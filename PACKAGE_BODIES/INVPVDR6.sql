--------------------------------------------------------
--  DDL for Package Body INVPVDR6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVDR6" AS
/* $Header: INVPVD6B.pls 120.20.12010000.3 2009/08/10 23:13:07 mshirkol ship $ */
FUNCTION validate_item_header6(
   org_id          NUMBER,
   all_org         NUMBER          := 2,
   prog_appid      NUMBER          := -1,
   prog_id         NUMBER          := -1,
   request_id      NUMBER          := -1,
   user_id         NUMBER          := -1,
   login_id        NUMBER          := -1,
   err_text IN OUT NOCOPY VARCHAR2,
   xset_id  IN     NUMBER     DEFAULT -999) RETURN INTEGER IS

   loc_ctrl_code       NUMBER;
   cost_flag           VARCHAR2(1);
   inv_asset_flag      VARCHAR2(1);
   mrp_stock_code      NUMBER;
   base_item           NUMBER;
   lead_lot_size       NUMBER;
   out_op_flag         VARCHAR2(1);
   shelf_code          NUMBER;
   temp                VARCHAR2(2);
   temp_uom_code       VARCHAR2(3);
   temp_u_o_m          VARCHAR2(25);
   temp_uom_class      VARCHAR2(10);
   temp_enabled_flag   VARCHAR2(1);
   reqst_id            NUMBER ;
   masterorg_id        NUMBER ;

   CURSOR cc IS
      SELECT *
      FROM   MTL_SYSTEM_ITEMS_INTERFACE
      WHERE ((organization_id  = org_id) OR (all_Org = 1))
      AND   set_process_id     = xset_id
      AND   process_flag in (31, 32, 33, 34 , 35 , 45);

   --Bug: 3028216 Get the category sets which does not have default cat
   CURSOR Func_Area_csr(cp_farea_id NUMBER) IS
      SELECT FUNCTIONAL_AREA_DESC, mcs.category_set_name
      FROM   mtl_category_sets_vl            mcs
            ,mtl_default_category_sets_fk_v  mdcs
      WHERE  mcs.category_set_id = mdcs.category_set_id
        AND  mcs.default_category_id IS NULL
	     AND  mdcs.functional_area_id = cp_farea_id; --Bug 4654433

   -- Added for bug # 3762750
   CURSOR c_mfglookup_exists(cp_lookup_type VARCHAR2,
                            cp_lookup_code VARCHAR2) IS
      SELECT 'x'
      FROM  MFG_LOOKUPS
      WHERE LOOKUP_TYPE     = cp_lookup_type
      AND   LOOKUP_CODE     = cp_lookup_code
      AND   SYSDATE BETWEEN   NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
      AND   ENABLED_FLAG    = 'Y';

   -- Added the cursor for bug # 3762750
   CURSOR c_fndlookup_exists(cp_lookup_type VARCHAR2,
                             cp_lookup_code VARCHAR2) IS
      SELECT 'x'
      FROM  FND_LOOKUP_VALUES_VL
      WHERE LOOKUP_TYPE = cp_lookup_type
      AND   LOOKUP_CODE = cp_lookup_code
      AND   SYSDATE BETWEEN  NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
      AND   ENABLED_FLAG = 'Y';

   --4195218 : Changed query for TAX_CODE
   /* Fix for bug 6350384- Tax Codes are stored at O.U level, so modified below cursor
      to add a subquery for fetching operating_unit */
    /*Bug 7437620  Modified the query to fetch the operating unit
      Table hr_organization_information is used instead of org_organization_defintions*/

   CURSOR c_tax_code_exists(cp_tax_code VARCHAR2, cp_org_id NUMBER) IS
      SELECT 'x'
      FROM   ZX_OUTPUT_CLASSIFICATIONS_V
      WHERE  lookup_code  = cp_tax_code
      AND    enabled_flag = 'Y'
      AND    SYSDATE BETWEEN  NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
      AND    org_id IN (-99,(SELECT org_information3 FROM  hr_organization_information
                                    WHERE ( ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
                                     AND ORGANIZATION_ID=cp_org_id));

   --Start 6531903:Default catalog to be run only once
   CURSOR c_function_area_setup IS
      SELECT functional_area_id
      FROM  mtl_default_category_sets dcs
           ,mtl_category_sets_b cs
      WHERE cs.category_set_id = dcs.category_set_id
        AND cs.default_category_id IS NULL
        AND dcs.functional_area_id IN (1,2,3,4,5,6,7,9,10);

   l_functional_area1      NUMBER := NULL;
   l_functional_area2      NUMBER := NULL;
   l_functional_area3      NUMBER := NULL;
   l_functional_area4      NUMBER := NULL;
   l_functional_area5      NUMBER := NULL;
   l_functional_area6      NUMBER := NULL;
   l_functional_area7      NUMBER := NULL;
   l_functional_area9      NUMBER := NULL;
   l_functional_area10     NUMBER := NULL;
   l_functional_area_id    NUMBER := NULL;
   --End 6531903:Default catalog to be run only once

   msicount                NUMBER;
   msiicount               NUMBER;
   resersal_flag           NUMBER;
   dup_item_id             NUMBER;
   l_item_id               NUMBER;
   l_org_id                NUMBER;
   cat_set_id              NUMBER;
   trans_id                NUMBER;
   ext_flag                NUMBER := 0;
   error_msg               VARCHAR2(2000);
   status                  NUMBER;
   dumm_status             NUMBER;
   master_org_id           NUMBER;
   stmt                    NUMBER;
   LOGGING_ERR             EXCEPTION;
   VALIDATE_ERR            EXCEPTION;
   chart_of_acc_id         NUMBER;   /*NP 30AUG94*/
   temp_proc_flag          NUMBER;
   temp_count              NUMBER;
   count_is_zero           EXCEPTION;
   l_process_flag_2        NUMBER := 2 ;
   l_process_flag_3        NUMBER := 3 ;
   l_process_flag_4        NUMBER := 4 ;
   l_Func_Area             VARCHAR2(2000);
   l_Cat_Set_Name          VARCHAR2(2000);
   Cat_Set_No_Default_Cat  EXCEPTION;
   validate_source         NUMBER;
   l_dummy                 VARCHAR2(1);
   l_logerr                NUMBER;
   l_inv_debug_level	   NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPVDR6.validate_item_header6 : begin');
   END IF;
   reqst_id := request_id ;
   error_msg := 'Validation error in validating MTL_SYSTEM_ITEMS_INTERFACE with ';

   --Start 3515652: Performance enhancements
   dumm_status := INVPUPI2.validate_flags(
                           org_id
                          ,all_org
                          ,prog_appid
                          ,prog_id
                          ,request_id
                          ,user_id
                          ,login_id
                          ,xset_id
                          ,err_text);

   if dumm_status <> 0 then
      raise LOGGING_ERR;
   end if;
   --End 3515652: Performance enhancements

   --Start 6531903:Default catalog to be run only once
   OPEN c_function_area_setup;
   LOOP
      FETCH c_function_area_setup INTO l_functional_area_id;
      EXIT WHEN c_function_area_setup%NOTFOUND;
      IF l_functional_area_id = 1 THEN
         l_functional_area1    := 1;
      ELSIF l_functional_area_id = 2 THEN
         l_functional_area2    := 2;
      ELSIF l_functional_area_id = 3 THEN
         l_functional_area3    := 3;
      ELSIF l_functional_area_id = 4 THEN
         l_functional_area4    := 4;
      ELSIF l_functional_area_id = 5 THEN
         l_functional_area5    := 5;
      ELSIF l_functional_area_id = 6 THEN
         l_functional_area6    := 6;
      ELSIF l_functional_area_id = 7 THEN
         l_functional_area7    := 7;
      ELSIF l_functional_area_id = 9 THEN
         l_functional_area9    := 9;
      ELSIF l_functional_area_id = 10 THEN
         l_functional_area10   := 10;
      END IF;
    END LOOP;
   --End 6531903:Default catalog to be run only once

   FOR cr IN cc LOOP
      status   := 0;
      trans_id := cr.transaction_id;
      l_org_id := cr.organization_id;
      l_item_id := cr.inventory_item_id; -- Bug 4705184
      temp_proc_flag := cr.process_flag; -- Bug 4705184

  /* Bug 4705184
      select inventory_item_id into l_item_id
      from mtl_system_items_interface
      where transaction_id = cr.transaction_id
      and   set_process_id = xset_id; */

      -- Validate second group of foreign keys
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVDR6.validate_item_header6: validating foreign keys set 3');
      END IF;

      stmt := 31;
      -- validate foreign keys
      temp_count := 0;
      if  cr.PLANNING_EXCEPTION_SET is not null then
         begin
            select count(*) into temp_count
            from MRP_PLANNING_EXCEPTION_SETS
            where EXCEPTION_SET_NAME = cr.PLANNING_EXCEPTION_SET;
            if temp_count = 0 then
               RAISE count_is_zero;
            end if;
         exception
            WHEN count_is_zero THEN
               dumm_status := INVPUOPI.mtl_log_interface_err(
                  cr.organization_id,
                  user_id,
                  login_id,
                  prog_appid,
                  prog_id,
                  request_id,
                  cr.TRANSACTION_ID,
                  error_msg,
                  'PLANNING_EXCEPTION_SET',
                  'MTL_SYSTEM_ITEMS_INTERFACE',
                  'INV_IOI_PLN_EXC_SET',
                  err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      stmt := 32;
                -- validate foreign keys
      if cr.ATP_RULE_ID is not null then
         begin
            select 'x' into temp
            from MTL_ATP_RULES
            where RULE_ID = cr.ATP_RULE_ID;
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                    cr.organization_id,
                    user_id,
                    login_id,
                    prog_appid,
                    prog_id,
                    request_id,
                    cr.TRANSACTION_ID,
                    error_msg,
                    'ATP_RULE_ID',
                    'MTL_SYSTEM_ITEMS_INTERFACE',
                    'INV_IOI_ATP_RULE',
                    err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      stmt := 33;
      -- validate foreign keys
      if  cr.BASE_WARRANTY_SERVICE_ID is not null then
         begin
            select 'x' into temp
            from MTL_SYSTEM_ITEMS_B
            where INVENTORY_ITEM_ID = cr.BASE_WARRANTY_SERVICE_ID
            and   ORGANIZATION_ID = cr.ORGANIZATION_ID;
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                 cr.organization_id,
                 user_id,
                 login_id,
                 prog_appid,
                 prog_id,
                 request_id,
                 cr.TRANSACTION_ID,
                 error_msg,
                 'BASE_WARRANTY_SERVICE_ID',
                 'MTL_SYSTEM_ITEMS_INTERFACE',
                 'INV_IOI_BASE_WAR_SERV',
                 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      stmt := 34;
      -- validate foreign keys
      if  cr.PAYMENT_TERMS_ID is not null then
         begin
            select 'x' into temp
            from RA_TERMS
            where TERM_ID = cr.PAYMENT_TERMS_ID;
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                 cr.organization_id,
                 user_id,
                 login_id,
                 prog_appid,
                 prog_id,
                 request_id,
                 cr.TRANSACTION_ID,
                 error_msg,
                 'PAYMENT_TERMS_ID',
                 'MTL_SYSTEM_ITEMS_INTERFACE',
                 'INV_IOI_PAYMENT_TERMS',
                 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      stmt := 34;
      -- validate foreign keys
      if cr.UNIT_OF_ISSUE is not null then
         begin
            select master_organization_id
            into masterorg_id
            from mtl_parameters
            where organization_id = cr.organization_id ;

            if (cr.transaction_type = 'CREATE') then
               if (masterorg_id = cr.organization_id) then
                  select 'x' into temp
                  from MTL_UNITS_OF_MEASURE muom1
                  where muom1.UNIT_OF_MEASURE = cr.UNIT_OF_ISSUE
                   and  muom1.UOM_CLASS in
                              (select UOM_CLASS
                               from MTL_UNITS_OF_MEASURE muom2
                               where muom2.UNIT_OF_MEASURE = cr.PRIMARY_UNIT_OF_MEASURE);
               else
                  select 'x' into temp
                  from mtl_item_uoms_view
                  where organization_id = masterorg_id
                  and inventory_item_id = cr.inventory_item_id
                  and unit_of_measure = cr.unit_of_issue ;
               end if ;
            else
               select 'x' into temp
               from mtl_item_uoms_view
               where organization_id = cr.organization_id
               and inventory_item_id = cr.inventory_item_id
               and unit_of_measure = cr.unit_of_issue ;
            end if ;
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                  cr.organization_id,
                  user_id,
                  login_id,
                  prog_appid,
                  prog_id,
                  request_id,
                  cr.TRANSACTION_ID,
                  error_msg,
                  'UNIT_OF_ISSUE',
                  'MTL_SYSTEM_ITEMS_INTERFACE',
                  'INV_IOI_UNIT_OF_ISSUE',
                  err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      stmt := 38;
      -- validate foreign keys
      if  cr.SOURCE_ORGANIZATION_ID is not null then
         begin
	/*	Fix for bug 5844510-Use org_organization_definitions view
		instead of mtl_parameters to validate the source org, since
		an organization's disable date can be obtained from ood view.
		select 'x' into temp
		from MTL_PARAMETERS
		where ORGANIZATION_ID = cr.SOURCE_ORGANIZATION_ID;
        */
                select 'x' into temp
                from org_organization_definitions
                where ORGANIZATION_ID = cr.SOURCE_ORGANIZATION_ID
                and  nvl(disable_date,sysdate+1) > sysdate;
	exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                 cr.organization_id,
                 user_id,
                 login_id,
                 prog_appid,
                 prog_id,
                 request_id,
                 cr.TRANSACTION_ID,
                 error_msg,
                 'SOURCE_ORGANIZATION_ID',
                 'MTL_SYSTEM_ITEMS_INTERFACE',
                 'INV_IOI_SOURCE_ORG_ID',
                 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      stmt := 39;
      -- validate foreign keys
      if  cr.DEFAULT_SHIPPING_ORG is not null then
         begin
            select 'x' into temp
            from MTL_PARAMETERS
            where ORGANIZATION_ID = cr.DEFAULT_SHIPPING_ORG;
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                 cr.organization_id,
                 user_id,
                 login_id,
                 prog_appid,
                 prog_id,
                 request_id,
                 cr.TRANSACTION_ID,
                 error_msg,
                 'DEFAULT_SHIPPING_ORG',
                 'MTL_SYSTEM_ITEMS_INTERFACE',
                 'INV_IOI_DEF_SHIPPING_ORG',
                 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      stmt := 40;
      -- validate foreign keys
      --Bug: 5032896. Modified the query below to include all Accounting Rules and exclude Invoicing Rules
      if  cr.ACCOUNTING_RULE_ID is not null then
         begin
            select 'x' into temp
            from RA_RULES
            where RULE_ID = cr.ACCOUNTING_RULE_ID
	    and TYPE not in ('I')
	    and STATUS = 'A';
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                 cr.organization_id,
                 user_id,
                 login_id,
                 prog_appid,
                 prog_id,
                 request_id,
                 cr.TRANSACTION_ID,
                 error_msg,
                 'ACCOUNTING_RULE_ID',
                 'MTL_SYSTEM_ITEMS_INTERFACE',
                 'INV_IOI_ACCT_RULE_ID',
                 err_text);
                 if dumm_status < 0 then
                         raise LOGGING_ERR;
                 end if;
                 status := 1;
         end;
      end if;

		IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPVDR6: Validating foreign keys set 4');
      END IF;

      stmt := 41;
      -- validate foreign keys
      if  cr.INVOICING_RULE_ID is not null then
         begin
            select 'x' into temp
            from RA_RULES
            where RULE_ID = cr.INVOICING_RULE_ID;
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                 cr.organization_id,
                 user_id,
                 login_id,
                 prog_appid,
                 prog_id,
                 request_id,
                 cr.TRANSACTION_ID,
                 error_msg,
                 'INVOICING_RULE_ID',
                 'MTL_SYSTEM_ITEMS_INTERFACE',
                 'INV_IOI_INVOICING_RULE_ID',
                 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      stmt := 43;
      -- validate foreign keys
      if  cr.PLANNER_CODE is not null then
         begin
            select 'x' into temp
            from MTL_PLANNERS
            where PLANNER_CODE = cr.PLANNER_CODE
            and   ORGANIZATION_ID = cr.ORGANIZATION_ID
            and   SYSDATE < nvl(DISABLE_DATE, SYSDATE+1); /*NP 16OCT94*/
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                 cr.organization_id,
                 user_id,
                 login_id,
                 prog_appid,
                 prog_id,
                 request_id,
                 cr.TRANSACTION_ID,
                 error_msg,
                 'PLANNER_CODE',
                 'MTL_SYSTEM_ITEMS_INTERFACE',
                 'INV_IOI_PLANNER_CODE',
                 err_text);
                 if dumm_status < 0 then
                    raise LOGGING_ERR;
                 end if;
                 status := 1;
         end;
      end if;

      --Added for 11.5.10 CTO
      stmt := 44;
      --* Added for Bug #4457440
		if  cr.START_DATE_ACTIVE is not null then
		   dumm_status := INVPUOPI.mtl_log_interface_err(
            cr.organization_id,
            user_id,
            login_id,
            prog_appid,
            prog_id,
            request_id,
            cr.TRANSACTION_ID,
            error_msg,
			   'START_DATE_ACTIVE',
			   'MTL_SYSTEM_ITEMS_INTERFACE',
			   'INV_START_DATE_END_DATE_WARN',
			   err_text);
			if dumm_status < 0 then
				raise LOGGING_ERR;
			end if;
		end if;

		if  cr.END_DATE_ACTIVE is not null then
		   dumm_status := INVPUOPI.mtl_log_interface_err(
            cr.organization_id,
            user_id,
            login_id,
            prog_appid,
            prog_id,
            request_id,
            cr.TRANSACTION_ID,
            error_msg,
            'END_DATE_ACTIVE',
            'MTL_SYSTEM_ITEMS_INTERFACE',
            'INV_START_DATE_END_DATE_WARN',
            err_text);
			if dumm_status < 0 then
				raise LOGGING_ERR;
			end if;
      end if;
		--* End of Bug #4457440

      -- validate foreign keys
      if  (cr.CONFIG_ORGS is not null) then
         --3762750: Using cursor call to avoid multiple parsing
	 temp := null;
         OPEN  c_fndlookup_exists('INV_CONFIG_ORGS_TYPE',cr.CONFIG_ORGS);
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
                      'CONFIG_ORGS',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_INVALID_ATTR_COL_VALUE',
                      err_text);
            if dumm_status < 0 then
               raise LOGGING_ERR;
            end if;
            status := 1;
         end if;
      end if;

      if  (cr.CONFIG_MATCH is not null) then
         --3762750: Using cursor call to avoid multiple parsing
 	 temp := null;
         OPEN  c_fndlookup_exists('INV_CONFIG_MATCH_TYPE',cr.CONFIG_MATCH);
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
                      'CONFIG_MATCH',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_INVALID_ATTR_COL_VALUE',
                      err_text);
            if dumm_status < 0 then
               raise LOGGING_ERR;
            end if;
            status := 1;
         end if;
      end if;

      stmt := 45;
      -- validate foreign keys
      if  (cr.CONFIG_ORGS is not null OR cr.CONFIG_MATCH is not null) then
         if NOT (cr.BOM_ITEM_TYPE = 1 and NVL(cr.PICK_COMPONENTS_FLAG,'N') = 'N') then
            dumm_status := INVPUOPI.mtl_log_interface_err(
                cr.organization_id,
                user_id,
                login_id,
                prog_appid,
                prog_id,
                request_id,
                cr.TRANSACTION_ID,
                error_msg,
                'CONFIG_ORGS_OR_CONFIG_MATCH',
                'MTL_SYSTEM_ITEMS_INTERFACE',
                'INV_CONFIG_ORG_MATCH',
                 err_text);
            if dumm_status < 0 then
               raise LOGGING_ERR;
            end if;
            status := 1;
         end if;
      end if;

      --Start : 3436146 WIP Supply Type must be Phantom when BOM Item Type is Option Class.
      if (cr.BOM_ITEM_TYPE = 2 and cr.WIP_SUPPLY_TYPE <> 6) then
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
                'INV_ITEM_OPTION_PHANTOM',
                 err_text);
         if dumm_status < 0 then
            raise LOGGING_ERR;
         end if;
         status := 1;
      end if;
      --End : 3436146 WIP Supply Type must be Phantom when BOM Item Type is Option Class.

      stmt := 47;
      if  (cr.INVENTORY_PLANNING_CODE is not null) then
         --3762750: Using cursor call to avoid multiple parsing
 	 temp := null;
         OPEN  c_fndlookup_exists('MTL_MATERIAL_PLANNING',cr.INVENTORY_PLANNING_CODE);
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
                      'INVENTORY_PLANNING_CODE',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_INVALID_ATTR_COL_VALUE',
                      err_text);
             if dumm_status < 0 then
                raise LOGGING_ERR;
             end if;
             status := 1;
          end if;
      end if;

      if  (cr.INVENTORY_PLANNING_CODE = 7) then
         begin
           select 'x' into temp
           from hr_organization_information
           where org_information_context = 'Customer/Supplier Association'
           and (org_information1 is not null or org_information3 is not null)
           and organization_id = cr.organization_id;
         exception
            when NO_DATA_FOUND then
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
                 'MTL_MSI_GP_INV_PLAN_CODE',
                 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      /* Adding validation to throw an error when Min-Max quantities are set to NOT NULL with
         Inventory Planning Code NOT Min-Max - Bug 5478211 */
	 --Bug: 5478211 Error will only be thrown when Inventory Planning Code is Vendor Managed

	 if ( cr.inventory_planning_code = 7 AND
	     (cr.MIN_MINMAX_QUANTITY IS NOT NULL OR
	      cr.MAX_MINMAX_QUANTITY IS NOT NULL OR
	      cr.MINIMUM_ORDER_QUANTITY IS NOT NULL OR
	      cr.MAXIMUM_ORDER_QUANTITY IS NOT NULL)) then
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
                            'INV_MINMAX_QUANTITIES',
                             err_text);
                 if dumm_status < 0 then
                   raise LOGGING_ERR;
                 end if;
                 status := 1;
	 end if;

      -- validate foreign keys
      if  ( cr.vmi_minimum_units is not null) then
         begin
             if floor(abs(cr.vmi_minimum_units)) - abs(cr.vmi_minimum_units ) <>  0 then
                raise no_data_found;
              end if;
              if cr.vmi_minimum_units <=  0 then
                 raise too_many_rows;
              end if;
         exception
            when NO_DATA_FOUND then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                      cr.organization_id,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      request_id,
                      cr.TRANSACTION_ID,
                      error_msg,
                      'VMI_MINIMUM_UNITS',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_VMI_INTEGER_VALUE',
                      err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
            when TOO_MANY_ROWS then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                      cr.organization_id,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      request_id,
                      cr.TRANSACTION_ID,
                      error_msg,
                      'VMI_MINIMUM_UNITS',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_VMI_GREATER_THAN_ZERO',
                      err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
         end;
      end if;

      -- validate foreign keys
      if  ( cr.vmi_minimum_days is not null) then
              begin
               if floor(abs(cr.vmi_minimum_days)) - abs(cr.vmi_minimum_days ) <>  0 then
                  raise no_data_found;
               end if;
               if cr.vmi_minimum_days <=  0 then
                  raise too_many_rows;
               end if;
              exception
              when NO_DATA_FOUND then
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                      cr.organization_id,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      request_id,
                      cr.TRANSACTION_ID,
                      error_msg,
                      'VMI_MINIMUM_DAYS',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_VMI_INTEGER_VALUE',
                      err_text);
                      if dumm_status < 0 then
                              raise LOGGING_ERR;
                      end if;
                      status := 1;
              when TOO_MANY_ROWS then
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                      cr.organization_id,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      request_id,
                      cr.TRANSACTION_ID,
                      error_msg,
                      'VMI_MINIMUM_DAYS',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_VMI_GREATER_THAN_ZERO',
                      err_text);
                      if dumm_status < 0 then
                              raise LOGGING_ERR;
                      end if;
                      status := 1;
              end;
      end if;

      -- validate foreign keys
      if  ( cr.vmi_maximum_units is not null) then
              begin
               if floor(abs(cr.vmi_maximum_units)) - abs(cr.vmi_maximum_units ) <>  0 then
                  raise no_data_found;
               end if;
               if cr.vmi_maximum_units <=  0 then
                  raise too_many_rows;
               end if;
              exception
              when NO_DATA_FOUND then
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                      cr.organization_id,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      request_id,
                      cr.TRANSACTION_ID,
                      error_msg,
                      'VMI_MAXIMUM_UNITS',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_VMI_INTEGER_VALUE',
                      err_text);
                      if dumm_status < 0 then
                              raise LOGGING_ERR;
                      end if;
                      status := 1;
              when TOO_MANY_ROWS then
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                      cr.organization_id,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      request_id,
                      cr.TRANSACTION_ID,
                      error_msg,
                      'VMI_MAXIMUM_UNITS',
                      'MTL_SYSTEM_ITEMS_INTERFACE',
                      'INV_VMI_GREATER_THAN_ZERO',
                      err_text);
                      if dumm_status < 0 then
                              raise LOGGING_ERR;
                      end if;
                      status := 1;
              end;
      end if;

         -- validate foreign keys
                if  ( cr.vmi_maximum_days is not null) then
                        begin
                         if floor(abs(cr.vmi_maximum_days)) - abs(cr.vmi_maximum_days ) <>  0 then
                            raise no_data_found;
                         end if;
                         if cr.vmi_maximum_days <=  0 then
                            raise too_many_rows;
                         end if;
                        exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MAXIMUM_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_INTEGER_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        when TOO_MANY_ROWS then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MAXIMUM_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_GREATER_THAN_ZERO',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

         -- validate foreign keys
                if  ( cr.vmi_fixed_order_quantity is not null) then
                        begin
                         if floor(abs(cr.vmi_fixed_order_quantity)) - abs(cr.vmi_fixed_order_quantity ) <>  0 then
                            raise no_data_found;
                         end if;
                         if cr.vmi_fixed_order_quantity <=  0 then
                            raise too_many_rows;
                         end if;
                        exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_FIXED_ORDER_QUANTITY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_INTEGER_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        when TOO_MANY_ROWS then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_FIXED_ORDER_QUANTITY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_GREATER_THAN_ZERO',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

                if  ( cr.vmi_minimum_units is not null)
                    and ( cr.vmi_minimum_days  is not null) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MINIMUM_UNITS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MIN_UNITS_DAYS_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                 end if;

                if  ( cr.vmi_maximum_units is not null)
                    and ( cr.vmi_fixed_order_quantity is not null) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MAXIMUM_UNITS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MAX_UNITS_DAYS_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                 end if;

                if  ( cr.vmi_maximum_days is not null)
                    and ( cr.vmi_fixed_order_quantity is not null) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MAXIMUM_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MAX_UNITS_DAYS_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                 end if;

                if  ( cr.vmi_maximum_days is not null)
                    and ( cr.vmi_maximum_units is not null) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MAXIMUM_UNITS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MAX_DAYS_UNIT_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                 end if;

                if  ( cr.vmi_minimum_units is not null)
                    and ( cr.vmi_maximum_days is not null) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MAXIMUM_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MIN_MAX_UNITS_DAYS_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                 end if;

                if  ( cr.vmi_minimum_days is not null)
                    and ( cr.vmi_maximum_units is not null) then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MINIMUM_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MIN_MAX_UNITS_DAYS_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                 end if;

                if  (  (nvl(cr.vmi_fixed_order_quantity,0) = 0 )
                   and (cr.vmi_minimum_units > nvl(cr.vmi_maximum_units,0)))  then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MINIMUM_UNITS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MIN_MAX_QTY_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                end if;

                 if   nvl(cr.vmi_fixed_order_quantity,0) = 0
                      and cr.vmi_minimum_days >  nvl(cr.vmi_maximum_days,0)   then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_MINIMUM_DAYS',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_MIN_DAYS_MAX_DAYS_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                 end if;

         -- validate foreign keys
                if  ( cr.forecast_horizon is not null) then
                        begin
                         if floor(abs(cr.forecast_horizon)) - abs(cr.forecast_horizon ) <>  0 then
                            raise no_data_found;
                         end if;
                         if cr.forecast_horizon <  0 then
                            raise too_many_rows;
                         end if;
                        exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'FORECAST_HORIZON',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_INTEGER_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        when TOO_MANY_ROWS then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'FORECAST_HORIZON',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_GREATER_THAN_ZERO',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

         -- validate foreign keys
                if  ( cr.days_tgt_inv_supply is not null) then
                        begin
                         if floor(abs(cr.days_tgt_inv_supply)) - abs(cr.days_tgt_inv_supply ) <>  0 then
                            raise no_data_found;
                         end if;
                         if cr.days_tgt_inv_supply <  0 then
                            raise too_many_rows;
                         end if;
                        exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DAYS_TGT_INV_SUPPLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_INTEGER_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        when TOO_MANY_ROWS then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DAYS_TGT_INV_SUPPLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_GREATER_THAN_ZERO',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

         -- validate foreign keys
                if  ( cr.days_tgt_inv_window is not null) then
                        begin
                         if floor(abs(cr.days_tgt_inv_window)) - abs(cr.days_tgt_inv_window ) <>  0 then
                            raise no_data_found;
                         end if;
                         if cr.days_tgt_inv_window <  0 then
                            raise too_many_rows;
                         end if;
                        exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DAYS_TGT_INV_WINDOW',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_INTEGER_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        when TOO_MANY_ROWS then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DAYS_TGT_INV_WINDOW',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_GREATER_THAN_ZERO',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

 -- validate foreign keys
                if  ( cr.days_max_inv_window is not null) then
                        begin
                         if floor(abs(cr.days_max_inv_window)) - abs(cr.days_max_inv_window ) <>  0 then
                            raise no_data_found;
                         end if;
                         if cr.days_max_inv_window <  0 then
                            raise too_many_rows;
                         end if;
                        exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DAYS_MAX_INV_WINDOW',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_INTEGER_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        when TOO_MANY_ROWS then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DAYS_MAX_INV_WINDOW',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_GREATER_THAN_ZERO',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;

         -- validate foreign keys
                if  ( cr.days_max_inv_supply is not null) then
                        begin
                         if floor(abs(cr.days_max_inv_supply)) - abs(cr.days_max_inv_supply ) <>  0 then
                            raise no_data_found;
                         end if;
                         if cr.days_max_inv_supply <  0 then
                            raise too_many_rows;
                         end if;
                        exception
                        when NO_DATA_FOUND then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DAYS_MAX_INV_SUPPLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_INTEGER_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        when TOO_MANY_ROWS then
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DAYS_MAX_INV_SUPPLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_VMI_GREATER_THAN_ZERO',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        end;
                end if;


                -- validate foreign keys
                if  ( cr.consigned_flag is not null) then

                        -- 3762750: Using cursor call to avoid multiple parsing
     		        temp := null;
                        OPEN  c_mfglookup_exists('SYS_YES_NO',CR.CONSIGNED_FLAG);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CONSIGNED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;

                -- validate foreign keys
                if  ( cr.asn_autoexpire_flag is not null) then

                        -- 3762750: Using cursor call to avoid multiple parsing
 		        temp := null;
                        OPEN  c_mfglookup_exists('SYS_YES_NO',CR.ASN_AUTOEXPIRE_FLAG);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'ASN_AUTOEXPIRE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;

                 -- validate foreign keys
                if  ( cr.exclude_from_budget_flag is not null) then
                        -- 3762750: Using cursor call to avoid multiple parsing
 		        temp := null;
                        OPEN  c_mfglookup_exists('SYS_YES_NO',CR.EXCLUDE_FROM_BUDGET_FLAG);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'EXCLUDE_FROM_BUDGET_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;

                  -- validate foreign keys
                if  ( cr.drp_planned_flag is not null) then
                        -- 3762750: Using cursor call to avoid multiple parsing
		        temp := null;
                        OPEN  c_mfglookup_exists('SYS_YES_NO',CR.DRP_PLANNED_FLAG);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DRP_PLANNED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;

                     -- validate foreign keys
                if  ( cr.critical_component_flag is not null) then
                        -- 3762750: Using cursor call to avoid multiple parsing
			temp := null;
                        OPEN  c_mfglookup_exists('SYS_YES_NO',CR.CRITICAL_COMPONENT_FLAG);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CRITICAL_COMPONENT_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;


                -- validate foreign keys
                if  ( cr.so_authorization_flag is not null) then
                        -- 3762750: Using cursor call to avoid multiple parsing
			temp := null;
                        OPEN  c_mfglookup_exists('MTL_MSI_GP_RELEASE_AUTH',CR.SO_AUTHORIZATION_FLAG);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SO_AUTHORIZATION_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;
                                -- validate foreign keys
                if  ( cr.vmi_forecast_type is not null) then
                        -- 3762750: Using cursor call to avoid multiple parsing
			temp := null;
                        OPEN  c_mfglookup_exists('MTL_MSI_GP_FORECAST_TYPE',CR.VMI_FORECAST_TYPE);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'VMI_FORECAST_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;
                -- validate foreign keys
                if  ( cr.continous_transfer is not null) then
                        -- 3762750: Using cursor call to avoid multiple parsing
			temp := null;
                        OPEN  c_mfglookup_exists('MTL_MSI_MRP_INT_ORG',CR.CONTINOUS_TRANSFER);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CONTINOUS_TRANSFER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;
                -- validate foreign keys
                if  ( cr.convergence is not null) then
                        -- 3762750: Using cursor call to avoid multiple parsing
			temp := null;
                        OPEN  c_mfglookup_exists('MTL_MSI_MRP_CONV_SUPP',CR.CONVERGENCE);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                              dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CONVERGENCE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;
                -- validate foreign keys
                if  ( cr.divergence is not null) then
                        -- 3762750: Using cursor call to avoid multiple parsing
			temp := null;
                        OPEN  c_mfglookup_exists('MTL_MSI_MRP_DIV_SUPP',CR.DIVERGENCE);
                        FETCH c_mfglookup_exists INTO temp;
                        CLOSE c_mfglookup_exists;

                        IF (temp IS NULL) THEN
                                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'DIVERGENCE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                status := 1;
                        END IF;
                end if;
                --Start of bug fix: 3095347
               /* Fix for bug 5844510- Source Org/SubInv Should be Null
                   when source_type is either null or Supplier(2).
                   Changed the error msg too to indicate the same since source_type
                   is the driving column and source org/SubInv are dependent on it.
                   Prior to fix, error msg indicated that source_type has to corrected.*/
                if  ( ( (cr.source_type is null) or (cr.source_type = 2) )
                      and (cr.source_organization_id is not null
                           or cr.source_subinventory is not null))
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
                                'SOURCE_TYPE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SOURCE_ORG_MUST_BE_NULL',
                                err_text);
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                      status := 1;
                end if;

                if  (cr.source_type is not null
                     and cr.source_organization_id = nvl(org_id,cr.organization_id)
                     and cr.mrp_planning_code      = 3
                     and cr.source_subinventory    is null)
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
                                'SOURCE_SUBINVENTORY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_SOURCE_SUBINV_REQUIRED',
                                err_text);
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                      status := 1;
                end if;

                if cr.source_type in (1,3)
                   and cr.source_organization_id is not null
                then
                   validate_source := INVIDIT1.validate_source_org(
                                         cr.organization_id,
                                         cr.inventory_item_id,
                                         cr.inventory_item_id,
                                         cr.source_organization_id,
                                         cr.mrp_planning_code,
                                         cr.source_subinventory);
                   /* Fix for bug 5844510- For throwing INV_ITEM_IN_SOURCE_ORG error,
                      compare validate_source with value 1. Prior to the fix, it was
                      comparing with value 3 which is wrong.*/
                   if (validate_source = 1
                      and cr.source_organization_id <> cr.organization_id )
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
                                'SOURCE_SUBINVENTORY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_ITEM_IN_SOURCE_ORG',
                                err_text);
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                      status := 1;
                   elsif ( validate_source = 3 ) then
                      dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'SOURCE_SUBINVENTORY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INTERORG_NTWK',
                                err_text);
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                      status := 1;
                   end if;
                end if;

		/* R12 Enhancement - Adding validation */

	     if  cr.TAX_CODE is not null then
	        IF l_inv_debug_level IN(101, 102) THEN
              INVPUTLI.info('INVPVDR6: Calling INVPVDR6 - Verifying lookup type for tax code ');
           END IF;

	   temp := null;
	   OPEN  c_tax_code_exists(cr.TAX_CODE,cr.organization_id);
           FETCH c_tax_code_exists INTO temp;
           CLOSE c_tax_code_exists;

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
	                                'TAX_CODE',
	                                'MTL_SYSTEM_ITEMS_INTERFACE',
	                                'INV_IOI_TAX_CODE',
	                                err_text);
	                    if dumm_status < 0 then
	                           raise LOGGING_ERR;
	                    end if;
	                    status := 1;

	             END IF;

	        END IF;


                --End   of bug fix:  3095347
		/* Bug: 5178297 Commenting this block to allow negative values for Lead Times
                --Start : 2990665 Lead Time Quantities cannot be negative.
                if  (cr.PREPROCESSING_LEAD_TIME        < 0
                     or cr.FULL_LEAD_TIME              < 0
                     or cr.POSTPROCESSING_LEAD_TIME    < 0
                     or cr.FIXED_LEAD_TIME             < 0
                     or cr.VARIABLE_LEAD_TIME          < 0
                     or cr.CUM_MANUFACTURING_LEAD_TIME < 0
                     or cr.CUMULATIVE_TOTAL_LEAD_TIME  < 0
                     or cr.LEAD_TIME_LOT_SIZE          < 0)
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
                                'LEAD_TIMES_QUANTITIES',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_NEGATIVE_LEAD_TIME_QTY',
                                err_text);
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                      status := 1;
                end if;
                --End   : 2990665
                End Commenting Bug: 5178297*/
--Bug:3309789 DRP planned items cannot be enabled with Assemble to Order
                if  (cr.drp_planned_flag = 1
                     and cr.replenish_to_order_flag = 'Y' )
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
                                'DRP_PLANNED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_DRP_CANNOT_BE_ATO',
                                err_text);
                      if dumm_status < 0 then
                         raise LOGGING_ERR;
                      end if;
                      status := 1;
                end if;


   /* NP 09SEP94
   ** call INVPUOPI.validate_flags to validate the yes/no flags
   ** function validate_flags now resides in INVPUPI2 instead of INVPVALI
   ** NP 06MAY96: No need to add xset_id call since it processes with row_id
   ** which is absolutely unique.Moving this code above all beacause of perf reasons.
      3515652: Performance enhancements, now validate flag works on setid

	  IF l_inv_debug_level IN(101, 102) THEN
             INVPUTLI.info('INVPVDR6: Calling INVPUPI2.validate_flags');
          END IF;
          dumm_status := INVPUPI2.validate_flags (
                                                cr.rowid,
                                                 prog_appid,
                                                 prog_id,
                                                 request_id,
                                                 user_id,
                                                 login_id,
                                                 err_text);

          if dumm_status < 0 then
             raise LOGGING_ERR;
          end if;

          if dumm_status <> 0 then
             status := 1;
          end if;
*/
/*
** call the costing package to validate the cost columns
** NP 06MAY96: No need to pass xset_id to CSTFVSUB procedure
** The transaction_id is passed and that is unique enough
** for all the updates that CSTFVSUB does to MSII.
*/

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPVDR6: Calling INVPCOII.CSTFVSUB Costing package');
   END IF;


/* INVPUTLI.info(cr.rowid|| ' ' ||user_id|| ' ' ||login_id||' ');
** INVPUTLI.info(request_id||' ' || prog_id||' '||prog_appid||' '|| err_text);
*/
        dumm_status := INVPCOII.CSTFVSUB(cr.transaction_id,
	                                 cr.material_sub_elem,
					 cr.material_oh_sub_elem,
					 cr.organization_id,
                                                 user_id,
                                                 login_id,
                                                 request_id,
                                                 prog_id,
                                                 prog_appid,
                                                 err_text);
                                if dumm_status < 0 then
                                        raise LOGGING_ERR;
                                end if;
                                if dumm_status <> 0 then
                                        status := 1;
                                end if;

stmt := 48;

--Bug: 3028216 check of defautl categories
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPPROC.inproit_process_item: Checking Default categories before insert');
   END IF;

        BEGIN
	   l_logerr := 0;

	   --Start 6531903:Default catalog to be run only once
	   IF cr.inventory_item_flag = 'Y' AND l_functional_area1 IS NOT NULL THEN
	      l_logerr := l_functional_area1;
	   ELSIF (cr.purchasing_item_flag = 'Y' OR cr.internal_order_flag ='Y') AND l_functional_area2 IS NOT NULL THEN
              l_logerr := l_functional_area2;
	   ELSIF cr.mrp_planning_code = 6 AND l_functional_area3 IS NOT NULL THEN
              l_logerr := l_functional_area3;
	   ELSIF cr.serviceable_product_flag = 'Y' AND l_functional_area4 IS NOT NULL THEN
              l_logerr := l_functional_area4;
	   ELSIF cr.costing_enabled_flag = 'Y' AND l_functional_area5 IS NOT NULL THEN
              l_logerr := l_functional_area5;
	   ELSIF cr.eng_item_flag = 'Y' AND l_functional_area6 IS NOT NULL THEN
              l_logerr := l_functional_area6;
	   ELSIF cr.customer_order_flag = 'Y' AND l_functional_area7 IS NOT NULL THEN
              l_logerr := l_functional_area7;
	   ELSIF cr.eam_item_type IS NOT NULL AND l_functional_area9 IS NOT NULL THEN
              l_logerr := l_functional_area9;
	   ELSIF cr.contract_item_type_code IS NOT NULL AND l_functional_area10 IS NOT NULL THEN
              l_logerr := l_functional_area10;
           END IF;
	   --End 6531903:Default catalog to be run only once

           IF l_logerr <> 0 THEN
	      OPEN Func_Area_csr(l_logerr);
	      FETCH Func_Area_csr INTO l_Func_Area,l_Cat_Set_Name;
              CLOSE Func_Area_csr;
              RAISE Cat_Set_No_Default_Cat;
	   END IF;
        EXCEPTION
          WHEN Cat_Set_No_Default_Cat THEN
             IF ( Func_Area_csr%ISOPEN ) THEN
                CLOSE Func_Area_csr;
             END IF;
             FND_MESSAGE.SET_NAME ('INV', 'INV_CAT_SET_NO_DEFAULT_CAT');
             FND_MESSAGE.SET_TOKEN ('ENTITY1', l_Func_Area);
             FND_MESSAGE.SET_TOKEN ('ENTITY2', l_Cat_Set_Name);
             error_msg := FND_MESSAGE.GET;
             dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                null,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_CAT_SET_NO_DEFAULT_CAT',
                                err_text);
             if dumm_status < 0 then
                 raise LOGGING_ERR;
             end if;
             status := 1;
       END;  -- Check of default category

                /* NP26DEC94 : New code to update process_flag.
                ** This code necessiated due to the breaking up INVPVHDR into
                ** 6 smaller packages to overcome PL/SQL limitations
                ** with code size.
                ** Let's update the process flag for the record
                ** Give it value 42 if all okay and 32 if some
                ** validation failed in this procedure
                ** Need to do this ONLY if all previous validation okay.
                ** The process flag values that are possible at this time are
                ** 31 :set by INVPVHDR
                ** 32 :set by INVPVDR2
                ** 33 :set by INVPVDR3
                ** 34 :set by INVPVDR4
                ** 35, 45 :set by INVPVDR5
                ** 36, 46 :set by INVPVDR7
                */

           /*   Bug 4705184
	        select process_flag into temp_proc_flag
                from MTL_SYSTEM_ITEMS_INTERFACE
                where inventory_item_id = l_item_id
                and   set_process_id + 0 = xset_id
                and   process_flag in (31, 32, 33, 34, 35, 45)
                and   organization_id = cr.organization_id
                and   rownum < 2; */

                /* Bug 3713912 set value of process_flag to 46 or 36 depending on
                ** value of the variable: status.
                ** Essentially, we check to see if validation has not already failed in one of
                ** the previous packages.
                */

               if   (temp_proc_flag <> 31 and temp_proc_flag <> 32
                 and temp_proc_flag <> 33 and temp_proc_flag <> 34
                 and temp_proc_flag <> 35) then
                        update MTL_SYSTEM_ITEMS_INTERFACE
                        set process_flag = DECODE(status,0,46,36),
                            PRIMARY_UOM_CODE = cr.primary_uom_code,
                            primary_unit_of_measure = cr.primary_unit_of_measure
                        where inventory_item_id = l_item_id
                        --and   set_process_id + 0 = xset_id -- fix for bug#8757041,removed + 0
                        and   set_process_id  = xset_id
                        and   process_flag = 45
                        and   organization_id = cr.organization_id;
               end if;

        end loop;

        return(0);

exception

        when LOGGING_ERR then
                return(dumm_status);
        when VALIDATE_ERR then
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
                return(status);

        when OTHERS then
                err_text := substr('INVPVALI.validate_item_header6' || SQLERRM , 1,240);
                return(SQLCODE);

END validate_item_header6;


end INVPVDR6;

/
