--------------------------------------------------------
--  DDL for Package Body WF_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_LOV" as
/* $Header: wflovb.pls 120.1 2005/07/02 03:49:13 appldev ship $ */

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
 null;
end Error;

/*===========================================================================
  PROCEDURE NAME:       OpenLovWinHtml

  DESCRIPTION:          Generates javascript required to run the HTML LOV.
                        Insert the javascript statements in the header of
                        the Document that will call the LOV window.

============================================================================*/
procedure OpenLovWinHtml(p_jscript_tag     IN Varchar2 ) is

begin

   IF (p_jscript_tag = 'Y') THEN

      htp.p('<SCRIPT LANGUAGE="JavaScript"> <!-- hide the script''s contents from feeble browsers');

   END IF;

   htp.p('// global for brower version branching');
   htp.p('var Nav4 = ((navigator.appName == "Netscape") && (parseInt(navigator.appVersion) == 4))');
   htp.p('var IELinkClicks');

   htp.p('// code for modal lov window');
   htp.p('var FNDLOVwindow = new Object();');

   htp.p(
      'function fnd_open_window(url,x,y)
       {
          var x1 = x - 16;
          var y1 = y - 50;
          var url2 = url + "&width=" + x1 + "&height=" + y1;

          var attributes=
             "bgColor=red,resizable=yes,scrollbars=no,toolbar=no,menubar=no,width="+x+",height="+ y;

          FNDLOVwindow.win = window.open(url2, "FNDLOVwindow", attributes);

          FNDLOVwindow.win.focus();

          FNDLOVwindow.win.opener = self;

          FNDLOVwindow.open = true;
       }'
   );

    -- event handler to prevent any Navigator action when modal is active
    htp.p('function deadend() {
      if (FNDLOVwindow.win && !FNDLOVwindow.win.closed) {
        FNDLOVwindow.win.focus()
        return false
      }
    }');

    -- preserve IE link onclick event handlers while they're disabled
    -- restore when re-enabling the main window
    htp.p('function disableForms() {
      IELinkClicks = new Array()
      for (var h = 0; h < frames.length; h++) {
        for (var i = 0; i < frames[h].document.forms.length; i++) {
          for (var j = 0; j < frames[h].document.forms[i].elements.length; j++) {
             frames[h].document.forms[i].elements[j].disabled = true
          }
        }
        IELinkClicks[h] = new Array()
        for (i = 0; i < frames[h].document.links.length; i++) {
          IELinkClicks[h][i] = frames[h].document.links[i].onclick
          frames[h].document.links[i].onclick = deadend
        }
      }
    }');

    htp.p('function enableForms() {
      for (var h = 0; h < frames.length; h++) {
        for (var i = 0; i < frames[h].document.forms.length; i++) {
          for (var j = 0; j < frames[h].document.forms[i].elements.length; j++) {
            frames[h].document.forms[i].elements[j].disabled = false
          }
        }
        for (i = 0; i < top.frames[h].document.links.length; i++) {
            frames[h].document.links[i].onclick = IELinkClicks[h][i]
        }
      }
    }');

    -- a little extra help for Navigator
    htp.p('function blockEvents() {
      if (Nav4) {
        window.captureEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS)
        window.onclick = deadend
        window.onfocus = checkModal
      } else {
        disableForms()
      }
    }');

    htp.p('function unblockEvents() {
      if (Nav4) {
        window.releaseEvents(Event.CLICK | Event.MOUSEDOWN | Event.MOUSEUP | Event.FOCUS)
        window.onclick = null
        window.onfocus = null
      } else {
        enableForms()
      }
    }');

    -- invoked by onFocus event handler of EVERY frame's document
    htp.p('function checkModal() {
      if (FNDLOVwindow.open && FNDLOVwindow.win && !FNDLOVwindow.win.closed) {
          FNDLOVwindow.win.focus()
      }
    }');

    -- clear 'opener' reference in a modal
    htp.p('function cancelModal() {
      if (FNDLOVwindow.win && !FNDLOVwindow.win.closed) {
        FNDLOVwindow.win.opener = null;
        FNDLOVwindow.open = false;
      }
    }');

    htp.p('// end of modal lov code');

   IF (p_jscript_tag = 'Y') THEN

      htp.p('<!-- done hiding from old browsers --> </SCRIPT>');
      htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');
   END IF;

   exception
   when others then
      Wf_Core.Context('wf_lov', 'OpenLovWinHtml');
      raise;

end OpenLovWinHtml;

/*===========================================================================
  FUNCTION NAME:        GenerateLovURL

  DESCRIPTION:          Generates the URL syntax required to launch
                        the lov window for the given field.

============================================================================*/
function GenerateLovURL (p_form_name       IN Varchar2,
                         p_query_plsql     IN Varchar2,
                         p_query_params    IN Varchar2,
                         p_column_names    IN Varchar2,
                         p_longlist        IN Varchar2,
                         p_callback        IN Varchar2 ,
                         p_callback_params IN Varchar2 ,
                         p_init_find_field IN Varchar2 ,
                         p_width           IN Varchar2,
                         p_height          IN Varchar2,
                         p_prompt          IN Varchar2 ,
                         p_window_title    IN Varchar2 )
return VARCHAR2
IS

l_url     VARCHAR2(4000);

BEGIN

    l_url := '"javascript:fnd_open_window('||''''||
               'wf_lov.lovapplet'||
               '?doc_name='       ||p_form_name||
               '&column_names='   ||p_column_names||
               '&query_params='   ||p_query_params||
               '&query_plsql='    ||p_query_plsql||
               '&longlist='       ||p_longlist||
               '&callback='       ||p_callback||
               '&callback_params='||p_callback_params||
               '&initial_find='   ||p_init_find_field||
               '&window_title='   ||p_window_title||
               ''''||
               ','||p_width||','||p_height||')" ';

    if p_prompt is not null then
       l_url := l_url|| ' OnMouseOver="window.status='''||p_prompt||
                ''';return true" ';
    end if;


    return (l_url);

exception
  when others then
    rollback;
    wf_core.context('Wf_Lov', 'GenerateLovURL',
                         p_form_name    ,
                         p_query_plsql  ,
                         p_query_params ,
                         p_column_names ,
                         p_longlist     );

    wf_lov.Error;
END GenerateLovURL;

procedure CreateButton (when_pressed_url in varchar2,
                        onmouseover in varchar2,
                        icon_top in varchar2,
                        icon_name in varchar2,
                        show_text in varchar2) is
begin

   htp.p('<TABLE border=0 cellpadding=0 cellspacing=0 align=right summary="">');

   htp.p('<TR> <TD align="right" height=22 rowspan=3 id=""><A href="'||when_pressed_url||'" '||
         onmouseover||'>'||
         '<IMG src="'||icon_top||'FNDJLFRL.gif" height=22 width=15 border=0 alt=""></A></TD>'||
         '<TD height=1 bgcolor=#FFFFFF colspan=2><IMG src="'||icon_top||
         'FNDINVDT.gif" height=1 width=1 alt=""></TD>'||
         '<TD height=22 rowspan=3 id=""><A href="'||when_pressed_url||'" '||onmouseover||
         '><IMG src="'||icon_top||'FNDJLFRR.gif" height=22 width=15 border=0 alt=""></A>'||
         '</TD></TR>'||
         '<TR> <TD height=20 bgcolor=#cccccc id=""><A href="'||when_pressed_url||
         '" '||onmouseover||'><IMG src="'||icon_top||icon_name||'" border=0 alt="' || onmouseover || '"></A></TD>'||
         '<TD id="" height=20 align=center valign=center bgcolor=#cccccc nowrap><A href="'||
         when_pressed_url||'" style="text-decoration:none" '||onmouseover||
         '><FONT size=2 face="Arial,Helvetica,Geneva"  color=#000000>'||show_text||
         '</FONT></A></TD></TR>'||
         '<TR> <TD height=1 bgcolor=#000000 colspan=2 id=""><IMG src="'||icon_top||
         'FNDINVDT.gif" width=1 height=1></TD></TR>');

   htp.p('</TABLE>');

exception
  when others then
    rollback;
    wf_core.context('Wf_Lov', 'create_reg_button',when_pressed_url,onmouseover,
                    icon_top,icon_name,show_text);
    wf_lov.Error;

end CreateButton;

procedure LovApplet(doc_name        varchar2,
                    column_names    varchar2,
                    query_params    varchar2,
                    query_plsql     varchar2,
                    callback        varchar2 ,
                    callback_params varchar2 ,
                    longlist        varchar2,
                    initial_find    varchar2 ,
                    width           varchar2,
                    height          varchar2,
                    window_title    varchar2 ) IS

username varchar2(320);   -- Username to query
lang_codeset varchar2(50);
col_num varchar2(20);
l_document_position number := 0;
i number;
l_url         varchar2(1000);
l_media       varchar2(240) := wfa_html.image_loc;
l_icon        varchar2(30);
l_text        varchar2(30) := '';
l_onmouseover varchar2(240);
l_params      varchar2(240) := callback_params;
l_window_name varchar2(240);
name          varchar2(1000);
buffer        varchar2(1000);
col_names     varchar2(1000) := column_names;
callback_str  varchar2(2000) := callback;


begin

  -- Check session and current user
  wfa_sec.GetSession(username);

  lang_codeset := substr(userenv('LANGUAGE'),
                         instr(userenv('LANGUAGE'),'.')+1,
                         length(userenv('LANGUAGE')));

  l_document_position := INSTR(UPPER(doc_name), '.DOCUMENT');
  /*
  ** Strip off the document object information from the document hierarchy
  ** so we can run javascript functions on the window and/or frame
  */
  l_window_name := SUBSTR(doc_name, 1, l_document_position-1);


  htp.htmlOpen;
  htp.headOpen;

  IF (window_title IS NOT NULL) THEN

     htp.title(window_title);

  ELSE

     htp.title(wf_core.translate('WFPREF_LOV'));

  END IF;

  htp.p('<SCRIPT LANGUAGE="JavaScript1.2"> <!-- hide the script''s contents from feeble browsers');

  if doc_name <> 'PRELOAD' then -- added to prevent js errors on lov preload

  htp.p(
      'function set_value()
       {');

  -- added for modal lov functionality
  htp.p(l_window_name||'.unblockEvents();');

  name := col_names;
  i := 0;

  /*
  ** Loop through the fields to set and set the values based
  ** on a hard coded field list lovValue0-15
  */
  while (instr(col_names, ',') <> 0) loop

      name := substr(col_names, 1, instr(col_names, ',')-1);
      col_names := substr(col_names, instr(col_names, ',')+1,
                         length(col_names)-length(name)-1);

      IF (name <> 'NULL') THEN

         htp.p(doc_name||'.'||name||'.value = top.parent.document.LovApplet.lovValue'||to_char(i)||';');

      END IF;

      i := i + 1;

  end loop;

  /*
  ** Check to see if there's anything left after the loop to get.
  ** there should be something left after the last comma.
  */
  IF (col_names <> 'NULL') THEN

     htp.p(doc_name||'.'||col_names||'.value = parent.document.LovApplet.lovValue'||i||';');

  end if;


  /*
  ** Create the callback function and callback parameters syntax
  */
  if (LENGTH(callback_str) > 0) then

      callback_str := callback_str || '(';

  end if;

  i := 0;

  while (instr(l_params, ',') <> 0) loop

      /*
      ** If the buffer has at least one other field already then
      ** add a comma to the string
      */
      IF (i > 0) THEN

         callback_str := callback_str || ',';

      END IF;

      col_num   := substr(l_params, 1, instr(l_params, ',')-1);

      l_params := substr(l_params, instr(l_params, ',')+1,
                         length(l_params)-length(col_num)-1);

      callback_str := callback_str || 'parent.document.LovApplet.lovValue'||col_num;

      i := i + 1;

  end loop;

  /*
  ** Check to see if there's anything left after the loop to get.
  ** there should be something left after the last comma.
  */
  IF (LENGTH(l_params) > 0) THEN

      /*
      ** If the buffer has at least one other field already then
      ** add a comma to the string
      */
      IF (i > 0) THEN

         callback_str := callback_str || ',';

      END IF;

      callback_str := callback_str || 'parent.document.LovApplet.lovValue'||l_params;

  end if;

  if (LENGTH(callback_str) > 0) then

      callback_str := callback_str || ');';

  end if;

  htp.p(callback_str);

  htp.p(l_window_name||'.cancelModal();');

  htp.p('window.close();}');

  htp.p('<!-- done hiding from old browsers --> </SCRIPT>');
  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');
  htp.p('<SCRIPT LANGUAGE="JavaScript1.2"> <!-- hide the script''s contents from feeble browsers');

  -- added 'if (opener)...' line for modal lov functionality
  htp.p(
      'function cancel_lov()
       {
         if (opener.parent) {
           '||l_window_name||'.unblockEvents();
           '||l_window_name||'.cancelModal();
         }

         window.close();

        }'
  );
  end if;  -- PRELOAD

  -- added for modal lov functionality
  htp.p('var Nav4 = ((navigator.appName == "Netscape") && (parseInt(navigator.appVersion) == 4))');

  htp.p('function forceFocus() {
    if (!Nav4) {
      window.focus();
    }
  }');

  htp.p('<!-- done hiding from old browsers --> </SCRIPT>');

  htp.p('<SCRIPT LANGUAGE="JavaScript1.2"> <!-- hide the script''s contents from feeble browsers');

  htp.p(
      'function helper()
       {
         var encoded_value = '||initial_find|| '

         document.write("<applet code=\"oracle.apps.fnd.wf.LovApplet.class\" codebase=\"/OA_JAVA\" archive=\"/OA_JAVA/oracle/apps/fnd/wf/jar/wflov.jar\" width=100% height=90% name=LovApplet>");

         document.write("<param name=QUERY_PARAMS value='||query_params||'>")');

         htp.p('document.write("<param name=QUERY_URL value='||
               wfa_html.base_url(get_from_resources=>TRUE)||
               '/'||query_plsql||'>")');

         htp.p('document.write("<param name=LONGLIST value='||longlist||'>")');
         htp.p('document.write("<param name=INITIAL_FIND value="+"\""+encoded_value+"\""+">")');
         htp.p('document.write("<param name=LANGCODESET value='||lang_codeset||'>")');
         htp.p('document.write("<param name=title value='||'LOV'||'>")');
         htp.p('document.write("<\/applet>");');
  htp.p('}');

  htp.p('<!-- done hiding from old browsers --> </SCRIPT>');

  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  htp.p('<param name=QUERY_URL value="' ||
       wfa_html.base_url(get_from_resources=>TRUE)||
       '/'|| query_plsql || '">');

  htp.p('<param name=LONGLIST value="' || longlist || '">');

  htp.headclose;

  if doc_name <> 'PRELOAD' then -- added to prevent js errors on lov preload
    htp.p('<body BGCOLOR="#CCCCCC" onLoad="if (opener.parent) '||
       l_window_name||'.blockEvents(); forceFocus()" onFocus="forceFocus()">');
  else
    htp.p('<body BGCOLOR="#FFFFFF">');
  end if;

  htp.p('<form name="LOVWin">');

  htp.p('<SCRIPT LANGUAGE="JavaScript1.2"> <!-- hide the script''s contents from feeble browsers');

  htp.p('helper();');

  htp.p('<!-- done hiding from old browsers --> </SCRIPT>');
  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  l_url         := 'javascript:cancel_lov()';
  l_icon        := 'FNDJLFCN.gif';
  l_text        := wf_core.translate ('CANCEL');
  l_onmouseover := wf_core.translate ('CANCEL');

  CreateButton (l_url, l_onmouseover, l_media, l_icon, l_text);

  l_url         := 'javascript:set_value()';
  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('WFMON_OK');
  l_onmouseover := wf_core.translate ('WFMON_OK');

  CreateButton (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</form>');
  htp.p('</body>');
  htp.htmlclose;


exception
  when others then
    rollback;
    wf_core.context('Wf_Pref', 'lang_lov_applet');
    wf_lov.error;

end LovApplet;


procedure display_lov
(
p_lov_name            in varchar2 ,
p_display_name        in varchar2 ,
p_validation_callback in varchar2 ,
p_dest_hidden_field   in varchar2 ,
p_dest_display_field  in varchar2 ,
p_current_value       in varchar2 ,
p_param1              in varchar2 ,
p_param2              in varchar2 ,
p_param3              in varchar2 ,
p_param4              in varchar2 ,
p_param5              in varchar2 ,
p_display_key         in varchar2
) IS

username	varchar2(320);
l_display_name  varchar2(360);

BEGIN

  WFA_SEC.GetSession(username);

 /*  Check the display_key.  If 'Y' then translate p_display_name and store
  *  in l_display_name
  */

  if (p_display_key='Y') then
     l_display_name := wf_core.translate(p_display_name);
  end if;

  /*
  ** Set the title for the window
  **
  ** Check to see if the key is passed, if yes then display the variable
  ** storing the translated value.
  */
if (p_display_key='Y') then
  htp.title(l_display_name);

  /*
  ** Now create the summary/detail frameset
  */
  htp.p ('<FRAMESET ROWS="75,*" BORDER=0 BGCOLOR="#CCCCCC" TITLE="' ||
         l_display_name || '" LONGDESC="' || owa_util.get_owa_service_path ||
         'wfa_html.LongDesc?p_token="' || p_lov_name || '">');
else
   htp.title(p_display_name);

   htp.p ('<FRAMESET ROWS="75,*" BORDER=0 BGCOLOR="#CCCCCC" TITLE="' ||
         p_display_name || '" LONGDESC="' || owa_util.get_owa_service_path ||
         'wfa_html.LongDesc?p_token="' || p_lov_name || '">');

end if;

  /*
  ** Create the summary frame
  */

  htp.p ('<FRAME NAME=FIND '||
         'SRC='||
         owa_util.get_owa_service_path||
         'wf_lov.display_lov_find?p_lov_name='||
         wfa_html.conv_special_url_chars(p_lov_name)||
         '&p_display_name='||p_display_name||
         '&p_validation_callback='|| p_validation_callback||
         '&p_dest_hidden_field='||p_dest_hidden_field||
         '&p_dest_display_field='||p_dest_display_field||
         '&p_current_value='||
         wfa_html.conv_special_url_chars(p_current_value)||
         '&p_autoquery=Y'||'&p_display_key='||p_display_key||
         ' MARGINHEIGHT=10 MARGINWIDTH=10 FRAMEBORDER=0 WRAP=OFF TITLE="' ||
         p_display_name || '" LONGDESC="' || owa_util.get_owa_service_path ||
         'wfa_html.LongDesc?p_token="' || p_lov_name || '">');


  /*
  ** Create the details frame
  */
htp.p('details frame p_display_name is '||p_display_name);
 htp.p ('<FRAME NAME=DETAILS '||
         'SRC='||
         owa_util.get_owa_service_path||
         'wf_lov.display_lov_details?p_lov_name='||
         wfa_html.conv_special_url_chars(p_lov_name)||
         '&p_display_name='||p_display_name||
         '&p_validation_callback='||p_validation_callback||
        '&p_dest_hidden_field='||p_dest_hidden_field||
         '&p_dest_display_field='||p_dest_display_field||
         '&p_autoquery=Y'||
         '&p_param1='||
             wfa_html.conv_special_url_chars(p_param1)||
         '&p_param2='||
             wfa_html.conv_special_url_chars(p_param2)||
         '&p_param3='||
             wfa_html.conv_special_url_chars(p_param3)||
         '&p_param4='||
             wfa_html.conv_special_url_chars(p_param4)||
         '&p_param5='||
             wfa_html.conv_special_url_chars(p_param5)||
         '&p_display_key='||p_display_key||
         ' MARGINHEIGHT=10 MARGINWIDTH=10 FRAMEBORDER=YES TITLE="' ||
         p_display_name || '" LONGDESC="' || owa_util.get_owa_service_path ||
         'wfa_html.LongDesc?p_token="' || p_lov_name || '">');

  /*
  ** Close the summary/details frameset
  */
  htp.p ('</FRAMESET>');

  htp.bodyclose;
  htp.htmlclose;


exception
  when others then
    rollback;
    wf_core.context('Wf_Lov', 'display_lov');
    wf_lov.error;

end display_lov;


procedure display_lov_find (
p_lov_name                in varchar2 ,
p_display_name            in varchar2 ,
p_validation_callback     in varchar2 ,
p_dest_hidden_field       in varchar2 ,
p_dest_display_field      in varchar2 ,
p_current_value           in varchar2 ,
p_autoquery               in varchar2 ,
p_display_key             in varchar2 )

IS

username	varchar2(320);
l_display_name  varchar2(360);

BEGIN

  WFA_SEC.GetSession(username);

if (p_display_key='Y') then
   l_display_name := wf_core.translate(p_display_name);
end if;

  htp.headopen;

  htp.p ('<SCRIPT LANGUAGE="JavaScript">');

  htp.p('function LOV_submit()
         {
            parent.DETAILS.document.WF_DETAILS.p_lov_name.value = '||
               ''''||p_lov_name||''''||';
            parent.DETAILS.document.WF_DETAILS.p_display_name.value = '||
               ''''||p_display_name||''''||';
            parent.DETAILS.document.WF_DETAILS.p_validation_callback.value = '||
               ''''||p_validation_callback||''''||';
            parent.DETAILS.document.WF_DETAILS.p_dest_hidden_field.value = '||
              ''''||p_dest_hidden_field||''''||';
            parent.DETAILS.document.WF_DETAILS.p_dest_display_field.value = '||
              ''''||p_dest_display_field||''''||';
            parent.DETAILS.document.WF_DETAILS.p_current_value.value =
               document.WF_FIND.p_current_value.value;
            parent.DETAILS.document.WF_DETAILS.p_autoquery.value = '||
              ''''||'N'||''''||';
            parent.DETAILS.document.WF_DETAILS.p_start_row.value = 1;
            parent.DETAILS.document.WF_DETAILS.submit();
          }');

  htp.p('function fnd_get_searchtext()
         {
             if ('||p_current_value||'!= "")
             {
                 document.WF_FIND.p_current_value.value = '||
                     p_current_value||';
              }
         }');

  htp.p('function fnd_launch_query()
         {
             if (document.WF_FIND.p_current_value.value == "")
             {
                alert("'||wf_core.translate('WFLOV_NO_CRITERIA')||'");
                document.WF_FIND.p_current_value.focus();
             }
             else
             {
                  LOV_submit();
              }
          }');

  htp.p('function fnd_launch_query2()
         {
             fnd_launch_query();
          }');

  htp.p('</SCRIPT>');

  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  htp.headclose;

  htp.p('<body bgcolor="#CCCCCC">');

  htp.formOpen(curl=>'javascript:fnd_launch_query();',
               cmethod=>'POST', cattributes=>'NAME="WF_FIND"');

  htp.tableOpen(cattributes=>'summary=""');

  htp.tableRowOpen;
  htp.tableData(cvalue=>'<LABEL FOR="i_current_value">' ||
                        wf_core.translate('FIND') ||
                        '</LABEL>',
                calign=>'right',
                cattributes=>'id=""');

  htp.tableData(htf.formText(cname=>'p_current_value', csize=>'30',
                             cmaxlength=>'4000', cvalue=>'',
                             cattributes=>'id="i_current_value"'),
                cattributes=>'id=""');

  htp.p ('<SCRIPT LANGUAGE="JavaScript"> fnd_get_searchtext(); </SCRIPT>');
  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  htp.p('<TD id="">');

  wfa_html.create_reg_button ('javascript:fnd_launch_query();',
                              wf_core.translate ('FIND'),
                              wfa_html.image_loc,
                              'fndfind.gif',
                              wf_core.translate ('FIND'));

  htp.p('</TD>');

  htp.p('<TD id="">');

  wfa_html.create_reg_button ('javascript:document.WF_FIND.reset();',
                              wf_core.translate ('CLEAR'),
                              wfa_html.image_loc,
                              'fndfind.gif',
                              wf_core.translate ('CLEAR'));

  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableClose;
  htp.formClose;


exception
  when others then
    rollback;
    wf_core.context('Wf_Lov', 'display_lov_find');
    wf_lov.error;

end display_lov_find;


procedure display_lov_details   (
p_lov_name                in varchar2 ,
p_display_name            in varchar2 ,
p_validation_callback     in varchar2 ,
p_dest_hidden_field       in varchar2 ,
p_dest_display_field      in varchar2 ,
p_current_value           in varchar2 ,
p_start_row               in varchar2 ,
p_autoquery               in varchar2 ,
p_param1                  in varchar2 ,
p_param2                  in varchar2 ,
p_param3                  in varchar2 ,
p_param4                  in varchar2 ,
p_param5                  in varchar2 ,
p_display_key             in varchar2 )

IS

l_ncols          number := 0;
l_result         number := 0;
l_start_row      number := TO_NUMBER(p_start_row);
l_number_rows    number := 10;
l_call_method    varchar2(10) := 'LOV';
l_hidden_value   varchar2(240);
l_display_value  varchar2(4000) := p_current_value;
l_sql_stmt       varchar2(4000);
username	 varchar2(320);
l_display_name   varchar2(360) := NULL;

l_cursorName     number;
l_cursorResult   number;

BEGIN

  WFA_SEC.GetSession(username);

  htp.headopen;

  htp.p ('<SCRIPT LANGUAGE="JavaScript">');

if (p_display_key='Y') then
  l_display_name := wf_core.translate(p_display_name);
end if;

  if (p_autoquery = 'Y') then

     -- assigning the field values in javascript via autoquery function
     -- note that in pl/sql, we only pass in the javascript field names,
     -- not the values.
     htp.p('function autoquery()
            {
               if ('||p_dest_display_field||' != "")
               {
                  document.WF_DETAILS.p_current_value.value = '||
                      p_dest_display_field||';
                  document.WF_DETAILS.p_autoquery.value = "N";');
     if (p_param1 is not null) then
       htp.p('    document.WF_DETAILS.p_param1.value = '||
                      p_param1||';');
     end if;
     if (p_param2 is not null) then
       htp.p('    document.WF_DETAILS.p_param2.value = '||
                      p_param2||';');
     end if;
     if (p_param3 is not null) then
       htp.p('    document.WF_DETAILS.p_param3.value = '||
                      p_param3||';');
     end if;
     if (p_param4 is not null) then
       htp.p('    document.WF_DETAILS.p_param4.value = '||
                      p_param4||';');
     end if;
     if (p_param5 is not null) then
       htp.p('    document.WF_DETAILS.p_param5.value = '||
                      p_param5||';');
     end if;
     htp.p('      document.WF_DETAILS.submit();
               }
               else
               {
                  document.write("<CENTER><B>")
                  document.write('||''''||
                     wf_core.translate('WFLOV_CRITERIA')||''''||');
                  document.write("</B></CENTER>")
                  document.WF_DETAILS.p_autoquery.value = "N";');
     if (p_param1 is not null) then
       htp.p('    document.WF_DETAILS.p_param1.value = '||
                      p_param1||';');
     end if;
     if (p_param2 is not null) then
       htp.p('    document.WF_DETAILS.p_param2.value = '||
                      p_param2||';');
     end if;
     if (p_param3 is not null) then
       htp.p('    document.WF_DETAILS.p_param3.value = '||
                      p_param3||';');
     end if;
     if (p_param4 is not null) then
       htp.p('    document.WF_DETAILS.p_param4.value = '||
                      p_param4||';');
     end if;
     if (p_param5 is not null) then
       htp.p('    document.WF_DETAILS.p_param5.value = '||
                      p_param5||';');
     end if;

     htp.p('    }
            }');

  else

      -- Javascript function to handle CD buttons
      htp.p('function LOV_rows(start_num) {
            document.WF_DETAILS.p_start_row.value = start_num;
            document.WF_DETAILS.p_autoquery.value = "N";
            document.WF_DETAILS.submit();
            }');

  end if;

  htp.p('function LOV_copy(num) {
        '||
         p_dest_display_field||'=document.WF_LOV_FRM.h_display[num].value;
        '||
         p_dest_hidden_field||'=document.WF_LOV_FRM.h_hidden[num].value;
         parent.self.close();
         }');

  htp.p('</SCRIPT>');

  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  htp.headclose;

  htp.p('<body bgcolor="#CCCCCC">');

  htp.formOpen(curl=>owa_util.get_owa_service_path||
                   'wf_lov.display_lov_details',
             cmethod=>'POST', cattributes=>'NAME="WF_DETAILS"');

  htp.formhidden('p_lov_name', p_lov_name);
  htp.formhidden('p_display_name', p_display_name);
  htp.formhidden('p_validation_callback', p_validation_callback);
  htp.formhidden('p_dest_hidden_field', p_dest_hidden_field);
  htp.formhidden('p_dest_display_field',p_dest_display_field);
  htp.formhidden('p_current_value',p_current_value);
  htp.formhidden('p_start_row',p_start_row);
  htp.formhidden('p_autoquery',p_autoquery);
  htp.formhidden('p_param1',p_param1);
  htp.formhidden('p_param2',p_param2);
  htp.formhidden('p_param3',p_param3);
  htp.formhidden('p_param4',p_param4);
  htp.formhidden('p_param5',p_param5);
  htp.formhidden('p_display_key',p_display_key);

  if (p_autoquery = 'Y') then

        -- Autoquery or Display hint about selection criteria
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        htp.p('autoquery()');
        htp.p('</SCRIPT>');

  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  end if;


  wf_lov.g_define_rec.total_rows := 0;
  wf_lov.g_define_rec.add_attr1_title := null;
  wf_lov.g_define_rec.add_attr2_title := null;
  wf_lov.g_define_rec.add_attr3_title := null;
  wf_lov.g_define_rec.add_attr4_title := null;
  wf_lov.g_define_rec.add_attr5_title := null;
  wf_lov.g_value_tbl.delete;

  if (p_autoquery <> 'Y') THEN
    --<3310020:rwunderl>
    --Validating that the callback is authorized.
    if ((UPPER(p_validation_callback) = 'WFA_HTML.WF_USER_VAL') or
        (UPPER(p_validation_callback) = 'WFA_HTML_JSP.WF_USER_VAL') or
        (UPPER(p_validation_callback) = 'WF_EVENT_HTML.WF_SYSTEM_VAL') or
        (UPPER(p_validation_callback) = 'WF_EVENT_HTML.WF_EVENT_VAL') or
        (UPPER(p_validation_callback) = 'WF_EVENT_HTML.WF_AGENT_VAL') or
        (UPPER(p_validation_callback) = 'WF_EVENT_HTML.WF_SYSTEM_VAL') or
        (UPPER(p_validation_callback) = 'WF_EVENT_HTML.WF_PROCESSNAME_VAL') or
        (UPPER(p_validation_callback) = 'WF_EVENT_HTML.WF_ITEMTYPE_VAL')) then
       l_sql_stmt := 'BEGIN '||p_validation_callback||
               '(:1, :2, :3, :4, :5, :6, :7';

       --Appending any optional parameter place holders to l_sql_stmt.
       if (p_param1 is not null) then
         l_sql_stmt := l_sql_stmt||', :8';
       end if;
       if (p_param2 is not null) then
         l_sql_stmt := l_sql_stmt||', :9';
       end if;
       if (p_param3 is not null) then
         l_sql_stmt := l_sql_stmt||', :10';
       end if;
       if (p_param4 is not null) then
         l_sql_stmt := l_sql_stmt||', :11';
       end if;
       if (p_param5 is not null) then
         l_sql_stmt := l_sql_stmt||', :12';
       end if;
       l_sql_stmt := l_sql_stmt||'); END;';

       --Opening the cursor and parsing
       l_cursorName := DBMS_SQL.Open_Cursor;
       DBMS_SQL.Parse(l_cursorName, l_sql_stmt, DBMS_SQL.NATIVE);

       --Binding the mandatory parameters.
       DBMS_SQL.Bind_Variable(l_cursorName, ':1', l_call_method);
       DBMS_SQL.Bind_Variable(l_cursorName, ':2', p_lov_name);
       DBMS_SQL.Bind_Variable(l_cursorName, ':3', l_start_row);
       DBMS_SQL.Bind_Variable(l_cursorName, ':4', l_number_rows);
       DBMS_SQL.Bind_Variable(l_cursorName, ':5', l_hidden_value);
       DBMS_SQL.Bind_Variable(l_cursorName, ':6', l_display_value);
       DBMS_SQL.Bind_Variable(l_cursorName, ':7', l_result);

       --Binding the optional parameters.
       if (p_param1 is not null) then
         DBMS_SQL.Bind_Variable(l_cursorName, ':8', p_param1);
       end if;
       if (p_param2 is not null) then
         DBMS_SQL.Bind_Variable(l_cursorName, ':9', p_param2);
       end if;
       if (p_param3 is not null) then
         DBMS_SQL.Bind_Variable(l_cursorName, ':10', p_param3);
       end if;
       if (p_param4 is not null) then
         DBMS_SQL.Bind_Variable(l_cursorName, ':11', p_param4);
       end if;
       if (p_param5 is not null) then
         DBMS_SQL.Bind_Variable(l_cursorName, ':12', p_param5);
       end if;

       --Executing the cursor.
       l_cursorResult := DBMS_SQL.Execute(l_cursorName);

       --Storing out variables into local variables.
       DBMS_SQL.Variable_Value(l_cursorName, ':5', l_hidden_value);
       DBMS_SQL.Variable_Value(l_cursorName, ':6', l_display_value);
       DBMS_SQL.Variable_Value(l_cursorName, ':7', l_result);

       --Closing the cursor
       DBMS_SQL.Close_Cursor(l_cursorName);

    end if;

  else

     l_result := 0;

  end if;

  if (l_result > 0) then


       /*
       ** Print out the row count for the results in the form of
       ** Records: 1 to 15 of 25
       */
       htp.tableOpen(cborder => 'BORDER=0', cattributes => 'WIDTH="100%" SUMMARY=""');
       htp.tableRowOpen;

       wf_core.clear;
       Wf_Core.Token('START_REC', p_start_row);
       Wf_Core.Token('END_REC', TO_CHAR(TO_NUMBER(p_start_row) + wf_lov.g_value_tbl.count - 1));
       Wf_Core.Token('TOTAL_REC', '<font color="ff0000">'||TO_CHAR(wf_lov.g_define_rec.total_rows)||'</font>');

       htp.tabledata('<font size=2>' || Wf_Core.Translate('RECORD_MSG') ||
                     '</font>', cattributes=>'id=""');

       htp.tableRowClose;
       htp.tableClose;

       -- display table header of LOV
       htp.p('<TABLE width=98% bgcolor=#999999 cellpadding=2'||
             ' cellspacing=0 border=0 summary="">');
       htp.p('<TR><TD>');
       htp.p('<TABLE width=100% cellpadding=2 cellspacing=1 border=0>');

       /*
       ** Print out the header
       */
       htp.p('<TR BGColor="336699">');

       /*
       ** get the display name for the attribute
       */
  if (p_display_key = 'Y') then
       htp.p('<TH align=center valign=bottom bgcolor="336699" id="'||
             p_display_name||'">'||
             '<FONT color=#FFFFFF>'||l_display_name||
             '</TH>');
  else

    htp.p('<TH align=center valign=bottom bgcolor="336699" id="' ||
             p_display_name || '">'||
             '<FONT color=#FFFFFF>'|| p_display_name ||
             '</TH>');
  end if;
       if (wf_lov.g_define_rec.add_attr1_title IS NOT NULL) then

          htp.p('<TH align=center valign=bottom bgcolor="336699" id="' ||
                wf_lov.g_define_rec.add_attr1_title || '">'||
                '<FONT color=#FFFFFF>'|| wf_lov.g_define_rec.add_attr1_title ||
                '</TH>');

          l_ncols := l_ncols + 1;

       end if;

       if (wf_lov.g_define_rec.add_attr2_title IS NOT NULL) then

          htp.p('<TH align=center valign=bottom bgcolor="336699" id="' ||
                 wf_lov.g_define_rec.add_attr2_title || '">'||
                '<FONT color=#FFFFFF>'|| wf_lov.g_define_rec.add_attr2_title ||
                '</TH>');

          l_ncols := l_ncols + 1;

       end if;

       if (wf_lov.g_define_rec.add_attr3_title IS NOT NULL) then

          htp.p('<TH align=center valign=bottom bgcolor="336699" id="' ||
                wf_lov.g_define_rec.add_attr3_title || '">'||
                '<FONT color=#FFFFFF>'|| wf_lov.g_define_rec.add_attr3_title ||
                '</TH>');

          l_ncols := l_ncols + 1;

       end if;

       if (wf_lov.g_define_rec.add_attr4_title IS NOT NULL) then

          htp.p('<TH align=center valign=bottom bgcolor="336699" id="' ||
                wf_lov.g_define_rec.add_attr4_title || '">'||
                '<FONT color=#FFFFFF>'|| wf_lov.g_define_rec.add_attr4_title ||
                '</TH>');

          l_ncols := l_ncols + 1;

       end if;

       if (wf_lov.g_define_rec.add_attr5_title IS NOT NULL) then

          htp.p('<TH align=center valign=bottom bgcolor="336699" id="' ||
                wf_lov.g_define_rec.add_attr5_title || '">'||
                '<FONT color=#FFFFFF>'|| wf_lov.g_define_rec.add_attr5_title ||
                '</TH>');

          l_ncols := l_ncols + 1;

       end if;

       htp.tablerowclose;
       /*
       ** Loop through the data
       */
       for ii in 1..wf_lov.g_value_tbl.count loop

          -- display one row of data
          if (round(ii/2) = ii/2) then
             htp.p('<TR BGColor="ffffff">');
          else
             htp.p('<TR BGColor="99ccff">');
          end if;

     if (p_display_key='Y') then
          htp.tabledata ('<A HREF="javascript:LOV_copy('||to_char(ii)||')">'||
                         wf_lov.g_value_tbl(ii).display_value||'</A>',
                         cattributes=>'headers="' || l_display_name || '"');
     else
          htp.tabledata ('<A HREF="javascript:LOV_copy('||to_char(ii)||')">'||
                         wf_lov.g_value_tbl(ii).display_value||'</A>',
                         cattributes=>'headers="' || p_display_name || '"');
     end if;

          if (l_ncols > 0) then

             htp.tabledata (wf_lov.g_value_tbl(ii).add_attr1_value,
                            cattributes=>'headers="' ||
                                      wf_lov.g_define_rec.add_attr1_title ||
                                      '"');

          end if;
          if (l_ncols > 1) then

             htp.tabledata (wf_lov.g_value_tbl(ii).add_attr2_value,
                            cattributes=>'headers="' ||
                                      wf_lov.g_define_rec.add_attr2_title ||
                                      '"');

          end if;
          if (l_ncols > 2) then

             htp.tabledata (wf_lov.g_value_tbl(ii).add_attr3_value,
                            cattributes=>'headers="' ||
                                      wf_lov.g_define_rec.add_attr3_title ||
                                      '"');


          end if;
          if (l_ncols > 3) then

             htp.tabledata (wf_lov.g_value_tbl(ii).add_attr4_value,
                            cattributes=>'headers="' ||
                                      wf_lov.g_define_rec.add_attr4_title ||
                                      '"');


          end if;
          if (l_ncols > 4) then

             htp.tabledata (wf_lov.g_value_tbl(ii).add_attr5_value,
                            cattributes=>'headers="' ||
                                      wf_lov.g_define_rec.add_attr5_title ||
                                      '"');


          end if;

          htp.tablerowclose;

       end loop;

       htp.tableClose;

       htp.p('</TD>');
       htp.p('</TR>');
       htp.p('</TABLE>');

       htp.tableOpen(calign=>'CENTER', cborder => 'BORDER=0',
                     cattributes=>'summary=""');
       htp.tableRowOpen;

       /*
       ** Check to see if you should create the PREVIOUS button
       */
       IF  (TO_NUMBER(p_start_row) >  1) THEN

          htp.p('<TD id="">');

          /*
          ** Make sure that your not going to go back past the first
          ** record.  Otherwise subtract the query set from the start
          */
          IF (TO_NUMBER(p_start_row) < 1) THEN

              l_start_row := 1;

          ELSE

              l_start_row := TO_NUMBER(p_start_row) - 10;

          END IF;

          htp.p('<A HREF="javascript:LOV_rows('||
                  TO_CHAR(l_start_row)||
                ')">');

          htp.p('<IMG SRC="/OA_MEDIA/FNDIPRVB.gif" border=0 alt="' ||
                WF_CORE.Translate('PREVIOUS') || '"></A>');

          htp.p('<font class=button>'||wf_core.translate('PREVIOUS')||'</font>');

          htp.p('</TD>');

       END IF;


       /*
       ** Check to see if you should create the Next button
       */
       IF  (wf_lov.g_value_tbl.count = 10) THEN

        l_start_row := TO_NUMBER(p_start_row) + 10;
        if (l_start_row <= wf_lov.g_define_rec.total_rows) then

          htp.p('<TD id="">');

          htp.p('<A HREF="javascript:LOV_rows('||
                  TO_CHAR(l_start_row)||
                ')">');

          htp.p('<IMG SRC="/OA_MEDIA/FNDINXTB.gif" border=0 alt="' ||
                WF_CORE.Translate('NEXT') || '"></A>');

          htp.p('<font class=button>'||wf_core.translate('NEXT')||'</font>');

          htp.p('</TD>');
        end if;

       END IF;

       htp.tableRowClose;

       htp.tableclose;

       htp.formclose;

       -- Form to hold the display value and hidden key for the javascript
       -- LOV_copy().  This is to fix the problem when either display_value
       -- or the hidden_key contain single quotes.
       htp.formOpen(curl=>null, cmethod=>'Post',
                    cattributes=>'NAME=WF_LOV_FRM');

       -- place dummy values in index 0
       htp.formHidden('h_display', 'xxx');
       htp.formHidden('h_hidden', 'xxx');

       for ii in 1..wf_lov.g_value_tbl.count loop
         htp.formHidden('h_display',wf_lov.g_value_tbl(ii).display_value);
-- ### does not work for double quotes
-- ###             replace(wf_lov.g_value_tbl(ii).display_value, '"', '\"'));
         htp.formHidden('h_hidden',wf_lov.g_value_tbl(ii).hidden_key);
-- ###             replace(wf_lov.g_value_tbl(ii).hidden_key, '"', '\"'));
       end loop;

       htp.formClose;

       htp.bodyclose;

   end if;

exception
  when others then
    rollback;
    wf_core.context('Wf_Lov', 'Display_Lov_Details' );
    raise;
end display_lov_details;

/*
** This procedure is a combination of display_lov, display_lov_find and
** display_lov_details for new UI design with no frame
 */
procedure display_lov_no_frame
(
p_lov_name            in varchar2 ,
p_display_name        in varchar2 ,
p_validation_callback in varchar2 ,
p_dest_hidden_field   in varchar2 ,
p_dest_display_field  in varchar2 ,
p_current_value       in varchar2 ,
p_start_row           in varchar2 ,
p_autoquery           in varchar2 ,
p_language            in varchar2
) IS
ii               number := 0;
nn               number := 0;
l_total_rows     number := 0;
l_ncols          number := 0;
l_result         number := 0;
l_temp_start_row number := 0;
l_start_row      number;
l_end_row      number;
l_number_rows    number := 10;
l_call_method    varchar2(10) := 'LOV';
l_hidden_value   varchar2(240);
l_display_value  varchar2(4000) := p_current_value;
l_sql_stmt       varchar2(4000);
l_name       VARCHAR2 (320);
l_display_name       VARCHAR2 (360);
p_max_rows       number := 25;
l_from           varchar2(10);
l_to             varchar2(10);
username	 varchar2(320);

  type NameList is table of wf_roles.name%type;
  type DNameList is table of wf_roles.display_name%type;

  names NameList;
  dnames DNameList;

-- took away the function and wildcard in the cursor below,
-- instead uses the following four plsql variables.
--Bug 2342682
  criteria1  varchar2(12);
  criteria2  varchar2(12);
  criteria3  varchar2(12);
  criteria4  varchar2(12);

CURSOR c_user_lov (c_find_criteria IN VARCHAR2) IS
  select NAME, DISPLAY_NAME
    from WF_ROLES
   where (DISPLAY_NAME  like criteria1
    or    DISPLAY_NAME  like criteria2
    or    DISPLAY_NAME  like criteria3
    or    DISPLAY_NAME  like criteria4)
    and  upper(DISPLAY_NAME) like upper(c_find_criteria)||'%'
    and status <> 'INACTIVE'
  union
  select NAME, DISPLAY_NAME
    from WF_ROLES
   where ORIG_SYSTEM not in ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
                             'HZ_GROUP','CUST_CONT')
     and upper(NAME) like upper(c_find_criteria)||'%'
     and (NAME  like criteria1
      or  NAME  like criteria2
      or  NAME  like criteria3
      or  NAME  like criteria4)
     and status <> 'INACTIVE'
   order by 2;

BEGIN

  WFA_SEC.GetSession(username);

  /*
  ** Set the title for the window
  */
  htp.title(wf_core.translate('SELECT')||'&'||'nbsp;'||p_display_name);

  htp.headopen;
  -- hardcode to /OA_HTML/ for ssp
  htp.p('<link rel="stylesheet" href="/OA_HTML/PORSTYL2.css">');
--  htp.p('<link rel="stylesheet" href="'||WFA_HTML.image_loc||'PORSTYL2.css">');
  htp.p ('<SCRIPT LANGUAGE="JavaScript">');

  htp.p('function LOV_submit()
         {
            document.WF_DETAILS.p_lov_name.value = '||
               ''''||p_lov_name||''''||';
            document.WF_DETAILS.p_display_name.value = '||
               ''''||p_display_name||''''||';
            document.WF_DETAILS.p_validation_callback.value = '||
               ''''||p_validation_callback||''''||';
            document.WF_DETAILS.p_dest_hidden_field.value = '||
              ''''||p_dest_hidden_field||''''||';
            document.WF_DETAILS.p_dest_display_field.value = '||
              ''''||p_dest_display_field||''''||';
            document.WF_DETAILS.p_current_value.value =
               document.WF_FIND.p_current_value.value;
            document.WF_DETAILS.p_autoquery.value = '||
              ''''||'N'||''''||';
            document.WF_DETAILS.p_start_row.value = 1;
            document.WF_DETAILS.p_language.value = '||
               ''''||p_language||''''||';
            document.WF_DETAILS.submit();
          }');



  htp.p('function fnd_get_searchtext()
         {');
         if (p_autoquery = 'Y') then
     htp.p('if ('||p_current_value||'!= "")
             {
                 document.WF_FIND.p_current_value.value = '||
                     p_current_value||';
              }');
         end if;
       htp.p('}');

  htp.p('function fnd_launch_query()
         {
             if (document.WF_FIND.p_current_value.value == "")
             {
                alert("'||wf_core.translate('WFLOV_NO_CRITERIA')||'");
                document.WF_FIND.p_current_value.focus();
             }
             else
             {
                  LOV_submit();
              }
          }');

  if (p_autoquery = 'Y') then

     htp.p('function autoquery()
            {
               if ('||p_dest_display_field||' != "")
               {
                  document.WF_DETAILS.p_current_value.value = '||
                      p_dest_display_field||';
                  document.WF_DETAILS.p_autoquery.value = "N";
                  document.WF_DETAILS.p_start_row.value = 1;
                  document.WF_DETAILS.submit();
               }
               else
               {

                  document.WF_DETAILS.p_autoquery.value = "N";
               }
          }');
  else

      -- Javascript function to handle CD buttons
      htp.p('function LOV_rows(start_num) {
            document.WF_DETAILS.p_start_row.value = start_num;
            document.WF_DETAILS.p_autoquery.value = "N";
            document.WF_DETAILS.submit();
            }');

  end if;


  htp.p('</SCRIPT>');

  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');


  htp.headclose;

  htp.p('<body>');
  htp.p('<BR>');
  htp.formOpen(curl=>'javascript:fnd_launch_query();',
               cmethod=>'POST', cattributes=>'NAME="WF_FIND"');
  htp.p('<TABLE width=100% cellpadding=0 cellspacing=0 border=0 id="">');
  htp.p('<TR>');
  htp.p('<TD id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
  htp.p('<TD width=100% id="' || p_display_name || '"><SPAN class=header>');
  htp.p(wf_core.translate('SELECT')||'&'||'nbsp;'||p_display_name);
  htp.p('</SPAN></TD></TR>');
  htp.p('<TR><TD height=1><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif alt=""></TD>');
   htp.p('<TD height=1 bgcolor=#cccc99 id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif alt=""><BR></TD></TR>');
   htp.p('<TR><TD id=""><IMG src=/OA_MEDIA/FNDITPNT.gif width=100% height=10 alt=""></TD></TR>');
   htp.p('<TR><TD id=""><IMG src=/OA_MEDIA/FNDITPNT.gif width=45 height=1 alt=""></TD><TD width=100%></TD></TR>');

  htp.tableRowOpen;
  htp.p('<TD height=1 id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
  htp.p('<TD id=""><TABLE cellpadding=0 cellspacing=0 border=0 summary="">');
  htp.p('<TR>');
  htp.p('<TD id=""><B>'||wf_core.translate('WFLOV_SEARCH')||'</B>&'||'nbsp;<INPUT TYPE="text" NAME="p_current_value" SIZE="20" MAXLENGTH="4000">');
  htp.p ('<SCRIPT LANGUAGE="JavaScript"> fnd_get_searchtext(); </SCRIPT>');
  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  htp.p('<a href="javascript:fnd_launch_query()"><img src="'||WFA_HTML.image_loc||p_language||'/WFGOW.gif" align="absmiddle" alt="'||wf_core.translate('WFJSP_GO')||'" border="0"></a>');

--  htp.p('<a href="javascript:fnd_launch_query()"><img src="'||WFA_HTML.image_loc||icx_sec.getID(21)||'/WFGOW.gif" align="absmiddle" alt="'||wf_core.translate('WFJSP_GO')||'" border="0"></a>');

htp.p('</TD></TR></TABLE>');

  htp.p('</TD>');
  htp.p('</TR>');

-- blue separator
htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
  htp.p('<TR>');
  htp.p('<TD id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
  htp.p('<TD id=""><table width="100%" border="0" cellspacing="0" cellpadding="0" background="'||WFA_HTML.image_loc||'WFBLUES.jpg" summary="">');
  htp.p('<tr background="'||WFA_HTML.image_loc||'WFBLUES.jpg">');
  htp.p('<td height="1" background="'||WFA_HTML.image_loc||'WFBLUES.jpg" id=""><img src="'||WFA_HTML.image_loc||'WFBLUES.gif" width="6" height="1" alt=""></td></tr></table></TD>');
  htp.tableRowClose;

  htp.formClose;
  htp.formOpen(curl=>owa_util.get_owa_service_path||
                   'wf_lov.display_lov_no_frame',
             cmethod=>'POST', cattributes=>'NAME="WF_DETAILS"');

  htp.formhidden('p_lov_name', p_lov_name);
  htp.formhidden('p_display_name', p_display_name);
  htp.formhidden('p_validation_callback', p_validation_callback);
  htp.formhidden('p_dest_hidden_field', p_dest_hidden_field);
  htp.formhidden('p_dest_display_field',p_dest_display_field);
  htp.formhidden('p_current_value',p_current_value);
  htp.formhidden('p_start_row',p_start_row);
  htp.formhidden('p_autoquery',p_autoquery);
  htp.formhidden('p_language',p_language);

  if (p_autoquery = 'Y') then

        -- Autoquery or Display hint about selection criteria
        htp.p('<SCRIPT LANGUAGE="JavaScript">');
        htp.p('autoquery()');
        htp.p('</SCRIPT>');

  htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

  end if;

  wf_lov.g_define_rec.total_rows := 0;
  wf_lov.g_define_rec.add_attr1_title := null;
  wf_lov.g_define_rec.add_attr2_title := null;
  wf_lov.g_define_rec.add_attr3_title := null;
  wf_lov.g_define_rec.add_attr4_title := null;
  wf_lov.g_define_rec.add_attr5_title := null;
  wf_lov.g_value_tbl.delete;

  if (p_autoquery <> 'Y') THEN

   wf_lov.g_define_rec.add_attr1_title := wf_core.translate ('WFITD_INTERNAL_NAME');

   -- these 4 criteria variables were extracted from the sql in cursor
   -- c_user_lov.  Without doing this, the optimizer did not know to
   -- use indexes in the base tables.
   criteria1 := lower(substr(l_display_value, 1, 2))||'%';
   criteria2 := lower(substr(l_display_value, 1, 1))||
                upper(substr(l_display_value, 2, 1))||'%';
   criteria3 := initcap(substr(l_display_value, 1, 2))||'%';
   criteria4 := upper(substr(l_display_value, 1, 2))||'%';

   open c_user_lov (l_display_value);
   -- use bulk collect to improve performance, also get the count
   -- while fetching the data
   fetch c_user_lov bulk collect into names, dnames;
   close c_user_lov;

   if (names is null) then
     l_total_rows := 0;
   else
     l_total_rows := names.COUNT;
     if (l_total_rows < (to_number(p_start_row)+p_max_rows-1)) then
       l_end_row := l_total_rows;
     else
       l_end_row := to_number(p_start_row)+p_max_rows-1;
     end if;

     for ii in to_number(p_start_row)..l_end_row loop
       nn := nn + 1;
       wf_lov.g_value_tbl(nn).hidden_key      := names(ii);
       wf_lov.g_value_tbl(nn).display_value   := dnames(ii);
       wf_lov.g_value_tbl(nn).add_attr1_value := names(ii);
     end loop;
   end if;

   wf_lov.g_define_rec.total_rows := l_total_rows;

   l_result := 1;

  else

     l_result := 0;

  end if;

htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
  htp.tableRowOpen;
  htp.p('<TD id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
  if (p_autoquery='Y') then
--    htp.p('<TD class=contenttext><B>'||wf_core.translate('WFLOV_GO')||'</B></TD>');
  htp.tableRowClose;
  htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
  htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
  htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
  htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
  htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
  htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
   elsif (wf_lov.g_define_rec.total_rows=0) then
       wf_core.clear;
       wf_core.token('NAME', p_display_name);
       wf_core.token('VALUE', p_current_value);
       htp.p('<TD class=contenttext id="">'||wf_core.translate('WFLOV_NO_MATCH')||'</TD></TR>');
   elsif (wf_lov.g_define_rec.total_rows>0) then

  if (l_result > 0) then

       /*
       ** Print out the row count for the results in the form of
       ** Records: 1 to 15 of 25
       */

    htp.p('<TD class=contenttext id=""><B>'||wf_core.translate('WFLOV_CLICK')||'</B></TD>');
  htp.tableRowClose;
       htp.tableRowOpen;
  htp.p('<TD height=1 id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
       if (p_start_row is not null) then
         l_temp_start_row := to_number(p_start_row);
       end if;
         l_from := to_char(l_temp_start_row);

       if (l_temp_start_row =0) then
         l_to := TO_CHAR(l_temp_start_row + wf_lov.g_value_tbl.count);

       else
         l_to := TO_CHAR(l_temp_start_row + wf_lov.g_value_tbl.count -1);
       end if;


       htp.p('<TD align=right valign=top height=25 class=contenttext id="">');
       /*
       ** Check to see if you should create the PREVIOUS button
       */
       IF  (TO_NUMBER(p_start_row) >  1) THEN


          /*
          ** Make sure that your not going to go back past the first
          ** record.  Otherwise subtract the query set from the start
          */
          IF (TO_NUMBER(p_start_row) < 1) THEN

              l_start_row := 1;

          ELSE

              l_start_row := TO_NUMBER(p_start_row) - p_max_rows;

          END IF;

          htp.p('<IMG SRC="/OA_MEDIA/WFPREVEN.gif" align="absmiddle" border=0> alt=""');

          htp.p('<A HREF="javascript:LOV_rows('||
                  TO_CHAR(l_start_row)||
                ')">');
          htp.p(wf_core.translate('PREVIOUS')||'</A>');
      ELSE
         htp.p('<SPAN class=disabledtext><img src="/OA_MEDIA/WFPREVDI.gif"  align="absmiddle" border="0" alt="' || WF_CORE.Translate('PREVIOUS') || '">&'||'nbsp;'||wf_core.translate('PREVIOUS')||'</SPAN>');

       END IF;
         Wf_Core.Clear;
         Wf_Core.Token('START_REC', l_from);
         Wf_Core.Token('END_REC', l_to);
         Wf_Core.Token('TOTAL_REC', TO_CHAR(wf_lov.g_define_rec.total_rows));
         htp.p('<span class=contenttext><B>'||Wf_Core.Translate('PAGE_MSG')||'</B></span>');

       /*
       ** Check to see if you should create the Next button
       */
       IF (p_start_row + p_max_rows - 1 < wf_lov.g_define_rec.total_rows) THEN
--       IF  (wf_lov.g_value_tbl.count = p_max_rows) THEN

          l_start_row := TO_NUMBER(p_start_row) + p_max_rows;

           htp.p('<A HREF="javascript:LOV_rows('||
                  TO_CHAR(l_start_row)||
                ')">');

          htp.p(wf_core.translate('NEXT')||'</A>');

          htp.p('<IMG SRC="/OA_MEDIA/WFNEXTEN.gif"  align="absbottom" border="0" alt="' || WF_CORE.Translate('NEXT') || '">');

     ELSE
         htp.p('<SPAN class=disabledtext><img src="/OA_MEDIA/WFNEXTDI.gif"  align="absbottom" border="0" alt="' || WF_CORE.Translate('NEXT') || '">&'||'nbsp;'||wf_core.translate('NEXT')||'</SPAN>');

       END IF;

       END IF;
          htp.p('</TD>');

       htp.tableRowClose;


       -- display table header of LOV
       htp.p('<TR>');
  htp.p('<TD height=1 id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
       htp.p('<TD id="">');
      htp.p('<table width="100%" border="0" cellspacing="1" cellpadding="5">');
      htp.p('<tr>');


       /*
       ** Print out the header
       */

       /*
       ** get the display name for the attribute
       */
       htp.p('<TD class=tableheader id="">&'||'nbsp</TD>');

       htp.p('<TD class=tableheader id="">'|| p_display_name ||
             '</TD>');

       if (wf_lov.g_define_rec.add_attr1_title IS NOT NULL) then

       htp.p('<TD class=tableheader id="">'|| wf_lov.g_define_rec.add_attr1_title||
             '</TD>');

          l_ncols := l_ncols + 1;

       end if;

       if (wf_lov.g_define_rec.add_attr2_title IS NOT NULL) then

       htp.p('<TD class=tableheader id="">'|| wf_lov.g_define_rec.add_attr2_title||
             '</TD>');

          l_ncols := l_ncols + 1;

       end if;

       if (wf_lov.g_define_rec.add_attr3_title IS NOT NULL) then

       htp.p('<TD class=tableheader id="">'|| wf_lov.g_define_rec.add_attr3_title||
             '</TD>');

          l_ncols := l_ncols + 1;

       end if;

       if (wf_lov.g_define_rec.add_attr4_title IS NOT NULL) then

       htp.p('<TD class=tableheader id="">'|| wf_lov.g_define_rec.add_attr4_title||
             '</TD>');

          l_ncols := l_ncols + 1;

       end if;

       if (wf_lov.g_define_rec.add_attr5_title IS NOT NULL) then

       htp.p('<TD class=tableheader id="">'|| wf_lov.g_define_rec.add_attr5_title||
             '</TD>');
          l_ncols := l_ncols + 1;

       end if;

       htp.tablerowclose;
       /*
       ** Loop through the data
       */
       for ii in 1..wf_lov.g_value_tbl.count loop

          -- display one row of data

         htp.p('<TD class=tabledata VALIGN=CENTER ALIGN=LEFT id=""><A HREF="javascript:'||
                          p_dest_display_field||'='||''''||
                          replace(wf_lov.g_value_tbl(ii).display_value,
                          '''','\047')||''''||
                          ';'||p_dest_hidden_field||'='||''''||
                          replace(wf_lov.g_value_tbl(ii).hidden_key,
                          '''','\047')||''''||
                          ';parent.self.close();">'||wf_core.translate('SELECT')||'</A></TD><TD class=tabledata VALIGN=CENTER ALIGN=LEFT id="">'||wf_lov.g_value_tbl(ii).display_value||'</TD>');

          if (l_ncols > 0) then
             htp.p('<TD class=tabledata VALIGN=CENTER ALIGN=LEFT id="">'||wf_lov.g_value_tbl(ii).add_attr1_value||'</TD>');

          end if;
          if (l_ncols > 1) then
             htp.p('<TD class=tabledata VALIGN=CENTER ALIGN=LEFT id="">'||wf_lov.g_value_tbl(ii).add_attr2_value||'</TD>');

          end if;
          if (l_ncols > 2) then
              htp.p('<TD class=tabledata VALIGN=CENTER ALIGN=LEFT id="">'||wf_lov.g_value_tbl(ii).add_attr3_value||'</TD>');

          end if;

          if (l_ncols > 3) then
             htp.p('<TD class=tabledata VALIGN=CENTER ALIGN=LEFT id="">'||wf_lov.g_value_tbl(ii).add_attr4_value||'</TD>');
          end if;

          if (l_ncols > 4) then
             htp.p('<TD class=tabledata VALIGN=CENTER ALIGN=LEFT id="">'||wf_lov.g_value_tbl(ii).add_attr5_value||'</TD>');

          end if;

          htp.tablerowclose;

       end loop;

       htp.tableClose;

       htp.p('</TD>');
       htp.p('</TR>');

     if (wf_lov.g_value_tbl.count > 5) then
       htp.tableRowOpen;
  htp.p('<TD id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
       htp.p('<TD align=right valign=top height=25 class=contenttext id="">');
       /*
       ** Check to see if you should create the PREVIOUS button
       */
       IF  (TO_NUMBER(p_start_row) >  1) THEN


          /*
          ** Make sure that your not going to go back past the first
          ** record.  Otherwise subtract the query set from the start
          */
          IF (TO_NUMBER(p_start_row) < 1) THEN

              l_start_row := 1;

          ELSE

              l_start_row := TO_NUMBER(p_start_row) - p_max_rows;

          END IF;

          htp.p('<IMG SRC="/OA_MEDIA/WFPREVEN.gif" align="absmiddle" border=0 alt="' || WF_CORE.Translate('PREVIOUS') || '">');

         htp.p('<A HREF="javascript:LOV_rows('||
                  TO_CHAR(l_start_row)||
                ')">');

          htp.p(wf_core.translate('PREVIOUS')||'</A>');
      ELSE
         htp.p('<SPAN class=disabledtext><img src="/OA_MEDIA/WFPREVDI.gif"  align="absmiddle" border="0">&'||'nbsp;'||wf_core.translate('PREVIOUS')||'</SPAN>');

       END IF;


         Wf_Core.Clear;
         Wf_Core.Token('START_REC', l_from);
         Wf_Core.Token('END_REC', l_to);
         Wf_Core.Token('TOTAL_REC', TO_CHAR(wf_lov.g_define_rec.total_rows));
         htp.p('<span class=contenttext><B>'||Wf_Core.Translate('PAGE_MSG')||'</B></span>');

       /*
       ** Check to see if you should create the Next button
       */
       IF  (wf_lov.g_value_tbl.count = p_max_rows) THEN


          l_start_row := TO_NUMBER(p_start_row) + p_max_rows;


          htp.p('<A HREF="javascript:LOV_rows('||
                  TO_CHAR(l_start_row)||
                ')">');

          htp.p(wf_core.translate('NEXT')||'</A>');

           htp.p('<IMG SRC="/OA_MEDIA/WFNEXTEN.gif"  align="absbottom" border="0" alt="' || WF_CORE.Translate('NEXT') || '">');
      ELSE
         htp.p('<SPAN class=disabledtext><img src="/OA_MEDIA/WFNEXTDI.gif"  align="absbottom" border="0" alt="' || WF_CORE.Translate('NEXT') || '">&'||
'nbsp;'||wf_core.translate('NEXT')||'</SPAN>');

       END IF;

          htp.p('</TD>');
       htp.tableRowClose;
      end if;
    end if; -- if (wf_lov.g_define_rec.total_rows=0)
--       htp.tableclose;

    -- blue separator
 --     htp.p('<table width="100%" border="0" cellspacing="1" cellpadding="5">');
htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
      htp.p('<TR>');
      htp.p('<TD id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
      htp.p('<TD id=""><table width="100%" border="0" cellspacing="0" cellpadding="0" background="'||WFA_HTML.image_loc||'WFBLUES.jpg">');
      htp.p('<tr background="'||WFA_HTML.image_loc||'WFBLUES.jpg">');
      htp.p('<td height="1" id="" background="'||WFA_HTML.image_loc||'WFBLUES.jpg"><img src="'||WFA_HTML.image_loc||'WFBLUES.gif" width="6" height="1"></td></tr></table></TD>');
      htp.tableRowClose;
htp.p('<TR><TD class=contenttext colspan=1 id="">&nbsp</TD></TR>');
--      htp.p('<table width="100%" border="0" cellspacing="1" cellpadding="5">');
      htp.p('<tr valign=baseline>');
     htp.p('<TD height=1 valign=bottom id=""><IMG src='||WFA_HTML.image_loc||'FNDITPNT.gif width=15 height=1 alt=""></TD>');
      htp.p('<td align=right valign=bottom id=""><a href="javascript:parent.self.close();"><img src="'||WFA_HTML.image_loc||p_language||'/WFCANCEL.gif" align="absmiddle" alt="'||wf_core.translate('CANCEL')||'" border="0"></a></td></tr></table>');
--      htp.p('<td align=right valign=bottom><a href="javascript:parent.self.close();"><img src="'||WFA_HTML.image_loc||icx_sec.getID(21)||'/WFCANCEL.gif" align="absmiddle" alt="'||wf_core.translate('CANCEL')||'" border="0"></a></td></tr></table>');
  htp.formClose;
  htp.bodyclose;
  htp.htmlclose;


exception
  when others then
    rollback;
    wf_core.context('Wf_Lov', 'display_lov_no_frame');
    wf_lov.error;

end display_lov_no_frame;

/*
** Bug 1380107. Avoid problem with multibyte characters in ssp5 url
** getting corrupted. The URL is created when the select button on the
** right of the reassign-to field is clicked in the notification
** details -> Reassign page. Error only occurs with Netscape 4.7X.
** This procedure is created to workaround the issue where
** multibyte characters for the word User (Japanese) are garbled.
** We used to call wfcontext.getMessage("WFA_FIND_USER") in WFReassign.jsp
** Pass in the non-translated key p_display_name_key instead
** of the translated multibyte value in p_display_name.
** This routine will use the key to find the translated value and call
** the procedure display_lov_no_frame.
 */
procedure display_lov_no_frame_key
(
p_lov_name            in varchar2 ,
p_display_name_key    in varchar2 ,
p_validation_callback in varchar2 ,
p_dest_hidden_field   in varchar2 ,
p_dest_display_field  in varchar2 ,
p_current_value       in varchar2 ,
p_start_row           in varchar2 ,
p_autoquery           in varchar2 ,
p_language            in varchar2
) IS

l_display_name  varchar2(4000) := NULL;
BEGIN

-- From wf_core.get_message
  begin
    select TEXT
    into l_display_name
    from WF_RESOURCES
    where TYPE = 'WFTKN'
       and NAME = p_display_name_key
       and LANGUAGE = p_language
       and NAME not in ('WF_VERSION','WF_SYSTEM_GUID',
        'WF_SYSTEM_STATUS','WF_SCHEMA');
  exception
    when NO_DATA_FOUND then
      select TEXT
      into l_display_name
      from WF_RESOURCES
      where TYPE = 'WFTKN'
        and NAME = p_display_name_key
        and LANGUAGE = 'US'
        and NAME in ('WF_VERSION','WF_SYSTEM_GUID',
          'WF_SYSTEM_STATUS','WF_SCHEMA');
  end;

  display_lov_no_frame(p_lov_name, l_display_name,
    p_validation_callback, p_dest_hidden_field,
    p_dest_display_field, p_current_value, p_start_row,
    p_autoquery, p_language);

exception
  when others then
    rollback;
    wf_core.context('Wf_Lov', 'display_lov_no_frame_key');
    wf_lov.error;

end display_lov_no_frame_key;


end WF_LOV;

/
