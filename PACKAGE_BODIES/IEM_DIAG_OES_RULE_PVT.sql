--------------------------------------------------------
--  DDL for Package Body IEM_DIAG_OES_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DIAG_OES_RULE_PVT" AS
/* $Header: iemdorub.pls 115.2 2003/01/20 22:41:03 chtang noship $ */

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
   l_norule_accounts varchar2(32767);
   l_mulrule_accounts varchar2(32767);
   l_invalidrule_accounts varchar2(32767);
   l_notauthen_accounts varchar2(32767);
   dummy_num   NUMBER;
   l_db_link   iem_db_connections.db_link%type;
   l_apps_link iem_db_connections.db_link%type;
   l_db_name   iem_db_servers.db_name%type;
   l_db_server_tbl	  jtf_varchar2_Table_100:=jtf_varchar2_Table_100();
   l_count 	number;
   l_link_count number;

   l_account_rec		iem_diag_oes_rule_pvt.account_type;
   Type get_account_rec is REF CURSOR ;
   email_account_cur		get_account_rec;
   l_string		varchar2(2000);
   l_str VARCHAR2(2000);
   l_str1 VARCHAR2(2000);
   l_ret NUMBER;
   l_stat	varchar2(10);
   l_data	varchar2(255);
   l_im_link varchar2(200);
   l_im_link1 varchar2(200);
   l_dummy INTEGER;
   l_rule_table VARCHAR(100);
   l_account_table VARCHAR(100);
   l_domain_table VARCHAR(100);
   l_rule_count NUMBER := 0;
   l_rule_name VARCHAR2(100);
   l_rule_apps_name VARCHAR2(100);
   l_cursorID INTEGER;
   l_cursorID1 INTEGER;
   l_length NUMBER;
BEGIN
   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

	l_string := 'select email_user, domain, db_server_id, email_password, account_flag from iem_email_accounts';

	select db_link into l_apps_link from iem_db_connections where is_admin='O';

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
  	     		statusStr := 'FAILURE';
      			l_notauthen_accounts := l_notauthen_accounts || l_account_rec.email_user || '@' || l_account_rec.domain || ', ';
      			fixInfo := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      			isFatal := 'FALSE';
   		END IF;

   		l_cursorID := DBMS_SQL.OPEN_CURSOR;

		l_rule_table := 'om_server_rules' || l_im_link;
		l_account_table := 'ds_account' || l_im_link;
		l_domain_table := 'ds_domain' || l_im_link;

		l_str := 'select count(*) from ' || l_rule_table || ' a, ' || l_account_table || ' b, ' || l_domain_table || ' c where b.objectid = a.account_id and b.domainid = c.objectid and c.qualifiedname=UPPER(:domain) and b.name = UPPER(:username)';

		l_str1 := 'select info1 from ' || l_rule_table || ' a, ' || l_account_table || ' b, ' || l_domain_table || ' c where b.objectid = a.account_id and b.domainid = c.objectid and c.qualifiedname=UPPER(:domain) and b.name = UPPER(:username)';

		DBMS_SQL.PARSE(l_cursorID, l_str, DBMS_SQL.V7);

		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':domain', l_account_rec.domain);
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':username', l_account_rec.email_user);

		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_rule_count);

		l_dummy := DBMS_SQL.EXECUTE(l_cursorID);

    		IF DBMS_SQL.FETCH_ROWS(l_cursorID) = 0 THEN
       			reportStr := 'no rows selected';
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
        		EXIT;
     		END IF;

    		DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_rule_count);

    		if (l_account_rec.account_flag = 'A') then
    			if (l_rule_count <> 0) then
      				statusStr := 'FAILURE';
      				l_mulrule_accounts := l_mulrule_accounts || l_account_rec.email_user || ', ';
      				fixInfo := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      				isFatal := 'FALSE';
    			end if;

    		else
    			if (l_rule_count = 0) then
    				statusStr := 'FAILURE';
      				l_norule_accounts := l_norule_accounts || l_account_rec.email_user || '@' || l_account_rec.domain || ', ';
      				fixInfo := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      				isFatal := 'FALSE';
      			elsif (l_rule_count > 1) then
      				statusStr := 'FAILURE';
      				l_mulrule_accounts := l_mulrule_accounts || l_account_rec.email_user || '@' || l_account_rec.domain || ', ';
      				fixInfo := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      				isFatal := 'FALSE';
      			else

      				-- Check the rule has valid apps link name
      				l_cursorID1 := DBMS_SQL.OPEN_CURSOR;

      				DBMS_SQL.PARSE(l_cursorID1, l_str1, DBMS_SQL.V7);
				DBMS_SQL.BIND_VARIABLE(l_cursorID1, ':domain', l_account_rec.domain);
				DBMS_SQL.BIND_VARIABLE(l_cursorID1, ':username', l_account_rec.email_user);

				DBMS_SQL.DEFINE_COLUMN(l_cursorID1, 1, l_rule_name, 500);

				l_dummy := DBMS_SQL.EXECUTE(l_cursorID1);

    				IF DBMS_SQL.FETCH_ROWS(l_cursorID1) = 0 THEN
       					reportStr := 'no rows selected';
					JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
        				EXIT;
     				END IF;

    				DBMS_SQL.COLUMN_VALUE(l_cursorID1, 1, l_rule_name);

    				select length(l_rule_name) into l_length from dual;

    				if (l_length < 35) then
    					statusStr := 'FAILURE';
      					l_invalidrule_accounts := l_invalidrule_accounts || l_account_rec.email_user || '@' || l_account_rec.domain || ', ';
      					fixInfo := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      					isFatal := 'FALSE';
    				else
    					select substr(l_rule_name, 35) into l_rule_apps_name from dual;

    					if (l_rule_apps_name <> l_apps_link) then
    						statusStr := 'FAILURE';
      						l_invalidrule_accounts := l_invalidrule_accounts || l_account_rec.email_user || '@' || l_account_rec.domain || ', ';
      						fixInfo := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      						isFatal := 'FALSE';
    					end if;
    				end if;

      				DBMS_SQL.CLOSE_CURSOR(l_cursorID1);
    			end if;
    		end if;

		DBMS_SQL.CLOSE_CURSOR(l_cursorID);


	END LOOP; -- for email account

	close email_account_cur;

	if (statusStr = 'SUCCESS') then
		reportStr := '<font color=blue> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_SUCCESS') || ' </font><p>';
	else
		if (l_notauthen_accounts <>  FND_API.G_MISS_CHAR) then
			l_notauthen_accounts := RTRIM(l_notauthen_accounts, ', ');
			errStr := errStr || l_notauthen_accounts || ' ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_ERROR1') || '  ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC2_SUM1'));
		end if;
		if (l_norule_accounts <>  FND_API.G_MISS_CHAR) then
			l_norule_accounts := RTRIM(l_norule_accounts, ', ');
			errStr := errStr || l_norule_accounts || ' ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_ERROR2') || '  ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_SUM1'));
		end if;
		if (l_mulrule_accounts <>  FND_API.G_MISS_CHAR) then
			l_mulrule_accounts := RTRIM(l_mulrule_accounts, ', ');
			errStr := errStr || l_mulrule_accounts || ' ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_ERROR3') || '  ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_SUM2'));
		end if;
		if (l_invalidrule_accounts <>  FND_API.G_MISS_CHAR) then
			l_invalidrule_accounts := RTRIM(l_invalidrule_accounts, ', ');
			errStr := errStr || l_invalidrule_accounts || ' ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_ERROR4') || '  ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_SUM2'));
		end if;
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
   descStr := '<ul><li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_DESC') || ' <li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC3_DESC1') || ' </ul>';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TESTCASE_NAME3');
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
