--------------------------------------------------------
--  DDL for Package Body GMI_RILSM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_RILSM_XMLP_PKG" AS
/* $Header: RILSMB.pls 120.0 2007/12/24 13:27:19 nchinnam noship $ */
  FUNCTION RANGECFFORMULA RETURN VARCHAR2 IS
    RANGE_STATUS VARCHAR2(50);
  BEGIN
    SELECT
      DECODE(FROM_STATUS
            ,NULL
            ,DECODE(TO_STATUS
                  ,NULL
                  ,'Status Range All'
                  ,' Status Range All - ' || TO_STATUS)
            ,DECODE(TO_STATUS
                  ,NULL
                  ,'Status Range ' || FROM_STATUS || ' - All '
                  ,'Status Range ' || FROM_STATUS || ' - ' || TO_STATUS))
    INTO RANGE_STATUS
    FROM
      DUAL;
    RETURN (RANGE_STATUS);
  END RANGECFFORMULA;

  FUNCTION ORDERCFFORMULA RETURN VARCHAR2 IS
    ORDER_CF VARCHAR2(5);
  BEGIN
    SELECT
      'Asc'
    INTO ORDER_CF
    FROM
      DUAL
    WHERE ORDER1 = 'Ascending';
    RETURN (ORDER_CF);
    RETURN 'Asc';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ORDER_CF := 'Desc';
      RETURN (ORDER_CF);
  END ORDERCFFORMULA;

  FUNCTION USERCFFORMULA RETURN VARCHAR2 IS
    USERNAME VARCHAR2(100);
  BEGIN
    SELECT
      USER_NAME
    INTO USERNAME
    FROM
      FND_USER
    WHERE USER_ID = USER_ID_1;
    RETURN (USERNAME);
  END USERCFFORMULA;

  FUNCTION FROM_ITEMCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF FROM_STATUS IS NULL THEN
      SELECT
        'All'
      INTO FROM_STATUSCP
      FROM
        DUAL;
    ELSE
      FROM_STATUSCP := FROM_STATUS;
    END IF;
    RETURN (FROM_STATUSCP);
  END FROM_ITEMCFFORMULA;

  FUNCTION TO_STATUSCFFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF TO_STATUS IS NULL THEN
      SELECT
        'All'
      INTO TO_STATUSCP
      FROM
        DUAL;
    ELSE
      TO_STATUSCP := TO_STATUS;
    END IF;
    RETURN (TO_STATUSCP);
  END TO_STATUSCFFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
  USER_ID_1:=USER_ID;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
          select argument4 into order1  from FND_CONCURRENT_REQUESTS
where request_id =P_CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION FROM_STATUSCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FROM_STATUSCP;
  END FROM_STATUSCP_P;

  FUNCTION TO_STATUSCP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_STATUSCP;
  END TO_STATUSCP_P;

END GMI_RILSM_XMLP_PKG;


/
