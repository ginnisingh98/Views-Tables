--------------------------------------------------------
--  DDL for Package Body EGO_IMPORT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_IMPORT_UTIL_PVT" AS
/* $Header: EGOVIMUB.pls 120.54.12010000.34 2011/07/14 11:49:29 nendrapu ship $ */

  G_LOG_TIMESTAMP_FORMAT CONSTANT VARCHAR2( 30 ) := 'dd-mon-yyyy hh:mi:ss.ff';

  G_NLS_DATE_FORMAT VARCHAR2( 1000 ) := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')||' HH24:MI:SS';

  -- This variable has un-indented code to SAVE the space consumed of variable
  G_PROD_COL_LIST   VARCHAR2( 3000 ) := q'#
C_EXT_ATTR1,C_EXT_ATTR2,C_EXT_ATTR3,C_EXT_ATTR4,C_EXT_ATTR5,C_EXT_ATTR6,C_EXT_ATTR7,C_EXT_ATTR8,
C_EXT_ATTR9,C_EXT_ATTR10,C_EXT_ATTR11,C_EXT_ATTR12,C_EXT_ATTR13,C_EXT_ATTR14,C_EXT_ATTR15,
C_EXT_ATTR16,C_EXT_ATTR17,C_EXT_ATTR18,C_EXT_ATTR19,C_EXT_ATTR20,C_EXT_ATTR21,C_EXT_ATTR22,
C_EXT_ATTR23,C_EXT_ATTR24,C_EXT_ATTR25,C_EXT_ATTR26,C_EXT_ATTR27,C_EXT_ATTR28,C_EXT_ATTR29,
C_EXT_ATTR30,C_EXT_ATTR31,C_EXT_ATTR32,C_EXT_ATTR33,C_EXT_ATTR34,C_EXT_ATTR35,C_EXT_ATTR36,
C_EXT_ATTR37,C_EXT_ATTR38,C_EXT_ATTR39,C_EXT_ATTR40,N_EXT_ATTR1,UOM_EXT_ATTR1,N_EXT_ATTR2,
UOM_EXT_ATTR2,N_EXT_ATTR3,UOM_EXT_ATTR3,N_EXT_ATTR4,UOM_EXT_ATTR4,N_EXT_ATTR5,UOM_EXT_ATTR5,
N_EXT_ATTR6,UOM_EXT_ATTR6,N_EXT_ATTR7,UOM_EXT_ATTR7,N_EXT_ATTR8,UOM_EXT_ATTR8,N_EXT_ATTR9,
UOM_EXT_ATTR9,N_EXT_ATTR10,UOM_EXT_ATTR10,N_EXT_ATTR11,UOM_EXT_ATTR11,N_EXT_ATTR12,
UOM_EXT_ATTR12,N_EXT_ATTR13,UOM_EXT_ATTR13,N_EXT_ATTR14,UOM_EXT_ATTR14,N_EXT_ATTR15,
UOM_EXT_ATTR15,N_EXT_ATTR16,UOM_EXT_ATTR16,N_EXT_ATTR17,UOM_EXT_ATTR17,N_EXT_ATTR18,
UOM_EXT_ATTR18,N_EXT_ATTR19,UOM_EXT_ATTR19,N_EXT_ATTR20,UOM_EXT_ATTR20,D_EXT_ATTR1,
D_EXT_ATTR2,D_EXT_ATTR3,D_EXT_ATTR4,D_EXT_ATTR5,D_EXT_ATTR6,D_EXT_ATTR7,D_EXT_ATTR8,
D_EXT_ATTR9,D_EXT_ATTR10,TL_EXT_ATTR1,TL_EXT_ATTR2,TL_EXT_ATTR3,TL_EXT_ATTR4,TL_EXT_ATTR5,
TL_EXT_ATTR6,TL_EXT_ATTR7,TL_EXT_ATTR8,TL_EXT_ATTR9,TL_EXT_ATTR10,TL_EXT_ATTR11,
TL_EXT_ATTR12,TL_EXT_ATTR13,TL_EXT_ATTR14,TL_EXT_ATTR15,TL_EXT_ATTR16,TL_EXT_ATTR17,
TL_EXT_ATTR18,TL_EXT_ATTR19,TL_EXT_ATTR20,TL_EXT_ATTR21,TL_EXT_ATTR22,TL_EXT_ATTR23,
TL_EXT_ATTR24,TL_EXT_ATTR25,TL_EXT_ATTR26,TL_EXT_ATTR27,TL_EXT_ATTR28,TL_EXT_ATTR29,
TL_EXT_ATTR30,TL_EXT_ATTR31,TL_EXT_ATTR32,TL_EXT_ATTR33,TL_EXT_ATTR34,TL_EXT_ATTR35,
TL_EXT_ATTR36,TL_EXT_ATTR37,TL_EXT_ATTR38,TL_EXT_ATTR39,TL_EXT_ATTR40 #';

  TYPE ITEM_DETAIL_RECORD IS RECORD(
                                     TRANSACTION_ID           NUMBER,
                                     INVENTORY_ITEM_ID        NUMBER,
                                     ORGANIZATION_ID          NUMBER,
                                     ITEM_NUMBER              MTL_SYSTEM_ITEMS_INTERFACE.ITEM_NUMBER%TYPE,
                                     SOURCE_SYSTEM_REFERENCE  MTL_SYSTEM_ITEMS_INTERFACE.SOURCE_SYSTEM_REFERENCE%TYPE,
                                     SOURCE_SYSTEM_ID         NUMBER,
                                     DATA_LEVEL_ID            NUMBER,
                                     SUPPLIER_ID              NUMBER,
                                     SUPPLIER_SITE_ID         NUMBER,
                                     PROCESS_FLAG             NUMBER
                                   );

  TYPE ITEM_DETAIL_TBL IS TABLE OF ITEM_DETAIL_RECORD;

  /*
   * This method writes into concurrent program log
   */
  PROCEDURE Debug_Conc_Log( p_message IN VARCHAR2
                          , p_add_timestamp IN BOOLEAN DEFAULT TRUE )
  IS
     l_inv_debug_level  NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
     l_message          VARCHAR2(3800);
  BEGIN
    IF l_inv_debug_level IN(101, 102) THEN
      IF LENGTH(p_message) > 3800 THEN
        FOR i IN 1..( CEIL(LENGTH(p_message)/3800) ) LOOP
          l_message := SUBSTR(p_message, ( 3800*(i-1) + 1 ), 3800 );
          INVPUTLI.info(  ( CASE
                            WHEN p_add_timestamp THEN to_char( systimestamp, G_LOG_TIMESTAMP_FORMAT ) || ': '
                            ELSE ''
                            END  )
                       ||   l_message );
        END LOOP;
      ELSE
        INVPUTLI.info(  ( CASE
                          WHEN p_add_timestamp THEN to_char( systimestamp, G_LOG_TIMESTAMP_FORMAT ) || ': '
                          ELSE ''
                          END  )
                     ||   p_message );
      END IF;
    END IF;
  END Debug_Conc_Log;

  ---------------------------------
  -- PRIVATE METHODS STARTS HERE --
  ---------------------------------

  PROCEDURE Resolve_Data_Level_Id( p_batch_id NUMBER )
  IS
  BEGIN
    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
       SET uai.DATA_LEVEL_ID = (SELECT edlb.DATA_LEVEL_ID
                                FROM EGO_DATA_LEVEL_B edlb
                                WHERE edlb.DATA_LEVEL_NAME = uai.DATA_LEVEL_NAME
                                  AND edlb.APPLICATION_ID  = 431
                                  AND edlb.ATTR_GROUP_TYPE = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                               )
    WHERE uai.DATA_SET_ID     = p_batch_id
      AND uai.PROCESS_STATUS  = 1
      AND uai.DATA_LEVEL_NAME IS NOT NULL
      AND uai.DATA_LEVEL_ID   IS NULL;

    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
       SET uai.DATA_LEVEL_ID = (SELECT edlv.DATA_LEVEL_ID
                                FROM EGO_DATA_LEVEL_VL edlv
                                WHERE edlv.USER_DATA_LEVEL_NAME = uai.USER_DATA_LEVEL_NAME
                                  AND edlv.APPLICATION_ID       = 431
                                  AND edlv.ATTR_GROUP_TYPE      = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                               )
    WHERE uai.DATA_SET_ID          = p_batch_id
      AND uai.PROCESS_STATUS       = 1
      AND uai.USER_DATA_LEVEL_NAME IS NOT NULL
      AND uai.DATA_LEVEL_NAME      IS NULL
      AND uai.DATA_LEVEL_ID        IS NULL;

    -----------------------------------------------------------
    -- If all data level columns are null, then check if the --
    -- attribute group is associated at only one level, then --
    -- put that data level id here.                          --
    -----------------------------------------------------------
    UPDATE EGO_ITM_USR_ATTR_INTRFC uai
       SET DATA_LEVEL_ID = (SELECT DATA_LEVEL_ID
                            FROM EGO_ATTR_GROUP_DL eagd, EGO_FND_DSC_FLX_CTX_EXT ag_ext
                            WHERE eagd.ATTR_GROUP_ID                   = ag_ext.ATTR_GROUP_ID
                              AND ag_ext.APPLICATION_ID                = 431
                              AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                              AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = uai.ATTR_GROUP_INT_NAME
                           )
    WHERE uai.DATA_SET_ID          = p_batch_id
      AND uai.PROCESS_STATUS       = 1
      AND uai.DATA_LEVEL_ID        IS NULL
      AND uai.DATA_LEVEL_NAME      IS NULL
      AND uai.USER_DATA_LEVEL_NAME IS NULL
      AND (SELECT COUNT(*)
           FROM EGO_ATTR_GROUP_DL eagd, EGO_FND_DSC_FLX_CTX_EXT ag_ext
           WHERE eagd.ATTR_GROUP_ID                   = ag_ext.ATTR_GROUP_ID
             AND ag_ext.APPLICATION_ID                = 431
             AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(uai.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
             AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = uai.ATTR_GROUP_INT_NAME
          ) = 1;
  END Resolve_Data_Level_Id;

  /*
   * This API is called to resolve inventory_item_id for all
   * the chid entities such as revision, UDA and intersections
   */
  PROCEDURE Resolve_PKs_For_Child( p_batch_id NUMBER )
  IS
    l_return_status VARCHAR2(10);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
  BEGIN
    Debug_Conc_Log('Resolve_PKs_For_Child: Starting ');
    UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
    SET INVENTORY_ITEM_ID = NVL((SELECT INVENTORY_ITEM_ID
                                 FROM MTL_SYSTEM_ITEMS_KFV MSIK
                                 WHERE MSIK.CONCATENATED_SEGMENTS = MIRI.ITEM_NUMBER
                                   AND MSIK.ORGANIZATION_ID = MIRI.ORGANIZATION_ID
                                ),
                                (SELECT INVENTORY_ITEM_ID
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE (MSII.ITEM_NUMBER = MIRI.ITEM_NUMBER OR MSII.SOURCE_SYSTEM_REFERENCE = MIRI.SOURCE_SYSTEM_REFERENCE)
                                   AND MSII.SOURCE_SYSTEM_ID = MIRI.SOURCE_SYSTEM_ID
                                   AND MSII.ORGANIZATION_ID = MIRI.ORGANIZATION_ID
                                   AND MSII.SET_PROCESS_ID = MIRI.SET_PROCESS_ID
                                   AND MSII.PROCESS_FLAG = 1
                                   AND ROWNUM = 1
                                ))
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG = 1
      AND INVENTORY_ITEM_ID IS NULL
      AND (ITEM_NUMBER IS NOT NULL OR SOURCE_SYSTEM_REFERENCE IS NOT NULL);

    Debug_Conc_Log('Resolve_PKs_For_Child: Updated Revisions '||SQL%ROWCOUNT);

    UPDATE MTL_ITEM_CATEGORIES_INTERFACE MICI
    SET INVENTORY_ITEM_ID = NVL((SELECT INVENTORY_ITEM_ID
                                 FROM MTL_SYSTEM_ITEMS_KFV MSIK
                                 WHERE MSIK.CONCATENATED_SEGMENTS = MICI.ITEM_NUMBER
                                   AND MSIK.ORGANIZATION_ID = MICI.ORGANIZATION_ID
                                ),
                                (SELECT INVENTORY_ITEM_ID
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE (MSII.ITEM_NUMBER = MICI.ITEM_NUMBER OR MSII.SOURCE_SYSTEM_REFERENCE = MICI.SOURCE_SYSTEM_REFERENCE)
                                   AND MSII.SOURCE_SYSTEM_ID = MICI.SOURCE_SYSTEM_ID
                                   AND MSII.ORGANIZATION_ID = MICI.ORGANIZATION_ID
                                   AND MSII.SET_PROCESS_ID = MICI.SET_PROCESS_ID
                                   AND MSII.PROCESS_FLAG = 1
                                   AND ROWNUM = 1
                                ))
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG = 1
      AND INVENTORY_ITEM_ID IS NULL
      AND (ITEM_NUMBER IS NOT NULL OR SOURCE_SYSTEM_REFERENCE IS NOT NULL);

    Debug_Conc_Log('Resolve_PKs_For_Child: Updated Categories '||SQL%ROWCOUNT);

    UPDATE EGO_ITM_USR_ATTR_INTRFC UAI
       SET ATTR_GROUP_ID = (SELECT ATTR_GROUP_ID
                              FROM EGO_FND_DSC_FLX_CTX_EXT FLX_EXT
                             WHERE APPLICATION_ID = 431
                               AND DESCRIPTIVE_FLEXFIELD_NAME = UAI.ATTR_GROUP_TYPE
                               AND DESCRIPTIVE_FLEX_CONTEXT_CODE = UAI.ATTR_GROUP_INT_NAME)
    WHERE UAI.DATA_SET_ID = p_batch_id
      AND UAI.PROCESS_STATUS = 1
      AND UAI.ATTR_GROUP_ID IS NULL;
    Debug_Conc_Log('Resolve_PKs_For_Child: Updated Attribute Group ID '||SQL%ROWCOUNT);

    UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
    SET INVENTORY_ITEM_ID = NVL((SELECT INVENTORY_ITEM_ID
                                 FROM MTL_SYSTEM_ITEMS_KFV MSIK
                                 WHERE MSIK.CONCATENATED_SEGMENTS = EIUAI.ITEM_NUMBER
                                   AND MSIK.ORGANIZATION_ID = EIUAI.ORGANIZATION_ID
                                ),
    --Bug 9660659 - Removing the OR in this query, making two queries - Bug 9660659
    /*
                                (SELECT INVENTORY_ITEM_ID
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE (MSII.ITEM_NUMBER = EIUAI.ITEM_NUMBER OR MSII.SOURCE_SYSTEM_REFERENCE = EIUAI.SOURCE_SYSTEM_REFERENCE)
                                   AND MSII.SOURCE_SYSTEM_ID = EIUAI.SOURCE_SYSTEM_ID
                                   AND MSII.ORGANIZATION_ID = EIUAI.ORGANIZATION_ID
                                   AND MSII.SET_PROCESS_ID = EIUAI.DATA_SET_ID
                                   AND MSII.PROCESS_FLAG = 1
                                   AND ROWNUM = 1
                                ))
    */
                                NVL( (SELECT INVENTORY_ITEM_ID
                                        FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                       WHERE (MSII.ITEM_NUMBER = EIUAI.ITEM_NUMBER)
                                         AND MSII.SOURCE_SYSTEM_ID = EIUAI.SOURCE_SYSTEM_ID
                                         AND MSII.ORGANIZATION_ID = EIUAI.ORGANIZATION_ID
                                         AND MSII.SET_PROCESS_ID = EIUAI.DATA_SET_ID
                                         AND MSII.PROCESS_FLAG = 1
                                         AND ROWNUM = 1) ,
                                    (SELECT INVENTORY_ITEM_ID
                                       FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                      WHERE (MSII.SOURCE_SYSTEM_REFERENCE = EIUAI.SOURCE_SYSTEM_REFERENCE)
                                        AND MSII.SOURCE_SYSTEM_ID = EIUAI.SOURCE_SYSTEM_ID
                                        AND MSII.ORGANIZATION_ID = EIUAI.ORGANIZATION_ID
                                        AND MSII.SET_PROCESS_ID = EIUAI.DATA_SET_ID
                                        AND MSII.PROCESS_FLAG = 1
                                        AND ROWNUM = 1)
                                   )  -- End of inner NVL
                               )  --End of outer NVL
    WHERE DATA_SET_ID = p_batch_id
      AND PROCESS_STATUS = 1
      AND INVENTORY_ITEM_ID IS NULL
      AND (ITEM_NUMBER IS NOT NULL OR SOURCE_SYSTEM_REFERENCE IS NOT NULL);

    Debug_Conc_Log('Resolve_PKs_For_Child: Updated User Attrs '||SQL%ROWCOUNT);

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
    SET INVENTORY_ITEM_ID = NVL((SELECT INVENTORY_ITEM_ID
                                 FROM MTL_SYSTEM_ITEMS_KFV MSIK
                                 WHERE MSIK.CONCATENATED_SEGMENTS = EIAI.ITEM_NUMBER
                                   AND MSIK.ORGANIZATION_ID = EIAI.ORGANIZATION_ID
                                ),
                                (SELECT INVENTORY_ITEM_ID
                                 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                                 WHERE (MSII.ITEM_NUMBER = EIAI.ITEM_NUMBER OR MSII.SOURCE_SYSTEM_REFERENCE = EIAI.SOURCE_SYSTEM_REFERENCE)
                                   AND MSII.SOURCE_SYSTEM_ID = EIAI.SOURCE_SYSTEM_ID
                                   AND MSII.ORGANIZATION_ID = EIAI.ORGANIZATION_ID
                                   AND MSII.SET_PROCESS_ID = EIAI.BATCH_ID
                                   AND MSII.PROCESS_FLAG = 1
                                   AND ROWNUM = 1
                                ))
    WHERE BATCH_ID = p_batch_id
      AND PROCESS_FLAG = 1
      AND INVENTORY_ITEM_ID IS NULL
      AND (ITEM_NUMBER IS NOT NULL OR SOURCE_SYSTEM_REFERENCE IS NOT NULL);
    Debug_Conc_Log('Resolve_PKs_For_Child: Updated Intersections '||SQL%ROWCOUNT);

    UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
    SET REVISION_ID = NVL((SELECT REVISION_ID
                           FROM MTL_ITEM_REVISIONS_B MIRB
                           WHERE MIRB.INVENTORY_ITEM_ID = EIUAI.INVENTORY_ITEM_ID
                             AND MIRB.ORGANIZATION_ID   = EIUAI.ORGANIZATION_ID
                             AND MIRB.REVISION          = EIUAI.REVISION
                           ),
                          (SELECT REVISION_ID
                           FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
                           WHERE MIRI.INVENTORY_ITEM_ID = EIUAI.INVENTORY_ITEM_ID
                             AND MIRI.ORGANIZATION_ID   = EIUAI.ORGANIZATION_ID
                             AND MIRI.REVISION          = EIUAI.REVISION
                             AND MIRI.SET_PROCESS_ID    = EIUAI.DATA_SET_ID
                             AND MIRI.PROCESS_FLAG      = 1
                             AND ROWNUM                 = 1
                          ))
    WHERE DATA_SET_ID = p_batch_id
      AND PROCESS_STATUS = 1
      AND REVISION_ID IS NULL
      AND REVISION IS NOT NULL
      AND INVENTORY_ITEM_ID IS NOT NULL;

    Debug_Conc_Log('Resolve_PKs_For_Child: Updated Revision_id for User Attrs '||SQL%ROWCOUNT);

    COMMIT;
  END Resolve_PKs_For_Child;

  /* Private API to call tempalte application for UDAs*/
  PROCEDURE Call_UDA_Apply_Template
                        ( p_batch_id         NUMBER,
                          p_entity_sql       VARCHAR2,
                          p_gdsn_entity_sql  VARCHAR2,
                          p_user_id          NUMBER,
                          p_login_id         NUMBER,
                          p_prog_appid       NUMBER,
                          p_prog_id          NUMBER,
                          p_request_id       NUMBER,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_err_msg          OUT NOCOPY VARCHAR2
                        )
  IS
    l_return_status          VARCHAR2(1);
    l_errorcode              NUMBER;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    G_FND_RET_STS_WARNING    VARCHAR2(1) := 'W';
    l_class_code_hierarchy_sql VARCHAR2(500);
    l_template_table_sql         VARCHAR2(4000);

  BEGIN

    Debug_Conc_Log('Call_UDA_Apply_Template: Starting ');

    l_template_table_sql :=' SELECT *                                                                                                                                                  '||
                       '   FROM (                                                                                                                                                      '||
                       '                SELECT  MIN(CATALOG_LEVEL) OVER (PARTITION BY  ROOT_CLASS, ATTRIBUTE_ID) MIN_LEVEL                                                             '||
                       '                        ,ROOT_CLASS CLASSIFICATION_CODE                                                                                                        '||
                       '                        ,CATALOG_LEVEL                                                                                                                         '||
                       '                        ,TEMPLATE_ID,ATTRIBUTE_GROUP_ID,ATTRIBUTE_ID,ENABLED_FLAG,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN  '||
                       '                        ,ROW_NUMBER,ATTRIBUTE_STRING_VALUE,ATTRIBUTE_NUMBER_VALUE,ATTRIBUTE_DATE_VALUE,ATTRIBUTE_TRANSLATED_VALUE,ATTRIBUTE_UOM_CODE           '||
                       '                        ,REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,DATA_LEVEL_ID                                                        '||
                       '                 FROM EGO_TEMPL_ATTRIBUTES TEMPL,                                                                                                              '||
                       '                      (SELECT CONNECT_BY_ROOT ITEM_CATALOG_GROUP_ID ROOT_CLASS, ITEM_CATALOG_GROUP_ID, PARENT_CATALOG_GROUP_ID, LEVEL CATALOG_LEVEL            '||
                       '                         FROM  MTL_ITEM_CATALOG_GROUPS_B                                                                                                       '||
                       '                   CONNECT BY PRIOR   PARENT_CATALOG_GROUP_ID= ITEM_CATALOG_GROUP_ID                                                                           '||
                       '                   START WITH ITEM_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID                                                                                    '||
                       '                      ) CATALOG                                                                                                                                '||
                       '                WHERE TEMPL.CLASSIFICATION_CODE= CATALOG.ITEM_CATALOG_GROUP_ID                                                                                 '||
                       '                  AND ENABLED_FLAG = ''Y''                                                                                                                     '||
                       '        )                                                                                                                                                      '||
                       ' WHERE  MIN_LEVEL = CATALOG_LEVEL                                                                                                                        ';


    l_class_code_hierarchy_sql := ' SELECT item_catalog_group_id FROM MTL_ITEM_CATALOG_GROUPS_B TEMPL CONNECT BY PRIOR TEMPL.PARENT_CATALOG_GROUP_ID = TEMPL.ITEM_CATALOG_GROUP_ID START WITH TEMPL.ITEM_CATALOG_GROUP_ID = ENTITIES.ITEM_CATALOG_GROUP_ID ';
    Debug_Conc_Log('Call_UDA_Apply_Template: Calling EGO_USER_ATTRS_BULK_PVT.Apply_Template_On_Intf_Table for EGO_ITEMMGMT_GROUP');
    EGO_USER_ATTRS_BULK_PVT.Apply_Template_On_Intf_Table(
        p_api_version                   => 1.0
       ,p_application_id                => 431
       ,p_object_name                   => 'EGO_ITEM'
       ,p_interface_table_name          => 'EGO_ITM_USR_ATTR_INTRFC'
       ,p_data_set_id                   => p_batch_id
       ,p_attr_group_type               => 'EGO_ITEMMGMT_GROUP'
       ,p_request_id                    => p_request_id
       ,p_program_application_id        => p_prog_appid
       ,p_program_id                    => p_prog_id
       ,p_program_update_date           => SYSDATE
       ,p_current_user_party_id         => p_user_id
       ,p_target_entity_sql             => p_entity_sql
       ,p_process_status                => '2'  -- Bug 10263673
       ,p_class_code_hierarchy_sql      => l_class_code_hierarchy_sql
       ,p_hierarchy_template_tbl_sql    => l_template_table_sql
       ,x_return_status                 => l_return_status
       ,x_errorcode                     => l_errorcode
       ,x_msg_count                     => l_msg_count
       ,x_msg_data                      => l_msg_data
    );

    Debug_Conc_Log('Call_UDA_Apply_Template: Done Calling for EGO_ITEMMGMT_GROUP with l_return_status, l_errorcode, l_msg_data='||l_return_status||','|| l_errorcode||','|| l_msg_data);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := '2';
      x_err_msg       := l_msg_data;
      RETURN;
    ELSIF l_return_status = G_FND_RET_STS_WARNING THEN
      x_return_status := '1';
      x_err_msg       := l_msg_data;
    ELSE
      x_return_status := '0';
      x_err_msg       := NULL;
    END IF;

    Debug_Conc_Log('Call_UDA_Apply_Template: Calling EGO_USER_ATTRS_BULK_PVT.Apply_Template_On_Intf_Table for EGO_ITEM_GTIN_ATTRS');
    EGO_USER_ATTRS_BULK_PVT.Apply_Template_On_Intf_Table(
        p_api_version                   => 1.0
       ,p_application_id                => 431
       ,p_object_name                   => 'EGO_ITEM'
       ,p_interface_table_name          => 'EGO_ITM_USR_ATTR_INTRFC'
       ,p_data_set_id                   => p_batch_id
       ,p_attr_group_type               => 'EGO_ITEM_GTIN_ATTRS'
       ,p_request_id                    => p_request_id
       ,p_program_application_id        => p_prog_appid
       ,p_program_id                    => p_prog_id
       ,p_program_update_date           => SYSDATE
       ,p_current_user_party_id         => p_user_id
       ,p_target_entity_sql             => p_gdsn_entity_sql
       ,p_process_status                => '2'  -- Bug 10263673
       ,p_class_code_hierarchy_sql      => l_class_code_hierarchy_sql
       ,p_hierarchy_template_tbl_sql    => l_template_table_sql
       ,x_return_status                 => l_return_status
       ,x_errorcode                     => l_errorcode
       ,x_msg_count                     => l_msg_count
       ,x_msg_data                      => l_msg_data
    );

    Debug_Conc_Log('Call_UDA_Apply_Template: Done Calling for EGO_ITEM_GTIN_ATTRS with l_return_status, l_errorcode, l_msg_data='||l_return_status||','|| l_errorcode||','|| l_msg_data);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := '2';
      x_err_msg       := l_msg_data;
      RETURN;
    ELSIF l_return_status = G_FND_RET_STS_WARNING THEN
      x_return_status := '1';
      x_err_msg       := l_msg_data;
    ELSE
      x_return_status := '0';
      x_err_msg       := NULL;
    END IF;

    Debug_Conc_Log('Call_UDA_Apply_Template: Calling EGO_USER_ATTRS_BULK_PVT.Apply_Template_On_Intf_Table for EGO_ITEM_GTIN_MULTI_ATTRS');
    EGO_USER_ATTRS_BULK_PVT.Apply_Template_On_Intf_Table(
        p_api_version                   => 1.0
       ,p_application_id                => 431
       ,p_object_name                   => 'EGO_ITEM'
       ,p_interface_table_name          => 'EGO_ITM_USR_ATTR_INTRFC'
       ,p_data_set_id                   => p_batch_id
       ,p_attr_group_type               => 'EGO_ITEM_GTIN_MULTI_ATTRS'
       ,p_request_id                    => p_request_id
       ,p_program_application_id        => p_prog_appid
       ,p_program_id                    => p_prog_id
       ,p_program_update_date           => SYSDATE
       ,p_current_user_party_id         => p_user_id
       ,p_target_entity_sql             => p_gdsn_entity_sql
       ,p_process_status                => '2'  -- Bug 10263673
       ,p_class_code_hierarchy_sql      => l_class_code_hierarchy_sql
       ,p_hierarchy_template_tbl_sql    => l_template_table_sql
       ,x_return_status                 => l_return_status
       ,x_errorcode                     => l_errorcode
       ,x_msg_count                     => l_msg_count
       ,x_msg_data                      => l_msg_data
    );

    Debug_Conc_Log('Call_UDA_Apply_Template: Done Calling for EGO_ITEM_GTIN_MULTI_ATTRS with l_return_status, l_errorcode, l_msg_data='||l_return_status||','|| l_errorcode||','|| l_msg_data);
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := '2';
      x_err_msg       := l_msg_data;
      RETURN;
    ELSIF l_return_status = G_FND_RET_STS_WARNING THEN
      x_return_status := '1';
      x_err_msg       := l_msg_data;
    ELSE
      x_return_status := '0';
      x_err_msg       := NULL;
    END IF;

    IF NVL(x_return_status, '0') = '0' THEN
      x_return_status := '0';
      x_err_msg := NULL;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := '2';
    x_err_msg       := SQLERRM;
    Debug_Conc_Log('Call_UDA_Apply_Template: Error l_return_status, l_msg_data='||x_return_status||','|| ',' || x_err_msg);
  END Call_UDA_Apply_Template;

  /* Private API to call tempalte application for UDAs*/
  PROCEDURE Apply_Templates_For_UDAs
                        ( p_batch_id       NUMBER,
                          p_user_id        NUMBER,
                          p_login_id       NUMBER,
                          p_prog_appid     NUMBER,
                          p_prog_id        NUMBER,
                          p_request_id     NUMBER,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_err_msg        OUT NOCOPY VARCHAR2
                        )
  IS
    l_err_msg                  VARCHAR2(4000);
    l_return_status            VARCHAR2(10);
    l_template_table           INVPULI2.Import_Template_Tbl_Type;
    l_apply_multiple_template  BOOLEAN;
    l_entity_sql               VARCHAR2(32000);
    l_sql_part1                VARCHAR2(1000);
    l_sql_part2                VARCHAR2(32000);
    l_sql_part3                VARCHAR2(32000);
    l_sql_part4                VARCHAR2(32000); /* Bug 9201112 */
    l_gdsn_sql_part1           VARCHAR2(32000);
    l_gdsn_sql_part2           VARCHAR2(32000);
    l_gdsn_entity_sql          VARCHAR2(32000);

    l_item_dl_id               NUMBER;
    l_item_rev_dl_id           NUMBER;
    l_item_org_dl_id           NUMBER; /* Bug 9201112 */
    l_item_gtin_dl_id          NUMBER;
    l_item_gtin_multi_dl_id    NUMBER;

    /* Bug 9201112. Fetching data for ITEM_ORG Data Level also. */
    CURSOR c_data_levels IS
      SELECT ATTR_GROUP_TYPE, DATA_LEVEL_ID, DATA_LEVEL_NAME
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE IN ('EGO_ITEMMGMT_GROUP', 'EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME IN ( 'ITEM_LEVEL', 'ITEM_REVISION_LEVEL', 'ITEM_ORG' );

  BEGIN
    Debug_Conc_Log('Apply_Templates_For_UDAs: Starting ');
    x_return_status := '0';
    x_err_msg := NULL;

    /* Bug 9201112. Store the DATA_LEVEL_ID for ITEM_ORG Data Level in l_item_org_dl_id. */
    FOR i IN c_data_levels LOOP
      IF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_ORG' THEN
        l_item_org_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL' THEN
        l_item_rev_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_gtin_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_gtin_multi_dl_id := i.DATA_LEVEL_ID;
      END IF;
    END LOOP;

    SELECT TEMPLATE_ID
    BULK COLLECT INTO l_template_table
    FROM EGO_IMPORT_COPY_OPTIONS
    WHERE BATCH_ID = p_batch_id
      AND COPY_OPTION = 'APPLY_TEMPLATE'
    ORDER BY TEMPLATE_SEQUENCE DESC;

    IF l_template_table IS NULL OR l_template_table.COUNT = 0 THEN
      l_apply_multiple_template := FALSE;
    ELSE
      l_apply_multiple_template := TRUE;
    END IF;

    IF l_apply_multiple_template THEN
      Debug_Conc_Log('Apply_Templates_For_UDAs: APPLY_TEMPLATE option found in Copy options, so applying multiple templates');
      l_sql_part2 := q'#
                         MSII.INVENTORY_ITEM_ID ,
                         MSII.ORGANIZATION_ID,
                         MSII.ITEM_CATALOG_GROUP_ID,
                         NULL AS PK1_VALUE,
                         NULL AS PK2_VALUE,
                         NULL AS PK3_VALUE,
                         NULL AS PK4_VALUE,
                         NULL AS PK5_VALUE,
                         NULL AS REVISION_ID, #' ||
                         l_item_dl_id || q'# AS DATA_LEVEL_ID
                       FROM
                         MTL_SYSTEM_ITEMS_INTERFACE MSII
                       WHERE ITEM_CATALOG_GROUP_ID IS NOT NULL
                         AND SET_PROCESS_ID    = #' || p_batch_id || q'#
                         AND PROCESS_FLAG      = 1
                       UNION ALL #';

      /* Bug 9201112. Query that considers ITEM_ORG Data Level. */
      l_sql_part4 := q'#
                         MSII.INVENTORY_ITEM_ID ,
                         MSII.ORGANIZATION_ID,
                         MSII.ITEM_CATALOG_GROUP_ID,
                         NULL AS PK1_VALUE,
                         NULL AS PK2_VALUE,
                         NULL AS PK3_VALUE,
                         NULL AS PK4_VALUE,
                         NULL AS PK5_VALUE,
                         NULL AS REVISION_ID, #' ||
                         l_item_org_dl_id || q'# AS DATA_LEVEL_ID
                       FROM
                         MTL_SYSTEM_ITEMS_INTERFACE MSII
                       WHERE ITEM_CATALOG_GROUP_ID IS NOT NULL
                         AND SET_PROCESS_ID    = #' || p_batch_id || q'#
                         AND PROCESS_FLAG      = 1
                       UNION ALL #';

      l_sql_part3 := q'#
                         MSII.INVENTORY_ITEM_ID ,
                         MSII.ORGANIZATION_ID,
                         MSII.ITEM_CATALOG_GROUP_ID,
                         NULL AS PK1_VALUE,
                         NULL AS PK2_VALUE,
                         NULL AS PK3_VALUE,
                         NULL AS PK4_VALUE,
                         NULL AS PK5_VALUE,
                         MIRI.REVISION_ID, #' ||
                         l_item_rev_dl_id || q'# AS DATA_LEVEL_ID
                       FROM
                         MTL_SYSTEM_ITEMS_INTERFACE MSII,
                         MTL_ITEM_REVISIONS_INTERFACE MIRI
                       WHERE MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
                         AND MSII.SET_PROCESS_ID    = #' || p_batch_id || q'#
                         AND MSII.PROCESS_FLAG      = 1
                         AND MSII.SET_PROCESS_ID    = MIRI.SET_PROCESS_ID
                         AND MIRI.PROCESS_FLAG      = 1
                         AND MIRI.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                         AND MIRI.ORGANIZATION_ID   = MSII.ORGANIZATION_ID #';

      l_gdsn_sql_part1 := q'#
                             MSII.INVENTORY_ITEM_ID ,
                             MSII.ORGANIZATION_ID,
                             MSII.ITEM_CATALOG_GROUP_ID,
                             NULL AS PK1_VALUE,
                             NULL AS PK2_VALUE,
                             NULL AS PK3_VALUE,
                             NULL AS PK4_VALUE,
                             NULL AS PK5_VALUE,
                             NULL AS REVISION_ID, #' ||
                             l_item_gtin_dl_id || q'# AS DATA_LEVEL_ID
                           FROM
                             MTL_SYSTEM_ITEMS_INTERFACE MSII
                           WHERE MSII.ITEM_CATALOG_GROUP_ID                IS NOT NULL
                             AND MSII.SET_PROCESS_ID                       = #' || p_batch_id || q'#
                             AND MSII.PROCESS_FLAG                         = 1
                             AND NVL(MSII.GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y'
                           UNION ALL #';

      l_gdsn_sql_part2 := q'#
                             MSII.INVENTORY_ITEM_ID ,
                             MSII.ORGANIZATION_ID,
                             MSII.ITEM_CATALOG_GROUP_ID,
                             NULL AS PK1_VALUE,
                             NULL AS PK2_VALUE,
                             NULL AS PK3_VALUE,
                             NULL AS PK4_VALUE,
                             NULL AS PK5_VALUE,
                             NULL AS REVISION_ID, #' ||
                             l_item_gtin_multi_dl_id || q'# AS DATA_LEVEL_ID
                           FROM
                             MTL_SYSTEM_ITEMS_INTERFACE MSII
                           WHERE MSII.ITEM_CATALOG_GROUP_ID                IS NOT NULL
                             AND MSII.SET_PROCESS_ID                       = #' || p_batch_id || q'#
                             AND MSII.PROCESS_FLAG                         = 1
                             AND NVL(MSII.GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y' #';

      Debug_Conc_Log('Apply_Templates_For_UDAs: Before Loop');
      IF l_template_table IS NOT NULL THEN
        FOR i IN l_template_table.FIRST..l_template_table.LAST LOOP
          l_sql_part1 := 'SELECT ' || l_template_table(i) || ' AS TEMPLATE_ID, ';
          /* 9201112. Adding l_sql_part4 to l_entity_sql. */
    l_entity_sql := l_sql_part1 || l_sql_part2 || l_sql_part1 || l_sql_part4 || l_sql_part1 || l_sql_part3;
          l_gdsn_entity_sql := l_sql_part1 || l_gdsn_sql_part1 || l_sql_part1 || l_gdsn_sql_part2;
          --Debug_Conc_Log('Apply_Templates_For_UDAs: l_entity_sql='||l_entity_sql);
          --Debug_Conc_Log('Apply_Templates_For_UDAs: l_gdsn_entity_sql='||l_gdsn_entity_sql);
          Debug_Conc_Log('Apply_Templates_For_UDAs: Applying template-'||l_template_table(i));

          Call_UDA_Apply_Template
                        ( p_batch_id        => p_batch_id,
                          p_entity_sql      => l_entity_sql,
                          p_gdsn_entity_sql => l_gdsn_entity_sql,
                          p_user_id         => p_user_id,
                          p_login_id        => p_login_id,
                          p_prog_appid      => p_prog_appid,
                          p_prog_id         => p_prog_id,
                          p_request_id      => p_request_id,
                          x_return_status   => l_return_status,
                          x_err_msg         => l_err_msg
                        );

          Debug_Conc_Log('Apply_Templates_For_UDAs: Done Call_UDA_Apply_Template l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
          IF NVL(l_return_status, '0') > x_return_status THEN
            x_return_status := l_return_status;
            x_err_msg := l_err_msg;
          END IF;
          IF x_return_status = '2' THEN
            RETURN;
          END IF;

        END LOOP; -- FOR i IN l_template_table.FIRST
      END IF; -- IF l_template_table IS NOT NULL THEN
    ELSE -- IF l_apply_multiple_template
      -- applying templates present in the MSII table
      -- template_id/name is taken from the template_id/name
      -- column of MSII table
      Debug_Conc_Log('Apply_Templates_For_UDAs: APPLY_TEMPLATE option NOT found in Copy options, so applying templates present in MSII/MIRI');

      /* Bug 9201112. Update the query l_entity_sql to considers ITEM_ORG Data Level also. */
      /* Bug 9678667 - Added the hint */
      l_entity_sql := q'#
                      SELECT
                        MIRI.TEMPLATE_ID,
                        MSIB.INVENTORY_ITEM_ID ,
                        MSIB.ORGANIZATION_ID,
                        MSIB.ITEM_CATALOG_GROUP_ID,
                        NULL AS PK1_VALUE,
                        NULL AS PK2_VALUE,
                        NULL AS PK3_VALUE,
                        NULL AS PK4_VALUE,
                        NULL AS PK5_VALUE,
                        MIRI.REVISION_ID, #' ||
                        l_item_rev_dl_id || q'# AS DATA_LEVEL_ID
                      FROM
                        MTL_ITEM_REVISIONS_INTERFACE MIRI,
                        MTL_SYSTEM_ITEMS_B           MSIB
                      WHERE MSIB.ITEM_CATALOG_GROUP_ID IS NOT NULL
                        AND MIRI.TEMPLATE_ID           IS NOT NULL
                        AND MIRI.INVENTORY_ITEM_ID     = MSIB.INVENTORY_ITEM_ID
                        AND MIRI.ORGANIZATION_ID       = MSIB.ORGANIZATION_ID
                        AND MIRI.SET_PROCESS_ID        = #' || p_batch_id || q'#
                        AND MIRI.PROCESS_FLAG          = 1
                        AND NOT EXISTS
                             (SELECT NULL
                              FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                              WHERE MSII.INVENTORY_ITEM_ID = MIRI.INVENTORY_ITEM_ID
                                AND MSII.ORGANIZATION_ID   = MIRI.ORGANIZATION_ID
                                AND MSII.SET_PROCESS_ID    = MIRI.SET_PROCESS_ID
                                AND MSII.PROCESS_FLAG      = MIRI.PROCESS_FLAG)
                      UNION ALL
                      SELECT  /*+ LEADING(MSII) USE_NL_WITH_INDEX(MIRI, MTL_ITEM_REVS_INTERFACE_N2 ) */
                        MSII.TEMPLATE_ID,
                        MSII.INVENTORY_ITEM_ID ,
                        MSII.ORGANIZATION_ID,
                        MSII.ITEM_CATALOG_GROUP_ID,
                        NULL AS PK1_VALUE,
                        NULL AS PK2_VALUE,
                        NULL AS PK3_VALUE,
                        NULL AS PK4_VALUE,
                        NULL AS PK5_VALUE,
                        (CASE WHEN MIRI.REVISION_Id IS NULL
                              THEN (SELECT Max(REVISION_ID)
                                    FROM MTL_ITEM_REVISIONS_B MIRB
                                    WHERE MIRB.EFFECTIVITY_DATE <= SYSDATE
                                      AND MIRB.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID
                                      AND MIRB.ORGANIZATION_ID   = MSII.ORGANIZATION_ID
                                   )
                              ELSE MIRI.REVISION_ID
                        END) REVISION_ID, #' ||
                        l_item_rev_dl_id || q'# AS DATA_LEVEL_ID
                      FROM
                        MTL_SYSTEM_ITEMS_INTERFACE   MSII,
                        MTL_ITEM_REVISIONS_INTERFACE MIRI
                      WHERE MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
                        AND MSII.TEMPLATE_ID           IS NOT NULL
                        AND MIRI.INVENTORY_ITEM_ID(+)  = MSII.INVENTORY_ITEM_ID
                        AND MIRI.ORGANIZATION_ID(+)    = MSII.ORGANIZATION_ID
                        AND MIRI.SET_PROCESS_ID(+)     = MSII.SET_PROCESS_ID
                        AND MIRI.PROCESS_FLAG(+)       = 1
                        AND MSII.SET_PROCESS_ID        = #' || p_batch_id || q'#
                        AND MSII.PROCESS_FLAG          = 1
                      UNION ALL
                      SELECT
                        MSII.TEMPLATE_ID,
                        MSII.INVENTORY_ITEM_ID ,
                        MSII.ORGANIZATION_ID,
                        MSII.ITEM_CATALOG_GROUP_ID,
                        NULL AS PK1_VALUE,
                        NULL AS PK2_VALUE,
                        NULL AS PK3_VALUE,
                        NULL AS PK4_VALUE,
                        NULL AS PK5_VALUE,
                        NULL AS REVISION_ID, #' ||
                        l_item_dl_id || q'# AS DATA_LEVEL_ID
                      FROM
                        MTL_SYSTEM_ITEMS_INTERFACE   MSII
                      WHERE MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
                        AND MSII.TEMPLATE_ID           IS NOT NULL
                        AND MSII.SET_PROCESS_ID        = #' || p_batch_id || q'#
                        AND MSII.PROCESS_FLAG          = 1
          UNION ALL
                      SELECT
                        MSII.TEMPLATE_ID,
                        MSII.INVENTORY_ITEM_ID ,
                        MSII.ORGANIZATION_ID,
                        MSII.ITEM_CATALOG_GROUP_ID,
                        NULL AS PK1_VALUE,
                        NULL AS PK2_VALUE,
                        NULL AS PK3_VALUE,
                        NULL AS PK4_VALUE,
                        NULL AS PK5_VALUE,
                        NULL AS REVISION_ID, #' ||
                        l_item_org_dl_id || q'# AS DATA_LEVEL_ID
                      FROM
                        MTL_SYSTEM_ITEMS_INTERFACE   MSII
                      WHERE MSII.ITEM_CATALOG_GROUP_ID IS NOT NULL
                        AND MSII.TEMPLATE_ID           IS NOT NULL
                        AND MSII.SET_PROCESS_ID        = #' || p_batch_id || q'#
                        AND MSII.PROCESS_FLAG          = 1 #';

      Debug_Conc_Log('Apply_Templates_For_UDAs: Created l_entity_sql');
      l_gdsn_entity_sql := q'#
                            SELECT
                              MSII.TEMPLATE_ID,
                              MSII.INVENTORY_ITEM_ID ,
                              MSII.ORGANIZATION_ID,
                              MSII.ITEM_CATALOG_GROUP_ID,
                              NULL AS PK1_VALUE,
                              NULL AS PK2_VALUE,
                              NULL AS PK3_VALUE,
                              NULL AS PK4_VALUE,
                              NULL AS PK5_VALUE,
                              NULL AS REVISION_ID, #' ||
                              l_item_gtin_dl_id || q'# AS DATA_LEVEL_ID
                            FROM
                              MTL_SYSTEM_ITEMS_INTERFACE   MSII
                            WHERE MSII.ITEM_CATALOG_GROUP_ID                IS NOT NULL
                              AND MSII.TEMPLATE_ID                          IS NOT NULL
                              AND MSII.SET_PROCESS_ID                       = #' || p_batch_id || q'#
                              AND MSII.PROCESS_FLAG                         = 1
                              AND NVL(MSII.GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y'
                            UNION ALL
                            SELECT
                              MSII.TEMPLATE_ID,
                              MSII.INVENTORY_ITEM_ID ,
                              MSII.ORGANIZATION_ID,
                              MSII.ITEM_CATALOG_GROUP_ID,
                              NULL AS PK1_VALUE,
                              NULL AS PK2_VALUE,
                              NULL AS PK3_VALUE,
                              NULL AS PK4_VALUE,
                              NULL AS PK5_VALUE,
                              NULL AS REVISION_ID, #' ||
                              l_item_gtin_multi_dl_id || q'# AS DATA_LEVEL_ID
                            FROM
                              MTL_SYSTEM_ITEMS_INTERFACE   MSII
                            WHERE MSII.ITEM_CATALOG_GROUP_ID                IS NOT NULL
                              AND MSII.TEMPLATE_ID                          IS NOT NULL
                              AND MSII.SET_PROCESS_ID                       = #' || p_batch_id || q'#
                              AND NVL(MSII.GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y'
                              AND MSII.PROCESS_FLAG                         = 1 #';

      Debug_Conc_Log('Apply_Templates_For_UDAs: Created l_gdsn_entity_sql');

      Call_UDA_Apply_Template
                    ( p_batch_id        => p_batch_id,
                      p_entity_sql      => l_entity_sql,
                      p_gdsn_entity_sql => l_gdsn_entity_sql,
                      p_user_id         => p_user_id,
                      p_login_id        => p_login_id,
                      p_prog_appid      => p_prog_appid,
                      p_prog_id         => p_prog_id,
                      p_request_id      => p_request_id,
                      x_return_status   => l_return_status,
                      x_err_msg         => l_err_msg
                    );

      Debug_Conc_Log('Apply_Templates_For_UDAs: Done Call_UDA_Apply_Template l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
      IF l_return_status = '2' THEN
        x_return_status := l_return_status;
        x_err_msg := l_err_msg;
        RETURN;
      ELSE
        x_return_status := l_return_status;
        x_err_msg := l_err_msg;
      END IF;
    END IF; -- IF l_apply_multiple_template

    IF NVL(x_return_status, '0') = '0' THEN
      x_return_status := '0';
      x_err_msg := NULL;
    END IF;
    Debug_Conc_Log('Apply_Templates_For_UDAs: Done with l_return_status, l_err_msg='||x_return_status||','||x_err_msg);
  EXCEPTION WHEN OTHERS THEN
    x_return_status := '2';
    x_err_msg := SQLERRM;
    Debug_Conc_Log('Apply_Templates_For_UDAs: Error with l_return_status, l_err_msg='||x_return_status||','||x_err_msg);
  END Apply_Templates_For_UDAs;

  PROCEDURE Copy_UDA_Attributes(retcode               OUT NOCOPY VARCHAR2,
                                errbuf                OUT NOCOPY VARCHAR2,
                                p_batch_id                       NUMBER)
  IS
    CURSOR c_data_levels IS
      SELECT
        edlb.DATA_LEVEL_ID,
        edlb.DATA_LEVEL_NAME
      FROM
        EGO_IMPORT_COPY_OPTIONS eico,
        EGO_DATA_LEVEL_B edlb,
        EGO_FND_DSC_FLX_CTX_EXT ag_ext
      WHERE eico.COPY_OPTION     LIKE 'COPY_ATTR_GROUP%'
        AND eico.BATCH_ID        = p_batch_id
        AND edlb.DATA_LEVEL_NAME = RTRIM(SUBSTR(eico.COPY_OPTION, INSTR(eico.COPY_OPTION, ':')+1))
        AND edlb.APPLICATION_ID  = 431
        AND edlb.APPLICATION_ID  = ag_ext.APPLICATION_ID
        AND edlb.ATTR_GROUP_TYPE = ag_ext.DESCRIPTIVE_FLEXFIELD_NAME
        AND ag_ext.ATTR_GROUP_ID = eico.ATTR_GROUP_ID
      GROUP BY edlb.DATA_LEVEL_ID, edlb.DATA_LEVEL_NAME
      UNION
      SELECT
        DATA_LEVEL_ID,
        DATA_LEVEL_NAME
      FROM EGO_DATA_LEVEL_B
      WHERE APPLICATION_ID  = 431
        AND ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
        AND DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL';

    l_src_sql           VARCHAR2(32000);
    l_ag_sql            VARCHAR2(32000);
    l_dest_sql          VARCHAR2(32000);
    l_join_condition    VARCHAR2(4000);
    l_rev_where_clause  VARCHAR2(1000);
    l_rev_id_sql        VARCHAR2(2000);
    l_pk_where          VARCHAR2(2000);
    l_return_status     VARCHAR2(10);
    l_ret_code          VARCHAR2(10);
    l_err_msg           VARCHAR2(4000);
    l_msg_data          VARCHAR2(4000);
    l_msg_count         NUMBER;
  BEGIN
    Debug_Conc_Log('Copy_UDA_Attributes: Starting ');
    RETCODE := '0';
    ERRBUF := NULL;

    FOR i IN c_data_levels LOOP
      IF i.DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL' THEN
        l_rev_where_clause := ' AND msii.COPY_REVISION_ID = ext_prod.REVISION_ID';
        l_pk_where := ' AND ext_prod.PK1_VALUE IS NULL AND ext_prod.PK2_VALUE IS NULL ';
        l_rev_id_sql := q'#(SELECT MAX(miri.REVISION_ID) KEEP (DENSE_RANK FIRST ORDER BY miri.REVISION)
                            FROM MTL_ITEM_REVISIONS_INTERFACE miri
                            WHERE miri.INVENTORY_ITEM_ID = msii.INVENTORY_ITEM_ID
                              AND miri.ORGANIZATION_ID   = msii.ORGANIZATION_ID
                              AND miri.SET_PROCESS_ID    = msii.SET_PROCESS_ID
                              AND miri.PROCESS_FLAG      = 1
                           ) AS REVISION_ID, #';
      ELSE
        l_rev_where_clause := NULL;
        l_rev_id_sql := ' NULL AS REVISION_ID, ';
        IF i.DATA_LEVEL_NAME = 'ITEM_SUP' THEN
          l_pk_where := ' AND ext_prod.PK1_VALUE IS NOT NULL AND ext_prod.PK2_VALUE IS NULL ';
        ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE' THEN
          l_pk_where := ' AND ext_prod.PK1_VALUE IS NOT NULL AND ext_prod.PK2_VALUE IS NOT NULL ';
        ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE_ORG' THEN
          l_pk_where := ' AND ext_prod.PK1_VALUE IS NOT NULL AND ext_prod.PK2_VALUE IS NOT NULL ';
        ELSE
          l_pk_where := NULL;
        END IF;
      END IF;
      l_src_sql := q'#
                      SELECT
                        ROWNUM AS ROW_IDENTIFIER,
                        msii.INVENTORY_ITEM_ID   AS INVENTORY_ITEM_ID,
                        msii.ORGANIZATION_ID     AS ORGANIZATION_ID,
                        msii.SET_PROCESS_ID      AS DATA_SET_ID,
                        msii.ORGANIZATION_CODE,
                        msii.ITEM_NUMBER,
                        msii.ITEM_CATALOG_GROUP_ID, #' || l_rev_id_sql || q'#
                        NULL AS REVISION,
                        ext_prod.DATA_LEVEL_ID,
                        ext_prod.PK1_VALUE,
                        ext_prod.PK2_VALUE,
                        ext_prod.PK3_VALUE,
                        ext_prod.PK4_VALUE,
                        ext_prod.PK5_VALUE,
                        NULL AS CHANGE_ID,
                        NULL AS CHANGE_LINE_ID,
                        msii.SOURCE_SYSTEM_ID,
                        msii.SOURCE_SYSTEM_REFERENCE,
                        msii.BUNDLE_ID,
                        msii.TRANSACTION_ID,
                        ext_prod.ATTR_GROUP_ID,
                        ext_prod.EXTENSION_ID, #' || G_PROD_COL_LIST || q'#
                      FROM
                        EGO_IMPORT_COPY_OPTIONS eico,
                        MTL_SYSTEM_ITEMS_INTERFACE msii,
                        EGO_MTL_SY_ITEMS_EXT_VL ext_prod
                      WHERE eico.COPY_OPTION       = 'COPY_ATTR_GROUP:#' || i.DATA_LEVEL_NAME || q'#'
                        AND eico.BATCH_ID          = #' || p_batch_id || q'#
                        AND eico.BATCH_ID          = msii.SET_PROCESS_ID
                        AND msii.PROCESS_FLAG      = 1
                        AND msii.COPY_ITEM_ID      = ext_prod.INVENTORY_ITEM_ID
                        AND msii.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID #' || l_rev_where_clause || q'#
                        AND ext_prod.DATA_LEVEL_ID = #' || i.DATA_LEVEL_ID || l_pk_where || q'#
                        AND ext_prod.ATTR_GROUP_ID = eico.ATTR_GROUP_ID  #';

      l_ag_sql := q'#
                      SELECT
                        ext_prod.ATTR_GROUP_ID
                      FROM
                        EGO_IMPORT_COPY_OPTIONS eico,
                        MTL_SYSTEM_ITEMS_INTERFACE msii,
                        EGO_MTL_SY_ITEMS_EXT_VL ext_prod
                      WHERE eico.COPY_OPTION       = 'COPY_ATTR_GROUP:#' || i.DATA_LEVEL_NAME || q'#'
                        AND eico.BATCH_ID          = #' || p_batch_id || q'#
                        AND eico.BATCH_ID          = msii.SET_PROCESS_ID
                        AND msii.PROCESS_FLAG      = 1
                        AND msii.COPY_ITEM_ID      = ext_prod.INVENTORY_ITEM_ID
                        AND msii.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID #' || l_rev_where_clause || q'#
                        AND ext_prod.DATA_LEVEL_ID = #' || i.DATA_LEVEL_ID || l_pk_where || q'#
                        AND ext_prod.ATTR_GROUP_ID = eico.ATTR_GROUP_ID  #';

      Debug_Conc_Log('Copy_UDA_Attributes: Calling copy for data level-'||i.DATA_LEVEL_ID);

      EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
        (
           p_api_version               => 1.0
          ,p_commit                    => 'F'
          ,p_copy_from_intf_table      => 'F'
          ,p_source_entity_sql         => l_src_sql
          ,p_source_attr_groups_sql    => l_ag_sql
          ,p_dest_process_status       => '2'   -- Bug 10263673
          ,p_dest_data_set_id          => p_batch_id
          ,p_dest_transaction_type     => 'CREATE'
          ,p_cleanup_row_identifiers   => FND_API.G_FALSE
          ,x_return_status             => l_return_status
          ,x_msg_count                 => l_msg_count
          ,x_msg_data                  => l_msg_data
        );

      Debug_Conc_Log('Copy_UDA_Attributes: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

      IF l_return_status = 'S' THEN
        l_ret_code := '0';
        l_err_msg := NULL;
      ELSIF l_return_status = 'E' THEN
        l_ret_code := '1';
        l_err_msg := l_msg_data;
      ELSE
        l_ret_code := '2';
        l_err_msg := l_msg_data;
      END IF;

      IF l_ret_code > RETCODE THEN
        RETCODE := l_ret_code;
        ERRBUF := l_err_msg;
      END IF;

      IF RETCODE = '2' THEN
        RETURN;
      END IF;
    END LOOP; -- c_data_levels
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
  END Copy_UDA_Attributes;

  -- procedure to do attribute group level defaulting
  -- Bug 9959169 : Added a new parameter p_msii_miri_process_flag
  PROCEDURE Do_AGLevel_UDA_Defaulting( p_batch_id       NUMBER,
                                       x_return_status  OUT NOCOPY VARCHAR2,
                                       x_err_msg        OUT NOCOPY VARCHAR2
                                      ,p_msii_miri_process_flag  IN NUMBER DEFAULT 1  -- Bug 9959169

                                     )
  IS
    l_err_msg                  VARCHAR2(4000);
    l_return_status            VARCHAR2(10);
    l_entity_sql               VARCHAR2(32000);
    l_item_dl_id               NUMBER;
    l_item_org_dl_id           NUMBER;
    l_item_rev_dl_id           NUMBER;
    l_item_gtin_dl_id          NUMBER;
    l_item_gtin_multi_dl_id    NUMBER;
    l_exclude_ag_sql           VARCHAR2(4000);

    l_g_ps_in_process     CONSTANT NUMBER := 2; --for bug 7523737



    CURSOR c_data_levels IS
      SELECT ATTR_GROUP_TYPE, DATA_LEVEL_ID, DATA_LEVEL_NAME
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE IN ('EGO_ITEMMGMT_GROUP', 'EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME IN ( 'ITEM_LEVEL', 'ITEM_REVISION_LEVEL', 'ITEM_ORG' );

  BEGIN
    Debug_Conc_Log('Do_AGLevel_UDA_Defaulting: Starting ');

    FOR i IN c_data_levels LOOP
      IF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_ORG' THEN
        l_item_org_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP' AND i.DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL' THEN
        l_item_rev_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_gtin_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS' AND i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_gtin_multi_dl_id := i.DATA_LEVEL_ID;
      END IF;
    END LOOP;

    l_exclude_ag_sql := NULL;
    -- Fix for bug#9660659

    l_entity_sql := q'#
                    SELECT
                      msii.TRANSACTION_ID,
                      msii.INVENTORY_ITEM_ID,
                      msii.ORGANIZATION_ID,
                      NULL AS REVISION_ID,
                      msii.ITEM_CATALOG_GROUP_ID,
                      msii.ITEM_NUMBER,
                      msii.ORGANIZATION_CODE,
                      NULL AS PK1_VALUE,
                      NULL AS PK2_VALUE,
                      NULL AS PK3_VALUE,
                      NULL AS PK4_VALUE,
                      NULL AS PK5_VALUE,
                      #' || l_item_dl_id || q'# AS DATA_LEVEL_ID
                    FROM
                      MTL_SYSTEM_ITEMS_INTERFACE msii, MTL_PARAMETERS mp
                    WHERE msii.SET_PROCESS_ID            = #' || p_batch_id || q'#
                      AND msii.ITEM_CATALOG_GROUP_ID     IS NOT NULL
                      AND msii.PROCESS_FLAG              = #' || p_msii_miri_process_flag || q'#
                      AND msii.TRANSACTION_TYPE          = 'CREATE'
                      AND NVL(msii.STYLE_ITEM_FLAG, 'Y') = 'Y'
                      AND msii.ORGANIZATION_ID           = mp.ORGANIZATION_ID
                      AND mp.ORGANIZATION_ID             = mp.MASTER_ORGANIZATION_ID
                    UNION ALL
                    SELECT
                      msii.TRANSACTION_ID,
                      msii.INVENTORY_ITEM_ID,
                      msii.ORGANIZATION_ID,
                      NULL AS REVISION_ID,
                      msii.ITEM_CATALOG_GROUP_ID,
                      msii.ITEM_NUMBER,
                      msii.ORGANIZATION_CODE,
                      NULL AS PK1_VALUE,
                      NULL AS PK2_VALUE,
                      NULL AS PK3_VALUE,
                      NULL AS PK4_VALUE,
                      NULL AS PK5_VALUE,
                      #' || l_item_org_dl_id || q'# AS DATA_LEVEL_ID
                    FROM
                      MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE msii.SET_PROCESS_ID            = #' || p_batch_id || q'#
                      AND msii.ITEM_CATALOG_GROUP_ID     IS NOT NULL
                      AND msii.PROCESS_FLAG              = #' || p_msii_miri_process_flag || q'#
                      AND msii.TRANSACTION_TYPE          = 'CREATE'
                      AND NVL(msii.STYLE_ITEM_FLAG, 'Y') = 'Y'
                    UNION ALL
                    SELECT /*+ leading(miri) use_nl_with_index(msii, MTL_SYSTEM_ITEMS_INTERFACE_N1) */
                      miri.TRANSACTION_ID,
                      miri.INVENTORY_ITEM_ID,
                      miri.ORGANIZATION_ID,
                      miri.REVISION_ID,
                      msii.ITEM_CATALOG_GROUP_ID,
                      miri.ITEM_NUMBER,
                      miri.ORGANIZATION_CODE,
                      NULL AS PK1_VALUE,
                      NULL AS PK2_VALUE,
                      NULL AS PK3_VALUE,
                      NULL AS PK4_VALUE,
                      NULL AS PK5_VALUE,
                      #' || l_item_rev_dl_id || q'# AS DATA_LEVEL_ID
                    FROM
                      MTL_SYSTEM_ITEMS_INTERFACE msii,
                      MTL_ITEM_REVISIONS_INTERFACE miri
                    WHERE miri.INVENTORY_ITEM_ID         = msii.INVENTORY_ITEM_ID
                      AND miri.ORGANIZATION_ID           = msii.ORGANIZATION_ID
                      AND msii.ITEM_CATALOG_GROUP_ID     IS NOT NULL
                      AND miri.SET_PROCESS_ID            = msii.SET_PROCESS_ID
                      AND msii.PROCESS_FLAG              = #' || p_msii_miri_process_flag || q'#
                      AND NVL(msii.STYLE_ITEM_FLAG, 'Y') = 'Y'
                      AND msii.TRANSACTION_TYPE          = 'CREATE'
                      AND miri.SET_PROCESS_ID            = #' || p_batch_id || q'#
                      AND miri.PROCESS_FLAG              = #' || p_msii_miri_process_flag || q'# #';

    Debug_Conc_Log('Do_AGLevel_UDA_Defaulting: Created l_entity_sql');

    EGO_USER_ATTRS_BULK_PVT.Insert_Default_Val_Rows (
                            p_api_version                   =>1.0
                           ,p_application_id                =>431
                           ,p_attr_group_type               =>'EGO_ITEMMGMT_GROUP'
                           ,p_object_name                   =>'EGO_ITEM'
                           ,p_interface_table_name          =>'EGO_ITM_USR_ATTR_INTRFC'
                           ,p_data_set_id                   => p_batch_id
                           ,p_target_entity_sql             => l_entity_sql
                           ,p_attr_groups_to_exclude        => l_exclude_ag_sql
                           ,p_additional_class_Code_query   => 'SELECT PARENT_CATALOG_GROUP_ID FROM EGO_ITEM_CAT_DENORM_HIER  WHERE CHILD_CATALOG_GROUP_ID = ENTITY.ITEM_CATALOG_GROUP_ID '
                           ,p_extra_column_names            => 'PROG_INT_CHAR1 '
                           ,p_extra_column_values           => ' ''EXT_DEFAULT_VAL_ROW'' '
                           ,x_return_status                 => l_return_status
                           ,x_msg_data                      => l_err_msg);

    Debug_Conc_Log('Do_AGLevel_UDA_Defaulting: Done EGO_USER_ATTRS_BULK_PVT.Insert_Default_Val_Rows l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := '2';
      x_err_msg := l_err_msg;
      RETURN;
    ELSE
      x_return_status := '0';
      x_err_msg := NULL;
    END IF;

--Bug 7523737 Begin
  --The above API call inserts records for mandatory UDAs with default values.
    --However, when user is assigning items to child organizations, we should
    --not be inserting records into the UDA table for item level UDAs (as they
    --are master controlled). So deleting the child records for item level
    --UDAs here (identified by rev_id = null. For 12.0+ releases, we need to use data level ID).
  DELETE FROM EGO_ITM_USR_ATTR_INTRFC ATTRS
--        WHERE ATTRS.DATA_SET_ID = p_data_set_id
     WHERE ATTRS.DATA_SET_ID = p_batch_id
          AND ATTRS.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
          AND ATTRS.REVISION_ID IS NULL
          --AND ATTRS.PROCESS_STATUS = G_PS_IN_PROCESS
          AND ATTRS.PROCESS_STATUS =  l_g_ps_in_process
          AND ATTRS.PROG_INT_CHAR1 = 'EXT_DEFAULT_VAL_ROW'
          AND EXISTS (SELECT 'X'
                        FROM MTL_PARAMETERS
                       WHERE ORGANIZATION_ID = ATTRS.ORGANIZATION_ID
                         AND ORGANIZATION_ID <> MASTER_ORGANIZATION_ID);
  --Bug 7523737 End

  -- Bug 9959169 Start
  -- The above api call inserts records for mandatory UDAs with default values.
   -- However, when user is trying to create a style item, we should bot be inserting variant attributes as it would value set for style item.
   -- So deleting the variant records for style item.
  DELETE EGO_ITM_USR_ATTR_INTRFC EIUAI
  WHERE EIUAI.DATA_SET_ID = p_batch_id
    AND EIUAI.PROCESS_STATUS = l_g_ps_in_process
    AND EIUAI.ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
    AND EIUAI.PROG_INT_CHAR1 = 'EXT_DEFAULT_VAL_ROW'
    AND (SELECT VARIANT FROM EGO_FND_DSC_FLX_CTX_EXT EXT
        WHERE APPLICATION_ID = 431
          AND EIUAI.ATTR_GROUP_INT_NAME = DESCRIPTIVE_FLEX_CONTEXT_CODE
          AND DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_ITEMMGMT_GROUP') = 'Y'
    AND EXISTS (SELECT 1 FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                WHERE MSII.INVENTORY_ITEM_ID = EIUAI.INVENTORY_ITEM_ID
                  AND MSII.ORGANIZATION_ID = EIUAI.ORGANIZATION_ID
                  AND MSII.SET_PROCESS_ID = EIUAI.DATA_SET_ID
                  AND NVL(MSII.STYLE_ITEM_FLAG, 'N') = 'Y'
                  AND MSII.PROCESS_FLAG = p_msii_miri_process_flag ) ;
  -- Bug 9959169 End



    l_entity_sql := q'#
                    SELECT
                      msii.TRANSACTION_ID,
                      msii.INVENTORY_ITEM_ID,
                      msii.ORGANIZATION_ID,
                      NULL AS REVISION_ID,
                      msii.ITEM_CATALOG_GROUP_ID,
                      msii.ITEM_NUMBER,
                      msii.ORGANIZATION_CODE,
                      NULL AS PK1_VALUE,
                      NULL AS PK2_VALUE,
                      NULL AS PK3_VALUE,
                      NULL AS PK4_VALUE,
                      NULL AS PK5_VALUE,
                      #' || l_item_gtin_dl_id || q'# AS DATA_LEVEL_ID
                    FROM
                      MTL_SYSTEM_ITEMS_INTERFACE msii, MTL_PARAMETERS mp
                    WHERE msii.SET_PROCESS_ID                       = #' || p_batch_id || q'#
                      AND msii.ITEM_CATALOG_GROUP_ID                IS NOT NULL
                      AND msii.PROCESS_FLAG                         = #' || p_msii_miri_process_flag || q'#
                      AND NVL(msii.GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y'
                      AND NVL(msii.STYLE_ITEM_FLAG, 'Y')            = 'Y'
                      AND msii.TRANSACTION_TYPE                     = 'CREATE'
                      AND msii.ORGANIZATION_ID                      = mp.ORGANIZATION_ID
                      AND mp.ORGANIZATION_ID                        = mp.MASTER_ORGANIZATION_ID
                    UNION ALL
                    SELECT
                      msii.TRANSACTION_ID,
                      msii.INVENTORY_ITEM_ID,
                      msii.ORGANIZATION_ID,
                      NULL AS REVISION_ID,
                      msii.ITEM_CATALOG_GROUP_ID,
                      msii.ITEM_NUMBER,
                      msii.ORGANIZATION_CODE,
                      NULL AS PK1_VALUE,
                      NULL AS PK2_VALUE,
                      NULL AS PK3_VALUE,
                      NULL AS PK4_VALUE,
                      NULL AS PK5_VALUE,
                      #' || l_item_gtin_multi_dl_id || q'# AS DATA_LEVEL_ID
                    FROM
                      MTL_SYSTEM_ITEMS_INTERFACE msii, MTL_PARAMETERS mp
                    WHERE msii.SET_PROCESS_ID                       = #' || p_batch_id || q'#
                      AND msii.ITEM_CATALOG_GROUP_ID                IS NOT NULL
                      AND NVL(msii.GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y'
                      AND NVL(msii.STYLE_ITEM_FLAG, 'Y')            = 'Y'
                      AND msii.TRANSACTION_TYPE                     = 'CREATE'
                      AND msii.ORGANIZATION_ID                      = mp.ORGANIZATION_ID
                      AND mp.ORGANIZATION_ID                        = mp.MASTER_ORGANIZATION_ID
                      AND msii.PROCESS_FLAG                         = #' || p_msii_miri_process_flag || q'# #';

    Debug_Conc_Log('Do_AGLevel_UDA_Defaulting: For GDSN Attributes, Created l_entity_sql');
    EGO_USER_ATTRS_BULK_PVT.Insert_Default_Val_Rows (
                            p_api_version                   =>1.0
                           ,p_application_id                =>431
                           ,p_attr_group_type               =>'EGO_ITEM_GTIN_ATTRS'
                           ,p_object_name                   =>'EGO_ITEM'
                           ,p_interface_table_name          =>'EGO_ITM_USR_ATTR_INTRFC'
                           ,p_data_set_id                   => p_batch_id
                           ,p_target_entity_sql             => l_entity_sql
                           ,p_attr_groups_to_exclude        => l_exclude_ag_sql
                           ,p_additional_class_Code_query   => 'SELECT PARENT_CATALOG_GROUP_ID FROM EGO_ITEM_CAT_DENORM_HIER  WHERE CHILD_CATALOG_GROUP_ID = ENTITY.ITEM_CATALOG_GROUP_ID '
                           ,p_extra_column_names            => 'PROG_INT_CHAR1'
                           ,p_extra_column_values           => ' ''EXT_DEFAULT_VAL_ROW'' '
                           ,x_return_status                 => l_return_status
                           ,x_msg_data                      => l_err_msg);

    Debug_Conc_Log('Do_AGLevel_UDA_Defaulting: Done EGO_USER_ATTRS_BULK_PVT.Insert_Default_Val_Rows l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := '2';
      x_err_msg := l_err_msg;
      RETURN;
    ELSE
      x_return_status := '0';
      x_err_msg := NULL;
    END IF;

    l_entity_sql := q'#
                    SELECT
                      eiai.TRANSACTION_ID,
                      eiai.INVENTORY_ITEM_ID,
                      eiai.ORGANIZATION_ID,
                      NULL AS REVISION_ID,
                      ( NVL( (SELECT ITEM_CATALOG_GROUP_ID
                              FROM MTL_SYSTEM_ITEMS_B msib
                              WHERE msib.INVENTORY_ITEM_ID = eiai.INVENTORY_ITEM_ID
                                AND msib.ORGANIZATION_ID   = eiai.ORGANIZATION_ID
                             ),
                             (SELECT ITEM_CATALOG_GROUP_ID
                              FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                              WHERE msii.INVENTORY_ITEM_ID = eiai.INVENTORY_ITEM_ID
                                AND msii.ORGANIZATION_ID   = eiai.ORGANIZATION_ID
                                AND msii.SET_PROCESS_ID    = eiai.BATCH_ID
                                AND msii.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                                AND ROWNUM = 1
                             )
                           )
                      ) AS ITEM_CATALOG_GROUP_ID,
                      eiai.ITEM_NUMBER,
                      eiai.ORGANIZATION_CODE,
                      eiai.PK1_VALUE,
                      eiai.PK2_VALUE,
                      NULL AS PK3_VALUE,
                      NULL AS PK4_VALUE,
                      NULL AS PK5_VALUE,
                      eiai.DATA_LEVEL_ID
                    FROM
                      EGO_ITEM_ASSOCIATIONS_INTF eiai
                    WHERE eiai.BATCH_ID                  = #' || p_batch_id || q'#
                      AND NVL(eiai.STYLE_ITEM_FLAG, 'Y') = 'Y'
                      AND eiai.PROCESS_FLAG              = #' || p_msii_miri_process_flag || q'# #';

    Debug_Conc_Log('Do_AGLevel_UDA_Defaulting: For Intersections - Created l_entity_sql');

    EGO_USER_ATTRS_BULK_PVT.Insert_Default_Val_Rows (
                            p_api_version                   =>1.0
                           ,p_application_id                =>431
                           ,p_attr_group_type               =>'EGO_ITEMMGMT_GROUP'
                           ,p_object_name                   =>'EGO_ITEM'
                           ,p_interface_table_name          =>'EGO_ITM_USR_ATTR_INTRFC'
                           ,p_data_set_id                   => p_batch_id
                           ,p_target_entity_sql             => l_entity_sql
                           ,p_attr_groups_to_exclude        => l_exclude_ag_sql
                           ,p_additional_class_Code_query   => 'SELECT PARENT_CATALOG_GROUP_ID FROM EGO_ITEM_CAT_DENORM_HIER  WHERE CHILD_CATALOG_GROUP_ID = ENTITY.ITEM_CATALOG_GROUP_ID '
                           ,p_extra_column_names            => 'PROG_INT_CHAR1 '
                           ,p_extra_column_values           => ' ''EXT_DEFAULT_VAL_ROW'' '
                           ,x_return_status                 => l_return_status
                           ,x_msg_data                      => l_err_msg);

    Debug_Conc_Log('Do_AGLevel_UDA_Defaulting: For Intersections - Done EGO_USER_ATTRS_BULK_PVT.Insert_Default_Val_Rows l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := '2';
      x_err_msg := l_err_msg;
      RETURN;
    ELSE
      x_return_status := '0';
      x_err_msg := NULL;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    x_return_status := '2';
    x_err_msg := SQLERRM;
    Debug_Conc_Log('Do_AGLevel_UDA_Defaulting: Error with l_return_status, l_err_msg='||x_return_status||','||x_err_msg);
  END Do_AGLevel_UDA_Defaulting;

  /* Function to process copy options for UDAs
   */
  PROCEDURE Process_Copy_Options_For_UDAs(retcode               OUT NOCOPY VARCHAR2,
                                          errbuf                OUT NOCOPY VARCHAR2,
                                          p_batch_id                       NUMBER,
                                          p_copy_options_exist             VARCHAR2)
  IS
    l_user_id             NUMBER := FND_GLOBAL.USER_ID;
    l_login_id            NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid          NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id             NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id          NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_err_msg             VARCHAR2(4000);
    l_copy_first          VARCHAR2(1);
    l_return_status       VARCHAR2(1) := '0';
  BEGIN
    Debug_Conc_Log('Process_Copy_Options_For_UDAs: Starting, p_copy_options_exist='||p_copy_options_exist);
    IF l_request_id IS NULL OR l_request_id <= 0 THEN
      l_request_id := -1;
    END IF;

    RETCODE := '0';
    ERRBUF := NULL;

    Debug_Conc_Log('Process_Copy_Options_For_UDAs: Calling Resolve_Data_Level_Id');
    Resolve_Data_Level_Id( p_batch_id => p_batch_id);
    Debug_Conc_Log('Process_Copy_Options_For_UDAs: Done Resolve_Data_Level_Id');

    IF NVL(p_copy_options_exist, 'N') = 'N' THEN
      -- applying templates
      -- template_id/name is taken from the template_id/name
      -- column of MSII table
      Debug_Conc_Log('Process_Copy_Options_For_UDAs: Calling Apply_Templates_For_UDAs');
      Apply_Templates_For_UDAs( p_batch_id,
                                l_user_id,
                                l_login_id,
                                l_prog_appid,
                                l_prog_id,
                                l_request_id,
                                l_return_status,
                                l_err_msg
                              );
      Debug_Conc_Log('Process_Copy_Options_For_UDAs: Done Apply_Templates_For_UDAs with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
      IF l_return_status > RETCODE THEN
        RETCODE := l_return_status;
        ERRBUF := l_err_msg;
      END IF;
      IF RETCODE = '2' THEN
        RETURN;
      END IF;
    ELSE --IF p_copy_option_exists = 'N' THEN
      -- get copy options here and depending on the options
      -- apply templates, copy, etc.
      BEGIN
        SELECT NVL(SELECTION_FLAG, 'N') INTO l_copy_first
        FROM EGO_IMPORT_COPY_OPTIONS
        WHERE BATCH_ID = p_batch_id
          AND COPY_OPTION = 'COPY_FIRST';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_copy_first := 'N';
      END;

      -- if user has selected copy_first='Y', then it means that
      -- first copy the attributes and then apply the templates
      -- but when applying templates overwrite the existing values
      -- but technically we do it reverse i.e.
      -- if user has selected copy_first='Y', then we will apply the
      -- templates first (without overwriting existing values) in the
      -- reverse order that user has specified, and then we will
      -- copy the attributes (without overwriting existing values)

      Debug_Conc_Log('Process_Copy_Options_For_UDAs: l_copy_first='||l_copy_first);
      IF l_copy_first = 'N' THEN
        -- copying UDA attributes
        Debug_Conc_Log('Process_Copy_Options_For_UDAs: Calling Copy_UDA_Attributes');

        Copy_UDA_Attributes(retcode     => l_return_status,
                            errbuf      => l_err_msg,
                            p_batch_id  => p_batch_id
                           );

        Debug_Conc_Log('Process_Copy_Options_For_UDAs: Done Copy_UDA_Attributes with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
        IF l_return_status > RETCODE THEN
          RETCODE := l_return_status;
          ERRBUF := l_err_msg;
        END IF;
        IF RETCODE = '2' THEN
          RETURN;
        END IF;

        Apply_Templates_For_UDAs( p_batch_id,
                                  l_user_id,
                                  l_login_id,
                                  l_prog_appid,
                                  l_prog_id,
                                  l_request_id,
                                  l_return_status,
                                  l_err_msg
                                );
        Debug_Conc_Log('Process_Copy_Options_For_UDAs: Done Apply_Templates_For_UDAs with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
        IF l_return_status > RETCODE THEN
          RETCODE := l_return_status;
          ERRBUF := l_err_msg;
        END IF;
        IF RETCODE = '2' THEN
          RETURN;
        END IF;
      ELSE --IF l_copy_first = 'N' THEN
        Debug_Conc_Log('Process_Copy_Options_For_UDAs: Calling Apply_Templates_For_UDAs');
        Apply_Templates_For_UDAs( p_batch_id,
                                  l_user_id,
                                  l_login_id,
                                  l_prog_appid,
                                  l_prog_id,
                                  l_request_id,
                                  l_return_status,
                                  l_err_msg
                                );
        Debug_Conc_Log('Process_Copy_Options_For_UDAs: Done Apply_Templates_For_UDAs with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
        IF l_return_status > RETCODE THEN
          RETCODE := l_return_status;
          ERRBUF := l_err_msg;
        END IF;
        IF RETCODE = '2' THEN
          RETURN;
        END IF;

        Debug_Conc_Log('Process_Copy_Options_For_UDAs: Calling Copy_UDA_Attributes');

        Copy_UDA_Attributes(retcode     => l_return_status,
                            errbuf      => l_err_msg,
                            p_batch_id  => p_batch_id
                           );

        Debug_Conc_Log('Process_Copy_Options_For_UDAs: Done Copy_UDA_Attributes with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
        IF l_return_status > RETCODE THEN
          RETCODE := l_return_status;
          ERRBUF := l_err_msg;
        END IF;

        IF RETCODE = '2' THEN
          RETURN;
        END IF;
      END IF; --IF l_copy_first = 'N' THEN
    END IF; -- IF NVL(p_copy_option_exists, 'N') = 'N' THEN

    IF NVL(RETCODE, '0') = '0' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    END IF;

    -- Bug 10263673 : Start
    -- The below call to the api is needed as, the row idents need to be cleaned up after the template/copy attrs is done
    -- and before the attr level defaulting.
    Debug_Conc_Log('Process_Copy_Options_For_UDAs: Calling Clean_Up_UDA_Row_Idents ');
    EGO_IMPORT_PVT.Clean_Up_UDA_Row_Idents(
                             p_batch_id             => p_batch_id,
                             p_process_status       => 2,
                             p_ignore_item_num_upd  => FND_API.G_TRUE,
                             p_commit               => FND_API.G_FALSE );
    Debug_Conc_Log('Process_Copy_Options_For_UDAs: Clean_Up_UDA_Row_Idents Done.');
    -- Bug 10263673 : End

    Debug_Conc_Log('Process_Copy_Options_For_UDAs: Done - retcode, errbuf='||retcode||','||errbuf);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Process_Copy_Options_For_UDAs: Error - retcode, errbuf='||retcode||','||errbuf);
  END Process_Copy_Options_For_UDAs;

  /* Private API to call tempalte application for items
   */
  FUNCTION Apply_Templates_For_Items
                        ( p_batch_id   NUMBER,
                          p_user_id    NUMBER,
                          p_login_id   NUMBER,
                          p_prog_appid NUMBER,
                          p_prog_id    NUMBER,
                          p_request_id NUMBER,
                          x_err_msg    OUT NOCOPY VARCHAR2
                        )
  RETURN INTEGER
  IS
    l_err_msg                  VARCHAR2(4000);
    l_return_status            INTEGER;
    l_template_table           INVPULI2.Import_Template_Tbl_Type;
    l_apply_multiple_template  BOOLEAN;
  BEGIN
    Debug_Conc_Log('Apply_Templates_For_Items: Starting p_batch_id='||p_batch_id);
    SELECT TEMPLATE_ID
    BULK COLLECT INTO l_template_table
    FROM EGO_IMPORT_COPY_OPTIONS
    WHERE BATCH_ID = p_batch_id
      AND COPY_OPTION = 'APPLY_TEMPLATE'
    ORDER BY TEMPLATE_SEQUENCE DESC;

    IF l_template_table IS NULL OR l_template_table.COUNT = 0 THEN
      l_apply_multiple_template := FALSE;
    ELSE
      l_apply_multiple_template := TRUE;
    END IF;

    IF l_apply_multiple_template THEN
      Debug_Conc_Log('Apply_Templates_For_Items: APPLY_TEMPLATE option found in Copy options, so applying multiple templates');
      Debug_Conc_Log('Apply_Templates_For_Items: Calling INVPULI2.apply_multiple_template');
      l_return_status := INVPULI2.apply_multiple_template
                            (
                               p_template_tbl  => l_template_table
                              ,p_org_id        => NULL
                              ,p_all_org       => 1
                              ,p_prog_appid    => p_prog_appid
                              ,p_prog_id       => p_prog_id
                              ,p_request_id    => p_request_id
                              ,p_user_id       => p_user_id
                              ,p_login_id      => p_login_id
                              ,p_xset_id       => p_batch_id
                              ,x_err_text      => l_err_msg
                            );

      Debug_Conc_Log('Apply_Templates_For_Items: Done INVPULI2.apply_multiple_template with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
      IF l_return_status <> 0 THEN
        x_err_msg := l_err_msg;
        RETURN l_return_status;
      END IF;
    ELSE -- IF l_apply_multiple_template
      -- applying templates present in the MSII table
      -- template_id/name is taken from the template_id/name
      -- column of MSII table
      Debug_Conc_Log('Apply_Templates_For_Items: APPLY_TEMPLATE option NOT found in Copy options, so applying templates present in MSII');
      Debug_Conc_Log('Apply_Templates_For_Items: Calling INVPULI2.copy_template_attributes');
      l_return_status := INVPULI2.copy_template_attributes
                            (
                               org_id     => NULL
                              ,all_org    => 1
                              ,prog_appid => p_prog_appid
                              ,prog_id    => p_prog_id
                              ,request_id => p_request_id
                              ,user_id    => p_user_id
                              ,login_id   => p_login_id
                              ,xset_id    => p_batch_id
                              ,err_text   => l_err_msg
                            );

      Debug_Conc_Log('Apply_Templates_For_Items: Done INVPULI2.copy_template_attributes with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
      IF l_return_status <> 0 THEN
        x_err_msg := l_err_msg;
        RETURN l_return_status;
      END IF;
    END IF; -- IF l_apply_multiple_template

    x_err_msg := NULL;
    Debug_Conc_Log('Apply_Templates_For_Items: Done with l_return_status, l_err_msg='||l_return_status||','||x_err_msg);
    RETURN l_return_status;
  EXCEPTION WHEN OTHERS THEN
    x_err_msg := SQLERRM;
    Debug_Conc_Log('Apply_Templates_For_Items: Error with l_return_status, l_err_msg='||SQLCODE||','||x_err_msg);
    RETURN SQLCODE;
  END Apply_Templates_For_Items;



  PROCEDURE Copy_New_Cat_Assgns_From_Style(retcode               OUT NOCOPY VARCHAR2,
                                           errbuf                OUT NOCOPY VARCHAR2,
                                           p_batch_id                       NUMBER)
  IS
    l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_def_style_catg_option    VARCHAR2(1);
    l_pdh_ss_id                NUMBER := EGO_IMPORT_PVT.Get_Pdh_Source_System_Id;
  BEGIN
    RETCODE := '0';
    Debug_Conc_Log('Copy_New_Cat_Assgns_From_Style: Starting');
    l_def_style_catg_option := EGO_COMMON_PVT.GET_OPTION_VALUE('EGO_DEFAULT_STYLE_ALTERNATE_CATALOG');
    Debug_Conc_Log('Copy_New_Cat_Assgns_From_Style: l_def_style_catg_option='||l_def_style_catg_option);
    IF NVL(l_def_style_catg_option, 'N') <> 'Y' THEN
      Debug_Conc_Log('Copy_New_Cat_Assgns_From_Style: Defaulting is set to NO, so returning');
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END IF;

    INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE
    (
      INVENTORY_ITEM_ID,
      ITEM_NUMBER,
      ORGANIZATION_ID,
      CATEGORY_SET_ID,
      CATEGORY_ID,
      PROCESS_FLAG,
      SET_PROCESS_ID,
      TRANSACTION_TYPE,
      SOURCE_SYSTEM_ID,
      CREATED_BY
    )
    SELECT
      msik.INVENTORY_ITEM_ID,
      msik.CONCATENATED_SEGMENTS AS ITEM_NUMBER,
      msik.ORGANIZATION_ID,
      mici.CATEGORY_SET_ID,
      mici.CATEGORY_ID,
      1 PROCESS_FLAG,
      p_batch_id,
      'CREATE',
      l_pdh_ss_id,
      -99
    FROM
      MTL_ITEM_CATEGORIES_INTERFACE mici,
      MTL_SYSTEM_ITEMS_KFV msik
    WHERE mici.SET_PROCESS_ID    = p_batch_id
      AND msik.STYLE_ITEM_ID     = mici.INVENTORY_ITEM_ID
      AND msik.ORGANIZATION_ID   = mici.ORGANIZATION_ID
      AND mici.REQUEST_ID        = l_request_id
      AND mici.TRANSACTION_TYPE  = 'CREATE'
      AND mici.PROCESS_FLAG      = 7
      AND msik.STYLE_ITEM_FLAG   = 'N'
      AND NOT EXISTS (SELECT 1 FROM MTL_DEFAULT_CATEGORY_SETS dcs WHERE dcs.CATEGORY_SET_ID = mici.CATEGORY_SET_ID)
      AND NOT EXISTS (SELECT 1
                      FROM MTL_ITEM_CATEGORIES mic
                      WHERE mic.CATEGORY_SET_ID   = mici.CATEGORY_SET_ID
                        AND mic.CATEGORY_ID       = mici.CATEGORY_ID
                        AND mic.INVENTORY_ITEM_ID = msik.INVENTORY_ITEM_ID
                        AND mic.ORGANIZATION_ID   = msik.ORGANIZATION_ID)
      AND NOT EXISTS (SELECT NULL
                      FROM MTL_ITEM_CATEGORIES_INTERFACE mici1
                        WHERE mici1.SET_PROCESS_ID  = p_batch_id
                          AND mici1.PROCESS_FLAG    = 1
                          AND (mici1.INVENTORY_ITEM_ID = msik.INVENTORY_ITEM_ID OR mici1.ITEM_NUMBER = msik.CONCATENATED_SEGMENTS)
                          AND mici1.ORGANIZATION_ID = msik.ORGANIZATION_ID
                          AND (mici1.CATEGORY_SET_ID = mici.CATEGORY_SET_ID
                               OR mici1.CATEGORY_SET_NAME = (SELECT mcs.CATEGORY_SET_NAME
                                                             FROM MTL_CATEGORY_SETS_VL mcs
                                                             WHERE mcs.CATEGORY_SET_ID = mici.CATEGORY_SET_ID
                                                            )
                              )
                          AND (mici1.CATEGORY_ID     = mici.CATEGORY_ID
                               OR mici1.CATEGORY_NAME = (SELECT mc.CONCATENATED_SEGMENTS
                                                         FROM MTL_CATEGORIES_KFV mc
                                                         WHERE mc.CATEGORY_ID = mici.CATEGORY_ID
                                                        )
                              )
                     );

    Debug_Conc_Log('Copy_New_Cat_Assgns_From_Style: Inserted records count='||SQL%ROWCOUNT);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := 'Copy_New_Cat_Assgns_From_Style: Error -'||SQLERRM;
  END Copy_New_Cat_Assgns_From_Style;


  PROCEDURE Copy_Category_Assignments(retcode               OUT NOCOPY VARCHAR2,
                                      errbuf                OUT NOCOPY VARCHAR2,
                                      p_batch_id                       NUMBER,
                                      p_skus_only                      VARCHAR2)
  IS
    l_def_style_catg_option    VARCHAR2(1);
  BEGIN
    RETCODE := '0';
    Debug_Conc_Log('Copy_Category_Assignments: Starting p_skus_only='||p_skus_only);
    l_def_style_catg_option := EGO_COMMON_PVT.GET_OPTION_VALUE('EGO_DEFAULT_STYLE_ALTERNATE_CATALOG');
    Debug_Conc_Log('Copy_Category_Assignments: l_def_style_catg_option='||l_def_style_catg_option);
    IF NVL(l_def_style_catg_option, 'N') <> 'Y' AND NVL(p_skus_only, 'Y') = 'Y' THEN
      Debug_Conc_Log('Copy_Category_Assignments: Defaulting is set to NO, so returning');
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END IF;

    INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE
    (
      INVENTORY_ITEM_ID,
      ITEM_NUMBER,
      ORGANIZATION_ID,
      CATEGORY_SET_ID,
      CATEGORY_ID,
      PROCESS_FLAG,
      SET_PROCESS_ID,
      TRANSACTION_TYPE
    )
    SELECT
      MSII.INVENTORY_ITEM_ID,
      MSII.ITEM_NUMBER,
      MSII.ORGANIZATION_ID,
      STYLE_CATS.CATEGORY_SET_ID,
      STYLE_CATS.CATEGORY_ID,
      1 PROCESS_FLAG,
      MSII.SET_PROCESS_ID,
      'CREATE'
    FROM
      MTL_SYSTEM_ITEMS_INTERFACE MSII,
      MTL_PARAMETERS O,
      MTL_ITEM_CATEGORIES STYLE_CATS
    WHERE MSII.SET_PROCESS_ID          = p_batch_id
      AND MSII.PROCESS_FLAG            = 1
      AND MSII.TRANSACTION_TYPE        = 'CREATE'
      AND ((NVL(p_skus_only, 'Y') = 'Y' AND MSII.STYLE_ITEM_FLAG = 'N')
        OR (NVL(p_skus_only, 'Y') = 'N' AND NVL(MSII.STYLE_ITEM_FLAG, 'Y') = 'Y')
          )
      AND MSII.ORGANIZATION_ID         = O.ORGANIZATION_ID
      AND O.ORGANIZATION_ID            = O.MASTER_ORGANIZATION_ID
      AND NOT EXISTS (SELECT 1 FROM MTL_DEFAULT_CATEGORY_SETS DCS WHERE DCS.CATEGORY_SET_ID = STYLE_CATS.CATEGORY_SET_ID)
      AND STYLE_CATS.INVENTORY_ITEM_ID = MSII.COPY_ITEM_ID
      AND STYLE_CATS.ORGANIZATION_ID   = MSII.ORGANIZATION_ID
      AND NOT EXISTS (SELECT NULL
                      FROM MTL_ITEM_CATEGORIES_INTERFACE MICI
                        WHERE MICI.SET_PROCESS_ID  = MSII.SET_PROCESS_ID
                          AND MICI.PROCESS_FLAG    = MSII.PROCESS_FLAG
                          AND (MICI.ITEM_NUMBER    = MSII.ITEM_NUMBER OR MICI.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID)
                          AND MICI.ORGANIZATION_ID = MSII.ORGANIZATION_ID
                          AND MICI.CATEGORY_SET_ID = STYLE_CATS.CATEGORY_SET_ID
                          AND MICI.CATEGORY_ID     = STYLE_CATS.CATEGORY_ID
                     );

    Debug_Conc_Log('Copy_Category_Assignments: Inserted records count='||SQL%ROWCOUNT);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := 'Copy_Category_Assignments: Error -'||SQLERRM;
  END Copy_Category_Assignments;

  /* Function to process copy options for Items */
  PROCEDURE Process_Copy_Options_For_Items(retcode               OUT NOCOPY VARCHAR2,
                                           errbuf                OUT NOCOPY VARCHAR2,
                                           p_batch_id                       NUMBER,
                                           p_copy_options_exist             VARCHAR2)
  IS
    l_user_id             NUMBER := FND_GLOBAL.USER_ID;
    l_login_id            NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid          NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id             NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id          NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_err_msg             VARCHAR2(4000);
    l_return_status       INTEGER;
    l_ret_status          VARCHAR2(10);
    l_copy_first          VARCHAR2(1);
    l_copy_org            VARCHAR2(1);
    l_copy_cat            VARCHAR2(1);
    l_copy_sup            VARCHAR2(1);
    l_copy_sup_site       VARCHAR2(1);
    l_copy_sup_site_org   VARCHAR2(1);
    l_data_level_names    EGO_ITEM_ASSOCIATIONS_PUB.VARCHAR2_TBL_TYPE;
    l_src_item_id         NUMBER;
    l_msg_count           NUMBER;
    l_cntr                NUMBER;
  BEGIN
    Debug_Conc_Log('Process_Copy_Options_For_Items: Starting p_copy_options_exist='||p_copy_options_exist);
    RETCODE := '0';
    IF l_request_id IS NULL OR l_request_id <= 0 THEN
      l_request_id := -1;
    END IF;

    IF NVL(p_copy_options_exist, 'N') = 'N' THEN
      -- applying templates
      -- template_id/name is taken from the template_id/name
      -- column of MSII table
      Debug_Conc_Log('Process_Copy_Options_For_Items: Calling INVPULI2.copy_template_attributes');
      l_return_status := INVPULI2.copy_template_attributes
                            (
                               org_id     => NULL
                              ,all_org    => 1
                              ,prog_appid => l_prog_appid
                              ,prog_id    => l_prog_id
                              ,request_id => l_request_id
                              ,user_id    => l_user_id
                              ,login_id   => l_login_id
                              ,xset_id    => p_batch_id
                              ,err_text   => l_err_msg
                            );

      Debug_Conc_Log('Process_Copy_Options_For_Items: Done INVPULI2.copy_template_attributes with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
      IF l_return_status <> 0 THEN
        RETCODE := '2';
        ERRBUF := 'Error Code='||l_return_status||', Msg='||l_err_msg;
        RETURN;
      END IF;

      -- copying MSI attributes
      Debug_Conc_Log('Process_Copy_Options_For_Items: Calling INVPULI3.copy_item_attributes');
      l_return_status := INVPULI3.copy_item_attributes
                            (
                               org_id     => NULL
                              ,all_org    => 1
                              ,prog_appid => l_prog_appid
                              ,prog_id    => l_prog_id
                              ,request_id => l_request_id
                              ,user_id    => l_user_id
                              ,login_id   => l_login_id
                              ,xset_id    => p_batch_id
                              ,err_text   => l_err_msg
                            );
      Debug_Conc_Log('Process_Copy_Options_For_Items: Done INVPULI3.copy_item_attributes with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
      IF l_return_status <> 0 THEN
        RETCODE := '2';
        ERRBUF := 'Error Code='||l_return_status||', Msg='||l_err_msg;
        RETURN;
      END IF;

      Debug_Conc_Log('Process_Copy_Options_For_Items: Calling Copy_Category_Assignments for SKUs');
      Copy_Category_Assignments( retcode      => l_ret_status
                                ,errbuf       => l_err_msg
                                ,p_batch_id   => p_batch_id
                                ,p_skus_only  => 'Y'
                               );
      Debug_Conc_Log('Process_Copy_Options_For_Items: Done Copy_Category_Assignments with l_ret_status, l_err_msg='||l_ret_status||','||l_err_msg);
      IF l_ret_status > RETCODE THEN
        RETCODE := l_ret_status;
        ERRBUF := l_err_msg;
      END IF;

      Debug_Conc_Log('Process_Copy_Options_For_Items: Calling Copy_New_Cat_Assgns_From_Style for SKUs');
      Copy_New_Cat_Assgns_From_Style( retcode      => l_ret_status
                                     ,errbuf       => l_err_msg
                                     ,p_batch_id   => p_batch_id
                                    );
      Debug_Conc_Log('Process_Copy_Options_For_Items: Done Copy_New_Cat_Assgns_From_Style with l_ret_status, l_err_msg='||l_ret_status||','||l_err_msg);
      IF l_ret_status > RETCODE THEN
        RETCODE := l_ret_status;
        ERRBUF := l_err_msg;
      END IF;
    ELSE --IF p_copy_option_exists = 'N' THEN
      -- get copy options here and depending on the options
      -- apply templates, copy, etc.
      BEGIN
        SELECT NVL(SELECTION_FLAG, 'N') INTO l_copy_first
        FROM EGO_IMPORT_COPY_OPTIONS
        WHERE BATCH_ID = p_batch_id
          AND COPY_OPTION = 'COPY_FIRST';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_copy_first := 'N';
      END;

      -- if user has selected copy_first='Y', then it means that
      -- first copy the attributes and then apply the templates
      -- but when applying templates overwrite the existing values
      -- but technically we do it reverse i.e.
      -- if user has selected copy_first='Y', then we will apply the
      -- templates first (without overwriting existing values) in the
      -- reverse order that user has specified, and then we will
      -- copy the attributes (without overwriting existing values)

      Debug_Conc_Log('Process_Copy_Options_For_Items: l_copy_first='||l_copy_first);
      IF l_copy_first = 'N' THEN
        -- copying MSI attributes
        Debug_Conc_Log('Process_Copy_Options_For_Items: Calling INVPULI3.copy_item_attributes');
        l_return_status := INVPULI3.copy_item_attributes
                              (
                                 org_id     => NULL
                                ,all_org    => 1
                                ,prog_appid => l_prog_appid
                                ,prog_id    => l_prog_id
                                ,request_id => l_request_id
                                ,user_id    => l_user_id
                                ,login_id   => l_login_id
                                ,xset_id    => p_batch_id
                                ,err_text   => l_err_msg
                              );

        Debug_Conc_Log('Process_Copy_Options_For_Items: Done INVPULI3.copy_item_attributes with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
        IF l_return_status <> 0 THEN
          RETCODE := '2';
          ERRBUF := 'Error Code='||l_return_status||', Msg='||l_err_msg;
          RETURN;
        END IF;

        l_return_status := Apply_Templates_For_Items(p_batch_id,
                                                     l_user_id,
                                                     l_login_id,
                                                     l_prog_appid,
                                                     l_prog_id,
                                                     l_request_id,
                                                     l_err_msg
                                                   );
        Debug_Conc_Log('Process_Copy_Options_For_Items: Done Apply_Templates_For_Items with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
        IF l_return_status <> 0 THEN
          RETCODE := '2';
          ERRBUF := 'Error Code='||l_return_status||', Msg='||l_err_msg;
          RETURN;
        END IF;
      ELSE --IF l_copy_first = 'N' THEN
        Debug_Conc_Log('Process_Copy_Options_For_Items: Calling Apply_Templates_For_Items');
        l_return_status := Apply_Templates_For_Items(p_batch_id,
                                                     l_user_id,
                                                     l_login_id,
                                                     l_prog_appid,
                                                     l_prog_id,
                                                     l_request_id,
                                                     l_err_msg
                                                   );
        Debug_Conc_Log('Process_Copy_Options_For_Items: Done Apply_Templates_For_Items with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
        IF l_return_status <> 0 THEN
          RETCODE := '2';
          ERRBUF := 'Error Code='||l_return_status||', Msg='||l_err_msg;
          RETURN;
        END IF;

        -- copying MSI attributes
        l_return_status := INVPULI3.copy_item_attributes
                              (
                                 org_id     => NULL
                                ,all_org    => 1
                                ,prog_appid => l_prog_appid
                                ,prog_id    => l_prog_id
                                ,request_id => l_request_id
                                ,user_id    => l_user_id
                                ,login_id   => l_login_id
                                ,xset_id    => p_batch_id
                                ,err_text   => l_err_msg
                              );
        Debug_Conc_Log('Process_Copy_Options_For_Items: Done INVPULI3.copy_item_attributes with l_return_status, l_err_msg='||l_return_status||','||l_err_msg);
        IF l_return_status <> 0 THEN
          RETCODE := '2';
          ERRBUF := 'Error Code='||l_return_status||', Msg='||l_err_msg;
          RETURN;
        END IF;
      END IF; --IF l_copy_first = 'N' THEN

      -- copying organization assignments
      BEGIN
        SELECT NVL(SELECTION_FLAG, 'N') INTO l_copy_org
        FROM EGO_IMPORT_COPY_OPTIONS
        WHERE BATCH_ID = p_batch_id
          AND COPY_OPTION = 'COPY_ORG_ASSIGNMENTS';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_copy_org := 'N';
      END;

      Debug_Conc_Log('Process_Copy_Options_For_Items: l_copy_org='||l_copy_org);
      IF l_copy_org = 'Y' THEN
        INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
        (
          SET_PROCESS_ID,
          PROCESS_FLAG,
          TRANSACTION_TYPE,
          INVENTORY_ITEM_ID,
          ITEM_NUMBER,
          ORGANIZATION_ID,
          STYLE_ITEM_ID,
          STYLE_ITEM_FLAG,
          SOURCE_SYSTEM_ID,
          SOURCE_SYSTEM_REFERENCE,
          COPY_ITEM_ID
        )
        SELECT
          MSII.SET_PROCESS_ID,
          MSII.PROCESS_FLAG,
          'CREATE',
          MSII.INVENTORY_ITEM_ID,
          MSII.ITEM_NUMBER,
          MSI.ORGANIZATION_ID,
          MSI.STYLE_ITEM_ID,
          MSI.STYLE_ITEM_FLAG,
          MSII.SOURCE_SYSTEM_ID,
          MSII.SOURCE_SYSTEM_REFERENCE,
          MSII.COPY_ITEM_ID
        FROM
          MTL_SYSTEM_ITEMS_INTERFACE MSII,
          MTL_SYSTEM_ITEMS_B MSI,
          MTL_PARAMETERS MP
        WHERE MSII.SET_PROCESS_ID       = p_batch_id
          AND MSII.PROCESS_FLAG         = 1
          AND MSII.TRANSACTION_TYPE     = 'CREATE'
          AND MSII.COPY_ITEM_ID         = MSI.INVENTORY_ITEM_ID
          AND MSI.ORGANIZATION_ID       = MP.ORGANIZATION_ID
          AND MP.MASTER_ORGANIZATION_ID <> MP.ORGANIZATION_ID
          AND NOT EXISTS (SELECT NULL
                          FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2
                            WHERE MSII2.SET_PROCESS_ID  = MSII.SET_PROCESS_ID
                              AND MSII2.PROCESS_FLAG    = MSII.PROCESS_FLAG
                              AND (MSII2.ITEM_NUMBER    = MSII.ITEM_NUMBER OR MSII2.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID)
                              AND MSII2.ORGANIZATION_ID = MSI.ORGANIZATION_ID
                         );

        Debug_Conc_Log('Process_Copy_Options_For_Items: Done Copy Orgs., rowcount='||SQL%ROWCOUNT);
      END IF; -- IF l_copy_org = 'Y' THEN

      -- copying category assignments
      BEGIN
        SELECT NVL(SELECTION_FLAG, 'N') INTO l_copy_cat
        FROM EGO_IMPORT_COPY_OPTIONS
        WHERE BATCH_ID = p_batch_id
          --AND REQUEST_ID = l_request_id
          AND COPY_OPTION = 'COPY_CAT_ASSIGNMENTS';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_copy_cat := 'N';
      END;

      Debug_Conc_Log('Process_Copy_Options_For_Items: l_copy_cat='||l_copy_cat);
      IF l_copy_cat = 'Y' THEN
        Debug_Conc_Log('Process_Copy_Options_For_Items: Calling Copy_Category_Assignments');
        Copy_Category_Assignments( retcode      => l_ret_status
                                  ,errbuf       => l_err_msg
                                  ,p_batch_id   => p_batch_id
                                  ,p_skus_only  => 'N'
                                 );
        Debug_Conc_Log('Process_Copy_Options_For_Items: Done Copy_Category_Assignments with l_ret_status, l_err_msg='||l_ret_status||','||l_err_msg);
        IF l_ret_status > RETCODE THEN
          RETCODE := l_ret_status;
          ERRBUF := l_err_msg;
        END IF;
      END IF; -- IF l_copy_cat = 'Y' THEN

      -- copying intersections
      l_copy_sup := 'N';
      l_copy_sup_site := 'N';
      l_copy_sup_site_org := 'N';
      l_cntr := 1;
      FOR i IN ( SELECT COPY_OPTION, NVL(SELECTION_FLAG, 'N') SELECTION_FLAG
                 FROM EGO_IMPORT_COPY_OPTIONS
                 WHERE BATCH_ID = p_batch_id
                   AND COPY_OPTION IN ('COPY_SUPPLIER_ASSIGNMENTS',
                                       'COPY_SUPPLIER_SITE_ASSIGNMENTS',
                                       'COPY_SUPPLIER_SITE_ORG_ASSIGNMENTS')
               )
      LOOP
        IF i.COPY_OPTION = 'COPY_SUPPLIER_ASSIGNMENTS' THEN
          l_copy_sup := i.SELECTION_FLAG;
          IF l_copy_sup = 'Y' THEN
            l_data_level_names(l_cntr) := 'ITEM_SUP';
            l_cntr := l_cntr + 1;
          END IF;
        ELSIF i.COPY_OPTION = 'COPY_SUPPLIER_SITE_ASSIGNMENTS' THEN
          l_copy_sup_site := i.SELECTION_FLAG;
          IF l_copy_sup_site = 'Y' THEN
            l_data_level_names(l_cntr) := 'ITEM_SUP_SITE';
            l_cntr := l_cntr + 1;
          END IF;
        ELSIF i.COPY_OPTION = 'COPY_SUPPLIER_SITE_ORG_ASSIGNMENTS' THEN
          l_copy_sup_site_org := i.SELECTION_FLAG;
          IF l_copy_sup_site_org = 'Y' THEN
            l_data_level_names(l_cntr) := 'ITEM_SUP_SITE_ORG';
            l_cntr := l_cntr + 1;
          END IF;
        END IF;
      END LOOP;

      Debug_Conc_Log('Process_Copy_Options_For_Items: l_copy_sup,l_copy_sup_site,l_copy_sup_site_org='||l_copy_sup||','||l_copy_sup_site||','||l_copy_sup_site_org);
      IF (l_copy_sup = 'Y' OR l_copy_sup_site = 'Y' OR l_copy_sup_site_org = 'Y') THEN
        BEGIN
          SELECT COPY_ITEM_ID INTO l_src_item_id
          FROM MTL_SYSTEM_ITEMS_INTERFACE
          WHERE SET_PROCESS_ID = p_batch_id
            AND PROCESS_FLAG   = 1
            AND COPY_ITEM_ID   IS NOT NULL
            AND ROWNUM         = 1;

          Debug_Conc_Log('Process_Copy_Options_For_Items: l_src_item_id='||l_src_item_id);
          EGO_ITEM_ASSOCIATIONS_PUB.copy_associations_to_items
              (
                 p_api_version      => 1.0
                ,p_batch_id         => p_batch_id
                ,p_src_item_id      => l_src_item_id
                ,p_data_level_names => l_data_level_names
                ,x_return_status    => l_ret_status
                ,x_msg_count        => l_msg_count
                ,x_msg_data         => l_err_msg
              );
          Debug_Conc_Log('Process_Copy_Options_For_Items: Done EGO_ITEM_ASSOCIATIONS_PUB.copy_associations_to_items - l_return_status, l_msg_data='||l_ret_status||','||l_err_msg);
          IF l_ret_status = 'S' THEN
            RETCODE := '0';
            ERRBUF := NULL;
          ELSIF l_ret_status = 'E' THEN
            RETCODE := '1';
            ERRBUF := l_err_msg;
          ELSE
            RETCODE := '2';
            ERRBUF := l_err_msg;
            RETURN;
          END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          Debug_Conc_Log('Process_Copy_Options_For_Items: Done No Item found to copy from ');
          NULL;
        END;
      END IF; -- IF (l_copy_sup = 'Y' OR
    END IF; --IF p_copy_option_exists = 'N' THEN
    RETCODE := '0';
    ERRBUF := NULL;
    Debug_Conc_Log('Process_Copy_Options_For_Items: Done - retcode, errbuf='||retcode||','||errbuf);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Process_Copy_Options_For_Items: Error - retcode, errbuf='||retcode||','||errbuf);
  END Process_Copy_Options_For_Items;

  /*
   * This method does the defaulting of Supplier Intersections
   */
  PROCEDURE Default_Supplier_Intersections( retcode               OUT NOCOPY VARCHAR2
                                           ,errbuf                OUT NOCOPY VARCHAR2
                                           ,p_batch_id                       NUMBER
                                           ,p_msii_miri_process_flag  IN     NUMBER DEFAULT 1   -- Bug 12635842
                                          )
  IS
    l_return_status  VARCHAR2(10);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(4000);
  BEGIN
    -- call defaulting API for Supplier Intersections
    Debug_Conc_Log('Default_Supplier_Intersections: Starting copy_from_style_to_SKUs');
    EGO_ITEM_ASSOCIATIONS_PUB.copy_from_style_to_SKUs
      (
         p_api_version      => 1.0
        ,p_batch_id         => p_batch_id
        ,x_return_status    => l_return_status
        ,x_msg_count        => l_msg_count
        ,x_msg_data         => l_msg_data
        ,p_msii_miri_process_flag => p_msii_miri_process_flag    -- Bug 12635842
      );

    Debug_Conc_Log('Default_Supplier_Intersections: Done copy_from_style_to_SKUs - l_return_status, l_msg_data='||l_return_status||','||l_msg_data);
    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    Debug_Conc_Log('Default_Supplier_Intersections: Calling Copy_To_Packs');
    EGO_ITEM_ASSOCIATIONS_PUB.Copy_To_Packs
      (
         p_api_version      => 1.0
        ,p_batch_id         => p_batch_id
        ,x_return_status    => l_return_status
        ,x_msg_count        => l_msg_count
        ,x_msg_data         => l_msg_data
      );

    Debug_Conc_Log('Default_Supplier_Intersections: Done Copy_To_Packs - l_return_status, l_msg_data='||l_return_status||','||l_msg_data);
    IF l_return_status = 'S' AND RETCODE = '0' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' AND RETCODE IN ('0', '1') THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
    END IF;
    Debug_Conc_Log('Default_Supplier_Intersections: Done - l_return_status, l_msg_data='||RETCODE||','||ERRBUF);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Default_Supplier_Intersections: Error - retcode, errbuf='||retcode||','||errbuf);
  END Default_Supplier_Intersections;

  /*
   * This method does the defaulting of User Defined Attributes
   * at each data level from Production table
   */
  PROCEDURE Default_User_Attrs_From_Prod( retcode               OUT NOCOPY VARCHAR2
                                         ,errbuf                OUT NOCOPY VARCHAR2
                                         ,p_batch_id                       NUMBER
                                         ,p_msii_miri_process_flag  IN     NUMBER DEFAULT 1   -- Bug 12635842
                                        )
  IS
    CURSOR c_data_levels IS
      SELECT DATA_LEVEL_ID, DATA_LEVEL_NAME
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME IN ('ITEM_LEVEL', 'ITEM_ORG', 'ITEM_SUP', 'ITEM_SUP_SITE', 'ITEM_SUP_SITE_ORG', 'ITEM_REVISION_LEVEL');

    l_item_dl_id               NUMBER;
    l_item_org_dl_id           NUMBER;
    l_item_sup_dl_id           NUMBER;
    l_item_sup_site_dl_id      NUMBER;
    l_item_sup_site_org_dl_id  NUMBER;
    l_item_rev_dl_id           NUMBER;
    l_src_sql                  VARCHAR2(32000);
    l_ag_sql                   VARCHAR2(32000);
    l_dest_sql                 VARCHAR2(32000);
    l_join_condition           VARCHAR2(32000);
    l_return_status            VARCHAR2(10);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(4000);
    l_add_all_to_cm            VARCHAR2(1); --for ER 9489112
  BEGIN
    Debug_Conc_Log('Default_User_Attrs_From_Prod: Starting ');
    -- getting data level ids for all intersections into local variables
    FOR i IN c_data_levels LOOP
      IF i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_ORG' THEN
        l_item_org_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP' THEN
        l_item_sup_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE' THEN
        l_item_sup_site_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE_ORG' THEN
        l_item_sup_site_org_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_REVISION_LEVEL' THEN
        l_item_rev_dl_id := i.DATA_LEVEL_ID;
      END IF; -- IF i.DATA_LEVEL_NAME
    END LOOP; -- FOR i IN c_data_levels LOOP

    Debug_Conc_Log('Default_User_Attrs_From_Prod: After getting Data Level IDs');
    -- building SQLs for Defaulting of Item Level UDAs from Style to SKUs
    l_src_sql := q'#
                  SELECT
                    ROWNUM                     AS ROW_IDENTIFIER,
                    msii.INVENTORY_ITEM_ID     AS INVENTORY_ITEM_ID,
                    msii.ORGANIZATION_ID       AS ORGANIZATION_ID,
                    msii.SET_PROCESS_ID        AS DATA_SET_ID,
                    msii.ITEM_NUMBER,
                    msii.ORGANIZATION_CODE,
                    ext_prod.ITEM_CATALOG_GROUP_ID,
                    ext_prod.ATTR_GROUP_ID,
                    ext_prod.DATA_LEVEL_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    NULL AS PK1_VALUE,
                    NULL AS PK2_VALUE,
                    NULL AS PK3_VALUE,
                    NULL AS PK4_VALUE,
                    NULL AS PK5_VALUE,
                    NULL AS CHANGE_ID,
                    NULL AS CHANGE_LINE_ID,
                    msii.SOURCE_SYSTEM_ID,
                    msii.SOURCE_SYSTEM_REFERENCE,
                    msii.BUNDLE_ID,
                    msii.TRANSACTION_ID,
                    ext_prod.EXTENSION_ID, #' || G_PROD_COL_LIST || q'#
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
                    EGO_MTL_SY_ITEMS_EXT_VL ext_prod,
                    MTL_PARAMETERS mp
                  WHERE msii.STYLE_ITEM_FLAG   = 'N'
                    AND msii.SET_PROCESS_ID    = #' || p_batch_id || q'#
                    AND msii.TRANSACTION_TYPE  = 'CREATE'
                    AND msii.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                    AND msii.STYLE_ITEM_ID     = ext_prod.INVENTORY_ITEM_ID
                    AND msii.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                    AND msii.ORGANIZATION_ID   = mp.ORGANIZATION_ID
                    AND mp.ORGANIZATION_ID     = mp.MASTER_ORGANIZATION_ID
                    AND ext_prod.DATA_LEVEL_ID = #' || l_item_dl_id || q'#
                    AND EXISTS (SELECT NULL
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID         = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID         = ext_prod.DATA_LEVEL_ID
                                  AND NVL(eagd.DEFAULTING, 'D')  = 'D'
                               ) #';
    l_ag_sql := q'#
                  SELECT
                    ext_prod.ATTR_GROUP_ID
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
                    EGO_MTL_SY_ITEMS_EXT_B ext_prod,
                    MTL_PARAMETERS mp
                  WHERE msii.STYLE_ITEM_FLAG   = 'N'
                    AND msii.SET_PROCESS_ID    = #' || p_batch_id || q'#
                    AND msii.TRANSACTION_TYPE  = 'CREATE'
                    AND msii.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                    AND msii.STYLE_ITEM_ID     = ext_prod.INVENTORY_ITEM_ID
                    AND msii.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                    AND msii.ORGANIZATION_ID   = mp.ORGANIZATION_ID
                    AND mp.ORGANIZATION_ID     = mp.MASTER_ORGANIZATION_ID
                    AND ext_prod.DATA_LEVEL_ID = #' || l_item_dl_id || q'#
                    AND EXISTS (SELECT NULL
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID         = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID         = ext_prod.DATA_LEVEL_ID
                                  AND NVL(eagd.DEFAULTING, 'D')  = 'D'
                               ) #';

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Defaulting Item Level UDAs from Style to SKUs');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'F'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);
    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    -- building SQLs for Defaulting of Item Revision Level UDAs from Style to SKUs
    l_src_sql := q'#
                  SELECT
                    ROWNUM                     AS ROW_IDENTIFIER,
                    msii.INVENTORY_ITEM_ID     AS INVENTORY_ITEM_ID,
                    msii.ORGANIZATION_ID       AS ORGANIZATION_ID,
                    msii.SET_PROCESS_ID        AS DATA_SET_ID,
                    msii.ITEM_NUMBER,
                    msii.ORGANIZATION_CODE,
                    ext_prod.ITEM_CATALOG_GROUP_ID,
                    ext_prod.ATTR_GROUP_ID,
                    ext_prod.DATA_LEVEL_ID,
                    (SELECT MAX(miri.REVISION_ID) KEEP (DENSE_RANK FIRST ORDER BY miri.REVISION)
                     FROM MTL_ITEM_REVISIONS_INTERFACE miri
                     WHERE miri.INVENTORY_ITEM_ID = msii.INVENTORY_ITEM_ID
                       AND miri.ORGANIZATION_ID   = msii.ORGANIZATION_ID
                       AND miri.SET_PROCESS_ID    = msii.SET_PROCESS_ID
                       AND miri.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                    ) AS REVISION_ID,
                    NULL AS REVISION,
                    NULL AS PK1_VALUE,
                    NULL AS PK2_VALUE,
                    NULL AS PK3_VALUE,
                    NULL AS PK4_VALUE,
                    NULL AS PK5_VALUE,
                    NULL AS CHANGE_ID,
                    NULL AS CHANGE_LINE_ID,
                    msii.SOURCE_SYSTEM_ID,
                    msii.SOURCE_SYSTEM_REFERENCE,
                    msii.BUNDLE_ID,
                    msii.TRANSACTION_ID,
                    ext_prod.EXTENSION_ID, #' || G_PROD_COL_LIST || q'#
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
                    EGO_MTL_SY_ITEMS_EXT_VL ext_prod,
                    MTL_PARAMETERS mp
                  WHERE msii.STYLE_ITEM_FLAG   = 'N'
                    AND msii.SET_PROCESS_ID    = #' || p_batch_id || q'#
                    AND msii.TRANSACTION_TYPE  = 'CREATE'
                    AND msii.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                    AND msii.STYLE_ITEM_ID     = ext_prod.INVENTORY_ITEM_ID
                    AND msii.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                    AND msii.ORGANIZATION_ID   = mp.ORGANIZATION_ID
                    AND mp.ORGANIZATION_ID     = mp.MASTER_ORGANIZATION_ID
                    AND ext_prod.DATA_LEVEL_ID = #' || l_item_rev_dl_id || q'#
                    AND ext_prod.REVISION_ID   = (SELECT MAX(REVISION_ID)
                                                  FROM MTL_ITEM_REVISIONS_B mirb
                                                  WHERE mirb.EFFECTIVITY_DATE <= SYSDATE
                                                    AND mirb.INVENTORY_ITEM_ID = ext_prod.INVENTORY_ITEM_ID
                                                    AND mirb.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                                                 )
                    AND EXISTS (SELECT NULL
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID         = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID         = ext_prod.DATA_LEVEL_ID
                                  AND NVL(eagd.DEFAULTING, 'D')  = 'D'
                               ) #';

    l_ag_sql := q'#
                  SELECT
                    ext_prod.ATTR_GROUP_ID
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
                    EGO_MTL_SY_ITEMS_EXT_B ext_prod,
                    MTL_PARAMETERS mp
                  WHERE msii.STYLE_ITEM_FLAG   = 'N'
                    AND msii.SET_PROCESS_ID    = #' || p_batch_id || q'#
                    AND msii.TRANSACTION_TYPE  = 'CREATE'
                    AND msii.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                    AND msii.STYLE_ITEM_ID     = ext_prod.INVENTORY_ITEM_ID
                    AND msii.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                    AND msii.ORGANIZATION_ID   = mp.ORGANIZATION_ID
                    AND mp.ORGANIZATION_ID     = mp.MASTER_ORGANIZATION_ID
                    AND ext_prod.DATA_LEVEL_ID = #' || l_item_rev_dl_id || q'#
                    AND ext_prod.REVISION_ID   = (SELECT MAX(REVISION_ID)
                                                  FROM MTL_ITEM_REVISIONS_B mirb
                                                  WHERE mirb.EFFECTIVITY_DATE <= SYSDATE
                                                    AND mirb.INVENTORY_ITEM_ID = ext_prod.INVENTORY_ITEM_ID
                                                    AND mirb.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                                                 )
                    AND EXISTS (SELECT NULL
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID         = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID         = ext_prod.DATA_LEVEL_ID
                                  AND NVL(eagd.DEFAULTING, 'D')  = 'D'
                               ) #';

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Defaulting Item Revision Level UDAs from Style to SKUs');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'F'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);
    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    -- building SQLs for Defaulting of Item Revision Level UDAs for newly created revisions
    -- ER 9489112, only Defaulting of Item Rev level UDAs when Change Order enabled and AddAllItemToChangeOrder option = Y
    -- since java code will default Item Rev level UDAs later
    l_add_all_to_cm := EGO_IMPORT_PVT.getAddAllToChangeFlag(p_batch_id => p_batch_id);
    IF  l_add_all_to_cm <> 'Y' THEN
    l_src_sql := q'#
                  SELECT
                    ROWNUM                     AS ROW_IDENTIFIER,
                    miri.INVENTORY_ITEM_ID     AS INVENTORY_ITEM_ID,
                    miri.ORGANIZATION_ID       AS ORGANIZATION_ID,
                    miri.SET_PROCESS_ID        AS DATA_SET_ID,
                    miri.ITEM_NUMBER,
                    miri.ORGANIZATION_CODE,
                    ext_prod.ITEM_CATALOG_GROUP_ID,
                    ext_prod.ATTR_GROUP_ID,
                    ext_prod.DATA_LEVEL_ID,
                    miri.REVISION_ID,
                    miri.REVISION,
                    NULL AS PK1_VALUE,
                    NULL AS PK2_VALUE,
                    NULL AS PK3_VALUE,
                    NULL AS PK4_VALUE,
                    NULL AS PK5_VALUE,
                    NULL AS CHANGE_ID,
                    NULL AS CHANGE_LINE_ID,
                    miri.SOURCE_SYSTEM_ID,
                    miri.SOURCE_SYSTEM_REFERENCE,
                    NULL AS BUNDLE_ID,
                    miri.TRANSACTION_ID,
                    ext_prod.EXTENSION_ID, #' || G_PROD_COL_LIST || q'#
                  FROM MTL_ITEM_REVISIONS_INTERFACE miri,
                    EGO_MTL_SY_ITEMS_EXT_VL ext_prod
                  WHERE miri.SET_PROCESS_ID    = #' || p_batch_id || q'#
                    AND miri.TRANSACTION_TYPE  = 'CREATE'
                    AND miri.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                    AND miri.INVENTORY_ITEM_ID = ext_prod.INVENTORY_ITEM_ID
                    AND miri.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                    AND ext_prod.DATA_LEVEL_ID = #' || l_item_rev_dl_id || q'#
                    AND ext_prod.REVISION_ID   = (SELECT MAX(REVISION_ID)
                                                  FROM MTL_ITEM_REVISIONS_B mirb
                                                  WHERE mirb.EFFECTIVITY_DATE <= SYSDATE
                                                    AND mirb.INVENTORY_ITEM_ID = ext_prod.INVENTORY_ITEM_ID
                                                    AND mirb.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                                                 )
                    AND NOT EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                                    WHERE msii.SET_PROCESS_ID    = miri.SET_PROCESS_ID
                                      AND msii.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                                      AND msii.TRANSACTION_TYPE  = 'CREATE'
                                      AND msii.INVENTORY_ITEM_ID = miri.INVENTORY_ITEM_ID
                                      AND msii.ORGANIZATION_ID   = miri.ORGANIZATION_ID
                                   ) #';

    l_ag_sql := q'#
                  SELECT
                    ext_prod.ATTR_GROUP_ID
                  FROM MTL_ITEM_REVISIONS_INTERFACE miri,
                    EGO_MTL_SY_ITEMS_EXT_B ext_prod
                  WHERE miri.SET_PROCESS_ID    = #' || p_batch_id || q'#
                    AND miri.TRANSACTION_TYPE  = 'CREATE'
                    AND miri.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                    AND miri.INVENTORY_ITEM_ID = ext_prod.INVENTORY_ITEM_ID
                    AND miri.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                    AND ext_prod.DATA_LEVEL_ID = #' || l_item_rev_dl_id || q'#
                    AND ext_prod.REVISION_ID   = (SELECT MAX(REVISION_ID)
                                                  FROM MTL_ITEM_REVISIONS_B mirb
                                                  WHERE mirb.EFFECTIVITY_DATE <= SYSDATE
                                                    AND mirb.INVENTORY_ITEM_ID = ext_prod.INVENTORY_ITEM_ID
                                                    AND mirb.ORGANIZATION_ID   = ext_prod.ORGANIZATION_ID
                                                 )
                    AND NOT EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                                    WHERE msii.SET_PROCESS_ID    = miri.SET_PROCESS_ID
                                      AND msii.PROCESS_FLAG      = #' || p_msii_miri_process_flag || q'#
                                      AND msii.TRANSACTION_TYPE  = 'CREATE'
                                      AND msii.INVENTORY_ITEM_ID = miri.INVENTORY_ITEM_ID
                                      AND msii.ORGANIZATION_ID   = miri.ORGANIZATION_ID
                                   ) #';

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Defaulting Item Revision Level UDAs for newly created revisions-'||l_src_sql);

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'F'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);
    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;
    END IF; --l_add_all_to_cm <> 'Y'

    -- building SQLs for Defaulting of UDAs for Org Assignments (SKU + Style + Std. Item)
    -- 6468564 : Removed the check on msi.
    l_src_sql := q'#
                  SELECT
                    ROWNUM                          AS ROW_IDENTIFIER,
                    msii.INVENTORY_ITEM_ID          AS INVENTORY_ITEM_ID,
                    msii.ORGANIZATION_ID            AS ORGANIZATION_ID,
                    msii.SET_PROCESS_ID             AS DATA_SET_ID,
                    msii.ITEM_NUMBER,
                    msii.ORGANIZATION_CODE,
                    ext_prod.ITEM_CATALOG_GROUP_ID,
                    ext_prod.ATTR_GROUP_ID,
                    ext_prod.DATA_LEVEL_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    NULL AS PK1_VALUE,
                    NULL AS PK2_VALUE,
                    NULL AS PK3_VALUE,
                    NULL AS PK4_VALUE,
                    NULL AS PK5_VALUE,
                    NULL AS CHANGE_ID,
                    NULL AS CHANGE_LINE_ID,
                    msii.SOURCE_SYSTEM_ID,
                    msii.SOURCE_SYSTEM_REFERENCE,
                    msii.BUNDLE_ID,
                    msii.TRANSACTION_ID,
                    ext_prod.EXTENSION_ID, #' || G_PROD_COL_LIST || q'#
                  FROM
                    MTL_SYSTEM_ITEMS_INTERFACE msii,
                    EGO_MTL_SY_ITEMS_EXT_VL ext_prod,
                    MTL_PARAMETERS mp
                  WHERE msii.SET_PROCESS_ID   = #' || p_batch_id || q'#
                    AND msii.PROCESS_FLAG     = #' || p_msii_miri_process_flag || q'#
                    AND msii.TRANSACTION_TYPE = 'CREATE'
                    AND msii.ORGANIZATION_ID   = mp.ORGANIZATION_ID
                    AND ext_prod.DATA_LEVEL_ID = #' || l_item_org_dl_id || q'#
                    AND ext_prod.INVENTORY_ITEM_ID = NVL(msii.STYLE_ITEM_ID,msii.INVENTORY_ITEM_ID)
                    AND ext_prod.ORGANIZATION_ID   = NVL2(msii.STYLE_ITEM_ID,msii.ORGANIZATION_ID,mp.MASTER_ORGANIZATION_ID)
                    AND EXISTS (SELECT 1
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID           = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID           = ext_prod.DATA_LEVEL_ID
                                  AND ( NVL(eagd.DEFAULTING, 'D')  = 'D' OR msii.STYLE_ITEM_ID IS NULL )
                               )
                    AND NOT EXISTS (SELECT 1
                                    FROM EGO_FND_DSC_FLX_CTX_EXT fl_ctx
                                    WHERE fl_ctx.DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_ITEMMGMT_GROUP'
                                      AND fl_ctx.DESCRIPTIVE_FLEX_CONTEXT_CODE IN ('ItemDetailImage', 'ItemDetailDesc')
                                      AND ext_prod.ATTR_GROUP_ID = fl_ctx.ATTR_GROUP_ID
                                   )#';

    l_ag_sql := q'#
                  SELECT
                    ext_prod.ATTR_GROUP_ID
                  FROM
                    MTL_SYSTEM_ITEMS_INTERFACE msii,
                    EGO_MTL_SY_ITEMS_EXT_B ext_prod,
                    MTL_PARAMETERS mp
                  WHERE msii.SET_PROCESS_ID   = #' || p_batch_id || q'#
                    AND msii.PROCESS_FLAG     = #' || p_msii_miri_process_flag || q'#
                    AND msii.TRANSACTION_TYPE = 'CREATE'
                    AND msii.ORGANIZATION_ID   = mp.ORGANIZATION_ID
                    AND ext_prod.DATA_LEVEL_ID = #' || l_item_org_dl_id || q'#
                    AND ext_prod.INVENTORY_ITEM_ID = NVL(msii.STYLE_ITEM_ID,msii.INVENTORY_ITEM_ID)
                    AND ext_prod.ORGANIZATION_ID   = NVL2(msii.STYLE_ITEM_ID,msii.ORGANIZATION_ID,mp.MASTER_ORGANIZATION_ID)
                    AND EXISTS (SELECT 1
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID           = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID           = ext_prod.DATA_LEVEL_ID
                                  AND ( NVL(eagd.DEFAULTING, 'D')  = 'D' OR msii.STYLE_ITEM_ID IS NULL )
                               )
                    AND NOT EXISTS (SELECT 1
                                    FROM EGO_FND_DSC_FLX_CTX_EXT fl_ctx
                                    WHERE fl_ctx.DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_ITEMMGMT_GROUP'
                                      AND fl_ctx.DESCRIPTIVE_FLEX_CONTEXT_CODE IN ('ItemDetailImage', 'ItemDetailDesc')
                                      AND ext_prod.ATTR_GROUP_ID = fl_ctx.ATTR_GROUP_ID
                                   )#';

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Defaulting Item Org Level UDAs ');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'F'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    -- For Defaulting of UDAs for Item Supplier Intersections (SKU + Style + Std. Item), updating
    -- the Style_item_flag and Style_item_id in the associations interface table.
    Debug_Conc_Log('Default_User_Attrs_From_Prod: Updating Style_item_id, Style_item_flag in EGO_ITEM_ASSOCIATIONS_INTF');
    UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
    SET (STYLE_ITEM_FLAG, STYLE_ITEM_ID) = (SELECT
                                              msi.STYLE_ITEM_FLAG,
                                              msi.STYLE_ITEM_ID
                                            FROM MTL_SYSTEM_ITEMS_B msi, MTL_PARAMETERS mp
                                            WHERE msi.INVENTORY_ITEM_ID = eiai.INVENTORY_ITEM_ID
                                              AND eiai.ORGANIZATION_ID = mp.ORGANIZATION_ID
                                              AND msi.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID
                                           )
    WHERE eiai.BATCH_ID = p_batch_id
      AND eiai.PROCESS_FLAG = 1
      AND eiai.TRANSACTION_TYPE = 'CREATE'
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_B msi2, MTL_PARAMETERS mp2
                  WHERE msi2.INVENTORY_ITEM_ID = eiai.INVENTORY_ITEM_ID
                    AND eiai.ORGANIZATION_ID = mp2.ORGANIZATION_ID
                    AND msi2.ORGANIZATION_ID = mp2.MASTER_ORGANIZATION_ID
                  );

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
    SET (STYLE_ITEM_FLAG, STYLE_ITEM_ID) = (SELECT msii.STYLE_ITEM_FLAG , msii.STYLE_ITEM_ID
                                            FROM MTL_SYSTEM_ITEMS_INTERFACE msii, MTL_PARAMETERS mp
                                            WHERE msii.INVENTORY_ITEM_ID = eiai.INVENTORY_ITEM_ID
                                              AND eiai.ORGANIZATION_ID = mp.ORGANIZATION_ID
                                              AND msii.ORGANIZATION_ID = mp.MASTER_ORGANIZATION_ID
                                              AND msii.SET_PROCESS_ID = eiai.BATCH_ID
                                              AND msii.PROCESS_FLAG =  p_msii_miri_process_flag
                                              AND ROWNUM = 1)
    WHERE eiai.BATCH_ID = p_batch_id
      AND eiai.PROCESS_FLAG = 1
      AND eiai.TRANSACTION_TYPE = 'CREATE'
      AND EXISTS (SELECT 1
                  FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2, MTL_PARAMETERS mp2
                  WHERE MSII2.INVENTORY_ITEM_ID = eiai.INVENTORY_ITEM_ID
                    AND MSII2.ORGANIZATION_ID = mp2.MASTER_ORGANIZATION_ID
                    AND eiai.ORGANIZATION_ID = mp2.ORGANIZATION_ID
                    AND MSII2.SET_PROCESS_ID = eiai.BATCH_ID
                    AND MSII2.PROCESS_FLAG = p_msii_miri_process_flag );

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Updated Style_item_id, Style_item_flag in EGO_ITEM_ASSOCIATIONS_INTF');
    -- building SQLs for Defaulting of UDAs for Item Supplier Intersections (SKU + Style + Std. Item)
    l_src_sql := q'#
                  SELECT
                    ROWNUM                          AS ROW_IDENTIFIER,
                    eiai.INVENTORY_ITEM_ID          AS INVENTORY_ITEM_ID,
                    eiai.ORGANIZATION_ID            AS ORGANIZATION_ID,
                    eiai.BATCH_ID                   AS DATA_SET_ID,
                    eiai.ITEM_NUMBER,
                    eiai.ORGANIZATION_CODE,
                    ext_prod.ITEM_CATALOG_GROUP_ID,
                    ext_prod.ATTR_GROUP_ID,
                    eiai.DATA_LEVEL_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    eiai.PK1_VALUE,
                    eiai.PK2_VALUE,
                    eiai.PK3_VALUE,
                    eiai.PK4_VALUE,
                    eiai.PK5_VALUE,
                    NULL AS CHANGE_ID,
                    NULL AS CHANGE_LINE_ID,
                    eiai.SOURCE_SYSTEM_ID,
                    eiai.SOURCE_SYSTEM_REFERENCE,
                    eiai.BUNDLE_ID,
                    eiai.TRANSACTION_ID,
                    ext_prod.EXTENSION_ID, #' || G_PROD_COL_LIST || q'#
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_MTL_SY_ITEMS_EXT_VL ext_prod
                  WHERE eiai.BATCH_ID            = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE    = 'CREATE'
                    AND eiai.DATA_LEVEL_ID       = #' || l_item_sup_dl_id || q'#
                    AND eiai.PROCESS_FLAG        = 1
                    AND eiai.ORGANIZATION_ID     = ext_prod.ORGANIZATION_ID
                    AND (ext_prod.INVENTORY_ITEM_ID, ext_prod.DATA_LEVEL_ID, NVL(ext_prod.PK1_VALUE, -99)) IN
                                                 (SELECT
                                                    Nvl(MAX(eia.INVENTORY_ITEM_ID), eiai.INVENTORY_ITEM_ID),
                                                    NVL(MAX(eia.DATA_LEVEL_ID), #' || l_item_dl_id || q'#),
                                                    NVL(MAX(eia.PK1_VALUE), -99)
                                                  FROM EGO_ITEM_ASSOCIATIONS eia
                                                  WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                                    AND eia.ORGANIZATION_ID = eiai.ORGANIZATION_ID
                                                    AND eia.DATA_LEVEL_ID = #' || l_item_sup_dl_id || q'#
                                                    AND eia.PK1_VALUE = eiai.PK1_VALUE
                                                 )
                    AND EXISTS (SELECT 1
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID           = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID           = eiai.DATA_LEVEL_ID
                                  AND ( NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL )
                               ) #';

    l_ag_sql := q'#
                  SELECT
                    ext_prod.ATTR_GROUP_ID
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_MTL_SY_ITEMS_EXT_B ext_prod
                  WHERE eiai.BATCH_ID            = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE    = 'CREATE'
                    AND eiai.DATA_LEVEL_ID       = #' || l_item_sup_dl_id || q'#
                    AND eiai.PROCESS_FLAG        = 1
                    AND eiai.ORGANIZATION_ID     = ext_prod.ORGANIZATION_ID
                    AND (ext_prod.INVENTORY_ITEM_ID, ext_prod.DATA_LEVEL_ID, NVL(ext_prod.PK1_VALUE, -99)) IN
                                                 (SELECT
                                                    Nvl(MAX(eia.INVENTORY_ITEM_ID), eiai.INVENTORY_ITEM_ID),
                                                    NVL(MAX(eia.DATA_LEVEL_ID), #' || l_item_dl_id || q'#),
                                                    NVL(MAX(eia.PK1_VALUE), -99)
                                                  FROM EGO_ITEM_ASSOCIATIONS eia
                                                  WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                                    AND eia.ORGANIZATION_ID = eiai.ORGANIZATION_ID
                                                    AND eia.DATA_LEVEL_ID = #' || l_item_sup_dl_id || q'#
                                                    AND eia.PK1_VALUE = eiai.PK1_VALUE
                                                 )
                    AND EXISTS (SELECT 1
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID           = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID           = eiai.DATA_LEVEL_ID
                                  AND ( NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL )
                               ) #';

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Defaulting Item Supplier Level UDAs ');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'F'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    -- building SQLs for Defaulting of UDAs for Item Supplier Site Intersections (SKU + Style + Std. Item)
    l_src_sql := q'#
                  SELECT
                    ROWNUM                          AS ROW_IDENTIFIER,
                    eiai.INVENTORY_ITEM_ID          AS INVENTORY_ITEM_ID,
                    eiai.ORGANIZATION_ID            AS ORGANIZATION_ID,
                    eiai.BATCH_ID                   AS DATA_SET_ID,
                    eiai.ITEM_NUMBER,
                    eiai.ORGANIZATION_CODE,
                    ext_prod.ITEM_CATALOG_GROUP_ID,
                    ext_prod.ATTR_GROUP_ID,
                    eiai.DATA_LEVEL_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    eiai.PK1_VALUE,
                    eiai.PK2_VALUE,
                    eiai.PK3_VALUE,
                    eiai.PK4_VALUE,
                    eiai.PK5_VALUE,
                    NULL AS CHANGE_ID,
                    NULL AS CHANGE_LINE_ID,
                    eiai.SOURCE_SYSTEM_ID,
                    eiai.SOURCE_SYSTEM_REFERENCE,
                    eiai.BUNDLE_ID,
                    eiai.TRANSACTION_ID,
                    ext_prod.EXTENSION_ID, #' || G_PROD_COL_LIST || q'#
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_MTL_SY_ITEMS_EXT_VL ext_prod
                  WHERE eiai.BATCH_ID            = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE    = 'CREATE'
                    AND eiai.DATA_LEVEL_ID       = #' || l_item_sup_site_dl_id || q'#
                    AND eiai.PROCESS_FLAG        = 1
                    AND eiai.ORGANIZATION_ID     = ext_prod.ORGANIZATION_ID
                    AND (ext_prod.INVENTORY_ITEM_ID,
                         ext_prod.DATA_LEVEL_ID,
                         ext_prod.PK1_VALUE,
                         NVL(ext_prod.PK2_VALUE, -99)) IN
                                                 (SELECT
                                                    NVL(MAX(eia.INVENTORY_ITEM_ID), eiai.INVENTORY_ITEM_ID),
                                                    NVL(MAX(eia.DATA_LEVEL_ID), #' || l_item_sup_dl_id || q'#),
                                                    NVL(MAX(eia.PK1_VALUE), eiai.PK1_VALUE),
                                                    NVL(MAX(eia.PK2_VALUE), -99)
                                                  FROM EGO_ITEM_ASSOCIATIONS eia
                                                  WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                                    AND eia.ORGANIZATION_ID = eiai.ORGANIZATION_ID
                                                    AND eia.DATA_LEVEL_ID = #' || l_item_sup_site_dl_id || q'#
                                                    AND eia.PK1_VALUE = eiai.PK1_VALUE
                                                    AND eia.PK2_VALUE = eiai.PK2_VALUE
                                                 )
                    AND EXISTS (SELECT 1
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID           = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID           = eiai.DATA_LEVEL_ID
                                  AND ( NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL )
                               ) #';

    l_ag_sql := q'#
                  SELECT
                    ext_prod.ATTR_GROUP_ID
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_MTL_SY_ITEMS_EXT_B ext_prod
                  WHERE eiai.BATCH_ID            = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE    = 'CREATE'
                    AND eiai.DATA_LEVEL_ID       = #' || l_item_sup_site_dl_id || q'#
                    AND eiai.PROCESS_FLAG        = 1
                    AND eiai.ORGANIZATION_ID     = ext_prod.ORGANIZATION_ID
                    AND (ext_prod.INVENTORY_ITEM_ID,
                         ext_prod.DATA_LEVEL_ID,
                         ext_prod.PK1_VALUE,
                         NVL(ext_prod.PK2_VALUE, -99)) IN
                                                 (SELECT
                                                    NVL(MAX(eia.INVENTORY_ITEM_ID), eiai.INVENTORY_ITEM_ID),
                                                    NVL(MAX(eia.DATA_LEVEL_ID), #' || l_item_sup_dl_id || q'#),
                                                    NVL(MAX(eia.PK1_VALUE), eiai.PK1_VALUE),
                                                    NVL(MAX(eia.PK2_VALUE), -99)
                                                  FROM EGO_ITEM_ASSOCIATIONS eia
                                                  WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                                    AND eia.ORGANIZATION_ID = eiai.ORGANIZATION_ID
                                                    AND eia.DATA_LEVEL_ID = #' || l_item_sup_site_dl_id || q'#
                                                    AND eia.PK1_VALUE = eiai.PK1_VALUE
                                                    AND eia.PK2_VALUE = eiai.PK2_VALUE
                                                 )
                    AND EXISTS (SELECT 1
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID           = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID           = eiai.DATA_LEVEL_ID
                                  AND ( NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL )
                               ) #';

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Defaulting Item Supplier Site Level UDAs');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'F'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    -- building SQLs for Defaulting of UDAs for Item Supplier Site Org Intersections (SKU + Style + Std. Item)
    l_src_sql := q'#
                  SELECT
                    ROWNUM                          AS ROW_IDENTIFIER,
                    eiai.INVENTORY_ITEM_ID          AS INVENTORY_ITEM_ID,
                    eiai.ORGANIZATION_ID            AS ORGANIZATION_ID,
                    eiai.BATCH_ID                   AS DATA_SET_ID,
                    eiai.ITEM_NUMBER,
                    eiai.ORGANIZATION_CODE,
                    ext_prod.ITEM_CATALOG_GROUP_ID,
                    ext_prod.ATTR_GROUP_ID,
                    eiai.DATA_LEVEL_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    eiai.PK1_VALUE,
                    eiai.PK2_VALUE,
                    eiai.PK3_VALUE,
                    eiai.PK4_VALUE,
                    eiai.PK5_VALUE,
                    NULL AS CHANGE_ID,
                    NULL AS CHANGE_LINE_ID,
                    eiai.SOURCE_SYSTEM_ID,
                    eiai.SOURCE_SYSTEM_REFERENCE,
                    eiai.BUNDLE_ID,
                    eiai.TRANSACTION_ID,
                    ext_prod.EXTENSION_ID, #' || G_PROD_COL_LIST || q'#
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_MTL_SY_ITEMS_EXT_VL ext_prod,
                    MTL_PARAMETERS mp
                  WHERE eiai.BATCH_ID              = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE      = 'CREATE'
                    AND eiai.DATA_LEVEL_ID         = #' || l_item_sup_site_org_dl_id || q'#
                    AND eiai.PROCESS_FLAG          = 1
                    AND ext_prod.INVENTORY_ITEM_ID = NVL(eiai.STYLE_ITEM_ID, eiai.INVENTORY_ITEM_ID)
                    AND eiai.ORGANIZATION_ID       = mp.ORGANIZATION_ID
                    AND (ext_prod.INVENTORY_ITEM_ID,
                         ext_prod.DATA_LEVEL_ID,
                         ext_prod.PK1_VALUE,
                         ext_prod.PK2_VALUE,
                         ext_prod.ORGANIZATION_ID) IN
                                                 (SELECT
                                                    NVL(MAX(eia.INVENTORY_ITEM_ID), eiai.INVENTORY_ITEM_ID),
                                                    NVL(MAX(eia.DATA_LEVEL_ID), #' || l_item_sup_site_dl_id || q'#),
                                                    NVL(MAX(eia.PK1_VALUE), eiai.PK1_VALUE),
                                                    NVL(MAX(eia.PK2_VALUE), eiai.PK2_VALUE),
                                                    DECODE(MAX(eia.DATA_LEVEL_ID), NULL, mp.MASTER_ORGANIZATION_ID, eiai.ORGANIZATION_ID)
                                                  FROM EGO_ITEM_ASSOCIATIONS eia
                                                  WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                                    AND eia.ORGANIZATION_ID = eiai.ORGANIZATION_ID
                                                    AND eia.DATA_LEVEL_ID = #' || l_item_sup_site_org_dl_id || q'#
                                                    AND eia.PK1_VALUE = eiai.PK1_VALUE
                                                    AND eia.PK2_VALUE = eiai.PK2_VALUE
                                                 )
                    AND EXISTS (SELECT 1
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID           = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID           = eiai.DATA_LEVEL_ID
                                  AND ( NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL )
                               ) #';

    l_ag_sql := q'#
                  SELECT
                    ext_prod.ATTR_GROUP_ID
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_MTL_SY_ITEMS_EXT_B ext_prod,
                    MTL_PARAMETERS mp
                  WHERE eiai.BATCH_ID              = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE      = 'CREATE'
                    AND eiai.DATA_LEVEL_ID         = #' || l_item_sup_site_org_dl_id || q'#
                    AND eiai.PROCESS_FLAG          = 1
                    AND ext_prod.INVENTORY_ITEM_ID = NVL(eiai.STYLE_ITEM_ID, eiai.INVENTORY_ITEM_ID)
                    AND eiai.ORGANIZATION_ID       = mp.ORGANIZATION_ID
                    AND (ext_prod.INVENTORY_ITEM_ID,
                         ext_prod.DATA_LEVEL_ID,
                         ext_prod.PK1_VALUE,
                         ext_prod.PK2_VALUE,
                         ext_prod.ORGANIZATION_ID) IN
                                                 (SELECT
                                                    NVL(MAX(eia.INVENTORY_ITEM_ID), eiai.INVENTORY_ITEM_ID),
                                                    NVL(MAX(eia.DATA_LEVEL_ID), #' || l_item_sup_site_dl_id || q'#),
                                                    NVL(MAX(eia.PK1_VALUE), eiai.PK1_VALUE),
                                                    NVL(MAX(eia.PK2_VALUE), eiai.PK2_VALUE),
                                                    DECODE(MAX(eia.DATA_LEVEL_ID), NULL, mp.MASTER_ORGANIZATION_ID, eiai.ORGANIZATION_ID)
                                                  FROM EGO_ITEM_ASSOCIATIONS eia
                                                  WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                                    AND eia.ORGANIZATION_ID = eiai.ORGANIZATION_ID
                                                    AND eia.DATA_LEVEL_ID = #' || l_item_sup_site_org_dl_id || q'#
                                                    AND eia.PK1_VALUE = eiai.PK1_VALUE
                                                    AND eia.PK2_VALUE = eiai.PK2_VALUE
                                                 )
                    AND EXISTS (SELECT 1
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID           = ext_prod.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID           = eiai.DATA_LEVEL_ID
                                  AND ( NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL )
                               ) #';

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Defaulting Item Supplier Site Org Level UDAs');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'F'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE   -- FND_API.G_TRUE   -- Bug 9678667
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Prod: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;
    Debug_Conc_Log('Default_User_Attrs_From_Prod: Done - retcode, errbuf='||retcode||','||errbuf);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Default_User_Attrs_From_Prod: Error - retcode, errbuf='||retcode||','||errbuf);
  END Default_User_Attrs_From_Prod;

  /*
   * This method does the defaulting of User Defined Attributes
   * at each data level from Interface table
   */
  PROCEDURE Default_User_Attrs_From_Intf( retcode               OUT NOCOPY VARCHAR2
                                         ,errbuf                OUT NOCOPY VARCHAR2
                                         ,p_batch_id                       NUMBER
                                        )
  IS
    CURSOR c_data_levels IS
      SELECT DATA_LEVEL_ID, DATA_LEVEL_NAME
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME IN ('ITEM_LEVEL', 'ITEM_ORG', 'ITEM_SUP', 'ITEM_SUP_SITE', 'ITEM_SUP_SITE_ORG');

    l_item_dl_id               NUMBER;
    l_item_org_dl_id           NUMBER;
    l_item_sup_dl_id           NUMBER;
    l_item_sup_site_dl_id      NUMBER;
    l_item_sup_site_org_dl_id  NUMBER;
    l_src_sql                  VARCHAR2(32000);
    l_ag_sql                   VARCHAR2(32000);
    l_dest_sql                 VARCHAR2(32000);
    l_join_condition           VARCHAR2(32000);
    l_return_status            VARCHAR2(10);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(4000);
  BEGIN
    Debug_Conc_Log('Default_User_Attrs_From_Intf: Starting ');
    -- getting data level ids for all intersections into local variables
    FOR i IN c_data_levels LOOP
      IF i.DATA_LEVEL_NAME = 'ITEM_LEVEL' THEN
        l_item_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_ORG' THEN
        l_item_org_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP' THEN
        l_item_sup_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE' THEN
        l_item_sup_site_dl_id := i.DATA_LEVEL_ID;
      ELSIF i.DATA_LEVEL_NAME = 'ITEM_SUP_SITE_ORG' THEN
        l_item_sup_site_org_dl_id := i.DATA_LEVEL_ID;
      END IF; -- IF i.DATA_LEVEL_NAME
    END LOOP; -- FOR i IN c_data_levels LOOP

    Debug_Conc_Log('Default_User_Attrs_From_Intf: After getting Data Level IDs');

    -- building SQLs for Defaulting of UDAs for Org Assignments (Style + Std. Item)
    -- fix for bug#9660659
    l_src_sql := q'#
                  SELECT /*+ leading(msii) use_nl_with_index(ext_intf, EGO_ITM_USR_ATTR_INTRFC_N2) */
                    ext_intf.TRANSACTION_ID,
                    msii.SET_PROCESS_ID AS DATA_SET_ID,
                    msii.ORGANIZATION_ID,
                    msii.ORGANIZATION_CODE,
                    msii.INVENTORY_ITEM_ID,
                    msii.ITEM_NUMBER,
                    ext_intf.ITEM_CATALOG_GROUP_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    NULL AS PK1_VALUE,
                    NULL AS PK2_VALUE,
                    NULL AS PK3_VALUE,
                    NULL AS PK4_VALUE,
                    NULL AS PK5_VALUE,
                    ext_intf.ROW_IDENTIFIER + msii.ORGANIZATION_ID AS ROW_IDENTIFIER,
                    ext_intf.ATTR_GROUP_TYPE,
                    ext_intf.ATTR_GROUP_INT_NAME,
                    ext_intf.ATTR_GROUP_ID,
                    ext_intf.ATTR_INT_NAME,
                    ext_intf.ATTR_VALUE_STR,
                    ext_intf.ATTR_VALUE_NUM,
                    ext_intf.ATTR_VALUE_DATE,
                    ext_intf.ATTR_VALUE_UOM,
                    ext_intf.CHANGE_ID,
                    ext_intf.CHANGE_LINE_ID,
                    ext_intf.SOURCE_SYSTEM_ID,
                    ext_intf.SOURCE_SYSTEM_REFERENCE,
                    ext_intf.BUNDLE_ID,
                    ext_intf.DATA_LEVEL_ID
                  FROM
                    MTL_SYSTEM_ITEMS_INTERFACE msii,
                    EGO_ITM_USR_ATTR_INTRFC ext_intf,
                    MTL_PARAMETERS mp,
                    EGO_FND_DSC_FLX_CTX_EXT ag_ext
                  WHERE msii.SET_PROCESS_ID                  = #' || p_batch_id || q'#
                    AND msii.PROCESS_FLAG                    = 1
                    AND msii.TRANSACTION_TYPE                = 'CREATE'
                    AND msii.STYLE_ITEM_ID                   IS NULL
                    AND EXISTS (SELECT /*+ push_subq */ 1 FROM MTL_PARAMETERS mp1
                                WHERE mp1.ORGANIZATION_ID = msii.ORGANIZATION_ID
                                  AND mp1.ORGANIZATION_ID <> mp1.MASTER_ORGANIZATION_ID
                               )
                    AND msii.ORGANIZATION_ID                 = mp.ORGANIZATION_ID
                    AND msii.SET_PROCESS_ID                  = ext_intf.DATA_SET_ID
                    AND ext_intf.PROCESS_STATUS              in (1,2)  /* Bug 9923555 */
                    AND ext_intf.INVENTORY_ITEM_ID           = msii.INVENTORY_ITEM_ID
                    AND ext_intf.ORGANIZATION_ID             = mp.MASTER_ORGANIZATION_ID
                    AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(ext_intf.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                    AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = ext_intf.ATTR_GROUP_INT_NAME
                    AND ag_ext.APPLICATION_ID                = 431
                    AND NVL(ag_ext.VARIANT, 'N')             = 'N'
                    AND ext_intf.DATA_LEVEL_ID               = #' || l_item_org_dl_id;

    -- when copying from interface to interface, we do not need l_ag_sql, so passing dummy value
    l_ag_sql := 'SELECT NULL AS ATTR_GROUP_ID FROM DUAL WHERE 1 = 2';
    Debug_Conc_Log('Default_User_Attrs_From_Intf: Defaulting Item Org Level UDAs');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'T'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Intf: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    -- building SQLs for Defaulting of UDAs for Item Supplier Intersections (SKU + Style + Std. Item)
    l_src_sql := q'#
                  SELECT
                    ext_intf.TRANSACTION_ID,
                    eiai.BATCH_ID AS DATA_SET_ID,
                    eiai.ORGANIZATION_ID,
                    eiai.ORGANIZATION_CODE,
                    eiai.INVENTORY_ITEM_ID,
                    eiai.ITEM_NUMBER,
                    ext_intf.ITEM_CATALOG_GROUP_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    eiai.PK1_VALUE,
                    eiai.PK2_VALUE,
                    eiai.PK3_VALUE,
                    eiai.PK4_VALUE,
                    eiai.PK5_VALUE,
                    ext_intf.ROW_IDENTIFIER + eiai.PK1_VALUE AS ROW_IDENTIFIER,
                    ext_intf.ATTR_GROUP_TYPE,
                    ext_intf.ATTR_GROUP_INT_NAME,
                    ext_intf.ATTR_GROUP_ID,
                    ext_intf.ATTR_INT_NAME,
                    ext_intf.ATTR_VALUE_STR,
                    ext_intf.ATTR_VALUE_NUM,
                    ext_intf.ATTR_VALUE_DATE,
                    ext_intf.ATTR_VALUE_UOM,
                    ext_intf.CHANGE_ID,
                    ext_intf.CHANGE_LINE_ID,
                    ext_intf.SOURCE_SYSTEM_ID,
                    ext_intf.SOURCE_SYSTEM_REFERENCE,
                    ext_intf.BUNDLE_ID,
                    eiai.DATA_LEVEL_ID
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_ITM_USR_ATTR_INTRFC ext_intf,
                    EGO_FND_DSC_FLX_CTX_EXT ag_ext
                  WHERE eiai.BATCH_ID                        = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE                = 'CREATE'
                    AND eiai.DATA_LEVEL_ID                   = #' || l_item_sup_dl_id || q'#
                    AND eiai.PROCESS_FLAG                    = 1
                    AND eiai.BATCH_ID                        = ext_intf.DATA_SET_ID
                    AND ext_intf.PROCESS_STATUS              in (1,2)  /* Bug 9923555 */
                    AND eiai.INVENTORY_ITEM_ID               = ext_intf.INVENTORY_ITEM_ID
                    AND eiai.ORGANIZATION_ID                 = ext_intf.ORGANIZATION_ID
                    AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(ext_intf.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                    AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = ext_intf.ATTR_GROUP_INT_NAME
                    AND ag_ext.APPLICATION_ID                = 431
                    AND NVL(ag_ext.VARIANT, 'N')             = 'N'
                    AND ext_intf.DATA_LEVEL_ID               = #' || l_item_dl_id || q'#
                    AND EXISTS (SELECT NULL
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID         = ag_ext.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID         = #' || l_item_sup_dl_id || q'#
                                  AND (NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL)
                               )
                    AND NOT EXISTS (SELECT NULL
                                    FROM EGO_ITEM_ASSOCIATIONS eia
                                    WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                      AND eia.ORGANIZATION_ID   = eiai.ORGANIZATION_ID
                                      AND eia.DATA_LEVEL_ID     = #' || l_item_sup_dl_id || q'#
                                      AND eia.PK1_VALUE         = eiai.PK1_VALUE
                                   )#';

    -- when copying from interface to interface, we do not need l_ag_sql, so passing dummy value
    l_ag_sql := 'SELECT NULL AS ATTR_GROUP_ID FROM DUAL WHERE 1 = 2';
    Debug_Conc_Log('Default_User_Attrs_From_Intf: Defaulting Item Supplier Level UDAs');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'T'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Intf: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    -- building SQLs for Defaulting of UDAs for Item Supplier Site Intersections (SKU + Style + Std. Item)
    l_src_sql := q'#
                  SELECT
                    ext_intf.TRANSACTION_ID,
                    eiai.BATCH_ID AS DATA_SET_ID,
                    eiai.ORGANIZATION_ID,
                    eiai.ORGANIZATION_CODE,
                    eiai.INVENTORY_ITEM_ID,
                    eiai.ITEM_NUMBER,
                    ext_intf.ITEM_CATALOG_GROUP_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    eiai.PK1_VALUE,
                    eiai.PK2_VALUE,
                    eiai.PK3_VALUE,
                    eiai.PK4_VALUE,
                    eiai.PK5_VALUE,
                    ext_intf.ROW_IDENTIFIER + eiai.PK2_VALUE AS ROW_IDENTIFIER,
                    ext_intf.ATTR_GROUP_TYPE,
                    ext_intf.ATTR_GROUP_INT_NAME,
                    ext_intf.ATTR_GROUP_ID,
                    ext_intf.ATTR_INT_NAME,
                    ext_intf.ATTR_VALUE_STR,
                    ext_intf.ATTR_VALUE_NUM,
                    ext_intf.ATTR_VALUE_DATE,
                    ext_intf.ATTR_VALUE_UOM,
                    ext_intf.CHANGE_ID,
                    ext_intf.CHANGE_LINE_ID,
                    ext_intf.SOURCE_SYSTEM_ID,
                    ext_intf.SOURCE_SYSTEM_REFERENCE,
                    ext_intf.BUNDLE_ID,
                    eiai.DATA_LEVEL_ID
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_ITM_USR_ATTR_INTRFC ext_intf,
                    EGO_FND_DSC_FLX_CTX_EXT ag_ext
                  WHERE eiai.BATCH_ID                        = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE                = 'CREATE'
                    AND eiai.DATA_LEVEL_ID                   = #' || l_item_sup_site_dl_id || q'#
                    AND eiai.PROCESS_FLAG                    = 1
                    AND eiai.BATCH_ID                        = ext_intf.DATA_SET_ID
                    AND ext_intf.PROCESS_STATUS              in (1,2)  /* Bug 9923555 */
                    AND eiai.INVENTORY_ITEM_ID               = ext_intf.INVENTORY_ITEM_ID
                    AND eiai.ORGANIZATION_ID                 = ext_intf.ORGANIZATION_ID
                    AND ext_intf.DATA_LEVEL_ID               = #' || l_item_sup_dl_id || q'#
                    AND ext_intf.PK1_VALUE                   = eiai.PK1_VALUE
                    AND ext_intf.PK2_VALUE                   IS NULL
                    AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(ext_intf.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                    AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = ext_intf.ATTR_GROUP_INT_NAME
                    AND ag_ext.APPLICATION_ID                = 431
                    AND NVL(ag_ext.VARIANT, 'N')             = 'N'
                    AND EXISTS (SELECT NULL
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID         = ag_ext.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID         = #' || l_item_sup_site_dl_id || q'#
                                  AND (NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL)
                               )
                    AND NOT EXISTS (SELECT NULL
                                    FROM EGO_ITEM_ASSOCIATIONS eia
                                    WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                      AND eia.ORGANIZATION_ID   = eiai.ORGANIZATION_ID
                                      AND eia.DATA_LEVEL_ID     = #' || l_item_sup_site_dl_id || q'#
                                      AND eia.PK1_VALUE         = eiai.PK1_VALUE
                                      AND eia.PK2_VALUE         = eiai.PK2_VALUE
                                   )#';

    -- when copying from interface to interface, we do not need l_ag_sql, so passing dummy value
    l_ag_sql := 'SELECT NULL AS ATTR_GROUP_ID FROM DUAL WHERE 1 = 2';
    Debug_Conc_Log('Default_User_Attrs_From_Intf: Defaulting Item Supplier Site Level UDAs');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'T'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Intf: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;

    -- building SQLs for Defaulting of UDAs for Item Supplier Site Org Intersections (SKU + Style + Std. Item)
    l_src_sql := q'#
                  SELECT
                    ext_intf.TRANSACTION_ID,
                    eiai.BATCH_ID AS DATA_SET_ID,
                    eiai.ORGANIZATION_ID,
                    eiai.ORGANIZATION_CODE,
                    eiai.INVENTORY_ITEM_ID,
                    eiai.ITEM_NUMBER,
                    ext_intf.ITEM_CATALOG_GROUP_ID,
                    NULL AS REVISION_ID,
                    NULL AS REVISION,
                    eiai.PK1_VALUE,
                    eiai.PK2_VALUE,
                    eiai.PK3_VALUE,
                    eiai.PK4_VALUE,
                    eiai.PK5_VALUE,
                    ext_intf.ROW_IDENTIFIER + eiai.PK2_VALUE + eiai.ORGANIZATION_ID AS ROW_IDENTIFIER,
                    ext_intf.ATTR_GROUP_TYPE,
                    ext_intf.ATTR_GROUP_INT_NAME,
                    ext_intf.ATTR_GROUP_ID,
                    ext_intf.ATTR_INT_NAME,
                    ext_intf.ATTR_VALUE_STR,
                    ext_intf.ATTR_VALUE_NUM,
                    ext_intf.ATTR_VALUE_DATE,
                    ext_intf.ATTR_VALUE_UOM,
                    ext_intf.CHANGE_ID,
                    ext_intf.CHANGE_LINE_ID,
                    ext_intf.SOURCE_SYSTEM_ID,
                    ext_intf.SOURCE_SYSTEM_REFERENCE,
                    ext_intf.BUNDLE_ID,
                    eiai.DATA_LEVEL_ID
                  FROM
                    EGO_ITEM_ASSOCIATIONS_INTF eiai,
                    EGO_ITM_USR_ATTR_INTRFC ext_intf,
                    MTL_PARAMETERS mp,
                    EGO_FND_DSC_FLX_CTX_EXT ag_ext
                  WHERE eiai.BATCH_ID                        = #' || p_batch_id || q'#
                    AND eiai.TRANSACTION_TYPE                = 'CREATE'
                    AND eiai.DATA_LEVEL_ID                   = #' || l_item_sup_site_org_dl_id || q'#
                    AND eiai.PROCESS_FLAG                    = 1
                    AND eiai.BATCH_ID                        = ext_intf.DATA_SET_ID
                    AND ext_intf.PROCESS_STATUS              in (1,2)  /* Bug 9923555 */
                    AND eiai.INVENTORY_ITEM_ID               = ext_intf.INVENTORY_ITEM_ID
                    AND eiai.ORGANIZATION_ID                 = mp.ORGANIZATION_ID
                    AND mp.MASTER_ORGANIZATION_ID            = ext_intf.ORGANIZATION_ID
                    AND ext_intf.DATA_LEVEL_ID               = #' || l_item_sup_site_dl_id || q'#
                    AND ext_intf.PK1_VALUE                   = eiai.PK1_VALUE
                    AND ext_intf.PK2_VALUE                   = eiai.PK2_VALUE
                    AND ag_ext.DESCRIPTIVE_FLEXFIELD_NAME    = NVL(ext_intf.ATTR_GROUP_TYPE, 'EGO_ITEMMGMT_GROUP')
                    AND ag_ext.DESCRIPTIVE_FLEX_CONTEXT_CODE = ext_intf.ATTR_GROUP_INT_NAME
                    AND ag_ext.APPLICATION_ID                = 431
                    AND NVL(ag_ext.VARIANT, 'N')             = 'N'
                    AND EXISTS (SELECT NULL
                                FROM EGO_ATTR_GROUP_DL eagd
                                WHERE eagd.ATTR_GROUP_ID         = ag_ext.ATTR_GROUP_ID
                                  AND eagd.DATA_LEVEL_ID         = #' || l_item_sup_site_org_dl_id || q'#
                                  AND (NVL(eagd.DEFAULTING, 'D')  = 'D' OR eiai.STYLE_ITEM_ID IS NULL)
                               )
                    AND NOT EXISTS (SELECT NULL
                                    FROM EGO_ITEM_ASSOCIATIONS eia
                                    WHERE eia.INVENTORY_ITEM_ID = eiai.STYLE_ITEM_ID
                                      AND eia.ORGANIZATION_ID   = eiai.ORGANIZATION_ID
                                      AND eia.DATA_LEVEL_ID     = #' || l_item_sup_site_org_dl_id || q'#
                                      AND eia.PK1_VALUE         = eiai.PK1_VALUE
                                      AND eia.PK2_VALUE         = eiai.PK2_VALUE
                                   )#';

    -- when copying from interface to interface, we do not need l_ag_sql, so passing dummy value
    l_ag_sql := 'SELECT NULL AS ATTR_GROUP_ID FROM DUAL WHERE 1 = 2';
    Debug_Conc_Log('Default_User_Attrs_From_Intf: Defaulting Item Supplier Site Org Level UDAs');

    EGO_ITEM_USER_ATTRS_CP_PUB.Copy_data_to_Intf
      (
         p_api_version               => 1.0
        ,p_commit                    => 'F'
        ,p_copy_from_intf_table      => 'T'
        ,p_source_entity_sql         => l_src_sql
        ,p_source_attr_groups_sql    => l_ag_sql
        ,p_dest_process_status       => '2'
        ,p_dest_data_set_id          => p_batch_id
        ,p_dest_transaction_type     => 'CREATE'
        ,p_cleanup_row_identifiers   => FND_API.G_FALSE    -- FND_API.G_TRUE   -- Bug 9678667
        ,x_return_status             => l_return_status
        ,x_msg_count                 => l_msg_count
        ,x_msg_data                  => l_msg_data
      );

    Debug_Conc_Log('Default_User_Attrs_From_Intf: Copy API returned with l_return_status, l_msg_data-'|| l_return_status || ',' || l_msg_data);

    IF l_return_status = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    ELSIF l_return_status = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSE
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    END IF;
    Debug_Conc_Log('Default_User_Attrs_From_Intf: Done - retcode, errbuf='||retcode||','||errbuf);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Default_User_Attrs_From_Intf: Error - retcode, errbuf='||retcode||','||errbuf);
  END Default_User_Attrs_From_Intf;

  /*
   * This method does the defaulting of Category Assignments
   */
  PROCEDURE Default_Category_Assignments( retcode               OUT NOCOPY VARCHAR2
                                         ,errbuf                OUT NOCOPY VARCHAR2
                                         ,p_batch_id                       NUMBER
                                         ,p_msii_miri_process_flag  IN     NUMBER DEFAULT 1   -- Bug 12635842
                                        )
  IS
  BEGIN
    -- call defaulting of non default category assignments here
    Debug_Conc_Log('Default_Category_Assignments: Starting');
    INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE
    (
      INVENTORY_ITEM_ID,
      ITEM_NUMBER,
      ORGANIZATION_ID,
      CATEGORY_SET_ID,
      CATEGORY_ID,
      PROCESS_FLAG,
      SET_PROCESS_ID,
      TRANSACTION_TYPE
    )
    SELECT
      MSII.INVENTORY_ITEM_ID,
      MSII.ITEM_NUMBER,
      MSII.ORGANIZATION_ID,
      STYLE_CATS.CATEGORY_SET_ID,
      STYLE_CATS.CATEGORY_ID,
      1 PROCESS_FLAG,
      MSII.SET_PROCESS_ID,
      'CREATE'
    FROM
      MTL_SYSTEM_ITEMS_INTERFACE MSII,
      MTL_PARAMETERS O,
      MTL_ITEM_CATEGORIES STYLE_CATS
    WHERE MSII.SET_PROCESS_ID   = p_batch_id
      AND MSII.PROCESS_FLAG     = p_msii_miri_process_flag  -- Bug 12635842
      AND MSII.TRANSACTION_TYPE = 'CREATE'
      AND MSII.STYLE_ITEM_FLAG  = 'N'
      AND MSII.ORGANIZATION_ID  = O.ORGANIZATION_ID
      AND O.ORGANIZATION_ID     = O.MASTER_ORGANIZATION_ID
      AND NOT EXISTS (SELECT 1
                      FROM MTL_DEFAULT_CATEGORY_SETS DCS
                      WHERE DCS.CATEGORY_SET_ID = STYLE_CATS.CATEGORY_SET_ID
                     )
      AND STYLE_CATS.INVENTORY_ITEM_ID = MSII.STYLE_ITEM_ID
      AND STYLE_CATS.ORGANIZATION_ID   = MSII.ORGANIZATION_ID;

    RETCODE := '0';
    ERRBUF := NULL;
    Debug_Conc_Log('Default_Category_Assignments: Done defaulting category assignments rowcount='||SQL%ROWCOUNT);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Default_Category_Assignments: Error - retcode, errbuf='||retcode||','||errbuf);
  END Default_Category_Assignments;

  /*
   * This method does all the defaulting
   * It calls various Defaulting APIs on child entities
   * such as UDA, Category Assgn etc.
   */
  PROCEDURE Default_Child_Entities( retcode               OUT NOCOPY VARCHAR2
                                   ,errbuf                OUT NOCOPY VARCHAR2
                                   ,p_batch_id                       NUMBER
                                   ,p_msii_miri_process_flag  IN     NUMBER DEFAULT 1   -- Bug 12635842
                                  )
  IS
    l_retcode  VARCHAR2(10);
    l_errbuf   VARCHAR2(4000);
  BEGIN
    -- call child entities defaulting here
    Debug_Conc_Log('Default_Child_Entities: Starting');
    Default_Supplier_Intersections( retcode      => l_retcode
                                   ,errbuf       => l_errbuf
                                   ,p_batch_id   => p_batch_id
                                   ,p_msii_miri_process_flag => p_msii_miri_process_flag  -- Bug 12635842
                                  );

    Debug_Conc_Log('Default_Child_Entities: Done Default_Supplier_Intersections with retcode, errbuf='||l_retcode||','||l_errbuf);
    RETCODE := l_retcode;
    ERRBUF := l_errbuf;
    IF retcode = '2' THEN
      RETURN;
    END IF;

    /* Bug 10120039 : Start
       Commenting the below update query here and plaing it before INSERT_FUN_GEN_SETUP_UDAS in the procedure Preprocess_Import
       so that for all the user entered records will set PROG_INT_NUM4 = 0.
       Also the fix done for the bug 9678667 is reverted.
    */
    -- to identify the records that are not inserted by defaulting APIs
   -- UPDATE /*+ INDEX(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N3) */    /* Bug 9678667 */
   /*   EGO_ITM_USR_ATTR_INTRFC
       SET PROG_INT_NUM4 = 0
     WHERE DATA_SET_ID = p_batch_id
       AND PROCESS_STATUS in (1,2);  -- Bug 9742469
   */
   -- Bug 10120039 : End

    -- call defaulting of Attributes (UDA) from Style to SKUs
    Default_User_Attrs_From_Prod( retcode      => l_retcode
                                 ,errbuf       => l_errbuf
                                 ,p_batch_id   => p_batch_id
                                 ,p_msii_miri_process_flag => p_msii_miri_process_flag  -- Bug 12635842
                                );
    Debug_Conc_Log('Default_Child_Entities: Done Default_User_Attrs_From_Prod with retcode, errbuf='||l_retcode||','||l_errbuf);
    IF NVL(l_retcode, '0') > RETCODE THEN
      RETCODE := l_retcode;
      ERRBUF := l_errbuf;
    END IF;

    IF RETCODE = '2' THEN
      RETURN;
    END IF;

    -- call defaulting of category assignments from Style to SKUs
    Default_Category_Assignments( retcode      => l_retcode
                                 ,errbuf       => l_errbuf
                                 ,p_batch_id   => p_batch_id
                                 ,p_msii_miri_process_flag => p_msii_miri_process_flag  -- Bug 12635842
                                );
    Debug_Conc_Log('Default_Child_Entities: Done Default_Category_Assignments with retcode, errbuf='||l_retcode||','||l_errbuf);
    IF NVL(l_retcode, '0') > RETCODE THEN
      RETCODE := l_retcode;
      ERRBUF := l_errbuf;
    END IF;

    IF RETCODE = '2' THEN
      RETURN;
    END IF;
    Debug_Conc_Log('Default_Child_Entities: Done - retcode, errbuf='||retcode||','||errbuf);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Default_Child_Entities: Error - retcode, errbuf='||retcode||','||errbuf);
  END Default_Child_Entities;



  PROCEDURE Log_Error_For_Timestamp_Val( RETCODE     OUT NOCOPY VARCHAR2,
                                         ERRBUF      OUT NOCOPY VARCHAR2,
                                         p_item_detail_tbl      ITEM_DETAIL_TBL,
                                         p_show_prod_timestemp  BOOLEAN,
                                         p_intf_table_name      VARCHAR2,
                                         p_user_id              NUMBER,
                                         p_login_id             NUMBER,
                                         p_prog_appid           NUMBER,
                                         p_prog_id              NUMBER,
                                         p_req_id               NUMBER
                                       )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_msg_name             VARCHAR2(100);
    l_msg_text             VARCHAR2(4000);
    l_prod_timestamp       VARCHAR2(100);
  BEGIN
    IF p_item_detail_tbl IS NOT NULL AND p_item_detail_tbl.COUNT > 0 THEN
      FOR i IN p_item_detail_tbl.FIRST..p_item_detail_tbl.LAST LOOP
        IF p_item_detail_tbl(i).PROCESS_FLAG = 6 THEN
          IF p_show_prod_timestemp THEN
            BEGIN
              SELECT TO_CHAR(LAST_MESSAGE_TIMESTAMP, G_NLS_DATE_FORMAT) INTO l_prod_timestamp
              FROM EGO_INBOUND_MSG_EXT
              WHERE SOURCE_SYSTEM_ID          = p_item_detail_tbl(i).SOURCE_SYSTEM_ID
                AND INVENTORY_ITEM_ID         = p_item_detail_tbl(i).INVENTORY_ITEM_ID
                AND ORGANIZATION_ID           = p_item_detail_tbl(i).ORGANIZATION_ID
                AND DATA_LEVEL_ID             = p_item_detail_tbl(i).DATA_LEVEL_ID
                AND NVL(SUPPLIER_ID, -1)      = NVL(p_item_detail_tbl(i).SUPPLIER_ID, -1)
                AND NVL(SUPPLIER_SITE_ID, -1) = NVL(p_item_detail_tbl(i).SUPPLIER_SITE_ID, -1);
            EXCEPTION WHEN OTHERS THEN
              l_prod_timestamp := NULL;
            END;

            FND_MESSAGE.SET_NAME('EGO', 'EGO_TIMESTAMP_GREATER_IN_PROD');
            FND_MESSAGE.SET_TOKEN('TIMESTAMP', l_prod_timestamp);
          ELSE
            FND_MESSAGE.SET_NAME('EGO', 'EGO_TIMESTAMP_GREATER_IN_BATCH');
          END IF;

          FND_MESSAGE.SET_TOKEN('SS_REF', p_item_detail_tbl(i).SOURCE_SYSTEM_REFERENCE);
          l_msg_text := FND_MESSAGE.GET;

          INSERT INTO MTL_INTERFACE_ERRORS
          (
            TRANSACTION_ID,
            UNIQUE_ID,
            ORGANIZATION_ID,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            COLUMN_NAME,
            TABLE_NAME,
            MESSAGE_NAME,
            ERROR_MESSAGE,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
          )
          VALUES
          (
            p_item_detail_tbl(i).TRANSACTION_ID,
            NULL,
            p_item_detail_tbl(i).ORGANIZATION_ID,
            SYSDATE,
            p_user_id,
            SYSDATE,
            p_user_id,
            p_login_id,
            NULL,
            p_intf_table_name,
            NULL,
            l_msg_text,
            p_req_id,
            p_prog_appid,
            p_prog_id,
            SYSDATE
          );
        END IF; -- IF PROCESS_FLAG = 6
      END LOOP;
    END IF;

    COMMIT;

    RETCODE := '0';
    ERRBUF := NULL;
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := 'Error in logging error - '||SQLERRM;
    Debug_Conc_Log('Log_Error_For_Timestamp_Val: Error = '||SQLERRM);
  END Log_Error_For_Timestamp_Val;
  /*
   * This method stamps the rows to stale by comparing message timestamp
   * from production (Only for batches having enabled_for_data_pool as Y)
   */
  PROCEDURE Validate_Timestamp_With_Prod(retcode     OUT NOCOPY VARCHAR2,
                                         errbuf      OUT NOCOPY VARCHAR2,
                                         p_batch_id  IN NUMBER)
  IS
    l_item_master_dl_id        NUMBER;
    l_enabled_for_data_pool    VARCHAR2(1);
    l_item_detail_tbl          ITEM_DETAIL_TBL;
    l_user_id                  NUMBER := FND_GLOBAL.USER_ID;
    l_login_id                 NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid               NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id                  NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_ret_code                 VARCHAR2(10);
    l_err_buf                  VARCHAR2(4000);
  BEGIN
    Debug_Conc_Log('Validate_Timestamp_With_Prod: Starting p_batch_id='||p_batch_id);
    BEGIN
      SELECT NVL(ENABLED_FOR_DATA_POOL, 'N') INTO l_enabled_for_data_pool
      FROM EGO_IMPORT_OPTION_SETS
      WHERE BATCH_ID = p_batch_id;
    EXCEPTION WHEN OTHERS THEN
      Debug_Conc_Log('Validate_Timestamp_With_Prod: exception='||SQLERRM);
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END;

    Debug_Conc_Log('Validate_Timestamp_With_Prod: l_enabled_for_data_pool='||l_enabled_for_data_pool);
    IF l_enabled_for_data_pool = 'N' THEN
      RETCODE := '0';
      ERRBUF := NULL;
      Debug_Conc_Log('Validate_Timestamp_With_Prod: Done');
      RETURN;
    END IF;

    BEGIN
      SELECT DATA_LEVEL_ID INTO l_item_master_dl_id
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE = 'EGO_MASTER_ITEMS'
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME = 'ITEM_ORG';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN;
    END;

    Debug_Conc_Log('Validate_Timestamp_With_Prod: l_item_master_dl_id='||l_item_master_dl_id);

    l_item_detail_tbl := NULL;

    UPDATE MTL_SYSTEM_ITEMS_INTERFACE msii
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG   = 1
      AND EXISTS (SELECT NULL
                  FROM EGO_INBOUND_MSG_EXT eime
                  WHERE eime.SOURCE_SYSTEM_ID       = msii.SOURCE_SYSTEM_ID
                    AND eime.DATA_LEVEL_ID          = l_item_master_dl_id
                    AND eime.INVENTORY_ITEM_ID      = msii.INVENTORY_ITEM_ID
                    AND eime.ORGANIZATION_ID        = msii.ORGANIZATION_ID
                    AND eime.LAST_MESSAGE_TIMESTAMP > msii.MESSAGE_TIMESTAMP
                 )
    RETURNING
      TRANSACTION_ID,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      ITEM_NUMBER,
      SOURCE_SYSTEM_REFERENCE,
      SOURCE_SYSTEM_ID,
      l_item_master_dl_id,
      -1,
      -1,
      PROCESS_FLAG
    BULK COLLECT INTO l_item_detail_tbl;

    Debug_Conc_Log('Validate_Timestamp_With_Prod: Updated MSII rowcount='||SQL%ROWCOUNT);
    IF l_item_detail_tbl IS NOT NULL THEN
      Debug_Conc_Log('Validate_Timestamp_With_Prod: Logging errors for MTL_SYSTEM_ITEMS_INTERFACE');
      Log_Error_For_Timestamp_Val(RETCODE               => l_ret_code,
                                  ERRBUF                => l_err_buf,
                                  p_item_detail_tbl     => l_item_detail_tbl,
                                  p_show_prod_timestemp => TRUE,
                                  p_intf_table_name     => 'MTL_SYSTEM_ITEMS_INTERFACE',
                                  p_user_id             => l_user_id,
                                  p_login_id            => l_login_id,
                                  p_prog_appid          => l_prog_appid,
                                  p_prog_id             => l_prog_id,
                                  p_req_id              => l_request_id
                                 );
      Debug_Conc_Log('Validate_Timestamp_With_Prod: Done Logging errors with l_ret_code,l_err_buf='||l_ret_code||','||l_err_buf);
    END IF;

    l_item_detail_tbl := NULL;

    UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
    SET PROCESS_STATUS         = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE DATA_SET_ID    = p_batch_id
      AND PROCESS_STATUS = 1
      AND ROW_IDENTIFIER IN (SELECT eiuai2.ROW_IDENTIFIER
                             FROM EGO_INBOUND_MSG_EXT eime, EGO_ITM_USR_ATTR_INTRFC eiuai2, MTL_SYSTEM_ITEMS_INTERFACE msii
                             WHERE eiuai2.DATA_SET_ID              = eiuai.DATA_SET_ID
                               AND eiuai2.PROCESS_STATUS           = 1
                               AND eime.SOURCE_SYSTEM_ID           = eiuai2.SOURCE_SYSTEM_ID
                               AND eime.DATA_LEVEL_ID              = eiuai2.DATA_LEVEL_ID
                               AND eime.INVENTORY_ITEM_ID          = eiuai2.INVENTORY_ITEM_ID
                               AND eime.ORGANIZATION_ID            = eiuai2.ORGANIZATION_ID
                               AND NVL(eime.SUPPLIER_ID, -99)      = NVL(eiuai2.PK1_VALUE, -99)
                               AND NVL(eime.SUPPLIER_SITE_ID, -99) = NVL(eiuai2.PK2_VALUE, -99)
                               AND eiuai2.DATA_SET_ID              = msii.SET_PROCESS_ID
                               AND msii.PROCESS_FLAG               = 6
                               AND eiuai2.INVENTORY_ITEM_ID        = msii.INVENTORY_ITEM_ID
                               AND eiuai2.ORGANIZATION_ID          = msii.ORGANIZATION_ID
                               AND eime.LAST_MESSAGE_TIMESTAMP     > msii.MESSAGE_TIMESTAMP
                             GROUP BY eiuai2.ROW_IDENTIFIER
                            )
    RETURNING
      TRANSACTION_ID,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      ITEM_NUMBER,
      SOURCE_SYSTEM_REFERENCE,
      SOURCE_SYSTEM_ID,
      DATA_LEVEL_ID,
      PK1_VALUE,
      PK2_VALUE,
      PROCESS_STATUS
    BULK COLLECT INTO l_item_detail_tbl;

    Debug_Conc_Log('Validate_Timestamp_With_Prod: Updated EGO_ITM_USR_ATTR_INTRFC rowcount='||SQL%ROWCOUNT);
    IF l_item_detail_tbl IS NOT NULL THEN
      Debug_Conc_Log('Validate_Timestamp_With_Prod: Logging errors for EGO_ITM_USR_ATTR_INTRFC');
      Log_Error_For_Timestamp_Val(RETCODE               => l_ret_code,
                                  ERRBUF                => l_err_buf,
                                  p_item_detail_tbl     => l_item_detail_tbl,
                                  p_show_prod_timestemp => TRUE,
                                  p_intf_table_name     => 'EGO_ITM_USR_ATTR_INTRFC',
                                  p_user_id             => l_user_id,
                                  p_login_id            => l_login_id,
                                  p_prog_appid          => l_prog_appid,
                                  p_prog_id             => l_prog_id,
                                  p_req_id              => l_request_id
                                 );
      Debug_Conc_Log('Validate_Timestamp_With_Prod: Done Logging errors with l_ret_code,l_err_buf='||l_ret_code||','||l_err_buf);
    END IF;

    l_item_detail_tbl := NULL;

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE BATCH_ID     = p_batch_id
      AND PROCESS_FLAG = 1
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE eiai.BATCH_ID          = msii.SET_PROCESS_ID
                    AND msii.PROCESS_FLAG      = 6
                    AND eiai.INVENTORY_ITEM_ID = msii.INVENTORY_ITEM_ID
                    AND eiai.ORGANIZATION_ID   = msii.ORGANIZATION_ID
                    AND eiai.BUNDLE_ID         = msii.BUNDLE_ID
                 )
    RETURNING
      TRANSACTION_ID,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      ITEM_NUMBER,
      SOURCE_SYSTEM_REFERENCE,
      SOURCE_SYSTEM_ID,
      DATA_LEVEL_ID,
      PK1_VALUE,
      PK2_VALUE,
      PROCESS_FLAG
    BULK COLLECT INTO l_item_detail_tbl;

    Debug_Conc_Log('Validate_Timestamp_With_Prod: Updated EGO_ITEM_ASSOCIATIONS_INTF rowcount='||SQL%ROWCOUNT);
    IF l_item_detail_tbl IS NOT NULL THEN
      Debug_Conc_Log('Validate_Timestamp_With_Prod: Logging errors for EGO_ITEM_ASSOCIATIONS_INTF');
      Log_Error_For_Timestamp_Val(RETCODE               => l_ret_code,
                                  ERRBUF                => l_err_buf,
                                  p_item_detail_tbl     => l_item_detail_tbl,
                                  p_show_prod_timestemp => TRUE,
                                  p_intf_table_name     => 'EGO_ITEM_ASSOCIATIONS_INTF',
                                  p_user_id             => l_user_id,
                                  p_login_id            => l_login_id,
                                  p_prog_appid          => l_prog_appid,
                                  p_prog_id             => l_prog_id,
                                  p_req_id              => l_request_id
                                 );
      Debug_Conc_Log('Validate_Timestamp_With_Prod: Done Logging errors with l_ret_code,l_err_buf='||l_ret_code||','||l_err_buf);
    END IF;

    l_item_detail_tbl := NULL;

    UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG   = 1
      AND EXISTS (SELECT NULL
                  FROM EGO_INBOUND_MSG_EXT eime, MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE mici.SET_PROCESS_ID          = msii.SET_PROCESS_ID
                    AND msii.PROCESS_FLAG            = 6
                    AND mici.INVENTORY_ITEM_ID       = msii.INVENTORY_ITEM_ID
                    AND mici.ORGANIZATION_ID         = msii.ORGANIZATION_ID
                    AND eime.SOURCE_SYSTEM_ID        = mici.SOURCE_SYSTEM_ID
                    AND eime.DATA_LEVEL_ID           = l_item_master_dl_id
                    AND eime.INVENTORY_ITEM_ID       = mici.INVENTORY_ITEM_ID
                    AND eime.ORGANIZATION_ID         = mici.ORGANIZATION_ID
                    AND eime.LAST_MESSAGE_TIMESTAMP  > msii.MESSAGE_TIMESTAMP
                 );

    Debug_Conc_Log('Validate_Timestamp_With_Prod: Updated MTL_ITEM_CATEGORIES_INTERFACE rowcount='||SQL%ROWCOUNT);

    UPDATE BOM_BILL_OF_MTLS_INTERFACE bbmi
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE BATCH_ID = p_batch_id
      AND PROCESS_FLAG   = 1
      AND EXISTS (SELECT NULL
                  FROM EGO_INBOUND_MSG_EXT eime, MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE bbmi.BATCH_ID                = msii.SET_PROCESS_ID
                    AND msii.PROCESS_FLAG            = 6
                    AND bbmi.ASSEMBLY_ITEM_ID        = msii.INVENTORY_ITEM_ID
                    AND bbmi.ORGANIZATION_ID         = msii.ORGANIZATION_ID
                    AND eime.SOURCE_SYSTEM_ID        = msii.SOURCE_SYSTEM_ID
                    AND eime.DATA_LEVEL_ID           = l_item_master_dl_id
                    AND eime.INVENTORY_ITEM_ID       = msii.INVENTORY_ITEM_ID
                    AND eime.ORGANIZATION_ID         = msii.ORGANIZATION_ID
                    AND eime.LAST_MESSAGE_TIMESTAMP  > msii.MESSAGE_TIMESTAMP
                 );

    Debug_Conc_Log('Validate_Timestamp_With_Prod: Updated BOM_BILL_OF_MTLS_INTERFACE rowcount='||SQL%ROWCOUNT);
    UPDATE BOM_INVENTORY_COMPS_INTERFACE bici
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE BATCH_ID = p_batch_id
      AND PROCESS_FLAG   = 1
      AND EXISTS (SELECT NULL
                  FROM EGO_INBOUND_MSG_EXT eime, MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE bici.BATCH_ID                = msii.SET_PROCESS_ID
                    AND msii.PROCESS_FLAG            = 6
                    AND bici.COMPONENT_ITEM_ID       = msii.INVENTORY_ITEM_ID
                    AND bici.ORGANIZATION_ID         = msii.ORGANIZATION_ID
                    AND eime.SOURCE_SYSTEM_ID        = msii.SOURCE_SYSTEM_ID
                    AND eime.DATA_LEVEL_ID           = l_item_master_dl_id
                    AND eime.INVENTORY_ITEM_ID       = msii.INVENTORY_ITEM_ID
                    AND eime.ORGANIZATION_ID         = msii.ORGANIZATION_ID
                    AND eime.LAST_MESSAGE_TIMESTAMP  > msii.MESSAGE_TIMESTAMP
                 );
    Debug_Conc_Log('Validate_Timestamp_With_Prod: Updated BOM_INVENTORY_COMPS_INTERFACE rowcount='||SQL%ROWCOUNT);

    RETCODE := '0';
    ERRBUF := NULL;
    Debug_Conc_Log('Validate_Timestamp_With_Prod: Done Successfully');
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Validate_Timestamp_With_Prod: Error - '||SQLERRM);
  END Validate_Timestamp_With_Prod;

  /* Fix for bug#9336604: Start */
  PROCEDURE Insert_fun_gen_setup_udas
       (p_batch_id  IN NUMBER)
  IS
    CURSOR cat_in_batch(p_batch_id NUMBER) IS
      SELECT DISTINCT msii.item_catalog_group_id AS item_catalog_group_id
      FROM   mtl_system_items_interface msii,
             mtl_parameters mp
      WHERE  msii.set_process_id = p_batch_id
             AND msii.process_flag = 1
             AND msii.transaction_type = 'CREATE'
             AND msii.item_catalog_group_id IS NOT NULL
             AND msii.item_catalog_group_id <> -1
             AND Nvl(msii.style_item_flag,'N') = 'N'
             AND msii.organization_id = mp.organization_id
             AND mp.organization_id = mp.master_organization_id;
    l_num_action_id    NUMBER;
    l_desc_action_id   NUMBER;
    l_attr_group_id    dbms_sql.number_table;
    l_attr_group_name  dbms_sql.varchar2_table;
    l_attr_name        dbms_sql.varchar2_table;
    l_n_def_value      dbms_sql.varchar2_table;
    l_c_def_value      dbms_sql.varchar2_table;
    l_d_def_value      dbms_sql.varchar2_table;
    l_data_type        dbms_sql.varchar2_table;
    l_row_id           NUMBER;
    l_trans_id         NUMBER;
    l_created_by       NUMBER;
    l_last_updated_by  NUMBER;
    l_ag_exits_count   NUMBER;
  BEGIN
    Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: Starting. First set org_code into MSII.');

    -- Fix for bug#9660659 Start
    --UPDATE mtl_system_items_interface msii
    --SET    msii.organization_code = (SELECT mp.organization_code
    --                                 FROM   mtl_parameters mp
    --                                 WHERE  mp.organization_id = msii.organization_id);
    --
    IF p_batch_id is not null THEN

      UPDATE mtl_system_items_interface msii
      SET    msii.organization_code = (SELECT mp.organization_code
                                       FROM   mtl_parameters mp
                                       WHERE  mp.organization_id = msii.organization_id)
      WHERE SET_PROCESS_ID = P_BATCH_ID;

    ELSE

      UPDATE mtl_system_items_interface msii
      SET    msii.organization_code = (SELECT mp.organization_code
                                       FROM   mtl_parameters mp
                                       WHERE  mp.organization_id = msii.organization_id);
    END IF;
    -- Fix for bug#9660659 End

    Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: Done setting org_code into MSII. Now looping through distinct ICC in this batch.');

    FOR j IN cat_in_batch(p_batch_id) LOOP
      Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: Processing ICC: '
                     ||j.item_catalog_group_id);

      SELECT To_number(Substr(item_num_action_id,Instr(item_num_action_id,'$$',2) + 2))   AS item_num_action_id,
             To_number(Substr(item_desc_action_id,Instr(item_desc_action_id,'$$',2) + 2)) AS item_desc_action_id
      INTO   l_num_action_id,l_desc_action_id
      FROM   (SELECT Min(CASE
                           WHEN item_desc_gen_method = 'F'
                                AND (PRIOR item_desc_gen_method IS NULL
                                            OR PRIOR item_desc_gen_method = 'I')
                           THEN '$$'
                                ||Lpad(LEVEL,6,'0')
                                ||'$$'
                                ||item_desc_action_id
                           WHEN item_desc_gen_method IN ('U','S')
                           THEN '$$'
                                ||Lpad(LEVEL,6,'0')
                                ||'$$'
                           ELSE NULL
                         END) item_desc_action_id,
                     Min(CASE
                           WHEN item_num_gen_method = 'F'
                                AND (PRIOR item_num_gen_method IS NULL
                                            OR PRIOR item_num_gen_method = 'I')
                           THEN '$$'
                                ||Lpad(LEVEL,6,'0')
                                ||'$$'
                                ||item_num_action_id
                           WHEN item_num_gen_method IN ('U','S')
                           THEN '$$'
                                ||Lpad(LEVEL,6,'0')
                                ||'$$'
                           ELSE NULL
                         END) item_num_action_id
              FROM   mtl_item_catalog_groups_b
              CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id START WITH item_catalog_group_id = j.item_catalog_group_id);

      Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: l_num_action_id: '
                     ||l_num_action_id
                     ||', l_desc_action_id: '
                     ||l_desc_action_id);

      IF (l_num_action_id IS NOT NULL
           OR l_desc_action_id IS NOT NULL) THEN
        SELECT ag_ext.attr_group_id,
               fl_col.descriptive_flex_context_code,
               fl_col.end_user_column_name,
               attr_ext.data_type,
               To_number(Decode(attr_ext.data_type,'N',fl_col.default_value,
                                                   NULL)),
               Decode(attr_ext.data_type,'A',fl_col.default_value,
                                         'C',fl_col.default_value,
                                         NULL),
               Decode(attr_ext.data_type,'X',ego_user_attrs_bulk_pvt.Get_date(fl_col.default_value,NULL),
                                         'Y',ego_user_attrs_bulk_pvt.Get_date(fl_col.default_value,NULL),
                                         NULL)
        BULK COLLECT INTO l_attr_group_id,l_attr_group_name,l_attr_name,l_data_type,
               l_n_def_value,l_c_def_value,l_d_def_value
        FROM   ego_mappings_b MAP,
               fnd_descr_flex_column_usages fl_col,
               ego_fnd_df_col_usgs_ext attr_ext,
               ego_fnd_dsc_flx_ctx_ext ag_ext,
               ego_attr_group_dl ag_dl
        WHERE  MAP.mapped_obj_type = 'A'
               AND fl_col.application_id = MAP.mapped_to_group_pk1
               AND fl_col.descriptive_flexfield_name = MAP.mapped_to_group_pk2
               AND fl_col.descriptive_flex_context_code = MAP.mapped_to_group_pk3
               AND fl_col.end_user_column_name = MAP.mapped_attribute
               AND ag_ext.application_id = fl_col.application_id
               AND ag_ext.descriptive_flexfield_name = fl_col.descriptive_flexfield_name
               AND ag_ext.descriptive_flex_context_code = fl_col.descriptive_flex_context_code
               AND attr_ext.application_id = fl_col.application_id
               AND attr_ext.descriptive_flexfield_name = fl_col.descriptive_flexfield_name
               AND attr_ext.descriptive_flex_context_code = fl_col.descriptive_flex_context_code
               AND attr_ext.application_column_name = fl_col.application_column_name
               AND ag_ext.attr_group_id = ag_dl.attr_group_id
               AND ag_dl.data_level_id = 43101
               AND fl_col.default_value IS NOT NULL
               AND fl_col.enabled_flag = 'Y'
               AND fl_col.descriptive_flexfield_name = 'EGO_ITEMMGMT_GROUP'
               AND fl_col.application_id = 431
               AND ((l_num_action_id IS NOT NULL
                     AND l_desc_action_id IS NOT NULL
                     AND (To_number(MAP.mapped_obj_pk1_val) IN (l_num_action_id,l_desc_action_id)))
                     OR (l_num_action_id IS NOT NULL
                         AND l_desc_action_id IS NULL
                         AND To_number(MAP.mapped_obj_pk1_val) = l_num_action_id)
                     OR (l_num_action_id IS NULL
                         AND l_desc_action_id IS NOT NULL
                         AND To_number(MAP.mapped_obj_pk1_val) = l_desc_action_id));

        Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: Done getting FG attrs for l_num_action_id: '
                       ||l_num_action_id
                       ||', l_desc_action_id: '
                       ||l_desc_action_id);

        IF (l_attr_name.COUNT > 0) THEN
          FOR i IN l_attr_name.FIRST.. l_attr_name.LAST LOOP
            Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: Processing l_attr_name: '
                           ||l_attr_name(i)
                           ||', l_attr_group_id: '
                           ||l_attr_group_id(i)
                           ||', l_attr_group_name: '
                           ||l_attr_group_name(i)
                           ||', l_data_type: '
                           ||l_data_type(i)
                           ||', l_n_def_value: '
                           ||l_n_def_value(i)
                           ||', l_c_def_value: '
                           ||l_c_def_value(i)
                           ||', l_d_def_value: '
                           ||l_d_def_value(i));

            SELECT Count(* )
            INTO   l_ag_exits_count
            FROM   ego_itm_usr_attr_intrfc
            WHERE  data_set_id = p_batch_id
                   AND attr_group_int_name = l_attr_group_name(i)
                   AND process_status = 1
                   AND data_level_id = 43101;

            Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: l_ag_exits_count :'||l_ag_exits_count);  -- Bug 12553744

            IF (l_ag_exits_count > 0) THEN
              INSERT INTO ego_itm_usr_attr_intrfc
                         (process_status,
                          data_set_id,
                          row_identifier,
                          attr_group_int_name,
                          attr_int_name,
                          attr_value_num,
                          attr_value_str,
                          attr_value_date,
                          transaction_type,
                          inventory_item_id,
                          organization_id,
                          source_system_reference,
                          source_system_id,
                          item_number,
                          organization_code,
                          data_level_id,
                          pk1_value,
                          pk2_value,
                          revision_id,
                          item_catalog_group_id,
                          attr_group_type,
                          attr_group_id,
                          request_id, -- Bug 10112500
                          created_by,
                          creation_date,
                          last_updated_by,
                          last_update_date)
              SELECT   2,   /* Bug 12553744 */
                       data_set_id,
                       row_identifier,
                       l_attr_group_name(i),
                       l_attr_name(i),
                       l_n_def_value(i),
                       l_c_def_value(i),
                       ego_user_attrs_bulk_pvt.Get_date(l_d_def_value(i)),
                       'CREATE',
                       a.inventory_item_id,
                       a.organization_id,
                       a.source_system_reference,
                       a.source_system_id,
                       a.item_number,
                       a.organization_code,
                       data_level_id,
                       pk1_value,
                       pk2_value,
                       revision_id,
                       a.item_catalog_group_id,
                       attr_group_type,
                       attr_group_id,
                       FND_GLOBAL.CONC_REQUEST_ID, -- Bug 10112500
                       fnd_global.user_id,
                       SYSDATE,
                       fnd_global.user_id,
                       SYSDATE
              FROM     ego_itm_usr_attr_intrfc a,
                       /* Bug 10112500 - Start */
                       mtl_system_items_interface msii,
                       mtl_parameters mp
                       /* Bug 10112500 - End */
              WHERE    NOT EXISTS (SELECT NULL
                                   FROM   ego_itm_usr_attr_intrfc b
                                   WHERE  data_set_id = a.data_set_id
                                          AND b.attr_int_name = l_attr_name(i)
                                          AND b.attr_group_int_name = a.attr_group_int_name
                                          AND b.transaction_type = a.transaction_type
                                          AND b.data_level_id = a.data_level_id
                                          AND a.row_identifier = b.row_identifier)
                       AND data_set_id = p_batch_id
                       AND attr_group_int_name = l_attr_group_name(i)
                       AND data_level_id = 43101
                       AND process_status = 2   /* Bug 10263673, changing the value 2 as by the time this code gets executed all the records will be in status 2 */
                       /* Bug 10112500 - Start */
                       AND msii.set_process_id = p_batch_id
                       AND msii.process_flag = 1
                       AND Nvl(msii.style_item_flag,'N') = 'N'
                       AND msii.organization_id = mp.organization_id
                       AND mp.organization_id = mp.master_organization_id
                       AND msii.item_catalog_group_id = j.item_catalog_group_id
                       AND msii.transaction_type = 'CREATE'
                       AND (a.inventory_item_id = msii.inventory_item_id
                            OR a.item_number = msii.item_number
                            OR a.source_system_reference = msii.source_system_reference)
                      AND (a.organization_id = msii.organization_id
                              OR a.organization_code = msii.organization_code)
                      /* Bug 10112500 - End */
              GROUP BY data_set_id,
                       row_identifier,
                       a.inventory_item_id,
                       a.organization_id,
                       a.source_system_reference,
                       a.source_system_id,
                       a.item_number,
                       a.organization_code,
                       data_level_id,
                       pk1_value,
                       pk2_value,
                       revision_id,
                       a.item_catalog_group_id,
                       attr_group_id,
                 attr_group_type;

              Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: Inserted '||SQL%ROWCOUNT||' rows into ego_itm_usr_attr_intrfc ' );  -- Bug 12553744
            END IF;   -- l_ag_exits_count


            SELECT Nvl(Max(row_identifier),1)   -- Bug 9820607
            INTO   l_row_id
            FROM   ego_itm_usr_attr_intrfc
            WHERE  data_set_id = p_batch_id;

            Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: l_row_id : '||l_row_id); -- Bug 12553744

            INSERT INTO ego_itm_usr_attr_intrfc
                       (process_status,
                        data_set_id,
                        row_identifier,
                        attr_group_int_name,
                        attr_int_name,
                        attr_value_num,
                        attr_value_str,
                        attr_value_date,
                        transaction_type,
                        inventory_item_id,
                        organization_id,
                        source_system_reference,
                        item_number,
                        organization_code,
                        data_level_id,
                        attr_group_type,
                        attr_group_id,
                        item_catalog_group_id, /* Bug 12553744 */
                        request_id, /* Bug 10112500 */
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date)
            /* Bug 9678667 : Added Below hint */
            SELECT /*+ leading(mp) use_hash(msii) */
                   2,   /* Bug 12553744 */
                   p_batch_id,
                   l_row_id + ROWNUM,
                   l_attr_group_name(i),
                   l_attr_name(i),
                   l_n_def_value(i),
                   l_c_def_value(i),
                   ego_user_attrs_bulk_pvt.Get_date(l_d_def_value(i)),
                   'CREATE',
                   inventory_item_id,
                   msii.organization_id,
                   source_system_reference,
                   item_number,
                   msii.organization_code,
                   43101,
                   'EGO_ITEMMGMT_GROUP',
                   l_attr_group_id(i),
                   j.item_catalog_group_id,    /* Bug 12553744 */
                   FND_GLOBAL.CONC_REQUEST_ID, /* Bug 10112500 */
                   fnd_global.user_id,
                   SYSDATE,
                   fnd_global.user_id,
                   SYSDATE
            FROM   mtl_system_items_interface msii,
                   mtl_parameters mp
            WHERE  msii.set_process_id = p_batch_id
                   AND msii.process_flag = 1
                   AND msii.transaction_type = 'CREATE' -- Bug 10112500
                   AND Nvl(msii.style_item_flag,'N') = 'N'
                   AND msii.organization_id = mp.organization_id
                   AND mp.organization_id = mp.master_organization_id
                   AND msii.item_catalog_group_id = j.item_catalog_group_id
                   AND NOT EXISTS ((SELECT /*+ index(B, EGO_ITM_USR_ATTR_INTRFC_N1) */  -- Bug 9678667
                                          NULL
                                   FROM   ego_itm_usr_attr_intrfc b
                                   WHERE  data_set_id = p_batch_id
                                          AND b.attr_int_name = l_attr_name(i)
                                          AND b.attr_group_int_name = l_attr_group_name(i)
                                          /* Fix for bug#9660659 - Start */
                                          /*AND (b.inventory_item_id = msii.inventory_item_id
                                                OR b.item_number = msii.item_number
                                                OR b.source_system_reference = msii.source_system_reference)
                                          AND (b.organization_id = msii.organization_id
                                                OR b.organization_code = msii.organization_code)

                                          AND b.data_level_id = 43101);
                                          */
                                          AND (b.inventory_item_id = msii.inventory_item_id)
                                          AND (b.organization_id = msii.organization_id
                                                OR b.organization_code = msii.organization_code)
                                          AND b.process_status = 2    /* Bug 10263673, changing the value 2 as by the time this code gets executed all the records will be in status 2 */
                                          AND b.data_level_id = 43101)
                                   UNION ALL
                                   (SELECT NULL
                                    FROM   ego_itm_usr_attr_intrfc b
                                    WHERE  data_set_id = p_batch_id
                                          AND b.attr_int_name = l_attr_name(i)
                                          AND b.attr_group_int_name = l_attr_group_name(i)
                                          AND (b.item_number = msii.item_number)
                                          AND (b.organization_id = msii.organization_id
                                                OR b.organization_code = msii.organization_code)
                                          AND b.process_status = 2    /* Bug 10263673, changing the value 2 as by the time this code gets executed all the records will be in status 2 */
                                          AND b.data_level_id = 43101)
                                   UNION ALL
                                   (SELECT NULL
                                    FROM   ego_itm_usr_attr_intrfc b
                                    WHERE  data_set_id = p_batch_id
                                          AND b.attr_int_name = l_attr_name(i)
                                          AND b.attr_group_int_name = l_attr_group_name(i)
                                          AND b.source_system_id = msii.source_system_id  -- Bug 9678667
                                          AND (b.source_system_reference = msii.source_system_reference)
                                          AND (b.organization_id = msii.organization_id
                                                OR b.organization_code = msii.organization_code)
                                          AND b.process_status = 2    /* Bug 10263673, changing the value 2 as by the time this code gets executed all the records will be in status 2 */
                                          AND b.data_level_id = 43101));
                                   /* Fix for bug#9660659 - End */

            Debug_conc_log('INSERT_FUN_GEN_SETUP_UDAS: Inserted '||SQL%ROWCOUNT||' rows into ego_itm_usr_attr_intrfc ' ); -- Bug 12553744
          END LOOP;
        END IF; --(if l_attr_name.COUNT > 0)
      END IF;--(if any of l_num_action_id or l_desc_action_id is not null)
    END LOOP;
  END insert_fun_gen_setup_udas;
  ----------------------------------
  --   PUBLIC METHODS STARTS HERE --
  ----------------------------------

  /* Function to do the preprocessing of Import
   * This method is called from Concurrent Program
   * and then, this method internally calls the
   * various defaulting/copy APIs that are needed
   * for preprocessing
   */
  PROCEDURE Preprocess_Import(retcode               OUT NOCOPY VARCHAR2,
                              errbuf                OUT NOCOPY VARCHAR2,
                              p_batch_id                       NUMBER)
  IS
    l_user_id                NUMBER := FND_GLOBAL.USER_ID;
    l_login_id               NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid             NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id                NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id             NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_err_msg                VARCHAR2(4000);
    l_return_status          INTEGER;
    l_copy_first             VARCHAR2(1);
    l_copy_option_exists     VARCHAR2(1);
    l_copy_org               VARCHAR2(1);
    l_copy_cat               VARCHAR2(1);
    l_retcode                VARCHAR2(1);
    l_errbuf                 VARCHAR2(4000);
    l_org                    VARCHAR2(100);
    l_return_status_str      VARCHAR2(100);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_enabled_for_data_pool  VARCHAR2(1);
  BEGIN
    Debug_Conc_Log('Starting Preprocess_Import');
    IF l_request_id IS NULL OR l_request_id <= 0 THEN
      l_request_id := -1;
    END IF;

    Debug_Conc_Log('Preprocess_Import: l_request_id='||l_request_id);

    BEGIN
      SELECT NVL(ENABLED_FOR_DATA_POOL, 'N')
      INTO l_enabled_for_data_pool
      FROM EGO_IMPORT_OPTION_SETS
      WHERE BATCH_ID = p_batch_id;
    EXCEPTION WHEN OTHERS THEN
      l_enabled_for_data_pool := 'N';
    END;

    Debug_Conc_Log('Preprocess_Import: l_enabled_for_data_pool='||l_enabled_for_data_pool);

    Debug_Conc_Log('Preprocess_Import: Calling Pre_Process of Intersections ');
    EGO_ITEM_ASSOCIATIONS_PUB.Pre_Process
      (
        p_api_version    => 1.0,
        p_batch_id       => p_batch_id,
        x_return_status  => l_return_status_str,
        x_msg_count      => l_msg_count,
        x_msg_data       => l_msg_data
      );
    Debug_Conc_Log('Preprocess_Import: Done Pre_Process of Intersections with l_return_status, l_msg_data='||l_return_status_str||','|| l_msg_data);
    IF l_return_status_str = 'U' THEN
      RETCODE := '2';
      ERRBUF := l_msg_data;
      RETURN;
    ELSIF l_return_status_str = 'E' THEN
      RETCODE := '1';
      ERRBUF := l_msg_data;
    ELSIF l_return_status_str = 'S' THEN
      RETCODE := '0';
      ERRBUF := NULL;
    END IF;


    IF l_enabled_for_data_pool = 'Y' THEN
      Debug_Conc_Log('Preprocess_Import: Calling Validate_Timestamp_With_Prod');
      Validate_Timestamp_With_Prod(retcode     => l_retcode,
                                   errbuf      => l_errbuf,
                                   p_batch_id  => p_batch_id);

      Debug_Conc_Log('Preprocess_Import: Done Validate_Timestamp_With_Prod with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);
      IF NVL(l_retcode, '0') > RETCODE THEN
        RETCODE := l_retcode;
        ERRBUF := l_errbuf;
      END IF;

      IF retcode = '2' THEN
        RETURN;
      END IF;
    END IF; -- IF l_enabled_for_data_pool = 'Y' THEN

    IF l_enabled_for_data_pool = 'N' THEN
      -- If import copy options exists, then it is a UI flow
      -- either SKU creation, Multiple item creation, Multiple
      -- copy item, multiple packaging hierarchy flow
      BEGIN
        SELECT 'Y' INTO l_copy_option_exists
        FROM EGO_IMPORT_COPY_OPTIONS
        WHERE BATCH_ID = p_batch_id
          AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_copy_option_exists := 'N';
      END;

      Debug_Conc_Log('Preprocess_Import: l_copy_option_exists='||l_copy_option_exists);
      -- we will first process the copy options for Items (IOI)
      Process_Copy_Options_For_Items(retcode               => l_retcode,
                                     errbuf                => l_errbuf,
                                     p_batch_id            => p_batch_id,
                                     p_copy_options_exist  => l_copy_option_exists);

      Debug_Conc_Log('Preprocess_Import: Done Process_Copy_Options_For_Items with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);
      IF NVL(l_retcode, '0') > RETCODE THEN
        RETCODE := l_retcode;
        ERRBUF := l_errbuf;
      END IF;

      IF retcode = '2' THEN
        RETURN;
      END IF;
    END IF; -- IF l_enabled_for_data_pool = 'Y' THEN

    -- call IOI defaulting
    fnd_profile.get('EGO_USER_ORGANIZATION_CONTEXT', l_org);
    Debug_Conc_Log('Preprocess_Import: Starting IOI defaulting l_org='||l_org);
    EGO_ITEM_OPEN_INTERFACE_PVT.item_open_interface_process
        ( ERRBUF                   => l_errbuf,
          RETCODE                  => l_retcode,
          P_org_id                 => l_org,
          P_all_org                => 1,
          P_default_flag           => 2,
          P_val_item_flag          => 2,
          P_pro_item_flag          => 2,
          P_del_rec_flag           => 2,
          P_prog_appid             => l_prog_appid,
          P_prog_id                => l_prog_id,
          P_request_id             => l_request_id,
          P_user_id                => l_user_id,
          P_login_id               => l_login_id,
          P_xset_id                => p_batch_id,
          P_commit_flag            => 2,
          P_run_mode               => 0
        );
    Debug_Conc_Log('Preprocess_Import: Done IOI defaulting with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);

    IF NVL(l_retcode, '0') > RETCODE THEN
      RETCODE := l_retcode;
      ERRBUF := l_errbuf;
    END IF;

    IF retcode = '2' THEN
      RETURN;
    END IF;


    -- call Resolve_PKs_For_Child
    -- This API will propagate Item ID to all the child entities
    -- such as UDA, Revisions, Intersections etc.
    Resolve_PKs_For_Child( p_batch_id );
    Debug_Conc_Log('Preprocess_Import: Done Resolve_PKs_For_Child');

    /* Bug 10120039 : Start
       to identify the records that are not inserted by defaulting APIs i.e to identify the records entered by user.
    */
    UPDATE /*+ INDEX(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N3) */
    EGO_ITM_USR_ATTR_INTRFC
    SET PROG_INT_NUM4 = 0
    WHERE DATA_SET_ID = p_batch_id
    AND PROCESS_STATUS = 1;
    -- Bug 10120039 : End

    /* Fix for bug#9336604 : Start */
    -- Bug 10263673 :
    --  Moving this into EGOCIUAB.pls after template application. So that the Defaulting of attrs involved in Function generation
    -- are done after template application.
    -- INSERT_FUN_GEN_SETUP_UDAS( p_batch_id );
    /* Fix for bug#9336604 : End */

    INV_EGO_REVISION_VALIDATE.Set_Process_Control_HTML_API('IMPORT');  -- Bug 10263673, set the flag to IMPORT, so that in EGOCIUAB.pls we check for this flag and do the template application only in this case.

    -- call UDA bulkloader in Validate Mode with security check
    Debug_Conc_Log('Preprocess_Import: Before calling UDA bulkloader in Validate Mode, with security check');
    EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data
          (
            ERRBUF                         => l_errbuf,
            RETCODE                        => l_retcode,
            p_data_set_id                  => p_batch_id,
            p_validate_only                => FND_API.G_TRUE,
            p_ignore_security_for_validate => FND_API.G_FALSE
          );

    INV_EGO_REVISION_VALIDATE.Set_Process_Control_HTML_API(NULL);  -- Bug 10263673

    Debug_Conc_Log('Preprocess_Import: Done EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);
    IF NVL(l_retcode, '0') > RETCODE THEN
      RETCODE := l_retcode;
      ERRBUF := l_errbuf;
    END IF;

    IF RETCODE = '2' THEN
      RETURN;
    END IF;

    IF l_enabled_for_data_pool = 'N' THEN
      -- call process copy options for UDAs
      -- this will do the Apply Multiple Templates
      -- and copying of attributes if any

      -- Bug 10263673 : Start
      -- Moving the logic of template application and copy of attributes into EGOCIUAB.pls after the validation of IDs
      -- for user given data and before the call to EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data api, so that
      -- Application of template is done before defaulting of attr level values.
      --
      /*
      Process_Copy_Options_For_UDAs(retcode               => l_retcode,
                                    errbuf                => l_errbuf,
                                    p_batch_id            => p_batch_id,
                                    p_copy_options_exist  => l_copy_option_exists);

      Debug_Conc_Log('Preprocess_Import: Done Process_Copy_Options_For_UDAs with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);

      IF NVL(l_retcode, '0') > RETCODE THEN
        RETCODE := l_retcode;
        ERRBUF := l_errbuf;
      END IF;

      IF RETCODE = '2' THEN
        RETURN;
      END IF;
      */ -- Bug 10263673 : End

      -- call defaulting APIs
      Default_Child_Entities(retcode               => l_retcode,
                             errbuf                => l_errbuf,
                             p_batch_id            => p_batch_id);

      Debug_Conc_Log('Preprocess_Import: Done Default_Child_Entities with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);

      IF NVL(l_retcode, '0') > RETCODE THEN
        RETCODE := l_retcode;
        ERRBUF := l_errbuf;
      END IF;

      IF RETCODE = '2' THEN
        RETURN;
      END IF;
    END IF; -- IF l_enabled_for_data_pool = 'N' THEN

    -- Doing the attribute group level defaulting
    Do_AGLevel_UDA_Defaulting( p_batch_id       => p_batch_id,
                               x_return_status  => l_retcode,
                               x_err_msg        => l_errbuf
                             );

    Debug_Conc_Log('Preprocess_Import: Done Do_AGLevel_UDA_Defaulting with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);
    IF NVL(l_retcode, '0') > RETCODE THEN
      RETCODE := l_retcode;
      ERRBUF := l_errbuf;
    END IF;

    IF RETCODE = '2' THEN
      RETURN;
    END IF;

    -- call UDA bulkloader in Validate Mode ignoring security check
    -- Fix for bug#9336604. Performance Fix Begin. Comment this validation call.
      --All Function generation attributes have been validated during previous calls.
      --So the defaulted UDAs can be validated later.
    /*Debug_Conc_Log('Preprocess_Import: Before calling UDA bulkloader in Validate Mode, ignoring security check');
    EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data
          (
            ERRBUF                         => l_errbuf,
            RETCODE                        => l_retcode,
            p_data_set_id                  => p_batch_id,
            p_validate_only                => FND_API.G_TRUE,
            p_ignore_security_for_validate => FND_API.G_TRUE
          );

    Debug_Conc_Log('Preprocess_Import: Done EGO_ITEM_USER_ATTRS_CP_PUB.Process_Item_User_Attrs_Data with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);
    IF NVL(l_retcode, '0') > RETCODE THEN
      RETCODE := l_retcode;
      ERRBUF := l_errbuf;
    END IF;

    IF RETCODE = '2' THEN
      RETURN;
    END IF;*/
    -- Fix for bug#9336604 Performance Fix End

    IF l_enabled_for_data_pool = 'N' THEN
      -- call Post validation UDA Defaulting
      Default_User_Attrs_From_Intf(retcode               => l_retcode,
                                   errbuf                => l_errbuf,
                                   p_batch_id            => p_batch_id);

      Debug_Conc_Log('Preprocess_Import: Done Default_User_Attrs_From_Intf with l_retcode, l_errbuf='||l_retcode||','||l_errbuf);

      IF NVL(l_retcode, '0') > RETCODE THEN
        RETCODE := l_retcode;
        ERRBUF := l_errbuf;
      END IF;

      IF RETCODE = '2' THEN
        RETURN;
      END IF;
    END IF; -- IF l_enabled_for_data_pool = 'N' THEN

    /* Fix for bug#9678667 : Start */
    UPDATE ego_itm_usr_attr_intrfc
       SET PROG_INT_NUM1          = NULL
          ,PROG_INT_NUM2          = NULL
          ,PROG_INT_NUM3          = NULL
          ,PROG_INT_CHAR1         = 'N'
          ,PROG_INT_CHAR2         = 'N'
          ,REQUEST_ID             = FND_GLOBAL.CONC_REQUEST_ID
          ,PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID
          ,PROGRAM_ID             = FND_GLOBAL.CONC_PROGRAM_ID
          ,PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE PROCESS_STATUS   = 2
        AND DATA_SET_ID      = p_batch_id
        AND TRANSACTION_TYPE = 'CREATE'
        AND PROG_INT_CHAR1   IN ('FROM_INTF', 'FROM_PROD');
    /* Fix for bug#9678667 : End */

    -- Bug 9678667 : Start
    Debug_Conc_Log('Preprocess_Import: Calling Clean_Up_UDA_Row_Idents ');
    EGO_IMPORT_PVT.Clean_Up_UDA_Row_Idents(
                             p_batch_id             => p_batch_id,
                             p_process_status       => 2,
                             p_ignore_item_num_upd  => FND_API.G_TRUE,
                             p_commit               => FND_API.G_FALSE );
    Debug_Conc_Log('Preprocess_Import: Clean_Up_UDA_Row_Idents Done.');
    -- Bug 9678667 : End

    COMMIT;
    Debug_Conc_Log('Preprocess_Import: Done with retcode, errbuf='||retcode||','||errbuf);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Preprocess_Import: Error retcode, errbuf='||retcode||','||errbuf);
  END Preprocess_Import;

  /*
   * This API does the defaulting of Org Assignments
   * from Style to SKU and from SKU to Style
   */
  PROCEDURE Default_Org_Assignments( retcode       OUT NOCOPY VARCHAR2,
                                     errbuf        OUT NOCOPY VARCHAR2,
                                     p_batch_id    NUMBER
                                   )
  IS
    CURSOR c_intf_records (c_source_system_id NUMBER) IS
      SELECT
        ORGANIZATION_ID,
        INVENTORY_ITEM_ID,
        ITEM_NUMBER,
        STYLE_ITEM_FLAG,
        STYLE_ITEM_ID,
        SOURCE_SYSTEM_ID,
        ITEM_CATALOG_GROUP_ID,
        ITEM_CATALOG_GROUP_NAME
      FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
      WHERE SET_PROCESS_ID          = p_batch_id
        AND PROCESS_FLAG            = 1
        AND STYLE_ITEM_FLAG         IN ('N', 'Y')
        AND UPPER(TRANSACTION_TYPE) IN ('CREATE', 'SYNC')
        AND EXISTS (SELECT NULL
                    FROM MTL_PARAMETERS MP
                    WHERE MP.ORGANIZATION_ID = MSII.ORGANIZATION_ID
                      AND MP.ORGANIZATION_ID <> MP.MASTER_ORGANIZATION_ID)
      UNION
      SELECT
        MSI.ORGANIZATION_ID       AS ORGANIZATION_ID,
        MSI.INVENTORY_ITEM_ID     AS INVENTORY_ITEM_ID,
        MSI.CONCATENATED_SEGMENTS AS ITEM_NUMBER,
        'Y'                       AS STYLE_ITEM_FLAG,
        MSI.INVENTORY_ITEM_ID     AS STYLE_ITEM_ID,
        c_source_system_id        AS SOURCE_SYSTEM_ID,
        MSI.ITEM_CATALOG_GROUP_ID,
        NULL
      FROM MTL_SYSTEM_ITEMS_KFV MSI, MTL_SYSTEM_ITEMS_INTERFACE MSII, MTL_PARAMETERS MP
      WHERE MSII.SET_PROCESS_ID          = p_batch_id
        AND MSII.PROCESS_FLAG            = 1
        AND MSII.STYLE_ITEM_FLAG         = 'N'
        AND UPPER(MSII.TRANSACTION_TYPE) = 'CREATE'
        AND MSII.ORGANIZATION_ID         = MP.ORGANIZATION_ID
        AND MP.ORGANIZATION_ID           = MP.MASTER_ORGANIZATION_ID
        AND MSII.STYLE_ITEM_ID           = MSI.INVENTORY_ITEM_ID
        AND EXISTS (SELECT NULL FROM MTL_PARAMETERS MP1
                    WHERE MSI.ORGANIZATION_ID = MP1.ORGANIZATION_ID
                      AND MP1.ORGANIZATION_ID <> MP1.MASTER_ORGANIZATION_ID)
      GROUP BY MSI.ORGANIZATION_ID, MSI.INVENTORY_ITEM_ID, MSI.CONCATENATED_SEGMENTS, MSI.INVENTORY_ITEM_ID, MSI.ITEM_CATALOG_GROUP_ID;

    l_source_system_id      NUMBER;
    l_def_style_org_option  VARCHAR2(1);
  BEGIN
    Debug_Conc_Log('Default_Org_Assignments: Starting');
    l_def_style_org_option := EGO_COMMON_PVT.GET_OPTION_VALUE('EGO_DEFAULT_STYLE_ITEM_ORG');
    Debug_Conc_Log('Default_Org_Assignments: l_def_style_org_option='||l_def_style_org_option);
    IF NVL(l_def_style_org_option, 'N') <> 'Y' THEN
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END IF;

    BEGIN
      SELECT SOURCE_SYSTEM_ID INTO l_source_system_id
      FROM EGO_IMPORT_BATCHES_B
      WHERE BATCH_ID = p_batch_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_source_system_id := EGO_IMPORT_PVT.GET_PDH_SOURCE_SYSTEM_ID;
    END;

    Debug_Conc_Log('Default_Org_Assignments: l_source_system_id='||l_source_system_id);
    FOR i IN c_intf_records(l_source_system_id) LOOP
      IF i.STYLE_ITEM_FLAG = 'Y' THEN
        Debug_Conc_Log('Default_Org_Assignments: Defaulting Orgs from Style to SKU for all existing SKUs, style_item_id, org_id='||i.INVENTORY_ITEM_ID ||','||i.ORGANIZATION_ID);
        -- creating org assignment for all existing SKUs
        INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
        (
          SET_PROCESS_ID,
          PROCESS_FLAG,
          ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          ITEM_NUMBER,
          STYLE_ITEM_FLAG,
          STYLE_ITEM_ID,
          SOURCE_SYSTEM_ID,
          TRANSACTION_TYPE,
          ITEM_CATALOG_GROUP_ID,
          ITEM_CATALOG_GROUP_NAME,
          CREATED_BY
        )
        SELECT
          p_batch_id, --SET_PROCESS_ID
          1, -- PROCESS_FLAG
          i.ORGANIZATION_ID,
          MSI.INVENTORY_ITEM_ID,
          MSI.CONCATENATED_SEGMENTS,
          MSI.STYLE_ITEM_FLAG,
          MSI.STYLE_ITEM_ID,
          l_source_system_id,
          'CREATE',
          MSI.ITEM_CATALOG_GROUP_ID,
          NULL,
          -99
        FROM MTL_SYSTEM_ITEMS_KFV MSI, MTL_PARAMETERS MP
        WHERE MSI.STYLE_ITEM_FLAG = 'N'
          AND MSI.STYLE_ITEM_ID   = i.INVENTORY_ITEM_ID
          AND MSI.ORGANIZATION_ID = MP.ORGANIZATION_ID
          AND MP.ORGANIZATION_ID  = MP.MASTER_ORGANIZATION_ID
          AND NOT EXISTS (SELECT 1
                          FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
                          WHERE MSII.SET_PROCESS_ID    = p_batch_id
                            AND MSII.PROCESS_FLAG      = 1
                            AND MSII.ORGANIZATION_ID   = i.ORGANIZATION_ID
                            AND (MSII.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID OR MSII.ITEM_NUMBER = MSI.CONCATENATED_SEGMENTS)
                         )
          AND NOT EXISTS (SELECT 1
                          FROM MTL_SYSTEM_ITEMS_B MSIB
                          WHERE MSIB.ORGANIZATION_ID   = i.ORGANIZATION_ID
                            AND MSIB.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID);

        Debug_Conc_Log('Default_Org_Assignments: Done rows processed='||SQL%ROWCOUNT);

        -- creating org assignment for all SKUs to be created in MSII
        Debug_Conc_Log('Default_Org_Assignments: Defaulting Orgs from Style to SKU for all new SKUs to be created, style_item_id, org_id='||i.INVENTORY_ITEM_ID ||','||i.ORGANIZATION_ID);
        INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
        (
          SET_PROCESS_ID,
          PROCESS_FLAG,
          ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          ITEM_NUMBER,
          STYLE_ITEM_FLAG,
          STYLE_ITEM_ID,
          SOURCE_SYSTEM_ID,
          TRANSACTION_TYPE,
          ITEM_CATALOG_GROUP_ID,
          ITEM_CATALOG_GROUP_NAME,
          CREATED_BY
        )
        SELECT
          p_batch_id, --SET_PROCESS_ID
          1, -- PROCESS_FLAG
          i.ORGANIZATION_ID,
          MSII.INVENTORY_ITEM_ID,
          MSII.ITEM_NUMBER,
          MSII.STYLE_ITEM_FLAG,
          MSII.STYLE_ITEM_ID,
          MSII.SOURCE_SYSTEM_ID,
          'CREATE',
          MSII.ITEM_CATALOG_GROUP_ID,
          MSII.ITEM_CATALOG_GROUP_NAME,
          -99
        FROM MTL_SYSTEM_ITEMS_INTERFACE MSII, MTL_PARAMETERS MP
        WHERE MSII.SET_PROCESS_ID          = p_batch_id
          AND MSII.PROCESS_FLAG            = 1
          AND MSII.STYLE_ITEM_FLAG         = 'N'
          AND UPPER(MSII.TRANSACTION_TYPE) = 'CREATE'
          AND MSII.ORGANIZATION_ID         = MP.ORGANIZATION_ID
          AND MP.ORGANIZATION_ID           = MP.MASTER_ORGANIZATION_ID
          AND MSII.STYLE_ITEM_ID           = i.INVENTORY_ITEM_ID
          AND NOT EXISTS (SELECT 1
                          FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2
                          WHERE MSII2.SET_PROCESS_ID    = p_batch_id
                            AND MSII2.PROCESS_FLAG      = 1
                            AND MSII2.ORGANIZATION_ID   = i.ORGANIZATION_ID
                            AND (MSII2.INVENTORY_ITEM_ID = MSII.INVENTORY_ITEM_ID OR MSII2.ITEM_NUMBER = MSII.ITEM_NUMBER)
                         );

        Debug_Conc_Log('Default_Org_Assignments: Done rows processed='||SQL%ROWCOUNT);
      ELSE -- IF i.STYLE_ITEM_FLAG = 'Y' THEN
        Debug_Conc_Log('Default_Org_Assignments: Defaulting Orgs from SKU to Style, SKU_Item_Id, style_item_id, org_id='||i.INVENTORY_ITEM_ID ||','||i.STYLE_ITEM_ID || ',' ||i.ORGANIZATION_ID);
        INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
        (
          SET_PROCESS_ID,
          PROCESS_FLAG,
          ORGANIZATION_ID,
          INVENTORY_ITEM_ID,
          ITEM_NUMBER,
          STYLE_ITEM_FLAG,
          STYLE_ITEM_ID,
          SOURCE_SYSTEM_ID,
          TRANSACTION_TYPE,
          ITEM_CATALOG_GROUP_ID,
          ITEM_CATALOG_GROUP_NAME,
          CREATED_BY
        )
        SELECT
          p_batch_id, --SET_PROCESS_ID
          1, -- PROCESS_FLAG
          i.ORGANIZATION_ID,
          i.STYLE_ITEM_ID,
          NULL,
          'Y',
          NULL,
          l_source_system_id,
          'CREATE',
          i.ITEM_CATALOG_GROUP_ID,
          i.ITEM_CATALOG_GROUP_NAME,
          -99
        FROM DUAL
        WHERE NOT EXISTS (SELECT 1
                          FROM MTL_SYSTEM_ITEMS_INTERFACE MSII2
                          WHERE MSII2.SET_PROCESS_ID    = p_batch_id
                            AND MSII2.PROCESS_FLAG      = 1
                            AND MSII2.ORGANIZATION_ID   = i.ORGANIZATION_ID
                            AND MSII2.INVENTORY_ITEM_ID = i.STYLE_ITEM_ID
                         )
          AND NOT EXISTS (SELECT NULL
                          FROM MTL_SYSTEM_ITEMS_B MSIB
                          WHERE MSIB.INVENTORY_ITEM_ID = i.STYLE_ITEM_ID
                            AND MSIB.ORGANIZATION_ID   = i.ORGANIZATION_ID);

        Debug_Conc_Log('Default_Org_Assignments: Done rows processed='||SQL%ROWCOUNT);
      END IF; -- IF i.STYLE_ITEM_FLAG = 'Y' THEN
    END LOOP;

    RETCODE := '0';
    ERRBUF := NULL;
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Default_Org_Assignments: Error -'||SQLERRM);
  END Default_Org_Assignments;

  /*
   * This API Marks all the records to process_flag 10 in all interface tables
   * to disable SKUs for processing, and marks process_flag to 1
   * to enable SKUs for processing
   */
  PROCEDURE Enable_Disable_SKU_Processing( retcode                  OUT NOCOPY VARCHAR2,
                                           errbuf                   OUT NOCOPY VARCHAR2,
                                           p_batch_id               NUMBER,
                                           p_enable_sku_processing  VARCHAR2, /* T - TRUE / F - FALSE */
                                           x_skus_to_process        OUT NOCOPY VARCHAR2   -- Bug 9678667
                                         )
  IS
  BEGIN
    x_skus_to_process := 'F'; -- Bug 9678667 : Change
    Debug_Conc_Log('Enable_Disable_SKU_Processing: Starting, p_enable_sku_processing='||p_enable_sku_processing);

    IF p_enable_sku_processing = 'F' THEN
      Debug_Conc_Log('Enable_Disable_SKU_Processing: Disabling SKUs');
      UPDATE MTL_SYSTEM_ITEMS_INTERFACE
      SET PROCESS_FLAG = 10
      WHERE SET_PROCESS_ID   = p_batch_id
        AND PROCESS_FLAG     = 1
        AND STYLE_ITEM_FLAG  = 'N';

      --R12C Business Events to be fired only ONCE although Batch Import is called twice for Styles and then SKUs
      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_Item_Bulkload_Bus_Event(p_true_false => p_enable_sku_processing);
      END IF;

      Debug_Conc_Log('Enable_Disable_SKU_Processing: MTL_SYSTEM_ITEMS_INTERFACE Processed rows='||SQL%ROWCOUNT);

      UPDATE MTL_ITEM_REVISIONS_INTERFACE miri
      SET PROCESS_FLAG = 10
      WHERE SET_PROCESS_ID   = p_batch_id
        AND PROCESS_FLAG     = 1
        AND EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE msii.SET_PROCESS_ID     = miri.SET_PROCESS_ID
                      AND msii.PROCESS_FLAG       = 10
                      AND ( (msii.INVENTORY_ITEM_ID = miri.INVENTORY_ITEM_ID OR msii.ITEM_NUMBER = miri.ITEM_NUMBER) OR
                            (msii.SOURCE_SYSTEM_ID = miri.SOURCE_SYSTEM_ID AND msii.SOURCE_SYSTEM_REFERENCE = miri.SOURCE_SYSTEM_REFERENCE)
                          )
                      AND msii.ORGANIZATION_ID    = miri.ORGANIZATION_ID
                    UNION ALL
                    SELECT NULL FROM MTL_SYSTEM_ITEMS_KFV msik
                    WHERE (msik.INVENTORY_ITEM_ID = miri.INVENTORY_ITEM_ID OR msik.CONCATENATED_SEGMENTS = miri.ITEM_NUMBER)
                      AND msik.ORGANIZATION_ID  = miri.ORGANIZATION_ID
                      AND msik.STYLE_ITEM_FLAG  = 'N'
                   );

      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_Rev_Change_Bus_Event(p_true_false => p_enable_sku_processing);
      END IF;

      Debug_Conc_Log('Enable_Disable_SKU_Processing: MTL_ITEM_REVISIONS_INTERFACE Processed rows='||SQL%ROWCOUNT);

      UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
      SET PROCESS_FLAG = 10
      WHERE SET_PROCESS_ID   = p_batch_id
        AND PROCESS_FLAG     = 1
        AND EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE msii.SET_PROCESS_ID     = mici.SET_PROCESS_ID
                      AND msii.PROCESS_FLAG       = 10
                      AND ( (msii.INVENTORY_ITEM_ID = mici.INVENTORY_ITEM_ID OR msii.ITEM_NUMBER = mici.ITEM_NUMBER) OR
                            (msii.SOURCE_SYSTEM_ID = mici.SOURCE_SYSTEM_ID AND msii.SOURCE_SYSTEM_REFERENCE = mici.SOURCE_SYSTEM_REFERENCE)
                          )
                      AND msii.ORGANIZATION_ID    = mici.ORGANIZATION_ID
                    UNION ALL
                    SELECT NULL FROM MTL_SYSTEM_ITEMS_KFV msik
                    WHERE (msik.INVENTORY_ITEM_ID = mici.INVENTORY_ITEM_ID OR msik.CONCATENATED_SEGMENTS = mici.ITEM_NUMBER)
                      AND msik.ORGANIZATION_ID = mici.ORGANIZATION_ID
                      AND msik.STYLE_ITEM_FLAG = 'N'
                   );

      -- calling this unconditionally, because we will be going through processing SKUs always
    IF SQL%ROWCOUNT > 0 THEN
      EGO_WF_WRAPPER_PVT.Set_Category_Assign_Bus_Event(p_true_false => p_enable_sku_processing);
      END IF;
      Debug_Conc_Log('Enable_Disable_SKU_Processing: MTL_ITEM_CATEGORIES_INTERFACE Processed rows='||SQL%ROWCOUNT);

      -- for user defined attributes, all the process statuses are already in use i.e.
      -- 0, 1, 2, 3, 4, 5, 6, and 8 and above are in use
      -- 7 has a conflict with other interface tables, user may think that record is successful
      -- so, the only option left is to use numbers with decimal < 8
      UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
      SET PROCESS_STATUS = 1.5
      WHERE DATA_SET_ID    = p_batch_id
        AND PROCESS_STATUS = 1
        AND EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE msii.SET_PROCESS_ID     = eiuai.DATA_SET_ID
                      AND msii.PROCESS_FLAG       = 10
                      AND ( (msii.INVENTORY_ITEM_ID = eiuai.INVENTORY_ITEM_ID OR msii.ITEM_NUMBER = eiuai.ITEM_NUMBER) OR
                            (msii.SOURCE_SYSTEM_ID = eiuai.SOURCE_SYSTEM_ID AND msii.SOURCE_SYSTEM_REFERENCE = eiuai.SOURCE_SYSTEM_REFERENCE)
                          )
                      AND msii.ORGANIZATION_ID    = eiuai.ORGANIZATION_ID
                    UNION ALL
                    SELECT NULL FROM MTL_SYSTEM_ITEMS_KFV msik
                    WHERE (msik.INVENTORY_ITEM_ID = eiuai.INVENTORY_ITEM_ID OR msik.CONCATENATED_SEGMENTS = eiuai.ITEM_NUMBER)
                      AND msik.ORGANIZATION_ID = eiuai.ORGANIZATION_ID
                      AND msik.STYLE_ITEM_FLAG = 'N'
                   );

      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_PostAttr_Change_Event(p_true_false => p_enable_sku_processing);
      END IF;

      Debug_Conc_Log('Enable_Disable_SKU_Processing: EGO_ITM_USR_ATTR_INTRFC Processed rows='||SQL%ROWCOUNT);

      UPDATE EGO_AML_INTF eai
      SET PROCESS_FLAG = 10
      WHERE DATA_SET_ID   = p_batch_id
        AND PROCESS_FLAG  = 1
        AND EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE msii.SET_PROCESS_ID     = eai.DATA_SET_ID
                      AND msii.PROCESS_FLAG       = 10
                      AND ( (msii.INVENTORY_ITEM_ID = eai.INVENTORY_ITEM_ID OR msii.ITEM_NUMBER = eai.ITEM_NUMBER) OR
                            (msii.SOURCE_SYSTEM_ID = eai.SOURCE_SYSTEM_ID AND msii.SOURCE_SYSTEM_REFERENCE = eai.SOURCE_SYSTEM_REFERENCE)
                          )
                      AND msii.ORGANIZATION_ID    = eai.ORGANIZATION_ID
                    UNION ALL
                    SELECT NULL FROM MTL_SYSTEM_ITEMS_KFV msik
                    WHERE (msik.INVENTORY_ITEM_ID = eai.INVENTORY_ITEM_ID OR msik.CONCATENATED_SEGMENTS = eai.ITEM_NUMBER)
                      AND msik.ORGANIZATION_ID = eai.ORGANIZATION_ID
                      AND msik.STYLE_ITEM_FLAG = 'N'
                   );

      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_PostAml_Change_Event(p_true_false => p_enable_sku_processing);
      END IF;

      Debug_Conc_Log('Enable_Disable_SKU_Processing: EGO_AML_INTF Processed rows='||SQL%ROWCOUNT);

      UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
      SET PROCESS_FLAG = 10
      WHERE BATCH_ID     = p_batch_id
        AND PROCESS_FLAG = 1
        AND EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE msii.SET_PROCESS_ID     = eiai.BATCH_ID
                      AND msii.PROCESS_FLAG       = 10
                      AND ( (msii.INVENTORY_ITEM_ID = eiai.INVENTORY_ITEM_ID OR msii.ITEM_NUMBER = eiai.ITEM_NUMBER) OR
                            (msii.SOURCE_SYSTEM_ID = eiai.SOURCE_SYSTEM_ID AND msii.SOURCE_SYSTEM_REFERENCE = eiai.SOURCE_SYSTEM_REFERENCE)
                          )
                      AND msii.ORGANIZATION_ID    = eiai.ORGANIZATION_ID
                    UNION ALL
                    SELECT NULL FROM MTL_SYSTEM_ITEMS_KFV msik
                    WHERE (msik.INVENTORY_ITEM_ID = eiai.INVENTORY_ITEM_ID OR msik.CONCATENATED_SEGMENTS = eiai.ITEM_NUMBER)
                      AND msik.ORGANIZATION_ID = eiai.ORGANIZATION_ID
                      AND msik.STYLE_ITEM_FLAG = 'N'
                   );

      Debug_Conc_Log('Enable_Disable_SKU_Processing: EGO_ITEM_ASSOCIATIONS_INTF Processed rows='||SQL%ROWCOUNT);

      UPDATE EGO_ITEM_PEOPLE_INTF eipi
      SET PROCESS_STATUS = 10
      WHERE DATA_SET_ID    = p_batch_id
        AND PROCESS_STATUS = 1
        AND EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE msii.SET_PROCESS_ID     = eipi.DATA_SET_ID
                      AND msii.PROCESS_FLAG       = 10
                      AND ( (msii.INVENTORY_ITEM_ID = eipi.INVENTORY_ITEM_ID OR msii.ITEM_NUMBER = eipi.ITEM_NUMBER) OR
                            (msii.SOURCE_SYSTEM_ID = eipi.SOURCE_SYSTEM_ID AND msii.SOURCE_SYSTEM_REFERENCE = eipi.SOURCE_SYSTEM_REFERENCE)
                          )
                      AND msii.ORGANIZATION_ID    = eipi.ORGANIZATION_ID
                    UNION ALL
                    SELECT NULL FROM MTL_SYSTEM_ITEMS_KFV msik
                    WHERE (msik.INVENTORY_ITEM_ID = eipi.INVENTORY_ITEM_ID OR msik.CONCATENATED_SEGMENTS = eipi.ITEM_NUMBER)
                      AND msik.ORGANIZATION_ID = eipi.ORGANIZATION_ID
                      AND msik.STYLE_ITEM_FLAG = 'N'
                   );

      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_Item_People_Event(p_true_false => p_enable_sku_processing);
      END IF;

      Debug_Conc_Log('Enable_Disable_SKU_Processing: EGO_ITEM_PEOPLE_INTF Processed rows='||SQL%ROWCOUNT);

    ELSIF p_enable_sku_processing = 'T' THEN
      Debug_Conc_Log('Enable_Disable_SKU_Processing: Enabling SKUs');

      --Maybe set to T if batch contains ONLY Styles, to prevent raising again in such cases
      EGO_WF_WRAPPER_PVT.Set_Item_Bulkload_Bus_Event(p_true_false => 'F');

      UPDATE MTL_SYSTEM_ITEMS_INTERFACE
      SET PROCESS_FLAG = 1
      WHERE SET_PROCESS_ID   = p_batch_id
        AND PROCESS_FLAG     = 10
        AND STYLE_ITEM_FLAG  = 'N';

      -- Bug 9678667 : change begin
      IF(SQL%ROWCOUNT > 0) THEN
        x_skus_to_process := 'T';
      END IF;
      -- Bug 9678667 : change end

      --R12C Business Events to be fired only ONCE although Batch Import is called twice for Styles and then SKUs
      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_Item_Bulkload_Bus_Event(p_true_false => p_enable_sku_processing);
      END IF;
      Debug_Conc_Log('Enable_Disable_SKU_Processing: MTL_SYSTEM_ITEMS_INTERFACE Processed rows='||SQL%ROWCOUNT);

      IF SQL%ROWCOUNT > 0 THEN
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
        SET STYLE_ITEM_ID = (SELECT MSIK.INVENTORY_ITEM_ID
                             FROM MTL_SYSTEM_ITEMS_KFV MSIK
                             WHERE MSIK.CONCATENATED_SEGMENTS = MSII.STYLE_ITEM_NUMBER
                               AND MSIK.ORGANIZATION_ID       = MSII.ORGANIZATION_ID
                            )
        WHERE SET_PROCESS_ID    = p_batch_id
          AND STYLE_ITEM_NUMBER IS NOT NULL
          AND STYLE_ITEM_ID     IS NULL
          AND STYLE_ITEM_FLAG   = 'N'
          AND PROCESS_FLAG      = 1;

        Debug_Conc_Log('Enable_Disable_SKU_Processing - Done Resolving Style Item Id cnt- '||SQL%ROWCOUNT );
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
        SET COPY_ITEM_ID         = STYLE_ITEM_ID,
            COPY_ORGANIZATION_ID = ORGANIZATION_ID,
            TEMPLATE_ID          = NULL,
            TEMPLATE_NAME        = NULL
        WHERE SET_PROCESS_ID    = p_batch_id
          AND STYLE_ITEM_ID     IS NOT NULL
          AND STYLE_ITEM_FLAG   = 'N'
          AND PROCESS_FLAG      = 1;

        Debug_Conc_Log('Enable_Disable_SKU_Processing - Done Updating Copy Item Id cnt-'||SQL%ROWCOUNT );
      END IF;

      UPDATE MTL_ITEM_REVISIONS_INTERFACE miri
      SET PROCESS_FLAG = 1
      WHERE SET_PROCESS_ID   = p_batch_id
        AND PROCESS_FLAG     = 10;

      -- Bug 9678667 : change begin
      IF(SQL%ROWCOUNT > 0) THEN
        x_skus_to_process := 'T';
      END IF;
      -- Bug 9678667 : change end

      --R12C Business Events to be fired only ONCE although Batch Import is called twice for Styles and then SKUs
      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_Rev_Change_Bus_Event(p_true_false => p_enable_sku_processing);
      ELSE
         EGO_WF_WRAPPER_PVT.Set_Rev_Change_Bus_Event(p_true_false => 'F');    -- Bug #9341964, make sure biz event is fired only once
      END IF;
      Debug_Conc_Log('Enable_Disable_SKU_Processing: MTL_ITEM_REVISIONS_INTERFACE Processed rows='||SQL%ROWCOUNT);

      UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
      SET PROCESS_FLAG = 1
      WHERE SET_PROCESS_ID   = p_batch_id
        AND PROCESS_FLAG     = 10;

      -- Bug 9678667 : change begin
      IF(SQL%ROWCOUNT > 0) THEN
        x_skus_to_process := 'T';
      END IF;
      -- Bug 9678667 : change end

      --R12C Business Events to be fired only ONCE although Batch Import is called twice for Styles and then SKUs
        IF(SQL%ROWCOUNT > 0) THEN
      EGO_WF_WRAPPER_PVT.Set_Category_Assign_Bus_Event(p_true_false => p_enable_sku_processing);
        END IF;
      Debug_Conc_Log('Enable_Disable_SKU_Processing: MTL_ITEM_CATEGORIES_INTERFACE Processed rows='||SQL%ROWCOUNT);

      UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
      SET PROCESS_STATUS = 1
      WHERE DATA_SET_ID    = p_batch_id
        AND PROCESS_STATUS = 1.5;

      -- Bug 9678667 : change begin
      IF(SQL%ROWCOUNT > 0) THEN
        x_skus_to_process := 'T';
      END IF;
      -- Bug 9678667 : change end

      --R12C Business Events to be fired only ONCE although Batch Import is called twice for Styles and then SKUs
      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_PostAttr_Change_Event(p_true_false => p_enable_sku_processing);
      END IF;
      Debug_Conc_Log('Enable_Disable_SKU_Processing: EGO_ITM_USR_ATTR_INTRFC Processed rows='||SQL%ROWCOUNT);

      UPDATE EGO_AML_INTF eai
      SET PROCESS_FLAG = 1
      WHERE DATA_SET_ID   = p_batch_id
        AND PROCESS_FLAG  = 10;

      -- Bug 9678667 : change begin
      IF(SQL%ROWCOUNT > 0) THEN
        x_skus_to_process := 'T';
      END IF;
      -- Bug 9678667 : change end

      --R12C Business Events to be fired only ONCE although Batch Import is called twice for Styles and then SKUs
      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_PostAml_Change_Event(p_true_false => p_enable_sku_processing);
      END IF;
      Debug_Conc_Log('Enable_Disable_SKU_Processing: EGO_AML_INTF Processed rows='||SQL%ROWCOUNT);

      UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
      SET PROCESS_FLAG = 1
      WHERE BATCH_ID     = p_batch_id
        AND PROCESS_FLAG = 10;

      -- Bug 9678667 : change begin
      IF(SQL%ROWCOUNT > 0) THEN
        x_skus_to_process := 'T';
      END IF;
      -- Bug 9678667 : change end

      Debug_Conc_Log('Enable_Disable_SKU_Processing: EGO_ITEM_ASSOCIATIONS_INTF Processed rows='||SQL%ROWCOUNT);

      UPDATE EGO_ITEM_PEOPLE_INTF eipi
      SET PROCESS_STATUS = 1
      WHERE DATA_SET_ID    = p_batch_id
        AND PROCESS_STATUS = 10;

      -- Bug 9678667 : change begin
      IF(SQL%ROWCOUNT > 0) THEN
        x_skus_to_process := 'T';
      END IF;
      -- Bug 9678667 : change end

      --R12C Business Events to be fired only ONCE although Batch Import is called twice for Styles and then SKUs
      IF SQL%ROWCOUNT > 0 THEN
         EGO_WF_WRAPPER_PVT.Set_Item_People_Event(p_true_false => p_enable_sku_processing);
      END IF;
      Debug_Conc_Log('Enable_Disable_SKU_Processing: EGO_ITEM_PEOPLE_INTF Processed rows='||SQL%ROWCOUNT);
    END IF;

    RETCODE := '0';
    ERRBUF := NULL;
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Enable_Disable_SKU_Processing: Error -'||ERRBUF);
  END Enable_Disable_SKU_Processing;

  /*
   * This method does the defaulting of Item people directly into the Procudution table
   */
  PROCEDURE Default_Item_People( retcode               OUT NOCOPY VARCHAR2,
                                 errbuf                OUT NOCOPY VARCHAR2,
                                 p_batch_id                       NUMBER
                               )
  IS
    TYPE ref_cursor IS REF CURSOR;
    c_get_item_roles           ref_cursor;

    l_grant_guid               FND_GRANTS.GRANT_GUID%type;
    l_return_status            VARCHAR2(10);
    l_errorcode                VARCHAR2(10);
    l_menu_id                  NUMBER;
    l_party_key                VARCHAR2(99);
    l_object_id                NUMBER;
    l_ret_status               VARCHAR2(10);
    l_def_style_people_option  VARCHAR2(1);
    l_copy_people_option       VARCHAR2(1);
    l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_sql                      VARCHAR2(32000);
    l_item_id_sql              VARCHAR2(1000);

    l_inventory_item_id        NUMBER;
    l_organization_id          NUMBER;
    l_menu_name                FND_MENUS.MENU_NAME%TYPE;
    l_grantee_type             FND_GRANTS.GRANTEE_TYPE%TYPE;
    l_grantee_key              FND_GRANTS.GRANTEE_KEY%TYPE;
    l_end_date                 DATE;
  BEGIN
    Debug_Conc_Log('Default_Item_People: Starting');
    RETCODE := '0';
    l_def_style_people_option := EGO_COMMON_PVT.GET_OPTION_VALUE('EGO_DEFAULT_STYLE_PEOPLE');

    Debug_Conc_Log('Default_Item_People: Style to SKU copy option value-'||l_def_style_people_option);
    BEGIN
      SELECT SELECTION_FLAG INTO l_copy_people_option
      FROM EGO_IMPORT_COPY_OPTIONS
      WHERE BATCH_ID    = p_batch_id
        AND COPY_OPTION = 'COPY_PEOPLE'
        AND ROWNUM      = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_copy_people_option := 'N';
    END;

    Debug_Conc_Log('Default_Item_People: import copy option value-'||l_copy_people_option);

    IF NVL(l_def_style_people_option, 'N') = 'N' AND NVL(l_copy_people_option, 'N') = 'N' THEN
      Debug_Conc_Log('Default_Item_People: Import Copy Option value and Style to SKU copy option value, both are N, so exiting.');
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END IF;

    SELECT MENU_ID INTO l_menu_id
    FROM FND_MENUS
    WHERE MENU_NAME = 'EGO_ITEM_OWNER';

    Debug_Conc_Log('Default_Item_People: l_menu_id-'||l_menu_id);

    SELECT 'HZ_PARTY:'||PARTY_ID INTO l_party_key
    FROM EGO_USER_V
    WHERE USER_ID = FND_GLOBAL.USER_ID;

    Debug_Conc_Log('Default_Item_People: l_party_key-'||l_party_key);

    SELECT OBJECT_ID INTO l_object_id
    FROM FND_OBJECTS
    WHERE OBJ_NAME = 'EGO_ITEM';

    Debug_Conc_Log('Default_Item_People: l_object_id-'||l_object_id);

    IF NVL(l_copy_people_option, 'N') = 'Y' THEN
      l_item_id_sql := q'# TO_CHAR(msii.COPY_ITEM_ID) AND NVL(msii.STYLE_ITEM_FLAG, 'Y') = 'Y' #';
    ELSIF NVL(l_def_style_people_option, 'N') = 'Y' THEN
      l_item_id_sql := q'# TO_CHAR(msii.STYLE_ITEM_ID) AND NVL(msii.STYLE_ITEM_FLAG, 'Y') = 'N' #';
    END IF;

    Debug_Conc_Log('Default_Item_People: l_item_id_sql-'||l_item_id_sql);

    l_sql := q'#
              SELECT
                msii.INVENTORY_ITEM_ID,
                msii.ORGANIZATION_ID,
                menus.MENU_NAME,
                grants.GRANTEE_TYPE,
                grants.GRANTEE_KEY,
                grants.END_DATE
              FROM
                MTL_SYSTEM_ITEMS_INTERFACE msii,
                FND_GRANTS grants,
                FND_MENUS menus
              WHERE msii.SET_PROCESS_ID            = #' || p_batch_id || q'#
                AND msii.PROCESS_FLAG              = 7
                AND msii.TRANSACTION_TYPE          = 'CREATE'
                AND msii.REQUEST_ID                = #' || l_request_id || q'#
                AND menus.MENU_ID                  = grants.MENU_ID
                AND grants.INSTANCE_TYPE           = 'INSTANCE'
                AND grants.INSTANCE_PK1_VALUE      = #' || l_item_id_sql || q'#
                AND grants.INSTANCE_PK2_VALUE      = TO_CHAR(msii.ORGANIZATION_ID)
                AND grants.OBJECT_ID               = #' || l_object_id || q'#
                AND NVL(grants.END_DATE, SYSDATE) >= SYSDATE
                AND NOT ( grants.MENU_ID = #' || l_menu_id || q'# AND grants.GRANTEE_KEY = '#' || l_party_key || q'#' ) #';

    Debug_Conc_Log('Default_Item_People: Created l_sql');

    OPEN c_get_item_roles FOR l_sql;

    Debug_Conc_Log('Default_Item_People: Opened cursor');
    LOOP
      FETCH c_get_item_roles INTO l_inventory_item_id, l_organization_id, l_menu_name, l_grantee_type, l_grantee_key, l_end_date;
      EXIT WHEN c_get_item_roles%NOTFOUND;
      Debug_Conc_Log('Default_Item_People: Creating grant for l_inventory_item_id, l_organization_id, l_menu_name, l_grantee_type, l_grantee_key, l_end_date='||
                      l_inventory_item_id||','|| l_organization_id||','|| l_menu_name||','|| l_grantee_type||','|| l_grantee_key||','|| l_end_date);


      FND_GRANTS_PKG.GRANT_FUNCTION(
              p_api_version        => 1.0,
              p_menu_name          => l_menu_name,
              p_object_name        => 'EGO_ITEM',
              p_instance_type      => 'INSTANCE',
              p_instance_set_id    => NULL,
              p_instance_pk1_value => TO_CHAR(l_inventory_item_id),
              p_instance_pk2_value => TO_CHAR(l_organization_id),
              p_grantee_type       => l_grantee_type,
              p_grantee_key        => l_grantee_key,
              p_start_date         => SYSDATE,
              p_end_date           => l_end_date,
              x_grant_guid         => l_grant_guid,
              x_success            => l_return_status,
              x_errorcode          => l_errorcode
          );

      Debug_Conc_Log('Default_Item_People: Returned with l_return_status,l_errorcode='||l_return_status||','||l_errorcode);
      IF l_return_status = FND_API.G_TRUE THEN
        l_ret_status := '0';
      ELSE
        l_ret_status := '2';
      END IF;

      IF NVL(RETCODE, '0') < l_ret_status THEN
        RETCODE := l_ret_status;
        ERRBUF := l_errorcode;
      END IF;
    END LOOP;
    CLOSE c_get_item_roles;

    COMMIT;
    Debug_Conc_Log('Default_Item_People: Done with - RETCODE , ERRBUF='||RETCODE ||','|| ERRBUF);
  EXCEPTION WHEN OTHERS THEN
    IF c_get_item_roles%ISOPEN THEN
      CLOSE c_get_item_roles;
    END IF;
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Default_Item_People: Error with - RETCODE , ERRBUF='||RETCODE ||','|| ERRBUF);
  END Default_Item_People;

  /*
   * This method copies Item people from style to SKU (that are newly added to style) directly into the Procudution table
   */
  PROCEDURE Copy_Item_People_From_Style( retcode               OUT NOCOPY VARCHAR2,
                                         errbuf                OUT NOCOPY VARCHAR2,
                                         p_batch_id                       NUMBER
                                       )
  IS

    -- Should pick 7 records only.
    -- 6504765 : Style to sku item people is not defaulted for item author role
    CURSOR c_skus_to_process(cp_request_id NUMBER, cp_object_id NUMBER) IS
      SELECT DISTINCT
        msik.INVENTORY_ITEM_ID,
        intf.ORGANIZATION_ID,
        menus.MENU_NAME,
        intf.GRANTEE_TYPE,
        DECODE(intf.GRANTEE_TYPE, 'USER',   'HZ_PARTY:'||TO_CHAR(intf.GRANTEE_PARTY_ID),
                             'GROUP',  'HZ_GROUP:'||TO_CHAR(intf.GRANTEE_PARTY_ID),
                             'COMPANY','HZ_COMPANY:'||TO_CHAR(intf.GRANTEE_PARTY_ID),
                             'GLOBAL', intf.GRANTEE_TYPE,
                             TO_CHAR(intf.GRANTEE_PARTY_ID)
              ) GRANTEE_KEY,
        intf.END_DATE
      FROM
        MTL_SYSTEM_ITEMS_KFV msik,
        EGO_ITEM_PEOPLE_INTF intf,
        MTL_PARAMETERS mp,
        FND_MENUS menus
      WHERE intf.DATA_SET_ID      = p_batch_id
        AND intf.PROCESS_STATUS   = 4
        AND intf.REQUEST_ID       = cp_request_id
        AND intf.TRANSACTION_TYPE = 'CREATE'
        AND msik.STYLE_ITEM_ID    = intf.INVENTORY_ITEM_ID
        AND msik.ORGANIZATION_ID  = mp.ORGANIZATION_ID
        AND mp.ORGANIZATION_ID    = mp.MASTER_ORGANIZATION_ID
        AND intf.INTERNAL_ROLE_ID = menus.MENU_ID
        AND NOT EXISTS (SELECT 1 FROM FND_GRANTS fg
                        WHERE fg.INSTANCE_TYPE           = 'INSTANCE'
                          AND fg.INSTANCE_PK1_VALUE      = To_Char(msik.INVENTORY_ITEM_ID)
                          AND fg.INSTANCE_PK2_VALUE      = TO_CHAR(intf.ORGANIZATION_ID)
                          AND fg.OBJECT_ID               = cp_object_id
                          AND NVL(fg.END_DATE, SYSDATE)  >= SYSDATE
                          AND fg.MENU_ID                 = menus.MENU_ID
                          AND fg.GRANTEE_TYPE            = intf.GRANTEE_TYPE
                          AND fg.GRANTEE_KEY             = 'HZ_PARTY:'||intf.GRANTEE_PARTY_ID
                       );

    l_grant_guid               FND_GRANTS.GRANT_GUID%type;
    l_return_status            VARCHAR2(10);
    l_errorcode                VARCHAR2(10);
    l_object_id                NUMBER;
    l_ret_status               VARCHAR2(10);
    l_def_style_people_option  VARCHAR2(1);
    l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  BEGIN
    Debug_Conc_Log('Copy_Item_People_From_Style: Starting');
    RETCODE := '0';
    l_def_style_people_option := EGO_COMMON_PVT.GET_OPTION_VALUE('EGO_DEFAULT_STYLE_PEOPLE');

    Debug_Conc_Log('Copy_Item_People_From_Style: Style to SKU copy option value-'||l_def_style_people_option);

    IF NVL(l_def_style_people_option, 'N') = 'N' THEN
      Debug_Conc_Log('Copy_Item_People_From_Style: Style to SKU copy option value is N, so exiting.');
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END IF;

    SELECT OBJECT_ID INTO l_object_id
    FROM FND_OBJECTS
    WHERE OBJ_NAME = 'EGO_ITEM';

    Debug_Conc_Log('Copy_Item_People_From_Style: l_object_id-'||l_object_id);
    FOR i IN c_skus_to_process(l_request_id, l_object_id) LOOP
      Debug_Conc_Log('Copy_Item_People_From_Style: Creating grant for l_inventory_item_id, l_organization_id, l_menu_name, l_grantee_type, l_grantee_key, l_end_date='||
                      i.INVENTORY_ITEM_ID||','|| i.ORGANIZATION_ID||','|| i.MENU_NAME||','|| i.GRANTEE_TYPE||','|| i.GRANTEE_KEY||','|| i.END_DATE);

      FND_GRANTS_PKG.GRANT_FUNCTION(
              p_api_version        => 1.0,
              p_menu_name          => i.MENU_NAME,
              p_object_name        => 'EGO_ITEM',
              p_instance_type      => 'INSTANCE',
              p_instance_set_id    => NULL,
              p_instance_pk1_value => TO_CHAR(i.INVENTORY_ITEM_ID),
              p_instance_pk2_value => TO_CHAR(i.ORGANIZATION_ID),
              p_grantee_type       => i.GRANTEE_TYPE,
              p_grantee_key        => i.GRANTEE_KEY,
              p_start_date         => SYSDATE,
              p_end_date           => i.END_DATE,
              x_grant_guid         => l_grant_guid,
              x_success            => l_return_status,
              x_errorcode          => l_errorcode
          );

      Debug_Conc_Log('Copy_Item_People_From_Style: Returned with l_return_status,l_errorcode='||l_return_status||','||l_errorcode);
      IF l_return_status = FND_API.G_TRUE THEN
        l_ret_status := '0';
      ELSE
        l_ret_status := '2';
      END IF;

      IF NVL(RETCODE, '0') < l_ret_status THEN
        RETCODE := l_ret_status;
        ERRBUF := l_errorcode;
      END IF;
    END LOOP;

    COMMIT;
    Debug_Conc_Log('Copy_Item_People_From_Style: Done with - RETCODE , ERRBUF='||RETCODE ||','|| ERRBUF);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Copy_Item_People_From_Style: Error with - RETCODE , ERRBUF='||RETCODE ||','|| ERRBUF);
  END Copy_Item_People_From_Style;


  /*
   * This method copies the LC Project
   */
  PROCEDURE Copy_LC_Projects( retcode               OUT NOCOPY VARCHAR2,
                              errbuf                OUT NOCOPY VARCHAR2,
                              p_batch_id                       NUMBER
                            )
  IS
    CURSOR c_intf_rows (c_request_id IN NUMBER) IS
      SELECT
        msii.INVENTORY_ITEM_ID AS DEST_ITEM_ID,
        msii.ORGANIZATION_ID,
        msii.STYLE_ITEM_ID      AS SOURCE_ITEM_ID,
        (SELECT MAX(mirb.REVISION_ID)
         FROM MTL_ITEM_REVISIONS_B mirb
         WHERE mirb.INVENTORY_ITEM_ID = msii.STYLE_ITEM_ID
           AND mirb.ORGANIZATION_ID   = msii.ORGANIZATION_ID
           AND mirb.EFFECTIVITY_DATE <= SYSDATE
        ) AS SOURCE_REVISION_ID,
        (SELECT MAX(mirb.REVISION_ID)
         FROM MTL_ITEM_REVISIONS_B mirb
         WHERE mirb.INVENTORY_ITEM_ID = msii.INVENTORY_ITEM_ID
           AND mirb.ORGANIZATION_ID   = msii.ORGANIZATION_ID
           AND mirb.EFFECTIVITY_DATE <= SYSDATE
        ) AS DEST_REVISION_ID
      FROM
        MTL_SYSTEM_ITEMS_INTERFACE msii,
        MTL_PARAMETERS mp
      WHERE msii.SET_PROCESS_ID   = p_batch_id
        AND msii.PROCESS_FLAG     = 7
        AND msii.TRANSACTION_TYPE = 'CREATE'
        AND msii.REQUEST_ID       = c_request_id
        AND msii.ORGANIZATION_ID  = mp.ORGANIZATION_ID
        AND mp.ORGANIZATION_ID    = mp.MASTER_ORGANIZATION_ID
        AND msii.STYLE_ITEM_FLAG  = 'N';

    l_return_status             VARCHAR2(10);
    l_errorcode                 VARCHAR2(10);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(4000);
    l_ret_status                VARCHAR2(10);
    l_def_style_project_option  VARCHAR2(1);
    l_copy_people_option        VARCHAR2(1);
    l_request_id                NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_inventory_item_id         NUMBER;
    l_organization_id           NUMBER;
  BEGIN
    Debug_Conc_Log('Copy_LC_Projects: Starting');
    RETCODE := '0';
    l_def_style_project_option := EGO_COMMON_PVT.GET_OPTION_VALUE('EGO_DEFAULT_STYLE_LC_PROJS');

    Debug_Conc_Log('Copy_LC_Projects: Style to SKU copy option value-'||l_def_style_project_option);

    IF NVL(l_def_style_project_option, 'N') = 'N' THEN
      Debug_Conc_Log('Copy_LC_Projects: Style to SKU defaulting option valueis N, so exiting.');
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END IF;

    FOR i IN c_intf_rows(l_request_id) LOOP
      Debug_Conc_Log('Copy_LC_Projects: Copying Item Level Projects for source_item_id, organization_id, dest_item_id='||
                      i.SOURCE_ITEM_ID||','|| i.ORGANIZATION_ID|| i.DEST_ITEM_ID);
      EGO_LIFECYCLE_USER_PUB.Copy_Project
      (
         p_api_version       => 1.0,
         p_commit            => FND_API.G_FALSE,
         p_source_item_id    => i.SOURCE_ITEM_ID,
         p_source_org_id     => i.ORGANIZATION_ID,
         p_source_rev_id     => NULL,
         p_association_type  => 'EGO_ITEM_PROJ_ASSOC_TYPE',
         p_association_code  => 'LIFECYCLE_TRACKING',
         p_dest_item_id      => i.DEST_ITEM_ID,
         p_dest_org_id       => i.ORGANIZATION_ID,
         p_dest_rev_id       => NULL,
         x_return_status     => l_return_status,
         x_error_code        => l_errorcode,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data
      );
      Debug_Conc_Log('Copy_LC_Projects: Done with l_return_status, l_errorcode, l_msg_data-'||l_return_status||','|| l_errorcode||','|| l_msg_data);
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_ret_status := '0';
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_ret_status := '1';
      ELSE
        l_ret_status := '2';
      END IF;

      IF NVL(RETCODE, '0') < l_ret_status THEN
        RETCODE := l_ret_status;
        ERRBUF := l_msg_data;
      END IF;

      Debug_Conc_Log('Copy_LC_Projects: Copying Revision Level Project for source_item_id, organization_id, source_revision_id, dest_item_id, dest_revision_id='||
                      i.SOURCE_ITEM_ID||','|| i.ORGANIZATION_ID||','|| i.SOURCE_REVISION_ID||','|| i.DEST_ITEM_ID||','|| i.DEST_REVISION_ID);
      EGO_LIFECYCLE_USER_PUB.Copy_Project
      (
         p_api_version       => 1.0,
         p_commit            => FND_API.G_FALSE,
         p_source_item_id    => i.SOURCE_ITEM_ID,
         p_source_org_id     => i.ORGANIZATION_ID,
         p_source_rev_id     => i.SOURCE_REVISION_ID,
         p_association_type  => 'EGO_ITEM_PROJ_ASSOC_TYPE',
         p_association_code  => 'LIFECYCLE_TRACKING',
         p_dest_item_id      => i.DEST_ITEM_ID,
         p_dest_org_id       => i.ORGANIZATION_ID,
         p_dest_rev_id       => i.DEST_REVISION_ID,
         x_return_status     => l_return_status,
         x_error_code        => l_errorcode,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data
      );
      Debug_Conc_Log('Copy_LC_Projects: Done with l_return_status, l_errorcode, l_msg_data-'||l_return_status||','|| l_errorcode||','|| l_msg_data);
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_ret_status := '0';
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_ret_status := '1';
      ELSE
        l_ret_status := '2';
      END IF;

      IF NVL(RETCODE, '0') < l_ret_status THEN
        RETCODE := l_ret_status;
        ERRBUF := l_msg_data;
      END IF;
    END LOOP;  -- FOR i IN c_intf_rows
    COMMIT;
    Debug_Conc_Log('Copy_LC_Projects: Done with - RETCODE , ERRBUF='||RETCODE ||','|| ERRBUF);
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Copy_LC_Projects: Error with - RETCODE , ERRBUF='||RETCODE ||','|| ERRBUF);
  END Copy_LC_Projects;

  PROCEDURE Propagate_Item_Num_To_Child (
                                           p_batch_id                  NUMBER
                                         , p_ss_id                     NUMBER
                                         , p_ss_ref                    VARCHAR2
                                         , p_old_item_number           VARCHAR2
                                         , p_item_number               VARCHAR2
                                        )
  IS
    TYPE ROWID_TYPE_TBL IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    l_pdh_ss_id   NUMBER := EGO_IMPORT_PVT.Get_Pdh_Source_System_Id;
    l_row_id_tbl  ROWID_TYPE_TBL;
    l_err_txt     VARCHAR2(4000);
    l_ret_code    VARCHAR2(100);
  BEGIN
    -- nulling out all the segments
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE
    SET ITEM_NUMBER = p_item_number,
        SEGMENT1 = NULL,
        SEGMENT2 = NULL,
        SEGMENT3 = NULL,
        SEGMENT4 = NULL,
        SEGMENT5 = NULL,
        SEGMENT6 = NULL,
        SEGMENT7 = NULL,
        SEGMENT8 = NULL,
        SEGMENT9 = NULL,
        SEGMENT10 = NULL,
        SEGMENT11 = NULL,
        SEGMENT12 = NULL,
        SEGMENT13 = NULL,
        SEGMENT14 = NULL,
        SEGMENT15 = NULL,
        SEGMENT16 = NULL,
        SEGMENT17 = NULL,
        SEGMENT18 = NULL,
        SEGMENT19 = NULL,
        SEGMENT20 = NULL
    WHERE PROCESS_FLAG     = 1
      AND SET_PROCESS_ID   = p_batch_id
      AND SOURCE_SYSTEM_ID = p_ss_id
      AND ( ITEM_NUMBER = p_old_item_number OR SOURCE_SYSTEM_REFERENCE = p_ss_ref )
    RETURNING ROWID BULK COLLECT INTO l_row_id_tbl;

    IF l_row_id_tbl IS NOT NULL AND l_row_id_tbl.COUNT > 0 THEN
      FOR i IN l_row_id_tbl.FIRST..l_row_id_tbl.LAST LOOP
        l_ret_code := INVPUOPI.mtl_pr_parse_item_number
                        (
                          item_number => p_item_number,
                          item_id     => null,
                          trans_id    => null,
                          org_id      => null,
                          err_text    => l_err_txt,
                          p_rowid     => l_row_id_tbl(i)
                        );
      END LOOP;
    END IF;

    -- Fix for bug#9660659 Start
    --UPDATE MTL_ITEM_REVISIONS_INTERFACE
    --SET ITEM_NUMBER = p_item_number
    --WHERE PROCESS_FLAG     = 1
    --  AND SET_PROCESS_ID   = p_batch_id
    --  AND SOURCE_SYSTEM_ID = p_ss_id
    --  AND ( ITEM_NUMBER = p_old_item_number OR SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    IF(p_ss_ref IS NOT null) THEN
      UPDATE MTL_ITEM_REVISIONS_INTERFACE
        SET ITEM_NUMBER = p_item_number
      WHERE PROCESS_FLAG     = 1
      AND SET_PROCESS_ID   = p_batch_id
      AND SOURCE_SYSTEM_ID = p_ss_id
      AND SOURCE_SYSTEM_REFERENCE = p_ss_ref;
    ELSE
      UPDATE MTL_ITEM_REVISIONS_INTERFACE
        SET ITEM_NUMBER = p_item_number
      WHERE PROCESS_FLAG     = 1
      AND SET_PROCESS_ID   = p_batch_id
      AND ITEM_NUMBER = p_old_item_number;
    END IF;
    -- Fix for bug#9660659 End

    UPDATE MTL_ITEM_CATEGORIES_INTERFACE
    SET ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG     = 1
      AND SET_PROCESS_ID   = p_batch_id
      AND SOURCE_SYSTEM_ID = p_ss_id
      AND ( ITEM_NUMBER = p_old_item_number OR SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE EGO_ITEM_PEOPLE_INTF
    SET ITEM_NUMBER = p_item_number
    WHERE PROCESS_STATUS   = 1
      AND DATA_SET_ID      = p_batch_id
      AND SOURCE_SYSTEM_ID = p_ss_id
      AND ( ITEM_NUMBER = p_old_item_number OR SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    -- Fix for bug#9660659 Start
    --UPDATE EGO_ITM_USR_ATTR_INTRFC
    --SET ITEM_NUMBER = p_item_number
    --WHERE PROCESS_STATUS   = 2
    --  AND DATA_SET_ID      = p_batch_id
    --  AND SOURCE_SYSTEM_ID = p_ss_id
    --  AND ( ITEM_NUMBER = p_old_item_number OR SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    IF(p_ss_ref IS NOT null) THEN
      UPDATE /*+ index(EGO_ITM_USR_ATTR_INTRFC, EGO_ITM_USR_ATTR_INTRFC_N5) */ EGO_ITM_USR_ATTR_INTRFC /* Bug 9678667 - Added the hint */
       SET ITEM_NUMBER = p_item_number
      WHERE PROCESS_STATUS   = 2
      AND DATA_SET_ID      = p_batch_id
      AND SOURCE_SYSTEM_ID = p_ss_id
      AND SOURCE_SYSTEM_REFERENCE = p_ss_ref;
    ELSE
      UPDATE EGO_ITM_USR_ATTR_INTRFC
      SET ITEM_NUMBER = p_item_number
      WHERE PROCESS_STATUS   = 2
      AND DATA_SET_ID      = p_batch_id
      AND ITEM_NUMBER = p_old_item_number;
    END IF;
    -- Fix for bug#9660659 End

    UPDATE EGO_AML_INTF
    SET ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG     = 1
      AND DATA_SET_ID      = p_batch_id
      AND SOURCE_SYSTEM_ID = p_ss_id
      AND ( ITEM_NUMBER = p_old_item_number OR SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    -- propagating to BOM tables
    UPDATE BOM_BILL_OF_MTLS_INTERFACE
    SET ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( ITEM_NUMBER = p_old_item_number OR SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_INVENTORY_COMPS_INTERFACE
    SET COMPONENT_ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( COMPONENT_ITEM_NUMBER = p_old_item_number OR COMP_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_INVENTORY_COMPS_INTERFACE
    SET ASSEMBLY_ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( ASSEMBLY_ITEM_NUMBER = p_old_item_number OR PARENT_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_SUB_COMPS_INTERFACE
    SET ASSEMBLY_ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( ASSEMBLY_ITEM_NUMBER = p_old_item_number OR PARENT_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_SUB_COMPS_INTERFACE
    SET COMPONENT_ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( COMPONENT_ITEM_NUMBER = p_old_item_number OR COMP_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_SUB_COMPS_INTERFACE
    SET SUBSTITUTE_COMP_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( SUBSTITUTE_COMP_NUMBER = p_old_item_number OR SUBCOM_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_REF_DESGS_INTERFACE
    SET ASSEMBLY_ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( ASSEMBLY_ITEM_NUMBER = p_old_item_number OR PARENT_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_REF_DESGS_INTERFACE
    SET COMPONENT_ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( COMPONENT_ITEM_NUMBER = p_old_item_number OR COMP_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_COMPONENT_OPS_INTERFACE
    SET ASSEMBLY_ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( ASSEMBLY_ITEM_NUMBER = p_old_item_number OR PARENT_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

    UPDATE BOM_COMPONENT_OPS_INTERFACE
    SET COMPONENT_ITEM_NUMBER = p_item_number
    WHERE PROCESS_FLAG = 1
      AND BATCH_ID     = p_batch_id
      AND ( COMPONENT_ITEM_NUMBER = p_old_item_number OR COMP_SOURCE_SYSTEM_REFERENCE = p_ss_ref );

  END Propagate_Item_Num_To_Child;


  PROCEDURE Process_Import_Copy_Options
      (   p_api_version           IN          NUMBER
      ,   p_commit                IN          VARCHAR2 DEFAULT FND_API.G_TRUE
      ,   p_batch_id              IN          NUMBER
      ,   p_copy_option           IN          VARCHAR2
      ,   p_template_name         IN          VARCHAR2
      ,   p_template_sequence     IN          NUMBER
      ,   p_selection_flag        IN          VARCHAR2
      ,   x_return_status         OUT NOCOPY  VARCHAR2
      ,   x_msg_count             OUT NOCOPY  NUMBER
      ,   x_msg_data              OUT NOCOPY  VARCHAR2
      )
  IS
    CURSOR check_template_name (cp_template_name VARCHAR2) IS
      SELECT template_id
      FROM   mtl_item_templates
      WHERE  template_name = cp_template_name;

    CURSOR c_batch_exists IS
      SELECT 1 FROM mtl_system_items_interface
      WHERE set_process_id = p_batch_id
        AND process_flag   = 1;

    l_template_id NUMBER;
    l_sequence    NUMBER;
    l_select_flag VARCHAR2(1);
    l_error       NUMBER := 0;
    l_sysdate     DATE := sysdate;
    l_user_id     NUMBER := FND_GLOBAL.USER_ID;
    l_batch_exists NUMBER := 0;
  BEGIN
    IF ((p_batch_id IS NULL) OR (p_batch_id = 0)) THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;
      x_msg_data := 'Batch Id is mandatory';
      l_error := 1;
    ELSE
      OPEN  c_batch_exists;
      FETCH c_batch_exists INTO l_batch_exists;
      CLOSE c_batch_exists;

      IF l_batch_exists = 0 THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Batch contains no items';
        l_error := 1;
      END IF;
    END IF;

    IF p_copy_option = 'APPLY_TEMPLATE' THEN
      l_sequence := p_template_sequence;
      OPEN  check_template_name(cp_template_name => p_template_name);
      FETCH check_template_name INTO l_template_id;
      CLOSE check_template_name;

      IF l_template_id IS NULL THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Invalid template Name';
        l_error := 1;
      END IF;
    ELSIF p_copy_option = 'COPY_FIRST' THEN
      IF p_selection_flag IS NULL OR p_selection_flag NOT IN ('Y', 'N') THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Invalid Copy Option and Selection Flag combination';
        l_error := 1;
      ELSE
        l_select_flag := p_selection_flag;
      END IF;

    END IF;

    IF l_error = 0 THEN
      INSERT INTO ego_import_copy_options
      ( batch_id,
        copy_option,
        template_id,
        template_sequence,
        attr_group_id,
        attach_category_id,
        selection_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by
      )
      VALUES
      ( p_batch_id,
        p_copy_option,
        l_template_id,
        l_sequence,
        null,
        null,
        l_select_flag,
        l_sysdate,
        l_user_id,
        l_sysdate,
        l_user_id
      );
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;
      x_msg_data := SQLERRM;
  END Process_Import_Copy_Options;

  PROCEDURE Process_Variant_Attrs
      (   p_api_version           IN          NUMBER
      ,   p_commit                IN          VARCHAR2 DEFAULT FND_API.G_TRUE
      ,   p_batch_id              IN          NUMBER
      ,   p_item_number           IN          VARCHAR2
      ,   p_organization_id       IN          NUMBER
      ,   p_attr_group_type       IN          VARCHAR2
      ,   p_attr_group_name       IN          VARCHAR2
      ,   p_attr_name             IN          VARCHAR2
      ,   p_data_level_name       IN          VARCHAR2
      ,   p_attr_value_num        IN          NUMBER
      ,   p_attr_value_str        IN          VARCHAR2
      ,   p_attr_value_date       IN          DATE
      ,   x_return_status         OUT NOCOPY  VARCHAR2
      ,   x_msg_count             OUT NOCOPY  NUMBER
      ,   x_msg_data              OUT NOCOPY  VARCHAR2 )
  IS

     CURSOR c_valid_record
     IS
       SELECT 1
         FROM EGO_ATTRS_V
        WHERE UPPER(ATTR_GROUP_TYPE) = UPPER(p_attr_group_type)
          AND UPPER(ATTR_GROUP_NAME) = UPPER(p_attr_group_name)
         AND UPPER(ATTR_NAME)       = UPPER(p_attr_name)
          AND APPLICATION_ID         = 431;

     CURSOR c_valid_data_level
     IS
       SELECT 1
         FROM ego_attr_group_dl
        WHERE data_level_id IN (SELECT data_level_id FROM ego_data_level_b
                                 WHERE attr_group_type = p_attr_group_type
                                   AND data_level_name = p_data_level_name
                                   AND application_id = 431)
          AND attr_group_id IN (SELECT attr_group_id FROM ego_attr_groups_v
                                 WHERE attr_group_type = p_attr_group_type
                                   AND attr_group_name = p_attr_group_name
                                   AND application_id = 431);

     CURSOR c_item_details
     IS
       SELECT style_item_flag,mtl_system_items_interface_s.NEXTVAL,
              item_catalog_group_id
         FROM mtl_system_items_interface
        WHERE item_number = p_item_number
         AND organization_id = p_organization_id
         AND set_process_id = p_batch_id
           AND process_flag = 1;

     CURSOR c_attr_type
     IS
        SELECT variant FROM ego_obj_attr_grp_assocs_v
         WHERE attr_group_type = p_attr_group_type
           AND attr_group_name = p_attr_group_name
           AND application_id  = 431;

     CURSOR c_group_record
     IS
        SELECT MAX(ROW_IDENTIFIER), ITEM_CATALOG_GROUP_ID
          FROM EGO_ITM_USR_ATTR_INTRFC
         WHERE ITEM_NUMBER = p_item_number
           AND ORGANIZATION_ID = p_organization_id
           AND DATA_SET_ID = p_batch_id
           AND PROCESS_STATUS = 2
           AND ATTR_GROUP_TYPE = p_attr_group_type
           AND ATTR_GROUP_INT_NAME = p_attr_group_name
        GROUP BY ROW_IDENTIFIER,ITEM_CATALOG_GROUP_ID ;

     l_grp_row_identifier        NUMBER;
     l_grp_item_catalog_group_id NUMBER;
     l_row_identifier            NUMBER;
     l_item_catalog_group_id     NUMBER;
     l_sysdate                   DATE := sysdate;
     l_valid_record              NUMBER := 0;
     l_valid_data_level          NUMBER := 0;

     l_attr_value_num  NUMBER;
     l_attr_value_str  VARCHAR2(1000);
     l_attr_value_date DATE;
     l_attr_disp_value VARCHAR2(1000);
     l_style_item_flag VARCHAR2(1);
     l_variant         VARCHAR2(1);

     l_user_id         NUMBER := FND_GLOBAL.USER_ID;
     l_batch_exists    NUMBER := 0;
     l_error           NUMBER := 0;
  BEGIN

     IF ((p_batch_id IS NULL) OR (p_batch_id = 0)) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Batch Id is mandatory';
        l_error := 1;
     END IF;

   /* Validate record passed to interface */
     OPEN  c_valid_record;
     FETCH c_valid_record INTO l_valid_record;
     CLOSE c_valid_record;

     OPEN  c_valid_data_level;
     FETCH c_valid_data_level INTO l_valid_data_level;
     CLOSE c_valid_data_level;

     IF l_valid_record = 0 OR l_valid_data_level = 0 THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := 'Invalid Attr Group Type, Name and Attr Name combination';
        l_error := 1;
     ELSE
      /* Add all attributes for an item in the same batch and same attribute group to one group */
        OPEN  c_group_record;
        FETCH c_group_record INTO l_grp_row_identifier, l_grp_item_catalog_group_id;
        CLOSE c_group_record;

        OPEN  c_item_details;
        FETCH c_item_details INTO l_style_item_flag, l_row_identifier, l_item_catalog_group_id;

        IF c_item_details%NOTFOUND THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           x_msg_count := 1;
           x_msg_data := 'Batch contains no items';
           l_error := 1;
        END IF;

        l_attr_value_num := p_attr_value_num;
        l_attr_value_date := p_attr_value_date;

        OPEN  c_attr_type;
        FETCH c_attr_type INTO l_variant;
        CLOSE c_attr_type;

        IF l_style_item_flag = 'Y' AND l_variant = 'Y' THEN
           l_attr_disp_value := p_attr_value_str;
        ELSE
           l_attr_value_str := p_attr_value_str;
        END IF;
     END IF;

     IF l_error = 0 THEN
        INSERT INTO EGO_ITM_USR_ATTR_INTRFC
        (
                   PROCESS_STATUS
                  ,TRANSACTION_ID
                  ,DATA_SET_ID
                  ,TRANSACTION_TYPE
                  ,ITEM_NUMBER
                  ,ORGANIZATION_ID
                  ,ITEM_CATALOG_GROUP_ID
                  ,SOURCE_SYSTEM_ID
                  ,SOURCE_SYSTEM_REFERENCE
                  ,ROW_IDENTIFIER
                  ,ATTR_GROUP_TYPE
                  ,ATTR_GROUP_INT_NAME
                  ,ATTR_GROUP_ID
                  ,ATTR_INT_NAME
                  ,DATA_LEVEL_NAME
                  ,ATTR_VALUE_STR
                  ,ATTR_VALUE_NUM
                  ,ATTR_VALUE_DATE
                  ,ATTR_DISP_VALUE
                  ,CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE
       )
        VALUES
        (
                   2
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
                  ,p_batch_id
                  ,'SYNC'
                  ,p_item_number
                  ,p_organization_id
                  ,NVL(l_grp_item_catalog_group_id,l_item_catalog_group_id)
                  ,EGO_IMPORT_PVT.get_pdh_source_system_id
                  ,null
                  ,NVL(l_grp_row_identifier,l_row_identifier)
                  ,p_attr_group_type
                  ,p_attr_group_name
                  ,null
                  ,p_attr_name
                  ,p_data_level_name
                  ,l_attr_value_str
                  ,l_attr_value_num
                  ,l_attr_value_date
                  ,l_attr_disp_value
                  ,l_user_id
                  ,l_sysdate
                  ,l_user_id
                  ,l_sysdate
       );

        x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;

  EXCEPTION
    WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;
      x_msg_data := SQLERRM;
  END Process_Variant_Attrs;

  PROCEDURE Get_Interface_Errors( p_batch_id       IN NUMBER,
                                  x_item_err_table OUT NOCOPY EGO_VARCHAR_TBL_TYPE,
                                  x_rev_err_table  OUT NOCOPY EGO_VARCHAR_TBL_TYPE,
                                  x_uda_err_table  OUT NOCOPY EGO_VARCHAR_TBL_TYPE)
  IS
     TYPE transaction_table_type IS TABLE OF
     mtl_system_items_interface.transaction_type%TYPE
     INDEX BY BINARY_INTEGER;

     transaction_table  transaction_table_type;
     l_item_err_table EGO_VARCHAR_TBL_TYPE;
     l_rev_err_table  EGO_VARCHAR_TBL_TYPE;
     l_uda_err_table  EGO_VARCHAR_TBL_TYPE;
  BEGIN

    BEGIN
      SELECT error_message BULK COLLECT INTO l_item_err_table
        FROM mtl_interface_errors
       WHERE transaction_id IN ( SELECT transaction_id
                                   FROM mtl_system_items_interface
                                  WHERE set_process_id = p_batch_id
                                    AND process_flag = 3);
    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

    BEGIN
      SELECT error_message BULK COLLECT INTO l_rev_err_table
        FROM mtl_interface_errors
       WHERE transaction_id IN ( SELECT transaction_id
                                   FROM mtl_item_revisions_interface
                                  WHERE set_process_id = p_batch_id
                                    AND process_flag = 3);
    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

    BEGIN
      SELECT error_message BULK COLLECT INTO l_uda_err_table
        FROM mtl_interface_errors
       WHERE transaction_id IN ( SELECT transaction_id
                                   FROM EGO_ITM_USR_ATTR_INTRFC
                                  WHERE data_set_id = p_batch_id
                                    AND process_status = 3);
    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

    x_item_err_table := l_item_err_table;
    x_rev_err_table  := l_rev_err_table;
    x_uda_err_table  := l_uda_err_table;
  EXCEPTION
    WHEN others THEN
       null;
  END get_interface_errors;

  /*
   * This method will stale out all the rows in batch
   * that are not latest for enabled_for_data_pool batches
   */
  PROCEDURE Validate_Timestamp_In_Batch(retcode     OUT NOCOPY VARCHAR2,
                                        errbuf      OUT NOCOPY VARCHAR2,
                                        p_batch_id  IN NUMBER)
  IS
    l_item_master_dl_id        NUMBER;
    l_enabled_for_data_pool    VARCHAR2(1);
    l_item_detail_tbl          ITEM_DETAIL_TBL;
    l_user_id                  NUMBER := FND_GLOBAL.USER_ID;
    l_login_id                 NUMBER := FND_GLOBAL.LOGIN_ID;
    l_prog_appid               NUMBER := FND_GLOBAL.PROG_APPL_ID;
    l_prog_id                  NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;
    l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    l_ret_code                 VARCHAR2(10);
    l_err_buf                  VARCHAR2(4000);
  BEGIN
    Debug_Conc_Log('Validate_Timestamp_In_Batch: Starting p_batch_id='||p_batch_id);
    BEGIN
      SELECT NVL(ENABLED_FOR_DATA_POOL, 'N') INTO l_enabled_for_data_pool
      FROM EGO_IMPORT_OPTION_SETS
      WHERE BATCH_ID = p_batch_id;
    EXCEPTION WHEN OTHERS THEN
      Debug_Conc_Log('Validate_Timestamp_In_Batch: exception='||SQLERRM);
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END;

    Debug_Conc_Log('Validate_Timestamp_In_Batch: l_enabled_for_data_pool='||l_enabled_for_data_pool);
    IF l_enabled_for_data_pool = 'N' THEN
      RETCODE := '0';
      ERRBUF := NULL;
      Debug_Conc_Log('Validate_Timestamp_In_Batch: Done');
      RETURN;
    END IF;

    BEGIN
      SELECT DATA_LEVEL_ID INTO l_item_master_dl_id
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE = 'EGO_MASTER_ITEMS'
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME = 'ITEM_ORG';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      Debug_Conc_Log('Validate_Timestamp_In_Batch: No data found for EGO_MASTER_ITEMS');
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END;

    Debug_Conc_Log('Validate_Timestamp_In_Batch: l_item_master_dl_id='||l_item_master_dl_id);
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE msii
    SET PROCESS_FLAG = 14
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG   = 4
      AND BUNDLE_ID      = (SELECT MAX(BUNDLE_ID) KEEP (DENSE_RANK FIRST ORDER BY MESSAGE_TIMESTAMP DESC )
                            FROM MTL_SYSTEM_ITEMS_INTERFACE msii2
                            WHERE msii2.INVENTORY_ITEM_ID = msii.INVENTORY_ITEM_ID
                              AND msii2.ORGANIZATION_ID   = msii.ORGANIZATION_ID
                              AND msii2.SET_PROCESS_ID    = msii.SET_PROCESS_ID
                              AND msii2.PROCESS_FLAG      = msii.PROCESS_FLAG
                            );

    Debug_Conc_Log('Validate_Timestamp_In_Batch: Updated MSII to 14, rowcount='||SQL%ROWCOUNT);
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE msii
    SET PROCESS_FLAG = DECODE(PROCESS_FLAG, 4, 16, 4)
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG   IN ( 4, 14 );

    UPDATE MTL_ITEM_REVISIONS_INTERFACE miri
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG = 1
      AND ROWID <> (SELECT MIN(miri2.ROWID)
                    FROM MTL_SYSTEM_ITEMS_INTERFACE msii, MTL_ITEM_REVISIONS_INTERFACE miri2
                    WHERE msii.INVENTORY_ITEM_ID   = miri2.INVENTORY_ITEM_ID
                      AND msii.ORGANIZATION_ID     = miri2.ORGANIZATION_ID
                      AND msii.SET_PROCESS_ID      = miri2.SET_PROCESS_ID
                      AND msii.SET_PROCESS_ID      = miri.SET_PROCESS_ID
                      AND msii.INVENTORY_ITEM_ID   = miri.INVENTORY_ITEM_ID
                      AND msii.ORGANIZATION_ID     = miri.ORGANIZATION_ID
                      AND msii.PROCESS_FLAG        = 16
                      AND miri2.PROCESS_FLAG       = 1
                      AND msii.TRANSACTION_TYPE    = 'CREATE'
                      AND miri2.TRANSACTION_TYPE   = 'CREATE'
                   );

    l_item_detail_tbl := NULL;

    Debug_Conc_Log('Validate_Timestamp_In_Batch: Updated MSII to 16,4, rowcount='||SQL%ROWCOUNT);

    UPDATE EGO_ITM_USR_ATTR_INTRFC eiuai
    SET PROCESS_STATUS         = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE DATA_SET_ID    = p_batch_id
      AND PROCESS_STATUS = 2
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE msii.SET_PROCESS_ID      = eiuai.DATA_SET_ID
                    AND msii.PROCESS_FLAG        = 16
                    AND eiuai.INVENTORY_ITEM_ID  = msii.INVENTORY_ITEM_ID
                    AND eiuai.ORGANIZATION_ID    = msii.ORGANIZATION_ID
                    AND eiuai.BUNDLE_ID          = msii.BUNDLE_ID
                 )
    RETURNING
      TRANSACTION_ID,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      ITEM_NUMBER,
      SOURCE_SYSTEM_REFERENCE,
      SOURCE_SYSTEM_ID,
      DATA_LEVEL_ID,
      PK1_VALUE,
      PK2_VALUE,
      PROCESS_STATUS
    BULK COLLECT INTO l_item_detail_tbl;

    Debug_Conc_Log('Validate_Timestamp_In_Batch: Updated EGO_ITM_USR_ATTR_INTRFC rowcount='||SQL%ROWCOUNT);
    IF l_item_detail_tbl IS NOT NULL THEN
      Debug_Conc_Log('Validate_Timestamp_In_Batch: Logging errors for EGO_ITM_USR_ATTR_INTRFC');
      Log_Error_For_Timestamp_Val(RETCODE               => l_ret_code,
                                  ERRBUF                => l_err_buf,
                                  p_item_detail_tbl     => l_item_detail_tbl,
                                  p_show_prod_timestemp => FALSE,
                                  p_intf_table_name     => 'EGO_ITM_USR_ATTR_INTRFC',
                                  p_user_id             => l_user_id,
                                  p_login_id            => l_login_id,
                                  p_prog_appid          => l_prog_appid,
                                  p_prog_id             => l_prog_id,
                                  p_req_id              => l_request_id
                                 );
      Debug_Conc_Log('Validate_Timestamp_In_Batch: Done Logging errors with l_ret_code,l_err_buf='||l_ret_code||','||l_err_buf);
    END IF;

    l_item_detail_tbl := NULL;

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF eiai
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE BATCH_ID     = p_batch_id
      AND PROCESS_FLAG = 1
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE msii.SET_PROCESS_ID     = eiai.BATCH_ID
                    AND msii.PROCESS_FLAG       = 16
                    AND eiai.INVENTORY_ITEM_ID  = msii.INVENTORY_ITEM_ID
                    AND eiai.ORGANIZATION_ID    = msii.ORGANIZATION_ID
                    AND eiai.BUNDLE_ID          = msii.BUNDLE_ID
                 )
    RETURNING
      TRANSACTION_ID,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      ITEM_NUMBER,
      SOURCE_SYSTEM_REFERENCE,
      SOURCE_SYSTEM_ID,
      DATA_LEVEL_ID,
      PK1_VALUE,
      PK2_VALUE,
      PROCESS_FLAG
    BULK COLLECT INTO l_item_detail_tbl;

    Debug_Conc_Log('Validate_Timestamp_In_Batch: Updated EGO_ITEM_ASSOCIATIONS_INTF rowcount='||SQL%ROWCOUNT);
    IF l_item_detail_tbl IS NOT NULL THEN
      Debug_Conc_Log('Validate_Timestamp_In_Batch: Logging errors for EGO_ITEM_ASSOCIATIONS_INTF');
      Log_Error_For_Timestamp_Val(RETCODE               => l_ret_code,
                                  ERRBUF                => l_err_buf,
                                  p_item_detail_tbl     => l_item_detail_tbl,
                                  p_show_prod_timestemp => FALSE,
                                  p_intf_table_name     => 'EGO_ITEM_ASSOCIATIONS_INTF',
                                  p_user_id             => l_user_id,
                                  p_login_id            => l_login_id,
                                  p_prog_appid          => l_prog_appid,
                                  p_prog_id             => l_prog_id,
                                  p_req_id              => l_request_id
                                 );
      Debug_Conc_Log('Validate_Timestamp_In_Batch: Done Logging errors with l_ret_code,l_err_buf='||l_ret_code||','||l_err_buf);
    END IF;

    l_item_detail_tbl := NULL;

    UPDATE MTL_ITEM_CATEGORIES_INTERFACE mici
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG   = 1
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE msii.SET_PROCESS_ID     = mici.SET_PROCESS_ID
                    AND msii.PROCESS_FLAG       = 16
                    AND mici.INVENTORY_ITEM_ID  = msii.INVENTORY_ITEM_ID
                    AND mici.ORGANIZATION_ID    = msii.ORGANIZATION_ID
                    AND mici.BUNDLE_ID          = msii.BUNDLE_ID
                 );

    Debug_Conc_Log('Validate_Timestamp_In_Batch: Updated MTL_ITEM_CATEGORIES_INTERFACE rowcount='||SQL%ROWCOUNT);
    UPDATE BOM_BILL_OF_MTLS_INTERFACE bbmi
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE BATCH_ID = p_batch_id
      AND PROCESS_FLAG   = 1
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE msii.SET_PROCESS_ID   = bbmi.BATCH_ID
                    AND msii.PROCESS_FLAG     = 16
                    AND bbmi.ASSEMBLY_ITEM_ID = msii.INVENTORY_ITEM_ID
                    AND bbmi.ORGANIZATION_ID  = msii.ORGANIZATION_ID
                    AND bbmi.BUNDLE_ID        = msii.BUNDLE_ID
                 );

    Debug_Conc_Log('Validate_Timestamp_In_Batch: Updated BOM_BILL_OF_MTLS_INTERFACE rowcount='||SQL%ROWCOUNT);
    UPDATE BOM_INVENTORY_COMPS_INTERFACE bici
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE BATCH_ID = p_batch_id
      AND PROCESS_FLAG   = 1
      AND EXISTS (SELECT NULL
                  FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE msii.SET_PROCESS_ID    = bici.BATCH_ID
                    AND msii.PROCESS_FLAG      = 16
                    AND bici.COMPONENT_ITEM_ID = msii.INVENTORY_ITEM_ID
                    AND bici.ORGANIZATION_ID   = msii.ORGANIZATION_ID
                    AND bici.BUNDLE_ID         = msii.BUNDLE_ID
                 );

    Debug_Conc_Log('Validate_Timestamp_In_Batch: Updated BOM_INVENTORY_COMPS_INTERFACE rowcount='||SQL%ROWCOUNT);

    UPDATE MTL_SYSTEM_ITEMS_INTERFACE msii
    SET PROCESS_FLAG           = 6,
        REQUEST_ID             = l_request_id,
        PROGRAM_ID             = l_prog_id,
        PROGRAM_APPLICATION_ID = l_prog_appid,
        LAST_UPDATE_DATE       = SYSDATE,
        LAST_UPDATED_BY        = l_user_id
    WHERE SET_PROCESS_ID = p_batch_id
      AND PROCESS_FLAG   = 16
    RETURNING
      TRANSACTION_ID,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      ITEM_NUMBER,
      SOURCE_SYSTEM_REFERENCE,
      SOURCE_SYSTEM_ID,
      l_item_master_dl_id,
      -1,
      -1,
      PROCESS_FLAG
    BULK COLLECT INTO l_item_detail_tbl;

    Debug_Conc_Log('Validate_Timestamp_In_Batch: Updated MSII to 6, rowcount='||SQL%ROWCOUNT);
    IF l_item_detail_tbl IS NOT NULL THEN
      Debug_Conc_Log('Validate_Timestamp_In_Batch: Logging errors for MTL_SYSTEM_ITEMS_INTERFACE');
      Log_Error_For_Timestamp_Val(RETCODE               => l_ret_code,
                                  ERRBUF                => l_err_buf,
                                  p_item_detail_tbl     => l_item_detail_tbl,
                                  p_show_prod_timestemp => FALSE,
                                  p_intf_table_name     => 'MTL_SYSTEM_ITEMS_INTERFACE',
                                  p_user_id             => l_user_id,
                                  p_login_id            => l_login_id,
                                  p_prog_appid          => l_prog_appid,
                                  p_prog_id             => l_prog_id,
                                  p_req_id              => l_request_id
                                 );
      Debug_Conc_Log('Validate_Timestamp_In_Batch: Done Logging errors with l_ret_code,l_err_buf='||l_ret_code||','||l_err_buf);
    END IF;

    COMMIT;
    RETCODE := '0';
    ERRBUF := NULL;
    Debug_Conc_Log('Validate_Timestamp_In_Batch: Done Successfully');
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Validate_Timestamp_In_Batch: Error - '||SQLERRM);
  END Validate_Timestamp_In_Batch;


  PROCEDURE Update_Timestamp_In_Prod(retcode     OUT NOCOPY VARCHAR2,
                                     errbuf      OUT NOCOPY VARCHAR2,
                                     p_batch_id  IN NUMBER)
  IS
    l_item_master_dl_id        NUMBER;
    l_enabled_for_data_pool    VARCHAR2(1);
    l_user_id                  NUMBER := FND_GLOBAL.USER_ID;
    l_login_id                 NUMBER := FND_GLOBAL.LOGIN_ID;
    l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  BEGIN
    Debug_Conc_Log('Update_Timestamp_In_Prod: Starting p_batch_id='||p_batch_id);
    BEGIN
      SELECT NVL(ENABLED_FOR_DATA_POOL, 'N') INTO l_enabled_for_data_pool
      FROM EGO_IMPORT_OPTION_SETS
      WHERE BATCH_ID = p_batch_id;
    EXCEPTION WHEN OTHERS THEN
      Debug_Conc_Log('Update_Timestamp_In_Prod: exception='||SQLERRM);
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END;

    Debug_Conc_Log('Update_Timestamp_In_Prod: l_enabled_for_data_pool='||l_enabled_for_data_pool);
    IF l_enabled_for_data_pool = 'N' THEN
      RETCODE := '0';
      ERRBUF := NULL;
      Debug_Conc_Log('Update_Timestamp_In_Prod: Done');
      RETURN;
    END IF;

    BEGIN
      SELECT DATA_LEVEL_ID INTO l_item_master_dl_id
      FROM EGO_DATA_LEVEL_B
      WHERE ATTR_GROUP_TYPE = 'EGO_MASTER_ITEMS'
        AND APPLICATION_ID = 431
        AND DATA_LEVEL_NAME = 'ITEM_ORG';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      Debug_Conc_Log('Update_Timestamp_In_Prod: No data found for EGO_MASTER_ITEMS');
      RETCODE := '0';
      ERRBUF := NULL;
      RETURN;
    END;

    Debug_Conc_Log('Update_Timestamp_In_Prod: l_item_master_dl_id='||l_item_master_dl_id);
    MERGE INTO EGO_INBOUND_MSG_EXT eime
    USING ( SELECT
              SOURCE_SYSTEM_ID,
              l_item_master_dl_id AS DATA_LEVEL_ID,
              INVENTORY_ITEM_ID,
              ORGANIZATION_ID,
              NULL AS SUPPLIER_ID,
              NULL AS SUPPLIER_SITE_ID,
              MAX(MESSAGE_TIMESTAMP) AS MESSAGE_TIMESTAMP
            FROM MTL_SYSTEM_ITEMS_INTERFACE
            WHERE SET_PROCESS_ID = p_batch_id
              AND PROCESS_FLAG   = 7
              AND REQUEST_ID     = l_request_id
            GROUP BY SOURCE_SYSTEM_ID, l_item_master_dl_id, INVENTORY_ITEM_ID, ORGANIZATION_ID
            UNION ALL
            SELECT
              eiuai.SOURCE_SYSTEM_ID,
              eiuai.DATA_LEVEL_ID,
              eiuai.INVENTORY_ITEM_ID,
              eiuai.ORGANIZATION_ID,
              eiuai.PK1_VALUE AS SUPPLIER_ID,
              eiuai.PK2_VALUE AS SUPPLIER_SITE_ID,
              MAX(msii.MESSAGE_TIMESTAMP) AS MESSAGE_TIMESTAMP
            FROM EGO_ITM_USR_ATTR_INTRFC eiuai, MTL_SYSTEM_ITEMS_INTERFACE msii
            WHERE eiuai.DATA_SET_ID      = p_batch_id
              AND eiuai.PROCESS_STATUS   = 4
              AND eiuai.REQUEST_ID       = l_request_id
              AND msii.SET_PROCESS_ID    = eiuai.DATA_SET_ID
              AND msii.INVENTORY_ITEM_ID = eiuai.INVENTORY_ITEM_ID
              AND msii.ORGANIZATION_ID   = eiuai.ORGANIZATION_ID
              AND msii.BUNDLE_ID         = eiuai.BUNDLE_ID
            GROUP BY eiuai.SOURCE_SYSTEM_ID, eiuai.DATA_LEVEL_ID, eiuai.INVENTORY_ITEM_ID, eiuai.ORGANIZATION_ID, eiuai.PK1_VALUE, eiuai.PK2_VALUE
          ) intf
    ON (    eime.SOURCE_SYSTEM_ID          = intf.SOURCE_SYSTEM_ID
        AND eime.DATA_LEVEL_ID             = intf.DATA_LEVEL_ID
        AND eime.INVENTORY_ITEM_ID         = intf.INVENTORY_ITEM_ID
        AND eime.ORGANIZATION_ID           = intf.ORGANIZATION_ID
        AND NVL(eime.SUPPLIER_ID, -1)      = NVL(intf.SUPPLIER_ID, -1)
        AND NVL(eime.SUPPLIER_SITE_ID, -1) = NVL(intf.SUPPLIER_SITE_ID, -1)
       )
    WHEN MATCHED THEN
      UPDATE SET LAST_MESSAGE_TIMESTAMP = intf.MESSAGE_TIMESTAMP,
                 LAST_UPDATE_DATE       = SYSDATE,
                 LAST_UPDATED_BY        = l_user_id
    WHEN NOT MATCHED THEN
      INSERT
      (
        INVENTORY_ITEM_ID,
        ORGANIZATION_ID,
        SOURCE_SYSTEM_ID,
        DATA_LEVEL_ID,
        SUPPLIER_ID,
        SUPPLIER_SITE_ID,
        LAST_MESSAGE_TIMESTAMP,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
      )
      VALUES
      (
        intf.INVENTORY_ITEM_ID,
        intf.ORGANIZATION_ID,
        intf.SOURCE_SYSTEM_ID,
        intf.DATA_LEVEL_ID,
        intf.SUPPLIER_ID,
        intf.SUPPLIER_SITE_ID,
        intf.MESSAGE_TIMESTAMP,
        SYSDATE,
        l_user_id,
        SYSDATE,
        l_user_id,
        l_login_id
      );

    Debug_Conc_Log('Update_Timestamp_In_Prod: Done merging');
    COMMIT;
    RETCODE := '0';
    ERRBUF := NULL;
    Debug_Conc_Log('Update_Timestamp_In_Prod: Done Successfully');
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Update_Timestamp_In_Prod: Error - '||SQLERRM);
  END Update_Timestamp_In_Prod;


  PROCEDURE Copy_Attachments ( retcode    OUT NOCOPY VARCHAR2,
                               errbuf     OUT NOCOPY VARCHAR2,
                               p_batch_id IN NUMBER )
  IS
    CURSOR attach_id_cur IS
      SELECT DISTINCT ATTACH_CATEGORY_ID
      FROM EGO_IMPORT_COPY_OPTIONS
      WHERE COPY_OPTION = 'COPY_ATTCH_CATEGORY'
        AND BATCH_ID = p_batch_id;

    CURSOR interface_items_cur IS
      SELECT msii.ORGANIZATION_ID      AS DEST_ORG_ID,
             msii.INVENTORY_ITEM_ID    AS DEST_ITEM_ID,
             msii.COPY_ORGANIZATION_ID AS SOURCE_ORG_ID,
             msii.COPY_ITEM_ID         AS SOURCE_ITEM_ID
      FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
           MTL_PARAMETERS mp
      WHERE msii.SET_PROCESS_ID = p_batch_id
        AND msii.PROCESS_FLAG     = 7
        AND msii.TRANSACTION_TYPE = 'CREATE'
        AND msii.REQUEST_ID = FND_GLOBAL.CONC_REQUEST_ID
        AND msii.ORGANIZATION_ID  = mp.ORGANIZATION_ID
        AND mp.ORGANIZATION_ID    = mp.MASTER_ORGANIZATION_ID
        AND ( msii.STYLE_ITEM_FLAG = 'Y'
              OR msii.STYLE_ITEM_FLAG  IS NULL );

  l_to_attachment_id   NUMBER;
  BEGIN
    Debug_Conc_Log('Copy_Attachments Begin --- ');
    FOR item_row IN interface_items_cur
    LOOP
      Debug_Conc_Log ('Copy_Attachments - Copying following AttachmentIds from ItemID/OrgId:' ||
                      item_row.SOURCE_ITEM_ID || '/' || item_row.SOURCE_ORG_ID ||
                      ' To ItemId/OrgId:' || item_row.DEST_ITEM_ID || '/' || item_row.DEST_ORG_ID);
      FOR attach_row IN attach_id_cur
      LOOP
        Debug_Conc_Log('Copy_Attachments - Copying Attachment with CategoryId : '|| attach_row.ATTACH_CATEGORY_ID);
        dom_attachment_util_pkg.copy_attachments(
              X_from_entity_name => 'MTL_SYSTEM_ITEMS'
            , X_from_pk1_value   => item_row.SOURCE_ORG_ID  -- SourceOrganizationId
            , X_from_pk2_value   => item_row.SOURCE_ITEM_ID -- SourceItemId
            , X_to_attachment_id => l_to_attachment_id      -- to Attachment Id
            , X_to_entity_name   => 'MTL_SYSTEM_ITEMS'
            , X_to_pk1_value     => item_row.DEST_ORG_ID    -- DestOrgId
            , X_to_pk2_value     => item_row.DEST_ITEM_ID   -- DestItemId
            , X_from_category_id => attach_row.ATTACH_CATEGORY_ID
            );
      END LOOP;
      Debug_Conc_Log('Copy_Attachments - Attachment created with attachment Id : '|| l_to_attachment_id );
    END LOOP;
    COMMIT;
    RETCODE := '0';
    ERRBUF := NULL;
    Debug_Conc_Log('Copy_Attachments End ;');
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Copy_Attachments : Error - '||SQLERRM);
  END Copy_Attachments;

  /*
   * This method is called at the end of import processing.
   * If any SKUs are created in EGO_SKU_VARIANT_ATTR_USAGES table
   * but corresponding variant attributes are not present in
   * production table, then delete that entry.
   */
  PROCEDURE Clean_Dirty_SKUs( retcode    OUT NOCOPY VARCHAR2,
                              errbuf     OUT NOCOPY VARCHAR2,
                              p_batch_id IN NUMBER )
  IS
    l_item_dl_id               NUMBER;
    l_item_object_id           NUMBER;
    l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  BEGIN
    Debug_Conc_Log('Clean_Dirty_SKUs : Starting ');
    SELECT OBJECT_ID INTO l_item_object_id
    FROM FND_OBJECTS
    WHERE OBJ_NAME = 'EGO_ITEM';

    Debug_Conc_Log('Clean_Dirty_SKUs : Object_id='||l_item_object_id);

    SELECT DATA_LEVEL_ID INTO l_item_dl_id
    FROM EGO_DATA_LEVEL_B
    WHERE ATTR_GROUP_TYPE = 'EGO_ITEMMGMT_GROUP'
      AND APPLICATION_ID = 431
      AND DATA_LEVEL_NAME = 'ITEM_LEVEL';

    Debug_Conc_Log('Clean_Dirty_SKUs : l_item_dl_id='||l_item_dl_id);

    DELETE FROM EGO_SKU_VARIANT_ATTR_USAGES esvas
    WHERE EXISTS (SELECT NULL
                  FROM
                    EGO_FND_DSC_FLX_CTX_EXT ag_ext,
                    EGO_OBJ_AG_ASSOCS_B assoc,
                    MTL_SYSTEM_ITEMS_INTERFACE msii
                  WHERE msii.INVENTORY_ITEM_ID    = esvas.SKU_ITEM_ID
        AND msii.STYLE_ITEM_ID        = esvas.STYLE_ITEM_ID
                    AND msii.ORGANIZATION_ID      = esvas.ORGANIZATION_ID
                    AND msii.SET_PROCESS_ID       = p_batch_id
                    AND msii.REQUEST_ID           = l_request_id
                    AND msii.STYLE_ITEM_FLAG      = 'N'
                    AND ag_ext.VARIANT            = 'Y'
                    AND assoc.ATTR_GROUP_ID       = ag_ext.ATTR_GROUP_ID
                    AND assoc.CLASSIFICATION_CODE = TO_CHAR(msii.ITEM_CATALOG_GROUP_ID)
                    AND assoc.OBJECT_ID           = l_item_object_id
                    AND assoc.DATA_LEVEL_ID       = l_item_dl_id
                    AND NOT EXISTS (SELECT NULL
                                    FROM EGO_MTL_SY_ITEMS_EXT_B ext
                                    WHERE ext.ORGANIZATION_ID   = msii.ORGANIZATION_ID
                                      AND ext.INVENTORY_ITEM_ID = msii.INVENTORY_ITEM_ID
                                      AND ext.ATTR_GROUP_ID     = ag_ext.ATTR_GROUP_ID
                                      AND ext.DATA_LEVEL_ID     = assoc.DATA_LEVEL_ID
                                   )
                 );

    Debug_Conc_Log('Clean_Dirty_SKUs: Deleted '||SQL%ROWCOUNT||' rows.');
    RETCODE := '0';
    ERRBUF := NULL;
    Debug_Conc_Log('Clean_Dirty_SKUs End ;');
  EXCEPTION WHEN OTHERS THEN
    RETCODE := '2';
    ERRBUF := SQLERRM;
    Debug_Conc_Log('Clean_Dirty_SKUs : Error - '||SQLERRM);
  END Clean_Dirty_SKUs;

  PROCEDURE check_for_duplicates(p_batch_id IN NUMBER,
                                 p_commit   IN VARCHAR2 DEFAULT FND_API.G_FALSE) IS

   CURSOR Items_in_batch(p_batch_id NUMBER) is
   select UNIQUE SOURCE_SYSTEM_REFERENCE
   from MTL_SYSTEM_ITEMS_INTERFACE msii
   WHERE PROCESS_FLAG  = 0
   AND SET_PROCESS_ID = p_batch_id
   AND ORGANIZATION_ID IS NOT NULL;

   CURSOR Check_Duplicates_in_batch(p_batch_id NUMBER,source_system_ref_check varchar2) is
     select RANK() OVER   ( ORDER BY ATTR_VALUE_DATE desc
                      )rnk, transaction_id,bundle_id
      from EGO_ITM_USR_ATTR_INTRFC where  transaction_id IN(SELECT  transaction_id
                           FROM
                    ( SELECT
                      msii.transaction_id
                    FROM MTL_SYSTEM_ITEMS_INTERFACE msii
                    WHERE   PROCESS_FLAG        = 0
                        AND SET_PROCESS_ID      = p_batch_id
                        AND SOURCE_SYSTEM_REFERENCE =source_system_ref_check
                        AND ORGANIZATION_ID         IS NOT NULL
                       )
                    ) and ATTR_GROUP_INT_NAME = 'ORDERING_INFO' and ATTR_INT_NAME='LAST_MODIFIED_DATE'order by ATTR_VALUE_DATE desc;



BEGIN

for I1 in Items_in_batch(p_batch_id) loop


  -- Outer loop to get all unique unprocessed rows in msii

for I2 in Check_Duplicates_in_batch(p_batch_id,I1.SOURCE_SYSTEM_REFERENCE) loop

 -- Inner loop to get all LAST_MODIFIED_DATE values for all unprocessed items



If Check_Duplicates_in_batch%ROWCOUNT>1 then

 Debug_Conc_Log('Duplicates exist');

-- Duplicates exist so we go to BOM tables and delete as otherwise the Structure Import will fail due to duplicate structures in the interface table

 delete FROM BOM_INVENTORY_COMPS_INTERFACE A
 WHERE exists (SELECT 'x' FROM BOM_INVENTORY_COMPS_INTERFACE B
              WHERE
              B.PARENT_SOURCE_SYSTEM_REFERENCE = A.PARENT_SOURCE_SYSTEM_REFERENCE
              and B.COMP_SOURCE_SYSTEM_REFERENCE = A.COMP_SOURCE_SYSTEM_REFERENCE
              and
              (B.OPERATION_SEQ_NUM = A.OPERATION_SEQ_NUM OR  (B.OPERATION_SEQ_NUM  IS NULL AND A.OPERATION_SEQ_NUM  IS NULL))
              and
              (B.EFFECTIVITY_DATE= A.EFFECTIVITY_DATE OR  (B.EFFECTIVITY_DATE  IS NULL AND A.EFFECTIVITY_DATE  IS NULL))
              and  B.PROCESS_FLAG = A.PROCESS_FLAG
              and B.batch_id = A.batch_id -- fix for bug#9132730
              and B.rowid <> A.rowid)
 and A.process_flag=1
 and BATCH_ID=p_batch_id  and ALTERNATE_BOM_DESIGNATOR = 'PIM_PBOM_S' and bundle_id = I2.bundle_id;


 delete FROM  BOM_BILL_OF_MTLS_INTERFACE A
 WHERE
 exists (SELECT 'x' FROM  BOM_BILL_OF_MTLS_INTERFACE  B
         WHERE
         B.SOURCE_SYSTEM_REFERENCE = A.SOURCE_SYSTEM_REFERENCE
         and  B.PROCESS_FLAG = A.PROCESS_FLAG
         and B.batch_id = A.batch_id -- fix for bug#9132730
         and A.rowid <> B.rowid
         )
 and A.process_flag=1
 and BATCH_ID=p_batch_id and ALTERNATE_BOM_DESIGNATOR = 'PIM_PBOM_S' and bundle_id = I2.bundle_id;



If I2.rnk=1 then

-- Exact copy of same item , we can delete it

  delete from mtl_system_items_interface where transaction_id = I2.transaction_id and SOURCE_SYSTEM_REFERENCE=I1.SOURCE_SYSTEM_REFERENCE;
  delete from EGO_ITM_USR_ATTR_INTRFC where transaction_id = I2.transaction_id and SOURCE_SYSTEM_REFERENCE=I1.SOURCE_SYSTEM_REFERENCE;
  delete from EGO_ITEM_ASSOCIATIONS_INTF where transaction_id = I2.transaction_id and SOURCE_SYSTEM_REFERENCE=I1.SOURCE_SYSTEM_REFERENCE;
  delete from mtl_item_categories_interface where transaction_id = I2.transaction_id and SOURCE_SYSTEM_REFERENCE=I1.SOURCE_SYSTEM_REFERENCE;

else

 -- As we have ordered by LAST_MODIFIED_DATE we can delete rows having rank >1


  delete from mtl_system_items_interface where transaction_id = I2.transaction_id and SOURCE_SYSTEM_REFERENCE=I1.SOURCE_SYSTEM_REFERENCE;
  delete from EGO_ITM_USR_ATTR_INTRFC where transaction_id = I2.transaction_id and SOURCE_SYSTEM_REFERENCE=I1.SOURCE_SYSTEM_REFERENCE;
  delete from EGO_ITEM_ASSOCIATIONS_INTF where transaction_id = I2.transaction_id and SOURCE_SYSTEM_REFERENCE=I1.SOURCE_SYSTEM_REFERENCE;
  delete from mtl_item_categories_interface where transaction_id = I2.transaction_id and SOURCE_SYSTEM_REFERENCE=I1.SOURCE_SYSTEM_REFERENCE;


end if;
else


 Debug_Conc_Log('No Duplicates exist');
-- No duplicates exist

end if;

end loop;
end loop;


  EXCEPTION WHEN OTHERS THEN
        Debug_Conc_Log( 'Error - ' || SQLERRM);
        IF Items_in_batch%ISOPEN THEN
            CLOSE Items_in_batch;
        END IF;
IF Check_Duplicates_in_batch%ISOPEN THEN
            CLOSE Check_Duplicates_in_batch;
        END IF;
        RAISE;

END check_for_duplicates;


END EGO_IMPORT_UTIL_PVT;

/
