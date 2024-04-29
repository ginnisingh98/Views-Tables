--------------------------------------------------------
--  DDL for Package Body CZ_IMP_SINGLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_IMP_SINGLE" AS
/*	$Header: czisngb.pls 120.25.12010000.4 2010/04/29 19:17:35 lamrute ship $		*/

/*******************************
Stuller's changes :

1. extr_intl_text - orig_sys_ref has inventory_item_id:expl_type:orgId (instead of description)
2. Select - Distinct - items
3. Select - Distinct - item_property_value
4. Call cz_ref.delete_duplicates after populate_table
5. extr_intl_text change to query bill_sequence_id and use in query

********************************/

G_BOM_APPLICATION_ID CONSTANT NUMBER := 702;
G_EGO_APPLICATION_ID CONSTANT NUMBER := 431;

G_PKG_NAME           CONSTANT VARCHAR2(50) := 'CZ_IMP_SINGLE';

DECIMAL_TYPE         CONSTANT NUMBER := 2;
TEXT_TYPE            CONSTANT NUMBER := 4;
TL_TEXT_TYPE         CONSTANT NUMBER := 8;

l_Batch_Size         NUMBER          := 100;

g_ItemCatalogTable   SYSTEM.CZ_ITEM_CATALOG_TBL := SYSTEM.CZ_ITEM_CATALOG_TBL(SYSTEM.CZ_ITEM_CATALOG_REC(NULL));
g_CONFIG_ENGINE_TYPE VARCHAR2(10);

TYPE tCatalogGroupId  IS TABLE OF cz_exv_item_master.item_catalog_group_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tInventoryItemId IS TABLE OF cz_exv_item_master.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE tInt             IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

itemCatalogGroupId    tCatalogGroupId;
repCatalogGroupId     tCatalogGroupId;
inventoryItemId       tInventoryItemId;
repItemId             tInventoryItemId;
hashCatalog           tInt;

-- This table contains top model IDs of explosions that have been processed within an import run
processed_expls_tbl   tInt;

--This variable stores a value of db setting, introduced for Pella, to be used across two procedures.

allowDecimalOptionClass  PLS_INTEGER;

--9496782
czGatherStatsCnt         NUMBER := 0;

TYPE number_tbl_type       IS TABLE OF NUMBER           INDEX BY BINARY_INTEGER;
TYPE varchar_tbl_type      IS TABLE OF VARCHAR2(255)    INDEX BY BINARY_INTEGER;
TYPE long_varchar_tbl_type IS TABLE OF VARCHAR2(4000)   INDEX BY BINARY_INTEGER;
TYPE varchar_arr_tbl_type  IS TABLE OF varchar_tbl_type INDEX BY BINARY_INTEGER;
TYPE number_arr_tbl_type   IS TABLE OF number_tbl_type  INDEX BY BINARY_INTEGER;
TYPE varchar_iv_tbl_type   IS TABLE OF VARCHAR2(255)    INDEX BY VARCHAR2(255);

TYPE  rec_cols_rec   IS RECORD (col_name VARCHAR2(255),col_num NUMBER);
TYPE  rec_cols_tbl   IS TABLE OF rec_cols_rec INDEX BY VARCHAR2(255);

PROCEDURE get_App_Info(p_app_short_name IN VARCHAR2,
                       x_oracle_schema  OUT NOCOPY VARCHAR2) IS

  v_status            VARCHAR2(255);
  v_industry          VARCHAR2(255);
  v_ret               BOOLEAN;
BEGIN
  v_ret := FND_INSTALLATION.GET_APP_INFO(APPLICATION_SHORT_NAME => p_app_short_name,
                                         STATUS                 => v_status,
                                         INDUSTRY               => v_industry,
                                         ORACLE_SCHEMA          => x_oracle_schema);
END;

------------------------------------------------------------------------------------------
-- Returns true if the input child model should be refreshed within this import run.
-- This check was added for Stuller but isn't currently in use.  To do this correctly,
-- the logic in this procedure would need to be replaced for a check to see if this
-- model was modified in BOM.

FUNCTION importChildModel(inRunId           IN NUMBER,
                          inOrgId           IN NUMBER,
                          inTopId           IN NUMBER,
                          inExplType        IN VARCHAR2)
RETURN BOOLEAN IS

   CURSOR c_childModel IS
      SELECT p.model_ps_node_id FROM cz_xfr_project_bills p, cz_devl_projects d
      WHERE p.organization_id = inOrgId
        AND p.top_item_id = inTopId
        AND p.explosion_type = inExplType
        AND d.deleted_flag = '0'
        AND d.devl_project_id = d.persistent_project_id
        AND p.model_ps_node_id = d.devl_project_id;

   xERROR           BOOLEAN:=FALSE;
   nChildFound      BOOLEAN:=FALSE;
   nDevlProjectId   cz_devl_projects.devl_project_id%TYPE;

BEGIN

  OPEN c_childModel;
  FETCH c_childModel INTO nDevlProjectId;
    nChildFound:=c_childModel%FOUND;
  CLOSE c_childModel;
return nChildFound;
END;
------------------------------------------------------------------------------------------

PROCEDURE EXTR_ITEM_MASTER(inRun_ID    IN PLS_INTEGER,
                           nOrg_ID     IN NUMBER,
                           nTop_ID     IN NUMBER,
                           sExpl_type  IN VARCHAR2)
IS
  DFLT_REFPARTNBR CZ_DB_SETTINGS.VALUE%TYPE;
  xERROR          BOOLEAN :=FALSE;

  v_settings_id      VARCHAR2(40);
  v_section_name     VARCHAR2(30);

  CURSOR C_REF_PART_NBR IS
   SELECT UPPER(VALUE) FROM CZ_DB_SETTINGS
   WHERE UPPER(SECTION_NAME) = v_section_name
         AND UPPER(SETTING_ID) = v_settings_id;

   TYPE tItemDesc                 IS TABLE OF cz_exv_items.item_desc%TYPE INDEX BY BINARY_INTEGER;
   TYPE tBomItemType              IS TABLE OF cz_exv_items.bom_item_type%TYPE INDEX BY BINARY_INTEGER;
   TYPE tOrganizationId           IS TABLE OF cz_exv_items.organization_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tInventoryItemId          IS TABLE OF cz_exv_items.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tSegment1                 IS TABLE OF cz_exv_items.segment1%TYPE INDEX BY BINARY_INTEGER;
   TYPE tConcatenatedSegments     IS TABLE OF cz_exv_items.concatenated_segments%TYPE INDEX BY BINARY_INTEGER;
   TYPE tFixedLeadTime            IS TABLE OF cz_exv_items.fixed_lead_time%TYPE INDEX BY BINARY_INTEGER;
   TYPE tItemStatusCode           IS TABLE OF cz_exv_items.inventory_item_status_code%TYPE INDEX BY BINARY_INTEGER;
   TYPE tCatalogId                IS TABLE OF cz_exv_items.item_catalog_group_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tIndivisibleFlag          IS TABLE OF cz_exv_items.indivisible_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tCustomerOrderFlag        IS TABLE OF cz_exv_items.customer_order_enabled_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tPrimaryUomCode           IS TABLE OF cz_exv_items.primary_uom_code%TYPE INDEX BY BINARY_INTEGER;

   TYPE tOrigSysRef               IS TABLE OF cz_imp_item_master.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
   TYPE tRefPartNbr               IS TABLE OF cz_imp_item_master.ref_part_nbr%TYPE INDEX BY BINARY_INTEGER;
   TYPE tDescText                 IS TABLE OF cz_imp_item_master.desc_text%TYPE INDEX BY BINARY_INTEGER;
   TYPE tLeadTime                 IS TABLE OF cz_imp_item_master.lead_time%TYPE INDEX BY BINARY_INTEGER;
   TYPE tQuoteableFlag            IS TABLE OF cz_imp_item_master.quoteable_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tDeletedFlag              IS TABLE OF cz_imp_item_master.deleted_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tItemUomCode              IS TABLE OF cz_imp_item_master.primary_uom_code%TYPE INDEX BY BINARY_INTEGER;
   TYPE tDecimalQtyFlag           IS TABLE OF cz_imp_item_master.decimal_qty_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tFskItemType              IS TABLE OF cz_imp_item_master.fsk_itemtype_1_1%TYPE INDEX BY BINARY_INTEGER;
   TYPE tSrcApplicationId         IS TABLE OF cz_imp_item_master.src_application_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tSrcTypeCode              IS TABLE OF cz_imp_item_master.src_type_code%TYPE INDEX BY BINARY_INTEGER;

   InventoryItemId                tInventoryItemId;
   OrganizationId                 tOrganizationId;
   Segment1                       tSegment1;
   ConcatenatedSegments           tConcatenatedSegments;
   ItemDesc                       tItemDesc;
   FixedLeadTime                  tFixedLeadTime;
   BomItemType                    tBomItemType;
   CustomerOrderFlag              tCustomerOrderFlag;
   ItemStatusCode                 tItemStatusCode;
   PrimaryUomCode                 tPrimaryUomCode;
   IndivisibleFlag                tIndivisibleFlag;
   CatalogId                      tCatalogId;
   SrcApplicationId               tSrcApplicationId;

   iOrigSysRef                    tOrigSysRef;
   iRefPartNbr                    tRefPartNbr;
   iDescText                      tDescText;
   iLeadTime                      tLeadTime;
   iQuoteableFlag                 tQuoteableFlag;
   iDeletedFlag                   tDeletedFlag;
   iPrimaryUomCode                tItemUomCode;
   iDecimalQtyFlag                tDecimalQtyFlag;
   iFskItemType                   tFskItemType;
   iSrcApplicationId              tSrcApplicationId;
   iSrcTypeCode                   tSrcTypeCode;
   nIndex                         PLS_INTEGER := 1;

   st_time          number;
   end_time         number;
   loop_end_time    number;
   insert_end_time  number;
   d_str            varchar2(255);

BEGIN

  v_settings_id := 'REFPARTNBR';
  v_section_name := 'ORAAPPS_INTEGRATE';

  OPEN C_REF_PART_NBR;
  FETCH C_REF_PART_NBR INTO DFLT_REFPARTNBR;
  CLOSE C_REF_PART_NBR;

    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;

    SELECT DISTINCT INVENTORY_ITEM_ID, ORGANIZATION_ID, SEGMENT1, CONCATENATED_SEGMENTS, ITEM_DESC,
           FIXED_LEAD_TIME, BOM_ITEM_TYPE, CUSTOMER_ORDER_ENABLED_FLAG,
           INVENTORY_ITEM_STATUS_CODE, PRIMARY_UOM_CODE, INDIVISIBLE_FLAG, ITEM_CATALOG_GROUP_ID,
           INV_APPLICATION_ID
    BULK COLLECT INTO
           InventoryItemId, OrganizationId, Segment1, ConcatenatedSegments, ItemDesc,
           FixedLeadTime, BomItemType, CustomerOrderFlag,
           ItemStatusCode, PrimaryUomCode, IndivisibleFlag, CatalogId,
           SrcApplicationId
    FROM CZ_EXV_ITEMS
    WHERE ORGANIZATION_ID=nOrg_ID AND TOP_ITEM_ID=nTop_ID
      AND EXPLOSION_TYPE=sExpl_type;

    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Bulk collect item master (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_id);
    end if;

    FOR i IN 1..InventoryItemId.COUNT LOOP

      iOrigSysRef(nIndex) := CZ_ORAAPPS_INTEGRATE.ITEM_SURROGATE_KEY(to_char(InventoryItemId(i)),to_char(OrganizationId(i)));
      IF(DFLT_REFPARTNBR = 'SEGMENT1')THEN
        iRefPartNbr(nIndex) := Segment1(i);
      ELSIF(DFLT_REFPARTNBR = 'CONCATENATED_SEGMENTS')THEN
        iRefPartNbr(nIndex) := ConcatenatedSegments(i);
      ELSE
        iRefPartNbr(nIndex) := ItemDesc(i);
      END IF;
      iDescText(nIndex) := ItemDesc(i);
      iLeadTime(nIndex) := FixedLeadTime(i);
      IF(CustomerOrderFlag(i) = 'N')THEN
        IF(BomItemType(i) = cnStandard)THEN
          iQuoteableFlag(nIndex) := '1';
        ELSE
          iQuoteableFlag(nIndex) := '0';
        END IF;
      ELSE
        iQuoteableFlag(nIndex) := '1';
      END IF;
      /* Bug 8210696 - no need to check for 'OBSOLETE'
      IF(ItemStatusCode(i) = 'OBSOLETE')THEN
        iDeletedFlag(nIndex) := '1';
      ELSE
        iDeletedFlag(nIndex) := '0';
      END IF;*/
      iDeletedFlag(nIndex) := '0';
      iPrimaryUomCode(nIndex) := PrimaryUomCode(i);

/* Added the profile condition for the fix of bug # 3074328  jjujjava 10/06/03 */
      IF(UPPER(FND_PROFILE.VALUE('CZ_IMP_DECIMAL_QTY_FLAG')) = 'Y')THEN
	  IF(IndivisibleFlag(i) = 'Y')THEN
	    iDecimalQtyFlag(nIndex) := '0';
          ELSIF(BomItemType(i) = cnStandard OR (BomItemType(i) = cnOptionClass AND allowDecimalOptionClass = 1)) THEN
	      iDecimalQtyFlag(nIndex) := '1';
	  ELSE
	    iDecimalQtyFlag(nIndex) := '0';
	  END IF;
      ELSE
         iDecimalQtyFlag(nIndex) := '0';
      END IF;

      iFskItemType(nIndex) := CatalogId(i);
      iSrcApplicationId(nIndex) := SrcApplicationId(i);
      iSrcTypeCode(nIndex) := BomItemType(i);

      nIndex := nIndex + 1;
    END LOOP;

    if (CZ_IMP_ALL.get_time) then
        loop_end_time := dbms_utility.get_time();
        --dbms_output.put_line ('loop over coll. (' || nTop_Id || ') :' || (loop_end_time-end_time)/100.00);
    end if;

    FORALL i IN 1..iOrigSysRef.COUNT
      INSERT /*+ APPEND */ INTO CZ_IMP_ITEM_MASTER
        (ORIG_SYS_REF, REF_PART_NBR, DESC_TEXT, LEAD_TIME,
         QUOTEABLE_FLAG, DELETED_FLAG,
         RUN_ID, PRIMARY_UOM_CODE, DECIMAL_QTY_FLAG,
         FSK_ITEMTYPE_1_1, FSK_ITEMTYPE_1_EXT,
         SRC_APPLICATION_ID,SRC_TYPE_CODE)
      VALUES
        (iOrigSysRef(i), iRefPartNbr(i), ItemDesc(i), iLeadTime(i),
         iQuoteableFlag(i), iDeletedFlag(i),
         inRun_ID, iPrimaryUomCode(i), iDecimalQtyFlag(i),
         iFskItemType(i), iFskItemType(i),
         iSrcApplicationId(i), iSrcTypeCode(i));

    if (CZ_IMP_ALL.get_time) then
        insert_end_time := dbms_utility.get_time();
        --dbms_output.put_line ('Insert imp item master (' || nTop_Id || ') :' || (insert_end_time-end_time)/100.00);
    end if;


   COMMIT;

EXCEPTION
 WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
 WHEN OTHERS THEN
   d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
   xERROR:=cz_utils.log_report(d_str,1,'EXTR_ITEM_MASTER',11276,inRun_Id);
   RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------

  PROCEDURE setFCEMinMax (minVal              IN OUT NOCOPY NUMBER,
                          maxVal              IN OUT NOCOPY NUMBER,
                          defaultVal          IN NUMBER,
                          p_decimal_item_flag IN VARCHAR2,
                          p_use_defaults      IN VARCHAR2,
                          p_set_decimals      IN VARCHAR2,
                          p_default_dec       IN NUMBER,
                          p_default_int       IN NUMBER ) IS
    l_max_boundary_val NUMBER;

    FUNCTION setFCEMaxBoundary RETURN NUMBER IS
      l_max_boundary_val  NUMBER;
    BEGIN
      --
      -- by default set max boundary value to FND_PROFILE.VALUE('CZ_DEFAULT_MAX_QTY_INT')
      --
      l_max_boundary_val := p_default_int;

      --
      -- if Imports sets decimal quantity <=> FND_PROFILE.VALUE('CZ_IMP_DECIMAL_QTY_FLAG')='Y'
      --    and item is decimal <=> p_decimal_item_flag='1'
      -- then set set max boundary value to FND_PROFILE.VALUE('CZ_DEFAULT_MAX_QTY_DEC')
      --
      IF (UPPER(p_set_decimals)='Y' AND p_decimal_item_flag='1') THEN
        l_max_boundary_val := p_default_dec;
      END IF;
      RETURN l_max_boundary_val;
    END setFCEMaxBoundary;

    FUNCTION setFCEMin RETURN NUMBER IS
    BEGIN
      IF p_set_decimals='Y' AND p_decimal_item_flag='1' THEN
        RETURN 0; -- decimals are used and decimal flag = true
      END IF;
      RETURN 1; -- integer or decimals , but decimals are not used
    END setFCEMin;

  BEGIN
    -- get value of max boundary
    l_max_boundary_val := setFCEMaxBoundary();

    IF defaultVal IS NULL THEN
      --
      -- min=NULL, max=NULL, default value=NULL
      --
      IF minVal IS NULL AND (maxVal IS NULL OR maxVal IN(0,-1)) THEN
        minVal := setFCEMin();
        maxVal := l_max_boundary_val;
        RETURN;
      END IF;

      --
      -- min=NULL, max IS NOT NULL, default value=NULL
      --
      IF minVal IS NULL AND NOT(maxVal IS NULL OR maxVal IN(0,-1)) THEN
        minVal := setFCEMin();
        RETURN;
      END IF;

      --
      -- min IS NOT NULL, max IS NOT NULL, default value=NULL
      --
      IF minVal IS NOT NULL AND NOT(maxVal IS NULL OR maxVal IN(0,-1)) THEN
        RETURN;
      END IF;

      --
      -- min IS NOT NULL, max IS NULL, default value=NULL
      --
      IF minVal IS NOT NULL AND (maxVal IS NULL OR maxVal IN(0,-1)) THEN
        maxVal := l_max_boundary_val;
        RETURN;
      END IF;

    ELSE -- there is a not null default value

      --
      -- min=NULL, max=NULL, default value IS NOT NULL
      --
      IF minVal IS NULL AND (maxVal IS NULL OR maxVal IN(0,-1)) THEN
        IF p_use_defaults='Y' THEN
          minVal := defaultVal;
          maxVal := defaultVal;
        ELSE
          minVal := setFCEMin();
          maxVal := l_max_boundary_val;
        END IF;
        RETURN;
      END IF;

      --
      -- min=NULL, max IS NOT NULL, default value IS NOT NULL
      --
      IF minVal IS NULL AND NOT(maxVal IS NULL OR maxVal IN(0,-1)) THEN
        IF p_use_defaults='Y' THEN
          IF defaultVal <= maxVal THEN
            minVal := defaultVal;
          ELSE
            minVal := setFCEMin();
          END IF;
        ELSE  -- do not use defaults case
          minVal := setFCEMin();
        END IF;
        RETURN;
      END IF;

      --
      -- min IS NOT NULL, max IS NOT NULL, default value IS NOT NULL
      --
      IF minVal IS NOT NULL AND NOT(maxVal IS NULL OR maxVal IN(0,-1)) THEN
        RETURN;
      END IF;

      --
      -- min IS NOT NULL, max IS NULL, default value IS NOT NULL
      --
      IF minVal IS NOT NULL AND (maxVal IS NULL OR maxVal IN(0,-1)) THEN

        IF p_use_defaults='Y' THEN
          IF defaultVal >= minVal THEN
            maxVal := defaultVal;
          ELSE
            maxVal := l_max_boundary_val;
          END IF;
        ELSE  -- do not use defaults case
          maxVal := l_max_boundary_val;
        END IF;

        RETURN;
      END IF;

    END IF;


  END setFCEMinMax;

------------------------------------------------------------------------------------------
PROCEDURE EXTR_PS_NODE(inRun_ID    IN PLS_INTEGER,
                       nOrg_ID     IN NUMBER,
                       nTop_ID     IN NUMBER,
                       sExpl_type  IN VARCHAR2,
                       nModelId    IN NUMBER)
IS

   TYPE tIntegerArray             IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
   TYPE tStringArray              IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
   TYPE tNumberArray              IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   TYPE tComponentSequenceId      IS TABLE OF cz_exv_item_master.component_sequence_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tComponentCode            IS TABLE OF cz_exv_item_master.component_code%TYPE INDEX BY BINARY_INTEGER;
   TYPE tCreationDate             IS TABLE OF cz_exv_item_master.creation_date%TYPE INDEX BY BINARY_INTEGER;
   TYPE tCreatedBy                IS TABLE OF cz_exv_item_master.created_by%TYPE INDEX BY BINARY_INTEGER;
   TYPE tLastUpdateDate           IS TABLE OF cz_exv_item_master.last_update_date%TYPE INDEX BY BINARY_INTEGER;
   TYPE tLastUpdatedBy            IS TABLE OF cz_exv_item_master.last_updated_by%TYPE INDEX BY BINARY_INTEGER;
   TYPE tEffectivityDate          IS TABLE OF cz_exv_item_master.effectivity_date%TYPE INDEX BY BINARY_INTEGER;
   TYPE tDisableDate              IS TABLE OF cz_exv_item_master.disable_date%TYPE INDEX BY BINARY_INTEGER;
   TYPE tDescription              IS TABLE OF cz_exv_item_master.description%TYPE INDEX BY BINARY_INTEGER;
   TYPE tLowQuantity              IS TABLE OF cz_exv_item_master.low_quantity%TYPE INDEX BY BINARY_INTEGER;
   TYPE tHighQuantity             IS TABLE OF cz_exv_item_master.high_quantity%TYPE INDEX BY BINARY_INTEGER;
   TYPE tSortOrder                IS TABLE OF cz_exv_item_master.sort_order%TYPE INDEX BY BINARY_INTEGER;
   TYPE tBomItemType              IS TABLE OF cz_exv_item_master.bom_item_type%TYPE INDEX BY BINARY_INTEGER;
   TYPE tComponentItemId          IS TABLE OF cz_exv_item_master.component_item_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tMutuallyExclusiveOptions IS TABLE OF cz_exv_item_master.mutually_exclusive_options%TYPE INDEX BY BINARY_INTEGER;
   TYPE tPickComponentsFlag       IS TABLE OF cz_exv_item_master.pick_components_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tComponentQuantity        IS TABLE OF cz_exv_item_master.component_quantity%TYPE INDEX BY BINARY_INTEGER;
   TYPE tOptional                 IS TABLE OF cz_exv_item_master.optional%TYPE INDEX BY BINARY_INTEGER;
   TYPE tOrganizationId           IS TABLE OF cz_exv_item_master.organization_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tTopItemId                IS TABLE OF cz_exv_item_master.top_item_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tExplosionType            IS TABLE OF cz_exv_item_master.explosion_type%TYPE INDEX BY BINARY_INTEGER;
   TYPE tPlanLevel                IS TABLE OF cz_exv_item_master.plan_level%TYPE INDEX BY BINARY_INTEGER;
   TYPE tIndivisibleFlag          IS TABLE OF cz_exv_item_master.indivisible_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tCustomerOrderEnabledFlag IS TABLE OF cz_exv_item_master.customer_order_enabled_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tPrimaryUomCode           IS TABLE OF cz_exv_item_master.primary_uom_code%TYPE INDEX BY BINARY_INTEGER;
   TYPE tConfigModelType          IS TABLE OF cz_exv_item_master.config_model_type%TYPE INDEX BY BINARY_INTEGER;
   TYPE tModelType                IS TABLE OF cz_exv_item_master.model_type%TYPE INDEX BY BINARY_INTEGER;

   TYPE tPsNodeType               IS TABLE OF cz_imp_ps_nodes.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
   TYPE tOrigSysRef               IS TABLE OF cz_imp_ps_nodes.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
   TYPE tName                     IS TABLE OF cz_imp_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
   TYPE tMinimum                  IS TABLE OF cz_imp_ps_nodes.minimum%TYPE INDEX BY BINARY_INTEGER;
   TYPE tMaximum                  IS TABLE OF cz_imp_ps_nodes.maximum%TYPE INDEX BY BINARY_INTEGER;
   TYPE tTreeSeq                  IS TABLE OF cz_imp_ps_nodes.tree_seq%TYPE INDEX BY BINARY_INTEGER;
   TYPE tBomTreatment             IS TABLE OF cz_imp_ps_nodes.bom_treatment%TYPE INDEX BY BINARY_INTEGER;
   TYPE tUiOmit                   IS TABLE OF cz_imp_ps_nodes.ui_omit%TYPE INDEX BY BINARY_INTEGER;
   TYPE tUiSection                IS TABLE OF cz_imp_ps_nodes.ui_section%TYPE INDEX BY BINARY_INTEGER;
   TYPE tProductFlag              IS TABLE OF cz_imp_ps_nodes.product_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tfskIntlText              IS TABLE OF cz_imp_ps_nodes.fsk_intltext_1_1%TYPE INDEX BY BINARY_INTEGER;
   TYPE tfskItemMaster            IS TABLE OF cz_imp_ps_nodes.fsk_itemmaster_2_1%TYPE INDEX BY BINARY_INTEGER;
   TYPE tfskItemMaster22          IS TABLE OF cz_imp_ps_nodes.fsk_itemmaster_2_2%TYPE INDEX BY BINARY_INTEGER;
   TYPE tfskParentNode            IS TABLE OF cz_imp_ps_nodes.fsk_psnode_3_1%TYPE INDEX BY BINARY_INTEGER;
   TYPE tfskDevlProject           IS TABLE OF cz_imp_ps_nodes.fsk_devlproject_5_1%TYPE INDEX BY BINARY_INTEGER;
   TYPE tEffectiveFrom            IS TABLE OF cz_imp_ps_nodes.effective_from%TYPE INDEX BY BINARY_INTEGER;
   TYPE tEffectiveUntil           IS TABLE OF cz_imp_ps_nodes.effective_until%TYPE INDEX BY BINARY_INTEGER;
   TYPE tRunId                    IS TABLE OF cz_imp_ps_nodes.run_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tSoItemTypeCode           IS TABLE OF cz_imp_ps_nodes.so_item_type_code%TYPE INDEX BY BINARY_INTEGER;
   TYPE tMinimumSelected          IS TABLE OF cz_imp_ps_nodes.minimum_selected%TYPE INDEX BY BINARY_INTEGER;
   TYPE tMaximumSelected          IS TABLE OF cz_imp_ps_nodes.maximum_selected%TYPE INDEX BY BINARY_INTEGER;
   TYPE tBomRequired              IS TABLE OF cz_imp_ps_nodes.bom_required%TYPE INDEX BY BINARY_INTEGER;
   TYPE tInitialValue             IS TABLE OF cz_imp_ps_nodes.initial_value%TYPE INDEX BY BINARY_INTEGER;
   TYPE tfskReference             IS TABLE OF cz_imp_ps_nodes.fsk_psnode_6_1%TYPE INDEX BY BINARY_INTEGER;
   TYPE tDecimalQtyFlag           IS TABLE OF cz_imp_ps_nodes.decimal_qty_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tUserNum                  IS TABLE OF cz_imp_ps_nodes.user_num03%TYPE INDEX BY BINARY_INTEGER;
   TYPE tQuoteableFlag            IS TABLE OF cz_imp_ps_nodes.quoteable_flag%TYPE INDEX BY BINARY_INTEGER;
   TYPE tPsPrimaryUomCode         IS TABLE OF cz_imp_ps_nodes.primary_uom_code%TYPE INDEX BY BINARY_INTEGER;
   TYPE tBomSortOrder             IS TABLE OF cz_imp_ps_nodes.bom_sort_order%TYPE INDEX BY BINARY_INTEGER;
   TYPE tComponentSequencePath    IS TABLE OF cz_imp_ps_nodes.component_sequence_path%TYPE INDEX BY BINARY_INTEGER;
   TYPE tTrackableFlag		      IS TABLE OF cz_imp_ps_nodes.ib_trackable%TYPE INDEX BY BINARY_INTEGER;
   TYPE tInitNumVal               IS TABLE OF cz_imp_ps_nodes.initial_num_value%TYPE INDEX BY BINARY_INTEGER;
   TYPE tSrcApplicationId         IS TABLE OF cz_imp_ps_nodes.src_application_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tIBLinkItemFlag           IS TABLE OF cz_imp_ps_nodes.ib_link_item_flag%TYPE INDEX BY BINARY_INTEGER;

   -- changes for TSO --

   TYPE tShippableItemFlag IS TABLE OF cz_exv_item_master.shippable_item_flag%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE tTransEnabledFlag IS TABLE OF cz_exv_item_master.mtl_transactions_enabled_flag%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE tReplenishToOrderFlag IS TABLE OF cz_exv_item_master.replenish_to_order_flag%TYPE
    INDEX BY BINARY_INTEGER;
   TYPE tSerialNumberControlCode IS TABLE OF cz_exv_item_master.serial_number_control_code%TYPE
    INDEX BY BINARY_INTEGER;

   TYPE tPSShippableItemFlag IS TABLE OF cz_imp_ps_nodes.shippable_item_flag%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE tInventoryTransactableFlag IS TABLE OF cz_imp_ps_nodes.inventory_transactable_flag%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE tAssembleToOrderFlag IS TABLE OF cz_imp_ps_nodes.assemble_to_order_flag%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE tSerializableItemFlag IS TABLE OF cz_imp_ps_nodes.serializable_item_flag%TYPE
     INDEX BY BINARY_INTEGER;

   ShippableItemFlag          tShippableItemFlag;
   TransEnabledFlag           tTransEnabledFlag;
   ReplenishToOrderFlag       tReplenishToOrderFlag;
   SerialNumberControlCode    tSerialNumberControlCode;

   iShippableItemFlag         tPSShippableItemFlag;
   iInventoryTransactableFlag tInventoryTransactableFlag;
   iAssembleToOrder           tAssembleToOrderFlag;
   iSerializableItemFlag      tSerializableItemFlag;

   -- end of changes for TSO --

   n_SortWidth                    NUMBER := cz_imp_ps_node.n_SortWidth;
   x_usesurr_itemmaster           PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_ITEM_MASTERS', 'IMPORT');
   x_usesurr_intltext             PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_LOCALIZED_TEXTS', 'IMPORT');
   x_usesurr_psnode               PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_PS_NODES', 'IMPORT');
   x_usesurr_devlproject          PLS_INTEGER:=CZ_UTILS.GET_PK_USEEXPANSION_FLAG('CZ_DEVL_PROJECTS', 'IMPORT');
   x_error                        BOOLEAN:=FALSE;

   ComponentSequenceId            tComponentSequenceId;
   ComponentCode                  tComponentCode;
   CreationDate                   tCreationDate;
   CreatedBy                      tCreatedBy;
   LastUpdateDate                 tLastUpdateDate;
   LastUpdatedBy                  tLastUpdatedBy;
   EffectivityDate                tEffectivityDate;
   DisableDate                    tDisableDate;
   Description                    tDescription;
   LowQuantity                    tLowQuantity;
   HighQuantity                   tHighQuantity;
   SortOrder                      tSortOrder;
   BomItemType                    tBomItemType;
   ComponentItemId                tComponentItemId;
   MutuallyExclusiveOptions       tMutuallyExclusiveOptions;
   PickComponentsFlag             tPickComponentsFlag;
   ComponentQuantity              tComponentQuantity;
   v_Optional                     tOptional;
   OrganizationId                 tOrganizationId;
   TopItemId                      tTopItemId;
   ExplosionType                  tExplosionType;
   PlanLevel                      tPlanLevel;
   IndivisibleFlag                tIndivisibleFlag;
   CustomerOrderEnabledFlag       tCustomerOrderEnabledFlag;
   PrimaryUomCode                 tPrimaryUomCode;
   ConfigModelType                tConfigModelType;
   ModelType                      tModelType;
   TrackableFlag                  tTrackableFlag;
   SrcApplicationId               tSrcApplicationId;
   FSKItemMaster22                tfskItemMaster22;
   IBLinkItemFlag                 tIBLinkItemFlag;

   iComponentCode                 tComponentCode;
   iPsNodeType                    tPsNodeType;
   iOrigSysRef                    tOrigSysRef;
   iPlanLevel                     tPlanLevel;
   iName                          tName;
   iMinimum                       tMinimum;
   iMaximum                       tMaximum;
   iTreeSeq                       tTreeSeq;
   iBomTreatment                  tBomTreatment;
   iUiOmit                        tUiOmit;
   iUiSection                     tUiSection;
   iProductFlag                   tProductFlag;
   ifskIntlText                   tfskIntlText;
   ifskIntlTextExt                tfskIntlText;
   ifskItemMaster                 tfskItemMaster;
   ifskItemMasterExt              tfskItemMaster;
   ifskItemMaster22               tfskItemMaster22;
   ifskParentNode                 tfskParentNode;
   ifskParentNodeExt              tfskParentNode;
   ifskDevlProject                tfskDevlProject;
   ifskDevlProjectExt             tfskDevlProject;
   ifskReference                  tfskReference;
   iMutuallyExclusive             tMutuallyExclusiveOptions;
   iOptional                      tOptional;
   iCreationDate                  tCreationDate;
   iCreatedBy                     tCreatedBy;
   iLastUpdateDate                tLastUpdateDate;
   iLastUpdatedBy                 tLastUpdatedBy;
   iEffectiveFrom                 tEffectiveFrom;
   iEffectiveUntil                tEffectiveUntil;
   iComponentSequenceId           tComponentSequenceId;
   iRunId                         tRunId;
   iSoItemTypeCode                tSoItemTypeCode;
   iMinimumSelected               tMinimumSelected;
   iMaximumSelected               tMaximumSelected;
   iBomRequired                   tBomRequired;
   iInitialValue                  tInitialValue;
   iOrganizationId                tOrganizationId;
   iTopItemId                     tTopItemId;
   iExplosionType                 tExplosionType;
   iDecimalQtyFlag                tDecimalQtyFlag;
   iQuoteableFlag                 tQuoteableFlag;
   iPrimaryUomCode                tPsPrimaryUomCode;
   iBomSortOrder                  tBomSortOrder;
   iComponentSequencePath         tComponentSequencePath;
   iBTrackableFlag                tTrackableFlag;
   iInitNumVal                    tInitNumVal;
   iSrcApplicationId              tSrcApplicationId;
   iIBLinkItemFlag                tIBLinkItemFlag;

   nIndex                         PLS_INTEGER := 1;
   nStack                         PLS_INTEGER := 1;
   nCount                         PLS_INTEGER;
   genStatisticsCz                PLS_INTEGER;

   l_use_defaults                 VARCHAR2(1);
   l_set_decimals                 VARCHAR2(1);
   l_default_dec                  NUMBER;
   l_default_int                  NUMBER;

   l_imp_decimal_qty_flag         VARCHAR2(1) := UPPER(FND_PROFILE.VALUE('CZ_IMP_DECIMAL_QTY_FLAG'));
   l_max_boundary_value           NUMBER;

   StackPlanLevel                 tPlanLevel;
   StackComponentCode             tComponentCode;
   StackTopItemId                 tTopItemId;
   StackModelType                  tModelType;
   StackProcessFlag               tIntegerArray;
   AllModels                      tStringArray;
   thisOrigSysRef                 cz_imp_ps_nodes.orig_sys_ref%TYPE;

   ComponentSequencePath          cz_imp_ps_nodes.component_sequence_path%TYPE;
   previousPlanLevel              PLS_INTEGER;

   nDebug                         PLS_INTEGER;

   st_time                        number;
   end_time                       number;
   loop_end_time                  number;
   insert_end_time                number;
   d_str                          varchar2(255);
   l_lang                         VARCHAR2(4);

   MemoryBulkSize                 NATURAL;
   startFlag                      BOOLEAN := TRUE;

   v_settings_id                  VARCHAR2(40);
   v_section_name                 VARCHAR2(30);
   --9496782
   v_batchSize                    NUMBER;


   CURSOR c_data (inLang VARCHAR2) IS
     SELECT
       NVL(COMMON_COMPONENT_SEQUENCE_ID, COMPONENT_SEQUENCE_ID), COMPONENT_CODE, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
       LAST_UPDATED_BY, EFFECTIVITY_DATE, DISABLE_DATE, ITEM_DESC, LOW_QUANTITY, HIGH_QUANTITY,
       SORT_ORDER, BOM_ITEM_TYPE, COMPONENT_ITEM_ID, MUTUALLY_EXCLUSIVE_OPTIONS, plan_level,
       PICK_COMPONENTS_FLAG, COMPONENT_QUANTITY, OPTIONAL, organization_id, top_item_id, explosion_type,
       INDIVISIBLE_FLAG, CUSTOMER_ORDER_ENABLED_FLAG, PRIMARY_UOM_CODE, MODEL_TYPE, COMMS_NL_TRACKABLE_FLAG,
       CONFIG_MODEL_TYPE, BOM_APPLICATION_ID, INV_APPLICATION_ID, IB_LINK_ITEM_FLAG,
       DECODE(SHIPPABLE_ITEM_FLAG,'Y','1','N','0','0'),
       DECODE(MTL_TRANSACTIONS_ENABLED_FLAG,'Y','1','N','0','0'),
       DECODE(REPLENISH_TO_ORDER_FLAG,'Y','1','N','0','0'),
       SERIAL_NUMBER_CONTROL_CODE
     FROM cz_exv_item_master
    WHERE organization_id = nOrg_ID
      AND top_item_id = nTop_ID
      AND explosion_type = sExpl_type
      AND language = inLang
    ORDER BY sort_order, component_code;

   parentOrigSysRef               tOrigSysRef;
   childCount                     tNumberArray;

   CURSOR c_parent IS
     SELECT fsk_psnode_3_1, COUNT(*) FROM cz_imp_ps_nodes
      WHERE run_id = inRun_ID
        AND rec_status IS NULL
        AND optional = OraNo
      GROUP BY fsk_psnode_3_1;
---------------------------------------------------------------------------------------------------
FUNCTION ShiftComponentCode(inComponentCode IN VARCHAR2, inPlanLevel IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
 IF(inPlanLevel = 0)THEN
  RETURN inComponentCode;
 ELSE
  RETURN SUBSTR(inComponentCode, INSTR(inComponentCode, '-', 1, inPlanLevel) + 1);
 END IF;
END;
---------------------------------------------------------------------------------------------------
BEGIN

nDebug := 0;

 v_settings_id := 'memorybulksize';
 v_section_name := 'import';

 BEGIN

   SELECT TO_NUMBER(value) INTO MemoryBulkSize
     FROM cz_db_settings
    WHERE LOWER(setting_id) = v_settings_id
      AND LOWER(section_name) = v_section_name;

 EXCEPTION
   WHEN OTHERS THEN
     MemoryBulkSize := 10000000;
 END;

 l_lang := userenv('LANG');
 OPEN c_data(l_lang);

LOOP

 ComponentSequenceId.DELETE;
 ComponentCode.DELETE;
 CreationDate.DELETE;
 CreatedBy.DELETE;
 LastUpdateDate.DELETE;
 LastUpdatedBy.DELETE;
 EffectivityDate.DELETE;
 DisableDate.DELETE;
 Description.DELETE;
 LowQuantity.DELETE;
 HighQuantity.DELETE;
 SortOrder.DELETE;
 BomItemType.DELETE;
 ComponentItemId.DELETE;
 MutuallyExclusiveOptions.DELETE;
 PlanLevel.DELETE;
 PickComponentsFlag.DELETE;
 ComponentQuantity.DELETE;
 v_Optional.DELETE;
 OrganizationId.DELETE;
 TopItemId.DELETE;
 ExplosionType.DELETE;
 IndivisibleFlag.DELETE;
 CustomerOrderEnabledFlag.DELETE;
 PrimaryUomCode.DELETE;
 ConfigModelType.DELETE;
 ModelType.DELETE;
 SrcApplicationId.DELETE;
 FSKItemMaster22.DELETE;
 IBLinkItemFlag.DELETE;

 ShippableItemFlag.DELETE;
 TransEnabledFlag.DELETE;
 ReplenishToOrderFlag.DELETE;
 SerialNumberControlCode.DELETE;

 iName.DELETE;
 iOrigSysRef.DELETE;
 iMinimum.DELETE;
 iMaximum.DELETE;
 iTreeSeq.DELETE;
 iPsNodeType.DELETE;
 iBomTreatment.DELETE;
 iUiOmit.DELETE;
 iUiSection.DELETE;
 iProductFlag.DELETE;
 ifskIntlText.DELETE;
 ifskIntlTextExt.DELETE;
 ifskItemMaster.DELETE;
 ifskItemMasterExt.DELETE;
 ifskItemMaster22.DELETE;
 ifskParentNode.DELETE;
 ifskParentNodeExt.DELETE;
 iMutuallyExclusive.DELETE;
 iOptional.DELETE;
 ifskDevlProject.DELETE;
 ifskDevlProjectExt.DELETE;
 iCreationDate.DELETE;
 iCreatedBy.DELETE;
 iLastUpdateDate.DELETE;
 iLastUpdatedBy.DELETE;
 iEffectiveFrom.DELETE;
 iEffectiveUntil.DELETE;
 iComponentSequenceId.DELETE;
 iComponentCode.DELETE;
 iPlanLevel.DELETE;
 iRunId.DELETE;
 iSoItemTypeCode.DELETE;
 iMinimumSelected.DELETE;
 iBomRequired.DELETE;
 iInitialValue.DELETE;
 iOrganizationId.DELETE;
 iTopItemId.DELETE;
 iExplosionType.DELETE;
 ifskReference.DELETE;
 iMaximumSelected.DELETE;
 iDecimalQtyFlag.DELETE;
 iQuoteableFlag.DELETE;
 iPrimaryUomCode.DELETE;
 iBomSortOrder.DELETE;
 iComponentSequencePath.DELETE;
 iSrcApplicationId.DELETE;
 iIBLinkItemFlag.DELETE;

 iShippableItemFlag.DELETE;
 iInventoryTransactableFlag.DELETE;
 iAssembleToOrder.DELETE;
 iSerializableItemFlag.DELETE;


 nIndex := 1;

 if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
 end if;

 l_lang := userenv('LANG');

 FETCH c_data BULK COLLECT INTO
    ComponentSequenceId, ComponentCode, CreationDate, CreatedBy, LastUpdateDate,
    LastUpdatedBy, EffectivityDate, DisableDate, Description, LowQuantity, HighQuantity,
    SortOrder, BomItemType, ComponentItemId, MutuallyExclusiveOptions, PlanLevel,
    PickComponentsFlag, ComponentQuantity, v_Optional, OrganizationId, TopItemId, ExplosionType,
    IndivisibleFlag, CustomerOrderEnabledFlag, PrimaryUomCode, ModelType, TrackableFlag, ConfigModelType,
    SrcApplicationId, FSKItemMaster22, IBLinkItemFlag,
    ShippableItemFlag, TransEnabledFlag, ReplenishToOrderFlag, SerialNumberControlCode -- changes for TSO
 LIMIT MemoryBulkSize;

 IF(ComponentItemId.COUNT = 0)THEN
   IF(startFlag)THEN
     --'No BOM data to extract. Verify that the bill you want to import exists on the import-enabled server.'
     x_error:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_BOM_NO_DATA'),1,'CZ_IMP_SINGLE.EXTR_PS_NODE',11276,inRun_Id);
     RETURN;
   ELSE
     EXIT;
   END IF;
 END IF;

if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Extract ps structure (' || nTop_Id || ' - count - ' || componentItemId.COUNT || ' ) :' || (end_time-st_time)/100.00;
            x_ERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
 end if;

 if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
 end if;

--dbms_output.put_line('COUNT IS:'||ComponentItemId.COUNT);
 FOR i IN ComponentItemId.FIRST..ComponentItemId.LAST LOOP

  --Need to account for bug #1710684.

  IF(EffectivityDate(i) < cz_utils.EPOCH_BEGIN_)THEN EffectivityDate(i) := cz_utils.EPOCH_BEGIN_; END IF;
  IF(DisableDate(i) > cz_utils.EPOCH_END_)THEN DisableDate(i) := cz_utils.EPOCH_END_; END IF;

  IF(PlanLevel(i) = 0)THEN
    nStack := 1;
    StackComponentCode(nStack) := ComponentCode(i);
    StackTopItemId(nStack) := TopItemId(i);
    StackPlanLevel(nStack) := 0;
    StackProcessFlag(nStack) := 1;
--DBMS_OUTPUT.PUT_LINE('IF plan level ... ModelType: '||ModelType(i));
    StackModelType(nStack) := ModelType(i);
  END IF;

  IF((startFlag AND i = ComponentItemId.FIRST) OR PlanLevel(i) = 0)THEN
    ComponentSequencePath := NULL;
    previousPlanLevel := 0;
  ELSE
    IF(previousPlanLevel < PlanLevel(i))THEN
      IF(ComponentSequencePath IS NOT NULL)THEN ComponentSequencePath := ComponentSequencePath || '-'; END IF;
      ComponentSequencePath := ComponentSequencePath || ComponentSequenceId(i);
    ELSE
      ComponentSequencePath := SUBSTR(ComponentSequencePath, 1, INSTR(ComponentSequencePath, '-', -1, previousPlanLevel - PlanLevel(i) + 1) - 1);
      IF(ComponentSequencePath IS NOT NULL)THEN ComponentSequencePath := ComponentSequencePath || '-'; END IF;
      ComponentSequencePath := ComponentSequencePath || ComponentSequenceId(i);
    END IF;
   previousPlanLevel := PlanLevel(i);
  END IF;

--DBMS_OUTPUT.PUT_LINE('New element: i='||i||', index='||nIndex);
--DBMS_OUTPUT.PUT_LINE('Parameters: BomItemType='||BomItemType(i)||', ComponentCode='||ComponentCode(i));
--DBMS_OUTPUT.PUT_LINE('Stack: nStack='||nStack||', StackComponentCode='||StackComponentCode(nStack)||', StackTopItemId='||StackTopItemId(nStack)||', StackPlanLevel='||StackPlanLevel(nStack)||', StackProcessFlag='||StackProcessFlag(nStack));

   --The dash ('-') added to the end of StackComponentCode is a fix for the bug #1956683. To be on
   --the safe side, we are also changing INSTR(...) = 0 to be INSTR(...) <> 1, but because of the
   --ordering by component_code, both comparisons are equivalent.

   IF(INSTR(ComponentCode(i), StackComponentCode(nStack) || '-') <> 1 OR
      (ComponentCode(i) = StackComponentCode(nStack) AND BomItemType(i) = cnModel))THEN

--DBMS_OUTPUT.PUT_LINE('End of model, stack back');
--DBMS_OUTPUT.PUT_LINE('PlanLevel='||PlanLevel(i));

      FOR j IN PlanLevel(i)..StackPlanLevel(nStack) LOOP
        nStack := nStack - 1;
      END LOOP;
      IF(nStack < 1)THEN nStack := 1; END IF;

--DBMS_OUTPUT.PUT_LINE('New StackPlanLevel='||StackPlanLevel(nStack));

   END IF;
   IF(StackProcessFlag(nStack) = 1)THEN
    IF(BomItemType(i) = cnModel)THEN
      IF(PlanLevel(i) > 0)THEN

--DBMS_OUTPUT.PUT_LINE('Creating reference...');

       iPsNodeType(nIndex) := cnReference;
       iComponentCode(nIndex) := ShiftComponentCode(ComponentCode(i), StackPlanLevel(nStack));
       iComponentSequencePath(nIndex) := ComponentSequencePath;
       iOrigSysRef(nIndex) := CZ_ORAAPPS_INTEGRATE.COMPONENT_SURROGATE_KEY(iComponentCode(nIndex),ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
       iPlanLevel(nIndex) := PlanLevel(i) - StackPlanLevel(nStack);

--DBMS_OUTPUT.PUT_LINE('PlanLevel('||i||')='||PlanLevel(i));
--DBMS_OUTPUT.PUT_LINE('StackPlanLevel('||nStack||')='||StackPlanLevel(nStack));
--DBMS_OUTPUT.PUT_LINE('iPlanLevel('||nIndex||')='||iPlanLevel(nIndex));

       IF(x_usesurr_psnode = 0)THEN
        ifskParentNode(nIndex) :=
         CZ_ORAAPPS_INTEGRATE.COMPONENT_SURROGATE_KEY(SUBSTR(iComponentCode(nIndex),1,INSTR(iComponentCode(nIndex),'-',-1,1)-1),
           ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
        ifskParentNodeExt(nIndex) := NULL;
       ELSE
        ifskParentNode(nIndex) := NULL;
        ifskParentNodeExt(nIndex) :=
         CZ_ORAAPPS_INTEGRATE.COMPONENT_SURROGATE_KEY(SUBSTR(iComponentCode(nIndex),1,INSTR(iComponentCode(nIndex),'-',-1,1)-1),
           ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
       END IF;

       IF(x_usesurr_devlproject = 0)THEN
        ifskDevlProject(nIndex) := CZ_ORAAPPS_INTEGRATE.PROJECT_SURROGATE_KEY(ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
        ifskDevlProjectExt(nIndex) := NULL;
       ELSE
        ifskDevlProject(nIndex) := NULL;
        ifskDevlProjectExt(nIndex) := CZ_ORAAPPS_INTEGRATE.PROJECT_SURROGATE_KEY(ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
       END IF;

       ifskReference(nIndex) := CZ_ORAAPPS_INTEGRATE.COMPONENT_SURROGATE_KEY(TO_CHAR(ComponentItemId(i)),ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(ComponentItemId(i)));
       iOrganizationId(nIndex) := OrganizationId(i);
       iTopItemId(nIndex) := StackTopItemId(nStack);
       iExplosionType(nIndex) := ExplosionType(i);

--DBMS_OUTPUT.PUT_LINE('Reference parameters: ComponentCode='||iComponentCode(nIndex)||', Reference='||ifskReference(nIndex)||', TopItemId='||iTopItemId(nIndex));

       iName(nIndex) := SUBSTR(Description(i), 1, 240);
       iMinimum(nIndex) := 1;
       iMaximum(nIndex) := 1;
       iTreeSeq(nIndex) := TO_NUMBER(SUBSTR(SortOrder(i),LENGTH(SortOrder(i))-n_SortWidth+1,n_SortWidth));
       iBomSortOrder(nIndex) := SortOrder(i);
       iBomTreatment(nIndex) := cnNormal;
       iUiOmit(nIndex) := '0';
       iUiSection(nIndex) := 1;
       iProductFlag(nIndex) := '0';

       iShippableItemFlag(nIndex)         := ShippableItemFlag(i);
       iInventoryTransactableFlag(nIndex) := TransEnabledFlag(i);
       iAssembleToOrder(nIndex)           := ReplenishToOrderFlag(i);

       IF SerialNumberControlCode(i)<>1 THEN
         iSerializableItemFlag(nIndex) := '1';
       ELSE
         iSerializableItemFlag(nIndex) := '0';
       END IF;

-- Performance fix for Stuller: FSK should be orig_sys_ref, not description.
       IF(x_usesurr_intltext = 0)THEN
 --     ifskIntlText(nIndex) := Description(i);
        ifskIntlText(nIndex) := ComponentItemId(i) || ':' || ExplosionType(i) || ':' || OrganizationId(i) || ':'|| ComponentSequenceId(i);
        ifskIntlTextExt(nIndex) := NULL;
       ELSE
        ifskIntlText(nIndex) := NULL;
 --     ifskIntlTextExt(nIndex) := Description(i);
        ifskIntlTextExt(nIndex) := ComponentItemId(i) || ':' || ExplosionType(i) || ':' || OrganizationId(i) || ':'|| ComponentSequenceId(i);
       END IF;

       IF(x_usesurr_itemmaster = 0)THEN
        ifskItemMaster(nIndex) := CZ_ORAAPPS_INTEGRATE.ITEM_SURROGATE_KEY(TO_CHAR(ComponentItemId(i)),TO_CHAR(OrganizationId(i)));
        ifskItemMasterExt(nIndex) := NULL;
       ELSE
        ifskItemMaster(nIndex) := NULL;
        ifskItemMasterExt(nIndex) := CZ_ORAAPPS_INTEGRATE.ITEM_SURROGATE_KEY(TO_CHAR(ComponentItemId(i)),TO_CHAR(OrganizationId(i)));
       END IF;

       iMutuallyExclusive(nIndex) := MutuallyExclusiveOptions(i);
       iOptional(nIndex) := v_Optional(i);
       iCreationDate(nIndex) := CreationDate(i);
       iCreatedBy(nIndex) := CreatedBy(i);
       iLastUpdateDate(nIndex) := LastUpdateDate(i);
       iLastUpdatedBy(nIndex) := LastUpdatedBy(i);
       iEffectiveFrom(nIndex) := EffectivityDate(i);
       iEffectiveUntil(nIndex) := DisableDate(i);
       iComponentSequenceId(nIndex) := ComponentSequenceId(i);
       iRunId(nIndex) := inRun_ID;
       iSoItemTypeCode(nIndex) := NULL;

       --minimum_selected, maximum_selected of the reference inherit the values of minimum, maximum
       --of the child model because it's nominal minimum, maximum will be 0, -1.

       IF(LowQuantity(i) IS NULL)THEN
         IF g_CONFIG_ENGINE_TYPE='F' THEN
           -- this will be converted to default value later
           iMinimumSelected(nIndex) := NULL;
         ELSE
           iMinimumSelected(nIndex) := 0;
         END IF;
       ELSE
         iMinimumSelected(nIndex) := LowQuantity(i);
       END IF;

       IF(HighQuantity(i) IS NULL OR HighQuantity(i) = 0)THEN
         iMaximumSelected(nIndex) := -1;
       ELSE
         iMaximumSelected(nIndex) := HighQuantity(i);
       END IF;

       iPrimaryUomCode(nIndex) := PrimaryUomCode(i);
       iQuoteableFlag(nIndex) := '1';
       IF(CustomerOrderEnabledFlag(i) = 'N')THEN
        IF(BomItemType(i) <> 4)THEN
          iQuoteableFlag(nIndex) := '0';
        END IF;
       END IF;

       IF(UPPER(FND_PROFILE.VALUE('CZ_IMP_DECIMAL_QTY_FLAG')) = 'Y')THEN

         IF(IndivisibleFlag(i) = 'Y')THEN
          iDecimalQtyFlag(nIndex) := '0';
         ELSIF(StackModelType(nStack) = 'A' AND (BomItemType(i) = cnStandard OR (BomItemType(i) = cnOptionClass AND allowDecimalOptionClass = 1)))THEN
           iDecimalQtyFlag(nIndex) := '1';
         ELSE
           iDecimalQtyFlag(nIndex) := '0';
         END IF;
       ELSE
         iDecimalQtyFlag(nIndex) := '0';
       END IF;

       IF(v_Optional(i) = OraNo)THEN
        iBomRequired(nIndex) := '1';
       ELSE
        iBomRequired(nIndex) := '0';
       END IF;

       IF(ComponentQuantity(i) IS NULL OR ComponentQuantity(i) = 0)THEN
        iInitNumVal(nIndex) := 1;
       ELSE
        iInitNumVal(nIndex) := ComponentQuantity(i);
       END IF;

 	 IF(TrackableFlag(i) = 'Y')THEN
  	  iBTrackableFlag(nIndex) := '1';
	 ELSE
  	  iBTrackableFlag(nIndex) := '0';
	 END IF;
       iSrcApplicationId(nIndex) := SrcApplicationId(i);
       ifskItemMaster22(nIndex) := FSKItemMaster22(i);
       iIBLinkItemFlag(nIndex) := IBLinkItemFlag(i);
       nIndex := nIndex + 1;

      END IF;

      IF(i > ComponentItemId.FIRST OR (NOT startFlag))THEN
        nStack := nStack + 1;
        StackComponentCode(nStack) := ComponentCode(i);
        StackTopItemId(nStack) := ComponentItemId(i);
        StackPlanLevel(nStack) := PlanLevel(i);
        StackProcessFlag(nStack) := 1;
--DBMS_OUTPUT.PUT_LINE('IF i> comp ... ModelType: '||ModelType(i));
        StackModelType(nStack) := ModelType(i);

      END IF;
       thisOrigSysRef := CZ_ORAAPPS_INTEGRATE.COMPONENT_SURROGATE_KEY(TO_CHAR(ComponentItemId(i)),ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(ComponentItemId(i)));

      --Check if the model has already been processed in this session

--DBMS_OUTPUT.PUT_LINE('Verifying model...');

      IF(PlanLevel(i) > 0)THEN

--DBMS_OUTPUT.PUT_LINE('Child model - skip...');

        StackProcessFlag(nStack) := 0;
      ELSIF(AllModels.LAST IS NOT NULL)THEN
        FOR j IN AllModels.FIRST..AllModels.LAST LOOP
          IF(AllModels(j) = thisOrigSysRef)THEN
              StackProcessFlag(nStack) := 0;

--DBMS_OUTPUT.PUT_LINE('Model already exists...');

              EXIT;
            END IF;
        END LOOP;
      END IF;

      IF(StackProcessFlag(nStack) = 1)THEN
         AllModels(NVL(AllModels.LAST, 0) + 1) := thisOrigSysRef;
      END IF;
    END IF;

    IF(StackProcessFlag(nStack) = 1)THEN

--DBMS_OUTPUT.PUT_LINE('Processing simple node...');

      IF(BomItemType(i) = cnModel)THEN
        iPsNodeType(nIndex) := bomModel;
      ELSIF(BomItemType(i) = cnOptionClass)THEN
        iPsNodeType(nIndex) := bomOptionClass;
      ELSIF(BomItemType(i) = cnStandard)THEN
        iPsNodeType(nIndex) := bomStandard;
      END IF;
      iComponentCode(nIndex) := ShiftComponentCode(ComponentCode(i), StackPlanLevel(nStack));
      iComponentSequencePath(nIndex) := ComponentSequencePath;
      iOrigSysRef(nIndex) := CZ_ORAAPPS_INTEGRATE.COMPONENT_SURROGATE_KEY(iComponentCode(nIndex),ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
      iPlanLevel(nIndex) := PlanLevel(i) - StackPlanLevel(nStack);

--DBMS_OUTPUT.PUT_LINE('PlanLevel('||i||')='||PlanLevel(i));
--DBMS_OUTPUT.PUT_LINE('StackPlanLevel('||nStack||')='||StackPlanLevel(nStack));
--DBMS_OUTPUT.PUT_LINE('iPlanLevel('||nIndex||')='||iPlanLevel(nIndex));

      IF(x_usesurr_psnode = 0)THEN
       IF(BomItemType(i) = cnModel)THEN
        ifskParentNode(nIndex) := NULL;
       ELSE
        ifskParentNode(nIndex) :=
         CZ_ORAAPPS_INTEGRATE.COMPONENT_SURROGATE_KEY(SUBSTR(iComponentCode(nIndex),1,INSTR(iComponentCode(nIndex),'-',-1,1)-1),
           ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
       END IF;
       ifskParentNodeExt(nIndex) := NULL;
      ELSE
       ifskParentNode(nIndex) := NULL;
       IF(BomItemType(i) = cnModel)THEN
        ifskParentNodeExt(nIndex) := NULL;
       ELSE
        ifskParentNodeExt(nIndex) :=
         CZ_ORAAPPS_INTEGRATE.COMPONENT_SURROGATE_KEY(SUBSTR(iComponentCode(nIndex),1,INSTR(iComponentCode(nIndex),'-',-1,1)-1),
           ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
       END IF;
      END IF;

      IF(x_usesurr_devlproject = 0)THEN
       ifskDevlProject(nIndex) := CZ_ORAAPPS_INTEGRATE.PROJECT_SURROGATE_KEY(ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
       ifskDevlProjectExt(nIndex) := NULL;
      ELSE
       ifskDevlProject(nIndex) := NULL;
       ifskDevlProjectExt(nIndex) := CZ_ORAAPPS_INTEGRATE.PROJECT_SURROGATE_KEY(ExplosionType(i),TO_CHAR(OrganizationId(i)),TO_CHAR(StackTopItemId(nStack)));
      END IF;

      ifskReference(nIndex) := NULL;
      iOrganizationId(nIndex) := OrganizationId(i);
      iTopItemId(nIndex) := StackTopItemId(nStack);
      iExplosionType(nIndex) := ExplosionType(i);

      iName(nIndex) := SUBSTR(Description(i), 1, 240);

      IF(BomItemType(i) = cnModel)THEN

      --This 'child' model is becoming a 'root' model so it's minimum, maximum should be 0, -1
      --The real values have been preserved in the corresponding reference's minimum_, maximum_selected.

          iMinimum(nIndex) := 0;
          iMaximum(nIndex) := -1;
          iTreeSeq(nIndex) := 1;
          iBomSortOrder(nIndex) := LPAD('1', n_SortWidth, '0');
      ELSE
        IF(LowQuantity(i) IS NULL)THEN
          IF g_CONFIG_ENGINE_TYPE='F' THEN
            -- this will be converted to default value later
            iMinimum(nIndex) := NULL;
          ELSE
            iMinimum(nIndex) := 0;
          END IF;
        ELSE
          iMinimum(nIndex) := LowQuantity(i);
        END IF;
        IF(HighQuantity(i) IS NULL OR HighQuantity(i) = 0)THEN
          iMaximum(nIndex) := -1;
        ELSE
          iMaximum(nIndex) := HighQuantity(i);
        END IF;
        iTreeSeq(nIndex) := TO_NUMBER(SUBSTR(SortOrder(i),LENGTH(SortOrder(i))-n_SortWidth+1,n_SortWidth));
        iBomSortOrder(nIndex) := SortOrder(i);
      END IF;

      IF(BomItemType(i) = cnStandard AND v_Optional(i) = OraNo)THEN
       iBomTreatment(nIndex) := cnSkip;
      ELSE
       iBomTreatment(nIndex) := cnNormal;
      END IF;

      iUiOmit(nIndex) := '0';
      iUiSection(nIndex) := 1;

      IF(BomItemType(i) = cnModel)THEN
       iProductFlag(nIndex) := '1';
      ELSE
       iProductFlag(nIndex) := '0';
      END IF;

      iShippableItemFlag(nIndex)         := ShippableItemFlag(i);
      iInventoryTransactableFlag(nIndex) := TransEnabledFlag(i);
      iAssembleToOrder(nIndex)           := ReplenishToOrderFlag(i);

      IF SerialNumberControlCode(i)<>1 THEN
        iSerializableItemFlag(nIndex)    := '1';
      ELSE
        iSerializableItemFlag(nIndex)    := '0';
      END IF;

      IF(x_usesurr_intltext = 0)THEN
--     ifskIntlText(nIndex) := Description(i);
       ifskIntlText(nIndex) := ComponentItemId(i) || ':' || ExplosionType(i) || ':' || OrganizationId(i) || ':'|| ComponentSequenceId(i);
       ifskIntlTextExt(nIndex) := NULL;
      ELSE
       ifskIntlText(nIndex) := NULL;
       ifskIntlTextExt(nIndex) := ComponentItemId(i) || ':' || ExplosionType(i) || ':' || OrganizationId(i) || ':'|| ComponentSequenceId(i);
--     ifskIntlTextExt(nIndex) := Description(i);
      END IF;

      IF(x_usesurr_itemmaster = 0)THEN
       ifskItemMaster(nIndex) := CZ_ORAAPPS_INTEGRATE.ITEM_SURROGATE_KEY(TO_CHAR(ComponentItemId(i)),TO_CHAR(OrganizationId(i)));
       ifskItemMasterExt(nIndex) := NULL;
      ELSE
       ifskItemMaster(nIndex) := NULL;
       ifskItemMasterExt(nIndex) := CZ_ORAAPPS_INTEGRATE.ITEM_SURROGATE_KEY(TO_CHAR(ComponentItemId(i)),TO_CHAR(OrganizationId(i)));
      END IF;

      iMutuallyExclusive(nIndex) := MutuallyExclusiveOptions(i);
      iOptional(nIndex) := v_Optional(i);
      iCreationDate(nIndex) := CreationDate(i);
      iCreatedBy(nIndex) := CreatedBy(i);
      iLastUpdateDate(nIndex) := LastUpdateDate(i);
      iLastUpdatedBy(nIndex) := LastUpdatedBy(i);

      IF(BomItemType(i) = cnModel)THEN
       iEffectiveFrom(nIndex) := CZ_UTILS.EPOCH_BEGIN;
       iEffectiveUntil(nIndex) := CZ_UTILS.EPOCH_END;
       iComponentSequenceId(nIndex) := NULL;
      ELSE
       iEffectiveFrom(nIndex) := EffectivityDate(i);
       iEffectiveUntil(nIndex) := DisableDate(i);
       iComponentSequenceId(nIndex) := ComponentSequenceId(i);
      END IF;

      iRunId(nIndex) := inRun_ID;

      IF(BomItemType(i) = cnModel)THEN
       iSoItemTypeCode(nIndex) := 'MODEL';
      ELSIF(BomItemType(i) = cnModel)THEN
       iSoItemTypeCode(nIndex) := 'CLASS';
      ELSE
       IF(PickComponentsFlag(i) = 'Y')THEN
        iSoItemTypeCode(nIndex) := 'KIT';
       ELSE
        iSoItemTypeCode(nIndex) := 'STANDARD';
       END IF;
      END IF;

      iMinimumSelected(nIndex) := 0;
      iMaximumSelected(nIndex) := NULL;
      iPrimaryUomCode(nIndex) := PrimaryUomCode(i);
      iQuoteableFlag(nIndex) := '1';
      IF(CustomerOrderEnabledFlag(i) = 'N')THEN
       IF(BomItemType(i) <> 4)THEN
         iQuoteableFlag(nIndex) := '0';
       END IF;
      END IF;

      IF(UPPER(FND_PROFILE.VALUE('CZ_IMP_DECIMAL_QTY_FLAG')) = 'Y')THEN

        IF(IndivisibleFlag(i) = 'Y')THEN
         iDecimalQtyFlag(nIndex) := '0';
        ELSIF(StackModelType(nStack) = 'A' AND (BomItemType(i) = cnStandard OR (BomItemType(i) = cnOptionClass AND allowDecimalOptionClass = 1)))THEN
          iDecimalQtyFlag(nIndex) := '1';
        ELSE
          iDecimalQtyFlag(nIndex) := '0';
        END IF;
      ELSE
        iDecimalQtyFlag(nIndex) := '0';
      END IF;

      IF(v_Optional(i) = OraNo)THEN
       iBomRequired(nIndex) := '1';
      ELSE
       iBomRequired(nIndex) := '0';
      END IF;

      IF(ComponentQuantity(i) IS NULL OR ComponentQuantity(i) = 0)THEN
       iInitNumVal(nIndex) := 1;
      ELSE
       iInitNumVal(nIndex) := ComponentQuantity(i);
      END IF;

	IF(TrackableFlag(i) = 'Y')THEN
  	 iBTrackableFlag(nIndex) := '1';
	ELSE
  	 iBTrackableFlag(nIndex) := '0';
	END IF;
      iSrcApplicationId(nIndex) := SrcApplicationId(i);
      ifskItemMaster22(nIndex) := FSKItemMaster22(i);
      iIBLinkItemFlag(nIndex) := IBLinkItemFlag(i);
      nIndex := nIndex + 1;

    END IF;
   END IF;
 END LOOP;

 if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       loop ps structure (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
                x_error:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
 end if;

 if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
 end if;



 --
 -- changes for Solver --
 --
 IF g_CONFIG_ENGINE_TYPE='F' THEN

   l_use_defaults := FND_PROFILE.VALUE('CZ_BOM_DEFAULT_QTY_DOMN');
   l_set_decimals := FND_PROFILE.VALUE('CZ_IMP_DECIMAL_QTY_FLAG');
   l_default_dec  := FND_PROFILE.VALUE('CZ_DEFAULT_MAX_QTY_DEC');
   l_default_int  := FND_PROFILE.VALUE('CZ_DEFAULT_MAX_QTY_INT');

   FOR j IN 1..iOrigSysRef.COUNT
   LOOP
       -- this a special case of root of BOM Model
       IF iSoItemTypeCode(j) = 'MODEL' THEN
         iMINIMUM(j) := 0;
         iMAXIMUM(j) := -1;
         GOTO CONTINUE;
       END IF;
       IF iPsNodeType(j) = 263 THEN -- reference
         setFCEMinMax (minVal              => iMINIMUMSELECTED(j),
                       maxVal              => iMAXIMUMSELECTED(j),
                       defaultVal          => iInitNumVal(j),
                       p_decimal_item_flag => iDecimalQtyFlag(j),
                       p_use_defaults      => l_use_defaults,
                       p_set_decimals      => l_set_decimals,
                       p_default_dec       => l_default_dec,
                       p_default_int       => l_default_int );
       ELSE -- not a reference
         setFCEMinMax (minVal              => iMINIMUM(j),
                       maxVal              => iMAXIMUM(j),
                       defaultVal          => iInitNumVal(j),
                       p_decimal_item_flag => iDecimalQtyFlag(j),
                       p_use_defaults      => l_use_defaults,
                       p_set_decimals      => l_set_decimals,
                       p_default_dec       => l_default_dec,
                       p_default_int       => l_default_int );

       END IF;
       <<CONTINUE>> NULL;
   END LOOP;
 END IF;

 FORALL i IN 1..iOrigSysRef.COUNT
  INSERT INTO cz_imp_ps_nodes
   (NAME, ORIG_SYS_REF, MINIMUM, MAXIMUM, TREE_SEQ, PS_NODE_TYPE, BOM_TREATMENT, UI_OMIT,
    UI_SECTION, PRODUCT_FLAG, FSK_INTLTEXT_1_1, FSK_INTLTEXT_1_EXT, FSK_ITEMMASTER_2_1,
    FSK_ITEMMASTER_2_EXT, FSK_PSNODE_3_1, FSK_PSNODE_3_EXT, MUTUALLY_EXCLUSIVE_OPTIONS, OPTIONAL,
    FSK_DEVLPROJECT_5_1, FSK_DEVLPROJECT_5_EXT, CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
    LAST_UPDATED_BY, EFFECTIVE_FROM, EFFECTIVE_UNTIL, COMPONENT_SEQUENCE_ID, COMPONENT_CODE,
    PLAN_LEVEL, RUN_ID, SO_ITEM_TYPE_CODE, MINIMUM_SELECTED, BOM_REQUIRED, initial_num_value,
    ORGANIZATION_ID, TOP_ITEM_ID, EXPLOSION_TYPE, fsk_psnode_6_1, MAXIMUM_SELECTED,
    DECIMAL_QTY_FLAG, QUOTEABLE_FLAG,PRIMARY_UOM_CODE,BOM_SORT_ORDER,
    COMPONENT_SEQUENCE_PATH,IB_TRACKABLE,SRC_APPLICATION_ID, FSK_ITEMMASTER_2_2, IB_LINK_ITEM_FLAG,
    SHIPPABLE_ITEM_FLAG,INVENTORY_TRANSACTABLE_FLAG, ASSEMBLE_TO_ORDER_FLAG,SERIALIZABLE_ITEM_FLAG)  -- changes for TSO
  VALUES
   (iName(i), iOrigSysRef(i), iMinimum(i), iMaximum(i), iTreeSeq(i), iPsNodeType(i), iBomTreatment(i),
    iUiOmit(i), iUiSection(i), iProductFlag(i), ifskIntlText(i), ifskIntlTextExt(i), ifskItemMaster(i),
    ifskItemMasterExt(i), ifskParentNode(i), ifskParentNodeExt(i), iMutuallyExclusive(i), iOptional(i),
    ifskDevlProject(i), ifskDevlProjectExt(i), iCreationDate(i), iCreatedBy(i), iLastUpdateDate(i),
    iLastUpdatedBy(i), iEffectiveFrom(i), iEffectiveUntil(i), iComponentSequenceId(i),
    iComponentCode(i), iPlanLevel(i), iRunId(i), iSoItemTypeCode(i), iMinimumSelected(i),
    iBomRequired(i), iInitNumVal(i), iOrganizationId(i), iTopItemId(i), iExplosionType(i),
    ifskReference(i), iMaximumSelected(i), iDecimalQtyFlag(i),
    iQuoteableFlag(i),iPrimaryUomCode(i),iBomSortOrder(i), iComponentSequencePath(i),iBTrackableFlag(i),
    iSrcApplicationId(i), ifskItemMaster22(i), iIBLinkItemFlag(i),
    iShippableItemFlag(i), iInventoryTransactableFlag(i), iAssembleToOrder(i), iSerializableItemFlag(i)); -- changes for TSO

 if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Insert ps nodes (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            x_error:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
 end if;

  -- 9496782
 czGatherStatsCnt := czGatherStatsCnt + iOrigSysRef.COUNT ;

 COMMIT;
 startFlag := FALSE;
END LOOP; -- FETCH c_data BULK COLLECT
CLOSE c_data;

--Depending on db setting, generate the statistics here for the tables used in the queries bellow.

 v_settings_id := 'GENSTATISTICSCZ';
 v_section_name := 'IMPORT';

BEGIN
  SELECT decode(upper(VALUE),'TRUE','1','FALSE','0','T','1','F','0','1','1','0','0','YES','1','NO','0','Y','1','N','0','0')
    INTO genStatisticsCz FROM CZ_DB_SETTINGS
   WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
EXCEPTION
  WHEN OTHERS THEN
    genStatisticsCz := 0;
END;

IF(genStatisticsCz = 1)THEN
  --bug 9496782 make this call conditionalize which is really helpful when there are lot of references
  -- and gather stats will run after every 10000+ (batchsize setting) nodes range

  --9496782 Get BatchSize

    v_settings_id := 'BATCHSIZE';
    v_section_name := 'SCHEMA';

    BEGIN
       SELECT VALUE
       INTO v_batchSize FROM CZ_DB_SETTINGS
       WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
    EXCEPTION
       WHEN OTHERS THEN
          v_batchSize := 5000;
    END;

    -- Due to bug 6749205, inPlanLevel is still not available in this
    -- version so changing original IF condition . Once that is fixed
    -- uncomment following line to replace existing IF condition with new one.
    --IF (czGatherStatsCnt > v_batchSize OR inPlanLevel = 0) THEN
    IF (czGatherStatsCnt > v_batchSize) THEN
      czGatherStatsCnt := 0;
      x_error:=cz_utils.log_report('Gather Stats : Start' ,1,'EXTRACTION',11299,inRun_Id);
      fnd_stats.gather_table_stats('CZ', 'CZ_IMP_PS_NODES');
      --bug 9496782 comment out following call
      -- fnd_stats.gather_table_stats('CZ', 'CZ_PS_NODES');
      fnd_stats.gather_table_stats('CZ', 'CZ_XFR_PROJECT_BILLS');
      x_error:=cz_utils.log_report('Gather Stats : End',1,'EXTRACTION',11299,inRun_Id);

      if (CZ_IMP_ALL.get_time) then
          end_time := dbms_utility.get_time();
          d_str := inRun_Id || '       Gather Stats :' || (end_time-st_time)/100.00;
          x_error:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
      end if;
    END IF;
END IF;

--AT: The calculation of maximum_selected is moved here as we do reading into memory in batches and cannot
--calculate this inside the cycle which is possibly incomplete.

BEGIN

  --Bug #2737004. The cursor doesn't return records for option classes with only optional children.
  --As a result, such option classes are missing from the update.

  UPDATE cz_imp_ps_nodes SET maximum_selected = 1
   WHERE run_id = inRun_ID
     AND rec_status IS NULL
     AND mutually_exclusive_options = OraYes
     AND ps_node_type = bomOptionClass;

  COMMIT;

  OPEN c_parent;
  LOOP

    parentOrigSysRef.DELETE;
    childCount.DELETE;

    FETCH c_parent BULK COLLECT INTO parentOrigSysRef, childCount LIMIT MemoryBulkSize;
    EXIT WHEN childCount.COUNT = 0;

    FORALL i IN 1..childCount.COUNT
      UPDATE cz_imp_ps_nodes SET maximum_selected = childCount(i) + 1
       WHERE run_id = inRun_ID
         AND rec_status IS NULL
         AND mutually_exclusive_options = OraYes
         AND orig_sys_ref = parentOrigSysRef(i);

    COMMIT;
  END LOOP;
  CLOSE c_parent;

EXCEPTION
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
  WHEN OTHERS THEN
    IF(c_parent%ISOPEN)THEN CLOSE c_parent; END IF;
    d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    x_error:=cz_utils.log_report(d_str,1,'CZ_IMP_SINGLE.maximum_selected',11276,inRun_Id);
    RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;

------------------------------------------------------------------------------
---Check the online PS_NODE table for obsolete ps_nodes, i.e. ps_nodes        -
---which are not present in the current import data under the current project,-
---and so their corresponding BOMs were likely deleted in Oracle Applications.-
---For such ps_nodes DELETED_FLAG field should be set to '1'.                 -
---BOM_EXPLOSIONS is supposed to be correct, and so no verification is done   -
---for parent-child relationships after some of the ps_nodes are marked as    -
---deleted.                                                                   -
-------------------------------------------------------------------------------

   DECLARE
     CURSOR c_onl_ps_node IS
      SELECT B.ORIG_SYS_REF, B.COMPONENT_SEQUENCE_PATH, B.ps_node_id, B.ps_node_type
      FROM CZ_XFR_PROJECT_BILLS P,CZ_PS_NODES B
      WHERE B.DEVL_PROJECT_ID=P.model_ps_node_id
        AND P.organization_id = nORg_ID
        AND P.top_item_id = nTop_ID
        AND P.explosion_type = sExpl_type
        AND P.DELETED_FLAG='0'
        AND B.DELETED_FLAG='0'
        AND B.ORIG_SYS_REF IS NOT NULL
        AND B.PS_NODE_TYPE <> 259
        AND B.devl_project_id = nModelId
      FOR UPDATE OF B.DELETED_FLAG;

     x_onl_ps_node_f        BOOLEAN:=FALSE;
     x_imp_ps_node_f        BOOLEAN:=FALSE;
     sOnlOrigSysRef         CZ_PS_NODES.ORIG_SYS_REF%TYPE;
     v_PsNodeId             CZ_PS_NODES.PS_NODE_ID%TYPE;
     v_PsNodeType           CZ_PS_NODES.PS_NODE_TYPE%TYPE;
     v_SequencePath         CZ_PS_NODES.COMPONENT_SEQUENCE_PATH%TYPE;
     cDefaultChar           CHAR(1);
     p_out_err              INTEGER;

   BEGIN

     if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
     end if;

     OPEN c_onl_ps_node;

     LOOP

      sOnlOrigSysRef:=NULL;
      FETCH c_onl_ps_node INTO sOnlOrigSysRef, v_SequencePath, v_PsNodeId, v_PsNodeType;
      x_onl_ps_node_f:=c_onl_ps_node%FOUND;
      EXIT WHEN NOT x_onl_ps_node_f;

      DECLARE
        CURSOR c_imp_ps_node IS
         SELECT 'F' FROM CZ_IMP_PS_NODES
         WHERE ORIG_SYS_REF=sOnlOrigSysRef AND RUN_ID=inRun_ID
           AND NVL(COMPONENT_SEQUENCE_PATH, -1) = NVL(v_SequencePath, -1)
           AND REC_STATUS IS NULL;
      BEGIN
        OPEN c_imp_ps_node;
        FETCH c_imp_ps_node INTO cDefaultChar;
        x_imp_ps_node_f:=c_imp_ps_node%FOUND;
        CLOSE c_imp_ps_node;
      END;

      IF(NOT x_imp_ps_node_f) THEN
          UPDATE CZ_PS_NODES SET
          DELETED_FLAG='1'
          WHERE CURRENT OF c_onl_ps_node;

          --Here to call cz_refs api
          IF(v_PsNodeType IN (bomModel, cnReference))THEN
            cz_refs.delete_Node(v_PsNodeId, v_PsNodeType, p_out_err, '1');
               IF (p_out_err > 0) THEN
                 BEGIN
                   SELECT message INTO d_str FROM cz_db_logs WHERE run_id = p_out_err;
                 EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                     d_str := NULL;
                 END;
                 RAISE CZ_REFS_DELNODE_EXCP;
               END IF;
          END IF;

      END IF;

     END LOOP;

     if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '        Deleted ps node check (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
                x_error:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
     end if;

     CLOSE c_onl_ps_node;
     COMMIT;

     EXCEPTION
      WHEN CZ_REFS_DELNODE_EXCP THEN
        IF d_str IS NULL THEN d_str := 'NO MESSAGE FOUND'; END IF;
        d_str := CZ_UTILS.GET_TEXT('CZ_IMP_CZREFS_DELNODE', 'MSG', d_str);
        x_error :=cz_utils.log_report(d_str,1,'CZ_IMP_SINGLE.EXTR_PS_NODE: delete obsolete nodes',11276,inRun_Id);
        ROLLBACK;
        RAISE;
      WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
        ROLLBACK;
        RAISE;
      WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
        RAISE;
      WHEN OTHERS THEN
        d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
        x_error:=cz_utils.log_report(d_str,1,'CZ_IMP_SINGLE.EXTR_PS_NODE: delete obsolete nodes',11276,inRun_Id);
        ROLLBACK;
        RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
    END;

EXCEPTION
 WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
 WHEN OTHERS THEN
  IF(c_data%ISOPEN)THEN CLOSE c_data; END IF;
  d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
  x_error:=cz_utils.log_report(d_str,1,'CZ_IMP_SINGLE.EXTR_PS_NODE',11276,inRun_Id);
  RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------
PROCEDURE EXTR_INTL_TEXT(inRun_ID    IN PLS_INTEGER,
                         nOrg_ID     IN NUMBER,
                         nTop_ID     IN NUMBER,
                         sExpl_type  IN VARCHAR2,
                         nModelId    IN NUMBER)
IS
   xERROR       BOOLEAN:=FALSE;

   TYPE tCompSeqId             IS TABLE OF cz_exv_intl_text.component_sequence_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tOrgId                 IS TABLE OF cz_exv_intl_text.organization_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tCompItemId            IS TABLE OF cz_exv_intl_text.component_item_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tCompCode              IS TABLE OF cz_exv_intl_text.component_code%TYPE INDEX BY BINARY_INTEGER;

   TYPE tOrigSysRef            IS TABLE OF cz_imp_localized_texts.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
   TYPE tLocalizedStr          IS TABLE OF cz_imp_localized_texts.localized_str%TYPE INDEX BY BINARY_INTEGER;
   TYPE tLanguage              IS TABLE OF cz_imp_localized_texts.language%TYPE INDEX BY BINARY_INTEGER;
   TYPE tSrcLang               IS TABLE OF cz_imp_localized_texts.source_lang%TYPE INDEX BY BINARY_INTEGER;
   TYPE tFSKDevlProject        IS TABLE OF cz_imp_localized_texts.fsk_devlproject_1_1%TYPE INDEX BY BINARY_INTEGER;

   TYPE tTextStr               IS TABLE OF cz_imp_intl_text.text_str%TYPE INDEX BY BINARY_INTEGER;

   CompSeqId             tCompSeqId;
   OrgId		       tOrgId;
   CompCode              tCompCode;
   CompItemId            tCompItemId;

   iOrigSysRef           tOrigSysRef;
   iLocalizedStr         tLocalizedStr;
   iLanguage		 	 tLanguage;
   iSrcLang		 		 tSrcLang;
 --  iFSKDevlProject       tFSKDevlProject;
   iFSKDevlProject       cz_imp_localized_texts.fsk_devlproject_1_1%TYPE;
   nTopBillSequenceId    BOM_EXPLOSIONS.top_bill_sequence_id%type;

   st_time               number;
   end_time              number;
   loop_end_time         number;
   insert_end_time       number;
   d_str                 varchar2(255);

   MemoryBulkSize        NATURAL;

   CURSOR c_data IS
     SELECT DISTINCT component_item_id,
     NVL(common_component_sequence_id, component_sequence_id) AS component_sequence_id,
     component_code,
     description, language, source_lang
     FROM cz_exv_intl_text
     WHERE organization_id = nOrg_ID
     AND top_item_id = nTop_ID
     AND explosion_type = sExpl_type;

  l_comp_code  bom_explosions.component_code%TYPE;
  x_model_found BOOLEAN := FALSE;
  l_next_model_id NUMBER;
  l_parent_model_id NUMBER;
  l_next_item_id NUMBER;

   v_settings_id                  VARCHAR2(40);
   v_section_name                 VARCHAR2(30);

BEGIN

 v_settings_id := 'memorybulksize';
 v_section_name := 'import';

 BEGIN

   SELECT TO_NUMBER(value) INTO MemoryBulkSize
     FROM cz_db_settings
    WHERE LOWER(setting_id) = v_settings_id
      AND LOWER(section_name) = v_section_name;

 EXCEPTION
   WHEN OTHERS THEN
     MemoryBulkSize := 10000000;
 END;

  OPEN c_data;
  LOOP
     iOrigSysRef.DELETE;
     iLocalizedStr.DELETE;
     iLanguage.DELETE;
     iSrcLang.DELETE;

     CompSeqId.DELETE;
     CompItemId.DELETE;
     CompCode.DELETE;

     FETCH c_data
     BULK COLLECT
       INTO CompItemId, CompSeqId, CompCode, iLocalizedStr, iLanguage, iSrcLang
        LIMIT MemoryBulkSize;
     EXIT WHEN c_data%NOTFOUND AND CompItemId.COUNT = 0;

     IF (CompItemId.COUNT > 0) THEN

          FOR i IN 1..CompItemId.COUNT LOOP

             l_comp_code := CompCode(i);
             x_model_found := FALSE;

             -- need to find the containing parent model, use the component_code
             IF (instr(l_comp_code,'-') > 0) THEN

                 WHILE (instr(l_comp_code,'-') > 0 ) AND (x_model_found = FALSE)  LOOP
                      -- get the next item in the component_code
                      l_next_item_id := substr(l_comp_code, instr(l_comp_code,'-',-1) + 1 );

                      -- if no imported models in models cache then return
                      IF (gModelItemId_tbl.COUNT = 0) THEN
                          RETURN;
                      END IF;

                      -- find the item in the list of models in the global array
                      FOR j IN gModelItemId_tbl.FIRST..gModelItemId_tbl.LAST LOOP

                           --
                           -- skip the model item itself, we need its parent
                           -- because this text belongs to the reference node
                           -- so the parent model must be found
                           --
                           IF (to_number(l_next_item_id) = gModelItemId_tbl(j)
                               AND gModelItemId_tbl(j) <> CompItemId(i) ) THEN

                                -- found the containing model: the parent model
                                l_parent_model_id := gModelItemId_tbl(j);
                                x_model_found := TRUE;
                                EXIT;

                           END IF ;

                      END LOOP;

                      -- get the rest of the component_code and repreat
                      l_comp_code := substr(l_comp_code, 1, instr(l_comp_code,'-',-1)-1);

                 END LOOP;

                 IF (x_model_found = FALSE) THEN
                    l_parent_model_id := nTop_ID; -- the parent is the left-most item, the top item
                 END IF;
             ElSE
                   l_parent_model_id := nTop_ID; -- the item belongs to the top model
             END IF;

             iFSKDevlProject := CZ_ORAAPPS_INTEGRATE.PROJECT_SURROGATE_KEY(sExpl_type,to_char(nOrg_ID),to_char(l_parent_model_id));

             INSERT INTO CZ_IMP_LOCALIZED_TEXTS
               (LOCALIZED_STR, LANGUAGE, SOURCE_LANG, RUN_ID, ORIG_SYS_REF, FSK_DEVLPROJECT_1_1)
             VALUES (iLocalizedStr(i), iLanguage(i), iSrcLang(i), inRun_ID,
                     CompItemId(i)||':'||sExpl_type||':'||nOrg_ID||':'||CompSeqId(i), iFSKDevlProject);
          END LOOP;
          COMMIT;
     END IF;

  END LOOP;
  CLOSE c_data;

    --
   -- Insert a text for each child model root node in this top model
   IF (gModelItemId_tbl.COUNT > 0) THEN
      FOR j IN gModelItemId_tbl.FIRST..gModelItemId_tbl.LAST LOOP

       IF ( gModelItemId_tbl(j) <> nTop_ID) THEN

          INSERT INTO CZ_IMP_LOCALIZED_TEXTS
             (LOCALIZED_STR, LANGUAGE, SOURCE_LANG, RUN_ID, ORIG_SYS_REF, FSK_DEVLPROJECT_1_1)
          SELECT description, language, source_lang, inRun_ID,
                 gModelItemId_tbl(j)||':'||sExpl_type||':'||nOrg_ID||':'||
                 NVL(common_component_sequence_id, component_sequence_id),
                 CZ_ORAAPPS_INTEGRATE.PROJECT_SURROGATE_KEY(sExpl_type,to_char(nOrg_ID),to_char(gModelItemId_tbl(j)))
            FROM cz_exv_intl_text
           WHERE organization_id = nOrg_ID
             AND top_item_id = gModelItemId_tbl(j)
             AND explosion_type = sExpl_type
             AND component_item_id = top_item_id;
        END IF;

      END LOOP;
   END IF;

 if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Extract text (' || nTop_Id || ' - Count - ' || iLocalizedStr.COUNT || ') :' || (end_time-st_time)/100.00;
                xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
 end if;

 COMMIT;
EXCEPTION
 WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
 WHEN OTHERS THEN
   IF(c_data%ISOPEN)THEN CLOSE c_data; END IF;
   d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
   xERROR:=cz_utils.log_report(d_str,1,'CZ_IMP_SINGLE.EXTR_INTL_TEXT',11276,inRun_Id);
   RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------
PROCEDURE EXTR_DEVL_PROJECT(inRun_ID    IN PLS_INTEGER,
                            nOrg_ID     IN NUMBER,
                            nTop_ID     IN NUMBER,
                            sExpl_type  IN VARCHAR2,
                            nModelId    IN NUMBER)
IS
   xERROR          BOOLEAN:=FALSE;

   TYPE tDescription              IS TABLE OF cz_exv_item_master.description%TYPE INDEX BY BINARY_INTEGER;
   TYPE tComponentItemId          IS TABLE OF cz_exv_item_master.component_item_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tOrganizationId           IS TABLE OF cz_exv_item_master.organization_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tExplosionType            IS TABLE OF cz_exv_item_master.explosion_type%TYPE INDEX BY BINARY_INTEGER;
   TYPE tPlanLevel                IS TABLE OF cz_exv_item_master.plan_level%TYPE INDEX BY BINARY_INTEGER;
   TYPE tModelType                IS TABLE OF cz_exv_item_master.model_type%TYPE INDEX BY BINARY_INTEGER;

   TYPE tOrigSysRef               IS TABLE OF cz_imp_devl_project.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
   TYPE tName                     IS TABLE OF cz_imp_devl_project.name%TYPE INDEX BY BINARY_INTEGER;
   TYPE tDescText                 IS TABLE OF cz_imp_devl_project.desc_text%TYPE INDEX BY BINARY_INTEGER;
   TYPE tTopItemId                IS TABLE OF cz_imp_devl_project.top_item_id%TYPE INDEX BY BINARY_INTEGER;
   TYPE tProductKey               IS TABLE OF cz_imp_devl_project.product_key%TYPE INDEX BY BINARY_INTEGER;

   Description                    tDescription;
   OrganizationId                 tOrganizationId;
   ComponentItemId                tComponentItemId;
   ExplosionType                  tExplosionType;
   PlanLevel                      tPlanLevel;
   ModelType			    tModelType;
   ConfigModelType                tModelType;

   iOrigSysRef                    tOrigSysRef;
   iPlanLevel                     tPlanLevel;
   iName                          tName;
   iDescText                      tDescText;
   iTopItemId                     tTopItemId;
   iModelType			    tModelType;
   iConfigModelType               tModelType;
   iOrganizationId                tOrganizationId;
   iInventoryItemId               tComponentItemId;
   iProductKey                    tProductKey;

   nIndex                         PLS_INTEGER := 1;

   st_time               number;
   end_time              number;
   loop_end_time             number;
   insert_end_time       number;
   d_str                       varchar2(255);
   l_lang               VARCHAR2(4);

BEGIN
gModelItemId_tbl.delete;
 if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
 end if;

  l_lang := userenv('LANG');

SELECT
   ORGANIZATION_ID, COMPONENT_ITEM_ID, EXPLOSION_TYPE,
   DESCRIPTION, PLAN_LEVEL, MODEL_TYPE, CONFIG_MODEL_TYPE
BULK COLLECT INTO
   OrganizationId, ComponentItemId, ExplosionType, Description, PlanLevel, ModelType, ConfigModelType
 FROM CZ_EXV_ITEM_MASTER WHERE bom_item_type = cz_imp_ps_node.cnModel
  AND ORGANIZATION_ID=nOrg_ID
  AND TOP_ITEM_ID=nTop_ID AND EXPLOSION_TYPE=sExpl_type
  AND language = l_lang;

if (CZ_IMP_ALL.get_time) then
    end_time := dbms_utility.get_time();
    d_str := inRun_Id || '       Extract projects (' || nTop_Id || ' - Count - ' || OrganizationId.COUNT || ') :' || (end_time-st_time)/100.00;
            xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
 end if;

  FOR i IN 1..OrganizationId.COUNT LOOP

      iOrigSysRef(nIndex) := CZ_ORAAPPS_INTEGRATE.PROJECT_SURROGATE_KEY(ExplosionType(i),to_char(OrganizationId(i)),to_char(ComponentItemId(i)));
      iName(nIndex) := Description(i) || '(' || to_char(OrganizationId(i)) || ' ' || to_char(ComponentItemId(i)) || ')';
      iDescText(nIndex) := SUBSTR(Description(i), 1, 255);
      iPlanLevel(nIndex) := PlanLevel(i);
      iTopItemId(nIndex) := ComponentItemId(i);
      gModelItemId_tbl(nIndex) := ComponentItemId(i); -- store for access by extr_intl_text procedure
      iOrganizationId(nIndex) := OrganizationId(i);
      iInventoryItemId(nIndex) := ComponentItemId(i);
      iProductKey(nIndex) := OrganizationId(i)||':'||ComponentItemId(i);

      IF(ConfigModelType(i) = 'N')THEN

        iModelType(nIndex) := 'N';
      ELSE

        iModelType(nIndex) := ModelType(i);
      END IF;

      nIndex := nIndex + 1;
  END LOOP;

if (CZ_IMP_ALL.get_time) then
        loop_end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Loop Projects (' || nTop_Id || ') :' || (loop_end_time-end_time)/100.00;
                xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
 end if;

  FORALL i IN 1..iOrigSysRef.COUNT
    INSERT INTO CZ_IMP_DEVL_PROJECT
      (ORGANIZATION_ID, TOP_ITEM_ID, EXPLOSION_TYPE, ORIG_SYS_REF, VERSION,
       RUN_ID, NAME, FSK_INTLTEXT_1_1, DESC_TEXT, PLAN_LEVEL, MODEL_ID, MODEL_TYPE,
       INVENTORY_ITEM_ID, PRODUCT_KEY, BOM_CAPTION_RULE_ID, NONBOM_CAPTION_RULE_ID, CONFIG_ENGINE_TYPE)
    VALUES
      (nOrg_ID, iTopItemId(i), sExpl_type, iOrigSysRef(i), 1,
       inRun_ID, iName(i), iDescText(i), iDescText(i), iPlanLevel(i), nModelId, iModelType(i),
       iInventoryItemId(i), iProductKey(i), G_CAPTION_RULE_DESC, G_CAPTION_RULE_NAME, g_CONFIG_ENGINE_TYPE);

if (CZ_IMP_ALL.get_time) then
        insert_end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Insert projects (' || nTop_Id || ') :' || (insert_end_time-loop_end_time)/100.00;
            xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
 end if;

 COMMIT;

EXCEPTION
 WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
 WHEN OTHERS THEN
   d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
   xERROR:=cz_utils.log_report(d_str,1,'EXTR_DEVL_PROJECT',11276,inRun_Id);
   RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------
PROCEDURE EXTR_ITEM_TYPES(inRun_ID    IN PLS_INTEGER,
                          nOrg_ID     IN NUMBER,
                          nTop_ID     IN NUMBER,
                          sExpl_type  IN VARCHAR2)
IS
   xERROR          BOOLEAN:=FALSE;

   st_time               number;
   end_time              number;
   loop_end_time             number;
   insert_end_time       number;
   d_str                       varchar2(255);
   l_use_segments        BOOLEAN:=FALSE;
   l_name_method         VARCHAR2(255);

BEGIN
  if (CZ_IMP_ALL.get_time) then
    st_time := dbms_utility.get_time();
  end if;

  fnd_profile.get('CZ_SEGS_FOR_ITEMTYPE_NAME', l_name_method);

  IF (l_name_method = 'CZ_CAT_DESC') THEN
      l_use_segments := FALSE;
  ELSIF (l_name_method = 'CZ_CAT_CONCAT_SEGS') THEN
      l_use_segments := TRUE;
  END IF;

  IF (l_use_segments = TRUE) THEN
     FORALL i IN 1..itemCatalogGroupId.COUNT
       INSERT INTO CZ_IMP_ITEM_TYPE
         (DESC_TEXT, NAME, ORIG_SYS_REF,SRC_APPLICATION_ID,RUN_ID)
       SELECT DESCRIPTION, CATALOG_CONCAT_SEGS, ITEM_CATALOG_GROUP_ID, G_BOM_APPLICATION_ID, inRUN_ID
         FROM CZ_EXV_ITEM_TYPES
        WHERE ITEM_CATALOG_GROUP_ID = itemCatalogGroupId(i);
  ELSE
     FORALL i IN 1..itemCatalogGroupId.COUNT
       INSERT INTO CZ_IMP_ITEM_TYPE
         (DESC_TEXT, NAME, ORIG_SYS_REF, SRC_APPLICATION_ID, RUN_ID)
       SELECT DESCRIPTION, DESCRIPTION, ITEM_CATALOG_GROUP_ID, G_BOM_APPLICATION_ID, inRUN_ID
         FROM CZ_EXV_ITEM_TYPES
        WHERE ITEM_CATALOG_GROUP_ID = itemCatalogGroupId(i);
  END IF;

  if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Insert item type (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
  end if;
 COMMIT;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   NULL;
 WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
 WHEN OTHERS THEN
   d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
   xERROR:=cz_utils.log_report(d_str,1,'EXTR_ITEM_TYPES',11276,inRun_Id);
   RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------

  FUNCTION get_Col_Num(p_col_name IN VARCHAR2,p_col_tbl IN OUT NOCOPY rec_cols_tbl) RETURN NUMBER IS
  BEGIN
    IF p_col_tbl.EXISTS(p_col_name) THEN
      RETURN p_col_tbl(p_col_name).col_num;
    END IF;
    RETURN -1;
  END get_Col_Num;

  FUNCTION get_ItemCatalogTable RETURN SYSTEM.CZ_ITEM_CATALOG_TBL IS
  BEGIN
    RETURN g_ItemCatalogTable;
  END get_ItemCatalogTable;

  PROCEDURE EXTR_APC_PROPERTIES(p_run_id      IN NUMBER,
                                p_org_id      IN NUMBER,
                                p_top_item_id IN NUMBER,
                                p_expl_type   IN VARCHAR2) IS

    xERROR              BOOLEAN:=FALSE;
    st_time             NUMBER;
    end_time            NUMBER;
    loop_end_time       NUMBER;
    insert_end_time     NUMBER;
    d_str               VARCHAR2(255);

    l_prev_item_catalog_tbl SYSTEM.CZ_ITEM_CATALOG_TBL := SYSTEM.CZ_ITEM_CATALOG_TBL(SYSTEM.CZ_ITEM_CATALOG_REC(NULL));

    l_cursor                  NUMBER;
    l_exec                    NUMBER;
    l_error                   BOOLEAN;

    l_col_tbl                 rec_cols_tbl;
    l_rec_tab                 DBMS_SQL.desc_tab;
    l_att_names_tbl           varchar_tbl_type;
    l_db_columns_tbl          varchar_tbl_type;
    l_num_value_tbl           number_tbl_type;

    l_str_value               VARCHAR2(1000);
    l_num_value               NUMBER;

    l_column_num              NUMBER;
    l_rec_counter             NUMBER;
    l_inventory_item_id       NUMBER;
    l_org_id                  NUMBER;
    l_col_num                 NUMBER;
    l_current_attr_group_id   NUMBER;
    l_col_cnt                 NUMBER;
    l_col_length              NUMBER;
    l_attr_group_id           NUMBER;
    l_current_inv_item_id     NUMBER;
    l_attr_group_col_num      NUMBER;
    l_inv_item_col_num        NUMBER;
    l_org_id_col_num          NUMBER;
    l_lang_col_num            NUMBER;
    l_source_lang_col_num     NUMBER;
    l_language                VARCHAR2(255);
    l_col_name                VARCHAR2(255);
    l_source_lang             VARCHAR2(255);
    l_column_value            VARCHAR2(1000);
    l_item_catalog_path       VARCHAR2(4000);

    l_attr_group_id_tbl          number_tbl_type;
    l_temp_map                   number_tbl_type;
    l_attr_group_name_tbl        varchar_tbl_type;
    l_attr_group_type_tbl        varchar_tbl_type;
    l_attr_id_tbl                number_tbl_type;
    l_attr_name_tbl              varchar_tbl_type;
    l_property_type_tbl          number_tbl_type;
    l_database_column_tbl        varchar_tbl_type;
    l_db_column_types_tbl        number_tbl_type;
    l_description_tbl            varchar_tbl_type;
    l_data_type_code_tbl         varchar_tbl_type;
    l_item_catalog_group_id_tbl  number_tbl_type;
    l_def_value_tbl              long_varchar_tbl_type;
    l_item_catalog_group_map_tbl number_tbl_type;
    l_sql                        VARCHAR2(32000);
    l_api_name                   VARCHAR2(255) := 'EXTR_APC_PROPERTIES';
    l_ndebug                     NUMBER;
    l_check_for_stub_views       NUMBER;

    l_prop_values_tbl                long_varchar_tbl_type;
    l_prop_orig_sys_ref_tbl          long_varchar_tbl_type;
    l_localtext_orig_sys_ref_tbl     long_varchar_tbl_type;
    l_item_master_orig_sys_ref_tbl   varchar_tbl_type;
    l_group_attr_names_tbl           varchar_arr_tbl_type;
    l_group_database_columns_tbl     varchar_arr_tbl_type;
    l_group_db_column_types_tbl      number_arr_tbl_type;
    l_item_cat_tbl                   number_tbl_type;
    l_item_cat_temp_tbl              number_tbl_type;
    l_attr_list_item_cat_tbl         number_tbl_type;
    l_used_db_columns_tbl            varchar_iv_tbl_type;
    l_hier_item_cat_tbl              number_arr_tbl_type;
    l_temp_hier_item_cat_tbl         number_arr_tbl_type;
    l_attr_list_cat_tbl              varchar_tbl_type;

    l_nh_attr_list_cat_tbl           varchar_arr_tbl_type;
    l_t_attr_list_cat_tbl            varchar_tbl_type;

    l_attr_item_cat_tbl              varchar_arr_tbl_type;
    l_attr_by_cat_tbl                varchar_arr_tbl_type;

    l_attr_list_temp_tbl             varchar_tbl_type;
    l_item_cat_path_tbl              varchar_tbl_type;
    l_no_attr_item_cat_tbl           number_tbl_type;
    l_no_attr_catalog                NUMBER;
    l_no_attr_cat_index              NUMBER;
    l_attr_counter                   NUMBER;

  BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_ndebug := 0;
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'EXTR_APC_PROPERTIES is called ('||TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS')||') :',
    fnd_log.LEVEL_STATEMENT);
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'parameters : RUN_ID='||TO_CHAR(p_run_id)||',p_org_id='||TO_CHAR(p_org_id)||
    ', p_top_item_id='||TO_CHAR(p_top_item_id)||',p_expl_type='||p_expl_type ,
    fnd_log.LEVEL_STATEMENT);
  END IF;

  --
  -- if l_check_for_stub_views > 0 then stub views are used
  --
  SELECT COUNT(*) INTO l_check_for_stub_views FROM CZ_EXV_APC_PROPERTIES
  WHERE ATTR_GROUP_ID = -1 AND
        ITEM_CATALOG_GROUP_ID = -1 AND
        ATTR_ID = -1 AND
        APPLICATION_ID = -1;

  DELETE FROM CZ_IMP_TMP_ITEMCAT WHERE run_id=p_run_id;
  COMMIT;

  --
  -- if list of item catalog group is empty or stub views are used then just return
  --
  IF itemCatalogGroupId.COUNT=0 OR l_check_for_stub_views > 0 THEN
    RETURN;
  END IF;

  --
  -- Definitions of global SQL types which are used in TABLE(CAST(...))
  --
  -- CREATE OR REPLACE TYPE SYSTEM.CZ_ITEM_CATALOG_REC IS OBJECT(item_catalog_group_id number);
  --
  -- CREATE OR REPLACE TYPE SYSTEM.CZ_ITEM_CATALOG_TBL IS TABLE OF SYSTEM.CZ_ITEM_CATALOG_REC;
  --

  FOR item_index IN itemCatalogGroupId.FIRST..itemCatalogGroupId.LAST
  LOOP
    l_item_catalog_path := '';

    FOR i IN(SELECT item_catalog_group_id,parent_catalog_group_id,description,catalog_concat_segs
               FROM CZ_EXV_ITEM_TYPES
             START WITH item_catalog_group_id = itemCatalogGroupId(item_index)
             CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id)
    LOOP
      l_prev_item_catalog_tbl.extend;
      l_prev_item_catalog_tbl(l_prev_item_catalog_tbl.LAST) := SYSTEM.CZ_ITEM_CATALOG_REC(i.item_catalog_group_id);

      IF i.item_catalog_group_id<>itemCatalogGroupId(item_index) THEN
        l_item_cat_tbl(l_item_cat_tbl.COUNT+1) := i.item_catalog_group_id;
        l_item_catalog_path := l_item_catalog_path || '-' || TO_CHAR(i.item_catalog_group_id);
      END IF;

    END LOOP;

    IF l_item_cat_tbl.COUNT>0 THEN
      l_hier_item_cat_tbl(itemCatalogGroupId(item_index)) := l_item_cat_tbl;
      l_item_cat_path_tbl(itemCatalogGroupId(item_index)) := l_item_catalog_path;
      l_item_cat_tbl.DELETE;
    END IF;

  END LOOP;

  INSERT INTO CZ_IMP_TMP_ITEMCAT(run_id, item_catalog_group_id)
  SELECT p_run_id,item_catalog_group_id
    FROM (SELECT DISTINCT item_catalog_group_id
            FROM TABLE(CAST(l_prev_item_catalog_tbl AS SYSTEM.CZ_ITEM_CATALOG_TBL)) WHERE item_catalog_group_id IS NOT NULL);


  IF SQL%ROWCOUNT=0 THEN
    RETURN;
  END IF;

  --
  -- l_prev_item_catalog_tbl will not be in use anymore - remove all elements from it
  --
  l_prev_item_catalog_tbl.DELETE;

  --
  -- retrieve meta data for current itemCatalogGroupId = itemCatalogGroupId(item_index)
  --
  l_rec_counter := 0;


  FOR attr IN(SELECT attr_group_id, attr_group_name||'.'||attr_name  AS attribute_name,
                   DECODE(data_type_code,'N',DECIMAL_TYPE,'C',TEXT_TYPE,'A',TL_TEXT_TYPE,TEXT_TYPE) AS property_type,
                   database_column,description,apcprops.item_catalog_group_id,apcprops.default_value
              FROM CZ_EXV_APC_PROPERTIES apcprops,
                   CZ_IMP_TMP_ITEMCAT itemtypes
             WHERE apcprops.item_catalog_group_id=itemtypes.item_catalog_group_id AND
                   itemtypes.run_id=p_run_id
                   ORDER BY attr_group_id)
  LOOP
    l_rec_counter := l_rec_counter + 1;
    l_attr_group_id_tbl(l_rec_counter) := attr.attr_group_id;
    l_attr_name_tbl(l_rec_counter) := attr.attribute_name;
    l_property_type_tbl(l_rec_counter) := attr.property_type;
    l_database_column_tbl(l_rec_counter) := attr.database_column;
    l_description_tbl(l_rec_counter) := attr.description;
    l_item_catalog_group_id_tbl(l_rec_counter) := attr.item_catalog_group_id;
    l_def_value_tbl(l_rec_counter) := attr.default_value;

    IF l_attr_by_cat_tbl.EXISTS(attr.item_catalog_group_id) THEN
      l_attr_counter := l_attr_by_cat_tbl(attr.item_catalog_group_id).COUNT + 1;
      l_attr_by_cat_tbl(attr.item_catalog_group_id)(l_attr_counter) := attr.attribute_name;
    ELSE
      l_attr_by_cat_tbl(attr.item_catalog_group_id)(1) := attr.attribute_name;
    END IF;

    l_used_db_columns_tbl(attr.database_column) := attr.database_column;

  END LOOP;

  IF l_attr_name_tbl.COUNT = 0 THEN
    DELETE FROM CZ_IMP_TMP_ITEMCAT where run_id=p_run_id;
    RETURN;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'APC meta data have been retrieved ('||TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS')||') ',
    fnd_log.LEVEL_STATEMENT);
  END IF;

  FOR ii IN (SELECT item_catalog_group_id FROM CZ_IMP_TMP_ITEMCAT WHERE run_id=p_run_id)
  LOOP
    IF l_hier_item_cat_tbl.EXISTS(ii.item_catalog_group_id) THEN

       l_item_cat_tbl := l_hier_item_cat_tbl(ii.item_catalog_group_id);

       IF l_item_cat_tbl.COUNT > 0 THEN

         FOR jj IN l_item_cat_tbl.First..l_item_cat_tbl.Last
         LOOP
           IF l_attr_by_cat_tbl.EXISTS(l_item_cat_tbl(jj)) AND l_attr_by_cat_tbl(l_item_cat_tbl(jj)).COUNT > 0 THEN
             FOR kk IN 1..l_attr_by_cat_tbl(l_item_cat_tbl(jj)).COUNT
             LOOP
               IF l_attr_item_cat_tbl.EXISTS(ii.item_catalog_group_id) THEN
                 l_attr_counter := l_attr_item_cat_tbl(ii.item_catalog_group_id).COUNT + 1;
                 l_attr_item_cat_tbl(ii.item_catalog_group_id)(l_attr_counter) := l_attr_by_cat_tbl(l_item_cat_tbl(jj))(kk);
               ELSE
                 l_attr_item_cat_tbl(ii.item_catalog_group_id)(1) := l_attr_by_cat_tbl(l_item_cat_tbl(jj))(kk);
               END IF;
             END LOOP;
           END IF;

         END LOOP;
       END IF;
    END IF;
  END LOOP;


  --
  -- populate Import Property table with APC properties meta data for Items
  -- format of ORIG_SYS_REF : <CZ_ATTR_NAME> || ':' || <EGO_APPLICATION_ID>
  -- where CZ_ATTR_NAME = <APC attr_group_name>||'.'||<APC attr_name>
  --
  FOR i IN l_attr_name_tbl.FIRST..l_attr_name_tbl.LAST
  LOOP
    INSERT INTO CZ_IMP_PROPERTY
      (DESC_TEXT,NAME,ORIG_SYS_REF,RUN_ID,DATA_TYPE,DEF_VALUE,DEF_NUM_VALUE,SRC_APPLICATION_ID)
    VALUES (l_description_tbl(i),
            l_attr_name_tbl(i),
            l_attr_name_tbl(i)||'-'||TO_CHAR(G_EGO_APPLICATION_ID),
            p_run_id,
            l_property_type_tbl(i),
            l_def_value_tbl(i),
            DECODE(l_property_type_tbl(i),DECIMAL_TYPE,TO_NUMBER(l_def_value_tbl(i)),NULL),
            G_EGO_APPLICATION_ID);
  END LOOP;

  COMMIT;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'CZ_IMP_PROPERTY has been populated ('||TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS')||') ',
    fnd_log.LEVEL_STATEMENT);
  END IF;

  --
  -- populate Import Property table with APC properties meta data for Item Types
  -- format of ORIG_SYS_REF : <ITEM CATALOG_GROUP_ID> || ':' || <CZ_ATTR_NAME> || ':' || <EGO_APPLICATION_ID>
  -- where CZ_ATTR_NAME = <APC attr_group_name>||'.'||<APC attr_name>
  --
 FORALL i IN l_attr_name_tbl.FIRST..l_attr_name_tbl.LAST
    INSERT INTO CZ_IMP_ITEM_TYPE_PROPERTY
      (FSK_ITEMTYPE_1_1,FSK_ITEMTYPE_1_EXT,FSK_PROPERTY_2_1,FSK_PROPERTY_2_EXT,RUN_ID,
       ORIG_SYS_REF,SRC_APPLICATION_ID)
    VALUES (l_item_catalog_group_id_tbl(i),
            l_item_catalog_group_id_tbl(i),
            l_attr_name_tbl(i)||'-'||TO_CHAR(G_EGO_APPLICATION_ID),
            l_attr_name_tbl(i)||'-'||TO_CHAR(G_EGO_APPLICATION_ID),
            p_run_id,
            TO_CHAR(l_item_catalog_group_id_tbl(i)) || ':' ||l_attr_name_tbl(i)||'-'||TO_CHAR(G_EGO_APPLICATION_ID),
            G_EGO_APPLICATION_ID);

  COMMIT;

  FOR ii IN (SELECT item_catalog_group_id FROM CZ_IMP_TMP_ITEMCAT WHERE run_id=p_run_id)
  LOOP
    IF l_attr_item_cat_tbl.EXISTS(ii.item_catalog_group_id) THEN
      l_attr_list_temp_tbl := l_attr_item_cat_tbl(ii.item_catalog_group_id);

      IF l_attr_list_temp_tbl.COUNT > 0 THEN
        FOR jj IN l_attr_list_temp_tbl.First..l_attr_list_temp_tbl.Last
        LOOP
          INSERT INTO CZ_IMP_ITEM_TYPE_PROPERTY
          (FSK_ITEMTYPE_1_1,FSK_ITEMTYPE_1_EXT,FSK_PROPERTY_2_1,FSK_PROPERTY_2_EXT,RUN_ID,
           ORIG_SYS_REF,SRC_APPLICATION_ID)
          VALUES (ii.item_catalog_group_id,
           ii.item_catalog_group_id,
           l_attr_list_temp_tbl(jj)||'-'||TO_CHAR(G_EGO_APPLICATION_ID),
           l_attr_list_temp_tbl(jj)||'-'||TO_CHAR(G_EGO_APPLICATION_ID),
           p_run_id,
           TO_CHAR(ii.item_catalog_group_id)|| ':'||
           l_attr_list_temp_tbl(jj)||'-'||TO_CHAR(G_EGO_APPLICATION_ID) || '-' || l_item_cat_path_tbl(ii.item_catalog_group_id) ,
           G_EGO_APPLICATION_ID);

        END LOOP;
      END IF;

    END IF;
  END LOOP;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'CZ_IMP_ITEM_TYPE_PROPERTY has been populated ('||TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS')||') ',
    fnd_log.LEVEL_STATEMENT);
  END IF;

  --
  -- collect APC meta data for properties :
  --
  --   l_att_names_tbl          - array of attribute names ( one array per attribute group )
  --   l_db_columns_tbl         - array of column names ( one array per attribute group )
  --   l_db_column_types_tbl    - array of column types ( one array per attribute group )
  --
  --   l_att_names_tbl, l_db_columns_tbl and l_db_column_types_tbl are temp arrays which are
  --   used for populating 2-dim arrays  l_group_attr_names_tbl, l_group_database_columns_tbl, l_group_db_column_types_tbl
  --
  --   l_group_attr_names_tbl       - array of array l_att_names_tbl ( stores arrays l_att_names_tbl for attribute groups )
  --                                  index of array is attribute group id
  --   l_group_database_columns_tbl - array of array l_db_columns_tbl ( stores arrays l_db_columns_tbl for attribute groups )
  --                                  index of array is attribute group id
  --   l_group_db_column_types_tbl  - array of array l_group_db_column_types_tbl ( stores arrays l_group_db_column_types_tbl for attribute groups )
  --                                  index of array is attribute group id
  --

  l_current_attr_group_id := 0;

  FOR i IN l_attr_name_tbl.FIRST..l_attr_name_tbl.LAST
  LOOP

    IF l_current_attr_group_id=l_attr_group_id_tbl(i) THEN
      l_att_names_tbl(l_att_names_tbl.COUNT+1)                := l_attr_name_tbl(i);
      l_db_columns_tbl(l_db_columns_tbl.COUNT+1)              := l_database_column_tbl(i);
      l_db_column_types_tbl(l_db_column_types_tbl.COUNT+1)    := l_property_type_tbl(i);
    ELSE
      IF l_current_attr_group_id=0 THEN
        l_current_attr_group_id := l_attr_group_id_tbl(i);
        l_att_names_tbl(l_att_names_tbl.COUNT+1)              := l_attr_name_tbl(i);
        l_db_columns_tbl(l_db_columns_tbl.COUNT+1)            := l_database_column_tbl(i);
        l_db_column_types_tbl(l_db_column_types_tbl.COUNT+1)  := l_property_type_tbl(i);
      ELSE
        l_group_attr_names_tbl(l_current_attr_group_id)       := l_att_names_tbl;
        l_group_database_columns_tbl(l_current_attr_group_id) := l_db_columns_tbl;
        l_group_db_column_types_tbl(l_current_attr_group_id)  := l_db_column_types_tbl;

        l_att_names_tbl.DELETE;
        l_db_columns_tbl.DELETE;
        l_db_column_types_tbl.DELETE;

        l_current_attr_group_id := l_attr_group_id_tbl(i);

        l_att_names_tbl(l_att_names_tbl.COUNT+1)              := l_attr_name_tbl(i);
        l_db_columns_tbl(l_db_columns_tbl.COUNT+1)            := l_database_column_tbl(i);
        l_db_column_types_tbl(l_db_column_types_tbl.COUNT+1)  := l_property_type_tbl(i);

      END IF;
    END IF;
  END LOOP;

  -- populate 2-dim arrays
  l_group_attr_names_tbl(l_current_attr_group_id)             := l_att_names_tbl;
  l_group_database_columns_tbl(l_current_attr_group_id)       := l_db_columns_tbl;
  l_group_db_column_types_tbl(l_current_attr_group_id)        := l_db_column_types_tbl;

  -- release temp arrays
  l_att_names_tbl.DELETE;
  l_db_columns_tbl.DELETE;
  l_db_column_types_tbl.DELETE;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'Internal arrays have been populated ('||TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS')||') ',
    fnd_log.LEVEL_STATEMENT);
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'Retrieving of APC property values will be started ('||TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS')||') ',
    fnd_log.LEVEL_STATEMENT);
  END IF;

---Bug Fix - 8519380
  l_sql := 'SELECT apcpropvals.* FROM CZ_EXV_ITEM_APC_PROP_VALUES apcpropvals,'||
           'CZ_IMP_TMP_ITEMCAT itemtypes '||
            'WHERE apcpropvals.item_catalog_group_id = itemtypes.item_catalog_group_id '||
              'AND EXISTS (SELECT NULL FROM CZ_EXV_ITEMS '||
                          'WHERE inventory_item_id = apcpropvals.inventory_item_id '||
                          ' AND organization_id = '|| p_org_id ||
                          ' AND top_item_id = '||p_top_item_id||
                          ' AND explosion_type = '''||p_expl_type||''')'||
              ' AND organization_id = '|| p_org_id ||
              ' AND inventory_item_id IS NOT NULL ORDER BY INVENTORY_ITEM_ID';
  --
  -- define cursor and dynamically describe columns of this cursor
  --
  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);
  l_exec := DBMS_SQL.EXECUTE(l_cursor);
  DBMS_SQL.DESCRIBE_COLUMNS(l_cursor, l_col_cnt, l_rec_tab);

  --
  -- dynamically define columns of record set
  --
  l_col_num := l_rec_tab.FIRST;
  IF (l_col_num IS NOT NULL) THEN
    LOOP
      l_col_name:=UPPER(l_rec_tab(l_col_num).col_name);
      l_col_length:=l_rec_tab(l_col_num).col_max_len;

      l_col_tbl(l_col_name).col_name := l_col_name;
      l_col_tbl(l_col_name).col_num  := l_col_num;

      IF l_col_name IN('ATTR_GROUP_ID') THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor,l_col_num,l_num_value);
        l_attr_group_col_num := l_col_num;
      ELSIF l_col_name IN('INVENTORY_ITEM_ID') THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor,l_col_num,l_num_value);
        l_inv_item_col_num := l_col_num;
      ELSIF l_col_name IN('ORGANIZATION_ID') THEN
         DBMS_SQL.DEFINE_COLUMN(l_cursor,l_col_num,l_num_value);
         l_org_id_col_num := l_col_num;
      ELSIF l_col_name IN('LANGUAGE') THEN
         DBMS_SQL.DEFINE_COLUMN(l_cursor,l_col_num,l_str_value,l_col_length);
         l_lang_col_num := l_col_num;
      ELSIF l_col_name IN('SOURCE_LANG') THEN
         DBMS_SQL.DEFINE_COLUMN(l_cursor,l_col_num,l_str_value,l_col_length);
         l_source_lang_col_num := l_col_num;
      END IF;

      IF l_used_db_columns_tbl.EXISTS(l_col_name) THEN
        DBMS_SQL.DEFINE_COLUMN(l_cursor,l_col_num,l_str_value,l_col_length);
      END IF;

      l_col_num := l_rec_tab.NEXT(l_col_num);
      EXIT WHEN (l_col_num IS NULL);

    END LOOP; -- end of loop through l_rec_tab
  END IF; -- end of IF (l_col_num IS NOT NULL) THEN

  l_current_inv_item_id := 0;

  l_rec_counter := 0;

  --
  -- fetch records from dynamic cursor with sql =  l_sql
  --
  LOOP

    IF DBMS_SQL.FETCH_ROWS(l_cursor)=0 THEN
      EXIT;
    ELSE
      DBMS_SQL.COLUMN_VALUE(l_cursor,l_attr_group_col_num,l_attr_group_id);
      DBMS_SQL.COLUMN_VALUE(l_cursor,l_inv_item_col_num,l_inventory_item_id);
      DBMS_SQL.COLUMN_VALUE(l_cursor,l_org_id_col_num,l_org_id);
      DBMS_SQL.COLUMN_VALUE(l_cursor,l_lang_col_num,l_language);
      DBMS_SQL.COLUMN_VALUE(l_cursor,l_source_lang_col_num,l_source_lang);

      l_att_names_tbl       := l_group_attr_names_tbl(l_attr_group_id);
      l_db_columns_tbl      := l_group_database_columns_tbl(l_attr_group_id);
      l_db_column_types_tbl := l_group_db_column_types_tbl(l_attr_group_id);

      --
      -- handle each EXT column in this loop
      --
      FOR n IN l_db_columns_tbl.FIRST..l_db_columns_tbl.LAST
      LOOP
        -- find column num of column with name l_db_columns_tbl(m)
        l_column_num := get_Col_Num(l_db_columns_tbl(n), l_col_tbl);

        --
        -- find value of property which is stored in column l_db_columns_tbl(n)
        --
        DBMS_SQL.COLUMN_VALUE(l_cursor,l_column_num,l_column_value);

        IF l_column_value IS NOT NULL THEN

        l_rec_counter := l_rec_counter + 1;

        l_prop_values_tbl(l_rec_counter)              := l_column_value;
        l_prop_orig_sys_ref_tbl(l_rec_counter)        := l_att_names_tbl(n)||'-'||TO_CHAR(G_EGO_APPLICATION_ID);
        l_item_master_orig_sys_ref_tbl(l_rec_counter) := TO_CHAR(l_inventory_item_id)||':'||TO_CHAR(l_org_id);

        l_localtext_orig_sys_ref_tbl(l_rec_counter)   := NULL;

        --
        -- if it is translatable property then populate l_num_value_tbl () with intl_text_id and
        -- add record to CZ_IMP_LOCALIZED_TEXTS with
        --  ORIG_SYS_REF = l_prop_orig_sys_ref_tbl(l_rec_counter)
        --
        IF l_db_column_types_tbl(n)=TL_TEXT_TYPE THEN  -- translatable text
          l_localtext_orig_sys_ref_tbl(l_rec_counter)   := l_prop_orig_sys_ref_tbl(l_rec_counter)||':'||l_db_columns_tbl(n)||':'||TO_CHAR(l_inventory_item_id);

          INSERT INTO CZ_IMP_LOCALIZED_TEXTS
            (LOCALIZED_STR, LANGUAGE, SOURCE_LANG, RUN_ID,  ORIG_SYS_REF, MODEL_ID)
          VALUES
            (l_column_value,l_language, l_source_lang, p_run_id, l_localtext_orig_sys_ref_tbl(l_rec_counter),0);
          l_num_value_tbl (l_rec_counter) := NULL;
        ELSIF  l_db_column_types_tbl(n)=DECIMAL_TYPE THEN -- DECIMAL
            l_num_value_tbl (l_rec_counter) := TO_NUMBER(l_column_value);
            l_prop_values_tbl(l_rec_counter) := l_column_value;
        ELSE
            l_num_value_tbl (l_rec_counter) := NULL;
        END IF;

       END IF;

      END LOOP; -- end of FOR n IN ...

    END IF;  -- end of IF DBMS_SQL.FETCH_ROWS(l_cursor)=0

    IF l_prop_values_tbl.COUNT > 0 AND (l_rec_counter=l_Batch_Size  OR FLOOR(l_rec_counter/l_Batch_Size)=0) THEN

      --
      -- insert portion of data limited by l_Batch_Size to Import Property Values
      --
      FORALL i IN l_prop_values_tbl.FIRST..l_prop_values_tbl.LAST
        INSERT INTO CZ_IMP_ITEM_PROPERTY_VALUE
          (PROPERTY_VALUE, FSK_PROPERTY_1_1,FSK_PROPERTY_1_EXT,
           FSK_ITEMMASTER_2_1,FSK_ITEMMASTER_2_EXT,RUN_ID,ORIG_SYS_REF,FSK_LOCALIZEDTEXT_3_1,PROPERTY_NUM_VALUE,
           SRC_APPLICATION_ID)
         VALUES
          (l_prop_values_tbl(i), l_prop_orig_sys_ref_tbl(i),l_prop_orig_sys_ref_tbl(i),
           l_item_master_orig_sys_ref_tbl(i), l_item_master_orig_sys_ref_tbl(i),
           p_run_id,
           l_item_master_orig_sys_ref_tbl(i) || ':' || l_prop_orig_sys_ref_tbl(i),
           l_localtext_orig_sys_ref_tbl(i),
           l_num_value_tbl(i),
           G_EGO_APPLICATION_ID);

        COMMIT;

        FORALL i IN l_prop_values_tbl.FIRST..l_prop_values_tbl.LAST
          INSERT INTO CZ_IMP_LOCALIZED_TEXTS
            (LOCALIZED_STR, LANGUAGE, SOURCE_LANG, RUN_ID,  ORIG_SYS_REF, MODEL_ID)
          SELECT
            LOCALIZED_STR, LANG.LANGUAGE_CODE, SOURCE_LANG, RUN_ID,  ORIG_SYS_REF, MODEL_ID
	   FROM CZ_IMP_LOCALIZED_TEXTS intl,fnd_languages lang
            WHERE intl.run_id=p_run_id AND intl.orig_sys_ref=l_localtext_orig_sys_ref_tbl(i) AND installed_flag in( 'B', 'I')
                  AND LANGUAGE_CODE<>SOURCE_LANG
		AND EXISTS
		(SELECT 1 FROM CZ_IMP_LOCALIZED_TEXTS loc,fnd_languages lang
		 WHERE loc.run_id=p_run_id AND orig_sys_ref = intl.orig_sys_ref
		       AND lang.language_code <> loc.language
                   );
       COMMIT;

        l_rec_counter := 0;
        l_prop_values_tbl.DELETE;
        l_prop_orig_sys_ref_tbl.DELETE;
        l_item_master_orig_sys_ref_tbl.DELETE;
        l_num_value_tbl.DELETE;
        l_localtext_orig_sys_ref_tbl.DELETE;
    END IF;


  END LOOP;  -- end of looping through l_cursor

  -- close cursor
  DBMS_SQL.CLOSE_CURSOR(l_cursor);

  DELETE FROM CZ_IMP_TMP_ITEMCAT WHERE run_id=p_run_id;
  COMMIT;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    cz_utils.log_report(G_PKG_NAME, l_api_name, l_ndebug,
    'CZ_IMP_ITEM_PROPERTY_VALUE has been populated ('||TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS')||') ',
    fnd_log.LEVEL_STATEMENT);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DELETE FROM CZ_IMP_TMP_ITEMCAT WHERE run_id=p_run_id;
    COMMIT;
    l_error:=CZ_UTILS.LOG_REPORT(SQLERRM,1,'EXTR_APC_PROPERTIES',11276,p_run_id);
    RAISE;
END EXTR_APC_PROPERTIES;

------------------------------------------------------------------------------------------
PROCEDURE EXTR_PROPERTIES(inRun_ID    IN PLS_INTEGER,
                          nOrg_ID     IN NUMBER,
                          nTop_ID     IN NUMBER,
                          sExpl_type  IN VARCHAR2)
IS
   DECIMAL_TYPE         CONSTANT NUMBER := 2;
   TEXT_TYPE            CONSTANT NUMBER := 4;

   xERROR          BOOLEAN:=FALSE;
   sName           CZ_IMP_PROPERTY.ORIG_SYS_REF%TYPE;
   nType           CZ_IMP_PROPERTY.DATA_TYPE%TYPE;
   sResolve        CZ_DB_SETTINGS.VALUE%TYPE;

   TYPE tNumber    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   tabValues       tNumber;

   CURSOR C_DATATYPE IS
    SELECT ORIG_SYS_REF FROM CZ_IMP_PROPERTY WHERE RUN_ID=inRUN_ID AND REC_STATUS IS NULL
    FOR UPDATE;

   st_time               number;
   end_time              number;
   loop_end_time         number;
   insert_end_time       number;
   d_str                 varchar2(255);
   l_noupdate            cz_xfr_fields.noupdate%TYPE;
   l_check_values        BOOLEAN :=FALSE;
   l_onl_type            cz_properties.data_type%TYPE;

   v_settings_id         VARCHAR2(40);
   v_section_name        VARCHAR2(30);

BEGIN

 if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
 end if;

  FORALL i IN 1..itemCatalogGroupId.COUNT
    INSERT INTO CZ_IMP_PROPERTY
      (DESC_TEXT,NAME,ORIG_SYS_REF,RUN_ID,DATA_TYPE,SRC_APPLICATION_ID)
    SELECT DESCRIPTION, ELEMENT_NAME, ELEMENT_NAME, inRUN_ID, TEXT_TYPE, G_BOM_APPLICATION_ID
      FROM CZ_EXV_ITEM_PROPERTIES
     WHERE ITEM_CATALOG_GROUP_ID = itemCatalogGroupId(i);

 if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Insert property (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
  end if;

  COMMIT;

 v_settings_id := 'ResolvePropertyDataType';
 v_section_name := 'ORAAPPS_INTEGRATE';

 BEGIN
  SELECT VALUE INTO sResolve FROM CZ_DB_SETTINGS
  WHERE SETTING_ID=v_settings_id AND SECTION_NAME=v_section_name;
 EXCEPTION
   WHEN OTHERS THEN
     sResolve:='NO';
 END;

 BEGIN
  SELECT noupdate INTO l_noupdate
  FROM cz_xfr_fields f, cz_xfr_tables t
  WHERE t.order_seq=f.order_seq
  AND t.dst_table='CZ_PROPERTIES'
  AND f.xfr_group='IMPORT'
  AND t.xfr_group=f.xfr_group
  AND f.dst_field='DATA_TYPE'
  AND rownum < 2;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
  l_noupdate:='0';
END;

   OPEN C_DATATYPE;
   LOOP
      FETCH C_DATATYPE INTO sName;
      EXIT WHEN C_DATATYPE%NOTFOUND;

      BEGIN
        SELECT data_type INTO l_onl_type
        FROM cz_properties
        WHERE orig_sys_ref=sName
        AND deleted_flag='0'
        AND rownum <2;
        nType := l_onl_type;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
        l_onl_type:= -1;
      END;

      IF (l_onl_type = -1 AND sResolve = 'YES') THEN
        l_check_values := TRUE;
      ELSIF (l_onl_type = -1 AND sResolve = 'NO') THEN
        l_check_values := FALSE;
        nType := TEXT_TYPE;
      ELSIF (l_onl_type = TEXT_TYPE AND l_noupdate = '1') THEN
        l_check_values := FALSE;
        nType := TEXT_TYPE;
      ELSIF (l_onl_type = TEXT_TYPE AND l_noupdate = '0' AND sResolve='YES') THEN
        l_check_values := TRUE;
      ELSIF (l_onl_type = DECIMAL_TYPE AND l_noupdate = '1') THEN
        l_check_values := FALSE;
        nType := DECIMAL_TYPE;
      ELSIF (l_onl_type = DECIMAL_TYPE AND l_noupdate = '0') THEN
        l_check_values := TRUE;
      ELSE
        l_check_values := FALSE;
        nType := TEXT_TYPE;
      END IF;

      IF (l_check_values = TRUE) THEN
        BEGIN
          tabValues.DELETE;

          SELECT TO_NUMBER(element_value) BULK COLLECT INTO tabValues
            FROM cz_exv_descr_element_values
           WHERE element_name = sName;

          IF(tabValues.COUNT > 0)THEN
            nType := DECIMAL_TYPE;
          END IF;
        EXCEPTION
          WHEN INVALID_NUMBER THEN
           nType := TEXT_TYPE;
        END;
      END IF;

      IF(nType=DECIMAL_TYPE)THEN
        UPDATE CZ_IMP_PROPERTY SET DATA_TYPE=DECIMAL_TYPE,DEF_NUM_VALUE=0
        WHERE CURRENT OF C_DATATYPE;
      END IF;
   END LOOP;
   CLOSE C_DATATYPE;
  if (CZ_IMP_ALL.get_time) then
        loop_end_time := dbms_utility.get_time();
        d_str := inRun_Id || '        Resolve property datatype (' || nTop_Id || ') :' || (loop_end_time-end_time)/100.00;
            xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
  end if;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
   NULL;
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
  WHEN OTHERS THEN
    IF(c_datatype%ISOPEN)THEN CLOSE c_datatype; END IF;
   d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
   xERROR:=cz_utils.log_report(d_str,1,'EXTR_PROPERTIES',11276,inRun_Id);
   RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------
PROCEDURE EXTR_ITEM_TYPE_PROPERTIES(inRun_ID    IN PLS_INTEGER,
                                    nOrg_ID     IN NUMBER,
                                    nTop_ID     IN NUMBER,
                                    sExpl_type  IN VARCHAR2)
IS
   xERROR          BOOLEAN:=FALSE;

   st_time               number;
   end_time              number;
   loop_end_time             number;
   insert_end_time       number;
   d_str                       varchar2(255);

BEGIN

 if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
 end if;

 FORALL i IN 1..itemCatalogGroupId.COUNT
   INSERT INTO CZ_IMP_ITEM_TYPE_PROPERTY
     (FSK_ITEMTYPE_1_1,FSK_ITEMTYPE_1_EXT,FSK_PROPERTY_2_1,FSK_PROPERTY_2_EXT,RUN_ID,
      ORIG_SYS_REF,SRC_APPLICATION_ID)
   SELECT ITEM_CATALOG_GROUP_ID, ITEM_CATALOG_GROUP_ID, ELEMENT_NAME, ELEMENT_NAME, inRUN_ID,
          TO_CHAR(ITEM_CATALOG_GROUP_ID) || ':' || ELEMENT_NAME, G_BOM_APPLICATION_ID
     FROM CZ_EXV_ITEM_PROPERTIES
    WHERE ITEM_CATALOG_GROUP_ID = itemCatalogGroupId(i);

 if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Insert item Type prop (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
  end if;

 COMMIT;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   NULL;
 WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
 WHEN OTHERS THEN
   d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
   xERROR:=cz_utils.log_report(d_str,1,'EXTR_ITEM_TYPE_PROPERTIES',11276,inRun_Id);
   RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------
PROCEDURE EXTR_ITEM_PROPERTY_VALUES(inRun_ID    IN PLS_INTEGER,
                                    nOrg_ID     IN NUMBER,
                                    nTop_ID     IN NUMBER,
                                    sExpl_type  IN VARCHAR2)
IS
   xERROR          BOOLEAN:=FALSE;

   st_time               number;
   end_time              number;
   loop_end_time         number;
   d_str                 varchar2(255);

BEGIN

  if(CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
  end if;

  FORALL i IN 1..inventoryItemId.COUNT
    INSERT INTO CZ_IMP_ITEM_PROPERTY_VALUE
      (PROPERTY_VALUE, FSK_PROPERTY_1_1, FSK_PROPERTY_1_EXT,
       FSK_ITEMMASTER_2_1,
       FSK_ITEMMASTER_2_EXT,
       RUN_ID,
       ORIG_SYS_REF, SRC_APPLICATION_ID)
    SELECT ELEMENT_VALUE, ELEMENT_NAME, ELEMENT_NAME,
           CZ_ORAAPPS_INTEGRATE.ITEM_SURROGATE_KEY(to_char(INVENTORY_ITEM_ID), to_char(ORGANIZATION_ID)),
           CZ_ORAAPPS_INTEGRATE.ITEM_SURROGATE_KEY(to_char(INVENTORY_ITEM_ID), to_char(ORGANIZATION_ID)),
           inRun_ID,
           CZ_ORAAPPS_INTEGRATE.ITEM_SURROGATE_KEY(to_char(INVENTORY_ITEM_ID), to_char(ORGANIZATION_ID))|| ':' || ELEMENT_NAME,
           G_BOM_APPLICATION_ID
      FROM CZ_EXV_ITEM_PROPERTY_VALUES
     WHERE INVENTORY_ITEM_ID = inventoryItemId(i)
       AND ORGANIZATION_ID = nOrg_ID
       AND ELEMENT_VALUE IS NOT NULL;

  if (CZ_IMP_ALL.get_time) then
        loop_end_time := dbms_utility.get_time();
        d_str := inRun_Id || '       Bulk collect prop val (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xError:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
  end if;

  COMMIT;
EXCEPTION
 WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
 WHEN NO_DATA_FOUND THEN
   NULL;
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
 WHEN OTHERS THEN
   d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
   xERROR:=cz_utils.log_report(d_str,1,'EXTR_ITEM_PROPERTY_VALUES',11276,inRun_Id);
   RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------
PROCEDURE extract_table(inRun_ID    IN PLS_INTEGER,
                        table_name  IN VARCHAR2,
                        nOrg_ID     IN NUMBER,
                        nTop_ID     IN NUMBER,
                        sExpl_type  IN VARCHAR2,
                        nModelId    IN NUMBER)
IS
  lower_table_name  VARCHAR2(50) := LOWER(table_name);
  xERROR            BOOLEAN:=FALSE;
  st_time number;
  end_time number;
  d_str    varchar2(255);
BEGIN
  --DBMS_OUTPUT.ENABLE;
  --DBMS_OUTPUT.PUT_LINE('EXTRACTING TABLE: ' || lower_table_name);
  IF(lower_table_name='cz_item_masters') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     EXTR_ITEM_MASTER(inRun_ID,nOrg_ID,nTop_ID,sExpl_type);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Extract item master (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_ps_nodes') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     EXTR_PS_NODE(inRun_ID,nOrg_ID,nTop_ID,sExpl_type,nModelId);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str :=inRun_Id || '    Extract ps structure (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_localized_texts') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     EXTR_INTL_TEXT(inRun_ID,nOrg_ID,nTop_ID,sExpl_type,nModelId);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Extract intl text (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
                xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_devl_projects') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     EXTR_DEVL_PROJECT(inRun_ID,nOrg_ID,nTop_ID,sExpl_type,nModelId);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Extract devl project (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_item_types') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     EXTR_ITEM_TYPES(inRun_ID,nOrg_ID,nTop_ID,sExpl_type);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Extract item types (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_properties') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     EXTR_PROPERTIES(inRun_ID,nOrg_ID,nTop_ID,sExpl_type);

   EXTR_APC_PROPERTIES(p_run_id      => inRun_ID,
                       p_org_id      => nOrg_ID,
                       p_top_item_id => nTop_ID,
                       p_expl_type   => sExpl_type);

    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Extract property (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_item_type_properties') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     EXTR_ITEM_TYPE_PROPERTIES(inRun_ID,nOrg_ID,nTop_ID,sExpl_type);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Extract item type property (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
                xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_item_property_values') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     EXTR_ITEM_PROPERTY_VALUES(inRun_ID,nOrg_ID,nTop_ID,sExpl_type);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Extract item property value (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,inRun_Id);
    end if;
  ELSE
     --DBMS_OUTPUT.PUT_LINE(CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_TABLE_EXTRACT','TABLENAME',table_name));
     xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_TABLE_EXTRACT','TABLENAME',table_name),1,'SINGLEBILL.EXTRACT_TABLE',11276,inRun_Id);
  END IF;
END extract_table;
------------------------------------------------------------------------------------------
PROCEDURE populate_table(inRun_ID       IN PLS_INTEGER,
                         table_name     IN VARCHAR2,
                         commit_size    IN PLS_INTEGER,
                         max_err        IN PLS_INTEGER,
                         inXFR_GROUP    IN VARCHAR2,
                         p_rp_folder_id IN NUMBER,
                         x_failed       IN OUT NOCOPY NUMBER
)
IS
  lower_table_name  VARCHAR2(50) := LOWER(table_name);
  xERROR            BOOLEAN:=FALSE;
  Inserts  PLS_INTEGER;
  Updates  PLS_INTEGER;
  Dups     PLS_INTEGER;
  st_time number;
  end_time number;
  d_str    varchar2(255);
BEGIN
  --DBMS_OUTPUT.ENABLE;
  --DBMS_OUTPUT.PUT_LINE('IMPORTING TABLE: ' || lower_table_name);
  IF(lower_table_name='cz_item_masters') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     CZ_IMP_IM_MAIN.MAIN_ITEM_MASTER(inRun_ID, commit_size, max_err,
                                  Inserts, Updates, x_failed, Dups, inXFR_GROUP);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Populate items :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'POPULATE',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_ps_nodes') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     CZ_IMP_PS_NODE.MAIN_PS_NODE(inRun_ID, commit_size, max_err,
                                     Inserts, Updates, x_failed, Dups, inXFR_GROUP);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Populate product structure :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'POPULATE',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_localized_texts') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     CZ_IMP_PS_NODE.MAIN_INTL_TEXT(inRun_ID, commit_size, max_err,
                                       Inserts, Updates, x_failed, Dups, inXFR_GROUP);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Populate intl text :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'POPULATE',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_devl_projects') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     CZ_IMP_PS_NODE.MAIN_DEVL_PROJECT(inRun_ID, commit_size, max_err,
                                      Inserts, Updates, x_failed, Dups,
                                      inXFR_GROUP,p_rp_folder_id);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Populate project :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'POPULATE',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_item_property_values') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     CZ_IMP_IM_MAIN.MAIN_ITEM_PROPERTY_VALUE(inRun_ID, commit_size, max_err,
                                          Inserts, Updates, x_failed, Dups, inXFR_GROUP);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Populate item property val :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'POPULATE',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_item_types') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     CZ_IMP_IM_MAIN.MAIN_ITEM_TYPE(inRun_ID, commit_size, max_err,
                                Inserts, Updates, x_failed, Dups, inXFR_GROUP);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Populate item type  :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'POPULATE',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_item_type_properties') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     CZ_IMP_IM_MAIN.MAIN_ITEM_TYPE_PROPERTY(inRun_ID, commit_size, max_err,
                                         Inserts, Updates, x_failed, Dups, inXFR_GROUP);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Populate item type property :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'POPULATE',11299,inRun_Id);
    end if;
  ELSIF(lower_table_name='cz_properties') THEN
    if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
    end if;
     CZ_IMP_IM_MAIN.MAIN_PROPERTY(inRun_ID, commit_size, max_err,
                               Inserts, Updates, x_failed, Dups, inXFR_GROUP, p_rp_folder_id);
    if (CZ_IMP_ALL.get_time) then
        end_time := dbms_utility.get_time();
        d_str := inRun_Id || '    Populate property :' || (end_time-st_time)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'POPULATE',11299,inRun_Id);
    end if;
  ELSE
     --DBMS_OUTPUT.PUT_LINE(CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_TABLE_IMPORT','TABLENAME',table_name));
     xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_INVALID_TABLE_IMPORT','TABLENAME',table_name),1,'CZ_IMP_SINGLE.POPULATE_TABLE',11276,inRun_Id);
  END IF;
  --DBMS_OUTPUT.PUT_LINE('INSERTS:    '||to_char(Inserts));
  --DBMS_OUTPUT.PUT_LINE('UPDATES:    '||to_char(Updates));
  --DBMS_OUTPUT.PUT_LINE('FAILED:     '||to_char(x_failed));
  --DBMS_OUTPUT.PUT_LINE('DUPLICATES: '||to_char(Dups));
END populate_table;
------------------------------------------------------------------------------------------
FUNCTION get_remote_import
RETURN BOOLEAN IS

      v_enabled         VARCHAR2(1) := '1';
      v_local           VARCHAR2(8) := 'LOCAL';

	CURSOR check_remote_import IS
		SELECT server_local_id FROM CZ_SERVERS
		WHERE local_name = v_local
		AND import_enabled = v_enabled;

	l_server_id CZ_SERVERS.server_local_id%type;
	x_get_remote_import_f BOOLEAN := false;
	xError boolean := false;
        d_str VARCHAR2(2000);

	BEGIN
		-- check if this import session is local or remote. If remote do not use autonomous
		-- transactions
		OPEN check_remote_import;
		FETCH check_remote_import INTO l_server_id;
			x_get_remote_import_f := check_remote_import%FOUND;
		CLOSE check_remote_import;

		IF (x_get_remote_import_f) THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	EXCEPTION
         WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
            RAISE;
         WHEN OTHERS THEN
           d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
           xERROR:=cz_utils.log_report(d_str,1,'CZ_IMP_SINGLE.GET_REMOTE_IMPORT',11276);
           RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END GET_REMOTE_IMPORT;
------------------------------------------------------------------------------------------
FUNCTION isAppsVersion11i(fndLinkName IN VARCHAR2)
RETURN BOOLEAN
IS

-- Check version of apps for existence of mtl_system_items_tl table
-- This table was introduced for Multilingual support in 11i

   xERROR              BOOLEAN:=FALSE;
   vString 	           VARCHAR2(255);
   v_count 	           NUMBER := 0;
   v_inv_oracle_schema VARCHAR2(255);
   d_str    varchar2(255);
	BEGIN
      get_App_Info('INV', v_inv_oracle_schema);
	vString := 'select count(*) from all_tables' ||fndLinkName||
			' where owner='''||v_inv_oracle_schema||''' AND table_name = ''MTL_SYSTEM_ITEMS_TL'' AND ROWNUM<2';

      EXECUTE IMMEDIATE vString into v_count;
	IF (v_count > 0) then
		return true;
	ELSE
		return false;
	END IF;

EXCEPTION
 WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
   RAISE;
 WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
   RAISE;
 WHEN OTHERS THEN
  d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
  xERROR:=cz_utils.log_report(d_str,1,'CZ_IMP_SINGLE.isAppsVersion11i',11276);
  RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;

------------------------------------------------------------------------------------------
FUNCTION ExtractPsNode(inRunId           IN NUMBER,
                       inOrgId           IN NUMBER,
                       inTopId           IN NUMBER,
                       inExplType        IN VARCHAR2,
                       inServerId        IN NUMBER,
                       inRunExploder     IN PLS_INTEGER,
                       inRevDate         IN DATE,
                       inDateFormat      IN VARCHAR2,
                       inRefreshModelId  IN NUMBER,
                       inCopyRootModel   IN VARCHAR2,
                       inCopyChildModels IN VARCHAR2,
                       inGenStatistics   IN PLS_INTEGER)
RETURN NUMBER IS

   CURSOR c_expl (inLang VARCHAR2) IS
    SELECT component_item_id, component_code FROM cz_exv_item_master
    WHERE top_item_id = inTopId
      AND organization_id = inOrgId
      AND explosion_type = inExplType
      AND bom_item_type = 1
      AND plan_level > 0
      AND language = inLang
      order by plan_level;

   TYPE tStringArray IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
   tabCompCode      tStringArray;
   tabTraversedChildCode      tStringArray;

   nModelId         NUMBER;
   nSecondaryId     NUMBER;
   outGrp_ID        NUMBER;
   outError_code    NUMBER;
   outErr_msg       VARCHAR2(255);
   xERROR           BOOLEAN:=FALSE;
   nTopItemId       NUMBER;
   compCode         VARCHAR2(2000);
   SubModelFlag     PLS_INTEGER;
   l_check          PLS_INTEGER;

   lastCompCode     VARCHAR2(2000);
   nChildTopItemId  NUMBER;

   bom_explode_st   number;
   bom_explode_end  number;
   d_str            varchar2(255);

   childDevlProjectId   cz_devl_projects.devl_project_id%TYPE;
   l_lang               VARCHAR2(4);
BEGIN

  IF(inCopyRootModel = '1')THEN

   SELECT CZ_XFR_PROJECT_BILLS_S.NEXTVAL INTO nModelId FROM DUAL;

   INSERT INTO CZ_XFR_PROJECT_BILLS
    (ORGANIZATION_ID,TOP_ITEM_ID,EXPLOSION_TYPE,DELETED_FLAG,MODEL_PS_NODE_ID,copy_addl_child_models,
     source_server)
   SELECT inOrgId,inTopId,inExplType,'0',nModelId,inCopyChildModels,inServerId
   FROM DUAL;

  ELSE

   IF(inRefreshModelId IS NULL OR inRefreshModelId = -1)THEN

     nModelId := NULL;

     BEGIN
      SELECT p.model_ps_node_id INTO nModelId
        FROM cz_xfr_project_bills p, cz_devl_projects d
      WHERE p.organization_id = inOrgId
        AND p.top_item_id = inTopId
        AND p.explosion_type = inExplType
        AND d.deleted_flag = '0'
        AND d.devl_project_id = d.persistent_project_id
        AND p.model_ps_node_id = d.devl_project_id;
      EXCEPTION
        WHEN OTHERS THEN
          nModelId := NULL;
      END;

     IF(nModelId IS NOT NULL)THEN

      UPDATE cz_xfr_project_bills SET
        deleted_flag = '0',
        copy_addl_child_models = inCopyChildModels,
        source_server = inServerId
      WHERE model_ps_node_id = nModelId;

     ELSE

      SELECT CZ_XFR_PROJECT_BILLS_S.NEXTVAL INTO nModelId FROM DUAL;

      INSERT INTO CZ_XFR_PROJECT_BILLS
       (ORGANIZATION_ID,TOP_ITEM_ID,EXPLOSION_TYPE,DELETED_FLAG,MODEL_PS_NODE_ID,copy_addl_child_models,
        source_server)
      SELECT inOrgId,inTopId,inExplType,'0',nModelId,inCopyChildModels,inServerId
      FROM DUAL;

     END IF;

   ELSE

    nModelId := inRefreshModelId;

    INSERT INTO CZ_XFR_PROJECT_BILLS
      (ORGANIZATION_ID,TOP_ITEM_ID,EXPLOSION_TYPE,DELETED_FLAG,MODEL_PS_NODE_ID,copy_addl_child_models,
       source_server)
    SELECT inOrgId,inTopId,inExplType,'0',inRefreshModelId,inCopyChildModels,inServerId
    FROM DUAL WHERE NOT EXISTS
    (SELECT NULL FROM CZ_XFR_PROJECT_BILLS WHERE model_ps_node_id = inRefreshModelId);

    UPDATE cz_xfr_project_bills SET
      deleted_flag = '0',
      copy_addl_child_models = inCopyChildModels,
      source_server = inServerId
    WHERE model_ps_node_id = inRefreshModelId;

   END IF;
  END IF;

  if (CZ_IMP_ALL.get_time) then
      bom_explode_st := dbms_utility.get_time();
  end if;

  IF((inRunExploder = 1) and (NOT(GET_REMOTE_IMPORT))) THEN

    DELETE FROM bom_explosions WHERE explosion_type = inExplType AND organization_id = inOrgId
       AND top_item_id = inTopId;
    COMMIT;

    BOMPNORD.bmxporder_explode_for_order(inOrgId, 2, inExplType, 1, outGrp_ID,
                    0, 60, inTopId, '', SYSDATE-1000, TO_CHAR(inRevDate, inDateFormat),
                    0, 'N', outErr_msg, outError_code);

      COMMIT;

      IF(inGenStatistics = 1)THEN

        fnd_stats.gather_table_stats('BOM', 'BOM_EXPLOSIONS');
      END IF;

    IF(outError_code <> 0)THEN
      xERROR:=cz_utils.log_report(outErr_msg, 1, 'BOM_EXPLODER', 11276,inRunId);
      CZ_ORAAPPS_INTEGRATE.mRETCODE := 2;
      CZ_ORAAPPS_INTEGRATE.mERRBUF := outErr_msg;
      RETURN nModelId;
    END IF;
  ELSE

    --Bug #5347969. If exploding is disabled or import is remote (we do not explode remotely),
    --we need to check if the available explosion is up-to-date and fail if it is not,
    --otherwise it is possible to delete active items from Configurator.

    BEGIN

      SELECT 1 INTO l_check FROM cz_exv_bom_explosions
       WHERE top_item_id = inTopId
         AND organization_id= inOrgId
         AND explosion_type = inExplType
         AND rexplode_flag = 1
         AND ROWNUM = 1;

      --If found, explosion is not up-to-date.

      outErr_msg := CZ_UTILS.GET_TEXT('CZ_IMP_STALE_EXPLOSION');
      xERROR:=CZ_IMP_ALL.REPORT(outErr_msg, 1, 'BOM_EXPLODER', 11276);
      CZ_ORAAPPS_INTEGRATE.mRETCODE := 2;
      CZ_ORAAPPS_INTEGRATE.mERRBUF := outErr_msg;
      RETURN nModelId;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        --This exception means we can continue.

        NULL;
    END;
  END IF;

  if (CZ_IMP_ALL.get_time) then
     bom_explode_end := dbms_utility.get_time();
     d_str := inRunId || '    Bom Exploder (' || inTopId || ') :' || (bom_explode_end-bom_explode_st)/100.00;
              xERROR:=cz_utils.log_report(d_str,1,'BOM_EXPLODER',11299,inRunId);
  end if;

    extract_table(inRunId, 'CZ_PS_NODES', inOrgId, inTopId, inExplType, nModelId);

  l_lang := userenv('LANG');

  OPEN c_expl (l_lang);
  LOOP
   BEGIN
     FETCH c_expl INTO nTopItemId, compCode;
     EXIT WHEN c_expl%NOTFOUND;

     -- if this model has been processed within this import session, it doesn't need
     -- to be processed again
     IF(NOT processed_expls_tbl.EXISTS(nTopItemId)) THEN
          SubModelFlag := 0;
/*
          -- This code may be obsoleted by use of processed_expls_tbl, but it shouldn't hurt
          -- to leave it in.

          IF(tabCompCode.COUNT > 0)THEN
            FOR i IN 1..tabCompCode.COUNT LOOP
              IF(INSTR(compCode,tabCompCode(i)) <> 0)THEN
                SubModelFlag := 1;
                EXIT;
              END IF;
            END LOOP;
          END IF;
              --Commenting this piece of code as this is obsoleted by use of processed_expls_tbl.//Bug6979513
*/
          IF(SubModelFlag = 0)THEN

            -- Skip if not refreshing unchanged child models.
            IF(importUnchangedChildModels = 0) THEN
              IF(NOT (importChildModel(inRunId, inOrgId, nTopItemId,inExplType))) THEN

                nSecondaryId := ExtractPsNode(inRunId, inOrgId, nTopItemId, inExplType, inServerId,
                                              inRunExploder, inRevDate, inDateFormat, -1, 0, 0, 0);
              END IF;
            ELSE
                nSecondaryId := ExtractPsNode(inRunId, inOrgId, nTopItemId, inExplType, inServerId,
                                              inRunExploder, inRevDate, inDateFormat, -1, 0, 0, 0);
            END IF;

            tabCompCode(tabCompCode.COUNT + 1) := compCode;
            IF(CZ_ORAAPPS_INTEGRATE.mRETCODE = 2)THEN RETURN nModelId; END IF;
          END IF;

          -- Explosion has been processed, add to array
          processed_expls_tbl(nTopItemId) := 1;

     END IF; -- NOT processed_expls_tbl(nTopItemId).EXISTS

   EXCEPTION
      WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
       RAISE;
      WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
       RAISE;
      WHEN OTHERS THEN
       d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
       xERROR:=cz_utils.log_report(d_str,1,'ExtractPsNode.RECURSION',11276);
       RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
   END;
  END LOOP;
  CLOSE c_expl;

  RETURN nModelId;

EXCEPTION
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    RAISE;
  WHEN OTHERS THEN
    d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(d_str,1,'ExtractPsNode',11276,inRunId);
    RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END;
------------------------------------------------------------------------------------------
PROCEDURE ImportSingleBill(nOrg_ID IN NUMBER,nTop_ID IN NUMBER,
                           COPY_CHILD_MODELS IN VARCHAR2,
                           REFRESH_MODEL_ID IN NUMBER,
                           COPY_ROOT_MODEL   IN VARCHAR2,
                           sExpl_type IN VARCHAR2,dRev_date IN DATE,
                           x_run_id OUT NOCOPY NUMBER) IS

   TYPE tUIDetailedTypeTbl IS TABLE OF CZ_UI_TYPEDPSN_V.detailed_type_id%TYPE INDEX BY VARCHAR2(15);-- kdande; Bug 6885757; 12-Mar-2008

   genRun_ID        PLS_INTEGER;
   nCommit_size     PLS_INTEGER DEFAULT 1;
   nMax_err         PLS_INTEGER DEFAULT 10000;
   sTableName       CZ_XFR_TABLES.DST_TABLE%TYPE;
   xERROR           BOOLEAN:=FALSE;
   nRunExploder     PLS_INTEGER;
   cFound           CHAR(1);
   dDateFormat      VARCHAR2(40);
   sVersion         CZ_DB_SETTINGS.VALUE%TYPE;
   server_id        cz_servers.server_local_id%TYPE;
   nModelId         NUMBER;
   topModelId       NUMBER;
   genStatisticsBom PLS_INTEGER;
   genStatisticsCz  PLS_INTEGER;
   st_time          number;
   end_time         number;
   extract_st       number;
   extract_end      number;
   d_str            varchar2(255);
   l_failed         NUMBER :=0;
   l_msg_tmp        varchar2(2000);
   l_lang           VARCHAR2(4);
   l_compare_detailed_types BOOLEAN;
   l_current_date           DATE;
   l_detailed_types_tbl     tUIDetailedTypeTbl;
   l_update_model_timestamp BOOLEAN := FALSE;


   CURSOR C_EXTRACTION_ORDER IS
    SELECT DST_TABLE FROM CZ_XFR_TABLES
    WHERE XFR_GROUP='EXTRACT' AND DISABLED='0'
    AND DST_TABLE IN ('CZ_ITEM_TYPES','CZ_PROPERTIES','CZ_ITEM_TYPE_PROPERTIES',
        'CZ_ITEM_MASTERS','CZ_ITEM_PROPERTY_VALUES','CZ_LOCALIZED_TEXTS','CZ_DEVL_PROJECTS')
    ORDER BY ORDER_SEQ;
   CURSOR C_IMPORT_ORDER IS
    SELECT DST_TABLE FROM CZ_XFR_TABLES
    WHERE XFR_GROUP='IMPORT' AND DISABLED='0'
    AND DST_TABLE IN ('CZ_ITEM_TYPES','CZ_PROPERTIES','CZ_ITEM_TYPE_PROPERTIES',
        'CZ_ITEM_MASTERS','CZ_ITEM_PROPERTY_VALUES','CZ_LOCALIZED_TEXTS','CZ_DEVL_PROJECTS',
        'CZ_PS_NODES')
    ORDER BY ORDER_SEQ;
   CURSOR C_BILL_OF_MATERIAL IS
    SELECT 'F' FROM CZ_EXV_BILL_OF_MATERIALS
    WHERE ORGANIZATION_ID=nOrg_ID AND ASSEMBLY_ITEM_ID=nTop_ID;
   NOUPDATE_SOURCE_BILL_DELETED NUMBER;

   CZ_LANGUAGES_DO_NOT_MATCH  EXCEPTION;

   l_msg_data		 VARCHAR2(2000);
   l_msg_count		 NUMBER := 0;
   l_return_status	 VARCHAR2(1);
   l_locked_models 	 cz_security_pvt.number_type_tbl;
   l_checkout_user 	 cz_security_pvt.varchar_type_tbl;
   HAS_NO_PRIV	         EXCEPTION;
   PRIV_CHECK_ERR	 EXCEPTION;
   FAILED_TO_LOCK_MODEL  EXCEPTION;

   v_settings_id         VARCHAR2(40);
   v_section_name        VARCHAR2(30);
   v_enabled             VARCHAR2(1) := '1';

BEGIN

  IF (REFRESH_MODEL_ID IS NULL OR REFRESH_MODEL_ID=-1) THEN
    BEGIN
      SELECT NVL(d.config_engine_type,'L') INTO g_CONFIG_ENGINE_TYPE
        FROM cz_xfr_project_bills p, cz_devl_projects d
      WHERE p.organization_id = nOrg_ID
        AND p.top_item_id = nTop_ID
        AND p.explosion_type = sExpl_type
        AND d.deleted_flag = '0'
        AND d.devl_project_id = d.persistent_project_id
        AND p.model_ps_node_id = d.devl_project_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         g_CONFIG_ENGINE_TYPE := FND_PROFILE.VALUE('CZ_CONFIG_ENGINE_NEW_MODELS');
    END;
  ELSE
    SELECT NVL(config_engine_type,'L') INTO g_CONFIG_ENGINE_TYPE FROM CZ_DEVL_PROJECTS
     WHERE devl_project_id=REFRESH_MODEL_ID;
  END IF;

  CZ_ADMIN.SPX_SYNC_IMPORTSESSIONS;
  DBMS_APPLICATION_INFO.SET_MODULE('CZIMPORT','');

  BEGIN
   SELECT server_local_id INTO server_id
     FROM cz_servers
    WHERE import_enabled = v_enabled;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS'),1,'CZ_IMP_ALL.ImportSingleBill',11276);
      RAISE CZ_ADMIN.IMP_TOO_MANY_SERVERS;
    WHEN NO_DATA_FOUND THEN
      xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_NO_IMP_SERVERS'),1,'CZ_IMP_ALL.ImportSingleBill',11276);
     RAISE CZ_ADMIN.IMP_NO_IMP_SERVER;
  END;

  IF(server_id > 0)THEN
    IF(CZ_UTILS.check_installed_lang(server_id) <> 0)THEN
      xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_LANGUAGES_DO_NOT_MATCH'),1,'CZ_IMP_ALL.ImportSingleBill',11276);
      RAISE CZ_ADMIN.CZ_LANGUAGES_DO_NOT_MATCH;
    END IF;
  END IF;

   --Determines whether unchanged child models should be refreshed during this run, default - YES.

   v_settings_id := 'IMPORTCHILDMODEL';
   v_section_name := 'IMPORT';

   BEGIN
        SELECT decode(upper(VALUE),'TRUE','1','FALSE','0','T','1','F','0','1','1','0','0','YES','1','NO','0','Y','1','N','0','1')
        INTO importUnchangedChildModels FROM CZ_DB_SETTINGS
        WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
   EXCEPTION
     WHEN OTHERS THEN
       importUnchangedChildModels := 1;
   END;

   --Generate statistics on BOM_EXPLOSIONS after root explosion, default - NO.

   v_settings_id := 'GENSTATISTICSBOM';
   v_section_name := 'IMPORT';

   BEGIN
        SELECT decode(upper(VALUE),'TRUE','1','FALSE','0','T','1','F','0','1','1','0','0','YES','1','NO','0','Y','1','N','0','0')
        INTO genStatisticsBom FROM CZ_DB_SETTINGS
        WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
   EXCEPTION
     WHEN OTHERS THEN
       genStatisticsBom := 0;
   END;

   --Generate statistics on IMPORT tables after extraction, default - NO.

   v_settings_id := 'GENSTATISTICSCZ';
   v_section_name := 'IMPORT';

   BEGIN
        SELECT decode(upper(VALUE),'TRUE','1','FALSE','0','T','1','F','0','1','1','0','0','YES','1','NO','0','Y','1','N','0','0')
        INTO genStatisticsCz FROM CZ_DB_SETTINGS
        WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
   EXCEPTION
     WHEN OTHERS THEN
       genStatisticsCz := 0;
   END;

   --Relaxing decimal quantity restriction for Pella. If this setting is set to 'YES', BOM indivisible_flag will be imported not
   --only for Standard Items (the default behavior), but also for Option Classes.
   --This setting must be present and set to 'YES' to change the default behavior.
   --Bug #4717871.

   v_settings_id := 'ALLOWDECIMALOPTIONCLASS';
   v_section_name := 'IMPORT';

   BEGIN
        SELECT decode(upper(VALUE),'TRUE',1,'FALSE',0,'T',1,'F',0,'1',1,'0',0,'YES',1,'NO',0,'Y',1,'N',0,0)
        INTO allowDecimalOptionClass FROM CZ_DB_SETTINGS
        WHERE upper(SETTING_ID)=v_settings_id AND SECTION_NAME=v_section_name;
   EXCEPTION
     WHEN OTHERS THEN
       allowDecimalOptionClass := 0;
   END;

  BEGIN
   SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO genRun_ID FROM DUAL;
   INSERT INTO CZ_XFR_RUN_INFOS (RUN_ID,STARTED,LAST_ACTIVITY,COMPLETED)
   VALUES (genRun_ID,SYSDATE,SYSDATE,'0');
   x_run_id := genRun_ID;
  EXCEPTION
    WHEN OTHERS THEN
      d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
      xERROR:=cz_utils.log_report(d_str,1,'SINGLEBILL:CZ_XFR_RUN_INFOS',11276,genRun_ID);
      RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
  END;
  COMMIT;

----1) Run the BOM EXPLODER for the specified bills which are not deleted

       v_settings_id := 'RUN_BILL_EXPLODER';
       v_section_name := 'ORAAPPS_INTEGRATE';

       BEGIN
        SELECT DECODE(UPPER(value), 'YES', 1, 'Y', 1, '1', 1, 'TRUE', 1, 'T', 1,
                                    'NO', 0, 'N', 0, '0', 0, 'FALSE', 0, 'F', 0,
                                    0)
       INTO nRunExploder FROM CZ_DB_SETTINGS
        WHERE UPPER(SECTION_NAME) = v_section_name
          AND UPPER(SETTING_ID) = v_settings_id;
       EXCEPTION
         WHEN OTHERS THEN
           nRunExploder:=0;
       END;

       v_settings_id := 'BOM_REVISION';
       v_section_name := 'ORAAPPS_INTEGRATE';

       BEGIN
        SELECT VALUE INTO sVersion FROM CZ_DB_SETTINGS
        WHERE UPPER(SECTION_NAME) = v_section_name
          AND UPPER(SETTING_ID) = v_settings_id;
       EXCEPTION
         WHEN OTHERS THEN
           sVersion:='11.5.0';
       END;

       SELECT DECODE(SUBSTR(sVersion,1,INSTR(sVersion,'.',1,2)-1),
                 '11.5','YYYY/MM/DD HH24:MI','DD-MON-RR HH24:MI')
       INTO dDateFormat FROM DUAL;

       BEGIN

        v_settings_id := 'COMMITSIZE';
        v_section_name := 'IMPORT';

        SELECT VALUE INTO nCommit_size FROM CZ_DB_SETTINGS
        WHERE UPPER(SETTING_ID) = v_settings_id
          AND UPPER(SECTION_NAME) = v_section_name;

        v_settings_id := 'MAXIMUMERRORS';
        v_section_name := 'IMPORT';

        SELECT VALUE INTO nMax_err FROM CZ_DB_SETTINGS
        WHERE UPPER(SETTING_ID) = v_settings_id
          AND UPPER(SECTION_NAME) = v_section_name;
       EXCEPTION
         WHEN OTHERS THEN
           xERROR:=cz_utils.log_report(SQLERRM,1,'SINGLEBILL:COMMITSIZE',11276,x_run_id);
       END;

       NOUPDATE_SOURCE_BILL_DELETED:=CZ_UTILS.GET_NOUPDATE_FLAG('CZ_XFR_PROJECT_BILLS','SOURCE_BILL_DELETED', 'IMPORT');
       BEGIN
        OPEN C_BILL_OF_MATERIAL;
        FETCH C_BILL_OF_MATERIAL INTO cFound;
        IF(C_BILL_OF_MATERIAL%FOUND)THEN

        if (CZ_IMP_ALL.get_time) then
            extract_st := dbms_utility.get_time();
        end if;

	     -- Clear processed_expl_tbl before and after ps node extraction.
	    processed_expls_tbl.DELETE;
            nModelId := ExtractPsNode(genRun_ID, nOrg_ID, nTop_ID, sExpl_type, server_id, nRunExploder,
                                    dRev_date, dDateFormat, REFRESH_MODEL_ID, COPY_ROOT_MODEL, COPY_CHILD_MODELS,
                                    genStatisticsBom);
	    processed_expls_tbl.DELETE;
----------deep-lock the model if it exists
            FOR j IN (SELECT devl_project_id FROM cz_devl_projects
                      WHERE devl_project_id = nModelId AND deleted_flag='0')
            LOOP
                        cz_security_pvt.lock_model(
                                        p_api_version          =>   1.0,
					p_model_id             =>   nModelId,
					p_lock_child_models    =>   FND_API.G_TRUE,
					p_commit_flag          =>   FND_API.G_TRUE,
					x_locked_entities      =>   l_locked_models,
					x_return_status        =>   l_return_status,
					x_msg_count            =>   l_msg_count,
					x_msg_data             =>   l_msg_data);
                        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                          FOR i IN 1..l_msg_count LOOP
                             l_msg_data  := fnd_msg_pub.GET(i,fnd_api.g_false);
                             xERROR:=cz_utils.log_report(l_msg_data,1,'CZ_IMP_SINGLE.IMPORTSINGLEBILL',20001,genRun_ID);
                          END LOOP;
                          RAISE FAILED_TO_LOCK_MODEL;
      	                END IF;
            END LOOP;

        if (CZ_IMP_ALL.get_time) then
            extract_end := dbms_utility.get_time();
            d_str := genRun_Id || ' EXTRACT PS - TOTAL (' || nTop_Id || ') :' || (extract_end-extract_st)/100.00;
            xERROR:=cz_utils.log_report(d_str,1,'EXTRACT_PS_NODE',11299,genRun_ID);
        end if;

        IF(CZ_ORAAPPS_INTEGRATE.mRETCODE = 2)THEN RETURN; END IF;

          UPDATE CZ_XFR_PROJECT_BILLS SET
           SOURCE_BILL_DELETED=DECODE(NOUPDATE_SOURCE_BILL_DELETED,0,'0',SOURCE_BILL_DELETED)
          WHERE ORGANIZATION_ID=nOrg_ID AND TOP_ITEM_ID=nTop_ID AND EXPLOSION_TYPE=sExpl_type;
        ELSE
          UPDATE CZ_XFR_PROJECT_BILLS SET
           SOURCE_BILL_DELETED=DECODE(NOUPDATE_SOURCE_BILL_DELETED,0,'1',SOURCE_BILL_DELETED)
          WHERE ORGANIZATION_ID=nOrg_ID AND TOP_ITEM_ID=nTop_ID AND EXPLOSION_TYPE=sExpl_type;
        END IF;
        CLOSE C_BILL_OF_MATERIAL;
       EXCEPTION
        WHEN PRIV_CHECK_ERR THEN
         xERROR:=cz_utils.log_report(l_msg_data,1,'SINGLEBILL.GENERAL',20001,genRun_ID);
         DBMS_APPLICATION_INFO.SET_MODULE('','');
         RAISE;
        WHEN HAS_NO_PRIV THEN
         xERROR:=cz_utils.log_report(l_msg_data,1,'SINGLEBILL.GENERAL',20001,genRun_ID);
         DBMS_APPLICATION_INFO.SET_MODULE('','');
         RAISE;
        WHEN FAILED_TO_LOCK_MODEL THEN
         xERROR:=cz_utils.log_report(l_msg_data,1,'SINGLEBILL.GENERAL',20001,genRun_ID);
         COMMIT;
         DBMS_APPLICATION_INFO.SET_MODULE('','');
         RAISE;
        WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
         IF C_BILL_OF_MATERIAL%ISOPEN THEN CLOSE C_BILL_OF_MATERIAL; END IF;
         processed_expls_tbl.DELETE;
         RAISE;
       WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
         RAISE;
        WHEN OTHERS THEN
         IF C_BILL_OF_MATERIAL%ISOPEN THEN CLOSE C_BILL_OF_MATERIAL; END IF;
         processed_expls_tbl.DELETE;
         d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
         xERROR:=cz_utils.log_report(d_str,1,'EXTRACT_PS_NODE',11299,genRun_ID);
         RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
       END;

-------Create the table of all relevant item catalog group ids which will be used for extraction of property related data.

       itemCatalogGroupId.DELETE;
       repCatalogGroupId.DELETE;
       inventoryItemId.DELETE;
       repItemId.DELETE;
       hashCatalog.DELETE;

       if (CZ_IMP_ALL.get_time) then
        st_time := dbms_utility.get_time();
       end if;

       l_lang := userenv('LANG');

       BEGIN
         SELECT item_catalog_group_id, inventory_item_id
           BULK COLLECT INTO repCatalogGroupId, repItemId
           FROM cz_exv_item_master
          WHERE organization_id = nOrg_ID
            AND top_item_id = nTop_ID
            AND explosion_type = sExpl_type
            AND item_catalog_group_id IS NOT NULL
            AND language = l_lang;

         --itemCatalogGroupId should be unique.

         FOR i IN 1..repCatalogGroupId.COUNT LOOP

           IF(NOT hashCatalog.EXISTS(repCatalogGroupId(i)))THEN

             itemCatalogGroupId(itemCatalogGroupId.COUNT + 1) := repCatalogGroupId(i);
             hashCatalog(repCatalogGroupId(i)) := 1;
           END IF;
         END LOOP;

         hashCatalog.DELETE;

         --inventoryItemId should be unique.

         FOR i IN 1..repItemId.COUNT LOOP

           IF(NOT hashCatalog.EXISTS(repItemId(i)))THEN

             inventoryItemId(inventoryItemId.COUNT + 1) := repItemId(i);
             hashCatalog(repItemId(i)) := 1;
           END IF;
         END LOOP;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           xERROR:=cz_utils.log_report(SQLERRM,1,'CZ_IMP_SINGLE.IMPORTSINGLEBILL.CATALOG',11276,genRun_ID);
       END;

       if (CZ_IMP_ALL.get_time) then
         end_time := dbms_utility.get_time();
         d_str := genRun_Id ||' Collect Catalog group id (' || nTop_Id || ') :' || (end_time-st_time)/100.00;
         xERROR:=cz_utils.log_report(d_str,1,'EXTRACTION',11299,genRun_ID);
       end if;

----2) Populate the table for UI refresh using the extracted list of models

       FOR model IN (SELECT DISTINCT component_id FROM cz_model_ref_expls WHERE model_id = nModelId
                        AND deleted_flag = '0' AND (ps_node_type IN (263, 264) OR parent_expl_node_id IS NULL))LOOP

        FOR j IN (SELECT devl_project_id FROM cz_devl_projects
                  WHERE devl_project_id = model.component_id AND deleted_flag='0')
        LOOP
            l_compare_detailed_types := TRUE;
            l_current_date := SYSDATE;
            FOR i IN (SELECT ps_node_id, detailed_type_id
                      FROM  CZ_UI_TYPEDPSN_V
                      WHERE devl_project_Id  = model.component_id
                      AND ps_node_type IN (CZ_TYPES.PS_NODE_TYPE_BOM_MODEL, CZ_TYPES.PS_NODE_TYPE_BOM_OPTION_CLASS)
                      AND deleted_flag = '0')
            LOOP
                l_detailed_types_tbl(i.ps_node_id) := i.detailed_type_id;
            END LOOP;
        END LOOP;
       END LOOP;

----3) Call all the extract procedures in the order specified by ORDER_SEQ field of CZ_XFR_TABLES with XFR_GROUP='EXTRACT'

       OPEN C_EXTRACTION_ORDER;
       LOOP
        BEGIN
         FETCH C_EXTRACTION_ORDER INTO sTableName;
         EXIT WHEN C_EXTRACTION_ORDER%NOTFOUND;

         extract_table(genRun_ID, sTableName, nOrg_ID, nTop_ID, sExpl_type, nModelId);

         EXCEPTION
           WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
             RAISE;
           WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
             RAISE;
           WHEN NO_DATA_FOUND THEN
             xERROR:=cz_utils.log_report(sTableName||':'||SQLERRM,1,'CZ_IMP_SINGLE.IMPORTSINGLEBILL.extract_table',11276,genRun_ID);
           WHEN OTHERS THEN
             d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
             xERROR:=cz_utils.log_report(d_str,1,'SINGLEBILL:EXTRACTION',11276,genRun_ID);
             RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
        END;
       END LOOP;
       CLOSE C_EXTRACTION_ORDER;

----3.5 Gather statistics on IMPORT so that best possible plans are used during key resolution and transfer.

       IF(genStatisticsCz = 1)THEN
         FOR i IN (SELECT src_table FROM cz_xfr_tables
                   WHERE xfr_group='IMPORT'
                   AND disabled='0') LOOP
           fnd_stats.GATHER_TABLE_STATS('CZ',i.src_table);
         END LOOP;
       END IF;

----4) Call all the import procedures in the order specified by ORDER_SEQ field of CZ_XFR_TABLES with XFR_GROUP='IMPORT'

       OPEN C_IMPORT_ORDER;
       LOOP
        BEGIN
         FETCH C_IMPORT_ORDER INTO sTableName;
         EXIT WHEN C_IMPORT_ORDER%NOTFOUND;
         populate_table(genRun_ID, sTableName, nCommit_size, nMax_err, 'IMPORT', CZ_IMP_SINGLE.RP_ROOT_FOLDER, l_failed);
        EXCEPTION
          WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
            RAISE;
          WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
            RAISE;
          WHEN NO_DATA_FOUND THEN
             xERROR:=cz_utils.log_report(sTableName||':'||SQLERRM,1,'CZ_IMP_SINGLE.IMPORTSINGLEBILL.populate_table',11276,genRun_ID);
          WHEN OTHERS THEN
            d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
            xERROR:=cz_utils.log_report(d_str,1,'CZ_IMP_SINGLE.GO.IMPORT',11276,genRun_ID);
            RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
        END;
       END LOOP;
       CLOSE C_IMPORT_ORDER;

       --Populate has_trackable_children flag in cz_model_ref_expls. It is sufficient to call the procedure
       --only once for the very root project. For every run_id there is exactly one record in the table for
       --the root project (this is not necessarily true for the child models).
       BEGIN
         SELECT model_ps_node_id INTO nModelId
           FROM cz_xfr_project_bills
          WHERE organization_id = nOrg_ID
            AND top_item_id = nTop_ID
            AND explosion_type = sExpl_type
            AND last_import_run_id = genRun_ID;
       EXCEPTION
        WHEN OTHERS THEN
            xERROR:=cz_utils.log_report(nTop_ID||':'||SQLERRM,1,'CZ_IMP_SINGLE.IMPORTSINGLEBILL.XFRPROJECTS',11276,genRun_ID);
       END;

       BEGIN
         cz_refs.set_Trackable_Children_Flag(nModelId);
       EXCEPTION
        WHEN OTHERS THEN
            xERROR:=cz_utils.log_report(nModelId||':'||SQLERRM,1,'CZ_IMP_SINGLE.IMPORTSINGLEBILL.TRACKABLE',11276,genRun_ID);
       END;

----5) Finally update the (LAST_ACTIVITY,COMPLETED) fields of CZ_XFR_RUN_INFOS
       BEGIN
          UPDATE CZ_XFR_RUN_INFOS SET
          LAST_ACTIVITY=SYSDATE,
          COMPLETED='1'
          WHERE RUN_ID=genRun_ID;
       EXCEPTION
        WHEN OTHERS THEN
            xERROR:=cz_utils.log_report(genRun_ID||':'||SQLERRM,1,'CZ_IMP_SINGLE.IMPORTSINGLEBILL.RUNINFOS',11276,genRun_ID);
       END;

       --DBMS_OUTPUT.PUT_LINE(CZ_UTILS.GET_TEXT('CZ_IMP_IMPORT_COMPLETED','RUNID',TO_CHAR(genRun_ID)));

       IF l_compare_detailed_types THEN

         FOR model IN (SELECT devl_project_id FROM cz_imp_devl_project WHERE run_id = genRun_ID
                          AND rec_status = 'OK')LOOP
           FOR i IN (SELECT ps_node_id, detailed_type_id
                     FROM  CZ_UI_TYPEDPSN_V
                     WHERE devl_project_Id  = model.devl_project_id
                     AND ps_node_type IN (CZ_TYPES.PS_NODE_TYPE_BOM_MODEL, CZ_TYPES.PS_NODE_TYPE_BOM_OPTION_CLASS)
                     AND creation_date <= l_current_date
                     AND deleted_flag = '0')
           LOOP
               IF l_detailed_types_tbl.EXISTS( i.ps_node_id ) THEN
                   IF l_detailed_types_tbl(i.ps_node_id) <> i.detailed_type_id THEN

                       UPDATE CZ_PS_NODES set UI_TIMESTAMP_CHANGETYPE = SYSDATE
                       WHERE devl_project_id = model.devl_project_id
                       AND ps_node_id = i.ps_node_id;

                       l_update_model_timestamp := TRUE;

                   END IF;
               END IF;
           END LOOP;

           IF l_update_model_timestamp THEN
             UPDATE cz_devl_projects set ui_timestamp_struct_update = SYSDATE
             WHERE devl_project_id = model.devl_project_id;
           END IF;
         END LOOP;
       END IF;

       COMMIT;
       DBMS_APPLICATION_INFO.SET_MODULE('','');

----6) Unlock model
       IF ( l_locked_models.COUNT > 0 ) THEN
         BEGIN
            cz_security_pvt.unlock_model(
                                        p_api_version         =>   1.0,
					p_commit_flag         =>   FND_API.G_TRUE,
					p_models_to_unlock    =>   l_locked_models,
					x_return_status       =>   l_return_status,
					x_msg_count           =>   l_msg_count,
					x_msg_data            =>   l_msg_data);
         EXCEPTION
          WHEN OTHERS THEN
           xERROR:=cz_utils.log_report(nModelId||':'||SQLERRM,1,'CZ_IMP_SINGLE.IMPORTSINGLEBILL.UNLOCK',11276,genRun_ID);
         END;
       END IF;
EXCEPTION
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
    RAISE;
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
    xERROR:=cz_utils.log_report(CZ_UTILS.GET_TEXT('CZ_IMP_ACTIVE_SESSION_EXISTS'),1,'SINGLEBILL.GENERAL',11276,genRun_ID);
    DBMS_APPLICATION_INFO.SET_MODULE('','');
    RAISE;
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    RAISE;
  WHEN NO_DATA_FOUND THEN
    xERROR:=cz_utils.log_report(SQLERRM,1,'SINGLEBILL.GENERAL',11276,genRun_ID);
  WHEN OTHERS THEN
    IF ( l_locked_models.COUNT > 0 ) THEN
        BEGIN
            cz_security_pvt.unlock_model(
                                        p_api_version         =>   1.0,
					p_commit_flag         =>   FND_API.G_TRUE,
					p_models_to_unlock    =>   l_locked_models,
					x_return_status       =>   l_return_status,
					x_msg_count           =>   l_msg_count,
					x_msg_data            =>   l_msg_data);
        EXCEPTION
         WHEN OTHERS THEN
           xERROR:=cz_utils.log_report(nModelId||':'||SQLERRM,1,'SINGLEBILL.GENERAL.unlock',11276,genRun_ID);
        END;
    END IF;
    d_str:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
    xERROR:=cz_utils.log_report(d_str,1,'SINGLEBILL.GENERAL',11276,genRun_ID);
    DBMS_APPLICATION_INFO.SET_MODULE('','');
    RAISE CZ_ADMIN.IMP_UNEXP_SQL_ERROR;
END ImportSingleBill;
------------------------------------------------------------------------------------------

END CZ_IMP_SINGLE;

/
