--------------------------------------------------------
--  DDL for Package Body MRP_REPORT_INV_TURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_REPORT_INV_TURNS" AS
/* $Header: MRPPRINB.pls 115.11 2002/07/15 06:03:33 sdgupta ship $ */

/*--------------------------- PUBLIC ROUTINES --------------------------------*/

PROCEDURE mrp_calculate_inventory_turns(
                                arg_query_id        IN NUMBER,
                                arg_org_id          IN NUMBER,
                                arg_compile_desig   IN VARCHAR2,
                                arg_sched_desig     IN VARCHAR2,
                                arg_cost_type       IN NUMBER,
				arg_def_cost_type   IN NUMBER) IS
    /*----------------------+
    | Variable declarations |
    +----------------------*/
    arg_calendar_code               VARCHAR2(10);
    arg_exception_set_id            NUMBER;
    begin_inv                       NUMBER;
    issued_inv                      NUMBER;
    start_date_this_period          DATE;
    start_date_next_period          DATE;
    start_date_report               DATE;
    begin_inv_report                NUMBER;
    purchase_orders                 NUMBER;
    purchase_reqs                   NUMBER;
    planned_orders_buy              NUMBER;
    discrete_jobs                   NUMBER;
    repetitive_schedules            NUMBER;
    planned_orders_make             NUMBER;
    master_schedule                 NUMBER;
    past_due_master_schedule        NUMBER;
    cum_master_schedule             NUMBER  := 0;
    first_period                    BOOLEAN := TRUE;
    end_inv_prev_period             NUMBER  := 0;
    end_inv_this_period             NUMBER  := 0;
    period_turns                    NUMBER  := 0;
    cum_turns                       NUMBER  := 0;
    my_rowid                        ROWID;
    select_on_hand                  EXCEPTION;
    select_wip                      EXCEPTION;
    update_beginning_inv            EXCEPTION;
    update_open_purchase_orders     EXCEPTION;
    update_open_purchase_reqs       EXCEPTION;
    update_mrp_purchase_orders      EXCEPTION;
    update_open_discrete_jobs       EXCEPTION;
    update_mrp_repetitive_scheds    EXCEPTION;
    update_mrp_discrete_jobs        EXCEPTION;
    update_master_sched_discrete    EXCEPTION;
    update_master_sched_repetitive  EXCEPTION;
    select_past_due_mds		    EXCEPTION;
    update_past_due_mds             EXCEPTION;
    select_inventory_values         EXCEPTION;
    update_inventory_values         EXCEPTION;

    /*------------------------+
    | Inventory values cursor |
    +------------------------*/
    CURSOR inv_values_cur IS
        SELECT   rowid,
                 date1,
                 date2,
                 number1,
                 number2,
                 number3,
                 number4,
                 number5,
                 number6,
                 number7,
                 number8
        FROM     mrp_form_query
        WHERE    query_id = arg_query_id
        ORDER BY date1;
BEGIN
    /*--------------------------+
    |  Select calendar defaults |
    +--------------------------*/
    mrp_calendar.select_calendar_defaults(
        arg_org_id,
        arg_calendar_code,
        arg_exception_set_id);

    /*-----------------------------------------------------------+
    |  Write org_id, compile_designator, and schedule_designator |
    |  for each row of the current query_id                      |
    +-----------------------------------------------------------*/
    update mrp_form_query
    set    char1 = arg_compile_desig,
           char2 = arg_sched_desig,
     	   number12 = arg_org_id
    where  query_id = arg_query_id;

    /*----------------------------------+
    | Calculate on-hand inventory value |
    +----------------------------------*/
    /*SELECT   NVL(SUM((sys.nettable_inventory_quantity
                    + sys.nonnettable_inventory_quantity)
                      * NVL(cst.item_cost, 0)), 0)
             / 1000*//*2417274*/
 SELECT   NVL(SUM((sys.nettable_inventory_quantity)
                      * NVL(cst.item_cost, 0)), 0)
             / 1000
    INTO     begin_inv
    FROM     cst_item_costs    cst,
             mrp_system_items  sys
    WHERE    cst.organization_id    = sys.organization_id
    AND      cst.inventory_item_id  = sys.inventory_item_id
    AND (  cst.cost_type_id      = arg_cost_type
            OR
           (
               (cst.cost_type_id    = arg_def_cost_type)
              AND
               (NOT EXISTS
                 (SELECT 'Primary Cost Type Row'
                  FROM cst_item_costs cst1
                   WHERE cst1.inventory_item_id = cst.inventory_item_id
                  AND   cst1.organization_id   = arg_org_id
                  AND   cst1.cost_type_id      = arg_cost_type)
                )
             )
         )
    AND      sys.compile_designator = arg_compile_desig
    AND      sys.organization_id    = arg_org_id;

    IF SQL%NOTFOUND THEN
        RAISE select_on_hand;
    END IF;
    /*------------------------------+
    | Calculate WIP inventory value |
    +------------------------------*/
    SELECT   NVL(SUM(NVL(wip.net_quantity, 0)
                   * NVL(cst.item_cost, 0)), 0)
             / 1000
    INTO     issued_inv
    FROM     cst_item_costs      cst,
             mrp_wip_components  wip
    WHERE    cst.organization_id    = wip.organization_id
    AND      cst.inventory_item_id  = wip.inventory_item_id
    AND (  cst.cost_type_id      = arg_cost_type
            OR
           (
               (cst.cost_type_id    = arg_def_cost_type)
              AND
               (NOT EXISTS
                 (SELECT 'Primary Cost Type Row'
                  FROM cst_item_costs cst1
                   WHERE cst1.inventory_item_id = cst.inventory_item_id
                  AND   cst1.organization_id   = arg_org_id
                  AND   cst1.cost_type_id      = arg_cost_type)
                )
             )
         )
    AND      wip.compile_designator = arg_compile_desig
    AND      wip.organization_id    = arg_org_id
    AND      wip.wip_entity_type   IN (1, 3)
    AND      DECODE(wip.wip_entity_type,
              1, 1, wip.supply_demand_type) =
             DECODE(wip.wip_entity_type, 1, 1, 1);

    IF SQL%NOTFOUND THEN
        RAISE select_wip;
    END IF;
    /*----------------------------+
    | Write sum to mrp_form_query |
    +----------------------------*/
    UPDATE mrp_form_query
    SET    number1 = begin_inv + issued_inv
    WHERE  query_id = arg_query_id
    AND    date2 IS NOT NULL;

    IF SQL%NOTFOUND THEN
        RAISE update_beginning_inv;
    END IF;
    /*-----------------------------------------+
    |  Calculate value of open purchase orders |
    +-----------------------------------------*/
    UPDATE  mrp_form_query  query
    SET     number2 =
            (SELECT   NVL(SUM(rec.new_order_quantity
                        * NVL(cst.item_cost, 0)), 0)
                      / 1000
            FROM     cst_item_costs       cst,
                     mrp_recommendations  rec
            WHERE    cst.organization_id          = rec.organization_id
            AND      cst.inventory_item_id        = rec.inventory_item_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      rec.new_schedule_date       >= query.date1
            AND      rec.new_schedule_date        < query.date2
            AND      rec.disposition_status_type  = 1
            AND      rec.order_type              IN (1, 8)
            AND      rec.compile_designator       = arg_compile_desig
            AND      rec.organization_id          = arg_org_id)
    WHERE   query_id = arg_query_id;

    IF SQL%NOTFOUND THEN
        RAISE update_open_purchase_orders;
    END IF;
    /*-----------------------------------------------+
    |  Calculate value of open purchase requisitions |
    +-----------------------------------------------*/
    UPDATE  mrp_form_query  query
    SET     number3 =
            (SELECT   NVL(SUM(rec.new_order_quantity
                        * NVL(cst.item_cost,0)), 0)
                      / 1000
            FROM     cst_item_costs       cst,
                     mrp_recommendations  rec
            WHERE    cst.organization_id         = rec.organization_id
            AND      cst.inventory_item_id       = rec.inventory_item_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      rec.new_schedule_date      >= query.date1
            AND      rec.new_schedule_date       < query.date2
            AND      rec.disposition_status_type = 1
            AND      rec.order_type              = 2
            AND      rec.compile_designator      = arg_compile_desig
            AND      rec.organization_id         = arg_org_id)
    WHERE   query_id = arg_query_id;

    IF SQL%NOTFOUND THEN
        RAISE update_open_purchase_reqs;
    END IF;
    /*------------------------------------------------+
    |  Calculate value of MRP planned purchase orders |
    +------------------------------------------------*/
    UPDATE  mrp_form_query  query
    SET     number4 =
            (SELECT   NVL(SUM(rec.new_order_quantity
                        * NVL(cst.item_cost, 0)), 0)
                      / 1000
            FROM     cst_item_costs       cst,
                     mrp_system_items     sys,
                     mrp_recommendations  rec
            WHERE    cst.organization_id         = sys.organization_id
            AND      cst.inventory_item_id       = sys.inventory_item_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      sys.inventory_item_id       = rec.inventory_item_id
            AND      sys.compile_designator      = rec.compile_designator
            AND      sys.organization_id         = rec.organization_id
            AND      sys.planning_make_buy_code  = 2
            AND      rec.new_schedule_date      >= query.date1
            AND      rec.new_schedule_date       < query.date2
            AND      rec.disposition_status_type = 1
            AND      rec.order_type              = 5
            AND      rec.compile_designator      = arg_compile_desig
            AND      rec.organization_id         = arg_org_id)
    WHERE   query_id = arg_query_id;

    IF SQL%NOTFOUND THEN
        RAISE update_mrp_purchase_orders;
    END IF;
   /*-----------------------------------------------------------------+
    |  Calculate value of open discrete jobs and open flow schedules, |
    |  excluding material costs. Note that we include flow schedule   |
    |  costs under the heading of discrete jobs in the report.        |
    +-----------------------------------------------------------------*/
    UPDATE  mrp_form_query  query
    SET     number5 =
            (SELECT   NVL(SUM(rec.new_order_quantity
                      * (NVL(cst.tl_resource, 0)
                       + NVL(cst.tl_overhead, 0)
                       + NVL(cst.tl_material_overhead, 0)
                       + NVL(cst.tl_outside_processing, 0))), 0)
                      / 1000
            FROM     cst_item_costs       cst,
                     mrp_recommendations  rec
            WHERE    cst.inventory_item_id       = rec.inventory_item_id
            AND      cst.organization_id         = rec.organization_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      rec.new_wip_start_date     >= query.date1
            AND      rec.new_wip_start_date      < query.date2
            AND      rec.disposition_status_type = 1
            AND      rec.order_type              in (3, 27)
            AND      rec.compile_designator      = arg_compile_desig
            AND      rec.organization_id         = arg_org_id)
    WHERE   query_id = arg_query_id;

    IF SQL%NOTFOUND THEN
        RAISE update_open_discrete_jobs;
    END IF;
    /*------------------------------------------------------------------------+
    |  Calculate value of suggested repetitive schedules, excluding material  |
    |  costs                                                                  |
    +------------------------------------------------------------------------*/
    UPDATE  mrp_form_query  query
    SET     number6 =
            (SELECT   NVL(SUM(NVL(rec.daily_rate, 0)
                         *  (NVL(cst.tl_resource, 0)
                           + NVL(cst.tl_overhead, 0)
                           + NVL(cst.tl_material_overhead, 0)
                           + NVL(cst.tl_outside_processing, 0))), 0)
                      / 1000
            FROM     cst_item_costs          cst,
                     bom_calendar_dates      cal,
                     mrp_recommendations     rec
            WHERE    cst.inventory_item_id        = rec.inventory_item_id
            AND      cst.organization_id          = rec.organization_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      rec.last_unit_start_date    >= query.date1
            AND      rec.first_unit_start_date    < query.date2
            AND      cal.calendar_date      BETWEEN
                                           GREATEST(rec.first_unit_start_date,
                                                    query.date1)
                                                AND
                                              LEAST(rec.last_unit_start_date,
                                                   (query.date2 - 1))
            AND      cal.calendar_code            = arg_calendar_code
            AND      cal.exception_set_id         = arg_exception_set_id
            AND      cal.seq_num                 IS NOT NULL
            AND      rec.disposition_status_type  = 1
            AND      rec.order_type               = 4
            AND      rec.compile_designator       = arg_compile_desig
            AND      rec.organization_id          = arg_org_id)
    WHERE   query_id = arg_query_id;

    IF SQL%NOTFOUND THEN
        RAISE update_mrp_repetitive_scheds;
    END IF;
    /*------------------------------------------------------------------------+
    |  Calculate value of MRP planned discrete jobs, excluding material costs |
    +------------------------------------------------------------------------*/
    UPDATE  mrp_form_query  query
    SET     number7 =
            (SELECT   NVL(SUM(rec.new_order_quantity
                      * (NVL(cst.tl_resource, 0)
                       + NVL(cst.tl_overhead, 0)
                       + NVL(cst.tl_material_overhead, 0)
                       + NVL(cst.tl_outside_processing, 0))), 0)
                      / 1000
            FROM     cst_item_costs               cst,
                     mrp_system_items             sys,
                     mrp_recommendations          rec
            WHERE    cst.inventory_item_id       = sys.inventory_item_id
            AND      cst.organization_id         = sys.organization_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      sys.inventory_item_id       = rec.inventory_item_id
            AND      sys.compile_designator      = rec.compile_designator
            AND      sys.organization_id         = rec.organization_id
            AND      sys.planning_make_buy_code  = 1
            AND      rec.new_schedule_date      >= query.date1
            AND      rec.new_schedule_date       < query.date2
            AND      rec.disposition_status_type = 1
            AND      rec.order_type              = 5
            AND      rec.compile_designator      = arg_compile_desig
            AND      rec.organization_id         = arg_org_id)
    WHERE   query_id = arg_query_id;

    IF SQL%NOTFOUND THEN
        RAISE update_mrp_discrete_jobs;
    END IF;
    /*----------------------------------------------------+
    |  Calculate value of master schedule, discrete items |
    +----------------------------------------------------*/
    UPDATE  mrp_form_query  query
    SET     number8 =
            (SELECT   NVL(SUM(dates.schedule_quantity * cst.item_cost), 0)
                      / 1000
            FROM     mrp_schedule_dates  dates,
                     cst_item_costs      cst,
                     mrp_system_items    sys,
		     mrp_schedule_designators sched
            WHERE    cst.organization_id       = sys.organization_id
            AND      cst.inventory_item_id     = sys.inventory_item_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      dates.organization_id     = sys.organization_id
            AND      dates.inventory_item_id   = sys.inventory_item_id
            AND      dates.schedule_date      >= query.date1
            AND      dates.schedule_date       < query.date2
            AND      dates.schedule_level      = 3
            AND      dates.schedule_designator = arg_sched_desig
	    AND	     sched.schedule_designator = arg_sched_desig
	    AND	     sched.organization_id     = arg_org_id
            AND      sys.repetitive_type       = 1
            AND      sys.compile_designator    = arg_compile_desig
            AND      sys.organization_id       = arg_org_id)
    WHERE   query_id = arg_query_id;

    IF SQL%NOTFOUND THEN
        RAISE update_master_sched_discrete;
    END IF;
    /*------------------------------------------------------+
    |  Calculate value of master schedule, repetitive items |
    +------------------------------------------------------*/
    UPDATE  mrp_form_query  query
    SET     number8 =
            (SELECT  query.number8 +
                     NVL(SUM(cst.item_cost
                      * dates.repetitive_daily_rate), 0)
                     / 1000
            FROM     bom_calendar_dates  cal,
                     mrp_schedule_dates  dates,
                     cst_item_costs      cst,
                     mrp_system_items    sys,
		     mrp_schedule_designators sched
            WHERE    cst.organization_id       = sys.organization_id
            AND      cst.inventory_item_id     = sys.inventory_item_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      dates.organization_id     = sys.organization_id
            AND      dates.inventory_item_id   = sys.inventory_item_id
            AND      dates.rate_end_date      >= query.date1
            AND      dates.schedule_date       < query.date2
            AND      dates.schedule_level      = 3
            AND      dates.schedule_designator = arg_sched_desig
	    AND      sched.schedule_designator = arg_sched_desig
	    AND      sched.organization_id     = arg_org_id
            AND      cal.calendar_date   BETWEEN
                                        GREATEST(dates.schedule_date,
                                                 query.date1)
                                             AND
                                           LEAST(dates.rate_end_date,
                                                (query.date2 - 1))
            AND      cal.calendar_code            = arg_calendar_code
            AND      cal.exception_set_id         = arg_exception_set_id
            AND      cal.seq_num              IS NOT NULL
            AND      sys.repetitive_type       = 2
            AND      sys.compile_designator    = arg_compile_desig
            AND      sys.organization_id       = arg_org_id)
    WHERE   query_id = arg_query_id;

    IF SQL%NOTFOUND THEN
        RAISE update_master_sched_repetitive;
    END IF;
    /*--------------------------------------------------------------+
    | Calculate ending inventory, period turns and cumulative turns |
    +--------------------------------------------------------------*/
    OPEN inv_values_cur;
    LOOP
        FETCH inv_values_cur INTO
            my_rowid,
            start_date_this_period,
            start_date_next_period,
            begin_inv_report,
            purchase_orders,
            purchase_reqs,
            planned_orders_buy,
            discrete_jobs,
            repetitive_schedules,
            planned_orders_make,
            master_schedule;

        EXIT WHEN inv_values_cur%NOTFOUND;

        IF SQL%NOTFOUND THEN
            RAISE select_inventory_values;
        END IF;
        /*--------------------------------------------------------+
        | Initialize inventory values for report and first period |
        +--------------------------------------------------------*/
        IF first_period = TRUE THEN
            first_period := FALSE;
            start_date_report   := start_date_this_period;
            end_inv_prev_period := begin_inv_report;
			/* following code added for bug fix 399945 */
			/*---------------------------------------------+
			|  Calculate value of past due master schedule |
			+---------------------------------------------*/
            SELECT  NVL(SUM(cst.item_cost
                      * NVL(dates.repetitive_daily_rate,
						dates.schedule_quantity)), 0) / 1000
			INTO	 past_due_master_schedule
            FROM     bom_calendar_dates  cal,
                     mrp_schedule_dates  dates,
                     cst_item_costs      cst,
                     mrp_system_items    sys,
		     mrp_schedule_designators sched
            WHERE    cst.organization_id       = sys.organization_id
            AND      cst.inventory_item_id     = sys.inventory_item_id
            AND ( cst.cost_type_id      = arg_cost_type
                OR
                  (
                   (cst.cost_type_id    = arg_def_cost_type)
                   AND
                   (NOT EXISTS
                      (SELECT 'Primary Cost Type Row'
                       FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                       AND   cst1.organization_id   = arg_org_id
                       AND   cst1.cost_type_id      = arg_cost_type)
                   )
                 )
               )
            AND      dates.organization_id     = sys.organization_id
            AND      dates.inventory_item_id   = sys.inventory_item_id
            AND      NVL(dates.rate_end_date, dates.schedule_date)
						< start_date_this_period
            AND      dates.schedule_level      = 3
            AND      dates.schedule_designator = arg_sched_desig
	    AND      sched.schedule_designator = arg_sched_desig
	    AND      sched.organization_id     = arg_org_id
            AND      cal.calendar_date   BETWEEN dates.schedule_date
					 AND NVL(dates.rate_end_date, dates.schedule_date)
            AND      cal.calendar_code            = arg_calendar_code
            AND      cal.exception_set_id         = arg_exception_set_id
            AND      cal.seq_num              IS NOT NULL
            AND      sys.compile_designator    = arg_compile_desig
            AND      sys.organization_id       = arg_org_id;
			IF SQL%NOTFOUND THEN
				RAISE select_past_due_mds;
			END IF;
			master_schedule := master_schedule + past_due_master_schedule;
			UPDATE mrp_form_query
			SET    number8 = master_schedule
			WHERE  rowid = my_rowid;
				IF SQL%NOTFOUND THEN
					RAISE update_past_due_mds;
				END IF;
		/* End of code added for bug fix 399945 */
        ELSE
            end_inv_prev_period := end_inv_this_period;
            period_turns := 0;
            cum_turns := 0;
        END IF;
        /*----------------------------------+
        | Update cumulative master schedule |
        +----------------------------------*/
        cum_master_schedule := cum_master_schedule + master_schedule;
        /*----------------------------------------------------+
        | Calculate ending inventory value for current period |
        +----------------------------------------------------*/
        end_inv_this_period := ((end_inv_prev_period
                                + purchase_orders
                                + purchase_reqs
                                + planned_orders_buy
                                + discrete_jobs
                                + repetitive_schedules
                                + planned_orders_make)
                                  - master_schedule);
        /*---------------------------------------------+
        | Calculate inventory turns for current period |
        +---------------------------------------------*/
        IF ((end_inv_prev_period + end_inv_this_period)) = 0 THEN
            period_turns := null;
        ELSE
            period_turns := (master_schedule
                            / ((end_inv_prev_period + end_inv_this_period) / 2))
                                * (365 / (start_date_next_period -
                                          start_date_this_period));
        END IF;
        /*-------------------------------------+
        | Calculate cumulative inventory turns |
        +-------------------------------------*/
        IF ((begin_inv_report + end_inv_this_period) = 0) THEN
            cum_turns := null;
        ELSE
            cum_turns := (cum_master_schedule
                         / ((begin_inv_report + end_inv_this_period) / 2))
                             * (365 / (start_date_next_period -
                                       start_date_report));
        END IF;
        /*-------------------------------------------------------------+
        | Write ending inventory, period turns and cumulative turns to |
        | mrp_form_query                                               |
        +-------------------------------------------------------------*/
        UPDATE  mrp_form_query q
        SET     number9 = end_inv_this_period,
                number10 = period_turns,
                number11 = cum_turns
        WHERE   rowid = my_rowid;

        IF SQL%NOTFOUND THEN
            RAISE update_inventory_values;
        END IF;
    END LOOP;
    CLOSE inv_values_cur;
commit;
EXCEPTION
    WHEN select_on_hand THEN
        raise_application_error(-20000,
            'Cannot select on-hand beginning inventory value');

    WHEN select_wip THEN
        raise_application_error(-20000,
            'Cannot select WIP beginning inventory value');

    WHEN update_beginning_inv THEN
        raise_application_error(-20000,
            'Cannot update beginning inventory value');

    WHEN update_open_purchase_orders THEN
        raise_application_error(-20000,
            'Cannot update open purchase order values');

    WHEN update_open_purchase_reqs THEN
        raise_application_error(-20000,
            'Cannot update open purchase requisition values');

    WHEN update_mrp_purchase_orders THEN
        raise_application_error(-20000,
            'Cannot update MRP planned purchase order values');

    WHEN update_open_discrete_jobs THEN
        raise_application_error(-20000,
            'Cannot update open discrete job values');

    WHEN update_mrp_repetitive_scheds THEN
        raise_application_error(-20000,
            'Cannot update suggested repetitive schedule values');

    WHEN update_mrp_discrete_jobs THEN
        raise_application_error(-20000,
            'Cannot update MRP planned discrete job values');

    WHEN update_master_sched_discrete THEN
        raise_application_error(-20000,
            'Cannot update master schedule, discrete item values');

    WHEN update_master_sched_repetitive THEN
        raise_application_error(-20000,
            'Cannot update master schedule, discrete item values');

    WHEN select_inventory_values THEN
        raise_application_error(-20000,
                'Cannot select inventory values');

    WHEN update_inventory_values THEN
        raise_application_error(-20000,
                'Cannot update inventory values');

	WHEN select_past_due_mds THEN
		raise_application_error(-2000,
				'Cannot select past due MDS');
	WHEN update_past_due_mds THEN
		raise_application_error(-2000,
				'Cannot update past due MDS');

END mrp_calculate_inventory_turns;
END mrp_report_inv_turns;

/
