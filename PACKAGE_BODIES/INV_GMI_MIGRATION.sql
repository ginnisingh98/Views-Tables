--------------------------------------------------------
--  DDL for Package Body INV_GMI_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_GMI_MIGRATION" AS
/* $Header: INVGMIMB.pls 120.17.12010000.5 2009/07/02 00:00:54 kbavadek ship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    INVGMIMB.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    INVGMIMB                                                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the procedure used for inventory  migration for |
 |    OPM convergence project. These procedure are meant for migration only.|
 |                                                                          |
 | Contents                                                                 |
 |    migrate_inventory_types                                               |
 |    migrate_item_categories                                               |
 |    migrate_default_category_sets                                         |
 |    migrate_lot_status                                                    |
 |    migrate_actions                                                       |
 |    migrate_opm_grades                                                    |
 |    migrate_odm_grades                                                    |
 |    migrate_lot_conversions                                               |
 |    migrate_inventory_balances                                            |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 3/22/05                                    |
 |                                                                          |
 |    Jatinder - 12/1/06 - initialize the locator_id - 5692408              |
 |                                                                          |
 |    Jatinder Gogna - 12/1/06 - use the following trans type for the       |
 |               shipping_ind - 5692788.                                    |
 |               Following is based upon input for Pete, Roberta            |
 |               and Discrete team.                                         |
 |               -- Sales Order Pick                                        |
 |               -- Move Order Transfer                                     |
 |                                                                          |
 |    Jatinder - 11/6/06 - Bug 5692929. As per GME team, only WIP Issue     |
 |               should be Disallowed.                                      |
 |    Jatinder - 12/18/06- Bug 5722698. Added NVL to the                    |
 |               UPDATE_BATCH_INDICATOR column.                             |
 |    Archana Mundhe  08/12/2008  Bug 6845259                               |
 |               Modified the update of ic_item_mst_b_mig based on item_id  |
 |    Archana Mundhe  03/25/2009  Bug 8363586                               |
 |               Modified migrate_inventory_balances to exclude records that|
 |               are delete marked from being processed.                    |
 |     Kedar Bavadekar - 06/23/09                                           |
 |                      Fix for Bug#8242978 . Added Ship confirm in         |
 |                      disallowed for status with shipping indicator       |
 |                      unchecked                                           |
 |     Kedar Bavadekar - 07/01/09. Fix for Bug#8650503.                     |
 |                       Added parameter X_ONHAND_CONTROL in call to        |
 |                       INSERT_ROW in package mtl_material_statuses_pkg    |
 +==========================================================================+
*/

G_DEFAULT_LOCT		VARCHAR2(50);
G_msg_item_id		NUMBER;
G_msg_ditem_id		NUMBER;
G_msg_lot_id		NUMBER;
G_msg_organization_id	NUMBER;
G_msg_item_no		VARCHAR2(100);
G_msg_ditem_no		VARCHAR2(100);
G_msg_lot_no		VARCHAR2(100);
G_msg_organization_code	VARCHAR2(100);

/*====================================================================
--  PROCEDURE:
--    item
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to item_no
--
--
--  PARAMETERS:
--
--  SYNOPSIS:
--    get_mig_status;
--
--  HISTORY
--====================================================================*/
FUNCTION item
( p_item_id			IN		NUMBER)
RETURN VARCHAR2 IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	l_return_val	VARCHAR2(200);
BEGIN
	IF G_msg_item_id = p_item_id THEN
		RETURN G_msg_item_no;
	END IF;

	BEGIN
		SELECT item_no ||'('||to_char(p_item_id)||')'
		INTO l_return_val
		FROM ic_item_mst_b
		WHERE item_id = p_item_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			G_msg_item_no := '('||to_char(p_item_id)||')';
	END;

	G_msg_item_id := p_item_id;
	G_msg_item_no := substr(l_return_val,1,100);

	RETURN G_msg_item_no;
END;

/*====================================================================
--  PROCEDURE:
--    ditem
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to item_no
--
--
--  PARAMETERS:
--
--  SYNOPSIS:
--    get_mig_status;
--
--  HISTORY
--====================================================================*/
FUNCTION ditem
( p_organization_id		IN		NUMBER,
  p_ditem_id			IN		NUMBER)
RETURN VARCHAR2 IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	l_return_val	VARCHAR2(200);
BEGIN
	IF G_msg_ditem_id = p_ditem_id THEN
		RETURN G_msg_ditem_no;
	END IF;

	BEGIN
		SELECT segment1 ||'('||to_char(p_ditem_id)||')'
		INTO l_return_val
		FROM mtl_system_items_b
		WHERE organization_id = p_organization_id AND
			inventory_item_id = p_ditem_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			G_msg_ditem_no := '('||to_char(p_ditem_id)||')';
	END;

	G_msg_ditem_id := p_ditem_id;
	G_msg_ditem_no := substr(l_return_val,1,100);

	RETURN G_msg_ditem_no;
END;

/*====================================================================
--  PROCEDURE:
--    lot
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to get lot_no
--
--
--  PARAMETERS:
--
--  SYNOPSIS:
--    get_mig_status;
--
--  HISTORY
--====================================================================*/
FUNCTION lot
( p_lot_id			IN		NUMBER)
RETURN VARCHAR2 IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	l_return_val	VARCHAR2(200);
BEGIN
	IF G_msg_lot_id = p_lot_id THEN
		RETURN G_msg_lot_no;
	END IF;

	BEGIN
		SELECT lot_no ||decode(sublot_no, NULL,NULL,', '||sublot_no)
			||'('||to_char(p_lot_id)||')'
		INTO l_return_val
		FROM ic_lots_mst
		WHERE lot_id = p_lot_id AND
			rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			G_msg_lot_no := '('||to_char(p_lot_id)||')';
	END;

	G_msg_lot_id := p_lot_id;
	G_msg_lot_no := substr(l_return_val,1,100);

	RETURN G_msg_lot_no;
END;

/*====================================================================
--  PROCEDURE:
--    org
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to get org code
--
--
--  PARAMETERS:
--
--  SYNOPSIS:
--    get_mig_status;
--
--  HISTORY
--====================================================================*/
FUNCTION org
( p_organization_id		IN		NUMBER)
RETURN VARCHAR2 IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	l_return_val	VARCHAR2(200);
BEGIN
	IF G_msg_organization_id = p_organization_id THEN
		RETURN G_msg_organization_code;
	END IF;

	BEGIN
		SELECT organization_code ||'('||to_char(p_organization_id)||')'
		INTO l_return_val
		FROM mtl_parameters
		WHERE organization_id = p_organization_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			G_msg_organization_code := '('||to_char(p_organization_id)||')';
	END;

	G_msg_organization_id := p_organization_id;
	G_msg_organization_code := substr(l_return_val,1,100);

	RETURN G_msg_organization_code;
END;

/*====================================================================
--  PROCEDURE:
--    migrate_inventory_types
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the OPM inventory types
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    p_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_inventory_types (p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_inventory_types
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER) IS

CURSOR c_ic_invn_typ IS
SELECT *
FROM ic_invn_typ
WHERE migrated_ind is NULL;

l_status_id	NUMBER;
l_count		PLS_INTEGER;
l_enabled_flag	VARCHAR2(1);
l_is_allowed	PLS_INTEGER;
l_migrate_count	PLS_INTEGER;

l_rowid		ROWID;

BEGIN
	x_failure_count := 0;
	l_migrate_count	:= 0;
	-- dbms_output.put_line ('Started INVENTORY TYPES migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'IC_INVN_TYP',
		p_context         => 'INVENTORY TYPES',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');

	FOR l_inv_type IN c_ic_invn_typ LOOP
	BEGIN
		-- Check if the inventory type already exists in the discrete
		SELECT count(*)
		INTO l_count
		FROM fnd_lookup_values
		WHERE
			lookup_type = 'ITEM_TYPE' and
			lookup_code = l_inv_type.inv_type and
			view_application_id = 3 and
			ROWNUM = 1;

		IF (l_count > 0) THEN
			-- No migration needed, skip it.
			-- dbms_output.put_line ('Inventory type '||l_inv_type.inv_type||' already exist in discrete.');
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_PROCEDURE,
				p_message_token   => 'GMI_MIG_TYPE_EXISTS',
				p_table_name      => 'IC_INVN_TYP',
				p_context         => 'INVENTORY TYPES',
				p_param1          => l_inv_type.inv_type,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise FND_API.G_EXC_ERROR;
		END IF;


		l_enabled_flag := 'Y';
		IF (l_inv_type.delete_mark = 1) THEN
			l_enabled_flag := 'N';
		END IF;
		FND_LOOKUP_VALUES_PKG.INSERT_ROW (
			X_ROWID=> l_rowid,
			X_LOOKUP_TYPE=> 'ITEM_TYPE',
			X_SECURITY_GROUP_ID=> 0,
			X_VIEW_APPLICATION_ID=> 3,
			X_LOOKUP_CODE=> l_inv_type.inv_type,
			X_TAG=> NULL,
			X_ENABLED_FLAG=> l_enabled_flag,
			X_START_DATE_ACTIVE=> NULL,
			X_END_DATE_ACTIVE=> NULL,
			X_TERRITORY_CODE=> NULL,
			X_ATTRIBUTE_CATEGORY=> NULL,
			X_ATTRIBUTE1 => l_inv_type.attribute1,
			X_ATTRIBUTE2 => l_inv_type.attribute2,
			X_ATTRIBUTE3 => l_inv_type.attribute3,
			X_ATTRIBUTE4 => l_inv_type.attribute4,
			X_ATTRIBUTE5 => l_inv_type.attribute5,
			X_ATTRIBUTE6 => l_inv_type.attribute6,
			X_ATTRIBUTE7 => l_inv_type.attribute7,
			X_ATTRIBUTE8 => l_inv_type.attribute8,
			X_ATTRIBUTE9 => l_inv_type.attribute9,
			X_ATTRIBUTE10 => l_inv_type.attribute10,
			X_ATTRIBUTE11 => l_inv_type.attribute11,
			X_ATTRIBUTE12 => l_inv_type.attribute12,
			X_ATTRIBUTE13 => l_inv_type.attribute13,
			X_ATTRIBUTE14 => l_inv_type.attribute14,
			X_ATTRIBUTE15 => l_inv_type.attribute15,
			X_MEANING=> l_inv_type.inv_type,
			X_DESCRIPTION=> l_inv_type.inv_type_desc,
			X_CREATION_DATE=> l_inv_type.creation_date,
			X_CREATED_BY=> l_inv_type.created_by,
			X_LAST_UPDATE_DATE=> l_inv_type.last_update_date,
			X_LAST_UPDATED_BY=> l_inv_type.last_updated_by,
			X_LAST_UPDATE_LOGIN=> NULL
		);

		UPDATE ic_invn_typ
		SET
			migrated_ind = 1
		WHERE
			inv_type = l_inv_type.inv_type;

		IF (p_commit <> FND_API.G_FALSE) THEN
			COMMIT;
		END IF;
		l_migrate_count := l_migrate_count + 1;
	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			NULL; -- Move to the next record.
	END;
	END LOOP;

	-- dbms_output.put_line ('Completed INVENTORY TYPES migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'IC_INVN_TYP',
		p_context         => 'INVENTORY TYPES',
		p_param1          => l_migrate_count,
		p_param2          => x_failure_count,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'IC_INVN_TYP',
			p_context         => 'INVENTORY TYPES',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');

END;

/*====================================================================
--  PROCEDURE:
--    migrate_default_category_sets
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the OPM default category_sets
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit should be performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_category_sets(p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_default_category_sets
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER) IS

	e_already_exists	EXCEPTION;
	l_migrate_count		PLS_INTEGER;
	l_functional_area_id	NUMBER;
	l_category_set_id	NUMBER;

	CURSOR c_opm_category_sets IS
	SELECT * FROM gmi_category_sets
        WHERE migrated_ind is NULL AND
            OPM_CLASS in ('ALLOC_CLASS','SEQ_CLASS','SUB_STANDARD_CLASS',
                    'TECH_CLASS','GL_CLASS','COST_CLASS','GL_BUSINESS_CLASS',
                    'GL_PRODUCT_LINE');

BEGIN
	x_failure_count := 0;
	l_migrate_count	:= 0;
	-- dbms_output.put_line ('Started CATEGORY SETS migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'GMI_CATEGORY_SETS',
		p_context         => 'CATEGORY SETS',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
	FOR c in c_opm_category_sets LOOP
	BEGIN
		SELECT functional_area_id, category_set_id
		INTO l_functional_area_id, l_category_set_id
		FROM mtl_default_category_sets s,
			mfg_lookups l
		WHERE
			l.lookup_type = 'MTL_FUNCTIONAL_AREAS' and
			l.meaning = 'Process '|| decode (c.user_opm_class, 'General Ledger Class',
						'GL Class', 'GL Product Line', 'Product Line',
						c.user_opm_class) AND
			l.lookup_code = s.functional_area_id;

		IF (l_category_set_id <> -1) THEN
			-- dbms_output.put_line ('Default category set already assigned for '||c.user_opm_class);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_PROCEDURE,
				p_message_token   => 'GMI_MIG_CAT_SET_ASSIGNED',
				p_table_name      => 'GMI_CATEGORY_SETS',
				p_context         => 'CATEGORY SETS',
				p_param1          => c.user_opm_class,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise e_already_exists;
		END IF;

		-- Update discrete functional area with OPM category set id for convergence
		-- functional areas
		UPDATE mtl_default_category_sets
		SET category_set_id = NVL(c.category_set_id, -1)
		WHERE
			functional_area_id = l_functional_area_id and
			category_set_id = -1;

		UPDATE gmi_category_sets
		SET migrated_ind = 1
		WHERE opm_class = c.opm_class;

		IF (p_commit <> FND_API.G_FALSE) THEN
			COMMIT;
		END IF;
		l_migrate_count := l_migrate_count + 1;
	EXCEPTION
		WHEN e_already_exists THEN
			x_failure_count := x_failure_count + 1;
		WHEN NO_DATA_FOUND THEN
			-- dbms_output.put_line ('Functional area does not exist in discrete : '||c.user_opm_class);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_PROCEDURE,
				p_message_token   => 'GMI_MIG_NO_FUNC_AREA',
				p_table_name      => 'GMI_CATEGORY_SETS',
				p_context         => 'CATEGORY SETS',
				p_param1          => c.user_opm_class,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
	END;
	END LOOP;

	-- dbms_output.put_line ('Completed CATEGORY SETS migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'GMI_CATEGORY_SETS',
		p_context         => 'CATEGORY SETS',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'GMI_CATEGORY_SETS',
			p_context         => 'CATEGORY SETS',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
END;

/*====================================================================
--  PROCEDURE:
--    migrate_item_categories
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the OPM Item Categories
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    p_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_item_categories (p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_item_categories
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, p_start_rowid			IN		ROWID
, p_end_rowid			IN		ROWID
, x_failure_count		OUT NOCOPY	NUMBER) IS

CURSOR c_item_cat_error IS
	SELECT DISTINCT
		i.inventory_item_id,
		i.organization_id,
		g.category_set_id
	FROM gmi_item_categories g,
		ic_item_mst_b_mig i,
		mtl_item_categories m
	WHERE g.rowid BETWEEN p_start_rowid AND p_end_rowid AND
		i.migrated_ind is not NULL and
		i.category_migrated_ind is NULL and
		i.item_id = g.item_id and
		m.organization_id = i.organization_id and
		m.inventory_item_id = i.inventory_item_id and
		m.category_set_id = g.category_set_id and
		m.category_id <> g.category_id;

l_migrate_count	PLS_INTEGER;

BEGIN
	x_failure_count := 0;
	l_migrate_count	:= 0;
	-- dbms_output.put_line ('Started ITEM CATEGORIES migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'GMI_ITEM_CATEGORIES',
		p_context         => 'ITEM CATEGORIES',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');

	-- insert new record in discrete
	insert into mtl_item_categories(
		INVENTORY_ITEM_ID,
		ORGANIZATION_ID,
		CATEGORY_SET_ID,
		CATEGORY_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		WH_UPDATE_DATE)
	SELECT
		i.inventory_item_id,
		i.organization_id,
		g.category_set_id,
		g.category_id,
		g.creation_date,
		g.created_by,
		g.last_update_date,
		g.last_updated_by,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL
	FROM gmi_item_categories g,
		ic_item_mst_b_mig i
	WHERE g.rowid BETWEEN p_start_rowid AND p_end_rowid AND
		i.migrated_ind is not NULL and
		i.category_migrated_ind is NULL and
		i.item_id = g.item_id and
                NOT EXISTS(
                         SELECT 1
                         FROM mtl_item_categories
                         WHERE
                            organization_id = i.organization_id AND
                            inventory_item_id = i.inventory_item_id AND
                            category_set_id = g.category_set_id);

	l_migrate_count := SQL%ROWCOUNT;

	/* Select rows with error */
	FOR r in c_item_cat_error LOOP
		-- Log warning message
		-- dbms_output.put_line ('A different category already assigned in discrete. Org id, Item, category set id' || to_char(r.organization_id)||', '||to_char(v_inventory_item_id)||', '||to_char(r.category_set_id));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_PROCEDURE,
			p_message_token   => 'GMI_MIG_ITEM_CAT_EXISTS',
			p_table_name      => 'GMI_ITEM_CATEGORIES',
			p_context         => 'ITEM CATEGORIES',
			p_param1          => INV_GMI_Migration.org(r.organization_id),
			p_param2          => INV_GMI_Migration.ditem(r.organization_id, r.inventory_item_id),
			p_param3          => to_char(r.category_set_id),
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => NULL,
			p_app_short_name  => 'GMI');
		x_failure_count := x_failure_count + 1;
	END LOOP;


	/* Update the rows as migrated */
   /* Bug 6845259 */
   /* Modified the update*/
   UPDATE ic_item_mst_b_mig mig
   SET category_migrated_ind = 1
   WHERE exists ( SELECT 1
                    FROM gmi_item_categories gic
                    WHERE ROWID BETWEEN  p_start_rowid AND p_end_rowid
                    AND   mig.item_id = gic.item_id);

	/* UPDATE ic_item_mst_b_mig
	SET category_migrated_ind = 1
	WHERE
		(organization_id, inventory_item_id) IN (
			SELECT organization_id, inventory_item_id
			FROM gmi_item_categories
			WHERE
				rowid BETWEEN p_start_rowid AND p_end_rowid); */

	-- dbms_output.put_line ('Completed ITEM CATEGORIES migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'GMI_ITEM_CATEGORIES',
		p_context         => 'ITEM CATEGORIES',
		p_param1          => l_migrate_count,
		p_param2          => x_failure_count,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'GMI_ITEM_CATEGORIES',
			p_context         => 'ITEM CATEGORIES',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');

END;

/*====================================================================
--  PROCEDURE:
--    migrate_lot_status
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the OPM Lot status
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_lot_status(p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--     Kedar Bavadekar - 06/23/09 Fix for Bug#8242978 . Added Ship confirm in
--                      disallowed for status with shipping indicator
--                      unchecked
--====================================================================*/

PROCEDURE migrate_lot_status
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER) IS

l_status_id	NUMBER;
l_count	PLS_INTEGER;
l_availability_type	PLS_INTEGER;
l_is_allowed	PLS_INTEGER;
l_migrate_count	PLS_INTEGER;

l_rowid		ROWID;

CURSOR c_ic_lots_sts IS
SELECT *
FROM ic_lots_sts
WHERE status_id is NULL ;

CURSOR c_trans_type IS
SELECT transaction_type_id, transaction_type_name, transaction_source_type_id
FROM mtl_transaction_types
WHERE
	status_control_flag = 1 and
	disable_date is NULL ;

BEGIN
	x_failure_count := 0;
	l_migrate_count	:= 0;
	-- dbms_output.put_line ('Started LOT STATUS migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'IC_LOTS_STS',
		p_context         => 'LOT STATUS',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
	FOR l_lot_status IN c_ic_lots_sts LOOP
	BEGIN
		-- Check if the material status already exists in the discrete
		SELECT count(*)
		INTO l_count
		FROM mtl_material_statuses_tl
		WHERE
			status_code = l_lot_status.lot_status and
			rownum = 1;

		IF (l_count > 0) THEN
			-- No migration needed, skip it.
			-- dbms_output.put_line ('Lot status already exists: '||l_lot_status.lot_status);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_STATUS_EXISTS',
				p_table_name      => 'IC_LOTS_STS',
				p_context         => 'LOT STATUS',
				p_param1          => l_lot_status.lot_status,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise FND_API.G_EXC_ERROR;
		END IF;

		SELECT mtl_material_status_s.NEXTVAL
		INTO   l_status_id
		FROM DUAL;

		l_availability_type := 2;
		IF (l_lot_status.rejected_ind = 0) THEN
			IF (l_lot_status.nettable_ind = 1) THEN
				l_availability_type := 1;
			END IF;
		END IF;
		MTL_MATERIAL_STATUSES_PKG.INSERT_ROW (
			X_ROWID => l_rowid,
			X_STATUS_ID => l_status_id,
			X_ATTRIBUTE1 => NULL,
			X_ATTRIBUTE2 => NULL,
			X_ATTRIBUTE3 => NULL,
			X_ATTRIBUTE4 => NULL,
			X_ATTRIBUTE5 => NULL,
			X_ATTRIBUTE6 => NULL,
			X_ATTRIBUTE7 => NULL,
			X_ATTRIBUTE8 => NULL,
			X_ATTRIBUTE9 => NULL,
			X_ATTRIBUTE10 => NULL,
			X_ATTRIBUTE11 => NULL,
			X_ATTRIBUTE12 => NULL,
			X_ATTRIBUTE13 => NULL,
			X_ATTRIBUTE14 => NULL,
			X_ATTRIBUTE15 => NULL,
			X_LOCATOR_CONTROL => 2,
			X_LOT_CONTROL => 1,
			X_SERIAL_CONTROL => 2,
			X_ZONE_CONTROL => 2,
                        X_ONHAND_CONTROL => 2, /* Fix for Bug#8650503 */
			X_REQUEST_ID         => NULL,
			X_ATTRIBUTE_CATEGORY => NULL,
			X_ENABLED_FLAG => l_lot_status.delete_mark+1,
			X_STATUS_CODE => l_lot_status.lot_status,
			X_DESCRIPTION => l_lot_status.status_desc,
			X_CREATION_DATE => l_lot_status.creation_date,
			X_CREATED_BY => l_lot_status.created_by,
			X_LAST_UPDATE_DATE => l_lot_status.last_update_date,
			X_LAST_UPDATED_BY => l_lot_status.last_updated_by,
			X_LAST_UPDATE_LOGIN => NULL,
			X_LPN_CONTROL => 2,
			X_INVENTORY_ATP_CODE => l_lot_status.rejected_ind+1,
			X_RESERVABLE_TYPE => l_lot_status.rejected_ind+1,
			X_AVAILABILITY_TYPE => l_availability_type
			);

		FOR tt IN c_trans_type LOOP
			l_is_allowed := 1;
			IF (l_lot_status.order_proc_ind = 0 or l_lot_status.rejected_ind = 1) THEN
				-- Sales Order Pick
				-- Internal Order Pick
				IF (tt.transaction_type_id = 52 or
				   tt.transaction_type_id = 53) THEN
					l_is_allowed := 2;
				END IF;
			END IF;
			IF (l_lot_status.prod_ind = 0 or l_lot_status.rejected_ind = 1) THEN
				-- WIP Issue
				-- WIP Completion Return
				-- WIP Assy Completion
				-- WIP Component Return
				-- WIP By-product Completion
				-- WIP By-product Return
				-- Jatinder - 11/6/06 - Bug 5692929. As per GME team, only WIP Issue should be
				-- Disallowed.
				IF (tt.transaction_type_id = 35) THEN
					l_is_allowed := 2;
				END IF;
			END IF;
			IF (l_lot_status.shipping_ind = 0 or l_lot_status.rejected_ind = 1) THEN
				-- Sales order issue
				-- Internal order issue
				-- Int Order Intr Ship
				-- Jatinder Gogna - 12/1/06 - use the following trans type for the shipping_ind - 5692788
				-- Following is based upon input for Pete, Roberta and Discrete team.
				-- Sales Order Pick
				-- Move Order Transfer

                                /* Fix for Bug#8242978. Sales order issue should be disallowed.
                                   Added 33 in if condition
                                */
				-- IF (tt.transaction_type_id = 52 or
				--   tt.transaction_type_id = 64) THEN

                                IF tt.transaction_type_id in (52, 64, 33)  THEN
					l_is_allowed := 2;
				END IF;
			END IF;

			INSERT INTO MTL_STATUS_TRANSACTION_CONTROL (
				status_id,
				transaction_type_id,
				is_allowed,
				creation_date,
				created_by,
				last_updated_by,
				last_update_date
			) VALUES (
				l_status_id,
				tt.transaction_type_id,
				l_is_allowed,
				l_lot_status.creation_date,
				l_lot_status.created_by,
				l_lot_status.last_updated_by,
				l_lot_status.last_update_date);

		END LOOP;
		UPDATE ic_lots_sts
		SET
			status_id = l_status_id,
			migrated_ind = 1
		WHERE
			lot_status = l_lot_status.lot_status;

		IF (p_commit <> FND_API.G_FALSE) THEN
			COMMIT;
		END IF;
		l_migrate_count := l_migrate_count + 1;
	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			NULL; -- Move to the next record.
	END;
	END LOOP;

	-- dbms_output.put_line ('Completed LOT STATUS migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'IC_LOTS_STS',
		p_context         => 'LOT STATUS',
		p_param1          => l_migrate_count,
		p_param2          => x_failure_count,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');

EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'IC_LOTS_STS',
			p_context         => 'LOT STATUS',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
END;

/*====================================================================
--  PROCEDURE:
--    migrate_actions
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the OPM actions
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_actions(p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_actions
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER) IS

	l_rowid			ROWID;
	l_disable_flag		VARCHAR2(1);
	e_already_exists	EXCEPTION;
	l_count			PLS_INTEGER;
	l_migrate_count	PLS_INTEGER;

	CURSOR c_opm_actions IS
	SELECT * FROM gmd_actions_b
	WHERE migrated_ind is NULL;

	CURSOR c_opm_actions_tl (p_action_code VARCHAR2) IS
	SELECT * FROM gmd_actions_tl
	WHERE action_code = p_action_code;
BEGIN
	x_failure_count := 0;
	l_migrate_count	:= 0;
	-- dbms_output.put_line ('Started ACTIONS migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'GMD_ACTIONS',
		p_context         => 'ACTIONS',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
	FOR g in c_opm_actions LOOP
	BEGIN

		SELECT count(*)
		INTO l_count
		FROM mtl_actions_b
		WHERE action_code = g.action_code;

		IF (l_count > 0) THEN
			-- dbms_output.put_line ('Action already exists: '||g.action_code);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_PROCEDURE,
				p_message_token   => 'GMI_MIG_ACTION_EXISTS',
				p_table_name      => 'GMD_ACTIONS',
				p_context         => 'ACTIONS',
				p_param1          => g.action_code,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise e_already_exists;
		END IF;

		l_disable_flag := 'N';
		IF (g.delete_mark = 1) THEN
			l_disable_flag := 'Y';
		END IF;
		MTL_ACTIONS_PVT.INSERT_ROW (
			X_ROWID => l_rowid,
			X_ACTION_CODE => g.action_code,
			X_DESCRIPTION => ' ',
			X_DISABLE_FLAG => l_disable_flag,
			X_ATTRIBUTE1 => g.ATTRIBUTE1,
			X_ATTRIBUTE2 => g.ATTRIBUTE2,
			X_ATTRIBUTE3 => g.ATTRIBUTE3,
			X_ATTRIBUTE4 => g.ATTRIBUTE4,
			X_ATTRIBUTE5 => g.ATTRIBUTE5,
			X_ATTRIBUTE6 => g.ATTRIBUTE6,
			X_ATTRIBUTE7 => g.ATTRIBUTE7,
			X_ATTRIBUTE8 => g.ATTRIBUTE8,
			X_ATTRIBUTE9 => g.ATTRIBUTE9,
			X_ATTRIBUTE10 => g.ATTRIBUTE10,
			X_ATTRIBUTE11 => g.ATTRIBUTE11,
			X_ATTRIBUTE12 => g.ATTRIBUTE12,
			X_ATTRIBUTE13 => g.ATTRIBUTE13,
			X_ATTRIBUTE14 => g.ATTRIBUTE14,
			X_ATTRIBUTE15 => g.ATTRIBUTE15,
			X_ATTRIBUTE16 => g.ATTRIBUTE16,
			X_ATTRIBUTE17 => g.ATTRIBUTE17,
			X_ATTRIBUTE18 => g.ATTRIBUTE18,
			X_ATTRIBUTE19 => g.ATTRIBUTE19,
			X_ATTRIBUTE20 => g.ATTRIBUTE20,
			X_ATTRIBUTE21 => g.ATTRIBUTE21,
			X_ATTRIBUTE22 => g.ATTRIBUTE22,
			X_ATTRIBUTE23 => g.ATTRIBUTE23,
			X_ATTRIBUTE24 => g.ATTRIBUTE24,
			X_ATTRIBUTE25 => g.ATTRIBUTE25,
			X_ATTRIBUTE26 => g.ATTRIBUTE26,
			X_ATTRIBUTE27 => g.ATTRIBUTE27,
			X_ATTRIBUTE28 => g.ATTRIBUTE28,
			X_ATTRIBUTE29 => g.ATTRIBUTE29,
			X_ATTRIBUTE30 => g.ATTRIBUTE30,
			X_ATTRIBUTE_CATEGORY => g.ATTRIBUTE_CATEGORY,
			X_CREATION_DATE => g.CREATION_DATE,
			X_CREATED_BY => g.CREATED_BY,
			X_LAST_UPDATE_DATE => g.LAST_UPDATE_DATE,
			X_LAST_UPDATED_BY => g.LAST_UPDATED_BY,
			X_LAST_UPDATE_LOGIN => g.LAST_UPDATE_LOGIN);

		FOR gt in c_opm_actions_tl (g.action_code) LOOP
			UPDATE mtl_actions_TL
			SET
				DESCRIPTION = gt.action_desc,
				SOURCE_LANG = gt.source_lang
			WHERE
				action_code = gt.action_code AND
				language = gt.language;
		END LOOP;

		UPDATE gmd_actions_b
		SET migrated_ind = 1
		WHERE action_code = g.action_code;

		IF (p_commit <> FND_API.G_FALSE) THEN
			COMMIT;
		END IF;
		l_migrate_count := l_migrate_count + 1;
	EXCEPTION
		WHEN e_already_exists THEN
			UPDATE gmd_actions_b
			SET migrated_ind = 1
			WHERE action_code = g.action_code;
	END;
	END LOOP;

	-- dbms_output.put_line ('Completed ACTIONS migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'GMD_ACTIONS',
		p_context         => 'ACTIONS',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'GMD_ACTIONS',
			p_context         => 'ACTIONS',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
END;

/*====================================================================
--  PROCEDURE:
--    migrate_opm_grades
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the OPM grades
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_opm_grades(p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_opm_grades
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER) IS

	l_rowid			ROWID;
	l_disable_flag		VARCHAR2(1);
	e_already_exists	EXCEPTION;
	l_count			PLS_INTEGER;
	l_migrate_count	PLS_INTEGER;

	CURSOR c_opm_grades IS
	SELECT * FROM gmd_grades_b
	WHERE migrated_ind is NULL;

	CURSOR c_opm_grades_tl (p_qc_grade VARCHAR2) IS
	SELECT * FROM gmd_grades_tl
	WHERE QC_GRADE = p_qc_grade;
BEGIN
	x_failure_count := 0;
	l_migrate_count	:= 0;
	-- dbms_output.put_line ('Started GRADES migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'GMD_GRADES',
		p_context         => 'GRADES',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
	FOR g in c_opm_grades LOOP
	BEGIN

		SELECT count(*)
		INTO l_count
		FROM mtl_grades_b
		WHERE grade_code = g.qc_grade;

		IF (l_count > 0) THEN
			-- dbms_output.put_line ('Grade already exists: '||g.qc_grade);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_PROCEDURE,
				p_message_token   => 'GMI_MIG_GRADE_EXISTS',
				p_table_name      => 'GMD_GRADES',
				p_context         => 'GRADES',
				p_param1          => g.qc_grade,
				p_param2          => NULL,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise e_already_exists;
		END IF;

		l_disable_flag := 'N';
		IF (g.delete_mark = 1) THEN
			l_disable_flag := 'Y';
		END IF;
		MTL_GRADES_PVT.INSERT_ROW (
			X_ROWID => l_rowid,
			X_GRADE_CODE => g.qc_grade,
			X_DESCRIPTION => nvl(g.qc_grade_desc, g.qc_grade),
			X_DISABLE_FLAG => l_disable_flag,
			X_ATTRIBUTE1 => g.ATTRIBUTE1,
			X_ATTRIBUTE2 => g.ATTRIBUTE2,
			X_ATTRIBUTE3 => g.ATTRIBUTE3,
			X_ATTRIBUTE4 => g.ATTRIBUTE4,
			X_ATTRIBUTE5 => g.ATTRIBUTE5,
			X_ATTRIBUTE6 => g.ATTRIBUTE6,
			X_ATTRIBUTE7 => g.ATTRIBUTE7,
			X_ATTRIBUTE8 => g.ATTRIBUTE8,
			X_ATTRIBUTE9 => g.ATTRIBUTE9,
			X_ATTRIBUTE10 => g.ATTRIBUTE10,
			X_ATTRIBUTE11 => g.ATTRIBUTE11,
			X_ATTRIBUTE12 => g.ATTRIBUTE12,
			X_ATTRIBUTE13 => g.ATTRIBUTE13,
			X_ATTRIBUTE14 => g.ATTRIBUTE14,
			X_ATTRIBUTE15 => g.ATTRIBUTE15,
			X_ATTRIBUTE16 => g.ATTRIBUTE16,
			X_ATTRIBUTE17 => g.ATTRIBUTE17,
			X_ATTRIBUTE18 => g.ATTRIBUTE18,
			X_ATTRIBUTE19 => g.ATTRIBUTE19,
			X_ATTRIBUTE20 => g.ATTRIBUTE20,
			X_ATTRIBUTE21 => g.ATTRIBUTE21,
			X_ATTRIBUTE22 => g.ATTRIBUTE22,
			X_ATTRIBUTE23 => g.ATTRIBUTE23,
			X_ATTRIBUTE24 => g.ATTRIBUTE24,
			X_ATTRIBUTE25 => g.ATTRIBUTE25,
			X_ATTRIBUTE26 => g.ATTRIBUTE26,
			X_ATTRIBUTE27 => g.ATTRIBUTE27,
			X_ATTRIBUTE28 => g.ATTRIBUTE28,
			X_ATTRIBUTE29 => g.ATTRIBUTE29,
			X_ATTRIBUTE30 => g.ATTRIBUTE30,
			X_ATTRIBUTE_CATEGORY => g.ATTRIBUTE_CATEGORY,
			X_CREATION_DATE => g.CREATION_DATE,
			X_CREATED_BY => g.CREATED_BY,
			X_LAST_UPDATE_DATE => g.LAST_UPDATE_DATE,
			X_LAST_UPDATED_BY => g.LAST_UPDATED_BY,
			X_LAST_UPDATE_LOGIN => g.LAST_UPDATE_LOGIN);

		FOR gt in c_opm_grades_tl (g.qc_grade) LOOP
			UPDATE MTL_GRADES_TL
			SET
				DESCRIPTION = gt.qc_grade_desc,
				SOURCE_LANG = gt.source_lang
			WHERE
				grade_code = gt.qc_grade AND
				language = gt.language;
		END LOOP;

		UPDATE gmd_grades_b
		SET migrated_ind = 1
		WHERE qc_grade = g.qc_grade;

		IF (p_commit <> FND_API.G_FALSE) THEN
			COMMIT;
		END IF;
		l_migrate_count := l_migrate_count + 1;
	EXCEPTION
		WHEN e_already_exists THEN
			UPDATE gmd_grades_b
			SET migrated_ind = 1
			WHERE qc_grade = g.qc_grade;
	END;
	END LOOP;

	-- dbms_output.put_line ('Completed GRADES migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'GMD_GRADES',
		p_context         => 'GRADES',
		p_param1          => l_migrate_count,
		p_param2          => x_failure_count,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'GMD_GRADES',
			p_context         => 'GRADES',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
END;

/*====================================================================
--  PROCEDURE:
--    migrate_odm_grades
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the Discrete grades
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_odm_grades(p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_odm_grades
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER) IS

	l_rowid			ROWID;
	l_disable_flag		VARCHAR2(1);
	e_already_exists	EXCEPTION;
	l_count			PLS_INTEGER;
	l_migrate_count	PLS_INTEGER;

	CURSOR c_lot_grades IS
	SELECT distinct grade_code FROM mtl_lot_numbers
	WHERE grade_code is not NULL;

BEGIN
	x_failure_count := 0;
	l_migrate_count	:= 0;
	-- dbms_output.put_line ('Started GRADES migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'MTL_LOT_NUMBERS',
		p_context         => 'GRADES',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
	FOR g in c_lot_grades LOOP
	BEGIN

		SELECT count(*)
		INTO l_count
		FROM mtl_grades_b
		WHERE grade_code = g.grade_code;

		IF (l_count > 0) THEN
			raise e_already_exists;
		END IF;

		MTL_GRADES_PVT.INSERT_ROW (
			X_ROWID => l_rowid,
			X_GRADE_CODE => g.grade_code,
			X_DESCRIPTION => g.grade_code,
			X_DISABLE_FLAG => 'N',
			X_ATTRIBUTE1 => NULL,
			X_ATTRIBUTE2 => NULL,
			X_ATTRIBUTE3 => NULL,
			X_ATTRIBUTE4 => NULL,
			X_ATTRIBUTE5 => NULL,
			X_ATTRIBUTE6 => NULL,
			X_ATTRIBUTE7 => NULL,
			X_ATTRIBUTE8 => NULL,
			X_ATTRIBUTE9 => NULL,
			X_ATTRIBUTE10 => NULL,
			X_ATTRIBUTE11 => NULL,
			X_ATTRIBUTE12 => NULL,
			X_ATTRIBUTE13 => NULL,
			X_ATTRIBUTE14 => NULL,
			X_ATTRIBUTE15 => NULL,
			X_ATTRIBUTE16 => NULL,
			X_ATTRIBUTE17 => NULL,
			X_ATTRIBUTE18 => NULL,
			X_ATTRIBUTE19 => NULL,
			X_ATTRIBUTE20 => NULL,
			X_ATTRIBUTE21 => NULL,
			X_ATTRIBUTE22 => NULL,
			X_ATTRIBUTE23 => NULL,
			X_ATTRIBUTE24 => NULL,
			X_ATTRIBUTE25 => NULL,
			X_ATTRIBUTE26 => NULL,
			X_ATTRIBUTE27 => NULL,
			X_ATTRIBUTE28 => NULL,
			X_ATTRIBUTE29 => NULL,
			X_ATTRIBUTE30 => NULL,
			X_ATTRIBUTE_CATEGORY => NULL,
			X_CREATION_DATE => sysdate,
			X_CREATED_BY => 0,
			X_LAST_UPDATE_DATE => sysdate,
			X_LAST_UPDATED_BY => 0,
			X_LAST_UPDATE_LOGIN => NULL);


	IF (p_commit <> FND_API.G_FALSE) THEN
		COMMIT;
	END IF;
	l_migrate_count := l_migrate_count + 1;
	EXCEPTION
		WHEN e_already_exists THEN
			NULL;
	END;
	END LOOP;

	-- dbms_output.put_line ('Completed GRADES migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'MTL_LOT_NUMBERS',
		p_context         => 'GRADES',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'MTL_LOT_NUMBERS',
			p_context         => 'GRADES',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
END;

/*====================================================================
--  PROCEDURE:
--    migrate_lot_conversions
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the Lot conversions
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_lot_conversions(p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_lot_conversions
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, p_start_rowid			IN		ROWID
, p_end_rowid			IN		ROWID
, x_failure_count		OUT NOCOPY	NUMBER) IS

	l_rowid			ROWID;
	l_disable_flag		VARCHAR2(1);
	e_already_exists	EXCEPTION;
	l_count			PLS_INTEGER;
	l_inventory_item_id	NUMBER;
	l_failure_count		PLS_INTEGER;
	l_migrate_count		PLS_INTEGER;
	l_from_unit_of_measure	VARCHAR2(25);
	l_from_uom_code		VARCHAR2(3);
	l_from_uom_class	VARCHAR2(10);
	l_to_unit_of_measure	VARCHAR2(25);
	l_to_uom_code		VARCHAR2(3);
	l_field_name		VARCHAR(50);
	l_field_value		VARCHAR(50);
	l_conversion_id		NUMBER;
	l_conv_audit_id		NUMBER;
	l_conv_audit_detail_id	NUMBER;
	l_reason_id		NUMBER;
	l_organization_id	NUMBER;
	l_locator_id		NUMBER;
	l_subinventory_ind_flag	VARCHAR2(1);
	l_migrated_ind		PLS_INTEGER;

	CURSOR c_ic_item_cnv IS
	SELECT m.parent_lot_number, m.lot_number, m.organization_id, c.*
	FROM ic_item_cnv c, ic_lots_mst_mig m
	WHERE
	    c.rowid BETWEEN p_start_rowid AND p_end_rowid and
	    c.item_id = m.item_id and
	    c.lot_id = m.lot_id and
	    nvl(m.migrated_ind,0) = 1 and
	    m.conv_migrated_ind is NULL;


	CURSOR c_gmi_item_conv_audit
		(pconversion_id	NUMBER) IS
	SELECT *
	FROM gmi_item_conv_audit
	WHERE conversion_id = pconversion_id;

	CURSOR c_gmi_item_conv_audit_details
		(pconv_audit_id	NUMBER) IS
	SELECT *
	FROM gmi_item_conv_audit_details
	WHERE conv_audit_id = pconv_audit_id;
BEGIN
	x_failure_count := 0;
	l_migrate_count	:= 0;
	-- dbms_output.put_line ('Started LOT CONVERSION migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'IC_LOTS_CNV',
		p_context         => 'LOT CONVERSION',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');

	FOR c in c_ic_item_cnv LOOP
	BEGIN
		-- Get the discrete item id
		INV_OPM_Item_Migration.get_ODM_item (
			p_migration_run_id => p_migration_run_id,
			p_item_id => c.item_id,
			p_organization_id => c.organization_id,
			p_mode => NULL,
			p_commit => 'Y',
			x_inventory_item_id => l_inventory_item_id,
			x_failure_count => l_failure_count);
		IF (l_failure_count > 0) THEN
			-- Log Error
			-- dbms_output.put_line ('Failed to get discrete item. Item id :'||to_char(c.item_id));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_ITEM_MIG_FAILED',
				p_table_name      => 'IC_ITEM_CNV',
				p_context         => 'LOT CONVERSION',
				p_param1          => INV_GMI_Migration.org(c.organization_id),
				p_param2          => INV_GMI_Migration.item(c.item_id),
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise FND_API.G_EXC_ERROR;
		END IF;

		l_field_name := 'From UOM data';
		l_field_value := 'Organization = '||to_char(c.organization_id)||', Item Id = '||to_char(l_inventory_item_id);
		SELECT bu.unit_of_measure,
		       bu.uom_code,
		       bu.uom_class
		INTO l_from_unit_of_measure,
			l_from_uom_code,
			l_from_uom_class
		FROM mtl_system_items_b i,
			mtl_units_of_measure iu,
			mtl_units_of_measure bu
		WHERE
			i.organization_id = c.organization_id
			AND i.inventory_item_id = l_inventory_item_id
			AND i.primary_uom_code = iu.uom_Code
			AND iu.uom_class = bu.uom_class
			AND bu.base_uom_flag = 'Y';

		l_field_name := 'To UOM data';
		l_field_value := 'UM Type = '||c.um_type;
		SELECT unit_of_measure, uom_code
		INTO l_to_unit_of_measure, l_to_uom_code
		FROM mtl_units_of_measure
		WHERE
			uom_class = c.um_type AND
			base_uom_flag = 'Y';

		-- Check if the conversion already exists
		SELECT count(*)
		INTO l_count
		FROM mtl_lot_uom_class_conversions
		WHERE
			organization_id = c.organization_id AND
			inventory_item_id = l_inventory_item_id AND
			lot_number = c.lot_number AND
			from_uom_class = l_from_uom_class AND
			to_uom_class = c.um_type;

		IF (l_count > 0) THEN
			-- No migration needed, skip it.
			-- dbms_output.put_line ('Lot conversion already exist. org_id, inventory_item_id, lot num, from class, to class'||to_char(c.organization_id)||', '||to_char(l_inventory_item_id)||', '||c.lot_number||', '||l_from_uom_class||', '||c.um_type);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_PROCEDURE,
				p_message_token   => 'GMI_MIG_LOT_CONV_EXISTS',
				p_table_name      => 'IC_ITEM_CNV',
				p_context         => 'LOT CONVERSIONS',
				p_param1          => INV_GMI_Migration.org(c.organization_id),
				p_param2          => INV_GMI_Migration.ditem(c.organization_id, l_inventory_item_id),
				p_param3          => c.lot_number,
				p_param4          => l_from_uom_class,
				p_param5          => c.um_type,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise FND_API.G_EXC_ERROR;
		END IF;

		SELECT MTL_CONVERSION_ID_S.NEXTVAL INTO l_conversion_id FROM DUAL;

		INSERT INTO mtl_lot_uom_class_conversions(
			conversion_id,
			lot_number,
			organization_id,
			inventory_item_id,
			from_unit_of_measure,
			from_uom_code,
			from_uom_class,
			to_unit_of_measure,
			to_uom_code,
			to_uom_class,
			conversion_rate,
			disable_date,
			event_spec_disp_id,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
		VALUES(
			l_conversion_id,
			c.lot_number,
			c.organization_id,
			l_inventory_item_id,
			l_from_unit_of_measure,
			l_from_uom_code,
			l_from_uom_class,
			l_to_unit_of_measure,
			l_to_uom_code,
			c.um_type,
			c.type_factor,
			DECODE (c.delete_mark, 1, c.last_update_date, NULL),
			c.event_spec_disp_id,
			c.created_by,
			c.creation_date,
			c.last_updated_by,
			c.last_update_date,
			c.last_update_login
		);

		FOR cuadit in c_gmi_item_conv_audit(c.conversion_id) LOOP

			SELECT MTL_CONV_AUDIT_ID_S.NEXTVAL
			INTO l_conv_audit_id FROM DUAL;

			l_field_name := 'Reason Id';
			l_field_value := 'Reason Code = ' || cuadit.reason_code;

			IF cuadit.reason_code IS NOT NULL THEN
				SELECT reason_id INTO l_reason_id
				FROM sy_reas_cds_b
				WHERE
					reason_code = cuadit.reason_code;
			END IF;

 			-- Jatinder - 12/18/06- Bug 5722698. Added NVL to the
			-- UPDATE_BATCH_INDICATOR column.
			INSERT INTO mtl_lot_conv_audit(
				conv_audit_id,
				conversion_id,
				conversion_date,
				update_type_indicator,
				batch_id,
				reason_id,
				old_conversion_rate,
				new_conversion_rate,
				event_spec_disp_id,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date
			)VALUES(
				l_conv_audit_id,
				l_conversion_id,
				cuadit.conversion_date,
				NVL(cuadit.update_batch_indicator, 0),
				cuadit.batch_id,
				l_reason_id,
				cuadit.old_type_factor,
				cuadit.new_type_factor,
				cuadit.event_spec_disp_id,
				cuadit.created_by,
				cuadit.creation_date,
				cuadit.last_updated_by,
				cuadit.last_update_date);

			FOR adetail in c_gmi_item_conv_audit_details (cuadit.conv_audit_id) LOOP

				-- Get the organization / subinventory for the warehouse
				l_field_name := 'Organization/ Subinventory';
				l_field_value := 'Warehouse = '||adetail.whse_code;
				SELECT organization_id, subinventory_ind_flag, migrated_ind
				INTO l_organization_id, l_subinventory_ind_flag, l_migrated_ind
				FROM ic_whse_mst
				WHERE
					whse_code = adetail.whse_code;
				IF (nvl(l_migrated_ind,0) <> 1) THEN
					-- dbms_output.put_line ('Warehouse not mmigrated: '||adetail.whse_code);
					GMA_COMMON_LOGGING.gma_migration_central_log (
						p_run_id          => p_migration_run_id,
						p_log_level       => FND_LOG.LEVEL_ERROR,
						p_message_token   => 'GMI_MIG_WHSE_NOT_MIGRATED',
						p_table_name      => 'IC_ITEM_CNV',
						p_context         => 'LOT CONVERSION',
						p_param1          => adetail.whse_code,
						p_param2          => NULL,
						p_param3          => NULL,
						p_param4          => NULL,
						p_param5          => NULL,
						p_db_error        => NULL,
						p_app_short_name  => 'GMI');
					RAISE FND_API.G_EXC_ERROR; -- Skip this conversion
				END IF;

				-- Get the Locator id
				l_field_name := 'Loctor Id';
				l_field_value := 'Warehouse/ Location =' ||adetail.whse_code
					||'/ '||adetail.location;
				-- Jatinder - 12/1/06 - initialize the locator_id - 5692408
				l_locator_id := NULL;
				IF (G_DEFAULT_LOCT is NULL) THEN
					SELECT fnd_profile.value ('IC$DEFAULT_LOCT')
					INTO G_DEFAULT_LOCT
					FROM dual;
				END IF;
				IF (adetail.location <> G_DEFAULT_LOCT) THEN
				BEGIN
					SELECT locator_id INTO l_locator_id
					FROM ic_loct_mst
					WHERE
						whse_code = adetail.whse_code AND
						location = adetail.location;

					IF (l_locator_id is NULL) THEN
						-- dbms_output.put_line ('Location not migrated for whse, loc :'||adetail.whse_code||', '||adetail.location);
						GMA_COMMON_LOGGING.gma_migration_central_log (
							p_run_id          => p_migration_run_id,
							p_log_level       => FND_LOG.LEVEL_ERROR,
							p_message_token   => 'GMI_MIG_LOC_NOT_MIGRATED',
							p_table_name      => 'IC_ITEM_CNV',
							p_context         => 'LOT CONVERSION',
							p_param1          => adetail.whse_code,
							p_param2          => adetail.location,
							p_param3          => NULL,
							p_param4          => NULL,
							p_param5          => NULL,
							p_db_error        => NULL,
							p_app_short_name  => 'GMI');
						RAISE FND_API.G_EXC_ERROR; -- Skip this conversion
					END IF;
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						-- Create locator in discrete ( dynamic locator)
						l_failure_count := 0;
						inv_migrate_process_org.create_location(
							p_migration_run_id => p_migration_run_id,
							p_organization_id => l_organization_id,
							p_subinventory_code => adetail.whse_code,
							p_location => adetail.location,
							p_loct_desc => adetail.location,
							p_start_date_active => adetail.creation_date,
							p_commit => FND_API.G_TRUE,
							x_location_id => l_locator_id,
							x_failure_count => l_failure_count,
							p_segment2 => NULL,
							p_segment3 => NULL,
							p_segment4 => NULL,
							p_segment5 => NULL,
							p_segment6 => NULL,
							p_segment7 => NULL,
							p_segment8 => NULL,
							p_segment9 => NULL,
							p_segment10 => NULL,
							p_segment11 => NULL,
							p_segment12 => NULL,
							p_segment13 => NULL,
							p_segment14 => NULL,
							p_segment15 => NULL,
							p_segment16 => NULL,
							p_segment17 => NULL,
							p_segment18 => NULL,
							p_segment19 => NULL,
							p_segment20 => NULL);

						IF (l_failure_count > 0) THEN
							-- Log error
							-- dbms_output.put_line ( 'Unable to create the locator for dynamic OPM location :' || adetail.whse_code ||', '||adetail.location );
							GMA_COMMON_LOGGING.gma_migration_central_log (
								p_run_id          => p_migration_run_id,
								p_log_level       => FND_LOG.LEVEL_ERROR,
								p_message_token   => 'GMI_LOC_CREATION_FAILED',
								p_table_name      => 'IC_LOCT_INV',
								p_context         => 'INVENTORY BALANCE',
								p_param1          => adetail.whse_code,
								p_param2          => adetail.location,
								p_param3          => NULL,
								p_param4          => NULL,
								p_param5          => NULL,
								p_db_error        => NULL,
								p_app_short_name  => 'GMI');
							raise FND_API.G_EXC_ERROR;
						END IF;
				END;
				END IF;

				SELECT MTL_CONV_AUDIT_DETAIL_ID_S.NEXTVAL
				INTO l_conv_audit_detail_id FROM DUAL;
				INSERT INTO mtl_lot_conv_audit_details(
					conv_audit_detail_id,
					conv_audit_id,
					revision,
					organization_id,
					subinventory_code,
					lpn_id,
					locator_id,
					old_primary_qty,
					old_secondary_qty,
					new_primary_qty,
					new_secondary_qty,
					transaction_primary_qty,
					transaction_secondary_qty,
					transaction_update_flag,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date
				)VALUES(
					l_conv_audit_detail_id,
					l_conv_audit_id,
					NULL,
					l_organization_id,
					adetail.whse_code,
					NULL,
					l_locator_id,
					adetail.old_onhand_qty,
					adetail.old_onhand_qty2,
					adetail.new_onhand_qty,
					adetail.new_onhand_qty2,
					adetail.trans_qty,
					adetail.trans_qty2,
					adetail.trans_update_flag,
					adetail.created_by,
					adetail.creation_date,
					adetail.last_updated_by,
					adetail.last_update_date
					);
			END LOOP;
		END LOOP;
		UPDATE ic_lots_mst_mig
		SET
			conv_migrated_ind = 1,
			last_update_date = sysdate,
			last_updated_by = 0
		WHERE
			item_id = c.item_id AND
			organization_id = c.organization_id AND
			lot_number = c.lot_number;

		IF (p_commit <> FND_API.G_FALSE) THEN
			COMMIT;
		END IF;
		l_migrate_count := l_migrate_count + 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- dbms_output.put_line ('Cannot find '||l_field_name||' for '||l_field_value);
			ROLLBACK;
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_NO_DATA_FOR_FIELD',
				p_table_name      => 'IC_ITEM_CNV',
				p_context         => 'LOT CONVERSION',
				p_param1          => l_field_name,
				p_param2          => l_field_value,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK;
			x_failure_count := x_failure_count + 1;
			NULL; -- Skip to the next row.
	END;
	END LOOP;

	-- dbms_output.put_line ('Completed LOT CONVERSION migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_PROCEDURE,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'IC_ITEM_CNV',
		p_context         => 'LOT CONVERSION',
		p_param1          => l_migrate_count,
		p_param2          => x_failure_count,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'IC_ITEM_CNV',
			p_context         => 'LOT CONVERSION',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
END;

/*====================================================================
--  PROCEDURE:
--    init_doc_seq
--
--  DESCRIPTION:
--    This PL/SQL procedure will insert doc sequence record, if needed
--    The procedure is autonomous, becuase the transfer API has autonomous
--    routine to get the doc_no
--
--  PARAMETERS:
--    p_orgn_code    - organization of the doc sequence.
--
--  SYNOPSIS:
--    init_doc_seq (p_orgn_code    => l_orgn_code);
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE init_doc_seq ( p_orgn_code	IN	VARCHAR2) IS
	PRAGMA AUTONOMOUS_TRANSACTION;

	l_count		PLS_INTEGER;
	l_rowid		ROWID;
BEGIN
	INSERT INTO sy_docs_seq(
		doc_type,
		orgn_code,
		assignment_type,
		last_assigned,
		format_size,
		pad_char,
		delete_mark,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		trans_cnt)
	SELECT
		'DXFR',
		p_orgn_code,
		2,
		0,
		6,
		0,
		0,
		sysdate,
		0,
		sysdate,
		0,
		0
	FROM dual
	WHERE
		NOT EXISTS (
			SELECT 1
			FROM sy_docs_seq
			WHERE
				doc_type = 'DXFR' AND
				orgn_code = p_orgn_code);


	SELECT count(*)
	INTO l_count
	FROM sy_reas_cds
	WHERE
		reason_code = 'CNVM';

	IF l_count = 0 THEN
		sy_reas_cds_pkg.insert_row (
			x_rowid  => l_rowid,
			x_reason_code  => 'CNVM',
			x_reason_desc2  => NULL,
			x_reason_type  => 0,
			x_flow_type  => 0,
			x_auth_string  => NULL,
			x_delete_mark  => 0,
			x_text_code  => NULL,
			x_trans_cnt  => 0,
			x_reason_desc1  => 'OPM Convergence Migration',
			x_creation_date  => sysdate,
			x_created_by  => 0,
			x_last_update_date  => sysdate,
			x_last_updated_by  => 0,
			x_last_update_login  => NULL);

		UPDATE sy_reas_cds_b
		SET reason_id = -99
		WHERE reason_code = 'CNVM';
	END IF;
	COMMIT;
END;
/*====================================================================
--  PROCEDURE:
--    migrate_inventory_balances
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the Inventory Balances
--    to Oracle Inventory for the convergence project.
--
--  PARAMETERS:
--    P_migration_run_id    - id to use to right to migration log
--    p_commit - flag to indicate if commit shouldbe performed.
--    x_failure_count - Number of exceptions occurred.
--
--  SYNOPSIS:
--    migrate_inventory_balances(p_migartion_id    => l_migration_id,
--                          p_commit => l_commit ,
--                          x_exception_count => l_exception_count );
--
--  HISTORY
--	Jatinder Gogna - Created - 03/25/05
--====================================================================*/

PROCEDURE migrate_inventory_balances
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER) IS

l_prev_whse_code	VARCHAR2(4);
l_prev_organization_id	NUMBER;
l_skip_to_next_whse	PLS_INTEGER;
l_migrate_count		PLS_INTEGER;
l_orgn_code		VARCHAR2(4);
l_co_code		VARCHAR2(4);
l_subinventory_ind_flag	VARCHAR2(1);
l_whse_loct_ctl		PLS_INTEGER;
l_item_loct_ctl		PLS_INTEGER;
l_lot_ctl		PLS_INTEGER;
l_noninv_ind		PLS_INTEGER;
l_item_um		VARCHAR2(4);
l_item_no		VARCHAR2(32);
l_organization_id	NUMBER;
l_inventory_item_id	NUMBER;
l_subinventory_code	VARCHAR2(10);
l_locator_id		NUMBER;
l_migrated_ind		PLS_INTEGER;
l_last_updated_by	NUMBER;
l_field_name		VARCHAR(50);
l_field_value		VARCHAR(50);
l_period_id		INTEGER;
l_open_past_period	BOOLEAN;
l_period_set_name 	VARCHAR2(15);
l_accounted_period_type	VARCHAR2(15);
l_period_name 		VARCHAR2(15);
l_period_year 		NUMBER;
l_period_number		NUMBER;
l_period_end_date	DATE;
l_prior_period_open     BOOLEAN;
l_new_acct_period_id    NUMBER;
l_last_scheduled_close_date   DATE;
l_duplicate_open_period BOOLEAN;
l_commit_complete       BOOLEAN;
l_recs_displayed        NUMBER;
l_failure_count         NUMBER;
l_return_status         VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(1000);
l_hdr_rec		gmivdx.hdr_type;
l_line_rec_tbl		gmivdx.line_type_tbl;
l_lot_rec_tbl		gmivdx.lot_type_tbl;
o_hdr_row		gmi_discrete_transfers%ROWTYPE;
o_line_row_tbl		gmivdx.line_row_tbl;
o_lot_row_tbl		gmivdx.lot_row_tbl;
l_transaction_set_id	NUMBER;
l_lot_number		VARCHAR2(80);
l_parent_lot_number	VARCHAR2(80);
l_count			PLS_INTEGER;


e_skip_whse		EXCEPTION;

-- Bug 8363586
-- Added filter - and delete_mark = 0
CURSOR c_ic_loct_inv IS
SELECT rowid, l.*
FROM ic_loct_inv l
WHERE migrated_ind is NULL AND
	ROUND(loct_onhand, 5) <> 0 AND
   delete_mark = 0
ORDER by whse_code;

-- Get the subinventory for the warehouse
CURSOR c_subinventory (p_whse_code 	VARCHAR2) IS
SELECT subinventory_code, count(*)
FROM ic_loct_mst o, mtl_item_locations d
WHERE o.locator_id = d.inventory_location_id AND
    o.whse_code = p_whse_code
GROUP BY whse_code, subinventory_code
ORDER by 2 desc;

-- Get the current period info
CURSOR c_future_periods IS
SELECT period_name, period_year,
	period_number , end_date
INTO l_period_name, l_period_year,
	l_period_number, l_period_end_date
FROM org_acct_periods_v
WHERE rec_type = 'GL_PERIOD' AND
	period_set_name = l_period_set_name AND
	accounted_period_type = l_accounted_period_type AND
	end_date > l_last_scheduled_close_date AND
	start_date < sysdate;
BEGIN
	x_failure_count:= 0;
	l_migrate_count	:= 0;
	l_skip_to_next_whse := 0;

	-- dbms_output.put_line ('Started INVENTORY BALANCE migration');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_ERROR,
		p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
		p_table_name      => 'IC_LOCT_INV',
		p_context         => 'INVENTORY BALANCE',
		p_param1          => NULL,
		p_param2          => NULL,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');

	FOR bal in c_ic_loct_inv LOOP
	BEGIN
		-- SAVEPOINT bal_migration_start;

		IF (bal.whse_code = l_prev_whse_code and l_skip_to_next_whse = 1) THEN
			RAISE e_skip_whse;
		END IF;

		IF (bal.whse_code <> l_prev_whse_code or l_prev_whse_code IS NULL) THEN
			-- New warehouse, reset some of the values
			l_skip_to_next_whse := 0;
			l_prev_whse_code := bal.whse_code;

			-- Check if warehouse has been migrated
			SELECT orgn_code, subinventory_ind_flag, loct_ctl,
				organization_id, migrated_ind, last_updated_by
			INTO l_orgn_code, l_subinventory_ind_flag, l_whse_loct_ctl,
				l_organization_id, l_migrated_ind, l_last_updated_by
			FROM ic_whse_mst
			WHERE
				whse_code = bal.whse_code;

			IF (l_migrated_ind is NULL or l_organization_id is NULL) THEN
				-- dbms_output.put_line ('Warehouse not migrated :'||bal.whse_code);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_WHSE_NOT_MIGRATED',
					p_table_name      => 'IC_LOCT_INV',
					p_context         => 'INVENTORY BALANCE',
					p_param1          => bal.whse_code,
					p_param2          => NULL,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				RAISE e_skip_whse; -- skip all rows for the warehouse
			END IF;

			-- Check in the inventory period is open in discrete
			invttmtx.tdatechk (l_organization_id, trunc(sysdate), l_period_id,
				l_open_past_period);
			invttmtx.G_ORG_ID := NULL;
			IF (l_period_id = -1) THEN
				-- dbms_output.put_line ('Error retrieving open period for org :' ||to_char(l_organization_id));
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'INV_RETRIEVE_PERIOD',
					p_table_name      => 'IC_LOCT_INV',
					p_context         => 'INVENTORY BALANCE',
					p_param1          => NULL,
					p_param2          => NULL,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'INV');
				RAISE e_skip_whse; -- skip all rows for the warehouse
			ELSIF (l_period_id = 0) THEN
				-- dbms_output.put_line ('No open period for org :' ||to_char(l_organization_id));
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_NO_ODM_OPEN_PERIOD',
					p_table_name      => 'IC_LOCT_INV',
					p_context         => 'INVENTORY BALANCE',
					p_param1          => INV_GMI_Migration.org(l_organization_id),
					p_param2          => NULL,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');

				-- Try to open the period
				l_field_name := 'Organization Definition';
				l_field_value := INV_GMI_Migration.org(l_organization_id);
				l_skip_to_next_whse := 1;
				SELECT b.period_set_name, b.accounted_period_type
				INTO l_period_set_name, l_accounted_period_type
				FROM   org_organization_definitions a,
					gl_sets_of_books b
				WHERE a.organization_id = l_organization_id
				AND a.set_of_books_id = b.set_of_books_id;
				l_skip_to_next_whse := 0;

				SELECT  NVL(MAX(schedule_close_date), sysdate)
				INTO	l_last_scheduled_close_date
				FROM    org_acct_periods
				WHERE   organization_id = l_organization_id;

				-- Open all future periods till the sysdate
				FOR fp IN c_future_periods LOOP
					-- Open the period
					-- dbms_output.put_line ('Opening period year/num/name' || fp.period_year ||'/'||fp.period_number||'/'||fp.period_name);
					GMA_COMMON_LOGGING.gma_migration_central_log (
						p_run_id          => p_migration_run_id,
						p_log_level       => FND_LOG.LEVEL_ERROR,
						p_message_token   => 'GMI_MIG_OPENING_ODM_PERIOD',
						p_table_name      => 'IC_LOCT_INV',
						p_context         => 'INVENTORY BALANCE',
						p_param1          => INV_GMI_Migration.org(l_organization_id),
						p_param2          => fp.period_year,
						p_param3          => fp.period_number,
						p_param4          => fp.period_name,
						p_param5          => NULL,
						p_db_error        => NULL,
						p_app_short_name  => 'GMI');

					CST_AccountingPeriod_PUB.Open_Period(
						p_api_version               => 1.0,
						p_org_id                    => l_organization_id,
						p_user_id                   => l_last_updated_by,
						p_login_id                  => NULL,
						p_acct_period_type          => l_accounted_period_type,
						p_org_period_set_name       => l_period_set_name,
						p_open_period_name          => fp.period_name,
						p_open_period_year          => fp.period_year,
						p_open_period_num           => fp.period_number,
						x_last_scheduled_close_date => l_last_scheduled_close_date,
						p_period_end_date           => fp.end_date,
						x_prior_period_open         => l_prior_period_open,
						x_new_acct_period_id        => l_new_acct_period_id,
						x_duplicate_open_period     => l_duplicate_open_period,
						x_commit_complete           => l_commit_complete,
						x_return_status             => l_return_status );

					IF (NOT l_prior_period_open) THEN
						-- dbms_output.put_line ('Prior period is not open');
						GMA_COMMON_LOGGING.gma_migration_central_log (
							p_run_id          => p_migration_run_id,
							p_log_level       => FND_LOG.LEVEL_ERROR,
							p_message_token   => 'INV_PREV_PD_NOT_OPEN_10G',
							p_table_name      => 'IC_LOCT_INV',
							p_context         => 'INVENTORY BALANCE',
							p_param1          => NULL,
							p_param2          => NULL,
							p_param3          => NULL,
							p_param4          => NULL,
							p_param5          => NULL,
							p_db_error        => NULL,
							p_app_short_name  => 'INV');
						RAISE e_skip_whse; -- skip all rows for the warehouse
					ELSIF (l_new_acct_period_id = 0) THEN
						-- dbms_output.put_line ('Cannot get next period');
						GMA_COMMON_LOGGING.gma_migration_central_log (
							p_run_id          => p_migration_run_id,
							p_log_level       => FND_LOG.LEVEL_ERROR,
							p_message_token   => 'INV_CANNOT_GET_NEXT_PERIOD',
							p_table_name      => 'IC_LOCT_INV',
							p_context         => 'INVENTORY BALANCE',
							p_param1          => NULL,
							p_param2          => NULL,
							p_param3          => NULL,
							p_param4          => NULL,
							p_param5          => NULL,
							p_db_error        => NULL,
							p_app_short_name  => 'INV');
						RAISE e_skip_whse; -- skip all rows for the warehouse
					ELSIF (l_duplicate_open_period) THEN
						-- dbms_output.put_line ('Period opened by another user');
						GMA_COMMON_LOGGING.gma_migration_central_log (
							p_run_id          => p_migration_run_id,
							p_log_level       => FND_LOG.LEVEL_ERROR,
							p_message_token   => 'INV_DUPLICATE_OPEN_PERIOD',
							p_table_name      => 'IC_LOCT_INV',
							p_context         => 'INVENTORY BALANCE',
							p_param1          => NULL,
							p_param2          => NULL,
							p_param3          => NULL,
							p_param4          => NULL,
							p_param5          => NULL,
							p_db_error        => NULL,
							p_app_short_name  => 'INV');
						RAISE e_skip_whse; -- skip all rows for the warehouse
					ELSIF (NOT l_commit_complete) THEN
						-- dbms_output.put_line ('No Change made for period opening');
						GMA_COMMON_LOGGING.gma_migration_central_log (
							p_run_id          => p_migration_run_id,
							p_log_level       => FND_LOG.LEVEL_ERROR,
							p_message_token   => 'INV_NO_CHANGES',
							p_table_name      => 'IC_LOCT_INV',
							p_context         => 'INVENTORY BALANCE',
							p_param1          => NULL,
							p_param2          => NULL,
							p_param3          => NULL,
							p_param4          => NULL,
							p_param5          => NULL,
							p_db_error        => NULL,
							p_app_short_name  => 'INV');
						RAISE e_skip_whse; -- skip all rows for the warehouse
					END IF;
				END LOOP; -- Opening ODM periods
			END IF; -- ODM period open check / period creation

			-- Setup document sequencing for warehouse organization, if it is not there.
			init_doc_seq (l_orgn_code);
		END IF;	-- First warehouse row

		-- Start the balance migration
		-- Prepare the data for the migration
		-- Get the discrete item id
		fnd_msg_pub.initialize;
		INV_OPM_Item_Migration.get_ODM_item (
			p_migration_run_id => p_migration_run_id,
			p_item_id => bal.item_id,
			p_organization_id => l_organization_id,
			p_mode => '',
			p_commit => FND_API.G_TRUE,
			x_inventory_item_id => l_inventory_item_id,
			x_failure_count => l_failure_count);
		IF (l_failure_count > 0) THEN
			-- Log Error
			-- dbms_output.put_line ('Failed to migrate item,org = '||to_char(bal.item_id)||', '||to_char(l_organization_id));
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_ITEM_MIG_FAILED',
				p_table_name      => 'IC_LOCT_INV',
				p_context         => 'INVENTORY BALANCE',
				p_param1          => INV_GMI_Migration.org(l_organization_id),
				p_param2          => INV_GMI_Migration.item(bal.item_id),
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise FND_API.G_EXC_ERROR;
		END IF;

		l_field_name := 'OPM Item attributes';
		l_field_value := 'OPM item id = '||to_char(bal.item_id);

		SELECT loct_ctl, item_um, lot_ctl, noninv_ind, item_no
		INTO l_item_loct_ctl, l_item_um, l_lot_ctl, l_noninv_ind, l_item_no
		FROM ic_item_mst_b
		WHERE
			item_id = bal.item_id;

		IF (l_noninv_ind = 1) THEN
			-- Log Error
			-- dbms_output.put_line ('Cannot migrate balances for non-inventory item '|| l_item_no);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_NONINV_ITEM',
				p_table_name      => 'IC_LOCT_INV',
				p_context         => 'INVENTORY BALANCE',
				p_param1          => l_item_no,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			raise FND_API.G_EXC_ERROR;
		END IF;

		-- Get the discrete lot number
		l_lot_number := NULL;
		l_parent_lot_number := NULL;

		IF (bal.lot_id > 0) THEN -- Lot controlled item
			fnd_msg_pub.initialize;
			INV_OPM_Lot_Migration.get_ODM_lot (
				p_migration_run_id => p_migration_run_id,
				p_item_id => bal.item_id,
				p_lot_id => bal.lot_id,
				p_whse_code => bal.whse_code,
				p_orgn_code => NULL,
				p_location => bal.location,
				p_commit => FND_API.G_TRUE,
				x_lot_number => l_lot_number,
				x_parent_lot_number => l_parent_lot_number,
				x_failure_count => l_failure_count);

			IF (l_failure_count > 0) THEN
				-- Log Error
				-- dbms_output.put_line ('Failed to migrate lot = '||to_char(bal.lot_id)||', '||bal.whse_code||', '||bal.location);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_LOT_MIG_FAILED',
					p_table_name      => 'IC_LOCT_INV',
					p_context         => 'INVENTORY BALANCE',
					p_param1          => INV_GMI_Migration.item(bal.item_id),
					p_param2          => INV_GMI_Migration.lot(bal.lot_id),
					p_param3          => bal.whse_code,
					p_param4          => bal.location,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				raise FND_API.G_EXC_ERROR;
			END IF;
		END IF;

		-- Get the loctor id
		l_field_name := 'Default Location Profile';
		l_field_value := NULL;
		l_locator_id := NULL;
		l_subinventory_code := NULL;
		IF (G_DEFAULT_LOCT is NULL) THEN
			SELECT fnd_profile.value ('IC$DEFAULT_LOCT')
			INTO G_DEFAULT_LOCT
			FROM dual;
		END IF;
		IF ( l_whse_loct_ctl <> 0 and l_item_loct_ctl <> 0 and
			bal.location <> G_DEFAULT_LOCT) THEN
		BEGIN
			SELECT ol.locator_id, dl.subinventory_code
			INTO l_locator_id, l_subinventory_code
			FROM ic_loct_mst ol, mtl_item_locations dl
			WHERE
				ol.whse_code = bal.whse_code AND
				ol.location = bal.location AND
				ol.locator_id = dl.inventory_location_id (+);

			IF (l_locator_id is NULL) THEN
				-- Log error
				-- dbms_output.put_line ( 'Warehouse location not migrated :' || bal.whse_code ||', '||bal.location );
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_LOC_NOT_MIGRATED',
					p_table_name      => 'IC_LOCT_INV',
					p_context         => 'INVENTORY BALANCE',
					p_param1          => bal.whse_code,
					p_param2          => bal.location,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				raise FND_API.G_EXC_ERROR;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				-- Create locator in discrete ( dynamic locator)
				l_failure_count := 0;
				-- Get the subinventory for the warehouse
				OPEN c_subinventory (bal.whse_code);
				FETCH c_subinventory INTO l_subinventory_code, l_count;
				CLOSE c_subinventory;

				IF (l_subinventory_code is NULL) THEN
					l_subinventory_code := bal.whse_code;
				END IF;

				inv_migrate_process_org.create_location(
					p_migration_run_id => p_migration_run_id,
					p_organization_id => l_organization_id,
					p_subinventory_code => l_subinventory_code,
					p_location => bal.location,
					p_loct_desc => bal.location,
					p_start_date_active => bal.creation_date,
					p_commit => FND_API.G_TRUE,
					x_location_id => l_locator_id,
					x_failure_count => l_failure_count,
					p_segment2 => NULL,
					p_segment3 => NULL,
					p_segment4 => NULL,
					p_segment5 => NULL,
					p_segment6 => NULL,
					p_segment7 => NULL,
					p_segment8 => NULL,
					p_segment9 => NULL,
					p_segment10 => NULL,
					p_segment11 => NULL,
					p_segment12 => NULL,
					p_segment13 => NULL,
					p_segment14 => NULL,
					p_segment15 => NULL,
					p_segment16 => NULL,
					p_segment17 => NULL,
					p_segment18 => NULL,
					p_segment19 => NULL,
					p_segment20 => NULL);
				-- Log error
				IF (l_failure_count > 0) THEN
					-- dbms_output.put_line ( 'Warehouse location not migrated :' || bal.whse_code ||', '||bal.location );
					GMA_COMMON_LOGGING.gma_migration_central_log (
						p_run_id          => p_migration_run_id,
						p_log_level       => FND_LOG.LEVEL_ERROR,
						p_message_token   => 'GMI_LOC_CREATION_FAILED',
						p_table_name      => 'IC_LOCT_INV',
						p_context         => 'INVENTORY BALANCE',
						p_param1          => bal.whse_code,
						p_param2          => bal.location,
						p_param3          => NULL,
						p_param4          => NULL,
						p_param5          => NULL,
						p_db_error        => NULL,
						p_app_short_name  => 'GMI');
					raise FND_API.G_EXC_ERROR;
				END IF;
		END;
		END IF;

		-- Get the subinventory for non-location controlled warehouse. For
		-- Location controlled whse, it determined as part of locator.
		IF (l_subinventory_code is NULL) THEN
			l_subinventory_code := bal.whse_code;
		END IF;

		-- Header record
		l_hdr_rec.orgn_code := l_orgn_code;
		IF (bal.loct_onhand < 0) THEN
			l_hdr_rec.transfer_type := 1; -- Discrete to process
		ELSE
			l_hdr_rec.transfer_type := 0; -- Process to Discrete
		END IF;
		l_hdr_rec.trans_date := sysdate;
		l_hdr_rec.comments := 'OPM Inventory Convergence migration';

		-- Line record
		l_line_rec_tbl(1).line_no := 1;
		l_line_rec_tbl(1).opm_item_id := bal.item_id;
		l_line_rec_tbl(1).opm_whse_code := bal.whse_code;
		l_line_rec_tbl(1).opm_location := bal.location;
		l_line_rec_tbl(1).opm_lot_id := 0;
		IF (bal.lot_id > 0) THEN
			l_line_rec_tbl(1).opm_lot_id := NULL;
		END IF;
		l_line_rec_tbl(1).odm_inv_organization_id := l_organization_id;
		l_line_rec_tbl(1).odm_item_id := l_inventory_item_id;
		l_line_rec_tbl(1).odm_subinventory := l_subinventory_code;
		l_line_rec_tbl(1).opm_reason_code := 'CNVM';
		l_line_rec_tbl(1).odm_locator_id := l_locator_id;
		l_line_rec_tbl(1).odm_lot_number := NULL;
		IF (bal.loct_onhand < 0) THEN
			l_line_rec_tbl(1).quantity := -bal.loct_onhand;
			l_line_rec_tbl(1).quantity2 := -bal.loct_onhand2;
		ELSE
			l_line_rec_tbl(1).quantity := bal.loct_onhand;
			l_line_rec_tbl(1).quantity2 := bal.loct_onhand2;
		END IF;
		l_line_rec_tbl(1).quantity_um := l_item_um;


		-- Lot record ( for lot controlled items)
		IF (bal.lot_id > 0) THEN
			l_lot_rec_tbl(1).line_no := 1;
			l_lot_rec_tbl(1).opm_lot_id := bal.lot_id;
			l_lot_rec_tbl(1).odm_lot_number := l_lot_number;
			IF (bal.loct_onhand < 0) THEN
				l_lot_rec_tbl(1).quantity := -bal.loct_onhand;
				l_lot_rec_tbl(1).quantity2 := -bal.loct_onhand2;
			ELSE
				l_lot_rec_tbl(1).quantity := bal.loct_onhand;
				l_lot_rec_tbl(1).quantity2 := bal.loct_onhand2;
			END IF;
		ELSE
			l_lot_rec_tbl(1).line_no := NULL;
			l_lot_rec_tbl(1).opm_lot_id := NULL;
			l_lot_rec_tbl(1).odm_lot_number := NULL;
			l_lot_rec_tbl(1).quantity := NULL;
			l_lot_rec_tbl(1).quantity2 := NULL;
		END IF;


-- dbms_output.put_line ('Disc. lot = '||l_lot_rec_tbl(1).odm_lot_number);
		-- Transfer the balance
		fnd_msg_pub.initialize;
		GMIVDX.Create_transfer_pvt (
			p_api_version => 1.0,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			p_hdr_rec => l_hdr_rec,
			p_line_rec_tbl => l_line_rec_tbl,
			p_lot_rec_tbl => l_lot_rec_tbl,
			x_hdr_row => o_hdr_row,
			x_line_row_tbl => o_line_row_tbl,
			x_lot_row_tbl => o_lot_row_tbl,
			x_transaction_set_id => l_transaction_set_id);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			-- dbms_output.put_line ('Balance migration failed for item, whse, lot, location'||l_item_no||', '||bal.whse_code||', '||l_lot_number||', '||bal.location);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_BALANCE_MIG_FAILED',
				p_table_name      => 'IC_LOCT_INV',
				p_context         => 'INVENTORY BALANCE',
				p_param1          => INV_GMI_Migration.item(bal.item_id),
				p_param2          => bal.whse_code,
				p_param3          => INV_GMI_Migration.lot(bal.lot_id),
				p_param4          => bal.location,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
			FOR i in 1..l_msg_count LOOP
				-- dbms_output.put_line (substr(fnd_msg_pub.get_detail(i, NULL),1,255));
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_UNEXPECTED_ERROR',
					p_table_name      => 'IC_LOCT_INV',
					p_context         => 'INVENTORY BALANCE',
					p_token1	  => 'ERROR',
					p_param1          => fnd_msg_pub.get_detail(i, NULL),
					p_param2          => NULL,
					p_param3          => NULL,
					p_param4          => NULL,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
			END LOOP;
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		-- Update the discrete transactions as costed
		UPDATE mtl_material_transactions
		SET
			costed_flag = NULL,
			opm_costed_flag = NULL
		WHERE
			transaction_set_id = l_transaction_set_id;

		-- Update mtl transaction id back in OPM table
		UPDATE ic_loct_inv
		SET migrated_ind = 1,
		    material_transaction_id = l_transaction_set_id
		WHERE
			rowid = bal.rowid;

		l_migrate_count := l_migrate_count + 1;
		IF (p_commit <> FND_API.G_FALSE) THEN
			COMMIT;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- dbms_output.put_line ('Cannot find '||l_field_name||' for '||l_field_value);
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_MIG_NO_DATA_FOR_FIELD',
				p_table_name      => 'IC_LOCT_INV',
				p_context         => 'INVENTORY BALANCE',
				p_param1          => l_field_name,
				p_param2          => l_field_value,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			x_failure_count := x_failure_count + 1;
			-- ROLLBACK TO bal_migration_start;
			ROLLBACK ;
		WHEN e_skip_whse THEN
			x_failure_count := x_failure_count + 1;
			IF (l_skip_to_next_whse = 0) THEN
				l_skip_to_next_whse := 1;
			END IF;
			-- ROLLBACK TO bal_migration_start;
			ROLLBACK ;
		WHEN FND_API.G_EXC_ERROR THEN
			x_failure_count := x_failure_count + 1;
			-- ROLLBACK TO bal_migration_start;
			ROLLBACK ;
	END;
	END LOOP;
	-- dbms_output.put_line ('Completed INVENTORY BALANCE migration. Migrated = '||to_char(l_migrate_count)||', Failed = '||to_char(x_failure_count));
	-- dbms_output.put_line ('Migrated ' || to_char(l_migrate_count) ||' rows');
	GMA_COMMON_LOGGING.gma_migration_central_log (
		p_run_id          => p_migration_run_id,
		p_log_level       => FND_LOG.LEVEL_ERROR,
		p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
		p_table_name      => 'IC_LOCT_INV',
		p_context         => 'INVENTORY BALANCE',
		p_param1          => l_migrate_count,
		p_param2          => x_failure_count,
		p_param3          => NULL,
		p_param4          => NULL,
		p_param5          => NULL,
		p_db_error        => NULL,
		p_app_short_name  => 'GMA');
EXCEPTION
	WHEN OTHERS THEN
		x_failure_count := x_failure_count + 1;
		-- dbms_output.put_line (substr(SQLERRM,1,255));
		GMA_COMMON_LOGGING.gma_migration_central_log (
			p_run_id          => p_migration_run_id,
			p_log_level       => FND_LOG.LEVEL_ERROR,
			p_message_token   => 'GMA_MIGRATION_DB_ERROR',
			p_table_name      => 'IC_LOCT_INV',
			p_context         => 'INVENTORY BALANCE',
			p_param1          => NULL,
			p_param2          => NULL,
			p_param3          => NULL,
			p_param4          => NULL,
			p_param5          => NULL,
			p_db_error        => SQLERRM,
			p_app_short_name  => 'GMA');
		ROLLBACK ;
END;

END INV_GMI_Migration;

/
