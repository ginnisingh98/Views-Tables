--------------------------------------------------------
--  DDL for Package Body ICX_DEFINE_PAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_DEFINE_PAGES" as
/* $Header: ICXCNPAB.pls 120.0 2005/10/07 12:13:47 gjimenez noship $ */


procedure Error
as
  error_name      varchar2(30);
  error_message   varchar2(2000);
  error_stack     varchar2(32000);
begin
    htp.htmlOpen;
    htp.headOpen;
    htp.title(wf_core.translate('ERROR'));
    htp.headClose;

    begin
      wfa_sec.Header(background_only=>TRUE);
    exception
      when others then
        htp.bodyOpen;
    end;

    htp.header(nsize=>1, cheader=>wf_core.translate('ERROR'));
    wf_core.get_error(error_name, error_message, error_stack);

    if (error_name is not null) then
        htp.p(error_message);
    else
        htp.p(sqlerrm);
    end if;

    htp.hr;
    htp.p(wf_core.translate('WFENG_ERRNAME')||':  '||error_name);
    htp.br;
    htp.p(wf_core.translate('WFENG_ERRSTACK')||': '||
          replace(error_stack,wf_core.newline,'<br>'));

    wfa_sec.Footer;
    htp.htmlClose;
end Error;

--  ***********************************************
--	procedure DispPageDialog
--  ***********************************************
procedure DispPageDialog
(p_mode      in varchar2 ,
 p_page_id   in varchar2 ) is

    first_seed      boolean  := TRUE;
    l_page_name     varchar2(80);
    l_title         varchar2(80);
    l_message       varchar2(240) := 'Please select a Page';
    l_dialog        icxui_api_dialog;
    l_button        icxui_api_button;
    l_button2       icxui_api_button;
    l_button_list   icxui_api_button_list;

    l_region        icx_api_region.region_record;
    l_user_id            number;
    l_page_id            varchar2(30);
    username             varchar2(30);
    l_function_syntax    varchar2(2000) := 'javascript:cancelsubmit()';
    l_agent              varchar2(80);
    l_alert              VARCHAR2(120);

cursor wlistcurs is
   select ip.page_id, ipt.page_name, ip.page_type
     from icx_pages ip,
	  icx_pages_tl ipt
    where ip.user_id = l_user_id
      and ipt.language = userenv('LANG')
      and ip.page_id = ipt.page_id
      and ip.page_type in ('USER', 'SEED')
   order by PAGE_TYPE DESC, SEQUENCE_NUMBER;

begin

  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  l_user_id:= icx_sec.getID(icx_sec.PV_WEB_USER_ID);

  l_agent := FND_WEB_CONFIG.WEB_SERVER || icx_plug_utilities.getPLSQLagent;

  if (p_page_id IS NOT NULL) then

      select MAX(page_name)
        into l_page_name
        from icx_pages_tl
       where page_id = p_page_id
         and language = userenv('LANG');

   end if;

    if (p_mode = 'DELETE') then

       l_title := wf_core.translate('ICX_CONFIRMTITLE');

    elsif (p_mode = 'RENAME') then

       l_title := wf_core.translate('RENAME');

    elsif (p_mode = 'COPY') then

       l_title :=  wf_core.translate('COPY');

    else

       l_title :=  wf_core.translate('WFDM_CREATE');

    end if;

    -- HTML Open
    htp.htmlOpen;

    -- HTML Header Open
    htp.headOpen;

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    htp.p('<!-- Comment out script for old browers');

    htp.p('function cancelsubmit() {
		 self.close();
        }');

    htp.p('function selectTo() {
        alert("'||l_message||'");
        }');

    htp.p('function applySubmit() { ');
    IF p_mode IN ('CREATE','RENAME','COPY') THEN

      fnd_message.set_name('FND','FND_MISSING_REQUIRED_VALUE');
      l_alert:= FND_MESSAGE.GET;
      htp.p('  if (document.new_pagename.p_page_name.value==""){
                  alert("'||l_alert||' '||wf_core.translate('NEW_PAGE_NAME')||'");
                  document.new_pagename.p_page_name.value="'||l_page_name||'"
               }else{
                  document.new_pagename.submit();
               }');
    END IF;
   -- htp.p('  document.new_pagename.submit();');
    htp.p('  }' );  -- moved all reload and close logic to the savepage code --mputman bug 1936581

    htp.p ('function applyDelete(url){

          top.opener.parent.location = url;

            // Close the window
            window.close();

          }');

    htp.p('//-->');
    htp.p('</SCRIPT>');

    -- HTML Head Close
    htp.headClose;

    if (p_mode = 'CREATE') then

       l_function_syntax := 'javascript:applySubmit()';

       -- Construct the Button and the Button list
       l_button := icxui_api_button.create_button(
           p_button_name => wf_core.translate('APPLY'),
           p_button_url  => l_function_syntax);

    elsif (p_mode = 'DELETE') then

       l_function_syntax := 'javascript:applyDelete('''||'icx_define_pages.savepage?p_mode=DELETE&p_page_id='||p_page_id||''')';

       -- Construct the Button and the Button list
       l_button := icxui_api_button.create_button(
           p_button_name => wf_core.translate('APPLY'),
           p_button_url  => l_function_syntax);

    elsif (p_mode = 'COPY') then

       l_function_syntax := 'javascript:applySubmit()';

       -- Construct the Button and the Button list
       l_button := icxui_api_button.create_button(
           p_button_name => wf_core.translate('APPLY'),
           p_button_url  => l_function_syntax);

    elsif (p_mode = 'RENAME') then

       l_function_syntax := 'javascript:applySubmit()';

       -- Construct the Button and the Button list
       l_button := icxui_api_button.create_button(
           p_button_name => wf_core.translate('APPLY'),
           p_button_url  => l_function_syntax);

    end if;

    l_button2 := icxui_api_button.create_button(p_button_name => wf_core.translate('CANCEL'),
                                     p_button_url => 'javascript:cancelsubmit()');


    l_button_list := icxui_api_button_list(l_button, l_button2);

    -- Construct the Dialog
    l_dialog   := icxui_api_dialog.create_dialog(
                       p_title          => l_title,
                       p_subheader_text => '&nbsp',
                       p_buttons        => l_button_list);

    -- HTML Body Open
    htp.p('<BODY bgcolor="#CCCCCC">');

    htp.centerOpen;

    -- Form Open
    htp.formOpen(cattributes => 'NAME="new_pagename"',
                 curl        => l_agent || 'icx_define_pages.savePage',
                 cmethod     => 'POST',
                 cenctype    => 'multipart/form-data');  --mputman reodered

    -- Draw the Dialog Title Bar
    l_dialog.open_dialog;

    -- TABLE FOR THE FORM ELEMENTS
    -- htp.tableRowOpen;
    -- wwutl_htp.tableDataOpen;
    htp.tableOpen(cattributes=>'cellspacing="0" cellpadding="0" border="0" width="80%"');

    if (p_mode = 'COPY') then

      htp.p('<tr><td valign=top>'||wf_core.translate('COPY')||'</td>');

      htp.p('<td>');

      htp.p('<select width="200" name="p_page_id" size=10>');

       -- set the pagess that have already been selected
       for rec in wlistcurs loop

           if (rec.page_type = 'SEED' and first_seed = TRUE) then

              htp.formSelectOption(cvalue => wf_core.translate('ICX_PREDEFINED'),
                                   cattributes => 'VALUE="'||to_char(rec.page_id)||'"');

              first_seed := FALSE;

           end if;

           htp.formSelectOption(cvalue => rec.page_name,
                                cattributes => 'VALUE="'||to_char(rec.page_id)||'"');

       end loop;

       htp.formSelectClose;

       htp.p('</td></tr>');

       htp.p('<tr><td>&nbsp</td></tr>');

    end if;

    -- Old Page Name
    if (p_mode IN ('RENAME', 'DELETE')) then

       htp.tableRowOpen;
       htp.tableData(cvalue=>wf_core.translate('PAGE_NAME'),
                     cattributes  => 'VALIGN="MIDDLE"');

       htp.tableData('<B>'||l_page_name||'</B>', cattributes  => 'VALIGN="MIDDLE"');
       htp.tableRowClose;
       htp.formHidden('p_page_id', p_page_id);

    end if;

    if (p_mode IN ('COPY', 'CREATE', 'RENAME')) THEN



       htp.tableRowOpen;
       htp.tableData(wf_core.translate('NEW_PAGE_NAME'),
                     cattributes  => 'VALIGN="MIDDLE"');

       htp.tableData(htf.fontOpen(cface => 'arial,helvetica')
                     || htf.formText(cname => 'p_page_name', csize => '20', cmaxlength => '30',
                                     cattributes => 'VALUE="'||l_page_name||'"')||        --mputman removed onClick
                     htf.fontClose, cattributes  => 'VALIGN="MIDDLE"');
       htp.tableRowClose;
       htp.formHidden('p_mode',p_mode);

    end if;


    -- CLOSE THE TABLE FOR THE FORM ELEMENTS
    htp.tableClose;

    -- Draw the dialog footer
    l_dialog.close_dialog;

    -- CLOSE FORM
    htp.formClose;

    htp.centerClose;

    -- Close Body
    htp.bodyClose;

    -- Close HTML
    htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('icx_define_pages', 'DispPageDialog');
    Error;
end DispPageDialog;

procedure OrderPages(
   Pages        in VARCHAR2,
   oldPages     in varchar2,
   calledfrom   in varchar2) is

l_done               boolean := FALSE;
l_user_id            number;
l_position           number := 0;
l_page_id            varchar2(30);
username             varchar2(30);
l_pages              varchar2(4000);

Begin

  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  l_user_id:= icx_sec.getID(icx_sec.PV_WEB_USER_ID);

  -- Validate the user
  if (username is null) then
      -- No username entered
      wfa_html.Login('WFA_ENTER_ID');
      return;
  end if;

  l_pages := pages;

  while (l_done = FALSE) loop

     if (instr(l_pages, ':') > 0) then

        l_page_id := SUBSTR(l_pages, 1, instr(l_pages, ':') - 1);
        l_pages   := SUBSTR(l_pages, instr(l_pages, ':') + 1);

     else

        -- Make sure to get the last page
        l_page_id := l_pages;
        l_done    := TRUE;

     end if;

     if (l_page_id IS NOT NULL) then

        l_position := l_position + 1;

        update icx_pages
        set    SEQUENCE_NUMBER	= l_position
        where  user_id = l_user_id
        and    page_id = TO_NUMBER(l_page_id);

     end if;

  end loop;

   -- use owa_util.redirect_url to redirect the URL to the home page
   owa_util.redirect_url(curl=>wfa_html.base_url ||
   	     	            '/icx_define_pages.PageList',
			    bclose_header=>TRUE);


exception
  when others then
    rollback;
    wf_core.context('icx_define_pages', 'OrderPages');
    Error;

END OrderPages;

procedure SavePage(
   P_request          in varchar2,
   P_Mode             in varchar2,
   P_Page_id          in varchar2,
   P_Page_Name        in varchar2) IS

l_user_id            number;
l_position           number := 0;
l_page_id            varchar2(30);
username             varchar2(30);
l_pages              varchar2(4000);

BEGIN
  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  l_user_id:= icx_sec.getID(icx_sec.PV_WEB_USER_ID);

  -- Validate the user
  if (username is null) then
      -- No username entered
      wfa_html.Login('WFA_ENTER_ID');
      return;
  end if;

  if (p_mode = 'CREATE') then
     -- Get the new page id

     l_page_id := oracleconfigure.createpage (
       p_page_type => 'USER',
       p_page_name => p_page_name);

  elsif (p_mode = 'RENAME') then

     -- Set the new page name
     oracleconfigure.renamepage (
       p_page_id   => p_page_id,
       p_page_name => p_page_name);

  elsif (p_mode = 'COPY') then

     -- Get the new page id
     l_page_id := oracleconfigure.copypage (
       p_page_id =>  p_page_id,
       p_page_name => p_page_name);

  elsif (p_mode = 'DELETE') then

     -- Set the new page name
     oracleconfigure.deletepage (p_page_id   => p_page_id);

     -- use owa_util.redirect_url to redirect the URL to the home page
     owa_util.redirect_url(curl=>wfa_html.base_url ||
      	     	            '/icx_define_pages.editpagelist',
			    bclose_header=>TRUE);

  end if;
  if (p_mode in ('CREATE', 'COPY', 'RENAME') ) then
     -- removed browser specific code and added parent reload and window close
     -- mputman 1936581
    htp.p('<SCRIPT>');
    htp.p('parent.opener.location.reload();');
    htp.p('window.close();');
    htp.p('</SCRIPT>');

  end if;
exception
  when others then
    rollback;
    wf_core.context('icx_define_pages', 'OrderPages');
    Error;

END SavePage;


procedure PageList is

l_user_id               number;
l_title                 varchar2(80);
old_plist               varchar2(2000);
l_message               varchar2(2000);
l_nbsp                  varchar2(240);
l_history varchar2(240);
l_prompt_length number;

username                varchar2(30);
l_actions icx_cabo.actionTable;


cursor wlistcurs is
   select ip.page_id, ipt.page_name
     from icx_pages ip,
	  icx_pages_tl ipt
    where ip.user_id = l_user_id
      and ipt.language = userenv('LANG')
      and ip.page_id = ipt.page_id
      and ip.page_type = 'USER'
   order by ip.sequence_number;

begin

  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  l_user_id:= icx_sec.getID(icx_sec.PV_WEB_USER_ID);

  -- Validate the user
  if (username is null) then
      -- No username entered
      wfa_html.Login('WFA_ENTER_ID');
      return;
  end if;


    l_title := 'Maintain Pages';
    l_nbsp := '&'||'nbsp;';

    if instr(owa_util.get_cgi_env('HTTP_USER_AGENT'),'MSIE') > 0
    then
        l_history := '';
    else
        l_history := 'history.go(0);';
    end if;

    htp.p('<html>');
    htp.p('<head>');
    htp.p('<title>'||l_title||'</title>');
    htp.p('</head>');

    wfa_sec.Header(background_only=>TRUE,
                   page_title=>wf_core.translate('MAINTAIN_PAGES'),
                   inc_lov_applet=>FALSE);

    htp.p('<SCRIPT LANGUAGE="JavaScript">');

    l_prompt_length := 0;

    l_message := wf_core.translate('SELECT_PAGE');

    htp.p('<!-- Comment out script for old browers');

    htp.p('function selectTo() {
        alert("'||l_message||'")
        }');

    htp.p('function swap(e1, e2)
           {
              ttext = e1.text;
              tvalue = e1.value;
              e1.text = e2.text;
              e1.value = e2.value;
              e2.text = ttext;
              e2.value = tvalue;
           }');

    htp.p('function deleteBlankRowIfNotEmpty(toList)
           {
              var idx = -1;
              var val = "";
           // find a blank row in table
              for (i = 0; i < toList.length; i++){
                   val = toList.options[i].value;
                   if (val == "") {
                      idx = i;
                      break;
                   }
              }
              if (idx >= 0 && (toList.length > 1))
                 toList.options[idx] = null;
           }');

    htp.p('function moveElementUp(toList, p_formname)
           {    // go through the list and get all selected items
              for ( i = 0; i <= toList.length-1; i++)
              { // if the item is selected then swap it
                if (toList.options[i].selected)
                {   // check if it is not the first item
                    if (i != 0)
                    {
                        swap(toList.options[i], toList.options[i - 1]);
                        toList.options[i - 1].selected = true;
                        toList.options[i].selected = false;
                    }
                }
              }
            }');

     htp.p('function moveElementDown(toList, p_formname)
            {    // go through the list and get all selected items
               for ( i = toList.length-1; i >= 0; i--)
               { // if the item is selected then swap it
                 if (toList.options[i].selected)
                 {   // check if it is not the first item
                     if (i != toList.length-1)
                     {
                         swap(toList.options[i], toList.options[i + 1]);
                         toList.options[i + 1].selected = true;
                         toList.options[i].selected = false;
                     }
                 }
               }
            }');

     htp.p('function moveElementTop(toList, p_formname)
            {    // get the first item selected which needs to move to top
                 iSelected = toList.selectedIndex;
                 if (iSelected == 0)
                    return;
                 // now run the moveup loop
                 for ( iMoveTop = 1; iMoveTop <= iSelected; iMoveTop++)
                    moveElementUp(toList);
            }');

     htp.p('function moveElementBottom(toList, p_formname)
            {    // get the last item selected which needs to move to bottom
                 for ( i = 0; i <= toList.length-1; i++)
                 { // if the item is selected then swap it
                   if (toList.options[i].selected)
                      iSelected = i;
                 }
                 if (iSelected == toList.length-1)
                    return;
                 iSelected = toList.length - 1 - iSelected;
                 // now run the movedown loop
                 for ( iMoveDown = 1; iMoveDown <= iSelected; iMoveDown++)
                    moveElementDown(toList);
            }');

     htp.p ('function Rename() {
        var temp=document.PageList.C.selectedIndex;
        if (temp < 0)
          selectTo();
        else {
	  var valuestring=document.PageList.C.options[temp].value;
          popupWin = window.open("'||wfa_html.base_url ||
                '/icx_define_pages.DispPageDialog?p_mode=RENAME&p_page_id=" + valuestring,
                "EditRegion", "statusbar=Y,resizable,width=575,height=300");
         }
        }');

     htp.p ('function Delete() {
        var temp=document.PageList.C.selectedIndex;
        if (temp < 0)
          selectTo();
        else {
	  var valuestring=document.PageList.C.options[temp].value;
          popupWin = window.open("'||wfa_html.base_url ||
                '/icx_define_pages.DispPageDialog?p_mode=DELETE&p_page_id="+ valuestring,
                "EditRegion", "statusbar=Y,resizable,width=575,height=300");
         }
        }');

     htp.p ('function Copy() {
          popupWin = window.open("'||wfa_html.base_url ||
                '/icx_define_pages.DispPageDialog?p_mode=COPY",
                "EditRegion", "statusbar=Y,resizable,width=575,height=400");
        }');

    htp.p('function Edit() {
        var temp=document.PageList.C.selectedIndex;
        if (temp < 0)
          selectTo();
        else {
	  var valuestring=document.PageList.C.options[temp].value;

	  top.location.href ="'||wfa_html.base_url ||'/oracleconfigure.customize?p_page_id=" + valuestring;
	}
        }');

   htp.p ('function createNew() {
              popupWin = window.open("'||wfa_html.base_url ||
                '/icx_define_pages.DispPageDialog?p_mode=CREATE",
                                     "EditRegion", "statusbar=Y,resizable,width=575,height=300");
            }');


    htp.p('function saveOrder() {
        var end=document.PageList.C.length;

        document.updatePageList.pages.value = "";

        for (var i=0; i<end; i++)
          if (document.PageList.C.options[i].value != "")
             document.updatePageList.pages.value = document.updatePageList.pages.value + ":" + document.PageList.C.options[i].value;

	document.updatePageList.submit();

        }');

   htp.p('function cancelPage() {
        top.location.href = "'||wfa_html.base_url ||'/oraclemypage.home";
        }');

    htp.p('//-->');
    htp.p('</SCRIPT>');

    htp.p('<BODY bgcolor="#CCCCCC">');
    htp.formOpen('javascript:saveOrder()','POST','','','NAME="PageList"');

    htp.p('<table width="100%" border=0 cellspacing=0 cellpadding=0>'); -- main

    htp.p('<tr><td align=center><BR>');

    htp.p('<table width="10%" border=0 cellspacing=10 cellpadding=0>'); -- Cell

    htp.p('<tr><td align=center><B> ' || wf_core.translate('PAGE_NAME') || '</B></td></tr>');

    htp.p('<tr><td>');

    htp.p('<select width="200" name="C" size=10>');

    old_plist:='';

    -- set the pagess that have already been selected
    for rec in wlistcurs loop

        htp.formSelectOption(cvalue => rec.page_name,
                             cattributes => 'VALUE="'||to_char(rec.page_id)||'"');

        old_plist:= old_plist ||':'||to_char(rec.page_id);

    end loop;

    htp.formSelectClose;

    htp.p('</td><td align="left">');

    htp.p('<table border=0><tr><td align="left" valign="top">');

    htp.p('<A HREF="javascript:moveElementTop(document.PageList.C,'||''''||
          'PageList'||''''||');" onMouseOver="window.status='''||'Top'||''';return true"><image src="/OA_MEDIA/movetop.gif" alt="'||wf_core.translate('TOP')||'" BORDER="0"></A>');

    htp.p('</td></tr><tr><td align="left">');

    htp.p('<A HREF="javascript:moveElementUp(document.PageList.C,'||''''||
          'PageList'||''''||');" onMouseOver="window.status='''||'Up'||''';return true"><image src="/OA_MEDIA/moveup.gif" alt="'||wf_core.translate('UP')||'" BORDER="0"></A>');

    htp.p('</td></tr><tr><td align="left">');

    htp.p('<A HREF="javascript:moveElementDown(document.PageList.C,'||''''||
          'PageList'||''''||');" onMouseOver="window.status='''||'Down'||''';return true"><image src="/OA_MEDIA/movedown.gif" alt="'||wf_core.translate('DOWN')||'" BORDER="0"></A>');

    htp.p('</td></tr><tr><td align="left">');

    htp.p('<A HREF="javascript:moveElementBottom(document.PageList.C,'||''''||
          'PageList'||''''||');" onMouseOver="window.status='''||'Bottom'||''';return true"><image src="/OA_MEDIA/movebottom.gif" alt="'||wf_core.translate('BOTTOM')||'" BORDER="0"></A>');

    htp.p('</td></tr></table>'); -- Up and Down


    htp.p('</td></tr>');  --close first row

    htp.p('<tr><td colspan=2>');    --second row

    htp.p('</td></tr>');  --end second row
    htp.p('</table>'); -- Cell
    htp.p('</td></tr>');

    htp.p('<tr><td><br></td></tr>');

    htp.p('<tr><td align=center>');

    htp.p('</td></tr></table>'); -- Main

    htp.formClose;

    -- add real form that does the posting
    htp.formOpen('icx_define_pages.OrderPages','POST','','','NAME="updatePageList"');
    htp.formHidden(cname=>'pages');
    htp.formHidden(cname=>'oldpages',cvalue=>old_plist);
    htp.formHidden(cname=>'calledfrom');
    htp.formClose;

-- finally add buttons for cabo page.
-- these cause javascript error if procedure not called from
-- cabo frame.

   l_actions(0).name := 'Done';
   l_actions(0).text := wf_core.translate('DONE');
   l_actions(0).actiontype := 'function';
   l_actions(0).action := 'top.main.cancelPage()';  -- put your own commands here
   l_actions(0).targetframe := 'main';
   l_actions(0).enabled := 'b_enabled';
   l_actions(0).gap := 'b_narrow_gap';

   l_actions(1).name := 'Save';
   l_actions(1).text := wf_core.translate('SAVE');
   l_actions(1).actiontype := 'function';
   l_actions(1).action := 'top.main.saveOrder()';  -- put your own commands here
   l_actions(1).targetframe := 'main';
   l_actions(1).enabled := 'b_enabled';
   l_actions(1).gap := 'b_narrow_gap';

   l_actions(2).name := 'New';
   l_actions(2).text := wf_core.translate('NEW');
   l_actions(2).actiontype := 'function';
   l_actions(2).action := 'top.main.createNew()';  -- put your own commands here
   l_actions(2).targetframe := 'main';
   l_actions(2).enabled := 'b_enabled';
   l_actions(2).gap := 'b_narrow_gap';

   l_actions(3).name := 'CopyPage';
   l_actions(3).text := wf_core.translate('COPY');
   l_actions(3).actiontype := 'function';
   l_actions(3).action := 'top.main.Copy()';  -- put your own commands here
   l_actions(3).targetframe := 'main';
   l_actions(3).enabled := 'b_enabled';
   l_actions(3).gap := 'b_narrow_gap';

   l_actions(4).name := 'EditPage';
   l_actions(4).text := wf_core.translate('EDIT');
   l_actions(4).actiontype := 'function';
   l_actions(4).action := 'top.main.Edit()';  -- put your own commands here
   l_actions(4).targetframe := 'main';
   l_actions(4).enabled := 'b_enabled';
   l_actions(4).gap := 'b_narrow_gap';

   l_actions(5).name := 'RenamePage';
   l_actions(5).text := wf_core.translate('RENAME');
   l_actions(5).actiontype := 'function';
   l_actions(5).action := 'top.main.Rename()';  -- put your own commands here
   l_actions(5).targetframe := 'main';
   l_actions(5).enabled := 'b_enabled';
   l_actions(5).gap := 'b_narrow_gap';

   l_actions(6).name := 'DeletePage';
   l_actions(6).text := wf_core.translate('DELETE');
   l_actions(6).actiontype := 'function';
   l_actions(6).action := 'top.main.Delete()';  -- put your own commands here
   l_actions(6).targetframe := 'main';
   l_actions(6).enabled := 'b_enabled';
   l_actions(6).gap := 'b_narrow_gap';

   icx_cabo.buttons(l_actions);

   htp.bodyClose;
   htp.htmlClose;

exception
    when others then
        htp.p(SQLERRM);

end PageList;


procedure EditPageList is

l_title varchar2(80);
l_helpmsg varchar2(2000);
l_helptitle varchar2(240);
l_actions icx_cabo.actionTable;
l_toolbar icx_cabo.toolbar;
username varchar2(30);

begin

  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

    htp.headopen;
    htp.p('<SCRIPT>');

    icx_admin_sig.help_win_script('PAGEADM', null, 'FND');

    htp.p('</SCRIPT>');
    htp.headclose;

l_toolbar.title := wf_core.translate ('MAINTAIN_PAGES');
l_toolbar.help_url := 'javascript:top.help_window()';
fnd_message.set_name('ICX','ICX_HELP');
l_toolbar.help_mouseover := FND_MESSAGE.GET;
l_toolbar.custom_option1_url := icx_plug_utilities.getPLSQLagent ||
          'OracleMyPage.Home';
l_toolbar.custom_option1_mouseover := wf_core.translate ('RETURN_TO_HOME');
l_toolbar.custom_option1_gif := '/OA_MEDIA/FNDHOME.gif';
l_toolbar.custom_option1_mouseover_gif := '/OA_MEDIA/FNDHOME.gif';

l_helpmsg := wf_core.translate ('ICX_ADMIN_HELP');
l_helptitle := wf_core.translate ('MAINTAIN_PAGES');

icx_cabo.container(p_toolbar => l_toolbar,
               p_helpmsg => l_helpmsg,
               p_helptitle => l_helptitle,
               p_url => owa_util.get_cgi_env('SCRIPT_NAME')||'/ICX_DEFINE_PAGES.PageList',
               p_action => TRUE);

end EditPageList;

end ICX_DEFINE_PAGES;

/
