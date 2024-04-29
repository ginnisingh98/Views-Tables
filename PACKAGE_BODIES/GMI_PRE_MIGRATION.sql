--------------------------------------------------------
--  DDL for Package Body GMI_PRE_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PRE_MIGRATION" AS
/* $Header: GMIPMIGB.pls 120.1 2005/07/05 09:14:27 jgogna noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPMIGB.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |   Public                                                                 |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIPMIGB                                                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the procedure used for pre-migration validation |
 |    of the OPM convergence migration.                                     |
 |                                                                          |
 | Contents                                                                 |
 |    validate                                                              |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 3/22/05                                    |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

/*====================================================================
--  PROCEDURE:
--    validate_desc_flex_definition
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to validate the conflict
--    in desc flexfield usage for discrete and OPM.
--
--  PARAMETERS:
--    p_opm_desc_flex_name - OPM desc flexfield name
--    p_odm_desc_flex_name - ODM desc flexfield name
--  SYNOPSIS:
--    validate_desc_flex_definition( 'ITEM_FLEX', 'MTL_SYSTEM_ITEMS');
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE validate_desc_flex_definition
( p_migration_run_id		IN	NUMBER,
  p_opm_desc_flex_name		IN	VARCHAR2,
  p_odm_desc_flex_name          IN      VARCHAR2)
IS

CURSOR c_get_desc_flex_col_conflict IS

SELECT col.descriptive_flex_context_code,
	col.application_column_name,
	col.end_user_column_name
FROM fnd_descr_flex_column_usages col,
	fnd_descr_flex_contexts cont
WHERE
	col.application_id = 551 and
	col.descriptive_flexfield_name = p_opm_desc_flex_name and
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
			col2.descriptive_flexfield_name = p_odm_desc_flex_name and
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
	col.descriptive_flexfield_name = p_opm_desc_flex_name and
	col.enabled_flag = 'Y' and
	col.application_id = cont.application_id and
	col.descriptive_flexfield_name = cont.descriptive_flexfield_name and
	col.descriptive_flex_context_code = cont.descriptive_flex_context_code and
	cont.enabled_flag = 'Y';

l_opm_context		VARCHAR2(30);
l_odm_context		VARCHAR2(30);
l_table_name		VARCHAR2(50);
l_context		VARCHAR2(50);
BEGIN
	BEGIN
		IF p_opm_desc_flex_name = 'ITEM_FLEX' THEN
			l_table_name := 'IC_ITEM_MST_B';
			l_context := 'ITEMS';
		ELSIF p_opm_desc_flex_name = 'LOT_FLEX' THEN
			l_table_name := 'IC_LOTS_MST';
			l_context := 'LOTS';
		END IF;
		SELECT cont.descriptive_flex_context_code
		INTO l_opm_context
		FROM fnd_descr_flex_contexts cont
		WHERE cont.application_id = 551 and
			cont.descriptive_flexfield_name = p_opm_desc_flex_name and
			cont.enabled_flag = 'Y' and
			cont.global_flag = 'N' and
			rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	END;
	BEGIN
		SELECT cont.descriptive_flex_context_code
		INTO l_odm_context
		FROM fnd_descr_flex_contexts cont
		WHERE cont.application_id = 401 and
			cont.descriptive_flexfield_name = p_odm_desc_flex_name and
			cont.enabled_flag = 'Y' and
			cont.global_flag = 'N' and
			rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	END;
	IF (l_opm_context is not NULL and l_odm_context is not NULL) THEN
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

		-- dbms_output.put_line ('Desc flexfield column conflict.' || conflict_columns.descriptive_flex_context_code ||', '||conflict_columns.end_user_column_name||', '||conflict_columns.application_column_name);
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

END;

/*====================================================================
--  PROCEDURE:
--    validate
--
--  DESCRIPTION:
--    This package contains the procedure used for pre-migration validation
--    of the OPM convergence migration.
--
--  PARAMETERS:
--
--  SYNOPSIS:
--    validate;
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE validate (
p_migration_run_id	IN	NUMBER) IS

CURSOR c_autolot IS
SELECT count(*) item_count
FROM ic_item_mst_b
WHERE lot_ctl = 1 AND
    autolot_active_indicator <> 1;

CURSOR c_lot_status IS
SELECT i.item_no, l.lot_no, l.sublot_no, w.orgn_code, w.whse_code, inv.location, inv.lot_status
FROM ic_loct_inv inv, ic_item_mst_b i, ic_lots_mst l, ic_whse_mst w
WHERE
    inv.whse_code = w.whse_code AND
    inv.item_id = i.item_id AND
    i.lot_ctl = 1 AND
    inv.item_id = l.item_id AND
    inv.lot_id = l.lot_id AND
    inv.loct_onhand <> 0 AND
    EXISTS (
	SELECT 1
	FROM ic_loct_inv inv2, ic_whse_mst w2
	WHERE
	    inv.whse_code = w2.whse_code AND
	    inv.item_id = inv2.item_id AND
	    inv.lot_id = inv2.lot_id AND
			-- Compare the balances within the mapped org
		DECODE(w.subinventory_ind_flag, 'Y', w.orgn_code, w.whse_code) =
		DECODE(w2.subinventory_ind_flag, 'Y', w2.orgn_code, w2.whse_code) AND
			-- Same locations for whse mapped as subinventory will be created as diff locators.
		inv.whse_code||inv.location <> inv2.whse_code||inv2.location AND
	    inv.lot_status <> inv2.lot_status AND
	    inv2.loct_onhand <> 0)
ORDER by i.item_no, l.lot_no, l.sublot_no, w.orgn_code, w.whse_code, inv.location;

CURSOR c_lot_uniqeness IS
SELECT organization_code
FROM mtl_parameters
WHERE
    (organization_id IN (
        SELECT mtl_organization_id
        FROM ic_whse_mst) OR
    organization_id IN (
        SELECT organization_id
        FROM ic_whse_mst)) AND
    lot_number_uniqueness <> 2;

CURSOR c_org_locator_ctl1 IS
SELECT organization_code
FROM mtl_parameters
WHERE
    (organization_id IN (
        SELECT mtl_organization_id
        FROM ic_whse_mst
	WHERE loct_ctl = 1) OR
    organization_id IN (
        SELECT organization_id
        FROM ic_whse_mst
	WHERE loct_ctl = 1)) AND
    stock_locator_control_code <> 4;

CURSOR c_sub_locator_ctl IS
SELECT distinct p.organization_code, s.secondary_inventory_name
FROM mtl_parameters p,
    mtl_secondary_inventories s,
    mtl_item_locations l,
    ic_loct_mst ol
WHERE
    p.organization_id = s.organization_id AND
    p.organization_id = l.organization_id AND
    s.secondary_inventory_name = l.subinventory_code AND
    l.inventory_location_id = ol.inventory_location_id AND
    s.locator_type <> 5 AND
    (p.organization_id IN (
        SELECT mtl_organization_id
        FROM ic_whse_mst
        WHERE loct_ctl = 1) OR
    p.organization_id IN (
        SELECT organization_id
        FROM ic_whse_mst
        WHERE loct_ctl = 1));

CURSOR c_org_locator_ctl2 IS
SELECT organization_code
FROM mtl_parameters
WHERE
    (organization_id IN (
        SELECT mtl_organization_id
        FROM ic_whse_mst
	WHERE loct_ctl = 0) OR
    organization_id IN (
        SELECT organization_id
        FROM ic_whse_mst
	WHERE loct_ctl = 0)) AND
    stock_locator_control_code <> 1;

CURSOR c_neg_balances IS
SELECT i.item_no, l.lot_no, l.sublot_no, inv.whse_code, inv.location,
    inv.loct_onhand, inv.loct_onhand2
FROM ic_loct_inv inv,
    ic_item_mst_b i,
    ic_lots_mst l
WHERE
    inv.item_id = i.item_id AND
    inv.item_id = l.item_id AND
    inv.lot_id = l.lot_id AND
    ROUND(loct_onhand, 5) <> 0 AND
    DECODE(i.dualum_ind, 0, 99999, ROUND(loct_onhand2, 5)) <> 0 AND
    loct_onhand < 0 AND
    DECODE(i.dualum_ind, 0, 99999, loct_onhand2) < 0;

CURSOR c_mix_balances IS
SELECT i.item_no, l.lot_no, l.sublot_no, inv.whse_code, inv.location,
    inv.loct_onhand, inv.loct_onhand2
FROM ic_loct_inv inv,
    ic_item_mst_b i,
    ic_lots_mst l
WHERE
    inv.item_id = i.item_id AND
    inv.item_id = l.item_id AND
    inv.lot_id = l.lot_id AND
    ROUND(loct_onhand, 5) <> 0 AND
    ROUND(loct_onhand2, 5) <> 0 AND
    i.dualum_ind <> 0 AND
    loct_onhand/ABS(loct_onhand) <> loct_onhand2/ABS(loct_onhand2);

CURSOR c_decimal_dust_balances IS
SELECT i.item_no, l.lot_no, l.sublot_no, inv.whse_code, inv.location,
    inv.loct_onhand, inv.loct_onhand2
FROM ic_loct_inv inv,
    ic_item_mst_b i,
    ic_lots_mst l
WHERE
    inv.item_id = i.item_id AND
    inv.item_id = l.item_id AND
    inv.lot_id = l.lot_id AND
    ROUND(loct_onhand, 5) = 0 AND
    DECODE(i.dualum_ind, 0, 99999, ROUND(loct_onhand2, 5)) = 0 AND
    (loct_onhand <> 0 OR loct_onhand2 <> 0);

CURSOR c_non_inv_balances IS
SELECT i.item_no, l.lot_no, l.sublot_no, inv.whse_code, inv.location,
    inv.loct_onhand, inv.loct_onhand2
FROM ic_loct_inv inv,
    ic_item_mst_b i,
    ic_lots_mst l
WHERE
    inv.item_id = i.item_id AND
    i.noninv_ind = 1 AND
    inv.item_id = l.item_id AND
    inv.lot_id = l.lot_id AND
    ROUND(loct_onhand, 5) <> 0 ;

CURSOR c_in_transit_transfers IS
select orgn_code, transfer_no
from ic_xfer_mst
WHERE
    transfer_status = 2 AND
    delete_mark = 0;

l_delimiter	VARCHAR2(1);

BEGIN
	-- Check the items which do not have auto lot numbering setup
	FOR i IN c_autolot LOOP
		-- dbms_output.put_line ('Number of lot controlled items without autolot numbering setup : '|| to_char(i.item_count));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_ITEM_AUTOLOT',
			p_table_name      => 'IC_ITEM_MST_B',
			p_context         => 'ITEMS',
			p_param1          => to_char(i.item_count),
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- Validate the descriptive flexfield conflicts for items and lots.
	validate_desc_flex_definition (p_migration_run_id, 'ITEM_FLEX', 'MTL_SYSTEM_ITEMS');
	validate_desc_flex_definition (p_migration_run_id, 'LOTS_FLEX', 'MTL_LOT_NUMBERS');

	-- Show any lots with multiple status in different locations.
	FOR ls IN c_lot_status LOOP
		l_delimiter := NULL;
		IF ls.sublot_no is not NULL THEN
			l_delimiter := '-';
		END IF;
		-- dbms_output.put_line ('Lot with multiple status. Item, Lot-Sublot, Whse, Location, Status : '|| ls.item_no||', '||ls.lot_no||l_delimiter||ls.sublot_no||', '||ls.whse_code||', '||ls.location||', '||ls.lot_status);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_MULTIPLE_STATUS_LOT',
			p_table_name      => 'IC_LOTS_MST',
			p_context         => 'LOTS',
			p_param1          => ls.item_no,
			p_param2          => ls.lot_no||l_delimiter||ls.sublot_no,
			p_param3          => ls.whse_code,
			p_param4          => ls.location,
			p_param5          => ls.lot_status,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- Validate the lot uniqueness for the existing process enabled organizations.
	FOR lu IN c_lot_uniqeness LOOP
		-- dbms_output.put_line ('Lot uniqueness not set to NONE for the organization : '||lu.organization_code);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_INCORRECT_LOT_UNIQ',
			p_table_name      => 'IC_LOTS_MST',
			p_context         => 'LOTS',
			p_param1          => lu.organization_code,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- Validate the discrete locator control

	FOR dl1 IN c_org_locator_ctl1 LOOP
		-- dbms_output.put_line ('Locator control not set to Determine at Subinventory for organization corresponding to location controlled OPM warehouses : '||dl1.organization_code);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_INCORRECT_LOCT_CTL',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCES',
			p_param1          => dl1.organization_code,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	FOR dl1 IN c_sub_locator_ctl LOOP
		-- dbms_output.put_line ('Locator control not set to Item Level for subinventory corresponding to OPM warehouse locators : '||dl1.organization_code||', '||dl1.secondary_inventory_name);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_INCORRECT_SUB_LOCT_CTL',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCES',
			p_param1          => dl1.organization_code,
			p_param2          => dl1.secondary_inventory_name,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	FOR dl2 IN c_org_locator_ctl2 LOOP
		-- dbms_output.put_line ('Locator control not set to None for organization corresponding to non-location controlled OPM warehouses : '||dl2.organization_code);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_INCORRECT_NON_LOCT_CTL',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCES',
			p_param1          => dl2.organization_code,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- Show the negative OPM inventory balances.

	FOR nb IN c_neg_balances LOOP
		-- dbms_output.put_line ('Negative balances exists for item, lot, sublot, whse, location : '||nb.item_no||', '||nb.lot_no||', '||nb.sublot_no||', '||nb.whse_code||', '||nb.location);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_NEG_BALANCES',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCES',
			p_param1          => nb.item_no,
			p_param2          => nb.lot_no,
			p_param3          => nb.sublot_no,
			p_param4          => nb.whse_code,
			p_param5          => nb.location,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- Show any OPM balances for dual controlled items which are positive for
	-- primary and negative for secondary or vice-versa.

	FOR mb IN c_mix_balances LOOP
		-- dbms_output.put_line ('Mixed balances for dual quantity exists for item, lot, sublot, whse, location : '||mb.item_no||', '||mb.lot_no||', '||mb.sublot_no||', '||mb.whse_code||', '||mb.location);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_MIX_BALANCES',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCES',
			p_param1          => mb.item_no,
			p_param2          => mb.lot_no,
			p_param3          => mb.sublot_no,
			p_param4          => mb.whse_code,
			p_param5          => mb.location,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');

	END LOOP;

	-- Show any decimal dust kind of balances that will not be migrated for convergence.

	FOR db IN c_decimal_dust_balances LOOP
		-- dbms_output.put_line ('Decimal dust balances exists for item, lot, sublot, whse, location : '||db.item_no||', '||db.lot_no||', '||db.sublot_no||', '||db.whse_code||', '||db.location);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_DUST_BALANCES',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCES',
			p_param1          => db.item_no,
			p_param2          => db.lot_no,
			p_param3          => db.sublot_no,
			p_param4          => db.whse_code,
			p_param5          => db.location,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- Display balances for non-inv items
	FOR nb IN c_non_inv_balances LOOP
		-- dbms_output.put_line ('Inventory balances exists for non-inventory item, lot, sublot, whse, location : '||nb.item_no||', '||nb.lot_no||', '||nb.sublot_no||', '||nb.whse_code||', '||nb.location);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_NEG_BALANCES',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCES',
			p_param1          => nb.item_no,
			p_param2          => nb.lot_no,
			p_param3          => nb.sublot_no,
			p_param4          => nb.whse_code,
			p_param5          => nb.location,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- Display in-transit transfers
	FOR tb IN c_in_transit_transfers LOOP
		-- dbms_output.put_line ('In Transit transfer exists : ' || tb.orgn_code ||' '||tb.transfer_no);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_INTRANS_BALANCES',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCES',
			p_param1          => tb.orgn_code ||' '||tb.transfer_no,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');

	END LOOP;

END;

END GMI_Pre_Migration;

/
