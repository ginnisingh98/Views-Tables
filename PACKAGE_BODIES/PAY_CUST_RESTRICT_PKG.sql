--------------------------------------------------------
--  DDL for Package Body PAY_CUST_RESTRICT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CUST_RESTRICT_PKG" AS
/* $Header: pecrs01t.pkb 115.1 99/07/17 18:52:11 porting ship $ */
 PROCEDURE UNIQUENESS_CHECK(P_CUSTOMIZED_RESTRICTION_ID IN OUT NUMBER,
                            P_BUSINESS_GROUP_ID                NUMBER,
                            P_LEGISLATION_CODE                 VARCHAR2,

                            P_NAME                             VARCHAR2,
                            P_ROWID                            VARCHAR2,
                            P_MODE                             VARCHAR2) IS
 L_DUMMY VARCHAR2(1);
 CURSOR C_C1 IS
 SELECT 1

 FROM   PAY_CUSTOMIZED_RESTRICTIONS PCR
 WHERE  UPPER(PCR.NAME)    = UPPER(P_NAME)

 AND     nvl(PCR.business_group_id, nvl(P_BUSINESS_GROUP_ID, -9999) )
                  =  nvl(P_BUSINESS_GROUP_ID, -9999)
 AND     nvl(PCR.legislation_code, nvl(P_LEGISLATION_CODE, 'XXX') )
                  =  nvl(P_LEGISLATION_CODE, 'XXX')
 AND    (PCR.ROWID <> P_ROWID OR P_ROWID IS NULL);


 CURSOR C_NEXTVAL IS
 SELECT PAY_CUSTOMIZED_RESTRICTIONS_S.NEXTVAL
 FROM SYS.DUAL;
 BEGIN
  OPEN C_C1;
  FETCH C_C1 INTO L_DUMMY;
  IF C_C1%FOUND THEN
     CLOSE C_C1;
     HR_UTILITY.SET_MESSAGE('801','HR_6030_CUST_UNIQUE_NAME');
     HR_UTILITY.RAISE_ERROR;
  ELSE
    CLOSE C_C1;
     IF P_MODE = 'WVI' THEN /* if the package is called from WVI do not */
      RETURN;               /* select from sequence                     */
     END IF;
    OPEN  C_NEXTVAL;
    FETCH C_NEXTVAL INTO P_CUSTOMIZED_RESTRICTION_ID;
    CLOSE C_NEXTVAL;
  END IF;
 END UNIQUENESS_CHECK;
 PROCEDURE POST_QUERY(P_DISP_FORM_NAME IN OUT VARCHAR2,
                      P_FORM_NAME             VARCHAR2,
                      P_APPLICATION_ID        NUMBER) IS
 CURSOR C_FORM IS
 SELECT F.USER_FORM_NAME
 FROM   FND_FORM_VL F
 WHERE  F.FORM_NAME       = P_FORM_NAME
 AND    F.APPLICATION_ID  = P_APPLICATION_ID;
  BEGIN
   OPEN  C_FORM;
   FETCH C_FORM INTO P_DISP_FORM_NAME;
   CLOSE C_FORM;
  END POST_QUERY;
END PAY_CUST_RESTRICT_PKG;

/
