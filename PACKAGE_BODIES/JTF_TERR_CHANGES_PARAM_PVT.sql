--------------------------------------------------------
--  DDL for Package Body JTF_TERR_CHANGES_PARAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_CHANGES_PARAM_PVT" AS
/* $Header: jtftrpcb.pls 120.0 2005/06/02 18:21:44 appldev ship $ */

   --g_image_prefix varchar2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
   l_user_id      number;
   v_date_time    varchar2(30);
   l_agent        varchar2(200);
   ctr1           integer        := 0;
   ctr2           integer        := 0;
--   G_DATE_FORMAT  varchar2(20)   := as_ofl_util_pkg.get_date_format;


   TYPE day_TABLE IS table of varchar2(2000) INDEX BY BINARY_INTEGER;
   TYPE year_TABLE IS table of varchar2(2000) INDEX BY BINARY_INTEGER;

   day_data      day_table;
   year_data     year_table;


  procedure header is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: header
--
--  DESCRIPTION:  This procedure is creates the descriptive header in the parameter form
--
-----------------------------------------------------------------------------------------------
   begin
     --select to_char(sysdate,G_DATE_FORMAT) into v_date_time from dual;
     htp.htmlopen;
     htp.headOpen;
     htp.title('Territory Changes Report');
       htp.p('<SCRIPT language="JavaScript">');
       htp.p('  function validateForm(objform) {');
       htp.p('    var s_day = objform.p_sd_date.selectedIndex;');
       htp.p('    var s_month = objform.p_sm_date.selectedIndex;');
       htp.p('    var s_year = objform.p_sy_date.selectedIndex;');
       htp.p('    var e_day = objform.p_ed_date.selectedIndex;');
       htp.p('    var e_month = objform.p_em_date.selectedIndex;');
       htp.p('    var e_year = objform.p_ey_date.selectedIndex;');
       htp.p('    var p_valid = true;');
       htp.p('       if ((s_month == "3"== "30")||(s_month == "5"== "30")');
       htp.p('          ||(s_month == "8"== "30")||(s_month == "10"== "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('       if ((e_month == "3"== "30")||(e_month == "5"== "30")');
       htp.p('          ||(e_month == "8"== "30")||(e_month == "10"== "30")){');
       htp.p('          alert(''End Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('       if (s_month == "1"){');
       htp.p('          if ((s_year == "2"||s_year == "6"||s_year == "10"||s_year == "14"||s_year == "18")');
       htp.p('           (s_day == "29"||s_day == "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       htp.p('       if (s_month == "1"){');
       htp.p('          if ((s_year != "2" != "6" != "10" != "14" != "18")');
       htp.p('           (s_day == "28"||s_day == "29"||s_day == "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       htp.p('       if (e_month == "1"){');
       htp.p('          if ((e_year == "2"||e_year == "6"||e_year == "10"||e_year == "14"||e_year == "18")');
       htp.p('           (e_day == "29"||e_day == "30")){');
       htp.p('          alert(''End Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       htp.p('       if (e_month == "1"){');
       htp.p('          if ((e_year != "2" != "6" != "10" != "14" != "18")');
       htp.p('           (e_day == "28"||e_day == "29"||e_day == "30")){');
       htp.p('          alert(''End Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       htp.p('       if (s_year > e_year){');
       htp.p('          alert(''Start Date must be less than End Date'');');
       htp.p('          p_valid = false;}');
       htp.p('       if (s_year == e_year){');
       htp.p('          if (s_month > e_month){');
       htp.p('            alert(''Start Date must be less than End Date'');');
       htp.p('            p_valid = false;}');
       htp.p('          if (s_month == e_month){');
       htp.p('            if (s_day > e_day){');
       htp.p('              alert(''Start Date must be less than End Date'');');
       htp.p('              p_valid = false;}');
       htp.p('                                 }');
       htp.p('                             }');
     --  htp.p('              alert(''Start Date must be less than End Date'');');

       htp.p('       if (p_valid){');
       htp.p('          objform.submit();}');
       htp.p('}');
       htp.p('</script>');
     htp.headClose;
     htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
     htp.tableOpen('border="0"  ');
     htp.tableRowOpen( calign => 'TOP' );
--     htp.tableData( htf.img(curl=>g_image_prefix||'oppty.gif'));
     htp.tableData( '<FONT size=+1 face="times new roman">' || 'Territory Changes Report', cnowrap => 'TRUE');
     htp.tableData(htf.bold(v_date_time),calign => 'right',ccolspan => '110');
     htp.tableRowClose;
     htp.tableClose;
     htp.tableOpen(  cattributes => 'border=0 cellspacing=0 cellpadding=0 width=561' );
     htp.tableRowOpen( cvalign => 'top' );
     htp.tableData( ' ', ccolspan => '2', cattributes => ' height=9');
     htp.tableData( '<FONT face="Times New Roman">' ||htf.bold( 'Please specify the criteria and select OK.  ') ||
                    '</FONT>', calign => 'center', crowspan => '2', ccolspan => '110', cattributes => ' width=346');
     htp.tableData( ' ', ccolspan => '6');
     htp.Br;
     htp.tableRowClose;
     htp.tableClose;
     htp.bodyClose;
     htp.headClose;
     htp.htmlClose;
   end;
-----------------------------------------------------------------------------------------------
procedure terr_changes_paramform is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: Territory Changes
--
--  DESCRIPTION:  This procedure is main body of the parameter form
--
-----------------------------------------------------------------------------------------------
   /*
   cursor cur_get_manager is
   select distinct ltrim(rtrim(ppf.last_name))||', ' ||ltrim(rtrim(ppf.first_name)) manager_name ,
          ppf.person_id manager_person_id
   from per_people_f ppf,
        as_sales_groups asg
   where asg.manager_person_id =    ppf.person_id
   and asg.enabled_flag = 'Y'
   and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
   and trunc(sysdate)<=  nvl(asg.end_date_active,trunc(sysdate) )
    order by ltrim(rtrim(ppf.last_name))||', ' ||ltrim(rtrim(ppf.first_name)) ;
    */
   day_counter NUMBER := 1;
   year_counter  NUMBER := 1990;

BEGIN


    FOR i IN 1..31 LOOP
       if day_counter <= 9  then
         day_data(i) := '0'||day_counter;
         day_counter := day_counter +1;
       else
         day_data(i) := to_char(day_counter);
         day_counter := day_counter +1;
       end if;
    END LOOP;

    FOR i IN 1..21 LOOP
         year_data(i) := to_char(year_counter);
         year_counter := year_counter +1;
    END LOOP;

    if (icx_sec.validateSession(c_function_code => 'JTF_TERR_CHGS_RPT', c_validate_only => 'Y')) then
       header;

       l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
       -------------------- Returns login user Id--------------------------
       htp.FormOpen(owa_util.Get_Owa_Service_Path||'JTF_TERR_changes_report_PVT.report_wrapper',
                             cattributes => ' NAME="param"');
       htp.htmlopen;
       htp.headOpen;
       htp.title('Territory Changes Report');
       htp.headClose;
       htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
       htp.tableopen;
       htp.tableRowOpen( cvalign => 'top' );
       htp.tableData( ' ', cattributes => ' height=9');
       htp.tableData( '<FONT size=2 face="Times New Roman">' || '</FONT>', calign => 'right', crowspan => '2', ccolspan => '3', cattributes => ' width=154');
       htp.tableData( ' ');
       htp.tableRowClose;
       htp.tableClose;
       htp.tableOpen(cattributes=>'width="600" ');
        -- OUTPUT FORMAT FIELD
       htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="50%"valign="top">Select Output Format</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_response">');
       htp.FormSelectOption('Excel');
       htp.FormSelectOption('HTML',cselected => 'TRUE');
       htp.FormSelectClose;
       htp.tableRowClose;
/*     -- MANAGER/GROUP FIELD

     htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="50%" valign="top">Manager/Group</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_manager"  >');
       FOR rec_get_manager IN cur_get_manager LOOP
           htp.FormSelectOption(rec_get_manager.manager_name,cattributes => ' value= '||rec_get_manager.manager_person_id);
       END LOOP;
     htp.FormSelectClose;
     htp.p('</td>');
    htp.tableRowClose;
*/
        -- EARLISET CHANGE DATE FIELD
        htp.tableRowOpen();
        htp.p('<td align="RIGHT" width="32%" valign="top">Earliest Change Date</td>');
        htp.p('<td>');
        htp.p ('<SELECT name="p_sd_date">');
        --  htp.FormSelectOption('   ');
        FOR i IN 1..day_data.count  LOOP
            htp.FormSelectOption(day_data(i),
            cattributes => ' value= '||day_data(i),
			cselected => 'TRUE' );
        END LOOP;
        htp.FormSelectClose;
        htp.p('-');

        htp.p ('<SELECT name="p_sm_date">');
        htp.FormSelectOption('JAN',cselected => 'TRUE');
        htp.FormSelectOption('FEB');
        htp.FormSelectOption('MAR');
        htp.FormSelectOption('APR');
        htp.FormSelectOption('MAY');
        htp.FormSelectOption('JUN');
        htp.FormSelectOption('JUL');
        htp.FormSelectOption('AUG');
        htp.FormSelectOption('SEP');
        htp.FormSelectOption('OCT');
        htp.FormSelectOption('NOV');
        htp.FormSelectOption('DEC');
        htp.FormSelectClose;
        htp.p('-');
        htp.p ('<SELECT name="p_sy_date">');
        --  htp.FormSelectOption('   ');
        FOR i IN 1..year_data.count  LOOP
            htp.FormSelectOption(year_data(i),
			cattributes => ' value= '||year_data(i));
        END LOOP;
        htp.FormSelectClose;
        htp.p('</td>');
        htp.tableRowClose;

        -- LATEST CHANGE DATE FIELD
        htp.tableRowOpen();
        htp.p('<td align="RIGHT" width="32%" valign="top">Latest Change Date</td>');
        htp.p('<td>');
        htp.p ('<SELECT name="p_ed_date">');
        --  htp.FormSelectOption('   ');
        FOR i IN 1..day_data.count  LOOP
            htp.FormSelectOption(day_data(i),
			cattributes => ' value= '||day_data(i),
			cselected => 'TRUE' );
        END LOOP;
        htp.FormSelectClose;
        htp.p('-');

        htp.p ('<SELECT name="p_em_date">');
        htp.FormSelectOption('JAN',cselected => 'TRUE');
        htp.FormSelectOption('FEB');
        htp.FormSelectOption('MAR');
        htp.FormSelectOption('APR');
        htp.FormSelectOption('MAY');
        htp.FormSelectOption('JUN');
        htp.FormSelectOption('JUL');
        htp.FormSelectOption('AUG');
        htp.FormSelectOption('SEP');
        htp.FormSelectOption('OCT');
        htp.FormSelectOption('NOV');
        htp.FormSelectOption('DEC');
        htp.FormSelectClose;
        htp.p('-');

        htp.p ('<SELECT name="p_ey_date">');
        --  htp.FormSelectOption('   ');
        FOR i IN 1..year_data.count  LOOP
            htp.FormSelectOption(year_data(i),
            cattributes => ' value= '||year_data(i));
        END LOOP;
        htp.FormSelectClose;
        htp.p('</td>');
        htp.tableRowClose;

        htp.tableClose;
        htp.Br;
        htp.Br;
        htp.Br;
        footer;
        htp.FormClose;
        htp.bodyclose;
        htp.htmlclose;
    else
        htp.p('Invalid session');
    end if;
    exception
        when others then
            htp.p(SQLERRM);
END terr_changes_paramform;

 procedure footer is
 BEGIN
      l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
      htp.htmlopen;
      htp.tableRowOpen;
      htp.tableData( htf.hr, crowspan => '1', ccolspan => '190', cnowrap => 'TRUE');
      htp.tableRowClose;
      htp.tableOpen( calign => 'center', cattributes => ' border=0 cellspacing=2 cellpadding=2' );
      htp.tableRowOpen;
      htp.formOpen( curl => l_agent||'/JTF_TERR_CHANGES_report_PVT.report_wrapper', cmethod => 'GET',
                              cattributes => ' NAME="MyForm" TARGET="_top"');

      htp.p('<td>');
      htp.p('<INPUT TYPE="BUTTON" VALUE="OK" onClick="validateForm(document.param)">');
      htp.p('</td>');
      htp.tableData( '<INPUT type=button value="Cancel" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
      htp.tableRowClose;
      htp.tableClose;
      htp.htmlClose;
   END footer;
END;

/
