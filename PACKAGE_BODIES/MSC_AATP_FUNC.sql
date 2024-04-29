--------------------------------------------------------
--  DDL for Package Body MSC_AATP_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_AATP_FUNC" AS
/* $Header: MSCFAATB.pls 120.1.12010000.2 2008/08/25 10:40:06 sbnaik ship $  */
G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MSC_AATP_FUNC';

-- INFINITE_NUMBER         CONSTANT NUMBER := 1.0e+10;

-- demand type
DEMAND_SALES_ORDER_MDS  CONSTANT INTEGER := 6;
DEMAND_FORECAST         CONSTANT INTEGER := 7;
DEMAND_MANUAL           CONSTANT INTEGER := 8;
DEMAND_OTHER            CONSTANT INTEGER := 9;
DEMAND_HARD_RESERVE     CONSTANT INTEGER := 10;
DEMND_MDS_IND           CONSTANT INTEGER := 11;
DEMND_MPS_COMPILE       CONSTANT INTEGER := 12;
FORECAST                CONSTANT INTEGER := 29;
DEMAND_SALES_ORDER      CONSTANT INTEGER := 30;

G_HIERARCHY_PROFILE     NUMBER := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

FUNCTION Get_Item_Demand_Alloc_Percent(
	p_plan_id 		IN 	NUMBER,
	p_demand_id 		IN 	NUMBER,
	p_demand_date 		IN 	DATE,
	p_assembly_item_id 	IN 	NUMBER,
        p_source_org_id         IN      NUMBER,
	p_inventory_item_id 	IN 	NUMBER,
	p_org_id 		IN 	NUMBER,
	p_instance_id 		IN 	NUMBER,
	p_origination_type 	IN 	NUMBER,
	p_record_class 		IN 	VARCHAR2,
	p_demand_class 		IN 	VARCHAR2,
        p_level_id              IN      NUMBER)
RETURN NUMBER
IS
	l_alloc_percent   		NUMBER;
	l_alloc_rule   			NUMBER;
	l_default_atp_rule_id           NUMBER;
	l_calendar_code                 VARCHAR2(14);
	l_calendar_exception_set_id     NUMBER;
	l_default_demand_class          VARCHAR2(34);
        l_org_code                      VARCHAR2(7);
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Get_Item_Demand_Alloc_Percent *****');
     msc_sch_wb.atp_debug('p_plan_id =' || p_plan_id);
     msc_sch_wb.atp_debug('p_demand_id =' || p_demand_id);
     msc_sch_wb.atp_debug('p_demand_date =' || p_demand_date );
     msc_sch_wb.atp_debug('p_assembly_item_id =' || p_assembly_item_id);
     msc_sch_wb.atp_debug('p_source_org_id =' || p_source_org_id);
     msc_sch_wb.atp_debug('p_inventory_item_id =' || p_inventory_item_id);
     msc_sch_wb.atp_debug('p_org_id =' || p_org_id);
     msc_sch_wb.atp_debug('p_instance_id =' || p_instance_id);
     msc_sch_wb.atp_debug('p_origination_type =' || p_origination_type );
     msc_sch_wb.atp_debug('p_demand_class =' || p_demand_class);
     msc_sch_wb.atp_debug('p_record_class =' || p_record_class);
  END IF;

  l_alloc_rule :=  MSC_AATP_FUNC.Get_DC_Alloc_Percent(p_instance_id, p_inventory_item_id, p_org_id,
				null, null, p_demand_class, p_demand_date);
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('l_alloc_rule : '||l_alloc_rule);
  END IF;

-- dsting #1625776
-- If no rule exists for the demand on the demand date, and the demand date is > sysdate
-- ie the demand is past due and the demand is a sales order,
-- then honor the rule for that item on sysdate
  IF l_alloc_rule IS NULL    AND
     p_demand_date < trunc(sysdate) AND
     p_origination_type in (DEMAND_SALES_ORDER, DEMAND_SALES_ORDER_MDS)
  THEN
  	l_alloc_rule :=  MSC_AATP_FUNC.Get_DC_Alloc_Percent(p_instance_id, p_inventory_item_id, p_org_id,
					null, null, p_demand_class,sysdate);
  END IF;

  IF l_alloc_rule IS NULL THEN
	l_alloc_percent := 1;
  ELSIF p_record_class <> p_demand_class THEN
	l_alloc_percent := 0;
  --rajjain changed the condition as an internal sales order is also a dependent demand
  ELSIF ( p_origination_type = DEMAND_HARD_RESERVE or (p_origination_type in (DEMAND_SALES_ORDER_MDS, DEMAND_SALES_ORDER) and
                                                         (p_source_org_id in (-23453, p_org_id)
  -- bug 2783787 (ssurendr) - independent demands were getting considered as dependent because of wrong IN expresession
                                                         or p_source_org_id IS NULL))) THEN

      -- mps and mds we may need to do something different, let's deal with
      -- them later.

  -- if the demand is the independent demand, we join back to see the demand
  -- class.  if the demand is the dependent demand, we see how we allocate for
  -- the parent supply, we do the same thing to it's dependent demand.

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('this is indep demand, origination_type = '||p_origination_type);
      END IF;
      /*
      bug 2783787 (ssurendr) - null demand_class in request should be regarded as "OTHER"
      MSC_ATP_PROC.get_org_default_info(p_instance_id, p_org_id, l_default_atp_rule_id,
                  l_calendar_code, l_calendar_exception_set_id, l_default_demand_class,
                        l_org_code);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('l_default_atp_rule_id='||l_default_atp_rule_id);
         msc_sch_wb.atp_debug('l_calendar_code='||l_calendar_code);
         msc_sch_wb.atp_debug('l_calendar_exception_set_id'||l_calendar_exception_set_id);
         msc_sch_wb.atp_debug('l_default_demand_class'||l_default_demand_class);
         msc_sch_wb.atp_debug('l_org_code'||l_org_code);
      END IF;
      */

      BEGIN

        -- Changed as per discussion with Christine.
  	IF (p_origination_type = DEMAND_SALES_ORDER) OR
           (p_origination_type = DEMAND_SALES_ORDER_MDS) THEN

           IF G_HIERARCHY_PROFILE = 1 THEN
                -- demand class
	        select  1
       		into	l_alloc_percent
       		from    msc_demands d
       		--5027568
        	where   decode(d.origination_type, -100, 30, d.origination_type)  in (6, 30)--DEMAND_SALES_ORDER
        	and     d.plan_id = p_plan_id
        	and     d.demand_id = p_demand_id
        	and	NVL(d.demand_class,'-1') = p_demand_class;

                /* bug 2783787 - demand_class is always available in msc_demands
                no need to look in msc_sales_orders
	        select  1
       		into	l_alloc_percent
       		from    msc_sales_orders so,
       	         	msc_demands d
        	where   d.origination_type in (6, 30)	--DEMAND_SALES_ORDER
        	and     d.plan_id = p_plan_id
        	and     d.demand_id = p_demand_id
        	and     d.reservation_id = so.demand_id
        	and     so.sr_instance_id= d.sr_instance_id
        	and     so.organization_id= d.organization_id
        	and     so.inventory_item_id= d.inventory_item_id
                --bug 2424357: treat others as -1
        	--and	NVL(so.demand_class, NVL(l_default_demand_class,'@@@')) = p_demand_class
        	and	NVL(so.demand_class, NVL(l_default_demand_class,'-1')) = p_demand_class
        	and     so.parent_demand_id is null;*/

           ELSIF G_HIERARCHY_PROFILE = 2 THEN
                select  1
                into    l_alloc_percent
                from    msc_demands d
                where   d.plan_id = p_plan_id
                and     d.demand_id = p_demand_id
                and     MSC_AATP_FUNC.get_hierarchy_demand_class(d.customer_id, d.ship_to_site_id,d.inventory_item_id, d.organization_id, d.sr_instance_id, p_demand_date, p_level_id, null) = p_demand_class;


           END IF; -- IF G_HIERARCHY_PROFILE = 1 THEN

  	ELSIF p_origination_type = DEMAND_HARD_RESERVE THEN

	-- It is assumed that we shall be deducting any hard reservations before
	-- doing allocations. For example if total supply is 100 and there is a
	-- hard reservation of 20 (irrespective of the demand class), we shall be
	-- allocating only the balance (100 - 20 = 80) based on allocation rule of
	-- the requested demand class.

         	l_alloc_percent :=  MSC_AATP_FUNC.Get_DC_Alloc_Percent(
			p_instance_id, p_assembly_item_id, p_org_id,
			null, null, p_demand_class, p_demand_date);
	END IF;

        -- work around for bug 1403859
        -- As per Raghvan we need to also add condition for parent_demand_id
	-- as null on msc_sales_orders to avoid multiple rows - Bug # 1405568

/*
        SELECT 1
        INTO   l_alloc_percent
        FROM   msc_sales_orders so,
               msc_demands d
        WHERE  d.demand_id = p_demand_id
        AND    d.plan_id = p_plan_id
        AND    so.demand_id  = d.reservation_id
        AND    so.sr_instance_id = d.sr_instance_id
        AND    so.inventory_item_id  = d.inventory_item_id
        AND    so.organization_id  = d.organization_id
        AND    so.parent_demand_id is null
        AND    NVL(so.demand_class, NVL(l_default_demand_class,'@@@')) = p_demand_class;
*/


      EXCEPTION
        when no_data_found then
          l_alloc_percent := 0.0;
        when others then
          l_alloc_percent := NULL;
	  IF PG_DEBUG in ('Y', 'C') THEN
	     msc_sch_wb.atp_debug('Exception in Get_Item_Demand_Alloc_Percent');
	  END IF;
      END;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('before leave the if, l_alloc_percent = '|| l_alloc_percent);
      END IF;

  ELSE

      -- this is dependent demand, we see how we alocate the parent supply,
      -- and do the same thing for it's demand

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('this is dependent demand');
         msc_sch_wb.atp_debug('Get_Item_Demand_Alloc_Percent: ' || 'G_TIME_PHASED_PF_ENABLED := ' || MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED);
      END IF;
      -- Check if there is an allocation rule defined at component level.
      -- If no rule at component level, consider every demand and supply, that means
      -- consider allocation percent to be 1 (100%), else check if there is a rule at
      -- parent level and use that rule.
/*
      l_alloc_percent :=  MSC_AATP_FUNC.Get_DC_Alloc_Percent(
		p_instance_id, p_inventory_item_id, p_org_id,
		null, null, p_demand_class, p_demand_date);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('before entering the parent if, l_alloc_percent = '||l_alloc_percent);
      END IF;

      IF l_alloc_percent IS NOT NULL THEN
*/

      /* To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
         As per the new logic for dependent demand allocation use allocation rule for component only if
         component is time phased PF ATP enabled*/
      IF MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED = 'Y' THEN
         l_alloc_percent :=  l_alloc_rule;
      ELSE
         /* To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
            As per the new logic for we don't time phased ATP allocation logic at assembly. So we always pass
            p_assembly_item_id irrespective of whether assembly item is time phased PF enabled or not*/
         l_alloc_percent :=  NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
		p_instance_id, p_assembly_item_id,
                NVL(p_source_org_id, p_org_id),
		null, null,p_demand_class, p_demand_date), l_alloc_rule);
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('before leaving the parent if, l_alloc_percent = '||l_alloc_percent);
      END IF;
/*
      ELSE
         l_alloc_percent := 1;
      END IF;
*/

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('before leave the if, l_alloc_percent = '||l_alloc_percent);
      END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('before returning, l_alloc_percent = '||l_alloc_percent);
  END IF;
  return(l_alloc_percent);

END Get_Item_Demand_Alloc_Percent;

FUNCTION Get_DC_Alloc_Percent(
	p_instance_id 	IN 	NUMBER,
	p_inv_item_id 	IN 	NUMBER,
	p_org_id 	IN 	NUMBER,
	p_dept_id 	IN 	NUMBER,
	p_res_id  	IN 	NUMBER,
	p_demand_class 	IN 	VARCHAR2,
	p_request_date 	IN 	DATE)
RETURN NUMBER
IS
	l_alloc_percent NUMBER := 0.0;
        l_rule_name     VARCHAR2(30);
	l_time_phase 	NUMBER;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Get_DC_Alloc_Percent *****');
     msc_sch_wb.atp_debug('p_instance_id =' || p_instance_id);
     msc_sch_wb.atp_debug('p_inv_item_id =' || p_inv_item_id);
     msc_sch_wb.atp_debug('p_org_id =' || p_org_id);
     msc_sch_wb.atp_debug('p_dept_id =' || p_dept_id);
     msc_sch_wb.atp_debug('p_res_id =' || p_res_id);
     msc_sch_wb.atp_debug('p_demand_class =' || p_demand_class);
     msc_sch_wb.atp_debug('p_request_date =' || p_request_date );
  END IF;

  --IF p_inv_item_id is not null THEN      placed down
        -- Get the allocation percent for the item/demand class. If no rule found,
	-- check if a rule on the specified date exists for any demand class
	-- for the specific item, take allocation percentage as NULL.
	-- Though we will treat NULL as 1, but we need to differentiate them
	-- so as to group demands/ supplies by demand classes. - ngoel 8/31/2000.

/*
      		SELECT allocation_percent/100
	      	INTO   l_alloc_percent
      		FROM   msc_item_hierarchy_mv
      		WHERE  demand_class = p_demand_class
      		AND    inventory_item_id = p_inv_item_id
      		AND    organization_id = p_org_id
      		AND    sr_instance_id = p_instance_id
      		AND    p_request_date between effective_date and disable_date;
*/
		-- Modified by NGOEL on 2/23/2001 as there may be more than 1 rule assigned
		-- to an item/org/instance combinantion at a given level based on time phase.
                --SELECT distinct allocation_rule_name
       /* Assumption is that in time phased ATP scenarios Aggregate time fence
          will be more than the plan run frequency */
   --code commented to get allocation percent
   --bug3099066
   --BEGIN  --bug3333114
  IF p_inv_item_id is not null THEN
    IF G_HIERARCHY_PROFILE = 1 THEN ---bug3099066
       BEGIN ---Bug 3099066
         IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get the Allocation on Request Date');
         END IF;

         SELECT allocation_percent/100
         INTO   l_alloc_percent
         FROM   msc_item_hierarchy_mv
         WHERE  inventory_item_id = p_inv_item_id
         AND    organization_id = p_org_id
         AND    sr_instance_id = p_instance_id
         AND    demand_class = p_demand_class
         AND    level_id = -1
         AND    p_request_date between effective_date and disable_date;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Inside Exception Get the Allocation on Sysdate');
         END IF;
         IF (p_request_date < trunc(sysdate)) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Inside IF of Exception');
            END IF;

            BEGIN

             SELECT allocation_percent/100
             INTO   l_alloc_percent
             FROM   msc_item_hierarchy_mv
             WHERE  inventory_item_id = p_inv_item_id
             AND    organization_id = p_org_id
             AND    sr_instance_id = p_instance_id
             AND    demand_class = p_demand_class
             AND    level_id = -1
             AND     trunc(sysdate) between effective_date and disable_date;

            EXCEPTION

            WHEN NO_DATA_FOUND THEN
              SELECT DECODE(count(allocation_percent), 0, NULL, 0)
              INTO   l_alloc_percent
              FROM   msc_item_hierarchy_mv
              WHERE  inventory_item_id = p_inv_item_id
              AND    organization_id = p_org_id
              AND    sr_instance_id = p_instance_id
              AND    (p_request_date between effective_date and disable_date
              OR     trunc(sysdate) between effective_date and disable_date)
              AND    level_id = -1;
	        END;
         ELSE
	       IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Inside Else of Exception');
           END IF;

           SELECT DECODE(count(allocation_percent), 0, NULL, 0)
           INTO   l_alloc_percent
           FROM   msc_item_hierarchy_mv
           WHERE  inventory_item_id = p_inv_item_id
           AND    organization_id = p_org_id
           AND    sr_instance_id = p_instance_id
           AND    p_request_date between effective_date and disable_date
           AND    level_id = -1;
         END IF;
       END;
    ELSE
       BEGIN ---Bug 3099066
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get the Allocation on Request Date:2');
         END IF;

         SELECT allocation_percent/100
         INTO   l_alloc_percent
         FROM   msc_item_hierarchy_mv
         WHERE  inventory_item_id = p_inv_item_id
         AND    organization_id = p_org_id
         AND    sr_instance_id = p_instance_id
         AND    demand_class = p_demand_class
         AND    level_id <> -1
         AND    p_request_date between effective_date and disable_date;
       EXCEPTION

         WHEN NO_DATA_FOUND THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get the Allocation on Sysdate:2');
           END IF;

           IF (p_request_date < trunc(sysdate)) THEN
             BEGIN

               SELECT allocation_percent/100
               INTO   l_alloc_percent
               FROM   msc_item_hierarchy_mv
               WHERE  inventory_item_id = p_inv_item_id
               AND    organization_id = p_org_id
               AND    sr_instance_id = p_instance_id
               AND    demand_class = p_demand_class
               AND    level_id <> -1
               AND     trunc(sysdate) between effective_date and disable_date;
             EXCEPTION

               WHEN NO_DATA_FOUND THEN

               SELECT DECODE(count(allocation_percent), 0, NULL, 0)
               INTO   l_alloc_percent
               FROM   msc_item_hierarchy_mv
               WHERE  inventory_item_id = p_inv_item_id
               AND    organization_id = p_org_id
               AND    sr_instance_id = p_instance_id
               AND    (p_request_date between effective_date and disable_date
               OR     trunc(sysdate) between effective_date and disable_date)
               AND    level_id <> -1;
	         END;
           ELSE
             SELECT DECODE(count(allocation_percent), 0, NULL, 0)
             INTO   l_alloc_percent
             FROM   msc_item_hierarchy_mv
             WHERE  inventory_item_id = p_inv_item_id
             AND    organization_id = p_org_id
             AND    sr_instance_id = p_instance_id
             AND    p_request_date between effective_date and disable_date
             AND    level_id <> -1;
           END IF;
       END;
    END IF;
  --END; --bug3333114
  --old code code commented to get allocation percent
  --for the dept/res/demand class  bug3333114
  ELSE
    IF G_HIERARCHY_PROFILE = 1 THEN ---bug3333114 start
      BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get the Allocation on Request Date:1');
        END IF;

        SELECT allocation_percent/100
        INTO   l_alloc_percent
        FROM   msc_resource_hierarchy_mv
        WHERE  demand_class = p_demand_class
        AND    department_id = p_dept_id
        AND    resource_id = p_res_id
        AND    organization_id = p_org_id
        AND    sr_instance_id = p_instance_id
        AND    level_id = -1
        AND    p_request_date between effective_date and disable_date;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get the Allocation on Sysdate:1');
          END IF;
          IF (p_request_date < trunc(sysdate)) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Inside IF');
            END IF;
            BEGIN
              SELECT allocation_percent/100
              INTO   l_alloc_percent
              FROM   msc_resource_hierarchy_mv
              WHERE  demand_class = p_demand_class
	          AND    department_id = p_dept_id
	          AND    resource_id = p_res_id
              AND    organization_id = p_org_id
              AND    sr_instance_id = p_instance_id
              AND    level_id = -1
              AND     trunc(sysdate) between effective_date and disable_date;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
               SELECT DECODE(count(allocation_percent), 0, NULL, 0)
               INTO   l_alloc_percent
               FROM   msc_resource_hierarchy_mv
               WHERE  department_id = p_dept_id
	           AND    resource_id = p_res_id
               AND    organization_id = p_org_id
               AND    sr_instance_id = p_instance_id
               AND    (p_request_date between effective_date and disable_date
               OR     trunc(sysdate) between effective_date and disable_date)
               AND    level_id = -1;
	        END;
          ELSE
	         IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Inside Else');
             END IF;

             SELECT DECODE(count(allocation_percent), 0, NULL, 0)
             INTO   l_alloc_percent
             FROM   msc_resource_hierarchy_mv
             WHERE  department_id = p_dept_id
	         AND    resource_id = p_res_id
             AND    organization_id = p_org_id
             AND    sr_instance_id = p_instance_id
             AND    p_request_date between effective_date and disable_date
             AND    level_id = -1;
          END IF;
      END;
    ELSE
       BEGIN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get the Allocation on Request Date:2');
         END IF;
         SELECT allocation_percent/100
         INTO   l_alloc_percent
         FROM   msc_resource_hierarchy_mv
         WHERE  demand_class = p_demand_class
         AND    department_id = p_dept_id
         AND    resource_id = p_res_id
         AND    organization_id = p_org_id
         AND    sr_instance_id = p_instance_id
         AND    level_id <> -1
         AND    p_request_date between effective_date and disable_date;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get the Allocation on Sysdate:2');
          END IF;

          IF (p_request_date < trunc(sysdate)) THEN

           BEGIN
            SELECT allocation_percent/100
            INTO   l_alloc_percent
            FROM   msc_resource_hierarchy_mv
            WHERE  demand_class = p_demand_class
	        AND    department_id = p_dept_id
	        AND    resource_id = p_res_id
            AND    organization_id = p_org_id
            AND    sr_instance_id = p_instance_id
            AND    level_id <> -1
            AND     trunc(sysdate) between effective_date and disable_date;
           EXCEPTION
            WHEN NO_DATA_FOUND THEN
            SELECT DECODE(count(allocation_percent), 0, NULL, 0)
            INTO   l_alloc_percent
            FROM   msc_resource_hierarchy_mv
            WHERE  department_id = p_dept_id
	        AND    resource_id = p_res_id
            AND    organization_id = p_org_id
            AND    sr_instance_id = p_instance_id
            AND    (p_request_date between effective_date and disable_date
            OR     trunc(sysdate) between effective_date and disable_date)
            AND    level_id <> -1;
	       END;
          ELSE
           SELECT DECODE(count(allocation_percent), 0, NULL, 0)
           INTO   l_alloc_percent
           FROM   msc_resource_hierarchy_mv
           WHERE  department_id = p_dept_id
	       AND    resource_id = p_res_id
           AND    organization_id = p_org_id
           AND    sr_instance_id = p_instance_id
           AND    p_request_date between effective_date and disable_date
           AND    level_id <> -1;
          END IF;
       END;
    END IF;
  END IF;  --bug3333114 end
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Call to alloc:' || to_char(l_alloc_percent));
  END IF;
  return (l_alloc_percent);

EXCEPTION
  WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Error code:' || to_char(sqlcode));
      END IF;
      return(0.0);
END Get_DC_Alloc_Percent;

FUNCTION Get_Res_Demand_Alloc_Percent(
	p_demand_date 		IN 	DATE,
	p_assembly_item_id 	IN 	NUMBER,
	p_org_id 		IN 	NUMBER,
	p_instance_id 		IN 	NUMBER,
	p_dept_id 		IN 	NUMBER,
	p_res_id  		IN 	NUMBER,
	p_record_class 		IN 	VARCHAR2,
	p_demand_class 		IN 	VARCHAR2)
RETURN NUMBER
IS
	l_alloc_rule		NUMBER;
	l_alloc_percent		NUMBER;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('******** Get_Res_demand_Alloc_Percent ********');
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'p_demand_date =' || p_demand_date );
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'p_assembly_item_id =' || p_assembly_item_id);
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'p_org_id =' || p_org_id);
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'p_instance_id =' || p_instance_id);
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'p_dept_id =' || p_dept_id);
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'p_res_id =' || p_res_id);
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'p_record_class =' || p_record_class);
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'p_demand_class =' || p_demand_class);
  END IF;

  --Check if there is any allocation rule for the resource

      l_alloc_rule :=  MSC_AATP_FUNC.Get_DC_Alloc_Percent(p_instance_id, null, p_org_id, p_dept_id,
                p_res_id, p_demand_class, p_demand_date);

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'After resource DC Alloc rule :' ||to_char(l_alloc_rule));
  END IF;
      IF l_alloc_rule IS NULL THEN
         --For Bug # 1409203, if no rule at resource level
         --every supply demand must be counted.
         l_alloc_percent := 1;
         --l_alloc_percent := NULL;
      ELSIF p_record_class <> p_demand_class THEN
	 l_alloc_percent := 0;
      ELSE
      -- this is dependent demand, we see how we alocate the parent supply,
      -- and do the same thing for its demand
         l_alloc_percent :=  NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p_instance_id, p_assembly_item_id, p_org_id,
                null, null, p_demand_class, p_demand_date), l_alloc_rule);
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'After parent item DC Alloc Percent :' ||to_char(l_alloc_percent));
  END IF;
      END IF;
/*
      -- If no allocation percentage specified for any demand classes for
      -- specified time period, get the allocation percentage for department
      -- resource.
      IF l_alloc_percent IS NULL THEN
            l_alloc_percent :=  MSC_AATP_FUNC.Get_DC_Alloc_Percent(p_instance_id, null, p_org_id,
		p_dept_id, p_res_id, p_demand_class, p_demand_date);
      END IF;
*/
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Get_Res_Demand_Alloc_Percent: ' || 'Before Leaving Res Demand Alloc Percent :' ||to_char(l_alloc_percent));
  END IF;
      return (l_alloc_percent);

END GET_RES_DEMAND_ALLOC_PERCENT;


FUNCTION Get_Hierarchy_Demand_Class(
  p_partner_id         IN    NUMBER,
  p_partner_site_id    IN    NUMBER,
  p_inventory_item_id  IN    NUMBER,
  p_organization_id    IN    NUMBER,
  p_instance_id        IN    NUMBER,
  p_request_date       IN    DATE,
  p_level_id           IN    NUMBER,
  p_demand_class       IN    VARCHAR2)
RETURN VARCHAR2
IS
l_hierarchy_demand_class VARCHAR2(200);
l_partner_id NUMBER;
l_partner_site_id NUMBER;
l_class_code VARCHAR2(30);
l_inv_item_id NUMBER;
l_time_phase_id NUMBER;
l_temp NUMBER := 0;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('BEGIN Get_Hierarchy_Demand_Class');
       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'p_inventory_item_id : ' ||p_inventory_item_id);
       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'p_partner_id : ' ||p_partner_id);
       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'p_partner_site_id : ' ||p_partner_site_id);
       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'p_request_date : ' ||p_request_date);
       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'p_organization_id : ' ||p_organization_id);
       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'p_instance_id : ' ||p_instance_id);
       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'p_level_id : ' ||p_level_id);
       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'p_demand_class : ' ||p_demand_class);
    END IF;


    -- now this function supports 2 functionalities.
    -- CASE 1: to find the demand class for an incoming request
    --    G_Hierarchy_Profile is 1 .
    --
    -- CASE 2: to find the hierarchy demand class at a particular level
    --    p_level_id is not null
    G_HIERARCHY_PROFILE := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);

    IF (G_HIERARCHY_PROFILE = 1) THEN
        -- we are doing the demand class
        -- this would happen only in case 1
        l_hierarchy_demand_class := p_demand_class;

        IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') THEN

           BEGIN
             --diag_atp
             SELECT distinct time_phase_id, allocation_rule_name
             INTO   l_time_phase_id, MSC_ATP_PVT.G_ALLOCATION_RULE_NAME
             FROM   msc_item_hierarchy_mv
             WHERE  inventory_item_id = p_inventory_item_id
             AND    organization_id = p_organization_id
             AND    sr_instance_id = p_instance_id
             AND    greatest(p_request_date,trunc(sysdate)) between effective_date and disable_date; --bug3099066
           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_time_phase_id := NULL;
                    MSC_ATP_PVT.G_ALLOCATION_RULE_NAME := null;
           END;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_time_phase_id '||l_time_phase_id);
           END IF;

           IF l_time_phase_id  IS NOT NULL THEN

              BEGIN
                SELECT distinct demand_class
                INTO   l_hierarchy_demand_class
                FROM   msc_allocations
                WHERE  demand_class = p_demand_class
                AND    time_phase_id = l_time_phase_id
                --AND    level_id = 1 -- demand_class hence no level_id
                --AND    class = '-1' -- demand_class hence no customer_class
                ;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_hierarchy_demand_class := '-1'; -- Return Others
              END;

           ELSE

              l_hierarchy_demand_class := '-1'; -- Return Others

           END IF; -- IF l_time_phase_id IS NULL

        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||
                                 l_hierarchy_demand_class);
        END IF;

    ELSIF (G_HIERARCHY_PROFILE = 2) THEN
        -- we are doing the customer class
        -- get the local id of the customer and site
        IF p_partner_id  IS NOT NULL THEN
          BEGIN

            SELECT CUSTOMER_CLASS_CODE
            INTO   l_class_code
            FROM   msc_trading_partners
            WHERE  PARTNER_ID = p_partner_id;
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_class_code := NULL;
          END;
        END IF; -- IF p_customer_id  IS NOT NULL

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_class_code '||l_class_code);
        END IF;

        BEGIN
          --diag_atp
          SELECT distinct time_phase_id, allocation_rule_name
          INTO   l_time_phase_id, MSC_ATP_PVT.G_ALLOCATION_RULE_NAME
          FROM   msc_item_hierarchy_mv
          WHERE  inventory_item_id = p_inventory_item_id
          AND    organization_id = p_organization_id
          AND    sr_instance_id = p_instance_id
          AND    greatest(p_request_date,trunc(sysdate)) between effective_date and disable_date; --bug3099066
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_time_phase_id := NULL;
                    --diag_atp
                    MSC_ATP_PVT.G_ALLOCATION_RULE_NAME := null;
                    --bug 2424357: trat others as -1
                    --return '@@@';  -- since there is no time phase id
                    return '-1';  -- since there is no time phase id
                                   -- we won't find the dummy demand class
        END;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_time_phase_id '||l_time_phase_id);
        END IF;

        IF (p_partner_id IS NOT NULL AND p_level_id is null) OR
           (p_level_id in (2, 3)) THEN -- level 2 + level 3

            IF (p_partner_site_id IS NOT NULL AND p_level_id is null) OR
               (p_level_id = 3) THEN -- level 3
                -- level 3
                -- try to find the match demand class for
                -- that class_code+partner_id+partner_site_id
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 3');
                END IF;

                BEGIN
       	            SELECT distinct demand_class
                    INTO l_hierarchy_demand_class
                    FROM msc_allocations
                    WHERE level_id = 3
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code
                    AND partner_id = p_partner_id
                    AND partner_site_id = p_partner_site_id;
                EXCEPTION
	            WHEN NO_DATA_FOUND THEN
		        -- no match for
                        -- class_code + partner_id+_partner_site_id
		        l_hierarchy_demand_class := null;
                END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 3, after the first select');
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                END IF;


	        IF l_hierarchy_demand_class IS NULL THEN
		    -- could not find the match demand class
                    -- for class_code+partner_id+partner_site_id
                    -- try to find the match demand class for that
                    -- class_code+partner_id+others
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 3, first select fails');
                    END IF;

                    BEGIN
                        SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
                        FROM msc_allocations
                        WHERE level_id = 3
                        AND time_phase_id = l_time_phase_id
                        AND class = l_class_code
                        AND partner_id = p_partner_id
                        AND partner_site_id = -1;
                    Exception
                        WHEN NO_DATA_FOUND THEN
                            l_hierarchy_demand_class := null;
                    END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 3, after the second select');
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                END IF;

                END IF; -- IF l_hierarchy_demand_class IS NULL

                IF l_hierarchy_demand_class IS NULL THEN
		    -- could not find the match demand class for
                    -- (class_code+partner_id+partner_site_id)   and
                    -- (class_code+partner_id+others)

                    -- try to find the match demand class for that
                    -- class_code+others+others
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 3, second select fails');
                    END IF;

                    -- bug 1680773
                    -- before we try class+others+others,
                    -- try to see if we have a the exact class+partner defined.
                    -- if yes, the hierarchy for that class+partner exists
                    -- but it does not cover the site.
                    -- the name should be '@@@' which eventually will
                    -- match to 0 percent.
                    -- if no, then find class+others+others
                    ---bug 2424357: Since we have will always have 'OTHERS' we wouldn't need
                    --- to check the following condition
                    /*SELECT count(*)
                    INTO l_temp
                    FROM msc_allocations
                    WHERE level_id =3
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code
                    AND partner_id = p_partner_id;

                    IF l_temp = 0 THEN */

  		      BEGIN

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_time_phase_id = '||l_time_phase_id);
                           msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_class_code = '||l_class_code);
                        END IF;
			SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
			FROM msc_allocations
			WHERE level_id = 3
                        AND time_phase_id = l_time_phase_id
			AND class = l_class_code
			AND partner_id = -1
			AND partner_site_id = -1;
                      EXCEPTION
		        WHEN NO_DATA_FOUND THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'NO DATA FOUND');
                        END IF;
                        -- no match for
                        -- class_code + other+other
                        l_hierarchy_demand_class := null;
                      END;

                    /*ELSE
                      --bug 2424357: trat others as -1
                      --l_hierarchy_demand_class := '@@@';
                      l_hierarchy_demand_class := '-1';
                    END IF; */


                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 3, after the third select');
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                    END IF;


                END IF; -- l_hierarchy_demand_class IS NULL THEN


                IF l_hierarchy_demand_class IS NULL THEN
                    -- could not find the match demand class for
                    -- (class_code+partner_id+partner_site_id)   and
                    -- (class_code+partner_id+others)
                    -- (class_code+others+others)

                    -- try to find the match demand class for that
                    -- others+others+others

                    -- bug 1680773
                    -- try to see if we have a the exact class defined.
                    -- if yes, the hierarchy for that class does exist
                    -- but does not cover the customer.  so
                    -- the name should be '@@@' which eventually will
                    -- match to 0 percent.
                    -- if no, then find others+others+others

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 3, third select fails');
                    END IF;

                    /*SELECT count(*)
                    INTO l_temp
                    FROM msc_allocations
                    WHERE level_id =3
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code;

                    IF l_temp = 0 THEN
                    */

                      BEGIN
                        SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
                        FROM msc_allocations
                        WHERE level_id = 3
                        AND time_phase_id = l_time_phase_id
                        AND class = '-1'
                        AND partner_id = -1
                        AND partner_site_id = -1;
                      Exception
                        WHEN NO_DATA_FOUND THEN
                            --bug 2424357
                            --l_hierarchy_demand_class := null;
                            l_hierarchy_demand_class := '-1';
                      END;
                    /*
                    ELSE
                      --bug 2424357: trat others as -1
                      --l_hierarchy_demand_class := '@@@';
                      l_hierarchy_demand_class := '-1';
                    END IF;
                    */
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 3, after the 4th select');
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                    END IF;


                END IF; -- IF l_hierarchy_demand_class IS NULL
            ELSIF (p_partner_site_id IS NULL AND p_level_id is null) OR
                  (p_level_id = 2) THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 2');
                END IF;

                -- level 2
                -- try to find the match demand class for
                -- that class_code+partner_id
                BEGIN
                    SELECT distinct demand_class
                    INTO l_hierarchy_demand_class
                    FROM msc_allocations
                    WHERE level_id = 2
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code
                    AND partner_id = p_partner_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        -- no match for
                        -- class_code + partner_id
                        l_hierarchy_demand_class := null;
                END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 2, after the first select');
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                END IF;

                IF l_hierarchy_demand_class IS NULL THEN
                    -- could not find the match demand class
                    -- for class_code+partner_id
                    -- try to find the match demand class for that
                    -- class_code+others

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 2, first select fails');
                    END IF;

                    BEGIN
                        SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
                        FROM msc_allocations
                        WHERE level_id = 2
                        AND time_phase_id = l_time_phase_id
                        AND class = l_class_code
                        AND partner_id = -1;
                    Exception
                        WHEN NO_DATA_FOUND THEN
                            l_hierarchy_demand_class := null;
                    END;
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 2, after the second select');
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                    END IF;

                END IF; -- IF l_hierarchy_demand_class IS NULL
                -- bug 1680773
                IF l_hierarchy_demand_class IS NULL THEN
                    -- could not find the match demand class
                    -- for (class_code+partner_id) and
                    -- (class_code+others )
                    -- try to see if we have  the exact class defined.
                    -- if yes, the hierarchy for that class does exist
                    -- but does not cover the customer.  so
                    -- the name should be '@@@' which eventually will
                    -- match to 0 percent.
                    -- if no, then find others+others

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 2, second select fails');
                    END IF;
                    /*
                    SELECT count(*)
                    INTO l_temp
                    FROM msc_allocations
                    WHERE level_id =2
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code;

                    IF l_temp = 0 THEN
                    */
                      BEGIN
                        SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
                        FROM msc_allocations
                        WHERE level_id =2
                        AND time_phase_id = l_time_phase_id
                        AND class = '-1'
                        AND partner_id = -1;
                      Exception
                            WHEN NO_DATA_FOUND THEN
                              -- 2424357: Since this is the last search
                              -- and we have't found anything. That means
                              -- this customer belongs to others
                              --l_hierarchy_demand_class := null;
                              l_hierarchy_demand_class := '-1';

                      END;
                    /*
                    ELSE
                      --bug 2424357: trat others as -1
                      --l_hierarchy_demand_class := '@@@';
                      l_hierarchy_demand_class := '-1';
                    END IF;
                    */
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 2, after the third select');
                       msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                    END IF;
                END IF; -- IF l_hierarchy_demand_class IS NULL

            END IF; -- IF (p_partner_site_id IS NOT NULL AND p_level_id is null)
                    --  OR (p_level_id in (2,3))

        ELSIF(p_partner_id IS NULL AND p_level_id is null) OR
             (p_level_id = 1) THEN

            -- level 1
            -- since we do not have the class info which comes from
            -- partner_id, assume it is others
            -- find the match demand class for others

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 1');
            END IF;
            IF p_level_id = 1 THEN
                BEGIN
                    SELECT distinct demand_class
                    INTO l_hierarchy_demand_class
                    FROM msc_allocations
                    WHERE level_id = 1
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_hierarchy_demand_class := null;
                END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 1, after the first select');
                   msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                END IF;

            END IF;

            IF l_hierarchy_demand_class IS NULL THEN

              BEGIN
                SELECT distinct demand_class
                INTO l_hierarchy_demand_class
                FROM msc_allocations
                WHERE level_id = 1
                AND time_phase_id = l_time_phase_id
                AND class = '-1';
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- this should not happen
                    --2424357
                    l_hierarchy_demand_class := '-1';
              END;

            END IF; -- IF l_hierarchy_demand_class IS NULL

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'level 1, after the second select');
               msc_sch_wb.atp_debug('Get_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
            END IF;

        END IF; --  IF p_partner_id IS NOT NULL THEN
    END IF; -- IF (G_HIERARCHY_PROFILE = 1)

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('END Get_Hierarchy_Demand_Class');
    END IF;
    --bug 2424357: trat others as -1
    --RETURN NVL(l_hierarchy_demand_class, '@@@'); -- 1680773
    RETURN NVL(l_hierarchy_demand_class, '-1'); -- 1680773

END Get_Hierarchy_Demand_Class;


FUNCTION Get_Allowed_Stolen_Percent(
  p_instance_id         IN NUMBER,
  p_inv_item_id         IN NUMBER,
  p_org_id              IN NUMBER,
  p_dept_id             IN NUMBER,
  p_res_id              IN NUMBER,
  p_demand_class        IN VARCHAR2,
  p_request_date        IN DATE)
RETURN NUMBER
IS
	l_alloc_percent NUMBER := 0.0;
        l_rule_name     VARCHAR2(30);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('******** Get_Allowed_Stolen_Percent ********');
     msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'p_instance_id =' || p_instance_id);
     msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'p_inv_item_id =' || p_inv_item_id);
     msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'p_org_id =' || p_org_id);
     msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'p_dept_id =' || p_dept_id);
     msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'p_res_id =' || p_res_id);
     msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'p_demand_class =' || p_demand_class);
     msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'p_request_date =' || p_request_date );
  END IF;

  IF p_inv_item_id is not null THEN
        -- Get the allocation percent for the item/demand class. If no rule found,
	-- check if a rule on the specified date exists for any demand class
	-- for the specific item, take allocation percentage as NULL.
	-- Though we will treat NULL as 1, but we need to differentiate them
	-- so as to group demands/ supplies by demand classes. - ngoel 8/31/2000.
	BEGIN
		-- Changes For bug 2384551 start
		IF G_HIERARCHY_PROFILE = 1 THEN

      		SELECT (allocation_percent- NVL(min_allocation_percent,0))/100
	      	INTO   l_alloc_percent
      		FROM   msc_item_hierarchy_mv
      		WHERE  demand_class = p_demand_class
      		AND    inventory_item_id = p_inv_item_id
      		AND    organization_id = p_org_id
      		AND    sr_instance_id = p_instance_id
      		AND    p_request_date between effective_date and disable_date
		AND    level_id = -1;

		ELSE

		SELECT (allocation_percent- NVL(min_allocation_percent,0))/100
                INTO   l_alloc_percent
                FROM   msc_item_hierarchy_mv
                WHERE  demand_class = p_demand_class
                AND    inventory_item_id = p_inv_item_id
                AND    organization_id = p_org_id
                AND    sr_instance_id = p_instance_id
                AND    p_request_date between effective_date and disable_date
                AND    level_id <> -1;

		END IF;
		-- Changes For bug 2384551 start

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		-- Changes For bug 2384551 start
		IF G_HIERARCHY_PROFILE = 1  THEN

      		SELECT DECODE(count(allocation_percent), 0, NULL, 0)
	      	INTO   l_alloc_percent
      		FROM   msc_item_hierarchy_mv
      		WHERE  inventory_item_id = p_inv_item_id
      		AND    organization_id = p_org_id
      		AND    sr_instance_id = p_instance_id
      		AND    p_request_date between effective_date and disable_date
		AND    level_id = -1;

		ELSE

		SELECT DECODE(count(allocation_percent), 0, NULL, 0)
                INTO   l_alloc_percent
                FROM   msc_item_hierarchy_mv
                WHERE  inventory_item_id = p_inv_item_id
                AND    organization_id = p_org_id
                AND    sr_instance_id = p_instance_id
                AND    p_request_date between effective_date and disable_date
                AND    level_id <> -1;

		END IF;
		-- Changes For bug 2384551 end
	   WHEN OTHERS THEN
		l_alloc_percent := NULL;
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Exception in Get_Allowed_Stolen_Percent');
		END IF;
	END;

  ELSE
        -- Get the allocation percent for the dept/res/demand class
	BEGIN
		-- Changes For bug 2384551 start
		IF G_HIERARCHY_PROFILE = 1 THEN

        	SELECT (allocation_percent- NVL(min_allocation_percent, 0))/100
	        INTO   l_alloc_percent
       	 	FROM   msc_resource_hierarchy_mv
        	WHERE  demand_class = p_demand_class
	        AND    department_id = p_dept_id
	        AND    resource_id = p_res_id
        	AND    organization_id = p_org_id
        	AND    sr_instance_id = p_instance_id
        	AND    p_request_date between effective_date and disable_date
		AND    level_id = -1;

		ELSE

		SELECT (allocation_percent- NVL(min_allocation_percent, 0))/100
                INTO   l_alloc_percent
                FROM   msc_resource_hierarchy_mv
                WHERE  demand_class = p_demand_class
                AND    department_id = p_dept_id
                AND    resource_id = p_res_id
                AND    organization_id = p_org_id
                AND    sr_instance_id = p_instance_id
                AND    p_request_date between effective_date and disable_date
                AND    level_id <> -1;

		END IF;
		-- Changes For bug 2384551 end

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		-- Changes For bug 2384551 start
		IF G_HIERARCHY_PROFILE = 1 THEN

      		SELECT DECODE(count(allocation_percent), 0, NULL, 0)
	        INTO   l_alloc_percent
       	 	FROM   msc_resource_hierarchy_mv
        	WHERE  department_id = p_dept_id
	        AND    resource_id = p_res_id
        	AND    organization_id = p_org_id
        	AND    sr_instance_id = p_instance_id
        	AND    p_request_date between effective_date and disable_date
		AND    level_id = -1;

		ELSE

		SELECT DECODE(count(allocation_percent), 0, NULL, 0)
                INTO   l_alloc_percent
                FROM   msc_resource_hierarchy_mv
                WHERE  department_id = p_dept_id
                AND    resource_id = p_res_id
                AND    organization_id = p_org_id
                AND    sr_instance_id = p_instance_id
                AND    p_request_date between effective_date and disable_date
                AND    level_id <> -1;

		END IF;
		-- Changes For bug 2384551 end
	   WHEN OTHERS THEN
		l_alloc_percent := NULL;
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Exception in Get_Allowed_Stolen_Percent');
		END IF;
	END;

  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'Call to alloc:' || to_char(l_alloc_percent));
  END IF;
  return (l_alloc_percent);
EXCEPTION
  WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Allowed_Stolen_Percent: ' || 'Error code:' || to_char(sqlcode));
      END IF;
      return(0.0);
END Get_Allowed_Stolen_Percent;


FUNCTION Get_Res_Hierarchy_Demand_Class(
  p_partner_id         IN    NUMBER,
  p_partner_site_id    IN    NUMBER,
  p_department_id      IN    NUMBER,
  p_resource_id        IN    NUMBER,
  p_organization_id    IN    NUMBER,
  p_instance_id        IN    NUMBER,
  p_request_date       IN    DATE,
  p_level_id           IN    NUMBER,
  p_demand_class       IN    VARCHAR2)
RETURN VARCHAR2
IS

l_hierarchy_demand_class VARCHAR2(200);
l_partner_id NUMBER;
l_partner_site_id NUMBER;
l_class_code VARCHAR2(30);
l_inv_item_id NUMBER;
l_time_phase_id NUMBER;
l_temp NUMBER := 0;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'BEGIN Get_Hierarchy_Demand_Class');
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_department_id : ' ||p_department_id);
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_resource_id : ' ||p_resource_id);
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_partner_id : ' ||p_partner_id);
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_partner_site_id : ' ||p_partner_site_id);
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_request_date : ' ||p_request_date);
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_organization_id : ' ||p_organization_id);
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_instance_id : ' ||p_instance_id);
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_level_id : ' ||p_level_id);
       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'p_demand_class : ' ||p_demand_class);
    END IF;


    -- now this function supports 2 functionalities.
    -- CASE 1: to find the demand class for an incoming request
    --    G_Hierarchy_Profile is 1 .
    --
    -- CASE 2: to find the hierarchy demand class at a particular level
    --    p_level_id is not null
    G_HIERARCHY_PROFILE := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);

    IF (G_HIERARCHY_PROFILE = 1) THEN
        -- we are doing the demand class
        -- this would happen only in case 1
        l_hierarchy_demand_class := p_demand_class;

        IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') THEN

           BEGIN
             --diag_atp
             SELECT distinct time_phase_id, allocation_rule_name
             INTO   l_time_phase_id, MSC_ATP_PVT.G_ALLOCATION_RULE_NAME
             FROM   msc_resource_hierarchy_mv
             WHERE  resource_id = p_resource_id
             AND    department_id = p_department_id
             AND    organization_id = p_organization_id
             AND    sr_instance_id = p_instance_id
             AND    GREATEST(p_request_date,trunc(sysdate)) between effective_date and disable_date; --bug3333114
           EXCEPTION
                WHEN NO_DATA_FOUND THEN

                    l_time_phase_id := NULL;
                    --diag_atp
                    MSC_ATP_PVT.G_ALLOCATION_RULE_NAME := null;
           END;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_time_phase_id '||l_time_phase_id);
           END IF;

           IF l_time_phase_id  IS NOT NULL THEN

              BEGIN
                SELECT distinct demand_class
                INTO   l_hierarchy_demand_class
                FROM   msc_allocations
                WHERE  demand_class = p_demand_class
                AND    time_phase_id = l_time_phase_id
                --AND    level_id = 1 -- demand_class hence no level_id
                --AND    class = '-1' -- demand_class hence no customer_class
                ;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_hierarchy_demand_class := '-1'; -- Return Others
              END;

           ELSE

              l_hierarchy_demand_class := '-1'; -- Return Others

           END IF; -- IF l_time_phase_id IS NULL

        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||
                                 l_hierarchy_demand_class);
        END IF;

    ELSIF (G_HIERARCHY_PROFILE = 2) THEN
        -- we are doing the customer class
        -- get the local id of the customer and site
        IF p_partner_id  IS NOT NULL THEN
          BEGIN

            SELECT CUSTOMER_CLASS_CODE
            INTO   l_class_code
            FROM   msc_trading_partners
            WHERE  PARTNER_ID = p_partner_id;
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_class_code := NULL;
          END;
        END IF; -- IF p_customer_id  IS NOT NULL

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_class_code '||l_class_code);
        END IF;

        BEGIN

          SELECT distinct time_phase_id, allocation_rule_name
          INTO   l_time_phase_id, MSC_ATP_PVT.G_ALLOCATION_RULE_NAME
          FROM   msc_resource_hierarchy_mv
          WHERE  resource_id = p_resource_id
          AND    department_id = p_department_id
          AND    organization_id = p_organization_id
          AND    sr_instance_id = p_instance_id
          AND    greatest(p_request_date,trunc(sysdate)) between effective_date and disable_date; --bug3333114
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_time_phase_id := NULL;
                    --diag_atp
                    MSC_ATP_PVT.G_ALLOCATION_RULE_NAME := null;
                    --bug 2424357: trat others as -1
                    --return '@@@';  -- since there is no time phase id
                    return '-1';  -- since there is no time phase id
                                   -- we won't find the dummy demand class
        END;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_time_phase_id '||l_time_phase_id);
        END IF;

        IF (p_partner_id IS NOT NULL AND p_level_id is null) OR
           (p_level_id in (2, 3)) THEN -- level 2 + level 3

            IF (p_partner_site_id IS NOT NULL AND p_level_id is null) OR
               (p_level_id = 3) THEN -- level 3
                -- level 3
                -- try to find the match demand class for
                -- that class_code+partner_id+partner_site_id
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 3');
                END IF;

                BEGIN
       	            SELECT distinct demand_class
                    INTO l_hierarchy_demand_class
                    FROM msc_allocations
                    WHERE level_id = 3
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code
                    AND partner_id = p_partner_id
                    AND partner_site_id = p_partner_site_id;
                EXCEPTION
	            WHEN NO_DATA_FOUND THEN
		        -- no match for
                        -- class_code + partner_id+_partner_site_id
		        l_hierarchy_demand_class := null;
                END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 3, after the first select');
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                END IF;


	        IF l_hierarchy_demand_class IS NULL THEN
		    -- could not find the match demand class
                    -- for class_code+partner_id+partner_site_id
                    -- try to find the match demand class for that
                    -- class_code+partner_id+others
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 3, first select fails');
                    END IF;

                    BEGIN
                        SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
                        FROM msc_allocations
                        WHERE level_id = 3
                        AND time_phase_id = l_time_phase_id
                        AND class = l_class_code
                        AND partner_id = p_partner_id
                        AND partner_site_id = -1;
                    Exception
                        WHEN NO_DATA_FOUND THEN
                            l_hierarchy_demand_class := null;
                    END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 3, after the second select');
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                END IF;

                END IF; -- IF l_hierarchy_demand_class IS NULL

                IF l_hierarchy_demand_class IS NULL THEN
		    -- could not find the match demand class for
                    -- (class_code+partner_id+partner_site_id)   and
                    -- (class_code+partner_id+others)

                    -- try to find the match demand class for that
                    -- class_code+others+others
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 3, second select fails');
                    END IF;

  		    BEGIN

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_time_phase_id = '||l_time_phase_id);
                           msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_class_code = '||l_class_code);
                        END IF;
			SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
			FROM msc_allocations
			WHERE level_id = 3
                        AND time_phase_id = l_time_phase_id
			AND class = l_class_code
			AND partner_id = -1
			AND partner_site_id = -1;
                    EXCEPTION
		        WHEN NO_DATA_FOUND THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'NO DATA FOUND');
                        END IF;
                        -- no match for
                        -- class_code + other+other
                        l_hierarchy_demand_class := null;
                    END;



                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 3, after the third select');
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                    END IF;


                END IF; -- l_hierarchy_demand_class IS NULL THEN


                IF l_hierarchy_demand_class IS NULL THEN
                    -- could not find the match demand class for
                    -- (class_code+partner_id+partner_site_id)   and
                    -- (class_code+partner_id+others)
                    -- (class_code+others+others)

                    -- try to find the match demand class for that
                    -- others+others+others

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 3, third select fails');
                    END IF;

                    BEGIN
                        SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
                        FROM msc_allocations
                        WHERE level_id = 3
                        AND time_phase_id = l_time_phase_id
                        AND class = '-1'
                        AND partner_id = -1
                        AND partner_site_id = -1;
                    Exception
                        WHEN NO_DATA_FOUND THEN
                            l_hierarchy_demand_class := '-1';
                    END;

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 3, after the 4th select');
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                    END IF;


                END IF; -- IF l_hierarchy_demand_class IS NULL
            ELSIF (p_partner_site_id IS NULL AND p_level_id is null) OR
                  (p_level_id = 2) THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 2');
                END IF;

                -- level 2
                -- try to find the match demand class for
                -- that class_code+partner_id
                BEGIN
                    SELECT distinct demand_class
                    INTO l_hierarchy_demand_class
                    FROM msc_allocations
                    WHERE level_id = 2
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code
                    AND partner_id = p_partner_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        -- no match for
                        -- class_code + partner_id
                        l_hierarchy_demand_class := null;
                END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 2, after the first select');
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                END IF;

                IF l_hierarchy_demand_class IS NULL THEN
                    -- could not find the match demand class
                    -- for class_code+partner_id
                    -- try to find the match demand class for that
                    -- class_code+others

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 2, first select fails');
                    END IF;

                    BEGIN
                        SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
                        FROM msc_allocations
                        WHERE level_id = 2
                        AND time_phase_id = l_time_phase_id
                        AND class = l_class_code
                        AND partner_id = -1;
                    Exception
                        WHEN NO_DATA_FOUND THEN
                            l_hierarchy_demand_class := null;
                    END;
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 2, after the second select');
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                    END IF;

                END IF; -- IF l_hierarchy_demand_class IS NULL
                -- bug 1680773
                IF l_hierarchy_demand_class IS NULL THEN
                    -- could not find the match demand class
                    -- for (class_code+partner_id) and
                    -- (class_code+others )

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 2, second select fails');
                    END IF;

                    BEGIN
                        SELECT distinct demand_class
                        INTO l_hierarchy_demand_class
                        FROM msc_allocations
                        WHERE level_id =2
                        AND time_phase_id = l_time_phase_id
                        AND class = '-1'
                        AND partner_id = -1;
                    Exception
                            WHEN NO_DATA_FOUND THEN
                              l_hierarchy_demand_class := '-1';

                    END;
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 2, after the third select');
                       msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                    END IF;
                END IF; -- IF l_hierarchy_demand_class IS NULL

            END IF; -- IF (p_partner_site_id IS NOT NULL AND p_level_id is null)
                    --  OR (p_level_id in (2,3))

        ELSIF(p_partner_id IS NULL AND p_level_id is null) OR
             (p_level_id = 1) THEN

            -- level 1
            -- since we do not have the class info which comes from
            -- partner_id, assume it is others
            -- find the match demand class for others

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 1');
            END IF;
            IF p_level_id = 1 THEN
                BEGIN
                    SELECT distinct demand_class
                    INTO l_hierarchy_demand_class
                    FROM msc_allocations
                    WHERE level_id = 1
                    AND time_phase_id = l_time_phase_id
                    AND class = l_class_code;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_hierarchy_demand_class := null;
                END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 1, after the first select');
                   msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
                END IF;

            END IF;

            IF l_hierarchy_demand_class IS NULL THEN

              BEGIN
                SELECT distinct demand_class
                INTO l_hierarchy_demand_class
                FROM msc_allocations
                WHERE level_id = 1
                AND time_phase_id = l_time_phase_id
                AND class = '-1';
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- this should not happen
                    l_hierarchy_demand_class := '-1';
              END;

            END IF; -- IF l_hierarchy_demand_class IS NULL

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'level 1, after the second select');
               msc_sch_wb.atp_debug('Get_Res_Hierarchy_Demand_Class: ' || 'l_hierarchy_demand_class = '||l_hierarchy_demand_class);
            END IF;

        END IF; --  IF p_partner_id IS NOT NULL THEN
    END IF; -- IF (G_HIERARCHY_PROFILE = 1)

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('END Get_RES_Hierarchy_Demand_Class');
    END IF;
    --bug 2424357: trat others as -1
    --RETURN NVL(l_hierarchy_demand_class, '@@@'); -- 1680773
    RETURN NVL(l_hierarchy_demand_class, '-1'); -- 1680773

END Get_Res_Hierarchy_Demand_Class;

END MSC_AATP_FUNC;

/
