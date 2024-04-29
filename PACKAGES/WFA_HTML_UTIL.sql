--------------------------------------------------------
--  DDL for Package WFA_HTML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WFA_HTML_UTIL" AUTHID CURRENT_USER as
/* $Header: wfhtms.pls 120.2.12010000.1 2008/07/25 14:42:07 appldev ship $ */

--
-- GetUrl (PRIVATE)
--   Produce URL link in response portion
-- IN
--   nid -
--   description - instructions
--   value - & || attr name
--   the value gets past off as a string which is then translated.
--   because the string only contains the URL attr, it will be correctly
--   substituted including and argument.
procedure GetUrl(
    nid          in number,
    description  in varchar2,
    value        in varchar2);

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
  nid          in number default null,
  nkey         in varchar2 default null);

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
  submit in boolean);

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
  otherattr in number);

-- SetAttribute (PRIVATE)
--   Set response attributes when processing a response.
-- IN
--   nid - notification id
--   attr_name_type - attribute name#type#format
--   attr_value - attribute value
--   doc_name -
--
procedure SetAttribute(
  nid            in number,
  attr_name_type in varchar2,
  attr_value     in varchar2,
  doc_name       in varchar2);

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
return varchar2;

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
  urlstrg out nocopy varchar2);


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
return varchar2;

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
return varchar2;

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
                               subject   out nocopy varchar2);

end WFA_HTML_UTIL;

/
