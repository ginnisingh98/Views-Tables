--------------------------------------------------------
--  DDL for Package Body JTF_TERR_DEFINITION_PARAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_DEFINITION_PARAM_PVT" AS
/* $Header: jtftrpdb.pls 120.0 2005/06/02 18:21:45 appldev ship $ */

--
--g_image_prefix varchar2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
   l_user_id      number;
   v_date_time    varchar2(30);
   l_agent        varchar2(200);
   ctr1           integer        := 0;
   ctr2           integer        := 0;
--   G_DATE_FORMAT  varchar2(20)   := as_ofl_util_pkg.get_date_format;
   G_DATE_FORMAT  varchar2(20)  := 'MM/DD/YY';


  procedure header is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: header
--
--  DESCRIPTION:  This procedure is creates the descriptive header in the parameter form
--
-----------------------------------------------------------------------------------------------
   begin
     select to_char(sysdate,G_DATE_FORMAT) into v_date_time from dual;
     htp.htmlopen;
     htp.headOpen;
     htp.title('Territory Defintion Report');
     htp.headClose;
     htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
     htp.tableOpen('border="0"  ');
     htp.tableRowOpen( calign => 'TOP' );
     --htp.tableData( htf.img(curl=>'terman32.gif'));
     htp.tableData( '<FONT size=+1 face="times new roman">' || 'Territory Definition Report', cnowrap => 'TRUE');
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
procedure terr_definition_paramform is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: terr_definition_paramform
--
--  DESCRIPTION:  This procedure is main body of the parameter form
--
-----------------------------------------------------------------------------------------------

/* this resource cursor to be used in final delivery*/
Cursor cur_salesrep is
    select -1 resource_id, 'ALL' resource_name
    from dual
 union
    select distinct resource_id, wf_notification.substitutespecialchars(resource_name) resource_name
    from jtf_terr_resources_v
    order by resource_name;

/* qualifier cursor */
Cursor cur_qual is
    select -1  qual_usg_id ,'ALL' seeded_qual_name
    from dual
 union
    select qual_usg_id , wf_notification.substitutespecialchars(usage) || ' - ' ||
                         wf_notification.substitutespecialchars(seeded_qual_name) seeded_qual_name
    from jtf_seeded_qual_usgs_v
    where enabled_flag = 'Y' and not (qual_type_id = -1001)
 order by seeded_qual_name;

BEGIN

 fnd_client_info.set_org_context(fnd_profile.value('ORG_ID'));

if (icx_sec.validateSession(c_function_code => 'JTF_TERR_DFN_RPT', c_validate_only => 'Y')) then
       header;

       l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
       -------------------- Returns login user Id--------------------------
       htp.FormOpen(owa_util.Get_Owa_Service_Path||'JTF_TERR_DEFINITION_REPORT_PVT.report_wrapper', cattributes => ' NAME="param"');
       htp.htmlopen;
       htp.headOpen;
       htp.title('Territory Definition Report');
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
/* Output format control */
       htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="35%"valign="top">Select Output Format</td>');
       htp.p('<td>');
       htp.p('<SELECT name="p_response">');
       htp.FormSelectOption('Excel');
       htp.FormSelectOption('HTML', cselected => 'TRUE');
       htp.FormSelectClose;
       htp.tableRowClose;
/* Sales Rep Search Restriction */
       htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="32%" valign="top">Sales Rep</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_srp">');
         FOR rec_salesrep IN cur_salesrep  LOOP
           htp.FormSelectOption(rec_salesrep.resource_name,cattributes => ' value= '||rec_salesrep.resource_id);
         END LOOP;
       htp.FormSelectClose;
       htp.p('</td>');
       htp.tableRowClose;
/* Qualifier Search Restriction */
     htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="32%" valign="top">Qualifiers</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_qual">');
         FOR rec_qual IN cur_qual LOOP
           htp.FormSelectOption(rec_qual.seeded_qual_name, cattributes => ' value= '||rec_qual.qual_usg_id);
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
   END terr_definition_paramform;


   procedure footer is
   BEGIN
      l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
      htp.htmlopen;
      htp.tableRowOpen;
      htp.tableData( htf.hr, crowspan => '1', ccolspan => '190', cnowrap => 'TRUE');
      htp.tableRowClose;
      htp.tableOpen( calign => 'center', cattributes => ' border=0 cellspacing=2 cellpadding=2' );
      htp.tableRowOpen;
      htp.formOpen( curl => l_agent||'JTF_TERR_DEFINITION_REPORT_PVT.report_wrapper', cmethod => 'post', cattributes => ' NAME="MyForm" TARGET="_top"');
      htp.tableData( htf.formSubmit( cvalue => 'OK', cattributes => ' onMouseOver="window.status=''OK'';return true"'));
      htp.tableData( '<INPUT type=button value="Cancel" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
      htp.tableRowClose;
      htp.tableClose;
      htp.htmlClose;
   END footer;
END;

/
