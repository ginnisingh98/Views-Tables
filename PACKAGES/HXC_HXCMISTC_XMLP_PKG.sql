--------------------------------------------------------
--  DDL for Package HXC_HXCMISTC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HXCMISTC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXCMISTCS.pls 120.0 2007/12/04 05:39:59 amakrish noship $ */
  P_SORT_OPTION1 VARCHAR2(80);

  P_SORT_OPTION2 VARCHAR2(80);

  P_SORT_OPTION3 VARCHAR2(80);

  P_SORT_OPTION4 VARCHAR2(80);

  P_SORT1_LABEL VARCHAR2(100);

  P_SORT2_LABEL VARCHAR2(100);

  P_SORT3_LABEL VARCHAR2(100);

  P_SORT4_LABEL VARCHAR2(100);

  COL_1 VARCHAR2(100) := 'hou.name';

  COL_2 VARCHAR2(100) := 'hl.location_code';

  COL_3 VARCHAR2(80) := 'ppa.payroll_name';

  COL_4 VARCHAR2(240) := 'ppf.full_name';

  P_ORGANIZATION VARCHAR2(240);

  P_DATE_TO DATE;

  P_DATE_FROM DATE;

  P_APPLICATION VARCHAR2(30);

  P_DEFINE_MISSING VARCHAR2(80);

  P_SELECT_CONDITION VARCHAR2(240);

  P_BUSINESS_GROUP_ID NUMBER;

  P_LOCATION VARCHAR2(80);

  P_PAYROLL_ASSIGNMENT_SET VARCHAR2(80);

  P_PAYROLL VARCHAR2(40);

  P_PERSON_NAME VARCHAR2(80);

  P_PERSON_NUMBER NUMBER;

  P_SUPERVISOR VARCHAR2(40);

  P_SELECT_CONDITION2 VARCHAR2(700);

  P_DEFINE_LABEL VARCHAR2(80);

  P_APPLICATION_LABEL VARCHAR2(80);

  P_PERSON_NAME_LABEL VARCHAR2(80);

  P_PERSON_NUMBER_LABEL VARCHAR2(80);

  P_LOCATION_LABEL VARCHAR2(80);

  P_ORGANIZATION_LABEL VARCHAR2(240);

  P_PAYROLL_LABEL VARCHAR2(80);

  P_ASSIGNMENT_SET_LABEL VARCHAR2(80);

  P_SUPERVISOR_LABEL VARCHAR2(80);

  P_SELECT_CONDITION3 VARCHAR2(40);

  P_DEBUG VARCHAR2(32767);

  P_CONC_REQUEST_ID NUMBER;

  P_PERSON_TYPE VARCHAR2(32767);

  PERSON_TYPE1 VARCHAR2(1000);

  PERSON_TYPE2 VARCHAR2(1000);

  ASSIGNMENT_TYPE1 VARCHAR2(1000);

  P_ASSIGNMENT_TYPE VARCHAR2(1000);

  P_VENDOR_ID VARCHAR2(40);

  P_VENDOR_LABEL VARCHAR2(100);

  P_PERSON_TYPE_LABEL VARCHAR2(80);

  P_ASSIGNMENT_TYPE_LABEL VARCHAR2(80);

  PERSON_TYPE3 VARCHAR2(1000);

  CP_PAYROLL_NAME VARCHAR2(80);

  CP_SCL_TCARD_REQ VARCHAR2(20);

  CP_APPLICATION_SET_ID VARCHAR2(2000);

  CP_TCARD_REQ_ATTR1 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR2 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR3 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR4 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR5 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR6 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR7 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR8 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR9 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR10 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR11 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR12 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR13 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR14 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR15 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR16 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR17 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR18 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR19 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR20 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR21 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR22 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR23 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR24 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR25 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR26 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR27 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR28 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR29 VARCHAR2(2000);

  CP_TCARD_REQ_ATTR30 VARCHAR2(2000);

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_APPLICATIONFORMULA RETURN CHAR;

  PROCEDURE SORT_OPTION(L_SORT_OPTION IN VARCHAR2
                       ,L_SORT_BY OUT NOCOPY VARCHAR2
                       ,L_SORT_LABEL OUT NOCOPY VARCHAR2);

  FUNCTION CF_RESOURCE_PREFFORMULA(PERSON_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION G_START_TIMEGROUPFILTER(APPROVAL_STATUS IN VARCHAR2
                                  ,P_COUNT IN NUMBER
                                  ,RESOURCE_ID1 IN NUMBER) RETURN BOOLEAN;

  FUNCTION G_ROWNUMGROUPFILTER(START_TIME1 IN DATE) RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CP_PAYROLL_NAME_P RETURN VARCHAR2;

  FUNCTION CP_SCL_TCARD_REQ_P RETURN VARCHAR2;

  FUNCTION CP_APPLICATION_SET_ID_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR1_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR2_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR3_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR4_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR5_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR6_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR7_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR8_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR9_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR10_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR11_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR12_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR13_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR14_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR15_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR16_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR17_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR18_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR19_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR20_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR21_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR22_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR23_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR24_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR25_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR26_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR27_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR28_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR29_P RETURN VARCHAR2;

  FUNCTION CP_TCARD_REQ_ATTR30_P RETURN VARCHAR2;

END HXC_HXCMISTC_XMLP_PKG;

/