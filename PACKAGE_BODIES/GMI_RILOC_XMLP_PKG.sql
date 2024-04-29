--------------------------------------------------------
--  DDL for Package Body GMI_RILOC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_RILOC_XMLP_PKG" AS
/* $Header: RILOCB.pls 120.0 2007/12/24 13:25:08 nchinnam noship $ */
  FUNCTION LEXPRMCFFORMULA RETURN VARCHAR2 IS
    W_FROM VARCHAR2(4);
    W_TO VARCHAR2(4);
    D_FROM VARCHAR2(40);
    D_TO VARCHAR2(40);
  BEGIN
    /*SRW.REFERENCE(LEXPRMCP)*/NULL;
    IF FROM_WHSE IS NULL THEN
      W_FROM := '0';
    ELSE
      W_FROM := FROM_WHSE;
    END IF;
    IF TO_WHSE IS NULL THEN
      W_TO := 'zzzz';
    ELSE
      W_TO := TO_WHSE;
    END IF;
    IF FROM_LOCATION IS NULL THEN
      D_FROM := '0';
    ELSE
      D_FROM := FROM_LOCATION;
    END IF;
    IF TO_LOCATION IS NULL THEN
      D_TO := 'zzzzzzzzzzzzzzzz';
    ELSE
      D_TO := TO_LOCATION;
    END IF;
    IF SORT_BY = 'Whse' THEN
      LEXPRMCP := 'whse_code >=''' || W_FROM || '''  and whse_code <=  ''' || W_TO || '''';
    ELSIF SORT_BY = 'Location' THEN
      LEXPRMCP := 'location >=''' || D_FROM || '''  and location <=  ''' || D_TO || '''';
    END IF;
    RETURN NULL;
  END LEXPRMCFFORMULA;

  FUNCTION LEXORDCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF SORT_BY = 'Whse' THEN
      IF ORDER1 = 'Ascending' THEN
        RETURN ('whse_code asc, location asc');
      ELSE
        RETURN ('whse_code desc, location desc');
      END IF;
    ELSIF SORT_BY = 'Location' THEN
      IF ORDER1 = 'Ascending' THEN
        RETURN ('Location asc ');
      ELSE
        RETURN ('Location desc');
      END IF;
    END IF;
    RETURN 'whse_code';
  END LEXORDCFFORMULA;

  FUNCTION USERCFFORMULA RETURN VARCHAR2 IS
    USERNAME VARCHAR2(100);
  BEGIN
    SELECT
      USER_NAME
    INTO USERNAME
    FROM
      FND_USER
    WHERE USER_ID = GMI_RILOC_XMLP_PKG.USER_ID;
    RETURN (USERNAME);
  END USERCFFORMULA;

  FUNCTION RANGE1CFFORMULA RETURN VARCHAR2 IS
    RANGEV VARCHAR2(200);
  BEGIN
    IF SORT_BY = 'Whse' THEN
      SELECT
        DECODE(FROM_WHSE
              ,NULL
              ,DECODE(TO_WHSE
                    ,NULL
                    ,' Range : All '
                    ,' Range From: All - ' || TO_WHSE)
              ,DECODE(TO_WHSE
                    ,NULL
                    ,' Range From: ' || FROM_WHSE || ' - All '
                    ,' Range From: ' || FROM_WHSE || ' - ' || TO_WHSE))
      INTO RANGEV
      FROM
        DUAL;
    ELSIF SORT_BY = 'Location' THEN
      SELECT
        DECODE(FROM_LOCATION
              ,NULL
              ,DECODE(TO_LOCATION
                    ,NULL
                    ,' Range : All '
                    ,' Range From: All - ' || TO_LOCATION)
              ,DECODE(TO_LOCATION
                    ,NULL
                    ,' Range From: ' || FROM_LOCATION || ' - All '
                    ,' Range From: ' || FROM_LOCATION || ' - ' || TO_LOCATION))
      INTO RANGEV
      FROM
        DUAL;
    END IF;
    RETURN (RANGEV);
  END RANGE1CFFORMULA;

  FUNCTION FROM_LOCATIONCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF FROM_LOCATION IS NULL THEN
      SELECT
        'All'
      INTO FROM_LOCATIONCP
      FROM
        DUAL;
    ELSE
      FROM_LOCATIONCP := FROM_LOCATION;
    END IF;
    RETURN (FROM_LOCATIONCP);
  END FROM_LOCATIONCFFORMULA;

  FUNCTION TO_LOCATIONCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF TO_LOCATION IS NULL THEN
      SELECT
        'All'
      INTO TO_LOCATIONCP
      FROM
        DUAL;
    ELSE
      TO_LOCATIONCP := TO_LOCATION;
    END IF;
    RETURN (TO_LOCATIONCP);
  END TO_LOCATIONCFFORMULA;

  FUNCTION FROM_WHSECFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF FROM_WHSE IS NULL THEN
      SELECT
        'All'
      INTO FROM_WHSECP
      FROM
        DUAL;
    ELSE
      FROM_WHSECP := FROM_WHSE;
    END IF;
    RETURN (FROM_WHSECP);
  END FROM_WHSECFFORMULA;

  FUNCTION TO_WHSECFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF TO_WHSE IS NULL THEN
      SELECT
        'All'
      INTO TO_WHSECP
      FROM
        DUAL;
    ELSE
      TO_WHSECP := TO_WHSE;
    END IF;
    RETURN (TO_WHSECP);
  END TO_WHSECFFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.MESSAGE(100
               ,LEXPRMCP)*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  PROCEDURE HEADER IS
  BEGIN
    NULL;
  END HEADER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION LEXPRMCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN LEXPRMCP;
  END LEXPRMCP_P;

  FUNCTION FROM_LOCATIONCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_LOCATIONCP;
  END FROM_LOCATIONCP_P;

  FUNCTION TO_LOCATIONCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_LOCATIONCP;
  END TO_LOCATIONCP_P;

  FUNCTION FROM_WHSECP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_WHSECP;
  END FROM_WHSECP_P;

  FUNCTION TO_WHSECP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_WHSECP;
  END TO_WHSECP_P;

END GMI_RILOC_XMLP_PKG;


/
