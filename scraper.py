#!/usr/bin/env python
from __future__ import division
import sys
import scraperwiki
import lxml.html
import requests
import re
import json
import urlparse

# retry 5 times, as Highrise seems ropey
requests.defaults.defaults['max_retries'] = 5

user_list = {}


def get_settings():
    with open('../scraperwiki.json') as f:
        settings = json.load(f)
        try:
            return settings['highrise']['username'], \
                   settings['highrise']['password'], \
                   settings['highrise']['domain']
        except KeyError as err:
            sys.stderr.write("Could not find your Highrise %s" % err.message)
            exit(1)


def setup():
    global user_list
    
    xml = get_xml('https://%s/users.xml' % DOMAIN)
    if xml == None or xml.strip() == '':
        sys.stderr.write("Couldn't connect to your domain: please check it.")
        exit(1)
    users = lxml.html.fromstring(xml)
    for user in users.cssselect('user'):
        id = int(user.cssselect('id')[0].text)
        name = user.cssselect('name')[0].text
        user_list[id] = name
    
def get_xml(url):
    global APIKEY
    try:
        r=requests.get(url, auth=(APIKEY,'X'), verify=False)
    except:
        return None
    return r.content

def get_text(item):
    try:
        return item.text
    except:
        try:
            return item[0].text
        except:
            return None

def css_text(item, css):
    return get_text(item.cssselect(css))

def get_session():
    global BASEURL, APIKEY
    s = requests.session()
    dom = lxml.html.fromstring(s.get('https://launchpad.37signals.com/highrise/signin', verify=False).content)
    token = dom.cssselect('input[name=authenticity_token]')[0].get('value')
    params = {}
    params['username'] = USERNAME
    params['password'] = PASSWORD
    params['product'] = 'highrise'
    params['authenticity_token'] = token


    r = s.post('https://launchpad.37signals.com/session', params, verify=False)
    url = r.url
    dom = lxml.html.fromstring(r.content)
    if 'failed_authentication=true' in url:
        errmsg = dom.cssselect('#login_dialog h2')[0].text_content()
        sys.stderr.write(errmsg)
        exit(1)

    user_id = dom.xpath('.//meta[@name="current-user"]')[0].get('content')
    r = s.get(urlparse.urljoin(url, '/users/%s/edit' % user_id))

    dom = lxml.html.fromstring(r.content)
    APIKEY = dom.cssselect('#token')[0].text_content()

    return r

def get_deals():
    deal_lookup={'deal_name':'name', 'deal_id':'id', 'owner_id':'responsible-party-id', 'created':'created-at', 'updated':'updated-at', 'super_status':'status', 'price':'price'}
    
    deals = lxml.html.fromstring(get_xml('https://%s/deals.xml' % DOMAIN).cssselect('deals deal'))
     
    dealbuilder=[]
    for deal in deals:
        deal_info={}
        for item in deal_lookup:
            deal_info[item]=css_text(deal, deal_lookup[item])
        print 'getting deal:', deal_info['deal_name']
        oid = deal_info['owner_id']
        try:
            oid = int(oid)
            deal_info['owner']=user_list[oid]
        except TypeError:
            print "skipping deal %r" % deal_info
            continue
        m = re.search(r'(^\d{3,4}|\d{3,4}i?p?$)', deal_info['deal_name'], re.IGNORECASE)
        if m:
            deal_info['ref_no'] = m.group(0)
        else:
            deal_info['ref_no'] = None

        try: # see if they're a company :-(
            deal_info['company']=deal.xpath('party/name')[0].text
            deal_info['company_id']=deal.xpath('party/id')[0].text
        except IndexError: # is a person, not a company :)
            deal_info['company']=deal.xpath('party/company-name')[0].text
            deal_info['contact']='%s %s'%(deal.xpath('party/first-name')[0].text , deal.xpath('party/last-name')[0].text)
            deal_info['company_id']=deal.xpath('party/company-id')[0].text
            deal_info['contact_id']=deal.xpath('party/id')[0].text
        
        donesomething=False
    

        deal_info['status'] = None
        deal_info['status_details'] = None
        deal_info['redflag'] = None
        deal_info['redflag_details'] = None
        deal_info['completed'] = None

        
        dealbuilder.append(deal_info)
    
    print 'saving data'

    scraperwiki.sqlite.execute('DROP TABLE IF EXISTS deals')

    scraperwiki.sqlite.execute('CREATE TABLE `deals` (`deal_id` integer, `ref_no` text, `deal_name` text, `super_status` text, `status` text, `status_details` text, `status_due` text, `created` text, `updated` text, `redflag` text, `redflag_details` text, `price` integer, `company` text, `company_id` integer, `contact` text, `contact_id` integer, `owner` text, `owner_id` integer, `dropbox` text)')
    scraperwiki.sqlite.commit()
    
    scraperwiki.sqlite.save(['deal_id'], dealbuilder, 'deals')

USERNAME, PASSWORD, DOMAIN = get_settings()
APIKEY = None
get_session()
setup()
get_deals()
