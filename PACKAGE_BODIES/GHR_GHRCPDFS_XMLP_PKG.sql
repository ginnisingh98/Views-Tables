--------------------------------------------------------
--  DDL for Package Body GHR_GHRCPDFS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_GHRCPDFS_XMLP_PKG" AS
/* $Header: GHRCPDFSB.pls 120.0 2007/12/04 08:07:22 srikrish noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    apf boolean;
  BEGIN
    apf := afterpform;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    GHR_CPDF_STATRPT.POPULATE_GHR_CPDF_TEMP(P_AGENCY_CODE || NVL(P_AGENCY_SUBELEMENT
                                               ,'%')
                                           ,P_REPORT_DATE);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF FILENAME IS NOT NULL THEN
      --DESNAME := FILENAME;
      null;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

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
    GHR_CPDF_STATRPT.CLEANUP_TABLE;
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

END GHR_GHRCPDFS_XMLP_PKG;

/
