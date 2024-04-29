--------------------------------------------------------
--  DDL for Package Body MRP_EPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_EPI" AS
/* $Header: MRPCINVB.pls 120.3 2005/09/12 08:31:26 gmalhotr noship $  */
PROCEDURE inventory_turns(errbuf             OUT NOCOPY VARCHAR2, --2663505
		          retcode            OUT NOCOPY NUMBER,   --2663505
                          p_owning_org_id    IN NUMBER,
                          p_designator       IN VARCHAR2) IS

  CURSOR ORG_TYPE_C IS
  SELECT distinct code
  FROM mrp_srs_org_select_plan_v
  WHERE designator = p_designator
    AND ((code=2 AND org_id = p_owning_org_id)
        OR (code=1 AND planned_org=p_owning_org_id));

  CURSOR PLAN_BOUNDS_C(p_org_type IN NUMBER) IS
  SELECT trunc(plan.data_start_date), trunc(plan.cutoff_date)
  FROM mrp_plans plan,
        mrp_plan_organizations_v org
  WHERE DECODE(p_org_type, 1, org.planned_organization,
        org.organization_id) = p_owning_org_id
  AND org.compile_designator = p_designator
  AND org.organization_id = plan.organization_id
  AND org.compile_designator = plan.compile_designator;

  CURSOR PLAN_DATES_C(p_plan_start_date IN DATE, p_plan_end_date IN DATE) IS
  SELECT DECODE(LEAST(start_date,p_plan_start_date),start_date,
	p_plan_start_date,start_date) start_date,
	DECODE(GREATEST(end_date,p_plan_end_date),end_date,
	p_plan_end_date,end_date) end_date
  FROM gl_periods cal,
	org_organization_definitions org,
	gl_sets_of_books sb
  WHERE org.set_of_books_id = sb.set_of_books_id
  AND sb.period_set_name = cal.period_set_name
  AND sb.accounted_period_type = cal.period_type
  AND cal.adjustment_period_flag = 'N'
  AND org.organization_id = p_owning_org_id
  AND cal.end_date >= p_plan_start_date
  AND cal.start_date <= p_plan_end_date;

  CURSOR PLAN_ORGS_C(p_org_type IN NUMBER) IS
  SELECT pln_sched.input_designator_name,
	org_v.planned_organization
  FROM mrp_plan_organizations_v org_v,
	mrp_plan_schedules_v pln_sched
  WHERE pln_sched.input_organization_id = org_v.planned_organization
    AND pln_sched.compile_designator = org_v.compile_designator
    AND DECODE(p_org_type, 1, org_v.planned_organization,
	org_v.organization_id) = p_owning_org_id
    AND org_v.compile_designator = p_designator
    AND pln_sched.input_designator_type = 1;

  l_cursor              VARCHAR2(30);

  l_org_type            NUMBER;
  l_plan_start_date     DATE;
  l_plan_end_date       DATE;
  l_old_start_date     DATE;
  l_old_end_date       DATE;
  l_sched_name		VARCHAR2(30);
  l_org_id		NUMBER;

  l_count               NUMBER := 1;

BEGIN

  l_cursor := 'ORG_TYPE_C';
  OPEN ORG_TYPE_C;
  FETCH ORG_TYPE_C INTO l_org_type;
  CLOSE ORG_TYPE_C;

  l_cursor := 'PLAN_BOUNDS_C';
  OPEN PLAN_BOUNDS_C(l_org_type);
  FETCH PLAN_BOUNDS_C INTO l_plan_start_date, l_plan_end_date;
  CLOSE PLAN_BOUNDS_C;

  l_cursor := 'DELETE STATEMENTS';
  DELETE FROM mrp_bis_inv_detail
  WHERE compile_designator = p_designator;

  DELETE FROM mrp_bis_plan_profit
  WHERE compile_designator = p_designator;

  DELETE FROM mrp_bis_res_summary
  WHERE compile_designator = p_designator;

  l_cursor := 'INSERT STATEMENTS';
    -- Insert a row to store the beginning inventory values
      INSERT INTO mrp_bis_inv_detail
          (compile_designator,
          owning_org_id,
          organization_id,
          schedule_designator,
          detail_date,
          inventory_item_id,
          project_id,
          task_id,
          mds_quantity,
          inventory_quantity,
          snapshot_cost,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by)
      SELECT
                org.compile_designator,
                org.organization_id,
                org.planned_organization,
                pln_sched.input_designator_name,
                l_plan_start_date - 1,
                sys.inventory_item_id,
                NULL,
                NULL,
                NVL(past_due_mds(pln_sched.input_designator_name,
			org.planned_organization,
			sys.inventory_item_id,
			l_plan_start_date),0) *
			NVL(mrp_item_cost(sys.inventory_item_id,
			sys.organization_id),0),
                ((NVL(sys.nettable_inventory_quantity,0) +
                        NVL(sys.nonnettable_inventory_quantity,0) +
                        NVL(issued_values(
                                org.compile_designator,
                                org.planned_organization,
                                sys.inventory_item_id),0)) *
			NVL(mrp_item_cost(sys.inventory_item_id,
				sys.organization_id),0)) -
                (NVL(past_due_mds(pln_sched.input_designator_name,
                        org.planned_organization,
                        sys.inventory_item_id,
                        l_plan_start_date),0) *
                        NVL(mrp_item_cost(sys.inventory_item_id,
                        sys.organization_id),0)),
                NVL(mrp_item_cost(sys.inventory_item_id,
                        sys.organization_id),0),
                sysdate,
                1,
                sysdate,
                1
        FROM mrp_plan_schedules_v pln_sched,
                mrp_system_items sys,
                mrp_plan_organizations_v org
        WHERE sys.compile_designator = org.compile_designator
        AND sys.organization_id = org.planned_organization
        AND org.planned_organization = pln_sched.input_organization_id(+)
        AND org.compile_designator = pln_sched.compile_designator(+)
        AND pln_sched.input_designator_type(+) = 1
        AND DECODE(l_org_type,1,org.planned_organization,org.organization_id)
                = p_owning_org_id
        AND org.compile_designator = p_designator;

  l_old_start_date := l_plan_start_date-1;
  l_old_end_date := l_plan_start_date-1;

  commit work;
  FOR plan_dates_rec IN plan_dates_c(l_plan_start_date, l_plan_end_date)
  LOOP
    INSERT INTO mrp_bis_inv_detail
        (compile_designator,
        owning_org_id,
        organization_id,
        schedule_designator,
        detail_date,
        inventory_item_id,
        project_id,
        task_id,
        mds_quantity,
        inventory_quantity,
        snapshot_cost,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by)
    SELECT
        inv.compile_designator,
        inv.owning_org_id,
        inv.organization_id,
        inv.schedule_designator,
        plan_dates_rec.start_date,
        inv.inventory_item_id,
        inv.project_id,
        inv.task_id,
        NVL(SUM(NVL(dates.schedule_quantity,0)*inv.snapshot_cost),0),
        (NVL(inv.inventory_quantity,0) +
		NVL(inv_values(inv.compile_designator,
                inv.organization_id, inv.inventory_item_id,
                plan_dates_rec.start_date,plan_dates_rec.end_date),0) ),
        inv.snapshot_cost,
        sysdate,
        1,
        sysdate,
        1
    FROM mrp_schedule_dates dates,
        mrp_system_items sys,
        mrp_bis_inv_detail inv
    WHERE dates.rate_end_date IS NULL
    AND dates.schedule_date(+)
	between plan_dates_rec.start_date and plan_dates_rec.end_date
    AND dates.schedule_level(+) = 3
    AND dates.schedule_designator(+) = inv.schedule_designator
    AND dates.organization_id(+) = inv.organization_id
    AND dates.inventory_item_id(+) = inv.inventory_item_id
    AND sys.inventory_item_id = inv.inventory_item_id
    AND sys.organization_id = inv.organization_id
    AND sys.compile_designator = inv.compile_designator
    AND sys.repetitive_type = 1
    AND inv.detail_date between l_old_start_date and l_old_end_date
    AND inv.owning_org_id = p_owning_org_id
    AND inv.compile_designator = p_designator
    GROUP BY inv.compile_designator, inv.owning_org_id, inv.organization_id,
        inv.schedule_designator, inv.detail_date, inv.inventory_item_id,
        inv.project_id, inv.task_id, inv.snapshot_cost, inv.inventory_quantity
    UNION
    SELECT
        inv.compile_designator,
        inv.owning_org_id,
        inv.organization_id,
        inv.schedule_designator,
        cal.calendar_date,
        inv.inventory_item_id,
        inv.project_id,
        inv.task_id,
        NVL(SUM(NVL(dates.schedule_quantity,0)*inv.snapshot_cost),0),
        (NVL(inv.inventory_quantity,0) +
                NVL(inv_values(inv.compile_designator,
                        inv.organization_id, inv.inventory_item_id,
                        plan_dates_rec.start_date,plan_dates_rec.end_date),0)),
        inv.snapshot_cost,
        sysdate,
        1,
        sysdate,
        1
    FROM bom_calendar_dates cal,
        mtl_parameters mtl,
        mrp_schedule_dates dates,
        mrp_bis_inv_detail inv
    WHERE cal.calendar_date BETWEEN dates.schedule_date AND dates.rate_end_date
    AND   dates.rate_end_date is not null
    AND   cal.calendar_date
		between plan_dates_rec.start_date and plan_dates_rec.end_date
    AND   cal.seq_num IS NOT NULL
    AND   mtl.organization_id = inv.organization_id
    AND   mtl.calendar_exception_set_id = cal.exception_set_id
    AND   mtl.calendar_code = cal.calendar_code
    AND   dates.organization_id = inv.organization_id
    AND   dates.inventory_item_id = inv.inventory_item_id
    AND   dates.schedule_level = 3
    AND   dates.schedule_designator = inv.schedule_designator
    AND   inv.detail_date
		between l_old_start_date and l_old_end_date
    AND inv.owning_org_id = p_owning_org_id
    AND inv.compile_designator = p_designator
    GROUP BY inv.compile_designator, inv.owning_org_id, inv.organization_id,
        inv.schedule_designator, cal.calendar_date, inv.inventory_item_id,
        inv.project_id, inv.task_id, inv.snapshot_cost, inv.inventory_quantity;

    l_old_start_date := plan_dates_rec.start_date;
    l_old_end_date := plan_dates_rec.end_date;

    commit work;
  END LOOP;
-- ------------------------
-- Populate margin table
-- ------------------------
  l_cursor := 'PLAN_ORGS_C';
  OPEN PLAN_ORGS_C(l_org_type);
  LOOP
    FETCH PLAN_ORGS_C into l_sched_name, l_org_id;
    EXIT WHEN PLAN_ORGS_C%NOTFOUND;

    mrp_calculate_revenue(p_designator, l_sched_name, l_org_id,
			p_owning_org_id, l_plan_start_date,l_plan_end_date);

-- ------------------------
-- Populate resource table
-- ------------------------
  mrp_resource_util(p_designator, l_org_id, l_plan_start_date,
	l_plan_end_date);

  END LOOP;
  CLOSE PLAN_ORGS_C;

  COMMIT WORK;

  retcode := G_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
	errbuf := 'Error in mrp_epi.inventory_turns function' ||
				' Cursor: ' || l_cursor ||
				' SQL error: ' || sqlerrm;
	retcode := G_ERROR;

END inventory_turns;

FUNCTION mrp_item_selling_price(arg_item_id in number,
				 arg_org_id  in number,
				 arg_price_list_id in number default null,
				 arg_currency in varchar2 default null)
 RETURN NUMBER
 IS
	arg_price number;
 BEGIN
   select round(list_price *
	  (1 - (NVL(FND_PROFILE.Value_Specific('MRP_BIS_AV_DISCOUNT'),0)/100)),
		NVL(-spl.rounding_factor,2))
   into arg_price
   from oe_price_list_lines sopl,
	mtl_system_items msi,
        oe_price_lists spl
   where spl.price_list_id  = FND_PROFILE.Value_Specific('MRP_BIS_PRICE_LIST')
   and   sopl.price_list_id  = spl.price_list_id
   and   sopl.inventory_item_id = arg_item_id
   and   msi.inventory_item_id = arg_item_id
   and   msi.organization_id = arg_org_id
   and   nvl(sopl.unit_code,' ') = nvl(msi.primary_uom_code,' ')
   and   sysdate between nvl(sopl.start_date_active, sysdate-1)
		  and nvl(sopl.end_date_active, sysdate+1)
   and   rownum = 1;

    return arg_price;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   return mrp_epi.mrp_item_cost(arg_item_id, arg_org_id);
END mrp_item_selling_price;

-- New function for the APS
--     It's a copy from mrp_item_selling_price without the discount.
--     We want to make this function callable from a remote database,
-- so we don't use the profile option MRP_BIS_PRICE_LIST.
FUNCTION mrp_item_list_price(arg_item_id in number,
	                     arg_org_id  in number,
			     arg_price_list_id in number default null,
			     arg_currency in varchar2 default null)
 RETURN NUMBER
 IS
	arg_price number;
 BEGIN

   select round(list_price,NVL(spl.rounding_factor,2))
   into arg_price
   from oe_price_list_lines sopl,
	mtl_system_items msi,
	oe_price_lists spl
   where spl.price_list_id  = arg_price_list_id
   and   sopl.price_list_id  = spl.price_list_id
   and   sopl.inventory_item_id = arg_item_id
   and   msi.inventory_item_id = arg_item_id
   and   msi.organization_id = arg_org_id
   and   nvl(sopl.unit_code,' ') = nvl(msi.primary_uom_code,' ')
   and   sysdate between nvl(sopl.start_date_active, sysdate-1)
		  and nvl(sopl.end_date_active, sysdate+1)
   and   rownum = 1;

    return arg_price;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   return mrp_epi.mrp_item_cost(arg_item_id, arg_org_id);
END mrp_item_list_price;

FUNCTION mrp_item_cost(p_item_id in number,
			 p_org_id  in number)
RETURN NUMBER IS

  CURSOR COST_C IS
  SELECT NVL(cst.item_cost,0)
  FROM cst_cost_types cct,
	mtl_parameters mtl,
	cst_item_costs cst
  WHERE (cst.cost_type_id = cct.cost_type_id
        OR (cst.cost_type_id = cct.default_cost_type_id
        AND (NOT EXISTS (SELECT 'Primary Cost Type Row'
                        FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                          AND cst1.organization_id = cst.organization_id
                          AND cst1.cost_type_id = cct.cost_type_id))))
    AND cct.costing_method_type = mtl.primary_cost_method
    AND cct.cost_type_id = DECODE(mtl.primary_cost_method,1,1,2,2,1)
    AND mtl.organization_id = cst.organization_id
    AND cst.inventory_item_id = p_item_id
    AND cst.organization_id = p_org_id;

  l_cost	NUMBER;

BEGIN

  OPEN COST_C;
  FETCH COST_C into l_cost;
  CLOSE COST_C;

  RETURN(l_cost);

END mrp_item_cost;

FUNCTION mrp_resource_cost(p_item_id in number,
			 p_org_id  in number)
RETURN NUMBER IS

  CURSOR COST_C IS
  SELECT NVL(cst.tl_resource,0)
	+ NVL(cst.tl_overhead,0)
	+ NVL(cst.tl_material_overhead,0)
	+ NVL(cst.tl_outside_processing,0)
  FROM cst_cost_types cct,
	mtl_parameters mtl,
	cst_item_costs cst
  WHERE (cst.cost_type_id = cct.cost_type_id
        OR (cst.cost_type_id = cct.default_cost_type_id
        AND (NOT EXISTS (SELECT 'Primary Cost Type Row'
                        FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                          AND cst1.organization_id = cst.organization_id
                          AND cst1.cost_type_id = cct.cost_type_id))))
    AND cct.costing_method_type = mtl.primary_cost_method
    AND cct.cost_type_id = DECODE(mtl.primary_cost_method,1,1,2,2,1)
    AND mtl.organization_id = cst.organization_id
    AND cst.inventory_item_id = p_item_id
    AND cst.organization_id = p_org_id;

  l_cost	NUMBER;

BEGIN

  OPEN COST_C;
  FETCH COST_C into l_cost;
  CLOSE COST_C;

  RETURN(l_cost);

END mrp_resource_cost;

    /*--------------------------------------+
    |  Calculate value of master schedule   |
    +---------------------------------------*/
PROCEDURE mrp_calculate_revenue(plan_name          in   varchar2,
                                sched_name         in   varchar2,
                                p_org_id           in   number,
				p_owning_org_id    in   number,
				p_start_date       in   date,
				p_complete_date    in   date)
IS
  revenue       number;
  cost          number;

BEGIN

    /*------------------------------------------------------+
    |  Calculate value of master schedule, discrete items   |
    +------------------------------------------------------*/
    SELECT   NVL(SUM(NVL(dates.schedule_quantity,0) *
             mrp_item_selling_price(
                                 dates.inventory_item_id,
                                 dates.organization_id)), 0)
                      / 1000,
             NVL(SUM(NVL(dates.schedule_quantity,0) *
             mrp_item_cost(dates.inventory_item_id,
                                 dates.organization_id)), 0)
                      / 1000
    INTO   revenue, cost
            FROM  mrp_schedule_dates  dates,
                  mrp_system_items    sys
            WHERE dates.organization_id     = sys.organization_id
            AND   dates.inventory_item_id   = sys.inventory_item_id
            AND   dates.schedule_level      = 3
            AND   dates.schedule_designator = sched_name
            AND   sys.repetitive_type       = 1
            AND   sys.compile_designator    = plan_name
            AND   sys.organization_id       = p_org_id;

    /*------------------------------------------------------+
    |  Calculate value of master schedule, repetitive items |
    +------------------------------------------------------*/
SELECT     revenue +   NVL(SUM(dates.repetitive_daily_rate *
               mrp_item_selling_price(
                                 dates.inventory_item_id,
                                 dates.organization_id)), 0)
                     / 1000,
           cost +   NVL(SUM(NVL(dates.repetitive_daily_rate,0) *
               mrp_item_cost(dates.inventory_item_id,
                                 dates.organization_id)), 0)
                     / 1000
     INTO   revenue, cost
            FROM     bom_calendar_dates cal,
		     mrp_schedule_dates  dates,
                     mrp_system_items    sys,
		     mtl_parameters param
            WHERE    dates.organization_id     = sys.organization_id
            AND      dates.inventory_item_id   = sys.inventory_item_id
            AND      dates.schedule_level      = 3
            AND      dates.schedule_designator = sched_name
            AND      cal.calendar_date between
		     GREATEST(dates.schedule_date,p_start_date)
                     AND LEAST(dates.rate_end_date,p_complete_date -1)
            AND      cal.calendar_code = param.calendar_code
            AND      cal.exception_set_id = param.calendar_exception_set_id
	    AND      param.organization_id = sys.organization_id
            AND      sys.repetitive_type       = 2
            AND      sys.compile_designator    = plan_name
            AND      sys.organization_id       = p_org_id;

  INSERT into mrp_bis_plan_profit
        (compile_designator,
         organization_id,
         owning_org_id,
         schedule_designator,
         plan_cost,
         plan_revenue,
         last_update_date,
         last_updated_by,
         creation_date,
 	 created_by)
  VALUES (
        plan_name,
	p_org_id,
	p_owning_org_id,
	sched_name,
	cost,
	revenue,
	sysdate,
	1,
	sysdate,
	1);

END mrp_calculate_revenue;

PROCEDURE mrp_populate_fc_sum(ERRBUF OUT NOCOPY varchar2,  --2653505
				RETCODE OUT NOCOPY number, --2663505
				p_organization_id number,
                                p_from_forecast varchar2,
                                p_to_forecast varchar2,
                                p_from_date DATE,
                                p_to_date DATE) IS
BEGIN

   -- bug2384395
   -- before delete analyse mrp_bis_forecast
    BEGIN
    DBMS_STATS.gather_table_stats('MRP','MRP_BIS_FORECAST_WB', estimate_percent
=> 10, degree => 2, granularity => 'GLOBAL', cascade =>TRUE);
    EXCEPTION
    WHEN OTHERS THEN
     FND_FILE.put_line(fnd_file.log,'MRP_BIS_FORECAST_WB : '||sqlerrm(sqlcode));
    END;

  /*----------------------------------------------------------------+
   | Each run of the concurrent program repopulates the summary     |
   | table so delete the existing records.                          |
   +----------------------------------------------------------------*/
  DELETE FROM mrp_bis_forecast_wb
    WHERE organization_id = p_organization_id
    AND forecast_set between p_from_forecast and p_to_forecast
    AND forecast_date between p_from_date and p_to_date;

  -- bug2384395
 -- Drop indexes before insertion

  BEGIN
   ad_ddl.do_ddl( applsys_schema => 'APPLSYS',
                  application_short_name => 'MRP',
                  statement_type => AD_DDL.DROP_INDEX,
                  statement =>
                  'drop index MRP_BIS_FORECAST_WB_N1',
                  object_name => 'MRP_BIS_FORECAST_WB');
   --
  EXCEPTION
     WHEN OTHERS THEN
     FND_FILE.put_line(fnd_file.log,'Drop Index 1 Error : '||SQLERRM(sqlcode));
  END;
  --
   BEGIN
   ad_ddl.do_ddl( applsys_schema => 'APPLSYS',
                  application_short_name => 'MRP',
                  statement_type => AD_DDL.DROP_INDEX,
                  statement =>
                  'drop index MRP_BIS_FORECAST_WB_N2',
                  object_name => 'MRP_BIS_FORECAST_WB');

   --
  EXCEPTION
     WHEN OTHERS THEN
     FND_FILE.put_line(fnd_file.log,'Drop Index 2 Error : '||SQLERRM(sqlcode));
  END;

  /*----------------------------------------------------------------+
   | Insert forecast records this select statement retrieves the    |
   | all forecast records.  If there are orders on the day of the   |
   | forecast then it shows the orders against that forecast        |
   +----------------------------------------------------------------*/

/* 2169811 - SVAIDYAN : commented the cond. parend_demand_id is not null
   since this will be null in mtl_demand_omoe */

   INSERT INTO MRP_BIS_FORECAST_WB (
	organization_id,
	organization_code,
	organization_name,
	forecast_set,
	forecast,
	forecast_description,
	update_type,
	demand_class,
	category_set_id,
	category_set,
	category_id,
	category,
	category_description,
	product_family_id,
	product_family_number,
	product_family_desc,
	inventory_item_id,
	item_number,
	item_description,
	customer_class,
	customer_id,
	customer,
	ship_id,
	ship_to_address,
	ship_to_city,
	ship_to_state,
	ship_to_zip,
	bill_id,
	bill_to_address,
	bill_to_city,
	bill_to_state,
	bill_to_zip,
	forecast_date,
	forecast_quantity,
	order_quantity,
	shipped_quantity,
	forecast_amount,
	order_amount,
	shipped_amount,
	confidence_percentage)
  SELECT dates.organization_id,
        org.organization_code,
        org.organization_name,
        desig.forecast_set,
        NULL,					-- forecast
        NULL,					-- forecast description
        desig.update_type,
        desig.demand_class,
        scat.category_set_id,
        scat.category_set_name,
        cat.category_id,
        cat.concatenated_segments,
        vcat.description,
        DECODE(sys.bom_item_type,5,sys.inventory_item_id,
		NVL(sys2.inventory_item_id,sys3.inventory_item_id)),
        DECODE(sys.bom_item_type,5,sys.concatenated_segments,
		NVL(sys2.concatenated_segments,sys3.concatenated_segments)),
        DECODE(sys.bom_item_type,5,sys.description,
		DECODE(sys2.inventory_item_id,NULL,sys3.description,
		sys2.description)),
        sys.inventory_item_id,
        sys.concatenated_segments,
        sys.description,
        ar.meaning,
        desig.customer_id,
        PART.party_name,
        desig.ship_id,
        LOC2.address1,
        LOC2.city,
        LOC2.state,
        LOC2.postal_code,
        desig.bill_id,
        LOC1.address1,
        LOC1.city,
        LOC1.state,
        LOC1.postal_code,
        cal.calendar_date,
        dates.original_forecast_quantity,
        sum(md.primary_uom_quantity),
        sum(md.completed_quantity),
        dates.original_forecast_quantity *
                mrp_epi.mrp_item_selling_price(dates.inventory_item_id,
                dates.organization_id),
        sum(md.primary_uom_quantity) *
                mrp_epi.mrp_item_selling_price(dates.inventory_item_id,
                dates.organization_id),
        sum(md.completed_quantity) *
                mrp_epi.mrp_item_selling_price(dates.inventory_item_id,
                dates.organization_id),
        avg(dates.confidence_percentage)
  FROM org_organization_definitions org,
       fnd_lookup_values ar,
        --ar_lookups ar, --bug2384395
        HZ_PARTIES PART,   /*bug4434875*/
        HZ_CUST_ACCOUNTS CA,
        HZ_CUST_ACCT_SITES_ALL  AS1,
        HZ_CUST_ACCT_SITES_ALL  AS2,
        HZ_PARTY_SITES  PS1,
        HZ_PARTY_SITES  PS2,
        HZ_LOCATIONS LOC1 ,
        HZ_LOCATIONS LOC2 ,
        HZ_CUST_SITE_USES_ALL  SU1 ,
        HZ_CUST_SITE_USES_ALL  SU2 ,
        mtl_category_sets scat,
        mtl_categories_kfv cat,
        mtl_categories_vl vcat,
        mtl_item_categories icat,
        bom_calendar_dates cal,
        mtl_parameters mp,
        mtl_system_items_kfv sys3,
        mtl_system_items_kfv sys2,
        mtl_system_items_kfv sys,
        (SELECT inventory_item_id,
           ship_from_org_id organization_id,
           schedule_ship_date requirement_date,
           sold_to_org_id customer_id,
           demand_class_code demand_class,
           ship_to_org_id ship_to_site_use_id,
           invoice_to_org_id bill_to_site_use_id,
           SUM(DECODE(ool.ordered_quantity,
                      NULL, 0,
                            inv_decimals_pub.get_primary_quantity(ool.ship_from_org_id,
                                 ool.inventory_item_id,
                                 ool.order_quantity_uom,
                                 ool.ordered_quantity))) primary_uom_quantity,
           SUM(DECODE(OOL.SHIPPED_QUANTITY,
                            NULL, 0,
                            inv_decimals_pub.get_primary_quantity(ool.ship_from_org_id,
                                 ool.inventory_item_id,
                                 ool.order_quantity_uom,
                                 ool.shipped_quantity))) completed_quantity
           FROM oe_order_lines_all ool
           WHERE DECODE(ool.source_document_type_id,
                      10, 8, DECODE(ool.line_category_code, 'ORDER', 2, 12)) in (2,8)
           GROUP BY inventory_item_id,ship_from_org_id,schedule_ship_date,
                sold_to_org_id,demand_class_code, ship_to_org_id,invoice_to_org_id) md,
        mrp_forecast_designators desig,
        ( SELECT
           forecast_designator,
           organization_id,
           sum(original_forecast_quantity) original_forecast_quantity,
           inventory_item_id,
           confidence_percentage,
           bucket_type,
           forecast_date,
           rate_end_date,
           ship_id
          FROM mrp_forecast_dates
          GROUP BY forecast_designator, organization_id,
           inventory_item_id,
           confidence_percentage,
           bucket_type,
           forecast_date,
           rate_end_date,
           ship_id) dates
  WHERE    PART.party_id (+) = CA.party_id
    AND    org.organization_id = desig.organization_id
    AND     ar.lookup_type(+) = 'CUSTOMER CLASS'
    AND     ar.lookup_code(+) = CA.customer_class_code
    AND     ar.LANGUAGE(+) = userenv('LANG')
    and     ar.VIEW_APPLICATION_ID(+) = 222
    and     ar.SECURITY_GROUP_ID(+) = fnd_global.lookup_security_group('CUSTOMER CLASS', 222)
    AND     CA.cust_account_id(+) = desig.customer_id
    AND     SU1.cust_acct_site_id = AS1.cust_acct_site_id(+)
    AND     AS1.party_site_id     = PS1.party_site_id(+)
    AND     PS1.location_id       = LOC1.location_id(+)
    AND     SU1.site_use_code(+) = 'BILL_TO'
    AND     SU1.site_use_id(+) = desig.bill_id
    AND     SU2.cust_acct_site_id = AS2.cust_acct_site_id(+)
    AND     AS2.party_site_id     = PS2.party_site_id(+)
    AND     PS2.location_id       = LOC2.location_id(+)
    AND     SU2.site_use_code(+) = 'SHIP_TO'
    AND     SU2.site_use_id(+) = desig.ship_id
    AND     cat.category_id = icat.category_id
    AND     vcat.category_id = icat.category_id
    AND     vcat.structure_id=scat.structure_id
    AND     scat.category_set_id = (SELECT category_set_id
                FROM mtl_default_category_sets
                WHERE functional_area_id = 1)
    AND     icat.category_set_id = scat.category_set_id
    AND     icat.inventory_item_id = dates.inventory_item_id
    AND     icat.organization_id = dates.organization_id
    AND     ((dates.bucket_type = 1)
        OR (dates.bucket_type = 2 AND cal.calendar_date IN
                (SELECT week_start_date
                FROM bom_cal_week_start_dates
                WHERE week_start_date BETWEEN dates.forecast_date AND
                        NVL(dates.rate_end_date,dates.forecast_date)
                AND calendar_code = cal.calendar_code
                AND exception_set_id = cal.exception_set_id))
        OR (dates.bucket_type = 3 AND cal.calendar_date IN
                (SELECT period_start_date
                FROM bom_period_start_dates
                WHERE period_start_date BETWEEN dates.forecast_date AND
                        NVL(dates.rate_end_date,dates.forecast_date)
                AND calendar_code = cal.calendar_code
                AND exception_set_id = cal.exception_set_id)))
    AND     ((dates.bucket_type = 1 AND cal.calendar_date =
                     md.requirement_date)
        OR (dates.bucket_type = 2 AND to_char(md.requirement_date,'WWYYYY') =
                   to_char(calendar_date,'WWYYYY'))
        OR (dates.bucket_type = 3 AND to_char(md.requirement_date,'MMYYYY') =
                   to_char(calendar_date,'MMYYYY')))
    AND     cal.calendar_date BETWEEN dates.forecast_date
        AND NVL(dates.rate_end_date,dates.forecast_date)
    AND     cal.seq_num IS NOT NULL
    AND     cal.exception_set_id = mp.calendar_exception_set_id
    AND     cal.calendar_code = mp.calendar_code
    AND     mp.organization_id = sys.organization_id
    AND     sys3.organization_id(+) = sys.organization_id
    AND     sys3.inventory_item_id(+) = sys.base_item_id
    AND     sys2.organization_id(+) = sys.organization_id
    AND     sys2.inventory_item_id(+) = sys.product_family_item_id
    AND     sys.organization_id = dates.organization_id
    AND     sys.inventory_item_id = dates.inventory_item_id
    AND     DECODE(desig.update_type,2,
                NVL(md.ship_to_site_use_id,NVL(dates.ship_id,-1)),-1)
                = NVL(dates.ship_id,-1)
    AND     DECODE(desig.update_type,3,
                NVL(md.bill_to_site_use_id,NVL(desig.bill_id,-1)),-1)
                = NVL(desig.bill_id,-1)
    AND     DECODE(desig.update_type,4,
                NVL(md.customer_id,NVL(desig.customer_id,-1)),-1)
                = NVL(desig.customer_id,-1)
    AND     DECODE(desig.demand_class,NULL,NVL(desig.demand_class,'@@@'),
		NVL(md.demand_class,mp.default_demand_class))
                = NVL(desig.demand_class,'@@@')
    AND     md.inventory_item_id = dates.inventory_item_id
    AND     md.organization_id = dates.organization_id
    AND     desig.forecast_set IS NOT NULL
    AND     dates.organization_id = desig.organization_id
    AND     dates.forecast_designator = desig.forecast_designator
    AND     desig.organization_id = p_organization_id
    AND     desig.forecast_set between p_from_forecast and p_to_forecast
    AND     dates.forecast_date between p_from_date and p_to_date
    AND     NVL(dates.rate_end_date,p_from_date)
		between p_from_date and p_to_date
    AND NVL(desig.disable_date,p_to_date + 1) > p_to_date  /*2560013*/
  GROUP BY dates.organization_id, org.organization_code, org.organization_name,
        desig.forecast_set, desig.update_type, desig.demand_class,
        scat.category_set_id, scat.category_set_name, cat.category_id,
        cat.concatenated_segments, vcat.description, sys.bom_item_type,
        NVL(sys2.inventory_item_id,sys3.inventory_item_id),
        NVL(sys2.concatenated_segments,sys3.concatenated_segments),
        sys2.description, sys3.description, sys.inventory_item_id,
	sys.concatenated_segments, dates.inventory_item_id,
        DECODE(sys.bom_item_type,5,sys.inventory_item_id,
		NVL(sys2.inventory_item_id,sys3.inventory_item_id)),
        DECODE(sys.bom_item_type,5,sys.concatenated_segments,
		NVL(sys2.concatenated_segments,sys3.concatenated_segments)),
        DECODE(sys.bom_item_type,5,sys.description,
		DECODE(sys2.inventory_item_id,NULL,sys3.description,
		sys2.description)),
        sys.description, ar.meaning, desig.customer_id, PART.party_name,
        desig.ship_id, LOC2.address1, LOC2.city, LOC2.state, LOC2.postal_code,
        desig.bill_id, LOC1.address1, LOC1.city, LOC1.state, LOC1.postal_code,
        cal.calendar_date,dates.original_forecast_quantity, dates.original_forecast_quantity *
                mrp_epi.mrp_item_selling_price(dates.inventory_item_id,
                dates.organization_id);

  -- bug2384395
   -- Create Indexes after first insert
  BEGIN
   ad_ddl.do_ddl( applsys_schema => 'APPLSYS',
                           application_short_name => 'MRP',
                           statement_type => AD_DDL.CREATE_INDEX,
                           statement =>
                 'create index MRP_BIS_FORECAST_WB_N1'
              ||' on MRP_BIS_FORECAST_WB '
              ||'(ORGANIZATION_ID, INVENTORY_ITEM_ID,FORECAST_DATE)'
              ||' STORAGE (INITIAL 40K NEXT 2520K PCTINCREASE 50) ',
                           object_name =>'MRP_BIS_FORECAST_WB');
   EXCEPTION
    WHEN OTHERS THEN
     FND_FILE.put_line(fnd_file.log,'Create Index 1 Error : '||SQLERRM(sqlcode))
;
  END;

   BEGIN
   ad_ddl.do_ddl( applsys_schema => 'APPLSYS',
                           application_short_name => 'MRP',
                           statement_type => AD_DDL.CREATE_INDEX,
                           statement =>
                 'create index MRP_BIS_FORECAST_WB_N2'
              ||' on MRP_BIS_FORECAST_WB '
              ||'(ORGANIZATION_NAME, FORECAST_SET)'
              ||' STORAGE (INITIAL 40K NEXT 3784K PCTINCREASE 50) ',
                           object_name =>'MRP_BIS_FORECAST_WB');
   EXCEPTION
    WHEN OTHERS THEN
   FND_FILE.put_line(fnd_file.log,'Create Index 2 Error : '||SQLERRM(sqlcode));
  END;

  /*---------------------------------------------------------------------+
   | Corner-case to catch records that match with order on everything    |
   | except demand_class or customer info.  This statement gets the      |
   | forecast records that are excluded because the join to mtl_demand   |
   | is false.                                                           |
   +---------------------------------------------------------------------*/

 INSERT INTO MRP_BIS_FORECAST_WB (
	organization_id,
	organization_code,
	organization_name,
	forecast_set,
	forecast,
	forecast_description,
	update_type,
	demand_class,
	category_set_id,
	category_set,
	category_id,
	category,
	category_description,
	product_family_id,
	product_family_number,
	product_family_desc,
	inventory_item_id,
	item_number,
	item_description,
	customer_class,
	customer_id,
	customer,
	ship_id,
	ship_to_address,
	ship_to_city,
	ship_to_state,
	ship_to_zip,
	bill_id,
	bill_to_address,
	bill_to_city,
	bill_to_state,
	bill_to_zip,
	forecast_date,
	forecast_quantity,
	order_quantity,
	shipped_quantity,
	forecast_amount,
	order_amount,
	shipped_amount,
	confidence_percentage)
  SELECT org.organization_id,
        org.organization_code,
        org.organization_name,
        desig.forecast_set,
        NULL,					-- forecast
        NULL,					-- forecast description
        desig.update_type,
        desig.demand_class,
        scat.category_set_id,
        scat.category_set_name,
        cat.category_id,
        cat.concatenated_segments,
        vcat.description,
        DECODE(sys.bom_item_type,5,sys.inventory_item_id,
		NVL(sys2.inventory_item_id,sys3.inventory_item_id)),
        DECODE(sys.bom_item_type,5,sys.concatenated_segments,
		NVL(sys2.concatenated_segments,sys3.concatenated_segments)),
        DECODE(sys.bom_item_type,5,sys.description,
		DECODE(sys2.inventory_item_id,NULL,sys3.description,
		sys2.description)),
        sys.inventory_item_id,
        sys.concatenated_segments,
        sys.description,
        ar.meaning,
        desig.customer_id,
        PART.party_name,
        desig.ship_id,
        LOC2.address1,
        LOC2.city,
        LOC2.state,
        LOC2.postal_code,
        desig.bill_id,
        LOC1.address1,
        LOC1.city,
        LOC1.state,
        LOC1.postal_code,
        cal.calendar_date,
        dates.original_forecast_quantity,
        0,
        0,
        dates.original_forecast_quantity *
                mrp_epi.mrp_item_selling_price(dates.inventory_item_id,
                dates.organization_id),
	0,
	0,
        dates.confidence_percentage
  FROM org_organization_definitions org,
        fnd_lookup_values ar,
        --ar_lookups ar, --bug2384395
        HZ_PARTIES PART,     /*bug4434875*/
        HZ_CUST_ACCOUNTS CA,
        HZ_CUST_ACCT_SITES_ALL  AS1,
        HZ_CUST_ACCT_SITES_ALL  AS2,
        HZ_PARTY_SITES  PS1,
        HZ_PARTY_SITES  PS2,
        HZ_LOCATIONS LOC1 ,
        HZ_LOCATIONS LOC2 ,
        HZ_CUST_SITE_USES_ALL  SU1 ,
        HZ_CUST_SITE_USES_ALL  SU2 ,
        mtl_category_sets scat,
        mtl_categories_kfv cat,
	mtl_categories_vl vcat,
        mtl_item_categories icat,
        bom_calendar_dates cal,
        mtl_parameters mp,
        mtl_system_items_kfv sys3,
        mtl_system_items_kfv sys2,
        mtl_system_items_kfv sys,
        mrp_forecast_designators desig,
        mrp_forecast_dates dates
  WHERE PART.party_id (+) = CA.party_id
    AND org.organization_id = desig.organization_id
    AND ar.lookup_type(+) = 'CUSTOMER CLASS'
    AND ar.lookup_code(+) = CA.customer_class_code
    -- bug2384395
    AND     ar.LANGUAGE(+) = userenv('LANG')
    and     ar.VIEW_APPLICATION_ID(+) = 222
    and     ar.SECURITY_GROUP_ID(+) =  fnd_global.lookup_security_group('CUSTOMER CLASS', 222)
    AND     CA.cust_account_id(+) = desig.customer_id
    AND     SU1.cust_acct_site_id = AS1.cust_acct_site_id(+)
    AND     AS1.party_site_id     = PS1.party_site_id(+)
    AND     PS1.location_id       = LOC1.location_id(+)
    AND     SU1.site_use_code(+) = 'BILL_TO'
    AND     SU1.site_use_id(+) = desig.bill_id
    AND     SU2.cust_acct_site_id = AS2.cust_acct_site_id(+)
    AND     AS2.party_site_id     = PS2.party_site_id(+)
    AND     PS2.location_id       = LOC2.location_id(+)
    AND     SU2.site_use_code(+) = 'SHIP_TO'
    AND     SU2.site_use_id(+) = desig.ship_id
    AND     cat.category_id = icat.category_id
    AND     vcat.category_id=icat.category_id
    AND     vcat.structure_id=scat.structure_id
    AND     scat.category_set_id = (SELECT category_set_id
                FROM mtl_default_category_sets
                WHERE functional_area_id = 1)
    AND     icat.category_set_id = scat.category_set_id
    AND     icat.inventory_item_id = dates.inventory_item_id
    AND     icat.organization_id = dates.organization_id
    AND     sys3.organization_id(+) = sys.organization_id
    AND     sys3.inventory_item_id(+) = sys.base_item_id
    AND     sys2.organization_id(+) = sys.organization_id
    AND     sys2.inventory_item_id(+) = sys.product_family_item_id
    AND     sys.organization_id = dates.organization_id
    AND     sys.inventory_item_id = dates.inventory_item_id
    AND     ((dates.bucket_type = 1)
        OR (dates.bucket_type = 2 AND cal.calendar_date IN
                (SELECT week_start_date
                FROM bom_cal_week_start_dates
                WHERE week_start_date BETWEEN dates.forecast_date AND
                        NVL(dates.rate_end_date,dates.forecast_date)
                AND calendar_code = cal.calendar_code
                AND exception_set_id = cal.exception_set_id))
        OR (dates.bucket_type = 3 AND cal.calendar_date IN
                (SELECT period_start_date
                FROM bom_period_start_dates
                WHERE period_start_date BETWEEN dates.forecast_date AND
                        NVL(dates.rate_end_date,dates.forecast_date)
                AND calendar_code = cal.calendar_code
                AND exception_set_id = cal.exception_set_id)))
    AND     cal.calendar_date BETWEEN dates.forecast_date
        AND NVL(dates.rate_end_date,dates.forecast_date)
    AND     cal.seq_num IS NOT NULL
    AND     cal.exception_set_id = mp.calendar_exception_set_id
    AND     cal.calendar_code = mp.calendar_code
    AND     mp.organization_id = dates.organization_id
    AND     desig.forecast_set IS NOT NULL
    AND     dates.organization_id = desig.organization_id
    AND     dates.forecast_designator = desig.forecast_designator
    AND     desig.organization_id = p_organization_id
    AND     desig.forecast_set between p_from_forecast and p_to_forecast
    AND     dates.forecast_date between p_from_date and p_to_date
    AND     NVL(dates.rate_end_date,p_from_date)
		between p_from_date and p_to_date
    AND NVL(desig.disable_date,p_to_date + 1) > p_to_date /*2560013*/
    AND     NOT EXISTS (SELECT 'x'
                FROM mrp_bis_forecast_wb
                WHERE inventory_item_id = dates.inventory_item_id
                  AND organization_id = dates.organization_id
                  AND forecast_set = desig.forecast_set
                  AND DECODE(update_type,2, NVL(desig.ship_id,-1),-1)
                        = DECODE(update_type,2,NVL(ship_id,-1),-1)
                  AND DECODE(update_type,3, NVL(desig.bill_id,-1),-1)
                        = DECODE(update_type,3,NVL(bill_id,-1),-1)
                  AND DECODE(update_type,4, NVL(desig.customer_id,-1),-1)
                        = DECODE(update_type,4, NVL(customer_id,-1),-1)
                  AND NVL(demand_class,'@@@') = NVL(desig.demand_class,'@@@')
                  AND forecast_date = cal.calendar_date);

  /*-------------------------------------------------------------------+
   | Insert a record for orders that were not forecast                 |
   +-------------------------------------------------------------------*/

/* 2169811 - SVAIDYAN : commented the cond. parend_demand_id is not null
   since this will be null in mtl_demand_omoe. Also added the select of
   inventory_item_id for wb and the cond.
   md.inventory_item_id = wb.inventory_item_id Without this change, it will
   show the actual quantity as the sum of actual quantity of all sales orders
   for all items in all forecasts against each forecast. */

 INSERT INTO MRP_BIS_FORECAST_WB (
	organization_id,
	organization_code,
	organization_name,
	forecast_set,
	forecast,
	forecast_description,
	update_type,
	demand_class,
	category_set_id,
	category_set,
	category_id,
	category,
	category_description,
	product_family_id,
	product_family_number,
	product_family_desc,
	inventory_item_id,
	item_number,
	item_description,
	customer_class,
	customer_id,
	customer,
	ship_id,
	ship_to_address,
	ship_to_city,
	ship_to_state,
	ship_to_zip,
	bill_id,
	bill_to_address,
	bill_to_city,
	bill_to_state,
	bill_to_zip,
	forecast_date,
	forecast_quantity,
	order_quantity,
	shipped_quantity,
	forecast_amount,
	order_amount,
	shipped_amount,
	confidence_percentage)
  SELECT wb.organization_id,
        wb.organization_code,
        wb.organization_name,
        wb.forecast_set,
        NULL,				-- forecast
        NULL,				-- forecast description
        wb.update_type,
        md.demand_class,
        scat.category_set_id,
        scat.category_set_name,
        cat.category_id,
        cat.concatenated_segments,
        vcat.description,
        DECODE(sys.bom_item_type,5,sys.inventory_item_id,
		NVL(sys2.inventory_item_id,sys3.inventory_item_id)),
        DECODE(sys.bom_item_type,5,sys.concatenated_segments,
		NVL(sys2.concatenated_segments,sys3.concatenated_segments)),
        DECODE(sys.bom_item_type,5,sys.description,
		DECODE(sys2.inventory_item_id,NULL,sys3.description,
		sys2.description)),
        sys.inventory_item_id,
        sys.concatenated_segments,
        sys.description,
        ar.meaning,
        DECODE(wb.update_type,4,md.customer_id,NULL),
        PART.party_name,
        DECODE(wb.update_type,4,md.ship_to_site_use_id,2,md.ship_to_site_use_id,NULL),
        LOC2.address1,
        LOC2.city,
        LOC2.state,
        LOC2.postal_code,
        DECODE(wb.update_type,4,md.bill_to_site_use_id,2,md.bill_to_site_use_id,NULL),
        LOC1.address1,
        LOC1.city,
        LOC1.state,
        LOC1.postal_code,
        md.requirement_date,
        0,
        md.primary_uom_quantity,
        md.completed_quantity,
        0,
        md.primary_uom_quantity *
                mrp_epi.mrp_item_selling_price(md.inventory_item_id,
                md.organization_id),
        md.completed_quantity *
                mrp_epi.mrp_item_selling_price(md.inventory_item_id,
                md.organization_id),
        0
  FROM
       fnd_lookup_values ar,
        --ar_lookups ar, --bug2384395
        HZ_PARTIES PART,
        HZ_CUST_ACCOUNTS CA,
        HZ_CUST_ACCT_SITES_ALL  AS1,
        HZ_CUST_ACCT_SITES_ALL  AS2,
        HZ_PARTY_SITES  PS1,
        HZ_PARTY_SITES  PS2,
        HZ_LOCATIONS LOC1 ,
        HZ_LOCATIONS LOC2 ,
        HZ_CUST_SITE_USES_ALL  SU1 ,
        HZ_CUST_SITE_USES_ALL  SU2 ,
        mtl_category_sets scat,
        mtl_categories_kfv cat,
        mtl_categories_vl vcat,
        mtl_item_categories icat,
        mtl_system_items_kfv sys3,
        mtl_system_items_kfv sys2,
        mtl_system_items_kfv sys,
        mtl_parameters param,
        (SELECT distinct organization_id, organization_code, organization_name,
		update_type, forecast_set, inventory_item_id
        FROM mrp_bis_forecast_wb
        WHERE organization_id = p_organization_id
          AND forecast_set between p_from_forecast and p_to_forecast
          AND forecast_date between p_from_date and p_to_date) wb,
        mtl_demand_omoe md
  WHERE     PART.party_id (+)= CA.party_id
    AND     ar.lookup_type(+) = 'CUSTOMER_CLASS'
    AND     ar.lookup_code(+) = CA.customer_class_code
    -- bug2384395
    AND     ar.LANGUAGE(+) = userenv('LANG')
    and     ar.VIEW_APPLICATION_ID(+) = 222
    and     ar.SECURITY_GROUP_ID(+) = fnd_global.lookup_security_group('CUSTOMER CLASS', 222)
    AND     CA.cust_account_id(+) = md.customer_id
    AND     SU1.cust_acct_site_id = AS1.cust_acct_site_id(+)
    AND     AS1.party_site_id     = PS1.party_site_id(+)
    AND     PS1.location_id       = LOC1.location_id(+)
    AND     SU1.site_use_code(+) = 'BILL_TO'
    AND     SU1.site_use_id(+) = md.bill_to_site_use_id
    AND     SU2.cust_acct_site_id = AS2.cust_acct_site_id(+)
    AND     AS2.party_site_id     = PS2.party_site_id(+)
    AND     PS2.location_id       = LOC2.location_id(+)
    AND     SU2.site_use_code(+) = 'SHIP_TO'
    AND     SU2.site_use_id(+) = md.ship_to_site_use_id
    AND     cat.category_id = icat.category_id
    AND     vcat.category_id = icat.category_id
    AND     vcat.structure_id=scat.structure_id
    AND     scat.category_set_id = (SELECT category_set_id
                FROM mtl_default_category_sets
                WHERE functional_area_id = 1)
    AND     icat.category_set_id = scat.category_set_id
    AND     icat.inventory_item_id = md.inventory_item_id
    AND     icat.organization_id = md.organization_id
    AND     sys3.organization_id(+) = sys.organization_id
    AND     sys3.inventory_item_id(+) = sys.base_item_id
    AND     sys2.organization_id(+) = sys.organization_id
    AND     sys2.inventory_item_id(+) = sys.product_family_item_id
    AND     sys.organization_id = md.organization_id
    AND     sys.inventory_item_id = md.inventory_item_id
    AND     param.organization_id = md.organization_id
    AND     md.reservation_type = 1
    AND     md.demand_source_type in (2,8)
    AND	    md.primary_uom_quantity <> 0
    AND     md.organization_id = wb.organization_id
    AND     md.inventory_item_id = wb.inventory_item_id
    AND     md.requirement_date between p_from_date and p_to_date
    AND     NOT EXISTS (SELECT 'x'
                FROM mrp_bis_forecast_wb
                WHERE inventory_item_id = md.inventory_item_id
                  AND organization_id = md.organization_id
                  AND forecast_set = wb.forecast_set
                  AND organization_id = wb.organization_id
                  AND DECODE(update_type,2,
                        NVL(md.ship_to_site_use_id,NVL(ship_id,-1)),-1)
                        = NVL(ship_id,-1)
                  AND DECODE(update_type,3,
                        NVL(md.bill_to_site_use_id,NVL(bill_id,-1)),-1)
                        = NVL(bill_id,-1)
                  AND DECODE(update_type,4,
                        NVL(md.customer_id,NVL(customer_id,-1)),-1)
                        = NVL(customer_id,-1)
                  AND DECODE(demand_class,NULL,NVL(demand_class,'@@@'),
			NVL(md.demand_class,param.default_demand_class))
                        = NVL(demand_class,'@@@')
                  AND forecast_date = md.requirement_date);

  COMMIT WORK;

  RETCODE := G_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ERRBUF := 'Error: unable to update forecast workbook summary table' ||
				' SQL error: ' || sqlerrm;
    RETCODE := G_ERROR;

END mrp_populate_fc_sum;

FUNCTION past_due_mds(p_designator IN VARCHAR2, p_org_id IN NUMBER,
        p_item_id IN NUMBER, p_date IN DATE) RETURN NUMBER IS

  CURSOR MDS_C IS
  SELECT SUM(NVL(schedule_quantity,0))
  FROM mrp_schedule_dates
  WHERE schedule_designator = p_designator
    AND schedule_level = 3
    AND organization_id = p_org_id
    AND inventory_item_id = p_item_id
    AND schedule_date < p_date;

  l_mds		NUMBER;

BEGIN

  OPEN MDS_C;
  FETCH MDS_C into l_mds;
  CLOSE MDS_C;

  RETURN l_mds;

END past_due_mds;

FUNCTION issued_values(p_designator IN VARCHAR2, p_org_id IN NUMBER,
        p_item_id IN NUMBER) RETURN NUMBER IS

  CURSOR ISSUED_VALUES_C IS
  SELECT NVL(SUM(NVL(wip.quantity_issued,0)),0)
  FROM mrp_wip_components wip
  WHERE wip.compile_designator = p_designator
  AND   wip.organization_id = p_org_id
  AND   wip.wip_entity_type in (1,3)
  AND   DECODE(wip.wip_entity_type,1,1,wip.supply_demand_type) =
                DECODE(wip.wip_entity_type,1,1,1)
  AND   wip.inventory_item_id = p_item_id;

  l_issued      NUMBER;

BEGIN

  OPEN ISSUED_VALUES_C;
  FETCH ISSUED_VALUES_C INTO l_issued;
  CLOSE ISSUED_VALUES_C;

  RETURN l_issued;

END issued_values;

FUNCTION inv_values(p_designator IN VARCHAR2, p_org_id IN NUMBER,
        p_item_id IN NUMBER, p_start_date IN DATE,
	p_end_date IN DATE) RETURN NUMBER IS

  CURSOR INV_VALUES_C1 IS
  SELECT NVL(SUM(NVL(rec.new_order_quantity,0)),0) *
	mrp_item_cost(rec.inventory_item_id, rec.organization_id)
  FROM mrp_system_items msi,
       mrp_recommendations rec
  WHERE rec.disposition_status_type = 1
    AND TRUNC(rec.new_schedule_date) between p_start_date and p_end_date
    AND rec.order_type in (1,2,5,8)
    AND msi.planning_make_buy_code = 2
    AND msi.organization_id = rec.organization_id
    AND msi.inventory_item_id = rec.inventory_item_id
    AND msi.compile_designator = rec.compile_designator
    AND rec.compile_designator = p_designator
    AND rec.organization_id = p_org_id
    AND rec.inventory_item_id = p_item_id
  GROUP BY rec.inventory_item_id, rec.organization_id;

/** Bug 2416975 : Replaced the function mrp_resource_cost with
    mrp_item_cost **/
  CURSOR INV_VALUES_C2 IS
  SELECT NVL(SUM(DECODE(order_type,4,NVL(rec.daily_rate,0),
        NVL(rec.new_order_quantity,0))),0) *
	mrp_item_cost(rec.inventory_item_id, rec.organization_id)
  FROM bom_calendar_dates cal,
	mtl_parameters mtl,
	mrp_system_items msi,
       	mrp_recommendations rec
  WHERE rec.disposition_status_type = 1
    AND ((calendar_date = TRUNC(rec.new_wip_start_date)
        AND rec.order_type in (3,27))
        OR (calendar_date BETWEEN TRUNC(rec.first_unit_start_date)
        AND TRUNC(rec.last_unit_start_date)
        AND rec.order_type = 4)
        OR (calendar_date = TRUNC(rec.new_schedule_date)
        AND rec.order_type = 5))
    AND cal.calendar_date between p_start_date and p_end_date
    AND cal.calendar_code = mtl.calendar_code
    AND cal.exception_set_id = mtl.calendar_exception_set_id
    AND mtl.organization_id = rec.organization_id
    AND msi.planning_make_buy_code = 1
    AND msi.organization_id = rec.organization_id
    AND msi.inventory_item_id = rec.inventory_item_id
    AND msi.compile_designator = rec.compile_designator
    AND rec.compile_designator = p_designator
    AND rec.organization_id = p_org_id
    AND rec.inventory_item_id = p_item_id
  GROUP BY rec.inventory_item_id, rec.organization_id;

/** Bug 2756660 **/
  CURSOR INV_VALUES_C3 IS
  SELECT NVL(SUM(NVL(req.using_requirements_quantity,0)),0) *
	mrp_item_cost(req.inventory_item_id, req.organization_id)
  FROM mrp_gross_requirements req
  WHERE TRUNC(req.using_assembly_demand_date) between p_start_date and p_end_date
    AND req.compile_designator = p_designator
    AND req.organization_id = p_org_id
    AND req.inventory_item_id = p_item_id
  GROUP BY req.inventory_item_id, req.organization_id;

  l_inv_value1          NUMBER;
  l_inv_value2          NUMBER;
  l_inv_value3          NUMBER;

BEGIN

  OPEN INV_VALUES_C1;
  FETCH INV_VALUES_C1 INTO l_inv_value1;
  CLOSE INV_VALUES_C1;

  OPEN INV_VALUES_C2;
  FETCH INV_VALUES_C2 INTO l_inv_value2;
  CLOSE INV_VALUES_C2;

  OPEN INV_VALUES_C3;
  FETCH INV_VALUES_C3 INTO l_inv_value3;
  CLOSE INV_VALUES_C3;

  RETURN (NVL(l_inv_value1,0) + NVL(l_inv_value2,0)) - NVL(l_inv_value3,0);

EXCEPTION

  WHEN OTHERS THEN

    RETURN 0;

END inv_values;

PROCEDURE  mrp_resource_util(p_designator	varchar2,
				p_org_id	number,
				p_start_date	date,
				p_end_date	date) IS

  l_query_id	NUMBER;
BEGIN

-- ---------------------------------------------
-- Use mrp_form_query to gather resource data to
-- be summarized
-- ---------------------------------------------
  SELECT mrp_form_query_s.nextval
  INTO l_query_id
  FROM dual;

  INSERT INTO mrp_form_query
  (query_id,
   number1,
   char1,
   number2,
   number3,
   number4,
   date1,
   number5,
   number6,
   last_update_date,
   last_updated_by,
   creation_date,
   created_by)
  SELECT l_query_id,
	avail.organization_id,
	avail.compile_designator,
	avail.department_id,
	avail.resource_id,
	avail.line_id,
	cal.calendar_date,
	0,
	avail.total_availability,
 	sysdate,
	1,
	sysdate,
	1
  FROM bom_calendar_dates cal,
        mtl_parameters param,
        crp_available_resources_v avail
  WHERE cal.calendar_date BETWEEN avail.resource_start_date
	AND NVL(avail.resource_end_date,avail.resource_start_date)
    AND cal.calendar_date BETWEEN p_start_date AND p_end_date
    AND cal.calendar_code = param.calendar_code
    AND cal.exception_set_id = param.calendar_exception_set_id
    AND cal.seq_num IS NOT NULL
    AND param.organization_id = avail.organization_id
    AND avail.compile_designator = p_designator
    AND avail.organization_id = p_org_id
UNION ALL
  SELECT l_query_id,
	req.organization_id,
	req.compile_designator,
	DECODE(req.resource_id,-1,to_number(NULL),req.department_id),
	req.resource_id,
	DECODE(req.resource_id,-1,req.department_id,to_number(NULL)),
	cal.calendar_date,
	req.resource_hours,
	0,
	sysdate,
	1,
	sysdate,
	1
  FROM bom_calendar_dates cal,
        mtl_parameters param,
        crp_resource_requirements_v req
  WHERE cal.calendar_date BETWEEN req.resource_date
	AND NVL(req.resource_end_date,req.resource_date)
    AND cal.calendar_date BETWEEN p_start_date AND p_end_date
    AND cal.calendar_code = param.calendar_code
    AND cal.exception_set_id = param.calendar_exception_set_id
    AND cal.seq_num IS NOT NULL
    AND param.organization_id = req.organization_id
    AND req.compile_designator = p_designator
    AND req.organization_id = p_org_id;

-- ------------------------------------------------
-- Insert summary records into mrp_bis_res_summary
-- ------------------------------------------------
  INSERT INTO mrp_bis_res_summary
  (organization_id,
   compile_designator,
   department_id,
   resource_id,
   line_id,
   resource_date,
   required_hours,
   available_hours,
   utilization,
   last_update_date,
   last_updated_by,
   creation_date,
   created_by)
  SELECT
   number1,
   char1,
   number2,
   number3,
   number4,
   date1,
   sum(number5),
   sum(number6),
   decode(nvl(sum(number6),0),0,0,sum(number5)/sum(number6)),
   sysdate,
   1,
   sysdate,
   1
  FROM mrp_form_query
  WHERE query_id = l_query_id
  GROUP BY number1, char1, number2, number3, number4, date1;

-- -----------------------------------
-- Calculate the resource utilization
-- If available hours is zero, then
-- utilization already shows as zero
-- -----------------------------------
/***
  UPDATE mrp_bis_res_summary
  SET utilization = required_hours/available_hours
  WHERE available_hours <> 0;
***/

  delete from MRP_FORM_QUERY where query_id = l_query_id;

END mrp_resource_util;

END mrp_epi;

/
