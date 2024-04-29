--------------------------------------------------------
--  DDL for Package Body INV_MIGRATE_PROCESS_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MIGRATE_PROCESS_ORG" AS
/* $Header: INVPOMGB.pls 120.21 2008/02/19 06:49:15 rlnagara ship $ */

/*====================================================================
--  PROCEDURE:
--    sync_whse_subinventory
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to create the subinventory with the name
--    of whse for mtl organization id.
--
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    sync_whse_subinventory (p_migartion_id    => l_migration_id,
--                            p_commit          => 'T',
--                            x_failure_count   => l_failure_count );
--
--  HISTORY
--   05-APR-2007   ACATALDO     Bug 5727749 Remove calls to the central
--                              logging API that are already handled
--                              by the calling layer.
--   06-APR-2007   ACATALDO     Bug 5955262 - Used correct token in exception
--                              block for migration table failure.
--====================================================================*/

  PROCEDURE sync_whse_subinventory (P_migration_run_id	IN  NUMBER,
                                    P_whse_code         IN  VARCHAR2,
				    P_whse_name         IN  VARCHAR2,
				    P_organization_id   IN  NUMBER,
                                    P_commit		IN  VARCHAR2,
                                    X_failure_count	OUT NOCOPY NUMBER) IS

    CURSOR Cur_check_subinventory IS
      SELECT 1
      FROM   dual
      WHERE  EXISTS (SELECT 1
                     FROM   mtl_secondary_inventories
		     WHERE  secondary_inventory_name = P_whse_code
		     AND    organization_id = P_organization_id);

    CURSOR Cur_get_details(V_organization_id NUMBER) IS
      SELECT *
      FROM   mtl_parameters
      WHERE  organization_id = V_organization_id;

    --Local Variables
    l_migrate_count	NUMBER;
    l_migration_id	NUMBER;
    l_locator_type	NUMBER;
    l_temp		NUMBER;
    l_rowid             VARCHAR2(80);

    --Row type declarations
    l_details		Cur_get_details%ROWTYPE;
  BEGIN
    l_migration_id := P_migration_run_id;
    X_failure_count := 0;

    --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
    --  logging API that are already handled by the calling layer.
    --  GMA_COMMON_LOGGING.gma_migration_central_log (
    --     p_run_id          => l_migration_id,
    --     p_log_level       => FND_LOG.LEVEL_PROCEDURE,
    --     p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
    --     p_table_name      => 'IC_WHSE_MST',
    --     p_context         => 'WHSE_SYNC',
    --     p_app_short_name  => 'GMA');

      OPEN Cur_check_subinventory;
      FETCH Cur_check_subinventory INTO l_temp;
      IF (Cur_check_subinventory%NOTFOUND) THEN
        CLOSE Cur_check_subinventory;
        --Fetch some details from mtl_parameters table to pass the parameter values.
	OPEN Cur_get_details(P_organization_id);
	FETCH Cur_get_details INTO l_details;
	CLOSE Cur_get_details;
        IF (l_details.stock_locator_control_code = 4) THEN
	  l_locator_type := 5;
	ELSE
	  l_locator_type := 1;
	END IF;

	--Now insert the warehouse into mtl_secondary_inventories table
	mtl_secondary_inventories_pkg.insert_row (
	         x_rowid                        => l_rowid
	       , x_secondary_inventory_name 	=> P_whse_code
               , x_organization_id 		=> P_organization_id
               , x_last_update_date 		=> SYSDATE
               , x_last_updated_by 		=> 0
               , x_creation_date		=> SYSDATE
               , x_created_by 			=> 0
               , x_last_update_login 		=> 0
               , x_description 			=> p_whse_name
               , x_disable_date 		=> NULL
               , x_inventory_atp_code 		=> 1
               , x_availability_type 		=> 1
               , x_reservable_type 		=> 1
               , x_locator_type 		=> l_locator_type
               , x_picking_order 		=> NULL
               , x_dropping_order 		=> NULL
               , x_material_account 		=> l_details.material_account
               , x_material_overhead_account    => l_details.material_overhead_account
               , x_resource_account 		=> l_details.resource_account
               , x_overhead_account 	        => l_details.overhead_account
               , x_outside_processing_account   => l_details.outside_processing_account
               , x_quantity_tracked 		=> 1
               , x_asset_inventory 		=> 1
               , x_source_type 			=> NULL
               , x_source_subinventory 		=> NULL
               , x_source_organization_id 	=> NULL
               , x_requisition_approval_type 	=> NULL
               , x_expense_account 		=> l_details.expense_account
               , x_encumbrance_account 		=> l_details.encumbrance_account
               , x_attribute_category 		=> NULL
               , x_attribute1 			=> NULL
               , x_attribute2 			=> NULL
               , x_attribute3 			=> NULL
               , x_attribute4 			=> NULL
               , x_attribute5 			=> NULL
               , x_attribute6 			=> NULL
               , x_attribute7 			=> NULL
               , x_attribute8 			=> NULL
               , x_attribute9 			=> NULL
               , x_attribute10 			=> NULL
               , x_attribute11 			=> NULL
               , x_attribute12 			=> NULL
               , x_attribute13 			=> NULL
               , x_attribute14 			=> NULL
               , x_attribute15 			=> NULL
               , x_preprocessing_lead_time 	=> NULL
               , x_processing_lead_time 	=> NULL
               , x_postprocessing_lead_time 	=> NULL
               , x_demand_class 		=> NULL
               , x_project_id 			=> NULL
               , x_task_id 			=> NULL
               , x_subinventory_usage 		=> NULL
               , x_notify_list_id 		=> NULL
               , x_depreciable_flag 		=> 2
               , x_location_id 			=> NULL
               , x_status_id 			=> 1
               , x_default_loc_status_id 	=> 1
               , x_lpn_controlled_flag 		=> 0
               , x_default_cost_group_id 	=> l_details.default_cost_group_id
               , x_pick_uom_code 		=> NULL
               , x_cartonization_flag 		=> 0
               , x_planning_level 		=> 2
               , x_default_count_type_code 	=> 2
               , x_subinventory_type 		=> 1
               , x_enable_bulk_pick 		=> 'N');
      END IF;

      IF (Cur_check_subinventory%ISOPEN) THEN
        CLOSE Cur_check_subinventory;
      END IF;

      UPDATE IC_LOCT_MST
      SET    locator_id = inventory_location_id
      WHERE  whse_code = P_whse_code;

    --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
    --  logging API that are already handled by the calling layer.
    --  GMA_COMMON_LOGGING.gma_migration_central_log (
    --     p_run_id          => l_migration_id,
    --     p_log_level       => FND_LOG.LEVEL_PROCEDURE,
    --     p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
    --     p_table_name      => 'IC_WHSE_MST',
    --     p_context         => 'WHSE_SYNC',
    --     p_app_short_name  => 'GMA');

    EXCEPTION
      WHEN OTHERS THEN
      x_failure_count := x_failure_count + 1;
      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'IC_WHSE_MST',
          p_context         => 'WHSE_SYNC',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');

      --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
      --  logging API that are already handled by the calling layer.
      --  GMA_COMMON_LOGGING.gma_migration_central_log (
      --      p_run_id          => l_migration_id,
      --      p_log_level       => FND_LOG.LEVEL_PROCEDURE,
      --      p_message_token   => 'GMA_MIGRATION_TABLE_FAIL',
      --      p_table_name      => 'IC_WHSE_MST',
      --      p_context         => 'WHSE_SYNC',
      --      p_app_short_name  => 'GMA');

  END sync_whse_subinventory;

/*====================================================================
--  PROCEDURE:
--    update_organization
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to update the exisitng Organization
--    values .
--
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    migrate_organization(p_migartion_id    => l_migration_id,
--                         p_commit          => 'T',
--                         x_failure_count   => l_failure_count );
--
--  HISTORY
--   05-APR-2007   ACATALDO     Bug 5727749 - Initialized migrate counter to
--                              avoid token showing in error log when a null
--                              is passed.
--   06-APR-2007   ACATALDO     Bug 5955262 - Used correct token in exception
--                              block for migration table failure.
--====================================================================*/

  PROCEDURE update_organization (P_migration_run_id	IN  NUMBER,
                                 P_commit		IN  VARCHAR2,
				 X_failure_count	OUT NOCOPY NUMBER) IS
    CURSOR Cur_get_orgn IS
      SELECT organization_id, process_orgn_code
      FROM   mtl_parameters
      WHERE  process_enabled_flag = 'Y';

    CURSOR Cur_get_oper_unit (V_orgn_code VARCHAR2)IS
      SELECT a.co_code
      FROM   sy_orgn_mst a, gl_plcy_mst b
      WHERE  a.co_code = b.co_code
      AND    a.orgn_code = V_orgn_code
      AND    b.new_le_flag = 'Y';

    CURSOR Cur_get_whse (V_organization_id NUMBER) IS
      SELECT a.whse_code, a.whse_name
      FROM   ic_whse_mst a
      WHERE  mtl_organization_id = V_organization_id
      AND    NVL(subinventory_ind_flag, 'N') = 'N'
      AND    NVL(migrated_ind,0) = 0;

    --Local Variables
    l_migrate_count	NUMBER;
    l_failure_count	NUMBER;
    l_whse_code         VARCHAR2(4);
    l_whse_name         VARCHAR2(240);
    l_co_code           VARCHAR2(4);
    l_migration_id	NUMBER;
    l_legal_entity	NUMBER;

    SYNC_WHSE_ERROR	EXCEPTION;
  BEGIN
    l_migration_id := P_migration_run_id;
    X_failure_count := 0;
    l_migrate_count := 0; /* Bug 5727749 */

    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => l_migration_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'MTL_PARAMETERS',
       p_context         => 'ORGANIZATION',
       p_app_short_name  => 'GMA');

    /*Bug 5358112 - Setting the cost method to 1 and cost organization id to itself */
    UPDATE mtl_parameters
    SET lot_number_uniqueness = 2,
        primary_cost_method = 1,
        cost_organization_id = organization_id
    WHERE process_enabled_flag = 'Y';

    --Update some specific columns in the mtl_parameters table for existing organizations
    FOR l_rec IN Cur_get_orgn LOOP
      UPDATE mtl_parameters m
      SET    stock_locator_control_code = 4
      WHERE  organization_id = l_rec.organization_id
      AND    EXISTS (SELECT 1
                     FROM IC_WHSE_MST
                     WHERE loct_ctl > 0
                     AND mtl_organization_id = l_rec.organization_id);

      OPEN Cur_get_oper_unit(l_rec.process_orgn_code);
      FETCH Cur_get_oper_unit INTO l_co_code;
      IF Cur_get_oper_unit%FOUND THEN
        l_legal_entity := gmf_migration.get_legal_entity_id (p_co_code     => l_co_code,
                                                             p_source_type => 'N');
        /*Bug 5228725 - Added the org_information_context clause */
        UPDATE hr_organization_information
	SET    org_information2 = l_legal_entity
	WHERE  organization_id = l_rec.organization_id
	AND    org_information_context = 'Accounting Information';
      END IF;
      CLOSE Cur_get_oper_unit;

      /* Update the locator control for the existing subinventories to be determined at item level */
      UPDATE mtl_secondary_inventories
      SET locator_type = 5
      WHERE organization_id = l_rec.organization_id
      AND    EXISTS (SELECT 1
                     FROM IC_WHSE_MST
                     WHERE loct_ctl > 0
                     AND mtl_organization_id = l_rec.organization_id);

      /* Update secondary inventories table for any rows that had the default cost group id */
      /* missing - due to an issue in the gmf_mtl_parameters_biur_tg trigger code - Bug 5553034*/
      UPDATE mtl_secondary_inventories
      SET default_cost_group_id = (SELECT default_cost_group_id
                                   FROM   mtl_parameters
                                   WHERE  organization_id = l_rec.organization_id)
      WHERE default_cost_group_id IS NULL
      AND   organization_id = l_rec.organization_id
      AND   secondary_inventory_name <> 'AX_INTRANS';

      OPEN Cur_get_whse (l_rec.organization_id);
      FETCH Cur_get_whse INTO l_whse_code , l_whse_name;
      IF Cur_get_whse%FOUND THEN
        sync_whse_subinventory (P_migration_run_id => l_migration_id,
                                P_whse_code        => l_whse_code,
				P_whse_name        => l_whse_name,
				P_organization_id  => l_rec.organization_id,
                                P_commit           => FND_API.G_FALSE,
                                X_failure_count	   => l_failure_count);
        IF l_failure_count > 0 THEN
          CLOSE Cur_get_whse;
          RAISE SYNC_WHSE_ERROR;
        END IF;
        UPDATE ic_whse_mst
        SET    migrated_ind = 1,
               organization_id = mtl_organization_id
        WHERE  mtl_organization_id = l_rec.organization_id;
      END IF;
      CLOSE Cur_get_whse;
         --Lets save the changes now based on the commit parameter
      IF p_commit = FND_API.G_TRUE THEN
        COMMIT;
      END IF;
    END LOOP;

    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => l_migration_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'MTL_PARAMETERS',
       p_context         => 'ORGANIZATION',
       p_param1          => l_migrate_count,
       p_param2          => X_failure_count,
       p_app_short_name  => 'GMA');

    EXCEPTION
      WHEN SYNC_WHSE_ERROR THEN
        ROLLBACK;
        x_failure_count := x_failure_count + 1;
      WHEN OTHERS THEN
        ROLLBACK;
        x_failure_count := x_failure_count + 1;
        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'MTL_PARAMETERS',
          p_context         => 'ORGANIZATION',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_MIGRATION_TABLE_FAIL',
          p_table_name      => 'MTL_PARAMETERS',
          p_context         => 'ORGANIZATION',
          p_app_short_name  => 'GMA');

  END update_organization;

/*====================================================================
--  PROCEDURE:
--    create_location
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to create the location in
--    Discrete tables .
--
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    p_organization_id --Organization id.
--    p_subinventory_code --Subinventory for location.
--    p_location --location name.
--    P_loct_desc --Location Name.
--    P_statrt_date_active - Start date
--    x_failure_count    - Number of failures occurred.
--  SYNOPSIS:
--    create_location(P_migration_run_id   => l_migration_id
--                     p_organization_id   => l_organization_id,
--                     p_subinventory_code => l_subinventory_code,
--                     p_location	   => l_location,
--                     p_loct_desc	   => l_loct_desc,
--                     p_start_date_active => l_start_date_active,
--                     p_commit            => 'Y',
--                     x_failure_count     => l_failure_count);
--
--  HISTORY
--   06-APR-2007   ACATALDO     Bug 5955262 - Used correct token in exception
--                              block for migration table failure.
--====================================================================*/

  PROCEDURE create_location (P_migration_run_id		IN  NUMBER,
		             P_organization_id		IN  NUMBER,
		             P_subinventory_code	IN  VARCHAR2,
		             P_location			IN  VARCHAR2,
			     P_loct_desc		IN  VARCHAR2,
			     P_start_date_active	IN  DATE,
                             P_commit			IN  VARCHAR2,
			     X_location_id		OUT NOCOPY NUMBER,
                             X_failure_count		OUT NOCOPY NUMBER,
                             P_disable_date             IN  DATE,
                             P_segment2                 IN  VARCHAR2,
                             P_segment3                 IN  VARCHAR2,
                             P_segment4                 IN  VARCHAR2,
                             P_segment5                 IN  VARCHAR2,
                             P_segment6                 IN  VARCHAR2,
                             P_segment7                 IN  VARCHAR2,
                             P_segment8                 IN  VARCHAR2,
                             P_segment9                 IN  VARCHAR2,
                             P_segment10                IN  VARCHAR2,
                             P_segment11                IN  VARCHAR2,
                             P_segment12                IN  VARCHAR2,
                             P_segment13                IN  VARCHAR2,
                             P_segment14                IN  VARCHAR2,
                             P_segment15                IN  VARCHAR2,
                             P_segment16                IN  VARCHAR2,
                             P_segment17                IN  VARCHAR2,
                             P_segment18                IN  VARCHAR2,
                             P_segment19                IN  VARCHAR2,
                             P_segment20                IN  VARCHAR2) IS

    --CURSORS

    /* Bug 5529682 - Changed reference to mtl_item_locations_kfv to mtl_item_locations */
    /* Bug 5607797 - Changed the following select to return the inventory location id instead of 1 */
    CURSOR Cur_check_sub_location(V_location VARCHAR2) IS
      SELECT inventory_location_id
      FROM   mtl_item_locations
      WHERE  segment1 = V_location
      AND    subinventory_code = P_subinventory_code
      AND    organization_id = p_organization_id;

    /* Bug 5529682 - Changed reference to mtl_item_locations_kfv to mtl_item_locations */
    CURSOR Cur_check_location(V_location VARCHAR2) IS
      SELECT 1
      FROM   dual
      WHERE  EXISTS (SELECT 1
                     FROM   mtl_item_locations
		     WHERE  segment1 = V_location
		     AND    organization_id = p_organization_id);

    CURSOR Cur_get_id IS
      SELECT mtl_item_locations_s.nextval
      FROM   dual;

    --Local Variables
    l_migration_id		NUMBER;
    l_organization_id		NUMBER;
    l_location_id		NUMBER;
    l_temp			NUMBER;
    l_loct_desc			VARCHAR2(80);
    l_start_date_active		DATE;
    l_migrate_count		NUMBER(5) DEFAULT 0;
    l_segment1                  VARCHAR2(80);

    --Exceptions
    LOCATION_EXISTS	EXCEPTION;
  BEGIN
    l_migration_id := P_migration_run_id;
    X_failure_count := 0;

    OPEN Cur_check_sub_location(P_location);
    FETCH Cur_check_sub_location INTO X_location_id;
    IF (Cur_check_sub_location%FOUND) THEN
      CLOSE Cur_check_sub_location;
      RAISE LOCATION_EXISTS;
    ELSE
      CLOSE Cur_check_sub_location;

      /* Bug# 5529682 - If location not found with the exact name then try to see */
      /* if there is a location defined with a concatenated subinventory */
      OPEN Cur_check_sub_location(P_subinventory_code ||' '|| P_location);
      FETCH Cur_check_sub_location INTO X_location_id;
      IF (Cur_check_sub_location%FOUND) THEN
        CLOSE Cur_check_sub_location;
        RAISE LOCATION_EXISTS;
      ELSE
        CLOSE Cur_check_sub_location;
        OPEN Cur_get_id;
        FETCH Cur_get_id INTO l_location_id;
        CLOSE Cur_get_id;
        X_location_id := l_location_id;
      END IF;
    END IF;


    OPEN Cur_check_location(P_location);
    FETCH Cur_check_location INTO l_temp;
    IF (Cur_check_location%FOUND) THEN
      /* If the location exists under the org for a different subinventory */
      /* then build a new one using the subinventory code */
      l_segment1 := P_subinventory_code ||' '|| P_location;
    ELSE
      l_segment1 := p_location;
    END IF;
    CLOSE Cur_check_location;

    IF (P_loct_desc IS NULL) THEN
      l_loct_desc := P_location;
    ELSE
      l_loct_desc := P_loct_desc;
    END IF;

    IF (P_start_date_active IS NULL) THEN
      l_start_date_active := SYSDATE;
    ELSE
      l_start_date_active := P_start_date_active;
    END IF;

      --Insert the location into mtl_item_locations table
      INSERT INTO mtl_item_locations(
	inventory_location_id,organization_id,description,descriptive_text,disable_date,picking_order,location_maximum_units,
	subinventory_code,location_weight_uom_code,max_weight,volume_uom_code,max_cubic_area,segment1,segment2,segment3,segment4,
	segment5,segment6,segment7,segment8,segment9,segment10,segment11,segment12,segment13,segment14,segment15,segment16,
	segment17,segment18,segment19,segment20,summary_flag,enabled_flag,start_date_active,end_date_active,attribute_category,
	attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,
        attribute11,attribute12,attribute13,attribute14,attribute15,project_id,task_id,physical_location_id,pick_uom_code,
	dimension_uom_code,length,width,height,locator_status,status_id,current_cubic_area,available_cubic_area,current_weight,
	available_weight,location_current_units,location_available_units,suggested_cubic_area,empty_flag,mixed_items_flag,
	dropping_order,location_suggested_units,availability_type,inventory_atp_code,reservable_type,inventory_item_id,
	creation_date,created_by,last_update_date,last_updated_by)
      VALUES (
	l_location_id,p_organization_id,l_loct_desc,NULL,p_disable_date,NULL,NULL,p_subinventory_code,NULL,NULL,NULL,
	NULL,l_segment1,p_segment2,p_segment3,p_segment4,p_segment5,p_segment6,p_segment7,p_segment8,p_segment9,p_segment10,
	p_segment11,p_segment12,p_segment13,p_segment14,p_segment15,p_segment16,p_segment17,p_segment18,p_segment19,p_segment20,
	'N','Y',l_start_date_active,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,1,NULL,
	SYSDATE,0,SYSDATE,0);

    --Lets save the changes now based on the commit parameter
    IF p_commit = FND_API.G_TRUE THEN
      COMMIT;
    END IF;

    l_migrate_count := l_migrate_count + 1;


    EXCEPTION
      WHEN LOCATION_EXISTS THEN
        NULL;

      WHEN OTHERS THEN
      x_failure_count := x_failure_count + 1;
      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'IC_LOCT_MST',
          p_context         => 'LOCATION',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');

      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_MIGRATION_TABLE_FAIL',
          p_table_name      => 'IC_LOCT_MST',
          p_context         => 'LOCATION',
          p_app_short_name  => 'GMA');

  END create_location;

/*====================================================================
--  PROCEDURE:
--    migrate_location
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the locations to
--    Discrete tables .
--
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    p_organization_id --Organization id.
--    p_subinventory_code --Subinventory for location.
--    x_failure_count    - Number of failures occurred.
--
--  SYNOPSIS:
--    migrate_location(P_migration_run_id  => l_migration_id
--                     p_organization_id   => l_organization_id,
--                     p_subinventory_code => l_subinventory_code,
--                     p_commit            => 'N',
--                     x_failure_count     => l_failure_count);
--
--  HISTORY
--   05-APR-2007   ACATALDO     Bug 5727749 Remove calls to the central
--                              logging API that are already handled
--                              by the calling layer.
--   06-APR-2007   ACATALDO     Bug 5955262 - Used correct token in exception
--                              block for migration table failure.
--====================================================================*/

  PROCEDURE migrate_location (P_migration_run_id	IN  NUMBER,
		              P_organization_id		IN  NUMBER,
		              P_subinventory_code	IN  VARCHAR2,
                              P_commit			IN  VARCHAR2,
			      X_location_id             OUT NOCOPY NUMBER,
                              X_failure_count		OUT NOCOPY NUMBER) IS
    --CURSORS
    -- Removed select of segment1 etc from kfv views. Thomas Daniel. B4712289
    /* Bug 5529682 - Removed reference to mtl_item_locations_kfv */
    /* duplicate checking is now being done using segment1 */
    CURSOR Cur_get_location (V_location VARCHAR2) IS
      SELECT il.*, l.delete_mark
      FROM   mtl_item_locations il, ic_loct_mst l
      WHERE  l.location <> V_location
      AND    l.whse_code = P_subinventory_code
      AND    l.inventory_location_id = il.inventory_location_id;

    --Local Variables
    l_migration_id		NUMBER;
    l_organization_id		NUMBER;
    l_location			VARCHAR2(240);
    l_loc			VARCHAR2(240);
    l_temp			NUMBER;
    l_location_id		NUMBER;
    l_failure_count		NUMBER;
    l_disable_date              DATE;

    --Exceptions
    LOCATION_FAILED	EXCEPTION;
  BEGIN
    l_migration_id := P_migration_run_id;
    X_failure_count := 0;

     --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
     --  logging API that are already handled by the calling layer.
     -- GMA_COMMON_LOGGING.gma_migration_central_log (
     --   p_run_id          => l_migration_id,
     --   p_log_level       => FND_LOG.LEVEL_PROCEDURE,
     --   p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
     --   p_table_name      => 'IC_LOCT_MST',
     --   p_context         => 'LOCATION',
     --   p_app_short_name  => 'GMA');

    l_location := FND_PROFILE.VALUE('IC$DEFAULT_LOCT');
    FOR l_rec IN Cur_get_location(l_location) LOOP

      /* Bug 5529682 - Removed the concatenation of subinventory and location */
      /* this is being done in the create_location procedure */

      IF l_rec.delete_mark = 0 THEN
        l_disable_date := NULL; --SYSDATE; Bug# 5451429 delete mark = 0 is not disabled.
      ELSE
        l_disable_date := SYSDATE; --NULL; Bug# 5451429 delete mark <> 0 is disabled.
      END IF;

      create_location (P_migration_run_id  => l_migration_id,
		       P_organization_id   => P_organization_id,
		       P_subinventory_code => P_subinventory_code,
		       P_location          => l_rec.segment1,
		       P_disable_date      => l_disable_date,
		       P_segment2          => l_rec.segment2,
		       P_segment3          => l_rec.segment3,
		       P_segment4          => l_rec.segment4,
		       P_segment5          => l_rec.segment5,
		       P_segment6          => l_rec.segment6,
		       P_segment7          => l_rec.segment7,
		       P_segment8          => l_rec.segment8,
		       P_segment9          => l_rec.segment9,
		       P_segment10         => l_rec.segment10,
		       P_segment11         => l_rec.segment11,
		       P_segment12         => l_rec.segment12,
		       P_segment13         => l_rec.segment13,
		       P_segment14         => l_rec.segment14,
		       P_segment15         => l_rec.segment15,
		       P_segment16         => l_rec.segment16,
		       P_segment17         => l_rec.segment17,
		       P_segment18         => l_rec.segment18,
		       P_segment19         => l_rec.segment19,
		       P_segment20         => l_rec.segment20,
		       P_loct_desc         => l_rec.description,
		       P_start_date_active => l_rec.creation_date,
                       P_commit            => FND_API.G_FALSE,
		       X_location_id	   => l_location_id,
                       X_failure_count     => l_failure_count);
      IF (l_failure_count > 0) THEN
        RAISE LOCATION_FAILED;
      ELSE
        UPDATE ic_loct_mst
        SET    locator_id = l_location_id
        WHERE  location = l_rec.segment1
        AND    whse_code = p_subinventory_code;
      END IF;
    END LOOP;

    --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
    --  logging API that are already handled by the calling layer.
    -- GMA_COMMON_LOGGING.gma_migration_central_log (
    --    p_run_id          => l_migration_id,
    --    p_log_level       => FND_LOG.LEVEL_PROCEDURE,
    --    p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
    --    p_table_name      => 'IC_LOCT_MST',
    --    p_context         => 'LOCATION',
    --    p_app_short_name  => 'GMA');

    EXCEPTION
      WHEN LOCATION_FAILED THEN
      x_failure_count := l_failure_count;

      WHEN OTHERS THEN
      x_failure_count := x_failure_count + l_failure_count;
      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'IC_LOCT_MST',
          p_context         => 'LOCATION',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');

      --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
      --  logging API that are already handled by the calling layer.
      -- GMA_COMMON_LOGGING.gma_migration_central_log (
      --     p_run_id          => l_migration_id,
      --     p_log_level       => FND_LOG.LEVEL_PROCEDURE,
      --     p_message_token   => 'GMA_MIGRATION_TABLE_FAIL',
      --     p_table_name      => 'IC_LOCT_MST',
      --     p_context         => 'LOCATION',
      --     p_app_short_name  => 'GMA');

  END migrate_location;

/*====================================================================
--  PROCEDURE:
--    migrate_subinventory
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the warehouses to
--    Discrete tables .
--
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count    - Number of failures occurred.
--
--  SYNOPSIS:
--    migrate_subinventory(p_migartion_id    => l_migration_id,
--                         p_orgn_code       => l_rec.orgn_code,
--                         p_commit          => 'T',
--                         x_failure_count   => l_failure_count );
--
--  HISTORY
--   05-APR-2007   ACATALDO     Bug 5727749 Remove calls to the central
--                              logging API that are already handled
--                              by the calling layer.
--   06-APR-2007   ACATALDO     Bug 5955262 - Used correct token in exception
--                              block for migration table failure.
--====================================================================*/

  PROCEDURE migrate_subinventory (P_migration_run_id	IN  NUMBER,
                                  P_orgn_code		IN  VARCHAR2,
                                  P_commit		IN  VARCHAR2,
                                  X_failure_count	OUT NOCOPY NUMBER) IS

    --CURSORS
    CURSOR Cur_get_warehouse IS
      SELECT *
      FROM   ic_whse_mst_vw
      WHERE  subinventory_ind_flag = 'Y'
      AND    orgn_code = P_orgn_code
      AND    NVL(migrated_ind,0) = 0;

    CURSOR Cur_get_orgn(V_orgn_code VARCHAR2) IS
      SELECT organization_id
      FROM   sy_orgn_mst
      WHERE  orgn_code = V_orgn_code;

    CURSOR Cur_check_subinventory(V_whse_code VARCHAR2, V_organization_id NUMBER) IS
      SELECT 1
      FROM   dual
      WHERE  EXISTS (SELECT 1
                     FROM   mtl_secondary_inventories
		     WHERE  secondary_inventory_name = V_whse_code
		     AND    organization_id = V_organization_id);

    CURSOR Cur_get_details(V_orgn_id NUMBER) IS
      SELECT *
      FROM   mtl_parameters
      WHERE  organization_id = V_orgn_id;

    --Local Variables
    l_migration_id		NUMBER;
    l_organization_id		NUMBER;
    l_cost_orgn_id		NUMBER;
    l_location_id		NUMBER;
    l_mtl_orgn_id		NUMBER;
    l_subinv_ind		VARCHAR2(1);
    l_temp			NUMBER;
    l_locator_type		NUMBER;
    l_rowid             	VARCHAR2(80);
    l_failure_count		NUMBER;

    --Row type declarations
    l_details		Cur_get_details%ROWTYPE;

    --Exceptions
    ORGN_NOT_MIGRATED	EXCEPTION;
    MIG_LOCATION_ERROR  EXCEPTION;
  BEGIN
    X_failure_count := 0;
    l_migration_id := P_migration_run_id;

    --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
    --  logging API that are already handled by the calling layer.
    -- GMA_COMMON_LOGGING.gma_migration_central_log (
    --    p_run_id          => l_migration_id,
    --    p_log_level       => FND_LOG.LEVEL_PROCEDURE,
    --    p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
    --    p_table_name      => 'IC_WHSE_MST',
    --    p_context         => 'WAREHOUSE',
    --    p_app_short_name  => 'GMA');

    FOR l_rec IN Cur_get_warehouse LOOP
    BEGIN
      IF (l_rec.subinventory_ind_flag = 'Y') THEN
        IF (l_rec.organization_id IS NULL) THEN
	  OPEN Cur_get_orgn(l_rec.orgn_code);
          FETCH Cur_get_orgn INTO l_organization_id;
          CLOSE Cur_get_orgn;
	  IF (l_organization_id IS NULL) THEN
	    RAISE ORGN_NOT_MIGRATED;
	  END IF;
	ELSE
          l_organization_id := l_rec.organization_id;
	END IF;

        --Fecth some details from mtl_parameters table to pass the parameter values.
  	OPEN Cur_get_details(l_organization_id);
	FETCH Cur_get_details INTO l_details;
	CLOSE Cur_get_details;

        -- Check if the warehouse is location controlled
        IF l_rec.loct_ctl > 0THEN
          IF (l_details.stock_locator_control_code = 4) THEN
    	    l_locator_type := 5;
	  ELSE
 	    l_locator_type := 1;
 	  END IF;
 	ELSE
 	  l_locator_type := 1;
	END IF;

        OPEN Cur_check_subinventory(l_rec.whse_code, l_organization_id);
        FETCH Cur_check_subinventory INTO l_temp;
	IF (Cur_check_subinventory%FOUND) THEN
	  UPDATE mtl_secondary_inventories
	  SET locator_type = l_locator_type,
	      default_loc_status_id = 1
	  WHERE organization_id = l_organization_id
	  AND   secondary_inventory_name = l_rec.whse_code;

          GMA_COMMON_LOGGING.gma_migration_central_log (
            p_run_id          => l_migration_id,
            p_log_level       => FND_LOG.LEVEL_PROCEDURE,
            p_message_token   => 'GMA_WHSE_EXISTS',
            p_table_name      => 'IC_WHSE_MST',
            p_context         => 'WAREHOUSE',
	    p_token1          => 'WAREHOUSE',
            p_param1          => l_rec.whse_code,
            p_app_short_name  => 'GMA');

          UPDATE ic_loct_mst
          SET    locator_id = inventory_location_id
          WHERE  whse_code = l_rec.whse_code;
        ELSE
	  --Now insert the warehouse into mtl_secondary_inventories table
          mtl_secondary_inventories_pkg.insert_row (
	         x_rowid                        => l_rowid
	       , x_secondary_inventory_name 	=> l_rec.whse_code
               , x_organization_id 		=> l_organization_id
               , x_last_update_date 		=> SYSDATE
               , x_last_updated_by 		=> 0
               , x_creation_date		=> SYSDATE
               , x_created_by 			=> 0
               , x_last_update_login 		=> 0
               , x_description 			=> l_rec.whse_name
               , x_disable_date 		=> NULL
               , x_inventory_atp_code 		=> 1
               , x_availability_type 		=> 1
               , x_reservable_type 		=> 1
               , x_locator_type 		=> l_locator_type
               , x_picking_order 		=> NULL
               , x_dropping_order 		=> NULL
               , x_material_account 		=> l_details.material_account
               , x_material_overhead_account    => l_details.material_overhead_account
               , x_resource_account 		=> l_details.resource_account
               , x_overhead_account 	        => l_details.overhead_account
               , x_outside_processing_account   => l_details.outside_processing_account
               , x_quantity_tracked 		=> 1
               , x_asset_inventory 		=> 1
               , x_source_type 			=> NULL
               , x_source_subinventory 		=> NULL
               , x_source_organization_id 	=> NULL
               , x_requisition_approval_type 	=> NULL
               , x_expense_account 		=> l_details.expense_account
               , x_encumbrance_account 		=> l_details.encumbrance_account
               , x_attribute_category 		=> NULL
               , x_attribute1 			=> NULL
               , x_attribute2 			=> NULL
               , x_attribute3 			=> NULL
               , x_attribute4 			=> NULL
               , x_attribute5 			=> NULL
               , x_attribute6 			=> NULL
               , x_attribute7 			=> NULL
               , x_attribute8 			=> NULL
               , x_attribute9 			=> NULL
               , x_attribute10 			=> NULL
               , x_attribute11 			=> NULL
               , x_attribute12 			=> NULL
               , x_attribute13 			=> NULL
               , x_attribute14 			=> NULL
               , x_attribute15 			=> NULL
               , x_preprocessing_lead_time 	=> NULL
               , x_processing_lead_time 	=> NULL
               , x_postprocessing_lead_time 	=> NULL
               , x_demand_class 		=> NULL
               , x_project_id 			=> NULL
               , x_task_id 			=> NULL
               , x_subinventory_usage 		=> NULL
               , x_notify_list_id 		=> NULL
               , x_depreciable_flag 		=> 2
               , x_location_id 			=> NULL
               , x_status_id 			=> 1
               , x_default_loc_status_id 	=> 1
               , x_lpn_controlled_flag 		=> 0
               , x_default_cost_group_id 	=> l_details.default_cost_group_id
               , x_pick_uom_code 		=> NULL
               , x_cartonization_flag 		=> 0
               , x_planning_level 		=> 2
               , x_default_count_type_code 	=> 2
               , x_subinventory_type 		=> 1
               , x_enable_bulk_pick 		=> 'N');

          migrate_location(P_migration_run_id  => l_migration_id,
                       P_organization_id   => l_organization_id,
		       P_subinventory_code => l_rec.whse_code,
                       P_commit 	   => FND_API.G_FALSE,
                       X_location_id	   => l_location_id,
	               X_failure_count     => l_failure_count);
          IF l_failure_count > 0 THEN
            CLOSE Cur_check_subinventory;
            RAISE MIG_LOCATION_ERROR;
          END IF;
        END IF;
        CLOSE Cur_check_subinventory;

        --Validate the existing inventory org for the warehouse
        IF (l_rec.disable_warehouse_ind ='Y') THEN
          UPDATE hr_organization_units
          SET    date_to = SYSDATE
          WHERE  organization_id = l_rec.mtl_organization_id;
        END IF;

        --Update the migrated ind for the warehouse.
        UPDATE ic_whse_mst
        SET    organization_id = l_organization_id,
               migrated_ind = 1
        WHERE  whse_code = l_rec.whse_code;

      END IF; /* IF (l_rec.subinventory_ind_flag = 'Y') */
    EXCEPTION
      WHEN MIG_LOCATION_ERROR THEN
        X_failure_count := X_failure_count + l_failure_count;
      WHEN ORGN_NOT_MIGRATED THEN
        x_failure_count := x_failure_count + 1;
        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMD_ORG_NOT_MIGRATED',
          p_table_name      => 'IC_WHSE_MST',
          p_context         => 'WAREHOUSE',
	  p_token1          => 'ORGANIZATION',
          p_param1          => l_rec.orgn_code,
          p_app_short_name  => 'GMA');

      WHEN OTHERS THEN
        x_failure_count := x_failure_count + 1;

        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'IC_WHSE_MST',
          p_context         => 'WAREHOUSE',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');
    END;
    END LOOP;

     --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
     --  logging API that are already handled by the calling layer.
     -- GMA_COMMON_LOGGING.gma_migration_central_log (
     --    p_run_id          => l_migration_id,
     --    p_log_level       => FND_LOG.LEVEL_PROCEDURE,
     --    p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
     --    p_table_name      => 'IC_WHSE_MST',
     --    p_context         => 'WAREHOUSE',
     --    p_app_short_name  => 'GMA');


    EXCEPTION
      WHEN OTHERS THEN
      x_failure_count := x_failure_count + 1;

      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'IC_WHSE_MST',
          p_context         => 'WAREHOUSE',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');

     --  Bug 5727749 T.Cataldo 5-April-2007 Remove calls to the central
     --  logging API that are already handled by the calling layer.
     --  GMA_COMMON_LOGGING.gma_migration_central_log (
     --      p_run_id          => l_migration_id,
     --      p_log_level       => FND_LOG.LEVEL_PROCEDURE,
     --      p_message_token   => 'GMA_MIGRATION_TABLE_FAIL',
     --      p_table_name      => 'IC_WHSE_MST',
     --      p_context         => 'WAREHOUSE',
     --      p_app_short_name  => 'GMA');

  END migrate_subinventory;

/*====================================================================
--  PROCEDURE:
--    create_organization
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to create organization at the
--    discrete end.
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count    - Number of failures occurred.
--
--  SYNOPSIS:
--
--
--  HISTORY
--    TDaniel  Bug#5108912 - Removed the condition (AND p_plant_ind <> 0)
--             for creating the inventory org.
--    RLNAGARA Bug6607319 - Added Default Status for Material Status Migration ME
--====================================================================*/

  PROCEDURE create_organization (P_template_organization_id	IN  NUMBER,
                                 P_orgn_code		        IN  VARCHAR2,
                                 P_orgn_name                    IN  VARCHAR2,
                                 P_organization_code            IN  VARCHAR2,
                                 P_organization_name            IN  VARCHAR2,
                                 P_addr_id                      IN  NUMBER,
                                 P_creation_date                IN  DATE,
                                 P_inventory_org_ind            IN  VARCHAR2,
				 P_default_status_id            IN  VARCHAR2, --RLNAGARA Material Status Migration ME
                                 P_plant_ind                    IN  NUMBER,
                                 P_migrate_as_ind               IN  NUMBER,
                                 P_process_enabled_ind          IN  VARCHAR2,
                                 p_delete_mark                  IN  NUMBER,
                                 P_migration_run_id             IN  NUMBER,
                                 X_failure_count	OUT NOCOPY NUMBER,
                                 X_organization_id      OUT NOCOPY NUMBER) IS
    --CURSORS
    CURSOR Cur_get_organization_id (V_orgn_code VARCHAR2)IS
      SELECT m.organization_id
      FROM   mtl_parameters m, ic_whse_mst w
      WHERE  w.orgn_code = V_orgn_code
      AND    w.mtl_organization_id = m.organization_id
      ORDER BY whse_code;

    CURSOR Cur_get_address (V_addr_id NUMBER)IS
      SELECT *
      FROM   sy_addr_mst
      WHERE  addr_id = V_addr_id
      AND    delete_mark = 0;

    /* Bug 5358112 - Changed the cursor to refer to the base tables instead of */
    /* org organization definitions table */
    CURSOR Cur_get_orgn_def (V_orgn_id NUMBER)IS
      SELECT HOU.BUSINESS_GROUP_ID,
             DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION1), TO_NUMBER(NULL)) SET_OF_BOOKS_ID,
             DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION3), TO_NUMBER(NULL)) OPERATING_UNIT,
             DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION2), null) LEGAL_ENTITY
      FROM  HR_ORGANIZATION_UNITS HOU, HR_ORGANIZATION_INFORMATION HOI2
      WHERE HOU.organization_id = V_orgn_id
      AND   HOU.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
      AND   ( HOI2.ORG_INFORMATION_CONTEXT || '') ='Accounting Information';

    CURSOR Cur_get_unit IS
      SELECT hr_organization_units_s.nextval
      FROM   dual;

    CURSOR Cur_org_code (v_org_code VARCHAR2, v_start_ch NUMBER) IS
      (SELECT substrb(v_org_code,1,v_start_ch)|| substrb(ltrim(to_char(to_number(rownum)-1,'099')), v_start_ch+1)
       FROM gl_sevt_ttl t1, gl_sevt_ttl t2
       WHERE rownum <= decode(v_start_ch, 0, 1000, 1, 100, 10)
       minus
       SELECT organization_code
       FROM mtl_parameters);

    CURSOR Cur_get_orgn_values(V_orgn_id NUMBER) IS
      SELECT *
      FROM   mtl_parameters
      WHERE  organization_id = V_orgn_id;


    --LOCAL VARIABLES
    l_rowid             	VARCHAR2(80);
    l_orgn_code         	VARCHAR2(3);
    l_organization_name         VARCHAR2(240);
    l_org_Id			NUMBER;
    l_organization_Id		NUMBER;
    l_master_organization_Id	NUMBER;
    l_process_enabled_ind	VARCHAR2(1);
    l_location_id		NUMBER;
    l_dummy			NUMBER;
    l_date_to			DATE;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER(5);
    l_msg_data                  VARCHAR2(2000);
    l_cost_group_id             NUMBER(15);

    --Row type declarations
    l_addr		Cur_get_address%ROWTYPE;
    l_orgn_def		Cur_get_orgn_def%ROWTYPE;
    l_parameter		Cur_get_orgn_values%ROWTYPE;

    --Exceptions
    ORGN_MISSING	     EXCEPTION;
    COST_GROUP_SETUP_ERR     EXCEPTION;
    l_def_business_group NUMBER(15) := FND_PROFILE.VALUE('ORG_ID');
  BEGIN
    X_failure_count := 0;
    IF (P_template_organization_id IS NOT NULL) THEN
      l_org_id := p_template_organization_id;
    ELSE
      OPEN Cur_get_organization_id(p_orgn_code);
      FETCH Cur_get_organization_id INTO l_org_id;
      CLOSE Cur_get_organization_id;
    END IF;

    IF (NVL(p_inventory_org_ind, 'Y') = 'Y') THEN
      IF (l_org_id IS NULL) THEN
        RAISE ORGN_MISSING;
      END IF;
    END IF;
    -- Default the organization name
    IF p_organization_name IS NOT NULL THEN
      l_organization_name := p_organization_name;
    ELSE
      l_organization_name := p_orgn_code||':'||p_orgn_name;
    END IF;

    --Fetch the organization definition.
    OPEN Cur_get_orgn_def(l_org_id);
    FETCH Cur_get_orgn_def INTO l_orgn_def;
    IF Cur_get_orgn_def%NOTFOUND THEN
      CLOSE Cur_get_orgn_def;
      RAISE ORGN_MISSING;
    END IF;
    CLOSE Cur_get_orgn_def;

    IF (P_addr_id IS NOT NULL) THEN
      --Fetch the address for each organization and create a location for the same by calling the API.
      OPEN Cur_get_address(P_addr_id);
      FETCH Cur_get_address INTO l_addr;
      CLOSE Cur_get_address;

      hr_location_api.create_location(p_effective_date          => p_creation_date,
                                      p_location_code           => p_orgn_code,
                                      p_description             => p_orgn_name,
                                      p_address_line_1          => l_addr.addr1,
                                      p_address_line_2 	        => l_addr.addr2,
                                      p_address_line_3 	        => l_addr.addr3,
                                      p_town_or_city 	        => l_addr.addr4,
                                      p_region_3 	        => l_addr.state_code,
                                      p_postal_code 	        => l_addr.postal_code,
                                      p_country 	        => l_addr.country_code,
                                      p_loc_information13       => l_addr.ora_addr4,
                                      p_region_1 	        => l_addr.province,
                                      p_region_2 	        => l_addr.county,
                                      p_style 		        => 'OPM',
                                      p_business_group_id       => NVL(l_orgn_def.business_group_id, l_def_business_group),
                                      p_location_id 	        => l_location_id,
                                      p_object_version_number   => l_dummy);
      END IF;
      --Create a row for the organization in hr_organization_units table.
      OPEN Cur_get_unit;
      FETCH Cur_get_unit INTO X_organization_id;
      CLOSE Cur_get_unit;

      IF (p_migrate_as_ind = 3 OR (p_migrate_as_ind IS NULL AND p_delete_mark = 1)) THEN
        l_date_to := SYSDATE;
      END IF;
      hr_organization_units_pkg.insert_row(
                                          X_rowid 		       =>l_rowid,
                                          X_organization_id 	       =>X_organization_id,
                                          X_business_group_id	       =>NVL(l_orgn_def.business_group_id, l_def_business_group),
                                          X_cost_allocation_keyflex_id =>NULL,
                                          X_location_id		       =>l_location_id,
                                          X_soft_coding_keyflex_id     =>NULL,
                                          X_date_from		       =>p_creation_date,
                                          X_name		       =>l_organization_name,
                                          X_comments		       =>NULL,
                                          X_date_to		       =>l_date_to,
                                          X_internal_external_flag     =>'INT',
                                          X_internal_address_line      =>NULL,
                                          X_type		       =>NULL,
                                          X_security_profile_id	       =>NULL,
                                          X_view_all_orgs	       =>NULL,
                                          X_attribute_category 	       =>NULL,
                                          X_attribute1		       =>NULL,
                                          X_attribute2		       =>NULL,
                                          X_attribute3		       =>NULL,
                                          X_attribute4		       =>NULL,
                                          X_attribute5		       =>NULL,
                                          X_attribute6		       =>NULL,
                                          X_attribute7		       =>NULL,
                                          X_attribute8		       =>NULL,
                                          X_attribute9		       =>NULL,
                                          X_attribute10		       =>NULL,
                                          X_attribute11		       =>NULL,
                                          X_attribute12		       =>NULL,
                                          X_attribute13		       =>NULL,
                                          X_attribute14		       =>NULL,
                                          X_attribute15		       =>NULL,
					  X_attribute16		       =>NULL,
                                          X_attribute17		       =>NULL,
                                          X_attribute18		       =>NULL,
                                          X_attribute19		       =>NULL,
                                          X_attribute20		       =>NULL);
      --Classify this organization as an inventory organization.
      IF (NVL(p_inventory_org_ind, 'Y') = 'Y') THEN
        INSERT INTO hr_organization_information(
                        ORG_INFORMATION_ID,
                        ORG_INFORMATION_CONTEXT,
                        ORGANIZATION_ID,
                        ORG_INFORMATION1,
                        ORG_INFORMATION2,
                        ORG_INFORMATION3,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATED_BY,
                        CREATION_DATE)
        VALUES (
                        hr_organization_information_s.nextval,
                        'CLASS',
                        X_organization_id,
                        'INV',
                        'Y',
                        NULL,
                        sysdate,
                        0,
                        0,
                        sysdate);
        --Define the accounting information from the fiscal policy
        INSERT INTO hr_organization_information(
                        ORG_INFORMATION_ID,
                        ORG_INFORMATION_CONTEXT,
                        ORGANIZATION_ID,
                        ORG_INFORMATION1,
                        ORG_INFORMATION2,
                        ORG_INFORMATION3,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATED_BY,
                        CREATION_DATE)
        VALUES (
                        hr_organization_information_s.nextval,
                        'Accounting Information',
                        X_organization_id,
                        l_orgn_def.set_of_books_id,
                        l_orgn_def.legal_entity,
                        l_orgn_def.operating_unit,
                        sysdate,
                        0,
                        0,
                        sysdate);

      --Fetch the organization info from mtl_parameters and insert into the table.
      OPEN Cur_get_orgn_values(l_org_id);
      FETCH Cur_get_orgn_values INTO l_parameter;
      CLOSE Cur_get_orgn_values;

      IF (p_migrate_as_ind IS NOT NULL) THEN
        l_orgn_code := p_organization_code;
	l_master_organization_id := l_parameter.master_organization_id;
	-- Bug 5352477 - Default the process enabled indicator if it is NULL
    	l_process_enabled_ind := NVL(p_process_enabled_ind, 'Y');
      ELSE
        l_process_enabled_ind := 'Y';
        l_master_organization_id := l_parameter.master_organization_id;
        OPEN Cur_org_code (p_orgn_code, 2);
        FETCH Cur_org_code INTO l_orgn_code;
        IF Cur_org_code%NOTFOUND THEN
          CLOSE Cur_org_code;
          OPEN Cur_org_code (p_orgn_code, 1);
          FETCH Cur_org_code INTO l_orgn_code;
          IF Cur_org_code%NOTFOUND THEN
            CLOSE Cur_org_code;
            OPEN Cur_org_code (p_orgn_code, 0);
            FETCH Cur_org_code INTO l_orgn_code;
            CLOSE Cur_org_code;
          ELSE
            CLOSE Cur_org_code;
          END IF;
        ELSE
          CLOSE Cur_org_code;
        END IF;
      END IF;

      /* Fetch the default cost group for the organization */
      INV_COST_GROUP_PVT.get_default_cost_group
  	(x_return_status               => l_return_status,
   	 x_msg_count                   => l_msg_count,
   	 x_msg_data                    => l_msg_data,
   	 x_cost_group_id               => l_cost_group_id,
   	 p_material_account            => l_parameter.Material_Account,
   	 p_material_overhead_account   => l_parameter.Material_Overhead_Account,
   	 p_resource_account            => l_parameter.Resource_Account,
   	 p_overhead_account            => l_parameter.Overhead_Account,
   	 p_outside_processing_account  => l_parameter.Outside_Processing_Account,
   	 p_expense_account             => l_parameter.Expense_Account,
   	 p_encumbrance_account         => l_parameter.Encumbrance_Account,
         p_average_cost_var_account    => l_parameter.Average_Cost_Var_Account,
   	 p_organization_id             => x_organization_id,
         p_cost_group                  => NULL
   	);

      IF (l_return_status <> 'S') then
	RAISE COST_GROUP_SETUP_ERR;
      END IF;

      /* Bug 5358112 changed the primary cost method to 1 */
      INSERT INTO mtl_parameters(
          organization_id, last_update_date, last_updated_by, creation_date, created_by, last_update_login,
          organization_code, master_organization_id, primary_cost_method, cost_organization_id,
          default_material_cost_id, calendar_exception_set_id, calendar_code, general_ledger_update_code,
          default_atp_rule_id, default_picking_rule_id, default_locator_order_value, default_subinv_order_value,
          negative_inv_receipt_code, stock_locator_control_code, material_account, material_overhead_account,
          matl_ovhd_absorption_acct, resource_account, purchase_price_var_account, ap_accrual_account,
          overhead_account, outside_processing_account, intransit_inv_account, interorg_receivables_account,
          interorg_price_var_account, interorg_payables_account, cost_of_sales_account, encumbrance_account,
          interorg_transfer_cr_account, matl_interorg_transfer_code, interorg_trnsfr_charge_percent,
          source_organization_id, source_subinventory, source_type, serial_number_type,
          auto_serial_alpha_prefix, start_auto_serial_number, auto_lot_alpha_prefix, lot_number_uniqueness,
          lot_number_generation, lot_number_zero_padding, lot_number_length, starting_revision,
          default_demand_class, encumbrance_reversal_flag, maintain_fifo_qty_stack_type,
          invoice_price_var_account, average_cost_var_account, sales_account, expense_account,
          serial_number_generation, mat_ovhd_cost_type_id, project_reference_enabled,
          pm_cost_collection_enabled, project_control_level, avg_rates_cost_type_id, txn_approval_timeout_period,
          borrpay_matl_var_account, borrpay_moh_var_account, borrpay_res_var_account, borrpay_osp_var_account,
          borrpay_ovh_var_account, org_max_weight, org_max_volume, org_max_weight_uom_code, org_max_volume_uom_code,
          mo_source_required, mo_pick_confirm_required, mo_approval_timeout_action, project_cost_account,
          process_enabled_flag, process_orgn_code, wsm_enabled_flag, default_cost_group_id, wms_enabled_flag, qa_skipping_insp_flag,default_status_id)
      VALUES (
          X_organization_id, l_parameter.last_update_date, l_parameter.last_updated_by, l_parameter.creation_date,
	  l_parameter.created_by, l_parameter.last_update_login,l_orgn_code, l_master_organization_id, 1,
  	  X_organization_id, l_parameter.default_material_cost_id, l_parameter.calendar_exception_set_id,
	  l_parameter.calendar_code, l_parameter.general_ledger_update_code, l_parameter.default_atp_rule_id,
	  l_parameter.default_picking_rule_id, l_parameter.default_locator_order_value, l_parameter.default_subinv_order_value,
          l_parameter.negative_inv_receipt_code, 4, l_parameter.material_account,
	  l_parameter.material_overhead_account, l_parameter.matl_ovhd_absorption_acct, l_parameter.resource_account,
          l_parameter.purchase_price_var_account, l_parameter.ap_accrual_account, l_parameter.overhead_account,
          l_parameter.outside_processing_account, l_parameter.intransit_inv_account, l_parameter.interorg_receivables_account,
          l_parameter.interorg_price_var_account, l_parameter.interorg_payables_account, l_parameter.cost_of_sales_account,
	  l_parameter.encumbrance_account, l_parameter.interorg_transfer_cr_account, l_parameter.matl_interorg_transfer_code,
	  l_parameter.interorg_trnsfr_charge_percent, l_parameter.source_organization_id, l_parameter.source_subinventory,
	  l_parameter.source_type, l_parameter.serial_number_type, l_parameter.auto_serial_alpha_prefix, l_parameter.start_auto_serial_number,
	  l_parameter.auto_lot_alpha_prefix, 2, l_parameter.lot_number_generation, l_parameter.lot_number_zero_padding,
	  l_parameter.lot_number_length, l_parameter.starting_revision, l_parameter.default_demand_class, l_parameter.encumbrance_reversal_flag,
	  l_parameter.maintain_fifo_qty_stack_type, l_parameter.invoice_price_var_account, l_parameter.average_cost_var_account, l_parameter.sales_account,
	  l_parameter.expense_account, l_parameter.serial_number_generation, l_parameter.mat_ovhd_cost_type_id, l_parameter.project_reference_enabled,
          l_parameter.pm_cost_collection_enabled, l_parameter.project_control_level, l_parameter.avg_rates_cost_type_id, l_parameter.txn_approval_timeout_period,
          l_parameter.borrpay_matl_var_account, l_parameter.borrpay_moh_var_account, l_parameter.borrpay_res_var_account, l_parameter.borrpay_osp_var_account,
          l_parameter.borrpay_ovh_var_account, l_parameter.org_max_weight, l_parameter.org_max_volume, l_parameter.org_max_weight_uom_code,
	  l_parameter.org_max_volume_uom_code, l_parameter.mo_source_required, l_parameter.mo_pick_confirm_required, l_parameter.mo_approval_timeout_action,
	  l_parameter.project_cost_account,l_process_enabled_ind, l_parameter.organization_code, l_parameter.wsm_enabled_flag,
	  l_cost_group_id, l_parameter.wms_enabled_flag, l_parameter.qa_skipping_insp_flag,p_default_status_id);


      /* Bug 5620938 - A default subinventory must be created for the organization */
      mtl_secondary_inventories_pkg.insert_row (
	         x_rowid                        => l_rowid
	       , x_secondary_inventory_name 	=> l_orgn_code
               , x_organization_id 		=> X_organization_id
               , x_last_update_date 		=> SYSDATE
               , x_last_updated_by 		=> 0
               , x_creation_date		=> SYSDATE
               , x_created_by 			=> 0
               , x_last_update_login 		=> 0
               , x_description 			=> l_organization_name
               , x_disable_date 		=> NULL
               , x_inventory_atp_code 		=> 1
               , x_availability_type 		=> 1
               , x_reservable_type 		=> 1
               , x_locator_type 		=> 5
               , x_picking_order 		=> NULL
               , x_dropping_order 		=> NULL
               , x_material_account 		=> l_parameter.material_account
               , x_material_overhead_account    => l_parameter.material_overhead_account
               , x_resource_account 		=> l_parameter.resource_account
               , x_overhead_account 	        => l_parameter.overhead_account
               , x_outside_processing_account   => l_parameter.outside_processing_account
               , x_quantity_tracked 		=> 1
               , x_asset_inventory 		=> 1
               , x_source_type 			=> NULL
               , x_source_subinventory 		=> NULL
               , x_source_organization_id 	=> NULL
               , x_requisition_approval_type 	=> NULL
               , x_expense_account 		=> l_parameter.expense_account
               , x_encumbrance_account 		=> l_parameter.encumbrance_account
               , x_attribute_category 		=> NULL
               , x_attribute1 			=> NULL
               , x_attribute2 			=> NULL
               , x_attribute3 			=> NULL
               , x_attribute4 			=> NULL
               , x_attribute5 			=> NULL
               , x_attribute6 			=> NULL
               , x_attribute7 			=> NULL
               , x_attribute8 			=> NULL
               , x_attribute9 			=> NULL
               , x_attribute10 			=> NULL
               , x_attribute11 			=> NULL
               , x_attribute12 			=> NULL
               , x_attribute13 			=> NULL
               , x_attribute14 			=> NULL
               , x_attribute15 			=> NULL
               , x_preprocessing_lead_time 	=> NULL
               , x_processing_lead_time 	=> NULL
               , x_postprocessing_lead_time 	=> NULL
               , x_demand_class 		=> NULL
               , x_project_id 			=> NULL
               , x_task_id 			=> NULL
               , x_subinventory_usage 		=> NULL
               , x_notify_list_id 		=> NULL
               , x_depreciable_flag 		=> 2
               , x_location_id 			=> NULL
               , x_status_id 			=> 1
               , x_default_loc_status_id 	=> 1
               , x_lpn_controlled_flag 		=> 0
               , x_default_cost_group_id 	=> l_cost_group_id
               , x_pick_uom_code 		=> NULL
               , x_cartonization_flag 		=> 0
               , x_planning_level 		=> 2
               , x_default_count_type_code 	=> 2
               , x_subinventory_type 		=> 1
               , x_enable_bulk_pick 		=> 'N');

      /* Create back the link to hr locations to point to the created organization */
      IF p_addr_id IS NOT NULL THEN
        UPDATE hr_locations_all
        SET    inventory_organization_id = X_organization_id
        WHERE  location_code = p_orgn_code;
      END IF;
    END IF; /* IF (p_inventory_org_ind = 'Y' OR (p_inventory_org_ind IS NULL AND p_plant_ind <> 0)) */

  EXCEPTION
    WHEN ORGN_MISSING THEN
      x_failure_count := x_failure_count + 1;
      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMA_TEMP_ORGN_MISSING_ERROR',
          p_table_name      => 'SY_ORGN_MST',
          p_context         => 'ORGANIZATION',
	  p_token1          => 'ORGANIZATION',
          p_param1          => p_orgn_code,
          p_app_short_name  => 'GMA');

    WHEN COST_GROUP_SETUP_ERR THEN
      x_failure_count := x_failure_count + 1;
      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'SY_ORGN_MST',
          p_context         => 'ORGANIZATION',
          p_db_error        => p_orgn_code||'-'||l_msg_data,
          p_app_short_name  => 'GMA');

    WHEN OTHERS THEN
      x_failure_count := x_failure_count + 1;

      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'SY_ORGN_MST',
          p_context         => 'ORGANIZATION',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');
  END create_organization;


/*====================================================================
--  PROCEDURE:
--    migrate_organization
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to migrate the Organizations to
--    Discrete tables .
--
--
--  PARAMETERS:
--    P_migration_run_id - id to use to right to migration log
--    x_failure_count       - Number of failures occurred.
--
--  SYNOPSIS:
--    migrate_organization(p_migartion_id    => l_migration_id,
--                         p_commit          => 'T',
--                         x_failure_count   => l_failure_count );
--
--  HISTORY
--   05-APR-2007   ACATALDO     Bug 5727749 - Initialized migrate counter to
--                              avoid token showing in error log when a null
--                              is passed.
--   06-APR-2007   ACATALDO     Bug 5955262 - Used correct token in exception
--                              block for migration table failure and
--                              warehouse insert error.
--   17-Dec-2007   RLNAGARA     Bug 6607319 - Modified for Material Status ME
--====================================================================*/

  PROCEDURE migrate_organization (P_migration_run_id	IN  NUMBER,
                                  P_commit		IN  VARCHAR2,
                                  X_failure_count	OUT NOCOPY NUMBER) IS

    --CURSORS
    CURSOR Cur_get_organization IS
      SELECT *
      FROM   sy_orgn_mst
      WHERE  (migrate_as_ind <> 0 OR migrate_as_ind IS NULL)
      AND    (orgn_code <> co_code or plant_ind > 0)
      AND    NVL(migrated_ind,0) = 0;

    --RLNAGARA Material Status Migration ME - Added the below cursor
    CURSOR Cur_get_status_id(v_status VARCHAR2) IS
      SELECT status_id
      FROM mtl_material_statuses
      WHERE status_code = v_status;

    --LOCAL VARIABLES
    l_organization_id           NUMBER;
    l_migration_id		NUMBER;
    l_failure_count		NUMBER;
    l_migrate_count             NUMBER;
    l_default_status_id       NUMBER;  --RLNAGARA Material Status Migration ME

    --Exceptions
    CREATE_ORGN_ERROR	EXCEPTION;
    WHSE_CODE_ERROR     EXCEPTION;
    --RLNAGARA Material Status Migration ME
    DEFAULT_STATUS_MISSING	EXCEPTION;
    STATUS_ID_MISSING	EXCEPTION;
  BEGIN
    l_migration_id := P_migration_run_id;
    X_failure_count := 0;
    l_migrate_count := 0; /* Bug 5727749 */


    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => l_migration_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
       p_table_name      => 'SY_ORGN_MST',
       p_context         => 'ORGANIZATION',
       p_app_short_name  => 'GMA');

    FOR l_rec IN Cur_get_organization LOOP
    BEGIN
      SAVEPOINT Organization_Setup;

      --RLNAGARA Material Status Migration ME
      IF (l_rec.default_status IS NULL) THEN
        RAISE DEFAULT_STATUS_MISSING;
      ELSE
         OPEN Cur_get_status_id(l_rec.default_status);
         FETCH Cur_get_status_id INTO l_default_status_id;
         IF Cur_get_status_id%NOTFOUND THEN
           CLOSE Cur_get_status_id;
	   RAISE STATUS_ID_MISSING;
	 END IF;
         CLOSE Cur_get_status_id;
      END IF;

      IF NVL(l_rec.migrate_as_ind, 1) IN (1,3) THEN
        create_organization (P_template_organization_id	=> l_rec.template_organization_id
                            ,P_orgn_code		=> l_rec.orgn_code
                            ,P_orgn_name                => l_rec.orgn_name
                            ,P_organization_code        => l_rec.organization_code
                            ,P_organization_name        => l_rec.organization_name
                            ,P_addr_id                  => l_rec.addr_id
                            ,P_creation_date            => l_rec.creation_date
                            ,P_inventory_org_ind        => l_rec.inventory_org_ind
			    ,P_default_status_id        => l_default_status_id       --RLNAGARA Material Status Migration ME
                            ,P_plant_ind                => l_rec.plant_ind
                            ,P_migrate_as_ind           => l_rec.migrate_as_ind
                            ,P_process_enabled_ind      => l_rec.process_enabled_ind
                            ,P_delete_mark              => l_rec.delete_mark
                            ,P_migration_run_id         => p_migration_run_id
                            ,X_organization_id          => l_organization_id
                            ,X_failure_count	        => l_failure_count);
        IF l_failure_count > 0 THEN
          RAISE CREATE_ORGN_ERROR;
        END IF;
      ELSE
        l_organization_id := l_rec.organization_id;
	--RLNAGARA Material Status Migration ME - Updating for already existing organizations
        UPDATE mtl_parameters
        SET default_status_id = l_default_status_id
        WHERE organization_id = l_rec.organization_id;
      END IF; /* IF NVL(l_rec.migrate_as_ind, 1) IN (1,3) */

      UPDATE sy_orgn_mst_b
      SET    organization_id = l_organization_id,
             migrated_ind = 1
      WHERE  orgn_code = l_rec.orgn_code;

      migrate_subinventory(P_migration_run_id => l_migration_id,
                           P_orgn_code        => l_rec.orgn_code,
                           P_commit 	        => FND_API.G_FALSE,
	 	           X_failure_count    => l_failure_count);
      IF (l_failure_count > 0) THEN
        RAISE WHSE_CODE_ERROR;
      END IF;

      --Bases on the p_commit flag commit the transaction.
      IF p_commit = FND_API.G_TRUE THEN
        COMMIT;
      END IF;
      l_migrate_count := l_migrate_count + 1;

    EXCEPTION
      WHEN CREATE_ORGN_ERROR THEN
        x_failure_count := x_failure_count + 1;
        ROLLBACK TO Organization_Setup;
        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMA_ORGN_MISSING_ERROR',
          p_table_name      => 'SY_ORGN_MST',
          p_context         => 'ORGANIZATION',
	  p_token1          => 'ORGANIZATION',
          p_param1          => l_rec.orgn_code,
          p_app_short_name  => 'GMA');

      WHEN WHSE_CODE_ERROR THEN
        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMA_MIGRATION_FAIL',
          p_token1          => 'PARAM1',
          p_param1          => 'due to an error in migrating the W/H as a subinventory',
          p_context         => 'ORGANIZATION',
          p_app_short_name  => 'GMA');

    --RLNAGARA Material Status Migration ME
    WHEN DEFAULT_STATUS_MISSING THEN
      x_failure_count := x_failure_count + 1;
      GMA_COMMON_LOGGING.gma_migration_central_log(
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMA_DEFAULT_STATUS_MISSING_ERROR',
          p_table_name      => 'SY_ORGN_MST',
          p_context         => 'ORGANIZATION',
	  p_token1          => 'ORGANIZATION',
          p_param1          => l_rec.organization_code,
          p_app_short_name  => 'GMA');

    --RLNAGARA Material Status Migration ME
    WHEN STATUS_ID_MISSING THEN
      x_failure_count := x_failure_count + 1;
      GMA_COMMON_LOGGING.gma_migration_central_log(
          p_run_id          => P_migration_run_id,
          p_log_level       => FND_LOG.LEVEL_ERROR,
          p_message_token   => 'GMD_MIG_STATUS_ID',
          p_table_name      => 'MTL_MATERIAL_STATUSES',
          p_context         => 'STAT',
	  p_token1          => 'STAT',
          p_param1          => l_rec.default_status,
          p_app_short_name  => 'GMA');

      WHEN OTHERS THEN
        x_failure_count := x_failure_count + 1;
        ROLLBACK TO Organization_Setup;
        GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'SY_ORGN_MST',
          p_context         => 'ORGANIZATION',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');
    END;
    END LOOP;

    GMA_COMMON_LOGGING.gma_migration_central_log (
       p_run_id          => l_migration_id,
       p_log_level       => FND_LOG.LEVEL_PROCEDURE,
       p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
       p_table_name      => 'SY_ORGN_MST',
       p_context         => 'ORGANIZATION',
       p_param1          => l_migrate_count,
       p_param2          => X_failure_count,
       p_app_short_name  => 'GMA');


    EXCEPTION
      WHEN OTHERS THEN
      x_failure_count := X_failure_count + 1;

      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
          p_message_token   => 'GMA_MIGRATION_DB_ERROR',
          p_table_name      => 'SY_ORGN_MST',
          p_context         => 'ORGANIZATION',
          p_db_error        => SQLERRM,
          p_app_short_name  => 'GMA');

      GMA_COMMON_LOGGING.gma_migration_central_log (
          p_run_id          => l_migration_id,
          p_log_level       => FND_LOG.LEVEL_PROCEDURE,
          p_message_token   => 'GMA_MIGRATION_TABLE_FAIL',
          p_table_name      => 'SY_ORGN_MST',
          p_context         => 'ORGANIZATION',
          p_app_short_name  => 'GMA');

END migrate_organization;

END INV_MIGRATE_PROCESS_ORG;


/
