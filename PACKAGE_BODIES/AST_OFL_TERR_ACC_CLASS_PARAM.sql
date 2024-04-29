--------------------------------------------------------
--  DDL for Package Body AST_OFL_TERR_ACC_CLASS_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_OFL_TERR_ACC_CLASS_PARAM" AS
 /* $Header: astrtapb.pls 115.10 2002/02/06 14:27:40 pkm ship   $ */

--g_image_prefix varchar2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
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
     htp.title('Account Classification Report');
     htp.headClose;
     htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
     htp.tableOpen('border="0"  ');
     htp.tableRowOpen( calign => 'TOP' );
     --htp.tableData( htf.img(curl=>g_image_prefix||'oppty.gif'));
     htp.tableData( '<FONT size=+1 face="times new roman">' || 'Account Classification Report', cnowrap => 'TRUE');
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
procedure terr_acc_class_param is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: Territories - Account Classification Report
--
--  DESCRIPTION:  This procedure is main body of the parameter form
--
-----------------------------------------------------------------------------------------------
/*
   cursor cur_terr_group is select territory_group_id , name

-- Changed for 11i AJScott
--   from  as_territory_groups;
    from as_territory_groups_all;

   rec_terr_group cur_terr_group%rowtype;
*/

   BEGIN


if (icx_sec.validateSession) then
       header;

       l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
       -------------------- Returns login user Id--------------------------
       htp.FormOpen(owa_util.Get_Owa_Service_Path||'AST_OFL_TERR_acc_class_report.report_wrapper',
                             cattributes => ' NAME="param"');
       htp.htmlopen;
       htp.headOpen;
       htp.title('Account Classification Report');
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
     htp.p('<td align="RIGHT" valign="top">Customer Name</td>');
     htp.p('<td>');
     htp.FormText('p_customer_name','50');
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
 END terr_acc_class_param;

 procedure footer is
 BEGIN
      l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
      htp.htmlopen;
      htp.tableRowOpen;
      htp.tableData( htf.hr, crowspan => '1', ccolspan => '190', cnowrap => 'TRUE');
      htp.tableRowClose;
      htp.tableOpen( calign => 'center', cattributes => ' border=0 cellspacing=2 cellpadding=2' );
      htp.tableRowOpen;
      htp.formOpen( curl => l_agent||'/AST_OFL_TERR_acc_class_report.report_wrapper', cmethod => 'GET',
                              cattributes => ' NAME="MyForm" TARGET="_top"');
        htp.tableData( htf.formSubmit( cvalue => 'OK', cattributes => ' onMouseOver="window.status=''OK'';return true"'));

      --htp.tableData( '<INPUT type=button value="Cancel" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
      htp.tableData( '<INPUT type=button value="Reset" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
      htp.tableData( '<INPUT type=button value="Cancel" onClick="window.close()" onMouseOver="window.status="Close";return true">');
      htp.tableRowClose;
      htp.tableClose;
      htp.htmlClose;
   END footer;
END;

/
