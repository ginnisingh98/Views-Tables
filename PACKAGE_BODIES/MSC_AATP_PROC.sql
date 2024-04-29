--------------------------------------------------------
--  DDL for Package Body MSC_AATP_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_AATP_PROC" AS
/* $Header: MSCPAATB.pls 120.1 2007/12/12 10:32:59 sbnaik ship $  */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE Add_to_current_atp (
	p_steal_atp            		IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info,
	p_current_atp        		IN OUT	NOCOPY MRP_ATP_PVT.ATP_Info,
	x_return_status 		OUT     NOCOPY VARCHAR2
) IS
	i 			PLS_INTEGER; -- index for p_current_atp
	j 			PLS_INTEGER; -- index for p_steal_atp
	k 			PLS_INTEGER; -- index for l_current_atp
	n 			PLS_INTEGER; -- starting point of p_steal_atp
	l_current_atp  		MRP_ATP_PVT.ATP_Info; -- this will be the output
	l_processed		BOOLEAN;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********Begin Add_to_current_atp Procedure************');
    END IF;

  -- initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  j := p_current_atp.atp_period.FIRST;
  k := 0;
  FOR i IN 1..p_steal_atp.atp_period.COUNT LOOP

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug ('Add_to_current_atp: ' ||  'we are in loop i = '||i);
    END IF;
    IF p_steal_atp.atp_qty(i) < 0 THEN
       l_processed := FALSE;
       WHILE (j IS NOT NULL) LOOP
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug ('Add_to_current_atp: ' ||  'we are in loop j = '||j);
          END IF;
          k := k+1;
          l_current_atp.atp_period.Extend;
          l_current_atp.atp_qty.Extend;

          IF p_current_atp.atp_period(j) < p_steal_atp.atp_period(i) THEN

            -- we add this to l_current_atp
            l_current_atp.atp_period(k) := p_current_atp.atp_period(j);
            l_current_atp.atp_qty(k) := p_current_atp.atp_qty(j);

          ELSIF p_current_atp.atp_period(j)=p_steal_atp.atp_period(i) THEN

            -- both record (p_current_atp and p_steal_atp) are on the same
            -- date.  we need to sum them up
            l_processed := TRUE;
            l_current_atp.atp_period(k) := p_current_atp.atp_period(j);
            l_current_atp.atp_qty(k) := p_current_atp.atp_qty(j) +
                                           p_steal_atp.atp_qty(i);
            -- j := j+1;
            j := p_current_atp.atp_period.NEXT(j);
            EXIT; -- exit the loop since we had done group by before. so
                  -- we don't need to go to next record any more
          ELSE -- this is the greater part
            l_processed := TRUE;
            l_current_atp.atp_period(k) := p_steal_atp.atp_period(i);
            l_current_atp.atp_qty(k) := p_steal_atp.atp_qty(i);
            EXIT; -- exit the loop since we had done group by before.

          END IF;
         j := p_current_atp.atp_period.NEXT(j) ;
       END LOOP;

       IF (j is null) AND (l_processed = FALSE) THEN
         -- this means p_current_atp is over,
         -- so we don't need to worry about p_next_steak_atp,
         -- we just keep add p_steal_atp to l_current_atp
         -- if they are not added before
         k := k+1;
         l_current_atp.atp_period.Extend;
         l_current_atp.atp_qty.Extend;

         l_current_atp.atp_period(k) := p_steal_atp.atp_period(i);
         l_current_atp.atp_qty(k) := p_steal_atp.atp_qty(i);
       END IF;
       p_steal_atp.atp_qty(i) := 0;

    END IF; -- p_steal_atp.atp_qty < 0
  END LOOP;

  -- now we have taken care of all p_steal_atp and part of
  -- p_current_atp. now we need to take care the rest of p_current_atp

  -- FOR j IN n..p_current_atp.atp_period.COUNT LOOP
  WHILE j is not null LOOP
     -- we add this to l_current_atp
     k := k+1;
     l_current_atp.atp_period.Extend;
     l_current_atp.atp_qty.Extend;
     l_current_atp.atp_period(k) := p_current_atp.atp_period(j);
     l_current_atp.atp_qty(k) := p_current_atp.atp_qty(j);
     j := p_current_atp.atp_period.NEXT(j);
  END LOOP;

  p_current_atp := l_current_atp;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********End Add_to_current_atp Procedure************');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_to_current_atp: ' || 'Error code:' || to_char(sqlcode));
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

END Add_to_current_atp;

PROCEDURE Atp_Forward_Consume (
        p_atp_period      IN      MRP_ATP_PUB.date_arr,
        p_atf_date        IN      DATE,
        p_atp_qty         IN OUT  NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status   OUT     NOCOPY VARCHAR2
) IS
	i 			PLS_INTEGER;
	j 			PLS_INTEGER;
	l_counter		PLS_INTEGER;
        -- time_phased_atp
        l_fw_nullifying_bucket_index    NUMBER  := 1;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********Begin Atp_Forward_Consume Procedure************');
    END IF;

    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_counter := p_atp_qty.COUNT;
    FOR i in 1..l_counter LOOP

        -- this loop will do forward consumption
        -- forward consumption when neg atp quantity occurs
        IF (p_atp_qty(i) < 0 ) THEN
            j := i + 1;
            WHILE (j <= l_counter)  LOOP
                IF ((p_atp_period(i)<=p_atf_date) and (p_atp_period(j)>p_atf_date)) THEN
                    -- exit loop when crossing time fence
                    j := l_counter + 1;
                ELSIF (p_atp_qty(j) <= 0 OR j < l_fw_nullifying_bucket_index) THEN
                    --  forward one more period
                    j := j+1 ;
                ELSE
                    -- You can get something from here. So set the nullifying bucket index
                    l_fw_nullifying_bucket_index := j;
                    IF (p_atp_qty(j) + p_atp_qty(i) < 0) THEN
                        -- not enough to cover the shortage
                        p_atp_qty(i) := p_atp_qty(i) + p_atp_qty(j);
                        p_atp_qty(j) := 0;
                        j := j+1;
                    ELSE
                        -- enough to cover the shortage
                        p_atp_qty(j) := p_atp_qty(j) + p_atp_qty(i);
                        p_atp_qty(i) := 0;
                        j := l_counter + 1;
                    END IF;
                END IF;
            END LOOP;
        END IF;

    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********End Atp_Forward_Consume Procedure************');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Forward_Consume: ' || 'Error code:' || to_char(sqlcode));
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

END Atp_Forward_Consume;

PROCEDURE Atp_Adjusted_Cum (
        p_current_atp		IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info,
        p_unallocated_atp	IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info,
        x_return_status         OUT     NOCOPY VARCHAR2
) IS
	i 			PLS_INTEGER;
	j 			PLS_INTEGER;
	l_counter		PLS_INTEGER;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('**********Begin Atp_Adjusted_Cum Procedure************');
  END IF;

  -- initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  i := p_current_atp.atp_period.LAST;
  While i is not null LOOP

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug ('Atp_Adjusted_Cum: ' ||  'i = '||i);
    END IF;
    p_current_atp.atp_qty(i) := GREATEST(LEAST(p_current_atp.atp_qty(i),
                                   p_unallocated_atp.atp_qty(i)), 0);

    p_unallocated_atp.atp_qty(i) := p_unallocated_atp.atp_qty(i) - p_current_atp.atp_qty(i);

    --rajjain Bug 2793336 03/10/2003 Begin
    IF i <> p_current_atp.atp_period.LAST
      AND p_unallocated_atp.atp_qty(i) > p_unallocated_atp.atp_qty(i+1)
    THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug ('Atp_Adjusted_Cum: ' || 'Unallocated Cum Date:Qty - '||
                          p_current_atp.atp_period(i) ||' : '|| p_unallocated_atp.atp_qty(i) );
       END IF;
       p_unallocated_atp.atp_qty(i) := p_unallocated_atp.atp_qty(i+1);
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug ('Atp_Adjusted_Cum: ' || 'Updated Unallocated Cum Date:Qty - '||
                          p_current_atp.atp_period(i) ||' : '|| p_unallocated_atp.atp_qty(i) );
       END IF;
    END IF;
    --rajjain Bug 2793336 03/10/2003 End
    i := p_current_atp.atp_period.Prior(i);
  END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('**********End Atp_Adjusted_Cum Procedure************');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Adjusted_Cum: ' || 'Error code:' || to_char(sqlcode));
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

END Atp_Adjusted_Cum;

PROCEDURE Atp_Remove_Negatives (
        p_atp_qty         IN OUT NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status   OUT    NOCOPY VARCHAR2
) IS
	i 			PLS_INTEGER;
	l_counter		PLS_INTEGER;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********Begin Atp_Remove_Negatives Procedure************');
    END IF;

    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_counter := p_atp_qty.COUNT;
    FOR i in 1..l_counter LOOP

        -- this loop will remove negatives
        IF (p_atp_qty(i) < 0 ) THEN
            p_atp_qty(i) := 0;

	    IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Atp_Remove_Negatives: ' ||  'we are in loop for removing negatives, i='||i);
            END IF;
	END IF;

    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('**********End Atp_Remove_Negatives Procedure************');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Atp_Remove_Negatives: ' || 'Error code:' || to_char(sqlcode));
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

END Atp_Remove_Negatives;

PROCEDURE get_unalloc_data_from_SD_temp(
  x_atp_period                  OUT NOCOPY 	MRP_ATP_PUB.ATP_Period_Typ,
  p_unallocated_atp		IN OUT NOCOPY 	MRP_ATP_PVT.ATP_Info,
  x_return_status 		OUT NOCOPY     	VARCHAR2
) IS
  i			NUMBER;
  j			NUMBER;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('PROCEDURE get_unalloc_data_from_SD_temp');
  END IF;

  -- initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- do netting for unallocated qty also
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
	,SUM(unallocated_quantity)
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
        x_atp_period.Period_Quantity,
	p_unallocated_atp.atp_qty
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
     x_atp_period.total_bucketed_demand_quantity.extend(i); -- time_phased_atp

     FOR j IN 1..(i-1) LOOP
	x_atp_period.Period_End_Date(j) :=
		x_atp_period.Period_Start_Date(j+1) - 1;
     END LOOP;

EXCEPTION
  WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('get_unalloc_data_from_SD_temp: ' || 'Error code:' || to_char(sqlcode));
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

END get_unalloc_data_from_SD_temp;

END MSC_AATP_PROC;

/
