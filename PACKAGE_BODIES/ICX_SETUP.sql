--------------------------------------------------------
--  DDL for Package Body ICX_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_SETUP" as
/* $Header: ICXDPARB.pls 120.0 2005/10/07 12:14:05 gjimenez noship $ */

-- Create a page for user to input post-install setup info
-- Store it in icx_parameters
--
PROCEDURE get_parameters is
  v_query_set	number;
  v_home_url	varchar2(240);
  v_webmaster_email	varchar2(80);
  v_max_rows	number;
  v_language	varchar2(30);
  PV_LANGUAGE_CODE number := 21;	-- parameter value for calling getID
  v_web_user	varchar2(30);
  PV_WEB_USER_ID number := 10;		-- parameter value for calling getID

  -- variables used to build path for images, static html
  v_help_html	varchar2(150);
  v_bkgrd_image	varchar2(150);
  v_gap_image	varchar2(150);

  -- variables used to get prompts from Object Navigator
  v_appl_id	number := 601;		-- application_id
  v_page_code	varchar2(30) := 'ICX_SETUP';	-- page code as defined in ON
  v_title	varchar2(80);		-- page title
  v_prompt_tab	icx_util.g_prompts_table;  -- PL/SQL table of prompts
  v_save_label	varchar2(50) := null;
  v_revert_label varchar2(50) := null;
  v_lines_page	varchar2(50) := null;
  v_start_url	varchar2(50) := null;
  v_web_email	varchar2(50) := null;
  v_max_rows_returned varchar2(50) := null;

  l_save_url	varchar2(1000);
  l_revert_url	varchar2(1000);

  -- variables for messages, hints
  v_set_req 	varchar2(240);
--  v_url_req	varchar2(240); bug 2565837
  v_email_req	varchar2(240);

  c_browser     varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');

begin
if (icx_sec.validateSession('ICX_SETUP')) then

  -- need the language code to find any images or static html
  v_language := icx_sec.getID(PV_LANGUAGE_CODE);
  v_web_user := icx_sec.getID(PV_WEB_USER_ID);

  select query_set,
	 home_url,
	 webmaster_email,
         max_rows
  into v_query_set,
       v_home_url,
       v_webmaster_email,
       v_max_rows
  from icx_parameters;

  -- get the title and prompts from Object Navigator
  icx_util.getPrompts(v_appl_id, v_page_code, v_title, v_prompt_tab);
  v_save_label := v_prompt_tab(1);
  v_revert_label := v_prompt_tab(2);
  v_lines_page := v_prompt_tab(3);
  v_start_url  := v_prompt_tab(4);
  v_web_email  := v_prompt_tab(5);
  v_max_rows_returned  := v_prompt_tab(6);

  -- get error messages from Message Dictionary
  fnd_message.set_name('ICX', 'ICX_LINES_PAGE_REQUIRED');
  v_set_req := fnd_message.get;
--  fnd_message.set_name('ICX', 'ICX_HOME_URL_REQUIRED');
--  v_url_req := fnd_message.get;
  fnd_message.set_name('ICX', 'ICX_WEB_EMAIL_REQUIRED');
  v_email_req := fnd_message.get;

  htp.htmlOpen;
  -- show copyright in source
  icx_util.copyright;
  htp.headOpen;
  htp.title(v_title);
  htp.p('<SCRIPT LANGUAGE="JavaScript">');
  htp.p('<!-- hide from old browsers');
  -- creates javascript function to check if value is a number
  js.checkNumber;
  js.null_alert;

  v_help_html := '/OA_DOC/'||v_language||'/aic/icxhlpst.htm';
  icx_admin_sig.help_win_script(v_help_html, v_language);

  fnd_message.set_name('CS','CS_ALL_GREATER_THAN_ZERO');
  htp.p('function checkNonZero(input) {
	var msg = "'||icx_util.replace_quotes(fnd_message.get)||'";
	var str = input.value;
	var count = 0;

	for (var i = 0; i< str.length; i++) {
	    var ch = str.substring(i,i+1);
	    if (ch == "0") {
		count++;
	    }
	}
	if (count==str.length) {
	    alert(msg);
	    return false;
	}
	return true;
  }
  ');
  htp.p('function update_param(set_req, email_req) {
           if (checkNumber(document.define_param.QuerySet) &&
	       (checkNonZero(document.define_param.QuerySet)) &&
	       (!null_alert(document.define_param.QuerySet.value, set_req)) &&
	       (!null_alert(document.define_param.WebEmail.value, email_req)))
             document.define_param.submit();
         } ');
  htp.p('function restore_param() {
         document.define_param.QuerySet.value = document.define_param.QuerySet.defaultValue;
         document.define_param.HomeUrl.value = document.define_param.HomeUrl.defaultValue;
	 document.define_param.WebEmail.value = document.define_param.WebEmail.defaultValue;
         } ');

  htp.p('// done hiding from old browsers -->');
  htp.p('</SCRIPT>');
  htp.headClose;

  -- Display logo, toolbar

  icx_admin_sig.toolbar(v_language);

  htp.header(2, v_title);
  htp.para;
  htp.formOpen('icx_setup.update_parameters', 'POST', '','', 'NAME="define_param" ');
  htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData(v_lines_page, 'RIGHT');
    htp.tableData(htf.formText('QuerySet', 10, 10, v_query_set));
    htp.tableRowClose;

    htp.tableRowOpen;
    htp.tableData(v_max_rows_returned, 'RIGHT');
    htp.tableData(htf.formText('MaxRows', 10, 10, v_max_rows));
    htp.tableRowClose;

    htp.tableRowOpen;
    htp.tableData(v_start_url, 'RIGHT');
    htp.tableData(htf.formText('HomeUrl', 45, 240, icx_util.replace_alt_quotes(v_home_url)));
    htp.tableRowClose;

    htp.tableRowOpen;
    htp.tableData(v_web_email, 'RIGHT');
    htp.tableData(htf.formText('WebEmail', 45, 80, icx_util.replace_alt_quotes(v_webmaster_email)));
    htp.tableRowClose;

  htp.tableClose;
  -- keep the web user id in a hidden field for last_updated_by
  htp.formHidden('WebUser', icx_util.replace_alt_quotes(v_web_user));

  htp.formClose;

  l_save_url := 'javascript:update_param('''||icx_util.replace_onMouseOver_quotes(v_set_req)||''','''||icx_util.replace_onMouseOver_quotes(v_email_req)||''')';

  icx_util.DynamicButton(P_ButtonText => v_save_label,
			 P_ImageFileName => 'FNDBSBMT',
			 P_OnMouseOverText => v_save_label,
			 P_HyperTextCall => l_save_url,
			 P_LanguageCode => v_language,
			 P_JavaScriptFlag => FALSE);

   htp.tableRowClose;
   htp.tableClose;

  htp.bodyClose;
  icx_sig.footer;
  htp.htmlClose;

end if;

exception
  when OTHERS then
    htp.p(sqlerrm);

end get_parameters;

PROCEDURE update_parameters(QuerySet in number,
			    HomeUrl  in varchar2,
			    WebEmail in varchar2,
                            MaxRows  in number,
			    WebUser  in number) is

begin

if (icx_sec.validateSession('ICX_SETUP')) then

  update icx_parameters
  set query_set = QuerySet,
      home_url = HomeUrl,
      webmaster_email = WebEmail,
      max_rows = MaxRows,
      last_updated_by = WebUser,
      last_update_date = sysdate
  ;

  -- redisplay setup page
  icx_setup.get_parameters;

end if;

end update_parameters;

END ICX_SETUP;

/
