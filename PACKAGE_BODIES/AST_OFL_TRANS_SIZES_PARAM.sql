--------------------------------------------------------
--  DDL for Package Body AST_OFL_TRANS_SIZES_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_OFL_TRANS_SIZES_PARAM" AS
 /* $Header: astrttpb.pls 115.24 2002/02/07 15:24:53 pkm ship      $ */

g_image_prefix varchar2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
   l_user_id      number;
   v_date_time    varchar2(30);
   l_agent        varchar2(200);
   ctr1           integer        := 0;
   ctr2           integer        := 0;

-- Changed for 11i AJScott
--   G_DATE_FORMAT  varchar2(20)   := as_ofl_util_pkg.get_date_format;

   l_test         owa_util.dateType;


   TYPE day_TABLE IS table of varchar2(2000) INDEX BY BINARY_INTEGER;
   TYPE year_TABLE IS table of varchar2(2000) INDEX BY BINARY_INTEGER;

   day_data      day_table;
   year_data     year_table;

   /* variable for supporting multi-currency */
   v_usr_currency_code          varchar2(15);


  procedure header is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: header
--
--  DESCRIPTION:  This procedure is creates the descriptive header in the parameter form
--
-----------------------------------------------------------------------------------------------
   begin

     select to_char(sysdate, 'DD-MON-YYYY') into v_date_time from dual;

     htp.htmlopen;
     htp.headOpen;
     htp.title('Transaction Counts and Deal Sizes');
     htp.headClose;
     htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
     htp.tableOpen('border="0"  ');
     htp.tableRowOpen( calign => 'TOP' );
     --htp.tableData( htf.img(curl=>g_image_prefix||'oppty.gif'));
     htp.tableData( '<FONT size=+1 face="times new roman">' || 'Transaction Counts and Deal Sizes Report', cnowrap => 'TRUE');
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
procedure trans_deal_sizes_paramform is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: trans_deal_sizes_paramform
--
--  DESCRIPTION:  This procedure is main body of the parameter form
--
-----------------------------------------------------------------------------------------------
--Added new sales group on 15-feb-01 by sesundar

     CURSOR cur_sales_group(p_userid	NUMBER) IS
     select grpd.group_id sgi,
            decode(grpd.group_id, grpd.parent_group_id,
            decode(topgrp.manager_flag, 'Y', grptl.group_name,
			    ' *'||grptl.group_name),
            decode(topgrp.manager_flag, 'Y',
            decode(grpd.immediate_parent_flag, 'Y',
				 '-'||grptl.group_name, '--'||grptl.group_name),
            decode(grpd.immediate_parent_flag, 'Y',
		  '  -'||grptl.group_name, '  --'||grptl.group_name))) name
     from jtf_rs_groups_denorm grpd,
          jtf_rs_groups_tl grptl,
       (select distinct grpb.group_id, rrb2.manager_flag
          from jtf_rs_groups_b grpb,
               jtf_rs_role_relations rrel2,
               jtf_rs_roles_b rrb2,
               jtf_rs_resource_extns rsc2,
               jtf_rs_group_members mem,
               fnd_user fnu
         where grpb.group_id = mem.group_id
           and trunc(sysdate) between grpb.start_date_active
           and nvl(grpb.end_date_active, trunc(sysdate))
           and rrb2.role_type_code in ('SALES','TELESALES')
           and (rrb2.manager_flag = 'Y' or rrb2.admin_flag = 'Y')
           and rrel2.role_id = rrb2.role_id
           and trunc(sysdate) between rrel2.start_date_active
           and nvl(rrel2.end_date_active, trunc(sysdate))
           and rrel2.role_resource_type = 'RS_GROUP_MEMBER'
           and rrel2.role_resource_id = mem.group_member_id
           and mem.resource_id = rsc2.resource_id
           and mem.delete_flag='N'
           and rsc2.source_id = fnu.employee_id
           and fnu.user_id = p_userid) topgrp
 where grptl.group_id = grpd.group_id
   and grpd.parent_group_id = topgrp.group_id
   and trunc(sysdate) between grpd.start_date_active
   and nvl(grpd.end_date_active, trunc(sysdate))
 order by 2 desc;

    CURSOR cur_currencies
    IS
    select currency_code
    from fnd_currencies_vl
    where upper(enabled_flag) = 'Y'
    and trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
                       and nvl(end_date_active, trunc(sysdate))
    order by 1;


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


if (icx_sec.validateSession(c_commit => FALSE)) then
       header;

       l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
       -------------------- Returns login user Id--------------------------

       /* set user's currency code */
       v_usr_currency_code := FND_PROFILE.VALUE('JTF_PROFILE_DEFAULT_CURRENCY');

       htp.FormOpen(owa_util.Get_Owa_Service_Path||'ast_ofl_TRANS_SIZES_REPORT.report_wrapper', cattributes => ' NAME="param"');
       htp.htmlopen;
       htp.headOpen;
       htp.title('Event Registration Summary Report');
       htp.p('<SCRIPT language="JavaScript">');
       htp.p('  function validateForm(objform) {');
       htp.p('    var s_day = objform.p_sd_date.selectedIndex;');
       htp.p('    var s_month = objform.p_sm_date.selectedIndex;');
       htp.p('    var s_year = objform.p_sy_date.selectedIndex;');
       htp.p('    var e_day = objform.p_ed_date.selectedIndex;');
       htp.p('    var e_month = objform.p_em_date.selectedIndex;');
       htp.p('    var e_year = objform.p_ey_date.selectedIndex;');
       htp.p('    var p_valid = true;');
       htp.p('       if ((s_month == "3"&&s_day== "30")||(s_month == "5"&&s_day== "30")');
       htp.p('          ||(s_month == "8"&&s_day== "30")||(s_month == "10"&&s_day== "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('       if ((e_month == "3"&&e_day== "30")||(e_month == "5"&&e_day== "30")');
       htp.p('          ||(e_month == "8"&&e_day== "30")||(e_month == "10"&&e_day== "30")){');
       htp.p('          alert(''End Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('       if (s_month == "1"){');
       htp.p('          if ((s_year == "2"||s_year == "6"||s_year == "10"||s_year == "14"||s_year == "18")');
       htp.p('          && (s_day == "29"||s_day == "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       htp.p('       if (s_month == "1"){');
       htp.p('          if ((s_year != "2"&&s_year != "6"&&s_year != "10"&&s_year != "14"&&s_year != "18")');
       htp.p('          && (s_day == "28"||s_day == "29"||s_day == "30")){');
       htp.p('          alert(''Start Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       htp.p('       if (e_month == "1"){');
       htp.p('          if ((e_year == "2"||e_year == "6"||e_year == "10"||e_year == "14"||e_year == "18")');
       htp.p('          && (e_day == "29"||e_day == "30")){');
       htp.p('          alert(''End Date Must be a Valid Date'');');
       htp.p('          p_valid = false;}');
       htp.p('                           }');
       htp.p('       if (e_month == "1"){');
       htp.p('          if ((e_year != "2"&&e_year != "6"&&e_year != "10"&&e_year != "14"&&e_year != "18")');
       htp.p('          && (e_day == "28"||e_day == "29"||e_day == "30")){');
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

     htp.tableRowClose;

       htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="50%" valign="top">Start Date</td>');
       htp.p('<td>');
       --owa_util.choose_date('p_test', sysdate);
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
         FOR i IN 1..12 LOOP
               if i=1 then
               --htp.FormSelectOption(lpad(to_char(i),2,'0'),
                 htp.FormSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
			   cattributes => ' value='||lpad(to_char(i),2,'0'),
                   cselected => 'TRUE' );
               else
               --htp.FormSelectOption(lpad(to_char(i),2,'0'),
                 htp.FormSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
			   cattributes => ' value='||lpad(to_char(i),2,'0'));
               end if;
         END LOOP;
     htp.FormSelectClose;
     htp.p('-');

     htp.p ('<SELECT name="p_sy_date">');
     --  htp.FormSelectOption('   ');
         FOR i IN 1..year_data.count  LOOP
	     IF year_data(i) = TO_CHAR(SYSDATE, 'YYYY') THEN
		 htp.FormSelectOption(year_data(i),
		  cattributes => ' value= '||year_data(i),
		  cselected => 'TRUE');
		ELSE
	           htp.FormSelectOption(year_data(i),
			cattributes => ' value= '||year_data(i));
          END IF;
	    END LOOP;
       htp.FormSelectClose;
     htp.p('</td>');
     htp.tableRowClose;

     htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="50%" valign="top">End Date</td>');
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
         FOR i IN 1..12 LOOP
               if i=1 then
               --htp.FormSelectOption(lpad(to_char(i),2,'0'),
                 htp.FormSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
			   cattributes => ' value='||lpad(to_char(i),2,'0'),
                   cselected => 'TRUE' );
               else
               --htp.FormSelectOption(lpad(to_char(i),2,'0'),
                 htp.FormSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
			   cattributes => ' value='||lpad(to_char(i),2,'0'));
               end if;
         END LOOP;
     htp.FormSelectClose;
     htp.p('-');

     htp.p ('<SELECT name="p_ey_date">');
     --  htp.FormSelectOption('   ');
         FOR i IN 1..year_data.count  LOOP
	     IF year_data(i) = TO_CHAR(SYSDATE, 'YYYY') THEN
		 htp.FormSelectOption(year_data(i),
		  cattributes => ' value= '||year_data(i),
		  cselected => 'TRUE');
		ELSE
	           htp.FormSelectOption(year_data(i),
			cattributes => ' value= '||year_data(i));
          END IF;
         END LOOP;
       htp.FormSelectClose;
     htp.p('</td>');
     htp.tableRowClose;

     htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="50%" valign="top">Are these Close Dates or Creation Dates</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_close_or_entry">');
       htp.FormSelectOption('Creation Dates',
                            cattributes => ' value= '||'ENTRY');
       htp.FormSelectOption('Close Dates',
                            cattributes => ' value= '||'CLOSE',
			                cselected => 'TRUE' );
       htp.FormSelectClose;
     htp.p('</td>');
     htp.tableRowClose;

       htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="50%" valign="top">Sales Group</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_sgp">');
         FOR rec_sales_group IN cur_sales_group(l_user_id)  LOOP
           htp.FormSelectOption(rec_sales_group.name,cattributes => ' value= '||rec_sales_group.sgi);
           --htp.FormSelectOption(rec_sales_group.name,cattributes => ' value= '||7062);
         END LOOP;
       htp.FormSelectClose;
       htp.p('</td>');
       htp.tableRowClose;
     --htp.p('<INPUT type=button value="Submit" onClick="populate1();return true" >');

     htp.tableRowOpen();
     htp.p('<td align="RIGHT" width="50%"valign="top">Reporting Currency</td>');
     htp.p('<td>');
     htp.p ('<SELECT name="p_crcy">');
     FOR rec_currencies IN cur_currencies
     LOOP
         if rec_currencies.currency_code = v_usr_currency_code
         then
            htp.FormSelectOption(rec_currencies.currency_code, cselected => 'TRUE');
         else
            htp.FormSelectOption(rec_currencies.currency_code);
         end if;
     END LOOP;
     htp.FormSelectClose;
     htp.p('</td>');
     htp.tableRowClose;
     htp.tableClose;

     htp.tableOpen(cattributes=>'border="0" width="80%"');
     htp.tableRowOpen;
     htp.p('<td align = "center" width="100%">');
     htp.p('Groups and Totals');
     htp.p('<input type="radio" value="NON-REPEATING" checked name="p_repeat_values">');
     htp.p('&nbsp;');
     htp.p('Repeating Values');
     htp.p('<input type="radio" name="p_repeat_values" value="REPEATING">');
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

     rollback;

     exception
        when others then
                htp.p(SQLERRM);
   END trans_deal_sizes_paramform;


   procedure footer is
   BEGIN
      l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
      htp.htmlopen;
      htp.tableRowOpen;
      htp.tableData( htf.hr, crowspan => '1', ccolspan => '190', cnowrap => 'TRUE');
      htp.tableRowClose;
      htp.tableOpen( calign => 'center', cattributes => ' border=0 cellspacing=2 cellpadding=2' );
      htp.tableRowOpen;
      htp.formOpen( curl => l_agent||'ast_ofl_TRANS_SIZES_REPORT.report_wrapper', cmethod => 'post', cattributes => ' NAME="MyForm" TARGET="_top"');
      --htp.tableData( htf.formSubmit( cvalue => 'OK', cattributes => ' onMouseOver="window.status=''OK'';return true"'));
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
