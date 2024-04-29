--------------------------------------------------------
--  DDL for Package Body ODP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ODP" AS
/* $Header: msddsplb.pls 115.12 2002/05/21 10:13:04 pkm ship     $ */

procedure display_plans is

n_session_id            number;
n_responsibility_id     number;
n_function_id           number;
n_application_id        number;
v_language              varchar2(240);
v_url                   varchar2(2000);
n_web_user              number;
b_plans_found           boolean;
v_mod_shared_path       MSD_DEMAND_PLANS_V.SHARED_DB_LOCATION%TYPE;
v_odp_resp              varchar2(2) NOT NULL := 'NA';
v_browser               varchar2(80);
v_prompt_tab            icx_util.g_prompts_table;
v_title                 varchar2(80);
v_no_plans              varchar2(80);
v_prompt                varchar2(80);
v_start                 varchar2(80);
v_function_name         varchar2(30);

v_appl_id               number := 601;  -- Application must be Oracle Common Modules-AK for translation
v_page_code             varchar2(30) := 'MSD_DISPLAY_PLANS';
v_init_prg              varchar2(80) := 'dp.init.sso';
v_odpcode_db            varchar2(80) := 'ODPCODE';
v_sep                   varchar2(1)  := '/';
v_pth_sep               varchar2(3)  := '%2f';
v_id_nm                 varchar2(3)  := 'ID=';
v_func_id_nm            varchar2(4)  := 'IDF=';
v_shr_nm                varchar2(4)  := 'SHR=';
v_shrpth_nm             varchar2(9)  := 'SHR_PATH=';

v_help_html             varchar2(150); -- 06/07/00

b_profile_defined       boolean;
v_access_profile_nm     varchar2(80) := 'ICX_ACCESSIBILITY_FEATURES';
v_jaws_spt              varchar2(13) := 'JAWS_SUPPORT=';
v_jaws_spt_val          varchar2(3);

cursor c_demand_plans is
   select DEMAND_PLAN_ID, DEMAND_PLAN_NAME,
   EXPRESS_MACHINE_PORT, OWA_VIRTUAL_PATH_NAME,
   EAD_NAME, SHARED_DB_LOCATION, SHARED_DB_PREFIX
   from msd_demand_plans_v
   where demand_plan_id in
   (select demand_plan_id from msd_dp_users_v
     where user_id = n_web_user and
     responsibility_id = n_responsibility_id)
   order by demand_plan_name;

begin

 if (icx_sec.validateSession()) then
   n_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
   v_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   n_web_user := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
   n_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
   n_function_id := icx_sec.getID(icx_sec.PV_FUNCTION_ID);

   select APPLICATION_ID
     into n_application_id
     from FND_RESPONSIBILITY
     where RESPONSIBILITY_ID = n_responsibility_id;

   select FUNCTION_NAME
     into v_function_name
     from FND_FORM_FUNCTIONS
     where FUNCTION_ID = n_function_id;

   fnd_profile.get_specific(
             name_z               => v_access_profile_nm,
             user_id_z            => n_web_user,
             responsibility_id_z  => n_responsibility_id,
             application_id_z     => n_application_id,
             val_z                => v_jaws_spt_val,
             defined_z            => b_profile_defined);

   if( NOT b_profile_defined OR v_jaws_spt_val = '' OR v_jaws_spt_val = 'N')
     then
        v_jaws_spt_val := 'No';
     else
        v_jaws_spt_val := 'Yes';
     end if;

   htp.htmlOpen;
   -- show copyright in source
   icx_util.copyright;
   htp.headOpen;

   icx_util.getPrompts(v_appl_id, v_page_code, v_title, v_prompt_tab);
   v_prompt := v_prompt_tab(1);
   v_start := v_prompt_tab(2);
   v_no_plans := v_prompt_tab(3);
   htp.title(v_title);

   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   htp.p('<!-- hide from old browsers');
   htp.p('var destHREF="NULL"');

   -- wsn 06/07/00 add help function
   icx_admin_sig.help_win_script('ICXPHP', null, 'FND');

   htp.p('function BldUrl(_val)
          {
          var _browser_name=navigator.appName;
          var _browser_ver=navigator.appVersion.substring(0,3);
          var _screen_height=screen.availHeight - 50;
          var _screen_width=screen.availWidth - 15;
          if (_browser_name==''Netscape'')
            var _intl_lang=navigator.languager;
          else
            var _intl_lang=navigator.browserLanguager;
	      destHREF=_val+"BRWS="+_browser_name+"/BRWS_VER="+_browser_ver+"/LANG="+_intl_lang+"/SCR_HT="+_screen_height+"/SCR_WD="+_screen_width
          winParms="height="+_screen_height+",width="+_screen_width+",toolbar=no,status=yes,location=no,menubar=no,resizable=yes,scrollbars=yes,top=0,left=0,screenX=0,screenY=0"
          }');
   htp.p('function SubmitHandler()
          {
          if (destHREF!="NULL")
          {
            destHREF = destHREF + "/DUMMY="+Math.random();
            window.open(destHREF,"ODPwindow",winParms);
          }
          else
          {
            alert("Select a demand plan.")
          }
          }');
   htp.p('// done hiding -->');
   htp.p('</SCRIPT>');
   htp.headClose;

   htp.bodyOpen( cattributes => 'BGCOLOR=white');
   -- display logo and toolbar
   icx_admin_sig.toolbar(v_language);
   htp.header(3, v_prompt);
   htp.para;

   htp.formOpen(curl => '');
   b_plans_found := false;
   for v_plan in c_demand_plans loop

      select REPLACE(v_plan.SHARED_DB_LOCATION, v_sep, v_pth_sep)
        into v_mod_shared_path from DUAL;

      v_url := 'http:' || v_sep || v_sep ||
               v_plan.EXPRESS_MACHINE_PORT || v_sep ||
               v_plan.OWA_VIRTUAL_PATH_NAME
               || v_sep || v_plan.EAD_NAME || '/db' ||
               v_odpcode_db || v_sep || v_init_prg
               || '?' ||
               v_func_id_nm || v_function_name || v_sep ||
               v_id_nm || v_plan.DEMAND_PLAN_ID || v_sep ||
               v_shr_nm || v_plan.SHARED_DB_PREFIX || v_sep ||
               v_shrpth_nm || v_mod_shared_path || v_sep ||
               v_jaws_spt || v_jaws_spt_val || v_sep;

      htp.p('<INPUT TYPE="RADIO" NAME="PlanSelect" VALUE="' ||
            v_url || '" onCLick="BldUrl(this.value)"> ' ||
            v_plan.DEMAND_PLAN_NAME);
      htp.nl;

      b_plans_found := true;
   end loop;

   if (b_plans_found) then
      htp.para;
      htp.p('<INPUT TYPE="BUTTON" NAME="Start" VALUE="' || v_start || '" onClick="SubmitHandler()">');
   else
      htp.para;
      htp.print(v_no_plans);
      htp.para;
   end if;

   htp.formClose;
   htp.bodyClose;
   htp.htmlClose;
 end if;

end display_plans;

end odp;

/
