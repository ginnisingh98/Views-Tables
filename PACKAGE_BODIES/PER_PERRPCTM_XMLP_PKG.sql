--------------------------------------------------------
--  DDL for Package Body PER_PERRPCTM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPCTM_XMLP_PKG" AS
/* $Header: PERRPCTMB.pls 120.2 2007/12/17 07:23:28 srikrish noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      CURSOR CSR_ORG_STRUCTURE_VERSION(P_ORG_STRUCTURE_VERSION_ID IN NUMBER) IS
        SELECT
          BUSINESS_GROUP_ID
        FROM
          PER_ORG_STRUCTURE_VERSIONS
        WHERE ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID;
      CURSOR CSR_ORGANIZATION(P_ORGANIZATION_ID IN NUMBER) IS
        SELECT
          BUSINESS_GROUP_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;
      V_ORGANIZATION_NAME VARCHAR2(240);
      V_ORGANIZATION_TYPE VARCHAR2(80);
      V_ORG_STRUCTURE_NAME VARCHAR2(30);
      V_ORG_VERSION NUMBER;
      V_VERSION_START_DATE DATE;
      V_VERSION_END_DATE DATE;
      V_LEAV_REASON1 VARCHAR2(80);
      V_LEAV_REASON2 VARCHAR2(80);
      V_LEAV_REASON3 VARCHAR2(80);
      V_LEAV_REASON4 VARCHAR2(80);
      V_LEAV_REASON5 VARCHAR2(80);
      V_LEAV_REASON6 VARCHAR2(80);
    BEGIN
     -- HR_STANDARD.EVENT('BEFORE REPORT');
      IF P_ALTERNATE = 'Y' THEN
        P_LOOKUP_TYPE := 'FR_ENDING_REASON';
        P_REASON_COLUMN := 'P.PDS_INFORMATION2';
      ELSE
        P_LOOKUP_TYPE := 'HR_CWK_TERMINATION_REASONS';
        P_REASON_COLUMN := 'P.TERMINATION_REASON';
      END IF;
      IF (P_ORG_STRUCTURE_VERSION_ID IS NOT NULL) THEN
        OPEN CSR_ORG_STRUCTURE_VERSION(P_ORG_STRUCTURE_VERSION_ID);
        FETCH CSR_ORG_STRUCTURE_VERSION
         INTO
           P_BUSINESS_GROUP_ID;
        CLOSE CSR_ORG_STRUCTURE_VERSION;
      ELSE
        OPEN CSR_ORGANIZATION(P_PARENT_ORGANIZATION_ID);
        FETCH CSR_ORGANIZATION
         INTO
           P_BUSINESS_GROUP_ID;
        CLOSE CSR_ORGANIZATION;
      END IF;
      IF (P_BUSINESS_GROUP_ID IS NOT NULL) THEN
        C_BUSINESS_GROUP_NAME := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
      ELSE
        C_BUSINESS_GROUP_NAME := C_GLOBAL_HIERARCHY;
      END IF;
      HR_REPORTS.GET_ORGANIZATION(P_PARENT_ORGANIZATION_ID
                                 ,V_ORGANIZATION_NAME
                                 ,V_ORGANIZATION_TYPE);
      C_PARENT_ORGANIZATION_NAME := V_ORGANIZATION_NAME;
      IF P_ORG_STRUCTURE_VERSION_ID IS NOT NULL THEN
        HR_REPORTS.GET_ORGANIZATION_HIERARCHY(NULL
                                             ,P_ORG_STRUCTURE_VERSION_ID
                                             ,V_ORG_STRUCTURE_NAME
                                             ,V_ORG_VERSION
                                             ,V_VERSION_START_DATE
                                             ,V_VERSION_END_DATE);
        C_ORG_STRUCTURE_NAME := V_ORG_STRUCTURE_NAME;
      ELSE
        C_ORG_STRUCTURE_NAME := '';
      END IF;
      IF P_PARENT_ORGANIZATION_ID IS NOT NULL THEN
        P_ORG_MATCHING := ' where p.organization_id = :p_parent_organization_id ';
      ELSIF P_ORG_STRUCTURE_VERSION_ID IS NOT NULL THEN
        P_ORG_MATCHING := '  where p.organization_id in ( select organization_id_child from per_org_structure_elements where org_structure_version_id = TO_CHAR(P_ORG_STRUCTURE_VERSION_ID)  union '||
				'select distinct organization_id_parent from per_org_structure_elements  where org_structure_version_id = ' || TO_CHAR(P_ORG_STRUCTURE_VERSION_ID) || ')';
      END IF;
      IF P_LEAV_REASON1 IS NOT NULL THEN
        SELECT
          MEANING
        INTO
          V_LEAV_REASON1
        FROM
          HR_LOOKUPS
        WHERE LOOKUP_TYPE = P_LOOKUP_TYPE
          AND LOOKUP_CODE = P_LEAV_REASON1;
        C_LEAV_REASON1 := V_LEAV_REASON1;
        C_HEAD_REASONS := V_LEAV_REASON1;
      END IF;
      IF P_LEAV_REASON2 IS NOT NULL THEN
        SELECT
          MEANING
        INTO
          V_LEAV_REASON2
        FROM
          HR_LOOKUPS
        WHERE LOOKUP_TYPE = P_LOOKUP_TYPE
          AND LOOKUP_CODE = P_LEAV_REASON2;
        C_LEAV_REASON2 := V_LEAV_REASON2;
        C_HEAD_REASONS := C_HEAD_REASONS || ',' || V_LEAV_REASON2;
      END IF;
      IF P_LEAV_REASON3 IS NOT NULL THEN
        SELECT
          MEANING
        INTO
          V_LEAV_REASON3
        FROM
          HR_LOOKUPS
        WHERE LOOKUP_TYPE = P_LOOKUP_TYPE
          AND LOOKUP_CODE = P_LEAV_REASON3;
        C_LEAV_REASON3 := V_LEAV_REASON3;
        C_HEAD_REASONS := C_HEAD_REASONS || ',' || V_LEAV_REASON3;
      END IF;
      IF P_LEAV_REASON4 IS NOT NULL THEN
        SELECT
          MEANING
        INTO
          V_LEAV_REASON4
        FROM
          HR_LOOKUPS
        WHERE LOOKUP_TYPE = P_LOOKUP_TYPE
          AND LOOKUP_CODE = P_LEAV_REASON4;
        C_LEAV_REASON4 := V_LEAV_REASON4;
        C_HEAD_REASONS := C_HEAD_REASONS || ',' || V_LEAV_REASON4;
      END IF;
      IF P_LEAV_REASON5 IS NOT NULL THEN
        SELECT
          MEANING
        INTO
          V_LEAV_REASON5
        FROM
          HR_LOOKUPS
        WHERE LOOKUP_TYPE = P_LOOKUP_TYPE
          AND LOOKUP_CODE = P_LEAV_REASON5;
        C_LEAV_REASON5 := V_LEAV_REASON5;
        C_HEAD_REASONS := C_HEAD_REASONS || ',' || V_LEAV_REASON5;
      END IF;
      IF P_LEAV_REASON6 IS NOT NULL THEN
        SELECT
          MEANING
        INTO
          V_LEAV_REASON6
        FROM
          HR_LOOKUPS
        WHERE LOOKUP_TYPE = P_LOOKUP_TYPE
          AND LOOKUP_CODE = P_LEAV_REASON6;
        C_LEAV_REASON6 := V_LEAV_REASON6;
        C_HEAD_REASONS := C_HEAD_REASONS || ',' || V_LEAV_REASON6;
      END IF;
    END;
	--Display parameters introduced
	P_DATE_TO_T := to_char(P_DATE_TO,'DD-MON-YYYY');
	P_DATE_FROM_T := to_char(P_DATE_FROM,'DD-MON-YYYY');
	P_SESSION_DATE_T := to_char(P_SESSION_DATE,'DD-MON-YYYY');

    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
 --   HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_SUBTITLE;
  END C_REPORT_SUBTITLE_P;

  FUNCTION C_PARENT_ORGANIZATION_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PARENT_ORGANIZATION_NAME;
  END C_PARENT_ORGANIZATION_NAME_P;

  FUNCTION C_ORG_STRUCTURE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ORG_STRUCTURE_NAME;
  END C_ORG_STRUCTURE_NAME_P;

  FUNCTION C_HEAD_REASONS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_HEAD_REASONS;
  END C_HEAD_REASONS_P;

  FUNCTION C_LEAV_REASON1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_LEAV_REASON1;
  END C_LEAV_REASON1_P;

  FUNCTION C_LEAV_REASON2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_LEAV_REASON2;
  END C_LEAV_REASON2_P;

  FUNCTION C_LEAV_REASON3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_LEAV_REASON3;
  END C_LEAV_REASON3_P;

  FUNCTION C_LEAV_REASON4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_LEAV_REASON4;
  END C_LEAV_REASON4_P;

  FUNCTION C_LEAV_REASON5_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_LEAV_REASON5;
  END C_LEAV_REASON5_P;

  FUNCTION C_LEAV_REASON6_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_LEAV_REASON6;
  END C_LEAV_REASON6_P;

  FUNCTION C_GLOBAL_HIERARCHY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_GLOBAL_HIERARCHY;
  END C_GLOBAL_HIERARCHY_P;

END PER_PERRPCTM_XMLP_PKG;

/