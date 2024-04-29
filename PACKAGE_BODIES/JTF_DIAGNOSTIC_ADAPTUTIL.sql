--------------------------------------------------------
--  DDL for Package Body JTF_DIAGNOSTIC_ADAPTUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAGNOSTIC_ADAPTUTIL" AS
/* $Header: jtfdiagadptutl_b.pls 120.12 2008/03/11 10:02:18 sramados noship $ */

  -----------------------------------------------------------
  -- checkValidApi takes in the test package name and
  -- queries the all_arguments data dictionary to check if the
  -- api required for this to be a valid diagnostic test exist.
  -- checks for the runTest procedure call in the package name
  -- and then checks if the API exists. Currently it is just the
  -- runTest method that is checked.
  -- probably not the best wasy to do this - need to look further
  -- into the dbms_describe package and describe_procedure calls.
  -----------------------------------------------------------



FUNCTION checkValidApi(packageName IN VARCHAR2) RETURN INTEGER IS
  arg1 VARCHAR2(100);
  arg2 VARCHAR2(100);
  arg3 VARCHAR2(100);
  maxPos INTEGER;
  b_true NUMBER := 1;
  b_false NUMBER :=0;
BEGIN
  -- checking if a valid RUNTEST API has been written.
  select nvl(TYPE_NAME,PLS_TYPE) into arg1
  from all_arguments z
  where UPPER(z.package_name) = UPPER(packageName)
  and upper(z.owner) in ('APPS', 'JTF', 'APPLSYS')
  and UPPER(z.object_name) = 'RUNTEST'
  and z.position = 1
  and z.IN_OUT = 'IN';

  select nvl(z.TYPE_NAME,z.PLS_TYPE)  into arg2
  from all_arguments z
  where UPPER(z.package_name) = UPPER(packageName)
  and upper(z.owner) in ('APPS', 'JTF', 'APPLSYS')
  and UPPER(z.object_name) = 'RUNTEST'
  and z.position = 2
  and z.IN_OUT = 'OUT';

  select nvl(z.TYPE_NAME,z.PLS_TYPE) into arg3
  from all_arguments z
  where UPPER(z.package_name) = UPPER(packageName)
  and upper(z.owner) in ('APPS', 'JTF', 'APPLSYS')
  and UPPER(z.object_name) = 'RUNTEST'
  and z.position = 3
  and z.IN_OUT = 'OUT';

  -- make sure that function has correct no of params.
  select max(z.position) into maxPos
  from all_arguments z
  where UPPER(z.package_name) = UPPER(packageName)
  and upper(z.owner) in ('APPS', 'JTF', 'APPLSYS')
  and UPPER(z.object_name) = 'RUNTEST';
  IF maxPos > 3 THEN
    return b_false;
  END IF;
  IF (UPPER(arg1) <> 'JTF_DIAG_INPUTTBL') THEN
    return b_false;
  END IF;
  IF (UPPER(arg2) <> 'JTF_DIAG_REPORT') THEN
    return b_false;
  END IF;
  IF (UPPER(arg3) <> 'CLOB') THEN
    return b_false;
  END IF;
  return b_true;
EXCEPTION
   WHEN others THEN
   return b_false;
END checkValidApi;


  -----------------------------------------------------------
  -- checkValidPackage takes in the test package name and
  -- queries the all_objects data dictionary to check if the
  -- package and package body for the specified package exist
  -- and are marked as valid objects
  -- returns '1' if valid and '0' if not valid
  -----------------------------------------------------------

FUNCTION checkValidPackage(packageName IN VARCHAR2) RETURN INTEGER IS
 s_status VARCHAR2(30);
 b_status VARCHAR2(30);
 b_true NUMBER := 1;
 b_false NUMBER :=0;
 BEGIN

 -- OWNER CHANGE
  select y.status into s_status from all_objects y
  where y.object_name = UPPER(packageName)
  and y.object_type = 'PACKAGE'
  and upper(y.owner) in ('APPS', 'JTF', 'APPLSYS');

  select y.status into b_status from all_objects y
  where y.object_name = UPPER(packageName)
  and y.object_type = 'PACKAGE BODY'
  and upper(y.owner) in ('APPS', 'JTF', 'APPLSYS');

  IF s_status = 'VALID' and b_status = 'VALID' THEN
    return b_true;
  ELSE
    return b_false;
  END IF;
  EXCEPTION
   WHEN others THEN
    return b_false;
 END checkValidPackage;

  -----------------------------------------------------------
  -- checkPackageExists takes in the test package name and
  -- queries the all_objects data dictionary to check if the
  -- package and package body for the specified package exist
  -- returns '1' if exists '0' if doesnt exist.
  -----------------------------------------------------------

FUNCTION checkPackageExists(packageName IN VARCHAR2) RETURN INTEGER IS
  v_pspec VARCHAR2(100);
  v_pbody VARCHAR2(100);
  b_true NUMBER := 1;
  b_false NUMBER :=0;
BEGIN
  select y.owner into v_pspec from all_objects y
  where y.object_name = UPPER(packageName)
  and y.object_type = 'PACKAGE'
  and upper(y.owner) in ('APPS', 'JTF', 'APPLSYS');

  select  y.owner into v_pbody from all_objects y
  where y.object_name = UPPER(packageName)
  and y.object_type = 'PACKAGE BODY'
  and upper(y.owner) in ('APPS', 'JTF', 'APPLSYS');

  return b_true;
EXCEPTION
 WHEN others THEN
  -- logging here..
  return b_false;
END;

  -----------------------------------------------------------
  -- getVersion takes in the test package name and returns the
  -- RCS Header information for the body of the PLSQL package body
  -- file.
  -----------------------------------------------------------

FUNCTION getVersion(packageName IN VARCHAR2) RETURN VARCHAR2 IS
  rcs_id VARCHAR2(4000) := 'Version Unknown.';
BEGIN
  select text into rcs_id from all_source
  where name like UPPER(packageName)
  and upper(owner) in ('APPS', 'JTF', 'APPLSYS')
  and text like '%$%Header%ship%' and
  type like 'PACKAGE BODY';
  return rcs_id;
EXCEPTION
  WHEN others THEN
  -- logging here..
  return 'Version Unknown.';
END;


  -----------------------------------------------------------
  -- constructReport takes in four parameters.
  -- status - the result of the test - either SUCCESS or FAILED
  -- errStr - the error that has been populated by the user
  --          could be SQLERRM or a user defined error message
  -- fixInfo - string to help the user to fix the associated problem
  -- isFatal - either TRUE or FALSE (sring representations)
  -----------------------------------------------------------

FUNCTION constructReport(status    IN VARCHAR2 DEFAULT 'FAILED',
						 errStr    IN VARCHAR2 DEFAULT 'Internal Error',
						 fixInfo   IN VARCHAR2 DEFAULT 'No Fix Information Available',
						 isFatal   IN VARCHAR2 DEFAULT 'FALSE') RETURN JTF_DIAG_REPORT IS
 tempReport JTF_DIAG_REPORT;
BEGIN
 b_html_on := false;
 tempReport := JTF_DIAG_REPORT(status,
							   errStr,
							   fixInfo,
							   isFatal);
 return tempReport;
EXCEPTION
 WHEN others THEN
  return null;
END constructReport;

  ---------------------------------------------------------------------
  -- initialise a inputTable object and return it to the
  -- caller method.   A table of a single empty JTF_DIAG_INPUTS
  -- is created and then removed with the call to trim -
  -- this initializes the collection
  ---------------------------------------------------------------------

FUNCTION initInputTable RETURN JTF_DIAG_INPUTTBL IS
 temp JTF_DIAG_INPUTTBL;
BEGIN
 temp := JTF_DIAG_INPUTTBL(JTF_DIAG_INPUTS(-1,'',''));
 temp.trim;
 return temp;
EXCEPTION
 WHEN others THEN
  return null;
END;

  ---------------------------------------------------------------------
  -- initialise a reportTable object and return it to the
  -- caller method.   A table of a single empty JTF_DIAG_REPORT
  -- is created and then removed with the call to trim -
  -- this initializes the collection
  ---------------------------------------------------------------------

FUNCTION initReportTable RETURN JTF_DIAG_REPORTTBL IS
 tempRpt JTF_DIAG_REPORT;
 temp JTF_DIAG_REPORTTBL;
BEGIN
  tempRpt := JTF_DIAG_REPORT('','','','');
  temp := JTF_DIAG_REPORTTBL(tempRpt);
  temp.trim;
 return temp;
EXCEPTION
 WHEN others THEN
  return null;
END;

  ----------------------------------------------------------------------
  -- initVarcharTabble returns an empty table of VARCHAR2(4000)
  ----------------------------------------------------------------------

FUNCTION initVarcharTable RETURN JTF_VARCHAR2_TABLE_4000 IS
 temp JTF_VARCHAR2_TABLE_4000;
BEGIN
  temp := JTF_VARCHAR2_TABLE_4000('');
  temp.trim;
 return temp;
EXCEPTION
 WHEN others THEN
  return null;
END;


  ----------------------------------------------------------------------
  -- initReportClob returns an initialised CLOB
  ----------------------------------------------------------------------

FUNCTION initReportClob RETURN CLOB IS
  temp CLOB;
BEGIN
  dbms_lob.createTemporary(temp,true,dbms_lob.call);
  return temp;
EXCEPTION
 WHEN others THEN
  -- logging here
  return null;
END;


  ----------------------------------------------------------------------
  -- getReportClob returns the CLOB containing the session report.
  ----------------------------------------------------------------------

FUNCTION getReportClob RETURN CLOB IS
BEGIN
  return reportClob;
END;



  ----------------------------------------------------------------------
  -- compareResults takes a 3 arguments the operator that is to be performed
  -- the expected String value and the String value that is to be tested
  -- i.e passing in = 'string1' 'StRiNg' would evaluate to true as the
  -- two strings match.
  ----------------------------------------------------------------------

FUNCTION compareResults(oper IN VARCHAR2,
                         arg1 IN VARCHAR2,
						 arg2 IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
 IF (oper = '=') THEN
   IF (UPPER(arg1) = UPPER(arg2)) THEN
     return true;
   ELSE
     return false;
   END IF;
 ELSE
   return false;
 END IF;
 EXCEPTION
 WHEN others THEN
  -- logging here
  return false;
END;


  ----------------------------------------------------------------------
  -- compareResults takes a 3 arguments the operator that is to be performed
  -- the expected value and the value that is to be tested
  -- i.e passing in > 50 1 would evaluate to true as 50 IS greater than
  -- 1 etc...  > 1 50 would evaluate to false.
  ----------------------------------------------------------------------

FUNCTION compareResults(oper IN VARCHAR2,
                         arg1 IN INTEGER,
						 arg2 IN INTEGER) RETURN BOOLEAN IS
BEGIN
 IF (oper = '=') THEN
   IF (arg1 = arg2) THEN
     return true;
   ELSE
     return false;
   END IF;
 END IF;
 IF (oper = '>') THEN
   IF (arg1 > arg2) THEN
     return true;
   ELSE
     return false;
   END IF;
 END IF;
 IF (oper = '<') THEN
   IF (arg1 < arg2) THEN
     return true;
   ELSE
     return false;
   END IF;
 END IF;
 EXCEPTION
 WHEN others THEN
  return false;
END;

  ----------------------------------------------------------------------
  -- extractVersion takes the full version string as argument i.e the
  -- full RCS_ID and strips out the version number of the test. i.e
  -- it is assuming that RCS_ID tags are in the format of :
  -- '$Header: <filename>.sql xxx.xx yyyy/mm/dd hh:mm:ss <userid> <ship status>';
  -- and in this case the version i.e xxx.xx would be returned.
  ----------------------------------------------------------------------

FUNCTION extractVersion(versionStr IN VARCHAR2) RETURN VARCHAR2 IS
 startPos INTEGER;
 endPos   INTEGER;
 numChars INTEGER;
 tempStr  VARCHAR2(100);
BEGIN
 startPos := instr(versionStr,' ',1,3);
 endPos   := instr(versionStr,' ',startPos+1,1);
 numChars := endPos - startPos;
 tempStr  := substr(versionStr,startPos,numChars);
 return tempStr;
EXCEPTION
 WHEN others THEN
  return 'No Version';
END;

  ----------------------------------------------------------------------
  -- setUpVars passes in a reference to an out variable reportCLOB
  -- which is of type CLOB - this procedure initializes this clob
  ----------------------------------------------------------------------


PROCEDURE setUpVars IS
 BEGIN
   b_html_on := false;
   reportClob:= initReportClob; -- initialize reportClob
 EXCEPTION
 WHEN others THEN
  -- logging here
  null;
END;

  ----------------------------------------------------------------------
  -- addInput takes a table of JTF_DIAG_INPUTS in the form JTF_DIAG_INPUTTBL
  -- a varchar2 representing the variable to add and a varchar2 representing
  -- the value to add and this function will add create a new JTF_DIAG_INPUTS
  -- object from the variable and value and add this JTF_DIAG_INPUTS to
  -- a table of JTF_DIAG_INPUTS (JTF_DIAG_INPUTTBL) and return this. As this
  -- method is overloaded and no "showValue" is passed - this field is
  -- set as TRUE or VISIBLE
  ----------------------------------------------------------------------

FUNCTION addInput(inputs IN JTF_DIAG_INPUTTBL,
                   var   IN  VARCHAR2,
	               val   IN  VARCHAR2) RETURN JTF_DIAG_INPUTTBL IS
  tempInput JTF_DIAG_INPUTS;
  tempInputTable JTF_DIAG_INPUTTBL;
  valueStrTestInfo VARCHAR2(100);
  BEGIN
    tempInputTable := inputs;
    tempInput := JTF_DIAG_INPUTS(VISIBLE,var,val);
    tempInputTable.extend(1);
    tempInputTable(tempInputTable.COUNT) := tempInput;
	return tempInputTable;
  EXCEPTION
    WHEN others THEN
	 -- logging here...
	 return inputs;
END;



  ----------------------------------------------------------------------
  -- addInput takes a table of JTF_DIAG_INPUTS in the form JTF_DIAG_INPUTTBL
  -- a varchar2 representing the variable to add and a varchar2 representing
  -- the value to add and this function will add create a new JTF_DIAG_INPUTS
  -- object from the variable and value and add this JTF_DIAG_INPUTS to
  -- a table of JTF_DIAG_INPUTS (JTF_DIAG_INPUTTBL) and return this.
  -- showValue can either be set to VISIBLE or HIDDEN. This is to indicate
  -- if the variable is a confidential field.
  ----------------------------------------------------------------------


FUNCTION addInput(inputs IN JTF_DIAG_INPUTTBL,
                   var   IN  VARCHAR2,
	               val   IN  VARCHAR2,
				   showValue IN BOOLEAN) RETURN JTF_DIAG_INPUTTBL IS
  tempInput JTF_DIAG_INPUTS;
  tempInputTable JTF_DIAG_INPUTTBL;
  valueStrTestInfo VARCHAR2(100);
  hidval INTEGER;
  BEGIN
   tempInputTable := inputs;
   IF showValue THEN
     hidVal := VISIBLE;
   ELSE
     hidVal := HIDDEN;
   END IF;
	tempInput := JTF_DIAG_INPUTS(hidVal,var,val);
    tempInputTable.extend(1);
    tempInputTable(tempInputTable.COUNT) := tempInput;
	return tempInputTable;
  EXCEPTION
    WHEN others THEN
	 -- logging here...
	 return inputs;
END;


  ----------------------------------------------------------------------
  -- getInputValue takes the argument name that we want the associated
  -- value for, and the JTF_DIAG_INPUTTBL of objects (table of JTF_DIAG_INPUTS)
  -- the associated value is extracted from the JTF_DIAG_INPUTTBL and returned
  -- for the passed in argument name.
  ----------------------------------------------------------------------

 FUNCTION getInputValue(argName IN VARCHAR2,
                        inputs IN JTF_DIAG_INPUTTBL) RETURN VARCHAR2 IS
  input JTF_DIAG_INPUTS;
 BEGIN
   FOR v_counter IN 1..inputs.COUNT LOOP
      input := inputs(v_counter);
	  IF UPPER(inputs(v_counter).name) = UPPER(argName) THEN
		return inputs(v_counter).value;
	  END IF;
   END LOOP;
   return NULL;
 END;

    -------------------------------------------------------------
    -- AddSafeStringToReport takes an input string containing
    -- characters which are illegal in Xml.This function will
    -- replace those characters with Xml complaint characters
    -- , add <span> tags to make it Xml Parser complaint and then
    -- add this string to report.
    -------------------------------------------------------------
    Procedure AddSafeStringToReport(reportStr In Long)
    Is
    tempReportStr LONG;
    tempClob CLOB;
    strSize INTEGER;
    BEGIN
    IF reportStr is not null then
      IF b_html_on then
        tempReportStr := replace(reportStr,'&', '&amp;');
        tempReportStr := replace(replace(tempReportStr,'<','&lt;'),'>','&gt;');
        tempReportStr := replace(replace(tempReportStr,'','&apos;'),'"','&quot;');

        tempReportStr := concat('<span>',tempReportStr);
        tempReportStr := concat(tempReportStr, '</span>');

        dbms_lob.createTemporary(tempClob,true,dbms_lob.call);
        select vsize(tempReportStr) into strSize from dual;
        dbms_lob.write(tempClob,strSize,1,tempReportStr);
        dbms_lob.append(reportClob,tempClob);
      END IF;
    END IF;
    EXCEPTION
      WHEN others THEN
          --  logging here...
    null;
    END AddSafeStringToReport;
 ----------------------------------------------------------------------
  -- addStringToReport takes the report CLOB and LONG representation
  -- of the report string and appends the string onto the end of the
  -- report CLOB - the report CLOB is a IN/OUT object and so the CLOB
  -- object is accessable from the calling procedure after this procedure
  -- has terminated
  ----------------------------------------------------------------------

PROCEDURE addStringToReport(reportStr IN LONG) IS
  tempClob CLOB;
  strSize INTEGER;
  tmpReportStr LONG;
  BEGIN
    IF reportStr IS NOT NULL THEN
      IF (UPPER(reportStr) = UPPER('@HTML')) AND (DBMS_LOB.GETLENGTH(reportClob) = 0) THEN
        b_html_on := TRUE;
      END IF;
      dbms_lob.createTemporary(tempClob,true,dbms_lob.call);
      tmpReportStr := reportStr;
      select vsize(tmpReportStr) into strSize from dual;
      dbms_lob.write(tempClob,strSize,1,tmpReportStr);
      dbms_lob.append(reportClob,tempClob);
     END IF;
  EXCEPTION
    WHEN others THEN
	--  logging here...
    null;
END;
 -----------------------------------------------------------
  -- getTestMethodsForPkg tajes in a partial or complete
  -- string of the plsql package that is to have its
  -- unit tests executed.   A list or more technicaly a
  -- table of VARVCHAR(4000) is returned to the calling function
  -- this list contains all the methods that are contained in the package
  -- identified by the passed in String.   The procedure names are
  -- passed back in the format <packagename>.<procedurename>()
  -----------------------------------------------------------

FUNCTION  getTestMethodsForPkg(pkgName VARCHAR2) RETURN JTF_VARCHAR2_TABLE_4000 IS
  testNameTable JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
  testName VARCHAR2(4000);
  v_size NUMBER := 0;
  cursor testNameCursor IS

    select distinct a.package_name, a.object_name
    from all_arguments a, all_objects b
    where
    -- a.owner like 'APPS' and b.owner like 'APPS'
    -- and a.object_id = b.object_id
    a.object_id = b.object_id
    and b.object_name like upper(pkgName)||'%'
    and b.object_name like upper('%DIAGUNITTEST%')
    and b.object_type like 'PACKAGE'
    and upper(b.owner) in ('APPS', 'JTF', 'APPLSYS')
    and upper(a.owner) in ('APPS', 'JTF', 'APPLSYS')
    and a.object_name like 'TEST%'
    and a.sequence = 0;

    -- select distinct package_name,object_name
    -- from all_arguments
    -- where owner like 'APPS'
    -- where owner like USER
    -- and upper(package_name) like  upper(pkgName)
    -- and upper(package_name) like  upper(pkgName)||'%'
    -- and upper(package_name) like upper('%DIAGUNITTEST%')
    -- and upper(object_name) like 'TEST%'
    -- and sequence = 0;
BEGIN
  for x in testNameCursor
  loop
    v_size := v_size +1;
    testNameTable.extend;
    testNameTable(v_size) := x.package_name||'.'||x.object_name||'()';
  end loop;
  return testNameTable;
END;

  -----------------------------------------------------------
  -- getTestPackages takes in a partial or complete
  -- string of the plsql package that is to have its
  -- unit tests executed.   A list or more technicaly a
  -- table of VARVCHAR(4000) is returned to the calling function
  -- this list contains all the packages that begin or are denoted
  -- by the passed in String
  -----------------------------------------------------------

FUNCTION  getTestPackages(pkgName VARCHAR2) RETURN JTF_VARCHAR2_TABLE_4000 IS
  testNameTable JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
  testName VARCHAR2(4000);
  v_size NUMBER := 0;
  cursor testNameCursor IS
    select distinct package_name
    from all_arguments
    -- where owner like 'APPS'
    where -- owner like USER
    -- and upper(package_name) like  upper(pkgName)||'%'
    upper(package_name) like  upper(pkgName)||'%'
    and upper(owner) in ('APPS', 'JTF', 'APPLSYS')
    and upper(object_name) like upper('RUNTEST');
BEGIN
  for x in testNameCursor
  loop
    v_size := v_size +1;
    testNameTable.extend;
    testNameTable(v_size) := x.package_name;
  end loop;
  return testNameTable;
END;

-----------------------------------------------------------
  -- getUnitTestPackages takes in a partial or complete
  -- string of the plsql package that is to have its
  -- unit tests executed.   A list or more technicaly a
  -- table of VARCHAR(4000) is returned to the calling function
  -- this list contains all the packages that begin or are denoted
  -- by the passed in String and also contain procedures that
  -- have names beginning with "test..."  and pass no parameters.
  -- thus recognising packages with Unit tests within.
  -----------------------------------------------------------

FUNCTION  getUnitTestPackages(pkgName VARCHAR2) RETURN JTF_VARCHAR2_TABLE_4000 IS
  testNameTable JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
  testName VARCHAR2(4000);
  v_size NUMBER := 0;
  cursor testNameCursor IS
    select distinct package_name
    from all_arguments
    -- where owner like 'APPS'
    where -- owner like USER
    -- and upper(package_name) like  upper(pkgName)||'%'
    upper(package_name) like  upper(pkgName)||'%'
    and upper(package_name) like upper('%DIAGUNITTEST%')
    and upper(object_name) like 'TEST%'
    and upper(owner) in ('APPS', 'JTF', 'APPLSYS')
    and sequence = 0;
BEGIN
  for x in testNameCursor
  loop
    v_size := v_size +1;
    testNameTable.extend;
    testNameTable(v_size) := x.package_name;
  end loop;
  return testNameTable;
END;

  --------------------------------------------------------------------
  -- assert takes in two objects, - the message to be be thrown in the
  -- custom application exception. And a boolean value to indicate if
  -- the exception should be thrown at all.
  --------------------------------------------------------------------

PROCEDURE assert(message VARCHAR2,condition BOOLEAN) IS
BEGIN
  IF (not condition) THEN
    fail(message);
  END IF;
END;

  --------------------------------------------------------------------
  -- fail throws a PL/SQL custom application error.   The message
  -- passed through forms part of the error String that will be displayed
  -- as part of the plsql exception.   The PLSQL exception is caught and
  -- parsed by the diagnostic framework.
  --------------------------------------------------------------------


PROCEDURE fail(message VARCHAR2) IS
BEGIN
  RAISE_APPLICATION_ERROR(-20000,message);
END;

  --------------------------------------------------------------------
  -- assertTrue takes in a message to display to the user (if assertion fails) along
  -- with a BOOLEAN value.   If the value is False the assertion error is
  -- thrown displaying the message in the diagnostic framework else the
  -- message is ignored.
  --------------------------------------------------------------------

PROCEDURE assertTrue(message VARCHAR2, condition BOOLEAN) IS
BEGIN
  assert(message,condition);
END;

  --------------------------------------------------------------------
  -- assertTrue takes in a message to display to the user (if assertion fails) along
  -- with two VARCHAR2 objects and a operator.  Openator can be  (equals =)
  -- The assertion fail call is called if the
  -- the following statement is false  arg1 = arg2
  --------------------------------------------------------------------

PROCEDURE assertTrue(message VARCHAR2, operand VARCHAR2,arg1 VARCHAR2,arg2 VARCHAR2) IS
BEGIN
 IF (operand = '=') THEN
   IF (UPPER(arg1) = UPPER(arg2)) THEN
     assert(message,TRUE);
   ELSE
     assert(message,FALSE);
   END IF;
 ELSE
   assert(message,FALSE);
 END IF;
 EXCEPTION
 WHEN others THEN
  assert(message,FALSE);
END;

  --------------------------------------------------------------------
  -- assertTrue takes in a message to display to the user (if assertion fails) along
  -- with two NUMBER objects and a operator.  Openator can be (greater than >) ,
  -- (less than <) or  (equals =) The assertion fail call is called if the
  -- the following statement is false  arg1 (operand) arg2
  -- ie 10 > 20 is true, 20 = 21 is false  etc...
  --------------------------------------------------------------------

PROCEDURE assertTrue(message VARCHAR2, operand VARCHAR2,arg1 NUMBER,arg2 NUMBER) IS
BEGIN
  IF (operand = '=') THEN
   IF (arg1 = arg2) THEN
    assert(message,TRUE);
   ELSE
     assert(message,FALSE);
   END IF;
 END IF;
 IF (operand = '>') THEN
   IF (arg1 > arg2) THEN
     assert(message,TRUE);
   ELSE
     assert(message,FALSE);
   END IF;
 END IF;
 IF (operand = '<') THEN
   IF (arg1 < arg2) THEN
     assert(message,TRUE);
   ELSE
     assert(message,FALSE);
   END IF;
 END IF;
 EXCEPTION
 WHEN others THEN
  assert(message,FALSE);
END;

  --------------------------------------------------------------------
  -- assertEquals takes in a message to display to the user (if assertion fails) along
  -- with two NUMBER objects.  The assertion fail call is called if the
  -- two numbers are not equal.
  --------------------------------------------------------------------

PROCEDURE assertEquals(message VARCHAR2,arg1 NUMBER,arg2 NUMBER) IS
BEGIN
  IF (arg1 = arg2) THEN
   assert(message,TRUE);
 ELSE
   assert(message,FALSE);
 END IF;
END;

  --------------------------------------------------------------------
  -- assertEquals takes in a message to display to the user (if assertion fails) along
  -- with two VARCHAR2 objects.  The assertion fail call is called if the
  -- two Strings are not equal.
  --------------------------------------------------------------------

PROCEDURE assertEquals(message VARCHAR2,arg1 VARCHAR2,arg2 VARCHAR2) IS
BEGIN
 IF (arg1 = arg2) THEN
   assert(message,TRUE);
 ELSE
   assert(message,FALSE);
 END IF;
END;

  --------------------------------------------------------------------
  -- assertEquals takes in a message to display to the user (if assertion fails) along
  -- with two clob objects.  The assertion fail call is called if the
  -- two Clobs are not equal.
  --------------------------------------------------------------------

PROCEDURE assertEquals(message VARCHAR2,arg1 CLOB,arg2 CLOB) IS
 retval      INTEGER;
 strSizeArg1 INTEGER;
 strSizeArg2 INTEGER;
BEGIN
 select dbms_lob.getlength(arg1) into strSizeArg1 from dual;
 select dbms_lob.getlength(arg2) into strSizeArg2 from dual;
 retval :=  dbms_lob.compare(arg1,arg2,strSizeArg1,1,1);
 IF (retval = 0) THEN
   assert(message,TRUE);
 ELSE
   assert(message,FALSE);
 END IF;
END;

  --------------------------------------------------------------------
  -- assertNotNull takes in a message to display to the user (if assertion fails) along
  -- with a VARCHAR2 parameter.  The assert fail call is called if in
  -- a VARCHAR2 object throws an assertion error if it is null
  --------------------------------------------------------------------

PROCEDURE assertNotNull(message VARCHAR2,arg1 VARCHAR2) IS
BEGIN
 IF (arg1 IS NOT NULL) THEN
   assert(message,TRUE);
 ELSE
   assert(message,FALSE);
 END IF;
END;

  --------------------------------------------------------------------
  -- assertNull takes in a message to display to the user (if assertion fails) along
  -- with a VARCHAR2 parameter.  The assert fail call is called if in
  -- a VARCHAR2 object throws an assertion error - if it is not null
  --------------------------------------------------------------------

PROCEDURE assertNull(message VARCHAR2,arg1 VARCHAR2) IS
BEGIN
  IF (arg1 IS NULL) THEN
   assert(message,TRUE);
 ELSE
   assert(message,FALSE);
 END IF;
END;


  --------------------------------------------------------------------
  -- failNotEquals takes in a message to display to the user (if assertion fails) along
  -- with two VARCHAR2 parameters.  The assert fail call is called if the
  -- two VARCHAR2 (strings) are not equal.
  --------------------------------------------------------------------

PROCEDURE failNotEquals(message VARCHAR2,arg1 VARCHAR2,arg2 VARCHAR2) IS
BEGIN
  IF (arg1 = arg2) THEN
   assert(message,TRUE);
 ELSE
   assert(message,FALSE);
 END IF;
END;

  --------------------------------------------------------------------
  -- failNotEquals takes in a message to display to the user (if assertion fails) along
  -- with two NUMBER parameters.  The assert fail call is called if the
  -- two NUMBERS are not equal.
  --------------------------------------------------------------------

PROCEDURE failNotEquals(message VARCHAR2,arg1 NUMBER,arg2 NUMBER) IS
BEGIN
  IF (arg1 = arg2) THEN
   assert(message,TRUE);
 ELSE
   assert(message,FALSE);
 END IF;
END;

  --------------------------------------------------------------------
  -- failNotEquals takes in a message to display to the user (if assertion fails) along
  -- with two clob objects.  The assert fail call is called if the
  -- two clobs are not identical.
  --------------------------------------------------------------------

PROCEDURE failNotEquals(message VARCHAR2,arg1 CLOB,arg2 CLOB) IS
 retval      INTEGER;
 strSizeArg1 INTEGER;
 strSizeArg2 INTEGER;
BEGIN
 select dbms_lob.getlength(arg1) into strSizeArg1 from dual;
 select dbms_lob.getlength(arg2) into strSizeArg2 from dual;
 retval :=  dbms_lob.compare(arg1,arg2,strSizeArg1,1,1);
 IF (retval = 0) THEN
   assert(message,TRUE);
 ELSE
   assert(message,FALSE);
 END IF;
END;

  --------------------------------------------------------------------
  -- failFormatted takes in a message to display to the user (if assertion fails) along
  -- with the value that was expected (VARCHAR2) and the actual value (VARCHAR2) recieved
  --------------------------------------------------------------------

PROCEDURE failFormatted(message VARCHAR2,expected VARCHAR2,actual VARCHAR2) IS
 tempStr VARCHAR2(4000);
BEGIN
  IF (expected is not null) or (actual is not null) THEN
    IF (message is not null) THEN
      tempStr := message||'  Expected:['||expected||'] but was: ['||actual||']';
      assert(tempStr,FALSE);
    ELSE
	  tempStr := 'No Error Available -  Expected:['||expected||'] but was: ['||actual||']';
      assert(tempStr,FALSE);
	END IF;
 ELSE
   IF (message is not null) THEN
      assert(message,FALSE);
    ELSE
      assert('No Error Available',FALSE);
	END IF;
 END IF;
END;

  --------------------------------------------------------------------
  -- failFormatted takes in a message to display to the user (if assertion fails) along
  -- with the value that was expected (NUMBER) and the actual value (NUMBER) recieved
  --------------------------------------------------------------------

PROCEDURE failFormatted(message VARCHAR2,expected NUMBER,actual NUMBER) IS
 tempStr VARCHAR2(4000);
BEGIN
  IF (message is not null) THEN
    tempStr := message||'  Expected:['||expected||'] but was: ['||actual||']';
    assert(tempStr,FALSE);
 ELSE
   assert('No Error Available',FALSE);
 END IF;
END;


 ----------------------------
 --- PipeLining APIs
 ----------------------------

  ----------------------------------------------------------------------
  -- addOutput takes a table of JTF_DIAG_OUTPUTS in the form JTF_DIAG_OUTPUTTBL
  -- a varchar2 representing the variable to add and a varchar2 representing
  -- the value to add and this function will add create a new JTF_DIAG_OUTPUTS
  -- object from the variable and value and add this JTF_DIAG_OUTPUTS to
  -- a table of JTF_DIAG_OUTPUTS (JTF_DIAG_OUTPUTTBL) and return this.
  ----------------------------------------------------------------------

 FUNCTION addOutput(outputs IN JTF_DIAG_OUTPUTTBL,
				var IN  VARCHAR2,
				val IN  VARCHAR2) RETURN JTF_DIAG_OUTPUTTBL IS
  tempOutput JTF_DIAG_OUTPUTS;
  tempOutputTable JTF_DIAG_OUTPUTTBL;
  BEGIN
    tempOutputTable := outputs;
    tempOutput := JTF_DIAG_OUTPUTS(VISIBLE,var,val);
    tempOutputTable.extend(1);
    tempOutputTable(tempOutputTable.COUNT) := tempOutput;
	return tempOutputTable;
  EXCEPTION
    WHEN others THEN
	 -- logging here...
	 return outputs;
END;


  ---------------------------------------------------------------------
  -- initialise a outputTable object and return it to the
  -- caller method.   A table of a single empty JTF_DIAG_OUTPUTS
  -- is created and and then removed with the call to trim -
  -- this initializes the collection
  ---------------------------------------------------------------------

FUNCTION initOutputTable RETURN JTF_DIAG_OUTPUTTBL IS
 temp JTF_DIAG_OUTPUTTBL;
BEGIN
 temp := JTF_DIAG_OUTPUTTBL(JTF_DIAG_OUTPUTS(-1,'',''));
 temp.trim;
 return temp;
EXCEPTION
 WHEN others THEN
  return null;
END;


  ----------------------------------------------------------------------
  -- addDependency takes a table of VARCHAR2(4000) in the form
  -- JTF_DIAG_DEPENDTBL, and a varchar2 representing the value to add
  -- and this function will add this value to
  -- a table of VARCHAR2(4000) (JTF_DIAG_DEPENDTBL) and return this.
  ----------------------------------------------------------------------

 FUNCTION addDependency(dependencies IN JTF_DIAG_DEPENDTBL,
			val IN  VARCHAR2) RETURN JTF_DIAG_DEPENDTBL IS
  tempDependency VARCHAR2(4000);
  tempDependencyTable JTF_DIAG_DEPENDTBL;
  BEGIN
    tempDependencyTable := dependencies;
    tempDependency := val;
    tempDependencyTable.extend(1);
    tempDependencyTable(tempDependencyTable.COUNT) := tempDependency;
    return tempDependencyTable;
  EXCEPTION
    WHEN others THEN
	 -- logging here...
	 return dependencies;
END;


  ---------------------------------------------------------------------
  -- initialise a dependencyTable object and return it to the
  -- caller method.   A empty table of VARCHAR2(4000) is created
  ---------------------------------------------------------------------
 FUNCTION initDependencyTable RETURN JTF_DIAG_DEPENDTBL IS
 temp JTF_DIAG_DEPENDTBL;
BEGIN
 temp := JTF_DIAG_DEPENDTBL();
 -- temp.trim;
 return temp;
EXCEPTION
 WHEN others THEN
  return null;
END;


 ----------------------------
 --- Deprecated APIs
 ----------------------------

 PROCEDURE setUpVars(reportClob OUT NOCOPY CLOB) IS
 BEGIN
   setUpVars;
 END;

 PROCEDURE addStringToReport(reportClob IN OUT NOCOPY CLOB,reportStr IN LONG) IS
 BEGIN
   addStringToReport(reportStr);
 END;

   ---------------------------------------------------------------------
  -- initialise a inputTable object and return it to the
  -- caller method.   A table of a single empty JTF_DIAG_TEST_INPUTS
  -- is created and then removed with the call to trim -
  -- this initialises the collection
  ---------------------------------------------------------------------

FUNCTION initialiseInput RETURN JTF_DIAG_TEST_INPUTS IS
BEGIN
 return JTF_DIAG_HELPER_UTILS.initialise_Input_Collection;
END;

  ----------------------------------------------------------------------
  -- addInput takes a table of JTF_DIAG_TEST_INPUT in the form JTF_DIAG_TEST_INPUTS
  -- name, value has tobe passed.Others will take default values.If values provided
  -- JTF_DIAG_TEST_INPUT will be created with the values and JTF_DIAG_TEST_INPUTS
  -- table will be returned.
  ----------------------------------------------------------------------

FUNCTION addInput(inputs IN JTF_DIAG_TEST_INPUTS,
                   name   IN  VARCHAR2,
                   value   IN  VARCHAR2,
                   isConfidential IN VARCHAR2 default 'FALSE',
                   defaultValue IN VARCHAR2 default null,
                   tip IN  VARCHAR2 default null,
                   isMandatory IN  VARCHAR2 default 'FALSE',
                   isDate IN VARCHAR2 default 'FALSE',
                   isNumber IN VARCHAR2 default 'FALSE') RETURN JTF_DIAG_TEST_INPUTS IS
BEGIN
	return JTF_DIAG_HELPER_UTILS.addInput(inputs,name, value, isConfidential, defaultValue, tip, isMandatory, isDate, isNumber);
END;


------------------------------------
-- new APIs for Execution Engine and
-- reporting library
-------------------------------------
FUNCTION GET_SITE_DATE_FORMAT RETURN VARCHAR2 IS
date_format varchar2(100);
BEGIN
APPS.FND_PROFILE.GET('ICX_DATE_FORMAT_MASK',date_format);
return date_format;
END GET_SITE_DATE_FORMAT;

FUNCTION GET_DATE_FORMAT(user_id IN number)  RETURN VARCHAR2 IS
date_format varchar2(50);
BEGIN
date_format:=APPS.FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK',user_id);
return date_format;
END GET_DATE_FORMAT;



END jtf_diagnostic_adaptutil;

/
