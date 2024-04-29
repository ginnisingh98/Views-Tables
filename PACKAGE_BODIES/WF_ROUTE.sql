--------------------------------------------------------
--  DDL for Package Body WF_ROUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ROUTE" AS
/* $Header: wfrtgb.pls 120.4 2006/04/06 09:31:41 rwunderl ship $ */

--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error
as
begin
  Null;
end Error;

--
-- RuleOwner (PRIVATE)
--   Return role owning this rule, and validate rule exists
-- IN
--   ruleid - rule id
-- RETURNS
--   Owning role
--
function RuleOwner(
  ruleid in number)
return varchar2
is
  owner varchar2(320);
begin
  begin
    select WRR.ROLE
    into owner
    from WF_ROUTING_RULES WRR
    where WRR.RULE_ID = RuleOwner.ruleid;
  exception
    when no_data_found then
      Wf_Core.Token('RULE', to_char(ruleid));
      Wf_Core.Raise('WFRTG_INVALID_RULE');
  end;

  return owner;
exception
  when others then
    wf_core.context('Wf_Route', 'RuleOwner', to_char(ruleid));
    raise;
end RuleOwner;

--
-- Authenticate (PRIVATE)
--   Authenticate current user has access to rules for this user.
--   Exception raised if access is denied.
-- IN
--   user - user to check
-- RETURNS
--   Authenticated username
--   (username, or current user if username passed in is null)
--
function Authenticate(
  user in varchar2)
return varchar2
is
  curuser varchar2(320);
  admin_role varchar2(320);
begin
  -- Get current user
  Wfa_Sec.GetSession(curuser);

  -- If user is null, must be for current user
  if (user is null) then
    return(curuser);
  end if;

  -- If admin granted to current user,
  -- grant access and pretend to be
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
      Wf_Directory.IsPerformer(curuser, admin_role)) then
    return(user);
  end if;

  -- Otherwise current user must match the user checking
  if (curuser <> user) then
    Wf_Core.Token('CURUSER', curuser);
    Wf_Core.Token('USER', user);
    Wf_Core.Raise('WFRTG_ACCESS_USER');
  end if;

  return(user);
exception
  when others then
    wf_core.context('Wf_Route', 'Authenticate', user);
    raise;
end Authenticate;

--
-- GetAttrValue (PRIVATE)
--   Get value of response rule attribute
-- IN
--   ruleid - routing rule id
--   attrname - attribute name
-- OUT
--   tvalue - text value
--   nvalue - number value
--   dvalue - date value
-- RETURNS
--   False if no attr not defined for this rule
--
function GetAttrValue(
  ruleid in number,
  attrname in varchar2,
  tvalue out nocopy varchar2,
  nvalue out nocopy number,
  dvalue out nocopy date)
return boolean
is
begin
  select WRRA.TEXT_VALUE, WRRA.NUMBER_VALUE, WRRA.DATE_VALUE
  into tvalue, nvalue, dvalue
  from WF_ROUTING_RULE_ATTRIBUTES WRRA
  where WRRA.RULE_ID = GetAttrValue.ruleid
  and WRRA.NAME = GetAttrValue.attrname;

  return(TRUE);
exception
  when no_data_found then
    return(FALSE);
  when others then
    wf_core.context('Wf_Route', 'GetAttrValue', to_char(ruleid), attrname);
    raise;
end GetAttrValue;

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
    wf_core.context('Wf_Route', 'GetLookupMeaning', ltype, lcode);
    raise;
end GetLookupMeaning;

--
-- GetDisplayValue (PRIVATE)
--   Get displayed value of a response attribute field
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
  l_username VARCHAR2(320);
  value varchar2(2000);
  l_document_attributes   fnd_document_management.fnd_document_attributes;

begin
  -- Check session and current user
  wfa_sec.GetSession(l_username);
  l_username := upper(l_username);

  if (type = 'VARCHAR2') then
    value := tvalue;
  elsif (type = 'NUMBER') then
    if (format is null) then
      value := to_char(nvalue);
    else
      value := to_char(nvalue, format);
    end if;
  elsif (type = 'DATE') then
    if (format is null) then
      value := to_char(dvalue);
    else
      value := to_char(dvalue, format);
    end if;
  elsif (type = 'LOOKUP') then
    value := GetLookupMeaning(format, tvalue);
  elsif (type = 'URL') then
    value := tvalue;
  elsif (type = 'DOCUMENT') then
     /*
     ** If the default value is a dm document then go get the
     ** title from the DM system and place it in the field.  If
     ** its a plsql doc then just put the default value in the field
     */
     IF (SUBSTR(tvalue, 1, 3) = 'DM:') THEN

          /*
          ** get the document name
          */
          fnd_document_management.get_document_attributes(l_username,
             tvalue,
             l_document_attributes);

          value := l_document_attributes.document_name;

     ELSE

       -- Default to return text value unchanged
        value := tvalue;

     END IF;

  else
    -- Default to return text value unchanged
    value := tvalue;
  end if;

  return(value);

exception
  when others then
    wf_core.context('Wf_Route', 'GetDisplayWindow', type, format,
                    tvalue, to_char(nvalue), to_char(dvalue));
    raise;
end GetDisplayValue;

--
--
-- GetRole (PRIVATE)
-- Produce a Role response field
procedure GetRole(
  name         in varchar2,
  dvalue       in varchar2,
  seq          in varchar2 )
is
  len       pls_integer;
  l_message     varchar2(240)   := wfa_html.replace_onMouseOver_quotes(wf_core.translate ('WFPREF_LOV'));

-- variable for LOV
  l_url    varchar2(1000);
  l_media  varchar2(240) := wfa_html.image_loc;
  l_icon   varchar2(30)  := 'FNDILOV.gif';
  l_text   varchar2(30) := '';
  realname varchar2(360) := null;
  s0       varchar2(2000);
--
begin

  -- Draw field
  htp.formHidden('h_fnames', name||'#ROLE#');
  -- always print the display field as null
  htp.formHidden('h_fvalues', dvalue);

  -- get the display name
  wf_directory.GetRoleInfo(dvalue, realname, s0, s0, s0, s0);

  -- add LOV here: Note:bottom is name of frame.
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
            REPLACE('wf_lov.display_lov?p_lov_name='||'owner'||
            '&p_display_name='||'WFA_FIND_USER'||
            '&p_validation_callback=wfa_html.wf_user_val'||
            '&p_dest_hidden_field=top.opener.parent.document.CREATE_RULE.h_fvalues['||seq||'].value'||
            '&p_current_value=top.opener.parent.document.CREATE_RULE.h_fdocnames['||seq||'].value'||
            '&p_display_key='||'Y'||
            '&p_dest_display_field=top.opener.parent.document.CREATE_RULE.h_fdocnames['||seq||'].value',
               ' ', '%20')||''''||',500,500)';

  -- print everything together so ther is no gap.
  htp.tabledata(htf.formText(cname=>'h_fdocnames',
                csize=>30,
                cmaxlength=>240,
                cvalue=>realname,
                cattributes=>'id="i_attr'||seq||'"')||
               '<A href='||l_url||'>'||
               '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                    l_message||'" onmouseover="window.status='||''''||
                    l_message||''''||';return true"></A>',
                    cattributes=>'id=""');

exception
  when others then
    wf_core.context('Wf_route', 'GetRole', name, seq);
    raise;
end GetRole;


--
-- GetLookup (PRIVATE)
--   Produce a lookup response field
-- IN
--   name - field name
--   value - default value (lookup code)
--   format - lookup type
--   submit - flag include a submit button for result field
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - added ID attrib for TD tag for ADA
--
procedure GetLookup(
  name in varchar2,
  value in varchar2,
  format in varchar2,
  submit in boolean,
  seq    in varchar2)
as
  cursor lookup_codes(p_lookup_type varchar2) is
    select MEANING, LOOKUP_CODE
    from   WF_LOOKUPS
    where  LOOKUP_TYPE = p_lookup_type
    order by MEANING;

  template varchar2(4000);

begin
  -- always print the display field as null
  htp.formHidden('h_fdocnames', '');

  -- Create hidden field and select list
  template := htf.formHidden('h_fnames', name||'#LOOKUP#'||format)||
                             wf_core.newline||
              htf.formSelectOpen('h_fvalues',
                                  cattributes=>'id="i_attr'||seq||'"');


  -- Add all lookups to select list
  for i in lookup_codes(format) loop
    if (i.lookup_code = value) then
      template := template||wf_core.newline||
                  htf.formSelectOption(i.meaning, 'SELECTED');
    else
      template := template||wf_core.newline||
                  htf.formSelectOption(i.meaning);
    end if;
  end loop;
  template := template||wf_core.newline||htf.formSelectClose;

  if (not submit) then
    -- Draw a normal field
    htp.tableData(template, 'left',cattributes=>'id=""');
  else
    -- Draw a submit-style field for the result.
    -- Leave TableData open so reassign button can be added to same cell.
    htp.p('<TD ID="" ALIGN=left>'
             ||wf_core.newline||template);
    htp.formSubmit('Submit', wf_core.translate('SUBMIT'), 'NOBORDER');
  end if;

exception
  when others then
    wf_core.context('Wf_Route', 'GetLookup', name, value, format, seq);
    raise;
end GetLookup;

-- GetDocument (PRIVATE)
-- Prints the document text field with the DM lov button.
Procedure GetDocument (name      in varchar2,
             format    in varchar2,
             dvalue    in varchar2,
             index_num in varchar2) is

   l_username      varchar2(320);   -- Username to query
   l_callback_URL  varchar2(4000);
   l_attach_URL    varchar2(4000);
begin

  htp.formHidden('h_fnames', name||'#DOCUMENT#'||format);
  htp.formHidden('h_fvalues', null);

  -- Set the destination field name for the document id
  fnd_document_management.set_document_id_html (
        null,
        'CREATE_RULE',
        'h_fvalues['||index_num||']',
        'h_fdocnames['||index_num||']',
        l_callback_url);

  -- Check session and current user
  wfa_sec.GetSession(l_username);
  l_username := upper(l_username);

  fnd_document_management.get_launch_attach_url (
        l_username,
        l_callback_url,
        TRUE,
        l_attach_url);

  -- document field
  htp.tableData(cvalue=>htf.formText(cname=>'h_fdocnames', csize=>32,
                                     cmaxlength=>60,
                                     cvalue=>dvalue,
                cattributes=>'id="i_attr'||index_num||'"')
                ||'&nbsp&nbsp&nbsp'||l_attach_URL,
                calign=>'Left',
                cattributes=>'id=""');

exception
  when others then
    wf_core.context('Wf_route', 'GetDocument', name, format, dvalue);
    raise;
end GetDocument;

--
-- GetField (PRIVATE)
--   Produce a varchar2/number/date response field
-- IN
--   name - field name
--   type - field type (VARCHAR2, NUMBER, DATE)
--   format - format mask
--   dvalue - default value
--   index_num - for ada enhancement
--
procedure GetField(
  name         in varchar2,
  type         in varchar2,
  format       in varchar2,
  dvalue       in varchar2,
  index_num    in varchar2)
is
  len      number;
begin
  -- Figure field len
  if (type = 'VARCHAR2') then
    len := nvl(to_number(format), 2000);
  else
    len := 62;
  end if;

  -- Draw field
  htp.formHidden('h_fnames', name||'#'||type||'#'||format);

  -- always print the display field as null
  htp.formHidden('h_fdocnames', '');

  if (len <= 80) then
    -- single line field
    htp.tableData(
        cvalue=>htf.formText(cname=>'h_fvalues',
                             csize=>len,
                             cmaxlength=>len,
                             cvalue=>dvalue,
        cattributes=>'id="i_attr'||index_num||'"'),
        calign=>'Left',
        cattributes=>'id=""');
  else
    -- multi line field
    htp.tableData(
        cvalue=>htf.formTextareaOpen2(
                    cname=>'h_fvalues',
                    nrows=>2,
                    ncolumns=>65,
                    cwrap=>'SOFT',
                    cattributes=>'id="i_attr'||index_num||'" maxlength= '||to_char(len))
        || dvalue|| htf.formTextareaClose,
        calign=>'Left',
        cattributes=>'id=""');
  end if;
exception
  when others then
    wf_core.context('Wf_Route', 'GetField', name, type, format, dvalue,
           index_num);
    raise;
end GetField;

--
-- ValidateRole (PRIVATE)
--   Validate that role is valid internal or display name
-- IN
--   role - role to check
-- RETURNS
--   Internal name of role
--
function ValidateRole(
  role in varchar2)
return varchar2
is
  dummy number;
  rname varchar2(320); -- Internal name of role
  role_info_tbl  wf_directory.wf_local_roles_tbl_type;
begin
  -- Look first for internal name
  rname := upper(ValidateRole.role);
  Wf_Directory.GetRoleInfo2(rname,role_info_tbl);
  if (role_info_tbl(1).name is not null) then
    return(rname);
  end if;

  -- Look for display_name
  begin
    -- Very costly statement
    select NAME
    into rname
    from WF_ROLE_LOV_VL
    where DISPLAY_NAME = ValidateRole.role;

    -- Found, return internal name
    return(rname);
  exception
    when no_data_found then
      -- Not displayed or internal role name, error
      wf_core.token('ROLE', role);
      wf_core.raise('WFNTF_ROLE');
  end;

exception
  when others then
    wf_core.context('Wf_Route', 'ValidateRole', role);
    raise;
end ValidateRole;

--
-- StringToDate (PRIVATE)
--   Convert string to date, taking optional time into account
-- NOTE
--   Makes the following assumptions:
--   1. Default NLS_DATE_FORMAT does not have a time component,
--      and does not contain any ':' characters.
--   2. Dstring will be in one of the following formats:
--        NLS_DATE_FORMAT
--        NLS_DATE_FORMAT||' HH24:MI'
--        NLS_DATE_FORMAT||' HH24:MI:SS'
-- IN
--   dstring - date as string
-- RETURNS
--   Date as date
--
function StringToDate(
  dstring in varchar2)
return date
is
  colon1 number;
  colon2 number;
  space number;
  datebuf date;
begin
  -- Check for time component
  colon1 := instr(dstring, ':', 1, 1);
  if (colon1 = 0) then
    -- No time component, do a straight conversion
    datebuf := to_date(dstring, SYS_CONTEXT('USERENV','NLS_DATE_FORMAT'));
  else
    -- Look for last space in string (not counting trailers).
    -- Using this as dividing point, get date portion of string
    -- without time.
    space := instr(rtrim(dstring), ' ', -1, 1);
    datebuf := to_date(substr(dstring, 1, space-1),SYS_CONTEXT('USERENV','NLS_DATE_FORMAT'));

    -- Append time component
    colon2 := instr(dstring, ':', 1, 2);
    if (colon2 = 0) then
      -- Assume HH24:MI time component
      datebuf := to_date(to_char(datebuf, 'YYYY/MM/DD')||
                         to_char(to_date(substr(dstring, space),
                                         ' HH24:MI'),
                                 ' HH24:MI'),
                         'YYYY/MM/DD HH24:MI');
    else
      -- Assume HH24:MI:SS time component
      datebuf := to_date(to_char(datebuf, 'YYYY/MM/DD')||
                         to_char(to_date(substr(dstring, space),
                                         ' HH24:MI:SS'),
                                 ' HH24:MI:SS'),
                          'YYYY/MM/DD HH24:MI:SS');
    end if;
  end if;

  return(datebuf);
exception
  when others then
    wf_core.context('Wf_Route', 'StringToDate', dstring);
    raise;
end StringToDate;

--
-- SetAttribute (PRIVATE)
--   Set routing response attributes
-- IN
--   ruleid - routing rule id
--   attr_name_type - attribute name#type#format
--   attr_value - attribute value
--
procedure SetAttribute(
  ruleid         in number,
  attr_name_type in varchar2,
  attr_value     in varchar2,
  attr_doc_name       in varchar2)
as
  first     number;
  second    number;
  attr_type varchar2(8);
  attr_name varchar2(30);
  attr_fmt  varchar2(240);

  tvalue varchar2(2000) := '';
  nvalue number := '';
  dvalue date := '';
begin
  -- Parse out name#type#format
  first  := instr(attr_name_type, '#', 1);
  second := instr(attr_name_type, '#', 1, 2);
  attr_name := substr(attr_name_type, 1, first-1);
  attr_type := substr(attr_name_type, first+1, second-first-1);
  attr_fmt  := substr(attr_name_type, second+1,
                      length(attr_name_type)-second);

  if (attr_type = 'DATE') then
    if (attr_fmt is not null) then
      dvalue := to_date(attr_value, attr_fmt);
    else
      dvalue := to_date(attr_value,SYS_CONTEXT('USERENV','NLS_DATE_FORMAT'));
    end if;
  elsif (attr_type = 'NUMBER') then
    if (attr_fmt is not null) then
      nvalue := to_number(attr_value, attr_fmt);
    else
      nvalue := to_number(attr_value);
    end if;
  elsif (attr_type = 'LOOKUP') then
    -- Decode lookup meaning to code
    begin
      select WL.LOOKUP_CODE
      into   tvalue
      from   WF_LOOKUPS WL
      where  Wl.LOOKUP_TYPE = SetAttribute.attr_fmt
      and    MEANING = SetAttribute.attr_value;
    exception
      when no_data_found then
        wf_core.token('TYPE', attr_fmt);
        wf_core.token('CODE', attr_value);
        wf_core.raise('WFSQL_LOOKUP_CODE');
    end;
  elsif (attr_type = 'ROLE') then

    -- Decode role to internal name
    tvalue := attr_value;
    wfa_html.validate_display_name (attr_doc_name, tvalue);

  else
    -- VARCHAR2 or misc values all use text
    tvalue := attr_value;
  end if;

  -- Update/Insert attributes table with new values
  update WF_ROUTING_RULE_ATTRIBUTES WRRA set
    TEXT_VALUE = SetAttribute.tvalue,
    NUMBER_VALUE = SetAttribute.nvalue,
    DATE_VALUE = SetAttribute.dvalue
  where WRRA.RULE_ID = SetAttribute.ruleid
  and WRRA.NAME = SetAttribute.attr_name;

  if (sql%rowcount = 0) then
    -- Insert missing attribute row
    insert into WF_ROUTING_RULE_ATTRIBUTES (
      RULE_ID,
      NAME,
      TYPE,
      TEXT_VALUE,
      NUMBER_VALUE,
      DATE_VALUE
    ) values (
      SetAttribute.ruleid,
      SetAttribute.attr_name,
      'RESPOND',
      SetAttribute.tvalue,
      SetAttribute.nvalue,
      SetAttribute.dvalue
    );
  end if;
exception
  when others then
    wf_core.context('Wf_Route', 'SetAttribute',
                    to_char(ruleid), attr_name_type, attr_value);
    raise;
end SetAttribute;


--
-- DeleteRule
--   Delete rule with ruleid
-- IN
--   user - role owning rule
--   ruleid - Rule id
--
procedure DeleteRule(
  user in varchar2 ,
  ruleid in varchar2)
is
  owner varchar2(320);
begin
  -- Validate access
  owner := Wf_Route.Authenticate(user);

  -- Delete this rule along with any child attributes
  delete from WF_ROUTING_RULE_ATTRIBUTES
  where RULE_ID = ruleid;

  delete from WF_ROUTING_RULES
  where RULE_ID = ruleid;

  -- Return to opening page
  Wf_Route.List(user, '--EDITSCREEN--');
exception
  when others then
    wf_core.context('Wf_Route', 'DeleteRule', ruleid, user);
    wf_route.error;
end;

--
-- SubmitUpdate
--   Process rule update page
-- IN
--   ruleid - Rule id
--   action - Rule action
--   action_argument - Forward to if forward
--   begin_date - Begin date
--   end_date - End date
--   rule_comment - Rule comment
--   h_fnames - array of attr field names
--   h_fvalues - array of attr field values
--   h_fdocnames - array of document name values
--   h_counter - number of fields passed in fnames and fvalues
--   delete_button - Delete button flag (for cancel this operation)
--   update_button - Update button flag
--
procedure SubmitUpdate(
  rule_id in varchar2,
  action in varchar2,
  fmode  in varchar2 ,
  action_argument in varchar2 ,
  display_action_argument in varchar2 ,
  begin_date in varchar2 ,
  end_date in varchar2 ,
  rule_comment in varchar2 ,
  h_fnames in Name_Array,
  h_fvalues in Value_Array,
  h_fdocnames in Value_Array,
  h_counter in varchar2,
  delete_button in varchar2 ,
  update_button in varchar2 )
is
  nruleid number;
  owner varchar2(320);
  realname varchar2(360);
  s0 varchar2(2000);
  forwardee varchar2(320);
  l_action varchar2(30) := '';
  begdate date;
  enddate date;
  CANCEL_RECORD exception;
begin
  -- Find rule owner and validate access
  nruleid := to_number(rule_id);
  owner := Wf_Route.RuleOwner(nruleid);
  owner := Wf_Route.Authenticate(owner);
  wf_directory.GetRoleInfo(owner, realname, s0, s0, s0, s0);

  l_action := substrb(action, 1, 30);

  if (delete_button is not null) then
/*
    -- Now delete rule in the List procedure instead of here
    -- Delete this rule along with any child attributes
    delete from WF_ROUTING_RULE_ATTRIBUTES
    where RULE_ID = nruleid;

    delete from WF_ROUTING_RULES
    where RULE_ID = nruleid;
*/
    -- Cancel the operation and return to opening page
    raise CANCEL_RECORD;

  else
    -- UPDATE

    --
    -- Update main table data
    --
    if (action = 'FORWARD') then
      forwardee := action_argument;
      wfa_html.validate_display_name (display_action_argument, forwardee);
      l_action := substrb(fmode, 1, 30);
    end if;

    begdate := StringToDate(begin_date);
    enddate := StringToDate(end_date);

    -- Validate date range
    if (enddate <= begdate) then
      wf_core.raise('WFRTG_BAD_DATE_RANGE');
    end if;

    -- Update columns in main table
    update WF_ROUTING_RULES WRR set
      ACTION = l_action,
      ACTION_ARGUMENT = SubmitUpdate.forwardee,
      BEGIN_DATE = SubmitUpdate.begdate,
      END_DATE = SubmitUpdate.enddate,
      RULE_COMMENT = SubmitUpdate.rule_comment
    where WRR.RULE_ID = SubmitUpdate.nruleid;

    --
    -- Update routing attributes if RESPOND
    --
    if (action = 'RESPOND') then
      -- Start at 2 to step over the Dummy_Name/Dummy_Value pair added at
      -- the start of the array.
      for i in 2 .. to_number(h_counter) loop
        SetAttribute(nruleid, h_fnames(i), h_fvalues(i), h_fdocnames(i));
      end loop;
    else
      begin
      -- Update attributes table with null values since this is not a response
      update WF_ROUTING_RULE_ATTRIBUTES WRRA set
             TEXT_VALUE = null,
             NUMBER_VALUE = null,
             DATE_VALUE = null
      where WRRA.RULE_ID = nruleid;
      exception
         when others then null;
      end;
    end if;
  end if;

  -- Go back to the List page
  owa_util.redirect_url(curl=>wfa_html.base_url || '/wf_route.list?user='||owner||'&display_user=--EDITSCREEN--',
                         bclose_header=>TRUE);

exception
  when CANCEL_RECORD then
    Wf_Route.List(owner);

  when others then
    wf_core.context('Wf_Route', 'SubmitUpdate', rule_id, action,
                    action_argument, begin_date, end_date);
    wf_route.error;
end SubmitUpdate;

--
-- UpdateRule
--   Update values for existing rule
-- IN
--   rule_id - Rule id number
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 -Added summary attr for table tag for ADA
--             - Added ID attr for TD tags
--             - Added label for input fields and radio buttons
--
procedure UpdateRule(
  ruleid in varchar2)
is
  nruleid number;
  owner varchar2(320);
  realname varchar2(360);
  s0 varchar2(2000);
  l_url         varchar2(1000);
  l_media       varchar2(240) := wfa_html.image_loc;
  l_icon        varchar2(30) := 'FNDILOV.gif';
  l_onmouseover varchar2(240) := wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFA_FIND_USER'));

  -- Rule data
  cursor rulecurs is
    select WRR.MESSAGE_TYPE,
           WRR.MESSAGE_NAME,
           to_char(WRR.BEGIN_DATE)||to_char(WRR.BEGIN_DATE, ' HH24:MI:SS')
             CBEGIN_DATE,
           to_char(WRR.END_DATE) ||to_char(WRR.END_DATE, ' HH24:MI:SS')
             CEND_DATE,
           WRR.ACTION,
           WRR.ACTION_ARGUMENT,
           WRR.RULE_COMMENT,
           WIT.DISPLAY_NAME TYPE_DISPLAY,
           WM.SUBJECT
    from WF_ROUTING_RULES WRR, WF_ITEM_TYPES_VL WIT, WF_MESSAGES_VL WM,
         WF_LOOKUPS WL
    where WRR.RULE_ID = nruleid
    and WRR.MESSAGE_TYPE = WIT.NAME (+)
    and WRR.MESSAGE_TYPE = WM.TYPE (+)
    and WRR.MESSAGE_NAME = WM.NAME (+)
    and WRR.ACTION = WL.LOOKUP_CODE
    and WL.LOOKUP_TYPE = 'WFSTD_ROUTING_ACTIONS';

--  Obsolete fields from above select
--           WM.DISPLAY_NAME MSG_DISPLAY,
--           WL.MEANING ACTION_DISPLAY
--

  rulerec rulecurs%rowtype;

  -- Attr data
  cursor attrcurs is
    select WMA.NAME,
           WMA.DISPLAY_NAME,
           WMA.VALUE_TYPE,
           decode(WMA.VALUE_TYPE, 'ITEMATTR', WIA.TEXT_DEFAULT,
                  WMA.TEXT_DEFAULT) TEXT_VALUE,
           decode(WMA.VALUE_TYPE, 'ITEMATTR', WIA.NUMBER_DEFAULT,
                  WMA.NUMBER_DEFAULT) NUMBER_VALUE,
           decode(WMA.VALUE_TYPE, 'ITEMATTR', WIA.DATE_DEFAULT,
                  WMA.DATE_DEFAULT) DATE_VALUE,
           WMA.TYPE,
           WMA.FORMAT
    from WF_ROUTING_RULES WRR,
         WF_MESSAGE_ATTRIBUTES_VL WMA,
         WF_ITEM_ATTRIBUTES WIA
    where WRR.RULE_ID = nruleid
    and WRR.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and WRR.MESSAGE_NAME = WMA.MESSAGE_NAME
    and WMA.SUBTYPE = 'RESPOND'
    and WMA.TYPE not in ('FORM', 'URL')
    and WMA.MESSAGE_TYPE = WIA.ITEM_TYPE (+)
    and WMA.TEXT_DEFAULT = WIA.NAME (+)
    order by decode(WMA.NAME, 'RESULT', 9999, WMA.SEQUENCE);

--  Obsolete field from above SQL statement
--           WMA.DESCRIPTION,

  tvalue varchar2(2000);
  nvalue number;
  dvalue date;
  dispvalue varchar2(2000);
  respcnt number := 0;
  rowcount number;
  msg_type varchar2(8);
  msg_name varchar2(30);

  fchecked pls_integer := null;
  tchecked pls_integer := null;
  l_message     varchar2(240)   := wfa_html.replace_onMouseOver_quotes(wf_core.translate ('WFPREF_LOV'));

begin
  -- Find rule owner and validate access
  nruleid := to_number(ruleid);
  owner := Wf_Route.RuleOwner(nruleid);
  owner := Wf_Route.Authenticate(owner);
  wf_directory.GetRoleInfo(owner, realname, s0, s0, s0, s0);

  -- Get rule data
  open rulecurs;
  fetch rulecurs into rulerec;
  if (rulecurs%notfound) then
    Wf_Core.Token('RULE', to_char(nruleid));
    Wf_Core.Raise('WFRTG_INVALID_RULE');
  end if;
  close rulecurs;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFRTG_UPDATE_TITLE')||' '||realname);
  wfa_html.create_help_function('wf/links/upr.htm?UPRULE');
  fnd_document_management.get_open_dm_display_window;

  -- Add the java script to the header to open the dm window for
  -- any DM function that and any standard LOV
  fnd_document_management.get_open_dm_attach_window;

  htp.headClose;
  wfa_sec.Header(FALSE,'',wf_core.translate('WFRTG_UPDATE_TITLE'), TRUE);

  -- Open form
  -- Add dummy fields to start both array-type input fields.
  -- These dummy values are needed so that the array parameters to
  -- the submit procedure will not be null even if there are no real
  -- response fields.  This would cause a pl/sql error, because array
  -- parameters can't be defaulted.
  htp.p('<FORM NAME="CREATE_RULE" ACTION="wf_route.SubmitUpdate" METHOD="POST">');
  htp.formHidden('h_fnames', 'Dummy_Name');
  htp.formHidden('h_fvalues', 'Dummy_Value');
  htp.formHidden('h_fdocnames', 'Dummy_Document_Value');
  htp.formHidden('rule_id', ruleid);
--  htp.formHidden('action', rulerec.action);

  htp.tableOpen(cattributes=>'width=100% summary=""');

  --
  -- Rules main table section
  --

  -- Message Type/Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('MESSAGE_TYPE'),
                calign=>'right',
                cattributes=>'id=""');
  htp.tableHeader(cvalue=>nvl(rulerec.type_display,
                              htf.em(wf_core.translate('<ALL>'))),
                  calign=>'left',
              cattributes=>'id=""');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('NOTIFICATION'),
                calign=>'right',
                cattributes=>'id=""');
  IF (rulerec.subject IS NULL) THEN

     htp.tableHeader(cvalue=>htf.em(wf_core.translate('<ALL>')),
                     calign=>'left',
               cattributes=>'id=""');
  ELSE

     htp.tableHeader(cvalue=>wf_notification.GetSubSubjectDisplay(rulerec.message_type,
                                rulerec.message_name),
                     calign=>'left',cattributes=>'id=""');

  END IF;

  htp.tableRowClose;

  -- Active Dates
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_begin_date">' ||
                wf_core.translate('WFRTG_BEGIN_DATE') || '</LABEL>',
                calign=>'right',
                cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'begin_date',
                                     csize=>30, cmaxlength=>64,
                                     cvalue=>rulerec.cbegin_date,
                                     cattributes=>'id="i_begin_date"'),
                  calign=>'left',
                  cattributes=>'id=""');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_end_date">' ||
                wf_core.translate('WFRTG_END_DATE') || '</LABEL>',
                calign=>'right',
                cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'end_date',
                                     csize=>30, cmaxlength=>64,
                                     cvalue=>rulerec.cend_date,
                                     cattributes=>'id="i_end_date"'),
                  calign=>'left',
                  cattributes=>'id=""');
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData(htf.br,cattributes=>'id=""');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableHeader(wf_core.translate('WFRTG_AUTOMATICALLY'), 'left',
         ccolspan=>'2',cattributes=>'id=""');
  htp.tableRowClose;


  -- Comment

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_rule_comment">' ||
                wf_core.translate('WFRTG_COMMENTS_INCLUDE') || '</LABEL>',
                calign=>'right', cattributes=>'width="10%" id=""');
  htp.tableData(cvalue=>htf.formTextareaOpen2(
                          cname=>'rule_comment',
                          nrows=>3,
                          ncolumns=>65,
                          cwrap=>'soft',
                          cattributes=>'maxlength=2000 id="i_rule_comment"')||
                        rulerec.rule_comment||
                        htf.formTextareaClose,
                  ccolspan=>3,
                  calign=>'left', cattributes=>'width="*" id=""');
  htp.tableRowClose;

  htp.tableClose;

  -- Action
  if (rulerec.action = 'FORWARD' or rulerec.action = 'TRANSFER') then
    if (rulerec.action = 'FORWARD') then
       fchecked := 1;
    else
       tchecked := 1;
    end if;
    htp.formRadio(cname=>'action', cvalue=>'FORWARD', cchecked=>'1',
         cattributes=>'id="i_wfa_assignto"');

  else

    htp.formRadio(cname=>'action', cvalue=>'FORWARD',
         cattributes=>'id="i_wfa_assignto"');
    -- If this is not a reassign the go ahead and set the delagate default
    fchecked := 1;

  end if;

  htp.p('<LABEL FOR="i_wfa_assignto">' ||
      wf_core.translate('WFA_ASSIGNTO') || '</LABEL>');
  htp.formHidden('action_argument', rulerec.action_argument);

  if (rulerec.action_argument IS NOT NULL) then

     wf_directory.GetRoleInfo(rulerec.action_argument, realname, s0, s0, s0, s0);

  end if;

  -- add LOV here: Note:bottom is name of frame.
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
            REPLACE('wf_lov.display_lov?p_lov_name='||'owner'||
            '&p_display_name='||'WFA_FIND_USER'||
            '&p_validation_callback=wfa_html.wf_user_val'||
            '&p_dest_hidden_field=top.opener.parent.document.CREATE_RULE.action_argument.value'||
            '&p_current_value=top.opener.parent.document.CREATE_RULE.display_action_argument.value'||
            '&p_display_key='||'Y'||
            '&p_dest_display_field=top.opener.parent.document.CREATE_RULE.display_action_argument.value',
              ' ', '%20')||''''||',500,500)';

  -- print everything together so ther is no gap.
  htp.formText(cname=>'display_action_argument', csize=>30,
               cmaxlength=>240,
               cvalue=>realname,
               cattributes=>'id="i_wfa_assignto"');
  htp.p('<A href='||l_url||'>'||
               '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                    l_message||'" onmouseover="window.status='||''''||
                    l_message||''''||';return true"></A>');

  htp.br;

  -- Forward Mode
  htp.p('&'||'nbsp;&'||'nbsp;&'||'nbsp;');
  htp.formRadio(cname=>'fmode', cvalue=>'FORWARD', cchecked=>fchecked,
       cattributes=>'id="i_group_reassign"');
  htp.p('<LABEL FOR="i_group_reassign">' ||
      wf_core.translate('WFA_GROUP_REASSIGN_DELEGATE') || '</LABEL>');
  htp.br;
  htp.p('&'||'nbsp;&'||'nbsp;&'||'nbsp;');
  htp.formRadio(cname=>'fmode', cvalue=>'TRANSFER', cchecked=>tchecked,
       cattributes=>'id="i_transfer"');
  htp.p('<LABEL FOR="i_transfer">' ||
       wf_core.translate('WFA_GROUP_REASSIGN_TRANSFER') || '</LABEL>');
  htp.br;

  -- ### Comment below out since we have Delegate and Transfer implemented
  -- Instead put a hidden field to make fmode forward
  -- htp.formHidden('fmode', 'FORWARD');

  select MESSAGE_TYPE, MESSAGE_NAME
    into msg_type, msg_name
    from WF_ROUTING_RULES
   where RULE_ID = ruleid;

  -- Not a valid option when msg_type or msg_name is null
  if ((msg_type is not null) and (msg_name is not null)) then

    if (rulerec.action = 'RESPOND') then
      htp.formRadio(cname=>'action', cvalue=>'RESPOND', cchecked=>'1',
          cattributes=>'id="i_wfitd_msg_respond"');
    else
      htp.formRadio(cname=>'action', cvalue=>'RESPOND',
          cattributes=>'id="i_wfrtg_close"');
    end if;
    -- Check existing of response
    select count(WMA.NAME) into rowcount
    from WF_ROUTING_RULES WRR,
         WF_MESSAGE_ATTRIBUTES_VL WMA,
         WF_ITEM_ATTRIBUTES WIA
    where WRR.RULE_ID = nruleid
    and WRR.MESSAGE_TYPE = WMA.MESSAGE_TYPE
    and WRR.MESSAGE_NAME = WMA.MESSAGE_NAME
    and WMA.SUBTYPE = 'RESPOND'
    and WMA.TYPE not in ('FORM', 'URL')
    and WMA.MESSAGE_TYPE = WIA.ITEM_TYPE (+)
    and WMA.TEXT_DEFAULT = WIA.NAME (+)
    order by decode(WMA.NAME, 'RESULT', 9999, WMA.SEQUENCE);
    --
    -- If there is no message attributes, there is no response and we give
    -- a choice of 'close', otherwise 'respond'.
    --
    if (rowcount = 0) then
      htp.p('<LABEL FOR="i_wfrtg_close">' ||
         wf_core.translate('WFRTG_CLOSE') || '</LABEL>');
    else
      htp.p('<LABEL FOR="i_wfitd_msg_respond">' ||
         wf_core.translate('WFITD_MSG_SOURCE_TYPE_RESPOND') || '</LABEL>');
      -- Draw attr fields
      htp.tableOpen(cattributes=>'summary=""');
-- LOOP
      for attr in attrcurs loop
        respcnt := respcnt + 1;
        htp.tableRowOpen;
        -- Indentation
   htp.p('<TD ID="' || wf_core.translate('WFITD_MSG_SOURCE_TYPE_RESPOND') || '">
             '||'&'||'nbsp &'||'nbsp &'||'nbsp</TD>');

        -- Prompt
        htp.tableData(cvalue=>'<LABEL FOR="i_attr'|| respcnt ||'">' ||
                      attr.display_name || '</LABEL>',
                      calign=>'right',
                      cattributes=>'id=""');

        -- Attr field
        if (GetAttrValue(nruleid, attr.name, tvalue, nvalue, dvalue)) then
          -- If attribute already defined for this rule,
          -- use current value.
          attr.text_value := tvalue;
          attr.number_value := nvalue;
          attr.date_value := dvalue;
        end if;

        dispvalue := GetDisplayValue(attr.type, attr.format, attr.text_value,
                  attr.number_value, attr.date_value);

        if (attr.type = 'LOOKUP') then
          GetLookup(attr.name, attr.text_value, attr.format, FALSE,
               to_char(respcnt));
        elsif (attr.type = 'ROLE') then
          GetRole(attr.name, attr.text_value, to_char(respcnt) );
        elsif (attr.type = 'DOCUMENT') then
          GetDocument(attr.name, attr.format, dispvalue, to_char(respcnt) );
        else
          GetField(attr.name, attr.type, attr.format, dispvalue,
                   to_char(respcnt));
        end if;
        htp.tableRowClose;
      end loop;
-- END LOOP
      htp.tableClose;
    end if;
    htp.br;
  end if;
  -- Add counter
  htp.formHidden('h_counter', to_char(respcnt+1), null);

  -- Not a valid option when both msg_type and msg_name are null
  if ((msg_type is not null) or (msg_name is not null)) then
    if (rulerec.action = 'NOOP') then
      htp.formRadio(cname=>'action', cvalue=>'NOOP', cchecked=>'1',
          cattributes=>'id="i_deliver"');
    else
      htp.formRadio(cname=>'action', cvalue=>'NOOP',
          cattributes=>'id="i_deliver"');
    end if;
    htp.p('<LABEL FOR="i_deliver">' ||
         wf_core.translate('WFRTG_DELIVER') ||
         '</LABEL>');
    htp.br;
  end if;
  -- NOTE: Do NOT create any more fields for h_names or h_values here.  The
  -- submit buttons created above must be the last values for these fields
  -- to work around an MSIE bug that always sends the submit button last.
  htp.formClose;


    -- Add submit button
  htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.CREATE_RULE.submit()',
                              wf_core.translate ('WFMON_DONE'),
                              wfa_html.image_loc,
                              'FNDJLFOK.gif',
                              wf_core.translate ('WFMON_DONE'));

  htp.p('</TD>');

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:window.history.back()',
                              wf_core.translate ('CANCEL'),
                              wfa_html.image_loc,
                              'FNDJLFCN.gif',
                              wf_core.translate ('CANCEL'));

  htp.p('</TD>');


  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.footer;
  htp.htmlClose;

exception
  when others then
    if (rulecurs%isopen) then
      close rulecurs;
    end if;
    wf_core.context('Wf_Route', 'UpdateRule', ruleid);
    wf_route.error;
end UpdateRule;

--
-- SubmitCreate
--   Process CreateRule request
-- IN
--   user - role owning rule
--   msg_type - message type
--   msg_name - message name
--   begin_date - Start date
--   end_date - End date
--   action - action
--   fmode  - forward mode: 'FORWARD', 'TRANSFER'
--   action_argument - reassign to if forward
--   h_fnames - Name array
--   h_fvalues - Value array
--   h_fdocnames - array of document name values
--   h_counter - count of array element
--   rule_comment - comments included in notification
--   delete_button - cancel operation flag
--   done_button - done button flag
--
procedure SubmitCreate(
  user in varchar2,
  msg_type in varchar2,
  msg_name in varchar2,
  begin_date in varchar2 ,
  end_date in varchar2 ,
  action in varchar2,
  fmode  in varchar2 ,
  action_argument in varchar2 ,
  display_action_argument in varchar2 ,
  h_fnames in Name_Array,
  h_fvalues in Value_Array,
  h_fdocnames in Value_Array,
  h_counter in varchar2,
  rule_comment in varchar2 ,
--  insert_button in varchar2 default null)
  delete_button in varchar2 ,
  done_button in varchar2 )
is
  owner varchar2(320);
  realname varchar2(360);
  s0 varchar2(2000);
  l_msg_type varchar2(8) := REPLACE(msg_type, '^', ' ');
  l_msg_name varchar2(30) := REPLACE(msg_name, '^', ' ');
  typebuf varchar2(8);
  namebuf varchar2(30);
  ruleid number;
  begdate date;
  enddate date;
  forwardee varchar2(320);
  l_action varchar2(30) := action;

begin
  -- Validate access
  owner := Wf_Route.Authenticate(user);
  wf_directory.GetRoleInfo(owner, realname, s0, s0, s0, s0);

  -- Check if delete

  if (delete_button is not null) then
    --
    -- Raise DELETE so that it won't create a record
    --
    Wf_Route.List(user, '--EDITSCREEN--');
    return;
  end if;

  if (done_button is not null) then
    -- Validate msg_type
    if (l_msg_type = '*') then
      -- Change '*' for default back to null
      typebuf := '';
    else
      -- All others must by valid via poplist
      typebuf := l_msg_type;
    end if;

    -- Validate msg_name
    if (l_msg_name = '*') then
      -- Change '*' for default back to null
      namebuf := '';
    else
      -- All others must by valid via poplist
      namebuf := l_msg_name;
    end if;

    -- Get dates
    begdate := StringToDate(begin_date);
    enddate := StringToDate(end_date);

    -- Validate date range
    if (enddate <= begdate) then
      wf_core.raise('WFRTG_BAD_DATE_RANGE');
    end if;

    -- Validate action
    -- Only rule is RESPOND must have both msg_type and msg_name specified
    if (action = 'RESPOND') then
      if ((typebuf is null) or (namebuf is null)) then
        wf_core.raise('WFRTG_RESPOND_MESSAGE');
      end if;
    end if;

    -- Validate action_argument
    if (action = 'FORWARD') then
      forwardee := action_argument;
      wfa_html.validate_display_name (display_action_argument, forwardee);
      l_action := fmode;
    end if;

    -- Select new ruleid
    select WF_ROUTING_RULES_S.NEXTVAL
    into ruleid
    from SYS.DUAL;

    -- Insert new rule in table with data so far
    insert into WF_ROUTING_RULES (
      RULE_ID,
      ROLE,
      ACTION,
      BEGIN_DATE,
      END_DATE,
      MESSAGE_TYPE,
      MESSAGE_NAME,
      ACTION_ARGUMENT,
      RULE_COMMENT
    ) values (
      ruleid,
      SubmitCreate.owner,
      SubmitCreate.l_action,
      begdate,
      enddate,
      SubmitCreate.typebuf,
      SubmitCreate.namebuf,
      SubmitCreate.forwardee,
      SubmitCreate.rule_comment
    );

    -- Go directly to update to finish entering data
    -- Wf_route.UpdateRule(to_char(ruleid));
    --
    -- Update routing attributes if RESPOND
    --
    if (SubmitCreate.action = 'RESPOND') then
      -- Start at 2 to step over the Dummy_Name/Dummy_Value pair added at
      -- the start of the array.
      for i in 2 .. to_number(SubmitCreate.h_counter) loop
        SetAttribute(ruleid, SubmitCreate.h_fnames(i),
                     SubmitCreate.h_fvalues(i), SubmitCreate.h_fdocnames(i));
      end loop;
    end if;
  end if;

  -- Go back to the List page
  owa_util.redirect_url(curl=>wfa_html.base_url || '/wf_route.list?user='||user||'&display_user=--EDITSCREEN--',
                         bclose_header=>TRUE);



exception
  when others then
    rollback;
    wf_core.context('Wf_Route', 'SubmitCreate', msg_type, msg_name,
                    begin_date, end_date, action);
    wf_route.error;
end SubmitCreate;


--
-- CreateRule
--   Create a new routing rule
--   Part 1, choose msg_type
-- IN
--   user - User to query rules for.  If null use current user.
--          Nore: only WF_ADMIN_ROLE can create rules for other users
--   create_button - create button flag
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--             - Added ID attr for TD tags
--
procedure CreateRule(
  user in varchar2 ,
  create_button in varchar2 )
is
begin
   Null;
end CreateRule;

--
-- CreateRule2
--   Create a new routing rule
--   Part 2.  Choose msg_name/ subject
-- IN
--   user - User to query rules for.  If null use current user.
--          Nore: only WF_ADMIN_ROLE can create rules for other users
--   msg_type - message type
--   insert_button - continue to create the record
--   cancel_button - cancel button flag
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--             - Added ID attr for TD tags
--
procedure CreateRule2(
  user in varchar2 ,
  msg_type in varchar2 ,
  insert_button in varchar2 ,
  cancel_button in varchar2 )
is
begin
   NULL;
end CreateRule2;

--
-- CreateRule3
--   Create a new routing rule
--   Part 3. Specify the start and end date
--           Select action and put in comments.
-- IN
--   user - User to query rules for.  If null use current user.
--          Nore: only WF_ADMIN_ROLE can create rules for other users
--   msg_type - message type
--   msg_name - message name
--   insert_button - continue to create the record
--   cancel_button - cancel button flag
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--             - Added ID attr for TD tags
--
procedure CreateRule3(
  user in varchar2 ,
  msg_type in varchar2 ,
  msg_name in varchar2 ,
  insert_button in varchar2 ,
  cancel_button in varchar2 )
is
begin
   NULL;
end CreateRule3;


--
-- List
--   Produce list of routing rules for user
-- IN
--   user - User to query rules for.  If null use current user.
--          Note: only WF_ADMIN_ROLE can query other than the current user.
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--                     - added alt attr for img tags
--                     - added ID attr for TD tags
--                     - added ID attr for TH tags
--                     - added label for form input & select fields
--
procedure List (
  user in varchar2 ,
  display_user in varchar2
)
is
  username varchar2(320);   -- Username to query
  t_user   varchar2(320);
  admin_role varchar2(320); -- Role for admin mode
  realname varchar2(360);   -- Display name of username
  isactive number;         -- Active?
  l_media              varchar2(240) := wfa_html.image_loc;
  l_icon               varchar2(30) := 'FNDILOV.gif';
  l_text               varchar2(30) := '';
  l_onmouseover        varchar2(240) := wf_core.translate ('WFPREF_LOV');
  l_url                varchar2(4000);
  today    date;           -- Today's date
  s0 varchar2(2000);       -- Dummy

  forwardname varchar2(360); -- Display name of forwardee

  cursor wf_rules_cursor is
    select WRR.MESSAGE_TYPE,
           WRR.MESSAGE_NAME,
           WRR.BEGIN_DATE,
           WRR.END_DATE,
           WRR.ACTION,
           WRR.ACTION_ARGUMENT,
           WRR.RULE_ID,
           WIT.DISPLAY_NAME TYPE_DISPLAY,
           WM.DISPLAY_NAME MSG_DISPLAY,
           WM.SUBJECT,
           WL.MEANING ACTION_DISPLAY
    from WF_ROUTING_RULES WRR, WF_ITEM_TYPES_VL WIT, WF_MESSAGES_VL WM,
         WF_LOOKUPS WL
    where WRR.ROLE = username
    and WRR.MESSAGE_TYPE = WIT.NAME (+)
    and WRR.MESSAGE_TYPE = WM.TYPE (+)
    and WRR.MESSAGE_NAME = WM.NAME (+)
    and WRR.ACTION = WL.LOOKUP_CODE
    and WL.LOOKUP_TYPE = 'WFSTD_ROUTING_ACTIONS'
    order by TYPE_DISPLAY, MSG_DISPLAY, BEGIN_DATE;

  rowcount number;
  att_tvalue varchar2(2000) ;
begin

  -- Get all the username find criteria resolved
  t_user := user;

  -- This function is also called by the edit confirmation page and only
  -- pass the user name and never the display name.  The search criteria
  -- should not be null so this is a safe check and will use the user name
  -- in cases where the display name is not passed in.
  if (NVL(display_user, '--BLANK--') <> '--EDITSCREEN--') then

     wfa_html.validate_display_name (display_user, t_user);

  end if;

  -- Check current user has access to this user
  username := Wf_Route.Authenticate(upper(t_user));
  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);


  -- Set today's date
  select sysdate into today from sys.dual;

  -- Set page title
  htp.htmlOpen;
--  DEBUG info
--  htp.p('<P>t_user='||t_user||' username='||username||'<br> realname='||realname||'</P>');
--

  IF (realname IS NULL) THEN

      htp.p('<BODY bgcolor=#cccccc>');
      htp.center(htf.bold(wf_core.translate('WFPREF_INVALID_ROLE_NAME'))||':'||display_user);
      htp.br;

      htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');

      --Submit Button

      htp.tableRowOpen;

      l_url         := wfa_html.base_url||
                     '/wf_route.find';
      l_icon        := 'FNDJLFOK.gif';
      l_text        := wf_core.translate ('WFMON_OK');
      l_onmouseover := wf_core.translate ('WFMON_OK');

      htp.p('<TD ID="">');

      wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

      htp.p('</TD>');
      htp.tablerowclose;
      htp.tableclose;
      htp.p('</BODY>');
      return;

  END IF;

  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('WFRTG_LIST_TITLE')||' - '||realname);
  wfa_html.create_help_function('wf/links/nrr.htm?NRR');
  htp.headClose;
  wfa_sec.header(FALSE, 'wf_route.find', wf_core.translate('WFRTG_FIND_TITLE'), TRUE);

  -- Column headers
  htp.tableOpen(calign=>'CENTER', cattributes=>'border=1 cellpadding=3 bgcolor=white width="100%" summary="' || wf_core.translate('WFRTG_FIND_TITLE') || '"');
--  htp.tableRowOpen(cattributes=>'bgcolor=#83c1c1');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');

--  htp.tableData(cvalue=>'<font color=#000000>'||
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('MESSAGE_TYPE')||'</font>',
                  calign=>'Center',
      cattributes=>'id="' || wf_core.translate('MESSAGE_TYPE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('NOTIFICATION')||'</font>',
                  calign=>'Center',
      cattributes=>'id="' || wf_core.translate('NOTIFICATION') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('RESULT_APPLY_RULE')||'</font>',
                  calign=>'Center',
      cattributes=>'id="' || wf_core.translate('RESULT_APPLY_RULE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('ACTIVE')||'</font>',
                  calign=>'Center',
      cattributes=>'id="' || wf_core.translate('ACTIVE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                  wf_core.translate('WFRTG_DELETE')||'</font>',
                  calign=>'Center',
      cattributes=>'id="' || wf_core.translate('WFRTG_DELETE') || '"');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Query matching rules
  for rule in wf_rules_cursor loop
    isactive := 0;
    if today > rule.begin_date and today < rule.end_date then
        isactive := 1;
    else
        if rule.begin_date is null and today < rule.end_date then
           isactive := 1;
        else
           if rule.end_date is null and today > rule.begin_date then
             isactive := 1;
           else
             if ((rule.end_date is null) and (rule.begin_date is null)) then
               isactive := 1;
             end if;
           end if;
        end if;
    end if;

    htp.tableRowOpen(null, 'TOP');
    htp.tableData(nvl(rule.type_display,
                      htf.em(wf_core.translate('<ALL>'))),
                  'left',cattributes=>'id=""');

    IF (rule.subject IS NULL) THEN

       htp.tableData(htf.em(wf_core.translate('<ALL>')),
                  'left', cattributes=>'id=""');

    ELSE

       htp.tableData(wf_notification.GetSubSubjectDisplay(rule.message_type,
                            rule.message_name),
                  'left', cattributes=>'id=""');

    END IF;


    if ( rule.action = 'FORWARD' ) then
       -- get the display name of the forwardee in delegation
       wf_directory.GetRoleInfo(rule.action_argument, forwardname,
                                s0, s0, s0, s0);
       htp.tableData(htf.anchor(wfa_html.base_url||
                                '/Wf_Route.UpdateRule?ruleid='||
                                to_char(rule.rule_id),
                                wf_core.translate('DELEGATE')||':'||
                                forwardname),
                     'left',cattributes=>'id=""');
    elsif ( rule.action = 'TRANSFER' ) then
       -- get the display name of the forwardee in transfering
       wf_directory.GetRoleInfo(rule.action_argument, forwardname,
                                s0, s0, s0, s0);
       htp.tableData(htf.anchor(wfa_html.base_url||
                                '/Wf_Route.UpdateRule?ruleid='||
                                to_char(rule.rule_id),
                                wf_core.translate('TRANSFER')||':'||
                                forwardname),
                     'left',cattributes=>'id=""');
    else
      if ( rule.action = 'NOOP' ) then
       htp.tableData(htf.anchor(wfa_html.base_url||
                                '/Wf_Route.UpdateRule?ruleid='||
                                to_char(rule.rule_id),
                                wf_core.translate('WFRTG_DELIVERTOME')),
                     'left',cattributes=>'id=""');
      else

       -- Check existing of response
       select count(WMA.NAME)
       into rowcount
       from WF_ROUTING_RULES WRR,
            WF_MESSAGE_ATTRIBUTES_VL WMA,
            WF_ITEM_ATTRIBUTES WIA
       where WRR.RULE_ID = rule.rule_id
       and WRR.MESSAGE_TYPE = WMA.MESSAGE_TYPE
       and WRR.MESSAGE_NAME = WMA.MESSAGE_NAME
       and WMA.SUBTYPE = 'RESPOND'
       and WMA.TYPE not in ('FORM', 'URL')
       and WMA.MESSAGE_TYPE = WIA.ITEM_TYPE (+)
       and WMA.TEXT_DEFAULT = WIA.NAME (+)
       order by decode(WMA.NAME, 'RESULT', 9999, WMA.SEQUENCE);

       -- Check RESULT value
       begin
/* ### we should display the meaning instead of the underlying value.

         select TEXT_VALUE
         into att_tvalue
         from WF_ROUTING_RULE_ATTRIBUTES
         where RULE_ID = rule.rule_id
         and   NAME = 'RESULT';
*/
         select WL.MEANING
         into att_tvalue
         from WF_LOOKUPS WL,
              WF_MESSAGE_ATTRIBUTES_VL WMA,
              WF_ROUTING_RULES WRR,
              WF_ROUTING_RULE_ATTRIBUTES WRA
         where WRA.RULE_ID = rule.rule_id
         and   WRA.NAME = 'RESULT'
         and   WRR.RULE_ID = WRA.RULE_ID
         and   WMA.NAME = WRA.NAME
         and   WRR.MESSAGE_TYPE = WMA.MESSAGE_TYPE
         and   WRR.MESSAGE_NAME = WMA.MESSAGE_NAME
         and   WL.LOOKUP_TYPE = WMA.FORMAT
         and   WL.LOOKUP_CODE = WRA.TEXT_VALUE;
       exception
         when no_data_found then
           att_tvalue := '';
       end;

       --
       -- If there is no message attributes, there is no response and we give
       -- a choice of 'close', otherwise 'response'.
       --
       if (rowcount = 0) then
         htp.tableData(htf.anchor(wfa_html.base_url||
                                  '/Wf_Route.UpdateRule?ruleid='||
                                  to_char(rule.rule_id),
                                  wf_core.translate('WFRTG_CLOSE')),
                       'left',cattributes=>'id="' ||
           wf_core.translate('WFRTG_CLOSE') || '"');
       else
         if (att_tvalue is not null) then
           htp.tableData(htf.anchor(wfa_html.base_url||
                                    '/Wf_Route.UpdateRule?ruleid='||
                                    to_char(rule.rule_id),
                  wf_core.translate('WFITD_MSG_SOURCE_TYPE_RESPOND')||':'
                                    ||att_tvalue),
                  'left',cattributes=>'id="' || wf_core.translate('WFITD_MSG_SOURCE_TYPE_RESPOND') || '"');
         else
           htp.tableData(htf.anchor(wfa_html.base_url||
                                    '/Wf_Route.UpdateRule?ruleid='||
                                    to_char(rule.rule_id),
                  wf_core.translate('WFITD_MSG_SOURCE_TYPE_RESPOND')),
                         'left',cattributes=>'id="' || wf_core.translate('WFITD_MSG_SOURCE_TYPE_RESPOND') || '"');
         end if;
       end if;
      end if;
    end if;

    if isactive = 1 then
        htp.tableData(htf.img(wfa_html.image_loc||'FNDICHEK.gif',
                              'Center', wf_core.translate('ACTIVE')), 'center',
                              cattributes=>'valign="MIDDLE" id=""');
    else
        htp.tableData(htf.br,cattributes=>'id=""');
    end if;

--    htp.tableData(nvl(to_char(rule.begin_date)||
--                      to_char(rule.begin_date, ' HH24:MI:SS'),
--                  htf.br), 'left',cattributes=>'id=""');

    htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/Wf_Route.DeleteRule?user='||username||
                                  '&'||'ruleid='||to_char(rule.rule_id),
 ctext=>'<IMG SRC="'||wfa_html.image_loc||'FNDIDELR.gif"
              alt="' || wf_core.translate('WFRTG_DELETE') || '" BORDER=0>'),
                       'center', cattributes=>'valign="MIDDLE" id=""');
    htp.tableRowClose;
  end loop;

  htp.tableClose;


  -- Button to create new rule
  htp.formOpen(curl=>'wf_route.CreateRule',
               cmethod=>'POST', cattributes=>'NAME="WF_LIST"');

  htp.formHidden('user', username);

  htp.formClose;

  -- Add submit button
  htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.WF_LIST.submit()',
                              wf_core.translate('WFRTG_INSERT'),
                              wfa_html.image_loc,
                              'FNDJLFOK.gif',
                              wf_core.translate('WFRTG_INSERT'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;


  -- Close up shop
--  wfa_sec.Footer;
  htp.htmlClose;
exception
  when others then
    wf_core.context('Wf_Route', 'List', user, display_user);
    wf_route.error;
end List;


--
-- Find
--  Find routing rules for given user
--  Note: only WF_ADMIN_ROLE can query other than the current user.
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 - Added summary attr for table tag for ADA
--             - Added ID attr for TD tags
--
procedure Find
is
  curuser varchar2(320);
  admin_role varchar2(320);
  realname   varchar2(360);
  l_url         varchar2(1000);
  l_media       varchar2(240) := wfa_html.image_loc;
  l_icon        varchar2(30) := 'FNDILOV.gif';
  s0 varchar2(2000);
  l_onmouseover varchar2(240) := wfa_html.replace_onMouseOver_quotes(wf_core.translate('WFA_FIND_USER'));
  l_message     varchar2(240)   := wfa_html.replace_onMouseOver_quotes(wf_core.translate ('WFPREF_LOV'));

begin
  -- Check if current user has admin role
  Wfa_Sec.GetSession(curuser);
  wf_directory.GetRoleInfo(curuser, realname, s0, s0, s0, s0);
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role <> '*' and
      not Wf_Directory.IsPerformer(curuser, admin_role)) then
    -- If current user does not have admin,
    -- go directly to rules list for current user.
    Wf_Route.List(curuser, '--EDITSCREEN--');
--    Wf_Route.ListFrame;
    return;
  end if;

  -- Admin approved, draw the form
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFRTG_FIND_TITLE'));
  wfa_html.create_help_function('wf/links/rul.htm?RULES');
  fnd_document_management.get_open_dm_display_window;
  htp.headClose;
  wfa_sec.header(FALSE, '', wf_core.translate('WFRTG_FIND_TITLE'), TRUE);

  htp.formOpen(curl=>'wf_route.list',
               cmethod=>'POST', cattributes=>'NAME="WF_FIND"');

  htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 cellpadding=2 cellspacing=0 summary=""');

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_display_user">' ||
           wf_core.translate('USER_ID') || '</LABEL>', calign=>'right',
           cattributes=>'id=""');
  htp.formHidden('user', curuser);

  -- add LOV here: Note:bottom is name of frame.
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
            REPLACE('wf_lov.display_lov?p_lov_name='||'owner'||
            '&p_display_name='||'WFA_FIND_USER'||
            '&p_validation_callback=wfa_html.wf_user_val'||
            '&p_dest_hidden_field=top.opener.parent.document.WF_FIND.user.value'||
            '&p_current_value=top.opener.parent.document.WF_FIND.display_user.value'||
            '&p_display_key='||'Y'||
            '&p_dest_display_field=top.opener.parent.document.WF_FIND.display_user.value',
             ' ', '%20')||''''||',500,500)';

    -- print everything together so ther is no gap.
    htp.tabledata(htf.formText(cname=>'display_user', csize=>30,
                       cmaxlength=>360,
                       cvalue=>realname,
                       cattributes=>'id="i_display_user"')||
               '<A href='||l_url||'>'||
               '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                    l_message||'" onmouseover="window.status='||''''||
                    l_message||''''||';return true"></A>',
                    cattributes=>'id=""');

  htp.tableRowClose;
  htp.tableClose;
  htp.formClose;

  -- Add submit button
  htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');
  htp.tableRowOpen;

  htp.p('<TD ID="">');

  wfa_html.create_reg_button ('javascript:document.WF_FIND.submit()',
                              wf_core.translate ('FIND'),
                              wfa_html.image_loc,
                              'fndfind.gif',
                              wf_core.translate ('FIND'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;

  wfa_sec.Footer;
  htp.htmlClose;
exception
  when others then
    wf_core.context('Wf_Route', 'Find', user);
    wf_route.error;
end Find;

--
-- ChangeMessageName
--  Changes the message name on any defined rule(s).
--
procedure ChangeMessageName (p_itemType in varchar2,
                             p_oldMessageName in varchar2,
                             p_newMessageName in varchar2) is
begin
  update WF_ROUTING_RULES
     set MESSAGE_NAME = upper(p_newMessageName)
   where MESSAGE_TYPE = p_itemType
     and MESSAGE_NAME = p_oldMessageName;
end;

END WF_ROUTE;

/
