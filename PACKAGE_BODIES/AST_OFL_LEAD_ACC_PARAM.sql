--------------------------------------------------------
--  DDL for Package Body AST_OFL_LEAD_ACC_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_OFL_LEAD_ACC_PARAM" AS
 /* $Header: astrtupb.pls 115.11 2002/02/07 00:05:51 pkm ship     $ */
--
g_image_prefix varchar2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
   l_user_id      number;
   v_date_time    varchar2(30);
   l_agent        varchar2(200);
   ctr1           integer        := 0;
   ctr2           integer        := 0;

-- Changed for 11i AJScott
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

-- Changed for 11i AJScott
--     select to_char(sysdate,G_DATE_FORMAT) into v_date_time from dual;
     select fnd_date.date_to_chardate(sysdate) into v_date_time from dual;

     htp.htmlopen;
     htp.headOpen;
     htp.title('Unassigned Opportunities Report');
     htp.headClose;
     htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
     htp.tableOpen('border="0"  ');
     htp.tableRowOpen( calign => 'TOP' );
--     htp.tableData( htf.img(curl=>g_image_prefix||'oppty.gif'));
     htp.tableData( '<FONT size=+1 face="times new roman">' || 'Unassigned Opportunities Report', cnowrap => 'TRUE');
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
procedure lead_acc_paramform is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: lead_acc_paramform
--
--  DESCRIPTION:  This procedure is main body of the parameter form
--
-----------------------------------------------------------------------------------------------
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


if (icx_sec.validateSession) then
       header;

       l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
       -------------------- Returns login user Id--------------------------
       htp.FormOpen(owa_util.Get_Owa_Service_Path||'AST_OFL_LEAD_ACC_report.report_wrapper',
                             cattributes => ' NAME="param"');
       htp.htmlopen;
       htp.headOpen;
       htp.title('Unassigned Opportunities Report');
       htp.p('<SCRIPT language="JavaScript">');
       htp.p('  function validateForm(objform) {');
       htp.p('    var s_day = objform.p_sd_date.selectedIndex;');
       htp.p('    var s_month = objform.p_sm_date.selectedIndex;');
       htp.p('    var s_year = objform.p_sy_date.selectedIndex;');
       htp.p('    var p_valid = true;');
       htp.p('       if ((s_month == "3"&&s_day== "30")||(s_month == "5"&&s_day== "30")');
       htp.p('          ||(s_month == "8"&&s_day== "30")||(s_month == "10"&&s_day== "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('       if (s_month == "1"){');
       htp.p('          if ((s_year == "2"||s_year == "6"||s_year == "10"||s_year == "14"||s_year == "18")');
       htp.p('          && (s_day == "29"||s_day == "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       htp.p('       if (s_month == "1"){');
       htp.p('          if ((s_year != "2" != "6" != "10" != "14" != "18")');
       htp.p('          && (s_day == "28"||s_day == "29"||s_day == "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       --htp.p('                                 }');
       --htp.p('                             }');
       htp.p('       if (p_valid){');
       htp.p('          objform.submit();}');
       htp.p('}');
       htp.p('</script>');
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
       htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="50%"valign="top">Select Output Format</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_response">');
       htp.FormSelectOption('Excel');
       htp.FormSelectOption('HTML',cselected => 'TRUE');
       htp.FormSelectClose;
       htp.tableRowClose;

     --htp.tableRowClose;

       htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="32%" valign="top">From Date</td>');
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

/*
     htp.p ('<SELECT name="p_sm_date">');
         FOR i IN 1..12 LOOP
               if i=1 then
               htp.FormSelectOption(lpad(to_char(i),2,'0'),
                   cattributes => ' value='||lpad(to_char(i),2,'0'),
                   cselected => 'TRUE' );
               else
               htp.FormSelectOption(lpad(to_char(i),2,'0'),
                   cattributes => ' value='||lpad(to_char(i),2,'0'));
               end if;
         END LOOP;
     htp.FormSelectClose;
     htp.p('-');
*/
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
 END lead_acc_paramform;

 procedure footer is
 BEGIN
      l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
      htp.htmlopen;
      htp.tableRowOpen;
      htp.tableData( htf.hr, crowspan => '1', ccolspan => '190', cnowrap => 'TRUE');
      htp.tableRowClose;
      htp.tableOpen( calign => 'center', cattributes => ' border=0 cellspacing=2 cellpadding=2' );
      htp.tableRowOpen;
      htp.formOpen( curl => l_agent||'/AST_OFL_LEAD_ACC_report.report_wrapper', cmethod => 'POST',
                              cattributes => ' NAME="MyForm" TARGET="_top"');
      htp.p('<td>');
      htp.p('<INPUT TYPE="BUTTON" VALUE="OK" onClick="validateForm(document.param)">');
      htp.p('</td>');
      --htp.tableData( '<INPUT type=button value="Cancel" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
      htp.tableData( '<INPUT type=button value="Reset" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
      htp.tableData( '<INPUT type=button value="Cancel" onClick="window.close()" onMouseOver="window.status="Close";return true">');
      htp.tableRowClose;
      htp.tableClose;
      htp.htmlClose;
   END footer;
END;

/
