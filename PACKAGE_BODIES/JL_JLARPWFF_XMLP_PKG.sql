--------------------------------------------------------
--  DDL for Package Body JL_JLARPWFF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLARPWFF_XMLP_PKG" AS
/* $Header: JLARPWFFB.pls 120.1 2007/12/25 16:35:09 dwkrishn noship $ */
  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN IS
    BASE_CURR AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES_VL.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES_VL.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES_VL.DESCRIPTION%TYPE;
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    SELECT
      P.BASE_CURRENCY_CODE,
      C.PRECISION,
      C.MINIMUM_ACCOUNTABLE_UNIT,
      C.DESCRIPTION
    INTO BASE_CURR,PREC,MIN_AU,DESCR
    FROM
      AP_SYSTEM_PARAMETERS P,
      FND_CURRENCIES_VL C
    WHERE P.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
    C_BASE_CURRENCY_CODE := BASE_CURR;
    C_BASE_PRECISION := PREC;
    C_BASE_MIN_ACCT_UNIT := MIN_AU;
    C_BASE_DESCRIPTION := DESCR;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_BASE_CURR_DATA;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CUSTOM_INIT;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COVER_PAGE_VALUES;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN IS
    NLS_VOID AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_NA AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_ALL AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    SELECT
      LY.MEANING,
      LN.MEANING,
      L1.DISPLAYED_FIELD,
      L2.DISPLAYED_FIELD,
      L3.DISPLAYED_FIELD
    INTO NLS_YES,NLS_NO,NLS_ALL,NLS_VOID,NLS_NA
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES L1,
      AP_LOOKUP_CODES L2,
      AP_LOOKUP_CODES L3
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND L1.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L1.LOOKUP_CODE = 'ALL'
      AND L2.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND L2.LOOKUP_CODE = 'VOID'
      AND L3.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L3.LOOKUP_CODE = 'NA';
    C_NLS_YES := NLS_YES;
    C_NLS_NO := NLS_NO;
    C_NLS_ALL := NLS_ALL;
    C_NLS_VOID := NLS_VOID;
    C_NLS_NA := NLS_NA;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_APPRVL_NO_DATA');
    C_NLS_NO_DATA_EXISTS := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    C_NLS_END_OF_REPORT := FND_MESSAGE.GET;
    C_NLS_NO_DATA_EXISTS := '*** ' || C_NLS_NO_DATA_EXISTS || ' ***';
    C_NLS_END_OF_REPORT := '*** ' || C_NLS_END_OF_REPORT || ' ***';
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_NLS_STRINGS;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
    BEGIN
      C_REPORT_START_DATE := SYSDATE;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('1'
                   ,'After SRWINIT')*/NULL;
      END IF;
      BEGIN
        P_LOCATION_ID := JG_ZZ_COMPANY_INFO.GET_LOCATION_ID;
        IF (P_DEBUG_SWITCH = 'Y') THEN
          /*SRW.MESSAGE('1'
                     ,'After retrieving LOCATION_ID: ' || TO_CHAR(P_LOCATION_ID))*/NULL;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          /*SRW.MESSAGE(02
                     ,'ERROR unknown Location ID')*/NULL;
          RAISE;
      END;
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('2'
                   ,'After Get_Company_Name')*/NULL;
      END IF;
      IF (GET_BASE_CURR_DATA <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('4'
                   ,'After Get_Base_Curr_Data')*/NULL;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.BREAK*/NULL;
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('20'
                   ,'After SRWEXIT')*/NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_NAME HR_LOCATIONS.GLOBAL_ATTRIBUTE8%TYPE;
  BEGIN
    SELECT
      HR.GLOBAL_ATTRIBUTE8 COMPANY_NAME
    INTO L_NAME
    FROM
      HR_LOCATIONS HR
    WHERE HR.LOCATION_ID = P_LOCATION_ID;
    C_COMPANY_NAME_HEADER := L_NAME;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;

  FUNCTION CF_WHT_AGENT_NUMFORMULA(COMP_PRIMARY_ID_NUMBER IN VARCHAR2
                                  ,COMP_TAX_AUTHORITY_ID IN NUMBER
                                  ,COMP_TAX_AUTHORITY_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
    L_COMPANY_NUM_AGENT_RET VARCHAR2(50);
  BEGIN
    IF P_JURISDICTION_TYPE = 'PROVINCIAL' THEN
      SELECT
        LPAD(SUBSTR(JGEA_C.ID_NUMBER
                   ,1
                   ,13)
            ,13
            ,' ')
      INTO L_COMPANY_NUM_AGENT_RET
      FROM
        JG_ZZ_ENTITY_ASSOC JGEA_C
      WHERE JGEA_C.PRIMARY_ID_NUMBER = COMP_PRIMARY_ID_NUMBER
        AND JGEA_C.ASSOCIATED_ENTITY_ID = COMP_TAX_AUTHORITY_ID
        AND JGEA_C.ID_TYPE = COMP_TAX_AUTHORITY_TYPE;
      RETURN (L_COMPANY_NUM_AGENT_RET);
    ELSE
      RETURN ('');
    END IF;
    RETURN NULL;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,'Company Withholding Agent number not found')*/NULL;
      /*SRW.MESSAGE('7'
                 ,'primary_id_number: ' || COMP_PRIMARY_ID_NUMBER)*/NULL;
      /*SRW.MESSAGE('7'
                 ,'associated_entity_id: ' || TO_CHAR(COMP_TAX_AUTHORITY_ID))*/NULL;
      /*SRW.MESSAGE('7'
                 ,'jgea_c.id_type: ' || COMP_TAX_AUTHORITY_TYPE)*/NULL;
      RETURN NULL;
  END CF_WHT_AGENT_NUMFORMULA;

  FUNCTION CF_SUPP_INSCRIPTIONFORMULA(SUPP_PRIMARY_ID_NUMBER IN VARCHAR2
                                     ,SUPP_TAX_AUTHORITY_ID IN NUMBER
                                     ,SUPP_TAX_AUTHORITY_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
    L_SUPPLIER_PROVINCE_NUMBER VARCHAR2(50);
  BEGIN
    IF P_JURISDICTION_TYPE = 'PROVINCIAL' THEN
      SELECT
        LPAD(SUBSTR(JGEA_S.ID_NUMBER
                   ,1
                   ,13)
            ,13
            ,' ') SUPPLIER_PROVINCE_NUMBER
      INTO L_SUPPLIER_PROVINCE_NUMBER
      FROM
        JG_ZZ_ENTITY_ASSOC JGEA_S
      WHERE JGEA_S.PRIMARY_ID_NUMBER = SUPP_PRIMARY_ID_NUMBER
        AND JGEA_S.ASSOCIATED_ENTITY_ID = SUPP_TAX_AUTHORITY_ID
        AND JGEA_S.ID_TYPE = SUPP_TAX_AUTHORITY_TYPE;
      RETURN (L_SUPPLIER_PROVINCE_NUMBER);
    ELSE
      RETURN ('');
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,'Supplier Inscription Number not found')*/NULL;
      /*SRW.MESSAGE('7'
                 ,'primary_id_number: ' || SUPP_PRIMARY_ID_NUMBER)*/NULL;
      /*SRW.MESSAGE('7'
                 ,'associated_entity_id: ' || TO_CHAR(SUPP_TAX_AUTHORITY_ID))*/NULL;
      /*SRW.MESSAGE('7'
                 ,'jgea_c.id_type: ' || SUPP_TAX_AUTHORITY_TYPE)*/NULL;
      RETURN NULL;
  END CF_SUPP_INSCRIPTIONFORMULA;

  FUNCTION CF_AMT_IN_EXCESSFORMULA RETURN VARCHAR2 IS
    L_EXCESS_AMT VARCHAR2(11);
  BEGIN
    SELECT
      LPAD('0.00'
          ,11
          ,' ')
    INTO L_EXCESS_AMT
    FROM
      DUAL;
    RETURN (L_EXCESS_AMT);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,'Error getting Amount in Excess ')*/NULL;
      RETURN NULL;
  END CF_AMT_IN_EXCESSFORMULA;

  FUNCTION CF_DOCUMENT_AMTFORMULA(DOCUMENT_AMOUNT IN NUMBER) RETURN VARCHAR2 IS
    L_DOCUMENT_AMT VARCHAR2(16);
  BEGIN
    IF P_JURISDICTION_TYPE = 'PROVINCIAL' OR P_JURISDICTION_TYPE = 'FEDERAL' THEN
      L_DOCUMENT_AMT := LPAD(LTRIM(TO_CHAR(ROUND(DOCUMENT_AMOUNT
                                                ,2)
                                          ,'9999999999999.99'))
                            ,16
                            ,' ');
      RETURN (L_DOCUMENT_AMT);
    ELSE
      /*SRW.MESSAGE('7'
                 ,'Jurisdiction Type is ' || P_JURISDICTION_TYPE)*/NULL;
      RETURN ('');
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,SQLERRM)*/NULL;
      /*SRW.MESSAGE('7'
                 ,'Error in Document Amount ' || P_JURISDICTION_TYPE)*/NULL;
      RETURN NULL;
  END CF_DOCUMENT_AMTFORMULA;

  FUNCTION CF_FEDERAL_RECFORMULA(DOCUMENT_DATE IN DATE
                                ,DOCUMENT_NUMBER IN VARCHAR2
                                ,CF_DOCUMENT_AMT IN VARCHAR2
                                ,DGI_TAX_TYPE_CODE IN VARCHAR2
                                ,DGI_TAX_REGIME_CODE IN VARCHAR2
                                ,WITHHOLDING_CODE IN VARCHAR2
                                ,CF_TAXABLE_AMT IN VARCHAR2
                                ,SUPPLIER_CONDITION_CODE IN VARCHAR2
                                ,CF_WH_AMT IN VARCHAR2
                                ,CF_EXEMPT_PERC IN VARCHAR2
                                ,BULLETIN_ISSUE_DATE IN VARCHAR2
                                ,SUPP_TAX_IDENTIFICATION_TYPE IN VARCHAR2
                                ,CUIT_NUMBER IN VARCHAR2
                                ,CF_CERT_NUM IN VARCHAR2) RETURN VARCHAR2 IS
    L_FED_REC VARCHAR2(139);
  BEGIN
    L_FED_REC := P_DOCUMENT_CODE || TO_CHAR(DOCUMENT_DATE
                        ,'DD/MM/RRRR') || DOCUMENT_NUMBER || CF_DOCUMENT_AMT || DGI_TAX_TYPE_CODE || DGI_TAX_REGIME_CODE || WITHHOLDING_CODE || CF_TAXABLE_AMT || TO_CHAR(DOCUMENT_DATE
                        ,'DD/MM/RRRR') || SUPPLIER_CONDITION_CODE || CF_WH_AMT || CF_EXEMPT_PERC || BULLETIN_ISSUE_DATE || SUPP_TAX_IDENTIFICATION_TYPE || RPAD(CUIT_NUMBER
                     ,20
                     ,' ') || CF_CERT_NUM;
    RETURN (L_FED_REC);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,SQLERRM)*/NULL;
      /*SRW.MESSAGE('7'
                 ,'Fed Rec length is ' || TO_CHAR(NVL(LENGTH(L_FED_REC)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Document code length is ' || TO_CHAR(NVL(LENGTH(P_DOCUMENT_CODE)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('7'
                 ,'Doc. date length is ' || TO_CHAR(NVL(LENGTH(TO_CHAR(DOCUMENT_DATE
                                           ,'DD/MM/RRRR'))
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Document number length is ' || TO_CHAR(NVL(LENGTH(DOCUMENT_NUMBER)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Document amount length is ' || TO_CHAR(NVL(LENGTH(CF_DOCUMENT_AMT)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'DGI Type length is ' || TO_CHAR(NVL(LENGTH(DGI_TAX_TYPE_CODE)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'DGI Tax regime length is ' || TO_CHAR(NVL(LENGTH(DGI_TAX_REGIME_CODE)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Withholding code length is ' || TO_CHAR(NVL(LENGTH(WITHHOLDING_CODE)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Taxable Amount length is ' || TO_CHAR(NVL(LENGTH(CF_TAXABLE_AMT)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'WHT date length is ' || TO_CHAR(NVL(LENGTH(TO_CHAR(DOCUMENT_DATE
                                           ,'DD/MM/RRRR'))
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Supp condn length is ' || TO_CHAR(NVL(LENGTH(SUPPLIER_CONDITION_CODE)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Withholding amt length is ' || TO_CHAR(NVL(LENGTH(CF_WH_AMT)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'exemption perc length is ' || TO_CHAR(NVL(LENGTH(CF_EXEMPT_PERC)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'bulletin date length is ' || TO_CHAR(NVL(LENGTH(BULLETIN_ISSUE_DATE)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Supp tax ident length is ' || TO_CHAR(NVL(LENGTH(SUPP_TAX_IDENTIFICATION_TYPE)
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'cuit number length is ' || TO_CHAR(NVL(LENGTH(RPAD(CUIT_NUMBER
                                        ,20
                                        ,' '))
                            ,0)))*/NULL;
      /*SRW.MESSAGE('8'
                 ,'Certificate num length is ' || TO_CHAR(NVL(LENGTH(CF_CERT_NUM)
                            ,0)))*/NULL;
      RETURN NULL;
  END CF_FEDERAL_RECFORMULA;

  FUNCTION CF_PROV_RECFORMULA(DOCUMENT_DATE IN DATE
                             ,DOCUMENT_NUMBER IN VARCHAR2
                             ,CF_DOCUMENT_AMT IN VARCHAR2
                             ,DGI_TAX_TYPE_CODE IN VARCHAR2
                             ,DGI_TAX_REGIME_CODE IN VARCHAR2
                             ,WITHHOLDING_CODE IN VARCHAR2
                             ,CF_TAXABLE_AMT IN VARCHAR2
                             ,SUPPLIER_CONDITION_CODE IN VARCHAR2
                             ,CF_WH_AMT IN VARCHAR2
                             ,CF_EXEMPT_PERC IN VARCHAR2
                             ,BULLETIN_ISSUE_DATE IN VARCHAR2
                             ,SUPP_TAX_IDENTIFICATION_TYPE IN VARCHAR2
                             ,CUIT_NUMBER IN VARCHAR2
                             ,CF_CERT_NUM IN VARCHAR2
                             ,CF_WHT_AGENT_NUM IN VARCHAR2
                             ,CF_SUPP_INSCRIPTION IN VARCHAR2) RETURN VARCHAR2 IS
    L_PROV_REC VARCHAR2(170);
  BEGIN
    L_PROV_REC := P_DOCUMENT_CODE || TO_CHAR(DOCUMENT_DATE
                         ,'DD/MM/RRRR') || DOCUMENT_NUMBER || CF_DOCUMENT_AMT || DGI_TAX_TYPE_CODE || DGI_TAX_REGIME_CODE || WITHHOLDING_CODE || CF_TAXABLE_AMT || TO_CHAR(DOCUMENT_DATE
                         ,'DD/MM/RRRR') || SUPPLIER_CONDITION_CODE || CF_WH_AMT || CF_EXEMPT_PERC || BULLETIN_ISSUE_DATE || SUPP_TAX_IDENTIFICATION_TYPE || RPAD(CUIT_NUMBER
                      ,20
                      ,' ') || CF_CERT_NUM || CF_WHT_AGENT_NUM || CF_SUPP_INSCRIPTION;
    RETURN (L_PROV_REC);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,SQLERRM)*/NULL;
      RETURN NULL;
  END CF_PROV_RECFORMULA;

  FUNCTION CF_ZONAL_RECFORMULA(DGI_TAX_REGIME_CODE IN VARCHAR2
                              ,CUIT_NUMBER IN VARCHAR2
                              ,CF_AMT_IN_EXCESS IN VARCHAR2
                              ,DOCUMENT_DATE IN DATE
                              ,CF_WH_AMT IN VARCHAR2
                              ,CF_CERT_NUM IN VARCHAR2) RETURN VARCHAR2 IS
    L_ZONAL_REC VARCHAR2(60);
  BEGIN
    L_ZONAL_REC := DGI_TAX_REGIME_CODE || RPAD(CUIT_NUMBER
                       ,11
                       ,' ') || CF_AMT_IN_EXCESS || TO_CHAR(DOCUMENT_DATE
                          ,'DD/MM/RRRR') || CF_WH_AMT || CF_CERT_NUM;
    RETURN (L_ZONAL_REC);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,SQLERRM)*/NULL;
      RETURN NULL;
  END CF_ZONAL_RECFORMULA;

  FUNCTION CF_TAXABLE_AMTFORMULA(DOCUMENT_AMOUNT IN NUMBER) RETURN VARCHAR2 IS
    L_TAXABLE_AMT VARCHAR2(14);
  BEGIN
    IF P_JURISDICTION_TYPE = 'PROVINCIAL' OR P_JURISDICTION_TYPE = 'FEDERAL' THEN
      L_TAXABLE_AMT := LPAD(LTRIM(TO_CHAR(ROUND(DOCUMENT_AMOUNT
                                               ,2)
                                         ,'99999999999.99'))
                           ,14
                           ,' ');
      RETURN (L_TAXABLE_AMT);
    ELSE
      /*SRW.MESSAGE('7'
                 ,'Jurisdiction Type is ' || P_JURISDICTION_TYPE)*/NULL;
      RETURN ('');
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,SQLERRM)*/NULL;
      RETURN NULL;
  END CF_TAXABLE_AMTFORMULA;

  FUNCTION CF_WH_AMTFORMULA(WITHHOLDING_AMOUNT IN NUMBER) RETURN VARCHAR2 IS
    L_WH_AMT VARCHAR2(14);
    L_DEC VARCHAR2(1);
  BEGIN
    IF P_JURISDICTION_TYPE = 'PROVINCIAL' OR P_JURISDICTION_TYPE = 'FEDERAL' THEN
      L_WH_AMT := LPAD(LTRIM(TO_CHAR(ROUND(WITHHOLDING_AMOUNT
                                          ,2)
                                    ,'99999999999.99'))
                      ,14
                      ,' ');
    ELSIF P_JURISDICTION_TYPE = 'ZONAL' THEN
      L_WH_AMT := LPAD(LTRIM(TO_CHAR(ROUND(WITHHOLDING_AMOUNT
                                          ,2)
                                    ,'99999999.99'))
                      ,11
                      ,' ');
    END IF;
    RETURN (L_WH_AMT);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,SQLERRM)*/NULL;
      RETURN NULL;
  END CF_WH_AMTFORMULA;

  FUNCTION CF_SPACEFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (' ');
  END CF_SPACEFORMULA;

  FUNCTION CF_CERT_NUMFORMULA(CERTIFICATE_NUMBER IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN (LPAD(TO_CHAR(CERTIFICATE_NUMBER)
               ,14
               ,'0'));
  END CF_CERT_NUMFORMULA;

  FUNCTION CF_EXEMPT_PERCFORMULA(EXEMPTION_PERCENTAGE IN NUMBER) RETURN VARCHAR2 IS
    L_EXEMPT_PERC VARCHAR2(6);
  BEGIN
    IF P_JURISDICTION_TYPE = 'PROVINCIAL' OR P_JURISDICTION_TYPE = 'FEDERAL' THEN
      L_EXEMPT_PERC := LPAD(LTRIM(TO_CHAR(ROUND(EXEMPTION_PERCENTAGE
                                               ,2)
                                         ,'990.99'))
                           ,6
                           ,' ');
      RETURN (L_EXEMPT_PERC);
    ELSE
      /*SRW.MESSAGE('7'
                 ,'Jurisdiction Type is ' || P_JURISDICTION_TYPE)*/NULL;
      RETURN ('');
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('7'
                 ,SQLERRM)*/NULL;
      /*SRW.MESSAGE('7'
                 ,'Error in formatting Exemption Percentage' || P_JURISDICTION_TYPE)*/NULL;
      RETURN NULL;
  END CF_EXEMPT_PERCFORMULA;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_YES;
  END C_NLS_YES_P;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO;
  END C_NLS_NO_P;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_ALL;
  END C_NLS_ALL_P;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO_DATA_EXISTS;
  END C_NLS_NO_DATA_EXISTS_P;

  FUNCTION C_NLS_VOID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_VOID;
  END C_NLS_VOID_P;

  FUNCTION C_NLS_NA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NA;
  END C_NLS_NA_P;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_END_OF_REPORT;
  END C_NLS_END_OF_REPORT_P;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_REPORT_START_DATE;
  END C_REPORT_START_DATE_P;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_CURRENCY_CODE;
  END C_BASE_CURRENCY_CODE_P;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_PRECISION;
  END C_BASE_PRECISION_P;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_MIN_ACCT_UNIT;
  END C_BASE_MIN_ACCT_UNIT_P;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_DESCRIPTION;
  END C_BASE_DESCRIPTION_P;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_CHART_OF_ACCOUNTS_ID;
  END C_CHART_OF_ACCOUNTS_ID_P;

END JL_JLARPWFF_XMLP_PKG;



/
