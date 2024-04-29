--------------------------------------------------------
--  DDL for Package JTF_DECLARATIVE_DIAGNOSTIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DECLARATIVE_DIAGNOSTIC" AUTHID CURRENT_USER AS
/* $Header: jtfdecl_diag_s.pls 120.2 2005/08/13 01:05:17 minxu noship $ */

    PROCEDURE init;
    PROCEDURE cleanup;

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
			    p_ordernumber IN NUMBER);

    PROCEDURE run_or_validate_count(
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
				DETAILS_STRING IN OUT NOCOPY VARCHAR2,
				ORDERNUMBER IN OUT NOCOPY NUMBER);

    PROCEDURE run_or_validate_rec_norec(
  				appshtname in varchar2,
  				grpname in varchar2,
  				testclsname in varchar2,
  				report OUT NOCOPY JTF_DIAG_REPORT,
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
				STEPTYPE in VARCHAR2);

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
					details_String IN OUT NOCOPY VARCHAR2,
					ORDERNUMBER IN OUT NOCOPY NUMBER,
		 		        sysParamNames IN JTF_VARCHAR2_TABLE_4000,
		 		        sysParamValues IN JTF_VARCHAR2_TABLE_4000);

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
				ORDERNUMBER IN OUT NOCOPY NUMBER);

    PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2);
    PROCEDURE getTestName(str OUT NOCOPY VARCHAR2);
    PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2);
    PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
    FUNCTION  getTestMode RETURN INTEGER;

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
                                P_LUBID         IN NUMBER);

  PROCEDURE GET_TEST_STEPS(
    			p_appid IN VARCHAR2,
    			p_groupName IN VARCHAR2,
    			p_testclassname IN VARCHAR2,
    			p_teststepnames OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
    			p_teststepdesc OUT NOCOPY JTF_VARCHAR2_TABLE_4000);

 PROCEDURE UPDATE_STEP_SEQ(
			P_APPID 	IN VARCHAR2,
			P_GROUPNAME 	IN VARCHAR2,
			P_TESTCLASSNAME IN VARCHAR2,
			P_STEPSEQARRAY	IN JTF_VARCHAR2_TABLE_4000,
                        P_LUBID         IN NUMBER);

 PROCEDURE DELETE_STEPS(
			P_APPID 	IN VARCHAR2,
			P_GROUPNAME 	IN VARCHAR2,
			P_TESTCLASSNAME IN VARCHAR2,
			P_DELSTEPARRAY	IN JTF_VARCHAR2_TABLE_4000);


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
                        P_LUBID                 IN      NUMBER);


  PROCEDURE addStringToClob(reportStr IN LONG, detailsClob IN OUT NOCOPY CLOB);

END;

 

/
