--------------------------------------------------------
--  DDL for Package Body INVPVDR7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPVDR7" AS
/* $Header: INVPVD7B.pls 120.15.12010000.5 2010/02/16 11:42:59 sandpand ship $ */

FUNCTION validate_item_header7
(
org_id		number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text      IN OUT  NOCOPY VARCHAR2,
xset_id       IN      NUMBER     DEFAULT -999
)
RETURN INTEGER
IS
   l_col_name      VARCHAR2(30);
   l_msg_name      VARCHAR2(30);

        /*
	** Retrieve column values for validation
	*/
	CURSOR cc is
	select intf.ROWID, intf.*
	from MTL_SYSTEM_ITEMS_INTERFACE intf
	where ((organization_id = org_id) or -- fix for bug#8757041,removed + 0
	       (all_Org = 1))
        and   set_process_id  = xset_id
	and   process_flag in (31, 32, 33, 34, 35, 36, 46);

	CURSOR c_org_loc_control(cp_org_id number) IS
	   SELECT stock_locator_control_code,
             primary_cost_method,
	          NVL(wms_enabled_flag,'N'),
             NVL(process_enabled_flag,'N'),
             NVL(eam_enabled_flag,'N'),
		       NVL(trading_partner_org_flag,'N')
	   FROM   mtl_parameters
	   where  organization_id = cp_org_id;

	CURSOR c_subinv_loc_control(cp_org_id      number,
	                            cp_subinv_name varchar2) IS
	   SELECT locator_type
	   FROM   mtl_secondary_inventories
	   WHERE  secondary_inventory_name = cp_subinv_name
           AND    organization_id          = cp_org_id
           AND    SYSDATE < nvl(disable_date, SYSDATE+1);

	l_org_loc_ctrl              NUMBER;
	l_subinv_loc_ctrl           NUMBER;
	l_loc_mandatory             BOOLEAN := FALSE;

        l_process_subinv_error      BOOLEAN := FALSE;
	l_process_locator_error     BOOLEAN := FALSE;
	l_message_name              VARCHAR2(30):= NULL;
        l_msg_text              fnd_new_messages.message_text%TYPE;

	l_item_id		NUMBER;
	l_org_id		NUMBER;
	trans_id		NUMBER;

	error_msg		VARCHAR2(240);-- Bug 5216657, increasing size
	status			NUMBER;
	dumm_status		NUMBER;
        stmt                    NUMBER;
        LOGGING_ERR             EXCEPTION;
        VALIDATE_ERR            EXCEPTION;
        lot_num_generation_val  NUMBER;
        l_temp			VARCHAR2(10);
        l_child_lot_starting_number pls_integer;
	l_trading_partner_org   VARCHAR2(1);
	l_process_enabled       VARCHAR2(1);
	l_wms_enabled           VARCHAR2(1);
	l_eam_enabled           VARCHAR2(1);
	l_cost_method           NUMBER;
        l_process_flag_2        number := 2 ;
        l_process_flag_3        number := 3 ;
        l_process_flag_4        number := 4 ;
        temp_proc_flag          number;
        reqst_id	       NUMBER ;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
	l_charge_periodicity_class VARCHAR2(10);
	l_SHIKYU_profile           VARCHAR2(1);

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPVDR7.validate_item_header7: begin');
   END IF;

  -- Retrieving fnd_profile values outside the loop for perf reasons.
  l_charge_periodicity_class := FND_PROFILE.VALUE('ONT_UOM_CLASS_CHARGE_PERIODICITY');
  l_SHIKYU_profile :=  fnd_profile.value('JMF_SHK_CHARGE_BASED_ENABLED');

  reqst_id := request_id ;
   -- Validate the records

   FOR cr IN cc LOOP

      status := 0;

      trans_id := cr.transaction_id;
      l_org_id := cr.organization_id;
      l_item_id := cr.inventory_item_id;  --Bug: 4705184
      temp_proc_flag := cr.process_flag; -- Bug 4705184

      /* Bug 4705184
      select inventory_item_id
      into l_item_id
      from mtl_system_items_interface
      where transaction_id = cr.transaction_id
      and   set_process_id = xset_id; */

      open  c_org_loc_control(cr.organization_id);
      fetch c_org_loc_control INTO l_org_loc_ctrl,l_cost_method,l_wms_enabled,l_process_enabled,
                                   l_eam_enabled,l_trading_partner_org;
      close c_org_loc_control;

      /*Validate following attributes in this file*/
      /*LOT_DIVISIBLE_FLAG
        GRADE_CONTROL_FLAG
        DEFAULT_GRADE
        CHILD_LOT_FLAG
        PARENT_CHILD_GENERATION_FLAG
        CHILD_LOT_PREFIX
        CHILD_LOT_STARTING_NUMBER
      	CHILD_LOT_VALIDATION_FLAG
        COPY_LOT_ATTRIBUTE_FLAG
        RECIPE_ENABLED_FLAG
        PROCESS_QUALITY_ENABLED_FLAG
        PROCESS_EXECUTION_ENABLED_FLAG
        PROCESS_COSTING_ENABLED_FLAG
        PROCESS_SUPPLY_SUBINVENTORY
        PROCESS_SUPPLY_LOCATOR_ID
        PROCESS_YIELD_SUBINVENTORY
        PROCESS_YIELD_LOCATOR_ID
        HAZARDOUS_MATERIAL_FLAG
        CAS_NUMBER
      	RETEST_INTERVAL
        EXPIRATION_ACTION_INTERVAL
        EXPIRATION_ACTION_CODE
      	MATURITY_DAYS
        HOLD_DAYS
       */



        --Item can be Lot In/Divisible only if Lot Control is Full Controlled
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying lot divisible flag.... LOT_DIVISIBLE_FLAG');
        END IF;

        IF (  cr.LOT_DIVISIBLE_FLAG IS NOT NULL
		   AND cr.LOT_DIVISIBLE_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'LOT_DIVISIBLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;
                status := 1;
        END IF;-- LOT_DIVISIBLE_FLAG is not null AND <> 'N','Y'

        if (cr.LOT_CONTROL_CODE <> 2 and NVL(cr.LOT_DIVISIBLE_FLAG,'N') = 'Y') then

           dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'LOT_DIVISIBLE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_LOT_DIVISIBLE',
				err_text);
           if dumm_status < 0 then
              raise LOGGING_ERR;
           end if;
           status := 1;
        end if;

        --Item can be Grade Controlled only if Lot Control is Full Controlled
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying grade control flag GRADE_CONTROL_FLAG....');
        END IF;
        IF (  cr.GRADE_CONTROL_FLAG IS NOT NULL
		   AND cr.GRADE_CONTROL_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'GRADE_CONTROL_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- GRADE_CONTROL_FLAG is not null AND <> 'N','Y'

        if (cr.LOT_CONTROL_CODE <> 2 and NVL(cr.GRADE_CONTROL_FLAG,'N') = 'Y') then

           dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'GRADE_CONTROL_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_GRADE_CONTROL',
				err_text);
           if dumm_status < 0 then
              raise LOGGING_ERR;
           end if;

           status := 1;
        end if;

        --Item can have Default Grade specified only if Lot Control is Full Controlled
        --and item is grade controlled.
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying Default Grade....');
        END IF;
        if (cr.DEFAULT_GRADE IS NOT NULL) then
           if (cr.LOT_CONTROL_CODE <> 2 or NVL(cr.GRADE_CONTROL_FLAG,'N') <> 'Y') then

              dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'DEFAULT_GRADE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_DEFAULT_GRADE_NULL',
				err_text);
              if dumm_status < 0 then
                 raise LOGGING_ERR;
              end if;

              status := 1;

           elsif (cr.LOT_CONTROL_CODE = 2 or NVL(cr.GRADE_CONTROL_FLAG,'N') = 'Y') then
              begin
                 select 'x' into l_temp
                 from   MTL_GRADES_B
                 where  GRADE_CODE = cr.DEFAULT_GRADE
                 and    nvl(DISABLE_FLAG,'N') <> 'Y';

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
                    'DEFAULT_GRADE',
                    'MTL_SYSTEM_ITEMS_INTERFACE',
                    'INV_INVALID_DEFAULT_GRADE',
                    err_text);

                 if dumm_status < 0 then
                    raise LOGGING_ERR;
                 end if;

                 status := 1;
              end;
           end if;
        else /*if cr.DEFAULT_GRADE IS NULL) then*/
        --if item is grade controlled and has no default grade then log error.
           if (cr.LOT_CONTROL_CODE = 2 and NVL(cr.GRADE_CONTROL_FLAG,'N') = 'Y') then
              dumm_status := INVPUOPI.mtl_log_interface_err(
                    cr.organization_id,
                    user_id,
                    login_id,
                    prog_appid,
                    prog_id,
                    request_id,
                    cr.TRANSACTION_ID,
                    error_msg,
                    'DEFAULT_GRADE',
                    'MTL_SYSTEM_ITEMS_INTERFACE',
                    'INV_INVALID_DEFAULT_GRADE',
                    err_text);

              if dumm_status < 0 then
                 raise LOGGING_ERR;
              end if;

              status := 1;
           end if;
        end if;


        --validate CHILD_LOT_FLAG
        --Item can be CHILD_LOT_FLAG enabled only if its lot controlled.
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying child lot flag....');
        END IF;
        IF (  cr.CHILD_LOT_FLAG IS NOT NULL
		   AND cr.CHILD_LOT_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CHILD_LOT_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- CHILD_LOT_FLAG is not null AND <> 'N','Y'

        if (cr.LOT_CONTROL_CODE <> 2 and NVL(cr.CHILD_LOT_FLAG,'N') = 'Y') then

           dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CHILD_LOT_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_CHILD_LOT_FLAG',
				err_text);
           if dumm_status < 0 then
              raise LOGGING_ERR;
           end if;

           status := 1;
        end if;

        --validate PARENT_CHILD_GENERATION_FLAG
        --Check the lookup and it can be not null only if item is child lot enabled and lot controlled.
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying parent child generation flag....');
        END IF;
        lot_num_generation_val := NULL;
        select lot_number_generation
        into   lot_num_generation_val
        from   mtl_parameters
        where  organization_id = cr.organization_id
        and rownum =1;

        if (cr.PARENT_CHILD_GENERATION_FLAG IS NOT NULL) then
           l_col_name := 'PARENT_CHILD_GENERATION_FLAG';
           l_msg_name := 'INV_INVALID_ATTR_COL_VALUE';

           begin
              select 'x' into l_temp
              from   FND_LOOKUP_VALUES_VL
              where  LOOKUP_TYPE = 'INV_PARENT_CHILD_GENERATION'
                and  LOOKUP_CODE = cr.PARENT_CHILD_GENERATION_FLAG
                and  SYSDATE between
                     NVL(start_date_active, SYSDATE) and NVL(end_date_active, SYSDATE)
                and  ENABLED_FLAG = 'Y';

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
				'PARENT_CHILD_GENERATION_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                l_msg_name,
				err_text);
                 if dumm_status < 0 then
                    raise LOGGING_ERR;
                  end if;

                 status := 1;
              end;
         else
           if (cr.LOT_CONTROL_CODE = 2 and NVL(cr.CHILD_LOT_FLAG,'N') = 'Y' and lot_num_generation_val = 2) then

              dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PARENT_CHILD_GENERATION_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_PARENT_CHILD_FLAG',
				err_text);
              if dumm_status < 0 then
                 raise LOGGING_ERR;
              end if;

              status := 1;
           end if;
        end if;

	--validate CHILD_LOT_STARTING_NUMBER
	--if CHILD_LOT_STARTING_NUMBER is not null it should be a number and
	--if item is child lot enabled and lot numer generation is at item level then
	--CHILD_LOT_STARTING_NUMBER has to be not null
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying child lot starting number....');
        END IF;

        if (cr.CHILD_LOT_STARTING_NUMBER IS NOT NULL) then
           if (cr.CHILD_LOT_STARTING_NUMBER < 0) THEN
             dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CHILD_LOT_STARTING_NUMBER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_CHILD_LOT_START_NO',
		                err_text);
             if dumm_status < 0 then
               raise LOGGING_ERR;
             end if;
             status := 1;
           end if;

	   begin
	      SELECT TO_CHAR(TO_NUMBER(cr.CHILD_LOT_STARTING_NUMBER))
	      INTO   l_child_lot_starting_number
	      FROM DUAL;

	      if l_child_lot_starting_number <> cr.CHILD_LOT_STARTING_NUMBER then
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CHILD_LOT_STARTING_NUMBER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_CHILD_LOT_START_NO',
		                err_text);
                if dumm_status < 0 then
                  raise LOGGING_ERR;
                end if;
                status := 1;
	      end if;

	      exception
	      when others then
              --check to see that the child lot start number is an integer.
                 dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CHILD_LOT_STARTING_NUMBER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_CHILD_LOT_START_NO',
				err_text);
                 if dumm_status < 0 then
                    raise LOGGING_ERR;
                 end if;
                 status := 1;
           end;
        elsif cr.CHILD_LOT_STARTING_NUMBER IS NULL then
           if cr.lot_control_code = 2 and
              lot_num_generation_val = 2 and
              nvl(cr.child_lot_flag,'N') = 'Y' then
	         dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'CHILD_LOT_STARTING_NUMBER',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_CHILD_LOT_START_NO',
		                err_text);
                 if dumm_status < 0 then
                    raise LOGGING_ERR;
                 end if;
                 status := 1;
           end if;
        end if;

	--validate CHILD_LOT_VALIDATION_FLAG
	--Item can have child lot validation flag ON only if it is child lot enabled
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying child lot validate flag....');
        END IF;
        IF (  cr.CHILD_LOT_VALIDATION_FLAG IS NOT NULL
		   AND cr.CHILD_LOT_VALIDATION_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'CHILD_LOT_VALIDATION_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- CHILD_LOT_VALIDATION_FLAG is not null AND <> 'N','Y'

        --validate COPY_LOT_ATTRIBUTE_FLAG
        --Item can have child lot validation flag ON only if it is child lot enabled
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying copy lot attribute flag....');
        END IF;

        IF (  cr.COPY_LOT_ATTRIBUTE_FLAG IS NOT NULL
		   AND cr.COPY_LOT_ATTRIBUTE_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'COPY_LOT_ATTRIBUTE_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- COPY_LOT_ATTRIBUTE_FLAG is not null AND <> 'N','Y'

        --validate RECIPE_ENABLED_FLAG
        IF (  cr.RECIPE_ENABLED_FLAG IS NOT NULL
		   AND cr.RECIPE_ENABLED_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'RECIPE_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- RECIPE_ENABLED_FLAG is not null AND <> 'N','Y'

        --validate PROCESS_EXECUTION_ENABLED_FLAG
        IF (  cr.PROCESS_EXECUTION_ENABLED_FLAG IS NOT NULL
		   AND cr.PROCESS_EXECUTION_ENABLED_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PROCESS_EXECUTION_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- PROCESS_EXECUTION_ENABLED_FLAG is not null AND <> 'N','Y'

	--Added for bug 5300040
	--Process execution must be No if either of inventory item or reciped enabled flags are No
        IF (  cr.PROCESS_EXECUTION_ENABLED_FLAG = 'Y' AND
		   (cr.INVENTORY_ITEM_FLAG ='N' OR cr.RECIPE_ENABLED_FLAG ='N' ))THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PROCESS_EXECUTION_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_PR_EXEC_NOT_ALLOWED',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- PROCESS_EXECUTION_ENABLED_FLAG cannot be 'Y' if inventory or recipe enabled flag is 'N'


        --validate PROCESS_COSTING_ENABLED_FLAG
        IF (  cr.PROCESS_COSTING_ENABLED_FLAG IS NOT NULL
		   AND cr.PROCESS_COSTING_ENABLED_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PROCESS_COSTING_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- PROCESS_COSTING_ENABLED_FLAG is not null AND <> 'N','Y'

        --validate PROCESS_QUALITY_ENABLED_FLAG
        IF (  cr.PROCESS_QUALITY_ENABLED_FLAG IS NOT NULL
		   AND cr.PROCESS_QUALITY_ENABLED_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'PROCESS_QUALITY_ENABLED_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- PROCESS_QUALITY_ENABLED_FLAG is not null AND <> 'N','Y'

        --validate PROCESS_SUPPLY_SUBINVENTORY
        --validate foreign keys
        IF l_inv_debug_level IN(101, 102) THEN
           INVPUTLI.info('INVPVDR7: verifying process supply subinventory....');
        END IF;

        if (cr.PROCESS_SUPPLY_SUBINVENTORY IS NOT NULL ) then

            l_process_subinv_error := FALSE;

            if cr.RESTRICT_SUBINVENTORIES_CODE = 1    AND cr.TRANSACTION_TYPE ='CREATE' then
               l_process_subinv_error := TRUE;
               l_message_name     := 'INV_IOI_PROCESS_SUP_SUB';
	    elsif cr.RESTRICT_SUBINVENTORIES_CODE = 1 AND cr.TRANSACTION_TYPE ='UPDATE' then
               begin
                  select 'x' INTO l_temp
                    from  MTL_ITEM_SUB_INVENTORIES i
                   where  i.inventory_item_id   = cr.inventory_item_id
                     and  i.ORGANIZATION_ID     = cr.ORGANIZATION_ID
                     and  i.SECONDARY_INVENTORY = cr.PROCESS_SUPPLY_SUBINVENTORY;

                  exception
                  when no_data_found then
                     l_process_subinv_error := TRUE;
                     l_message_name     := 'INV_INT_RESSUBEXP';
               end;
            elsif NVL(cr.RESTRICT_SUBINVENTORIES_CODE,2) = 2 then
               begin
                  select 'x' INTO l_temp
                    from  MTL_SECONDARY_INVENTORIES
                   where  SECONDARY_INVENTORY_NAME = cr.PROCESS_SUPPLY_SUBINVENTORY
                     and  ORGANIZATION_ID        = cr.ORGANIZATION_ID
                     and  SYSDATE < nvl(DISABLE_DATE, SYSDATE+1);

                  exception
                  when no_data_found then
                     l_process_subinv_error := TRUE;
                     l_message_name     := 'INV_IOI_PROCESS_SUP_SUB';
               end;
            end if;

            if l_process_subinv_error then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PROCESS_SUPPLY_SUBINVENTORY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                l_message_name,
				err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
            end if;
         end if;

         --validate PROCESS_SUPPLY_LOCATOR_ID
        IF l_inv_debug_level IN(101, 102) THEN
	   INVPUTLI.info('INVPVDR7: verifying process supply locator id....');
        END IF;

        --{
        if cr.PROCESS_SUPPLY_SUBINVENTORY IS NOT NULL then

            l_loc_mandatory := FALSE;

            if l_org_loc_ctrl IN (2,3) then
               l_loc_mandatory := TRUE;
            end if;

            if NOT l_loc_mandatory then

               open  c_subinv_loc_control(cr.organization_id,cr.process_supply_subinventory);
               fetch c_subinv_loc_control INTO l_subinv_loc_ctrl;
               close c_subinv_loc_control;

               if l_subinv_loc_ctrl NOT IN (1,5) then
                  l_loc_mandatory := TRUE;
               end if;
            end if;

            if NOT l_loc_mandatory
               and cr.LOCATION_CONTROL_CODE <> 1 then
               l_loc_mandatory := TRUE;
            end if;
            --{
            if l_loc_mandatory
               AND cr.PROCESS_SUPPLY_LOCATOR_ID IS NULL then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PROCESS_SUPPLY_LOCATOR_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PROCESS_SUP_LOC_ID',
				err_text);
               if dumm_status < 0 THEN
                  raise LOGGING_ERR;
               end if;

               status := 1;
            end if;--}

         end if;--}

         -- validate foreign keys
         --{
         if  cr.PROCESS_SUPPLY_LOCATOR_ID IS NOT NULL then

            l_process_locator_error := FALSE;

            --if (nvl(cr.PROCESS_EXECUTION_ENABLED_FLAG,'N') = 'N') then
            --   l_process_subinv_error := TRUE;
            --   l_message_name     := 'INV_IOI_PROCESS_SUP_LOC_ID';
            --end if;

            if cr.RESTRICT_LOCATORS_CODE = 1 and cr.TRANSACTION_TYPE ='CREATE' then
               l_process_locator_error := TRUE;
            elsif cr.RESTRICT_LOCATORS_CODE = 1 AND cr.TRANSACTION_TYPE ='UPDATE' then
               BEGIN
                  select 'x' INTO l_temp
                  from   MTL_SECONDARY_LOCATORS
                  where  INVENTORY_ITEM_ID     = cr.INVENTORY_ITEM_ID
                  and    ORGANIZATION_ID       = cr.ORGANIZATION_ID
                  and    SECONDARY_LOCATOR     = cr.PROCESS_SUPPLY_LOCATOR_ID
                  and    SUBINVENTORY_CODE     = cr.PROCESS_SUPPLY_SUBINVENTORY;

                  exception
                  when NO_DATA_FOUND then
                     l_process_locator_error := TRUE;
                  end;
            elsif NVL(cr.RESTRICT_LOCATORS_CODE,2) = 2 THEN
               begin
                  select 'x' INTO l_temp
                  from   MTL_ITEM_LOCATIONS
                  where  INVENTORY_LOCATION_ID = cr.PROCESS_SUPPLY_LOCATOR_ID
                  and    SUBINVENTORY_CODE     = cr.PROCESS_SUPPLY_SUBINVENTORY
                  and    ORGANIZATION_ID       = cr.ORGANIZATION_ID
                  and    SYSDATE < nvl(DISABLE_DATE, SYSDATE+1); /*NP 16OCT94*/

                  exception
                  when NO_DATA_FOUND then
                     l_process_locator_error := TRUE;
               end;
            end if;

            if l_process_locator_error then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PROCESS_SUPPLY_LOCATOR_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PROCESS_SUP_LOC_ID',
				err_text);
                                if dumm_status < 0 then
                                   raise LOGGING_ERR;
                                end if;
                                status := 1;
            end if;
         end if; --}


         --validate PROCESS_YIELD_SUBINVENTORY
         --validate foreign keys
         IF l_inv_debug_level IN(101, 102) THEN
            INVPUTLI.info('INVPVDR7: verifying process yield subinventory....');
         END IF;

         if (cr.PROCESS_YIELD_SUBINVENTORY IS NOT NULL ) then

            l_process_subinv_error := FALSE;

            --if (nvl(cr.PROCESS_EXECUTION_ENABLED_FLAG,'N') = 'N') then
            --   l_process_subinv_error := TRUE;
            --   l_message_name     := 'INV_IOI_PROCESS_YIELD_SUB';
            --end if;

            if cr.RESTRICT_SUBINVENTORIES_CODE = 1    AND cr.TRANSACTION_TYPE ='CREATE' then
               l_process_subinv_error := TRUE;
               l_message_name     := 'INV_IOI_PROCESS_YIELD_SUB';
	    elsif cr.RESTRICT_SUBINVENTORIES_CODE = 1 AND cr.TRANSACTION_TYPE ='UPDATE' then
               begin
                  select 'x' INTO l_temp
                    from  MTL_ITEM_SUB_INVENTORIES i
                   where  i.inventory_item_id   = cr.inventory_item_id
                     and  i.ORGANIZATION_ID     = cr.ORGANIZATION_ID
                     and  i.SECONDARY_INVENTORY = cr.PROCESS_YIELD_SUBINVENTORY;

                  exception
                  when no_data_found then
                     l_process_subinv_error := TRUE;
                     l_message_name     := 'INV_INT_RESSUBEXP';
               end;
            elsif NVL(cr.RESTRICT_SUBINVENTORIES_CODE,2) = 2 then
               begin
                  select 'x' INTO l_temp
                    from  MTL_SECONDARY_INVENTORIES
                   where SECONDARY_INVENTORY_NAME = cr.PROCESS_YIELD_SUBINVENTORY
                     and   ORGANIZATION_ID        = cr.ORGANIZATION_ID
                     and  SYSDATE < nvl(DISABLE_DATE, SYSDATE+1);

                  exception
                  when no_data_found then
                     l_process_subinv_error := TRUE;
                     l_message_name     := 'INV_IOI_PROCESS_YIELD_SUB';
               end;
            end if;

            if l_process_subinv_error then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PROCESS_YIELD_SUBINVENTORY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                l_message_name,
				err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
            end if;
         end if;

         --validate PROCESS_YIELD_LOCATOR_ID
         IF l_inv_debug_level IN(101, 102) THEN
	    INVPUTLI.info('INVPVDR7: verifying process yield locator....');
         END IF;

	 if cr.PROCESS_YIELD_SUBINVENTORY IS NOT NULL then

            l_loc_mandatory := FALSE;

            if l_org_loc_ctrl IN (2,3) then
               l_loc_mandatory := TRUE;
            end if;

            if NOT l_loc_mandatory then

               open  c_subinv_loc_control(cr.organization_id,cr.process_yield_subinventory);
               fetch c_subinv_loc_control INTO l_subinv_loc_ctrl;
               close c_subinv_loc_control;

               if l_subinv_loc_ctrl NOT IN (1,5) then
                  l_loc_mandatory := TRUE;
               end if;
            end if;

            if NOT l_loc_mandatory
               and cr.LOCATION_CONTROL_CODE <> 1 then
               l_loc_mandatory := TRUE;
            end if;

            if l_loc_mandatory
               AND cr.PROCESS_YIELD_LOCATOR_ID IS NULL then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PROCESS_YIELD_LOCATOR_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PROCESS_YLD_LOC_ID',
				err_text);
               if dumm_status < 0 THEN
                  raise LOGGING_ERR;
               end if;

               status := 1;
            end if;

         end if;

         -- validate foreign keys
         if  cr.PROCESS_YIELD_LOCATOR_ID IS NOT NULL then

            l_process_locator_error := FALSE;

            if cr.RESTRICT_LOCATORS_CODE = 1 and cr.TRANSACTION_TYPE ='CREATE' then
               l_process_locator_error := TRUE;
            elsif cr.RESTRICT_LOCATORS_CODE = 1 AND cr.TRANSACTION_TYPE ='UPDATE' then
               BEGIN
                  select 'x' INTO l_temp
                  from   MTL_SECONDARY_LOCATORS
                  where  INVENTORY_ITEM_ID     = cr.INVENTORY_ITEM_ID
                  and    ORGANIZATION_ID       = cr.ORGANIZATION_ID
                  and    SECONDARY_LOCATOR     = cr.PROCESS_YIELD_LOCATOR_ID
                  and    SUBINVENTORY_CODE     = cr.PROCESS_YIELD_SUBINVENTORY;

                  exception
                  when NO_DATA_FOUND then
                     l_process_locator_error := TRUE;
                  end;
            elsif NVL(cr.RESTRICT_LOCATORS_CODE,2) = 2 THEN
               begin
                  select 'x' INTO l_temp
                  from   MTL_ITEM_LOCATIONS
                  where  INVENTORY_LOCATION_ID = cr.PROCESS_YIELD_LOCATOR_ID
                  and    SUBINVENTORY_CODE     = cr.PROCESS_YIELD_SUBINVENTORY
                  and    ORGANIZATION_ID       = cr.ORGANIZATION_ID
                  and    SYSDATE < nvl(DISABLE_DATE, SYSDATE+1); /*NP 16OCT94*/

                  exception
                  when NO_DATA_FOUND then
                     l_process_locator_error := TRUE;
               end;
            end if;

            if l_process_locator_error then
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
				'PROCESS_YIELD_LOCATOR_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_PROCESS_YLD_LOC_ID',
				err_text);
                                if dumm_status < 0 then
                                   raise LOGGING_ERR;
                                end if;
                                status := 1;
            end if;
         end if;

         --validate EXPIRATION_ACTION_CODE
         IF l_inv_debug_level IN(101, 102) THEN
	    INVPUTLI.info('INVPVDR7: verifying expiration action code....');
         END IF;
         if (cr.EXPIRATION_ACTION_CODE is NOT NULL) then
            begin
                  select 'x' into l_temp
                    from mtl_actions_b
                   where action_code = cr.EXPIRATION_ACTION_CODE
                     and disable_flag= 'N';

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
			 'EXPIRATION_ACTION_CODE',
                         'MTL_SYSTEM_ITEMS_INTERFACE',
                         'INV_INVALID_EXPRTN_ACTN_CODE',
         		 err_text);

                     if dumm_status < 0 then
                        raise LOGGING_ERR;
                     end if;
                     status := 1;
            end;
         end if;

         --validate RETEST_INTERVAL
         --it should be greater than zero
         IF l_inv_debug_level IN(101, 102) THEN
	    INVPUTLI.info('INVPVDR7: verifying retest interval....');
         END IF;
         if (cr.RETEST_INTERVAL is NOT NULL) then
            if (cr.RETEST_INTERVAL < 0 OR cr.RETEST_INTERVAL > 999999) then

               dumm_status := INVPUOPI.mtl_log_interface_err(
                         cr.organization_id,
                         user_id,
                         login_id,
                         prog_appid,
                         prog_id,
		         request_id,
                         cr.TRANSACTION_ID,
                         error_msg,
			 'RETEST_INTERVAL',
                         'MTL_SYSTEM_ITEMS_INTERFACE',
                         'INV_INVALID_RETEST_INTERVAL',
         		 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
            end if;
         end if;

         --validate EXPIRATION ACTION INTERVAL
         --it should be greater than or equal to -999999 and less than or equal to 999999
         IF l_inv_debug_level IN(101, 102) THEN
	    INVPUTLI.info('INVPVDR7: verifying expiration action interval....');
         END IF;
         if (cr.EXPIRATION_ACTION_INTERVAL is NOT NULL) then
            if (cr.EXPIRATION_ACTION_INTERVAL < -999999 OR cr.EXPIRATION_ACTION_INTERVAL > 999999) then

               dumm_status := INVPUOPI.mtl_log_interface_err(
                         cr.organization_id,
                         user_id,
                         login_id,
                         prog_appid,
                         prog_id,
		         request_id,
                         cr.TRANSACTION_ID,
                         error_msg,
			 'EXPIRATION_ACTION_INTERVAL',
                         'MTL_SYSTEM_ITEMS_INTERFACE',
                         'INV_INVALID_EXPRTN_ACTN_INTRVL',
         		 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
            end if;
         end if;


         --validate MATURITY_DAYS
         --it should be greater than zero
         IF l_inv_debug_level IN(101, 102) THEN
 	    INVPUTLI.info('INVPVDR7: verifying maturity days....');
         END IF;
         if (cr.MATURITY_DAYS is NOT NULL) then
            if (cr.MATURITY_DAYS < 0 OR cr.MATURITY_DAYS > 999999) then

               dumm_status := INVPUOPI.mtl_log_interface_err(
                         cr.organization_id,
                         user_id,
                         login_id,
                         prog_appid,
                         prog_id,
		         request_id,
                         cr.TRANSACTION_ID,
                         error_msg,
			 'MATURITY_DAYS',
                         'MTL_SYSTEM_ITEMS_INTERFACE',
                         'INV_INVALID_MATURITY_DAYS',
         		 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
            end if;
         end if;

         --validate HOLD_DAYS
         --it should be greater than zero
         IF l_inv_debug_level IN(101, 102) THEN
	    INVPUTLI.info('INVPVDR7: verifying hold days....');
         END IF;

         if (cr.HOLD_DAYS is NOT NULL) then
            if (cr.HOLD_DAYS < 0 OR cr.HOLD_DAYS > 999999) then

               dumm_status := INVPUOPI.mtl_log_interface_err(
                         cr.organization_id,
                         user_id,
                         login_id,
                         prog_appid,
                         prog_id,
		         request_id,
                         cr.TRANSACTION_ID,
                         error_msg,
			 'HOLD_DAYS',
                         'MTL_SYSTEM_ITEMS_INTERFACE',
                         'INV_INVALID_HOLD_DAYS',
         		 err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
               status := 1;
            end if;
         end if;

         IF l_inv_debug_level IN(101, 102) THEN
	    INVPUTLI.info('INVPVDR7: verifying hazardous material flag....');
         END IF;

        IF (  cr.HAZARDOUS_MATERIAL_FLAG IS NOT NULL
		   AND cr.HAZARDOUS_MATERIAL_FLAG NOT IN ( 'Y','N')  )THEN
                dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.TRANSACTION_ID,
                                error_msg,
                                'HAZARDOUS_MATERIAL_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_FLAG_Y_N_NULL',
                                err_text );
                IF dumm_status < 0 THEN
                 raise LOGGING_ERR;
                END IF;

                status := 1;
        END IF;-- HAZARDOUS_MATERIAL_FLAG is not null AND <> 'N','Y'

	/* R12 Enhancement : Validations added for the new attributes */
        IF l_inv_debug_level IN(101, 102) THEN
	   INVPUTLI.info('INVPVDR7: verifying charge periodicity code....');
        END IF;

	IF cr.CHARGE_PERIODICITY_CODE IS NOT NULL THEN
          BEGIN
               SELECT 'x' INTO l_temp
               FROM MTL_UOM_CONVERSIONS
               WHERE UOM_CLASS = l_charge_periodicity_class
                 AND UOM_CODE = cr.CHARGE_PERIODICITY_CODE;

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
                                'CHARGE_PERIODICITY_CODE',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_INVALID_CHARGE_CODE',
                                 err_text );

                  IF dumm_status < 0 THEN
                         RAISE LOGGING_ERR;
                  END IF;
                  STATUS := 1;
	   END;
         END IF;
         IF l_inv_debug_level IN(101, 102) THEN
	    INVPUTLI.info('INVPVDR7: verifying repair leadtime....');
         END IF;
         IF cr.REPAIR_LEADTIME IS NOT NULL
              AND cr.REPAIR_LEADTIME < 0 THEN
	         dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'REPAIR_LEADTIME',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                 err_text );
                 IF dumm_status < 0 THEN
                       RAISE LOGGING_ERR;
                 END IF;
                 STATUS := 1;
          END IF;
          IF l_inv_debug_level IN(101, 102) THEN
	     INVPUTLI.info('INVPVDR7: verifying repair yield....');
          END IF;
          IF cr.REPAIR_YIELD IS NOT NULL
 --Bug 4473603 AND cr.REPAIR_YIELD > 100 AND cr.REPAIR_YIELD < 0 THEN
               AND (cr.REPAIR_YIELD > 100 OR cr.REPAIR_YIELD < 0 )THEN
            --Bug 5216657  start
                 FND_MESSAGE.SET_NAME('INV','INV_REPAIR_YIELD_COL_NAME');
                 error_msg := FND_MESSAGE.GET;
                 FND_MESSAGE.SET_NAME('INV','INV_IOI_INVALID_PERCENT_VALUE');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE', error_msg);
                 error_msg := FND_MESSAGE.GET;
             --Bug 5216657 end

	         dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'REPAIR_YIELD',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ERR',--Bug 5216657
                                 err_text );
                 IF dumm_status < 0 THEN
                       RAISE LOGGING_ERR;
                 END IF;
                 STATUS := 1;
           END IF;
           IF l_inv_debug_level IN(101, 102) THEN
	      INVPUTLI.info('INVPVDR7: verifying preposition point....');
           END IF;

          IF cr.PREPOSITION_POINT NOT IN ('Y','N') THEN
	           dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'PREPOSITION_POINT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                 err_text );
                    IF dumm_status < 0 THEN
                           RAISE LOGGING_ERR;
                    END IF;
                    STATUS := 1;
             END IF;
             IF l_inv_debug_level IN(101, 102) THEN
	        INVPUTLI.info('INVPVDR7: verifying repair program....');
             END IF;

	     IF cr.REPAIR_PROGRAM NOT IN (1,2,3) THEN
	              dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'REPAIR_PROGRAM',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                 err_text );
                      IF dumm_status < 0 THEN
                            RAISE LOGGING_ERR;
                      END IF;
                      STATUS := 1;
              END IF;

              IF l_inv_debug_level IN(101, 102) THEN
                 INVPUTLI.info('INVPVDR7: verifying subcontracting component....');
              END IF;

	      IF cr.SUBCONTRACTING_COMPONENT IS NOT NULL AND
	         cr.SUBCONTRACTING_COMPONENT NOT IN (1,2) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'SUBCONTRACTING_COMPONENT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                 err_text );
                         IF dumm_status < 0 THEN
                                   RAISE LOGGING_ERR;
                         END IF;
                         STATUS := 1;
                END IF;
                IF l_inv_debug_level IN(101, 102) THEN
	           INVPUTLI.info('INVPVDR7: verifying outsourced assembly....');
                END IF;

                IF cr.OUTSOURCED_ASSEMBLY NOT IN (1,2) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'OUTSOURCED_ASSEMBLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_ATTR_COL_VALUE',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;
                 IF l_inv_debug_level IN(101, 102) THEN
		    INVPUTLI.info('INVPVDR7: verifying outsourced assembly,SHIKYU enabled....');
                 END IF;
		 IF ((NVL(l_SHIKYU_profile,'N') = 'N')  AND
		     cr.OUTSOURCED_ASSEMBLY = 1) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'OUTSOURCED_ASSEMBLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_OS_ASMBLY_NO_JMF_PROFILE',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;
                 IF l_inv_debug_level IN(101, 102) THEN
		    INVPUTLI.info('INVPVDR7: verifying outsourced assembly,Release time fence....');
                 END IF;

		 IF (NVL(cr.RELEASE_TIME_FENCE_CODE,6) <> 7 AND l_trading_partner_org = 'Y'
		     AND cr.OUTSOURCED_ASSEMBLY = 1) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'OUTSOURCED_ASSEMBLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_OS_ASMBLY_TP_TIME_FENSE',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;

                 IF l_inv_debug_level IN(101, 102) THEN
	            INVPUTLI.info('INVPVDR7: verifying outsourced assembly, organizations......');
                 END IF;

		 IF( NOT(l_wms_enabled = 'N' AND l_process_enabled = 'N' AND l_eam_enabled = 'N')AND
		         cr.OUTSOURCED_ASSEMBLY = 1) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'OUTSOURCED_ASSEMBLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_OS_ASMBLY_INVALID_ORG',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;

                 IF l_inv_debug_level IN(101, 102) THEN
		    INVPUTLI.info('INVPVDR7: verifying outsourced assembly.cost method....');
                 END IF;
--
-- Fix for bug#6447581
-- Outsourced Assembly and Costing Method validation is commented.
--
--		 IF(l_cost_method <> 1 AND cr.OUTSOURCED_ASSEMBLY = 1) THEN
--	                dumm_status := INVPUOPI.mtl_log_interface_err(
--                                 cr.organization_id,
--                                 user_id,
--                                 login_id,
--                                 prog_appid,
--                                 prog_id,
--                                 request_id,
--                                 cr.TRANSACTION_ID,
--                                 error_msg,
--                                'OUTSOURCED_ASSEMBLY',
--                                'MTL_SYSTEM_ITEMS_INTERFACE',
--                                'INV_OS_ASMBLY_STD_COST_ORG',
--                                 err_text );
--                       IF dumm_status < 0 THEN
--                               RAISE LOGGING_ERR;
--                       END IF;
--                       STATUS := 1;
--                 END IF;
--
                 IF l_inv_debug_level IN(101, 102) THEN
		    INVPUTLI.info('INVPVDR7: verifying outsourced assembly,bom item type....');
                 END IF;
		 IF( NOT(cr.BOM_ITEM_TYPE = 4 AND cr.EFFECTIVITY_CONTROL = 1)AND
		   (cr.OUTSOURCED_ASSEMBLY = 1)) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'OUTSOURCED_ASSEMBLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_OS_ASMBLY_INVALID_BOM_ATTR',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;

                 --Bug: 5139950
                 --Bom item type can be 5 (product family) only if inventory flag is Y
                 --and planning_make_buy_code is 1 (Make)
		 IF( cr.BOM_ITEM_TYPE = 5 and cr.INVENTORY_ITEM_FLAG <> 'Y') THEN
                     dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                                    cr.organization_id,
                                                                    user_id,
                                                                    login_id,
                                                                    prog_appid,
                                                                    prog_id,
                                                                    request_id,
                                                                    cr.transaction_id,
                                                                    error_msg,
                                                                   'INVENTORY_ITEM_FLAG',
                                                                   'MTL_SYSTEM_ITEMS_INTERFACE',
                                                                   'INV_BOM_ITEM_TYPE_PF_INV',
                                                                    err_text);
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
		 END IF;
                 --Bug: 5139950
                 --Bom item type can be 5 (product family) only if inventory flag is Y
                 --and planning_make_buy_code is 1 (Make)
		 IF (cr.BOM_ITEM_TYPE = 5 AND cr.INVENTORY_ITEM_FLAG = 'Y' AND cr.PLANNING_MAKE_BUY_CODE <> 1)THEN
                     dumm_status  := INVPUOPI.mtl_log_interface_err(
                                                                    cr.organization_id,
                                                                    user_id,
                                                                    login_id,
                                                                    prog_appid,
                                                                    prog_id,
                                                                    request_id,
                                                                    cr.transaction_id,
                                                                    error_msg,
                                                                   'PLANNING_MAKE_BUY_CODE',
                                                                   'MTL_SYSTEM_ITEMS_INTERFACE',
                                                                   'INV_PLANNING_MAKE_BUY_CODE',
                                                                    err_text);
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
		 END IF;

                 IF l_inv_debug_level IN(101, 102) THEN
		    INVPUTLI.info('INVPVDR7: verifying outsourced assembly,outside operation....');
                 END IF;

		 IF(cr.OUTSIDE_OPERATION_FLAG = 'Y' AND cr.OUTSOURCED_ASSEMBLY = 1)
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
                                'OUTSOURCED_ASSEMBLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_OS_ASMBLY_OUTSIDE_OPRN',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;

		 IF((/*cr.INTERNAL_ORDER_FLAG = 'Y' OR cr.INTERNAL_ORDER_ENABLED_FLAG = 'Y' OR*/ -- Bug 9246127
		     cr.PICK_COMPONENTS_FLAG ='Y' OR cr.REPLENISH_TO_ORDER_FLAG  =  'Y')AND
		     cr.OUTSOURCED_ASSEMBLY = 1) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'OUTSOURCED_ASSEMBLY',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_OS_ASMBLY_INVALID_OM_ATTR',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;
                 IF l_inv_debug_level IN(101, 102) THEN
	            INVPUTLI.info('INVPVDR7: verifying subcontracting component,SHIKYU....');
                 END IF;

		 IF((NVL(l_SHIKYU_profile,'N') = 'N') AND
		         cr.SUBCONTRACTING_COMPONENT IS NOT NULL)
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
                                'SUBCONTRACTING_COMPONENT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SUBCONTR_COMP_NO_JMF_PRFL',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;

                 IF l_inv_debug_level IN(101, 102) THEN
		    INVPUTLI.info('INVPVDR7: verifying subcontracting component organizations....');
                 END IF;
		 IF(NOT(l_wms_enabled = 'N' AND l_process_enabled = 'N' AND l_eam_enabled = 'N')AND
		   cr.SUBCONTRACTING_COMPONENT IS NOT NULL) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'SUBCONTRACTING_COMPONENT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_OS_ASMBLY_INVALID_ORG',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;

                 --Bug8687179
                 --commenting the following validation.
	         /*IF(l_cost_method <> 1 AND cr.SUBCONTRACTING_COMPONENT IS NOT NULL) THEN
	                dumm_status := INVPUOPI.mtl_log_interface_err(
                                 cr.organization_id,
                                 user_id,
                                 login_id,
                                 prog_appid,
                                 prog_id,
                                 request_id,
                                 cr.TRANSACTION_ID,
                                 error_msg,
                                'SUBCONTRACTING_COMPONENT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_SUBCONTR_COMP_STD_COST_ORG',
                                 err_text );
                       IF dumm_status < 0 THEN
                               RAISE LOGGING_ERR;
                       END IF;
                       STATUS := 1;
                 END IF;
                  */

        -------------------------------------------------------------------------
                /* New code to update process_flag.
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

         /* Bug 4705184
		select process_flag into temp_proc_flag
                  from MTL_SYSTEM_ITEMS_INTERFACE
                where inventory_item_id = l_item_id
                and   set_process_id + 0  = xset_id
                and   process_flag in (3,31,32,33,34,35,36,46) --3571136
                and   organization_id = cr.organization_id
                and   rownum < 2; */

                /* set value of process_flag to 4 or 3
                ** depending on value of the variable: status.
                ** NOTE: not 47, 37..this is the FINAL set of
                ** validations. All the values 31-35 and 41-45 were
                ** just temporary values.
                ** Essentially, we check to see if validation has not
                ** already failed in one of the previous packages.
                */

               if   (temp_proc_flag = 46 ) then
                        /*The validations are all clear up until this package*/

                        update MTL_SYSTEM_ITEMS_INTERFACE
                        set process_flag = DECODE(status,0,4,3),
                            PRIMARY_UOM_CODE = cr.primary_uom_code,
                            primary_unit_of_measure = cr.primary_unit_of_measure
                        where inventory_item_id = l_item_id
                        -- and   set_process_id  + 0 = xset_id -- fix for bug#8757041,removed + 0
                        and   set_process_id  = xset_id
                        and   process_flag = 46
                        and   organization_id = cr.organization_id;

                        update MTL_ITEM_CATEGORIES_INTERFACE
                        set    process_flag = DECODE(status,0,4,3)
                        where  process_flag = 4
                        and    set_process_id    = xset_id
                        and    inventory_item_id = l_item_id
                        and    organization_id = cr.organization_id;

               else
                        /*there is some validation problem somewhere: process
                        **flag is one of 31,32,33,34,35,36:
                        **Set it to 3 unconditionally*/

                        update MTL_SYSTEM_ITEMS_INTERFACE
                        set process_flag = 3,
                          PRIMARY_UOM_CODE = cr.primary_uom_code,
                          primary_unit_of_measure = cr.primary_unit_of_measure,
                          request_id = reqst_id,
                          program_application_id = nvl(program_application_id,prog_appid)
                          ,
                          PROGRAM_ID = nvl(PROGRAM_ID,prog_id),
                          PROGRAM_UPDATE_DATE = nvl(PROGRAM_UPDATE_DATE,sysdate),
                          LAST_UPDATE_DATE = nvl(LAST_UPDATE_DATE,sysdate),
                          LAST_UPDATED_BY = nvl(LAST_UPDATED_BY,user_id),
                          CREATION_DATE = nvl(CREATION_DATE,sysdate),
                          CREATED_BY = nvl(CREATED_BY,user_id),
                          LAST_UPDATE_LOGIN = nvl(LAST_UPDATE_LOGIN,login_id)
                        where inventory_item_id = l_item_id
                        -- and   set_process_id + 0 = xset_id -- fix for bug#8757041,removed + 0
                        and   set_process_id = xset_id
                        and   process_flag in (31,32,33,34,35,36)
                        and   organization_id = cr.organization_id;

                   /*NP 04/11/95 Also need to reset process_flag = 3 for child
                   **reset process_flag = 3 for table
                   **mtl_item_categories_interface
                   **and set process_flag = 3 for mtl_item_revisions_interface
                   ** for the relevant inventory_item_id
                   */
                       update MTL_ITEM_CATEGORIES_INTERFACE
                          set process_flag = l_process_flag_3,
                          request_id = reqst_id,
                          program_application_id = nvl(program_application_id,prog_appid)
                          ,
                          PROGRAM_ID = nvl(PROGRAM_ID,prog_id),
                          PROGRAM_UPDATE_DATE = nvl(PROGRAM_UPDATE_DATE,sysdate),
                          LAST_UPDATE_DATE = nvl(LAST_UPDATE_DATE,sysdate),
                          LAST_UPDATED_BY = nvl(LAST_UPDATED_BY,user_id),
                          CREATION_DATE = nvl(CREATION_DATE,sysdate),
                          CREATED_BY = nvl(CREATED_BY,user_id),
                          LAST_UPDATE_LOGIN = nvl(LAST_UPDATE_LOGIN,login_id)
                        where process_flag = l_process_flag_4
                          and set_process_id  = xset_id
                          and inventory_item_id = l_item_id
                          and organization_id = cr.organization_id;

           /*SETID: not setid related: what about revisions_interface here??*/

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
		err_text := substr('INVPVDR7.validate_item_header7' || SQLERRM, 1,240);
		return(SQLCODE);

end validate_item_header7;

end INVPVDR7;

/
