--------------------------------------------------------
--  DDL for Package Body WFA_HTML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WFA_HTML_UTIL" as
/* $Header: wfhtmb.pls 120.5.12010000.7 2009/12/09 18:47:45 vshanmug ship $ */


--
-- Package Globals
--
result_button_threshold pls_integer := 3;  -- Max number of submit buttons

--
-- GetUrl (PRIVATE)
--   Produce URL link in response portion
-- IN
--   nid -
--   description - instructions
--   value - url string not token substituted
procedure GetUrl(
    nid          in number,
    description  in varchar2,
    value        in varchar2)
as
urlstring varchar2(1950);
begin
  -- Ignore if no URL provided
  if (value is null) then
    return;
  end if;

 htp.tableRowOpen;

  -- Include description if needed.
  -- NOTE: Description are printed here instead of in the prompt link
  -- as for other fields, because the prompt is already used for the
  -- URL itself.
  if (description is not null) then
    htp.tableData(description, 'right', cattributes=>'id=""');
  else
    htp.tableData(htf.br, cattributes=>'id=""');
  end if;

  -- Print URL
  urlstring:=wf_notification.GetURLText(value, nid);

  -- Bug 4634849
  urlstring := wfa_html.encode_url(urlstring);
  htp.p('<td id=""> <a href="'||urlstring||'">'||urlstring||'</a></td>');

  htp.tableRowClose;

exception
  when others then
    wf_core.context('Wfa_Html_Util', 'GetUrl', value, description, to_char(nid));
    raise;
end GetUrl;

--
-- GetField (PRIVATE)
--   Produce a varchar2/number/date response field
-- IN
--   name - field name
--   type - field type (VARCHAR2, NUMBER, DATE)
--   format - format mask
--   dvalue - default value
--   index - the attribute element number in the attribute list
--
procedure GetField(
  name         in varchar2,
  type        in varchar2,
  format       in varchar2,
  dvalue       in varchar2,
  index_num    in number,
  nid          in number,
  nkey         in varchar2)
is
begin
   -- bug 7314545
   null;
end GetField;

--
-- GetLookup (PRIVATE)
--   Produce a lookup response field
-- IN
--   name - field name
--   value - default value (lookup code)
--   format - lookup type
--   submit - flag include a submit button for result field
--
procedure GetLookup(
  name in varchar2,
  value in varchar2,
  format in varchar2,
  submit in boolean)
as
begin
   -- bug 7314545
   null;
end GetLookup;

--
-- GetButtons (PRIVATE)
--   Produce a response field as submit buttons
-- IN
--   value - default value
--   format - lookup type
--
procedure GetButtons(
  value   in varchar2,
  format  in varchar2,
  otherattr in number)
as
begin
   -- bug 7314545
   null;
end GetButtons;

--
-- SetAttribute (PRIVATE)
--   Set response attributes when processing a response.
-- IN
--   nid - notification id
--   attr_name_type - attribute name#type#format
--   attr_value - attribute value
--
procedure SetAttribute(
  nid            in number,
  attr_name_type in varchar2,
  attr_value     in varchar2,
  doc_name       in varchar2)
as
begin
   -- bug 7314545
   null;
end SetAttribute;

--
-- GetLookupMeaning (PRIVATE)
--   Retrieve displayed value of lookup
-- IN
--   ltype - lookup type
--   lcode - lookup code
-- RETURNS
--   Displayed meaning of lookup code
--
function GetLookupMeaning(
  ltype in varchar2,
  lcode in varchar2)
return varchar2
is
  meaning varchar2(80);
begin
  select WL.MEANING
  into meaning
  from WF_LOOKUPS WL
  where WL.LOOKUP_TYPE = GetLookupMeaning.ltype
  and WL.LOOKUP_CODE = GetLookupMeaning.lcode;

  return(meaning);
exception
  when no_data_found then
    return(lcode);
  when others then
    wf_core.context('Wfa_Html_Util', 'GetLookupMeaning', ltype, lcode);
    raise;
end GetLookupMeaning;

--
-- GetUrlCount (PRIVATE)
-- IN
--   nid - notification id
-- OUT
--   urlcnt  - number of urls as reponse attributes
--   urlstrg - one of the urls if it exist
--             this is generally discarded unless there is only one
procedure GetUrlCount(
  nid in number,
  urlcnt out nocopy number,
  urlstrg out nocopy varchar2)
is
  buf pls_integer;
begin
   -- bug 7314545
   null;
end GetUrlCount;

--
-- GetResponseUrl (PRIVATE)
--   Return single response url.
--   NOTE: this assumes there is exactly one response url attribute.
-- IN
--   nid - notification id
-- RETURNS
--   Response url
--
function GetResponseUrl(
  nid in number)
return varchar2
is
  buf varchar2(4000);
begin
  select text_value
  into buf
  from WF_NOTIFICATION_ATTRIBUTES NA,
       WF_MESSAGE_ATTRIBUTES_VL MA,
       WF_NOTIFICATIONS N
  where N.NOTIFICATION_ID = nid
  and NA.NOTIFICATION_ID = N.NOTIFICATION_ID
  and MA.MESSAGE_NAME = N.MESSAGE_NAME
  and MA.MESSAGE_TYPE = N.MESSAGE_TYPE
  and MA.NAME = NA.NAME
  and MA.SUBTYPE = 'RESPOND'
  and MA.TYPE = 'URL'
  and ROWNUM = 1;

  return(buf);

exception
  when others then
    wf_core.context('Wfa_Html_Util', 'GetResponseUrl', to_char(nid));
    raise;
end GetResponseUrl;

--
-- GetDisplayValue (PRIVATE)
--   Get displayed value of a response field
-- IN
--   type - field type (VARCHAR2, NUMBER, DATE, LOOKUP, URL)
--   format - field format (depends on type)
--   tvalue - text value
--   nvalue - number value
--   dvalue - date value
-- RETURNS
--   Displayed value
--
function GetDisplayValue(
  type in varchar2,
  format in varchar2,
  tvalue in varchar2,
  nvalue in number,
  dvalue in date)
return varchar2
is
  s0 varchar2(2000);
  value varchar2(4000);
begin
  if (type = 'VARCHAR2') then
    value := tvalue;
  elsif (type = 'NUMBER') then
    if (format is null) then
      value := to_char(nvalue);
    else
      value := to_char(nvalue, format);
    end if;
  elsif (type = 'DATE') then
    -- <bug 7514495>
    value := wf_notification_util.GetCalendarDate( wf_notification_util.getCurrentNID() , dvalue, format);
  elsif (type = 'LOOKUP') then
    value := wfa_html_util.GetLookupMeaning(format, tvalue);
  elsif (type = 'URL') then
    value := tvalue;
  elsif (type = 'ROLE') then
    wf_directory.GetRoleInfo(tvalue, value, s0, s0, s0, s0);
  else
    -- Default to return text value unchanged
    value := tvalue;
  end if;

  return(value);

exception
  when others then
    wf_core.context('Wfa_Html_Util', 'GetDisplayWindow', type, format,
                    tvalue, to_char(nvalue), to_char(dvalue));
    raise;
end GetDisplayValue;

--
-- GetDenormalizedValues
--   Populate WF_NOTIFICATIONS with the needed values with supplied langcode.
--   Then returns those values via the out variables.
-- IN:
--   nid - notification id
--   langcode - language code
-- OUT:
--   from_user - display name of from role
--   to_user - display name of recipient_role
--   subject - subject of the notification
--
procedure GetDenormalizedValues(nid       in  number,
                                langcode  in  varchar2,
                                from_user out nocopy varchar2,
                                to_user   out nocopy varchar2,
                                subject   out nocopy varchar2)
is
begin
  Wf_Notification.Denormalize_Notification(nid=>nid,langcode=>langcode);

  begin
    select FROM_USER, TO_USER, SUBJECT
      into from_user, to_user, subject
      from WF_NOTIFICATIONS
     where NOTIFICATION_ID = nid;
  exception
    when OTHERS then
      from_user := null;
      to_user   := null;
      subject   := null;
  end;

exception
  when OTHERS then
    wf_core.context('Wfa_Html_Util', 'GetDenormalizedValues',
                    to_char(nid), langcode);
    raise;
end GetDenormalizedValues;

end WFA_HTML_UTIL;

/
