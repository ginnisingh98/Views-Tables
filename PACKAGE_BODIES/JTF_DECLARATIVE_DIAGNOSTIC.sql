--------------------------------------------------------
--  DDL for Package Body JTF_DECLARATIVE_DIAGNOSTIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DECLARATIVE_DIAGNOSTIC" AS
/* $Header: jtfdecl_diag_b.pls 120.2 2005/08/13 01:05:33 minxu noship $ */
  ------------------------------------------------------------
  -- procedure to initialize test datastructures
  -- executeds prior to test run (not currently being called)
  ------------------------------------------------------------
  PROCEDURE init IS
  BEGIN
   -- test writer could insert special setup code here
   null;
  END init;

  PROCEDURE INSERT_COL_STEP_DATA(
			P_APPID 		IN 	VARCHAR2,
			P_GROUPNAME 		IN 	VARCHAR2,
			P_TESTCLASSNAME 	IN 	VARCHAR2,
			P_TESTSTEPNAME		IN	VARCHAR2,
			P_COLNAMES_ARRAY  	IN	JTF_VARCHAR2_TABLE_4000,
			P_LOGOP_ARRAY  		IN	JTF_VARCHAR2_TABLE_4000,
			P_VAL1_ARRAY  		IN	JTF_VARCHAR2_TABLE_4000,
			P_VAL2_ARRAY  		IN	JTF_VARCHAR2_TABLE_4000,
			ISUPDATE		IN 	VARCHAR2,
                        P_LUBID                 IN      NUMBER) IS

	V_INDEX  NUMBER;

  BEGIN

  	if isupdate = 'TRUE' then
  		delete from jtf_diagnostic_decl_step_cols
  		where
	  		appid = P_APPID
  			and groupname = p_groupname
  			and testclassname = p_testclassname
  			and teststepname = p_teststepname;
  	end if;


  	V_INDEX := 1;

        LOOP
	  IF P_COLNAMES_ARRAY.EXISTS(V_INDEX) THEN

			insert into jtf_diagnostic_decl_step_cols
			(
				APPID,
				GROUPNAME,
				TESTCLASSNAME,
				TESTSTEPNAME,
				COLUMN_NAME,
				LOGICAL_OPERATOR,
				VALIDATION_VAL1,
				VALIDATION_VAL2,
				OBJECT_VERSION_NUMBER,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				CREATION_DATE,
				SECURITY_GROUP_ID
			)
			values
			(
				P_APPID,
				P_GROUPNAME,
				P_TESTCLASSNAME,
				P_TESTSTEPNAME,
				P_COLNAMES_ARRAY(V_INDEX),
				P_LOGOP_ARRAY(V_INDEX),
				P_VAL1_ARRAY(V_INDEX),
				P_VAL2_ARRAY(V_INDEX),
				1,
				P_LUBID,
				SYSDATE,
				P_LUBID,
				NULL,
				SYSDATE,
				NULL
			);
	        V_INDEX := V_INDEX + 1;

	  ELSE
	    EXIT;
          END IF;

        END LOOP;
  END INSERT_COL_STEP_DATA;


  ------------------------------------------------------------
  -- procedure to cleanup any  test datastructures that were setup in the init
  --  procedure call executes after test run (not currently being called)
  ------------------------------------------------------------
  PROCEDURE cleanup IS
  BEGIN
   -- test writer could insert special cleanup code here
   NULL;
  END cleanup;

  ------------------------------------------------------------
  -- procedure to execute the PLSQL test
  -- the inputs needed for the test are passed in and a report object and CLOB are -- returned.
  ------------------------------------------------------------
    PROCEDURE runtest(inputs IN  JTF_DIAG_INPUTTBL,
                            report OUT NOCOPY JTF_DIAG_REPORT,
                            reportClob OUT NOCOPY CLOB,
			    appshortname IN VARCHAR2,
			    groupname IN VARCHAR2,
			    testclassname IN VARCHAR2,
			    p_teststepname IN VARCHAR2,
			    p_teststeptype IN VARCHAR2,
			    p_stepDescription IN VARCHAR2,
			    p_errorType IN VARCHAR2,
			    p_errorMessage IN VARCHAR2,
			    p_fixInfo IN VARCHAR2,
			    p_tableViewName IN VARCHAR2,
			    p_logicalOperator IN VARCHAR2,
			    p_validationVal1 IN VARCHAR2,
			    p_validationVal2 IN VARCHAR2,
			    p_whereClauseOrSQL IN VARCHAR2,
			    sysParamNames IN JTF_VARCHAR2_TABLE_4000,
			    sysParamValues IN JTF_VARCHAR2_TABLE_4000,
			    p_ordernumber IN NUMBER) IS

	reportStr   		LONG;
	statusStr   		VARCHAR2(50);  -- SUCCESS or FAILURE
	errStr      		VARCHAR2(4000);
	fixInfo     		VARCHAR2(4000);
	isFatal     		VARCHAR2(50);  -- TRUE or FALSE
	v_counter		INTEGER;
	v_step_failed		BOOLEAN;
	v_overall_failed	BOOLEAN;
	v_terminate_exec	BOOLEAN;

	v_summaryString		VARCHAR2(32767);

	-- this should be a CLOB instead since this is
	-- limiting the size of the report that we can generate
	-- THIS IS TEMPORARY -----

	v_detailsString		VARCHAR2(32767);
	v_detailsClob		CLOB;

   BEGIN

   	-- default value for terminating execution
   	v_terminate_exec := FALSE;

   	v_counter := p_ordernumber;

     	JTF_DIAGNOSTIC_ADAPTUTIL.setUpVars;
     	dbms_lob.createTemporary(v_detailsClob,true,dbms_lob.call);
     	v_summaryString := '';

        -- addStringToClob('<table border=0>', v_detailsClob);

        v_detailsString := '';

	if p_teststeptype = 'COUNT' and not v_terminate_exec then

			run_or_validate_count(
					appshortname, groupname, testclassname, report,
					p_teststepname,
					p_stepDescription,
					p_errorType,
					p_errorMessage,
					p_fixInfo,
					p_tableViewName,
					p_logicalOperator,
					p_validationVal1,
					p_validationVal2,
					p_whereClauseOrSQL,
					v_step_failed,
					v_summaryString,
					v_detailsString,
					v_counter);

			-- add that information to the CLOB
			-- and empty out the v_detailsString

			addStringToClob(v_detailsString, v_detailsClob);
			v_detailsString := '';

	elsif (p_teststeptype = 'RECORD' OR p_teststeptype = 'NO RECORD') and not v_terminate_exec then

			 run_or_validate_rec_norec(
					appshortname, groupname, testclassname, report,
					p_teststepname,
					p_stepDescription,
					p_errorType,
					p_errorMessage,
					p_fixInfo,
					p_whereClauseOrSQL,
					v_step_failed,
					v_summaryString,
					v_detailsString,
					v_counter,
					p_teststeptype);

			-- add that information to the CLOB
			-- and empty out the v_detailsString

			addStringToClob(v_detailsString, v_detailsClob);
			v_detailsString := '';


	elsif p_teststeptype = 'SYSTEM PARAMETER' and not v_terminate_exec then

			run_system_parameter_step(
					appshortname,
					groupname,
					testclassname,
					report,
					p_teststepname,
					p_stepDescription,
					p_errorType,
					p_errorMessage,
					p_fixInfo, p_tableViewName,
					p_logicalOperator,
					p_validationVal1,
					v_step_failed,
					v_summaryString,
					v_detailsString,
					v_counter,
		 		        sysParamNames,
		 		        sysParamValues);

			-- add that information to the CLOB
			-- and empty out the v_detailsString

			addStringToClob(v_detailsString, v_detailsClob);
			v_detailsString := '';


	elsif p_teststeptype = 'COLUMN'  and not v_terminate_exec then

			run_or_validate_column(
					appshortname, groupname, testclassname, report,
					p_teststepname,
					p_stepDescription,
					p_errorType,
					p_errorMessage,
					p_fixInfo,
					p_tableViewName,
					p_logicalOperator,
					p_validationVal1,
					p_validationVal2,
					p_whereClauseOrSQL,
					v_step_failed,
					v_summaryString,
					v_detailsClob,
					v_counter);

			-- add that information to the CLOB
			-- and empty out the v_detailsString

			-- addStringToClob(v_detailsString, v_detailsClob);
			-- v_detailsString := '';

	end if;


	if v_step_failed = TRUE and not v_terminate_exec then
			v_overall_failed := TRUE;
			if p_errorType = 'NORMALERROR' OR p_errorType = 'FATALERROR' then

				statusStr := 'FAILURE'; -- SUCCESS or FAILURE
				errStr    := 'One of the test steps failed';
				fixInfo   := 'Please check the failure details in the report';

				if p_errorType = 'FATALERROR' then
					isFatal   := 'TRUE';
				else
					isFatal   := 'FALSE';
				end if;
			end if;

			if p_errorType = 'FATALERROR' then
				-- v_counter := v_counter + 1;
				-- exit;
				v_terminate_exec := TRUE;

			end if;
	end if;

        v_counter := v_counter + 1;

        -- v_detailsString := v_detailsString || '</table>';

 	-- add that information to the CLOB
	-- and empty out the v_detailsString

	addStringToClob(v_detailsString, v_detailsClob);
	v_detailsString := '';

 	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
 	dbms_lob.append(reportClob, v_detailsClob);

        -- overall status of the testcase
        -- captured by the following boolean

        if v_overall_failed = FALSE then
	statusStr := 'SUCCESS'; -- SUCCESS or FAILURE
	errStr    := '';
	fixInfo   := '';
	isFatal   := '';
        end if;

        report := JTF_DIAGNOSTIC_ADAPTUTIL.constructReport(statusStr,errStr,fixInfo,isFatal);

        EXCEPTION
         	when others then
	       	-- this should never happen
         	JTF_DIAGNOSTIC_ADAPTUTIL.addStringToReport('Exception Occurred In RUNTEST');
         	reportClob := JTF_DIAGNOSTIC_ADAPTUTIL.getReportClob;
         	raise;

   END runTest;


   PROCEDURE run_or_validate_column(
      				appshtname in varchar2,
  				grpname in varchar2,
  				testclsname in varchar2,
  				report out NOCOPY JTF_DIAG_REPORT,
    				teststpname IN VARCHAR2,
				step_description IN VARCHAR2,
				error_type IN VARCHAR2,
				error_message IN VARCHAR2,
				fix_info IN VARCHAR2,
				table_view_name IN VARCHAR2,
				logical_operator IN VARCHAR2,
				validation_val1 IN VARCHAR2,
				VALIDATION_VAL2 IN VARCHAR2,
				WHERE_CLAUSE_OR_SQL IN VARCHAR2,
				STEP_FAILED IN OUT NOCOPY BOOLEAN,
				SUMMARY_STRING IN OUT NOCOPY VARCHAR2,
				DETAILS_CLOB IN OUT NOCOPY CLOB,
				ORDERNUMBER IN OUT NOCOPY NUMBER) IS

  v_sqlstr 	VARCHAR2(32767);
  v_header	VARCHAR2(10000);
  v_count	number;
  v_count2	number;
  v_count3	number;
  v_cursorID	integer;
  v_dummy 	INTEGER;

  v_selectValue JTF_VARCHAR2_TABLE_4000;
  v_columnNames	JTF_VARCHAR2_TABLE_4000;
  v_logicalOp 	JTF_VARCHAR2_TABLE_4000;
  v_validVal1	JTF_VARCHAR2_TABLE_4000;
  v_validVal2	JTF_VARCHAR2_TABLE_4000;

  cursor datalist is
  	select COLUMN_NAME, LOGICAL_OPERATOR,
	VALIDATION_VAL1, VALIDATION_VAL2
	from jtf_diagnostic_decl_step_cols
	where APPID = appshtname
	and GROUPNAME = grpname
	and TESTCLASSNAME = testclsname
	and TESTSTEPNAME = teststpname;

  BEGIN
	v_sqlstr := '';
	v_count := 0;

	-- set step failed to false to begin with. let the comparison
	-- process decide if its a failure or success

	step_failed := FALSE;

	addStringToClob('<tr><td colspan=5 class=reportDataCell>', DETAILS_CLOB);

	-- DETAILS_STRING:= DETAILS_STRING || '<tr><td class=reportDataCell>';
	-- instantiate the data structures for
	-- loading data, etc

	v_columnNames	:= JTF_VARCHAR2_TABLE_4000();
	v_logicalOp 	:= JTF_VARCHAR2_TABLE_4000();
	v_validVal1	:= JTF_VARCHAR2_TABLE_4000();
	v_validVal2	:= JTF_VARCHAR2_TABLE_4000();

      FOR x in datalist
        LOOP
		v_count := v_count + 1;
		v_columnNames.extend;
		v_logicalOp.extend;
		v_validVal1.extend;
		v_validVal2.extend;

		v_columnNames(v_count) := x.column_name;
		v_logicalOp(v_count) := x.logical_operator;
		v_validVal1(v_count) := x.validation_val1;
		v_validVal2(v_count) := x.validation_val2;

        END LOOP;

	v_sqlstr := 'select ';

	-- now construct the SQL statement
	-- to read up the values for comparison
	v_count2 := 1;
	loop
		if v_count2 > v_count then
		   exit;
		end if;

		-- if v_count2 is less than the number of columns read up
		-- then add a comma for the SQL string to be formed

		if v_count2 < v_count then
			v_sqlstr := v_sqlstr || 'to_char(' || v_columnNames(v_count2) || ')' || ', ';
		else
			v_sqlstr := v_sqlstr || 'to_char(' || v_columnNames(v_count2) || ')';
		end if;

		v_count2 := v_count2 + 1;
	end loop;

	-- add the table name to the
	-- SQL string being constructed
	v_sqlstr := v_sqlstr || ' from ' || table_view_name;

    	-- add the where clause to the
	-- SQL string being constructed

	if WHERE_CLAUSE_OR_SQL is null or length(WHERE_CLAUSE_OR_SQL) = 0 then
		null;
	else
		v_sqlstr := v_sqlstr || ' where ' || WHERE_CLAUSE_OR_SQL;
	end if;

	-- at this point the SQL statement is complete
	-- for execution. Now construct the HTML to be displayed
	-- on the UI

	v_header := '<p><hr><b><a name="' || (ORDERNUMBER + 1)
			||'">STEP NAME: </a></b>' || '<br><hr>' || (ORDERNUMBER + 1)|| ': ' || teststpname;

	addStringToClob(v_header || '<p><b>STEP DESCRIPTION: </b>' || '<br>' || step_description
			|| '<p>'
			|| '<b>SQL QUERY CONSTRUCTED: </b>' || '<br>' || v_sqlstr
			|| '<p>', DETAILS_CLOB);

	-- addStringToClob('<b>ERROR TYPE: </b>' || '<br>' || error_type, DETAILS_CLOB);

	v_cursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(v_cursorID, v_sqlstr, DBMS_SQL.V7);

	-- now bind the values for the column
	-- values to be retrieved

	-- again loop and bind the column values
	-- to the datastructure for retrieval

	v_selectValue 	:= JTF_VARCHAR2_TABLE_4000();
	for v_count2 in 1 .. v_count loop
		v_selectValue.extend;
		DBMS_SQL.DEFINE_COLUMN(v_cursorID, v_count2, v_selectValue(v_count2), 3000);
	end loop;

	-- execute the dynamically created SQL statement
	v_dummy := dbms_sql.execute(v_cursorID);

        -- at this time display the desired values
        -- for the columns that should be matches
        -- with the actual values

	-- start the table

        addStringToClob('<p><b>VALIDATION RULES: </b><br><table>', DETAILS_CLOB);

	for v_count2 in 1 .. v_count loop
		addStringToClob('<tr><td CLASS=reportDataCell>' || v_columnNames(v_count2) || ' SHOULD BE ', DETAILS_CLOB);
		addStringToClob(v_logicalOp(v_count2) || ' ' || v_validVal1(v_count2), DETAILS_CLOB);

		if v_logicalOp(v_count2) = 'BETWEEN' then
			addStringToClob(' AND ' || v_validVal2(v_count2), DETAILS_CLOB);
		end if;
		addStringToClob('</td></tr>', DETAILS_CLOB);

	end loop;

	-- end the table
        addStringToClob('</table>', DETAILS_CLOB);
        addStringToClob('<p>', DETAILS_CLOB);


	-- start the table again to construct the result set
        addStringToClob('<p><b>APPLYING VALIDATION RULES TO RESULT SET: </b><table border=1><tr>', DETAILS_CLOB);

	for v_count2 in 1 .. v_count loop
		addStringToClob('<td CLASS=reportDataCell><b>' || upper(v_columnNames(v_count2)), DETAILS_CLOB);
		addStringToClob('</b></td>', DETAILS_CLOB);

	end loop;
	-- dont end the table yet but end the row
	addStringToClob('</tr>', DETAILS_CLOB);

	v_count3 := 0;
        loop
         	-- fetch the rows into the buffer
         	if dbms_sql.fetch_rows(v_cursorID) = 0 then
         		exit;
         	end if;

		v_count3 := v_count3 + 1;

		-- fetch the values in the datastructure for rendering
		-- and comparison...
		for v_count2 in 1 .. v_count loop
			dbms_sql.column_value(v_cursorID, v_count2, v_selectValue(v_count2));
		end loop;


		-- for each row received compare the values
		-- with the desired values and construct the
		-- report at the same time

		v_count2 := 1;

		addStringToClob('<tr>', DETAILS_CLOB);

		for v_count2 in 1 .. v_count loop

			addStringToClob('<td CLASS=reportDataCell>', DETAILS_CLOB);

		        if v_logicalOp(v_count2) = '<>' then

		        	if v_selectValue(v_count2) <>  v_validVal1(v_count2) then
					addStringToClob(v_selectValue(v_count2), DETAILS_CLOB);
				else
					addStringToClob('<font color=red><b>'
		        				|| v_selectValue(v_count2) || ' (**FAILED**) '
		        				|| '</b></font>', DETAILS_CLOB);

					step_failed := TRUE;
		        	end if;

		        elsif v_logicalOp(v_count2) = '=' then

		        	if v_selectValue(v_count2) =  v_validVal1(v_count2) then
					addStringToClob(v_selectValue(v_count2), DETAILS_CLOB);
				else
					addStringToClob('<font color=red><b>'
						|| v_selectValue(v_count2) || ' (**FAILED**) '
						|| '</b></font>', DETAILS_CLOB);

					step_failed := TRUE;
		        	end if;

		        elsif v_logicalOp(v_count2) = '<' then

		        	if to_number(v_selectValue(v_count2)) <  to_number(v_validVal1(v_count2)) then
					addStringToClob(v_selectValue(v_count2), DETAILS_CLOB);
				else
					addStringToClob('<font color=red><b>'
						|| v_selectValue(v_count2) || ' (**FAILED**) '
						|| '</b></font>', DETAILS_CLOB);
					step_failed := TRUE;
		        	end if;

		        elsif v_logicalOp(v_count2) = '>' then

		        	if to_number(v_selectValue(v_count2)) >  to_number(v_validVal1(v_count2)) then
					addStringToClob(v_selectValue(v_count2), DETAILS_CLOB);
				else
					addStringToClob('<font color=red><b>'
						|| v_selectValue(v_count2) || ' (**FAILED**) '
						|| '</b></font>', DETAILS_CLOB);
					step_failed := TRUE;
		        	end if;

		        elsif v_logicalOp(v_count2) = '>=' then

		        	if to_number(v_selectValue(v_count2)) >=  to_number(v_validVal1(v_count2)) then
					addStringToClob(v_selectValue(v_count2), DETAILS_CLOB);
				else
					addStringToClob('<font color=red><b>'
						|| v_selectValue(v_count2) || ' (**FAILED**) '
						|| '</b></font>', DETAILS_CLOB);
					step_failed := TRUE;
		        	end if;

		        elsif v_logicalOp(v_count2) = '<=' then

		        	if to_number(v_selectValue(v_count2)) <=  to_number(v_validVal1(v_count2)) then
					addStringToClob(v_selectValue(v_count2), DETAILS_CLOB);
				else
					addStringToClob('<font color=red><b>'
						|| v_selectValue(v_count2) || ' (**FAILED**) '
						|| '</b></font>', DETAILS_CLOB);
					step_failed := TRUE;
		        	end if;

		        elsif v_logicalOp(v_count2) = 'BETWEEN' then

		        	if to_number(v_validVal1(v_count2)) <= to_number(v_selectValue(v_count2))
		        		AND to_number(v_selectValue(v_count2)) <= to_number(v_validVal2(v_count2)) then

					addStringToClob(v_selectValue(v_count2), DETAILS_CLOB);
				else
					addStringToClob('<font color=red><b>'
						|| v_selectValue(v_count2) || ' (**FAILED**) '
						|| '</b></font>', DETAILS_CLOB);
					step_failed := TRUE;
		        	end if;

		        end if;

			addStringToClob('</td>', DETAILS_CLOB);
		end loop;

		addStringToClob('</tr>', DETAILS_CLOB);

        end loop;

        -- now close the table
	addStringToClob('</table>', DETAILS_CLOB);

	SUMMARY_STRING := SUMMARY_STRING || '<tr>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || (ORDERNUMBER + 1) || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || teststpname || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || 'COLUMN' || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || error_type || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>';

     	if step_failed then
     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">FAILED</a>';

		addStringToClob('<p><font color=red><b>STATUS: </b>Failed</font><p>',
						DETAILS_CLOB);

        else
     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">PASSED</a>';

		addStringToClob('<p><font color=green><b>STATUS: </b>Succeeded</font><p>',
						DETAILS_CLOB);

     	end if;

	addStringToClob('</td></tr>', DETAILS_CLOB);

     	SUMMARY_STRING := SUMMARY_STRING || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '</tr>';
        dbms_sql.close_cursor(v_cursorID);

        EXCEPTION
         	when others then
         	-- close the cursor
         	dbms_sql.close_cursor(v_cursorID);

		SUMMARY_STRING := SUMMARY_STRING || '<tr>';
		SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || (ORDERNUMBER + 1) || '</td>';
		SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || teststpname || '</td>';
		SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || 'COLUMN' || '</td>';
		SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || error_type || '</td>';
		SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>';

     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">EXCEPTION OCCURRED</a>';

		addStringToClob('<p><b>EXCEPTION: </b>' || '<br>' || SQLERRM, DETAILS_CLOB);

		addStringToClob('<p><font color=red><b>STATUS: </b>Failed</font><p>',
						DETAILS_CLOB);

		addStringToClob('</td></tr>', DETAILS_CLOB);

     		step_failed := TRUE;

   END run_or_validate_column;


   PROCEDURE run_system_parameter_step(
					appshortname in varchar2,
					groupname in varchar2,
					testclassname in varchar2,
					report OUT NOCOPY JTF_DIAG_REPORT,
					teststpname in varchar2,
					step_description in varchar2,
					error_type in varchar2,
					error_message in varchar2,
					fix_info in varchar2,
					table_view_name in varchar2,
					logical_operator in varchar2,
					validation_val1 in varchar2,
					step_failed IN OUT NOCOPY BOOLEAN,
					summary_String IN OUT NOCOPY VARCHAR2,
					DETAILS_STRING IN OUT NOCOPY VARCHAR2,
					ORDERNUMBER IN OUT NOCOPY NUMBER,
		 		        sysParamNames IN JTF_VARCHAR2_TABLE_4000,
		 		        sysParamValues IN JTF_VARCHAR2_TABLE_4000) IS

  v_detailsstr 	VARCHAR2(4000);
  v_header	VARCHAR2(300);
  v_count	integer;
  v_recFound	BOOLEAN;

  BEGIN
	v_detailsstr := '';

	-- reportDataCell

	DETAILS_STRING := DETAILS_STRING || '<tr><td colspan=5 class=reportDataCell>';

	v_header := '<p><hr><b><a name="' || (ORDERNUMBER + 1)
			||'">STEP NAME: </a></b>' || '<br><hr>' || (ORDERNUMBER + 1)|| ': ' || teststpname;

	v_detailsstr := v_header || '<p><b>STEP DESCRIPTION: </b>' || '<br>' || step_description
			|| '<p>' ;
	-- v_detailsstr := v_detailsstr  || '<b>SQL QUERY EXECUTED: </b>' || '<br>' || v_detailsstr;

        v_detailsstr := v_detailsstr || '<p>';
        -- v_detailsstr := v_detailsstr || '<b>ERROR TYPE: </b>' || '<br>' || error_type;

        v_count := 1;

  	v_detailsstr := v_detailsstr || '<b>SYSTEM PARAM ANALYSIS: </b>' || '<br>';

        LOOP

	  IF sysParamNames.EXISTS(v_count) and sysParamValues.EXISTS(v_count) THEN

	  	if sysParamNames(v_count) = table_view_name then

			if sysParamValues(v_count) =  validation_val1 then
				v_detailsstr  := v_detailsstr || 'The value for system parameter: '
						|| sysParamNames(v_count) || ' is '
						|| sysParamValues(v_count) || ', which is the desired value.';
				v_detailsstr  := v_detailsstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
				step_failed := FALSE;
				v_recFound  := TRUE;
				EXIT;
			else
				v_detailsstr  := v_detailsstr || 'Value for system parameter: '
						|| sysParamNames(v_count) || ' is '
						|| sysParamValues(v_count) || '. <br>The expected value was: '
						|| validation_val1;

				v_detailsstr  := v_detailsstr || '<p><b>ERROR MESSAGE: </b>'
					|| '<br>' || error_message;
				v_detailsstr  := v_detailsstr || '<p>' || '<b>FIX INFO: </b>';
				v_detailsstr  := v_detailsstr || '<br>' || fix_info;
				v_detailsstr  := v_detailsstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
				step_failed := TRUE;
				v_recFound  := TRUE;
				EXIT;
			end if;

	  	end if;

	  else
		v_recFound  := FALSE;
		EXIT;
	  end if;

	  v_count := v_count + 1;

        END LOOP;

	-- if record was not found then provide the
	-- appropriate error message that the system param was not found

	if not v_recFound then
		v_detailsstr  := v_detailsstr || '<br>' || 'The system parameter: '
				|| table_view_name || ' was not found';

		v_detailsstr  := v_detailsstr || '<p><b>ERROR MESSAGE: </b>'
			|| '<br>' || error_message;
		v_detailsstr  := v_detailsstr || '<p>' || '<b>FIX INFO: </b>';
		v_detailsstr  := v_detailsstr || '<br>' || fix_info;
		v_detailsstr  := v_detailsstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
		step_failed := TRUE;
	end if;


	SUMMARY_STRING := SUMMARY_STRING || '<tr>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || (ORDERNUMBER + 1) || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || teststpname || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || 'SYSTEM PARAMETER' || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || error_type || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>';

     	if step_failed then
     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">FAILED</a>';
        else
     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">PASSED</a>';
     	end if;

     	SUMMARY_STRING := SUMMARY_STRING || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '</tr>';

	DETAILS_STRING := DETAILS_STRING || v_detailsstr;
	DETAILS_STRING := DETAILS_STRING || '</td></tr>';

  END run_system_parameter_step;


  ------------------------------------------------------------
  -- procedure to run_or_validate_count
  ------------------------------------------------------------
  PROCEDURE run_or_validate_count(
  				appshtname in varchar2,
  				grpname in varchar2,
  				testclsname in varchar2, report OUT NOCOPY JTF_DIAG_REPORT,
  				teststpname IN VARCHAR2,
				step_description IN VARCHAR2,
				error_type IN VARCHAR2,
				error_message IN VARCHAR2,
				fix_info IN VARCHAR2,
				table_view_name IN VARCHAR2,
				logical_operator IN VARCHAR2,
				validation_val1 IN VARCHAR2,
				VALIDATION_VAL2 IN VARCHAR2,
				WHERE_CLAUSE_OR_SQL IN VARCHAR2,
				STEP_FAILED IN OUT NOCOPY BOOLEAN,
				SUMMARY_STRING IN OUT NOCOPY VARCHAR2,
				DETAILS_STRING IN OUT NOCOPY VARCHAR2,
				ORDERNUMBER IN OUT NOCOPY NUMBER) IS

  v_sqlstr 	VARCHAR2(32767);
  v_header	VARCHAR2(300);
  v_count	integer;
  v_cursorID	integer;

  BEGIN
	v_sqlstr := '';

	-- reportDataCell

	DETAILS_STRING:= DETAILS_STRING || '<tr><td colspan=5 class=reportDataCell>';

	if table_view_name is null or length(table_view_name) = 0 then
		v_sqlstr := WHERE_CLAUSE_OR_SQL;
	else
		v_sqlstr := 'select count(*) from ' || table_view_name;
		if WHERE_CLAUSE_OR_SQL is null or length(WHERE_CLAUSE_OR_SQL) = 0 then
			null;
		else
			v_sqlstr := v_sqlstr || ' where ' || WHERE_CLAUSE_OR_SQL;
		end if;
	end if;

	v_cursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(v_cursorID, v_sqlstr, DBMS_SQL.V7);
	DBMS_SQL.DEFINE_COLUMN(v_cursorID, 1, v_count);
	v_count := dbms_sql.execute(v_cursorID);

       loop
               	-- fetch the rows into the buffer
         	if dbms_sql.fetch_rows(v_cursorID) = 0 then
         		exit;
         	end if;
		dbms_sql.column_value(v_cursorID, 1, v_count);
       end loop;


	v_header := '<p><hr><b><a name="' || (ORDERNUMBER + 1)
			||'">STEP NAME: </a></b>' || '<br><hr>' || (ORDERNUMBER + 1)|| ': ' || teststpname;

	v_sqlstr := v_header || '<p><b>STEP DESCRIPTION: </b>' || '<br>' || step_description
			|| '<p>'
			|| '<b>SQL QUERY EXECUTED: </b>' || '<br>' || v_sqlstr
			|| '<p>'
			|| '<b>RETURNED VALUE: </b>' || '<br>' || v_count;
			-- || '<b>COUNT VALUE: </b>' || '<br>' || v_count;

        v_sqlstr := v_sqlstr || '<p>';
        -- v_sqlstr := v_sqlstr || '<b>ERROR TYPE: </b>' || '<br>' || error_type;
	-- v_sqlstr := v_sqlstr || '<p><b>VALIDATION VALUE: </b>' || '<br>' || validation_val1;
	v_sqlstr := v_sqlstr || '<p><b>EXPECTED RESULT: </b>' || '<br>';

	-- || validation_val1
	-- v_sqlstr := v_sqlstr || '<p><b>LOGICAL OPERATOR: </b>' || '<br>' || logical_operator || ' AND ';

        if logical_operator = '<>' then

        	v_sqlstr  := v_sqlstr || 'Returned value must not equal ' || validation_val1;

        	if to_char(v_count) <>  validation_val1 then
			-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' <> ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' IS = ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;

        elsif logical_operator = '=' then

        	v_sqlstr  := v_sqlstr || 'Returned value must equal ' || validation_val1;

        	if to_char(v_count) =  validation_val1 then
			-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' = ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' IS NOT = ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;

        elsif logical_operator = '<' then

        	v_sqlstr  := v_sqlstr || 'Returned value must be less than ' || validation_val1;

        	if v_count <  to_number(validation_val1) then
			-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' < ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' IS NOT < ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;

        elsif logical_operator = '>' then

        	v_sqlstr  := v_sqlstr || 'Returned value must be greater than ' || validation_val1;

        	if v_count >  to_number(validation_val1) then
			-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' > ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' IS NOT > ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;

        elsif logical_operator = '>=' then

        	v_sqlstr  := v_sqlstr || 'Returned value must be greater than or equal to ' || validation_val1;

        	if v_count >=  to_number(validation_val1) then
			-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' >= ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' IS NOT >= ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;
        elsif logical_operator = '<=' then

        	v_sqlstr  := v_sqlstr || 'Returned value must be less than or equal to ' || validation_val1;

        	if v_count <=  to_number(validation_val1) then
			-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' <= ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' IS NOT <= ' || validation_val1;
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;
        elsif logical_operator = 'BETWEEN' then

        	v_sqlstr  := v_sqlstr || 'Returned value must be between '
        				|| validation_val1
        				|| ' and '
        				|| validation_val2
        				|| ', both values inclusive' ;

        	if to_number(validation_val1) <= v_count and v_count <= to_number(validation_val2) then
			-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' IS BETWEEN ' || validation_val1 || ' AND ';
			-- v_sqlstr  := v_sqlstr || validation_val2;
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || to_char(v_count) || ' IS NOT BETWEEN '
        		--		|| validation_val1 || ' AND ' || validation_val2;
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;

        end if;

	SUMMARY_STRING := SUMMARY_STRING || '<tr>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || (ORDERNUMBER + 1) || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || teststpname || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || 'COUNT' || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || error_type || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>';

     	if step_failed then
     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">FAILED</a>';
        else
     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">PASSED</a>';
     	end if;

     	SUMMARY_STRING := SUMMARY_STRING || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '</tr>';

	DETAILS_STRING := DETAILS_STRING || v_sqlstr;
	DETAILS_STRING := DETAILS_STRING || '</td></tr>';

        dbms_sql.close_cursor(v_cursorID);

  END run_or_validate_count;


  ------------------------------------------------------------
  -- procedure to run_or_validate_record or no record
  ------------------------------------------------------------
  PROCEDURE run_or_validate_rec_norec(
  				appshtname in varchar2,
  				grpname in varchar2,
  				testclsname in varchar2, report OUT NOCOPY JTF_DIAG_REPORT,
  				teststpname IN VARCHAR2,
				step_description IN VARCHAR2,
				error_type IN VARCHAR2,
				error_message IN VARCHAR2,
				fix_info IN VARCHAR2,
				WHERE_CLAUSE_OR_SQL IN VARCHAR2,
				STEP_FAILED IN OUT NOCOPY BOOLEAN,
				SUMMARY_STRING IN OUT NOCOPY VARCHAR2,
				DETAILS_STRING IN OUT NOCOPY VARCHAR2,
				ORDERNUMBER IN OUT NOCOPY NUMBER,
				STEPTYPE in VARCHAR2) IS

  v_sqlstr 	VARCHAR2(32767);
  v_header	VARCHAR2(300);
  v_count	integer;
  v_cursorID	integer;

  BEGIN
	v_sqlstr := '';

	-- reportDataCell

	DETAILS_STRING:= DETAILS_STRING || '<tr><td colspan=5 class=reportDataCell>';

	v_sqlstr := WHERE_CLAUSE_OR_SQL;
	v_cursorID := DBMS_SQL.OPEN_CURSOR;

	DBMS_SQL.PARSE(v_cursorID, v_sqlstr, DBMS_SQL.V7);
	v_count := DBMS_SQL.EXECUTE_AND_FETCH(v_cursorID);

	v_header := '<p><hr><b><a name="' || (ORDERNUMBER + 1)
			||'">STEP NAME: </a></b>' || '<br><hr>' || (ORDERNUMBER + 1)|| ': ' || teststpname;

	v_sqlstr := v_header || '<p><b>STEP DESCRIPTION: </b>' || '<br>' || step_description
			|| '<p>'
			|| '<b>SQL QUERY EXECUTED: </b>' || '<br>' || v_sqlstr;

        v_sqlstr := v_sqlstr || '<p>';
        -- v_sqlstr := v_sqlstr || '<b>ERROR TYPE: </b>' || '<br>' || error_type;

        -- v_sqlstr := v_sqlstr || ' <br>value of v_count: ' || v_count || STEPTYPE;

        if STEPTYPE = 'RECORD' then

		v_sqlstr := v_sqlstr || '<b>EXECUTION STATUS: </b>'
				|| '<br>' || 'Number of rows that the query generated: ' || to_char(v_count) || '. <br>The intent of the query was to generate greater than 0 rows.';

        	if v_count >= 1 then
			-- v_sqlstr  := v_sqlstr || '<p>' || to_char(v_count) || ' >= 1. SQL returned records';
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || '<p>' || to_char(v_count) || ' IS NOT >= 1. SQL returned no records';
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;

        elsif STEPTYPE = 'NO RECORD' then

		v_sqlstr := v_sqlstr || '<b>EXECUTION STATUS: </b>'
				|| '<br>' || 'Number of rows that the query generated: ' || to_char(v_count) || '. <br>The intent of the query was to generate no rows.';

        	if v_count < 1 then
			-- v_sqlstr  := v_sqlstr || '<p>' || to_char(v_count) || ' < 1. SQL returned no records';
			v_sqlstr  := v_sqlstr || '<p><font color=green><b>STATUS: </b>Succeeded</font><p>';
			step_failed := FALSE;
		else
        		-- v_sqlstr  := v_sqlstr || '<p>' || to_char(v_count) || ' IS NOT < 1. SQL returned records';
			v_sqlstr  := v_sqlstr || '<p><b>ERROR MESSAGE: </b>'
				|| '<br>' || error_message;
			v_sqlstr  := v_sqlstr || '<p>' || '<b>FIX INFO: </b>';
			v_sqlstr  := v_sqlstr || '<br>' || fix_info;
			v_sqlstr  := v_sqlstr || '<p><font color=red><b>STATUS: </b>Failed</font><p>';
			step_failed := TRUE;
        	end if;
        end if;

	SUMMARY_STRING := SUMMARY_STRING || '<tr>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || (ORDERNUMBER + 1) || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || teststpname || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td CLASS=tableDataCell>' || STEPTYPE || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>' || error_type || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '<td  nowrap CLASS=tableDataCell>';

     	if step_failed then
     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">FAILED</a>';
        else
     		SUMMARY_STRING := SUMMARY_STRING
     				|| '<a href="#'
     				|| (ORDERNUMBER + 1)
     				||'">PASSED</a>';
     	end if;

     	SUMMARY_STRING := SUMMARY_STRING || '</td>';
     	SUMMARY_STRING := SUMMARY_STRING || '</tr>';

	DETAILS_STRING := DETAILS_STRING || v_sqlstr;
	DETAILS_STRING := DETAILS_STRING || '</td></tr>';

        dbms_sql.close_cursor(v_cursorID);

  END run_or_validate_rec_norec;



  PROCEDURE UPDATE_STEP_SEQ(
			P_APPID 	IN VARCHAR2,
			P_GROUPNAME 	IN VARCHAR2,
			P_TESTCLASSNAME IN VARCHAR2,
			P_STEPSEQARRAY	IN JTF_VARCHAR2_TABLE_4000,
                        P_LUBID         IN NUMBER) IS

    v_numofrows NUMBER;
    v_index BINARY_INTEGER := 1;

  BEGIN
	SELECT COUNT(*)
	INTO v_numofrows
        FROM jtf_diagnostic_decl_test_steps
	WHERE APPID = P_APPID
	and GROUPNAME = P_GROUPNAME
	and TESTCLASSNAME = P_TESTCLASSNAME;

        IF P_STEPSEQARRAY.COUNT <> v_numofrows THEN
		RAISE_APPLICATION_ERROR(-20000, 'Cant Update Step Sequences - Mismatch in number of sequences received');
        END IF;

        LOOP
	  IF P_STEPSEQARRAY.EXISTS(v_index) THEN

		UPDATE jtf_diagnostic_decl_test_steps
		SET EXECUTION_SEQUENCE = v_index,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
		WHERE appid = P_APPID
		and GROUPNAME = P_GROUPNAME
		and TESTCLASSNAME = P_TESTCLASSNAME
		and TESTSTEPNAME = P_STEPSEQARRAY(v_index);

		IF SQL%NOTFOUND THEN
		   RAISE_APPLICATION_ERROR(-20000,
		   		'Cant Update Step Sequence, Record Not Found'
		   		|| P_APPID || ' '
		   		|| P_GROUPNAME || ' '
		   		|| P_TESTCLASSNAME || ' ' || 'OLD EXEC SEQ: ' || v_index);
		END IF;
	        v_index := v_index + 1;

	  ELSE
	    EXIT;
          END IF;

        END LOOP;

  END UPDATE_STEP_SEQ;



  ------------------------------------------------------------
  -- procedure to report name back to framework
  ------------------------------------------------------------
  PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Declarative Diagnostic Test';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'This is a declaratively constructed diagnostic test for DB setups';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'QAPackage Test';
  END getTestName;


  ------------------------------------------------------------
  -- FUNCTION to report test name back to framework
  ------------------------------------------------------------
  FUNCTION getTestMode return INTEGER IS
  BEGIN
    return JTF_DIAGNOSTIC_ADAPTUTIL.ADVANCED_MODE;
  END getTestMode;




  ------------------------------------------------------------
  -- procedure to provide/populate  the default parameters for the test case.
  ------------------------------------------------------------
  PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL) IS
    tempInput JTF_DIAG_INPUTTBL;
  BEGIN
    tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
    -- tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'USERNAME','SYSADMIN');
    -- tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'APPID','690');
    -- tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'RESPID','21841');
    -- tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'ORGID','');
    -- tempInput := JTF_DIAGNOSTIC_ADAPTUTIL.addInput(tempInput,'PROFILE_LEVEL','');
    defaultInputValues := tempInput;
  EXCEPTION
   when others then
   defaultInputValues := JTF_DIAGNOSTIC_ADAPTUTIL.initinputtable;
  END getDefaultTestParams;


  ------------------------------------------------------------
  -- procedure to insert the count step type into the
  -- jtf_diagnostic_decl_test_steps table
  ------------------------------------------------------------
  PROCEDURE insert_core_steps(
				qAppID 		IN VARCHAR2,
				newTestName 	IN VARCHAR2,
				addToGroupName 	IN VARCHAR2,
				stepType 	IN VARCHAR2,
				newStepName 	IN VARCHAR2,
				newStepDesc 	IN VARCHAR2,
				errorType 	IN VARCHAR2,
				newStepErrMsg 	IN VARCHAR2,
				newStepFixInfo 	IN VARCHAR2,
				newStepTableName IN VARCHAR2,
				newStepQuery 	 IN VARCHAR2,
				logicalOperator  IN VARCHAR2,
				val1 		IN VARCHAR2,
				val2 		IN VARCHAR2,
				isUpdate	IN VARCHAR2,
                                P_LUBID         IN NUMBER) IS

  v_ordernumber	jtf_diagnostic_decl_test_steps.EXECUTION_SEQUENCE%TYPE;
  v_temp	number;
  v_temp_char	varchar(1000);

  BEGIN


  	-- making sure that the record is unique
  	-- by checking if it already exists

  	select count(*) into v_temp
  	from jtf_diagnostic_decl_test_steps
  	where appid = qAppID
  	and groupname = addToGroupName
  	and testclassname = newTestName
  	and TESTSTEPNAME = newStepName;

  	if v_temp > 0 and not isupdate = 'TRUE' then
  		raise_application_error(-20000, 'Step name already exists in testcase');
  	elsif isupdate = 'TRUE' and v_temp > 0 then

  		-- first cleanup all information from the
  		-- jtf_diagnostic_arg and jtf_diagnostic_decl_step_cols

  		v_temp_char := newTestName || '/' || newStepName || '{-STEP/CLASS-}%';

	  	delete from jtf_diagnostic_arg where
	  	APPID = qAppID
	  	and GROUPNAME = addToGroupName
	  	and TESTCLASSNAME like v_temp_char;

	  	delete from jtf_diagnostic_decl_step_cols
	  	where appid = qAppID
	  	and groupname = addToGroupName
	  	and testclassname = newTestName
	  	and TESTSTEPNAME = newStepName;

		update jtf_diagnostic_decl_test_steps
		set
			STEP_TYPE = stepType,
			STEP_DESCRIPTION = newStepDesc,
			ERROR_TYPE = errorType,
			ERROR_MESSAGE = newStepErrMsg,
			FIX_INFO = newStepFixInfo,
			TABLE_VIEW_NAME = newStepTableName,
			WHERE_CLAUSE_OR_SQL = newStepQuery,
			LOGICAL_OPERATOR = logicalOperator,
			VALIDATION_VAL1 = val1,
			VALIDATION_VAL2 = val2,
			OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
			LAST_UPDATE_DATE = SYSDATE,
			LAST_UPDATED_BY = P_LUBID
		where
			APPID = qAppID and
			GROUPNAME = addToGroupName and
			TESTCLASSNAME = newTestName and
			TESTSTEPNAME = newStepName;

	elsif not isupdate = 'TRUE' and v_temp = 0 then
  		-- insert the record to the database
	  	-- getting the next sequence number for
	  	-- inserting into the DB

	    	select count(*) into v_ordernumber
	  	from jtf_diagnostic_decl_test_steps
	  	where appid = qAppID
	  	and groupname = addToGroupName
	  	and testclassname = newTestName;

	  	if sql%notfound or v_ordernumber = 0 then
	  		v_ordernumber := 1;
	  	else v_ordernumber := v_ordernumber + 1;
	  	end if;

		 insert into jtf_diagnostic_decl_test_steps
		 (
			APPID,
			GROUPNAME,
			TESTCLASSNAME,
			TESTSTEPNAME,
			EXECUTION_SEQUENCE,
			STEP_TYPE,
			STEP_DESCRIPTION,
			ERROR_TYPE,
			ERROR_MESSAGE,
			FIX_INFO,
			MULTI_ORG,
			TABLE_VIEW_NAME,
			WHERE_CLAUSE_OR_SQL,
			LOGICAL_OPERATOR,
			VALIDATION_VAL1,
			VALIDATION_VAL2,
			OBJECT_VERSION_NUMBER,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			CREATION_DATE
		 )
		 values
		 (
			qAppID,
			addToGroupName,
			newTestName,
			newStepName,
			v_ordernumber,
			stepType,
			newStepDesc,
			errorType,
			newStepErrMsg,
			newStepFixInfo,
			'N',
			newStepTableName,
			newStepQuery,
			logicalOperator,
			val1,
			val2,
			1,
			P_LUBID,
			SYSDATE,
			P_LUBID,
			NULL,
			SYSDATE
		 );
  	end if;

  END insert_core_steps;

   PROCEDURE GET_TEST_STEPS(
    			p_appid IN VARCHAR2,
    			p_groupName IN VARCHAR2,
    			p_testclassname IN VARCHAR2,
    			p_teststepnames OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
    			p_teststepdesc OUT NOCOPY JTF_VARCHAR2_TABLE_4000) IS

     V_SIZE NUMBER;

     cursor testlist is

    	select TESTSTEPNAME, STEP_DESCRIPTION
    	from jtf_diagnostic_decl_test_steps
    	where APPID like p_appid
    	and GROUPNAME = p_GROUPNAME
    	and TESTCLASSNAME = p_TESTCLASSNAME
    	order by EXECUTION_SEQUENCE;

  BEGIN
  	p_teststepnames := JTF_VARCHAR2_TABLE_4000();
  	p_teststepdesc := JTF_VARCHAR2_TABLE_4000();

  	V_SIZE := 0;

  	FOR x in testlist

        LOOP
            V_SIZE := V_SIZE + 1;
            p_teststepnames.extend;
            p_teststepdesc.extend;

            p_teststepnames(V_SIZE) := x.TESTSTEPNAME;
            p_teststepdesc(V_SIZE) := x.STEP_DESCRIPTION;
        END LOOP;

  END GET_TEST_STEPS;


 PROCEDURE DELETE_STEPS(
			P_APPID 	IN VARCHAR2,
			P_GROUPNAME 	IN VARCHAR2,
			P_TESTCLASSNAME IN VARCHAR2,
			P_DELSTEPARRAY	IN JTF_VARCHAR2_TABLE_4000) IS

    v_index BINARY_INTEGER := 1;
    v_execution_sequence number;
    v_step_type varchar2(100);
    v_diagnostic_testname varchar2(250) := '';

  BEGIN
        LOOP
	  IF P_DELSTEPARRAY.EXISTS(v_index) THEN

		select distinct EXECUTION_SEQUENCE into v_execution_sequence
		from jtf_diagnostic_decl_test_steps
		where APPID = P_APPID and groupname = P_GROUPNAME
		and TESTCLASSNAME = P_TESTCLASSNAME and
		TESTSTEPNAME = P_DELSTEPARRAY(v_index);

		select step_type into v_step_type
		from jtf_diagnostic_decl_test_steps
		where APPID = P_APPID and groupname = P_GROUPNAME
		and TESTCLASSNAME = P_TESTCLASSNAME and
		TESTSTEPNAME = P_DELSTEPARRAY(v_index);


	  	-- make sure that incase this was a DIAGNOSTICTEST
	  	-- step type then the arguments table is also cleaned up.

		IF v_step_type = 'DIAGNOSTICTEST' THEN

			select table_view_name into v_diagnostic_testname
			from jtf_diagnostic_decl_test_steps
			where APPID = P_APPID and groupname = P_GROUPNAME
			and TESTCLASSNAME = P_TESTCLASSNAME and
			TESTSTEPNAME = P_DELSTEPARRAY(v_index);

			v_diagnostic_testname := P_TESTCLASSNAME
						|| '/' || P_DELSTEPARRAY(v_index)
						|| '{-STEP/CLASS-}' || v_diagnostic_testname;

		  	delete from jtf_diagnostic_arg where
		  	APPID = P_APPID
		  	and GROUPNAME = P_GROUPNAME
		  	and TESTCLASSNAME = v_diagnostic_testname;

		END IF;

	  	delete from jtf_diagnostic_decl_test_steps where
	  	APPID = P_APPID
	  	and GROUPNAME = P_GROUPNAME
	  	and TESTCLASSNAME = P_TESTCLASSNAME
	  	and TESTSTEPNAME = P_DELSTEPARRAY(v_index);

		IF SQL%NOTFOUND THEN
		   RAISE_APPLICATION_ERROR(-20000, 'Cant Delete Step, Record Not Found: '
		   		|| P_APPID
		   		|| ' '
		   		|| P_GROUPNAME
		   		|| ' '
		   		|| P_TESTCLASSNAME
		   		|| ' '
		   		|| P_DELSTEPARRAY(v_index));

		END IF;

	   	update jtf_diagnostic_decl_test_steps
	    	set EXECUTION_SEQUENCE = (EXECUTION_SEQUENCE - 1),
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE
		where EXECUTION_SEQUENCE > v_execution_sequence
	  	and APPID = P_APPID
	  	and GROUPNAME = P_GROUPNAME
	  	and TESTCLASSNAME = P_TESTCLASSNAME;


	  	-- make sure that incase this was a COLUMN
	  	-- step type then the column table is also
	  	-- cleaned up well.

		IF v_step_type = 'COLUMN' THEN
		  	delete from jtf_diagnostic_decl_step_cols where
		  	APPID = P_APPID
		  	and GROUPNAME = P_GROUPNAME
		  	and TESTCLASSNAME = P_TESTCLASSNAME
		  	and TESTSTEPNAME = P_DELSTEPARRAY(v_index);
		END IF;


	        v_index := v_index + 1;

	  ELSE
	    EXIT;
          END IF;

        END LOOP;

  END DELETE_STEPS;



  PROCEDURE addStringToClob(reportStr IN LONG, detailsClob IN OUT NOCOPY CLOB) IS
	  tempClob CLOB;
	  strSize INTEGER;
	  tmpReportStr LONG;
  BEGIN

    IF reportStr IS NOT NULL THEN
      dbms_lob.createTemporary(tempClob,true,dbms_lob.call);
      tmpReportStr := reportStr;
      select vsize(tmpReportStr) into strSize from dual;
      dbms_lob.write(tempClob,strSize,1,tmpReportStr);
      dbms_lob.append(detailsClob, tempClob);
    END IF;

  EXCEPTION
    WHEN others THEN
	--  logging here...
    null;
  END;


END JTF_DECLARATIVE_DIAGNOSTIC;


/
