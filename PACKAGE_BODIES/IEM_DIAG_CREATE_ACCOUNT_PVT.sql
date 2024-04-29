--------------------------------------------------------
--  DDL for Package Body IEM_DIAG_CREATE_ACCOUNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DIAG_CREATE_ACCOUNT_PVT" AS
/* $Header: iemdactb.pls 115.3 2003/10/10 00:33:38 chtang noship $ */

PROCEDURE init IS
  BEGIN
    null;
  END init;


PROCEDURE cleanup IS
  BEGIN
    null;
  END cleanup;

PROCEDURE runTest(inputs IN JTF_DIAG_INPUTTBL,
                  reports OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB) IS
   reportStr   LONG;
   counter     NUMBER;
   dummy_v2t   JTF_DIAGNOSTIC_COREAPI.v2t;
   c_userid    VARCHAR2(50);
   c_domain    VARCHAR2(100);
   statusStr   VARCHAR2(50) := 'SUCCESS';
   errStr      VARCHAR2(4000);
   fixInfo     VARCHAR2(4000);
   isFatal     VARCHAR2(50);
   l_accounts varchar2(5000);
   l_db_link   iem_db_connections.db_link%type;
   l_db_name   iem_db_servers.db_name%type;
   l_db_server_tbl	  jtf_varchar2_Table_100:=jtf_varchar2_Table_100();
   l_count 	number;
   l_link_count number;

   l_db_server_rec		iem_db_servers%rowtype;
   l_account_rec		iem_diag_oes_rule_pvt.account_type;
   Type get_account_rec is REF CURSOR ;
   email_account_cur		get_account_rec;
   l_str VARCHAR2(5000);
   l_ret NUMBER;
   l_stat	varchar2(10);
   l_data	varchar2(255);
   l_im_link varchar2(200);
   l_im_link1 varchar2(200);
   l_ret          number:=0;
   l_ret1         BINARY_INTEGER:=0;
   rpc_error 	EXCEPTION;
   rpc_error2   EXCEPTION;
   PRAGMA    EXCEPTION_INIT(rpc_error, -28576);
   PRAGMA    EXCEPTION_INIT(rpc_error2, -28575);

BEGIN
   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

	FND_MSG_PUB.initialize;

  c_userid := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM6'), inputs);
  c_domain := JTF_DIAGNOSTIC_ADAPTUTIL.getInputValue(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM7'), inputs);

  	select count(*) into l_count from iem_db_servers;

  	if (l_count = 0) then
  		statusStr := 'FAILURE';
      		errStr := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_ERROR1');
      		fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      		reportStr := reportStr || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM5') || '</font><br>';
      		isFatal := 'FALSE';
  	elsif (l_count > 1) then
  		statusStr := 'FAILURE';
  		errStr := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_ERROR1');
  		reportStr := reportStr || '<font color=red> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM4') || '</font><br>';
      		fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      		isFatal := 'FALSE';

	else

	   select * into l_db_server_rec from iem_db_servers;

	   IEM_DB_CONNECTIONS_PVT.select_item(
               		p_api_version_number =>1.0,
                 	p_db_server_id  =>l_db_server_rec.db_server_id,
               		p_is_admin =>'A',
  			x_db_link=>l_im_link1,
  			x_return_status =>l_stat,
  			x_msg_count    => l_count,
  			x_msg_data      => l_data);


		If l_im_link1 is null then
  	   		l_im_link:=null;
		else
   		 	l_im_link:='@'||l_im_link1;
		end if;

		l_str:='begin dapls.acct_create'||l_im_link||'(:p_admin_id, :p_admin_pass, :p_oes_database, :p_domain, :p_account_id, :p_account_first, :p_account_last, :p_account_pass, :p_node, :l_ret1);end; ';

	EXECUTE IMMEDIATE l_str using l_db_server_rec.admin_user, l_db_server_rec.admin_password, l_db_server_rec.sid, c_domain, c_userid, c_userid, c_userid, 'welcome', l_db_server_rec.email_node,IN OUT l_ret1;
	if l_ret1=0 then
		reportStr := reportStr || '<font color=blue> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUCCESS') || ' </font><br>';
	else
		statusStr := 'FAILURE';
      		errStr := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_ERROR') || l_ret1;
      		reportStr := reportStr || '<font color=red> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM1') || '<br>' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM2') || '<br>'
    			|| FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM3') || ' </font><br>';
      		fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      		isFatal := 'FALSE';
   	end if;


   end if; -- l_count = 0

   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
   reports := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

   EXCEPTION
    WHEN OTHERS THEN
    	statusStr := 'FAILURE';
    	isFatal := 'FALSE';
    	errStr := SQLERRM;
    	reportStr := reportStr || '<font color=red> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM1') || '<br>' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM2') || '<br>'
    			|| FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM3') || '<br>';
    	JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
 	reports := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;

END runTest;


PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_COMPONENT1');
END getComponentName;

PROCEDURE getTestDesc(descStr  OUT NOCOPY VARCHAR2) IS
BEGIN
  descStr :=  '<ul><li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_DESC') || ' <li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_DESC1') || ' </ul>';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TESTCASE_NAME1');
END getTestName;

FUNCTION getTestMode RETURN INTEGER IS
BEGIN
return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
END getTestMode;


PROCEDURE getDefaultTestParams(defaultInputvalues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
   tempInput JTF_DIAG_INPUTTBL;
BEGIN
   tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
   tempInput :=
JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput, FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM6'),'');
   tempInput :=
JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput, FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC1_SUM7'),'');
defaultInputValues := tempInput;
EXCEPTION
 WHEN OTHERS THEN
    defaultInputvalues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;

    null;
END getDefaultTestParams;

END;

/
