--------------------------------------------------------
--  DDL for Package Body WIP_WIPLBOSP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPLBOSP_XMLP_PKG" AS
/* $Header: WIPLBOSPB.pls 120.1 2008/01/31 12:24:20 npannamp noship $ */
  FUNCTION JOB_LIMITER RETURN CHARACTER IS
    LIMIT_JOBS VARCHAR2(500);
  BEGIN
    IF (P_FROM_JOB IS NOT NULL) THEN
      IF (P_TO_JOB IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME BETWEEN ''' || P_FROM_JOB || ''' AND ''' || P_TO_JOB || '''';
      ELSE
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME >= ''' || P_FROM_JOB || '''';
      END IF;
    ELSE
      IF (P_TO_JOB IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME <= ''' || P_TO_JOB || '''';
      ELSE
        LIMIT_JOBS := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_JOBS);
  END JOB_LIMITER;

  FUNCTION C_DJ_LINE_LIMITERFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_FROM_LINE IS NOT NULL) OR (P_TO_LINE IS NOT NULL) THEN
      RETURN ('AND 1 = 2');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_DJ_LINE_LIMITERFORMULA;

  FUNCTION C_ASSEMBLY_LIMITERFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (P_ITEM_WHERE IS NOT NULL) THEN
        RETURN ('AND ');
      ELSE
        RETURN (' ');
      END IF;
    END;
    RETURN NULL;
  END C_ASSEMBLY_LIMITERFORMULA;

  FUNCTION LINE_LIMITER RETURN CHARACTER IS
    LIMIT_LINES VARCHAR2(200);
  BEGIN
    IF (P_FROM_LINE IS NOT NULL) THEN
      IF (P_TO_LINE IS NOT NULL) THEN
        LIMIT_LINES := ' AND WL.LINE_CODE BETWEEN ''' || P_FROM_LINE || ''' AND ''' || P_TO_LINE || '''';
      ELSE
        LIMIT_LINES := ' AND WL.LINE_CODE >= ''' || P_FROM_LINE || '''';
      END IF;
    ELSE
      IF (P_TO_LINE IS NOT NULL) THEN
        LIMIT_LINES := ' AND WL.LINE_CODE <= ''' || P_TO_LINE || '''';
      ELSE
        LIMIT_LINES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_LINES);
  END LINE_LIMITER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
  SELECT fifst.id_flex_num
into p_item_flex_num
FROM fnd_id_flex_structures fifst
WHERE fifst.application_id = 401
AND fifst.id_flex_code = 'MSTK'
AND fifst.enabled_flag = 'Y'
AND fifst.freeze_flex_definition_flag = 'Y'
and rownum<2;

    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

    QTY_PRECISION := wip_common_xmlp_pkg.get_precision(P_qty_precision);
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK" APPL_SHORT_NAME="INV"
                  OUTPUT=":P_ASSEMBLY" MODE="SELECT" DISPLAY="ALL"
                  TABLEALIAS="SI1"')*/NULL;
    IF (P_FROM_ASSEMBLY IS NOT NULL) THEN
      IF (P_TO_ASSEMBLY IS NOT NULL) THEN
        NULL;
      ELSE
        NULL;
      END IF;
    ELSE
      IF (P_TO_ASSEMBLY IS NOT NULL) THEN
        NULL;
      END IF;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION OPEN_PO_ONLY RETURN CHARACTER IS
    OPEN_ONLY VARCHAR2(500);
  BEGIN
    IF (P_OPEN_ONLY = 1) THEN
      OPEN_ONLY := 'and poll.closed_code not in
                       (''FINALLY CLOSED'',''CLOSED'',''CLOSED FOR RECEIVING'')
                       and nvl(poll.cancel_flag,''N'') = ''N''';
    ELSE
      OPEN_ONLY := '  ';
    END IF;
    RETURN (OPEN_ONLY);
  END OPEN_PO_ONLY;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_FROM_ASSEMBLY IS NOT NULL OR P_TO_ASSEMBLY IS NOT NULL THEN
      P_OUTER := ' ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

END WIP_WIPLBOSP_XMLP_PKG;



/
