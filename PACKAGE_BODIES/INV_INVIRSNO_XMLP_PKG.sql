--------------------------------------------------------
--  DDL for Package Body INV_INVIRSNO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRSNO_XMLP_PKG" AS
/* $Header: INVIRSNOB.pls 120.1 2007/12/25 10:33:59 dwkrishn noship $ */
  FUNCTION WHERE_SERIAL_NUM RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(30);
      HI VARCHAR2(30);
    BEGIN
      LO := P_SERIAL_LO;
      HI := P_SERIAL_HI;
      IF P_SERIAL_LO IS NULL AND P_SERIAL_HI IS NULL THEN
        RETURN (' ');
      ELSE
        IF P_SERIAL_LO IS NOT NULL AND P_SERIAL_HI IS NULL THEN
          RETURN ('  and msn.serial_number >= ''' || LO || ''' ');
        ELSE
          IF P_SERIAL_LO IS NULL AND P_SERIAL_HI IS NOT NULL THEN
            RETURN (' and msn.serial_number <= ''' || HI || ''' ');
          ELSE
            RETURN (' and  msn.serial_number between ''' || LO || ''' and ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_SERIAL_NUM;

  FUNCTION WHERE_VENDOR RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(30);
      HI VARCHAR2(30);
    BEGIN
      LO := P_VENDOR_LO;
      HI := P_VENDOR_HI;
      IF P_VENDOR_LO IS NULL AND P_VENDOR_HI IS NULL THEN
        RETURN (' ');
      ELSE
        IF P_VENDOR_LO IS NOT NULL AND P_VENDOR_HI IS NULL THEN
          RETURN (' and pov.vendor_name >= ''' || LO || ''' ');
        ELSE
          IF P_VENDOR_LO IS NULL AND P_VENDOR_HI IS NOT NULL THEN
            RETURN (' and pov.vendor_name >= ''' || HI || ''' ');
          ELSE
            RETURN (' and pov.vendor_name between ''' || LO || ''' and ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_VENDOR;

  FUNCTION WHERE_VEND_SN RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(30);
      HI VARCHAR2(30);
    BEGIN
      LO := P_VEND_SERIAL_LO;
      HI := P_VEND_SERIAL_HI;
      IF P_VEND_SERIAL_LO IS NULL AND P_VEND_SERIAL_HI IS NULL THEN
        RETURN (' ');
      ELSE
        IF P_VEND_SERIAL_LO IS NOT NULL AND P_VEND_SERIAL_HI IS NULL THEN
          RETURN (' and msn.vendor_serial_number >= ''' || LO || ''' ');
        ELSE
          IF P_VEND_SERIAL_LO IS NULL AND P_VEND_SERIAL_HI IS NOT NULL THEN
            RETURN (' and msn.vendor_serial_number <= ''' || HI || ''' ');
          ELSE
            RETURN (' and msn.vendor_serial_number between ''' || LO || ''' and ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_VEND_SN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(0
                   ,'Failed srwinit, before report trigger')*/NULL;
        RAISE;
    END;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := TO_CHAR(P_ORG);
    BEGIN
      /*SRW.USER_EXIT('FND PUTPROFILE NAME="' || 'MFG_ORGANIZATION_ID' || '" FIELD="' || P_ORG_ID_CHAR || '"')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, setting org profile ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Failed flexsql loc select, before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(4
                   ,'Failed flexsql item select, before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(5
                   ,'Failed flexsql item order by, before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(8
                   ,'Failed flexsql item where, before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(12
                   ,'Failed flexsql  MKTS select, before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(16
                   ,'Failed flexsql MDSP select, before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(20
                   ,'Failed flexsql GL# select, before report trigger')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_UNIT_STATUS_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_UNIT_STATUS IS NULL THEN
        return(' ');
      ELSE
        RETURN (' and  msn.current_status = ' || TO_CHAR(P_UNIT_STATUS));
      END IF;
    END;
    RETURN(' ');
  END C_UNIT_STATUS_WHEREFORMULA;

  FUNCTION C_SOURCE_TYPE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_UNIT_STATUS IS NOT NULL THEN
        IF P_SOURCE_TYPE IS NULL THEN
          return(' ');
        ELSE
          RETURN (' and msn.last_txn_source_type_id = ' || TO_CHAR(P_SOURCE_TYPE));
        END IF;
      ELSE
        return(' ');
      END IF;
    END;
    RETURN (' ');
  END C_SOURCE_TYPE_WHEREFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'SRWEXIT failed')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

END INV_INVIRSNO_XMLP_PKG;


/
