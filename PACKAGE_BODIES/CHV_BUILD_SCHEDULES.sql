--------------------------------------------------------
--  DDL for Package Body CHV_BUILD_SCHEDULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_BUILD_SCHEDULES" as
/* $Header: CHVPRSBB.pls 120.2.12010000.7 2014/07/01 08:48:11 shikapoo ship $ */

/*======================= CHV_BUILD_SCHEDULES ===============================*/


/*=============================================================================

  PROCEDURE NAME:     build_schedule()

=============================================================================*/
PROCEDURE build_schedule(p_schedule_category         in VARCHAR2,
		         p_autoschedule_flag         in VARCHAR2,
		         p_schedule_type             in VARCHAR2,
		         p_schedule_subtype          in VARCHAR2 DEFAULT null,
		         p_schedule_num              in VARCHAR2 DEFAULT null,
		         p_schedule_revision         IN NUMBER   DEFAULT null,
		         p_horizon_start_date        in DATE,
		         p_bucket_pattern_id         in NUMBER   DEFAULT null,
		         p_multi_org_flag            in VARCHAR2 DEFAULT null,
		         p_ship_to_organization_id   in NUMBER   DEFAULT null,
		         p_mrp_compile_designator    in VARCHAR2 DEFAULT null,
		         p_mps_schedule_designator   in VARCHAR2 DEFAULT null,
		         p_drp_compile_designator    in VARCHAR2 DEFAULT null,
		         p_include_future_releases   in VARCHAR2 DEFAULT null,
		         p_autoconfirm_flag          in VARCHAR2 DEFAULT null,
	                 p_communication_code        in VARCHAR2 DEFAULT null,
		         p_vendor_id                 in NUMBER   DEFAULT null,
		         p_vendor_site_id            in NUMBER   DEFAULT null,
		         p_category_set_id           in NUMBER   DEFAULT null,
			 p_struct_num	             in NUMBER   DEFAULT null,
			 p_yes_no		     in VARCHAR2 DEFAULT null,
		         p_category_id               in NUMBER   DEFAULT null,
			 p_item_org		     in NUMBER   DEFAULT null,
		         p_item_id                   in NUMBER   DEFAULT null,
		         p_scheduler_id              in NUMBER   DEFAULT null,
		         p_buyer_id                  in NUMBER   DEFAULT null,
		         p_planner_code              in VARCHAR2 DEFAULT null,
			 p_owner_id                  in NUMBER   DEFAULT null,
			 p_batch_id		     in NUMBER DEFAULT null,
                         p_exclude_zero_quantity_lines in VARCHAR2 DEFAULT null) IS

  x_progress                  VARCHAR2(3) := NULL; -- For debugging purpose

  x_distinct_v_vs_org_id      VARCHAR2(240); -- Distinct concatenation of 3 ids
                                            -- (for the first parameter in the
                                            -- cursor, no real use of it).

  -- Following variables whose values should be retrieved from cursors.
  x_vendor_id                 NUMBER;
  x_vendor_site_id            NUMBER;
  x_organization_id           NUMBER;
  /* Bug# 2933042 - Increased the size of x_organization_name from 60
     to 240 to make it UTF8 compliant */
  x_organization_name         VARCHAR2(240);

/* Bug#2823839 Increased the width of the x_vendor_name by replacing
** VARCHAR2(80) with po_vendors.vendor_name type(which is 240) */

  x_vendor_name               po_vendors.vendor_name%type;
  x_vendor_code               VARCHAR2(15);
  x_item_desc                 VARCHAR2(240);
  x_bucket_pattern_id         NUMBER;
  x_mrp_compile_designator    VARCHAR2(10);
  x_mps_schedule_designator   VARCHAR2(10);
  x_drp_compile_designator    VARCHAR2(10);
  x_schedule_subtype          VARCHAR2(25);
  x_schedule_type	      VARCHAR2(25);
  x_schedule_horizon_start    DATE;
  x_include_future_releases_flag VARCHAR2(1);

  -- Following variables whose values are calculated within the procedure.
  x_dummy		      VARCHAR2(1);
  x_dummy_num1		      NUMBER;
  x_dummy_num2		      NUMBER;
  x_schedule_id               NUMBER;
  x_schedule_num              VARCHAR2(20);
  x_schedule_revision         NUMBER;
  x_user_id                   NUMBER;
  x_login_id                  NUMBER;
  x_horizon_end_date          DATE;
  x_confirmed_schedule        VARCHAR2(1)  := '';
  x_transmission_method       VARCHAR2(1) := 'N';
  x_item_created              VARCHAR2(1)  := 'N'; -- Indicates if atleast
						   -- one item is created
						   -- for a schedule header.

  x_old_schedule_id           NUMBER;
  x_do_not_send_edi           VARCHAR2(1) := 'N';

  x_confirm_source	      VARCHAR2(15);
  x_return_number             NUMBER;
  x_ece_path		      VARCHAR2(80);
  x_ece_file		      VARCHAR2(30);
  x_ece_path_file	      VARCHAR2(120);
  x_edi_set		      VARCHAR2(1) := 'N';

  x_str                       VARCHAR2(480);
  x_org_id 		      NUMBER;  /* Bug 2616988 fixed. added x_org_id */

  -- 3 PL/SQL tables used for calculating bucket quantities.
  x_bucket_descriptor_table   chv_create_buckets.bkttable;
  x_bucket_start_date_table   chv_create_buckets.bkttable;
  x_bucket_end_date_table     chv_create_buckets.bkttable;

  -- The MRP, MPS, or DRP Designator will optionally be passed in.
  --   From the WB we will default the designator into the fields
  --   from the org options.  The user has the option to change
  --   the value of the fields in the form.
  CURSOR C_ORGS IS
  SELECT coo.organization_id,
         p_mrp_compile_designator,
         p_mps_schedule_designator,
         p_drp_compile_designator
  FROM   chv_org_options coo
  WHERE  nvl(p_ship_to_organization_id,
		coo.organization_id) = coo.organization_id;

  -- When we a running in a non-multi-org situation we are going
  -- to look through all of the orgs and create schedule headers
  -- for the first organization and then create schedule headers
  -- for the next organization.  When we are running in a multi-org
  -- situation we are going to create a schedule header and then
  -- for each schedule header create a schedule item for each
  -- organization.  We need to have a dummy cursor for this.
  CURSOR C_NOORGS IS
  SELECT dummy,
	 p_mrp_compile_designator,
	 p_mps_schedule_designator,
	 p_drp_compile_designator
  FROM   dual;

  -- For all schedules, we will create a new schedule header for each
  -- 	vendor, vendor site, bucket pattern, schedule type,
  --	schedule sub type, and org combination.
  -- The schedule subtype and bucket pattern will always be provided
  --    from the workbench.  We will not use the values from the asl.
  -- We must have the sub-query to return one record in the situation
  --	where we have a global record and a local record.
  CURSOR C_SINGLE_ORG_WB_BPM IS
  SELECT DISTINCT(paa.vendor_id||paa.vendor_site_id),
         p_bucket_pattern_id,
         paa.vendor_id,
         paa.vendor_site_id,
	 p_schedule_subtype
  FROM   po_asl_attributes_val_v paa
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
         or
         (using_organization_id = x_organization_id))
  AND    paa.vendor_id       = NVL(p_vendor_id, paa.vendor_id)
  AND    paa.vendor_site_id  = NVL(p_vendor_site_id, paa.vendor_site_id)
  AND    nvl(p_item_id, paa.item_id) = paa.item_id
  AND    (p_category_set_id is null
          OR
	  paa.item_id in (
          	select mic.inventory_item_id
		from   mtl_item_categories mic
		where  mic.category_set_id = p_category_set_id
		and    mic.organization_id = x_organization_id
		and    nvl(p_category_id,mic.category_id) = mic.category_id))
  AND    nvl(paa.enable_autoschedule_flag,'N') = 'N'
  AND   ((p_schedule_type = 'PLAN_SCHEDULE'
          AND paa.enable_plan_schedule_flag = 'Y')
         OR
         (p_schedule_type = 'SHIP_SCHEDULE'
          AND paa.enable_ship_schedule_flag = 'Y'))
  AND   nvl(paa.scheduler_id,-1) =
		NVL(p_scheduler_id, nvl(paa.scheduler_id,-1))
  AND   (p_planner_code IS NULL
         OR
         EXISTS (SELECT 'check if planner exists in mtl_system_items'
                 FROM   mtl_system_items msi,mtl_planners mtp
                 WHERE  msi.planner_code      = p_planner_code
                 AND    msi.organization_id = x_organization_id
                 AND    mtp.organization_id = x_organization_id
                 AND    mtp.planner_code      = p_planner_code
                 AND    msi.inventory_item_id = paa.item_id))
  AND   (p_buyer_id IS NULL
         OR
         EXISTS (SELECT 'check if buyer exists in mtl_system_items'
                 FROM   mtl_system_items msi
                 WHERE  msi.inventory_item_id = paa.item_id
                 AND    msi.organization_id   = x_organization_id
                 AND    msi.buyer_id          = p_buyer_id));

  -- This statement will be run by AutoSchedule.  The bucket pattern
  -- 	and schedule subtype will always be used from the ASL.
  CURSOR C_SINGLE_ORG_WB_BP_NOTPROV IS
  SELECT DISTINCT(paa.vendor_id||paa.vendor_site_id||decode(p_schedule_type,
			'PLAN_SCHEDULE',paa.plan_bucket_pattern_id,
			paa.ship_bucket_pattern_id)||decode(p_schedule_type,
			'PLAN_SCHEDULE',paa.plan_schedule_type,
			paa.ship_schedule_type)),
         decode(p_schedule_type,'PLAN_SCHEDULE',paa.plan_bucket_pattern_id,
		paa.ship_bucket_pattern_id),
         paa.vendor_id,
         paa.vendor_site_id,
	 decode(p_schedule_type, 'PLAN_SCHEDULE', paa.plan_schedule_type,
		paa.ship_schedule_type)
  FROM   po_asl_attributes_val_v paa,
	 chv_bucket_patterns cbp,
	 po_vendor_sites_all povs
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
         or
         (using_organization_id = x_organization_id))
  AND    paa.vendor_id       = NVL(p_vendor_id, paa.vendor_id)
  AND    paa.vendor_site_id  = NVL(p_vendor_site_id, paa.vendor_site_id)
  AND    nvl(p_item_id, paa.item_id) = paa.item_id
/* Bug 2616988 fixed. added the below three statements so that only those
   data pertaining to current operating unit will be picked up.
*/
  AND    povs.vendor_site_id = paa.vendor_site_id
  AND    povs.vendor_id = paa.vendor_id
  AND    povs.org_id = x_org_id
  AND    (p_category_set_id is null
          OR
	  paa.item_id in (
          	select mic.inventory_item_id
		from   mtl_item_categories mic
		where  mic.category_set_id = p_category_set_id
		and    mic.organization_id = x_organization_id
		and    nvl(p_category_id,mic.category_id) = mic.category_id))
  AND    nvl(paa.enable_autoschedule_flag, 'N') = 'Y'
  AND   ((p_schedule_type = 'PLAN_SCHEDULE'
          AND paa.enable_plan_schedule_flag = 'Y')
         OR
         (p_schedule_type = 'SHIP_SCHEDULE'
          AND paa.enable_ship_schedule_flag = 'Y'))
  AND   ((p_schedule_type = 'PLAN_SCHEDULE'
	  AND paa.plan_bucket_pattern_id = cbp.bucket_pattern_id
	  AND nvl(cbp.inactive_date, sysdate) < sysdate + 1)
	 OR
	 (p_schedule_type = 'SHIP_SCHEDULE'
	  AND paa.ship_bucket_pattern_id = cbp.bucket_pattern_id
	  AND nvl(cbp.inactive_date, sysdate) < sysdate + 1))
  AND   nvl(paa.scheduler_id,-1) =
		NVL(p_scheduler_id, nvl(paa.scheduler_id,-1))
  AND   (p_planner_code IS NULL
         OR
         EXISTS (SELECT 'check if planner exists in mtl_system_items'
                 FROM   mtl_system_items msi,mtl_planners mtp
                 WHERE  msi.planner_code     = p_planner_code
                 AND    msi.inventory_item_id = paa.item_id
                 AND    mtp.organization_id = x_organization_id
                 AND    mtp.planner_code      = p_planner_code
                 AND    msi.organization_id = x_organization_id))
  AND   (p_buyer_id IS NULL
         OR
         EXISTS (SELECT 'check if buyer exists in mtl_system_items'
                 FROM   mtl_system_items msi
                 WHERE  msi.inventory_item_id = paa.item_id
                 AND    msi.organization_id   = x_organization_id
                 AND    msi.buyer_id          = p_buyer_id));

  -- These cursors will be used only if Autoschedule fails and we need to find the reason
  -- why it failed.

  CURSOR C_CHECK_ORG IS
  SELECT paa.vendor_id,
         paa.vendor_site_id
  FROM   po_asl_attributes_val_v paa
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
         or
         (using_organization_id = x_organization_id));

  CURSOR C_CHECK_V_VS IS
  SELECT paa.vendor_id,
         paa.vendor_site_id
  FROM   po_asl_attributes_val_v paa
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
         or
         (using_organization_id = x_organization_id))
  AND    paa.vendor_id       = NVL(p_vendor_id,paa.vendor_id)
  AND    paa.vendor_site_id  = NVL(p_vendor_site_id,paa.vendor_site_id);

  CURSOR C_CHECK_V_VS_ITEM IS
  SELECT paa.vendor_id,
         paa.vendor_site_id
  FROM   po_asl_attributes_val_v paa
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
         or
         (using_organization_id = x_organization_id))
  AND    paa.vendor_id       = NVL(p_vendor_id,paa.vendor_id)
  AND    paa.vendor_site_id  = NVL(p_vendor_site_id,paa.vendor_site_id)
  AND    paa.item_id = NVL(p_item_id,paa.item_id);


  CURSOR C_CHECK_V_VS_AS_FLAG IS
  SELECT paa.vendor_id,
         paa.vendor_site_id
  FROM   po_asl_attributes_val_v paa
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
         or
         (using_organization_id = x_organization_id))
  AND    paa.vendor_id       = NVL(p_vendor_id,paa.vendor_id)
  AND    paa.vendor_site_id  = NVL(p_vendor_site_id, paa.vendor_site_id)
  AND    paa.item_id = NVL(p_item_id,paa.item_id)
  AND   ((p_schedule_type = 'PLAN_SCHEDULE'
          AND paa.enable_plan_schedule_flag = 'Y')
         OR
         (p_schedule_type = 'SHIP_SCHEDULE'
          AND paa.enable_ship_schedule_flag = 'Y'))
  AND    paa.enable_autoschedule_flag = 'Y';

  CURSOR C_CHECK_V_VS_ST_FLAG IS
  SELECT paa.vendor_id,
         paa.vendor_site_id
  FROM   po_asl_attributes_val_v paa
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
         or
         (using_organization_id = x_organization_id))
  AND    paa.vendor_id       = NVL(p_vendor_id, paa.vendor_id)
  AND    paa.vendor_site_id  = NVL(p_vendor_site_id,paa.vendor_site_id)
  AND    paa.item_id = NVL(p_item_id,paa.item_id)
  AND   ((p_schedule_type = 'PLAN_SCHEDULE'
          AND paa.enable_plan_schedule_flag = 'Y')
         OR
         (p_schedule_type = 'SHIP_SCHEDULE'
          AND paa.enable_ship_schedule_flag = 'Y'));

  CURSOR C_CHECK_BP IS
  SELECT paa.vendor_id,
         paa.vendor_site_id
  FROM   po_asl_attributes_val_v paa,
         chv_bucket_patterns cbp
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
         or
         (using_organization_id = x_organization_id))
  AND    paa.vendor_id       = NVL(p_vendor_id,paa.vendor_id)
  AND    paa.vendor_site_id  = NVL(p_vendor_site_id,paa.vendor_site_id)
  AND    paa.item_id = NVL(p_item_id,paa.item_id)
  AND    paa.enable_autoschedule_flag = 'Y'
  AND   ((p_schedule_type = 'PLAN_SCHEDULE'
          AND paa.enable_plan_schedule_flag = 'Y')
         OR
         (p_schedule_type = 'SHIP_SCHEDULE'
          AND paa.enable_ship_schedule_flag = 'Y'))
  AND   ((p_schedule_type = 'PLAN_SCHEDULE'
          AND paa.plan_bucket_pattern_id = cbp.bucket_pattern_id
          AND nvl(cbp.inactive_date, sysdate) < sysdate + 1)
         OR
         (p_schedule_type = 'SHIP_SCHEDULE'
          AND paa.ship_bucket_pattern_id = cbp.bucket_pattern_id
          AND nvl(cbp.inactive_date, sysdate) < sysdate + 1));

BEGIN

---- dbms_output.put_line('Entering build_schedule');

-- Get x_user_id and x_login_id from the global variable set.
x_user_id  := NVL(fnd_global.user_id, 0);
x_login_id := NVL(fnd_global.login_id, 0);

/* Bug 2616988 fixed. added below sql statement to get current
   operating unit id.
*/

x_org_id := PO_MOAC_UTILS_PVT.get_current_org_id;  -- <R12 MOAC>

IF p_multi_org_flag = 'N' OR p_multi_org_flag is NULL THEN
  OPEN C_ORGS;
ELSE
  OPEN C_NOORGS;
END IF;

LOOP

  IF p_multi_org_flag = 'N' OR p_multi_org_flag is NULL THEN
    -- For each of the organizations, find the asl attributes record
    -- that matches.
    FETCH C_ORGS
    INTO  x_organization_id,
          x_mrp_compile_designator,
          x_mps_schedule_designator,
          x_drp_compile_designator;
    EXIT WHEN C_ORGS%NOTFOUND;

  ELSE

    x_organization_id := p_ship_to_organization_id;

    -- This will only find one record.
    FETCH C_NOORGS
    INTO  x_dummy,
          x_mrp_compile_designator,
          x_mps_schedule_designator,
          x_drp_compile_designator;
    EXIT WHEN C_NOORGS%NOTFOUND;

  END IF;

  ---- dbms_output.put_line('after organizations cursor'||x_organization_id);

  x_progress := '010';
  -- This cursor is executed from WB
  IF NVL(p_autoschedule_flag,'N')='N' THEN
    ---- dbms_output.put_line('Build Schedule: Before open WB - Single Org');
    OPEN C_SINGLE_ORG_WB_BPM;

  -- This cursor is executed from AutoSchedule
  ELSIF NVL(p_autoschedule_flag,'N')='Y' THEN
    ---- dbms_output.put_line('Build Schedule: Before open Auto - Single Org');
    OPEN C_SINGLE_ORG_WB_BP_NOTPROV;

  END IF; -- end of open cursor

  LOOP
    ---- dbms_output.put_line('Build_schedule: fetching cursor');

    -- Fetch one row at a time from the appropriate cursor opened above
    --       Exit the loop at the last row.
    x_progress := '020';
    IF NVL(p_autoschedule_flag,'N')='N' THEN

      ---- dbms_output.put_line('sched type'||p_schedule_type);
      ---- dbms_output.put_line('sched sub type'||p_schedule_subtype);
      ---- dbms_output.put_line('vendor'||p_vendor_id);
      ---- dbms_output.put_line('vendor site'||p_vendor_site_id);
      ---- dbms_output.put_line('bucket pattern'||p_bucket_pattern_id);
      ---- dbms_output.put_line('org'||x_organization_id);
      ---- dbms_output.put_line('buyer'||p_buyer_id);
      ---- dbms_output.put_line('planner'||p_planner_code);
      ---- dbms_output.put_line('scheduler'||p_scheduler_id);

      FETCH C_SINGLE_ORG_WB_BPM
      INTO  x_distinct_v_vs_org_id,
            x_bucket_pattern_id,
            x_vendor_id,
            x_vendor_site_id,
	    x_schedule_subtype;
      EXIT WHEN C_SINGLE_ORG_WB_BPM%NOTFOUND;

    ELSIF NVL(p_autoschedule_flag,'N')='Y' THEN

      ---- dbms_output.put_line('Single Org - AutoSchedule');
      ---- dbms_output.put_line('sched type'||p_schedule_type);
      ---- dbms_output.put_line('sched sub type'||p_schedule_subtype);
      ---- dbms_output.put_line('vendor'||p_vendor_id);
      ---- dbms_output.put_line('vendor site'||p_vendor_site_id);
      ---- dbms_output.put_line('bucket pattern'||p_bucket_pattern_id);
      ---- dbms_output.put_line('org'||x_organization_id);
      ---- dbms_output.put_line('buyer'||p_buyer_id);
      ---- dbms_output.put_line('planner'||p_planner_code);
      ---- dbms_output.put_line('scheduler'||p_scheduler_id);

      FETCH C_SINGLE_ORG_WB_BP_NOTPROV
      INTO  x_distinct_v_vs_org_id,
            x_bucket_pattern_id,
            x_vendor_id,
            x_vendor_site_id,
	    x_schedule_subtype;
      EXIT WHEN C_SINGLE_ORG_WB_BP_NOTPROV%NOTFOUND;

    END IF; -- end of fetch cursor

    ---- dbms_output.put_line('after asl header fetch'||x_vendor_id);

    -- If schedule category is not INQUIRY (NEW or REVISION),
    --        then get x_schedule_num and x_schedule_revision.
    -- Exception handler within get_schedule_number should take care of any
    --        error and failure in calculating the number and revision.
    x_progress := '030';
    IF (p_schedule_category <> 'SIMULATION') THEN
      ---- dbms_output.put_line('Build_schedule: get_schedule_number');

      x_schedule_num := p_schedule_num;
      get_schedule_number(p_schedule_category,
                          x_vendor_id,
                          x_vendor_site_id,
                          x_schedule_num,
                          x_schedule_revision);

      ---- dbms_output.put_line('Schedule Number = '||x_schedule_num);
      ---- dbms_output.put_line('Schedule Revision = '||x_schedule_revision);

    END IF;

    -- Create 3 temp bucket tables (descriptor, start_date and end_date)
    --       and get x_horizon_end_date in the meantime.
    ---- dbms_output.put_line('Build_schedule: create_bucket_template');

    x_progress := '040';

    chv_create_buckets.create_bucket_template(p_horizon_start_date,
					       p_include_future_releases,
                                               x_bucket_pattern_id,
					       x_horizon_end_date,
                                               x_bucket_descriptor_table,
                                               x_bucket_start_date_table,
                                               x_bucket_end_date_table);

    ---- dbms_output.put_line('Build Schedules: end Date'||to_char(x_horizon_end_date,'DD-MON-YYYY'));

    -- Insert a new row into CHV_SCHEDULE_HEADERS.
    --       Before that, get a new unique schedule header ID.
    -- Any error will be caught at the exception at the end of the procedure.
    x_progress := '050';
    SELECT chv_schedule_headers_s.NEXTVAL
    INTO   x_schedule_id
    FROM   DUAL;

    ---- dbms_output.put_line('Schedule Header id'||x_schedule_id);

    ---- dbms_output.put_line('Build_schedule: insert into chv_schedule_headers');

    ---- dbms_output.put_line('Build_schedule: schedule id'||x_schedule_id);
    ---- dbms_output.put_line('Build_schedule: vendor id'||x_vendor_id);
    ---- dbms_output.put_line('Build_schedule: site id'||x_vendor_site_id);
    ---- dbms_output.put_line('Build_schedule: batch id'||p_batch_id);
    ---- dbms_output.put_line('Build_schedule: schedule type'||p_schedule_type);
    ---- dbms_output.put_line('Build_schedule: subtype'||x_schedule_subtype);
    ---- dbms_output.put_line('Build_schedule: start'||p_horizon_start_date);
    ---- dbms_output.put_line('Build_schedule: end'||x_horizon_end_date);
    ---- dbms_output.put_line('Build_schedule: bucket id'||x_bucket_pattern_id);
    ---- dbms_output.put_line('Build_schedule: owner id'||p_owner_id);
    ---- dbms_output.put_line('Build_schedule: user id'||x_user_id);
    ---- dbms_output.put_line('Build_schedule: login id'||x_login_id);

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
                                     p_schedule_type,
                                     x_schedule_subtype,
                                     x_schedule_num,
                                     x_schedule_revision,
                                     p_horizon_start_date,
                                     x_horizon_end_date,
                                     x_bucket_pattern_id,
				     p_owner_id,
                                     SYSDATE,            -- last_update_date
                                     x_user_id,          -- last_updated_by
                                     SYSDATE,            -- creation_date
                                     x_user_id,          -- created_by
                                     DECODE(p_multi_org_flag, 'N',
					x_organization_id, '',
					x_organization_id, ''),
                                     x_mps_schedule_designator,
                                     x_mrp_compile_designator,
                                     x_drp_compile_designator,
                                     'IN_PROCESS',       -- schedule_status
                                     DECODE(p_schedule_category, 'SIMULATION',
                                            'Y', 'N'),   -- inquiry_flag
                                     p_include_future_releases,
                                     x_login_id, -- last_update_login
				     p_batch_id);

    -- Create schedule items for this new schedule.
    ---- dbms_output.put_line('Build_schedule: create_items');

    x_progress := '070';
    chv_build_schedules.create_items(p_schedule_category,
                 p_autoschedule_flag,
                 p_schedule_type,
                 x_schedule_subtype,
                 x_schedule_id,
                 x_schedule_num,
                 x_schedule_revision,
                 p_horizon_start_date,
                 x_bucket_pattern_id,
                 p_include_future_releases,
                 x_mrp_compile_designator,
                 x_mps_schedule_designator,
                 x_drp_compile_designator,
                 x_organization_id,
                 p_multi_org_flag,
                 x_vendor_id,
                 x_vendor_site_id,
                 p_category_set_id,
                 p_category_id,
                 p_item_id,
                 p_scheduler_id,
                 p_buyer_id,
                 p_planner_code,
                 x_user_id,
                 x_login_id,
		 x_horizon_end_date,
		 x_bucket_descriptor_table,
		 x_bucket_start_date_table,
		 x_bucket_end_date_table,
		 x_item_created,
	         x_old_schedule_id,
		 p_bucket_pattern_id,  -- used to determine if the
				       -- we must match the bucket pattern
   				       -- in the asl record or not in
				       -- items cursor
	         p_schedule_subtype,   -- used to determine if the
				       -- we must match the schedule subtype
   				       -- in the asl record or not in
				       -- items cursor
		 p_batch_id);

    -- If we did not find an item to create for the schedule header,
    -- we need to delete the schedule header.  We should never
    -- create a schedule header without any scheduled items.
    IF (x_item_created = 'N') THEN

      x_progress := '075';

      ---- dbms_output.put_line('deleteing the schedule header');

      DELETE from chv_schedule_headers
      where  schedule_id = x_schedule_id;

    ELSE

      -- Confirm schedule if it is autoschedule and autoconfirm is set to 'Y'.
      -- An inquiry schedule cannot be confirmed.
      x_progress := '080';
      IF p_autoschedule_flag = 'Y' AND p_autoconfirm_flag = 'Y' and
	 p_schedule_category <> 'SIMULATION' THEN
        ---- dbms_output.put_line('Build_schedule: confirm_schedules');

        chv_confirm_schedules.confirm_schedule_header(
                                              x_schedule_id,
					      p_schedule_type,
					      p_communication_code,
					      x_confirm_source,
					      x_confirmed_schedule);

      END IF;


      -- If the schedule is confirmed, we should check the method for
      -- communicating it to the supplier.
      IF (x_confirmed_schedule = 'Y' AND
	  p_autoschedule_flag = 'Y' AND
		(p_communication_code = 'BOTH' or
		 p_communication_code =  'EDI')) THEN

        x_progress := '090';

        -- Select the transmission method for the supplier and site from
        -- the edi tables.
        -- direction:  O - outbound; I - inbound
        BEGIN

	  SELECT edi_flag
	  INTO   x_transmission_method
          FROM   ece_tp_headers eth,
		 ece_tp_details etd,
		 po_vendor_sites pvs,
	         chv_schedule_headers csh
	  WHERE  eth.tp_header_id = etd.tp_header_id
	  AND    decode(csh.schedule_type, 'PLAN_SCHEDULE', 'SPSO', 'SSSO') =
			etd.document_id
	  AND    eth.tp_header_id = pvs.tp_header_id
	  AND    csh.vendor_site_id = pvs.vendor_site_id
          AND    csh.schedule_id = x_schedule_id;

/*
          SELECT transmission_method
          INTO   x_transmission_method
          FROM   ECE_CONTROL ECC,
  	         CHV_SCHEDULE_HEADERS CSH
          WHERE  CSH.schedule_id    = x_schedule_id
          AND    decode(CSH.schedule_type, 'PLAN_SCHEDULE', 'SPSO', 'SSSO')
			          = ECC.DOCUMENT_TYPE
          AND    CSH.vendor_id      = ECC.entity_id
          AND    CSH.vendor_site_id = ECC.entity_site_id
          AND    ECC.entity_type    = 'SUPPLIER'
          AND    ECC.direction      = 'O';

*/

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
		-- If the supplier is not setup for the edi transaction
		-- and they want to print and edi it both, set the
		-- communication code so they can just print it.
		null;

          WHEN OTHERS THEN raise;

        END;

      END IF; -- IF confirm = y

      x_progress := '100';


      --  You can print unconfirmed schedules, but you cannot send
      --  unconfirmed schedules via edi.
      --  For each header we will update the communication method.
      --  At the end of the program we will call the batch job
      --  to print/send via edi all the progrmas that indicate
      --  that they should be sent.
      IF (x_transmission_method = 'Y' AND
	  p_communication_code = 'EDI') THEN

	  UPDATE chv_schedule_headers
          SET    communication_code = 'EDI'
          WHERE  schedule_id = x_schedule_id;

	  x_edi_set := 'Y';

      ELSIF (x_transmission_method = 'Y' AND
	     p_communication_code = 'BOTH' ) THEN

	  UPDATE chv_schedule_headers
          SET    communication_code = 'BOTH'
          WHERE  schedule_id = x_schedule_id;

          x_edi_set := 'Y';

      ELSIF ((x_transmission_method <> 'Y' AND
	      p_communication_code = 'BOTH') OR
	     (p_communication_code = 'PRINT')) THEN

	  UPDATE chv_schedule_headers
          SET    communication_code = 'PRINT'
          WHERE  schedule_id = x_schedule_id;

      END IF;

    END IF; -- If item_created = N
  /* Bug 2775001 fixed. reinitialized the variable x_item_created to 'N'
     for the next record fetched to create headers and corresponding
     chv items.
  */
      x_item_created := 'N' ;
  END LOOP; -- end loop of asl fetching cursor

           ---- dbms_output.put_line('Finding reason of autoschedule failure');
  --  Find the reason why the autoschedule did not build
  IF NVL(P_autoschedule_flag,'N') = 'Y' THEN
  IF (C_SINGLE_ORG_WB_BP_NOTPROV%ROWCOUNT = 0 ) THEN
      fnd_message.set_name('CHV','CHV_AUTOSCHEDULE_FAILED');
      x_str := fnd_message.get;
      ----  dbms_output.put_line(x_str);
      x_str := null;
      IF p_planner_code IS NOT NULL THEN
          BEGIN
           SELECT 'Y' INTO x_dummy
                   FROM   mtl_planners mpl
                   WHERE  mpl.planner_code      = p_planner_code
                   AND    mpl.organization_id = x_organization_id
                   AND    nvl(mpl.disable_date,sysdate +1 ) > sysdate;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('CHV','CHV_PLANNER_NOT_ACTIVE');
             x_str := fnd_message.get;
             ----  dbms_output.put_line(x_str);
             x_str := null;
          END;
      END IF;

      IF  p_buyer_id IS NOT NULL THEN
           BEGIN
           SELECT 'Y' INTO x_dummy
                   FROM   mtl_system_items msi
                   WHERE  msi.inventory_item_id = p_item_id
                   AND    msi.organization_id   = x_organization_id
                   AND    msi.buyer_id          = p_buyer_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('CHV','CHV_BUYER_NOT_ACTIVE');
             x_str := fnd_message.get;
             ----  dbms_output.put_line(x_str);
             x_str := null;
          END;
      END IF;

      SELECT organization_name INTO x_organization_name from org_organization_definitions
      where organization_id = x_organization_id;

      IF p_vendor_id is not null THEN
          SELECT vendor_name into x_vendor_name from po_vendors where p_vendor_id = vendor_id;
      ELSE
         x_vendor_name := 'No Vendor Provided';
      END IF;

      IF p_vendor_site_id is not null THEN
          SELECT vendor_site_code into x_vendor_code from po_vendor_sites where p_vendor_site_id = vendor_site_id and p_vendor_id = vendor_id;
      ELSE
         x_vendor_code := 'No Vendor Site';
      END IF;

      IF p_item_id is not null THEN
          SELECT description into x_item_desc from mtl_system_items where p_item_id = inventory_item_id  and organization_id = x_organization_id;
      ELSE
         x_item_desc := 'No Item Provided ';
      END IF;

      -- Check if ASL set for ORG

      OPEN C_CHECK_ORG;
      LOOP
      FETCH C_CHECK_ORG INTO
            x_dummy_num1,
            x_dummy_num2;
      EXIT WHEN (C_CHECK_ORG%NOTFOUND OR  C_CHECK_ORG%ROWCOUNT > 1);
      END LOOP;
      IF C_CHECK_ORG%ROWCOUNT = 0 THEN
           fnd_message.set_name('CHV','CHV_NO_ASL_FOR_ORG');
           FND_MESSAGE.SET_TOKEN('ORG',x_organization_name);
           x_str := fnd_message.get;
           ----  dbms_output.put_line(x_str);
           x_str := null;
      END IF;
      CLOSE C_CHECK_ORG;

      -- Check if ASL set for Vendor/Vendor Site

      OPEN C_CHECK_V_VS;
      LOOP
          FETCH C_CHECK_V_VS INTO
                x_dummy_num1,
                x_dummy_num2;
          EXIT WHEN (C_CHECK_V_VS%NOTFOUND OR  C_CHECK_V_VS%ROWCOUNT > 1);
      END LOOP;
      IF C_CHECK_V_VS%ROWCOUNT = 0 THEN
           fnd_message.set_name('CHV','CHV_NO_ASL_FOR_SUPPLIER');
           FND_MESSAGE.SET_TOKEN('VENDOR',x_vendor_name);
           FND_MESSAGE.SET_TOKEN('VENDORSITE',x_vendor_code);
           x_str := fnd_message.get;
           ----  dbms_output.put_line(x_str);
      END IF;
      CLOSE C_CHECK_V_VS;

      -- Check if Vendor Vendor Site Item has ASL entry

      OPEN C_CHECK_V_VS_ITEM;
      LOOP
          FETCH C_CHECK_V_VS_ITEM INTO
                x_dummy_num1,
                x_dummy_num2;
          EXIT WHEN (C_CHECK_V_VS_ITEM%NOTFOUND OR  C_CHECK_V_VS_ITEM%ROWCOUNT > 1);
      END LOOP;
      IF C_CHECK_V_VS_ITEM%ROWCOUNT = 0 THEN
           fnd_message.set_name('CHV','CHV_NO_ASL_FOR_ITEM');
           FND_MESSAGE.SET_TOKEN('ITEM',x_item_desc);
           x_str := fnd_message.get;
           ----  dbms_output.put_line(x_str);
      END IF;
      CLOSE C_CHECK_V_VS_ITEM;

      -- Check if Enable Planning/Shipping Flag is set

      OPEN C_CHECK_V_VS_ST_FLAG;
      LOOP
          FETCH C_CHECK_V_VS_ST_FLAG INTO
                x_dummy_num1,
                x_dummy_num2;
          EXIT WHEN (C_CHECK_V_VS_ST_FLAG%NOTFOUND OR  C_CHECK_V_VS_ST_FLAG%ROWCOUNT > 1);
      END LOOP;
      IF C_CHECK_V_VS_ST_FLAG%ROWCOUNT = 0 THEN
           IF p_schedule_type = 'PLAN_SCHEDULE' THEN
               fnd_message.set_name('CHV','CHV_NO_PLANNING_FLAG');
               FND_MESSAGE.SET_TOKEN('ITEM',x_item_desc);
               x_str := fnd_message.get;
               ----  dbms_output.put_line(x_str);
           ELSE
               fnd_message.set_name('CHV','CHV_NO_SHIPPING_FLAG');
               FND_MESSAGE.SET_TOKEN('ITEM',x_item_desc);
               x_str := fnd_message.get;
               ----  dbms_output.put_line(x_str);
           END IF;
      END IF;
      CLOSE C_CHECK_V_VS_ST_FLAG;

      -- Check if Autoschedule Flag is Set

      OPEN C_CHECK_V_VS_AS_FLAG;
      LOOP
          FETCH C_CHECK_V_VS_AS_FLAG INTO
                x_dummy_num1,
                x_dummy_num2;
          EXIT WHEN (C_CHECK_V_VS_AS_FLAG%NOTFOUND OR  C_CHECK_V_VS_AS_FLAG%ROWCOUNT > 1);
      END LOOP;
      IF C_CHECK_V_VS_AS_FLAG%ROWCOUNT = 0 THEN
           fnd_message.set_name('CHV','CHV_AUTOSCHED_FLAG_NOT_SET');
           FND_MESSAGE.SET_TOKEN('ITEM',x_item_desc);
           x_str := fnd_message.get;
           ----  dbms_output.put_line(x_str);
      ELSE
         -- Check if Bucket Pattern Active

         OPEN C_CHECK_BP;
         LOOP
             FETCH C_CHECK_BP INTO
                   x_dummy_num1,
                   x_dummy_num2;
             EXIT WHEN (C_CHECK_BP%NOTFOUND OR  C_CHECK_BP%ROWCOUNT > 1);
         END LOOP;
         IF C_CHECK_BP%ROWCOUNT = 0 THEN
           fnd_message.set_name('CHV','CHV_BUCKET_PATTERN_DISABLED');
           FND_MESSAGE.SET_TOKEN('ITEM',x_item_desc);
           x_str := fnd_message.get;
           ----  dbms_output.put_line(x_str);
         END IF;
         CLOSE C_CHECK_BP;
      END IF;
      CLOSE C_CHECK_V_VS_AS_FLAG;

  END IF;
  END IF;

  IF NVL(p_autoschedule_flag,'N')='N' THEN
    CLOSE C_SINGLE_ORG_WB_BPM;

  ELSIF NVL(p_autoschedule_flag,'N')='Y' THEN
    CLOSE C_SINGLE_ORG_WB_BP_NOTPROV;

  END IF;

END LOOP; -- end of orgs fetching cursor

IF (p_communication_code = 'BOTH' or
    p_communication_code = 'PRINT')
   THEN
  /* 5075549 fixed. set the org context */
  fnd_request.set_org_id(x_org_id);
  IF p_schedule_type = 'PLAN_SCHEDULE' THEN

  ----  dbms_output.put_line('try to print planning schedule');
  x_return_number := FND_REQUEST.submit_request('PO',
                'CHVPRSCH',
                null,
                null,
                false,
                NULL, -- schedule_num
                NULL, -- schedule_rev
                'PLAN_SCHEDULE', -- schedule_type
                NULL, -- schedule sub type
                NULL, -- horizon start
                NULL, -- horizon end
                NULL, -- vendor name from
                NULL, -- vendor name to
                NULL, -- vendor site
                NULL, -- test print
                NULL, -- organization
                NULL, -- qyt precision
                p_autoschedule_flag, -- autoschedule flag
                p_batch_id, -- batch id
                p_exclude_zero_quantity_lines, -- exclude zero quantity lines
                NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  ----  dbms_output.put_line('request_id'||x_return_number);

  ELSE /* Submit the Shipping Schedule */

  ----  dbms_output.put_line('try to print shipping schedule');
  x_return_number := FND_REQUEST.submit_request('PO',
                'CHVSHSCH',
                null,
                null,
                false,
                NULL, -- schedule_num
                NULL, -- schedule_rev
                'SHIP_SCHEDULE', -- schedule_type
                NULL, -- schedule sub type
                NULL, -- horizon start
                NULL, -- horizon end
                NULL, -- vendor name from
                NULL, -- vendor name to
                NULL, -- vendor site
                NULL, -- test print
                NULL, -- organization
                NULL, -- qty precision
                p_autoschedule_flag, -- autoschedule flag
                p_batch_id, -- batch id
                p_exclude_zero_quantity_lines, -- exclude zero quantity lines
                NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

     ----  dbms_output.put_line('request_id'||x_return_number);

  END IF;
END IF;

-- Call the edi program to edi all schedule headers that have a
-- communication method of EDI or BOTH.
IF (x_edi_set = 'Y') THEN

  ---- dbms_output.put_line('try to send via edi');

  fnd_profile.get('ECE_OUT_FILE_PATH',x_ece_path);

  IF p_schedule_type = 'PLAN_SCHEDULE' THEN

      select 'SPSO' || lpad(substr(to_char(ECE_OUTPUT_RUNS_S.nextval),
    	 decode(length(ECE_OUTPUT_RUNS_S.nextval),1,-1,2, -2,3, -3,-4),
        	  4), 4, '0') || '.dat'
      into   x_ece_file
      from   dual;

      select x_ece_path || x_ece_file
      into   x_ece_path_file
      from   dual;

/*Bug 1701675:When lauching ECSPSO/ECSSSO transactions,a extra parameter called
            x_ece_path_file is passed to ECSPSO/ECSSSO concurrent program.
            This parameter is not in ECSPSO/ECSSSO concurrent program.Hence
            removing this parameter  from call to the concurrent program
            'fnd_request.submit_request'.Also adding a parameter debug_mode to
            the call to concurrent program.*/
    /* Bug 1955282:Changed the 10th parameter in the call below from
                   null to chr(0) */

/* Bug 2090899: Passing Batch Id also as one of the parameter as requested
   by EDI Team.
*/

/* Bug2576335 fixed. Changed the debug mode from '3' to '0' */

      x_return_number := FND_REQUEST.submit_request('EC',
		'ECSPSO',
		null,
		null,
		false,
		x_ece_path, -- file path
		x_ece_file, -- file name
--Bug 1701675   x_ece_path_file, -- file path  name
		0, -- schedule_id
 /*              3, --Bug 1701675:Debug Mode   Bug2576335.old*/
	        0,  /* Bug2576335.new */
                p_batch_id, -- Bug 2090899.
		chr(0),-- bug 1955282
		NULL,
		NULL,
		NULL,
                NULL,
		NULL,
		NULL,
		NULL,
		NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  ELSE

      select 'SSSO' || lpad(substr(to_char(ECE_OUTPUT_RUNS_S.nextval),
             decode(length(ECE_OUTPUT_RUNS_S.nextval),1,-1,2, -2,3, -3,-4),
              4), 4, '0') || '.dat'
      into   x_ece_file
      from   dual;

      select x_ece_path || x_ece_file
      into   x_ece_path_file
      from   dual;

/* Bug 2090899: Passing Batch Id also as one of the parameter as requested
   by EDI Team.
*/

      x_return_number := FND_REQUEST.submit_request('EC',
		'ECSSSO',
		null,
		null,
		false,
		x_ece_path, -- file path
		x_ece_file, -- file name
--Bug 1701675   x_ece_path_file, -- file path  name
		0, -- schedule_id
                3, --Bug 1701675:Debug Mode
                p_batch_id, -- Bug 2090899.
		chr(0),  -- bug 1955282
		NULL,
		NULL,
		NULL,
                NULL,
		NULL,
		NULL,
		NULL,
		NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  END IF;
END IF;


---- dbms_output.put_line('Build_schedule: closing cursor');

-- Close the appropriate cursor according to p_multi_org_flag and
--         p_autoschedule_flag.
  x_progress := '110';

  IF p_multi_org_flag = 'N' OR p_multi_org_flag is NULL THEN
    CLOSE C_ORGS;
  ELSE
    CLOSE C_NOORGS;
  END IF;


  ---- dbms_output.put_line('Exiting build_schedule');

EXCEPTION
  WHEN OTHERS THEN
    ----  dbms_output.put_line('sqlca'||sqlcode);
    po_message_s.sql_error('build_schedule', x_progress, sqlcode);
    RAISE;

END build_schedule;


/*=============================================================================

  PROCEDURE NAME:     get_schedule_number()

=============================================================================*/
PROCEDURE get_schedule_number(p_schedule_category         in     VARCHAR2,
		              x_vendor_id                 in     NUMBER,
		              x_vendor_site_id            in     NUMBER,
		              x_schedule_num              in out NOCOPY VARCHAR2,
		              x_schedule_revision         out NOCOPY    NUMBER) IS

  x_progress     VARCHAR2(3) := NULL;
  x_count_l    NUMBER      := 0;

BEGIN

  /* DEBUG Pri B.It is possible that we are going to get duplicate
	schedule numbers in this case.  What if we are doing
	two schedule builds at the same time?  Sent email to
	Sri.  We need to solve this one. */

  -- All schedule numbers must be unique within a vendor/venodr site.
  -- Schedule numbers are based on sysdate concatenated with a hyphen and a
  -- 	unique sequence as follows: YYYYMMDD-n.  Where (n) is the schedule
  -- 	number being created for the vendor/site on a certain day.
  -- Also assign revision.  Revisions for a new schedule is always 0.
  --	All subsequent revisions are incremented by 1 for the vendor/site.
  -- No schedule numbers will be generated for inquiry schedules.

  IF p_schedule_category = 'NEW' THEN
    ---- dbms_output.put_line('Get_schedule_number: get for NEW schedule');

    -- Select the next largest number to be used for the next schedule
    --       generated today; Set the revision to 0 for a new schedule.
    x_progress := '010';

    SELECT chv_schedule_headers_s2.NEXTVAL
    INTO   x_count_l
    FROM   DUAL;

    x_schedule_num := TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' ||
                         TO_CHAR(x_count_l);
    x_schedule_revision := 0;

  ELSIF p_schedule_category = 'REVISION' THEN
    ---- dbms_output.put_line('Get_schedule_number: get for REVISION schedule');

    -- Select the next largest revision number for a given schedule;
    x_progress := '020';
    SELECT NVL(MAX(schedule_revision),0) + 1
    INTO   x_count_l
    FROM   chv_schedule_headers
    WHERE  schedule_num = x_schedule_num;

    x_schedule_revision := x_count_l;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_schedule_number', x_progress, sqlcode);
    RAISE;

END get_schedule_number;


/*=============================================================================

  PROCEDURE NAME:     create_items()

=============================================================================*/
PROCEDURE create_items  (p_schedule_category         in VARCHAR2,
		         p_autoschedule_flag         in VARCHAR2,
		         p_schedule_type             in VARCHAR2,
		         x_schedule_subtype          in VARCHAR2,
		         x_schedule_id               in NUMBER,
		         x_schedule_num              in VARCHAR2,
                         x_schedule_revision         in NUMBER,
		         p_horizon_start_date        in DATE,
		         x_bucket_pattern_id         in NUMBER,
		         p_include_future_releases   in VARCHAR2,
		         x_mrp_compile_designator    in VARCHAR2,
		         x_mps_schedule_designator   in VARCHAR2,
		         x_drp_compile_designator    in VARCHAR2,
		         x_organization_id_l         in NUMBER,
		         p_multi_org_flag            in VARCHAR2,
		         x_vendor_id                 in NUMBER,
		         x_vendor_site_id            in NUMBER,
		         p_category_set_id           in NUMBER,
		         p_category_id               in NUMBER,
		         p_item_id                   in NUMBER,
		         p_scheduler_id              in NUMBER,
		         p_buyer_id                  in NUMBER,
		         p_planner_code              in VARCHAR2,
		         x_user_id                   in NUMBER,
                         x_login_id                  in NUMBER,
			 x_horizon_end_date          in DATE,
                         x_bucket_descriptor_table   in out NOCOPY chv_create_buckets.BKTTABLE,
                         x_bucket_start_date_table   in out NOCOPY chv_create_buckets.BKTTABLE,
                         x_bucket_end_date_table     in out NOCOPY chv_create_buckets.BKTTABLE,
			 x_item_created		     in out NOCOPY VARCHAR2,
			 x_old_schedule_id	     in NUMBER,
			 p_bucket_pattern_id	     in NUMBER,
			 p_schedule_subtype          in VARCHAR2,
			 p_batch_id		     in NUMBER
) IS

  x_progress                  VARCHAR2(3) := NULL;

  /* DEBUG x_schedule_num and x_schedule_revision are not used in this procedure,
     does load_item_orders need them? Doesn't look like that,
     Should we remove them from the parameter list?
     Also, should x_horizon_end_date be passed in from build_schedule?
     or should it be recalculated in get_cum_info? */
  -- Following variables whose values should be retrieved from cursors.
  x_asl_id_l                       NUMBER;
  x_item_id_l                      NUMBER;
  x_enable_cum_flag_l              VARCHAR2(1);
  x_enable_authorizations_flag_l   VARCHAR2(1);
  x_organization_id                NUMBER;
  /* Bug# 2933042 - Increased the size of x_organization_name from 60
     to 240 to make it UTF8 compliant */
  x_organization_name              VARCHAR2(240);
  x_temp_org_id			   NUMBER;

  -- Following variables whose values are calculated within the procedure.
  x_last_receipt_tranx_id_l        NUMBER;
  x_cum_quantity_received_l        NUMBER;
  x_cum_qty_received_primary_l     NUMBER;
  x_cum_period_end_date_l          DATE;
  x_starting_auth_quantity_l       NUMBER;
  x_starting_auth_qty_primary_l    NUMBER;
  x_item_planning_method_l         NUMBER;
  x_purch_unit_of_measure_l        VARCHAR2(25);
  x_primary_unit_of_measure_l      VARCHAR2(25);
  x_primary_uom_code_l             VARCHAR2(3);
  x_purchasing_uom_code_l          VARCHAR2(3);
  x_conversion_rate_l              NUMBER;
  x_plan_designator_l              VARCHAR2(10);
  x_po_header_id_l                 NUMBER;
  x_po_line_id_l                   NUMBER;
  x_schedule_item_id_l             NUMBER;
  x_number_of_blanket_agreements   NUMBER := 0;
  x_past_due			   NUMBER;
  x_past_due_primary		   NUMBER;
  x_plan_lookup			   VARCHAR2(25);
  x_dummy			   VARCHAR2(1);
  x_dummy_num1			   NUMBER;
  x_dummy_num2			   NUMBER;
  x_using_org_id_l		   NUMBER;
  x_str	                           VARCHAR2(480);

  -- An item must be MRP,MPS, or DRP planned in a ship-to org to be included
  --	in the schedule.  Note:  We have removed this requirement.  If
  --	the item is setup in the asl we will let you use it.  If we
  --	had this requirement we wouuld not be able to pick up items which
  --	are min/max planned, etc...
  -- An item must be purchaseable in the ship-to-org to be included in the
  --	schedule.  Note: We have removed this requirement for the same
  --	reason listed above.
  -- An item must be included in the ASL fro the ship-to org to be included in
  --    the schedule
  -- An item must be Planning/Shipping Schedule Enabled in the ASL for
  -- 	the corresponding schedule type to be included in the schedule
  -- AutoSchedule items are not included in NEW schedule builds in
  --	the workbench. It does not matter whether building planning
  --	or shipping schedules:  If AutoSchedule is 'Yes' in the ASL,
  --	the item is excluded.

  -- Multi-org schedules will create a new schedule item record for each
  --	item/organization combination
  -- Multiorg shipping schedules are not allowed
  -- If build a schedule for one org, this is specified by the user.
  --	If building schedules for multiple orgs, the list of orgs is
  --	determined by the specified MRP/MPS/DRP plans (each is potentially
  --	associated with multiple organizations).  In the wb, the user can
  --	optionally delete orgs from the composite list before launching
  --	the build process.

  -- All the qtys will be calculated in the primary and the
  --	purchasing uom.  Always recalc CUms using the ASL UOM.
  -- Supplier Scheduling requires the item in the ASL

  -- DEBUG. Logic for category set

  -- Note that only one cursor is needed at the item level for the
  -- WorkBench and AutoSchedule.  This is because we are not selecting
  -- distinct.
  -- Note that this does not need a correlated sub-query.  The max
  -- is done in the outer query. ** this has been changed Bug 454811(vpawar)
  CURSOR CI_SINGLE_ORG_WB_BPM IS
  SELECT paa.using_organization_id,
	 paa.asl_id,
         paa.item_id,
         NVL(paa.enable_authorizations_flag, 'N'),
	 paa.purchasing_unit_of_measure
  FROM   po_asl_attributes_val_v paa
  WHERE  ((paa.using_organization_id = -1 and not exists
                (SELECT *
                 FROM   po_asl_attributes_val_v paa2
                 WHERE  paa2.using_organization_id = x_organization_id
                 AND    paa2.vendor_id = paa.vendor_id
                 AND    paa2.vendor_site_id = paa.vendor_site_id
                 AND    paa2.item_id = paa.item_id ))
          or
          (paa.using_organization_id = x_organization_id))
  AND    paa.asl_id = paa.asl_id
  AND    paa.vendor_id = x_vendor_id
  AND    paa.vendor_site_id = x_vendor_site_id
  AND    nvl(p_item_id, paa.item_id) = paa.item_id
  AND    exists (select * from mtl_system_items
                 where inventory_item_id = paa.item_id
                 and organization_id = x_organization_id) /* Bug 462403 vpawar */
  AND    (p_category_set_id is null
          OR
	  paa.item_id in (
          	select mic.inventory_item_id
		from   mtl_item_categories mic
		where  mic.category_set_id = p_category_set_id
		and    mic.organization_id = x_organization_id
		and    nvl(p_category_id,mic.category_id) = mic.category_id))
  AND    nvl(p_autoschedule_flag,'N') = nvl(paa.enable_autoschedule_flag, 'N')
  AND   ((p_schedule_type = 'PLAN_SCHEDULE'
          AND paa.enable_plan_schedule_flag = 'Y')
         OR
         (p_schedule_type = 'SHIP_SCHEDULE'
          AND paa.enable_ship_schedule_flag = 'Y'))
  AND   (nvl(p_autoschedule_flag, 'N') = 'N'
          OR
         (p_autoschedule_flag = 'Y'
	  AND
	  ((p_schedule_type = 'PLAN_SCHEDULE'
	    AND  x_bucket_pattern_id = paa.plan_bucket_pattern_id)
           OR
           (p_schedule_type = 'SHIP_SCHEDULE'
	    AND  x_bucket_pattern_id = paa.ship_bucket_pattern_id))))
/* Bug 692450 Not checking schedule subtype */
  AND   (nvl(p_autoschedule_flag, 'N') = 'N'
          OR
         (p_autoschedule_flag = 'Y'
          AND
          ((p_schedule_type = 'PLAN_SCHEDULE'
            AND  x_schedule_subtype = paa.plan_schedule_type)
           OR
           (p_schedule_type = 'SHIP_SCHEDULE'
            AND  x_schedule_subtype = paa.ship_schedule_type))))
/* Bug 692450 Not checking schedule subtype */
  AND   nvl(paa.scheduler_id,-1) =
		NVL(p_scheduler_id, nvl(paa.scheduler_id,-1))
  AND   (p_planner_code IS NULL
         OR
         EXISTS (SELECT 'check if planner exists in mtl_system_items'
                 FROM  mtl_system_items msi,mtl_planners mtp
                 WHERE  msi.planner_code     = p_planner_code
                 AND    msi.inventory_item_id = paa.item_id
                 AND    mtp.organization_id = x_organization_id
                 AND    mtp.planner_code      = p_planner_code
                 AND    msi.organization_id = x_organization_id))
  AND   (p_buyer_id IS NULL
         OR
         EXISTS (SELECT 'check if buyer exists in mtl_system_items'
                 FROM   mtl_system_items msi
                 WHERE  msi.inventory_item_id = paa.item_id
                 AND    msi.organization_id   = x_organization_id
                 AND    msi.buyer_id          = p_buyer_id));
/*    GROUP BY paa.asl_id,
             paa.item_id,
             NVL(paa.enable_authorizations_flag, 'N'),
             paa.purchasing_unit_of_measure; */

  -- DEBUG.  Check for disabled org, disabled asl record, anything
  --		else that might be disabled

  -- Define the cursor to get all items that need to be rebuilt.


  -- If this is multi-org, we need to insert an item record for
  -- each organization.
  CURSOR C_ITEM_ORGS IS
  SELECT cso.organization_id
  FROM   chv_schedule_organizations cso
  WHERE  cso.batch_id = p_batch_id;

  -- We must open a cursor if this is not multi-org.  This is a dummy
  -- cursor that will find one record.
  CURSOR C_ITEM_NOORGS IS
  SELECT dummy
  FROM   sys.dual;

  -- Get all orgs currently on the schedule
  CURSOR C_ITEM_ORGS_REVISION IS
  SELECT distinct csi.organization_id
  FROM   chv_schedule_items csi
  WHERE  csi.schedule_id = x_old_schedule_id;

  -- Get all records where the flag is set to rebuild.
  CURSOR REBUILD IS
  SELECT csi.schedule_item_id,
	 csi.item_id,
	 decode(csi.item_planning_method,'MRP_PLANNED',3,
					 'MPS_PLANNED',2,
					 'DRP_PLANNED',4),
	 csi.organization_id
  FROM   chv_schedule_items csi
  WHERE  csi.schedule_id = x_schedule_id
  AND    nvl(csi.rebuild_flag, 'N') = 'Y';

  -- Get all item records for a schedule.
  CURSOR REVISION IS
  SELECT csi.schedule_item_id,
	 csi.organization_id,
	 csi.item_id,
	 decode(csi.item_planning_method,'MRP_PLANNED',3,
	                                 'MPS_PLANNED',2,
				         'DRP_PLANNED',4),
	 csi.purchasing_unit_of_measure
  FROM   chv_schedule_items csi
  WHERE  csi.schedule_id = x_old_schedule_id;

  -- Get all item records for a schedule and organization.
  CURSOR REVISION_MULTI_ORGS IS
  SELECT csi.schedule_item_id,
	 csi.organization_id,
	 csi.item_id,
	 decode(csi.item_planning_method,'MRP_PLANNED',3,
	                                 'MPS_PLANNED',2,
				         'DRP_PLANNED',4),
	 csi.purchasing_unit_of_measure
  FROM   chv_schedule_items csi
  WHERE  csi.schedule_id = x_old_schedule_id
  AND    csi.organization_id = x_organization_id;



BEGIN



---- dbms_output.put_line('Create_Items: in create items');


-- If this is a item rebuild, it will always be for one oragnization.
-- We do not need to loop through multiple organizations.
IF (p_multi_org_flag = 'N' OR p_multi_org_flag is null OR
	p_schedule_category = 'REBUILD') THEN

  ---- dbms_output.put_line('Create_Items: before opening C_ITEM_NOORGS');

  OPEN C_ITEM_NOORGS;

ELSE

  IF (p_schedule_category = 'REVISION') THEN

    ---- dbms_output.put_line('Create_items: revision cursor');
    OPEN C_ITEM_ORGS_REVISION;

  ELSE

   ---- dbms_output.put_line('Create_items: no revision cursor');
   OPEN C_ITEM_ORGS;

  END IF;

END IF;

LOOP


  IF (p_multi_org_flag = 'N' OR p_multi_org_flag is NULL
	OR p_schedule_category = 'REBUILD') THEN

    ---- dbms_output.put_line('Create_Items: before fetching C_ITEM_NOORGS');

    -- Do not select any organizations.  Just a dummy record.
    FETCH C_ITEM_NOORGS
    INTO  x_dummy;
    EXIT WHEN C_ITEM_NOORGS%NOTFOUND;

     -- Revision sql statement selects the org.  Since we cannot
     -- assign a value to a parameter, the workaround is to
     -- setup another variable.
     x_organization_id := x_organization_id_l;

  ELSE

    IF (p_schedule_category = 'REVISION') THEN

      -- Fetch all orgs currently on schedule.
      FETCH C_ITEM_ORGS_REVISION
      INTO  x_organization_id;
      EXIT  WHEN C_ITEM_ORGS_REVISION%NOTFOUND;

    ELSE

      -- Fetch all orgs that the user selected in the WB.
      FETCH C_ITEM_ORGS
      INTO  x_organization_id;
      EXIT  WHEN C_ITEM_ORGS%NOTFOUND;

    END IF;

  END IF;


  ---- dbms_output.put_line('Create Items: Item'||p_item_id);

  ---- dbms_output.put_line('Entering create_items');

  -- Open the appropriate cursor based on p_multi_org_flag and
  --      p_autoschedule_flag.
  x_progress := '010';

  IF p_schedule_category = 'REBUILD' THEN
    OPEN REBUILD;


  ELSIF p_schedule_category = 'REVISION' THEN
    IF (p_multi_org_flag = 'N' or p_multi_org_flag is NULL) THEN
      OPEN REVISION;
    ---- dbms_output.put_line('Create_items: Opening single org cursor');
    ELSE
      OPEN REVISION_MULTI_ORGS;
    ---- dbms_output.put_line('Create_items: Opening Multiorg cursor');
    END IF;


  ELSE
    OPEN CI_SINGLE_ORG_WB_BPM;

  END IF;

  LOOP
    ---- dbms_output.put_line('Create_items: fetching cursor');

    -- Fetch one row at a time from the appropriate cursor opened above
    --      (based on p_multi_org_flag and p_autoschedule_flag).
    --      Exit the loop at the last row
    x_progress := '020';
    IF p_schedule_category = 'REBUILD' THEN
      -- Fetch all items that need to be rebuilt, along with
      -- their organization.
      FETCH REBUILD
      INTO x_schedule_item_id_l,
	   x_item_id_l,
	   x_item_planning_method_l,
	   x_organization_id;
      EXIT WHEN REBUILD%NOTFOUND;

      -- The options for the item/org/supplier/supplier site from the asl.
      SELECT paa.asl_id,
	     nvl(paa.enable_authorizations_flag,'N'),
	     paa.purchasing_unit_of_measure,
	     max(paa.using_organization_id)
      INTO   x_asl_id_l,
	     x_enable_authorizations_flag_l,
	     x_purch_unit_of_measure_l,
	     x_using_org_id_l
      FROM   po_asl_attributes_val_v paa
      WHERE  paa.vendor_id = x_vendor_id
      AND    paa.vendor_site_id = x_vendor_site_id
      AND    paa.item_id = x_item_id_l
      AND    paa.using_organization_id =
		(SELECT MAX(paa2.using_organization_id)
		 FROM   po_asl_attributes_val_v paa2
	         WHERE  decode(paa2.using_organization_id, -1,
			 x_organization_id, paa2.using_organization_id) =
				x_organization_id
		 AND    paa2.vendor_id = x_vendor_id
                 AND    paa2.vendor_site_id = x_vendor_site_id
		 AND    paa2.item_id = x_item_id_l)
      GROUP BY paa.asl_id, paa.enable_authorizations_flag,
		paa.purchasing_unit_of_measure;

      -- Get the new primary unit of measure associated with the item
      -- in case the primary unit of measure has changed.
      SELECT primary_unit_of_measure
      INTO   x_primary_unit_of_measure_l
      FROM   MTL_system_items
      WHERE  organization_id   = x_organization_id
      AND    inventory_item_id = x_item_id_l;

    ELSIF p_schedule_category = 'REVISION' THEN
          IF (p_multi_org_flag = 'N' or p_multi_org_flag is NULL) THEN
             ---- dbms_output.put_line('Create_items: schedule ID'||x_old_schedule_id);

              FETCH REVISION
              INTO  x_schedule_item_id_l,
                    x_organization_id,
                    x_item_id_l,
                    x_item_planning_method_l,
                    x_purch_unit_of_measure_l;
               EXIT WHEN REVISION%NOTFOUND;
          ELSE
             ---- dbms_output.put_line('Create_items: Mschedule ID'||x_old_schedule_id);
             ---- dbms_output.put_line('Create_items: Mschedule ID'||x_organization_id_l);
             ---- dbms_output.put_line('Create_items: Mschedule ID'||x_organization_id);
              FETCH REVISION_MULTI_ORGS
              INTO  x_schedule_item_id_l,
                    x_organization_id,
                    x_item_id_l,
                    x_item_planning_method_l,
                    x_purch_unit_of_measure_l;
               EXIT WHEN REVISION_MULTI_ORGS%NOTFOUND;
          END IF;

      ---- dbms_output.put_line('Create_items: MitemID'||x_item_id_l);
      SELECT paa.asl_id,
	     nvl(paa.enable_authorizations_flag,'N'),
	     max(paa.using_organization_id)
      INTO   x_asl_id_l,
	     x_enable_authorizations_flag_l,
	     x_using_org_id_l
      FROM   po_asl_attributes_val_v paa
      WHERE  paa.vendor_id = x_vendor_id
      AND    paa.vendor_site_id = x_vendor_site_id
      AND    paa.item_id = x_item_id_l
      AND    paa.using_organization_id =
		(SELECT MAX(paa2.using_organization_id)
		 FROM   po_asl_attributes_val_v paa2
	         WHERE  decode(paa2.using_organization_id, -1,
			 x_organization_id, paa2.using_organization_id) =
				x_organization_id
		 AND    paa2.vendor_id = x_vendor_id
                 AND    paa2.vendor_site_id = x_vendor_site_id
		 AND    paa2.item_id = x_item_id_l)
      GROUP BY paa.asl_id, paa.enable_authorizations_flag;

    ELSE
      ---- dbms_output.put_line('Create Items: before fetch of WB_BPM');

      FETCH CI_SINGLE_ORG_WB_BPM
      INTO  x_using_org_id_l,
	    x_asl_id_l,
            x_item_id_l,
            x_enable_authorizations_flag_l,
	    x_purch_unit_of_measure_l;
      EXIT WHEN CI_SINGLE_ORG_WB_BPM%NOTFOUND;
    END IF;


    -- Included is the seed data rules for the item_planning_method
    -- 3:MRP; 4:MPS, 6:Not Planned, 7:MRP/DRP, 8:MPS/DRP, 9:DRP
    -- If we are rebuilding a schedule, we get the plan type
    --	from the schedule header and the planning method associated
    --  with the item.
    ---- dbms_output.put_line ('Create_items: get plan_designator');

    IF (p_schedule_category <> 'REBUILD') THEN

      -- Select item_planning_method and primary_unit_of_measure from
      --          MTL_SYSTEM_ITEMS.
      ---- dbms_output.put_line ('Create_items: select from MTL_SYSTEM_ITEMS');

      x_progress := '040';
      -- DEBUG Prio C.  Move to main cursor.
/*      SELECT decode(p_schedule_category, 'REVISION', x_item_planning_method_l, */
      SELECT mrp_planning_code,
             primary_unit_of_measure
      INTO   x_item_planning_method_l,
             x_primary_unit_of_measure_l
      FROM   MTL_system_items
      WHERE  organization_id   = x_organization_id
      AND    inventory_item_id = x_item_id_l;

      ---- dbms_output.put_line('Create_items: Planning Meth'||x_item_planning_method_l);

      x_progress := '050';
      -- DEBUG.  Beef up comments on this.
      IF (x_item_planning_method_l in (3, 7)) THEN
         x_plan_designator_l := x_mrp_compile_designator;
         x_plan_lookup := 'MRP_PLANNED';
      ELSIF (x_item_planning_method_l in (4, 8)) THEN
         x_plan_designator_l := x_mps_schedule_designator;
	 x_plan_lookup := 'MPS_PLANNED';
      ELSIF (x_item_planning_method_l = 9) THEN
         x_plan_designator_l := x_drp_compile_designator;
	 x_plan_lookup := 'DRP_PLANNED';
      END IF;
    END IF;

      SELECT nvl(enable_cum_flag,'N')
      INTO   x_enable_cum_flag_l
      FROM   chv_org_options
      WHERE  organization_id = x_organization_id;

      -- If we are building a simulation schedule, we will still let
      -- you build the schedule if a cum period is not open.
      IF (p_schedule_category = 'SIMULATION') THEN
        x_enable_cum_flag_l := 'N';
      END IF;

      -- A CUM period must be open.

      IF (x_enable_cum_flag_l = 'Y') THEN
        BEGIN

  /* Bug 2251090 fixed. In the where clause  of the below sql, added
     the nvl() statement for cum_period_end_date to take care of null
     condition.
  */
  /* Bug 4485196 fixed. added to_char to below select clause as it was failing with
     ORA-6502 error on 10G database.
  */
          SELECT max(to_char('Y'))
          INTO   x_enable_cum_flag_l
          FROM   chv_cum_periods
          WHERE  organization_id = x_organization_id
          AND    p_horizon_start_date between
     	  	 cum_period_start_date and nvl(cum_period_end_date,p_horizon_start_date+1);

          IF x_enable_cum_flag_l is null THEN
              SELECT organization_name INTO x_organization_name FROM
              org_organization_definitions WHERE
              organization_id = x_organization_id;
              fnd_message.set_name('CHV','CHV_NO_ACTIVE_OPEN_CUM');
              FND_MESSAGE.SET_TOKEN('ORG',x_organization_name);
              x_str := fnd_message.get;
              ---- dbms_output.put_line(x_str);
              EXIT;
          END IF;

        EXCEPTION
          WHEN OTHERS THEN raise;

        END;

      END IF;

      -- If cum is enabled, get the cum qty received and the last
      -- receipt transaction date.
      ---- dbms_output.put_line('Create_items: get_cum_info');

      x_progress := '030';
      IF  x_enable_cum_flag_l = 'Y' THEN
        chv_cum_periods_s2.get_cum_info (x_organization_id,
                                    x_vendor_id,
                                    x_vendor_site_id,
                                    x_item_id_l,
                                    p_horizon_start_date,
    		  		    x_horizon_end_date,
    			  	    x_purch_unit_of_measure_l,
    				    x_primary_unit_of_measure_l,
                                    x_last_receipt_tranx_id_l,
                                    x_cum_quantity_received_l,
                                    x_cum_qty_received_primary_l,
                                    x_cum_period_end_date_l);
      END IF;


      -- If p_schedule_category is not REBUILD, insert new chv_schedule_items.
      --       Before that, need to get a new unique schedule item id.
      IF p_schedule_category <> 'REBUILD' THEN
        x_progress := '060';
        SELECT chv_schedule_items_s.NEXTVAL
        INTO   x_schedule_item_id_l
        FROM   DUAL;

        ---- dbms_output.put_line ('Create_items: inserting into chv_schedule_items');
        ---- dbms_output.put_line ('Create_items: schedule id'||x_schedule_id);
        ---- dbms_output.put_line ('Create_items: schedule_item_id'||x_schedule_item_id_l);
        ---- dbms_output.put_line ('Create_items: item id'||x_item_id_l);
        ---- dbms_output.put_line ('Create_items: org'||x_organization_id);
        ---- dbms_output.put_line ('Create_items: plan'||x_plan_lookup);
        ---- dbms_output.put_line ('Create_items: user'||x_user_id);
        ---- dbms_output.put_line ('Create_items: login'||x_login_id);

        x_progress := '070';

        INSERT INTO chv_schedule_items (schedule_id,
                                      schedule_item_id,
                                      organization_id,
                                      item_id,
                                      item_planning_method,
                                      po_header_id,
                                      po_line_id,
                                      last_update_date,
                                      last_updated_by,
                                      creation_date,
                                      created_by,
                                      rebuild_flag,
                                      item_confirm_status,
                                      starting_cum_quantity,
                                      starting_auth_quantity,
                                      starting_cum_qty_primary,
                                      starting_auth_qty_primary,
                                      last_receipt_transaction_id,
                                      purchasing_unit_of_measure,
                                      primary_unit_of_measure,
                                      last_update_login)
          VALUES                         (x_schedule_id,
                                      x_schedule_item_id_l,
                                      x_organization_id,
                                      x_item_id_l,
                                      x_plan_lookup,
                                      x_po_header_id_l,
                                      x_po_line_id_l,
                                      SYSDATE,              -- last_update_date
                                      x_user_id,            -- last_updated_by
                                      SYSDATE,              -- creation_date
                                      x_user_id,            -- created_by
                                      'N',                  -- rebuild_flag
                                      'IN_PROCESS',
                                      x_cum_quantity_received_l,
                                      0, -- starting_auth_qty to be updated later
                                      x_cum_qty_received_primary_l,
                                      0, -- start_auth_qty_prim to be updated later
                                      x_last_receipt_tranx_id_l,
                                      x_purch_unit_of_measure_l,
                                      x_primary_unit_of_measure_l,
                                      x_login_id);         -- last_update_login
        x_item_created := 'Y';



      ELSE -- The schedule type = 'REBUILD'

        x_progress := '080';

        -- We need to update the primary and purchasing unit of measure
        -- on the item in case it has changed since the orginial build.
        update chv_schedule_items
        set rebuild_flag = 'N',
    	    item_confirm_status = 'IN_PROCESS',
    	    last_updated_by = x_user_id,
    	    last_update_date = sysdate,
    	    last_update_login = x_login_id,
    	    purchasing_unit_of_measure = x_purch_unit_of_measure_l,
    	    primary_unit_of_measure = x_primary_unit_of_measure_l,
	    starting_cum_quantity = x_cum_quantity_received_l,
            starting_cum_qty_primary=x_cum_qty_received_primary_l,
	    last_receipt_transaction_id=x_last_receipt_tranx_id_l
        where  schedule_item_id = x_schedule_item_id_l;

         x_item_created := 'Y';

         --Based on the Item Planning method we need to pass the
         --plan designator to load item orders.

         IF x_item_planning_method_l = 3 then
            x_plan_designator_l := x_mrp_compile_designator ;
         ELSIF
            x_item_planning_method_l = 2 then
            x_plan_designator_l := x_mps_schedule_designator ;
         ELSIF
            x_item_planning_method_l = 4 then
            x_plan_designator_l := x_drp_compile_designator ;
         END IF ;

      END IF; -- end of if REBUID

      ---- dbms_output.put_line ('Create_items: calculating conversion rate.');

      -- Get the uom code (3 characters) for the primary unit of measure
      x_progress := '080';

      BEGIN

        SELECT uom_code
        INTO   x_primary_uom_code_l
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = x_primary_unit_of_measure_l;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN null;
        WHEN OTHERS THEN raise;
      END;

      -- Get the uom code (3 characters) for the purch unit of measure
      x_progress := '090';

      BEGIN

        SELECT uom_code
        INTO   x_purchasing_uom_code_l
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = X_purch_unit_of_measure_l;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN null;
        WHEN OTHERS THEN raise;
      END;

      -- Get the conversion rate for the item going from primary to
      --      purchasing unit of measure.
      --      precision is to 10 places
      x_progress := '100';
      inv_convert.inv_um_conversion(x_primary_uom_code_l,
                                  x_purchasing_uom_code_l,
                                  x_item_id_l, x_conversion_rate_l);

      ---- dbms_output.put_line('Create_Items: conv rate: P->PO:'||x_conversion_rate_l);

      -- Get item's discrete planned orders, requisitions and approved releases.
      ---- dbms_output.put_line ('Create_items: load_item_orders');

      x_progress := '110';
      chv_load_orders.load_item_orders(x_organization_id,
                                     x_schedule_id,
                                     x_schedule_item_id_l,
                                     x_vendor_id,
                                     x_vendor_site_id,
                                     x_item_id_l,
    				     x_purch_unit_of_measure_l,
    				     x_primary_unit_of_measure_l,
                                     x_conversion_rate_l,
                                     p_horizon_start_date,
                                     x_horizon_end_date,
                                     p_include_future_releases,
                                     p_schedule_type,
                                     x_schedule_subtype,
    				     x_plan_designator_l
                                    );

      -- Calculate bucket qty
      ---- dbms_output.put_line('Create_items: calculate_bucket_qty');
      ---- dbms_output.put_line('Create_items: schedule_id'||x_schedule_id);
      ---- dbms_output.put_line('Create_items: item id'||x_schedule_item_id_l);
      ---- dbms_output.put_line('Create_items: start date'||p_horizon_start_date);
      ---- dbms_output.put_line('Create_items: end date'||x_horizon_end_date);
      ---- dbms_output.put_line('Create_items: sched type'||p_schedule_type);
      ---- dbms_output.put_line('Create_items: cum enabled'||x_enable_cum_flag_l);
      ---- dbms_output.put_line('Create_items: cum qty'||x_cum_quantity_received_l);

      x_progress := '150';
      chv_create_buckets.calculate_buckets( x_schedule_id,
                                          x_schedule_item_id_l,
                                          p_horizon_start_date,
                                          x_horizon_end_date,
    					  x_schedule_subtype,
                                          x_enable_cum_flag_l,
    	                                  x_cum_quantity_received_l,
                                          x_bucket_descriptor_table,
                                          x_bucket_start_date_table,
                                          x_bucket_end_date_table,
    					  x_past_due,
    					  x_past_due_primary);

      --  Logic for getting oldest open Supply Agreement:
      --  1.  Get the oldest open supply agreement that has open
      --		requirements on the schedule.
      --  2.  If there is not a supply agreement on the schedule
      --		get the supply agreement that is in the ASL.
      --  3.  If there is more than one record on the ASL, get the
      --		oldest open one.
      --  4.  If there is one record on the ASL. get that one.
      --  5.  If there are no ASL records, get the oldest open
      --		Supply Agreement.
      ---- dbms_output.put_line('Create_items: select po_header and po_line');

      x_progress := '115';
  /* Bug 2365922 fixed. Appended 'AND' statements to the below sql
     to check for vendor_id and vendor_site_id.
  */

      SELECT min(poh.po_header_id)
      INTO   x_po_header_id_l
      FROM   po_headers poh,
    	       chv_item_orders cio,
    	       po_lines pol
      WHERE  poh.creation_date =
    		(SELECT min(poh2.creation_date)
    		 FROM   po_headers poh2,
    			po_lines pol2,
    			chv_item_orders cio2
    	         WHERE  cio2.schedule_id = x_schedule_id
                 AND    poh2.po_header_id = cio2.document_header_id
                 AND    cio2.schedule_item_id = x_schedule_item_id_l
    	         AND    poh2.po_header_id = pol2.po_header_id
                 AND    pol2.item_id = x_item_id_l
                 AND    cio2.supply_document_type = 'RELEASE'
				 AND    nvl(poh2.supply_agreement_flag,'N') = 'Y'
                 AND    nvl(poh2.cancel_flag,'N') = 'N'
                 AND    nvl(poh2.closed_code,'OPEN') = 'OPEN'
 	             AND    Trunc(Nvl(poh2.end_date,SYSDATE)) >= Trunc(SYSDATE) --bug18778747
			)
      AND    cio.schedule_id = x_schedule_id
      AND    poh.po_header_id = cio.document_header_id
      AND    cio.schedule_item_id = x_schedule_item_id_l
      AND    cio.supply_document_type = 'RELEASE'
      AND    pol.item_id = x_item_id_l
      AND    poh.po_header_id = pol.po_header_id
      AND    nvl(poh.supply_agreement_flag,'N') = 'Y'
	  AND    nvl(poh.cancel_flag,'N') = 'N'
	  AND    nvl(poh.closed_code,'OPEN') = 'OPEN' ----bug18778747
      AND    poh.vendor_id = x_vendor_id
      AND    poh.vendor_site_id = x_vendor_site_id ;

      IF (x_po_header_id_l is not NULL) THEN

        x_progress := '125';

        SELECT min(pol.po_line_id)
        INTO   x_po_line_id_l
        FROM   po_lines pol
        WHERE  pol.po_header_id = x_po_header_id_l
        AND    pol.item_id = x_item_id_l
		AND    nvl(pol.cancel_flag,'N') = 'N'
		AND    nvl(pol.closed_code,'OPEN') = 'OPEN'
		AND    Trunc(Nvl(pol.expiration_date,SYSDATE)) >= Trunc(SYSDATE); --bug18778747

	-- Bug 19077362: Cummins GBPA Support : Start */
	-- If Agreement# is coming as Standard PO, replace with GBPA details
	DECLARE
	  l_gbpa_header_id number;
	  l_gbpa_line_id number;

	BEGIN
	  SELECT  pol.from_header_id, pol.from_line_id
	  INTO    l_gbpa_header_id, l_gbpa_line_id
	  FROM    po_headers poh, po_lines pol
	  WHERE   pol.po_line_id = x_po_line_id_l
	    AND     pol.po_header_id = x_po_header_id_l
	    AND     poh.po_header_id = pol.po_header_id
	    AND     poh.type_lookup_code = 'STANDARD'
	    AND     EXISTS (
	                  SELECT  1
			  FROM    po_headers ph1, po_lines pl1
			  WHERE   pol.from_line_id IS NOT NULL
			    AND     pol.from_line_id = pl1.po_line_id
			    AND     pl1.po_header_id = ph1.po_header_id
			    AND     ph1.type_lookup_code = 'BLANKET'
			    AND     nvl(ph1.global_agreement_flag,'N') = 'Y'
			    AND     nvl(ph1.supply_agreement_flag,'N') = 'Y'
			    AND     nvl(pl1.cancel_flag,'N') = 'N'
			    AND     nvl(pl1.closed_code,'OPEN') = 'OPEN'
			    AND     Trunc(Nvl(pl1.expiration_date,SYSDATE)) >= Trunc(SYSDATE)
			    AND     Trunc(Nvl(ph1.end_date,SYSDATE)) >= Trunc(SYSDATE)
			    AND     nvl(ph1.closed_code, 'OPEN') = 'OPEN'
			    AND     nvl(ph1.cancel_flag, 'N') = 'N');

	  x_po_header_id_l := l_gbpa_header_id;
	  x_po_line_id_l := l_gbpa_line_id;

	EXCEPTION
	  WHEN no_data_found THEN
	    NULL;
	END;
       -- Bug 19077362: Cummins GBPA Support : End */


      ELSE

        BEGIN
  /* Bug 2365922 fixed. Appended 'AND' statements to the below sql
     to check for vendor_id and vendor_site_id.
  */

          SELECT count(*)
          INTO   x_number_of_blanket_agreements
          FROM   po_asl_documents,
		 po_headers poh
          WHERE  asl_id = x_asl_id_l
          AND    using_organization_id = x_using_org_id_l
          AND    document_type_code = 'BLANKET'
	  AND    poh.po_header_id = document_header_id
          AND    nvl(poh.supply_agreement_flag,'N') = 'Y'
          AND    nvl(poh.cancel_flag,'N') = 'N'
          AND    nvl(poh.closed_code,'OPEN') = 'OPEN'
          AND    Trunc(Nvl(poh.end_date,SYSDATE)) >= Trunc(SYSDATE) --bug18778747
		  AND    poh.vendor_id = x_vendor_id
          AND    poh.vendor_site_id = x_vendor_site_id ;

        EXCEPTION
          WHEN NO_DATA_FOUND then null;
          WHEN OTHERS then raise;

        END;

        x_progress := '120';

        IF (x_number_of_blanket_agreements = 1) THEN

          ---- dbms_output.put_line('Create_items: #B = 1');
  /* Bug 2365922 fixed. Appended 'AND' statements to the below sql
     to check for vendor_id and vendor_site_id.
  */

          SELECT document_header_id,
		 document_line_id
          INTO   x_po_header_id_l,
		 x_po_line_id_l
          FROM   po_asl_documents
                 , po_headers poh
          WHERE  document_type_code = 'BLANKET'
	  AND    poh.po_header_id = document_header_id
          AND    nvl(poh.supply_agreement_flag,'N') = 'Y'
          AND    nvl(poh.cancel_flag,'N') = 'N'
          AND    nvl(poh.closed_code,'OPEN') = 'OPEN'
		  AND    Trunc(Nvl(poh.end_date,SYSDATE)) >= Trunc(SYSDATE) --bug18778747
          AND    using_organization_id = x_using_org_id_l
          AND    asl_id = x_asl_id_l
          AND    poh.vendor_id = x_vendor_id
          AND    poh.vendor_site_id = x_vendor_site_id ;

        ELSIF (x_number_of_blanket_agreements > 1) THEN

      	  ---- dbms_output.put_line('Create_items: #B > 0: asl id'||x_asl_id_l);
          ---- dbms_output.put_line('Create_items: sitem id'||x_schedule_item_id_l);
  /* Bug 2365922 fixed. Added an 'AND' statement to the below sql
     to check for vendor_id and vendor_site_id.
  */

          SELECT min(poh.po_header_id)
          INTO   x_po_header_id_l
          FROM   po_headers poh,
    	         po_lines pol,
    	         po_asl_documents pad
          WHERE  poh.creation_date =
    		(SELECT min(poh2.creation_date)
    		 FROM   po_headers poh2,
    			po_lines pol2,
    			po_asl_documents pad2
    	         WHERE  poh2.po_header_id = pad2.document_header_id
                 AND    pad2.asl_id = x_asl_id_l
                 AND    pad2.using_organization_id = x_using_org_id_l
    	         AND    poh2.po_header_id = pol2.po_header_id
                 AND    pol2.item_id = x_item_id_l
                 AND    pad2.document_type_code = 'BLANKET'
				 AND    poh2.vendor_id = x_vendor_id
				 AND    poh2.vendor_site_id = x_vendor_site_id
				 AND    nvl(poh2.supply_agreement_flag,'N') = 'Y'
				 AND    nvl(poh2.cancel_flag,'N') = 'N'
				 AND    nvl(poh2.closed_code,'OPEN') = 'OPEN'
				 AND    Trunc(Nvl(poh2.end_date,SYSDATE)) >= Trunc(SYSDATE) --bug18778747
			)
          AND    pad.document_header_id = poh.po_header_id
		  AND    pad.asl_id = x_asl_id_l
          AND    pad.using_organization_id = x_using_org_id_l
          AND    poh.po_header_id = pol.po_header_id
          AND    pol.item_id = x_item_id_l
          AND    pad.document_type_code = 'BLANKET'
          AND    poh.vendor_id = x_vendor_id
          AND    poh.vendor_site_id = x_vendor_site_id
		  AND    nvl(poh.supply_agreement_flag,'N') = 'Y'
		  AND    nvl(poh.cancel_flag,'N') = 'N'
		  AND    nvl(poh.closed_code,'OPEN') = 'OPEN' ; --bug18778747

          x_progress := '125';

          ---- dbms_output.put_line('Create_items: select min line id');

          SELECT min(pol.po_line_id)
          INTO   x_po_line_id_l
          FROM   po_lines pol,
		 po_asl_documents
          WHERE  pol.po_header_id = x_po_header_id_l
          AND    pol.item_id = x_item_id_l
	  AND    pol.po_header_id = document_header_id
          AND    nvl(pol.cancel_flag,'N') = 'N'
          AND    nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
		  AND    Trunc(Nvl(pol.expiration_date,SYSDATE)) >= Trunc(SYSDATE); --bug18778747

	ELSE /* There are no asl records */
  /* Bug 2365922 fixed. Appended 'AND' statements to the below sql
     to check for vendor_id and vendor_site_id.
  */

          SELECT min(poh.po_header_id)
          INTO   x_po_header_id_l
          FROM   po_headers poh,
    	         po_lines pol
          WHERE  poh.creation_date =
    		(SELECT min(poh2.creation_date)
    		 FROM   po_headers poh2,
    			po_lines pol2
    	         WHERE  poh2.po_header_id = pol2.po_header_id
                 AND    pol2.item_id = x_item_id_l
				 AND    poh2.type_lookup_code = 'BLANKET'
				 AND    poh2.authorization_status = 'APPROVED'
				 AND    nvl(poh2.cancel_flag,'N') = 'N'
				 AND    nvl(poh2.closed_code,'OPEN') = 'OPEN'
				 AND    Trunc(Nvl(poh2.end_date,SYSDATE)) >= Trunc(SYSDATE) --bug18778747
			)
          AND    poh.po_header_id = pol.po_header_id
          AND    pol.item_id = x_item_id_l
          AND    poh.type_lookup_code = 'BLANKET'
	  AND    poh.authorization_status = 'APPROVED'
	  AND    nvl(poh.cancel_flag,'N') = 'N'
          AND    nvl(poh.closed_code,'OPEN') = 'OPEN'
          AND    Trunc(Nvl(poh.end_date,SYSDATE)) >= Trunc(SYSDATE) --bug18778747
		  AND    poh.vendor_id = x_vendor_id
          AND    poh.vendor_site_id = x_vendor_site_id ;

          x_progress := '125';

          ---- dbms_output.put_line('Create_items: select min line id');

          SELECT min(pol.po_line_id)
          INTO   x_po_line_id_l
          FROM   po_lines pol
          WHERE  pol.po_header_id = x_po_header_id_l
          AND    pol.item_id = x_item_id_l
          AND    nvl(pol.cancel_flag,'N') = 'N'
          AND    nvl(pol.closed_code,'OPEN') = 'OPEN'
		  AND    Trunc(Nvl(pol.expiration_date,SYSDATE)) >= Trunc(SYSDATE); --bug18778747

        END IF; -- If only one blanket agreement

      END IF; -- If no header found

	  /* bug18778747 : For a schedule header, the x_item_created should be Y
 	    if atleast one item is created, since passing Item details in parameters
 	    is not mandatory. */

 	 IF x_po_header_id_l is NOT NULL AND x_po_line_id_l is NOT NULL THEN
 	    x_item_created := 'Y';
 	 END IF;

      -- Authorizations are calculated only for Planning Schedules if
      -- 	   authorizations are enabled in the ASL for the vendor/vendor site/
      --     item/org combination.

      -- If authorizations are being calculated and CUMS are being tracked,
      -- the authorization quanitty starts with the CUM qty received +
      -- any past due quantity.  If CUMS are not being tracked, the
      -- authorizations start with the past due quantity.

      ---- dbms_output.put_line('Create_items: calculating starting auth qty');

      x_progress := '130';
      IF x_enable_authorizations_flag_l = 'Y' AND
    		p_schedule_type = 'PLAN_SCHEDULE' THEN

        x_starting_auth_quantity_l := nvl(x_cum_quantity_received_l,0) +
                                      nvl(x_past_due,0);
        x_starting_auth_qty_primary_l := nvl(x_cum_qty_received_primary_l,0) +
                                         nvl(x_past_due_primary,0);

      END IF;

      -- Update chv_schedule_items with the new po_header_id, po_line_id, and
      --       starting authorization quantities.
      ---- dbms_output.put_line('Create_items: updating chv_schedule_items');

      x_progress := '140';
      UPDATE chv_schedule_items
      SET    po_header_id              = x_po_header_id_l,
           po_line_id                = x_po_line_id_l,
           starting_auth_quantity    = x_starting_auth_quantity_l,
           starting_auth_qty_primary = x_starting_auth_qty_primary_l
      WHERE schedule_item_id = x_schedule_item_id_l;


      ---- dbms_output.put_line('Create_items: calc_auth_qty');

      -- Calculate authorization quantities.
      x_progress := '160';
      IF x_enable_authorizations_flag_l = 'Y' AND p_schedule_type =
    		'PLAN_SCHEDULE' THEN

        ---- dbms_output.put_line('Create_items: before insert into auths');

        chv_create_authorizations.insert_authorizations(x_organization_id,
                                              x_schedule_id,
                                              x_schedule_item_id_l,
                                              x_asl_id_l,
                                              p_horizon_start_date,
                                              x_horizon_end_date,
    					      x_starting_auth_quantity_l,
    					      x_starting_auth_qty_primary_l,
    					      x_cum_quantity_received_l,
    					      x_cum_qty_received_primary_l,
                                              x_cum_period_end_date_l,
                                              x_purch_unit_of_measure_l,
                                              x_primary_unit_of_measure_l,
                                              x_enable_cum_flag_l);
      END IF;

  x_last_receipt_tranx_id_l := to_number(null);
  x_cum_quantity_received_l := to_number(null);
  x_cum_qty_received_primary_l := to_number(null);
  x_cum_period_end_date_l := to_date(null);

  END LOOP;

  ---- dbms_output.put_line ('Create_items: here1 cursor');
  -- Close the appropriate cursor
  x_progress := '170';
  IF p_schedule_category = 'REVISION' THEN
    IF (p_multi_org_flag = 'N' or p_multi_org_flag is NULL) THEN
        CLOSE REVISION;
    ELSE
        CLOSE REVISION_MULTI_ORGS;
    END IF;
  ELSIF p_schedule_category = 'REBUILD' THEN
    CLOSE REBUILD;
  ELSE
    CLOSE CI_SINGLE_ORG_WB_BPM;
  END IF;

  END LOOP;  -- organization loop.


  ---- dbms_output.put_line ('Create_items: closing cursor');

  IF (p_multi_org_flag = 'Y') THEN
      IF p_schedule_category = 'REVISION' THEN
          CLOSE C_ITEM_ORGS_REVISION;
      ELSE
          IF p_schedule_category = 'REBUILD' THEN
              CLOSE C_ITEM_NOORGS;
          ELSE
              CLOSE C_ITEM_ORGS;
          END IF;
      END IF;
  ELSE
    CLOSE C_ITEM_NOORGS;
  END IF;


  ---- dbms_output.put_line('Exiting creat_items');

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('create_items', x_progress, sqlcode);
    RAISE;


END create_items;

END CHV_BUILD_SCHEDULES;

/
