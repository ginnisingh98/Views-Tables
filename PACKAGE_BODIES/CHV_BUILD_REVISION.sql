--------------------------------------------------------
--  DDL for Package Body CHV_BUILD_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_BUILD_REVISION" as
/* $Header: CHVPRBRB.pls 115.0 99/07/17 01:29:39 porting ship $ */

/*======================= CHV_BUILD_REVISION=================================*/

/*=============================================================================

  PROCEDURE NAME:     create_schedule_revision

=============================================================================*/
PROCEDURE create_schedule_revision(
			 p_schedule_id		     in NUMBER,
		         p_owner_id                  in NUMBER,
	                 p_batch_id                  in NUMBER) IS

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
  x_horizon_end_date          DATE;
  x_schedule_num	      VARCHAR2(25);
  x_include_future_releases   VARCHAR2(1);
  x_schedule_id               NUMBER;
  x_schedule_revision         NUMBER;
  x_multi_org_flag            VARCHAR2(1);
  x_item_created	      VARCHAR2(1);

  -- Following variables whose values are calculated within the procedure.

  x_user_id                   NUMBER;
  x_login_id                  NUMBER;

  x_progress		      VARCHAR2(3);

  -- 3 PL/SQL tables used for calculating bucket quantities.
  x_bucket_descriptor_table   chv_create_buckets.bkttable;
  x_bucket_start_date_table   chv_create_buckets.bkttable;
  x_bucket_end_date_table     chv_create_buckets.bkttable;

  x_bucket_count              BINARY_INTEGER := 1; -- DEBUG need this?

  CURSOR C_REVISION IS
  SELECT
	 vendor_id,
	 vendor_site_id,
	 schedule_type,
	 schedule_subtype,
	 schedule_horizon_start,
	 schedule_horizon_end,
	 bucket_pattern_id,
	 schedule_num,
	 organization_id,
	 mps_schedule_designator,
	 mrp_compile_designator,
	 drp_compile_designator,
	 include_future_releases_flag
  FROM   chv_schedule_headers csh
  WHERE  schedule_id = p_schedule_id;

BEGIN

  --dbms_output.put_line('Entering create schedule revision');

  -- Get x_user_id and x_login_id from the global variable set.
  x_user_id  := NVL(fnd_global.user_id, 0);
  x_login_id := NVL(fnd_global.login_id, 0);

  x_progress := '010';

  OPEN C_REVISION;

  x_progress := '020';

  --dbms_output.put_line('Create_Schedule_Revision: fetch into');
  FETCH C_REVISION INTO
	 x_vendor_id,
	 x_vendor_site_id,
	 x_schedule_type,
	 x_schedule_subtype,
	 x_horizon_start_date,
	 x_horizon_end_date,
	 x_bucket_pattern_id,
	 x_schedule_num,
	 x_organization_id,
	 x_mps_schedule_designator,
	 x_mrp_compile_designator,
	 x_drp_compile_designator,
	 x_include_future_releases;

  x_progress := '030';

  -- Create 3 temp bucket tables (descriptor, start_date and end_date)
  --       and get x_horizon_end_date in the meantime
  --dbms_output.put_line('Create_Schedule_Revision: create_bucket_template');

  chv_create_buckets.create_bucket_template(x_horizon_start_date,
					    x_include_future_releases,
                                            x_bucket_pattern_id,
					    x_horizon_end_date,
                                            x_bucket_descriptor_table,
                                            x_bucket_start_date_table,
                                            x_bucket_end_date_table);

  --dbms_output.put_line('Build Schedules: end Date'||x_horizon_end_date);

  x_progress := '040';

  chv_build_schedules.get_schedule_number('REVISION',
                      x_vendor_id,
                      x_vendor_site_id,
                      x_schedule_num,
                      x_schedule_revision);

  -- Insert a new row into CHV_SCHEDULE_HEADERS.
  --       Before that, get a new unique schedule header ID.
  -- Any error will be caught at the exception at the end of the procedure.
  x_progress := '050';
  SELECT chv_schedule_headers_s.NEXTVAL
  INTO   x_schedule_id
  FROM   DUAL;

  x_progress := '060';
  INSERT INTO chv_schedule_headers(schedule_id,
                                     vendor_id,
                                     vendor_site_id,
                                     schedule_type,
                                     schedule_subtype,
                                     schedule_num,
                                     schedule_revision,
                                     schedule_horizon_start,
                                     schedule_horizon_end,
                                     bucket_pattern_id,
                                     schedule_owner_id,
                                     last_update_date,
                                     last_updated_by,
                                     creation_date,
                                     created_by,
                                     organization_id,
                                     mps_schedule_designator,
                                     mrp_compile_designator,
                                     drp_compile_designator,
                                     schedule_status,
                                     inquiry_flag,
                                     include_future_releases_flag,
                                     last_update_login,
				     batch_id)
  VALUES                          (x_schedule_id,
                                     x_vendor_id,
                                     x_vendor_site_id,
                                     x_schedule_type,
                                     x_schedule_subtype,
                                     x_schedule_num,
                                     x_schedule_revision,
                                     x_horizon_start_date,
                                     x_horizon_end_date,
                                     x_bucket_pattern_id,
				     p_owner_id,
                                     SYSDATE,            -- last_update_date
                                     x_user_id,          -- last_updated_by
                                     SYSDATE,            -- creation_date
                                     x_user_id,          -- created_by
                                     x_organization_id,
                                     x_mps_schedule_designator,
                                     x_mrp_compile_designator,
                                     x_drp_compile_designator,
                                     'IN_PROCESS',       -- schedule_status
                                     'N',   -- inquiry_flag
                                     x_include_future_releases,
                                     x_login_id,
				     p_batch_id);        -- last_update_login


  x_progress := '070';


  IF (x_organization_id > 0 ) THEN
    x_multi_org_flag := 'Y';
  ELSE
    x_multi_org_flag := 'N';
  END IF;


  chv_build_schedules.create_items('REVISION',
                 'N',
                 x_schedule_type,
                 x_schedule_subtype,
                 x_schedule_id,
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
	         p_schedule_id,
		 x_bucket_pattern_id,
		 x_schedule_subtype,
	         p_batch_id);

  x_progress := '090';

  CLOSE C_REVISION;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE C_REVISION;
    po_message_s.sql_error('create_schedule_revision', x_progress, sqlcode);
    RAISE;

END create_schedule_revision;

END CHV_BUILD_REVISION;

/
