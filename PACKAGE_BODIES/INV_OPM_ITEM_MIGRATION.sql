--------------------------------------------------------
--  DDL for Package Body INV_OPM_ITEM_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_OPM_ITEM_MIGRATION" AS
/* $Header: INVGIMGB.pls 120.12.12010000.3 2008/11/17 20:58:41 adeshmuk ship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    INVGIMGB.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |   Public                                                                 |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    INV_OPM_Item_Migration                                                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the procedure used for item migration for OPM   |
 |    convergence project. These procedure are meant for migration only.    |
 |                                                                          |
 | Contents                                                                 |
 |    get_ODM_item                                                          |
 |    get_ODM_regulatory_item                                               |
 |    migrate_opm_items                                                     |
 |    migrate_obsolete_columns                                              |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 3/22/05                                    |
 |                                                                          |
 |    Jatinder - 11/30/06 - Use correct organization to lock migration      |
 |               records. 5690686.                                          |
 |    Jatinder - 11/30/06 - Move commit to the main procedure to avoid      |
 |               deadlocks. 5690686.                                        |
 |    Jatinder - 12/15/06 - Make OPM items with NULL or 0 shelf life days   |
 |               as user defined expiration control. Discrete item master   |
 |               doesn't allow shlef life expiration control for 0 shelf    |
 |               life days. 5730196                                         |
 |    Archana Mundhe - 11/14/08 - Bug 7166389                               |
 |               Migrate status_ctl flag,  status_id for status_ctl=2 items.|
 +==========================================================================+
*/

/*  Global variables */
g_item_id		NUMBER;
g_organization_id	NUMBER;
g_inventory_item_id	NUMBER;
g_inv_item_status_code  VARCHAR2(10);
g_auto_lot_alpha_prefix	VARCHAR2(30);
g_start_auto_lot_number	NUMBER;
g_child_lot_prefix	VARCHAR2(30);
g_child_lot_starting_number	NUMBER;

/*===========================================================================
--  PROCEDURE:
--   get_reg_item_info
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to build a record to simulate data
--    in ic_item_mst_b table.
--
--  PARAMETERS:
--    p_item_code       - Item_code to use to retrieve Regulatory item values
--    x_reg_item_rec    - Record in the format of ic_item_mst_b
--    x_return_status   - Returns the status of the function (success, failure, etc.)
--    x_msg_data        - Returns message data if an error occurred
--
--  SYNOPSIS:
--    get_reg_item_info(
--                           p_item_code        => l_item_code,
--                           x_reg_item_rec     => l_opm_item,
--                           x_return_status    => l_return_status,
--                           x_msg_data         => l_msg_data );
--
--  HISTORY
--   Melanie Grosser - 5/11/05
--=========================================================================== */
 PROCEDURE get_reg_item_info
  (
     p_item_code            IN          VARCHAR2,
     x_reg_item_rec         OUT NOCOPY  IC_ITEM_MST_B%ROWTYPE,
     x_return_status        OUT NOCOPY  VARCHAR2,
     x_msg_data             OUT NOCOPY  VARCHAR2
  ) IS

   /*  ------------- LOCAL VARIABLES ------------------- */
     l_description            VARCHAR2(240);
     l_um_type                sy_uoms_typ.um_type%TYPE;
     l_uom                    sy_uoms_typ.std_um%TYPE;

   /*  ------------------ CURSORS ---------------------- */
     /* Cursor used to retrieve the Regulatory item info*/
     CURSOR c_get_reg_item IS
       SELECT *
         FROM gr_item_general
        WHERE item_code = p_item_code;
     l_reg_rec    c_get_reg_item%ROWTYPE;

   /* Cursor used to retrieve the Regulatory item description*/
     CURSOR c_get_description IS
           SELECT name_description
             FROM gr_multilingual_name_tl
            WHERE language = userenv('LANG') and
                  label_code = '11007' and
                  item_code = p_item_code;

     CURSOR c_get_um_type IS
       SELECT profile_option_value
         FROM fnd_profile_options a, fnd_profile_option_values b
        WHERE b.level_id = 10001 and
              a.profile_option_id = b.profile_option_id and
              a.profile_option_name = 'FM_YIELD_TYPE';


/* Cursor used to retrieve the std uom for FM_YIELD_TYPE class */
     CURSOR c_get_uom (v_um_type VARCHAR2) IS
           SELECT std_um
             FROM sy_uoms_typ
            WHERE um_type = v_um_type;

   /*  ----------------- EXCEPTIONS -------------------- */
      INVALID_ITEM   EXCEPTION;

  BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /* Retrieve Regulatory Item information  */
      OPEN c_get_reg_item;
      FETCH c_get_reg_item  INTO l_reg_rec;

      /* If inventory item not found */
      IF c_get_reg_item%NOTFOUND THEN
         CLOSE c_get_reg_item;
         RAISE INVALID_ITEM;
      END IF;

      CLOSE c_get_reg_item;

      /* Retrieve Description (MSDS Name)  */
      OPEN c_get_description;
      FETCH c_get_description  INTO l_description;
      CLOSE c_get_description;

      /* Retrieve value of FM_YIELD_TYPE */
      OPEN c_get_um_type;
      FETCH c_get_um_type INTO l_um_type;
      CLOSE c_get_um_type;

      /* Retrieve std uom  */
      OPEN c_get_uom(l_um_type);
      FETCH c_get_uom  INTO l_uom;
      CLOSE c_get_uom;

      x_reg_item_rec.ITEM_NO            := l_reg_rec.item_code;
      x_reg_item_rec.ITEM_DESC1         := l_description;
      x_reg_item_rec.ITEM_UM            := l_uom;
      x_reg_item_rec.DUALUM_IND         := 0;
      x_reg_item_rec.DEVIATION_LO       := 0;
      x_reg_item_rec.DEVIATION_HI       := 0;
      x_reg_item_rec.LOT_CTL            := 0;
      x_reg_item_rec.LOT_INDIVISIBLE    := 0;
      x_reg_item_rec.SUBLOT_CTL         := 0;
      x_reg_item_rec.LOCT_CTL           := 0;
      x_reg_item_rec.NONINV_IND         := 1;
      x_reg_item_rec.INACTIVE_IND       := 1;
      x_reg_item_rec.RETEST_INTERVAL    := 0;
      x_reg_item_rec.GRADE_CTL          := 0;
      x_reg_item_rec.STATUS_CTL         := 0;
      x_reg_item_rec.EXPERIMENTAL_IND   := 0;
      x_reg_item_rec.DELETE_MARK        := 0;
      x_reg_item_rec.CREATION_DATE      := l_reg_rec.creation_date;
      x_reg_item_rec.CREATED_BY         := l_reg_rec.created_by;
      x_reg_item_rec.LAST_UPDATE_DATE   := l_reg_rec.last_update_date;
      x_reg_item_rec.LAST_UPDATED_BY    := l_reg_rec.last_updated_by;
      x_reg_item_rec.LAST_UPDATE_LOGIN  := l_reg_rec.last_update_login;


  EXCEPTION

      WHEN INVALID_ITEM THEN
          FND_MESSAGE.SET_NAME('GR','GR_INVALID_ITEM');
          x_msg_data := FND_MESSAGE.GET;
          x_return_status := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
          x_msg_data := SQLERRM;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END get_reg_item_info;

/*====================================================================
--  PROCEDURE:
--    migrate_OPM_item_to_ODM
--
--  DESCRIPTION:
--    Internal routine to migrate OPM items to Oracle inventory.
--    This procedure should not be called on its own. Call the
--    get_ODM_item procedure instead.
--
--  PARAMETERS:
--
--  SYNOPSIS:
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_OPM_item_to_ODM
( p_migration_run_id		IN		NUMBER
, p_item_id			IN		NUMBER
, p_item_code			IN		VARCHAR2
, p_item_source			IN		VARCHAR2
, p_organization_id		IN		NUMBER
, p_master_org_id		IN		NUMBER
, p_organization_type		IN		VARCHAR2
, p_commit			IN		VARCHAR2
, x_inventory_item_id		OUT NOCOPY	NUMBER
, x_failure_count               OUT NOCOPY	NUMBER
) IS
  l_item_rec			INV_ITEM_API.Item_rec_type;
  o_item_rec			INV_ITEM_API.Item_rec_type;
  l_opm_item			IC_ITEM_MST_B%ROWTYPE;
  l_inventory_item_id		NUMBER;
  l_organization_code		VARCHAR2(3);
  l_action			VARCHAR2(1);
  l_event			VARCHAR(20);
  l_return_status               VARCHAR2(10);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);
  l_field_name			VARCHAR(50);
  l_field_value			VARCHAR(50);
  v_rowid 			varchar2(1000);
  e_error			EXCEPTION;

  l_enabled_flag		VARCHAR2(1);
  l_prim_uom_code		VARCHAR2(3);
  l_prim_unit_of_meassure	VARCHAR2(15);
  l_sec_uom_code		VARCHAR2(3);
  l_sec_unit_of_meassure	VARCHAR2(15);
  l_inventory_item_flag		VARCHAR2(1);
  l_inventory_asset_flag 	VARCHAR2(1);
  l_costing_enabled_flag 	VARCHAR2(1);
  l_stock_enabled_flag		VARCHAR2(1);
  l_build_in_wip_flag		VARCHAR2(1);
  l_mtl_xactions_enabled_flag	VARCHAR2(1);
  l_purchasing_enabled_flag	VARCHAR2(1);
  l_customer_order_enabled_flag	VARCHAR2(1);
  l_internal_order_enabled_flag	VARCHAR2(1);
  l_invoice_enabled_flag	VARCHAR2(1);
  l_recipe_enabled_flag		VARCHAR2(1);
  l_process_exec_enabled_flag	VARCHAR2(1);
  l_process_costing_enabled_flag	VARCHAR2(1);
  l_process_quality_enabled_flag	VARCHAR2(1);
  l_shelf_life_code		NUMBER;
  l_auto_lot_alpha_prefix	VARCHAR2(30);
  l_start_auto_lot_number	NUMBER;
  l_child_lot_prefix		VARCHAR2(30);
  l_child_lot_starting_number	NUMBER;
  l_cost_of_sales_account 	NUMBER;
  l_sales_Account		NUMBER;
  l_expense_Account 		NUMBER;
  l_encumbrance_account		NUMBER;
  l_status_id			NUMBER;
  l_maturity_days		NUMBER;
  l_hold_days			NUMBER;
  l_process_enabled_flag	VARCHAR2(1);

  CURSOR c_ic_item_mst_tl IS
  SELECT *
  FROM ic_item_mst_tl
  WHERE item_id = p_item_id;
BEGIN
	x_failure_count := 0;
	-- Get the OPM Item Master Details
	BEGIN
		IF p_item_source = 'GR' THEN
			get_reg_item_info (
				p_item_code => p_item_code,
				x_reg_item_rec => l_opm_item,
				x_return_status => l_return_status,
				x_msg_data => l_msg_data);
			IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				-- Log error
				-- dbms_output.put_line ('Invalid Regulatory Item :' || p_item_code);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_UNEXPECTED_ERROR',
					p_table_name      => 'IC_ITEM_MST_B',
					p_context         => 'ITEMS',
					p_token1	  => 'ERROR',
					p_param1          => l_msg_data,
					p_param2          => NULL,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				x_failure_count := x_failure_count + 1;
				RAISE e_error;
			END IF;
		ELSE
			SELECT * INTO l_opm_item
			FROM ic_item_mst_b
			WHERE item_id = p_item_id;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- Log error
			-- dbms_output.put_line ('Invalid item id' || to_char(p_item_id));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_INVALID_ITEM_ID',
				p_table_name      => 'IC_ITEM_MST_B',
				p_context         => 'ITEMS',
				p_param1          => INV_GMI_Migration.item(p_item_id),
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RAISE e_error;
	END;

	-- Check if the item already exists in discrete
	BEGIN
		l_action := 'I';

		SELECT inventory_item_id
		INTO l_inventory_item_id
		FROM mtl_system_items_b
		WHERE
			segment1 = l_opm_item.item_no and
			ROWNUM = 1;

		INV_ITEM_PVT.Get_Org_Item(
			p_Item_ID => l_inventory_item_id,
			p_Org_ID => p_organization_id,
			x_Item_rec => l_item_rec,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data);

		IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			l_action := 'U';
		END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			SELECT mtl_system_items_s.nextval
			INTO l_inventory_item_id
			FROM dual
			WHERE rownum = 1;
	END;

	-- -- dbms_output.put_line ('Migrate Action = '||l_action);
	-- Set local variables based upon OPM item master definition
	IF (l_opm_item.delete_mark = 1) THEN
		l_enabled_flag :=  'N';
	ELSE
		l_enabled_flag :=  'Y';
	END IF;
	BEGIN
		-- Get default accounts
		l_field_name := 'Organization Accounts';
		l_field_value := 'Organization Id = '||to_char(p_organization_id);
		SELECT  cost_of_sales_account, sales_account,
			expense_account, encumbrance_account,
			process_enabled_flag, organization_code
		INTO    l_cost_of_sales_account, l_sales_account,
			l_expense_account, l_encumbrance_account,
			l_process_enabled_flag, l_organization_code
		FROM    mtl_parameters
		WHERE   organization_id = p_organization_id
		AND     rownum = 1;

		IF ( l_process_enabled_flag <> 'Y') THEN
			IF (p_organization_type = 'C') THEN
				-- Log Error
				-- dbms_output.put_line ('Cannot migrate discrete organization');
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_DISCRETE_ORG',
					p_table_name      => 'IC_ITEM_MST_B',
					p_context         => 'ITEMS',
					p_param1          => INV_GMI_Migration.org(p_organization_id),
					p_param2          => INV_GMI_Migration.item(p_item_id),
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				x_failure_count := x_failure_count + 1;
				RAISE e_error;
			END IF;
		END IF;
		l_field_name := 'UOM Code';
		l_field_value := l_opm_item.item_um;
		SELECT uom_code,unit_of_measure
		INTO l_prim_uom_code, l_prim_unit_of_meassure
		FROM sy_uoms_mst
		WHERE um_code = l_opm_item.item_um;

		IF (l_opm_item.dualum_ind > 0) THEN
			l_field_name := 'Secondary UOM';
			l_field_value := l_opm_item.item_um2;
			SELECT uom_code,unit_of_measure
			INTO l_sec_uom_code, l_sec_unit_of_meassure
			FROM sy_uoms_mst
			WHERE um_code = l_opm_item.item_um2;
		END IF;

                IF (g_inv_item_status_code is NULL) THEN
                        g_inv_item_status_code :=
                                fnd_profile.value ('INV_STATUS_DEFAULT');
                END IF;

		l_inventory_item_flag := 'Y';
		l_inventory_asset_flag := 'Y';
		l_costing_enabled_flag := 'Y';
		l_stock_enabled_flag := 'Y';
		l_build_in_wip_flag := 'Y';
		l_mtl_xactions_enabled_flag := 'Y';
		l_purchasing_enabled_flag := 'Y';
		l_customer_order_enabled_flag := 'Y';
		l_internal_order_enabled_flag := 'Y';
		l_invoice_enabled_flag := 'Y';
		l_recipe_enabled_flag := 'Y';
		l_process_exec_enabled_flag := 'Y';
		l_process_costing_enabled_flag := 'Y';
		l_process_quality_enabled_flag := 'Y';
		IF (l_opm_item.noninv_ind = 1) THEN
			l_inventory_item_flag := 'N';
			l_inventory_asset_flag := 'N';
			l_costing_enabled_flag := 'N';
			l_stock_enabled_flag := 'N';
			l_build_in_wip_flag := 'N';
			l_mtl_xactions_enabled_flag := 'N';
		END IF;
		-- inactive must come after noninv logic and can override noninv
		-- logic
		IF (l_opm_item.inactive_ind = 1) THEN
			l_stock_enabled_flag := 'N';
			l_build_in_wip_flag := 'N';
			l_mtl_xactions_enabled_flag := 'N';
			l_purchasing_enabled_flag := 'N';
			l_customer_order_enabled_flag := 'N';
			l_internal_order_enabled_flag := 'N';
			l_invoice_enabled_flag := 'N';
			l_recipe_enabled_flag := 'N';
			l_process_exec_enabled_flag := 'N';
			l_process_costing_enabled_flag := 'N';
			l_process_quality_enabled_flag := 'N';
		END IF;

 		-- Jatinder - 12/15/06 - Make OPM items with NULL or 0 shelf life days
		-- as user defined expiration control. Discrete item master
 		-- doesn't allow shelf life expiration control for 0 shelf
 		-- life days. 5730196
		l_shelf_life_code := 1; -- No control
		IF (l_opm_item.lot_ctl = 1) THEN
		BEGIN
			IF (nvl(l_opm_item.shelf_life, 0) = 0) THEN
				l_shelf_life_code := 4; -- User defined
			ELSE
				l_shelf_life_code := 2; -- Shelf Life Days
			END IF;
		END;
		END IF;

		l_field_name := 'GMI Migration parameters';
		l_field_value := NULL;
		IF (g_auto_lot_alpha_prefix is NULL) THEN
		BEGIN
			SELECT
				auto_lot_alpha_prefix, start_auto_lot_number,
				child_lot_prefix, child_lot_starting_number
			INTO
				g_auto_lot_alpha_prefix, g_start_auto_lot_number,
				g_child_lot_prefix, g_child_lot_starting_number
			FROM gmi_migration_parameters
			WHERE rownum = 1;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				g_auto_lot_alpha_prefix := 'L';
				g_start_auto_lot_number := 1;
				g_child_lot_prefix := '#S';
				g_child_lot_starting_number := 1;
		END;
		END IF;

		IF (l_opm_item.lot_ctl = 1) THEN
			l_auto_lot_alpha_prefix := nvl(l_opm_item.lot_prefix,
						g_auto_lot_alpha_prefix);
			l_start_auto_lot_number := nvl(l_opm_item.lot_suffix,
						g_start_auto_lot_number);
		END IF;
		IF (l_opm_item.sublot_ctl = 1) THEN
			l_child_lot_prefix := nvl(l_opm_item.sublot_prefix,
						g_child_lot_prefix);
			l_child_lot_starting_number := nvl(l_opm_item.sublot_suffix,
						g_child_lot_starting_number);
		END IF;

		-- Get the default status id
		l_field_name := 'Default Status Id';
		l_field_value := l_opm_item.lot_status;
      -- Bug 7166389
      -- Migrate status_id for status_ctl = 2 items.
                l_status_id := NULL;
		IF (l_opm_item.status_ctl IN (1,2) and
			l_opm_item.lot_status is not NULL) THEN
			SELECT status_id
			INTO l_status_id
			FROM ic_lots_sts
			WHERE
				lot_status = l_opm_item.lot_status and
				status_id is not NULL;
		END IF;

		-- Get CPG fields
		l_field_name := 'Maturity and Hold Days';
		BEGIN
			SELECT ic_matr_days, ic_hold_days
			INTO l_maturity_days, l_hold_days
			FROM ic_item_cpg
			WHERE
				item_id = l_opm_item.item_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;

	EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        -- Log error for l_field_name
			-- dbms_output.put_line ('Could not find '||l_field_name||' for '||l_field_value);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_NO_DATA_FOR_FIELD',
				p_table_name      => 'IC_ITEM_MST_B',
				p_context         => 'ITEMS',
				p_param1          => l_field_name,
				p_param2          => l_field_value,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RAISE e_error;
        END;

	-- Prepare the data for the Item creation
	l_item_rec.ORGANIZATION_ID	:=  p_organization_id;
	l_item_rec.INVENTORY_ITEM_ID	:=  l_inventory_item_id;
	l_item_rec.SEGMENT1	:=  l_opm_item.item_no;
	l_item_rec.SUMMARY_FLAG	:=  'Y';
	l_item_rec.ENABLED_FLAG	:=  l_enabled_flag;

	-- Fix any flags which may cause errors
	l_item_rec.BOM_ENABLED_FLAG := 'N';
	l_item_rec.PURCHASING_ITEM_FLAG := 'Y';
	l_item_rec.CUSTOMER_ORDER_FLAG := 'Y';
	l_item_rec.SHIPPABLE_ITEM_FLAG := 'Y';
	l_item_rec.INTERNAL_ORDER_FLAG := 'Y';
	l_item_rec.INVOICEABLE_ITEM_FLAG := 'Y';
	l_item_rec.SO_TRANSACTIONS_FLAG := 'Y';
	l_item_rec.TAXABLE_FLAG := 'Y';

	l_item_rec.INVENTORY_ITEM_FLAG	:=  l_inventory_item_flag;
	l_item_rec.INVENTORY_ASSET_FLAG	:=  l_inventory_asset_flag;
	l_item_rec.COSTING_ENABLED_FLAG	:=  l_costing_enabled_flag;
	l_item_rec.STOCK_ENABLED_FLAG	:=  l_stock_enabled_flag;
	l_item_rec.BUILD_IN_WIP_FLAG := l_build_in_wip_flag;
	l_item_rec.MTL_TRANSACTIONS_ENABLED_FLAG	:=  l_mtl_xactions_enabled_flag;
	l_item_rec.PURCHASING_ENABLED_FLAG := l_purchasing_enabled_flag;
	l_item_rec.CUSTOMER_ORDER_ENABLED_FLAG := l_customer_order_enabled_flag;
	l_item_rec.INTERNAL_ORDER_ENABLED_FLAG := l_internal_order_enabled_flag;
	l_item_rec.INVOICE_ENABLED_FLAG := l_invoice_enabled_flag;
	l_item_rec.RECIPE_ENABLED_FLAG := l_recipe_enabled_flag;
	l_item_rec.PROCESS_QUALITY_ENABLED_FLAG := l_process_quality_enabled_flag;
	l_item_rec.PROCESS_EXECUTION_ENABLED_FLAG := l_process_exec_enabled_flag;
	l_item_rec.PROCESS_COSTING_ENABLED_FLAG := l_process_costing_enabled_flag;

	IF (( l_process_enabled_flag = 'Y' and l_action = 'U') or l_action = 'I') THEN
		l_item_rec.BOM_ENABLED_FLAG := 'N';
		l_item_rec.DESCRIPTION	:=  l_opm_item.item_desc1;
		l_item_rec.LONG_DESCRIPTION	:=  l_opm_item.item_desc2;
		l_item_rec.PRIMARY_UOM_CODE	:=  l_prim_uom_code;
		l_item_rec.PRIMARY_UNIT_OF_MEASURE	:=  l_prim_unit_of_meassure;
		l_item_rec.ITEM_TYPE	:=  l_opm_item.inv_type;
		l_item_rec.SHELF_LIFE_CODE	:=  l_shelf_life_code;
		l_item_rec.SHELF_LIFE_DAYS	:=  l_opm_item.shelf_life;
		l_item_rec.LOT_CONTROL_CODE	:=  l_opm_item.lot_ctl + 1;
		l_item_rec.AUTO_LOT_ALPHA_PREFIX	:=  l_auto_lot_alpha_prefix;
		l_item_rec.START_AUTO_LOT_NUMBER	:=  l_start_auto_lot_number;
		l_item_rec.LOCATION_CONTROL_CODE	:=  l_opm_item.loct_ctl + 1;
		l_item_rec.ENG_ITEM_FLAG	:=  'N';
		IF (l_opm_item.experimental_ind = 1) THEN
			l_item_rec.ENG_ITEM_FLAG        :=  'Y';
		END IF;
		l_item_rec.LOT_STATUS_ENABLED := 'N';
      -- Bug 7166389
      -- Migrate status flag for status_ctl = 2 items
		IF (l_opm_item.status_ctl IN (1,2)) THEN
			l_item_rec.LOT_STATUS_ENABLED := 'Y';
		END IF;
		l_item_rec.DEFAULT_LOT_STATUS_ID := l_status_id;
		l_item_rec.DUAL_UOM_CONTROL := l_opm_item.dualum_ind + 1;
		l_item_rec.SECONDARY_UOM_CODE := l_sec_uom_code;
		l_item_rec.DUAL_UOM_DEVIATION_HIGH := nvl(l_opm_item.deviation_lo*100,0);
		l_item_rec.DUAL_UOM_DEVIATION_LOW := nvl(l_opm_item.deviation_hi*100,0);
		l_item_rec.SECONDARY_DEFAULT_IND := NULL;
		l_item_rec.TRACKING_QUANTITY_IND := 'P';
		IF (l_opm_item.dualum_ind > 0) THEN
			l_item_rec.TRACKING_QUANTITY_IND := 'PS';
			IF (l_opm_item.dualum_ind = 1) THEN
				l_item_rec.SECONDARY_DEFAULT_IND := 'F';
			ELSIF (l_opm_item.dualum_ind = 2) THEN
				l_item_rec.SECONDARY_DEFAULT_IND := 'D';
			ELSE
				l_item_rec.SECONDARY_DEFAULT_IND := 'N';
			END IF;
		END IF;
		l_item_rec.ONT_PRICING_QTY_SOURCE := 'P';
		IF (l_opm_item.ONT_PRICING_QTY_SOURCE = 1) THEN
			l_item_rec.ONT_PRICING_QTY_SOURCE := 'S';
		END IF;
		l_item_rec.LOT_DIVISIBLE_FLAG := 'N';
		IF (l_opm_item.lot_ctl = 1 and l_opm_item.lot_indivisible = 0) THEN
			l_item_rec.LOT_DIVISIBLE_FLAG := 'Y';
		END IF;
		l_item_rec.GRADE_CONTROL_FLAG := 'N';
		IF (l_opm_item.grade_ctl = 1) THEN
			l_item_rec.GRADE_CONTROL_FLAG := 'Y';
		END IF;
		l_item_rec.DEFAULT_GRADE := l_opm_item.qc_grade;
		l_item_rec.CHILD_LOT_FLAG := 'N';
		l_item_rec.CHILD_LOT_VALIDATION_FLAG := 'N';
		IF (l_opm_item.sublot_ctl =  1) THEN
			l_item_rec.CHILD_LOT_FLAG := 'Y';
			l_item_rec.PARENT_CHILD_GENERATION_FLAG := 'C';
			-- The lot migration may not conform to strict validation
			l_item_rec.CHILD_LOT_VALIDATION_FLAG := 'N';
			l_item_rec.CHILD_LOT_PREFIX := l_child_lot_prefix;
			l_item_rec.CHILD_LOT_STARTING_NUMBER := l_child_lot_starting_number;
		END IF;
		l_item_rec.COPY_LOT_ATTRIBUTE_FLAG := 'N';

		l_item_rec.PROCESS_SUPPLY_SUBINVENTORY := NULL;
		l_item_rec.PROCESS_SUPPLY_LOCATOR_ID := NULL;
		l_item_rec.PROCESS_YIELD_SUBINVENTORY := NULL;
		l_item_rec.PROCESS_YIELD_LOCATOR_ID := NULL;
		l_item_rec.HAZARDOUS_MATERIAL_FLAG := 'N';
		l_item_rec.CAS_NUMBER := NULL;
		l_item_rec.RETEST_INTERVAL := l_opm_item.retest_interval;
		l_item_rec.EXPIRATION_ACTION_INTERVAL := l_opm_item.expaction_interval;
		IF (l_opm_item.expaction_code is not NULL) THEN
			l_item_rec.EXPIRATION_ACTION_CODE := l_opm_item.expaction_code;
		END IF;
		l_item_rec.MATURITY_DAYS := l_maturity_days;
		l_item_rec.HOLD_DAYS := l_hold_days;

	END IF;


	IF (l_action = 'I') THEN

		l_item_rec.INVENTORY_ITEM_STATUS_CODE        :=  g_inv_item_status_code;
		l_item_rec.CATALOG_STATUS_FLAG	:=  'N';
		l_item_rec.ALLOWED_UNITS_LOOKUP_CODE	:=  3;
		l_item_rec.CHECK_SHORTAGES_FLAG	:=  'N';
		l_item_rec.REVISION_QTY_CONTROL_CODE	:=  1;
		l_item_rec.RESERVABLE_TYPE	:=  1;
		l_item_rec.CYCLE_COUNT_ENABLED_FLAG	:=  'N';
		l_item_rec.SERIAL_NUMBER_CONTROL_CODE	:=  1;
		l_item_rec.RESTRICT_SUBINVENTORIES_CODE	:=  2;
		l_item_rec.RESTRICT_LOCATORS_CODE	:=  2;
		l_item_rec.BOM_ITEM_TYPE	:=  4;
		l_item_rec.EFFECTIVITY_CONTROL	:=  1;
		l_item_rec.AUTO_CREATED_CONFIG_FLAG	:=  'N';
		l_item_rec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG	:=  'N';
		l_item_rec.COST_OF_SALES_ACCOUNT := l_cost_of_sales_account;
		l_item_rec.PURCHASING_ITEM_FLAG := 'Y';
		l_item_rec.MUST_USE_APPROVED_VENDOR_FLAG := 'N';
		l_item_rec.ALLOW_ITEM_DESC_UPDATE_FLAG := 'Y';
		l_item_rec.RFQ_REQUIRED_FLAG := 'N';
		l_item_rec.OUTSIDE_OPERATION_FLAG := 'N';
		l_item_rec.TAXABLE_FLAG := 'Y';
		l_item_rec.RECEIPT_REQUIRED_FLAG := 'Y';
		l_item_rec.INSPECTION_REQUIRED_FLAG := 'N';
		l_item_rec.UNIT_OF_ISSUE := l_prim_unit_of_meassure;
		l_item_rec.LIST_PRICE_PER_UNIT := 0;
		l_item_rec.MARKET_PRICE := 0;
		l_item_rec.PRICE_TOLERANCE_PERCENT := 0;
		l_item_rec.ENCUMBRANCE_ACCOUNT := l_encumbrance_account;
		l_item_rec.EXPENSE_ACCOUNT := l_expense_account;
		l_item_rec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG := 'N';
		l_item_rec.ALLOW_UNORDERED_RECEIPTS_FLAG := 'N';
		l_item_rec.ALLOW_EXPRESS_DELIVERY_FLAG := 'N';
		l_item_rec.INVENTORY_PLANNING_CODE := 2;
		l_item_rec.PLANNING_MAKE_BUY_CODE := 2;
		l_item_rec.MRP_SAFETY_STOCK_CODE := 1;
		l_item_rec.MRP_PLANNING_CODE := 7;
		l_item_rec.ATO_FORECAST_CONTROL := 2;
		l_item_rec.END_ASSEMBLY_PEGGING_FLAG := 'N';
		l_item_rec.REPETITIVE_PLANNING_FLAG := 'N';
		l_item_rec.ACCEPTABLE_RATE_INCREASE := 0;
		l_item_rec.ACCEPTABLE_RATE_DECREASE := 0;
		l_item_rec.PLANNING_TIME_FENCE_CODE := 4;
		l_item_rec.PLANNING_TIME_FENCE_DAYS := 1;
		l_item_rec.WIP_SUPPLY_TYPE := 1;
		l_item_rec.BOM_ENABLED_FLAG := 'N';
		l_item_rec.CUSTOMER_ORDER_FLAG := 'Y';
		l_item_rec.SHIPPABLE_ITEM_FLAG := 'Y';
		l_item_rec.INTERNAL_ORDER_FLAG := 'Y';
		l_item_rec.SO_TRANSACTIONS_FLAG := 'Y';
		l_item_rec.PICK_COMPONENTS_FLAG := 'N';
		l_item_rec.ATP_FLAG := 'N';
		l_item_rec.REPLENISH_TO_ORDER_FLAG := 'N';
		l_item_rec.ATP_COMPONENTS_FLAG := 'N';
		l_item_rec.SHIP_MODEL_COMPLETE_FLAG := 'N';
		l_item_rec.RETURNABLE_FLAG := 'Y';
		l_item_rec.RETURN_INSPECTION_REQUIREMENT := 2;
		l_item_rec.INVOICEABLE_ITEM_FLAG := 'Y';
		l_item_rec.SALES_ACCOUNT := l_sales_account;
		l_item_rec.SERVICE_DURATION := 0;
		l_item_rec.SERVICEABLE_PRODUCT_FLAG := 'N';
		l_item_rec.SERVICE_STARTING_DELAY := 0;
		l_item_rec.SERVICEABLE_COMPONENT_FLAG := 'N';
		l_item_rec.PREVENTIVE_MAINTENANCE_FLAG := 'N';
		l_item_rec.PRORATE_SERVICE_FLAG := 'N';
		l_item_rec.SERIAL_STATUS_ENABLED := 'N';
		l_item_rec.DEFAULT_SERIAL_STATUS_ID := NULL;
		l_item_rec.LOT_SPLIT_ENABLED := 'N';
		l_item_rec.LOT_MERGE_ENABLED := 'N';
		l_item_rec.LOT_TRANSLATE_ENABLED := 'N';
		l_item_rec.DEFAULT_SO_SOURCE_TYPE := 'INTERNAL';
		l_item_rec.CREATE_SUPPLY_FLAG := 'Y';
		l_item_rec.ASN_AUTOEXPIRE_FLAG := 2;
		l_item_rec.BULK_PICKED_FLAG := 'N';
		l_item_rec.CONSIGNED_FLAG := 2;
		l_item_rec.CONTINOUS_TRANSFER := 3;
		l_item_rec.CONVERGENCE := 3;
		l_item_rec.CRITICAL_COMPONENT_FLAG := 2;
		l_item_rec.DIVERGENCE := 3;
		l_item_rec.DRP_PLANNED_FLAG := 2;
		l_item_rec.EQUIPMENT_TYPE := 2;
		l_item_rec.EXCLUDE_FROM_BUDGET_FLAG := 2;
		l_item_rec.LEAD_TIME_LOT_SIZE := 1;
		l_item_rec.POSTPROCESSING_LEAD_TIME := 0; -- ?????
		l_item_rec.SERV_BILLING_ENABLED_FLAG := 'N';
		l_item_rec.SO_AUTHORIZATION_FLAG := 1;
		l_item_rec.VMI_FORECAST_TYPE := 1;
		l_item_rec.WEB_STATUS := 'UNPUBLISHED';

	END IF;


	IF (g_attribute_context = 1 and l_item_rec.ATTRIBUTE_CATEGORY is NULL) THEN
		l_item_rec.ATTRIBUTE_CATEGORY := l_opm_item.attribute_category;
	END IF;
	IF (g_attribute1 = 1 and l_item_rec.attribute1 is NULL) THEN l_item_rec.attribute1 := l_opm_item.attribute1; END IF;
	IF (g_attribute2 = 1 and l_item_rec.attribute2 is NULL) THEN l_item_rec.attribute2 := l_opm_item.attribute2; END IF;
	IF (g_attribute3 = 1 and l_item_rec.attribute3 is NULL) THEN l_item_rec.attribute3 := l_opm_item.attribute3; END IF;
	IF (g_attribute4 = 1 and l_item_rec.attribute4 is NULL) THEN l_item_rec.attribute4 := l_opm_item.attribute4; END IF;
	IF (g_attribute5 = 1 and l_item_rec.attribute5 is NULL) THEN l_item_rec.attribute5 := l_opm_item.attribute5; END IF;
	IF (g_attribute6 = 1 and l_item_rec.attribute6 is NULL) THEN l_item_rec.attribute6 := l_opm_item.attribute6; END IF;
	IF (g_attribute7 = 1 and l_item_rec.attribute7 is NULL) THEN l_item_rec.attribute7 := l_opm_item.attribute7; END IF;
	IF (g_attribute8 = 1 and l_item_rec.attribute8 is NULL) THEN l_item_rec.attribute8 := l_opm_item.attribute8; END IF;
	IF (g_attribute9 = 1 and l_item_rec.attribute9 is NULL) THEN l_item_rec.attribute9 := l_opm_item.attribute9; END IF;
	IF (g_attribute10 = 1 and l_item_rec.attribute10 is NULL) THEN l_item_rec.attribute10 := l_opm_item.attribute10; END IF;
	IF (g_attribute11 = 1 and l_item_rec.attribute11 is NULL) THEN l_item_rec.attribute11 := l_opm_item.attribute11; END IF;
	IF (g_attribute12 = 1 and l_item_rec.attribute12 is NULL) THEN l_item_rec.attribute12 := l_opm_item.attribute12; END IF;
	IF (g_attribute13 = 1 and l_item_rec.attribute13 is NULL) THEN l_item_rec.attribute13 := l_opm_item.attribute13; END IF;
	IF (g_attribute14 = 1 and l_item_rec.attribute14 is NULL) THEN l_item_rec.attribute14 := l_opm_item.attribute14; END IF;
	IF (g_attribute15 = 1 and l_item_rec.attribute15 is NULL) THEN l_item_rec.attribute15 := l_opm_item.attribute15; END IF;
	IF (g_attribute16 = 1 and l_item_rec.attribute16 is NULL) THEN l_item_rec.attribute16 := l_opm_item.attribute16; END IF;
	IF (g_attribute17 = 1 and l_item_rec.attribute17 is NULL) THEN l_item_rec.attribute17 := l_opm_item.attribute17; END IF;
	IF (g_attribute18 = 1 and l_item_rec.attribute18 is NULL) THEN l_item_rec.attribute18 := l_opm_item.attribute18; END IF;
	IF (g_attribute19 = 1 and l_item_rec.attribute19 is NULL) THEN l_item_rec.attribute19 := l_opm_item.attribute19; END IF;
	IF (g_attribute20 = 1 and l_item_rec.attribute20 is NULL) THEN l_item_rec.attribute20 := l_opm_item.attribute20; END IF;
	IF (g_attribute21 = 1 and l_item_rec.attribute21 is NULL) THEN l_item_rec.attribute21 := l_opm_item.attribute21; END IF;
	IF (g_attribute22 = 1 and l_item_rec.attribute22 is NULL) THEN l_item_rec.attribute22 := l_opm_item.attribute22; END IF;
	IF (g_attribute23 = 1 and l_item_rec.attribute23 is NULL) THEN l_item_rec.attribute23 := l_opm_item.attribute23; END IF;
	IF (g_attribute24 = 1 and l_item_rec.attribute24 is NULL) THEN l_item_rec.attribute24 := l_opm_item.attribute24; END IF;
	IF (g_attribute25 = 1 and l_item_rec.attribute25 is NULL) THEN l_item_rec.attribute25 := l_opm_item.attribute25; END IF;
	IF (g_attribute26 = 1 and l_item_rec.attribute26 is NULL) THEN l_item_rec.attribute26 := l_opm_item.attribute26; END IF;
	IF (g_attribute27 = 1 and l_item_rec.attribute27 is NULL) THEN l_item_rec.attribute27 := l_opm_item.attribute27; END IF;
	IF (g_attribute28 = 1 and l_item_rec.attribute28 is NULL) THEN l_item_rec.attribute28 := l_opm_item.attribute28; END IF;
	IF (g_attribute29 = 1 and l_item_rec.attribute29 is NULL) THEN l_item_rec.attribute29 := l_opm_item.attribute29; END IF;
	IF (g_attribute30 = 1 and l_item_rec.attribute30 is NULL) THEN l_item_rec.attribute30 := l_opm_item.attribute30; END IF;

	-- l_item_rec.GLOBAL_ATTRIBUTE_CATEGORY := NULL;
	-- l_item_rec.GLOBAL_ATTRIBUTE1 := NULL;
	-- l_item_rec.GLOBAL_ATTRIBUTE10 := NULL;
	l_item_rec.CREATION_DATE := SYSDATE;
	l_item_rec.CREATED_BY := l_opm_item.created_by;
	l_item_rec.LAST_UPDATE_DATE := SYSDATE;
	l_item_rec.LAST_UPDATED_BY := l_opm_item.last_updated_by;
	l_item_rec.LAST_UPDATE_LOGIN := NULL;

	IF p_item_source = 'GR' THEN
		l_recipe_enabled_flag := 'Y';
	END IF;
	-- Call the API to create/ update item item
	IF (l_action = 'I') THEN

		l_event := 'ORG_ASSIGN';
		IF (p_organization_type = 'M') THEN
			l_event := 'INSERT';
		END IF;

		-- -- dbms_output.put_line ('Event = '||l_event);
		fnd_msg_pub.initialize;
                INV_ITEM_PVT.Create_Item( p_item_rec => l_item_rec
                                         ,P_Item_Category_Struct_Id => NULL
                                         ,P_Inv_Install => INV_Item_Util.Appl_Install().INV
                                         ,P_Master_Org_Id => p_master_org_id
                                         ,P_Category_Set_Id => NULL
                                         ,P_Item_Category_Id => NULL
                                         ,P_Event => l_event
                                         ,x_row_Id => v_rowid
                                         ,P_Default_Move_Order_Sub_Inv => NULL
                                         ,P_Default_Receiving_Sub_Inv => NULL
                                         ,P_Default_Shipping_Sub_Inv  => NULL
                                        );
	ELSE
		fnd_msg_pub.initialize;
		INV_ITEM_PVT.Update_Item(
			p_item_rec => l_item_rec,
			P_Item_Category_Struct_Id => NULL,
			P_Inv_Install => INV_Item_Util.Appl_Install().INV,
			P_Master_Org_Id => p_master_org_id,
			P_Category_Set_Id => NULL,
			P_Item_Category_Id => NULL,
			P_Mode => 'UPDATE',
			P_Updateble_Item => NULL,
			P_Cost_Txn => NULL,
			P_Item_Cost_Details => NULL,
			P_Inv_Item_status_old => l_item_rec.INVENTORY_ITEM_STATUS_CODE,
			P_Default_Move_Order_Sub_Inv => '!',
			P_Default_Receiving_Sub_Inv => '!',
			P_Default_Shipping_Sub_Inv => '!');

	END IF;

	g_inventory_item_id := l_item_rec.INVENTORY_ITEM_ID;
	x_inventory_item_id := l_item_rec.INVENTORY_ITEM_ID;

	IF p_item_source = 'GMI' THEN

		-- Update the item description in the TL tables.
		FOR d in c_ic_item_mst_tl LOOP
			UPDATE mtl_system_items_tl
			SET 	description         = d.item_desc1,
				long_description    = nvl(long_description, d.item_desc2),
				source_lang         = d.source_lang,
				last_update_date    = d.last_update_date,
				last_updated_by     = d.last_updated_by
			WHERE
				organization_id = p_organization_id AND
				inventory_item_id = l_item_rec.INVENTORY_ITEM_ID AND
				language = d.language;
		END LOOP;

                -- Bug 5489195 - Added migrated_ind in the update
		UPDATE ic_item_mst_b_mig
		SET
			inventory_item_id = x_inventory_item_id,
                        migrated_ind = 1,
			last_update_date = sysdate,
			last_updated_by = 0
		WHERE
			item_id = p_item_id AND
			organization_id = p_organization_id;

		IF SQL%ROWCOUNT = 0 THEN
			INSERT INTO ic_item_mst_b_mig(
				item_id,
				organization_id,
				inventory_item_id,
				migrated_ind,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login
			)values(
				p_item_id,
				p_organization_id,
				x_inventory_item_id,
				1,
				sysdate,
				0,
				sysdate,
				0,
				NULL
			);
		END IF;
	END IF;

 	-- Jatinder - 11/30/06 - Move commit to the main procedure to avoid deadlocks. 5690686.
EXCEPTION
	WHEN e_error THEN
		ROLLBACK;
	WHEN FND_API.G_EXC_ERROR THEN
		x_failure_count := x_failure_count + 1;
		FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		FOR i in 1..l_msg_count LOOP
			-- dbms_output.put_line (substr(fnd_msg_pub.get_detail(i, NULL),1,255));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_UNEXPECTED_ERROR',
				p_table_name      => 'IC_ITEM_MST_B',
				p_context         => 'ITEMS',
				p_token1	  => 'ERROR',
				p_param1          => fnd_msg_pub.get_detail(i, NULL),
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'FND');
		END LOOP;
		ROLLBACK;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_failure_count := x_failure_count + 1;
		FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		FOR i in 1..l_msg_count LOOP
			-- dbms_output.put_line (substr(fnd_msg_pub.get_detail(i, NULL),1,255));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_UNEXPECTED_ERROR',
				p_table_name      => 'IC_ITEM_MST_B',
				p_context         => 'ITEMS',
				p_token1	  => 'ERROR',
				p_param1          => fnd_msg_pub.get_detail(i, NULL),
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'FND');
		END LOOP;
		ROLLBACK;

	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		FOR i in 1..l_msg_count LOOP
			-- dbms_output.put_line (substr(fnd_msg_pub.get_detail(i, NULL),1,255));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_UNEXPECTED_ERROR',
				p_table_name      => 'IC_ITEM_MST_B',
				p_context         => 'ITEMS',
				p_token1	  => 'ERROR',
				p_param1          => fnd_msg_pub.get_detail(i, NULL),
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'FND');
		END LOOP;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEMS',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
		ROLLBACK;
END;

/*====================================================================
--  PROCEDURE:
--    validate_item_controls
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to validate that item attribute
--    control is set to the correct level.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to write to migration log
--
--  SYNOPSIS:
--    validate_item_controls(p_migartion_id    => l_migration_id);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE validate_item_controls
( p_migration_run_id		IN	NUMBER)
IS

CURSOR c_master_attributes IS
SELECT attribute_name FROM mtl_item_attributes
WHERE
	control_level = 1 AND
	attribute_name IN ( 'MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND',
		'MTL_SYSTEM_ITEMS.ONT_PRICING_QTY_SOURCE',
		'MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND',
		'MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE',
		'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_HIGH',
		'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_LOW',
		'MTL_SYSTEM_ITEMS.ITEM_TYPE',
		'MTL_SYSTEM_ITEMS.AUTO_LOT_ALPHA_PREFIX',
		'MTL_SYSTEM_ITEMS.ENG_ITEM_FLAG',
		'MTL_SYSTEM_ITEMS.ITEM_TYPE',
		'MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE',
		'MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE',
		'MTL_SYSTEM_ITEMS.LOT_STATUS_ENABLED',
		'MTL_SYSTEM_ITEMS.START_AUTO_LOT_NUMBER') AND
	EXISTS (
		SELECT 1
		FROM mtl_parameters mo, mtl_parameters co
		WHERE
    			mo.organization_id = co.master_organization_id AND
    			Decode(mo.process_orgn_code, NULL, 'N', 'Y') <> Decode(co.process_orgn_code, NULL, 'N', 'Y'));
BEGIN

	-- Check if certain item attributes are set to be controlled at master level
	-- Just log error. Do not stop the migration for this error.
	FOR ia IN c_master_attributes LOOP
		-- dbms_output.put_line ('Attribute '|| ia.attribute_name || ' is controlled at master organization level and may result in migration issues if the attribute values are different for process and discrete organization');
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMI_MIG_ITEM_ATTRIBUTE',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEMS',
			p_param1          => ia.attribute_name,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;
END;

/*====================================================================
--  PROCEDURE:
--    validate_desc_flex_definition
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to validate the conflict
--    in desc flexfield usage for discrete and OPM Items.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to write to migration log
--
--  SYNOPSIS:
--    validate_desc_flex_definition(p_migartion_id    => l_migration_id);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE validate_desc_flex_definition
( p_migration_run_id		IN	NUMBER)
IS

CURSOR c_get_desc_flex_col_conflict IS

SELECT col.descriptive_flex_context_code,
	col.application_column_name,
	col.end_user_column_name
FROM fnd_descr_flex_column_usages col,
	fnd_descr_flex_contexts cont
WHERE
	col.application_id = 551 and
	col.descriptive_flexfield_name = 'ITEM_FLEX' and
	col.enabled_flag = 'Y' and
	col.application_id = cont.application_id and
	col.descriptive_flexfield_name = cont.descriptive_flexfield_name and
	col.descriptive_flex_context_code = cont.descriptive_flex_context_code and
	cont.enabled_flag = 'Y' and
	col.application_column_name in (
		SELECT col2.application_column_name
		FROM fnd_descr_flex_column_usages col2,
			fnd_descr_flex_contexts cont2
		WHERE
			col2.application_id = 401 and
			col2.descriptive_flexfield_name = 'MTL_SYSTEM_ITEMS' and
			col2.enabled_flag = 'Y' and
			col.application_id = cont2.application_id and
			col.descriptive_flexfield_name = cont2.descriptive_flexfield_name and
			col.descriptive_flex_context_code = cont2.descriptive_flex_context_code and
			cont2.enabled_flag = 'Y' );

CURSOR c_get_opm_desc_flex_cols IS

SELECT col.descriptive_flex_context_code,
	col.application_column_name,
	col.end_user_column_name
FROM fnd_descr_flex_column_usages col,
	fnd_descr_flex_contexts cont
WHERE
	col.application_id = 551 and
	col.descriptive_flexfield_name = 'ITEM_FLEX' and
	col.enabled_flag = 'Y' and
	col.application_id = cont.application_id and
	col.descriptive_flexfield_name = cont.descriptive_flexfield_name and
	col.descriptive_flex_context_code = cont.descriptive_flex_context_code and
	cont.enabled_flag = 'Y';

l_opm_context		VARCHAR2(30);
l_odm_context		VARCHAR2(30);
BEGIN

	g_desc_flex_conflict := 0;
	BEGIN
		SELECT cont.descriptive_flex_context_code
		INTO l_opm_context
		FROM fnd_descr_flex_contexts cont
		WHERE cont.application_id = 551 and
			cont.descriptive_flexfield_name = 'ITEM_FLEX' and
			cont.enabled_flag = 'Y' and
			cont.global_flag = 'N' and
			rownum = 1;
		g_attribute_context := 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	END;
	BEGIN
		SELECT cont.descriptive_flex_context_code
		INTO l_odm_context
		FROM fnd_descr_flex_contexts cont
		WHERE cont.application_id = 401 and
			cont.descriptive_flexfield_name = 'MTL_SYSTEM_ITEMS' and
			cont.enabled_flag = 'Y' and
			cont.global_flag = 'N' and
			rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	END;
	IF (l_opm_context is not NULL and l_odm_context is not NULL) THEN
		g_desc_flex_conflict := 1;
		-- Log Error
		-- dbms_output.put_line ('Desc flexfield conflict. OPM context: '|| l_opm_context ||', ODM context: '|| l_odm_context);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMI_MIG_DFLEX_CONTEXT_CONFLICT',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEMS',
			p_param1          => l_opm_context,
			p_param2          => l_odm_context,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END IF;

	-- Check if any OPM item decsriptive flexfield column is used in
	-- Discrete item flexfield

	FOR conflict_columns in c_get_desc_flex_col_conflict LOOP
		-- If we are here, that means we have a conflict
		g_desc_flex_conflict := 1;

		-- dbms_output.put_line ('Desc flexfield column conflict.');
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMI_MIG_DFLEX_COL_CONFLICT',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEMS',
			p_param1          => conflict_columns.descriptive_flex_context_code,
			p_param2          => conflict_columns.end_user_column_name,
			p_param3          => conflict_columns.application_column_name,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- If no conflict is found, set the control variable for item migration
	IF (g_desc_flex_conflict = 1) THEN
		RETURN;
	END IF;
	FOR opm_desc_cols in c_get_opm_desc_flex_cols LOOP

		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE1') THEN g_attribute1 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE2') THEN g_attribute2 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE3') THEN g_attribute3 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE4') THEN g_attribute4 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE5') THEN g_attribute5 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE6') THEN g_attribute6 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE7') THEN g_attribute7 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE8') THEN g_attribute8 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE9') THEN g_attribute9 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE10') THEN g_attribute10 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE11') THEN g_attribute11 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE12') THEN g_attribute12 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE13') THEN g_attribute13 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE14') THEN g_attribute14 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE15') THEN g_attribute15 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE16') THEN g_attribute16 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE17') THEN g_attribute17 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE18') THEN g_attribute18 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE19') THEN g_attribute19 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE20') THEN g_attribute20 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE21') THEN g_attribute21 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE22') THEN g_attribute22 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE23') THEN g_attribute23 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE24') THEN g_attribute24 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE25') THEN g_attribute25 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE26') THEN g_attribute26 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE27') THEN g_attribute27 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE28') THEN g_attribute28 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE29') THEN g_attribute29 := 1; END IF;
		IF (opm_desc_cols.application_column_name = 'ATTRIBUTE30') THEN g_attribute30 := 1; END IF;
	END LOOP;
END;

/*====================================================================
--  PROCEDURE:
--    get_ODM_item
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to get the Inventory Item Id for
--    an OPM item. If the OPM item is not migrated, it will migrate the
--    the item and return the discrete inventory item id.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to write to migration log
--    p_item_id - OPM item id
--    p_organization_id - Inventory organization of the item in Oracle
--                   Inventory. Item will be migrated to this organization.
--    p_mode - Use the value 'FORCE' if you want to migrate an OPM item
--             which has been migrated already. Leave it NULL for the normal
--             use.
--    p_commit - flag to indicate if commit should be performed.
--    x_inventory_item_id - Discrete inventory item id.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    get_ODM_item(	p_migartion_id		=> l_migration_id,
--		   	p_item_id		=> l_item_id,
--			p_organization_id 	=> l_organization_id,
--			p_mode 			=> NULL,
--			p_commit 		=> 'Y',
--			x_inventory_item_id 	=> l_inventory_item_id,
--			x_failure_count 	=> l_failure_count);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE get_ODM_item
( p_migration_run_id		IN		NUMBER
, p_item_id			IN		NUMBER
, p_organization_id		IN		NUMBER
, p_mode			IN		VARCHAR2
, p_commit			IN		VARCHAR2
, x_inventory_item_id		OUT NOCOPY	NUMBER
, x_failure_count               OUT NOCOPY	NUMBER
, p_item_code			IN		VARCHAR2 DEFAULT NULL
, p_item_source			IN		VARCHAR2 DEFAULT 'GMI'
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_migrated_ind                       	PLS_INTEGER;
  l_migrated_ind_m                     	PLS_INTEGER;
  l_master_organization_id		NUMBER;
  l_action				VARCHAR2(1);
  l_msg_count				NUMBER;
  l_msg_data				VARCHAR2(2000);
  i					PLS_INTEGER;
  dv					PLS_INTEGER;
BEGIN
	x_failure_count := 0;
	-- Validate input parameters
	IF ((p_item_source <> 'GMI' and p_item_source <> 'GR') or
		(p_item_source = 'GMI' and (p_item_id < 1 or p_item_id is NULL)) or
		(p_item_source = 'GR' and p_item_code is NULL) or
		p_organization_id < 1 or p_organization_id is NULL ) THEN
		-- Log validation error
		-- dbms_output.put_line ('Invalid parameters for item migration');
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMI_MIG_INVALID_PARAMS',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEMS',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
		x_failure_count := x_failure_count + 1;
		RETURN;
	END IF;

	-- See if the value for the item is already cached
	IF p_item_source = 'GMI' and (nvl(p_mode, 'N') <> 'FORCE'
		and g_item_id = p_item_id and g_organization_id = p_organization_id
		and g_inventory_item_id is not NULL) THEN
		x_inventory_item_id := g_inventory_item_id;
		RETURN;
	END IF;

	-- Check for flexfield conflicts
	IF (g_desc_flex_conflict is NULL) THEN
		validate_desc_flex_definition (p_migration_run_id);
	END IF;

	IF (g_desc_flex_conflict = 1) THEN
		-- Log error
		-- No need to log any meesages as they were logged by the previous call
		x_failure_count := x_failure_count + 1;
		RETURN;
	END IF;

	-- for GMI items check the value in ic_item_mst_b_mig table
	IF (p_item_source = 'GMI') THEN
	BEGIN
		g_item_id := p_item_id;
		g_organization_id := p_organization_id;
		g_inventory_item_id := NULL;
		l_migrated_ind := -1;

		-- Select and lock the row to avoid errors associated with running this routine in
		-- parallel from routines using AD parrallel update logic.
		SELECT inventory_item_id, migrated_ind
		INTO g_inventory_item_id, l_migrated_ind
		FROM ic_item_mst_b_mig
		WHERE
			item_id = g_item_id AND
			organization_id = g_organization_id
		FOR UPDATE;

		IF (nvl(p_mode, 'N') <> 'FORCE' and l_migrated_ind = 1) THEN
			x_inventory_item_id := g_inventory_item_id;
			COMMIT; -- Release the lock acquired above.
			RETURN;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			BEGIN
				INSERT INTO ic_item_mst_b_mig(
					item_id,
					organization_id,
					inventory_item_id,
					migrated_ind,
					creation_date,
					created_by,
					last_update_date,
					last_updated_by,
					last_update_login
				)values(
					g_item_id,
					g_organization_id,
					NULL,
					0,
					sysdate,
					0,
					sysdate,
					0,
					NULL
				);
			EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN -- Another parrallel run may have created this row already.
					NULL;
			END;

			-- Lock this row for the parrallel run of this routine.
			SELECT 1
			INTO dv
			FROM ic_item_mst_b_mig
			WHERE
				item_id = g_item_id AND
				organization_id = g_organization_id
			FOR UPDATE;
	END;
	END IF;

	-- This item needs migration
	-- Check the master organization to see if that has this item and
	-- has been migrated. For GR, item always need migration.
	BEGIN
		l_migrated_ind_m := -1;
		SELECT master_organization_id
		INTO l_master_organization_id
		FROM mtl_parameters
		WHERE
			organization_id = p_organization_id;

		-- Select and lock the row to avoid errors associated with running this routine in
		-- parallel from routines using AD parrallel update logic.
		SELECT i.migrated_ind
		INTO l_migrated_ind_m
		FROM ic_item_mst_b_mig i
		WHERE
			i.organization_id = l_master_organization_id and
			i.item_id = p_item_id
		FOR UPDATE;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
 			-- Jatinder - 11/30/06 - Use correct organization to lock migration records. 5690686.
			IF (p_item_source = 'GMI') THEN
				BEGIN
					INSERT INTO ic_item_mst_b_mig(
						item_id,
						organization_id,
						inventory_item_id,
						migrated_ind,
						creation_date,
						created_by,
						last_update_date,
						last_updated_by,
						last_update_login
					)values(
						p_item_id,
						l_master_organization_id,
						NULL,
						0,
						sysdate,
						0,
						sysdate,
						0,
						NULL
					);
				EXCEPTION
					WHEN DUP_VAL_ON_INDEX THEN -- Another parrallel run may have created this row already.
						NULL;
				END;

				-- Lock this row for the parrallel run of this routine.
				SELECT 1
				INTO dv
				FROM ic_item_mst_b_mig
				WHERE
					item_id = p_item_id AND
					organization_id = l_master_organization_id
				FOR UPDATE;
			END IF;
	END;

	-- -- dbms_output.put_line ('Master Org Id = '||to_char(l_master_organization_id)|| ', Migrated Ind = '||to_char(l_migrated_ind_m));
	-- If needed migrate the item in the master organization first.

        -- Bug 5489195 - Need to handle null migrated ind value
	IF (p_mode = 'FORCE' or NVL(l_migrated_ind_m,-1) <> 1) THEN
		-- -- dbms_output.put_line ('Migrate to master org');
		migrate_OPM_item_to_ODM (
			p_migration_run_id,
			p_item_id,
			p_item_code,
			p_item_source,
			l_master_organization_id,
			l_master_organization_id,
			'M',
			p_commit,
			x_inventory_item_id,
			x_failure_count);
		IF (x_failure_count > 0) THEN
			ROLLBACK;
			RETURN;
		END IF;
		-- -- dbms_output.put_line ('Migrated succesfully to master');
	END IF;

	-- Now migrate the OPM item in the chid organization.
	IF (p_organization_id <> l_master_organization_id ) THEN
		-- -- dbms_output.put_line ('Migrate to child org');
		migrate_OPM_item_to_ODM (
			p_migration_run_id,
			p_item_id,
			p_item_code,
			p_item_source,
			p_organization_id,
			l_master_organization_id,
			'C',
			p_commit,
			x_inventory_item_id,
			x_failure_count);
		IF (x_failure_count > 0) THEN
			ROLLBACK;
			RETURN;
		END IF;
		-- -- dbms_output.put_line ('Migrated succesfully to child');
	END IF;

 	-- Jatinder - 11/30/06 - Moved commit here to avoid deadlocks. 5690686.
	-- Autonomous transaction commit
	IF (p_commit <> FND_API.G_FALSE) THEN
		COMMIT;
	ELSE
		ROLLBACK; -- Since this is an autonomous transaction
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEMS',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
		ROLLBACK;
END;

/*====================================================================
--  PROCEDURE:
--    get_ODM_regulatory_item
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to get the Inventory Item Id for
--    an OPM regulatory item.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to write to migration log
--    p_item_code - OPM regulatory item code.
--    p_organization_id - Inventory organization of the item in Oracle
--                   Inventory. Item will be migrated to this organization.
--    p_mode - Use the value 'FORCE' if you want to migrate an OPM item
--             which has been migrated already. Leave it NULL for the normal
--             use.
--    p_commit - flag to indicate if commit should be performed.
--    x_inventory_item_id - Discrete inventory item id.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    get_ODM_regulatory_item(	p_migartion_id		=> l_migration_id,
--		   	p_item_code		=> l_item_code,
--			p_organization_id 	=> l_organization_id,
--			p_mode 			=> NULL,
--			p_commit 		=> 'Y',
--			x_inventory_item_id 	=> l_inventory_item_id,
--			x_failure_count 	=> l_failure_count);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/
PROCEDURE get_ODM_regulatory_item
( p_migration_run_id		IN		NUMBER
, p_item_code			IN		VARCHAR2
, p_organization_id		IN		NUMBER
, p_mode			IN		VARCHAR2
, p_commit			IN		VARCHAR2
, x_inventory_item_id		OUT NOCOPY	NUMBER
, x_failure_count               OUT NOCOPY	NUMBER) IS

BEGIN
	INV_OPM_Item_Migration.get_ODM_item (
		p_migration_run_id => p_migration_run_id,
		p_item_id => NULL,
		p_organization_id => p_organization_id,
		p_mode => p_mode,
		p_commit => p_commit,
		x_inventory_item_id => x_inventory_item_id,
		x_failure_count => x_failure_count,
		p_item_code	=> p_item_code,
		p_item_source	=> 'GR');
END;


/*====================================================================
--  PROCEDURE:
--    migrate_obsolete_columns
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to allow users to migrate the some
--    of the obsolete columns in OPM Item master to the Discrete Item
--    master flexfield. This script will not run automatically during
--    the convergence migration.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to write to migration log
--    p_obsolete_column_name - obsolete column name. Valid values:
--                     o	ALT_ITEMA
--                     o	ALT_ITEMB
--                     o	MATCH_TYPE
--                     o	UPC_CODE
--                     o	QCITEM_ID
--                     o	QCHOLD_RES_CODE
--    p_flexfield_column_name - Descriptive flexfield column.
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_obsolete_columns(p_migartion_id    => l_migration_id,
--                          p_obsolete_column_name => 'UPC_CODE',
-- 			    p_flexfield_column_name => 'ATTRIBUTE15',
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_obsolete_columns
( p_migration_run_id		IN		NUMBER
, p_obsolete_column_name	IN		VARCHAR2
, p_flexfield_column_name	IN		VARCHAR2
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER) IS

l_flexfield_column_name		VARCHAR2(50);
l_end_user_column_name		VARCHAR2(50);
l_migrated_ind			NUMBER(5);
l_count				PLS_INTEGER;
l_migrate_count			PLS_INTEGER;
l_obsolete_column_value		VARCHAR2(240);

CURSOR c_item IS
SELECT m.organization_id, m.inventory_item_id, i.alt_itema,
    i.alt_itemb, i.match_type, i.upc_code, i.qcitem_id,
    i.qchold_res_code
FROM ic_item_mst_b i, ic_item_mst_b_mig m
WHERE
    i.item_id = m.item_id AND
    m.migrated_ind = 1;

BEGIN
	x_failure_count := 0;
	l_migrate_count := 0;
	-- dbms_output.put_line ('Started ITEM OBSOLETE COLUMNS migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'IC_ITEM_MST_B',
		p_context         => 'ITEM OBSOLETE COLUMNS',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');

	IF (p_obsolete_column_name is NULL or p_flexfield_column_name is NULL) THEN
		-- dbms_output.put_line ('Invalid parameters for obsolete column migration');
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMI_MIG_INVALID_PARAMS',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEM OBSOLETE COLUMNS',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
		x_failure_count := x_failure_count + 1;
		RETURN;
	END IF;
	IF ( p_obsolete_column_name <> 'ALT_ITEMA' AND
		p_obsolete_column_name <> 'ALT_ITEMB' AND
		p_obsolete_column_name <> 'MATCH_TYPE' AND
		p_obsolete_column_name <> 'UPC_CODE' AND
		p_obsolete_column_name <> 'QCITEM_ID' AND
		p_obsolete_column_name <> 'QCHOLD_RES_CODE') THEN

		-- dbms_output.put_line ('Invalid value for the obsolete column :' || p_obsolete_column_name);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMI_MIG_INVALID_OBS_COL',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEM OBSOLETE COLUMNS',
			p_param1          => p_obsolete_column_name,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
		x_failure_count := x_failure_count + 1;
		RETURN;
	END IF;

	-- Check if the obsolete column is already mapped / migrated.
	BEGIN
		SELECT flexfield_column_name, migrated_ind
		INTO l_flexfield_column_name, l_migrated_ind
		FROM gmi_obsolete_item_columns
		WHERE
			obsolete_column_name = p_obsolete_column_name AND
			migrated_ind = 1;

		IF ( l_flexfield_column_name <> p_flexfield_column_name ) THEN
			-- dbms_output.put_line ('Obsolete column already migrated to different flexfield column :' || l_flexfield_column_name);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_COL_ALREADY_MIGRATED',
				p_table_name      => 'IC_ITEM_MST_B',
				p_context         => 'ITEM OBSOLETE COLUMNS',
				p_param1          => p_obsolete_column_name,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	END ;

	-- Validate the flexfield column
	BEGIN
		SELECT 1
		INTO l_count
		FROM fnd_tables t, fnd_columns c
		WHERE
			t.application_id = 401 AND
			t.table_name = 'MTL_SYSTEM_ITEMS_B' AND
			t.application_id = c.application_id AND
			t.table_id = c.table_id AND
			c.flexfield_application_id = 401 AND
			c.flexfield_name = 'MTL_SYSTEM_ITEMS' AND
			c.flexfield_usage_code = 'D' AND
			c.column_name = p_flexfield_column_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- dbms_output.put_line ('Invalid value for the flexfield column :' || p_flexfield_column_name);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_INVALID_FLEX_COL',
				p_table_name      => 'IC_ITEM_MST_B',
				p_context         => 'ITEM OBSOLETE COLUMNS',
				p_param1          => p_flexfield_column_name,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
	END;

	-- Check if the desc flexfield column is used for another column
	BEGIN
		SELECT end_user_column_name
		INTO l_end_user_column_name
		FROM fnd_descr_flex_column_usages col2,
			fnd_descr_flex_contexts cont2
		WHERE
			col2.application_id IN (401, 551) and
			col2.descriptive_flexfield_name in ('MTL_SYSTEM_ITEMS', 'ITEM_FLEX') AND
			col2.enabled_flag = 'Y' and
			col2.application_id = cont2.application_id and
			col2.descriptive_flexfield_name = cont2.descriptive_flexfield_name and
			col2.descriptive_flex_context_code = cont2.descriptive_flex_context_code and
			cont2.enabled_flag = 'Y' AND
			col2.application_column_name = p_flexfield_column_name;

		IF (l_end_user_column_name <> p_obsolete_column_name) THEN
			-- dbms_output.put_line ('Flexfield column is already in use : '||p_flexfield_column_name);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_FLEX_COL_IN_USE',
				p_table_name      => 'IC_ITEM_MST_B',
				p_context         => 'ITEM OBSOLETE COLUMNS',
				p_param1          => p_flexfield_column_name,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- Update flexfield definition
			fnd_flex_dsc_api.set_session_mode ('customer_data');
			fnd_flex_dsc_api.create_segment(
				appl_short_name => 'INV',
				flexfield_name => 'MTL_SYSTEM_ITEMS',
				context_name => 'Global Data Elements',
				name => p_obsolete_column_name,
				column => p_flexfield_column_name,
				description => p_obsolete_column_name,
				sequence_number => 100,
				enabled => 'Y',
				displayed => 'Y',
				value_set => NULL,
				default_type => NULL,
				default_value => NULL,
				required => 'N',
				security_enabled => 'N',
				display_size => 50,
				description_size => 50,
				concatenated_description_size => 25,
				list_of_values_prompt => p_obsolete_column_name,
				window_prompt => p_obsolete_column_name,
				range => NULL,
				srw_parameter => NULL,
				runtime_property_function => NULL);
	END;


	-- Migrate the obsolete values
	FOR i in c_item LOOP
		SELECT DECODE (p_obsolete_column_name,
			'ALT_ITEMA', i.ALT_ITEMA,
			'ALT_ITEMB', i.ALT_ITEMB,
			'MATCH_TYPE', i.MATCH_TYPE,
			'UPC_CODE', i.UPC_CODE,
			'QCITEM_ID', i.QCITEM_ID,
			'QCHOLD_RES_CODE', i.QCHOLD_RES_CODE)
		INTO l_obsolete_column_value
		FROM dual
		WHERE rownum = 1;

		UPDATE mtl_system_items_b
		SET
			ATTRIBUTE1 = DECODE (p_flexfield_column_name, 'ATTRIBUTE1', l_obsolete_column_value, ATTRIBUTE1),
			ATTRIBUTE2 = DECODE (p_flexfield_column_name, 'ATTRIBUTE2', l_obsolete_column_value, ATTRIBUTE2),
			ATTRIBUTE3 = DECODE (p_flexfield_column_name, 'ATTRIBUTE3', l_obsolete_column_value, ATTRIBUTE3),
			ATTRIBUTE4 = DECODE (p_flexfield_column_name, 'ATTRIBUTE4', l_obsolete_column_value, ATTRIBUTE4),
			ATTRIBUTE5 = DECODE (p_flexfield_column_name, 'ATTRIBUTE5', l_obsolete_column_value, ATTRIBUTE5),
			ATTRIBUTE6 = DECODE (p_flexfield_column_name, 'ATTRIBUTE6', l_obsolete_column_value, ATTRIBUTE6),
			ATTRIBUTE7 = DECODE (p_flexfield_column_name, 'ATTRIBUTE7', l_obsolete_column_value, ATTRIBUTE7),
			ATTRIBUTE8 = DECODE (p_flexfield_column_name, 'ATTRIBUTE8', l_obsolete_column_value, ATTRIBUTE8),
			ATTRIBUTE9 = DECODE (p_flexfield_column_name, 'ATTRIBUTE9', l_obsolete_column_value, ATTRIBUTE9),
			ATTRIBUTE10 = DECODE (p_flexfield_column_name, 'ATTRIBUTE10', l_obsolete_column_value, ATTRIBUTE10),
			ATTRIBUTE11 = DECODE (p_flexfield_column_name, 'ATTRIBUTE11', l_obsolete_column_value, ATTRIBUTE11),
			ATTRIBUTE12 = DECODE (p_flexfield_column_name, 'ATTRIBUTE12', l_obsolete_column_value, ATTRIBUTE12),
			ATTRIBUTE13 = DECODE (p_flexfield_column_name, 'ATTRIBUTE13', l_obsolete_column_value, ATTRIBUTE13),
			ATTRIBUTE14 = DECODE (p_flexfield_column_name, 'ATTRIBUTE14', l_obsolete_column_value, ATTRIBUTE14),
			ATTRIBUTE15 = DECODE (p_flexfield_column_name, 'ATTRIBUTE15', l_obsolete_column_value, ATTRIBUTE15),
			ATTRIBUTE16 = DECODE (p_flexfield_column_name, 'ATTRIBUTE16', l_obsolete_column_value, ATTRIBUTE16),
			ATTRIBUTE17 = DECODE (p_flexfield_column_name, 'ATTRIBUTE17', l_obsolete_column_value, ATTRIBUTE17),
			ATTRIBUTE18 = DECODE (p_flexfield_column_name, 'ATTRIBUTE18', l_obsolete_column_value, ATTRIBUTE18),
			ATTRIBUTE19 = DECODE (p_flexfield_column_name, 'ATTRIBUTE19', l_obsolete_column_value, ATTRIBUTE19),
			ATTRIBUTE20 = DECODE (p_flexfield_column_name, 'ATTRIBUTE20', l_obsolete_column_value, ATTRIBUTE20),
			ATTRIBUTE21 = DECODE (p_flexfield_column_name, 'ATTRIBUTE21', l_obsolete_column_value, ATTRIBUTE21),
			ATTRIBUTE22 = DECODE (p_flexfield_column_name, 'ATTRIBUTE22', l_obsolete_column_value, ATTRIBUTE22),
			ATTRIBUTE23 = DECODE (p_flexfield_column_name, 'ATTRIBUTE23', l_obsolete_column_value, ATTRIBUTE23),
			ATTRIBUTE24 = DECODE (p_flexfield_column_name, 'ATTRIBUTE24', l_obsolete_column_value, ATTRIBUTE24),
			ATTRIBUTE25 = DECODE (p_flexfield_column_name, 'ATTRIBUTE25', l_obsolete_column_value, ATTRIBUTE25),
			ATTRIBUTE26 = DECODE (p_flexfield_column_name, 'ATTRIBUTE26', l_obsolete_column_value, ATTRIBUTE26),
			ATTRIBUTE27 = DECODE (p_flexfield_column_name, 'ATTRIBUTE27', l_obsolete_column_value, ATTRIBUTE27),
			ATTRIBUTE28 = DECODE (p_flexfield_column_name, 'ATTRIBUTE28', l_obsolete_column_value, ATTRIBUTE28),
			ATTRIBUTE29 = DECODE (p_flexfield_column_name, 'ATTRIBUTE29', l_obsolete_column_value, ATTRIBUTE29),
			ATTRIBUTE30 = DECODE (p_flexfield_column_name, 'ATTRIBUTE30', l_obsolete_column_value, ATTRIBUTE30)
		WHERE
			organization_id = i.organization_id AND
			inventory_item_id = i.inventory_item_id;

		l_migrate_count := l_migrate_count + 1;

		-- Update the mig table.
		UPDATE gmi_obsolete_item_columns
		SET
			migrated_ind = 1,
			last_update_date = sysdate,
			last_updated_by = 0
		WHERE
			obsolete_column_name = p_obsolete_column_name;

		IF SQL%ROWCOUNT = 0 THEN
			INSERT INTO gmi_obsolete_item_columns(
				obsolete_column_name,
				flexfield_column_name,
				migrated_ind,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login
			)values(
				p_obsolete_column_name,
				p_flexfield_column_name,
				1,
				sysdate,
				0,
				sysdate,
				0,
				NULL
			);
		END IF;

		IF (p_commit <> FND_API.G_FALSE) THEN
			COMMIT;
		END IF;
	END LOOP;

	-- dbms_output.put_line ('Completed ITEM OBSOLETE COLUMNS migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'IC_ITEM_MST_B',
		p_context         => 'ITEM OBSOLETE COLUMNS',
		p_param1          => l_migrate_count,
		p_param2          => x_failure_count,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
END;

END INV_OPM_Item_Migration;

/
