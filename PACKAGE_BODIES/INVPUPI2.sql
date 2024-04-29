--------------------------------------------------------
--  DDL for Package Body INVPUPI2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPUPI2" AS
/* $Header: INVPUP2B.pls 120.4.12010000.2 2009/08/10 23:15:31 mshirkol ship $ */

FUNCTION validate_flags(
   org_id     IN            NUMBER
  ,all_org    IN            NUMBER  := 2
  ,prog_appid IN            NUMBER  := -1
  ,prog_id    IN            NUMBER  := -1
  ,request_id IN            NUMBER  := -1
  ,user_id    IN            NUMBER  := -1
  ,login_id   IN            NUMBER  := -1
  ,xset_id    IN            NUMBER  := -999
  ,err_text   IN OUT NOCOPY VARCHAR2
)
RETURN INTEGER IS

   CURSOR cc IS
   SELECT INVENTORY_ITEM_ID,
          TRANSACTION_ID,
          ORGANIZATION_ID,
          PICK_COMPONENTS_FLAG,
          PURCHASING_ITEM_FLAG,
          SHIPPABLE_ITEM_FLAG,
          CUSTOMER_ORDER_FLAG,
          INTERNAL_ORDER_FLAG,
          INVENTORY_ITEM_FLAG,
          ENG_ITEM_FLAG,
          INVENTORY_ASSET_FLAG,
          PURCHASING_ENABLED_FLAG,
          CUSTOMER_ORDER_ENABLED_FLAG,
          INTERNAL_ORDER_ENABLED_FLAG,
          SO_TRANSACTIONS_FLAG,
          MTL_TRANSACTIONS_ENABLED_FLAG,
          STOCK_ENABLED_FLAG,
          BOM_ENABLED_FLAG,
          BUILD_IN_WIP_FLAG,
          CATALOG_STATUS_FLAG,
          RETURNABLE_FLAG,
          COLLATERAL_FLAG,
          TAXABLE_FLAG,
          ALLOW_ITEM_DESC_UPDATE_FLAG,
          INSPECTION_REQUIRED_FLAG,
          RECEIPT_REQUIRED_FLAG,
          RFQ_REQUIRED_FLAG,
          ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
          ALLOW_UNORDERED_RECEIPTS_FLAG,
          ALLOW_EXPRESS_DELIVERY_FLAG,
          MRP_CALCULATE_ATP_FLAG,
          END_ASSEMBLY_PEGGING_FLAG,
          REPETITIVE_PLANNING_FLAG,
          REPLENISH_TO_ORDER_FLAG,
          ATP_COMPONENTS_FLAG,
          ATP_FLAG,
          DEFAULT_INCLUDE_IN_ROLLUP_FLAG,
          ENGINEERING_ECN_CODE,
          SERVICEABLE_PRODUCT_FLAG,
          PREVENTIVE_MAINTENANCE_FLAG,
          TIME_BILLABLE_FLAG,
          MATERIAL_BILLABLE_FLAG,
          EXPENSE_BILLABLE_FLAG,
          PRORATE_SERVICE_FLAG,
          SERVICE_DURATION_PERIOD_CODE,
          INVOICEABLE_ITEM_FLAG,
          INVOICE_ENABLED_FLAG,
          MUST_USE_APPROVED_VENDOR_FLAG,
          OUTSIDE_OPERATION_FLAG,
          COSTING_ENABLED_FLAG,
          CYCLE_COUNT_ENABLED_FLAG,
          AUTO_CREATED_CONFIG_FLAG,
          /*CK 18NOV98 Added new attribute*/
           CHECK_SHORTAGES_FLAG,
	       BOM_ITEM_TYPE,
	       CONTRACT_ITEM_TYPE_CODE,
          --R12 FPC
          GDSN_OUTBOUND_ENABLED_FLAG,
          STYLE_ITEM_FLAG
   FROM   MTL_SYSTEM_ITEMS_INTERFACE
   --3515652: Performance enhancements
   WHERE ((organization_id = org_id) or (all_Org = 1))
   AND   set_process_id  = xset_id
   AND   process_flag in (31, 32, 33, 34 , 35 , 45);

   --3760498: Using below query instead of Get_Material_Billable_flag
   CURSOR c_check_billable_flag(cp_lookup_type VARCHAR2
                               ,cp_lookup_code VARCHAR2) IS
      select meaning
      from   cs_lookups
      where  lookup_type = cp_lookup_type
      and    lookup_code =  cp_lookup_code
      and enabled_flag   = 'Y';


   dumm_status             NUMBER;
   status                  NUMBER := 0;
   stmt                    NUMBER;
   LOGGING_ERR             EXCEPTION;
   VALIDATE_ERR            EXCEPTION;
   error_msg               VARCHAR2(70);
   time_uom_class          VARCHAR2(2000);
   ctp_prof_val            NUMBER;
   temp_proc_flag          NUMBER;

-- Added code for bug #1498054
   l_installed   BOOLEAN;
   l_status      VARCHAR2(10);
   l_industry    VARCHAR2(10);
   bill_value    VARCHAR2(2000);
   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
   l_prev_uom_code  MTL_SYSTEM_ITEMS_INTERFACE.service_duration_period_code%TYPE := '!';  --Bug: 4654433
   l_serv_dur_per_code_err  NUMBER := 0;   --Bug: 4654433


BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('Inside INVPUPI2.validate_flags');
   END IF;

 -- Retrieving fnd_profile values outside the loop for perf reasons.
   fnd_profile.get('TIME_UOM_CLASS', time_uom_class);
   ctp_prof_val :=  nvl(fnd_profile.value('INV_CTP'), 3);

   FOR cr IN cc LOOP
       -- Validate YES/NO flags
       status := 0;
       stmt   := 1;
       IF (cr.PURCHASING_ITEM_FLAG <> 'Y' AND
           cr.PURCHASING_ITEM_FLAG <> 'N') THEN
           dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PURCHASING_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
           IF dumm_status < 0 THEN
              raise LOGGING_ERR;
           END IF;
           status := 1;
       END IF;

       stmt := 2;
       IF (cr.SHIPPABLE_ITEM_FLAG <> 'Y' AND
           cr.SHIPPABLE_ITEM_FLAG <> 'N') THEN
          dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SHIPPABLE_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
          IF dumm_status < 0 THEN
             RAISE LOGGING_ERR;
          END IF;
          status := 1;
       END IF;

       stmt := 3;
       IF (cr.CUSTOMER_ORDER_FLAG <> 'Y' AND
           cr.CUSTOMER_ORDER_FLAG <> 'N') THEN
          dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CUSTOMER_ORDER_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
          IF dumm_status < 0 THEN
             RAISE LOGGING_ERR;
          END IF;
          status := 1;
       END IF;

       stmt := 4;
       if  (cr.INTERNAL_ORDER_FLAG <> 'Y' and
                     cr.INTERNAL_ORDER_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INTERNAL_ORDER_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;
/*** Bug:2731125
       stmt := 5;
       if  (cr.SERVICE_ITEM_FLAG <> 'Y' and
                     cr.SERVICE_ITEM_FLAG <> 'N') then
**/
       stmt := 5;
       if  (cr.CONTRACT_ITEM_TYPE_CODE NOT IN ('SERVICE','WARRANTY','USAGE','SUBSCRIPTION')) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CONTRACT_ITEM_TYPE_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 6;
       if  (cr.INVENTORY_ITEM_FLAG <> 'Y' and
                     cr.INVENTORY_ITEM_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INVENTORY_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 7;
       if  (cr.ENG_ITEM_FLAG <> 'Y' and
                     cr.ENG_ITEM_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ENG_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 8;
       if  (cr.INVENTORY_ASSET_FLAG <> 'Y' and
                     cr.INVENTORY_ASSET_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INVENTORY_ASSET_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 9;
       if  (cr.PURCHASING_ENABLED_FLAG <> 'Y' and
                     cr.PURCHASING_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PURCHASING_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;

                               end if;
                                status := 1;
       end if;

       stmt := 10;
       if  (cr.CUSTOMER_ORDER_ENABLED_FLAG <> 'Y' and
                     cr.CUSTOMER_ORDER_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CUSTOMER_ORDER_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 11;
       if  (cr.INTERNAL_ORDER_ENABLED_FLAG <> 'Y' and
                     cr.INTERNAL_ORDER_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INTERNAL_ORDER_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 12;
       if  (cr.SO_TRANSACTIONS_FLAG <> 'Y' and
                     cr.SO_TRANSACTIONS_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SO_TRANSACTIONS_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 13;
       if  (cr.MTL_TRANSACTIONS_ENABLED_FLAG <> 'Y' and
                     cr.MTL_TRANSACTIONS_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MTL_TRANSACTIONS_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 14;
       if  (cr.STOCK_ENABLED_FLAG <> 'Y' and
                     cr.STOCK_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'STOCK_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 15;
       if  (cr.BOM_ENABLED_FLAG <> 'Y' and
                     cr.BOM_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'BOM_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 16;
       if  (cr.BUILD_IN_WIP_FLAG <> 'Y' and
                     cr.BUILD_IN_WIP_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'BUILD_IN_WIP_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 18;
       if  (cr.CATALOG_STATUS_FLAG <> 'Y' and
                     cr.CATALOG_STATUS_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CATALOG_STATUS_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 19;
       if  (cr.RETURNABLE_FLAG <> 'Y' and
                     cr.RETURNABLE_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RETURNABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 20;
       if  (cr.COLLATERAL_FLAG <> 'Y' and
                     cr.COLLATERAL_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'COLLATERAL_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 21;
       if  (cr.TAXABLE_FLAG <> 'Y' and
                     cr.TAXABLE_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'TAXABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 22;
       if  (cr.ALLOW_ITEM_DESC_UPDATE_FLAG <> 'Y' and
                     cr.ALLOW_ITEM_DESC_UPDATE_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ALLOW_ITEM_DESC_UPDATE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 23;
       if  (cr.INSPECTION_REQUIRED_FLAG <> 'Y' and
                     cr.INSPECTION_REQUIRED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INSPECTION_REQUIRED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 24;
       if  (cr.RECEIPT_REQUIRED_FLAG <> 'Y' and
                     cr.RECEIPT_REQUIRED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RECEIPT_REQUIRED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 25;
       if  (cr.RFQ_REQUIRED_FLAG <> 'Y' and
                     cr.RFQ_REQUIRED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RFQ_REQUIRED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 26;
       if  (cr.ALLOW_SUBSTITUTE_RECEIPTS_FLAG <> 'Y' and
                     cr.ALLOW_SUBSTITUTE_RECEIPTS_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ALLOW_SUBSTITUTE_RECEIPTS_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 27;
       if  (cr.ALLOW_UNORDERED_RECEIPTS_FLAG <> 'Y' and
                     cr.ALLOW_UNORDERED_RECEIPTS_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ALLOW_UNORDERED_RECEIPTS_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 28;
       if  (cr.ALLOW_EXPRESS_DELIVERY_FLAG <> 'Y' and
                     cr.ALLOW_EXPRESS_DELIVERY_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ALLOW_EXPRESS_DELIVERY_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 29;
       if  (cr.MRP_CALCULATE_ATP_FLAG <> 'Y' and
                     cr.MRP_CALCULATE_ATP_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MRP_CALCULATE_ATP_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 30;
              /*NP 20AUG96 new values added for END_ASSEMBLY_PEGGING_FLAG 10.7*/
       if (cr.END_ASSEMBLY_PEGGING_FLAG not in ('Y','N','A','B','I','X'))
                               then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'END_ASSEMBLY_PEGGING_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_END_ASSEM_PEGG_FLAG',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 31;
       if  (cr.REPETITIVE_PLANNING_FLAG <> 'Y' and
                     cr.REPETITIVE_PLANNING_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'REPETITIVE_PLANNING_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 32;
       if  (cr.PICK_COMPONENTS_FLAG <> 'Y' and
                     cr.PICK_COMPONENTS_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PICK_COMPONENTS_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 33;
       if  (cr.REPLENISH_TO_ORDER_FLAG <> 'Y' and
                     cr.REPLENISH_TO_ORDER_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'REPLENISH_TO_ORDER_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 34;
       if (cr.ATP_COMPONENTS_FLAG not in ('N','Y','R','C')) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ATP_COMPONENTS_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ATP_COMPONENTS_FLAG',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 35;
       if (cr.ATP_FLAG not in ('N','Y','R','C')) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ATP_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ATP_FLAG',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

      /* Bug 1477935 */
      if ( ctp_prof_val = 1 and cr.atp_flag in ('C','R') and
               ((cr.replenish_to_order_flag = 'Y') or
                (cr.replenish_to_order_flag = 'N' and cr.bom_item_type = 5) or
                (cr.replenish_to_order_flag = 'N' and cr.bom_item_type in (1,2,4))
               )) then
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                         cr.organization_id,
                                         user_id,
                                         login_id,
                                         prog_appid,
                                         prog_id,
                                         request_id,
                                         cr.TRANSACTION_ID,
                                         error_msg,
                                         'ATP_FLAG',
                                         'MTL_SYSTEM_ITEMS_INTERFACE',
                                         'INV_IOI_CHECK_ATP_CTP_1',
                                         err_text);
                                        if dumm_status < 0 then
                                                 raise LOGGING_ERR;
                                         end if;
               status := 1;
       elsif ( ctp_prof_val in (2,5) and cr.atp_flag in ('C','R') ) then
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                         cr.organization_id,
                                         user_id,
                                         login_id,
                                         prog_appid,
                                         prog_id,
                                         request_id,
                                         cr.TRANSACTION_ID,
                                         error_msg,
                                         'ATP_FLAG',
                                         'MTL_SYSTEM_ITEMS_INTERFACE',
                                         'INV_IOI_CHECK_ATP_CTP_2',
                                         err_text);
                                         if dumm_status < 0 then
                                                 raise LOGGING_ERR;
                                         end if;

               status := 1;
       elsif (ctp_prof_val = 3 and cr.bom_item_type in (1,2,4)
                    and cr.atp_flag in ('C','R')) then
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                         cr.organization_id,
                                         user_id,
                                         login_id,
                                         prog_appid,
                                         prog_id,
                                         request_id,
                                         cr.TRANSACTION_ID,
                                         error_msg,
                                         'ATP_FLAG',
                                         'MTL_SYSTEM_ITEMS_INTERFACE',
                                         'INV_IOI_CHECK_ATP_CTP_3A',
                                         err_text);
                                         if dumm_status < 0 then
                                                 raise LOGGING_ERR;
                                         end if;

               status := 1;
       elsif ( ctp_prof_val = 3 and cr.bom_item_type = 5
                   and cr.atp_flag <> 'N'   --Bug:3436199
                 ) then
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                         cr.organization_id,
                                         user_id,
                                         login_id,
                                         prog_appid,
                                         prog_id,
                                         request_id,
                                         cr.TRANSACTION_ID,
                                         error_msg,
                                         'ATP_FLAG',
                                         'MTL_SYSTEM_ITEMS_INTERFACE',
                                         'INV_CHECK_ATP_CTP_3B',--'INV_IOI_CHECK_ATP_CTP_3B',
                                         err_text);
                                         if dumm_status < 0 then
                                                 raise LOGGING_ERR;
                                         end if;

               status := 1;
          end if;
       stmt := 36;
       if  (cr.DEFAULT_INCLUDE_IN_ROLLUP_FLAG <> 'Y' and
            cr.DEFAULT_INCLUDE_IN_ROLLUP_FLAG <> 'N') then
           dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DEFAULT_INCLUDE_IN_ROLLUP_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
           if dumm_status < 0 then
              raise LOGGING_ERR;
           end if;
           status := 1;
       end if;

       stmt := 37;
            /*NP 02-OCT-95 Removed validation for  ENGINEERING_ECN_CODE */
/*** Bug: 2731125
       stmt := 38;
       if  (cr.VENDOR_WARRANTY_FLAG <> 'Y' and
                     cr.VENDOR_WARRANTY_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VENDOR_WARRANTY_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

-- SERVICEABLE_COMPONENT_FLAG got obsoleted
       stmt := 39;
       if  (cr.SERVICEABLE_COMPONENT_FLAG <> 'Y' and
                     cr.SERVICEABLE_COMPONENT_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SERVICEABLE_COMPONENT_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;
***/
       stmt := 40;
       if  (cr.SERVICEABLE_PRODUCT_FLAG <> 'Y' and
                     cr.SERVICEABLE_PRODUCT_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SERVICEABLE_PRODUCT_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 41;
       if  (cr.PREVENTIVE_MAINTENANCE_FLAG <> 'Y' and
                     cr.PREVENTIVE_MAINTENANCE_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PREVENTIVE_MAINTENANCE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;
       stmt := 42;
       if  (cr.TIME_BILLABLE_FLAG <> 'Y' and
                     cr.TIME_BILLABLE_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'TIME_BILLABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       -- Validate Material Billable Flag (Y,N,M,E,B,L,NULL), Y,N for 10.6
       -- Added 'L' for bug# 738612
       -- Removed 'Y','N','B' for bug 943383, as M,E,L,NULL are valid
       -- values in the Items form.
       -- 11.5.10 chnaged the Billing type lov query
    if (cr.MATERIAL_BILLABLE_FLAG IS NOT NULL) then
       stmt := 43;
       OPEN  c_check_billable_flag('MTL_SERVICE_BILLABLE_FLAG',cr.MATERIAL_BILLABLE_FLAG);
       FETCH c_check_billable_flag INTO bill_value;
       CLOSE c_check_billable_flag;
       if (bill_value IS NULL) then
          dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MATERIAL_BILLABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',--'INV_IOI_MATERIAL_BILLABLE_FLAG',
                                err_text);
          if dumm_status < 0 then
             raise LOGGING_ERR;
          end if;
          status := 1;
       end if;
    end if;

       stmt := 44;
       if  (cr.EXPENSE_BILLABLE_FLAG <> 'Y' and
                     cr.EXPENSE_BILLABLE_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'EXPENSE_BILLABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 45;
       if  (cr.PRORATE_SERVICE_FLAG <> 'Y' and
                     cr.PRORATE_SERVICE_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PRORATE_SERVICE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

                -- Validate Service Duration Period Code
       --Bug: 4654433 Performance fix
       stmt := 46;
       IF  cr.service_duration_period_code IS NOT NULL THEN
          IF cr.service_duration_period_code <> l_prev_uom_code THEN
             BEGIN
                SELECT status
                INTO   status
                FROM   mtl_all_primary_uoms_vv
                WHERE  uom_code = cr.service_duration_period_code
                AND    uom_class = time_uom_class;
	        l_serv_dur_per_code_err := 0;
             EXCEPTION
	        --Fix for bug# 2767335 (details below)
                WHEN TOO_MANY_ROWS THEN
                   --MTL_ALL_PRIMARY_UOMS_VV view contains Stamdard UOM
                   --conversions and Item Specific UOM conversions.
                   --Hence for a particular UOM_CODE of an UOM_CLASS
                   --There can be 2 or more rows in the above view.
                   --This is a valid case, and hence donot error.
	           NULL ; -- Do nothing
		   l_serv_dur_per_code_err := 0;

                WHEN OTHERS THEN
                     dumm_status := INVPUOPI.mtl_log_interface_err(
                                    cr.organization_id,
                                    user_id,
                                    login_id,
                                    prog_appid,
                                    prog_id,
                                    request_id,
                                    cr.TRANSACTION_ID,
                                    error_msg,
                                    'SERVICE_DURATION_PERIOD_CODE',
                                    'MTL_SYSTEM_ITEMS_INTERFACE',
                                    'INV_IOI_SERV_DUR_PER_CODE',
                                    err_text);
	             l_serv_dur_per_code_err := 1;
                     IF dumm_status < 0 THEN
                        RAISE LOGGING_ERR;
                     END IF;
                     status := 1;
             END;
          ELSIF l_serv_dur_per_code_err = 1 THEN
             dumm_status := INVPUOPI.mtl_log_interface_err(
                            cr.organization_id,
                            user_id,
                            login_id,
                            prog_appid,
                            prog_id,
                            request_id,
                            cr.TRANSACTION_ID,
                            error_msg,
                            'SERVICE_DURATION_PERIOD_CODE',
                            'MTL_SYSTEM_ITEMS_INTERFACE',
                            'INV_IOI_SERV_DUR_PER_CODE',
                            err_text);
   	     l_serv_dur_per_code_err := 1;
             IF dumm_status < 0 THEN
                RAISE LOGGING_ERR;
             END IF;
             status := 1;
          END IF;
       END IF;
       l_prev_uom_code := cr.service_duration_period_code;   --Bug: 4654433

       stmt := 47;
       if  (cr.INVOICEABLE_ITEM_FLAG <> 'Y' and
                     cr.INVOICEABLE_ITEM_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INVOICEABLE_ITEM_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 48;
       if  (cr.INVOICE_ENABLED_FLAG <> 'Y' and
                     cr.INVOICE_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INVOICE_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 49;
       if  (cr.MUST_USE_APPROVED_VENDOR_FLAG <> 'Y' and
                     cr.MUST_USE_APPROVED_VENDOR_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MUST_USE_APPROVED_VENDOR_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 50;
       if  (cr.OUTSIDE_OPERATION_FLAG <> 'Y' and
                     cr.OUTSIDE_OPERATION_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'OUTSIDE_OPERATION_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 51;
       if  (cr.COSTING_ENABLED_FLAG <> 'Y' and
                     cr.COSTING_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'COSTING_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 52;
       if  (cr.CYCLE_COUNT_ENABLED_FLAG <> 'Y' and
                     cr.CYCLE_COUNT_ENABLED_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CYCLE_COUNT_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;

       stmt := 53;
       if  (cr.AUTO_CREATED_CONFIG_FLAG <> 'Y' and
                     cr.AUTO_CREATED_CONFIG_FLAG <> 'N') then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'AUTO_CREATED_CONFIG_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
       end if;


        stmt := 54;
        IF (cr.CHECK_SHORTAGES_FLAG <> 'Y' AND
            cr.CHECK_SHORTAGES_FLAG <> 'N') THEN
           dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                 'CHECK_SHORTAGES_FLAG',
                                 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 'BOM_OP_VALIDATION_ERR',
                                 err_text);
           IF dumm_status < 0 THEN
              raise LOGGING_ERR;
           END IF;
           status := 1;
        END IF;

       /* Adding validation for GDSN_OUTBOUND_ENABLED and STYLE_ITEM_FLAG for R12 C */
        stmt := 55;
        IF (cr.GDSN_OUTBOUND_ENABLED_FLAG <> 'Y' AND
            cr.GDSN_OUTBOUND_ENABLED_FLAG <> 'N') THEN
           dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                 'GDSN_OUTBOUND_ENABLED_FLAG',
                                 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 'INV_IOI_FLAG_Y_N',
                                 err_text);
           IF dumm_status < 0 THEN
              raise LOGGING_ERR;
           END IF;
           status := 1;
        END IF;

        stmt := 56;
        IF (cr.STYLE_ITEM_FLAG <> 'Y' AND
            cr.STYLE_ITEM_FLAG <> 'N' AND
            cr.STYLE_ITEM_FLAG IS NOT NULL) THEN
           dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                 'STYLE_ITEM_FLAG',
                                 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 'BOM_OP_VALIDATION_ERR',
                                 err_text);
           IF dumm_status < 0 THEN
              raise LOGGING_ERR;
           END IF;
           status := 1;
        END IF;
        --Start 3515652: Performance enhancements
        select process_flag into temp_proc_flag
        from   MTL_SYSTEM_ITEMS_INTERFACE
        where inventory_item_id  = cr.inventory_item_id
        -- and   set_process_id + 0 = xset_id  -- fix for bug#8757041,removed + 0
        and   set_process_id = xset_id
        and   process_flag in (31, 32, 33, 34 , 35 , 45)
        and   organization_id    = cr.organization_id
        and   rownum < 2;

        IF (temp_proc_flag <> 31
	   and temp_proc_flag <> 32
           and temp_proc_flag <> 33
	   and temp_proc_flag <> 34)
	THEN
           update MTL_SYSTEM_ITEMS_INTERFACE
           set process_flag = DECODE(status,0,45,35)
           where inventory_item_id  = cr.inventory_item_id
           --and   set_process_id + 0 = xset_id  -- fix for bug#8757041,removed + 0
           and   set_process_id = xset_id
           and   process_flag       = 45
           and   organization_id    = cr.organization_id;
        END IF;

        --End 3515652: Performance enhancements

   END LOOP;

   RETURN(0);

EXCEPTION

   WHEN LOGGING_ERR THEN
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPUPI2:LOGGING_ERR : stmt ='||stmt);
      END IF;

        RETURN(dumm_status);
   WHEN VALIDATE_ERR THEN
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPUPI2:VALIDATE_ERR ');
      END IF;

        dumm_status := INVPUOPI.mtl_log_interface_err(
                                null,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                null,
                                err_text,
                                null,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);
        RETURN(status);
   WHEN OTHERS THEN
        err_text := substr('INVPUPI2.validate_flags' || SQLERRM, 1, 240);
        return(SQLCODE);

END validate_flags;

END INVPUPI2;

/
