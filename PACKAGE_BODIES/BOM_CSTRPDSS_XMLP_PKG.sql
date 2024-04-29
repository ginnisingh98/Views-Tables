--------------------------------------------------------
--  DDL for Package Body BOM_CSTRPDSS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRPDSS_XMLP_PKG" AS
/* $Header: CSTRPDSSB.pls 120.2 2008/01/03 03:42:48 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
   apf boolean;
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      apf := AFTERPFORM;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Error in SRWINIT')*/NULL;
        RAISE;
    END;
    BEGIN
      SELECT
        FRV.RESPONSIBILITY_NAME,
        TO_CHAR(FCR.REQUEST_DATE
               ,'YYYY/MM/DD HH24:MI:SS'),
        FAV.APPLICATION_NAME,
        FU.USER_NAME
      INTO CP_RESPONSIBILITY,CP_REQUEST_TIME,CP_APPLICATION,CP_REQUESTED_BY
      FROM
        FND_CONCURRENT_REQUESTS FCR,
        FND_RESPONSIBILITY_VL FRV,
        FND_APPLICATION_VL FAV,
        FND_USER FU
      WHERE FCR.REQUEST_ID = P_CONC_REQUEST_ID
        AND FCR.RESPONSIBILITY_APPLICATION_ID = FRV.APPLICATION_ID
        AND FCR.RESPONSIBILITY_ID = FRV.RESPONSIBILITY_ID
        AND FRV.APPLICATION_ID = FAV.APPLICATION_ID
        AND FU.USER_ID = FCR.REQUESTED_BY;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE(30
                   ,'Failed Request By and Request time Init,No data.')*/NULL;
      WHEN OTHERS THEN
        /*SRW.MESSAGE(31
                   ,'Failed Request By and Request time Init.')*/NULL;
    END;
    BEGIN
      SELECT
        DISTINCT
        XFI.NAME,
        CCG.COST_GROUP,
        CCT.COST_TYPE,
        GLL.CURRENCY_CODE,
        CAH.PERIOD_NAME,
        NVL(FC.PRECISION
           ,2)
      INTO CP_LEGAL_ENTITY,CP_COST_GROUP,CP_COST_TYPE,R_CURRENCY_CODE,CP_PERIOD_NAME,CP_PRECISION
      FROM
        CST_AE_HEADERS CAH,
        XLE_FIRSTPARTY_INFORMATION_V XFI,
        GL_LEDGER_LE_V GLL,
        CST_COST_GROUPS CCG,
        CST_COST_TYPES CCT,
        FND_CURRENCIES FC
      WHERE CAH.LEGAL_ENTITY_ID = XFI.LEGAL_ENTITY_ID
        AND GLL.LEGAL_ENTITY_ID = XFI.LEGAL_ENTITY_ID
        AND GLL.RELATIONSHIP_ENABLED_FLAG = 'Y'
        AND GLL.LEDGER_CATEGORY_CODE = 'PRIMARY'
        AND CAH.COST_GROUP_ID = P_COST_GROUP_ID
        AND CAH.PERIOD_ID = P_PERIOD_ID
        AND CCG.COST_GROUP_ID = CAH.COST_GROUP_ID
        AND CCT.COST_TYPE_ID = P_COST_TYPE_ID
        AND FC.CURRENCY_CODE = GLL.CURRENCY_CODE;
	QTY_PRECISION:=bom_common_xmlp_pkg.get_precision(CP_PRECISION);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE(30
                   ,'Failed in legal entity Init, No data.')*/NULL;
      WHEN OTHERS THEN
        /*SRW.MESSAGE(31
                   ,'Failed in legal entity Init.')*/NULL;
    END;
    BEGIN
      IF P_WIP = 2 THEN
        IF P_SORT_ID = 1 THEN
          NULL;
        ELSE
          PLEX_ITEM_FLEX := ' ';
        END IF;
      ELSE
        PLEX_ITEM_FLEX := ' ';
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Error in MSTK')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'Error in GL#')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_ACCT_FROM IS NOT NULL OR P_ACCT_TO IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(4
                   ,'Error in GL#')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Error in SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_ACCT_PADFORMULA(C_ACCT_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ACCT_PAD);
  END C_ACCT_PADFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_WIP = 2 THEN
        IF P_SORT_ID = 2 THEN
          P_SORT_OPTION := 'caetv.description';
        ELSIF P_SORT_ID = 3 THEN
          P_SORT_OPTION := 'mtst.transaction_source_type_name';
        ELSE
          P_SORT_OPTION := '(TO_CHAR(3)) ';
        END IF;
      ELSE
        P_SORT_OPTION := '(TO_CHAR(3)) ';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in p_sort_option')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_WIP = 2 THEN
        IF P_SORT_ID = 1 THEN
          P_MAT_TABLE_FROM := ', mtl_system_items msi';
        ELSIF P_SORT_ID = 2 THEN
          P_MAT_TABLE_FROM := ', cst_accounting_event_types_v caetv';
        ELSIF P_SORT_ID = 3 THEN
          P_MAT_TABLE_FROM := ', mtl_txn_source_types mtst';
        ELSE
          P_MAT_TABLE_FROM := ' ';
        END IF;
      ELSE
        P_MAT_TABLE_FROM := ' ';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in p_mat_or_wip_table_from')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_WIP = 2 THEN
        IF P_SORT_ID = 1 THEN
          P_MAT_WHERE := 'AND mmt.inventory_item_id = msi.inventory_item_id
                                              AND mmt.organization_id = msi.organization_id';
        ELSIF P_SORT_ID = 2 THEN
          P_MAT_WHERE := 'AND caetv.transaction_type_id = mmt.transaction_type_id
                                     AND caetv.transaction_action_id = mmt.transaction_action_id
                                     AND caetv.transaction_type_flag = ''' || 'INV' || '''';
        ELSIF P_SORT_ID = 3 THEN
          P_MAT_WHERE := 'AND mmt.transaction_source_type_id = mtst.transaction_source_type_id';
        ELSE
          P_MAT_WHERE := ' ';
        END IF;
      ELSE
        P_MAT_WHERE := ' ';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in  p_mat_or_wip_where')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_WIP = 2 THEN
        IF P_SORT_ID = 1 THEN
          P_RCV_TABLE_FROM := ', mtl_system_items msi
                                                       , rcv_shipment_lines rsl';
        ELSE
          P_RCV_TABLE_FROM := ' ';
        END IF;
      ELSE
        P_RCV_TABLE_FROM := ' ';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in p_rcv_table_from')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_WIP = 2 THEN
        IF P_SORT_ID = 1 THEN
          P_RCV_WHERE := 'AND rt.shipment_line_id = rsl.shipment_line_id
                                              AND rsl.item_id = msi.inventory_item_id(+)
                                              AND cah.organization_id = msi.organization_id';
        ELSE
          P_RCV_WHERE := ' ';
        END IF;
      ELSE
        P_RCV_WHERE := ' ';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in  p_rcv_where')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  --PROCEDURE FORMAT_QUANTITY(P_PRECISION IN NUMBER) IS
  --BEGIN
  --  SRW.ATTR.MASK := SRW.FORMATMASK_ATTR;
  --  IF P_PRECISION = 0 THEN
  --    SRW.ATTR.FORMATMASK := '-NNN,NNN,NNN,NN0';
  --  ELSIF P_PRECISION = 1 THEN
  --    SRW.ATTR.FORMATMASK := '-NNN,NNN,NNN,NN0.0';
  --  ELSIF P_PRECISION = 3 THEN
  --    SRW.ATTR.FORMATMASK := '-NN,NNN,NNN,NN0.000';
  --  ELSIF P_PRECISION = 4 THEN
  --    SRW.ATTR.FORMATMASK := '-N,NNN,NNN,NN0.0000';
  --  ELSIF P_PRECISION = 5 THEN
  --    SRW.ATTR.FORMATMASK := '-NNN,NNN,NN0.00000';
  --  ELSIF P_PRECISION = 6 THEN
  --    SRW.ATTR.FORMATMASK := '-NN,NNN,NN0.000000';
  --  ELSIF P_PRECISION = 7 THEN
  --    SRW.ATTR.FORMATMASK := '-NNNNNNNNNNN0';
  --  ELSIF P_PRECISION = 8 THEN
  --    SRW.ATTR.FORMATMASK := '-NNNNNNNNNNN0.0';
  --  ELSIF P_PRECISION = 9 THEN
  --    SRW.ATTR.FORMATMASK := '-NNNNNNNNNN0.00';
  --  ELSIF P_PRECISION = 10 THEN
  --    SRW.ATTR.FORMATMASK := '-NNNNNNNNNN0.000';
  --  ELSIF P_PRECISION = 11 THEN
  --    SRW.ATTR.FORMATMASK := '-NNNNNNNNN0.0000';
  --  ELSIF P_PRECISION = 12 THEN
  --    SRW.ATTR.FORMATMASK := '-NNNNNNNN0.00000';
  --  ELSIF P_PRECISION = 13 THEN
  --    SRW.ATTR.FORMATMASK := '-NNNNNNN0.000000';
  --  ELSE
  --    SRW.ATTR.FORMATMASK := '-NNN,NNN,NNN,NN0.00';
  --  END IF;
    /*SRW.SET_ATTR(0
                ,SRW.ATTR)*/
  --              NULL;
  --END FORMAT_QUANTITY;

  FUNCTION CF_NET_ACTIVITY_RFORMULA(NET_ACTIVITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(NET_ACTIVITY
                ,CP_PRECISION));
  END CF_NET_ACTIVITY_RFORMULA;

  FUNCTION CF_SUM_CREDITS_RFORMULA(SUM_CREDITS IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(SUM_CREDITS
                ,CP_PRECISION));
  END CF_SUM_CREDITS_RFORMULA;

  FUNCTION CF_SUM_DEBITS_RFORMULA(SUM_DEBITS IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(SUM_DEBITS
                ,CP_PRECISION));
  END CF_SUM_DEBITS_RFORMULA;

  FUNCTION CF_ACCT_TOT_RFORMULA(C_ACCT_TOT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(C_ACCT_TOT
                ,CP_PRECISION));
  END CF_ACCT_TOT_RFORMULA;

  FUNCTION CF_CR_ACCT_TOT_RFORMULA(C_CR_ACCT_TOT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(C_CR_ACCT_TOT
                ,CP_PRECISION));
  END CF_CR_ACCT_TOT_RFORMULA;

  FUNCTION CF_DR_ACCT_TOT_RFORMULA(C_DR_ACCT_TOT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(C_DR_ACCT_TOT
                ,CP_PRECISION));
  END CF_DR_ACCT_TOT_RFORMULA;

  FUNCTION CF_CR_TOT_RFORMULA(C_CR_TOT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(C_CR_TOT
                ,CP_PRECISION));
  END CF_CR_TOT_RFORMULA;

  FUNCTION CF_DR_TOT_RFORMULA(C_DR_TOT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(C_DR_TOT
                ,CP_PRECISION));
  END CF_DR_TOT_RFORMULA;

  FUNCTION CF_REPORT_TOT_RFORMULA(C_REPORT_TOT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(C_REPORT_TOT
                ,CP_PRECISION));
  END CF_REPORT_TOT_RFORMULA;

  FUNCTION CP_RESPONSIBILITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_RESPONSIBILITY;
  END CP_RESPONSIBILITY_P;

  FUNCTION CP_REQUEST_TIME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REQUEST_TIME;
  END CP_REQUEST_TIME_P;

  FUNCTION CP_APPLICATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_APPLICATION;
  END CP_APPLICATION_P;

  FUNCTION CP_REQUESTED_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REQUESTED_BY;
  END CP_REQUESTED_BY_P;

  FUNCTION CP_LEGAL_ENTITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LEGAL_ENTITY;
  END CP_LEGAL_ENTITY_P;

  FUNCTION CP_ACCT_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ACCT_ID;
  END CP_ACCT_ID_P;

  FUNCTION CP_COST_GROUP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COST_GROUP;
  END CP_COST_GROUP_P;

  FUNCTION CP_COST_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COST_TYPE;
  END CP_COST_TYPE_P;

  FUNCTION R_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN R_CURRENCY_CODE;
  END R_CURRENCY_CODE_P;

  FUNCTION CP_PERIOD_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PERIOD_NAME;
  END CP_PERIOD_NAME_P;

  FUNCTION CP_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN CP_PRECISION;
  END CP_PRECISION_P;

  FUNCTION C_item(C_item_field_p varchar2) RETURN varchar2 is
BEGIN
IF p_wip = 2
THEN
  IF P_sort_id = 1
  THEN

    RETURN(C_item_field_p);
  ELSE
    RETURN(NULL);
  END IF;
ELSE
  RETURN(NULL);
END IF;
 END C_item;

END BOM_CSTRPDSS_XMLP_PKG;


/
