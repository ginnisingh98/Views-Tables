--------------------------------------------------------
--  DDL for Package Body ICX_CHANGE_LANGUAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CHANGE_LANGUAGE" as
/* $Header: ICXCLANB.pls 120.0 2005/10/07 12:13:07 gjimenez noship $ */

  procedure show_languages is
l_title varchar2(80);
l_helpmsg varchar2(240);
l_helptitle varchar2(240);
l_actions icx_cabo.actionTable;
l_toolbar icx_cabo.toolbar;
username varchar2(30);
c_error_msg		varchar2(2000);
c_login_msg		varchar2(2000);
l_agent                 varchar2(240);
l_dbhost                varchar2(240);
l_prompts icx_util.g_prompts_table;--added mputman bug 1402459

begin

    htp.headopen;
    htp.p('<SCRIPT>');

    icx_admin_sig.help_win_script('GENPREF', null, 'FND');
    icx_util.getprompts(601, 'ICX_OBIS_TOOLBAR', l_title, l_prompts);--added mputman bug 1402459

    htp.p('</SCRIPT>');
    htp.headclose;

  -- Check session and current user
  wfa_sec.GetSession(username);
  username := upper(username);

  l_toolbar.title := wf_core.translate('ICX_LANG_PREF');
  l_toolbar.help_url := 'javascript:top.help_window()';
  fnd_message.set_name('ICX','ICX_HELP');
  l_toolbar.help_mouseover := FND_MESSAGE.GET;

  if icx_sec.g_mode_code in ( '115J', '115P') then
     l_toolbar.menu_url :=owa_util.get_cgi_env('SCRIPT_NAME')||'/OracleNavigate.Responsibility';--added mputman bug 1402459
     l_toolbar.menu_mouseover := l_prompts(7); -- from region ICX_OBIS_TOOLBAR added mputman bug 1402459
  end if;

  IF (icx_sec.g_mode_code <> 'SLAVE') THEN
  --mputman isolated menubutton to exclude slave mode 1747045
  --nlbarlow added for Portal support
  l_toolbar.custom_option1_url := icx_plug_utilities.getPLSQLagent ||
                                  'OracleMyPage.Home';
  l_toolbar.custom_option1_mouseover := wf_core.translate('RETURN_TO_HOME');
  l_toolbar.custom_option1_gif := '/OA_MEDIA/FNDHOME.gif';
  l_toolbar.custom_option1_mouseover_gif := '/OA_MEDIA/FNDHOME.gif';
  END IF;

  l_helpmsg :=  wf_core.translate('ICX_LANG_PREF');
  --l_helpmsg := '';
  l_helptitle := wf_core.translate('ICX_LANG_PREF');

  icx_cabo.container(p_toolbar => l_toolbar,
               p_helpmsg => l_helpmsg,
               p_helptitle => l_helptitle,
               p_url => owa_util.get_cgi_env('SCRIPT_NAME')||'/icx_change_language.show_languages_local?p_message_flag=N',
               p_action => TRUE);


exception
   when others then
      fnd_message.set_name('ICX','ICX_SESSION_FAILED');
      c_error_msg := fnd_message.get;
      fnd_message.set_name('ICX','ICX_SIGNIN_AGAIN');
      c_login_msg := fnd_message.get;

      OracleApps.displayLogin(c_error_msg||' '||c_login_msg,'IC','Y');
end;


-- *****************************************************
--          show_languages_local
-- *****************************************************

procedure show_languages_local(p_message_flag VARCHAR2) is

  cursor get_lang is
	SELECT LANGUAGE_CODE,
	       NLS_LANGUAGE,
	       DESCRIPTION,
	       ISO_LANGUAGE,
	       ISO_TERRITORY
	FROM   FND_LANGUAGES_VL
	WHERE  INSTALLED_FLAG in ('I', 'B')
        ORDER BY DESCRIPTION;

  c_title         varchar2(80);
  c_prompts       icx_util.g_prompts_table;
  v_lang	  varchar2(5);

l_actions    icx_cabo.actionTable;
l_actiontext varchar2(2000);

  begin

   -- Check if session is valid
   if icx_sec.validatesession('ICX_CH_LANG') then
    -- get language code
    v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

    icx_util.getPrompts(601,'ICX_CHANGE_LANG',c_title,c_prompts);

    htp.htmlOpen;
    htp.headOpen;
    htp.title(c_title);
    js.scriptOpen;
    icx_admin_sig.help_win_script('/OA_DOC/' || v_lang ||
	 			  '/aic/icxhlpln.htm');


    if icx_sec.g_mode_code in ( '115J', '115P') then
       htp.p('function cancelpref() {
              top.location.href = "'||owa_util.get_cgi_env('SCRIPT_NAME')||'/OracleNavigate.Responsibility";
             }'); -- updated mputman 1402459
    else
       htp.p('function cancelpref() {
             top.location.href = "'||wfa_html.base_url ||'/OracleNavigate.Responsibility";
       }');
    end if;

    htp.p('function savepref() {

	document.lang.submit();

        }');

--        top.location.href = "'||wfa_html.base_url ||'/oraclemypage.home";


    js.scriptClose;
--    icx_admin_sig.toolbar(language_code => v_lang);

    htp.p('<CENTER>');

    htp.br;
    htp.p('<FORM ACTION="ICX_CHANGE_LANGUAGE.set_new_language" NAME="lang">');
    htp.p(c_prompts(1));
    htp.p('<SELECT NAME="v_language" SIZE="1">');
    for prec in get_lang loop
 	if (prec.LANGUAGE_CODE = v_lang) then
           htp.p('<OPTION VALUE="' || prec.NLS_LANGUAGE ||
		 '" SELECTED> ' || prec.description || ' [' ||
		 prec.ISO_LANGUAGE || '-' || prec.ISO_TERRITORY || ']');
	else
	   htp.p('<OPTION VALUE="' || prec.NLS_LANGUAGE ||
		'"> ' || prec.description || ' [' ||
                 prec.ISO_LANGUAGE || '-' || prec.ISO_TERRITORY || ']');
	end if;
    end loop;
    htp.p('</SELECT>');
    htp.p('</FORM>');

    htp.p('</CENTER>');
    htp.p('<BR>');

/*
  icx_util.DynamicButton(P_ButtonText => c_prompts(2),
			 P_ImageFileName => 'FNDBSBMT',
			 P_OnMouseOverText => c_prompts(2),
			 P_HyperTextCall =>'javascript:document.lang.submit()',
			 P_LanguageCode => v_lang,
			 P_JavaScriptFlag => FALSE);
*/


   l_actions(0).name := 'Cancel';
   l_actions(0).text := wf_core.translate('CANCEL');
   l_actions(0).actiontype := 'function';
   l_actions(0).action := 'top.main.cancelpref()';  -- put your own commands here
   l_actions(0).targetframe := 'main';
   l_actions(0).enabled := 'b_enabled';
   l_actions(0).gap := 'b_narrow_gap';

   l_actions(1).name := 'Save';
   l_actions(1).text :=  wf_core.translate('APPLY');
   l_actions(1).actiontype := 'function';
   l_actions(1).action := 'top.main.savepref()';  -- put your own commands here
   l_actions(1).targetframe := 'main';
   l_actions(1).enabled := 'b_enabled';
   l_actions(1).gap := 'b_narrow_gap';

   if p_message_flag = 'N' then
      icx_cabo.buttons(p_actions => l_actions);
   else
      fnd_message.set_name('ICX','ICX_SUCCESS_CONFIRM');
      l_actiontext := fnd_message.get;

      icx_cabo.buttons(p_actions    => l_actions,
                       p_actiontext => l_actiontext);
   end if;

    htp.p('</BODY>');
    htp.htmlClose;

 end if;

end;




--------------------------------------------------------------------
  procedure set_new_language(v_language IN varchar2) is
--------------------------------------------------------------------
v_decrypted_lang	varchar2(30);
v_nls_territory		varchar2(30);
n_session_id		number;
l_language_code         varchar2(30);
l_agent           VARCHAR2(2000); --added mputman bug 1405228
l_url             VARCHAR2(2000); --added mputman bug 1405228
p_db_nls_language varchar2(80);
p_db_nls_date_format varchar2(30);
p_db_nls_date_language varchar2(80);
p_db_nls_numeric_characters varchar2(5);
p_db_nls_sort varchar2(30);
p_db_nls_territory varchar2(80);
p_db_nls_charset varchar2(80);


begin

   -- Check if session is valid
   if icx_sec.validatesession('ICX_CH_LANG')
   then

      select  language_code
      into    l_language_code
      from    fnd_languages
      where   nls_language = v_language;

      fnd_global.set_nls(
              p_nls_language => v_LANGUAGE,
              p_nls_date_format => NULL,
              p_nls_date_language => NULL,
              p_nls_numeric_characters => NULL,
              p_nls_sort => NULL,
              p_nls_territory => NULL,
              p_db_nls_language => p_db_nls_language,
              p_db_nls_date_format => p_db_nls_date_format,
              p_db_nls_date_language => p_db_nls_date_language,
              p_db_nls_numeric_characters => p_db_nls_numeric_characters,
              p_db_nls_sort => p_db_nls_sort,
              p_db_nls_territory => p_db_nls_territory,
              p_db_nls_charset => p_db_nls_charset);


      update icx_sessions
      set    nls_language = v_language,
             language_code = l_language_code,
             nls_date_language = p_db_nls_date_language
      where  session_id = icx_sec.g_session_id;

      --show_languages_local;
      --if added mputman bug 1405228
      IF (substr(icx_plug_utilities.getPLSQLagent, 1, 1) = '/') then
            l_agent := FND_WEB_CONFIG.WEB_SERVER||substr(icx_plug_utilities.getPLSQLagent,2);

         ELSE
            l_agent := FND_WEB_CONFIG.WEB_SERVER||icx_plug_utilities.getPLSQLagent;

         end if;

         l_url:=l_agent||'ICX_CHANGE_LANGUAGE.show_languages';
         l_url:='"'||l_url||'"';

         htp.p('


               <script language="JavaScript">
               function menuBypass(url){
               top.location=url;
               }
               </script>

               <frameset cols="100%,*" frameborder=no border=0>

               <frame
                src=javascript:parent.menuBypass('||l_url||')
                name=hiddenFrame1
                marginwidth=0
                marginheight=0
                scrolling=no>


               </frameset>

               ');--end mputman bug 1405228

   end if;

null;
end;

end ICX_CHANGE_LANGUAGE;

/
