--------------------------------------------------------
--  DDL for Package Body INV_INVTRVLT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRVLT_XMLP_PKG" AS
/* $Header: INVTRVLTB.pls 120.2 2008/01/08 06:31:43 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
       C_DATE_FORMAT varchar2(20);
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        C_DATE_FORMAT := 'DD-MON-YY';
      P_START_DATE_1 := to_char(P_START_DATE,C_DATE_FORMAT);
      P_END_DATE_1 := to_char(P_END_DATE,C_DATE_FORMAT);
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(0
                   ,'Failed srwinit, before report trigger')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(4
                   ,'Failed flexsql item select, before report trigger')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(8
                   ,'Failed flexsql item where, before report trigger')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(9
                   ,'Failed flexsql item order by, before report trigger')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(12
                   ,'Failed flexsql  MKTS select, before report trigger')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(16
                   ,'Failed flexsql MDSP select, before report trigger')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(20
                   ,'Failed flexsql GL# select, before report trigger')*/NULL;
    END;
    IF P_SORT_ID = 1 THEN
      /*SRW.SET_MAXROW('Q_LOT_TRACE_2'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_LOT_TRACE_3'
                    ,0)*/NULL;
    END IF;
    IF P_SORT_ID = 2 THEN
      /*SRW.SET_MAXROW('Q_LOT_TRACE_1'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_LOT_TRACE_3'
                    ,0)*/NULL;
    END IF;
    IF P_SORT_ID = 3 THEN
      /*SRW.SET_MAXROW('Q_LOT_TRACE_1'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_LOT_TRACE_2'
                    ,0)*/NULL;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION P_ITEM_WHEREVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ITEM_WHEREVALIDTRIGGER;
  FUNCTION WHERE_LOT RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(80);
      HI VARCHAR2(80);
    BEGIN
      LO := P_LOT_NUMBER_LO;
      HI := P_LOT_NUMBER_HI;
      IF P_LOT_NUMBER_LO IS NULL AND P_LOT_NUMBER_HI IS NULL THEN
        RETURN ('  ');
      ELSE
        IF P_LOT_NUMBER_LO IS NOT NULL AND P_LOT_NUMBER_HI IS NULL THEN
          RETURN (' and mtln.lot_number >= ''' || LO || ''' ');
        ELSE
          IF P_LOT_NUMBER_LO IS NULL AND P_LOT_NUMBER_HI IS NOT NULL THEN
            RETURN (' and mtln.lot_number <= ''' || HI || ''' ');
          ELSE
            RETURN (' and mtln.lot_number between ''' || LO || '''  and  ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN '  ';
  END WHERE_LOT;
  FUNCTION P_TRACE_FLAGVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_TRACE_FLAGVALIDTRIGGER;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
   P_END_DATE_1 := TRUNC(P_END_DATE);
    P_END_DATE_1 := TO_DATE(TO_CHAR(to_date(P_END_DATE_1,'DD-MON-YYYY')
                                 ,'DD-MON-RRRR') || ' 23:59:59'
                         ,'DD-MON-YYYY HH24:MI:SS');
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(0
                   ,'Failed srwexit, after report trigger')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;
END INV_INVTRVLT_XMLP_PKG;



/
