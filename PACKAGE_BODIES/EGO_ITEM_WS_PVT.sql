--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_WS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_WS_PVT" AS
/* $Header: EGOVIWSB.pls 120.0.12010000.24 2010/05/31 08:53:24 nendrapu noship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : EGOVIWSB.pls                                               |
| DESCRIPTION  : This file contains the procedures required for             |
|                Item Web service.                                          |
|                                                                           |
|                                                                           |
+==========================================================================*/
e_invalid_invocation_mode EXCEPTION;
e_no_org_details EXCEPTION;
e_no_rev_details EXCEPTION;

/* Procedure Inserts the UDA values for the publishing items,
 * for a given business entity level in to the table EGO_PUB_WS_FLAT_RECS.
*/
PROCEDURE POPULATE_AGS(sessionId IN NUMBER,
                      odisessionId IN NUMBER,
                      dataLevelId IN NUMBER
                      )
AS
  v_value_set_id NUMBER;
  v_value_set_name ego_attrs_v.VALUE_SET_NAME%TYPE;
  v_format_code ego_attrs_v.FORMAT_CODE%TYPE;
  v_display_value EGO_VALUE_SET_VALUES_V.DISPLAY_NAME%TYPE;
  v_count  NUMBER;
  v_publish_udas VARCHAR2(100);

  v_query_string_b VARCHAR2(32767);
  v_query_string_l VARCHAR2(32767);
  v_query_string  VARCHAR2(32767);
  v_attribute_group_id    ego_all_attr_base_v.ATTRIBUTEGROUP_ID%TYPE;
  v_attribute_group_name ego_all_attr_base_v.ATTRIBUTE_GROUP_NAME%TYPE;
  v_organization_id     ego_all_attr_base_v.organization_id%TYPE;
  v_inventory_item_id   ego_all_attr_base_v.inventory_item_id%TYPE;
  v_revision_id         ego_all_attr_base_v.revision_id%TYPE;
  v_application_id      ego_all_attr_base_v.application_id%TYPE;
  v_extension_id        ego_all_attr_base_v.extension_id%TYPE;
  v_data_level_id       ego_all_attr_base_v.data_level_id%TYPE;
  v_pk1_value           ego_all_attr_base_v.pk1_value%TYPE;
  v_pk2_value           ego_all_attr_base_v.pk2_value%TYPE;
  v_data_level_name     EGO_DATA_LEVEL_VL.user_data_level_name%TYPE;
  v_sequence_id         EGO_PUB_WS_FLAT_RECS.sequence_id%TYPE;
  v_pk3_value           EGO_ODI_WS_ENTITIES.pk3_value%TYPE;
  v_org_id              EGO_PUB_WS_FLAT_RECS.PK2_VALUE%TYPE;

  TYPE DYNAMIC_CUR IS REF CURSOR;
  v_dynamic_cursor  DYNAMIC_CUR;

BEGIN

  select char_value INTO v_publish_udas
  from EGO_PUB_WS_CONFIG
  where session_id = sessionId
  and PARAMETER_NAME = 'PUBLISH_UDA_GROUPS';

 IF ( v_publish_udas = 'Y')
  THEN

    SELECT Count(*) INTO v_count
    FROM EGO_PUB_WS_CONFIG
    WHERE SESSION_ID = sessionId
    AND  PARAMETER_NAME = 'PUBLISH_AG_NAME';

    v_query_string_b := 'SELECT DISTINCT egob.ATTRIBUTEGROUP_ID  , ' ||
                      ' egob.ATTRIBUTE_GROUP_NAME, '||
                      ' egob.ORGANIZATION_ID     , '||
                      ' egob.INVENTORY_ITEM_ID   , '||
                      ' egob.REVISION_ID         , '||
                      ' egob.APPLICATION_ID      , '||
                      ' egob.EXTENSION_ID        , '||
                      ' egob.DATA_LEVEL_ID       , '||
                      ' egob.PK1_VALUE           , '||
                      ' egob.PK2_VALUE         , '||
                      ' edlv.USER_DATA_LEVEL_NAME AS "DATA_LEVEL_NAME" , '||
                      ' flat.SEQUENCE_ID  , '||
                      ' ent.PK3_VALUE AS "PK3_VALUE" ,  '||
                      ' flat.PK2_VALUE AS "ORG_ID" '||
        ' FROM          ego_all_attr_base_v egob  , '||
                      ' EGO_DATA_LEVEL_VL edlv  , EGO_ODI_WS_ENTITIES ent, EGO_PUB_WS_FLAT_RECS flat '||
        ' WHERE        egob.DATA_LEVEL_ID = edlv.DATA_LEVEL_ID '||
        ' AND egob.APPLICATION_ID = edlv.APPLICATION_ID AND  '||
        ' ent.SESSION_ID = :1 '||
        ' AND ent.SESSION_ID=FLAT.SESSION_ID AND ent.PK1_VALUE=FLAT.PK1_VALUE '||
        ' AND ent.PK2_VALUE=FLAT.PK2_VALUE  AND ent.PK3_VALUE=FLAT.PK3_VALUE  ';


    v_query_string_l := 'SELECT DISTINCT egol.ATTRIBUTEGROUP_ID  , ' ||
                      ' egol.ATTRIBUTE_GROUP_NAME, '||
                      ' egol.ORGANIZATION_ID     , '||
                      ' egol.INVENTORY_ITEM_ID   , '||
                      ' egol.REVISION_ID         , '||
                      ' egol.APPLICATION_ID      , '||
                      ' egol.EXTENSION_ID        , '||
                      ' egol.DATA_LEVEL_ID       , '||
                      ' egol.PK1_VALUE           , '||
                      ' egol.PK2_VALUE         , '||
                      ' edlv.USER_DATA_LEVEL_NAME AS "DATA_LEVEL_NAME" , '||
                      ' flat.SEQUENCE_ID  , '||
                      ' ent.PK3_VALUE AS "PK3_VALUE" ,  '||
                      ' flat.PK2_VALUE AS "ORG_ID" '||
        ' FROM          ego_all_attr_lang_v egol  , '||
                      ' EGO_DATA_LEVEL_VL edlv  , EGO_ODI_WS_ENTITIES ent, EGO_PUB_WS_FLAT_RECS flat '||
        ' WHERE        egol.DATA_LEVEL_ID = edlv.DATA_LEVEL_ID '||
        ' AND egol.APPLICATION_ID = edlv.APPLICATION_ID AND  '||
        ' ent.SESSION_ID = :4 '||
        ' AND ent.SESSION_ID=FLAT.SESSION_ID AND ent.PK1_VALUE=FLAT.PK1_VALUE '||
        ' AND ent.PK2_VALUE=FLAT.PK2_VALUE  AND ent.PK3_VALUE=FLAT.PK3_VALUE  ';



        IF (datalevelId = 43101) THEN
          v_query_string_b := v_query_string_b || 'AND egob.data_level_id = 43101 '||
                              ' AND flat.PK1_VALUE = egob.INVENTORY_ITEM_ID '||
                              ' AND flat.REF1_VALUE = egob.ORGANIZATION_ID  '||
                              ' AND (nvl(egob.REVISION_ID,-1) = decode(nvl(egob.REVISION_ID,-1),-1,-1,flat.PK3_VALUE)) '||
                              ' AND FLAT.ENTITY_TYPE = ''ITEM'' ';

          v_query_string_l := v_query_string_l || 'AND egol.data_level_id = 43101 '||
                              ' AND flat.PK1_VALUE = egol.INVENTORY_ITEM_ID '||
                              ' AND flat.REF1_VALUE = egol.ORGANIZATION_ID  '||
                              ' AND (nvl(egol.REVISION_ID,-1) = decode(nvl(egol.REVISION_ID,-1),-1,-1,flat.PK3_VALUE)) '||
                              ' AND FLAT.ENTITY_TYPE = ''ITEM'' ';

        ELSIF   (datalevelId = 43102) THEN
          /* for Organization level Attribute Groups, datalevelId = 43102 */
          v_query_string_b := v_query_string_b || ' AND egob.data_level_id = 43102 AND '||
                              ' flat.PK1_VALUE = egob.INVENTORY_ITEM_ID AND '||
                              ' flat.PK2_VALUE = egob.ORGANIZATION_ID AND '||
                              ' FLAT.ENTITY_TYPE = ''ORGANIZATION'' ';

          v_query_string_l := v_query_string_l || ' AND egol.data_level_id = 43102 AND '||
                              ' flat.PK1_VALUE = egol.INVENTORY_ITEM_ID AND '||
                              ' flat.PK2_VALUE = egol.ORGANIZATION_ID AND '||
                              ' FLAT.ENTITY_TYPE = ''ORGANIZATION'' ';

        ELSIF (datalevelId = 43103) THEN
          /* for Supplier level Attribute Groups, datalevelId = 43103 */
          v_query_string_b := v_query_string_b || ' AND egob.data_level_id = 43103 AND '||
                              ' flat.PK1_VALUE = egob.INVENTORY_ITEM_ID AND '||
                              ' flat.REF2_VALUE = egob.ORGANIZATION_ID AND '||
                              ' flat.REF1_VALUE = egob.PK1_VALUE AND '||
                              ' FLAT.ENTITY_TYPE = ''SUPPLIER_ASSIGNMNET'' ';

          v_query_string_l := v_query_string_l || ' AND egol.data_level_id = 43103 AND '||
                              ' flat.PK1_VALUE = egol.INVENTORY_ITEM_ID AND '||
                              ' flat.REF2_VALUE = egol.ORGANIZATION_ID AND '||
                              ' flat.REF1_VALUE = egol.PK1_VALUE AND '||
                              ' FLAT.ENTITY_TYPE = ''SUPPLIER_ASSIGNMNET'' ';

        ELSIF (datalevelId = 43104) THEN
          /* for Supplier Site level Attribute Groups, datalevelId = 43104 */
          v_query_string_b := v_query_string_b || ' AND egob.data_level_id = 43104 AND '||
                              ' flat.PK1_VALUE = egob.INVENTORY_ITEM_ID AND '||
                              ' flat.REF2_VALUE = egob.ORGANIZATION_ID AND '||
                              ' flat.REF1_VALUE = egob.PK1_VALUE AND '||
                              ' flat.REF3_VALUE = egob.PK2_VALUE AND '||
                              ' FLAT.ENTITY_TYPE = ''SUPPLIER_SITE_ASSIGNMNET'' ';

          v_query_string_l := v_query_string_l || ' AND egol.data_level_id = 43104 AND '||
                              ' flat.PK1_VALUE = egol.INVENTORY_ITEM_ID AND '||
                              ' flat.REF2_VALUE = egol.ORGANIZATION_ID AND '||
                              ' flat.REF1_VALUE = egol.PK1_VALUE AND '||
                              ' flat.REF3_VALUE = egol.PK2_VALUE AND '||
                              ' FLAT.ENTITY_TYPE = ''SUPPLIER_SITE_ASSIGNMNET'' ';

        ELSIF (datalevelId = 43105) THEN
          /* for Supplier Site org level Attribute Groups, datalevelId = 43105 */
          v_query_string_b := v_query_string_b || ' AND egob.data_level_id = 43105 AND '||
                              ' flat.PK1_VALUE = egob.INVENTORY_ITEM_ID AND '||
                              ' flat.PK2_VALUE = egob.ORGANIZATION_ID AND '||
                              ' flat.REF1_VALUE = egob.PK1_VALUE AND '||
                              ' flat.REF2_VALUE = egob.PK2_VALUE AND '||
                              ' FLAT.ENTITY_TYPE = ''SUPPLIER_SITE_ORG_ASSIGNMNET'' ';

          v_query_string_l := v_query_string_l || ' AND egol.data_level_id = 43105 AND '||
                              ' flat.PK1_VALUE = egol.INVENTORY_ITEM_ID AND '||
                              ' flat.PK2_VALUE = egol.ORGANIZATION_ID AND '||
                              ' flat.REF1_VALUE = egol.PK1_VALUE AND '||
                              ' flat.REF2_VALUE = egol.PK2_VALUE AND '||
                              ' FLAT.ENTITY_TYPE = ''SUPPLIER_SITE_ORG_ASSIGNMNET'' ';

        ELSIF (datalevelId = 43106) THEN
          /* for Item Revision level Attribute Groups, datalevelId = 43106 */
          v_query_string_b := v_query_string_b || 'AND egob.data_level_id = 43106 '||
                              ' AND flat.PK1_VALUE = egob.INVENTORY_ITEM_ID '||
                              ' AND flat.PK2_VALUE = egob.ORGANIZATION_ID  '||    -- Bug: 8656001
                              ' AND flat.PK3_VALUE  = egob.REVISION_ID  '||
                              ' AND FLAT.ENTITY_TYPE = ''ITEM_REVISION'' ';

          v_query_string_l := v_query_string_l || 'AND egol.data_level_id = 43106 '||
                              ' AND flat.PK1_VALUE = egol.INVENTORY_ITEM_ID '||
                              ' AND flat.PK2_VALUE = egol.ORGANIZATION_ID  '||
                              ' AND flat.PK3_VALUE  = egol.REVISION_ID  '||       -- Bug: 8656001
                              ' AND FLAT.ENTITY_TYPE = ''ITEM_REVISION'' ';
        END IF;

        v_query_string_b := v_query_string_b || ' AND  '||
                            ' (:2 = 0 OR  '||
                            '   egob.ATTRIBUTE_GROUP_NAME IN (SELECT char_value FROM EGO_PUB_WS_CONFIG '||
                            '                                 WHERE  session_id = :3 '||
                            '                                 and PARAMETER_NAME = ''PUBLISH_AG_NAME'' ) '||
                            ' ) ';

        v_query_string_l := v_query_string_l || ' AND  '||
                            ' (:5 = 0 OR  '||
                            '   egol.ATTRIBUTE_GROUP_NAME IN (SELECT char_value FROM EGO_PUB_WS_CONFIG '||
                            '                                 WHERE  session_id = :6 '||
                            '                                 and PARAMETER_NAME = ''PUBLISH_AG_NAME'' ) '||
                            ' ) ';


        v_query_string :=  '( '||
                              v_query_string_b ||
                            ') '||
                            ' UNION '||
                            '( '||
                              v_query_string_l ||
                            ') ' ;

          BEGIN
            OPEN v_dynamic_cursor FOR v_query_string USING sessionId  ,
                                                           v_count    ,
                                                           sessionId  ,
                                                           sessionId  ,
                                                           v_count    ,
                                                           sessionId ;
            LOOP
              FETCH v_dynamic_cursor INTO v_attribute_group_id,
                                          v_attribute_group_name,
                                          v_organization_id     ,
                                          v_inventory_item_id   ,
                                          v_revision_id         ,
                                          v_application_id      ,
                                          v_extension_id        ,
                                          v_data_level_id       ,
                                          v_pk1_value           ,
                                          v_pk2_value           ,
                                          v_data_level_name     ,
                                          v_sequence_id         ,
                                          v_pk3_value           ,
                                          v_org_id ;

              EXIT WHEN v_dynamic_cursor%NOTFOUND;



                insert into     EGO_PUB_WS_FLAT_RECS
                (
                  SEQUENCE_ID,
                  SESSION_ID,
                  ODI_SESSION_ID,
                  ENTITY_TYPE,
                  PK1_VALUE,
                  PK2_VALUE,
                  PK3_VALUE,
                  REF1_VALUE,
                  REF2_VALUE,
                  REF3_VALUE,
                  REF4_VALUE,
                  PARENT_SEQUENCE_ID,
                  VALUE,
                  CREATION_DATE
                )
                select
                  EGO_PUB_WS_FLAT_RECS_S.nextval,
                  sessionId,
                  odiSessionId,
                  'ATTRIBUTE_GROUP',
                  v_inventory_item_id,
                  v_org_id,
                  v_pk3_value,
                  v_attribute_group_id,
                  v_extension_id ,
                  v_data_level_id,
                  v_organization_id,
                  v_sequence_id,
                  XMLForest(
                        v_attribute_group_id AS "ATTRIBUTEGROUP_ID",
                        v_attribute_group_name AS "ATTRIBUTE_GROUP_NAME",
                        v_extension_id AS "EXTENSION_ID",
                        v_data_level_name AS "DATA_LEVEL_NAME"
                        ).getclobval() ,
                  SYSDATE
                FROM dual;

            END LOOP;
            CLOSE v_dynamic_cursor;
          EXCEPTION
          WHEN OTHERS THEN
            IF (v_dynamic_cursor%ISOPEN) THEN
              CLOSE v_dynamic_cursor;
            END IF;
          END;

      /* Insert The UDA values other than translated char value, for all the AGs that were inserted into the flat table for the corresponding level */
      insert into     EGO_PUB_WS_FLAT_RECS
        (
                SEQUENCE_ID,
                SESSION_ID,
                ODI_SESSION_ID,
                ENTITY_TYPE,
                PK1_VALUE,
                PK2_VALUE,
                PK3_VALUE,
                REF1_VALUE,
                REF2_VALUE,
                REF3_VALUE ,
                REF4_VALUE ,
                REF5_VALUE ,
                PARENT_SEQUENCE_ID,
                VALUE,
                CREATION_DATE
        )
        select
                EGO_PUB_WS_FLAT_RECS_S.nextval,
                sessionId,
                odisessionId,
                'UDA',
                flat.PK1_VALUE ,
                flat.PK2_VALUE ,
                flat.PK3_VALUE ,
                list.ATTRIBUTEGROUP_ID ,
                list.EXTENSION_ID ,
                dataLevelId ,
                flat.REF4_VALUE ,
                list.ATTRIBUTE_ID ,
                flat.SEQUENCE_ID,
              XMLForest(
                  list.ATTRIBUTE_NAME AS "ATTRIBUTE_NAME",
                  list.ATTRIBUTE_CHAR_VALUE AS "ATTRIBUTE_CHAR_VALUE",
                  list.ATTRIBUTE_NUMBER_VALUE AS "ATTRIBUTE_NUMBER_VALUE",
                  list.ATTRIBUTE_UOM_VALUE AS "ATTRIBUTE_UOM_VALUE",
                  list.ATTRIBUTE_DATE_VALUE AS "ATTRIBUTE_DATE_VALUE",
                  list.ATTRIBUTE_DATETIME_VALUE AS "ATTRIBUTE_DATETIME_VALUE"  ,
                  evsv.DISPLAY_NAME AS "DISPLAY_VALUE"
              ).getclobval() ,
                    SYSDATE
      FROM (
              (SELECT
                  ATTRIBUTEGROUP_ID,
                  EXTENSION_ID,
                  ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  APPLICATION_ID,
                  DATA_LEVEL_ID,
                  ATTRIBUTE_ID,
                  ATTRIBUTE_NAME,
                  ATTRIBUTE_CHAR_VALUE,
                  ATTRIBUTE_NUMBER_VALUE,
                  ATTRIBUTE_UOM_VALUE,
                  ATTRIBUTE_DATE_VALUE,
                  ATTRIBUTE_DATETIME_VALUE,
                  null as TRANSLATED_CHAR_VALUE,
                  REVISION_ID
                  FROM ego_all_attr_base_v)
                ) list , EGO_PUB_WS_FLAT_RECS flat  ,
                ego_attrs_v eav, EGO_VALUE_SET_VALUES_V evsv
        WHERE
                  list.ATTRIBUTEGROUP_ID = FLAT.REF1_VALUE
                  AND list.EXTENSION_ID = FLAT.REF2_VALUE
                  AND list.INVENTORY_ITEM_ID = FLAT.PK1_VALUE
                  AND list.ORGANIZATION_ID =  Decode(dataLevelId , 43101, flat.REF4_VALUE,
                                                                  43103 , flat.REF4_VALUE,
                                                                  43104 , flat.REF4_VALUE,
                                                                    FLAT.PK2_VALUE )
                  AND nvl(list.REVISION_ID, -1) = Decode(nvl(list.REVISION_ID, -1), -1,-1,flat.PK3_VALUE)
                  AND  list.DATA_LEVEL_ID = dataLevelId
                  AND  FLAT.session_id = sessionId
                  AND  FLAT.ENTITY_TYPE = 'ATTRIBUTE_GROUP'

                  AND  eav.VALUE_SET_ID = evsv.VALUE_SET_ID (+)
                  AND eav.attr_id =   list.ATTRIBUTE_ID
                  AND Nvl(eav.enabled_flag, 'Y') = 'Y'  -- Bug 9542020
                  AND
                  (
                    ( list.ATTRIBUTE_CHAR_VALUE IS NOT NULL
                      AND Nvl(evsv.FORMAT_TYPE, 'C') = 'C'  -- Bug 9539538
                      AND Nvl(evsv.INTERNAL_NAME,list.ATTRIBUTE_CHAR_VALUE ) = list.ATTRIBUTE_CHAR_VALUE
                    )
                    OR
                    ( list.ATTRIBUTE_NUMBER_VALUE IS NOT NULL
                      AND Nvl(evsv.FORMAT_TYPE, 'N') = 'N'  -- Bug 9539538
                      AND Nvl(evsv.INTERNAL_NAME,list.ATTRIBUTE_NUMBER_VALUE) = list.ATTRIBUTE_NUMBER_VALUE
                    )
                    OR
                    ( list.ATTRIBUTE_DATE_VALUE IS NOT NULL
                      AND Nvl(evsv.FORMAT_TYPE, 'X') = 'X'  -- Bug 9539538
          -- Bug 9615220 Should change parameters to DATEor DATETIME, then compare
                      AND Nvl(To_Date(evsv.INTERNAL_NAME, 'YYYY-MM-DD HH24:MI:SS'),To_Date(list.ATTRIBUTE_DATE_VALUE, 'MM/DD/YYYY')) = To_Date(list.ATTRIBUTE_DATE_VALUE, 'MM/DD/YYYY')
                    )
                    OR
                    ( list.ATTRIBUTE_DATETIME_VALUE IS NOT NULL
                      AND Nvl(evsv.FORMAT_TYPE, 'Y') = 'Y'  -- Bug 9539538
          -- Bug 9615220 Should change parameters to DATEor DATETIME, then compare
                      AND Nvl(To_Date(evsv.INTERNAL_NAME, 'YYYY-MM-DD HH24:MI:SS'),To_Date(list.ATTRIBUTE_DATETIME_VALUE, 'MM/DD/YYYY HH24:MI:SS')) = To_Date(list.ATTRIBUTE_DATETIME_VALUE, 'MM/DD/YYYY HH24:MI:SS')
                    )
                  );

        -- Bug 8791039 : Below Query added to get the UDAs having NULL Values
        /* Bug 9582978 : Start
          Performance issue, Instead of single query, will insert the records in a loop so that
          XMLFORST doesn't cause performance issue.

        insert into     EGO_PUB_WS_FLAT_RECS
        (
                SEQUENCE_ID,
                SESSION_ID,
                ODI_SESSION_ID,
                ENTITY_TYPE,
                PK1_VALUE,
                PK2_VALUE,
                PK3_VALUE,
                REF1_VALUE,
                REF2_VALUE,
                REF3_VALUE ,
                REF4_VALUE ,
                REF5_VALUE ,
                PARENT_SEQUENCE_ID,
                VALUE,
                CREATION_DATE
        )
        select
                EGO_PUB_WS_FLAT_RECS_S.nextval,
                sessionId,
                odisessionId,
                'UDA',
                flat.PK1_VALUE ,
                flat.PK2_VALUE ,
                flat.PK3_VALUE ,
                list.ATTRIBUTEGROUP_ID ,
                list.EXTENSION_ID ,
                dataLevelId ,
                flat.REF4_VALUE ,
                list.ATTRIBUTE_ID ,
                flat.SEQUENCE_ID,
              XMLForest(
                  list.ATTRIBUTE_NAME AS "ATTRIBUTE_NAME",
                  list.ATTRIBUTE_CHAR_VALUE AS "ATTRIBUTE_CHAR_VALUE",
                  list.ATTRIBUTE_NUMBER_VALUE AS "ATTRIBUTE_NUMBER_VALUE",
                  list.ATTRIBUTE_UOM_VALUE AS "ATTRIBUTE_UOM_VALUE",
                  list.ATTRIBUTE_DATE_VALUE AS "ATTRIBUTE_DATE_VALUE",
                  list.ATTRIBUTE_DATETIME_VALUE AS "ATTRIBUTE_DATETIME_VALUE"  ,
                  NULL AS "DISPLAY_VALUE"
              ).getclobval() ,
                    SYSDATE
      FROM (
              (SELECT
                  ATTRIBUTEGROUP_ID,
                  EXTENSION_ID,
                  ORGANIZATION_ID,
                  INVENTORY_ITEM_ID,
                  APPLICATION_ID,
                  DATA_LEVEL_ID,
                  ATTRIBUTE_ID,
                  ATTRIBUTE_NAME,
                  ATTRIBUTE_CHAR_VALUE,
                  ATTRIBUTE_NUMBER_VALUE,
                  ATTRIBUTE_UOM_VALUE,
                  ATTRIBUTE_DATE_VALUE,
                  ATTRIBUTE_DATETIME_VALUE,
                  null as TRANSLATED_CHAR_VALUE,
                  REVISION_ID
                  FROM ego_all_attr_base_v)
                ) list , EGO_PUB_WS_FLAT_RECS flat  ,
                ego_attrs_v eav
        WHERE
                  list.ATTRIBUTEGROUP_ID = FLAT.REF1_VALUE
                  AND list.EXTENSION_ID = FLAT.REF2_VALUE
                  AND list.INVENTORY_ITEM_ID = FLAT.PK1_VALUE
                  AND list.ORGANIZATION_ID =  Decode(dataLevelId , 43101, flat.REF4_VALUE,
                                                                  43103 , flat.REF4_VALUE,
                                                                  43104 , flat.REF4_VALUE,
                                                                    FLAT.PK2_VALUE )
                  AND nvl(list.REVISION_ID, -1) = Decode(nvl(list.REVISION_ID, -1), -1,-1,flat.PK3_VALUE)
                  AND  list.DATA_LEVEL_ID = dataLevelId
                  AND  FLAT.session_id = sessionId
                  AND  FLAT.ENTITY_TYPE = 'ATTRIBUTE_GROUP'
                  AND eav.attr_id =   list.ATTRIBUTE_ID
                  AND Nvl(eav.enabled_flag, 'Y') = 'Y'  -- Bug 9542020
                  AND list.ATTRIBUTE_CHAR_VALUE IS  NULL
                  AND list.ATTRIBUTE_NUMBER_VALUE IS  NULL
                  AND list.ATTRIBUTE_DATE_VALUE IS  NULL
                  AND list.ATTRIBUTE_DATETIME_VALUE IS  NULL;
        */

        -- Get all the details of UDAs having NULL values and insert in the loop.
        FOR i IN (SELECT
                    list.ATTRIBUTEGROUP_ID,
                    list.EXTENSION_ID,
                    list.ATTRIBUTE_ID,
                    list.ATTRIBUTE_NAME ,
                    list.ATTRIBUTE_CHAR_VALUE,
                    list.ATTRIBUTE_NUMBER_VALUE,
                    list.ATTRIBUTE_UOM_VALUE,
                    list.ATTRIBUTE_DATE_VALUE,
                    list.ATTRIBUTE_DATETIME_VALUE,
                    list.REVISION_ID ,
                    flat.PK1_VALUE ,
                    flat.PK2_VALUE ,
                    flat.PK3_VALUE ,
                    flat.REF4_VALUE ,
                    flat.SEQUENCE_ID
                  FROM  ego_all_attr_base_v list , EGO_PUB_WS_FLAT_RECS flat  ,
                    ego_attrs_v eav
                  WHERE
                    list.ATTRIBUTEGROUP_ID = FLAT.REF1_VALUE
                    AND list.EXTENSION_ID = FLAT.REF2_VALUE
                    AND list.INVENTORY_ITEM_ID = FLAT.PK1_VALUE
                    AND list.ORGANIZATION_ID =  Decode(dataLevelId , 43101, flat.REF4_VALUE,
                                                                    43103 , flat.REF4_VALUE,
                                                                    43104 , flat.REF4_VALUE,
                                                                      FLAT.PK2_VALUE )
                    AND nvl(list.REVISION_ID, -1) = Decode(nvl(list.REVISION_ID, -1), -1,-1,flat.PK3_VALUE)
                    AND  list.DATA_LEVEL_ID = dataLevelId
                    AND  FLAT.session_id = sessionId
                    AND  FLAT.ENTITY_TYPE = 'ATTRIBUTE_GROUP'
                    AND eav.attr_id =   list.ATTRIBUTE_ID
                    AND Nvl(eav.enabled_flag, 'Y') = 'Y'  -- Bug 9542020
                    AND
                      (list.DATA_TYPE_CODE = 'C' AND list.ATTRIBUTE_CHAR_VALUE IS  NULL
                        OR
                        list.DATA_TYPE_CODE = 'N' AND list.ATTRIBUTE_NUMBER_VALUE IS  NULL
                        OR
                        list.DATA_TYPE_CODE = 'X' AND list.ATTRIBUTE_DATE_VALUE IS  NULL
                        OR
                        list.DATA_TYPE_CODE = 'Y' AND list.ATTRIBUTE_DATETIME_VALUE IS  NULL
                    )
                  )
        LOOP

          insert into     EGO_PUB_WS_FLAT_RECS
          (
            SEQUENCE_ID,
            SESSION_ID,
            ODI_SESSION_ID,
            ENTITY_TYPE,
            PK1_VALUE,
            PK2_VALUE,
            PK3_VALUE,
            REF1_VALUE,
            REF2_VALUE,
            REF3_VALUE ,
            REF4_VALUE ,
            REF5_VALUE ,
            PARENT_SEQUENCE_ID,
            VALUE,
            CREATION_DATE
          )
          select
            EGO_PUB_WS_FLAT_RECS_S.nextval,
            sessionId,
            odisessionId,
            'UDA',
            i.PK1_VALUE ,
            i.PK2_VALUE ,
            i.PK3_VALUE ,
            i.ATTRIBUTEGROUP_ID ,
            i.EXTENSION_ID ,
            dataLevelId ,
            i.REF4_VALUE ,
            i.ATTRIBUTE_ID ,
            i.SEQUENCE_ID,
            XMLForest(
              i.ATTRIBUTE_NAME AS "ATTRIBUTE_NAME",
              i.ATTRIBUTE_CHAR_VALUE AS "ATTRIBUTE_CHAR_VALUE",
              i.ATTRIBUTE_NUMBER_VALUE AS "ATTRIBUTE_NUMBER_VALUE",
              i.ATTRIBUTE_UOM_VALUE AS "ATTRIBUTE_UOM_VALUE",
              i.ATTRIBUTE_DATE_VALUE AS "ATTRIBUTE_DATE_VALUE",
              i.ATTRIBUTE_DATETIME_VALUE AS "ATTRIBUTE_DATETIME_VALUE"  ,
              NULL AS "DISPLAY_VALUE"
            ).getclobval() ,
            SYSDATE
          FROM dual;
      END LOOP;
      -- Bug 9582978 : End


        /* Insert the translated char value if exists, for all the AGs that were inserted into the flat table for the corresponding level */
        insert into     EGO_PUB_WS_FLAT_RECS
        (
                SEQUENCE_ID,
                SESSION_ID,
                ODI_SESSION_ID,
                ENTITY_TYPE,
                PK1_VALUE,
                PK2_VALUE,
                PK3_VALUE,
                REF1_VALUE,
                REF2_VALUE,
                REF3_VALUE,
                REF4_VALUE,
                REF5_VALUE,
                REF6_VALUE,
                PARENT_SEQUENCE_ID,
                VALUE,
                CREATION_DATE
        )
        select
                EGO_PUB_WS_FLAT_RECS_S.nextval,
                sessionId,
                odisessionId,
                'UDA',
                flat.PK1_VALUE ,
                flat.PK2_VALUE ,
                flat.PK3_VALUE ,
                list.ATTRIBUTEGROUP_ID ,
                list.EXTENSION_ID ,
                dataLevelId ,
                flat.REF4_VALUE ,
                list.ATTRIBUTE_ID ,
                'TRANSLATED_CHAR_VALUE' ,
                flat.SEQUENCE_ID,
                XMLForest(
                  list.ATTRIBUTE_NAME AS "ATTRIBUTE_NAME",
                  list.TRANSLATED_CHAR_VALUE AS TRANSLATED_CHAR_VALUE
                ).getclobval() ,
                    SYSDATE
        FROM (
              (SELECT
                    ATTRIBUTEGROUP_ID,
                    EXTENSION_ID,
                    ORGANIZATION_ID,
                    INVENTORY_ITEM_ID,
                    APPLICATION_ID,
                    DATA_LEVEL_ID,
                    ATTRIBUTE_ID,
                    ATTRIBUTE_NAME,
                    ATTRIBUTE_TRANSLATABLE_VALUE as TRANSLATED_CHAR_VALUE,
                    REVISION_ID
                    FROM ego_all_attr_lang_v
                  where language = userenv('LANG'))
                ) list , EGO_PUB_WS_FLAT_RECS flat
                , ego_attrs_v eav   -- Bug 9542020
        WHERE
                  list.ATTRIBUTEGROUP_ID = FLAT.REF1_VALUE
                  AND list.EXTENSION_ID = FLAT.REF2_VALUE
                  AND list.INVENTORY_ITEM_ID = FLAT.PK1_VALUE
                  AND list.ORGANIZATION_ID =  Decode(dataLevelId , 43101, flat.REF4_VALUE,
                                                                  43103 , flat.REF4_VALUE,
                                                                  43104 , flat.REF4_VALUE,
                                                                    FLAT.PK2_VALUE )
                  AND  nvl(list.REVISION_ID, -1) = Decode(nvl(list.REVISION_ID, -1), -1,-1,flat.PK3_VALUE)
                  AND  list.DATA_LEVEL_ID = dataLevelId
                  -- Bug 9542020 - Start
                  AND eav.attr_id =   list.ATTRIBUTE_ID
                  AND Nvl(eav.enabled_flag, 'Y') = 'Y'
                  -- Bug 9542020 - End
                  AND  FLAT.session_id = sessionId
                  AND  FLAT.ENTITY_TYPE = 'ATTRIBUTE_GROUP';

        /* Insert Translatable values ( for Trabslated char value )*/
        insert into     EGO_PUB_WS_FLAT_RECS
        (
                SEQUENCE_ID,
                SESSION_ID,
                ODI_SESSION_ID,
                ENTITY_TYPE,
                PK1_VALUE,
                PK2_VALUE,
                PK3_VALUE,
                REF1_VALUE,
                PARENT_SEQUENCE_ID,
                VALUE,
                CREATION_DATE
        )
        select
                EGO_PUB_WS_FLAT_RECS_S.nextval,
                sessionId,
                odisessionId,
                'UDA_TRANSLATIONS',
                flat.PK1_VALUE ,
                flat.PK2_VALUE ,
                flat.PK3_VALUE ,
                dataLevelId ,
                flat.SEQUENCE_ID,
                XMLForest(
                  CONFIG.CHAR_VALUE AS "Language" ,
                  list.TRANSLATED_CHAR_VALUE AS "Value"
                ).getclobval() ,
                    SYSDATE
        FROM (SELECT
                    ATTRIBUTEGROUP_ID,
                    EXTENSION_ID,
                    ORGANIZATION_ID,
                    INVENTORY_ITEM_ID,
                    APPLICATION_ID,
                    DATA_LEVEL_ID,
                    ATTRIBUTE_ID,
                    ATTRIBUTE_NAME,
                    ATTRIBUTE_TRANSLATABLE_VALUE as TRANSLATED_CHAR_VALUE,
                    REVISION_ID,
                    LANGUAGE
                    FROM ego_all_attr_lang_v ealv
                ) list , EGO_PUB_WS_FLAT_RECS flat , EGO_PUB_WS_CONFIG CONFIG
        WHERE   list.ATTRIBUTEGROUP_ID = FLAT.REF1_VALUE
                  AND list.EXTENSION_ID = FLAT.REF2_VALUE
                  AND list.INVENTORY_ITEM_ID = FLAT.PK1_VALUE
                  AND list.ORGANIZATION_ID =  Decode(dataLevelId , 43101, flat.REF4_VALUE,
                                                                  43103 , flat.REF4_VALUE,
                                                                  43104 , flat.REF4_VALUE,
                                                                    FLAT.PK2_VALUE )
                  AND  nvl(list.REVISION_ID, -1) = Decode(nvl(list.REVISION_ID, -1), -1,-1,flat.PK3_VALUE)
                  AND To_Char(list.ATTRIBUTE_ID) = flat.REF5_VALUE
                  AND To_Char(list.DATA_LEVEL_ID) = flat.REF3_VALUE
                  AND list.DATA_LEVEL_ID = dataLevelId
                  AND To_Char(list.INVENTORY_ITEM_ID) = flat.PK1_VALUE
                  AND  FLAT.session_id = sessionId
                  AND  CONFIG.SESSION_ID = FLAT.SESSION_ID
                  AND CONFIG.CHAR_VALUE = list.LANGUAGE
                  AND FLAT.ENTITY_TYPE = 'UDA'
                  AND CONFIG.PARAMETER_NAME = 'LANGUAGE_CODE'
                  AND FLAT.REF6_VALUE = 'TRANSLATED_CHAR_VALUE';

        COMMIT;
  END IF; --  if for v_publish_udas
END;

-- This Procedure inserts the GTIN XRef Deetails associated to an Item into the table EGO_PUB_WS_FLAT_RECS
PROCEDURE POPULATE_GTIN_DETAILS
(sessionId IN NUMBER,
odisessionId IN NUMBER
)
AS

BEGIN

    insert into     EGO_PUB_WS_FLAT_RECS
      (
              SEQUENCE_ID,
              SESSION_ID,
              ODI_SESSION_ID,
              ENTITY_TYPE,
              PK1_VALUE,
              PK2_VALUE,
              PK3_VALUE,
              REF1_VALUE,
              PARENT_SEQUENCE_ID,
              VALUE,
              CREATION_DATE
      )
      SELECT
              EGO_PUB_WS_FLAT_RECS_S.nextval,
              sessionId,
              odiSessionId,
              'GTIN_CROSS_REFERENCE',
              flat.PK1_VALUE,
              flat.PK2_VALUE,
              flat.PK3_VALUE,
              CROSS_REFERENCE_ID,
              flat.SEQUENCE_ID,
              XMLForest(
                     EgoGtinEO.CROSS_REFERENCE AS "CrossReference" ,
                     A.ITEM_NUMBER AS "PackItemNumber" ,
                     EgoGtinEO.DESCRIPTION AS "GTINDescription" ,
                     EgoGtinEO.UOM_CODE AS "UnitOfMeasure" ,
                     (SELECT MIR.REVISION
                      FROM    MTL_ITEM_REVISIONS_B MIR
                      WHERE   EgoGtinEO.REVISION_ID = MIR.REVISION_ID
                    ) AS "Revision" ,
                    EgoGtinEO.CROSS_REFERENCE_ID AS "CrossReferenceId" ,
                    EgoGtinEO.EPC_GTIN_SERIAL AS "EpcGtinSerial"
                    ).getclobval() ,
             SYSDATE
      FROM
       MTL_CROSS_REFERENCES EgoGtinEO                              ,
       MTL_SYSTEM_ITEMS_B MSIB                                     ,
       MTL_PARAMETERS MP                                           ,
       ( SELECT DISTINCT MCR1.CROSS_REFERENCE                      ,
                        MSIK.INVENTORY_ITEM_ID                     ,
                        MSIK.CONCATENATED_SEGMENTS ITEM_NUMBER     ,
                        MSIK.ORGANIZATION_ID MASTER_ORGANIZATION_ID,
                        MSIK.PRIMARY_UOM_CODE
       FROM             MTL_CROSS_REFERENCES_B MCR1,
                        MTL_SYSTEM_ITEMS_KFV MSIK  ,
                        MTL_PARAMETERS MP1
       WHERE            MCR1.CROSS_REFERENCE_TYPE = 'GTIN'
                    AND MCR1.INVENTORY_ITEM_ID    = MSIK.INVENTORY_ITEM_ID
                    AND MSIK.ORGANIZATION_ID      = MP1.MASTER_ORGANIZATION_ID
                    AND MSIK.PRIMARY_UOM_CODE     = trim(MCR1.UOM_CODE)
       ) A,
       EGO_PUB_WS_FLAT_RECS flat
   WHERE  EgoGtinEO.INVENTORY_ITEM_ID    = MSIB.INVENTORY_ITEM_ID
   AND  MP.ORGANIZATION_ID             = flat.PK2_VALUE
   AND MSIB.ORGANIZATION_ID           = MP.MASTER_ORGANIZATION_ID
   AND EgoGtinEO.CROSS_REFERENCE_TYPE = 'GTIN'
   AND MP.MASTER_ORGANIZATION_ID = flat.PK2_VALUE
   AND EgoGtinEO.CROSS_REFERENCE      = A.CROSS_REFERENCE(+)
   AND flat.PK1_VALUE = EgoGtinEO.INVENTORY_ITEM_ID
   AND flat.ENTITY_TYPE = 'ITEM'
   AND flat.SESSION_ID = sessionId ;


   /* Insert Translations for GTIN */
   insert into     EGO_PUB_WS_FLAT_RECS
      (
              SEQUENCE_ID,
              SESSION_ID,
              ODI_SESSION_ID,
              ENTITY_TYPE,
              PK1_VALUE,
              PK2_VALUE,
              PK3_VALUE,
              PARENT_SEQUENCE_ID,
              VALUE,
              CREATION_DATE
      )
      SELECT
              EGO_PUB_WS_FLAT_RECS_S.nextval,
              sessionId,
              odiSessionId,
              'GTIN_CROSS_REFERENCE_TRANSLATIONS',
              flat.PK1_VALUE,
              flat.PK2_VALUE,
              flat.PK3_VALUE,
              flat.SEQUENCE_ID,
              XMLForest(
                     config.char_value AS "Language" ,
                     mcrt.DESCRIPTION  AS "GTINDescription"
                    ).getclobval() ,
             SYSDATE
      FROM  MTL_CROSS_REFERENCES_TL mcrt, EGO_PUB_WS_CONFIG config, EGO_PUB_WS_FLAT_RECS flat
      WHERE config.SESSION_ID = flat.SESSION_ID
      AND config.PARAMETER_NAME = 'LANGUAGE_CODE'
      AND config.CHAR_VALUE = mcrt.LANGUAGE
      AND flat.ENTITY_TYPE = 'GTIN_CROSS_REFERENCE'
      AND flat.REF1_VALUE = mcrt.CROSS_REFERENCE_ID
      AND flat.SESSION_ID = sessionId
      AND Nvl(mcrt.DESCRIPTION, 1) = Nvl(mcrt.DESCRIPTION, 2);

      COMMIT;

  END;


-- This Procedure inserts the Transaction Attributee details associated to an Item into the table EGO_PUB_WS_FLAT_RECS
PROCEDURE POPULATE_Transaction_Attrs
          (sessionId IN NUMBER,
          odisessionId IN NUMBER
          )
AS
      l_item_start_date    DATE ;/*Item start effective date*/
      l_item_create_date   DATE ;/*Item create  date*/
      l_version_seq_id     VARCHAR2(5);
      l_ta_entered_count   NUMBER;
      l_ta_count           NUMBER;

      CURSOR Cur_TA_List (cp_item_catalog_category_id  NUMBER,
                          cp_icc_version_number        NUMBER,
                          cp_creation_date             DATE ,
                          cp_start_date         DATE )
      IS

      SELECT * FROM
      (
      SELECT  *
      FROM
              (
                      SELECT  versions.item_catalog_group_id,
                              versions.icc_version_NUMBER   ,
                              attrs.attr_id                  ,
                              attrs.attr_name                ,
                              hier.lev     lev
                      FROM    ego_obj_AG_assocs_b assocs       ,
                              ego_attrs_v attrs                ,
                              ego_attr_groups_v ag             ,
                              EGO_TRANS_ATTR_VERS_B versions,
                              mtl_item_catalog_groups_kfv icv  ,
                              (
                                      SELECT  item_catalog_group_id,
                                              LEVEL lev
                                      FROM    mtl_item_catalog_groups_b
                                      START WITH item_catalog_group_id = cp_item_catalog_category_id
                                      CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                              )
                              hier
                      WHERE   ag.attr_group_type                      = 'EGO_ITEM_TRANS_ATTR_GROUP'
                          AND assocs.attr_group_id                    = ag.attr_group_id
                          AND assocs.classification_code              = TO_CHAR(hier.item_catalog_group_id)
                          AND attrs.attr_group_name                   = ag.attr_group_name
                          AND TO_CHAR(icv.item_catalog_group_id)      = assocs.classification_code
                          AND TO_CHAR(versions.association_id)        = assocs.association_id
                          AND TO_CHAR(versions.item_catalog_group_id) = assocs.classification_code
                          AND attrs.attr_id                           = versions.attr_id

              )


      )
      WHERE
      (
        ( LEV = 1 AND ICC_VERSION_number =cp_icc_version_number )
        OR
        ( LEV > 1 AND ( item_catalog_group_id, ICC_VERSION_NUMBER )
                  IN ( SELECT  item_catalog_group_id, VERSION_SEQ_ID
                      FROM EGO_MTL_CATALOG_GRP_VERS_B
                      WHERE (item_catalog_group_id,start_active_date )
                              IN
                            (SELECT  item_catalog_group_id, MAX(start_active_date) start_active_date
                            FROM    EGO_MTL_CATALOG_GRP_VERS_B
                            WHERE  creation_date <= cp_creation_date
                                AND version_seq_id > 0
                                AND  start_active_date <=  cp_start_date
                            GROUP BY item_catalog_group_id
                            HAVING MAX(start_active_date)<=cp_start_date
                            )
                      AND version_seq_id > 0
                    )
        )
      );


      CURSOR cur_item_list
      IS
      SELECT sequence_id,parent_sequence_id,pk1_value item_id ,pk2_value org_id, pk3_value rev_id
      FROM EGO_PUB_WS_FLAT_RECS
      WHERE session_id= sessionId
          AND odi_session_id = odisessionId
          AND entity_type ='ITEM_REVISION';


    l_item_ta_metadata_tbl      EGO_TRAN_ATTR_TBL;
    l_return_status            VARCHAR2(1):=NULL ;
    l_item_catalog_group_id       VARCHAR2(10);
    l_is_modified   VARCHAR2(2);
    l_is_inherited  VARCHAR2(2);


BEGIN
    l_item_ta_metadata_tbl := EGO_TRAN_ATTR_TBL(NULL);
     /* If input parameter has been passed then process data*/
     FOR j IN cur_item_list
     LOOP
       IF(j.item_id IS NOT NULL AND j.org_id IS NOT NULL AND j.rev_id IS NOT null)
       THEN
          --Finding which ICC is associated ot the item.
          SELECT ITEM_CATALOG_GROUP_ID INTO  l_item_catalog_group_id FROM MTL_SYSTEM_ITEMS_VL
          WHERE INVENTORY_ITEM_ID = j.item_id AND ORGANIZATION_ID = j.org_id ;

         IF(l_item_catalog_group_id IS NULL ) THEN
              NULL;
         ELSE
             SELECT  EFFECTIVITY_DATE  ,CREATION_DATE
             INTO l_item_start_date, l_item_create_date
             FROM  MTL_ITEM_REVISIONS_VL
             WHERE INVENTORY_ITEM_ID = j.item_id
             AND ORGANIZATION_ID = j.org_id
             AND REVISION_ID =  j.rev_id;

             -- Bug 8690445 : Added the Exception Block
             BEGIN
               --Finding out which ICC version is effective at a time of item creation.
               SELECT  VERSION_SEQ_ID INTO l_version_seq_id
               FROM EGO_MTL_CATALOG_GRP_VERS_B
               WHERE   (ITEM_CATALOG_GROUP_ID, start_active_date) IN
                       (
                        SELECT  ITEM_CATALOG_GROUP_ID,Max(START_ACTIVE_DATE) START_ACTIVE_DATE
                        FROM    EGO_MTL_CATALOG_GRP_VERS_B
                        WHERE   CREATION_DATE <= l_item_create_date AND
                              ITEM_CATALOG_GROUP_ID = l_item_catalog_group_id AND
                              START_ACTIVE_DATE <= l_item_start_date AND VERSION_SEQ_ID >0
                        GROUP BY ITEM_CATALOG_GROUP_ID
                        HAVING MAX(START_ACTIVE_DATE) <= l_item_start_date
                       );
             EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_version_seq_id := NULL;
             END;
         END IF;
         IF (l_item_catalog_group_id IS NOT NULL AND l_version_seq_id IS NOT NULL)
         THEN
            SELECT Count(*)
            INTO l_ta_entered_count
            FROM EGO_PUB_WS_CONFIG
            WHERE PARAMETER_NAME = 'PUBLISH_TA_ID'
            AND SESSION_ID = sessionId;

            FOR k IN Cur_TA_List(l_item_catalog_group_id, l_version_seq_id, l_item_create_date,l_item_start_date)
            LOOP
               SELECT Count(*)
               INTO l_ta_count
               FROM EGO_PUB_WS_CONFIG
               WHERE PARAMETER_NAME = 'PUBLISH_TA_ID'
               AND SESSION_ID = sessionId
               AND NUMERIC_VALUE = k.attr_id;

               IF (l_ta_entered_count = 0 OR l_ta_count <> 0) THEN
                  EGO_TRANSACTION_ATTRS_PVT.GET_TRANS_ATTR_METADATA(
                                                x_ta_metadata_tbl =>l_item_ta_metadata_tbl
                                                , p_item_catalog_category_id  => NULL
                                                , p_icc_version  => NULL
                                                , p_attribute_id => k.attr_id
                                                , p_inventory_item_id  => j.item_id
                                                , p_organization_id    => j.org_id
                                                , p_revision_id        => j.rev_id
                                                , x_is_inherited   => l_is_inherited
                                                , x_is_modified    => l_is_modified
                                                , x_return_status => l_return_status );


                  FOR i IN  l_item_ta_metadata_tbl.first..l_item_ta_metadata_tbl.last
                  LOOP
                    INSERT INTO EGO_PUB_WS_FLAT_RECS
                    (
                      SEQUENCE_ID,
                      SESSION_ID,
                      ODI_SESSION_ID,
                      ENTITY_TYPE,
                      PK1_VALUE,
                      PK2_VALUE,
                      PK3_VALUE,
                      REF1_VALUE,
                      PARENT_SEQUENCE_ID,
                      VALUE,
                      CREATION_DATE
                    )
                    SELECT
                        EGO_PUB_WS_FLAT_RECS_S.nextval,
                        sessionId  ,
                        odisessionId,
                        'TRANSACTION_ATTRIBUTE',
                        j.item_id,
                        j.org_id,
                        j.rev_id,
                        k.attr_id,
                        j.sequence_id,
                        xmlforest(l_item_ta_metadata_tbl(i).attrid as "AttributeId",
                                  k.attr_name as "AttrName",
                                  l_item_ta_metadata_tbl(i).AttrDisplayName as "AttrDisplayName",
                                  l_item_ta_metadata_tbl(i).SEQUENCE as "AttrSequence",
                                  l_item_ta_metadata_tbl(i).ValueSetName AS "ValueSetName", -- Bug  8643860
                                  l_item_ta_metadata_tbl(i).UomClass AS "UomClass",   -- Bug  8643860
                                  l_item_ta_metadata_tbl(i).defaultvalue as "DeafultValue",
                                  l_item_ta_metadata_tbl(i).rejectedvalue as "RejectedValue",
                                  l_item_ta_metadata_tbl(i).requiredflag as "RequiredFlag",
                                  l_item_ta_metadata_tbl(i).readonlyflag as "ReadOnlyFlag",
                                  l_item_ta_metadata_tbl(i).hiddenflag as "HiddenFlag",
                                  l_item_ta_metadata_tbl(i).searchableflag as "SearchableFlag",
                                  l_item_ta_metadata_tbl(i).checkeligibility as "CheckEligibility" ,
                                  l_is_inherited AS "Inherited",
                                  l_is_modified  AS "Modified"
                                  ).getclobval()
                                  ,SYSDATE
                    FROM dual ;
                  END LOOP; -- loop i
               END IF; -- end of if (l_ta_entered_count = 0 OR l_ta_count <> 0)
            END LOOP; -- loop k
         END IF;
       END IF;
     END LOOP; -- loop j

     COMMIT;
EXCEPTION
  WHEN OTHERS
  THEN
    RAISE;
END;


/* Procedure to get invocation Mode and setting batch_id based on invocation mode
   If mode is 'BATCH' then it will give some Batch Id, If mode is 'HMDM' or 'LIST' then
   Batch Id will be -1*/
PROCEDURE Invocation_Mode ( p_session_id    IN  NUMBER,
                            p_odi_session_id IN NUMBER,
                            p_search_str    IN  VARCHAR2,
                            x_mode          OUT NOCOPY VARCHAR2,
                            x_batch_id      OUT NOCOPY NUMBER  )
IS

    --Local Variable
    l_mode         VARCHAR2(20) := 'MODE';
    l_batch_id     NUMBER := -1;
    l_exists       NUMBER;
    l_exists_inv_id NUMBER;
    l_exists_inv_name NUMBER;
    l_exists_items_list NUMBER;
    l_exists_org_id NUMBER;
    l_exists_org_code NUMBER;
    l_exists_rev_id NUMBER;
    l_exists_revision NUMBER;
    l_exists_rev_date NUMBER;
    l_inv_id NUMBER := -1;
    l_segments_provided BOOLEAN := FALSE;

    l_segment_1         mtl_system_items_b.segment1%TYPE;
    l_segment_2         mtl_system_items_b.segment2%TYPE;
    l_segment_3         mtl_system_items_b.segment3%TYPE;
    l_segment_4         mtl_system_items_b.segment4%TYPE;
    l_segment_5         mtl_system_items_b.segment5%TYPE;
    l_segment_6         mtl_system_items_b.segment6%TYPE;
    l_segment_7         mtl_system_items_b.segment7%TYPE;
    l_segment_8         mtl_system_items_b.segment8%TYPE;
    l_segment_9         mtl_system_items_b.segment9%TYPE;
    l_segment_10        mtl_system_items_b.segment10%TYPE;
    l_segment_11        mtl_system_items_b.segment11%TYPE;
    l_segment_12        mtl_system_items_b.segment12%TYPE;
    l_segment_13        mtl_system_items_b.segment13%TYPE;
    l_segment_14        mtl_system_items_b.segment14%TYPE;
    l_segment_15        mtl_system_items_b.segment15%TYPE;

BEGIN

      --if BatchId node exist and It has some value then we are in 'BATCH' mode
      -- p_search_str = '/itemQueryParameters/BatchId' for Batch

      SELECT existsNode(xmlcontent, p_search_str)
      INTO l_exists
      FROM EGO_PUB_WS_PARAMS
      WHERE session_id = p_session_id;

      IF l_exists=1 THEN
          /*If node exist for 'BatchId' then extractValue for BatchId'*/
          SELECT Nvl(extractValue(xmlcontent,p_search_str),-1)
          INTO l_batch_id
          FROM EGO_PUB_WS_PARAMS
          WHERE session_id = p_session_id;
      END IF;

      IF(l_exists <> 1 or (l_exists = 1 and l_batch_id = -1)) THEN

              SELECT existsNode(xmlcontent, '/itemQueryParameters/InventoryItemId') ,
              existsNode(xmlcontent, '/itemQueryParameters/InventoryItemName')
              INTO l_exists_inv_id , l_exists_inv_name
              FROM EGO_PUB_WS_PARAMS
              WHERE session_id = p_session_id;

              SELECT existsNode(xmlcontent, '/itemQueryParameters/OrganizationId') ,
              existsNode(xmlcontent, '/itemQueryParameters/OrganizationCode')
              INTO l_exists_org_id , l_exists_org_code
              FROM EGO_PUB_WS_PARAMS
              WHERE session_id = p_session_id;

              SELECT existsNode(xmlcontent, '/itemQueryParameters/RevisionId') ,
              existsNode(xmlcontent, '/itemQueryParameters/Revision') ,
              existsNode(xmlcontent, '/itemQueryParameters/RevisionDate')
              INTO l_exists_rev_id , l_exists_revision, l_exists_rev_date
              FROM EGO_PUB_WS_PARAMS
              WHERE session_id = p_session_id;

              process_non_batch_flow(p_session_id,
                        p_odi_session_id,
                        l_exists_inv_id,
                        l_exists_inv_name ,
                        l_exists_org_id,
                        l_exists_org_code,
                        l_exists_rev_id,
                        l_exists_revision ,
                        l_exists_rev_date ,
                        l_mode
                      );

             IF l_mode <> 'LIST' AND l_mode <> 'HMDM'
             THEN
                raise e_invalid_invocation_mode;
             END IF ;
      ELSE
        l_mode:= 'BATCH';
      END IF;

      x_mode := l_mode;
      x_batch_id:= l_batch_id;
EXCEPTION
  WHEN e_invalid_invocation_mode THEN
   RAISE e_invalid_invocation_mode;

END Invocation_Mode;


PROCEDURE  process_bom_explosions(p_session_id    IN  NUMBER,
                                  p_odi_session_id IN NUMBER,
                                  p_index     IN NUMBER,
                                  pk1_value   IN VARCHAR2 ,
                                  pk2_value   IN varchar2,
                                  pk3_value   IN varchar2,
                                  rev_date    IN Date,
                                  alternate_desg  IN VARCHAR2  DEFAULT NULL,
                                  levels_explode  IN NUMBER DEFAULT 60,
                                  explode_option  IN NUMBER,
                                  explode_std_bom IN VARCHAR2, -- Bug 8752314 : CMR Change
                                  group_id        OUT NOCOPY NUMBER,
                                  x_error_code    OUT NOCOPY VARCHAR2 ,
                                  x_error_message OUT NOCOPY VARCHAR2
                                  )
IS

 g_id number;
 top_bill_seq_id NUMBER;

 BEGIN

    bom_exploder_pub.exploder_userexit
    (   org_id           =>     to_number(pk2_value)
      , rev_date         =>     rev_date
      ,order_by          =>     1
    ,levels_to_explode   =>     levels_explode
    ,impl_flag           =>     1        /* 1 - Imp Only, 2 - imp and unimpl */
    ,alt_desg            =>     alternate_desg
    ,error_code          =>     x_error_code
    ,err_msg             =>     x_error_message
    ,bom_or_eng          =>     2  /* 1- BOM , 2 - ENG */
    ,explode_option      =>     explode_option
    ,grp_id              =>     g_id
    ,material_ctrl       =>     1
    ,pk_value1           =>    pk1_value
    ,pk_value2           =>    pk2_value
    ,std_bom_explode_flag =>   explode_std_bom  -- Bug 8752314 : CMR Change
    );

    if( To_Number(Nvl(x_error_code,0)) <> 0) THEN
      EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                        p_odi_session_id => p_odi_session_id,
                        p_input_id  => p_index ,
                        p_err_code => 'BOM_EXPLOSION_ERROR',
                        p_err_message => 'Error: Error Occured while exploding the '||alternate_desg||' structure for the Item ');

      DELETE ego_odi_ws_entities
      WHERE  session_id = p_session_id
      AND  pk1_value = pk1_value
      AND  pk2_value = pk2_value
      AND  pk3_value = pk3_value;
    else
      if( g_id is not null) then
              group_id := g_id;
      end if;
    end if;

exception
when others then
  RAISE;
 END process_bom_explosions;



PROCEDURE Preprocess_Item_Input   (  p_session_id      IN NUMBER,
                                p_odi_session_id  IN NUMBER )

IS
  l_batch_id        NUMBER;
  l_mode            VARCHAR2(20);
  l_item_id_tab     dbms_sql.VARCHAR2_table;
  l_org_id_tab      dbms_sql.VARCHAR2_table;
  l_rev_id_tab      dbms_sql.VARCHAR2_table;
  l_seq_num_tab     dbms_sql.VARCHAR2_table;
  l_rev_date_tab    dbms_sql.VARCHAR2_table;      -- Bug 8659192

  batch_entity_rec      EGO_PUB_FWK_PK.TBL_OF_BAT_ENT_OBJ_TYPE;
  l_alt_desg            VARCHAR2(100) := null;
  l_rev_date            DATE;
  l_levels_to_explode   NUMBER;
  l_group_id            NUMBER;
  l_error_code          VARCHAR2(100);
  l_error_message       VARCHAR2(2000);
  x_return_status       VARCHAR2(1);
  x_msg_count           NUMBER;
  x_msg_data            VARCHAR2(500);
  l_duplicates_count    NUMBER;
  v_count               NUMBER;
  l_exists_struct_name  NUMBER;
  l_is_valid_structure  BOOLEAN := TRUE;

  l_explode_option            NUMBER;
  l_exists_levels_to_explode  NUMBER;
  l_exists_explode_option     NUMBER;
  v_index                     NUMBER; -- Bug 8667104
  p_input_id                  NUMBER;

  l_expl_std_bom              VARCHAR2(10); -- Bug 8752314: CMR Change
  l_exists_explode_std        NUMBER; -- Bug 8752314: CMR Change

  e_invalid_batch_id EXCEPTION;

  -- Bug 8706557 : Added below variables
  l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
  l_parameter_t            WF_PARAMETER_T      := WF_PARAMETER_T(null, null);
  l_event_name             VARCHAR2(240);
  l_event_key              VARCHAR2(240);
  l_event_num              NUMBER;

CURSOR cur_exploded_records (grp_id NUMBER, levels NUMBER )
 IS
  SELECT
  ego.inventory_item_id AS inventory_item_id
  ,ego.organization_id AS org_id
  ,bom_exploder_pub.get_component_revision_id(nvl(be.component_sequence_id, 0)) AS rev_id
  , bom_exploder_pub.get_component_revision_label(nvl(be.component_sequence_id, 0)) AS rev_label
  , be.plan_level AS plan_level
  FROM bom_explosions_all be , mtl_system_items_b_kfv ego
  WHERE be.group_id = grp_id
  AND ego.inventory_item_id = be.component_item_id
  AND ego.organization_id = be.organization_id
  AND be.plan_level <= levels
  AND be.plan_level > 0
  AND /* This whereclause for filter criteria: Start */
      (  bom_exploder_pub.get_explode_option = 1 OR
         be.plan_level = 0 OR
         /* Date Effectivity */
         (  nvl(be.effectivity_control,1) = 1 AND
            (  (  be.implementation_date IS NULL AND
                  be.acd_type = 3 AND
                  decode(be.comp_fixed_revision_id,
                         NULL,bom_exploder_pub.get_explosion_date,
                         bom_exploder_pub.get_revision_highdate(be.comp_fixed_revision_id)) >= be.trimmed_effectivity_date
               ) OR
               (  bom_exploder_pub.get_explode_option = 2 AND
                  decode(be.comp_fixed_revision_id,
                         NULL,bom_exploder_pub.get_explosion_date,
                         bom_exploder_pub.get_revision_highdate(be.comp_fixed_revision_id)) >= be.trimmed_effectivity_date AND
                  decode(be.comp_fixed_revision_id,
                         NULL,bom_exploder_pub.get_explosion_date,
                         bom_exploder_pub.get_revision_highdate(be.comp_fixed_revision_id)) < nvl(be.trimmed_disable_date,to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss'))
               ) OR
               (  bom_exploder_pub.get_explode_option = 3 AND
                  decode(be.comp_fixed_revision_id,
                         NULL,bom_exploder_pub.get_explosion_date,
                         bom_exploder_pub.get_revision_highdate(be.comp_fixed_revision_id)) < nvl(be.trimmed_disable_date,to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss'))
               )
            )
         ) OR
         /* Rev Effectivity */
         (  nvl(be.effectivity_control,1) = 4 AND
            (  (  bom_exploder_pub.get_explode_option = 2 AND
                  (  (  bom_exploder_pub.get_expl_end_item_rev_code >= (SELECT revision FROM mtl_item_revisions_b
                                                                        WHERE inventory_item_id = be.end_item_id
                                                                        AND organization_id = be.end_item_org_id
                                                                        AND revision_id = be.from_end_item_rev_id) AND
                        (  be.to_end_item_rev_id IS NULL OR
                           bom_exploder_pub.get_expl_end_item_rev_code <= (SELECT revision FROM mtl_item_revisions_b
                                                                           WHERE inventory_item_id = be.end_item_id
                                                                           AND organization_id = be.end_item_org_id
                                                                           AND revision_id = be.to_end_item_rev_id)
                        )
                     ) OR
                     (  be.plan_level > 1 AND
                        bom_exploder_pub.get_component_revision(nvl(be.parent_comp_seq_id,0)) >= (SELECT revision FROM mtl_item_revisions_b
                                                                                                  WHERE inventory_item_id = be.assembly_item_id
                                                                                                  AND organization_id = be.organization_id
                                                                                                  AND revision_id = be.from_end_item_rev_id) AND
                        (  be.to_end_item_rev_id IS NULL OR
                           bom_exploder_pub.get_component_revision(nvl(be.parent_comp_seq_id,0)) <= (SELECT revision FROM mtl_item_revisions_b
                                                                                                     WHERE inventory_item_id = be.assembly_item_id
                                                                                                     AND organization_id = be.organization_id
                                                                                                     AND revision_id = be.to_end_item_rev_id)

                        )
                     )
                  )
               ) OR
               (  bom_exploder_pub.get_explode_option = 3 AND
                  (  (  be.to_end_item_rev_id IS NULL
                     ) OR
                     (  bom_exploder_pub.get_expl_end_item_rev_code <= (SELECT revision FROM mtl_item_revisions_b
                                                                        WHERE inventory_item_id = be.end_item_id
                                                                        AND organization_id = be.end_item_org_id
                                                                        AND revision_id = be.to_end_item_rev_id)
                     ) OR
                     (  be.plan_level > 1 AND
                        bom_exploder_pub.get_component_revision(nvl(be.parent_comp_seq_id,0)) <= (SELECT revision FROM mtl_item_revisions_b
                                                                                                  WHERE inventory_item_id = be.assembly_item_id
                                                                                                  AND organization_id = be.organization_id
                                                                                                  AND revision_id = be.to_end_item_rev_id)
                     )
                  )
               )
            )
         ) OR
         /* Unit/Serial Effectivity */
         (  nvl(be.effectivity_control,1) = 2 AND
            (  (  bom_exploder_pub.get_explode_option = 2 AND
                  bom_exploder_pub.get_expl_unit_number BETWEEN be.trimmed_from_unit_number AND nvl(be.trimmed_to_unit_number,bom_exploder_pub.get_expl_unit_number)
               ) OR
               (  bom_exploder_pub.get_explode_option = 3 AND
                  bom_exploder_pub.get_expl_unit_number <= nvl(be.trimmed_to_unit_number,bom_exploder_pub.get_expl_unit_number)
               )
            )
         )
      );

BEGIN
  -- Bug 9752177 : Commenting the below code
  -- EXECUTE IMMEDIATE 'alter session set nls_date_format=''YYYY.MM.DD HH24:MI:SS''';    -- Bug 8659192

  /* Call API to find invocation mode and batch_id, Batch_Id will be -1 if mode is HMDM or LIST*/
  Invocation_Mode( p_session_id,p_odi_session_id,'/itemQueryParameters/BatchId',l_mode,l_batch_id);

  INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
  VALUES (p_session_id,p_odi_session_id,'INVOCATION_MODE',2,NULL,l_mode,NULL,SYSDATE,G_CURRENT_USER_ID);

  IF l_batch_id > -1 THEN

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
      VALUES (p_session_id,p_odi_session_id,'BATCH_ID',2,NULL,NULL,l_batch_id,SYSDATE,G_CURRENT_USER_ID);

      SELECT pk1_value , pk2_value ,pk3_value
      BULK COLLECT INTO  l_item_id_tab, l_org_id_tab, l_rev_id_tab
      FROM Ego_Pub_Bat_Ent_Objs_v   --Find OUT NOCOPY if any other PK's
      WHERE batch_id = l_batch_id
      AND USER_ENTERED = 'Y';

      -- Bug  8670655
      IF (l_item_id_tab.Count = 0) THEN
        RAISE e_invalid_batch_id;
      END IF;

      SELECT CHAR_VALUE INTO l_alt_desg FROM EGO_PUB_BAT_PARAMS_B
      WHERE type_id=l_batch_id AND Upper(parameter_name) ='STRUCTURE_NAME';

      /* Need to check for below */
      SELECT DATE_VALUE INTO l_rev_date FROM EGO_PUB_BAT_PARAMS_B
      WHERE type_id=l_batch_id AND Upper(parameter_name) ='EXPLOSION_DATE';

      -- Bug 8683213 : Start
      BEGIN
        SELECT NUMERIC_VALUE INTO l_levels_to_explode FROM EGO_PUB_BAT_PARAMS_B
        WHERE type_id = l_batch_id AND Upper(parameter_name) ='LEVELS_TO_EXPLODE';

        IF (l_levels_to_explode < 0) OR (l_levels_to_explode > 60) THEN
          l_levels_to_explode := 60;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        l_levels_to_explode := 60;
      END;
      -- Bug 8683213 : End

      -- In Batch Mode, all structures explosions will happen only for Current option.
      l_explode_option := 2;

      -- Bug 8752314 : CMR Change
      SELECT CHAR_VALUE INTO l_expl_std_bom FROM EGO_PUB_BAT_PARAMS_B
      WHERE type_id=l_batch_id AND Upper(parameter_name) ='EXPLODE_STD_BOM';

      FOR i IN 1..l_item_id_tab.Count
      LOOP
        INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value,pk4_value, SEQUENCE_NUMBER)
        VALUES (p_session_id,p_odi_session_id,'ITEM',l_item_id_tab(i),l_org_id_tab(i),l_rev_id_tab(i), i, i);
      END LOOP;

  ELSE

    IF (l_mode <> 'MODE') THEN
       -- Process the details for NON - Batch Mode
      SELECT existsNode(xmlcontent, '/itemQueryParameters/StructureName')
      INTO l_exists_struct_name
      FROM EGO_PUB_WS_PARAMS
      WHERE session_id = p_session_id;

      IF (l_exists_struct_name = 1) THEN
         SELECT extractValue(xmlcontent, '/itemQueryParameters/StructureName')
         INTO l_alt_desg
         FROM EGO_PUB_WS_PARAMS
         WHERE session_id = p_session_id;
      END IF;

      SELECT existsNode(xmlcontent, '/itemQueryParameters/BomExploderParameters/LevelsToExplode'),
              existsNode(xmlcontent, '/itemQueryParameters/BomExploderParameters/ExplodeOption'),
              existsNode(xmlcontent, '/itemQueryParameters/BomExploderParameters/ExplodeStandard')  -- Bug 8752314 : CMR Change
      INTO l_exists_levels_to_explode, l_exists_explode_option, l_exists_explode_std
      FROM EGO_PUB_WS_PARAMS
      WHERE session_id = p_session_id;

      IF (l_exists_levels_to_explode = 1) THEN
         SELECT nvl(extractValue(xmlcontent, '/itemQueryParameters/BomExploderParameters/LevelsToExplode'),60)
         INTO l_levels_to_explode
         FROM EGO_PUB_WS_PARAMS
         WHERE session_id = p_session_id;
      ELSE
        l_levels_to_explode := 60;
      END IF;

      IF (l_levels_to_explode < 0) OR (l_levels_to_explode > 60) THEN
              l_levels_to_explode := 60;
      END IF;

      -- By Default the explode option should be Current.
      IF (l_exists_explode_option = 1) THEN
        SELECT nvl(extractValue(xmlcontent, '/itemQueryParameters/BomExploderParameters/ExplodeOption'),2)
        INTO l_explode_option
        FROM EGO_PUB_WS_PARAMS
        WHERE session_id = p_session_id;
      ELSE
        l_explode_option := 2;
      END IF;

      -- Bug 8752314 : CMR Change
      IF (l_exists_explode_std = 1) THEN
        SELECT nvl(extractValue(xmlcontent, '/itemQueryParameters/BomExploderParameters/ExplodeStandard'),'Y')
        INTO l_expl_std_bom
        FROM EGO_PUB_WS_PARAMS
        WHERE session_id = p_session_id;
      ELSE
        l_expl_std_bom := 'Y';
      END IF;

    END IF; -- end of (l_mode <> 'MODE')

  END IF;  -- end of l_batch_id > -1


  Init_Security_details(p_session_id, p_odi_session_id, x_return_status);  -- Bug 8659248

  IF (x_return_status = 'S') THEN
    -- check security for all items
    check_security( p_session_id => p_session_id,
                    p_odi_session_id => p_odi_session_id,
                    p_priv_check => 'EGO_PUBLISH_ITEM',
                    p_for_exploded_items => 'N',
                    x_return_status => x_return_status
                  );

    IF (x_return_status = 'S') THEN
      -- Fetch the entity details, for non batch get the rev date also for each entity
      IF l_batch_id = -1 THEN
        SELECT pk1_value , pk2_value ,pk3_value, SEQUENCE_NUMBER, To_Date(pk5_value,'YYYY.MM.DD HH24:MI:SS')   -- Bug 8659192
        BULK COLLECT INTO  l_item_id_tab, l_org_id_tab, l_rev_id_tab, l_seq_num_tab, l_rev_date_tab
        FROM ego_odi_ws_entities
        WHERE session_id = p_session_id
        AND nvl(REF1_VALUE, 'Y') = 'Y';
      ELSE
        SELECT pk1_value , pk2_value ,pk3_value, SEQUENCE_NUMBER
        BULK COLLECT INTO  l_item_id_tab, l_org_id_tab, l_rev_id_tab , l_seq_num_tab
        FROM ego_odi_ws_entities
        WHERE session_id = p_session_id
        AND nvl(REF1_VALUE, 'Y') = 'Y';
      END IF;

      IF (l_alt_desg IS NOT NULL) THEN
        FOR i IN 1..l_item_id_tab.Count
        LOOP
          IF ((l_alt_desg IS NOT NULL) AND (Upper(l_alt_desg) = 'PRIMARY')) THEN
            -- For Primary Structure, No Need to validate and assign null value
            l_alt_desg := '';
          ELSE
            -- validate structure details given
            l_is_valid_structure := validate_structure_name(p_session_id => p_session_id,
                                                            p_odi_session_id => p_odi_session_id,
                                                            p_org_id => l_org_id_tab(i),
                                                            p_structure_name => l_alt_desg,
                                                            p_input_id  => l_seq_num_tab(i)
                                                            );
          END IF;

          IF (l_is_valid_structure) THEN
            -- Bug 8659192
            IF l_batch_id = -1 THEN
              l_rev_date := l_rev_date_tab(i);
            END IF;

            /* Call Bom Exploder Procedure */
            process_bom_explosions(p_session_id => p_session_id,
                                    p_odi_session_id => p_odi_session_id,
                                    p_index   =>  l_seq_num_tab(i),
                                    pk1_value  =>  l_item_id_tab(i),
                                    pk2_value   => l_org_id_tab(i) ,
                                    pk3_value  => l_rev_id_tab(i),
                                    rev_date    => l_rev_date ,
                                    alternate_desg  => l_alt_desg ,
                                    levels_explode =>  l_levels_to_explode ,
                                    explode_option => l_explode_option ,
                                    explode_std_bom =>  l_expl_std_bom ,  -- Bug 8752314 : CMR Change
                                    group_id        => l_group_id,
                                    x_error_code   => l_error_code,
                                    x_error_message =>  l_error_message
                                    );

            FOR j IN cur_exploded_records(l_group_id, l_levels_to_explode)
            LOOP
              -- Do not publish components exploded with null revisions.
              IF(j.rev_id IS NOT NULL) THEN
                INSERT INTO ego_odi_ws_entities ( session_id, odi_session_id, entity_type, pk1_value, pk2_value, pk3_value, pk4_value)
                VALUES (p_session_id,p_odi_session_id,'ITEM',j.inventory_item_id,j.org_id,j.rev_id, l_seq_num_tab(i) );
              END IF;
            END LOOP;  -- end of loop j
          END IF; -- end of (l_is_valid_structure)
        END LOOP; -- end of loop i

        /* Performance Change: Start
        -- Below Code is moved out of the loop, To improve the performance */
        -- check security for all exploded items
        check_security( p_session_id => p_session_id,
                  p_odi_session_id => p_odi_session_id,
                  p_priv_check => 'EGO_PUBLISH_ITEM',
                  p_for_exploded_items => 'Y',
                  x_return_status => x_return_status
                );
        IF (l_batch_id > -1 and x_return_status = 'S') THEN
          v_index := 1;   -- Bug 8667104
          for k in (SELECT DISTINCT pk1_value , pk2_value ,pk3_value  -- Bug 9530282
                    FROM ego_odi_ws_entities
                    WHERE session_id = p_session_id
                    AND nvl(REF1_VALUE, 'Y') = 'Y')
          loop
            SELECT Count(*) INTO v_count
            FROM  Ego_Pub_Bat_Ent_Objs_v
            WHERE batch_id = l_batch_id
            AND pk1_value = k.pk1_value
            AND pk2_value = k.pk2_value
            AND pk3_value = k.pk3_value;

            IF (v_count = 0) THEN
              -- Bug 8667104 : Prepare the record only for derived entities
              batch_entity_rec(v_index).batch_id := l_batch_id;
              batch_entity_rec(v_index).pk1_value := k.pk1_value;
              batch_entity_rec(v_index).pk2_value := k.pk2_value;
              batch_entity_rec(v_index).pk3_value := k.pk3_value ;
              batch_entity_rec(v_index).pk4_value := NULL ;
              batch_entity_rec(v_index).pk5_value := NULL ;
              batch_entity_rec(v_index).user_entered := 'N';

              v_index := v_index + 1;

            END IF;
          end loop; -- end of loop k

          -- Bug 8667104 : Calling the Below API for all the derived entities at a time, i.e in bulk
          EGO_PUB_FWK_PK.add_derived_entities(batch_entity_rec,x_return_status,x_msg_count,x_msg_data);
          IF (x_return_status <> 'S') THEN
            NULL;
          END IF;
        END IF; -- end of if (l_batch_id > -1 and x_return_status = 'S')
        -- Performance Change: End:
      END IF;  -- end of if l_alt_desg IS NOT NULL
    END IF; -- end of (x_return_status = 'S')

    /* Check for duplicate records in ego_odi_ws_entities */
    FOR i IN (SELECT pk1_value, pk2_value, pk3_value FROM ego_odi_ws_entities
              WHERE session_id =  p_session_id AND entity_type = 'ITEM')
    LOOP
      select Count(*) INTO l_duplicates_count FROM ego_odi_ws_entities
      WHERE  session_id = p_session_id  and pk1_value = i.pk1_value and pk2_value = i.pk2_value AND pk3_value = i.pk3_value
      AND nvl(REF1_VALUE, 'Y') = 'Y';   -- Bug  8658259

      IF l_duplicates_count > 0
      THEN
        DELETE ego_odi_ws_entities
        WHERE  session_id = p_session_id
        AND  pk1_value = i.pk1_value
        AND  pk2_value = i.pk2_value
        AND  pk3_value = i.pk3_value
        AND ROWNUM < l_duplicates_count;
      END IF;
    END LOOP;
    /* End of checking duplicate records */
  END IF;

  select count(*) into v_count
  FROM ego_odi_ws_entities
  WHERE session_id = p_session_id
  AND nvl(REF1_VALUE, 'Y') = 'Y';

  IF (v_count <> 0) THEN
    /* Insert all the configurations into the table in below procedure */
    process_configurations(p_session_id, p_odi_session_id);

    -- Bug 8706557 : Start - Raise the business event for bacth mode
    IF (l_batch_id <> -1) THEN
      l_event_name := 'oracle.apps.ego.item.FreezePublishedItems' ;

      SELECT MTL_BUSINESS_EVENTS_S.NEXTVAL into l_event_num FROM dual;

      l_event_key := SUBSTRB(l_event_name, 1, 255) || '-' || l_event_num;

      wf_event.AddParameterToList( p_name            => 'BATCH_ID'
                                  ,p_value           => l_batch_id
                                  ,p_ParameterList   => l_parameter_List);

      WF_EVENT.Raise( p_event_name => l_event_name
                     ,p_event_key  => l_event_key
                     ,p_parameters => l_parameter_list);

      l_parameter_list.DELETE;
    END IF;
    -- Bug 8706557 : End
  END IF;

  COMMIT;

EXCEPTION

  WHEN e_invalid_invocation_mode THEN
    SELECT Nvl(Max(INPUT_ID),0) + 1 into p_input_id
    FROM EGO_PUB_WS_INPUT_IDENTIFIERS
    WHERE session_id =  p_session_id;

    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                        p_odi_session_id => p_odi_session_id,
                        p_input_id  => p_input_id,
                        p_err_code => 'EGO_INVALID_INVOCATION_MODE',
                        p_err_message => 'Invalid Invocation Mode, No valid details of Items to be published are given');

  WHEN e_no_org_details THEN
    SELECT Nvl(Max(INPUT_ID),0) + 1 into p_input_id
    FROM EGO_PUB_WS_INPUT_IDENTIFIERS
    WHERE session_id =  p_session_id;

    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                        p_odi_session_id => p_odi_session_id,
                        p_input_id  => p_input_id,
                        p_err_code => 'EGO_NO_ORG_DETAILS',
                        p_err_message => 'Organization details are not provided');

  WHEN e_no_rev_details THEN
    SELECT Nvl(Max(INPUT_ID),0) + 1 into p_input_id
    FROM EGO_PUB_WS_INPUT_IDENTIFIERS
    WHERE session_id =  p_session_id;

    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                        p_odi_session_id => p_odi_session_id,
                        p_input_id  => p_input_id,
                        p_err_code => 'EGO_NO_REV_DETAILS',
                        p_err_message => 'Revision details are not provided');

  WHEN e_invalid_batch_id THEN
    SELECT Nvl(Max(INPUT_ID),0) + 1 into p_input_id
    FROM EGO_PUB_WS_INPUT_IDENTIFIERS
    WHERE session_id =  p_session_id;

    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_input_id,
                             p_param_name  => 'BatchId',
                             p_param_value => l_batch_id );

    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => p_input_id,
                          p_err_code => 'EGO_INVALID_BATCH_ID',
                          p_err_message => 'Invalid Batch Id');
  WHEN OTHERS THEN
  RAISE;
END Preprocess_Item_Input;


PROCEDURE process_configurations ( p_session_id        IN  NUMBER,
                                p_odi_session_id    IN  NUMBER)

IS

      l_lang_code_tab        dbms_sql.varchar2_table;
      l_lang_name_tab        dbms_sql.varchar2_table;   -- Bug 8670897
      l_uda_attr_name_tab    dbms_sql.varchar2_table;
      l_uda_attr_id_tab      dbms_sql.varchar2_table;
      l_ta_attr_id_tab       dbms_sql.varchar2_table;
      l_ta_attr_name_tab     dbms_sql.varchar2_table;

      PUBLISH_OP_ATTR_GROUPS VARCHAR2(10);

      l_node_exists             NUMBER;
      l_node_exists_ag_id   NUMBER;
      l_node_exists_ag_name NUMBER;
      l_node_exists_ta_id   NUMBER;
      l_node_exists_ta_name NUMBER;
      l_lang_count NUMBER;      -- Bug 8670897

      L_PUBLISH_OP_ATTR_GROUPS          VARCHAR2(10);
      L_PUBLISH_ITEM_CATALOG            VARCHAR2(10);
      L_PUBLISH_INV_CHARS               VARCHAR2(10);
      L_PUBLISH_PHY_CHARS               VARCHAR2(10);
      L_PUBLISH_BOM_CHARS               VARCHAR2(10);
      L_PUBLISH_WIP_CHARS               VARCHAR2(10);
      L_PUBLISH_COST_CHARS              VARCHAR2(10);
      L_PUBLISH_PLT_CHARS               VARCHAR2(10);
      L_PUBLISH_PLAN_CHARS              VARCHAR2(10);
      L_PUBLISH_PURCHASE_CHARS          VARCHAR2(10);
      L_PUBLISH_RECEIVE_CHARS           VARCHAR2(10);
      L_PUBLISH_OM_CHARS                VARCHAR2(10);
      L_PUBLISH_INVOICE_CHARS           VARCHAR2(10);
      L_PUBLISH_WEBOPT_CHARS            VARCHAR2(10);
      L_PUBLISH_SERVICE_CHARS           VARCHAR2(10);
      L_PUBLISH_ASSET_CHARS             VARCHAR2(10);
      L_PUBLISH_PMFG_CHARS              VARCHAR2(10);
      L_PUBLISH_UDA_GROUPS               VARCHAR2(10);
      L_PUBLISH_ITEM_REVISION            VARCHAR2(10);
      L_PUBLISH_TRANSACTION_ATTRS        VARCHAR2(10);
      L_PUBLISH_RELATED_ITEMS            VARCHAR2(10);
      L_PUBLISH_CUSTOMER_ITEMS           VARCHAR2(10);
      L_PUBLISH_MFGPART_NUMBERS          VARCHAR2(10);
      L_PUBLISH_GTIN_XREFS               VARCHAR2(10);
      L_PUBLISH_ALTCAT_ASSIGNMENTS       VARCHAR2(10);
      L_PUBLISH_SUPPLIER_ASSIGNMNETS     VARCHAR2(10);

      v_ags_count NUMBER;
      v_ag_null_cnt NUMBER;
      v_publish_udas  VARCHAR2(10);
      v_publish_tas   VARCHAR2(10);
      l_retpayload      VARCHAR2(10); -- Added for Chunking
      p_index NUMBER;

BEGIN

  /* Below Code is added for Chunking, extract configurable parameter 'ReturnPayload' */
  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ReturnPayload')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG (session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'return_payload',2,NULL,'TRUE',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Upper(Nvl(extractValue(ret_pay, '/ReturnPayload'),'Y'))
    INTO  l_retpayload
    FROM (SELECT  Value(retpay) ret_pay
           FROM EGO_PUB_WS_PARAMS i,
           TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ReturnPayload') )) retpay
           WHERE session_id=p_session_id
           );

    --Insert record for  configurable parameter 'ReturnPayload'
    If (Upper(l_retpayload)='Y' ) then
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
      VALUES (p_session_id,p_odi_session_id,'return_payload',2,NULL,'TRUE',NULL,SYSDATE,G_CURRENT_USER_ID);
    else
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
      VALUES (p_session_id,p_odi_session_id,'return_payload',2,NULL,'FALSE',NULL,SYSDATE,G_CURRENT_USER_ID);
    end if;
  END IF;
  /* End of Code added for Chunking */

  SELECT   extractValue(lang_code, '/LanguageCode')
    BULK COLLECT INTO  l_lang_code_tab
    FROM  (SELECT  Value(langcode) lang_code
           FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ListOfLanguages/LanguageCode') )) langcode
          WHERE session_id=p_session_id
          );
  -- Bug 8670897
  SELECT   extractValue(lang_name, '/LanguageName')
    BULK COLLECT INTO  l_lang_name_tab
    FROM  (SELECT  Value(langname) lang_name
           FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ListOfLanguages/LanguageName') )) langname
          WHERE session_id=p_session_id
          );


  --Insert record into config table for parameter language
  -- Bug 8670897 : Below code is modified to handle Language Name along with Language Code
  IF ((l_lang_name_tab.Count = l_lang_code_tab.Count) AND  l_lang_code_tab.Count > 0 AND l_lang_name_tab.Count > 0 ) THEN
    l_lang_count := 0;
    FOR i IN 1..l_lang_code_tab.Count
    LOOP
      IF (l_lang_code_tab(i) IS NULL) THEN
        IF (l_lang_name_tab(i) IS NULL) THEN
          l_lang_count := l_lang_count + 1;
        ELSE
          BEGIN
            SELECT language_code INTO l_lang_code_tab(i)
            FROM FND_LANGUAGES WHERE NLS_LANGUAGE = l_lang_name_tab(i);

            INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
            VALUES (p_session_id,p_odi_session_id,'LANGUAGE_CODE',2,NULL,l_lang_code_tab(i),NULL,SYSDATE,G_CURRENT_USER_ID);
          EXCEPTION
            WHEN No_Data_Found THEN

            SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
            FROM EGO_PUB_WS_INPUT_IDENTIFIERS
            WHERE session_id =  p_session_id;

            EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                                     p_odi_session_id => p_odi_session_id,
                                     p_input_id  => p_index,
                                     p_param_name  => 'LanguageName',
                                     p_param_value => l_lang_name_tab(i) );

            EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                  p_odi_session_id => p_odi_session_id,
                                  p_input_id  => p_index,
                                  p_err_code => 'EGO_INVALID_LANGUAGE_NAME',
                                  p_err_message => 'Invalid Language Name');

          END;
        END IF;
      ELSE
        BEGIN
          SELECT language_code INTO l_lang_code_tab(i)
          FROM FND_LANGUAGES WHERE language_code = l_lang_code_tab(i);

          INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
          VALUES (p_session_id,p_odi_session_id,'LANGUAGE_CODE',2,NULL,l_lang_code_tab(i),NULL,SYSDATE,G_CURRENT_USER_ID);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
            FROM EGO_PUB_WS_INPUT_IDENTIFIERS
            WHERE session_id =  p_session_id;

            EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                                     p_odi_session_id => p_odi_session_id,
                                     p_input_id  => p_index,
                                     p_param_name  => 'LanguageCode',
                                     p_param_value => l_lang_code_tab(i) );

            EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                  p_odi_session_id => p_odi_session_id,
                                  p_input_id  => p_index,
                                  p_err_code => 'EGO_INVALID_LANGUAGE_CODE',
                                  p_err_message => 'Invalid Language Code');
        END;

      END IF;
    END LOOP;

    IF (l_lang_count = l_lang_code_tab.Count) THEN
      FOR i IN (SELECT language_code FROM FND_LANGUAGES WHERE INSTALLED_FLAG IN ('I','B') ) LOOP
        INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'LANGUAGE_CODE',2,NULL,i.language_code,NULL,SYSDATE,G_CURRENT_USER_ID);
      END LOOP;
    END IF;
  END IF;

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/OperationalAttributeGroups')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 1) THEN
    SELECT   Nvl(extractValue(uda_ag, '/OperationalAttributeGroups'),'Y')
    INTO  L_PUBLISH_OP_ATTR_GROUPS
    FROM  (SELECT  Value(udaag) uda_ag
            FROM EGO_PUB_WS_PARAMS i,
            TABLE(XMLSequence(
              extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/OperationalAttributeGroups') )) udaag
            WHERE session_id=p_session_id
          );

    -- Need to validate the values entered by user and throw error for wrong values.  ???????????

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_OP_ATTR_GROUPS',2,NULL,Upper(L_PUBLISH_OP_ATTR_GROUPS),NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_OP_ATTR_GROUPS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF; -- (l_node_exists = 1) for Operational Ags

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    -- insert 'Y' for all the operational attributes groups
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_ITEM_CATALOG',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_INV_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PHY_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_BOM_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_WIP_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_COST_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PLT_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PLAN_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PURCHASE_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_OM_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_RECEIVE_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_INVOICE_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_WEBOPT_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_SERVICE_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_ASSET_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PMFG_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

  ELSE
    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ItemCatalog')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_ITEM_CATALOG',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/ItemCatalog'),'Y')
        INTO  L_PUBLISH_ITEM_CATALOG
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ItemCatalog') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_ITEM_CATALOG',2,NULL,Upper(L_PUBLISH_ITEM_CATALOG),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/InventoryCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_INV_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/InventoryCharacteristics'),'Y')
        INTO  L_PUBLISH_INV_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/InventoryCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_INV_CHARS',2,NULL,Upper(L_PUBLISH_INV_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);

    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/PhysicalCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PHY_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/PhysicalCharacteristics'),'Y')
        INTO  L_PUBLISH_PHY_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/PhysicalCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PHY_CHARS',2,NULL,Upper(L_PUBLISH_PHY_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;


    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/BillsOfMaterialCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_BOM_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/BillsOfMaterialCharacteristics'),'Y')
        INTO  L_PUBLISH_BOM_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/BillsOfMaterialCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_BOM_CHARS',2,NULL,Upper(L_PUBLISH_BOM_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;


    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/WorkInProcessCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_WIP_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/WorkInProcessCharacteristics'),'Y')
        INTO  L_PUBLISH_WIP_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/WorkInProcessCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_WIP_CHARS',2,NULL,Upper(L_PUBLISH_WIP_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/CostingCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_COST_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/CostingCharacteristics'),'Y')
        INTO  L_PUBLISH_COST_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/CostingCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_COST_CHARS',2,NULL,Upper(L_PUBLISH_COST_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ProcessingLeadTimeCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PLT_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/ProcessingLeadTimeCharacteristics'),'Y')
        INTO  L_PUBLISH_PLT_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ProcessingLeadTimeCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PLT_CHARS',2,NULL,Upper(L_PUBLISH_PLT_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/PlanningCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PLAN_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/PlanningCharacteristics'),'Y')
        INTO  L_PUBLISH_PLAN_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/PlanningCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PLAN_CHARS',2,NULL,Upper(L_PUBLISH_PLAN_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/PurchasingCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PURCHASE_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/PurchasingCharacteristics'),'Y')
        INTO  L_PUBLISH_PURCHASE_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/PurchasingCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PURCHASE_CHARS',2,NULL,Upper(L_PUBLISH_PURCHASE_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/OrderManagementCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_OM_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/OrderManagementCharacteristics'),'Y')
        INTO  L_PUBLISH_OM_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/OrderManagementCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_OM_CHARS',2,NULL,Upper(L_PUBLISH_OM_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ReceivingCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_RECEIVE_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/ReceivingCharacteristics'),'Y')
        INTO  L_PUBLISH_RECEIVE_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ReceivingCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_RECEIVE_CHARS',2,NULL,Upper(L_PUBLISH_RECEIVE_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/InvoicingCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_INVOICE_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/InvoicingCharacteristics'),'Y')
        INTO  L_PUBLISH_INVOICE_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/InvoicingCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_INVOICE_CHARS',2,NULL,Upper(L_PUBLISH_INVOICE_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/WebOptionsCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_WEBOPT_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/WebOptionsCharacteristics'),'Y')
        INTO  L_PUBLISH_WEBOPT_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/WebOptionsCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_WEBOPT_CHARS',2,NULL,Upper(L_PUBLISH_WEBOPT_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ServiceCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_SERVICE_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/ServiceCharacteristics'),'Y')
        INTO  L_PUBLISH_SERVICE_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ServiceCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_SERVICE_CHARS',2,NULL,Upper(L_PUBLISH_SERVICE_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/AssetCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_ASSET_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/AssetCharacteristics'),'Y')
        INTO  L_PUBLISH_ASSET_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/AssetCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_ASSET_CHARS',2,NULL,Upper(L_PUBLISH_ASSET_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ProcessMfgCharacteristics')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF (l_node_exists = 0) THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PMFG_CHARS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
    ELSE
      SELECT   Nvl(extractValue(uda_ag, '/ProcessMfgCharacteristics'),'Y')
        INTO  L_PUBLISH_PMFG_CHARS
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/PublishOperationalAttributeGroups/ProcessMfgCharacteristics') )) udaag
                WHERE session_id=p_session_id
              );

      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
        VALUES (p_session_id,p_odi_session_id,'PUBLISH_PMFG_CHARS',2,NULL,Upper(L_PUBLISH_PMFG_CHARS),NULL,SYSDATE,G_CURRENT_USER_ID);
    END IF;

  END IF; -- (l_node_exists = 0) for Publish Operational Ags

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/UserDefinedAttributeGroups')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_UDA_GROUPS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/UserDefinedAttributeGroups'),'Y')
    INTO  L_PUBLISH_UDA_GROUPS
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/UserDefinedAttributeGroups') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_UDA_GROUPS',2,NULL,Upper(L_PUBLISH_UDA_GROUPS),NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF;


  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ItemRevision')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_ITEM_REVISION',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/ItemRevision'),'Y')
    INTO  L_PUBLISH_ITEM_REVISION
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ItemRevision') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_ITEM_REVISION',2,NULL,Upper(L_PUBLISH_ITEM_REVISION),NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF;

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/TransactionAttributes')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_TRANSACTION_ATTRS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/TransactionAttributes'),'Y')
    INTO  L_PUBLISH_TRANSACTION_ATTRS
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/TransactionAttributes') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_TRANSACTION_ATTRS',2,NULL,Upper(L_PUBLISH_TRANSACTION_ATTRS),NULL,SYSDATE,G_CURRENT_USER_ID);

  END IF;

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/RelatedItems')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_RELATED_ITEMS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/RelatedItems'),'Y')
    INTO  L_PUBLISH_RELATED_ITEMS
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/RelatedItems') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_RELATED_ITEMS',2,NULL,Upper(L_PUBLISH_RELATED_ITEMS),NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF;


  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/CustomerItems')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_CUSTOMER_ITEMS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/CustomerItems'),'Y')
    INTO  L_PUBLISH_CUSTOMER_ITEMS
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/CustomerItems') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_CUSTOMER_ITEMS',2,NULL,Upper(L_PUBLISH_CUSTOMER_ITEMS),NULL,SYSDATE,G_CURRENT_USER_ID);

  END IF;

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ManufacturerPartNumbers')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_MFGPART_NUMBERS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/ManufacturerPartNumbers'),'Y')
    INTO  L_PUBLISH_MFGPART_NUMBERS
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ManufacturerPartNumbers') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_MFGPART_NUMBERS',2,NULL,Upper(L_PUBLISH_MFGPART_NUMBERS),NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF;

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/GTINCrossReferences')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_GTIN_XREFS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/GTINCrossReferences'),'Y')
    INTO  L_PUBLISH_GTIN_XREFS
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/GTINCrossReferences') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_GTIN_XREFS',2,NULL,Upper(L_PUBLISH_GTIN_XREFS),NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF;

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/AlternateCategoryAssignments')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_ALTCAT_ASSIGNMENTS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);

  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/AlternateCategoryAssignments'),'Y')
    INTO  L_PUBLISH_ALTCAT_ASSIGNMENTS
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/AlternateCategoryAssignments') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_ALTCAT_ASSIGNMENTS',2,NULL,Upper(L_PUBLISH_ALTCAT_ASSIGNMENTS),NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF;

  SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/SupplierAssignments')
  INTO l_node_exists
  FROM EGO_PUB_WS_PARAMS
  WHERE session_id = p_session_id;

  IF (l_node_exists = 0) THEN
    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_SUPPLIER_ASSIGNMNETS',2,NULL,'Y',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
    SELECT   Nvl(extractValue(uda_ag, '/SupplierAssignments'),'Y')
    INTO  L_PUBLISH_SUPPLIER_ASSIGNMNETS
    FROM  (SELECT  Value(udaag) uda_ag
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                            extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/SupplierAssignments') )) udaag
                    WHERE session_id=p_session_id
            );

    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
    VALUES (p_session_id,p_odi_session_id,'PUBLISH_SUPPLIER_ASSIGNMNETS',2,NULL,Upper(L_PUBLISH_SUPPLIER_ASSIGNMNETS),NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF;

  SELECT CHAR_VALUE INTO v_publish_udas
  FROM EGO_PUB_WS_CONFIG
  WHERE Parameter_Name = 'PUBLISH_UDA_GROUPS'
  AND session_id = p_session_id;

  -- Validate the List of UDAS provided only if publishing UDAS
  IF (v_publish_udas = 'Y') THEN
    /* Process for UDAS */

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishUserDefinedAttributeGroups')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;


    IF (l_node_exists = 1) THEN         -- (l_node_exists = 1) for list of pub udags
      SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishUserDefinedAttributeGroups/AttributeGroupId') ,
        existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishUserDefinedAttributeGroups/AttributeGroupName')
      INTO l_node_exists_ag_id, l_node_exists_ag_name
      FROM EGO_PUB_WS_PARAMS
      WHERE session_id = p_session_id;

      IF (l_node_exists_ag_id <> 0 AND l_node_exists_ag_name <> 0) THEN
        SELECT   extractValue(uda_ag, '/AttributeGroupId')
        BULK COLLECT INTO l_uda_attr_id_tab
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishUserDefinedAttributeGroups/AttributeGroupId') )) udaag
                WHERE session_id=p_session_id
            );

        SELECT   extractValue(uda_ag, '/AttributeGroupName')
        BULK COLLECT INTO l_uda_attr_name_tab
        FROM  (SELECT  Value(udaag) uda_ag
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishUserDefinedAttributeGroups/AttributeGroupName') )) udaag
                WHERE session_id=p_session_id
              );

        IF ((l_uda_attr_id_tab.Count = l_uda_attr_name_tab.Count) AND l_uda_attr_id_tab.Count > 0 AND  l_uda_attr_name_tab.Count > 0 )
        THEN
          v_ag_null_cnt := 0;
          FOR i IN 1..l_uda_attr_id_tab.Count
          LOOP

            IF (l_uda_attr_name_tab(i) IS NOT NULL)
            THEN
              BEGIN
                /* Need to validate for valid input values */
                SELECT ATTR_GROUP_NAME
                INTO  l_uda_attr_name_tab(i) -- v_attr_group_name
                FROM ego_attr_groups_v
                WHERE ATTR_GROUP_NAME = l_uda_attr_name_tab(i)
                AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP';

              EXCEPTION
                WHEN No_Data_Found THEN
                  SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
                  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
                  WHERE session_id =  p_session_id;

                  -- Throw error : Attribute Id given is wrong.????? or will ignore the attribute
                  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                                               p_odi_session_id => p_odi_session_id,
                                               p_input_id  => p_index,
                                               p_param_name  => 'AttributeGroupName',
                                               p_param_value => l_uda_attr_name_tab(i) );

                  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                        p_odi_session_id => p_odi_session_id,
                                        p_input_id  => p_index,
                                        p_err_code => 'EGO_INVALID_AG_NAME',
                                        p_err_message => 'Invalid Attribute Group Name');

                    l_uda_attr_name_tab(i) := NULL;
                    l_uda_attr_name_tab(i) := NULL;
              END;
            ELSIF (l_uda_attr_id_tab(i) IS NOT NULL) THEN
              BEGIN
                /* Need to validate for valid input values */
                SELECT ATTR_GROUP_NAME
                INTO  l_uda_attr_name_tab(i) -- v_attr_group_name
                FROM ego_attr_groups_v
                WHERE ATTR_GROUP_ID = l_uda_attr_id_tab(i)
                AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP';

              EXCEPTION
                WHEN No_Data_Found THEN
                  SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
                  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
                  WHERE session_id =  p_session_id;

                  -- Throw error : Attribute Id given is wrong.????? or will ignore the attribute
                  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                                               p_odi_session_id => p_odi_session_id,
                                               p_input_id  => p_index,
                                               p_param_name  => 'AttributeGroupId',
                                               p_param_value => l_uda_attr_id_tab(i) );

                  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                        p_odi_session_id => p_odi_session_id,
                                        p_input_id  => p_index,
                                        p_err_code => 'EGO_INVALID_AG_ID',
                                        p_err_message => 'Invalid Attribute Group Id');

                    l_uda_attr_name_tab(i) := NULL;
                    l_uda_attr_name_tab(i) := NULL;
              END;
            ELSE
              v_ag_null_cnt := v_ag_null_cnt + 1;
            END IF;

            IF (l_uda_attr_name_tab(i) IS NOT NULL)
            THEN
              INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
              VALUES (p_session_id,p_odi_session_id,'PUBLISH_AG_NAME',2,NULL, l_uda_attr_name_tab(i),NULL,SYSDATE,G_CURRENT_USER_ID);
            END IF;

          END LOOP;

          -- 8667733 : Start
          SELECT Count(*) INTO v_ags_count
          FROM EGO_PUB_WS_CONFIG
          WHERE Parameter_Name = 'PUBLISH_AG_NAME'
          AND session_id = p_session_id;

          -- If all the AGs provided are invalid, then Do not fetch UDA at all.
          IF (v_ags_count = 0 AND (v_ag_null_cnt <> l_uda_attr_id_tab.Count)) THEN
            UPDATE EGO_PUB_WS_CONFIG
            SET Char_value = 'N'
            WHERE session_id = p_session_id
            AND Parameter_Name = 'PUBLISH_UDA_GROUPS';
          END IF;
          -- 8667733 : End
        END IF;
      END IF; -- end of  (l_node_exists <> 0 AND l_node_exists_ag_name <> 0)
    END IF; -- end of (l_node_exists = 1) for list of pub udags
  END IF;  -- end of (v_publish_udas = 'Y')


  SELECT CHAR_VALUE INTO v_publish_tas
  FROM EGO_PUB_WS_CONFIG
  WHERE Parameter_Name = 'PUBLISH_TRANSACTION_ATTRS'
  AND session_id = p_session_id;

  -- Validate the List of TAs provided only if publishing TAs
  IF (v_publish_tas = 'Y') THEN
    /* Process for Transaction Attributes */

    SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishTransactionAttributes')
    INTO l_node_exists
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;


    IF (l_node_exists = 1) THEN         -- (l_node_exists = 1) for list of pub udags
      SELECT existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishTransactionAttributes/AttributeId') ,
        existsNode(xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishTransactionAttributes/AttributeName')
      INTO l_node_exists_ta_id, l_node_exists_ta_name
      FROM EGO_PUB_WS_PARAMS
      WHERE session_id = p_session_id;

      IF (l_node_exists_ta_id <> 0 AND l_node_exists_ta_name <> 0) THEN
        SELECT   extractValue(ta_attr, '/AttributeId')
        BULK COLLECT INTO l_ta_attr_id_tab
        FROM  (SELECT  Value(ta) ta_attr
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishTransactionAttributes/AttributeId') )) ta
                WHERE session_id=p_session_id
            );

        SELECT   extractValue(ta_attr, '/AttributeName')
        BULK COLLECT INTO l_ta_attr_name_tab
        FROM  (SELECT  Value(ta) ta_attr
                FROM EGO_PUB_WS_PARAMS i,
                TABLE(XMLSequence(
                  extract(i.xmlcontent, '/itemQueryParameters/PublishEntities/ListOfPublishTransactionAttributes/AttributeName') )) ta
                WHERE session_id=p_session_id
              );

        IF ((l_ta_attr_id_tab.Count = l_ta_attr_name_tab.Count) AND l_ta_attr_id_tab.Count > 0 AND  l_ta_attr_name_tab.Count > 0 )
        THEN
          FOR i IN 1..l_ta_attr_name_tab.Count
          LOOP

            IF (l_ta_attr_name_tab(i) IS NOT NULL )
            THEN
              BEGIN
                /* Need to validate for valid input values */
                SELECT ATTR_ID
                INTO  l_ta_attr_id_tab(i)
                FROM ego_attrs_v
                WHERE ATTR_NAME = l_ta_attr_name_tab(i)
                AND ATTR_GROUP_TYPE = 'EGO_ITEM_TRANS_ATTR_GROUP';

              EXCEPTION
                WHEN No_Data_Found THEN
                  SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
                  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
                  WHERE session_id =  p_session_id;

                  -- Throw error : Attribute Id given is wrong.????? or will ignore the attribute
                  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                                               p_odi_session_id => p_odi_session_id,
                                               p_input_id  => p_index,
                                               p_param_name  => 'AttributeName',
                                               p_param_value => l_ta_attr_name_tab(i) );

                  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                        p_odi_session_id => p_odi_session_id,
                                        p_input_id  => p_index,
                                        p_err_code => 'EGO_INVALID_TA_NAME',
                                        p_err_message => 'Invalid Transaction Attribute Name');

                  INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                  VALUES (p_session_id,p_odi_session_id,'PUBLISH_TA_ID',2,NULL, l_ta_attr_name_tab(i), NULL , SYSDATE, G_CURRENT_USER_ID);
                    l_ta_attr_id_tab(i) := NULL;
                    l_ta_attr_name_tab(i) := NULL;

                WHEN Too_Many_Rows THEN
                  FOR j IN ( SELECT ATTR_ID
                              FROM ego_attrs_v
                              WHERE ATTR_NAME = l_ta_attr_name_tab(i)
                              AND ATTR_GROUP_TYPE = 'EGO_ITEM_TRANS_ATTR_GROUP')
                  LOOP
                    INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                    VALUES (p_session_id,p_odi_session_id,'PUBLISH_TA_ID',1,NULL, NULL,j.ATTR_ID, SYSDATE, G_CURRENT_USER_ID);
                  END LOOP;

                  l_ta_attr_id_tab(i) := NULL;
                  l_ta_attr_name_tab(i) := NULL;

              END;
            ELSIF (l_ta_attr_id_tab(i) IS NOT NULL) THEN
              BEGIN
                /* Need to validate for valid input values */
                SELECT ATTR_ID
                INTO  l_ta_attr_id_tab(i)
                FROM ego_attrs_v
                WHERE ATTR_ID = l_ta_attr_id_tab(i)
                AND ATTR_GROUP_TYPE = 'EGO_ITEM_TRANS_ATTR_GROUP';

              EXCEPTION
                WHEN No_Data_Found THEN
                  SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
                  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
                  WHERE session_id =  p_session_id;

                  -- Throw error : Attribute Id given is wrong.????? or will ignore the attribute
                  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                                               p_odi_session_id => p_odi_session_id,
                                               p_input_id  => p_index,
                                               p_param_name  => 'AttributeId',
                                               p_param_value => l_ta_attr_id_tab(i) );

                  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                        p_odi_session_id => p_odi_session_id,
                                        p_input_id  => p_index,
                                        p_err_code => 'EGO_INVALID_TA_ID',
                                        p_err_message => 'Invalid Transaction Attribute Id');

                  INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                  VALUES (p_session_id,p_odi_session_id,'PUBLISH_TA_ID',2,NULL, l_ta_attr_id_tab(i), NULL , SYSDATE, G_CURRENT_USER_ID);
                    l_ta_attr_id_tab(i) := NULL;
                    l_ta_attr_name_tab(i) := NULL;
              END;
            END IF;

            IF (l_ta_attr_id_tab(i) IS NOT NULL)
            THEN
              INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
              VALUES (p_session_id,p_odi_session_id,'PUBLISH_TA_ID',1,NULL, NULL, l_ta_attr_id_tab(i), SYSDATE, G_CURRENT_USER_ID);
            END IF;

          END LOOP;
        END IF;
      END IF; -- end of  (l_node_exists_ta_id <> 0 AND l_node_exists_ag_name <> 0)
    END IF; -- end of (l_node_exists = 1) for list of pub TAs
  END IF; -- end of (v_publish_tas = 'Y')

EXCEPTION
  WHEN OTHERS THEN
  RAISE;
END process_configurations;

PROCEDURE process_non_batch_flow ( p_session_id    IN  NUMBER,
    p_odi_session_id IN NUMBER,
    p_exists_inv_id IN NUMBER,
    p_exists_inv_name IN NUMBER,
    p_exists_org_id IN NUMBER,
    p_exists_org_code IN  NUMBER,
    p_exists_rev_id IN NUMBER,
    p_exists_revision IN NUMBER,
    p_exists_rev_date IN NUMBER ,
    p_mode OUT NOCOPY VARCHAR2
    )
 IS
    l_inv_id NUMBER := -1;
    l_segments_provided BOOLEAN := FALSE;
    l_org_id NUMBER  := -1;
    l_org_code VARCHAR2(10) := NULL;
    l_rev_id   NUMBER  := -1;
    l_revision VARCHAR2(10) := NULL;
    l_rev_date DATE  := NULL;
    l_exists_items_list NUMBER;

    l_segment_1         mtl_system_items_b.segment1%TYPE;
    l_segment_2         mtl_system_items_b.segment2%TYPE;
    l_segment_3         mtl_system_items_b.segment3%TYPE;
    l_segment_4         mtl_system_items_b.segment4%TYPE;
    l_segment_5         mtl_system_items_b.segment5%TYPE;
    l_segment_6         mtl_system_items_b.segment6%TYPE;
    l_segment_7         mtl_system_items_b.segment7%TYPE;
    l_segment_8         mtl_system_items_b.segment8%TYPE;
    l_segment_9         mtl_system_items_b.segment9%TYPE;
    l_segment_10        mtl_system_items_b.segment10%TYPE;
    l_segment_11        mtl_system_items_b.segment11%TYPE;
    l_segment_12        mtl_system_items_b.segment12%TYPE;
    l_segment_13        mtl_system_items_b.segment13%TYPE;
    l_segment_14        mtl_system_items_b.segment14%TYPE;
    l_segment_15        mtl_system_items_b.segment15%TYPE;
    l_segment_16        mtl_system_items_b.segment16%TYPE;
    l_segment_17        mtl_system_items_b.segment17%TYPE;
    l_segment_18        mtl_system_items_b.segment18%TYPE;
    l_segment_19        mtl_system_items_b.segment19%TYPE;
    l_segment_20        mtl_system_items_b.segment20%TYPE;

    l_item_id_tab   dbms_sql.VARCHAR2_table;
    l_org_id_tab    dbms_sql.VARCHAR2_table;
    l_org_code_tab  dbms_sql.VARCHAR2_table;
    l_rev_id_tab    dbms_sql.VARCHAR2_table;
    l_rev_tab       dbms_sql.VARCHAR2_table;

    l_list_inv_id  NUMBER;
    l_list_org_id  NUMBER;
    l_list_rev_id  NUMBER;
    l_list_rev_date DATE;

    l_segment_1_tab     dbms_sql.VARCHAR2_table;
    l_segment_2_tab     dbms_sql.VARCHAR2_table;
    l_segment_3_tab     dbms_sql.VARCHAR2_table;
    l_segment_4_tab     dbms_sql.VARCHAR2_table;
    l_segment_5_tab     dbms_sql.VARCHAR2_table;
    l_segment_6_tab     dbms_sql.VARCHAR2_table;
    l_segment_7_tab     dbms_sql.VARCHAR2_table;
    l_segment_8_tab     dbms_sql.VARCHAR2_table;
    l_segment_9_tab     dbms_sql.VARCHAR2_table;
    l_segment_10_tab    dbms_sql.VARCHAR2_table;
    l_segment_11_tab    dbms_sql.VARCHAR2_table;
    l_segment_12_tab    dbms_sql.VARCHAR2_table;
    l_segment_13_tab    dbms_sql.VARCHAR2_table;
    l_segment_14_tab    dbms_sql.VARCHAR2_table;
    l_segment_15_tab    dbms_sql.VARCHAR2_table;
    l_segment_16_tab    dbms_sql.VARCHAR2_table;
    l_segment_17_tab    dbms_sql.VARCHAR2_table;
    l_segment_18_tab    dbms_sql.VARCHAR2_table;
    l_segment_19_tab    dbms_sql.VARCHAR2_table;
    l_segment_20_tab    dbms_sql.VARCHAR2_table;

    v_is_valid_item BOOLEAN;
    v_is_valid_org BOOLEAN;
    v_is_valid_rev BOOLEAN;
    l_list_segments BOOLEAN;

    l_inv_item_id   NUMBER;
    l_revision_id   NUMBER;
    l_revision_date DATE;
    l_organization_id  NUMBER;
    l_item_ids_count NUMBER;
    l_seg1_count NUMBER;

BEGIN

  IF((p_exists_inv_id = 1 OR p_exists_inv_name = 1) AND
    (p_exists_org_id = 1 OR p_exists_org_code = 1) AND
    (p_exists_rev_id = 1 OR p_exists_revision = 1 OR p_exists_rev_date = 1)
  )
  THEN
    -- HMDM Flow
    IF (p_exists_inv_id = 1) THEN
      SELECT Nvl(extractValue(xmlcontent, '/itemQueryParameters/InventoryItemId'), -1)
      INTO l_inv_id
      FROM EGO_PUB_WS_PARAMS
      WHERE session_id = p_session_id;
    END IF; -- end of p_exists_inv_id = 1

    IF (p_exists_inv_name = 1) THEN

      SELECT   extractValue(segments, '/InventoryItemName/Segment1'), extractValue(segments, '/InventoryItemName/Segment2') ,
        extractValue(segments, '/InventoryItemName/Segment3'), extractValue(segments, '/InventoryItemName/Segment4') ,
        extractValue(segments, '/InventoryItemName/Segment5'), extractValue(segments, '/InventoryItemName/Segment6') ,
        extractValue(segments, '/InventoryItemName/Segment7'), extractValue(segments, '/InventoryItemName/Segment8') ,
        extractValue(segments, '/InventoryItemName/Segment9'), extractValue(segments, '/InventoryItemName/Segment10') ,
        extractValue(segments, '/InventoryItemName/Segment11'), extractValue(segments, '/InventoryItemName/Segment12') ,
        extractValue(segments, '/InventoryItemName/Segment13'), extractValue(segments, '/InventoryItemName/Segment14') ,
        extractValue(segments, '/InventoryItemName/Segment15'), extractValue(segments, '/InventoryItemName/Segment16') ,
        extractValue(segments, '/InventoryItemName/Segment17'), extractValue(segments, '/InventoryItemName/Segment18') ,
        extractValue(segments, '/InventoryItemName/Segment19'), extractValue(segments, '/InventoryItemName/Segment20')
        INTO  l_segment_1, l_segment_2 ,
              l_segment_3, l_segment_4 ,
              l_segment_5, l_segment_6 ,
              l_segment_7, l_segment_8 ,
              l_segment_9, l_segment_10  ,
              l_segment_11, l_segment_12 ,
              l_segment_13, l_segment_14 ,
              l_segment_15, l_segment_16 ,
              l_segment_17, l_segment_18 ,
              l_segment_19, l_segment_20
      FROM  (SELECT  Value(itemName) segments
             FROM EGO_PUB_WS_PARAMS i,
             TABLE(XMLSequence(extract(i.xmlcontent, '/itemQueryParameters/InventoryItemName'))) itemName
             WHERE session_id = p_session_id
            );

      IF (  l_segment_1 IS NULL AND  l_segment_2  IS NULL AND
            l_segment_3 IS NULL AND  l_segment_4  IS NULL AND
            l_segment_5 IS NULL AND  l_segment_6  IS NULL AND
            l_segment_7 IS NULL AND  l_segment_8  IS NULL AND
            l_segment_9 IS NULL AND  l_segment_10 IS NULL AND
            l_segment_11 IS NULL AND l_segment_12 IS NULL AND
            l_segment_13 IS NULL AND l_segment_14 IS NULL AND
            l_segment_15 IS NULL AND l_segment_16 IS NULL AND
            l_segment_17 IS NULL AND l_segment_18 IS NULL AND
            l_segment_19 IS NULL AND l_segment_20 IS NULL ) THEN

            l_segments_provided := FALSE;
      ELSE
            l_segments_provided := TRUE;
      END IF;
    END IF; -- end of p_exists_inv_name = 1

    IF (l_inv_id = -1 AND l_segments_provided = FALSE) THEN

        -- If Inventory Item Id or Item Name are not given then Check for List Flow
        SELECT existsNode(xmlcontent, '/itemQueryParameters/ItemsList')
        INTO l_exists_items_list
        FROM EGO_PUB_WS_PARAMS
        WHERE session_id = p_session_id;

        IF l_exists_items_list = 1
        THEN
          p_mode:= 'LIST';
        ELSE
          p_mode := 'MODE';
        END IF; -- l_exists_items_list = 1

    ELSE
          -- If Inventory Item Id or Item Name are given then consider as HMDM Flow
          p_mode := 'HMDM';

          IF (p_exists_org_id = 1) THEN
            SELECT Nvl(extractValue(xmlcontent, '/itemQueryParameters/OrganizationId'), -1)
            INTO l_org_id
            FROM EGO_PUB_WS_PARAMS
            WHERE session_id = p_session_id;
          END IF; -- end of p_exists_org_id = 1

          IF (p_exists_org_code = 1) THEN
            SELECT extractValue(xmlcontent, '/itemQueryParameters/OrganizationCode')
            INTO l_org_code
            FROM EGO_PUB_WS_PARAMS
            WHERE session_id = p_session_id;
          END IF;  --  end of p_exists_org_code = 1

          IF (l_org_id = -1 AND l_org_code IS NULL) THEN
            -- error
            RAISE e_no_org_details;
          ELSE
            IF (p_exists_rev_id = 1) THEN
                SELECT Nvl(extractValue(xmlcontent, '/itemQueryParameters/RevisionId'), -1)
                INTO l_rev_id
                FROM EGO_PUB_WS_PARAMS
                WHERE session_id = p_session_id;
            END IF;  -- end of (p_exists_rev_id = 1)

            IF (p_exists_revision = 1) THEN
                SELECT extractValue(xmlcontent, '/itemQueryParameters/Revision')
                INTO l_revision
                FROM EGO_PUB_WS_PARAMS
                WHERE session_id = p_session_id;
            END IF;  -- end of (p_exists_revision = 1)

            IF (p_exists_rev_date = 1) THEN
                SELECT To_Date(extractValue(xmlcontent, '/itemQueryParameters/RevisionDate'), 'YYYY.MM.DD HH24:MI:SS')
                INTO l_rev_date
                FROM EGO_PUB_WS_PARAMS
                WHERE session_id = p_session_id;
            END IF;  -- end of (p_exists_rev_date = 1)

            IF (l_rev_id = -1 AND l_revision IS NULL AND l_rev_date IS NULL) THEN
              -- error
              RAISE e_no_rev_details;
            END IF;  -- end of (l_rev_id = -1 AND l_revision IS NULL AND l_rev_date IS NULL)

          END IF; -- end of (l_org_id = -1 AND l_org_code IS NULL)

          -- validate for the inputs (inv item , org, rev)
          v_is_valid_org := Validate_organization(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_org_id => l_org_id,
                                                p_org_code => l_org_code,
                                                p_index => 1,
                                                p_organization_id => l_organization_id
                                                );
          IF (v_is_valid_org) THEN
              v_is_valid_item := Validate_Item(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_inv_id => l_inv_id ,
                                                p_org_id => l_organization_id ,
                                                p_segment1 => l_segment_1 ,
                                                p_segment2 => l_segment_2 ,
                                                p_segment3 => l_segment_3 ,
                                                p_segment4 => l_segment_4 ,
                                                p_segment5 => l_segment_5 ,
                                                p_segment6 => l_segment_6 ,
                                                p_segment7 => l_segment_7 ,
                                                p_segment8 => l_segment_8 ,
                                                p_segment9 => l_segment_9 ,
                                                p_segment10 => l_segment_10 ,
                                                p_segment11 => l_segment_11 ,
                                                p_segment12 => l_segment_12 ,
                                                p_segment13 => l_segment_13 ,
                                                p_segment14 => l_segment_14 ,
                                                p_segment15 => l_segment_15 ,
                                                p_segment16 => l_segment_16 ,
                                                p_segment17 => l_segment_17 ,
                                                p_segment18 => l_segment_18 ,
                                                p_segment19 => l_segment_19 ,
                                                p_segment20 => l_segment_20 ,
                                                p_index => 1,
                                                p_inv_item_id => l_inv_item_id
                                                ) ;

              IF (v_is_valid_item) THEN
                  v_is_valid_rev :=  validate_revision_details (p_session_id => p_session_id,
                                                                p_odi_session_id => p_odi_session_id,
                                                                p_inv_id => l_inv_item_id,
                                                                p_org_id =>  l_organization_id ,
                                                                p_rev_id => l_rev_id,
                                                                p_revision => l_revision,
                                                                p_rev_date => l_rev_date,
                                                                p_index => 1,
                                                                p_revision_id => l_revision_id,
                                                                p_revision_date => l_revision_date
                                                                ) ;

                  IF (v_is_valid_rev) THEN
                    POPULATE_REVISION_DETAILS(p_session_id ,
                                p_odi_session_id ,
                                p_rev_id => l_rev_id ,
                                p_revision => l_revision ,
                                p_rev_date => l_rev_date ,
                                p_index => 1);

                    INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value, pk4_value, pk5_value, SEQUENCE_NUMBER)
                    VALUES (p_session_id,p_odi_session_id,'ITEM',l_inv_item_id,l_organization_id,l_revision_id, 1, To_Char(l_revision_date,'YYYY.MM.DD HH24:MI:SS'), 1);
                  END IF;
              ELSE
                POPULATE_REVISION_DETAILS(p_session_id ,
                                p_odi_session_id ,
                                p_rev_id => l_rev_id ,
                                p_revision => l_revision ,
                                p_rev_date => l_rev_date ,
                                p_index => 1);
              END IF;  --end of (v_is_valid_item)
          ELSE
            IF (l_inv_id <> -1) THEN
                    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                               p_odi_session_id => p_odi_session_id,
                               p_input_id  => 1,
                               p_param_name  => 'InventoryItemId',
                               p_param_value => l_inv_id );
            ELSE
              POPULATE_SEGMENTS(p_session_id ,
                    p_odi_session_id ,
                    p_segment1 => l_segment_1 ,
                    p_segment2 => l_segment_2 ,
                    p_segment3 => l_segment_3 ,
                    p_segment4 => l_segment_4 ,
                    p_segment5 => l_segment_5 ,
                    p_segment6 => l_segment_6 ,
                    p_segment7 => l_segment_7 ,
                    p_segment8 => l_segment_8 ,
                    p_segment9 => l_segment_9 ,
                    p_segment10 => l_segment_10 ,
                    p_segment11 => l_segment_11 ,
                    p_segment12 => l_segment_12 ,
                    p_segment13 => l_segment_13 ,
                    p_segment14 => l_segment_14 ,
                    p_segment15 => l_segment_15 ,
                    p_segment16 => l_segment_16 ,
                    p_segment17 => l_segment_17 ,
                    p_segment18 => l_segment_18 ,
                    p_segment19 => l_segment_19 ,
                    p_segment20 => l_segment_20 ,
                    p_index => 1 );

            END IF;

            POPULATE_REVISION_DETAILS(p_session_id ,
                                p_odi_session_id ,
                                p_rev_id => l_rev_id ,
                                p_revision => l_revision ,
                                p_rev_date => l_rev_date ,
                                p_index => 1);
          END IF; -- end of (v_is_valid_org)
    END IF; -- end of (l_inv_id = -1 AND l_segments_provided = FALSE)

  ELSE
    -- List Flow
    SELECT existsNode(xmlcontent, '/itemQueryParameters/ItemsList')
    INTO l_exists_items_list
    FROM EGO_PUB_WS_PARAMS
    WHERE session_id = p_session_id;

    IF l_exists_items_list = 1
    THEN
      -- IN LIST MODE
      p_mode:= 'LIST';
    ELSE
      p_mode := 'MODE';
    END IF;

  END IF;  /* end of ((p_exists_inv_id = 1 OR p_exists_inv_name = 1) AND
    (p_exists_org_id = 1 OR p_exists_org_code = 1) AND
    (p_exists_rev_id = 1 OR p_exists_revision = 1 OR p_exists_rev_date = 1))
    */
IF (p_mode = 'LIST') THEN

      SELECT   Nvl(extractValue(item_id, '/InventoryItemId'),-1)
      BULK COLLECT INTO  l_item_id_tab
      FROM  (SELECT  Value(itemId) item_id
          FROM EGO_PUB_WS_PARAMS i,
          TABLE(XMLSequence(
          extract(i.xmlcontent, '/itemQueryParameters/ItemsList/InventoryItemId') )) itemId
          WHERE session_id=p_session_id
      );

      BEGIN
        SELECT extractValue(segments, '/InventoryItemName/Segment1'), extractValue(segments, '/InventoryItemName/Segment2') ,
          extractValue(segments, '/InventoryItemName/Segment3'), extractValue(segments, '/InventoryItemName/Segment4') ,
          extractValue(segments, '/InventoryItemName/Segment5'), extractValue(segments, '/InventoryItemName/Segment6') ,
          extractValue(segments, '/InventoryItemName/Segment7'), extractValue(segments, '/InventoryItemName/Segment8') ,
          extractValue(segments, '/InventoryItemName/Segment9'), extractValue(segments, '/InventoryItemName/Segment10') ,
          extractValue(segments, '/InventoryItemName/Segment11'), extractValue(segments, '/InventoryItemName/Segment12') ,
          extractValue(segments, '/InventoryItemName/Segment13'), extractValue(segments, '/InventoryItemName/Segment14') ,
          extractValue(segments, '/InventoryItemName/Segment15'), extractValue(segments, '/InventoryItemName/Segment16') ,
          extractValue(segments, '/InventoryItemName/Segment17'), extractValue(segments, '/InventoryItemName/Segment18') ,
          extractValue(segments, '/InventoryItemName/Segment19'), extractValue(segments, '/InventoryItemName/Segment20')
        BULK COLLECT INTO
        l_segment_1_tab,  l_segment_2_tab,
        l_segment_3_tab,  l_segment_4_tab,
        l_segment_5_tab,  l_segment_6_tab,
        l_segment_7_tab,  l_segment_8_tab,
        l_segment_9_tab,  l_segment_10_tab,
        l_segment_11_tab,  l_segment_12_tab,
        l_segment_13_tab,  l_segment_14_tab,
        l_segment_15_tab, l_segment_16_tab,
        l_segment_17_tab, l_segment_18_tab,
        l_segment_19_tab, l_segment_20_tab
              FROM  (SELECT  Value(itemName) segments
          FROM EGO_PUB_WS_PARAMS i,
          TABLE(XMLSequence(extract(i.xmlcontent, '/itemQueryParameters/ItemsList/InventoryItemName'))) itemName
          WHERE session_id = p_session_id
        );
        IF l_segment_1_tab.Count > 0 THEN
          l_list_segments := TRUE;
        ELSE
          l_list_segments := FALSE;
        END IF;
      EXCEPTION
      WHEN OTHERS  THEN
        l_list_segments := FALSE;
      END;


      SELECT   Nvl(extractValue(org_id, '/OrganizationId'), -1)
      BULK COLLECT INTO  l_org_id_tab
      FROM  (SELECT  Value(orgId) org_id
          FROM EGO_PUB_WS_PARAMS i,
          TABLE(XMLSequence(
          extract(i.xmlcontent, '/itemQueryParameters/ItemsList/OrganizationId') )) orgId
          WHERE session_id=p_session_id
      );

      SELECT   extractValue(org_code, '/OrganizationCode')
      BULK COLLECT INTO  l_org_code_tab
      FROM  (SELECT  Value(orgCode) org_code
          FROM EGO_PUB_WS_PARAMS i,
          TABLE(XMLSequence(
          extract(i.xmlcontent, '/itemQueryParameters/ItemsList/OrganizationCode') )) orgCode
          WHERE session_id=p_session_id
      );

      SELECT   Nvl(extractValue(rev_id, '/RevisionId'), -1)
      BULK COLLECT INTO  l_rev_id_tab
      FROM  (SELECT  Value(revId) rev_id
          FROM EGO_PUB_WS_PARAMS i,
          TABLE(XMLSequence(
          extract(i.xmlcontent, '/itemQueryParameters/ItemsList/RevisionId') )) revId
          WHERE session_id=p_session_id
      );

      SELECT   extractValue(rev_lable, '/Revision')
      BULK COLLECT INTO  l_rev_tab
      FROM  (SELECT  Value(rev) rev_lable
          FROM EGO_PUB_WS_PARAMS i,
          TABLE(XMLSequence(
          extract(i.xmlcontent, '/itemQueryParameters/ItemsList/Revision') )) rev
          WHERE session_id=p_session_id
      );

      l_item_ids_count := 0;
      FOR id IN 1..l_item_id_tab.Count  LOOP
        IF (l_item_id_tab(id) = -1) THEN
          l_item_ids_count := l_item_ids_count + 1;
        END IF;
      END LOOP;

      IF (l_item_ids_count = l_item_id_tab.Count) THEN
        IF (l_list_segments = FALSE) THEN
          p_mode := 'MODE';
          RAISE e_invalid_invocation_mode;
        ELSE
          l_seg1_count := 0;
          FOR seg in 1..l_segment_1_tab.Count  LOOP
            IF (l_segment_1_tab(seg) IS NULL) THEN
              l_seg1_count := l_seg1_count + 1;
            END IF;
          END LOOP;

          IF (l_seg1_count = l_segment_1_tab.Count) THEN
            p_mode := 'MODE';
            RAISE e_invalid_invocation_mode;
          END IF;
        END IF;
      END IF;


      FOR i in 1..l_item_id_tab.Count  LOOP
        l_list_inv_id := l_item_id_tab(i);
        l_list_org_id := l_org_id_tab(i);
        l_list_rev_id := l_rev_id_tab(i);

         -- validate for the inputs (inv item , org, rev)
          v_is_valid_org := Validate_organization(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_org_id => l_list_org_id,
                                                p_org_code => l_org_code_tab(i),
                                                p_index => i,
                                                p_organization_id => l_organization_id
                                                );

          IF (v_is_valid_org) THEN
              -- Need to do for segemnts also , do the validation and log the errors.
              --validate_items(l_item_id_tab(i), l_org_id_tab(i));
              IF (l_list_segments = FALSE) THEN
                v_is_valid_item :=  Validate_Item(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_inv_id => l_list_inv_id ,
                                                p_org_id => l_organization_id ,
                                                p_segment1 => NULL,
                                                p_segment2 => NULL,
                                                p_segment3 => NULL,
                                                p_segment4 => NULL,
                                                p_segment5 => NULL,
                                                p_segment6 => NULL,
                                                p_segment7 => NULL,
                                                p_segment8 => NULL,
                                                p_segment9 => NULL,
                                                p_segment10 => NULL,
                                                p_segment11 => NULL,
                                                p_segment12 => NULL,
                                                p_segment13 => NULL,
                                                p_segment14 => NULL,
                                                p_segment15 => NULL,
                                                p_segment16 => NULL ,
                                                p_segment17 => NULL ,
                                                p_segment18 => NULL ,
                                                p_segment19 => NULL ,
                                                p_segment20 => NULL ,
                                                p_index => i,
                                                p_inv_item_id => l_inv_item_id
                                                ) ;

              ELSE
                v_is_valid_item :=  Validate_Item(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_inv_id => l_list_inv_id ,
                                                p_org_id => l_organization_id ,
                                                p_segment1 => l_segment_1_tab(i),
                                                p_segment2 => l_segment_2_tab(i),
                                                p_segment3 => l_segment_3_tab(i),
                                                p_segment4 => l_segment_4_tab(i),
                                                p_segment5 => l_segment_5_tab(i),
                                                p_segment6 => l_segment_6_tab(i),
                                                p_segment7 => l_segment_7_tab(i),
                                                p_segment8 => l_segment_8_tab(i),
                                                p_segment9 => l_segment_9_tab(i),
                                                p_segment10 => l_segment_10_tab(i),
                                                p_segment11 => l_segment_11_tab(i),
                                                p_segment12 => l_segment_12_tab(i),
                                                p_segment13 => l_segment_13_tab(i),
                                                p_segment14 => l_segment_14_tab(i),
                                                p_segment15 => l_segment_15_tab(i),
                                                p_segment16 => l_segment_16_tab(i) ,
                                                p_segment17 => l_segment_17_tab(i) ,
                                                p_segment18 => l_segment_18_tab(i) ,
                                                p_segment19 => l_segment_19_tab(i) ,
                                                p_segment20 => l_segment_20_tab(i) ,
                                                p_index => i,
                                                p_inv_item_id => l_inv_item_id
                                                ) ;
            END IF;
              IF (v_is_valid_item) THEN
                -- Bug 8659192 : Start
                IF (p_exists_rev_date = 1) THEN
                  SELECT To_Date(extractValue(xmlcontent, '/itemQueryParameters/RevisionDate'),'YYYY.MM.DD HH24:MI:SS')
                  INTO l_rev_date
                  FROM EGO_PUB_WS_PARAMS
                  WHERE session_id = p_session_id;
                END IF;  -- end of (p_exists_rev_date = 1)
                -- Bug 8659192 : End
                v_is_valid_rev :=  validate_revision_details(p_session_id => p_session_id,
                                                              p_odi_session_id => p_odi_session_id,
                                                              p_inv_id => l_inv_item_id,
                                                              p_org_id =>  l_organization_id ,
                                                              p_rev_id => l_list_rev_id,
                                                              p_revision => l_rev_tab(i),
                                                              p_rev_date => l_rev_date,     -- Bug 8659192
                                                              p_index => i,
                                                              p_revision_id => l_revision_id ,
                                                              p_revision_date => l_revision_date
                                                             ) ;

                IF (v_is_valid_rev) THEN
                  POPULATE_REVISION_DETAILS(p_session_id ,
                              p_odi_session_id ,
                              p_rev_id => l_list_rev_id ,
                              p_revision => l_rev_tab(i) ,
                              p_rev_date => l_rev_date ,
                              p_index => i);

                  -- Bug 8659192 : Insert the Rev Date for the Item, in the column pk5_value
                  INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value, pk4_value, pk5_value, SEQUENCE_NUMBER)
                  VALUES (p_session_id,p_odi_session_id,'ITEM',l_inv_item_id,l_organization_id,l_revision_id, i, To_Char(l_revision_date,'YYYY.MM.DD HH24:MI:SS') , i);
                END IF;
              ELSE
                SELECT To_Date(extractValue(xmlcontent, '/itemQueryParameters/RevisionDate'),'YYYY.MM.DD HH24:MI:SS')
                INTO l_rev_date
                FROM EGO_PUB_WS_PARAMS
                WHERE session_id = p_session_id;

                POPULATE_REVISION_DETAILS(p_session_id ,
                                p_odi_session_id ,
                                p_rev_id => l_list_rev_id ,
                                p_revision => l_rev_tab(i) ,
                                p_rev_date => l_rev_date ,
                                p_index => i);

              END IF; -- (v_is_valid_item)

          ELSE
            IF (l_list_inv_id <> -1) THEN
                  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => i,
                             p_param_name  => 'InventoryItemId',
                             p_param_value => l_list_inv_id );
            ELSE

              POPULATE_SEGMENTS(p_session_id ,
                    p_odi_session_id ,
                    p_segment1 => l_segment_1_tab(i),
                    p_segment2 => l_segment_2_tab(i),
                    p_segment3 => l_segment_3_tab(i),
                    p_segment4 => l_segment_4_tab(i),
                    p_segment5 => l_segment_5_tab(i),
                    p_segment6 => l_segment_6_tab(i),
                    p_segment7 => l_segment_7_tab(i),
                    p_segment8 => l_segment_8_tab(i),
                    p_segment9 => l_segment_9_tab(i),
                    p_segment10 => l_segment_10_tab(i),
                    p_segment11 => l_segment_11_tab(i),
                    p_segment12 => l_segment_12_tab(i),
                    p_segment13 => l_segment_13_tab(i),
                    p_segment14 => l_segment_14_tab(i),
                    p_segment15 => l_segment_15_tab(i),
                    p_segment16 => l_segment_16_tab(i) ,
                    p_segment17 => l_segment_17_tab(i) ,
                    p_segment18 => l_segment_18_tab(i) ,
                    p_segment19 => l_segment_19_tab(i) ,
                    p_segment20 => l_segment_20_tab(i) ,
                    p_index => i );
            END IF;

            SELECT To_Date(extractValue(xmlcontent, '/itemQueryParameters/RevisionDate'),'YYYY.MM.DD HH24:MI:SS')
            INTO l_rev_date
            FROM EGO_PUB_WS_PARAMS
            WHERE session_id = p_session_id;

            POPULATE_REVISION_DETAILS(p_session_id ,
                              p_odi_session_id ,
                              p_rev_id => l_list_rev_id ,
                              p_revision => l_rev_tab(i) ,
                              p_rev_date => l_rev_date ,
                              p_index => i);

          END IF; -- (v_is_valid_org)

      END LOOP;

    END IF;

END process_non_batch_flow;



FUNCTION  Validate_Item(p_session_id    IN  NUMBER,
                        p_odi_session_id IN NUMBER,
                        p_inv_id in number,
                        p_org_id in NUMBER ,
                        p_segment1 in varchar2,
                        p_segment2 in varchar2,
                        p_segment3 in varchar2,
                        p_segment4 in varchar2,
                        p_segment5 in varchar2,
                        p_segment6 in varchar2,
                        p_segment7 in varchar2,
                        p_segment8 in varchar2,
                        p_segment9 in varchar2,
                        p_segment10 in varchar2,
                        p_segment11 in varchar2,
                        p_segment12 in varchar2,
                        p_segment13 in varchar2,
                        p_segment14 in varchar2,
                        p_segment15 in varchar2,
                        p_segment16 in varchar2,
                        p_segment17 in varchar2,
                        p_segment18 in varchar2,
                        p_segment19 in varchar2,
                        p_segment20 in varchar2,
                        p_index in number,
                        p_inv_item_id OUT NOCOPY number
                        ) RETURN BOOLEAN
IS

BEGIN
  IF (p_inv_id <> -1  AND  p_org_id <> -1)  THEN

    select inventory_item_id
    INTO  p_inv_item_id
    from mtl_system_items_kfv
    WHERE organization_id = p_org_id
    AND  inventory_item_id = p_inv_id;

    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'InventoryItemId',
                             p_param_value => p_inv_item_id );

  ELSE
    select inventory_item_id
    INTO  p_inv_item_id
     from mtl_system_items_kfv
    WHERE organization_id = p_org_id
    AND  Nvl(segment1, 0) = Nvl(p_segment1, 0)
    AND  Nvl(segment2, 0) = Nvl(p_segment2, 0)
    AND  Nvl(segment3, 0) = Nvl(p_segment3, 0)
    AND  Nvl(segment4, 0) = Nvl(p_segment4, 0)
    AND  Nvl(segment5, 0) = Nvl(p_segment5, 0)
    AND  Nvl(segment6, 0) = Nvl(p_segment6, 0)
    AND  Nvl(segment7, 0) = Nvl(p_segment7, 0)
    AND  Nvl(segment8, 0) = Nvl(p_segment8, 0)
    AND  Nvl(segment9, 0) = Nvl(p_segment9, 0)
    AND  Nvl(segment10, 0) = Nvl(p_segment10, 0)
    AND  Nvl(segment11, 0) = Nvl(p_segment11, 0)
    AND  Nvl(segment12, 0) = Nvl(p_segment12, 0)
    AND  Nvl(segment13, 0) = Nvl(p_segment13, 0)
    AND  Nvl(segment14, 0) = Nvl(p_segment14, 0)
    AND  Nvl(segment15, 0) = Nvl(p_segment15, 0)
    AND  Nvl(segment16, 0) = Nvl(p_segment16, 0)
    AND  Nvl(segment17, 0) = Nvl(p_segment17, 0)
    AND  Nvl(segment18, 0) = Nvl(p_segment18, 0)
    AND  Nvl(segment19, 0) = Nvl(p_segment19, 0)
    AND  Nvl(segment20, 0) = Nvl(p_segment20, 0) ;

    POPULATE_SEGMENTS(p_session_id ,
                    p_odi_session_id ,
                    p_segment1 ,
                    p_segment2 ,
                    p_segment3 ,
                    p_segment4 ,
                    p_segment5 ,
                    p_segment6 ,
                    p_segment7 ,
                    p_segment8 ,
                    p_segment9 ,
                    p_segment10 ,
                    p_segment11 ,
                    p_segment12 ,
                    p_segment13 ,
                    p_segment14 ,
                    p_segment15 ,
                    p_segment16 ,
                    p_segment17 ,
                    p_segment18 ,
                    p_segment19 ,
                    p_segment20 ,
                    p_index );

  END IF;
  RETURN TRUE;
EXCEPTION
WHEN No_Data_Found THEN
  IF (p_inv_id <> -1  AND  p_org_id <> -1) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'InventoryItemId',
                             p_param_value => p_inv_id );

     EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_ITEM_ID',
                      p_err_message => 'Invalid Inventory Item Id');

  ELSE
    POPULATE_SEGMENTS(p_session_id ,
                    p_odi_session_id ,
                    p_segment1 ,
                    p_segment2 ,
                    p_segment3 ,
                    p_segment4 ,
                    p_segment5 ,
                    p_segment6 ,
                    p_segment7 ,
                    p_segment8 ,
                    p_segment9 ,
                    p_segment10 ,
                    p_segment11 ,
                    p_segment12 ,
                    p_segment13 ,
                    p_segment14 ,
                    p_segment15 ,
                    p_segment16 ,
                    p_segment17 ,
                    p_segment18 ,
                    p_segment19 ,
                    p_segment20 ,
                    p_index );

     EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_ITEM_NAME',
                      p_err_message => 'Invalid Inventory Item Name');
  END IF;

  RETURN FALSE;

WHEN OTHERS THEN
  RAISE;

END Validate_Item;


function Validate_organization(p_session_id    IN  NUMBER,
                              p_odi_session_id IN NUMBER,
                              p_org_id in NUMBER ,
                              p_org_code IN VARCHAR2,
                              p_index in number,
                              p_organization_id OUT NOCOPY number
                              )  RETURN BOOLEAN
IS

BEGIN
  IF (p_org_id <> -1)  THEN
    select organization_id
    INTO p_organization_id
    from mtl_parameters
    WHERE organization_id = p_org_id;

    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'OrganizationId',
                             p_param_value => p_org_id );
  ELSE
    select organization_id
    INTO p_organization_id
    from mtl_parameters
    WHERE organization_code = p_org_code;

    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'OrganizationCode',
                             p_param_value => p_org_code );

  END IF;
  RETURN TRUE;
EXCEPTION
WHEN No_Data_Found THEN
    IF (p_org_id <> -1)  THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'OrganizationId',
                             p_param_value => p_org_id );

    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_ORG_ID',
                      p_err_message => 'Invalid Organization Id');
  ELSE
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'OrganizationCode',
                             p_param_value => p_org_code );

    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_ORG_CODE',
                      p_err_message => 'Invalid Organization Code');

  END IF;

  RETURN FALSE;
WHEN OTHERS THEN
  RAISE;

END Validate_organization;


function validate_revision_details(p_session_id    IN  NUMBER,
                                  p_odi_session_id IN NUMBER,
                                  p_inv_id IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_rev_id in NUMBER ,
                                  p_revision IN varchar2,
                                  p_rev_date IN DATE,
                                  p_index in number,
                                  p_revision_id     OUT NOCOPY NUMBER ,
                                  p_revision_date OUT NOCOPY DATE
                                  )  RETURN BOOLEAN
is

v_effectivity_date DATE;
v_end_date DATE;
v_impl_date DATE;
v_is_valid_rev_date BOOLEAN;
v_count NUMBER;
v_current_date DATE;
e_no_revision EXCEPTION;
e_unimpl_revision EXCEPTION;

BEGIN
  IF (p_rev_date IS NOT NULL) THEN
    BEGIN
      SELECT *
      INTO p_revision_id, v_effectivity_date, v_end_date, v_impl_date
      FROM
        (SELECT revision_id ,
         effectivity_date ,
         (SELECT NVL( MIN(b.effectivity_date)-(1/86400),to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss')) end_date
         FROM    mtl_item_revisions_b b
         WHERE   b.inventory_item_id = a.inventory_item_id
             AND b.organization_id   = a.organization_id
             AND b.effectivity_date  > a.effectivity_date
         ) end_date,
         implementation_date
        from mtl_item_revisions_b a
        WHERE organization_id = p_org_id
          AND  inventory_item_id = p_inv_id
          AND effectivity_date < p_rev_date
          AND implementation_date IS NOT NULL
        ORDER BY effectivity_date DESC) list
      WHERE ROWNUM = 1;

      p_revision_date :=  p_rev_date;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE e_no_revision;
    END;
  ELSE
    IF (p_rev_id <> -1)  THEN
      SELECT revision_id ,
         effectivity_date ,
         (SELECT NVL( MIN(b.effectivity_date)-(1/86400),to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss')) end_date
         FROM    mtl_item_revisions_b b
         WHERE   b.inventory_item_id = a.inventory_item_id
             AND b.organization_id   = a.organization_id
             AND b.effectivity_date  > a.effectivity_date
         ) end_date,
         implementation_date
      INTO p_revision_id, v_effectivity_date, v_end_date, v_impl_date
      from mtl_item_revisions_b a
      WHERE organization_id = p_org_id
      AND  inventory_item_id = p_inv_id
      AND revision_id = p_rev_id;
    ELSIF (p_revision IS NOT NULL) THEN
      SELECT revision_id ,
         effectivity_date ,
         (SELECT NVL( MIN(b.effectivity_date)-(1/86400),to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss')) end_date
         FROM    mtl_item_revisions_b b
         WHERE   b.inventory_item_id = a.inventory_item_id
             AND b.organization_id   = a.organization_id
             AND b.effectivity_date  > a.effectivity_date
         ) end_date,
         implementation_date
      INTO p_revision_id, v_effectivity_date, v_end_date, v_impl_date
      from mtl_item_revisions_b a
      WHERE organization_id = p_org_id
      AND  inventory_item_id = p_inv_id
      AND revision = p_revision;
    ELSE
      p_revision_date := SYSDATE;

      -- Do we need to fetch the latest revision based on sysdate if rev id and revision are null????
      SELECT *
      INTO p_revision_id, v_effectivity_date, v_end_date, v_impl_date
      FROM
        (SELECT revision_id ,
         effectivity_date ,
         (SELECT NVL( MIN(b.effectivity_date)-(1/86400),to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss')) end_date
         FROM    mtl_item_revisions_b b
         WHERE   b.inventory_item_id = a.inventory_item_id
             AND b.organization_id   = a.organization_id
             AND b.effectivity_date  > a.effectivity_date
         ) end_date,
         implementation_date
        from mtl_item_revisions_b a
        WHERE organization_id = p_org_id
          AND  inventory_item_id = p_inv_id
          AND effectivity_date < SYSDATE
          AND implementation_date IS NOT NULL
        ORDER BY effectivity_date DESC) list
      WHERE ROWNUM = 1;
    END IF;

    IF ((p_rev_id <> -1) OR p_revision IS NOT NULL) THEN
      IF (v_impl_date IS NULL ) THEN
        RAISE e_unimpl_revision;
      END IF;

      SELECT SYSDATE INTO v_current_date from dual;

      IF(v_end_date <= v_current_date) THEN
        p_revision_date := v_end_date;
      ELSE
        -- Bug 8659192: Start
        IF (v_current_date >= v_effectivity_date) THEN
           -- For Current Revision Take Sysdate
           p_revision_date := SYSDATE;
        ELSE
          p_revision_date := v_effectivity_date;
        END IF;
        -- Bug 8659192: End
      END IF;
    END IF;
  END IF; -- end of if (p_rev_date IS NOT NULL)
  RETURN TRUE;
EXCEPTION
WHEN e_no_revision THEN
  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'RevisionDate',
                             p_param_value => to_char(p_rev_date,'YYYY.MM.DD HH24:MI:SS')
                             );

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_NO_REV_EXISTS',
                      p_err_message => 'No revision exists for the revision date');

  RETURN FALSE;

WHEN e_unimpl_revision then
  IF (p_rev_id <> -1) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'RevisionId',
                             p_param_value => p_rev_id
                             );
  END IF;

  IF (p_revision IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'Revision',
                             p_param_value => p_revision
                             );
  END IF;

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_UNIMPL_REVISION',
                      p_err_message => 'Unimplemented Revisions are not published');

  RETURN FALSE;

WHEN No_Data_Found THEN
  IF (p_rev_id <> -1)  THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'RevisionId',
                             p_param_value => p_rev_id
                             );
  ELSIF (p_revision IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'Revision',
                             p_param_value => p_revision
                             );
  ELSE
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'RevisionDate',
                             p_param_value => to_char(p_rev_date,'YYYY.MM.DD HH24:MI:SS')
                             );
  END IF;

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_REV_DETAILS',
                      p_err_message => 'Invalid Revision Details');

  RETURN FALSE;

WHEN OTHERS THEN
  RAISE;

END validate_revision_details;


function validate_structure_name(p_session_id    IN  NUMBER,
                                p_odi_session_id IN NUMBER,
                                p_org_id   IN NUMBER,
                                p_structure_name IN varchar2,
                                p_input_id    IN  NUMBER
                                )  RETURN BOOLEAN
is

v_count NUMBER;
v_org_code VARCHAR2(10);
p_index NUMBER;

BEGIN

  IF(p_structure_name is not null) then
    select 1 INTO v_count
    from
    bom_alternate_designators
    WHERE organization_id = p_org_id
    AND  ALTERNATE_DESIGNATOR_CODE = p_structure_name;

    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
WHEN No_Data_Found THEN
  SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
  WHERE session_id =  p_session_id;

  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'StructureName',
                             p_param_value => p_structure_name
                             );

  BEGIN

    SELECT PARAM_VALUE into v_org_code
    FROM EGO_PUB_WS_INPUT_IDENTIFIERS
    WHERE SESSION_ID = p_session_id
    AND INPUT_ID = p_input_id
    AND PARAM_NAME = 'OrganizationCode';

    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'OrganizationCode',
                           p_param_value => v_org_code
                           );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'OrganizationId',
                             p_param_value => p_org_id
                             );
  END;

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => p_index,
                          p_err_code => 'EGO_INVALID_STRUCTURE',
                          p_err_message => 'Invalid Structure Name and Org Combination');
  RETURN FALSE;

WHEN OTHERS THEN
  RAISE;

END validate_structure_name;

PROCEDURE check_security(p_session_id IN  NUMBER,
                          p_odi_session_id IN NUMBER,
                          p_priv_check IN  VARCHAR2,
                          p_for_exploded_items IN VARCHAR2,
                          x_return_status OUT NOCOPY  VARCHAR2
                         )
  IS

  l_sec_predicate VARCHAR2(32767);
  l_dynamic_update_sql VARCHAR2(32767);
  l_dynamic_sql VARCHAR2(32767);
  l_item_id NUMBER;
  l_org_id NUMBER;
  l_rev_id NUMBER;

  l_mode VARCHAR2(10);
  l_batch_id NUMBER;
  l_batch_ent_obj_id NUMBER;
  l_user_name VARCHAR2(100);
  l_structure_name  VARCHAR2(100);
  p_index number;
  l_seq_number NUMBER;
  l_component_name  mtl_system_items_b_kfv.CONCATENATED_SEGMENTS%TYPE;

  TYPE DYNAMIC_CUR IS REF CURSOR;
  v_dynamic_cursor         DYNAMIC_CUR;

BEGIN

  select char_value
  into l_mode
  from EGO_PUB_WS_CONFIG
  where parameter_name = 'INVOCATION_MODE'
  and session_id  = p_session_id;

  IF (l_mode = 'BATCH') THEN
    SELECT party_name INTO l_user_name
    FROM EGO_USER_V WHERE USER_ID = FND_GLOBAL.USER_ID;

    select Numeric_Value
    into l_batch_id
    from EGO_PUB_WS_CONFIG
    where parameter_name = 'BATCH_ID'
    and session_id  = p_session_id;

    SELECT CHAR_VALUE INTO l_structure_name FROM EGO_PUB_BAT_PARAMS_B
    WHERE type_id=l_batch_id AND Upper(parameter_name) ='STRUCTURE_NAME';
  END IF;

   EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => p_priv_check
       ,p_object_name      => 'EGO_ITEM'
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(FND_GLOBAL.PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'i.pk1_value'
       ,p_pk2_alias        => 'i.pk2_value'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );

    IF x_return_status IN ('T','F')  THEN

      IF l_sec_predicate IS NOT NULL THEN

        BEGIN
          l_dynamic_sql := ' select distinct PK4_VALUE ' ||
                         ' from EGO_ODI_WS_ENTITIES i ' ||
                         ' where i.session_id = :1 ' ||
                         ' AND nvl(i.REF1_VALUE, ''Y'') = ''Y'' ' ||
                         ' AND NOT ' || l_sec_predicate;

          OPEN v_dynamic_cursor FOR l_dynamic_sql
          USING  p_session_id;
          LOOP
            FETCH  v_dynamic_cursor INTO  l_seq_number;
            EXIT WHEN v_dynamic_cursor%NOTFOUND;

            IF (p_for_exploded_items = 'N') THEN
              EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                              p_odi_session_id => p_odi_session_id,
                              p_input_id  => l_seq_number,
                              p_err_code => 'EGO_NO_PUBLISH_PRIV',
                              p_err_message => 'User does not have the publish privilege for item');

            ELSE
              IF (l_mode = 'BATCH') THEN
                SELECT BATCH_ENTITY_OBJECT_ID
                INTO l_batch_ent_obj_id
                FROM Ego_Pub_Bat_Ent_Objs_v
                WHERE batch_id = l_batch_id
                AND (PK1_VALUE, PK2_VALUE, PK3_VALUE) in (select pk1_value, pk2_value, pk3_value
                                                          from EGO_ODI_WS_ENTITIES
                                                          where session_id = p_session_id
                                                          and SEQUENCE_NUMBER = l_seq_number);

                -- Need to use an API - which will be provided by PUB FWK
                UPDATE EGO_PUB_BAT_STATUS_B
                SET STATUS_CODE = 'F' , MESSAGE = 'User ' || l_user_name ||' does not have the publilsh privilege on few components of the structure ' ||
                l_structure_name || ' for this Item.'
                WHERE batch_id = l_batch_id AND BATCH_ENTITY_OBJECT_ID = l_batch_ent_obj_id;

              END IF;
            END IF;
          END LOOP;
            CLOSE v_dynamic_cursor;
            x_return_status := 'S';
        EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E';
          RAISE;
          IF (v_dynamic_cursor%ISOPEN) THEN
            CLOSE v_dynamic_cursor;
          END IF;
        END; -- end of BEGIN

        l_dynamic_update_sql := ' update EGO_ODI_WS_ENTITIES i ' ||
                                ' set REF1_VALUE = ''N'' ' ||
                                ' where i.session_id = :1 ' ||
                                ' AND nvl(i.REF1_VALUE, ''Y'') = ''Y'' ' ||
                                ' AND NOT ' || l_sec_predicate;

        EXECUTE IMMEDIATE l_dynamic_update_sql
        USING IN p_session_id;

        IF (p_for_exploded_items = 'Y') THEN
          EGO_DATA_SECURITY.get_security_predicate
             (p_api_version      => 1.0
             ,p_function         => 'EGO_VIEW_ITEM'
             ,p_object_name      => 'EGO_ITEM'
             ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(FND_GLOBAL.PARTY_ID)
             ,p_statement_type   => 'EXISTS'
             ,p_pk1_alias        => 'i.pk1_value'
             ,p_pk2_alias        => 'i.pk2_value'
             ,p_pk3_alias        => NULL
             ,p_pk4_alias        => NULL
             ,p_pk5_alias        => NULL
             ,x_predicate        => l_sec_predicate
             ,x_return_status    => x_return_status );

          IF x_return_status IN ('T','F')  THEN

            IF l_sec_predicate IS NOT NULL THEN
              BEGIN
                l_dynamic_sql := ' select pk1_value, pk2_value, pk3_value, PK4_VALUE ' ||
                               ' from EGO_ODI_WS_ENTITIES i ' ||
                               ' where i.session_id = :1 ' ||
                               ' AND nvl(i.REF1_VALUE, ''Y'') = ''N'' ' ||
                               ' AND SEQUENCE_NUMBER IS NULL ' ||
                               ' AND ' || l_sec_predicate;

                OPEN v_dynamic_cursor FOR l_dynamic_sql
                USING  p_session_id;
                LOOP
                  FETCH  v_dynamic_cursor INTO l_item_id , l_org_id, l_rev_id, l_seq_number;
                  EXIT WHEN v_dynamic_cursor%NOTFOUND;

                    select CONCATENATED_SEGMENTS
                    into l_component_name
                    from mtl_system_items_b_kfv
                    WHERE inventory_item_id = l_item_id
                    AND ORGANIZATION_ID = l_org_id;

                    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                    p_odi_session_id => p_odi_session_id,
                                    p_input_id  => l_seq_number,
                                    p_err_code => 'EGO_NO_PUBLISH_PRIV_COMP',
                                    p_err_message => 'User does not have the publish privilege for Component - '|| l_component_name);
                END LOOP;
                  CLOSE v_dynamic_cursor;
                  x_return_status := 'S';
              EXCEPTION
              WHEN OTHERS THEN
                x_return_status := 'E';
                RAISE;
                IF (v_dynamic_cursor%ISOPEN) THEN
                  CLOSE v_dynamic_cursor;
                END IF;
              END; -- end of BEGIN

              l_dynamic_sql := ' select distinct PK4_VALUE ' ||
                               ' from EGO_ODI_WS_ENTITIES i ' ||
                               ' where i.session_id = :1 ' ||
                               ' AND nvl(i.REF1_VALUE, ''Y'') = ''N'' ' ||
                               ' AND SEQUENCE_NUMBER IS NULL ' ||
                               ' AND NOT ' || l_sec_predicate;

              OPEN v_dynamic_cursor FOR l_dynamic_sql
                USING  p_session_id;
                LOOP
                  FETCH  v_dynamic_cursor INTO l_seq_number;
                  EXIT WHEN v_dynamic_cursor%NOTFOUND;

                    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                    p_odi_session_id => p_odi_session_id,
                                    p_input_id  => l_seq_number,
                                    p_err_code => 'EGO_NO_PUBLISH_PRIV',
                                    p_err_message => 'User does not have the publilsh privilege on few components of the structure for the item');
                END LOOP;
                  CLOSE v_dynamic_cursor;
                  x_return_status := 'S';
            ELSE
                for i in (SELECT PK1_VALUE, PK2_VALUE, PK3_VALUE, PK4_VALUE
                          FROM EGO_ODI_WS_ENTITIES
                          WHERE SESSION_ID = P_SESSION_ID
                          AND NVL(REF1_VALUE, 'Y') = 'N'
                          AND SEQUENCE_NUMBER IS NULL)
                loop
                  select CONCATENATED_SEGMENTS
                  into l_component_name
                  from mtl_system_items_b_kfv
                  WHERE inventory_item_id = i.PK1_VALUE
                  AND ORGANIZATION_ID = i.PK2_VALUE;

                  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                  p_odi_session_id => p_odi_session_id,
                                  p_input_id  => l_seq_number,
                                  p_err_code => 'EGO_NO_PUBLISH_PRIV_COMP',
                                  p_err_message => 'User does not have the publish privilege for Component - '|| l_component_name);
                end loop;
              x_return_status := 'S';
            END IF;  -- end of l_sec_predicate IS NOT NULL
          END IF;

          UPDATE EGO_ODI_WS_ENTITIES ent1
          SET REF1_VALUE = 'N'
          WHERE Nvl(REF1_VALUE, 'Y') <> 'N'
          AND session_id = p_session_id
          AND PK4_VALUE IN (SELECT PK4_VALUE FROM EGO_ODI_WS_ENTITIES ent2
                            WHERE Nvl(REF1_VALUE, 'Y') = 'N'
                            AND SEQUENCE_NUMBER  IS NULL
                            AND ent1.session_id = ent2.session_id
                            );
        END IF;
      ELSE
       x_return_status := 'S';
      END IF;  -- end of l_sec_predicate IS NOT NULL
    END IF;

  END check_security;

/* Bug 8659248 : Added the Below procedure for getting the security details of the
  user who is publishing the Items */
PROCEDURE Init_Security_details(p_session_id IN NUMBER,
                                p_odi_session_id IN NUMBER,
                                p_return_status OUT NOCOPY VARCHAR2) -- Bug 8776414
IS

l_mode VARCHAR2(100);
l_application_id NUMBER;
l_responsibility_id NUMBER;
l_user_id NUMBER;
l_security_group_id NUMBER;
l_batch_id NUMBER;
l_fnd_user_name VARCHAR2(100);
l_responsibility_name VARCHAR2(100);
l_responsibility_appl_name VARCHAR2(100);
l_security_group_name VARCHAR2(100);

BEGIN

  --retrieving invocation mode
  select char_value
  into l_mode
  from EGO_PUB_WS_CONFIG
  where parameter_name = 'INVOCATION_MODE'
  and session_id  = p_session_id;

  --if mode is batch, get security related information from publication
  --framework using batch_id
  IF l_mode = 'BATCH' THEN

    --retrieving batchId from input XML
    select to_number(extractValue(xmlcontent, '/itemQueryParameters/BatchId'))
    into l_batch_id
    from EGO_PUB_WS_PARAMS
    where session_id =  p_session_id;

    --retrieving user_id and responsability
    select created_by, responsibility_id
    into l_user_id,l_responsibility_id
    from EGO_PUB_BAT_HDR_B
    where batch_id = l_batch_id;

    --retrieving responsability_id
    Select application_id
    into l_application_id
    from FND_RESPONSIBILITY
    where responsibility_id = l_responsibility_id;

    -- Bug 8776414 : Start
    --Initializing security context
    FND_GLOBAL.APPS_INITIALIZE(
        USER_ID=>l_user_id,
        RESP_ID=>l_responsibility_id,
        RESP_APPL_ID=>l_application_id
        );

    p_return_status := 'S';
    -- Bug 8776414: End

  ELSIF l_mode = 'LIST' OR  l_mode = 'HMDM' THEN

    select fnd_user_name, responsibility_name, responsibility_appl_name, security_group_name
    into l_fnd_user_name, l_responsibility_name, l_responsibility_appl_name, l_security_group_name
    from EGO_PUB_WS_PARAMS
    where session_id = p_session_id;

    INSERT INTO EGO_PUB_WS_CONFIG (session_id,
      odi_session_id,
      Parameter_Name,
      Data_Type,
      Char_value,
      creation_date,
      created_by)
    VALUES (p_session_id,
      p_odi_session_id,
      'FND_USER_NAME',
      2,
      l_fnd_user_name,
      sysdate,
      0);

    INSERT INTO EGO_PUB_WS_CONFIG (session_id,
      odi_session_id,
      Parameter_Name,
      Data_Type,
      Char_value,
      creation_date,
      created_by)
    VALUES (p_session_id,
      p_odi_session_id,
      'RESPONSIBILITY_NAME',
      2,
      l_responsibility_name,
      sysdate,
      0);

    INSERT INTO EGO_PUB_WS_CONFIG (session_id,
      odi_session_id,
      Parameter_Name,
      Data_Type,
      Char_value,
      creation_date,
      created_by)
    VALUES (p_session_id,
      p_odi_session_id,
      'RESPONSIBILITY_APP_NAME',
      2,
      l_responsibility_appl_name,
      sysdate,
      0);

    INSERT INTO EGO_PUB_WS_CONFIG (session_id,
      odi_session_id,
      Parameter_Name,
      Data_Type,
      Char_value,
      creation_date,
      created_by)
    VALUES (p_session_id,
      p_odi_session_id,
      'SECURITY_GROUP_NAME',
      2,
      l_security_group_name,
      sysdate,
      0);

    BEGIN

      --retrieving user id from user name
      select user_id
      into l_user_id
      from fnd_user
      where user_name = l_fnd_user_name;

      --retrieving responsibility id from responsability name
      Select responsibility_id
      into l_responsibility_id
      from FND_RESPONSIBILITY
      where responsibility_key = l_responsibility_name;

      --retrieving application id from application name
      select application_id
      into l_application_id
      from FND_APPLICATION
      where application_short_name = l_responsibility_appl_name;

      -- Bug 8776414 : Start
      --Initializing security context
      FND_GLOBAL.APPS_INITIALIZE(
          USER_ID=>l_user_id,
          RESP_ID=>l_responsibility_id,
          RESP_APPL_ID=>l_application_id
          );

      p_return_status := 'S';
      -- Bug 8776414: End
    exception
    when no_data_found then
      -- Bug 8776414 : Start
      DELETE EGO_PUB_WS_INPUT_IDENTIFIERS
      WHERE session_id =  p_session_id;

      DELETE EGO_PUB_WS_ERRORS
      WHERE session_id =  p_session_id;

      EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => 1,
                           p_param_name  => 'RESPONSIBILITY_NAME',
                           p_param_value => l_responsibility_name );

      EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => 1,
                           p_param_name  => 'RESPONSIBILITY_APPL_NAME',
                           p_param_value => l_responsibility_appl_name );

      EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                            p_odi_session_id => p_odi_session_id,
                            p_input_id  => 1,
                            p_err_code => 'EGO_INVALID_SECURITY_DETAILS',
                            p_err_message => 'Invalid Security Details');

      -- Do not publish any item, So delete all the records.
      DELETE ego_odi_ws_entities
      WHERE  session_id = p_session_id;

      p_return_status := 'E';
      -- Bug 8776414 : End
    end;
  END IF;

END Init_Security_Details;

PROCEDURE POPULATE_SEGMENTS(p_session_id    IN  NUMBER,
                        p_odi_session_id IN NUMBER,
                        p_segment1 in varchar2,
                        p_segment2 in varchar2,
                        p_segment3 in varchar2,
                        p_segment4 in varchar2,
                        p_segment5 in varchar2,
                        p_segment6 in varchar2,
                        p_segment7 in varchar2,
                        p_segment8 in varchar2,
                        p_segment9 in varchar2,
                        p_segment10 in varchar2,
                        p_segment11 in varchar2,
                        p_segment12 in varchar2,
                        p_segment13 in varchar2,
                        p_segment14 in varchar2,
                        p_segment15 in varchar2,
                        p_segment16 in varchar2,
                        p_segment17 in varchar2,
                        p_segment18 in varchar2,
                        p_segment19 in varchar2,
                        p_segment20 in varchar2,
                        p_index in number )
IS

BEGIN
  IF (p_segment1 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment1',
                           p_param_value => p_segment1 );
  END IF;

  IF (p_segment2 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment2',
                           p_param_value => p_segment2 );
  END IF;

  IF (p_segment3 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment3',
                           p_param_value => p_segment3 );
  END IF;

  IF (p_segment4 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment4',
                           p_param_value => p_segment4 );
  END IF;

  IF (p_segment5 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment5',
                           p_param_value => p_segment5 );
  END IF;

  IF (p_segment6 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment6',
                           p_param_value => p_segment6 );
  END IF;

  IF (p_segment7 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment7',
                           p_param_value => p_segment7 );
  END IF;

  IF (p_segment8 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment8',
                           p_param_value => p_segment8 );
  END IF;

  IF (p_segment9 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment9',
                           p_param_value => p_segment9 );
  END IF;

  IF (p_segment10 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment10',
                           p_param_value => p_segment10 );
  END IF;

  IF (p_segment11 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment11',
                           p_param_value => p_segment11 );
  END IF;

  IF (p_segment12 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment12',
                           p_param_value => p_segment12 );
  END IF;

  IF (p_segment13 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment13',
                           p_param_value => p_segment13 );
  END IF;

  IF (p_segment14 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment14',
                           p_param_value => p_segment14 );
  END IF;

  IF (p_segment15 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment15',
                           p_param_value => p_segment15 );

  END IF;

  IF (p_segment16 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment16',
                           p_param_value => p_segment16 );

  END IF;

  IF (p_segment17 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment17',
                           p_param_value => p_segment17 );

  END IF;

  IF (p_segment18 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment18',
                           p_param_value => p_segment18 );

  END IF;

  IF (p_segment19 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment19',
                           p_param_value => p_segment19 );

  END IF;

  IF (p_segment20 IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Segment20',
                           p_param_value => p_segment20 );

  END IF;
END POPULATE_SEGMENTS;


PROCEDURE POPULATE_REVISION_DETAILS(p_session_id    IN  NUMBER,
                        p_odi_session_id IN NUMBER,
                        p_rev_id NUMBER,
                        p_revision VARCHAR,
                        p_rev_date DATE,
                        p_index NUMBER)
IS
BEGIN

  IF (p_rev_id <> -1) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'RevisionId',
                           p_param_value => p_rev_id );
  END IF;

  IF (p_revision IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'Revision',
                           p_param_value => p_revision );
  END IF;

  IF (p_rev_date IS NOT NULL) THEN
    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                           p_odi_session_id => p_odi_session_id,
                           p_input_id  => p_index,
                           p_param_name  => 'RevisionDate',
                           p_param_value => p_rev_date );
  END IF;
END POPULATE_REVISION_DETAILS;

END EGO_ITEM_WS_PVT;

/
