--------------------------------------------------------
--  DDL for Package Body AR_ARHLVOUT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARHLVOUT_XMLP_PKG" AS
/* $Header: ARHLVOUTB.pls 120.0 2008/01/24 14:53:02 dwkrishn noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
   P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    SELECT
      BAT.BATCH_NAME,
      BAT.ORIGINAL_SYSTEM,
      TRUNC(BAT.CREATION_DATE),
      BAT.LOAD_TYPE,
      BAT.TOTAL_BATCH_RECORDS,
      BAT.TOTAL_RECORDS_IMPORTED,
      BAT.IMPORT_STATUS,
      P_LKP.MEANING,
      A_LKP.MEANING,
      C_LKP.MEANING,
      CP_LKP.MEANING
    INTO P_BATCH_NAME,P_ORIG_SYS,P_CRE_DT,P_LOAD_TYPE,P_TOT_B_REC,P_TOT_REC_IMP,P_IMP_STATUS,P_ACT_PARTIES,P_ACT_ADDR,P_ACT_CTS,P_ACT_CPT
    FROM
      HZ_IMP_BATCH_SUMMARY BAT,
      FND_LOOKUP_VALUES P_LKP,
      FND_LOOKUP_VALUES A_LKP,
      FND_LOOKUP_VALUES C_LKP,
      FND_LOOKUP_VALUES CP_LKP
    WHERE BATCH_ID = P_BATCH_ID
      AND p_lkp.language (+) = USERENV('LANG')
      AND p_lkp.view_application_id (+) = 222
      AND p_lkp.security_group_id (+) = FND_GLOBAL.LOOKUP_SECURITY_GROUP('HZ_IMP_BATCH_DEDUP_ACTIONS',222)
      AND p_lkp.lookup_type (+) = 'HZ_IMP_BATCH_DEDUP_ACTIONS'
      AND p_lkp.lookup_code (+) = BD_ACTION_ON_PARTIES
      AND a_lkp.language (+) = USERENV('LANG')
      AND a_lkp.view_application_id (+) = 222
      AND a_lkp.security_group_id (+) = FND_GLOBAL.LOOKUP_SECURITY_GROUP('HZ_IMP_BATCH_DEDUP_ACTIONS',222)
      AND a_lkp.lookup_type (+) = 'HZ_IMP_BATCH_DEDUP_ACTIONS'
      AND a_lkp.lookup_code (+) = BD_ACTION_ON_ADDRESSES
      AND c_lkp.language (+) = USERENV('LANG')
      AND c_lkp.view_application_id (+) = 222
      AND c_lkp.security_group_id (+) = FND_GLOBAL.LOOKUP_SECURITY_GROUP('HZ_IMP_BATCH_DEDUP_ACTIONS',222)
      AND c_lkp.lookup_type (+) = 'HZ_IMP_BATCH_DEDUP_ACTIONS'
      AND c_lkp.lookup_code (+) = BD_ACTION_ON_CONTACTS
      AND cp_lkp.language (+) = USERENV('LANG')
      AND cp_lkp.view_application_id (+) = 222
      AND cp_lkp.security_group_id (+) = FND_GLOBAL.LOOKUP_SECURITY_GROUP('HZ_IMP_BATCH_DEDUP_ACTIONS',222)
      AND cp_lkp.lookup_type (+) = 'HZ_IMP_BATCH_DEDUP_ACTIONS'
      AND cp_lkp.lookup_code (+) = BD_ACTION_ON_CONTACT_POINTS;
    RETURN (TRUE);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (FALSE);
  END AFTERPFORM;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;
END AR_ARHLVOUT_XMLP_PKG;

/
