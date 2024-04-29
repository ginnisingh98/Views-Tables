--------------------------------------------------------
--  DDL for Package Body PAY_PAYGBP35_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYGBP35_XMLP_PKG" AS
/* $Header: PAYGBP35B.pls 120.0 2008/01/07 15:34:55 srikrish noship $ */
  FUNCTION C_PAY_CONTRIBSFORMULA(SUM_PAY_CONTRIBS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF SUM_PAY_CONTRIBS > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_CONTRIBS / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    RETURN NULL;
  END C_PAY_CONTRIBSFORMULA;

  FUNCTION C_PAY_SSPFORMULA(SUM_PAY_SSP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_SSP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_SSP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_PAY_SSPFORMULA;

  FUNCTION C_PAY_SMPFORMULA(SUM_PAY_SMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_SMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_SMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_PAY_SMPFORMULA;

  FUNCTION C_PAY_GROSSFORMULA(SUM_PAY_GROSS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_GROSS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_GROSS / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_PAY_GROSSFORMULA;

  FUNCTION C_PAY_TAXFORMULA(SUM_PAY_TAX IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_TAX
         ,0) = 0 THEN
        RETURN ('0.00');
      ELSE
        RETURN (TO_CHAR(SUM_PAY_TAX / 100
                      ,'99999999990.00'));
      END IF;
    END;
    RETURN NULL;
  END C_PAY_TAXFORMULA;

  FUNCTION C_PAY_PREV_GROSSFORMULA(SUM_PAY_PREV_GROSS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_PREV_GROSS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_PREV_GROSS / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_PAY_PREV_GROSSFORMULA;

  FUNCTION C_PAY_PREV_TAXFORMULA(SUM_PAY_PREV_TAX IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_PREV_TAX
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_PREV_TAX / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_PAY_PREV_TAXFORMULA;

  FUNCTION C_EOY_CONTRIBSFORMULA(SUM_EOY_CONTRIBS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_CONTRIBS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_CONTRIBS / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_CONTRIBSFORMULA;

  FUNCTION C_EOY_SSPFORMULA(SUM_EOY_SSP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_SSP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_SSP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SSPFORMULA;

  FUNCTION C_EOY_SMPFORMULA(SUM_EOY_SMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_SMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_SMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SMPFORMULA;

  FUNCTION C_EOY_GROSSFORMULA(SUM_EOY_GROSS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_GROSS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_GROSS / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_GROSSFORMULA;

  FUNCTION C_EOY_TAXFORMULA(SUM_EOY_TAX IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_TAX
         ,0) = 0 THEN
        RETURN ('0.0');
      ELSE
        RETURN (TO_CHAR(SUM_EOY_TAX / 100
                      ,'99999999990.00'));
      END IF;
    END;
    RETURN NULL;
  END C_EOY_TAXFORMULA;

  FUNCTION C_EOY_PREV_GROSSFORMULA(SUM_EOY_PREV_GROSS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_PREV_GROSS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_PREV_GROSS / 100));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_PREV_GROSSFORMULA;

  FUNCTION C_EOY_PREV_TAXFORMULA(SUM_EOY_PREV_TAX IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_PREV_TAX
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_PREV_TAX / 100));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_PREV_TAXFORMULA;

  FUNCTION C_TOT_CONTRIBSFORMULA(SUM_TOT_CONTRIBS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_CONTRIBS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_CONTRIBS / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_CONTRIBSFORMULA;

  FUNCTION C_TOT_SSPFORMULA(SUM_TOT_SSP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_SSP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_SSP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_SSPFORMULA;

  FUNCTION C_TOT_SMPFORMULA(SUM_TOT_SMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_SMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_SMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_SMPFORMULA;

  FUNCTION C_TOT_GROSSFORMULA(SUM_TOT_GROSS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_GROSS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_GROSS / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_GROSSFORMULA;

  FUNCTION C_TOT_TAXFORMULA(SUM_TOT_TAX IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_TAX
         ,0) = 0 THEN
        RETURN ('0.00');
      ELSE
        RETURN (TO_CHAR(SUM_TOT_TAX / 100
                      ,'99999999990.00'));
      END IF;
    END;
    RETURN NULL;
  END C_TOT_TAXFORMULA;

  FUNCTION C_TOT_PREV_GROSFORMULA(SUM_TOT_PREV_GROSS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_PREV_GROSS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_PREV_GROSS / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_PREV_GROSFORMULA;

  FUNCTION C_TOT_PREV_TAXFORMULA(SUM_TOT_PREV_TAX IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_PREV_TAX
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_PREV_TAX / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_PREV_TAXFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_BUSINESS_GROUP_ID NUMBER;
      L_LEGISLATIVE_PARAMETERS VARCHAR2(240);
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      SELECT
        A.BUSINESS_GROUP_ID,
        A.REQUEST_ID,
        A.LEGISLATIVE_PARAMETERS,
        A.START_DATE,
        A.EFFECTIVE_DATE,
        TO_NUMBER(SUBSTR(TO_CHAR(A.START_DATE
                                ,'DD-MM-YYYY')
                        ,7
                        ,4))
      INTO L_BUSINESS_GROUP_ID,C_REQUEST_ID,L_LEGISLATIVE_PARAMETERS,C_START_DATE,C_END_DATE,C_DATE_FROM
      FROM
        PAY_PAYROLL_ACTIONS A
      WHERE A.PAYROLL_ACTION_ID = P_PAYROLL_ACTION_ID;
      C_TAX_DISTRICT := PAY_GB_EOY_ARCHIVE.GET_PARAMETER(L_LEGISLATIVE_PARAMETERS
                                                        ,'TAX_REF'
                                                        ,NULL);
      C_PERMIT_NO := PAY_GB_EOY_ARCHIVE.GET_PARAMETER(L_LEGISLATIVE_PARAMETERS
                                                     ,'PERMIT'
                                                     ,NULL);
      C_BUSINESS_GROUP_NAME := HR_REPORTS.GET_BUSINESS_GROUP(L_BUSINESS_GROUP_ID);
      C_DATE_FROM_TO := TO_CHAR(C_DATE_FROM) || '/' || TO_CHAR(C_DATE_FROM + 1);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_NI_VALUEFORMULA(NI_CODE IN VARCHAR2
                            ,SUM_CONTRIBS IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (NI_CODE <> 'P') THEN
      RETURN (SUM_CONTRIBS);
    ELSE
      RETURN (0.0);
    END IF;
    RETURN NULL;
  END C_NI_VALUEFORMULA;

  FUNCTION C_NIP_VALUEFORMULA(NI_CODE IN VARCHAR2
                             ,SUM_CONTRIBS IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (NI_CODE = 'P') THEN
      RETURN (SUM_CONTRIBS);
    ELSE
      RETURN (0.0);
    END IF;
    RETURN NULL;
  END C_NIP_VALUEFORMULA;

  FUNCTION C_EOY_NIPFORMULA(SUM_EOY_CONTRIBS IN NUMBER
                           ,SUM_EOY_NIP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_CONTRIBS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_NIP / 100
                      ,'9999999990.00'));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_NIPFORMULA;

  FUNCTION C_TOT_NIPFORMULA(SUM_TOT_CONTRIBS IN NUMBER
                           ,SUM_TOT_NIP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_CONTRIBS
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_NIP / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_NIPFORMULA;

  FUNCTION C_SMP_NI_COMPFORMULA(SMP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SMP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SMP_NI_COMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SMP_NI_COMPFORMULA;

  FUNCTION C_SMP_RECFORMULA(SMP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SMP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(SMP_REC / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SMP_RECFORMULA;

  FUNCTION C_SSP_RECFORMULA(SSP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SSP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(SSP_REC / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SSP_RECFORMULA;

  FUNCTION C_NIP_CONTRIBSFORMULA(SUM_PAY_CONTRIBS IN NUMBER
                                ,SUM_NIP_CONTRIBS IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF SUM_PAY_CONTRIBS > 0 THEN
        RETURN (TO_CHAR(SUM_NIP_CONTRIBS / 100
                      ,'9999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    RETURN NULL;
  END C_NIP_CONTRIBSFORMULA;

  FUNCTION C_EOY_SMP_RECFORMULA(EOY_SMP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(EOY_SMP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(EOY_SMP_REC / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SMP_RECFORMULA;

  FUNCTION C_EOY_SSP_RECFORMULA(EOY_SSP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(EOY_SSP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(EOY_SSP_REC / 100
                      ,'9999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SSP_RECFORMULA;

  FUNCTION C_EOY_SMP_NI_COMPFORMULA(EOY_SMP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(EOY_SMP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(EOY_SMP_NI_COMP / 100
                      ,'9999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SMP_NI_COMPFORMULA;

  FUNCTION C_SUM_SMP_RECFORMULA(SUM_SMP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_SMP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_SMP_REC / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SUM_SMP_RECFORMULA;

  FUNCTION C_SUM_SMP_NI_COMPFORMULA(SUM_SMP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_SMP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_SMP_NI_COMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SUM_SMP_NI_COMPFORMULA;

  FUNCTION C_SUM_SSP_RECFORMULA(SUM_SSP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_SSP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_SSP_REC / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SUM_SSP_RECFORMULA;

  FUNCTION C_EOY_SPP_BIRTHFORMULA(SUM_EOY_SPP_BIRTH IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_SPP_BIRTH
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_SPP_BIRTH / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SPP_BIRTHFORMULA;

  FUNCTION C_EOY_SAPFORMULA(SUM_EOY_SAP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_SAP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_SAP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SAPFORMULA;

  FUNCTION C_EOY_SPP_ADOPTFORMULA(SUM_EOY_SPP_ADOPT IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_EOY_SPP_ADOPT
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_EOY_SPP_ADOPT / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.0');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SPP_ADOPTFORMULA;

  FUNCTION C_TOT_SAPFORMULA(SUM_TOT_SAP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_SAP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_SAP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_SAPFORMULA;

  FUNCTION C_TOT_SPP_BIRTHFORMULA(SUM_TOT_SPP_BIRTH IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_SPP_BIRTH
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_SPP_BIRTH / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_SPP_BIRTHFORMULA;

  FUNCTION C_TOT_SPP_ADOPTFORMULA(SUM_TOT_SPP_ADOPT IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_TOT_SPP_ADOPT
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_TOT_SPP_ADOPT / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_TOT_SPP_ADOPTFORMULA;

  FUNCTION C_PAY_SAPFORMULA(SUM_PAY_SAP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_SAP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_SAP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_PAY_SAPFORMULA;

  FUNCTION C_PAY_SPPAFORMULA(SUM_PAY_SPP_ADOPT IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_SPP_ADOPT
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_SPP_ADOPT / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_PAY_SPPAFORMULA;

  FUNCTION C_PAY_SPPBFORMULA(SUM_PAY_SPP_BIRTH IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_PAY_SPP_BIRTH
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_PAY_SPP_BIRTH / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_PAY_SPPBFORMULA;

  FUNCTION C_SAP_NI_COMPFORMULA(SAP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SAP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SAP_NI_COMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SAP_NI_COMPFORMULA;

  FUNCTION C_SPP_NI_COMPFORMULA(SPP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SPP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SPP_NI_COMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SPP_NI_COMPFORMULA;

  FUNCTION C_SAP_RECFORMULA(SAP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SAP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(SAP_REC / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SAP_RECFORMULA;

  FUNCTION C_SPP_RECFORMULA(SPP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SPP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(SPP_REC / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SPP_RECFORMULA;

  FUNCTION C_EOY_SAP_RECFORMULA(EOY_SAP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(EOY_SAP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(EOY_SAP_REC / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SAP_RECFORMULA;

  FUNCTION C_EOY_SPP_RECFORMULA(EOY_SPP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(EOY_SPP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(EOY_SPP_REC / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SPP_RECFORMULA;

  FUNCTION C_EOY_SAP_NI_COMPFORMULA(EOY_SAP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(EOY_SAP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(EOY_SAP_NI_COMP / 100
                      ,'9999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SAP_NI_COMPFORMULA;

  FUNCTION C_EOY_SPP_NI_COMPFORMULA(EOY_SPP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(EOY_SPP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(EOY_SPP_NI_COMP / 100
                      ,'9999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_EOY_SPP_NI_COMPFORMULA;

  FUNCTION C_SUM_SAP_RECFORMULA(SUM_SAP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_SAP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_SAP_REC / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SUM_SAP_RECFORMULA;

  FUNCTION C_SUM_SPP_RECFORMULA(SUM_SPP_REC IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_SPP_REC
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_SPP_REC / 100
                      ,'99999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SUM_SPP_RECFORMULA;

  FUNCTION C_SUM_SAP_NI_COMPFORMULA(SUM_SAP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_SAP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_SAP_NI_COMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END C_SUM_SAP_NI_COMPFORMULA;

  FUNCTION CSUM_SPP_NI_COMPFORMULA(SUM_SPP_NI_COMP IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF NVL(SUM_SPP_NI_COMP
         ,0) > 0 THEN
        RETURN (TO_CHAR(SUM_SPP_NI_COMP / 100
                      ,'999999990.00'));
      ELSE
        RETURN ('0.00');
      END IF;
    END;
    RETURN NULL;
  END CSUM_SPP_NI_COMPFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_NI_ARREARSFORMULA(ASSIG_ACT_ID IN NUMBER) RETURN NUMBER IS
    L_NI_ARREARS NUMBER := 0;
  BEGIN
    L_NI_ARREARS := PAY_GB_EOY_ARCHIVE.GET_ARCH_NUM(ASSIG_ACT_ID
                                                   ,'X_NI_ARREARS') / 100;
    RETURN NVL(L_NI_ARREARS
              ,0);
  END C_NI_ARREARSFORMULA;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_REQUEST_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_REQUEST_ID;
  END C_REQUEST_ID_P;

  FUNCTION C_TAX_DISTRICT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TAX_DISTRICT;
  END C_TAX_DISTRICT_P;

  FUNCTION C_PERMIT_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PERMIT_NO;
  END C_PERMIT_NO_P;

  FUNCTION C_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_START_DATE;
  END C_START_DATE_P;

  FUNCTION C_END_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_END_DATE;
  END C_END_DATE_P;

  FUNCTION C_DATE_FROM_P RETURN NUMBER IS
  BEGIN
    RETURN C_DATE_FROM;
  END C_DATE_FROM_P;

  FUNCTION C_DATE_FROM_TO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_FROM_TO;
  END C_DATE_FROM_TO_P;

END PAY_PAYGBP35_XMLP_PKG;

/
