--------------------------------------------------------
--  DDL for Package Body WF_INITIATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_INITIATE" as
/* $Header: wfinitb.pls 120.3 2005/10/04 05:16:53 rtodi ship $ */

---
procedure Print_Error
is
  error_name	varchar2(30);
  error_message	varchar2(2000);
  error_stack	varchar2(32000);
begin
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('ERROR'));
  htp.headClose;
  wfa_sec.header(background_only=>TRUE);

  htp.header(1, wf_core.translate('ERROR'));
  htp.br;
  --
  wf_core.get_error(error_name, error_message, error_stack);
  if (error_name is not null) then
	htp.p(error_message);
  elsif (sqlcode <> 0) then
	htp.p(sqlerrm);
  end if;

  htp.br;
  if (error_stack is not null) then
	htp.p(wf_core.translate('WFMON_ERROR_STACK'));
	htp.p(replace(error_stack,wf_core.newline,'<br>') || '<br>');
  end if;
  --
  htp.bodyClose;
  htp.htmlClose;
  --
end Print_Error;

--
-- GetLookup (PRIVATE)
--   Produce a lookup response field
-- IN
--   name - field name
--   value - default value (lookup code)
--   format - lookup type
--
procedure GetLookup(
  name in varchar2,
  value in varchar2,
  format in varchar2,
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
                  htf.formSelectOption(cvalue=>i.meaning,
                                       cattributes=>'value='||i.lookup_code,
			               cselected=>'SELECTED');
    else
      template := template||wf_core.newline||
                  htf.formSelectOption(cvalue=>i.meaning,
                                       cattributes=>'value='||i.lookup_code);
    end if;
  end loop;
  template := template||wf_core.newline||htf.formSelectClose;
  htp.tableData(template, 'left',cattributes=>'id=""');
exception
  when others then
    wf_core.context('Wf_initiate', 'GetLookup', name, value, format);
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
        'WF_INITIATE',
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
    wf_core.context('Wf_Initiate', 'GetDocument', name, format, dvalue);
    raise;
end GetDocument;

--
-- GetField (PRIVATE)
-- Produce a text response field
procedure GetField(
  name         in varchar2,
  type         in varchar2,
  format       in varchar2,
  dvalue       in varchar2,
  index_num    in varchar2)
is
  len      pls_integer;
begin
  -- Figure field len
  if (type = 'VARCHAR2') then
    len := nvl(to_number(format), 4000);
  elsif (type = 'DATE') then
    len := nvl(to_number(length(format)),40);
  else
    len := 40;
  end if;

  -- Draw field
  htp.formHidden('h_fnames', name||'#'||type||'#'||format);
  -- always print the display field as null
  htp.formHidden('h_fdocnames', '');
--
-- commented out multi-line field for text
--
--  if (len <= 80) then
    -- single line field
    htp.tableData(
        cvalue=>htf.formText(cname=>'h_fvalues', csize=>40,
                             cmaxlength=>len,
                    cvalue=>replace(dvalue,'&','&amp'),
          cattributes=>'id="i_attr'||index_num||'"'),
        calign=>'Left',
        cattributes=>'id=""');
--  else
       -- multi line field
--        htp.tableData(
--         	    cvalue=>htf.formTextareaOpen2(
--                            cname=>'h_fvalues',
--                            nrows=>2,
--                            ncolumns=>40,
--                            cwrap=>'SOFT',
--                            cattributes=>'maxlength='||to_char(len))||
--                            dvalue||
--                            htf.formTextareaClose,
--                   calign=>'Left',
--                   cattributes=>'id=""');
--     end if;
exception
  when others then
    wf_core.context('Wf_Initiate', 'GetField', name, type, format, dvalue,
      index_num);
    raise;
end GetField;
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

-- variable for LOV
  l_url    varchar2(1000);
  l_media  varchar2(240) := wfa_html.image_loc;
  l_icon   varchar2(30)  := 'FNDILOV.gif';
  l_text   varchar2(30) := '';
  l_message varchar2(240) := null;

--
begin
  -- Draw field
  htp.formHidden('h_fnames', name||'#ROLE#');
  -- always print the display field as null
  htp.formHidden('h_fvalues', null);

  -- add LOV here: Note:bottom is name of frame.
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
            REPLACE('wf_lov.display_lov?p_lov_name='||'owner'||
            '&p_display_name='||'WFA_FIND_USER'||
            '&p_validation_callback=wfa_html.wf_user_val'||
            '&p_dest_hidden_field=top.opener.parent.document.WF_INITIATE.h_fvalues['||seq||'].value'||
            '&p_current_value=top.opener.parent.document.WF_INITIATE.h_fdocnames['||seq||'].value'||
            '&p_display_key='||'Y'||
            '&p_dest_display_field=top.opener.parent.document.WF_INITIATE.h_fdocnames['||seq||'].value',
             ' ', '%20')||''''||',500,500)';

  l_message := wf_core.translate ('WFPREF_LOV');

  -- print everything together so ther is no gap.
  htp.tabledata(htf.formText(cname=>'h_fdocnames',
                csize=>30,
                cmaxlength=>240,
                cvalue=>dvalue,
                cattributes=>'id="i_attr'||seq||'"')||
               '<A href='||l_url||'>'||
               '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
                    l_message||'" onmouseover="window.status='||''''||
                    l_message||''''||';return true"></A>',
                  cattributes=>'id=""');

exception
  when others then
    wf_core.context('Wf_initiate', 'GetRole', name, seq);
    raise;
end GetRole;


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
  cursor lov_lookup is
  select WL.MEANING
  from WF_LOOKUPS WL
  where WL.LOOKUP_TYPE = GetLookupMeaning.ltype
  and WL.LOOKUP_CODE = GetLookupMeaning.lcode;

begin
  open lov_lookup;
  fetch lov_lookup into meaning;
  close lov_lookup;

  if meaning is null then
     meaning :=lcode;
  end if;

  return(meaning);
exception
  when others then
    wf_core.context('Wf_initiate', 'GetLookupMeaning', ltype, lcode);
    raise;
end GetLookupMeaning;


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
    if (format is null) then
      value := to_char(dvalue);
    else
      value := to_char(dvalue, format);
    end if;
  elsif (type = 'LOOKUP') then
    value := GetLookupMeaning(format, tvalue);
  elsif (type = 'URL') then
    value := tvalue;
  else
    -- Default to return text value unchanged
    value := tvalue;
  end if;

  return(value);

exception
  when others then
    wf_core.context('Wf_initiate', 'GetDisplayValue', type, format,
                    tvalue, to_char(nvalue), to_char(dvalue));
    raise;
end GetDisplayValue;



--
-- ItemType
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 -Added summary attr for table tag for ADA
--
procedure ItemType as

  username	varchar2(320);
  admin_role    varchar2(320);  -- Role for admin mode
  admin_mode    varchar2(1);    -- Does user have admin privledges
  l_error_msg varchar2(2000) := null;

  cursor itemtypes is
  select name, display_name, nvl(description,'&nbsp;') description
  from   wf_item_types_vl
  where  name not in ('WFSTD','WFERROR','WFMAIL')
  order by name;
begin
  --
  -- Authenticate user
  wfa_sec.GetSession(username);
  username := upper(username);
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
         Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else
     l_error_msg := wf_core.translate('WFINIT_INVALID_ADMIN');
  end if;
  --
  -- Header and Page Title
  --
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFINIT_ITEM_TYPE_TITLE'));
  wfa_html.create_help_function('wf/links/tes.htm?TESTING');
  htp.headClose;
  wfa_sec.header(page_title=>wf_core.translate('WFINIT_ITEM_TYPE_TITLE'));
  --
  if (l_error_msg IS NOT NULL) THEN
     htp.center(htf.bold(l_error_msg));
     return;
  end if;
  --
  htp.tableOpen(cattributes=>'border=1 cellpadding=1 cellspacing=3 bgcolor=white align=center summary= "' || wf_core.translate('WFINIT_ITEM_TYPE_TITLE') || '"');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                         wf_core.translate('ITEMTYPE')||'</font>',
                calign=>'center',
                cattributes=>'id="' || wf_core.translate('ITEMTYPE') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                         wf_core.translate('WFITD_INTERNAL_NAME')||'</font>',
                calign=>'center',
                cattributes=>'id="' || wf_core.translate('WFITD_INTERNAL_NAME') || '"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
                         wf_core.translate('DESCRIPTION')||'</font>',
                calign=>'center',
                cattributes=>'id="' || wf_core.translate('DESCRIPTION') || '"');
  htp.tableRowClose;
  --
  --

  for typerec in itemtypes loop
 	htp.tableRowOpen('bgcolor=#ffffcc');

	htp.tableData(cvalue=>htf.anchor(wfa_html.base_url
                              ||'/wf_initiate.Process?ItemType='||wfa_html.conv_special_url_chars(typerec.name),
			      ctext=>typerec.display_name),
                       cattributes=>'headers="' || wf_core.translate('ITEMTYPE') || '"');

	htp.tableData(cvalue=>typerec.name,  calign=>'left',
            cattributes=>'headers="' || wf_core.translate('WFITD_INTERNAL_NAME') || '"');
	htp.tableData(cvalue=>typerec.description, calign=>'left',
           cattributes=>'headers="' || wf_core.translate('DESCRIPTION') || '"');
	htp.tableRowClose;
  end loop;
  --
  --
  htp.tableClose;
  wfa_sec.Footer;
  htp.htmlClose;
exception
  when others then
    if (ItemTypes%isopen) then
      close ItemTypes;  -- Close cursor just in case
    end if;
    rollback;
    wf_core.context('Wf_Initiate', 'ItemType');
    print_error;
end ItemType;


--
-- Process
--   generate response frame contents
--   to gather all required input to launch the workflow
-- IN
--
-- MODIFICATION LOG:
-- 06-JUN-2001 JWSMITH BUG 1819232 -Added ID attr for TD tag for ADA
--             - Added summary attr for table tag for ADA
--
procedure Process(ItemType in varchar2 )
as
  --
  -- Item Attributes Cursor
  --
  cursor ItemAttrs is
  select name, display_name, type, subtype, format,
         text_default, number_default, date_default
  from   wf_item_attributes_vl
  where  item_type = Process.itemtype
  order by sequence;
  --
  -- Runnable Process cursor
  --
  cursor RunnableProcesses is
  select wfrp.process_name, wfrp.display_name
  from   wf_runnable_processes_v wfrp
  where  wfrp.item_type =  Process.itemtype
  order  by wfrp.display_name;
  --
  --
  --
  admin_mode 		varchar2(1);
  admin_role		varchar2(320);
  l_error_msg		varchar2(240);
  username 	 	varchar2(320);
  dvalue 		varchar2(2000);
  respcnt 		pls_integer :=0;
  l_itemTypeDisp 	varchar2(80);

  l_media       	varchar2(240):= wfa_html.image_loc;
  l_icon        	varchar2(30) := 'FNDILOV.gif';
  l_url         	varchar2(1000);
  l_onmouseover         varchar2(240);
  l_message             varchar2(240)   := wf_core.translate ('WFPREF_LOV');
  l_text        	varchar2(30) := '';
--
--
--
begin

  -- Authenticate user
  wfa_sec.GetSession(username);
  username := upper(username);
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
         Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else
     l_error_msg := wf_core.translate('WFINIT_INVALID_ADMIN');
  end if;
  --
  -- Header and Page Title
  --
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFINIT_PROCESS_TITLE'));
  wfa_html.create_help_function('wf/links/ini.htm?INIT_WF');

  -- Add the java script to the header to open the dm window for
  -- any DM function that and any standard LOV
  fnd_document_management.get_open_dm_attach_window;
  fnd_document_management.get_open_dm_display_window;

  htp.headClose;

  wfa_sec.Header(FALSE, '', wf_core.translate('WFINIT_PROCESS_TITLE')||' - '||Process.ItemType);
  htp.br;

  --
  if (l_error_msg IS NOT NULL) THEN
     htp.center(htf.bold(l_error_msg));
     return;
  end if;
  --
  --
  -- Response body content
  --
  --
  --
  select display_name
  into   l_ItemTypeDisp
  from   wf_item_types_vl
  where  name = Process.ItemType;

  --
  -- wf_initiate.SubmitWorkflow is the url(procedure) to which the contents
  -- of this form is sent
  htp.formOpen(curl=>wfa_html.base_url||'/Wf_Initiate.SubmitWorkflow',
               cmethod=>'Post', cattributes=>'NAME="WF_INITIATE"');

  --
  -- Add dummy fields to start both array-type input fields.
  -- These dummy values are needed so that the array parameters to
  -- the submit procedure will not be null even if there are no real
  -- response fields.  This would cause a pl/sql error, because array
  -- parameters can't be defaulted.
  --
  htp.formHidden('h_fnames', 'Dummy_Name');
  htp.formHidden('h_fvalues', 'Dummy_Value');
  htp.formHidden('h_fdocnames', 'Dummy_Display_Name');
  --
  htp.formHidden('itemtype',Process.ItemType);
  --
  --
  -- Item Key
  --
  htp.tableOpen(cattributes=>'border=0 cellpadding=2 cellspacing=0 ALIGN=CENTER summary="' || wf_core.translate('WFINIT_PROCESS_TITLE') || '"');
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_itemkey">' ||
                wf_core.translate('ITEMKEY') || '</LABEL>',  calign=>'right',
       cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'itemkey',csize=>40,
			cmaxlength=>240,
                        cattributes=>'id="i_itemkey"'),
        		calign=>'Left',
                        cattributes=>'id=""');
  htp.tableRowClose;
  --
  -- User Key
  --
  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_user_itemkey">' ||
                        wf_core.translate('USER_ITEMKEY') || '</LABEL>',
                        calign=>'right',
                        cattributes=>'id=""');
  htp.tableData(cvalue=>htf.formText(cname=>'userkey', csize=>40,
			cmaxlength=>240,
                        cattributes=>'id="i_user_itemkey"'),
        		calign=>'Left',
                        cattributes=>'id=""');
  htp.tableRowClose;
  --
  -- Process name
  --
  htp.tableRowOpen('bgcolor=#ffffcc');
  htp.tableData(cvalue=>'<LABEL FOR="i_process_name">' ||
           wf_core.translate('PROCESS_NAME') || '</LABEL>',  calign=>'right',
           cattributes=>'id=""');
  htp.p('<TD ID="">');
  htp.formSelectOpen(cname=>'Process',cattributes=>'id="i_process_name"');

  -- add a null process which will invoke the selector function
  htp.formSelectOption(cvalue=>wf_core.translate('WFA_NULL_PROCESS')
			,cattributes=>'value='||'""');
  for wfp in RunnableProcesses loop
	htp.formSelectOption(cvalue=>wfp.display_name
			,cattributes=>'value='||'"'||wfp.process_name||'"');
  end loop;

  htp.formSelectClose;
  htp.p('</TD>');
  htp.tableRowClose;
  htp.formHidden('owner', null);

  --
  -- Process Owner
  --
  -- add LOV here: Note:bottom is name of frame.
  -- Note: The REPLACE function replaces all the space characters with
  -- the proper escape sequence.
  l_url := 'javascript:fnd_open_dm_display_window('||''''||
            REPLACE('wf_lov.display_lov?p_lov_name='||'owner'||
            '&p_display_name='||'WFA_FIND_USER'||
            '&p_validation_callback=wfa_html.wf_user_val'||
            '&p_dest_hidden_field=top.opener.parent.document.WF_INITIATE.owner.value'||
            '&p_current_value=top.opener.parent.document.WF_INITIATE.display_owner.value'||
            '&p_display_key='||'Y'||
            '&p_dest_display_field=top.opener.parent.document.WF_INITIATE.display_owner.value',
             ' ', '%20')||''''||',500,500)';

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_process_owner">' ||
                wf_core.translate('PROCESS_OWNER') ||
                '</LABEL>',  calign=>'right',
                cattributes=>'id=""');

  -- print everything together so ther is no gap.
  htp.tabledata(htf.formText(cname=>'display_owner', csize=>30,
                 cmaxlength=>240,
                 cvalue=>username,
                 cattributes=>'id="i_process_owner"')||
        '<A href='||l_url||'>'||
        '<IMG src="'||l_media||l_icon||'" border=0 alt="'||
         l_message||'" onmouseover="window.status='||''''||
         l_message||''''||';return true"></A>',
         cattributes=>'id=""');

  htp.tableRowClose;

  for rec in itemattrs loop
    respcnt := respcnt + 1;
    htp.tableRowOpen('bgcolor=#ffffcc');
    htp.tableData(cvalue=>'<LABEL FOR="i_attr'|| respcnt ||'">' ||
                  rec.display_name || '</LABEL>',
                  calign=>'right',
                  cattributes=>'id=""');

    dvalue := GetDisplayValue(rec.type, rec.format, rec.text_default,
	     rec.number_default, rec.date_default);

    if (rec.type = 'LOOKUP') then
       GetLookup(rec.name, rec.text_default, rec.format, to_char(respcnt));
    elsif (rec.type = 'ROLE') then
       wf_initiate.GetRole(rec.name, rec.text_default,
			to_char(respcnt) );
    elsif (rec.type = 'DOCUMENT') then
       GetDocument(rec.name, rec.format, dvalue, to_char(respcnt) );
    else
       GetField(rec.name, rec.type, rec.format, dvalue, to_char(respcnt) );
    end if;
    htp.tableRowClose;
  end loop;

  htp.tableClose;

  htp.formHidden('h_counter', to_char(respcnt+1));

  htp.br;


  --Submit Button

  htp.tableopen(calign=>'CENTER', cattributes=>'summary=""');
  htp.tableRowOpen;

  l_url         := 'javascript:document.WF_INITIATE.submit()';
  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('WFMON_OK');
  l_onmouseover := wf_core.translate ('WFMON_OK');

  htp.p('<TD ID="">');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  l_url         := wfa_html.base_url||'/wf_initiate.itemType';
  l_icon        := 'FNDJLFCN.gif';
  l_text        := wf_core.translate ('CANCEL');
  l_onmouseover := wf_core.translate ('CANCEL');

  htp.p('<TD ID="">');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;


  htp.formClose;
  --
  -- NOTE: Do NOT create any more fields for h_names or h_values here.  The
  -- submit buttons created above must be the last values for these fields
  -- to work around an MSIE bug that always sends the submit button last.
  -- Page footer
  --
  Wfa_Sec.Footer;
  htp.htmlClose;
exception
  when others then
    if (itemattrs%isopen) then
      close itemattrs;  -- Close cursor just in case
    end if;
    rollback;
    wf_core.context('Wf_Initiate', 'Process');
    print_error;
end Process;


--
-- SetAttribute (PRIVATE)
--   Set response attributes when processing a response.
-- IN
--   ItemType		- Item Type
--   ItemKey		- Item Key
--   Attr_Name_Type 	- attribute name#type#format
--   Attr_Value 	- attribute value
--   Attr_Doc_Name 	- attribute display value - usually discarded
--
procedure SetAttribute(
  itemtype       in varchar2,
  itemkey        in varchar2,
  attr_name_type in varchar2,
  attr_value     in varchar2,
  attr_doc_name  in varchar2)
as
  first     pls_integer;
  second    pls_integer;
  attr_type varchar2(8);
  attr_name varchar2(30);
  attr_fmt  varchar2(240);
  --
  badfmt boolean:=FALSE;
  input_too_long boolean:=FALSE;
  l_attr_value varchar2(320);

begin
  -- Parse out name#type#format
  -- It is ok to have # in attribute name as the leading character
  -- It is also possible to have # in format, so the best thing we can do
  -- for now is to look for attr name starting from 2nd character.
  -- Attr name cannot be null.
  first  := instr(attr_name_type, '#', 2);
  second := instr(attr_name_type, '#', 2, 2);
  attr_name := substr(attr_name_type, 1, first-1);
  attr_type := substr(attr_name_type, first+1, second-first-1);
  attr_fmt  := substr(attr_name_type, second+1,
                      length(attr_name_type)-second);
  --
  begin
  if (attr_type = 'DATE') then
    if (attr_fmt is not null) then
      wf_engine.SetItemAttrDate(SetAttribute.itemType,SetAttribute.itemkey,
					attr_name,to_date(attr_value,attr_fmt));
    else
       wf_engine.SetItemAttrDate (SetAttribute.itemType,SetAttribute.itemkey ,
					attr_name,to_date(attr_value,SYS_CONTEXT('USERENV','NLS_DATE_FORMAT')));
    end if;
  elsif (attr_type = 'NUMBER') then
    if (attr_fmt is not null) then
       wf_engine.SetItemAttrNumber(SetAttribute.itemType,SetAttribute.itemkey,  attr_name,
                                    to_number(attr_value, attr_fmt));
    else
     wf_engine.SetItemAttrNumber (SetAttribute.itemType,SetAttribute.itemkey,  attr_name,
                                    to_number(attr_value));
    end if;
  elsif (attr_type = 'VARCHAR2' )
     and (length(attr_value) > nvl(to_number(attr_fmt),length(attr_value))) then
      input_too_long:=true;
  elsif (attr_type = 'ROLE' ) then

      /*
      ** If this is a role then try to get the unique role name for the
      ** user that was selected.  Since this could be a display name
      ** or an internal name, make sure to get the unique internal name
      */
      l_attr_value := attr_value;

      wfa_html.validate_display_name (attr_doc_name, l_attr_value);

      wf_engine.setitemattrtext( SetAttribute.itemType,SetAttribute.itemkey,
					 attr_name, l_attr_value);
  elsif (attr_type = 'DOCUMENT' ) then
     -- if PLSQL then use the display value into which the user typed
     if upper(substr(attr_doc_name,1, 5)) = 'PLSQL' then

      wf_engine.setitemattrtext( SetAttribute.itemType,SetAttribute.itemkey,
					 attr_name, attr_doc_name);
     -- use the hidden field populated by doc lov
     else

      wf_engine.setitemattrtext( SetAttribute.itemType,SetAttribute.itemkey,
					 attr_name, attr_value);
     end if;

  else
    -- Lookup, VARCHAR2 or misc value
      wf_engine.setitemattrtext( SetAttribute.itemType,SetAttribute.itemkey,
					 attr_name, attr_value);
  end if;
  exception
  when others then
    if (wf_core.error_name is null) and (attr_fmt is not null) then
      badfmt := true;
    else
      raise;
    end if;
  end;
  if (badfmt) then
    Wf_Core.Token('FORMAT', attr_fmt);
    Wf_core.Token('VALUE',attr_value);
    Wf_Core.Raise('WFINIT_INVALID_FMT');
  end if;
  if input_too_long then
    Wf_Core.Token('FORMAT', attr_fmt);
    Wf_core.Token('INPUT',substr(attr_value,1,10));
    Wf_core.Token('TRUNC',substr(attr_value,to_number(attr_fmt)+1));
    wf_core.raise('WFINIT_INPUT_TOOLONG');
  end if;

exception
  when others then
        wf_core.context('Wf_initiate', 'SetAttribute',
                        SetAttribute.itemType,SetAttribute.itemkey,
			attr_name_type, attr_value, attr_doc_name);
    raise;
end SetAttribute;


--
-- SubmitWorkflow
--   Submit the workflow
-- IN
procedure SubmitWorkflow(
  itemtype      in varchar2 ,
  itemkey       in varchar2 ,
  userkey       in varchar2 ,
  process       in varchar2 ,
  Owner  	in varchar2 ,
  display_Owner in varchar2 ,
  h_fnames      in Name_Array,
  h_fvalues     in Value_Array,
  h_fdocnames   in Value_Array, -- the display field
  h_counter     in varchar2)
as
  username   varchar2(320);
  t_owner    varchar2(320);
  admin_role varchar2(320);
  admin_mode varchar2(10);
  counter    pls_integer;
  access_key varchar2(2000);
  l_error_msg   VARCHAR2(2000);
begin

  -- Authenticate user
  wfa_sec.GetSession(username);
  username := upper(username);
  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
         Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else
     l_error_msg := wf_core.translate('WFINIT_INVALID_ADMIN');
  end if;

  -- Convert the display name of the owner to a username if necessary
  t_owner := owner;
  wfa_html.validate_display_name (display_owner, t_owner);

  --
  if (l_error_msg IS NOT NULL) THEN
     htp.center(htf.bold(l_error_msg));
     return;
  end if;

  wf_engine.createprocess(itemtype => SubmitWorkflow.itemtype,
			  itemkey  => SubmitWorkflow.itemkey,
			  process  => SubmitWorkflow.process );

  if SubmitWorkflow.UserKey is not null then
    wf_engine.SetItemUserKey(ItemType=> SubmitWorkflow.ItemType,
	  		     ItemKey => SubmitWorkflow.ItemKey,
			     UserKey => SubmitWorkflow.UserKey);
  end if;

  if SubmitWorkflow.t_Owner is not null then
     wf_engine.SetItemOwner (itemtype=>SubmitWorkflow.itemtype,
			     itemkey =>SubmitWorkflow.itemkey,
			     owner   =>upper(SubmitWorkflow.t_Owner) );
  end if;

  --
  -- Set attributes in the reponse array.
  -- Start at 2 to step over the Dummy_Name/Dummy_Value pair added at
  -- the start of the array.
  --
  for counter in 2 .. to_number(h_counter) loop
    SetAttribute(SubmitWorkflow.itemtype, SubmitWorkflow.itemkey,
                 h_fnames(counter), h_fvalues(counter), h_fdocnames(counter));
  end loop;

  -- Submit workflow
  wf_engine.startprocess(SubmitWorkflow.itemtype, SubmitWorkflow.itemkey);


  -- go to the advanced envelope to display all the results.
  -- call it with all options so it displays every activity response.
  owa_util.redirect_url(curl=>wf_monitor.GetAdvancedEnvelopeUrl(
				x_agent      => wfa_html.base_url,
				x_item_type  => SubmitWorkflow.itemtype,
				x_item_key   => SubmitWorkflow.itemkey,
				x_admin_mode => 'YES',
                                x_options    => 'YES'),
        bclose_header=>TRUE);

  --
exception
  when others then
    rollback;
    wf_core.context('Wf_Initiate','SubmitWorkflow',
                    itemtype, itemkey);
    print_error;

end SubmitWorkflow;
--
--
end WF_INITIATE;

/
