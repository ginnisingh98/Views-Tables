--------------------------------------------------------
--  DDL for Package Body CHV_REBUILD_SCHEDULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_REBUILD_SCHEDULES" as
/* $Header: CHVPRRBB.pls 115.0 99/07/17 01:30:16 porting ship $ */

/*======================= CHV_REBUILD_SCHEDULE===============================*/

/*=============================================================================

  PROCEDURE NAME:     rebuild_scheduled_items()

=============================================================================*/
PROCEDURE rebuild_item(
			 p_schedule_id		     in NUMBER,
		         p_autoconfirm_flag          in VARCHAR2,
	                 p_print_flag                in VARCHAR2 DEFAULT null) IS

  x_progress                  VARCHAR2(3) := NULL; -- For debugging purpose

  -- Following variables whose values should be retrieved from schedule select
  x_vendor_id                 NUMBER;
  x_vendor_site_id            NUMBER;
  x_organization_id           NUMBER;
  x_bucket_pattern_id         NUMBER;
  x_mrp_compile_designator    VARCHAR2(10);
  x_mps_schedule_designator   VARCHAR2(10);
  x_drp_compile_designator    VARCHAR2(10);
  x_schedule_subtype          VARCHAR2(25);
  x_schedule_type             VARCHAR2(25);
  x_horizon_start_date        DATE;
  x_schedule_revision         NUMBER;
  x_schedule_num	      VARCHAR2(25);
  x_include_future_releases   VARCHAR2(1);
  x_item_created              VARCHAR2(1);
  x_schedule_item_id          NUMBER;
  x_multi_org_flag            VARCHAR2(1);
  x_batch_id		      NUMBER;

  -- Following variables whose values are calculated within the procedure.

  x_user_id                   NUMBER;
  x_login_id                  NUMBER;
  x_horizon_end_date          DATE;

  -- 3 PL/SQL tables used for calculating bucket quantities.
  x_bucket_descriptor_table   chv_create_buckets.bkttable;
  x_bucket_start_date_table   chv_create_buckets.bkttable;
  x_bucket_end_date_table     chv_create_buckets.bkttable;

  x_bucket_count              BINARY_INTEGER := 1; -- DEBUG need this?

  -- We will be getting the item_planning_method in chv_schedule_items
  -- in the create_items routine.
  CURSOR ITEMS IS
  SELECT schedule_item_id
  FROM   chv_schedule_items
  WHERE  schedule_id = p_schedule_id
  AND    rebuild_flag = 'Y';

BEGIN

  dbms_output.put_line('Entering rebuild_schedule');

  -- Get x_user_id and x_login_id from the global variable set.
  x_user_id  := NVL(fnd_global.user_id, 0);
  x_login_id := NVL(fnd_global.login_id, 0);

  x_progress := '010';

  -- Find the Schedule Header that we are rebuilding. We will be using
  -- information stored at the schedule header level to determine what
  -- data is created at the lower level.
  SELECT bucket_pattern_id,
	 vendor_id,
	 vendor_site_id,
	 organization_id,
	 mrp_compile_designator,
	 mps_schedule_designator,
	 drp_compile_designator,
	 schedule_subtype,
	 schedule_type,
	 schedule_horizon_start,
	 include_future_releases_flag
  INTO   x_bucket_pattern_id,
         x_vendor_id,
         x_vendor_site_id,
         x_organization_id,
         x_mrp_compile_designator,
         x_mps_schedule_designator,
         x_drp_compile_designator,
	 x_schedule_subtype,
	 x_schedule_type,
	 x_horizon_start_date,
	 x_include_future_releases
  FROM   chv_schedule_headers
  WHERE  schedule_id = p_schedule_id;

  -- Note We need to account for that the plans may no longer
  -- exist.  They may have been deleted by the planning system.
  -- The code should be ok and not fail if this happens.  Leaving
  -- this comment here, so we are aware of the issue.

  -- Create 3 temp bucket tables (descriptor, start_date and end_date)
  --       and get x_horizon_end_date in the meantime.
  dbms_output.put_line('Build_schedule: create_bucket_template');

  x_progress := '020';

  chv_create_buckets.create_bucket_template(x_horizon_start_date,
					    x_include_future_releases,
                                            x_bucket_pattern_id,
					    x_horizon_end_date,
                                            x_bucket_descriptor_table,
                                            x_bucket_start_date_table,
                                            x_bucket_end_date_table);

  dbms_output.put_line('Build Schedules: end Date'||x_horizon_end_date);


  x_progress := '030';

  OPEN ITEMS;

  LOOP

    x_progress := '040';

    FETCH ITEMS INTO
      x_schedule_item_id;
    EXIT WHEN ITEMS%NOTFOUND;


    x_progress := '050';

    -- Delete the item that we are rebuilding
    BEGIN

      DELETE FROM chv_item_orders
      WHERE schedule_id = p_schedule_id
      AND   schedule_item_id = x_schedule_item_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN null;
      WHEN OTHERS THEN raise;

    END;

    x_progress := '060';

    -- Delete the corresponding records in chv_horizontal_schedules.
    BEGIN

      DELETE FROM chv_horizontal_schedules
      WHERE  schedule_id = p_schedule_id
      AND    schedule_item_id = x_schedule_item_id;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN null;
      WHEN OTHERS THEN raise;

    END;

    x_progress := '070';

    -- Delete the corresponding records in authorizations.
    BEGIN

      DELETE from chv_authorizations
      WHERE  reference_id = x_schedule_item_id
      AND    reference_type = 'SCHEDULE_ITEMS';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN null;
      WHEN OTHERS THEN raise;

    END;

    -- If there is no organization at the header level, we are
    -- building a multi-org schedule.
    IF (x_organization_id is NULL) THEN
      x_multi_org_flag := 'Y';
    ELSE
      x_multi_org_flag := 'N';
    END IF;

    x_progress := '080';

    chv_build_schedules.create_items('REBUILD',
                 'N',
                 x_schedule_type,
                 x_schedule_subtype,
                 p_schedule_id,
                 null,
                 null,
                 x_horizon_start_date,
                 null,
                 x_include_future_releases,
                 x_mrp_compile_designator,
                 x_mps_schedule_designator,
                 x_drp_compile_designator,
                 x_organization_id,
                 x_multi_org_flag,
                 x_vendor_id,
                 x_vendor_site_id,
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 x_user_id,
                 x_login_id,
		 x_horizon_end_date,
		 x_bucket_descriptor_table,
		 x_bucket_start_date_table,
		 x_bucket_end_date_table,
		 x_item_created,
		 null,
                 x_bucket_pattern_id,
		 x_schedule_subtype,
		 x_batch_id);

  END LOOP; -- end loop of fetching cursor

  CLOSE ITEMS;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE ITEMS;
    po_message_s.sql_error('rebuild_schedule', x_progress, sqlcode);
    RAISE;

END rebuild_item;

END CHV_REBUILD_SCHEDULES;

/
