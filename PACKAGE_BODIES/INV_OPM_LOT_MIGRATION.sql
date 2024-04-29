--------------------------------------------------------
--  DDL for Package Body INV_OPM_LOT_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_OPM_LOT_MIGRATION" AS
/* $Header: INVLTMGB.pls 120.16 2008/02/27 18:05:20 rlnagara ship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    INVLTMGB.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    INV_OPM_Lot_Migration                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the procedure used for lot migration for OPM    |
 |    convergence project. These procedure are meant for migration only.    |
 |                                                                          |
 | Contents                                                                 |
 |    get_ODM_lot                                                           |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 3/22/05                                    |
 |                                                                          |
 |    Jatinder - 11/30/06 - Use correct balance status from ic_lots_mst_mig |
 |             B5690654                                                     |
 |                                                                          |
 +==========================================================================+
*/

/*  Global variables */
g_init_mig		PLS_INTEGER;
g_lot_id		NUMBER;
g_item_id		NUMBER;
g_whse_code		VARCHAR2(4);
g_orgn_code		VARCHAR2(4);
g_location		VARCHAR2(16);
g_organization_id	NUMBER;
g_lot_number		VARCHAR2(80);
g_parent_lot_number	VARCHAR2(80);
g_desc_flex_conflict	PLS_INTEGER;
g_attribute_context	PLS_INTEGER;
g_attribute1	PLS_INTEGER;
g_attribute2	PLS_INTEGER;
g_attribute3	PLS_INTEGER;
g_attribute4	PLS_INTEGER;
g_attribute5	PLS_INTEGER;
g_attribute6	PLS_INTEGER;
g_attribute7	PLS_INTEGER;
g_attribute8	PLS_INTEGER;
g_attribute9	PLS_INTEGER;
g_attribute10	PLS_INTEGER;
g_attribute11	PLS_INTEGER;
g_attribute12	PLS_INTEGER;
g_attribute13	PLS_INTEGER;
g_attribute14	PLS_INTEGER;
g_attribute15	PLS_INTEGER;
g_attribute16	PLS_INTEGER;
g_attribute17	PLS_INTEGER;
g_attribute18	PLS_INTEGER;
g_attribute19	PLS_INTEGER;
g_attribute20	PLS_INTEGER;
g_attribute21	PLS_INTEGER;
g_attribute22	PLS_INTEGER;
g_attribute23	PLS_INTEGER;
g_attribute24	PLS_INTEGER;
g_attribute25	PLS_INTEGER;
g_attribute26	PLS_INTEGER;
g_attribute27	PLS_INTEGER;
g_attribute28	PLS_INTEGER;
g_attribute29	PLS_INTEGER;
g_attribute30	PLS_INTEGER;


/*====================================================================
--  PROCEDURE:
--    migrate_OPM_lot_to_ODM
--
--  DESCRIPTION:
--    Internal routine to migrate OPM lots to Oracle inventory.
--    This procedure should not be called on its own. Call the
--    get_ODM_lot procedure instead.
--
--  PARAMETERS:
--
--  SYNOPSIS:
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--   RLNAGARA Bug 6607319 Status is passed as NULL for Material Status Migration ME
--====================================================================*/

PROCEDURE migrate_OPM_lot_to_ODM
( p_migration_run_id		IN		NUMBER
, p_item_id                     IN              NUMBER
, p_lot_id                      IN              NUMBER
, p_organization_id             IN              NUMBER
, p_whse_code                   IN              VARCHAR2
, p_location                    IN              VARCHAR2
, p_lot_status                  IN              VARCHAR2
, p_commit                      IN              VARCHAR2
, x_lot_number                  IN OUT NOCOPY      VARCHAR2
, x_parent_lot_number           IN OUT NOCOPY      VARCHAR2
, x_failure_count               OUT NOCOPY	NUMBER
) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_lot_rec			mtl_lot_numbers%ROWTYPE;
  o_lot_rec			mtl_lot_numbers%ROWTYPE;
  o_item_rec			INV_ITEM_API.Item_rec_type;
  -- l_error_tbl			INV_ITEM_API.Error_tbl_type;
  l_opm_lot			ic_lots_mst%ROWTYPE;
  l_inventory_item_id		NUMBER;
  l_count			NUMBER;
  l_lot_number			VARCHAR2(80);
  l_parent_lot_number		VARCHAR2(80);
  l_status_ctl			NUMBER;
  l_default_status		VARCHAR2(4);
  l_lot_status			VARCHAR2(4);
  l_whse_orgn_code		VARCHAR2(4);
  l_status_id			NUMBER;
  l_maturity_date		DATE;
  l_hold_date			DATE;

  l_return_status               VARCHAR2(10);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);
  l_field_name			VARCHAR(50);
  l_field_value                 VARCHAR(50);
  v_rowid 			varchar2(1000);
  i				PLS_INTEGER;

BEGIN
	x_failure_count := 0;
	-- Get the OPM Lot Master Details
	BEGIN
		SELECT * INTO l_opm_lot
		FROM ic_lots_mst
		WHERE item_id = p_item_id and
			lot_id = p_lot_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- Log error
			-- dbms_output.put_line ('Invalid Lot id : '||to_char(p_lot_id));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_INVALID_LOT_ID',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_param1          => INV_GMI_Migration.lot(p_lot_id),
				p_param2          => INV_GMI_Migration.item(p_item_id),
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
	END;

	-- Check if the item has already been migrated to discrete
	BEGIN
		INV_OPM_Item_Migration.get_ODM_item (
			p_migration_run_id => p_migration_run_id,
			p_item_id => p_item_id,
			p_organization_id => p_organization_id,
			p_mode => NULL,
			p_commit => FND_API.G_TRUE,
			x_inventory_item_id => l_inventory_item_id,
			x_failure_count => x_failure_count);
		IF (x_failure_count > 0) THEN
			-- Log Error
			-- dbms_output.put_line ('Item migration failed for Item id : '||to_char(p_item_id));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_ITEM_MIG_FAILED',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_param1          => INV_GMI_Migration.org(p_organization_id),
				p_param2          => INV_GMI_Migration.item(p_item_id),
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
		END IF;
	END;


	-- Set local variables based upon OPM lot master definition
	BEGIN
		-- Get lot numbers for discrete
		l_lot_status := p_lot_status;
		IF (x_lot_number is NULL) THEN
			l_field_name := 'GMI Migration Parameters';
			l_field_value := NULL;
			SELECT l_opm_lot.lot_no || DECODE (l_opm_lot.sublot_no, NULL, NULL,
                  		(SELECT lot_sublot_delimiter FROM gmi_migration_parameters)) ||
        			l_opm_lot.sublot_no,
				DECODE(sublot_ctl, 1, DECODE(l_opm_lot.sublot_no, NULL, NULL,
					l_opm_lot.lot_no)),
				status_ctl, lot_status
			INTO x_lot_number, x_parent_lot_number, l_status_ctl, l_default_status
			FROM ic_item_mst_b
			WHERE
				item_id = p_item_id;

			-- Get the inventory status for the lot
			IF (l_status_ctl = 1) THEN
			BEGIN
				SELECT lot_status
				INTO l_lot_status
				FROM ic_loct_inv
				WHERE
					item_id = p_item_id and
					lot_id = p_lot_id and
					whse_code = p_whse_code and
					rownum = 1;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
			END IF;
			-- insert it into ic_lots_mst_mig table
			IF (l_lot_status is NULL) THEN
				l_lot_status := l_default_status;
			END IF;
			INSERT into ic_lots_mst_mig (
			         item_id,
			         lot_id,
			         organization_id,
			         whse_code,
			         location,
			         status,
			         parent_lot_number,
			         lot_number,
			         migrated_ind,
			         additional_status_lot,
			         user_updated_ind,
			         creation_date,
			         created_by,
			         last_update_date,
			         last_updated_by,
			         last_update_login)
			VALUES (
			         p_item_id,
			         p_lot_id,
			         p_organization_id,
			         p_whse_code,
			         p_location,      --rlnagara 2 Material Status Migration ME - dont know why NULL was passed here even though we had location value.
			         l_lot_status,    --rlnagara 2 Material Status Migration ME - dont know why NULL was passed here even though we had lot status value.
			         x_parent_lot_number,
			         x_lot_number,
			         0,
			         0,
			         -1,
			         sysdate,
			         0,
			         sysdate,
			         0,
			         NULL);

		END IF;

		-- Get CPG fields
		l_field_name := 'Maturity and Hold Days';
		l_field_value := to_char(p_lot_id);
		BEGIN
			SELECT ic_matr_date, ic_hold_date
			INTO l_maturity_date, l_hold_date
			FROM ic_lots_cpg
			WHERE
				item_id = p_item_id AND
				lot_id = p_lot_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;


		/* rlnagara 2 Material Status Migration ME - As we are passing status_id as NULL while creating the l_lot_rec, below code is not needed.
		-- Get status id
		-- Jatinder - 11/30/06 - Use correct balance status from ic_lots_mst_mig B5690654
		l_status_id := NULL;
		IF (l_lot_status IS NOT NULL) THEN
			l_field_name := 'Lot Status Id';
			l_field_value := l_lot_status;
			l_field_name := 'Lot Status';
			SELECT status_id
			INTO l_status_id
			FROM ic_lots_sts
			WHERE
				lot_status = l_lot_status;
		END IF;
		*/

	EXCEPTION
                WHEN NO_DATA_FOUND THEN
			-- dbms_output.put_line ('Could not find '||l_field_name||' for '||l_field_value);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_NO_DATA_FOR_FIELD',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_param1          => l_field_name,
				p_param2          => l_field_value,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
        END;

	-- Prepare the data for the Lot creation
	l_lot_rec.INVENTORY_ITEM_ID := l_inventory_item_id;
	l_lot_rec.ORGANIZATION_ID := p_organization_id;
	l_lot_rec.LOT_NUMBER := x_lot_number;
	l_lot_rec.EXPIRATION_DATE := l_opm_lot.expire_date;
	l_lot_rec.DISABLE_FLAG := NULL;
	IF (l_opm_lot.inactive_ind = 1 or l_opm_lot.delete_mark = 1) THEN
		l_lot_rec.DISABLE_FLAG := 1;
	END IF;
	l_lot_rec.REQUEST_ID := NULL;
	l_lot_rec.PROGRAM_APPLICATION_ID := NULL;
	l_lot_rec.PROGRAM_ID := NULL;
	l_lot_rec.PROGRAM_UPDATE_DATE := NULL;
	l_lot_rec.GEN_OBJECT_ID := NULL;
	l_lot_rec.DESCRIPTION := l_opm_lot.lot_desc;
	l_lot_rec.VENDOR_NAME := NULL;
	l_lot_rec.SUPPLIER_LOT_NUMBER := NULL;
	l_lot_rec.GRADE_CODE := l_opm_lot.qc_grade;
	l_lot_rec.ORIGINATION_DATE := l_opm_lot.lot_created;
	l_lot_rec.DATE_CODE := NULL;
	l_lot_rec.STATUS_ID := NULL;   --RLNAGARA Material Status Migration ME - Status is not passed.
	l_lot_rec.CHANGE_DATE := NULL;
	l_lot_rec.AGE := NULL;
	l_lot_rec.VENDOR_ID := NULL;
	l_lot_rec.TERRITORY_CODE := NULL;
	l_lot_rec.PARENT_LOT_NUMBER := x_parent_lot_number;
	l_lot_rec.ORIGINATION_TYPE := l_opm_lot.origination_type;
	l_lot_rec.EXPIRATION_ACTION_CODE := l_opm_lot.expaction_code;
	IF (l_opm_lot.expaction_date < l_lot_rec.ORIGINATION_DATE) THEN
		l_lot_rec.EXPIRATION_ACTION_DATE := l_lot_rec.ORIGINATION_DATE;
	ELSE
		l_lot_rec.EXPIRATION_ACTION_DATE := l_opm_lot.expaction_date;
	END IF;
	IF (l_opm_lot.retest_date < l_lot_rec.ORIGINATION_DATE) THEN
		l_lot_rec.RETEST_DATE := l_lot_rec.ORIGINATION_DATE;
	ELSE
		l_lot_rec.RETEST_DATE := l_opm_lot.retest_date;
	END IF;
	IF (l_hold_date < l_lot_rec.ORIGINATION_DATE) THEN
		l_lot_rec.HOLD_DATE := l_lot_rec.ORIGINATION_DATE;
	ELSE
		l_lot_rec.HOLD_DATE := l_hold_date;
	END IF;
	IF (l_maturity_date < l_lot_rec.ORIGINATION_DATE) THEN
		l_lot_rec.MATURITY_DATE := l_lot_rec.ORIGINATION_DATE;
	ELSE
		l_lot_rec.MATURITY_DATE := l_maturity_date;
	END IF;
	-- l_lot_rec.INVENTORY_ATP_CODE := NULL; -- ????
	-- l_lot_rec.RESERVABLE_TYPE := NULL; -- ????
	-- l_lot_rec.AVAILABILITY_TYPE := NULL; -- ????


	IF (g_attribute_context = 1 and l_lot_rec.ATTRIBUTE_CATEGORY is NULL) THEN
		l_lot_rec.ATTRIBUTE_CATEGORY := l_opm_lot.attribute_category;
	END IF;
	IF (g_attribute1 = 1 and l_lot_rec.attribute1 is NULL) THEN l_lot_rec.attribute1 := l_opm_lot.attribute1; END IF;
	IF (g_attribute2 = 1 and l_lot_rec.attribute2 is NULL) THEN l_lot_rec.attribute2 := l_opm_lot.attribute2; END IF;
	IF (g_attribute3 = 1 and l_lot_rec.attribute3 is NULL) THEN l_lot_rec.attribute3 := l_opm_lot.attribute3; END IF;
	IF (g_attribute4 = 1 and l_lot_rec.attribute4 is NULL) THEN l_lot_rec.attribute4 := l_opm_lot.attribute4; END IF;
	IF (g_attribute5 = 1 and l_lot_rec.attribute5 is NULL) THEN l_lot_rec.attribute5 := l_opm_lot.attribute5; END IF;
	IF (g_attribute6 = 1 and l_lot_rec.attribute6 is NULL) THEN l_lot_rec.attribute6 := l_opm_lot.attribute6; END IF;
	IF (g_attribute7 = 1 and l_lot_rec.attribute7 is NULL) THEN l_lot_rec.attribute7 := l_opm_lot.attribute7; END IF;
	IF (g_attribute8 = 1 and l_lot_rec.attribute8 is NULL) THEN l_lot_rec.attribute8 := l_opm_lot.attribute8; END IF;
	IF (g_attribute9 = 1 and l_lot_rec.attribute9 is NULL) THEN l_lot_rec.attribute9 := l_opm_lot.attribute9; END IF;
	IF (g_attribute10 = 1 and l_lot_rec.attribute10 is NULL) THEN l_lot_rec.attribute10 := l_opm_lot.attribute10; END IF;
	IF (g_attribute11 = 1 and l_lot_rec.attribute11 is NULL) THEN l_lot_rec.attribute11 := l_opm_lot.attribute11; END IF;
	IF (g_attribute12 = 1 and l_lot_rec.attribute12 is NULL) THEN l_lot_rec.attribute12 := l_opm_lot.attribute12; END IF;
	IF (g_attribute13 = 1 and l_lot_rec.attribute13 is NULL) THEN l_lot_rec.attribute13 := l_opm_lot.attribute13; END IF;
	IF (g_attribute14 = 1 and l_lot_rec.attribute14 is NULL) THEN l_lot_rec.attribute14 := l_opm_lot.attribute14; END IF;
	IF (g_attribute15 = 1 and l_lot_rec.attribute15 is NULL) THEN l_lot_rec.attribute15 := l_opm_lot.attribute15; END IF;

	l_lot_rec.CREATION_DATE := SYSDATE;
	l_lot_rec.CREATED_BY := l_opm_lot.created_by;
	l_lot_rec.LAST_UPDATE_DATE := SYSDATE;
	l_lot_rec.LAST_UPDATED_BY := l_opm_lot.last_updated_by;
	l_lot_rec.LAST_UPDATE_LOGIN := -1;

	-- Check if the lot already exists
	SELECT count(*)
	INTO l_count
	FROM mtl_lot_numbers
	WHERE
		organization_id = p_organization_id AND
		inventory_item_id = l_inventory_item_id AND
		lot_number = x_lot_number;

	IF (l_count > 0) THEN
		-- Log error (warning)
		-- dbms_output.put_line ('Lot already exists for org id, item id, lot num : '||to_char(p_organization_id)||', '||to_char(l_inventory_item_id)||', '||x_lot_number);
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_LOT_ALREADY_EXISTS',
			p_table_name      => 'IC_LOTS_MST',
			p_context         => 'LOTS',
			p_param1          => INV_GMI_Migration.org(p_organization_id),
			p_param2          => INV_GMI_Migration.ditem(p_organization_id,l_inventory_item_id),
			p_param3          => x_lot_number,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	ELSE -- migrate the lot
		-- Call the API to create the lot

		INV_LOT_API_PUB.Create_Inv_lot (
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			x_row_id => v_rowid,
			x_lot_rec => o_lot_rec,
			p_lot_rec => l_lot_rec,
			p_source => NULL,
			p_api_version => 1.0,
			p_origin_txn_id => NULL);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			-- Log Error
			x_failure_count := x_failure_count + 1;
			FOR i in 1..l_msg_count LOOP
				-- dbms_output.put_line (substr(fnd_msg_pub.get_detail(i, NULL),1,255));
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_UNEXPECTED_ERROR',
					p_table_name      => 'IC_LOTS_MST',
					p_context         => 'LOTS',
					p_token1	  => 'ERROR',
					p_param1          => fnd_msg_pub.get_detail(i, NULL),
					p_param2          => NULL,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
			END LOOP;
			ROLLBACK;
			RETURN;
		END IF;

		-- Lot created successfully
		g_lot_number := x_lot_number;
		g_parent_lot_number := x_parent_lot_number;
	END IF;

	IF p_whse_code IS NOT NULL THEN
		SELECT orgn_code INTO l_whse_orgn_code
		FROM ic_whse_mst
		WHERE whse_code = p_whse_code;
	END IF;

	UPDATE ic_lots_mst_mig
	SET
		organization_id = p_organization_id,
		migrated_ind = 1,
		last_update_date = sysdate,
		last_updated_by = 0
	WHERE
		( organization_id = p_organization_id OR
		  (organization_id IS NULL AND                     -- whse mapped to subinventory
			whse_mapping_code = l_whse_orgn_code) OR
		  (organization_id IS NULL AND nvl(whse_mapping_code, ' ') <> l_whse_orgn_code AND
			whse_code = p_whse_code)) AND              -- whse not a subinventory
		lot_number = g_lot_number and
		item_id = p_item_id and		-- Added this to use index.
		lot_id = p_lot_id;		-- Added this to use index.

	-- Autonomous transaction commit
	IF (p_commit <> FND_API.G_FALSE) THEN
		COMMIT;
	ELSE
		ROLLBACK;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		RAISE;
END;

/*====================================================================
--  PROCEDURE:
--    validate_desc_flex_definition
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to validate the conflict
--    in desc flexfield usage for discrete and OPM Lots.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--
--  SYNOPSIS:
--    validate_desc_flex_definition(p_migartion_id    => l_migration_id);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE validate_desc_flex_definition
	(p_migration_run_id	IN	NUMBER) IS

CURSOR c_get_desc_felx_col_conflict IS

SELECT col.descriptive_flex_context_code,
	col.application_column_name,
	col.end_user_column_name
FROM fnd_descr_flex_column_usages col,
	fnd_descr_flex_contexts cont
WHERE
	col.application_id = 551 and
	col.descriptive_flexfield_name = 'LOTS_FLEX' and
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
			col2.descriptive_flexfield_name = 'MTL_LOT_NUMBERS' and
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
	col.descriptive_flexfield_name = 'LOTS_FLEX' and
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
			cont.descriptive_flexfield_name = 'LOTS_FLEX' and
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
			cont.descriptive_flexfield_name = 'MTL_LOT_NUMBERS' and
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
			p_table_name      => 'IC_LOTS_MST',
			p_context         => 'LOTS',
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

	FOR conflict_columns in c_get_desc_felx_col_conflict LOOP
		-- If we are here, that means we have a conflict
		g_desc_flex_conflict := 1;

		-- dbms_output.put_line ('Desc flexfield column conflict.');
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMI_MIG_DFLEX_CONTEXT_CONFLICT',
			p_table_name      => 'IC_LOTS_MST',
			p_context         => 'LOTS',
			p_param1          => conflict_columns.descriptive_flex_context_code,
			p_param2          => conflict_columns.end_user_column_name,
			p_param3          => conflict_columns.application_column_name,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
	END LOOP;

	-- If no conflict is found, set the control variable for item migration
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
--    get_ODM_lot
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to get the lot number for
--    an OPM lot. If the OPM lot is not migrated, it will migrate the
--    the lot and return the discrete lot number.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_inventory_item_id - Discrete item id.
--    p_lot_no - OPM Lot No
--    p_sublot_no - OPM SubLot No
--    p_organization_id - Inventory organization of the lot in Oracle
--                   Inventory. Lot will be migrated to this organization.
--    p_locator_id - Locator ( corresponding to OPM loction) where this
--                   lot exists.
--    p_commit - flag to indicate if commit should be performed.
--    x_lot_number - Discrete Lot Number
--    x_parent_lot_number - Discrete Parent Lot Number
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    get_ODM_lot(	p_migartion_id		=> l_migration_id,
--		   	p_inventory_item_id	=> l_inventory_item_id,
--		   	p_lot_no		=> l_lot_no,
--		   	p_sublot_no		=> l_sublot_no,
--			p_organization_id 	=> l_organization_id,
--			p_locator_id	 	=> l_locator_id,
--			p_commit 		=> FND_API.G_TRUE,
--			x_lot_number	 	=> l_lot_number,
--			x_parent_lot_number 	=> l_parent_lot_number,
--			x_failure_count 	=> l_failure_count);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE get_ODM_lot
( p_migration_run_id		IN		NUMBER
, p_inventory_item_id		IN		NUMBER
, p_lot_no			IN		VARCHAR2
, p_sublot_no			IN		VARCHAR2
, p_organization_id		IN		NUMBER
, p_locator_id			IN		NUMBER
, p_commit			IN		VARCHAR2
, x_lot_number			OUT NOCOPY	VARCHAR2
, x_parent_lot_number		OUT NOCOPY	VARCHAR2
, x_failure_count               OUT NOCOPY	NUMBER) IS

l_item_id		NUMBER;
l_lot_id		NUMBER;
l_loc_organization_id	NUMBER;
l_whse_code		VARCHAR2(4);
l_location_whse		VARCHAR2(4);
l_location		VARCHAR2(16);
l_field_name		VARCHAR(50);
l_field_value		VARCHAR(50);
BEGIN
	x_failure_count := 0;
	BEGIN
		l_field_name := 'Matching OPM Item';
		l_field_value := to_char(p_organization_id) ||', '||to_char(p_inventory_item_id);
		SELECT i.item_id
		INTO l_item_id
		FROM ic_item_mst_b i, mtl_system_items_b d
		WHERE
			d.organization_id = p_organization_id AND
			d.inventory_item_id = p_inventory_item_id AND
			d.segment1 = i.item_no;

		l_field_name := 'OPM Lot id';
		l_field_value := p_lot_no;
		SELECT lot_id
		INTO l_lot_id
		FROM ic_lots_mst
		WHERE
			item_id = l_item_id AND
			lot_no = p_lot_no AND
			nvl(sublot_no, ' ') = nvl(p_sublot_no, ' ');

		l_field_name := 'Migrated Warehouse';
		l_field_value := p_organization_id;

		-- 5412510 - Added ROWNUM as there can be multiple whse for the id
		-- when whse is migrated as the subinventory
		-- The whse is later used to get the organization_id back.
		SELECT whse_code
		INTO l_whse_code
		FROM ic_whse_mst
		WHERE
			organization_id = p_organization_id AND
			migrated_ind = 1 AND
			ROWNUM = 1;

		IF (p_locator_id is not NULL) THEN
			l_field_name := 'Migrated warehouse locations';
			l_field_value := p_locator_id;

			SELECT l.whse_code, l.location, w.organization_id
			INTO l_location_whse, l_location, l_loc_organization_id
			FROM ic_loct_mst l, ic_whse_mst w
			WHERE
				inventory_location_id = p_locator_id AND
				l.whse_code = w.whse_code;

			-- If multiple warehouses were mapped to an organization, choose the one
			-- for the locator used in the call.
			IF l_loc_organization_id = p_organization_id THEN
				l_whse_code := l_location_whse;
			END IF;

			IF (l_location_whse <> l_whse_code) THEN
				-- Log Error
				-- dbms_output.put_line ('Warehouse for the orgnization and loctor id do not match. org id, org_whse, locator id, whse :'||to_char(p_organization_id)||', '||l_whse_code||', '||to_char(p_locator_id)||', '||l_location_whse);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_DIFF_ORG_LOC_WHSE',
					p_table_name      => 'IC_LOTS_MST',
					p_context         => 'LOTS',
					p_param1          => INV_GMI_Migration.org(p_organization_id),
					p_param2          => l_whse_code,
					p_param3          => to_char(p_locator_id),
					p_param4          => l_location_whse,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				x_failure_count := x_failure_count + 1;
				RETURN;
			END IF;
		END IF;

		-- Call the main routine
		INV_OPM_Lot_Migration.get_ODM_lot(
			p_migration_run_id => p_migration_run_id,
			p_item_id => l_item_id,
			p_lot_id => l_lot_id,
			p_whse_code => l_whse_code,
			p_orgn_code => NULL,
			p_location => l_location,
			p_commit => p_commit,
			x_lot_number => x_lot_number,
			x_parent_lot_number => x_parent_lot_number,
			x_failure_count => x_failure_count);
	EXCEPTION
                WHEN NO_DATA_FOUND THEN
			-- dbms_output.put_line ('Could not find '||l_field_name||' for '||l_field_value);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_NO_DATA_FOR_FIELD',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_param1          => l_field_name,
				p_param2          => l_field_value,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
        END;
END;

/*====================================================================
--  PROCEDURE:
--    get_ODM_lot
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to get the lot number for
--    an OPM lot. If the OPM lot is not migrated, it will migrate the
--    the lot and return the discrete lot number.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_item_id - OPM item id.
--    p_lot_no - OPM Lot No
--    p_sublot_no - OPM SubLot No
--    p_whse_code - OPM warehouse for the lot. Lot will be migrated to
--                   the organization created for the OPM warehouse.
--                   If p_whse_code is specified then p_orgn_code is
--                   ignored.
--    p_orgn_code - OPM organization for the lot. Lot will be migrated to
--                   the organization created for the OPM organization.
--    p_location - OPM location where the lot exist.
--    p_get_parent_only - A value of 1 indicate to only return the parent lot.
--                A value of 0 indicate to return both lot and the parent lot.
--    p_commit - flag to indicate if commit should be performed.
--    x_lot_number - Discrete Lot Number
--    x_parent_lot_number - Discrete Parent Lot Number
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    get_ODM_lot(	p_migartion_id		=> l_migration_id,
--		   	p_item_id		=> l_item_id,
--		   	p_lot_no		=> l_lot_no,
--		   	p_sublot_no		=> l_sublot_no,
--			p_whse_code	 	=> l_whse_code,
--			p_orgn_code	 	=> l_orgn_code,
--			p_location	 	=> l_location,
--			p_get_parent_only 	=> 0,
--			p_commit 		=> 'Y',
--			x_lot_number	 	=> l_lot_number,
--			x_parent_lot_number 	=> l_parent_lot_number,
--			x_failure_count 	=> l_failure_count);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE get_ODM_lot
( p_migration_run_id		IN		NUMBER
, p_item_id			IN		NUMBER
, p_lot_no			IN		VARCHAR2
, p_sublot_no			IN		VARCHAR2
, p_whse_code			IN		VARCHAR2
, p_orgn_code			IN		VARCHAR2
, p_location			IN		VARCHAR2
, p_get_parent_only		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_lot_number			OUT NOCOPY	VARCHAR2
, x_parent_lot_number		OUT NOCOPY	VARCHAR2
, x_failure_count               OUT NOCOPY	NUMBER) IS

l_lot_id		NUMBER;
l_count			NUMBER;
BEGIN
	x_failure_count := 0;
	IF (p_get_parent_only <> 1) THEN
	BEGIN
		SELECT lot_id
		INTO l_lot_id
		FROM ic_lots_mst
		WHERE
			item_id = p_item_id AND
			lot_no = p_lot_no AND
			nvl(sublot_no, ' ') = nvl(p_sublot_no, ' ');

			INV_OPM_Lot_Migration.get_ODM_lot(
				p_migration_run_id => p_migration_run_id,
				p_item_id => p_item_id,
				p_lot_id => l_lot_id,
				p_whse_code => p_whse_code,
				p_orgn_code => p_orgn_code,
				p_location => p_location,
				p_commit => p_commit,
				x_lot_number => x_lot_number,
				x_parent_lot_number => x_parent_lot_number,
				x_failure_count => x_failure_count);
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- Log error
			-- dbms_output.put_line ('Invalid OPM lot. Item id, lot no, sublot no : '||to_char(p_item_id)||', '||p_lot_no||', '||p_sublot_no);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_INVALID_LOT',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_param1          => p_lot_no,
				p_param2          => p_sublot_no,
				p_param3          => INV_GMI_Migration.item(p_item_id),
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;

	END;
	ELSE -- Get the parent lot only
		SELECT count(*)
		INTO l_count
		FROM ic_lots_mst_mig
		WHERE
			item_id = p_item_id AND
			whse_code = p_whse_code AND
			parent_lot_number = p_lot_no AND
			migrated_ind = 1;
		IF (l_count = 0) THEN
			-- Log error
			-- dbms_output.put_line ('No parent lot found for item id, whse_code, lot no : '||to_char(p_item_id)||', '||p_whse_code||', '||p_lot_no);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_NO_PARENT_LOT',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_param1          => INV_GMI_Migration.item(p_item_id),
				p_param2          => p_whse_code,
				p_param3          => p_lot_no,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
		ELSE
			x_parent_lot_number := p_lot_no;
			RETURN;
		END IF;
	END IF;
END;

/*====================================================================
--  PROCEDURE:
--    get_ODM_lot
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to get the lot number for
--    an OPM lot. If the OPM lot is not migrated, it will migrate the
--    the lot and return the discrete lot number.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_item_id - OPM item id.
--    p_lot_id - OPM Lot id
--    p_whse_code - OPM warehouse for the lot. Lot will be migrated to
--                   the organization created for the OPM warehouse.
--                   If p_whse_code is specified then p_orgn_code is
--                   ignored.
--    p_orgn_code - OPM organization for the lot. Lot will be migrated to
--                   the organization created for the OPM organization.
--    p_location - OPM location where the lot exist.
--    p_commit - flag to indicate if commit should be performed.
--    x_lot_number - Discrete Lot Number
--    x_parent_lot_number - Discrete Parent Lot Number
--    x_failure_count - Number of exceptions occurred.
--    p_organization_id - If the organization_id for lot is different from the
--		organization_id where the warehouse is migrated, specify the
--		organziation_id here, else leave it NULL.
--
--  SYNOPSIS:
--    get_ODM_lot(	p_migartion_id		=> l_migration_id,
--		   	p_item_id		=> l_item_id,
--		   	p_lot_id		=> l_lot_id,
--		   	p_sublot_no		=> l_sublot_no,
--			p_whse_code	 	=> l_whse_code,
--			p_orgn_code	 	=> l_orgn_code,
--			p_location	 	=> l_location,
--			p_commit 		=> 'Y',
--			x_lot_number	 	=> l_lot_number,
--			x_parent_lot_number 	=> l_parent_lot_number,
--			x_failure_count 	=> l_failure_count);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE get_ODM_lot
( p_migration_run_id		IN		NUMBER
, p_item_id                     IN              NUMBER
, p_lot_id                      IN              NUMBER
, p_whse_code                   IN              VARCHAR2
, p_orgn_code                   IN              VARCHAR2
, p_location                    IN              VARCHAR2
, p_commit                      IN              VARCHAR2
, x_lot_number                  OUT NOCOPY      VARCHAR2
, x_parent_lot_number           OUT NOCOPY      VARCHAR2
, x_failure_count               OUT NOCOPY	NUMBER
, p_organization_id             IN              NUMBER  DEFAULT NULL
) IS
  l_migrated_ind			PLS_INTEGER;
  l_whse_migrated_ind			PLS_INTEGER;
  l_orgn_migrated_ind			PLS_INTEGER;
  l_organization_id                    	NUMBER;
  l_lot_status				VARCHAR2(4);
  l_count				PLS_INTEGER;
  i					PLS_INTEGER;
  l_msg_count				NUMBER;
  l_msg_data				VARCHAR2(2000);
BEGIN
	x_failure_count := 0;
	-- Validate input parameters
	IF (p_item_id < 1 or p_item_id is NULL
		or p_lot_id < 1 or p_lot_id is NULL
		or ( p_whse_code is NULL and p_orgn_code is NULL)
		or ( p_orgn_code is not NULL and p_location is not NULL)
		or ( p_organization_id is not NULL and p_location is not NULL)) THEN
		-- Log validation error
		-- dbms_output.put_line ('Invalid parameters');
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMI_MIG_INVALID_PARAMS',
			p_table_name      => 'IC_LOTS_MST',
			p_context         => 'LOTS',
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

	-- See if the value for the lot is already cached
	IF (g_item_id = p_item_id and
		g_lot_id = p_lot_id and
		nvl(g_whse_code, ' ') = nvl(p_whse_code, ' ') and
		nvl(g_orgn_code, ' ') = nvl(p_orgn_code, ' ') and
		nvl(g_organization_id, 0) = nvl(p_organization_id, 0) and
		nvl(g_location, ' ') = nvl(p_location, ' ') and
		g_lot_number is NOT NULL ) THEN
			x_lot_number := g_lot_number;
			x_parent_lot_number := g_parent_lot_number;
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

	-- Get the organization_id for the warehouse
	IF (p_organization_id IS NULL) THEN
		IF (p_whse_code IS NOT NULL) THEN
		BEGIN
			SELECT organization_id, migrated_ind
			INTO l_organization_id, l_whse_migrated_ind
			FROM ic_whse_mst
			WHERE
				whse_code = p_whse_code;

			IF (l_organization_id is NULL or l_whse_migrated_ind = 0) THEN
				-- Log error
				-- dbms_output.put_line ('Warehouse not migrated : '||p_whse_code);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_WHSE_NOT_MIGRATED',
					p_table_name      => 'IC_LOTS_MST',
					p_context         => 'LOTS',
					p_param1          => p_whse_code,
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
				-- Log error
				-- dbms_output.put_line ('Invalid warehouse : '||p_whse_code);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_INVALID_WHSE',
					p_table_name      => 'IC_LOTS_MST',
					p_context         => 'LOTS',
					p_param1          => p_whse_code,
					p_param2          => NULL,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				x_failure_count := x_failure_count + 1;
				RETURN;
		END;
		ELSE -- p_whse_code is NULL
		BEGIN
			SELECT organization_id, migrated_ind
			INTO l_organization_id, l_orgn_migrated_ind
			FROM sy_orgn_mst_b
			WHERE
				orgn_code = p_orgn_code;

			IF (l_organization_id is NULL or l_orgn_migrated_ind = 0) THEN
				-- Log error
				-- dbms_output.put_line ('Organization not migrated : '||p_orgn_code);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_ORGN_NOT_MIGRATED',
					p_table_name      => 'IC_LOTS_MST',
					p_context         => 'LOTS',
					p_param1          => p_orgn_code,
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
				-- Log error
				-- dbms_output.put_line ('Invalid organization : '||p_orgn_code);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_INVALID_ORGN',
					p_table_name      => 'IC_LOTS_MST',
					p_context         => 'LOTS',
					p_param1          => p_orgn_code,
					p_param2          => NULL,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				x_failure_count := x_failure_count + 1;
				RETURN;
		END;
		END IF;
	ELSE
		l_organization_id := p_organization_id;
	END IF;

	-- Check the value in ic_lots_mst_mig table
	BEGIN
		g_item_id := p_item_id;
		g_lot_id := p_lot_id;
		g_whse_code := p_whse_code;
		g_orgn_code := p_orgn_code;
		g_location := p_location;
		g_organization_id := l_organization_id;
		g_lot_number := NULL;
		g_parent_lot_number := NULL;
		l_migrated_ind := -1;

		IF (g_location is not NULL) THEN
		BEGIN
			SELECT lot_number, parent_lot_number, status, nvl(migrated_ind, 0)
			INTO g_lot_number, g_parent_lot_number, l_lot_status, l_migrated_ind
			FROM ic_lots_mst_mig
			WHERE
				item_id = g_item_id AND
				lot_id = g_lot_id AND
				whse_code = g_whse_code AND -- only OPM whse
				location = g_location AND
				ROWNUM = 1;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;
		END IF;

		IF (g_location is NULL or l_migrated_ind = -1) THEN

			SELECT lot_number, parent_lot_number, status, migrated_ind
			INTO g_lot_number, g_parent_lot_number, l_lot_status, l_migrated_ind
			FROM ic_lots_mst_mig
			WHERE
				item_id = g_item_id AND
				lot_id = g_lot_id AND
				organization_id = g_organization_id AND -- for OPM whse or orgn
				additional_status_lot = 0 AND
				ROWNUM = 1;
		END IF;

		x_lot_number := g_lot_number;
		x_parent_lot_number := g_parent_lot_number;
		IF (l_migrated_ind = 1) THEN
			RETURN;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	END;

	-- This lot needs migration

	IF (l_migrated_ind <> 1) THEN
		migrate_OPM_lot_to_ODM (
			p_migration_run_id,
			p_item_id,
			p_lot_id,
			l_organization_id,
			p_whse_code,
			p_location,
			l_lot_status,
			p_commit,
			x_lot_number,
			x_parent_lot_number,
			x_failure_count);
		IF (x_failure_count > 0) THEN
			-- dbms_output.put_line ('OPM Lot migration failed. item id, lot id, whse, location : '||to_char(p_item_id)||', '||to_char(p_lot_id)||', '||p_whse_code||', '||p_location);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_LOT_MIG_FAILED',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_param1          => INV_GMI_Migration.item(p_item_id),
				p_param2          => INV_GMI_Migration.lot(p_lot_id),
				p_param3          => p_whse_code,
				p_param4          => p_location,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			RETURN;
		END IF;
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_failure_count := x_failure_count + 1;
		FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		FOR i in 1..l_msg_count LOOP
			-- dbms_output.put_line (substr(fnd_msg_pub.get_detail(i, NULL),1,255));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => P_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_UNEXPECTED_ERROR',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_token1	  => 'ERROR',
				p_param1          => fnd_msg_pub.get_detail(i, NULL),
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
		END LOOP;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_failure_count := x_failure_count + 1;
		FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		FOR i in 1..l_msg_count LOOP
			-- dbms_output.put_line (substr(fnd_msg_pub.get_detail(i, NULL),1,255));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => P_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_UNEXPECTED_ERROR',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_token1	  => 'ERROR',
				p_param1          => fnd_msg_pub.get_detail(i, NULL),
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
		END LOOP;

	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		FOR i in 1..l_msg_count LOOP
			-- dbms_output.put_line (substr(fnd_msg_pub.get_detail(i, NULL),1,255));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => P_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_UNEXPECTED_ERROR',
				p_table_name      => 'IC_LOTS_MST',
				p_context         => 'LOTS',
				p_token1	  => 'ERROR',
				p_param1          => fnd_msg_pub.get_detail(i, NULL),
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
		END LOOP;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => P_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'IC_LOTS_MST',
			p_context         => 'LOTS',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');

END;
END INV_OPM_Lot_Migration;

/
