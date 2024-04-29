--------------------------------------------------------
--  DDL for Package Body IEM_DIAG_EMC_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DIAG_EMC_SETUP_PVT" AS
/* $Header: iemdsetb.pls 115.1 2003/10/10 00:34:26 chtang noship $ */

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
   l_server_group_count number := 0;
   l_db_count number := 0;
   l_oo_count number := 0;
   l_oraoffice_count number := 0;
   l_apps_count number := 0;
   l_imap_count number := 0;
   l_smtp_count number := 0;
   l_a_account_count number := 0;
   l_i_account_count number := 0;
   fixInfo     VARCHAR2(4000);
   isFatal     VARCHAR2(50);
   dummy_num   NUMBER;
   l_db_link   iem_db_connections.db_link%type;
   l_db_name   iem_db_servers.db_name%type;
   l_db_server_tbl	  jtf_varchar2_Table_100:=jtf_varchar2_Table_100();
   l_count 	number;
   l_link_count number;
   l_search_dblink VARCHAR2(129);
   l_global_name			VARCHAR2(240);
   l_cust_prof_null 	boolean	:= false;
   l_resource_prof_null boolean := false;
   link_not_correct		EXCEPTION;

    TYPE LinkCur Is REF CURSOR;
    l_link_cur			LinkCur;
    l_statement			VARCHAR2(2000);

BEGIN
   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

	errStr := '';
	fixInfo := '';

		-- Server Group
		select count(*) into l_server_group_count from iem_server_groups;

		-- Database Server
		select count(*) into l_db_count from iem_db_servers;

		-- Database Links
		select count(*) into l_oo_count from iem_db_connections where is_admin='A';
		select count(*) into l_oraoffice_count from iem_db_connections where is_admin='P';
		select count(*) into l_apps_count from iem_db_connections where is_admin='O';

		-- Email Servers
		select count(*) into l_imap_count from iem_email_servers where server_type_id=10001;
		select count(*) into l_smtp_count from iem_email_servers where server_type_id=10002;

		-- Email Accounts
		select count(*) into l_a_account_count from iem_email_accounts where account_flag = 'A';
		select count(*) into l_i_account_count from iem_email_accounts where account_flag = 'I';

		  -- Check if user has entered an default customer number in Profile
   		if (FND_PROFILE.VALUE('IEM_DEFAULT_CUSTOMER_NUMBER') is null or FND_PROFILE.VALUE('IEM_DEFAULT_CUSTOMER_ID') is null) then
   			l_cust_prof_null := true;
   		end if;

   		-- Check if user has entered an default resource number in Profile
   		if (FND_PROFILE.VALUE('IEM_SRVR_ARES') is null or FND_PROFILE.VALUE('IEM_DEFAULT_RESOURCE_NUMBER') is null) then
   			l_resource_prof_null := true;
   		end if;

		if (l_server_group_count = 0 or l_db_count = 0 or l_oo_count = 0 or l_oraoffice_count = 0 or l_apps_count = 0 or l_imap_count = 0
			or l_smtp_count = 0 or l_a_account_count = 0 or l_i_account_count = 0 or l_cust_prof_null or l_resource_prof_null) then
			statusStr := 'FAILURE';
      			fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      			isFatal := 'TRUE';
		end if;  -- (l_count = 0)


	if (statusStr = 'SUCCESS') then
		reportStr :=  '<font color=blue> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUCCESS') || ' </font><p>';
		JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
	else
		reportStr := '<hr>';

		-- Server Group
		if (l_server_group_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR1') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM1') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;

		-- Database Server
		if (l_db_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR2') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM2') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;

		-- Database Links
		if (l_oo_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR3') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM3') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;
		if (l_oraoffice_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR4') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM4') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;
		if (l_apps_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR5') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM5') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;

		-- Email Servers
		if (l_imap_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR6') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM6') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;
		if (l_smtp_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR7') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM7') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;

		-- Email Account
		if (l_a_account_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR8') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM8') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;
		if (l_i_account_count = 0) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR9') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM9') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;

		-- Profile
		if (l_cust_prof_null) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR10') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM10') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;
		if (l_resource_prof_null) then
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_ERROR11') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_SUM11') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;
	end if;

   reports := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
 	name := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_COMPONENT5');
END getComponentName;

PROCEDURE getTestDesc(descStr  OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := '<ul><li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_DESC1')  || ' <li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC10_DESC2') || '</ul>';

END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
  name :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TESTCASE_NAME10');
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
