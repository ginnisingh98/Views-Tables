--------------------------------------------------------
--  DDL for Package JTF_DIAGNOSTIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAGNOSTIC" AUTHID CURRENT_USER AS
/* $Header: jtfdiagnostic_s.pls 120.11.12010000.5 2010/09/15 05:31:11 rudas ship $ */


  -- ----------------------------------------------------------------------
  -- Get all application names registered with the diagnostic framework
  -- ----------------------------------------------------------------------

  procedure GET_APPS(
  		P_APPS OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
            	P_APPNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
            	P_SIZE OUT NOCOPY NUMBER
            	);

  -- ----------------------------------------------------------------------
  -- Get all the group names associated with a particular application
  -- ----------------------------------------------------------------------

  /* 5953806 - changed p_grp_created_by to be p_grp_last_updated_by */
  procedure GET_GROUPS(
  		P_APPNAME in VARCHAR2,
  		P_GROUPNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
  		P_GRP_SENSITIVITY OUT NOCOPY JTF_NUMBER_TABLE,
		P_GRP_LAST_UPDATED_BY OUT NOCOPY JTF_NUMBER_TABLE
  		);

  -- ----------------------------------------------------------------------
  -- Get all the test case information associated with the
  -- group and application
  -- ----------------------------------------------------------------------

  /* 5953806 - changed p_test_created_by to be p_test_last_updated_by */
  procedure GET_TESTS(
  		P_APPNAME IN VARCHAR2,
  		P_GROUPNAME IN VARCHAR2,
  		P_TESTCLASSNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
  		P_TESTTYPES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
  		P_TOTALARGROWS OUT NOCOPY JTF_NUMBER_TABLE,
                P_TST_SENSITIVITY OUT NOCOPY JTF_NUMBER_TABLE,
		P_TEST_LAST_UPDATED_BY OUT NOCOPY JTF_NUMBER_TABLE
  		);

-- deprecated don't use if you have test level sensitivity
  procedure GET_TESTS(
                P_APPNAME IN VARCHAR2,
                P_GROUPNAME IN VARCHAR2,
                P_TESTCLASSNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
                P_TESTTYPES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
                P_TOTALARGROWS OUT NOCOPY JTF_NUMBER_TABLE,
                P_TEST_LAST_UPDATED_BY OUT NOCOPY JTF_NUMBER_TABLE
                );

  -- ----------------------------------------------------------------------
  -- Get all argument information associated with the testclassname,
  -- the groupname and the application name
  -- ----------------------------------------------------------------------

  procedure GET_ARGS(
		P_APPID IN VARCHAR2,
  		P_GROUPNAME IN VARCHAR2,
		P_TESTCLASSNAME IN VARCHAR2,
		P_ARGNAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
		P_ARGVALUES OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
		P_ROWNUMBERS OUT NOCOPY JTF_NUMBER_TABLE,
		P_VALUESETNUM OUT NOCOPY JTF_NUMBER_TABLE
		);

  -- ----------------------------------------------------------------------
  -- Get all the prerequisites for a given group or an application
  -- in anycase there should be an application name received
  -- whether or not it is already an application or not
  -- ----------------------------------------------------------------------

  procedure GET_PREREQS(
  		P_APP_OR_GROUP_NAME IN VARCHAR2,
  		P_APPNAME IN VARCHAR2,
  		P_PREREQ_IDS OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
  		P_PREREQ_NAMES OUT NOCOPY JTF_VARCHAR2_TABLE_4000
  		);


  -- ----------------------------------------------------------------------
  -- Delete all information about an app given an application short name.
  -- This includes all groups, tests related to the groups, all arguments related to
  -- every test in the group and any prereqs
  -- ----------------------------------------------------------------------

  procedure DELETE_APP(
  		P_APP_NAME IN VARCHAR2
  		);

  -- ----------------------------------------------------------------------
  -- Delete all information about a group given an application short name.
  -- This includes all tests related to the group, all arguments related to
  -- every test in the group and any prereqs
  -- ----------------------------------------------------------------------

  procedure DELETE_GROUP(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2
  		);

  -- ----------------------------------------------------------------------
  -- Updates a groups sensitivity in the database
  -- ----------------------------------------------------------------------

  procedure UPDATE_GROUP_SENSITIVITY(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_GRP_SENSITIVITY IN NUMBER,
                P_LUBID IN NUMBER
  		);

  procedure UPDATE_GROUP_SENSITIVITY(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
                P_GRP_SENSITIVITY IN NUMBER
                );

  -- ----------------------------------------------------------------------
  -- Updates a tests sensitivity in the database
  -- ----------------------------------------------------------------------

  procedure UPDATE_TEST_SENSITIVITY(
                P_APP_NAME IN VARCHAR2,
                P_GROUP_NAME IN VARCHAR2,
                P_TEST_NAME IN VARCHAR2,
                P_TST_SENSITIVITY IN NUMBER,
                P_LUBID IN NUMBER
                );

  -- ----------------------------------------------------------------------
  -- Updates a tests end date in the database
  -- ----------------------------------------------------------------------

  procedure UPDATE_TEST_END_DATE(
                P_APP_NAME IN VARCHAR2,
                P_GROUP_NAME IN VARCHAR2,
                P_TEST_NAME IN VARCHAR2,
                P_END_DATE IN DATE default null,
                P_LUBID IN NUMBER
                );

  -- ----------------------------------------------------------------------
  -- Delete all information about a testcase given an application short
  -- name and a group. This includes all all arguments related to
  -- the test in the group and any prereqs
  -- ----------------------------------------------------------------------

   procedure DELETE_TEST(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_TEST_CLASS_NAME IN VARCHAR2
  		);




  -- ----------------------------------------------------------------------
  -- Delete all arguments pertaining to a testcase.
  -- ----------------------------------------------------------------------
   procedure DELETE_ALL_ARGS_FOR_TEST(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_TEST_CLASS_NAME IN VARCHAR2
  		);



  -- ----------------------------------------------------------------------
  -- Delete an argument combination pertaining to a testcase. We use the
  -- argument row number to identify a combination for a test case
  -- ----------------------------------------------------------------------

  procedure DELETE_ARG_SET(
  		P_APP_NAME IN VARCHAR2,
  		P_GROUP_NAME IN VARCHAR2,
  		P_TEST_CLASS_NAME IN VARCHAR2,
  		P_ARG_ROW_NUM IN NUMBER
  		);

  -- ----------------------------------------------------------------------
  -- Update sequences of groups given an appid and the given array of
  -- complete group names which should be valid groupnames
  -- and an array of corresponding sequence numbers
  -- ----------------------------------------------------------------------

  procedure UPDATE_GROUP_SEQ(
		P_APPID IN VARCHAR2,
    		P_GROUPNAMES IN JTF_VARCHAR2_TABLE_4000,
                P_LUBID IN NUMBER);

  procedure UPDATE_GROUP_SEQ(
		P_APPID IN VARCHAR2,
    		P_GROUPNAMES IN JTF_VARCHAR2_TABLE_4000);

  -- ----------------------------------------------------------------------
  -- Update sequences of testname given an appid and groupname and given
  -- array of complete testclassnames which should be valid groupnames
  -- and corresponding array of sequence numbers
  -- ----------------------------------------------------------------------

  procedure UPDATE_TEST_SEQ(
		P_APPID IN VARCHAR2,
		P_GROUPNAME IN VARCHAR2,
		P_TESTCLASSNAMES IN JTF_VARCHAR2_TABLE_4000,
                P_LUBID IN NUMBER);

  procedure UPDATE_TEST_SEQ(
		P_APPID IN VARCHAR2,
		P_GROUPNAME IN VARCHAR2,
		P_TESTCLASSNAMES IN JTF_VARCHAR2_TABLE_4000);

  -- ----------------------------------------------------------------------
  -- Update prereqs of an application or a group within the application.
  -- In either case (app or group), you should provide the appname
  -- and an array of prereqs and the type (1 or 2)
  -- ----------------------------------------------------------------------

  procedure UPDATE_PREREQS(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_SOURCETYPE IN NUMBER,
                P_LUBID IN NUMBER);

  procedure UPDATE_PREREQS(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_SOURCETYPE IN NUMBER);

  -- ----------------------------------------------------------------------
  -- Update argument values of a testcase
  -- You should provide the appname, testclassname, groupname, array of
  -- argument names and corresponding argument values and the rownumber that
  -- it corresponds with on the UI
  -- ----------------------------------------------------------------------

  procedure UPDATE_ARG_VALUES(
		P_TESTCLASSNAME IN VARCHAR2,
		P_GROUPNAME IN VARCHAR2,
		P_APPID IN VARCHAR2,
		P_ARGNAMES IN JTF_VARCHAR2_TABLE_4000,
		P_ARGVALUES IN JTF_VARCHAR2_TABLE_4000,
		P_ROWNUMBER IN NUMBER,
                P_LUBID IN NUMBER
		);

  procedure UPDATE_ARG_VALUES(
		P_TESTCLASSNAME IN VARCHAR2,
		P_GROUPNAME IN VARCHAR2,
		P_APPID IN VARCHAR2,
		P_ARGNAMES IN JTF_VARCHAR2_TABLE_4000,
		P_ARGVALUES IN JTF_VARCHAR2_TABLE_4000,
		P_ROWNUMBER IN NUMBER
		);



  -- ----------------------------------------------------------------------
  -- Insert an app into the framework with or without prereqs
  -- ----------------------------------------------------------------------

  procedure INSERT_APP(
  		P_APPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_LUBID IN NUMBER
  		);

  procedure INSERT_APP(
  		P_APPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000
  		);

  -- ----------------------------------------------------------------------
  -- Insert Group with or without prereqs
  -- ----------------------------------------------------------------------

   procedure INSERT_GRP(
  		P_NEW_GROUP IN VARCHAR2,
 		P_APP IN VARCHAR2,
		P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_LUBID IN NUMBER
		);

   procedure INSERT_GRP(
  		P_NEW_GROUP IN VARCHAR2,
 		P_APP IN VARCHAR2,
		P_PREREQID IN JTF_VARCHAR2_TABLE_4000
		);



  -- ----------------------------------------------------------------------
  -- Insert Group with or without prereqs    - deprecated
  -- ----------------------------------------------------------------------

   procedure INSERT_GROUP(
  		P_NEW_GROUP IN VARCHAR2,
 		P_APP IN VARCHAR2,
		P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
		P_SENSITIVITY IN NUMBER,
                P_LUBID IN NUMBER
		);

   procedure INSERT_GROUP(
  		P_NEW_GROUP IN VARCHAR2,
 		P_APP IN VARCHAR2,
		P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
		P_SENSITIVITY IN NUMBER
		);

  -- ----------------------------------------------------------------------
  -- Insert testcase to a group within an application
  -- ----------------------------------------------------------------------

  procedure GET_GROUP_SENSITIVITY(p_appid in varchar2,
                                p_group_name in varchar2,
                                p_sensitivity out NOCOPY number);

  procedure INSERT_TESTCASE(p_testclassname in varchar2,
                            p_group_name in varchar2,
                            p_appid in varchar2,
                            p_test_type in varchar2,
	                    P_SENSITIVITY IN NUMBER,
	                    p_valid_apps_xml in varchar2,
                            p_end_date in date default null,
                            p_meta_data in varchar2,
	                    p_lubid in number);

  procedure INSERT_TESTCASE(p_testclassname in varchar2,
                            p_group_name in varchar2,
                            p_appid in varchar2,
                            p_test_type in varchar2,
                            p_lubid in number);

  procedure INSERT_TESTCASE(p_testclassname in varchar2,
                            p_group_name in varchar2,
                            p_appid in varchar2,
                            p_test_type in varchar2);


  -- ----------------------------------------------------------------------
  -- Insert argument values for a testcase but one row only
  -- ----------------------------------------------------------------------

  procedure INSERT_ARGVALUE_ROW(p_appid in varchar2,
  				p_group_name in varchar2,
  				p_test_class_name in varchar2,
  				p_arg_names in jtf_varchar2_table_4000,
  				p_arg_values in jtf_varchar2_table_4000,
                                p_lubid in number);

  procedure INSERT_ARGVALUE_ROW(p_appid in varchar2,
  				p_group_name in varchar2,
  				p_test_class_name in varchar2,
  				p_arg_names in jtf_varchar2_table_4000,
  				p_arg_values in jtf_varchar2_table_4000);


  ---------------------------------------------------------------------------
  -- Checks if a group or application is valid. If application, it should
  -- be registered with the diagnostic framework. If group then it should be
  -- registered within the application
  ---------------------------------------------------------------------------

  procedure CHECK_APP_OR_GROUP_VALIDITY(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_SOURCETYPE IN NUMBER);


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
                P_LUBID IN NUMBER);

  procedure PREREQ_INSERTION(
                P_SOURCEID IN VARCHAR2,
                P_SOURCEAPPID IN VARCHAR2,
                P_PREREQID IN JTF_VARCHAR2_TABLE_4000,
                P_SOURCETYPE IN NUMBER);


  ---------------------------------------------------------------------------
  -- Rename a group within an application. This procedure makes sure that the
  -- new  group name does not clash with another name in the same application
  ---------------------------------------------------------------------------

  procedure RENAME_GROUP(
                P_APPID IN VARCHAR2,
                P_GROUPNAME IN VARCHAR2,
                P_NEWGROUPNAME IN VARCHAR2,
                P_LUBID IN NUMBER);


  procedure RENAME_GROUP(
                P_APPID IN VARCHAR2,
                P_GROUPNAME IN VARCHAR2,
                P_NEWGROUPNAME IN VARCHAR2);


  ---------------------------------------------------------------------------
  -- Upload an application row from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_APP(
		P_APPID 	IN VARCHAR2,
     		P_LUDATE 	IN VARCHAR2,
		P_SEC_GRP_ID	IN VARCHAR2,
		P_CUST_MODE	IN VARCHAR2,
		P_OWNER 	IN VARCHAR2);


  ---------------------------------------------------------------------------
  -- Upload an application group row from the ldt file
  ---------------------------------------------------------------------------

  PROCEDURE LOAD_ROW_GROUP(
     		P_APPID 	IN VARCHAR2,
     		P_GROUPNAME	IN VARCHAR2,
		P_SENSITIVITY   IN VARCHAR2,
     		P_LUDATE 	IN VARCHAR2,
		P_SEC_GRP_ID	IN VARCHAR2,
		P_CUST_MODE	IN VARCHAR2,
     		P_OWNER 	IN VARCHAR2);


  ---------------------------------------------------------------------------
  -- Upload an application group test row from the ldt file
  ---------------------------------------------------------------------------

 PROCEDURE LOAD_ROW_TEST(
     		P_APPID 		IN VARCHAR2,
     		P_GROUPNAME		IN VARCHAR2,
     		P_TESTCLASSNAME		IN VARCHAR2,
     		P_TESTTYPE		IN VARCHAR2,
     		P_TOTALARGUMENTROWS	IN VARCHAR2,
		P_SENSITIVITY   	IN VARCHAR2,
     		P_LUDATE 		IN VARCHAR2,
		P_SEC_GRP_ID		IN VARCHAR2,
		P_CUST_MODE		IN VARCHAR2,
                P_VALID_APPLICATIONS	IN CLOB,
                P_END_DATE              IN VARCHAR2,
                P_META_DATA             IN VARCHAR2,
     		P_OWNER 		IN VARCHAR2);


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
     		P_OWNER 		IN VARCHAR2);


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
     		P_OWNER 	IN VARCHAR2);


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
		P_OWNER			IN VARCHAR2);


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
		P_OWNER			IN VARCHAR2);


  ---------------------------------------------------------------------------
  -- Upload a test's alert information row from the ldt file
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
     		P_OWNER 		IN VARCHAR2);


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
     		P_OWNER 		IN VARCHAR2);

  ------------------------------------------------------------
  -- procedure PARSE TEST CLASS NAME
  ------------------------------------------------------------

   procedure PARSE_TESTCLASSNAME(
                        P_TESTCLASSNAME IN VARCHAR2,
                        V_PRODUCT OUT NOCOPY VARCHAR2,
                        V_FILENAME OUT NOCOPY VARCHAR2);

-- ----------------------------------------------------------------------
-- Procedure to seed a test set from the ldt
-- ----------------------------------------------------------------------
  PROCEDURE SEED_TESTSET(
		P_NAME	 	IN VARCHAR2,
		P_DESCRIPTION	IN VARCHAR2,
		P_XML		IN CLOB,
     		P_LUDATE 	IN VARCHAR2,
		P_CUST_MODE	IN VARCHAR2,
		P_OWNER 	IN VARCHAR2);
-- ----------------------------------------------------------------------
-- Procedure to update a test set. The last updated date would be the
-- system date and the user info will be taken from FND_GLOBAL.user_id
-- ----------------------------------------------------------------------
  PROCEDURE UPDATE_TESTSET(
		P_NAME	 		IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_XML			IN CLOB);
-- ----------------------------------------------------------------------
-- Procedure to update a test set providing the last updated information
-- ----------------------------------------------------------------------
  PROCEDURE UPDATE_TESTSET(
		P_NAME	 		IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_XML			IN CLOB,
		P_LAST_UPDATED_BY	IN NUMBER,
     		P_LAST_UPDATED_DATE	IN DATE);
-- ----------------------------------------------------------------------
-- Procedure to insert a test set. The last updated date, creation_date
-- would be the system date and the user info will be taken
-- from FND_GLOBAL.user_id
-- ----------------------------------------------------------------------
  PROCEDURE INSERT_TESTSET(
		P_NAME	 		IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_XML			IN CLOB);
-- ----------------------------------------------------------------------
-- Procedure to insert a test set providing the creation and last updated
-- information
-- ----------------------------------------------------------------------
  PROCEDURE INSERT_TESTSET(
		P_NAME	 		IN VARCHAR2,
		P_DESCRIPTION		IN VARCHAR2,
		P_XML			IN CLOB,
		P_CREATED_BY		IN NUMBER,
     		P_CREATION_DATE		IN DATE,
		P_LAST_UPDATE_LOGIN	IN NUMBER,
		P_LAST_UPDATED_BY	IN NUMBER,
     		P_LAST_UPDATED_DATE	IN DATE);

-- ---------------------------------------------------------------------------------------
-- Procedure to update valid applications for the test. The last updated date would be the
-- system date and the user info will be taken from FND_GLOBAL.user_id
-- ---------------------------------------------------------------------------------------
  PROCEDURE UPDATE_VALID_APPS(
		P_APPSHORTNAME	IN VARCHAR2,
		P_GROUPNAME	IN VARCHAR2,
		P_TESTCLASSNAME	IN VARCHAR2,
                P_VALIDAPPS     IN VARCHAR2);
-- ------------------------------------------------------------------------------------------
-- Procedure to update valid applications for the test providing the last updated information
-- ------------------------------------------------------------------------------------------
  PROCEDURE UPDATE_VALID_APPS(
		P_APPSHORTNAME		IN VARCHAR2,
		P_GROUPNAME		IN VARCHAR2,
		P_TESTCLASSNAME		IN VARCHAR2,
                P_VALIDAPPS     	IN VARCHAR2,
		P_LAST_UPDATED_BY	IN NUMBER,
                P_LAST_UPDATED_DATE	IN DATE);

-- ------------------------------------------------------------------------------------------
-- Function used to validate whether the user is having the privilege to execute the test
-- or not. This function takes sensitivity & valid applications at test level as parameters
-- and checks if user is having the privilege to execute the test
-- ------------------------------------------------------------------------------------------
  FUNCTION VALIDATE_APPLICATIONS(
                 P_SENSITIVITY NUMBER,
                 P_VALID_APPS_XML XMLTYPE)
           RETURN NUMBER;

-- ------------------------------------------------------------------------------------------
-- Function to return an arraylist of custom applications w.r.t seeded application
-- ------------------------------------------------------------------------------------------
  FUNCTION GET_CUSTOM_APPS(SEEDED_APP VARCHAR2)
           RETURN JTF_DIAG_ARRAYLIST;

-- ------------------------------------------------------------------------------------------
-- Function to return an app id from app short name
-- ------------------------------------------------------------------------------------------
  FUNCTION GET_APP_ID(APP_SHORT_NAME VARCHAR2)
           RETURN INTEGER;

-- ------------------------------------------------------------------------------------------
-- Function to return an array of custom applications w.r.t seeded application
-- ------------------------------------------------------------------------------------------
  FUNCTION GET_CUSTOM_APPS_ARRAY(APP_SHORT_NAME VARCHAR2)
           RETURN jtf_varchar2_table_100;

END JTF_DIAGNOSTIC;

/
