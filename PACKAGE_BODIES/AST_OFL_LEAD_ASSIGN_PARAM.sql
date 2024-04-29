--------------------------------------------------------
--  DDL for Package Body AST_OFL_LEAD_ASSIGN_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_OFL_LEAD_ASSIGN_PARAM" 
 /* $Header: astrtlpb.pls 115.8 2002/02/05 17:27:38 pkm ship   $ */
AS

/*
	Date			Remarks
	----------	------------------------------------------------
	05/30/2001     Created
*/

  TYPE day_table IS
    TABLE OF	VARCHAR2(2000)
    INDEX BY	BINARY_INTEGER;

  TYPE year_table IS
    TABLE OF	VARCHAR2(2000)
    INDEX BY	BINARY_INTEGER;

  g_image_prefix		VARCHAR2(250) := '/OA_MEDIA/' || icx_sec.getid(icx_sec.pv_language_code) || '/';
  l_user_id			NUMBER;
  v_date_time			VARCHAR2(30);
  l_agent				VARCHAR2(200);
  ctr1				INTEGER := 0;
  ctr2				INTEGER := 0;
  l_test			 	owa_util.dateType;
  day_data			day_table;
  year_data			year_table;

  -- variable for supporting multi-currency
  v_usr_currency_code	VARCHAR2(15);
--------------------------------------------------------------------------------
  PROCEDURE header IS
  BEGIN
    SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY')
    INTO v_date_time
    FROM DUAL;

    htp.htmlOpen;
    htp.headOpen;
    htp.title('Lead Assignment');
    htp.headClose;
    htp.bodyOpen(cAttributes => 'bgcolor="#CCCCCC"');
    htp.tableOpen('border="0"  ');
    htp.tableRowOpen(cAlign => 'TOP');


    htp.tableData('<FONT size=+1 face="times new roman">' || 'Lead Assignment Report', cNoWrap => 'TRUE');
    htp.tableData(htf.bold(v_date_time), cAlign => 'right', cColSpan => '110');
    htp.tableRowClose;
    htp.tableClose;
    htp.tableOpen(cAttributes => 'border=0 cellspacing=0 cellpadding=0 width=561');
    htp.tableRowOpen(cVAlign => 'top');
    htp.tableData(' ', cColSpan => '2', cAttributes => ' height=9');
    htp.tableData('<FONT face="Times New Roman">' || htf.bold('Please specify the criteria and select OK.  ') || '</FONT>', cAlign => 'center', cRowSpan => '2', cColSpan => '110', cAttributes => ' width=346');
    htp.tableData(' ', cColSpan => '6');
    htp.br;
    htp.tableRowClose;
    htp.tableClose;
    htp.bodyClose;
    htp.headClose;
    htp.htmlClose;
  END;
--------------------------------------------------------------------------------
  PROCEDURE lead_assign_param_form IS
    day_counter         NUMBER := 1;
    year_counter        NUMBER := 1990;
    probability_counter NUMBER := 1;

    CURSOR Cur_Sales_Group(P_Userid NUMBER) IS
    SELECT grpd.group_id sgi
	    , DECODE(grpd.group_id
                , grpd.parent_group_id
                , DECODE(topgrp.manager_flag
                       , 'Y'
                       , grptl.group_name, ' *'||grptl.group_name
                        )
                , DECODE(topgrp.manager_flag
                       , 'Y'
                       , DECODE(grpd.immediate_parent_flag
                              , 'Y'
                              , '-'||grptl.group_name, '--'||grptl.group_name
                               )
                       , DECODE(grpd.immediate_parent_flag
                              , 'Y'
                              , '  -'||grptl.group_name, '  --'||grptl.group_name
                               )
                        )
                 ) name
    FROM Jtf_rs_groups_denorm grpd
       , Jtf_rs_groups_tl grptl
       , (SELECT DISTINCT grpb.group_id
                        , rrb2.manager_flag
          FROM Jtf_rs_groups_b grpb
             , Jtf_rs_role_relations rrel2
             , Jtf_rs_roles_b rrb2
             , Jtf_rs_resource_extns rsc2
             , Jtf_rs_group_members mem
             , Fnd_user fnu
          WHERE grpb.group_id = mem.group_id
            AND TRUNC(SYSDATE) BETWEEN grpb.start_date_active
                                   AND NVL(grpb.end_date_active, TRUNC(SYSDATE))
            AND rrb2.role_type_code IN ('SALES', 'TELESALES')
            AND (rrb2.manager_flag = 'Y'
              OR rrb2.admin_flag = 'Y')
            AND rrel2.role_id = rrb2.role_id
            AND TRUNC(SYSDATE) BETWEEN rrel2.start_date_active
                                   AND NVL(rrel2.end_date_active, TRUNC(SYSDATE))
            AND rrel2.role_resource_type = 'RS_GROUP_MEMBER'
            AND rrel2.role_resource_id = mem.group_member_id
		  -- Begin Mod Raam on 02.27.2001
            AND mem.delete_flag = 'N'
		  -- End Mod.
            AND mem.resource_id = rsc2.resource_id
            AND rsc2.source_id = fnu.employee_id
            AND fnu.user_id = P_Userid) topgrp
    WHERE grptl.group_id = grpd.group_id
      AND grpd.parent_group_id = topgrp.group_id
      AND TRUNC(SYSDATE) BETWEEN grpd.start_date_active
      AND NVL(grpd.end_date_active, TRUNC(SYSDATE))
    ORDER BY 2 DESC;

    CURSOR cur_sales_rep(iUserID NUMBER) IS
	select distinct source_id pid, source_name flname
	from JTF_RS_RESOURCE_EXTNS
	where source_id in (
	    select distinct b.person_id
	    from jtf_rs_rep_managers b, JTF_RS_RESOURCE_EXTNS a
	    where b.manager_person_id = a.source_id
	    and a.user_id = iUserID
	);

/*
     select distinct rsc.source_id pid,
                     rsc.source_name flname
      from jtf_rs_resource_extns rsc,
           jtf_rs_group_members gmem,
           jtf_rs_role_relations rrel,
           jtf_rs_roles_b rrb,
           (select distinct grpd.group_id
              from jtf_rs_groups_denorm grpd,
                   jtf_rs_role_relations rrel2,
                   jtf_rs_roles_b rrb2,
                   jtf_rs_resource_extns rsc2,
                   jtf_rs_group_members mem,
                   fnd_user fnu
             where grpd.parent_group_id = mem.group_id
               and nvl(grpd.end_date_active, trunc(sysdate)) >= trunc(sysdate)
               and rrb2.role_type_code in ('SALES','TELESALES')
               and (rrb2.admin_flag = 'Y' or rrb2.manager_flag = 'Y')
               and rrel2.role_id = rrb2.role_id
               and trunc(sysdate) between rrel2.start_date_active
                   and nvl(rrel2.end_date_active, trunc(sysdate))
               and rrel2.role_resource_type = 'RS_GROUP_MEMBER'
               and rrel2.role_resource_id = mem.group_member_id
               and mem.resource_id = rsc2.resource_id
               and mem.delete_flag='N'
               and rsc2.source_id = fnu.employee_id
               and fnu.user_id = fnd_global.user_id) grps
     where gmem.group_id = grps.group_id
       and rsc.resource_id = gmem.resource_id
       and rrel.role_resource_id = gmem.group_member_id
       and trunc(sysdate) between rrel.start_date_active
              and nvl(rrel.end_date_active, trunc(sysdate))
       and rrb.role_type_code in ('SALES','TELESALES')
       and rrb.admin_flag = 'N'
       and rrel.role_id = rrb.role_id
       and rrel.role_resource_type = 'RS_GROUP_MEMBER'
       and gmem.delete_flag='N'
   UNION
   select distinct rsc.source_id pid,
           rsc.source_name flname
      from jtf_rs_resource_extns rsc,
           fnd_user fnu
      where rsc.source_id = fnu.employee_id
      and fnu.user_id = fnd_global.user_id
      order by 2;
*/

  BEGIN
    FOR i IN 1..31 LOOP
      IF day_counter <= 9 THEN
        day_data(i) := '0' || day_counter;
        day_counter := day_counter + 1;
      ELSE
        day_data(i) := TO_CHAR(day_counter);
        day_counter := day_counter + 1;
      END IF;
    END LOOP;

    FOR i IN 1..21 LOOP
      year_data(i) := TO_CHAR(year_counter);
      year_counter := year_counter + 1;
    END LOOP;

    IF (icx_sec.validateSession) THEN
      header;
      l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
      -- Returns login user Id
      -- set user's currency code
      v_usr_currency_code := FND_PROFILE.Value('JTF_PROFILE_DEFAULT_CURRENCY');
      htp.formOpen(owa_util.Get_Owa_Service_Path || 'AST_OFL_LEADASSIGN_RPT_PKG.lead_assign_rpt_wrapper', cAttributes => ' NAME="param"');
      htp.htmlOpen;
      htp.headOpen;
      htp.title('Lead Assignment Report');
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
      htp.bodyOpen(cAttributes => 'bgcolor="#CCCCCC"');
      htp.tableOpen;
      htp.tableRowOpen(cVAlign => 'top');
      htp.tableData(' ', cAttributes => ' height=9');
      htp.tableData('<FONT size=2 face="Times New Roman">' || '</FONT>', cAlign => 'right', cRowSpan => '2', cColSpan => '3', cAttributes => ' width=154');
      htp.tableData( ' ');
      htp.tableRowClose;
      htp.tableClose;
      htp.tableOpen(cAttributes => 'width="600" ');
      htp.tableRowOpen();
-- htp.p(L_USER_ID);
      htp.p('<td align="RIGHT" width="50%"valign="top">Select Output Format</td>');
      htp.p('<td>');
      htp.p('<SELECT name="p_response">');
      htp.formSelectOption('Excel');
      htp.formSelectOption('HTML', cSelected => 'TRUE');
      htp.formSelectClose;
      htp.tableRowClose;
      htp.tableRowClose;
      htp.tableRowOpen();
      htp.p('<td align="RIGHT" width="50%" valign="top">Please Enter Start Date</td>');
      htp.p('<td>');
      htp.p('<SELECT name="p_sd_date">');
      FOR i IN 1..day_data.count LOOP
        htp.formSelectOption(day_data(i),
		cAttributes => ' value= ' || day_data(i),
		cSelected => 'TRUE' );
      END LOOP;
      htp.formSelectClose;
      htp.p('-');
      htp.p('<SELECT name="p_sm_date">');
      FOR i IN 1..12 LOOP
        IF i = 1 THEN
          htp.formSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
		  cAttributes => ' value=' || LPAD(TO_CHAR(i), 2, '0'),
		  cSelected => 'TRUE');
        ELSE
          htp.formSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
		  cAttributes => ' value=' || LPAD(TO_CHAR(i), 2, '0'));
        END IF;
      END LOOP;
      htp.formSelectClose;
      htp.p('-');
      htp.p('<SELECT name="p_sy_date">');
      FOR i IN 1..year_data.count LOOP
	   IF year_data(i) = TO_CHAR(SYSDATE, 'YYYY') THEN
          htp.formSelectOption(year_data(i),
		  cAttributes => ' value= ' || year_data(i),
		  cSelected => 'TRUE');
        ELSE
          htp.formSelectOption(year_data(i),
		  cAttributes => ' value= ' || year_data(i));
	   END IF;
      END LOOP;
      htp.formSelectClose;
      htp.p('</td>');
      htp.tableRowClose;
      htp.tableRowOpen();
      htp.p('<td align="RIGHT" width="50%" valign="top">Please Enter End Date</td>');
      htp.p('<td>');
      htp.p('<SELECT name="p_ed_date">');
      FOR i IN 1..day_data.count LOOP
        htp.formSelectOption(day_data(i),
		cAttributes => ' value= ' || day_data(i),
		cSelected => 'TRUE' );
      END LOOP;
      htp.formSelectClose;
      htp.p('-');
      htp.p('<SELECT name="p_em_date">');
      FOR i IN 1..12 LOOP
        IF i=1 THEN
          htp.formSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
		  cAttributes => ' value=' || LPAD(TO_CHAR(i), 2, '0'),
		  cSelected => 'TRUE');
        ELSE
          htp.formSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
		  cAttributes => ' value=' || LPAD(TO_CHAR(i), 2, '0'));
        END IF;
      END LOOP;
      htp.formSelectClose;
      htp.p('-');
      htp.p ('<SELECT name="p_ey_date">');
      FOR i IN 1..year_data.count LOOP
	   IF year_data(i) = TO_CHAR(SYSDATE, 'YYYY') THEN
          htp.formSelectOption(year_data(i),
	  	  cAttributes => ' value= ' || year_data(i),
		  cSelected => 'TRUE' );
        ELSE
          htp.formSelectOption(year_data(i),
	  	  cAttributes => ' value= ' || year_data(i));
        END IF;
      END LOOP;
      htp.formSelectClose;
      htp.p('</td>');
      htp.tableRowClose;
      htp.tableRowOpen();
      --htp.p('<td align="RIGHT" width="50%" valign="top">Are these Close Dates or Creation Dates</td>');
      --htp.p('<td>');
      --htp.p ('<SELECT name="p_close_or_entry">');
      --htp.formSelectOption('Creation Dates',
	--   cAttributes => ' value= ' || 'ENTRY');
      --htp.formSelectOption('Close Dates',
	--   cAttributes => ' value= ' || 'CLOSE',
	--   cSelected => 'TRUE' );
      --htp.formSelectClose;
      --htp.p('</td>');
      htp.tableRowClose;
      --htp.tableRowOpen();
      --htp.p('<td align="RIGHT" width="50%" valign="top">Sales Group</td>');
      --htp.p('<td>');
      --htp.p('<SELECT name="p_sgp">');
      --FOR rec_sales_group IN cur_sales_group(l_user_id) LOOP
      --  htp.formSelectOption(rec_sales_group.name, cAttributes => ' value= ' || rec_sales_group.sgi);
        --htp.formSelectOption(rec_sales_group.name, cAttributes => ' value= ' || 7062);
      --END LOOP;
      --htp.formSelectClose;
      --htp.p('</td>');
      --htp.tableRowClose;
	htp.tableRowOpen();
	htp.p('<td align="RIGHT" width="32%" valign="top">Sales Rep</td>');
	htp.p('<td>');
	htp.p ('<SELECT name="p_srp">');
	FOR rec_sales_rep IN cur_sales_rep(l_user_id) LOOP
		IF rec_sales_rep.flname ='ALL' THEN
			htp.formSelectOption(rec_sales_rep.flname, cAttributes => ' value= ' || rec_sales_rep.pid, cSelected => 'TRUE');
		ELSE
			htp.formSelectOption(rec_sales_rep.flname, cAttributes => ' value= ' || rec_sales_rep.pid);
		END IF;
	END LOOP;
	htp.formSelectOption('ALL', cAttributes => ' value= -1');
	htp.formSelectOption('All My Team', cAttributes => ' value= -2');
	htp.formSelectClose;
	htp.p('</td>');
	htp.tableRowClose;
      htp.tableClose;
      htp.br;
      htp.br;
      htp.br;
      footer;
      htp.formClose;
      htp.bodyClose;
      htp.htmlClose;
      rollback;
    ELSE
      htp.p('Invalid session');
    END IF;
  EXCEPTION
    WHEN others THEN
      htp.p(SQLERRM);
  END lead_assign_param_form;
--------------------------------------------------------------------------------
  PROCEDURE footer IS
  BEGIN
    l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
    htp.htmlOpen;
    htp.tableRowOpen;
    htp.tableData(htf.hr, cRowSpan => '1', cColSpan => '190', cNoWrap => 'TRUE');
    htp.tableRowClose;
    htp.tableOpen(cAlign => 'center', cAttributes => ' border=0 cellspacing=2 cellpadding=2');
    htp.tableRowOpen;
    htp.formOpen(cUrl => l_agent || 'ast_ofl_pipeline_buckets_rpt.report_wrapper', cMethod => 'post', cAttributes => ' NAME="MyForm" TARGET="_top"');
-- htp.tableData(htf.formSubmit(cValue => 'OK', cAttributes => ' onMouseOver="window.status=''OK'';return true"'));
    htp.p('<td>');
    htp.p('<INPUT TYPE="BUTTON" VALUE="OK" onClick="validateForm(document.param)">');
    htp.p('</td>');
  --htp.tableData('<INPUT type=button value="Cancel" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
    htp.tableData( '<INPUT type=button value="Reset" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
    htp.tableData( '<INPUT type=button value="Cancel" onClick="window.close()" onMouseOver="window.status="Close";return true">');
    htp.tableRowClose;
    htp.tableClose;
    htp.htmlClose;
  END footer;
END;

/
