--------------------------------------------------------
--  DDL for Package Body BOM_BOMRDDEL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOMRDDEL_XMLP_PKG" AS
/* $Header: BOMRDDELB.pls 120.0 2007/12/24 09:39:47 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION WHERE_GROUP RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      GROUP_FROM VARCHAR2(10);
      GROUP_TO VARCHAR2(10);
    BEGIN
      GROUP_FROM := P_GROUP_FROM;
      GROUP_TO := P_GROUP_TO;
      IF (P_GROUP_FROM IS NOT NULL AND P_GROUP_TO IS NOT NULL) THEN
        RETURN ('and bdg.DELETE_GROUP_NAME between ''' || GROUP_FROM || ''' and ''' || GROUP_TO || '''');
      ELSE
        IF P_GROUP_FROM IS NOT NULL THEN
          RETURN ('and bdg.DELETE_GROUP_NAME like ''' || GROUP_FROM || '''');
        ELSE
          IF P_GROUP_TO IS NOT NULL THEN
            RETURN ('and bdg.DELETE_GROUP_NAME like ''' || GROUP_TO || '''');
          ELSE
            RETURN (' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END WHERE_GROUP;

  FUNCTION WHERE_TYPE RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ITEM_TYPE VARCHAR2(1);
      BILL_TYPE VARCHAR2(1);
      ROUT_TYPE VARCHAR2(1);
      COMP_TYPE VARCHAR2(1);
      OPER_TYPE VARCHAR2(1);
      BR_TYPE VARCHAR2(1);
      IBR_TYPE VARCHAR2(1);
    BEGIN
      IF P_ITEM_FLAG = 1 THEN
        ITEM_TYPE := 1;
      ELSE
        ITEM_TYPE := 0;
      END IF;
      IF P_BILL_FLAG = 1 THEN
        BILL_TYPE := 2;
      ELSE
        BILL_TYPE := 0;
      END IF;
      IF P_ROUT_FLAG = 1 THEN
        ROUT_TYPE := 3;
      ELSE
        ROUT_TYPE := 0;
      END IF;
      IF P_COMP_FLAG = 1 THEN
        COMP_TYPE := 4;
      ELSE
        COMP_TYPE := 0;
      END IF;
      IF P_OPER_FLAG = 1 THEN
        OPER_TYPE := 5;
      ELSE
        OPER_TYPE := 0;
      END IF;
      IF P_BR_FLAG = 1 THEN
        BR_TYPE := 6;
      ELSE
        BR_TYPE := 0;
      END IF;
      IF P_IBR_FLAG = 1 THEN
        IBR_TYPE := 7;
      ELSE
        IBR_TYPE := 0;
      END IF;
      RETURN ('and bdg.DELETE_TYPE in ( ' || ITEM_TYPE || ', ' || BILL_TYPE || ', ' || ROUT_TYPE || ', ' || COMP_TYPE || ', ' || OPER_TYPE || ', ' || BR_TYPE || ', ' || IBR_TYPE || ')');
    END;
    RETURN ' ';
  END WHERE_TYPE;

  FUNCTION WHERE_TYPE1 RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ITEM_TYPE VARCHAR2(1);
      BILL_TYPE VARCHAR2(1);
      ROUT_TYPE VARCHAR2(1);
      COMP_TYPE VARCHAR2(1);
      OPER_TYPE VARCHAR2(1);
      BR_TYPE VARCHAR2(1);
      IBR_TYPE VARCHAR2(1);
    BEGIN
      IF P_ITEM_FLAG = 1 THEN
        ITEM_TYPE := 1;
      ELSE
        ITEM_TYPE := 0;
      END IF;
      IF P_BILL_FLAG = 1 THEN
        BILL_TYPE := 2;
      ELSE
        BILL_TYPE := 0;
      END IF;
      IF P_ROUT_FLAG = 1 THEN
        ROUT_TYPE := 3;
      ELSE
        ROUT_TYPE := 0;
      END IF;
      IF P_COMP_FLAG = 1 THEN
        COMP_TYPE := 4;
      ELSE
        COMP_TYPE := 0;
      END IF;
      IF P_OPER_FLAG = 1 THEN
        OPER_TYPE := 5;
      ELSE
        OPER_TYPE := 0;
      END IF;
      IF P_BR_FLAG = 1 THEN
        BR_TYPE := 6;
      ELSE
        BR_TYPE := 0;
      END IF;
      IF P_IBR_FLAG = 1 THEN
        IBR_TYPE := 7;
      ELSE
        IBR_TYPE := 0;
      END IF;
      RETURN ('and bdg.DELETE_TYPE in ( ' || ITEM_TYPE || ', ' || BILL_TYPE || ', ' || ROUT_TYPE || ', ' || COMP_TYPE || ', ' || OPER_TYPE || ', ' || BR_TYPE || ', ' || IBR_TYPE || ')');
    END;
    RETURN ' ';
  END WHERE_TYPE1;

  FUNCTION WHERE_ENTITY_STATUS RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      PEND VARCHAR2(1);
      CHECK_OK VARCHAR2(1);
      ERROR VARCHAR2(1);
      DEL VARCHAR2(1);
    BEGIN
      IF P_PEND_STATUS_FLAG = 1 THEN
        PEND := 1;
      ELSE
        PEND := 0;
      END IF;
      IF P_CHECK_STATUS_FLAG = 1 THEN
        CHECK_OK := 2;
      ELSE
        CHECK_OK := 0;
      END IF;
      IF P_ERROR_STATUS_FLAG = 1 THEN
        ERROR := 3;
      ELSE
        ERROR := 0;
      END IF;
      IF P_DEL_STATUS_FLAG = 1 THEN
        DEL := 4;
      ELSE
        DEL := 0;
      END IF;
      RETURN ('and ( bde.delete_status_type is null or bde.DELETE_STATUS_TYPE in ( ' || PEND || ', ' || CHECK_OK || ', ' || ERROR || ', ' || DEL || '))');
    END;
    RETURN ' ';
  END WHERE_ENTITY_STATUS;

  FUNCTION WHERE_SUB_ENTITY_STATUS RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      PEND VARCHAR2(1);
      CHECK_OK VARCHAR2(1);
      ERROR VARCHAR2(1);
      DEL VARCHAR2(1);
    BEGIN
      IF P_PEND_STATUS_FLAG = 1 THEN
        PEND := 1;
      ELSE
        PEND := 0;
      END IF;
      IF P_CHECK_STATUS_FLAG = 1 THEN
        CHECK_OK := 2;
      ELSE
        CHECK_OK := 0;
      END IF;
      IF P_ERROR_STATUS_FLAG = 1 THEN
        ERROR := 3;
      ELSE
        ERROR := 0;
      END IF;
      IF P_DEL_STATUS_FLAG = 1 THEN
        DEL := 4;
      ELSE
        DEL := 0;
      END IF;
      RETURN ('and ( bdse.delete_status_type is null or bdse.DELETE_STATUS_TYPE in ( ' || PEND || ', ' || CHECK_OK || ', ' || ERROR || ', ' || DEL || '))');
    END;
    RETURN ' ';
  END WHERE_SUB_ENTITY_STATUS;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION C_ENG_FLAG_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_BOM_OR_ENG = 'ENG' THEN
      RETURN (' and bdg.engineering_flag = 2 ');
    ELSE
      RETURN (' and bdg.engineering_flag = 1 ');
    END IF;
    RETURN ' ';
  END C_ENG_FLAG_WHEREFORMULA;

  --FUNCTION GET_MESSAGE RETURN VARCHAR2 IS
  FUNCTION GET_MESSAGE(ENTITY_MESSAGE IN VARCHAR2) RETURN VARCHAR2 IS
   BEGIN
    FND_MESSAGE.SET_NAME('null'
                        ,ENTITY_MESSAGE);
    P_ENT_MSG := FND_MESSAGE.GET;
    RETURN (P_ENT_MSG);
  END GET_MESSAGE;

  FUNCTION GET_MESSAGE2 RETURN VARCHAR2 IS
  BEGIN
    FND_MESSAGE.SET_NAME('null'
                        ,':COMP_MESSAGE');
    P_COMP_MSG := FND_MESSAGE.GET;
    RETURN (P_COMP_MSG);
  END GET_MESSAGE2;

  FUNCTION GET_MESSAGE3 RETURN VARCHAR2 IS
  BEGIN
    FND_MESSAGE.SET_NAME('null'
                        ,':OP_MESSAGE');
    P_OP_MSG := FND_MESSAGE.GET;
    RETURN (P_OP_MSG);
  END GET_MESSAGE3;

END BOM_BOMRDDEL_XMLP_PKG;


/
