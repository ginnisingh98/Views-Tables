--------------------------------------------------------
--  DDL for Package Body MSC_AATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_AATP_PVT" AS
/* $Header: MSCAATPB.pls 120.4.12010000.11 2009/08/24 06:42:34 sbnaik ship $  */

G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MSC_AATP_PVT';
-- ship_rec_cal
G_USER_ID               CONSTANT NUMBER := FND_GLOBAL.USER_ID;

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

-- AATP Forward Consumption rajjain
G_ATP_FW_CONSUME_METHOD NUMBER := NVL(FND_PROFILE.VALUE('MSC_ATP_FORWARD_CONSUME_METHOD'), 1);
----------------------------------------------------------------------

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE Print_Period_Qty(
	p_msg		IN varchar2,
	p_atp_info	IN MRP_ATP_PVT.ATP_Info
) IS
	i	PLS_INTEGER;
BEGIN
	i := p_atp_info.atp_qty.FIRST;
	while i is not null loop
		msc_sch_wb.atp_debug(p_msg || p_atp_info.atp_period(i) || ':' ||
			p_atp_info.atp_qty(i));
		i := p_atp_info.atp_qty.NEXT(i);
	end loop;
END Print_Period_Qty;


PROCEDURE move_SD_plsql_into_SD_temp(
	x_atp_supply_demand 	IN OUT NOCOPY  MRP_ATP_PUB.ATP_Supply_Demand_Typ
) IS
	null_atp_supply_demand  MRP_ATP_PUB.ATP_Supply_Demand_Typ;
	-- ship_rec_cal
	l_sysdate               DATE := trunc(sysdate); --4135752
BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('**** PROCEDURE move_SD_plsql_into_SD_temp ****');
	END IF;

	FORALL k IN 1..x_atp_supply_demand.Level.COUNT
		INSERT INTO msc_atp_sd_details_temp (
			session_id,
			Atp_Level,
			order_line_id,
			scenario_id,
			inventory_item_id,
			request_item_id,
			department_id,
			resource_id,
			Supplier_id,
			Supplier_Site_id,
			UOM_code,
			Supply_Demand_Type,
			Supply_Demand_Source_Type,
			Identifier1,
			Supply_Demand_Date,
			Supply_Demand_Quantity,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
			-- time_phased_atp changes begin
			organization_id,
			original_item_id,
                        original_supply_demand_type,
                        original_demand_date,
                        original_demand_quantity,
                        allocated_quantity,
                        pf_display_flag
                        -- time_phased_atp changes end
		) VALUES (
			MSC_ATP_PVT.G_SESSION_ID,
			x_atp_supply_demand.level(k),
			x_atp_supply_demand.identifier(k),
			x_atp_supply_demand.scenario_id(k),
			x_atp_supply_demand.inventory_item_id(k),
			x_atp_supply_demand.request_item_id(k),
			x_atp_supply_demand.department_id(k),
			x_atp_supply_demand.resource_id(k),
			x_atp_supply_demand.supplier_id(k),
			x_atp_supply_demand.supplier_site_id(k),
			x_atp_supply_demand.uom(k),
			x_atp_supply_demand.supply_demand_type(k),
			x_atp_supply_demand.supply_demand_source_type(k),
			x_atp_supply_demand.identifier1(k),
			x_atp_supply_demand.supply_demand_date(k),
	                x_atp_supply_demand.supply_demand_quantity(k),
        		-- ship_rec_cal changes begin
        		l_sysdate,
        		G_USER_ID,
        		l_sysdate,
        		G_USER_ID,
        		G_USER_ID,
        		-- ship_rec_cal changes end
			-- time_phased_atp changes begin
			x_atp_supply_demand.organization_id(k),
			x_atp_supply_demand.original_item_id(k),
                        x_atp_supply_demand.original_supply_demand_type(k),
                        x_atp_supply_demand.original_demand_date(k),
                        x_atp_supply_demand.original_demand_quantity(k),
                        x_atp_supply_demand.allocated_quantity(k),
                        x_atp_supply_demand.pf_display_flag(k)
			-- time_phased_atp changes end
		);
	-- end forall

	x_atp_supply_demand := null_atp_supply_demand;

END move_SD_plsql_into_SD_temp;

---------------------------------------------------------------------------

-- 2859130
-- constrained plan
-- from previous resource requirements fix 2809639, optimized plan really means
-- constrained plan. here opt=constrained, unopt=unconstrained
--avjain Plan by request date  all netting sqls have been changed to incorporate Plan by Request Date Enhancements
PROCEDURE item_alloc_avail_opt (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sys_next_date	IN DATE,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail_opt: constrained plan: ' || p_plan_id);
        END IF;
              -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
              -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
              SELECT        SD_DATE,
                           SUM(SD_QTY)
             BULK COLLECT INTO
                           x_atp_dates,
                           x_atp_qtys
             FROM (
                   SELECT  --C.PRIOR_DATE SD_DATE, -- 2859130
			  GREATEST(
                           TRUNC(DECODE(RECORD_SOURCE,
                           	2,
                           	NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                           	DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                           	2,
                           	(NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                           	NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                           	 p_sys_next_date)SD_DATE, --plan by request date,promise date, schedule date--3099066
                           -- -1* D.USING_REQUIREMENT_QUANTITY*
                           -1*(D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))* --5027568
                           DECODE(DECODE(G_HIERARCHY_PROFILE,
                           /*------------------------------------------------------------------------+
                           | rajjain begin 07/19/2002                                                |
                           |                                                                         |
                           | Case 1: For internal sales orders [origination type is in (6,30) and    |
                           |            source_organization_id is not null and <> organization_id]   |
                           |                  Return NULL                                            |
                           | Case 2: For others if DEMAND_CLASS is null then return null             |
                           |          else if p_demand_class is '-1' then call                       |
                           |            Get_Hierarchy_Demand_class else return DEMAND_CLASS          |
                           +------------------------------------------------------------------------*/
                              1, decode(decode (d.origination_type, -100, 30,d.origination_type),
                                 6, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(
                                                  DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                                      --plan by request date,promise date, schedule date
                                             		p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             					p_level_id, D.DEMAND_CLASS),  --plan by request date,promise date, schedule date
                                             D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(
                                             	    DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             			p_level_id, D.DEMAND_CLASS),  --plan by request date,promise date, schedule date
                                             D.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 30, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(
                                             	    DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             				p_level_id, D.DEMAND_CLASS),  --plan by request date,promise date, schedule date
                                             D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(
                                             	    DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             				p_level_id, D.DEMAND_CLASS),  --plan by request date,promise date, schedule date
                                             D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(
                                             	    DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             			p_level_id, D.DEMAND_CLASS),  --plan by request date,promise date, schedule date
                                             D.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, TRUNC(
                                                   DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                          			p_level_id, D.DEMAND_CLASS),  --plan by request date,promise date, schedule date
                                          D.DEMAND_CLASS))),
                              -- rajjain end
                              2, DECODE(D.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                   0, TO_CHAR(NULL),
                                 -- rajjain begin 07/19/2002
                                 decode(decode (d.origination_type, -100, 30,d.origination_type),
                                    6, decode(d.source_organization_id,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id,
                                             TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id,
                                             TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                             p_level_id, NULL),
                                       d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    30, decode(d.source_organization_id,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id,
                                             	TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id,
                                             	TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                             p_level_id, NULL),
                                       d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id,
                                             TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                       p_item_id, p_org_id, p_instance_id,
                                       	          TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))--plan by request date,promise date, schedule date
                                       				,p_level_id, NULL)))),
                                 -- rajjain end 07/19/2002
                           p_demand_class, 1,
                             Decode(D.Demand_Class, NULL, --4365873 If l_demand_class is not null and demand class is populated
                             -- on  supplies record then 0 should be allocated.
                              MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                 D.DEMAND_ID,
		                                 TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                 D.USING_ASSEMBLY_ITEM_ID,
                                 DECODE(D.SOURCE_ORGANIZATION_ID,
                                    -23453, null,
                                    D.SOURCE_ORGANIZATION_ID), -- 1665483
                                 p_item_id,
                                 p_org_id, -- 1665483
                                 p_instance_id,
                                 decode (d.origination_type, -100, 30,d.origination_type), --5027568
                                 DECODE(G_HIERARCHY_PROFILE,
                                 /*-----------------------------------------------------------------+
                                 | rajjain begin 07/19/2002                                         |
                                 |                                                                  |
                                 | Case 1: For internal sales orders [origination type is in (6,30) |
                                 |         and source_organization_id is not null                   |
                                 |         and <> organization_id] -> Return p_demand_class         |
                                 | Case 2: For others if DEMAND_CLASS is null then return null      |
                                 |           else if p_demand_class is '-1' then call               |
                                 |           Get_Hierarchy_Demand_class else return DEMAND_CLASS    |
                                 +-----------------------------------------------------------------*/
                                    1, decode(decode (d.origination_type, -100, 30,d.origination_type),
                                       6, decode(d.source_organization_id,
                                          NULL, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, TRUNC(
                                                   DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                                   	p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          -23453, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id,
                                                   	TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                                   			p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id,
                                                   TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                                   		p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          p_demand_class),
                                    30, decode(d.source_organization_id,
                                       NULL, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id,
                                                    TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                                		p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       -23453, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id,
                                                     TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                                			p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id,
                                                     TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), --plan by request date,promise date, schedule date
                                                	p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       p_demand_class),
                                    DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(
                                             	DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))--plan by request date,promise date, schedule date
                                             		, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS))),
                                    -- rajjain end
                                    2, DECODE(D.CUSTOMER_ID, NULL, p_demand_class,
                                                   0, p_demand_class,
                                       -- rajjain begin 07/19/2002
                                       decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                          6, decode(d.source_organization_id,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          30, decode(d.source_organization_id,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                             p_item_id, p_org_id, p_instance_id,
                                             TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),p_level_id, NULL)))),
                                       -- rajjain end 07/19/2002
                                       p_demand_class,
                                       p_level_id),0)) SD_QTY --4365873
                   FROM    -- MSC_CALENDAR_DATES C, -- 2859130
                           MSC_DEMANDS D
                   WHERE        D.PLAN_ID = p_plan_id
                   AND                D.SR_INSTANCE_ID = p_instance_id
                   AND                D.INVENTORY_ITEM_ID = p_item_id
                   AND         D.ORGANIZATION_ID = p_org_id
                   AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
                   AND         D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- For summary enhancement
                   -- 2859130
                   -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
                   -- Bug 1530311, need to exclude forecast, ngoel 12/05/2000
                   -- AND                C.CALENDAR_CODE = p_cal_code
                   -- AND                C.EXCEPTION_SET_ID = p_cal_exc_set_id
                   -- AND         C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                   -- since we store repetitive schedule demand in different ways for
                   -- ods (total quantity on start date) and pds  (daily quantity from
                   -- start date to end date), we need to make sure we only select work day
                   -- for pds's repetitive schedule demand.
                   -- AND         C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE) AND
                   --             TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                   --                       D.USING_ASSEMBLY_DEMAND_DATE))
                   -- AND         (( D.ORIGINATION_TYPE = 4
                   --         AND C.SEQ_NUM IS NOT NULL) OR
                   --         ( D.ORIGINATION_TYPE  <> 4))
                   -- AND         C.PRIOR_DATE < NVL(p_itf,
                   --                  C.PRIOR_DATE + 1)
                   --bug3693892 added trunc
                   AND   TRUNC(DECODE(RECORD_SOURCE,
                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) <
                         TRUNC(NVL(p_itf,DECODE(RECORD_SOURCE,
                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))+1))
                   UNION ALL
                   SELECT  --C.NEXT_DATE SD_DATE, -- 2859130
                           --TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) SD_DATE,
                           GREATEST(TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)),p_sys_next_date) SD_DATE,--3099066
                           NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)*
                              DECODE(DECODE(G_HIERARCHY_PROFILE,
                                     --2424357: Convert the demand calls in case of others for
                                     --- demand class allocated ATP
                                     1, DECODE(S.DEMAND_CLASS, null, null,
                                        DECODE(p_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         null,
                                                         null,
                                                         S.inventory_item_id,
                                                         p_org_id,
                                                         p_instance_id,
                                                         trunc(nvl(S.firm_date, S.new_schedule_date)),
                                                         -- c.next_date, -- 2859130
                                                         p_level_id,
                                                         S.DEMAND_CLASS),S.DEMAND_CLASS)),
                                     2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                       0, TO_CHAR(NULL),
                                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         S.CUSTOMER_ID,
                                                         S.SHIP_TO_SITE_ID,
                                                         S.inventory_item_id,
                                                         p_org_id,
                                                         p_instance_id,
                                                         trunc(nvl(S.firm_date, S.new_schedule_date)),
                                                         -- c.next_date, -- 2859130
                                                         p_level_id,
                                                         NULL))),
                                 p_demand_class, 1,
                                 NULL, nvl(MIHM.allocation_percent/100,1), --4365873
                                 /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           s.inventory_item_id,
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           -- c.next_date -- 2859130
                                           trunc(nvl(s.firm_date, s.new_schedule_date))), 1),*/
                                 DECODE(
                                  MIHM.allocation_percent/100, --4365873
                                 /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           s.inventory_item_id,
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           -- c.next_date -- 2859130
                                           trunc(nvl(s.firm_date, s.new_schedule_date))),*/
                                   NULL, 1,
                                 0)) SD_QTY
                   FROM    -- MSC_CALENDAR_DATES C, -- 2859130
                           MSC_SUPPLIES S,MSC_ITEM_HIERARCHY_MV MIHM
                   WHERE   S.PLAN_ID = p_plan_id
                   AND     S.SR_INSTANCE_ID = p_instance_id
                   AND     S.INVENTORY_ITEM_ID = p_item_id
                   AND     S.ORGANIZATION_ID = p_org_id
                           -- Exclude Cancelled Supplies 2460645
                   AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                   AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
                   -- 2859130
                   -- AND     C.CALENDAR_CODE = p_cal_code
                   -- AND     C.EXCEPTION_SET_ID = p_cal_exc_set_id
                   -- AND     C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
                   -- AND     C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                   --         AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE,
                   --             NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
                   -- AND     DECODE(S.LAST_UNIT_COMPLETION_DATE,
                   --                    NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                   -- AND     C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                   --                                            28, TRUNC(SYSDATE),
                   --                                            C.NEXT_DATE)
                   --AND     C.NEXT_DATE < NVL(p_itf,
                   --                          C.NEXT_DATE + 1)
                   AND     trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) >=
                                          trunc(DECODE(S.ORDER_TYPE, 27, SYSDATE,
                                                               28, SYSDATE,
                                                               NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE))) --4135752
                   AND     trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) < trunc(NVL(p_itf,
                                            NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE) + 1))
		--4365873
                AND    S.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
                AND    S.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
                AND    S.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
                AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
                AND    trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) >= MIHM.effective_date (+)
                AND    trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) <= MIHM.disable_date (+)
                AND    MIHM.demand_class (+) = p_demand_class
                   )
             GROUP BY SD_DATE
             ORDER BY SD_DATE; --4698199
END item_alloc_avail_opt;

-- unconstrained plan
--avjain All netting sqls have been changed to incorporate Plan by Request Date Enhancements
PROCEDURE item_alloc_avail_unopt (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sys_next_date	IN DATE,			--bug3099066
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail_unopt: UNconstrained plan: ' || p_plan_id);
        END IF;

             SELECT        SD_DATE,
                           SUM(SD_QTY)
             BULK COLLECT INTO
                           x_atp_dates,
                           x_atp_qtys
             FROM (
                   SELECT  ---C.CALENDAR_DATE SD_DATE,
                   GREATEST(C.CALENDAR_DATE,p_sys_next_date) SD_DATE,--3099066
                           -1* DECODE(D.ORIGINATION_TYPE,
                                  4, D.DAILY_DEMAND_RATE,
                                  --D.USING_REQUIREMENT_QUANTITY)*
                                  (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)))*  --5027568
                           DECODE(DECODE(G_HIERARCHY_PROFILE,
                           /*------------------------------------------------------------------------+
                           | rajjain begin 07/19/2002                                                |
                           |                                                                         |
                           | Case 1: For internal sales orders [origination type is in (6,30) and    |
                           |            source_organization_id is not null and <> organization_id]   |
                           |                  Return NULL                                            |
                           | Case 2: For others if DEMAND_CLASS is null then return null             |
                           |          else if p_demand_class is '-1' then call                       |
                           |            Get_Hierarchy_Demand_class else return DEMAND_CLASS          |
                           +------------------------------------------------------------------------*/
                              1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                 6, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 30, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS))),
                              -- rajjain end
                              2, DECODE(D.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                   0, TO_CHAR(NULL),
                                 -- rajjain begin 07/19/2002
                                 decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                    6, decode(d.source_organization_id,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    30, decode(d.source_organization_id,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                       p_item_id, p_org_id, p_instance_id,
                                       c.calendar_date,p_level_id, NULL)))),
                                 -- rajjain end 07/19/2002
                           p_demand_class, 1,
                             Decode(D.Demand_Class, NULL, --4365873
                              MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                 D.DEMAND_ID,
                                 c.calendar_date,
                                 D.USING_ASSEMBLY_ITEM_ID,
                                 DECODE(D.SOURCE_ORGANIZATION_ID,
                                    -23453, null,
                                    D.SOURCE_ORGANIZATION_ID), -- 1665483
                                 p_item_id,
                                 p_org_id, -- 1665483
                                 p_instance_id,
                                 decode (d.origination_type, -100, 30,d.origination_type), --5027568
                                 DECODE(G_HIERARCHY_PROFILE,
                                 /*-----------------------------------------------------------------+
                                 | rajjain begin 07/19/2002                                         |
                                 |                                                                  |
                                 | Case 1: For internal sales orders [origination type is in (6,30) |
                                 |         and source_organization_id is not null                   |
                                 |         and <> organization_id] -> Return p_demand_class         |
                                 | Case 2: For others if DEMAND_CLASS is null then return null      |
                                 |           else if p_demand_class is '-1' then call               |
                                 |           Get_Hierarchy_Demand_class else return DEMAND_CLASS    |
                                 +-----------------------------------------------------------------*/
                                    1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                       6, decode(d.source_organization_id,
                                          NULL, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          -23453, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          p_demand_class),
                                    30, decode(d.source_organization_id,
                                       NULL, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       -23453, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       p_demand_class),
                                    DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS))),
                                    -- rajjain end
                                    2, DECODE(D.CUSTOMER_ID, NULL, p_demand_class,
                                                   0, p_demand_class,
                                       -- rajjain begin 07/19/2002
                                       decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                          6, decode(d.source_organization_id,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          30, decode(d.source_organization_id,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                             p_item_id, p_org_id, p_instance_id,
                                             c.calendar_date,p_level_id, NULL)))),
                                       -- rajjain end 07/19/2002
                                       p_demand_class,
                                       p_level_id),0)) SD_QTY --4365873
                   FROM    MSC_CALENDAR_DATES C,
                           MSC_DEMANDS D
                   WHERE        D.PLAN_ID = p_plan_id
                   AND                D.SR_INSTANCE_ID = p_instance_id
                   AND                D.INVENTORY_ITEM_ID = p_item_id
                   AND         D.ORGANIZATION_ID = p_org_id
                   AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
                   AND         D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- For summary enhancement
                   -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
                   -- Bug 1530311, need to exclude forecast, ngoel 12/05/2000
                   AND                C.CALENDAR_CODE = p_cal_code
                   AND                C.EXCEPTION_SET_ID = p_cal_exc_set_id
                   AND         C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                   -- since we store repetitive schedule demand in different ways for
                   -- ods (total quantity on start date) and pds  (daily quantity from
                   -- start date to end date), we need to make sure we only select work day
                   -- for pds's repetitive schedule demand.
                   AND         C.CALENDAR_DATE
                   -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                   -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                               BETWEEN TRUNC(DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
                               AND     TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                             DECODE(RECORD_SOURCE,
                                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))
                   AND         (( D.ORIGINATION_TYPE = 4
                           AND C.SEQ_NUM IS NOT NULL) OR
                           ( D.ORIGINATION_TYPE  <> 4))
                   -- AND         C.PRIOR_DATE < NVL(p_itf,
                   --                  C.PRIOR_DATE + 1)
                   AND         C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE+1)
                   UNION ALL
                   SELECT  ---C.CALENDAR_DATE SD_DATE,
                           GREATEST(CS.CALENDAR_DATE,p_sys_next_date) SD_DATE,--3099066
                           NVL(CS.FIRM_QUANTITY,CS.NEW_ORDER_QUANTITY)*
                              DECODE(DECODE(G_HIERARCHY_PROFILE,
                                     --2424357: Convert the demand calls in case of others for
                                     --- demand class allocated ATP
                                     1, DECODE(CS.DEMAND_CLASS, null, null,
                                        DECODE(p_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         null,
                                                         null,
                                                         cs.inventory_item_id,
                                                         p_org_id,
                                                         p_instance_id,
                                                         cs.calendar_date,
                                                         p_level_id,
                                                         CS.DEMAND_CLASS),CS.DEMAND_CLASS)),
                                     2, DECODE(CS.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                       0, TO_CHAR(NULL),
                                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         CS.CUSTOMER_ID,
                                                         CS.SHIP_TO_SITE_ID,
                                                         cs.inventory_item_id,
                                                         p_org_id,
                                                         p_instance_id,
                                                         cs.calendar_date,
                                                         p_level_id,
                                                         NULL))),
                                 p_demand_class, 1,
                                 NULL, nvl(MIHM.allocation_percent/100,1), --4365873
                                 /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           cs.inventory_item_id,
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           cs.calendar_date), 1),*/
                                 DECODE(
                                 MIHM.allocation_percent/100, --4365873
                                 /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           cs.inventory_item_id,
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           cs.calendar_date),*/
                                   NULL, 1,
                                 0)) SD_QTY
                FROM
                (
                select
                	C.NEXT_DATE,
                	C.CALENDAR_DATE,
			S.FIRM_QUANTITY,
			S.NEW_ORDER_QUANTITY,
			S.DEMAND_CLASS,
			s.inventory_item_id,
			S.CUSTOMER_ID,
			S.SHIP_TO_SITE_ID,
			S.SR_INSTANCE_ID,
			S.ORGANIZATION_ID
                   FROM    MSC_CALENDAR_DATES C,
                           MSC_SUPPLIES S
                   WHERE   S.PLAN_ID = p_plan_id
                   AND     S.SR_INSTANCE_ID = p_instance_id
                   AND     S.INVENTORY_ITEM_ID = p_item_id
                   AND     S.ORGANIZATION_ID = p_org_id
                           -- Exclude Cancelled Supplies 2460645
                   AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                   AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
                   AND     C.CALENDAR_CODE = p_cal_code
                   AND     C.EXCEPTION_SET_ID = p_cal_exc_set_id
                   AND     C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
                   AND     C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                           AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE,
                               NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
                   AND     DECODE(S.LAST_UNIT_COMPLETION_DATE,
                                      NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                   -- 2859130
                   AND     C.CALENDAR_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                                                                   28, TRUNC(SYSDATE),
                                                                   C.CALENDAR_DATE)
                   AND     C.CALENDAR_DATE < NVL(p_itf,
                                            C.CALENDAR_DATE + 1)
                   --AND     C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                   --                                            28, TRUNC(SYSDATE),
                   --                                            C.NEXT_DATE)
                   --AND     C.NEXT_DATE < NVL(p_itf,
                   --                          C.NEXT_DATE + 1)
                   )CS,
		MSC_ITEM_HIERARCHY_MV MIHM
		WHERE
		--4365873
                       CS.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
                AND    CS.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
                AND    CS.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
                AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
                AND    CS.NEXT_DATE >= MIHM.effective_date (+)
                AND    CS.NEXT_DATE <= MIHM.disable_date (+)
                AND    MIHM.demand_class (+) = p_demand_class
                   )
                GROUP BY SD_DATE
                ORDER BY SD_DATE;--4698199
END item_alloc_avail_unopt;
--avjain All netting sqls have been changed to incorporate Plan by Request Date Enhancements
PROCEDURE item_alloc_avail_opt_unalloc (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sys_next_date	IN DATE,                        --bug3099066
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr,
   x_atp_unalloc_qtys   OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail_opt_unalloc: Get unallocated qtys as well. constrained plan: ' || p_plan_id);
        END IF;
              -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
              -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
              SELECT        SD_DATE,
                           SUM(UNALLOC_SD_QTY),
                           SUM(SD_QTY)
             BULK COLLECT INTO
                           x_atp_dates,
                           x_atp_unalloc_qtys,
                           x_atp_qtys
             FROM (
                   SELECT  -- C.PRIOR_DATE SD_DATE, -- 2859130
			GREATEST(
                           TRUNC(DECODE(RECORD_SOURCE,
                           	2,
                           	NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                           	DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                           	2,
                           	(NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                           	NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
                           	,p_sys_next_date) SD_DATE, --3099066 --plan by request date

                           -1* (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)) UNALLOC_SD_QTY, --5027568
                           -1* (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))* --5027568
                           DECODE(DECODE(G_HIERARCHY_PROFILE,
                           /*------------------------------------------------------------------------+
                           | rajjain begin 07/19/2002                                                |
                           |                                                                         |
                           | Case 1: For internal sales orders [origination type is in (6,30) and    |
                           |            source_organization_id is not null and <> organization_id]   |
                           |                  Return NULL                                            |
                           | Case 2: For others if DEMAND_CLASS is null then return null             |
                           |          else if p_demand_class is '-1' then call                       |
                           |            Get_Hierarchy_Demand_class else return DEMAND_CLASS          |
                           +------------------------------------------------------------------------*/
                              1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                 6, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 30, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS))),
                              -- rajjain end
                              2, DECODE(D.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                   0, TO_CHAR(NULL),
                                 -- rajjain begin 07/19/2002
                                 decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                    6, decode(d.source_organization_id,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             p_level_id, NULL),
                                       d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    30, decode(d.source_organization_id,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             p_level_id, NULL),
                                       d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                       p_item_id, p_org_id, p_instance_id,
                                       TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),p_level_id, NULL)))),
                                 -- rajjain end 07/19/2002
                           p_demand_class, 1,
                              Decode(D.Demand_Class, NULL, --4365873
                              MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                 D.DEMAND_ID,
                                 TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                 D.USING_ASSEMBLY_ITEM_ID,
                                 DECODE(D.SOURCE_ORGANIZATION_ID,
                                    -23453, null,
                                    D.SOURCE_ORGANIZATION_ID), -- 1665483
                                 p_item_id,
                                 p_org_id, -- 1665483
                                 p_instance_id,
                                 decode (d.origination_type, -100, 30,d.origination_type), --5027568
                                 DECODE(G_HIERARCHY_PROFILE,
                                 /*-----------------------------------------------------------------+
                                 | rajjain begin 07/19/2002                                         |
                                 |                                                                  |
                                 | Case 1: For internal sales orders [origination type is in (6,30) |
                                 |         and source_organization_id is not null                   |
                                 |         and <> organization_id] -> Return p_demand_class         |
                                 | Case 2: For others if DEMAND_CLASS is null then return null      |
                                 |           else if p_demand_class is '-1' then call               |
                                 |           Get_Hierarchy_Demand_class else return DEMAND_CLASS    |
                                 +-----------------------------------------------------------------*/
                                    1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                       6, decode(d.source_organization_id,
                                          NULL, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          -23453, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          p_demand_class),
                                    30, decode(d.source_organization_id,
                                       NULL, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       -23453, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       p_demand_class),
                                    DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS))),
                                    -- rajjain end
                                    2, DECODE(D.CUSTOMER_ID, NULL, p_demand_class,
                                                   0, p_demand_class,
                                       -- rajjain begin 07/19/2002
                                       decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                          6, decode(d.source_organization_id,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          30, decode(d.source_organization_id,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                             p_item_id, p_org_id, p_instance_id,
                                             TRUNC(DECODE(RECORD_SOURCE,
                                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),p_level_id, NULL)))),
                                       -- rajjain end 07/19/2002
                                       p_demand_class,
                                       p_level_id),0)) SD_QTY --4365873
                   FROM    MSC_DEMANDS D
                   WHERE        D.PLAN_ID = p_plan_id
                   AND                D.SR_INSTANCE_ID = p_instance_id
                   AND                D.INVENTORY_ITEM_ID = p_item_id
                   AND         D.ORGANIZATION_ID = p_org_id
                   AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
                   AND         D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- For summary enhancement
                   -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
                   -- Bug 1530311, need to exclude forecast, ngoel 12/05/2000
                   --AND                C.CALENDAR_CODE = p_cal_code
                   --AND                C.EXCEPTION_SET_ID = p_cal_exc_set_id
                   --AND         C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                   -- since we store repetitive schedule demand in different ways for
                   -- ods (total quantity on start date) and pds  (daily quantity from
                   -- start date to end date), we need to make sure we only select work day
                   -- for pds's repetitive schedule demand.
                   -- 2859130 repetitive schedule not supported for constrained plan
                   --AND         C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE) AND
                   --            TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                   --                      D.USING_ASSEMBLY_DEMAND_DATE))
                   --AND         (( D.ORIGINATION_TYPE = 4
                   --        AND C.SEQ_NUM IS NOT NULL) OR
                   --        ( D.ORIGINATION_TYPE  <> 4))
                   -- AND         C.PRIOR_DATE < NVL(p_itf,
                   --                 C.PRIOR_DATE + 1)
                   --bug3693892 added trunc
                   AND         TRUNC(DECODE(RECORD_SOURCE,
                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) <
                               TRUNC(NVL(p_itf,DECODE(RECORD_SOURCE,
                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) + 1))
                   UNION ALL
                   SELECT  -- C.NEXT_DATE SD_DATE, -- 2859130
                           -- TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) SD_DATE,
                           greatest(TRUNC(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)),p_sys_next_date) SD_DATE,--3099066
                           NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) UNALLOC_SD_QTY,
                           NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)*
                              DECODE(DECODE(G_HIERARCHY_PROFILE,
                                     --2424357: Convert the demand calls in case of others for
                                     --- demand class allocated ATP
                                     1, DECODE(S.DEMAND_CLASS, null, null,
                                        DECODE(p_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         null,
                                                         null,
                                                         S.inventory_item_id,
                                                         p_org_id,
                                                         p_instance_id,
                                                         trunc(nvl(S.firm_date, S.new_schedule_date)),
                                                         p_level_id,
                                                         S.DEMAND_CLASS),S.DEMAND_CLASS)),
                                     2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                       0, TO_CHAR(NULL),
                                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         S.CUSTOMER_ID,
                                                         S.SHIP_TO_SITE_ID,
                                                         S.inventory_item_id,
                                                         p_org_id,
                                                         p_instance_id,
                                                         trunc(nvl(S.firm_date, S.new_schedule_date)),
                                                         p_level_id,
                                                         NULL))),
                                 p_demand_class, 1,
                                 NULL, nvl(MIHM.allocation_percent/100,1), --4365873
                                 /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           s.inventory_item_id,
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           trunc(nvl(s.firm_date, s.new_schedule_date))), 1),*/
                                 DECODE(MIHM.allocation_percent/100, --4365873
                                 /*MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           s.inventory_item_id,
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           trunc(nvl(s.firm_date, s.new_schedule_date))),*/
                                   NULL, 1,
                                 0)) SD_QTY
                   FROM    -- MSC_CALENDAR_DATES C,
                           MSC_SUPPLIES S,MSC_ITEM_HIERARCHY_MV MIHM
                   WHERE   S.PLAN_ID = p_plan_id
                   AND     S.SR_INSTANCE_ID = p_instance_id
                   AND     S.INVENTORY_ITEM_ID = p_item_id
                   AND     S.ORGANIZATION_ID = p_org_id
                           -- Exclude Cancelled Supplies 2460645
                   AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                   AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
                   --AND     C.CALENDAR_CODE = p_cal_code
                   --AND     C.EXCEPTION_SET_ID = p_cal_exc_set_id
                   --AND     C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
                   --AND     C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                   --        AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE,
                   --            NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
                   --AND     DECODE(S.LAST_UNIT_COMPLETION_DATE,
                   --                   NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                   -- 2859130
                   -- AND     C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                   --                                             28, TRUNC(SYSDATE),
                   --                                             C.NEXT_DATE)
                   -- AND     C.NEXT_DATE < NVL(p_itf,
                   --                           C.NEXT_DATE + 1)
                   --AND     C.CALENDAR_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                   --                                            28, TRUNC(SYSDATE),
                   --                                            C.CALENDAR_DATE)
                   AND     trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) >= trunc(DECODE(S.ORDER_TYPE, 27, SYSDATE,
                                                               28, SYSDATE,
                                                               trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)))) --4135752
                   AND     trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) < NVL(p_itf,
                                             trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) + 1)
		--4365873
                AND    S.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
                AND    S.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
                AND    S.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
                AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
                AND    trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) >= MIHM.effective_date (+)
                AND    trunc(NVL(S.FIRM_DATE, S.NEW_SCHEDULE_DATE)) <= MIHM.disable_date (+)
                AND    MIHM.demand_class (+) = p_demand_class
                   )
             GROUP BY SD_DATE
             ORDER BY SD_DATE;--4698199

END item_alloc_avail_opt_unalloc;
--avjain All netting sqls have been changed to incorporate Plan by Request Date Enhancements
PROCEDURE item_alloc_avail_unopt_unalloc (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sys_next_date	IN DATE,			--bug3099066
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr,
   x_atp_unalloc_qtys   OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail_unopt_unalloc: Get unallocated qtys as well. UNconstrained plan: ' || p_plan_id);
        END IF;

             SELECT        SD_DATE,
                           SUM(UNALLOC_SD_QTY),
                           SUM(SD_QTY)
             BULK COLLECT INTO
                           x_atp_dates,
                           x_atp_unalloc_qtys,
                           x_atp_qtys
             FROM (
                   SELECT  --C.CALENDAR_DATE SD_DATE, -- 2859130 change to calendar date
                   	   GREATEST(C.CALENDAR_DATE,p_sys_next_date) SD_DATE,--3099066
                           -1* DECODE(D.ORIGINATION_TYPE,
                                  4, D.DAILY_DEMAND_RATE,
                                  --D.USING_REQUIREMENT_QUANTITY) UNALLOC_SD_QTY,
                                  (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))) UNALLOC_SD_QTY, --5027568
                           -1* DECODE(D.ORIGINATION_TYPE,
                                  4, D.DAILY_DEMAND_RATE,
                                  --D.USING_REQUIREMENT_QUANTITY)*
                                  (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)))* --5027568
                           DECODE(DECODE(G_HIERARCHY_PROFILE,
                           /*------------------------------------------------------------------------+
                           | rajjain begin 07/19/2002                                                |
                           |                                                                         |
                           | Case 1: For internal sales orders [origination type is in (6,30) and    |
                           |            source_organization_id is not null and <> organization_id]   |
                           |                  Return NULL                                            |
                           | Case 2: For others if DEMAND_CLASS is null then return null             |
                           |          else if p_demand_class is '-1' then call                       |
                           |            Get_Hierarchy_Demand_class else return DEMAND_CLASS          |
                           +------------------------------------------------------------------------*/
                              1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                 6, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 30, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)), TO_CHAR(NULL)),
                                 DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS))),
                              -- rajjain end
                              2, DECODE(D.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                   0, TO_CHAR(NULL),
                                 -- rajjain begin 07/19/2002
                                 decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                    6, decode(d.source_organization_id,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    30, decode(d.source_organization_id,
                                       NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                             p_org_id, p_instance_id, c.calendar_date,
                                             p_level_id, NULL),
                                       TO_CHAR(NULL)),
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                       p_item_id, p_org_id, p_instance_id,
                                       c.calendar_date,p_level_id, NULL)))),
                                 -- rajjain end 07/19/2002
                           p_demand_class, 1,
                             Decode(D.Demand_Class, NULL, --4365873
                              MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                                 D.DEMAND_ID,
                                 c.calendar_date,
                                 D.USING_ASSEMBLY_ITEM_ID,
                                 DECODE(D.SOURCE_ORGANIZATION_ID,
                                    -23453, null,
                                    D.SOURCE_ORGANIZATION_ID), -- 1665483
                                 p_item_id,
                                 p_org_id, -- 1665483
                                 p_instance_id,
                                 DECODE (D.ORIGINATION_TYPE, -100, 30,D.ORIGINATION_TYPE) , --5027568
                                 DECODE(G_HIERARCHY_PROFILE,
                                 /*-----------------------------------------------------------------+
                                 | rajjain begin 07/19/2002                                         |
                                 |                                                                  |
                                 | Case 1: For internal sales orders [origination type is in (6,30) |
                                 |         and source_organization_id is not null                   |
                                 |         and <> organization_id] -> Return p_demand_class         |
                                 | Case 2: For others if DEMAND_CLASS is null then return null      |
                                 |           else if p_demand_class is '-1' then call               |
                                 |           Get_Hierarchy_Demand_class else return DEMAND_CLASS    |
                                 +-----------------------------------------------------------------*/
                                    1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                       6, decode(d.source_organization_id,
                                          NULL, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          -23453, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                             DECODE(p_demand_class, '-1',
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   null, null, p_item_id, p_org_id,
                                                   p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                                D.DEMAND_CLASS)),
                                          p_demand_class),
                                    30, decode(d.source_organization_id,
                                       NULL, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       -23453, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       p_demand_class),
                                    DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS))),
                                    -- rajjain end
                                    2, DECODE(D.CUSTOMER_ID, NULL, p_demand_class,
                                                   0, p_demand_class,
                                       -- rajjain begin 07/19/2002
                                       decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                          6, decode(d.source_organization_id,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          30, decode(d.source_organization_id,
                                             NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                   D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                   p_org_id, p_instance_id, c.calendar_date,
                                                   p_level_id, NULL),
                                             p_demand_class),
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                             p_item_id, p_org_id, p_instance_id,
                                             c.calendar_date,p_level_id, NULL)))),
                                       -- rajjain end 07/19/2002
                                       p_demand_class,
                                       p_level_id),0)) SD_QTY --4365873
                   FROM    MSC_CALENDAR_DATES C,
                           MSC_DEMANDS D
                   WHERE        D.PLAN_ID = p_plan_id
                   AND                D.SR_INSTANCE_ID = p_instance_id
                   AND                D.INVENTORY_ITEM_ID = p_item_id
                   AND         D.ORGANIZATION_ID = p_org_id
                   AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
                   AND         D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- For summary enhancement
                   -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
                   -- Bug 1530311, need to exclude forecast, ngoel 12/05/2000
                   AND                C.CALENDAR_CODE = p_cal_code
                   AND                C.EXCEPTION_SET_ID = p_cal_exc_set_id
                   AND         C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                   -- since we store repetitive schedule demand in different ways for
                   -- ods (total quantity on start date) and pds  (daily quantity from
                   -- start date to end date), we need to make sure we only select work day
                   -- for pds's repetitive schedule demand.
                   -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                   -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                   AND         C.CALENDAR_DATE BETWEEN TRUNC(DECODE(RECORD_SOURCE,
                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) AND
                               TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                         DECODE(RECORD_SOURCE,
                                 2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                    DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                           2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                              NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))
                   AND         (( D.ORIGINATION_TYPE = 4
                           AND C.SEQ_NUM IS NOT NULL) OR
                           ( D.ORIGINATION_TYPE  <> 4))
                   AND         C.CALENDAR_DATE < NVL(p_itf,
                                   C.CALENDAR_DATE + 1)
                   UNION ALL
                   SELECT  --C.CALENDAR_DATE SD_DATE, --2859130
                           greatest(CS.CALENDAR_DATE,p_sys_next_date) SD_DATE,--3099066
                           NVL(CS.FIRM_QUANTITY,CS.NEW_ORDER_QUANTITY) UNALLOC_SD_QTY,
                           NVL(CS.FIRM_QUANTITY,CS.NEW_ORDER_QUANTITY)*
                              DECODE(DECODE(G_HIERARCHY_PROFILE,
                                     --2424357: Convert the demand calls in case of others for
                                     --- demand class allocated ATP
                                     1, DECODE(CS.DEMAND_CLASS, null, null,
                                        DECODE(p_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         null,
                                                         null,
                                                         cs.inventory_item_id,
                                                         p_org_id,
                                                         p_instance_id,
                                                         cs.calendar_date,
                                                         p_level_id,
                                                         CS.DEMAND_CLASS),CS.DEMAND_CLASS)),
                                     2, DECODE(CS.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                       0, TO_CHAR(NULL),
                                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                         CS.CUSTOMER_ID,
                                                         CS.SHIP_TO_SITE_ID,
                                                         cs.inventory_item_id,
                                                         p_org_id,
                                                         p_instance_id,
                                                         cs.calendar_date,
                                                         p_level_id,
                                                         NULL))),
                                 p_demand_class, 1,
                                 NULL, nvl(MIHM.allocation_percent/100,1), --4365873
                                 /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           s.inventory_item_id,
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           c.calendar_date), 1),*/
                                 DECODE(
                                 MIHM.allocation_percent/100, --4365873
                                 /*MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                           p_instance_id,
                                           s.inventory_item_id,
                                           p_org_id,
                                           null,
                                           null,
                                           p_demand_class,
                                           c.calendar_date),*/
                                   NULL, 1,
                                 0)) SD_QTY
                FROM
                (
                select
                	C.NEXT_DATE,
                	C.CALENDAR_DATE,
			S.FIRM_QUANTITY,
			S.NEW_ORDER_QUANTITY,
			S.DEMAND_CLASS,
			s.inventory_item_id,
			S.CUSTOMER_ID,
			S.SHIP_TO_SITE_ID,
			S.SR_INSTANCE_ID,
			S.ORGANIZATION_ID
                   FROM    MSC_CALENDAR_DATES C,
                           MSC_SUPPLIES S
                   WHERE   S.PLAN_ID = p_plan_id
                   AND     S.SR_INSTANCE_ID = p_instance_id
                   AND     S.INVENTORY_ITEM_ID = p_item_id
                   AND     S.ORGANIZATION_ID = p_org_id
                           -- Exclude Cancelled Supplies 2460645
                   AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                   AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
                   AND     C.CALENDAR_CODE = p_cal_code
                   AND     C.EXCEPTION_SET_ID = p_cal_exc_set_id
                   AND     C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
                   AND     C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                           AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE,
                               NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
                   AND     DECODE(S.LAST_UNIT_COMPLETION_DATE,
                                      NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                   AND     C.CALENDAR_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                                                               28, TRUNC(SYSDATE),
                                                               C.CALENDAR_DATE)
                   AND     C.CALENDAR_DATE < NVL(p_itf,
                                             C.CALENDAR_DATE + 1))CS,
		MSC_ITEM_HIERARCHY_MV MIHM
		WHERE
		--4365873
                       CS.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
                AND    CS.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
                AND    CS.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
                AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
                AND    CS.NEXT_DATE >= MIHM.effective_date (+)
                AND    CS.NEXT_DATE <= MIHM.disable_date (+)
                AND    MIHM.demand_class (+) = p_demand_class
                   )
             GROUP BY SD_DATE
             ORDER BY SD_DATE;--4698199
END item_alloc_avail_unopt_unalloc;
--avjain All netting sqls have been changed to incorporate Plan by Request Date Enhancements
PROCEDURE item_alloc_avail_opt_dtls (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sr_item_id         IN NUMBER,
   p_level              IN NUMBER,
   p_identifier         IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_uom_code           IN VARCHAR2,
   p_sys_next_date	IN DATE				--bug3099066
) IS
   l_null_num   NUMBER;
   l_null_char  VARCHAR2(1);
   l_sysdate    DATE := trunc(sysdate); --4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail_opt_dtls: constrained plan: ' || p_plan_id);
        END IF;

        INSERT INTO msc_atp_sd_details_temp (
                ATP_Level,
                Order_line_id,
                Scenario_Id,
                Inventory_Item_Id,
                Request_Item_Id,
                Organization_Id,
                Department_Id,
                Resource_Id,
                Supplier_Id,
                Supplier_Site_Id,
                From_Organization_Id,
                From_Location_Id,
                To_Organization_Id,
                To_Location_Id,
                Ship_Method,
                UOM_code,
                Supply_Demand_Type,
                Supply_Demand_Source_Type,
                Supply_Demand_Source_Type_Name,
                Identifier1,
                Identifier2,
                Identifier3,
                Identifier4,
                Allocated_Quantity, -- fixed as part of time_phased_atp
                Supply_Demand_Quantity,
                Supply_Demand_Date,
                Disposition_Type,
                Disposition_Name,
                Pegging_Id,
                End_Pegging_Id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                Unallocated_Quantity,
                ORIG_CUSTOMER_SITE_NAME,--bug3263368
                ORIG_CUSTOMER_NAME, --bug3263368
                ORIG_DEMAND_CLASS, --bug3263368
                ORIG_REQUEST_DATE --bug3263368
                )
           (
            SELECT      p_level col1,
                        p_identifier col2,
                        p_scenario_id col3,
                        p_sr_item_id col4 ,
                        p_sr_item_id col5,
                        p_org_id col6,
                        l_null_num col7,
                        l_null_num col8,
                        l_null_num col9,
                        l_null_num col10,
                        l_null_num col11,
                        l_null_num col12,
                        l_null_num col13,
                        l_null_num col14,
                        l_null_char col15,
                        p_uom_code col16,
                        1 col17, -- demand
                        --D.ORIGINATION_TYPE col18,
                        DECODE( D.ORIGINATION_TYPE, -100, 30, D.ORIGINATION_TYPE) col18,  --5027568
                        l_null_char col19,
                        D.SR_INSTANCE_ID col20,
                        l_null_num col21,
                        D.DEMAND_ID col22,
                        l_null_num col23,
                        -- -1* D.USING_REQUIREMENT_QUANTITY * -- 2859130 remove decode originition_type 4
                        -1*(D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))* --5027568
			/*New*/
                        DECODE(p_scenario_id, -1, 1,
                        --2424357
                        DECODE(DECODE(G_HIERARCHY_PROFILE,
                        /*------------------------------------------------------------------------+
                        | rajjain begin 07/19/2002                                                |
                        |                                                                         |
                        | Case 1: For internal sales orders [origination type is in (6,30) and    |
                        |            source_organization_id is not null and <> organization_id]   |
                        |                  Return NULL                                            |
                        | Case 2: For others if DEMAND_CLASS is null then return null             |
                        |          else if p_demand_class is '-1' then call                       |
                        |            Get_Hierarchy_Demand_class else return DEMAND_CLASS          |
                        +------------------------------------------------------------------------*/
                           1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                              6, decode(d.source_organization_id,
                                 NULL, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                                            -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                 -23453, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                 d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)), NULL),
                              30, decode(d.source_organization_id,
                                 NULL, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                 -23453, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                 d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)), NULL),
                              DECODE(D.DEMAND_CLASS, null, null,
                                 DECODE(p_demand_class, '-1',
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                       null, null, p_item_id, p_org_id,
                                       p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                       D.DEMAND_CLASS))),
                           -- rajjain end
                           2, DECODE(D.CUSTOMER_ID, NULL, NULL,
                                                0, NULL,
                              -- rajjain begin 07/19/2002
                              decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                 6, decode(d.source_organization_id,
                                    NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                          p_level_id, NULL),
                                    -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                          p_level_id, NULL),
                                    d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                          p_level_id, NULL),
                                    NULL),
                                 30, decode(d.source_organization_id,
                                    NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                          p_level_id, NULL),
                                    -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                          p_level_id, NULL),
                                    d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                          p_level_id, NULL),
                                    NULL),
                                 MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                    p_item_id, p_org_id, p_instance_id,
                                    trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),p_level_id, NULL)))),
                              -- rajjain end 07/19/2002
                        p_demand_class, 1,
                          Decode(D.Demand_Class, NULL, --4365873
                           MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                              D.DEMAND_ID,
                              trunc(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                              D.USING_ASSEMBLY_ITEM_ID,
                              DECODE(D.SOURCE_ORGANIZATION_ID,
                                 -23453, null,
                                 D.SOURCE_ORGANIZATION_ID),
                              p_item_id,
                              p_org_id, -- 1665483
                              p_instance_id,
                              decode (d.origination_type, -100, 30,d.origination_type),
                              DECODE(G_HIERARCHY_PROFILE,
                              /*-----------------------------------------------------------------+
                              | rajjain begin 07/19/2002                                         |
                              |                                                                  |
                              | Case 1: For internal sales orders [origination type is in (6,30) |
                              |         and source_organization_id is not null                   |
                              |         and <> organization_id] -> Return p_demand_class         |
                              | Case 2: For others if DEMAND_CLASS is null then return null      |
                              |           else if p_demand_class is '-1' then call               |
                              |           Get_Hierarchy_Demand_class else return DEMAND_CLASS    |
                              +-----------------------------------------------------------------*/
                                 1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                    6, decode(d.source_organization_id,
                                       NULL, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       -23453, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       p_demand_class),
                                 30, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                    p_demand_class),
                                 DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))), p_level_id, D.DEMAND_CLASS),
                                       D.DEMAND_CLASS))),
                                 -- rajjain end
                                 2, DECODE(D.CUSTOMER_ID, NULL, p_demand_class,
                                                0, p_demand_class,
                                    -- rajjain begin 07/19/2002
                                    decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                       6, decode(d.source_organization_id,
                                          NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                p_level_id, NULL),
                                          -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                p_level_id, NULL),
                                          d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                p_level_id, NULL),
                                          p_demand_class),
                                       30, decode(d.source_organization_id,
                                          NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                p_level_id, NULL),
                                          -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                p_level_id, NULL),
                                          d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                                                p_level_id, NULL),
                                          p_demand_class),
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                          p_item_id, p_org_id, p_instance_id,
                                          TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),p_level_id, NULL)))),
                                    -- rajjain end 07/19/2002
                                    p_demand_class,
                                    p_level_id),0))) col24,
                                /*New*/
                        -- -1* D.USING_REQUIREMENT_QUANTITY, -- fixed as part of time_phased_atp
                        -1* (D.USING_REQUIREMENT_QUANTITY - nvl(d.reserved_quantity,0)),--5027568
                        -- C.PRIOR_DATE col25, -- 2859130
                        GREATEST(TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))),
                        	 p_sys_next_date) col25, --plan by request date --3099066
                        l_null_num col26,
                        DECODE(D.ORIGINATION_TYPE, 1, to_char(D.DISPOSITION_ID), D.ORDER_NUMBER) col27,
                               -- rajjain 04/25/2003 Bug 2771075
                               -- For Planned Order Demands We will populate disposition_id
                               -- in disposition_name column
                        l_null_num col28,
                        l_null_num col29,
        		-- ship_rec_cal changes begin
        		l_sysdate,
        		G_USER_ID,
        		l_sysdate,
        		G_USER_ID,
        		G_USER_ID,
        		-- ship_rec_cal changes end
                        -- Unallocated_Quantity
                        -- -1* D.USING_REQUIREMENT_QUANTITY, -- 2859130 remove decode for origination_type 4
                        -1* (D.USING_REQUIREMENT_QUANTITY - nvl(d.reserved_quantity,0)), --5027568
                        MTPS.LOCATION, --bug3263368
                        MTP.PARTNER_NAME, --bug3263368
                        D.DEMAND_CLASS, --bug3263368
                        DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,
                                                    D.REQUEST_SHIP_DATE) --bug3263368
            FROM        -- MSC_CALENDAR_DATES C, --2859130
                        MSC_DEMANDS D,
                        MSC_TRADING_PARTNERS    MTP,--bug3263368
                        MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
            WHERE       D.PLAN_ID = p_plan_id
            AND         D.SR_INSTANCE_ID = p_instance_id
            AND         D.INVENTORY_ITEM_ID = p_item_id
            AND         D.ORGANIZATION_ID = p_org_id
            AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
            AND         D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- For summary enhancement
            AND         D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
            AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368
            -- 2859130
            -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
            -- Bug 1530311, need to exclude forecast, ngoel 12/05/2000
            -- AND         C.CALENDAR_CODE = p_cal_code
            -- AND         C.EXCEPTION_SET_ID = p_cal_exc_set_id
            -- AND         C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
            -- since we store repetitive schedule demand in different ways for
            -- ods (total quantity on start date) and pds  (daily quantity from
            -- start date to end date), we need to make sure we only select work day
            -- for pds's repetitive schedule demand.
            -- AND         C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE) AND
            --             TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
            --                       D.USING_ASSEMBLY_DEMAND_DATE))
            -- AND         (( D.ORIGINATION_TYPE = 4
            --               AND C.SEQ_NUM IS NOT NULL) OR
            --               ( D.ORIGINATION_TYPE  <> 4))
            -- 2859130
            -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
            -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
            --bug3693892 added trunc
            AND         TRUNC(DECODE(RECORD_SOURCE,
                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
                       < TRUNC(NVL(p_itf,DECODE(RECORD_SOURCE,
                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) + 1))
            -- AND C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE+1)
            UNION ALL
            SELECT      p_level col1,
                        p_identifier col2,
                        p_scenario_id col3,
                        p_sr_item_id col4 ,
                        p_sr_item_id col5,
                        p_org_id col6,
                        l_null_num col7,
                        l_null_num col8,
                        l_null_num col9,
                        l_null_num col10,
                        l_null_num col11,
                        l_null_num col12,
                        l_null_num col13,
                        l_null_num col14,
                        l_null_char col15,
                        p_uom_code col16,
                        2 col17, -- supply
                        S.ORDER_TYPE col18,
                        l_null_char col19,
                        S.SR_INSTANCE_ID col20,
                                l_null_num col21,
                        S.TRANSACTION_ID col22,
                        l_null_num col23,
                        NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)*
                                DECODE(p_scenario_id, -1, 1,
                                DECODE(DECODE(G_HIERARCHY_PROFILE,
                                              --2424357
                                              1, DECODE(S.DEMAND_CLASS, null, null,
                                                     DECODE(p_demand_class,'-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                          null,
                                                          null,
                                                          S.inventory_item_id,
                                                          p_org_id,
                                                          p_instance_id,
                                                          TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)),
                                                          p_level_id,
                                                          S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                        --0, TO_CHAR(NULL),
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                          S.CUSTOMER_ID,
                                                          S.SHIP_TO_SITE_ID,
                                                          S.inventory_item_id,
                                                          p_org_id,
                                                          p_instance_id,
                                                          TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)),
                                                          p_level_id,
                                                          NULL))),
                                        p_demand_class, 1,
                                        NULL, NVL(MIHM.allocation_percent/100,--4365873
                                        /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                p_instance_id,
                                                s.inventory_item_id,
                                                p_org_id,
                                                null,
                                                null,
                                                p_demand_class,
                                                TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))),*/
                                                 1),
                                        DECODE(MIHM.allocation_percent/100, --4365873
                                        /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                p_instance_id,
                                                s.inventory_item_id,
                                                p_org_id,
                                                null,
                                                null,
                                                p_demand_class,
                                                TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))),*/
                                        NULL, 1,
                                        0))) col24,
                        NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY),
                        --C.NEXT_DATE col25, -- 2859130
                        --TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) col25,
                        GREATEST(TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)),p_sys_next_date) col25,--3099066
                        l_null_num col26,
                        DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER) col27,
                               -- Bug 2771075. For Planned Orders, we will populate transaction_id
			       -- in the disposition_name column to be consistent with Planning.
                        l_null_num col28,
                        l_null_num col29,
        		-- ship_rec_cal changes begin
        		l_sysdate,
        		G_USER_ID,
        		l_sysdate,
        		G_USER_ID,
        		G_USER_ID,
        		-- ship_rec_cal changes end
                        NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY), -- unallocated quantity
                        null, --bug3263368 ORIG_CUSTOMER_SITE_NAME
                        null, --bug3263368 ORIG_CUSTOMER_NAME
                        null, --bug3263368 ORIG_DEMAND_CLASS
                        null  --bug3263368 ORIG_REQUEST_DATE
            FROM        -- MSC_CALENDAR_DATES C, -- 2859130
                        MSC_SUPPLIES S,MSC_ITEM_HIERARCHY_MV  MIHM
            WHERE       S.PLAN_ID = p_plan_id
            AND         S.SR_INSTANCE_ID = p_instance_id
            AND         S.INVENTORY_ITEM_ID = p_item_id
            AND         S.ORGANIZATION_ID = p_org_id
                        -- Exclude Cancelled Supplies 2460645
            AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
            AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
            --2859130
            --AND         C.CALENDAR_CODE = p_cal_code
            --AND         C.EXCEPTION_SET_ID = p_cal_exc_set_id
            --AND         C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
            --AND         C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
            --                    AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE,
            --                        NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
            --AND         DECODE(S.LAST_UNIT_COMPLETION_DATE,
            --                   NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
            --AND         C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
            --                                                28, TRUNC(SYSDATE),
            --                                                C.NEXT_DATE)
            --AND         C.NEXT_DATE < NVL(p_itf,
            --                             C.NEXT_DATE + 1)
            AND         TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                                                            28, TRUNC(SYSDATE),
                                                            TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
            AND         TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) < NVL(p_itf,
                                         TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) + 1)
	    --4365873
            AND    S.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
            AND    S.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
            AND    S.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
            AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
            AND    TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) >= MIHM.effective_date (+)
            AND    TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) <= MIHM.disable_date (+)
            AND    MIHM.demand_class (+) = p_demand_class
           ); -- dsting removed order by col25

END item_alloc_avail_opt_dtls;
--avjain All netting sqls have been changed to incorporate Plan by Request Date Enhancements
PROCEDURE item_alloc_avail_unopt_dtls (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sr_item_id         IN NUMBER,
   p_level              IN NUMBER,
   p_identifier         IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_uom_code           IN VARCHAR2,
   p_sys_next_date	IN DATE
) IS
   l_null_num   NUMBER;
   l_null_char  VARCHAR2(1);
   l_sysdate    DATE := trunc(sysdate);--4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail_unopt_dtls: UNconstrained plan: ' || p_plan_id);
        END IF;

        INSERT INTO msc_atp_sd_details_temp (
                ATP_Level,
                Order_line_id,
                Scenario_Id,
                Inventory_Item_Id,
                Request_Item_Id,
                Organization_Id,
                Department_Id,
                Resource_Id,
                Supplier_Id,
                Supplier_Site_Id,
                From_Organization_Id,
                From_Location_Id,
                To_Organization_Id,
                To_Location_Id,
                Ship_Method,
                UOM_code,
                Supply_Demand_Type,
                Supply_Demand_Source_Type,
                Supply_Demand_Source_Type_Name,
                Identifier1,
                Identifier2,
                Identifier3,
                Identifier4,
                Allocated_Quantity,
                Supply_Demand_Quantity,
                Supply_Demand_Date,
                Disposition_Type,
                Disposition_Name,
                Pegging_Id,
                End_Pegging_Id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                Unallocated_Quantity,
                ORIG_CUSTOMER_SITE_NAME,--bug3263368
                ORIG_CUSTOMER_NAME, --bug3263368
                ORIG_DEMAND_CLASS, --bug3263368
                ORIG_REQUEST_DATE --bug3263368
                )
           (
            SELECT      p_level col1,
                        p_identifier col2,
                        p_scenario_id col3,
                        p_sr_item_id col4 ,
                        p_sr_item_id col5,
                        p_org_id col6,
                        l_null_num col7,
                        l_null_num col8,
                        l_null_num col9,
                        l_null_num col10,
                        l_null_num col11,
                        l_null_num col12,
                        l_null_num col13,
                        l_null_num col14,
                        l_null_char col15,
                        p_uom_code col16,
                        1 col17, -- demand
                        --D.ORIGINATION_TYPE col18,
                        DECODE( D.ORIGINATION_TYPE, -100, 30, D.ORIGINATION_TYPE) col18,  --5027568
                        l_null_char col19,
                        D.SR_INSTANCE_ID col20,
                        l_null_num col21,
                        D.DEMAND_ID col22,
                        l_null_num col23,
                        -1* DECODE(D.ORIGINATION_TYPE,
                               4, D.DAILY_DEMAND_RATE,
                               --D.USING_REQUIREMENT_QUANTITY)*
                               (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)))* --5027568
			/*New*/
                        DECODE(p_scenario_id, -1, 1,
                        --2424357
                        DECODE(DECODE(G_HIERARCHY_PROFILE,
                        /*------------------------------------------------------------------------+
                        | rajjain begin 07/19/2002                                                |
                        |                                                                         |
                        | Case 1: For internal sales orders [origination type is in (6,30) and    |
                        |            source_organization_id is not null and <> organization_id]   |
                        |                  Return NULL                                            |
                        | Case 2: For others if DEMAND_CLASS is null then return null             |
                        |          else if p_demand_class is '-1' then call                       |
                        |            Get_Hierarchy_Demand_class else return DEMAND_CLASS          |
                        +------------------------------------------------------------------------*/
                           1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                              6, decode(d.source_organization_id,
                                 NULL, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                 -23453, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                 d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)), NULL),
                              30, decode(d.source_organization_id,
                                 NULL, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                 -23453, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                 d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)), NULL),
                              DECODE(D.DEMAND_CLASS, null, null,
                                 DECODE(p_demand_class, '-1',
                                    MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                       null, null, p_item_id, p_org_id,
                                       p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                       D.DEMAND_CLASS))),
                           -- rajjain end
                           2, DECODE(D.CUSTOMER_ID, NULL, NULL,
                                                0, NULL,
                              -- rajjain begin 07/19/2002
                              decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                 6, decode(d.source_organization_id,
                                    NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, c.calendar_date,
                                          p_level_id, NULL),
                                    -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, c.calendar_date,
                                          p_level_id, NULL),
                                    d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, c.calendar_date,
                                          p_level_id, NULL),
                                    NULL),
                                 30, decode(d.source_organization_id,
                                    NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, c.calendar_date,
                                          p_level_id, NULL),
                                    -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, c.calendar_date,
                                          p_level_id, NULL),
                                    d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                          p_org_id, p_instance_id, c.calendar_date,
                                          p_level_id, NULL),
                                    NULL),
                                 MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                    p_item_id, p_org_id, p_instance_id,
                                    c.calendar_date,p_level_id, NULL)))),
                              -- rajjain end 07/19/2002
                        p_demand_class, 1,
                        Decode(D.Demand_Class, NULL, --4365873
                           MSC_AATP_FUNC.Get_Item_Demand_Alloc_Percent(p_plan_id,
                              D.DEMAND_ID,
                              c.calendar_date,
                              D.USING_ASSEMBLY_ITEM_ID,
                              DECODE(D.SOURCE_ORGANIZATION_ID,
                                 -23453, null,
                                 D.SOURCE_ORGANIZATION_ID),
                              p_item_id,
                              p_org_id, -- 1665483
                              p_instance_id,
                              decode (d.origination_type, -100, 30,d.origination_type),
                              DECODE(G_HIERARCHY_PROFILE,
                              /*-----------------------------------------------------------------+
                              | rajjain begin 07/19/2002                                         |
                              |                                                                  |
                              | Case 1: For internal sales orders [origination type is in (6,30) |
                              |         and source_organization_id is not null                   |
                              |         and <> organization_id] -> Return p_demand_class         |
                              | Case 2: For others if DEMAND_CLASS is null then return null      |
                              |           else if p_demand_class is '-1' then call               |
                              |           Get_Hierarchy_Demand_class else return DEMAND_CLASS    |
                              +-----------------------------------------------------------------*/
                                 1, decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                    6, decode(d.source_organization_id,
                                       NULL, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       -23453, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                          DECODE(p_demand_class, '-1',
                                             MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                null, null, p_item_id, p_org_id,
                                                p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                             D.DEMAND_CLASS)),
                                       p_demand_class),
                                 30, decode(d.source_organization_id,
                                    NULL, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                    -23453, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                    d.organization_id, DECODE(D.DEMAND_CLASS, null, null,
                                       DECODE(p_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                             null, null, p_item_id, p_org_id,
                                             p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                          D.DEMAND_CLASS)),
                                    p_demand_class),
                                 DECODE(D.DEMAND_CLASS, null, null,
                                    DECODE(p_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                          null, null, p_item_id, p_org_id,
                                          p_instance_id, c.calendar_date, p_level_id, D.DEMAND_CLASS),
                                       D.DEMAND_CLASS))),
                                 -- rajjain end
                                 2, DECODE(D.CUSTOMER_ID, NULL, p_demand_class,
                                                0, p_demand_class,
                                    -- rajjain begin 07/19/2002
                                    decode(decode (d.origination_type, -100, 30,d.origination_type),  --5027568
                                       6, decode(d.source_organization_id,
                                          NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, c.calendar_date,
                                                p_level_id, NULL),
                                          -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, c.calendar_date,
                                                p_level_id, NULL),
                                          d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, c.calendar_date,
                                                p_level_id, NULL),
                                          p_demand_class),
                                       30, decode(d.source_organization_id,
                                          NULL, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, c.calendar_date,
                                                p_level_id, NULL),
                                          -23453, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, c.calendar_date,
                                                p_level_id, NULL),
                                          d.organization_id, MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                D.CUSTOMER_ID, D.SHIP_TO_SITE_ID, p_item_id,
                                                p_org_id, p_instance_id, c.calendar_date,
                                                p_level_id, NULL),
                                          p_demand_class),
                                       MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(D.CUSTOMER_ID, D.SHIP_TO_SITE_ID,
                                          p_item_id, p_org_id, p_instance_id,
                                          c.calendar_date,p_level_id, NULL)))),
                                    -- rajjain end 07/19/2002
                                    p_demand_class,
                                    p_level_id),0))) col24,
                                /*New*/
                        -1* DECODE(D.ORIGINATION_TYPE,
                               4, D.DAILY_DEMAND_RATE,
                               --D.USING_REQUIREMENT_QUANTITY),
                               (D.USING_REQUIREMENT_QUANTITY- nvl(d.reserved_quantity,0))),  --5027568

                        -- C.PRIOR_DATE col25, -- 2859130
                        --C.CALENDAR_DATE col25,
                        GREATEST(C.CALENDAR_DATE,p_sys_next_date) col25,
                        l_null_num col26,
                        DECODE(D.ORIGINATION_TYPE, 1, to_char(D.DISPOSITION_ID), D.ORDER_NUMBER) col27,
                               -- rajjain 04/25/2003 Bug 2771075
                               -- For Planned Order Demands We will populate disposition_id
                               -- in disposition_name column
                        l_null_num col28,
                        l_null_num col29,
                        -- ship_rec_cal changes begin
                        l_sysdate,
                        G_USER_ID,
                        l_sysdate,
                        G_USER_ID,
                        G_USER_ID,
                        -- ship_rec_cal changes end
                        -- Unallocated_Quantity
                        -1* DECODE(D.ORIGINATION_TYPE,
                                4, D.DAILY_DEMAND_RATE,
                        --D.USING_REQUIREMENT_QUANTITY),
                        (D.USING_REQUIREMENT_QUANTITY- nvl(d.reserved_quantity,0))),  --5027568
                        MTPS.LOCATION, --bug3263368
                        MTP.PARTNER_NAME, --bug3263368
                        D.DEMAND_CLASS, --bug3263368
                        DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,
                                                D.REQUEST_SHIP_DATE) --bug3263368

            FROM        MSC_CALENDAR_DATES C,
                        MSC_DEMANDS D,
                        MSC_TRADING_PARTNERS    MTP,--bug3263368
                        MSC_TRADING_PARTNER_SITES    MTPS --bug3263368

            WHERE       D.PLAN_ID = p_plan_id
            AND         D.SR_INSTANCE_ID = p_instance_id
            AND         D.INVENTORY_ITEM_ID = p_item_id
            AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
            AND         D.ORGANIZATION_ID = p_org_id
            AND         D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- For summary enhancement
            AND         D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
            AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+)--bug3263368

            -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
            -- Bug 1530311, need to exclude forecast, ngoel 12/05/2000
            AND         C.CALENDAR_CODE = p_cal_code
            AND         C.EXCEPTION_SET_ID = p_cal_exc_set_id
            AND         C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
            -- since we store repetitive schedule demand in different ways for
            -- ods (total quantity on start date) and pds  (daily quantity from
            -- start date to end date), we need to make sure we only select work day
            -- for pds's repetitive schedule demand.
            -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
            -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
            AND         C.CALENDAR_DATE BETWEEN TRUNC(DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) AND
                        TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                                  DECODE(RECORD_SOURCE,
                                         2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                            DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                                   2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                      NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))
            AND         (( D.ORIGINATION_TYPE = 4
                          AND C.SEQ_NUM IS NOT NULL) OR
                          ( D.ORIGINATION_TYPE  <> 4))
            -- 2859130
            -- AND         C.PRIOR_DATE < NVL(p_itf,
            --                              C.PRIOR_DATE + 1)
            AND C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE+1)
            UNION ALL
            SELECT      p_level col1,
                        p_identifier col2,
                        p_scenario_id col3,
                        p_sr_item_id col4 ,
                        p_sr_item_id col5,
                        p_org_id col6,
                        l_null_num col7,
                        l_null_num col8,
                        l_null_num col9,
                        l_null_num col10,
                        l_null_num col11,
                        l_null_num col12,
                        l_null_num col13,
                        l_null_num col14,
                        l_null_char col15,
                        p_uom_code col16,
                        2 col17, -- supply
                        CS.ORDER_TYPE col18,
                        l_null_char col19,
                        CS.SR_INSTANCE_ID col20,
                                l_null_num col21,
                        CS.TRANSACTION_ID col22,
                        l_null_num col23,
                        NVL(CS.FIRM_QUANTITY,CS.NEW_ORDER_QUANTITY)*
                                DECODE(p_scenario_id, -1, 1,
                                DECODE(DECODE(G_HIERARCHY_PROFILE,
                                              --2424357
                                              1, DECODE(CS.DEMAND_CLASS, null, null,
                                                     DECODE(p_demand_class,'-1',
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                          null,
                                                          null,
                                                          cs.inventory_item_id,
                                                          p_org_id,
                                                          p_instance_id,
                                                          cs.calendar_date,
                                                          p_level_id,
                                                          CS.DEMAND_CLASS), CS.DEMAND_CLASS)),
                                              2, DECODE(CS.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                                        --0, TO_CHAR(NULL),
                                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                          CS.CUSTOMER_ID,
                                                          CS.SHIP_TO_SITE_ID,
                                                          cs.inventory_item_id,
                                                          p_org_id,
                                                          p_instance_id,
                                                          cs.calendar_date,
                                                          p_level_id,
                                                          NULL))),
                                        p_demand_class, 1,
                                        NULL, nvl(MIHM.allocation_percent/100,1), --4365873
                                        /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                p_instance_id,
                                                cs.inventory_item_id,
                                                p_org_id,
                                                null,
                                                null,
                                                p_demand_class,
                                                cs.calendar_date), 1),*/
                                        DECODE(
                                        MIHM.allocation_percent/100, --4365873
                                        /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                p_instance_id,
                                                cs.inventory_item_id,
                                                p_org_id,
                                                null,
                                                null,
                                                p_demand_class,
                                                cs.calendar_date),*/
                                        NULL, 1,
                                        0))) col24,
                        NVL(CS.FIRM_QUANTITY,CS.NEW_ORDER_QUANTITY),
                        --C.NEXT_DATE col25, -- 2859130
                        --C.CALENDAR_DATE col25,
                        GREATEST(CS.CALENDAR_DATE,p_sys_next_date) col25,--3099066
                        l_null_num col26,
                        DECODE(CS.ORDER_TYPE, 5, to_char(CS.TRANSACTION_ID), CS.ORDER_NUMBER) col27,
                               -- Bug 2771075. For Planned Orders, we will populate transaction_id
			       -- in the disposition_name column to be consistent with Planning.
                        l_null_num col28,
                        l_null_num col29,
                        -- ship_rec_cal changes begin
                        l_sysdate,
                        G_USER_ID,
                        l_sysdate,
                        G_USER_ID,
                        G_USER_ID,
                        -- ship_rec_cal changes end
                        NVL(CS.FIRM_QUANTITY,CS.NEW_ORDER_QUANTITY), -- unallocated quantity
                        null, --bug3263368 ORIG_CUSTOMER_SITE_NAME
                        null, --bug3263368 ORIG_CUSTOMER_NAME
                        null, --bug3263368 ORIG_DEMAND_CLASS
                        null  --bug3263368 ORIG_REQUEST_DATE
            FROM

            	(	select
            		S.ORDER_TYPE,
			S.TRANSACTION_ID,
			S.ORDER_NUMBER,
			S.SR_INSTANCE_ID,
			C.NEXT_DATE,
			S.FIRM_QUANTITY,
			S.NEW_ORDER_QUANTITY,
			S.DEMAND_CLASS,
			s.inventory_item_id,
			S.CUSTOMER_ID,
			S.SHIP_TO_SITE_ID,
			S.ORGANIZATION_ID,
			C.CALENDAR_DATE

            FROM        MSC_CALENDAR_DATES C,
                        MSC_SUPPLIES S
            WHERE       S.PLAN_ID = p_plan_id
            AND         S.SR_INSTANCE_ID = p_instance_id
            AND         S.INVENTORY_ITEM_ID = p_item_id
            AND         S.ORGANIZATION_ID = p_org_id
                        -- Exclude Cancelled Supplies 2460645
            AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
            AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
            AND         C.CALENDAR_CODE = p_cal_code
            AND         C.EXCEPTION_SET_ID = p_cal_exc_set_id
            AND         C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
            AND         C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                                AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE,
                                    NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
            AND         DECODE(TRUNC(S.LAST_UNIT_COMPLETION_DATE), --4135752
                               NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
            --2859130
            --AND         C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
            --                                                28, TRUNC(SYSDATE),
            --                                                C.NEXT_DATE)
            --AND         C.NEXT_DATE < NVL(p_itf,
            --                             C.NEXT_DATE + 1)
            AND         C.CALENDAR_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                                                            28, TRUNC(SYSDATE),
                                                            C.CALENDAR_DATE)
            AND         C.CALENDAR_DATE < NVL(p_itf,
                                         C.CALENDAR_DATE + 1))CS,
            MSC_ITEM_HIERARCHY_MV  MIHM
            WHERE
	    --4365873
                   CS.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
            AND    CS.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
            AND    CS.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
            AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
            AND    CS.NEXT_DATE >= MIHM.effective_date (+)
            AND    CS.NEXT_DATE <= MIHM.disable_date (+)
            AND    MIHM.demand_class (+) = p_demand_class
           )
           ; -- dsting removed order by col25
END item_alloc_avail_unopt_dtls;

---------------------------------------------------------------------------

PROCEDURE item_alloc_avail (
   p_optimized_plan     IN NUMBER,
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sys_next_date	IN DATE,			--bug3099066
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail');
        END IF;

        IF nvl(p_optimized_plan, 2) = 1 THEN
                item_alloc_avail_opt(
                     p_item_id,
                     p_org_id,
                     p_instance_id,
                     p_plan_id,
                     p_demand_class,
                     p_level_id,
                     p_itf,
                     p_cal_code,
                     p_cal_exc_set_id,
                     p_sys_next_date,	--bug3099066
                     x_atp_dates,
                     x_atp_qtys
          );
        ELSE
                item_alloc_avail_unopt(
                     p_item_id,
                     p_org_id,
                     p_instance_id,
                     p_plan_id,
                     p_demand_class,
                     p_level_id,
                     p_itf,
                     p_cal_code,
                     p_cal_exc_set_id,
                     p_sys_next_date,	--bug3099066
                     x_atp_dates,
                     x_atp_qtys
          );
        END IF;
END item_alloc_avail;

PROCEDURE item_alloc_avail_unalloc (
   p_optimized_plan     IN NUMBER,
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sys_next_date	IN DATE,			--bug3099066
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr,
   x_atp_unalloc_qtys   OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail_unalloc: Get unallocated qtys as well');
        END IF;

        IF nvl(p_optimized_plan, 2) = 1 THEN
                item_alloc_avail_opt_unalloc(
                     p_item_id,
                     p_org_id,
                     p_instance_id,
                     p_plan_id,
                     p_demand_class,
                     p_level_id,
                     p_itf,
                     p_cal_code,
                     p_cal_exc_set_id,
                     p_sys_next_date,		--bug3099066
                     x_atp_dates,
                     x_atp_qtys,
                     x_atp_unalloc_qtys
          );
        ELSE
                item_alloc_avail_unopt_unalloc(
                     p_item_id,
                     p_org_id,
                     p_instance_id,
                     p_plan_id,
                     p_demand_class,
                     p_level_id,
                     p_itf,
                     p_cal_code,
                     p_cal_exc_set_id,
                     p_sys_next_date,		--bug3099066
                     x_atp_dates,
                     x_atp_qtys,
                     x_atp_unalloc_qtys
          );
        END IF;
END item_alloc_avail_unalloc;

PROCEDURE item_alloc_avail_dtls (
   p_optimized_plan     IN NUMBER,
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_level_id           IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sr_item_id         IN NUMBER,
   p_level              IN NUMBER,
   p_identifier         IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_uom_code           IN VARCHAR2,
   p_sys_next_date	IN DATE)  	--bug3099066
   IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('item_alloc_avail_dtls');
        END IF;

        IF nvl(p_optimized_plan, 2) = 1 THEN
                item_alloc_avail_opt_dtls(
                   p_item_id,
                   p_org_id,
                   p_instance_id,
                   p_plan_id,
                   p_demand_class,
                   p_level_id,
                   p_itf,
                   p_cal_code,
                   p_cal_exc_set_id,
                   p_sr_item_id,
                   p_level,
                   p_identifier,
                   p_scenario_id,
                   p_uom_code,
                   p_sys_next_date		--bug3099066
                );
        ELSE
                item_alloc_avail_unopt_dtls(
                   p_item_id,
                   p_org_id,
                   p_instance_id,
                   p_plan_id,
                   p_demand_class,
                   p_level_id,
                   p_itf,
                   p_cal_code,
                   p_cal_exc_set_id,
                   p_sr_item_id,
                   p_level,
                   p_identifier,
                   p_scenario_id,
                   p_uom_code,
                   p_sys_next_date		--bug3099066
                );
        END IF;

END item_alloc_avail_dtls;
-- end 2859130

---------------------------------------------------------------------------

PROCEDURE Atp_Demand_Class_Consume(
        p_current_atp   IN OUT  NoCopy MRP_ATP_PVT.ATP_Info,
        p_steal_atp     IN OUT  NoCopy MRP_ATP_PVT.ATP_Info,
        p_atf_date      IN DATE := NULL)   -- time_phased_atp
IS
	i NUMBER; -- index for p_steal_atp
	j NUMBER; -- index for p_current_atp
	k NUMBER; -- starting point for consumption of p_current_atp
	m NUMBER;
        l_allowed_stealing_qty NUMBER;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('*******Begin Atp_Demand_Class_Consume Procedure******');

       m := p_current_atp.atp_period.FIRST;
       WHILE m is not null LOOP
            msc_sch_wb.atp_debug('Atp_Demand_Class_Consume: ' || 'p_current_atp.atp_period , qty  = '||
	    p_current_atp.atp_period(m) ||' : '|| p_current_atp.atp_qty(m) );
         m := p_current_atp.atp_qty.Next(m);
       END LOOP;

       m := p_steal_atp.atp_period.FIRST;
       WHILE m is not null LOOP
            msc_sch_wb.atp_debug('Atp_Demand_Class_Consume: ' || 'p_steal_atp.atp_period and qty = '||
	    p_steal_atp.atp_period(m) ||' : '|| p_steal_atp.atp_qty(m));
         m := p_steal_atp.atp_qty.Next(m);
       END LOOP;
    END IF;

    k := p_current_atp.atp_period.FIRST;
    -- i is the index for steal_atp

    FOR i in 1..p_steal_atp.atp_qty.COUNT LOOP

        -- consume current_atp (backward) if we have neg in steal_atp
        IF (p_steal_atp.atp_qty(i) < 0 ) THEN

            k := NVL(k, 1); --  if k is null, make it as 1 so that
                            --  we can find the starting point for the first
                            --  element.

            WHILE (k IS NOT NULL)  LOOP
             IF k = p_current_atp.atp_period.LAST THEN
               -- this is the last record
              IF (p_current_atp.atp_period(k) > p_steal_atp.atp_period(i)) THEN
                -- cannot do any consumption since the date from p_steal_atp
                -- is greater than p_ccurrent_atp
                k := NULL;
              END IF;
              EXIT; -- exit the loop since this is the last record

             ELSE
               -- this is not the last record
              IF ((p_current_atp.atp_period(k) <= p_steal_atp.atp_period(i))
                 AND (p_current_atp.atp_period(k+1)>p_steal_atp.atp_period(i)))
              THEN
                 -- this is the starting point, we can exit now
		 IF PG_DEBUG in ('Y', 'C') THEN
		    msc_sch_wb.atp_debug('Atp_Demand_Class_Consume: ' || 'exit at k = ' ||to_char(k)||' and i = ' ||to_char(i));
		 END IF;
                 EXIT;
              ELSE
                 k := p_current_atp.atp_period.NEXT(k);
              END IF;
             END IF;
            END LOOP;

            j:= k;

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug ('Atp_Demand_Class_Consume: ' || 'starting consumption for (i) th element in stealing tab, start from j th element of current tab.  i = '||i || 'j = '||j);
	END IF;

            WHILE (NVL(j, -1) > 0) LOOP

                -- 02/16: find the allowed stealing quantity
                -- time_phased_atp
                IF ((p_atf_date is not null) and (p_steal_atp.atp_period(i)>p_atf_date) and (p_current_atp.atp_period(j)<=p_atf_date)) THEN
                    -- exit loop when crossing time fence
                    j := 0;
                -- 02/16: changed the if
                ELSIF (p_current_atp.atp_qty(j) <=0 ) THEN
                    --  backward one more period
                    j := j-1 ;
                ELSE
                    IF (p_current_atp.atp_qty(j) + p_steal_atp.atp_qty(i)< 0) THEN
                        -- not enough to cover the shortage
                        p_steal_atp.atp_qty(i) := p_steal_atp.atp_qty(i) +
                                                  p_current_atp.atp_qty(j);
                        --- bug 1657855, remove support for min alloc
                        p_current_atp.atp_qty(j) := 0;
                        --p_current_atp.limit_qty(j) := 0;
                        j := j-1;
                    ELSE
                        -- enough to cover the shortage
			-- Bug 1665096, index i is being used instead of j for p_current_atp
			-- ngoel 3/2/2001
                        --p_current_atp.atp_qty(j) := p_current_atp.atp_qty(i) +
                        p_current_atp.atp_qty(j) := p_current_atp.atp_qty(j) +
                                                    p_steal_atp.atp_qty(i);
                        ---p_current_atp.limit_qty(j) :=
                        ---               p_current_atp.limit_qty(j)+
                        ---               p_steal_atp.atp_qty(i);
                        p_steal_atp.atp_qty(i) := 0;
                        j := -1;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END LOOP;

END Atp_Demand_Class_Consume;


PROCEDURE Add_to_Next_Steal_Atp(
        p_current_atp      IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info,
        p_next_steal_atp   IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info)
IS
	i 			PLS_INTEGER; -- index for p_current_atp
	j 			PLS_INTEGER; -- index for p_next_steal_atp
	k 			PLS_INTEGER; -- index for l_next_steal_atp
	n 			PLS_INTEGER; -- starting point of p_next_steal_atp
	l_next_steal_atp  	MRP_ATP_PVT.ATP_Info; -- this will be the output
        l_processed             BOOLEAN := FALSE ;
BEGIN

  -- this procedure will combine p_current_atp and p_next_steal_atp to form
  -- a new record of tables and then return as p_next_steal_atp.
  -- they need to be ordered by.

  j := p_next_steal_atp.atp_period.FIRST;
  k := 0;
  FOR i IN 1..p_current_atp.atp_period.COUNT LOOP
    -- we only worry about the neg quantity (that's why we need to steal

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug ('Add_to_Next_Steal_Atp: ' ||  'we are in i loop for current steal, i='||i);
    END IF;
    IF p_current_atp.atp_qty(i) < 0 THEN
       l_processed := FALSE; --1923405
       WHILE (j IS NOT NULL) LOOP
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug ('Add_to_Next_Steal_Atp: ' ||  'we are in j loop for next steal, j='||j);
         END IF;
         IF p_next_steal_atp.atp_qty(j) < 0 THEN

          k := k+1;
          l_next_steal_atp.atp_period.Extend;
          l_next_steal_atp.atp_qty.Extend;

          IF p_next_steal_atp.atp_period(j) < p_current_atp.atp_period(i) THEN

            -- we add this to l_next_steal_atp
            l_next_steal_atp.atp_period(k) := p_next_steal_atp.atp_period(j);
            l_next_steal_atp.atp_qty(k) := p_next_steal_atp.atp_qty(j);

          ELSIF p_next_steal_atp.atp_period(j)=p_current_atp.atp_period(i) THEN

            -- both record (p_next_steal_atp and p_current_atp) are on the same
            -- date.  we need to sum them up
            l_processed := TRUE; -- 1923405
            l_next_steal_atp.atp_period(k) := p_next_steal_atp.atp_period(j);
            l_next_steal_atp.atp_qty(k) := p_next_steal_atp.atp_qty(j) +
                                           p_current_atp.atp_qty(i);
            -- j := j+1;
            j := p_next_steal_atp.atp_period.NEXT(j);
            EXIT; -- exit the loop since we had done group by before. so
                  -- we don't need to go to next record any more
          ELSE -- this is the greater part
            l_processed := TRUE; -- 1923405
            l_next_steal_atp.atp_period(k) := p_current_atp.atp_period(i);
            l_next_steal_atp.atp_qty(k) := p_current_atp.atp_qty(i);
            EXIT; -- exit the loop since we had done group by before.

          END IF;
         END IF; -- p_next_steal_atp.atp_qty < 0
         j := p_next_steal_atp.atp_period.NEXT(j) ;
       END LOOP;

       -- 1923405: undo 1739629, add l_processed = FALSE condition
       IF (j is null) AND (l_processed = FALSE) THEN
         -- this means p_next_steal_atp is over,
         -- so we don't need to worry about p_next_steak_atp,
         -- we just keep add p_current_atp to l_next_steal_atp
         -- if they are not added before
         k := k+1;
         l_next_steal_atp.atp_period.Extend;
         l_next_steal_atp.atp_qty.Extend;

         l_next_steal_atp.atp_period(k) := p_current_atp.atp_period(i);
         l_next_steal_atp.atp_qty(k) := p_current_atp.atp_qty(i);
       END IF;
       -- AATP Forward Consumption rajjain begin
       -- After adding negatives from p_current_atp to p_next_steal_atp
       -- we update the the negatives in p_current_atp to zero.
       p_current_atp.atp_qty(i) := 0;
       -- AATP Forward Consumption rajjain end
    END IF; -- p_current_atp.atp_qty < 0
  END LOOP;

  -- now we have taken care of all p_current_atp and part of
  -- p_next_steal_atp. now we need to take care the rest of p_next_steal_atp

  -- FOR j IN n..p_next_steal_atp.atp_period.COUNT LOOP
  WHILE j is not null LOOP
         IF p_next_steal_atp.atp_qty(j) < 0 THEN
            -- we add this to l_next_steal_atp
            k := k+1;
            l_next_steal_atp.atp_period.Extend;
            l_next_steal_atp.atp_qty.Extend;
            l_next_steal_atp.atp_period(k) := p_next_steal_atp.atp_period(j);
            l_next_steal_atp.atp_qty(k) := p_next_steal_atp.atp_qty(j);
         END IF;
         j := p_next_steal_atp.atp_period.NEXT(j);
  END LOOP;

  p_next_steal_atp := l_next_steal_atp;

END Add_to_Next_Steal_Atp;


PROCEDURE Item_Alloc_Cum_Atp(
	p_plan_id 	      IN NUMBER,
	p_level               IN NUMBER,
	p_identifier          IN NUMBER,
	p_scenario_id         IN NUMBER,
	p_inventory_item_id   IN NUMBER,
	p_organization_id     IN NUMBER,
	p_instance_id         IN NUMBER,
	p_demand_class        IN VARCHAR2,
	p_request_date        IN DATE,
	p_insert_flag         IN NUMBER,
	x_atp_info            OUT  NoCopy MRP_ATP_PVT.ATP_Info,
	x_atp_period          OUT  NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   OUT  NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
        p_get_mat_in_rec      IN   MSC_ATP_REQ.get_mat_in_rec,
	p_request_item_id     IN NUMBER, -- For time_phased_atp
	p_atf_date            IN DATE)   -- For time_phased_atp
IS
	l_infinite_time_fence_date	DATE;
	l_default_atp_rule_id           NUMBER;
	l_calendar_exception_set_id     NUMBER;
        l_level_id                      NUMBER;
	l_priority			NUMBER := 1;
	l_allocation_percent		NUMBER := 100;
	l_inv_item_id			NUMBER;
	l_null_num  			NUMBER := null;
	l_steal_period_quantity		NUMBER;
	l_demand_class			VARCHAR2(80);
	l_uom_code			VARCHAR2(3);
	l_null_char    			VARCHAR2(3) := null;
	l_return_status			VARCHAR2(1);
	l_default_demand_class          VARCHAR2(34);
	l_calendar_code                 VARCHAR2(14);
	i				PLS_INTEGER;
	mm				PLS_INTEGER;
	ii                              PLS_INTEGER;
	jj                              PLS_INTEGER;
	j				PLS_INTEGER;
	k				PLS_INTEGER;
	l_demand_class_tab		MRP_ATP_PUB.char80_arr
       		                            := MRP_ATP_PUB.char80_arr();
	l_demand_class_priority_tab	MRP_ATP_PUB.number_arr
       		                            := MRP_ATP_PUB.number_arr();
	l_current_atp			MRP_ATP_PVT.ATP_Info;
	l_next_steal_atp		MRP_ATP_PVT.ATP_Info;
	l_current_steal_atp             MRP_ATP_PVT.ATP_Info;
        l_temp_atp                      MRP_ATP_PVT.ATP_Info;
	l_null_steal_atp		MRP_ATP_PVT.ATP_Info;

        -- AATP Forward Consumption rajjain begin
	l_unallocated_atp		MRP_ATP_PVT.ATP_Info;
	l_lowest_priority_demand_class	VARCHAR2(80);
        l_lowest_priority		NUMBER;
	l_fw_consume_tab		MRP_ATP_PUB.number_arr
       		                            := MRP_ATP_PUB.number_arr();
	l_allocation_percent_tab	MRP_ATP_PUB.number_arr
       		                            := MRP_ATP_PUB.number_arr();
	l_next_fw_consume		PLS_INTEGER := 0;
	l_lowest_cust_priority		NUMBER;
	l_lowest_site_priority		NUMBER;
	-- AATP Forward Consumption rajjain end

        -- 1680719
        l_class_tab                     MRP_ATP_PUB.char30_arr
                                            := MRP_ATP_PUB.char30_arr();
        l_partner_tab                   MRP_ATP_PUB.number_arr
                                            := MRP_ATP_PUB.number_arr();
        l_class_next_steal_atp          MRP_ATP_PVT.ATP_Info;
        l_partner_next_steal_atp        MRP_ATP_PVT.ATP_Info;
        l_class_curr_steal_atp          MRP_ATP_PVT.ATP_Info;
        l_partner_curr_steal_atp        MRP_ATP_PVT.ATP_Info;
        l_pos1                            NUMBER;
        l_pos2                            NUMBER;
        delim     constant varchar2(1) := fnd_global.local_chr(13);

        -- krajan - 04/01/02 - Variable added for fsteal
        l_org_code                      VARCHAR2(7);

	l_temp_atp_supply_demand        MRP_ATP_PUB.ATP_Supply_Demand_Typ;
	l_sysdate 			DATE := trunc(sysdate);--4135752

	-- time_phased_atp
	l_time_phased_atp               VARCHAR2(1) := 'N';
	l_pf_item_id                    NUMBER;
        l_item_to_use                   NUMBER;


BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('******* Item_Alloc_Cum_Atp *******');
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_plan_id =' || p_plan_id );
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_level =' || p_level );
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_identifier =' || p_identifier);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_scenario_id =' || p_scenario_id);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_instance_id =' || p_instance_id);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_inventory_item_id =' || p_inventory_item_id);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_request_item_id =' || p_request_item_id);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_organization_id =' || p_organization_id);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_demand_class =' || p_demand_class);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_request_date =' || p_request_date );
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_insert_flag =' || p_insert_flag );
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_atf_date =' || p_atf_date );
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_get_mat_in_rec.sys_next_osc_date =' || p_get_mat_in_rec.sys_next_osc_date); --bug3333114
  END IF;


  /*-----------------------------------------------------------------------------------------+
  | rajjain begin 10/08/2002                                                                 |
  |                                                                                          |
  | Logic:                                                                                   |
  |                                                                                          |
  | Step 1: Find all the demand classes in the hierarchy                                     |
  |                                                                                          |
  | Step 2: If "MSC:Allocated ATP Forward Consumption Method" profile is set to              |
  |         "Reduce future supply from lowest priority", store the type of forward           |
  |         consumption in a PL/SQL table                                                    |
  |                                                                                          |
  | Step 3: If "MSC:Allocated ATP Forward Consumption Method" profile is set to              |
  |         "Reduce available supply from any priority", calculate unallocated availability  |
  |         Do backward consumption                                                          |
  |         Do forward consumption, do accumulation                                          |
  |                                                                                          |
  | Step 4: For each demand class DCi ->                                                     |
  |         1. get the daily net availability                                                |
  |         2. do backward consumption for DCi                                               |
  |         3. do demand class consumption if DC1 to DC(i-1) has any negative bucket         |
  |         4. If "MSC:Allocated ATP Forward Consumption Method" profile is set to           |
  |            a) "Reduce future supply from lowest priority" (Method 1)                     |
  |               Do the type of forward consumption we stored in the PL/SQL table           |
  |               Do accumulation                                                            |
  |            b) "Reduce available supply from any priority" (Method 2)                     |
  |               Do accumulation                                                            |
  |               Use the unallocated cum and calculated the adjusted cum                    |
  |                                                                                          |
  | Step 5: Exit from the l_demand_class_tab loop if l_demand_class is the requested DC      |
  |                                                                                          |
  +-----------------------------------------------------------------------------------------*/

 -- time_phased_atp
 IF (p_inventory_item_id <> p_request_item_id and p_atf_date is not null) THEN
        l_time_phased_atp := 'Y';
        l_pf_item_id := MSC_ATP_PVT.G_ITEM_INFO_REC.product_family_id;
 END IF;

 -- rajjain 01/29/2003 begin Bug 2737596
 IF p_identifier = -1 THEN
    BEGIN
       SELECT inventory_item_id, uom_code
       INTO   l_inv_item_id, l_uom_code
       FROM   msc_system_items
       WHERE  plan_id = p_plan_id
       AND    sr_instance_id = p_instance_id
       AND    organization_id = p_organization_id
       AND    sr_inventory_item_id = p_inventory_item_id;
    EXCEPTION
       WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error selecting uom_code for the item');
          END IF;
    END;
 ELSE
    -- we need not select this in case of ATP QUERY as this information is available in G_ITEM_INFO_REC
    l_inv_item_id := MSC_ATP_PVT.G_ITEM_INFO_REC.inventory_item_id;
    l_uom_code := MSC_ATP_PVT.G_ITEM_INFO_REC.uom_code;
 END IF;
 -- rajjain 01/29/2003 end Bug 2737596

 /* New allocation logic for time_phased_atp changes begin
    For time phased ATP scenarios if allocation rule at member item is not defined then within ATF use
    allocation rule defined at family */
 IF l_time_phased_atp = 'Y' THEN
     IF p_request_date <= p_atf_date THEN
         IF MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF = 'Y' THEN
             l_item_to_use := l_inv_item_id;
         ELSE
             l_item_to_use := l_pf_item_id;
         END IF;
     ELSE
         l_item_to_use := l_pf_item_id;
     END IF;
 ELSE
     l_item_to_use := l_inv_item_id;
 END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Item to be used = ' || l_item_to_use);
 END IF;
 /* New allocation logic for time_phased_atp changes end */

 -- select the priority  and allocation_percent for that item/demand class.
 -- if no data found, check if this item has a valid allocation rule.
 -- otherwise return error.
 IF p_scenario_id <> -1 THEN
    MSC_AATP_PVT.Get_DC_Info(p_instance_id, l_item_to_use, p_organization_id, null, null,
     p_demand_class, p_request_date, l_level_id, l_priority, l_allocation_percent, l_return_status);

    IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error retrieving Priority and Demand Class');
        END IF;
    END IF;
 ELSE
     l_priority := -1;
     l_allocation_percent := NULL;
 END IF;

  -- find the demand classes that have priority higher (small number) than
  -- the requested demand class

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_allocation_percent = '||l_allocation_percent);
  END IF;

 /* rajjain 01/29/2003 Bug 2737596
    We don't need to select all demand classes in case this procdure is
    called from MSC_AATP_PVT.VIEW_ALLOCATION for view total*/
 IF p_identifier <> -1 or (p_identifier = -1 and p_scenario_id <> -1) THEN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before select the high priority demand class');
  END IF;

  /*AATP Forward Consumption rajjain begin
  1. Now we select all the demand classes in l_demand_class_tab irrespective of demand class for which
     Inquiry has come.
  2. l_allocation_percent_tab stores the allocation_percent for the demand classes.
  3. If inquiry is at level 2 or 3 we also populate l_fw_consume_tab which stores the type
     of forward consumption. We bulk collect 0 in l_fw_consume_tab to initialise it.

  Note:
  1. We order by allocation_percent in demand class scenario if we have multiple
     demand classes at same priority.
  2. We are not doing this for customer class scenario as it may impact performance
     negatively due to extra joins.*/

  /* time_phased_atp changes begin */
  -- bug 1680719
  IF l_level_id = -1 THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT demand_class, priority, allocation_percent
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab, l_allocation_percent_tab
    FROM   msc_item_hierarchy_mv
    WHERE  inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
    AND	   organization_id = p_organization_id
    AND    sr_instance_id = p_instance_id
    AND    p_request_date BETWEEN effective_date AND disable_date
    AND    level_id = l_level_id
    --rajjain added demand_class asc
    ORDER BY priority asc, allocation_percent desc, demand_class asc;

  ELSIF l_level_id = 1 THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT demand_class, priority, allocation_percent
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab, l_allocation_percent_tab
    FROM   msc_item_hierarchy_mv
    WHERE  inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
    AND    organization_id = p_organization_id
    AND    sr_instance_id = p_instance_id
    AND    p_request_date BETWEEN effective_date AND disable_date
    AND    level_id = l_level_id
    ORDER BY priority asc, class asc;

  ELSIF l_level_id = 2 THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT mv1.demand_class, mv1.priority, mv1.class, mv1.partner_id, 0, mv1.allocation_percent
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab,
                      l_class_tab, l_partner_tab, l_fw_consume_tab, l_allocation_percent_tab
    FROM   msc_item_hierarchy_mv mv1
    WHERE  mv1.inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
    AND    mv1.organization_id = p_organization_id
    AND    mv1.sr_instance_id = p_instance_id
    AND    p_request_date BETWEEN mv1.effective_date AND mv1.disable_date
    AND    mv1.level_id = l_level_id
    ORDER BY trunc(mv1.priority, -3), mv1.class ,
             trunc(mv1.priority, -2), mv1.partner_id;


  ELSIF l_level_id = 3 THEN

    -- bug 1680719
    -- we need to select the class, partner_id, partner_site_id

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT mv1.demand_class, mv1.priority, mv1.class, mv1.partner_id, 0, mv1.allocation_percent
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab,
                      l_class_tab, l_partner_tab, l_fw_consume_tab, l_allocation_percent_tab
    FROM   msc_item_hierarchy_mv mv1
    WHERE  mv1.inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
    AND    mv1.organization_id = p_organization_id
    AND    mv1.sr_instance_id = p_instance_id
    AND    p_request_date BETWEEN mv1.effective_date AND mv1.disable_date
    AND    mv1.level_id = l_level_id
    ORDER BY trunc(mv1.priority, -3), mv1.class ,
             trunc(mv1.priority, -2), mv1.partner_id,
             mv1.priority, mv1.partner_site_id;

  END IF;
  -- AATP Forward Consumption rajjain end
  /* time_phased_atp changes end */

  mm := l_demand_class_tab.FIRST;
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_demand_class_tab.count = '||
                        l_demand_class_tab.count);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_demand_class_priority_tab.count = '||
                        l_demand_class_priority_tab.count);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_allocation_percent_tab.count = '||
                        l_allocation_percent_tab.count);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_class_tab.count = '||
                        l_class_tab.count);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_partner_tab.count = '||
                        l_partner_tab.count);
  END IF;

 END IF;

 -- Need to add the requested demand class in case call is from
 -- View_Allocation for View Total, else l_demand_class_tab remains empty.
 IF l_demand_class_tab.count = 0 THEN
--/* 1665110
  -- add the request demand class into the list
  l_demand_class_tab.Extend;
  l_demand_class_priority_tab.Extend;
  -- krajan: 2745212
  l_allocation_percent_tab.Extend;

  i := l_demand_class_tab.COUNT;
  l_demand_class_priority_tab(i) := l_priority;
  l_demand_class_tab(i) := p_demand_class;
  -- 2745212
  l_allocation_percent_tab(i) := 100;

  -- 1680719
  IF l_level_id in (2, 3) THEN
      l_class_tab.Extend;
      l_partner_tab.Extend;
      -- krajan : 2745212
      l_fw_consume_tab.Extend;

      l_pos1 := instr(p_demand_class,delim,1,1);
      l_pos2 := instr(p_demand_class,delim,1,2);
      l_class_tab(i) := substr(p_demand_class,1,l_pos1-1);
      IF l_pos2 = 0 THEN
        l_partner_tab(i) := substr(p_demand_class,l_pos1+1);
      ELSE
        l_partner_tab(i) := substr(p_demand_class,l_pos1+1,l_pos2-l_pos1-1) ;
      END IF;
  END IF;
--1665110 */
 END IF;

  mm := l_demand_class_tab.FIRST;
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_demand_class_tab.count = '|| l_demand_class_tab.count);
  END IF;

  /*AATP Forward Consumption rajjain begin
  1. Level_id in (-1, 1) ->
     a. We calculate the l_lowest_priority and l_lowest_priority_demand_class.
     b. l_lowest_priority_demand_class is the lowest demand class with non zero
        allocation percentage.
     c. l_lowest_priority is the priority of l_lowest_priority_demand_class.
  2. Level_id in (2,3) ->
     a. We form the l_fw_consume_tab. This takes values from 0-4 which depends on
        type of forward consumption we do for this demand class.*/
  mm := l_demand_class_tab.LAST;
  -- we go bottom up in l_demand_class_tab
  IF l_level_id in (-1, 1) THEN

     WHILE mm is not null LOOP

     msc_sch_wb.atp_debug('---------------------l_demand_class_tab'||l_demand_class_tab(mm));--6359986
     IF (l_demand_class_tab(mm) ='-1') then							--6359986
      IF(MSC_ATP_PVT.G_ZERO_ALLOCATION_PERC = 'N') THEN	--6359986
      IF l_allocation_percent_tab(mm) <> 0 THEN
	  l_lowest_priority_demand_class := l_demand_class_tab(mm);
	  l_lowest_priority := l_demand_class_priority_tab(mm);
	  IF PG_DEBUG in ('Y', 'C') THEN
	     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_lowest_priority_demand_class: ' ||
	                        l_lowest_priority_demand_class);
	     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_lowest_priority: ' ||
	                        l_lowest_priority);
	  END IF;
	  EXIT;
      END IF;
      ELSE			--6359986 start
          l_lowest_priority_demand_class := l_demand_class_tab(mm);
	  			l_lowest_priority := l_demand_class_priority_tab(mm);
	  			IF PG_DEBUG in ('Y', 'C') THEN
	     			msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_lowest_priority_demand_class: ' ||
	                        l_lowest_priority_demand_class);
	     			msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_lowest_priority: ' ||
	                        l_lowest_priority);
	  			END IF;
	  			EXIT;
      END IF;

     ELSE
          l_lowest_priority_demand_class := l_demand_class_tab(mm);
	  			l_lowest_priority := l_demand_class_priority_tab(mm);
	  			IF PG_DEBUG in ('Y', 'C') THEN
	     			msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_lowest_priority_demand_class: ' ||
	                        l_lowest_priority_demand_class);
	     			msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_lowest_priority: ' ||
	                        l_lowest_priority);
	  			END IF;
	  			EXIT;
     END IF;	--6359986 end
      mm := l_demand_class_tab.Prior(mm);
     END LOOP;
  ELSIF l_level_id in (2, 3) THEN
    WHILE mm is not null LOOP
     IF (REPLACE(l_demand_class_tab(mm),FND_GLOBAL.LOCAL_CHR(13),' ') in ('-1','-1 -1 -1','-1 -1')) then --6359986
     IF(MSC_ATP_PVT.G_ZERO_ALLOCATION_PERC = 'N') THEN ----6359986
     IF l_allocation_percent_tab(mm) <> 0 THEN
        -- this is the lowest demand class with non zero allocation percentage
        l_fw_consume_tab(mm) := 4;
				l_lowest_priority_demand_class := l_demand_class_tab(mm);
				--5634348
	      l_lowest_priority := trunc(l_demand_class_priority_tab(mm), -3);
        -- krajan : 2745212
        mm := l_demand_class_tab.Prior(mm);

	exit;
     ELSE
        -- this is demand class with zero allocation percentage
        -- this dc needs to do forward consumption for its own negatives
        l_fw_consume_tab(mm) := 1;
     END IF;
     ELSE		--6359986 start
        -- this is the lowest demand class with non zero allocation percentage
        l_lowest_priority_demand_class := l_demand_class_tab(mm);
	      --5634348
	      l_lowest_priority := trunc(l_demand_class_priority_tab(mm), -3);
        -- krajan : 2745212

        l_fw_consume_tab(mm) := 4;
        mm := l_demand_class_tab.Prior(mm);
        exit;
     END IF;
    ELSE
       -- this is the lowest demand class with non zero allocation percentage
        l_lowest_priority_demand_class := l_demand_class_tab(mm);
	      --5634348
	      l_lowest_priority := trunc(l_demand_class_priority_tab(mm), -3);
        -- krajan : 2745212
        l_fw_consume_tab(mm) := 4;
        mm := l_demand_class_tab.Prior(mm);
        exit;
    END IF; --6359986 end
      msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'mm: '||mm);
      mm := l_demand_class_tab.Prior(mm);
    END LOOP;
    --l_lowest_priority := trunc(l_demand_class_priority_tab(mm), -3);	--5634348, commenting it

    WHILE mm is not null LOOP
     IF l_next_fw_consume <> 0 THEN
        IF l_allocation_percent_tab(mm) <> 0 THEN
            IF l_next_fw_consume = 2 THEN
              -- this is the lowest priority dc with non zero allocation % at current customer level
              -- set the lowest site priority
              l_lowest_site_priority := l_demand_class_priority_tab(mm);
            ELSIF l_next_fw_consume = 3 THEN
              -- this is the lowest priority customer with non zero allocation % at current
              -- customer class level. set the lowest customer and site priority
              l_lowest_cust_priority := trunc(l_demand_class_priority_tab(mm), -2);
              l_lowest_site_priority := l_demand_class_priority_tab(mm);
            END IF;
            l_fw_consume_tab(mm) := l_next_fw_consume;
            l_next_fw_consume := 0; -- reset l_next_fw_consume to zero
        ELSE
            -- dc with zero allocation %
            l_fw_consume_tab(mm) := 1;
        END IF;
     ELSIF l_class_tab(mm) <> l_class_tab(mm+1) THEN
      --customer class changed
      IF trunc(l_demand_class_priority_tab(mm), -3)<>trunc(l_demand_class_priority_tab(mm+1), -3) THEN
         --customer class priority changed
         exit;
      ELSE
         --reset the lowest customer and site priority at this level to null
         l_lowest_cust_priority := null;
         l_lowest_site_priority := null;
         IF l_allocation_percent_tab(mm) = 0 THEN
            -- allocation % zero set l_next_fw_consume
            l_next_fw_consume := 3;
            l_fw_consume_tab(mm) := 1;
         ELSE
            l_fw_consume_tab(mm) := 3;
            l_lowest_cust_priority := trunc(l_demand_class_priority_tab(mm), -2);
            l_lowest_site_priority := l_demand_class_priority_tab(mm);
         END IF;
      END IF;
     ELSIF l_partner_tab(mm) <> l_partner_tab(mm+1) THEN
       --customer changed
       --reset the lowest site priority at this level to null
       l_lowest_site_priority := null;
       IF trunc(l_demand_class_priority_tab(mm), -2) = trunc(l_demand_class_priority_tab(mm+1), -2)
          AND (l_lowest_cust_priority is null
               OR trunc(l_demand_class_priority_tab(mm), -2) = l_lowest_cust_priority) THEN
         --customer priority same
         IF l_allocation_percent_tab(mm) = 0 THEN
            -- allocation % zero set l_next_fw_consume
            l_next_fw_consume := 2;
            l_fw_consume_tab(mm) := 1;
         ELSE
            l_fw_consume_tab(mm) := 2;
            l_lowest_site_priority := l_demand_class_priority_tab(mm);
         END IF;
       END IF;
     ELSIF l_demand_class_priority_tab(mm) = l_demand_class_priority_tab(mm+1)
           AND (l_lowest_site_priority is null OR l_demand_class_priority_tab(mm) = l_lowest_site_priority) THEN
       --site priority same
       l_fw_consume_tab(mm) := 1;
     END IF;

     mm := l_demand_class_tab.Prior(mm);

    END LOOP;
  END IF;
  --bug3948494  For demand_class cases, if request comes for highest priority
  -- and l_lowest_priority is > 1 then process only requested demand class
  IF l_level_id = -1 and l_priority = 1 and l_lowest_priority > 1 THEN

    l_demand_class_tab.Delete;
    l_demand_class_priority_tab.Delete;
    l_allocation_percent_tab.Delete;

    l_demand_class_tab.Extend;
    l_demand_class_priority_tab.Extend;
    l_allocation_percent_tab.Extend;

    i := l_demand_class_tab.COUNT;
    l_demand_class_priority_tab(i) := l_priority;
    l_demand_class_tab(i) := p_demand_class;
    l_allocation_percent_tab(i) := l_allocation_percent;

    IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_demand_class_tab.count = '||
                        l_demand_class_tab.count);
      msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_demand_class_priority_tab.count = '||
                        l_demand_class_priority_tab.count);
      msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_allocation_percent_tab.count = '||
                        l_allocation_percent_tab.count);
    END IF;

  END IF;

  mm := l_fw_consume_tab.FIRST;
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_fw_consume_tab.count = '|| l_fw_consume_tab.count);
     WHILE mm is not null LOOP
        msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_fw_consume_tab = '||
           l_fw_consume_tab(mm));

        -- krajan : 2745212
        mm := l_fw_consume_tab.Next(mm);

     END LOOP;
  END IF;
  -- AATP Forward Consumption rajjain end 10/21/2002

  -- for performance reason, we need to get the following info and
  -- store in variables instead of joining it

  -- krajan: 04/01/02 Added l_org_code to call.
  /* Modularize Item and Org Info */
  -- changed Call
  MSC_ATP_PROC.get_global_org_info(p_instance_id, p_organization_id);
  l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
  l_calendar_code := MSC_ATP_PVT.G_ORG_INFO_REC.cal_code;
  l_calendar_exception_set_id := MSC_ATP_PVT.G_ORG_INFO_REC.cal_exception_set_id;
  l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
  l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
  /* Modularize Item and Org Info */

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_default_atp_rule_id='|| l_default_atp_rule_id);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_calendar_code='||l_calendar_code);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_calendar_exception_set_id'|| l_calendar_exception_set_id);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_default_demand_class'|| l_default_demand_class);
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_org_code'|| l_org_code);
  END IF;
  --diag_atp
  -- rajjain 01/29/2003 Bug 2737596
  -- Need to call get_infinite_time_fence_date procedure in case call is from View allocation
  -- as p_get_mat_in_rec will not be populated
  IF p_identifier = -1 THEN
     -- get the infinite time fence date if it exists
     l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(p_instance_id,
             p_inventory_item_id,p_organization_id, p_plan_id);
  ELSE
     ---diag_atp
     l_infinite_time_fence_date := p_get_mat_in_rec.infinite_time_fence_date;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_infinite_time_fence_date'|| l_infinite_time_fence_date);
  END IF;

  -- Now go demand class by demand class and calculate the allocated picture
  FOR i in 1..l_demand_class_tab.COUNT LOOP

          l_demand_class := l_demand_class_tab(i);
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'in i loop, i = '||i);
             msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_demand_class = '||l_demand_class);
          END IF;
    -- get the daily net availability for DCi
    IF (NVL(p_insert_flag, 0) = 0  OR l_demand_class <> p_demand_class) THEN
       -- we don't want details
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                             'Inside IF (NVL(p_insert_flag, 0) = 0');
       END IF;

       /* AATP Forward Consumption rajjain
       We calculate unallocated availability alongwith allocated availability calculation
       for first demand class if Forward consumption method is method2*/
       IF i=1 AND G_ATP_FW_CONSUME_METHOD = 2 THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                                'Inside IF i=1 AND Method2');
          END IF;
          -- time_phased_atp
          IF l_time_phased_atp='N' THEN
                  -- 2859130
                  item_alloc_avail_unalloc(
                     p_get_mat_in_rec.optimized_plan,
                     l_inv_item_id,
                     p_organization_id,
                     p_instance_id,
                     p_plan_id,
                     l_demand_class,
                     l_level_id,
                     l_infinite_time_fence_date,
                     l_calendar_code,
                     l_calendar_exception_set_id,
                     p_get_mat_in_rec.sys_next_osc_date,			--bug3099066 bug3333114
                     l_current_atp.atp_period,
                     l_current_atp.atp_qty,
                     l_unallocated_atp.atp_qty
                  );
          ELSE
                  MSC_ATP_PF.Item_Alloc_Avail_Pf_Unalloc(
                     l_inv_item_id,
                     l_pf_item_id,
                     p_organization_id,
                     p_instance_id,
                     p_plan_id,
                     l_demand_class,
                     l_level_id,
                     l_infinite_time_fence_date,
                     p_get_mat_in_rec.sys_next_osc_date,			--bug3099066 bug3333114
                     p_atf_date,
                     l_current_atp.atp_period,
                     l_current_atp.atp_qty,
                     l_unallocated_atp.atp_qty,
                     l_return_status
                  );
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error occured in procedure Item_Alloc_Avail_Pf_Unalloc');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;
          END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Before Atp_Consume for l_unallocated_atp');
	   mm := l_unallocated_atp.atp_qty.FIRST;
	   while mm is not null loop
		msc_sch_wb.atp_debug('l_unallocated_atp.atp_period:atp_qty = ' ||
		            l_current_atp.atp_period(mm) || ':' || l_unallocated_atp.atp_qty(mm));
		mm := l_unallocated_atp.atp_qty.NEXT(mm);
	   end loop;
        END IF;

        -- after calculating the net unallocated availability do b/w+f/w consumption and accumulation
        -- time_phased_atp
        IF l_time_phased_atp = 'Y' THEN
            MSC_ATP_PF.pf_atp_consume(
                   l_unallocated_atp.atp_qty,
                   l_return_status,
                   l_current_atp.atp_period,
                   MSC_ATP_PF.Bw_Fw_Cum, --b/w, f/w consumption and accumulation
                   p_atf_date);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error occured in procedure Pf_Atp_Consume');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            MSC_ATP_PROC.Atp_Consume(l_unallocated_atp.atp_qty, l_unallocated_atp.atp_qty.COUNT);
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'After Atp_Consume for l_unallocated_atp');
	   mm := l_unallocated_atp.atp_qty.FIRST;
	   while mm is not null loop
		msc_sch_wb.atp_debug('l_unallocated_atp.atp_period:atp_qty = ' ||
		            l_current_atp.atp_period(mm) || ':' || l_unallocated_atp.atp_qty(mm));
		mm := l_unallocated_atp.atp_qty.NEXT(mm);
	   end loop;
        END IF;

       ELSE
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                'Inside ELSE of IF i=1 AND G_ATP_FW_CONSUME_METHOD = 2 THEN');
          END IF;
          -- time_phased_atp
          IF l_time_phased_atp='N' THEN
                  item_alloc_avail(
                     p_get_mat_in_rec.optimized_plan,
                     l_inv_item_id,
                     p_organization_id,
                     p_instance_id,
                     p_plan_id,
                     l_demand_class,
                     l_level_id,
                     l_infinite_time_fence_date,
                     l_calendar_code,
                     l_calendar_exception_set_id,
                     p_get_mat_in_rec.sys_next_osc_date,			--bug3099066 bug3333114
                     l_current_atp.atp_period,
                     l_current_atp.atp_qty
                  );
          ELSE
                  MSC_ATP_PF.Item_Alloc_Avail_Pf(
                     l_inv_item_id,
                     l_pf_item_id,
                     p_organization_id,
                     p_instance_id,
                     p_plan_id,
                     l_demand_class,
                     l_level_id,
                     l_infinite_time_fence_date,
                     p_get_mat_in_rec.sys_next_osc_date,			--bug3099066 bug3333114
                     p_atf_date,
                     l_current_atp.atp_period,
                     l_current_atp.atp_qty,
                     l_return_status
                  );
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error occured in procedure Item_Alloc_Avail_Pf');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;
          END IF;
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: After calculating daily net availability');
           Print_Period_Qty('l_current_atp.atp_period:atp_qty = ', l_current_atp);
       END IF;

    ELSE
        -- IF (NVL(p_insert_flag, 0) <> 0  AND l_demand_class = p_demand_class)
        -- OR p_scenario_id = -1
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                 'Inside ELSE of IF (NVL(p_insert_flag, 0)=0 OR l_demand_class<>p_demand_class)');
        END IF;
        MSC_ATP_DB_UTILS.Clear_SD_Details_Temp();

        -- time_phased_atp
        IF l_time_phased_atp='N' THEN
                item_alloc_avail_dtls(
                   p_get_mat_in_rec.optimized_plan,
                   l_inv_item_id,
                   p_organization_id,
                   p_instance_id,
                   p_plan_id,
                   l_demand_class,
                   l_level_id,
                   l_infinite_time_fence_date,
                   l_calendar_code,
                   l_calendar_exception_set_id,
                   p_inventory_item_id,
                   p_level,
                   p_identifier,
                   p_scenario_id,
                   l_uom_code,
                   p_get_mat_in_rec.sys_next_osc_date			--bug3099066 bug3333114
                );
        ELSE
                MSC_ATP_PF.Item_Alloc_Avail_Pf_Dtls(
                   l_inv_item_id,
                   l_pf_item_id,
                   p_request_item_id,
                   p_inventory_item_id,
                   p_organization_id,
                   p_instance_id,
                   p_plan_id,
                   l_demand_class,
                   l_level_id,
                   l_infinite_time_fence_date,
                   p_level,
                   p_identifier,
                   p_scenario_id,
                   l_uom_code,
                   p_get_mat_in_rec.sys_next_osc_date,			--bug3099066 bug3333114
                   p_atf_date,
                   l_return_status
                );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error occured in procedure Item_Alloc_Avail_Pf_Dtls');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        END IF;

     -- for period ATP
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after insert into msc_atp_sd_details_temp');
        msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'num rows : ' || SQL%ROWCOUNT);
     END IF;

     /*AATP Forward Consumption rajjain begin
     If request comes at topmost demand class level get unallocated data
     along with period data from sd temp table*/
     IF i=1 AND G_ATP_FW_CONSUME_METHOD = 2 THEN

        -- time_phased_atp
        IF l_time_phased_atp='Y' THEN
           MSC_ATP_PF.Get_Unalloc_Data_From_Sd_Temp(x_atp_period, l_unallocated_atp, l_return_status);
        ELSE
           MSC_AATP_PROC.get_unalloc_data_from_SD_temp(x_atp_period, l_unallocated_atp, l_return_status);
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to get_unalloc_data_from_SD_temp');
           END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'After get_unalloc_data_from_SD_temp');
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_unallocated_atp.atp_qty.COUNT : '||l_unallocated_atp.atp_qty.COUNT);
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Before Atp_Consume for l_unallocated_atp');
	   mm := l_unallocated_atp.atp_qty.FIRST;
	   while mm is not null loop
		msc_sch_wb.atp_debug('l_unallocated_atp.atp_period:atp_qty = ' ||
		            x_atp_period.Period_Start_Date(mm) || ':' || l_unallocated_atp.atp_qty(mm));
		mm := l_unallocated_atp.atp_qty.NEXT(mm);
	   end loop;
        END IF;

        -- after calculating the net unallocated availability do b/w+f/w consumption and accumulation
        -- time_phased_atp
        IF l_time_phased_atp = 'Y' THEN
            MSC_ATP_PF.pf_atp_consume(
                   l_unallocated_atp.atp_qty,
                   l_return_status,
                   x_atp_period.Period_Start_Date,
                   MSC_ATP_PF.Bw_Fw_Cum, --b/w, f/w consumption and accumulation
                   p_atf_date);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error occured in procedure Pf_Atp_Consume');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        ELSE
            MSC_ATP_PROC.Atp_Consume(l_unallocated_atp.atp_qty, l_unallocated_atp.atp_qty.COUNT);
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'After Atp_Consume for l_unallocated_atp');
	   mm := l_unallocated_atp.atp_qty.FIRST;
	   while mm is not null loop
		msc_sch_wb.atp_debug('l_unallocated_atp.atp_period:atp_qty = ' ||
		            x_atp_period.Period_Start_Date(mm) || ':' || l_unallocated_atp.atp_qty(mm));
		mm := l_unallocated_atp.atp_qty.NEXT(mm);
	   end loop;
        END IF;

     ELSE
        -- time_phased_atp
        IF l_time_phased_atp='Y' THEN
           MSC_ATP_PF.Get_Period_Data_From_Sd_Temp(x_atp_period, l_return_status);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error occured in procedure Get_Period_Data_From_Sd_Temp');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
           END IF;
        ELSE
           /* time_phased_atp
              call new procedure to fix the issue of not displaying correct quantities in ATP SD Window when
              user opens ATP SD window from ATP pegging in allocated scenarios*/
           MSC_ATP_PROC.Get_Alloc_Data_From_Sd_Temp(x_atp_period, l_return_status);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error occured in procedure get_alloc_data_from_SD_temp');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Need not get unalloc data from SD temp');
        END IF;
     END IF;

     -- old netting code here

      l_current_atp.atp_period := x_atp_period.Period_Start_Date;
      l_current_atp.atp_qty := x_atp_period.Period_Quantity;
      -- bug 1657855, remove support for min alloc
      --l_current_atp.limit_qty := l_current_atp.atp_qty; -- 02/16

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'right after the big query');
       Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
    END IF;

    /* rajjain 01/29/2003 Bug 2737596
       We only need to do b/w consumption, f/w consumption and accumulation in case the call is
       from MSC_AATP_PVT.VIEW_ALLOCATION for view total*/
    IF p_identifier <> -1 or (p_identifier = -1 and p_scenario_id <> -1) THEN

      -- do backward consumption for DCi

      -- time_phased_atp
      IF l_time_phased_atp = 'Y' THEN
          MSC_ATP_PF.pf_atp_consume(
                 l_current_atp.atp_qty,
                 l_return_status,
                 l_current_atp.atp_period,
                 MSC_ATP_PF.Backward, --b/w consumption
                 p_atf_date);
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error occured in procedure Pf_Atp_Consume');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
          END IF;
      ELSE
            MSC_ATP_PROC.Atp_Backward_Consume(l_current_atp.atp_qty);
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'right after the backward consume');
         Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
   	        l_current_atp);
      END IF;



      -- we have 3 records of tables.
      -- l_current_atp: stores the date and quantity for this demand class,
      --                and since we need to do backward consumption on this.
      -- l_current_steal_atp: stores the date and quantity from higher priority
      --                      demand class, this need to consume l_current_atp
      -- l_next_steal_atp : stores  the date and quantity for next priority
      --                    demand class to cunsume.  we need this because we may
      --                    have multiple demand classes at same priority .
      -- for example, we have DC1 in priority 1, DC21, DC22 in priority 2,
      -- DC3 in priority  3.
      -- now DC21 need to take care DC1, DC22 need to take care DC1 but not DC21,
      -- DC3 need to take care DC1, DC21, and DC22.  so if we are in the loop for
      -- DC22, than l_current_atp is the atp info for DC22,
      -- l_current_steal_atp is the atp info for DC1(which does not include DC21),
      -- and l_next_steal_atp is the stealing data that we need to take care
      -- for DC1, DC21 and DC22  when later on we move to the loop for DC3.

      -- do backward consumption if DC1 to DC(i-1) has any negative bucket,and
      -- the priority  is higher than DCi
      -- the l_current_atp is an in/out parameter

      -- for 1680719, since in hierarchy demand class we cannot
      -- judge the priority by just looking at the priority (we need
      -- the information from the parent, so the condition needs to be changed.

      IF l_level_id IN (-1, 1) THEN
        -- here is the old logic which should still be ok for level id 1 and -1
       IF (i > 1) THEN

        IF (l_demand_class_priority_tab(i) >
            l_demand_class_priority_tab (i-1)) THEN
        -- we don't need to change the l_current_steal_atp if we don't
        -- move to next priority.
        -- but we do need to change the l_current_steal_atp
        -- if we are in different priority  now.

          l_current_steal_atp := l_next_steal_atp;

          -- Added for bug 1409335. Need to initialize l_next_steal_atp
          -- otherwise quanities would be getting accumulated
          -- repeatedly.
          l_next_steal_atp := l_null_steal_atp;
        END IF;
       END IF;
      ELSE -- IF l_level_id IN (-1, 1) THEN

       IF (i > 1) THEN

        IF (l_class_tab(i) <> l_class_tab(i-1)) THEN

          -- class changed.  If priority of both classes are not the same,
          -- then we need to change the curr_steal_atp  at class level.

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'class changed');
          END IF;

          IF trunc(l_demand_class_priority_tab(i), -3) >
             trunc(l_demand_class_priority_tab (i-1), -3) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'class priority changed');
            END IF;
            l_class_curr_steal_atp := l_class_next_steal_atp;
            l_class_next_steal_atp := l_null_steal_atp;
          END IF;

          l_partner_next_steal_atp := l_null_steal_atp;
          l_partner_curr_steal_atp := l_null_steal_atp;
          l_partner_next_steal_atp := l_null_steal_atp;
          l_current_steal_atp := l_null_steal_atp;
          l_next_steal_atp := l_null_steal_atp;

        ELSE
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'same class');
          END IF;
          IF (l_partner_tab(i) <> l_partner_tab(i-1)) THEN
            -- customer changed.  If priority of both customers are not the
            -- same, we need to change the curr_steal_atp  at partner level.

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'customer changed');
            END IF;

            IF trunc(l_demand_class_priority_tab(i), -2) >
               trunc(l_demand_class_priority_tab (i-1), -2) THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'customer priority changed');
              END IF;

              l_partner_curr_steal_atp := l_partner_next_steal_atp;
              l_partner_next_steal_atp := l_null_steal_atp;
            END IF;

            l_current_steal_atp := l_null_steal_atp;
            l_next_steal_atp := l_null_steal_atp;

          ELSE
            -- same customer
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'same customer ');
            END IF;

            IF (l_demand_class_priority_tab(i) >
                l_demand_class_priority_tab (i-1)) THEN
              -- site level priority changed

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'site priority changed');
              END IF;
              l_current_steal_atp := l_next_steal_atp;
              l_next_steal_atp := l_null_steal_atp;

            END IF;
          END IF; -- IF (l_partner_tab(i) <> l_partner_tab(i-1))
        END IF; -- IF (l_class_tab(i) <> l_class_tab(i-1))

       END IF; -- IF (i > 1)

      END IF; -- IF l_level_id IN (-1, 1)
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before we decide we need to do dc consumption');
      END IF;
      IF (i > 1) THEN
       IF (  -- this is the huge condition
             ((l_level_id IN (-1, 1)) AND
             (l_demand_class_priority_tab(i) <> l_demand_class_priority_tab(1)))
           OR
             (l_level_id in (2, 3))
          ) THEN

        -- we need to do demand class consume only if we are not in the first
        -- preferred priority

        -- bug 1413459
        -- we need to remember what's the atp picture before the
        -- demand class consumption but after it's own backward
        -- consumption.  so that we can figure out the stealing
        -- quantity correctly.
        IF (NVL(p_insert_flag, 0) <>0)
           AND (l_demand_class_tab(i) = p_demand_class) THEN
            l_temp_atp := l_current_atp;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_demand_class : '||p_demand_class);
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_demand_class_tab(i) : '||l_demand_class_tab(i));
        END IF;

        -- 1680719
        -- since we have hierarchy now, before we do demand class
        -- consumption for site level, we need to do the class level and
        -- partner level first

        IF l_level_id IN (2,3) THEN

          IF l_class_tab(i) <> l_class_tab(1) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before consume l_class_curr_steal_atp');
               Print_Period_Qty('l_class_curr_steal_atp.atp_period:atp_qty = ',
			l_class_curr_steal_atp);
            END IF;

            /* time_phased_atp
               pass p_atf_date to make sure we do not do demand class consumption across ATF*/
            MSC_AATP_PVT.Atp_Demand_Class_Consume(l_current_atp, l_class_curr_steal_atp, p_atf_date);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'After consume l_class_curr_steal_atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_class_curr_steal_atp.atp_period:atp_qty = ',
			l_class_curr_steal_atp);

            END IF;

          END IF; --IF l_class_tab(i) <> l_class_tab(1) THEN

          -- bug 1922942: although partner_id should be unique, we introduced
          -- -1 for 'Other' which make the partner_id not unique.
          -- for example, Class1/Other and Class2/Other will have same
          -- partner_id -1. so the if condition needs to be modified.

          -- IF l_partner_tab(i) <> l_partner_tab(1) THEN

          IF (l_class_tab(i) <> l_class_tab(1)) OR
              (l_partner_tab(i) <> l_partner_tab(1)) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before consume l_partner_curr_steal_atp');
            END IF;
            /* time_phased_atp
               pass p_atf_date to make sure we do not do demand class consumption across ATF*/
            MSC_AATP_PVT.Atp_Demand_Class_Consume(l_current_atp, l_partner_curr_steal_atp, p_atf_date);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'After consume l_partner_curr_steal_atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_partner_curr_steal_atp.atp_period:atp_qty = ',
			l_partner_curr_steal_atp);
            END IF;

          END IF; -- IF l_partner_tab(i) <> l_partner_tab(1) THEN

        END IF; -- IF l_level_id IN (2,3)

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Before consume current_steal_atp');
           Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
        END IF;

        /* time_phased_atp
           pass p_atf_date to make sure we do not do demand class consumption across ATF*/
        MSC_AATP_PVT.Atp_Demand_Class_Consume(l_current_atp, l_current_steal_atp, p_atf_date);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'After consume l_current_steal_atp');

           Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
           Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		l_current_steal_atp);
        END IF;

        -- this part is not in the original design.
        -- original design is that we will ignore the inconsistancy
        -- in the s/d and period atp for display when stealing happens, as long
        -- as we take care the stealing in the logic.
        -- but i think it is still better to put it in.
        -- and actually if we change Atp_Demand_Class_Consume we can
        -- deal with this together.  but for now...

        -- we need to know if we need to store the stealing
        -- results in to x_atp_supply_demand and x_atp_period or not.
        -- we only do it if this is the demand class we request and
        -- insert_flag is on

        IF (NVL(p_insert_flag, 0) <>0) AND (l_demand_class_tab(i) = p_demand_class) THEN

          /*rajjain begin 12/10/2002
          We now do following instead of making call to MSC_SATP_FUNC.Extend_Atp_Supply_Demand
          number of times condition l_current_atp.atp_qty(j) < l_temp_atp.atp_qty(j) is true
          inside FOR LOOP
          1. Before FOR loop we extend l_temp_atp_supply_demand by l_current_atp.atp_qty.COUNT
          2. After FOR loop we trim the remaining.*/

          -- initialize k
          k := l_temp_atp_supply_demand.Level.Count;
          MSC_SATP_FUNC.Extend_Atp_Supply_Demand(l_temp_atp_supply_demand, l_return_status,
                        l_current_atp.atp_qty.COUNT);

          IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'k before FOR LOOP = ' || k);
          END IF;

          FOR j in 1..l_current_atp.atp_qty.COUNT LOOP

            IF l_current_atp.atp_qty(j) < l_temp_atp.atp_qty(j) THEN
              -- this is the stealing quantity in that period

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                            'l_current_atp.atp_qty(j)='||l_current_atp.atp_qty(j));
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                            'l_temp_atp.atp_qty(j)='||l_temp_atp.atp_qty(j));
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                            'l_steal_period_quantity='||l_steal_period_quantity);
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                            'x_atp_period.period_start_date(j)='||x_atp_period.period_start_date(j));
              END IF;

              -- bug 1413459: the stealing quantity should be the current
              -- period quantity (after backward consumption, after stealing)
              -- minus the period quantity after backward consumption but
              -- before the stealing
              l_steal_period_quantity := l_current_atp.atp_qty(j) -
                                         l_temp_atp.atp_qty(j);

              /*rajjain 12/10/2002 This procedure call is not needed as we have already extended
              l_temp_atp_supply_demand outside this FOR loop
              MSC_SATP_FUNC.Extend_Atp_Supply_Demand(l_temp_atp_supply_demand, l_return_status);

              k := l_temp_atp_supply_demand.Level.Count;*/

              k := k+1; -- rajjain increment k
              l_temp_atp_supply_demand.level(k) := p_level;
              l_temp_atp_supply_demand.identifier(k) := p_identifier;
              l_temp_atp_supply_demand.scenario_id(k) := p_scenario_id;
              l_temp_atp_supply_demand.inventory_item_id(k) := p_inventory_item_id;
              l_temp_atp_supply_demand.uom(k):= l_uom_code;
              l_temp_atp_supply_demand.supply_demand_type(k) := 1;

              -- Bug 1408132 and 1416290, Need to insert type as
              -- Demand Class Consumption (45).

              l_temp_atp_supply_demand.identifier1(k) := p_instance_id;
              l_temp_atp_supply_demand.supply_demand_date (k) := l_current_atp.atp_period(j);
              l_temp_atp_supply_demand.supply_demand_quantity(k) := l_steal_period_quantity;

              -- time_phased_atp change begin
              l_temp_atp_supply_demand.organization_id(k) := p_organization_id;
              IF l_time_phased_atp='Y' THEN
                 l_temp_atp_supply_demand.request_item_id(k) := p_request_item_id;
                 l_temp_atp_supply_demand.supply_demand_source_type(k) := 51;
                 l_temp_atp_supply_demand.Original_Supply_Demand_Type(k) := 45;
                 l_temp_atp_supply_demand.Original_Item_Id(k) := p_request_item_id;
                 l_temp_atp_supply_demand.Original_Demand_Date(k) := l_current_atp.atp_period(j);
                 l_temp_atp_supply_demand.Original_Demand_Quantity(k) := l_steal_period_quantity;
                 l_temp_atp_supply_demand.Allocated_Quantity(k) := l_steal_period_quantity;
                 l_temp_atp_supply_demand.Pf_Display_Flag(k) := 1;
                 x_atp_period.Total_Bucketed_Demand_Quantity(j):=
                        x_atp_period.Total_Bucketed_Demand_Quantity(j) + l_steal_period_quantity;
              ELSE
                 l_temp_atp_supply_demand.request_item_id(k) := p_inventory_item_id;
                 l_temp_atp_supply_demand.supply_demand_source_type(k) := 45;
              END IF;
              -- time_phased_atp change end

              x_atp_period.Total_Demand_Quantity(j):=
                     x_atp_period.Total_Demand_Quantity(j) + l_steal_period_quantity;

              x_atp_period.period_quantity(j):=x_atp_period.period_quantity(j)
                     + l_steal_period_quantity;

            END IF;
          END LOOP;

          IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'k after FOR LOOP = ' || k);
          END IF;

          --rajjain trim the remaining 12/10/2002
          MSC_SATP_FUNC.Trim_Atp_Supply_Demand(l_temp_atp_supply_demand, l_return_status,
                        (l_temp_atp_supply_demand.Level.Count - k));

	  -- dsting dump the data into msc_atp_sd_details_temp
	  -- and null out the record
	  move_SD_plsql_into_SD_temp(l_temp_atp_supply_demand);

        END IF;  -- IF (NVL(p_insert_flag, 0) <>0) .....
       END IF; -- the huge condition
      END IF; -- IF (i > 1)

      -- AATP Forward Consumption rajjain begin
      IF l_level_id IN (-1, 1) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Inside IF l_level_id IN (-1, 1) THEN');
        END IF;

        /*1. If level_id is in (-1, 1) and forward consumption method is method1
              for the lowest priority demand class -> add negatives from l_current_steal to
              l_current_atp and do forward consumption
          2. If level_id is in (-1, 1) and forward consumption method is method2
              for the lowest priority demand class -> call Atp_Remove_Negatives to remove
              all the negatives from l_current_atp*/
	IF l_demand_class = l_lowest_priority_demand_class THEN
          IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'This is l_lowest_priority_demand_class');
          END IF;
          IF G_ATP_FW_CONSUME_METHOD = 1 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Method 1');
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'level = '||l_level_id);
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Add_to_Current_Atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
			l_current_steal_atp);
            END IF;

            MSC_AATP_PROC.Add_to_Current_Atp(l_current_steal_atp, l_current_atp, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Add_to_Current_Atp');
               END IF;
            END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Add_to_Current_Atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
            END IF;

            MSC_AATP_PROC.Atp_Forward_Consume(l_current_atp.atp_period, p_atf_date, l_current_atp.atp_qty, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Forward_Consume');
               END IF;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Atp_Forward_Consume for last demand class');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
            END IF;

            /*Call Atp_Remove_Negatives to remove negatives in case we have negatives left
            after forward consumption. we will not show these negatives in atp_inquiry for
            Allocated ATP with User Defined %.*/

            MSC_AATP_PROC.Atp_Remove_Negatives(l_current_atp.atp_qty, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Remove_Negatives');
               END IF;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Atp_Remove_Negatives');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
            END IF;

          ELSE
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Method 2');
            END IF;
	    MSC_AATP_PROC.Atp_remove_negatives(l_current_atp.atp_qty, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_remove_negatives');
               END IF;
            END IF;

          END IF;

	ELSE
          IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'This is not the l_lowest_priority_demand_class');
          END IF;
	  IF l_demand_class_priority_tab(i) < l_lowest_priority OR G_ATP_FW_CONSUME_METHOD = 2 THEN
            -- this demand class is not the lowest priority demand class
            -- add negatives from l_current_atp to l_next_steal_atp
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: '||'l_demand_class_priority_tab(i)<l_lowest_priority'||
                          ' OR G_ATP_FW_CONSUME_METHOD = 2');
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Add_to_Next_Steal_Atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
			l_next_steal_atp);
            END IF;

            -- we need to prepare the l_next_steal_atp for next priority
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_atp, l_next_steal_atp);
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Add_to_Next_Steal_Atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
			l_next_steal_atp);
            END IF;

            IF i < l_demand_class_priority_tab.LAST AND l_demand_class_priority_tab(i)<
               l_demand_class_priority_tab(i+1) THEN
               -- this is the last element of current priority, so we also need
               -- to add l_steal_atp into l_next_steal_atp if we can not finish
               -- the stealing at this priority
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'This is the last element of current priority');
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'level = '||l_level_id);
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Adding Add_to_Next_Steal_Atp');

                  Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
		       l_next_steal_atp);
               END IF;

               MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Add_to_Next_Steal_Atp');

                  Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
		       l_next_steal_atp);
               END IF;

            END IF;

          ELSE
	    /* this is the lowest priority demand class in case
	    we have multiple demand classes at lowest priority
	    do forward consumption for all the lowest priority demand classes for method 1*/
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'This demand class is of l_lowest_priority');
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'level = '||l_level_id);
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                          'before Forward Consumption for lowest priority demand classes');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
            END IF;

	    MSC_AATP_PROC.Atp_Forward_Consume(l_current_atp.atp_period, p_atf_date, l_current_atp.atp_qty, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Forward_Consume');
               END IF;
            END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                          'after Forward Consumption for lowest priority demand classes');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
            END IF;

            /*Call Atp_Remove_Negatives to remove negatives in case we have negatives left
            after forward consumption. we will not show these negatives in atp_inquiry for
            Allocated ATP with User Defined %.*/

            MSC_AATP_PROC.Atp_Remove_Negatives(l_current_atp.atp_qty, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Remove_Negatives');
               END IF;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Atp_Remove_Negatives');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
            END IF;

	  END IF;

	END IF;

      ELSE --IF l_level_id IN (-1, 1) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Inside ELSE of IF l_level_id IN (-1, 1) THEN');
        END IF;
	IF l_demand_class = l_lowest_priority_demand_class THEN
          IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'This is l_lowest_priority_demand_class');
          END IF;
          IF G_ATP_FW_CONSUME_METHOD = 1 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Method 1');
            END IF;
	    IF l_fw_consume_tab(i) = 4 THEN
              -- add all negatives to l_current_atp and do forward consumption
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_fw_consume_tab(i) is 4');
              END IF;
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_partner_next_steal_atp);
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_curr_steal_atp,
                                    l_partner_next_steal_atp);
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_next_steal_atp,
                                    l_class_next_steal_atp);
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_class_curr_steal_atp,
                                    l_class_next_steal_atp);
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Add_to_Next_Steal_Atp');

                 Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		      l_current_atp);
                 Print_Period_Qty('l_class_next_steal_atp.atp_period:atp_qty = ',
		      l_class_next_steal_atp);
              END IF;
              MSC_AATP_PROC.Add_to_Current_Atp(l_class_next_steal_atp, l_current_atp, l_return_status);
              IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Add_to_Current_Atp');
                 END IF;
              END IF;

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Add_to_Current_Atp');

                 Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		      l_current_atp);
                 Print_Period_Qty('l_class_next_steal_atp.atp_period:atp_qty = ',
		      l_class_next_steal_atp);
              END IF;
              MSC_AATP_PROC.Atp_Forward_Consume(l_current_atp.atp_period, p_atf_date, l_current_atp.atp_qty, l_return_status);
              IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Forward_Consume');
                 END IF;
              END IF;
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Atp_forward_consume');

                 Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		      l_current_atp);
              END IF;

              /*Call Atp_Remove_Negatives to remove negatives in case we have negatives left
              after forward consumption. we will not show these negatives in atp_inquiry for
              Allocated ATP with User Defined %.*/

              MSC_AATP_PROC.Atp_Remove_Negatives(l_current_atp.atp_qty, l_return_status);
              IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Remove_Negatives');
                 END IF;
              END IF;

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Atp_Remove_Negatives');
                 Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
	  		  l_current_atp);
              END IF;
	    END IF;
          ELSE
            -- method2, remove negatives from l_current_atp
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Method 2');
            END IF;
	    MSC_AATP_PROC.Atp_remove_negatives(l_current_atp.atp_qty, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_remove_negatives');
               END IF;
            END IF;

          END IF;
	ELSE --IF l_demand_class = l_lowest_priority_demand_class THEN
          IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                          'This is not the l_lowest_priority_demand_class');
          END IF;
          IF G_ATP_FW_CONSUME_METHOD = 2 OR
             (G_ATP_FW_CONSUME_METHOD = 1 AND l_fw_consume_tab(i) = 0) THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Inside IF G_ATP_FW_CONSUME_METHOD = 2 OR '||
                          '(G_ATP_FW_CONSUME_METHOD = 1 AND l_fw_consume_tab(i) = 0)');
		 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Adding Add_to_Next_Steal_Atp');

                 Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		      l_current_atp);
                 Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
		      l_next_steal_atp);
              END IF;

              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_atp, l_next_steal_atp);

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Add_to_Next_Steal_Atp');

                 Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		      l_current_atp);
                 Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
		      l_next_steal_atp);
              END IF;

	  END IF;

          IF i = l_class_tab.LAST OR (l_class_tab(i) <> l_class_tab(i+1))
             OR (G_ATP_FW_CONSUME_METHOD = 1 AND l_fw_consume_tab(i) = 3) THEN
            -- either we are at last record in l_demand_class_tab or
            -- we are at last record at current customer class level in l_demand_class_tab or
            -- this is the lowest priority customer at customer class level
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                   'We are at lowest priority customer at current customer class level ');
            END IF;

            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_partner_next_steal_atp);
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_curr_steal_atp,
                                  l_partner_next_steal_atp);
            IF G_ATP_FW_CONSUME_METHOD <> 1 OR l_fw_consume_tab(i) <> 3 THEN
               MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_next_steal_atp,
                                     l_class_next_steal_atp);
            END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
		 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Adding Add_to_Next_Steal_Atp');

                 Print_Period_Qty('l_class_next_steal_atp.atp_period:atp_qty = ',
		      l_class_next_steal_atp);
                 Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		      l_current_atp);
            END IF;

            IF i = l_class_tab.LAST OR trunc(l_demand_class_priority_tab(i), -3)<
               trunc(l_demand_class_priority_tab (i+1), -3) THEN

              -- next customer class is at higher priority then this cc
              -- add negatives from class_curr_steal to class_next_steal
              IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                             'next customer class is at higher priority then this cc');
              END IF;
              IF PG_DEBUG in ('Y', 'C') THEN
		 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Adding Add_to_Next_Steal_Atp');

                 Print_Period_Qty('l_class_next_steal_atp.atp_period:atp_qty = ',
		      l_class_next_steal_atp);
                 Print_Period_Qty('l_class_curr_steal_atp.atp_period:atp_qty = ',
		      l_class_curr_steal_atp);
              END IF;
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_class_curr_steal_atp,
                                    l_class_next_steal_atp);
              IF PG_DEBUG in ('Y', 'C') THEN
		 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Adding Add_to_Next_Steal_Atp');

                 Print_Period_Qty('l_class_next_steal_atp.atp_period:atp_qty = ',
		      l_class_next_steal_atp);
                 Print_Period_Qty('l_class_curr_steal_atp.atp_period:atp_qty = ',
		      l_class_curr_steal_atp);
              END IF;

            END IF;

          ELSE
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
               'We are not at lowest priority customer at current customer class level ');
            END IF;
            IF (l_partner_tab(i) <> l_partner_tab(i+1))
               OR (G_ATP_FW_CONSUME_METHOD = 1 AND l_fw_consume_tab(i) = 2) THEN
              -- either we are at last record at current customer level in l_demand_class_tab or
              -- this is the lowest priority site at this customer level
              IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                  'We are at lowest priority customer site at current customer level  ');
              END IF;
              IF PG_DEBUG in ('Y', 'C') THEN
		 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Adding Add_to_Next_Steal_Atp');

                 Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		      l_current_steal_atp);
                 Print_Period_Qty('l_partner_next_steal_atp.atp_period:atp_qty = ',
		      l_partner_next_steal_atp);
              END IF;
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);

              IF G_ATP_FW_CONSUME_METHOD <> 1 OR l_fw_consume_tab(i) <> 2 THEN
                 -- if forward consumption type is 2 we wont add the negatives in l_next_steal_atp
                 -- to l_partner_steal_atp. we will add the negatives to l_current_atp and do forward
                 -- consumption instead.
                 MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_partner_next_steal_atp);
              END IF;

              IF PG_DEBUG in ('Y', 'C') THEN
		 msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Adding Add_to_Next_Steal_Atp');

                 Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		      l_current_steal_atp);
                 Print_Period_Qty('l_partner_next_steal_atp.atp_period:atp_qty = ',
		      l_partner_next_steal_atp);
              END IF;
              IF trunc(l_demand_class_priority_tab(i), -2)<
                 trunc(l_demand_class_priority_tab (i+1), -2) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                             'next customer is at higher priority then this customer');
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Adding Add_to_Next_Steal_Atp');

                  Print_Period_Qty('l_partner_curr_steal_atp.atp_period:atp_qty = ',
		       l_partner_curr_steal_atp);
                  Print_Period_Qty('l_partner_next_steal_atp.atp_period:atp_qty = ',
		       l_partner_next_steal_atp);
                END IF;

                MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_curr_steal_atp,
                                      l_partner_next_steal_atp);

                IF PG_DEBUG in ('Y', 'C') THEN
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Adding Add_to_Next_Steal_Atp');

                  Print_Period_Qty('l_partner_curr_steal_atp.atp_period:atp_qty = ',
		       l_partner_curr_steal_atp);
                  Print_Period_Qty('l_partner_next_steal_atp.atp_period:atp_qty = ',
		       l_partner_next_steal_atp);
                END IF;

              END IF;


            ELSE
              -- we are not at last site under this customer
              IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                             'we are not at last site under this customer');
              END IF;
              IF (l_demand_class_priority_tab(i)<>
                  l_demand_class_priority_tab (i+1)) THEN
                -- next site under this customer is not at same priority as this site
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                         'next site under this customer is not at same priority as this site');
                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Adding Add_to_Next_Steal_Atp');

                  Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		       l_current_steal_atp);
                  Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
		       l_next_steal_atp);
                END IF;
                MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);
                IF PG_DEBUG in ('Y', 'C') THEN
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Adding Add_to_Next_Steal_Atp');

                  Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		       l_current_steal_atp);
                  Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
		       l_next_steal_atp);
                END IF;

              END IF;
            END IF;
          END IF;
	  IF G_ATP_FW_CONSUME_METHOD = 1 AND l_fw_consume_tab(i) <> 0 THEN
	    IF l_fw_consume_tab(i) = 2 THEN
              -- add negatives from l_next_steal_atp to l_current_atp and then do forward consumption
              IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_fw_consume_tab(i) = 2');
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Adding Add_to_Current_Atp');

                  Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		       l_current_atp);
                  Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
		       l_next_steal_atp);
              END IF;
	      MSC_AATP_PROC.Add_to_Current_Atp(l_next_steal_atp, l_current_atp, l_return_status);
              IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Add_to_Current_Atp');
                 END IF;
              END IF;
              IF PG_DEBUG in ('Y', 'C') THEN
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Adding Add_to_Current_Atp');

                  Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		       l_current_atp);
                  Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
		       l_next_steal_atp);
              END IF;
	    ELSIF l_fw_consume_tab(i) = 3 THEN
	      -- add negatives from l_partner_next_steal_atp to l_current_atp and then do forward consumption
              IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_fw_consume_tab(i) = 3');
              END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'before Adding Add_to_Current_Atp');

                  Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		       l_current_atp);
                  Print_Period_Qty('l_partner_next_steal_atp.atp_period:atp_qty = ',
		       l_partner_next_steal_atp);
                END IF;
	      MSC_AATP_PROC.Add_to_Current_Atp(l_partner_next_steal_atp, l_current_atp, l_return_status);
              IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Add_to_Current_Atp');
                 END IF;
              END IF;
              IF PG_DEBUG in ('Y', 'C') THEN
		  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Adding Add_to_Current_Atp');

                  Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		       l_current_atp);
                  Print_Period_Qty('l_partner_next_steal_atp.atp_period:atp_qty = ',
		       l_partner_next_steal_atp);
              END IF;
	    END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Before Atp_Forward_Consume for Method1');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
	  	        l_current_atp);
            END IF;
	    MSC_AATP_PROC.Atp_Forward_Consume(l_current_atp.atp_period, p_atf_date, l_current_atp.atp_qty, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Forward_Consume');
               END IF;
            END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'After Atp_Forward_Consume for Method1');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
	  	        l_current_atp);
            END IF;

            /*Call Atp_Remove_Negatives to remove negatives in case we have negatives left
            after forward consumption. we will not show these negatives in atp_inquiry for
            Allocated ATP with User Defined %.*/

            MSC_AATP_PROC.Atp_Remove_Negatives(l_current_atp.atp_qty, l_return_status);
            IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Remove_Negatives');
               END IF;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after Atp_Remove_Negatives');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
	  		l_current_atp);
            END IF;
	  END IF;
        END IF;

      END IF;

      IF G_ATP_FW_CONSUME_METHOD = 2 THEN
        -- method2, do accumulation and then calculate the adjusted cum
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Before Atp_Accumulate for Method2');
           Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		    l_current_atp);
        END IF;

        MSC_ATP_PROC.Atp_Accumulate(l_current_atp.atp_qty);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'After Atp_Accumulate for Method2');
           Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		    l_current_atp);
        END IF;

	MSC_AATP_PROC.Atp_Adjusted_Cum(l_current_atp, l_unallocated_atp, l_return_status);
        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Error in call to Atp_Forward_Consume');
           END IF;
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                    'l_current_atp after Atp_Adjusted_Cum for Method2');
           Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		    l_current_atp);
           msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' ||
                    'l_unallocated_atp after Atp_Adjusted_Cum for Method2');
	   mm := l_unallocated_atp.atp_qty.FIRST;
	   while mm is not null loop
		msc_sch_wb.atp_debug('l_unallocated_atp.atp_period:atp_qty = ' ||
		            l_current_atp.atp_period(mm) || ':' || l_unallocated_atp.atp_qty(mm));
		mm := l_unallocated_atp.atp_qty.NEXT(mm);
	   end loop;
        END IF;

      END IF;
      -- rajjain AATP Forward Consumption end
    ELSE --IF p_identifier <> -1 or (p_identifier = -1 and p_scenario_id <> -1) THEN
       /* rajjain 01/29/2003 Bug 2737596
          We only need to do b/w consumption, f/w consumption and accumulation in case the call is
          from MSC_AATP_PVT.VIEW_ALLOCATION for view total*/
      MSC_ATP_PROC.Atp_Consume(l_current_atp.atp_qty, l_current_atp.atp_qty.COUNT);
    END IF;

    -- 1665110
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'p_demand_class = '||p_demand_class);
    END IF;
    EXIT WHEN (l_demand_class = p_demand_class);
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'after the exit statement, so we did not exit');
    END IF;

  END LOOP;

  /* rajjain 01/29/2003 Bug 2737596
     We need not do accumulation in case the call is from VIEW_ALLOCATION
     for view total as we have already done this in atp_consume*/
  IF p_identifier <> -1 or (p_identifier = -1 and p_scenario_id <> -1) THEN
    IF G_ATP_FW_CONSUME_METHOD = 1 THEN
      -- we need to do accumulation only if forward consumption method is 1
      -- as we have the adjusted cum picture available if forward consumption method is 2
      MSC_ATP_PROC.Atp_Accumulate(l_current_atp.atp_qty);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'Right after the Atp_Accumulate');
         msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_current_atp.atp_period.count = '||
                    l_current_atp.atp_period.count);
         msc_sch_wb.atp_debug('Item_Alloc_Cum_Atp: ' || 'l_current_atp.atp_qty.count = '||
                    l_current_atp.atp_qty.count);
         Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
	    l_current_atp);
      END IF;
    END IF;
  END IF;

  x_atp_info := l_current_atp;
  --diag_atp: we have already calculate this date.
  /*-- get the infinite time fence date if it exists
  l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(p_instance_id,
             p_inventory_item_id,p_organization_id, p_plan_id);
  */

  IF l_infinite_time_fence_date IS NOT NULL THEN
      -- add one more entry to indicate infinite time fence date and quantity.
      x_atp_info.atp_qty.EXTEND;
      --x_atp_info.limit_qty.EXTEND;
      x_atp_info.atp_period.EXTEND;

      i := x_atp_info.atp_qty.COUNT;
      x_atp_info.atp_period(i) := l_infinite_time_fence_date;
      x_atp_info.atp_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;
      --x_atp_info.limit_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;


      IF NVL(p_insert_flag, 0) <> 0 THEN
        -- add one more entry to indicate infinite time fence date and quantity.

        x_atp_period.Cumulative_Quantity := x_atp_info.atp_qty;

        j := x_atp_period.Level.COUNT;
        MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, l_return_status);
        j := j + 1;
        IF j > 1 THEN
          x_atp_period.Period_End_Date(j-1) := l_infinite_time_fence_date -1;
	  -- dsting
          --x_atp_period.Identifier1(j) := x_atp_supply_demand.Identifier1(j-1);
          --x_atp_period.Identifier2(j) := x_atp_supply_demand.Identifier2(j-1);
          x_atp_period.Identifier1(j) := x_atp_period.Identifier1(j-1);
          x_atp_period.Identifier2(j) := x_atp_period.Identifier2(j-1);
        END IF;

        x_atp_period.Level(j) := p_level;
        x_atp_period.Identifier(j) := p_identifier;
        x_atp_period.Scenario_Id(j) := p_scenario_id;
        x_atp_period.Pegging_Id(j) := NULL;
        x_atp_period.End_Pegging_Id(j) := NULL;
        x_atp_period.Inventory_Item_Id(j) := p_inventory_item_id;
        x_atp_period.Request_Item_Id(j) := p_inventory_item_id;
        x_atp_period.Organization_id(j) := p_organization_id;
        x_atp_period.Period_Start_Date(j) := l_infinite_time_fence_date;
        x_atp_period.Total_Supply_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
        x_atp_period.Total_Demand_Quantity(j) := 0;
        -- time_phased_atp
        x_atp_period.Total_Bucketed_Demand_Quantity(j) := 0;
        x_atp_period.Period_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
        x_atp_period.Cumulative_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;

    END IF;
  END IF;
 --END IF;

END Item_Alloc_Cum_Atp;

PROCEDURE Res_Alloc_Cum_Atp(
	p_plan_id 	      IN 	NUMBER,
	p_level               IN 	NUMBER,
	p_identifier          IN 	NUMBER,
	p_scenario_id         IN 	NUMBER,
	p_department_id       IN 	NUMBER,
	p_resource_id         IN 	NUMBER,
	p_organization_id     IN 	NUMBER,
	p_instance_id         IN 	NUMBER,
	p_demand_class        IN 	VARCHAR2,
	p_request_date        IN 	DATE,
	p_insert_flag         IN 	NUMBER,
        p_max_capacity        IN        NUMBER,
        p_batchable_flag      IN        NUMBER,
        p_res_conversion_rate IN        NUMBER,
        p_res_uom_type	      IN        NUMBER,
	x_atp_info            OUT  	NoCopy MRP_ATP_PVT.ATP_Info,
	x_atp_period          OUT  	NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   OUT  	NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ)
IS
l_infinite_time_fence_date	DATE;
l_default_atp_rule_id           NUMBER;
l_calendar_exception_set_id     NUMBER;
l_level_id                      NUMBER;
l_priority			NUMBER := 1;
l_allocation_percent		NUMBER := 100;
l_inv_item_id			NUMBER;
l_null_num  			NUMBER := null;
l_steal_period_quantity		NUMBER;
l_demand_class			VARCHAR2(80);
l_uom_code			VARCHAR2(3);
l_null_char    			VARCHAR2(3) := null;
l_return_status			VARCHAR(1);
l_calendar_code                 VARCHAR2(14);
l_default_demand_class          VARCHAR2(34);
i				PLS_INTEGER;
mm				PLS_INTEGER;
ii                              PLS_INTEGER;
jj                              PLS_INTEGER;
j				PLS_INTEGER;
k				PLS_INTEGER;
l_demand_class_tab		MRP_ATP_PUB.char80_arr
                                   := MRP_ATP_PUB.char80_arr();
l_demand_class_priority_tab	MRP_ATP_PUB.number_arr
                                   := MRP_ATP_PUB.number_arr();
l_current_atp			MRP_ATP_PVT.ATP_Info;
l_next_steal_atp		MRP_ATP_PVT.ATP_Info;
l_null_steal_atp		MRP_ATP_PVT.ATP_Info;
l_current_steal_atp             MRP_ATP_PVT.ATP_Info;
l_temp_atp                      MRP_ATP_PVT.ATP_Info;
l_optimized_plan                PLS_INTEGER := 2;

-- 1680719
l_class_tab                     MRP_ATP_PUB.char30_arr
                                    := MRP_ATP_PUB.char30_arr();
l_partner_tab                   MRP_ATP_PUB.number_arr
                                    := MRP_ATP_PUB.number_arr();
l_class_next_steal_atp          MRP_ATP_PVT.ATP_Info;
l_partner_next_steal_atp        MRP_ATP_PVT.ATP_Info;
l_class_curr_steal_atp          MRP_ATP_PVT.ATP_Info;
l_partner_curr_steal_atp        MRP_ATP_PVT.ATP_Info;
l_pos1                          NUMBER;
l_pos2                          NUMBER;
delim     constant varchar2(1) := fnd_global.local_chr(13);
MSO_Batch_Flag                  VARCHAR2(1);
l_constraint_plan               NUMBER;
l_use_batching                  NUMBER;
--krajan 04/01/02 added for fstealing
l_org_code                      VARCHAR2(7);
l_plan_start_date               date;

-- dsting for s/d performance enh
l_temp_atp_supply_demand     	MRP_ATP_PUB.ATP_Supply_Demand_Typ;

-- ship_rec_cal
l_sysdate                       DATE := trunc(sysdate); --4135752
l_sys_next_date                 DATE; --bug3333114

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('******* Res_Alloc_Cum_Atp *******');
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'p_plan_id =' || p_plan_id);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'p_instance_id =' || p_instance_id);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'p_department_id =' || p_department_id);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'p_resource_id =' || p_resource_id);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'p_organization_id =' || p_organization_id);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'p_demand_class =' || p_demand_class);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'p_request_date =' || p_request_date );
  END IF;
MSO_Batch_flag := NVL(fnd_profile.value('MSO_BATCHABLE_FLAG'),'N');
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'MSO_Batch_flag := ' || MSO_Batch_flag);
  END IF;
  Begin
    SELECT DECODE(plans.plan_type, 4, 2,
             DECODE(daily_material_constraints, 1, 1,
               DECODE(daily_resource_constraints, 1, 1,
                 DECODE(weekly_material_constraints, 1, 1,
                   DECODE(weekly_resource_constraints, 1, 1,
                     DECODE(period_material_constraints, 1, 1,
                       DECODE(period_resource_constraints, 1, 1, 2)
                           )
                         )
                       )
                     )
                   )
                 ),
           DECODE(MSO_Batch_Flag, 'Y', DECODE(plans.plan_type, 4, 0,2,0,  -- filter out MPS plans
             DECODE(daily_material_constraints, 1, 1,
               DECODE(daily_resource_constraints, 1, 1,
                 DECODE(weekly_material_constraints, 1, 1,
                   DECODE(weekly_resource_constraints, 1, 1,
                     DECODE(period_material_constraints, 1, 1,
                       DECODE(period_resource_constraints, 1, 1, 2)
                           )
                         )
                       )
                     )
                   )
                 ), 0),
           trunc(plan_start_date)

    INTO   l_optimized_plan,l_constraint_plan, l_plan_start_date
    FROM   msc_designators desig,
           msc_plans plans
    WHERE  plans.plan_id = p_plan_id
    AND    desig.designator = plans.compile_designator
    AND    desig.sr_instance_id = plans.sr_instance_id
    AND    desig.organization_id = plans.organization_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
           l_optimized_plan := 2;
           l_constraint_plan := 0;
  END;
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Res_alloc_Cum_ATP: l_optimized_plan: ' || l_optimized_plan);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_constraint_plan  =' || l_constraint_plan);
  END IF;

  IF (MSO_Batch_Flag = 'Y')  and (l_constraint_plan = 1) and (p_batchable_flag = 1) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Do Batching');
        END IF;
        l_use_batching := 1;
  ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'No Batching');
        END IF;
        l_use_batching := 0;
  END IF;


  -- find all the demand classes that we need to take care: all the demand
  -- classes that have higher priority  + this requested demand class.

  -- Logic
  -- Step 1:
  -- 	FOR each demand class DCi, we need to
  --  	1. get the net daily availability
  --  	2. do backward consumption
  --  	3. do backward consumption if DC1 to DC(i-1) has any negative bucket
  -- 	END LOOP
  -- Step 2:
  --    do accumulation for the requested demand class

  -- select the priority  and allocation_percent for that item/demand class.
  -- if no data found, check if this item has a valid allocation rule.
  -- otherwise return error.

 -- If request is from view allocation for total ATP, assign
 -- l_priority = -1 and l_allocation_percent = NULL
 IF p_scenario_id <> -1 THEN
    MSC_AATP_PVT.Get_DC_Info(p_instance_id, null, p_organization_id,
        p_department_id, p_resource_id, p_demand_class,
        p_request_date, l_level_id, l_priority, l_allocation_percent, l_return_status);

    IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Error retrieving Priority and Demand Class');
        END IF;
    END IF;
 ELSE
     l_priority := -1;
     l_allocation_percent := NULL;
 END IF;

  -- find the demand classes that have priority  higher (small number) than
  -- the requested demand class

-- IF l_allocation_percent <> 0.0 THEN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_allocation_percent = '||l_allocation_percent);
  END IF;
  -- We don't need to select all demand classes in case this procdure is
  -- called from MSC_AATP_PVT.VIEW_ALLOCATION as we don't need to take care
  -- of any existing stealing.
 IF p_identifier <> -1 THEN

 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'before select the high priority demand class');
 END IF;

  -- bug 1680719
 --bug3948494 Do not select Higher priority DC if the requested DC
 --is at highest priority, we donot honor for forward consumption method here.
  IF l_level_id = -1 AND l_priority <> 1 THEN


    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT demand_class, priority
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab
    FROM   msc_resource_hierarchy_mv
    WHERE  department_id = p_department_id
    AND    resource_id = p_resource_id
    AND	   organization_id = p_organization_id
    AND    sr_instance_id = p_instance_id
    AND    p_request_date BETWEEN effective_date AND disable_date
    AND    priority  <= l_priority  -- 1665110, add '='
    AND    level_id = l_level_id
    ORDER BY priority asc, allocation_percent desc;

  ELSIF l_level_id = 1 THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT demand_class, priority
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab
    FROM   msc_resource_hierarchy_mv
    WHERE  department_id = p_department_id
    AND    resource_id = p_resource_id
    AND    organization_id = p_organization_id
    AND    sr_instance_id = p_instance_id
    AND    p_request_date BETWEEN effective_date AND disable_date
    AND    priority  <= l_priority  -- 1665110, add '='
    AND    level_id = l_level_id
    ORDER BY priority asc, class;

  ELSIF l_level_id = 2 THEN


    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT mv1.demand_class, mv1.priority, mv1.class, mv1.partner_id
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab,
                      l_class_tab, l_partner_tab
    FROM   msc_resource_hierarchy_mv mv1
    WHERE  mv1.department_id = p_department_id
    AND    mv1.resource_id = p_resource_id
    AND    mv1.organization_id = p_organization_id
    AND    mv1.sr_instance_id = p_instance_id
    AND    p_request_date BETWEEN mv1.effective_date AND mv1.disable_date
    --AND    mv1.priority  <= l_priority -- 1665110, add '='
    AND    mv1.level_id = l_level_id
    AND trunc(mv1.priority, -3) <= trunc(l_priority, -3)
      ORDER BY trunc(mv1.priority, -3), mv1.class ,
               trunc(mv1.priority, -2), mv1.partner_id;

  ELSIF l_level_id = 3 THEN

    -- bug 1680719
    -- we need to select the class, partner_id, partner_site_id

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT mv1.demand_class, mv1.priority, mv1.class, mv1.partner_id
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab,
                      l_class_tab, l_partner_tab
    FROM   msc_resource_hierarchy_mv mv1
    WHERE  mv1.department_id = p_department_id
    AND    mv1.resource_id = p_resource_id
    AND    mv1.organization_id = p_organization_id
    AND    mv1.sr_instance_id = p_instance_id
    AND    p_request_date BETWEEN mv1.effective_date AND mv1.disable_date
    --AND    mv1.priority  <= l_priority -- 1665110, add '='
    AND    mv1.level_id = l_level_id
    AND trunc(mv1.priority, -3) <= trunc(l_priority, -3)
      ORDER BY trunc(mv1.priority, -3), mv1.class ,
               trunc(mv1.priority, -2), mv1.partner_id,
               mv1.priority, mv1.partner_site_id;
  END IF;

 -- Bug 1807827, need to add the requested demand class in case call is from
 -- View_Allocation, else l_demand_class_tab remains empty.
 END IF;
 --ELSE           -- p_scenario_id = -1 for View_Allocation
 IF l_demand_class_tab.count = 0 THEN
   --/* 1665110
     -- add the request demand class into the list
     l_demand_class_tab.Extend;
     l_demand_class_priority_tab.Extend;
     i := l_demand_class_tab.COUNT;
     l_demand_class_priority_tab(i) := l_priority;
     l_demand_class_tab(i) := p_demand_class;

     -- 1680719
     IF l_level_id in (2, 3) THEN
         l_class_tab.Extend;
         l_partner_tab.Extend;
         l_pos1 := instr(p_demand_class,delim,1,1);
         l_pos2 := instr(p_demand_class,delim,1,2);
         l_class_tab(i) := substr(p_demand_class,1,l_pos1-1);
         IF l_pos2 = 0 THEN
           l_partner_tab(i) := substr(p_demand_class,l_pos1+1);
         ELSE
           l_partner_tab(i) := substr(p_demand_class,l_pos1+1,l_pos2-l_pos1-1) ;
         END IF;
     END IF;
 END IF;
--1665110 */
  mm := l_demand_class_tab.FIRST;

  WHILE mm is not null LOOP
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_demand_class_tab and priority = '||
        l_demand_class_tab(mm) ||' : '|| l_demand_class_priority_tab(mm));
     END IF;

     IF l_level_id in (2,3) THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_class_tab and partner = '||
        l_class_tab(mm) ||' : '||l_partner_tab(mm));
       END IF;
     END IF;

     mm := l_demand_class_tab.Next(mm);
  END LOOP;

  l_uom_code := NVL(fnd_profile.value('MSC:HOUR_UOM_CODE'),
                    fnd_profile.value('BOM:HOUR_UOM_CODE'));

  -- for performance reason, we need to get the following info and
  -- store in variables instead of joining it

  /* Modularize Item and Org Info */
  -- changed call
  MSC_ATP_PROC.get_global_org_info(p_instance_id, p_organization_id);
  l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
  l_calendar_code := MSC_ATP_PVT.G_ORG_INFO_REC.cal_code;
  l_calendar_exception_set_id := MSC_ATP_PVT.G_ORG_INFO_REC.cal_exception_set_id;
  l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
  l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
  /* Modularize Item and Org Info */
  --bug3333114 start
  l_sys_next_date := MSC_CALENDAR.NEXT_WORK_DAY (
                                        l_calendar_code,
                                        p_instance_id,
                                        TRUNC(sysdate));

  IF PG_DEBUG in ('Y', 'C') THEN
  msc_sch_wb.atp_debug('Sys next Date : '||to_char(l_sys_next_date, 'DD-MON-YYYY'));
  END IF;

  IF (l_sys_next_date is NULL) THEN
      msc_sch_wb.atp_debug('Sys Next Date is null');
      MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  --bug3333114 end

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_default_atp_rule_id='|| l_default_atp_rule_id);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_calendar_code='||l_calendar_code);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_calendar_exception_set_id'|| l_calendar_exception_set_id);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_default_demand_class'|| l_default_demand_class);
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_org_code'|| l_org_code);
  END IF;

  FOR i in 1..l_demand_class_tab.COUNT LOOP
          l_demand_class := l_demand_class_tab(i);
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'in i loop, i = '||i);
             msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_demand_class = '||l_demand_class);
          END IF;
   -- get the daily net availability for DCi
   IF (NVL(p_insert_flag, 0) = 0  OR l_demand_class <> p_demand_class) THEN
       -- we don't want details

     IF (l_use_batching = 1) THEN
       IF (l_optimized_plan = 1) THEN -- Constrained Plan Bug 2809639
          IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Constrained Plan Batching');
          END IF;
       	  SELECT 	SD_DATE,
       			SUM(SD_QTY)
          BULK COLLECT INTO
                	l_current_atp.atp_period,
                	l_current_atp.atp_qty
          FROM (
          SELECT  -- C.CALENDAR_DATE SD_DATE, -- 2859130
                  -- Bug 3348095
                  -- For ATP created records use end_date otherwise start_date
                  GREATEST(DECODE(REQ.record_source, 2, TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                           TRUNC(REQ.START_DATE)),l_sys_next_date) SD_DATE, --bug3333114
                -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                         DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) *
                   -- For ATP created records use resource_hours
                   -- End Bug 3348095
                ---resource batching
                DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME) *
                       NVL(MUC.CONVERSION_RATE, 1) * NVL(S.NEW_ORDER_QUANTITY, FIRM_QUANTITY) *

                        /*New*/
		DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --bug 2424357
                              1, DECODE(S.DEMAND_CLASS, null, null,
                                    DECODE(l_demand_class, '-1',
                                        MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  s.inventory_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  NULL))),
		       l_demand_class, 1,
                       --bug 4089293: If l_demand_class is not null and demand class is populated
                       -- on  supplies record then 0 should be allocated.
                       Decode (S.Demand_Class, NULL,
		       MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(
                         -- 2859130 C.CALENDAR_DATE,
                         -- Bug 3348095
                         -- For ATP created records use end_date
                         -- otherwise start_date
                         DECODE(REQ.record_source, 2,
                           TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                             TRUNC(REQ.START_DATE)),
                         --trunc(req.start_date),
                         -- End Bug 3348095
                         REQ.ASSEMBLY_ITEM_ID,
			 p_organization_id,
                         p_instance_id,
                         p_department_id,
			 p_resource_id,
                         DECODE(G_HIERARCHY_PROFILE,
                                --2424357
                                1, DECODE(S.DEMAND_CLASS, null, null,
                                       DECODE(l_demand_class, -1,
                                          MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                2, DECODE(S.CUSTOMER_ID, NULL, l_demand_class,
                                          0, l_demand_class,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  l_inv_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  NULL))),
                         l_demand_class), 0)) SD_QTY
                        /*New*/
          FROM    MSC_DEPARTMENT_RESOURCES DR,
                  MSC_SUPPLIES S,
                  MSC_RESOURCE_REQUIREMENTS REQ,
                  -- 2859130 MSC_CALENDAR_DATES C,
                  MSC_SYSTEM_ITEMS I,
                  MSC_UOM_CONVERSIONS  MUC
          WHERE   DR.PLAN_ID = p_plan_id
          AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_department_id
          AND     DR.RESOURCE_ID = p_resource_id
          AND     DR.SR_INSTANCE_ID = p_instance_id
          AND     DR.ORGANIZATION_ID = p_organization_id -- for performance
          AND     REQ.PLAN_ID = DR.PLAN_ID
          AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
          AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
          AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
          AND     NVL(REQ.PARENT_ID, 1)  = 1  -- Bug 2809639
          AND     S.PLAN_ID = DR.PLAN_ID
          AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
          AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3948494
                  -- Exclude Cancelled Supplies 2460645
          AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
          AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
          AND     I.PLAN_ID = S.PLAN_ID
          AND     I.ORGANIZATION_ID = S.ORGANIZATION_ID
          AND     I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
          -- Begin CTO Option Dependent Resources ODR
          AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
          -- End CTO Option Dependent Resources
          AND     DECODE(p_res_uom_type, 1, I.WEIGHT_UOM, 2 , I.VOLUME_UOM) = MUC.UOM_CODE (+)
          AND     MUC.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
          AND     MUC.INVENTORY_ITEM_ID (+)= 0
          -- 2859130
          --AND     C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
          --AND     C.CALENDAR_CODE = l_calendar_code
          --AND     C.EXCEPTION_SET_ID = l_calendar_exception_set_id
          --AND     C.CALENDAR_DATE = TRUNC(REQ.START_DATE) -- Bug 2809639
          --AND     C.SEQ_NUM IS NOT NULL
          ---bug 2341075: get data from plan_satrt date instead of sysdate
          --AND     C.CALENDAR_DATE >= trunc(sysdate)
          AND     trunc(REQ.START_DATE) >= l_plan_start_date --4135752
          UNION ALL
          SELECT  trunc(MNRA.SHIFT_DATE) SD_DATE, --4135752
                  MNRA.CAPACITY_UNITS * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,MNRA.to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600) *
                                              NVL((MRHM.allocation_percent/100), 1)
/*
                                              NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                				     p_instance_id,
                			             null,
                                                     p_organization_id,
                                                     p_department_id,
                                                     p_resource_id,
                                                     l_demand_class,
                                                     SHIFT_DATE),1) SD_QTY
*/
          FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                  msc_resource_hierarchy_mv MRHM
          WHERE   MNRA.PLAN_ID = p_plan_id
          AND     NVL(MNRA.PARENT_ID, -2) <> -1
          AND     MNRA.SR_INSTANCE_ID = p_instance_id
          AND     MNRA.RESOURCE_ID = p_resource_id
          AND     MNRA.DEPARTMENT_ID = p_department_id
          ---bug 2341075; get data from plan_start date
          --AND     SHIFT_DATE >= trunc(sysdate)
          --bug 4232627: select only those records which are after plan start date
          AND     MNRA.SHIFT_DATE >= l_plan_start_date
          --bug 4089293
          AND     MNRA.organization_id = p_organization_id
          AND     MRHM.department_id (+) = MNRA.department_id
          AND     MRHM.resource_id  (+)= MNRA.resource_id
          AND     MRHM.organization_id (+) = MNRA.organization_id
          AND     MRHM.sr_instance_id  (+)= MNRA.sr_instance_id
          --AND     MRHM.level_id (+) = -1 --4365873
          AND     decode(MRHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
          --bug 4232627:
          --AND     MNRA.shift_date >=  GREATEST(l_plan_start_date,MRHM.effective_date (+))
          AND     trunc(MNRA.shift_date) >=  trunc(MRHM.effective_date (+))
          AND     trunc(MNRA.shift_date) <=  trunc(MRHM.disable_date (+))
          AND     MRHM.demand_class (+)= l_demand_class
          )
          GROUP BY SD_DATE
          ORDER BY SD_DATE;--4698199
       ELSE  -- now Other plans Bug 2809639
          IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Other Plans Batching');
          END IF;
       	  SELECT 	SD_DATE,
       			SUM(SD_QTY)
          BULK COLLECT INTO
                	l_current_atp.atp_period,
                	l_current_atp.atp_qty
          FROM (
          SELECT  GREATEST(C.CALENDAR_DATE,l_sys_next_date) SD_DATE, --bug3333114
                -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                          -- Bug 3348095
                          DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) *
                          -- For ATP created records use resource_hours
                          -- End Bug 3348095
                ---resource batching
                DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME) *
                       NVL(MUC.CONVERSION_RATE, 1) * NVL(S.NEW_ORDER_QUANTITY, FIRM_QUANTITY) *

                        /*New*/
		DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --bug 2424357
                              1, DECODE(S.DEMAND_CLASS, null, null,
                                    DECODE(l_demand_class, '-1',
                                        MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  s.inventory_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  NULL))),
		       l_demand_class, 1,
                       --bug 4156016: If l_demand_class is not null and demand class is populated
                       -- on  supplies record then 0 should be allocated.
                       Decode (S.Demand_Class, NULL,
		       MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(C.CALENDAR_DATE,
                         REQ.ASSEMBLY_ITEM_ID,
			 p_organization_id,
                         p_instance_id,
                         p_department_id,
			 p_resource_id,
                         DECODE(G_HIERARCHY_PROFILE,
                                --2424357
                                1, DECODE(S.DEMAND_CLASS, null, null,
                                       DECODE(l_demand_class, -1,
                                          MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                2, DECODE(S.CUSTOMER_ID, NULL, l_demand_class,
                                          0, l_demand_class,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  l_inv_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  NULL))),
                         l_demand_class), 0)) SD_QTY
                        /*New*/
          FROM    MSC_DEPARTMENT_RESOURCES DR,
                  MSC_SUPPLIES S,
                  MSC_RESOURCE_REQUIREMENTS REQ,
                  MSC_CALENDAR_DATES C,
                  MSC_SYSTEM_ITEMS I,
                  MSC_UOM_CONVERSIONS  MUC
          WHERE   DR.PLAN_ID = p_plan_id
          AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_department_id
          AND     DR.RESOURCE_ID = p_resource_id
          AND     DR.SR_INSTANCE_ID = p_instance_id
          AND     DR.ORGANIZATION_ID = p_organization_id -- for performance
          AND     REQ.PLAN_ID = DR.PLAN_ID
          AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
          AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
          AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
          AND     NVL(REQ.PARENT_ID, l_optimized_plan) = l_optimized_plan
          AND     S.PLAN_ID = DR.PLAN_ID
          AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
          AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3948494
                  -- Exclude Cancelled Supplies 2460645
          AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
          AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
          AND     I.PLAN_ID = S.PLAN_ID
          AND     I.ORGANIZATION_ID = S.ORGANIZATION_ID
          AND     I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
          -- Begin CTO Option Dependent Resources ODR
          AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
          -- End CTO Option Dependent Resources
          AND     DECODE(p_res_uom_type, 1, I.WEIGHT_UOM, 2 , I.VOLUME_UOM) = MUC.UOM_CODE (+)
          AND     MUC.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
          AND     MUC.INVENTORY_ITEM_ID (+)= 0
          AND     C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
          AND     C.CALENDAR_CODE = l_calendar_code
          AND     C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                  -- Bug 3348095
                  -- Ensure that the ATP created resource Reqs
                  -- do not get double counted.
         AND      C.CALENDAR_DATE BETWEEN DECODE(REQ.record_source, 2,
                       TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)), TRUNC(REQ.START_DATE))
                   AND TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                  -- End Bug 3348095
          AND     C.SEQ_NUM IS NOT NULL
          ---bug 2341075: get data from plan_satrt date instead of sysdate
          --AND     C.CALENDAR_DATE >= trunc(sysdate)
          AND     C.CALENDAR_DATE >= l_plan_start_date
          UNION ALL
          SELECT  trunc(MNRA.SHIFT_DATE) SD_DATE, --4135752
                  MNRA.CAPACITY_UNITS * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,MNRA.to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600) *
                                              NVL((MRHM.allocation_percent/100), 1)
/*
                                              NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                				     p_instance_id,
                			             null,
                                                     p_organization_id,
                                                     p_department_id,
                                                     p_resource_id,
                                                     l_demand_class,
                                                     SHIFT_DATE),1) SD_QTY
*/
          FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                  msc_resource_hierarchy_mv MRHM
          WHERE   MNRA.PLAN_ID = p_plan_id
          AND     NVL(MNRA.PARENT_ID, -2) <> -1
          AND     MNRA.SR_INSTANCE_ID = p_instance_id
          AND     MNRA.RESOURCE_ID = p_resource_id
          AND     MNRA.DEPARTMENT_ID = p_department_id
          ---bug 2341075; get data from plan_start date
          --AND     SHIFT_DATE >= trunc(sysdate)
          --bug 4232627: select only those records which are after plan start date
          AND     MNRA.SHIFT_DATE >= l_plan_start_date
          --bug 4156016
          AND     MNRA.organization_id = p_organization_id
          AND     MRHM.department_id (+) = MNRA.department_id
          AND     MRHM.resource_id  (+)= MNRA.resource_id
          AND     MRHM.organization_id (+) = MNRA.organization_id
          AND     MRHM.sr_instance_id  (+)= MNRA.sr_instance_id
          --AND     MRHM.level_id (+) = -1 --4365873
          AND     decode(MRHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
          --bug 4232627:
          AND     trunc(MNRA.shift_date) >=  trunc(GREATEST(l_plan_start_date,MRHM.effective_date (+))) --4135752
          AND     trunc(MNRA.shift_date) <=  trunc(MRHM.disable_date (+))--4135752
          AND     MRHM.demand_class (+)= l_demand_class
          )
          GROUP BY SD_DATE
          ORDER BY SD_DATE;--4698199
       END IF; -- l_optimized_plan = 1 Bug 2809639
     ELSE --- IF l_use_batching =1 THEN

       IF (l_optimized_plan = 1) THEN -- Constrained Plan Bug 2809639
          IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Constrained Plan No Batching');
          END IF;
       	  SELECT 	SD_DATE,
       			SUM(SD_QTY)
          BULK COLLECT INTO
                	l_current_atp.atp_period,
                	l_current_atp.atp_qty
          FROM (
          SELECT  -- C.CALENDAR_DATE SD_DATE, -- 2859130
                  -- Bug 3348095
                  -- For ATP created records use end_date otherwise start_date
                 GREATEST(DECODE(REQ.record_source, 2, TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                           TRUNC(REQ.START_DATE)),l_sys_next_date) SD_DATE, --bug3333114
                -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                      -- Bug 3348095
                        DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) *
                      -- For ATP created records use resource_hours
                      -- End Bug 3348095
                        /*New*/
		DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --2424357
                              1, DECODE(S.DEMAND_CLASS, null, null,
                                    DECODE(l_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
  				                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  S.DEMAND_CLASS),S.DEMAND_CLASS)),
                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  s.inventory_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  NULL))),
		       l_demand_class, 1,
                       --bug 4156016: If l_demand_class is not null and demand class is populated
                       -- on  supplies record then 0 should be allocated.
                       Decode (S.Demand_Class, NULL,
		       MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(
                         -- 2859130 C.CALENDAR_DATE,
                         -- Bug 3348095
                         -- For ATP created records use end_date
                         -- otherwise start_date
                         DECODE(REQ.record_source, 2,
                           TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                             TRUNC(REQ.START_DATE)),
                         --trunc(req.start_date),
                         -- End Bug 3348095
                         REQ.ASSEMBLY_ITEM_ID,
			 p_organization_id,
                         p_instance_id,
                         p_department_id,
			 p_resource_id,
                         DECODE(G_HIERARCHY_PROFILE,
                                --2424357
                                1, DECODE(S.DEMAND_CLASS, null, null,
                                       DECODE(l_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                2, DECODE(S.CUSTOMER_ID, NULL, l_demand_class,
                                          0, l_demand_class,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  l_inv_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  NULL))),
                         l_demand_class), 0)) SD_QTY
                        /*New*/
          FROM    MSC_DEPARTMENT_RESOURCES DR,
                  MSC_SUPPLIES S,
                  MSC_SYSTEM_ITEMS I,   -- CTO ODR
                  MSC_RESOURCE_REQUIREMENTS REQ
                  -- 2859130 MSC_CALENDAR_DATES C
          WHERE   DR.PLAN_ID = p_plan_id
          AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_department_id
          AND     DR.RESOURCE_ID = p_resource_id
          AND     DR.SR_INSTANCE_ID = p_instance_id
          AND     DR.ORGANIZATION_ID = p_organization_id -- for performance
          AND     REQ.PLAN_ID = DR.PLAN_ID
          AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
          AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
          AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
          AND     NVL(REQ.PARENT_ID, 1)  = 1 -- Bug 2809639
          -- CTO Option Dependent Resources ODR
          AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
          AND     I.PLAN_ID = REQ.PLAN_ID
          AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
          AND     I.INVENTORY_ITEM_ID = REQ.ASSEMBLY_ITEM_ID
          AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
                -- bom_item_type not model and option_class always committed.
                     AND   (I.atp_flag <> 'N')
                -- atp_flag is 'Y' then committed.
                     OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
               -- if record created by ATP then committed.
          -- End CTO Option Dependent Resources
          AND     S.PLAN_ID = DR.PLAN_ID
          AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
          AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3948494
          -- Exclude Cancelled Supplies 2460645
          AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645

          -- 2859130
          -- AND     C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
          -- AND     C.CALENDAR_CODE = l_calendar_code
          -- AND     C.EXCEPTION_SET_ID = l_calendar_exception_set_id
          -- AND     C.CALENDAR_DATE = TRUNC(REQ.START_DATE) -- Bug 2809639
          -- AND     C.SEQ_NUM IS NOT NULL
          ---bug 2341075
          --AND     C.CALENDAR_DATE >= trunc(sysdate)
          AND     trunc(REQ.START_DATE) >= l_plan_start_date --4135752
          UNION ALL
          SELECT  trunc(MNRA.SHIFT_DATE) SD_DATE, --4135752
                  MNRA.CAPACITY_UNITS * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,MNRA.to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600) *
                                              NVL((MRHM.allocation_percent/100), 1)
                                                    /*
                                                     NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                				     p_instance_id,
                			             null,
                                                     p_organization_id,
                                                     p_department_id,
                                                     p_resource_id,
                                                     l_demand_class,
                                                     SHIFT_DATE),1) SD_QTY */
          FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                  msc_resource_hierarchy_mv MRHM
          WHERE   MNRA.PLAN_ID = p_plan_id
          AND     NVL(MNRA.PARENT_ID, -2) <> -1
          AND     MNRA.SR_INSTANCE_ID = p_instance_id
          AND     MNRA.RESOURCE_ID = p_resource_id
          AND     MNRA.DEPARTMENT_ID = p_department_id
          --bug 2341075
          --AND     SHIFT_DATE >= trunc(sysdate)
          --bug 4232627: select only those records which are after plan start date
          AND     MNRA.SHIFT_DATE >= l_plan_start_date
          --bug 4156016
          AND     MNRA.organization_id = p_organization_id
          AND     MRHM.department_id (+) = MNRA.department_id
          AND     MRHM.resource_id  (+)= MNRA.resource_id
          AND     MRHM.organization_id (+) = MNRA.organization_id
          AND     MRHM.sr_instance_id  (+)= MNRA.sr_instance_id
          --AND     MRHM.level_id (+) = -1 --4365873
          AND     decode(MRHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
           --bug 4232627:
          AND     trunc(MNRA.shift_date) >=  trunc(GREATEST(l_plan_start_date,MRHM.effective_date (+))) --4135752
          AND     trunc(MNRA.shift_date) <=  trunc(MRHM.disable_date (+)) --4135752
          AND     MRHM.demand_class (+)= l_demand_class
          )
          GROUP BY SD_DATE
          ORDER BY SD_DATE;--4698199
       ELSE  -- now Other plans Bug 2809639
          IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Other Plans No Batching');
          END IF;
       	  SELECT 	SD_DATE,
       			SUM(SD_QTY)
          BULK COLLECT INTO
                	l_current_atp.atp_period,
                	l_current_atp.atp_qty
          FROM (
          SELECT GREATEST(C.CALENDAR_DATE,l_sys_next_date) SD_DATE,--bug3333114
                -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                          -- Bug 3348095
                          DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) *
                          -- For ATP created records use resource_hours
                          -- End Bug 3348095
                        /*New*/
		DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --2424357
                              1, DECODE(S.DEMAND_CLASS, null, null,
                                    DECODE(l_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
  				                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  S.DEMAND_CLASS),S.DEMAND_CLASS)),
                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  s.inventory_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  NULL))),
		       l_demand_class, 1,
                       --bug 4156016: If l_demand_class is not null and demand class is populated
                       -- on  supplies record then 0 should be allocated.
                       Decode (S.Demand_Class, NULL,
		       MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(C.CALENDAR_DATE,
                         REQ.ASSEMBLY_ITEM_ID,
			 p_organization_id,
                         p_instance_id,
                         p_department_id,
			 p_resource_id,
                         DECODE(G_HIERARCHY_PROFILE,
                                --2424357
                                1, DECODE(S.DEMAND_CLASS, null, null,
                                       DECODE(l_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                2, DECODE(S.CUSTOMER_ID, NULL, l_demand_class,
                                          0, l_demand_class,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  l_inv_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  NULL))),
                         l_demand_class), 0)) SD_QTY
                        /*New*/
          FROM    MSC_DEPARTMENT_RESOURCES DR,
                  MSC_SUPPLIES S,
                  MSC_SYSTEM_ITEMS I,   -- CTO ODR
                  MSC_RESOURCE_REQUIREMENTS REQ,
                  MSC_CALENDAR_DATES C
          WHERE   DR.PLAN_ID = p_plan_id
          AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_department_id
          AND     DR.RESOURCE_ID = p_resource_id
          AND     DR.SR_INSTANCE_ID = p_instance_id
          AND     DR.ORGANIZATION_ID = p_organization_id -- for performance
          AND     REQ.PLAN_ID = DR.PLAN_ID
          AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
          AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
          AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
          AND     NVL(REQ.PARENT_ID, l_optimized_plan) = l_optimized_plan
          -- CTO Option Dependent Resources ODR
          AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
          AND     I.PLAN_ID = REQ.PLAN_ID
          AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
          AND     I.INVENTORY_ITEM_ID = REQ.ASSEMBLY_ITEM_ID
          AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
                -- bom_item_type not model and option_class always committed.
                     AND   (I.atp_flag <> 'N')
                -- atp_flag is 'Y' then committed.
                     OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
               -- if record created by ATP then committed.
          -- End CTO Option Dependent Resources
          AND     S.PLAN_ID = DR.PLAN_ID
          AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
          AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3948494
          -- Exclude Cancelled Supplies 2460645
          AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645

          AND     C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
          AND     C.CALENDAR_CODE = l_calendar_code
          AND     C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                  -- Bug 3348095
                  -- Ensure that the ATP created resource Reqs
                  -- do not get double counted.
         AND      C.CALENDAR_DATE BETWEEN DECODE(REQ.record_source, 2,
                       TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)), TRUNC(REQ.START_DATE))
                   AND TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                  -- End Bug 3348095
          AND     C.SEQ_NUM IS NOT NULL
          ---bug 2341075
          --AND     C.CALENDAR_DATE >= trunc(sysdate)
          AND     C.CALENDAR_DATE >= l_plan_start_date
          UNION ALL
          SELECT  trunc(MNRA.SHIFT_DATE) SD_DATE, --4135752
                  MNRA.CAPACITY_UNITS * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,MNRA.to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600) *
                                              NVL((MRHM.allocation_percent/100), 1)
/*
                                              NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                				     p_instance_id,
                			             null,
                                                     p_organization_id,
                                                     p_department_id,
                                                     p_resource_id,
                                                     l_demand_class,
                                                     SHIFT_DATE),1) SD_QTY
*/
          FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                  msc_resource_hierarchy_mv MRHM
          WHERE   MNRA.PLAN_ID = p_plan_id
          AND     NVL(MNRA.PARENT_ID, -2) <> -1
          AND     MNRA.SR_INSTANCE_ID = p_instance_id
          AND     MNRA.RESOURCE_ID = p_resource_id
          AND     MNRA.DEPARTMENT_ID = p_department_id
          ---bug 2341075; get data from plan_start date
          --AND     SHIFT_DATE >= trunc(sysdate)
          --bug 4232627: select only those records which are after plan start date
          AND     MNRA.SHIFT_DATE >= l_plan_start_date
          --bug 4156016
          AND     MNRA.organization_id = p_organization_id
          AND     MRHM.department_id (+) = MNRA.department_id
          AND     MRHM.resource_id  (+)= MNRA.resource_id
          AND     MRHM.organization_id (+) = MNRA.organization_id
          AND     MRHM.sr_instance_id  (+)= MNRA.sr_instance_id
          --AND     MRHM.level_id (+) = -1 --4365873
          AND     decode(MRHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
          --bug 4232627:
          AND     trunc(MNRA.shift_date) >=  trunc(GREATEST(l_plan_start_date,MRHM.effective_date (+))) --4135752
          AND     trunc(MNRA.shift_date) <=  trunc(MRHM.disable_date (+)) --4135752
          AND     MRHM.demand_class (+)= l_demand_class
          )
          GROUP BY SD_DATE
          ORDER BY SD_DATE;--4698199
       END IF; -- l_optimized_plan = 1 Bug 2809639
      -- bug 1657855,  remove support for min alloc
      --l_current_atp.limit_qty := l_current_atp.atp_qty;
     END IF;
   ELSE
        -- IF (NVL(p_insert_flag, 0) <> 0  AND l_demand_class = p_demand_class)
        -- OR p_scenario_id = -1 - we want details

      -- 2792336
     MSC_ATP_DB_UTILS.Clear_SD_Details_Temp();

     IF (l_use_batching = 1) THEN
       IF (l_optimized_plan = 1) THEN -- Constrained Plan Bug 2809639
         IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Constrained Plan Batching Details');
         END IF;
	 INSERT INTO msc_atp_sd_details_temp (
		ATP_Level,
		Order_line_id,
		Scenario_Id,
		Inventory_Item_Id,
		Request_Item_Id,
		Organization_Id,
		Department_Id,
		Resource_Id,
		Supplier_Id,
		Supplier_Site_Id,
		From_Organization_Id,
		From_Location_Id,
		To_Organization_Id,
		To_Location_Id,
		Ship_Method,
		UOM_code,
		Supply_Demand_Type,
		Supply_Demand_Source_Type,
		Supply_Demand_Source_Type_Name,
		Identifier1,
		Identifier2,
		Identifier3,
		Identifier4,
		Supply_Demand_Quantity,
		Supply_Demand_Date,
		Disposition_Type,
		Disposition_Name,
		Pegging_Id,
		End_Pegging_Id,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		Unallocated_Quantity
	)

	(SELECT
    	 	p_level col1,
		p_identifier col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
		p_organization_id col6,
                p_department_id col7,
                p_resource_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		l_uom_code col16,
		1 col17, -- demand
		S.ORDER_TYPE col18,
                l_null_char col19,
		REQ.SR_INSTANCE_ID col20,
                l_null_num col21,
		REQ.TRANSACTION_ID col22,
		l_null_num col23,
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                         -- Bug 3348095
                         DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) *
                         -- For ATP created records use resource_hours
                         -- End Bug 3348095
                 ---- resource batching
                DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME) *
                NVL(MUC.CONVERSION_RATE, 1) * NVL(S.NEW_ORDER_QUANTITY,S.FIRM_QUANTITY) *

                        /*New*/
                DECODE(p_scenario_id, -1, 1,
                       DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --2424357
                              1, DECODE(S.DEMAND_CLASS, null, null,
                                     DECODE(l_demand_class, '-1',
                                         MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  s.inventory_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  NULL))),
                       l_demand_class, 1,
                       --bug 4156016: If l_demand_class is not null and demand class is populated
                       -- on  supplies record then 0 should be allocated.
                       Decode (S.Demand_Class, NULL,
                       MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(
                         -- 2859130 C.CALENDAR_DATE,
                         -- Bug 3348095
                         -- For ATP created records use end_date
                         -- otherwise start_date
                         DECODE(REQ.record_source, 2,
                            TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                               TRUNC(REQ.START_DATE)),
                         --trunc(req.start_date),
                         -- End Bug 3348095
                         REQ.ASSEMBLY_ITEM_ID,
                         p_organization_id,
                         p_instance_id,
                         p_department_id,
                         p_resource_id,
                         DECODE(G_HIERARCHY_PROFILE,
                                ---2424357
                                1, DECODE(S.DEMAND_CLASS, null, null,
                                      DECODE(l_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                   S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                2, DECODE(S.CUSTOMER_ID, NULL, l_demand_class,
                                          0, l_demand_class,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  l_inv_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  --2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  NULL))),
                         l_demand_class), 0))) col24,
                        /*New*/
		-- 2859130 C.CALENDAR_DATE col25,
                -- Bug 3348095
                -- For ATP created records use end_date otherwise start_date
                GREATEST(DECODE(REQ.record_source, 2,
                   TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) , TRUNC(REQ.START_DATE)),l_sys_next_date) col25,  --bug3333114
                -- End Bug 3348095
                -- TRUNC(req.start_date) col25,
                l_null_num col26,
                -- Bug 2771075. For Planned Orders, we will populate transaction_id
		-- in the disposition_name column to be consistent with Planning.
		-- S.ORDER_NUMBER col27,
		DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER ) col27,
                l_null_num col28,
                l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                          -- Bug 3348095
                          DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) *
                          -- For ATP created records use resource_hours
                          -- End Bug 3348095
                 ---- resource batching
                DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME) *
                NVL(MUC.CONVERSION_RATE, 1) * NVL(S.NEW_ORDER_QUANTITY,S.FIRM_QUANTITY)
         FROM   MSC_DEPARTMENT_RESOURCES DR,
                MSC_SUPPLIES S,
                MSC_RESOURCE_REQUIREMENTS REQ,
                -- 2859130 MSC_CALENDAR_DATES C,
                MSC_SYSTEM_ITEMS I,
                MSC_UOM_CONVERSIONS MUC
         WHERE  DR.PLAN_ID = p_plan_id
         AND    NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_department_id
         AND    DR.RESOURCE_ID = p_resource_id
         AND    DR.SR_INSTANCE_ID = p_instance_id
         AND    DR.ORGANIZATION_ID = p_organization_id -- for performance
         AND    REQ.PLAN_ID = DR.PLAN_ID
         AND    REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         AND    REQ.RESOURCE_ID = DR.RESOURCE_ID
         AND    REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
         AND    NVL(REQ.PARENT_ID, 1) = 1 -- Bug 2809639
         AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
         AND     I.PLAN_ID = REQ.PLAN_ID
         AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
         AND     I.INVENTORY_ITEM_ID = REQ.ASSEMBLY_ITEM_ID
          -- Begin CTO Option Dependent Resources ODR
          AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
         -- End CTO Option Dependent Resources
         AND     DECODE(p_res_uom_type, 1, I.WEIGHT_UOM, 2 , I.VOLUME_UOM) = MUC.UOM_CODE (+)
         AND     MUC.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
         AND     MUC.INVENTORY_ITEM_ID (+)= 0
         AND    S.PLAN_ID = DR.PLAN_ID
         AND    S.TRANSACTION_ID = REQ.SUPPLY_ID
         AND    S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3948494
         -- Exclude Cancelled Supplies 2460645
         AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
         -- 2859130
         -- AND    C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         -- AND    C.CALENDAR_CODE = l_calendar_code
         -- AND    C.EXCEPTION_SET_ID = l_calendar_exception_set_id
         -- AND    C.CALENDAR_DATE = TRUNC(REQ.START_DATE) -- Bug 2809639
         -- AND    C.SEQ_NUM IS NOT NULL
         ---bug 2341075
         --AND    C.CALENDAR_DATE >= trunc(sysdate)
         -- AND    C.CALENDAR_DATE >= l_plan_start_date
         AND    trunc(req.start_date) >= l_plan_start_date --4135752
         UNION ALL
         SELECT p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_organization_id col6,
                p_department_id col7,
                p_resource_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                l_uom_code col16,
                2 col17, -- supply
                l_null_num col18,
                l_null_char col19,
                MNRA.SR_INSTANCE_ID col20,
                l_null_num col21,
                MNRA.TRANSACTION_ID col22,
                l_null_num col23,
                MNRA.CAPACITY_UNITS  * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600) *
                DECODE(p_scenario_id, -1, 1, NVL((MRHM.allocation_percent/100), 1)) col24,
                --bug 4156016
	        /*		NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                     p_instance_id,
                                                     null,
                                                     p_organization_id,
                                                     p_department_id,
                                                     p_resource_id,
                                                     l_demand_class,
                                                     SHIFT_DATE),1)) col24, */
                MNRA.SHIFT_DATE col25,
                l_null_num col26,
                l_null_char col27,
                l_null_num col28,
		l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
                MNRA.CAPACITY_UNITS * p_max_capacity * p_res_conversion_rate * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,MNRA.to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600)
          FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                  msc_resource_hierarchy_mv MRHM
          WHERE   MNRA.PLAN_ID = p_plan_id
          AND     NVL(MNRA.PARENT_ID, -2) <> -1
          AND     MNRA.SR_INSTANCE_ID = p_instance_id
          AND     MNRA.RESOURCE_ID = p_resource_id
          AND     MNRA.DEPARTMENT_ID = p_department_id
          --bug 2341075
          --AND     SHIFT_DATE >= trunc(sysdate)
          --bug 4232627: select only those records which are after plan start date
          AND     MNRA.SHIFT_DATE >= l_plan_start_date
          --bug 4156016
          AND     MNRA.organization_id = p_organization_id
          AND     MRHM.department_id (+) = MNRA.department_id
          AND     MRHM.resource_id  (+)= MNRA.resource_id
          AND     MRHM.organization_id (+) = MNRA.organization_id
          AND     MRHM.sr_instance_id  (+)= MNRA.sr_instance_id
          --AND     MRHM.level_id (+) = -1 --4365873
          AND     decode(MRHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
          --bug 4232627: select only those records which are after plan start date
          AND     trunc(MNRA.shift_date) >=  trunc(MRHM.effective_date (+))
          AND     trunc(MNRA.shift_date) <=  trunc(MRHM.disable_date (+))
          AND     MRHM.demand_class (+) = l_demand_class
	)
	; -- dsting removed order by col25;
       ELSE  -- now Other plans Bug 2809639
         IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Other Plans Batching Details');
         END IF;
	 INSERT INTO msc_atp_sd_details_temp (
		ATP_Level,
		Order_line_id,
		Scenario_Id,
		Inventory_Item_Id,
		Request_Item_Id,
		Organization_Id,
		Department_Id,
		Resource_Id,
		Supplier_Id,
		Supplier_Site_Id,
		From_Organization_Id,
		From_Location_Id,
		To_Organization_Id,
		To_Location_Id,
		Ship_Method,
		UOM_code,
		Supply_Demand_Type,
		Supply_Demand_Source_Type,
		Supply_Demand_Source_Type_Name,
		Identifier1,
		Identifier2,
		Identifier3,
		Identifier4,
		Supply_Demand_Quantity,
		Supply_Demand_Date,
		Disposition_Type,
		Disposition_Name,
		Pegging_Id,
		End_Pegging_Id,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		Unallocated_Quantity
	)

	(SELECT
    	 	p_level col1,
		p_identifier col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
		p_organization_id col6,
                p_department_id col7,
                p_resource_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		l_uom_code col16,
		1 col17, -- demand
		S.ORDER_TYPE col18,
                l_null_char col19,
		REQ.SR_INSTANCE_ID col20,
                l_null_num col21,
		REQ.TRANSACTION_ID col22,
		l_null_num col23,
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                         -- Bug 3348095
                         DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) *
                         -- For ATP created records use resource_hours
                         -- End Bug 3348095
                 ---- resource batching
                DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME) *
                NVL(MUC.CONVERSION_RATE, 1) * NVL(S.NEW_ORDER_QUANTITY,S.FIRM_QUANTITY) *

                        /*New*/
                DECODE(p_scenario_id, -1, 1,
                       DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --2424357
                              1, DECODE(S.DEMAND_CLASS, null, null,
                                     DECODE(l_demand_class, '-1',
                                         MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  s.inventory_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  NULL))),
                       l_demand_class, 1,
                       --bug 4156016: If l_demand_class is not null and demand class is populated
                       -- on  supplies record then 0 should be allocated.
                       Decode (S.Demand_Class, NULL,
                       MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(
                         C.CALENDAR_DATE,
                         REQ.ASSEMBLY_ITEM_ID,
                         p_organization_id,
                         p_instance_id,
                         p_department_id,
                         p_resource_id,
                         DECODE(G_HIERARCHY_PROFILE,
                                ---2424357
                                1, DECODE(S.DEMAND_CLASS, null, null,
                                      DECODE(l_demand_class, '-1',
                                          MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                   S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                2, DECODE(S.CUSTOMER_ID, NULL, l_demand_class,
                                          0, l_demand_class,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  l_inv_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  NULL))),
                         l_demand_class), 0))) col24,
                        /*New*/
		GREATEST(C.CALENDAR_DATE,l_sys_next_date) col25, --bug3333114
                l_null_num col26,
                -- Bug 2771075. For Planned Orders, we will populate transaction_id
		-- in the disposition_name column to be consistent with Planning.
		-- S.ORDER_NUMBER col27,
		DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER ) col27,
                l_null_num col28,
                l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                          -- Bug 3348095
                          DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                   REQ.DAILY_RESOURCE_HOURS))) *
                          -- For ATP created records use resource_hours
                          -- End Bug 3348095
                 ---- resource batching
                DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME) *
                NVL(MUC.CONVERSION_RATE, 1) * NVL(S.NEW_ORDER_QUANTITY,S.FIRM_QUANTITY)
         FROM   MSC_DEPARTMENT_RESOURCES DR,
                MSC_SUPPLIES S,
                MSC_RESOURCE_REQUIREMENTS REQ,
                MSC_CALENDAR_DATES C,
                MSC_SYSTEM_ITEMS I,
                MSC_UOM_CONVERSIONS MUC
         WHERE  DR.PLAN_ID = p_plan_id
         AND    NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_department_id
         AND    DR.RESOURCE_ID = p_resource_id
         AND    DR.SR_INSTANCE_ID = p_instance_id
         AND    DR.ORGANIZATION_ID = p_organization_id -- for performance
         AND    REQ.PLAN_ID = DR.PLAN_ID
         AND    REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         AND    REQ.RESOURCE_ID = DR.RESOURCE_ID
         AND    REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
         AND    NVL(REQ.PARENT_ID, l_optimized_plan) = l_optimized_plan
         AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
         AND     I.PLAN_ID = REQ.PLAN_ID
         AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
         AND     I.INVENTORY_ITEM_ID = REQ.ASSEMBLY_ITEM_ID
          -- Begin CTO Option Dependent Resources ODR
          AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
         -- End CTO Option Dependent Resources
         AND     DECODE(p_res_uom_type, 1, I.WEIGHT_UOM, 2 , I.VOLUME_UOM) = MUC.UOM_CODE (+)
         AND     MUC.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
         AND     MUC.INVENTORY_ITEM_ID (+)= 0
         AND    S.PLAN_ID = DR.PLAN_ID
         AND    S.TRANSACTION_ID = REQ.SUPPLY_ID
         AND    S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3948494
         -- Exclude Cancelled Supplies 2460645
         AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
         AND    C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         AND    C.CALENDAR_CODE = l_calendar_code
         AND    C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                -- Bug 3348095
                -- Ensure that the ATP created resource Reqs
                -- do not get double counted.
         AND     C.CALENDAR_DATE BETWEEN DECODE(REQ.record_source, 2,
                          TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)), TRUNC(REQ.START_DATE))
                   AND TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                -- End Bug 3348095
         AND    C.SEQ_NUM IS NOT NULL
         ---bug 2341075
         --AND    C.CALENDAR_DATE >= trunc(sysdate)
         AND    C.CALENDAR_DATE >= l_plan_start_date
         UNION ALL
         SELECT p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_organization_id col6,
                p_department_id col7,
                p_resource_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                l_uom_code col16,
                2 col17, -- supply
                l_null_num col18,
                l_null_char col19,
                MNRA.SR_INSTANCE_ID col20,
                l_null_num col21,
                MNRA.TRANSACTION_ID col22,
                l_null_num col23,
                MNRA.CAPACITY_UNITS  * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600) *
                DECODE(p_scenario_id, -1, 1, NVL((MRHM.allocation_percent/100), 1)) col24,
                --bug 4156016
	        /*		NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                     p_instance_id,
                                                     null,
                                                     p_organization_id,
                                                     p_department_id,
                                                     p_resource_id,
                                                     l_demand_class,
                                                     SHIFT_DATE),1)) col24, */
                MNRA.SHIFT_DATE col25,
                l_null_num col26,
                l_null_char col27,
                l_null_num col28,
		l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
                MNRA.CAPACITY_UNITS * p_max_capacity * p_res_conversion_rate * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,MNRA.to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600)
          FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                  msc_resource_hierarchy_mv MRHM
          WHERE   MNRA.PLAN_ID = p_plan_id
          AND     NVL(MNRA.PARENT_ID, -2) <> -1
          AND     MNRA.SR_INSTANCE_ID = p_instance_id
          AND     MNRA.RESOURCE_ID = p_resource_id
          AND     MNRA.DEPARTMENT_ID = p_department_id
          --bug 2341075
          --AND     SHIFT_DATE >= trunc(sysdate)
          --bug 4232627: select only those records which are after plan start date
          AND     MNRA.SHIFT_DATE >= l_plan_start_date
          --bug 4156016
          AND     MNRA.organization_id = p_organization_id
          AND     MRHM.department_id (+) = MNRA.department_id
          AND     MRHM.resource_id  (+)= MNRA.resource_id
          AND     MRHM.organization_id (+) = MNRA.organization_id
          AND     MRHM.sr_instance_id  (+)= MNRA.sr_instance_id
          --AND     MRHM.level_id (+) = -1 --4365873
          AND     decode(MRHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
          --bug 4232627:
          AND     trunc(MNRA.shift_date) >=  trunc(MRHM.effective_date (+))
          AND     trunc(MNRA.shift_date) <=  trunc(MRHM.disable_date (+))
          AND     MRHM.demand_class (+) = l_demand_class
	)
	; -- dsting removed order by col25;
       END IF; -- l_optimized_plan = 1 Bug 2809639
     ELSE

       IF (l_optimized_plan = 1) THEN -- Constrained Plan Bug 2809639
         IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Constrained Plan No Batching Details');
         END IF;
	 INSERT INTO msc_atp_sd_details_temp (
		ATP_Level,
		Order_line_id,
		Scenario_Id,
		Inventory_Item_Id,
		Request_Item_Id,
		Organization_Id,
		Department_Id,
		Resource_Id,
		Supplier_Id,
		Supplier_Site_Id,
		From_Organization_Id,
		From_Location_Id,
		To_Organization_Id,
		To_Location_Id,
		Ship_Method,
		UOM_code,
		Supply_Demand_Type,
		Supply_Demand_Source_Type,
		Supply_Demand_Source_Type_Name,
		Identifier1,
		Identifier2,
		Identifier3,
		Identifier4,
		Supply_Demand_Quantity,
		Supply_Demand_Date,
		Disposition_Type,
		Disposition_Name,
		Pegging_Id,
		End_Pegging_Id,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		Unallocated_Quantity
	)
    	(SELECT
		p_level col1,
		p_identifier col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
		p_organization_id col6,
                p_department_id col7,
                p_resource_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		l_uom_code col16,
		1 col17, -- demand
		S.ORDER_TYPE col18,
                l_null_char col19,
		REQ.SR_INSTANCE_ID col20,
                l_null_num col21,
		REQ.TRANSACTION_ID col22,
		l_null_num col23,
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                         -- Bug 3348095
                         DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) *
                         -- For ATP created records use resource_hours
                         -- End Bug 3348095
                        /*New*/
                DECODE(p_scenario_id, -1, 1,
                       DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --2424357
                              1, DECODE(S.DEMAND_CLASS, null, null,
                                    DECODE(l_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  s.inventory_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  NULL))),
                       l_demand_class, 1,
                       --bug 4156016: If l_demand_class is not null and demand class is populated
                       -- on  supplies record then 0 should be allocated.
                       Decode (S.Demand_Class, NULL,
                       MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(
                         -- 2859130 C.CALENDAR_DATE,
                         -- Bug 3348095
                         -- For ATP created records use end_date
                         -- otherwise start_date
                         DECODE(REQ.record_source, 2,
                            TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                TRUNC(REQ.START_DATE)),
                         --trunc(req.start_date),
                         -- End Bug 3348095
                         REQ.ASSEMBLY_ITEM_ID,
                         p_organization_id,
                         p_instance_id,
                         p_department_id,
                         p_resource_id,
                         DECODE(G_HIERARCHY_PROFILE,
                                --2424357
                                1, DECODE(S.DEMAND_CLASS, null, null,
                                     DECODE(l_demand_class, '-1',
                                         MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  -- 2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                2, DECODE(S.CUSTOMER_ID, NULL, l_demand_class,
                                          0, l_demand_class,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  l_inv_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  --2859130 c.calendar_date,
                                                  -- Bug 3348095
                                                  -- For ATP created records use end_date
                                                  -- otherwise start_date
                                                  DECODE(REQ.record_source, 2,
                                                    TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                                                      TRUNC(REQ.START_DATE)),
                                                  --trunc(req.start_date),
                                                  -- End Bug 3348095
                                                  l_level_id,
                                                  NULL))),
                         l_demand_class), 0))) col24,
                        /*New*/
		-- 2859130 C.CALENDAR_DATE col25,
                -- Bug 3348095
                -- For ATP created records use end_date otherwise start_date
                GREATEST(DECODE(REQ.record_source, 2,
                   TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) , TRUNC(REQ.START_DATE)),l_sys_next_date) col25,  --bug3333114
                -- End Bug 3348095
                -- TRUNC(req.start_date) col25,
                l_null_num col26,
		-- Bug 2771075. For Planned Orders, we will populate transaction_id
		-- in the disposition_name column to be consistent with Planning.
		-- S.ORDER_NUMBER col27,
		DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER) col27,
                l_null_num col28,
                l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                          -- Bug 3348095
                          DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS)))
                          -- For ATP created records use resource_hours
                          -- End Bug 3348095
         FROM   MSC_DEPARTMENT_RESOURCES DR,
                MSC_SUPPLIES S,
                MSC_SYSTEM_ITEMS I,  -- CTO ODR
                MSC_RESOURCE_REQUIREMENTS REQ
                -- 2859130 MSC_CALENDAR_DATES C
         WHERE  DR.PLAN_ID = p_plan_id
         AND    NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_department_id
         AND    DR.RESOURCE_ID = p_resource_id
         AND    DR.SR_INSTANCE_ID = p_instance_id
         AND    DR.ORGANIZATION_ID = p_organization_id -- for performance
         AND    REQ.PLAN_ID = DR.PLAN_ID
         AND    REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         AND    REQ.RESOURCE_ID = DR.RESOURCE_ID
         AND    REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
         AND    NVL(REQ.PARENT_ID, 1) = 1 -- parent_id is 1 for constrained plans. Bug 2809639
         -- CTO Option Dependent Resources ODR
         AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
         AND     I.PLAN_ID = REQ.PLAN_ID
         AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
         AND     I.INVENTORY_ITEM_ID = REQ.ASSEMBLY_ITEM_ID
         AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
         -- End CTO Option Dependent Resources
         AND    S.PLAN_ID = DR.PLAN_ID
         AND    S.TRANSACTION_ID = REQ.SUPPLY_ID
         AND    S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3948494
                -- Exclude Cancelled Supplies 2460645
         AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
         -- 2859130
         -- AND    C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         -- AND    C.CALENDAR_CODE = l_calendar_code
         -- AND    C.EXCEPTION_SET_ID = l_calendar_exception_set_id
         -- AND    C.CALENDAR_DATE = TRUNC(REQ.START_DATE) -- Bug 2809639
         -- AND    C.SEQ_NUM IS NOT NULL
         ---bug 2341075
         --AND    C.CALENDAR_DATE >= trunc(sysdate)
         -- AND    C.CALENDAR_DATE >= l_plan_start_date
         AND    trunc(req.start_date) >= l_plan_start_date --4135752
         UNION ALL
         SELECT p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_organization_id col6,
                p_department_id col7,
                p_resource_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                l_uom_code col16,
                2 col17, -- supply
                l_null_num col18,
                l_null_char col19,
                MNRA.SR_INSTANCE_ID col20,
                l_null_num col21,
                MNRA.TRANSACTION_ID col22,
                l_null_num col23,
                MNRA.CAPACITY_UNITS  * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600) *
                DECODE(p_scenario_id, -1, 1, NVL((MRHM.allocation_percent/100), 1)) col24,
                --bug 4156016
	        /*		NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                     p_instance_id,
                                                     null,
                                                     p_organization_id,
                                                     p_department_id,
                                                     p_resource_id,
                                                     l_demand_class,
                                                     SHIFT_DATE),1)) col24, */
                MNRA.SHIFT_DATE col25,
                l_null_num col26,
                l_null_char col27,
                l_null_num col28,
		l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                MNRA.CAPACITY_UNITS  * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,MNRA.to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600)
          FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                  msc_resource_hierarchy_mv MRHM
          WHERE   MNRA.PLAN_ID = p_plan_id
          AND     NVL(MNRA.PARENT_ID, -2) <> -1
          AND     MNRA.SR_INSTANCE_ID = p_instance_id
          AND     MNRA.RESOURCE_ID = p_resource_id
          AND     MNRA.DEPARTMENT_ID = p_department_id
          --bug 2341075
          --AND     SHIFT_DATE >= trunc(sysdate)
          --bug 4232627: select only those records which are after plan start date
          AND     MNRA.SHIFT_DATE >= l_plan_start_date
          --bug 4156016
          AND     MNRA.organization_id = p_organization_id
          AND     MRHM.department_id (+) = MNRA.department_id
          AND     MRHM.resource_id  (+)= MNRA.resource_id
          AND     MRHM.organization_id (+) = MNRA.organization_id
          AND     MRHM.sr_instance_id  (+)= MNRA.sr_instance_id
          --AND     MRHM.level_id (+) = -1 --4365873
          AND     decode(MRHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
          --bug 4232627:
          AND     trunc(MNRA.shift_date) >=  trunc(MRHM.effective_date (+))
          AND     trunc(MNRA.shift_date) <=  trunc(MRHM.disable_date (+))
          AND     MRHM.demand_class (+) = l_demand_class
	)
	; -- dsting removed order by col25;
       ELSE  -- now Other plans Bug 2809639
         IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Other Plans No Batching Details');
         END IF;
	 INSERT INTO msc_atp_sd_details_temp (
		ATP_Level,
		Order_line_id,
		Scenario_Id,
		Inventory_Item_Id,
		Request_Item_Id,
		Organization_Id,
		Department_Id,
		Resource_Id,
		Supplier_Id,
		Supplier_Site_Id,
		From_Organization_Id,
		From_Location_Id,
		To_Organization_Id,
		To_Location_Id,
		Ship_Method,
		UOM_code,
		Supply_Demand_Type,
		Supply_Demand_Source_Type,
		Supply_Demand_Source_Type_Name,
		Identifier1,
		Identifier2,
		Identifier3,
		Identifier4,
		Supply_Demand_Quantity,
		Supply_Demand_Date,
		Disposition_Type,
		Disposition_Name,
		Pegging_Id,
		End_Pegging_Id,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		Unallocated_Quantity
	)
    	(SELECT
		p_level col1,
		p_identifier col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
		p_organization_id col6,
                p_department_id col7,
                p_resource_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		l_uom_code col16,
		1 col17, -- demand
		S.ORDER_TYPE col18,
                l_null_char col19,
		REQ.SR_INSTANCE_ID col20,
                l_null_num col21,
		REQ.TRANSACTION_ID col22,
		l_null_num col23,
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                          -- Bug 3348095
                          DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                   REQ.DAILY_RESOURCE_HOURS))) *
                          -- For ATP created records use resource_hours
                          -- End Bug 3348095
                        /*New*/
                DECODE(p_scenario_id, -1, 1,
                       DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --2424357
                              1, DECODE(S.DEMAND_CLASS, null, null,
                                    DECODE(l_demand_class, '-1',
                                       MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                              2, DECODE(S.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  s.inventory_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  NULL))),
                       l_demand_class, 1,
                       --bug 4156016: If l_demand_class is not null and demand class is populated
                       -- on  supplies record then 0 should be allocated.
                       Decode (S.Demand_Class, NULL,
                       MSC_AATP_FUNC.Get_Res_Demand_Alloc_Percent(C.CALENDAR_DATE,
                         REQ.ASSEMBLY_ITEM_ID,
                         p_organization_id,
                         p_instance_id,
                         p_department_id,
                         p_resource_id,
                         DECODE(G_HIERARCHY_PROFILE,
                                --2424357
                                1, DECODE(S.DEMAND_CLASS, null, null,
                                     DECODE(l_demand_class, '-1',
                                         MSC_AATP_FUNC.Get_RES_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p_department_id,
                                                  p_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  S.DEMAND_CLASS), S.DEMAND_CLASS)),
                                2, DECODE(S.CUSTOMER_ID, NULL, l_demand_class,
                                          0, l_demand_class,
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  S.CUSTOMER_ID,
                                                  S.SHIP_TO_SITE_ID,
                                                  l_inv_item_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  c.calendar_date,
                                                  l_level_id,
                                                  NULL))),
                         l_demand_class), 0))) col24,
                        /*New*/
		GREATEST(C.CALENDAR_DATE,l_sys_next_date) col25, --bug3333114
                l_null_num col26,
		-- Bug 2771075. For Planned Orders, we will populate transaction_id
		-- in the disposition_name column to be consistent with Planning.
		-- S.ORDER_NUMBER col27,
		DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER) col27,
                l_null_num col28,
                l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                          -- Bug 3348095
                          DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                   REQ.DAILY_RESOURCE_HOURS)))
                          -- For ATP created records use resource_hours
                          -- End Bug 3348095
         FROM   MSC_DEPARTMENT_RESOURCES DR,
                MSC_SUPPLIES S,
                MSC_SYSTEM_ITEMS I, -- CTO ODR
                MSC_RESOURCE_REQUIREMENTS REQ,
                MSC_CALENDAR_DATES C
         WHERE  DR.PLAN_ID = p_plan_id
         AND    NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_department_id
         AND    DR.RESOURCE_ID = p_resource_id
         AND    DR.SR_INSTANCE_ID = p_instance_id
         AND    DR.ORGANIZATION_ID = p_organization_id -- for performance
         AND    REQ.PLAN_ID = DR.PLAN_ID
         AND    REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         AND    REQ.RESOURCE_ID = DR.RESOURCE_ID
         AND    REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
         AND    NVL(REQ.PARENT_ID, l_optimized_plan) = l_optimized_plan
         -- CTO Option Dependent Resources ODR
         AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
         AND     I.PLAN_ID = REQ.PLAN_ID
         AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
         AND     I.INVENTORY_ITEM_ID = REQ.ASSEMBLY_ITEM_ID
         AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
         -- End CTO Option Dependent Resources
         AND    S.PLAN_ID = DR.PLAN_ID
         AND    S.TRANSACTION_ID = REQ.SUPPLY_ID
         AND    S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3948494
                -- Exclude Cancelled Supplies 2460645
         AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
         AND    C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         AND    C.CALENDAR_CODE = l_calendar_code
         AND    C.EXCEPTION_SET_ID = l_calendar_exception_set_id
                -- Bug 3348095
                -- Ensure that the ATP created resource Reqs
                -- do not get double counted.
         AND     C.CALENDAR_DATE BETWEEN DECODE(REQ.record_source, 2,
                          TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)), TRUNC(REQ.START_DATE))
                   AND TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                -- End Bug 3348095
         AND    C.SEQ_NUM IS NOT NULL
         ---bug 2341075
         --AND    C.CALENDAR_DATE >= trunc(sysdate)
         AND    C.CALENDAR_DATE >= l_plan_start_date
         UNION ALL
         SELECT p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_organization_id col6,
                p_department_id col7,
                p_resource_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                l_uom_code col16,
                2 col17, -- supply
                l_null_num col18,
                l_null_char col19,
                MNRA.SR_INSTANCE_ID col20,
                l_null_num col21,
                MNRA.TRANSACTION_ID col22,
                l_null_num col23,
                MNRA.CAPACITY_UNITS  * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600) *
                DECODE(p_scenario_id, -1, 1, NVL((MRHM.allocation_percent/100), 1)) col24,
                --bug 4156016
	        /*		NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                     p_instance_id,
                                                     null,
                                                     p_organization_id,
                                                     p_department_id,
                                                     p_resource_id,
                                                     l_demand_class,
                                                     SHIFT_DATE),1)) col24, */
                MNRA.SHIFT_DATE col25,
                l_null_num col26,
                l_null_char col27,
                l_null_num col28,
		l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                MNRA.CAPACITY_UNITS  * ((DECODE(LEAST(MNRA.from_time, MNRA.to_time),
                       MNRA.to_time,MNRA.to_time + 24*3600,
                       MNRA.to_time) - MNRA.from_time)/3600)
          FROM    MSC_NET_RESOURCE_AVAIL MNRA,
                  msc_resource_hierarchy_mv MRHM
          WHERE   MNRA.PLAN_ID = p_plan_id
          AND     NVL(MNRA.PARENT_ID, -2) <> -1
          AND     MNRA.SR_INSTANCE_ID = p_instance_id
          AND     MNRA.RESOURCE_ID = p_resource_id
          AND     MNRA.DEPARTMENT_ID = p_department_id
          --bug 2341075
          --AND     SHIFT_DATE >= trunc(sysdate)
          --bug 4232627: select only those records which are after plan start date
          --AND     MNRA.SHIFT_DATE >= l_plan_start_date
          --bug 4156016
          AND     MNRA.organization_id = p_organization_id
          AND     MRHM.department_id (+) = MNRA.department_id
          AND     MRHM.resource_id  (+)= MNRA.resource_id
          AND     MRHM.organization_id (+) = MNRA.organization_id
          AND     MRHM.sr_instance_id  (+)= MNRA.sr_instance_id
          --AND     MRHM.level_id (+) = -1 --4365873
          AND     decode(MRHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
          --bug 4232627:
          AND     trunc(MNRA.shift_date) >=  trunc(MRHM.effective_date (+))
          AND     trunc(MNRA.shift_date) <=  trunc(MRHM.disable_date (+))
          AND     MRHM.demand_class (+) = l_demand_class
	)
	; -- dsting removed order by col25;
       END IF; -- l_optimized_plan = 1 Bug 2809639

     END IF; --- If l_use_batching =1 then

      -- for period ATP
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'after insert into msc_atp_sd_details_temp');
      END IF;
      MSC_ATP_PROC.get_period_data_from_SD_temp(x_atp_period);

      l_current_atp.atp_period := x_atp_period.Period_Start_Date;
      l_current_atp.atp_qty := x_atp_period.Period_Quantity;
      --- bug 1657855, remove support for min alloc
      --l_current_atp.limit_qty := l_current_atp.atp_qty; -- 02/16

   END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'right after the big query');
       Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
    END IF;

    -- do backward consumption for DCi
    MSC_ATP_PROC.Atp_Backward_Consume(l_current_atp.atp_qty);

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'right after the backward consume');
       Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
    END IF;

    -- we have 3 records of tables.
    -- l_current_atp: stores the date and quantity for this demand class,
    --                and since we need to do backward consumption on this.
    -- l_current_steal_atp: stores the date and quantity from higher priority
    --                      demand class, this need to consume l_current_atp
    -- l_next_steal_atp : stores  the date and quantity for next priority
    --                    demand class to cunsume.  we need this because we may
    --                    have multiple demand classes at same priority .
    -- for example, we have DC1 in priority 1, DC21, DC22 in priority 2,
    -- DC3 in priority  3.
    -- now DC21 need to take care DC1, DC22 need to take care DC1 but not DC21,
    -- DC3 need to take care DC1, DC21, and DC22.  so if we are in the loop for
    -- DC22, than l_current_atp is the atp info for DC22,
    -- l_current_steal_atp is the atp info for DC1(which does not include DC21),
    -- and l_next_steal_atp is the stealing data that we need to take care
    -- for DC1, DC21 and DC22  when later on we move to the loop for DC3.

       -- do backward consumption if DC1 to DC(i-1) has any negative bucket,and
       -- the priority  is higher than DCi
       -- the l_current_atp is an in/out parameter

      -- for 1680719, since in hierarchy demand class we cannot
      -- judge the priority by just looking at the priority (we need
      -- the information from the parent, so the condition needs to be changed.

      IF l_level_id IN (-1, 1) THEN
        -- here is the old logic which should still be ok for level id 1 and -1
       IF (i > 1) THEN

        IF (l_demand_class_priority_tab(i) >
            l_demand_class_priority_tab (i-1)) THEN
        -- we don't need to change the l_current_steal_atp if we don't
        -- move to next priority.
        -- but we do need to change the l_current_steal_atp
        -- if we are in different priority  now.

          l_current_steal_atp := l_next_steal_atp;

          -- Added for bug 1409335. Need to initialize l_next_steal_atp
          -- otherwise quanities would be getting accumulated
          -- repeatedly.
          l_next_steal_atp := l_null_steal_atp;
        END IF;
       END IF;
      ELSE -- IF l_level_id IN (-1, 1) THEN

       IF (i > 1) THEN

        IF (l_class_tab(i) <> l_class_tab(i-1)) THEN

          -- class changed.  If priority of both classes are not the same,
          -- then we need to change the curr_steal_atp  at class level.

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'class changed');
          END IF;

          IF trunc(l_demand_class_priority_tab(i), -3) >
             trunc(l_demand_class_priority_tab (i-1), -3) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'class priority changed');
            END IF;
            l_class_curr_steal_atp := l_class_next_steal_atp;
            l_class_next_steal_atp := l_null_steal_atp;
          END IF;

          l_partner_next_steal_atp := l_null_steal_atp;
          l_partner_curr_steal_atp := l_null_steal_atp;
          l_partner_next_steal_atp := l_null_steal_atp;
          l_current_steal_atp := l_null_steal_atp;
          l_next_steal_atp := l_null_steal_atp;

        ELSE
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'same class');
          END IF;
          IF (l_partner_tab(i) <> l_partner_tab(i-1)) THEN
            -- customer changed.  If priority of both customers are not the
            -- same, we need to change the curr_steal_atp  at partner level.

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'customer changed');
            END IF;

            IF trunc(l_demand_class_priority_tab(i), -2) >
               trunc(l_demand_class_priority_tab (i-1), -2) THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'customer priority changed');
              END IF;

              l_partner_curr_steal_atp := l_partner_next_steal_atp;
              l_partner_next_steal_atp := l_null_steal_atp;
            END IF;

            l_current_steal_atp := l_null_steal_atp;
            l_next_steal_atp := l_null_steal_atp;

          ELSE
            -- same customer
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'same customer ');
            END IF;

            IF (l_demand_class_priority_tab(i) >
                l_demand_class_priority_tab (i-1)) THEN
              -- site level priority changed

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'site priority changed');
              END IF;
              l_current_steal_atp := l_next_steal_atp;
              l_next_steal_atp := l_null_steal_atp;

            END IF;
          END IF; -- IF (l_partner_tab(i) <> l_partner_tab(i-1))
        END IF; -- IF (l_class_tab(i) <> l_class_tab(i-1))

       END IF; -- IF (i > 1)

      END IF; -- IF l_level_id IN (-1, 1)
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'before we decide we need to do dc consumption');
      END IF;

      IF (i > 1) THEN
       IF (  -- this is the huge condition
             ((l_level_id IN (-1, 1)) AND
             (l_demand_class_priority_tab(i) <> l_demand_class_priority_tab(1)))
           OR
             (l_level_id in (2, 3))
          ) THEN

        -- we need to do demand class consume only if we are not in the first
        -- preferred priority

        -- bug 1413459
        -- we need to remember what's the atp picture before the
        -- demand class consumption but after it's own backward
        -- consumption.  so that we can figure out the stealing
        -- quantity correctly.
        IF (NVL(p_insert_flag, 0) <>0)
           AND (l_demand_class_tab(i) = p_demand_class) THEN
            l_temp_atp := l_current_atp;
        END IF;

--------------
        -- 1680719
        -- since we have hierarchy now, before we do demand class
        -- consumption for site level, we need to do the class level and
        -- partner level first

        IF l_level_id IN (2,3) THEN

          IF l_class_tab(i) <> l_class_tab(1) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'before consume l_class_curr_steal_atp');
               Print_Period_Qty('l_class_curr_steal_atp.atp_period:atp_qty = ',
			l_class_curr_steal_atp);
            END IF;

            MSC_AATP_PVT.Atp_Demand_Class_Consume(l_current_atp, l_class_curr_steal_atp);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'After consume l_class_curr_steal_atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_class_curr_steal_atp.atp_period:atp_qty = ',
			l_class_curr_steal_atp);
            END IF;
          END IF; --IF l_class_tab(i) <> l_class_tab(1) THEN

          -- bug 1922942: although partner_id should be unique, we introduced
          -- -1 for 'Other' which make the partner_id not unique.
          -- for example, Class1/Other and Class2/Other will have same
          -- partner_id -1. so the if condition needs to be modified.

          -- IF l_partner_tab(i) <> l_partner_tab(1) THEN

          IF (l_class_tab(i) <> l_class_tab(1)) OR
              (l_partner_tab(i) <> l_partner_tab(1)) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'before consume l_partner_curr_steal_atp');
            END IF;
            MSC_AATP_PVT.Atp_Demand_Class_Consume(l_current_atp, l_partner_curr_steal_atp);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'After consume l_partner_curr_steal_atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_partner_curr_steal_atp.atp_period:atp_qty = ',
			l_partner_curr_steal_atp);

            END IF;
          END IF; -- IF l_partner_tab(i) <> l_partner_tab(1) THEN

        END IF; -- IF l_level_id IN (2,3)

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'Before consume current_steal_atp');

           Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		l_current_steal_atp);

        END IF;

        MSC_AATP_PVT.Atp_Demand_Class_Consume(l_current_atp, l_current_steal_atp);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'After consume l_current_steal_atp');

           Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
           Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		l_current_steal_atp);
        END IF;

        -- this part is not in the original design.
        -- original design is that we will ignore the inconsistancy
        -- in the s/d and period atp for display when stealing happens, as long
        -- as we take care the stealing in the logic.
        -- but i think it is still better to put it in.
        -- and actually if we change Atp_Demand_Class_Consume we can
        -- deal with this together.  but for now...

        -- we need to know if we need to store the stealing
        -- results in to x_atp_supply_demand and x_atp_period or not.
        -- we only do it if this is the demand class we request and
        -- insert_flag is on

        IF (NVL(p_insert_flag, 0) <>0) AND
           (l_demand_class_tab(i) = p_demand_class) THEN

          FOR j in 1..l_current_atp.atp_qty.COUNT LOOP

            IF l_current_atp.atp_qty(j) < l_temp_atp.atp_qty(j) THEN
              -- this is the stealing quantity in that period
              -- bug 1413459: the stealing quantity should be the current
              -- period quantity (after backward consumption, after stealing)
              -- minus the period quantity after backward consumption but
              -- before the stealing
              l_steal_period_quantity := l_current_atp.atp_qty(j) -
                                         l_temp_atp.atp_qty(j);

              MSC_SATP_FUNC.Extend_Atp_Supply_Demand(l_temp_atp_supply_demand, l_return_status);

              k := l_temp_atp_supply_demand.Level.Count;
              l_temp_atp_supply_demand.level(k) := p_level;
              l_temp_atp_supply_demand.identifier(k) := p_identifier;
              l_temp_atp_supply_demand.scenario_id(k) := p_scenario_id;
              l_temp_atp_supply_demand.department_id(k) := p_department_id;
              l_temp_atp_supply_demand.resource_id(k) := p_resource_id;
              l_temp_atp_supply_demand.uom(k):= l_uom_code;
              l_temp_atp_supply_demand.supply_demand_type(k) := 1;

              -- Bug 1408132 and 1416290, Need to insert type as
              -- Demand Class Consumption (45).
              l_temp_atp_supply_demand.supply_demand_source_type(k) := 45;

              l_temp_atp_supply_demand.identifier1(k) := p_instance_id;
              l_temp_atp_supply_demand.supply_demand_date (k) := l_current_atp.atp_period(j);
              l_temp_atp_supply_demand.supply_demand_quantity(k) := l_steal_period_quantity;

              x_atp_period.Total_Demand_Quantity(j):=
                     x_atp_period.Total_Demand_Quantity(j) +
                     l_steal_period_quantity;

              x_atp_period.period_quantity(j):= x_atp_period.period_quantity(j)
                     + l_steal_period_quantity;

            END IF;
          END LOOP;

	  -- dsting
	  move_SD_plsql_into_SD_temp(l_temp_atp_supply_demand);

        END IF;  -- IF (NVL(p_insert_flag, 0) <>0) .....
       END IF; -- the huge condition
      END IF; -- IF (i > 1)

      --IF l_demand_class_priority_tab(i) < l_priority THEN
      ---bug 1655110
      IF (l_demand_class <> p_demand_class) THEN
        -- we need to prepare the l_next_steal_atp for next priorit

        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_atp, l_next_steal_atp);

        -- 1680719
        IF l_level_id IN (-1, 1) THEN
          IF l_demand_class_priority_tab(i)<
             l_demand_class_priority_tab(i+1) THEN
          -- this is the last element of current priority, so we also need
          -- to add l_steal_atp into l_next_steal_atp if we can not finish
          -- the stealing at this priority

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'level = '||l_level_id);
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'before Adding Add_to_Next_Steal_Atp');
               Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
			l_next_steal_atp);

            END IF;

            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'after Add_to_Next_Steal_Atp');
               Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
			l_next_steal_atp);
            END IF;

          END IF;

        ELSE -- IF l_level_id IN (-1, 1)
          -- this is for hierarchy customer level and site level
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'level = '||l_level_id);
             msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'i = '||i);
             msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_class_tab(i) = '||l_class_tab(i));
             msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'l_class_tab(i+1) = '||l_class_tab(i+1));
          END IF;
          IF (l_class_tab(i) <> l_class_tab(i+1)) THEN

            -- class changed.  If priority of both classes are not the same,
            -- then we need to change the curr_steal_atp  at class level.
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'class changed');
            END IF;

            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_partner_next_steal_atp);
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_curr_steal_atp,
                                  l_partner_next_steal_atp);
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_next_steal_atp,
                                  l_class_next_steal_atp);

            IF trunc(l_demand_class_priority_tab(i), -3)<
               trunc(l_demand_class_priority_tab (i+1), -3) THEN

              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_class_curr_steal_atp,
                                    l_class_next_steal_atp);

            END IF;

          ELSE

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'class the same');
            END IF;
            IF (l_partner_tab(i) <> l_partner_tab(i+1)) THEN
              -- customer changed
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'customer not the same');
              END IF;
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);

              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_partner_next_steal_atp);

              IF trunc(l_demand_class_priority_tab(i), -2)<
                 trunc(l_demand_class_priority_tab (i+1), -2) THEN
                -- customer priority changed

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'customer priority changed');
                END IF;
                MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_curr_steal_atp,
                                      l_partner_next_steal_atp);

              END IF;


            ELSE
              -- same customer
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'customer the same');
              END IF;
              IF (l_demand_class_priority_tab(i)<>
                  l_demand_class_priority_tab (i+1)) THEN
                -- site level priority changed
                MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);

              END IF;
            END IF;
          END IF;
        END IF; -- IF l_level_id IN (-1, 1)
      END IF;

      -- 1665110
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'p_demand_class = '||p_demand_class);
      END IF;
      EXIT WHEN (l_demand_class = p_demand_class);
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'after the exit statement, so we did not exit');
      END IF;

  END LOOP;

  MSC_ATP_PROC.Atp_Accumulate(l_current_atp.atp_qty);

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Res_Alloc_Cum_Atp: ' || 'right after the Atp_Accumulate');
     Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
	l_current_atp);
  END IF;

  x_atp_info := l_current_atp;

  -- get the infinite time fence date if it exists
  l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(null,
             null,null, p_plan_id);


  IF l_infinite_time_fence_date IS NOT NULL THEN
      -- add one more entry to indicate infinite time fence date
      -- and quantity.
      x_atp_info.atp_qty.EXTEND;
      x_atp_info.atp_period.EXTEND;
      --- bug 1657855, remove support for alloc
      --x_atp_info.limit_qty.EXTEND;

      i := x_atp_info.atp_qty.COUNT;
      x_atp_info.atp_period(i) := l_infinite_time_fence_date;
      x_atp_info.atp_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;
      --x_atp_info.limit_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;

      IF NVL(p_insert_flag, 0) <> 0 THEN
        -- add one more entry to indicate infinite time fence date
        -- and quantity.

        x_atp_period.Cumulative_Quantity := x_atp_info.atp_qty;

        j := x_atp_period.Level.COUNT;
        MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, l_return_status);
        j := j + 1;
        IF j > 1 THEN
          x_atp_period.Period_End_Date(j-1) := l_infinite_time_fence_date -1;
	  -- dsting
          --x_atp_period.Identifier1(j) := x_atp_supply_demand.Identifier1(j-1);
          --x_atp_period.Identifier2(j) := x_atp_supply_demand.Identifier2(j-1);
          x_atp_period.Identifier1(j) := x_atp_period.Identifier1(j-1);
          x_atp_period.Identifier2(j) := x_atp_period.Identifier2(j-1);
        END IF;

        x_atp_period.Level(j) := p_level;
        x_atp_period.Identifier(j) := p_identifier;
        x_atp_period.Scenario_Id(j) := p_scenario_id;
        x_atp_period.Pegging_Id(j) := NULL;
        x_atp_period.End_Pegging_Id(j) := NULL;
        x_atp_period.Department_Id(j) := p_department_id;
        x_atp_period.Resource_Id(j) := p_resource_id;
        x_atp_period.Organization_id(j) := p_organization_id;
        x_atp_period.Period_Start_Date(j) := l_infinite_time_fence_date;
        x_atp_period.Total_Supply_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
        x_atp_period.Total_Demand_Quantity(j) := 0;
        x_atp_period.Period_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
        x_atp_period.Cumulative_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;

    END IF;
  END IF;
-- END IF;

END Res_Alloc_Cum_Atp;

/* spec changed as part of ship_rec_cal changes
   various input parameters passed in a record atp_info_rec
*/
PROCEDURE Supplier_Alloc_Cum_Atp(
        p_sup_atp_info_rec      IN      MSC_ATP_REQ.ATP_Info_Rec,
	p_identifier          	IN 	NUMBER,
	p_request_date        	IN 	DATE,
	x_atp_info            	OUT 	NoCopy MRP_ATP_PVT.ATP_Info,
	x_atp_period          	OUT 	NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand   	OUT 	NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ
)
IS
l_calendar_code                 VARCHAR2(14);
l_calendar_exception_set_id     NUMBER;
l_level_id                      NUMBER;
l_priority			NUMBER := 1;
l_allocation_percent		NUMBER := 100;
l_demand_class_tab		MRP_ATP_PUB.char80_arr
                                   := MRP_ATP_PUB.char80_arr();
l_demand_class_priority_tab	MRP_ATP_PUB.number_arr
                                   := MRP_ATP_PUB.number_arr();
l_current_atp			MRP_ATP_PVT.ATP_Info;
l_next_steal_atp		MRP_ATP_PVT.ATP_Info;
l_null_steal_atp		MRP_ATP_PVT.ATP_Info;
l_current_steal_atp             MRP_ATP_PVT.ATP_Info;
l_temp_atp                      MRP_ATP_PVT.ATP_Info;
i				PLS_INTEGER;
l_infinite_time_fence_date	DATE;
mm				PLS_INTEGER;
ii                              PLS_INTEGER;
jj                              PLS_INTEGER;
j				PLS_INTEGER;
k				PLS_INTEGER;
l_demand_class			VARCHAR2(80);
l_inv_item_id			NUMBER;
l_uom_code			VARCHAR2(3);
l_null_num  			number := null;
l_null_char    			varchar2(3) := null;
l_return_status			VARCHAR(1);
l_steal_period_quantity		number;
l_instance_id                   number;
l_org_id                        number;
l_plan_start_date               DATE;
l_postprocessing_lead_time      NUMBER;
l_cutoff_date                   DATE;

-- 1680719
l_class_tab                     MRP_ATP_PUB.char30_arr
                                    := MRP_ATP_PUB.char30_arr();
l_partner_tab                   MRP_ATP_PUB.number_arr
                                    := MRP_ATP_PUB.number_arr();
l_class_next_steal_atp          MRP_ATP_PVT.ATP_Info;
l_partner_next_steal_atp        MRP_ATP_PVT.ATP_Info;
l_class_curr_steal_atp          MRP_ATP_PVT.ATP_Info;
l_partner_curr_steal_atp        MRP_ATP_PVT.ATP_Info;
l_pos1                          NUMBER;
l_pos2                          NUMBER;
delim     constant varchar2(1) := fnd_global.local_chr(13);

-- dsting for s/d performance enh
l_temp_atp_supply_demand   		MRP_ATP_PUB.ATP_Supply_Demand_Typ;

--s_cto_rearch
l_check_cap_model_flag          number;
--e_cto_arch

-- ship_rec_cal
l_sysdate               DATE := trunc(sysdate); --4135752
l_sys_next_date                 DATE; --bug3333114

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('******* Supplier_Alloc_Cum_Atp *******');
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.instance_id =' || p_sup_atp_info_rec.instance_id);
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.supplier_id =' || p_sup_atp_info_rec.supplier_id);
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.supplier_site_id =' || p_sup_atp_info_rec.supplier_site_id);
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.inventory_item_id =' || p_sup_atp_info_rec.inventory_item_id);
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.organization_id =' || p_sup_atp_info_rec.organization_id);
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.demand_class =' || p_sup_atp_info_rec.demand_class);
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_request_date =' || p_request_date );
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.shipping_cal_code =' || p_sup_atp_info_rec.shipping_cal_code );
  END IF;


  -- find all the demand classes that we need to take care: all the demand
  -- classes that have higher priority  + this requested demand class.

  -- Logic
  -- Step 1:
  -- 	FOR each demand class DCi, we need to
  --  	1. get the net daily availability
  --  	2. do backward consumption
  --  	3. do backward consumption if DC1 to DC(i-1) has any negative bucket
  -- 	END LOOP
  -- Step 2:
  --    do accumulation for the requested demand class

  -- select the priority  and allocation_percent for that item/demand class.
  -- if no data found, check if this item has a valid allocation rule.
  -- otherwise return error.

 -- bug 1169467
 -- get the plan start date. later on we will use this restrict the
 -- availability

 -- Supplier Capacity and Lead Time (SCLT) Proj
 -- Commented out
 -- SELECT trunc(plan_start_date), sr_instance_id, organization_id,
 --        trunc(cutoff_date)
 -- INTO   l_plan_start_date, l_instance_id, l_org_id, l_cutoff_date
 -- FROM   msc_plans
 -- WHERE  plan_id = p_sup_atp_info_rec.plan_id;

 -- Instead re-assigned local values using global variable
    l_plan_start_date := MSC_ATP_PVT.G_PLAN_INFO_REC.plan_start_date;
    l_instance_id     := MSC_ATP_PVT.G_PLAN_INFO_REC.sr_instance_id;
    l_org_id          := MSC_ATP_PVT.G_PLAN_INFO_REC.organization_id;
    l_cutoff_date     := MSC_ATP_PVT.G_PLAN_INFO_REC.plan_cutoff_date;

 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_plan_start_date = '||l_plan_start_date);
    msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_instance_id = '||l_instance_id);
    msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_org_id = '||l_org_id);
    msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_cutoff_date = '||l_cutoff_date);
 END IF;

 --s_cto_rearch
 IF (p_sup_atp_info_rec.bom_item_type = 4 AND (p_sup_atp_info_rec.rep_ord_flag = 'Y'
                                          OR   p_sup_atp_info_rec.base_item_id is not null)) THEN --bug 8631827,7592457
        l_inv_item_id := p_sup_atp_info_rec.base_item_id;
        l_check_cap_model_flag := 1;
 ELSIF  p_sup_atp_info_rec.bom_item_type = 1 THEN
        l_inv_item_id := p_sup_atp_info_rec.inventory_item_id;
        l_check_cap_model_flag := 1;
 ELSE
        l_inv_item_id := p_sup_atp_info_rec.inventory_item_id;
 END IF;
 --e_cto_rearch


 --MSC_AATP_PVT.Get_DC_Info(l_instance_id, p_sup_atp_info_rec.inventory_item_id, p_sup_atp_info_rec.organization_id, null, null,
 MSC_AATP_PVT.Get_DC_Info(l_instance_id, l_inv_item_id, p_sup_atp_info_rec.organization_id, null, null,
	 p_sup_atp_info_rec.demand_class, p_request_date, l_level_id, l_priority, l_allocation_percent, l_return_status);
  -- find the demand classes that have priority  higher (small number) than
  -- the requested demand class

-- IF l_allocation_percent <> 0.0 THEN
 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'before select the high priority demand class');
 END IF;

  -- bug 1680719
  --bug3948494 Do not select Higher priority DC if the requested DC
  --is at highest priority , we donot honor for forward consumption method here.
  IF l_level_id = -1 AND l_priority <> 1 THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_allocation_percent = '||l_allocation_percent);
    END IF;
    SELECT demand_class, priority
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab
    FROM   msc_item_hierarchy_mv
    --WHERE  inventory_item_id = p_sup_atp_info_rec.inventory_item_id
    WHERE  inventory_item_id = l_inv_item_id
    AND    organization_id = p_sup_atp_info_rec.organization_id -- Ship To org
    AND    sr_instance_id = l_instance_id
    AND    p_request_date BETWEEN effective_date AND disable_date
    AND    priority  <= l_priority   -- 1665110, add '='
    AND    level_id = l_level_id
    ORDER BY priority asc, allocation_percent desc ;

  ELSIF l_level_id = 1 THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT demand_class, priority
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab
    FROM   msc_item_hierarchy_mv
    --WHERE  inventory_item_id = p_sup_atp_info_rec.inventory_item_id
    WHERE  inventory_item_id = l_inv_item_id
    AND    organization_id = p_sup_atp_info_rec.organization_id
    AND    sr_instance_id = l_instance_id
    AND    p_request_date BETWEEN effective_date AND disable_date
    AND    priority  <= l_priority   -- 1665110, add '='
    AND    level_id = l_level_id
    ORDER BY priority asc, class;

  ELSIF l_level_id = 2 THEN


    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT mv1.demand_class, mv1.priority, mv1.class, mv1.partner_id
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab,
                      l_class_tab, l_partner_tab
    FROM   msc_item_hierarchy_mv mv1
    --WHERE  mv1.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
    WHERE  inventory_item_id = l_inv_item_id
    AND    mv1.organization_id = p_sup_atp_info_rec.organization_id
    AND    mv1.sr_instance_id = l_instance_id
    AND    p_request_date BETWEEN mv1.effective_date AND mv1.disable_date
    --AND    mv1.priority  <= l_priority   -- 1665110, add '='
    AND    mv1.level_id = l_level_id
    AND trunc(mv1.priority, -3) <= trunc(l_priority, -3)
      ORDER BY trunc(mv1.priority, -3), mv1.class ,
               trunc(mv1.priority, -2), mv1.partner_id;


  ELSIF l_level_id = 3 THEN

    -- bug 1680719
    -- we need to select the class, partner_id, partner_site_id

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT mv1.demand_class, mv1.priority, mv1.class, mv1.partner_id
    BULK COLLECT INTO l_demand_class_tab, l_demand_class_priority_tab,
                      l_class_tab, l_partner_tab
    FROM   msc_item_hierarchy_mv mv1
    --WHERE  mv1.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
    WHERE  mv1.inventory_item_id = l_inv_item_id
    AND    mv1.organization_id = p_sup_atp_info_rec.organization_id
    AND    mv1.sr_instance_id = l_instance_id
    AND    p_request_date BETWEEN mv1.effective_date AND mv1.disable_date
    --AND    mv1.priority  <= l_priority   -- 1665110, add '='
    AND    mv1.level_id = l_level_id
    AND trunc(mv1.priority, -3) <= trunc(l_priority, -3)
      ORDER BY trunc(mv1.priority, -3), mv1.class ,
               trunc(mv1.priority, -2), mv1.partner_id,
               mv1.priority, mv1.partner_site_id;
  END IF;

--/* 1665110
  IF l_demand_class_tab.count = 0 THEN
     -- add the request demand class into the list
     l_demand_class_tab.Extend;
     l_demand_class_priority_tab.Extend;
     i := l_demand_class_tab.COUNT;
     l_demand_class_priority_tab(i) := l_priority;
     l_demand_class_tab(i) := p_sup_atp_info_rec.demand_class;

     -- 1680719
     IF l_level_id in (2, 3) THEN
         l_class_tab.Extend;
         l_partner_tab.Extend;
         l_pos1 := instr(p_sup_atp_info_rec.demand_class,delim,1,1);
         l_pos2 := instr(p_sup_atp_info_rec.demand_class,delim,1,2);
         l_class_tab(i) := substr(p_sup_atp_info_rec.demand_class,1,l_pos1-1);
         IF l_pos2 = 0 THEN
           l_partner_tab(i) := substr(p_sup_atp_info_rec.demand_class,l_pos1+1);
         ELSE
           l_partner_tab(i) := substr(p_sup_atp_info_rec.demand_class,l_pos1+1,l_pos2-l_pos1-1) ;
         END IF;
     END IF;
  END IF;
--1665110 */

  mm := l_demand_class_tab.FIRST;

  WHILE mm is not null LOOP
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_demand_class_tab and priority = '||
        l_demand_class_tab(mm) ||' : '|| l_demand_class_priority_tab(mm));
     END IF;

     IF l_level_id in (2,3) THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_class_tab and partner = '||
        l_class_tab(mm) ||' : '||l_partner_tab(mm));
       END IF;
     END IF;

     mm := l_demand_class_tab.Next(mm);

  END LOOP;

  -- get the uom code :bug 1187141
  SELECT uom_code, postprocessing_lead_time
  INTO   l_uom_code, l_postprocessing_lead_time
  FROM   msc_system_items
  WHERE  plan_id = p_sup_atp_info_rec.plan_id
  AND    sr_instance_id = p_sup_atp_info_rec.instance_id
  AND    organization_id = p_sup_atp_info_rec.organization_id
  --AND    inventory_item_id = p_sup_atp_info_rec.inventory_item_id;
  AND    inventory_item_id = l_inv_item_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_uom_code and l_postprocessing_lead_time = '||
        l_uom_code ||' : '||l_postprocessing_lead_time);
  END IF;

  -- for performance reason, we need to get the following info and
  -- store in variables instead of joining it

  --=======================================================================================================
  --  ship_rec_cal changes begin
  --=======================================================================================================
  --  use SMC instead of OMC for netting
  --  IF SMC is FOC get plan owning org's calendar. Since we assume that every org must have atleast a
  --  manufacturing calendar defined, we use plan owning org's calendar as it will be spanning atleast
  --  upto plan end date
  --=======================================================================================================
  IF p_sup_atp_info_rec.manufacturing_cal_code <> '@@@' THEN
     l_calendar_code := p_sup_atp_info_rec.manufacturing_cal_code;
  ELSE
        SELECT  tp.calendar_code
        INTO    l_calendar_code
        FROM    msc_trading_partners tp,
                msc_plans mp
        WHERE   mp.plan_id = p_sup_atp_info_rec.plan_id
        AND     tp.sr_instance_id  = mp.sr_instance_id
        AND     tp.partner_type    = 3
        AND     tp.sr_tp_id        = mp.organization_id;
  END IF;
  l_calendar_exception_set_id := -1;

  --bug3333114 start
  l_sys_next_date := MSC_CALENDAR.NEXT_WORK_DAY (
                                        p_sup_atp_info_rec.shipping_cal_code,
                                        l_instance_id,
                                        TRUNC(sysdate));

  IF PG_DEBUG in ('Y', 'C') THEN
  msc_sch_wb.atp_debug('Sys next Date : '||to_char(l_sys_next_date, 'DD-MON-YYYY'));
  END IF;

  IF (l_sys_next_date is NULL) THEN
      msc_sch_wb.atp_debug('Sys Next Date is null');
      MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  --bug3333114 end

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.manufacturing_cal_code='||p_sup_atp_info_rec.manufacturing_cal_code);
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_calendar_code='||l_calendar_code);
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_calendar_exception_set_id'|| l_calendar_exception_set_id);
  END IF;
  --  ship_rec_cal changes end


  FOR i in 1..l_demand_class_tab.COUNT LOOP
          l_demand_class := l_demand_class_tab(i);
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'in i loop, i = '||i);
             msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_demand_class = '||l_demand_class);
          END IF;
    --=======================================================================================================
    -- ship_rec_cal changes begin
    --=======================================================================================================
    --  In all the SQLs that get supplier capacities following are the changes:
    --  1. Pass (c.seq_num - p_sup_atp_info_rec.sysdate_seq_num) to get_tolerance_percentage fn instead of
    --     passing c.calendar_date.
    --  2. If calendar code passed in FOC, we use plan owning org's calendar and remove p_seq_num is not
    --     null filter condition.
    --
    --  In all the SQLs that get planned orders, purchase orders and purchase requisitions following
    --  are the changes:
    --  1. We use new_dock_date or new_ship_date depending on whether supplier capacity is dock capacity or
    --     ship capacity.
    --     Earlier we used to look at new_schedule_date and offset post_processing_lead_time.
    --  2. Removed join with msc_calendar_dates
    --=======================================================================================================
    -- get the daily net availability for DCi
    IF (NVL(p_sup_atp_info_rec.insert_flag, 0) = 0  OR l_demand_class <> p_sup_atp_info_rec.demand_class) THEN
      IF l_check_cap_model_flag = 1 THEN

          -- we don't want details
         SELECT 	trunc(l_date), --4135752
      		   SUM(quantity)
         BULK COLLECT INTO
               	   l_current_atp.atp_period,
               	   l_current_atp.atp_qty
         FROM (
         SELECT GREATEST(cs.calendar_date,l_sys_next_date) l_date, --bug3333114
	        cs.capacity*(1+NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                      p_sup_atp_info_rec.instance_id, p_sup_atp_info_rec.plan_id,
                                      l_inv_item_id, p_sup_atp_info_rec.organization_id,
                                      p_sup_atp_info_rec.supplier_id, p_sup_atp_info_rec.supplier_site_id,
                                      cs.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0))*
		   /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(l_instance_id,
                                            s.inventory_item_id,
                                            p_sup_atp_info_rec.organization_id,
                                            null,
                                            null,
                                            l_demand_class,
                                            c.calendar_date), 1) quantity*/
                   NVL(MIHM.allocation_percent/100, 1) quantity --4365873
	FROM
      (
      SELECT
      	    c.calendar_date,
      	    c.seq_num,
	    s.inventory_item_id,
	    s.sr_instance_id,
	    S.ORGANIZATION_ID,
	    S.capacity
         FROM   msc_calendar_dates c,
                msc_supplier_capacities s
         --WHERE  s.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
         WHERE  s.inventory_item_id = l_inv_item_id
         AND    s.sr_instance_id = p_sup_atp_info_rec.instance_id
         AND    s.plan_id = p_sup_atp_info_rec.plan_id
         AND    s.organization_id = p_sup_atp_info_rec.organization_id
         AND    s.supplier_id = p_sup_atp_info_rec.supplier_id
         AND    NVL(s.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
         AND    c.calendar_date BETWEEN trunc(s.from_date)
                                --AND NVL(s.to_date,l_cutoff_date)
                                AND trunc(NVL(s.to_date,least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))) --4055719
         AND    (c.seq_num IS NOT NULL or p_sup_atp_info_rec.manufacturing_cal_code = '@@@')
         AND    c.calendar_code = l_calendar_code
         AND    c.exception_set_id = l_calendar_exception_set_id
         AND    c.sr_instance_id = l_instance_id
         AND    c.calendar_date >= NVL(p_sup_atp_info_rec.sup_cap_cum_date, l_plan_start_date))CS,
      msc_item_hierarchy_mv mihm
      WHERE
      --4365873
      	     CS.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
      AND    CS.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
      AND    CS.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
      AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
      AND    CS.calendar_date >= MIHM.effective_date (+)
      AND    CS.calendar_date <= MIHM.disable_date (+)
      AND    MIHM.demand_class (+) = l_demand_class
         -- Supplier Capacity (SCLT) Accumulation starts from this date.
         -- AND    c.calendar_date >= l_plan_start_date -- bug 1169467
         UNION ALL
         SELECT GREATEST(trunc(Decode(p_sup_atp_info_rec.sup_cap_type,  --4135752
                                1, p.new_ship_date,
                                p.new_dock_date)),l_sys_next_date) l_date, -- For ship_rec_cal --bug3333114
                (-1)*(p.new_order_quantity - NVL(p.implement_quantity,0))*
		   DECODE(DECODE(G_HIERARCHY_PROFILE,
                                 --2424357
                                 1, DECODE(p.DEMAND_CLASS, null, null,
                                       DECODE(l_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                     null,
                                                     null,
                                                     p.inventory_item_id,
                                                     p.organization_id,
                                                     p.sr_instance_id,
                                                     trunc(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                          1, p.new_ship_date,
                                                          p.new_dock_date
                                                     )), --4135752
                                                     l_level_id,
                                                     p.DEMAND_CLASS), p.DEMAND_CLASS)),
                                 2, DECODE(p.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                           0, TO_CHAR(NULL),
                                                   MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                     p.CUSTOMER_ID,
                                                     p.SHIP_TO_SITE_ID,
                                                     p.inventory_item_id,
                                                     p.organization_id,
                                                     p.sr_instance_id,
                                                     trunc(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                          1, p.new_ship_date,
                                                          p.new_dock_date
                                                     )), --4135752
                                                     l_level_id,
                                                     NULL))),
		           l_demand_class, 1,
			   NULL, NVL(MIHM.allocation_percent/100,  --4365873
			   /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p.sr_instance_id,
                                                          p.inventory_item_id ,
				                          p.organization_id,
                                                          null,
                                                          null,
				                          l_demand_class,
                                                          trunc(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                                        1, p.new_ship_date,
                                                                        p.new_dock_date
                                                          ))),*/
                                                           1), --4135752
                           DECODE(MIHM.allocation_percent/100,
                           /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p.sr_instance_id,
                                                       p.inventory_item_id,
                                                       p.organization_id,
                                                       null,
                                                       null,
                                                       l_demand_class,
                                                       trunc(Decode(p_sup_atp_info_rec.sup_cap_type,  --4135752
                                                          1, p.new_ship_date,
                                                          p.new_dock_date
                                                       ))),*/
				   NULL, 1,
				   0)) quantity
         -- Supplier Capacity (SCLT) Changes Begin
         FROM   msc_supplies p,msc_item_hierarchy_mv MIHM
         WHERE  (p.order_type IN (5, 2)
                OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = trunc(MSC_ATP_REQ.G_PROMISE_DATE) --4135752
                     AND p.order_type = 1 AND p.promised_date IS NULL))
         -- Supplier Capacity (SCLT) Accumulation Ignore Purchase Orders
         -- WHERE  p.order_type IN (5, 1, 2)
         AND    p.plan_id = p_sup_atp_info_rec.plan_id
         AND    p.sr_instance_id = p_sup_atp_info_rec.instance_id
         --AND    p.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
   -- 1214694      AND    p.organization_id = p_sup_atp_info_rec.organization_id
         AND    p.supplier_id  = p_sup_atp_info_rec.supplier_id
         AND    NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                -- Exclude Cancelled Supplies 2460645
         AND    NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                 --consider ATP inserted PO only and palling PO will be tied to forecats
         AND    ((p.inventory_item_id = l_inv_item_id and p.record_source=2) OR
                    p.inventory_item_id in
                           (select inventory_item_id from msc_system_items msi
                            where  msi.base_item_id = l_inv_item_id
                            and    msi.plan_id = p_sup_atp_info_rec.plan_id
                            and    msi.organization_id = p_sup_atp_info_rec.organization_id
                            and    msi.base_item_id = l_inv_item_id))
         AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) --4055719 --4135752
                      <= trunc(least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))                    --4135752
         -- Supplier Capacity (SCLT) Changes End
      --4365873
      AND    p.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
      AND    p.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
      AND    p.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
      AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
      AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) >= MIHM.effective_date (+)
      AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) <= MIHM.disable_date (+)
      AND    MIHM.demand_class (+) = l_demand_class
         )
         GROUP BY l_date
         ORDER BY l_DATE;--4698199
         --- bug 1657855, remove support for min alloc
         --l_current_atp.limit_qty := l_current_atp.atp_qty;
      ELSE
          -- we don't want details
         SELECT 	trunc(l_date), --4135752
      		   SUM(quantity)
         BULK COLLECT INTO
               	   l_current_atp.atp_period,
               	   l_current_atp.atp_qty
         FROM (
         SELECT GREATEST(cs.calendar_date,l_sys_next_date) l_date, --bug3333114
	        cs.capacity*(1+NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                      p_sup_atp_info_rec.instance_id, p_sup_atp_info_rec.plan_id,
                                      p_sup_atp_info_rec.inventory_item_id, p_sup_atp_info_rec.organization_id,
                                      p_sup_atp_info_rec.supplier_id, p_sup_atp_info_rec.supplier_site_id,
                                      cs.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0))*
		   /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(l_instance_id,
                                            s.inventory_item_id,
                                            p_sup_atp_info_rec.organization_id,
                                            null,
                                            null,
                                            l_demand_class,
                                            c.calendar_date), 1) quantity*/
                    NVL(MIHM.allocation_percent/100, 1) quantity --4365873
         FROM
      (
      SELECT
      	    c.calendar_date,
      	    c.seq_num,
	    s.inventory_item_id,
	    s.sr_instance_id,
	    S.ORGANIZATION_ID,
	    S.capacity
         FROM   msc_calendar_dates c,
                msc_supplier_capacities s
         WHERE  s.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
         AND    s.sr_instance_id = p_sup_atp_info_rec.instance_id
         AND    s.plan_id = p_sup_atp_info_rec.plan_id
         AND    s.organization_id = p_sup_atp_info_rec.organization_id
         AND    s.supplier_id = p_sup_atp_info_rec.supplier_id
         AND    NVL(s.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
         AND    c.calendar_date BETWEEN trunc(s.from_date)
                                --AND NVL(s.to_date,l_cutoff_date)
                                AND trunc(NVL(s.to_date,least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))) --4055719
         AND    (c.seq_num IS NOT NULL or p_sup_atp_info_rec.manufacturing_cal_code = '@@@')
         AND    c.calendar_code = l_calendar_code
         AND    c.exception_set_id = l_calendar_exception_set_id
         AND    c.sr_instance_id = l_instance_id
         AND    c.calendar_date >= NVL(p_sup_atp_info_rec.sup_cap_cum_date, l_plan_start_date))CS,
      msc_item_hierarchy_mv mihm
      WHERE
      --4365873
      	     CS.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
      AND    CS.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
      AND    CS.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
      AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
      AND    CS.calendar_date >= MIHM.effective_date (+)
      AND    CS.calendar_date <= MIHM.disable_date (+)
      AND    MIHM.demand_class (+) = l_demand_class
         -- Supplier Capacity (SCLT) Accumulation starts from this date.
         -- AND    c.calendar_date >= l_plan_start_date -- bug 1169467
         UNION ALL
         SELECT GREATEST(trunc(Decode(p_sup_atp_info_rec.sup_cap_type,  --4135752
                   1, p.new_ship_date,
                   p.new_dock_date
                )),l_sys_next_date) l_date, --bug3333114
                -- ship_rec_cal rearrange signs to get rid of multiply times -1
                (NVL(p.implement_quantity,0) - p.new_order_quantity)*
		   DECODE(DECODE(G_HIERARCHY_PROFILE,
                                 --2424357
                                 1, DECODE(p.DEMAND_CLASS, null, null,
                                       DECODE(l_demand_class, '-1',
                                           MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                     null,
                                                     null,
                                                     p.inventory_item_id,
                                                     p.organization_id,
                                                     p.sr_instance_id,
                                                     trunc(Decode(p_sup_atp_info_rec.sup_cap_type,  --4135752
                                                           1, p.new_ship_date,
                                                           p.new_dock_date
                                                     )),
                                                     l_level_id,
                                                     p.DEMAND_CLASS), p.DEMAND_CLASS)),
                                 2, DECODE(p.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                           0, TO_CHAR(NULL),
                                                   MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                     p.CUSTOMER_ID,
                                                     p.SHIP_TO_SITE_ID,
                                                     p.inventory_item_id,
                                                     p.organization_id,
                                                     p.sr_instance_id,
                                                     trunc(Decode(p_sup_atp_info_rec.sup_cap_type,  --4135752
                                                           1, p.new_ship_date,
                                                           p.new_dock_date
                                                     )),
                                                     l_level_id,
                                                     NULL))),
		           l_demand_class, 1,
			   NULL, NVL(MIHM.allocation_percent/100,  --4365874
			   /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p.sr_instance_id,
                                                          p.inventory_item_id ,
				                          p.organization_id,
                                                          null,
                                                          null,
				                          l_demand_class,
                                                          trunc(Decode(p_sup_atp_info_rec.sup_cap_type,  --4135752
                                                             1, p.new_ship_date,
                                                             p.new_dock_date
                                                          ))),*/
                                                           1), --4135752
                           DECODE(MIHM.allocation_percent/100,
			   /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p.sr_instance_id,
                                                       p.inventory_item_id,
                                                       p.organization_id,
                                                       null,
                                                       null,
                                                       l_demand_class,
                                                       trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                             1, p.new_ship_date,
                                                             p.new_dock_date
                                                       ))), */
				   NULL, 1,
				   0)) quantity
         -- Supplier Capacity (SCLT) Changes Begin
         FROM   msc_supplies p,msc_item_hierarchy_mv MIHM
         WHERE  (p.order_type IN (5, 2)
                OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                     AND p.order_type = 1 AND p.promised_date IS NULL))
         -- Supplier Capacity (SCLT) Accumulation Ignore Purchase Orders
         -- WHERE  p.order_type IN (5, 1, 2)
         AND    p.plan_id = p_sup_atp_info_rec.plan_id
         AND    p.sr_instance_id = p_sup_atp_info_rec.instance_id
         AND    p.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
   -- 1214694      AND    p.organization_id = p_sup_atp_info_rec.organization_id
         AND    p.supplier_id  = p_sup_atp_info_rec.supplier_id
         AND    NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                -- Exclude Cancelled Supplies 2460645
         AND    NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
         AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) --4055719 --4135752
                       <= least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date)
      --4365873
      AND    p.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
      AND    p.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
      AND    p.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
      AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
      AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) >= MIHM.effective_date (+)
      AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) <= MIHM.disable_date (+)
      AND    MIHM.demand_class (+) = l_demand_class
         )
         GROUP BY l_date
         ORDER BY l_DATE;--4698199
         --- bug 1657855, remove support for min alloc
         --l_current_atp.limit_qty := l_current_atp.atp_qty;
      END IF;
    ELSE
        --IF (NVL(p_sup_atp_info_rec.insert_flag, 0) <> 0  AND
        -- l_demand_class <> p_sup_atp_info_rec.demand_class) THEN we want details
	MSC_ATP_DB_UTILS.Clear_SD_Details_Temp();

        IF l_check_cap_model_flag = 1 THEN

           -- dsting: s/d details performance enh
           INSERT INTO msc_atp_sd_details_temp (
           	ATP_Level,
           	Order_line_id,
           	Scenario_Id,
           	Inventory_Item_Id,
           	Request_Item_Id,
	        Organization_Id,
                Department_Id,
	        Resource_Id,
                Supplier_Id,
                Supplier_Site_Id,
	        From_Organization_Id,
	        From_Location_Id,
	        To_Organization_Id,
	        To_Location_Id,
	        Ship_Method,
	        UOM_code,
	        Supply_Demand_Type,
	        Supply_Demand_Source_Type,
	        Supply_Demand_Source_Type_Name,
	        Identifier1,
	        Identifier2,
	        Identifier3,
	        Identifier4,
	        Supply_Demand_Quantity,
	        Supply_Demand_Date,
	        Disposition_Type,
	        Disposition_Name,
	        Pegging_Id,
	        End_Pegging_Id,
	        creation_date,
	        created_by,
	        last_update_date,
	        last_updated_by,
	        last_update_login,
	        Unallocated_Quantity
            )

            (SELECT     p_sup_atp_info_rec.level col1,
		p_identifier col2,
                p_sup_atp_info_rec.scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
		p_sup_atp_info_rec.organization_id col6,
                l_null_num col7,
                l_null_num col8,
                p_sup_atp_info_rec.supplier_id col9,
                p_sup_atp_info_rec.supplier_site_id col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		l_uom_code col16,
		2 col17, -- supply
		l_null_num col18,
                l_null_char col19,
		p_sup_atp_info_rec.instance_id col20,
                l_null_num col21,
		l_null_num col22,
		l_null_num col23,
                cs.capacity*(1+NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                   p_sup_atp_info_rec.instance_id,
                                   p_sup_atp_info_rec.plan_id,
                                   l_inv_item_id,
                                   p_sup_atp_info_rec.organization_id,
                                   p_sup_atp_info_rec.supplier_id,
                                   p_sup_atp_info_rec.supplier_site_id,
                                   cs.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0)) *
                                   NVL(MIHM.allocation_percent/100,  --4365873
                                   /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                     l_instance_id,
                                                     s.inventory_item_id,
                                                     p_sup_atp_info_rec.organization_id,
                                                     null,
                                                     null,
                                                     l_demand_class,
                                                     c.calendar_date),*/
                                                      1) col24,
		GREATEST(CS.CALENDAR_DATE,l_sys_next_date) col25, --bug3333114
                l_null_num col26,
                l_null_char col27,
                l_null_num col28,
                l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                cs.capacity*(1+NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                   p_sup_atp_info_rec.instance_id,
                                   p_sup_atp_info_rec.plan_id,
                                   l_inv_item_id,
                                   p_sup_atp_info_rec.organization_id,
                                   p_sup_atp_info_rec.supplier_id,
                                   p_sup_atp_info_rec.supplier_site_id,
                                   cs.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0))
         FROM
         (
         SELECT
            s.capacity,
	    c.calendar_date,
	    s.inventory_item_id,
	    s.sr_instance_id,
	    s.organization_id,
	    c.seq_num

                FROM   msc_calendar_dates c,
                       msc_supplier_capacities s
                --WHERE  s.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
                WHERE  s.inventory_item_id = l_inv_item_id
                AND    s.sr_instance_id = p_sup_atp_info_rec.instance_id
                AND    s.plan_id = p_sup_atp_info_rec.plan_id
                AND    s.organization_id = p_sup_atp_info_rec.organization_id
                AND    s.supplier_id = p_sup_atp_info_rec.supplier_id
                AND    NVL(s.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                AND    c.calendar_date BETWEEN trunc(s.from_date)
                                --AND NVL(s.to_date,l_cutoff_date)
                                AND trunc(NVL(s.to_date,least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))) --4055719
                AND    (c.seq_num IS NOT NULL or p_sup_atp_info_rec.manufacturing_cal_code = '@@@')
                AND    c.calendar_code = l_calendar_code
                AND    c.exception_set_id = l_calendar_exception_set_id
                AND    c.sr_instance_id = l_instance_id
                AND    c.calendar_date >= NVL(p_sup_atp_info_rec.sup_cap_cum_date, l_plan_start_date))CS,
         msc_item_hierarchy_mv MIHM
         WHERE
         --4365873
                cs.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
      	 AND    cs.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
      	 AND    cs.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
      	 --AND    decode(MIHM.level_id,-1,1,2) (+) = (select decode(fnd_profile.value('XXXX'),1,1,2) from dual)
      	 --AND   MIHM.level_id(+)=-1
      	 AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
      	 AND    cs.calendar_date >= MIHM.effective_date (+)
      	 AND    cs.calendar_date <= MIHM.disable_date (+)
      	 AND    MIHM.demand_class (+) = l_demand_class
                -- Supplier Capacity (SCLT) Accumulation starts from this date.
                -- AND    c.calendar_date >= l_plan_start_date -- bug 1169467
                UNION ALL
                SELECT p_sup_atp_info_rec.level col1,
                p_identifier col2,
                p_sup_atp_info_rec.scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_sup_atp_info_rec.organization_id col6,
                l_null_num col7,
                l_null_num col8,
                p_sup_atp_info_rec.supplier_id col9,
                p_sup_atp_info_rec.supplier_site_id col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                l_uom_code col16,
                1 col17, -- demand
                p.order_type col18,
                l_null_char col19,
                p_sup_atp_info_rec.instance_id col20,
                l_null_num col21,
                p.TRANSACTION_ID col22,
                l_null_num col23,
                -- ship_rec_cal rearrange signs to get rid of multiply times -1
                (NVL(p.implement_quantity,0) - p.new_order_quantity)*
                DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --2424357
                              1, DECODE(p.DEMAND_CLASS, null, null,
                                    DECODE(l_demand_class, '-1',
                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p.inventory_item_id,
                                                  p.organization_id,
                                                  p.sr_instance_id,
                                                  trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                     1, p.new_ship_date,
                                                     p.new_dock_date
                                                  )),
                                                  l_level_id,
                                                   p.DEMAND_CLASS), p.DEMAND_CLASS)),
                              2, DECODE(p.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  p.CUSTOMER_ID,
                                                  p.SHIP_TO_SITE_ID,
                                                  p.inventory_item_id,
                                                  p.organization_id,
                                                  p.sr_instance_id,
                                                  trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                     1, p.new_ship_date,
                                                     p.new_dock_date
                                                  )),
                                                  l_level_id,
                                                  NULL))),
                        l_demand_class, 1,
                        NULL, NVL(MIHM.allocation_percent/100,  --4365873
                        /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p.sr_instance_id,
                                                       p.inventory_item_id ,
                                                       p.organization_id,
                                                       null,
                                                       null,
                                                       l_demand_class,
                                                       trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                          1, p.new_ship_date,
                                                          p.new_dock_date
                                                       ))),*/
                                                        1),
                        DECODE(MIHM.allocation_percent/100,
                        /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p.sr_instance_id,
                                                    p.inventory_item_id,
                                                    p.organization_id,
                                                    null,
                                                    null,
                                                    l_demand_class,
                                                    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                       1, p.new_ship_date,
                                                       p.new_dock_date
                                                    ))),*/
                                NULL, 1,
                                0)) col24,
                GREATEST(trunc(Decode(p_sup_atp_info_rec.sup_cap_type,  --4135752
                   1, p.new_ship_date,
                   p.new_dock_date
                )),l_sys_next_date) col25, --bug3333114
                l_null_num col26,
                -- Bug 2771075. For Planned Orders, we will populate transaction_id
		-- in the disposition_name column to be consistent with Planning.
		-- p.order_number col27,
		DECODE(p.order_type, 5, to_char(p.transaction_id), p.order_number ) col27,
                l_null_num col28,
		l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                -- ship_rec_cal rearrange signs to get rid of multiply times -1
                (NVL(p.implement_quantity,0) - p.new_order_quantity)
             -- Supplier Capacity (SCLT) Changes Begin
             FROM   msc_supplies p,msc_item_hierarchy_mv MIHM
             WHERE  (p.order_type IN (5, 2)
                    OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                  AND p.order_type = 1 AND p.promised_date IS NULL))

             -- Supplier Capacity (SCLT) Accumulation Ignore Purchase Orders
             -- WHERE  p.order_type IN (5, 1, 2)
             AND    p.plan_id = p_sup_atp_info_rec.plan_id
             AND    p.sr_instance_id = p_sup_atp_info_rec.instance_id
             --AND    p.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
       -- 1214694      AND    p.organization_id = p_sup_atp_info_rec.organization_id
             AND    p.supplier_id  = p_sup_atp_info_rec.supplier_id
             AND    NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
             -- Exclude Cancelled Supplies 2460645
             AND    NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                    --consider ATP inserted POs only. Do not use Planning inserted POs as
                    -- theu would be tied to forecast
             AND    ((p.inventory_item_id = l_inv_item_id and p.record_source=2) OR
                    p.inventory_item_id in
                           (select inventory_item_id from msc_system_items msi
                            where  msi.base_item_id = l_inv_item_id
                            and    msi.plan_id = p_sup_atp_info_rec.plan_id
                            and    msi.organization_id = p_sup_atp_info_rec.organization_id
                            and    msi.base_item_id = l_inv_item_id))
             AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) --4055719 --4135752
                      <= least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date)
      --4365873
      AND    p.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
      AND    p.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
      AND    p.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
      --AND    MIHM.level_id (+) = decode(G_HIERARCHY_PROFILE,1,-1 )
      AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
      AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) >= MIHM.effective_date (+)
      AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) <= MIHM.disable_date (+)
      AND    MIHM.demand_class (+) = l_demand_class
       )
       ; -- dsting removed order by col25;
        ELSE

           -- dsting: s/d details performance enh
           INSERT INTO msc_atp_sd_details_temp (
           	ATP_Level,
           	Order_line_id,
           	Scenario_Id,
           	Inventory_Item_Id,
           	Request_Item_Id,
	        Organization_Id,
                Department_Id,
	        Resource_Id,
                Supplier_Id,
                Supplier_Site_Id,
	        From_Organization_Id,
	        From_Location_Id,
	        To_Organization_Id,
	        To_Location_Id,
	        Ship_Method,
	        UOM_code,
	        Supply_Demand_Type,
	        Supply_Demand_Source_Type,
	        Supply_Demand_Source_Type_Name,
	        Identifier1,
	        Identifier2,
	        Identifier3,
	        Identifier4,
	        Supply_Demand_Quantity,
	        Supply_Demand_Date,
	        Disposition_Type,
	        Disposition_Name,
	        Pegging_Id,
	        End_Pegging_Id,
	        creation_date,
	        created_by,
	        last_update_date,
	        last_updated_by,
	        last_update_login,
	        Unallocated_Quantity
            )

            (SELECT     p_sup_atp_info_rec.level col1,
		p_identifier col2,
                p_sup_atp_info_rec.scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
		p_sup_atp_info_rec.organization_id col6,
                l_null_num col7,
                l_null_num col8,
                p_sup_atp_info_rec.supplier_id col9,
                p_sup_atp_info_rec.supplier_site_id col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		l_uom_code col16,
		2 col17, -- supply
		l_null_num col18,
                l_null_char col19,
		p_sup_atp_info_rec.instance_id col20,
                l_null_num col21,
		l_null_num col22,
		l_null_num col23,
                cs.capacity*(1+NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                   p_sup_atp_info_rec.instance_id,
                                   p_sup_atp_info_rec.plan_id,
                                   p_sup_atp_info_rec.inventory_item_id,
                                   p_sup_atp_info_rec.organization_id,
                                   p_sup_atp_info_rec.supplier_id,
                                   p_sup_atp_info_rec.supplier_site_id,
                                   cs.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0)) *
                                   NVL(MIHM.allocation_percent/100,  --4365873
                                   /*NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(
                                                     l_instance_id,
                                                     cs.inventory_item_id,
                                                     p_sup_atp_info_rec.organization_id,
                                                     null,
                                                     null,
                                                     l_demand_class,
                                                     c.calendar_date),*/
                                                      1) col24,
		GREATEST(CS.CALENDAR_DATE,l_sys_next_date) col25, --bug3333114
                l_null_num col26,
                l_null_char col27,
                l_null_num col28,
                l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                cs.capacity*(1+NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                   p_sup_atp_info_rec.instance_id,
                                   p_sup_atp_info_rec.plan_id,
                                   p_sup_atp_info_rec.inventory_item_id,
                                   p_sup_atp_info_rec.organization_id,
                                   p_sup_atp_info_rec.supplier_id,
                                   p_sup_atp_info_rec.supplier_site_id,
                                   cs.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0))
         FROM
         (
         SELECT
            s.capacity,
	    c.calendar_date,
	    s.inventory_item_id,
	    s.sr_instance_id,
	    s.organization_id,
	    c.seq_num
                FROM   msc_calendar_dates c,
                       msc_supplier_capacities s
                WHERE  s.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
                AND    s.sr_instance_id = p_sup_atp_info_rec.instance_id
                AND    s.plan_id = p_sup_atp_info_rec.plan_id
                AND    s.organization_id = p_sup_atp_info_rec.organization_id
                AND    s.supplier_id = p_sup_atp_info_rec.supplier_id
                AND    NVL(s.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                AND    c.calendar_date BETWEEN trunc(s.from_date)
                                --AND NVL(s.to_date,l_cutoff_date)
                                AND trunc(NVL(s.to_date,least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))) --4055719
                AND    (c.seq_num IS NOT NULL or p_sup_atp_info_rec.manufacturing_cal_code = '@@@')
                AND    c.calendar_code = l_calendar_code
                AND    c.exception_set_id = l_calendar_exception_set_id
                AND    c.sr_instance_id = l_instance_id
                AND    c.calendar_date >= NVL(p_sup_atp_info_rec.sup_cap_cum_date, l_plan_start_date))CS,
         msc_item_hierarchy_mv MIHM
         WHERE
         --4365873
                cs.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
      	 AND    cs.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
      	 AND    cs.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
      	 --AND    decode(MIHM.level_id,-1,1,2) (+) = (select decode(fnd_profile.value('XXXX'),1,1,2) from dual)
      	 --AND   MIHM.level_id(+)=-1
      	 AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
      	 AND    cs.calendar_date >= MIHM.effective_date (+)
      	 AND    cs.calendar_date <= MIHM.disable_date (+)
      	 AND    MIHM.demand_class (+) = l_demand_class
                -- Supplier Capacity (SCLT) Accumulation starts from this date.
                -- AND    c.calendar_date >= l_plan_start_date -- bug 1169467
                UNION ALL
                SELECT p_sup_atp_info_rec.level col1,
                p_identifier col2,
                p_sup_atp_info_rec.scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_sup_atp_info_rec.organization_id col6,
                l_null_num col7,
                l_null_num col8,
                p_sup_atp_info_rec.supplier_id col9,
                p_sup_atp_info_rec.supplier_site_id col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                l_uom_code col16,
                1 col17, -- demand
                p.order_type col18,
                l_null_char col19,
                p_sup_atp_info_rec.instance_id col20,
                l_null_num col21,
                TRANSACTION_ID col22,
                l_null_num col23,
                -- ship_rec_cal rearrange signs to get rid of multiply times -1
                (NVL(p.implement_quantity,0) - p.new_order_quantity)*
                DECODE(DECODE(G_HIERARCHY_PROFILE,
                              --2424357
                              1, DECODE(p.DEMAND_CLASS, null, null,
                                    DECODE(l_demand_class, '-1',
                                        MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  null,
                                                  null,
                                                  p.inventory_item_id,
                                                  p.organization_id,
                                                  p.sr_instance_id,
                                                  trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                          1, p.new_ship_date,
                                                          p.new_dock_date
                                                  )),
                                                  l_level_id,
                                                   p.DEMAND_CLASS), p.DEMAND_CLASS)),
                              2, DECODE(p.CUSTOMER_ID, NULL, TO_CHAR(NULL),
                                        0, TO_CHAR(NULL),
                                                MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(
                                                  p.CUSTOMER_ID,
                                                  p.SHIP_TO_SITE_ID,
                                                  p.inventory_item_id,
                                                  p.organization_id,
                                                  p.sr_instance_id,
                                                  trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                          1, p.new_ship_date,
                                                          p.new_dock_date
                                                  )),
                                                  l_level_id,
                                                  NULL))),
                        l_demand_class, 1,
                        NULL, NVL(MIHM.allocation_percent/100,  --4365873
                        /*NULL, NVL(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p.sr_instance_id,
                                                       p.inventory_item_id ,
                                                       p.organization_id,
                                                       null,
                                                       null,
                                                       l_demand_class,
                                                       trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                          1, p.new_ship_date,
                                                          p.new_dock_date
                                                       ))),*/
                                                        1),
                        DECODE(MIHM.allocation_percent/100,
                        /*DECODE(MSC_AATP_FUNC.Get_DC_Alloc_Percent(p.sr_instance_id,
                                                    p.inventory_item_id,
                                                    p.organization_id,
                                                    null,
                                                    null,
                                                    l_demand_class,
                                                    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                                                          1, p.new_ship_date,
                                                          p.new_dock_date
                                                    ))),*/
                                NULL, 1,
                                0)) col24,
                GREATEST(trunc(Decode(p_sup_atp_info_rec.sup_cap_type, --4135752
                    1, p.new_ship_date,
                    p.new_dock_date
                )),l_sys_next_date) col25, --bug3333114
                l_null_num col26,
                -- Bug 2771075. For Planned Orders, we will populate transaction_id
		-- in the disposition_name column to be consistent with Planning.
		-- p.order_number col27,
		DECODE(p.order_type, 5, to_char(p.transaction_id), p.order_number ) col27,
                l_null_num col28,
		l_null_num col29,
		-- ship_rec_cal changes begin
		l_sysdate,
		G_USER_ID,
		l_sysdate,
		G_USER_ID,
		G_USER_ID,
		-- ship_rec_cal changes end
		-- Unallocated_Quantity
                -- ship_rec_cal rearrange signs to get rid of multiply times -1
                (NVL(p.implement_quantity,0) - p.new_order_quantity)
             -- Supplier Capacity (SCLT) Changes Begin
             FROM   msc_supplies p ,msc_item_hierarchy_mv MIHM
             WHERE  (p.order_type IN (5, 2)
                    OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                  AND p.order_type = 1 AND p.promised_date IS NULL))

             -- Supplier Capacity (SCLT) Accumulation Ignore Purchase Orders
             -- WHERE  p.order_type IN (5, 1, 2)
             AND    p.plan_id = p_sup_atp_info_rec.plan_id
             AND    p.sr_instance_id = p_sup_atp_info_rec.instance_id
             AND    p.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
       -- 1214694      AND    p.organization_id = p_sup_atp_info_rec.organization_id
             AND    p.supplier_id  = p_sup_atp_info_rec.supplier_id
             AND    NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
             -- Exclude Cancelled Supplies 2460645
             AND    NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
             AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) --4055719--4135752
                           <= least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date)
             --4365873
      AND    p.INVENTORY_ITEM_ID = MIHM.INVENTORY_ITEM_ID(+)
      AND    p.SR_INSTANCE_ID = MIHM.SR_INSTANCE_ID (+)
      AND    p.ORGANIZATION_ID = MIHM.ORGANIZATION_ID (+)
      --AND    MIHM.level_id (+) = decode(G_HIERARCHY_PROFILE,1,-1 )
      AND    decode(MIHM.level_id (+),-1,1,2) = decode(G_HIERARCHY_PROFILE,1,1,2)
      AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) >= MIHM.effective_date (+)
      AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) <= MIHM.disable_date (+)
      AND    MIHM.demand_class (+) = l_demand_class
       )
       ; -- dsting removed order by col25;
     END IF;
     --=======================================================================================================
     -- ship_rec_cal changes end
     --=======================================================================================================
     -- for period ATP
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'after insert into msc_atp_sd_details_temp');
     END IF;
     MSC_ATP_PROC.get_period_data_from_SD_temp(x_atp_period);

      l_current_atp.atp_period := x_atp_period.Period_Start_Date;
      l_current_atp.atp_qty := x_atp_period.Period_Quantity;
      -- bug 1657855, remove support for min alloc
      --l_current_atp.limit_qty := l_current_atp.atp_qty; -- 02/16

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'right after the big query');
       Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
    END IF;

    -- do backward consumption for DCi
    MSC_ATP_PROC.Atp_Backward_Consume(l_current_atp.atp_qty);

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'right after the backward consume');
       Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
    END IF;

    -- we have 3 records of tables.
    -- l_current_atp: stores the date and quantity for this demand class,
    --                and since we need to do backward consumption on this.
    -- l_current_steal_atp: stores the date and quantity from higher priority
    --                      demand class, this need to consume l_current_atp
    -- l_next_steal_atp : stores  the date and quantity for next priority
    --                    demand class to cunsume.  we need this because we may
    --                    have multiple demand classes at same priority .
    -- for example, we have DC1 in priority 1, DC21, DC22 in priority 2,
    -- DC3 in priority  3.
    -- now DC21 need to take care DC1, DC22 need to take care DC1 but not DC21,
    -- DC3 need to take care DC1, DC21, and DC22.  so if we are in the loop for
    -- DC22, than l_current_atp is the atp info for DC22,
    -- l_current_steal_atp is the atp info for DC1(which does not include DC21),
    -- and l_next_steal_atp is the stealing data that we need to take care
    -- for DC1, DC21 and DC22  when later on we move to the loop for DC3.

       -- do backward consumption if DC1 to DC(i-1) has any negative bucket,and
       -- the priority  is higher than DCi
       -- the l_current_atp is an in/out parameter

      -- for 1680719, since in hierarchy demand class we cannot
      -- judge the priority by just looking at the priority (we need
      -- the information from the parent, so the condition needs to be changed.

      IF l_level_id IN (-1, 1) THEN
        -- here is the old logic which should still be ok for level id 1 and -1
       IF (i > 1) THEN

        IF (l_demand_class_priority_tab(i) >
            l_demand_class_priority_tab (i-1)) THEN
        -- we don't need to change the l_current_steal_atp if we don't
        -- move to next priority.
        -- but we do need to change the l_current_steal_atp
        -- if we are in different priority  now.

          l_current_steal_atp := l_next_steal_atp;

          -- Added for bug 1409335. Need to initialize l_next_steal_atp
          -- otherwise quanities would be getting accumulated
          -- repeatedly.
          l_next_steal_atp := l_null_steal_atp;
        END IF;
       END IF;
      ELSE -- IF l_level_id IN (-1, 1) THEN

       IF (i > 1) THEN

        IF (l_class_tab(i) <> l_class_tab(i-1)) THEN

          -- class changed.  If priority of both classes are not the same,
          -- then we need to change the curr_steal_atp  at class level.

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'class changed');
          END IF;

          IF trunc(l_demand_class_priority_tab(i), -3) >
             trunc(l_demand_class_priority_tab (i-1), -3) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'class priority changed');
            END IF;
            l_class_curr_steal_atp := l_class_next_steal_atp;
            l_class_next_steal_atp := l_null_steal_atp;
          END IF;

          l_partner_next_steal_atp := l_null_steal_atp;
          l_partner_curr_steal_atp := l_null_steal_atp;
          l_partner_next_steal_atp := l_null_steal_atp;
          l_current_steal_atp := l_null_steal_atp;
          l_next_steal_atp := l_null_steal_atp;

        ELSE
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'same class');
          END IF;
          IF (l_partner_tab(i) <> l_partner_tab(i-1)) THEN
            -- customer changed.  If priority of both customers are not the
            -- same, we need to change the curr_steal_atp  at partner level.

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'customer changed');
            END IF;

            IF trunc(l_demand_class_priority_tab(i), -2) >
               trunc(l_demand_class_priority_tab (i-1), -2) THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'customer priority changed');
              END IF;

              l_partner_curr_steal_atp := l_partner_next_steal_atp;
              l_partner_next_steal_atp := l_null_steal_atp;
            END IF;

            l_current_steal_atp := l_null_steal_atp;
            l_next_steal_atp := l_null_steal_atp;


          ELSE
            -- same customer
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'same customer ');
            END IF;

            IF (l_demand_class_priority_tab(i) >
                l_demand_class_priority_tab (i-1)) THEN
              -- site level priority changed

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'site priority changed');
              END IF;
              l_current_steal_atp := l_next_steal_atp;
              l_next_steal_atp := l_null_steal_atp;

            END IF;
          END IF; -- IF (l_partner_tab(i) <> l_partner_tab(i-1))
        END IF; -- IF (l_class_tab(i) <> l_class_tab(i-1))

       END IF; -- IF (i > 1)

      END IF; -- IF l_level_id IN (-1, 1)
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'before we decide we need to do dc consumption');
      END IF;
      IF (i > 1) THEN
       IF (  -- this is the huge condition
             ((l_level_id IN (-1, 1)) AND
             (l_demand_class_priority_tab(i) <> l_demand_class_priority_tab(1)))
           OR
             (l_level_id in (2, 3))
          ) THEN

        -- we need to do demand class consume only if we are not in the first
        -- preferred priority

        -- bug 1413459
        -- we need to remember what's the atp picture before the
        -- demand class consumption but after it's own backward
        -- consumption.  so that we can figure out the stealing
        -- quantity correctly.
        IF (NVL(p_sup_atp_info_rec.insert_flag, 0) <>0)
           AND (l_demand_class_tab(i) = p_sup_atp_info_rec.demand_class) THEN
            l_temp_atp := l_current_atp;
        END IF;

        -- 1680719
        -- since we have hierarchy now, before we do demand class
        -- consumption for site level, we need to do the class level and
        -- partner level first

        IF l_level_id IN (2,3) THEN

          IF l_class_tab(i) <> l_class_tab(1) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'before consume l_class_curr_steal_atp');
               Print_Period_Qty('l_class_curr_steal_atp.atp_period:atp_qty = ',
			l_class_curr_steal_atp);
            END IF;

            MSC_AATP_PVT.Atp_demand_class_Consume(l_current_atp, l_class_curr_steal_atp);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'After consume l_class_curr_steal_atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_class_curr_steal_atp.atp_period:atp_qty = ',
			l_class_curr_steal_atp);
            END IF;
          END IF; --IF l_class_tab(i) <> l_class_tab(1) THEN

          -- bug 1922942: although partner_id should be unique, we introduced
          -- -1 for 'Other' which make the partner_id not unique.
          -- for example, Class1/Other and Class2/Other will have same
          -- partner_id -1. so the if condition needs to be modified.

          -- IF l_partner_tab(i) <> l_partner_tab(1) THEN

          IF (l_class_tab(i) <> l_class_tab(1)) OR
              (l_partner_tab(i) <> l_partner_tab(1)) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'before consume l_partner_curr_steal_atp');
            END IF;
            MSC_AATP_PVT.Atp_demand_class_Consume(l_current_atp, l_partner_curr_steal_atp);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'After consume l_partner_curr_steal_atp');
               Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
			l_current_atp);
               Print_Period_Qty('l_partner_curr_steal_atp.atp_period:atp_qty = ',
			l_partner_curr_steal_atp);
            END IF;
          END IF; -- IF l_partner_tab(i) <> l_partner_tab(1) THEN

        END IF; -- IF l_level_id IN (2,3)

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'Before consume current_steal_atp');
           Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		l_current_steal_atp);
        END IF;

        MSC_AATP_PVT.Atp_demand_class_Consume(l_current_atp, l_current_steal_atp);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'After consume l_current_steal_atp');
           Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
		l_current_atp);
           Print_Period_Qty('l_current_steal_atp.atp_period:atp_qty = ',
		l_current_steal_atp);
        END IF;

        -- this part is not in the original design.
        -- original design is that we will ignore the inconsistancy
        -- in the s/d and period atp for display when stealing happens, as long
        -- as we take care the stealing in the logic.
        -- but i think it is still better to put it in.
        -- and actually if we change Atp_sup_atp_info_rec.demand_class_Consume we can
        -- deal with this together.  but for now...

        -- we need to know if we need to store the stealing
        -- results in to x_atp_supply_demand and x_atp_period or not.
        -- we only do it if this is the demand class we request and
        -- insert_flag is on

        IF (NVL(p_sup_atp_info_rec.insert_flag, 0) <>0) AND
           (l_demand_class_tab(i) = p_sup_atp_info_rec.demand_class) THEN

          FOR j in 1..l_current_atp.atp_qty.COUNT LOOP

            IF l_current_atp.atp_qty(j) < l_temp_atp.atp_qty(j) THEN
              -- this is the stealing quantity in that period

              -- bug 1413459: the stealing quantity should be the current
              -- period quantity (after backward consumption, after stealing)
              -- minus the period quantity after backward consumption but
              -- before the stealing
              l_steal_period_quantity := l_current_atp.atp_qty(j) -
                                         l_temp_atp.atp_qty(j);


              MSC_SATP_FUNC.Extend_Atp_Supply_Demand(l_temp_atp_supply_demand,
                                       l_return_status);
              k := l_temp_atp_supply_demand.Level.Count;
              l_temp_atp_supply_demand.level(k) := p_sup_atp_info_rec.level;
              l_temp_atp_supply_demand.identifier(k) := p_identifier;
              l_temp_atp_supply_demand.scenario_id(k) := p_sup_atp_info_rec.scenario_id;
              l_temp_atp_supply_demand.supplier_id(k) := p_sup_atp_info_rec.supplier_id;
              l_temp_atp_supply_demand.supplier_site_id(k) := p_sup_atp_info_rec.supplier_site_id;
              l_temp_atp_supply_demand.uom(k):= l_uom_code;
              l_temp_atp_supply_demand.supply_demand_type(k) := 1;

              -- Bug 1408132 and 1416290, Need to insert type as
              -- Demand Class Consumption (45).
              l_temp_atp_supply_demand.supply_demand_source_type(k) := 45;

              l_temp_atp_supply_demand.identifier1(k) := p_sup_atp_info_rec.instance_id;
              l_temp_atp_supply_demand.supply_demand_date (k) :=
                    l_current_atp.atp_period(j);
              l_temp_atp_supply_demand.supply_demand_quantity(k) :=
                    l_steal_period_quantity;

              x_atp_period.Total_Demand_Quantity(j):=
                     x_atp_period.Total_Demand_Quantity(j) +
                     l_steal_period_quantity;

              x_atp_period.period_quantity(j):=x_atp_period.period_quantity(j)
                     + l_steal_period_quantity;

            END IF;
          END LOOP;

          --dsting
          move_SD_plsql_into_SD_temp(l_temp_atp_supply_demand);

        END IF;  -- IF (NVL(p_sup_atp_info_rec.insert_flag, 0) <>0) ....
       END IF; -- the huge condition
      END IF; -- IF (i > 1)

      ---IF l_demand_class_priority_tab(i) < l_priority THEN
      ---bug 1665110
      IF (l_demand_class <> p_sup_atp_info_rec.demand_class) THEN
        -- we need to prepare the l_next_steal_atp for next priorit

        MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_atp, l_next_steal_atp);

        -- 1680719
        IF l_level_id IN (-1, 1) THEN
          IF l_demand_class_priority_tab(i)<
             l_demand_class_priority_tab(i+1) THEN
          -- this is the last element of current priority, so we also need
          -- to add l_steal_atp into l_next_steal_atp if we can not finish
          -- the stealing at this priority

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'level = '||l_level_id);
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'before Adding Add_to_Next_Steal_Atp');
               Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
			l_next_steal_atp);
            END IF;

            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'after Add_to_Next_Steal_Atp');
               Print_Period_Qty('l_next_steal_atp.atp_period:atp_qty = ',
			l_next_steal_atp);
            END IF;

          END IF;

        ELSE -- IF l_level_id IN (-1, 1)
          -- this is for hierarchy customer level and site level
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'level = '||l_level_id);
             msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'i = '||i);
             msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_class_tab(i) = '||l_class_tab(i));
             msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'l_class_tab(i+1) = '||l_class_tab(i+1));
          END IF;
          IF (l_class_tab(i) <> l_class_tab(i+1)) THEN

            -- class changed.  If priority of both classes are not the same,
            -- then we need to change the curr_steal_atp  at class level.
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'class changed');
            END IF;

            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_partner_next_steal_atp);
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_curr_steal_atp,
                                  l_partner_next_steal_atp);
            MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_next_steal_atp,
                                  l_class_next_steal_atp);


            IF trunc(l_demand_class_priority_tab(i), -3)<
               trunc(l_demand_class_priority_tab (i+1), -3) THEN

              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_class_curr_steal_atp,
                                    l_class_next_steal_atp);

            END IF;

          ELSE

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'class the same');
            END IF;
            IF (l_partner_tab(i) <> l_partner_tab(i+1)) THEN
              -- customer changed
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'customer not the same');
              END IF;
              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);

              MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_next_steal_atp, l_partner_next_steal_atp);

              IF trunc(l_demand_class_priority_tab(i), -2)<
                 trunc(l_demand_class_priority_tab (i+1), -2) THEN
                -- customer priority changed

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'customer priority changed');
                END IF;
                MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_partner_curr_steal_atp,
                                      l_partner_next_steal_atp);

              END IF;


            ELSE
              -- same customer
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'customer the same');
              END IF;
              IF (l_demand_class_priority_tab(i)<>
                  l_demand_class_priority_tab (i+1)) THEN
                -- site level priority changed
                MSC_AATP_PVT.Add_to_Next_Steal_Atp(l_current_steal_atp, l_next_steal_atp);

              END IF;
            END IF;
          END IF;
        END IF; -- IF l_level_id IN (-1, 1)
      END IF;

      -- 1665110
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'p_sup_atp_info_rec.demand_class = '||p_sup_atp_info_rec.demand_class);
      END IF;
      EXIT WHEN (l_demand_class = p_sup_atp_info_rec.demand_class);
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'after the exit statement, so we did not exit');
      END IF;

  END LOOP;
  MSC_ATP_PROC.Atp_Accumulate(l_current_atp.atp_qty);

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'right after the Atp_Accumulate');
     Print_Period_Qty('l_current_atp.atp_period:atp_qty = ',
	l_current_atp);
  END IF;

  x_atp_info := l_current_atp;

  --4055719 , calling remove -ves
  MSC_AATP_PROC.Atp_Remove_Negatives(x_atp_period.Cumulative_Quantity, l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ' || 'Error occured in procedure Atp_Remove_Negatives');
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --4055719 , moved this code to MSC_ATP_REQ.get_supplier_atp_info
  -- get the infinite time fence date if it exists
  /*l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(null, --4055719
             null,null, p_sup_atp_info_rec.plan_id);

    IF l_infinite_time_fence_datee IS NOT NULL THEN
      -- add one more entry to indicate infinite time fence date
      -- and quantity.
      x_atp_info.atp_qty.EXTEND;
      x_atp_info.atp_period.EXTEND;
      --- bug 1657855, remove support for min alloc
      x_atp_info.limit_qty.EXTEND;

      i := x_atp_info.atp_qty.COUNT;
      x_atp_info.atp_period(i) := l_last_cap_next_date;
      x_atp_info.atp_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;
      ---x_atp_info.limit_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;


      IF NVL(p_sup_atp_info_rec.insert_flag, 0) <> 0 THEN
        -- add one more entry to indicate infinite time fence date
        -- and quantity.

        x_atp_period.Cumulative_Quantity := x_atp_info.atp_qty;

        j := x_atp_period.Level.COUNT;
        MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, l_return_status);
        j := j + 1;
        IF j > 1 THEN
          x_atp_period.Period_End_Date(j-1) := l_infinite_time_fence_date -1;
          x_atp_period.Identifier1(j) := x_atp_period.Identifier1(j-1);
          x_atp_period.Identifier2(j) := x_atp_period.Identifier2(j-1);
        END IF;

        x_atp_period.Level(j) := p_sup_atp_info_rec.level;
        x_atp_period.Identifier(j) := p_identifier;
        x_atp_period.Scenario_Id(j) := p_sup_atp_info_rec.scenario_id;
        x_atp_period.Pegging_Id(j) := NULL;
        x_atp_period.End_Pegging_Id(j) := NULL;
        x_atp_period.Supplier_Id(j) := p_sup_atp_info_rec.supplier_id;
        x_atp_period.Supplier_site_id(j) := p_sup_atp_info_rec.supplier_site_id;
        x_atp_period.Organization_id(j) := p_sup_atp_info_rec.organization_id;
        x_atp_period.Period_Start_Date(j) := l_infinite_time_fence_date;
        x_atp_period.Total_Supply_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
        x_atp_period.Total_Demand_Quantity(j) := 0;
        x_atp_period.Period_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
        x_atp_period.Cumulative_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;

     END IF;
   END IF; */
-- END IF;

END Supplier_Alloc_Cum_Atp;


PROCEDURE Get_DC_Info(
	p_instance_id	IN 	NUMBER,
	p_inv_item_id	IN 	NUMBER,
	p_org_id	IN 	NUMBER,
	p_dept_id	IN 	NUMBER,
	p_res_id	IN 	NUMBER,
	p_demand_class	IN 	VARCHAR2,
	p_request_date	IN 	DATE,
        x_level_id      OUT     NoCopy NUMBER,
	x_priority	OUT  	NoCopy NUMBER,
	x_alloc_percent	OUT 	NoCopy NUMBER,
	x_return_status	OUT 	NoCopy VARCHAR2)
IS
        l_rule_name     VARCHAR2(30);
	l_time_phase 	NUMBER;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('******** Get_DC_Info ********');
     msc_sch_wb.atp_debug('Get_DC_Info: ' || 'p_instance_id =' || p_instance_id);
     msc_sch_wb.atp_debug('Get_DC_Info: ' || 'p_inv_item_id =' || p_inv_item_id);
     msc_sch_wb.atp_debug('Get_DC_Info: ' || 'p_org_id =' || p_org_id);
     msc_sch_wb.atp_debug('Get_DC_Info: ' || 'p_dept_id =' || p_dept_id);
     msc_sch_wb.atp_debug('Get_DC_Info: ' || 'p_res_id =' || p_res_id);
     msc_sch_wb.atp_debug('Get_DC_Info: ' || 'p_demand_class =' || p_demand_class);
     msc_sch_wb.atp_debug('Get_DC_Info: ' || 'p_request_date =' || p_request_date );
  END IF;

  -- initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_inv_item_id is not null THEN
        -- Get the allocation percent for the item/demand class. If no rule found,
	-- check if a rule on the specified date exists for any demand class
	-- for the specific item, take allocation percentage as NULL.
	-- Though we will treat NULL as 1, but we need to differentiate them
	-- so as to group demands/ supplies by demand classes. - ngoel 8/31/2000.
	BEGIN
                -- Modified by NGOEL on 2/23/2001 as there may be more than 1 rule assigned
                -- to an item/org/instance combinantion at a given level based on time phase.
                --SELECT distinct allocation_rule_name
                --SELECT distinct allocation_rule_name, time_phase_id
                --bug3948494 removed distinct and introduced rownum
                SELECT allocation_rule_name, time_phase_id
                INTO   l_rule_name, l_time_phase
                FROM   msc_item_hierarchy_mv
                WHERE  inventory_item_id = p_inv_item_id
                AND    organization_id = p_org_id
      		AND    sr_instance_id = p_instance_id
      		AND    p_request_date between effective_date and disable_date
      		AND    rownum = 1 ;

		-- Changes for Bug 2384551 start
                IF (G_HIERARCHY_PROFILE = 1) THEN

                SELECT ma.priority, ma.allocation_percent/100, ma.level_id
                INTO   x_priority, x_alloc_percent, x_level_id
                FROM   msc_allocations ma
                WHERE  ma.demand_class = p_demand_class
                AND    ma.time_phase_id = l_time_phase
                AND    ma.level_id = -1;

                ELSE

                SELECT ma.priority, ma.allocation_percent/100, ma.level_id
                INTO   x_priority, x_alloc_percent, x_level_id
                FROM   msc_allocations ma
                WHERE  ma.demand_class = p_demand_class
                AND    ma.time_phase_id = l_time_phase
                AND    ma.level_id <> -1;

                END IF;
                 -- Changes for Bug 2384551 end

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
             IF G_HIERARCHY_PROFILE = 1 THEN
      		SELECT DECODE(count(allocation_percent), 0, NULL, 0)
	      	INTO   x_alloc_percent
      		FROM   msc_item_hierarchy_mv
      		WHERE  inventory_item_id = p_inv_item_id
      		AND    organization_id = p_org_id
      		AND    sr_instance_id = p_instance_id
      		AND    p_request_date between effective_date and disable_date
                AND    NVL(level_id, -1) = -1;

		x_priority := -1;
                x_level_id := -1;
             ELSIF G_HIERARCHY_PROFILE = 2 THEN

                -- this should never happen
                x_alloc_percent := NULL;
                x_priority := -1;
                x_level_id := 1;

             END IF;
	   WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Exception in Get_DC_Info');
		END IF;

		x_priority := -1;
	END;

  ELSE
        -- Get the allocation percent for the dept/res/demand class
	BEGIN
                -- Modified by NGOEL on 2/23/2001 as there may be more than 1 rule assigned
                -- to an item/org/instance combinantion at a given level based on time phase.
                --SELECT distinct allocation_rule_name
                --bug3948494 removed distinct and introduced rownum
                --SELECT distinct allocation_rule_name, time_phase_id
                SELECT allocation_rule_name, time_phase_id
                INTO   l_rule_name, l_time_phase
                FROM   msc_resource_hierarchy_mv
                WHERE  department_id = p_dept_id
                AND    resource_id = p_res_id
                AND    organization_id = p_org_id
        	AND    sr_instance_id = p_instance_id
        	AND    p_request_date between effective_date and disable_date
        	AND    rownum = 1 ;

		-- Changes for Bug 2384551  start
                IF G_HIERARCHY_PROFILE = 1 THEN

                SELECT ma.priority, ma.allocation_percent/100, ma.level_id
                INTO   x_priority, x_alloc_percent, x_level_id
                FROM   msc_allocations ma
                WHERE  ma.demand_class = p_demand_class
                AND    ma.time_phase_id = l_time_phase
                AND    ma.level_id = -1;

                ELSE

                SELECT ma.priority, ma.allocation_percent/100, ma.level_id
                INTO   x_priority, x_alloc_percent, x_level_id
                FROM   msc_allocations ma
                WHERE  ma.demand_class = p_demand_class
                AND    ma.time_phase_id = l_time_phase
                AND    ma.level_id <> -1;

                END IF;
                 -- Changes for Bug 2384551 end

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
             IF G_HIERARCHY_PROFILE = 1 THEN
      		SELECT DECODE(count(allocation_percent), 0, NULL, 0)
	      	INTO   x_alloc_percent
        	FROM   msc_resource_hierarchy_mv
        	WHERE  department_id = p_dept_id
        	AND    resource_id = p_res_id
        	AND    organization_id = p_org_id
        	AND    sr_instance_id = p_instance_id
        	AND    p_request_date between effective_date and disable_date
                AND    NVL(level_id, -1) = -1;

		x_priority := -1;
                x_level_id := -1;
             ELSIF G_HIERARCHY_PROFILE = 2 THEN

                -- this should never happen
                x_alloc_percent := NULL;
                x_priority := -1;
                x_level_id := 1;

             END IF;

	   WHEN OTHERS THEN
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Exception in Get_DC_Info');
		END IF;

		x_priority := -1;
	END;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Get_DC_Info: ' || 'Error code:' || to_char(sqlcode));
	END IF;
	x_priority := -1;
	x_alloc_percent := 0;
	x_return_status := FND_API.G_RET_STS_ERROR;
END Get_DC_Info;

PROCEDURE View_Allocation(
  p_session_id         IN    NUMBER,
  p_inventory_item_id  IN    NUMBER,
  p_instance_id        IN    NUMBER,
  p_organization_id    IN    NUMBER,
  p_department_id      IN    NUMBER,
  p_resource_id        IN    NUMBER,
  p_demand_class       IN    VARCHAR2,
  x_return_status      OUT   NoCopy VARCHAR2
)
IS
	l_plan_id			NUMBER;
	l_assign_set_id			NUMBER;
	l_msg_count			NUMBER;
	l_mode				NUMBER;
	mm				PLS_INTEGER;
	l_request_date			DATE;
	l_return_status			VARCHAR2(100);
	l_msg_data			VARCHAR2(200);
	l_atp_info			MRP_ATP_PVT.ATP_Info;
	l_atp_period			MRP_ATP_PUB.ATP_Period_Typ;
	l_atp_supply_demand		MRP_ATP_PUB.ATP_Supply_Demand_Typ;
	l_atp_rec			MRP_ATP_PUB.atp_rec_typ;
	l_atp_details			MRP_ATP_PUB.ATP_Details_Typ;
        l_atp_supply_demand_null        MRP_ATP_PUB.ATP_Supply_Demand_Typ;
        l_batchable_flag                NUMBER;
        l_max_capacity                  NUMBER;
        l_res_conversion_rate	number :=1;
        l_res_uom			varchar2(3);
        l_res_uom_type			NUMBER;
        l_plan_info_rec                 MSC_ATP_PVT.plan_info_rec;  -- added for bug 2392456

        --diag_atp
        l_get_mat_in_rec               MSC_ATP_REQ.get_mat_in_rec;


        --  Agilent Allocated ATP Based on Planning Details changes Begin
        l_demand_class                  VARCHAR2(80);
        --  Agilent Allocated ATP Based on Planning Details changes End

BEGIN
	msc_sch_wb.set_session_id(p_session_id);
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Begin View_Allocation');
	   msc_sch_wb.atp_debug('View_Allocation: ' || 'p_inventory_item_id = ' ||to_char(p_inventory_item_id));
	   msc_sch_wb.atp_debug('View_Allocation: ' || 'p_instance_id = ' ||to_char(p_instance_id));
	   msc_sch_wb.atp_debug('View_Allocation: ' || 'p_organization_id = ' ||to_char(p_organization_id));
	   msc_sch_wb.atp_debug('View_Allocation: ' || 'p_department_id = ' ||to_char(p_department_id));
	   msc_sch_wb.atp_debug('View_Allocation: ' || 'p_resource_id = ' ||to_char(p_resource_id));
           msc_sch_wb.atp_debug('View_Allocation: ' || 'p_demand_class = ' ||p_demand_class);
        END IF;

        -- Bug 2396523 : krajan : Added debug messages
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('View_Allocation: ' || 'P_DEMAND_CLASS ' || p_demand_class);
           msc_sch_wb.atp_debug('View_Allocation: ' || 'G_INV_CTP= ' || MSC_ATP_PVT.G_INV_CTP);
           msc_sch_wb.atp_debug('View_Allocation: ' || 'G_HIERARCHY_PROFILE = '|| MSC_ATP_PVT.G_HIERARCHY_PROFILE );
           msc_sch_wb.atp_debug('View_Allocation: ' || 'G_ALLOCATED_ATP = ' || MSC_ATP_PVT.G_ALLOCATED_ATP );
           msc_sch_wb.atp_debug('View_Allocation: ' || 'G_ALLOCATION_METHOD = '|| MSC_ATP_PVT.G_ALLOCATION_METHOD );
        END IF;

        -- krajan : 2400676
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('View_Allocation: ' || 'Resetting Global Error Code');
        END IF;
        MSC_SCH_WB.G_ATP_ERROR_CODE := 0;

	-- As part of ship_rec_cal. No need for SQL here. Just call the function straight.
        /*
	--Get sysdate to later pass on to the procedure.
        -- Changed to get the next working day from sysdate.
        SELECT   MSC_CALENDAR.NEXT_WORK_DAY(p_organization_id,
			p_instance_id, 1, TRUNC(sysdate))
        INTO    l_request_date
        FROM    dual;
	*/

	l_request_date := MSC_CALENDAR.NEXT_WORK_DAY(p_organization_id, p_instance_id, 1, sysdate);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('View_Allocation: ' || 'Request Date : '||to_char(l_request_date, 'DD-MON-YYYY'));
        END IF;
        -- krajan : 2400676
        IF (l_request_date = NULL) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('View_Allocation: ' || 'Request date is null');
                END IF;
                MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

	--Check if the request is for Item or Department-Resource.
	IF p_inventory_item_id IS NOT NULL THEN

		 --Get Plan Id for the item/org/instance.
                /* commented for bug 2392456
                MSC_ATP_PROC.Get_plan_Info(p_instance_id, p_inventory_item_id,
                        p_organization_id, p_demand_class, l_plan_id, l_assign_set_id);

                -- changes for bug 2392456 starts
                 MSC_ATP_PROC.Get_plan_Info(p_instance_id, p_inventory_item_id,
                        p_organization_id, p_demand_class, l_plan_info_rec);
                */
                -- New procedure for obtaining plan data : Supplier Capacity Lead Time (SCLT) proj.
                MSC_ATP_PROC.get_global_plan_info(p_instance_id, p_inventory_item_id,
                                                  p_organization_id, p_demand_class);

                l_plan_info_rec := MSC_ATP_PVT.G_PLAN_INFO_REC;
                -- End New procedure for obtaining plan data : Supplier Capacity Lead Time proj.

                l_plan_id       := l_plan_info_rec.plan_id;
                l_assign_set_id := l_plan_info_rec.assignment_set_id;
                -- changes for bug 2392456 ends

	        IF PG_DEBUG in ('Y', 'C') THEN
	           msc_sch_wb.atp_debug('View_Allocation: ' || 'Plan Id : '||to_char(l_plan_id));
	           msc_sch_wb.atp_debug('View_Allocation: ' || 'Assignment Set Id : '||to_char(l_assign_set_id));
	        END IF;

                -- krajan : 2400676
                IF (l_plan_id IS NULL) OR (l_plan_id = -1) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug ('View_Allocation: ' || 'Plan_ID is null or -1');
                        END IF;
                        MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.PLAN_NOT_FOUND;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_plan_id = -100) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug ('View_Allocation: ' || 'Plan_ID is -100 : Summary Running');
                        END IF;
                        MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.SUMM_CONC_PROG_RUNNING;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF (l_plan_id = -200) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug ('View_Allocation: ' || 'Plan_ID is -200 : Summary Running');
                        END IF;
                        MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.RUN_POST_PLAN_ALLOC;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;



		--Call Item_Alloc_Cum_Atp to get the period ATP info
		--for the item. Set insert_flag = 1, for period atp details.
		--Pass p_identifier = -1 to identify the call from this procedure,
		--so as not to do any demand class consumption/ stealing.

                IF p_demand_class IS NULL THEN

                -- To get the total ATP, demand class is passed as NULL,
                -- Pass p_scenario_id = -1 to identify the call for
                -- toatl ATP and demand class to be null

              -- Agilent Allocated ATP Based on Planning Details changes Begin

                  IF ((MSC_ATP_PVT.G_HIERARCHY_PROFILE <> 1) OR
                     ((MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                      (MSC_ATP_PVT.G_ALLOCATION_METHOD <> 1))) THEN

                       -- Original Code

                       MSC_AATP_PVT.Item_Alloc_Cum_Atp(
                                l_plan_id,
                                0,      --p_level(for top level item)
                                -1,     --p_identifier
                                -1,     --p_scenario_id - For total request
                                p_inventory_item_id,
                                p_organization_id,
                                p_instance_id,
                                p_demand_class,
                                l_request_date,
                                1,      --p_insert_flag,
                                l_atp_info,
                                l_atp_period,
                                l_atp_supply_demand,
                                --diag_atp
                                l_get_mat_in_rec,
                                p_inventory_item_id, -- time_phased_atp passing p_inventory_item_id for compilation
                                NULL); -- time_phased_atp passing null for compilation
                  ELSIF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                      (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation: before '||
                                'calling Item_Pre_Allocated_Atp for Totals');
                     END IF;
                     -- Set demand_class to NULL to obtain totals.

                   l_demand_class :=  NULL;
                     -- and MSC_AATP_REQ.Item_Pre_Allocated_Atp

                        MSC_AATP_REQ.Item_Pre_Allocated_Atp(
                                l_plan_id,
                                0,      --p_level(for top level item)
                                -1,     --p_identifier
                                -1,      --p_scenario_id - Not Used
                                p_inventory_item_id,
                                p_organization_id,
                                p_instance_id,
                                l_demand_class,
                                l_request_date,
                                1,      --p_insert_flag,
                                l_atp_info,
                                l_atp_period,
                                l_atp_supply_demand,
                                --diag_atp
                                l_get_mat_in_rec,
                                NULL,  -- p_refresh_number - For summary enhancement - Allocation WB will not use summary
                                NULL,  -- time_phased_atp - This procedure is not used
                                NULL); -- time_phased_atp - This procedure is not used
                 END IF;
                -- Agilent Allocated ATP Based on Planning Details changes End

                -- Assign null record of table to supply demand table as we
                -- don't need supply demand details in temp table.
                        l_atp_supply_demand := l_atp_supply_demand_null;
                ELSE

              -- Agilent Allocated ATP Based on Planning Details changes Begin

                  IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                      (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('View_Allocation: before calling '||
                                'Get_Hierarchy_Demand_Class for Demand Class');
                     END IF;
                     -- Code for Get_Hierarchy_Demand_Class

                   l_demand_class := MSC_AATP_FUNC.Get_Hierarchy_Demand_Class
                                      (
                                         NULL,    --partner_id
                                         NULL,    --partner_site_id
                                         --p_inventory_item_id,
                                         MSC_ATP_FUNC.Get_inv_item_id(
                                          p_instance_id,
                                          p_inventory_item_id,  -- src_inv_item
                                          null,
                                          p_organization_id  ), -- Get Inv Item
                                         p_organization_id,
                                         p_instance_id,
                                         l_request_date,
                                         1,        --p_level_id
                                         p_demand_class
                                      );
                     -- and MSC_AATP_REQ.Item_Pre_Allocated_Atp

                        MSC_AATP_REQ.Item_Pre_Allocated_Atp(
                                l_plan_id,
                                0,      --p_level(for top level item)
                                -1,     --p_identifier
                                -1,      --p_scenario_id - Not Used
                                p_inventory_item_id,
                                p_organization_id,
                                p_instance_id,
                                l_demand_class,
                                l_request_date,
                                1,      --p_insert_flag,
                                l_atp_info,
                                l_atp_period,
                                l_atp_supply_demand,
                                l_get_mat_in_rec,
                                NULL,  -- p_refresh_number - For summary enhancement - Allocation WB will not use summary
                                p_inventory_item_id,  -- time_phased_atp - Added for compilation
                                NULL); -- time_phased_atp - Added for compilation

                  -- Bug 2396523 : krajan. Commented out and added ELSIF
                  --ELSE  -- Original Code
                  ELSIF ((MSC_ATP_PVT.G_HIERARCHY_PROFILE <> 1) OR
                        ((MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                        (MSC_ATP_PVT.G_ALLOCATION_METHOD <> 1))) THEN

                            MSC_AATP_PVT.Item_Alloc_Cum_Atp(
                                l_plan_id,
                                0,      --p_level(for top level item)
                                -1,     --p_identifier
                                0,      --p_scenario_id - Not Used
                                p_inventory_item_id,
                                p_organization_id,
                                p_instance_id,
                                p_demand_class,
                                l_request_date,
                                1,      --p_insert_flag,
                                l_atp_info,
                                l_atp_period,
                                l_atp_supply_demand,
                                --diag_atp
                                l_get_mat_in_rec,
                                p_inventory_item_id, -- time_phased_atp passing p_inventory_item_id for compilation
                                NULL); -- time_phased_atp passing null for compilation
                  END IF;

                -- Agilent Allocated ATP Based on Planning Details changes End

                END IF;


	ELSIF p_inventory_item_id IS NULL THEN

                --Get Plan Id for the department/resource/org/instance.
                --In case we have multiple plans,get MRP plan as first
                --choice, for now just choose one with lowest plan id.

                BEGIN
                        SELECT  min(mdr.plan_id) as plan_id
                        INTO    l_plan_id
                        FROM    msc_department_resources mdr,
                                msc_trading_partners tp,
                                msc_apps_instances ins,
                                msc_plans plans,
                                msc_designators desig
                        WHERE   desig.inventory_atp_flag = 1
                        AND     plans.compile_designator = desig.designator
                        AND     plans.sr_instance_id = desig.sr_instance_id
                        AND     plans.organization_id = desig.organization_id
                        AND     plans.plan_completion_date is not null
                        AND     plans.data_completion_date is not null
                        AND     ins.instance_id = plans.sr_instance_id
                        AND     ins.enable_flag = 1
                        AND     tp.sr_tp_id = plans.organization_id
                        AND     tp.sr_instance_id = plans.sr_instance_id
                        AND     tp.partner_type = 3
                        AND     mdr.plan_id = plans.plan_id
                        AND     mdr.organization_id = p_organization_id
                        AND     mdr.sr_instance_id = p_instance_id
                        AND     mdr.resource_id = p_resource_id
                        AND     mdr.department_id = p_department_id
--                      AND     mdr.demand_class = p_demand_class
                        group by mdr.organization_id, mdr.sr_instance_id,
                              mdr.resource_id, mdr.department_id;--, desig.demand_class;
                EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                   msc_sch_wb.atp_debug('View_Allocation: ' || 'Plan not found ');
                                END IF;
                                MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.PLAN_NOT_FOUND;
                                RAISE FND_API.G_EXC_ERROR;
                        WHEN others THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                   msc_sch_wb.atp_debug('View_Allocation: ' || 'Error getting plan id :'||sqlcode);
                                END IF;
                                MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('View_Allocation: ' || 'Plan Id : '||to_char(l_plan_id));
                END IF;

		--Call Res_Alloc_Cum_Atp to get the period ATP info
		--for the department/resource. Set insert_flag = 1, for period atp details.
		--Pass p_identifier = -1 to identify the call from this procedure,
		--so as not to do any demand class consumption/ stealing.
                --resource bacting: find out if resource is batchable or not and the max capacity
                BEGIN
                   SELECT  batchable_flag, max_capacity, unit_of_measure, uom_class_type
                   INTO    l_batchable_flag, l_max_capacity, l_res_uom, l_res_uom_type
                   FROM    msc_department_resources
                   WHERE   department_id = p_department_id
                   AND     resource_id = p_resource_id
                   AND     organization_id = p_organization_id
                   AND     plan_id = l_plan_id
                   AND     sr_instance_id = p_instance_id ;
                EXCEPTION
                   WHEN OTHERS THEN
                      l_batchable_flag := 0;
                      l_max_capacity := 0;
                END;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('View_Allocation: ' || 'Convert res_item UOM');
                END IF;
                IF (l_batchable_flag = 1) THEN
                      BEGIN
                          SELECT conversion_rate
                          INTO   l_res_conversion_rate
                          FROM   msc_uom_conversions
                          WHERE  inventory_item_id = 0
                          AND    sr_instance_id = p_instance_id
                          AND    UOM_CODE = l_res_uom;
                      EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                                l_res_conversion_rate := 1;
                      END;

                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('View_Allocation: ' || 'l_res_conversion_rate := ' || l_res_conversion_rate);
                END IF;

              -- Agilent Allocated ATP Based on Planning Details changes Begin

                IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                    (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                    (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

                   l_demand_class := NULL;

                ELSE   -- original_code

                   l_demand_class := p_demand_class;

                END IF;

              -- Agilent Allocated ATP Based on Planning Details changes End

                IF l_demand_class IS NULL THEN

                -- To get the total ATP, demand class is passed as NULL,
                -- Pass p_scenario_id = -1 to identify the call for
                -- toatl ATP and demand class to be null

                        MSC_AATP_PVT.Res_Alloc_Cum_Atp(
                                l_plan_id,
                                0,      --p_level(for top level item)
                                -1,     --p_identifier
                                -1,     --p_scenario_id - To identify total request
                                p_department_id,
                                p_resource_id,
                                p_organization_id,
                                p_instance_id,
                                l_demand_class,
                                l_request_date,
                                1,      --p_insert_flag
                                 ---resource batching
                                l_max_capacity,
                                l_batchable_flag,
                                l_res_conversion_rate,
                                l_res_uom_type,
                                l_atp_info,
                                l_atp_period,
                                l_atp_supply_demand);

                -- Assign null record of table to supply demand table as we
                -- don't need supply demand details in temp table.

                        l_atp_supply_demand := l_atp_supply_demand_null;
                ELSE
                        MSC_AATP_PVT.Res_Alloc_Cum_Atp(
                                l_plan_id,
                                0,      --p_level(for top level item)
                                -1,     --p_identifier
                                0,      --p_scenario_id - Not Used
                                p_department_id,
                                p_resource_id,
                                p_organization_id,
                                p_instance_id,
                                l_demand_class,
                                l_request_date,
                                1,      --p_insert_flag
                                 ---resource batching
                                l_max_capacity,
                                l_batchable_flag,
                                l_res_conversion_rate,
                                l_res_uom_type,
                                l_atp_info,
                                l_atp_period,
                                l_atp_supply_demand);

                END IF;

	END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Supplier_Alloc_Cum_Atp: ');
     Print_Period_Qty('l_atp_info.atp_period:atp_qty = ',
	l_atp_info);
  END IF;

  -- krajan : 2400676
  IF (l_atp_period.period_quantity.COUNT = 0) THEN
        -- rajjain bug 2951786 05/13/2003
        MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.NO_SUPPLY_DEMAND;
        -- MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('View_Allocation: ' || 'l_atp_period is NULL');
           msc_sch_wb.atp_debug ('View_Allocation: ' || 'Error Code: ' || MSC_SCH_WB.G_ATP_ERROR_CODE);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     mm := l_atp_period.Period_Quantity.FIRST;

     WHILE mm is not null LOOP
        msc_sch_wb.atp_debug('View_Allocation: ' || 'l_atp_period.period_start_date and Period_Quantity = '||
           l_atp_period.period_start_date(mm) ||' : '|| l_atp_period.Period_Quantity(mm));
        mm := l_atp_period.Period_Quantity.Next(mm);
     END LOOP;
  END IF;

	/* rajjain 01/29/2003 begin Bug 2737596
	   This call is not needed now. Now we directly call PUT_SD_DATA
	   and PUT_PERIOD_DATA from this procedure.

	--Call procedure to insert l_atp_period
	--into mrp_atp_details_temp table.

	MSC_ATP_UTILS.put_into_temp_table(
		NULL,		--x_dblink
		p_session_id,
		l_atp_rec,
		l_atp_supply_demand,
		l_atp_period,
		l_atp_details,
		l_mode,
		x_return_status,
		l_msg_data,
		l_msg_count);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug ('View_Allocation: ' || 'Something wrong in call to PUT_INTO_TEMP_TABLE');
                END IF;
                MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;*/

         -- rajjain 01/29/2003 begin Bug 2737596
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('View_Allocation: ' || 'l_atp_supply_demand.level.COUNT: ' || l_atp_supply_demand.level.COUNT);
         END IF;

         MSC_ATP_UTILS.PUT_SD_DATA(l_atp_supply_demand, NULL, p_session_id);

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('View_Allocation: ' || ' Inserted supply demand  records ');
         END IF;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('View_Allocation: ' || 'l_atp_period.level.count: ' || l_atp_period.level.count);
         END IF;

         MSC_ATP_UTILS.PUT_PERIOD_DATA(l_atp_period, NULL, p_session_id);

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('View_Allocation: ' || ' Inserted period records ');
         END IF;
         -- rajjain 01/29/2003 end Bug 2737596

-- krajan : 2400614
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
        -- ATP ERROR CODE WILL BE SET before this exception is raised
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Error in View_Allocation: Expected Error Raised');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (MSC_SCH_WB.G_ATP_ERROR_CODE = 0) THEN
                MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF;

WHEN  MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Error in View_Allocation: Invalid Objects Found');
        END IF;
        MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.ATP_INVALID_OBJECTS;
        x_return_status := FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Error in View_Allocation');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (MSC_SCH_WB.G_ATP_ERROR_CODE = 0) THEN
                MSC_SCH_WB.G_ATP_ERROR_CODE := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
        END IF;

END View_allocation;


PROCEDURE Stealing (
               p_atp_record             IN OUT  NoCopy MRP_ATP_PVT.AtpRec,
               p_parent_pegging_id      IN      NUMBER,
               p_scenario_id            IN      NUMBER,
               p_level                  IN      NUMBER,
               p_search                 IN      NUMBER,
               p_plan_id                IN      NUMBER,
               p_net_demand             IN OUT  NoCopy NUMBER,
               x_total_mem_stealing_qty OUT     NOCOPY NUMBER, -- For time_phased_atp
               x_total_pf_stealing_qty  OUT     NOCOPY NUMBER, -- For time_phased_atp
               x_atp_supply_demand      OUT     NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_atp_period             OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
               x_return_status          OUT     NoCopy VARCHAR2,
               p_refresh_number         IN             NUMBER    -- For summary enhancement
)
IS
l_requested_ship_date          date;
l_atp_date_this_level          date;
l_atp_date_quantity_this_level number;
--l_requested_date_quantity      number;
l_atp_period                   MRP_ATP_PUB.ATP_Period_Typ;
l_atp_supply_demand            MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_pegging_rec                  mrp_atp_details_temp%ROWTYPE;
l_demand_class_tab             MRP_ATP_PUB.char80_arr
                                   := MRP_ATP_PUB.char80_arr();
l_demand_class_tab_new          MRP_ATP_PUB.char80_arr
                                   := MRP_ATP_PUB.char80_arr();--6359986
l_demand_class_priority_tab    MRP_ATP_PUB.number_arr
                                   := MRP_ATP_PUB.number_arr();
l_dmd_class_priority_tab_new MRP_ATP_PUB.number_arr
                                   := MRP_ATP_PUB.number_arr();

l_allocation_percent_tab	MRP_ATP_PUB.number_arr
       		                            := MRP_ATP_PUB.number_arr();
l_inv_item_id                  NUMBER;
l_demand_class                 VARCHAR2(30);
l_atp_insert_rec	       MRP_ATP_PVT.AtpRec;
l_inv_item_name                varchar2(250); --bug 2246200
l_org_code                     varchar2(7);
l_pegging_id                   number;
l_atp_pegging_id               number;
l_demand_id                    number;
l_priority                     number;
l_level_id                     number;
l_class                        varchar2(30);
l_partner_id                   number;

--  Agilent Allocated ATP Based on Planning Details changes
l_stealing_quantity            NUMBER;
--diag_atp
L_GET_MAT_IN_REC               MSC_ATP_REQ.GET_MAT_IN_REC;
l_get_mat_out_rec              MSC_ATP_REQ.get_mat_out_rec;

l_item_info_rec                MSC_ATP_PVT.item_attribute_rec;

-- time_phased_atp
l_time_phased_atp               VARCHAR2(1) := 'N';
l_mem_stealing_qty              NUMBER := 0;
l_pf_stealing_qty               NUMBER := 0;
l_atf_date_qty                  NUMBER;
l_pf_item_id                    NUMBER;
l_mat_atp_info_rec              MSC_ATP_REQ.Atp_Info_Rec;
l_process_item_id               NUMBER;
l_return_status                 VARCHAR2(1);
l_item_to_use                   NUMBER;

BEGIN

  -- Loop through the demand_class and do a single level check for each of them
  -- If partial quantity is available, insert that into the details.
  -- Keep decrementing the net_demand and exit if it is <= 0
  -- If the net_demand is still > 0, pass that back to the calling routing

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('********* Begin Stealing ************');
  END IF;

  /* time_phased_atp changes begin
     initialize variables*/
  x_total_mem_stealing_qty        := 0;
  x_total_pf_stealing_qty         := 0;

  IF (p_atp_record.inventory_item_id <> p_atp_record.request_item_id) and
         p_atp_record.atf_date is not null THEN
        l_time_phased_atp := 'Y';
        l_process_item_id := p_atp_record.request_item_id;
        l_pf_item_id := MSC_ATP_PVT.G_ITEM_INFO_REC.product_family_id;
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Stealing: ' || 'Time Phased ATP = ' || l_time_phased_atp);
                msc_sch_wb.atp_debug('Stealing: ' || 'ATF Date = ' || p_atp_record.atf_date);
                msc_sch_wb.atp_debug('Stealing: ' || 'l_pf_item_id = ' || l_pf_item_id);
        END IF;
  ELSE
        l_process_item_id := p_atp_record.inventory_item_id;
  END IF;
  -- time_phased_atp changes end

  /* Modularize Item and Org Info */
  MSC_ATP_PROC.get_global_item_info(p_atp_record.instance_id,
                                      ---bug 3917625: Pass in the real plan id
                                       --  -1,
                                       p_plan_id,
                                       l_process_item_id,
                                       p_atp_record.organization_id,
                                       l_item_info_rec );
  l_inv_item_id := MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id;
  /*l_inv_item_id := MSC_ATP_FUNC.get_inv_item_id (p_atp_record.instance_id,
                                                p_atp_record.request_item_id,
                                                null,
                                                p_atp_record.organization_id);
   Modularize Item and Org Info */

  /* New allocation logic for time_phased_atp changes begin */
  IF l_time_phased_atp = 'Y' THEN
        IF p_atp_record.requested_ship_date <= p_atp_record.atf_date THEN
            IF MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF = 'Y' THEN
                l_item_to_use := l_inv_item_id;
            ELSE
                l_item_to_use := l_pf_item_id;
            END IF;
        ELSE
            IF MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF = 'Y' THEN
                l_item_to_use := l_pf_item_id;
            ELSE
                l_item_to_use := l_inv_item_id;
            END IF;
        END IF;
  ELSE
        l_item_to_use := l_inv_item_id;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('ATP_Check: ' || 'p_atp_record.requested_ship_date = '||p_atp_record.requested_ship_date);
   msc_sch_wb.atp_debug('ATP_Check: ' || 'Item to be used = '||l_item_to_use);
  END IF;
  /* New allocation logic for time_phased_atp changes end */

  BEGIN

   -- Changes for Bug 2384551 start
  IF G_HIERARCHY_PROFILE = 1 THEN

  SELECT mv.priority, mv.level_id, mv.class, mv.partner_id
  INTO   l_priority, l_level_id, l_class, l_partner_id
  FROM   msc_item_hierarchy_mv mv
  WHERE  mv.inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
  AND    mv.organization_id = p_atp_record.organization_id
  AND    mv.sr_instance_id = p_atp_record.instance_id
  AND    p_atp_record.requested_ship_date BETWEEN effective_date
                                          AND disable_date
  AND    mv.demand_class = p_atp_record.demand_class
  AND    mv.level_id = -1;

  ELSE

  SELECT mv.priority, mv.level_id, mv.class, mv.partner_id
  INTO   l_priority, l_level_id, l_class, l_partner_id
  FROM   msc_item_hierarchy_mv mv
  WHERE  mv.inventory_item_id = l_item_to_use /* New allocation logic for time_phased_atp changes*/
  AND    mv.organization_id = p_atp_record.organization_id
  AND    mv.sr_instance_id = p_atp_record.instance_id
  AND    p_atp_record.requested_ship_date BETWEEN effective_date
                                          AND disable_date
  AND    mv.demand_class = p_atp_record.demand_class
  AND    mv.level_id <> -1;

  END IF;
   -- Changes for Bug 2384551 end

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Stealing: ' || 'No Data found ');
      END IF;
      l_priority := NULL;
      l_level_id := NULL;
      l_partner_id := NULL;
      l_class := NULL;
  END ;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Stealing: ' || 'l_priority = '||l_priority);
     msc_sch_wb.atp_debug('Stealing: ' || 'l_level_id = '||l_level_id);
     msc_sch_wb.atp_debug('Stealing: ' || 'l_partner_id = '||l_partner_id);
     msc_sch_wb.atp_debug('Stealing: ' || 'l_class = '||l_class);
     msc_sch_wb.atp_debug('Stealing: ' || 'before finding the lower priority dc ');
  END IF;

  IF l_level_id = -1 THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Stealing: ' || 'l_level_id = '||l_level_id);
    END IF;

    SELECT mv.demand_class, mv.priority, mv.allocation_percent
    BULK COLLECT INTO l_demand_class_tab_new, l_dmd_class_priority_tab_new, l_allocation_percent_tab	--6359986
    FROM   msc_item_hierarchy_mv mv
    WHERE  mv.inventory_item_id = l_item_to_use -- time_phased_atp
    AND    mv.organization_id = p_atp_record.organization_id
    AND    mv.sr_instance_id = p_atp_record.instance_id
    AND    p_atp_record.requested_ship_date BETWEEN effective_date
                                            AND disable_date
    AND    mv.priority  > l_priority
    AND    mv.level_id = l_level_id
    ORDER BY mv.priority asc , mv.allocation_percent desc ;

  ELSIF l_level_id = 1 THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Stealing: ' || 'l_level_id = '||l_level_id);
    END IF;

    SELECT mv.demand_class, mv.priority, mv.allocation_percent
    BULK COLLECT INTO l_demand_class_tab_new, l_dmd_class_priority_tab_new, l_allocation_percent_tab	--6359986
    FROM   msc_item_hierarchy_mv mv
    WHERE  mv.inventory_item_id = l_item_to_use -- time_phased_atp
    AND    mv.organization_id = p_atp_record.organization_id
    AND    mv.sr_instance_id = p_atp_record.instance_id
    AND    p_atp_record.requested_ship_date BETWEEN effective_date
                                            AND disable_date
    AND    mv.priority  > l_priority
    AND    mv.level_id = l_level_id
    ORDER BY mv.priority  , mv.class  ;

  ELSIF l_level_id = 2 THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Stealing: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT mv1.demand_class, mv1.priority, mv1.allocation_percent
    BULK COLLECT INTO l_demand_class_tab_new, l_dmd_class_priority_tab_new,l_allocation_percent_tab	--6359986
    FROM   msc_item_hierarchy_mv mv1
    WHERE  mv1.inventory_item_id = l_item_to_use -- time_phased_atp
    AND    mv1.organization_id = p_atp_record.organization_id
    AND    mv1.sr_instance_id = p_atp_record.instance_id
    AND    p_atp_record.requested_ship_date BETWEEN mv1.effective_date
                                            AND mv1.disable_date
    AND    mv1.priority  > l_priority
    AND    mv1.level_id = l_level_id
    AND    NOT (trunc(mv1.priority, -3) = trunc(l_priority, -3)
            AND (mv1.class <> l_class))
--    ORDER BY mv1.priority asc, mv1.allocation_percent desc;
      ORDER BY trunc(mv1.priority, -3), mv1.class ,
               trunc(mv1.priority, -2), mv1.partner_id;

  ELSIF l_level_id = 3 THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Stealing: ' || 'l_level_id = '||l_level_id);
    END IF;
    SELECT mv1.demand_class, mv1.priority, mv1.allocation_percent
    BULK COLLECT INTO l_demand_class_tab_new, l_dmd_class_priority_tab_new,l_allocation_percent_tab	--6359986
    FROM   msc_item_hierarchy_mv mv1
    WHERE  mv1.inventory_item_id = l_item_to_use -- time_phased_atp
    AND    mv1.organization_id = p_atp_record.organization_id
    AND    mv1.sr_instance_id = p_atp_record.instance_id
    AND    p_atp_record.requested_ship_date BETWEEN mv1.effective_date
                                            AND mv1.disable_date
    AND    mv1.priority  > l_priority
    AND    mv1.level_id = l_level_id
    AND    NOT (trunc(mv1.priority, -3) = trunc(l_priority, -3)
            AND (mv1.class <> l_class))
    AND    NOT (trunc(mv1.priority, -2) = trunc(l_priority, -2)
            AND (mv1.class = l_class)
            AND (mv1.partner_id <> l_partner_id))
--    ORDER BY mv1.priority asc, mv1.allocation_percent desc;
    ORDER BY trunc(mv1.priority, -3), mv1.class ,
             trunc(mv1.priority, -2), mv1.partner_id,
             mv1.priority, mv1.partner_site_id;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Stealing: ' || 'l_demand_class_tab_new.count = '||l_demand_class_tab_new.count);--6359986
  END IF;
  --diag_atp
  l_get_mat_in_rec.rounding_control_flag := MSC_ATP_PVT.G_ITEM_INFO_REC.rounding_control_type;
  l_get_mat_in_rec.dest_inv_item_id := l_inv_item_id;
--6359986 start
--bug5974491:Others with allocation 0% will be considered valid or invalid demand class

  FOR i in 1..l_demand_class_tab_new.COUNT LOOP


  IF (REPLACE(l_demand_class_tab_new(i),FND_GLOBAL.LOCAL_CHR(13),' ') in  ('-1','-1 -1 -1','-1 -1') ) then


        IF(MSC_ATP_PVT.G_ZERO_ALLOCATION_PERC = 'N') then
         IF l_allocation_percent_tab(i) <> 0 THEN
            l_demand_class_tab.EXTEND;
            l_demand_class_priority_tab.EXTEND;
            l_demand_class_tab(i) := l_demand_class_tab_new(i);
            l_demand_class_priority_tab(i) := l_dmd_class_priority_tab_new(i);
          END IF;
        ELSE
            l_demand_class_tab.EXTEND;
            l_demand_class_priority_tab.EXTEND;
            l_demand_class_tab(i) := l_demand_class_tab_new(i);
            l_demand_class_priority_tab(i) := l_dmd_class_priority_tab_new(i);
        END IF;
  ELSE

          l_demand_class_tab.EXTEND;
          l_demand_class_priority_tab.EXTEND;
          l_demand_class_tab(i) := l_demand_class_tab_new(i);
          l_demand_class_priority_tab(i) := l_dmd_class_priority_tab_new(i);
  END IF;

  END LOOP; --6359986 end

  FOR i in 1..l_demand_class_tab.COUNT LOOP
        l_demand_class := l_demand_class_tab(i);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Stealing: ' || 'Inside the loop of demand class');
           msc_sch_wb.atp_debug('Stealing: ' || 'l_demand_class'||l_demand_class);
        END IF;

        -- time_phased_atp changes begin
        l_mat_atp_info_rec.instance_id                       := p_atp_record.instance_id;
        l_mat_atp_info_rec.plan_id                           := p_plan_id;
        l_mat_atp_info_rec.level                             := p_level + 1;
        l_mat_atp_info_rec.identifier                        := p_atp_record.identifier;
        l_mat_atp_info_rec.scenario_id                       := p_scenario_id;
        l_mat_atp_info_rec.inventory_item_id                 := p_atp_record.inventory_item_id;
        l_mat_atp_info_rec.request_item_id                   := p_atp_record.request_item_id;
        l_mat_atp_info_rec.organization_id                   := p_atp_record.organization_id;
        l_mat_atp_info_rec.requested_date                    := p_atp_record.requested_ship_date;
        l_mat_atp_info_rec.quantity_ordered                  := p_net_demand;
        l_mat_atp_info_rec.demand_class                      := l_demand_class;
        l_mat_atp_info_rec.insert_flag                       := p_atp_record.insert_flag;
        l_mat_atp_info_rec.rounding_control_flag             := l_get_mat_in_rec.rounding_control_flag;
        l_mat_atp_info_rec.dest_inv_item_id                  := l_get_mat_in_rec.dest_inv_item_id;
        l_mat_atp_info_rec.infinite_time_fence_date          := l_get_mat_in_rec.infinite_time_fence_date;
        l_mat_atp_info_rec.plan_name                         := l_get_mat_in_rec.plan_name;
        l_mat_atp_info_rec.optimized_plan                    := l_get_mat_in_rec.optimized_plan;
        l_mat_atp_info_rec.requested_date_quantity           := null;
        l_mat_atp_info_rec.atp_date_this_level               := null;
        l_mat_atp_info_rec.atp_date_quantity_this_level      := null;
        l_mat_atp_info_rec.substitution_window               := null;
        l_mat_atp_info_rec.atf_date                          := p_atp_record.atf_date;   -- For time_phased_atp
        l_mat_atp_info_rec.refresh_number                    := p_refresh_number;   -- For summary enhancement
        l_mat_atp_info_rec.shipping_cal_code                 := p_atp_record.shipping_cal_code; -- Bug 3371817

        MSC_ATP_REQ.Get_Material_Atp_Info(
                l_mat_atp_info_rec,
                l_atp_period,
                l_atp_supply_demand,
                x_return_status);

        l_atf_date_qty                               := l_mat_atp_info_rec.atf_date_quantity;
        l_atp_date_this_level                        := l_mat_atp_info_rec.atp_date_this_level;
        l_atp_date_quantity_this_level               := l_mat_atp_info_rec.atp_date_quantity_this_level;
        l_get_mat_out_rec.atp_rule_name              := l_mat_atp_info_rec.atp_rule_name;
        l_get_mat_out_rec.infinite_time_fence_date   := l_mat_atp_info_rec.infinite_time_fence_date;
        p_atp_record.requested_date_quantity         := l_mat_atp_info_rec.requested_date_quantity;

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Back in Stealing');
	END IF;
        -- time_phased_atp changes end

        -- 1430561: move the p_net_demand calculation to the end so that
        -- we insert the right demand quantity
        -- p_net_demand := (p_net_demand - greatest(l_requested_date_quantity, 0)) ;

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Stealing: ' || 'p_net_demand = '||to_char(p_net_demand));
	END IF;
        -- if we don't have atp for this demand class , don't bother
        -- generate pegging tree, demand record.

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Stealing: ' || 'p_atp_record.requested_date_quantity = '||
                     p_atp_record.requested_date_quantity);
	END IF;

        IF p_atp_record.requested_date_quantity > 0 THEN

            -- time_phased_atp changes begin
            IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
                (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) ) THEN

               IF l_time_phased_atp = 'N' THEN
                       l_stealing_quantity :=  LEAST(
                                                p_atp_record.requested_date_quantity,
                                                p_net_demand);
                                                --p_atp_record.quantity_ordered);

                       MSC_ATP_DB_UTILS.Add_Stealing_Supply_Details (
                                        p_plan_id,
                                        -- rajjain 07/18/2003 bug 3010846
                                        -- pass component's sales order line id
                                        --p_atp_record.identifier,
                                        p_atp_record.demand_source_line,
                                        --p_atp_record.inventory_item_id,
                                        l_inv_item_id,
                                        p_atp_record.organization_id,
                                        p_atp_record.instance_id,
                                        l_stealing_quantity,
                                        p_atp_record.demand_class,
                                        l_demand_class,
                                        p_atp_record.requested_ship_date,
                                        l_demand_id,
                                        p_refresh_number,
                                        p_atp_record.ato_model_line_id,-- For summary enhancement
                                        p_atp_record.demand_source_type,  --cmro
                                        --bug3684383
                                        p_atp_record.order_number);
               ELSE
                       IF p_atp_record.requested_ship_date <= p_atp_record.atf_date THEN
                                l_mem_stealing_qty :=  LEAST(
                                                p_atp_record.requested_date_quantity,
                                                p_net_demand);
                       ELSE
                                IF (p_atp_record.requested_date_quantity - NVL(l_atf_date_qty, 0)) > p_net_demand THEN
                                        l_pf_stealing_qty := p_net_demand;
                                        l_mem_stealing_qty := 0;
                                ELSE
                                        l_pf_stealing_qty := p_atp_record.requested_date_quantity - NVL(l_atf_date_qty, 0);
                                        l_mem_stealing_qty := LEAST(NVL(l_atf_date_qty, 0), (p_net_demand - l_pf_stealing_qty));
                                END IF;
                       END IF;

                       -- get family item's dest id
                       l_pf_item_id := MSC_ATP_FUNC.get_inv_item_id (
                                                p_atp_record.instance_id,
                                                p_atp_record.inventory_item_id,
                                                null,
                                                p_atp_record.organization_id
                                             );
                       MSC_ATP_PF.Add_PF_Stealing_Supply_Details (
                                        p_plan_id,
                                        p_atp_record.demand_source_line,
                                        l_inv_item_id,
                                        l_pf_item_id,
                                        p_atp_record.organization_id,
                                        p_atp_record.instance_id,
                                        l_mem_stealing_qty,
                                        l_pf_stealing_qty,
                                        p_atp_record.demand_class,
                                        l_demand_class,
                                        p_atp_record.requested_ship_date,
                                        p_atp_record.atf_date,
                                        p_refresh_number, -- for summary enhancement
                                        l_demand_id,
                                        p_atp_record.ato_model_line_id,
                                        p_atp_record.demand_source_type,--cmro
                                        --bug3684383
                                        p_atp_record.order_number,
                                        l_return_status);
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Stealing: ' || 'Error occured in procedure Add_PF_Stealing_Supply_Details');
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
               END IF;
               -- time_phased_atp changes end

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Stealing Supply Id : ' || l_demand_id);
               END IF;

            ELSIF l_time_phased_atp = 'Y' THEN
                IF p_atp_record.requested_ship_date <= p_atp_record.atf_date THEN
                        l_mem_stealing_qty :=  LEAST(
                                        p_atp_record.requested_date_quantity,
                                        p_net_demand);
                ELSE
                        IF (p_atp_record.requested_date_quantity - NVL(l_atf_date_qty, 0)) > p_net_demand THEN
                                l_pf_stealing_qty := p_net_demand;
                                l_mem_stealing_qty := 0;
                        ELSE
                                l_pf_stealing_qty := p_atp_record.requested_date_quantity - NVL(l_atf_date_qty, 0);
                                l_mem_stealing_qty := LEAST(NVL(l_atf_date_qty, 0), (p_net_demand - l_pf_stealing_qty));
                        END IF;
                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Stealing: l_mem_stealing_qty = ' || l_mem_stealing_qty);
                  msc_sch_wb.atp_debug('Stealing: l_pf_stealing_qty = ' || l_pf_stealing_qty);
                END IF;
            END IF;

            x_total_mem_stealing_qty    := x_total_mem_stealing_qty + l_mem_stealing_qty;
            x_total_pf_stealing_qty     := x_total_pf_stealing_qty + l_pf_stealing_qty;
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Stealing: x_total_mem_stealing_qty = ' || x_total_mem_stealing_qty);
                msc_sch_wb.atp_debug('Stealing: x_total_pf_stealing_qty = ' || x_total_pf_stealing_qty);
            END IF;
            -- time_phased_atp changes end

            -- populate insert rec to pegging tree for this demand
            -- for performance reason, we call these function here and
            -- then populate the pegging tree with the values

            /* Modularize Item and Org Info */
            l_inv_item_name := MSC_ATP_PVT.G_ITEM_INFO_REC.item_name;
            /*l_inv_item_name := MSC_ATP_FUNC.get_inv_item_name(p_atp_record.instance_id,
                                      p_atp_record.inventory_item_id,
                                      p_atp_record.organization_id);
             Modularize Item and Org Info */

            /* Modularize Item and Org Info */
            MSC_ATP_PROC.get_global_org_info (p_atp_record.instance_id,
                                 p_atp_record.organization_id );
            l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Stealing: ' || 'Modular Use Org_code : '||l_org_code);
            END IF;
            /*l_org_code := MSC_ATP_FUNC.get_org_code(p_atp_record.instance_id,
                                         p_atp_record.organization_id);
             Modularize Item and Org Info */

            l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
            l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
            -- l_pegging_rec.parent_pegging_id:= l_pegging_id;
            l_pegging_rec.parent_pegging_id:= p_parent_pegging_id;
            l_pegging_rec.atp_level:= p_level + 1;
            l_pegging_rec.organization_id:= p_atp_record.organization_id;
            l_pegging_rec.organization_code:= l_org_code;
            l_pegging_rec.identifier1:= p_atp_record.instance_id;
            l_pegging_rec.identifier2 := p_plan_id;

            -- Bug 1419121, Insert Demand id to be used while deleting.

            l_pegging_rec.identifier3 := l_demand_id;
            --l_pegging_rec.identifier3 := NULL;

            -- time_phased_atp changes begin
            IF l_time_phased_atp = 'Y' and p_atp_record.requested_ship_date <= p_atp_record.atf_date THEN
                    l_pegging_rec.inventory_item_id:= p_atp_record.request_item_id;
                    l_pegging_rec.inventory_item_name := l_inv_item_name;
            ELSE
                    l_pegging_rec.inventory_item_id:= p_atp_record.inventory_item_id;
                    l_pegging_rec.inventory_item_name := MSC_ATP_FUNC.get_inv_item_name(
                                                            p_atp_record.instance_id,
                                                            p_atp_record.inventory_item_id,
                                                            p_atp_record.organization_id
                                                         );
            END IF;
            l_pegging_rec.aggregate_time_fence_date:= p_atp_record.atf_date;
            l_pegging_rec.request_item_id:= p_atp_record.request_item_id;
            -- time_phased_atp changes end

            l_pegging_rec.resource_id := NULL;
            l_pegging_rec.resource_code := NULL;
            l_pegging_rec.department_id := NULL;
            l_pegging_rec.department_code := NULL;
            l_pegging_rec.supplier_id := NULL;
            l_pegging_rec.supplier_name := NULL;
            l_pegging_rec.supplier_site_id := NULL;
            l_pegging_rec.supplier_site_name := NULL;
            l_pegging_rec.scenario_id:= p_scenario_id;
            l_pegging_rec.supply_demand_source_type:= MSC_ATP_PVT.ATP;
            l_pegging_rec.supply_demand_quantity:=
                            p_atp_record.requested_date_quantity;
            l_pegging_rec.supply_demand_date:= p_atp_record.requested_ship_date;
            l_pegging_rec.supply_demand_type:= 2;
            l_pegging_rec.source_type := 0;

            l_pegging_rec.char1 := l_demand_class;

            -- bug 1527660
            --l_pegging_rec.allocated_quantity :=
            --                l_atp_insert_rec.quantity_ordered;
            --bug3830147 Earlier allocated_quantity was getting passed as Null always.
            -- Populating it with correct stealing qty so that it can be used for
            -- workflow notification.
            IF l_time_phased_atp = 'Y' THEN
               l_pegging_rec.allocated_quantity := l_mem_stealing_qty + l_pf_stealing_qty;

            ELSE
               l_pegging_rec.allocated_quantity := LEAST(
                                                    p_atp_record.requested_date_quantity,
                                                    p_net_demand);
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Stealing: l_pegging_rec.allocated_quantity  = ' ||l_pegging_rec.allocated_quantity);
            END IF;
	    l_pegging_rec.component_identifier :=
                         NVL(p_atp_record.component_identifier, MSC_ATP_PVT.G_COMP_LINE_ID);

            -- for demo:1153192
            --optional_fw only if profile is set to 'N' populate constraint
            IF ((p_search = 1)
                   AND ( p_atp_record.quantity_ordered >=
                        l_mat_atp_info_rec.requested_date_quantity)) AND MSC_ATP_PVT.G_FORWARD_ATP = 'N' THEN
                  l_pegging_rec.constraint_flag := 'Y';
            ELSE
                  l_pegging_rec.constraint_flag := 'N';

            END IF;

            --diag_atp
            l_pegging_rec.plan_name := p_atp_record.plan_name;
            l_pegging_rec.required_quantity:= p_net_demand;
            l_pegging_rec.required_date := p_atp_record.requested_ship_date;
            l_pegging_rec.infinite_time_fence := l_get_mat_out_rec.infinite_time_fence_date;
            l_pegging_rec.atp_rule_name := l_get_mat_out_rec.atp_rule_name;
            l_pegging_rec.rounding_control := MSC_ATP_PVT.G_ITEM_INFO_REC.rounding_control_type;
            l_pegging_rec.atp_flag := MSC_ATP_PVT.G_ITEM_INFO_REC.atp_flag;
            l_pegging_rec.atp_component_flag := MSC_ATP_PVT.G_ITEM_INFO_REC.atp_comp_flag;
            l_pegging_rec.pegging_type := 3; ---atp supply node
            l_pegging_rec.postprocessing_lead_time := MSC_ATP_PVT.G_ITEM_INFO_REC.post_pro_lt;
            l_pegging_rec.preprocessing_lead_time := MSC_ATP_PVT.G_ITEM_INFO_REC.pre_pro_lt;
            l_pegging_rec.fixed_lead_time := MSC_ATP_PVT.G_ITEM_INFO_REC.fixed_lt;
            l_pegging_rec.variable_lead_time := MSC_ATP_PVT.G_ITEM_INFO_REC.variable_lt;
            l_pegging_rec.weight_capacity := MSC_ATP_PVT.G_ITEM_INFO_REC.unit_weight;
            l_pegging_rec.volume_capacity := MSC_ATP_PVT.G_ITEM_INFO_REC.unit_volume;
            l_pegging_rec.weight_uom := MSC_ATP_PVT.G_ITEM_INFO_REC.weight_uom;
            l_pegging_rec.volume_uom := MSC_ATP_PVT.G_ITEM_INFO_REC.volume_uom;
            l_pegging_rec.allocation_rule := MSC_ATP_PVT.G_ALLOCATION_RULE_NAME;

            l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;     -- for summary enhancement
            l_pegging_rec.demand_class := l_demand_class;
            -- Bug 3826234 start
            IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('ATP_Check: ' || '----------- Calendars passed to Pegging -----------------');
              msc_sch_wb.atp_debug('ATP_Check: ' || 'shipping_cal_code = '      ||p_atp_record.shipping_cal_code);
              msc_sch_wb.atp_debug('ATP_Check: ' || 'receiving_cal_code = '     ||p_atp_record.receiving_cal_code);
              msc_sch_wb.atp_debug('ATP_Check: ' || 'intransit_cal_code = '     ||p_atp_record.intransit_cal_code);
              msc_sch_wb.atp_debug('ATP_Check: ' || 'manufacturing_cal_code = ' ||p_atp_record.manufacturing_cal_code);
              msc_sch_wb.atp_debug('ATP_Check: ' || 'to_organization_id = ' ||p_atp_record.to_organization_id);
            END IF;
            IF p_parent_pegging_id = MSC_ATP_PVT.G_DEMAND_PEGGING_ID THEN
               l_pegging_rec.shipping_cal_code      :=  p_atp_record.shipping_cal_code;
               l_pegging_rec.receiving_cal_code     :=  p_atp_record.receiving_cal_code;
               l_pegging_rec.intransit_cal_code     :=  p_atp_record.intransit_cal_code;
               l_pegging_rec.manufacturing_cal_code :=  p_atp_record.manufacturing_cal_code;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check: ' || 'Inside IF');
               END IF;
            ELSIF NVL(p_atp_record.to_organization_id,p_atp_record.organization_id)
                                                             <> p_atp_record.organization_id THEN
               l_pegging_rec.shipping_cal_code      :=  p_atp_record.shipping_cal_code;
               l_pegging_rec.receiving_cal_code     :=  p_atp_record.receiving_cal_code;
               l_pegging_rec.intransit_cal_code     :=  p_atp_record.intransit_cal_code;
               l_pegging_rec.manufacturing_cal_code :=  NULL;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check: ' || 'Inside ELSIF');
               END IF;
            ELSE
               l_pegging_rec.manufacturing_cal_code :=  p_atp_record.manufacturing_cal_code;
               l_pegging_rec.shipping_cal_code      :=  NULL;
               l_pegging_rec.receiving_cal_code     :=  NULL;
               l_pegging_rec.intransit_cal_code     :=  NULL;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check: ' || 'Inside ELSE');
               END IF;
            END IF;
            -- Bug 3826234 end
            MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_atp_pegging_id);
            --optional_fw G_OPTIONAL_FW will be not null only when profile is Y
            IF MSC_ATP_PVT.G_OPTIONAL_FW is not null AND MSC_ATP_PVT.G_FORWARD_ATP = 'Y' THEN
               MSC_ATP_PVT.G_FW_STEAL_PEGGING_ID.EXTEND;
               MSC_ATP_PVT.G_FW_STEAL_PEGGING_ID(MSC_ATP_PVT.G_FW_STEAL_PEGGING_ID.COUNT) := l_atp_pegging_id;
               IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('ATP_Check: ' || 'MSC_ATP_PVT.G_FW_STEAL_PEGGING_ID := '
                                                              || MSC_ATP_PVT.G_FW_STEAL_PEGGING_ID(MSC_ATP_PVT.G_FW_STEAL_PEGGING_ID.COUNT));
               END IF;
            END IF;
            -- Add pegging_id to the l_atp_period and l_atp_supply_demand

            FOR i in 1..l_atp_period.Level.COUNT LOOP
                l_atp_period.Pegging_Id(i) := l_atp_pegging_id;
                l_atp_period.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;
            END LOOP;

            -- dsting: supply/demand details pl/sql table no longer used
/*          FOR i in 1..l_atp_supply_demand.Level.COUNT LOOP
                l_atp_supply_demand.Pegging_Id(i) := l_atp_pegging_id;
                l_atp_supply_demand.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;
            END LOOP;
*/

	    IF p_atp_record.insert_flag <> 0 THEN
		    MSC_ATP_DB_UTILS.move_SD_temp_into_mrp_details(l_atp_pegging_id,
					  MSC_ATP_PVT.G_DEMAND_PEGGING_ID);
	    END IF;

            MSC_ATP_PROC.Details_Output(l_atp_period,
                             l_atp_supply_demand,
                             x_atp_period,
                             x_atp_supply_demand,
                             x_return_status);

        END IF;  -- IF p_atp_record.requested_date_quantity > 0

        -- 1430561: we moved the p_net_demand to here
        p_net_demand := (p_net_demand - greatest(l_mat_atp_info_rec.requested_date_quantity, 0)) ;

        IF (p_net_demand <= 0) then
          EXIT;
        END IF;

  END LOOP;
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('********* END Stealing ************');
  END IF;
END Stealing;
END MSC_AATP_PVT;

/
