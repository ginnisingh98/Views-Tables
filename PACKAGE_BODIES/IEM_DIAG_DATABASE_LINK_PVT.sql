--------------------------------------------------------
--  DDL for Package Body IEM_DIAG_DATABASE_LINK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DIAG_DATABASE_LINK_PVT" AS
/* $Header: iemddblb.pls 115.6 2004/04/01 00:59:51 chtang noship $ */

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
   errOO1      VARCHAR2(4000);
   errOO2      VARCHAR2(4000);
   errOO3      VARCHAR2(4000);
   errOra1      VARCHAR2(4000);
   errOra2      VARCHAR2(4000);
   errOra3      VARCHAR2(4000);
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
   l_schema_owner			VARCHAR2(30);

   link_not_correct		EXCEPTION;

    TYPE LinkCur Is REF CURSOR;
    l_link_cur			LinkCur;
    l_statement			VARCHAR2(2000);

BEGIN
   JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
   JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('@html');
   JTF_DIAGNOSTIC_COREAPI.insert_style_sheet;

	select oracle_username into l_schema_owner from fnd_oracle_userid where read_only_flag = 'U';

	select db_server_id bulk collect into l_db_server_tbl from iem_db_servers;

	errStr := '';
	fixInfo := '';

	FOR i IN l_db_server_tbl.FIRST..l_db_server_tbl.LAST LOOP
		select count(*) into l_count from iem_db_connections where db_server_id=l_db_server_tbl(i) and is_admin='A';
		select db_name into l_db_name from iem_db_servers where db_server_id=l_db_server_tbl(i);

		if (l_count = 0) then
			statusStr := 'FAILURE';
      			errOO1 := errOO1 || l_db_name || ', ';
      			fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      			isFatal := 'TRUE';
		else
			select a.db_link into l_db_link from iem_db_connections a, iem_db_servers b where a.db_server_id=b.db_server_id and a.is_admin='A' and a.db_server_id=l_db_server_tbl(i);

			l_search_dblink := l_db_link || '%';

			select count(*)into l_link_count from all_db_links where upper(owner)=upper(l_schema_owner) and db_link like UPPER(l_search_dblink);

			if (l_link_count = 0) then
				statusStr := 'FAILURE';
      				errOO2 := errOO2 || l_db_link || ', ';
      				fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      				isFatal := 'TRUE';
      			else
      				-- check if oo link is valid
      				BEGIN
					l_statement := 'SELECT global_name FROM global_name@'||l_db_link;
					OPEN l_link_cur for l_statement;
					LOOP
						FETCH l_link_cur INTO l_global_name;
						EXIT WHEN l_link_cur%notfound;
					END LOOP;
					close l_link_cur;

			   	EXCEPTION

				  WHEN OTHERS THEN
						statusStr := 'FAILURE';
      						errOO3 := errOO3 || l_db_link || ', ';
      						fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      						isFatal := 'TRUE';
			   	END;
  			end if;  -- (l_link_count = 0)
		end if;  -- (l_count = 0)

		select count(*) into l_count from iem_db_connections where db_server_id=l_db_server_tbl(i) and is_admin='P';

		if (l_count = 0) then
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
			statusStr := 'FAILURE';
      			errOra1 := errOra1 || l_db_name || ', ';
      			fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      			isFatal := 'TRUE';
      		else
      			select a.db_link into l_db_link from iem_db_connections a, iem_db_servers b where a.db_server_id=b.db_server_id and a.is_admin='P' and a.db_server_id=l_db_server_tbl(i);

      		        l_search_dblink := l_db_link || '%';

      			select count(*)into l_link_count from all_db_links where upper(owner)=upper(l_schema_owner) and db_link like UPPER(l_search_dblink);

			if (l_link_count = 0) then
				statusStr := 'FAILURE';
      				errOra2 := errOra2 || l_db_link || ', ';
      				fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      				isFatal := 'TRUE';
      			else
      				-- check if ora link is valid
      				BEGIN
					l_statement := 'SELECT global_name FROM global_name@'||l_db_link;
					OPEN l_link_cur for l_statement;
					LOOP
						FETCH l_link_cur INTO l_global_name;
						EXIT WHEN l_link_cur%notfound;
					END LOOP;
					close l_link_cur;

			   	EXCEPTION
				  WHEN OTHERS THEN
					statusStr := 'FAILURE';
      					errOra3 := errOra3 || l_db_link || ', ';
      					fixInfo :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_HELP');
      					isFatal := 'TRUE';
			       END;

			end if; -- (l_link_count = 0)
		end if; -- (l_count = 0)

	END LOOP;

	if (statusStr = 'SUCCESS') then
		reportStr :=  '<font color=blue> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_SUCCESS') || ' </font><p>';
		JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
	else
		reportStr := '<hr>';
		if (errOO1 <>  FND_API.G_MISS_CHAR) then
			errOO1 := RTRIM(errOO1, ', ');
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_ERROR1') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint( FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_SUM1') );
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;

		if (errOO2 <>  FND_API.G_MISS_CHAR) then
			errOO2 := RTRIM(errOO2, ', ');
			errStr := errStr || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_ERROR2') || ' (' || errOO2 || ' )' || '  ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_SUM2'));
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;
		if (errOO3 <>  FND_API.G_MISS_CHAR) then
			errOO3 := RTRIM(errOO3, ', ');
			errStr := errStr || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_ERROR5') || ' (' || errOO3 || ' )' || '  ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_SUM5'));
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;

		if (errOra1 <>  FND_API.G_MISS_CHAR) then
			errOra1 := RTRIM(errOra1, ', ');
			errStr := errStr ||  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_ERROR3') || ' ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_SUM3'));
			JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport(reportClob,reportStr);
		end if;
		if (errOra2 <>  FND_API.G_MISS_CHAR) then
			errOra2 := RTRIM(errOra2, ', ');
			errStr := errStr || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_ERROR4') || ' (' || errOra2|| ' )' || '  ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_SUM4'));
		end if;
		if (errOra3 <>  FND_API.G_MISS_CHAR) then
			errOra3 := RTRIM(errOra3, ', ');
			errStr := errStr || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_ERROR6') || ' (' || errOra3|| ' )' || '  ';
			JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint(FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_SUM6'));
		end if;
	end if;

   reports := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);
   reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
END runTest;

PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name := FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_COMPONENT3');
END getComponentName;

PROCEDURE getTestDesc(descStr  OUT NOCOPY VARCHAR2) IS
BEGIN
   descStr := '<ul><li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_DESC') || ' <li> ' || FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TC7_DESC1') || '</ul>';
END getTestDesc;

PROCEDURE getTestName(name OUT NOCOPY VARCHAR2) IS
BEGIN
   name :=  FND_MESSAGE.GET_STRING('IEM', 'IEM_DIAG_TESTCASE_NAME7');
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
