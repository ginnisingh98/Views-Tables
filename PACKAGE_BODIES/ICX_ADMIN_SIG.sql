--------------------------------------------------------
--  DDL for Package Body ICX_ADMIN_SIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ADMIN_SIG" as
/* $Header: ICXADSIB.pls 120.0 2005/10/07 12:08:52 gjimenez noship $ */

procedure help_win_script (
defHlp in varchar2 default null,
language_code in varchar2 default null,
application_short_name in varchar2 default 'ICX') is

v_language_code varchar2(30);
l_target        varchar2(240)  := defhlp;
l_url           varchar2(4000) := NULL;
l_session_id    number;
l_application_short_name  varchar2(30) := 'ICX';
l_target_type   varchar2(20) := 'TARGET';

begin


   /*
   ** Get the default language if one has not been provided
   */
   if language_code is null then
       v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   else
       v_language_code := language_code;
   end if;

   /*
   ** If a help file has been passed in then try to get the
   ** application short name which is required by fnd_web.help
   ** If you can't find the application then ignore the file
   ** and just show the default ICX help page.
   */
   if  application_short_name is null then

     /*
     ** Get the the current session id
     */
     l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

     /*
     ** Get the application short name from the function prefix
     */
     begin

     select ffunc.function_name
     into   l_application_short_name
     from   fnd_form_functions_vl ffunc,
            icx_sessions icx
     where  icx.session_id = l_session_id
     and    icx.function_id = ffunc.function_id;

     exception
     when no_data_found then
        /*
        ** If you can't find the application then ignore the file
        ** and just show the default ICX help page.
        */
        l_application_short_name := 'ICX';
     when others then
        raise;
     end;

      l_application_short_name :=
            SUBSTR(l_application_short_name, 1,
            INSTR(l_application_short_name , '_') - 1);

   else

       l_application_short_name := application_short_name;

   end if;


   /*
   ** If no target has been specified then get the default ICX Help window
   */
   if l_target is null then

      l_target := 'icxhlpad.htm';
      l_target_type  := 'FILE';

   else

      /*
      ** check to see if the target is a filename rather than a
      ** target name.  If it is then strip off the prefix path
      ** and just leave the filename
      */
      if (INSTR(l_target, '/OA_DOC/') > 0) then

         l_target_type := 'FILE';

         while (INSTR(l_target, '/') > 0) loop

            l_target := SUBSTR(l_target, INSTR(l_target, '/') + 1);

         end loop;

         /*
         ** Strip off any parameters at the end of the filename
         */
         l_target := SUBSTR(l_target, 1, INSTR(l_target, '?') - 1);

      end if;

   end if;

   /*
   ** Get the proper syntax for opening the help window
   */
   l_url := fnd_help.get_url(l_application_short_name, l_target,
                             FALSE, l_target_type);

   /*
   ** Create the link syntax
   */
   htp.p('function help_window(){
	     help_win = window.open("'||l_url||'", "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=600,height=500")}');

end;

--************************************************************************
--                  icx_fnd_help
--************************************************************************

function icx_fnd_help ( defHlp           in varchar2 default null,
                        p_application_id in number default 178) return varchar2 is

l_url           varchar2(4000) := NULL;
l_target_type   varchar2(20) := 'TARGET';
l_application_short_name varchar2(50) := NULL;

begin

  begin
    select application_short_name
      into l_application_short_name
      from fnd_application
     where application_id = p_application_id;
  exception
    when no_data_found then
      /*
      ** If you can't find the application then ignore the file
      ** and just show the default ICX help page.
      */
      l_application_short_name := 'ICX';
    when others then
      raise;
  end;

  l_url := fnd_help.get_url(l_application_short_name, defHlp,
                             FALSE, l_target_type);

  return l_url;

end icx_fnd_help;


--Return the proper syntax for generating the help_win javascript function
--but don't pipe it out to htp.  This is used by BIS in their reports.
function help_win_syntax (
defHlp in varchar2 default null,
language_code in varchar2 default null,
application_short_name in varchar2 default 'ICX') return VARCHAR2 is

v_language_code varchar2(30);
l_target        varchar2(240)  := defhlp;
l_url           varchar2(4000) := NULL;
l_session_id    number;
l_application_short_name  varchar2(30) := 'ICX';
l_target_type   varchar2(20) := 'TARGET';
l_syntax        varchar2(32000) := NULL;

begin


   /*
   ** Get the default language if one has not been provided
   */
   if language_code is null then
       v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   else
       v_language_code := language_code;
   end if;

   /*
   ** If a help file has been passed in then try to get the
   ** application short name which is required by fnd_web.help
   ** If you can't find the application then ignore the file
   ** and just show the default ICX help page.
   */
   if  application_short_name is null then

     /*
     ** Get the the current session id
     */
     l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

     /*
     ** Get the application short name from the function prefix
     */
     begin

     select ffunc.function_name
     into   l_application_short_name
     from   fnd_form_functions_vl ffunc,
            icx_sessions icx
     where  icx.session_id = l_session_id
     and    icx.function_id = ffunc.function_id;

     exception
     when no_data_found then
        /*
        ** If you can't find the application then ignore the file
        ** and just show the default ICX help page.
        */
        l_application_short_name := 'ICX';
     when others then
        raise;
     end;

      l_application_short_name :=
            SUBSTR(l_application_short_name, 1,
            INSTR(l_application_short_name , '_') - 1);

   else

       l_application_short_name := application_short_name;

   end if;


   /*
   ** If no target has been specified then get the default ICX Help window
   */
   if l_target is null then

      l_target := 'icxhlpad.htm';
      l_target_type  := 'FILE';

   else

      /*
      ** check to see if the target is a filename rather than a
      ** target name.  If it is then strip off the prefix path
      ** and just leave the filename
      */
      if (INSTR(l_target, '/OA_DOC/') > 0) then

         l_target_type := 'FILE';

         while (INSTR(l_target, '/') > 0) loop

            l_target := SUBSTR(l_target, INSTR(l_target, '/') + 1);

         end loop;

         /*
         ** Strip off any parameters at the end of the filename
         */
         l_target := SUBSTR(l_target, 1, INSTR(l_target, '?') - 1);

      end if;

   end if;

   /*
   ** Get the proper syntax for opening the help window
   */
   l_url := fnd_help.get_url(l_application_short_name, l_target,
                             FALSE, l_target_type);

   /*
   ** Create the link syntax
   */
   l_syntax := 'function help_window(){
	     help_win = window.open("'||l_url||'", "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=600,height=500")}';

   return (l_syntax);

end;

function background (language_code in varchar2 default null) return varchar2 is

v_language_code varchar2(30);

begin

/* remove this commented code if the dependent code works fine.
   OA_MEDIA should no longer be made of language specific directories.
*/
--if language_code is null then
--      v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
--  else
--    v_language_code := language_code;
--end if;
    return '/OA_MEDIA/ICXBCKGR.jpg';
end;


procedure Openheader(defStatus in varchar2 default null, extraOnLoad in varchar2 default null, language_code in varchar2 default null) is

v_oa_web varchar2(80);
-- v_language_code varchar2(30);

begin

/* remove this commented code if the dependent code works fine.
   OA_MEDIA should no longer be made of language specific directories.
   Also changed the calls to icx_admin_sig.background so v_language_code
   is not passed as a parameter anymore.
*/
--if language_code is null then
--      v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
--  else
--    v_language_code := language_code;
--end if;

    if defStatus is null then
       fnd_message.set_name('ICX', 'ICX_OA_WEB');
       v_oa_web := fnd_message.get;

	if extraOnLoad is null then
          htp.bodyOpen(icx_admin_sig.background,'onLoad="self.defaultStatus='''||v_oa_web||'''; return true"');
        else
            htp.bodyOpen(icx_admin_sig.background,'onLoad="self.defaultStatus='''||v_oa_web||'''; '||extraOnLoad||'; return true"');
        end if;

     else

      if extraOnLoad is null then
      htp.bodyOpen(icx_admin_sig.background,'onLoad="self.defaultStatus='''||defStatus||'''; return true"');
      else
      htp.bodyOpen(icx_admin_sig.background,'onLoad="self.defaultStatus='''||defStatus||'''; '||extraOnLoad||'; return true"');

      end if;
      end if;

      htp.tableOpen('','','','','CELLSPACING=0 CELLPADDING=0');
      htp.tableRowOpen('CENTER','BOTTOM');
      htp.tableData(htf.img(curl => '/OA_MEDIA/FNDLOGOS.gif', cattributes => 'BORDER=0'),'CENTER','','','','','VALIGN="MIDDLE"');
      htp.p('<TD WIDTH=1000></TD>');

end;

procedure Closeheader (language_code in varchar2 default null) is

url	varchar2(240) := null;
c_title  varchar2(80);
c_prompts icx_util.g_prompts_table;
--v_language_code varchar2(30);

begin
/* remove this commented code if the dependent code works fine.
   OA_MEDIA should no longer be made of language specific directories.
*/
--if language_code is null then
--      v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
--  else
--   v_language_code := language_code;
--end if;

	icx_util.getprompts(601, 'ICX_HEADER', c_title, c_prompts);
	---htp.p('<td width=50></td>');
	 htp.tableData(htf.anchor('OracleApps.DMM',htf.img('/OA_MEDIA/FNDSMENU.gif',
		'CENTER',icx_util.replace_alt_quotes(c_prompts(3)),'','BORDER=0 WIDTH=55 HEIGHT=38'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_prompts(3))||''';return true"'));

	 htp.tableData(htf.anchor('icx_admin_sig.Startover', htf.img('/OA_MEDIA/FNDSLOGF.gif',
		'CENTER',icx_util.replace_alt_quotes(c_prompts(4)),'','BORDER=0 WIDTH=55 HEIGHT=38'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_prompts(4))||''';return true"'));

            htp.tableData(htf.anchor('javascript:help_window()',htf.img('/OA_MEDIA/FNDSHELP.gif',
		'CENTER',icx_util.replace_alt_quotes(c_prompts(5)),'','BORDER=0 WIDTH=46 HEIGHT=38'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_prompts(5))||''';return true"'));
    htp.tableRowClose;
    htp.tableClose;
    htp.line;
end;


procedure Closeheader2 (language_code in varchar2 default null) is

url 	varchar2(240) := null;
c_title varchar2(80);
c_prompts icx_util.g_prompts_table;

--v_language_code varchar2(30);

begin
/* remove this commented code if the dependent code works fine.
   OA_MEDIA should no longer be made of language specific directories.
*/
--  if language_code is null then
--	v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
--  else
--   v_language_code := language_code;
--  end if;

	icx_util.getprompts(601, 'ICX_HEADER', c_title, c_prompts);

        htp.tableData(htf.anchor('icx_admin_sig.Startover', htf.img('/OA_MEDIA/ICXTOP.gif',
		'CENTER',icx_util.replace_alt_quotes(c_prompts(4)),'','BORDER=0 WIDTH=55 HEIGHT=28'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_prompts(4))||''';return true"'));

            htp.tableData(htf.anchor('javascript:help_window()',htf.img('/OA_MEDIA/ICXHELP.gif',
		'CENTER',icx_util.replace_alt_quotes(c_prompts(5)),'','BORDER=0 WIDTH=46 HEIGHT=28'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_prompts(5))||''';return true"'));

	htp.tableData(htf.img('/OA_MEDIA/ICXRIGHT.gif','','','','BORDER=0 HEIGHT=28 WIDTH=20'),'CENTER','','','','','VALIGN="MIDDLE"');

    htp.tableRowClose;
    htp.tableClose;
    htp.line;
end;

procedure toolbar (language_code in varchar2 default null,
		   disp_find	 in varchar2 default null,
		   disp_mainmenu in varchar2 default 'Y',
		   disp_wizard   in varchar2 default 'N',
		   disp_help     in varchar2 default 'Y',
		   disp_export   in varchar2 default null,
		   disp_exit     in varchar2 default 'Y') is

url 	varchar2(240) := null;
c_title varchar2(80);
c_prompts icx_util.g_prompts_table;
v_language_code varchar2(30);

begin

/* remove this commented code if the dependent code works fine.
   OA_MEDIA should no longer be made of language specific directories.
   Also changed the calls to icx_admin_sig.background so v_language_code
   is not passed as a parameter anymore.
*/

--    if language_code is null then
--        v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
--    else
--        v_language_code := language_code;
--    end if;

    if substr(icx_sec.g_mode_code,1,3) = '115'
    then
        htp.p('<BODY BGCOLOR="#CCCCCC">');
        icx_plug_utilities.toolbar(p_text => '',
                       p_language_code => language_code,
                       p_disp_find     => disp_find,
                       p_disp_mainmenu => disp_mainmenu,
                       p_disp_wizard   => disp_wizard,
                       p_disp_help     => disp_help,
                       p_disp_export   => disp_export,
                       p_disp_exit     => disp_exit);
    elsif icx_sec.g_mode_code = 'OBIS'
    then
        htp.p('<BODY>');
        icx_plug_utilities.toolbar(p_text => '',
                       p_language_code => language_code,
                       p_disp_find     => disp_find,
                       p_disp_mainmenu => disp_mainmenu,
                       p_disp_wizard   => disp_wizard,
                       p_disp_help     => disp_help,
                       p_disp_export   => disp_export,
                       p_disp_exit     => disp_exit);
    else

    htp.bodyOpen(icx_admin_sig.background);

    htp.tableOpen('','','','','CELLSPACING=0 CELLPADDING=0 BORDER=0');

    htp.tableRowOpen('CENTER','BOTTOM');
    htp.tableData(htf.img(curl => '/OA_MEDIA/FNDLOGOS.gif', cattributes => 'BORDER=0'),
		'CENTER','','','','','VALIGN="MIDDLE"');
    htp.p('<TD WIDTH=1000></TD>');

    icx_util.getprompts(601, 'ICX_HEADER', c_title, c_prompts);

    htp.p('<TD>');
/*
** inner table for icons
*/
    htp.tableOpen(cattributes => 'border=0 cellspacing=0 cellpadding=0');

    htp.tableRowOpen(calign => 'CENTER');

    if (disp_wizard = 'Y') then
        htp.tableData(htf.anchor('javascript:doWizard()',
		htf.img('/OA_MEDIA/FNDSWZRD.gif','CENTER',
			icx_util.replace_alt_quotes(c_prompts(1)),'',
			'BORDER=0 '),'',
			'onMouseOver="window.status=''' ||
			icx_util.replace_onMouseOver_quotes(c_prompts(1))||
			''';return true"'));
    end if;

    if (disp_export is not null) then
        htp.p('<FORM ACTION="OracleON.csv" METHOD="POST" NAME="exportON">');
        htp.formHidden('S',icx_call.encrypt2(disp_export));
        htp.p('</FORM>');
        htp.tableData(htf.anchor('javascript:document.exportON.submit()',
                htf.img('/OA_MEDIA/FNDSEXPT.gif','CENTER',
                        icx_util.replace_alt_quotes(c_prompts(6)),'',
                        'BORDER=0 '),'',
                        'onMouseOver="window.status=''' ||
                        icx_util.replace_onMouseOver_quotes(c_prompts(6))||
                        ''';return true"'));
    end if;

    if (disp_find is not null) then
        htp.tableData(htf.anchor(disp_find,
		htf.img('/OA_MEDIA/FNDSFIND.gif','CENTER',
			icx_util.replace_alt_quotes(c_prompts(2)),'',
			'BORDER=0 '),'',
			'onMouseOver="window.status=''' ||
			icx_util.replace_onMouseOver_quotes(c_prompts(2))||
			''';return true"'));
    end if;

    if (disp_wizard = 'Y' or disp_find is not null or disp_export is not null) then
	htp.p('<TD WIDTH=50></TD>');
    end if;

    if (disp_mainmenu = 'Y' and icx_sec.g_mode_code <> 'SLAVE') then
    	htp.tableData(htf.anchor('OracleApps.DMM',
		htf.img('/OA_MEDIA/FNDSMENU.gif','CENTER',
			icx_util.replace_alt_quotes(c_prompts(3)),'',
			'BORDER=0 '),'',
			'onMouseOver="window.status=''' ||
			icx_util.replace_onMouseOver_quotes(c_prompts(3))
			||''';return true" TARGET="_top"'));
    end if;

    if (disp_exit = 'Y' and icx_sec.g_mode_code <> 'SLAVE') then
        htp.tableData(htf.anchor('icx_admin_sig.Startover',
		htf.img('/OA_MEDIA/FNDSLOGF.gif','CENTER',
		        icx_util.replace_alt_quotes(c_prompts(4)),'','
		        BORDER=0 '),'','
		        onMouseOver="window.status=''' ||
		        icx_util.replace_onMouseOver_quotes(c_prompts(4)) ||
		        ''';return true"'));
    end if;

    if (disp_help = 'Y') then
        htp.tableData(htf.anchor('javascript:help_window()',
		htf.img('/OA_MEDIA/FNDSHELP.gif','CENTER',
			icx_util.replace_alt_quotes(c_prompts(5)),'',
			'BORDER=0 '),'',
			'onMouseOver="window.status=''' ||
			icx_util.replace_onMouseOver_quotes(c_prompts(5))||
			''';return true"'));
    end if;

    htp.tableRowClose;

    htp.tableRowOpen(calign => 'CENTER', cvalign => 'TOP');

    if (disp_wizard = 'Y') then
        htp.tableData(cvalue => htf.anchor(curl => 'javascript:doWizard()',
		      ctext => '<FONT SIZE=2 COLOR=#000000>'||c_prompts(1)||'</FONT>',
		      cattributes => 'onMouseOver="window.status=''' || icx_util.replace_onMouseOver_quotes(c_prompts(1))|| ''';return true"'),
  		      calign=> 'CENTER');
    end if;

    if (disp_export is not null) then
        htp.tableData(cvalue => htf.anchor(curl => 'javascript:document.exportON.submit()',
                      ctext => '<FONT SIZE=2 COLOR=#000000>'||c_prompts(6)||'</FONT>',
                      cattributes => 'onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_prompts(6))||''';return true"'),
                      calign=> 'CENTER');
    end if;

    if (disp_find is not null) then
        htp.tableData(cvalue => htf.anchor(curl => disp_find,
			    ctext => '<FONT SIZE=2 COLOR=#000000>'||
				     c_prompts(2) ||
				 '</FONT>',
			    cattributes => 'onMouseOver="window.status=''' || icx_util.replace_onMouseOver_quotes(c_prompts(2))|| ''';return true"'),
			    calign=> 'CENTER');
    end if;

    if (disp_wizard = 'Y' or disp_find is not null or disp_export is not null) then
        htp.p('<TD WIDTH=50></TD>');
    end if;

    if (disp_mainmenu = 'Y' and icx_sec.g_mode_code <> 'SLAVE') then
    	htp.tableData(cvalue => htf.anchor(curl => 'OracleApps.DMM',
			    ctext => '<FONT SIZE=2 COLOR=#000000>'||
				     c_prompts(3) ||
				 '</FONT>',
			    cattributes => 'onMouseOver="window.status=''' || icx_util.replace_onMouseOver_quotes(c_prompts(3))|| ''';return true" TARGET="_top"'),
			    calign=> 'CENTER');
    end if;

    if (disp_exit = 'Y' and icx_sec.g_mode_code <> 'SLAVE') then
        htp.tableData(cvalue => htf.anchor(curl => 'icx_admin_sig.Startover',
			    ctext => '<FONT SIZE=2 COLOR=#000000>'||
				     c_prompts(4)
					 || '</FONT>',
			    cattributes => 'onMouseOver="window.status=''' || icx_util.replace_onMouseOver_quotes(c_prompts(4))|| ''';return true" TARGET="_top"'),
			    calign=> 'CENTER');
    end if;

    if (disp_help = 'Y') then
        htp.tableData(cvalue => htf.anchor(curl => 'javascript:help_window()',
			    ctext => '<FONT SIZE=2 COLOR=#000000>'||
				     c_prompts(5)
					 || '</FONT>',
			    cattributes => 'onMouseOver="window.status=''' || icx_util.replace_onMouseOver_quotes(c_prompts(5))|| ''';return true"'),
			    calign=> 'CENTER');
    end if;
    htp.tableRowClose;

    htp.tableClose;
    htp.p('</TD>');
/**
** close outer row and table
*/
    htp.tableRowClose;
    htp.tableClose;

    end if; -- 'OBIS'

end toolbar;


procedure Startover (language_code in varchar2 default null)is

l_url        varchar2(2000) := null;
/*
l_url1       varchar2(2000) := null;
l_url2       varchar2(2000) := null;
l_mode_code  varchar2(30);
l_session_id number;
l_defined    boolean;
l_login_id NUMBER; -- added for audits -- mputman
*/

begin

-- 2802333 nlbarlow
l_url := fnd_sso_manager.getLogoutUrl;

owa_util.mime_header('text/html', FALSE);

owa_util.redirect_url(l_url);

owa_util.http_header_close;

/*
        l_session_id := icx_sec.getsessioncookie;
-- bug 2335995 l_session_id is not null
        if ((l_session_id is not null) and (l_session_id > -1))
        then
          update icx_sessions
             set    disabled_flag = 'Y'
             where  session_id = l_session_id;
          commit;

          select HOME_URL, MODE_CODE, Login_id
             into   l_url, l_mode_code, l_login_id
             from   ICX_SESSIONS
             where  SESSION_ID = l_session_id; -- mputman added (l_)login_id for call to fnd_signon.
          IF l_login_id IS NOT NULL THEN
             fnd_signon.audit_end(l_login_id); -- mputman added to end audit session and resps.
          END IF;

        else
          l_url := '';
          l_mode_code := '';
        end if;

        if l_mode_code = '115X'
        then

          select HOME_URL
          into   l_url1
          from   ICX_PARAMETERS;

          fnd_profile.get_specific(name_z    => 'APPS_PORTAL',
                                   val_z     => l_url2,
                                   defined_z => l_defined );

          if l_url1 is null
          then
            l_url1 := wfa_html.conv_special_url_chars(l_url2);
          else
            l_url1 := wfa_html.conv_special_url_chars(l_url1);
          end if;

          l_url := replace(l_url2,'home','wwsec_app_priv.logout?p_done_url='||l_url1);

        end if;

	if l_url is null
	then
	    select HOME_URL
	    into   l_url
	    from   ICX_PARAMETERS;
	end if;
        owa_util.mime_header('text/html', FALSE);

        icx_sec.sendsessioncookie(-1);

        owa_util.redirect_url(l_url);

        owa_util.http_header_close;
*/

end;

procedure footer is
begin
/*
    htp.address('Please send any questions or comments to '
         ||htf.mailto('webapps@us.oracle.com','WebApps@us.oracle.com'));
*/
    htp.bodyClose;
    htp.htmlClose;
end;


procedure error_screen (title varchar2,
                        language_code in varchar2 default null,
			api_msg_count in number default null,
			api_msg_data in varchar2 default null) is

c_prompts icx_util.g_prompts_table;
c_title varchar2(80);
v_language_code varchar2(30);

begin
  -- add api messages to icx error page table
  if api_msg_count is not null then
    if api_msg_count = 1 then
      fnd_message.set_encoded(api_msg_data);
      icx_util.add_error(fnd_message.get);
    else
      for i in 1..api_msg_count loop
	fnd_message.set_encoded(fnd_msg_pub.Get);
	icx_util.add_error(fnd_message.get);
      end loop;
    end if;
  end if;

  if language_code is null then
    v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  else
   v_language_code := language_code;
  end if;
    icx_util.getprompts(601, 'ICX_ERR_SCRN', c_title, c_prompts);
    htp.htmlOpen;
    htp.headOpen;

    icx_util.copyright;

/*
    htp.p('<SCRIPT LANGUAGE="JavaScript">');
    htp.p('<!-- Hide from old browsers');

    icx_admin_sig.help_win_script('',v_language_code);

    htp.p('// -->');
    htp.p('</SCRIPT>');
*/

    htp.title(c_title);
    htp.headClose;

    icx_admin_sig.toolbar(language_code => v_language_code,
			  disp_help => 'N');
    icx_util.error_page_print;
    htp.nl;
    htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData(htf.anchor('javascript:history.back()',htf.img('/OA_MEDIA/FNDBKFR.gif','',icx_util.replace_alt_quotes(c_prompts(1)),'',
	'BORDER=0 HEIGHT=30 WIDTH=30'),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_prompts(1))||''';return true"'));
    htp.tableData(htf.anchor('javascript:history.back()',icx_util.replace_alt_quotes(c_prompts(2)),'','onMouseOver="window.status='''||icx_util.replace_onMouseOver_quotes(c_prompts(2))||''';return true"'));
    htp.tableRowClose;
    htp.tableClose;
    htp.htmlClose;

exception
	when others then
		htp.p(SQLERRM);
end;

procedure showTable(p_table pp_table,
		    row_count in binary_integer default 0,
                    col_num in binary_integer default 0,
		    p_border in binary_integer default 0,
                    p_cellpadding in binary_integer default 0,
		    p_cellspacing in binary_integer default 0,
		    p_width in binary_integer default 0,
		    p_cell_width in binary_integer default 0,
		    p_indent in binary_integer default 0,
		    img in varchar2 default 'FNDIBLBL.gif' ) is

        row_num         binary_integer;
        row_index       binary_integer;
        counter         binary_integer;
        remainder       binary_integer;
        col_index       binary_integer;
        real_counter    binary_integer;
	v_language_code varchar2(30);

begin

    -- v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
     real_counter := row_count;
     row_num  := trunc((row_count/col_num))+1;
     remainder := mod(row_count, col_num);

     htp.tableOpen('','','','','BORDER='||p_border || 'CELLPADDING='||
                   p_cellpadding || 'CELLSPACING='||p_cellspacing);
     row_index := 1;
     col_index := 1;

     while row_index <= row_num loop

         col_index := 1;
         counter := row_index;
         htp.tableRowOpen;
             while (counter <= row_count and col_index <= col_num and
                    real_counter <> 0) loop
		if (p_cell_width = 0 and p_indent = 0)
		then
		      htp.tableData(p_table(counter));
		else  htp.p('<TD WIDTH='||p_indent||'></TD>');
		     htp.tableData('<image src="/OA_MEDIA/'||img||'">'||p_table(counter),'','','','','','WIDTH="'||p_cell_width||'"');
		end if;
		     htp.p('<TD width='||p_width||'></TD>');
                real_counter := real_counter-1 ;
                    if col_index <= remainder then
                       counter := counter + row_num;
                    else
                        counter := counter + (row_num-1);

                    end if;
                    col_index := col_index+1;
                end loop;
         htp.tableRowClose;
         row_index := row_index+1;
     end loop;
     htp.tableClose;
end;



procedure displayTable(wlcm_table pp_table,
		    row_count in binary_integer default 0,
                    col_num in binary_integer default 0,
		    language_code in varchar2 default null,
		    img in varchar2 default 'FNDIGRBL.gif') is

        row_num         binary_integer;
        row_index       binary_integer;
        counter         binary_integer;
        remainder       binary_integer;
        col_index       binary_integer;
        real_counter    binary_integer;
-- 	v_language_code varchar2(30);

begin

/* remove the following comments if code dependent on
   language specific media directory works fine.
*/

--     if language_code is null then
--     v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
--     else
--     v_language_code := language_code;
--     end if;

     real_counter := row_count;
     row_num  := trunc((row_count/col_num))+1;
     remainder := mod(row_count, col_num);
     row_index := 1;
     col_index := 1;

     while row_index <= row_num loop

         col_index := 1;
         counter := row_index;
         htp.tableRowOpen;
--	 htp.p('<TD WIDTH=10></TD>');
             while (counter <= row_count and col_index <= col_num and
                    real_counter <> 0) loop
		      htp.tableData('<image src="/OA_MEDIA/'  || img || '">','right');
		      htp.tableData(wlcm_table(counter), 'left');
                    real_counter := real_counter-1 ;
                    if col_index <= remainder then
                       counter := counter + row_num;
                    else
                        counter := counter + (row_num-1);

                    end if;
                    col_index := col_index+1;
                end loop;
         htp.tableRowClose;
         row_index := row_index+1;
     end loop;
end;
end icx_admin_sig;

/
