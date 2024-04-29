--------------------------------------------------------
--  DDL for Package Body MSC_SET_DEMAND_PRIORITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SET_DEMAND_PRIORITY" AS
/* $Header: MSCDMPRB.pls 120.1 2005/07/06 11:45:54 pabram noship $ */


   LOWEST_PRIORITY CONSTANT INTEGER := 100000;

   FUNCTION MSC_DEMAND_PRIORITY(arg_plan_id   IN   NUMBER )
                return NUMBER IS

   TYPE char3000_arr IS TABLE of VARCHAR2(3000);

   TYPE t_DemandSort is RECORD (
        criteria      char3000_arr );

   v_DemandSort       t_DemandSort;

   DemandId MSC_DEMANDS.DEMAND_ID%TYPE;

   TYPE RefCurType IS REF CURSOR;
   cv   RefCurType;


   v_count                               NUMBER;
   v_OrderClause                         VARCHAR2(2000) := NULL;
   v_SelectClause                        VARCHAR2(100);
   v_FromClause                          VARCHAR2(200);
   v_WhereClause1                        VARCHAR2(200);
   v_WhereClause2                        VARCHAR2(200);
   v_WhereClause3                        VARCHAR2(200);
   v_SqlString                           VARCHAR2(3000);
   demand_priority                       NUMBER := 1;
   def_rule_id                           NUMBER;


BEGIN

      /****************************************************/
      /* Delete records in Demand_sort if found           */
      /****************************************************/
      v_DemandSort.criteria.DELETE;

      /****************************************************/
      /* Get the default demand priority rule id          */
      /****************************************************/
      SELECT RULE_ID
      INTO   def_rule_id
      FROM   msc_scheduling_rules
      WHERE  DEFAULT_FLAG = 'Y';


      /****************************************************/
      /* Get the criteria for ordering demands            */
      /****************************************************/
      SELECT  DECODE(MSR.meaning,
                  'Gross Margin',
           '-md.USING_REQUIREMENT_QUANTITY*md.SELLING_PRICE',
                  'Sales Order Priority',
           'DECODE(MSC_DEMANDS.ORIGINATION_TYPE,
                          6, NVL(md.SALES_ORDER_PRIORITY, 10000),
                          7, NVL(md.FORECAST_PRIORITY, 100000),
                             100000)',
                  'Schedule Date',
           'md.USING_ASSEMBLY_DEMAND_DATE',
                  'Promise Date',
           'NVL(md.PROMISE_DATE,
                      md.USING_ASSEMBLY_DEMAND_DATE)',
                  'Request Date',
           'NVL(md.REQUEST_DATE,
                      md.USING_ASSEMBLY_DEMAND_DATE)',
           'NULL')
      bulk collect INTO    v_DemandSort.criteria
      FROM      MSC_SCHEDULING_RULES MSR, MSC_PLANS MP
      WHERE     MSR.rule_id = NVL(MP.dem_priority_rule_id, def_rule_id)
      AND       MP.plan_id = arg_plan_id
      ORDER BY  MSR.sequence_number;


      /****************************************************/
      /* Now build the ORDER BY clause                    */
      /****************************************************/
      IF    (v_DemandSort.criteria.count > 0)
      THEN
             v_OrderClause := v_DemandSort.criteria( 1 );
      END IF;

      IF (v_DemandSort.criteria.count > 1)
      THEN
             FOR v_count in 2 .. v_DemandSort.criteria.count LOOP
               v_OrderClause :=
                    v_OrderClause || ', ' || v_DemandSort.criteria( v_count );
             END LOOP;
      END IF;

      /****************************************************/
      /* Get the SELECT, FROM and WHERE clause            */
      /****************************************************/
      v_SelectClause := 'SELECT demand_id ';
      v_FromClause   := 'FROM   msc_demands md, msc_plan_schedules mp ';
      v_WhereClause1 := 'WHERE  md.SCHEDULE_DESIGNATOR_ID =
                                              mp.INPUT_SCHEDULE_ID ';
      v_WhereClause2 := 'AND    mp.PLAN_ID = :arg_plan_id ';
      v_WhereClause3 := 'AND    md.PLAN_ID = -1 ';

      v_SqlString := v_SelectClause || v_FromClause || v_WhereClause1 ||
                     v_WhereClause2 || v_WhereClause3 ||
                           ' ORDER BY ' || v_OrderClause;

      /****************************************************/
      /* Open cursor for getting list of demands          */
      /****************************************************/
      OPEN cv FOR v_SqlString USING arg_plan_id;
      LOOP
         FETCH cv INTO DemandId;
         EXIT WHEN cv%NOTFOUND;

         /****************************************************/
         /* Update demand_priority in MSC_DEMANDS for this   */
         /* demand_id                                        */
         /****************************************************/
         UPDATE   msc_demands
         SET      DEMAND_PRIORITY = demand_priority
         WHERE    DEMAND_ID = DemandId
         AND      PLAN_ID = -1;

         /****************************************************/
         /* Increment demand priority by 1 for next demand   */
         /****************************************************/
         demand_priority := demand_priority + 1;

      END LOOP;

      CLOSE cv;

  return 1;

  EXCEPTION WHEN NO_DATA_FOUND THEN
        return 2;

END;

FUNCTION GET_INTERPLANT_DEMAND_PRIORITY(arg_plan_id   IN   NUMBER,
                                        arg_trans_id IN NUMBER)
                return NUMBER IS
p_dem_priority NUMBER := 0;
BEGIN

        SELECT NVL(MIN(end_dem.demand_priority),
						100000)
        INTO p_dem_priority
        FROM
           msc_demands end_dem,
           msc_full_pegging end_peg,
           msc_full_pegging pegging,
           msc_supplies sup
        WHERE
            end_dem.demand_id = end_peg.demand_id
        AND end_dem.plan_id = end_peg.plan_id
        AND end_peg.plan_id =  pegging.plan_id
        AND end_peg.pegging_id = pegging.end_pegging_id
        AND pegging.plan_id = sup.plan_id
        AND pegging.transaction_id = sup.transaction_id
        AND sup.transaction_id = arg_trans_id
        AND sup.plan_id = arg_plan_id;
		return p_dem_priority;

END;

END MSC_SET_DEMAND_PRIORITY;


/
