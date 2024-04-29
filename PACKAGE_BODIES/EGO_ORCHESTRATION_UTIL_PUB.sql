--------------------------------------------------------
--  DDL for Package Body EGO_ORCHESTRATION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ORCHESTRATION_UTIL_PUB" as
/* $Header: EGOORCHB.pls 120.21.12010000.10 2009/11/23 08:45:16 maychen ship $ */


FUNCTION GET_DATE_FROM_XML(l_xml_date IN XMLTYPE)
  RETURN DATE -- bug:6507903 Changed return type from varchar2 to date
IS
BEGIN
  IF l_xml_date IS NULL
  THEN
    RETURN NULL;
  ELSE
    RETURN To_Date( REGEXP_REPLACE(l_xml_date.getStringVal(), 'T', ' '), 'YYYY-MM-DD HH24:MI:SS');
  END IF;
END GET_DATE_FROM_XML;

-- -----------------------------------------------------------------------------
--  API Name:       Set_ICC_For_Rec_Bundle
--  This API will set Primary Catalog Category for Record bundle.
--  Input = Record Bundle Id
--  output = 1. Status ERROR or SUCCESS
--           2. GPC Code list for Advanced GPC to ICC mapping has not done.
--   Signatures of Catalog mangements APIs are mentioned below.
-- -----------------------------------------------------------------------------


PROCEDURE Set_ICC_For_Rec_Bundle
(  p_rb_id              IN          NUMBER ,
   x_Status               OUT NOCOPY  VARCHAR2,
   x_Gpc_list             OUT NOCOPY  VARCHAR2
)IS
  CURSOR Get_All_Items(l_b_Id NUMBER) IS
      SELECT gpc_code, bundle_id, source_system_id, source_system_reference
      FROM mtl_system_items_interface
      WHERE bundle_id = l_b_Id ;
  l_icc_code NUMBER;

BEGIN
    x_Gpc_list := NULL;
    x_Status := 'SUCCESS';
    FOR item_data IN Get_All_Items(l_b_Id => p_rb_id)
    LOOP
      EGO_CATG_MAP_UTIL_PKG.Get_Item_Catalog_Ctgr_Mapping(
                    P_GPC_ID            => item_data.gpc_code  --gpc_code
                   ,X_ICC_CATEGORY_ID   => l_icc_code); -- Icc code
      --l_icc_code := 0;
      IF l_icc_code IS NOT NULL
      THEN
        UPDATE mtl_system_items_interface
          SET Item_catalog_group_id = l_icc_code
          WHERE  bundle_id = item_data.bundle_id
                AND source_system_id = item_data.source_system_id
                AND source_system_reference = item_data.source_system_reference;
      ELSE
          x_Status := 'ERROR';
          x_Gpc_list := x_Gpc_list ||',' || item_data.gpc_code;
      END IF;
    END LOOP;
    IF ( x_Status <> 'ERROR' )
    THEN
      x_Status := 'SUCCESS';
    END IF;
    COMMIT;
END;

-- -----------------------------------------------------------------------------
--  API Name:       Set_ACC_For_Rec_Bundle
--  This API will set Alternate Catalog Category for Record bundle.
--  Input = Record Bundle Id
--  output = 1. Status ERROR or SUCCESS
--           2. GPC Code list for Advanced GPC to ACC mapping has not done.
-- -----------------------------------------------------------------------------

PROCEDURE Set_ACC_For_Rec_Bundle
(  p_rb_id                IN          NUMBER ,
   x_Status               OUT NOCOPY  VARCHAR2,
   x_Gpc_list             OUT NOCOPY  VARCHAR2
)IS
  CURSOR Get_All_Items(l_b_Id NUMBER)
  IS SELECT gpc_code ,bundle_id, global_trade_item_number,source_system_reference
      FROM mtl_system_items_interface
      WHERE bundle_id = l_b_Id ;

  l_acc_code NUMBER;
  l_acc_catalog NUMBER;

BEGIN
  x_Gpc_list := NULL;
  FOR item_data IN Get_All_Items(l_b_Id => p_rb_id)
  LOOP
    EGO_CATG_MAP_UTIL_PKG.Get_Alt_Catalog_Ctgr_Mapping
                  ( P_GPC_ID            => item_data.gpc_code   --gpc code
                    ,X_ACC_CATEGORY_ID   => l_acc_code    -- acc code
                    ,X_ACC_CATALOG_ID    => l_acc_catalog  ); --acc catalog
     --l_acc_code := 0;
     --l_acc_catalog := 0;
    IF l_acc_code IS NOT NULL
    THEN
      UPDATE MTL_ITEM_CATEGORIES_INTERFACE
      SET CATEGORY_id = l_acc_code ,CATEGORY_SET_ID = l_acc_catalog
        WHERE  bundle_id = item_data.bundle_id
          AND source_system_id = item_data.global_trade_item_number
          AND source_system_reference = item_data.source_system_reference;
      COMMIT;
    ELSE
      x_Status := 'ERROR';
      x_Gpc_list := x_Gpc_list ||',' || item_data.gpc_code;
    END IF;
  END LOOP;
  IF ( x_Status <> 'ERROR' )
  THEN
    x_Status := 'SUCCESS';
  END IF;
END;

PROCEDURE ADD_BUNDLES_TO_COL (x_bundle_collection_id   IN NUMBER,
                              p_bundles_clob           IN CLOB,
                              x_new_bundle_col_id      OUT NOCOPY NUMBER,
                              p_commit                 IN VARCHAR2 DEFAULT 'Y',
                              p_entity_name            IN VARCHAR2 DEFAULT 'BUNDLE'
                              )
IS
  CURSOR c_bundles(p_bundles_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) bundle
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_bundles_xml, '/Bundles/Bundle'))) xml_tab;

  CURSOR c_bundle_items(p_bundles_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) bundle
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_bundles_xml, '//ItemBundle'))) xml_tab;

  l_bundle_collection_id  NUMBER;
  l_bundle_id             NUMBER;
  p_bundles_xml           XMLTYPE;
  p_cln_bundles_clob      CLOB;
  l_source_system_id      NUMBER;
  l_source_system_ref     VARCHAR2(255);

BEGIN
  l_bundle_collection_id := x_bundle_collection_id;
  IF (l_bundle_collection_id = NULL OR
      l_bundle_collection_id = 0 OR
      l_bundle_collection_id = -1)
  THEN
    SELECT MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
    INTO l_bundle_collection_id
    FROM dual;
  END IF;


  x_new_bundle_col_id := l_bundle_collection_id;
  p_cln_bundles_clob := REPLACE(p_bundles_clob, 'ns1:');
  p_bundles_xml := XMLTYPE.createXML(xmlData => p_cln_bundles_clob);
  IF p_entity_name = 'ITEM'
  THEN
    IF p_bundles_xml.extract('//ItemBundle') IS NOT NULL
    THEN
      FOR c_bls IN c_bundle_items(p_bundles_xml)
      LOOP
        l_bundle_id := c_bls.bundle.extract('/ItemBundle/BundleId/text()').getNumberVal();
        l_source_system_id := c_bls.bundle.extract('/ItemBundle/ItemSourceSystemId/text()').getNumberVal();
        l_source_system_ref := c_bls.bundle.extract('/ItemBundle/ItemSourceSystemReference/text()').getStringVal();

        INSERT INTO MTL_ITEM_BULKLOAD_RECS (request_id,
                                          creation_date,
                                          last_update_date,
                                          created_by,
                                          last_updated_by,
                                          bundle_collection_id,
                                          bundle_id,
                                          source_system_id,
                                          source_system_reference
                                          ) values
                                          (-1,
                                          sysdate,
                                          sysdate,
                                          1,
                                          1,
                                          l_bundle_collection_id,
                                          l_bundle_id,
                                          l_source_system_id,
                                          l_source_system_ref
                                          );
      END LOOP;
    END IF;

  ELSE
    FOR c_bls IN c_bundles(p_bundles_xml)
    LOOP
      l_bundle_id := c_bls.bundle.extract('/Bundle/BundleId/text()').getNumberVal();
      INSERT INTO MTL_ITEM_BULKLOAD_RECS (request_id,
                                          creation_date,
                                          last_update_date,
                                          created_by,
                                          last_updated_by,
                                          bundle_collection_id,
                                          bundle_id,
                                          message_type,
                                          message_code
                                          ) values
                                          (-1,
                                          sysdate,
                                          sysdate,
                                          1,
                                          1,
                                          l_bundle_collection_id,
                                          l_bundle_id,
                                          c_bls.bundle.extract('/Bundle/Message/@type').getStringVal(),
                                          substr(c_bls.bundle.extract('/Bundle/Message/text()').getStringVal(), 1, 80));
    END LOOP;
  END IF;
  IF p_commit = 'Y'
  THEN
    COMMIT;
  END IF;
END ADD_BUNDLES_TO_COL;
-- -----------------------------------------------------------------------------
--  API Name:       Set_ICC_For_Rec_Collection
--  This API will set Primary Catalog Category for  bundle collection.
--  Input = Bundle Collection Id
--  output = 1. Bundle Collection Id With ICC (this will contain all bundles with ICC )
--           2. Bundle Collection Id With ICC (this will contain all bundles without ICC )
--
-- -----------------------------------------------------------------------------

PROCEDURE Set_ICC_For_Rec_Collection
(  p_rc_id              IN          NUMBER ,
   x_BundleWithICC               OUT NOCOPY  NUMBER,
   x_BundleWithoutICC             OUT NOCOPY  NUMBER
)IS

CURSOR getBundles(p_rcb_id NUMBER )
  IS  SELECT bundle_id
        FROM MTL_ITEM_BULKLOAD_RECS
        WHERE bundle_collection_id = p_rcb_id;

  l_gpc_list VARCHAR2(1000);
  l_status VARCHAR2(1000);
  l_FlagE VARCHAR2(10);
  l_FlagS VARCHAR2(10);
  l_bundle_W clob;
  l_bundle_WO clob;

  l_buffer varchar2(1000);

  l_BundlesStartTag  varchar2(100);
  l_BundleStartTag  varchar2(100);
  l_BundlesEndTag  varchar2(100);
  l_BundleEngTag  varchar2(100);

BEGIN

  l_BundlesStartTag := '<Bundles>' ;
  l_BundleStartTag := '<Bundle><BundleId>';
  l_BundlesEndTag := '</Bundles>';
  l_BundleEngTag  := '</BundleId></Bundle>';
  l_FlagE := 'N';
  l_FlagS := 'N';
  l_bundle_W := to_clob(' ');
  l_bundle_WO := to_clob(' ');
  dbms_lob.writeappend(l_bundle_W, length(l_BundlesStartTag), l_BundlesStartTag);
  dbms_lob.writeappend(l_bundle_WO, length(l_BundlesStartTag), l_BundlesStartTag);
  FOR record_bundle IN getBundles(p_rcb_id => p_rc_id)
  LOOP
    l_buffer := l_BundleStartTag || record_bundle.bundle_id || l_BundleEngTag ;
    Set_ICC_For_Rec_Bundle(
                    p_rb_id         => record_bundle.bundle_id   --record bundle id  code
                    ,x_Status       => l_status    -- status
                    ,x_Gpc_list     => l_gpc_list  ); --gpc list

    IF (l_status = 'SUCCESS') THEN
      l_FlagS := 'Y';
      dbms_lob.writeappend(l_bundle_W, length(l_buffer), l_buffer);
    ELSE
      l_FlagE := 'Y';
      dbms_lob.writeappend(l_bundle_WO, length(l_buffer), l_buffer);
    END IF;
  END LOOP ;
  dbms_lob.writeappend(l_bundle_W, length(l_BundlesEndTag), l_BundlesEndTag);
  dbms_lob.writeappend(l_bundle_WO, length(l_BundlesEndTag), l_BundlesEndTag);
  IF( l_FlagS = 'Y') THEN
    ADD_BUNDLES_TO_COL(
                  x_bundle_collection_id       => -1  --record bundle id  code
                  ,p_bundles_clob              => l_bundle_W    -- status
                  ,x_new_bundle_col_id         => x_BundleWithICC  ); --gpc list
  ELSE
    x_BundleWithICC := 0;
  END IF;
  IF( l_FlagE = 'Y') THEN
    ADD_BUNDLES_TO_COL(
                  x_bundle_collection_id       => -1   --record bundle id  code
                  ,p_bundles_clob              => l_bundle_WO    -- status
                  ,x_new_bundle_col_id         => x_BundleWithoutICC ); --gpc list
  ELSE
    x_BundleWithoutICC := 0;
  END IF ;
END ;

-- -----------------------------------------------------------------------------
--  API Name:       Set_ACC_For_Rec_Collection
--  This API will set Alternate Catalog Category for bundle collection.
--  Input = Bundle Collection Id
--  output = 1. Bundle Collection Id With ACC (this will contain all bundles with ACC )
--           2. Bundle Collection Id With ACC (this will contain all bundles without ACC )
--
-- -----------------------------------------------------------------------------


PROCEDURE Set_ACC_For_Rec_Collection
(  p_rc_id              IN          NUMBER ,
   x_BundleWithACC               OUT NOCOPY  NUMBER,
   x_BundleWithoutACC             OUT NOCOPY  NUMBER
)IS
  CURSOR getBundles(p_rcb_id NUMBER )   IS
      SELECT bundle_id
      FROM MTL_ITEM_BULKLOAD_RECS
      WHERE bundle_collection_id = p_rcb_id
            AND entity_type LIKE 'ITEM';

  l_gpc_list VARCHAR2(1000);
  l_status VARCHAR2(1000);

  l_bundle_W clob;
  l_bundle_WO clob;
  l_FlagE VARCHAR2(10);
  l_FlagS VARCHAR2(10);

  l_buffer varchar2(1000);

  l_BundlesStartTag  varchar2(100);
  l_BundleStartTag  varchar2(100);
  l_BundlesEndTag  varchar2(100);
  l_BundleEngTag  varchar2(100);

BEGIN

  l_BundlesStartTag := '<Bundles>' ;
  l_BundleStartTag := '<Bundle><BundleId>';
  l_BundlesEndTag := '</Bundles>';
  l_BundleEngTag  := '</BundleId></Bundle>';
  l_bundle_W := to_clob(' ');
  l_bundle_WO :=to_clob(' ');
  dbms_lob.writeappend(l_bundle_W, length(l_BundlesStartTag), l_BundlesStartTag);
  dbms_lob.writeappend(l_bundle_WO, length(l_BundlesStartTag), l_BundlesStartTag);
  l_FlagE := 'N';
  l_FlagS := 'N';

  FOR record_bundle IN getBundles(p_rcb_id => p_rc_id)
  LOOP
    l_buffer := l_BundleStartTag || record_bundle.bundle_id || l_BundleEngTag ;
    Set_ACC_For_Rec_Bundle(
                        p_rb_id       => record_bundle.bundle_id   --record bundle id  code
                        ,x_status        => l_status    -- status
                        ,x_gpc_list      => l_gpc_list ); --gpc list

    IF (l_status = 'SUCCESS') THEN
      dbms_lob.writeappend(l_bundle_W, length(l_buffer), l_buffer);
      l_FlagS := 'Y';
    ELSE
      dbms_lob.writeappend(l_bundle_WO, length(l_buffer), l_buffer);
      l_FlagE := 'Y';
    END IF;
  END LOOP ;
  dbms_lob.writeappend(l_bundle_W, length(l_BundlesEndTag), l_BundlesEndTag);
  dbms_lob.writeappend(l_bundle_WO, length(l_BundlesEndTag), l_BundlesEndTag);
  IF( l_FlagS = 'Y') THEN
    ADD_BUNDLES_TO_COL(
                      x_bundle_collection_id       => -1   --record bundle id  code
                      ,p_bundles_clob              => l_bundle_W   -- status
                      ,x_new_bundle_col_id         => x_BundleWithACC  ); --gpc list
  ELSE
    x_BundleWithACC := 0;
  END IF;

  IF( l_FlagE = 'Y') THEN
    ADD_BUNDLES_TO_COL(
                      x_bundle_collection_id       => -1   --record bundle id  code
                      ,p_bundles_clob              => l_bundle_WO   -- status
                      ,x_new_bundle_col_id         => x_BundleWithoutACC  ); --gpc list
  ELSE
    x_BundleWithoutACC := 0;
  END IF;

END ;

-- -----------------------------------------------------------------------------
--  API Name:       validate_batch
--  This API will validate batch name passed and if it failed then will return defaul batch ID.
--  Input = 1. batch_name
--          2. default_batch_name
--  output = 1. batch id
--           2. error message
--
-- -----------------------------------------------------------------------------




PROCEDURE validate_batch
(    p_batch_name IN VARCHAR2 ,
     p_default_batch_name IN VARCHAR2 ,
     x_batch_id OUT NOCOPY  NUMBER,
     x_error_msg OUT NOCOPY  VARCHAR2
) IS
/* Changed for bug 8277589 */
  /*CURSOR Get_BatchId (l_batch_name VARCHAR2 ) IS
  SELECT batch_id
  FROM EGO_IMPORT_BATCHES_tl
  WHERE name = l_batch_name
        and language = USERENV('LANG');*/

  CURSOR Get_BatchId (l_batch_name VARCHAR2 ) IS
  SELECT btl.batch_id
  FROM EGO_IMPORT_BATCHES_tl btl ,EGO_IMPORT_BATCHES_b bb
  WHERE btl.name =l_batch_name	-- 'Orch004'
        and btl.language = USERENV('LANG')
        AND btl.batch_id=bb.batch_id
        AND bb.batch_status IN ('A','P');
/* Changed for bug 8277589 ends*/

  CURSOR get_batch_type(l_batch_id NUMBER) IS
  SELECT batch_type
  from ego_import_batches_b
  WHERE batch_id =  l_batch_id;

  CURSOR c_is_enabled_for_gdsn(l_batch_id NUMBER)
  IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT NULL
                  FROM EGO_IMPORT_OPTION_SETS
                  WHERE BATCH_ID = l_batch_id
                  AND ENABLED_FOR_DATA_POOL = 'Y'
                );

  -- Batch_id NUMBER;
  l_Batch_satus  VARCHAR2(100);
  l_Batch_type   VARCHAR2(100);
  l_gdsn_batch   BOOLEAN;
  l_batch_id     NUMBER;

BEGIN
  x_error_msg := 'SUCCESS';
  x_batch_id := 0;
  l_batch_id := 0;
  l_gdsn_batch := FALSE;

  -- Find the Batch
  OPEN  Get_BatchId (l_batch_name => p_batch_name);
  FETCH Get_BatchId INTO l_batch_id;
  CLOSE Get_BatchId;
  IF( l_batch_id = 0 )
  THEN
    x_error_msg := 'EGO_ORCH_INVALID_BATCH_NAME';
  END IF ;

  -- Check Batch Status
  IF x_error_msg = 'SUCCESS'
  THEN
    l_Batch_satus :=  EGO_IMPORT_PVT.GET_BATCH_STATUS(l_batch_id );
    IF ( l_Batch_satus <> 'A')
    THEN
      x_error_msg := 'EGO_ORCH_BATCH_INACTIVE';
    END IF;
  END IF;

  IF x_error_msg = 'SUCCESS'
  THEN
    -- Validate Batch Type
    OPEN  get_batch_type (l_batch_id => l_batch_id);
    FETCH get_batch_type INTO l_Batch_type;
    CLOSE get_batch_type;
    IF ( l_Batch_type = 'EGO_ITEM')
    THEN
      x_error_msg := 'EGO_ORCH_BATCH_ITEM_TYPE';
    END IF;
  END IF;

  IF x_error_msg = 'SUCCESS'
  THEN
    FOR c_gdsn_batch_test in c_is_enabled_for_gdsn (l_batch_id => l_batch_id)
    LOOP
      l_gdsn_batch := TRUE;
    END LOOP;
    IF l_gdsn_batch <> TRUE
    THEN
      x_error_msg := 'EGO_ORCH_BATCH_NOT_GDSN';
    END IF;
  END IF;

  IF x_error_msg <> 'SUCCESS'
  THEN
    OPEN  Get_BatchId (l_batch_name => p_default_batch_name);
    FETCH Get_BatchId INTO l_batch_id;
    CLOSE Get_BatchId;

    IF l_batch_id IS NULL
    THEN
      x_Batch_id := 0;
    END IF;
  ELSE
    x_Batch_id := l_batch_id;
  END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
      x_error_msg := 'EGO_ORCH_BATCH_UEX_ERROR';
      IF get_batch_type%ISOPEN
      THEN
        CLOSE get_batch_type;
      END IF;
      IF Get_BatchId%ISOPEN
      THEN
        CLOSE Get_BatchId;
      END IF;
END;




FUNCTION PRE_PRE_PROCESS_BATCHES ( X_BUNDLE_COLLECTION_ID IN NUMBER,
                                   X_COMMIT               IN VARCHAR2
                                 )
                                 RETURN NUMBER
IS
  l_collection_id     NUMBER;
  l_batch_id          NUMBER;

  -- Added distinct so that Resolve_SSXref_on_Data_load gets called only once per batch
  CURSOR bundles IS
  SELECT distinct set_process_id
  FROM MTL_SYSTEM_ITEMS_INTERFACE
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

  --Cursor to get all different batches for a collection
  CURSOR cur_batch IS
  SELECT distinct set_process_id
  FROM MTL_SYSTEM_ITEMS_INTERFACE
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);


BEGIN
    l_collection_id := X_BUNDLE_COLLECTION_ID;

    --------------------------------------------------------------------------------------
    -- PUTTING THE PARAMS FOR NEW ROWS
    --------------------------------------------------------------------------------------

    -- Updating items rows
    UPDATE MTL_SYSTEM_ITEMS_INTERFACE ISTI
    SET TRANSACTION_TYPE = C_TRANSACTION_SYNC,
        PROCESS_FLAG = C_INIT_PROCESS_FLAG,
        --CONFIRM_STATUS = 'UN',
        SOURCE_SYSTEM_ID = (SELECT SOURCE_SYSTEM_ID
                            FROM EGO_IMPORT_BATCHES_B
                            WHERE BATCH_ID = ISTI.SET_PROCESS_ID)
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID)
      AND ITEM_NUMBER IS NULL;

    UPDATE MTL_SYSTEM_ITEMS_INTERFACE ISTI
    SET TRANSACTION_TYPE = C_TRANSACTION_SYNC,
        PROCESS_FLAG = C_INIT_PROCESS_FLAG,
        CONFIRM_STATUS = 'CN',
        SOURCE_SYSTEM_ID = (SELECT SOURCE_SYSTEM_ID
                            FROM EGO_IMPORT_BATCHES_B
                            WHERE BATCH_ID = ISTI.SET_PROCESS_ID)
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID)
      AND ITEM_NUMBER IS NOT NULL;

    -- Updating items user attribute rows
    UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
    SET TRANSACTION_TYPE = C_TRANSACTION_SYNC,
        PROCESS_STATUS = C_INIT_PROCESS_FLAG,
        SOURCE_SYSTEM_ID = (SELECT SOURCE_SYSTEM_ID
                            FROM EGO_IMPORT_BATCHES_B
                            WHERE BATCH_ID = EIUAI.DATA_SET_ID)
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    -- Updating items association rows
    UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
    SET TRANSACTION_TYPE = C_TRANSACTION_SYNC,
        PROCESS_FLAG = C_INIT_PROCESS_FLAG,
        SOURCE_SYSTEM_ID = (SELECT SOURCE_SYSTEM_ID
                            FROM EGO_IMPORT_BATCHES_B
                            WHERE BATCH_ID = EIAI.BATCH_ID)
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    -- Updating items caetgories rows
    UPDATE MTL_ITEM_CATEGORIES_INTERFACE MICI
    SET TRANSACTION_TYPE = C_TRANSACTION_SYNC,
        PROCESS_FLAG = C_INIT_PROCESS_FLAG,
        SOURCE_SYSTEM_ID = (SELECT SOURCE_SYSTEM_ID
                            FROM EGO_IMPORT_BATCHES_B
                            WHERE BATCH_ID = MICI.SET_PROCESS_ID)
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    -- Updating bill header rows
    UPDATE BOM_BILL_OF_MTLS_INTERFACE BBOMI
    SET TRANSACTION_TYPE = C_TRANSACTION_SYNC,
        PROCESS_FLAG = 1
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    -- Updating bill components rows
    UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
    SET TRANSACTION_TYPE = C_TRANSACTION_SYNC,
        PROCESS_FLAG = 1
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    -- Updating translatable rows
    UPDATE EGO_INTERFACE_TL
    SET PROCESS_STATUS = 1
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);


    UPDATE EGO_UCCNET_EVENTS EUE
    SET SOURCE_SYSTEM_ID = (SELECT SOURCE_SYSTEM_ID
                            FROM EGO_IMPORT_BATCHES_B
                            WHERE BATCH_ID = EUE.import_batch_id)
    WHERE CLN_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);


    FOR batches IN bundles
    LOOP
      EGO_IMPORT_PVT.Resolve_SSXref_on_Data_load( p_data_set_id   =>  batches.set_process_id);
    END LOOP;

    UPDATE BOM_BILL_OF_MTLS_INTERFACE BBOMI
    SET ORGANIZATION_ID = (SELECT ORGANIZATION_ID
                           FROM MTL_SYSTEM_ITEMS_INTERFACE
                           WHERE BUNDLE_ID = BBOMI.BUNDLE_ID
                           AND ROWNUM = 1),
        ORGANIZATION_CODE = (SELECT mp.organization_code
                             FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
                                  MTL_PARAMETERS mp
                             WHERE mp.organization_id = msii.organization_id
                             AND msii.BUNDLE_ID = BBOMI.BUNDLE_ID
                             AND ROWNUM = 1)
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
    SET ORGANIZATION_ID = (SELECT ORGANIZATION_ID
                           FROM MTL_SYSTEM_ITEMS_INTERFACE
                           WHERE BUNDLE_ID = BICI.BUNDLE_ID
                           AND ROWNUM = 1),
        ORGANIZATION_CODE = (SELECT mp.organization_code
                             FROM MTL_SYSTEM_ITEMS_INTERFACE msii,
                                  MTL_PARAMETERS mp
                             WHERE mp.organization_id = msii.organization_id
                             AND msii.BUNDLE_ID = BICI.BUNDLE_ID
                             AND ROWNUM = 1)
    WHERE BUNDLE_ID IN
      (SELECT BUNDLE_ID
       FROM MTL_ITEM_BULKLOAD_RECS
       WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
    SET pk2_value = (SELECT asa.VENDOR_SITE_ID
                       FROM ap_supplier_sites_all asa,
                            ap_supplier_sites_all asa2,
                            mtl_system_items_interface msii
                       WHERE asa.party_site_id = asa2.party_site_id
                         AND asa.vendor_id = EIUAI.pk1_value
                         AND asa2.vendor_site_id = EIUAI.pk2_value
                         --AND asa.org_id = msii.organization_id   --bug 8843486
                         AND msii.BUNDLE_ID = EIUAI.BUNDLE_ID
                         AND ROWNUM =1)
    WHERE data_level_name = 'ITEM_SUP_SITE'
      AND pk2_value IS NOT NULL
      AND BUNDLE_ID IN
          (SELECT BUNDLE_ID
           FROM MTL_ITEM_BULKLOAD_RECS
           WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
    SET pk2_value = (SELECT asa.VENDOR_SITE_ID
                       FROM ap_supplier_sites_all asa,
                            ap_supplier_sites_all asa2,
                            mtl_system_items_interface msii
                       WHERE asa.party_site_id = asa2.party_site_id
                         AND asa.vendor_id = EIAI.pk1_value
                         AND asa2.vendor_site_id = EIAI.pk2_value
                         --AND asa.org_id = msii.organization_id --bug 8843486
                         AND msii.BUNDLE_ID = EIAI.BUNDLE_ID
                         AND ROWNUM =1)
     WHERE data_level_name = 'ITEM_SUP_SITE'
      AND pk2_value IS NOT NULL
      AND BUNDLE_ID IN
          (SELECT BUNDLE_ID
           FROM MTL_ITEM_BULKLOAD_RECS
           WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    UPDATE EGO_ITM_USR_ATTR_INTRFC EIUAI
    SET pk2_value = (SELECT asa.VENDOR_SITE_ID
                       FROM ap_supplier_sites_all asa,
                            ap_supplier_sites_all asa2,
                            mtl_system_items_interface msii
                       WHERE asa.party_site_id = asa2.party_site_id
                         AND asa.vendor_id = EIUAI.pk1_value
                         AND asa2.vendor_site_id = EIUAI.pk2_value
                         --AND asa.org_id = msii.organization_id --bug 8843486
                         AND msii.BUNDLE_ID = EIUAI.BUNDLE_ID
                         AND ROWNUM =1)
    WHERE data_level_name = 'ITEM_SUP_SITE_ORG'
      AND pk2_value IS NOT NULL
      AND BUNDLE_ID IN
          (SELECT BUNDLE_ID
           FROM MTL_ITEM_BULKLOAD_RECS
           WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    UPDATE EGO_ITEM_ASSOCIATIONS_INTF EIAI
    SET pk2_value = (SELECT asa.VENDOR_SITE_ID
                       FROM ap_supplier_sites_all asa,
                            ap_supplier_sites_all asa2,
                            mtl_system_items_interface msii
                       WHERE asa.party_site_id = asa2.party_site_id
                         AND asa.vendor_id = EIAI.pk1_value
                         AND asa2.vendor_site_id = EIAI.pk2_value
                         --AND asa.org_id = msii.organization_id  --bug 8843486
                         AND msii.BUNDLE_ID = EIAI.BUNDLE_ID
                         AND ROWNUM =1)
     WHERE data_level_name = 'ITEM_SUP_SITE_ORG'
      AND pk2_value IS NOT NULL
      AND BUNDLE_ID IN
          (SELECT BUNDLE_ID
           FROM MTL_ITEM_BULKLOAD_RECS
           WHERE BUNDLE_COLLECTION_ID = X_BUNDLE_COLLECTION_ID);

    /*API to invoke automatic import concurrent program*/
    FOR doc IN cur_batch
    LOOP
      Import_Conc_Prg( doc.set_process_id);
    END LOOP;



    RETURN l_collection_id;
    EXCEPTION
       WHEN OTHERS
       THEN
         RETURN NULL;
END PRE_PRE_PROCESS_BATCHES;


PROCEDURE Import_Conc_Prg( p_batch_id         IN   NUMBER)
IS
    l_request_id    NUMBER         := 0;
    l_auto_import   VARCHAR2(1)    :='N';
    l_auto_match    VARCHAR2(1)    :='N';
    l_user_id       NUMBER         :=FND_GLOBAL.user_id;

    l_batch_name    VARCHAR2(1000);
    l_co_option     VARCHAR2(30);
	  l_add_to_co     VARCHAR2(1);
	  l_co_category   VARCHAR2(30);
	  l_co_type       VARCHAR2(100);
	  l_co_name       VARCHAR2(500);
	  l_co_number     VARCHAR2(10);
	  l_co_desc       VARCHAR2(2000);
	  l_schedule_date DATE;
	  l_batch_type    VARCHAR2(100);
	  l_nir_option    VARCHAR2(1);
	  l_language      VARCHAR2(100); --bug 9128650

BEGIN
	    --Initialise apps context
	  FND_GLOBAL.APPS_INITIALIZE(FND_GLOBAL.user_id,FND_GLOBAL.RESP_ID,FND_GLOBAL.resp_appl_id);

	  SELECT  BATCH_NAME, Nvl(IMPORT_ON_DATA_LOAD,'N'),Nvl(MATCH_ON_DATA_LOAD,'N'),
	       CHANGE_ORDER_CREATION,ADD_ALL_TO_CHANGE_FLAG,CHANGE_MGMT_TYPE_CODE,
	       CHANGE_TYPE_ID,CHANGE_NAME,CHANGE_NOTICE,CHANGE_DESCRIPTION,
	       IMPORT_SCHEDULE_DATE,BATCH_TYPE,NIR_OPTION
	  INTO l_batch_name,l_auto_import,l_auto_match,l_co_option,l_add_to_co,l_co_category,l_co_type,l_co_name,l_co_number,l_co_desc,
	       l_schedule_date,l_batch_type,l_nir_option
	  FROM ego_import_batch_details_v
	  WHERE BATCH_ID= p_batch_id
	     AND enabled_for_data_pool = 'Y';
	  SELECT userenv('LANG')
    INTO l_language
    FROM dual;

      IF (l_auto_import='Y' OR l_auto_match='Y') THEN
	      --Submit concurrent request
	      l_request_id  :=  FND_REQUEST.Submit_Request
	                           (application => 'EGO',
	                            program     => 'EGOIJAVA',
	                            argument1   =>	null,
	                            argument2   =>	fnd_global.user_id,
	                            argument3   =>	l_language, --lang bug 9128650
	                            argument4   =>	FND_GLOBAL.RESP_ID,
	                            argument5   =>	FND_GLOBAL.resp_appl_id,
	                            argument6   =>	2,
	                            argument7   =>	'N',
	                            argument8   =>	p_batch_id,
	                            argument9   =>	l_batch_name,
	                            argument10   =>	l_auto_import,
	                            argument11   =>	l_auto_match,
	                            argument12   =>	l_co_option,
	                            argument13   =>	l_add_to_co,
	                            argument14   =>	l_co_category,
	                            argument15   =>	l_co_type,
	                            argument16   =>	l_co_name,
	                            argument17   =>	l_co_number,
	                            argument18   =>	l_co_desc,
	                            argument19   =>	l_schedule_date,
	                            argument20   =>	l_batch_type,
	                            argument21   =>	l_nir_option

	                            );

	      IF l_request_id = 0 THEN
	        fnd_file.put_line(fnd_file.log, 'Request Not Submitted.');
	      ELSE
	        fnd_file.put_line(fnd_file.log, 'Submitted request using request id = '||l_request_id);

	        /*Updating import_request_id with request id of concurrent request submitted above for auto import*/
	        UPDATE EGO_IMPORT_BATCHES_B
	        SET LAST_IMPORT_REQUEST_ID= l_request_id
	        WHERE batch_id= p_batch_id;

	        COMMIT;
	      END IF; --IF l_request_id = 0 THEN
      END IF;--IF (l_auto_import='Y' OR l_auto_match='Y') THEN

END Import_Conc_Prg;



FUNCTION GET_BUNDLES_FROM_COL ( p_bundle_collection_id   IN NUMBER,
                                p_prior_bundle_id        IN NUMBER,
                                p_max_elements           IN NUMBER)
RETURN XMLTYPE
IS
  l_xml_doc XMLTYPE;
BEGIN
  l_xml_doc := NULL;
  SELECT   XMLELEMENT("BundleCollections",
             XMLELEMENT("BundleCollection",
               XMLELEMENT("BundleCollectionId", bundle_collection_id),
               XMLELEMENT("Bundles",
                 XMLAGG(XMLELEMENT("Bundle",
                          XMLELEMENT("BundleId", bundle_id)))))) XML_DOC
  INTO l_xml_doc
  FROM MTL_ITEM_BULKLOAD_RECS
  WHERE bundle_collection_id = p_bundle_collection_id
    AND bundle_id > Nvl(p_prior_bundle_id, 0)
    AND ROWNUM < p_max_elements
    GROUP BY  bundle_collection_id;

  RETURN l_xml_doc;

  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      return l_xml_doc;
END GET_BUNDLES_FROM_COL;

PROCEDURE GET_SUPPLIER_INFO ( X_EXT_SUP_ID            IN VARCHAR2,
                              X_EXT_SUP_TYPE          IN VARCHAR2,
                              X_SUP_LEVEL             IN VARCHAR2,
                              X_SUPPLIER_ID           OUT NOCOPY NUMBER,
                              X_SUPPLIER_NAME         OUT NOCOPY VARCHAR2
                            )
IS
BEGIN
  X_SUPPLIER_ID := NULL;
  X_SUPPLIER_NAME := NULL;

  IF X_EXT_SUP_TYPE = 'GLN' AND X_SUP_LEVEL = 'SUPPLIER'
  THEN
    SELECT asa.VENDOR_ID, aas.VENDOR_NAME
    INTO X_SUPPLIER_ID, X_SUPPLIER_NAME
    FROM ap_suppliers aas,
         ap_supplier_sites_all asa,
         hz_party_sites hps
    WHERE hps.GLOBAL_LOCATION_NUMBER = X_EXT_SUP_ID
      AND hps.party_site_id = asa.party_site_id
      AND aas.vendor_id = asa.vendor_id
      AND rownum = 1;

  ELSIF X_EXT_SUP_TYPE = 'GLN'
  THEN
      SELECT asa.VENDOR_SITE_ID, asa.VENDOR_SITE_CODE
      INTO X_SUPPLIER_ID, X_SUPPLIER_NAME
      FROM ap_suppliers aas,
           ap_supplier_sites_all asa,
           hz_party_sites hps
      WHERE hps.GLOBAL_LOCATION_NUMBER = X_EXT_SUP_ID
        AND hps.party_site_id = asa.party_site_id
        AND aas.vendor_id = asa.vendor_id
        AND rownum = 1;

  END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
      NULL;
END GET_SUPPLIER_INFO;


FUNCTION GET_NEXT_ID RETURN NUMBER
IS
  l_id NUMBER;
BEGIN
  SELECT MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
  INTO l_id
  FROM dual;

  RETURN l_id;
END;

PROCEDURE PROCESS_TL_ROWS(p_table_name     IN VARCHAR2,
                          p_batch_id       IN NUMBER,
                          p_unique_id      IN NUMBER,
                          p_bundle_id      IN NUMBER,
                          p_xml_data       IN XMLTYPE,
                          p_entity_name    IN VARCHAR2,
                          p_column_name    IN VARCHAR2
                        )
IS
  CURSOR c_entries(p_collection_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) entry
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_collection_xml, '/TL/'||p_entity_name))) xml_tab;

BEGIN
  FOR trans_entry IN c_entries(p_xml_data)
  LOOP
    INSERT INTO EGO_INTERFACE_TL (
      set_process_id,
      unique_id,
      bundle_id,
      table_name,
      LANGUAGE,
      column_name,
      column_value,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
    ) VALUES(
      p_batch_id,
      p_unique_id,
      p_bundle_id,
      p_table_name,
      trans_entry.ENTRY.extract('/'||p_entity_name||'/@languageID').getStringVal(),
      p_column_name,
      trans_entry.ENTRY.extract('/'||p_entity_name||'/text()').getStringVal(),
      1,
      SYSDATE,
      1,
      SYSDATE,
      1
    );
  END LOOP;
END;


PROCEDURE SAVE_ATTR_DATA( p_xml                     IN XMLTYPE,
                          p_entity_name             IN VARCHAR2,
                          p_transaction_id          IN NUMBER,
                          p_bundle_id               IN NUMBER,
                          p_source_system_id        IN NUMBER,
                          p_source_system_reference IN VARCHAR2,
                          p_organization_code       IN VARCHAR2,
                          p_data_set_id             IN NUMBER,
                          p_data_level_name         IN VARCHAR2,
                          p_pk1_value               IN NUMBER,
                          p_pk2_value               IN NUMBER,
                          p_created_by              IN NUMBER,
                          p_creation_date           IN DATE,
                          p_last_updated_by         IN NUMBER,
                          p_last_update_date        IN DATE,
                          p_last_update_login       IN NUMBER)
IS

  -- Attribute Groups
  CURSOR c_AttributeGrps(p_entity_xml XMLTYPE, p_entity_name VARCHAR2)
  IS
  SELECT Value(xml_tab) attributeGroups
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_entity_xml, '/'||p_entity_name||'/AttributeGroup'))) xml_tab;

  -- Attributes
  CURSOR c_Attributes(p_attrGrp_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) attributes
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_attrGrp_xml, '/AttributeGroup/Attribute'))) xml_tab;

  l_row_identifier       NUMBER;
  l_attr_group_int_name  VARCHAR2(255);
  l_attr_int_name        VARCHAR2(255);
  l_attr_text_value      VARCHAR2(255);
  l_attr_numeric_value   EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_NUM%TYPE;
  l_attr_quant_unit_code EGO_ITM_USR_ATTR_INTRFC.ATTR_VALUE_UOM%TYPE;
  l_is_trans             BOOLEAN;
  l_xml_trans            XMLTYPE;

  l_xml_attr_grp_int_nm  XMLTYPE;
  l_xml_attr_int_nm      XMLTYPE;
  l_xml_attr_val         XMLTYPE;
  l_date_value           EGO_ITM_USR_ATTR_INTRFC.attr_value_date%TYPE;

BEGIN
  FOR l_xml_AttrGrps IN c_AttributeGrps(p_xml, p_entity_name)
  LOOP
    l_xml_attr_grp_int_nm := l_xml_AttrGrps.attributeGroups.extract('/AttributeGroup/ID/text()');
    IF l_xml_attr_grp_int_nm IS NOT NULL AND (p_entity_name <> 'Item' OR l_xml_attr_grp_int_nm.getStringVal() <> 'EGO_ORCH_INT')
    THEN
      l_attr_group_int_name := l_xml_attr_grp_int_nm.getStringVal();
      l_row_identifier := GET_NEXT_ID();
      FOR l_xml_Attrs IN c_Attributes(l_xml_AttrGrps.attributeGroups)
      LOOP
        l_is_trans := FALSE;

        l_attr_int_name := NULL;
        l_xml_attr_int_nm := l_xml_Attrs.attributes.extract('/Attribute/ID/text()');
        IF l_xml_attr_int_nm IS NOT NULL
        THEN
          l_attr_int_name := l_xml_attr_int_nm.getStringVal();
        END IF;

        l_xml_attr_val := l_xml_Attrs.attributes.extract('/Attribute/Value/text()');
        l_attr_text_value := null;
        IF l_xml_attr_val IS NULL
        THEN
          --l_attr_text_value := l_xml_Attrs.attributes.extract('/Attribute/ValueText[position() =1]/text()').getStringVal();
          l_xml_attr_val := l_xml_Attrs.attributes.extract('/Attribute/ValueText[position() =1]/text()');
          --IF l_attr_text_value IS NOT NULL
          IF l_xml_attr_val IS NOT NULL
          THEN
            l_is_trans := TRUE;
          END IF;
        END IF;

        IF l_xml_attr_val IS NOT NULL
        THEN
          l_attr_text_value := l_xml_attr_val.getStringVal();
        END IF;

        l_date_value := get_date_from_xml(l_xml_Attrs.attributes.extract('/Attribute/ValueDateTime/text()'));

        -- bug:6504632 For numeric values, quantity attributes coming with UOM code, consider ValueQuantity tag
        -- otherwise consider ValueNumeric tag
        l_attr_numeric_value := NULL;
        l_attr_quant_unit_code := NULL;
        l_xml_attr_val := l_xml_Attrs.attributes.extract('/Attribute/ValueNumeric/text()');

        IF l_xml_attr_val IS NOT NULL
        THEN
          l_attr_numeric_value := l_xml_attr_val.getNumberVal();
          l_attr_quant_unit_code := NULL;
        END IF;

        l_xml_attr_val := l_xml_Attrs.attributes.extract('/Attribute/ValueQuantity/text()');

        IF l_xml_attr_val IS NOT NULL
        THEN
          l_attr_numeric_value := l_xml_attr_val.getNumberVal();
          l_attr_quant_unit_code := l_xml_Attrs.attributes.extract('/Attribute/ValueQuantity/@unitCode').getStringVal();
        END IF;

        INSERT INTO EGO_ITM_USR_ATTR_INTRFC(
                transaction_id,
                bundle_id,
                source_system_id,
                source_system_reference,
                data_set_id,
                row_identifier,
                organization_code,

                attr_group_type,
                attr_group_int_name,
                attr_int_name,
                attr_value_str,
                attr_value_num,
                attr_value_date,
                attr_value_uom,
                data_level_name,
                pk1_value,
                pk2_value,

                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN
        ) VALUES (
                p_transaction_id,
                p_bundle_id,
                p_source_system_id,
                p_source_system_reference,
                p_data_set_id,
                l_row_identifier,
                p_organization_code,

                'EGO_ITEMMGMT_GROUP', -- bug:6525204 Passing EGO_ITEMMGMT_GROUP as UDA type always
                l_attr_group_int_name,
                l_attr_int_name,
                l_attr_text_value,
                l_attr_numeric_value,
                l_date_value,
                l_attr_quant_unit_code,
                p_data_level_name,
                p_pk1_value,
                p_pk2_value,

                p_created_by,
                p_creation_date,
                p_last_updated_by,
                p_last_update_date,
                p_last_update_login
        );

        IF l_is_trans = TRUE
        THEN
          SELECT XMLELEMENT("TL", l_xml_Attrs.attributes.extract('/Attribute/ValueText'))
          INTO l_xml_trans
          FROM DUAL;

          IF l_xml_trans IS NOT NULL
          THEN
            PROCESS_TL_ROWS(p_table_name      => 'EGO_ITM_USR_ATTR_INTRFC',
                            p_batch_id        => p_data_set_id,
                            p_unique_id       => l_row_identifier,
                            p_bundle_id       => p_bundle_id,
                            p_xml_data        => l_xml_trans,
                            p_entity_name     => 'ValueText',
                            p_column_name     => l_attr_int_name);
          END IF;
        END IF;
      END LOOP; -- Loop over Attributes
    END IF;
  END LOOP; -- Loop over Attribute Groups
END SAVE_ATTR_DATA;

PROCEDURE SAVE_DATA ( p_xml_clob           IN  CLOB,
                      p_commit             IN  VARCHAR2,
                      p_source_sys_id      IN  NUMBER,
                      p_default_batch      IN  VARCHAR2,
                      x_new_bundle_col_id  OUT NOCOPY NUMBER,
                      x_err_bundle_col_id  OUT NOCOPY NUMBER)
IS
  l_rt_trimmed_xml  CLOB;
  l_trimmed_xml     CLOB;
  l_bundles_xml     CLOB;
  l_xml_data        XMLTYPE;

  l_BundlesStartTag  varchar2(25) := '<Bundles>';
  l_BundleStartTag   varchar2(25) := '<Bundle>';
  l_BundlesEndTag    varchar2(25) := '</Bundles>';
  l_BundleEndTag     varchar2(25) := '</Bundle>';
  l_BundleIdStartTag varchar2(25) := '<BundleId>';
  l_BundleIdEndTag   varchar2(25) := '</BundleId>';

  l_MessageTag       VARCHAR2(2000);

  l_xml_trans                     XMLTYPE;
  x_return_type                   VARCHAR2(80);
  x_return_msg                    VARCHAR2(80);
  l_return_msg                    VARCHAR2(80);

  l_bundle_id                     NUMBER;
  l_batch_id                      NUMBER;
  l_batch_name                    VARCHAR2(255);
  l_org_code                      VARCHAR2(80);

  l_message_id                    VARCHAR2(80);
  l_message_date                  DATE;
  l_ext_complex_item_reference    VARCHAR2(255);
  l_transaction_id                NUMBER;
  l_source_sys_reference          VARCHAR2(255);
  l_error_msg                     VARCHAR2(2000);
  l_supplier_id                   NUMBER;
  l_supplier_site_id              NUMBER;
  l_supplier_name                 VARCHAR2(255);
  l_row_identifier                NUMBER;
  l_hdr_source_sys_reference      VARCHAR2(255);
  l_xml_null_chk                  XMLTYPE;
  l_xml_batch_name                XMLTYPE;
  l_external_bundle_id            VARCHAR2(255);

  l_bundles_clob                  CLOB;
  l_err_bundles_clob              CLOB;

  l_err_bundle                    BOOLEAN;
  l_reg_bundle                    BOOLEAN;
  l_item_id                       VARCHAR2(80);

  l_created_by                    NUMBER;
  l_creation_date                 DATE;
  l_last_updated_by               NUMBER;
  l_last_update_date              DATE;
  l_last_update_login             NUMBER;

  l_supplier_attr_level           VARCHAR2(30);

  l_alt_cat_concat_seg            MTL_CATEGORIES_KFV.CONCATENATED_SEGMENTS%TYPE;

  l_item_product_description        VARCHAR2(240);

  EGO_ORC_HDR_SEC_NOT_FOUND       EXCEPTION;
  EGO_ORC_NO_BATCH                EXCEPTION;
  EGO_MSG_ERROR                   EXCEPTION;
  EGO_ORC_NO_GTIN                 EXCEPTION;
  EGO_ORC_NO_GLN                  EXCEPTION;
  EGO_ORC_NO_STRUCTURE            EXCEPTION;
  EGO_ORC_XML_ERROR               EXCEPTION;
  EGO_ORC_INVALID_GLN             EXCEPTION;
  EGO_ORC_DELETE_LINE             EXCEPTION;

  -- Bundles
  CURSOR c_bundles(p_collection_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) bundles
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_collection_xml, '/XMLEntries/SyncItemPublication/ItemPublicationLine'))) xml_tab;

  -- Items
  CURSOR c_items(p_bundles_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) items
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_bundles_xml, '/ItemPublicationLine/Item'))) xml_tab;

  -- Classification
  CURSOR c_classifications(p_items_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) classifications
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_items_xml, '/Item/ItemCatalog'))) xml_tab;

  -- Suppliers
  CURSOR c_suppliers(p_items_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) suppliers
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_items_xml, '/Item/ItemSupplier'))) xml_tab;

  -- Suppliers
  CURSOR c_supplierLocations(p_suppliers_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) supplierLocations
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_suppliers_xml, '/ItemSupplier/ItemSupplierLocation'))) xml_tab;

  -- Structures
  CURSOR c_structure(p_bundles_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) structures
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_bundles_xml, '/ItemPublicationLine/ItemStructure'))) xml_tab;

  -- Components
  CURSOR c_component(p_structures_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) components
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_structures_xml, '/ItemStructure/ComponentItem'))) xml_tab;

  -- Alternate Category concatenated segments
  CURSOR c_alt_cat_concat_seg(c_alt_cat_code VARCHAR2)
  IS
  SELECT CONCATENATED_SEGMENTS
  FROM MTL_CATEGORIES_KFV
  WHERE SEGMENT2 = c_alt_cat_code
  AND   ROWNUM = 1;

  -- Fix for bug#8833123
  -- Attribute Groups
  CURSOR c_AttributeGrps(p_entity_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) attributeGroups
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_entity_xml,'Item/ItemSupplier/ItemSupplierLocation/AttributeGroup'))) xml_tab;

  -- Attributes
  CURSOR c_Attributes(p_attrGrp_xml XMLTYPE)
  IS
  SELECT Value(xml_tab) attributes
  FROM TABLE(XMLSEQUENCE(EXTRACT(p_attrGrp_xml,'/AttributeGroup/Attribute'))) xml_tab;

  l_xml_attr_grp_int_nm  XMLTYPE;
  l_xml_attr_int_nm      XMLTYPE;

BEGIN
  x_return_type := 'S';
  -- Step 1: Prepare incoming data by trimming all prefixes
  l_trimmed_xml := REGEXP_REPLACE(p_xml_clob, 'xmlns="[^"]*"', '');

  l_rt_trimmed_xml := REGEXP_REPLACE(l_trimmed_xml, '<\/[^:>=" ]*:', '</');
  l_trimmed_xml := REGEXP_REPLACE(l_rt_trimmed_xml, '<[^:>=" ]*:', '<');

  l_created_by  := 0;
  l_creation_date := SYSDATE;
  l_last_updated_by := 0;
  l_last_update_date := SYSDATE;
  l_last_update_login := 0;

  l_err_bundle := FALSE;
  l_reg_bundle := FALSE;

  l_error_msg := NULL;

  x_new_bundle_col_id := NULL;
  x_err_bundle_col_id := NULL;

  IF l_trimmed_xml IS NOT NULL
  THEN
    BEGIN
      l_xml_data := XMLTYPE(l_trimmed_xml);
    EXCEPTION
      WHEN OTHERS
      THEN
        RAISE EGO_ORC_XML_ERROR;
    END;

    l_xml_null_chk := l_xml_data.extract('/XMLEntries/SyncItemPublication/ItemPublicationIdentification/AlternateIdentification/ID[@schemeName="1SYNC-MessageId"]/text()');
    IF l_xml_null_chk IS NULL
    THEN
      RAISE EGO_ORC_HDR_SEC_NOT_FOUND;
    END IF;

    -- Step 1: Get Header Info
    l_message_id := l_xml_null_chk.getStringVal();
    l_message_date := get_date_from_xml(l_xml_data.extract('/XMLEntries/SyncItemPublication/Status/EffectiveDateTime/text()'));

    -- Step 2: Get Bundle Info
    FOR l_xml_CplxItem IN c_bundles(l_xml_data)
    LOOP
      BEGIN
        l_external_bundle_id := '-1';

        l_xml_null_chk := l_xml_CplxItem.bundles.extract('/ItemPublicationLine/ItemPublicationLineBase/ProcessingCode[@listAgencyName="1SYNC"]/text()');
        IF (l_xml_null_chk IS NOT NULL AND l_xml_null_chk.getStringVal() = 'PUBLICATION_DELETE') --bug:6500128
        THEN
          raise EGO_ORC_DELETE_LINE;
        END IF;

        l_xml_null_chk := l_xml_CplxItem.bundles.extract('/ItemPublicationLine/ItemPublicationLineIdentification/AlternateIdentification/ID[@schemeName="1SYNC-DocumentId"]/text()');
        IF l_xml_null_chk IS NOT NULL
        THEN
          l_external_bundle_id := substr(l_xml_null_chk.getStringVal(), 1, 255);
        END IF;

        l_org_code := NULL;
        l_supplier_attr_level := 'ITEM_SUP_SITE';
        l_xml_null_chk := l_xml_CplxItem.bundles.extract('/ItemPublicationLine/ItemPublicationLineIdentification/AlternateIdentification/ContextID[@schemeName="OrganizationCode"]/text()');
        IF l_xml_null_chk IS NOT NULL
        THEN
          l_org_code := substr(l_xml_null_chk.getStringVal(), 1, 80);
          l_supplier_attr_level := 'ITEM_SUP_SITE_ORG';
        END IF;

        l_xml_batch_name := l_xml_CplxItem.bundles.extract('/ItemPublicationLine/Item/AttributeGroup[ID = "EGO_ORCH_INT"][Attribute[ID = "TopItem"]/Value = "Y"]/Attribute[ID = "BatchName"]/Value/text()');

        l_batch_name := NULL;
        l_MessageTag := NULL;
        l_batch_id := 0;
        l_error_msg := NULL;

        IF l_xml_batch_name IS NOT NULL
        THEN
          l_batch_name := l_xml_batch_name.getStringVal();
        ELSE
          l_batch_name := p_default_batch;
        END IF;

        validate_batch(p_batch_name         => l_batch_name ,
                       p_default_batch_name => p_default_batch ,
                       x_batch_id           => l_batch_id,
                       x_error_msg          => l_error_msg);

        l_bundle_id := GET_NEXT_ID();

    -- Step 3: Iterate over Items
        FOR l_xml_ItemEBO IN c_items(l_xml_CplxItem.bundles)
        LOOP
            l_xml_null_chk := l_xml_ItemEBO.items.extract('/Item/ItemIdentification/GTIN/text()');
            IF l_xml_null_chk IS NULL
            THEN
              RAISE EGO_ORC_NO_GTIN;
            END IF;

            l_source_sys_reference := l_xml_null_chk.getStringVal();
            l_transaction_id := GET_NEXT_ID();

            -- Bug#8833123
            -- Derive the product description
             FOR l_xml_AttrGrps IN c_AttributeGrps(l_xml_ItemEBO.items)
             LOOP
               l_xml_attr_grp_int_nm := l_xml_AttrGrps.attributeGroups.extract('/AttributeGroup/ID/text()');

               if (l_xml_attr_grp_int_nm.getStringVal() = 'TRADE_ITEM_DESCRIPTION') then
                 FOR l_xml_Attrs IN c_Attributes(l_xml_AttrGrps.attributeGroups)
                 LOOP
                   l_xml_attr_int_nm := l_xml_Attrs.attributes.extract('/Attribute/ID/text()');
                   if (l_xml_attr_int_nm.getStringVal() = 'PRODUCT_DESCRIPTION') then
                     l_item_product_description := substr(l_xml_Attrs.attributes.extract('/Attribute/ValueText[position() =1]/text()').getStringVal(),1,240);
                   end if;
                 END LOOP;
               end if;
             END LOOP;

      -- Step 4: Insert Data into MTL_SYSTEM_ITEMS_INTERFACE
            INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE(
              message_timestamp,
              transaction_id,
              top_item_flag,
              bundle_id,
              set_process_id,
              source_system_id,
              source_system_reference,

              item_number,
              organization_code,

              serial_status_enabled,
              lot_status_enabled,
              service_item_flag,
              --type_code
              dual_uom_control,
              primary_uom_code,
              --storage_uom_code,
              --shipping_uom_code,
              --UOM_conversion_usage_code
              secondary_uom_code,
              description,


              unit_volume,
              volume_uom_code,
              unit_weight,
              weight_uom_code,
              dimension_uom_code,
              unit_length,
              unit_width,
              unit_height,

              cycle_count_enabled_flag,
              --lot_expiration_on_receipt,
              lot_merge_enabled,
              lot_split_enabled,
              --reservation_allowed_flag,
              --serialization_event_code,
              shelf_life_days,
              --revision_control_flag,
              stock_enabled_flag,
              auto_lot_alpha_prefix,
              --auto_lot_suffix,
              auto_serial_alpha_prefix,
              --auto_serial_suffix,

              --debit_gl_account_code,
              asset_creation_code,
              purchasing_enabled_flag,
              receipt_required_flag,
              must_use_approved_vendor_flag,
              allow_substitute_receipts_flag,
              allow_unordered_receipts_flag,
              rfq_required_flag,
              taxable_flag,
              hazard_class_id,
              tax_code,
              --issue_uom_code,
              --list_price_per_unit_amount,
              list_price_per_unit,
              under_shipment_tolerance,
              over_shipment_tolerance,
              --receipt_duration_tolerance,

              --manufactured_item_indicator,
              consigned_flag,
              inventory_planning_code,
              --reorder_max_inv_duration,
              --reorder_min_inv_duration,
              --reorder_max_inv_quantity,
              --reorder_min_inv_quantity,
              --reorder_quantity,
              min_minmax_quantity,
              max_minmax_quantity,
              minimum_order_quantity,
              shrinkage_rate,

              bom_item_type,
              config_model_type,
              effectivity_control,
              wip_supply_type,
              eng_item_flag,
              bom_enabled_flag,
              costing_enabled_flag,
              inventory_asset_flag,
              std_lot_size,
              back_orderable_flag,
              returnable_flag,
              --assemble_to_order_flag,

              gpc_code,
              trade_item_descriptor,
			  global_trade_item_number,  /*Added for bug 7110166 */
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
            ) VALUES(
              l_message_date,
              l_transaction_id,
              NVL(l_xml_ItemEBO.items.extract('/Item/AttributeGroup[ID = "EGO_ORCH_INT"]/Attribute[ID ="TopItem"]/Value/text()').getStringVal(), 'N'),
              l_bundle_id,
              l_batch_id,
              p_source_sys_id,
              l_source_sys_reference,

              --l_xml_ItemEBO.items.extract('/Item/ItemIdentification/Identification/Name/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/ItemIdentification/Identification/text()').getStringVal(),
              l_org_code,

              Decode(l_xml_ItemEBO.items.extract('/Item/ItemBase/SerialControlIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/ItemBase/LotControlIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/ItemBase/ServiceIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              --l_xml_ItemEBO.items.extract('/Item/ItemBase/TypeCode/text()').getStringVal(),
              Decode(l_xml_ItemEBO.items.extract('/Item/ItemBase/DualUOMTrackingIndicator/text()').getStringVal(), 'true', 1, 'false', 0, null),
              -- UOM to be set during import
              -- Bug#8833123
              l_xml_ItemEBO.items.extract('/Item/ItemBase/BaseUOMCode/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/ItemBase/StorageUOMCode/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/ItemBase/ShippingUOMCode/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/ItemBase/UOMConversionUsageCode/text()').getStringVal(),
              null,--l_xml_ItemEBO.items.extract('/Item/ItemBase/SecondaryUOMCode/text()').getStringVal(),
              -- Bug#8833123
              -- l_xml_ItemEBO.items.extract('/Item/ItemBase/Description[position() = 1]/text()').getStringVal(),
              substr(nvl(l_xml_ItemEBO.items.extract('/Item/ItemBase/Description[position() = 1]/text()').getStringVal(),
                     nvl(l_item_product_description,l_xml_ItemEBO.items.extract('/Item/ItemIdentification/Identification/Name/text()').getStringVal())),1,240),
              l_xml_ItemEBO.items.extract('/Item/PhysicalCharacteristics/UnitVolumeMeasure/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PhysicalCharacteristics/UnitVolumeMeasure/@unitCode').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PhysicalCharacteristics/UnitWeightMeasure/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PhysicalCharacteristics/UnitWeightMeasure/@unitCode').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PhysicalCharacteristics/LengthMeasure/@unitCode').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PhysicalCharacteristics/LengthMeasure/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PhysicalCharacteristics/WidthMeasure/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PhysicalCharacteristics/HeightMeasure/text()').getStringVal(),

              Decode(l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/CycleCountEnabledIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              --Decode(l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/LotExpirationOnReceiptIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/LotMergeEnabledIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/LotSplitEnabledIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              --Decode(l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/ReservationAllowedIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              --l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/SerializationEventCode/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/ShelfLifeDuration/text()').getStringVal(),
              --Decode(l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/RevisionControlIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/StockingAllowedIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/InitialLotNumberPrefix/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/InitialLotNumberSuffix/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/InitialSerialNumberPrefix/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/InventoryConfiguration/InitialSerialNumberSuffix/text()').getStringVal(),

              --l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/DebitGLAccountCode/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/AssetClassificationCode/text()').getStringVal(),
              Decode(l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/PurchasableIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/ReceiptRequiredIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/UseApprovedSupplierIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/AllowReceiptSubstitutionIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/AllowUnorderedReceiptIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/RFQRequiredIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/TaxableIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/HazardClassificationCode/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/TaxCode/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/IssueUOMCode/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/UnitListPrice/Amount/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/UnitListPrice/PerQuantity/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/OverReceiptTolerancePercent/UnderDuration/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/OverReceiptTolerancePercent/OverDuration/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/PurchasingConfiguration/ReceiptDurationTolerance/text()').getStringVal(),

              --Decode(l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/ManufacturedItemIndicator/text()').getStringVal(), 'true', 1, 'false', 0, null),
              Decode(l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/ConsignmentItemIndicator/text()').getStringVal(), 'true', 1, 'false', 0, null),
              l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/InventoryPlanningCode/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/ReorderSetup/MaximumInventoryDuration/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/ReorderSetup/MinimumInventoryDuration/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/ReorderSetup/MaximumReorderQuantity/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/ReorderSetup/MinimumReorderQuantity/text()').getStringVal(),
              --l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/ReorderSetup/ReorderQuantity/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/MinMaxSetup/MinimumInventoryQuantity/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/MinMaxSetup/MaximumInventoryQuantity/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/MinimumProductionOrderQuantity/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/PlanningConfiguration/ShrinkageRate/text()').getStringVal(),

              l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/BOMItemTypeCode/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/ConfiguratorModelTypeCode/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/EffectivityControlCode/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/WIPSupplyTypeCode/text()').getStringVal(),
              Decode(l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/EngineeringItemIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/AllowStructureIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/CostingEnabledIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/InventoryAssetIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              l_xml_ItemEBO.items.extract('/Item/ManufacturingConfiguration/StandardLotSizeQuantity/text()').getStringVal(),

              Decode(l_xml_ItemEBO.items.extract('/Item/OrderManagementConfiguration/BackOrderEnabledIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              Decode(l_xml_ItemEBO.items.extract('/Item/OrderManagementConfiguration/ReturnableIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),
              --Decode(l_xml_ItemEBO.items.extract('/Item/OrderManagementConfiguration/AssembleToOrderIndicator/text()').getStringVal(), 'true', 'Y', 'false', 'N', null),

              l_xml_ItemEBO.items.extract('/Item/ItemCatalog[PrimaryIndicator = "true"]/CatalogReference/CatalogIdentification/Identification/ID[@schemeName = "GPC"]/text()').getStringVal(),
              -- Expecting the trade_item_descriptor as the BaseUOM
              -- Bug#8833123
              -- l_xml_ItemEBO.items.extract('/Item/ItemBase/BaseUOMCode/text()').getStringVal(),
              l_xml_ItemEBO.items.extract('/Item/ItemBase/SecondaryUOMCode/text()').getStringVal(),
	      l_source_sys_reference, /*Added for bug 7110166 */
              l_created_by,
              l_creation_date,
              l_last_updated_by,
              l_last_update_date,
              l_last_update_login
            );

      -- Step 5: Insert Data for translatable entries for MTL_SYSTEM_ITEMS_INTERFACE

            SELECT XMLELEMENT("TL", l_xml_ItemEBO.items.extract('/Item/ItemIdentification/Name'))
            INTO l_xml_trans
            FROM DUAL;

            IF l_xml_trans IS NOT NULL
            THEN
              PROCESS_TL_ROWS(p_table_name      => 'MTL_SYSTEM_ITEMS_INTERFACE',
                              p_batch_id        => l_batch_id,
                              p_unique_id       => l_transaction_id,
                              p_bundle_id       => l_bundle_id,
                              p_xml_data        => l_xml_trans,
                              p_entity_name     => 'Name',
                              p_column_name     => 'ItemNumber');
            END IF;

            SELECT XMLELEMENT("TL", l_xml_ItemEBO.items.extract('/Item/ItemBase/Description'))
            INTO l_xml_trans
            FROM DUAL;

            IF l_xml_trans IS NOT NULL
            THEN
              PROCESS_TL_ROWS(p_table_name      => 'MTL_SYSTEM_ITEMS_INTERFACE',
                              p_batch_id        => l_batch_id,
                              p_unique_id       => l_transaction_id,
                              p_bundle_id       => l_bundle_id,
                              p_xml_data        => l_xml_trans,
                              p_entity_name     => 'Description',
                              p_column_name     => 'Description');
            END IF;

            INSERT INTO EGO_UCCNET_EVENTS (
              source_system_id,
              source_system_reference,
              message_id,
              import_batch_id,
              ext_complex_item_reference,
              batch_id,
              event_row_id,
              event_type,
              event_action,
              gtin,
              supplier_gln,
              target_market,
              cln_id,
              disposition_code,
              disposition_date,

              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN

            ) VALUES (
              p_source_sys_id,
              l_source_sys_reference,
              l_message_id,
              l_batch_id,
              l_external_bundle_id, -- External Bundle Id
              -1,
              l_transaction_id, -- PDUTTA:IDentify seq
              'PUBLICATION_INBOUND',
              'NEW_ITEM', -- Action or NEW_ITEM
              l_source_sys_reference,
              '-1', -- Supplier GLN
              '-1', -- Tgt Mgt
              l_bundle_id,
              EGO_POST_PROCESS_MESSAGE_PVT.G_CIC_ACCEPTED_MESSAGE_TYPE,
              sysdate,

              l_created_by,
              l_creation_date,
              l_last_updated_by,
              l_last_update_date,
              l_last_update_login

            );

      -- Step 6: Insert Data for classifications/categories
            FOR l_xml_Classification IN c_classifications(l_xml_ItemEBO.items)
            LOOP
              --bug:6485109 Insert concatenated segments category name
              FOR l_alt_cat_conc_seg_rec IN c_alt_cat_concat_seg ( l_xml_Classification.classifications.extract('/ItemCatalog/CatalogReference/CatalogIdentification/Identification/ID/text()').getStringVal() )
              LOOP
                l_alt_cat_concat_seg := l_alt_cat_conc_seg_rec.concatenated_segments;
              END LOOP;

              INSERT INTO MTL_ITEM_CATEGORIES_INTERFACE(
                transaction_id,
                category_set_name,
                category_name,
                source_system_id,
                source_system_reference,
                bundle_id,
                set_process_id,

                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN
              ) VALUES (
                l_transaction_id,
                l_xml_Classification.classifications.extract('/ItemCatalog/CatalogReference/CatalogIdentification/Identification/ID/@schemeName').getStringVal(),
                l_alt_cat_concat_seg,
                p_source_sys_id,
                l_source_sys_reference,
                l_bundle_id,
                l_batch_id,

                l_created_by,
                l_creation_date,
                l_last_updated_by,
                l_last_update_date,
                l_last_update_login
              );
            END LOOP; -- Loop over Classifications

      -- Step 7: Insert Data for Suppliers
            FOR l_xml_Supplier IN c_suppliers(l_xml_ItemEBO.items)
            LOOP
              BEGIN
                l_xml_null_chk := l_xml_Supplier.suppliers.extract('/ItemSupplier/SupplierPartyReference/PartyIdentification/AlternateIdentification/ID[@schemeName = "GLN"]/text()');
                IF l_xml_null_chk IS NULL
                THEN
                  RAISE EGO_ORC_NO_GLN;
                END IF;


                GET_SUPPLIER_INFO ( X_EXT_SUP_ID     => l_xml_null_chk.getStringVal(),
                                    X_EXT_SUP_TYPE   => 'GLN',
                                    X_SUP_LEVEL      => 'SUPPLIER',
                                    X_SUPPLIER_ID    => l_supplier_id,
                                    X_SUPPLIER_NAME  => l_supplier_name
                                  );

                IF l_supplier_id IS NULL
                THEN
                  RAISE EGO_ORC_INVALID_GLN;
                ELSE
                  INSERT INTO EGO_ITEM_ASSOCIATIONS_INTF(
                    transaction_id,
                    batch_id,
                    source_system_id,
                    source_system_reference,
                    bundle_id,

                    pk1_value,
                    supplier_name,
                    supplier_number,
                    --supplier_site_name,
                    data_level_name,

                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN,
                    transaction_type
                  ) VALUES(
                    l_transaction_id,
                    l_batch_id,
                    p_source_sys_id,
                    l_source_sys_reference,
                    l_bundle_id,

                    l_supplier_id,
                    l_supplier_name,
                    l_supplier_id,
                    --l_supplier_site_name,
                    'ITEM_SUP',

                    l_created_by,
                    l_creation_date,
                    l_last_updated_by,
                    l_last_update_date,
                    l_last_update_login,
                    'SYNC'
                  );
        -- Step 8: Insert Data for Supplier Attributes
                  SAVE_ATTR_DATA( p_xml                     => l_xml_Supplier.suppliers,
                                p_entity_name             => 'ItemSupplier',
                                p_transaction_id          => l_transaction_id,
                                p_bundle_id               => l_bundle_id,
                                p_source_system_id        => p_source_sys_id,
                                p_source_system_reference => l_source_sys_reference,
				p_organization_code       => l_org_code,
                                p_data_set_id             => l_batch_id,
                                p_data_level_name         => 'ITEM_SUP',
                                p_pk1_value               => l_supplier_id,
                                p_pk2_value               => NULL,
                                p_created_by              => l_created_by,
                                p_creation_date           => l_creation_date,
                                p_last_updated_by         => l_last_updated_by,
                                p_last_update_date        => l_last_update_date,
                                p_last_update_login       => l_last_update_login);

        -- Step 9: Insert Data for Supplier Site Attributes
                  FOR l_xml_SupplierSite IN c_supplierLocations(l_xml_Supplier.suppliers)
                  LOOP
                    l_xml_null_chk := l_xml_SupplierSite.supplierLocations.extract('/ItemSupplierLocation/LocationReference/LocationIdentification/AlternateIdentification/ID[@schemeName = "GLN"]/text()');
                    IF l_xml_null_chk IS NULL
                    THEN
                      RAISE EGO_ORC_NO_GLN;
                    END IF;
                    GET_SUPPLIER_INFO ( X_EXT_SUP_ID     => l_xml_null_chk.getStringVal(),
                                        X_EXT_SUP_TYPE   => 'GLN',
                                        X_SUP_LEVEL      => 'SITE',
                                        X_SUPPLIER_ID    => l_supplier_site_id,
                                        X_SUPPLIER_NAME  => l_supplier_name
                                      );
                    IF l_supplier_id IS NULL
                    THEN
                      RAISE EGO_ORC_INVALID_GLN;
                    ELSE

                      -- bug:6485109 Insert a row for item supplier site for item supplier site org
                      IF ( l_supplier_attr_level = 'ITEM_SUP_SITE_ORG')
                      THEN
                        INSERT INTO EGO_ITEM_ASSOCIATIONS_INTF(
                          transaction_id,
                          batch_id,
                          source_system_id,
                          source_system_reference,
                          bundle_id,

                          pk1_value,
                          pk2_value,
                          supplier_name,
                          supplier_number,
                          supplier_site_name,
                          data_level_name,

                          CREATED_BY,
                          CREATION_DATE,
                          LAST_UPDATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATE_LOGIN,
                          transaction_type
                        ) VALUES(
                          l_transaction_id,
                          l_batch_id,
                          p_source_sys_id,
                          l_source_sys_reference,
                          l_bundle_id,

                          l_supplier_id,
                          l_supplier_site_id,
                          l_supplier_name,
                          l_supplier_site_id,
                          l_xml_SupplierSite.supplierLocations.extract('/ItemSupplierLocation/LocationReference/Name/text()').getStringVal(),
                          'ITEM_SUP_SITE',

                          l_created_by,
                          l_creation_date,
                          l_last_updated_by,
                          l_last_update_date,
                          l_last_update_login,
                          'SYNC'
                      );

                      END IF;

                      INSERT INTO EGO_ITEM_ASSOCIATIONS_INTF(
                        transaction_id,
                        batch_id,
                        source_system_id,
                        source_system_reference,
                        bundle_id,
                        organization_code,

                        pk1_value,
                        pk2_value,
                        supplier_name,
                        supplier_number,
                        supplier_site_name,
                        data_level_name,

                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        transaction_type
                      ) VALUES(
                        l_transaction_id,
                        l_batch_id,
                        p_source_sys_id,
                        l_source_sys_reference,
                        l_bundle_id,
                        l_org_code,

                        l_supplier_id,
                        l_supplier_site_id,
                        l_supplier_name,
                        l_supplier_site_id,
                        l_xml_SupplierSite.supplierLocations.extract('/ItemSupplierLocation/LocationReference/Name/text()').getStringVal(),
                        l_supplier_attr_level,

                        l_created_by,
                        l_creation_date,
                        l_last_updated_by,
                        l_last_update_date,
                        l_last_update_login,
                        'SYNC'
                      );
        -- Step 10: Insert Data for Supplier Site Attributes
                      SAVE_ATTR_DATA( p_xml                     => l_xml_SupplierSite.supplierLocations,
                                      p_entity_name             => 'ItemSupplierLocation',
                                      p_transaction_id          => l_transaction_id,
                                      p_bundle_id               => l_bundle_id,
                                      p_source_system_id        => p_source_sys_id,
                                      p_source_system_reference => l_source_sys_reference,
				      p_organization_code       => l_org_code,
                                      p_data_set_id             => l_batch_id,
                                      p_data_level_name         => l_supplier_attr_level,
                                      p_pk1_value               => l_supplier_id,
                                      p_pk2_value               => l_supplier_site_id,
                                      p_created_by              => l_created_by,
                                      p_creation_date           => l_creation_date,
                                      p_last_updated_by         => l_last_updated_by,
                                      p_last_update_date        => l_last_update_date,
                                      p_last_update_login       => l_last_update_login);
                    END IF;
                  END LOOP; -- Loop over Supplier Sites
                END IF;
              EXCEPTION
                WHEN EGO_ORC_NO_GLN
                THEN
                  l_MessageTag := l_MessageTag || 'EGO_ORC_NO_GLN ';
                WHEN EGO_ORC_INVALID_GLN
                THEN
                  l_MessageTag := l_MessageTag || 'EGO_ORC_INVALID_GLN';
              END;
            END LOOP; -- Loop over Suppliers
      -- Step 11: Insert Data for Item Attributes
            SAVE_ATTR_DATA( p_xml                     => l_xml_ItemEBO.items,
                            p_entity_name             => 'Item',
                            p_transaction_id          => l_transaction_id,
                            p_bundle_id               => l_bundle_id,
                            p_source_system_id        => p_source_sys_id,
                            p_source_system_reference => l_source_sys_reference,
			    p_organization_code       => l_org_code,
                            p_data_set_id             => l_batch_id,
                            p_data_level_name         => 'ITEM_LEVEL',
                            p_pk1_value               => null,
                            p_pk2_value               => null,
                            p_created_by              => l_created_by,
                            p_creation_date           => l_creation_date,
                            p_last_updated_by         => l_last_updated_by,
                            p_last_update_date        => l_last_update_date,
                            p_last_update_login       => l_last_update_login);
          END LOOP; -- Loop over Items

          FOR l_xml_structure IN c_structure(l_xml_CplxItem.bundles)
          LOOP
            BEGIN
              l_xml_null_chk := l_xml_structure.structures.extract('/ItemStructure/ItemReference/ItemIdentification/GTIN/text()');
              IF l_xml_null_chk IS NULL
              THEN
                RAISE EGO_ORC_NO_STRUCTURE;
              END IF;
              l_hdr_source_sys_reference := l_xml_null_chk.getStringVal();

              INSERT INTO BOM_BILL_OF_MTLS_INTERFACE(
                transaction_id,
                batch_id,
                --source_system_id,
                source_system_reference,
                bundle_id,
                alternate_bom_designator,
                organization_code,

                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN
              ) VALUES(
                NULL,--l_transaction_id,
                l_batch_id,
                --p_source_sys_id,
                l_hdr_source_sys_reference,
                l_bundle_id,
                'PIM_PBOM_S',
                l_org_code,

                l_created_by,
                l_creation_date,
                l_last_updated_by,
                l_last_update_date,
                l_last_update_login
              );

              FOR l_xml_component IN c_component(l_xml_structure.structures)
              LOOP
                INSERT INTO BOM_INVENTORY_COMPS_INTERFACE(
                  transaction_id,
                  batch_id,
                  --source_system_id,
                  parent_source_system_reference,
                  comp_source_system_reference,
                  bundle_id,
                  alternate_bom_designator,
                  organization_code,
                  component_quantity,
                  primary_unit_of_measure,

                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN
                ) VALUES(
                  NULL,--l_transaction_id,
                  l_batch_id,
                  --p_source_sys_id,
                  l_hdr_source_sys_reference,
                  l_xml_component.components.extract('/ComponentItem/ItemReference/ItemIdentification/GTIN/text()').getStringVal(),
                  l_bundle_id,
                  'PIM_PBOM_S',
                  l_org_code,
                  l_xml_component.components.extract('/ComponentItem/ComponentItemBase/Quantity/text()').getStringVal(),
                  l_xml_component.components.extract('/ComponentItem/ComponentItemBase/Quantity/@unitCode').getStringVal(),

                  l_created_by,
                  l_creation_date,
                  l_last_updated_by,
                  l_last_update_date,
                  l_last_update_login
              );

              END LOOP; -- Loop over Components
            EXCEPTION
              WHEN EGO_ORC_NO_STRUCTURE
              THEN
                l_MessageTag := l_MessageTag || 'EGO_ORC_NO_STRUCTURE ';
            END;
          END LOOP; -- Loop over ItemStructures

          IF l_xml_batch_name IS NULL
          THEN
            RAISE EGO_ORC_NO_BATCH;
          END IF;

          IF l_error_msg <> 'SUCCESS' AND l_batch_id = 0
          THEN
            RAISE EGO_MSG_ERROR;
          END IF;


          IF l_reg_bundle = FALSE
          THEN
            l_reg_bundle := TRUE;
            l_bundles_clob := l_BundlesStartTag;
          END IF;

          dbms_lob.writeappend(l_bundles_clob, length(l_BundleStartTag), l_BundleStartTag);
          dbms_lob.writeappend(l_bundles_clob, length(l_BundleIdStartTag), l_BundleIdStartTag);
          dbms_lob.writeappend(l_bundles_clob, length(l_bundle_id), l_bundle_id);
          dbms_lob.writeappend(l_bundles_clob, length(l_BundleIdEndTag), l_BundleIdEndTag);
          IF l_MessageTag IS NOT NULL
          THEN
            l_MessageTag := '<Message  type="Warning">'||l_MessageTag||'</Message>';
            dbms_lob.writeappend(l_bundles_clob, length(l_MessageTag), l_MessageTag);
          END IF;
          dbms_lob.writeappend(l_bundles_clob, length(l_BundleEndTag), l_BundleEndTag);

          EXCEPTION
            WHEN EGO_ORC_DELETE_LINE --Ignore Delete messages
            THEN
              NULL;

            WHEN EGO_ORC_NO_BATCH
            THEN
              IF l_err_bundle = FALSE
              THEN
                l_err_bundle := TRUE;
                l_err_bundles_clob := l_BundlesStartTag;
              END IF;
              l_MessageTag := '<Message type="Error">EGO_ORC_NO_BATCH</Message>';

              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleStartTag), l_BundleStartTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdStartTag), l_BundleIdStartTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_bundle_id), l_bundle_id);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdEndTag), l_BundleIdEndTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_MessageTag), l_MessageTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleEndTag), l_BundleEndTag);
            WHEN EGO_ORC_NO_GTIN
            THEN
              IF l_err_bundle = FALSE
              THEN
                l_err_bundle := TRUE;
                l_err_bundles_clob := l_BundlesStartTag;
              END IF;
              l_MessageTag := '<Message type="Error">EGO_ORC_NO_GTIN</Message>';

              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleStartTag), l_BundleStartTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdStartTag), l_BundleIdStartTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_bundle_id), l_bundle_id);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdEndTag), l_BundleIdEndTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_MessageTag), l_MessageTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleEndTag), l_BundleEndTag);

            WHEN EGO_MSG_ERROR
            THEN
              IF l_err_bundle = FALSE
              THEN
                l_err_bundle := TRUE;
                l_err_bundles_clob := l_BundlesStartTag;
              END IF;
              l_MessageTag := '<Message type="Error">'||l_error_msg||'</Message>';

              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleStartTag), l_BundleStartTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdStartTag), l_BundleIdStartTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_bundle_id), l_bundle_id);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdEndTag), l_BundleIdEndTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_MessageTag), l_MessageTag);
              dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleEndTag), l_BundleEndTag);
      END;
    END LOOP; -- Loop over Bundles

    IF l_reg_bundle = TRUE
    THEN
      dbms_lob.writeappend(l_bundles_clob, length(l_BundlesEndTag), l_BundlesEndTag);
      ADD_BUNDLES_TO_COL (x_bundle_collection_id   => -1,
                          p_bundles_clob           => l_bundles_clob,
                          x_new_bundle_col_id      => x_new_bundle_col_id,
                          p_commit                 => p_commit
                        );
    END IF;

    IF l_err_bundle = TRUE
    THEN
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundlesEndTag), l_BundlesEndTag);
      ADD_BUNDLES_TO_COL (x_bundle_collection_id   => -1,
                          p_bundles_clob           => l_err_bundles_clob,
                          x_new_bundle_col_id      => x_err_bundle_col_id,
                          p_commit                 => p_commit
                        );
    END IF;


  END IF; -- Input XML Check
  EXCEPTION
    WHEN EGO_ORC_HDR_SEC_NOT_FOUND
    THEN
      l_err_bundles_clob := l_BundlesStartTag;
      l_MessageTag := '<Message>EGO_ORC_HDR_SEC_NOT_FOUND</Message>';
      l_bundle_id := GET_NEXT_ID();
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleStartTag), l_BundleStartTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdStartTag), l_BundleIdStartTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_bundle_id), l_bundle_id);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdEndTag), l_BundleIdEndTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_MessageTag), l_MessageTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleEndTag), l_BundleEndTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundlesEndTag), l_BundlesEndTag);
      ADD_BUNDLES_TO_COL (x_bundle_collection_id   => -1,
                          p_bundles_clob           => l_err_bundles_clob,
                          x_new_bundle_col_id      => x_err_bundle_col_id,
                          p_commit                 => p_commit
                        );

    WHEN EGO_ORC_XML_ERROR
    THEN
      l_err_bundles_clob := l_BundlesStartTag;
      l_MessageTag := '<Message>EGO_ORC_XML_ERROR</Message>';
      l_bundle_id := GET_NEXT_ID();
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleStartTag), l_BundleStartTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdStartTag), l_BundleIdStartTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_bundle_id), l_bundle_id);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleIdEndTag), l_BundleIdEndTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_MessageTag), l_MessageTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundleEndTag), l_BundleEndTag);
      dbms_lob.writeappend(l_err_bundles_clob, length(l_BundlesEndTag), l_BundlesEndTag);
      ADD_BUNDLES_TO_COL (x_bundle_collection_id   => -1,
                          p_bundles_clob           => l_err_bundles_clob,
                          x_new_bundle_col_id      => x_err_bundle_col_id,
                          p_commit                 => p_commit
                        );


END SAVE_DATA;

END EGO_ORCHESTRATION_UTIL_PUB;



/
