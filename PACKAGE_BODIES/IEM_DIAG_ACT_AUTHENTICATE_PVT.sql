--------------------------------------------------------
--  DDL for Package Body IEM_DIAG_ACT_AUTHENTICATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DIAG_ACT_AUTHENTICATE_PVT" AS
/* $Header: iemdautb.pls 115.2 2003/01/20 22:40:17 chtang noship $ */

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
   statusStr   VARCHAR2(50) := 'SUCCESS';
   errStr      VARCHAR2(4000);
   fixInfo     VARCHAR2(4000);
   isFatal     VARCHAR2(50);
   l_accounts varchar2(5000);
   l_succeed_accounts varchar2(5000);
   l_db_link   iem_db_connections.db_link%type;
   l_db_name   iem_db_servers.db_name%type;
   l_db_server_tbl	  jtf_varchar2_Table_100:=jtf_varchar2_Table_100();
   l_count 	number;
   l_link_count number;

   l_account_rec		iem_diag_act_authenticate_pvt.account_type;
   Type get_account_rec is REF CURSOR ;
   email_account_cur		get_account_rec;
   l_string		varchar2(2000);
   l_str VARCHAR2(2000);
   l_ret NUMBER;
   l_stat	varchar2(10);
   l_data	varchar2(255);
   l_im_link varchar2(200);
   l_im_link1 varchar2(200);
BEGIN
   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

	l_string := 'select email_user, domain, db_server_id, email_password from iem_email_accounts';

	-- Start looping through all email accounts defined in SSA
	OPEN email_account_cur FOR l_string;
 	LOOP

		FETCH email_account_cur into l_account_rec;
		EXIT WHEN email_account_cur%NOTFOUND;

		IEM_DB_CONNECTIONS_PVT.select_item(
               		p_api_version_number =>1.0,
                 	p_db_server_id  =>l_account_rec.db_server_id,
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

  		l_str:='begin :l_ret:=im_api.authenticate'||l_im_link||'(:a_user,:a_domain,:a_password);end; ';
    		EXECUTE IMMEDIATE l_str using OUT l_ret,l_account_rec.email_user,l_account_rec.domain,l_account_rec.email_password;
   		IF l_ret<>0 THEN
   			l_accounts := l_accounts || l_account_rec.email_user || '@' || l_account_rec.domain || ', ';
  	     		statusStr := 'FAILURE';
      			fixInfo := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      			isFatal := 'FALSE';
      		--ELSE
      	--		l_succeed_accounts := l_succeed_accounts || l_account_rec.email_user || '@' || l_account_rec.domain || ', ';
   		END IF;



	END LOOP; -- for each email account

	close email_account_cur;

	if (statusStr = 'SUCCESS') then
		reportStr := '<font color=blue> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_SUCCESS') || ' </font><p>';
	else
		l_accounts := RTRIM(l_accounts, ', ');
		--l_accounts := RTRIM(l_succeed_accounts, ', ');
		errStr := errStr || l_accounts || ' ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_ERROR1');
		--errStr := errStr || l_accounts || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_ERROR1') || ' ' ||
		--	l_succeed_accounts || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_ERROR2');
		JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_SUM1'));
	end if;

	JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);

   reports := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;


PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_COMPONENT1');
END getComponentName;

PROCEDURE getTestDesc(descStr  OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := '<ul><li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_DESC') || ' <li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_DESC1') || ' </ul>';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TESTCASE_NAME2');
END getTestName;

FUNCTION getTestMode RETURN INTEGER IS
BEGIN
return JTF_DIAGNOSTIC_ADAPTUTIL.BOTH_MODE;
END getTestMode;

PROCEDURE getDefaultTestParams(defaultInputvalues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
   tempInput JTF_DIAG_INPUTTBL;
BEGIN
    null;
END getDefaultTestParams;

END;

/
