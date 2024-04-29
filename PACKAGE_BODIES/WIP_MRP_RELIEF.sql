--------------------------------------------------------
--  DDL for Package Body WIP_MRP_RELIEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MRP_RELIEF" AS
 /* $Header: wipmrpb.pls 120.0.12010000.3 2010/02/11 04:09:21 pding ship $ */


PROCEDURE WIP_DISCRETE_JOBS_PROC
 (item_id               IN NUMBER,
  org_id                IN NUMBER,
  last_upd_date         IN DATE,
  last_upd_by           IN NUMBER,
  creat_date            IN DATE,
  creat_by              IN NUMBER,
  new_mps_quantity      IN NUMBER,
  old_mps_quantity      IN NUMBER,
  new_start_quantity    IN NUMBER, /*add for bug 8979443 (FP of 8420494)*/
  old_start_quantity    IN NUMBER, /*add for bug 8979443 (FP of 8420494)*/
  new_sched_compl_date  IN DATE,
  old_sched_compl_date  IN DATE,
  wip_enty_id           IN NUMBER,
  srce_code             IN VARCHAR2,
  srce_line_id          IN NUMBER,
  new_bill_desig        IN VARCHAR2,
  old_bill_desig        IN VARCHAR2,
  new_bill_rev_date     IN DATE,
  old_bill_rev_date     IN DATE,
  new_dmd_class         IN VARCHAR2,
  old_dmd_class         IN VARCHAR2,
  new_status_type       IN NUMBER,
  old_status_type       IN NUMBER,
  new_qty_completed     IN NUMBER,
  old_qty_completed     IN NUMBER,
  new_date_completed    IN DATE,
  old_date_completed    IN DATE,
  new_project_id	IN NUMBER,
  old_project_id	IN NUMBER,
  new_task_id		IN NUMBER,
  old_task_id		IN NUMBER) IS

  new_qty NUMBER;
  old_qty NUMBER;
  new_date DATE;
  old_date DATE;

  wip_req_ops_rows NUMBER;

BEGIN

/*-------  Determine quantities and date for the insert ------------------*/
IF INSERTING THEN

        /*------------------------------------------------------------+
        | Insert - relieve if status is "effective" (procedure will
        | only be called in these cases due to trigger's WHEN clause) |
        +-------------------------------------------------------------*/
        new_qty := NVL(new_mps_quantity,0);
        old_qty := null;
        new_date := new_sched_compl_date;
        old_date := null;

ELSIF DELETING THEN

	/* Note that we are dropping the delete trigger for Prod16, rel10.7
	   11/18/96 (djoffe) I am leaving this logic here for historical
	   purposes.  */

        /*------------------------------------------------------------+
        | Delete - unrelieve if status is "effective" (procedure will |
        | only be called in these cases due to trigger's WHEN clause) |
        +-------------------------------------------------------------*/
        new_qty := NVL(LEAST(old_mps_quantity, old_qty_completed),0);
        old_qty := old_mps_quantity;
        new_date := SYSDATE;
        old_date := NVL(old_date_completed,old_sched_compl_date);

ELSIF UPDATING THEN

        /*------------------------------------------------------------+
        |                                                             |
        | Update - Changes to status_type are only important if they  |
        | move between an "effective" status (1,3,4,5,6) and a        |
        | "non-effective" status (7 - 15).                            |
        |                                                             |
        |       * Updates within a "non-effective" status should be   |
        |       ignored                                               |
        |                                                             |
        |       * Updates from an "effective" status to a             |
        |       "non-effective" status should be treated as deletes   |
        |                                                             |
        |       * Updates from an "non-effective" status to a         |
        |       "effective" status should be treated as inserts       |
        |                                                             |
        |       * Updated within an "effective" status should ignore  |
        |       the status and pass the other changed values to the   |
        |       mrp_relief_interface table                            |
        |                                                             |
        +------------------------------------------------------------*/

 /* NOTE - changes within a "non-effective" status have already been
           screened out */

 /* Changes from an "effective" status to a "non-effective" status */
        IF (old_status_type < 7 AND new_status_type > 6) THEN
          old_qty := old_mps_quantity;
          new_qty := NVL(LEAST(old_qty, old_qty_completed), 0);
          old_date := NVL(old_date_completed, old_sched_compl_date);
          new_date := LEAST(TRUNC(SYSDATE), old_date);
          IF (old_qty = new_qty) AND (old_date = new_date) THEN
            return;
          END IF;

 /* Changes from an "non-effective" status to a "effective" status */
        ELSIF (old_status_type > 6  AND new_status_type < 7) THEN
          new_qty := NVL(new_mps_quantity,0);
          old_qty := null;
          new_date := NVL(new_date_completed,new_sched_compl_date);
          old_date := null;

 /* Changes within an "effective" status */
        ELSIF (old_status_type < 7 AND new_status_type < 7) THEN
          new_qty := NVL(new_mps_quantity, 0);
          old_qty := old_mps_quantity;
          new_date := TRUNC(NVL(new_date_completed, new_sched_compl_date));
          old_date := TRUNC(NVL(old_date_completed, old_sched_compl_date));
         /*--------------------------------------------------------------+
          |  This If stmt prevents us from inserting 2 rows into the     |
          |  mrp interface table.  Since Forms 2.3 can't handle          |
          |  date/time in one field, but the db can, we update           |
          |  wip_discrete_jobs on fnd_post_insert and fnd_post_update    |
          |  to combine the form's date and time fields into 1 db column |
          |  This would cause the trigger to fire twice.                 |
          +--------------------------------------------------------------+*/
          IF (new_qty = old_qty AND new_date = old_date AND
 	               new_start_quantity = old_start_quantity AND       /*add for bug 8979443 (FP of 8420494)*/
            NVL(new_dmd_class,'NONEXISTENT') =
                      NVL(old_dmd_class,'NONEXISTENT') AND
            NVL(new_bill_desig, 'NONEXISTENT') =
                      NVL(old_bill_desig, 'NONEXISTENT') AND
	    NVL(old_project_id, -111) =
		      NVL(new_project_id, -111) AND
            NVL(old_task_id, -111) =
                      NVL(new_task_id, -111) ) THEN
         /*-----------------------------------------------------------------+
          |  This If stmt checks to see if any rows changes in WIP_REQ_OPS. |
          |  If the BILL_REVISION_DATE, ALT_BILL_DESIG, OR BILL_REF changed |
          |  for an unreleased job, the old bill was deleted and a new bill |
          |  was exploded.  Unfortunately, because of the date/time problem |
          |  described above (in this case, for BILL_REVISION_DATE), we     |
          |  must actually check and see if any requirements were changed.  |
          +-----------------------------------------------------------------+*/
            SELECT COUNT(*)
              INTO wip_req_ops_rows
              FROM WIP_REQUIREMENT_OPERATIONS
             WHERE WIP_ENTITY_ID = wip_enty_id
               AND ORGANIZATION_ID = org_id
               AND (NVL(MPS_REQUIRED_QUANTITY,required_quantity+1) <>
                        required_quantity
                 OR NVL(MPS_DATE_REQUIRED,date_required+1) <> date_required);

	    IF wip_req_ops_rows = 0 THEN
	      return;
	    END IF;

          END IF;

        ELSE
	  return; -- if old/new status not in above categories
        END IF;

END IF;

IF (ITEM_ID IS NOT NULL) THEN /*BUG 7240404 (FP of 7126271)*/
/*     MPS relief for assembly   */
        INSERT INTO mrp_relief_interface
                    (inventory_item_id,  -- NN
                     organization_id,    -- NN
                     last_update_date,   -- NN  sysdate
                     last_updated_by,    -- NN  :new.last_updated_by
                     creation_date,      -- NN  sysdate
                     created_by,         -- NN  :new.created_by
                     last_update_login,  --  N   -1
                     new_order_quantity, -- NN
                     old_order_quantity, --  N
                     new_order_date,     -- NN
                     old_order_date,     --  N
                     disposition_id,     -- NN  :new.wip_entity_id
                     planned_order_id,   --  N  :new.source_code,'MRP',
                     relief_type,        -- NN  2
                     disposition_type,   -- NN  1
                     demand_class,       --  N
                     old_demand_class,   --  N
                     line_num,           --  N  null
                     request_id,         --  N  null
                     program_application_id, --  N null
                     program_id,         --  N  null
                     program_update_date, -- N  null
                     process_status,     -- NN   2
                     source_code,        --  N  'WIP'
                     source_line_id,     --  N  null
                     error_message,      --  N  null
                     transaction_id,     --  NN
		     project_id,
		     old_project_id,
		     task_id,
		     old_task_id
                    )
           VALUES   (item_id,
                     org_id,
                     last_upd_date,
                     last_upd_by,
                     creat_date,
                     creat_by,
                     -1,
                     new_qty,
                     old_qty,
                     new_date,
                     old_date,
                     wip_enty_id,
                     DECODE(srce_code, 'MRP', srce_line_id, null),
                     2,
                     1,
                     new_dmd_class,
                     old_dmd_class,
                     null,
                     null,
                     null,
                     null,
                     null,
                     2,
                     'WIP',
                     null,
                     null,
                     mrp_relief_interface_s.nextval,
		     new_project_id,
		     old_project_id,
		     new_task_id,
		     old_task_id
                    );

/* Bug 3030600 - Will consider DATE_REQUIRED as new_date for phantom
                 components, except for Deletion case. Here keeping
                 new_date as SYSDATE as before */
IF DELETING THEN
/*     MPS relief for phantom components   */
        INSERT INTO mrp_relief_interface
                    (inventory_item_id,  -- NN
                     organization_id,    -- NN
                     last_update_date,   -- NN  sysdate
                     last_updated_by,    -- NN  :new.last_updated_by
                     creation_date,      -- NN  sysdate
                     created_by,         -- NN  :new.created_by
                     last_update_login,  --  N   -1
                     new_order_quantity, -- NN
                     old_order_quantity, --  N
                     new_order_date,     -- NN
                     old_order_date,     --  N
                     disposition_id,     -- NN  :new.wip_entity_id
                     planned_order_id,   --  N  :new.source_code,'MRP',
                     relief_type,        -- NN  2
                     disposition_type,   -- NN  1
                     demand_class,       --  N
                     old_demand_class,   --  N
                     line_num,           --  N  null
                     request_id,         --  N  null
                     program_application_id, --  N null
                     program_id,         --  N  null
                     program_update_date, -- N  null
                     process_status,     -- NN   2
                     source_code,        --  N  'WIP'
                     source_line_id,     --  N  null
                     error_message,      --  N  null
                     transaction_id,     -- NN
		     project_id,
		     old_project_id,
		     task_id,
		     old_task_id
                    )
              SELECT inventory_item_id,
                     organization_id,
                     last_upd_date,
                     last_upd_by,
                     creat_date,
                     creat_by,
                     -1,
                     quantity_per_assembly * new_qty,
                     quantity_per_assembly * old_qty,
                     new_date,
                     old_date,
                     wip_entity_id,
                     DECODE(srce_code, 'MRP', srce_line_id, null),
                     2,
                     1,
                     new_dmd_class,
                     old_dmd_class,
                     null,
                     null,
                     null,
                     null,
                     null,
                     2,
                     'WIP',
                     null,
                     null,
                     mrp_relief_interface_s.nextval,
		     new_project_id,
		     old_project_id,
		     new_task_id,
		     old_task_id
                FROM wip_requirement_operations
               WHERE wip_entity_id = wip_enty_id
                 AND organization_id = org_id
                 AND wip_supply_type = 6;
ELSE                                       /** INSERTING or UPDATING **/
        INSERT INTO mrp_relief_interface
                    (inventory_item_id,  -- NN
                     organization_id,    -- NN
                     last_update_date,   -- NN  sysdate
                     last_updated_by,    -- NN  :new.last_updated_by
                     creation_date,      -- NN  sysdate
                     created_by,         -- NN  :new.created_by
                     last_update_login,  --  N   -1
                     new_order_quantity, -- NN
                     old_order_quantity, --  N
                     new_order_date,     -- NN
                     old_order_date,     --  N
                     disposition_id,     -- NN  :new.wip_entity_id
                     planned_order_id,   --  N  :new.source_code,'MRP',
                     relief_type,        -- NN  2
                     disposition_type,   -- NN  1
                     demand_class,       --  N
                     old_demand_class,   --  N
                     line_num,           --  N  null
                     request_id,         --  N  null
                     program_application_id, --  N null
                     program_id,         --  N  null
                     program_update_date, -- N  null
                     process_status,     -- NN   2
                     source_code,        --  N  'WIP'
                     source_line_id,     --  N  null
                     error_message,      --  N  null
                     transaction_id,     -- NN
		     project_id,
		     old_project_id,
		     task_id,
		     old_task_id
                    )
              SELECT inventory_item_id,
                     organization_id,
                     last_upd_date,
                     last_upd_by,
                     creat_date,
                     creat_by,
                     -1,
                     quantity_per_assembly * new_qty,
                     quantity_per_assembly * old_qty,
                     date_required,   -- use WRO date_required as new_date
                     old_date,
                     wip_entity_id,
                     DECODE(srce_code, 'MRP', srce_line_id, null),
                     2,
                     1,
                     new_dmd_class,
                     old_dmd_class,
                     null,
                     null,
                     null,
                     null,
                     null,
                     2,
                     'WIP',
                     null,
                     null,
                     mrp_relief_interface_s.nextval,
		     new_project_id,
		     old_project_id,
		     new_task_id,
		     old_task_id
                FROM wip_requirement_operations
               WHERE wip_entity_id = wip_enty_id
                 AND organization_id = org_id
                 AND wip_supply_type = 6;
END IF;

ELSE
RETURN;
END IF;

END WIP_DISCRETE_JOBS_PROC;

PROCEDURE WIP_FLOW_SCHEDULES_PROC
 (item_id               IN NUMBER,
  org_id                IN NUMBER,
  last_upd_date         IN DATE,
  last_upd_by           IN NUMBER,
  creat_date            IN DATE,
  creat_by              IN NUMBER,
  new_request_id        IN NUMBER,
  old_request_id        IN NUMBER,
  dmd_src_type	    	IN NUMBER,
  dmd_src_line      	IN VARCHAR2,
  new_mps_quantity      IN NUMBER,
  old_mps_quantity      IN NUMBER,
  new_sched_compl_date  IN DATE,
  old_sched_compl_date  IN DATE,
  wip_enty_id           IN NUMBER,
  new_dmd_class         IN VARCHAR2,
  old_dmd_class         IN VARCHAR2,
  new_bill_desig        IN VARCHAR2,
  old_bill_desig        IN VARCHAR2,
  new_status_type       IN NUMBER,
  old_status_type       IN NUMBER,
  new_qty_completed     IN NUMBER,
  old_qty_completed     IN NUMBER,
  new_date_completed    IN DATE,
  old_date_completed    IN DATE,
  new_project_id	IN NUMBER,
  old_project_id	IN NUMBER,
  new_task_id		IN NUMBER,
  old_task_id		IN NUMBER) IS

  new_qty NUMBER;
  old_qty NUMBER;
  new_date DATE;
  old_date DATE;

  bill_desig_changed	BOOLEAN := FALSE;

BEGIN

/*-------  Determine quantities and date for the insert ------------------*/
  IF INSERTING THEN

      -- this is a kludge for the line scheduling workbench form
      IF new_request_id IS NOT NULL THEN
        return;
      END IF;

        /*------------------------------------------------------------+
        | Insert - relieve if status is "Open" (procedure will        |
        | only be called in this cases due to trigger's IF clause)    |
        +-------------------------------------------------------------*/
        new_qty  := NVL(new_mps_quantity,0);
        old_qty  := null;
        new_date := new_sched_compl_date;
        old_date := null;

  ELSIF DELETING THEN

      -- this is a kludge for the line scheduling workbench form
      IF old_request_id IS NOT NULL THEN
        return;
      END IF;

        /*------------------------------------------------------------+
        | Delete - unrelieve if status is "Open" (procedure will      |
        | only be called in this cases due to trigger's WHEN clause)  |
        +-------------------------------------------------------------*/
        new_qty  := NVL(LEAST(old_mps_quantity, old_qty_completed),0);
        old_qty  := old_mps_quantity;
        new_date := SYSDATE;
        old_date := old_sched_compl_date;

  ELSIF UPDATING THEN
        /*------------------------------------------------------------+
        | Bug 2289820, we will not consider status when doing relief   |
        +-------------------------------------------------------------*/


        /*------------------------------------------------------------+
        |                                                             |
        | Update - Changes to status_type are only important if they  |
        | move between an "Open" status (1) and a "Closed"	      |
	| status (2).                                                 |
        |                                                             |
        |       * Updates within a "Closed" status should be          |
        |         ignored                                             |
        |                                                             |
        |       * Updates from an "Open" status to a                  |
        |         "Closed" status should be treated as deletes        |
        |                                                             |
        |       * Updates from a "Closed" status to an                |
        |         "Open" status should be treated as inserts          |
        |                                                             |
        |       * Updated within an "Open"  status should ignore      |
        |         the status and pass the other changed values to the |
        |         mrp_relief_interface table                          |
        |                                                             |
        +------------------------------------------------------------*/

        /* NOTE - changes within a "Closed" status have already been
                  screened out */

        /* Changes from an "Open" status to a "Closed" status */
/*      IF (old_status_type = 1 AND new_status_type = 2) THEN
          old_qty  := old_mps_quantity;
          new_qty  := NVL(LEAST(old_qty, old_qty_completed), 0);
          old_date := old_sched_compl_date;
          new_date := LEAST(TRUNC(SYSDATE), old_date);

          IF (old_qty = new_qty) AND (old_date = new_date) THEN
            return;
          END IF;
commented the above in 2289820*/

        /* Changes from an "non-effective" status to a "effective" status */
/*      ELSIF (old_status_type = 2  AND new_status_type = 1) THEN
          new_qty  := NVL(new_mps_quantity,0);
          old_qty  := null;
          new_date := new_sched_compl_date;
          old_date := null;
commented the above in bug#2289820*/

        /* Changes within an "effective" status */
--commented in bug#2289820        ELSIF (old_status_type = 1 AND new_status_type = 1) THEN
          /* Added for bug number 2222628 */
          IF (old_request_id is NOT NULL AND new_request_id is NOT NULL) then
             IF ( new_mps_quantity = old_mps_quantity and new_mps_quantity = 0 and
                  old_mps_quantity = 0 ) then
                  null;
             else
              return;
             end if;
          END IF;
          IF (old_request_id is NOT NULL AND new_request_id is NULL) THEN
	    -- kludge for the line scheduling workbench form - treat this
  	    -- like an insert
            new_qty  := NVL(new_mps_quantity,0);
            old_qty  := null;
            new_date := new_sched_compl_date;
            old_date := null;
  	  ELSE
/*          new_qty  := NVL(new_mps_quantity, 0);
            old_qty  := old_mps_quantity; Commented and added the following two lines in  2289820
            new_qty  := NVL(greatest(new_mps_quantity,new_qty_completed), 0);
            old_qty  := greatest(old_mps_quantity,old_qty_completed);*/

            if (abs(new_mps_quantity) >= abs(new_qty_completed)) then
               new_qty := nvl(new_mps_quantity, 0);
            Else
               new_qty := nvl(new_qty_completed,0);
            End if;

            if (abs(old_mps_quantity) >= abs(old_qty_completed)) then
               old_qty := old_mps_quantity;
            Else
               old_qty := old_qty_completed;
            End if;

            new_date := TRUNC(new_sched_compl_date);
            old_date := TRUNC(old_sched_compl_date);
	  END IF;

   	  IF nvl(new_bill_desig, '@$!') <> nvl(old_bill_desig, '@$!') THEN
	    bill_desig_changed := TRUE;
  	  ELSE
	    bill_desig_changed := FALSE;
	  END IF;
--commented in bug#2289820	END IF;

  END IF;

  /* Now insert a record into MRP_RELIEF_INTERFACE to take care of
     MPS relief for assembly  Note that if bill designator changes
     we do not insert a row for the assembly. */


    INSERT INTO mrp_relief_interface
                    (inventory_item_id,  	-- NN
                     organization_id,    	-- NN
                     last_update_date,   	-- NN  sysdate
                     last_updated_by,    	-- NN  :new.last_updated_by
                     creation_date,      	-- NN  sysdate
                     created_by,         	-- NN  :new.created_by
                     last_update_login,  	--  N   -1
                     new_order_quantity, 	-- NN
                     old_order_quantity, 	--  N
                     new_order_date,     	-- NN
                     old_order_date,     	--  N
                     disposition_id,     	-- NN  :new.wip_entity_id
                     planned_order_id,   	--  N
                     relief_type,        	-- NN  2
                     disposition_type,   	-- NN  9
                     demand_class,       	--  N
                     old_demand_class,   	--  N
                     line_num,           	--  N  null
                     request_id,         	--  N  null
                     program_application_id, 	--  N  null
                     program_id,         	--  N  null
                     program_update_date, 	--  N  null
                     process_status,     	-- NN  2
                     source_code,        	--  N  'WIP'
                     source_line_id,     	--  N  null
                     error_message,      	--  N  null
                     transaction_id,     	-- NN
		     project_id,
		     old_project_id,
		     task_id,
		     old_task_id
                    )
    VALUES   	    (item_id,
                     org_id,
                     last_upd_date,
                     last_upd_by,
                     creat_date,
                     creat_by,
                     -1,
                     new_qty,
                     old_qty,
                     new_date,
                     old_date,
                     wip_enty_id,
                     DECODE (dmd_src_type, 100, to_number(dmd_src_line), null),
                     2,
                     9,
                     new_dmd_class,
                     old_dmd_class,
                     null,
                     null,
                     null,
                     null,
                     null,
                     2,
                     'WIP',
                     null,
                     null,
                     mrp_relief_interface_s.nextval,
		     new_project_id,
		     old_project_id,
		     new_task_id,
		     old_task_id
                    );

  IF NOT bill_desig_changed THEN

    /* insert any rows for phantom items */

	INSERT
	INTO mrp_relief_interface
        (inventory_item_id,
         organization_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         new_order_quantity,
         old_order_quantity,
         new_order_date,
         old_order_date,
         disposition_id,
         planned_order_id,
         relief_type,
         disposition_type,
         demand_class,
         old_demand_class,
         line_num,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         process_status,
         source_code,
         source_line_id,
         error_message,
         transaction_id,
         project_id,
         old_project_id,
         task_id,
         old_task_id)
	SELECT
       	bic.component_item_id,
       	org_id,
	sysdate,
	-1,
	sysdate,
	-1,
	null,
	nvl(new_qty,0) *
		nvl(bic.component_quantity,1),
	nvl(old_qty,0) *
		nvl(bic.component_quantity,1),
        new_date,
        old_date,
        wip_enty_id,
        null,
        2,
        9,
        new_dmd_class,
        old_dmd_class,
        null,
        null,
        null,
        null,
        null,
        2,
        'WIP',
        null,
        null,
        mrp_relief_interface_s.nextval,
        new_project_id,
	old_project_id,
	new_task_id,
	old_task_id
	FROM
       	mtl_system_items msi,
       	bom_inventory_components bic,
       	bom_bill_of_materials bbom
	WHERE   bbom.assembly_item_id = item_id
	AND     NVL(bbom.alternate_bom_designator, '@$!') =
			NVL(new_bill_desig, '@$!')
	AND     bbom.organization_id = org_id
        AND     bic.bill_sequence_id = bbom.common_bill_sequence_id
        AND     (nvl(bic.disable_date, new_sched_compl_date) +1) >=
                    new_sched_compl_date
        AND     bic.effectivity_date <= new_sched_compl_date
	AND     msi.inventory_item_id = bic.component_item_id
	AND     msi.organization_id = bbom.organization_id
	AND     msi.bom_item_type in (1, 2)
	AND     NVL(bic.wip_supply_type, NVL(msi.wip_supply_type,6)) = 6;


  END IF;


  /* now check if the bill designator changed and take care of handling
     Phantom items that might be affected due to the change. What we
     do is - treat all Phantom items that belong to the new bill desig
     as inserted and treat all phantom items that belong to the old bill
     designator as deleted */

  IF bill_desig_changed THEN

        /* inserts for the new bill designator */

	INSERT
	INTO mrp_relief_interface
        (inventory_item_id,
         organization_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         new_order_quantity,
         old_order_quantity,
         new_order_date,
         old_order_date,
         disposition_id,
         planned_order_id,
         relief_type,
         disposition_type,
         demand_class,
         old_demand_class,
         line_num,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         process_status,
         source_code,
         source_line_id,
         error_message,
         transaction_id,
         project_id,
         old_project_id,
         task_id,
         old_task_id)
	SELECT
       	bic.component_item_id,
       	org_id,
	sysdate,
	-1,
	sysdate,
	-1,
	null,
        (NVL(new_mps_quantity,0) *
		nvl(bic.component_quantity,1)),
	null,
        new_sched_compl_date,
        null,
        wip_enty_id,
        null,
        2,
        9,
        new_dmd_class,
        old_dmd_class,
        null,
        null,
        null,
        null,
        null,
        2,
        'WIP',
        null,
        null,
        mrp_relief_interface_s.nextval,
        new_project_id,
	old_project_id,
	new_task_id,
	old_task_id
	FROM
       	mtl_system_items msi,
       	bom_inventory_components bic,
       	bom_bill_of_materials bbom
	WHERE   bbom.assembly_item_id = item_id
	AND     NVL(bbom.alternate_bom_designator, '@$!') =
			NVL(new_bill_desig, '@$!')
	AND     bbom.organization_id = org_id
        AND     bic.bill_sequence_id = bbom.common_bill_sequence_id
        AND     (nvl(bic.disable_date, new_sched_compl_date) +1) >=
                    new_sched_compl_date
        AND     bic.effectivity_date <= new_sched_compl_date
	AND     msi.inventory_item_id = bic.component_item_id
	AND     msi.organization_id = bbom.organization_id
	AND     msi.bom_item_type in (1, 2)
	AND     NVL(bic.wip_supply_type, NVL(msi.wip_supply_type,6)) = 6;


        /*  now insert for the old bill designator */

	INSERT
	INTO mrp_relief_interface
        (inventory_item_id,
         organization_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         new_order_quantity,
         old_order_quantity,
         new_order_date,
         old_order_date,
         disposition_id,
         planned_order_id,
         relief_type,
         disposition_type,
         demand_class,
         old_demand_class,
         line_num,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         process_status,
         source_code,
         source_line_id,
         error_message,
         transaction_id,
         project_id,
         old_project_id,
         task_id,
         old_task_id)
	SELECT
       	bic.component_item_id,
       	org_id,
	sysdate,
	-1,
	sysdate,
	-1,
	null,
        (NVL(LEAST(old_mps_quantity, old_qty_completed),0) *
		nvl(bic.component_quantity,1)),
	nvl(old_qty,0) *
		nvl(bic.component_quantity,1),
        SYSDATE,
        old_sched_compl_date,
        wip_enty_id,
        null,
        2,
        9,
        new_dmd_class,
        old_dmd_class,
        null,
        null,
        null,
        null,
        null,
        2,
        'WIP',
        null,
        null,
        mrp_relief_interface_s.nextval,
        new_project_id,
	old_project_id,
	new_task_id,
	old_task_id
	FROM
       	mtl_system_items msi,
       	bom_inventory_components bic,
       	bom_bill_of_materials bbom
	WHERE   bbom.assembly_item_id = item_id
	AND     NVL(bbom.alternate_bom_designator, '@$!') =
			NVL(old_bill_desig, '@$!')
	AND     bbom.organization_id = org_id
        AND     bic.bill_sequence_id = bbom.common_bill_sequence_id
        AND     (nvl(bic.disable_date, new_sched_compl_date) +1) >=
                    new_sched_compl_date
        AND     bic.effectivity_date <= new_sched_compl_date
	AND     msi.inventory_item_id = bic.component_item_id
	AND     msi.organization_id = bbom.organization_id
	AND     msi.bom_item_type in (1, 2)
	AND     NVL(bic.wip_supply_type, NVL(msi.wip_supply_type,6)) = 6;

  END IF; /* end if bill designator changed */

END WIP_FLOW_SCHEDULES_PROC;

END WIP_MRP_RELIEF;

/
