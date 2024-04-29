--------------------------------------------------------
--  DDL for Package Body GHR_GHRCPDFD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_GHRCPDFD_XMLP_PKG" AS
/* $Header: GHRCPDFDB.pls 120.0 2007/12/04 07:58:03 srikrish noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF FILENAME IS NOT NULL THEN
      --DESNAME := FILENAME;
      null;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    apf boolean;
  BEGIN
    apf := afterpform;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    GHR_CPDF_DYNRPT.POPULATE_GHR_CPDF_TEMP(P_AGENCY_CODE || NVL(P_AGENCY_SUBELEMENT
                                              ,'%')
                                          ,P_REPORT_DATE_FROM
                                          ,P_REPORT_DATE_TO
                                          ,FALSE);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
    L_RET_FLAG BOOLEAN;
    P_WARN_FLAG VARCHAR2(1);
    CURSOR C_LOG IS
      SELECT
        '1'
      FROM
        GHR_PROCESS_LOG
      WHERE PROGRAM_NAME like '%' || P_CONC_REQUEST_ID;
  BEGIN
    GHR_CPDF_DYNRPT.CLEANUP_TABLE;
    FOR c_log_rec IN C_LOG LOOP
      P_WARN_FLAG := 'Y';
      EXIT;
    END LOOP;
    IF P_WARN_FLAG = 'Y' THEN
      L_RET_FLAG := FND_CONCURRENT.SET_COMPLETION_STATUS(STATUS => 'WARNING'
                                                        ,MESSAGE => 'Please Look at the Federal Process Log for failed records');
    END IF;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_SUPER_DIFFFORMULA(FIRST_NOA_CODE IN VARCHAR2
                               ,FIRST_ACTION_LA_CODE1 IN VARCHAR2
                               ,FIRST_ACTION_LA_CODE2 IN VARCHAR2
                               ,TO_SUPERVISORY_DIFFERENTIAL IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (FIRST_NOA_CODE = '810' AND (FIRST_ACTION_LA_CODE1 = 'VPH' OR FIRST_ACTION_LA_CODE2 = 'VPH')) THEN
      IF (TO_SUPERVISORY_DIFFERENTIAL IS NULL) THEN
        RETURN ('00000');
      END IF;
    ELSE
      IF (TO_SUPERVISORY_DIFFERENTIAL = 0) THEN
        RETURN (NULL);
      END IF;
    END IF;
    RETURN (LPAD(TO_SUPERVISORY_DIFFERENTIAL
               ,5
               ,'0'));
  END CF_SUPER_DIFFFORMULA;

  FUNCTION CF_RETN_ALLOWFORMULA(FIRST_NOA_CODE IN VARCHAR2
                               ,FIRST_ACTION_LA_CODE1 IN VARCHAR2
                               ,FIRST_ACTION_LA_CODE2 IN VARCHAR2
                               ,TO_RETENTION_ALLOWANCE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (FIRST_NOA_CODE = '810' AND (FIRST_ACTION_LA_CODE1 = 'VPG' OR FIRST_ACTION_LA_CODE2 = 'VPG')) THEN
      IF (TO_RETENTION_ALLOWANCE IS NULL) THEN
        RETURN ('00000');
      END IF;
    ELSE
      IF (TO_RETENTION_ALLOWANCE = 0) THEN
        RETURN (NULL);
      END IF;
    END IF;
    RETURN (LPAD(TO_RETENTION_ALLOWANCE
               ,5
               ,'0'));
  END CF_RETN_ALLOWFORMULA;

END GHR_GHRCPDFD_XMLP_PKG;

/
