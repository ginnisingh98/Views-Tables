--------------------------------------------------------
--  DDL for Package Body OPIMXRU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPIMXRU" AS
/* $Header: OPIMXRUB.pls 115.4 2002/05/06 21:59:19 ltong noship $ */

PROCEDURE  extract_opi_res_util (p_from_date  DATE ,
				 p_to_date    DATE  )
  IS

     CURSOR  wip_used (l_uom_class VARCHAR2,
		       l_hr_base_rate NUMBER ) is
	SELECT
	  trunc(wt.transaction_date) ||'-'|| wt.organization_id ||'-'||
	      bd.department_id || '-' || wt.resource_id   res_util_pk,
	  br.resource_code,
	  mp.organization_code, wt.organization_id,
	  trunc(wt.transaction_date) trx_date,
	  bd.department_code,
	  To_number(hoi.org_information1) sob_id,
	  SUM(primary_quantity* m2.conversion_rate/l_hr_base_rate) act_res_usage
	  FROM
	  bom_resources                   br,
	  bom_departments                 bd,
	  bom_department_resources        bdr,
	  wip_transactions                wt,
	  mtl_parameters                  mp,
	  mtl_uom_conversions             m2,
	  HR_ORGANIZATION_INFORMATION     hoi
	  WHERE
	  -- 1->resource trx   3-> outside processing,
	  -- both involve resource, other types don't have resource_id
	  wt.transaction_type IN (1,3)
	  and wt.transaction_date >= trunc(p_from_date)
	  and wt.transaction_date < trunc(p_to_date+1)
	  AND wt.organization_id = mp.organization_id
	  AND bdr.department_id  = wt.department_id
	  AND bdr.resource_id    = wt.resource_id
	  AND bd.department_id   = Nvl(bdr.share_from_dept_id, bdr.department_id)
	  AND br.resource_id = wt.resource_id
	  AND m2.uom_code = wt.primary_uom
	  AND m2.inventory_item_id = 0
	  AND m2.uom_class = l_uom_class
	  AND hoi.organization_id = wt.organization_id
	  AND hoi.ORG_INFORMATION_CONTEXT = 'Accounting Information'
	  GROUP BY
	  wt.organization_id,
	  bd.department_id, -- owning dept
	  wt.resource_id,
	  trunc(wt.transaction_date),
	  mp.organization_code,
	  hoi.org_information1,
	  bd.department_code,
	  br.resource_code ;

     p_uom_class     VARCHAR2(10);
     l_count         NUMBER := 0;
     l_opi_schema      VARCHAR2(30);
     l_status          VARCHAR2(30);
     l_industry        VARCHAR2(30);
     p_hr_base_rate  NUMBER := 0;
     p_uom_code      VARCHAR2(10);


BEGIN

   --  --------------------------------------------------------
   --   get the uom_class
   --  --------------------------------------------------------
   --  --------------------------------------------------------
   --   get the conversion rate from 'BOM:HOUR_UOM_CODE' to its
   --   class uom
   --  --------------------------------------------------------
   SELECT uom_code, uom_class, conversion_rate
     INTO p_uom_code, p_uom_class, p_hr_base_rate
     FROM mtl_uom_conversions
     WHERE inventory_item_id = 0
     AND uom_code = fnd_profile.value('BOM:HOUR_UOM_CODE');

   --  --------------------------------------------------------
   --  Insert 24 hr available resource into the push_log table
   --      actual usage is 0
   --  --------------------------------------------------------
   insert into opi_edw_res_util_push_log
     ( res_util_pk, organization_code, resource_code,
       department_code, trx_date, sob_id,
       uom, act_res_usage, avail_res )
     SELECT  /*+ ALL_ROWS */
     Trunc(bcd.calendar_date) ||'-'|| mp.organization_id ||'-'||
        bd.department_id || '-' || br.resource_id,
     mp.organization_code, br.resource_code,
     bd.department_code, bcd.calendar_date, To_number(hoi.org_information1),
     p_uom_code,
     0,
     24* bdr.capacity_units
     FROM bom_resources              br,
     bom_departments                 bd,
     bom_department_resources        bdr,
     bom_calendar_dates              bcd,
     mtl_parameters                  mp,
     mtl_units_of_measure            m2,
     HR_ORGANIZATION_INFORMATION     hoi
     WHERE bdr.available_24_hours_flag = 1  -- 24 hr available
     AND bdr.share_from_dept_id IS NULL     -- owing dept
     AND br.resource_id = bdr.resource_id
     AND m2.uom_code = br.unit_of_measure
     AND m2.uom_class = p_uom_class
     AND bd.department_id = bdr.department_id
     AND bd.organization_id = mp.organization_id
     AND bcd.calendar_code  = mp.calendar_code
     AND bcd.exception_set_id = mp.calendar_exception_set_id
     AND bcd.seq_num IS NOT NULL           -- scheduled to be on
     and bcd.calendar_date >= Trunc(p_from_date)
     and bcd.calendar_date < Trunc(p_to_date+1)
     AND ( bd.disable_date IS NULL OR bcd.calendar_date < bd.disable_date)
     AND ( br.disable_date IS NULL OR bcd.calendar_date < br.disable_date)
     AND hoi.organization_id = mp.organization_id
     AND hoi.ORG_INFORMATION_CONTEXT = 'Accounting Information'
       ;

     edw_log.put_line('Inserting into push_log for 24 hr availalbe res count ' || SQL%rowcount);
     edw_log.put_line('system time is ' || To_char(Sysdate, 'MM/DD/YYYY HH24:MI:SS') );
     --  --------------------------------------------------------
     --  commit since there might be a large set data
     --  --------------------------------------------------------
     COMMIT;


     --  --------------------------------------------------------
     --  Insert shift based available resource into push log
     --  --------------------------------------------------------
     INSERT INTO opi_edw_res_util_push_log
       ( res_util_pk, organization_code, resource_code,
	 department_code, trx_date, sob_id,
	 uom, act_res_usage, avail_res )
       SELECT
       Trunc(bsd.shift_date) ||'-'|| mp.organization_id ||'-'||
          bd.department_id || '-' || br.resource_id        res_util_pk,
       mp.organization_code,  br.resource_code,
       bd.department_code, bsd.shift_date, To_number(hoi.org_information1),
       p_uom_code,
       0,
       SUM((bst.to_time - bst.from_time)/3600*bdr.capacity_units) avail_res
       FROM
       bom_resources                   br,
       bom_departments                 bd,
       bom_department_resources        bdr,
       bom_resource_shifts             brs,
       bom_shift_dates                 bsd,
       bom_shift_times                 bst,
       mtl_parameters                  mp,
       mtl_units_of_measure            m2,
       HR_ORGANIZATION_INFORMATION     hoi
       WHERE bdr.available_24_hours_flag = 2   -- shift based
       AND bdr.share_from_dept_id IS NULL      -- owning dept
       AND br.resource_id = bdr.resource_id
       AND m2.uom_code = br.unit_of_measure
     AND m2.uom_class = p_uom_class
     AND bd.department_id = bdr.department_id
     AND bd.organization_id = mp.organization_id
     AND brs.department_id = bd.department_id
     AND brs.resource_id   = br.resource_id
     AND bsd.calendar_code = mp.calendar_code
     AND bsd.exception_set_id = mp.calendar_exception_set_id
     AND bsd.shift_num     = brs.shift_num
     AND bsd.seq_num IS NOT NULL               -- schedule to be available
     AND bsd.shift_date >= Trunc(p_from_date)
     AND bsd.shift_date < Trunc(p_to_date + 1)
     AND ( bd.disable_date IS NULL OR bsd.shift_date < bd.disable_date)
     AND ( br.disable_date IS NULL OR bsd.shift_date < br.disable_date)
     AND bst.calendar_code = mp.calendar_code
     AND bst.shift_num     = brs.shift_num
     AND hoi.organization_id = mp.organization_id
     AND hoi.ORG_INFORMATION_CONTEXT = 'Accounting Information'
     GROUP BY
     mp.organization_id,
     bd.department_id, -- owning dept
     br.resource_id,
     bsd.shift_date,
     mp.organization_code,
     bd.department_code,
     br.unit_of_measure,
     br.resource_code,
     hoi.org_information1
     ;

     edw_log.put_line('Inserting into push_log for shift availalbe res count ' || SQL%rowcount);
     edw_log.put_line('system time is ' || To_char(Sysdate, 'MM/DD/YYYY HH24:MI:SS') );
     COMMIT;

     --  --------------------------------------------------------
     --  For the those resoruce actually used in WIP
     --  a). If records already exists in push_log, update it with
     --      the actual usage value
     --  b). If not already exists (those resource actually used but
     --      not scheduled to be available, create a new record
     --      in push log    avail_usage = actual_usage
     --
     --  Potentially, there can be millions records updated/inserted
     --  We need to periodically commit in order to prevent rbs from
     --  running out
     --  --------------------------------------------------------

     FOR  l_wip IN  wip_used(p_uom_class, p_hr_base_rate) LOOP
	UPDATE  opi_edw_res_util_push_log
	  SET  act_res_usage = l_wip.act_res_usage
	  WHERE  res_util_pk = l_wip.res_util_pk;

	IF  sql%rowcount = 0 THEN   -- not existed

	   INSERT  INTO  opi_edw_res_util_push_log
	     ( res_util_pk, organization_code, resource_code,
	       department_code, trx_date, sob_id,
	       uom, act_res_usage, avail_res )
	     values ( l_wip.res_util_pk, l_wip.organization_code, l_wip.resource_code,
		      l_wip.department_code, l_wip.trx_date, l_wip.sob_id,
		      p_uom_code, l_wip.act_res_usage, l_wip.act_res_usage );
	END IF;

	IF l_count = 10000 THEN
	   COMMIT;
	   l_count := 0;
	 ELSE
	   l_count := l_count + 1;
	END IF;

     END LOOP;

     edw_log.put_line('After WIP used res update /insert system time is ' || To_char(Sysdate, 'MM/DD/YYYY HH24:MI:SS') );

     COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      edw_log.put_line('Inserting into push log has failed. ');
      RAISE;

END extract_opi_res_util;

END opimxru;

/
