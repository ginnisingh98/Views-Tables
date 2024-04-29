--------------------------------------------------------
--  DDL for Package Body IRC_XML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_XML_UTIL" as
/* $Header: irxmlutl.pkb 120.2 2006/03/11 02:48:31 mmillmor noship $ */
--
g_proxy varchar2(255);
g_wallet_path varchar2(255);
g_wallet_password varchar2(255);
--
-- -------------------------------------------------------------------------
-- |-------------------------< getWFXMLElement >---------------------------|
-- -------------------------------------------------------------------------
--
procedure getWFXMLElement
(itemtype  in     varchar2,
itemkey    in     varchar2,
actid      in     number,
funcmode   in     varchar2,
resultout     out nocopy varchar2) is
--
XPathTag varchar2(32767);
EventDocument CLOB;
Event wf_event_t;
parser xmlparser.parser;
event_doc xmldom.DOMDocument;
itemValue varchar2(32767);
responseAttr varchar2(32767);
--
begin

if (funcmode='RUN') then

  XPathTag:=wf_engine.getActivityAttrText
  (itemtype => itemtype
  ,itemkey  => itemkey
  ,actid    => actid
  ,aname    => 'TAG');

  responseAttr:=wf_engine.getActivityAttrText
  (itemtype => itemtype
  ,itemkey  => itemkey
  ,actid    => actid
  ,aname    => 'ATTR');

  Event:=wf_engine.getActivityAttrEvent
  (itemtype => itemtype
  ,itemkey  => itemkey
  ,actid    => actid
  ,name    => 'EVENT');

  if (XPathTag is not null and responseAttr is not null) then

    EventDocument:=Event.getEventData();
    itemValue:=irc_xml_util.valueOf(EventDocument,XPathTag);

    wf_engine.setItemAttrText
    (itemtype => itemtype
    ,itemkey  => itemkey
    ,aname    => responseAttr
    ,avalue   => itemValue);
  end if;
end if;
resultout:='COMPLETE';
exception
  when others then
    begin
      xmlparser.freeParser(parser);
      xmldom.freeDocument(event_doc);
    exception
    when others then
      null;
    end;
end getWFXMLElement;
--
-- -------------------------------------------------------------------------
-- |----------------------------< valueOf >---------------------------------|
-- -------------------------------------------------------------------------
--
function valueOf(doc xmldom.DOMDocument,xpath varchar2) return varchar2 is
--
retval varchar2(32767);
--
begin
--
  if (not xmldom.IsNull(doc)) then
    xslprocessor.valueOf(xmlDom.makeNode(doc),xpath,retval);
  end if;
  return retval;
end valueOf;
--
-- -------------------------------------------------------------------------
-- |----------------------------< valueOf >---------------------------------|
-- -------------------------------------------------------------------------
--
function valueOf(doc CLOB,xpath varchar2) return varchar2 is
--
retval varchar2(32767);
xmldoc xmldom.DOMDocument;
parser xmlparser.parser;
--
begin

  parser:=xmlparser.newParser;
  xmlparser.parseClob(parser,doc);
  xmldoc:=xmlparser.getDocument(parser);
  xmlparser.freeParser(parser);
  retval:=irc_xml_util.valueOf(xmldoc,xpath);
  xmldom.freeDocument(xmldoc);
  return retval;
exception
  when others then
    xmlparser.freeParser(parser);
    xmldom.freeDocument(xmldoc);
    return null;
end valueOf;
--
-- -------------------------------------------------------------------------
-- |----------------------------< valueOf >---------------------------------|
-- -------------------------------------------------------------------------
--
function valueOf(doc varchar2,xpath varchar2) return varchar2 is
--
retval varchar2(32767);
xmldoc xmldom.DOMDocument;
parser xmlparser.parser;
--
begin

  parser:=xmlparser.newParser;
  xmlparser.parseBuffer(parser,doc);
  xmldoc:=xmlparser.getDocument(parser);
  xmlparser.freeParser(parser);
  retval:=irc_xml_util.valueOf(xmldoc,xpath);
  xmldom.freeDocument(xmldoc);
  return retval;
exception
  when others then
    xmlparser.freeParser(parser);
    xmldom.freeDocument(xmldoc);
    return null;
end valueOf;
--
-- -------------------------------------------------------------------------
-- |----------------------------< http_get >--------------------------------|
-- -------------------------------------------------------------------------
--
function http_get(url varchar2) return varchar2 is
--
retval varchar2(32767);
l_proxy varchar2(255);
begin
  if(g_proxy is null) then
    g_proxy:=fnd_profile.value('WEB_PROXY_HOST');
  end if;
  if(g_proxy is not null) then
    l_proxy:=hr_util_web.proxyforURL(substr(url,1,2000));
  end if;
  if(lower(substr(url,1,5))='https') then
    if (g_wallet_path is null) then
      g_wallet_path:='file:'||fnd_profile.value('FND_DB_WALLET_DIR');
    end if;
    if (g_wallet_password is null) then
      g_wallet_password:=fnd_preference.eget('#INTERNAL','WF_WEBSERVICES','EWALLETPWD', 'WFWS_PWD');
    end if;
    retval:=UTL_HTTP.REQUEST(url   => url
                           ,proxy => l_proxy
                           ,wallet_path=>g_wallet_path
                           ,wallet_password=>g_wallet_password
                           );
  else
    retval:=UTL_HTTP.REQUEST(url   => url
                           ,proxy => l_proxy
                           );
  end if;
  return retval;
end http_get;
--
-- -------------------------------------------------------------------------
-- |------------------------< http_get_pieces >-----------------------------|
-- -------------------------------------------------------------------------
--
function http_get_pieces(url varchar2
                        ,max_pieces number) return utl_http.html_pieces is
--
retval utl_http.html_pieces;
l_proxy varchar2(255);
begin
  if(g_proxy is null) then
    g_proxy:=fnd_profile.value('WEB_PROXY_HOST');
  end if;
  if(g_proxy is not null) then
    l_proxy:=hr_util_web.proxyforURL(substr(url,1,2000));
  end if;
  if(lower(substr(url,1,5))='https') then
    if (g_wallet_path is null) then
      g_wallet_path:='file:'||fnd_profile.value('FND_DB_WALLET_DIR');
    end if;
    if (g_wallet_password is null) then
      g_wallet_password:=fnd_preference.eget('#INTERNAL','WF_WEBSERVICES','EWALLETPWD', 'WFWS_PWD');
    end if;
    retval:=UTL_HTTP.REQUEST_PIECES(url   => url
                           ,max_pieces=>max_pieces
                           ,proxy => l_proxy
                           ,wallet_path=>g_wallet_path
                           ,wallet_password=>g_wallet_password
                           );
  else
    retval:=UTL_HTTP.REQUEST_PIECES(url   => url
                           ,max_pieces=>max_pieces
                           ,proxy => l_proxy
                           );
  end if;
  return retval;
end http_get_pieces;
end irc_xml_util;

/
