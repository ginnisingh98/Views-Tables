--------------------------------------------------------
--  DDL for Package Body WSH_WSHRDINV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_WSHRDINV_XMLP_PKG" AS
/* $Header: WSHRDINVB.pls 120.2.12010000.4 2009/12/03 10:59:38 mvudugul ship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    DECLARE
      EIN_NUMBER VARCHAR2(150);
      STRUCT_NUMBER NUMBER;
      L_MSG_BUFFER VARCHAR2(2000);
      CURSOR ORG_NAME IS
        SELECT
          ORGANIZATION_NAME
        FROM
          ORG_ORGANIZATION_DEFINITIONS
        WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;
      CURSOR ORG_EIN IS
        SELECT
          OI.ORG_INFORMATION1
        FROM
          HR_ORGANIZATION_INFORMATION OI
        WHERE OI.ORGANIZATION_ID = P_ORGANIZATION_ID
          AND OI.ORG_INFORMATION_CONTEXT = 'Employer Identification';
      CURSOR MASTER_ORG_EIN IS
        SELECT
          MOI.ORG_INFORMATION1
        FROM
          MTL_PARAMETERS MP,
          HR_ORGANIZATION_INFORMATION MOI
        WHERE MP.ORGANIZATION_ID = P_ORGANIZATION_ID
          AND MP.MASTER_ORGANIZATION_ID = MOI.ORGANIZATION_ID
          AND MOI.ORG_INFORMATION_CONTEXT = 'Employer Identification';
      CURSOR STRUCT_NUM(FLEX_CODE IN VARCHAR2) IS
        SELECT
          ID_FLEX_NUM
        FROM
          FND_ID_FLEX_STRUCTURES
        WHERE ID_FLEX_CODE = FLEX_CODE;
      L_WH_ID NUMBER;
      L_TMP VARCHAR2(100);
    BEGIN
      FND_MESSAGE.SET_NAME('WSH'
                          ,'WSH_COMM_INV_RPT_EXPORT_TXT');
      L_MSG_BUFFER := FND_MESSAGE.GET;
      P_EXPORT_TXT := SUBSTRB(L_MSG_BUFFER
                             ,1
                             ,300);
      OPEN ORG_NAME;
      FETCH ORG_NAME
       INTO H_WAREHOUSE_NAME;
      CLOSE ORG_NAME;
      OPEN ORG_EIN;
      FETCH ORG_EIN
       INTO EIN_NUMBER;
      CLOSE ORG_EIN;
      IF EIN_NUMBER IS NULL THEN
        OPEN MASTER_ORG_EIN;
        FETCH MASTER_ORG_EIN
         INTO EIN_NUMBER;
        CLOSE MASTER_ORG_EIN;
      END IF;
      H_EIN := EIN_NUMBER;
      IF H_REPORT_ID IS NULL THEN
        H_REPORT_ID := TO_NUMBER(VALUE('CONC_REQUEST_ID'));
      END IF;
      IF H_REPORT_ID IS NULL THEN
        H_REPORT_ID := TO_NUMBER(TO_CHAR(SYSDATE
                                        ,'HH24MMSS'));
      END IF;
      OPEN STRUCT_NUM(P_ITEM_FLEX_CODE);
      FETCH STRUCT_NUM
       INTO STRUCT_NUMBER;
      CLOSE STRUCT_NUM;
      LP_STRUCTURE_NUM := STRUCT_NUMBER;
      IF LP_DEPARTURE_DATE_HIGH IS NOT NULL THEN
        LP_DEPARTURE_DATE_HIGH := LP_DEPARTURE_DATE_HIGH + (86399 / 86400);
      END IF;
      IF P_DEPARTURE_DATE_LOW IS NOT NULL OR LP_DEPARTURE_DATE_HIGH IS NOT NULL THEN
        IF P_DEPARTURE_DATE_LOW IS NULL THEN
          LP_DEPARTURE_DATE := 'AND wnd.delivery_id IN (select distinct delivery_id from wsh_delivery_legs where pick_up_stop_id in (select stop_id from wsh_trip_stops where planned_departure_date <= :LP_DEPARTURE_DATE_HIGH))';
        ELSIF LP_DEPARTURE_DATE_HIGH IS NULL THEN
          LP_DEPARTURE_DATE := 'AND wnd.delivery_id IN (select distinct delivery_id from wsh_delivery_legs where pick_up_stop_id in (select stop_id from wsh_trip_stops where planned_departure_date >= :P_DEPARTURE_DATE_LOW))';
        ELSE
          LP_DEPARTURE_DATE := 'AND wnd.delivery_id in (select distinct delivery_id from wsh_delivery_legs where pick_up_stop_id in (select stop_id from wsh_trip_stops where planned_departure_date between :P_DEPARTURE_DATE_LOW
				and :LP_DEPARTURE_DATE_HIGH))';
        END IF;
      END IF;
      IF P_DELIVERY_ID IS NOT NULL THEN
        LP_DELIVERY_ID := 'AND wnd.delivery_id = :P_DELIVERY_ID ';
      END IF;
      IF P_FREIGHT_CODE IS NOT NULL THEN
        LP_FREIGHT_CODE := 'AND wnd.ship_method_code = :P_FREIGHT_CODE ';
      END IF;
      IF P_ORGANIZATION_ID IS NOT NULL THEN
        LP_ORGANIZATION_ID := 'AND wdd.organization_id = :P_ORGANIZATION_ID ';
      END IF;
      IF P_TRIP_STOP_ID IS NOT NULL THEN
        LP_TRIP_STOP_ID := 'AND wnd.delivery_id in (select distinct wdl.delivery_id from wsh_delivery_legs wdl where (wdl.pick_up_stop_id = :P_TRIP_STOP_ID
                                                      OR wdl.drop_off_stop_id = :P_TRIP_STOP_ID)) ';
      END IF;

       --STANDALONE CHANGES
       IF WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'D' THEN
             P_STANDALONE := 'Y';
       ELSE
             P_STANDALONE := 'N';
       END IF;



      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWEXIT')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_ITEM_DISPFORMULA(CUSTOMER_ITEM_ID1 IN NUMBER
                             ,INVENTORY_ITEM_ID1 IN NUMBER
                             ,ORGANIZATION_ID1 IN NUMBER
                             ,ITEM_DESCRIPTION IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CURSOR CUSTOMER_LABEL(ID IN NUMBER,FLAG IN VARCHAR2) IS
        SELECT
          DECODE(FLAG
                ,'D'
                ,CUSTOMER_ITEM_DESC
                ,'F'
                ,CUSTOMER_ITEM_NUMBER
                ,CUSTOMER_ITEM_NUMBER || '     ' || CUSTOMER_ITEM_DESC) LABEL
        FROM
          MTL_CUSTOMER_ITEMS
        WHERE CUSTOMER_ITEM_ID = ID;
      CURSOR INVENTORY_LABEL(ID IN NUMBER,ORG_ID IN NUMBER) IS
        SELECT
          DESCRIPTION
        FROM
          MTL_SYSTEM_ITEMS_VL
        WHERE INVENTORY_ITEM_ID = ID
          AND ORGANIZATION_ID = ORG_ID;
      NAME VARCHAR2(800);
      USE_SHIPPER_NAME BOOLEAN := TRUE;
    BEGIN
      IF P_PRINT_CUST_ITEM = 'Y' AND CUSTOMER_ITEM_ID1 IS NOT NULL THEN
        BEGIN
          OPEN CUSTOMER_LABEL(CUSTOMER_ITEM_ID1,P_ITEM_DISPLAY);
          FETCH CUSTOMER_LABEL
           INTO NAME;
          CLOSE CUSTOMER_LABEL;
          IF NAME IS NULL OR NAME = '        ' THEN
            USE_SHIPPER_NAME := TRUE;
          ELSE
            USE_SHIPPER_NAME := FALSE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            CLOSE CUSTOMER_LABEL;
            USE_SHIPPER_NAME := TRUE;
        END;
      END IF;
      IF USE_SHIPPER_NAME THEN
        IF P_ITEM_DISPLAY = 'D' THEN
          IF INVENTORY_ITEM_ID1 IS NOT NULL THEN
            OPEN INVENTORY_LABEL(INVENTORY_ITEM_ID1,ORGANIZATION_ID1);
            FETCH INVENTORY_LABEL
             INTO NAME;
            CLOSE INVENTORY_LABEL;
          ELSE
            NAME := ITEM_DESCRIPTION;
          END IF;
        ELSIF P_ITEM_DISPLAY = 'F' THEN
        -- LSP PROJECT : passing p_remove_client_code as 'Y'
          NAME := WSH_UTIL_CORE.GET_ITEM_NAME(INVENTORY_ITEM_ID1
                                             ,ORGANIZATION_ID1
                                             ,P_ITEM_FLEX_CODE
                                             ,LP_STRUCTURE_NUM
                                             ,'Y');
        ELSE
          IF INVENTORY_ITEM_ID1 IS NOT NULL THEN
            OPEN INVENTORY_LABEL(INVENTORY_ITEM_ID1,ORGANIZATION_ID1);
            FETCH INVENTORY_LABEL
             INTO NAME;
            CLOSE INVENTORY_LABEL;
          ELSE
            NAME := ITEM_DESCRIPTION;
          END IF;
          -- LSP PROJECT : passing p_remove_client_code as 'Y'
          NAME := WSH_UTIL_CORE.GET_ITEM_NAME(INVENTORY_ITEM_ID1
                                             ,ORGANIZATION_ID1
                                             ,P_ITEM_FLEX_CODE
                                             ,LP_STRUCTURE_NUM
                                             ,'Y') || '     ' || NAME;
        END IF;
      END IF;
      RETURN NAME;
    END;
    RETURN NULL;
  END C_ITEM_DISPFORMULA;

  FUNCTION C_NUM_BOXESFORMULA(DELIVERY_ID3 IN NUMBER
                             ,NUM_LPN IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      CURSOR BOXES IS
        SELECT
          count(*)
        FROM
          WSH_DELIVERY_ASSIGNMENTS_V WDA,
          WSH_DELIVERY_DETAILS WDD
        WHERE WDD.DELIVERY_DETAIL_ID = WDA.DELIVERY_DETAIL_ID
          AND WDD.CONTAINER_FLAG = 'Y'
          AND WDA.PARENT_DELIVERY_DETAIL_ID IS NULL
          AND WDA.DELIVERY_ID is not null
          AND WDA.DELIVERY_ID = DELIVERY_ID3;
      NUM_OF_BOXES NUMBER;
    BEGIN
      IF (NUM_LPN IS NULL) THEN
        OPEN BOXES;
        FETCH BOXES
         INTO NUM_OF_BOXES;
        CLOSE BOXES;
        RETURN (NUM_OF_BOXES);
      ELSE
        RETURN (NUM_LPN);
      END IF;
    END;
    RETURN NULL;
  END C_NUM_BOXESFORMULA;

  FUNCTION C_DATA_FOUNDFORMULA(DELIVERY_ID3 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RP_DATA_FOUND := DELIVERY_ID3;
    RETURN (0);
  END C_DATA_FOUNDFORMULA;

  FUNCTION LP_STOP_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END LP_STOP_IDVALIDTRIGGER;

  FUNCTION C_SHIP_VIAFORMULA(DELIVERY_ID3 IN NUMBER
                            ,SHIP_VIA IN VARCHAR2
                            ,ORGANIZATION_ID1 IN NUMBER) RETURN CHAR IS
    CURSOR OTHER_LEGS IS
      SELECT
        DISTINCT
        WCS.SHIP_METHOD_MEANING
      FROM
        WSH_TRIPS T,
        WSH_TRIP_STOPS ST,
        WSH_DELIVERY_LEGS DG,
        WSH_CARRIER_SERVICES WCS,
        WSH_ORG_CARRIER_SERVICES WOCS
      WHERE DG.DELIVERY_ID = DELIVERY_ID3
        AND DG.PICK_UP_STOP_ID = ST.STOP_ID
        AND ST.TRIP_ID = T.TRIP_ID
        AND T.SHIP_METHOD_CODE <> NVL(SHIP_VIA
         ,'-1')
        AND T.SHIP_METHOD_CODE = WCS.SHIP_METHOD_CODE
        AND WCS.CARRIER_SERVICE_ID = WOCS.CARRIER_SERVICE_ID
        AND WOCS.ORGANIZATION_ID = ORGANIZATION_ID1;
    CURSOR GET_SHIP_METHOD_MEANING IS
      SELECT
        WCS.SHIP_METHOD_MEANING
      FROM
        WSH_CARRIER_SERVICES WCS
      WHERE WCS.SHIP_METHOD_CODE = SHIP_VIA;
    L_SHIP_METHOD VARCHAR2(500) := SHIP_VIA;
  BEGIN
    IF NVL(L_SHIP_METHOD
       ,'-1') = '-1' THEN
      L_SHIP_METHOD := NULL;
    ELSE
      OPEN GET_SHIP_METHOD_MEANING;
      FETCH GET_SHIP_METHOD_MEANING
       INTO L_SHIP_METHOD;
      CLOSE GET_SHIP_METHOD_MEANING;
    END IF;
    FOR dl IN OTHER_LEGS LOOP
      IF (L_SHIP_METHOD IS NOT NULL) THEN
        L_SHIP_METHOD := L_SHIP_METHOD || ', ' || DL.SHIP_METHOD_MEANING;
      ELSE
        L_SHIP_METHOD := DL.SHIP_METHOD_MEANING;
      END IF;
    END LOOP;
    RETURN L_SHIP_METHOD;
  END C_SHIP_VIAFORMULA;

  FUNCTION H_WAREHOUSE_NAMEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END H_WAREHOUSE_NAMEVALIDTRIGGER;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
   apf boolean;
   br0008 boolean;
  BEGIN
    br0008 := BEFOREREPORT0008;
    apf := AFTERPFORM;
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION F_SHIP_TO_CUST_NAMEFORMULA(SHIP_TO_SITE_USE_ID IN NUMBER) RETURN CHAR IS
  BEGIN
    DECLARE
      SHIP_TO_CUST_NAME HZ_PARTIES.PARTY_NAME%TYPE;
      L_PERSON_TITLE HZ_PARTIES.PERSON_TITLE%TYPE;
      L_LOOKUP_TYPE VARCHAR2(20);
      L_PERSON_TITLE_UP HZ_PARTIES.PERSON_TITLE%TYPE;
    BEGIN
      /*SRW.REFERENCE(SHIP_TO_SITE_USE_ID)*/NULL;
      SELECT
        HP.PARTY_NAME,
        NVL(HP.PERSON_PRE_NAME_ADJUNCT
           ,HP.PERSON_TITLE) TITLE
      INTO SHIP_TO_CUST_NAME,L_PERSON_TITLE
      FROM
        HZ_PARTY_SITES PS,
        HZ_CUST_ACCT_SITES_ALL CA,
        HZ_CUST_SITE_USES_ALL SU,
        HZ_PARTIES HP
      WHERE SU.SITE_USE_ID = SHIP_TO_SITE_USE_ID
        AND SU.CUST_ACCT_SITE_ID = CA.CUST_ACCT_SITE_ID
        AND CA.PARTY_SITE_ID = PS.PARTY_SITE_ID
        AND HP.PARTY_ID = PS.PARTY_ID;
      IF L_PERSON_TITLE IS NOT NULL THEN
        BEGIN
          L_LOOKUP_TYPE := 'RESPONSIBILITY';
          L_PERSON_TITLE_UP := UPPER(L_PERSON_TITLE);
          SELECT
            MEANING || ' ' || SHIP_TO_CUST_NAME
          INTO SHIP_TO_CUST_NAME
          FROM
            AR_LOOKUPS
          WHERE LOOKUP_CODE = L_PERSON_TITLE_UP
            AND LOOKUP_TYPE = L_LOOKUP_TYPE;
        EXCEPTION
          WHEN OTHERS THEN
            SHIP_TO_CUST_NAME := L_PERSON_TITLE || ' ' || SHIP_TO_CUST_NAME;
        END;
      END IF;
      IF SQL%NOTFOUND THEN
        RETURN (NULL);
      END IF;
      RETURN (SHIP_TO_CUST_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (NULL);
      WHEN OTHERS THEN
        RAISE;
    END;
  END F_SHIP_TO_CUST_NAMEFORMULA;

  FUNCTION CF_CONTACT_NAMEFORMULA(SHIP_TO_CONTACT_ID IN NUMBER) RETURN CHAR IS
    CONTACT_NAME HZ_PARTIES.PARTY_NAME%TYPE;
    L_PERSON_TITLE HZ_PARTIES.PERSON_TITLE%TYPE;
    L_PERSON_TITLE_UP HZ_PARTIES.PERSON_TITLE%TYPE;
    L_LOOKUP_TYPE VARCHAR2(20);
  BEGIN
    /*SRW.REFERENCE(SHIP_TO_CONTACT_ID)*/NULL;
    IF (SHIP_TO_CONTACT_ID IS NOT NULL) THEN
      SELECT
        PARTY.PARTY_NAME,
        NVL(PARTY.PERSON_PRE_NAME_ADJUNCT
           ,PARTY.PERSON_TITLE) TITLE
      INTO CONTACT_NAME,L_PERSON_TITLE
      FROM
        HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
        HZ_PARTIES PARTY,
        HZ_RELATIONSHIPS REL,
        HZ_ORG_CONTACTS ORG_CONT,
        HZ_PARTIES REL_PARTY
      WHERE ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = SHIP_TO_CONTACT_ID
        AND ACCT_ROLE.PARTY_ID = REL.PARTY_ID
        AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
        AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
        AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
        AND REL.DIRECTIONAL_FLAG = 'F'
        AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
        AND REL.SUBJECT_ID = PARTY.PARTY_ID
        AND REL.PARTY_ID = REL_PARTY.PARTY_ID;
      IF L_PERSON_TITLE IS NOT NULL THEN
        BEGIN
          L_LOOKUP_TYPE := 'RESPONSIBILITY';
          L_PERSON_TITLE_UP := UPPER(L_PERSON_TITLE);
          SELECT
            MEANING || ' ' || CONTACT_NAME
          INTO CONTACT_NAME
          FROM
            AR_LOOKUPS
          WHERE LOOKUP_CODE = L_PERSON_TITLE_UP
            AND LOOKUP_TYPE = L_LOOKUP_TYPE;
        EXCEPTION
          WHEN OTHERS THEN
            CONTACT_NAME := L_PERSON_TITLE || ' ' || CONTACT_NAME;
        END;
      END IF;
    ELSE
      CONTACT_NAME := '   ';
    END IF;
    RETURN (CONTACT_NAME);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      CONTACT_NAME := '   ';
      RETURN (CONTACT_NAME);
    WHEN OTHERS THEN
      RAISE;
  END CF_CONTACT_NAMEFORMULA;

  FUNCTION CF_CUSTOMER_NAMEFORMULA RETURN CHAR IS
    CUSTOMER_NAME VARCHAR2(120) := 'X';
  BEGIN
    RETURN (CUSTOMER_NAME);
  END CF_CUSTOMER_NAMEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION BEFOREREPORT0008 RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      LP_DEPARTURE_DATE_HIGH := P_DEPARTURE_DATE_HIGH;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed FND SRWINIT.')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT0008;

  FUNCTION CF_1FORMULA RETURN CHAR IS
  BEGIN
    RETURN H_WAREHOUSE_NAME;
  END CF_1FORMULA;

  FUNCTION CF_EINFORMULA0007 RETURN CHAR IS
  BEGIN
    RETURN H_EIN;
  END CF_EINFORMULA0007;

  FUNCTION CF_COMMODITY_CLASSFORMULA(INVENTORY_ITEM_ID1 IN NUMBER
                                    ,ORGANIZATION_ID1 IN NUMBER) RETURN CHAR IS
    L_CLASS_LIST VARCHAR2(1000);
    CURSOR C_CATEGORY(C_INV_ITEM_ID IN NUMBER,C_INV_ORG_ID IN NUMBER) IS
      SELECT
        CONCATENATED_SEGMENTS COMM_CLASS
      FROM
        MTL_CATEGORIES_KFV MC,
        MTL_ITEM_CATEGORIES MIC,
        MTL_CATEGORY_SETS_VL MCSTL
      WHERE MIC.INVENTORY_ITEM_ID = C_INV_ITEM_ID
        AND MIC.ORGANIZATION_ID = C_INV_ORG_ID
        AND MIC.CATEGORY_SET_ID = MCSTL.CATEGORY_SET_ID
        AND MC.CATEGORY_ID = MIC.CATEGORY_ID
        AND MCSTL.CATEGORY_SET_NAME = 'WSH_COMMODITY_CODE'
      ORDER BY
        MC.CATEGORY_ID;
  BEGIN
    /*SRW.REFERENCE(INVENTORY_ITEM_ID1)*/NULL;
    /*SRW.REFERENCE(ORGANIZATION_ID1)*/NULL;
    FOR c_rec IN C_CATEGORY(c_inv_item_id => INVENTORY_ITEM_ID1,
                         c_inv_org_id  => ORGANIZATION_ID1) LOOP
      IF (L_CLASS_LIST IS NULL) THEN
        L_CLASS_LIST := C_REC.COMM_CLASS;
      ELSE
        L_CLASS_LIST := L_CLASS_LIST || ', ' || C_REC.COMM_CLASS;
      END IF;
    END LOOP;
    RETURN (L_CLASS_LIST);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CF_COMMODITY_CLASSFORMULA;

  FUNCTION CP_SHIP_TO_ADDR1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_TO_ADDR1;
  END CP_SHIP_TO_ADDR1_P;

  FUNCTION CP_SHIP_TO_ADDR2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_TO_ADDR2;
  END CP_SHIP_TO_ADDR2_P;

  FUNCTION CP_SHIP_TO_ADDR3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_TO_ADDR3;
  END CP_SHIP_TO_ADDR3_P;

  FUNCTION CP_SHIP_TO_ADDR4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_TO_ADDR4;
  END CP_SHIP_TO_ADDR4_P;

  FUNCTION CP_SHIP_TO_CITY_STATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_TO_CITY_STATE;
  END CP_SHIP_TO_CITY_STATE_P;

  FUNCTION CP_SHIP_TO_COUNTRY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_TO_COUNTRY;
  END CP_SHIP_TO_COUNTRY_P;

  FUNCTION CP_ITEM_COST_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ITEM_COST;
  END CP_ITEM_COST_P;

  FUNCTION CP_EXTENDED_COST_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EXTENDED_COST;
  END CP_EXTENDED_COST_P;

  PROCEDURE PUT(NAME IN VARCHAR2
               ,VAL IN VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin FND_PROFILE.PUT(:NAME, :VAL); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_I(VAL);
    STPROC.EXECUTE;*/
    FND_PROFILE.PUT(NAME, VAL);
  END PUT;

  FUNCTION DEFINED(NAME IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
    X1 integer;
  BEGIN
    /*STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.DEFINED(:NAME); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,X0);
    RETURN X0;*/
    declare
     X0rv BOOLEAN;
    begin
     X0rv := FND_PROFILE.DEFINED(NAME);
     X1 := sys.diutil.bool_to_int(X0rv);
    end;
    RETURN sys.diutil.int_to_bool(X1);
  END DEFINED;

  PROCEDURE GET(NAME IN VARCHAR2
               ,VAL OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin FND_PROFILE.GET(:NAME, :VAL); end;');
    STPROC.BIND_I(NAME);
    STPROC.BIND_O(VAL);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,VAL);*/
    FND_PROFILE.GET(NAME, VAL);
  END GET;

  FUNCTION VALUE(NAME IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_PROFILE.VALUE(:NAME); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/

    X0 := FND_PROFILE.VALUE(NAME);
    RETURN X0;
  END VALUE;

  FUNCTION SAVE_USER(X_NAME IN VARCHAR2
                    ,X_VALUE IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
    X1 integer;
  BEGIN
    /*STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.SAVE_USER(:X_NAME, :X_VALUE); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(X_NAME);
    STPROC.BIND_I(X_VALUE);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,X0);
    RETURN X0;*/

    declare
     X0rv BOOLEAN;
    begin
     X0rv := FND_PROFILE.SAVE_USER(X_NAME, X_VALUE);
     X1 := sys.diutil.bool_to_int(X0rv);
    end;
    RETURN sys.diutil.int_to_bool(X1);
  END SAVE_USER;

  FUNCTION SAVE(X_NAME IN VARCHAR2
               ,X_VALUE IN VARCHAR2
               ,X_LEVEL_NAME IN VARCHAR2
               ,X_LEVEL_VALUE IN VARCHAR2
               ,X_LEVEL_VALUE_APP_ID IN VARCHAR2) RETURN BOOLEAN IS
    X0 BOOLEAN;
    X1 integer;
  BEGIN
    /*STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := FND_PROFILE.SAVE(:X_NAME, :X_VALUE, :X_LEVEL_NAME, :X_LEVEL_VALUE, :X_LEVEL_VALUE_APP_ID); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(X_NAME);
    STPROC.BIND_I(X_VALUE);
    STPROC.BIND_I(X_LEVEL_NAME);
    STPROC.BIND_I(X_LEVEL_VALUE);
    STPROC.BIND_I(X_LEVEL_VALUE_APP_ID);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(6
                   ,X0);
    RETURN X0;*/

    declare
     X0rv BOOLEAN;
    begin
     X0rv := FND_PROFILE.SAVE(X_NAME, X_VALUE, X_LEVEL_NAME, X_LEVEL_VALUE, X_LEVEL_VALUE_APP_ID);
     X1 := sys.diutil.bool_to_int(X0rv);
    end;
    RETURN sys.diutil.int_to_bool(X1);
  END SAVE;

  PROCEDURE GET_SPECIFIC(NAME_Z IN VARCHAR2
                        ,USER_ID_Z IN NUMBER
                        ,RESPONSIBILITY_ID_Z IN NUMBER
                        ,APPLICATION_ID_Z IN NUMBER
                        ,VAL_Z OUT NOCOPY VARCHAR2
                        ,DEFINED_Z OUT NOCOPY BOOLEAN) IS
  BEGIN
    /*STPROC.INIT('declare DEFINED_Z BOOLEAN; begin DEFINED_Z := sys.diutil.int_to_bool(:DEFINED_Z); FND_PROFILE.GET_SPECIFIC(:NAME_Z, :USER_ID_Z, :RESPONSIBILITY_ID_Z, :APPLICATION_ID_Z, :VAL_Z, DEFINED_Z);
    :DEFINED_Z := sys.diutil.bool_to_int(DEFINED_Z); end;');
    STPROC.BIND_O(DEFINED_Z);
    STPROC.BIND_I(NAME_Z);
    STPROC.BIND_I(USER_ID_Z);
    STPROC.BIND_I(RESPONSIBILITY_ID_Z);
    STPROC.BIND_I(APPLICATION_ID_Z);
    STPROC.BIND_O(VAL_Z);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,DEFINED_Z);
    STPROC.RETRIEVE(6,VAL_Z);*/

    declare
     DEFINED_Z BOOLEAN;
     DEFINED_Z1 integer;
    begin
     DEFINED_Z := sys.diutil.int_to_bool(DEFINED_Z1);
     FND_PROFILE.GET_SPECIFIC(NAME_Z, USER_ID_Z, RESPONSIBILITY_ID_Z, APPLICATION_ID_Z, VAL_Z, DEFINED_Z);
     DEFINED_Z1 := sys.diutil.bool_to_int(DEFINED_Z);
    end;
  END GET_SPECIFIC;

  FUNCTION VALUE_SPECIFIC(NAME IN VARCHAR2
                         ,USER_ID IN NUMBER
                         ,RESPONSIBILITY_ID IN NUMBER
                         ,APPLICATION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_PROFILE.VALUE_SPECIFIC(:NAME, :USER_ID, :RESPONSIBILITY_ID, :APPLICATION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(NAME);
    STPROC.BIND_I(USER_ID);
    STPROC.BIND_I(RESPONSIBILITY_ID);
    STPROC.BIND_I(APPLICATION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/

    X0 := FND_PROFILE.VALUE_SPECIFIC(NAME, USER_ID, RESPONSIBILITY_ID, APPLICATION_ID);
    RETURN X0;
  END VALUE_SPECIFIC;

  PROCEDURE INITIALIZE(USER_ID_Z IN NUMBER
                      ,RESPONSIBILITY_ID_Z IN NUMBER
                      ,APPLICATION_ID_Z IN NUMBER
                      ,SITE_ID_Z IN NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin FND_PROFILE.INITIALIZE(:USER_ID_Z, :RESPONSIBILITY_ID_Z, :APPLICATION_ID_Z, :SITE_ID_Z); end;');
    STPROC.BIND_I(USER_ID_Z);
    STPROC.BIND_I(RESPONSIBILITY_ID_Z);
    STPROC.BIND_I(APPLICATION_ID_Z);
    STPROC.BIND_I(SITE_ID_Z);
    STPROC.EXECUTE;*/

    FND_PROFILE.INITIALIZE(USER_ID_Z, RESPONSIBILITY_ID_Z, APPLICATION_ID_Z, SITE_ID_Z);
  END INITIALIZE;

  PROCEDURE PUTMULTIPLE(NAMES IN VARCHAR2
                       ,VALS IN VARCHAR2
                       ,NUM IN NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin FND_PROFILE.PUTMULTIPLE(:NAMES, :VALS, :NUM); end;');
    STPROC.BIND_I(NAMES);
    STPROC.BIND_I(VALS);
    STPROC.BIND_I(NUM);
    STPROC.EXECUTE;*/

    FND_PROFILE.PUTMULTIPLE(NAMES, VALS, NUM);
  END PUTMULTIPLE;


function C_ext_cost_fmtFormula(source_code varchar2, source_line_id number, unit_of_measure varchar2,
source_uom varchar2, shipped_quantity number, inventory_item_id1 number) return VARCHAR2 is
cursor oe_selling_price is
   select unit_selling_price
   from   oe_order_lines_all
   where  line_id = source_line_id;    --Bug 9166141 changed line_id to source_line_id

cursor oke_selling_price is
   select unit_price
   from   oke_k_deliverables_b
   where  deliverable_id  = source_line_id;   --Bug 9166141 changed line_id to source_line_id

l_unit_selling_price  NUMBER := 0;
begin
If source_code = 'OE' then
    open  oe_selling_price;
    fetch oe_selling_price into l_unit_selling_price;
    close oe_selling_price;
Elsif source_code = 'OKE' then
    open  oke_selling_price;
    fetch oke_selling_price into l_unit_selling_price;
    close oke_selling_price;
End If;
cp_extended_cost := ROUND(l_unit_selling_price *
                           WSH_WV_UTILS.CONVERT_UOM(unit_of_measure, source_uom,
                                                    shipped_quantity,
                                                    inventory_item_id1),2);
p_extended_cost := cp_extended_cost;
/*BEGIN
SRW.REFERENCE(:CURRENCY_CODE);

IF (:CURRENCY_CODE)  IS NOT NULL THEN
  SRW.USER_EXIT('FND FORMAT_CURRENCY
		CODE=":CURRENCY_CODE"
		DISPLAY_WIDTH="11"
		AMOUNT=":p_extended_cost"
		DISPLAY=":C_EXT_COST_FMT" ');

RETURN(:C_EXT_COST_FMT);
END IF;
RETURN NULL;
END;*/
RETURN p_extended_cost; --Bug 9166141
end;

function C_item_cost_fmtFormula(source_code varchar2, source_line_id number, unit_of_measure varchar2,
source_uom varchar2, inventory_item_id1 number) return VARCHAR2 is
cursor oe_selling_price is
   select unit_selling_price
   from   oe_order_lines_all
   where  line_id = source_line_id;   --Bug 9166141 changed line_id to source_line_id

cursor oke_selling_price is
   select unit_price
   from   oke_k_deliverables_b
   where  deliverable_id  = source_line_id;   --Bug 9166141 changed line_id to source_line_id

l_unit_selling_price  NUMBER := 0;
begin
If source_code = 'OE' then
    open  oe_selling_price;
    fetch oe_selling_price into l_unit_selling_price;
    close oe_selling_price;
Elsif source_code = 'OKE' then
    open  oke_selling_price;
    fetch oke_selling_price into l_unit_selling_price;
    close oke_selling_price;
End If;
cp_item_cost := ROUND(l_unit_selling_price *
                       WSH_WV_UTILS.CONVERT_UOM(unit_of_measure, source_uom, 1,
                                                inventory_item_id1),2);

p_item_cost  := cp_item_cost;
/*BEGIN
SRW.REFERENCE(:currency_code);

IF (:currency_code) is not null then
  SRW.USER_EXIT('FND FORMAT_CURRENCY
		CODE=":CURRENCY_CODE"
		DISPLAY_WIDTH="11"
		AMOUNT=":p_item_cost"
		DISPLAY=":C_ITEM_COST_FMT" ');

RETURN(:C_ITEM_COST_FMT);
END IF;
END;*/
RETURN p_item_cost;  --Bug 9166141
end;

END WSH_WSHRDINV_XMLP_PKG;



/
