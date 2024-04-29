--------------------------------------------------------
--  DDL for Package Body GMI_RIWHM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_RIWHM_XMLP_PKG" AS
/* $Header: RIWHMB.pls 120.0 2007/12/24 13:28:19 nchinnam noship $ */
  FUNCTION LEXPRMCFFORMULA RETURN VARCHAR2 IS
    W_FROM VARCHAR2(4);
    W_TO VARCHAR2(4);
    D_FROM VARCHAR2(40);
    D_TO VARCHAR2(40);
    R_FROM VARCHAR2(8);
    R_TO VARCHAR2(8);
    C_FROM VARCHAR2(8);
    C_TO VARCHAR2(8);
  BEGIN
    /*SRW.REFERENCE(LEXPRMCP)*/NULL;
    IF SORT_BY = 'Whse' THEN
      LEXPRMCP := ' whse_code between NVL(''' || FROM_WHSE || ''',whse_code) and NVL(''' || TO_WHSE || ''',whse_code)';
    ELSIF SORT_BY = 'Description' THEN
      LEXPRMCP := ' whse_name between NVL(''' || FROM_DESCRIPTION || ''',whse_name) and NVL(''' || TO_DESCRIPTION || ''',whse_name)';
    ELSIF SORT_BY = 'Region' THEN
      LEXPRMCP := ' region_code between NVL(''' || FROM_REGION || ''',region_code) and NVL(''' || TO_REGION || ''',region_code)';
    ELSIF SORT_BY = 'Class' THEN
      LEXPRMCP := ' whse_class between NVL(''' || FROM_CLASS || ''',whse_class) and NVL(''' || TO_CLASS || ''',whse_class)';
    END IF;
    RETURN NULL;
  END LEXPRMCFFORMULA;

  FUNCTION RANGE1FORMULA RETURN VARCHAR2 IS
    RANGEV VARCHAR2(200);
  BEGIN
    IF SORT_BY = 'Whse' THEN
      SELECT
        DECODE(FROM_WHSE
              ,NULL
              ,DECODE(TO_WHSE
                    ,NULL
                    ,' Range : All '
                    ,' Warehouse Range: All - ' || TO_WHSE)
              ,DECODE(TO_WHSE
                    ,NULL
                    ,' Warehouse Range: ' || FROM_WHSE || ' - All '
                    ,' Warehouse Range: ' || FROM_WHSE || ' - ' || TO_WHSE))
      INTO RANGEV
      FROM
        DUAL;
    ELSIF SORT_BY = 'Description' THEN
      SELECT
        DECODE(FROM_DESCRIPTION
              ,NULL
              ,DECODE(TO_DESCRIPTION
                    ,NULL
                    ,' Description Range: All '
                    ,' Description Range: All - ' || TO_DESCRIPTION)
              ,DECODE(TO_DESCRIPTION
                    ,NULL
                    ,' Description Range: ' || FROM_DESCRIPTION || ' - All '
                    ,' Description Range: ' || FROM_DESCRIPTION || ' - ' || TO_DESCRIPTION))
      INTO RANGEV
      FROM
        DUAL;
    ELSIF SORT_BY = 'Region' THEN
      SELECT
        DECODE(FROM_REGION
              ,NULL
              ,DECODE(TO_REGION
                    ,NULL
                    ,' Range : All '
                    ,' Region Range: All - ' || TO_REGION)
              ,DECODE(TO_REGION
                    ,NULL
                    ,' Region Range: ' || FROM_REGION || ' - All '
                    ,' Region Range: ' || FROM_REGION || ' - ' || TO_REGION))
      INTO RANGEV
      FROM
        DUAL;
    ELSIF SORT_BY = 'Class' THEN
      SELECT
        DECODE(FROM_CLASS
              ,NULL
              ,DECODE(TO_CLASS
                    ,NULL
                    ,' Range : All '
                    ,' class Range: All - ' || TO_CLASS)
              ,DECODE(TO_CLASS
                    ,NULL
                    ,' class Range: ' || FROM_CLASS || ' - All '
                    ,' class Range: ' || FROM_CLASS || ' - ' || TO_CLASS))
      INTO RANGEV
      FROM
        DUAL;
    END IF;
    RETURN (RANGEV);
  END RANGE1FORMULA;

  FUNCTION SORTCFFORMULA RETURN VARCHAR2 IS
    SORT1 VARCHAR2(15);
  BEGIN
    IF SORT_BY = 'Whse' THEN
      SELECT
        'Whse'
      INTO SORT1
      FROM
        DUAL;
    ELSIF SORT_BY = 'Description' THEN
      SELECT
        'Description'
      INTO SORT1
      FROM
        DUAL;
    ELSIF SORT_BY = 'Region' THEN
      SELECT
        'Region'
      INTO SORT1
      FROM
        DUAL;
    ELSE
      SELECT
        'Class'
      INTO SORT1
      FROM
        DUAL;
    END IF;
    RETURN (SORT1);
  END SORTCFFORMULA;

  FUNCTION LEX_ORDCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF SORT_BY = 'Whse' THEN
      IF ORDER1 = 'Ascending' THEN
        RETURN ('whse_code asc');
      ELSE
        RETURN ('whse_code desc');
      END IF;
    ELSIF SORT_BY = 'Description' THEN
      IF ORDER1 = 'Ascending' THEN
        RETURN ('whse_name asc ');
      ELSE
        RETURN ('whse_name desc');
      END IF;
    ELSIF SORT_BY = 'Region' THEN
      IF ORDER1 = 'Ascending' THEN
        RETURN ('region_code asc ');
      ELSE
        RETURN ('region_code desc');
      END IF;
    ELSIF SORT_BY = 'Class' THEN
      IF ORDER1 = 'Ascending' THEN
        RETURN ('whse_class asc ');
      ELSE
        RETURN ('whse_class desc');
      END IF;
    END IF;
    RETURN NULL;
  END LEX_ORDCFFORMULA;

  FUNCTION USERCFFORMULA RETURN VARCHAR2 IS
    USERNAME VARCHAR2(100);
  BEGIN
    SELECT
      USER_NAME
    INTO USERNAME
    FROM
      FND_USER
    WHERE USER_ID = GMI_RIWHM_XMLP_PKG.USER_ID;
    RETURN (USERNAME);
  END USERCFFORMULA;

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

  FUNCTION FROM_DESCRIPTIONCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF FROM_DESCRIPTION IS NULL THEN
      SELECT
        'All'
      INTO FROM_DESCRIPTIONCP
      FROM
        DUAL;
    ELSE
      FROM_DESCRIPTIONCP := FROM_DESCRIPTION;
    END IF;
    RETURN (FROM_DESCRIPTIONCP);
  END FROM_DESCRIPTIONCFFORMULA;

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

  FUNCTION TO_DESCRIPTIONCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF TO_DESCRIPTION IS NULL THEN
      SELECT
        'All'
      INTO TO_DESCRIPTIONCP
      FROM
        DUAL;
    ELSE
      TO_DESCRIPTIONCP := TO_DESCRIPTION;
    END IF;
    RETURN (TO_DESCRIPTIONCP);
  END TO_DESCRIPTIONCFFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION FROM_REGIONCFFORMULA RETURN CHAR IS
  BEGIN
    IF FROM_REGION IS NULL THEN
      SELECT
        'All'
      INTO FROM_REGIONCP
      FROM
        DUAL;
    ELSE
      FROM_REGIONCP := FROM_REGION;
    END IF;
    RETURN (FROM_REGIONCP);
  END FROM_REGIONCFFORMULA;

  FUNCTION TO_REGIONCFFORMULA RETURN CHAR IS
  BEGIN
    IF TO_REGION IS NULL THEN
      SELECT
        'All'
      INTO TO_REGIONCP
      FROM
        DUAL;
    ELSE
      TO_REGIONCP := TO_REGION;
    END IF;
    RETURN (TO_REGIONCP);
  END TO_REGIONCFFORMULA;

  FUNCTION FROM_CLASSCFFORMULA RETURN CHAR IS
  BEGIN
    IF FROM_CLASS IS NULL THEN
      SELECT
        'All'
      INTO FROM_CLASSCP
      FROM
        DUAL;
    ELSE
      FROM_CLASSCP := FROM_CLASS;
    END IF;
    RETURN (FROM_CLASSCP);
  END FROM_CLASSCFFORMULA;

  FUNCTION TO_CLASSCFFORMULA RETURN CHAR IS
  BEGIN
    IF TO_CLASS IS NULL THEN
      SELECT
        'All'
      INTO TO_CLASSCP
      FROM
        DUAL;
    ELSE
      TO_CLASSCP := TO_CLASS;
    END IF;
    RETURN (TO_CLASSCP);
  END TO_CLASSCFFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION LEXPRMCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN LEXPRMCP;
  END LEXPRMCP_P;

  FUNCTION FROM_WHSECP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_WHSECP;
  END FROM_WHSECP_P;

  FUNCTION FROM_DESCRIPTIONCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_DESCRIPTIONCP;
  END FROM_DESCRIPTIONCP_P;

  FUNCTION TO_WHSECP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_WHSECP;
  END TO_WHSECP_P;

  FUNCTION TO_DESCRIPTIONCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_DESCRIPTIONCP;
  END TO_DESCRIPTIONCP_P;

  FUNCTION FROM_REGIONCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_REGIONCP;
  END FROM_REGIONCP_P;

  FUNCTION TO_REGIONCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_REGIONCP;
  END TO_REGIONCP_P;

  FUNCTION FROM_CLASSCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_CLASSCP;
  END FROM_CLASSCP_P;

  FUNCTION TO_CLASSCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CLASSCP;
  END TO_CLASSCP_P;

END GMI_RIWHM_XMLP_PKG;


/
