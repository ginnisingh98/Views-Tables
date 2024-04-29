--------------------------------------------------------
--  DDL for Package Body INVNIRIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVNIRIS" AS
/* $Header: INVNIRIB.pls 120.32.12010000.2 2008/09/17 12:40:19 bparthas ship $ */
------------------------ validate_item_revs -----------------------------------

FUNCTION mtl_validate_nir_item
(
org_id          number,
all_org         NUMBER,
prog_appid      NUMBER,
prog_id         NUMBER,
request_id      NUMBER,
user_id         NUMBER,
login_id        NUMBER,
xset_id  IN     NUMBER,
err_text in out NOCOPY varchar2
)
RETURN INTEGER
IS
   LOGGING_ERR Exception;
   status    NUMBER;
   l_sysdate DATE  ;
   l_nir_rec_exists BOOLEAN;
   l_flag_error NUMBER;
   l_item_approval_status mtl_system_items_b.approval_status%TYPE; --Bug 4418037
   l_dumm_status NUMBER;
   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
   l_err_text VARCHAR2(1000);

 /* R12C : Changing the New Item Req Reqd = 'Y' sub-query for hierarchy enabled Catalogs */
   CURSOR c_get_processed_records(cp_process_flag NUMBER) IS
      SELECT msii.INVENTORY_ITEM_ID,
             msii.ITEM_CATALOG_GROUP_ID,
             msii.ORGANIZATION_ID,
             msii.TRANSACTION_ID,
             msii.ITEM_NUMBER,
             msii.rowid,
             msii.ENG_ITEM_FLAG,
       --    micb.NEW_ITEM_REQ_CHANGE_TYPE_ID,
             mp.ORGANIZATION_CODE,
	          mp.MASTER_ORGANIZATION_ID,
             msii.TRANSACTION_TYPE
       FROM  MTL_SYSTEM_ITEMS_INTERFACE msii,
             --MTL_ITEM_CATALOG_GROUPS_B  micb,
             MTL_PARAMETERS mp
      WHERE  ( (msii.organization_id + 0 = org_id) OR (all_Org = 1) )
        AND  msii.process_flag = cp_process_flag
        AND  msii.set_process_id = xset_id
        --AND  msii.ITEM_CATALOG_GROUP_ID = micb.ITEM_CATALOG_GROUP_ID
        --AND  micb.NEW_ITEM_REQUEST_REQD = 'Y'
        AND  mp.ORGANIZATION_ID = msii.ORGANIZATION_ID
        FOR UPDATE OF msii.INVENTORY_ITEM_ID;

/* R12C : Introducing cursor for hierarchy enabled Catalogs */
   CURSOR c_nir_reqd (cp_item_catalog_group_id IN NUMBER)
   IS
      SELECT  ICC.NEW_ITEM_REQUEST_REQD
        FROM  MTL_ITEM_CATALOG_GROUPS_B ICC
       WHERE  ICC.NEW_ITEM_REQUEST_REQD IS NOT NULL
         AND  ICC.NEW_ITEM_REQUEST_REQD <> 'I'
     CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
       START WITH ICC.ITEM_CATALOG_GROUP_ID = cp_item_catalog_group_id
       ORDER BY LEVEL ASC;

   --4676583 : Honouring batch option - Add All Imported Items to Change Order
   CURSOR c_get_batch_policy IS
      SELECT NVL(add_all_to_change_flag,'N')
      FROM   ego_import_option_sets
      WHERE  batch_id = xset_id;

   l_import_co_option  VARCHAR2(1) := 'N';
   l_nir_reqd          VARCHAR2(1) := 'N';

BEGIN
   status    := 0;
   l_sysdate := sysdate;
   l_nir_rec_exists := false;

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVNIRIS: first sta..set_id'||to_char(xset_id)||'org'||to_char(org_id)||'all'||to_char(all_org));
   END IF;

   FOR cur in c_get_processed_records(cp_process_flag=>2) LOOP
   /* R12C : Retrieving NIR reqd for hierarchy enabled Catalogs */
      l_nir_reqd := 'N';

      OPEN  c_nir_reqd(cp_item_catalog_group_id => cur.item_catalog_group_id);
      FETCH c_nir_reqd INTO l_nir_reqd;
      CLOSE c_nir_reqd;

      IF l_nir_reqd = 'Y' THEN
        l_flag_error := 0;
      --Start : Child Items for a master item which is unapproved cannot be created.
        IF cur.TRANSACTION_TYPE =  'UPDATE' THEN

           BEGIN
              SELECT approval_status
                INTO l_item_approval_status
                FROM mtl_system_items_b
               WHERE inventory_item_id = cur.INVENTORY_ITEM_ID
                 AND organization_id   = cur.ORGANIZATION_ID;
           EXCEPTION
             WHEN OTHERS THEN
 	             l_item_approval_status := 'N';
           END;

        ELSIF cur.TRANSACTION_TYPE = 'CREATE' THEN

          IF cur.organization_id <> cur.master_organization_id THEN

             BEGIN
                SELECT msi.approval_status
	             INTO l_item_approval_status
                FROM mtl_system_items_b msi
                WHERE msi.inventory_item_id = cur.inventory_item_id
                AND msi.organization_id     = (SELECT mp.master_organization_id
                                               FROM mtl_parameters mp
                                               WHERE mp.organization_id = cur.organization_id);
             EXCEPTION
                WHEN OTHERS THEN
                   l_item_approval_status := 'N';
             END;

             IF l_item_approval_status <> 'A' THEN
                UPDATE mtl_system_items_interface
                SET process_flag   = 3
                WHERE CURRENT OF c_get_processed_records;

 	             l_dumm_status := INVPUOPI.mtl_log_interface_err (
                        -1,
                        user_id,
                        login_id,
                        prog_appid,
                        prog_id,
                        request_id,
                        cur.transaction_id,
                        'Unapproved Item cannot be assigned to a child org',
                        'APPROVAL_STATUS',
                        'MTL_SYSTEM_ITEMS_INTERFACE',
                        'INV_NIR_NO_APPROVE',
                        l_err_text);
  	             IF l_dumm_status < 0 then
                  raise LOGGING_ERR;
                END IF;
	             l_flag_error := 1;
             END IF;
          END IF;
        END IF;

        IF ( l_flag_error = 0 ) THEN
          IF (((cur.TRANSACTION_TYPE = 'CREATE') AND (cur.organization_id = cur.master_organization_id))
             OR((cur.TRANSACTION_TYPE = 'UPDATE') AND (NVL(l_item_approval_status, 'A') <> 'A')))
          THEN
             l_nir_rec_exists := true;

             UPDATE MTL_SYSTEM_ITEMS_INTERFACE I
             SET I.SET_PROCESS_ID                 = I.SET_PROCESS_ID + 3000000000000,
 	              I.ENG_ITEM_FLAG                  = 'Y', --Bug 5519768
                 I.SUMMARY_FLAG                   = 'Y',
                 I.ENABLED_FLAG                   = 'Y',
                 I.BUYER_ID                       = NULL,
                 I.ACCOUNTING_RULE_ID             = NULL,
                 I.INVOICING_RULE_ID              = NULL,
                 I.COLLATERAL_FLAG                = NULL,
                 I.STOCK_ENABLED_FLAG             = 'N',
                 I.MTL_TRANSACTIONS_ENABLED_FLAG  = 'N',
                 I.INTERNAL_ORDER_ENABLED_FLAG    = 'N',
                 I.INVOICE_ENABLED_FLAG           = 'N',
	      -- Bug 5738958: BOM Allowed Flag can be updated even when Item Status is Pending
              -- I.BOM_ENABLED_FLAG               = 'N',
                 I.BUILD_IN_WIP_FLAG              = 'N',
                 I.CUSTOMER_ORDER_ENABLED_FLAG    = 'N',
                 I.PURCHASING_ENABLED_FLAG        = 'N',
                 I.INVENTORY_ITEM_FLAG            = 'N',
                 I.WIP_SUPPLY_TYPE                = 1,
                 I.AUTO_CREATED_CONFIG_FLAG       = 'N',
                 I.CYCLE_COUNT_ENABLED_FLAG       = 'N',
                 I.INTERNAL_ORDER_FLAG            = 'N',
                 I.INVENTORY_ITEM_STATUS_CODE     = 'Pending',
                 I.INVENTORY_PLANNING_CODE        = 6,
                 I.MRP_PLANNING_CODE              = 6,
                 I.INVENTORY_ASSET_FLAG           = 'N',
                 I.INVOICEABLE_ITEM_FLAG          = 'N',
                 I.EXPENSE_BILLABLE_FLAG          = NULL,
                 I.BOM_ITEM_TYPE                  = 4,
                 I.COSTING_ENABLED_FLAG           = 'N',
                 I.CUSTOMER_ORDER_FLAG            = 'N',
                 -- I.ALLOWED_UNITS_LOOKUP_CODE      = 3, --BUG 7255713
                 I.ATP_COMPONENTS_FLAG            = 'N',
                 I.ATP_FLAG                       = 'N',
                 I.TIME_BILLABLE_FLAG             = NULL,
                 I.SERVICEABLE_PRODUCT_FLAG       = 'N',
                 I.SHELF_LIFE_CODE                = 1,
                 I.SHIPPABLE_ITEM_FLAG            = 'N',
                 I.SO_TRANSACTIONS_FLAG           = 'N',
                 I.SERVICEABLE_COMPONENT_FLAG     = 'N',
                 I.REPLENISH_TO_ORDER_FLAG        = 'N',
                 I.RESERVABLE_TYPE                = 1,
                 I.RESTRICT_LOCATORS_CODE         = 2,
                 I.RESTRICT_SUBINVENTORIES_CODE   = 2,
                 I.REVISION_QTY_CONTROL_CODE      = 1,
                 I.SERIAL_NUMBER_CONTROL_CODE     = 1,
                 I.PREVENTIVE_MAINTENANCE_FLAG    = 'N',
                 I.SERV_BILLING_ENABLED_FLAG      = 'N',
                 I.PRORATE_SERVICE_FLAG           = 'N',
                 I.PURCHASING_ITEM_FLAG           = 'N',
                 I.OUTSIDE_OPERATION_FLAG         = 'N',
                 I.PICK_COMPONENTS_FLAG           = 'N',
                 I.PLANNING_MAKE_BUY_CODE         = 2,
                 I.PLANNING_TIME_FENCE_CODE       = 4,
                 I.PLANNING_TIME_FENCE_DAYS       = 1,
                 I.MUST_USE_APPROVED_VENDOR_FLAG  = 'N',
                 I.LOCATION_CONTROL_CODE          = 1,
                 I.LOT_CONTROL_CODE               = 1,
                 I.MRP_SAFETY_STOCK_CODE          = 1,
                 I.SHIP_MODEL_COMPLETE_FLAG       = 'N',
                 I.MARKET_PRICE                   = NULL,
                 I.LIST_PRICE_PER_UNIT            = NULL,
                 I.PRICE_TOLERANCE_PERCENT        = NULL,
                 I.SHELF_LIFE_DAYS                = 0,
                 I.REPETITIVE_PLANNING_FLAG       = 'N',
                 I.ACCEPTABLE_RATE_DECREASE       = 0,
                 I.ACCEPTABLE_RATE_INCREASE       = 0,
                 I.POSTPROCESSING_LEAD_TIME       = 0,
                 I.RETURN_INSPECTION_REQUIREMENT  = 2,
                 I.CONTAINER_ITEM_FLAG            = 'N',
                 I.VEHICLE_ITEM_FLAG              = 'N',
                 I.SERVICE_DURATION               = NULL,
                 I.RETURNABLE_FLAG                = 'N',
                 I.LEAD_TIME_LOT_SIZE             = 1,
                 I.CHECK_SHORTAGES_FLAG           = 'N',
                 I.EFFECTIVITY_CONTROL            = 1,
                 I.EQUIPMENT_TYPE                 = 2,
                 I.COMMS_NL_TRACKABLE_FLAG        = NULL,
                 I.WEB_STATUS                     = 'UNPUBLISHED',
                 I.BULK_PICKED_FLAG               = 'N',
                 I.LOT_STATUS_ENABLED             = 'N',
                 I.DEFAULT_LOT_STATUS_ID          = NULL,
                 I.SERIAL_STATUS_ENABLED          = 'N',
                 I.DEFAULT_SERIAL_STATUS_ID       =  NULL,
                 I.DUAL_UOM_CONTROL               = 1,
                 I.LOT_SPLIT_ENABLED              = 'N',
                 I.LOT_MERGE_ENABLED              = 'N',
                 I.LOT_TRANSLATE_ENABLED          = 'N',
                 I.DEFAULT_SO_SOURCE_TYPE         = 'INTERNAL',
                 I.CREATE_SUPPLY_FLAG             = 'Y',
                 -- I.TRACKING_QUANTITY_IND          = 'P', --BUG 7255713
                 -- I.ONT_PRICING_QTY_SOURCE         = 'P', --BUG 7255713
                 -- I.DUAL_UOM_DEVIATION_HIGH        = 0, --BUG 7255713
                 -- I.DUAL_UOM_DEVIATION_LOW         = 0, --BUG 7255713
                 I.VMI_MINIMUM_UNITS              = NULL,
                 I.VMI_MINIMUM_DAYS               = NULL,
                 I.VMI_MAXIMUM_UNITS              = NULL,
                 I.VMI_MAXIMUM_DAYS               = NULL,
                 I.VMI_FIXED_ORDER_QUANTITY       = NULL,
                 I.SO_AUTHORIZATION_FLAG          = NULL,
                 I.CONSIGNED_FLAG                 = 2,
                 I.ASN_AUTOEXPIRE_FLAG            = 2,
                 I.VMI_FORECAST_TYPE              = 1,
                 I.FORECAST_HORIZON               = NULL,
                 I.EXCLUDE_FROM_BUDGET_FLAG       = 2,
                 I.DAYS_TGT_INV_SUPPLY            = NULL,
                 I.DAYS_TGT_INV_WINDOW            = NULL,
                 I.DAYS_MAX_INV_SUPPLY            = NULL,
                 I.DAYS_MAX_INV_WINDOW            = NULL,
                 I.DRP_PLANNED_FLAG               = 2,
                 I.CRITICAL_COMPONENT_FLAG        = 2,
                 I.CONTINOUS_TRANSFER             = 3,
                 I.CONVERGENCE                    = 3,
                 I.DIVERGENCE                     = 3,
                 I.ACCEPTABLE_EARLY_DAYS          = NULL,
                 I.ALLOW_EXPRESS_DELIVERY_FLAG    = NULL,
                 I.ALLOW_SUBSTITUTE_RECEIPTS_FLAG = NULL,
                 I.ALLOW_UNORDERED_RECEIPTS_FLAG  = NULL,
                 I.ASSET_CATEGORY_ID              = NULL,
                 I.ASSET_CREATION_CODE            = NULL,
                 I.ATO_FORECAST_CONTROL           = NULL,
                 I.ATP_RULE_ID                    = NULL,
                 I.AUTO_LOT_ALPHA_PREFIX          = NULL,
                 I.AUTO_REDUCE_MPS                = NULL,
                 I.AUTO_SERIAL_ALPHA_PREFIX       = NULL,
                 I.BACK_ORDERABLE_FLAG            = NULL,
                 I.BASE_ITEM_ID                   = NULL,
                 I.BASE_WARRANTY_SERVICE_ID       = NULL,
                 I.CARRYING_COST                  = NULL,
                 I.CATALOG_STATUS_FLAG            = NULL,
                 I.COMMS_ACTIVATION_REQD_FLAG     = NULL,
                 I.CONFIG_MATCH                   = NULL,
                 I.CONFIG_MODEL_TYPE              = NULL,
                 I.CONFIG_ORGS                    = NULL,
                 I.CONTAINER_TYPE_CODE            = NULL,
                 I.CONTRACT_ITEM_TYPE_CODE        = NULL,
                 I.COUPON_EXEMPT_FLAG             = NULL,
                 I.COVERAGE_SCHEDULE_ID           = NULL,
                 I.CUM_MANUFACTURING_LEAD_TIME    = NULL,
                 I.CUMULATIVE_TOTAL_LEAD_TIME     = NULL,
                 I.DAYS_EARLY_RECEIPT_ALLOWED     = NULL,
                 I.DAYS_LATE_RECEIPT_ALLOWED      = NULL,
                 I.DEFAULT_INCLUDE_IN_ROLLUP_FLAG = NULL,
                 I.DEFAULT_SHIPPING_ORG           = NULL,
                 I.DEFECT_TRACKING_ON_FLAG        = NULL,
                 I.DEMAND_TIME_FENCE_CODE         = NULL,
                 I.DEMAND_TIME_FENCE_DAYS         = NULL,
                 I.DIMENSION_UOM_CODE             = NULL,
                 I.DOWNLOADABLE_FLAG              = NULL,
                 I.EAM_ACT_NOTIFICATION_FLAG      = NULL,
                 I.EAM_ACT_SHUTDOWN_STATUS        = NULL,
                 I.EAM_ACTIVITY_CAUSE_CODE        = NULL,
                 I.EAM_ACTIVITY_SOURCE_CODE       = NULL,
                 I.EAM_ACTIVITY_TYPE_CODE         = NULL,
                 I.EAM_ITEM_TYPE                  = NULL,
                 I.ELECTRONIC_FLAG                = NULL,
                 I.END_ASSEMBLY_PEGGING_FLAG      = NULL,
                 I.END_DATE_ACTIVE                = NULL,
                 I.ENFORCE_SHIP_TO_LOCATION_CODE  = NULL,
                 I.ENGINEERING_DATE               = NULL,
                 I.ENGINEERING_ECN_CODE           = NULL,
                 I.ENGINEERING_ITEM_ID            = NULL,
                 I.EVENT_FLAG                     = NULL,
                 I.FINANCING_ALLOWED_FLAG         = NULL,
                 I.FIXED_DAYS_SUPPLY              = NULL,
                 I.FIXED_LEAD_TIME                = NULL,
                 I.FIXED_LOT_MULTIPLIER           = NULL,
                 I.FIXED_ORDER_QUANTITY           = NULL,
                 I.FULL_LEAD_TIME                 = NULL,
                 I.HAZARD_CLASS_ID                = NULL,
                 I.IB_ITEM_INSTANCE_CLASS         = NULL,
                 I.INDIVISIBLE_FLAG               = NULL,
                 I.INSPECTION_REQUIRED_FLAG       = NULL,
                 I.INTERNAL_VOLUME                = NULL,
                 I.INVENTORY_CARRY_PENALTY        = NULL,
                 I.INVOICE_CLOSE_TOLERANCE        = NULL,
                 I.LOT_SUBSTITUTION_ENABLED       = NULL,
                 I.MATERIAL_BILLABLE_FLAG         = NULL,
                 I.MAX_MINMAX_QUANTITY            = NULL,
                 I.MAX_WARRANTY_AMOUNT            = NULL,
                 I.MAXIMUM_LOAD_WEIGHT            = NULL,
                 I.MAXIMUM_ORDER_QUANTITY         = NULL,
                 I.MIN_MINMAX_QUANTITY            = NULL,
                 I.MINIMUM_FILL_PERCENT           = NULL,
                 I.MINIMUM_LICENSE_QUANTITY       = NULL,
                 I.MINIMUM_ORDER_QUANTITY         = NULL,
                 I.MODEL_CONFIG_CLAUSE_NAME       = NULL,
                 I.MRP_CALCULATE_ATP_FLAG         = NULL,
                 I.MRP_SAFETY_STOCK_PERCENT       = NULL,
                 I.NEGATIVE_MEASUREMENT_ERROR     = NULL,
                 I.OPERATION_SLACK_PENALTY        = NULL,
                 I.ORDER_COST                     = NULL,
                 I.ORDERABLE_ON_WEB_FLAG          = NULL,
                 I.OUTSIDE_OPERATION_UOM_TYPE     = NULL,
                 I.OVER_RETURN_TOLERANCE          = NULL,
                 I.OVER_SHIPMENT_TOLERANCE        = NULL,
                 I.OVERCOMPLETION_TOLERANCE_TYPE  = NULL,
                 I.OVERCOMPLETION_TOLERANCE_VALUE = NULL,
                 I.OVERRUN_PERCENTAGE             = NULL,
                 I.PAYMENT_TERMS_ID               = NULL,
                 I.PICKING_RULE_ID                = NULL,
                 I.PLANNED_INV_POINT_FLAG         = NULL,
                 I.PLANNER_CODE                   = NULL,
                 I.PLANNING_EXCEPTION_SET         = NULL,
                 I.POSITIVE_MEASUREMENT_ERROR     = NULL,
                 I.PREPROCESSING_LEAD_TIME        = NULL,
                 I.PRIMARY_SPECIALIST_ID          = NULL,
                 I.PRODUCT_FAMILY_ITEM_ID         = NULL,
                 I.PURCHASING_TAX_CODE            = NULL,
                 I.QTY_RCV_EXCEPTION_CODE         = NULL,
                 I.QTY_RCV_TOLERANCE              = NULL,
                 I.RECEIPT_DAYS_EXCEPTION_CODE    = NULL,
                 I.RECEIVE_CLOSE_TOLERANCE        = NULL,
                 I.RECEIVING_ROUTING_ID           = NULL,
                 I.RECOVERED_PART_DISP_CODE       = NULL,
                 I.RELEASE_TIME_FENCE_CODE        = NULL,
                 I.RELEASE_TIME_FENCE_DAYS        = NULL,
                 I.RESPONSE_TIME_PERIOD_CODE      = NULL,
                 I.RESPONSE_TIME_VALUE            = NULL,
                 I.ROUNDING_CONTROL_TYPE          = NULL,
                 I.ROUNDING_FACTOR                = NULL,
                 I.SAFETY_STOCK_BUCKET_DAYS       = NULL,
                 -- I.SECONDARY_DEFAULT_IND          = NULL, BUG 7255713
                 I.SECONDARY_SPECIALIST_ID        = NULL,
                 -- I.SECONDARY_UOM_CODE             = NULL, BUG 7255713
                 I.SERV_IMPORTANCE_LEVEL          = NULL,
                 I.SERV_REQ_ENABLED_CODE          = NULL,
                 I.SERVICE_DURATION_PERIOD_CODE   = NULL,
                 I.SERVICE_ITEM_FLAG              = NULL,
                 I.SERVICE_STARTING_DELAY         = NULL,
                 I.SERVICEABLE_ITEM_CLASS_ID      = NULL,
                 I.SHRINKAGE_RATE                 = NULL,
                 I.SOURCE_ORGANIZATION_ID         = NULL,
                 I.SOURCE_SUBINVENTORY            = NULL,
                 I.SOURCE_TYPE                    = NULL,
                 I.START_AUTO_LOT_NUMBER          = NULL,
                 I.START_AUTO_SERIAL_NUMBER       = NULL,
                 I.START_DATE_ACTIVE              = NULL,
                 I.STD_LOT_SIZE                   = NULL,
                 I.SUBSCRIPTION_DEPEND_FLAG       = NULL,
                 I.SUBSTITUTION_WINDOW_CODE       = NULL,
                 I.SUBSTITUTION_WINDOW_DAYS       = NULL,
                 I.TAX_CODE                       = NULL,
                 I.UN_NUMBER_ID                   = NULL,
                 I.UNDER_RETURN_TOLERANCE         = NULL,
                 I.UNDER_SHIPMENT_TOLERANCE       = NULL,
                 I.UNIT_HEIGHT                    = NULL,
                 I.UNIT_LENGTH                    = NULL,
                 I.UNIT_OF_ISSUE                  = NULL,
                 I.UNIT_VOLUME                    = NULL,
	      -- Unit Weight can be updated for Pending Items -R12 C
              -- I.UNIT_WEIGHT                    = NULL,
                 I.UNIT_WIDTH                     = NULL,
                 I.USAGE_ITEM_FLAG                = NULL,
                 I.VARIABLE_LEAD_TIME             = NULL,
                 I.VENDOR_WARRANTY_FLAG           = NULL,
                 I.VOL_DISCOUNT_EXEMPT_FLAG       = NULL,
                 I.VOLUME_UOM_CODE                = NULL,
                 I.WARRANTY_VENDOR_ID             = NULL,
 	     -- Weight UOM can be updated for Pending Items -R12 C
              -- I.WEIGHT_UOM_CODE                = NULL,
                 I.WH_UPDATE_DATE                 = NULL,
                 I.WIP_SUPPLY_LOCATOR_ID          = NULL,
                 I.WIP_SUPPLY_SUBINVENTORY        = NULL,
                 I.GLOBAL_ATTRIBUTE_CATEGORY      = NULL,
                 I.GLOBAL_ATTRIBUTE1              = NULL,
                 I.GLOBAL_ATTRIBUTE2              = NULL,
                 I.GLOBAL_ATTRIBUTE3              = NULL,
                 I.GLOBAL_ATTRIBUTE4              = NULL,
                 I.GLOBAL_ATTRIBUTE5              = NULL,
                 I.GLOBAL_ATTRIBUTE6              = NULL,
                 I.GLOBAL_ATTRIBUTE7              = NULL,
                 I.GLOBAL_ATTRIBUTE8              = NULL,
                 I.GLOBAL_ATTRIBUTE9              = NULL,
                 I.GLOBAL_ATTRIBUTE10             = NULL,
                 I.ATTRIBUTE_CATEGORY             = NULL,
                 I.ATTRIBUTE1                     = NULL,
                 I.ATTRIBUTE2                     = NULL,
                 I.ATTRIBUTE3                     = NULL,
                 I.ATTRIBUTE4                     = NULL,
                 I.ATTRIBUTE5                     = NULL,
                 I.ATTRIBUTE6                     = NULL,
                 I.ATTRIBUTE7                     = NULL,
                 I.ATTRIBUTE8                     = NULL,
                 I.ATTRIBUTE9                     = NULL,
                 I.ATTRIBUTE10                    = NULL,
                 I.ATTRIBUTE11                    = NULL,
                 I.ATTRIBUTE12                    = NULL,
                 I.ATTRIBUTE13                    = NULL,
                 I.ATTRIBUTE14                    = NULL,
                 I.ATTRIBUTE15                    = NULL
             WHERE I.ROWID = CUR.ROWID;

             UPDATE MTL_ITEM_REVISIONS_INTERFACE
             SET    SET_PROCESS_ID    = SET_PROCESS_ID + 3000000000000
             WHERE  INVENTORY_ITEM_ID = CUR.INVENTORY_ITEM_ID
             AND    ORGANIZATION_ID   = CUR.ORGANIZATION_ID;

          END IF;
       END IF;
     END IF; -- If New Item Req is YES
   END LOOP;

   --Start : Check for data security and user privileges
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVNIRIS.mtl_pr_validate_item: before INV_EGO_REVISION_VALIDATE.validate_item_user_privileges');
   END IF;

   IF l_nir_rec_exists THEN
      status := INV_EGO_REVISION_VALIDATE.validate_item_user_privileges(
                         P_Org_Id     => org_id
                        ,P_All_Org    => all_org
                        ,P_Prog_AppId => prog_appid
                        ,P_Prog_Id    => prog_id
                        ,P_Request_Id => request_id
                        ,P_User_Id    => user_id
                        ,P_Login_Id   => login_id
                        ,P_Set_Id     => xset_id +  3000000000000
                        ,X_Err_Text   => err_text);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('INVNIRIS.mtl_pr_validate_item: INV_EGO_REVISION_VALIDATE.validate_item_user_privileges');
      END IF;

      --End : Check for data security and user privileges

      IF (status = 0) then
         IF l_inv_debug_level IN(101, 102) THEN
	         INVPUTLI.info('INVNIRIS: before INVPVHDR.validate_item_header'||to_char(xset_id)||'org'||to_char(org_id)||'all'||to_char(all_org));
	      END IF;

         status := INVPVHDR.validate_item_header(
                        org_id,
                        all_org,
                        prog_appid,
                        prog_id,
                        request_id,
                        user_id,
                        login_id,
                        err_text,
                        xset_id + 3000000000000);
      END IF;

      IF (status = 0) THEN

         UPDATE  MTL_SYSTEM_ITEMS_INTERFACE
         --SET   PROCESS_FLAG   = 4  BUG 7255713
         SET   PROCESS_FLAG   = 44  -- added for bug 7255713-ccsingh
         WHERE PROCESS_FLAG   = 41
         AND   ((SET_PROCESS_ID >= 3000000000000) OR (SET_PROCESS_ID = 3000000000000-999));

         IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVNIRIS.mtl_pr_validate_item: before INV_EGO_REVISION_VALIDATE.validate_items_lifecycle');
         END IF;
         /* start addition of code for bug 7255713-ccsingh */
         status := INVPVDR5.validate_item_header5(
                        org_id,
                        all_org,
                        prog_appid,
                        prog_id,
                        request_id,
                        user_id,
                        login_id,
                        err_text,
                        xset_id + 3000000000000);


      END IF ;

      IF (status = 0) THEN

         UPDATE  MTL_SYSTEM_ITEMS_INTERFACE
         SET   PROCESS_FLAG   = 4
         WHERE PROCESS_FLAG   = 45 --Changed the value from 41 to 45 as we need to validate primary attributes
         AND   ((SET_PROCESS_ID >= 3000000000000) OR (SET_PROCESS_ID = 3000000000000-999));

         IF l_inv_debug_level IN(101, 102) THEN
            INVPUTLI.info('INVNIRIS.mtl_pr_validate_item: before INV_EGO_REVISION_VALIDATE.validate_items_lifecycle');
         END IF;
         /* end addition of code for bug 7255713-ccsingh */
         status := INV_EGO_REVISION_VALIDATE.validate_items_lifecycle(
                         P_Org_Id     => org_id
                        ,P_All_Org    => all_org
                        ,P_Prog_AppId => prog_appid
                        ,P_Prog_Id    => prog_id
                        ,P_Request_Id => request_id
                        ,P_User_Id    => user_id
                        ,P_Login_Id   => login_id
                        ,P_Set_Id     => xset_id + 3000000000000
                        ,X_Err_Text   => err_text);

         IF l_inv_debug_level IN(101, 102) THEN
            INVPUTLI.info('INVNIRIS.mtl_pr_validate_item: INV_EGO_REVISION_VALIDATE.validate_items_lifecycle');
         END IF;

      END IF;

      -- validate item revisions
      IF (status = 0) THEN
         IF l_inv_debug_level IN(101, 102) THEN
	         INVPUTLI.info('INVNIRIS.mtl_pr_validate_item: before validate_item_revs');
         END IF;
         status := INVPVALI.validate_item_revs (
                        org_id,
                        all_org,
                        prog_appid,
                        prog_id,
                        request_id,
                        user_id,
                        login_id,
                        err_text,
                        xset_id + 3000000000000 );

         IF l_inv_debug_level IN(101, 102) THEN
  	         INVPUTLI.info('INVNIRIS.mtl_pr_validate_item: after validate_item_revs');
         END IF;
      END IF;
   END IF;

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVNIRIS.mtl_pr_validate_item:  done with status :'||status);
   END IF;

   UPDATE mtl_system_items_interface
   SET SET_PROCESS_ID = xset_id
   WHERE ((SET_PROCESS_ID >= 3000000000000) OR (SET_PROCESS_ID = 3000000000000-999));

   UPDATE mtl_item_revisions_interface
   SET SET_PROCESS_ID = xset_id
   WHERE ((SET_PROCESS_ID >= 3000000000000) OR (SET_PROCESS_ID = 3000000000000-999));


   OPEN  c_get_batch_policy;
   FETCH c_get_batch_policy INTO l_import_co_option;
   CLOSE c_get_batch_policy;

   IF NVL(l_import_co_option,'N') = 'Y' THEN

      UPDATE mtl_item_revisions_interface i
      SET    i.process_flag      = 5
      WHERE  i.process_flag      = 2
      AND    i.set_process_id    = xset_id
      AND    ((i.organization_id = org_id) or (all_org = 1))
      AND    i.transaction_type  = 'CREATE'
      AND    i.revision <> (select m.starting_revision
                            from  mtl_parameters m
                            where  m.organization_id = i.organization_id);
   END IF;

   RETURN (status);

EXCEPTION

   WHEN OTHERS THEN
      err_text := substr('INVNIRIS.mtl_pr_validate_item ' || SQLERRM, 1,240);
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info(err_text);
      END IF;
      RETURN(SQLCODE);

END mtl_validate_nir_item;

FUNCTION change_policy_check(
org_id          number,
all_org         NUMBER  DEFAULT 2,
prog_appid      NUMBER  DEFAULT -1,
prog_id         NUMBER  DEFAULT -1,
request_id      NUMBER  DEFAULT -1,
user_id         NUMBER  DEFAULT -1,
login_id        NUMBER  DEFAULT -1,
xset_id         NUMBER  DEFAULT -999,
err_text        IN OUT  NOCOPY VARCHAR2) RETURN INTEGER IS

   CURSOR c_populate_values IS
      SELECT msi.rowid
            ,msb.lifecycle_id
            ,msb.current_phase_id
            ,msb.inventory_item_status_code
            ,msb.item_catalog_group_id
            ,msb.eng_item_flag -- 5306178
            ,msb.style_item_flag
            ,msb.style_item_id
            ,msb.gdsn_outbound_enabled_flag
      FROM   mtl_system_items_interface msi,
             mtl_system_items_b msb
      WHERE  msi.process_flag      = 1
      AND    msi.set_process_id    = xset_id
      AND    ((msi.organization_id = org_id) or (all_org = 1))
      AND    msi.transaction_type  = 'UPDATE'
      AND    msi.organization_id   = msb.organization_id
      AND    msi.inventory_item_id = msb.inventory_item_id;
      -- 5306178 and    NVL(msb.approval_status,'A') = 'A';

  CURSOR c_check_attributes_policy IS
      SELECT  msi.rowid
             ,msi.*
      FROM   mtl_system_items_interface msi
      WHERE  msi.process_flag      = 1
      AND    msi.set_process_id    = xset_id
      AND    ((msi.organization_id = org_id) or (all_org = 1))
      AND    msi.transaction_type  = 'UPDATE';

   --4676583 : Honouring batch option - Add All Imported Items to Change Order
   --5216971 : Added structure_type_id
   CURSOR c_get_batch_policy IS
      SELECT NVL(add_all_to_change_flag,'N'), structure_type_id
      FROM   ego_import_option_sets
      WHERE  batch_id = xset_id;


   cursor c_hold_status_codes is
   SELECT msi.inventory_item_status_code, msi.eng_item_flag, msi.rowid
     FROM mtl_system_items_interface msi
    WHERE msi.process_flag      = 1
      AND msi.set_process_id    = xset_id
      AND ((msi.organization_id = org_id) or (all_org = 1))
      AND msi.transaction_type  = 'UPDATE';

   l_process_control   VARCHAR2(50) := INV_EGO_REVISION_VALIDATE.Get_Process_Control;
   l_ret_code          NUMBER  := 1;
   l_msb_rec           mtl_system_items%ROWTYPE;
   l_attr_grps         VARCHAR2(200);
   l_eng_object        VARCHAR2(10);
   l_policy_value      VARCHAR2(100);
   l_error_logged      NUMBER := 0;
   l_Err_Text          VARCHAR2(500);
   LOGGING_ERR         EXCEPTION;
   l_return_status     VARCHAR2(100);
   l_import_co_option  VARCHAR2(1) := 'N';
   l_inv_debug_level	  NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
   --Contains  'Attribute_Group_ID:Attribute_Group_Name'
   TYPE Item_Attributes_Type IS TABLE OF  VARCHAR2(100) INDEX BY BINARY_INTEGER;
   Attribute_Grp_Table  Item_Attributes_Type;
   l_status             NUMBER;

   l_structure_type_id  NUMBER; --5216971
   l_values_provided    BOOLEAN := FALSE;
   l_desc_status_change BOOLEAN := FALSE;
   l_rowid              ROWID;
   l_status_code        mtl_system_items_b.inventory_item_status_code%TYPE;
   l_eng_item_flag      mtl_system_items_b.eng_item_flag%TYPE;

   --Bug: 5532737
   l_attr_grp_name      EGO_ATTR_GROUPS_V.ATTR_GROUP_DISP_NAME%TYPE;
   l_ch_policy_found    BOOLEAN := FALSE;
   l_delim_pos          NUMBER  := 1;
   l_attr_group_id           VARCHAR2(10);
   l_msg_text           VARCHAR2(2000);
   --End Bug: 5532737

   FUNCTION get_attribute_group_id(p_attr_grp_name VARCHAR2) RETURN NUMBER IS
      l_attr_grp_id    NUMBER;
   BEGIN

      FOR I IN 1..Attribute_Grp_Table.COUNT LOOP
         IF SUBSTR(Attribute_Grp_Table(I),INSTR(Attribute_Grp_Table(I),':')+1) = p_attr_grp_name THEN
            l_attr_grp_id := TO_NUMBER(SUBSTR(Attribute_Grp_Table(I),1,INSTR(Attribute_Grp_Table(I),':')-1));
         END IF;
      END LOOP;
      RETURN l_attr_grp_id ;
   END get_attribute_group_id;


BEGIN

   UPDATE MTL_SYSTEM_ITEMS_INTERFACE
   SET    transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
   WHERE  transaction_id IS NULL
   AND    set_process_id = xset_id;

   --Assign Item Id and apply template.
   l_ret_code := INVUPD1B.chk_exist_copy_template_attr(
           org_id,
           all_org,
           prog_appid,
           prog_id,
           request_id,
           user_id,
           login_id,
           err_text,
           xset_id);

   --Start bug: 5238510
   --         : Check for data security and user privileges
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVNIRIS.change_poilcy_check: before INV_EGO_REVISION_VALIDATE.validate_item_user_privileges');
   END IF;

   l_status := INV_EGO_REVISION_VALIDATE.validate_item_user_privileges(
                         P_Org_Id       => org_id
                        ,P_All_Org      => all_org
                        ,P_Prog_AppId   => prog_appid
                        ,P_Prog_Id      => prog_id
                        ,P_Request_Id   => request_id
                        ,P_User_Id      => user_id
                        ,P_Login_Id     => login_id
                        ,P_Set_Id       => xset_id
                        ,X_Err_Text     => err_text
			,P_Process_flag => 1);

   IF l_inv_debug_level IN(101, 102) THEN
     INVPUTLI.info('INVNIRIS.change_poilcy_check: done INV_EGO_REVISION_VALIDATE.validate_item_user_privileges');
   END IF;
   --End bug: 5238510

   l_eng_object := INV_ITEM_UTIL.Object_Exists(p_object_type=>'PACKAGE BODY',p_object_name=>'ENG_CHANGE_POLICY_PKG');

   --When called from ECO validate and impliment should not mark them to 5.
   --6157001 : Removed the ENG_CALL:Y check
   IF (INSTR(l_process_control,'PLM_UI:Y') = 0) AND (l_eng_object ='Y')  THEN

      --Bug 5383744
      --Cache the current value of status code in this cursor.
      OPEN c_hold_status_codes;

      --Default certain basic attributes which are required for policy check.
      FOR cur IN c_populate_values LOOP
            UPDATE mtl_system_items_interface
            SET  lifecycle_id               = DECODE(lifecycle_id,NULL,cur.lifecycle_id,-999999,NULL,lifecycle_id)
                ,current_phase_id           = DECODE(current_phase_id,NULL,cur.current_phase_id,-999999,NULL,current_phase_id)
                ,item_catalog_group_id      = DECODE(item_catalog_group_id,NULL,cur.item_catalog_group_id,-999999, NULL,item_catalog_group_id)
                ,inventory_item_status_code = NVL(inventory_item_status_code,cur.inventory_item_status_code)
                ,eng_item_flag              = NVL(eng_item_flag,cur.eng_item_flag) -- 5306178
                 --Adding style item defaulting, since style/sku validations need to be performed before ICC change
	  	           --which happens in policy check
   		       ,style_item_flag            = DECODE(style_item_flag,NULL,cur.style_item_flag,'!',NULL,chr(0),NULL,style_item_flag)
		          ,style_item_id              = DECODE(style_item_id,NULL, cur.style_item_id,-999999,NULL,9.99E125,NULL,style_item_id)
                ,gdsn_outbound_enabled_flag = DECODE(gdsn_outbound_enabled_flag,NULL,cur.gdsn_outbound_enabled_flag,'!',NULL,chr(0),NULL,gdsn_outbound_enabled_flag)
            WHERE rowid = cur.rowid;
      END LOOP;

      --Call Item Lifecycle-Phase-Status validation.
      l_ret_code := INV_EGO_REVISION_VALIDATE.validate_items_lifecycle(
          P_Org_Id       => org_id
         ,P_All_Org      => all_org
         ,P_Prog_AppId   => prog_appid
         ,P_Prog_Id      => prog_id
         ,P_Request_Id   => request_id
         ,P_User_Id      => user_id
         ,P_Login_Id     => login_id
         ,P_Set_id       => xset_id
         ,P_Process_Flag => 1
         ,X_Err_Text     => err_text);

      --Bug 5383744 Update the status code values back to what user has populated.
      LOOP
         FETCH c_hold_status_codes
          INTO l_status_code, l_eng_item_flag, l_rowid ;
         EXIT WHEN c_hold_status_codes%NOTFOUND;
         UPDATE mtl_system_items_interface
            SET inventory_item_status_code = l_status_code
	       ,eng_item_flag              = l_eng_item_flag
          WHERE rowid = l_rowid;
      END LOOP;
      CLOSE c_hold_status_codes;

      --Get attribute group+id
      SELECT ATTR_GROUP_ID||':'||UPPER(ATTR_GROUP_NAME)
      BULK COLLECT INTO Attribute_Grp_Table
      FROM EGO_ATTR_GROUPS_V
      WHERE ATTR_GROUP_TYPE ='EGO_MASTER_ITEMS';

    -- Bug 4870703 : Change policy check should take precedence over batch options
    -- Bug 4676583 : Honouring batch option - Add All Imported Items to Change Order

      OPEN  c_get_batch_policy;
      FETCH c_get_batch_policy INTO l_import_co_option, l_structure_type_id;
      CLOSE c_get_batch_policy;

      FOR cur IN c_check_attributes_policy LOOP
         IF l_inv_debug_level IN(101, 102) THEN
            INVPUTLI.info('INVNIRIS.change_policy_check: Checking Attr groups');
         END IF;

         l_attr_grps    := NULL;
         l_policy_value := NULL;
         l_Err_Text     := NULL;
         l_error_logged := 0;

         SELECT * INTO  l_msb_rec
         FROM   mtl_system_items
         WHERE inventory_item_id = cur.inventory_item_id
         AND   organization_id   = cur.organization_id;

         --5367962 Check for attribute changes if:
         --Item Import     : Item has a lifecycle attached to it.
         --Structure Import: If Add to CO is YES.

         IF NVL(l_msb_rec.APPROVAL_STATUS,'A') ='A'
         AND (cur.current_phase_id is NOT NULL OR
             (NVL(l_import_co_option,'N') = 'Y' AND l_structure_type_id IS NOT NULL) )
         THEN

            --Inventory Attribute Group
            IF (NVL(cur.INVENTORY_ITEM_FLAG,           NVL(l_msb_rec.INVENTORY_ITEM_FLAG,'!'))              <> NVL(l_msb_rec.INVENTORY_ITEM_FLAG,'!'))
            OR (NVL(cur.STOCK_ENABLED_FLAG,            NVL(l_msb_rec.STOCK_ENABLED_FLAG,'!'))               <> NVL(l_msb_rec.STOCK_ENABLED_FLAG,'!'))
            OR (NVL(cur.MTL_TRANSACTIONS_ENABLED_FLAG, NVL(l_msb_rec.MTL_TRANSACTIONS_ENABLED_FLAG,'!'))    <> NVL(l_msb_rec.MTL_TRANSACTIONS_ENABLED_FLAG,'!'))
            OR (NVL(cur.REVISION_QTY_CONTROL_CODE,     NVL(l_msb_rec.REVISION_QTY_CONTROL_CODE,-999999))    <> NVL(l_msb_rec.REVISION_QTY_CONTROL_CODE,-999999))
            OR (NVL(cur.RESERVABLE_TYPE,               NVL(l_msb_rec.RESERVABLE_TYPE,-999999))              <> NVL(l_msb_rec.RESERVABLE_TYPE,-999999))
            OR (NVL(cur.CHECK_SHORTAGES_FLAG,          NVL(l_msb_rec.CHECK_SHORTAGES_FLAG,'!'))             <> NVL(l_msb_rec.CHECK_SHORTAGES_FLAG,'!'))
            OR (NVL(cur.LOT_CONTROL_CODE,              NVL(l_msb_rec.LOT_CONTROL_CODE,-999999))             <> NVL(l_msb_rec.LOT_CONTROL_CODE,-999999))
            OR (NVL(cur.AUTO_LOT_ALPHA_PREFIX,         NVL(l_msb_rec.AUTO_LOT_ALPHA_PREFIX,'!'))            <> NVL(l_msb_rec.AUTO_LOT_ALPHA_PREFIX,'!'))
            OR (NVL(cur.START_AUTO_LOT_NUMBER,         NVL(l_msb_rec.START_AUTO_LOT_NUMBER,'!'))            <> NVL(l_msb_rec.START_AUTO_LOT_NUMBER,'!'))
            OR (NVL(cur.MATURITY_DAYS,                 NVL(l_msb_rec.MATURITY_DAYS,-999999))                <> NVL(l_msb_rec.MATURITY_DAYS,-999999))
            OR (NVL(cur.HOLD_DAYS,                     NVL(l_msb_rec.HOLD_DAYS,-999999))                    <> NVL(l_msb_rec.HOLD_DAYS,-999999))
            OR (NVL(cur.SHELF_LIFE_CODE,               NVL(l_msb_rec.SHELF_LIFE_CODE,-999999))              <> NVL(l_msb_rec.SHELF_LIFE_CODE,-999999))
            OR (NVL(cur.SHELF_LIFE_DAYS,               NVL(l_msb_rec.SHELF_LIFE_DAYS,-999999))              <> NVL(l_msb_rec.SHELF_LIFE_DAYS,-999999))
            OR (NVL(cur.RETEST_INTERVAL,               NVL(l_msb_rec.RETEST_INTERVAL,-999999))              <> NVL(l_msb_rec.RETEST_INTERVAL,-999999))
            OR (NVL(cur.EXPIRATION_ACTION_INTERVAL,    NVL(l_msb_rec.EXPIRATION_ACTION_INTERVAL,-999999))   <> NVL(l_msb_rec.EXPIRATION_ACTION_INTERVAL,-999999))
            OR (NVL(cur.EXPIRATION_ACTION_CODE,        NVL(l_msb_rec.EXPIRATION_ACTION_CODE,'!'))           <> NVL(l_msb_rec.EXPIRATION_ACTION_CODE,'!'))
            OR (NVL(cur.CYCLE_COUNT_ENABLED_FLAG,      NVL(l_msb_rec.CYCLE_COUNT_ENABLED_FLAG,'!'))         <> NVL(l_msb_rec.CYCLE_COUNT_ENABLED_FLAG,'!'))
            OR (NVL(cur.NEGATIVE_MEASUREMENT_ERROR,    NVL(l_msb_rec.NEGATIVE_MEASUREMENT_ERROR,-999999))   <> NVL(l_msb_rec.NEGATIVE_MEASUREMENT_ERROR,-999999))
            OR (NVL(cur.POSITIVE_MEASUREMENT_ERROR,    NVL(l_msb_rec.POSITIVE_MEASUREMENT_ERROR,-999999))   <> NVL(l_msb_rec.POSITIVE_MEASUREMENT_ERROR,-999999))
            OR (NVL(cur.SERIAL_NUMBER_CONTROL_CODE,    NVL(l_msb_rec.SERIAL_NUMBER_CONTROL_CODE,-999999))   <> NVL(l_msb_rec.SERIAL_NUMBER_CONTROL_CODE,-999999))
            OR (NVL(cur.AUTO_SERIAL_ALPHA_PREFIX,      NVL(l_msb_rec.AUTO_SERIAL_ALPHA_PREFIX,'!'))         <> NVL(l_msb_rec.AUTO_SERIAL_ALPHA_PREFIX,'!'))
            OR (NVL(cur.START_AUTO_SERIAL_NUMBER,      NVL(l_msb_rec.START_AUTO_SERIAL_NUMBER,'!'))         <> NVL(l_msb_rec.START_AUTO_SERIAL_NUMBER,'!'))
            OR (NVL(cur.LOCATION_CONTROL_CODE,         NVL(l_msb_rec.LOCATION_CONTROL_CODE,-999999))        <> NVL(l_msb_rec.LOCATION_CONTROL_CODE,-999999))
            OR (NVL(cur.RESTRICT_SUBINVENTORIES_CODE,  NVL(l_msb_rec.RESTRICT_SUBINVENTORIES_CODE,-999999)) <> NVL(l_msb_rec.RESTRICT_SUBINVENTORIES_CODE,-999999))
            OR (NVL(cur.RESTRICT_LOCATORS_CODE,        NVL(l_msb_rec.RESTRICT_LOCATORS_CODE,-999999))       <> NVL(l_msb_rec.RESTRICT_LOCATORS_CODE,-999999))
            OR (NVL(cur.LOT_STATUS_ENABLED,            NVL(l_msb_rec.LOT_STATUS_ENABLED,'!'))               <> NVL(l_msb_rec.LOT_STATUS_ENABLED,'!'))
            OR (NVL(cur.DEFAULT_LOT_STATUS_ID,         NVL(l_msb_rec.DEFAULT_LOT_STATUS_ID,-999999))        <> NVL(l_msb_rec.DEFAULT_LOT_STATUS_ID,-999999))
            OR (NVL(cur.SERIAL_STATUS_ENABLED,         NVL(l_msb_rec.SERIAL_STATUS_ENABLED,'!'))            <> NVL(l_msb_rec.SERIAL_STATUS_ENABLED,'!'))
            OR (NVL(cur.DEFAULT_SERIAL_STATUS_ID,      NVL(l_msb_rec.DEFAULT_SERIAL_STATUS_ID,-999999))     <> NVL(l_msb_rec.DEFAULT_SERIAL_STATUS_ID,-999999))
            OR (NVL(cur.SERIAL_STATUS_ENABLED,         NVL(l_msb_rec.SERIAL_STATUS_ENABLED,'!'))            <> NVL(l_msb_rec.SERIAL_STATUS_ENABLED,'!'))
            OR (NVL(cur.DEFAULT_SERIAL_STATUS_ID,      NVL(l_msb_rec.DEFAULT_SERIAL_STATUS_ID,-999999))     <> NVL(l_msb_rec.DEFAULT_SERIAL_STATUS_ID,-999999))
            OR (NVL(cur.GRADE_CONTROL_FLAG,            NVL(l_msb_rec.GRADE_CONTROL_FLAG,'!'))               <> NVL(l_msb_rec.GRADE_CONTROL_FLAG,'!'))
            OR (NVL(cur.DEFAULT_GRADE,                 NVL(l_msb_rec.DEFAULT_GRADE,'!'))                    <> NVL(l_msb_rec.DEFAULT_GRADE,'!'))
            OR (NVL(cur.LOT_SPLIT_ENABLED,             NVL(l_msb_rec.LOT_SPLIT_ENABLED,'!'))                <> NVL(l_msb_rec.LOT_SPLIT_ENABLED,'!'))
            OR (NVL(cur.LOT_MERGE_ENABLED,             NVL(l_msb_rec.LOT_MERGE_ENABLED,'!'))                <> NVL(l_msb_rec.LOT_MERGE_ENABLED,'!'))
            OR (NVL(cur.LOT_TRANSLATE_ENABLED,         NVL(l_msb_rec.LOT_TRANSLATE_ENABLED,'!'))            <> NVL(l_msb_rec.LOT_TRANSLATE_ENABLED,'!'))
            OR (NVL(cur.LOT_SUBSTITUTION_ENABLED,      NVL(l_msb_rec.LOT_SUBSTITUTION_ENABLED,'!'))         <> NVL(l_msb_rec.LOT_SUBSTITUTION_ENABLED,'!'))
            OR (NVL(cur.BULK_PICKED_FLAG,              NVL(l_msb_rec.BULK_PICKED_FLAG,'!'))                 <> NVL(l_msb_rec.BULK_PICKED_FLAG,'!'))
            OR (NVL(cur.LOT_DIVISIBLE_FLAG,            NVL(l_msb_rec.LOT_DIVISIBLE_FLAG,'!'))               <> NVL(l_msb_rec.LOT_DIVISIBLE_FLAG,'!'))
            OR (NVL(cur.CHILD_LOT_PREFIX,              NVL(l_msb_rec.CHILD_LOT_PREFIX,-999999))                 <> NVL(l_msb_rec.CHILD_LOT_PREFIX,-999999))
            OR (NVL(cur.CHILD_LOT_STARTING_NUMBER,     NVL(l_msb_rec.CHILD_LOT_STARTING_NUMBER,-999999))    <> NVL(l_msb_rec.CHILD_LOT_STARTING_NUMBER,-999999))
            OR (NVL(cur.CHILD_LOT_VALIDATION_FLAG,     NVL(l_msb_rec.CHILD_LOT_VALIDATION_FLAG,'!'))        <> NVL(l_msb_rec.CHILD_LOT_VALIDATION_FLAG,'!'))
            OR (NVL(cur.PARENT_CHILD_GENERATION_FLAG,  NVL(l_msb_rec.PARENT_CHILD_GENERATION_FLAG,'!'))     <> NVL(l_msb_rec.PARENT_CHILD_GENERATION_FLAG,'!'))
            OR (NVL(cur.COPY_LOT_ATTRIBUTE_FLAG,       NVL(l_msb_rec.COPY_LOT_ATTRIBUTE_FLAG,'!'))          <> NVL(l_msb_rec.COPY_LOT_ATTRIBUTE_FLAG,'!'))
            OR (NVL(cur.CHILD_LOT_FLAG,                NVL(l_msb_rec.CHILD_LOT_FLAG,'!'))                   <> NVL(l_msb_rec.CHILD_LOT_FLAG,'!'))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('INVENTORY'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('INVENTORY'));
               END IF;
            END IF;

            --BOM Attribute Group
            IF (NVL(cur.BOM_ENABLED_FLAG,              NVL(l_msb_rec.BOM_ENABLED_FLAG,'!'))                 <> NVL(l_msb_rec.BOM_ENABLED_FLAG,'!'))
            OR (NVL(cur.BOM_ITEM_TYPE,                 NVL(l_msb_rec.BOM_ITEM_TYPE,-999999))                <> NVL(l_msb_rec.BOM_ITEM_TYPE,-999999))
            OR (NVL(cur.BASE_ITEM_ID,                  NVL(l_msb_rec.BASE_ITEM_ID,-999999))                 <> NVL(l_msb_rec.BASE_ITEM_ID,-999999))
            OR (NVL(cur.AUTO_CREATED_CONFIG_FLAG,      NVL(l_msb_rec.AUTO_CREATED_CONFIG_FLAG,'!'))         <> NVL(l_msb_rec.AUTO_CREATED_CONFIG_FLAG,'!'))
            OR (NVL(cur.ENG_ITEM_FLAG,                 NVL(l_msb_rec.ENG_ITEM_FLAG,'!'))                    <> NVL(l_msb_rec.ENG_ITEM_FLAG,'!'))
            OR (NVL(cur.EFFECTIVITY_CONTROL,           NVL(l_msb_rec.EFFECTIVITY_CONTROL,-999999))          <> NVL(l_msb_rec.EFFECTIVITY_CONTROL,-999999))
            OR (NVL(cur.CONFIG_MODEL_TYPE,             NVL(l_msb_rec.CONFIG_MODEL_TYPE,'!'))                <> NVL(l_msb_rec.CONFIG_MODEL_TYPE,'!'))
            OR (NVL(cur.CONFIG_ORGS,                   NVL(l_msb_rec.CONFIG_ORGS,-999999))                  <> NVL(l_msb_rec.CONFIG_ORGS,-999999))
            OR (NVL(cur.CONFIG_MATCH,                  NVL(l_msb_rec.CONFIG_MATCH,'!'))                     <> NVL(l_msb_rec.CONFIG_MATCH,'!'))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('BILLOFMATERIALS'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('BILLOFMATERIALS'));
               END IF;
            END IF;

            --Asset Management Group
            IF (NVL(cur.EAM_ITEM_TYPE,                 NVL(l_msb_rec.EAM_ITEM_TYPE,-999999))                <> NVL(l_msb_rec.EAM_ITEM_TYPE,-999999))
            OR (NVL(cur.EAM_ACTIVITY_TYPE_CODE,        NVL(l_msb_rec.EAM_ACTIVITY_TYPE_CODE,'!'))           <> NVL(l_msb_rec.EAM_ACTIVITY_TYPE_CODE,'!'))
            OR (NVL(cur.EAM_ACTIVITY_CAUSE_CODE,       NVL(l_msb_rec.EAM_ACTIVITY_CAUSE_CODE,'!'))          <> NVL(l_msb_rec.EAM_ACTIVITY_CAUSE_CODE,'!'))
            OR (NVL(cur.EAM_ACTIVITY_SOURCE_CODE,      NVL(l_msb_rec.EAM_ACTIVITY_SOURCE_CODE,'!'))         <> NVL(l_msb_rec.EAM_ACTIVITY_SOURCE_CODE,'!'))
            OR (NVL(cur.EAM_ACT_SHUTDOWN_STATUS,       NVL(l_msb_rec.EAM_ACT_SHUTDOWN_STATUS,'!'))          <> NVL(l_msb_rec.EAM_ACT_SHUTDOWN_STATUS,'!'))
            OR (NVL(cur.EAM_ACT_NOTIFICATION_FLAG,     NVL(l_msb_rec.EAM_ACT_NOTIFICATION_FLAG,'!'))        <> NVL(l_msb_rec.EAM_ACT_NOTIFICATION_FLAG,'!'))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('ASSETMANAGEMENT'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('ASSETMANAGEMENT'));
               END IF;
            END IF;

            --Costing Attribute Group
            IF (NVL(cur.COSTING_ENABLED_FLAG,          NVL(l_msb_rec.COSTING_ENABLED_FLAG,'!'))             <> NVL(l_msb_rec.COSTING_ENABLED_FLAG,'!'))
            OR (NVL(cur.INVENTORY_ASSET_FLAG,          NVL(l_msb_rec.INVENTORY_ASSET_FLAG,'!'))             <> NVL(l_msb_rec.INVENTORY_ASSET_FLAG,'!'))
            OR (NVL(cur.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,NVL(l_msb_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,'!'))   <> NVL(l_msb_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG,'!'))
            OR (NVL(cur.COST_OF_SALES_ACCOUNT,         NVL(l_msb_rec.COST_OF_SALES_ACCOUNT,-999999))        <> NVL(l_msb_rec.COST_OF_SALES_ACCOUNT,-999999))
            OR (NVL(cur.STD_LOT_SIZE,                  NVL(l_msb_rec.STD_LOT_SIZE,-999999))                 <> NVL(l_msb_rec.STD_LOT_SIZE,-999999))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('COSTING'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('COSTING'));
               END IF;
            END IF;

            --Purchasing Attribute Group
            IF (NVL(cur.PURCHASING_ITEM_FLAG,          NVL(l_msb_rec.PURCHASING_ITEM_FLAG,'!'))             <> NVL(l_msb_rec.PURCHASING_ITEM_FLAG,'!'))
            OR (NVL(cur.PURCHASING_ENABLED_FLAG,       NVL(l_msb_rec.PURCHASING_ENABLED_FLAG,'!'))          <> NVL(l_msb_rec.PURCHASING_ENABLED_FLAG,'!'))
            OR (NVL(cur.MUST_USE_APPROVED_VENDOR_FLAG, NVL(l_msb_rec.MUST_USE_APPROVED_VENDOR_FLAG,'!'))    <> NVL(l_msb_rec.MUST_USE_APPROVED_VENDOR_FLAG,'!'))
            OR (NVL(cur.ALLOW_ITEM_DESC_UPDATE_FLAG,   NVL(l_msb_rec.ALLOW_ITEM_DESC_UPDATE_FLAG,'!'))      <> NVL(l_msb_rec.ALLOW_ITEM_DESC_UPDATE_FLAG,'!'))
            OR (NVL(cur.RFQ_REQUIRED_FLAG,             NVL(l_msb_rec.RFQ_REQUIRED_FLAG,'!'))                <> NVL(l_msb_rec.RFQ_REQUIRED_FLAG,'!'))
            OR (NVL(cur.OUTSIDE_OPERATION_FLAG,        NVL(l_msb_rec.OUTSIDE_OPERATION_FLAG,'!'))           <> NVL(l_msb_rec.OUTSIDE_OPERATION_FLAG,'!'))
            OR (NVL(cur.OUTSIDE_OPERATION_UOM_TYPE,    NVL(l_msb_rec.OUTSIDE_OPERATION_UOM_TYPE,'!'))       <> NVL(l_msb_rec.OUTSIDE_OPERATION_UOM_TYPE,'!'))
            OR (NVL(cur.TAXABLE_FLAG,                  NVL(l_msb_rec.TAXABLE_FLAG,'!'))                     <> NVL(l_msb_rec.TAXABLE_FLAG,'!'))
            OR (NVL(cur.TAX_CODE,                      NVL(l_msb_rec.TAX_CODE,'!'))                         <> NVL(l_msb_rec.TAX_CODE,'!'))
            OR (NVL(cur.RECEIPT_REQUIRED_FLAG,         NVL(l_msb_rec.RECEIPT_REQUIRED_FLAG,'!'))            <> NVL(l_msb_rec.RECEIPT_REQUIRED_FLAG,'!'))
            OR (NVL(cur.INSPECTION_REQUIRED_FLAG,      NVL(l_msb_rec.INSPECTION_REQUIRED_FLAG,'!'))         <> NVL(l_msb_rec.INSPECTION_REQUIRED_FLAG,'!'))
            OR (NVL(cur.BUYER_ID,                      NVL(l_msb_rec.BUYER_ID,-999999))                     <> NVL(l_msb_rec.BUYER_ID,-999999))
            OR (NVL(cur.UNIT_OF_ISSUE,                 NVL(l_msb_rec.UNIT_OF_ISSUE,'!'))                    <> NVL(l_msb_rec.UNIT_OF_ISSUE,'!'))
            OR (NVL(cur.RECEIVE_CLOSE_TOLERANCE,       NVL(l_msb_rec.RECEIVE_CLOSE_TOLERANCE,-999999))      <> NVL(l_msb_rec.RECEIVE_CLOSE_TOLERANCE,-999999))
            OR (NVL(cur.INVOICE_CLOSE_TOLERANCE,       NVL(l_msb_rec.INVOICE_CLOSE_TOLERANCE,-999999))      <> NVL(l_msb_rec.INVOICE_CLOSE_TOLERANCE,-999999))
            OR (NVL(cur.UN_NUMBER_ID,                  NVL(l_msb_rec.UN_NUMBER_ID,-999999))                 <> NVL(l_msb_rec.UN_NUMBER_ID,-999999))
            OR (NVL(cur.HAZARD_CLASS_ID,               NVL(l_msb_rec.HAZARD_CLASS_ID,-999999))              <> NVL(l_msb_rec.HAZARD_CLASS_ID,-999999))
            OR (NVL(cur.LIST_PRICE_PER_UNIT,           NVL(l_msb_rec.LIST_PRICE_PER_UNIT,-999999))          <> NVL(l_msb_rec.LIST_PRICE_PER_UNIT,-999999))
            OR (NVL(cur.MARKET_PRICE,                  NVL(l_msb_rec.MARKET_PRICE,-999999))                 <> NVL(l_msb_rec.MARKET_PRICE,-999999))
            OR (NVL(cur.PRICE_TOLERANCE_PERCENT,       NVL(l_msb_rec.PRICE_TOLERANCE_PERCENT,-999999))      <> NVL(l_msb_rec.PRICE_TOLERANCE_PERCENT,-999999))
            OR (NVL(cur.ROUNDING_FACTOR,               NVL(l_msb_rec.ROUNDING_FACTOR,-999999))              <> NVL(l_msb_rec.ROUNDING_FACTOR,-999999))
            OR (NVL(cur.ENCUMBRANCE_ACCOUNT,           NVL(l_msb_rec.ENCUMBRANCE_ACCOUNT,-999999))          <> NVL(l_msb_rec.ENCUMBRANCE_ACCOUNT,-999999))
            OR (NVL(cur.EXPENSE_ACCOUNT,               NVL(l_msb_rec.EXPENSE_ACCOUNT,-999999))              <> NVL(l_msb_rec.EXPENSE_ACCOUNT,-999999))
            OR (NVL(cur.ASSET_CATEGORY_ID,             NVL(l_msb_rec.ASSET_CATEGORY_ID,-999999))            <> NVL(l_msb_rec.ASSET_CATEGORY_ID,-999999))
            OR (NVL(cur.OUTSOURCED_ASSEMBLY,           NVL(l_msb_rec.OUTSOURCED_ASSEMBLY,-999999))          <> NVL(l_msb_rec.OUTSOURCED_ASSEMBLY,-999999))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('PURCHASING'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('PURCHASING'));
               END IF;
            END IF;

            --Receiving Attribute Group
            IF (NVL(cur.RECEIPT_DAYS_EXCEPTION_CODE,   NVL(l_msb_rec.RECEIPT_DAYS_EXCEPTION_CODE,'!'))     <> NVL(l_msb_rec.RECEIPT_DAYS_EXCEPTION_CODE,'!'))
            OR (NVL(cur.DAYS_EARLY_RECEIPT_ALLOWED,    NVL(l_msb_rec.DAYS_EARLY_RECEIPT_ALLOWED,-999999))  <> NVL(l_msb_rec.DAYS_EARLY_RECEIPT_ALLOWED,-999999))
            OR (NVL(cur.DAYS_LATE_RECEIPT_ALLOWED,     NVL(l_msb_rec.DAYS_LATE_RECEIPT_ALLOWED,-999999))   <> NVL(l_msb_rec.DAYS_LATE_RECEIPT_ALLOWED,-999999))
            OR (NVL(cur.QTY_RCV_EXCEPTION_CODE,        NVL(l_msb_rec.QTY_RCV_EXCEPTION_CODE,'!'))          <> NVL(l_msb_rec.QTY_RCV_EXCEPTION_CODE,'!'))
            OR (NVL(cur.QTY_RCV_TOLERANCE,             NVL(l_msb_rec.QTY_RCV_TOLERANCE,-999999))           <> NVL(l_msb_rec.QTY_RCV_TOLERANCE,-999999))
            OR (NVL(cur.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,NVL(l_msb_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,'!'))  <> NVL(l_msb_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG,'!'))
            OR (NVL(cur.ALLOW_UNORDERED_RECEIPTS_FLAG, NVL(l_msb_rec.ALLOW_UNORDERED_RECEIPTS_FLAG,'!'))   <> NVL(l_msb_rec.ALLOW_UNORDERED_RECEIPTS_FLAG,'!'))
            OR (NVL(cur.ALLOW_EXPRESS_DELIVERY_FLAG,   NVL(l_msb_rec.ALLOW_EXPRESS_DELIVERY_FLAG,'!'))     <> NVL(l_msb_rec.ALLOW_EXPRESS_DELIVERY_FLAG,'!'))
            OR (NVL(cur.RECEIVING_ROUTING_ID,          NVL(l_msb_rec.RECEIVING_ROUTING_ID,-999999))        <> NVL(l_msb_rec.RECEIVING_ROUTING_ID,-999999))
            OR (NVL(cur.ENFORCE_SHIP_TO_LOCATION_CODE, NVL(l_msb_rec.ENFORCE_SHIP_TO_LOCATION_CODE,'!'))   <> NVL(l_msb_rec.ENFORCE_SHIP_TO_LOCATION_CODE,'!'))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('RECEIVING'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('RECEIVING'));
               END IF;
            END IF;

            --Process Manufacturing Attribute Group
            IF (NVL(cur.RECIPE_ENABLED_FLAG,           NVL(l_msb_rec.RECIPE_ENABLED_FLAG,'!'))              <> NVL(l_msb_rec.RECIPE_ENABLED_FLAG,'!'))
            OR (NVL(cur.PROCESS_QUALITY_ENABLED_FLAG,  NVL(l_msb_rec.PROCESS_QUALITY_ENABLED_FLAG,'!'))     <> NVL(l_msb_rec.PROCESS_QUALITY_ENABLED_FLAG,'!'))
            OR (NVL(cur.PROCESS_EXECUTION_ENABLED_FLAG,NVL(l_msb_rec.PROCESS_EXECUTION_ENABLED_FLAG,'!'))   <> NVL(l_msb_rec.PROCESS_EXECUTION_ENABLED_FLAG,'!'))
            OR (NVL(cur.PROCESS_SUPPLY_SUBINVENTORY,   NVL(l_msb_rec.PROCESS_SUPPLY_SUBINVENTORY,'!'))      <> NVL(l_msb_rec.PROCESS_SUPPLY_SUBINVENTORY,'!'))
            OR (NVL(cur.PROCESS_SUPPLY_LOCATOR_ID,     NVL(l_msb_rec.PROCESS_SUPPLY_LOCATOR_ID,-999999))    <> NVL(l_msb_rec.PROCESS_SUPPLY_LOCATOR_ID,-999999))
            OR (NVL(cur.PROCESS_YIELD_SUBINVENTORY,    NVL(l_msb_rec.PROCESS_YIELD_SUBINVENTORY,'!'))       <> NVL(l_msb_rec.PROCESS_YIELD_SUBINVENTORY,'!'))
            OR (NVL(cur.PROCESS_YIELD_LOCATOR_ID,      NVL(l_msb_rec.PROCESS_YIELD_LOCATOR_ID,-999999))     <> NVL(l_msb_rec.PROCESS_YIELD_LOCATOR_ID,-999999))
            OR (NVL(cur.PROCESS_COSTING_ENABLED_FLAG,  NVL(l_msb_rec.PROCESS_COSTING_ENABLED_FLAG,'!'))     <> NVL(l_msb_rec.PROCESS_COSTING_ENABLED_FLAG,'!'))
            OR (NVL(cur.HAZARDOUS_MATERIAL_FLAG,       NVL(l_msb_rec.HAZARDOUS_MATERIAL_FLAG,'!'))          <> NVL(l_msb_rec.HAZARDOUS_MATERIAL_FLAG,'!'))
            OR (NVL(cur.CAS_NUMBER,                    NVL(l_msb_rec.CAS_NUMBER,'!'))                       <> NVL(l_msb_rec.CAS_NUMBER,'!'))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('PROCESSMANUFACTURING'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('PROCESSMANUFACTURING'));
               END IF;
            END IF;

            --Physical Attributes
            IF (NVL(cur.WEIGHT_UOM_CODE,               NVL(l_msb_rec.WEIGHT_UOM_CODE,'!'))                  <> NVL(l_msb_rec.WEIGHT_UOM_CODE,'!'))
            OR (NVL(cur.UNIT_WEIGHT,                   NVL(l_msb_rec.UNIT_WEIGHT,-999999))                  <> NVL(l_msb_rec.UNIT_WEIGHT,-999999))
            OR (NVL(cur.VOLUME_UOM_CODE,               NVL(l_msb_rec.VOLUME_UOM_CODE,'!'))                  <> NVL(l_msb_rec.VOLUME_UOM_CODE,'!'))
            OR (NVL(cur.UNIT_VOLUME,                   NVL(l_msb_rec.UNIT_VOLUME,-999999))                  <> NVL(l_msb_rec.UNIT_VOLUME,-999999))
            OR (NVL(cur.CONTAINER_ITEM_FLAG,           NVL(l_msb_rec.CONTAINER_ITEM_FLAG,'!'))              <> NVL(l_msb_rec.CONTAINER_ITEM_FLAG,'!'))
            OR (NVL(cur.VEHICLE_ITEM_FLAG,             NVL(l_msb_rec.VEHICLE_ITEM_FLAG,'!'))                <> NVL(l_msb_rec.VEHICLE_ITEM_FLAG,'!'))
            OR (NVL(cur.CONTAINER_TYPE_CODE,           NVL(l_msb_rec.CONTAINER_TYPE_CODE,'!'))              <> NVL(l_msb_rec.CONTAINER_TYPE_CODE,'!'))
            OR (NVL(cur.INTERNAL_VOLUME,               NVL(l_msb_rec.INTERNAL_VOLUME,-999999))              <> NVL(l_msb_rec.INTERNAL_VOLUME,-999999))
            OR (NVL(cur.MAXIMUM_LOAD_WEIGHT,           NVL(l_msb_rec.MAXIMUM_LOAD_WEIGHT,-999999))          <> NVL(l_msb_rec.MAXIMUM_LOAD_WEIGHT,-999999))
            OR (NVL(cur.MINIMUM_FILL_PERCENT,          NVL(l_msb_rec.MINIMUM_FILL_PERCENT,-999999))         <> NVL(l_msb_rec.MINIMUM_FILL_PERCENT,-999999))
            OR (NVL(cur.DIMENSION_UOM_CODE,            NVL(l_msb_rec.DIMENSION_UOM_CODE,'!'))               <> NVL(l_msb_rec.DIMENSION_UOM_CODE,'!'))
            OR (NVL(cur.UNIT_LENGTH,                   NVL(l_msb_rec.UNIT_LENGTH,-999999))                  <> NVL(l_msb_rec.UNIT_LENGTH,-999999))
            OR (NVL(cur.UNIT_WIDTH,                    NVL(l_msb_rec.UNIT_WIDTH,-999999))                   <> NVL(l_msb_rec.UNIT_WIDTH,-999999))
            OR (NVL(cur.UNIT_HEIGHT,                   NVL(l_msb_rec.UNIT_HEIGHT,-999999))                  <> NVL(l_msb_rec.UNIT_HEIGHT,-999999))
            OR (NVL(cur.COLLATERAL_FLAG,               NVL(l_msb_rec.COLLATERAL_FLAG,'!'))                  <> NVL(l_msb_rec.COLLATERAL_FLAG,'!'))
            OR (NVL(cur.EVENT_FLAG,                    NVL(l_msb_rec.EVENT_FLAG,'!'))                       <> NVL(l_msb_rec.EVENT_FLAG,'!'))
            OR (NVL(cur.EQUIPMENT_TYPE,                NVL(l_msb_rec.EQUIPMENT_TYPE,-999999))               <> NVL(l_msb_rec.EQUIPMENT_TYPE,-999999))
            OR (NVL(cur.ELECTRONIC_FLAG,               NVL(l_msb_rec.ELECTRONIC_FLAG,'!'))                  <> NVL(l_msb_rec.ELECTRONIC_FLAG,'!'))
            OR (NVL(cur.DOWNLOADABLE_FLAG,             NVL(l_msb_rec.DOWNLOADABLE_FLAG,'!'))                <> NVL(l_msb_rec.DOWNLOADABLE_FLAG,'!'))
            OR (NVL(cur.INDIVISIBLE_FLAG,              NVL(l_msb_rec.INDIVISIBLE_FLAG,'!'))                 <> NVL(l_msb_rec.INDIVISIBLE_FLAG,'!'))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('PHYSICALATTRIBUTES'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('PHYSICALATTRIBUTES'));
               END IF;
            END IF;

            --General Planning
            IF (NVL(cur.INVENTORY_PLANNING_CODE,       NVL(l_msb_rec.INVENTORY_PLANNING_CODE,-999999))      <> NVL(l_msb_rec.INVENTORY_PLANNING_CODE,-999999))
            OR (NVL(cur.PLANNER_CODE,                  NVL(l_msb_rec.PLANNER_CODE,'!'))                     <> NVL(l_msb_rec.PLANNER_CODE,'!'))
            OR (NVL(cur.PLANNING_MAKE_BUY_CODE,        NVL(l_msb_rec.PLANNING_MAKE_BUY_CODE,-999999))       <> NVL(l_msb_rec.PLANNING_MAKE_BUY_CODE,-999999))
            OR (NVL(cur.MIN_MINMAX_QUANTITY,           NVL(l_msb_rec.MIN_MINMAX_QUANTITY,-999999))          <> NVL(l_msb_rec.MIN_MINMAX_QUANTITY,-999999))
            OR (NVL(cur.MAX_MINMAX_QUANTITY,           NVL(l_msb_rec.MAX_MINMAX_QUANTITY,-999999))          <> NVL(l_msb_rec.MAX_MINMAX_QUANTITY,-999999))
            OR (NVL(cur.MINIMUM_ORDER_QUANTITY,        NVL(l_msb_rec.MINIMUM_ORDER_QUANTITY,-999999))       <> NVL(l_msb_rec.MINIMUM_ORDER_QUANTITY,-999999))
            OR (NVL(cur.MAXIMUM_ORDER_QUANTITY,        NVL(l_msb_rec.MAXIMUM_ORDER_QUANTITY,-999999))       <> NVL(l_msb_rec.MAXIMUM_ORDER_QUANTITY,-999999))
            OR (NVL(cur.ORDER_COST,                    NVL(l_msb_rec.ORDER_COST,-999999))                   <> NVL(l_msb_rec.ORDER_COST,-999999))
            OR (NVL(cur.CARRYING_COST,                 NVL(l_msb_rec.CARRYING_COST,-999999))                <> NVL(l_msb_rec.CARRYING_COST,-999999))
            OR (NVL(cur.VMI_MINIMUM_UNITS,             NVL(l_msb_rec.VMI_MINIMUM_UNITS,-999999))            <> NVL(l_msb_rec.VMI_MINIMUM_UNITS,-999999))
            OR (NVL(cur.VMI_MINIMUM_DAYS,              NVL(l_msb_rec.VMI_MINIMUM_DAYS,-999999))             <> NVL(l_msb_rec.VMI_MINIMUM_DAYS,-999999))
            OR (NVL(cur.VMI_MAXIMUM_UNITS,             NVL(l_msb_rec.VMI_MAXIMUM_UNITS,-999999))            <> NVL(l_msb_rec.VMI_MAXIMUM_UNITS,-999999))
            OR (NVL(cur.VMI_MAXIMUM_DAYS,              NVL(l_msb_rec.VMI_MAXIMUM_DAYS,-999999))             <> NVL(l_msb_rec.VMI_MAXIMUM_DAYS,-999999))
            OR (NVL(cur.VMI_FIXED_ORDER_QUANTITY,      NVL(l_msb_rec.VMI_FIXED_ORDER_QUANTITY,-999999))     <> NVL(l_msb_rec.VMI_FIXED_ORDER_QUANTITY,-999999))
            OR (NVL(cur.SO_AUTHORIZATION_FLAG,         NVL(l_msb_rec.SO_AUTHORIZATION_FLAG,-999999))        <> NVL(l_msb_rec.SO_AUTHORIZATION_FLAG,-999999))
            OR (NVL(cur.CONSIGNED_FLAG,                NVL(l_msb_rec.CONSIGNED_FLAG,-999999))               <> NVL(l_msb_rec.CONSIGNED_FLAG,-999999))
            OR (NVL(cur.ASN_AUTOEXPIRE_FLAG,           NVL(l_msb_rec.ASN_AUTOEXPIRE_FLAG,-999999))          <> NVL(l_msb_rec.ASN_AUTOEXPIRE_FLAG,-999999))
            OR (NVL(cur.VMI_FORECAST_TYPE,             NVL(l_msb_rec.VMI_FORECAST_TYPE,-999999))            <> NVL(l_msb_rec.VMI_FORECAST_TYPE,-999999))
            OR (NVL(cur.FORECAST_HORIZON,              NVL(l_msb_rec.FORECAST_HORIZON,-999999))             <> NVL(l_msb_rec.FORECAST_HORIZON,-999999))
            OR (NVL(cur.SOURCE_TYPE,                   NVL(l_msb_rec.SOURCE_TYPE,-999999))                  <> NVL(l_msb_rec.SOURCE_TYPE,-999999))
            OR (NVL(cur.SOURCE_ORGANIZATION_ID,        NVL(l_msb_rec.SOURCE_ORGANIZATION_ID,-999999))       <> NVL(l_msb_rec.SOURCE_ORGANIZATION_ID,-999999))
            OR (NVL(cur.SOURCE_SUBINVENTORY,           NVL(l_msb_rec.SOURCE_SUBINVENTORY,'!'))              <> NVL(l_msb_rec.SOURCE_SUBINVENTORY,'!'))
            OR (NVL(cur.MRP_SAFETY_STOCK_CODE,         NVL(l_msb_rec.MRP_SAFETY_STOCK_CODE,-999999))        <> NVL(l_msb_rec.MRP_SAFETY_STOCK_CODE,-999999))
            OR (NVL(cur.SAFETY_STOCK_BUCKET_DAYS,      NVL(l_msb_rec.SAFETY_STOCK_BUCKET_DAYS,-999999))     <> NVL(l_msb_rec.SAFETY_STOCK_BUCKET_DAYS,-999999))
            OR (NVL(cur.MRP_SAFETY_STOCK_PERCENT,      NVL(l_msb_rec.MRP_SAFETY_STOCK_PERCENT,-999999))     <> NVL(l_msb_rec.MRP_SAFETY_STOCK_PERCENT,-999999))
            OR (NVL(cur.FIXED_ORDER_QUANTITY,          NVL(l_msb_rec.FIXED_ORDER_QUANTITY,-999999))             <> NVL(l_msb_rec.FIXED_ORDER_QUANTITY,-999999))
            OR (NVL(cur.FIXED_LOT_MULTIPLIER,          NVL(l_msb_rec.FIXED_LOT_MULTIPLIER,-999999))         <> NVL(l_msb_rec.FIXED_LOT_MULTIPLIER,-999999))
            OR (NVL(cur.SUBCONTRACTING_COMPONENT,      NVL(l_msb_rec.SUBCONTRACTING_COMPONENT,-999999))     <> NVL(l_msb_rec.SUBCONTRACTING_COMPONENT,-999999))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('GENERALPLANNING'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('GENERALPLANNING'));
               END IF;
            END IF;

            --MPS/MRP Planning
            IF (NVL(cur.MRP_PLANNING_CODE,             NVL(l_msb_rec.MRP_PLANNING_CODE,-999999))            <> NVL(l_msb_rec.MRP_PLANNING_CODE,-999999))
            OR (NVL(cur.ATO_FORECAST_CONTROL,          NVL(l_msb_rec.ATO_FORECAST_CONTROL,-999999))         <> NVL(l_msb_rec.ATO_FORECAST_CONTROL,-999999))
            OR (NVL(cur.PLANNING_EXCEPTION_SET,        NVL(l_msb_rec.PLANNING_EXCEPTION_SET,'!'))           <> NVL(l_msb_rec.PLANNING_EXCEPTION_SET,'!'))
            OR (NVL(cur.END_ASSEMBLY_PEGGING_FLAG,     NVL(l_msb_rec.END_ASSEMBLY_PEGGING_FLAG,'!'))        <> NVL(l_msb_rec.END_ASSEMBLY_PEGGING_FLAG,'!'))
            OR (NVL(cur.PLANNED_INV_POINT_FLAG,        NVL(l_msb_rec.PLANNED_INV_POINT_FLAG,'!'))           <> NVL(l_msb_rec.PLANNED_INV_POINT_FLAG,'!'))
            OR (NVL(cur.CREATE_SUPPLY_FLAG,            NVL(l_msb_rec.CREATE_SUPPLY_FLAG,'!'))               <> NVL(l_msb_rec.CREATE_SUPPLY_FLAG,'!'))
            OR (NVL(cur.EXCLUDE_FROM_BUDGET_FLAG,      NVL(l_msb_rec.EXCLUDE_FROM_BUDGET_FLAG,-999999))     <> NVL(l_msb_rec.EXCLUDE_FROM_BUDGET_FLAG,-999999))
            OR (NVL(cur.ROUNDING_CONTROL_TYPE,         NVL(l_msb_rec.ROUNDING_CONTROL_TYPE,-999999))        <> NVL(l_msb_rec.ROUNDING_CONTROL_TYPE,-999999))
            OR (NVL(cur.SHRINKAGE_RATE,                NVL(l_msb_rec.SHRINKAGE_RATE,-999999))               <> NVL(l_msb_rec.SHRINKAGE_RATE,-999999))
            OR (NVL(cur.ACCEPTABLE_EARLY_DAYS,         NVL(l_msb_rec.ACCEPTABLE_EARLY_DAYS,-999999))        <> NVL(l_msb_rec.ACCEPTABLE_EARLY_DAYS,-999999))
            OR (NVL(cur.REPETITIVE_PLANNING_FLAG,      NVL(l_msb_rec.REPETITIVE_PLANNING_FLAG,'!'))         <> NVL(l_msb_rec.REPETITIVE_PLANNING_FLAG,'!'))
            OR (NVL(cur.OVERRUN_PERCENTAGE,            NVL(l_msb_rec.OVERRUN_PERCENTAGE,-999999))           <> NVL(l_msb_rec.OVERRUN_PERCENTAGE,-999999))
            OR (NVL(cur.ACCEPTABLE_RATE_DECREASE,      NVL(l_msb_rec.ACCEPTABLE_RATE_DECREASE,-999999))     <> NVL(l_msb_rec.ACCEPTABLE_RATE_DECREASE,-999999))
            OR (NVL(cur.ACCEPTABLE_RATE_INCREASE,      NVL(l_msb_rec.ACCEPTABLE_RATE_INCREASE,-999999))     <> NVL(l_msb_rec.ACCEPTABLE_RATE_INCREASE,-999999))
            OR (NVL(cur.MRP_CALCULATE_ATP_FLAG,        NVL(l_msb_rec.MRP_CALCULATE_ATP_FLAG,'!'))           <> NVL(l_msb_rec.MRP_CALCULATE_ATP_FLAG,'!'))
            OR (NVL(cur.AUTO_REDUCE_MPS,               NVL(l_msb_rec.AUTO_REDUCE_MPS,-999999))              <> NVL(l_msb_rec.AUTO_REDUCE_MPS,-999999))
            OR (NVL(cur.PLANNING_TIME_FENCE_CODE,      NVL(l_msb_rec.PLANNING_TIME_FENCE_CODE,-999999))     <> NVL(l_msb_rec.PLANNING_TIME_FENCE_CODE,-999999))
            OR (NVL(cur.PLANNING_TIME_FENCE_DAYS,      NVL(l_msb_rec.PLANNING_TIME_FENCE_DAYS,-999999))     <> NVL(l_msb_rec.PLANNING_TIME_FENCE_DAYS,-999999))
            OR (NVL(cur.DEMAND_TIME_FENCE_CODE,        NVL(l_msb_rec.DEMAND_TIME_FENCE_CODE,-999999))       <> NVL(l_msb_rec.DEMAND_TIME_FENCE_CODE,-999999))
            OR (NVL(cur.DEMAND_TIME_FENCE_DAYS,        NVL(l_msb_rec.DEMAND_TIME_FENCE_DAYS,-999999))       <> NVL(l_msb_rec.DEMAND_TIME_FENCE_DAYS,-999999))
            OR (NVL(cur.RELEASE_TIME_FENCE_CODE,       NVL(l_msb_rec.RELEASE_TIME_FENCE_CODE,-999999))      <> NVL(l_msb_rec.RELEASE_TIME_FENCE_CODE,-999999))
            OR (NVL(cur.RELEASE_TIME_FENCE_DAYS,       NVL(l_msb_rec.RELEASE_TIME_FENCE_DAYS,-999999))      <> NVL(l_msb_rec.RELEASE_TIME_FENCE_DAYS,-999999))
            OR (NVL(cur.SUBSTITUTION_WINDOW_CODE,      NVL(l_msb_rec.SUBSTITUTION_WINDOW_CODE,-999999))     <> NVL(l_msb_rec.SUBSTITUTION_WINDOW_CODE,-999999))
            OR (NVL(cur.SUBSTITUTION_WINDOW_DAYS,      NVL(l_msb_rec.SUBSTITUTION_WINDOW_DAYS,-999999))     <> NVL(l_msb_rec.SUBSTITUTION_WINDOW_DAYS,-999999))
            OR (NVL(cur.DAYS_TGT_INV_SUPPLY,           NVL(l_msb_rec.DAYS_TGT_INV_SUPPLY,-999999))          <> NVL(l_msb_rec.DAYS_TGT_INV_SUPPLY,-999999))
            OR (NVL(cur.DAYS_TGT_INV_WINDOW,           NVL(l_msb_rec.DAYS_TGT_INV_WINDOW,-999999))          <> NVL(l_msb_rec.DAYS_TGT_INV_WINDOW,-999999))
            OR (NVL(cur.DAYS_MAX_INV_SUPPLY,           NVL(l_msb_rec.DAYS_MAX_INV_SUPPLY,-999999))          <> NVL(l_msb_rec.DAYS_MAX_INV_SUPPLY,-999999))
            OR (NVL(cur.DAYS_MAX_INV_WINDOW,           NVL(l_msb_rec.DAYS_MAX_INV_WINDOW,-999999))          <> NVL(l_msb_rec.DAYS_MAX_INV_WINDOW,-999999))
            OR (NVL(cur.CRITICAL_COMPONENT_FLAG,       NVL(l_msb_rec.CRITICAL_COMPONENT_FLAG,-999999))      <> NVL(l_msb_rec.CRITICAL_COMPONENT_FLAG,-999999))
            OR (NVL(cur.CONVERGENCE,                   NVL(l_msb_rec.CONVERGENCE,-999999))                  <> NVL(l_msb_rec.CONVERGENCE,-999999))
            OR (NVL(cur.CONTINOUS_TRANSFER,            NVL(l_msb_rec.CONTINOUS_TRANSFER,-999999))           <> NVL(l_msb_rec.CONTINOUS_TRANSFER,-999999))
            OR (NVL(cur.DIVERGENCE,                    NVL(l_msb_rec.DIVERGENCE,-999999))                   <> NVL(l_msb_rec.DIVERGENCE,-999999))
            OR (NVL(cur.DRP_PLANNED_FLAG,              NVL(l_msb_rec.DRP_PLANNED_FLAG,-999999))             <> NVL(l_msb_rec.DRP_PLANNED_FLAG,-999999))
            OR (NVL(cur.REPAIR_LEADTIME,               NVL(l_msb_rec.REPAIR_LEADTIME,-999999))              <> NVL(l_msb_rec.REPAIR_LEADTIME,-999999))
            OR (NVL(cur.REPAIR_YIELD,                  NVL(l_msb_rec.REPAIR_YIELD,-999999))                 <> NVL(l_msb_rec.REPAIR_YIELD,-999999))
            OR (NVL(cur.PREPOSITION_POINT,             NVL(l_msb_rec.PREPOSITION_POINT,'!'))                <> NVL(l_msb_rec.PREPOSITION_POINT,'!'))
            OR (NVL(cur.REPAIR_PROGRAM,                NVL(l_msb_rec.REPAIR_PROGRAM,-999999))               <> NVL(l_msb_rec.REPAIR_PROGRAM,-999999))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('MPSMRPPLANNING'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('MPSMRPPLANNING'));
               END IF;
            END IF;

            --Lead Times
            IF (NVL(cur.PREPROCESSING_LEAD_TIME,       NVL(l_msb_rec.PREPROCESSING_LEAD_TIME,-999999))      <> NVL(l_msb_rec.PREPROCESSING_LEAD_TIME,-999999))
            OR (NVL(cur.FULL_LEAD_TIME,                NVL(l_msb_rec.FULL_LEAD_TIME,-999999))               <> NVL(l_msb_rec.FULL_LEAD_TIME,-999999))
            OR (NVL(cur.POSTPROCESSING_LEAD_TIME,      NVL(l_msb_rec.POSTPROCESSING_LEAD_TIME,-999999))     <> NVL(l_msb_rec.POSTPROCESSING_LEAD_TIME,-999999))
            OR (NVL(cur.FIXED_LEAD_TIME,               NVL(l_msb_rec.FIXED_LEAD_TIME,-999999))              <> NVL(l_msb_rec.FIXED_LEAD_TIME,-999999))
            OR (NVL(cur.VARIABLE_LEAD_TIME,            NVL(l_msb_rec.VARIABLE_LEAD_TIME,-999999))           <> NVL(l_msb_rec.VARIABLE_LEAD_TIME,-999999))
            OR (NVL(cur.CUM_MANUFACTURING_LEAD_TIME,   NVL(l_msb_rec.CUM_MANUFACTURING_LEAD_TIME,-999999))  <> NVL(l_msb_rec.CUM_MANUFACTURING_LEAD_TIME,-999999))
            OR (NVL(cur.CUMULATIVE_TOTAL_LEAD_TIME,    NVL(l_msb_rec.CUMULATIVE_TOTAL_LEAD_TIME,-999999))   <> NVL(l_msb_rec.CUMULATIVE_TOTAL_LEAD_TIME,-999999))
            OR (NVL(cur.LEAD_TIME_LOT_SIZE,            NVL(l_msb_rec.LEAD_TIME_LOT_SIZE,-999999))           <> NVL(l_msb_rec.LEAD_TIME_LOT_SIZE,-999999))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('LEADTIMES'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('LEADTIMES'));
               END IF;
            END IF;

            --Work In Progress
            IF (NVL(cur.BUILD_IN_WIP_FLAG,             NVL(l_msb_rec.BUILD_IN_WIP_FLAG,'!'))                <> NVL(l_msb_rec.BUILD_IN_WIP_FLAG,'!'))
            OR (NVL(cur.WIP_SUPPLY_TYPE,               NVL(l_msb_rec.WIP_SUPPLY_TYPE,-999999))              <> NVL(l_msb_rec.WIP_SUPPLY_TYPE,-999999))
            OR (NVL(cur.WIP_SUPPLY_SUBINVENTORY,       NVL(l_msb_rec.WIP_SUPPLY_SUBINVENTORY,'!'))          <> NVL(l_msb_rec.WIP_SUPPLY_SUBINVENTORY,'!'))
            OR (NVL(cur.WIP_SUPPLY_LOCATOR_ID,         NVL(l_msb_rec.WIP_SUPPLY_LOCATOR_ID,-999999))        <> NVL(l_msb_rec.WIP_SUPPLY_LOCATOR_ID,-999999))
            OR (NVL(cur.OVERCOMPLETION_TOLERANCE_TYPE, NVL(l_msb_rec.OVERCOMPLETION_TOLERANCE_TYPE,-999999))<> NVL(l_msb_rec.OVERCOMPLETION_TOLERANCE_TYPE,-999999))
            OR (NVL(cur.OVERCOMPLETION_TOLERANCE_VALUE,NVL(l_msb_rec.OVERCOMPLETION_TOLERANCE_VALUE,-999999))<>NVL(l_msb_rec.OVERCOMPLETION_TOLERANCE_VALUE,-999999))
            OR (NVL(cur.INVENTORY_CARRY_PENALTY,       NVL(l_msb_rec.INVENTORY_CARRY_PENALTY,-999999))      <> NVL(l_msb_rec.INVENTORY_CARRY_PENALTY,-999999))
            OR (NVL(cur.OPERATION_SLACK_PENALTY,       NVL(l_msb_rec.OPERATION_SLACK_PENALTY,-999999))      <> NVL(l_msb_rec.OPERATION_SLACK_PENALTY,-999999))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('WORKINPROGRESS'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('WORKINPROGRESS'));
               END IF;
            END IF;

            --Order Management
            IF (NVL(cur.CUSTOMER_ORDER_FLAG,           NVL(l_msb_rec.CUSTOMER_ORDER_FLAG,'!'))              <> NVL(l_msb_rec.CUSTOMER_ORDER_FLAG,'!'))
            OR (NVL(cur.CUSTOMER_ORDER_ENABLED_FLAG,   NVL(l_msb_rec.CUSTOMER_ORDER_ENABLED_FLAG,'!'))      <> NVL(l_msb_rec.CUSTOMER_ORDER_ENABLED_FLAG,'!'))
            OR (NVL(cur.INTERNAL_ORDER_FLAG,           NVL(l_msb_rec.INTERNAL_ORDER_FLAG,'!'))              <> NVL(l_msb_rec.INTERNAL_ORDER_FLAG,'!'))
            OR (NVL(cur.INTERNAL_ORDER_ENABLED_FLAG,   NVL(l_msb_rec.INTERNAL_ORDER_ENABLED_FLAG,'!'))      <> NVL(l_msb_rec.INTERNAL_ORDER_ENABLED_FLAG,'!'))
            OR (NVL(cur.SHIPPABLE_ITEM_FLAG,           NVL(l_msb_rec.SHIPPABLE_ITEM_FLAG,'!'))              <> NVL(l_msb_rec.SHIPPABLE_ITEM_FLAG,'!'))
            OR (NVL(cur.SO_TRANSACTIONS_FLAG,          NVL(l_msb_rec.SO_TRANSACTIONS_FLAG,'!'))             <> NVL(l_msb_rec.SO_TRANSACTIONS_FLAG,'!'))
            OR (NVL(cur.DEFAULT_SHIPPING_ORG,          NVL(l_msb_rec.DEFAULT_SHIPPING_ORG,-999999))         <> NVL(l_msb_rec.DEFAULT_SHIPPING_ORG,-999999))
            OR (NVL(cur.DEFAULT_SO_SOURCE_TYPE,        NVL(l_msb_rec.DEFAULT_SO_SOURCE_TYPE,'!'))           <> NVL(l_msb_rec.DEFAULT_SO_SOURCE_TYPE,'!'))
            OR (NVL(cur.PICK_COMPONENTS_FLAG,          NVL(l_msb_rec.PICK_COMPONENTS_FLAG,'!'))             <> NVL(l_msb_rec.PICK_COMPONENTS_FLAG,'!'))
            OR (NVL(cur.REPLENISH_TO_ORDER_FLAG,       NVL(l_msb_rec.REPLENISH_TO_ORDER_FLAG,'!'))          <> NVL(l_msb_rec.REPLENISH_TO_ORDER_FLAG,'!'))
            OR (NVL(cur.ATP_FLAG,                      NVL(l_msb_rec.ATP_FLAG,'!'))                         <> NVL(l_msb_rec.ATP_FLAG,'!'))
            OR (NVL(cur.ATP_COMPONENTS_FLAG,           NVL(l_msb_rec.ATP_COMPONENTS_FLAG,'!'))              <> NVL(l_msb_rec.ATP_COMPONENTS_FLAG,'!'))
            OR (NVL(cur.ATP_RULE_ID,                   NVL(l_msb_rec.ATP_RULE_ID,-999999))                  <> NVL(l_msb_rec.ATP_RULE_ID,-999999))
            OR (NVL(cur.SHIP_MODEL_COMPLETE_FLAG,      NVL(l_msb_rec.SHIP_MODEL_COMPLETE_FLAG,'!'))         <> NVL(l_msb_rec.SHIP_MODEL_COMPLETE_FLAG,'!'))
            OR (NVL(cur.RETURNABLE_FLAG,               NVL(l_msb_rec.RETURNABLE_FLAG,'!'))                  <> NVL(l_msb_rec.RETURNABLE_FLAG,'!'))
            OR (NVL(cur.RETURN_INSPECTION_REQUIREMENT, NVL(l_msb_rec.RETURN_INSPECTION_REQUIREMENT,-999999))<> NVL(l_msb_rec.RETURN_INSPECTION_REQUIREMENT,-999999))
            OR (NVL(cur.FINANCING_ALLOWED_FLAG,        NVL(l_msb_rec.FINANCING_ALLOWED_FLAG,'!'))           <> NVL(l_msb_rec.FINANCING_ALLOWED_FLAG,'!'))
            OR (NVL(cur.OVER_SHIPMENT_TOLERANCE,       NVL(l_msb_rec.OVER_SHIPMENT_TOLERANCE,-999999))      <> NVL(l_msb_rec.OVER_SHIPMENT_TOLERANCE,-999999))
            OR (NVL(cur.OVER_SHIPMENT_TOLERANCE,       NVL(l_msb_rec.OVER_SHIPMENT_TOLERANCE,-999999))      <> NVL(l_msb_rec.OVER_SHIPMENT_TOLERANCE,-999999))
            OR (NVL(cur.UNDER_SHIPMENT_TOLERANCE,      NVL(l_msb_rec.UNDER_SHIPMENT_TOLERANCE,-999999))     <> NVL(l_msb_rec.UNDER_SHIPMENT_TOLERANCE,-999999))
            OR (NVL(cur.OVER_RETURN_TOLERANCE,         NVL(l_msb_rec.OVER_RETURN_TOLERANCE,-999999))        <> NVL(l_msb_rec.OVER_RETURN_TOLERANCE,-999999))
            OR (NVL(cur.UNDER_RETURN_TOLERANCE,        NVL(l_msb_rec.UNDER_RETURN_TOLERANCE,-999999))       <> NVL(l_msb_rec.UNDER_RETURN_TOLERANCE,-999999))
            OR (NVL(cur.PICKING_RULE_ID,               NVL(l_msb_rec.PICKING_RULE_ID,-999999))              <> NVL(l_msb_rec.PICKING_RULE_ID,-999999))
            OR (NVL(cur.CHARGE_PERIODICITY_CODE,       NVL(l_msb_rec.CHARGE_PERIODICITY_CODE,'!'))          <> NVL(l_msb_rec.CHARGE_PERIODICITY_CODE,'!'))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('ORDERMANAGEMENT'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('ORDERMANAGEMENT'));
               END IF;
            END IF;

            --Service Attributes
            IF (NVL(cur.CONTRACT_ITEM_TYPE_CODE,       NVL(l_msb_rec.CONTRACT_ITEM_TYPE_CODE,'!'))          <> NVL(l_msb_rec.CONTRACT_ITEM_TYPE_CODE,'!'))
            OR (NVL(cur.COVERAGE_SCHEDULE_ID,          NVL(l_msb_rec.COVERAGE_SCHEDULE_ID,-999999))         <> NVL(l_msb_rec.COVERAGE_SCHEDULE_ID,-999999))
            OR (NVL(cur.SERVICE_DURATION_PERIOD_CODE,  NVL(l_msb_rec.SERVICE_DURATION_PERIOD_CODE,'!'))     <> NVL(l_msb_rec.SERVICE_DURATION_PERIOD_CODE,'!'))
            OR (NVL(cur.MATERIAL_BILLABLE_FLAG,        NVL(l_msb_rec.MATERIAL_BILLABLE_FLAG,'!'))           <> NVL(l_msb_rec.MATERIAL_BILLABLE_FLAG,'!'))
            OR (NVL(cur.SERV_REQ_ENABLED_CODE,         NVL(l_msb_rec.SERV_REQ_ENABLED_CODE,'!'))            <> NVL(l_msb_rec.SERV_REQ_ENABLED_CODE,'!'))
            OR (NVL(cur.COMMS_ACTIVATION_REQD_FLAG,    NVL(l_msb_rec.COMMS_ACTIVATION_REQD_FLAG,'!'))       <> NVL(l_msb_rec.COMMS_ACTIVATION_REQD_FLAG,'!'))
            OR (NVL(cur.SERVICEABLE_PRODUCT_FLAG,      NVL(l_msb_rec.SERVICEABLE_PRODUCT_FLAG,'!'))         <> NVL(l_msb_rec.SERVICEABLE_PRODUCT_FLAG,'!'))
            OR (NVL(cur.SERV_BILLING_ENABLED_FLAG,     NVL(l_msb_rec.SERV_BILLING_ENABLED_FLAG,'!'))        <> NVL(l_msb_rec.SERV_BILLING_ENABLED_FLAG,'!'))
            OR (NVL(cur.DEFECT_TRACKING_ON_FLAG,       NVL(l_msb_rec.DEFECT_TRACKING_ON_FLAG,'!'))          <> NVL(l_msb_rec.DEFECT_TRACKING_ON_FLAG,'!'))
            OR (NVL(cur.RECOVERED_PART_DISP_CODE,      NVL(l_msb_rec.RECOVERED_PART_DISP_CODE,'!'))         <> NVL(l_msb_rec.RECOVERED_PART_DISP_CODE,'!'))
            OR (NVL(cur.COMMS_NL_TRACKABLE_FLAG,       NVL(l_msb_rec.COMMS_NL_TRACKABLE_FLAG,'!'))          <> NVL(l_msb_rec.COMMS_NL_TRACKABLE_FLAG,'!'))
            OR (NVL(cur.SERVICE_STARTING_DELAY,        NVL(l_msb_rec.SERVICE_STARTING_DELAY,-999999))       <> NVL(l_msb_rec.SERVICE_STARTING_DELAY,-999999))
            OR (NVL(cur.ASSET_CREATION_CODE,           NVL(l_msb_rec.ASSET_CREATION_CODE,'!'))              <> NVL(l_msb_rec.ASSET_CREATION_CODE,'!'))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('SERVICE'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('SERVICE'));
               END IF;
            END IF;

            --Web Option
            IF (NVL(cur.WEB_STATUS,                    NVL(l_msb_rec.WEB_STATUS,'!'))                       <> NVL(l_msb_rec.WEB_STATUS,'!'))
            OR (NVL(cur.ORDERABLE_ON_WEB_FLAG,         NVL(l_msb_rec.ORDERABLE_ON_WEB_FLAG,'!'))            <> NVL(l_msb_rec.ORDERABLE_ON_WEB_FLAG,'!'))
            OR (NVL(cur.BACK_ORDERABLE_FLAG,           NVL(l_msb_rec.BACK_ORDERABLE_FLAG,'!'))              <> NVL(l_msb_rec.BACK_ORDERABLE_FLAG,'!'))
            OR (NVL(cur.MINIMUM_LICENSE_QUANTITY,      NVL(l_msb_rec.MINIMUM_LICENSE_QUANTITY,-999999))     <> NVL(l_msb_rec.MINIMUM_LICENSE_QUANTITY,-999999))
            THEN
               IF l_attr_grps IS NULL THEN
                  l_attr_grps := TO_CHAR(get_attribute_group_id('WEBOPTION'));
               ELSE
                  l_attr_grps := l_attr_grps ||','||TO_CHAR(get_attribute_group_id('WEBOPTION'));
               END IF;
            END IF;

            IF l_attr_grps IS NOT NULL THEN
               IF l_inv_debug_level IN(101, 102) THEN
                  INVPUTLI.info('INVNIRIS.change_policy_check: Attr Grps Changed:' || l_attr_grps);
               END IF;

               IF cur.current_phase_id is NOT NULL THEN
                  --Bug 5367962 Find if any of the AG as ChanhePolicy of 'NOT ALLOWED'
                  EXECUTE IMMEDIATE
                    'BEGIN                                                      '||
                    '    ENG_CHANGE_POLICY_PKG.GET_OPATTR_CHANGEPOLICY(         '||
                    '       P_API_VERSION         => 1.0                        '||
                    '      ,X_RETURN_STATUS       => :l_return_status           '||
                    '      ,P_CATALOG_CATEGORY_ID => :cur.item_catalog_group_id '||
                    '      ,P_ITEM_LIFECYCLE_ID   => :cur.lifecycle_id          '||
                    '      ,P_LIFECYCLE_PHASE_ID  => :cur.current_phase_id      '||
                    '      ,P_ATTRIBUTE_GRP_IDS   => :l_attr_grps               '||
                    '      ,X_POLICY_VALUE        => :l_policy_value);          '||
                    ' EXCEPTION                                                 '||
                    '    WHEN OTHERS THEN                                       '||
                    '      NULL;                                                '||
                    ' END;                                                      '
                  USING OUT l_return_status,
                        IN  cur.item_catalog_group_id,
                        IN  cur.lifecycle_id,
                        IN  cur.current_phase_id,
                        IN  l_attr_grps,
                        OUT l_policy_value;

		  --If the above call returns NULL or ALLOWED CO is not required except the case
		  --when add to CO is true
                  --If NOT_ALLOWED is returned find which AG has it
                  IF l_policy_value = 'NOT_ALLOWED' THEN
                     WHILE ((l_delim_pos > 0) AND (l_ch_policy_found = FALSE)) LOOP
                        l_delim_pos := instr(l_attr_grps,',');
                        IF(l_delim_pos = 0 AND l_attr_grps is not null) then
                           l_attr_group_id := l_attr_grps;
                        ELSE
                           l_attr_group_id := substr(l_attr_grps,1,l_delim_pos-1);
                           l_attr_grps := substr(l_attr_grps,l_delim_pos+1);
                        END IF;
                        EXECUTE IMMEDIATE
                          'BEGIN                                                      '||
                          '    ENG_CHANGE_POLICY_PKG.GET_OPATTR_CHANGEPOLICY(         '||
                          '       P_API_VERSION         => 1.0                        '||
                          '      ,X_RETURN_STATUS       => :l_return_status           '||
                          '      ,P_CATALOG_CATEGORY_ID => :cur.item_catalog_group_id '||
                          '      ,P_ITEM_LIFECYCLE_ID   => :cur.lifecycle_id          '||
                          '      ,P_LIFECYCLE_PHASE_ID  => :cur.current_phase_id      '||
                          '      ,P_ATTRIBUTE_GRP_IDS   => :l_attr_group_id           '||
                          '      ,X_POLICY_VALUE        => :l_policy_value);          '||
                          ' EXCEPTION                                                 '||
                          '    WHEN OTHERS THEN                                       '||
                          '      NULL;                                                '||
                          ' END;                                                      '
                        USING OUT l_return_status,
                              IN  cur.item_catalog_group_id,
                              IN  cur.lifecycle_id,
                              IN  cur.current_phase_id,
                              IN  l_attr_group_id,
                              OUT l_policy_value;

                        IF l_policy_value = 'NOT_ALLOWED' THEN
                           l_ch_policy_found := TRUE;
                        END IF;
                     END LOOP;
		  END IF; --l_policy_value = NOT ALLOWED
               ELSE    --current_phase_id is NULL
                     l_policy_value := 'CHANGE_ORDER_REQUIRED';
	       END IF; --cur.current_phase_id is not NULL

               IF l_policy_value = 'NOT_ALLOWED' THEN
                  UPDATE mtl_system_items_interface
                  SET    process_flag = 3
                  WHERE  rowid        = cur.rowid;

                  SELECT ATTR_GROUP_DISP_NAME INTO l_attr_grp_name
		  FROM EGO_ATTR_GROUPS_V
		  WHERE ATTR_GROUP_ID = l_attr_group_id;

                  FND_MESSAGE.SET_NAME('INV','INV_IOI_CHANGE_NOT_ALLOWED');
		  FND_MESSAGE.SET_TOKEN('ATTR_GROUP_NAME',l_attr_grp_name);
		  l_msg_text := FND_MESSAGE.GET;
                  l_error_logged := INVPUOPI.mtl_log_interface_err(
                                cur.organization_id,
                                User_Id,
                                Login_Id,
                                Prog_AppId,
                                Prog_Id,
                                Request_id,
                                cur.transaction_id,
                                l_msg_text,
                                'APPROVAL_STATUS',
                                'MTL_SYTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',
                                l_Err_Text);
                  IF l_error_logged < 0 THEN
                     Raise LOGGING_ERR;
                  END IF;
               ELSIF l_policy_value = 'CHANGE_ORDER_REQUIRED' OR
	             (NVL(l_import_co_option,'N') = 'Y' AND l_structure_type_id IS NOT NULL)
	          THEN
                  --4723028 If called from CO, dont move to 5.
                  IF INSTR(l_process_control,'ENG_CALL:Y') = 0 THEN
                     IF l_inv_debug_level IN(101, 102) THEN
                        INVPUTLI.info('INVNIRIS.change_policy_check: Moving to 5 for CO');
                     END IF;

                     --4696529: Insert row into interface table to propogate changes to production.
                     IF l_msb_rec.inventory_item_status_code <> NVL(cur.inventory_item_status_code,l_msb_rec.inventory_item_status_code)
                        OR l_msb_rec.description <> NVL(cur.description,l_msb_rec.description)
                     THEN
                         INSERT INTO mtl_system_items_interface(
                            organization_id
                           ,inventory_item_id
                           ,process_flag
                           ,set_process_id
                           ,transaction_type
                           ,transaction_id
                           ,inventory_item_status_code
                           ,allowed_units_lookup_code
                           ,item_type
                           ,description)
                         VALUES(
                            cur.organization_id
                           ,cur.inventory_item_id
                           ,1
                           ,cur.set_process_id
                           ,'UPDATE'
                           ,mtl_system_items_interface_s.nextval
                           ,cur.inventory_item_status_code   --Bug 5383744
                           ,cur.allowed_units_lookup_code
                           ,cur.item_type
                           ,NVL(cur.description,l_msb_rec.description));
                     END IF;

                     UPDATE mtl_system_items_interface
                     SET    process_flag = 5,
		            --bug 5383744
		            inventory_item_status_code = NVL(cur.inventory_item_status_code,l_msb_rec.inventory_item_status_code)
                     WHERE  rowid        = cur.rowid;

                  END IF; --ENG call
               END IF;  --l_policy_value
            END IF; --l_attr_grps IS NOT NULL

         END IF; -- NVL(l_msb_rec.approval_status,'A') ='A'
      END LOOP;

   /*-- Bug 5216971 : Added the and condition on structure_type_id. Rows should not be
       marked to 5 if they are coming from structure import and have no changes on item
       specified. For rows which have changes to attributes will be set to 5
       in the above for loop. */
      -- 6157001 : Added the ENG_CALL check
      IF NVL(l_import_co_option,'N') = 'Y'
         AND l_structure_type_id IS NULL
	 AND INSTR(l_process_control,'ENG_CALL:Y') = 0
      THEN

         --Start: 5383744: Donot move 5 for no attrib values
         FOR cur IN c_check_attributes_policy LOOP

            SELECT * INTO  l_msb_rec
            FROM   mtl_system_items
            WHERE inventory_item_id = cur.inventory_item_id
            AND   organization_id   = cur.organization_id;

            --Inventory Attribute group
            IF cur.AUTO_LOT_ALPHA_PREFIX IS NOT NULL
            OR cur.AUTO_SERIAL_ALPHA_PREFIX IS NOT NULL
            OR cur.CYCLE_COUNT_ENABLED_FLAG IS NOT NULL
            OR cur.INVENTORY_ITEM_FLAG IS NOT NULL
            OR cur.LOCATION_CONTROL_CODE IS NOT NULL
            OR cur.MTL_TRANSACTIONS_ENABLED_FLAG IS NOT NULL
            OR cur.NEGATIVE_MEASUREMENT_ERROR IS NOT NULL
            OR cur.POSITIVE_MEASUREMENT_ERROR IS NOT NULL
            OR cur.RESERVABLE_TYPE IS NOT NULL
            OR cur.RESTRICT_LOCATORS_CODE IS NOT NULL
            OR cur.RESTRICT_SUBINVENTORIES_CODE IS NOT NULL
            OR cur.REVISION_QTY_CONTROL_CODE IS NOT NULL
            OR cur.SERIAL_NUMBER_CONTROL_CODE IS NOT NULL
            OR cur.SHELF_LIFE_CODE IS NOT NULL
            OR cur.SHELF_LIFE_DAYS IS NOT NULL
            OR cur.START_AUTO_LOT_NUMBER IS NOT NULL
            OR cur.START_AUTO_SERIAL_NUMBER IS NOT NULL
            OR cur.STOCK_ENABLED_FLAG IS NOT NULL
            OR cur.LOT_CONTROL_CODE IS NOT NULL
            OR cur.CHECK_SHORTAGES_FLAG IS NOT NULL
            OR cur.LOT_STATUS_ENABLED IS NOT NULL
            OR cur.DEFAULT_LOT_STATUS_ID IS NOT NULL
            OR cur.SERIAL_STATUS_ENABLED IS NOT NULL
            OR cur.DEFAULT_SERIAL_STATUS_ID IS NOT NULL
            OR cur.LOT_SPLIT_ENABLED IS NOT NULL
            OR cur.LOT_MERGE_ENABLED IS NOT NULL
            OR cur.BULK_PICKED_FLAG IS NOT NULL
            OR cur.LOT_TRANSLATE_ENABLED IS NOT NULL
            OR cur.LOT_SUBSTITUTION_ENABLED IS NOT NULL
            OR cur.LOT_DIVISIBLE_FLAG IS NOT NULL
            OR cur.GRADE_CONTROL_FLAG IS NOT NULL
            OR cur.DEFAULT_GRADE IS NOT NULL
            OR cur.CHILD_LOT_FLAG IS NOT NULL
            OR cur.PARENT_CHILD_GENERATION_FLAG IS NOT NULL
            OR cur.CHILD_LOT_PREFIX IS NOT NULL
            OR cur.CHILD_LOT_STARTING_NUMBER IS NOT NULL
            OR cur.CHILD_LOT_VALIDATION_FLAG IS NOT NULL
            OR cur.RETEST_INTERVAL IS NOT NULL
            OR cur.EXPIRATION_ACTION_INTERVAL IS NOT NULL
            OR cur.EXPIRATION_ACTION_CODE IS NOT NULL
            OR cur.MATURITY_DAYS IS NOT NULL
            OR cur.HOLD_DAYS IS NOT NULL
            OR cur.COPY_LOT_ATTRIBUTE_FLAG IS NOT NULL


            --BOM Attribute Group
            OR cur.BASE_ITEM_ID IS NOT NULL
            OR cur.BOM_ENABLED_FLAG IS NOT NULL
            OR cur.BOM_ITEM_TYPE IS NOT NULL
            OR cur.ENG_ITEM_FLAG IS NOT NULL
            OR cur.EFFECTIVITY_CONTROL IS NOT NULL
            OR cur.CONFIG_MODEL_TYPE IS NOT NULL
            OR cur.AUTO_CREATED_CONFIG_FLAG IS NOT NULL
            OR cur.CONFIG_ORGS IS NOT NULL
            OR cur.CONFIG_MATCH IS NOT NULL

            --Asset Management Group
            OR cur.EAM_ITEM_TYPE IS NOT NULL
            OR cur.EAM_ACTIVITY_TYPE_CODE IS NOT NULL
            OR cur.EAM_ACTIVITY_CAUSE_CODE IS NOT NULL
            OR cur.EAM_ACT_SHUTDOWN_STATUS IS NOT NULL
            OR cur.EAM_ACT_NOTIFICATION_FLAG IS NOT NULL
            OR cur.EAM_ACTIVITY_SOURCE_CODE IS NOT NULL

            --Costing Attribute Group
            OR cur.COSTING_ENABLED_FLAG IS NOT NULL
            OR cur.COST_OF_SALES_ACCOUNT IS NOT NULL
            OR cur.DEFAULT_INCLUDE_IN_ROLLUP_FLAG IS NOT NULL
            OR cur.STD_LOT_SIZE IS NOT NULL
            OR cur.INVENTORY_ASSET_FLAG IS NOT NULL

            --Purchasing Attribute Group
            OR cur.ALLOW_ITEM_DESC_UPDATE_FLAG IS NOT NULL
            OR cur.ASSET_CATEGORY_ID IS NOT NULL
            OR cur.BUYER_ID IS NOT NULL
            OR cur.ENCUMBRANCE_ACCOUNT IS NOT NULL
            OR cur.EXPENSE_ACCOUNT IS NOT NULL
            OR cur.HAZARD_CLASS_ID IS NOT NULL
            OR cur.LIST_PRICE_PER_UNIT IS NOT NULL
            OR cur.MARKET_PRICE IS NOT NULL
            OR cur.MUST_USE_APPROVED_VENDOR_FLAG IS NOT NULL
            OR cur.OUTSIDE_OPERATION_UOM_TYPE IS NOT NULL
            OR cur.PRICE_TOLERANCE_PERCENT IS NOT NULL
            OR cur.PURCHASING_ITEM_FLAG IS NOT NULL
            OR cur.RFQ_REQUIRED_FLAG IS NOT NULL
            OR cur.ROUNDING_FACTOR IS NOT NULL
            OR cur.TAXABLE_FLAG IS NOT NULL
            OR cur.UNIT_OF_ISSUE IS NOT NULL
            OR cur.UN_NUMBER_ID IS NOT NULL
            OR cur.INSPECTION_REQUIRED_FLAG IS NOT NULL
            OR cur.INVOICE_CLOSE_TOLERANCE IS NOT NULL
            OR cur.RECEIPT_REQUIRED_FLAG IS NOT NULL
            OR cur.RECEIVE_CLOSE_TOLERANCE IS NOT NULL
            OR cur.OUTSIDE_OPERATION_FLAG IS NOT NULL
            OR cur.PURCHASING_TAX_CODE IS NOT NULL
            OR cur.OUTSOURCED_ASSEMBLY IS NOT NULL
            OR cur.PURCHASING_ENABLED_FLAG IS NOT NULL

            --Receiving Attribute Group
            OR cur.ALLOW_EXPRESS_DELIVERY_FLAG IS NOT NULL
            OR cur.ALLOW_SUBSTITUTE_RECEIPTS_FLAG IS NOT NULL
            OR cur.ALLOW_UNORDERED_RECEIPTS_FLAG IS NOT NULL
            OR cur.DAYS_EARLY_RECEIPT_ALLOWED IS NOT NULL
            OR cur.ENFORCE_SHIP_TO_LOCATION_CODE IS NOT NULL
            OR cur.QTY_RCV_TOLERANCE IS NOT NULL
            OR cur.RECEIPT_DAYS_EXCEPTION_CODE IS NOT NULL
            OR cur.RECEIVING_ROUTING_ID IS NOT NULL
            OR cur.DAYS_LATE_RECEIPT_ALLOWED IS NOT NULL
            OR cur.QTY_RCV_EXCEPTION_CODE IS NOT NULL

            --Process Manufacturing Attribute Group
            OR cur.RECIPE_ENABLED_FLAG IS NOT NULL
            OR cur.CAS_NUMBER IS NOT NULL
            OR cur.HAZARDOUS_MATERIAL_FLAG IS NOT NULL
            OR cur.PROCESS_YIELD_LOCATOR_ID IS NOT NULL
            OR cur.PROCESS_QUALITY_ENABLED_FLAG IS NOT NULL
            OR cur.PROCESS_SUPPLY_LOCATOR_ID IS NOT NULL
            OR cur.PROCESS_EXECUTION_ENABLED_FLAG IS NOT NULL
            OR cur.PROCESS_COSTING_ENABLED_FLAG IS NOT NULL
            OR cur.PROCESS_SUPPLY_SUBINVENTORY IS NOT NULL
            OR cur.PROCESS_YIELD_SUBINVENTORY IS NOT NULL

            --Physical Attributes
            OR cur.UNIT_WEIGHT IS NOT NULL
            OR cur.VOLUME_UOM_CODE IS NOT NULL
            OR cur.WEIGHT_UOM_CODE IS NOT NULL
            OR cur.COLLATERAL_FLAG IS NOT NULL
            OR cur.VEHICLE_ITEM_FLAG IS NOT NULL
            OR cur.MAXIMUM_LOAD_WEIGHT IS NOT NULL
            OR cur.MINIMUM_FILL_PERCENT IS NOT NULL
            OR cur.UNIT_VOLUME IS NOT NULL
            OR cur.CONTAINER_ITEM_FLAG IS NOT NULL
            OR cur.INTERNAL_VOLUME IS NOT NULL
            OR cur.CONTAINER_TYPE_CODE IS NOT NULL
            OR cur.EQUIPMENT_TYPE IS NOT NULL
            OR cur.EVENT_FLAG IS NOT NULL
            OR cur.ELECTRONIC_FLAG IS NOT NULL
            OR cur.DOWNLOADABLE_FLAG IS NOT NULL
            OR cur.INDIVISIBLE_FLAG IS NOT NULL
            OR cur.DIMENSION_UOM_CODE IS NOT NULL
            OR cur.UNIT_LENGTH IS NOT NULL
            OR cur.UNIT_WIDTH IS NOT NULL
            OR cur.UNIT_HEIGHT IS NOT NULL

            --General Planning
            OR cur.FIXED_DAYS_SUPPLY IS NOT NULL
            OR cur.FIXED_LOT_MULTIPLIER IS NOT NULL
            OR cur.FIXED_ORDER_QUANTITY IS NOT NULL
            OR cur.INVENTORY_PLANNING_CODE IS NOT NULL
            OR cur.MAXIMUM_ORDER_QUANTITY IS NOT NULL
            OR cur.MAX_MINMAX_QUANTITY IS NOT NULL
            OR cur.MINIMUM_ORDER_QUANTITY IS NOT NULL
            OR cur.MIN_MINMAX_QUANTITY IS NOT NULL
            OR cur.MRP_SAFETY_STOCK_PERCENT IS NOT NULL
            OR cur.ORDER_COST IS NOT NULL
            OR cur.PLANNER_CODE IS NOT NULL
            OR cur.SAFETY_STOCK_BUCKET_DAYS IS NOT NULL
            OR cur.SOURCE_SUBINVENTORY IS NOT NULL
            OR cur.SOURCE_TYPE IS NOT NULL
            OR cur.CARRYING_COST IS NOT NULL
            OR cur.MRP_SAFETY_STOCK_CODE IS NOT NULL
            OR cur.SOURCE_ORGANIZATION_ID IS NOT NULL
            OR cur.PLANNING_MAKE_BUY_CODE IS NOT NULL
            OR cur.VMI_MINIMUM_UNITS IS NOT NULL
            OR cur.VMI_MINIMUM_DAYS IS NOT NULL
            OR cur.VMI_MAXIMUM_UNITS IS NOT NULL
            OR cur.VMI_MAXIMUM_DAYS IS NOT NULL
            OR cur.VMI_FIXED_ORDER_QUANTITY IS NOT NULL
            OR cur.SO_AUTHORIZATION_FLAG IS NOT NULL
            OR cur.CONSIGNED_FLAG IS NOT NULL
            OR cur.VMI_FORECAST_TYPE IS NOT NULL
            OR cur.FORECAST_HORIZON IS NOT NULL
            OR cur.ASN_AUTOEXPIRE_FLAG IS NOT NULL
            OR cur.SUBCONTRACTING_COMPONENT IS NOT NULL

            --MPS/MRP Planning
            OR cur.ACCEPTABLE_EARLY_DAYS IS NOT NULL
            OR cur.ACCEPTABLE_RATE_DECREASE IS NOT NULL
            OR cur.ACCEPTABLE_RATE_INCREASE IS NOT NULL
            OR cur.AUTO_REDUCE_MPS IS NOT NULL
            OR cur.DEMAND_TIME_FENCE_CODE IS NOT NULL
            OR cur.DEMAND_TIME_FENCE_DAYS IS NOT NULL
            OR cur.MRP_CALCULATE_ATP_FLAG IS NOT NULL
            OR cur.MRP_PLANNING_CODE IS NOT NULL
            OR cur.OVERRUN_PERCENTAGE IS NOT NULL
            OR cur.PLANNING_EXCEPTION_SET IS NOT NULL
            OR cur.PLANNING_TIME_FENCE_CODE IS NOT NULL
            OR cur.PLANNING_TIME_FENCE_DAYS IS NOT NULL
            OR cur.REPETITIVE_PLANNING_FLAG IS NOT NULL
            OR cur.ROUNDING_CONTROL_TYPE IS NOT NULL
            OR cur.SHRINKAGE_RATE IS NOT NULL
            OR cur.ATO_FORECAST_CONTROL IS NOT NULL
            OR cur.END_ASSEMBLY_PEGGING_FLAG IS NOT NULL
            OR cur.RELEASE_TIME_FENCE_CODE IS NOT NULL
            OR cur.RELEASE_TIME_FENCE_DAYS IS NOT NULL
            OR cur.PLANNED_INV_POINT_FLAG IS NOT NULL
            OR cur.CREATE_SUPPLY_FLAG IS NOT NULL
            OR cur.SUBSTITUTION_WINDOW_CODE IS NOT NULL
            OR cur.SUBSTITUTION_WINDOW_DAYS IS NOT NULL
            OR cur.CRITICAL_COMPONENT_FLAG IS NOT NULL
            OR cur.EXCLUDE_FROM_BUDGET_FLAG IS NOT NULL
            OR cur.DRP_PLANNED_FLAG IS NOT NULL
            OR cur.DAYS_MAX_INV_SUPPLY IS NOT NULL
            OR cur.DAYS_MAX_INV_WINDOW IS NOT NULL
            OR cur.DAYS_TGT_INV_SUPPLY IS NOT NULL
            OR cur.DAYS_TGT_INV_WINDOW IS NOT NULL
            OR cur.CONTINOUS_TRANSFER IS NOT NULL
            OR cur.CONVERGENCE IS NOT NULL
            OR cur.DIVERGENCE IS NOT NULL
            OR cur.REPAIR_PROGRAM IS NOT NULL
            OR cur.REPAIR_LEADTIME IS NOT NULL
            OR cur.REPAIR_YIELD IS NOT NULL
            OR cur.PREPOSITION_POINT IS NOT NULL

            --Lead Times
            OR cur.CUM_MANUFACTURING_LEAD_TIME IS NOT NULL
            OR cur.FIXED_LEAD_TIME IS NOT NULL
            OR cur.VARIABLE_LEAD_TIME IS NOT NULL
            OR cur.FULL_LEAD_TIME IS NOT NULL
            OR cur.POSTPROCESSING_LEAD_TIME IS NOT NULL
            OR cur.PREPROCESSING_LEAD_TIME IS NOT NULL
            OR cur.LEAD_TIME_LOT_SIZE IS NOT NULL
            OR cur.CUMULATIVE_TOTAL_LEAD_TIME IS NOT NULL

            --Work In Progress
            OR cur.WIP_SUPPLY_TYPE IS NOT NULL
            OR cur.OVERCOMPLETION_TOLERANCE_TYPE IS NOT NULL
            OR cur.INVENTORY_CARRY_PENALTY IS NOT NULL
            OR cur.OPERATION_SLACK_PENALTY IS NOT NULL
            OR cur.OVERCOMPLETION_TOLERANCE_VALUE IS NOT NULL
            OR cur.WIP_SUPPLY_SUBINVENTORY IS NOT NULL
            OR cur.WIP_SUPPLY_LOCATOR_ID IS NOT NULL
            OR cur.BUILD_IN_WIP_FLAG IS NOT NULL

            --Order Management
            OR cur.ATP_COMPONENTS_FLAG IS NOT NULL
            OR cur.ATP_FLAG IS NOT NULL
            OR cur.ATP_RULE_ID IS NOT NULL
            OR cur.CUSTOMER_ORDER_ENABLED_FLAG IS NOT NULL
            OR cur.CUSTOMER_ORDER_FLAG IS NOT NULL
            OR cur.DEFAULT_SHIPPING_ORG IS NOT NULL
            OR cur.INTERNAL_ORDER_ENABLED_FLAG IS NOT NULL
            OR cur.INTERNAL_ORDER_FLAG IS NOT NULL
            OR cur.PICKING_RULE_ID IS NOT NULL
            OR cur.PICK_COMPONENTS_FLAG IS NOT NULL
            OR cur.RETURNABLE_FLAG IS NOT NULL
            OR cur.RETURN_INSPECTION_REQUIREMENT IS NOT NULL
            OR cur.SHIPPABLE_ITEM_FLAG IS NOT NULL
            OR cur.SHIP_MODEL_COMPLETE_FLAG IS NOT NULL
            OR cur.SO_TRANSACTIONS_FLAG IS NOT NULL
            OR cur.REPLENISH_TO_ORDER_FLAG IS NOT NULL
            OR cur.OVER_SHIPMENT_TOLERANCE IS NOT NULL
            OR cur.UNDER_SHIPMENT_TOLERANCE IS NOT NULL
            OR cur.OVER_RETURN_TOLERANCE IS NOT NULL
            OR cur.UNDER_RETURN_TOLERANCE IS NOT NULL
            OR cur.VOL_DISCOUNT_EXEMPT_FLAG IS NOT NULL
            OR cur.COUPON_EXEMPT_FLAG IS NOT NULL
            OR cur.FINANCING_ALLOWED_FLAG IS NOT NULL
            OR cur.DEFAULT_SO_SOURCE_TYPE IS NOT NULL
            OR cur.CHARGE_PERIODICITY_CODE IS NOT NULL

            --Service Attributes
            OR cur.COVERAGE_SCHEDULE_ID IS NOT NULL
            OR cur.MATERIAL_BILLABLE_FLAG IS NOT NULL
            OR cur.MAX_WARRANTY_AMOUNT IS NOT NULL
            OR cur.PREVENTIVE_MAINTENANCE_FLAG IS NOT NULL
            OR cur.PRORATE_SERVICE_FLAG IS NOT NULL
            OR cur.RESPONSE_TIME_PERIOD_CODE IS NOT NULL
            OR cur.RESPONSE_TIME_VALUE IS NOT NULL
            OR cur.SERVICE_DURATION IS NOT NULL
            OR cur.SERVICE_DURATION_PERIOD_CODE IS NOT NULL
            OR cur.SERVICE_ITEM_FLAG IS NOT NULL
            OR cur.WARRANTY_VENDOR_ID IS NOT NULL
            OR cur.SERVICEABLE_PRODUCT_FLAG IS NOT NULL
            OR cur.VENDOR_WARRANTY_FLAG IS NOT NULL
            OR cur.SERVICE_STARTING_DELAY IS NOT NULL
            OR cur.USAGE_ITEM_FLAG IS NOT NULL
            OR cur.RECOVERED_PART_DISP_CODE IS NOT NULL
            OR cur.DEFECT_TRACKING_ON_FLAG IS NOT NULL
            OR cur.COMMS_NL_TRACKABLE_FLAG IS NOT NULL
            OR cur.ASSET_CREATION_CODE IS NOT NULL
            OR cur.COMMS_ACTIVATION_REQD_FLAG IS NOT NULL
            OR cur.CONTRACT_ITEM_TYPE_CODE IS NOT NULL
            OR cur.SERV_REQ_ENABLED_CODE IS NOT NULL
            OR cur.SERV_BILLING_ENABLED_FLAG IS NOT NULL
            OR cur.IB_ITEM_INSTANCE_CLASS IS NOT NULL

            --Web Option
            OR cur.ORDERABLE_ON_WEB_FLAG IS NOT NULL
            OR cur.BACK_ORDERABLE_FLAG IS NOT NULL
            OR cur.WEB_STATUS IS NOT NULL
            OR cur.MINIMUM_LICENSE_QUANTITY IS NOT NULL
            THEN
               IF l_inv_debug_level IN(101, 102) THEN
                  INVPUTLI.info('INVNIRIS.change_policy_check: Some Attr is non null');
               END IF;

              l_values_provided := TRUE;
            ELSE
              l_values_provided := FALSE;
            END IF;

            IF l_msb_rec.inventory_item_status_code <> NVL(cur.inventory_item_status_code,l_msb_rec.inventory_item_status_code)
               OR l_msb_rec.description <> NVL(cur.description,l_msb_rec.description)
            THEN
               l_desc_status_change := TRUE;
            ELSE
               l_desc_status_change := FALSE;
            END IF;

            IF l_values_provided THEN
               UPDATE mtl_system_items_interface msi
               SET    process_flag          = 5,
	              --Bug 5383744
		      inventory_item_status_code = NVL(cur.inventory_item_status_code,l_msb_rec.inventory_item_status_code)
               WHERE  rowid = cur.rowid;

               IF l_desc_status_change THEN
                  INSERT INTO mtl_system_items_interface(
                      organization_id
                     ,inventory_item_id
                     ,process_flag
                     ,set_process_id
                     ,transaction_type
                     ,transaction_id
                     ,inventory_item_status_code
                     ,allowed_units_lookup_code
                     ,item_type
                     ,description)
                  VALUES(
                      cur.organization_id
                     ,cur.inventory_item_id
                     ,1
                     ,cur.set_process_id
                     ,'UPDATE'
                     ,mtl_system_items_interface_s.nextval
                     ,cur.inventory_item_status_code --Bug 5383744
                     ,cur.allowed_units_lookup_code
                     ,cur.item_type
                     ,NVL(cur.description,l_msb_rec.description));
               END IF;

            ELSIF NOT l_desc_status_change THEN

               UPDATE mtl_system_items_interface msi
               SET    process_flag          = 7
               WHERE  rowid = cur.rowid;

            END IF; -- IF l_values_provided THEN
            --Start: 5383744: Donot move 5 for no attrib values

         END LOOP;

      END IF;  -- NVL(l_import_co_option,'N') = 'Y' AND l_structure_type_id IS NULL

   END IF; -- INTSR('ITEM_APPROVAL:A')

   RETURN(l_ret_code);

EXCEPTION
  WHEN LOGGING_ERR then
     IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info(l_Err_Text);
     END IF;
     RETURN(l_error_logged);
   WHEN OTHERS THEN
      err_text := substr('INVNIRIS.change_policy_check ' || SQLERRM, 1,240);
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info(err_text);
      END IF;
      RETURN(SQLCODE);
END change_policy_check;

END INVNIRIS;

/
