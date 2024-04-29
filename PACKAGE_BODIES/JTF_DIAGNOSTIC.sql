--------------------------------------------------------
--  DDL for Package Body JTF_DIAGNOSTIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAGNOSTIC" AS
/* $Header: jtfdiagnostic_b.pls 120.20.12010000.9 2010/09/16 06:54:11 rudas ship $ */

  ------------------------------
  -- Begin procedure GET APPS
  ------------------------------


  procedure GET_APPS(
            P_APPS OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
            P_APPNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
            P_SIZE OUT NOCOPY NUMBER) is


    CURSOR APPLIST IS
        -- select distinct a.appid, b.APPLICATION_NAME
        -- from jtf_diagnostic_app a, fnd_application_tl b, fnd_application c
        -- where a.appid = c.application_short_name
        --       and c.application_id = b.application_id
        --       and b.language = userenv('LANG');

        select distinct appid from jtf_diagnostic_app;

    BEGIN

      P_SIZE := 0;
      P_APPS := JTF_VARCHAR2_TABLE_4000();
      P_APPNAMES := JTF_VARCHAR2_TABLE_4000();

      -- Add the first application that does not show up
      -- in the database fnd tables, 'HTML Platform'

      -- P_SIZE := P_SIZE + 1;
      -- P_APPS.EXTEND;
      -- P_APPNAMES.EXTEND;
      -- P_APPS(P_SIZE) := 'SYSTEM_TESTS';
      -- P_APPNAMES(P_SIZE) := 'HTML Platform';
      -- P_APPNAMES(P_SIZE) := '';

      -- Now get stuff from the database and populate the
      -- rest of the array

      FOR x in APPLIST
        LOOP
            P_SIZE := P_SIZE + 1;
            P_APPS.EXTEND;
            P_APPNAMES.EXTEND;
            P_APPS(P_SIZE) := x.APPID;
            -- P_APPNAMES(P_SIZE) := x.APPLICATION_NAME;
            P_APPNAMES(P_SIZE) := '';
        END LOOP;

    END GET_APPS;


  ---------------------------------------------------
  -- Begin procedure to GET GROUPS FOR AN APPLICATION
  ---------------------------------------------------


    procedure GET_GROUPS(
  		P_APPNAME in VARCHAR2,
  		P_GROUPNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
  		P_GRP_SENSITIVITY OUT NOCOPY JTF_NUMBER_TABLE,
		P_GRP_LAST_UPDATED_BY OUT NOCOPY JTF_NUMBER_TABLE) is

    V_SIZE NUMBER;

    /* 5953806 - changed select to get last_updated_by instead of created_by */
    cursor grouplist is
    	select groupName, sensitivity, last_updated_by
    	from jtf_diagnostic_group
    	where appID like P_APPNAME
    	order by orderNumber;

    BEGIN

      P_GROUPNAMES := JTF_VARCHAR2_TABLE_4000();
      P_GRP_SENSITIVITY := JTF_NUMBER_TABLE();
      P_GRP_LAST_UPDATED_BY := JTF_NUMBER_TABLE();

      V_SIZE := 0;

      FOR x in grouplist
        LOOP

            V_SIZE := V_SIZE + 1;
            P_GROUPNAMES.extend;
            P_GROUPNAMES(V_SIZE) := x.groupName;

            P_GRP_SENSITIVITY.extend;
            P_GRP_SENSITIVITY(V_SIZE) := x.sensitivity;

	    P_GRP_LAST_UPDATED_BY.extend;
	    P_GRP_LAST_UPDATED_BY(V_SIZE) := x.last_updated_by;

        END LOOP;

    END GET_GROUPS;


  ---------------------------------------------------
  -- Begin procedure to GET TESTS FOR AN APPLICATION
  ---------------------------------------------------


  procedure GET_TESTS(
  		P_APPNAME IN VARCHAR2,
  		P_GROUPNAME IN VARCHAR2,
  		P_TESTCLASSNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
  		P_TESTTYPES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
  		P_TOTALARGROWS OUT NOCOPY JTF_NUMBER_TABLE,
                P_TST_SENSITIVITY OUT NOCOPY JTF_NUMBER_TABLE,
		P_TEST_LAST_UPDATED_BY OUT NOCOPY JTF_NUMBER_TABLE
  		) IS


    V_SIZE number;

    /* 5953806 - changed select to get last_updated_by instead of created_by */
    cursor testlist is
    	select testClassName, testtype, totalargumentrows, sensitivity, last_updated_by
    	from jtf_diagnostic_test
    	where appID like P_APPNAME
    	and groupname like P_GROUPNAME
    	order by orderNumber;

    BEGIN

      P_TESTCLASSNAMES := JTF_VARCHAR2_TABLE_4000();
      P_TESTTYPES := JTF_VARCHAR2_TABLE_4000();
      P_TOTALARGROWS := JTF_NUMBER_TABLE();
      P_TST_SENSITIVITY := JTF_NUMBER_TABLE();
      P_TEST_LAST_UPDATED_BY := JTF_NUMBER_TABLE();

      V_SIZE := 0;

      FOR x in TESTLIST
        LOOP
            V_SIZE := V_SIZE + 1;
            P_TESTCLASSNAMES.extend;
            P_TESTTYPES.EXTEND;
            P_TOTALARGROWS.EXTEND;
	    P_TEST_LAST_UPDATED_BY.EXTEND;
            P_TESTCLASSNAMES(V_SIZE) := x.TESTCLASSNAME;
            P_TESTTYPES(V_SIZE) := X.TESTTYPE;
            P_TOTALARGROWS(V_SIZE) := X.TOTALARGUMENTROWS;
	    P_TST_SENSITIVITY(V_SIZE) := X.SENSITIVITY;
	    P_TEST_LAST_UPDATED_BY(V_SIZE) := X.LAST_UPDATED_BY;
        END LOOP;

    END GET_TESTS;

-- deprecated don't use if you have test level sensitivity
  procedure GET_TESTS(
                P_APPNAME IN VARCHAR2,
                P_GROUPNAME IN VARCHAR2,
                P_TESTCLASSNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
                P_TESTTYPES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
                P_TOTALARGROWS OUT NOCOPY JTF_NUMBER_TABLE,
                P_TEST_LAST_UPDATED_BY OUT NOCOPY JTF_NUMBER_TABLE
                ) IS


    V_SIZE number;

    /* 5953806 - changed select to get last_updated_by instead of created_by */
    cursor testlist is
        select testClassName, testtype, totalargumentrows, last_updated_by
        from jtf_diagnostic_test
        where appID like P_APPNAME
        and groupname like P_GROUPNAME
        order by orderNumber;

    BEGIN

      P_TESTCLASSNAMES := JTF_VARCHAR2_TABLE_4000();
      P_TESTTYPES := JTF_VARCHAR2_TABLE_4000();
      P_TOTALARGROWS := JTF_NUMBER_TABLE();
      P_TEST_LAST_UPDATED_BY := JTF_NUMBER_TABLE();

      V_SIZE := 0;

      FOR x in TESTLIST
        LOOP
            V_SIZE := V_SIZE + 1;
            P_TESTCLASSNAMES.extend;
            P_TESTTYPES.EXTEND;
            P_TOTALARGROWS.EXTEND;
            P_TEST_LAST_UPDATED_BY.EXTEND;
            P_TESTCLASSNAMES(V_SIZE) := x.TESTCLASSNAME;
            P_TESTTYPES(V_SIZE) := X.TESTTYPE;
            P_TOTALARGROWS(V_SIZE) := X.TOTALARGUMENTROWS;
            P_TEST_LAST_UPDATED_BY(V_SIZE) := X.LAST_UPDATED_BY;
        END LOOP;

    END GET_TESTS;

  ----------------------------------------------------------
  -- Begin procedure to GET ARGS FOR A TEST, GROUP, APP
  ----------------------------------------------------------


    procedure GET_ARGS(
		P_APPID IN VARCHAR2,
  		P_GROUPNAME IN VARCHAR2,
		P_TESTCLASSNAME IN VARCHAR2,
		P_ARGNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
		P_ARGVALUES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
		P_ROWNUMBERS OUT NOCOPY JTF_NUMBER_TABLE,
		P_VALUESETNUM OUT NOCOPY JTF_NUMBER_TABLE) is

    V_SIZE number;

    cursor arglist is
    	select argname, argvalue, rownumber, valuesetnumber
	from jtf_diagnostic_arg
	where TestClassName = P_TESTCLASSNAME
	and groupname = P_GROUPNAME
	and appid = P_APPID
	order by rownumber;

    BEGIN

      P_ARGNAMES := jtf_varchar2_table_4000();
      P_ARGVALUES := jtf_varchar2_table_4000();
      P_ROWNUMBERS := JTF_NUMBER_TABLE();
      P_VALUESETNUM := JTF_NUMBER_TABLE();

      V_SIZE := 0;

      FOR x in arglist
        LOOP
            V_SIZE := V_SIZE + 1;

            P_ARGNAMES.extend;
            P_ARGVALUES.extend;
            P_ROWNUMBERS.extend;
            P_VALUESETNUM.extend;

            P_ARGNAMES(V_SIZE) := x.ArgName;
            P_argvalues(V_SIZE) := x.argvalue;
            P_ROWNUMBERS(V_SIZE) := x.RowNumber;
            P_VALUESETNUM(V_SIZE) := x.valuesetnumber;
        END LOOP;

    END GET_ARGS;


  ----------------------------------------------------------
  -- Begin procedure to GET PREREQS FOR AN APP OR A GROUP
  -- Also gets the full name of the application based on
  -- whether it is an application or a group
  ----------------------------------------------------------


    procedure GET_PREREQS(
  		P_APP_OR_GROUP_NAME IN VARCHAR2,
  		P_APPNAME IN VARCHAR2,
  		P_PREREQ_IDS OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
  		P_PREREQ_NAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000
  		) IS

  	V_SIZE NUMBER;
  	V_TEMP_NAME VARCHAR2(256);
  	V_TEMP_TYPE NUMBER;

  	CURSOR prereqlist is
  		select prereqid, type
  		from jtf_diagnostic_prereq
  		where sourceid = P_APP_OR_GROUP_NAME
  		and sourceappid = P_APPNAME;


    BEGIN
  	V_SIZE := 0;
  	P_PREREQ_IDS := JTF_VARCHAR2_TABLE_4000();
  	P_PREREQ_NAMES := JTF_VARCHAR2_TABLE_4000();
  	V_TEMP_NAME := '';
  	V_TEMP_TYPE := 0;

  	FOR x in prereqlist
        LOOP

            V_SIZE := V_SIZE + 1;
            P_PREREQ_IDS.extend;
            P_PREREQ_NAMES.extend;
            P_PREREQ_IDS(V_SIZE) := x.PREREQID;
            V_TEMP_TYPE := x.TYPE;
            V_TEMP_NAME := x.PREREQID;

            IF V_TEMP_TYPE = 1 AND V_TEMP_NAME <> 'SYSTEM_TESTS' THEN

            	-- select a.application_name into V_TEMP_NAME
            	-- from fnd_application_tl a, fnd_application b
            	-- where b.APPLICATION_SHORT_NAME = x.PREREQID
            	-- and b.APPLICATION_ID = a.APPLICATION_ID
            	-- and a.language = userenv('LANG');
                V_TEMP_NAME := '';

            ELSIF V_TEMP_TYPE = 1 AND V_TEMP_NAME = 'SYSTEM_TESTS' THEN
            	-- V_TEMP_NAME := 'HTML Platform';
                V_TEMP_NAME := '';

            END IF;

            P_PREREQ_NAMES(V_SIZE) := V_TEMP_NAME;

        END LOOP;

    END GET_PREREQS;



  -- ----------------------------------------------------------------------
  -- Updates a groups sensitivity in the database
  -- ----------------------------------------------------------------------

  procedure UPDATE_GROUP_SENSITIVITY(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_GRP_SENSITIVITY IN NUMBER,
  		P_LUBID IN NUMBER
	        ) IS

    BEGIN

		UPDATE jtf_diagnostic_group
		SET sensitivity = P_GRP_SENSITIVITY,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
		WHERE appid = P_APP_NAME AND
		      groupname = P_GROUP_NAME;

		IF SQL%NOTFOUND THEN
		   RAISE_APPLICATION_ERROR(-20000,'Cant Update, Record Not Found');
		END IF;


    END UPDATE_GROUP_SENSITIVITY;


  -- This is deprecated, please use the one above
  procedure UPDATE_GROUP_SENSITIVITY(
                P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_GRP_SENSITIVITY IN NUMBER
                ) IS
   BEGIN

       UPDATE_GROUP_SENSITIVITY(P_APP_NAME,
                                P_GROUP_NAME,
                                P_GRP_SENSITIVITY,
                                UID);

   END UPDATE_GROUP_SENSITIVITY;


-----------------------------------------------------------
  -- Updates a tests sensitivity in the database
----------------------------------------------------------

  procedure UPDATE_TEST_SENSITIVITY(
                P_APP_NAME IN VARCHAR2,
                P_GROUP_NAME IN VARCHAR2,
                P_TEST_NAME IN VARCHAR2,
                P_TST_SENSITIVITY IN NUMBER,
                P_LUBID IN NUMBER
                ) IS
    BEGIN

                UPDATE jtf_diagnostic_test
                SET sensitivity = P_TST_SENSITIVITY,
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = P_LUBID
                WHERE appid = P_APP_NAME AND
                      groupname = P_GROUP_NAME AND
		      testclassname = P_TEST_NAME;

                IF SQL%NOTFOUND THEN
                   RAISE_APPLICATION_ERROR(-20000,'Cant Update, Record Not
Found');
                END IF;


    END UPDATE_TEST_SENSITIVITY;

  ----------------------------------------------------------
  -- procedure DELETE AN APPLICATION
  ----------------------------------------------------------

   procedure DELETE_APP(
  		P_APP_NAME IN VARCHAR2
  		) IS

    BEGIN

        delete from jtf_diagnostic_app
        where appid = P_APP_NAME;

    	delete from jtf_diagnostic_group
    	where appid = P_APP_NAME;

    	delete from jtf_diagnostic_test
    	where appid = P_APP_NAME;

        delete from jtf_diagnostic_arg
    	where appid = P_APP_NAME;

    	delete from jtf_diagnostic_prereq
        where sourceappid = P_APP_NAME;

    	delete from jtf_diagnostic_prereq
        where prereqid = P_APP_NAME;

    END DELETE_APP;

  ----------------------------------------------------------
  -- procedure DELETE a GROUP FOR AN APPLICATION
  ----------------------------------------------------------


   procedure DELETE_GROUP(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2
  		) IS

    V_ORDERNUM 	jtf_diagnostic_group.ordernumber%TYPE;

    l_groupname varchar2(500);
    l_ordernumber number;
    l_object_version_number number;

    -- SKHEMANI Use the cursor to cleanup the
    -- entry in the JTF_DIAGNOSTIC_KB table

    CURSOR TSTLIST IS
        select testclassname from jtf_diagnostic_test
        where appid = P_APP_NAME
        and groupname = P_GROUP_NAME;

    CURSOR GRPLIST (c_ordernumber number) IS
	select groupname, ordernumber, object_version_number
	from jtf_diagnostic_group
	where appid = P_APP_NAME
	and ordernumber > c_ordernumber
	order by ordernumber;

    BEGIN

	-- populate the variable v_ordernum
	-- so that we can use this for resequencing

	select distinct count(*) into V_ORDERNUM
	from jtf_diagnostic_group
	where APPID = P_APP_NAME and groupname = P_GROUP_NAME;

	-- if the ordernumber not found then no point continuing with
	-- the rest, just raise an exception

	IF v_ordernum = 0 THEN
		RAISE_APPLICATION_ERROR(-20000, 'Record not found for deleting group');
    	END IF;


    	-- if application error not raised then
    	-- get the right order number into the variable
    	-- for further processing

    	select distinct ordernumber into V_ORDERNUM
	from jtf_diagnostic_group
	where APPID = P_APP_NAME and groupname = P_GROUP_NAME;

    	-- if flow of control reaches here,
    	-- cleanup all information about this group
    	-- from the jtf_diagnostic_group table

    	delete from jtf_diagnostic_group
    	where groupname = P_GROUP_NAME
    	and appid = P_APP_NAME;

    	-- Resequence the groups to make sure there are no holes in the
    	-- groups of this application

	open GRPLIST(V_ORDERNUM);
	loop
	  fetch GRPLIST into l_groupname, l_ordernumber, l_object_version_number;
	  exit when (GRPLIST%notfound);
    	  update jtf_diagnostic_group
    	  set ordernumber = (l_ordernumber - 1),
	  OBJECT_VERSION_NUMBER = l_OBJECT_VERSION_NUMBER + 1,
	  LAST_UPDATE_DATE = SYSDATE
	  where groupname = l_groupname
    	  and appid = P_APP_NAME;
	end loop;
	close GRPLIST;

        -- SKHEMANI Use the cursor to cleanup the
	-- entries of all tests in the JTF_DIAGNOSTIC_KB table
	-- pertaining to this group, if any

        FOR x in TSTLIST
        LOOP
        	delete_test(P_APP_NAME, P_GROUP_NAME, x.testclassname);
        END LOOP;

	-- fix for bug 4606418, we were not cleaning
	-- up the prereqs of a group at the time of deleting a
	-- group

    	delete from jtf_diagnostic_prereq
    	where sourceid = P_GROUP_NAME
    	and sourceappid = P_APP_NAME;

    END DELETE_GROUP;


  ----------------------------------------------------------
  -- procedure delete a test for a group and app
  ----------------------------------------------------------


   procedure DELETE_TEST(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_TEST_CLASS_NAME IN VARCHAR2
  		) IS

  	V_ORDERNUM 	jtf_diagnostic_test.ordernumber%TYPE;
  	V_SEQUENCE	jtf_diagnostic_test.sequence%TYPE;

	l_testclassname varchar2(1500);
	l_ordernumber number;
	l_object_version_number number;

    CURSOR TESTLIST (c_ordernumber number) IS
        select testclassname, ordernumber, object_version_number
        from jtf_diagnostic_test
        where appid = P_APP_NAME
	and groupname = P_GROUP_NAME
        and ordernumber > c_ordernumber
        order by ordernumber;

    BEGIN

	select count(*) into V_ORDERNUM
	from jtf_diagnostic_test
	where APPID = P_APP_NAME
	and groupname = P_GROUP_NAME
	and testclassname = P_TEST_CLASS_NAME
	and rownum <= 1;

	-- if the ordernumber not found then no point continuing with
	-- the rest, just raise an exception

	IF v_ordernum = 0 THEN
		RAISE_APPLICATION_ERROR(-20000, 'Record not found for deleting test');
    	END IF;


	-- SKHEMANI if flow of control reaches here, then the test has been found
	-- great... we will use this sequence number to cleanup the
	-- entry in the JTF_DIAGNOSTIC_KB table

	select sequence into V_SEQUENCE
	from jtf_diagnostic_test
	where APPID = P_APP_NAME
	and groupname = P_GROUP_NAME
	and testclassname = P_TEST_CLASS_NAME
	and rownum <= 1;

	-- SKHEMANI Use the stored sequence number to cleanup the
	-- entry in the JTF_DIAGNOSTIC_KB table

	delete from jtf_diagnostic_kb where
	sequence = V_SEQUENCE;


    	-- populate the variable v_ordernum
	-- so that we can use this for resequencing
	-- incase there are more than one testcases with the same classname
	-- they should all be deleted since a group should have the same testclassname
	-- appearing once in it

	select ordernumber into V_ORDERNUM
	from jtf_diagnostic_test
	where APPID = P_APP_NAME
	and groupname = P_GROUP_NAME
	and testclassname = P_TEST_CLASS_NAME
	and rownum <= 1;


    	-- cleanup all information about this test
    	-- from the jtf_diagnostic_test table

    	delete from jtf_diagnostic_test
    	where groupname = P_GROUP_NAME
    	and appid = P_APP_NAME
    	and testclassname = P_TEST_CLASS_NAME;

    	-- Resequence the testcases to make sure there are no holes in the
    	-- testcases of this group and application

        open TESTLIST(V_ORDERNUM);
        loop
          fetch TESTLIST into l_testclassname, l_ordernumber,
l_object_version_number;
          exit when (TESTLIST%notfound);
      	  update jtf_diagnostic_test
    	  set ordernumber = (l_ordernumber - 1),
	  OBJECT_VERSION_NUMBER = l_OBJECT_VERSION_NUMBER + 1,
	  LAST_UPDATE_DATE = SYSDATE
	  where testclassname = l_testclassname
    	  and appid = P_APP_NAME
    	  and groupname = P_GROUP_NAME;
	end loop;
	close TESTLIST;

    	-- cleanup all information about this testcase (testcase arguments)
    	-- from the jtf_diagnostic_arg table

    	delete from jtf_diagnostic_arg
    	where groupname = P_GROUP_NAME
    	and appid = P_APP_NAME
    	and testclassname = P_TEST_CLASS_NAME;

        -- cleanup all information about all teststeps of this testcase
    	-- from the jtf_diagnostic_decl_test_steps table

    	delete from jtf_diagnostic_decl_test_steps
    	where groupname = P_GROUP_NAME
    	and appid = P_APP_NAME
    	and testclassname = P_TEST_CLASS_NAME;

        -- cleanup all information about all teststeps of this testcase
    	-- from the jtf_diagnostic_decl_step_cols table

    	delete from jtf_diagnostic_decl_step_cols
    	where groupname = P_GROUP_NAME
    	and appid = P_APP_NAME
    	and testclassname = P_TEST_CLASS_NAME;

    	-- commit;

    END DELETE_TEST;




   procedure DELETE_ALL_ARGS_FOR_TEST(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_TEST_CLASS_NAME IN VARCHAR2
  		) IS

  BEGIN
    	delete from jtf_diagnostic_arg
    	where testclassname = P_TEST_CLASS_NAME
    	and groupname = P_GROUP_NAME
    	and appid = P_APP_NAME;
  END DELETE_ALL_ARGS_FOR_TEST;



  ----------------------------------------------------------
  -- procedure delete arguments for a testclassname, given
  -- a row number, application id and group name
  ----------------------------------------------------------


   procedure DELETE_ARG_SET(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_TEST_CLASS_NAME IN VARCHAR2,
  		P_ARG_ROW_NUM IN NUMBER
  		) IS

    BEGIN

    	-- remove the argument combination corresponding to the
    	-- testcase where we get the rownumber from the UI / Java layer
    	-- where each rownumber corresponds to one combination of
    	-- arguments which we will just delete

    	delete from jtf_diagnostic_arg
    	where testclassname = P_TEST_CLASS_NAME
    	and groupname = P_GROUP_NAME
    	and appid = P_APP_NAME
    	and rownumber = P_ARG_ROW_NUM;

    	-- If a row was deleted, then bump down the
    	-- number of argument rows for jtf_diagnostic_test

    	IF NOT SQL%NOTFOUND THEN
	    update jtf_diagnostic_test
	    set totalargumentrows = (totalargumentrows - 1),
	    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
	    LAST_UPDATE_DATE = SYSDATE
	    where testclassname = P_TEST_CLASS_NAME
	    and groupname = P_GROUP_NAME
    	    and appid = P_APP_NAME;

    	    update jtf_diagnostic_arg
    	    set rownumber = (rownumber - 1),
	    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
	    LAST_UPDATE_DATE = SYSDATE
    	    where testclassname = P_TEST_CLASS_NAME
    	    and groupname = P_GROUP_NAME
    	    and appid = P_APP_NAME
    	    and rownumber > P_ARG_ROW_NUM;
    	END IF;

    	-- commit;

    END DELETE_ARG_SET;


  ------------------------------
  -- Begin procedure UPDATE_GROUP_SEQ
  ------------------------------


    procedure UPDATE_GROUP_SEQ(
                P_APPID IN VARCHAR2,
                P_GROUPNAMES IN JTF_VARCHAR2_TABLE_4000,
                P_LUBID IN NUMBER) is

    v_numofrows NUMBER;
    v_index BINARY_INTEGER := 1;


    BEGIN

	SELECT COUNT(*)
	INTO v_numofrows
        FROM jtf_diagnostic_group
	WHERE appid = P_APPID;

        IF P_GROUPNAMES.COUNT <> v_numofrows THEN
		--RAISE_APPLICATION_ERROR(-20000, 'Cant Update - Mismatch');
                RAISE_APPLICATION_ERROR(-20000, 'UPDATE_GROUP_SEQ(): Cannot Update -
Mismatch. P_APPID=' || P_APPID|| ' ; v_numofrows='||v_numofrows ||' ;
P_GROUPNAMES.COUNT='||P_GROUPNAMES.COUNT);
        END IF;

        LOOP
	  IF P_GROUPNAMES.EXISTS(v_index) THEN

	  	UPDATE jtf_diagnostic_group
		SET ordernumber = v_index * -1
		WHERE appid = P_APPID AND
		ordernumber = v_index;

		UPDATE jtf_diagnostic_group
		SET ordernumber = v_index,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE
		--LAST_UPDATED_BY = P_LUBID
		WHERE appid = P_APPID AND
		      groupname = P_GROUPNAMES(v_index);

		IF SQL%NOTFOUND THEN
		   RAISE_APPLICATION_ERROR(-20000,'Cant Update, Record Not Found');
		END IF;
	        v_index := v_index + 1;
	  ELSE
	    EXIT;
          END IF;
        END LOOP;

	-- commit;

    END UPDATE_GROUP_SEQ;


    -- deprecated, please use the one above

    procedure UPDATE_GROUP_SEQ(
		P_APPID IN VARCHAR2,
    		P_GROUPNAMES IN JTF_VARCHAR2_TABLE_4000
                ) IS

    BEGIN

          UPDATE_GROUP_SEQ(P_APPID,
                           P_GROUPNAMES,
                           UID);


    END UPDATE_GROUP_SEQ;

  ----------------------------------
  -- Begin procedure UPDATE_TEST_SEQ
  ----------------------------------


    procedure UPDATE_TEST_SEQ(
                P_APPID IN VARCHAR2,
		P_GROUPNAME IN VARCHAR2,
                P_TESTCLASSNAMES IN JTF_VARCHAR2_TABLE_4000,
                P_LUBID IN NUMBER) is

    v_numofrows NUMBER;
    v_index BINARY_INTEGER := 1;

    BEGIN

	SELECT COUNT(*)
	INTO v_numofrows
        FROM jtf_diagnostic_test
	WHERE appid = P_APPID AND
	      groupname = P_GROUPNAME;

        IF P_TESTCLASSNAMES.COUNT <> v_numofrows THEN
		--RAISE_APPLICATION_ERROR(-20000, 'Cant Update - Mismatch');
                RAISE_APPLICATION_ERROR(-20000, 'UPDATE_TEST_SEQ(): Cannot Update -
Mismatch. P_APPID=' || P_APPID|| ' ; P_GROUPNAME='|| P_GROUPNAME || ' ;v_numofrows='||v_numofrows ||' ;
P_TESTCLASSNAMES.COUNT='||P_TESTCLASSNAMES.COUNT);
        END IF;

        LOOP
	  IF P_TESTCLASSNAMES.EXISTS(v_index) THEN

  	  	UPDATE jtf_diagnostic_test
		SET ordernumber = v_index * -1
		WHERE appid = P_APPID AND
		groupname = p_groupname and
		ordernumber = v_index;


		UPDATE jtf_diagnostic_test
		SET OrderNumber = v_index,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE
		--LAST_UPDATED_BY = P_LUBID
		WHERE appid = P_APPID AND
		      groupname = P_GROUPNAME AND
		      testclassname = P_TESTCLASSNAMES(v_index);

		IF SQL%NOTFOUND THEN
		   RAISE_APPLICATION_ERROR(-20000,'Cant Update, Record Not Found');
		END IF;
	        v_index := v_index + 1;
	  ELSE
	    EXIT;
          END IF;
        END LOOP;

	-- commit;

    END UPDATE_TEST_SEQ;


    procedure UPDATE_TEST_SEQ(
		P_APPID IN VARCHAR2,
		P_GROUPNAME IN VARCHAR2,
		P_TESTCLASSNAMES IN JTF_VARCHAR2_TABLE_4000
                ) IS

    BEGIN

          UPDATE_TEST_SEQ(P_APPID,
                          P_GROUPNAME,
                          P_TESTCLASSNAMES,
                          UID);

    END UPDATE_TEST_SEQ;

  ---------------------------------
  -- Begin procedure UPDATE_PREREQS
  ---------------------------------


  procedure UPDATE_PREREQS(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_SOURCETYPE IN NUMBER,
                P_LUBID IN NUMBER) IS

        v_index 	BINARY_INTEGER := 1;
        v_data_found    BINARY_INTEGER := 0;



    BEGIN

   	CHECK_APP_OR_GROUP_VALIDITY(P_SOURCEID,P_SOURCEAPPID,P_SOURCETYPE);

        -- if flow of control has reached thus far, remove all records
        -- for the sourceid supplied to the pl/sql layer

    	delete from jtf_diagnostic_prereq
    	where sourceid = p_sourceid
    	and sourceappid = p_sourceappid;

    	IF P_PREREQID IS NOT NULL AND P_PREREQID.COUNT > 0 THEN
    	    PREREQ_INSERTION(P_SOURCEID,P_SOURCEAPPID,P_PREREQID,P_SOURCETYPE,P_LUBID);
    	END IF;

    	-- commit;
    END UPDATE_PREREQS;

  -- deprecated, please use procedure above
  procedure UPDATE_PREREQS(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_SOURCETYPE IN NUMBER) IS

  BEGIN

        UPDATE_PREREQS(P_SOURCEID,
                       P_SOURCEAPPID,
                       P_PREREQID,
                       P_SOURCETYPE,
                       UID);

  END UPDATE_PREREQS;

  ------------------------------
  -- Begin procedure UPDATE_ARG_VALUES
  ------------------------------


    procedure UPDATE_ARG_VALUES(
                P_TESTCLASSNAME IN VARCHAR2,
                P_GROUPNAME IN VARCHAR2,
                P_APPID IN VARCHAR2,
                P_ARGNAMES IN JTF_VARCHAR2_TABLE_4000,
                P_ARGVALUES IN JTF_VARCHAR2_TABLE_4000,
                P_ROWNUMBER IN NUMBER,
                P_LUBID IN NUMBER) is

    v_index BINARY_INTEGER := 1;

    BEGIN

    loop
    	if p_argnames.EXISTS(v_index) AND p_argvalues.exists(v_index) then

    		update jtf_diagnostic_arg set
    		argvalue = p_argvalues(v_index),
    		object_version_number = object_version_number + 1,
    		-- last_updated_by = UID,
                last_updated_by = P_LUBID,
    		last_update_date = sysdate
    		where argname = p_argnames(v_index)
    		and rownumber = p_rownumber
    		and testclassname = p_testclassname
    		and groupname = p_groupname
    		and appid = p_appid;


    		if sql%notfound then
    			raise_application_error(-20000,
    				'Invalid data received -- no record found to update');
    		end if;

		-- increment the counter
    		v_index := v_index + 1;
    	else
    		exit;
    	end if;



    end loop;
      -- commit;
    END UPDATE_ARG_VALUES;

    -- deprecated, please use procedure above
    procedure UPDATE_ARG_VALUES(
		P_TESTCLASSNAME IN VARCHAR2,
		P_GROUPNAME IN VARCHAR2,
		P_APPID IN VARCHAR2,
		P_ARGNAMES IN JTF_VARCHAR2_TABLE_4000,
		P_ARGVALUES IN JTF_VARCHAR2_TABLE_4000,
		P_ROWNUMBER IN NUMBER
		) IS

    BEGIN

          UPDATE_ARG_VALUES(P_TESTCLASSNAME,
                            P_GROUPNAME,
                            P_APPID,
                            P_ARGNAMES,
                            P_ARGVALUES,
                            P_ROWNUMBER,
                            UID);

    END UPDATE_ARG_VALUES;

  -- ----------------------------------------------------------------------
  -- Insert an app into the framework with or without prereqs
  -- ----------------------------------------------------------------------

  procedure INSERT_APP(
  		P_APPID IN VARCHAR2,
  		P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_LUBID IN NUMBER) IS

  	-- v_asn		fnd_application.application_short_name%TYPE;
        V_SOURCETYPE 	BINARY_INTEGER := 1;

  BEGIN

  	-- check if the application value entered is
  	-- a valid application in the fnd_application table
  	-- and if yes it should not already be there in the
  	-- jtf_diagnostic_app table

  	-- select distinct application_short_name into v_asn
  	-- from fnd_application
  	-- where application_short_name = P_APPID
  	-- and rownum <= 1;

  	-- if sql%notfound then
  	--	raise_application_error(-20000,
  	--				'Invalid application short name');
  	-- else
  		select count(*) into v_sourcetype
  		from jtf_diagnostic_app
  		where appid = P_APPID;

  		if v_sourcetype <> 0 then
			raise_application_error(-20000,
  				'Application already registered');
  		end if;
  	-- end if;

  	v_sourcetype := 1;

  	-- Else create a new record
  	-- since the new value seems fine

  	insert into jtf_diagnostic_app(
  	SEQUENCE, APPID, OBJECT_VERSION_NUMBER, CREATED_BY,
  	LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE)
  	values (JTF_DIAGNOSTIC_APP_S.NEXTVAL, P_APPID, 1, P_LUBID,
  	SYSDATE, P_LUBID, NULL, SYSDATE);


  	-- Now check if the object received as the pre-req array
  	-- is not null in which case call the insertion routine

  	IF NOT P_PREREQID IS NULL then
  	  V_SOURCETYPE := 1;
	  PREREQ_INSERTION(P_APPID, P_APPID, P_PREREQID, V_SOURCETYPE, P_LUBID);
  	end if;

  	-- commit;

  END INSERT_APP;

  -- deprecated, please use procedure above
  procedure INSERT_APP(
  		P_APPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000
  		) IS

  BEGIN

        INSERT_APP(P_APPID,
                   P_PREREQID,
                   UID);

  END INSERT_APP;



  -- ----------------------------------------------------------------------
  -- Insert Group with or without prereqs with out SENSITIVITY
  -- ----------------------------------------------------------------------

  procedure INSERT_GRP(
  		P_NEW_GROUP IN VARCHAR2,
 		P_APP IN VARCHAR2,
		P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
		P_LUBID IN NUMBER) IS

  	v_groupname	jtf_diagnostic_group.groupname%TYPE;
  	V_SOURCETYPE 	BINARY_INTEGER := 2;
  	v_ordernumber	jtf_diagnostic_group.ordernumber%TYPE;


  BEGIN

  	-- Check if application is valid
	V_SOURCETYPE := 1;
  	CHECK_APP_OR_GROUP_VALIDITY(P_APP, P_APP, V_SOURCETYPE);

  	-- if flow of control reached here, implies that the
  	-- application is a valid application in the diagnostic framework


  	-- now check if the group value entered is
  	-- not already there in the tables for the application
  	-- and if yes it should not be reentered

  	select count(*) into v_sourcetype
  	from jtf_diagnostic_group
  	where appid = P_APP and groupname = p_new_group
  	and rownum <= 1;

	-- if anything found then raise an application error since the
	-- same group cannot be added multiple times

  	if v_sourcetype <> 0 then
  		raise_application_error(-20000,
  					'Group already exist. Cannot reenter');
  	end if;

  	-- reset the old v_sourcetype value
  	v_sourcetype := 1;


  	-- Else create a new record
  	-- since the new value seems fine
  	-- but first find out the highest number of order of groups
	-- and add this to the end. If there are no groups
	-- then make sure that this gets the first order number

  	select MAX(ordernumber) into v_ordernumber
  	from jtf_diagnostic_group where appid = p_app;

  	if sql%notfound or v_ordernumber = 0 then
  		v_ordernumber := 1;
  	else v_ordernumber := v_ordernumber + 1;

  	end if;


	insert into jtf_diagnostic_group(
	SEQUENCE, GROUPNAME,
	APPID, ORDERNUMBER,
	OBJECT_VERSION_NUMBER, CREATED_BY,
	LAST_UPDATE_DATE, LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN, CREATION_DATE)
	values(
	JTF_DIAGNOSTIC_GROUP_S.NEXTVAL, P_NEW_GROUP,
	P_APP, DECODE(v_ordernumber,null,1,v_ordernumber),
	1, P_LUBID,
	SYSDATE, P_LUBID,
	NULL, SYSDATE);


  	-- Now check if the object received as the pre-req array
  	-- is not null in which case call the insertion routine

  	IF NOT P_PREREQID IS NULL then
  	  V_SOURCETYPE := 2;
	  PREREQ_INSERTION(P_NEW_GROUP, P_APP, P_PREREQID, V_SOURCETYPE);
  	end if;

  	-- commit;

  END INSERT_GRP;

  procedure INSERT_GRP(
  		P_NEW_GROUP IN VARCHAR2,
 		P_APP IN VARCHAR2,
		P_PREREQID IN JTF_VARCHAR2_TABLE_4000
		) IS

  BEGIN

        INSERT_GRP(P_NEW_GROUP,
                     P_APP,
                     P_PREREQID,
                     UID);

  END INSERT_GRP;

  -- ----------------------------------------------------------------------
  -- Insert Group with or without prereqs -DEPRECATED
  -- ----------------------------------------------------------------------

  procedure INSERT_GROUP(
  		P_NEW_GROUP IN VARCHAR2,
 		P_APP IN VARCHAR2,
		P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
		P_SENSITIVITY IN NUMBER,
		P_LUBID IN NUMBER) IS

  	v_groupname	jtf_diagnostic_group.groupname%TYPE;
  	V_SOURCETYPE 	BINARY_INTEGER := 2;
  	v_ordernumber	jtf_diagnostic_group.ordernumber%TYPE;


  BEGIN

  	-- Check if application is valid
	V_SOURCETYPE := 1;
  	CHECK_APP_OR_GROUP_VALIDITY(P_APP, P_APP, V_SOURCETYPE);

  	-- if flow of control reached here, implies that the
  	-- application is a valid application in the diagnostic framework


  	-- now check if the group value entered is
  	-- not already there in the tables for the application
  	-- and if yes it should not be reentered

  	select count(*) into v_sourcetype
  	from jtf_diagnostic_group
  	where appid = P_APP and groupname = p_new_group
  	and rownum <= 1;

	-- if anything found then raise an application error since the
	-- same group cannot be added multiple times

  	if v_sourcetype <> 0 then
  		raise_application_error(-20000,
  					'Group already exist. Cannot reenter');
  	end if;

  	-- reset the old v_sourcetype value
  	v_sourcetype := 1;


  	-- Else create a new record
  	-- since the new value seems fine
  	-- but first find out the highest number of order of groups
	-- and add this to the end. If there are no groups
	-- then make sure that this gets the first order number

  	select MAX(ordernumber) into v_ordernumber
  	from jtf_diagnostic_group where appid = p_app;

  	if sql%notfound or v_ordernumber = 0 then
  		v_ordernumber := 1;
  	else v_ordernumber := v_ordernumber + 1;

  	end if;


	insert into jtf_diagnostic_group(
	SEQUENCE, GROUPNAME,
	APPID, ORDERNUMBER,
	OBJECT_VERSION_NUMBER, CREATED_BY,
	LAST_UPDATE_DATE, LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN, CREATION_DATE, SENSITIVITY)
	values(
	JTF_DIAGNOSTIC_GROUP_S.NEXTVAL, P_NEW_GROUP,
	P_APP, DECODE(v_ordernumber,null,1,v_ordernumber),
	1, P_LUBID,
	SYSDATE, P_LUBID,
	NULL, SYSDATE, P_SENSITIVITY);


  	-- Now check if the object received as the pre-req array
  	-- is not null in which case call the insertion routine

  	IF NOT P_PREREQID IS NULL then
  	  V_SOURCETYPE := 2;
	  PREREQ_INSERTION(P_NEW_GROUP, P_APP, P_PREREQID, V_SOURCETYPE);
  	end if;

  	-- commit;

  END INSERT_GROUP;

  procedure INSERT_GROUP(
  		P_NEW_GROUP IN VARCHAR2,
 		P_APP IN VARCHAR2,
		P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
		P_SENSITIVITY IN NUMBER
		) IS

  BEGIN

        INSERT_GROUP(P_NEW_GROUP,
                     P_APP,
                     P_PREREQID,
                     P_SENSITIVITY,
                     UID);

  END INSERT_GROUP;

  -- ----------------------------------------------------------------------
  -- Insert testcase to a group of an application
  -- ----------------------------------------------------------------------

  procedure GET_GROUP_SENSITIVITY(p_appid in varchar2,
				p_group_name in varchar2,
				p_sensitivity out NOCOPY number) IS

  begin
	select sensitivity into p_sensitivity
	from jtf_diagnostic_group
	where appid = p_appid and
	groupname = p_group_name;
  end GET_GROUP_SENSITIVITY;


   procedure INSERT_TESTCASE(p_testclassname in varchar2,
  			    p_group_name in varchar2,
  			    p_appid in varchar2,
  			    p_test_type in varchar2,
			    p_sensitivity in number,
                            p_valid_apps_xml in varchar2,
                            p_end_date in date default null,
                            p_meta_data in varchar2,
                            p_lubid in number) IS

	V_SOURCETYPE 	BINARY_INTEGER := 2;
  	v_ordernumber	jtf_diagnostic_test.ordernumber%TYPE;
   	l_sensitivity number;
        f_end_date date;
        f_meta_data xmltype;

  BEGIN

  	-- Check for groupname validity
  	v_sourcetype := 2;
  	CHECK_APP_OR_GROUP_VALIDITY(P_group_name, P_APPID, V_SOURCETYPE);

  	-- Check for application validity
  	v_sourcetype := 1;
  	CHECK_APP_OR_GROUP_VALIDITY(P_APPID, P_APPID, V_SOURCETYPE);

  	-- Now make sure that this testcase does not already exist in
  	-- the table. The same testcase should not exist 2 times in the
  	-- group

  	select count(*) into V_SOURCETYPE
  	from jtf_diagnostic_test
  	where  appid = p_appid and groupname = p_group_name
  	and testclassname = p_testclassname
  	and rownum <= 1;

  	if v_sourcetype > 0 then
  		raise_application_error(-20000,
  			'Testclassname already found in group and application');
  	end if;


  	-- bring the v_sourcetype back to original value
  	v_sourcetype := 1;

	-- default test sensitivity to group if not there
	if (P_SENSITIVITY is null) then
		GET_GROUP_SENSITIVITY(P_APPID,P_GROUP_NAME,L_SENSITIVITY);
	else
		l_sensitivity := P_SENSITIVITY;
	end if;

        IF P_END_DATE IS NOT NULL THEN
            --F_END_DATE := to_date(P_END_DATE, JTF_DIAGNOSTIC_ADAPTUTIL.GET_SITE_DATE_FORMAT());
	    F_END_DATE := P_END_DATE;
        END IF;

        IF P_META_DATA is not null then
            F_META_DATA := XMLTYPE(P_META_DATA);
        END IF;

  	-- if flow of control reaches here, insert the testcase
  	-- to the group
  	-- but first find out the highest number of order of tests
	-- in the group and add this to the end. If there are no tests
	-- then make sure that this gets the first order number

  	select MAX(ordernumber) into v_ordernumber
  	from jtf_diagnostic_test where appid = p_appid
  	and groupname = p_group_name;

  	if sql%notfound or v_ordernumber = 0 then
  		v_ordernumber := 1;
  	else v_ordernumber := v_ordernumber + 1;
  	end if;

	insert into jtf_diagnostic_test(
	SEQUENCE, GROUPNAME, APPID,
	ORDERNUMBER, TESTTYPE, TESTCLASSNAME,
	TOTALARGUMENTROWS,
	SENSITIVITY,
	OBJECT_VERSION_NUMBER, CREATED_BY,
	LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	CREATION_DATE,VALID_APPLICATIONS,END_DATE,TEST_METADATA)
	values(
	JTF_DIAGNOSTIC_TEST_S.NEXTVAL, p_group_name, p_appid,
	decode(v_ordernumber, null, 1, v_ordernumber),
	p_test_type, p_testclassname,
	0, l_sensitivity, 1, p_lubid,
	SYSDATE, p_lubid, NULL,
	SYSDATE,xmltype(p_valid_apps_xml),F_END_DATE,F_META_DATA);

	-- commit;

  END INSERT_TESTCASE;

  -- deprecated, please use procedure above
  procedure INSERT_TESTCASE(p_testclassname in varchar2,
                            p_group_name in varchar2,
                            p_appid in varchar2,
                            p_test_type in varchar2,
                            p_lubid in number) IS

  BEGIN

	        INSERT_TESTCASE(p_testclassname,
                        p_group_name,
                        p_appid,
                        p_test_type,
			null,null,null,null,
			p_lubid);

  END INSERT_TESTCASE;

  -- deprecated, please use procedure above
  procedure INSERT_TESTCASE(p_testclassname in varchar2,
  			    p_group_name in varchar2,
  			    p_appid in varchar2,
  			    p_test_type in varchar2) IS

  BEGIN

        INSERT_TESTCASE(p_testclassname,
                        p_group_name,
                        p_appid,
                        p_test_type,
                        UID);

  END INSERT_TESTCASE;

  -- ----------------------------------------------------------------------
  -- Insert argument values for a testcase but one row only
  -- ----------------------------------------------------------------------


  procedure INSERT_ARGVALUE_ROW(p_appid in varchar2,
  				p_group_name in varchar2,
  				p_test_class_name in varchar2,
  				p_arg_names in jtf_varchar2_table_4000,
  				p_arg_values in jtf_varchar2_table_4000,
                                p_lubid in number) IS

  	V_SOURCETYPE 	BINARY_INTEGER := 1;
  	v_rownumber	jtf_diagnostic_arg.rownumber%TYPE;
  	v_valsetnumber	jtf_diagnostic_arg.valuesetnumber%TYPE;

  BEGIN
  	-- first check if the application is valid

  	v_sourcetype := 1;
  	CHECK_APP_OR_GROUP_VALIDITY(P_APPID, P_APPID, V_SOURCETYPE);

  	-- check for groupname validity

  	v_sourcetype := 2;
  	CHECK_APP_OR_GROUP_VALIDITY(P_group_name, P_APPID, V_SOURCETYPE);

	-- then check if the testclassname is valid

	select count(*) into v_sourcetype
	from jtf_diagnostic_test where appid = p_appid
	and groupname = p_group_name
	and testclassname = p_test_class_name
	and rownum <= 1;

	-- making sure that the error only gets thrown incase
	-- its not a valid test name and also not a declarative
	-- test that contains a step that is a diagnostic test

	if v_sourcetype <> 1 and instr(p_test_class_name, '{-STEP/CLASS-}') <= 0 then
		raise_application_error(-20000, 'Invalid testclassname received:' || p_test_class_name);
	end if;

	-- then get the max row number and increment it by 1
	-- max row number is for this testclassname only

	select max(rownumber) into v_rownumber
	from jtf_diagnostic_arg where testclassname = p_test_class_name
	and groupname = p_group_name and appid = p_appid;

  	if sql%notfound or v_rownumber = 0 then
  		v_rownumber := 1;
  	else v_rownumber := v_rownumber + 1;
  	end if;

	-- now get the max valuesetnumber and increment it by 1

	select JTF_DIAGNOSTIC_ARG_VAL_SET_S.nextval
	into v_valsetnumber from dual;

	-- select max(valuesetnumber) into v_valsetnumber
	-- from jtf_diagnostic_arg;

  	-- if sql%notfound or v_valsetnumber = 0 then
  	--	v_valsetnumber := 1;
  	-- else v_valsetnumber := v_valsetnumber + 1;
  	-- end if;

	-- insert the name-value pair one by one
	V_SOURCETYPE := 1;
	loop
		if p_arg_names.exists(v_sourcetype) then

			insert into jtf_diagnostic_arg(
			SEQUENCE, TESTCLASSNAME, GROUPNAME,
			APPID, ARGNAME, ARGVALUE,
			ROWNUMBER,  VALUESETNUMBER,  OBJECT_VERSION_NUMBER,
			CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN, CREATION_DATE)
			values(
			JTF_DIAGNOSTIC_ARG_S.NEXTVAL, p_test_class_name, p_group_name,
			p_appid, p_arg_names(v_sourcetype), p_arg_values(v_sourcetype),
			decode(v_rownumber, null, 1, v_rownumber), v_valsetnumber, 1,
			p_lubid, SYSDATE, p_lubid,
			NULL, SYSDATE);

			v_sourcetype := v_sourcetype + 1;
		else
		  exit;
		end if;
	end loop;

	-- commit;

  END INSERT_ARGVALUE_ROW;

  procedure INSERT_ARGVALUE_ROW(p_appid in varchar2,
  				p_group_name in varchar2,
  				p_test_class_name in varchar2,
  				p_arg_names in jtf_varchar2_table_4000,
  				p_arg_values in jtf_varchar2_table_4000
                               ) IS

  BEGIN

        INSERT_ARGVALUE_ROW(P_APPID,
                            P_GROUP_NAME,
                            P_TEST_CLASS_NAME,
                            P_ARG_NAMES,
                            P_ARG_VALUES,
                            UID);

  END INSERT_ARGVALUE_ROW;

  ---------------------------------------------------------------------------
  -- Checks if a group or application is valid. If application, it should
  -- be registered with the diagnostic framework. If group then it should be
  -- registered within the application
  ---------------------------------------------------------------------------

  procedure CHECK_APP_OR_GROUP_VALIDITY(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_SOURCETYPE IN NUMBER) IS

    v_data_found 	BINARY_INTEGER := 0;

  BEGIN

    	-- if application, then is the application
    	-- registered in the jtf_diagnostic_app table
    	-- if group, then is the group part of the application

    	if p_sourcetype = 1 then
    		select count(*) into v_data_found  from jtf_diagnostic_app
    		where appid = p_sourceid;
    	elsif p_sourcetype = 2 then
    		select count(*) into v_data_found  from jtf_diagnostic_group
    		where appid = p_sourceappid and
    		groupname = p_sourceid;
    	else
    		raise_application_error(-20000, 'Invalid data type received');
    	end if;

    	if v_data_found = 0 then
    		raise_application_error(-20000,
    			'Could not find the group or application as registered');
    	end if;

  END CHECK_APP_OR_GROUP_VALIDITY;


  ---------------------------------------------------------------------------
  -- Inserts array of applications or groups into the database but makes
  -- sure that the application or group does not prereq itself and is
  -- registered (application with the framework and group with the application)
  ---------------------------------------------------------------------------

  procedure PREREQ_INSERTION(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_SOURCETYPE IN NUMBER,
                P_LUBID IN NUMBER) IS

    v_index 		BINARY_INTEGER := 1;
    v_data_found 	BINARY_INTEGER := 1;

  BEGIN

  	if P_SOURCEID = 'SYSTEM_TESTS' then
  		raise_application_error(-20000, 'HTML Platform cannot have any prereqs');
  	end if;

    	LOOP
	  IF P_PREREQID.EXISTS(v_index) THEN

	  	-- a group or application cannot prereq itself
	  	-- the following checks for that

	  	if P_SOURCEID = P_PREREQID(v_index) then
	  		raise_application_error(-20000, 'Entity Cant prereq itself');
	  	end if;

		-- the following checks if the data to be inserted
		-- is a valid group in the same application or
		-- a valid application registered in the diagnostic
		-- framework

	  	if P_SOURCETYPE = 1 then
	  		select sequence into v_data_found  from jtf_diagnostic_app
	  		where appid = P_PREREQID(v_index)
	  		and rownum <= 1;
	  	elsif p_sourcetype = 2 then
	  		select sequence into v_data_found  from jtf_diagnostic_group
	  		where groupname = P_PREREQID(v_index)
	  		and appid = p_sourceappid
	  		and rownum <= 1;

	  	end if;

		IF SQL%NOTFOUND THEN
	  		RAISE_APPLICATION_ERROR(-20000,
	  			'Group / Application supplied as prereq is not valid');
		END IF;


		-- if reached this far, great. the record is valid and
		-- we can insert the record in the table
		-- need to complete the insert statement

		insert into jtf_diagnostic_prereq
		(SEQUENCE, SOURCEID, PREREQID,
		SOURCEAPPID, TYPE, OBJECT_VERSION_NUMBER,
		CREATED_BY, LAST_UPDATE_DATE,
		LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATION_DATE)
		values
		(JTF_DIAGNOSTIC_PREREQ_S.NEXTVAL, P_SOURCEID,
		P_PREREQID(v_index), P_SOURCEAPPID, P_SOURCETYPE,
		1, P_LUBID, SYSDATE, P_LUBID,
		P_LUBID, SYSDATE);

		--increment the counter

	        v_index := v_index + 1;
	  ELSE
	    EXIT;
          END IF;
        END LOOP;

        -- commit;

   END PREREQ_INSERTION;

   -- deprecated, please use procedure above
   procedure PREREQ_INSERTION(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_SOURCETYPE IN NUMBER) IS

   BEGIN

         PREREQ_INSERTION(P_SOURCEID,
                          P_SOURCEAPPID,
                          P_PREREQID,
                          P_SOURCETYPE,
                          UID);

   END PREREQ_INSERTION;

  ---------------------------------------------------------------------------
  -- Rename a group within an application. This procedure makes sure that the
  -- new group name does not clash with another name in the same application
  ---------------------------------------------------------------------------

  procedure RENAME_GROUP(
                P_APPID IN VARCHAR2,
                P_GROUPNAME IN VARCHAR2,
                P_NEWGROUPNAME IN VARCHAR2,
                P_LUBID IN NUMBER) IS

	  v_data_found 	BINARY_INTEGER := 0;

  BEGIN

  	select count(*) into v_data_found
  	from jtf_diagnostic_group
  	where appid = p_appid
  	and groupname = p_groupname;

  	if v_data_found = 0 or sql%notfound then
  		raise_application_error(-20000, 'Invalid current group name provided');
  	end if;

  	-- proceed only if the old and the new
  	-- group names are not the same

	if p_groupname <> p_newgroupname then

  		-- if flow of control reaches here there is a valid
	  	-- group. Now make sure there already isnt a group existing in the
  		-- application. Should not be.

	  	-- put an invalid value into
  		-- v_data_found

	  	v_data_found := 1;

  		select count(*) into v_data_found
	  	from jtf_diagnostic_group
  		where appid = p_appid
	  	and groupname = p_newgroupname;

  		if v_data_found > 0 then
  			raise_application_error(-20000,
  			'New group name invalid -- name already taken');
  		end if;


  		-- if flow of control reaches here, it is alright to
  		-- rename the group across jtf_diagnostic_group,
	  	-- jtf_diagnostic_test, jtf_diagnostic_arg, jtf_diagnostic_prereq


	  	update jtf_diagnostic_group
  		set groupname = p_newgroupname,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
  		where groupname = p_groupname
  		and appid = p_appid;

  		update jtf_diagnostic_test
  		set groupname = p_newgroupname,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
  		where groupname = p_groupname
  		and appid = p_appid;

  		update jtf_diagnostic_arg
  		set groupname = p_newgroupname,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
  		where groupname = p_groupname
	  	and appid = p_appid;

  		-- rename the sourceid and
  		-- the prereqid

	  	update jtf_diagnostic_prereq
  		set sourceid = p_newgroupname,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
  		where sourceid = p_groupname
	  	and sourceappid = p_appid;

  		update jtf_diagnostic_prereq
  		set prereqid = p_newgroupname,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
  		where prereqid = p_groupname
	  	and sourceappid = p_appid;

  		update jtf_diagnostic_decl_test_steps
  		set groupname = p_newgroupname,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
  		where groupname = p_groupname
  		and appid = p_appid;

  		update jtf_diagnostic_decl_step_cols
  		set groupname = p_newgroupname,
		OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
		LAST_UPDATE_DATE = SYSDATE,
		LAST_UPDATED_BY = P_LUBID
  		where groupname = p_groupname
  		and appid = p_appid;

	end if;


  END RENAME_GROUP;

  -- deprecated, please use procedure above
  procedure RENAME_GROUP(
                P_APPID IN VARCHAR2,
                P_GROUPNAME IN VARCHAR2,
                P_NEWGROUPNAME IN VARCHAR2) IS

  BEGIN

        RENAME_GROUP(P_APPID,
                     P_GROUPNAME,
                     P_NEWGROUPNAME,
                     UID);

  END RENAME_GROUP;

  ---------------------------------------------------------------------------
  -- Upload an application row from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_APP(
		P_APPID 	IN VARCHAR2,
     		P_LUDATE 	IN VARCHAR2,
		P_SEC_GRP_ID	IN VARCHAR2,
		P_CUST_MODE	IN VARCHAR2,
		P_OWNER 	IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db

  BEGIN

         -- Translate owner to file_last_updated_by
         -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(p_ludate, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_app
         	where 	appid = p_appid;

       		-- Update record only as per standard

                -- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
               /* if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update	jtf_diagnostic_app
                set 	last_updated_by = f_luby,
                        last_update_date = f_ludate,
                        object_version_number = object_version_number + 1,
                        security_group_id = to_number(P_SEC_GRP_ID)
                where	appid = p_appid;

         	--end if;

  		exception

          		when no_data_found then
            		-- Record doesn't exist - insert in all cases

            			insert into jtf_diagnostic_app(
            				sequence,
            				appid,
            				object_version_number,
            				created_by,
            				last_update_date,
            				last_updated_by,
            				last_update_login,
            				creation_date,
            				security_group_id)
            			values(
            				jtf_diagnostic_app_s.nextval,
            				p_appid,
            				1,
            				f_luby,
            				f_ludate,
            				f_luby,
            				null,
            				f_ludate,
            				to_number(P_SEC_GRP_ID));

         end;

  END LOAD_ROW_APP;


  ---------------------------------------------------------------------------
  -- Upload an application group row from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_GROUP(
     		P_APPID 	IN VARCHAR2,
     		P_GROUPNAME	IN VARCHAR2,
     		P_SENSITIVITY	IN VARCHAR2,
     		P_LUDATE 	IN VARCHAR2,
		P_SEC_GRP_ID	IN VARCHAR2,
		P_CUST_MODE	IN VARCHAR2,
     		P_OWNER 	IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db
        v_num		number;		-- temporary variable
        v_sensitivity	number;		-- temp variable for sensitivity

  BEGIN

  	v_sensitivity := to_number(nvl(P_SENSITIVITY, '1'));

         -- Translate owner to file_last_updated_by

         -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(p_ludate, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_group
         	where 	appid = p_appid and
         		groupname = p_groupname;

       		-- Update record only as per standard

                -- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
                /*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update	jtf_diagnostic_group
                set 	sensitivity = v_sensitivity,
                        last_updated_by = f_luby,
                        last_update_date = f_ludate,
                        object_version_number = object_version_number + 1,
                        security_group_id = to_number(P_SEC_GRP_ID)
                where	appid = p_appid and groupname = p_groupname;

         	--end if;

  		exception

          		when no_data_found then
            		-- Record doesn't exist - insert in all cases

            			select nvl(max(ordernumber)+1,1) into v_num
            			from jtf_diagnostic_group where
            			appid = p_appid;

            			insert into jtf_diagnostic_group(
            				sequence,
            				groupname,
            				appid,
					sensitivity,
            				ordernumber,
            				object_version_number,
            				created_by,
            				last_update_date,
            				last_update_login,
            				last_updated_by,
            				creation_date,
            				security_group_id)
            			values(
            				jtf_diagnostic_group_s.nextval,
            				p_groupname,
            				p_appid,
					v_sensitivity,
            				v_num,
            				1,
            				f_luby,
            				f_ludate,
            				null,
            				f_luby,
            				f_ludate,
            				to_number(P_SEC_GRP_ID));

         end;

  END LOAD_ROW_GROUP;


 ---------------------------------------------------------------------------
  -- Upload an application group test row from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_TEST(
     		P_APPID 		IN VARCHAR2,
     		P_GROUPNAME		IN VARCHAR2,
     		P_TESTCLASSNAME		IN VARCHAR2,
     		P_TESTTYPE		IN VARCHAR2,
     		P_TOTALARGUMENTROWS	IN VARCHAR2,
                P_SENSITIVITY           IN VARCHAR2,
     		P_LUDATE 		IN VARCHAR2,
		P_SEC_GRP_ID		IN VARCHAR2,
		P_CUST_MODE		IN VARCHAR2,
                P_VALID_APPLICATIONS    IN CLOB,
                P_END_DATE              IN VARCHAR2,
                P_META_DATA             IN VARCHAR2,
     		P_OWNER 		IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db
        v_num		number;		-- temporary variable
	v_product	varchar2(50);
	v_filename	varchar2(500);
        c_product	varchar2(50);
        c_testclassname varchar2(1500);
	DOINSERT	boolean;
	l_sensitivity number;
        f_end_date date;
        f_meta_data xmltype;

  cursor C_GET_PROD_NAMES (l_appid varchar2,
			   l_groupname varchar2,
			   l_filename varchar2,
			   l_testclassname varchar2) is
    	select substr(TESTCLASSNAME,
                        instr(TESTCLASSNAME,'.',1,2)+1,
                        instr(TESTCLASSNAME,'.',1,3) -
                                instr(TESTCLASSNAME,'.',1,2) - 1),
		testclassname
	from JTF_DIAGNOSTIC_TEST
	where GROUPNAME = l_groupname
	and   APPID = l_appid
        and   testclassname <> l_testclassname
	and   substr(TESTCLASSNAME,
                        instr(TESTCLASSNAME,'.',-1,1)+1)
		= l_filename;

  BEGIN

         -- Translate owner to file_last_updated_by

	 -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

	 f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(p_ludate, 'YYYY/MM/DD'), sysdate);

         if p_end_date is not null then
            f_end_date := to_date(p_end_date, 'YYYY/MM/DD');
         end if;
         IF P_META_DATA is not null then
            F_META_DATA := XMLTYPE(P_META_DATA);
         END IF;

	 if (p_sensitivity is null) then
		GET_GROUP_SENSITIVITY(p_appid,p_groupname,
				l_sensitivity);
	else
		l_sensitivity := p_sensitivity;
	 end if;

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_test
         	where 	appid = p_appid and
         		groupname = p_groupname
         		and testclassname = p_testclassname;

       		-- Update record only as per standard

		-- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
		/*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake

                -- if valid_applications is not null, insert valid_applications in to table
                -- else ignore the valid_applications while inserting
                if P_VALID_APPLICATIONS is not null and P_VALID_APPLICATIONS <> empty_clob() then
                    update  jtf_diagnostic_test
                    set     last_updated_by = f_luby,
                            last_update_date = sysdate,--f_ludate,
                            object_version_number = object_version_number + 1,
                            TOTALARGUMENTROWS = p_TOTALARGUMENTROWS,
                            TESTTYPE = p_TESTTYPE,
                            sensitivity = l_sensitivity,
                            security_group_id = to_number(P_SEC_GRP_ID),
                            valid_applications = xmltype(P_VALID_APPLICATIONS),
                            end_date = f_end_date,
                            test_metadata = f_meta_data
                    where   appid = p_appid and groupname = p_groupname
                            and testclassname = p_testclassname;
                else

                    update  jtf_diagnostic_test
                    set     last_updated_by = f_luby,
                            last_update_date = sysdate,--f_ludate,
                            object_version_number = object_version_number + 1,
                            TOTALARGUMENTROWS = p_TOTALARGUMENTROWS,
                            TESTTYPE = p_TESTTYPE,
                            sensitivity = l_sensitivity,
                            security_group_id = to_number(P_SEC_GRP_ID),
                            end_date = f_end_date,
                            test_metadata = f_meta_data
                    where   appid = p_appid and groupname = p_groupname
                            and testclassname = p_testclassname;

               	end if;
                -- end if

  		exception

          		when no_data_found then
            		-- Record doesn't exist

            		   DOINSERT := TRUE;

			   -- For java test make sure izu test doesn't also
			   -- exist and if it does delete it, if we are
			   -- uploading izu java test and test exists in
			   -- another product don't upload.
 			   if (instr(P_TESTTYPE,5) <> 0) then
				PARSE_TESTCLASSNAME(P_TESTCLASSNAME,
						    V_PRODUCT,
						    V_FILENAME);
				open C_GET_PROD_NAMES(p_appid,
						      p_groupname,
						      V_FILENAME,
					  	      P_TESTCLASSNAME);
				loop
					fetch C_GET_PROD_NAMES into c_product,c_testclassname;
					exit when C_GET_PROD_NAMES%notfound;
					if c_product = 'izu' then
						DELETE_TEST(p_appid,
							    p_groupname,
						  	    c_testclassname);
					elsif V_PRODUCT = 'izu' and
						c_product <> 'izu' then
						DOINSERT := FALSE;
					end if;
				end loop;
				close C_GET_PROD_NAMES;
			   end if;

			   if DOINSERT then
                                --6599133
                                select MAX(ordernumber) into v_num
                                from jtf_diagnostic_test where appid = p_appid
                                and groupname = p_groupname;

                                if sql%notfound or v_num = 0 or v_num is null then
                                  v_num := 1;
                                else v_num := v_num + 1;
                                end if;

                                 -- if valid_applications is not null, insert valid_applications in to table
                                 -- else ignore the valid_applications while inserting
	                     if P_VALID_APPLICATIONS is not null and P_VALID_APPLICATIONS <> empty_clob() then
                                        insert into jtf_diagnostic_test(
                                                SEQUENCE,
                                                GROUPNAME,
                                                APPID,
                                                ORDERNUMBER,
                                                TESTTYPE,
                                                TESTCLASSNAME,
                                                TOTALARGUMENTROWS,
                                                SENSITIVITY,
                                                OBJECT_VERSION_NUMBER,
                                                CREATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY,
                                                LAST_UPDATE_LOGIN,
                                                CREATION_DATE,
                                                security_group_id,
                                                valid_applications,
                                                end_date,
                                                test_metadata)
                                        values(
                                                jtf_diagnostic_test_s.nextval,
                                                p_groupname,
                                                p_appid,
                                                v_num,
                                                p_testtype,
                                                p_testclassname,
                                                p_totalargumentrows,
                                                l_sensitivity,
                                                1,
                                                f_luby,
                                                f_ludate,
                                                f_luby,
                                                null,
                                                f_ludate,
                                                to_number(P_SEC_GRP_ID),
                                                xmltype(P_VALID_APPLICATIONS),
                                                f_end_date,
                                                f_meta_data);
                                    else
                                        insert into jtf_diagnostic_test(
                                                SEQUENCE,
                                                GROUPNAME,
                                                APPID,
                                                ORDERNUMBER,
                                                TESTTYPE,
                                                TESTCLASSNAME,
                                                TOTALARGUMENTROWS,
                                                SENSITIVITY,
                                                OBJECT_VERSION_NUMBER,
                                                CREATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATED_BY,
                                                LAST_UPDATE_LOGIN,
                                                CREATION_DATE,
                                                security_group_id,
                                                end_date,
                                                test_metadata)
                                        values(
                                                jtf_diagnostic_test_s.nextval,
                                                p_groupname,
                                                p_appid,
                                                v_num,
                                                p_testtype,
                                                p_testclassname,
                                                p_totalargumentrows,
                                                l_sensitivity,
                                                1,
                                                f_luby,
                                                f_ludate,
                                                f_luby,
                                                null,
                                                f_ludate,
                                                to_number(P_SEC_GRP_ID),
                                                f_end_date,
                                                f_meta_data);
                                    end if;
			   end if;
         end;

  END LOAD_ROW_TEST;


  ---------------------------------------------------------------------------
  -- Upload arguments of a testcase from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_ARG(
     		P_APPID 		IN VARCHAR2,
     		P_GROUPNAME		IN VARCHAR2,
     		P_TESTCLASSNAME		IN VARCHAR2,
     		P_ARGNAME		IN VARCHAR2,
     		P_ROWNUMBER		IN VARCHAR2,
     		P_ARGVALUE		IN VARCHAR2,
     		P_VALUESETNUMBER	IN VARCHAR2,
     		P_LUDATE 		IN VARCHAR2,
		P_SEC_GRP_ID		IN VARCHAR2,
		P_CUST_MODE		IN VARCHAR2,
     		P_OWNER 		IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db
        v_num		number;		-- temporary variable

  BEGIN

         -- Translate owner to file_last_updated_by

         -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(p_ludate, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_arg
         	where 	appid = p_appid
         		and groupname = p_groupname
         		and testclassname = p_testclassname
         		and argname = p_argname
         		and rownumber = p_rownumber;

       		-- Update record only as per standard

                -- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
                /*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update	jtf_diagnostic_arg
                set 	last_updated_by = f_luby,
                        argvalue = p_argvalue,
                        VALUESETNUMBER = p_VALUESETNUMBER,
                        last_update_date = f_ludate,
                        object_version_number = object_version_number + 1,
                        security_group_id = to_number(P_SEC_GRP_ID)
                where 	appid = p_appid
                        and groupname = p_groupname
                        and testclassname = p_testclassname
                        and argname = p_argname
                        and rownumber = p_rownumber;
         	--end if;

  		exception

          		when no_data_found then
            		-- Record doesn't exist - insert in all cases

           		insert into jtf_diagnostic_arg(
           			SEQUENCE,
           			TESTCLASSNAME,
           			GROUPNAME,
           			APPID,
           			ARGNAME,
           			ARGVALUE,
           			ROWNUMBER,
           			VALUESETNUMBER,
           			OBJECT_VERSION_NUMBER,
           			CREATED_BY,
           			LAST_UPDATE_DATE,
           			LAST_UPDATED_BY,
           			LAST_UPDATE_LOGIN,
           			CREATION_DATE,
           			SECURITY_GROUP_ID)
           		values(
           			jtf_diagnostic_arg_s.nextval,
           			p_testclassname,
           			p_groupname,
           			p_appid,
           			p_argname,
           			p_argvalue,
           			p_rownumber,
           			p_valuesetnumber,
           			1,
           			f_luby,
           			f_ludate,
           			f_luby,
           			null,
           			f_ludate,
           			to_number(P_SEC_GRP_ID));


         end;

  END LOAD_ROW_ARG;


  ---------------------------------------------------------------------------
  -- Upload application or group prerequisites from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_PREREQ(
     		P_SOURCEID 	IN VARCHAR2,
     		P_PREREQID	IN VARCHAR2,
     		P_SOURCEAPPID	IN VARCHAR2,
     		P_TYPE		IN VARCHAR2,
     		P_LUDATE 	IN VARCHAR2,
		P_SEC_GRP_ID	IN VARCHAR2,
		P_CUST_MODE	IN VARCHAR2,
     		P_OWNER 	IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db
        v_num		number;		-- temporary variable

  BEGIN

         -- Translate owner to file_last_updated_by
         -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(p_ludate, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_prereq
         	where 	sourceid = p_sourceid
         		and prereqid = p_prereqid
         		and SOURCEAPPID = p_SOURCEAPPID
         		and type = p_type;

       		-- Update record only as per standard

                -- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
                /*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update	jtf_diagnostic_prereq
                set 	last_updated_by = f_luby,
                        last_update_date = f_ludate,
                        object_version_number = object_version_number + 1,
                        security_group_id = to_number(P_SEC_GRP_ID)
                where 	sourceid = p_sourceid
                        and prereqid = p_prereqid
                        and SOURCEAPPID = p_SOURCEAPPID
                        and type = p_type;

         	--end if;

  		exception

          		when no_data_found then
            		-- Record doesn't exist - insert in all cases

			insert into jtf_diagnostic_prereq(
				SEQUENCE,
				SOURCEID,
				PREREQID,
				SOURCEAPPID,
				TYPE,
				OBJECT_VERSION_NUMBER,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				CREATION_DATE,
				SECURITY_GROUP_ID)
			values(
				jtf_diagnostic_prereq_s.nextval,
				p_sourceid,
				p_prereqid,
				p_sourceappid,
				p_type,
				1,
				f_luby,
				f_ludate,
				f_luby,
				null,
				f_ludate,
				to_number(P_SEC_GRP_ID));

         end;

  END LOAD_ROW_PREREQ;


  PROCEDURE LOAD_ROW_TEST_STEPS(
		P_APPID 		IN VARCHAR2,
		P_GROUPNAME 		IN VARCHAR2,
		P_TESTCLASSNAME		IN VARCHAR2,
		P_TESTSTEPNAME		IN VARCHAR2,
		P_EXECUTION_SEQUENCE	IN VARCHAR2,
		P_STEP_TYPE		IN VARCHAR2,
		P_STEP_DESCRIPTION	IN VARCHAR2,
		P_ERROR_TYPE		IN VARCHAR2,
		P_ERROR_MESSAGE		IN VARCHAR2,
		P_FIX_INFO		IN VARCHAR2,
		P_MULTI_ORG		IN VARCHAR2,
		P_TABLE_VIEW_NAME	IN VARCHAR2,
		P_WHERE_CLAUSE_OR_SQL	IN VARCHAR2,
		P_PROFILE_NAME		IN VARCHAR2,
		P_PROFILE_VALUE		IN VARCHAR2,
		P_LOGICAL_OPERATOR	IN VARCHAR2,
		P_FUNCTION_NAME		IN VARCHAR2,
		P_VALIDATION_VAL1	IN VARCHAR2,
		P_VALIDATION_VAL2	IN VARCHAR2,
		P_LAST_UPDATE_DATE	IN VARCHAR2,
		P_SECURITY_GROUP_ID	IN VARCHAR2,
		P_CUST_MODE		IN VARCHAR2,
		P_OWNER			IN VARCHAR2) IS

        f_luby    			number;  	-- entity owner in file
        f_ludate  			date;    	-- entity update date in file
        db_luby   			number;  	-- entity owner in db
        db_ludate 			date;  		-- entity update date in db
        v_num				number;		-- temporary variable
        v_EXECUTION_SEQUENCE 		number;		-- temporary variable

  BEGIN

         -- Translate owner to file_last_updated_by

         -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	JTF_DIAGNOSTIC_DECL_TEST_STEPS
         	where 	APPID = P_APPID
         		and GROUPNAME = P_GROUPNAME
         		and TESTCLASSNAME = P_TESTCLASSNAME
         		and TESTSTEPNAME = P_TESTSTEPNAME;

       		-- Update record only as per standard

                -- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
                /*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update	JTF_DIAGNOSTIC_DECL_TEST_STEPS
                set 	last_updated_by = f_luby,
                        last_update_date = f_ludate,
                        object_version_number = object_version_number + 1,
                        security_group_id = to_number(P_SECURITY_GROUP_ID),
                        STEP_TYPE = P_STEP_TYPE,
                        STEP_DESCRIPTION = P_STEP_DESCRIPTION,
                        ERROR_TYPE = P_ERROR_TYPE,
                        ERROR_MESSAGE = P_ERROR_MESSAGE,
                        FIX_INFO = P_FIX_INFO,
                        MULTI_ORG = P_MULTI_ORG,
                        TABLE_VIEW_NAME = P_TABLE_VIEW_NAME,
                        WHERE_CLAUSE_OR_SQL = P_WHERE_CLAUSE_OR_SQL,
                        PROFILE_NAME = P_PROFILE_NAME,
                        PROFILE_VALUE = P_PROFILE_VALUE,
                        LOGICAL_OPERATOR = P_LOGICAL_OPERATOR,
                        FUNCTION_NAME = P_FUNCTION_NAME,
                        VALIDATION_VAL1 = P_VALIDATION_VAL1,
                        VALIDATION_VAL2 = P_VALIDATION_VAL2
                where 	APPID = P_APPID
                        and GROUPNAME = P_GROUPNAME
                        and TESTCLASSNAME = P_TESTCLASSNAME
                        and TESTSTEPNAME = P_TESTSTEPNAME;

         	--end if;

  		exception

          		when no_data_found then
            		-- Record doesn't exist - insert in all cases

      		  	select MAX(EXECUTION_SEQUENCE) into v_EXECUTION_SEQUENCE
		  	from JTF_DIAGNOSTIC_DECL_TEST_STEPS
  	         	where 	APPID = P_APPID
         		and GROUPNAME = P_GROUPNAME
         		and TESTCLASSNAME = P_TESTCLASSNAME;

		  	if sql%notfound or v_EXECUTION_SEQUENCE = 0 then
		  		v_EXECUTION_SEQUENCE := 1;
		  	else v_EXECUTION_SEQUENCE := v_EXECUTION_SEQUENCE + 1;
		  	end if;

			insert into JTF_DIAGNOSTIC_DECL_TEST_STEPS(
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
				PROFILE_NAME,
				PROFILE_VALUE,
				LOGICAL_OPERATOR,
				FUNCTION_NAME,
				VALIDATION_VAL1,
				VALIDATION_VAL2,
				OBJECT_VERSION_NUMBER,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				CREATION_DATE,
				SECURITY_GROUP_ID)
			values(
				P_APPID,
				P_GROUPNAME,
				P_TESTCLASSNAME,
				P_TESTSTEPNAME,
				v_EXECUTION_SEQUENCE,
				P_STEP_TYPE,
				P_STEP_DESCRIPTION,
				P_ERROR_TYPE,
				P_ERROR_MESSAGE,
				P_FIX_INFO,
				P_MULTI_ORG,
				P_TABLE_VIEW_NAME,
				P_WHERE_CLAUSE_OR_SQL,
				P_PROFILE_NAME,
				P_PROFILE_VALUE,
				P_LOGICAL_OPERATOR,
				P_FUNCTION_NAME,
				P_VALIDATION_VAL1,
				P_VALIDATION_VAL2,
				1,
				f_luby,
				f_ludate,
				f_luby,
				null,
				f_ludate,
				to_number(P_SECURITY_GROUP_ID));

         end;
  END LOAD_ROW_TEST_STEPS;



  PROCEDURE LOAD_ROW_STEP_COLS(
		P_APPID 		IN VARCHAR2,
		P_GROUPNAME 		IN VARCHAR2,
		P_TESTCLASSNAME		IN VARCHAR2,
		P_TESTSTEPNAME		IN VARCHAR2,
		P_COLUMN_NAME		IN VARCHAR2,
		P_LOGICAL_OPERATOR	IN VARCHAR2,
		P_VALIDATION_VAL1	IN VARCHAR2,
		P_VALIDATION_VAL2	IN VARCHAR2,
		P_LAST_UPDATE_DATE	IN VARCHAR2,
		P_SECURITY_GROUP_ID	IN VARCHAR2,
		P_CUST_MODE		IN VARCHAR2,
		P_OWNER			IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db
        v_num		number;		-- temporary variable

  BEGIN

         -- Translate owner to file_last_updated_by

         -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_decl_step_cols
         	where 	APPID = P_APPID
         		and GROUPNAME = P_GROUPNAME
         		and TESTCLASSNAME = P_TESTCLASSNAME
         		and TESTSTEPNAME = P_TESTSTEPNAME
         		and COLUMN_NAME = P_COLUMN_NAME;

       		-- Update record only as per standard

                -- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
                /*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update	jtf_diagnostic_decl_step_cols
                set 	last_updated_by = f_luby,
                        last_update_date = f_ludate,
                        object_version_number = object_version_number + 1,
                        security_group_id = to_number(P_SECURITY_GROUP_ID),
                        LOGICAL_OPERATOR = P_LOGICAL_OPERATOR,
                        VALIDATION_VAL1 = P_VALIDATION_VAL1,
                        VALIDATION_VAL2 = P_VALIDATION_VAL2
                where 	APPID = P_APPID
                        and GROUPNAME = P_GROUPNAME
                        and TESTCLASSNAME = P_TESTCLASSNAME
                        and TESTSTEPNAME = P_TESTSTEPNAME
                        and COLUMN_NAME = P_COLUMN_NAME;

         	--end if;

  		exception

          		when no_data_found then
            		-- Record doesn't exist - insert in all cases

			insert into jtf_diagnostic_decl_step_cols(
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
				SECURITY_GROUP_ID)
			values(
				P_APPID,
				P_GROUPNAME,
				P_TESTCLASSNAME,
				P_TESTSTEPNAME,
				P_COLUMN_NAME,
				P_LOGICAL_OPERATOR,
				P_VALIDATION_VAL1,
				P_VALIDATION_VAL2,
				1,
				f_luby,
				f_ludate,
				f_luby,
				null,
				f_ludate,
				to_number(P_SECURITY_GROUP_ID));

         end;

  END LOAD_ROW_STEP_COLS;


 ---------------------------------------------------------------------------
  -- Upload a test alert information row from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_ALERT(
     		P_APPID 		IN VARCHAR2,
     		P_GROUPNAME		IN VARCHAR2,
     		P_TESTCLASSNAME		IN VARCHAR2,
     		P_TYPE			IN VARCHAR2,
     		P_LEVEL_VALUE		IN VARCHAR2,
     		P_LUDATE 		IN VARCHAR2,
		P_SEC_GRP_ID		IN VARCHAR2,
		P_CUST_MODE		IN VARCHAR2,
     		P_OWNER 		IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db
        v_num		number;		-- temporary variable

  BEGIN

         -- Translate owner to file_last_updated_by

         -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(p_ludate, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_alert
         	where 	appid = p_appid and
         		groupname = p_groupname
         		and testclassname = p_testclassname
			and type = p_type;

       		-- Update record only as per standard

                -- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
                /*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update	jtf_diagnostic_alert
                set 	last_updated_by = f_luby,
                        last_update_date = f_ludate,
                        object_version_number = object_version_number + 1,
                        LEVEL_VALUE = to_number(p_LEVEL_VALUE),
                        security_group_id = to_number(P_SEC_GRP_ID)
                where	appid = p_appid and groupname = p_groupname
                        and testclassname = p_testclassname
                        and type = p_type;

         	--end if;

  		exception

          		when no_data_found then
            		-- Record doesn't exist - insert in all cases

            			insert into jtf_diagnostic_alert(
            				SEQUENCE,
            				GROUPNAME,
            				APPID,
            				TYPE,
            				TESTCLASSNAME,
            				LEVEL_VALUE,
            				OBJECT_VERSION_NUMBER,
            				CREATED_BY,
            				LAST_UPDATE_DATE,
            				LAST_UPDATED_BY,
            				LAST_UPDATE_LOGIN,
            				CREATION_DATE,
            				security_group_id)
            			values(
            				jtf_diagnostic_alert_s.nextval,
            				p_groupname,
            				p_appid,
            				p_type,
            				p_testclassname,
            				to_number(p_level_value),
            				1,
            				f_luby,
            				f_ludate,
            				f_luby,
            				null,
            				f_ludate,
            				to_number(P_SEC_GRP_ID));
         end;

  END LOAD_ROW_ALERT;


 ---------------------------------------------------------------------------
  -- Upload a knowledge base information row from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_KB(
     		P_APPID 		IN VARCHAR2,
     		P_GROUPNAME		IN VARCHAR2,
     		P_TESTCLASSNAME		IN VARCHAR2,
 		P_USER_TEST_NAME	IN VARCHAR2,
		P_METALINK_NOTE		IN VARCHAR2,
		P_COMPETENCY		IN VARCHAR2,
		P_SUBCOMPETENCY		IN VARCHAR2,
		P_PRODUCTS		IN VARCHAR2,
		P_TEST_TYPE		IN VARCHAR2,
		P_ANALYSIS_SCOPE	IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_SHORT_DESCR		IN VARCHAR2,
		P_USAGE_DESCR		IN VARCHAR2,
		P_KEYWORDS		IN VARCHAR2,
		P_COMPONENT		IN VARCHAR2,
		P_SUBCOMPONENT		IN VARCHAR2,
		P_HIGH_PRODUCT_VERSION	IN VARCHAR2,
		P_LOW_PRODUCT_VERSION	IN VARCHAR2,
		P_HIGH_PATCHSET		IN VARCHAR2,
		P_LOW_PATCHSET		IN VARCHAR2,
     		P_LUDATE 		IN VARCHAR2,
		P_SEC_GRP_ID		IN VARCHAR2,
		P_CUST_MODE		IN VARCHAR2,
     		P_OWNER 		IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db
        v_num		number;		-- temporary variable
	seq		number;		-- varaible for SEQUENCE in db

  BEGIN
	 -- Get the sequence number from test table
	 -- as test table is updated before kb table, this should work
	 begin
	        select	SEQUENCE
		into	seq
		from	jtf_diagnostic_test
		where	appid = p_appid and
			groupname = p_groupname and
			testclassname = p_testclassname;
	 end;

         -- Translate owner to file_last_updated_by

         -- 5953806 - replaced to follow FNDLOAD standards
         /*if (P_OWNER = 'SEED') then
           f_luby := 1;
         else
           f_luby := 0;
         end if;*/

         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(p_ludate, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_kb
         	where 	sequence = seq;

       		-- Update record only as per standard

                -- 5953806 - replaced to if statement to follow FNDLOAD standards
       		/*if ((p_cust_mode = 'FORCE') or
	                ((f_luby = 0) and (db_luby = 1)) or
	       		((f_luby = db_luby) and (f_ludate > db_ludate)))*/
                /*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update	jtf_diagnostic_kb
                set 	last_updated_by = f_luby,
                        last_update_date = f_ludate,
                        object_version_number = object_version_number + 1,
                        USER_TEST_NAME = P_USER_TEST_NAME,
                        METALINK_NOTE = P_METALINK_NOTE,
                        COMPETENCY = P_COMPETENCY,
                        SUBCOMPETENCY = P_SUBCOMPETENCY,
                        PRODUCTS = P_PRODUCTS,
                        TEST_TYPE = P_TEST_TYPE,
                        ANALYSIS_SCOPE = P_ANALYSIS_SCOPE,
                        DESCRIPTION = P_DESCRIPTION,
                        SHORT_DESCR = P_SHORT_DESCR,
                        USAGE_DESCR = P_USAGE_DESCR,
                        KEYWORDS = P_KEYWORDS,
                        COMPONENT = P_COMPONENT,
                        SUBCOMPONENT = P_SUBCOMPONENT,
                        HIGH_PRODUCT_VERSION = P_HIGH_PRODUCT_VERSION,
                        LOW_PRODUCT_VERSION = P_LOW_PRODUCT_VERSION,
                        HIGH_PATCHSET = P_HIGH_PATCHSET,
                        LOW_PATCHSET = P_LOW_PATCHSET,
                        security_group_id = to_number(P_SEC_GRP_ID)
                where	sequence = seq;

         	--end if;

  		exception

          		when no_data_found then
            		-- Record doesn't exist - insert in all cases

            			insert into jtf_diagnostic_kb(
            				SEQUENCE,
 					USER_TEST_NAME,
					METALINK_NOTE,
					COMPETENCY,
					SUBCOMPETENCY,
					PRODUCTS,
					TEST_TYPE,
					ANALYSIS_SCOPE,
					DESCRIPTION,
					SHORT_DESCR,
					USAGE_DESCR,
					KEYWORDS,
					COMPONENT,
					SUBCOMPONENT,
					HIGH_PRODUCT_VERSION,
					LOW_PRODUCT_VERSION,
					HIGH_PATCHSET,
					LOW_PATCHSET,
            				OBJECT_VERSION_NUMBER,
            				CREATED_BY,
            				LAST_UPDATE_DATE,
            				LAST_UPDATED_BY,
            				LAST_UPDATE_LOGIN,
            				CREATION_DATE,
            				security_group_id)
            			values(
            				seq,
 					P_USER_TEST_NAME,
					P_METALINK_NOTE,
					P_COMPETENCY,
					P_SUBCOMPETENCY,
					P_PRODUCTS,
					P_TEST_TYPE,
					P_ANALYSIS_SCOPE,
					P_DESCRIPTION,
					P_SHORT_DESCR,
					P_USAGE_DESCR,
					P_KEYWORDS,
					P_COMPONENT,
					P_SUBCOMPONENT,
					P_HIGH_PRODUCT_VERSION,
					P_LOW_PRODUCT_VERSION,
					P_HIGH_PATCHSET,
					P_LOW_PATCHSET,
            				1,
            				f_luby,
            				f_ludate,
            				f_luby,
            				null,
            				f_ludate,
            				to_number(P_SEC_GRP_ID));
         end;

  END LOAD_ROW_KB;

  ------------------------------------------------------------
  -- procedure PARSE TEST CLASS NAME
  ------------------------------------------------------------

   procedure PARSE_TESTCLASSNAME(
			P_TESTCLASSNAME IN VARCHAR2,
			V_PRODUCT OUT NOCOPY VARCHAR2,
			V_FILENAME OUT NOCOPY VARCHAR2) IS

      BEGIN

		select substr(P_TESTCLASSNAME,
			instr(P_TESTCLASSNAME,'.',1,2)+1,
			instr(P_TESTCLASSNAME,'.',1,3) -
				instr(P_TESTCLASSNAME,'.',1,2) - 1)
				 	into V_PRODUCT from dual;

		select substr(P_TESTCLASSNAME,
			instr(P_TESTCLASSNAME,'.',-1,1)+1)
				into V_FILENAME from dual;

      END PARSE_TESTCLASSNAME;

    PROCEDURE SEED_TESTSET(
		P_NAME	 	IN VARCHAR2,
		P_DESCRIPTION	IN VARCHAR2,
		P_XML		IN CLOB,
     		P_LUDATE 	IN VARCHAR2,
		P_CUST_MODE	IN VARCHAR2,
		P_OWNER 	IN VARCHAR2) IS

        f_luby    	number;  	-- entity owner in file
        f_ludate  	date;    	-- entity update date in file
        db_luby   	number;  	-- entity owner in db
        db_ludate 	date;  		-- entity update date in db

    BEGIN

         -- Translate owner to file_last_updated_by
         f_luby := fnd_load_util.owner_id(P_OWNER);

         -- Translate char last_update_date to date
         f_ludate := nvl(to_date(p_ludate, 'YYYY/MM/DD'), sysdate);

	 begin
         	select 	LAST_UPDATED_BY, LAST_UPDATE_DATE
         	into 	db_luby, db_ludate
         	from 	jtf_diagnostic_testset
         	where 	name = p_name;

       		-- Update record only as per standard

                /*if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_cust_mode))
       		then*/
                -- seed data must not be changed by customers.Hence overwriting data always
                -- so that it covers up any changes by mistake
                update_testset(p_name,p_description,p_xml,f_luby,f_ludate);

         	--end if;

	exception

		when no_data_found then
		-- Record doesn't exist - insert in all cases
			insert_testset(p_name,p_description,p_xml,f_luby,f_ludate,null,f_luby,f_ludate);

         end;

    END SEED_TESTSET;


    PROCEDURE UPDATE_TESTSET(
		P_NAME	 		IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_XML			IN CLOB) IS
	f_luby    	number;
	f_ludate  	date;
    BEGIN
	f_luby := FND_GLOBAL.user_id;
	select sysdate into f_ludate from dual;
	UPDATE_TESTSET(P_NAME, P_DESCRIPTION, P_XML, f_luby, f_ludate);
    END UPDATE_TESTSET;

    PROCEDURE UPDATE_TESTSET(
		P_NAME	 		IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_XML			IN CLOB,
		P_LAST_UPDATED_BY	IN NUMBER,
     		P_LAST_UPDATED_DATE	IN DATE) IS

    BEGIN
	update	jtf_diagnostic_testset
		set 	description = P_DESCRIPTION,
			xml = XMLTYPE(P_XML),
			last_updated_by = P_LAST_UPDATED_BY,
			last_update_date = P_LAST_UPDATED_DATE
		where	name = P_NAME;
    END UPDATE_TESTSET;

    PROCEDURE INSERT_TESTSET(
		P_NAME	 		IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_XML			IN CLOB) IS
	f_luby    	number;
	f_ludate  	date;
    BEGIN
	f_luby := FND_GLOBAL.user_id;
	select sysdate into f_ludate from dual;
	INSERT_TESTSET(P_NAME, P_DESCRIPTION, P_XML, f_luby, f_ludate, null, f_luby, f_ludate);
    END INSERT_TESTSET;

    PROCEDURE INSERT_TESTSET(
		P_NAME	 		IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_XML			IN CLOB,
		P_CREATED_BY		IN NUMBER,
     		P_CREATION_DATE		IN DATE,
		P_LAST_UPDATE_LOGIN	IN NUMBER,
		P_LAST_UPDATED_BY	IN NUMBER,
     		P_LAST_UPDATED_DATE	IN DATE) IS

    BEGIN
	insert into jtf_diagnostic_testset
	(NAME, DESCRIPTION, XML, CREATED_BY, CREATION_DATE,
	LAST_UPDATE_LOGIN, LAST_UPDATED_BY, LAST_UPDATE_DATE)
	values
	( P_NAME , P_DESCRIPTION, XMLType(P_XML), P_CREATED_BY, P_CREATION_DATE,
	P_LAST_UPDATE_LOGIN, P_LAST_UPDATED_BY, P_LAST_UPDATED_DATE);
    END INSERT_TESTSET;

-- ---------------------------------------------------------------------------------------
-- Procedure to update valid applications for the test. The last updated date would be the
-- system date and the user info will be taken from FND_GLOBAL.user_id
-- ---------------------------------------------------------------------------------------
    PROCEDURE UPDATE_VALID_APPS(
		P_APPSHORTNAME	IN VARCHAR2,
		P_GROUPNAME	IN VARCHAR2,
		P_TESTCLASSNAME	IN VARCHAR2,
                P_VALIDAPPS     IN VARCHAR2) IS
	F_LUBY    	NUMBER;
	F_LUDATE  	DATE;
    BEGIN
	F_LUBY := FND_GLOBAL.user_id;
	SELECT SYSDATE INTO F_LUDATE FROM DUAL;
	UPDATE_VALID_APPS(P_APPSHORTNAME, P_GROUPNAME, P_TESTCLASSNAME,P_VALIDAPPS, F_LUBY, F_LUDATE);
    END UPDATE_VALID_APPS;

-- ------------------------------------------------------------------------------------------
-- Procedure to update valid applications for the test providing the last updated information
-- ------------------------------------------------------------------------------------------
    PROCEDURE UPDATE_VALID_APPS(
		P_APPSHORTNAME	 	IN VARCHAR2,
		P_GROUPNAME		IN VARCHAR2,
		P_TESTCLASSNAME		IN VARCHAR2,
		P_VALIDAPPS		IN VARCHAR2,
		P_LAST_UPDATED_BY	IN NUMBER,
     		P_LAST_UPDATED_DATE	IN DATE) IS

    BEGIN

        UPDATE	JTF_DIAGNOSTIC_TEST
		SET 	VALID_APPLICATIONS = XMLTYPE(P_VALIDAPPS),
			LAST_UPDATED_BY = P_LAST_UPDATED_BY,
			LAST_UPDATE_DATE = P_LAST_UPDATED_DATE
		WHERE	APPID = P_APPSHORTNAME
                AND     GROUPNAME = P_GROUPNAME
                AND     TESTCLASSNAME = P_TESTCLASSNAME;

    END UPDATE_VALID_APPS;


-- ------------------------------------------------------------------------------------------
-- Function used to validate whether the user is having the privilege to execute the test
-- or not. This function takes sensitivity & valid applications at test level as parameters
-- and checks if user is having the privilege to execute the test
-- ------------------------------------------------------------------------------------------
   FUNCTION VALIDATE_APPLICATIONS(
                  P_SENSITIVITY NUMBER,
                  P_VALID_APPS_XML XMLTYPE) RETURN NUMBER IS

        -- a cursor pointing to list of applications which are valid for
        -- user obtained using USER_NAME
         cursor valid_user_apps_cursor is
                  select distinct owner_tag from wf_roles where name in
                      ( select role_name from wf_user_roles where user_name=sys_context('FND','USER_NAME')
                        and role_name not in ( 'FND_RESP|FND|APPLICATION_DIAGNOSTICS|STANDARD','UMX|ODF_APPLICATION_END_USER_ROLE',
                        'UMX|ODF_APPLICATION_SUPER_USER_ROLE','UMX|ODF_DIAGNOSTICS_SUPER_USER_ROLE')
                         and sysdate >=start_date and start_date <nvl(expiration_date,sysdate+1)
                         and  nvl2(expiration_date,expiration_date,sysdate+1) >= sysdate
                         )
                    and sysdate >=start_date and start_date <nvl(expiration_date,sysdate+1)
                    and owner_tag is not null;

        -- a cursor pointing to valid apps for test using valid_applications column in test table
          cursor valid_seeded_apps_cursor is
                  select extractvalue(value(tbl),'/value') apps from
                    table(xmlsequence(extract(P_VALID_APPS_XML,'/list/value'))) tbl;

            user_apps     jtf_diag_arraylist; -- List of apps obtained using USER_NAME
            seeded_apps   jtf_diag_arraylist; -- List of apps marked as valid @ test level
            custom_apps   jtf_diag_arraylist; -- custom applications w.r.t seeded apps
            valid_apps    jtf_diag_arraylist; -- valid seeded & custom apps for user


        BEGIN

            if P_SENSITIVITY = 1 then
                return 1;
            end if;

            -- List of apps obtained using USER_NAME
            user_apps    := jtf_diag_arraylist();

            -- List of apps marked as valid @ test level
            seeded_apps  := jtf_diag_arraylist();


            -- get applications using USER_NAME
            for x in valid_user_apps_cursor loop
              user_apps.addtolist(x.owner_tag);
            end loop;

           -- get valid_apps_for_test using valid_applications column in test table
           for x in valid_seeded_apps_cursor loop
              seeded_apps.addtolist(x.apps);
           end loop;


            for i in 1 .. seeded_apps.getsize() loop

              -- if user_apps (obtained using USER_NAME) contains any of applications
              -- marked as valid at test level, then add those to valid_apps list
                if user_apps.contains(seeded_apps.get(i)) then
                    return 1;
                end if;

              -- custom apps w.r.t seeded apps
                custom_apps  := get_custom_apps(seeded_apps.get(i));

              -- if custom_apps contains any of applications on which user is having
              -- custom responsibility, then add respective seeded application to valid_apps list
                for j in 1 .. custom_apps.getsize() loop
                  if user_apps.contains(custom_apps.get(j)) then
                      return 1;
                  end if;
                end loop;
            end loop;

                return 0;
          -- end if;
    END VALIDATE_APPLICATIONS;

-- ------------------------------------------------------------------------------------------
-- Function to return an arraylist of custom applications w.r.t seed application
-- ------------------------------------------------------------------------------------------
  FUNCTION GET_CUSTOM_APPS(seeded_app VARCHAR2)
           RETURN JTF_DIAG_ARRAYLIST IS

    p_object_id integer;
    p_permission_set_id integer;
    p_custom_role varchar2(100);
    custom_apps_list jtf_diag_arraylist;

    cursor custom_apps_cursor is select instance_pk1_value from fnd_grants
            where grantee_key = p_custom_role and object_id = p_object_id
            and menu_id = p_permission_set_id;

   BEGIN
      -- retrieve the OBJECT_ID of ODF_CUSTOMIZATION_OBJ object
      select object_id into p_object_id from fnd_objects
          where obj_name = 'ODF_CUSTOMIZATION_OBJ';

      -- retrieve the PERMISSION_SET_ID of ODF_EXECUTION_PS
      select menu_id into p_permission_set_id from fnd_menus
          where menu_name = 'ODF_EXECUTION_PS';

      --Custom role attached to seed application
      p_custom_role := 'UMX|ODF_CUSTOM_'||seeded_app||'_ROLE';

      --instantiate array list
      custom_apps_list := jtf_diag_arraylist();

      for x  in custom_apps_cursor loop
          custom_apps_list.addtolist(x.instance_pk1_value);
      end loop;

      return custom_apps_list;
   END GET_CUSTOM_APPS;


-- ------------------------------------------------------------------------------------------
-- Function to return an app id from app short name
-- ------------------------------------------------------------------------------------------
  FUNCTION GET_APP_ID(APP_SHORT_NAME VARCHAR2)
           RETURN INTEGER IS
        p_appid integer;
    BEGIN
        select application_id into p_appid from fnd_application where application_short_name = APP_SHORT_NAME;
        return p_appid;
  END GET_APP_ID;

-- ------------------------------------------------------------------------------------------
-- Function to return an array of spp short names from app short name
-- ------------------------------------------------------------------------------------------
  FUNCTION GET_CUSTOM_APPS_ARRAY(APP_SHORT_NAME VARCHAR2)
           RETURN jtf_varchar2_table_100 IS

    custom_apps_array jtf_varchar2_table_100;
    custom_apps_list jtf_diag_arraylist;
    --asize integer:=0;
    BEGIN
     custom_apps_list:= GET_CUSTOM_APPS(APP_SHORT_NAME);
     custom_apps_array := jtf_varchar2_table_100();
     for i in  1 .. custom_apps_list.getsize() loop
       -- asize := asize+1;
        custom_apps_array.extend;
        custom_apps_array(i):= custom_apps_list.get(i);
     end loop;

     return custom_apps_array;

    END GET_CUSTOM_APPS_ARRAY;

    procedure UPDATE_TEST_END_DATE(
                P_APP_NAME IN VARCHAR2,
                P_GROUP_NAME IN VARCHAR2,
                P_TEST_NAME IN VARCHAR2,
                P_END_DATE IN DATE default null,
                P_LUBID IN NUMBER
                ) IS
        F_END_DATE  	date;
    BEGIN
                IF P_END_DATE IS NOT NULL THEN
                    --F_END_DATE := to_date(P_END_DATE, JTF_DIAGNOSTIC_ADAPTUTIL.GET_SITE_DATE_FORMAT());
                    F_END_DATE := P_END_DATE;
                END IF;
                UPDATE jtf_diagnostic_test
                SET end_date = F_END_DATE,
                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATED_BY = P_LUBID
                WHERE appid = P_APP_NAME AND
                      groupname = P_GROUP_NAME AND
		      testclassname = P_TEST_NAME;

                IF SQL%NOTFOUND THEN
                   RAISE_APPLICATION_ERROR(-20000,'Cant Update, Record Not
Found');
                END IF;


    END UPDATE_TEST_END_DATE;
END JTF_DIAGNOSTIC;

/
