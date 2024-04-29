--------------------------------------------------------
--  DDL for Package Body EAM_EAMWSREP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_EAMWSREP_XMLP_PKG" AS
/* $Header: EAMWSREPB.pls 120.0 2007/12/25 08:02:35 krreddy noship $ */
  FUNCTION CF_AREA RETURN VARCHAR2 IS
    CF_AREA VARCHAR2(150) := '';
  BEGIN
    IF P_AREA IS NOT NULL THEN
      CF_AREA := 'and mel.location_codes=''' || RTRIM(P_AREA) || '''';
    ELSE
      CF_AREA := 'and 1=1';
    END IF;
    RETURN (CF_AREA);
  END CF_AREA;

  FUNCTION CF_ASSET RETURN CHAR IS
    CF_ASSET VARCHAR2(100) := '';
  BEGIN
    IF P_ASSET IS NOT NULL THEN
      CF_ASSET := 'and cii.instance_number= ''' || P_ASSET || '''';
    ELSE
      CF_ASSET := 'and 1=1';
    END IF;
    RETURN (CF_ASSET);
  END CF_ASSET;

  FUNCTION CF_REBUILD_ITEM RETURN CHAR IS
    CF_REBUILD_ITEM VARCHAR2(50) := '';
  BEGIN
    IF P_REBUILD_ITEM IS NOT NULL THEN
      CF_REBUILD_ITEM := 'and wdj.rebuild_item_id= ' || P_REBUILD_ITEM;
    ELSE
      CF_REBUILD_ITEM := 'and 1=1';
    END IF;
    RETURN (CF_REBUILD_ITEM);
  END CF_REBUILD_ITEM;

  FUNCTION CF_ASSIGNED_DEPT RETURN CHAR IS
    CF_ASSIGNED_DEPT VARCHAR2(200) := '';
  BEGIN
    IF P_ASSIGNED_DEPT IS NOT NULL THEN
      CF_ASSIGNED_DEPT := 'and bd.department_code=''' || RTRIM(P_ASSIGNED_DEPT) || '''';
    ELSE
      CF_ASSIGNED_DEPT := 'and 1=1';
    END IF;
    RETURN (CF_ASSIGNED_DEPT);
  END CF_ASSIGNED_DEPT;

  FUNCTION CF_INSTANCE RETURN VARCHAR2 IS
    CF_INSTANCE VARCHAR2(2000) := '';
  BEGIN
    IF P_INSTANCE IS NOT NULL THEN
      CF_INSTANCE := 'and worp.instance_id = ((SELECT bre.instance_id  FROM PER_ALL_PEOPLE_F PAPF,bom_resource_employees bre,bom_resources br1
                             WHERE trunc(sysdate) between papf.effective_start_date and papf.effective_end_date AND
                             PAPF.PERSON_ID = BRE.PERSON_ID  and
                             bre.instance_id =worp.instance_id and
                             bre.resource_id =br.resource_id and
                     		br1.resource_id=bre.resource_id and
                     		br1.organization_id=worp.organization_id  and
                             bre.organization_id = worp.organization_id and
                     		papf.full_name = ''' || P_INSTANCE || '''
                     		and br1.resource_type=2)
                     		union
                         (select  bre.instance_id
                           FROM MTL_SYSTEM_ITEMS_KFV MSIK, bom_resource_equipments bre,bom_resources br2
                           WHERE BRE.INVENTORY_ITEM_ID = MSIK.INVENTORY_ITEM_ID AND
                                 MSIK.ITEM_TYPE = ''EQ''  and
                                 bre.instance_id =worp.instance_id and
                                 bre.resource_id = br.resource_id and
                     		   br2.resource_id=bre.resource_id and
                     		   br2.organization_id=worp.organization_id  and
                                bre.organization_id = worp.organization_id
                     		  and br2.resource_type=1  and
                     		  MSIK.CONCATENATED_SEGMENTS  =''' || P_INSTANCE || '''))';
    ELSE
      CF_INSTANCE := 'and 1=1';
    END IF;
    RETURN (CF_INSTANCE);
  END CF_INSTANCE;

  FUNCTION CF_OWNING_DEPARTMENT RETURN varchar2 IS
    CF_OWNING_DEPARTMENT VARCHAR2(20000) := '';
  BEGIN
    IF P_OWNING_DEPARTMENT IS NOT NULL THEN
      CF_OWNING_DEPARTMENT := 'and wdj.owning_department=
      (select department_id from   bom_departments where  department_code=''' || RTRIM(P_OWNING_DEPARTMENT) || '''
      and    organization_id=worp.organization_id)';
    ELSE
      CF_OWNING_DEPARTMENT := 'and 1=1';
    END IF;
    RETURN (CF_OWNING_DEPARTMENT);
  END CF_OWNING_DEPARTMENT;

  FUNCTION CF_REPORT_HEADER RETURN CHAR IS
    CF_REPORT_HEADER VARCHAR2(200);
  BEGIN
    CF_REPORT_HEADER := 'Weekly Schedule';
    RETURN (CF_REPORT_HEADER);
  END CF_REPORT_HEADER;

  FUNCTION CF_RESOURCE RETURN VARCHAR2 IS
    CF_RESOURCE VARCHAR2(1000) := '';
  BEGIN
    IF P_RESOURCE IS NULL THEN
      CF_RESOURCE := 'and 1=1';
    ELSE
      CF_RESOURCE := 'and br.resource_code=''' || P_RESOURCE || '''';
    END IF;
    RETURN (CF_RESOURCE);
  END CF_RESOURCE;

  FUNCTION CF_SHUTDOWN_TYPE RETURN CHAR IS
    CF_SHUTDOWN_TYPE VARCHAR2(50) := '';
  BEGIN
    IF P_SHUTDOWN_TYPE IS NOT NULL THEN
      CF_SHUTDOWN_TYPE := 'and ml2.meaning=''' || P_SHUTDOWN_TYPE || '''';
    ELSE
      CF_SHUTDOWN_TYPE := 'and 1=1';
    END IF;
    RETURN (CF_SHUTDOWN_TYPE);
  END CF_SHUTDOWN_TYPE;

  FUNCTION CF_SORT_BY RETURN CHAR IS
    CF_SORT_BY VARCHAR2(500) := '  ';
  BEGIN
    RETURN (CF_SORT_BY);
  END CF_SORT_BY;

  FUNCTION DAYS(RES_START_DATE IN DATE
               ,RES_COMPLETION_DATE IN DATE) RETURN VARCHAR2 IS
    X_ST_DAY_TIME VARCHAR2(5) := '';
    X_END_DAY_TIME VARCHAR2(5) := '';
    X_START_DAY VARCHAR2(20) := '';
    X_END_DAY VARCHAR2(20) := '';
    X_PERIOD NUMBER := 0;
    ADD_DAY NUMBER;
    X_MID_DAY VARCHAR2(20) := '';
    SUB_DAY NUMBER;
    X_WK_ST_DATE DATE;
  BEGIN
    /*SRW.REFERENCE(RES_START_DATE)*/NULL;
    /*SRW.REFERENCE(RES_COMPLETION_DATE)*/NULL;
    /*SRW.REFERENCE(CP_1)*/NULL;
    /*SRW.REFERENCE(CP_2)*/NULL;
    /*SRW.REFERENCE(CP_3)*/NULL;
    /*SRW.REFERENCE(CP_4)*/NULL;
    /*SRW.REFERENCE(CP_5)*/NULL;
    /*SRW.REFERENCE(CP_6)*/NULL;
    /*SRW.REFERENCE(CP_7)*/NULL;
    /*SRW.REFERENCE(CP_8)*/NULL;
    /*SRW.REFERENCE(CP_11)*/NULL;
    /*SRW.REFERENCE(CP_12)*/NULL;
    /*SRW.REFERENCE(CP_13)*/NULL;
    /*SRW.REFERENCE(CP_14)*/NULL;
    /*SRW.REFERENCE(CP_15)*/NULL;
    /*SRW.REFERENCE(CP_16)*/NULL;
    /*SRW.REFERENCE(CP_17)*/NULL;
    CP_1 := NULL;
    CP_2 := '';
    CP_3 := '';
    CP_4 := '';
    CP_5 := '';
    CP_6 := '';
    CP_7 := '';
    IF TO_NUMBER(TO_CHAR(RES_START_DATE
                     ,'MI')) > 30 THEN
      X_ST_DAY_TIME := SUBSTR(TO_CHAR(24 - TO_NUMBER(TO_CHAR(RES_START_DATE
                                                       ,'HH24')))
                             ,1
                             ,2);
    ELSE
      X_ST_DAY_TIME := SUBSTR(TO_CHAR(23 - TO_NUMBER(TO_CHAR(RES_START_DATE
                                                       ,'HH24')))
                             ,1
                             ,2);
    END IF;
    IF TO_NUMBER(TO_CHAR(RES_COMPLETION_DATE
                     ,'MI')) < 30 THEN
      X_END_DAY_TIME := SUBSTR(TO_CHAR(TO_NUMBER(TO_CHAR(RES_COMPLETION_DATE
                                                        ,'HH24')) + 1)
                              ,1
                              ,2);
    ELSE
      X_END_DAY_TIME := SUBSTR(TO_CHAR(RES_COMPLETION_DATE
                                      ,'HH24')
                              ,1
                              ,2);
    END IF;
    X_START_DAY := SUBSTR(TO_CHAR(RES_START_DATE
                                 ,'DAY')
                         ,1
                         ,3);
    X_END_DAY := SUBSTR(TO_CHAR(RES_COMPLETION_DATE
                               ,'DAY')
                       ,1
                       ,3);
    X_PERIOD := TO_NUMBER(RES_COMPLETION_DATE - RES_START_DATE);
    IF X_PERIOD = 0 THEN
      IF X_START_DAY = CP_11 THEN
        CP_1 := 0;
      ELSIF X_START_DAY = CP_12 THEN
        CP_2 := 0;
      ELSIF X_START_DAY = CP_13 THEN
        CP_3 := 0;
      ELSIF X_START_DAY = CP_14 THEN
        CP_4 := 0;
      ELSIF X_START_DAY = CP_15 THEN
        CP_5 := 0;
      ELSIF X_START_DAY = CP_16 THEN
        CP_6 := 0;
      ELSIF X_START_DAY = CP_17 THEN
        CP_7 := 0;
      END IF;
      CP_8 := 0;
      RETURN 'A';
    END IF;
    IF P_WEEK_START_DATE IS NOT NULL THEN
      X_WK_ST_DATE := P_WEEK_START_DATE;
    ELSE
      X_WK_ST_DATE := ROUND(SYSDATE
                           ,'DAY');
    END IF;
    IF X_START_DAY = CP_11 THEN
      ADD_DAY := 7;
    ELSIF X_START_DAY = CP_12 THEN
      ADD_DAY := 6;
    ELSIF X_START_DAY = CP_13 THEN
      ADD_DAY := 5;
    ELSIF X_START_DAY = CP_14 THEN
      ADD_DAY := 4;
    ELSIF X_START_DAY = CP_15 THEN
      ADD_DAY := 3;
    ELSIF X_START_DAY = CP_16 THEN
      ADD_DAY := 2;
    ELSIF X_START_DAY = CP_17 THEN
      ADD_DAY := 1;
    END IF;
    IF X_END_DAY = CP_11 THEN
      SUB_DAY := 1;
    ELSIF X_END_DAY = CP_12 THEN
      SUB_DAY := 2;
    ELSIF X_END_DAY = CP_13 THEN
      SUB_DAY := 3;
    ELSIF X_END_DAY = CP_14 THEN
      SUB_DAY := 4;
    ELSIF X_END_DAY = CP_15 THEN
      SUB_DAY := 5;
    ELSIF X_END_DAY = CP_16 THEN
      SUB_DAY := 6;
    ELSIF X_END_DAY = CP_17 THEN
      SUB_DAY := 7;
    END IF;
    IF RES_START_DATE > X_WK_ST_DATE AND RES_START_DATE < (X_WK_ST_DATE + 7) THEN
      IF TO_CHAR(RES_START_DATE
             ,'DD-MON-RRRR') <> TO_CHAR(RES_COMPLETION_DATE
             ,'DD-MON-RRRR') THEN
        IF X_START_DAY = CP_11 THEN
          CP_1 := X_ST_DAY_TIME;
        ELSIF X_START_DAY = CP_12 THEN
          CP_2 := X_ST_DAY_TIME;
        ELSIF X_START_DAY = CP_13 THEN
          CP_3 := X_ST_DAY_TIME;
        ELSIF X_START_DAY = CP_14 THEN
          CP_4 := X_ST_DAY_TIME;
        ELSIF X_START_DAY = CP_15 THEN
          CP_5 := X_ST_DAY_TIME;
        ELSIF X_START_DAY = CP_16 THEN
          CP_6 := X_ST_DAY_TIME;
        ELSIF X_START_DAY = CP_17 THEN
          CP_7 := X_ST_DAY_TIME;
        END IF;
        FOR i IN 1 .. ADD_DAY LOOP
          IF RES_START_DATE + I < RES_COMPLETION_DATE AND RES_START_DATE + I <= (X_WK_ST_DATE + 7) THEN
            X_MID_DAY := SUBSTR(TO_CHAR(RES_START_DATE + I
                                       ,'DAY')
                               ,1
                               ,3);
            IF X_MID_DAY = CP_11 THEN
              CP_1 := 24;
            ELSIF X_MID_DAY = CP_12 THEN
              CP_2 := 24;
            ELSIF X_MID_DAY = CP_13 THEN
              CP_3 := 24;
            ELSIF X_MID_DAY = CP_14 THEN
              CP_4 := 24;
            ELSIF X_MID_DAY = CP_15 THEN
              CP_5 := 24;
            ELSIF X_MID_DAY = CP_16 THEN
              CP_6 := 24;
            ELSIF X_MID_DAY = CP_17 THEN
              CP_7 := 24;
            END IF;
          END IF;
        END LOOP;
        IF RES_COMPLETION_DATE < (X_WK_ST_DATE + 7) THEN
          IF X_END_DAY = CP_11 THEN
            CP_1 := X_END_DAY_TIME;
          ELSIF X_END_DAY = CP_12 THEN
            CP_2 := X_END_DAY_TIME;
          ELSIF X_END_DAY = CP_13 THEN
            CP_3 := X_END_DAY_TIME;
          ELSIF X_END_DAY = CP_14 THEN
            CP_4 := X_END_DAY_TIME;
          ELSIF X_END_DAY = CP_15 THEN
            CP_5 := X_END_DAY_TIME;
          ELSIF X_END_DAY = CP_16 THEN
            CP_6 := X_END_DAY_TIME;
          ELSIF X_END_DAY = CP_17 THEN
            CP_7 := X_END_DAY_TIME;
          END IF;
        END IF;
      ELSIF TO_CHAR(RES_START_DATE
             ,'DD-MON-RRRR') = TO_CHAR(RES_COMPLETION_DATE
             ,'DD-MON-RRRR') THEN
        IF X_START_DAY = CP_11 THEN
          CP_1 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_12 THEN
          CP_2 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_13 THEN
          CP_3 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_14 THEN
          CP_4 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_15 THEN
          CP_5 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_16 THEN
          CP_6 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_17 THEN
          CP_7 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        END IF;
      END IF;
    ELSIF RES_COMPLETION_DATE > X_WK_ST_DATE AND RES_COMPLETION_DATE < (X_WK_ST_DATE + 7) THEN
      IF TO_CHAR(RES_START_DATE
             ,'DD-MON-RRRR') <> TO_CHAR(RES_COMPLETION_DATE
             ,'DD-MON-RRRR') THEN
        IF X_END_DAY = CP_11 THEN
          CP_1 := X_END_DAY_TIME;
        ELSIF X_END_DAY = CP_12 THEN
          CP_2 := X_END_DAY_TIME;
        ELSIF X_END_DAY = CP_13 THEN
          CP_3 := X_END_DAY_TIME;
        ELSIF X_END_DAY = CP_14 THEN
          CP_4 := X_END_DAY_TIME;
        ELSIF X_END_DAY = CP_15 THEN
          CP_5 := X_END_DAY_TIME;
        ELSIF X_END_DAY = CP_16 THEN
          CP_6 := X_END_DAY_TIME;
        ELSIF X_END_DAY = CP_17 THEN
          CP_7 := X_END_DAY_TIME;
        END IF;
        FOR i IN 1 .. (SUB_DAY - 1) LOOP
          IF RES_COMPLETION_DATE - I > RES_START_DATE THEN
            X_MID_DAY := SUBSTR(TO_CHAR(RES_COMPLETION_DATE - I
                                       ,'DAY')
                               ,1
                               ,3);
            IF X_MID_DAY = CP_11 THEN
              CP_1 := 24;
            ELSIF X_MID_DAY = CP_12 THEN
              CP_2 := 24;
            ELSIF X_MID_DAY = CP_13 THEN
              CP_3 := 24;
            ELSIF X_MID_DAY = CP_14 THEN
              CP_4 := 24;
            ELSIF X_MID_DAY = CP_15 THEN
              CP_5 := 24;
            ELSIF X_MID_DAY = CP_16 THEN
              CP_6 := 24;
            ELSIF X_MID_DAY = CP_17 THEN
              CP_7 := 24;
            END IF;
          END IF;
        END LOOP;
      ELSIF TO_CHAR(RES_START_DATE
             ,'DD-MON-RRRR') = TO_CHAR(RES_COMPLETION_DATE
             ,'DD-MON-RRRR') THEN
        IF X_START_DAY = CP_11 THEN
          CP_1 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_12 THEN
          CP_2 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_13 THEN
          CP_3 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_14 THEN
          CP_4 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_15 THEN
          CP_5 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_16 THEN
          CP_6 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        ELSIF X_START_DAY = CP_17 THEN
          CP_7 := SUBSTR(((RES_COMPLETION_DATE - RES_START_DATE) * 24)
                        ,1
                        ,2);
        END IF;
      END IF;
    ELSIF RES_COMPLETION_DATE > (X_WK_ST_DATE + 7) AND RES_START_DATE < X_WK_ST_DATE THEN
      CP_1 := 24;
      CP_2 := 24;
      CP_3 := 24;
      CP_4 := 24;
      CP_5 := 24;
      CP_6 := 24;
      CP_7 := 24;
    END IF;
    CP_8 := TO_NUMBER(NVL(CP_1
                         ,0)) + TO_NUMBER(NVL(CP_2
                         ,0)) + TO_NUMBER(NVL(CP_3
                         ,0)) + TO_NUMBER(NVL(CP_4
                         ,0)) + TO_NUMBER(NVL(CP_5
                         ,0)) + TO_NUMBER(NVL(CP_6
                         ,0)) + TO_NUMBER(NVL(CP_7
                         ,0));
    RETURN 'A';
  END DAYS;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_WEEK_STARTING IS NULL THEN
      IF RTRIM(TO_CHAR(SYSDATE
                   ,'DAY')) in ('SUNDAY','MONDAY','TUESDAY') THEN
        P_WEEK_START_DATE := ROUND(SYSDATE
                                  ,'DAY');
      ELSIF RTRIM(TO_CHAR(SYSDATE
                   ,'DAY')) in ('WEDNESDAY') THEN
        P_WEEK_START_DATE := ROUND(SYSDATE - 1
                                  ,'DAY');
      ELSIF RTRIM(TO_CHAR(SYSDATE
                   ,'DAY')) in ('THURSDAY','FRIDAY','SATURDAY') THEN
        P_WEEK_START_DATE := ROUND(SYSDATE - 4
                                  ,'DAY');
      END IF;
    ELSE
      P_WEEK_START_DATE := P_WEEK_STARTING;
      P_DIS_START_DATE := P_WEEK_STARTING;
    END IF;
    IF P_SORT_BY IS NOT NULL THEN
      BEGIN
        SELECT
          MEANING
        INTO P_DIS_SORT_BY
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'EAM_WSREP_SORT_BY'
          AND LOOKUP_CODE = P_SORT_BY;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSE
      P_DIS_SORT_BY := '';
    END IF;
    IF P_REBUILD_ITEM IS NOT NULL THEN
      BEGIN
        SELECT
          CONCATENATED_SEGMENTS
        INTO P_DIS_RBITEM
        FROM
          MTL_SYSTEM_ITEMS_B_KFV
        WHERE INVENTORY_ITEM_ID = P_REBUILD_ITEM
          AND ROWNUM < 2;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSE
      P_DIS_RBITEM := '';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.REFERENCE(P_WEEK_START_DATE)*/NULL;
    /*SRW.REFERENCE(CP_11)*/NULL;
    /*SRW.REFERENCE(CP_12)*/NULL;
    /*SRW.REFERENCE(CP_13)*/NULL;
    /*SRW.REFERENCE(CP_14)*/NULL;
    /*SRW.REFERENCE(CP_15)*/NULL;
    /*SRW.REFERENCE(CP_16)*/NULL;
    /*SRW.REFERENCE(CP_17)*/NULL;
    CP_11 := SUBSTR(TO_CHAR(P_WEEK_START_DATE
                           ,'DAY')
                   ,1
                   ,3);
    CP_12 := SUBSTR(TO_CHAR(P_WEEK_START_DATE + 1
                           ,'DAY')
                   ,1
                   ,3);
    CP_13 := SUBSTR(TO_CHAR(P_WEEK_START_DATE + 2
                           ,'DAY')
                   ,1
                   ,3);
    CP_14 := SUBSTR(TO_CHAR(P_WEEK_START_DATE + 3
                           ,'DAY')
                   ,1
                   ,3);
    CP_15 := SUBSTR(TO_CHAR(P_WEEK_START_DATE + 4
                           ,'DAY')
                   ,1
                   ,3);
    CP_16 := SUBSTR(TO_CHAR(P_WEEK_START_DATE + 5
                           ,'DAY')
                   ,1
                   ,3);
    CP_17 := SUBSTR(TO_CHAR(P_WEEK_START_DATE + 6
                           ,'DAY')
                   ,1
                   ,3);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_1;
  END CP_1_P;

  FUNCTION CP_2_P RETURN NUMBER IS
  BEGIN
    RETURN CP_2;
  END CP_2_P;

  FUNCTION CP_3_P RETURN NUMBER IS
  BEGIN
    RETURN CP_3;
  END CP_3_P;

  FUNCTION CP_4_P RETURN NUMBER IS
  BEGIN
    RETURN CP_4;
  END CP_4_P;

  FUNCTION CP_5_P RETURN NUMBER IS
  BEGIN
    RETURN CP_5;
  END CP_5_P;

  FUNCTION CP_6_P RETURN NUMBER IS
  BEGIN
    RETURN CP_6;
  END CP_6_P;

  FUNCTION CP_7_P RETURN NUMBER IS
  BEGIN
    RETURN CP_7;
  END CP_7_P;

  FUNCTION CP_8_P RETURN NUMBER IS
  BEGIN
    RETURN CP_8;
  END CP_8_P;

  FUNCTION CP_13_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_13;
  END CP_13_P;

  FUNCTION CP_14_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_14;
  END CP_14_P;

  FUNCTION CP_15_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_15;
  END CP_15_P;

  FUNCTION CP_16_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_16;
  END CP_16_P;

  FUNCTION CP_17_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_17;
  END CP_17_P;

  FUNCTION CP_11_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_11;
  END CP_11_P;

  FUNCTION CP_12_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_12;
  END CP_12_P;

END EAM_EAMWSREP_XMLP_PKG;



/
