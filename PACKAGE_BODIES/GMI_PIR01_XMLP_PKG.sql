--------------------------------------------------------
--  DDL for Package Body GMI_PIR01_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PIR01_XMLP_PKG" AS
/* $Header: PIR01B.pls 120.1 2007/12/27 11:29:13 nchinnam noship $ */
  FUNCTION ORDCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF SORT_BY = '2' THEN
      IF ORDER1 = '1' THEN
        RETURN ('1 ASC,12 ASC ,r.whse_code asc');
      ELSE
        RETURN ('1 ASC,12 ASC ,r.whse_code desc');
      END IF;
    ELSIF SORT_BY = '1' THEN
      IF ORDER1 = '1' THEN
        RETURN ('R.abc_code asc');
      ELSE
        RETURN ('R.abc_code desc');
      END IF;
    END IF;
    RETURN 'r.whse_code';
  END ORDCFFORMULA;
  FUNCTION RANGECFFORMULA RETURN VARCHAR2 IS
    X_CLAUSE VARCHAR2(150);
    X_AND VARCHAR2(5);
  BEGIN
    IF (FROM_WHSE IS NOT NULL AND TO_WHSE IS NOT NULL) THEN
      X_CLAUSE := 'r.whse_code>=''' || FROM_WHSE || ''' and r.whse_code<= ''' || TO_WHSE || '''';
    ELSIF (FROM_WHSE IS NOT NULL AND TO_WHSE IS NULL) THEN
      X_CLAUSE := 'r.whse_code>=''' || FROM_WHSE || '''';
    END IF;
    IF X_CLAUSE IS NOT NULL THEN
      X_AND := ' AND ';
    END IF;
    IF (FROM_RANK IS NOT NULL AND TO_RANK IS NOT NULL) THEN
      X_CLAUSE := X_CLAUSE || X_AND || 'abc_code>=''' || FROM_RANK || ''' and abc_code<= ''' || TO_RANK || ''' and r.whse_code>=''' || RFROM_WHSE || ''' and r.whse_code<= ''' || RTO_WHSE || '''';
    ELSIF (FROM_RANK IS NOT NULL AND TO_RANK IS NULL) THEN
      X_CLAUSE := X_CLAUSE || X_AND || 'abc_code >=''' || FROM_RANK || ''' and r.whse_code>=''' || RFROM_WHSE || ''' ';
    END IF;
    IF X_CLAUSE is null then
    X_CLAUSE:='r.whse_code>=''0''';
    end if;
    RETURN X_CLAUSE;
  END RANGECFFORMULA;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF FROM_WHSE > TO_WHSE THEN
      /*SRW.MESSAGE(100
                 ,GGM_MESSAGE.GET('IC_FROM_LTE_THRU'))*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    IF FROM_RANK > TO_RANK THEN
      /*SRW.MESSAGE(100
                 ,GGM_MESSAGE.GET('IC_FROM_LTE_THRU'))*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    IF FROM_WHSE IS NULL THEN
      IF TO_WHSE IS NOT NULL THEN
        /*SRW.MESSAGE(100
                   ,GGM_MESSAGE.GET('IC_FRM_REQD_FOR_THRU'))*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
    END IF;
    IF FROM_RANK IS NULL THEN
      IF TO_RANK IS NOT NULL THEN
        /*SRW.MESSAGE(100
                   ,GGM_MESSAGE.GET('IC_FRM_REQD_FOR_THRU'))*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
    END IF;
    RFROM_WHSE := SUBSTR(FROM_RANK
                        ,INSTR(FROM_RANK
                             ,':') + 1);
    RTO_WHSE := SUBSTR(TO_RANK
                      ,INSTR(TO_RANK
                           ,':') + 1);
    FROM_RANK := SUBSTR(FROM_RANK
                       ,1
                       ,INSTR(FROM_RANK
                            ,':') - 1);
    TO_RANK := SUBSTR(TO_RANK
                     ,1
                     ,INSTR(TO_RANK
                          ,':') - 1);
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION FROM_TOCFFORMULA RETURN VARCHAR2 IS
    RANGEV VARCHAR2(200);
  BEGIN
    IF SORT_BY = '2' THEN
      SELECT
        DECODE(FROM_WHSE
              ,NULL
              ,DECODE(TO_WHSE
                    ,NULL
                    ,' Range  All '
                    ,' Range From: All   Range To: ' || TO_WHSE)
              ,DECODE(TO_WHSE
                    ,NULL
                    ,' Range From ' || FROM_WHSE || '  Range To All '
                    ,' Range From ' || FROM_WHSE || '   Range To ' || TO_WHSE))
      INTO RANGEV
      FROM
        DUAL;
    ELSIF SORT_BY = '1' THEN
      SELECT
        DECODE(FROM_RANK
              ,NULL
              ,DECODE(TO_RANK
                    ,NULL
                    ,' Range  All '
                    ,' Range From: All   Range To: ' || TO_RANK)
              ,DECODE(TO_RANK
                    ,NULL
                    ,' Range From ' || FROM_RANK || '  Range To All '
                    ,' Range From ' || FROM_RANK || '   Range To ' || TO_RANK))
      INTO RANGEV
      FROM
        DUAL;
    END IF;
    RETURN (RANGEV);
  END FROM_TOCFFORMULA;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      select argument2 into order1  from FND_CONCURRENT_REQUESTS
where request_id =P_CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    P_ROWS := 0;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION ORDERCFFORMULA RETURN VARCHAR2 IS
    ORDER2 VARCHAR2(17);
  BEGIN
    IF ORDER1 = '1' THEN
      SELECT
        MEANING
      INTO ORDER2      FROM
        FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_CODE = '1'
        AND LOOKUP_TYPE = 'PI_ORDER';
    ELSIF ORDER1 = '2' THEN
      SELECT
        MEANING
      INTO ORDER2
      FROM
        FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_CODE = '2'
        AND LOOKUP_TYPE = 'PI_ORDER';
    END IF;
    RETURN (ORDER2);
  END ORDERCFFORMULA;
  FUNCTION SORTRETCFFORMULA RETURN VARCHAR2 IS
    SORT1 VARCHAR2(17);
  BEGIN
    IF SORT_BY = '1' THEN
      SELECT
        MEANING
      INTO SORT1
      FROM
        FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_CODE = '1'
        AND LOOKUP_TYPE = 'PI_PIR01_SORT';
    ELSIF SORT_BY = '2' THEN
      SELECT
        MEANING
      INTO SORT1
      FROM
        FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_CODE = '2'
        AND LOOKUP_TYPE = 'PI_PIR01_SORT';
    END IF;
    RETURN (SORT1);
  END SORTRETCFFORMULA;
  FUNCTION SELECTCFFORMULA RETURN VARCHAR2 IS
    SELECT1 VARCHAR2(17);
  BEGIN
    IF SELECT_CRITERIA = '1' THEN
      SELECT
        MEANING
      INTO SELECT1
      FROM
        FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_CODE = '1'
        AND LOOKUP_TYPE = 'PI_SELECTCRITERIA';
    ELSIF SELECT_CRITERIA = '2' THEN
      SELECT
        MEANING
      INTO SELECT1
      FROM
        FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_CODE = '2'
        AND LOOKUP_TYPE = 'PI_SELECTCRITERIA';
    ELSIF SELECT_CRITERIA = '3' THEN
      SELECT
        MEANING
      INTO SELECT1
      FROM
        FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_CODE = '3'
        AND LOOKUP_TYPE = 'PI_SELECTCRITERIA';
    END IF;
    RETURN (SELECT1);
  END SELECTCFFORMULA;
  PROCEDURE GMI_PIR01_XMLP_PKG_HEADER IS
  BEGIN
    NULL;
  END GMI_PIR01_XMLP_PKG_HEADER;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
END GMI_PIR01_XMLP_PKG;


/
