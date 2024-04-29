--------------------------------------------------------
--  DDL for Package Body INVPVDR4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVDR4" AS
/* $Header: INVPVD4B.pls 120.16.12010000.6 2009/08/10 23:17:39 mshirkol ship $ */

FUNCTION validate_item_header4 (
   org_id          NUMBER,
   all_org         NUMBER          := 2,
   prog_appid      NUMBER          := -1,
   prog_id         NUMBER          := -1,
   request_id      NUMBER          := -1,
   user_id         NUMBER          := -1,
   login_id        NUMBER          := -1,
   err_text        IN OUT  NOCOPY VARCHAR2,
   xset_id         IN      NUMBER     DEFAULT -999 ) RETURN INTEGER IS

   loc_ctrl_code         NUMBER;
   cost_flag             VARCHAR2(1);
   inv_asset_flag        VARCHAR2(1);
   mrp_stock_code        NUMBER;
   base_item             NUMBER;
   lead_lot_size         NUMBER;
   out_op_flag           VARCHAR2(1);
   shelf_code            NUMBER;
   temp                  VARCHAR2(2);
   temp_uom_code         VARCHAR2(3);
   temp_u_o_m            VARCHAR2(25);
   temp_uom_class        VARCHAR2(10);
   temp_enabled_flag     VARCHAR2(1);
   pur_dummy             VARCHAR2(30);
   l_col_name            VARCHAR2(30);
   l_msg_name            VARCHAR2(30);
   l_test                NUMBER;

   CURSOR cc IS
      SELECT ROWID, intf.*
      FROM  mtl_system_items_interface intf
      WHERE((intf.organization_id = org_id) OR (all_Org = 1) )
         AND intf.set_process_id = xset_id
         AND intf.process_flag in (31, 32, 33, 43);

   CURSOR  c_check_oks_template IS
      SELECT 'Y'
      FROM   USER_TAB_COLUMNS
      WHERE  TABLE_NAME    = 'OKS_COVERAGE_TEMPLTS_V'
      AND    COLUMN_NAME   = 'ITEM_TYPE';

   -- Added the cursor for bug # 3762750
   CURSOR c_mfglookup_exists(cp_lookup_type VARCHAR2,
                   cp_lookup_code VARCHAR2) IS
      SELECT 'x'
      FROM  MFG_LOOKUPS
      WHERE  LOOKUP_TYPE    = cp_lookup_type
      AND    LOOKUP_CODE    = cp_lookup_code
      AND    SYSDATE  BETWEEN NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
      AND    ENABLED_FLAG   = 'Y';

   -- Added the cursor for bug # 3762750
   CURSOR c_fndlookup_exists(cp_lookup_type VARCHAR2,
                        cp_lookup_code VARCHAR2) IS
      SELECT 'x'
      FROM  FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_TYPE = cp_lookup_type
      AND   LOOKUP_CODE = cp_lookup_code
      AND   SYSDATE BETWEEN  NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
      AND   ENABLED_FLAG = 'Y';

   msicount          NUMBER;
   msiicount         NUMBER;
   resersal_flag     NUMBER;
   dup_item_id       NUMBER;
   l_item_id         NUMBER;
   l_org_id          NUMBER;
   cat_set_id        NUMBER;
   trans_id          NUMBER;
   ext_flag          NUMBER := 0;
   error_msg         VARCHAR2(70);
   status            NUMBER;
   dumm_status       NUMBER;
   master_org_id     NUMBER;
   l_oks_exits       VARCHAR2(1) := 'N';
   stmt              NUMBER;
   LOGGING_ERR       EXCEPTION;
   VALIDATE_ERR      EXCEPTION;
   temp_proc_flag    NUMBER;
   proc_enab_org     VARCHAR2(1);
   l_inv_debug_level NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPVDR4.validate_item_header4: begin');
   END IF;
   -- Validate the records

   FOR cr IN cc LOOP
      status    := 0;
      trans_id  := cr.transaction_id;
      l_org_id  := cr.organization_id;
      l_item_id := cr.inventory_item_id; -- Bug 4705184
      temp_proc_flag := cr.process_flag; -- Bug 4705184

      -- Validate second set of fields with lookup values @@
      --INVPUTLI.info('INVPVDR4: Validating second set of lookups');
      -- validate lookup
      IF  (cr.bom_item_type <> 1 AND
           cr.bom_item_type <> 2 AND
           cr.bom_item_type <> 3 AND
           cr.bom_item_type <> 4 AND
           cr.bom_item_type <> 5)
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'BOM_ITEM_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_BOM_ITEM_TYPE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.wip_supply_type <> 1 AND
           cr.wip_supply_type <> 2 AND
           cr.wip_supply_type <> 3 AND
           cr.wip_supply_type <> 4 AND
           cr.wip_supply_type <> 5 AND
           cr.wip_supply_type <> 6)
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'WIP_SUPPLY_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_WIP_SUPP_TYPE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.allowed_units_lookup_code <> 1 and
           cr.allowed_units_lookup_code <> 2 and
           cr.allowed_units_lookup_code <> 3)
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ALLOWED_UNITS_LOOKUP_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ALWD_UN_LKUP_CODE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      -- 3357700:Vendor manage included in lookup for inv_plan_code
      IF  (cr.inventory_planning_code <> 1 AND
           cr.inventory_planning_code <> 2 AND
           cr.inventory_planning_code <> 6 AND
           cr.inventory_planning_code <> 7)
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'INVENTORY_PLANNING_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_INV_PLN_CODE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.planning_make_buy_code <> 1 AND cr.planning_make_buy_code <> 2) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PLANNING_MAKE_BUY_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PLN_MAKE_BUY_CODE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;


      -- validate lookup
      IF  (cr.rounding_control_type <> 1 AND cr.rounding_control_type <> 2) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ROUNDING_CONTROL_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_RND_CTRL_TYPE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.mrp_safety_stock_code <> 1 AND cr.mrp_safety_stock_code <> 2) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MRP_SAFETY_STOCK_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MRP_SAF_STK_CODE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.reservable_type <> 1 AND cr.reservable_type <> 2) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RESERVABLE_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_RESER_TYPE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.response_time_period_code <> 'DAY' AND
           cr.response_time_period_code <> 'HOU' AND
           cr.response_time_period_code <> 'WEE')
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RESPONSE_TIME_PERIOD_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_RESP_TIME_PER_CODE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.new_revision_code <> 'NOTIFY' AND
           cr.new_revision_code <> 'SEND_AUTOMATIC')
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'NEW_REVISION_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_NEW_REV_CODE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup  /*NP 12OCT94 ASS, RES changed to ASSEMBLY, RESOURCE */
      IF  (cr.outside_operation_uom_type <> 'ASSEMBLY' AND
           cr.outside_operation_uom_type <> 'RESOURCE') THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'OUTSIDE_OPERATION_UOM_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_OUTSIDE_OP_UOM_TYPE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.auto_reduce_mps <> 1 AND
           cr.auto_reduce_mps <> 2 AND
           cr.auto_reduce_mps <> 3 AND
           cr.auto_reduce_mps <> 4)
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'AUTO_REDUCE_MPS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_AUTO_REDUCE_MPS',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;


      -- validate lookup mrp_planning_code
      IF  (cr.mrp_planning_code not in (3,4,6,7,8,9)) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MRP_PLANNING_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_MRP_PLANNING_CODE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- Validate purchasing_tax_code
      IF ( (cr.taxable_flag <> 'Y') AND (cr.purchasing_tax_code IS NOT NULL) ) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PURCHASING_TAX_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_TAXABLE_FLAG',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      /* Changed the validation for R12 - Anmurali */
      IF (cr.purchasing_tax_code IS NOT NULL) THEN
         BEGIN
	 /* Fix for bug 6804003 - Tax Codes are stored at O.U. level, so added
		an inner subquery to fetch the operating_unit */
         /*Bug 7437620  Modified the query to fetch the operating unit
         Table hr_organization_information is used instead of org_organization_defintions*/

            SELECT 'valid_tax_code' into pur_dummy
            FROM dual
            WHERE EXISTS( SELECT NULL
                          FROM  zx_input_classifications_v
                          /* Bug 7588091 Added the nvl around the tax_type in the query*/
                          WHERE nvl(tax_type,'X') not in ('AWT','OFFSET')
                          AND   enabled_flag = 'Y'
                          AND   sysdate between start_date_active and  nvl(end_date_active,sysdate)
                          AND   lookup_code = cr.purchasing_tax_code
                          AND   org_id IN (-99,(SELECT org_information3 FROM  hr_organization_information
                                                WHERE ( ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
                                                       AND ORGANIZATION_ID=cr.organization_id)))
            AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PURCHASING_TAX_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PUR_TAX_CODE',
                                err_text);
               IF dumm_status < 0 THEN
                  raise LOGGING_ERR;
               END IF;
               status := 1;
         END;
      END IF;  -- purchasing_tax_code is not null

      -- bug 2843301 Validate Market and List Price.

      IF  (nvl(cr.MARKET_PRICE, 0) < 0 ) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MARKET_PRICE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_GREATER_EQUAL_ZERO',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      IF  (NVL(cr.LIST_PRICE_PER_UNIT, 0) < 0 ) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LIST_PRICE_PER_UNIT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_GREATER_EQUAL_ZERO',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.return_inspection_requirement <> 1 AND cr.return_inspection_requirement <> 2) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RETURN_INSPECTION_REQUIREMENT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_RETURN_INSP_REQ',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- validate lookup
      IF  (cr.ato_forecast_control <> 1 AND
           cr.ato_forecast_control <> 2 AND
           cr.ato_forecast_control <> 3)
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ATO_FORECAST_CONTROL',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ATO_FORECAST_CTRL',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;


      -- Bug 3969864 - Anmurali
      -- validate CUMULATIVE_TOTAL_LEAD_TIME
      -- length should not exceed 42 digits
      IF  (LENGTH(TO_CHAR(cr.cumulative_total_lead_time)) > 42 ) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CUMULATIVE_TOTAL_LEAD_TIME',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_NUMBER_TOO_LONG',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- Bug 5724477
      -- validate CUM_MANUFACTURING_LEAD_TIME
      -- length should not exceed 42 digits
      IF  (length(to_char(cr.CUM_MANUFACTURING_LEAD_TIME)) > 42 ) THEN
       	  dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CUM_MANUFACTURING_LEAD_TIME',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_CUM_MANU_TOO_LONG',
				err_text);
          IF dumm_status < 0 THEN
             raise LOGGING_ERR;
          END IF;
          status := 1;
      END IF;


   -- Validate Coverage Template value Added as part of 11.5.9 ENH.
      IF (cr.COVERAGE_SCHEDULE_ID IS NOT NULL ) THEN
         IF (cr.contract_item_type_code IS  NULL ) THEN
            dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'COVERAGE_SCHEDULE_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_COVERAGE_TEMP_CONTRACT',
                                err_text);
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         ELSE
            BEGIN
               l_col_name := 'COVERAGE_SCHEDULE_ID';
               l_msg_name := 'INV_IOI_ERR';
               fnd_message.SET_NAME ('INV', 'INV_INVALID_ATTR_NAME_VALUE');
               fnd_message.SET_TOKEN ('ATTR', 'Template');
	       error_msg := fnd_message.get;
               OPEN  c_check_oks_template;
               FETCH c_check_oks_template INTO l_oks_exits;
               CLOSE c_check_oks_template;
               IF l_oks_exits = 'Y' THEN
                  EXECUTE IMMEDIATE
                   'BEGIN                                             '||
                      'SELECT ''x'' INTO :temp                        '||
                      'FROM  OKS_COVERAGE_TEMPLTS_V                   '||
                      'WHERE  ITEM_TYPE = :cr.CONTRACT_ITEM_TYPE_CODE '||
                      'AND  ID          = :cr.COVERAGE_SCHEDULE_ID    '||
                      'AND  SYSDATE BETWEEN  NVL(start_date, SYSDATE-1) AND NVL(end_date, SYSDATE+1); '||
                      'END;'
                  USING OUT temp, IN cr.CONTRACT_ITEM_TYPE_CODE,  IN cr.COVERAGE_SCHEDULE_ID;
               ELSE
                  SELECT 'x' INTO temp
                  FROM  OKS_COVERAGE_TEMPLTS_V
                  WHERE ID          = cr.COVERAGE_SCHEDULE_ID
                  AND  SYSDATE BETWEEN  NVL(start_date, SYSDATE-1) AND NVL(end_date, SYSDATE+1);
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  dumm_status := INVPUOPI.mtl_log_interface_err
                              (  cr.organization_id,
                                 user_id, login_id, prog_appid, prog_id, request_id,
                                 cr.TRANSACTION_ID, error_msg,
                                 l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 l_msg_name,
                                 err_text );
                   IF dumm_status < 0 THEN
                      raise LOGGING_ERR;
                   END IF;
                   status := 1;
            END;
         END IF;
         -- Bug: 2811878 This validation will be in 11.5.10 in IOI
      ELSIF(cr.CONTRACT_ITEM_TYPE_CODE IN ('SERVICE', 'WARRANTY')) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'COVERAGE_SCHEDULE_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_COVERAGE_TEMPL_MAND',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF; -- Coverage Template end

      -- Validate Installed Base tracking Flag.
      IF (cr.COMMS_NL_TRACKABLE_FLAG = 'Y' AND
         --Bug: 2696647 Subscription Items can be Installed Base trackable
         cr.contract_item_type_code IN ('SERVICE','WARRANTY','USAGE'))
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'COMMS_NL_TRACKABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IB_TRACKING_CONTRACT',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      --Start 3416621 Subscription  should be IB trackble
      IF (cr.contract_item_type_code = 'SUBSCRIPTION' AND
          NVL(cr.COMMS_NL_TRACKABLE_FLAG,'N') <> 'Y')
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'COMMS_NL_TRACKABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CTTYPE_INSBASE_VALID',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      --End 3416621 Subscription  should be IB trackble
      --Added for 11.5.10
      IF (NVL(cr.COMMS_NL_TRACKABLE_FLAG,'N') = 'N' AND
          NVL(cr.asset_creation_code,'0') = '1')
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ASSET_CREATION_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INST_BASE_ASSET_CREATE_DEP',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      --Bug: 2710463 NVL added
      IF (NVL(cr.COMMS_NL_TRACKABLE_FLAG,'N') <> 'Y' AND
          cr.CONTRACT_ITEM_TYPE_CODE IS NULL AND
          cr.SERVICEABLE_PRODUCT_FLAG = 'Y')
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'COMMS_NL_TRACKABLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IB_TRACKING_SERVICEABLE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      --Validate LOT_SUBSTITUTION_ENABLED
      --Added validation for new attributes as part of 11.5.9
      IF ( cr.LOT_SUBSTITUTION_ENABLED = 'Y' AND NVL(cr.LOT_CONTROL_CODE,1)=1) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_SUBSTITUTION_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_LOT_SUB_ENABLED',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      -- Lot Subsitution flag must be either NULL or 'Y'
      IF (  cr.LOT_SUBSTITUTION_ENABLED IS NOT NULL AND cr.LOT_SUBSTITUTION_ENABLED <> 'Y' )THEN
         l_col_name := 'LOT_SUBSTITUTION_ENABLED';
         l_msg_name := 'INV_NOT_VALID_FLAG';

         dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF; -- LOT_SUBSTITUTION_ENABLED is not null

      /*Bug: 5140047 Commenting out this validation as this is duplicate.
      IF ( cr.LOT_SUBSTITUTION_ENABLED = 'Y' AND NVL(cr.LOT_CONTROL_CODE,1)=1) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_SUBSTITUTION_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_LOT_SUB_ENABLED',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;
      */
      -- Lot Subsitution flag must be either NULL or 'Y'
      --BEGIN : Fix for Bug# 2760857 (PPEDDAMA)
      --Begin : ***Validate LOT_TRANSLATE_ENABLED***
      IF ( cr.LOT_TRANSLATE_ENABLED IS NOT NULL AND cr.LOT_TRANSLATE_ENABLED NOT IN ( 'Y','N')  )THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_TRANSLATE_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF; -- LOT_TRANSLATE_ENABLED is not null AND <> 'Y'

      IF ( cr.LOT_TRANSLATE_ENABLED = 'Y' AND NVL(cr.LOT_CONTROL_CODE,1)=1) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_TRANSLATE_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_LOT_TRANS_ENABLED',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;-- LOT_TRANSLATE_ENABLED = 'Y' AND <<NO LOT CONTROL>>
      --End : ***Validate LOT_TRANSLATE_ENABLED***

      --Begin : ***Validate LOT_SPLIT_ENABLED***
      IF (  cr.LOT_SPLIT_ENABLED IS NOT NULL AND cr.LOT_SPLIT_ENABLED NOT IN ( 'Y','N')  )THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_SPLIT_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;-- LOT_SPLIT_ENABLED is not null AND <> 'Y'

      IF ( cr.LOT_SPLIT_ENABLED = 'Y' AND NVL(cr.LOT_CONTROL_CODE,1)=1) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_SPLIT_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_LOT_SPLIT_ENABLED',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;-- LOT_SPLIT_ENABLED = 'Y' AND <<NO LOT CONTROL>>
      --End : ***Validate LOT_SPLIT_ENABLED***

       --Begin : ***Validate LOT_MERGE_ENABLED***
      IF (  cr.LOT_MERGE_ENABLED IS NOT NULL AND cr.LOT_MERGE_ENABLED NOT IN ( 'Y','N')  )THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_MERGE_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;-- LOT_MERGE_ENABLED is not null AND <> 'Y'

      IF ( cr.LOT_MERGE_ENABLED = 'Y' AND NVL(cr.LOT_CONTROL_CODE,1)=1) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_MERGE_ENABLED',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_LOT_MERGE_ENABLED',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;-- LOT_MERGE_ENABLED = 'Y' AND <<NO LOT CONTROL>>
        --End : ***Validate LOT_MERGE_ENABLED***
        --END : Fix for Bug# 2760857 (PPEDDAMA)

      --Bug No: 3285381 Modified IF st.
      IF ( NVL(cr.MINIMUM_LICENSE_QUANTITY,1) < 1 OR
           NVL(cr.MINIMUM_LICENSE_QUANTITY,1) <> CEIL(NVL(cr.MINIMUM_LICENSE_QUANTITY,1)) )
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'MINIMUM_LICENSE_QUANTITY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_MIN_LICENSE',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;  -- MINIMUM_LICENSE_QUANTITY < 1

      IF ( NVL(cr.COMMS_NL_TRACKABLE_FLAG,'N') <> 'Y' AND cr.IB_ITEM_INSTANCE_CLASS IS NOT NULL) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'IB_ITEM_INSTANCE_CLASS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IB_INSTANCE_CLASS_IB_TRACK',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      IF ( cr.IB_ITEM_INSTANCE_CLASS IS NOT NULL ) THEN
         l_col_name := 'IB_ITEM_INSTANCE_CLASS';
         l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';
         -- 3762750: Using cursor call to avoid multiple parsing
         OPEN  c_fndlookup_exists('CSI_ITEM_CLASS',cr.IB_ITEM_INSTANCE_CLASS);
         FETCH c_fndlookup_exists INTO temp;
         CLOSE c_fndlookup_exists;

         IF temp IS NULL THEN
            dumm_status := INVPUOPI.mtl_log_interface_err
                              (  cr.organization_id,
                                 user_id, login_id, prog_appid, prog_id, request_id,
                                 cr.TRANSACTION_ID, error_msg,
                                 l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 l_msg_name,
                                 err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;
      END IF;-- IB_ITEM_INSTANCE_CLASS IS NOTNULL

      -- This Can be NOT NULL only for orderable and configurable PTO Models.
      IF ( cr.CONFIG_MODEL_TYPE IS NOT NULL AND
          NOT ( cr.BOM_ITEM_TYPE = 1  AND
          cr.CUSTOMER_ORDER_ENABLED_FLAG = 'Y' ) )
      THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CONFIG_MODEL_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CONFIG_MODEL_TYPE_MOD',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;  -- CONFIG_MODEL_TYPE IS NOTNULL

      -- CONFIG_MODEL_TYPE "Network Container Model" (N) cannot be
      -- Installed Base trackable item.
      IF ( NVL(cr.COMMS_NL_TRACKABLE_FLAG,'N') = 'Y' AND cr.CONFIG_MODEL_TYPE = 'N' ) THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CONFIG_MODEL_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CONFIG_MODEL_TYPE_IB_TRACK',
                                err_text);
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;  -- CONFIG_MODEL_TYPE IS NOTNULL

       IF ( cr.CONFIG_MODEL_TYPE IS NOT NULL ) THEN
         l_col_name := 'CONFIG_MODEL_TYPE';
         l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';
         -- 3762750: Using cursor call to avoid multiple parsing
         OPEN  c_fndlookup_exists('CZ_CONFIG_MODEL_TYPE',cr.CONFIG_MODEL_TYPE);
         FETCH c_fndlookup_exists INTO temp;
         CLOSE c_fndlookup_exists;

         IF temp IS NULL THEN
            dumm_status := INVPUOPI.mtl_log_interface_err
                              (  cr.organization_id,
                                 user_id, login_id, prog_appid, prog_id, request_id,
                                 cr.TRANSACTION_ID, error_msg,
                                 l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 l_msg_name,
                                 err_text );
            IF dumm_status < 0 THEN
              raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;
      END IF;-- CONFIG_MODEL_TYPE IS NOTNULL

      -- Ended FOR 11.5.9
      -- Validate WEB_STATUS
      IF ( cr.WEB_STATUS is not null ) THEN
         -- 3762750: Using cursor call to avoid multiple parsing
         OPEN  c_fndlookup_exists('IBE_ITEM_STATUS',cr.WEB_STATUS);
         FETCH c_fndlookup_exists INTO temp;
         CLOSE c_fndlookup_exists;
         IF temp IS NULL THEN
            dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'WEB_STATUS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_WEB_STATUS',
                                err_text);
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;
      END IF;  -- WEB_STATUS is not null

      --Validate INDIVISIBLE_FLAG
      -- Do not raise error
      -- Validate EAM Asset Item attributes
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVDR4.validate_item_header4: validate EAM attributes (EAM_ITEM_TYPE = ' || cr.EAM_ITEM_TYPE || ')');
      END IF;

      IF ( cr.EAM_ITEM_TYPE IS NOT NULL ) THEN
         BEGIN
            -- Organization must be EAM enabled for Asset Items to be imported
            /* FP Bug 8214318 with base Bug 7713558. Commenting 'Organization EAM enabled' validation,
            as EAM functionality allows EAM Items to be assigned to non-EAM enabled Organizations */
            /*
            l_col_name := 'EAM_ITEM_TYPE';
            l_msg_name := 'INV_EAM_ORG_NOT_ENABLED';

            stmt := 811;
            SELECT 'x' INTO temp
            FROM  MTL_PARAMETERS
            WHERE  ORGANIZATION_ID = cr.organization_id
            AND  (NVL(EAM_ENABLED_FLAG, 'N') = 'Y' or cr.organization_id = master_organization_id);*/
            --Bug:2672219 and  NVL(EAM_ENABLED_FLAG, 'N') = 'Y';
            -- Check Asset Item type value based on mfg_lookups
            l_col_name := 'EAM_ITEM_TYPE';
            l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';
            --l_msg_token := l_col_name;

            stmt := 812;

            -- 3762750: Using cursor call to avoid multiple parsing
            OPEN  c_mfglookup_exists('MTL_EAM_ITEM_TYPE',cr.EAM_ITEM_TYPE);
            FETCH c_mfglookup_exists INTO temp;
            CLOSE c_mfglookup_exists;
            IF temp IS NULL THEN
               RAISE no_data_found;
            END IF;
         EXCEPTION
            WHEN no_data_found THEN
               dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name, -- l_msg_token
                              err_text );
               IF dumm_status < 0 THEN
                  raise LOGGING_ERR;
               END IF;
               status := 1;
         END;
         stmt := 821;
         -- All Asset Items must be Inventory items
         IF ( NOT ( cr.INVENTORY_ITEM_FLAG = 'Y' ) ) THEN
            l_col_name := 'INVENTORY_ITEM_FLAG';
            l_msg_name := 'INV_EAM_ITEM_TYPE_PF_INV';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         stmt := 822;
         --R12 enhacement : Added validation Asset Group Item and Rebuidable item which is serial controlled must be IB Trackabale

         IF ( (cr.EAM_ITEM_TYPE = 1 OR
            (cr.EAM_ITEM_TYPE = 3 AND cr.SERIAL_NUMBER_CONTROL_CODE <> 1 ) )
             AND NVL(cr.COMMS_NL_TRACKABLE_FLAG,'N') <> 'Y')
         THEN
            l_col_name := 'COMMS_NL_TRACKABLE_FLAG';
            l_msg_name := 'INV_EAM_IB_TRACKABLE';

            dumm_status := INVPUOPI.mtl_log_interface_err
                              (cr.organization_id,
                               user_id,
                               login_id,
                               prog_appid,
                               prog_id,
                               request_id,
                               cr.TRANSACTION_ID,
                               error_msg,
                               l_col_name,
                               'MTL_SYSTEM_ITEMS_INTERFACE',
                               l_msg_name,
                               err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         -- Asset Group has unit effective BOM
         IF ( cr.EAM_ITEM_TYPE = 1  AND NOT ( cr.EFFECTIVITY_CONTROL = 2 ) ) THEN
            l_col_name := 'EFFECTIVITY_CONTROL';
            l_msg_name := 'INV_EAM_ASSET_UNIT_CONTROL';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         stmt := 824;

         -- Asset Group must be serial controlled of type Pre-Defined
         -- Change the second clause to include 'At Reciept' Items for R12
         IF ( cr.EAM_ITEM_TYPE = 1 AND cr.SERIAL_NUMBER_CONTROL_CODE NOT IN (2,5)) THEN
            l_col_name := 'SERIAL_NUMBER_CONTROL_CODE';
            l_msg_name := 'INV_EAM_ASSET_GRP_NO_SERIAL';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         stmt := 825;

         -- Asset Activity must not be serial controlled

         IF ( cr.EAM_ITEM_TYPE = 2
              AND NOT ( cr.SERIAL_NUMBER_CONTROL_CODE = 1 ) )
         THEN
            l_col_name := 'SERIAL_NUMBER_CONTROL_CODE';
            l_msg_name := 'INV_EAM_ACTIVITY_NEVER_SERIAL';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

      END IF;  -- EAM_ITEM_TYPE IS NOT NULL

      --R12 enhacement : Tracking UOM is PS, Organization is process_enabled Bom Allowed must be No
      --and BOM item type cannot be MODEL or OPTION CLASS
      --Reverting the above fix for OPM - No chk for Process Enabled org
      --4756500 Using l_org_id instead of org_id
      --Moving the validation out of the EAM_ITEM_TYPE IF BLOCK - UT Bug

      IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('INVPVDR4.validate_item_header4: Validating Tracking and BOM attributes');
      END IF;

			/*Comment the code to fix bug7477872
      IF (  cr.TRACKING_QUANTITY_IND = 'PS' AND
           (cr.BOM_ITEM_TYPE in (1,2) OR cr.BOM_ENABLED_FLAG='Y' ) )
      THEN
          l_col_name := 'TRACKING_QUANTITY_IND';
          l_msg_name := 'INV_TRACKING_OPM_BOM_ATTR';
          dumm_status := INVPUOPI.mtl_log_interface_err
                              (  cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                 l_col_name,
                                 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 l_msg_name,
                                 err_text );
           IF dumm_status < 0 THEN
              raise LOGGING_ERR;
           END IF;
           status := 1;
        END IF;
			*/
      -- For EAM Asset Activity item, validate Activity Type, Activity Cause,
      -- and Shutdown Type attribute values based on mfg_lookups.
      -- Convert lookup code to char since columns are varchar2, and
      -- mfg_lookups code is number.

      IF ( cr.EAM_ITEM_TYPE = 2 ) THEN
         stmt := 831;
         IF ( cr.EAM_ACTIVITY_TYPE_CODE IS NOT NULL ) THEN
            l_col_name := 'EAM_ACTIVITY_TYPE_CODE';
            l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';

            -- 3762750: Using cursor call to avoid multiple parsing
            OPEN  c_mfglookup_exists('MTL_EAM_ACTIVITY_TYPE',cr.EAM_ACTIVITY_TYPE_CODE);
            FETCH c_mfglookup_exists INTO temp;
            CLOSE c_mfglookup_exists;

            IF (temp IS NULL) THEN
               dumm_status := INVPUOPI.mtl_log_interface_err
                  (  cr.organization_id,user_id, login_id, prog_appid,
                     prog_id, request_id,cr.TRANSACTION_ID, error_msg,
                     l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',l_msg_name,err_text );
               IF dumm_status < 0 THEN
                  raise LOGGING_ERR;
               END IF;
               status := 1;
            END IF;
         END IF;

         stmt := 832;

         IF ( cr.EAM_ACTIVITY_CAUSE_CODE IS NOT NULL ) THEN
            l_col_name := 'EAM_ACTIVITY_CAUSE_CODE';
            l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';

            -- 3762750: Using cursor call to avoid multiple parsing
            OPEN  c_mfglookup_exists('MTL_EAM_ACTIVITY_CAUSE',cr.EAM_ACTIVITY_CAUSE_CODE);
            FETCH c_mfglookup_exists INTO temp;
            CLOSE c_mfglookup_exists;
            IF (temp IS NULL) THEN
               dumm_status := INVPUOPI.mtl_log_interface_err
                  (  cr.organization_id,
                     user_id, login_id, prog_appid, prog_id, request_id,
                     cr.TRANSACTION_ID, error_msg,
                     l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                     l_msg_name,
                     err_text );
               IF dumm_status < 0 THEN
                  raise LOGGING_ERR;
               END IF;
               status := 1;
            END IF;
         END IF;

         stmt := 833;

         IF ( cr.EAM_ACT_SHUTDOWN_STATUS IS NOT NULL ) THEN
            l_col_name := 'EAM_ACT_SHUTDOWN_STATUS';
            l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';

            -- 3762750: Using cursor call to avoid multiple parsing
            OPEN  c_mfglookup_exists('BOM_EAM_SHUTDOWN_TYPE',cr.EAM_ACT_SHUTDOWN_STATUS);
            FETCH c_mfglookup_exists INTO temp;
            CLOSE c_mfglookup_exists;
            IF (temp IS NULL) THEN
               dumm_status := INVPUOPI.mtl_log_interface_err
                  (  cr.organization_id,
                     user_id, login_id, prog_appid, prog_id, request_id,
                     cr.TRANSACTION_ID, error_msg,
                     l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                     l_msg_name, err_text );
               IF dumm_status < 0 THEN
                  raise LOGGING_ERR;
               END IF;
               status := 1;
            END IF;
         END IF;

         stmt := 834;

         -- Asset Activity Notification Required flag must be
         -- either NULL, 'Y' or 'N' for Asset Activity items.

         IF ( NOT (    cr.EAM_ACT_NOTIFICATION_FLAG IS NULL
                    OR cr.EAM_ACT_NOTIFICATION_FLAG IN ('Y', 'N') ))
         THEN
            l_col_name := 'EAM_ACT_NOTIFICATION_FLAG';
            l_msg_name := 'INV_IOI_FLAG_Y_N';
            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         --Added EAM attribute as part of 11.5.9
         stmt := 835;

         -- Asset Activity source must be NULL or valid value
         -- for Asset Activity items.

         IF ( cr.EAM_ACTIVITY_SOURCE_CODE IS NOT NULL ) THEN
            l_col_name := 'EAM_ACTIVITY_SOURCE_CODE';
            l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';
            -- 3762750: Using cursor call to avoid multiple parsing
            OPEN  c_fndlookup_exists('MTL_EAM_ACTIVITY_SOURCE',cr.EAM_ACTIVITY_SOURCE_CODE);
            FETCH c_fndlookup_exists INTO temp;
            CLOSE c_fndlookup_exists;

            IF temp IS NULL THEN
               dumm_status := INVPUOPI.mtl_log_interface_err
                              (  cr.organization_id,
                                 user_id, login_id, prog_appid, prog_id, request_id,
                                 cr.TRANSACTION_ID, error_msg,
                                 l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                                 l_msg_name,
                                 err_text );
               IF dumm_status < 0 THEN
                  raise LOGGING_ERR;
               END IF;
               status := 1;
            END IF;
         END IF;

      ELSE  -- cr.EAM_ITEM_TYPE <> 2 OR cr.EAM_ITEM_TYPE IS NULL
         -- Asset Activity attribute columns must be NULL for non-Asset Activity
         -- items (Asset Group, Rebuildable Asset and others).
         stmt := 841;
         IF ( cr.EAM_ACTIVITY_TYPE_CODE IS NOT NULL ) THEN
            l_col_name := 'EAM_ACTIVITY_TYPE_CODE';
            l_msg_name := 'INV_EAM_NON_ACT_ACT_TYPE';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         stmt := 842;

         IF ( cr.EAM_ACTIVITY_CAUSE_CODE IS NOT NULL ) THEN

            l_col_name := 'EAM_ACTIVITY_CAUSE_CODE';
            l_msg_name := 'INV_EAM_NON_ACT_ACT_CAUSE';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         stmt := 843;

         IF ( cr.EAM_ACT_SHUTDOWN_STATUS IS NOT NULL ) THEN

            l_col_name := 'EAM_ACT_SHUTDOWN_STATUS';
            l_msg_name := 'INV_EAM_NON_ACT_ACT_SHUTDOWN';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         stmt := 844;

         IF ( NVL(cr.EAM_ACT_NOTIFICATION_FLAG, 'N') <> 'N' ) THEN

            l_col_name := 'EAM_ACT_NOTIFICATION_FLAG';
            l_msg_name := 'INV_EAM_NON_ACT_ACT_NOTIF_FLAG';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

         --Added EAM attribute as part of 11.5.9
         stmt := 845;
         IF ( cr.EAM_ACTIVITY_SOURCE_CODE IS NOT NULL ) THEN
            l_col_name := 'EAM_ACTIVITY_SOURCE_CODE';
            l_msg_name := 'INV_EAM_NON_ACT_ACT_SOURCE';

            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID, error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name,
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
         END IF;

      END IF;  -- EAM_ITEM_TYPE = 2

      stmt := 851;

      --2949730 : Check on valid values on so source types introduced.
      IF (cr.DEFAULT_SO_SOURCE_TYPE IS NOT NULL) THEN
         l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';
         l_col_name := 'DEFAULT_SO_SOURCE_TYPE';

         BEGIN
            SELECT 'x' INTO temp
            FROM  OE_LOOKUPS
            WHERE LOOKUP_TYPE = 'SOURCE_TYPE'
            AND   LOOKUP_CODE = cr.DEFAULT_SO_SOURCE_TYPE
            AND   SYSDATE BETWEEN NVL(start_date_active, SYSDATE) AND NVL(end_date_active, SYSDATE)
            AND   ENABLED_FLAG = 'Y';

         EXCEPTION
            WHEN no_data_found THEN
               dumm_status := INVPUOPI.mtl_log_interface_err
                           (cr.organization_id,
                            user_id, login_id, prog_appid, prog_id, request_id,
                            cr.TRANSACTION_ID, error_msg,
                            l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                            l_msg_name, err_text );
               IF dumm_status < 0 THEN
                  raise LOGGING_ERR;
               END IF;
               status := 1;
         END;
      END IF;

      --Start 2904941 SO_SOURCE_TYPE->(PURCHASING_ENABLED-SHIP_MODEL) Validations
      IF (cr.DEFAULT_SO_SOURCE_TYPE ='EXTERNAL') THEN

         IF (cr.PURCHASING_ENABLED_FLAG <>'Y' OR cr.PURCHASING_ENABLED_FLAG IS NULL) THEN
            l_msg_name := 'INV_PURCHASING_SO_SOURCE_TYPE';
            l_col_name := 'DEFAULT_SO_SOURCE_TYPE';
            dumm_status := INVPUOPI.mtl_log_interface_err
                           (cr.organization_id,
                            user_id, login_id, prog_appid, prog_id, request_id,
                            cr.TRANSACTION_ID, error_msg,
                            l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                            l_msg_name, err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
      END IF;

      IF (cr.SHIP_MODEL_COMPLETE_FLAG ='Y') THEN
         l_msg_name  := 'INV_DEFAULT_SO_SOURCE_TYPE_EXT';
         l_col_name := 'DEFAULT_SO_SOURCE_TYPE';
         dumm_status := INVPUOPI.mtl_log_interface_err
                           (cr.organization_id,
                            user_id, login_id, prog_appid, prog_id, request_id,
                            cr.TRANSACTION_ID, error_msg,
                            l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                            l_msg_name, err_text );
         IF dumm_status < 0 THEN
           raise LOGGING_ERR;
         END IF;
         status := 1;
         END IF;
      END IF; --cr.DEFAULT_SO_SOURCE_TYPE
      stmt := 852;
      --End 2904941 SO_SOURCE_TYPE->(PURCHASING_ENABLED-SHIP_MODEL) Validations

      --Start 2993300: New Attributes validation
      stmt := 912;

      l_col_name := NULL;
      IF NVL(cr.SERV_BILLING_ENABLED_FLAG,'N') NOT IN ('Y','N') THEN
         l_col_name := 'SERV_BILLING_ENABLED_FLAG';
      ELSIF NOT (cr.PLANNED_INV_POINT_FLAG IS NULL   OR cr.PLANNED_INV_POINT_FLAG ='Y') THEN
         l_col_name := 'PLANNED_INV_POINT_FLAG';
      ELSIF NVL(cr.CREATE_SUPPLY_FLAG,'Z') NOT IN ('Y','N') THEN
         l_col_name := 'CREATE_SUPPLY_FLAG';
      ELSIF NOT(cr.SUBSTITUTION_WINDOW_CODE IS NULL  OR cr.SUBSTITUTION_WINDOW_CODE IN (1,2,3,4)) THEN
         l_col_name := 'SUBSTITUTION_WINDOW_CODE';
      ELSIF ( cr.SUBSTITUTION_WINDOW_DAYS < 0) THEN
         l_col_name := 'SUBSTITUTION_WINDOW_DAYS';
      ELSIF ( cr.SUBSTITUTION_WINDOW_DAYS < 0) THEN
         l_col_name := 'SUBSTITUTION_WINDOW_DAYS';
      ELSIF ( NVL( cr.ASSET_CREATION_CODE,'0' ) NOT IN ('0','1')) THEN--11.5.10
         l_col_name := 'ASSET_CREATION_CODE';
      END IF;

      IF l_col_name IS NOT NULL THEN
         l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';
         dumm_status := INVPUOPI.mtl_log_interface_err
                           (cr.organization_id,
                            user_id, login_id, prog_appid, prog_id, request_id,
                            cr.TRANSACTION_ID, error_msg,
                            l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                            l_msg_name, err_text );
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      l_col_name := NULL;
      IF cr.SUBSTITUTION_WINDOW_CODE = 4
         AND cr.SUBSTITUTION_WINDOW_DAYS IS NULL THEN
         l_col_name := 'SUBSTITUTION_WINDOW_DAYS';
         l_msg_name := 'INV_IOI_SUBS_WIN_DAYS_MAND';
      ELSIF (cr.SUBSTITUTION_WINDOW_CODE IS NULL
             OR  cr.SUBSTITUTION_WINDOW_CODE <> 4)         --Bug: 3289000
         AND cr.SUBSTITUTION_WINDOW_DAYS IS NOT NULL THEN
         l_col_name := 'SUBSTITUTION_WINDOW_DAYS';
         l_msg_name := 'INV_IOI_SUBS_WIN_DAYS_NULL';
      END IF;

      IF l_col_name IS NOT NULL THEN
         dumm_status := INVPUOPI.mtl_log_interface_err
                           (cr.organization_id,
                            user_id, login_id, prog_appid, prog_id, request_id,
                            cr.TRANSACTION_ID, error_msg,
                            l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                            l_msg_name, err_text );
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF;

      --Start 2339789:uom units without uom code
      /* R12 C Weight UOM Code can now be updated for Pending items. Moving the below set of validations to INVPVHDR
      l_col_name := NULL;
      l_msg_name := NULL;

      IF cr.WEIGHT_UOM_CODE IS NULL
         AND (cr.UNIT_WEIGHT IS NOT NULL OR cr.MAXIMUM_LOAD_WEIGHT IS NOT NULL) THEN --Bug: 3503944
         l_col_name := 'WEIGHT_UOM_CODE';
         l_msg_name := 'INV_IOI_WEIGHT_UOM_MISSING';
      ELSIF cr.VOLUME_UOM_CODE IS NULL
         AND (cr.UNIT_VOLUME IS NOT NULL OR cr.INTERNAL_VOLUME IS NOT NULL) THEN --Bug: 3503944
         l_col_name := 'VOLUME_UOM_CODE';
         l_msg_name := 'INV_IOI_VOLUME_UOM_MISSING';
      ELSIF cr.DIMENSION_UOM_CODE IS NULL
         AND (cr.UNIT_LENGTH IS NOT NULL
         OR cr.UNIT_WIDTH IS NOT NULL
         OR cr.UNIT_HEIGHT IS NOT NULL)
      THEN
         l_col_name := 'DIMENSION_UOM_CODE';
         l_msg_name := 'INV_IOI_DIMENSION_UOM_MISSING';
      END IF;

      IF l_col_name IS NOT NULL THEN
         dumm_status := INVPUOPI.mtl_log_interface_err
                           (cr.organization_id,
                            user_id, login_id, prog_appid, prog_id, request_id,
                            cr.TRANSACTION_ID, error_msg,
                            l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                            l_msg_name, err_text );
         IF dumm_status < 0 THEN
            raise LOGGING_ERR;
         END IF;
         status := 1;
      END IF; */
      --End   2339789:uom units without uom code
      --End 2993300: New Attributes validation

      /*
      INVPUTLI.info('INVPVDR4.validate_item_header4: validate EAM attributes (EAM_ITEM_TYPE = ' || cr.EAM_ITEM_TYPE || ')');

      IF ( cr.XXX IS NOT NULL ) THEN

      BEGIN

         -- ...

         l_col_name := '';
         l_msg_name := '';


      EXCEPTION
         WHEN no_data_found THEN
            dumm_status := INVPUOPI.mtl_log_interface_err
                           (  cr.organization_id,
                              user_id, login_id, prog_appid, prog_id, request_id,
                              cr.TRANSACTION_ID,
                              error_msg,
                              l_col_name, 'MTL_SYSTEM_ITEMS_INTERFACE',
                              l_msg_name, -- l_msg_token
                              err_text );
            IF dumm_status < 0 THEN
               raise LOGGING_ERR;
            END IF;
            status := 1;
      END;

      END IF;  -- ...
*/
                /* NP26DEC94 : New code to update process_flag.
                ** This code necessiated due to the breaking up INVPVHDR into
                ** 6 smaller packages to overcome PL/SQL limitations with code size.
                ** Let's update the process flag for the record
                ** Give it value 42 if all okay and 32 if some validation failed in this procedure
                ** Need to do this ONLY if all previous validation okay.
                ** The process flag values that are possible at this time are
                ** 31, :set by INVPVHDR
                ** 32, :set by INVPVDR2
                ** 33, 43 :set by INVPVDR3
                */

      stmt := 911;

   /* Bug 4705184
      SELECT process_flag into temp_proc_flag
      FROM MTL_SYSTEM_ITEMS_INTERFACE
      WHERE inventory_item_id = l_item_id
      AND   set_process_id + 0 = xset_id
      AND   process_flag in (31,32,33,43)
      AND   organization_id = cr.organization_id
      AND   rownum < 2; */

                /* set value of process_flag to 44 or 34 depending on
                ** value of the variable: status.
                ** Essentially, we check to see if validation has not already failed in one of
                ** the previous packages.
                */

      stmt := 913;

      IF (temp_proc_flag <> 31  AND
          temp_proc_flag <> 32  AND
          temp_proc_flag <> 33 )
      THEN
         UPDATE MTL_SYSTEM_ITEMS_INTERFACE
         SET process_flag = DECODE(status,0,44,34),
             PRIMARY_UOM_CODE = cr.primary_uom_code,
             primary_unit_of_measure = cr.primary_unit_of_measure
         WHERE inventory_item_id = l_item_id
         -- AND   set_process_id + 0 = xset_id --fix for bug#8757041,removed + 0
         AND   set_process_id = xset_id
         AND   process_flag = 43
         AND   organization_id = cr.organization_id;
      END IF;
   END LOOP;  -- cr IN cc

   RETURN (0);

EXCEPTION
   WHEN LOGGING_ERR THEN
      return (dumm_status);

   WHEN VALIDATE_ERR THEN
      dumm_status := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                trans_id,
                                err_text,
                                'validation_error ' || stmt,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_OP_VALIDATION_ERR',
                                err_text);
      return (status);
   WHEN OTHERS THEN
       err_text := substr('INVPVDR4.validate_item_header4: ' || SQLERRM , 1, 240);
       IF l_inv_debug_level IN(101, 102) THEN
            INVPUTLI.info(err_text || ' (stmt=' || TO_CHAR(stmt) || ') TRANSACTION_ID : ' || TO_CHAR(trans_id));
       END IF;
       return (SQLCODE);
END validate_item_header4;

END INVPVDR4;

/
