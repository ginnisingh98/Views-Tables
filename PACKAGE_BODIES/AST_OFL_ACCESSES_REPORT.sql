--------------------------------------------------------
--  DDL for Package Body AST_OFL_ACCESSES_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_OFL_ACCESSES_REPORT" 
 /* $Header: astrtacb.pls 115.10 2002/02/06 12:33:03 pkm ship  $ */
AS
        g_image_prefix          VARCHAR2(250) := '/OA_MEDIA/' || icx_sec.getid(icx_sec.pv_language_code) || '/';
        l_agent                 VARCHAR2(200);
        l_sgrp_name             VARCHAR2(60);
        l_user_id               NUMBER;
        l_groups_found          BOOLEAN;  --Added by Thanh Huynh 01/27/01
        l_flname                VARCHAR2(60);
        l_pid                   NUMBER;
        v_date_time             VARCHAR2(30);
        v_sales_group_id        NUMBER        := NULL;  --Variables for sales group & rep
        v_salesrep_id           NUMBER        := NULL;
        v_tab                   VARCHAR2(1);
        v_tabrow                VARCHAR2(2000);
----------------------------------------------------------------------------------------------------

PROCEDURE header
IS
BEGIN
    SELECT  to_char(SYSDATE,'DD-MON-YYYY')
      INTO  v_date_time
      FROM  dual;

    htp.htmlOpen;
    htp.headOpen;
    htp.title('Accesses Report');
    htp.headClose;
    htp.bodyOpen(cAttributes => 'bgcolor="#CCCCCC"');
    htp.tableOpen();
    htp.tableRowOpen(cAlign => 'TOP');
    htp.tableData( '<FONT size=+1 face="Times New Roman">' || 'Accesses Report', cnowrap => 'TRUE');
    htp.tableData(htf.bold(v_date_time), cAlign => 'right', cColSpan => '110');
    htp.tableRowClose;
    htp.tableClose;
    htp.tableOpen(cAttributes => ' border=0 cellspacing=0 cellpadding=0 width=561' );
    htp.tableRowOpen(cVAlign => 'top' );
    htp.tableData(' ', cColSpan => '2', cAttributes => ' height=9');
    htp.tableData('<FONT face="Times New Roman">' || htf.bold( 'Please specify the criteria and select OK.  ') || '</FONT>', cAlign => 'center', cRowSpan => '2', cColSpan => '110', cAttributes => ' width=346');
    htp.tableData(' ', cColSpan => '6');
    htp.br;
    htp.tableRowClose;
    htp.tableClose;
    htp.bodyClose;
    htp.headClose;
    htp.htmlClose;
END;

----------------------------------------------------------------------------------------------------
PROCEDURE accesses_paramform
IS


--for sales group

 CURSOR cur_sales_group(p_userid     NUMBER) IS
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

--for sales rep

    CURSOR cur_sales_rep IS
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

BEGIN

    IF (icx_sec.validateSession(c_commit => FALSE))
    THEN
      l_user_id := icx_sec.getID(icx_sec.pv_user_id);  -- Returns login user Id
      htp.formOpen(owa_util.Get_Owa_Service_Path || 'ast_ofl_accesses_report_pkg.accesses_wrapper', cattributes => ' NAME="param"');
        header;
        htp.htmlOpen;
        htp.headOpen;
        htp.title('Accesses Report');
        htp.headClose;
        footer;

        htp.bodyOpen(cAttributes => 'bgcolor="#CCCCCC"');
        htp.tableOpen;
        htp.tableRowOpen(cVAlign => 'top');
        htp.tableData(' ', cAttributes => ' height=9');
        htp.tableData('<FONT size=2 face="Times New Roman">' || '</FONT>',
                      cAlign => 'right',
                      cRowSpan => '2',
                      cColSpan => '3',
                      cAttributes => ' width=154');
        htp.tableData(' ');
        htp.tableRowClose;
        htp.tableClose;

        htp.tableOpen(cAttributes => 'width="700"');
        htp.tableRowOpen();
        htp.p('<td align="RIGHT" width="50%"valign="top">Select Output Format</td>');
        htp.p('<td>');
        htp.p('<SELECT name="p_response">');
        htp.formSelectOption('Excel');
        htp.formSelectOption('HTML',cSelected => 'TRUE');
        htp.formSelectClose;
        htp.tableRowClose;

        htp.tableRowOpen();
        htp.p('<td align="RIGHT" width="32%" valign="top">Sales Group</td>');
        htp.p('<td>');
        htp.p('<SELECT name="p_sgp">');

        /* Changed by Thanh Huynh 01/27/01 */
        l_groups_found := FALSE;
        FOR rec_sales_group IN  cur_sales_group(l_user_id)
        LOOP
            htp.formSelectOption(rec_sales_group.name, cAttributes => ' value= ' || rec_sales_group.sgi);
        l_groups_found := TRUE;
        END LOOP;
        htp.formSelectClose;
        htp.p('</td>');
        htp.tableRowClose;
        htp.tableRowOpen();
        htp.p('<td align="RIGHT" width="32%" valign="top">Sales Rep</td>');
        htp.p('<td>');
        htp.p('<SELECT name="p_srp">');
       /* Changed by Thanh Huynh 01/27/01 */
        IF l_groups_found
        THEN
           htp.formSelectOption('ALL', cAttributes => ' value= -999', cSelected
=> 'TRUE');
           FOR rec_sales_rep IN cur_sales_rep
           LOOP
              htp.formSelectOption(rec_sales_rep.flname,
                               cAttributes => ' value= ' || rec_sales_rep.pid);

           END LOOP;
        ELSE
           SELECT rsc.source_name, rsc.source_id
             INTO l_flname, l_pid
             FROM jtf_rs_resource_extns rsc,
                  fnd_user fnu
            WHERE rsc.source_id = fnu.employee_id
              AND fnu.user_id = fnd_global.user_id;
              htp.formSelectOption(l_flname,
                               cAttributes => ' value= ' || l_pid);
        END IF;
        /* End of Changes by Thanh Huynh 01/27/01 */

/* Commented by sesundar on 30-jan-01
        FOR rec_sales_rep IN cur_sales_rep
        LOOP
            IF rec_sales_rep.flname ='ALL' THEN
                htp.formSelectOption(rec_sales_rep.flname,
                               cAttributes => ' value= ' || rec_sales_rep.pid,
                               cSelected => 'TRUE');
            ELSE
                htp.formSelectOption(rec_sales_rep.flname,
                               cAttributes => ' value= ' || rec_sales_rep.pid);
            END IF;
        END LOOP; */
        htp.formSelectClose;
        htp.p('</td>');
        htp.tableRowClose;

        htp.tableRowOpen();
        htp.p('<td align="RIGHT" width="50%"valign="top">Access Type</td>');
        htp.p('<td>');
        htp.p('<SELECT name="p_access_type">');
        htp.formSelectOption('Account',cSelected => 'TRUE');
        htp.formSelectOption('Opportunity');
        htp.formSelectOption('Lead');
        htp.formSelectClose;
        htp.tableRowClose;

        htp.tableClose;
        htp.Br;
        htp.Br;
        htp.Br;
        footer;
        htp.FormClose;
        htp.bodyclose;
        htp.htmlclose;
    ELSE
        htp.p('Invalid session');
    END IF;

    EXCEPTION
        WHEN OTHERS THEN htp.p(SQLERRM);

END accesses_paramform;

PROCEDURE footer
IS
BEGIN
    l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
    htp.htmlOpen;
    htp.tableRowOpen;
    htp.tableData(htf.hr, cRowSpan => '1', cColSpan => '190', cNoWrap => 'TRUE');
    htp.tableRowClose;
    htp.tableOpen(cAlign => 'center', cAttributes => ' border=0 cellspacing=2 cellpadding=2');
    htp.tableRowOpen;
    htp.formOpen(owa_util.Get_Owa_Service_Path || 'ast_ofl_accesses_report_pkg.accesses_wrapper', cAttributes => ' NAME="param"');
    htp.tableData(htf.formSubmit(cValue => 'OK', cAttributes => ' onMouseOver="window.status=''OK'';return true"'));
    htp.tableData( '<INPUT type=button value="Reset" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
    htp.tableData( '<INPUT type=button value="Cancel" onClick="window.close()" onMouseOver="window.status="Close";return true">');
    htp.tableRowClose;
    htp.tableClose;
    htp.htmlClose;
END footer;

END AST_OFL_ACCESSES_REPORT;

/
