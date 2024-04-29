--------------------------------------------------------
--  DDL for Package Body INV_INVTRACS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRACS_XMLP_PKG" AS
/* $Header: INVTRACSB.pls 120.2 2008/01/08 06:33:08 dwkrishn noship $ */
  /* $Header: INVTRACSB.pls 120.2 2008/01/08 06:33:08 dwkrishn noship $ */
  FUNCTION SORT_COLFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      BATCH VARCHAR2(50);
    BEGIN
      IF P_SORT_ID = 2 THEN
        RETURN ('mtt.transaction_type_name');
      ELSE
        IF P_SORT_ID = 3 THEN
          RETURN ('mtst.transaction_source_type_name');
        ELSE
          IF P_SORT_ID = 4 THEN
            BATCH := 'decode(mta.gl_batch_id,-1,''' || '' || ''')';
            RETURN (BATCH);
          ELSE
            NULL;
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END SORT_COLFORMULA;
  FUNCTION GET_DEBIT(NET_ACTIVITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NET_ACTIVITY > 0 THEN
      RETURN (NET_ACTIVITY);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END GET_DEBIT;
  FUNCTION GET_CREDIT(NET_ACTIVITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NET_ACTIVITY < 0 THEN
      RETURN (NET_ACTIVITY);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END GET_CREDIT;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
     -- P_TO_DATE_DSP := TO_CHAR(P_TO_DATE,'DD-MON-YYYY');
      --P_FROM_DATE_DSP := TO_CHAR(P_FROM_DATE,'DD-MON-YYYY');


    P_FROM_DATE_DSP := TO_CHAR(TO_DATE(P_FROM_DATE
                                  ,'YYYY/MM/DD HH24:MI:SS')
                          ,'DD-MON-RRRR');
    P_TO_DATE_DSP := TO_CHAR(TO_DATE(P_TO_DATE
                                ,'YYYY/MM/DD HH24:MI:SS')
                        ,'DD-MON-RRRR');

      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Error in SRWINIT')*/NULL;
        RAISE;
    END;
    BEGIN
      IF P_SORT_ID = 1 THEN
        NULL;
      ELSE
        P_ITEM_FLEX := 'NULL';
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
      IF P_ACCT_LO IS NOT NULL OR P_ACCT_HI IS NOT NULL THEN
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
  FUNCTION C_CURRENCY_CODEFORMULA(R_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || R_CURRENCY_CODE || ')');
  END C_CURRENCY_CODEFORMULA;
  FUNCTION C_GL_BATCH_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_GL_BATCH_ID IS NOT NULL THEN
      RETURN ('and mta.gl_batch_id  = ogb.gl_batch_id (+)
                         and mta.gl_batch_id = ' || TO_CHAR(P_GL_BATCH_ID));
    ELSE
      IF P_SORT_ID = 4 AND P_GL_BATCH_ID IS NULL THEN
        RETURN ('and mta.gl_batch_id  = ogb.gl_batch_id (+)');
      ELSE
        return (' ');
      END IF;
    END IF;
    RETURN NULL;
  END C_GL_BATCH_WHEREFORMULA;
  FUNCTION C_GL_BATCH_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 4 OR P_GL_BATCH_ID IS NOT NULL THEN
      RETURN (', org_gl_batches ogb');
    ELSE
      return (' ');
    END IF;
    RETURN NULL;
  END C_GL_BATCH_FROMFORMULA;
  FUNCTION C_TYPE_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 2 THEN
      RETURN (', mtl_transaction_types mtt');
    ELSE
      IF P_SORT_ID = 3 THEN
        RETURN (', mtl_txn_source_types mtst');
      ELSE
        return (' ');
      END IF;
    END IF;
    RETURN NULL;
  END C_TYPE_FROMFORMULA;
  FUNCTION C_TYPE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 2 THEN
      RETURN ('and mmt.transaction_type_id = mtt.transaction_type_id');
    ELSE
      IF P_SORT_ID = 3 THEN
        RETURN ('and mtst.transaction_source_type_id = mmt.transaction_source_type_id');
      ELSE
        return (' ');
      END IF;
    END IF;
    RETURN NULL;
  END C_TYPE_WHEREFORMULA;
  FUNCTION C_ITEM_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 1 THEN
      RETURN ('mtl_system_items msi,');
    ELSE
      RETURN ('/* Do not select from mtl_system_items */');
    END IF;
    RETURN NULL;
  END C_ITEM_FROMFORMULA;
  FUNCTION C_ITEM_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 1 THEN
      RETURN ('and    mta.inventory_item_id = msi.inventory_item_id and msi.organization_id
              =  :P_ORG_ID  ');
    ELSE
      NULL;
    END IF;
    RETURN '  ';
  END C_ITEM_WHEREFORMULA;
  FUNCTION C_BATCH_DESCFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 4 OR P_GL_BATCH_ID IS NOT NULL THEN
      RETURN ('ogb.gl_batch_id, ogb.description');
    ELSE
      NULL;
    END IF;
    RETURN NULL;
  END C_BATCH_DESCFORMULA;
  FUNCTION C_ACCT_PADFORMULA(C_ACCT_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_ACCT_PAD);
  END C_ACCT_PADFORMULA;
  FUNCTION C_SORT_PADFORMULA(C_SORT_PAD IN VARCHAR2
                            ,SORT_OPTION IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 1 THEN
      RETURN (C_SORT_PAD);
    ELSE
      RETURN (SORT_OPTION);
    END IF;
    RETURN NULL;
  END C_SORT_PADFORMULA;
  FUNCTION C_DATE_WHEREFORMULA RETURN VARCHAR2 IS
  L_FORMAT VARCHAR2(100):='DD-MON-YYYY HH24:MI:SS';
  BEGIN
    IF P_FROM_DATE_T IS NOT NULL AND P_TO_DATE_T IS NOT NULL THEN
      RETURN ('and mta.transaction_date between ' || 'to_date(''' || P_FROM_DATE_T || ''',''' ||L_FORMAT|| ''')' || ' and ' || 'to_date(''' || P_TO_DATE_T || ''',''' ||L_FORMAT|| ''')');
    ELSE
      IF P_FROM_DATE_T IS NOT NULL AND P_TO_DATE_T IS NULL THEN
        RETURN ('and mta.transaction_date >=  ' || 'to_date(''' || P_FROM_DATE_T || ''',''' ||L_FORMAT|| ''')');
      ELSE
        IF P_FROM_DATE_T IS NULL AND P_TO_DATE_T IS NOT NULL THEN
          RETURN ('and  mta.transaction_date <= ' || 'to_date(''' || P_TO_DATE_T || ''',''' ||L_FORMAT|| ''')');
        ELSE
          RETURN (' ');
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  END C_DATE_WHEREFORMULA;
  FUNCTION C_BATCH_SELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_ID = 4 OR P_GL_BATCH_ID IS NOT NULL THEN
      RETURN ('ogb.gl_batch_id gl_batch_number, ogb.description Batch_desc,');
    ELSE
      RETURN ('0 gl_batch_number, ''xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'' Batch_desc,');
    END IF;
    RETURN NULL;
  END C_BATCH_SELFORMULA;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  L_FORMAT VARCHAR2(100):='DD-MON-YYYY HH24:MI:SS';
  BEGIN

    P_FROM_DATE_T := TO_CHAR(TO_DATE(P_FROM_DATE
                                  ,'YYYY/MM/DD HH24:MI:SS')
                          ,'DD-MON-RRRR HH24:MI:SS');
    P_TO_DATE_T := TO_CHAR(TO_DATE(P_TO_DATE
                                ,'YYYY/MM/DD HH24:MI:SS')
                        ,'DD-MON-RRRR');
    IF (P_TO_DATE_T IS NOT NULL) THEN
      P_TO_DATE_T := TO_CHAR(TO_DATE(P_TO_DATE_T || ' 23:59:59'
                                  ,'DD-MON-RRRR HH24:MI:SS')
                          ,'DD-MON-RRRR HH24:MI:SS');
    ELSE
      P_TO_DATE_T := TO_CHAR(TO_DATE(P_TO_DATE_T
                                  ,'DD-MON-RRRR HH24:MI:SS')
                          ,'DD-MON-RRRR HH24:MI:SS');
    END IF;
    /*SRW.MESSAGE(1112
               ,'from date: ' || P_FROM_DATE || '   to date: ' || P_TO_DATE)*/NULL;
    BEGIN
      IF P_FROM_DATE_T IS NOT NULL AND P_TO_DATE_T IS NOT NULL THEN
        P_DATE_RANGE := 'and (mta.transaction_date) between ' || 'to_date(''' || P_FROM_DATE_T || ''','''|| L_FORMAT ||''')' || ' and ' || 'to_date(''' || P_TO_DATE_T || ''',''' ||L_FORMAT ||''')';
      ELSIF P_FROM_DATE_T IS NOT NULL AND P_TO_DATE_T IS NULL THEN
        P_DATE_RANGE := 'and (mta.transaction_date) >= ' || 'to_date(''' || P_FROM_DATE_T || ''','''|| L_FORMAT|| ''')';
      ELSIF P_FROM_DATE_T IS NULL AND P_TO_DATE_T IS NOT NULL THEN
        P_DATE_RANGE := 'and  (mta.transaction_date) <= ' || 'to_date(''' || P_TO_DATE_T || ''',''' ||L_FORMAT|| ''')';
      ELSE
        P_DATE_RANGE := ' ';
      END IF;
      /*SRW.MESSAGE(1113
                 ,'date range: ' || P_DATE_RANGE)*/NULL;
    END;
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;
END INV_INVTRACS_XMLP_PKG;


/
