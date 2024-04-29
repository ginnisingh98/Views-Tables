--------------------------------------------------------
--  DDL for Package Body MSC_ATP_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_PROC" AS
/* $Header: MSCPATPB.pls 120.11.12010000.6 2009/10/14 09:12:09 sbnaik ship $  */
G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MSC_ATP_PROC';

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

-- dlt dsting. replaced hash with nested table since 8i doesn't support it
MAX_DLT_CACHE_SZ        NUMBER := 10;
dlt_lookup              MRP_ATP_PUB.char80_arr := MRP_ATP_PUB.char80_arr();
dlt_cache               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
ship_method_cache       MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr();
dlt_idx                 NUMBER := 0;

-- 2834932
G_NONWORKING_DAY        CONSTANT NUMBER := 1;
G_set_nonoverride_flag  VARCHAR2(1);
G_set_override_flag     VARCHAR2(1);
G_set_status            NUMBER;
G_is_ship_set           BOOLEAN;
G_override_date         DATE;
G_ship_EAD_set          DATE;
G_ship_LAD_set          DATE;
G_arr_LAD_set           DATE;
--G_latest_ship_date_set  DATE; --4460369
--G_latest_arr_date_set   DATE; --4460369

-- Private procedure Get_Sources_Info added for bug 2585710
PROCEDURE Get_Sources_Info(p_session_id             IN  NUMBER,
                           p_inventory_item_id      IN  NUMBER,
                           p_customer_id            IN  NUMBER,
                           p_customer_site_id       IN  NUMBER,
                           p_assignment_set_id      IN  NUMBER,
                           p_ship_set_item_count    IN  NUMBER,
                           x_atp_sources            OUT NOCOPY MRP_ATP_PVT.Atp_Source_Typ,
                           x_return_status          OUT NOCOPY VARCHAR2,
                           p_partner_type           IN  NUMBER, --2814895
	                   p_party_site_id          IN  NUMBER, --2814895
	                   p_order_line_id          IN  NUMBER,  --2814895
                           p_requested_date         IN   DATE  DEFAULT null   -- 8524794
                           );

PROCEDURE add_inf_time_fence_to_period(
  p_level			IN  NUMBER,
  p_identifier                  IN  NUMBER,
  p_scenario_id                 IN  NUMBER,
  p_inventory_item_id           IN  NUMBER,
  p_request_item_id		IN  NUMBER,
  p_organization_id             IN  NUMBER,
  p_supplier_id                 IN  NUMBER,
  p_supplier_site_id            IN  NUMBER,
  p_infinite_time_fence_date    IN  DATE,
  x_atp_period                  IN OUT NOCOPY 	MRP_ATP_PUB.ATP_Period_Typ

) IS
  j			NUMBER;
  l_return_status 	VARCHAR2(1);
BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('PROCEDURE add_inf_time_fence_to_period');
        END IF;

	IF p_infinite_time_fence_date IS NULL THEN
		RETURN;
	END IF;

        -- add one more entry to indicate infinite time fence date
        -- and quantity.
        MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, l_return_status);
        j := x_atp_period.Level.COUNT;

        IF j > 1 THEN
          x_atp_period.Period_End_Date(j-1) := p_infinite_time_fence_date - 1;
          x_atp_period.Identifier1(j) := x_atp_period.Identifier1(j-1);
          x_atp_period.Identifier2(j) := x_atp_period.Identifier2(j-1);
        END IF;

        x_atp_period.Level(j) := p_level;
        x_atp_period.Identifier(j) := p_identifier;
        x_atp_period.Scenario_Id(j) := p_scenario_id;
        x_atp_period.Pegging_Id(j) := NULL;
        x_atp_period.End_Pegging_Id(j) := NULL;
        x_atp_period.Inventory_Item_Id(j) := p_inventory_item_id;
	-- dsting: changed p_inventory_item_id to p_request_item_id
        x_atp_period.Request_Item_Id(j) := p_request_item_id;
        x_atp_period.Organization_id(j) := p_organization_id;
	x_atp_period.supplier_id(j) := p_supplier_id;
	x_atp_period.supplier_site_id(j) := p_supplier_site_id;
        x_atp_period.Period_Start_Date(j) := p_infinite_time_fence_date;
        x_atp_period.Total_Supply_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
        x_atp_period.Total_Demand_Quantity(j) := 0;
        x_atp_period.Total_Bucketed_Demand_Quantity(j) := 0; -- for time_phased_atp
        x_atp_period.Period_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
        x_atp_period.Cumulative_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;

END add_inf_time_fence_to_period;

--
-- dsting 9/17/2002
--
-- Populate the period record with data from the temp table
-- msc_atp_sd_details_temp
--
-- NOTE: as part of the pegging enhancement this procedure assumes that
-- only 1 item's data is in the session specific temp table
--
PROCEDURE get_period_data_from_SD_temp(
  x_atp_period                  OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ
) IS
  i			NUMBER;
  j			NUMBER;
  x_return_status 	NUMBER;
BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('PROCEDURE get_period_data_from_SD_temp');
	END IF;

     SELECT
	 ATP_level
--	,order_line_id
	,scenario_id
	,inventory_item_id
	,request_item_id
	,organization_id
	,supplier_id
	,supplier_site_id
	,department_id
	,resource_id
	,supply_demand_date
	,identifier1
	,identifier2
	,SUM(DECODE(supply_demand_type, 1, supply_demand_quantity, 0))
		total_demand_quantity
	,SUM(DECODE(supply_demand_type, 2, supply_demand_quantity, 0))
		total_supply_quantity
	,SUM(supply_demand_quantity)
     BULK COLLECT INTO
        x_atp_period.Level,
--        x_atp_period.Identifier,
        x_atp_period.Scenario_Id,
        x_atp_period.Inventory_Item_Id,
        x_atp_period.Request_Item_Id,
        x_atp_period.Organization_id,
	x_atp_period.Supplier_ID,
	x_atp_period.Supplier_Site_ID,
        x_atp_period.Department_id,
        x_atp_period.Resource_id,
        x_atp_period.Period_Start_Date,
        x_atp_period.Identifier1,
        x_atp_period.Identifier2,
        x_atp_period.Total_Demand_Quantity,
        x_atp_period.Total_Supply_Quantity,
        x_atp_period.Period_Quantity
     FROM msc_atp_sd_details_temp
     GROUP BY
	supply_demand_date
	,ATP_level
--	,order_line_id
	,scenario_id
	,inventory_item_id
	,request_item_id
	,organization_id
	,supplier_id
	,supplier_site_id
	,department_id
	,resource_id
	,identifier1
	,identifier2
     ORDER BY supply_demand_date;

     -- set the period end dates and
     -- extend the remaining fields to ensure same behaviour as before
     i := x_atp_period.Period_Start_Date.COUNT;

     x_atp_period.Identifier.EXTEND(i);
     x_atp_period.Pegging_Id.EXTEND(i);
     x_atp_period.End_Pegging_Id.EXTEND(i);
     x_atp_period.Period_End_Date.EXTEND(i);
     x_atp_period.From_Location_Id.EXTEND(i);
     x_atp_period.From_Organization_Id.EXTEND(i);
     x_atp_period.Ship_Method.EXTEND(i);
     x_atp_period.To_Location_Id.EXTEND(i);
     x_atp_period.To_Organization_Id.EXTEND(i);
     x_atp_period.Uom.EXTEND(i);

     --pf chnages -vivek
     x_atp_period.total_bucketed_demand_quantity.extend(i);

     FOR j IN 1..(i-1) LOOP
	x_atp_period.Period_End_Date(j) :=
		x_atp_period.Period_Start_Date(j+1) - 1;
     END LOOP;

END get_period_data_from_SD_temp;

-- New procedure added as part of time_phased_atp to fix the
-- issue of not displaying correct quantities in ATP SD Window when
-- user opens ATP SD window from ATP pegging in allocated scenarios
PROCEDURE Get_Alloc_Data_From_Sd_Temp(
  x_atp_period                  OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
  x_return_status               OUT NOCOPY VARCHAR2
) IS
  i			NUMBER;
  j			NUMBER;
BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('PROCEDURE Get_Alloc_Data_From_Sd_Temp');
	END IF;

        -- initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

     SELECT
	 ATP_level
	,scenario_id
	,inventory_item_id
	,request_item_id
	,organization_id
	,supplier_id
	,supplier_site_id
	,department_id
	,resource_id
	,supply_demand_date
	,identifier1
	,identifier2
	,SUM(DECODE(supply_demand_type, 1, allocated_quantity, 0))
		total_demand_quantity
	,SUM(DECODE(supply_demand_type, 2, allocated_quantity, 0))
		total_supply_quantity
	,SUM(allocated_quantity)
     BULK COLLECT INTO
        x_atp_period.Level,
        x_atp_period.Scenario_Id,
        x_atp_period.Inventory_Item_Id,
        x_atp_period.Request_Item_Id,
        x_atp_period.Organization_id,
	x_atp_period.Supplier_ID,
	x_atp_period.Supplier_Site_ID,
        x_atp_period.Department_id,
        x_atp_period.Resource_id,
        x_atp_period.Period_Start_Date,
        x_atp_period.Identifier1,
        x_atp_period.Identifier2,
        x_atp_period.Total_Demand_Quantity,
        x_atp_period.Total_Supply_Quantity,
        x_atp_period.Period_Quantity
     FROM msc_atp_sd_details_temp
     GROUP BY
	supply_demand_date
	,ATP_level
	,scenario_id
	,inventory_item_id
	,request_item_id
	,organization_id
	,supplier_id
	,supplier_site_id
	,department_id
	,resource_id
	,identifier1
	,identifier2
     ORDER BY supply_demand_date;

     -- set the period end dates and
     -- extend the remaining fields to ensure same behaviour as before
     i := x_atp_period.Period_Start_Date.COUNT;

     x_atp_period.Identifier.EXTEND(i);
     x_atp_period.Pegging_Id.EXTEND(i);
     x_atp_period.End_Pegging_Id.EXTEND(i);
     x_atp_period.Period_End_Date.EXTEND(i);
     x_atp_period.From_Location_Id.EXTEND(i);
     x_atp_period.From_Organization_Id.EXTEND(i);
     x_atp_period.Ship_Method.EXTEND(i);
     x_atp_period.To_Location_Id.EXTEND(i);
     x_atp_period.To_Organization_Id.EXTEND(i);
     x_atp_period.Uom.EXTEND(i);
     x_atp_period.total_bucketed_demand_quantity.extend(i);

     FOR j IN 1..(i-1) LOOP
	x_atp_period.Period_End_Date(j) :=
		x_atp_period.Period_Start_Date(j+1) - 1;
     END LOOP;

EXCEPTION
  WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Alloc_Data_From_Sd_Temp: ' || 'Error code:' || to_char(sqlcode));
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

END Get_Alloc_Data_From_Sd_Temp;

PROCEDURE Atp_Sources (p_instance_id               IN   NUMBER,
                       p_plan_id                   IN   NUMBER,
                       p_inventory_item_id         IN   NUMBER,
                       p_organization_id           IN   NUMBER,
                       p_customer_id               IN   NUMBER,
                       p_customer_site_id          IN   NUMBER,
                       p_assign_set_id             IN   NUMBER,
		       ---p_ship_set_item	           IN	MRP_ATP_PUB.number_arr,
                       p_item_sourcing_info_rec    IN   MSC_ATP_CTO.Item_Sourcing_Info_Rec,
                       p_session_id                IN   NUMBER,
                       x_atp_sources               OUT  NoCopy MRP_ATP_PVT.Atp_Source_Typ,
                       x_return_status             OUT  NoCopy VARCHAR2,
                       p_partner_type              IN   NUMBER, --2814895
	               p_party_site_id             IN   NUMBER, --2814895
	               p_order_line_id             IN   NUMBER  --2814895
) IS
-- Extra unwanted variables removed for bug 2585710
i PLS_INTEGER :=1;
l_count PLS_INTEGER;
l_preferred_rank NUMBER;
l_customer_id number;
l_ship_to_site_id number;
l_inv_item_id number;
l_distinct_item PLS_INTEGER;
l_organization_id  NUMBER;

/* Variables added for Bug 2585710 start */
l_dist_sr_ship_set_item_list    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_dest_ship_set_item_list       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_sysdate                       DATE;
l_return_status                 VARCHAR2(100);
/* Variables added for Bug 2585710 end */
--s_cto_rearch
l_model_flag  number := 2;
l_line_ids    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_source_list MRP_ATP_PVT.Atp_Source_Typ;
--e_cto_rearch

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** Begin Atp_Sources *********');
    END IF;
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_instance_id = '||p_instance_id);
       msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_plan_id = '||p_plan_id);
       msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_inventory_item_id = '||p_inventory_item_id);
       msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_organization_id = '||p_organization_id);
       msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_customer_id = '||p_customer_id);
       msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_customer_site_id = '||p_customer_site_id);
       msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_assign_set_id = '||p_assign_set_id);
    END IF;

    -- For bug 2585710. Store sysdate in local variable once and for all.
    -- Replace trunc(sysdate) everwhere.
    -- SELECT trunc(sysdate) INTO l_sysdate FROM dual;
    -- Modified to change explicit SELECT to direct assignment.
    l_sysdate := TRUNC(sysdate);

    IF (p_customer_id is not null) and (p_customer_site_id is not null) THEN
      BEGIN
    	SELECT TP_ID
    	INTO   l_customer_id
    	FROM   msc_tp_id_lid tp
    	WHERE  tp.SR_TP_ID = p_customer_id
    	AND    tp.SR_INSTANCE_ID = p_instance_id
    	AND    tp.PARTNER_TYPE = 2;

    	IF PG_DEBUG in ('Y', 'C') THEN
    	   msc_sch_wb.atp_debug('Atp_Sources: ' || 'l_customer_id '||l_customer_id);
    	END IF;

    	SELECT TP_SITE_ID
    	INTO   l_ship_to_site_id
    	FROM   msc_tp_site_id_lid tpsite
    	WHERE  tpsite.SR_TP_SITE_ID = p_customer_site_id
    	AND    tpsite.SR_INSTANCE_ID =  p_instance_id
    	AND    tpsite.PARTNER_TYPE = 2;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Sources: ' || 'l_ship_to_site_id '||l_ship_to_site_id);
        END IF;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'Customer id : '|| p_customer_id ||' not collected as yet');
             END IF;
	     l_customer_id := NULL;
	     l_ship_to_site_id := NULL;
      END;
    END IF;

    --s_cto_rearch
    --IF p_ship_set_item.count > 1 THEN
    IF p_item_sourcing_info_rec.sr_inventory_item_id.count > 1 THEN

       -- this is for ship set
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'Request is for ship set not a single line item');
                FOR i in 1.. p_item_sourcing_info_rec.sr_inventory_item_id.COUNT LOOP
                        msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_ship_set_item(i) = '
                                                ||  p_item_sourcing_info_rec.sr_inventory_item_id(i));
                END LOOP;
        END IF;

       /* For bug 2585710. A single for loop removes the duplicate items in ship set and
       also compute destination inventory item id */

        --FOR i in 1..p_ship_set_item.COUNT LOOP
        FOR i in 1..p_item_sourcing_info_rec.sr_inventory_item_id.COUNT LOOP

           IF (i = 1) THEN

                -- This is first item. Just store it in l_dist_sr_ship_set_item_list
                l_dist_sr_ship_set_item_list.EXTEND;

                --s_cto_reach
                l_line_ids.extend;
                l_line_ids(l_line_ids.count) := p_item_sourcing_info_rec.line_id(i);
                ---if model is invloved then set the model flag on
                IF p_item_sourcing_info_rec.ato_line_id(i) = p_item_sourcing_info_rec.line_id(i) THEN
                  l_model_flag := 1;
                END IF;

                l_dist_sr_ship_set_item_list(l_dist_sr_ship_set_item_list.COUNT)
                                             :=  p_item_sourcing_info_rec.sr_inventory_item_id(i);
                --l_dist_sr_ship_set_item_list(l_dist_sr_ship_set_item_list.COUNT) := p_ship_set_item(i);

                -- Get the dest inv item id and store that it in l_dest_ship_set_item_list
                l_dest_ship_set_item_list.EXTEND;
                l_dest_ship_set_item_list(l_dest_ship_set_item_list.COUNT) :=
                                        MSC_ATP_FUNC.get_inv_item_id(p_instance_id,
                                          p_item_sourcing_info_rec.sr_inventory_item_id(i),
                                          p_item_sourcing_info_rec.match_item_id(i),
                                          --p_ship_set_item(i),
                                          p_organization_id);

                -- 4091487 added elsif condition to raise try atp later error in case msc_item_id_lid contains no records
                -- If dest inv item id is null return from procedure means this item not collected
                IF l_dest_ship_set_item_list(l_dest_ship_set_item_list.COUNT) IS NULL THEN
                    --MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID := p_ship_set_item(i);
                    MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID :=  p_item_sourcing_info_rec.sr_inventory_item_id(i);
                    --x_return_status := FND_API.G_RET_STS_ERROR;
                    --return;
                    x_return_status := MSC_ATP_PVT.G_ITEM_NOT_COLL;

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Atp_Sources: ' || 'Inv Item Id not found for : ' ||
                                                                p_item_sourcing_info_rec.sr_inventory_item_id(i));
                        msc_sch_wb.atp_debug('return status assigned = ' || x_return_status);
                    END IF;
                    RAISE NO_DATA_FOUND;
                -- If dest inv item id is -1 return from procedure means no items not collected
                ELSIF  l_dest_ship_set_item_list(l_dest_ship_set_item_list.COUNT) = -1 THEN
                    x_return_status := MSC_ATP_PVT.G_ITEM_ID_NULL;
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('return status assigned = ' || x_return_status);
                    END IF;
                    RAISE NO_DATA_FOUND;
                END IF;


           ELSE
                -- This is not the first item. First check this in distinct source item ship set.

                l_distinct_item := 1; -- assume at first this is unique

                IF p_item_sourcing_info_rec.ato_line_id(i) is not null and
                   p_item_sourcing_info_rec.ato_line_id(i) <>  p_item_sourcing_info_rec.line_id(i) THEN
                   ---we do not look for sourcing for components of ato model
                   l_distinct_item := 0;

                   IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Model component, ignore for sourcing');
                   END IF;

                ELSE

                   FOR j in 1..l_dist_sr_ship_set_item_list.COUNT LOOP
                              --IF (p_ship_set_item(i) = l_dist_sr_ship_set_item_list(j)) THEN
                              IF ( p_item_sourcing_info_rec.sr_inventory_item_id(i) = l_dist_sr_ship_set_item_list(j)) THEN
                                      l_distinct_item := 0;
                                      EXIT;
                              END IF;
                   END LOOP;
                END IF;
                IF (l_distinct_item = 1) THEN

                        -- This is a distinct item. Do the same as for i = 1
                        l_dist_sr_ship_set_item_list.EXTEND;

                        --s_cto_reach
                        l_line_ids.extend;
                        l_line_ids(l_line_ids.count) := p_item_sourcing_info_rec.line_id(i);
                        ---if model is invloved then set the model flag on
                        IF p_item_sourcing_info_rec.ato_line_id(i) = p_item_sourcing_info_rec.line_id(i) THEN
                          l_model_flag := 1;
                        END IF;

                        --l_dist_sr_ship_set_item_list(l_dist_sr_ship_set_item_list.COUNT) := p_ship_set_item(i);
                        l_dist_sr_ship_set_item_list(l_dist_sr_ship_set_item_list.COUNT) :=
                                                       p_item_sourcing_info_rec.sr_inventory_item_id(i);

                        -- Get the dest inv item id and store that it in l_dest_ship_set_item_list
                        l_dest_ship_set_item_list.EXTEND;
                        l_dest_ship_set_item_list(l_dest_ship_set_item_list.COUNT) :=
                                                MSC_ATP_FUNC.get_inv_item_id(p_instance_id,
                                                  --p_ship_set_item(i),
                                                   p_item_sourcing_info_rec.sr_inventory_item_id(i),
                                                   p_item_sourcing_info_rec.match_item_id(i),
                                                  p_organization_id);
                 -- 4091487 added elsif condition to raise try atp later error in case msc_item_id_lid contains no records
                 -- If dest inv item id is null return from procedure means this item not collected
                 IF l_dest_ship_set_item_list(l_dest_ship_set_item_list.COUNT) IS NULL THEN
                    --MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID := p_ship_set_item(i);
                    MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID :=  p_item_sourcing_info_rec.sr_inventory_item_id(i);
                    --x_return_status := FND_API.G_RET_STS_ERROR;
                    --return;
                    x_return_status := MSC_ATP_PVT.G_ITEM_NOT_COLL;
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Atp_Sources: ' || 'Inv Item Id not found for : ' ||
                                                               p_item_sourcing_info_rec.sr_inventory_item_id(i));
                       msc_sch_wb.atp_debug('return status assigned = ' || x_return_status);
                    END IF;
                    RAISE NO_DATA_FOUND;
                    -- If dest inv item id is -1 return from procedure means no items not collected
                ELSIF  l_dest_ship_set_item_list(l_dest_ship_set_item_list.COUNT) = -1 THEN
                    x_return_status := MSC_ATP_PVT.G_ITEM_ID_NULL;
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('return status assigned = ' || x_return_status);
                    END IF;
                    RAISE NO_DATA_FOUND;
                END IF;

	       END IF;

	  END IF;

       END LOOP;

       msc_sch_wb.atp_debug('Atp_Sources: ' || 'l_count := ' || l_count);
       l_count := l_dest_ship_set_item_list.COUNT;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Sources: ' || 'No of distinct item in the ship set := '||l_count);
           FOR j in 1..l_count LOOP
              msc_sch_wb.atp_debug('Atp_Sources: ' || 'l_dest_ship_set_item_list(j) = '||l_dest_ship_set_item_list(j));
           END LOOP;
        END IF;


       -- Bug 2585710. Store ship set item inventory numbers into 8i temp table.

       DELETE MSC_SHIP_SET_TEMP;

       FORALL j IN 1..l_count
       --s_cto_rearch
       INSERT INTO MSC_SHIP_SET_TEMP(INVENTORY_ITEM_ID, VISITED_FLAG, MIN_REGION_VALUE, line_id)
       VALUES (l_dest_ship_set_item_list(j), 0, 0, l_line_ids(j));

    ELSE

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Atp_Sources: ' || 'Request is for single line item and not ship set');
       END IF;

       l_inv_item_id :=  MSC_ATP_FUNC.get_inv_item_id (p_instance_id,
                                       --p_inventory_item_id,
                                       --s_cto_rearch
                                       p_item_sourcing_info_rec.sr_inventory_item_id(1),
                                       p_item_sourcing_info_rec.match_item_id(1),
                                       --e_cto_rearch
                                       p_organization_id);
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Atp_Sources: ' || 'Inv item Id := ' || l_inv_item_id);
       END IF;
       -- 4091487 added elsif condition to raise try atp later error in case msc_item_id_lid contains no records
        ---bug 1905037
        -- If dest inv item id is -1 return from procedure means this item is not collected
       IF (l_inv_item_id IS NULL) THEN
            --MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID := p_inventory_item_id;
            MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID := p_item_sourcing_info_rec.sr_inventory_item_id(1);
            --x_return_status := FND_API.G_RET_STS_ERROR;
            --return;
           x_return_status := MSC_ATP_PVT.G_ITEM_NOT_COLL;
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Atp_Sources: ' || 'Inv Item Id not found for : ' ||
                                                               p_item_sourcing_info_rec.sr_inventory_item_id(1));
              msc_sch_wb.atp_debug('return status assigned = ' || x_return_status);
           END IF;
           RAISE NO_DATA_FOUND;
           -- If dest inv item id is -1 return from procedure means no items not collected
       ELSIF  l_inv_item_id = -1 THEN
           x_return_status := MSC_ATP_PVT.G_ITEM_ID_NULL;
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('return status assigned = ' || x_return_status);
           END IF;
           RAISE NO_DATA_FOUND;
       END IF;
       IF p_item_sourcing_info_rec.line_id(1) = p_item_sourcing_info_rec.ato_line_id(1) THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Atp_Sources: ' || 'Model Line, Add line id');
               msc_sch_wb.atp_debug('Atp_Sources: line_id := ' ||  p_item_sourcing_info_rec.line_id(1));
           END IF;
           l_model_flag := 1;
           l_line_ids.extend;
           l_line_ids(1) := p_item_sourcing_info_rec.line_id(1);
           IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('After Adding line id');
           END IF;

       END IF;
    END IF;
    IF (p_organization_id IS NOT NULL) OR  (p_customer_id is NOT NULL) THEN
       --s_cto_rearch
       --IF p_ship_set_item.COUNT > 1  THEN
       IF p_item_sourcing_info_rec.sr_inventory_item_id.count >1 THEN


          --IF NVL(p_organization_id, -1) = -1 THEN
          IF p_customer_site_id IS NOT NULL THEN
          -- Bug 3515520, don't use org in case customer/site is populated.

		          IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Atp_Sources: ' || 'we are in ship set and receiving party is customer');
                  END IF;

                   -- rmehra Replaced views by procedure for bug 2585710
                   MSC_ATP_PROC.Get_Sources_Info(order_sch_wb.debug_session_id, null, l_customer_id,
                   p_customer_site_id, p_assign_set_id, l_count, x_atp_sources, l_return_status,
                   p_partner_type, p_party_site_id, p_order_line_id ); --2814895

                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Atp_Sources: ' || 'Error occured in procedure Get_Sources_Info');
                        END IF;
                        DELETE MSC_SHIP_SET_TEMP;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        return;
                   END IF;

          --ELSE
          ELSIF p_organization_id IS NOT NULL AND (p_customer_id is NULL AND p_customer_site_id IS NULL) THEN
          -- Bug 3515520, don't use org in case customer/site is populated.

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'we are in ship set and receiving party is an inv org');
            END IF;

	   -- the cursor is different if it is ods or pds
           --bug 3495773: Add nvl condition
           IF nvl(p_plan_id, -1) <> -1 THEN
            -- pds , use msc_item_sourcing table
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Atp_Sources: ' || 'inside ship set, p_plan_id <> -1');
            END IF;

	    -- Fix for bug 1454524, no need to join based on assignment set as only
            -- 1 assignment set is supported for a plan.
            -- Bug 2585710. Rewriting the dynamic SQL in static form. Using msc_ship_set_temp
                SELECT
                        nvl(s.source_organization_id, -1),
                        -- nvl(s.sr_instance_id2,-1),
                        decode(nvl(min(s.source_type),
                                   decode(min(s.source_organization_id),
                                          to_number(null), 3,
                                                           1)),
                               3, p_instance_id,
                                  nvl(s.sr_instance_id2,-1)),
                        -- Bug 3270842 : For buy cases always select the passed instance id as source's
                        --               instance id for buy sources
                        -- Bug 3517529: For Buy cases if supplier_id and supplier_site_id are NULL, then
                        --              they are changed to -99 to identify the Buy case, otherwise it will
                        --              be identified as a Transfer case and ATP_Check will be called recursively.
                        nvl(supplier_id,decode(source_type,MSC_ATP_PVT.BUY,-99,-1)),
                        nvl(supplier_site_id,decode(source_type,MSC_ATP_PVT.BUY,-99,-1)),
                        sum(nvl(s.rank, 0) + 1 - nvl(s.allocation_percent,0)/1000), --2910418
                        nvl(min(s.source_type),
                                decode(min(s.source_organization_id),to_number(null), 3, 1)),
                        0,
                        NVL(MAX(s.avg_transit_lead_time), 0), -- dsting 2614883
                        NVL(s.ship_method, '@@@'), -- For ship_rec_cal
                        DECODE(mtps.shipping_control,'BUYER',1,2) -- For supplier intransit LT project - 1:Ship Cap, 2:Dock Cap
                BULK COLLECT INTO
                         x_atp_sources.Organization_Id,
                         x_atp_sources.Instance_Id,
                         x_atp_sources.Supplier_Id,
                         x_atp_sources.Supplier_Site_Id,
                         x_atp_sources.Rank,
                         x_atp_sources.Source_Type,
                         x_atp_sources.Preferred,
                         x_atp_sources.Lead_Time,
                         x_atp_sources.Ship_Method,
                         x_atp_sources.Sup_Cap_Type  -- For supplier intransit LT project
                FROM
                        msc_item_sourcing s,
                        msc_ship_set_temp msst,
                        msc_trading_partner_sites mtps -- For supplier intransit LT project
                WHERE
                        s.inventory_item_id = msst.inventory_item_id
                        AND     s.organization_id = p_organization_id
                        AND     s.sr_instance_id =  p_instance_id
                        AND     s.plan_id =  p_plan_id
                        AND     s.supplier_site_id = mtps.partner_site_id (+) -- For supplier intransit LT project
                        --bug 3373166: Use assignmnet set for plan sourcing
                        AND    NVL(s.assignment_set_type, 1) = 1
                        -- Bug 3787821: Putting the Date check if recieving party is org
                        AND     TRUNC(NVL(s.DISABLE_DATE,l_sysdate)) >= l_sysdate
                        AND     TRUNC(s.EFFECTIVE_DATE) <= l_sysdate
                        -- ATP4drp Circular sources applicable for DRP plans not supported by ATP.
                        AND     NVL(s.circular_src, 2) <> 1


                GROUP BY
                        s.source_organization_id,
                        s.sr_instance_id2,
                        s.supplier_id,
                        s.supplier_site_id,
                        DECODE(mtps.shipping_control,'BUYER',1,2) -- For supplier intransit LT project
                HAVING  count(*) = l_count
                ORDER BY 5;

           ELSE
            -- ODS, use msc_sources_v
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Atp_Sources: ' || 'We are in ODS, using msc_sources_v for sources.');
            END IF;

            -- fix 1460753: make at for global sourcing rule
           -- Bug 2585710. Rewriting the dynamic SQL into static form.

            SELECT
                    nvl(s.source_organization_id, p_organization_id),
                    nvl(s.source_org_instance_id, -1),
                    nvl(s.vendor_id, -1),
                    nvl(s.vendor_site_id, -1),
                    sum(nvl(s.rank, 0) + 1 - nvl(s.allocation_percent,0)/1000), --2910418
                    nvl(min(s.source_type),
                      decode(s.source_organization_id, to_number(null), 3, 1)),
                    0,
                    NVL(MAX(s.avg_transit_lead_time), 0), -- dsting 2614883
                    '@@@',
                    NULL -- For supplier intransit LT project
           BULK COLLECT INTO
                    x_atp_sources.Organization_Id,
                    x_atp_sources.Instance_Id,
                    x_atp_sources.Supplier_Id,
                    x_atp_sources.Supplier_Site_Id,
                    x_atp_sources.Rank,
                    x_atp_sources.Source_Type,
                    x_atp_sources.Preferred,
                    x_atp_sources.Lead_Time,
                    x_atp_sources.Ship_Method,
                    x_atp_sources.Sup_Cap_Type  -- For supplier intransit LT project
            FROM    msc_sources_v s,
                    msc_ship_set_temp msst
            WHERE   s.inventory_item_id = msst.inventory_item_id
            AND     s.organization_id = p_organization_id
            AND     s.sr_instance_id = p_instance_id
            AND     s.assignment_set_id = p_assign_set_id
            -- Bug 3787821: Putting the Date check if recieving party is org
            AND     TRUNC(NVL(s.DISABLE_DATE,l_sysdate)) >= l_sysdate
            AND     TRUNC(s.EFFECTIVE_DATE) <= l_sysdate
            AND     NVL(s.source_organization_id,
                        decode(s.source_type, 2, p_organization_id, -1)) <> -1
            GROUP BY s.source_organization_id,
                     s.source_org_instance_id,
                     s.vendor_id,
                     s.vendor_site_id
            HAVING count(*) = l_count
            ORDER BY 5;

           END IF; -- end if the ods/pds

          END IF;

          IF x_atp_sources.Rank.COUNT > 0 THEN
            l_preferred_rank := x_atp_sources.Rank(1);
            i := 1;
            WHILE i IS NOT NULL LOOP
              IF x_atp_sources.Rank(i) = l_preferred_rank THEN
                  x_atp_sources.Preferred(i) := 1;
              ELSE
                  EXIT;
              END IF;

              i:= x_atp_sources.Rank.NEXT(i);
            END LOOP;
          END IF;

       --ELSIF NVL(p_organization_id, -1) = -1 THEN
       ELSIF p_customer_site_id IS NOT NULL THEN
       -- Bug 3515520, don't use org in case customer/site is populated.

          -- we are in single line, receiving party is customer
          IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Atp_Sources: ' || 'we are in single line, receiving party is customer');
                  msc_sch_wb.atp_debug('Atp_Sources: ' || 'Customer Specific Sourcing');
          END IF;

          -- savirine, Sep 11, 2001: added region_id and source_organization_id in the where clause and
          -- added aliases in the select statement.

           -- ngoel 9/26/2001, since view msc_scatp_sources_v resolves the hierarchy,
	   -- no need to have either union all or separate clause for customer site and region

	  -- bug 2585710. Replaced views by procedure
           MSC_ATP_PROC.Get_Sources_Info(order_sch_wb.debug_session_id, l_inv_item_id, l_customer_id,
           p_customer_site_id, p_assign_set_id, null, x_atp_sources, l_return_status,
           p_partner_type, p_party_site_id, p_order_line_id ); --2814895

           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Atp_Sources: ' || 'Procedure Get_Sources_Info could not find any sources');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
            END IF;


          IF x_atp_sources.Rank.COUNT > 0 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Atp_Sources: ' || 'get some records');
            END IF;
            l_preferred_rank := x_atp_sources.Rank(1);
            i := 1;
            WHILE i IS NOT NULL LOOP
              IF x_atp_sources.Rank(i) = l_preferred_rank THEN
                  x_atp_sources.Preferred(i) := 1;
              ELSE
                  EXIT;
              END IF;

              i:= x_atp_sources.Rank.NEXT(i);
            END LOOP;
          END IF;

       --ELSE
       ELSIF p_organization_id IS NOT NULL AND (p_customer_id is NULL AND p_customer_site_id IS NULL) THEN
       -- Bug 3515520, don't use org in case customer/site is populated.

          -- we are in single line and receiving party is an inv org.

          IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Atp_Sources: ' || 'we are in single line and receiving party is an inv org.');

             msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_assign_set_id'||p_assign_set_id);
             msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_inventory_item_id'||p_inventory_item_id);
             msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_organization_id'||p_organization_id);
             msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_instance_id'||p_instance_id);
             msc_sch_wb.atp_debug('Atp_Sources: ' || 'p_plan_id'||p_plan_id);
          END IF;

          -- Bug 1542439, since planning is now carrying the sourcing for models
          -- removing the wrokaround and look into the PDS data rather than ODS
          -- data when the models are sourced.

          -- Modified on 11/06/2000 by ngoel. In case of multi-level, multi-org CTO
          -- we need to pick the sources from msc_sources_v instead of msc_item_sourcing
          -- since planning doesn't honor souring rules for models.

          -- Bug 1562754, use G_ASSEMBLY_LINE_ID instead of G_COMP_LINE_ID, to make sure that
          -- in case of CTO, we try to get the BOM correctly from msc_bom_temp_table.-NGOEL 02/01/2001

   --       IF p_plan_id <> -1 AND l_cto_bom = 0 THEN
           --bug 3495773: Add nvl condition
          IF nvl(p_plan_id, -1) <> -1 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Atp_Sources: ' || 'we are in pds, using msc_item_sourcing');
            END IF;
            -- we are in pds, using msc_item_sourcing

            -- Fix for bug 1454524, no need to join based on assignment set as only 1 assignment
            -- set is supported for a plan.
            SELECT  nvl(s.source_organization_id, -1),
                    decode(decode(s.organization_id,
                                  s.source_organization_id, 2,
                                  nvl(s.source_type,
                                      decode(source_organization_id,
                                             to_number(null), 3, 1))),
                           3, p_instance_id,
                              nvl(sr_instance_id2, -1)),
                    -- Bug 3270842 : For buy cases always select the passed instance id as source's
                    --               instance id for buy sources
                    -- Bug 3517529: For Buy cases if supplier_id and supplier_site_id are NULL, then
                    --              they are changed to -99 to identify the Buy case, otherwise it will
                    --              be identified as a Transfer case and ATP_Check will be called recursively.
                    nvl(supplier_id,decode(source_type,MSC_ATP_PVT.BUY,-99,-1)),
                    nvl(supplier_site_id,decode(source_type,MSC_ATP_PVT.BUY,-99,-1)),
                    nvl(s.rank, -1),
                    -- 2936920. treat as a make if org/src org are the same
                    decode(s.organization_id, s.source_organization_id, 2,
                    nvl(s.source_type,
                    decode(source_organization_id, to_number(null), 3, 1))),
                    0,
                    NVL(s.avg_transit_lead_time, 0), -- dsting 2614883
                    NVL(s.ship_method, '@@@'),
                    DECODE(mtps.shipping_control,'BUYER',1,2) -- For supplier intransit LT project - 1:Ship Cap, 2:Dock Cap
            BULK COLLECT INTO
                    x_atp_sources.Organization_Id,
                    x_atp_sources.Instance_Id,
                    x_atp_sources.Supplier_Id,
                    x_atp_sources.Supplier_Site_Id,
                    x_atp_sources.Rank,
                    x_atp_sources.Source_Type,
                    x_atp_sources.Preferred,
                    x_atp_sources.Lead_Time,
                    x_atp_sources.Ship_Method,
                    x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
            FROM    msc_item_sourcing s,
                    msc_trading_partner_sites mtps -- For supplier intransit LT project
            WHERE   s.inventory_item_id = l_inv_item_id
            AND     s.organization_id = p_organization_id
            AND     s.sr_instance_id = p_instance_id
            /*AND     s.assignment_set_id = p_assign_set_id*/
            AND     s.plan_id =  p_plan_id
            AND     s.supplier_site_id = mtps.partner_site_id (+) -- For supplier intransit LT project
            --bug 3373166: Use assignmnet set for plan sourcing
            AND    NVL(s.assignment_set_type, 1) = 1
            -- Bug 3787821: Putting the Date check if recieving party is org
            AND     TRUNC(NVL(s.DISABLE_DATE,l_sysdate)) >= l_sysdate
            AND     TRUNC(s.EFFECTIVE_DATE) <= l_sysdate
                     -- ATP4drp Circular sources applicable for DRP plans not supported by ATP.
            AND     NVL(s.circular_src, 2) <> 1
            ORDER BY rank asc, allocation_percent desc;
          ELSE

          IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Atp_Sources: ' || 'we are in ods, using msc_sources_v');
            END IF;
            -- we are in ods
            -- we are in ods or this is for multi-level, multi-org CTO, using msc_sources_v

            SELECT  nvl(s.source_organization_id, p_organization_id), -- 1460753
                    nvl(s.source_org_instance_id, -1),
                    nvl(s.vendor_id, -1),
                    nvl(s.vendor_site_id, -1),
                    nvl(s.rank, -1),
                    nvl(s.source_type,
                      decode(source_organization_id, to_number(null), 3, 1)),
                    0,
                    NVL(s.avg_transit_lead_time, -1),
                    NVL(s.ship_method, '@@@'),
                    NULL -- For supplier intransit LT project
            BULK COLLECT INTO
                    x_atp_sources.Organization_Id,
                    x_atp_sources.Instance_Id,
                    x_atp_sources.Supplier_Id,
                    x_atp_sources.Supplier_Site_Id,
                    x_atp_sources.Rank,
                    x_atp_sources.Source_Type,
                    x_atp_sources.Preferred,
                    x_atp_sources.Lead_Time,
                    x_atp_sources.Ship_Method,
                    x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
            FROM    msc_sources_v s
            WHERE   s.inventory_item_id = l_inv_item_id
            AND     s.organization_id = p_organization_id
            AND     s.sr_instance_id = p_instance_id
            AND     s.assignment_set_id = p_assign_set_id
            -- Bug 3787821: Putting the Date check if recieving party is org
            AND     TRUNC(NVL(s.DISABLE_DATE,l_sysdate)) >= l_sysdate
            AND     TRUNC(s.EFFECTIVE_DATE) <= l_sysdate
                    -- bug 1460753
            AND     NVL(s.source_organization_id,
                    decode(s.source_type,MSC_ATP_PVT.MAKE,p_organization_id,-1)) <> -1
            ORDER BY rank asc, allocation_percent desc;
          END IF;

          IF x_atp_sources.Rank.COUNT > 0 THEN
            l_preferred_rank := x_atp_sources.Rank(1);
            i := 1;
            WHILE i IS NOT NULL LOOP
              IF x_atp_sources.Rank(i) = l_preferred_rank THEN
                  x_atp_sources.Preferred(i) := 1;
              ELSE
                  EXIT;
              END IF;

              i:= x_atp_sources.Rank.NEXT(i);
            END LOOP;
          END IF;

       END IF;
    END IF;  ---  IF (p_organization_id IS NULL) AND (p_customer_id is NULL)

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Atp_Sources: ' || 'Sources count = '|| x_atp_sources.organization_id.count);
    END IF;
      --bug 3495773: Add nvl condition
    IF (x_atp_sources.organization_id.count = 0) and (nvl(p_plan_id, -1) = -1) then
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Atp_Sources: ' || 'No sources found so far');
       END IF;
       --s_cto_rearch
       --IF  p_ship_set_item.COUNT > 1 THEN
       IF p_item_sourcing_info_rec.sr_inventory_item_id.count > 1 THEN
       --e_cto_rearch

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Atp_Sources: ' || 'ship_count >1 ');
          END IF;
          -- BUG 2283260 Join to msc_system_items to only obtain sources
          -- which are valid for the item(s).

	  -- Rewriting the dynamic SQL into static one for bug 2585710.

        SELECT
                NVL(SOURCEORG.SOURCE_ORGANIZATION_ID, -1),
                NVL(SOURCEORG.SOURCE_ORG_INSTANCE_ID,-1),
                NVL(SOURCEORG.SOURCE_PARTNER_ID, -1),
                NVL(SOURCEORG.SOURCE_PARTNER_SITE_ID, -1),
                SUM(NVL(SOURCEORG.RANK, 0)),
                nvl(min(sourceorg.source_type),
                decode(sourceorg.source_organization_id,
                       to_number(null), 3, 1)),
                0,
                -1,
                '@@@',
                NULL -- For supplier intransit LT project
        BULK COLLECT INTO
                x_atp_sources.Organization_Id,
                x_atp_sources.Instance_Id,
                x_atp_sources.Supplier_Id,
                x_atp_sources.Supplier_Site_Id,
                x_atp_sources.Rank,
                x_atp_sources.Source_Type,
                x_atp_sources.Preferred,
                x_atp_sources.Lead_Time,
                x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
        FROM
                msc_sourcing_rules msr,
                msc_sr_receipt_org receiptorg,
                msc_sr_source_org sourceorg,
                msc_sr_assignments msa,
                msc_system_items msi,
                msc_ship_set_temp msst
        WHERE
                msa.assignment_type = 3
                AND    msa.assignment_set_id = p_assign_set_id
                AND    msa.inventory_item_id = msst.inventory_item_id
                AND    msa.sourcing_rule_id = msr.sourcing_rule_id
                AND    msr.status = 1
                AND    msr.sourcing_rule_type = 1
                AND    msr.sourcing_rule_id = receiptorg.sourcing_rule_id
                -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
                AND    TRUNC(NVL(receiptorg.disable_date, l_sysdate)) >=  l_sysdate
                AND    TRUNC(receiptorg.effective_date) <= l_sysdate
                AND    receiptorg.sr_receipt_id = sourceorg.sr_receipt_id
                AND    sourceorg.sr_instance_id = msi.sr_instance_id
                AND    sourceorg.source_organization_id = msi.organization_id
                -- ATP4drp Circular sources not supported by ATP.
                --AND    NVL(sourceorg.circular_src, 2) <> 1
                --Bug4567833
                AND     NVL(sourceorg.circular_src, 'N') <> 'Y'
                AND    msa.inventory_item_id = msi.inventory_item_id
                AND    msi.plan_id = -1
        GROUP  BY
                SOURCEORG.SOURCE_ORGANIZATION_ID,
                SOURCEORG.SOURCE_ORG_INSTANCE_ID,
                SOURCEORG.SOURCE_PARTNER_ID,
                SOURCEORG.SOURCE_PARTNER_SITE_ID
                HAVING count(*) = l_count
        ORDER  BY 5;


	  IF (x_atp_sources.organization_id.count = 0) THEN
             IF PG_DEBUG in ('Y', 'C') THEN
		msc_sch_wb.atp_debug('Atp_Sources: ' || 'Lookup for item level assignment failed.');
		msc_sch_wb.atp_debug('Atp_Sources: ' || 'Check on item_category level.');
	      END IF;
	      -- Rewriting the dynamic SQL into a static SQL. Refer to bug 2585710 for details.
                SELECT
                        NVL(SOURCEORG.SOURCE_ORGANIZATION_ID, -1),
                        NVL(SOURCEORG.SOURCE_ORG_INSTANCE_ID,-1),
                        NVL(SOURCEORG.SOURCE_PARTNER_ID, -1),
                        NVL(SOURCEORG.SOURCE_PARTNER_SITE_ID, -1),
                        SUM(NVL(SOURCEORG.RANK, 0)),
                        nvl(min(sourceorg.source_type),
                              decode(sourceorg.source_organization_id,
                                      to_number(null), 3, 1)),
                        0,
                        -1,
                        '@@@',
                        NULL -- For supplier intransit LT project
                BULK COLLECT INTO
                        x_atp_sources.Organization_Id,
                        x_atp_sources.Instance_Id,
                        x_atp_sources.Supplier_Id,
                        x_atp_sources.Supplier_Site_Id,
                        x_atp_sources.Rank,
                        x_atp_sources.Source_Type,
                        x_atp_sources.Preferred,
                        x_atp_sources.Lead_Time,
                        x_atp_sources.Ship_Method,
                        x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
                 FROM   msc_sourcing_rules msr,
                        msc_sr_receipt_org receiptorg,
                        msc_sr_source_org sourceorg,
                        msc_sr_assignments msa,
                        msc_item_categories cat,
                        msc_ship_set_temp msst
                 WHERE  msa.assignment_type = 2 and
                        msa.assignment_set_id = p_assign_set_id and
                        msa.inventory_item_id = msst.inventory_item_id
                 AND    msa.sourcing_rule_id = msr.sourcing_rule_id
                 AND    msr.status = 1
                 AND    msr.sourcing_rule_type = 1
                 AND    msr.sourcing_rule_id = receiptorg.sourcing_rule_id
                 -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
                 AND    TRUNC(NVL(receiptorg.disable_date, l_sysdate)) >= l_sysdate
                 AND    TRUNC(receiptorg.effective_date) <= l_sysdate
                 AND    receiptorg.sr_receipt_id = sourceorg.sr_receipt_id
                 AND    msa.category_name = cat.category_name
                 AND    msa.category_set_id = cat.category_set_id
                 AND    msa.inventory_item_id = cat.inventory_item_id
                 AND    sourceorg.source_organization_id = cat.organization_id
                 AND    sourceorg.sr_instance_id = cat.sr_instance_id
                 -- ATP4drp Circular sources not supported by ATP.
                 --AND    NVL(sourceorg.circular_src, 2) <> 1
                 --Bug4567833
                 AND     NVL(sourceorg.circular_src, 'N') <> 'Y'
                 GROUP  BY SOURCEORG.SOURCE_ORGANIZATION_ID,
                           SOURCEORG.SOURCE_ORG_INSTANCE_ID,
                           SOURCEORG.SOURCE_PARTNER_ID,
                           SOURCEORG.SOURCE_PARTNER_SITE_ID
                 HAVING count(*) = l_count
                 ORDER  BY 5;

          END IF;

	  IF (x_atp_sources.organization_id.count = 0) AND (p_organization_id is not null) AND
         (p_customer_id is NULL AND p_customer_site_id IS NULL) THEN
      -- Bug 3515520, don't use org in case customer/site is populated.
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'Lookup for item-cat assignment failed.');
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'Check on global-BOD level.');
             END IF;
             -- BUG 2283260 Join to msc_system_items to only obtain sources
             -- which are valid for the item(s).
             l_organization_id := p_organization_id; -- local var for testing
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || ' Org Id := ' || l_organization_id);
             END IF;
             -- Rewriting the SQL for bug 2585710.
                SELECT
                        NVL(SOURCEORG.SOURCE_ORGANIZATION_ID, -1),
                        NVL(SOURCEORG.SOURCE_ORG_INSTANCE_ID,-1),
                        NVL(SOURCEORG.SOURCE_PARTNER_ID, -1),
                        NVL(SOURCEORG.SOURCE_PARTNER_SITE_ID, -1),
                        NVL(SOURCEORG.RANK, 0),
                        nvl(sourceorg.source_type,
                         decode(sourceorg.source_organization_id,
                         to_number(null), 3, 1)),
                        0,
                        -1,
                        '@@@',
                        NULL -- For supplier intransit LT project
                BULK COLLECT INTO
                        x_atp_sources.Organization_Id,
                        x_atp_sources.Instance_Id,
                        x_atp_sources.Supplier_Id,
                        x_atp_sources.Supplier_Site_Id,
                        x_atp_sources.Rank,
                        x_atp_sources.Source_Type,
                        x_atp_sources.Preferred,
                        x_atp_sources.Lead_Time,
                        x_atp_sources.Ship_Method,
                        x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
                FROM
                        msc_sourcing_rules msr,
                        msc_sr_receipt_org receiptorg,
                        msc_sr_source_org sourceorg,
                        msc_sr_assignments msa,
                        msc_system_items msi,
                        msc_ship_set_temp msst
                WHERE
                        msa.assignment_type = 1
                        AND    msa.assignment_set_id = p_assign_set_id
                        AND    msa.sourcing_rule_id = msr.sourcing_rule_id
                        AND    msr.status = 1
                        AND    msr.sourcing_rule_type = 2
                        AND    msr.sourcing_rule_id = receiptorg.sourcing_rule_id
                        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
                        AND    TRUNC(NVL(receiptorg.disable_date, l_sysdate)) >= l_sysdate
                        AND    TRUNC(receiptorg.effective_date) <= l_sysdate
                        AND    receiptorg.sr_receipt_org = l_organization_id
                        AND    receiptorg.receipt_org_instance_id = p_instance_id
                        AND    receiptorg.sr_receipt_id = sourceorg.sr_receipt_id
                        AND    sourceorg.source_organization_id = msi.ORGANIZATION_ID
                        AND    sourceorg.sr_instance_id = msi.sr_instance_id
                        -- ATP4drp Circular sources not supported by ATP.
                        --AND    NVL(sourceorg.circular_src, 2) <> 1
                        --Bug4567833
                        AND     NVL(sourceorg.circular_src, 'N') <> 'Y'
                        AND    msi.inventory_item_id = msst.inventory_item_id
                        AND    msi.plan_id = -1
                ORDER  BY rank asc, allocation_percent desc;

          END IF;
          IF (x_atp_sources.organization_id.count = 0) THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'Lookup for GLOBAL-BOD assignment failed.');
		msc_sch_wb.atp_debug('Atp_Sources: ' || 'Check on global level');
             END IF;
             -- BUG 2283260 Join to msc_system_items to only obtain sources
             -- which are valid for the item(s).

                -- Rewriting the SQL into a static one for bug 2585710.
                SELECT
                        NVL(SOURCEORG.SOURCE_ORGANIZATION_ID, -1),
                        NVL(SOURCEORG.SOURCE_ORG_INSTANCE_ID,-1),
                        NVL(SOURCEORG.SOURCE_PARTNER_ID, -1),
                        NVL(SOURCEORG.SOURCE_PARTNER_SITE_ID, -1),
                        NVL(SOURCEORG.RANK, 0),
                        nvl(sourceorg.source_type,
                          decode(sourceorg.source_organization_id,
                                               to_number(null), 3, 1)),
                        0,
                        -1,
                        '@@@',
                        NULL -- For supplier intransit LT project
                BULK COLLECT INTO
                        x_atp_sources.Organization_Id,
                        x_atp_sources.Instance_Id,
                        x_atp_sources.Supplier_Id,
                        x_atp_sources.Supplier_Site_Id,
                        x_atp_sources.Rank,
                        x_atp_sources.Source_Type,
                        x_atp_sources.Preferred,
                        x_atp_sources.Lead_Time,
                        x_atp_sources.Ship_Method,
                        x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
                FROM
                        msc_sourcing_rules msr,
                        msc_sr_receipt_org receiptorg,
                        msc_sr_source_org sourceorg,
                        msc_sr_assignments msa,
                        msc_system_items msi,
                        msc_ship_set_temp msst
                WHERE
                        msa.assignment_type = 1
                        AND    msa.assignment_set_id = p_assign_set_id
                        AND    msa.sourcing_rule_id = msr.sourcing_rule_id
                        AND    msr.status = 1
                        AND    msr.sourcing_rule_type = 1
                        AND    msr.sourcing_rule_id = receiptorg.sourcing_rule_id
                        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
                        AND    TRUNC(NVL(receiptorg.disable_date, l_sysdate)) >= l_sysdate
                        AND    TRUNC(receiptorg.effective_date) <= l_sysdate
                        AND    receiptorg.sr_receipt_id = sourceorg.sr_receipt_id
                        AND    sourceorg.source_organization_id = msi.ORGANIZATION_ID
                        AND    sourceorg.sr_instance_id = msi.sr_instance_id
                        -- ATP4drp Circular sources not supported by ATP.
                        --AND    NVL(sourceorg.circular_src, 2) <> 1
                        --Bug4567833
                        AND     NVL(sourceorg.circular_src, 'N') <> 'Y'
                        AND    msi.inventory_item_id = msst.inventory_item_id
                        AND    msi.plan_id = -1
                ORDER  BY rank asc, allocation_percent desc;
          END IF;

       ELSE
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Atp_Sources: ' || 'at item level');
          msc_sch_wb.atp_debug('Atp_Sources: ' || 'ITEM Inv item Id := ' || l_inv_item_id);
       END IF;
             -- BUG 2283260 Join to msc_system_items to only obtain sources
             -- which are valid for the item(s).
          SELECT NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
                 NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,-1),
       		 NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
       	       	 NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
                 NVL(SOURCE_ORG.RANK, 0),
                 nvl(source_org.source_type,
                   decode(source_org.source_organization_id, to_number(null), 3, 1)),
                 0,
                 -1,
                 'XYZ',
                 NULL -- For supplier intransit LT project
          BULK COLLECT INTO
                 x_atp_sources.Organization_Id,
                 x_atp_sources.Instance_Id,
                 x_atp_sources.Supplier_Id,
                 x_atp_sources.Supplier_Site_Id,
                 x_atp_sources.Rank,
                 x_atp_sources.Source_Type,
                 x_atp_sources.Preferred,
                 x_atp_sources.Lead_Time,
                 x_atp_sources.Ship_Method,
                 x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project

          FROM    msc_sourcing_rules msr,
                 msc_sr_receipt_org receipt_org,
                 msc_sr_source_org source_org,
                 msc_sr_assignments msa,
                 msc_system_items msi
          WHERE   msa.assignment_type = 3 and
                 msa.assignment_set_id = p_assign_set_id and
                 msa.inventory_item_id = l_inv_item_id and
                 msa.sourcing_rule_id = msr.sourcing_rule_id and
                 msr.status = 1 and
                 msr.sourcing_rule_type = 1 and
                 msr.sourcing_rule_id = receipt_org.sourcing_rule_id and
                 -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
                 TRUNC(NVL(receipt_org.disable_date, l_sysdate )) >= l_sysdate and
                 TRUNC(receipt_org.effective_date) <= l_sysdate and
                 receipt_org.sr_receipt_id = source_org.sr_receipt_id and
                 source_org.sr_instance_id = msi.sr_instance_id and
                 source_org.source_organization_id = msi.ORGANIZATION_ID and
                 -- ATP4drp Circular sources not supported by ATP.
                 --NVL(source_org.circular_src, 2) <> 1  AND
                 --Bug4567833
                 NVL(source_org.circular_src, 'N') <> 'Y' AND
                 msa.inventory_item_id = msi.inventory_item_id and
                 msi.plan_id = -1
                 ORDER BY rank asc, allocation_percent desc;
          -- BUG 2283260 Note that join happens between msc_system_items(msi)
          -- and msc_sr_source_org (src) for org, instance as in certain cases
          -- join with msc_sr_assignments (msa) will bring no rows.
          -- Filter on item in msc_system_items.

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Count after item level = '||x_atp_sources.organization_id.count);
          END IF;
          IF (x_atp_sources.organization_id.count = 0) then
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'no sources on item level. look into item-cat level');
          msc_sch_wb.atp_debug('Atp_Sources: ' || ' ITEM CAT Inv item Id := ' || l_inv_item_id);
       END IF;
             SELECT NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
                    NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,-1),
                    NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
                    NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
                    NVL(SOURCE_ORG.RANK, 0),
                    nvl(source_org.source_type,
                      decode(source_org.source_organization_id, to_number(null), 3, 1)),
                    0,
                    -1,
                    'XYZ',
                    NULL -- For supplier intransit LT project
             BULK COLLECT INTO
                    x_atp_sources.Organization_Id,
                    x_atp_sources.Instance_Id,
                    x_atp_sources.Supplier_Id,
                    x_atp_sources.Supplier_Site_Id,
                    x_atp_sources.Rank,
                    x_atp_sources.Source_Type,
                    x_atp_sources.Preferred,
                    x_atp_sources.Lead_Time,
                    x_atp_sources.Ship_Method,
                    x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
            FROM    msc_sourcing_rules msr,
                    msc_sr_receipt_org receipt_org,
                    msc_sr_source_org source_org,
                    msc_sr_assignments msa,
                    msc_item_categories  cat
            WHERE   msa.assignment_type = 2 and
                    msa.assignment_set_id = p_assign_set_id and
                    msa.inventory_item_id = l_inv_item_id and
                    msa.sourcing_rule_id = msr.sourcing_rule_id and
                    msr.status = 1 and
                    msr.sourcing_rule_type = 1 and
                    msr.sourcing_rule_id = receipt_org.sourcing_rule_id and
                    -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
                    TRUNC(NVL(receipt_org.disable_date, l_sysdate)) >= l_sysdate and
                    TRUNC(receipt_org.effective_date) <= l_sysdate and
                    receipt_org.sr_receipt_id = source_org.sr_receipt_id and
                    msa.category_name = cat.category_name and
                    msa.category_set_id = cat.category_set_id and
                    msa.inventory_item_id = cat.inventory_item_id and
                    source_org.source_organization_id = cat.organization_id and
                    source_org.sr_instance_id = cat.sr_instance_id and
                    -- ATP4drp Circular sources not supported by ATP.
            --AND     NVL(source_org.circular_src, 2) <> 1
                    --Bug4567833
                    NVL(source_org.circular_src, 'N') <> 'Y'
                    ORDER BY rank asc, allocation_percent desc;
          -- BUG 2283260 Additional join between msc_sr_source_org snd
          -- msc_item_categories to ensure that the source is valid for item.
          END IF;

          IF (x_atp_sources.organization_id.count = 0) and (p_organization_id is not null) then
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'no sources on item-cat level. look at global-BOD level');
             END IF;
             l_organization_id := p_organization_id; -- local var for testing
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || ' Org Id := ' || l_organization_id);
             END IF;

             -- BUG 2283260 Join to msc_system_items to only obtain sources
             -- which are valid for the item(s).
             SELECT NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
                    NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,-1),
                    NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
                    NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
                    NVL(SOURCE_ORG.RANK, 0),
                    nvl(source_org.source_type,
                      decode(source_org.source_organization_id, to_number(null), 3, 1)),
                    0,
                    -1,
                    'XYZ',
                    NULL -- For supplier intransit LT project
             BULK COLLECT INTO
                    x_atp_sources.Organization_Id,
                    x_atp_sources.Instance_Id,
                    x_atp_sources.Supplier_Id,
                    x_atp_sources.Supplier_Site_Id,
                    x_atp_sources.Rank,
                    x_atp_sources.Source_Type,
                    x_atp_sources.Preferred,
                    x_atp_sources.Lead_Time,
                    x_atp_sources.Ship_Method,
                    x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
            FROM    msc_sourcing_rules msr,
                    msc_sr_receipt_org receipt_org,
                    msc_sr_source_org source_org,
                    msc_sr_assignments msa,
                    msc_system_items msi
            WHERE   msa.assignment_type = 1 and
                    msa.assignment_set_id = p_assign_set_id and
                    ---msa.inventory_item_id = l_inv_item_id and
                    msa.sourcing_rule_id = msr.sourcing_rule_id and
                    msr.status = 1 and
                    msr.sourcing_rule_type = 2 and
                    msr.sourcing_rule_id = receipt_org.sourcing_rule_id and
                    -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
                    TRUNC(NVL(receipt_org.disable_date, l_sysdate)) >= l_sysdate and
                    TRUNC(receipt_org.effective_date) <= l_sysdate and
                    receipt_org.SR_RECEIPT_ORG = l_organization_id and
                    receipt_org.RECEIPT_ORG_INSTANCE_ID = p_instance_id and
                    receipt_org.sr_receipt_id = source_org.sr_receipt_id and
                    source_org.source_organization_id = msi.ORGANIZATION_ID and
                    source_org.sr_instance_id = msi.sr_instance_id and
                    -- ATP4drp Circular sources not supported by ATP.
                    --NVL(source_org.circular_src, 2) <> 1 AND
                    --Bug4567833
                    NVL(source_org.circular_src, 'N') <> 'Y' AND
                    msi.inventory_item_id = l_inv_item_id and
                    msi.plan_id = -1
                    ORDER BY rank asc, allocation_percent desc;
          -- BUG 2283260 Note that join happens between msc_system_items(msi)
          -- and msc_sr_source_org (src) for org, instance as in certain cases
          -- join with msc_sr_assignments (msa) will bring no rows.
          -- Filter on item in msc_system_items.
          END IF;

          IF (x_atp_sources.organization_id.count = 0) then
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Atp_Sources: ' || 'no sources on global_bod level. look at global level');
             END IF;

             -- BUG 2283260 Join to msc_system_items to only obtain sources
             -- which are valid for the item(s).
             SELECT NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
                    NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,-1),
                    NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
                    NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
                    NVL(SOURCE_ORG.RANK, 0),
                    nvl(source_org.source_type,
                      decode(source_org.source_organization_id, to_number(null), 3, 1)),
                    0,
                    -1,
                    'XYZ',
                    NULL -- For supplier intransit LT project
             BULK COLLECT INTO
                    x_atp_sources.Organization_Id,
                    x_atp_sources.Instance_Id,
                    x_atp_sources.Supplier_Id,
                    x_atp_sources.Supplier_Site_Id,
                    x_atp_sources.Rank,
                    x_atp_sources.Source_Type,
                    x_atp_sources.Preferred,
                    x_atp_sources.Lead_Time,
                    x_atp_sources.Ship_Method,
                    x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
            FROM    msc_sourcing_rules msr,
                    msc_sr_receipt_org receipt_org,
                    msc_sr_source_org source_org,
                    msc_sr_assignments msa,
                    msc_system_items msi
            WHERE   msa.assignment_type = 1 and
                    msa.assignment_set_id = p_assign_set_id and
                    ---msa.inventory_item_id = l_inv_item_id and
                    msa.sourcing_rule_id = msr.sourcing_rule_id and
                    msr.status = 1 and
                    msr.sourcing_rule_type = 1 and
                    msr.sourcing_rule_id = receipt_org.sourcing_rule_id and
                    -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
                    TRUNC(NVL(receipt_org.disable_date, l_sysdate)) >= l_sysdate and
                    TRUNC(receipt_org.effective_date) <= l_sysdate and
                    receipt_org.sr_receipt_id = source_org.sr_receipt_id and
                    source_org.source_organization_id = msi.ORGANIZATION_ID and
                    source_org.sr_instance_id = msi.sr_instance_id and
                    -- ATP4drp Circular sources not supported by ATP.
                    --NVL(source_org.circular_src, 2) <> 1 AND
                    --Bug4567833
                    NVL(source_org.circular_src, 'N') <> 'Y' AND
                    msi.inventory_item_id = l_inv_item_id and
                    msi.plan_id = -1
                    ORDER BY rank asc, allocation_percent desc;
          -- BUG 2283260 Note that join happens between msc_system_items(msi)
          -- and msc_sr_source_org (src) for org, instance as in certain cases
          -- join with msc_sr_assignments (msa) will bring no rows.
          -- Filter on item in msc_system_items.
          END IF;

       END IF;
       FOR i in 1..x_atp_sources.Organization_Id.count Loop
            IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug( 'Atp_Sources: ' || 'x_atp_sources.Organization_Id ='|| x_atp_sources.Organization_Id(i));
        msc_sch_wb.atp_debug( 'Atp_Sources: ' || 'x_atp_sources.Supplier_Id ='|| x_atp_sources.Supplier_Id(i));
            END IF;
       END Loop;
    END IF;
        FOR i in 1..x_atp_sources.Organization_Id.count Loop
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Sources: ' || 'x_atp_sources.ship_method' || i ||' ' ||  x_atp_sources.ship_method(i));
        END IF;
     END LOOP;

     IF l_model_flag = 1
                         and x_atp_sources.instance_id.count > 0 THEN
        --- we found an ato item or a model. we need to connect to  msc_cto_sourcing to make sure
        -- that we have valid source
        l_source_list :=  x_atp_sources;
        MSC_ATP_CTO.Validate_CTO_Sources(l_source_list,
                                         l_line_ids,
                                         NVL(MSC_ATP_PVT.G_INSTANCE_ID, p_instance_id),
                                         p_session_id,
                                         x_return_status);
        x_atp_sources := l_source_list;

     END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** End Atp_Sources *****');
    END IF;

Exception

    WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Sources: ' || 'sqlcode : ' || sqlcode);
           msc_sch_wb.atp_debug('Atp_Sources: ' || 'sqlerrm : ' || sqlerrm);
        END IF;
        --x_return_status := FND_API.G_RET_STS_ERROR;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);  -- 4091487
    WHEN others THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Sources: ' || 'sqlcode : ' || sqlcode);
           msc_sch_wb.atp_debug('Atp_Sources: ' || 'sqlerrm : ' || sqlerrm);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;


END Atp_Sources;

--
-- neat trick to make atp_consume a THETA(n) algo
-- assume p_start_idx = 1, p_end_idx = n
--
-- Denote S(i) as the sum of the qtys on days 1..i
-- S(i..j) as the sum of the qtys on days i..j, j >= i
-- Q(i) as the qty on day i
-- A(i) as the correct accumulated qty on day i
--
-- We can break down the problem into 2 cases using these 2 facts
--
-- A(n) >= 0 iff all demands are satisfied.
-- A(n) = S(n).
--
-- For the case where S(n) >= 0, there are 4 main ideas.
--
-- 1) If Q(n) >= 0 and S(n-1) >= 0 then
--
-- for the array with qtys defined by
-- Q'(i) = Q(i) for i=1..n-1
-- the accumulated qtys A'(i) = A(i) for i = 1..n-1
--
-- Also, A(n) = A(n-1) + Q(n) => A(n-1) = A(n) - Q(n)
--
-- i.e. since S(n-1) >= 0 and Q(n) >=0, all netted demands are
-- satisfied by day n-1.
-- Hence after backward and forward consumption the net qty on
-- day n is still Q(n), and the net qtys on other days are the
-- same as if Q(n) were not there.
--
-- -----------------
--
-- 2) If S(i) < 0 then A(j) = 0 for j = 1..i
-- i.e. since the demands on days 1..i outweigh the supplies,
-- all the supplies during that time must be consumed. Also, we
-- already know all demands are satisfied.
--
-- -----------------
--
-- 3) If Q(n) < 0 and S(n-1) >=0 then
--
-- for the array with qtys defined by
-- Q'(n-1) = Q(n-1) + Q(n)
-- for i=1..n-2, Q'(i) = Q(i)
-- will result in the accumulated qtys A'(i) = A(i) for i=1..n-2.
--
-- Also, A(n-1) = A(n)
--
-- i.e. the last qty must be satisfied by backward consumption.
-- hence may simply push it back 1 day.
--
-- -----------------
--
-- 4) Since (1) and (3) reduce our problem size by 1 each time
-- and 2 is a terminating condition, we can use induction to
-- get a linear time algorithm.
--
-- In translating this to code, we use forward_acc to basically
-- handle (3).
--
-- ---------------------------------------------------
-- For the case when S(n) < 0, we simply use the fact that the old
-- atp_consume prioritizes demands so that earlier demands get first dibs on
-- the supply. So we calculate the total supply and give it to the
-- earliest demands
--
--

PROCEDURE atp_consume_range (
        p_atp_qty         IN OUT  NoCopy MRP_ATP_PUB.number_arr,
        p_start_idx       IN      NUMBER,
        p_end_idx         IN      NUMBER)
IS
j NUMBER;
acc NUMBER := 0;
real_dmd NUMBER := 0;
forward_acc NUMBER := 0;
BEGIN
        IF p_start_idx is null or p_end_idx is null or
           p_start_idx >= p_end_idx
        THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('atp_consume_range, bad indices: ' ||
                 p_start_idx || ':' || p_end_idx);
           END IF;
           return;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('atp_consume_range: arr size: ' || p_atp_qty.count());
           msc_sch_wb.atp_debug('                   start: ' || p_start_idx ||
                                'end: ' || p_end_idx);
        END IF;

	-- calculate S(n) and total supply (real_dmd)
	FOR i IN p_start_idx..p_end_idx LOOP
		acc := acc + p_atp_qty(i);
		IF p_atp_qty(i) > 0 THEN
			real_dmd := real_dmd + p_atp_qty(i);
		END IF;
	END LOOP;

	j := 0;
	IF acc >= 0 THEN
		forward_acc := p_atp_qty(p_end_idx);
		p_atp_qty(p_end_idx) := acc;

		FOR i in REVERSE p_start_idx..(p_end_idx-1) LOOP

			-- idea 1
			IF forward_acc > 0 THEN
				acc := acc - forward_acc;
				forward_acc := 0;
			END IF;

			-- idea 2
			IF acc < 0 THEN
				j := i;
				EXIT;
			END IF;

			-- idea 3
			forward_acc := forward_acc + p_atp_qty(i);
			p_atp_qty(i) := acc;
		END LOOP;

		-- idea 2
		FOR i in p_start_idx..j LOOP
			p_atp_qty(i) := 0;
		END LOOP;

	ELSE

		-- Distribute the supplies to the earliest demands
		j := p_end_idx;
		FOR i in p_start_idx..p_end_idx LOOP
			IF p_atp_qty(i) < 0 THEN
				real_dmd := real_dmd + p_atp_qty(i);
			END IF;

			IF real_dmd >= 0 THEN
				p_atp_qty(i) := 0;
			ELSE
				p_atp_qty(i) := real_dmd;
				j := i+1;
				EXIT;
			END IF;
		END LOOP;

		FOR i in j..p_end_idx LOOP
			IF p_atp_qty(i) < 0 THEN
				real_dmd := real_dmd + p_atp_qty(i);
			END IF;
			p_atp_qty(i) := real_dmd;
		END LOOP;
	END IF;

END atp_consume_range;

PROCEDURE atp_consume (
        p_atp_qty         IN OUT  NoCopy MRP_ATP_PUB.number_arr,
        p_counter         IN      NUMBER)
IS
BEGIN
        atp_consume_range(p_atp_qty, 1, p_counter);
END atp_consume;

PROCEDURE Details_Output (
  p_atp_period          IN       MRP_ATP_PUB.ATP_Period_Typ,
  p_atp_supply_demand   IN       MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_atp_period          IN OUT   NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand   IN OUT   NOCOPY  MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status       OUT      NoCopy VARCHAR2
) IS

l_period_count          PLS_INTEGER;
l_sd_count              PLS_INTEGER;
l_count                 PLS_INTEGER;

Begin

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** Begin Details_Output Procedure *****');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- dsting 10/1/02 supply/demand performance enh
    -- insert period data into mrp_atp_details_temp to transfer later
    -- since bulk binds across dblink are not supported.

    MSC_ATP_UTILS.Put_Period_Data(p_atp_period, NULL, MSC_ATP_PVT.G_SESSION_ID);
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Details_Output: ' || ' dsting expect 0 sd recs: ' || x_atp_supply_demand.level.count);
    END IF;
    RETURN;

    IF p_atp_period.level.COUNT > 0 THEN

        l_count := x_atp_period.level.COUNT;
        FOR l_period_count in 1..p_atp_period.level.COUNT LOOP
                    MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, x_return_status);

                    x_atp_period.Level(l_count + l_period_count) :=
                        p_atp_period.Level(l_period_count);
                    x_atp_period.Inventory_Item_Id(l_count + l_period_count) :=
                        p_atp_period.Inventory_Item_Id(l_period_count);
                    x_atp_period.Request_Item_Id(l_count + l_period_count) :=
                        p_atp_period.Request_Item_Id(l_period_count);
                    x_atp_period.Organization_Id(l_count + l_period_count) :=
                        p_atp_period.Organization_Id(l_period_count);
                    x_atp_period.Department_Id(l_count + l_period_count) :=
                        p_atp_period.Department_Id(l_period_count);
                    x_atp_period.Resource_Id(l_count + l_period_count) :=
                        p_atp_period.Resource_Id(l_period_count);
                    x_atp_period.Supplier_Id(l_count + l_period_count) :=
                        p_atp_period.Supplier_Id(l_period_count);
                    x_atp_period.Supplier_Site_Id(l_count + l_period_count) :=
                        p_atp_period.Supplier_Site_Id(l_period_count);
                    x_atp_period.From_Organization_Id(l_count + l_period_count)
                        := p_atp_period.From_Organization_Id(l_period_count);
                    x_atp_period.From_Location_Id(l_count + l_period_count) :=
                        p_atp_period.From_Location_Id(l_period_count);
                    x_atp_period.To_Organization_Id(l_count + l_period_count) :=
                        p_atp_period.To_Organization_Id(l_period_count);
                    x_atp_period.To_Location_Id(l_count + l_period_count) :=
                        p_atp_period.To_Location_Id(l_period_count);
                    x_atp_period.Ship_Method(l_count + l_period_count) :=
                        p_atp_period.Ship_Method(l_period_count);
                    x_atp_period.Uom(l_count + l_period_count) :=
                        p_atp_period.Uom(l_period_count);
                    x_atp_period.Total_Supply_Quantity(l_count + l_period_count)
                        := p_atp_period.Total_Supply_Quantity(l_period_count);
                    x_atp_period.Total_Demand_Quantity(l_count + l_period_count)
                        := p_atp_period.Total_Demand_Quantity(l_period_count);
                    x_atp_period.Period_Start_Date(l_count + l_period_count):=
                        p_atp_period.Period_Start_Date(l_period_count);
                    x_atp_period.Period_End_Date(l_count + l_period_count):=
                        p_atp_period.Period_End_Date(l_period_count);
                    x_atp_period.Period_Quantity(l_count + l_period_count):=
                        p_atp_period.Period_Quantity(l_period_count);
                    x_atp_period.Cumulative_Quantity(l_count + l_period_count):=
                        p_atp_period.Cumulative_Quantity(l_period_count);
                    x_atp_period.Identifier1(l_count + l_period_count):=
                        p_atp_period.Identifier1(l_period_count);
                    x_atp_period.Identifier2(l_count + l_period_count):=
                        p_atp_period.Identifier2(l_period_count);
                    x_atp_period.Identifier(l_count + l_period_count):=
                        p_atp_period.Identifier(l_period_count);
                    x_atp_period.scenario_Id(l_count + l_period_count) :=
                        p_atp_period.scenario_Id(l_period_count);
                    x_atp_period.pegging_id(l_count + l_period_count) :=
                        p_atp_period.pegging_id(l_period_count);
                    x_atp_period.end_pegging_id(l_count + l_period_count) :=
                        p_atp_period.end_pegging_id(l_period_count);


        END LOOP;
    END IF;

    IF p_atp_supply_demand.level.COUNT > 0 THEN
        l_count := x_atp_supply_demand.level.COUNT;

        FOR l_sd_count in 1..p_atp_supply_demand.level.COUNT LOOP
                    MSC_SATP_FUNC.Extend_Atp_Supply_Demand(x_atp_supply_demand,
                                             x_return_status);
                    x_atp_supply_demand.Level(l_count + l_sd_count):=
                        p_atp_supply_demand.Level(l_sd_count);
                    x_atp_supply_demand.Inventory_Item_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Inventory_Item_Id(l_sd_count);
                    x_atp_supply_demand.Request_Item_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Request_Item_Id(l_sd_count);
                    x_atp_supply_demand.Organization_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Organization_Id(l_sd_count);
                    x_atp_supply_demand.Department_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Department_Id(l_sd_count);
                    x_atp_supply_demand.Resource_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Resource_Id(l_sd_count);
                    x_atp_supply_demand.Supplier_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Supplier_Id(l_sd_count);
                    x_atp_supply_demand.Supplier_Site_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Supplier_Site_Id(l_sd_count);
                    x_atp_supply_demand.From_Organization_Id(l_count+l_sd_count)
                        := p_atp_supply_demand.From_Organization_Id(l_sd_count);
                    x_atp_supply_demand.From_Location_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.From_Location_Id(l_sd_count);
                    x_atp_supply_demand.To_Organization_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.To_Organization_Id(l_sd_count);
                    x_atp_supply_demand.To_Location_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.To_Location_Id(l_sd_count);
                    x_atp_supply_demand.Ship_Method(l_count+l_sd_count):=
                        p_atp_supply_demand.Ship_Method(l_sd_count);
                    x_atp_supply_demand.Uom(l_count+l_sd_count):=
                        p_atp_supply_demand.Uom(l_sd_count);
                    x_atp_supply_demand.Identifier1(l_count+l_sd_count):=
                        p_atp_supply_demand.Identifier1(l_sd_count);
                    x_atp_supply_demand.Identifier2(l_count+l_sd_count):=
                        p_atp_supply_demand.Identifier2(l_sd_count);
                    x_atp_supply_demand.Identifier3(l_count+l_sd_count):=
                        p_atp_supply_demand.Identifier3(l_sd_count);
                    x_atp_supply_demand.Identifier4(l_count+l_sd_count):=
                        p_atp_supply_demand.Identifier4(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Type(l_count+l_sd_count):=
                        p_atp_supply_demand.Supply_Demand_Type(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Source_Type(l_count+ l_sd_count)
                        := p_atp_supply_demand.Supply_Demand_Source_Type(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Source_Type_Name(l_count+l_sd_count):=
                        p_atp_supply_demand.Supply_Demand_Source_Type_Name(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Date(l_count+l_sd_count):=
                        p_atp_supply_demand.Supply_Demand_Date(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Quantity(l_count+l_sd_count) :=
                        p_atp_supply_demand.Supply_Demand_Quantity(l_sd_count);
                    x_atp_supply_demand.Identifier(l_count + l_sd_count):=
                        p_atp_supply_demand.Identifier(l_sd_count);
                    x_atp_supply_demand.scenario_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.scenario_Id(l_sd_count);
                    x_atp_supply_demand.Disposition_Type(l_count+l_sd_count):=
                        p_atp_supply_demand.Disposition_Type(l_sd_count);
                    x_atp_supply_demand.Disposition_Name(l_count+l_sd_count):=
                        p_atp_supply_demand.Disposition_Name(l_sd_count);
                    x_atp_supply_demand.Pegging_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Pegging_Id(l_sd_count);
                    x_atp_supply_demand.End_Pegging_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.End_Pegging_Id(l_sd_count);

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Details_Output: item '||
		p_atp_supply_demand.inventory_item_id(l_sd_count)||
		' : org '|| p_atp_supply_demand.organization_id(l_sd_count) ||
		' : qty '|| p_atp_supply_demand.supply_demand_quantity(l_sd_count) ||
		' : peg '|| p_atp_supply_demand.pegging_id(l_sd_count) ||
                ' : end peg ' || p_atp_supply_demand.end_pegging_id(l_sd_count));
	END IF;


        END LOOP;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** End Details_Output Procedure *****');
    END IF;

END Details_Output;


PROCEDURE get_dept_res_code (p_instance_id            IN NUMBER,
                             p_department_id          IN NUMBER,
                             p_resource_id            IN NUMBER,
                             p_organization_id        IN NUMBER,
                             x_department_code        OUT NoCopy VARCHAR2,
                             x_resource_code          OUT NoCopy VARCHAR2)
IS

BEGIN

  SELECT department_code,
         resource_code
  INTO   x_department_code,
         x_resource_code
  FROM   msc_department_resources
  WHERE  sr_instance_id = p_instance_id
  AND    organization_id = p_organization_id
  AND    plan_id = -1
  AND    department_id = p_department_id
  AND    resource_id = p_resource_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
  x_department_code := null;
  x_resource_code := null;

END get_dept_res_code;


PROCEDURE Get_SD_Period_Rec(
  p_atp_period          IN       MRP_ATP_PUB.ATP_Period_Typ,
  p_atp_supply_demand   IN       MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  p_identifier          IN       NUMBER,
  p_scenario_id         IN       NUMBER,
  p_new_scenario_id     IN       NUMBER,
  x_atp_period          IN OUT   NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand   IN OUT   NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status       OUT      NoCopy VARCHAR2
) IS

l_period_count  PLS_INTEGER;
l_sd_count      PLS_INTEGER;
l_count         PLS_INTEGER;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** Begin Get_SD_Period_Rec Procedure *****');
    END IF;

    FOR l_period_count in 1..p_atp_period.Level.COUNT LOOP

        IF (p_atp_period.identifier(l_period_count) = p_identifier) AND
           (p_atp_period.Scenario_Id(l_period_count) = p_scenario_id) THEN
                    l_count := x_atp_period.level.COUNT + 1;
                    MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, x_return_status);
                    x_atp_period.Level(l_count) :=
                        p_atp_period.Level(l_period_count);
                    x_atp_period.Inventory_Item_Id(l_count) :=
                        p_atp_period.Inventory_Item_Id(l_period_count);
                    x_atp_period.Request_Item_Id(l_count) :=
                        p_atp_period.Request_Item_Id(l_period_count);
                    x_atp_period.Organization_Id(l_count) :=
                        p_atp_period.Organization_Id(l_period_count);
                    x_atp_period.Department_Id(l_count) :=
                        p_atp_period.Department_Id(l_period_count);
                    x_atp_period.Resource_Id(l_count) :=
                        p_atp_period.Resource_Id(l_period_count);
                    x_atp_period.Supplier_Id(l_count) :=
                        p_atp_period.Supplier_Id(l_period_count);
                    x_atp_period.Supplier_Site_Id(l_count) :=
                        p_atp_period.Supplier_Site_Id(l_period_count);
                    x_atp_period.From_Organization_Id(l_count)
                        := p_atp_period.From_Organization_Id(l_period_count);
                    x_atp_period.From_Location_Id(l_count) :=
                        p_atp_period.From_Location_Id(l_period_count);
                    x_atp_period.To_Organization_Id(l_count) :=
                        p_atp_period.To_Organization_Id(l_period_count);
                    x_atp_period.To_Location_Id(l_count) :=
                        p_atp_period.To_Location_Id(l_period_count);
                    x_atp_period.Ship_Method(l_count) :=
                        p_atp_period.Ship_Method(l_period_count);
                    x_atp_period.Uom(l_count) :=
                        p_atp_period.Uom(l_period_count);
                    x_atp_period.Total_Supply_Quantity(l_count)
                        := p_atp_period.Total_Supply_Quantity(l_period_count);
                    x_atp_period.Total_Demand_Quantity(l_count)
                        := p_atp_period.Total_Demand_Quantity(l_period_count);
                    x_atp_period.Period_Start_Date(l_count):=
                        p_atp_period.Period_Start_Date(l_period_count);
                    x_atp_period.Period_End_Date(l_count):=
                        p_atp_period.Period_End_Date(l_period_count);
                    x_atp_period.Period_Quantity(l_count):=
                        p_atp_period.Period_Quantity(l_period_count);
                    x_atp_period.Cumulative_Quantity(l_count):=
                        p_atp_period.Cumulative_Quantity(l_period_count);
                    x_atp_period.Identifier1(l_count):=
                        p_atp_period.Identifier1(l_period_count);
                    x_atp_period.Identifier2(l_count):=
                        p_atp_period.Identifier2(l_period_count);
                    x_atp_period.Identifier(l_count):=
                        p_atp_period.Identifier(l_period_count);
                    x_atp_period.scenario_Id(l_count) := p_new_scenario_id;
                    x_atp_period.Pegging_Id(l_count):=
                        p_atp_period.Pegging_Id(l_period_count);
                    x_atp_period.End_Pegging_Id(l_count):=
                        p_atp_period.End_Pegging_Id(l_period_count);

        END IF;
    END LOOP;

    FOR l_sd_count in 1..p_atp_supply_demand.Level.COUNT LOOP
        IF (p_atp_supply_demand.identifier(l_sd_count) = p_identifier) AND
           (p_atp_supply_demand.Scenario_Id(l_sd_count)= p_scenario_id) THEN
                    l_count := x_atp_supply_demand.level.COUNT + 1;
                    MSC_SATP_FUNC.Extend_Atp_Supply_Demand(x_atp_supply_demand,
                                             x_return_status);
                    x_atp_supply_demand.Level(l_count):=
                        p_atp_supply_demand.Level(l_sd_count);
                    x_atp_supply_demand.Inventory_Item_Id(l_count):=
                        p_atp_supply_demand.Inventory_Item_Id(l_sd_count);
                    x_atp_supply_demand.Request_Item_Id(l_count):=
                        p_atp_supply_demand.Request_Item_Id(l_sd_count);
                    x_atp_supply_demand.Organization_Id(l_count):=
                        p_atp_supply_demand.Organization_Id(l_sd_count);
                    x_atp_supply_demand.Department_Id(l_count):=
                        p_atp_supply_demand.Department_Id(l_sd_count);
                    x_atp_supply_demand.Resource_Id(l_count):=
                        p_atp_supply_demand.Resource_Id(l_sd_count);
                    x_atp_supply_demand.Supplier_Id(l_count):=
                        p_atp_supply_demand.Supplier_Id(l_sd_count);
                    x_atp_supply_demand.Supplier_Site_Id(l_count):=
                        p_atp_supply_demand.Supplier_Site_Id(l_sd_count);
                    x_atp_supply_demand.From_Organization_Id(l_count)
                        := p_atp_supply_demand.From_Organization_Id(l_sd_count);
                    x_atp_supply_demand.From_Location_Id(l_count):=
                        p_atp_supply_demand.From_Location_Id(l_sd_count);
                    x_atp_supply_demand.To_Organization_Id(l_count):=
                        p_atp_supply_demand.To_Organization_Id(l_sd_count);
                    x_atp_supply_demand.To_Location_Id(l_count):=
                        p_atp_supply_demand.To_Location_Id(l_sd_count);
                    x_atp_supply_demand.Ship_Method(l_count):=
                        p_atp_supply_demand.Ship_Method(l_sd_count);
                    x_atp_supply_demand.Uom(l_count):=
                        p_atp_supply_demand.Uom(l_sd_count);
                    x_atp_supply_demand.Identifier1(l_count):=
                        p_atp_supply_demand.Identifier1(l_sd_count);
                    x_atp_supply_demand.Identifier2(l_count):=
                        p_atp_supply_demand.Identifier2(l_sd_count);
                    x_atp_supply_demand.Identifier3(l_count):=
                        p_atp_supply_demand.Identifier3(l_sd_count);
                    x_atp_supply_demand.Identifier4(l_count):=
                        p_atp_supply_demand.Identifier4(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Type(l_count):=
                        p_atp_supply_demand.Supply_Demand_Type(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Source_Type(l_count)
                        := p_atp_supply_demand.Supply_Demand_Source_Type(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Source_Type_Name(l_count)
                        := p_atp_supply_demand.Supply_Demand_Source_Type_Name(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Date(l_count):=
                        p_atp_supply_demand.Supply_Demand_Date(l_sd_count);
                    x_atp_supply_demand.Supply_Demand_Quantity(l_count) :=
                        p_atp_supply_demand.Supply_Demand_Quantity(l_sd_count);
                    x_atp_supply_demand.Identifier(l_count):=
                        p_atp_supply_demand.Identifier(l_sd_count);
                    x_atp_supply_demand.scenario_Id(l_count):=p_new_scenario_id;
                    x_atp_supply_demand.Pegging_Id(l_count):=
                        p_atp_supply_demand.Pegging_Id(l_sd_count);
                    x_atp_supply_demand.Disposition_Type(l_count):=
                        p_atp_supply_demand.Disposition_Type(l_sd_count);
                    x_atp_supply_demand.Disposition_Name(l_count):=
                        p_atp_supply_demand.Disposition_Name(l_sd_count);
                    x_atp_supply_demand.End_Pegging_Id(l_count):=
                        p_atp_supply_demand.End_Pegging_Id(l_sd_count);

IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('Get_SD_Period_Rec: ' || 'Details_Output: item '|| p_atp_supply_demand.inventory_item_id(l_sd_count)
	|| ': org '|| p_atp_supply_demand.organization_id(l_sd_count)
	|| ': quantity '|| p_atp_supply_demand.supply_demand_quantity(l_sd_count)
	|| ': peg '|| p_atp_supply_demand.pegging_id(l_sd_count));
END IF;

        END IF;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** End Get_SD_Period_Rec Procedure *****');
    END IF;

END Get_SD_Period_Rec;


PROCEDURE get_org_default_info (
	p_instance_id            	IN 	NUMBER,
	p_organization_id        	IN 	NUMBER,
	x_default_atp_rule_id       	OUT 	NoCopy NUMBER,
	x_calendar_code             	OUT 	NoCopy VARCHAR2,
	x_calendar_exception_set_id 	OUT 	NoCopy NUMBER,
	x_default_demand_class      	OUT 	NoCopy VARCHAR2,
	x_org_code			OUT	NoCopy VARCHAR2)
IS

BEGIN

    SELECT default_atp_rule_id,
           calendar_code,
           calendar_exception_set_id,
           default_demand_class,
	   organization_code
    INTO   x_default_atp_rule_id,
           x_calendar_code,
           x_calendar_exception_set_id,
           x_default_demand_class,
	   x_org_code
    FROM   msc_trading_partners
    WHERE  sr_tp_id = p_organization_id
    AND    sr_instance_id = p_instance_id
    AND    partner_type = 3;

EXCEPTION WHEN others THEN
  x_default_atp_rule_id := null;
  x_calendar_code := null;
  x_calendar_exception_set_id := null;
  x_default_demand_class := null;
  x_org_code := null;
END get_org_default_info;

PROCEDURE inv_primary_uom_conversion (p_instance_id        IN  NUMBER,
                                      p_organization_id    IN  NUMBER,
                                      p_inventory_item_id  IN  NUMBER,
                                      p_uom_code           IN  VARCHAR2,
                                      x_primary_uom_code   OUT NoCopy VARCHAR2,
                                      x_conversion_rate    OUT NoCopy NUMBER
                                      )
IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN --bug3110023
        msc_sch_wb.atp_debug('**************** inv_primary_uom_conversion Begin ***************');
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'p_instance_id       - ' || p_instance_id);
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'p_inventory_item_id - ' || MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id);
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'p_inventory_item_id - ' || p_inventory_item_id);
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'p_organization_id   - ' || p_organization_id);
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'p_uom_code   - ' || p_uom_code);
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'primary_uom_code   - ' || MSC_ATP_PVT.G_ITEM_INFO_REC.uom_code);
   END IF;
   /* Tuned for performance bug 2484964 */
    /* 4192057: Use the item info available in G_item_ifo_rec
       instead of connecting to msc_system_items table
    SELECT items.uom_code,
           conversion_rate
    INTO   x_primary_uom_code,
           x_conversion_rate
    FROM   msc_uom_conversions_view mucv,
           msc_system_items items
    WHERE  items.sr_inventory_item_id = p_inventory_item_id
    AND    items.organization_id = p_organization_id
    AND    items.plan_id = -1
    AND    items.sr_instance_id = p_instance_id
    AND    mucv.uom_code = p_uom_code
    AND    mucv.primary_uom_code  = items.uom_code
    AND    mucv.inventory_item_id = items.inventory_item_id
    AND    mucv.organization_id = items.organization_id
    AND    mucv.sr_instance_id = items.sr_instance_id;
    --AND    mucv.organization_id = p_organization_id
    --AND    mucv.sr_instance_id = p_instance_id;
    */
  IF p_uom_code <> MSC_ATP_PVT.G_ITEM_INFO_REC.uom_code THEN --bug3110023
   SELECT primary_uom_code,
          conversion_rate
   INTO   x_primary_uom_code,
          x_conversion_rate
   FROM   msc_uom_conversions_view mucv
   WHERE  mucv.uom_code = p_uom_code
   AND    mucv.primary_uom_code  = MSC_ATP_PVT.G_ITEM_INFO_REC.uom_code
   AND    mucv.inventory_item_id = MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id
   AND    mucv.organization_id = p_organization_id
   AND    mucv.sr_instance_id = p_instance_id;
  ELSE
   x_primary_uom_code := p_uom_code;
   x_conversion_rate := 1;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN --bug3110023
      msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'x_primary_uom_code   - ' || x_primary_uom_code);
      msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'x_conversion_rate   - ' || x_conversion_rate);
  END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
  x_primary_uom_code := p_uom_code;
  x_conversion_rate := 1;
  IF PG_DEBUG in ('Y', 'C') THEN --bug3110023
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : Inside NO_DATA_FOUND  ');
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'x_primary_uom_code   - ' || x_primary_uom_code);
        msc_sch_wb.atp_debug('inv_primary_uom_conversion : ' || 'x_conversion_rate   - ' || x_conversion_rate);
  END IF;
END inv_primary_uom_conversion;


PROCEDURE Extend_Atp_Sources (
  p_atp_sources         IN OUT NOCOPY  MRP_ATP_PVT.Atp_Source_Typ,
  x_return_status       OUT      NoCopy VARCHAR2)
IS

Begin

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    p_atp_sources.Organization_Id.EXTEND;
    p_atp_sources.Supplier_Id.EXTEND;
    p_atp_sources.Supplier_Site_Id.EXTEND;
    p_atp_sources.Rank.EXTEND;
    p_atp_sources.Source_Type.EXTEND;
    p_atp_sources.Instance_Id.EXTEND;
    p_atp_sources.Preferred.EXTEND;
    p_atp_sources.Lead_Time.EXTEND;
    p_atp_sources.Ship_Method.EXTEND;

END;


-- 24x7 ATP
--  Function logic changed to support 24x7 ATP.
Procedure Get_Plan_Info(
    p_instance_id        IN NUMBER,
    p_inventory_item_id  IN NUMBER,
    p_organization_id    IN NUMBER,
    p_demand_class       IN VARCHAR2,
    -- x_plan_id         OUT NoCopy NUMBER,  commented for bug 2392456
    -- x_assign_set_id   OUT NoCopy NUMBER   comented for bug 2392456
    x_plan_info_rec      OUT NoCopy MSC_ATP_PVT.plan_info_rec,   -- added for bug 2392456
    p_parent_plan_id     IN NUMBER DEFAULT NULL, --bug3510475
    p_time_phased_atp    IN VARCHAR2 := 'N' -- time_phased_atp
)
IS
l_dc_atp_flag       NUMBER := 2;
l_summary_flag      NUMBER;

--24x7
l_using_new_plan    number;
l_plan_info_rec     MSC_ATP_PVT.plan_info_rec;

--bug 2854351
l_plan_ids          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
i                   number;
l_generic_plan      number;

--ATP4drp local variable for time phased ATP.
l_time_phased_atp   VARCHAR2(2);
-- END ATP4drp

BEGIN
    -- ngoel, modified to check for ATP rule for demand class ATP

    -- initialize x_plan_info_rec for bug 2392456 starts
    x_plan_info_rec.plan_id                 := null;
    x_plan_info_rec.plan_name               := null;
    x_plan_info_rec.assignment_set_id       := null;
    x_plan_info_rec.plan_start_date         := null;
    x_plan_info_rec.plan_cutoff_date        := null;
    -- changes for bug 2392456 ends.

    x_plan_info_rec.summary_flag            := null; -- 24x7
    x_plan_info_rec.copy_plan_id            := null; -- 24x7
    x_plan_info_rec.subst_flag              := null; -- 24x7

    -- Additional Fields for Supplier Capacity and Lead Time (SCLT) Project.
    x_plan_info_rec.sr_instance_id          := null;
    x_plan_info_rec.organization_id         := null;
    x_plan_info_rec.curr_cutoff_date        := null;
    --add for plan by request date
    x_plan_info_rec.schedule_by_date_type   := null;

    -- For ship_rec_cal project.
    x_plan_info_rec.enforce_pur_lead_time   := null;
    x_plan_info_rec.enforce_sup_capacity    := null;

    -- For ATP4drp project
    x_plan_info_rec.plan_type               := null;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**************** Get_Plan_Info Begin ***************');
        msc_sch_wb.atp_debug('Get_Plan_Info : ' || 'p_instance_id       - ' || p_instance_id);
        msc_sch_wb.atp_debug('Get_Plan_Info : ' || 'p_inventory_item_id - ' || p_inventory_item_id);
        msc_sch_wb.atp_debug('Get_Plan_Info : ' || 'p_organization_id   - ' || p_organization_id);
        msc_sch_wb.atp_debug('Get_Plan_Info : ' || 'p_demand_class      - ' || p_demand_class);
        msc_sch_wb.atp_debug('Get_Plan_Info : ' || 'p_time_phased_atp   - ' || p_time_phased_atp);
    END IF;

    --  bug3510475. Check if the plan for Parent ORG /ITEM
    --already exists. if the parent plan exists, verify if the current
    --Item / Org is also planned in parent plan. Do not select from
    --msc_atp_plan_sn in this case.
    IF p_parent_plan_id is not null then
        BEGIN
          SELECT  plan_id
          INTO    x_plan_info_rec.plan_id
          FROM    msc_system_items
          WHERE   sr_instance_id = p_instance_id
          AND     organization_id = p_organization_id
          AND     sr_inventory_item_id = p_inventory_item_id
          AND     plan_id = p_parent_plan_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
                 x_plan_info_rec.plan_id := null;
        END;
    END IF;
    --bug3510475 add the x_plan_info_rec.plan_id condition
    IF MSC_ATP_PVT.G_ALLOCATED_ATP = 'N' and
         p_demand_class IS NOT NULL        and
         x_plan_info_rec.plan_id is NULL THEN

        -- Check if the demand class ATP is needed
        -- select item level and org level atp rules
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Item / Org is not planned in parent plan');
        END IF;
        BEGIN

            -- Bug 1757259, modified to replace = to IN for subquery. Also added distinct
            SELECT  demand_class_atp_flag
            INTO    l_dc_atp_flag
            FROM    msc_atp_rules
            WHERE   sr_instance_id = p_instance_id
            AND     rule_id IN (
                    SELECT  distinct NVL(mi.atp_rule_id, tp.default_atp_rule_id)
                    FROM    msc_system_items mi,
                            msc_trading_partners tp
                    WHERE   mi.organization_id = tp.sr_tp_id
                    AND     mi.sr_instance_id = tp.sr_instance_id
                    AND     tp.partner_type = 3
                    AND     mi.plan_id = -1
                    AND     mi.sr_instance_id = p_instance_id
                    AND     mi.organization_id = p_organization_id
                    AND     mi.sr_inventory_item_id = p_inventory_item_id);
        EXCEPTION
            WHEN no_data_found THEN
                l_dc_atp_flag := 2;
        END;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Plan_Info: ' || 'l_dc_atp_flag : ' ||l_dc_atp_flag);
        END IF;
    END IF;

    BEGIN

        --bug3510475 add the x_plan_info_rec.plan_id condition
        IF ((NVL(l_dc_atp_flag, 2) = 1) AND
            x_plan_info_rec.plan_id IS NULL) THEN


            -- select the plan_id based on the demand class
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Plan_Info: ' || 'Inside Demand Class ATP');
            END IF;


            /*SELECT  plan_id
                    -- INTO   x_plan_id  commented for bug 2392456
            INTO    x_plan_info_rec.plan_id   -- changed for bug 2392456
            FROM    msc_atp_plan_sn

            WHERE   demand_class =  p_demand_class
            AND     sr_instance_id = p_instance_id
            AND     organization_id = p_organization_id
            AND     sr_inventory_item_id = p_inventory_item_id; */

            --CHANGES MADE FOR HUBnSPOKE
	   SELECT  plan_id
           INTO    x_plan_info_rec.plan_id
	   FROM
	   	(SELECT  plan_id,Rank,completion_date
               	FROM    msc_atp_plan_sn
               	WHERE   demand_class = p_demand_class
                AND     sr_instance_id = p_instance_id
                AND     organization_id = p_organization_id
                AND     sr_inventory_item_id = p_inventory_item_id
                ORDER  BY Rank asc,completion_date desc,plan_id asc)
                WHERE ROWNUM=1;



        END IF;
            EXCEPTION
                WHEN no_data_found THEN
                    -- x_plan_id := NULL;  commented for bug 2392456
                    x_plan_info_rec.plan_id  := NULL;  -- changed for bug 2392456

        END;

        -- IF x_plan_id IS NULL THEN   commented for bug 2392456
        IF x_plan_info_rec.plan_id IS NULL THEN  -- changed for bug 2392456

            -- AATP: if we are doing allocated atp or no demand_class atp in atp_rule,
            -- we don't want to pick a plan with demand class on that plan.
            -- For AATP we want to pick a generic plan and then do allocation on it.
            -- Also, in case of demand class ATP, if we dont get a plan, we will select
            -- generic plan_id

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Plan_Info: ' || 'Inside Generic Plan');
            END IF;

            -- 1873918: PDS-ODS fix
            -- add error handling
            BEGIN
                --2854351
                /*SELECT plan_id
                -- INTO   x_plan_id  commented for bug 2392456
                INTO   x_plan_info_rec.plan_id   -- changed for bug 2392456
                FROM   msc_atp_plan_sn
                WHERE  demand_class IS NULL
                AND    sr_instance_id = p_instance_id
                AND    organization_id = p_organization_id
                AND    sr_inventory_item_id = p_inventory_item_id;
                */
                -- Bug 3086444, 3086366 : UNION ALL and rownum = 1 added

                select  plan_id
                bulk collect into l_plan_ids
                from
                    (
                        SELECT  plan_id,Rank,completion_date
                        FROM    msc_atp_plan_sn
                        WHERE   demand_class IS NULL
                        AND     sr_instance_id = p_instance_id
                        AND     organization_id = p_organization_id
                        AND     sr_inventory_item_id = p_inventory_item_id

                        UNION ALL

                        SELECT  -200 PLAN_ID, 20, to_date(null)
                        from    msc_atp_plan_sn
                        WHERE   rownum = 1
                        ORDER  BY Rank asc,completion_date desc,plan_id asc
                    );

                l_generic_plan := 1;

            EXCEPTION
                WHEN no_data_found THEN
                    msc_sch_wb.atp_debug('No data Found exception');
                    -- x_plan_id := NULL;
                    x_plan_info_rec.plan_id := NULL;
                    l_generic_plan := 1;

            END;

        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Total l_plan_ids count := ' || l_plan_ids.count);
        END IF;

        IF NVL(l_generic_plan, -1) = 1 THEN
            IF l_plan_ids.count = 0 THEN
            --- this is planned down time.
            -- The snapshot is being refreshed.
            -- Bug 2919892
            x_plan_info_rec.plan_id := -300;
            RETURN;
        ELSIF l_plan_ids.count = 1 THEN
            --ods to pds switch
            x_plan_info_rec.plan_id := NULL;
        ELSE
            FOR i in 1..l_plan_ids.count LOOP
                IF l_plan_ids(i) <> -200 THEN
                    x_plan_info_rec.plan_id := l_plan_ids(i);
                    EXIT;
                END IF;
            END LOOP;
         END IF; -- IF l_plan_ids.count = 0 THEN
    END IF; --- IF NVL(l_generic_plan, -1) THEN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Plan_Info: ' || 'selected plan_id : '||x_plan_info_rec.plan_id);
    END IF;  -- changed for bug 2392456
    -- msc_sch_wb.atp_debug('selected plan_id : '||x_plan_id);  commented for bug 2392456

    -- 1873918 PDS-ODS fix
    -- IF x_plan_id is null, then we switch to ODS, x_plan_id = -1
    -- IF x_plan_id is not null, we check the completion date,
    --     if no completion date, we should raise error later. set
    --                 x_plan_id to null
    --     if we have completion date, then keep the x_plan_id

    -- IF x_plan_id IS NULL THEN    commented for bug 2392456
    IF x_plan_info_rec.plan_id IS NULL THEN  -- changed for bug 2392456
        -- bug 2119013
        -- do not switch for multiorg/multilevel ato line.
        -- only doing the switch if this line is not MLATO.

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Plan_Info: ' || 'MSC_ATP_PVT.G_CTO_LINE='||MSC_ATP_PVT.G_CTO_LINE);
        END IF;

        IF (NVL(MSC_ATP_PVT.G_CTO_LINE, 'N') = 'N') THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Plan_Info: ' || 'x_plan_id is null, set to -1');
            END IF;
            -- x_plan_id := -1;  commented for bug 2392456
            x_plan_info_rec.plan_id := -1;  -- changed for  bug 2392456
        END IF;

    ELSE

        -- x_plan_id has some value
        BEGIN

            l_using_new_plan := 0;
            -- select designator type and assignment set
            -- bug 1384242, add the check to see if the plan has complete.
            -- we cannot do atp if the plan is running (not complete)
            -- this is because we only refresh snapshot when the plan finishes
            -- or inventory atp flag has been changed.  We don't refresh the
            -- snapshot when a plan is running.
            -- also select compile_designator for bug 2392456

            -- 24x7 : Removed join with msc_designators

            SELECT  plans.curr_assignment_set_id,
                    plans.compile_designator,
                    x_plan_info_rec.plan_id,
                    NVL(plans.summary_flag, 1),
                    decode(plans.plan_type,1,nvl(plans.use_end_item_substitutions,2),
                                           2,nvl(plans.use_end_item_substitutions,2),
                                           3,nvl(plans.use_end_item_substitutions,2),
                                           5,nvl(plans.use_end_item_substitutions,2),
                                           1),
                    NVL(plans.copy_plan_id,-1),
                    -- second plan for 24x7
                    plans2.curr_assignment_set_id,
                    plans2.compile_designator,
                    plans2.plan_id,
                    NVL(plans2.summary_flag, 1),
                    decode(plans2.plan_type,1,nvl(plans2.use_end_item_substitutions,2),
                                           2,nvl(plans2.use_end_item_substitutions,2),
                                           3,nvl(plans2.use_end_item_substitutions,2),
                                           5,nvl(plans2.use_end_item_substitutions,2),
                                           1),
                    NVL(plans2.copy_plan_id,-1),
                    -- Supplier Capacity and Lead Time (SCLT) Proj.
                    plans.sr_instance_id,
                    plans.organization_id,
                    trunc(nvl(plans.plan_start_date, plans.curr_start_date)), --8791503, RP-GOP Integration
                    trunc(plans.cutoff_date),
                    plans.curr_cutoff_date,
                    DECODE(plans.plan_type, 4, 2,
                        DECODE(plans.daily_material_constraints, 1, 1,
                            DECODE(plans.daily_resource_constraints, 1, 1,
                                DECODE(plans.weekly_material_constraints, 1, 1,
                                    DECODE(plans.weekly_resource_constraints, 1, 1,
                                        DECODE(plans.period_material_constraints, 1, 1,
                                            DECODE(plans.period_resource_constraints, 1, 1, 2)
                                              )
                                          )
                                      )
                                  )
                              )
                          ), -- 2859130
                    plans2.sr_instance_id,
                    plans2.organization_id,
                    trunc(nvl(plans2.plan_start_date, plans2.curr_start_date)), --8791503, RP-GOP Integration
                    trunc(plans2.cutoff_date),
                    plans2.curr_cutoff_date,
                    DECODE(plans2.plan_type, 4, 2,
                        DECODE(plans2.daily_material_constraints, 1, 1,
                            DECODE(plans2.daily_resource_constraints, 1, 1,
                                DECODE(plans2.weekly_material_constraints, 1, 1,
                                    DECODE(plans2.weekly_resource_constraints, 1, 1,
                                        DECODE(plans2.period_material_constraints, 1, 1,
                                            DECODE(plans2.period_resource_constraints, 1, 1, 2)
                                              )
                                          )
                                      )
                                  )
                              )
                          ), -- 2859130      ,
                    plans.schedule_by,
                    plans2.schedule_by,
                    -- ship_rec_cal changes begin
                    NVL(plans.daily_material_constraints, 2),
                    --bug 4100346: For unconstrained plan always enforce purchasing lead time
                    DECODE(plans.plan_type, 4, 1,
                        DECODE(plans.daily_material_constraints, 1, NVL(plans.enforce_pur_lt_constraints, 2),
                            DECODE(plans.daily_resource_constraints, 1, NVL(plans.enforce_pur_lt_constraints, 2),
                                DECODE(plans.weekly_material_constraints, 1, NVL(plans.enforce_pur_lt_constraints, 2),
                                    DECODE(plans.weekly_resource_constraints, 1, NVL(plans.enforce_pur_lt_constraints, 2),
                                        DECODE(plans.period_material_constraints, 1, NVL(plans.enforce_pur_lt_constraints, 2),
                                            DECODE(plans.period_resource_constraints, 1, NVL(plans.enforce_pur_lt_constraints, 2), 1)
                                              )
                                          )
                                      )
                                  )
                              )
                          ),
                    --NVL(plans.enforce_pur_lt_constraints, 2),
                    NVL(plans2.daily_material_constraints, 2),
                    --bug 4100346: For unconstrained plan always enforce purchasing lead time
                    --NVL(plans2.enforce_pur_lt_constraints, 2),
                    DECODE(plans2.plan_type, 4, 1,
                        DECODE(plans2.daily_material_constraints, 1, NVL(plans2.enforce_pur_lt_constraints, 2),
                            DECODE(plans2.daily_resource_constraints, 1, NVL(plans2.enforce_pur_lt_constraints, 2),
                                DECODE(plans2.weekly_material_constraints, 1, NVL(plans2.enforce_pur_lt_constraints, 2),
                                    DECODE(plans2.weekly_resource_constraints, 1, NVL(plans2.enforce_pur_lt_constraints, 2),
                                        DECODE(plans2.period_material_constraints, 1, NVL(plans2.enforce_pur_lt_constraints, 2),
                                            DECODE(plans2.period_resource_constraints, 1, NVL(plans2.enforce_pur_lt_constraints, 2), 1)
                                              )
                                          )
                                      )
                                  )
                              )
                          ),
                    -- ship_rec_cal changes end
                    -- ATP4drp changes begin
                    NVL(plans.plan_type, 1), -- Default is MRP plan
                    NVL(plans2.plan_type, 1),
                    plans.itf_horiz_days,   -- Obtain the ITF_HORIZ_DAYS
                    plans2.itf_horiz_days
                    -- ATP4drp changes end
            INTO    x_plan_info_rec.assignment_set_id,
                    x_plan_info_rec.plan_name,
                    x_plan_info_rec.plan_id,
                    --l_summary_flag,
                    x_plan_info_rec.summary_flag,
                    --MSC_ATP_PVT.G_PLAN_SUBST_FLAG,
                    x_plan_info_rec.subst_flag,
                    x_plan_info_rec.copy_plan_id,
                    l_plan_info_rec.assignment_set_id,
                    l_plan_info_rec.plan_name,
                    l_plan_info_rec.plan_id,
                    l_plan_info_rec.summary_flag,
                    l_plan_info_rec.subst_flag,
                    l_plan_info_rec.copy_plan_id,
                    -- Supplier Capacity and Lead Time (SCLT) Proj.
                    x_plan_info_rec.sr_instance_id,
                    x_plan_info_rec.organization_id,
                    x_plan_info_rec.plan_start_date,
                    x_plan_info_rec.plan_cutoff_date,
                    x_plan_info_rec.curr_cutoff_date,
                    x_plan_info_rec.optimized_plan, -- 2859130
                    l_plan_info_rec.sr_instance_id,
                    l_plan_info_rec.organization_id,
                    l_plan_info_rec.plan_start_date,
                    l_plan_info_rec.plan_cutoff_date,
                    l_plan_info_rec.curr_cutoff_date,
                    l_plan_info_rec.optimized_plan,-- 2859130
                    --plan by request date changes begin
                    x_plan_info_rec.schedule_by_date_type,
                    l_plan_info_rec.schedule_by_date_type,
                    --plan by request date changes end
                    -- ship_rec_cal changes begin
                    x_plan_info_rec.enforce_sup_capacity,
                    x_plan_info_rec.enforce_pur_lead_time,
                    l_plan_info_rec.enforce_sup_capacity,
                    l_plan_info_rec.enforce_pur_lead_time,
                    -- ship_rec_cal changes end
                    -- ATP4drp changes begin
                    x_plan_info_rec.plan_type,
                    l_plan_info_rec.plan_type,
                    x_plan_info_rec.itf_horiz_days,
                    l_plan_info_rec.itf_horiz_days
                    -- ATP4drp changes end
            FROM    msc_plans plans,
                    msc_plans plans2
            WHERE   plans.plan_id = x_plan_info_rec.plan_id
            AND     plans.plan_completion_date is not null
            AND     plans.data_completion_date is not null
            and     plans.plan_id = plans2.copy_plan_id (+);


            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('G_SYNC_ATP_CHECK  := '|| MSC_ATP_PVT.G_SYNC_ATP_CHECK);
                msc_sch_wb.atp_debug (' ---- ');
                msc_sch_wb.atp_debug ('Query Output : Old Plan ID : ' || x_plan_info_rec.plan_id);
                msc_sch_wb.atp_debug (' plan name:     : ' || x_plan_info_rec.plan_name) ;
                msc_sch_wb.atp_debug (' assign_set_id  : ' || x_plan_info_rec.assignment_set_id) ;
                msc_sch_wb.atp_debug (' summary_flag   : ' || x_plan_info_rec.summary_flag);
                msc_sch_wb.atp_debug (' substitition   : ' || x_plan_info_rec.subst_flag);
                msc_sch_wb.atp_debug (' copy_plan_id   : ' || x_plan_info_rec.copy_plan_id);
                msc_sch_wb.atp_debug (' start date     : ' || x_plan_info_rec.plan_start_date);
                msc_sch_wb.atp_debug (' cutoff date    : ' || x_plan_info_rec.plan_cutoff_date);
                msc_sch_wb.atp_debug (' curr_cutoff dt : ' || x_plan_info_rec.curr_cutoff_date);
                msc_sch_wb.atp_debug (' sr_instance_id : ' || x_plan_info_rec.sr_instance_id);
                msc_sch_wb.atp_debug (' org_id         : ' || x_plan_info_rec.organization_id);
                -- ship_rec_cal changes begin
                msc_sch_wb.atp_debug (' enforce_sup_capacity    : ' || x_plan_info_rec.enforce_sup_capacity);
                msc_sch_wb.atp_debug (' enforce_pur_lead_time   : ' || x_plan_info_rec.enforce_pur_lead_time);
                -- ship_rec_cal changes end
                -- ATP4drp changes begin
                msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                msc_sch_wb.atp_debug (' optimized_plan   : ' || x_plan_info_rec.optimized_plan);
                msc_sch_wb.atp_debug (' plan_type        : ' || x_plan_info_rec.plan_type);
                msc_sch_wb.atp_debug (' ITF_HORIZ_DAYS   : ' || x_plan_info_rec.itf_horiz_days);
                -- ATP4drp changes end
                msc_sch_wb.atp_debug (' ---- ');
                msc_sch_wb.atp_debug ('Query Output : New Plan ID : ' || l_plan_info_rec.plan_id);
                msc_sch_wb.atp_debug (' plan name:     : ' || l_plan_info_rec.plan_name) ;
                msc_sch_wb.atp_debug (' assign_set_id  : ' || l_plan_info_rec.assignment_set_id) ;
                msc_sch_wb.atp_debug (' summary_flag   : ' || l_plan_info_rec.summary_flag);
                msc_sch_wb.atp_debug (' substitition   : ' || l_plan_info_rec.subst_flag);
                msc_sch_wb.atp_debug (' copy_plan_id   : ' || l_plan_info_rec.copy_plan_id);
                msc_sch_wb.atp_debug (' start date     : ' || l_plan_info_rec.plan_start_date);
                msc_sch_wb.atp_debug (' cutoff date    : ' || l_plan_info_rec.plan_cutoff_date);
                msc_sch_wb.atp_debug (' curr_cutoff dt : ' || l_plan_info_rec.curr_cutoff_date);
                msc_sch_wb.atp_debug (' sr_instance_id : ' || l_plan_info_rec.sr_instance_id);
                msc_sch_wb.atp_debug (' org_id         : ' || l_plan_info_rec.organization_id);
                -- ship_rec_cal changes begin
                msc_sch_wb.atp_debug (' enforce_sup_capacity    : ' || l_plan_info_rec.enforce_sup_capacity);
                msc_sch_wb.atp_debug (' enforce_pur_lead_time   : ' || l_plan_info_rec.enforce_pur_lead_time);
                msc_sch_wb.atp_debug (' ---- ');
                -- ship_rec_cal changes end
                -- ATP4drp changes begin
                msc_sch_wb.atp_debug (' optimized_plan   : ' || l_plan_info_rec.optimized_plan);
                msc_sch_wb.atp_debug (' plan_type        : ' || l_plan_info_rec.plan_type);
                msc_sch_wb.atp_debug (' ITF_HORIZ_DAYS   : ' || l_plan_info_rec.itf_horiz_days);
                msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                -- ATP4drp changes end
                msc_sch_wb.atp_debug (' ---- ');
            END IF;

            if (NVL(MSC_ATP_PVT.G_SYNC_ATP_CHECK, 'N') = 'Y') then
                -- this is a sync call
                l_using_new_plan := 1;
                if PG_DEBUG in ('Y','C') then
                    msc_sch_wb.atp_debug ('Sync process. Switching plan to '|| l_plan_info_rec.plan_id);
                end if;
                if (l_plan_info_rec.plan_id IS  NULL) then
                    if PG_DEBUG in ('Y','C') then
                        msc_sch_wb.atp_debug ('Cannot find new plan during SYNC ATP check call');
                        msc_sch_wb.atp_debug ('Going by old plan to account for extended sync');
                    end if;
                    l_plan_info_rec := x_plan_info_rec;
                end if;

                -- copy new plan data to the old plan
                x_plan_info_rec := l_plan_info_rec;
            end if;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_plan_info_rec.plan_id             := NULL;
                x_plan_info_rec.plan_name           := NULL;
                x_plan_info_rec.assignment_set_id   := NULL;
                -- Additional Fields for Supplier Capacity and Lead Time (SCLT) Project.
                x_plan_info_rec.plan_start_date     := null;
                x_plan_info_rec.plan_cutoff_date    := null;
                x_plan_info_rec.sr_instance_id      := null;
                x_plan_info_rec.organization_id     := null;
                x_plan_info_rec.curr_cutoff_date    := null;
                x_plan_info_rec.optimized_plan      := 2; -- 2859130
                -- ATP4drp plan_type is meaningless when plan_id is NULL
                x_plan_info_rec.plan_type           := NULL;
        END;
    END IF;

    -- Assign global and local variables
    l_summary_flag := x_plan_info_rec.summary_flag;
    MSC_ATP_PVT.G_PLAN_SUBST_FLAG := x_plan_info_rec.subst_flag;

    if PG_DEBUG in ('Y','C') then
        msc_sch_wb.atp_debug ('Plan_ID after processing switches is : ' || x_plan_info_rec.plan_id);
    end if;

    -- ATP4drp
    IF NVL(x_plan_info_rec.plan_type, 1) = 5 THEN -- DRP plan then re-set variables
        MSC_ATP_PVT.G_ALLOCATED_ATP := 'N';
        l_time_phased_atp := 'N';
        IF PG_DEBUG in ('Y','C') then
            msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
            msc_sch_wb.atp_debug('DRP Plan, re-setting variables');
        END IF;
    ELSE
        MSC_ATP_PVT.G_ALLOCATED_ATP := MSC_ATP_PVT.G_ORIG_ALLOC_ATP;
        l_time_phased_atp := p_time_phased_atp;
    END IF;
    IF PG_DEBUG in ('Y','C') then
        msc_sch_wb.atp_debug('Value of MSC_ATP_PVT.G_ALLOCATED_ATP :' || MSC_ATP_PVT.G_ALLOCATED_ATP);
        msc_sch_wb.atp_debug('Value of l_time_phased_atp :' || l_time_phased_atp);
        msc_sch_wb.atp_debug('Value of p_time_phased_atp :' || p_time_phased_atp);
    END IF;
    -- End ATP4drp
    IF x_plan_info_rec.plan_id > 0  THEN

        IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
            (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
            (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
            (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

            IF l_summary_flag = MSC_POST_PRO.G_SF_SUMMARY_NOT_RUN THEN       -- Summary / pre-allocation was never run.
                x_plan_info_rec.plan_id := -200;
                if PG_DEBUG in ('Y','C') then
                    msc_sch_wb.atp_debug('Pre-allocation process needs to be run');
                end if;
            ELSIF l_summary_flag = MSC_POST_PRO.G_SF_PREALLOC_RUNNING THEN   -- Pre-allocation is running.
                x_plan_info_rec.plan_id := -100;
                if PG_DEBUG in ('Y','C') then
                    msc_sch_wb.atp_debug('Pre-allocation and/or PF bucketting process is running');
                end if;
            END IF;
        -- Summary enhancement: Do not reset summary flag so that copy SOs can be created
        -- this check will be made again just before building period data to decide whether summary should be used
        /*
        ELSIF NVL(MSC_ATP_PVT.G_SUMMARY_FLAG, 'N') = 'Y' THEN
            IF l_summary_flag = 1 THEN
                -- set the summary flag
                MSC_ATP_PVT.G_SUMMARY_FLAG := 'N';
                if PG_DEBUG in ('Y','C') then
                msc_sch_wb.atp_debug('Switch from summary to details tables');
                end if;
            ELSIF l_summary_flag = 2 THEN*/
        ELSIF l_summary_flag IN (MSC_POST_PRO.G_SF_SUMMARY_NOT_RUN, MSC_POST_PRO.G_SF_PREALLOC_RUNNING) THEN
            -- This means that PF bucketting has not started or is still in progress
            IF nvl(l_time_phased_atp,'N') = 'Y' THEN -- ATP4drp Use local variable instead of parameter
                x_plan_info_rec.plan_id := -100;  --changed for 2392456
                if PG_DEBUG in ('Y','C') then
                    msc_sch_wb.atp_debug('PF bucketting process is running or was never run');
                end if;
            END IF;
        END IF;


        -- 24x7 Specific Checks

        if (l_using_new_plan = 0) and (l_plan_info_rec.plan_id is not NULL)
                                   and (l_plan_info_rec.plan_id > 0) then
            -- checks against new plan when apt against old
            if l_plan_info_rec.summary_flag = MSC_ATP_24x7.G_SF_SYNC_DOWNTIME then
                -- downtime during ATP sync process
                x_plan_info_rec.plan_id := -300;
                if PG_DEBUG in ('Y','C') then
                    msc_sch_wb.atp_debug ('ATP Downtime based on new plan');
                end if;
            end if;
        end if;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Plan_Info : ' || 'x_plan_info_rec.plan_id - ' || x_plan_info_rec.plan_id);
        msc_sch_wb.atp_debug('**************** Get_Plan_Info End ***************');
    END IF;

END Get_Plan_Info;

PROCEDURE Atp_Backward_Consume(
        p_atp_qty         IN OUT  NoCopy MRP_ATP_PUB.number_arr
)
IS
i NUMBER;
j NUMBER;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('*******Begin Atp_Backward_Consume Procedure******');
    END IF;

    -- this for loop will do backward consumption
    FOR i in 2..p_atp_qty.COUNT LOOP

        -- backward consumption when neg atp quantity occurs
        IF (p_atp_qty(i) < 0 ) THEN
            j := i - 1;
            WHILE ((j>0) and (p_atp_qty(j)>=0))  LOOP
                IF (p_atp_qty(j) = 0) THEN
                    --  backward one more period
                    j := j-1 ;
                ELSE
                    IF (p_atp_qty(j) + p_atp_qty(i) < 0) THEN
                        -- not enough to cover the shortage
                        p_atp_qty(i) := p_atp_qty(i) + p_atp_qty(j);
                        p_atp_qty(j) := 0;
                        j := j-1;
                    ELSE
                        -- enough to cover the shortage
                        p_atp_qty(j) := p_atp_qty(j) + p_atp_qty(i);
                        p_atp_qty(i) := 0;
                        j := -1;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('*******End Atp_Backward_Consume Procedure******');
    END IF;

END Atp_Backward_Consume;


PROCEDURE Atp_Accumulate(
        p_atp_qty         IN OUT  NoCopy MRP_ATP_PUB.number_arr
)
IS
i NUMBER;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('*******Begin Atp_Accumulate Procedure***********');
    END IF;
    -- this for loop will do the acculumation
    FOR i in 2..p_atp_qty.COUNT LOOP
        -- accumulation (only the surplus)

        -- 1956037: do accumulation for neg quantity as well
        -- IF (p_atp_qty(i-1) > 0) THEN
          p_atp_qty(i) := p_atp_qty(i) + p_atp_qty(i-1);
        -- END IF;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********End Atp_Accumulate Procedure***********');
    END IF;
END Atp_Accumulate;

PROCEDURE Add_Coproducts(
    p_plan_id           IN NUMBER,
    p_instance_id       IN NUMBER,
    p_org_id            IN NUMBER,
    p_inv_item_id       IN NUMBER,
    p_request_date      IN DATE,
    p_demand_class      IN VARCHAR2,
    p_assembly_qty      IN NUMBER,
    p_parent_pegging_id IN NUMBER,
    -- 2869830
    p_rounding_flag     IN NUMBER,
    p_refresh_number    IN NUMBER,  -- For summary enhancement
    p_disposition_id    IN NUMBER -- bug 3766179
)
IS

TYPE ITEM_COPRODUCTS is RECORD (
               Inventory_item_id MRP_ATP_PUB.number_Arr,
               Quantity     MRP_ATP_PUB.number_arr);
l_coproducts_rec  ITEM_COPRODUCTS;
--l_supply_usage  number;
--l_coproducts_flag varchar(4);
l_transaction_id NUMBER;
l_return_status VARCHAR2(10);
l_pegging_id number;
l_process_seq_id NUMBER; -- rajjain 02/19/2003 Bug 2788302

-- 2869830
l_coprod_qty    number;

--3766179
l_supply_rec_type   MSC_ATP_DB_UTILS.Supply_Rec_typ;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Coproducts: ' || '******* Start ADD_COPRODUCT ********');
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_plan_id := ' || p_plan_id);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_instance_id := ' || p_instance_id);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_org_id := ' || p_org_id);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_inv_item_id := ' || p_inv_item_id);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_request_date := ' || p_request_date);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_demand_class := ' || p_demand_class);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_assembly_qty := ' || p_assembly_qty);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_parent_pegging_id := ' || p_parent_pegging_id);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_rounding_flag := ' || p_rounding_flag);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_refresh_number := ' || p_refresh_number);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || ' p_disposition_id := ' || p_disposition_id);
           msc_sch_wb.atp_debug('Add_Coproducts: ' || 'p_parent_pegging_id := ' || p_parent_pegging_id);
        END IF;
	------ determine the coproducts and their quantities
        -- Tuned the query for performance bug 2484964
	SELECT inventory_item_id,quantity
	BULK COLLECT INTO l_coproducts_rec.inventory_item_id,
							l_coproducts_rec.quantity
	FROM (SELECT MBC.inventory_item_id,
	            ABS(NVL(MBC.usage_quantity,1) * p_assembly_qty/
                NVL(MB.assembly_quantity,1)) quantity
  			FROM  MSC_SYSTEM_ITEMS I,
           		MSC_BOMS MB,
              	MSC_BOM_COMPONENTS MBC,
              	MSC_CALENDAR_DATES C,
              	MSC_TRADING_PARTNERS TP
        	WHERE I.plan_id = p_plan_id and
               I.sr_instance_id =  p_instance_id and
               I.organization_id = p_org_id and
               I.sr_inventory_item_id = p_inv_item_id and
               --MB.plan_id = p_plan_id and
               MB.plan_id = I.plan_id and
               --MB.assembly_item_id = I.inventory_item_id and
               MB.assembly_item_id = I.inventory_item_id and
               --MB.organization_id  = p_org_id and
               MB.organization_id  = I.organization_id and
               --MB.sr_instance_id =  p_instance_id and
               MB.sr_instance_id =  I.sr_instance_id and
               MB.bill_sequence_id = MBC.bill_sequence_id and
               MBC.plan_id = MB.plan_id and
               --MBC.organization_id  = p_org_id and
               --MBC.sr_instance_id =  p_instance_id and
               MBC.organization_id  = MB.organization_id and
               MBC.sr_instance_id =  MB.sr_instance_id and
               MBC.usage_quantity < 0 and
               TRUNC(NVL(MBC.disable_date , C.calendar_date + 1)) >
               	TRUNC(C.Calendar_date) and
               TRUNC(MBC.effectivity_date)<=
                 	TRUNC(GREATEST(sysdate, C.calendar_date)) and
               C.calendar_date = trunc(p_request_date) and
               --C.sr_instance_id = p_instance_id and
               C.sr_instance_id = MBC.sr_instance_id and
               C.calendar_code = TP.calendar_code and
               C.exception_set_id = TP.calendar_exception_set_id and
               --TP.sr_instance_id = p_instance_id and
               --TP.sr_tp_id =  p_org_id and
               TP.sr_instance_id = MBC.sr_instance_id and
               TP.sr_tp_id =  MBC.organization_id and
               TP.partner_type = 3 );
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Add_Coproducts: ' || 'No of Coproducts = ' || l_coproducts_rec.inventory_item_id.count);
    END IF;
	FOR rec_count in 1..l_coproducts_rec.inventory_item_id.count LOOP
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Add_Coproducts: ' || 'coproduct id = ' ||l_coproducts_rec.inventory_item_id(rec_count));
               msc_sch_wb.atp_debug('Add_Coproducts: ' || 'Coproduct quantity ='||  l_coproducts_rec.quantity(rec_count));
               msc_sch_wb.atp_debug('Add_Coproducts: ' || 'coproduct date = ' || p_request_date);
            END IF;
            /* rajjain 02/19/2003 Bug 2788302 Begin
             * get Process Sequence ID */
            l_process_seq_id := MSC_ATP_FUNC.get_process_seq_id(
                                  p_plan_id,
                                  l_coproducts_rec.inventory_item_id(rec_count),
                                  p_org_id,
                                  p_instance_id,
                                  p_request_date
                                  );
            -- rajjain 02/19/2003 Bug 2788302 End

            IF nvl(p_rounding_flag, 2) = 1 THEN
               l_coprod_qty := FLOOR(l_coproducts_rec.quantity(rec_count));
            ELSE
               l_coprod_qty := l_coproducts_rec.quantity(rec_count);
            END IF;

            --bug 3766179: call new procedure add_supplies instead
            /*
   	    MSC_ATP_DB_UTILS.Add_Planned_Order(
                                p_instance_id,
                                p_plan_id,
                                l_coproducts_rec.inventory_item_id(rec_count),
                                p_org_id,
                                p_request_date,
                                l_coprod_qty, -- 2869830
                                --l_coproducts_rec.quantity(rec_count),
                                null,
                                null,
                                p_demand_class,
                                -- rajjain 02/19/2003 Bug 2788302 Begin
                                p_org_id,
                                p_instance_id,
                                l_process_seq_id,
                                -- rajjain 02/19/2003 Bug 2788302 End
                                p_refresh_number,   -- For summary enhancement
                                -- ship_rec_cal changes begin
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,       -- Bug 3241766
                                null,       -- Bug 3241766
                                null,
                                -- ship_rec_cal changes end
                                l_transaction_id,
                                l_return_status
                             	);

            */

            l_supply_rec_type.instance_id := p_instance_id;
            l_supply_rec_type.plan_id := p_plan_id;
            l_supply_rec_type.inventory_item_id := l_coproducts_rec.inventory_item_id(rec_count);
            l_supply_rec_type.organization_id := p_org_id;
            l_supply_rec_type.schedule_date :=p_request_date;
            l_supply_rec_type.order_quantity := l_coprod_qty;
            l_supply_rec_type.supplier_id  := null;
            l_supply_rec_type.supplier_site_id := null;
            l_supply_rec_type.demand_class := p_demand_class;
            l_supply_rec_type.source_organization_id := p_org_id;
            l_supply_rec_type.source_sr_instance_id := p_instance_id;
            l_supply_rec_type.process_seq_id :=  l_process_seq_id;
            l_supply_rec_type.refresh_number := p_refresh_number;
            l_supply_rec_type.shipping_cal_code := null;
            l_supply_rec_type.receiving_cal_code := null;
            l_supply_rec_type.intransit_cal_code:= null;
            l_supply_rec_type.new_ship_date := null;
            l_supply_rec_type.new_dock_date := null;
            l_supply_rec_type.start_date := null;
            l_supply_rec_type.order_date := null;
            l_supply_rec_type.ship_method := null;
            l_supply_rec_type.request_item_id  := null;
            l_supply_rec_type.atf_date := null;

            l_supply_rec_type.firm_planned_type := 2;
            l_supply_rec_type.disposition_status_type := 1;
            l_supply_rec_type.record_source := 2;
            l_supply_rec_type.supply_type := 17; --planned order coproduct
            l_supply_rec_type.disposition_id := p_disposition_id;

            MSC_ATP_DB_UTILS.ADD_SUPPLIES(l_supply_rec_type);

            l_transaction_id := l_supply_rec_type.transaction_id;
            l_return_status :=  l_supply_rec_type.return_status;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Add_Coproducts: ' || 'l_transaction_id := ' || l_transaction_id);
               msc_Sch_wb.atp_debug('Add_Coproducts: ' || 'Add pegging for coproducts where pegging id = 4');
            END IF;

            INSERT into mrp_atp_details_temp
                 (session_id,
                  order_line_id,
	          pegging_id,
                  parent_pegging_id,
                  atp_level,
                  record_type,
                  organization_id,
                  organization_code,
                  identifier1,
                  identifier2,
                  identifier3,
		  inventory_item_id,
                  inventory_item_name,
                  resource_id,
                  resource_code,
                  department_id,
                  department_code,
                  supplier_id,
                  supplier_name,
 		  supplier_site_id,
                  supplier_site_name,
	          scenario_id,
		  source_type,
		  supply_demand_source_type,
                  supply_demand_quantity,
		  supply_demand_type,
		  supply_demand_date,
                  end_pegging_id,
                  constraint_flag,
                  allocated_quantity, -- 1527660
                  number1,
                  char1,
		  component_identifier,
                  -- resource batching
                  batchable_flag,
                  summary_flag
                -- dsting 2535568 purge temp table fix
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , last_update_login
		)
	    VALUES
                 (MSC_ATP_PVT.G_SESSION_ID,
                  MSC_ATP_PVT.G_ORDER_LINE_ID,
                  msc_full_pegging_s.nextval,
                  p_parent_pegging_id,
                  1,
                  4,
                  p_org_id,
                  null,
                  p_instance_id,
                  p_plan_id,
                  l_transaction_id,
                  l_coproducts_rec.inventory_item_id(rec_count),
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  null,
                  1,
		  2,
                  2,
                  l_coproducts_rec.quantity(rec_count),
                  2,
                  p_request_date,
                  NVL(MSC_ATP_PVT.G_DEMAND_PEGGING_ID, msc_full_pegging_s.currval),
                  null,
                  null, -- 1527660
                  null,
                  null,
		  null,
                  null,
                  MSC_ATP_PVT.G_SUMMARY_FLAG
		  -- dsting  2535568 purge temp table fix
		  , sysdate 		-- creation_date
		  , FND_GLOBAL.USER_ID  -- created_by
		  , sysdate 		-- last_update_date
		  , FND_GLOBAL.USER_ID  -- update_by
		  , FND_GLOBAL.USER_ID	-- login_by
		)
              RETURNING pegging_id INTO l_pegging_id;
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Add_Coproducts: ' || ' rec_count : = ' || rec_count);
                 msc_sch_wb.atp_debug('Add_Coproducts: ' || ' l_pegging_id : = ' || l_pegging_id);
              END IF;
	END LOOP;
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('**********End ADD_Coproducts Procedure***********');
	END IF;

END ADD_COPRODUCTS;


-- ========================================================================
-- This procedure inserts information source org information for the request
-- items  into mrp_atp_schedule_temp for Supply Chain ATP.
-- ========================================================================

PROCEDURE get_Supply_Sources(
			     x_session_id         IN      NUMBER,
			     x_sr_instance_id     IN      NUMBER,
			     x_assignment_set_id  IN      NUMBER,
			     x_plan_id            IN      NUMBER,
			     x_calling_inst       IN      VARCHAR2,
			     x_ret_status         OUT     NoCopy VARCHAR2,
			     x_error_mesg         OUT     NoCopy VARCHAR2,
                             p_node_id            IN    NUMBER DEFAULT null, --bug3610706
                             p_requested_date     IN    DATE DEFAULT null --8524794
			     )
  IS
     l_return_status       VARCHAR2(100);
     l_request_item_id     NUMBER := NULL;
     l_sources             mrp_atp_pvt.atp_source_typ;
     l_item_arr            mrp_atp_pub.number_arr := mrp_atp_pub.number_arr(1);
     l_item_sourcing_rec   MSC_ATP_CTO.Item_Sourcing_Info_Rec;
     l_other_cols          order_sch_wb.other_cols_typ;
     l_item_id             NUMBER;
     l_sr_instance_id      NUMBER;
     l_organization_id     NUMBER;
     l_customer_id         NUMBER;
     l_customer_site_id    NUMBER;
     l_dblink              VARCHAR2(128);   -- m2a link
     l_dynstring           VARCHAR2(129) := NULL;
     l_intransit_time	   NUMBER;
     l_ship_method	   VARCHAR2(30);
     l_ship_method_text	   VARCHAR2(80);
     sql_stmt              VARCHAR2(32000);
     j                     NUMBER;
     l_to_location_id      NUMBER;
     l_default_flag        NUMBER;
     l_cursor              integer;
     rows_processed  NUMBER;
     l_from_location_id    NUMBER;
     l_region_level          NUMBER;
     l_region_id             NUMBER;
     l_om_source_org         NUMBER;

CURSOR  SH_METHODS(p_from_location_id NUMBER,
                          p_source_instance_id NUMBER,
                          p_to_location_id NUMBER,
                          p_instance_id NUMBER) IS
      SELECT msim.intransit_time,
             msim.ship_method,
             msim.default_flag
      FROM  msc_interorg_ship_methods  msim
      WHERE  msim.plan_id = -1
      AND msim.from_location_id = p_from_location_id
      AND msim.sr_instance_id = p_source_instance_id
      AND msim.to_location_id = p_to_location_id
      AND msim.sr_instance_id2 = p_instance_id
      AND msim.to_region_id is null;

-- cnazarma  c_region_level cursor is needed to get
-- the most  specific region_level

CURSOR  c_region_level (p_from_location_id NUMBER,
                     p_from_instance_id NUMBER,
                     p_to_instance_id NUMBER,
                     p_session_id NUMBER,
                     p_partner_site_id NUMBER)   IS
SELECT  ( (10 * (10 - mrt.region_type)) +
         DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level, mrt.region_id
FROM    msc_interorg_ship_methods mism,
        msc_regions_temp mrt
WHERE   mism.plan_id = -1
AND     mism.from_location_id = p_from_location_id
AND     mism.sr_instance_id = p_from_instance_id
AND     mism.sr_instance_id2 = p_to_instance_id
AND     mism.to_region_id = mrt.region_id
AND     mrt.session_id = p_session_id
AND     mrt.partner_site_id = p_partner_site_id
ORDER BY 1;

     TYPE mastcurtyp IS REF CURSOR;
     mast_cursor mastcurtyp;
BEGIN

/*IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('get_Supply_Sources: ' || 'Inside of atp_proc ');
   msc_sch_wb.atp_debug('get_Supply_Sources: ' || 'p_node_id ' || p_node_id);
END IF;  */
/*----------------------------------------------------------------------------
  -- This procedure will be on the ATP server and will be called thru
   -- the atp link from the client.
----------------------------------------------------------------------------*/
msc_sch_wb.set_session_id(x_session_id); -- Set session ID for debug file.
  --bug3610706 start
    IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('get_Supply_Sources: ' || 'p_node_id ' || p_node_id || ':' || x_session_id);
     msc_sch_wb.atp_debug('get_Supply_Sources: ' || 'x_sr_instance_id ' || x_sr_instance_id);
    END IF;
    l_dblink := null;
    IF p_node_id is not null THEN
       BEGIN
       --Bug3765793 adding trim functions to remove spaces from db_link
         SELECT ltrim(rtrim(M2A_DBLINK))
         INTO   l_dblink
         FROM   msc_apps_instance_nodes
         WHERE  instance_id = x_sr_instance_id and
                node_id     = p_node_id;
         IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('RAC instance');
         END IF;
       EXCEPTION
        WHEN OTHERS THEN
            l_dblink := null;
            IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Did not get records in rac case');
            END IF;
       END;
    END IF;
  /* Bug 2085071 Fix */
    IF l_dblink is null THEN
     BEGIN
     --Bug3765793 adding trim functions to remove spaces from db_link
      SELECT  ltrim(rtrim(M2A_DBLINK))
	INTO   l_dblink
	FROM   msc_apps_instances
	WHERE  instance_id = x_sr_instance_id;
     EXCEPTION
      WHEN no_data_found THEN
	 NULL;
     END;
    END IF;
  --bug3610706 end
   IF l_dblink IS NOT NULL AND x_calling_inst = 'APPS' THEN
      l_dynstring := '@'||l_dblink;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_Supply_Sources: ' || ' l_dblink '||l_dblink);
   END IF;

/*--------------------------------------------------
selecting ship method and delivery lead time passed
by OM in addition to instance_id
org_id ,cust_id and cust_site_id

Pachset J changes:
Removed DISTINCT from select and added
order_line_id = nvl(ato_model_line_id, order_line_id)
and rownum = 1

In case of Ship set :
we should be selecting only first line

In case of Model/PTO only parent line will
have ship method, intransit time info
----------------------------------------------*/
     sql_stmt :=
            ' SELECT '||
            ' mast.sr_instance_id,mast.source_organization_id, '||
            ' mast.organization_id, '||
            ' mast.customer_id,mast.customer_site_id, '||
            ' mast.ship_method,mast.delivery_lead_time,mast.ship_method_text '||
            ' FROM mrp_atp_schedule_temp'||l_dynstring||' mast '||
            ' WHERE mast.session_id = :x_session_id '||
            ' AND status_flag = 4 and '||
            ' order_line_id = nvl(ato_model_line_id, order_line_id)'||
            ' AND  rownum = 1';

IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('get_Supply_Sources: ' || 'sql_stmt : ' || sql_stmt);
END IF;

   EXECUTE IMMEDIATE sql_stmt INTO l_sr_instance_id,l_om_source_org,
                l_organization_id,
		l_customer_id,l_customer_site_id,
		g_ship_method_rec.ship_method,g_ship_method_rec.intransit_time,
		g_ship_method_rec.ship_method_text
		using x_session_id;
IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('l_organization_id (destin org ) ' || l_organization_id);
      msc_sch_wb.atp_debug('l_om_source_org is ' ||l_om_source_org);
      msc_sch_wb.atp_debug('g_ship_method_rec.ship_method is ' ||
                            g_ship_method_rec.ship_method);
      msc_sch_wb.atp_debug('g_ship_method_rec.intransit_time is ' ||
                            g_ship_method_rec.intransit_time);
      msc_sch_wb.atp_debug('l_customer_id is ' || l_customer_id);
      msc_sch_wb.atp_debug('l_customer_site_id is ' || l_customer_site_id);
END IF;

   sql_stmt :=
     '    SELECT inventory_item_id ,order_line_id, ato_model_line_id,'||
     '           match_item_id' ||
     '    FROM mrp_atp_schedule_temp'||l_dynstring||
     '    WHERE session_id = :x_session_id '||
     '    AND status_flag = 4';

   OPEN mast_cursor FOR sql_stmt using x_session_id;

   j := 1;
   item_sources_extend(l_item_sourcing_rec);

   LOOP
      FETCH mast_cursor INTO l_item_sourcing_rec.sr_inventory_item_id(j),
                             l_item_sourcing_rec.line_id(j),
                             l_item_sourcing_rec.ato_line_id(j),
                             l_item_sourcing_rec.match_item_id(j);
      EXIT WHEN mast_cursor%notfound;
      j := j + 1;
      item_sources_extend(l_item_sourcing_rec);
   END LOOP;
      l_item_sourcing_rec.sr_inventory_item_id.trim(1);
      l_item_sourcing_rec.line_id.trim(1);
      l_item_sourcing_rec.ato_line_id.trim(1);
      l_item_sourcing_rec.match_item_id.trim(1);


IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug(' count is ' ||
                         l_item_sourcing_rec.sr_inventory_item_id. count);
     msc_sch_wb.atp_debug('get_Supply_Sources: ' || ' Plan_id : '||
                         x_plan_id||' assgn_id : '||x_assignment_set_id||
                         ' inst_id : '||l_sr_instance_id);
END IF;

    --bug3610706 Insert into destination regions table from Source
    --bug 4507141: l_dynstring indicates whether we are truely in distributed mode or not
    --IF l_dblink is not null THEN
    IF l_dynstring is not null THEN
             sql_stmt :=
               'INSERT INTO MSC_REGIONS_TEMP(
                session_id,
                partner_site_id,
                region_id,
                region_type,
                zone_flag,
                partner_type
                )
                (SELECT
                 session_id,
                 partner_site_id,
                 region_id,
                 region_type,
                 zone_flag,
                 partner_type
                 FROM msc_regions_temp' || l_dynstring || '
                 WHERE session_id = :x_session_id)';
              EXECUTE IMMEDIATE sql_stmt USING x_session_id;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Rows inserted in msc_regions_temp:'|| sql%rowcount);
      END IF;
    END IF;
    --bug3610706 End Changes

    IF l_item_sourcing_rec.sr_inventory_item_id.COUNT > 0 THEN

      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                              'l_item_sourcing_rec.sr_inventory_item_id(1) : '
                               || l_item_sourcing_rec.sr_inventory_item_id(1));
          msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                                'l_item_sourcing_rec.line_id(1) : '
                               || l_item_sourcing_rec.line_id(1));
          msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                                'l_item_sourcing_rec.ato_line_id(1) : '
                               || l_item_sourcing_rec.ato_line_id(1));
          msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                                'l_item_sourcing_rec.match_item_id(1) : '
                               || l_item_sourcing_rec.match_item_id(1));
      END IF;

	 MSC_ATP_PROC.Atp_Sources(l_sr_instance_id,
				  x_plan_id,
				  NULL,
				  l_Organization_Id,
				  l_Customer_Id,
				  l_Customer_Site_Id,
				  x_assignment_set_id,
				  l_item_sourcing_rec,
                                  x_session_id,
				  l_sources,
				  l_return_status);

     IF l_return_status <> 'S' THEN
	x_error_mesg := l_return_status;
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                                ' Error in call to msc_atp_pvt.atp_sources ');
	END IF;
	RETURN ;
     ELSE
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                                ' Success in call to atp_sources : ' ||
                                  l_sources.organization_id.COUNT);
	END IF;
     END IF;

     IF l_sources.organization_id.COUNT > 0 THEN
        MSC_SCH_WB.extend_other_cols(l_other_cols,
                                     l_sources.organization_id.COUNT);

	FOR j IN 1..l_sources.organization_id.COUNT LOOP
	    -- cchen's api returns these values.
	    IF l_sources.ship_method(j) = '@@@' THEN
	       l_sources.ship_method(j) := NULL;
	    END IF;
	    IF l_sources.lead_time(j) = '-1' THEN
	       l_sources.lead_time(j) := NULL;
	    END IF;

	    IF l_sources.organization_id(j) <> -1 THEN
	        BEGIN
		   SELECT organization_code
		     INTO l_other_cols.org_code(j)
		     FROM msc_trading_partners
		     WHERE sr_tp_id = l_sources.organization_id(j)
		     AND sr_instance_id = l_sources.instance_id(j)
		     AND partner_type = 3;
		EXCEPTION
		   WHEN no_data_found THEN
IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                               ' Org Code Not found for : ' ||
                                l_sources.organization_id(j));
END IF;
     x_error_mesg := 'Org Code Not found for : ' ||
                       l_sources.organization_id(j);
      RETURN;
      END;
	    ELSE
 	          BEGIN
		      SELECT mtil.sr_tp_id, mtp.partner_name
			INTO l_other_cols.sr_supplier_id(j),
			l_other_cols.vendor_name(j)
			FROM msc_tp_id_lid mtil,
			msc_trading_partners mtp
			WHERE mtil.tp_id = mtp.partner_id
			AND mtil.sr_instance_id = l_sources.instance_id(j)
			AND mtil.partner_type = 1
			AND mtp.partner_id = l_sources.supplier_id(j);

		      SELECT mtsil.sr_tp_site_id, mtps.tp_site_code
			INTO l_other_cols.sr_supplier_site_id(j),
			l_other_cols.vendor_site_name(j)
			FROM msc_tp_site_id_lid mtsil,
			msc_trading_partner_sites mtps
			WHERE mtsil.tp_site_id = mtps.partner_site_id
			AND mtsil.sr_instance_id = l_sources.instance_id(j)
			AND mtsil.partner_type = 1
			AND mtps.partner_site_id =
			l_sources.supplier_site_id(j);

        	  EXCEPTION
		     WHEN no_data_found THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                                       'Vendor name or site name Not found for '
				        ||l_sources.organization_id(j));
			END IF;
			x_error_mesg :='Vendor name or site name Not found for'
			                ||l_sources.organization_id(j);
			RETURN;
		  END;
	      END IF; -- IF l_sources.organization_id(j) <> -1
	   END LOOP;
/*------------------------------------------------------------------------------
 Due to bug # 2428750 changing region level sourcing logic
The new way to get shipping methods is the following:
1)  Find specific shipping methods  from location to location.
2)    If found, no need to deal with region level  ( see below condition:
    IF l_ship_method is NULL , only then go and proceed with region level)
3) IF not found, then use cursor c_region_level to get the most
specific region for this customer's location and its region_id
4) Once we know region_id , we need to get all  defined ship methods ( default and not default ) for a user to pick.

------------------------------------------------------------------------------*/
   FOR counter IN 1..l_sources.organization_id.COUNT LOOP
      MSC_ATP_PROC.msc_calculate_source_attrib
      	                           ( l_customer_id,
                                     l_customer_site_id,
	                             l_organization_id,
                                     l_sr_instance_id,
		                     counter,
                                     l_sources,
                                     l_other_cols);

           l_to_location_id :=
              msc_atp_func.get_location_id(l_sr_instance_id,
                                           l_organization_id,
                                           l_customer_id,
                                           l_customer_site_id,
                                           l_sources.supplier_id(counter),                                                 l_sources.supplier_site_id(counter));

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('get_Supply_Sources: '
                              || ' l_to_location_id '
                              ||l_to_location_id);
      END IF;

-- cnazarma need to have l_from_location_id since org_id
--might be diff from its location_id Bug #2422940

 l_from_location_id :=
  msc_atp_func.get_location_id (p_instance_id => l_sources.instance_id(counter),
                      p_organization_id => l_sources.organization_id(counter),
                      p_customer_id => NULL,
                      p_customer_site_id => NULL,
                      p_supplier_id => NULL,
                      p_supplier_site_id => NULL);

-- here we are getting shipping methods for specific from location to location

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_Supply_Sources: '
                             || ' l_from_location_id '
                             ||l_from_location_id);
    END IF;

-- if l_to_location_id is null, that means we need to work with redions.


  IF l_to_location_id is NOT NULL THEN
       OPEN SH_METHODS( l_from_location_id,
                      l_sources.instance_id(counter),
                      l_to_location_id,
                      l_sr_instance_id);
       LOOP
       FETCH SH_METHODS INTO l_intransit_time,
                         l_ship_method,
                       --  l_ship_method_text,
                         l_default_flag;
       EXIT WHEN SH_METHODS%NOTFOUND;

              sql_stmt :=
               ' INSERT INTO '||
               ' MRP_ATP_SCHEDULE_TEMP'||l_dynstring||' '||
               ' ( SESSION_ID,'||
               ' DELIVERY_LEAD_TIME,SHIP_METHOD, '||
               ' STATUS_FLAG, '||
               ' ship_method_text, '||
               ' inventory_item_id,scenario_id,source_organization_id' ||
		-- dsting 2535568 purge temp table fix
	       ',creation_date
	        ,created_by
	        ,last_update_date
		,last_updated_by
		,last_update_login) '||
               ' VALUES ( ' ||
               ' :x_session_id,' ||
               ' :l_instansit_time,' ||
               ' :l_ship_method,' ||
               ' -99,  '||
               ':l_ship_method_text, ' ||
               ' -1101, ' ||
               ' :l_default_flag,' ||
               ' :l_source_org_id'	||

		-- dsting 2535568 purge temp table fix
	       ',sysdate'         ||
	       ',:created_by'     ||
	       ',sysdate'         ||
	       ',:last_update_by' ||
	       ',:last_update_login )';

         BEGIN
                EXECUTE immediate sql_stmt
		using x_session_id,
                l_intransit_time,
                l_ship_method,
                l_ship_method_text,
                nvl(l_default_flag,1),
                l_sources.organization_id(counter),
                FND_GLOBAL.USER_ID,	-- dsting 2535568 purge temp table fix
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.USER_ID;

       IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('get_Supply_Sources: '
                                 || ' after exec of above sql ');
       END IF;

      END;

  END LOOP;  -- finish looping through all available shipping methods
  CLOSE SH_METHODS;

  IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('get_Supply_Sources: '
                          || 'l_ship_method AFTER FIRST SQL '
                          || l_ship_method);
  END IF;

/*-----------------------------------------------------------------------------
In case if there are no specific shipping methods found (l_ship_method is NULL ) THEN get the most specific region level and its region_id
-----------------------------------------------------------------------------*/
  ELSE
        OPEN c_region_level (l_from_location_id,
                             l_sources.instance_id(counter),
                             l_sources.instance_id(counter),
                             x_session_id,
                             l_customer_site_id);
        FETCH c_region_level INTO l_region_level, l_region_id;
        CLOSE c_region_level;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('get_Supply_Sources: '
                                  || 'region level is '
                                  || l_region_level || ' and region_id '
                                  || l_region_id);
        END IF;

    sql_stmt :=
               ' INSERT INTO '||
               ' MRP_ATP_SCHEDULE_TEMP'||l_dynstring||' '||
               ' ( SESSION_ID,'||
               ' DELIVERY_LEAD_TIME,SHIP_METHOD, '||
               ' STATUS_FLAG, '||
               ' SHIP_METHOD_TEXT, '||
               ' inventory_item_id,scenario_id,source_organization_id' ||
	       -- dsting 2535568 purge temp table fix
	       ' , creation_date
		 , created_by
		 , last_update_date
		 , last_updated_by
		 , last_update_login) '||
           ' SELECT distinct'||
               ' mrt.session_id , '||
               ' msim.intransit_time,  '||
               ' msim.ship_method,  '||
               ' -99,  '||
               ' msim.ship_method_text, ' ||
               ' -1101,msim.default_flag,:source_org_id'||

		-- dsting 2535568 purge temp table fix
	       ',sysdate'             ||
	       ',:created_by'         ||
	       ',sysdate'             ||
	       ',:last_update_by'     ||
	       ',:last_update_login ' ||
               ' FROM msc_interorg_ship_methods  msim '||
               ' , msc_regions_temp mrt '||
--               ' , fnd_common_lookups fnd '||
               ' WHERE mrt.session_id = :x_session_id '||
               ' AND msim.plan_id = -1 '||
               ' AND msim.from_location_id = :l_from_location_id '||
               ' AND msim.sr_instance_id = :source_instance_id '||
               ' AND msim.to_region_id = mrt.region_id '||
               ' AND mrt.partner_site_id = :customer_site_id '||
               ' AND msim.sr_instance_id2 = :instance_id '||
               ' AND mrt.region_id = :l_region_id ';
--               ' AND FND.LOOKUP_TYPE = ''SHIP_METHOD'''||
--               ' AND FND.APPLICATION_ID = 401 '||
--               ' AND FND.LOOKUP_CODE = msim.ship_method';

                execute immediate sql_stmt
                using l_sources.organization_id(counter),
		FND_GLOBAL.USER_ID,	-- dsting 2535568 purge temp table fix
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.USER_ID,
                x_session_id,
                l_from_location_id,
                l_sources.instance_id(counter),
                l_customer_site_id,
                l_sr_instance_id,
                l_region_id;

        END IF; -- if l_to_location_id_

          begin
          sql_stmt :=
  	   ' SELECT '||
  	   ' distinct mast.ship_method '||
  	   ' FROM mrp_atp_schedule_temp'||l_dynstring||' mast '||
  	   ' WHERE mast.session_id = :x_session_id '||
  	   ' AND status_flag = -99'||
  	   ' AND mast.source_organization_id=:source_org_id '||
  	   ' AND mast.ship_method = :ship_method ';

	   l_ship_method:=null;

  	  EXECUTE IMMEDIATE sql_stmt
          INTO l_ship_method
  	  USING x_session_id,
                l_sources.organization_id(counter),
                g_ship_method_rec.ship_method;
	  EXCEPTION
	  when no_data_found then null;
	  end;


      IF l_sources.organization_id(counter) = l_om_source_org THEN
          IF l_ship_method = g_ship_method_rec.ship_method THEN
           l_sources.ship_method(counter):=g_ship_method_rec.ship_method;
           l_sources.lead_time(counter):=g_ship_method_rec.intransit_time;

        IF g_ship_method_rec.intransit_time is NULL THEN

        BEGIN
          sql_stmt :=
             '  SELECT DISTINCT '||
             ' delivery_lead_time '||
             ' FROM mrp_atp_schedule_temp'||l_dynstring||
             ' WHERE session_id = :x_session_id '||
             ' AND status_flag = -99'||
             ' AND ship_method =:g_ship_method'||
             ' AND source_organization_id = :l_om_org';

               EXECUTE IMMEDIATE sql_stmt
               INTO l_sources.lead_time(counter)
               USING  x_session_id,
                      g_ship_method_rec.ship_method,
                      l_om_source_org ;

                 EXCEPTION
                 when no_data_found THEN
                 NULL;
                 END;
         END IF;
        END IF;

   	   IF l_sources.SHIP_METHOD(counter) IS NOT null THEN
            BEGIN
  	     select fnd.meaning
	     into  l_other_cols.ship_method_text(counter)
	     FROM FND_common_lookups fnd
	     where    FND.LOOKUP_CODE = l_sources.SHIP_METHOD(counter)
	     AND      FND.LOOKUP_TYPE = 'SHIP_METHOD'
	     AND      fND.APPLICATION_ID = 401;
            EXCEPTION
	     WHEN no_data_found THEN
	     l_other_cols.ship_method_text(counter)
	      := l_sources.ship_method(counter);
	     IF PG_DEBUG in ('Y', 'C') THEN
	        msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                                     'no desc for ship method ');
	     END IF;
            END;
       	   END IF;
       	   END IF;

	   END LOOP;

           -- m2a link to put back the records into the apps table.
	   MSC_ATP_PROC.insert_atp_sources(x_session_id,
                                           l_dblink,
                                           x_calling_inst,
			                   l_sources,l_other_cols);
	 ELSE
	   IF PG_DEBUG in ('Y', 'C') THEN
	      msc_sch_wb.atp_debug('get_Supply_Sources: ' ||
                                   ' There are no sources to be inserted ');
	   END IF;
	   x_ret_status := 'E';
	   x_error_mesg := 'MRP_ATP_NO_SOURCES';
	END IF; -- IF l_sources.organization_id.COUNT > 0
     END IF; -- IF l_item_arr.COUNT > 0 THEN

    -- Delete records from MSC_REGIONS_TEMP before returning back to calling
    -- application so as to clean up the table for another request within
    -- same session for Region Level Sourcing Support

    DELETE msc_regions_temp
    WHERE session_id = x_session_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_Supply_Sources: '
                            || 'Rows deleted from msc_regions_temp : '
                            ||sql%rowcount);
    END IF;
   --ubadrina bug 2265012 begin
   EXCEPTION
   when no_data_found then null;
   --ubadrina bug 2265012 end

END get_supply_sources;

PROCEDURE item_sources_extend(p_item_sourcing_rec
                          IN OUT NOCOPY MSC_ATP_CTO.Item_Sourcing_Info_Rec) IS
BEGIN
p_item_sourcing_rec.sr_inventory_item_id.extend;
p_item_sourcing_rec.line_id.extend;
p_item_sourcing_rec.ato_line_id.extend;
p_item_sourcing_rec.match_item_id.extend;
END item_sources_extend;


PROCEDURE msc_calculate_source_attrib
  ( l_customer_id                NUMBER,
    l_ship_to_site_use_id        NUMBER,
    l_dest_org_id                NUMBER,
    l_dest_instance_id           NUMBER,
    counter                      NUMBER,
    x_atp_sources                IN OUT NoCopy mrp_atp_pvt.atp_source_typ,
    x_other_cols                 IN OUT NoCopy order_sch_wb.other_cols_typ) IS

    l_from_location_id  NUMBER;
    l_to_location_id    NUMBER;
BEGIN
msc_sch_wb.atp_debug('!!!!!msc_calculate_attrib !!!!!!');
msc_sch_wb.atp_debug(' x_atp_sources.lead_time(counter) is '|| x_atp_sources.lead_time(counter));
msc_sch_wb.atp_debug('x_atp_sources.ship_method(counter) is '|| x_atp_sources.ship_method(counter));

   IF x_atp_sources.lead_time(counter) IS NULL THEN
      -- find the ship method and intransit time
      -- find the from_location_id
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('msc_calculate_source_attrib: '
                               || ' find the ship_method and intransit LT');
      END IF;

      l_from_location_id :=
	msc_atp_func.get_location_id (p_instance_id => l_dest_instance_id,
		    p_organization_id => x_atp_sources.organization_id(counter),
				     p_customer_id => NULL,
				     p_customer_site_id => NULL,
				     p_supplier_id => NULL,
				     p_supplier_site_id => NULL);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('msc_calculate_source_attrib: '
                               || ' from location_id = '||l_from_location_id);
      END IF;

      -- find the to_location_id
      l_to_location_id :=
	msc_atp_func.get_location_id(p_instance_id => l_dest_instance_id,
				    p_organization_id => l_dest_org_id,
				    p_customer_id => l_customer_id,
				    p_customer_site_id => l_ship_to_site_use_id,
				    p_supplier_id => NULL,
				    p_supplier_site_id => NULL);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('msc_calculate_source_attrib: '
                                    || ' from to_loc_id = '||l_to_location_id);
      END IF;

      -- find the ship method and intransit time first by
      -- from_location_id , to_location_id and default_flag
      x_atp_sources.ship_method(counter) :=
	NVL(MSC_SCATP_PUB.get_default_ship_method(l_from_location_id,
					  x_atp_sources.instance_id(counter),
					  l_to_location_id,
					  l_dest_instance_id,
					  order_sch_wb.debug_session_id,
					  l_ship_to_site_use_id),
	  MSC_SCATP_PUB.get_ship_method(x_atp_sources.organization_id(counter),
					  x_atp_sources.instance_id(counter),
					  l_dest_org_id,
					  l_dest_instance_id,
					  NULL,
					  NULL));
      x_atp_sources.lead_time(counter) :=
	NVL(MSC_SCATP_PUB.get_default_intransit_time(
					     l_from_location_id,
					     x_atp_sources.instance_id(counter),
					     l_to_location_id,
					     l_dest_instance_id,
					     order_sch_wb.debug_session_id,
					     l_ship_to_site_use_id),
	   NVL(MSC_SCATP_PUB.get_intransit_time(
				 x_atp_sources.organization_id(counter),
				 x_atp_sources.instance_id(counter),
				 l_dest_org_id,
				 l_dest_instance_id,
				 NULL,
				 NULL), 0));
   END IF;

   BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('msc_calculate_source_attrib: ' || 'get vendor_id and vendor_site_id ');
      END IF;

      select ORG_INFORMATION3,  ORG_INFORMATION4
	into x_atp_sources.supplier_id(counter), x_atp_sources.supplier_site_id(counter)
	from hr_organization_information
	where organization_id = x_atp_sources.organization_id(counter)
	and  ORG_INFORMATION_CONTEXT = 'Customer/Supplier Association';
   exception
      when no_data_found THEN
	 IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('msc_calculate_source_attrib: ' || 'No data found in-get vendor_id and vendor_site_id');
	 END IF;

	 x_atp_sources.supplier_id(counter) := 0;
	 x_atp_sources.supplier_site_id(counter) :=0;
   END;

   IF x_atp_sources.SHIP_METHOD(counter) is not null THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('msc_calculate_source_attrib: '
                               || 'ship method is not null '
                               ||x_atp_sources.SHIP_METHOD(counter));
      END IF;
   BEGIN
           select fnd.meaning
	   into  x_other_cols.ship_method_text(counter)
	   fROM FND_common_lookups FND
	   where    FND.LOOKUP_CODE = x_atp_sources.SHIP_METHOD(counter)
	   AND      FND.LOOKUP_TYPE = 'SHIP_METHOD'
	   AND      fND.APPLICATION_ID = 401;
      EXCEPTION
	 WHEN no_data_found THEN
	    x_other_cols.ship_method_text(counter)
	      := x_atp_sources.ship_method(counter);
	    IF PG_DEBUG in ('Y', 'C') THEN
	       msc_sch_wb.atp_debug('msc_calculate_source_attrib: '
                                    || 'no desc for ship method ');
	    END IF;
      END;

   END IF;

END msc_calculate_source_attrib;


PROCEDURE insert_atp_sources(x_session_id     NUMBER,
			     x_dblink         VARCHAR2,
			     x_calling_inst   VARCHAR2,
			     x_atp_sources    mrp_atp_pvt.atp_source_typ,
			     x_other_cols     order_sch_wb.other_cols_typ)
  IS
     sql_stmt   VARCHAR2(32000);
     l_dynstring VARCHAR2(129);

BEGIN

   IF x_dblink IS NOT NULL AND x_calling_inst = 'APPS' THEN
      l_dynstring := '@'||x_dblink;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('insert_atp_sources: ' || 'inserting sources link '||l_dynstring);
      END IF;
   END IF;

   order_sch_wb.debug_session_id := x_session_id;
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('insert_atp_sources: ' || 'inserting sources count =  '||x_atp_sources.organization_id.count);
   END IF;

     sql_stmt :=
       ' INSERT INTO '||
       ' MRP_ATP_SCHEDULE_TEMP'||l_dynstring||' '||
       ' (ACTION, CALLING_MODULE, SESSION_ID, ORDER_HEADER_ID, ORDER_LINE_ID, '||
       ' INVENTORY_ITEM_ID, ORGANIZATION_ID, SR_INSTANCE_ID, ORGANIZATION_CODE, '||
       ' SOURCE_ORGANIZATION_ID, '||
       ' order_number,  '||
       ' CUSTOMER_ID, CUSTOMER_SITE_ID, DESTINATION_TIME_ZONE, '||
       ' QUANTITY_ORDERED, UOM_CODE, REQUESTED_SHIP_DATE, REQUESTED_ARRIVAL_DATE, '||
       ' LATEST_ACCEPTABLE_DATE, DELIVERY_LEAD_TIME, FREIGHT_CARRIER, SHIP_METHOD, '||
       ' DEMAND_CLASS, SHIP_SET_NAME, ARRIVAL_SET_NAME, OVERRIDE_FLAG, '||
       ' VENDOR_ID, VENDOR_SITE_ID, INSERT_FLAG, '||
       ' ERROR_CODE, ERROR_MESSAGE, SEQUENCE_NUMBER, FIRM_FLAG, INVENTORY_ITEM_NAME, '||
       ' SOURCE_ORGANIZATION_CODE, '||
       ' INSTANCE_ID1, ORDER_LINE_NUMBER, PROMISE_DATE, '||
       ' CUSTOMER_NAME, CUSTOMER_LOCATION, '||
       ' Top_Model_line_id, ' ||
       ' ATO_Model_Line_Id, '||
       ' Parent_line_id, ' ||
       ' Config_item_line_id, ' ||
       ' Validation_Org, '||
       ' Component_Sequence_ID, '||
       ' Component_Code, ' ||
       ' line_number, '||
       ' included_item_flag, '||
       ' SCENARIO_ID, VENDOR_NAME, VENDOR_SITE_NAME, '||
       ' STATUS_FLAG, MDI_ROWID, DEMAND_SOURCE_TYPE, '||
       ' DEMAND_SOURCE_DELIVERY, ATP_LEAD_TIME, OE_FLAG, ITEM_DESC,  '||
       ' ship_method_text, shipment_number, option_number, '||
       ' project_number, task_number,old_source_organization_id,old_demand_class, '||
       ' ship_set_id, arrival_set_id' ||
       -- dsting 2535568 purge temp table fix
       ' ,creation_date'    ||
       ' ,created_by'       ||
       ' ,last_update_date' ||
       ' ,last_updated_by'  ||
       ' ,last_update_login ) ' ||
       ' SELECT  '||
       ' ACTION, CALLING_MODULE, SESSION_ID, ORDER_HEADER_ID, ORDER_LINE_ID, '||
       ' INVENTORY_ITEM_ID, ORGANIZATION_ID, SR_INSTANCE_ID, ORGANIZATION_CODE, '||
       ' :source_org_id, '||
       ' order_number, '||
       ' CUSTOMER_ID, CUSTOMER_SITE_ID, DESTINATION_TIME_ZONE, '||
       ' QUANTITY_ORDERED, UOM_CODE, REQUESTED_SHIP_DATE, REQUESTED_ARRIVAL_DATE, '||
       ' LATEST_ACCEPTABLE_DATE, '||
       ' :lead_time,  '||
       ' FREIGHT_CARRIER, '||
       ' :ship_method,  '||
       ' DEMAND_CLASS, '||
       ' ship_set_name, '||
       ' ARRIVAL_SET_NAME, OVERRIDE_FLAG, '||
       ' :supplier_id,  '||
       ' :supplier_site_id,  '||
       ' INSERT_FLAG, '||
       ' ERROR_CODE, ERROR_MESSAGE, SEQUENCE_NUMBER, FIRM_FLAG, INVENTORY_ITEM_NAME, '||
       ' :org_code, '||
       ' INSTANCE_ID1, ORDER_LINE_NUMBER, PROMISE_DATE, '||
       ' CUSTOMER_NAME, CUSTOMER_LOCATION, '||
       ' Top_Model_line_id, ' ||
       ' ATO_Model_Line_Id, '||
       ' Parent_line_id, ' ||
       ' Config_item_line_id, ' ||
       ' Validation_Org, '||
       ' Component_Sequence_ID, '||
       ' Component_Code, ' ||
       ' line_number, '||
       ' included_item_flag, '||
       ' SCENARIO_ID, '||
       ' :vendor_name,  '||
       ' :vendor_site_name, '||
       ' 22,  '||
       -- 22 is used here so that it does not get selected in lines block.
       -- cannot use 2 since it would be a valid one for backlog mode lines block.
       ' MDI_ROWID, DEMAND_SOURCE_TYPE, '||
       ' DEMAND_SOURCE_DELIVERY, ATP_LEAD_TIME, OE_FLAG, ITEM_DESC, '||
       ' :ship_method_text, '||
       ' shipment_number, option_number, project_number, task_number,old_source_organization_id, '||
       ' old_demand_class, ship_set_id, arrival_set_id  '||
	  ' ,sysdate '           ||  -- dsting 2535568 purge temp table fix
	  ' ,:created_by '       ||
	  ' ,sysdate '           ||
	  ' ,:last_update_by'    ||
	  ' ,:last_update_login' ||
       ' FROM mrp_atp_schedule_temp'||l_dynstring||' '||
       ' WHERE session_id = :x_session_id '||
       ' AND status_flag = 4';
     --msc_sch_wb.atp_debug(' sql stmt '||sql_stmt);

     FOR j IN 1..x_atp_sources.organization_id.COUNT LOOP
     -- x_atp_sources.organization_id.first..x_atp_sources.organization_id.last
	execute immediate sql_stmt
	  using x_atp_sources.organization_id(j),x_atp_sources.lead_time(j),
	  x_atp_sources.ship_method(j),
	  --x_other_cols.row_index(j), -- created initially for "forall" stmt
	  x_other_cols.sr_supplier_id(j),
	  x_other_cols.sr_supplier_site_id(j),x_other_cols.org_code(j),
	  x_other_cols.vendor_name(j),x_other_cols.vendor_site_name(j),
	  x_other_cols.ship_method_text(j),
	  FND_GLOBAL.USER_ID,		-- dsting 2535568 purge temp table fix
	  FND_GLOBAL.USER_ID,
	  FND_GLOBAL.USER_ID,
	  x_session_id;
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('insert_atp_sources: ' ||  ' In atp_insert_sources   x_atp_sources.ship_method(j) is ' || x_atp_sources.ship_method(j));
	   msc_sch_wb.atp_debug('insert_atp_sources: ' || ' inserted rows '||SQL%ROWCOUNT);
	END IF;
     END LOOP;
END insert_atp_sources;

PROCEDURE SHOW_SUMMARY_QUANTITY(p_instance_id          IN NUMBER,
                                p_plan_id              IN NUMBER,
                                p_organization_id      IN NUMBER,
                                p_inventory_item_id    IN NUMBER,
                                p_sd_date              IN DATE,
                                p_resource_id          IN NUMBER,
                                p_department_id        IN NUMBER,
                                p_supplier_id          IN NUMBER,
                                p_supplier_site_id     IN NUMBER,
                                p_dc_flag              IN NUMBER,
                                p_demand_class         IN VARCHAR2,
                                p_mode                 IN NUMBER
                                )
IS
temp_sd_qty  NUMBER;
BEGIN
        /* p_mode tells from which table to select
           1- summary_so    2- Summary_sd  3- summary_res  4-Summary_sup */

        IF order_sch_wb.mr_debug = 'Y' THEN -- if debug mode is on
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('**** In SHOW_SUMMARY_QUANTITY Debug mode is on ****');
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_instance_id := ' || p_instance_id);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_plan_id     := ' || p_plan_id);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_organization_id := ' || p_organization_id);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_inventory_item_id := ' || p_inventory_item_id);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_sd_date := ' || p_sd_date);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_resource_id := ' || p_resource_id);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_department_id := ' || p_department_id);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_supplier_id := ' || p_supplier_id);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_supplier_site_id := ' || p_supplier_site_id);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_mode := ' || p_mode);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_demand_class = ' || p_demand_class);
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'p_dc_flag = ' || p_dc_flag);
           END IF;

    	   IF p_mode = 1 THEN
	      BEGIN
                    select /*+ INDEX(msc_atp_summary_so MSC_ATP_SUMMARY_SO_U1) */ sd_qty
                    into temp_sd_qty
                    from MSC_ATP_SUMMARY_SO
                    where inventory_item_id = p_inventory_item_id and
                    organization_id = p_organization_id and
                    sr_instance_id = p_instance_id and
                    sd_date = trunc(p_sd_date) and
                    demand_class = Decode(p_dc_flag, 1, NVL(p_demand_class, '@@@'),'@@@');
              EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                           temp_sd_qty := -8888;
                       WHEN OTHERS THEn
                           temp_sd_qty := -9999;
	      END;
           ELSIF p_mode = 2 THEN
              BEGIN
                    select /*+ INDEX(msc_atp_summary_sd MSC_ATP_SUMMARY_SD_U1) */ sd_qty
                    into temp_sd_qty
                    from MSC_ATP_SUMMARY_SD
                    where sr_instance_id = p_instance_id
                    and   inventory_item_id = p_inventory_item_id
                    and   organization_id = p_organization_id
                    and   sd_date = trunc(p_sd_date)
                    and   plan_id = p_plan_id;
              EXCEPTION
                       when NO_DATA_FOUND THEN
                           temp_sd_qty := -8888;
                       when others then
                           temp_sd_qty := -9999;
              END;

           ELSIF p_mode = 3 THEN
              BEGIN
                    select /*+ INDEX(msc_atp_summary_res MSC_ATP_SUMMARY_RES_U1) */ sd_qty
                    into temp_sd_qty
                    from msc_atp_summary_res
                    where plan_id = p_plan_id
                    and   sr_instance_id = p_instance_id
                    and   organization_id = p_organization_id
                    and   resource_id = p_resource_id
                    and   department_id = p_department_id
                    and   sd_date = trunc(p_sd_date);
              EXCEPTION
                       when NO_DATA_FOUND THEN
                           temp_sd_qty := -8888;
                       when others then
                           temp_sd_qty := -9999;
              END;

           ELSIF p_mode = 4 THEN
              BEGIN
                    select /*+ INDEX(msc_atp_summary_sup MSC_ATP_SUMMARY_SUP_U1) */ sd_qty
                    into temp_sd_qty
                    from msc_atp_summary_sup
                    where plan_id = p_plan_id
                    and   sr_instance_id = p_instance_id
                    and inventory_item_id = p_inventory_item_id
                    and supplier_id = p_supplier_id
                    and supplier_site_id = p_supplier_site_id
                    and sd_date = trunc(p_sd_date);
              EXCEPTION
                       when NO_DATA_FOUND THEN
                           temp_sd_qty := -8888;
                       when others then
                           temp_sd_qty := -9999;
              END;

           END IF; -- IF p_mode= 1
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('SHOW_SUMMARY_QUANTITY: ' || 'temp_sd_qty := ' || temp_sd_qty);
              msc_sch_wb.atp_debug('**** END SHOW_SUMMARY_QUANTITY  ****');
           END IF;
        END IF; -- IF order_sch_wb.mr_debug = 'Y

END SHOW_SUMMARY_QUANTITY;

PROCEDURE GET_ITEM_ATTRIBUTES (p_instance_id            IN  NUMBER,
                               p_plan_id                IN  NUMBER,
                               p_inventory_item_id      IN  NUMBER,
                               p_organization_id        IN  NUMBER,
                               p_item_attribute_rec    IN OUT NoCopy MSC_ATP_PVT.item_attribute_rec)
AS

l_atp_flag           VARCHAR2(1);
l_bom_item_type      NUMBER;
l_atp_check          NUMBER;
l_atp_comp_flag      VARCHAR2(1);
l_pick_comp_flag     VARCHAR2(1);
l_replenish_flag     VARCHAR2(1);
l_cto_bom            NUMBER := 0;
l_source_org_id      NUMBER ;


BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('inside get_item_attributes');
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'sr_inventory_item_id = '||p_inventory_item_id);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'organization_id = '||p_organization_id);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'plan_id = '||p_plan_id);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'sr_instance_id = '||p_instance_id);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'G_ORDER_LINE_ID = '||MSC_ATP_PVT.G_ORDER_LINE_ID);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'G_ASSEMBLY_LINE_ID = '||MSC_ATP_PVT.G_ASSEMBLY_LINE_ID);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'G_COMP_LINE_ID = '||MSC_ATP_PVT.G_COMP_LINE_ID);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'G_INV_CTP = '||MSC_ATP_PVT.G_INV_CTP);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'parent_repl_ord_flag := ' ||
                                                          p_item_attribute_rec.parent_repl_ord_flag);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'parent_bom_item_type := ' ||
                                                          p_item_attribute_rec.parent_bom_item_type);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'parent_comp_flag := ' ||
                                                          p_item_attribute_rec.parent_comp_flag);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'parent_atp_flag := ' ||
                                                          p_item_attribute_rec.parent_atp_flag);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'parent_pegging_id := ' ||
                                                          p_item_attribute_rec.parent_pegging_id);
   END IF;

   -- ATP Rule added to accomodate Bug 1510853
   --s_cto_rearch
   SELECT i.atp_flag, i.bom_item_type,
          i.atp_components_flag, i.bom_item_type,
          i.pick_components_flag, i.replenish_to_order_flag, -- atp_comp_flag
          NVL(i.fixed_lead_time, 0), NVL(i.variable_lead_time, 0),
          --bug3609031 adding ceil
          NVL(ceil(i.preprocessing_lead_time), 0), NVL(ceil(i.postprocessing_lead_time),0),   --lead times,
          NVL(i.substitution_window,0), NVL(i.create_supply_flag, 1), i.inventory_item_id,
          SUBSTR(i.item_name, 1,40), i.atp_rule_id, NVL(i.rounding_control_type, 2),
          --diag_atp
          i.unit_volume, i.unit_weight, i.volume_uom, i.weight_uom,
          i.uom_code, i.inventory_item_id, --rajjain AATP forward consumption
          --bug3609031 adding ceil
          NVL(ceil(i.full_lead_time),0)  -- SCLT (Supplier Capacity Lead Time)
          , i.base_item_id
          --bug5222635/5248167
          ,decode(i.atp_flag,'N',i.inventory_item_id,Decode(i.product_family_id,NULL,i.inventory_item_id,-23453,i.inventory_item_id,i.product_family_id))
          --, nvl(i.product_family_id, i.inventory_item_id) -- For time_phased_atp
          ---3917625: Store plan_id
          ,i.plan_id
          , lowest_level_src -- ATP4drp obtain flag applicable to DRP plan items.
   INTO   l_atp_flag, l_bom_item_type,
          l_atp_comp_flag, l_bom_item_type, l_pick_comp_flag, l_replenish_flag,
          p_item_attribute_rec.fixed_lt, p_item_attribute_rec.variable_lt,
          p_item_attribute_rec.pre_pro_lt, p_item_attribute_rec.post_pro_lt,
          p_item_attribute_rec.substitution_window, p_item_attribute_rec.create_supply_flag,
          p_item_attribute_rec.dest_inv_item_id,
          p_item_attribute_rec.item_name,
          p_item_attribute_rec.atp_rule_id, p_item_attribute_rec.rounding_control_type,
          --diag_atp
          p_item_attribute_rec.unit_volume, p_item_attribute_rec.unit_weight,
          p_item_attribute_rec.volume_uom, p_item_attribute_rec.weight_uom,
          p_item_attribute_rec.uom_code, p_item_attribute_rec.inventory_item_id,
          p_item_attribute_rec.processing_lt -- SCLT (Supplier Capacity Lead Time)
          , p_item_attribute_rec.base_item_id
          , p_item_attribute_rec.product_family_id -- time_phased_atp
          ---bug 3917625
          ,p_item_attribute_rec.plan_id
          , p_item_attribute_rec.lowest_level_src -- ATP4drp obtain flag applicable to DRP plan items.
   FROM   msc_system_items i
   WHERE  i.sr_inventory_item_id = p_inventory_item_id
   AND    i.organization_id = p_organization_id
   --- bug 3917625: Read item attribute from planned data
   --AND    i.plan_id = -1
   AND    i.plan_id = p_plan_id
   AND    i.sr_instance_id = p_instance_id;

   --e_cto_rearch

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'l_bom_item_type = '||l_bom_item_type);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'l_atp_check     = '||l_atp_check);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'l_replenish_flag = ' || l_replenish_flag);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'l_atp_comp_flag = ' || l_atp_comp_flag);
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'UOM CODE = ' || p_item_attribute_rec.uom_code); --bug3110023
      msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
      msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'Lowest Level Source = ' || p_item_attribute_rec.lowest_level_src);
   END IF;

   -- ATP4drp re-set component flag for DRP plans
   IF NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) = 5 THEN
      IF l_atp_comp_flag = 'C' THEN
         l_atp_comp_flag := 'Y';
      ELSIF l_atp_comp_flag = 'R' THEN
         l_atp_comp_flag := 'N';
      END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: Before Reset Product Family = ' || p_item_attribute_rec.product_family_id);
      END IF;
      p_item_attribute_rec.product_family_id := p_item_attribute_rec.dest_inv_item_id;
      -- Bug 4052808 DRP Plans only support Fixed Lead Times.
      p_item_attribute_rec.variable_lt := 0;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'l_atp_comp_flag = ' || l_atp_comp_flag);
         msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'PF not applicable for DRP plans');
         msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'Reset Product Family = ' || p_item_attribute_rec.product_family_id);
         msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
      END IF;
   END IF;
   -- END ATP4drp

   /* s_cto_rearch
   IF l_bom_item_type = 4 AND NVL(l_atp_check, -1) = 2 THEN
       l_atp_flag := 'N';
   END IF;
    e_cto_rearch */

    -- Fix for Bug 1413039 9/22/00 - NGOEL
    -- Since we don't support multi-level ATP for ODS, set
    -- return ATP component flag as N in case of ODS.
  IF l_bom_item_type in (1,2) and l_pick_comp_flag = 'Y' THEN
     --We treat PTO option class and model as non-atpable
     l_atp_flag := 'N';
     l_atp_comp_flag := 'N';

  ELSIF MSC_ATP_PVT.G_INV_CTP = 5 THEN
    IF ((l_bom_item_type = 1 or l_bom_item_type = 4) and l_replenish_flag = 'Y') AND
          p_item_attribute_rec.parent_pegging_id is null THEN
       --If ATO model or ATO item then we may need to explode it.
       If l_atp_comp_flag = 'C' THEN

         l_atp_comp_flag := 'Y';

       ELSIF l_atp_comp_flag = 'R' THEN
          l_atp_comp_flag := 'N';
       END IF;

    ELSE
       l_atp_comp_flag := 'N';
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('l_bom_item_type := ' || l_bom_item_type);
        msc_sch_wb.atp_debug('parent_item_id := ' || p_item_attribute_rec.parent_item_id);

    END IF;
    IF NVL(p_item_attribute_rec.parent_item_id, -1) = p_inventory_item_id THEN
        --atp flag for this model = 'Y'. We are coming here for second time
        -- set the atp comp flag = 'N' so that model is not exploded again.
        l_atp_comp_flag := 'N';
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Turn off atp comp flag for model');
        END IF;
    END IF;
  ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('PDS ATP');
    END IF;
    IF NVL(p_item_attribute_rec.parent_repl_ord_flag, 'N') = 'Y' and
                    NVL(p_item_attribute_rec.parent_bom_item_type, 4) = 4 THEN
        --parent is config item
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Parent is ato item');
        END IF;
        IF l_bom_item_type in (1,2) THEN
            --here parent is config and thisi tem is model or option class
            -- we turn off the atp comp flag, honor atpp flga as it is
            l_atp_comp_flag := 'N'; --- we turn off components flags
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Model or option class, turn off components flag');
            END IF;
        END IF;
    ELSIF NVL(p_item_attribute_rec.parent_bom_item_type, 4) = 1 and
                      NVL(p_item_attribute_rec.parent_repl_ord_flag, 'N') = 'Y'  And l_bom_item_type = 2 THEN
         ---parent is a model and this item is option class
         ---atp flag is honored as such
         ---components resource part is copied over from model's components flag
         IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug(' parent is model, This is option class');
         END IF;

         IF NVL(p_item_attribute_rec.parent_comp_flag, 'N') in ('R', 'C') THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug(' Resource check on model is on, set the resource flag on option class');
              END IF;
               l_atp_comp_flag := 'R';
         ELSE
              l_atp_comp_flag := 'N';
         END IF;

    ELSIF l_bom_item_type = 1 THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('l_bom_item_type := ' || l_bom_item_type);
           msc_sch_wb.atp_debug('parent_item_id := ' || p_item_attribute_rec.parent_item_id);

        END IF;
        IF NVL(p_item_attribute_rec.parent_item_id, -1) = p_inventory_item_id THEN
           --atp flag for this model = 'Y'. We are coming here for second time
           -- set the atp comp flag = 'N' so that model is not exploded again.
           l_atp_comp_flag := 'N';
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Turn off atp comp flag for model');
           END IF;
        END IF;

    END IF;


  END IF;
  MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID := NULL;
  p_item_attribute_rec.atp_flag := l_atp_flag;
  p_item_attribute_rec.atp_comp_flag := l_atp_comp_flag;

  --s_cto_rearch
  p_item_attribute_rec.bom_item_type := l_bom_item_type;
  p_item_attribute_rec.replenish_to_ord_flag := l_replenish_flag;
  --e_cto_rearch

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'l_source_org_id = '||l_source_org_id);
  END IF;
  p_item_attribute_rec.cto_source_org_id := l_source_org_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'get_item_attr ATP flag is '||l_atp_flag);
     msc_sch_wb.atp_debug('GET_ITEM_ATTRIBUTES: ' || 'get_item_attr ATP components flag is '||l_atp_comp_flag);
  END IF;

  p_item_attribute_rec.instance_id := p_instance_id;
  p_item_attribute_rec.organization_id := p_organization_id;
  p_item_attribute_rec.sr_inv_item_id := p_inventory_item_id;
EXCEPTION
   WHEN  NO_DATA_FOUND THEN
       p_item_attribute_rec.instance_id := null;
       p_item_attribute_rec.organization_id := null;
       p_item_attribute_rec.sr_inv_item_id := null;
       MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID := p_inventory_item_id;
       p_item_attribute_rec.atp_flag := 'N';
       p_item_attribute_rec.atp_comp_flag := 'N';
       p_item_attribute_rec.pre_pro_lt := 0;
       p_item_attribute_rec.fixed_lt := 0;
       p_item_attribute_rec.variable_lt := 0;
       p_item_attribute_rec.post_pro_lt := 0;
       p_item_attribute_rec.substitution_window := 0;
       p_item_attribute_rec.create_supply_flag := 2;
       p_item_attribute_rec.atp_rule_id := NULL;
       p_item_attribute_rec.cto_source_org_id := l_source_org_id;
       p_item_attribute_rec.uom_code := NULL; --rajjain 12/10/2002
       p_item_attribute_rec.inventory_item_id := NULL; --rajjain 12/10/2002
       p_item_attribute_rec.processing_lt := 0;   -- SCLT (Supplier Capacity Lead Time)
       p_item_attribute_rec.lowest_level_src := 0;   -- ATP4drp
END GET_ITEM_ATTRIBUTES;

PROCEDURE GET_ORG_ATTRIBUTES (
        p_instance_id                   IN      NUMBER,
        p_organization_id               IN      NUMBER,
        x_org_attribute_rec             OUT     NoCopy MSC_ATP_PVT.org_attribute_rec)
IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('inside get_org_attributes');
      msc_sch_wb.atp_debug('GET_ORG_ATTRIBUTES: ' || 'sr_instance_id = '||p_instance_id);
      msc_sch_wb.atp_debug('GET_ORG_ATTRIBUTES: ' || 'organization_id = '||p_organization_id);
   END IF;

   SELECT  tp.default_atp_rule_id,
           tp.calendar_code,
           tp.calendar_exception_set_id,
           tp.default_demand_class,
           tp.organization_code,
           tp.organization_type, --(ssurendr) Bug 2865389
           NVl(mp.network_scheduling_method,1), --bug3601223
           NVL(tp.use_phantom_routings, 2) --4570421

    INTO   x_org_attribute_rec.default_atp_rule_id,
           x_org_attribute_rec.cal_code,
           x_org_attribute_rec.cal_exception_set_id,
           x_org_attribute_rec.default_demand_class,
           x_org_attribute_rec.org_code,
           x_org_attribute_rec.org_type, --(ssurendr) Bug 2865389
           x_org_attribute_rec.network_scheduling_method, --bug3601223
           x_org_attribute_rec.use_phantom_routings --4570421

    FROM   msc_trading_partners tp, msc_parameters mp
    WHERE  tp.sr_tp_id = p_organization_id
    AND    tp.sr_instance_id = p_instance_id
    AND    tp.partner_type = 3
    AND    mp.ORGANIZATION_ID(+) = tp.sr_tp_id
    AND    mp.SR_INSTANCE_ID(+) = tp.sr_instance_id;

    x_org_attribute_rec.instance_id          := p_instance_id;
    x_org_attribute_rec.organization_id      := p_organization_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('GET_ORG_ATTRIBUTES: network_scheduling_method := ' || x_org_attribute_rec.network_scheduling_method);
   END IF;

EXCEPTION WHEN others THEN
  x_org_attribute_rec.instance_id          := null;
  x_org_attribute_rec.organization_id      := null;
  x_org_attribute_rec.default_atp_rule_id  := null;
  x_org_attribute_rec.cal_code             := null;
  x_org_attribute_rec.cal_exception_set_id := null;
  x_org_attribute_rec.default_demand_class := null;
  x_org_attribute_rec.org_code             := null;
  x_org_attribute_rec.org_type             := null; --(ssurendr) Bug 2865389
  x_org_attribute_rec.network_scheduling_method := 1; --bug3601223


END GET_ORG_ATTRIBUTES;

PROCEDURE get_global_org_info (
        p_instance_id                   IN      NUMBER,
        p_organization_id               IN      NUMBER) IS

x_org_attribute_rec           MSC_ATP_PVT.org_attribute_rec;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('In get_global_org_info core');
   END IF;

   IF (MSC_ATP_PVT.G_ORG_INFO_REC.instance_id IS NULL) OR
      (MSC_ATP_PVT.G_ORG_INFO_REC.organization_id IS NULL) OR
      (MSC_ATP_PVT.G_ORG_INFO_REC.instance_id <> p_instance_id) OR
      (MSC_ATP_PVT.G_ORG_INFO_REC.organization_id <> p_organization_id) THEN

     GET_ORG_ATTRIBUTES(p_instance_id,  p_organization_id, x_org_attribute_rec);

     MSC_ATP_PVT.G_ORG_INFO_REC := x_org_attribute_rec;

   END IF;

END get_global_org_info;

PROCEDURE get_global_item_info (p_instance_id             IN  NUMBER,
                               p_plan_id                IN  NUMBER,
                               p_inventory_item_id      IN  NUMBER,
                               p_organization_id        IN  NUMBER,
                               p_item_attribute_rec     IN  MSC_ATP_PVT.item_attribute_rec )  IS

 l_item_attribute_rec         MSC_ATP_PVT.item_attribute_rec;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Inside Get Global item attributes');
      msc_sch_wb.atp_debug('parent_repl_ord_flag := ' || p_item_attribute_rec.parent_repl_ord_flag);
      msc_sch_wb.atp_debug('parent_bom_item_type := ' || p_item_attribute_rec.parent_bom_item_type);
      msc_sch_wb.atp_debug('parent_comp_flag := ' || p_item_attribute_rec.parent_comp_flag);
      msc_sch_wb.atp_debug('parent_atp_flag := ' || p_item_attribute_rec.parent_atp_flag);
      msc_sch_wb.atp_debug('parent_pegging_id := ' || p_item_attribute_rec.parent_pegging_id);
      msc_sch_wb.atp_debug('p_instance_id := ' || p_instance_id);
      msc_sch_wb.atp_debug('p_plan_id := ' || p_plan_id);
      msc_sch_wb.atp_debug('p_inventory_item_id := ' || p_inventory_item_id);
      msc_sch_wb.atp_debug('p_organization_id := ' || p_organization_id);
   END IF;
   IF (MSC_ATP_PVT.G_ITEM_INFO_REC.instance_id IS NULL) OR
      (MSC_ATP_PVT.G_ITEM_INFO_REC.organization_id IS NULL) OR
      (MSC_ATP_PVT.G_ITEM_INFO_REC.sr_inv_item_id IS NULL) OR
      (MSC_ATP_PVT.G_ITEM_INFO_REC.instance_id <> p_instance_id) OR
      (MSC_ATP_PVT.G_ITEM_INFO_REC.organization_id <> p_organization_id) OR
      (MSC_ATP_PVT.G_ITEM_INFO_REC.sr_inv_item_id <> p_inventory_item_id)
      ---3917625: read the item attributes if plan chnages
      OR (NVL(MSC_ATP_PVT.G_ITEM_INFO_REC.plan_id, -12345) <> p_plan_id) THEN


     msc_sch_wb.atp_debug('Item/Org/instance/plan info has changed. Recalculate item attributes');
     l_item_attribute_rec.parent_repl_ord_flag := p_item_attribute_rec.parent_repl_ord_flag;
     l_item_attribute_rec.parent_bom_item_type := p_item_attribute_rec.parent_bom_item_type;
     l_item_attribute_rec.parent_comp_flag := p_item_attribute_rec.parent_comp_flag;
     l_item_attribute_rec.parent_atp_flag := p_item_attribute_rec.parent_atp_flag;
     l_item_attribute_rec.parent_pegging_id := p_item_attribute_rec.parent_pegging_id;
     l_item_attribute_rec.parent_item_id := p_item_attribute_rec.parent_item_id;

     GET_ITEM_ATTRIBUTES(p_instance_id, p_plan_id, p_inventory_item_id,
                                p_organization_id, l_item_attribute_rec);

     MSC_ATP_PVT.G_ITEM_INFO_REC := l_item_attribute_rec;


   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_global_item_info ATP flag is '||
                                MSC_ATP_PVT.G_ITEM_INFO_REC.atp_flag);
   END IF;

END get_global_item_info;

-- New Procedure Supplier Capacity and Lead Time (SCLT) Project.
PROCEDURE get_global_plan_info (p_instance_id        IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_demand_class       IN VARCHAR2,
                                p_parent_plan_id     IN NUMBER DEFAULT NULL, --bug3510475
                                p_time_phased_atp    IN VARCHAR2 := 'N' ) IS -- time_phased_atp

p_plan_info_rec                 MSC_ATP_PVT.plan_info_rec;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('In get_global_plan_info core');
      msc_sch_wb.atp_debug('g__inv_id := ' || MSC_ATP_PVT.G_ITEM_INFO_REC.sr_inv_item_id);
      msc_sch_wb.atp_debug('p_inv_id := ' || p_inventory_item_id);
      msc_sch_wb.atp_debug('g_instance_id := ' || MSC_ATP_PVT.G_ITEM_INFO_REC.instance_id);
      msc_sch_wb.atp_debug('p_instance_id := ' || p_instance_id);
      msc_sch_wb.atp_debug('g_org_id := ' || MSC_ATP_PVT.G_ITEM_INFO_REC.organization_id);
      msc_sch_wb.atp_debug('p_org_id := ' || p_organization_id);
      msc_sch_wb.atp_debug('g_plan_id := ' || MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id);
   END IF;

   IF (MSC_ATP_PVT.G_ITEM_INFO_REC.sr_inv_item_id IS NULL) OR
      (MSC_ATP_PVT.G_ITEM_INFO_REC.instance_id <> p_instance_id) OR
      (MSC_ATP_PVT.G_ITEM_INFO_REC.organization_id <> p_organization_id) OR
      (MSC_ATP_PVT.G_ITEM_INFO_REC.sr_inv_item_id <> p_inventory_item_id) OR
      -- If Item information does not match
      (MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id IS NULL) OR
      (MSC_ATP_PVT.G_PLAN_INFO_REC.sr_instance_id <> p_instance_id) OR
      (MSC_ATP_PVT.G_PLAN_INFO_REC.organization_id <> p_organization_id) THEN
      -- Or If the Plan Information does not match then obtain the plan info.

      --bug3510475
      Get_Plan_Info(p_instance_id, p_inventory_item_id,
                    p_organization_id, p_demand_class, p_plan_info_rec,p_parent_plan_id,p_time_phased_atp); -- time_phased_atp
      MSC_ATP_PVT.G_PLAN_INFO_REC := p_plan_info_rec;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_global_plan_info Plan name is '||
                                MSC_ATP_PVT.G_PLAN_INFO_REC.plan_name);
      msc_sch_wb.atp_debug('get_global_plan_info Argument Organization ID is '||
                                                               p_organization_id);
      msc_sch_wb.atp_debug('get_global_plan_info Plan owning organization is '||
                                     MSC_ATP_PVT.G_PLAN_INFO_REC.organization_id);
   END IF;

END get_global_plan_info;

--diag_atp
Procedure get_infinite_time_fence_date (p_instance_id             IN NUMBER,
                                       p_inventory_item_id        IN NUMBER,
                                       p_organization_id          IN NUMBER,
                                       p_plan_id                  IN NUMBER,
                                       x_infinite_time_fence_date OUT NoCopy DATE,
                                       x_atp_rule_name            OUT NoCopy VARCHAR2,
                                       -- Bug 3036513 Add additional parameters with
                                       -- defaults in spec for resource infinite time fence.
                                       p_resource_id              IN NUMBER,
                                       p_department_id            IN NUMBER)
IS
l_infinite_time_fence_date      DATE;
l_item_type                     NUMBER;

BEGIN

  -- Bug 3036513 Print out the parameter values passed in to the procedure.
  IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('****inside get_infinite_time_fence_date****');
      msc_sch_wb.atp_debug('GET_INFINITE_TIME_FENCE_DATE: sr_instance_id = '||p_instance_id);
      msc_sch_wb.atp_debug('GET_INFINITE_TIME_FENCE_DATE: ' ||
                              'sr_inventory_item_id = '||p_inventory_item_id);
      msc_sch_wb.atp_debug('GET_INFINITE_TIME_FENCE_DATE: ' ||
                              'organization_id = '||p_organization_id);
      msc_sch_wb.atp_debug('GET_INFINITE_TIME_FENCE_DATE: ' || 'plan_id = '||p_plan_id);
      msc_sch_wb.atp_debug('GET_INFINITE_TIME_FENCE_DATE: resource_id = '||p_resource_id);
      msc_sch_wb.atp_debug('GET_INFINITE_TIME_FENCE_DATE: department_id = '||p_department_id);
  END IF;
  -- End Bug 3036513.

  -- Bug 1566260, in case of modle or option class for PDS ATP, return null.
  -- This way, we always will work with multi-level results rather than single level
  -- This was done so that pegging tree is always available for Mulit-org CTO and
  -- demand entries could be stored for planning purposes.
  /* s_CTO rearch : we start honoring infinite time fence on model
  IF p_plan_id <> -1  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'selecting item type for PDS');
    END IF;
    SELECT i.bom_item_type
    INTO   l_item_type
    FROM   msc_system_items i
    WHERE  i.plan_id = p_plan_id
    AND    i.sr_instance_id = p_instance_id
    AND    i.organization_id = p_organization_id
    AND    i.sr_inventory_item_id = p_inventory_item_id;
  END IF;

  IF nvl(l_item_type, -1) IN (1,2)  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'PDS item type is model(1) or option class(2) : '||l_item_type);
    END IF;
    l_infinite_time_fence_date := null;
  ELSE

  --e_CTO_rearch */

    -- Bug 2877340, 2746213
    -- Read the Profile option to pad the user defined days
    -- to infinite Supply fence.
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: Profile value for Infinite Supply Pad');
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: MSC_ATP_PVT.G_INF_SUP_TF_PAD ' || MSC_ATP_PVT.G_INF_SUP_TF_PAD);
    END IF;
    -- Bug 3036513 If resource_id is NULL get the infinite_time_fence_date
    -- for just the item.
    IF (p_resource_id IS NULL) THEN

       -- Obtain the ITF the normal way.
       SELECT c2.calendar_date, r.rule_name
       INTO   l_infinite_time_fence_date, x_atp_rule_name
       FROM   msc_calendar_dates c2,
              msc_calendar_dates c1,
              msc_atp_rules r,
              msc_trading_partners tp,
              msc_system_items i
       WHERE  i.sr_inventory_item_id = p_inventory_item_id
       AND    i.organization_id = p_organization_id
       --AND    i.plan_id = p_plan_id
       AND    i.plan_id = -1   -- for 1478110
       AND    i.sr_instance_id = p_instance_id
       AND    tp.sr_tp_id = i.organization_id
       AND    tp.sr_instance_id = i.sr_instance_id
       AND    tp.partner_type = 3
       AND    r.rule_id = NVL(i.atp_rule_id, NVL(tp.default_atp_rule_id,0))
       AND    r.sr_instance_id = p_instance_id
       AND    c1.sr_instance_id = p_instance_id
       AND    c1.calendar_date = TRUNC(sysdate)
       AND    c1.calendar_code = tp.calendar_code
       AND    c1.exception_set_id = -1
       AND    c2.sr_instance_id = p_instance_id
       -- Bug 2877340, 2746213
       -- Add Infinite Supply Time Fence PAD
       --bug3609031 adding ceil
       AND    c2.seq_num = c1.next_seq_num +
                   DECODE(r.infinite_supply_fence_code,
                   1, ceil(i.cumulative_total_lead_time) + MSC_ATP_PVT.G_INF_SUP_TF_PAD,
                   2, ceil(i.cum_manufacturing_lead_time) + MSC_ATP_PVT.G_INF_SUP_TF_PAD,
                   3, DECODE(NVL(ceil(i.preprocessing_lead_time),-1)+
                             NVL(ceil(i.full_lead_time),-1)+
                             NVL(ceil(i.postprocessing_lead_time),-1),-3,
                             NULL,              -- All are NULL so return NULL.
                             NVL(ceil(i.preprocessing_lead_time),0)+   -- Otherwise
                             NVL(ceil(i.full_lead_time),0) +           -- evaluate to
                             NVL(ceil(i.postprocessing_lead_time),0) -- NON NULL
                             + MSC_ATP_PVT.G_INF_SUP_TF_PAD),
                                                -- Bugs 1986353, 2004479.
                   4, r.infinite_supply_time_fence)
       -- End Bug 2877340, 2746213
       AND    c2.calendar_code = c1.calendar_code
       AND    c2.exception_set_id = -1;

    ELSE -- Bug 3036513 obtain infinite_time_fence_date for resource.
       SELECT c2.calendar_date, r.rule_name
       INTO   l_infinite_time_fence_date, x_atp_rule_name
       FROM   msc_calendar_dates c2,
              msc_calendar_dates c1,
              msc_atp_rules r,
              msc_trading_partners tp,
              msc_department_resources dep_res
       WHERE  dep_res.resource_id = p_resource_id
       AND    dep_res.department_id = p_department_id
       AND    dep_res.organization_id = p_organization_id
       AND    dep_res.plan_id = p_plan_id
       AND    dep_res.sr_instance_id = p_instance_id
       AND    tp.sr_tp_id = dep_res.organization_id
       AND    tp.sr_instance_id = dep_res.sr_instance_id
       AND    tp.partner_type = 3
       AND    r.rule_id = NVL(dep_res.atp_rule_id, NVL(tp.default_atp_rule_id,0))
       AND    r.sr_instance_id = dep_res.sr_instance_id
       AND    c1.sr_instance_id = dep_res.sr_instance_id
       AND    c1.calendar_date = TRUNC(sysdate)
       AND    c1.calendar_code = tp.calendar_code
       AND    c1.exception_set_id = -1
       AND    c2.sr_instance_id = dep_res.sr_instance_id
       AND    c2.seq_num = c1.next_seq_num + r.infinite_supply_time_fence
       AND    c2.calendar_code = c1.calendar_code
       AND    c2.exception_set_id = c1.exception_set_id;
    END IF;
    -- End Bug 3036513 p_resource_id is NULL

  --s_cto_rearch
  --END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'l_infinite_time_fence_date'||l_infinite_time_fence_date);
      msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'ATP Rule := ' || x_atp_rule_name);
   END IF;
  x_infinite_time_fence_date := l_infinite_time_fence_date;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       -- for 1478110.  please refer to the BUG
       --IF p_plan_id = -1 THEN

       -- ngoel 2/15/2002, modified to avoid no_data_found in case call is made from
       -- View_Allocation

       IF p_plan_id IN (-1, -200) THEN
         x_infinite_time_fence_date := null;
       ELSE

         -- since this is pds, use planning's cutoff date as the infinite
         -- time fence date if no rule at item/org level, and no rule
         -- at org default.

         SELECT curr_cutoff_date
         INTO   l_infinite_time_fence_date
         FROM   msc_plans
         WHERE  plan_id = p_plan_id;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'l_infinite_time_fence_date'||l_infinite_time_fence_date);
         END IF;
         x_infinite_time_fence_date := l_infinite_time_fence_date;
       END IF;

END get_infinite_time_fence_date;

-- krajan
-- New API to get all shipping methods for :
--     * ORG - ORG
--     * ORG - Customer Site
--
-- Can be called from both source and destnation
--
-- See design document for Bug 2359231
-- Checked- in as part of pegging enhancement I project
--

PROCEDURE Get_Shipping_Methods (
        p_from_organization_id            IN      number,
        p_to_organization_id              IN      number,
        p_to_customer_id                  IN      number,
        p_to_customer_site_id             IN      number,
        p_from_instance_id                IN      number,
        p_to_instance_id                  IN      number,
        p_session_id                      IN      number,
        p_calling_module                  IN      number,
        x_return_status                   OUT NOCOPY    varchar2
)
IS

---------------    CURSORS

-- For Source Region Level Data
CURSOR  c_lead_time (c_from_loc_id number, c_partner_site_id number, c_session_id number)
IS
SELECT  mism.ship_method, mism.intransit_time,
        ((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM    mtl_interorg_ship_methods mism,
        msc_regions_temp mrt
WHERE   mism.from_location_id = c_from_loc_id
AND     mism.to_region_id = mrt.region_id
AND     mrt.session_id = c_session_id
AND     mrt.partner_site_id = c_partner_site_id
ORDER BY 3;


-- For Destination Region Level Data
CURSOR  c_lead_time_dest (c_from_location_id number , c_from_instance_id number,
                          c_partner_site_id number, c_to_instance_id number,
                          c_session_id number
                         )
IS
SELECT  mism.ship_method, mism.intransit_time,
        ((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM    msc_interorg_ship_methods mism,
        msc_regions_temp mrt
WHERE   mism.plan_id = -1
AND     mism.from_location_id = c_from_location_id
AND     mism.sr_instance_id = c_from_instance_id
AND     mism.sr_instance_id2 = c_to_instance_id
AND     mism.to_region_id = mrt.region_id
AND     mrt.session_id = c_session_id
AND     mrt.partner_site_id = c_partner_site_id
ORDER BY 3;


----------------      Local Variables

l_ship_method_arr       MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr();
l_lead_time_arr         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

l_ship_method_arr_null  MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr();
l_lead_time_arr_null    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();

l_counter               number;
l_counter2              number;
l_level_tmp             number;
l_level_orig            number;
l_intransit_time_tmp    number;
l_ship_method_tmp       varchar2(30);
l_from_location_id      number;
l_to_location_id        number;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug ('------------Get Shipping Methods----------');
    msc_sch_wb.atp_debug ('From Organization        : ' || p_from_organization_id );
    msc_sch_wb.atp_debug ('To Organization          : ' || p_to_organization_id);
    msc_sch_wb.atp_debug ('To Customer              : ' || p_to_customer_id );
    msc_sch_wb.atp_debug ('To Customer Site         : ' || p_to_customer_site_id );
    msc_sch_wb.atp_debug ('From Instance            : ' || p_from_instance_id );
    msc_sch_wb.atp_debug ('To Instance              : ' || p_to_instance_id );
    msc_sch_wb.atp_debug ('Session ID               : ' || p_session_id);
    msc_sch_wb.atp_debug ('Calling Module           : ' || p_calling_module);
  END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call Get Regions to pipulate Region level data

    MSC_SATP_FUNC.Get_Regions (
        p_to_customer_site_id,
        p_calling_module,
        p_to_instance_id,
        p_session_id,
        NULL, -- dblink
        x_return_status
    );

    if (p_calling_module = 724) then
        -- On Destination
        if (p_to_organization_ID is not NULL) and
           (p_to_customer_id is NULL and p_to_customer_site_id is NULL) then
			-- Bug 3515520, don't use org in case customer/site is populated.
            -- Org - Org Intransit Lead Time
            -- bug 2958287
            BEGIN
                insert into mrp_atp_schedule_temp
                (session_id, inventory_item_id, scenario_id, delivery_lead_time, ship_method, status_flag)
                (
                    select  p_session_id,
                            -1,
                            -1,
                            intransit_time,
                            ship_method,
                            100
                      from  msc_interorg_ship_methods
                     where  from_organization_id = p_from_organization_id
                       and  to_organization_id = p_to_organization_id
                       and  sr_instance_id = p_from_instance_id
                       and  sr_instance_id2 = p_to_instance_id
                       and  to_region_id is null
                       and  plan_id = -1
                );
            EXCEPTION
                when NO_DATA_FOUND then
                    null;
            END;
        -----------------------------------------------------------
        --else -- p_to_org_id is not NULL
        elsif p_to_customer_site_id is NOT NULL then
			-- Bug 3515520, verify that customer site is populated.
            l_from_location_id := MSC_ATP_FUNC.get_location_id ( p_from_instance_id,
                                                            p_from_organization_id,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            NULL
                                                            );

            l_to_location_id := MSC_ATP_FUNC.get_location_id ( p_to_instance_id,
                                                            NULL,
                                                            p_to_customer_id,
                                                            p_to_customer_site_id,
                                                            NULL,
                                                            NULL
                                                            );

            if (l_from_location_id is NULL) then
                x_return_status := FND_API.G_RET_STS_ERROR;
                IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug ('Cannot map data to locations ');
                END IF;
                return;
            end if;

            -- Now try region mapping.
            BEGIN
               -- bug 2958287
               insert into mrp_atp_schedule_temp
                (session_id, inventory_item_id, scenario_id, delivery_lead_time, ship_method, status_flag)
                (
                    select  p_session_id,
                            -1,
                            -1,
                            intransit_time,
                            ship_method,
                            100
                      from  msc_interorg_ship_methods
                     where  plan_id = -1
                       and  from_location_id = l_from_location_id
                       and  sr_instance_id = p_from_instance_id
                       and  to_location_id = l_to_location_id
                       and  sr_instance_id2 = p_to_instance_id
                       and  to_region_id is NULL
                );
            EXCEPTION
                when DUP_VAL_ON_INDEX then
                   IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug ('Data already present');
                    END IF;
            END;

            if (sql%rowcount = 0) then
               IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug ('Shifting to Regions and Zones data');
               END IF;

                l_lead_time_arr := l_lead_time_arr_null;
                l_ship_method_arr := l_ship_method_arr_null;
                l_level_orig := NULL;

                l_counter := 0;
                OPEN c_lead_time_dest (l_from_location_id, p_from_instance_id,
                                       p_to_customer_site_id, p_to_instance_id,
                                       p_session_id
                                      );

                LOOP
                    FETCH c_lead_time_dest INTO  l_ship_method_tmp, l_intransit_time_tmp, l_level_tmp;
                    EXIT WHEN c_lead_time_dest%NOTFOUND;

                    if (l_level_orig is NULL) then
                        l_level_orig := l_level_tmp;
                    end if;

                    if (l_level_orig <> l_level_tmp) then
                        EXIT;
                    else
                        l_lead_time_arr.EXTEND;
                        l_ship_method_arr.EXTEND;
                        l_counter := l_counter + 1;

                        l_lead_time_arr(l_counter) := l_intransit_time_tmp;
                        l_ship_method_arr(l_counter) := l_ship_method_tmp;

                        IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug ('Method : ' || l_ship_method_tmp  || '  -  Time : ' || l_intransit_time_tmp);
                        END IF;
                    end if;

                END LOOP;

                CLOSE c_lead_time_dest;

                if (l_counter = 0) then
                   IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug ('No data from regions table');
                   END IF;
                else
                    BEGIN
                        forall l_counter2 in 1..l_counter
                         insert into mrp_atp_schedule_temp
                         (session_id, inventory_item_id, scenario_id, delivery_lead_time, ship_method, status_flag)
                         values
                         (
                            p_session_id,
                            -1,
                            -1,
                            l_lead_time_arr (l_counter2),
                            l_ship_method_arr (l_counter2),
                            100
                         );
                    EXCEPTION
                        when others then
                           IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug ('Unable to insert data');
                            END IF;
                    END;
                end if; -- l_counter = 0
            end if;
        end if;
----------------------------------------------------------------
    else -- case where calling_module <> 724
        -- On Source
        if (p_to_organization_ID is not NULL) and
           (p_to_customer_id is NULL and p_to_customer_site_id is NULL) then
            -- Bug 3515520, don't use org in case customer/site is populated.
            -- Org - Org Intransit Lead Time
            BEGIN
               IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug ('To Organization Specified ');
                END IF;
                insert into mrp_atp_schedule_temp
                (session_id, inventory_item_id, scenario_id, delivery_lead_time, ship_method, status_flag)
                (
                    select  p_session_id,
                            -1,
                            -1,
                            intransit_time,
                            ship_method,
                            100
                      from  mtl_interorg_ship_methods
                     where  from_organization_id = p_from_organization_id
                       and  to_organization_id = p_to_organization_id
                );
               IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug ('Records inserted into table : ' || sql%rowcount);
                END IF;
            EXCEPTION
                when OTHERS then
                    null;
            END;
        -----------------------------------------------------------
        --else -- p_to_organization_ID is not NULL
        elsif p_to_customer_site_id is NOT NULL then
        -- Bug 3515520, verify that customer site is populated.
            -- Org to Customer intransit Lead Time Calculation

            IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug ('Customer ID specified ');
            END IF;
            -- First get the location corresponding to the customer
            BEGIN
                l_from_location_id := MSC_SATP_FUNC.src_location_id (p_from_organization_id,
                                                                 NULL,
                                                                 NULL);
                l_to_location_id := MSC_SATP_FUNC.src_location_id (NULL,
                                                               p_to_customer_id,
                                                               p_to_customer_site_id);
            EXCEPTION
                when NO_DATA_FOUND then
                   IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug ('Unable to map organization of customer to location');
                   END IF;
            END;

            if (l_from_location_id is NULL) then
                IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug ('From location is NULL');
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
            end if;

           IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug ('From Location ID : ' || l_from_location_id);
            msc_sch_wb.atp_debug ('To Location ID   : ' || l_to_location_id );
           END IF;

            BEGIN
               insert into mrp_atp_schedule_temp
                (session_id, inventory_item_id, scenario_id, delivery_lead_time, ship_method, status_flag)
                (
                    select  p_session_id,
                            -1,
                            -1,
                            intransit_time,
                            ship_method,
                            100
                      from  mtl_interorg_ship_methods
                     where  from_location_id = l_from_location_id
                       and  to_location_id = l_to_location_id
                );
            EXCEPTION
                when DUP_VAL_ON_INDEX then
                   IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug ('Data already present');
                   END IF;

                when NO_DATA_FOUND then
                    null;
            END;

            if (sql%rowcount = 0) then
                IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug ('Shifting to Regions and Zones data');
                END IF;

                l_level_orig := NULL;
                l_lead_time_arr := l_lead_time_arr_null;
                l_ship_method_arr := l_ship_method_arr_null;

                l_counter := 0;
                OPEN c_lead_time (l_from_location_id, p_to_customer_site_id, p_session_id);

                LOOP
                    FETCH c_lead_time INTO  l_ship_method_tmp, l_intransit_time_tmp, l_level_tmp;
                    EXIT WHEN c_lead_time%NOTFOUND;

                    if (l_level_orig is NULL) then
                        l_level_orig := l_level_tmp;
                    end if;

                    if (l_level_orig <> l_level_tmp) then
                        EXIT;
                    else

                        l_lead_time_arr.EXTEND;
                        l_ship_method_arr.EXTEND;
                        l_counter := l_counter + 1;

                        l_lead_time_arr(l_counter) := l_intransit_time_tmp;
                        l_ship_method_arr(l_counter) := l_ship_method_tmp;

                       IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug ('Method : ' || l_ship_method_tmp || '  -  Time : ' || l_intransit_time_tmp);
                       END IF;

                    end if;
                END LOOP;

                CLOSE c_lead_time;

                if (l_counter = 0) then
                   IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug ('No data from regions table');
                    END IF;
                else
                    BEGIN
                        forall l_counter2 in 1..l_counter
                         insert into mrp_atp_schedule_temp
                         (session_id, inventory_item_id, scenario_id, delivery_lead_time, ship_method, status_flag)
                         values
                         (
                            p_session_id,
                            -1,
                            -1,
                            l_lead_time_arr (l_counter2),
                            l_ship_method_arr (l_counter2),
                            100
                         );
                    EXCEPTION
                        when others then
                            IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug ('Unable to insert data');
                            END IF;
                    END;
                end if; -- l_counter = 0
            end if; --sql rowcount = 0
        end if; -- p_org_id is not nULL
     end if; -- calling module check

     -- Delete data from MSC_REGIONS_TEMP
     DELETE MSC_REGIONS_TEMP
     where  session_id = p_session_id;

     IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug (sql%rowcount || ' rows deleted from regions temp table.');
     END IF;

     COMMIT;

END Get_shipping_methods;



-- dsting
 --*
 --* search for transit times in this order
 --*
 --* 1) loc to loc
 --* 2) region to region
 --* 3) org to org
 --*
 --* if a ship method is specified then 1,2,3 with ship method specified
 --* 	then 1,2,3 with default times
 --*
 --*
 --
-- krajan: Part of 2359231 changes
PROCEDURE ATP_Shipping_Lead_Time (
  p_from_loc_id             IN NUMBER,
  p_to_customer_site_id     IN NUMBER,
  p_session_id              IN NUMBER,
  x_ship_method             IN OUT NOCOPY VARCHAR2,
  x_intransit_time          OUT NOCOPY NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2
) IS
l_to_location_id        number;
l_sql_stmt      VARCHAR2(1000);
BEGIN
	-- We will return an error if shipping gives us something
    -- that doesn't meet our assumptions
    IF PG_DEBUG in ('Y','C') then
    msc_sch_wb.atp_debug ('---- ATP_Shipping_Lead_time--- ');
    msc_sch_wb.atp_debug ('From Loc ID        : ' ||p_from_loc_id);
    msc_sch_wb.atp_debug ('To Customer Site   : ' ||p_to_customer_site_id);
    msc_sch_wb.atp_debug ('Session ID         : ' || p_session_id );
    msc_sch_wb.atp_debug ('Ship Method        : ' || x_ship_method);
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_to_location_id := -1;

    -- Map customer site ID to location ID using PO (HR) data.
    BEGIN
        l_sql_stmt := 'select location_id
                	 from PO_LOCATION_ASSOCIATIONS
                	 where SITE_USE_ID = :p_customer_site_id';
        execute immediate l_sql_stmt into l_to_location_id
                using p_to_customer_site_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN

        IF PG_DEBUG in ('Y','C') then
            msc_sch_wb.atp_debug ('Cannot map customer site ID to location ID');
        end if;
    END;

    IF PG_DEBUG in ('Y','C') then
        msc_sch_wb.atp_debug ('Location ID : ' || l_to_location_id);
    end if;

	MSC_SATP_FUNC.Get_Regions_Shipping(
		p_to_customer_site_id,   -- customer_site_id
		-1,   -- not destination(724)
		NULL, -- no instance id
		p_session_id,
		NULL, -- dblink
		x_return_status
	);

	MSC_SATP_FUNC.get_src_transit_time(
		NULL, -- from org
		p_from_loc_id,
		NULL, -- to org
		l_to_location_id,
		p_session_id,
		p_to_customer_site_id,   -- fake customer/partner_site_id
		x_ship_method,
		x_intransit_time
	);

	DELETE MSC_REGIONS_TEMP
	WHERE session_id = p_session_id
        AND partner_site_id = p_to_customer_site_id;

        if (PG_DEBUG in ('Y','C')) then
                msc_sch_wb.atp_debug ('Returning ....');
                msc_sch_wb.atp_debug ('  Ship Method  : ' || x_ship_method);
                msc_sch_wb.atp_debug ('  Lead Time    : ' || x_intransit_time);
        end if;

	IF x_intransit_time < 0 THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

END ATP_Shipping_Lead_Time;

-- Procedure added for bug 2585710
PROCEDURE Get_Sources_Info(p_session_id             IN  NUMBER,
                           p_inventory_item_id      IN  NUMBER,
                           p_customer_id            IN  NUMBER,
                           p_customer_site_id       IN  NUMBER,
                           p_assignment_set_id      IN  NUMBER,
                           p_ship_set_item_count    IN  NUMBER,
                           x_atp_sources            OUT NOCOPY MRP_ATP_PVT.Atp_Source_Typ,
                           x_return_status          OUT NOCOPY VARCHAR2,
                           p_partner_type           IN  NUMBER, --2814895
	                   p_party_site_id          IN  NUMBER, --2814895
	                   p_order_line_id          IN  NUMBER, --2814895
	                   p_requested_date         IN   DATE  DEFAULT NULL  --8524794
	                   )
IS
        l_dist_level_type	MRP_ATP_PUB.number_arr;
        l_counter               PLS_INTEGER := 0;
        l_sysdate               DATE;
        l_inserted_rows         PLS_INTEGER := 0;
        l_updated_rows          PLS_INTEGER := 0;
	l_min_region_value	PLS_INTEGER := 0;
	l_inventory_item_id_arr	MRP_ATP_PUB.number_arr;
	l_min_region_value_arr	MRP_ATP_PUB.number_arr;
	l_items_visited		PLS_INTEGER := 0;
	i			PLS_INTEGER := 0;

BEGIN

/*
We make use of fall-through approach in searching the sources.
We first find whether our search is at all required or not.
If yes, then which all levels have to searched. This is done
by selecting distinct assignment_type along with their level_id
by a preliminary SQL

We have 2 cases here:
Case1. Finding the sources for single item.
p_ship_set_item_count is null, p_inventory_item_id is not null
Case2. Finding the sources for ship set.
p_ship_set_item_count is not null, p_inventory_item_id is null.
*/
IF PG_DEBUG in ('Y', 'C') THEN

msc_sch_wb.atp_debug('Inside Get_Sources Info procedure');
msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'p_inventory_item_id ' || p_inventory_item_id);
msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'p_customer_id ' || p_customer_id);
msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'p_customer_site_id ' || p_customer_site_id);
msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'p_assignment_set_id ' || p_assignment_set_id);
msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'p_ship_set_item_count ' || p_ship_set_item_count);
END IF;

-- Initialize return status and sysdate.
x_return_status := FND_API.G_RET_STS_SUCCESS;
SELECT TRUNC(sysdate) INTO l_sysdate FROM dual;

SELECT
	DECODE(MSRA.ASSIGNMENT_TYPE,
		1, 9,
		2, 6,
		3, 4,
		4, 7,
		5, 3,
		6, 1,
		7, 8,
		8, 5,
		9, 2)		Level_id
BULK COLLECT INTO
        l_dist_level_type
FROM
        MSC_SOURCING_RULES      MSR,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_SR_SOURCE_ORG       SOURCE_ORG
WHERE
        MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = RECEIPT_ORG.SOURCING_RULE_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SR_RECEIPT_ID = SOURCE_ORG.SR_RECEIPT_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
GROUP BY MSRA.ASSIGNMENT_TYPE
ORDER BY Level_id;

IF (l_dist_level_type.COUNT = 0) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Checking assignment set id indicates no sources can be found.');
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'So, not searching in any level. Returning from here itself');
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     return;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
	FOR l_counter in 1..l_dist_level_type.COUNT LOOP
	   msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level: ' || l_dist_level_type(l_counter));
	END LOOP;
     END IF;
END IF;


-- case1
IF (p_ship_set_item_count IS NULL) THEN

IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Starting search for a single line item sources');
END IF;


FOR l_counter IN l_dist_level_type.FIRST..l_dist_level_type.LAST LOOP

IF (l_dist_level_type(l_counter) = 1) THEN

-- LEVEL 1, ASSIGNMENT TYPE 6: ITEM-ORG
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 1 (item-org)');
END IF;

SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
        MSC_SYSTEM_ITEMS                        ITEM,
        MSC_SR_SOURCE_ORG                       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG                      RECEIPT_ORG,
        MSC_SOURCING_RULES                      MSR,
        MSC_SR_ASSIGNMENTS                      MSRA,
        MSC_TP_SITE_ID_LID                      MTSIL
WHERE
        MSRA.ASSIGNMENT_TYPE = 6 /* ITEM-ORG */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.PARTNER_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID = MTSIL.TP_SITE_ID
        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
        AND     MTSIL.SR_INSTANCE_ID = ITEM.SR_INSTANCE_ID
        AND     ITEM.INVENTORY_ITEM_ID = MSRA.INVENTORY_ITEM_ID
        AND     ITEM.PLAN_ID = -1
        AND     ITEM.INVENTORY_ITEM_ID = p_inventory_item_id
        AND     ITEM.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     ITEM.SR_INSTANCE_ID = SOURCE_ORG.SOURCE_ORG_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate )) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;

-- Stopping check
IF (x_atp_sources.Rank.COUNT > 0) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 1. Search over.');
    END IF;
    return;
ELSE
    IF l_counter = l_dist_level_type.LAST THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
    ELSE
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No sources found at level 1. Continuing search..');
	END IF;
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 2) THEN

-- LEVEL 2, ASSIGNMENT TYPE 9: ITEM-REGION
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 2 (item-reg)');
END IF;

-- Search for sources for which following expression is minimum
SELECT	NVL(MIN(2000 + ((10 - NVL(MRT_INNER.REGION_TYPE, 0)) * 10) + DECODE(MRT_INNER.ZONE_FLAG, 'Y', 1, 0)), 0)
INTO	l_min_region_value
FROM
	MSC_SYSTEM_ITEMS        ITEM_INNER,
	MSC_SR_SOURCE_ORG       SOURCE_ORG_INNER,
	MSC_SR_RECEIPT_ORG      RECEIPT_ORG_INNER,
	MSC_SOURCING_RULES      MSR_INNER,
	MSC_SR_ASSIGNMENTS      MSRA_INNER,
	MSC_REGIONS_TEMP        MRT_INNER
WHERE
	MSRA_INNER.ASSIGNMENT_TYPE = 9
	AND     MSRA_INNER.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA_INNER.REGION_ID = MRT_INNER.REGION_ID
	AND     MRT_INNER.PARTNER_SITE_ID IS NOT NULL
	AND     MRT_INNER.SESSION_ID = p_session_id
	--AND     MRT_INNER.PARTNER_SITE_ID = p_customer_site_id
	AND     MRT_INNER.PARTNER_SITE_ID = decode( NVL(p_partner_type, 2), 2, p_customer_site_id , 3 , p_party_site_id, 4, p_order_line_id)  --2814895
	AND     MRT_INNER.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	--AND     MRT_INNER.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MSRA_INNER.INVENTORY_ITEM_ID = ITEM_INNER.INVENTORY_ITEM_ID
	AND     ITEM_INNER.PLAN_ID = -1
	AND     ITEM_INNER.INVENTORY_ITEM_ID = p_inventory_item_id
	AND     ITEM_INNER.ORGANIZATION_ID = SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID
	AND     ITEM_INNER.SR_INSTANCE_ID = SOURCE_ORG_INNER.SR_INSTANCE_ID
	AND     SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG_INNER.SR_RECEIPT_ID = RECEIPT_ORG_INNER.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG_INNER.DISABLE_DATE,l_sysdate)) >= l_sysdate
	AND     TRUNC(RECEIPT_ORG_INNER.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG_INNER.SOURCING_RULE_ID = MSR_INNER.SOURCING_RULE_ID
	AND     MSR_INNER.STATUS = 1
	AND     MSR_INNER.SOURCING_RULE_TYPE = 1
	AND     MSR_INNER.SOURCING_RULE_ID = MSRA_INNER.SOURCING_RULE_ID;

IF (l_min_region_value <> 0) THEN
-- Sources found.
IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All sources found at level 2.');
END IF;
-- Collect the found sources and return
SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
	MSC_SYSTEM_ITEMS        ITEM,
	MSC_SR_SOURCE_ORG       SOURCE_ORG,
	MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
	MSC_SOURCING_RULES      MSR,
	MSC_SR_ASSIGNMENTS      MSRA,
	MSC_REGIONS_TEMP        MRT
WHERE
	MSRA.ASSIGNMENT_TYPE = 9
	AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA.REGION_ID = MRT.REGION_ID
	AND     MRT.SESSION_ID = p_session_id
	AND     MRT.PARTNER_SITE_ID IS NOT NULL
	--AND     MRT.PARTNER_SITE_ID = p_customer_site_id
	AND     MRT.PARTNER_SITE_ID = decode( NVL(p_partner_type, 2), 2, p_customer_site_id , 3 ,  p_party_site_id, 4, p_order_line_id)  --2814895
	AND     MRT.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	--AND     MRT.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     (2000 + ((10 - NVL(MRT.REGION_TYPE, 0)) * 10) +
		DECODE(MRT.ZONE_FLAG, 'Y', 1, 0)) = l_min_region_value
	AND     MSRA.INVENTORY_ITEM_ID = ITEM.INVENTORY_ITEM_ID
	AND     ITEM.PLAN_ID = -1
	AND     ITEM.INVENTORY_ITEM_ID = p_inventory_item_id
	AND     ITEM.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
	AND     ITEM.SR_INSTANCE_ID = SOURCE_ORG.SR_INSTANCE_ID
	AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
	AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
	AND     MSR.STATUS = 1
	AND     MSR.SOURCING_RULE_TYPE = 1
	AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;
	return;
ELSE
-- Stopping check.
   IF l_counter = l_dist_level_type.LAST THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
   ELSE
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No sources found at level 2. Continuing search..');
	END IF;
   END IF;
END IF;


ELSIF (l_dist_level_type(l_counter) = 3) THEN

-- LEVEL3, ASSIGNMENT_TYPE 5: CATEGORY-ORG
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 3 (cat-org)');
END IF;

SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
        MSC_ITEM_CATEGORIES     CAT,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_TP_SITE_ID_LID      MTSIL
WHERE
        MSRA.ASSIGNMENT_TYPE = 5 /* CATEGORY-ORG */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.PARTNER_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID = MTSIL.TP_SITE_ID
	AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
	AND     MTSIL.SR_INSTANCE_ID = CAT.SR_INSTANCE_ID
	AND     CAT.INVENTORY_ITEM_ID = p_inventory_item_id
        AND     CAT.CATEGORY_SET_ID = MSRA.CATEGORY_SET_ID
        AND     CAT.CATEGORY_NAME = MSRA.CATEGORY_NAME
        AND     CAT.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     CAT.SR_INSTANCE_ID = SOURCE_ORG.SOURCE_ORG_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate )) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;

--Stopping check
IF (x_atp_sources.Rank.COUNT > 0) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 3. Search over.');
    END IF;
    return;
ELSE
    IF l_counter = l_dist_level_type.LAST THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
    ELSE
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No sources found at level 3. Continuing search..');
	END IF;
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 4) THEN

-- LEVEL4, ASSIGNMENT TYPE3: ITEM
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 4 (item)');
END IF;
-- Bug 2931266. No need for customer_site_id join at this level
SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
        MSC_SYSTEM_ITEMS                ITEM,
        MSC_SR_SOURCE_ORG               SOURCE_ORG,
        MSC_SR_RECEIPT_ORG              RECEIPT_ORG,
        MSC_SOURCING_RULES              MSR,
--        MSC_TRADING_PARTNER_SITES       TP,
--        MSC_TP_SITE_ID_LID              MTSIL,
        MSC_SR_ASSIGNMENTS              MSRA
WHERE
        MSRA.ASSIGNMENT_TYPE = 3 /* ITEM */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.INVENTORY_ITEM_ID = p_inventory_item_id
        AND     ITEM.INVENTORY_ITEM_ID = MSRA.INVENTORY_ITEM_ID
        AND     ITEM.PLAN_ID = -1
--        AND     ITEM.SR_INSTANCE_ID = MTSIL.SR_INSTANCE_ID
--        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
--        AND     MTSIL.TP_SITE_ID = TP.PARTNER_SITE_ID
--        AND     TP.PARTNER_TYPE = 2
        AND     ITEM.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     ITEM.SR_INSTANCE_ID = SOURCE_ORG.SR_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
        AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE ,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
	AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
	AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;

-- Check for stopping
IF (x_atp_sources.Rank.COUNT > 0) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 4. Search over.');
    END IF;
    return;
ELSE
    IF l_counter = l_dist_level_type.LAST THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
    ELSE
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No sources found at level 4. Continuing search..');
	END IF;
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 5) THEN

-- LEVEL 5, ASSIGNMENT TYPE 8: CATEGORY-REGION
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 5 (cat-reg)');
END IF;
-- Searching sources for min value of expression.
SELECT	NVL(MIN(5000 + ((10 - NVL(MRT_INNER.REGION_TYPE, 0)) * 10) + DECODE(MRT_INNER.ZONE_FLAG, 'Y', 1, 0)), 0)
INTO	l_min_region_value
FROM
	MSC_ITEM_CATEGORIES     CAT_INNER,
	MSC_SR_SOURCE_ORG       SOURCE_ORG_INNER,
	MSC_SR_RECEIPT_ORG      RECEIPT_ORG_INNER,
	MSC_SOURCING_RULES      MSR_INNER,
	MSC_SR_ASSIGNMENTS      MSRA_INNER,
	MSC_REGIONS_TEMP        MRT_INNER
WHERE
	MSRA_INNER.ASSIGNMENT_TYPE = 8 /* CATEGORY-REGION */
	AND     MSRA_INNER.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA_INNER.REGION_ID = MRT_INNER.REGION_ID
	AND     MRT_INNER.PARTNER_SITE_ID IS NOT NULL
	AND     MRT_INNER.SESSION_ID = p_session_id
	--AND     MRT_INNER.PARTNER_SITE_ID = p_customer_site_id --2814895
	AND     MRT_INNER.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT_INNER.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	--AND     MRT_INNER.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MSRA_INNER.CATEGORY_SET_ID = CAT_INNER.CATEGORY_SET_ID
	AND     MSRA_INNER.CATEGORY_NAME = CAT_INNER.CATEGORY_NAME
	AND     CAT_INNER.INVENTORY_ITEM_ID = p_inventory_item_id
	AND     CAT_INNER.ORGANIZATION_ID = SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID
	AND     CAT_INNER.SR_INSTANCE_ID = SOURCE_ORG_INNER.SR_INSTANCE_ID
	AND     SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG_INNER.SR_RECEIPT_ID = RECEIPT_ORG_INNER.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG_INNER.DISABLE_DATE,l_sysdate)) >= l_sysdate
	AND     TRUNC(RECEIPT_ORG_INNER.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG_INNER.SOURCING_RULE_ID = MSR_INNER.SOURCING_RULE_ID
	AND     MSR_INNER.STATUS = 1
	AND     MSR_INNER.SOURCING_RULE_TYPE = 1
	AND     MSR_INNER.SOURCING_RULE_ID = MSRA_INNER.SOURCING_RULE_ID;

IF (l_min_region_value <> 0) THEN
-- Sources found
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All sources found at level 5.');
        END IF;
-- Collect the found sources and return.
SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
        MSC_ITEM_CATEGORIES     CAT,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_REGIONS_TEMP        MRT
WHERE
        MSRA.ASSIGNMENT_TYPE = 8 /* CATEGORY-REGION */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.REGION_ID = MRT.REGION_ID
        AND     MRT.PARTNER_SITE_ID IS NOT NULL
        AND     MRT.SESSION_ID = p_session_id
        --AND     MRT.PARTNER_SITE_ID = p_customer_site_id
        AND     MRT.PARTNER_SITE_ID = decode( NVL(p_partner_type,2), 2, p_customer_site_id , 4, p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	--AND     MRT.PARTNER_TYPE = 2 -- For supplier intransit LT project
        AND     (5000 + ((10 - NVL(MRT.REGION_TYPE, 0)) * 10) +
		DECODE(MRT.ZONE_FLAG, 'Y', 1, 0)) = l_min_region_value
	AND     MSRA.CATEGORY_SET_ID = CAT.CATEGORY_SET_ID
	AND     MSRA.CATEGORY_NAME = CAT.CATEGORY_NAME
	AND     CAT.INVENTORY_ITEM_ID = p_inventory_item_id
        AND     CAT.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     CAT.SR_INSTANCE_ID = SOURCE_ORG.SR_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
	AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;
	return;
ELSE
-- Sources not found. Check for stopping
    IF l_counter = l_dist_level_type.LAST THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
    ELSE
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No sources found at level 5. Continuing search..');
	END IF;
    END IF;
END IF;


ELSIF (l_dist_level_type(l_counter) = 6) THEN

-- LEVEL 6, ASSIGNMENT TYPE 2: CATEGORY
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 6 (cat)');
END IF;
-- Bug 2931266. No need for customer_site_id join at this level
SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
        MSC_ITEM_CATEGORIES             CAT,
--        MSC_TRADING_PARTNER_SITES       TP,
        MSC_SR_SOURCE_ORG               SOURCE_ORG,
        MSC_SR_RECEIPT_ORG              RECEIPT_ORG,
        MSC_SOURCING_RULES              MSR,
        MSC_SR_ASSIGNMENTS              MSRA
--        MSC_TP_SITE_ID_LID              MTSIL
WHERE
        MSRA.ASSIGNMENT_TYPE = 2 /* CATEGORY */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.CATEGORY_NAME = CAT.CATEGORY_NAME
        AND     MSRA.CATEGORY_SET_ID = CAT.CATEGORY_SET_ID
        AND     CAT.INVENTORY_ITEM_ID = p_inventory_item_id
--        AND     CAT.SR_INSTANCE_ID = MTSIL.SR_INSTANCE_ID
--        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
--        AND     MTSIL.TP_SITE_ID = TP.PARTNER_SITE_ID
--        AND     TP.PARTNER_TYPE = 2
        AND     CAT.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     CAT.SR_INSTANCE_ID = SOURCE_ORG.SR_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
        AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
	AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;

-- Stopping check
IF (x_atp_sources.Rank.COUNT > 0) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 6. Search over.');
    END IF;
    return;
ELSE
    IF l_counter = l_dist_level_type.LAST THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No sources found at level 6. Continuing search..');
	END IF;
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 7) THEN

-- LEVEL 7, ASSIGNMENT_TYPE 4: ORG
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 7 (org)');
END IF;

SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
        MSC_SYSTEM_ITEMS        ITEM,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_TP_SITE_ID_LID      MTSIL
WHERE
        MSRA.ASSIGNMENT_TYPE = 4 /* ORG */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.PARTNER_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID = MTSIL.TP_SITE_ID
        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
        AND     MTSIL.SR_INSTANCE_ID = ITEM.SR_INSTANCE_ID
        AND     ITEM.INVENTORY_ITEM_ID = p_inventory_item_id
        AND     ITEM.PLAN_ID = -1
        AND     ITEM.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     ITEM.SR_INSTANCE_ID = SOURCE_ORG.SOURCE_ORG_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
        AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate )) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;

-- Stopping Check
IF (x_atp_sources.Rank.COUNT > 0) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 7. Search over.');
    END IF;
    return;
ELSE
    IF l_counter = l_dist_level_type.LAST THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
    ELSE
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No sources found at level 7. Continuing search..');
	END IF;
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 8) THEN

-- LEVEL 8, ASSIGNMENT_TYPE 7: REGION
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 8 (reg)');
END IF;
-- Searching sources for min expression value
SELECT	NVL(MIN(8000 + ((10 - NVL(MRT_INNER.REGION_TYPE, 0)) * 100) + DECODE(MRT_INNER.ZONE_FLAG, 'Y', 1, 0)), 0)
INTO	l_min_region_value
FROM
	MSC_SYSTEM_ITEMS        ITEM_INNER,
	MSC_SR_SOURCE_ORG       SOURCE_ORG_INNER,
	MSC_SR_RECEIPT_ORG      RECEIPT_ORG_INNER,
	MSC_SOURCING_RULES      MSR_INNER,
	MSC_SR_ASSIGNMENTS      MSRA_INNER,
	MSC_REGIONS_TEMP        MRT_INNER
WHERE
	MSRA_INNER.ASSIGNMENT_TYPE = 7 /* REGION */
	AND     MSRA_INNER.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA_INNER.REGION_ID = MRT_INNER.REGION_ID
	AND     MRT_INNER.SESSION_ID = p_session_id
	--AND     MRT_INNER.PARTNER_SITE_ID = p_customer_site_id
	AND     MRT_INNER.PARTNER_SITE_ID IS NOT NULL
	--AND     MRT_INNER.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MRT_INNER.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT_INNER.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	AND     MSRA_INNER.SOURCING_RULE_ID = MSR_INNER.SOURCING_RULE_ID
	AND     MSR_INNER.STATUS = 1
	AND     MSR_INNER.SOURCING_RULE_TYPE = 1
	AND     MSR_INNER.SOURCING_RULE_ID = RECEIPT_ORG_INNER.SOURCING_RULE_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG_INNER.DISABLE_DATE,l_sysdate )) >= l_sysdate
	AND     TRUNC(RECEIPT_ORG_INNER.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG_INNER.SR_RECEIPT_ID = SOURCE_ORG_INNER.SR_RECEIPT_ID
	AND     SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID = ITEM_INNER.ORGANIZATION_ID
	AND     SOURCE_ORG_INNER.SR_INSTANCE_ID = ITEM_INNER.SR_INSTANCE_ID
	AND     ITEM_INNER.INVENTORY_ITEM_ID = p_inventory_item_id
	AND     ITEM_INNER.PLAN_ID = -1	;

IF (l_min_region_value <> 0) THEN
-- Sources found
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All sources found at level 8.');
    END IF;
-- Collect the sources and return.
SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
        MSC_SYSTEM_ITEMS        ITEM,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_REGIONS_TEMP        MRT
WHERE
        MSRA.ASSIGNMENT_TYPE = 7 /* REGION */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA.REGION_ID = MRT.REGION_ID
        AND     MRT.PARTNER_SITE_ID IS NOT NULL
        AND     MRT.SESSION_ID = p_session_id
        --AND     MRT.PARTNER_SITE_ID = p_customer_site_id
	--AND     MRT.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MRT.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
        AND     (8000 + ((10 - NVL(MRT.REGION_TYPE, 0)) * 100) +
		DECODE(MRT.ZONE_FLAG, 'Y', 1, 0)) = l_min_region_value
	AND     MSRA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = RECEIPT_ORG.SOURCING_RULE_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SR_RECEIPT_ID = SOURCE_ORG.SR_RECEIPT_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID = ITEM.ORGANIZATION_ID
        AND     SOURCE_ORG.SR_INSTANCE_ID = ITEM.SR_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     ITEM.INVENTORY_ITEM_ID = p_inventory_item_id
	AND     ITEM.PLAN_ID = -1
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;
        return;
ELSE
-- No sources found. Check for stopping
    IF l_counter = l_dist_level_type.LAST THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
    ELSE
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No sources found at level 8. Continuing search..');
	END IF;
    END IF;
END IF;


ELSIF (l_dist_level_type(l_counter) = 9) THEN

-- LEVEL 9, ASSIGNMENT_TYPE 1: GLOBAL
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 9 (global)');
END IF;
-- Bug 2931266. No need for customer_site_id join at this level
SELECT
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1)      SOURCE_ORGANIZATION_ID,
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1)      SOURCE_ORG_INSTANCE_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1)           VENDOR_ID,
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1)      VENDOR_SITE_ID,
        NVL(SOURCE_ORG.RANK, -1)                        RANK,
        NVL(SOURCE_ORG.SOURCE_TYPE,
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                to_number(null), 3, 1))                 SOURCE_TYPE,
        0                                               PREFERRED,
        -1                                              LEAD_TIME,
        '@@@'                                           SHIP_METHOD,
        NULL -- For supplier intransit LT project
BULK COLLECT INTO
         x_atp_sources.Organization_Id,
         x_atp_sources.Instance_Id,
         x_atp_sources.Supplier_Id,
         x_atp_sources.Supplier_Site_Id,
         x_atp_sources.Rank,
         x_atp_sources.Source_Type,
         x_atp_sources.Preferred,
         x_atp_sources.Lead_Time,
         x_atp_sources.Ship_Method,
         x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
FROM
        MSC_SYSTEM_ITEMS                ITEM,
--        MSC_TRADING_PARTNER_SITES       TP,
        MSC_SR_SOURCE_ORG               SOURCE_ORG,
        MSC_SR_RECEIPT_ORG              RECEIPT_ORG,
        MSC_SOURCING_RULES              MSR,
        MSC_SR_ASSIGNMENTS              MSRA
--        MSC_TP_SITE_ID_LID              MTSIL
WHERE
        MSRA.ASSIGNMENT_TYPE = 1 /* GLOBAL */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = RECEIPT_ORG.SOURCING_RULE_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SR_RECEIPT_ID = SOURCE_ORG.SR_RECEIPT_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID = ITEM.ORGANIZATION_ID
        AND     SOURCE_ORG.SR_INSTANCE_ID = ITEM.SR_INSTANCE_ID
        AND     ITEM.INVENTORY_ITEM_ID = p_inventory_item_id
	AND     ITEM.PLAN_ID = -1
/*
	AND     ITEM.SR_INSTANCE_ID = MTSIL.SR_INSTANCE_ID
        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
        AND     MTSIL.TP_SITE_ID = TP.PARTNER_SITE_ID
        AND     TP.PARTNER_TYPE = 2
*/
ORDER BY
        SOURCE_ORG.RANK ASC, SOURCE_ORG.ALLOCATION_PERCENT DESC;

-- Stopping Check
IF (x_atp_sources.Rank.COUNT > 0) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 9. Search over.');
    END IF;
    return;
ELSE
    IF l_counter = l_dist_level_type.LAST THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Could not find sources for the item in the entire search');
	END IF;
	x_return_status := FND_API.G_RET_STS_ERROR;
	return;
    END IF;
END IF;

END IF; -- l_dist_level_type

END LOOP; -- Loop on levels

ELSE -- of case1
-- case2 begins

IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Starting search for ship set sources');
END IF;

-- Delete the table MSC_ATP_SOURCES_TEMP
DELETE MSC_ATP_SOURCES_TEMP;

FOR l_counter IN l_dist_level_type.FIRST..l_dist_level_type.LAST LOOP

IF (l_dist_level_type(l_counter) = 1) THEN

-- LEVEL 1, ASSIGNMENT TYPE 6: ITEM-ORG
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 1 (item-org)');
END IF;

-- At first level, visited_flag in table msc_ship_set_temp is 0 for all rows.
-- Therefore no need for clause 'AND msst.visisble_flag = 0'.

-- Find and insert the sources in msc_atp_sources_temp
INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_SYSTEM_ITEMS                        ITEM,
        MSC_SR_SOURCE_ORG                       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG                      RECEIPT_ORG,
        MSC_SOURCING_RULES                      MSR,
        MSC_SR_ASSIGNMENTS                      MSRA,
        MSC_TP_SITE_ID_LID                      MTSIL,
        MSC_SHIP_SET_TEMP                       MSST
WHERE
        MSRA.ASSIGNMENT_TYPE = 6 /* ITEM-ORG */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.PARTNER_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID = MTSIL.TP_SITE_ID
        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
        AND     MTSIL.SR_INSTANCE_ID = ITEM.SR_INSTANCE_ID
        AND     ITEM.INVENTORY_ITEM_ID = MSRA.INVENTORY_ITEM_ID
        AND     ITEM.PLAN_ID = -1
        AND     ITEM.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
        AND     ITEM.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     ITEM.SR_INSTANCE_ID = SOURCE_ORG.SOURCE_ORG_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;

l_inserted_rows	:= SQL%ROWCOUNT;

IF (l_inserted_rows > 0) THEN

    -- Found some sources for some items.
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Found some sources for some ship set items at level 1');
    END IF;


    -- Mark all the items for which sources are/have been found.
    UPDATE	msc_ship_set_temp
    set		visited_flag = 1
    where	inventory_item_id in (select inventory_item_id from msc_atp_sources_temp);

    l_updated_rows := SQL%ROWCOUNT;

    -- Check if all the items in ship set are processed.
    IF (l_updated_rows = p_ship_set_item_count) THEN

	-- Find the common sources from the pool of sources in msc_atp_sources_temp
	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),  -- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank, order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5; -- order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		-- Common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All common sources for ship set found at level 1');
		END IF;
		return;
	ELSE
		-- No common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for all the ship set items.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF; -- common sources

     END IF; -- all items of ship set
END IF; -- some sources found

-- Check the stopping condition.
IF l_counter = l_dist_level_type.LAST THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All items in ship set could not be found in the entire search.');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     return;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Some more search left. Continuing');
    END IF;
END IF;


ELSIF (l_dist_level_type(l_counter) = 2) THEN

-- LEVEL 2, ASSIGNMENT TYPE 9: ITEM-REGION
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 2 (item-reg)');
END IF;

-- Find sources for min value of expression.
SELECT
	MSST_INNER.INVENTORY_ITEM_ID,
	MIN(2000 + ((10 - NVL(MRT_INNER.REGION_TYPE, 0)) * 10) + DECODE(MRT_INNER.ZONE_FLAG, 'Y', 1, 0))
BULK COLLECT INTO
	l_inventory_item_id_arr,
	l_min_region_value_arr
FROM
	MSC_SYSTEM_ITEMS        ITEM_INNER,
	MSC_SR_SOURCE_ORG       SOURCE_ORG_INNER,
	MSC_SR_RECEIPT_ORG      RECEIPT_ORG_INNER,
	MSC_SOURCING_RULES      MSR_INNER,
	MSC_SR_ASSIGNMENTS      MSRA_INNER,
	MSC_REGIONS_TEMP        MRT_INNER,
	MSC_SHIP_SET_TEMP       MSST_INNER
WHERE
	MSRA_INNER.ASSIGNMENT_TYPE = 9
	AND     MSRA_INNER.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA_INNER.REGION_ID = MRT_INNER.REGION_ID
	AND     MRT_INNER.PARTNER_SITE_ID IS NOT NULL
	--AND     MRT_INNER.PARTNER_SITE_ID = p_customer_site_id
	--AND     MRT_INNER.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MRT_INNER.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT_INNER.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	AND     MRT_INNER.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MSRA_INNER.INVENTORY_ITEM_ID = ITEM_INNER.INVENTORY_ITEM_ID
	AND     ITEM_INNER.PLAN_ID = -1
	AND     ITEM_INNER.INVENTORY_ITEM_ID = MSST_INNER.INVENTORY_ITEM_ID
	AND	MSST_INNER.VISITED_FLAG = 0
	AND     ITEM_INNER.ORGANIZATION_ID = SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID
	AND     ITEM_INNER.SR_INSTANCE_ID = SOURCE_ORG_INNER.SR_INSTANCE_ID
	AND     SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG_INNER.SR_RECEIPT_ID = RECEIPT_ORG_INNER.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG_INNER.DISABLE_DATE,l_sysdate)) >= l_sysdate
	AND     TRUNC(RECEIPT_ORG_INNER.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG_INNER.SOURCING_RULE_ID = MSR_INNER.SOURCING_RULE_ID
	AND     MSR_INNER.STATUS = 1
	AND     MSR_INNER.SOURCING_RULE_TYPE = 1
	AND     MSR_INNER.SOURCING_RULE_ID = MSRA_INNER.SOURCING_RULE_ID
GROUP BY
	MSST_INNER.INVENTORY_ITEM_ID;

IF (l_inventory_item_id_arr.COUNT > 0) THEN

-- Step1: All the items for which sources are found,
-- update column min_region_value and visited_flag in msc_ship_set_temp.
IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'For following items, the min region value found');
    FOR i IN 1..l_inventory_item_id_arr.COUNT LOOP
      msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Item: '|| l_inventory_item_id_arr(i)
			|| ' min region value: ' || l_min_region_value_arr(i));
    END LOOP;
END IF;


FORALL	i IN l_inventory_item_id_arr.FIRST..l_inventory_item_id_arr.LAST
UPDATE	msc_ship_set_temp
SET	min_region_value = l_min_region_value_arr(i),
	visited_flag = 1
WHERE	inventory_item_id = l_inventory_item_id_arr(i);

-- Step2: For the updated items find all the sources and store them in msc_atp_sources_temp
-- This is done by adding clause AND (expr) = msst.min_region_value
-- and removing the clause AND visited_flag = 0

INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_SYSTEM_ITEMS        ITEM,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_REGIONS_TEMP        MRT,
        MSC_SHIP_SET_TEMP       MSST
WHERE
	MSRA.ASSIGNMENT_TYPE = 9
	AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA.REGION_ID = MRT.REGION_ID
	AND     MRT.SESSION_ID = p_session_id
	AND     MRT.PARTNER_SITE_ID IS NOT NULL
	--AND     MRT.PARTNER_SITE_ID = p_customer_site_id
	--AND     MRT.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MRT.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	AND     (2000 + ((10 - NVL(MRT.REGION_TYPE, 0)) * 10) +
		DECODE(MRT.ZONE_FLAG, 'Y', 1, 0)) = MSST.MIN_REGION_VALUE
	AND     MSRA.INVENTORY_ITEM_ID = ITEM.INVENTORY_ITEM_ID
	AND     ITEM.PLAN_ID = -1
	AND     ITEM.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
	AND     ITEM.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
	AND     ITEM.SR_INSTANCE_ID = SOURCE_ORG.SR_INSTANCE_ID
	AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate )) >= l_sysdate
	AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
	AND     MSR.STATUS = 1
	AND     MSR.SOURCING_RULE_TYPE = 1
	AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;

-- Step3: Check if I need to stop here.

SELECT	COUNT(*)
INTO	l_items_visited
FROM	MSC_SHIP_SET_TEMP
WHERE	VISITED_FLAG = 1;

IF (l_items_visited = p_ship_set_item_count) THEN
-- We have to stop search and return from here. But before returning,
-- We need to check whether the search was fruitful or not
-- If search was fruitful set return_status to SUCCESS else FAILURE

	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),  -- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank,  order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5;  -- Rank;  order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 2. Search over.');
		END IF;
		return;
	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for the ship set.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF;

END IF; -- All items in ship set

END IF; -- some sources found

-- Check the stopping condition.
IF l_counter = l_dist_level_type.LAST THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All items in ship set could not be found in the entire search.');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     return;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Some more search left. Continuing');
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 3) THEN

-- LEVEL3, ASSIGNMENT_TYPE 5: CATEGORY-ORG

IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 3 (cat-org)');
END IF;

-- Find and insert the sources in msc_atp_sources_temp
INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_ITEM_CATEGORIES     CAT,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_TP_SITE_ID_LID      MTSIL,
        MSC_SHIP_SET_TEMP       MSST
WHERE
        MSRA.ASSIGNMENT_TYPE = 5 /* CATEGORY-ORG */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.PARTNER_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID = MTSIL.TP_SITE_ID
	AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
	AND     MTSIL.SR_INSTANCE_ID = CAT.SR_INSTANCE_ID
	AND     CAT.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
        AND     MSST.VISITED_FLAG = 0
        AND     CAT.CATEGORY_SET_ID = MSRA.CATEGORY_SET_ID
        AND     CAT.CATEGORY_NAME = MSRA.CATEGORY_NAME
        AND     CAT.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     CAT.SR_INSTANCE_ID = SOURCE_ORG.SOURCE_ORG_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate )) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;

l_inserted_rows	:= SQL%ROWCOUNT;

IF (l_inserted_rows > 0) THEN

    -- Found some sources for some items.
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Found some sources for some ship set items at level 3');
    END IF;

    -- Mark all the items for which sources are/have been found.
    UPDATE	msc_ship_set_temp
    set		visited_flag = 1
    where	inventory_item_id in (select inventory_item_id from msc_atp_sources_temp);

    l_updated_rows := SQL%ROWCOUNT;

    -- Check if all the items in ship set are processed.
    IF (l_updated_rows = p_ship_set_item_count) THEN

	-- Find the common sources from the pool of sources in msc_atp_sources_temp
	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),  -- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank, order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5; -- Rank; order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		-- Common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All common sources for ship set found at level 3');
		END IF;
		return;
	ELSE
		-- No common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for all the ship set items.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF; -- common sources

     END IF; -- all items of ship set
END IF; -- some sources found

-- Check the stopping condition.
IF l_counter = l_dist_level_type.LAST THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All items in ship set could not be found in the entire search.');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     return;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Some more search left. Continuing');
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 4) THEN

-- LEVEL4, ASSIGNMENT TYPE3: ITEM
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 4 (item)');
END IF;
-- Bug 2931266. No need for customer_site_id join at this level
INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_SYSTEM_ITEMS                ITEM,
--        MSC_TRADING_PARTNER_SITES       TP,
        MSC_SR_SOURCE_ORG               SOURCE_ORG,
        MSC_SR_RECEIPT_ORG              RECEIPT_ORG,
        MSC_SOURCING_RULES              MSR,
        MSC_SR_ASSIGNMENTS              MSRA,
--        MSC_TP_SITE_ID_LID              MTSIL,
        MSC_SHIP_SET_TEMP               MSST
WHERE

        MSRA.ASSIGNMENT_TYPE = 3 /* ITEM */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
	AND	MSST.VISITED_FLAG = 0
	AND     ITEM.INVENTORY_ITEM_ID = MSRA.INVENTORY_ITEM_ID
	AND     ITEM.PLAN_ID = -1
--	AND     ITEM.SR_INSTANCE_ID = MTSIL.SR_INSTANCE_ID
--        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
--        AND     MTSIL.TP_SITE_ID = TP.PARTNER_SITE_ID
--        AND     TP.PARTNER_TYPE = 2
        AND     ITEM.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     ITEM.SR_INSTANCE_ID = SOURCE_ORG.SR_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
        AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE ,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
	AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
	AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;
l_inserted_rows	:= SQL%ROWCOUNT;

IF (l_inserted_rows > 0) THEN

    -- Found some sources for some items.
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Found some sources for some ship set items at level 4');
    END IF;

    -- Mark all the items for which sources are/have been found.
    UPDATE	msc_ship_set_temp
    set		visited_flag = 1
    where	inventory_item_id in (select distinct(inventory_item_id) from msc_atp_sources_temp);

    l_updated_rows := SQL%ROWCOUNT;

    -- Check if all the items in ship set are processed.
    IF (l_updated_rows = p_ship_set_item_count) THEN

	-- Find the common sources from the pool of sources in msc_atp_sources_temp
	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),  -- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank,  order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5; -- Rank; order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		-- Common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
		    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All common sources for ship set found at level 4');
		END IF;
		return;
	ELSE
		-- No common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for all the ship set items.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF; -- common sources

     END IF; -- all items of ship set
END IF; -- some sources found

-- Check the stopping condition.
IF l_counter = l_dist_level_type.LAST THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All items in ship set could not be found in the entire search.');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     return;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Some more search left. Continuing');
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 5) THEN

-- LEVEL 5, ASSIGNMENT TYPE 8: CATEGORY-REGION
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 5 (cat-reg)');
END IF;

SELECT
	MSST_INNER.INVENTORY_ITEM_ID,
	MIN(5000 + ((10 - NVL(MRT_INNER.REGION_TYPE, 0)) * 10) + DECODE(MRT_INNER.ZONE_FLAG, 'Y', 1, 0))
BULK COLLECT INTO
	l_inventory_item_id_arr,
	l_min_region_value_arr
FROM
	MSC_ITEM_CATEGORIES     CAT_INNER,
	MSC_SR_SOURCE_ORG       SOURCE_ORG_INNER,
	MSC_SR_RECEIPT_ORG      RECEIPT_ORG_INNER,
	MSC_SOURCING_RULES      MSR_INNER,
	MSC_SR_ASSIGNMENTS      MSRA_INNER,
	MSC_REGIONS_TEMP        MRT_INNER,
	MSC_SHIP_SET_TEMP       MSST_INNER
WHERE

	MSRA_INNER.ASSIGNMENT_TYPE = 8 /* CATEGORY-REGION */
	AND     MSRA_INNER.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA_INNER.REGION_ID = MRT_INNER.REGION_ID
	AND     MRT_INNER.PARTNER_SITE_ID IS NOT NULL
	AND     MRT_INNER.SESSION_ID = p_session_id
	--AND     MRT_INNER.PARTNER_SITE_ID = p_customer_site_id
	--AND     MRT_INNER.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MRT_INNER.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT_INNER.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	AND     MSRA_INNER.CATEGORY_SET_ID = CAT_INNER.CATEGORY_SET_ID
	AND     MSRA_INNER.CATEGORY_NAME = CAT_INNER.CATEGORY_NAME
	AND     CAT_INNER.INVENTORY_ITEM_ID = MSST_INNER.INVENTORY_ITEM_ID
	AND	MSST_INNER.VISITED_FLAG = 0
	AND     CAT_INNER.ORGANIZATION_ID = SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID
	AND     CAT_INNER.SR_INSTANCE_ID = SOURCE_ORG_INNER.SR_INSTANCE_ID
	AND     SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG_INNER.SR_RECEIPT_ID = RECEIPT_ORG_INNER.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG_INNER.DISABLE_DATE,l_sysdate)) >= l_sysdate
	AND     TRUNC(RECEIPT_ORG_INNER.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG_INNER.SOURCING_RULE_ID = MSR_INNER.SOURCING_RULE_ID
	AND     MSR_INNER.STATUS = 1
	AND     MSR_INNER.SOURCING_RULE_TYPE = 1
	AND     MSR_INNER.SOURCING_RULE_ID = MSRA_INNER.SOURCING_RULE_ID
GROUP BY	MSST_INNER.INVENTORY_ITEM_ID;

IF (l_inventory_item_id_arr.COUNT > 0) THEN

-- Step1: For all the items found, update column min_region_value in msc_ship_set_temp.
-- Also update the column visited_flag
IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'For following items, the min region value found');
    FOR i IN 1..l_inventory_item_id_arr.COUNT LOOP
      msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Item: '|| l_inventory_item_id_arr(i)
			|| ' min region value: ' || l_min_region_value_arr(i));
    END LOOP;
END IF;

FORALL	i IN l_inventory_item_id_arr.FIRST..l_inventory_item_id_arr.LAST
UPDATE	msc_ship_set_temp
SET		min_region_value = l_min_region_value_arr(i),
		visited_flag = 1
WHERE	inventory_item_id = l_inventory_item_id_arr(i);

-- Step2: For the updated items find all the sources and store them in msc_atp_sources_temp
-- This is done by adding clause AND (expr) = msst.min_region_value
-- and removing the clause AND visited_flag = 0

INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_ITEM_CATEGORIES     CAT,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_REGIONS_TEMP        MRT,
        MSC_SHIP_SET_TEMP       MSST
WHERE

        MSRA.ASSIGNMENT_TYPE = 8 /* CATEGORY-REGION */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.REGION_ID = MRT.REGION_ID
        AND     MRT.PARTNER_SITE_ID IS NOT NULL
        AND     MRT.SESSION_ID = p_session_id
        --AND     MRT.PARTNER_SITE_ID = p_customer_site_id
	--AND     MRT.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MRT.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
        AND     (5000 + ((10 - NVL(MRT.REGION_TYPE, 0)) * 10) +
		DECODE(MRT.ZONE_FLAG, 'Y', 1, 0)) = MSST.MIN_REGION_VALUE
	AND     MSRA.CATEGORY_SET_ID = CAT.CATEGORY_SET_ID
	AND     MSRA.CATEGORY_NAME = CAT.CATEGORY_NAME
	AND     CAT.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
        AND     CAT.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     CAT.SR_INSTANCE_ID = SOURCE_ORG.SR_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
	AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;

-- Step3: Check if I need to stop here.

SELECT	COUNT(*)
INTO	l_items_visited
FROM	MSC_SHIP_SET_TEMP
WHERE	VISITED_FLAG = 1;

IF (l_items_visited = p_ship_set_item_count) THEN
	-- We have to stop search and return from here. But before returning,
	-- We need to check whether the search was fruitful or not
	-- If search was fruitful set return_status to SUCCESS else FAILURE

	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),  -- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank,  order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5; -- Rank;order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 5. Search over.');
		END IF;
		return;
	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for the ship set.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF;

END IF; -- All items in ship set

END IF; -- some sources found

ELSIF (l_dist_level_type(l_counter) = 6) THEN

-- LEVEL 6, ASSIGNMENT TYPE 2: CATEGORY
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 6 (cat)');
END IF;
-- Bug 2931266. No need for customer_site_id join at this level
INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_ITEM_CATEGORIES             CAT,
--        MSC_TRADING_PARTNER_SITES       TP,
        MSC_SR_SOURCE_ORG               SOURCE_ORG,
        MSC_SR_RECEIPT_ORG              RECEIPT_ORG,
        MSC_SOURCING_RULES              MSR,
        MSC_SR_ASSIGNMENTS              MSRA,
--        MSC_TP_SITE_ID_LID              MTSIL,
        MSC_SHIP_SET_TEMP               MSST
WHERE

        MSRA.ASSIGNMENT_TYPE = 2 /* CATEGORY */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.CATEGORY_NAME = CAT.CATEGORY_NAME
        AND     MSRA.CATEGORY_SET_ID = CAT.CATEGORY_SET_ID
        AND     CAT.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
	AND	MSST.VISITED_FLAG = 0
--        AND     CAT.SR_INSTANCE_ID = MTSIL.SR_INSTANCE_ID
--        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
--        AND     MTSIL.TP_SITE_ID = TP.PARTNER_SITE_ID
--        AND     TP.PARTNER_TYPE = 2
        AND     CAT.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     CAT.SR_INSTANCE_ID = SOURCE_ORG.SR_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
        AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
	AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;

l_inserted_rows	:= SQL%ROWCOUNT;

IF (l_inserted_rows > 0) THEN

    -- Found some sources for some items.
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Found some sources for some ship set items at level 6');
    END IF;

    -- Mark all the items for which sources are/have been found.
    UPDATE	msc_ship_set_temp
    set		visited_flag = 1
    where	inventory_item_id in (select inventory_item_id from msc_atp_sources_temp);

    l_updated_rows := SQL%ROWCOUNT;

    -- Check if all the items in ship set are processed.
    IF (l_updated_rows = p_ship_set_item_count) THEN

	-- Find the common sources from the pool of sources in msc_atp_sources_temp
	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),  -- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank,  order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5; -- Rank;  order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		-- Common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
   		   msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All common sources for ship set found at level 6');
		END IF;
		return;
	ELSE
		-- No common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for all the ship set items.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF; -- common sources

     END IF; -- all items of ship set
END IF; -- some sources found

-- Check the stopping condition.
IF l_counter = l_dist_level_type.LAST THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All items in ship set could not be found in the entire search.');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     return;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Some more search left. Continuing');
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 7) THEN

-- LEVEL 7, ASSIGNMENT_TYPE 4: ORG
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 7 (org)');
END IF;

INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_SYSTEM_ITEMS        ITEM,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_TP_SITE_ID_LID      MTSIL,
        MSC_SHIP_SET_TEMP       MSST
WHERE
        MSRA.ASSIGNMENT_TYPE = 4 /* ORG */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.PARTNER_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID IS NOT NULL
        AND     MSRA.SHIP_TO_SITE_ID = MTSIL.TP_SITE_ID
        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
        AND     MTSIL.SR_INSTANCE_ID = ITEM.SR_INSTANCE_ID
        AND     ITEM.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
	AND	MSST.VISITED_FLAG = 0
        AND     ITEM.PLAN_ID = -1
        AND     ITEM.ORGANIZATION_ID = SOURCE_ORG.SOURCE_ORGANIZATION_ID
        AND     ITEM.SR_INSTANCE_ID = SOURCE_ORG.SOURCE_ORG_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
        AND     SOURCE_ORG.SR_RECEIPT_ID = RECEIPT_ORG.SR_RECEIPT_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate )) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = MSRA.SOURCING_RULE_ID
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;

l_inserted_rows	:= SQL%ROWCOUNT;

IF (l_inserted_rows > 0) THEN

    -- Found some sources for some items.
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Found some sources for some ship set items at level 7');
    END IF;

    -- Mark all the items for which sources are/have been found.
    UPDATE	msc_ship_set_temp
    set		visited_flag = 1
    where	inventory_item_id in (select inventory_item_id from msc_atp_sources_temp);

    l_updated_rows := SQL%ROWCOUNT;

    -- Check if all the items in ship set are processed.
    IF (l_updated_rows = p_ship_set_item_count) THEN

	-- Find the common sources from the pool of sources in msc_atp_sources_temp
	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),  -- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank,  order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5; -- Rank; order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		-- Common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
		    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All common sources for ship set found at level 7');
		END IF;
		return;
	ELSE
		-- No common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for all the ship set items.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF; -- common sources

     END IF; -- all items of ship set
END IF; -- some sources found

-- Check the stopping condition.
IF l_counter = l_dist_level_type.LAST THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All items in ship set could not be found in the entire search.');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     return;
ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Some more search left. Continuing');
    END IF;
END IF;

ELSIF (l_dist_level_type(l_counter) = 8) THEN

-- LEVEL 8, ASSIGNMENT_TYPE 7: REGION
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 8 (reg)');
END IF;

SELECT
	MSST_INNER.INVENTORY_ITEM_ID,
	MIN(8000 + ((10 - NVL(MRT_INNER.REGION_TYPE, 0)) * 100) + DECODE(MRT_INNER.ZONE_FLAG, 'Y', 1, 0))
BULK COLLECT INTO
	l_inventory_item_id_arr,
	l_min_region_value_arr
FROM
	MSC_SYSTEM_ITEMS        ITEM_INNER,
	MSC_SR_SOURCE_ORG       SOURCE_ORG_INNER,
	MSC_SR_RECEIPT_ORG      RECEIPT_ORG_INNER,
	MSC_SOURCING_RULES      MSR_INNER,
	MSC_SR_ASSIGNMENTS      MSRA_INNER,
	MSC_REGIONS_TEMP        MRT_INNER,
	MSC_SHIP_SET_TEMP       MSST_INNER
WHERE
	MSRA_INNER.ASSIGNMENT_TYPE = 7 /* REGION */
	AND     MSRA_INNER.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA_INNER.REGION_ID = MRT_INNER.REGION_ID
	AND     MRT_INNER.SESSION_ID = p_session_id
	--AND     MRT_INNER.PARTNER_SITE_ID = p_customer_site_id
	AND     MRT_INNER.PARTNER_SITE_ID IS NOT NULL
	AND     MRT_INNER.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT_INNER.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
	--AND     MRT_INNER.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MSRA_INNER.SOURCING_RULE_ID = MSR_INNER.SOURCING_RULE_ID
	AND     MSR_INNER.STATUS = 1
	AND     MSR_INNER.SOURCING_RULE_TYPE = 1
	AND     MSR_INNER.SOURCING_RULE_ID = RECEIPT_ORG_INNER.SOURCING_RULE_ID
	-- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
	AND     TRUNC(NVL(RECEIPT_ORG_INNER.DISABLE_DATE,l_sysdate)) >= l_sysdate
	AND     TRUNC(RECEIPT_ORG_INNER.EFFECTIVE_DATE) <= l_sysdate
	AND     RECEIPT_ORG_INNER.SR_RECEIPT_ID = SOURCE_ORG_INNER.SR_RECEIPT_ID
	AND     SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     SOURCE_ORG_INNER.SOURCE_ORGANIZATION_ID = ITEM_INNER.ORGANIZATION_ID
	AND     SOURCE_ORG_INNER.SR_INSTANCE_ID = ITEM_INNER.SR_INSTANCE_ID
	AND     ITEM_INNER.PLAN_ID = -1
	AND     ITEM_INNER.INVENTORY_ITEM_ID = MSST_INNER.INVENTORY_ITEM_ID
	AND	MSST_INNER.VISITED_FLAG = 0
GROUP BY MSST_INNER.INVENTORY_ITEM_ID;

IF (l_inventory_item_id_arr.COUNT > 0) THEN

-- Step1: For all the items found, update column min_region_value in msc_ship_set_temp.
-- Also update the column visited_flag
IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'For following items, the min region value found');
    FOR i IN 1..l_inventory_item_id_arr.COUNT LOOP
      msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Item: '|| l_inventory_item_id_arr(i)
			|| ' min region value: ' || l_min_region_value_arr(i));
    END LOOP;
END IF;

FORALL	i IN l_inventory_item_id_arr.FIRST..l_inventory_item_id_arr.LAST
UPDATE	msc_ship_set_temp
SET		min_region_value = l_min_region_value_arr(i),
		visited_flag = 1
WHERE	inventory_item_id = l_inventory_item_id_arr(i);

-- Step2: For the updated items find all the sources and store them in msc_atp_sources_temp
-- This is done by adding clause AND (expr) = msst.min_region_value
-- and removing the clause AND visited_flag = 0

INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_SYSTEM_ITEMS        ITEM,
        MSC_SR_SOURCE_ORG       SOURCE_ORG,
        MSC_SR_RECEIPT_ORG      RECEIPT_ORG,
        MSC_SOURCING_RULES      MSR,
        MSC_SR_ASSIGNMENTS      MSRA,
        MSC_REGIONS_TEMP        MRT,
        MSC_SHIP_SET_TEMP       MSST
WHERE

        MSRA.ASSIGNMENT_TYPE = 7 /* REGION */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
	AND     MSRA.REGION_ID = MRT.REGION_ID
        AND     MRT.PARTNER_SITE_ID IS NOT NULL
        AND     MRT.SESSION_ID = p_session_id
        --AND     MRT.PARTNER_SITE_ID = p_customer_site_id
	--AND     MRT.PARTNER_TYPE = 2 -- For supplier intransit LT project
	AND     MRT.PARTNER_SITE_ID = decode(NVL(p_partner_type,2), 2, p_customer_site_id , 4 ,  p_party_site_id, 5, p_order_line_id)  --2814895
	AND     MRT.PARTNER_TYPE  = NVL(p_partner_type,2) --2814895
        AND     (8000 + ((10 - NVL(MRT.REGION_TYPE, 0)) * 100) +
		DECODE(MRT.ZONE_FLAG, 'Y', 1, 0)) = MSST.MIN_REGION_VALUE
	AND     MSRA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = RECEIPT_ORG.SOURCING_RULE_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SR_RECEIPT_ID = SOURCE_ORG.SR_RECEIPT_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID = ITEM.ORGANIZATION_ID
        AND     SOURCE_ORG.SR_INSTANCE_ID = ITEM.SR_INSTANCE_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
	AND     ITEM.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
	AND     ITEM.PLAN_ID = -1
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;

-- Step3: Check if I need to stop here.

SELECT	COUNT(*)
INTO	l_items_visited
FROM	MSC_SHIP_SET_TEMP
WHERE	VISITED_FLAG = 1;

IF (l_items_visited = p_ship_set_item_count) THEN
	-- We have to stop search and return from here. But before returning,
	-- We need to check whether the search was fruitful or not
	-- If search was fruitful set return_status to SUCCESS else FAILURE

	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),  -- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank, order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5; -- Rank;  order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Sources found at level 8. Search over.');
		END IF;
		return;
	ELSE
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for the ship set.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF;

END IF; -- All items in ship set

END IF; -- some sources found

ELSIF (l_dist_level_type(l_counter) = 9) THEN

-- LEVEL 9, ASSIGNMENT_TYPE 1: GLOBAL
IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Searching sources at level 9 (global)');
END IF;
-- Bug 2931266. No need for customer_site_id join at this level
INSERT INTO MSC_ATP_SOURCES_TEMP (inventory_item_id, Organization_Id, Instance_Id,
        Supplier_Id, Supplier_Site_Id, Rank, Source_Type, Preferred, Lead_Time, Ship_Method)
SELECT
        MSST.INVENTORY_ITEM_ID,
        NVL(SOURCE_ORG.SOURCE_ORGANIZATION_ID, -1),
        NVL(SOURCE_ORG.SOURCE_ORG_INSTANCE_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_ID, -1),
        NVL(SOURCE_ORG.SOURCE_PARTNER_SITE_ID, -1),
        SUM(NVL(SOURCE_ORG.RANK, 0) + 1 - SOURCE_ORG.ALLOCATION_PERCENT/1000), --2910418
        NVL(MIN(SOURCE_ORG.SOURCE_TYPE),
                DECODE(SOURCE_ORG.SOURCE_ORGANIZATION_ID,
                        to_number(null), 3, 1)),
        0,
        -1,
        '@@@'
FROM
        MSC_SYSTEM_ITEMS                ITEM,
--        MSC_TRADING_PARTNER_SITES       TP,
        MSC_SR_SOURCE_ORG               SOURCE_ORG,
        MSC_SR_RECEIPT_ORG              RECEIPT_ORG,
        MSC_SOURCING_RULES              MSR,
        MSC_SR_ASSIGNMENTS              MSRA,
--        MSC_TP_SITE_ID_LID              MTSIL,
        MSC_SHIP_SET_TEMP               MSST
WHERE
        MSRA.ASSIGNMENT_TYPE = 1 /* GLOBAL */
        AND     MSRA.ASSIGNMENT_SET_ID = p_assignment_set_id
        AND     MSRA.SOURCING_RULE_ID = MSR.SOURCING_RULE_ID
        AND     MSR.STATUS = 1
        AND     MSR.SOURCING_RULE_TYPE = 1
        AND     MSR.SOURCING_RULE_ID = RECEIPT_ORG.SOURCING_RULE_ID
        -- Bug 3787821: Changes for making the condition vaild if Sysdate = Disable_date
        AND     TRUNC(NVL(RECEIPT_ORG.DISABLE_DATE,l_sysdate)) >= l_sysdate
        AND     TRUNC(RECEIPT_ORG.EFFECTIVE_DATE) <= l_sysdate
        AND     RECEIPT_ORG.SR_RECEIPT_ID = SOURCE_ORG.SR_RECEIPT_ID
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID IS NOT NULL
        AND     SOURCE_ORG.SOURCE_ORGANIZATION_ID = ITEM.ORGANIZATION_ID
        AND     SOURCE_ORG.SR_INSTANCE_ID = ITEM.SR_INSTANCE_ID
	AND     ITEM.PLAN_ID = -1
        AND     ITEM.INVENTORY_ITEM_ID = MSST.INVENTORY_ITEM_ID
	AND	MSST.VISITED_FLAG = 0
--        AND     ITEM.SR_INSTANCE_ID = MTSIL.SR_INSTANCE_ID
--        AND     MTSIL.SR_TP_SITE_ID = p_customer_site_id
--        AND     MTSIL.TP_SITE_ID = TP.PARTNER_SITE_ID
--        AND     TP.PARTNER_TYPE = 2
GROUP BY
        MSST.INVENTORY_ITEM_ID,
        SOURCE_ORG.SOURCE_ORGANIZATION_ID,
        SOURCE_ORG.SOURCE_ORG_INSTANCE_ID,
        SOURCE_ORG.SOURCE_PARTNER_ID,
        SOURCE_ORG.SOURCE_PARTNER_SITE_ID;


l_inserted_rows	:= SQL%ROWCOUNT;

IF (l_inserted_rows > 0) THEN

    -- Found some sources for some items.
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'Found some sources for some ship set items at level 9');
    END IF;

    -- Mark all the items for which sources are/have been found.
    UPDATE	msc_ship_set_temp
    set		visited_flag = 1
    where	inventory_item_id in (select inventory_item_id from msc_atp_sources_temp);

    l_updated_rows := SQL%ROWCOUNT;

    -- Check if all the items in ship set are processed.
    IF (l_updated_rows = p_ship_set_item_count) THEN

	-- Find the common sources from the pool of sources in msc_atp_sources_temp
	SELECT  Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		sum(Rank),	-- order by cum rank instead of group by rank
		Source_Type,
		0,
		-1,
		'@@@',
		NULL -- For supplier intransit LT project
	BULK COLLECT INTO
		x_atp_sources.Organization_Id,
		x_atp_sources.Instance_Id,
		x_atp_sources.Supplier_Id,
		x_atp_sources.Supplier_Site_Id,
		x_atp_sources.Rank,
		x_atp_sources.Source_Type,
		x_atp_sources.Preferred,
		x_atp_sources.Lead_Time,
		x_atp_sources.Ship_Method,
                x_atp_sources.Sup_Cap_Type -- For supplier intransit LT project
	FROM    MSC_ATP_SOURCES_TEMP
	GROUP BY
		Organization_Id,
		Instance_Id,
		Supplier_Id,
		Supplier_Site_Id,
		-- Rank,	order by cum rank instead of group by rank
		Source_Type
	HAVING  count(*) = p_ship_set_item_count
	ORDER BY 5; --Rank;	order by cum rank instead of group by rank

	IF (x_atp_sources.Rank.COUNT > 0) THEN
		-- Common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All common sources for ship set found at level 9');
		END IF;
		return;
	ELSE
		-- No common sources found
		IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'No common sources for all the ship set items.');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF; -- common sources

     END IF; -- all items of ship set
END IF; -- some sources found

-- Check the stopping condition.
IF l_counter = l_dist_level_type.LAST THEN
    IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('Get_Sources_Info: '|| 'All items in ship set could not be found in the entire search.');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     return;
END IF;

END IF; -- l_dist_level_type

END LOOP;

END IF; -- case2

IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('End of Get_Sources Info procedure');
END IF;
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;

END Get_Sources_Info;

--------------------------------------------------
--        Set processing procedures             --
--------------------------------------------------

PROCEDURE Initialize_Set_Processing (
   p_set        IN      MRP_ATP_PUB.ATP_Rec_Typ,
   p_start      IN      NUMBER
) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Begin Initialize_Set_Processing');
   END IF;
   -- 2834932
   G_set_nonoverride_flag := 'N';
   G_set_override_flag := 'N';
   G_set_status := MSC_ATP_PVT.ALLSUCCESS;
   G_is_ship_set := p_set.ship_set_name(p_start) is not null;
   G_override_date := null;
   G_ship_LAD_set  := null;
   G_arr_LAD_set   := null;
   G_ship_EAD_set  := null;
   G_latest_ship_date_set := null;
   G_latest_arr_date_set  := null;
END Initialize_Set_Processing;

PROCEDURE Process_Set_Line(
   p_set         IN OUT NOCOPY   MRP_ATP_PUB.ATP_Rec_Typ,
   i             IN              NUMBER,
   x_line_status OUT NOCOPY      NUMBER
) IS
   l_request_date_ln             DATE;
   l_ship_LAD_ln                 DATE;
   l_arr_LAD_ln                  DATE;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('********** Begin Process_Set_Line **********');
   END IF;

   x_line_status := NVL(p_set.error_code(i), MSC_ATP_PVT.ALLSUCCESS);

   IF p_set.requested_ship_date(i) is NOT null THEN
      l_request_date_ln := p_set.requested_ship_date(i);
   ELSE
      l_request_date_ln := p_set.requested_arrival_date(i);
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('l_request_date_ln: ' || l_request_date_ln);
      msc_sch_wb.atp_debug('Input error code: ' || x_line_status); --bug3439591
   END IF;

   IF p_set.override_flag(i) = 'Y' THEN

       IF p_set.requested_ship_date(i) is NOT null THEN
          l_ship_LAD_ln := p_set.ship_date(i);
       ELSE
          l_arr_LAD_ln := p_set.arrival_date(i);
       END IF;

       -- Honor the first overridden date
       IF G_set_override_flag = 'N' THEN
          IF G_is_ship_set THEN
              G_override_date := p_set.ship_date(i);
          ELSE
              G_override_date := p_set.arrival_date(i);
          END IF;
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Override case. override_date: ' ||
                                to_char(G_override_date, 'DD-MON-YYYY HH24:MI:SS'));
       END IF;
       G_set_override_flag := 'Y';
   ELSE
       IF p_set.requested_ship_date(i) is NOT null THEN

          l_ship_LAD_ln := p_set.latest_acceptable_date(i);--bug3439591
       ELSE
          l_arr_LAD_ln := p_set.latest_acceptable_date(i);--bug3439591
       END IF;

       -- xxx dsting hack
       G_ship_EAD_set := GREATEST(nvl(p_set.earliest_acceptable_date(i), G_ship_EAD_set),
                                  nvl(G_ship_EAD_set, p_set.earliest_acceptable_date(i)));

      /* Bug 3365376: LAD should be considered for Non-atpable items as well.
      -- nonatpable items..move LAD back to sysdate of curr LAD is before sysdate
       IF p_set.Error_Code(i) = MSC_ATP_PVT.ATP_NOT_APPL THEN
          l_ship_LAD_ln := null;
          l_arr_LAD_ln := null;
       END IF;
       */

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Non-Override case. ship_date: ' || to_char(p_set.ship_date(i), 'DD-MON-YYYY HH24:MI:SS'));
          msc_sch_wb.atp_debug('Non-Override case. ship_LAD_ln: ' || to_char(l_ship_LAD_ln, 'DD-MON-YYYY HH24:MI:SS'));
          msc_sch_wb.atp_debug('Non-Override case.  arr_LAD_ln: ' || to_char(l_arr_LAD_ln, 'DD-MON-YYYY HH24:MI:SS'));
          msc_sch_wb.atp_debug('Non-Override case.  arr_date: ' || to_char(p_set.arrival_date(i), 'DD-MON-YYYY HH24:MI:SS'));--bug3439591
          msc_sch_wb.atp_debug('Non-Override case.  LAD: ' || to_char(p_set.latest_acceptable_date(i), 'DD-MON-YYYY HH24:MI:SS'));--bug3439591
       END IF;
       -- 2834932
       G_set_nonoverride_flag := 'Y';
   END IF;

   -- set line status
   -- dsting 2797410
   IF nvl(p_set.override_flag(i), 'N') = 'Y'
      AND p_set.error_code(i) = MSC_ATP_PVT.ATP_REQ_DATE_FAIL
   THEN
      x_line_status := MSC_ATP_PVT.ALLSUCCESS;

   --bug 3365376: We should check pass/fail status for Non atpbale lines as well
   /* ELSIF p_set.error_code(i) = MSC_ATP_PVT.ATP_NOT_APPL
      OR p_set.error_code(i) = MSC_ATP_PVT.PDS_TO_ODS_SWITCH
   */
   ELSIF  p_set.error_code(i) = MSC_ATP_PVT.PDS_TO_ODS_SWITCH
   THEN
      x_line_status := MSC_ATP_PVT.ALLSUCCESS;
   ELSIF p_set.error_code(i) = MSC_ATP_PVT.ATP_REQ_DATE_FAIL
      --bug 3365376
      OR p_set.error_code(i) = MSC_ATP_PVT.ATP_NOT_APPL
      THEN
      IF TRUNC(p_set.ship_date(i)) > TRUNC(l_ship_LAD_ln)
         or TRUNC(p_set.arrival_date(i)) > TRUNC(l_arr_LAD_ln)
      THEN
         x_line_status := MSC_ATP_PVT.ATP_ACCEPT_FAIL;
      ELSE
         x_line_status := MSC_ATP_PVT.ALLSUCCESS;
      END IF;
   END IF;
   IF p_set.Action(i) <> MSC_ATP_PVT.ATPQUERY AND
      (p_set.Error_Code(i) = MSC_ATP_PVT.ATP_NOT_APPL OR
       p_set.error_code(i) = MSC_ATP_PVT.PDS_TO_ODS_SWITCH)
   THEN
      p_set.Error_Code(i) := MSC_ATP_PVT.ALLSUCCESS;
   END IF;

   IF p_set.requested_ship_date(i) is NOT null THEN
      G_ship_LAD_set := LEAST(NVL(G_ship_LAD_set, l_ship_LAD_ln),
                              NVL(l_ship_LAD_ln,  G_ship_LAD_set));
   ELSE
      G_arr_LAD_set := LEAST(NVL(G_arr_LAD_set, l_arr_LAD_ln),
                             NVL(l_arr_LAD_ln,  G_arr_LAD_set));
   END IF;

   G_latest_ship_date_set := GREATEST(NVL(G_latest_ship_date_set, p_set.ship_date(i)),
                                      NVL(p_set.ship_date(i), G_latest_ship_date_set));
   G_latest_arr_date_set  := GREATEST(NVL(G_latest_arr_date_set, p_set.arrival_date(i)),
                                      NVL(p_set.arrival_date(i), G_latest_arr_date_set));

   IF x_line_status not in (MSC_ATP_PVT.ALLSUCCESS,
                            MSC_ATP_PVT.ATP_ACCEPT_FAIL)
   THEN
      G_set_status := x_line_status;
   ELSIF G_set_status = MSC_ATP_PVT.ALLSUCCESS THEN
      IF TRUNC(G_latest_ship_date_set) > TRUNC(G_ship_LAD_set)
         OR TRUNC(G_latest_arr_date_set) > TRUNC(G_arr_LAD_set)
         OR (G_is_ship_set AND TRUNC(G_override_date) < TRUNC(G_ship_EAD_set)) -- xxx dsting hack
      THEN
        G_set_status := MSC_ATP_PVT.GROUPEL_ERROR;
      END IF;
   END IF;
   IF MSC_ATP_PVT.G_ATP_ITEM_PRESENT_IN_SET  = 'N' and p_set.atp_flag(i) <> 'N' or p_set.atp_components_flag(i) <> 'N' THEN
      MSC_ATP_PVT.G_ATP_ITEM_PRESENT_IN_SET := 'Y';
      msc_sch_wb.atp_debug('CHANGED THE ITEM PRESENT FLAG');
   END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('line_status: '  || x_line_status);
       msc_sch_wb.atp_debug('set_status: '  || G_set_status);
       msc_sch_wb.atp_debug('ship_LAD_set: ' || G_ship_LAD_set);
       msc_sch_wb.atp_debug('arr_LAD_set: '  || G_arr_LAD_set);
       msc_sch_wb.atp_debug('latest_ship_date_set: ' || to_char(G_latest_ship_date_set, 'DD-MON-YYYY HH24:MI:SS'));
       msc_sch_wb.atp_debug('latest_arr_date_set: ' || to_char(G_latest_arr_date_set, 'DD-MON-YYYY HH24:MI:SS'));
   END IF;

END Process_Set_Line;

PROCEDURE Process_Set_Dates_Errors(
   p_set         IN OUT NOCOPY      MRP_ATP_PUB.ATP_Rec_Typ,
   p_src_dest    IN                 VARCHAR2,
   x_set_status  OUT NOCOPY         NUMBER,
   p_start       IN                 NUMBER DEFAULT NULL,
   p_end         IN                 NUMBER DEFAULT NULL
) IS
   l_line_date      DATE;
   l_group_date     DATE;
   l_start          NUMBER;
   l_end            NUMBER;

   -- 2834932
   l_status_flag    NUMBER;
   l_group_work_date DATE;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Begin Process_Set_Dates_Errors');
      msc_sch_wb.atp_debug('   set_status: ' || G_set_status);
   END IF;

   l_start := nvl(p_start, 1);
   l_end   := nvl(p_end, p_set.action.count);

   IF G_is_ship_set THEN
      l_group_date := G_latest_ship_date_set;  --4460369
   ELSE
      l_group_date := G_latest_arr_date_set; --4460369
   END IF;

   IF G_set_status = MSC_ATP_PVT.ATP_REQ_QTY_FAIL THEN
      l_group_date := null;
   END IF;

   -- 2834932 dsting
   -- check if the date is on a weekend
   /* ship_rec_cal changes begin */
   IF TRUNC(G_override_date) = TRUNC(l_group_date) AND
      G_set_nonoverride_flag = 'Y'
   THEN
      IF p_src_dest = 'D' THEN

	IF G_is_ship_set THEN
	 l_group_work_date := MSC_CALENDAR.next_work_day(
              p_set.shipping_cal_code(l_start),
              p_set.instance_id(l_start),
              l_group_date );
	ELSE
	 l_group_work_date := MSC_CALENDAR.next_work_day(
              p_set.receiving_cal_code(l_start),
              p_set.instance_id(l_start),
              l_group_date );
	END IF;

      ELSIF p_src_dest = 'S' THEN
	IF G_is_ship_set THEN
	 l_group_work_date := MSC_SATP_FUNC.src_next_work_day(
              p_set.shipping_cal_code(l_start),
              l_group_date);
	ELSE
	 l_group_work_date := MSC_SATP_FUNC.src_next_work_day(
              p_set.receiving_cal_code(l_start),
              l_group_date);
	END IF;
      END IF;
      /* ship_rec_cal changes end */

      IF l_group_work_date is null THEN
            p_set.error_code(l_start) := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
            raise NO_DATA_FOUND;
      END IF;

      IF TRUNC(l_group_date) <> TRUNC(l_group_work_date) THEN
         l_status_flag := G_NONWORKING_DAY;
         G_set_status := MSC_ATP_PVT.ATP_OVERRIDE_DATE_FAIL;
      ELSE
         l_status_flag := null;
      END IF;
      l_group_date := l_group_work_date; --4460369
   END IF;

   for i in l_start..l_end loop

      -- Populate the group dates
       --added by avjain for populating latestacceptable date for shipset
      IF G_ship_LAD_set IS NOT NULL THEN
  	p_set.latest_acceptable_date(i) :=G_ship_LAD_set;
      ELSE
  	p_set.latest_acceptable_date(i) :=G_arr_LAD_set;
      END IF;
      if G_is_ship_set then
         p_set.group_ship_date(i) := l_group_date;

         if l_group_date is null then
            p_set.group_arrival_date(i) := null;
         elsif p_set.ship_date(i) = l_group_date then
            p_set.group_arrival_date(i) := p_set.arrival_date(i);
         elsif p_src_dest = 'D' then

         /* ship_rec_cal changes begin */
            p_set.group_arrival_date(i) := TRUNC(MSC_CALENDAR.THREE_STEP_CAL_OFFSET_DATE(
                                                l_group_date, null, 0, -- pass null to make sure no validation on ship cal as
                                                                       -- l_group_date has already been validated on ship cal
                                                p_set.intransit_cal_code(i), nvl(p_set.delivery_lead_time(i), 0), 1,
                                                p_set.receiving_cal_code(i), 1, p_set.instance_id(i)))   -- bug 8539537
                                                + (l_group_date - trunc(l_group_date)); --4460369  --4967040

         else
            p_set.group_arrival_date(i) := TRUNC(MSC_SATP_FUNC.SRC_THREE_STEP_CAL_OFFSET_DATE(
                                                l_group_date, null, 0, -- pass null to make sure no validation on ship cal as
                                                                       -- l_group_date has already been validated on ship cal
                                                p_set.intransit_cal_code(i), nvl(p_set.delivery_lead_time(i), 0), 1,
                                                p_set.receiving_cal_code(i), 1))
                                                + (l_group_date - trunc(l_group_date)); --4460369  --4967040

         end if;
         /* ship_rec_cal changes end */
      else
         p_set.group_arrival_date(i) := l_group_date;
         if l_group_date is null then
            p_set.group_arrival_date(i) := null;
         elsif p_set.arrival_date(i) = l_group_date then
            p_set.group_ship_date(i) := p_set.ship_date(i);
         elsif p_src_dest = 'D' then
            /* ship_rec_cal changes begin */
            p_set.group_ship_date(i) := TRUNC(MSC_CALENDAR.THREE_STEP_CAL_OFFSET_DATE(
                				l_group_date, null, 0, -- pass null to make sure no validation on receiving cal as
                                                       -- l_group_date has already been validated on receiving cal
                				p_set.intransit_cal_code(i), -1 * nvl(p_set.delivery_lead_time(i), 0), -1,
                				p_set.shipping_cal_code(i), -1, p_set.instance_id(i)))   -- bug 8539537
                                                + (l_group_date - trunc(l_group_date)); --4460369  --4967040

         else
            p_set.group_ship_date(i) := TRUNC(MSC_SATP_FUNC.SRC_THREE_STEP_CAL_OFFSET_DATE(
                				l_group_date, null, 0, -- pass null to make sure no validation on receiving cal as
                                                       -- l_group_date has already been validated on receiving cal
                				p_set.intransit_cal_code(i), -1 * nvl(p_set.delivery_lead_time(i), 0), -1,
                				p_set.shipping_cal_code(i), -1))
                                                + (l_group_date - trunc(l_group_date)); --4460369  --4967040

         end if;
         /* ship_rec_cal changes end */
      end if;

      G_latest_ship_date_set := GREATEST(G_latest_ship_date_set, p_set.group_ship_date(i));
      G_latest_arr_date_set  := GREATEST(G_latest_arr_date_set, p_set.group_arrival_date(i));

      /*IF MSC_ATP_PVT.G_RETAIN_TIME_NON_ATP = 'N' or MSC_ATP_PVT.G_ATP_ITEM_PRESENT_IN_SET = 'Y'  THEN  --4460369
         IF p_set.requested_ship_date(i) is not null then
            p_set.group_ship_date(i) := trunc(p_set.group_ship_date(i)) +  MSC_ATP_PVT.G_END_OF_DAY;
         ELSE
            p_set.group_arrival_date(i) := trunc(p_set.group_arrival_date(i)) +  MSC_ATP_PVT.G_END_OF_DAY;
         END IF;
      END IF;  --4460369*/ --4967040

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Ship Date := ' || to_char(p_set.ship_date(i), 'DD-MON-YYYY HH24:MI:SS'));
         msc_sch_wb.atp_debug('Arrival Date := ' || to_char(p_set.arrival_date(i), 'DD-MON-YYYY HH24:MI:SS'));
         msc_sch_wb.atp_debug('Group Ship Date := ' || to_char(p_set.group_ship_date(i), 'DD-MON-YYYY HH24:MI:SS'));
        msc_sch_wb.atp_debug('group_ship_date(' || i || '): ' || p_set.group_ship_date(i));
        msc_sch_wb.atp_debug('group_arrival_date(' || i || '): ' || p_set.group_arrival_date(i));
      END IF;
   end loop;
   -- 2834932 dsting. split the group date and error code loops

   -- one final check to see if and dates pushed beyond LAD
   IF G_set_status = MSC_ATP_PVT.ALLSUCCESS THEN
      IF TRUNC(G_latest_ship_date_set) > TRUNC(G_ship_LAD_set)
         OR TRUNC(G_latest_arr_date_set) > TRUNC(G_arr_LAD_set)
      THEN
        G_set_status := MSC_ATP_PVT.GROUPEL_ERROR;
      END IF;
   END IF;

   --
   -- Populate error code if needed. These errors are handled
   --   ATP_MULTI_OVERRIDE_DATES
   --   ATP_OVERRIDE_DATE_FAIL
   --   ATP_ACCEPT_FAIL
   --   GROUPEL_ERROR
   --
   if G_set_status <> MSC_ATP_PVT.ALLSUCCESS then
      for i in l_start..l_end loop
         if G_is_ship_set then
            l_line_date := p_set.ship_date(i);
            -- 2834932 dsting
            IF l_status_flag = G_NONWORKING_DAY AND
               nvl(p_set.override_flag(i), 'N') = 'N'
            THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Override date is nonworking day');
               END IF;
               IF p_set.error_code(i) = MSC_ATP_PVT.ALLSUCCESS THEN
                  p_set.error_code(i) := MSC_ATP_PVT.ATP_OVERRIDE_DATE_FAIL;
               END IF;
            END IF;
         else
            l_line_date := p_set.arrival_date(i);
         end if;

         IF (NVL(p_set.Override_Flag(i), 'N') = 'Y') THEN
            IF  TRUNC(G_override_date) <> TRUNC(l_line_date) THEN
               p_set.Error_Code(i) := MSC_ATP_PVT.ATP_MULTI_OVERRIDE_DATES;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('stmt18 - Multiple lines overridden to diff dates');
               END IF;
            END IF;
         ELSE
            IF TRUNC(G_override_date) < TRUNC(l_line_date) THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('stmt19 - Unable to Meet Overridden dates');
               END IF;
               p_set.Error_Code(i) := MSC_ATP_PVT.ATP_OVERRIDE_DATE_FAIL;
            ELSIF TRUNC(p_set.ship_date(i)) > TRUNC(G_ship_LAD_set)
                  OR TRUNC(p_set.arrival_date(i)) > TRUNC(G_arr_LAD_set)
            THEN
               p_set.Error_Code(i) := MSC_ATP_PVT.ATP_ACCEPT_FAIL;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('stmt19 - Unable to Meet LAD');
               END IF;
            END IF;
         END IF;

         IF NVL(p_set.Error_Code(i), MSC_ATP_PVT.ALLSUCCESS)
             --bug 3365376: Popluate error also when we have atp not appl or PDS to ODS switch
             --= MSC_ATP_PVT.ALLSUCCESS
             IN (MSC_ATP_PVT.ALLSUCCESS, MSC_ATP_PVT.ATP_NOT_APPL, MSC_ATP_PVT.PDS_TO_ODS_SWITCH)
         THEN
            p_set.Error_Code(i) := MSC_ATP_PVT.GROUPEL_ERROR;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('GROUPEL_ERROR');
            END IF;
         END IF;
      end loop;
   end if;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('END Proces_Set_Dates_Errors');
   END IF;

   x_set_status := G_set_status;
END Process_Set_Dates_Errors;

-- dsting copied and pasted from schedule
PROCEDURE Update_Set_SD_Dates(
   p_set        IN OUT NOCOPY     MRP_ATP_PUB.ATP_Rec_Typ,
   p_arrival_set IN    		  mrp_atp_pub.date_arr
) IS
   l_plan_info_rec      	MSC_ATP_PVT.plan_info_rec;
   l_plan_id            	NUMBER;
   l_demand_pegging_id  	NUMBER;
   l_sd_date            	DATE;
   --ship_rec_cal
   l_order_date_type    	NUMBER;
   l_ship_arrival_date_rec MSC_ATP_PVT.ship_arrival_date_rec_typ;
   l_return_status      	VARCHAR2(1);
BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Begin Update_Set_SD_Dates');
     END IF;

     FOR m in 1.. p_set.action.count LOOP
       IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('m = ' || m);
       END IF;

       IF (p_set.Action(m)<> MSC_ATP_PVT.ATPQUERY and p_set.quantity_ordered(m) <> 0) THEN -- xxxx
         /* --bug4281663 commented and initialized below
         IF MSC_ATP_PVT.G_INV_CTP = 4 THEN
             -- New procedure for obtaining plan data : Supplier Capacity Lead Time proj.
             -- (SCLT)
             MSC_ATP_PROC.get_global_plan_info(p_set.instance_id(m),
                         p_set.inventory_item_id(m),
                         -- 2832497 dsting
                         p_set.source_organization_id(m),
                         p_set.demand_class(m));

             l_plan_info_rec := MSC_ATP_PVT.G_PLAN_INFO_REC;
             -- End New procedure for obtaining plan data : Supplier Capacity Lead Time proj.

             l_plan_id          := l_plan_info_rec.plan_id;
             IF p_set.attribute_07.Exists(m) THEN
                p_set.attribute_07(m) := l_plan_info_rec.plan_name;
             END IF;
             -- changes for bug 2392456 ends

         ELSE
             l_plan_id := -1;
         END IF;
         */
         --bug4281663 Using the plan_id passed instead of calling get_global_plan_info
         l_plan_id := p_set.plan_id(m);
         l_demand_pegging_id := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('  l_demand_pegging_id := ' || l_demand_pegging_id);
            msc_sch_wb.atp_debug('  l_plan_id := ' || l_plan_id);
         END IF;
         -- xxxx
         MSC_ATP_PVT.G_DEMAND_PEGGING_ID := p_set.end_pegging_id(m);
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('  G_DEMAND_PEGGING_ID := ' || MSC_ATP_PVT.G_DEMAND_PEGGING_ID);
            msc_sch_wb.atp_debug('  G_DEMAND_CLASS_ATP_FLAG := ' || MSC_ATP_PVT.G_DEMAND_CLASS_ATP_FLAG(m));
            msc_sch_wb.atp_debug('  G_REQ_ATP_DATE := ' || MSC_ATP_PVT.G_REQ_ATP_DATE(m));
            msc_sch_wb.atp_debug('  G_REQ_DATE_QTY := ' || MSC_ATP_PVT.G_REQ_DATE_QTY(m));
            --bug4281663 Added more debug statements
            msc_sch_wb.atp_debug('  p_set.ship_date(m) := ' || p_set.ship_date(m));
            msc_sch_wb.atp_debug('  p_set.group_ship_date(m) := ' || p_set.group_ship_date(m));
         END IF;

         -- update_sd_date for setproc
         IF p_set.ship_date(m) <> p_set.group_ship_date(m) THEN
            IF NVL(p_set.override_flag(m), 'N') = 'Y' THEN
               l_sd_date := p_set.ship_date(m);
            ELSIF nvl(p_set.atp_lead_time(m), 0) <> 0 THEN
               -- For ship_rec_cal, this is fine because date_offset from non-working day or working day
	       -- gives the same result.
               l_sd_date := MSC_CALENDAR.DATE_OFFSET(
                                   p_set.source_organization_id(m),
                                   p_set.instance_id(m),
                                   1,
                                   p_set.group_ship_date(m),
                                   -NVL(p_set.atp_lead_time(m), 0));
            ELSE
               l_sd_date := p_set.group_ship_date(m);
            END IF;

            -- ship_rec_cal
            IF p_set.requested_arrival_date(m) is not null THEN
                l_order_date_type := 2;
            ELSE
                l_order_date_type := 1;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug(' __________________Flush PDS Data__________________');
                msc_sch_wb.atp_debug('Update_Set_SD_Dates : ' || 'sch arrival date: ' || p_set.group_arrival_date(m));
                msc_sch_wb.atp_debug('Update_Set_SD_Dates : ' || 'lat accep date  : ' || p_set.latest_acceptable_date(m));
                msc_sch_wb.atp_debug('Update_Set_SD_Dates : ' || 'order_date_type : ' || l_order_date_type);
                msc_sch_wb.atp_debug('  update_sd_date line: ' || m || ' date: ' || l_sd_date);
            END IF;

            MSC_ATP_DB_UTILS.Update_SD_Date(p_set.Identifier(m),
             p_set.instance_id(m), l_sd_date, l_plan_id,null, -- dsting setproc
             MSC_ATP_PVT.G_DEMAND_CLASS_ATP_FLAG(m),
             MSC_ATP_PVT.G_REQ_ATP_DATE(m),
             MSC_ATP_PVT.G_REQ_DATE_QTY(m), -- Bug 1501787
             l_sd_date, -- Bug 2795053-reopen
             null,              -- For time_phased_atp
             p_set.atf_date(m), -- For time_phased_atp
             null,              -- For time_phased_atp
             p_set.group_arrival_date(m),       -- For ship_rec_cal
             l_order_date_type,                 -- For ship_rec_cal
             p_set.latest_acceptable_date(m),   -- For ship_rec_cal
             p_set.ship_set_name(m),
             p_set.arrival_set_name(m),
             p_set.override_flag(m),
             p_arrival_set(m),null    --time_phased_atp --bug3397904
             );

             MSC_ATP_PVT.G_DEMAND_PEGGING_ID := l_demand_pegging_id;
         ELSE

              /* ship_rec_cal changes begin
                 flush sch arrival date, lat acceptable date, order date type in pds*/

                    l_ship_arrival_date_rec.scheduled_arrival_date := p_set.arrival_date(m);
                    l_ship_arrival_date_rec.latest_acceptable_date := p_set.latest_acceptable_date(m);
                    l_ship_arrival_date_rec.instance_id 	   := p_set.instance_id(m);
                    l_ship_arrival_date_rec.plan_id 		   := l_plan_id;
                    l_ship_arrival_date_rec.arrival_set_name       := p_set.arrival_set_name(m);
                    l_ship_arrival_date_rec.ship_set_name          := p_set.ship_set_name(m);
                    l_ship_arrival_date_rec.atp_override_flag      := p_set.override_flag(m);
    		    l_ship_arrival_date_rec.request_arrival_date   := p_arrival_set(m);
                    MSC_ATP_PVT.G_DEMAND_PEGGING_ID := p_set.end_pegging_id(m);
                    /* Read demand_id from madt*/
                    BEGIN
                        SELECT identifier3
                        INTO   l_ship_arrival_date_rec.demand_id
                        FROM   mrp_atp_details_temp
                        WHERE  pegging_id = MSC_ATP_PVT.G_DEMAND_PEGGING_ID
                        AND    session_id = MSC_ATP_PVT.G_SESSION_ID
                        AND    record_type = 3;
                    EXCEPTION
                        WHEN OTHERS THEN
                            l_ship_arrival_date_rec.demand_id := null;
                    END;
                    IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Update_Set_SD_Dates: ' || 'l_ship_arrival_date_rec.demand_id = ' || l_ship_arrival_date_rec.demand_id);
                    END IF;

                    /* Determine order date type*/
                    IF p_set.requested_arrival_date(m) is not null THEN
                        l_ship_arrival_date_rec.order_date_type := 2;
                    ELSE
                        l_ship_arrival_date_rec.order_date_type := 1;
                    END IF;
		    IF l_ship_arrival_date_rec.demand_id is not null THEN
                    	    --bug4281663 used plan id to determine ods or pds
                    	    /*
                    	    IF (MSC_ATP_PVT.G_INV_CTP = 4) THEN
	                    	MSC_ATP_DB_UTILS.Flush_Data_In_Pds(l_ship_arrival_date_rec, l_return_status);
	                    ELSE
	                    	MSC_ATP_DB_UTILS.Flush_Data_In_Ods(l_ship_arrival_date_rec, l_return_status);
	                    END IF;
	                    */
	                    IF NVL(p_set.plan_id(m),-1) = -1 THEN
	                    	MSC_ATP_DB_UTILS.Flush_Data_In_Ods(l_ship_arrival_date_rec, l_return_status);
	                    ELSE
	                    	MSC_ATP_DB_UTILS.Flush_Data_In_Pds(l_ship_arrival_date_rec, l_return_status);
	                    END IF;
		    END IF;

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                            IF PG_DEBUG in ('Y', 'C') THEN
                                    msc_sch_wb.atp_debug('Update_Set_SD_Dates: ' || 'Error in call to Flush_Data_In_Pds procedure ');
                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                    END IF;

              /* ship_rec_cal changes end */
         END IF;
       END IF;
     END LOOP;
END Update_Set_SD_Dates;

--------------------------------------------------
--      Delivery lead time Procedures           --
--------------------------------------------------

-- dsting
--
-- search for transit times in this order
--
-- 1) loc to loc
-- 2) region to region
-- 3) org to org
--
-- if a ship method is specified then 1,2,3 with ship method specified
-- 	then 1,2,3 with default times

PROCEDURE get_transit_time (
	p_from_loc_id		IN NUMBER,
	p_from_instance_id	IN NUMBER,
	p_to_loc_id		IN NUMBER,
	p_to_instance_id	IN NUMBER,
	p_session_id		IN NUMBER,
	p_partner_site_id	IN NUMBER,
	x_ship_method		IN OUT NoCopy VARCHAR2,
	x_intransit_time	OUT NoCopy NUMBER,
	p_supplier_site_id      IN NUMBER DEFAULT NULL, -- For supplier intransit LT project
	p_partner_type          IN      NUMBER,--2814895
	p_party_site_id         IN      NUMBER, --2814895
	p_order_line_id         IN      NUMBER)--2814895
IS
	l_level			NUMBER;
        l_cache_idx             NUMBER;

CURSOR	c_lead_time
IS
SELECT  intransit_time,
	((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM    msc_interorg_ship_methods mism,
	msc_regions_temp mrt
WHERE   mism.plan_id = -1
AND     mism.from_location_id = p_from_loc_id
AND     mism.sr_instance_id = p_from_instance_id
AND     mism.sr_instance_id2 = p_to_instance_id
AND     mism.ship_method = x_ship_method
AND     mism.to_region_id = mrt.region_id
AND     mrt.session_id = p_session_id
AND     mrt.partner_site_id = decode(NVL(p_partner_type,2), 2, p_partner_site_id, 4,p_party_site_id, 5, p_order_line_id)  --2814895
AND     mrt.partner_type    = NVL(p_partner_type,2)  --2814895 -- For supplier intransit LT project
ORDER BY 2;

CURSOR	c_default_lead_time
IS
SELECT  ship_method, intransit_time,
	((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM    msc_interorg_ship_methods mism,
	   msc_regions_temp mrt
WHERE   mism.plan_id = -1
AND     mism.from_location_id = p_from_loc_id
AND     mism.sr_instance_id = p_from_instance_id
AND     mism.sr_instance_id2 = p_to_instance_id
AND	mism.default_flag = 1
AND     mism.to_region_id = mrt.region_id
AND     mrt.session_id = p_session_id
AND     mrt.partner_site_id = decode( NVL(p_partner_type,2), 2, p_partner_site_id, 4, p_party_site_id, 5, p_order_line_id)  --2814895
AND     mrt.partner_type    = NVL(p_partner_type,2)  --2814895 -- For supplier intransit LT project
ORDER BY 3;

-- Changes for supplier intransit LT project begin
CURSOR  c_supplier_lead_time
IS
SELECT  intransit_time,
        mrt.region_type region_level -- collection has already translated data
FROM    msc_interorg_ship_methods mism,
        msc_regions_temp          mrt
WHERE   mism.plan_id            = -1
AND     mism.to_location_id     = p_to_loc_id
AND     mism.sr_instance_id2    = p_to_instance_id
AND     mism.sr_instance_id     = p_from_instance_id
AND     mism.ship_method        = x_ship_method
AND     mism.from_region_id     = mrt.region_id
AND     mrt.session_id          = p_session_id
AND     mrt.partner_site_id     = p_supplier_site_id
AND     mrt.partner_type        = 1 -- For supplier intransit LT project
ORDER BY 2;

CURSOR  c_supplier_default_lead_time
IS
SELECT  ship_method, intransit_time,
        mrt.region_type region_level -- collection has already translated data
FROM    msc_interorg_ship_methods mism,
        msc_regions_temp          mrt
WHERE   mism.plan_id            = -1
AND     mism.to_location_id     = p_to_loc_id
AND     mism.sr_instance_id2    = p_to_instance_id
AND     mism.sr_instance_id     = p_from_instance_id
AND     mism.default_flag       = 1
AND     mism.from_region_id     = mrt.region_id
AND     mrt.session_id          = p_session_id
AND     mrt.partner_site_id     = p_supplier_site_id
AND     mrt.partner_type        = 1 -- For supplier intransit LT project
ORDER BY 3;
-- Changes for supplier intransit LT project end

BEGIN

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('********** get_transit_time **********');
           msc_sch_wb.atp_debug('loc from: ' || p_from_loc_id ||
                                ' to: '      || p_to_loc_id);
           msc_sch_wb.atp_debug('instance from: ' || p_from_instance_id ||
                                ' to: '           || p_to_instance_id);
           msc_sch_wb.atp_debug('session_id: '    || p_session_id);
           msc_sch_wb.atp_debug('partner_site: '  || p_partner_site_id);
           msc_sch_wb.atp_debug('ship method: '   || x_ship_method);
        END IF;

	-- if the receipt org or the ship method is NULL
	-- then get the default time

	IF p_from_loc_id IS NOT NULL THEN
    	 	BEGIN
                        IF p_to_loc_id IS NULL THEN
                           RAISE NO_DATA_FOUND;
                        END IF;

			IF x_ship_method IS NOT NULL THEN
         			SELECT  intransit_time
    	    			INTO    x_intransit_time
     	    			FROM    msc_interorg_ship_methods
    	    			WHERE   plan_id = -1
    				AND     from_location_id = p_from_loc_id
         			AND     sr_instance_id = p_from_instance_id
	         		AND     to_location_id = p_to_loc_id
    		    		AND     sr_instance_id2 = p_to_instance_id
    				AND     ship_method = x_ship_method
    				AND     rownum = 1;
			ELSE
         			SELECT  ship_method, intransit_time
    	    			INTO    x_ship_method, x_intransit_time
     	    			FROM    msc_interorg_ship_methods
    	    			WHERE   plan_id = -1
    				AND     from_location_id = p_from_loc_id
         			AND     sr_instance_id = p_from_instance_id
	         		AND     to_location_id = p_to_loc_id
    		    		AND     sr_instance_id2 = p_to_instance_id
				AND     default_flag = 1
    				AND     rownum = 1;
			END IF;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			msc_sch_wb.atp_debug('Using region level transit times');
			IF x_ship_method IS NOT NULL THEN
	     			OPEN c_lead_time;
	     			FETCH c_lead_time INTO x_intransit_time, l_level;
		     		CLOSE c_lead_time;
			ELSE
	     			OPEN c_default_lead_time;
	     			FETCH c_default_lead_time INTO x_ship_method,
							x_intransit_time,
					   		l_level;
			     	CLOSE c_default_lead_time;
			END IF;
		END;

        ELSIF p_supplier_site_id IS NOT NULL THEN -- For supplier intransit LT project

                IF x_ship_method IS NOT NULL THEN
                        OPEN  c_supplier_lead_time;
                        FETCH c_supplier_lead_time
                        INTO  x_intransit_time, l_level;
                        CLOSE c_supplier_lead_time;
                ELSE
                        OPEN  c_supplier_default_lead_time;
                        FETCH c_supplier_default_lead_time
                        INTO  x_ship_method, x_intransit_time, l_level;
                        CLOSE c_supplier_default_lead_time;
                END IF;

	END IF;

	IF x_intransit_time IS NULL AND x_ship_method IS NOT NULL THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Using default transit times');
                END IF;

		-- call myself with null ship method to get defaults
		x_ship_method := NULL;
		get_transit_time(p_from_loc_id,
				 p_from_instance_id,
				 p_to_loc_id,
				 p_to_instance_id,
				 p_session_id,
				 p_partner_site_id,
				 x_ship_method,
				 x_intransit_time,
				 p_supplier_site_id,-- For supplier intransit LT project
				 p_partner_type,--2814895
	                         p_party_site_id,--2814895
	                         p_order_line_id ); --2814895
	END IF;


        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('transit_time:' || x_intransit_time);
           msc_sch_wb.atp_debug('ship_method:'  || x_ship_method);
        END IF;

END get_transit_time;

--
-- Calculate the delivery lead time.
--
--
-- Get the to and from locations if needed
--
-- 1) first get the location to location transit time using ship method if given
-- 2) if that fails, then get the org to org transit time using ship method if given
-- 3) get the default location to location transit time if no ship method given,
--	or 1,2 failed
-- 4) if that fails, then get the default org to org transit time
-- 5) if everything fails, just set the delivery lead time to 0
--
-- If we care about the ship method and it's not specified
-- 6) set the ship method to be the default location to location ship method
-- 7) if that fails, set it to be the dafault org to org ship method
--
-- The following functions are deprecated
--
--    get_default_ship_method
--    get_default_intransit_time
--    get_ship_method
--    get_intransit_time
--    get_interloc_transit_time
--    (replaced by get_delivery_lead_time, get_transit_time)
--
--    src_interloc_transit_time
--    src_default_intransit_time
--    src_default_ship_method
--    src_ship_method
--    src_intransit_time
--    (replaced by get_src_transit_time)

PROCEDURE get_delivery_lead_time(
        p_from_org_id		IN	NUMBER,
        p_from_loc_id		IN 	NUMBER,
        p_instance_id	  	IN	NUMBER,
        p_to_org_id	  	IN	NUMBER,
        p_to_loc_id		IN 	NUMBER,
        p_to_instance_id 	IN	NUMBER,
        p_customer_id		IN	NUMBER,
        p_customer_site_id	IN	NUMBER,
        p_supplier_id           IN      NUMBER,
        p_supplier_site_id      IN      NUMBER,
        p_session_id	  	IN	NUMBER,
        p_partner_site_id	IN	NUMBER,
        p_ship_method	  	IN OUT NoCopy	VARCHAR2,
        x_delivery_lead_time 	OUT NoCopy	NUMBER,
        p_partner_type          IN      NUMBER, --2814895
        p_party_site_id         IN      NUMBER , --2814895
	p_order_line_id         IN      NUMBER  --2814895
) IS
        l_from_loc_id		NUMBER;
        l_to_loc_id		NUMBER;
        l_cache_idx             NUMBER;
        l_dlt_key               VARCHAR2(64);
BEGIN

    IF PG_DEBUG IN ('Y', 'C') THEN
        msc_sch_wb.atp_debug('PROCEDURE get_delivery_lead_time');
        msc_sch_wb.atp_debug('   org from: ' || p_from_org_id ||
                             '   to: '       || p_to_org_id);
        msc_sch_wb.atp_debug('   loc from: ' || p_from_loc_id ||
                             '   to: '       || p_to_loc_id);
        msc_sch_wb.atp_debug('   instance from: ' || p_instance_id ||
                             '   to: ' 	         || p_to_instance_id);
        msc_sch_wb.atp_debug('   customer id: '  || p_customer_id ||
                             '   site_id: '      || p_customer_site_id);
        msc_sch_wb.atp_debug('   supplier id: '  || p_supplier_id ||
                             '   site_id: '      || p_supplier_site_id);
        msc_sch_wb.atp_debug('   session_id: '    || p_session_id);
        msc_sch_wb.atp_debug('   partner_site: '  || p_partner_site_id);
        msc_sch_wb.atp_debug('   ship method: '   || p_ship_method);
        msc_sch_wb.atp_debug('   p_partner_type: '|| p_partner_type); --2814895
        msc_sch_wb.atp_debug('   p_party_site_id: '|| p_party_site_id);
        msc_sch_wb.atp_debug('   p_order_line_id: '|| p_order_line_id);
    END IF;

    l_to_loc_id   := p_to_loc_id;

    IF  NOT (p_party_site_id IS NOT NULL AND NVL(p_partner_type, -1) = 3) THEN  --2814895
       l_to_loc_id   := p_to_loc_id;
    END IF; -- 2814895, to give customer_sire_id preference over party_site_id

    l_from_loc_id := p_from_loc_id;


    l_dlt_key := p_to_org_id   || ':' || p_to_instance_id   || ':' ||
                 p_customer_id || ':' || p_customer_site_id || ':' ||
                 p_supplier_id || ':' || p_supplier_site_id || ':' ||
                 p_from_org_id || ':' || p_instance_id || ':' ||
                 p_ship_method;

    -- check if I've already calculated dlt for these parameters

    IF dlt_cache.count > 0 THEN
        for l_cache_idx in reverse dlt_lookup.first..dlt_lookup.count loop
            if dlt_lookup(l_cache_idx) = l_dlt_key then
                x_delivery_lead_time := dlt_cache(l_cache_idx);
                p_ship_method := ship_method_cache(l_cache_idx);
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('dlt cache hit! idx: ' || dlt_idx ||
                                         ' dlt: ' || x_delivery_lead_time ||
                                         ' ship_method: ' || p_ship_method);
                END IF;
                return;
            end if;
        end loop;
    END IF;

	IF l_to_loc_id IS NULL THEN
		IF p_customer_id IS NOT NULL AND p_customer_site_id IS NOT NULL THEN
	     		l_to_loc_id := MSC_ATP_FUNC.get_location_id(
					p_instance_id,
					NULL,
					p_customer_id,
					p_customer_site_id,
					NULL,
					NULL);
		--ELSE
		ELSIF p_to_org_id IS NOT NULL AND (p_customer_id is NULL AND p_customer_site_id IS NULL) THEN
        -- Bug 3515520, don't use org in case customer/site is populated.
	     		l_to_loc_id := MSC_ATP_FUNC.get_location_id(
					p_to_instance_id,--bug 7382923
					p_to_org_id,
					NULL,
					NULL,
					NULL,
					NULL);
		END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('location to: '      || l_to_loc_id);
                END IF;
	END IF;

	IF l_to_loc_id IS NULL THEN --2814895
	   l_to_loc_id   := p_to_loc_id;
	END IF;

	IF l_from_loc_id IS NULL AND p_from_org_id IS NOT NULL THEN
                -- For supplier intransit LT project
                -- call get_location only when from_org is passsed
		l_from_loc_id := MSC_ATP_FUNC.get_location_id(p_instance_id,
					p_from_org_id,
					NULL,
					NULL,
					p_supplier_id,
					p_supplier_site_id);
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('location from: ' || l_from_loc_id);
                END IF;
	END IF;

	get_transit_time(l_from_loc_id,
			 p_instance_id,
			 l_to_loc_id,
			 p_to_instance_id,
			 p_session_id,
			 p_partner_site_id,
			 p_ship_method,
			 x_delivery_lead_time,
			 p_supplier_site_id, -- For supplier intransit LT project
			 p_partner_type, --2814895
			 p_party_site_id, --2814895
			 p_order_line_id );  --2814895

        IF NVL(x_delivery_lead_time, -1) = -1 THEN
           p_ship_method := null;
           x_delivery_lead_time := 0;
        END IF;

        dlt_idx := dlt_idx+1;
        IF dlt_idx = MAX_DLT_CACHE_SZ THEN
           dlt_idx := 1;
        END IF;

        if dlt_cache.count() < MAX_DLT_CACHE_SZ then
           dlt_lookup.extend();
           dlt_cache.extend();
           ship_method_cache.extend();
        end if;

        -- add dlt and ship_method to cache
        dlt_lookup(dlt_idx) := l_dlt_key;
        dlt_cache(dlt_idx) := x_delivery_lead_time;
        ship_method_cache(dlt_idx) := p_ship_method;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('   ship method = ' || p_ship_method);
           msc_sch_wb.atp_debug('   delivery_lead_time = ' || x_delivery_lead_time);
           msc_sch_wb.atp_debug('END get_delivery_lead_time');
        END IF;

END get_delivery_lead_time;

PROCEDURE number_arr_cat (
        p1      IN OUT NOCOPY   mrp_atp_pub.number_arr,
        p2      IN              mrp_atp_pub.number_arr
) IS
        len        number;
BEGIN
        len := p1.count();
        p1.extend(p2.count);
        for i in 1..p2.count() loop
                p1(len + i) := p2(i);
        end loop;
END number_arr_cat;

PROCEDURE date_arr_cat (
        p1      IN OUT NOCOPY   mrp_atp_pub.date_arr,
        p2      IN              mrp_atp_pub.date_arr
) IS
        len        number;
BEGIN
        len := p1.count();
        p1.extend(p2.count);
        for i in 1..p2.count() loop
               p1(len + i) := p2(i);
        end loop;
END date_arr_cat;

PROCEDURE cleanup_set(
        p_instance_id   IN      number,
        p_plan_id       IN      number,
        peg_ids         IN      mrp_atp_pub.number_arr,
        dmd_class_flag  IN      mrp_atp_pub.number_arr
) IS
        l_return_sts varchar2(1);
BEGIN
        FOR i in 1..peg_ids.count LOOP
            MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(
              peg_ids(i),
              p_instance_id,
              p_plan_id,
              MSC_ATP_PVT.UNDO,
              dmd_class_flag(i),
              l_return_sts);
        end loop;
END cleanup_set;

--(ssurendr) Bug 2865389 Create a New procedure for Process Effectivity
PROCEDURE Get_Process_Effectivity (
                             p_plan_id             IN NUMBER,
                             p_item_id             IN NUMBER,
                             p_organization_id     IN NUMBER,
                             p_sr_instance_id      IN NUMBER,
                             p_new_schedule_date   IN DATE,
                             p_requested_quantity  IN NUMBER,
                             x_process_seq_id      OUT NOCOPY NUMBER,
                             x_routing_seq_id      OUT NOCOPY NUMBER,
                             x_bill_seq_id         OUT NOCOPY NUMBER,
                             x_op_seq_id           OUT NOCOPY NUMBER, --4570421
                             x_return_status       OUT NOCOPY VARCHAR2)

IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Inside Get Process Effectivity *****');
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'Selecting Process Sequence ID');
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'plan_id = '|| p_plan_id);
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'item id = '|| p_item_id);
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'p_organization_id = '|| p_organization_id);
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'p_sr_instance_id = '|| p_sr_instance_id);
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'p_new_schedule_date = '|| p_new_schedule_date);
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'p_requested_quantity = '|| p_requested_quantity);
    END IF;

    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT  a.process_sequence_id,a.routing_sequence_id, a.bill_sequence_id, a.operation_sequence_id --4570421
    INTO x_process_seq_id,x_routing_seq_id,x_bill_seq_id, x_op_seq_id
    FROM
    (
    /*
    SELECT process_sequence_id,routing_sequence_id,bill_sequence_id
    FROM msc_process_effectivity
    WHERE plan_id = p_plan_id
    AND   organization_id = p_organization_id
    AND   item_id = p_item_id
    AND   sr_instance_id = p_sr_instance_id
    AND   p_requested_quantity BETWEEN NVL(minimum_quantity,0) AND
               DECODE(NVL(maximum_quantity,0),0,99999999,maximum_quantity)
    /* rajjain 3008611
     * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
     * disable date should be less than or equal to greatest of PTF date, sysdate and start date
    AND   TRUNC(effectivity_date) <= TRUNC(GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
    AND   TRUNC(NVL(disable_date,GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1))
               > TRUNC(GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
    ORDER BY preference */
    --4570421
    SELECT eff.process_sequence_id, eff.routing_sequence_id, eff.bill_sequence_id, op.operation_sequence_id
    FROM msc_process_effectivity eff, msc_routing_operations op
    WHERE eff.plan_id = p_plan_id
    AND   eff.organization_id = p_organization_id
    AND   eff.item_id = p_item_id
    AND   eff.sr_instance_id = p_sr_instance_id
    AND   p_requested_quantity BETWEEN NVL(eff.minimum_quantity,0) AND
               DECODE(NVL(eff.maximum_quantity,0),0,99999999,maximum_quantity)
    AND   TRUNC(eff.effectivity_date) <= TRUNC(GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
    AND   TRUNC(NVL(eff.disable_date,GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1))
               > TRUNC(GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
    --4570421
    and   eff.plan_id = op.plan_id(+)
    AND   eff.sr_instance_id = op.sr_instance_id(+)
    and   eff.routing_sequence_id = op.routing_sequence_id(+)
    AND   TRUNC(op.effectivity_date(+)) <= TRUNC(GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
    AND   TRUNC(NVL(op.disable_date(+),GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1))
               > TRUNC(GREATEST(p_new_schedule_date, sysdate, MSC_ATP_PVT.G_PTF_DATE)) --4570421
    ORDER BY eff.preference, op.operation_seq_num
    ) a
    where rownum = 1;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'Routing Id:' || x_routing_seq_id || ' Bill Seq id :' || x_bill_seq_id || ' Procees seq ID:' || x_process_seq_id
                              || ' Operation seq ID:' || x_op_seq_id); --4570421
        msc_sch_wb.atp_debug('*****  END Get Process Effectivity *****');
    END IF;
EXCEPTION
    -- 3027711
    WHEN NO_DATA_FOUND THEN
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'Could not get process effectivity Values');
        x_process_seq_id := null;
        x_routing_seq_id := null;
        x_bill_seq_id := null;
    WHEN OTHERS THEN
        msc_sch_wb.atp_debug('Get_Process_Effectivity: ' || 'sqlcode: ' || sqlcode);
        x_process_seq_id := null;
        x_routing_seq_id := null;
        x_bill_seq_id := null;
        x_return_status := FND_API.G_RET_STS_ERROR;
END get_process_effectivity;

-- supplier intransit LT
PROCEDURE Get_Supplier_Regions (p_vendor_site_id    IN  NUMBER,
                                p_calling_module    IN  NUMBER,
                                p_instance_id       IN  NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2)
IS
l_counter       PLS_INTEGER;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('*************** Get_Supplier_Regions Begin *************');
           msc_sch_wb.atp_debug('Get_Supplier_Regions :' || 'p_vendor_site_id := ' || p_vendor_site_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        FOR l_counter IN 1..G_VENDOR_SITE_ID.COUNT LOOP
            IF MSC_ATP_PROC.G_VENDOR_SITE_ID(l_counter) = p_vendor_site_id THEN
                msc_sch_wb.atp_debug('Get_Supplier_Regions :' || 'Data for site ' || p_vendor_site_id ||
                        ' already exists.');
                return;
            END IF;
        END LOOP;

        MSC_SATP_FUNC.Get_Regions(NULL,                     -- p_customer_site_id
                                  p_calling_module,         -- p_calling_module
                                  p_instance_id,            -- p_instance_id
                                  MSC_ATP_PVT.G_SESSION_ID, -- p_session_id
                                  NULL,                     -- p_dblink
                                  x_return_status,          -- x_return_status
                                  NULL,                     -- p_location_id
                                  NULL,                     -- p_location_source
                                  p_vendor_site_id);        -- p_supplier_site_id

        G_VENDOR_SITE_ID.Extend();
        G_VENDOR_SITE_ID(G_VENDOR_SITE_ID.COUNT) := p_vendor_site_id;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('*************** Get_Supplier_Regions End *************');
        END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Supplier_Regions: ' || 'sqlcode: ' || sqlcode);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
END Get_Supplier_Regions;


-- supplier intransit LT
/*--ATP_Intransit_LT-----------------------------------------------------------
| - Generic API to find intransit lead times to be called mainly by
|   products other than GOP.
| o p_src_dest            - whether being called from source or
|                           destination - 1:Source; 2:Destination
| o p_session_id          - unique number identifying the current session
| o p_from_org_id         - used in org-org and org-cust scenario, should
|                           be null in supp-org case, not required if
|                           p_from_loc_id is provided
| o p_from_loc_id         - used in org-cust scenario, should be null in
|                           org-org and supp-org cases, not required if
|                           p_from_org_id is provided
| o p_from_vendor_site_id - used in supp-org scenario, should be null in
|                           org-org and supp-org cases
| o p_from_instance_id    - from party's instance id, not required when
|                           called from source
| o p_to_org_id           - used in org-org and supp-org scenario, should
|                           be null in org-cust case
| o p_to_loc_id           - used in org-cust scenario, should be null in
|                           org-org and supp-org cases, not required if
|                           p_to_customer_site_id is provided
| o p_to_customer_site_id - used in org-cust scenario, should be null in
|                           org-org and supp-org cases, not required if
|                           p_to_loc_id is provided
| o p_to_instance_id      - to party's instance id, not required when called
|                           from source
| o p_ship_method         - default ship method is used if not passed. if
|                           the passed ship method does not exist in shipping
|                           network then default ship method is returned
| o x_intransit_lead_time - intrasit lead time
| o x_return_status       - return status
+----------------------------------------------------------------------------*/
PROCEDURE ATP_Intransit_LT (p_src_dest              IN  NUMBER,
                            p_session_id            IN  NUMBER,
                            p_from_org_id           IN  NUMBER,
                            p_from_loc_id           IN  NUMBER,
                            p_from_vendor_site_id   IN  NUMBER,
                            p_from_instance_id      IN  NUMBER,
                            p_to_org_id             IN  NUMBER,
                            p_to_loc_id             IN  NUMBER,
                            p_to_customer_site_id   IN  NUMBER,
                            p_to_instance_id        IN  NUMBER,
                            p_ship_method           IN OUT  NoCopy VARCHAR2,
                            x_intransit_lead_time   OUT     NoCopy NUMBER,
                            x_return_status         OUT NOCOPY VARCHAR2
)
IS
    l_calling_module    NUMBER;
    l_return_status     VARCHAR2(1);
BEGIN
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    msc_sch_wb.set_session_id(p_session_id);
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***************Begin ATP_Intransit_LT *****************');
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_src_dest              : ' || p_src_dest );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_session_id            : ' || p_session_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_from_org_id           : ' || p_from_org_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_from_loc_id           : ' || p_from_loc_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_from_vendor_site_id   : ' || p_from_vendor_site_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_from_instance_id      : ' || p_from_instance_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_to_org_id             : ' || p_to_org_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_to_loc_id             : ' || p_to_loc_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_to_customer_site_id   : ' || p_to_customer_site_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_to_instance_id        : ' || p_to_instance_id );
       msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'p_ship_method           : ' || p_ship_method );
    END IF;

    IF p_from_vendor_site_id IS NOT NULL THEN
        IF p_src_dest = 1 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'Invalid parameter - supp-org not supported from source');
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        ELSE
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || ': supp-org case');
            END IF;
            MSC_SATP_FUNC.Get_Regions(NULL,                 -- p_customer_site_id
                                      724,                  -- p_calling_module
                                      p_from_instance_id,   -- p_instance_id
                                      p_session_id,         -- p_session_id
                                      NULL,                 -- p_dblink
                                      l_return_status,      -- x_return_status
                                      NULL,                 -- p_location_id
                                      NULL,                 -- p_location_source
                                      p_from_vendor_site_id -- p_supplier_site_id
                                     );

            Get_Delivery_Lead_Time(NULL,                    -- p_from_org_id
                                   NULL,                    -- p_from_loc_id
                                   p_from_instance_id,      -- p_instance_id
                                   p_to_org_id,             -- p_to_org_id
                                   NULL,                    -- p_to_loc_id
                                   p_to_instance_id,        -- p_to_instance_id
                                   NULL,                    -- p_customer_id
                                   NULL,                    -- p_customer_site_id
                                   NULL,                    -- p_supplier_id
                                   p_from_vendor_site_id,   -- p_supplier_site_id
                                   p_session_id,            -- p_session_id
                                   NULL,                    -- p_partner_site_id
                                   p_ship_method,           -- p_ship_method
                                   x_intransit_lead_time    -- x_delivery_lead_time
                                  );
        END IF;
    ELSIF p_to_customer_site_id IS NOT NULL OR p_to_loc_id IS NOT NULL THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || ': org-cust case');
        END IF;
        IF p_src_dest = 1 THEN
            MSC_SATP_FUNC.Get_Regions(p_to_customer_site_id,    -- p_customer_site_id
                                      -1,                       -- p_calling_module (not 724)
                                      NULL,                     -- p_instance_id
                                      p_session_id,             -- p_session_id
                                      NULL,                     -- p_dblink
                                      l_return_status,          -- x_return_status
                                      p_to_loc_id,              -- p_location_id
                                      'HZ',                     -- p_location_source
                                      NULL                      -- p_supplier_site_id
                                     );

            MSC_SATP_FUNC.get_src_transit_time(p_from_org_id,   -- p_from_org_id
                                       p_from_loc_id,           -- p_from_loc_id
                                       NULL,                    -- p_to_org_id
                                       p_to_loc_id,             -- p_to_loc_id
                                       p_session_id,            -- p_session_id
                                       p_to_customer_site_id,   -- p_partner_site_id
                                       p_ship_method,           -- x_ship_method
                                       x_intransit_lead_time    -- x_intransit_time
                                      );
        ELSE
            MSC_SATP_FUNC.Get_Regions(p_to_customer_site_id,    -- p_customer_site_id
                                      724,                      -- p_calling_module
                                      p_from_instance_id,       -- p_instance_id
                                      p_session_id,             -- p_session_id
                                      NULL,                     -- p_dblink
                                      l_return_status,          -- x_return_status
                                      p_to_loc_id,              -- p_location_id
                                      'HZ',                     -- p_location_source
                                      NULL                      -- p_supplier_site_id
                                     );

            Get_Delivery_Lead_Time(p_from_org_id,           -- p_from_org_id
                                   p_from_loc_id,           -- p_from_loc_id
                                   p_from_instance_id,      -- p_instance_id
                                   NULL,                    -- p_to_org_id
                                   p_to_loc_id,             -- p_to_loc_id
                                   p_to_instance_id,        -- p_to_instance_id
                                   NULL,                    -- p_customer_id
                                   p_to_customer_site_id,   -- p_customer_site_id
                                   NULL,                    -- p_supplier_id
                                   p_from_vendor_site_id,   -- p_supplier_site_id
                                   p_session_id,            -- p_session_id
                                   p_to_customer_site_id,   -- p_partner_site_id
                                   p_ship_method,           -- p_ship_method
                                   x_intransit_lead_time    -- x_delivery_lead_time
                                  );
        END IF;
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || ': org-org case');
        END IF;
        IF p_src_dest = 1 THEN
            MSC_SATP_FUNC.get_src_transit_time(p_from_org_id,   -- p_from_org_id
                                       p_from_loc_id,           -- p_from_loc_id
                                       p_to_org_id,             -- p_to_org_id
                                       p_to_loc_id,             -- p_to_loc_id
                                       p_session_id,            -- p_session_id
                                       NULL,                    -- p_partner_site_id
                                       p_ship_method,           -- x_ship_method
                                       x_intransit_lead_time    -- x_intransit_time
                                      );
        ELSE
            Get_Delivery_Lead_Time(p_from_org_id,           -- p_from_org_id
                                   p_from_loc_id,           -- p_from_loc_id
                                   p_from_instance_id,      -- p_instance_id
                                   p_to_org_id,             -- p_to_org_id
                                   p_to_loc_id,             -- p_to_loc_id
                                   p_to_instance_id,        -- p_to_instance_id
                                   NULL,                    -- p_customer_id
                                   NULL,                    -- p_customer_site_id
                                   NULL,                    -- p_supplier_id
                                   NULL,                    -- p_supplier_site_id
                                   p_session_id,            -- p_session_id
                                   NULL,                    -- p_partner_site_id
                                   p_ship_method,           -- p_ship_method
                                   x_intransit_lead_time    -- x_delivery_lead_time
                                  );
        END IF;
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('ATP_Intransit_LT: ' || 'Error code:' || to_char(sqlcode));
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
END ATP_Intransit_LT;

END MSC_ATP_PROC;

/
