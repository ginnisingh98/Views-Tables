--------------------------------------------------------
--  DDL for Package Body MSC_SATP_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SATP_FUNC" AS
/* $Header: MSCSATPB.pls 120.5.12010000.2 2009/08/24 06:58:11 sbnaik ship $  */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MSC_SATP_FUNC';
G_INV_CTP	NUMBER := FND_PROFILE.value('INV_CTP');


--Following Functions Are used for calculating delivery lead time on the source

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

FUNCTION src_location_id(
	p_organization_id        	IN     NUMBER,
	p_customer_id            	IN     NUMBER,
	p_customer_site_id       	IN     NUMBER
)
RETURN NUMBER IS
L_location_id 	NUMBER;
BEGIN

	IF (p_organization_id IS NOT NULL) THEN
	-- bug 2974334. Change the SQL into static.
	   SELECT	location_id
	   into		l_location_id
           --bug 3346564
	   --from	HR_ORGANIZATION_UNITS
	   from		HR_ALL_ORGANIZATION_UNITS
	   where	organization_id = p_organization_id;

	ELSIF  (p_customer_id IS NOT NULL and p_customer_site_id IS NOT NULL) THEN
           -- Bug 2793404, Bug discovered by Sony
	   -- bug 2974334. Change the SQL into static.
	   select	location_id
	   into		l_location_id
	   from		PO_LOCATION_ASSOCIATIONS
	   where	SITE_USE_ID = p_customer_site_id;

           -- End Bug 2793404

        END IF;
        return l_location_id;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
             RETURN null;
END src_location_id;

-- savirine added parameters p_session_id and p_partner_site_id on Sep 24, 2001.

FUNCTION src_interloc_transit_time (
	p_from_location_id 		IN 	NUMBER,
	p_to_location_id   		IN 	NUMBER,
	p_ship_method      		IN 	VARCHAR2,
        p_session_id 			IN 	NUMBER := NULL,
        p_partner_site_id 		IN 	NUMBER := NULL)
return NUMBER IS

l_intransit_time        NUMBER;
l_level                 NUMBER;

BEGIN

      BEGIN
        select  intransit_time
        into    l_intransit_time
        from    mtl_interorg_ship_methods
        where    from_location_id = p_from_location_id
        and     to_location_id = p_to_location_id
        and     ship_method = p_ship_method
        and     rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN

	     -- ngoel 9/25/2001, need to select most specific lead time based on regions
	     -- bug 2974334. Change the SQL into static.
		SELECT	intransit_time,
        	     	((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
		INTO	l_intransit_time, l_level
	     	FROM    mtl_interorg_ship_methods mism,
        	     	msc_regions_temp mrt
	     	WHERE   mism.from_location_id = p_from_location_id
	     	AND     mism.ship_method = p_ship_method
	     	AND     mism.to_region_id = mrt.region_id
	     	AND     mrt.session_id = p_session_id
	     	AND     mrt.partner_site_id = p_partner_site_id
	     	ORDER BY 2;

      END;
      return l_intransit_time;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         return null;
END src_interloc_transit_time;

-- savirine added parameters p_session_id and p_partner_site_id on Sep 24, 2001.

FUNCTION src_default_ship_method (
	p_from_location_id 		IN 	NUMBER,
	p_to_location_id 		IN 	NUMBER,
        p_session_id 			IN 	NUMBER := NULL,
        p_partner_site_id 		IN 	NUMBER := NULL)
return VARCHAR2 IS
l_ship_method     VARCHAR2(204);
l_level                 NUMBER;
BEGIN
     BEGIN
        SELECT ship_method
        INTO   l_ship_method
        FROM   mtl_interorg_ship_methods
        WHERE  from_location_id = p_from_location_id
        AND    to_location_id = p_to_location_id
        AND    default_flag = 1
        AND    rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN

             -- ngoel 9/25/2001, need to select most specific ship method based on regions.
	     -- bug 2974334. Change the SQL into static.
                SELECT	ship_method,
                        ((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
		INTO	l_ship_method, l_level
                FROM    mtl_interorg_ship_methods mism,
                        msc_regions_temp mrt
                WHERE   mism.from_location_id = p_from_location_id
                AND     mism.to_region_id = mrt.region_id
                AND     mrt.session_id = p_session_id
                AND     mrt.partner_site_id = p_partner_site_id
		AND	default_flag = 1
                ORDER BY 2;

      END;
      return l_ship_method;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         return null;
END src_default_ship_method;


FUNCTION src_ship_method (
	p_from_org_id 		IN 	NUMBER,
	p_to_org_id 		IN 	NUMBER
)
return VARCHAR2 IS
l_ship_method	VARCHAR2(30);
BEGIN
    -- bug 2974334. Change the SQL into static.
	select  ship_method
	into	l_ship_method
        from    mtl_interorg_ship_methods
        where   from_organization_id = p_from_org_id
        and     to_organization_id = p_to_org_id
        and     default_flag = 1
        and     rownum = 1;

    return l_ship_method;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         return null;
END src_ship_method;

-- savirine added parameters p_session_id and p_partner_site_id on Sep 24, 2001.

FUNCTION src_default_intransit_time(
	p_from_location_id 		IN 	NUMBER,
	p_to_location_id  		IN 	NUMBER,
        p_session_id 			IN 	NUMBER := NULL,
        p_partner_site_id 		IN 	NUMBER := NULL)
return NUMBER IS
l_intransit_time        NUMBER;
l_level                 NUMBER;
BEGIN
   BEGIN
	SELECT  intransit_time
	INTO    l_intransit_time
	FROM    mtl_interorg_ship_methods
	WHERE   from_location_id = p_from_location_id
	AND     to_location_id = p_to_location_id
	AND     default_flag = 1
	AND     rownum = 1;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN

             -- ngoel 9/25/2001, need to select most specific lead time based on regions
	     -- bug 2974334. Change the SQL into static.
		SELECT	intransit_time,
                        ((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
                INTO	l_intransit_time, l_level
		FROM    mtl_interorg_ship_methods mism,
                        msc_regions_temp mrt
                WHERE   mism.from_location_id = p_from_location_id
                AND     mism.default_flag = 1
                AND     mism.to_region_id = mrt.region_id
                AND     mrt.session_id = p_session_id
                AND     mrt.partner_site_id = p_partner_site_id
                ORDER BY 2;
    END;
    return l_intransit_time;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         return null;
END src_default_intransit_time;

FUNCTION src_intransit_time (
	p_from_org_id 			IN 	NUMBER,
	p_to_org_id 			IN 	NUMBER)
return NUMBER IS

l_intransit_time NUMBER;

BEGIN
    -- bug 2974334. Change the SQL into static.
	select	intransit_time
	into	l_intransit_time
        from    mtl_interorg_ship_methods
        where   from_organization_id = p_from_org_id
        and     to_organization_id = p_to_org_id
        and     default_flag = 1
        and     rownum = 1;

    return l_intransit_time;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
             return null;
END src_intransit_time;

FUNCTION src_prev_work_day ( p_organization_id   IN NUMBER,
                             p_date              IN DATE)
return DATE IS

l_return_date    DATE;
l_first_work_day	DATE; --bug3583705
l_last_work_day		DATE; --bug3583705

BEGIN
     -- Note: Compared to a similar function in MSC_CALENDAR
     -- the default of daily bucket is used here
     -- bug 2974334. Change the SQL into static.
	SELECT	cal.prior_date
	INTO	l_return_date
	FROM	bom_calendar_dates cal,
		mtl_parameters     org
	WHERE	cal.calendar_code = org.calendar_code
	AND	cal.exception_set_id = org.calendar_exception_set_id
	AND	cal.calendar_date = TRUNC(p_date)
	AND	org.organization_id = p_organization_id;
        RETURN l_return_date;
EXCEPTION
        WHEN NO_DATA_FOUND THEN --bug3583705
            IF MSC_CALENDAR.G_RETAIN_DATE = 'Y' THEN
                BEGIN
                    SELECT  min(calendar_date), max(calendar_date)
                    INTO    l_first_work_day, l_last_work_day
                    FROM    BOM_CALENDAR_DATES cal,
		            mtl_parameters     org
                    WHERE   cal.calendar_code = org.calendar_code
	            AND	    cal.exception_set_id = org.calendar_exception_set_id
	            AND	    org.organization_id = p_organization_id
                    AND     cal.seq_num is not null;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END;

                IF p_date >= l_last_work_day THEN
                    l_return_date := l_last_work_day;
                ELSIF p_date <= l_first_work_day THEN
                    l_return_date := l_first_work_day;
                ELSE
                    RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
            RETURN l_return_date;
END src_prev_work_day;

FUNCTION src_next_work_day ( p_organization_id   IN NUMBER,
                             p_date              IN DATE)
return DATE IS

l_return_date    DATE;
l_first_work_day	DATE; --bug3583705
l_last_work_day		DATE; --bug3583705
BEGIN
     -- Note: Compared to a similar function in MSC_CALENDAR
     -- the default of daily bucket is used here.


     -- bug 2974334. Change the SQL into static.
	SELECT	cal.next_date
	INTO	l_return_date
	FROM	bom_calendar_dates cal,
		mtl_parameters     org
	WHERE	cal.calendar_code = org.calendar_code
	AND	cal.exception_set_id = org.calendar_exception_set_id
	AND	cal.calendar_date = TRUNC(p_date)
	AND	org.organization_id = p_organization_id;

       RETURN l_return_date;
EXCEPTION
        WHEN NO_DATA_FOUND THEN --bug3583705
            IF MSC_CALENDAR.G_RETAIN_DATE = 'Y' THEN
                BEGIN
                    SELECT  min(calendar_date), max(calendar_date)
                    INTO    l_first_work_day, l_last_work_day
                    FROM    BOM_CALENDAR_DATES cal,
		            mtl_parameters     org
                    WHERE   cal.calendar_code = org.calendar_code
	            AND	    cal.exception_set_id = org.calendar_exception_set_id
	            AND	    org.organization_id = p_organization_id
                    AND     cal.seq_num is not null;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END;

                IF p_date >= l_last_work_day THEN
                    l_return_date := l_last_work_day;
                ELSIF p_date <= l_first_work_day THEN
                    l_return_date := l_first_work_day;
                ELSE
                    RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
            RETURN l_return_date;
END src_next_work_day;

-- dsting 2833417
FUNCTION src_date_offset ( p_organization_id   IN NUMBER,
                           p_date              IN DATE,
                           p_days              IN NUMBER
                         )
return DATE IS

l_return_date    DATE;
l_days           NUMBER;
l_first_work_day	DATE; --bug3583705
l_last_work_day		DATE; --bug3583705
BEGIN
     -- Note: Compared to a similar function in MSC_CALENDAR
     -- the default of daily bucket is used here


     IF p_days < 0 THEN
        l_days := FLOOR(p_days);
     ELSE
        l_days := CEIL(p_days);
     END IF;

	-- bug 2974334. Change the SQL into static. Also combined the 2 SQL's into one.
	SELECT	cal2.calendar_date
	INTO	l_return_date
	FROM	bom_calendar_dates cal1,
		bom_calendar_dates cal2,
		mtl_parameters     org
	WHERE	cal1.calendar_code = org.calendar_code
	AND	cal1.exception_set_id = org.calendar_exception_set_id
	AND	cal1.calendar_date = TRUNC(p_date)
	AND	org.organization_id = p_organization_id
	AND	cal2.exception_set_id = cal1.exception_set_id
	AND	cal2.calendar_code = cal1.calendar_code
	AND	cal2.seq_num = cal1.prior_seq_num + l_days;
        RETURN l_return_date;

EXCEPTION
        WHEN NO_DATA_FOUND THEN --bug3583705
            IF MSC_CALENDAR.G_RETAIN_DATE = 'Y' THEN
                BEGIN
                    SELECT  min(calendar_date), max(calendar_date)
                    INTO    l_first_work_day, l_last_work_day
                    FROM    BOM_CALENDAR_DATES cal,
		            mtl_parameters     org
                    WHERE   cal.calendar_code = org.calendar_code
	            AND	    cal.exception_set_id = org.calendar_exception_set_id
	            AND	    org.organization_id = p_organization_id
                    AND     cal.seq_num is not null;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END;

                IF p_date >= l_last_work_day THEN
                    l_return_date := l_last_work_day;
                ELSIF p_date <= l_first_work_day THEN
                    l_return_date := l_first_work_day;
                ELSE
                    RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
            RETURN l_return_date;
END src_date_offset;

-- ngoel 7/31/2001, modified to accept p_index as a parameter to determine
-- index length by which ATP_REC_TYP needs to be extended, default is 1.

PROCEDURE Extend_Atp (
  p_atp_tab             IN OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2,
  p_index		IN	 NUMBER  := 1
) IS
Begin
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('***** Begin Extend_Atp Procedure *****');
   END IF;

                    x_return_status := FND_API.G_RET_STS_SUCCESS;
                    msc_atp_global.extend_atp(p_atp_tab,
                                              x_return_status,
                                              p_index);
/* --s_cto_enhc
                    p_atp_tab.Row_Id.Extend(p_index);
                    p_atp_tab.Instance_Id.Extend(p_index);
                    p_atp_tab.Inventory_Item_Id.Extend(p_index);
                    p_atp_tab.Inventory_Item_Name.Extend(p_index);
                    p_atp_tab.Source_Organization_Id.Extend(p_index);
                    p_atp_tab.Organization_Id.Extend(p_index);
                    p_atp_tab.Source_Organization_Code.Extend(p_index);
                    p_atp_tab.Identifier.Extend(p_index);
                    p_atp_tab.Demand_Source_Header_Id.Extend(p_index);
		    p_atp_tab.Demand_Source_Delivery.Extend(p_index);
 		    p_atp_tab.Demand_Source_Type.Extend(p_index);
                    p_atp_tab.Scenario_Id.Extend(p_index);
                    p_atp_tab.Calling_Module.Extend(p_index);
                    p_atp_tab.Customer_Id.Extend(p_index);
                    p_atp_tab.Customer_Site_Id.Extend(p_index);
                    p_atp_tab.Destination_Time_Zone.Extend(p_index);
                    p_atp_tab.Quantity_Ordered.Extend(p_index);
                    p_atp_tab.Quantity_UOM.Extend(p_index);
                    p_atp_tab.Requested_Ship_Date.Extend(p_index);
                    p_atp_tab.Requested_Arrival_Date.Extend(p_index);
                    p_atp_tab.Earliest_Acceptable_Date.Extend(p_index);
                    p_atp_tab.Latest_Acceptable_Date.Extend(p_index);
                    p_atp_tab.Delivery_Lead_Time.Extend(p_index);
                    p_atp_tab.Freight_Carrier.Extend(p_index);
                    p_atp_tab.Ship_Method.Extend(p_index);
                    p_atp_tab.Demand_Class.Extend(p_index);
                    p_atp_tab.Ship_Set_Name.Extend(p_index);
                    p_atp_tab.Arrival_Set_Name.Extend(p_index);
                    p_atp_tab.Override_Flag.Extend(p_index);
                    p_atp_tab.Action.Extend(p_index);
                    p_atp_tab.Ship_Date.Extend(p_index);
		    p_atp_tab.Arrival_Date.Extend(p_index);
                    p_atp_tab.Available_Quantity.Extend(p_index);
                    p_atp_tab.Requested_Date_Quantity.Extend(p_index);
                    p_atp_tab.Group_Ship_Date.Extend(p_index);
                    p_atp_tab.Group_Arrival_Date.Extend(p_index);
                    p_atp_tab.Vendor_Id.Extend(p_index);
                    p_atp_tab.Vendor_Name.Extend(p_index);
                    p_atp_tab.Vendor_Site_Id.Extend(p_index);
                    p_atp_tab.Vendor_Site_Name.Extend(p_index);
                    p_atp_tab.Insert_Flag.Extend(p_index);
                    p_atp_tab.OE_Flag.Extend(p_index);
                    p_atp_tab.Error_Code.Extend(p_index);
                    p_atp_tab.Atp_Lead_Time.Extend(p_index);
                    p_atp_tab.Message.Extend(p_index);
                    p_atp_tab.End_Pegging_Id.Extend(p_index);
                    p_atp_tab.Order_Number.Extend(p_index);
                    p_atp_tab.Old_Source_Organization_Id.Extend(p_index);
                    p_atp_tab.Old_Demand_Class.Extend(p_index);
                    p_atp_tab.ato_delete_flag.Extend(p_index);		-- added by ngoel 6/15/2001
                    p_atp_tab.attribute_05.Extend(p_index);      	-- added by ngoel 7/31/2001
                    p_atp_tab.attribute_06.Extend(p_index);      	-- added by ngoel 8/09/2001
                    p_atp_tab.attribute_07.Extend(p_index);      	-- added for bug 2392456
                    p_atp_tab.attribute_01.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_name.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_class.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_location.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_country.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_state.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_city.Extend(p_index);      	-- added by ngoel 10/12/2001
                    p_atp_tab.customer_postal_code.Extend(p_index);     -- added by ngoel 10/12/2001

                    --- added for product substitution
                    p_atp_tab.substitution_typ_code.Extend(p_index);
                    p_atp_tab.req_item_detail_flag.Extend(p_index);
                    p_atp_tab.request_item_id.Extend(p_index);
                    p_atp_tab.req_item_req_date_qty.Extend(p_index);
                    p_atp_tab.req_item_available_date.Extend(p_index);
                    p_atp_tab.req_item_available_date_qty.Extend(p_index);
                    p_atp_tab.request_item_name.Extend(p_index);
                    p_atp_tab.old_inventory_item_id.Extend(p_index);
                    p_atp_tab.sales_rep.Extend(p_index);
                    p_atp_tab.customer_contact.Extend(p_index);
                    p_atp_tab.subst_flag.Extend(p_index);

                    --diag_atp
                    p_atp_tab.attribute_02.Extend(p_index);

                    -- 24x7 Support
                    p_atp_tab.attribute_04.Extend(p_index);
                    p_atp_tab.attribute_08.Extend(p_index);             -- 24x7
 e_cto_ench */
--   msc_sch_wb.atp_debug('***** End Extend_Atp Procedure *****');

END Extend_Atp;


PROCEDURE Assign_Atp_Input_Rec (
  p_atp_table          	IN       MRP_ATP_PUB.ATP_Rec_Typ,
  p_index         	IN       NUMBER,
  x_atp_table           IN OUT   NOCOPY MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status	OUT	 NoCopy VARCHAR2
) IS

l_count         PLS_INTEGER;
Begin
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** Begin Assign_Atp_Input_Rec Procedure *****');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- copy the p_index th elements in p_atp_table and append it to x_atp_table

    l_count := x_atp_table.Action.COUNT;

    MSC_SATP_FUNC.Extend_Atp(x_atp_table, x_return_status, 1);

    -- only under old OE we will have p_atp_table.Row_Id populated.

    IF p_atp_table.Row_Id.Exists(p_index) THEN
      x_atp_table.Row_Id(l_count + 1):= p_atp_table.Row_Id(p_index);
    END IF;

    IF p_atp_table.Instance_Id.Exists(p_index) THEN
      x_atp_table.Instance_Id(l_count + 1):= p_atp_table.Instance_Id(p_index);
    END IF;

    x_atp_table.Inventory_Item_Id(l_count + 1):=
              p_atp_table.Inventory_Item_Id(p_index);

    IF p_atp_table.Inventory_Item_Name.Exists(p_index) THEN
      x_atp_table.Inventory_Item_Name(l_count + 1):=
              p_atp_table.Inventory_Item_Name(p_index);
    END IF;

    IF p_atp_table.Source_Organization_Code.Exists(p_index) THEN
      x_atp_table.Source_Organization_code(l_count + 1) :=
              p_atp_table.Source_Organization_code(p_index);
    END IF;
    x_atp_table.Source_Organization_Id(l_count + 1):=
              p_atp_table.Source_Organization_Id(p_index);
    IF p_atp_table.Organization_Id.Exists(p_index) THEN
      x_atp_table.Organization_Id(l_count + 1) :=
              p_atp_table.Organization_Id(p_index);
    END IF;

    x_atp_table.Identifier(l_count + 1):= p_atp_table.Identifier(p_index);
    x_atp_table.Customer_Id(l_count + 1):= p_atp_table.Customer_Id(p_index);
    x_atp_table.Customer_Site_Id(l_count + 1):=
              p_atp_table.Customer_Site_Id(p_index);
    x_atp_table.Destination_Time_Zone(l_count + 1):=
              p_atp_table.Destination_Time_Zone(p_index);
    x_atp_table.Quantity_Ordered(l_count + 1):=
              p_atp_table.Quantity_Ordered(p_index);
    x_atp_table.Quantity_UOM(l_count + 1):=
              p_atp_table.Quantity_UOM(p_index);
    x_atp_table.Requested_Ship_Date(l_count + 1):=
              p_atp_table.Requested_Ship_Date(p_index);
    x_atp_table.Requested_Arrival_Date(l_count + 1):=
              p_atp_table.Requested_Arrival_Date(p_index);
    IF p_atp_table.Earliest_Acceptable_Date.COUNT > 0 THEN
      x_atp_table.Earliest_Acceptable_Date(l_count + 1):=
              p_atp_table.Earliest_Acceptable_Date(p_index);
    END IF;
    x_atp_table.Latest_Acceptable_Date(l_count + 1):=
              p_atp_table.Latest_Acceptable_Date(p_index);
    x_atp_table.Delivery_Lead_Time(l_count + 1):=
              p_atp_table.Delivery_Lead_Time(p_index);
    x_atp_table.Freight_Carrier(l_count + 1):=
              p_atp_table.Freight_Carrier(p_index);
    x_atp_table.Ship_Method(l_count + 1):=
              p_atp_table.Ship_Method(p_index);
    x_atp_table.Demand_Class(l_count + 1):=
              p_atp_table.Demand_Class(p_index);
    x_atp_table.Ship_Set_Name(l_count + 1):=
	      p_atp_table.Ship_Set_Name(p_index);
    x_atp_table.Arrival_Set_Name(l_count + 1):=
              p_atp_table.Arrival_Set_Name(p_index);
    x_atp_table.Override_Flag(l_count + 1):=
              p_atp_table.Override_Flag(p_index);
    x_atp_table.Action(l_count + 1):= p_atp_table.Action(p_index);
    x_atp_table.Insert_Flag(l_count + 1):= p_atp_table.Insert_Flag(p_index);

    IF p_atp_table.Calling_Module.Exists(p_index) THEN
      x_atp_table.Calling_Module(l_count+1) :=
              p_atp_table.Calling_Module(p_index);
    END IF;

    IF p_atp_table.Scenario_Id.Exists(p_index) THEN
      x_atp_table.Scenario_Id(l_count + 1):=
              p_atp_table.Scenario_Id(p_index);
    END IF;

    IF p_atp_table.Ship_Date.Exists(p_index) THEN
      x_atp_table.Ship_Date(l_count+1):=
              p_atp_table.Ship_Date(p_index);
    END IF;
 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Extend_Atp: ' || 'test1 = '||1);
 END IF;
    IF p_atp_table.arrival_date.Exists(p_index) THEN
      x_atp_table.arrival_Date(l_count+1):=
              p_atp_table.arrival_date(p_index);
    END IF;

    IF p_atp_table.Available_Quantity.Exists(p_index) THEN
      x_atp_table.Available_Quantity(l_count + 1):=
              p_atp_table.Available_Quantity(p_index);
    END IF;

    IF p_atp_table.Requested_Date_Quantity.Exists(p_index) THEN
      x_atp_table.Requested_Date_Quantity(l_count + 1):=
              p_atp_table.Requested_Date_Quantity(p_index);
    END IF;

    IF p_atp_table.Group_Ship_Date.Exists(p_index) THEN
      x_atp_table.Group_Ship_Date(l_count + 1):=
              p_atp_table.Group_Ship_Date(p_index);
    END IF;

    IF p_atp_table.Group_Arrival_Date.Exists(p_index) THEN
      x_atp_table.Group_Arrival_Date(l_count + 1):=
              p_atp_table.Group_Arrival_Date(p_index);
    END IF;

    IF p_atp_table.Vendor_Id.Exists(p_index) THEN
      x_atp_table.Vendor_Id(l_count + 1):=
              p_atp_table.Vendor_Id(p_index);
    END IF;

    IF p_atp_table.Vendor_Name.Exists(p_index) THEN
      x_atp_table.Vendor_Name(l_count + 1):=
              p_atp_table.Vendor_Name(p_index);
    END IF;

    IF p_atp_table.Vendor_Site_Id.Exists(p_index) THEN
      x_atp_table.Vendor_Site_Id(l_count + 1):=
              p_atp_table.Vendor_Site_Id(p_index);
    END IF;

    IF p_atp_table.Vendor_Site_Name.Exists(p_index) THEN
      x_atp_table.Vendor_Site_Name(l_count + 1):=
              p_atp_table.Vendor_Site_Name(p_index);
    END IF;

    IF p_atp_table.Error_Code.Exists(p_index) THEN
      x_atp_table.Error_Code(l_count + 1):=
              p_atp_table.Error_Code(p_index);
    END IF;

    IF p_atp_table.Message.Exists(p_index) THEN
      x_atp_table.Message(l_count + 1):= p_atp_table.Message(p_index);
    END IF;

    IF p_atp_table.OE_Flag.Exists(p_index) THEN
      x_atp_table.OE_Flag(l_count + 1):= p_atp_table.OE_Flag(p_index);
    END IF;

    IF p_atp_table.Atp_Lead_Time.Exists(p_index) THEN
      x_atp_table.Atp_Lead_Time(l_count + 1):=
       p_atp_table.Atp_Lead_Time(p_index);
    END IF;

    IF p_atp_table.Demand_Source_Header_Id.Exists(p_index) THEN
      x_atp_table.Demand_Source_Header_Id(l_count + 1):=
       p_atp_table.Demand_Source_Header_Id(p_index);
    END IF;

    IF p_atp_table.Demand_Source_Delivery.Exists(p_index) THEN
      x_atp_table.Demand_Source_Delivery(l_count + 1):=
       p_atp_table.Demand_Source_Delivery(p_index);
    END IF;

    IF p_atp_table.Demand_Source_Type.Exists(p_index) THEN
      x_atp_table.Demand_Source_Type(l_count + 1):=
       p_atp_table.Demand_Source_Type(p_index);
    END IF;

    IF p_atp_table.End_Pegging_Id.Exists(p_index) THEN
      x_atp_table.End_Pegging_Id(l_count + 1):=
       p_atp_table.End_Pegging_Id(p_index);
    END IF;

    IF p_atp_table.Order_Number.Exists(p_index) THEN
      x_atp_table.Order_Number(l_count + 1):=
       p_atp_table.Order_Number(p_index);

      -- 24x7 Bug 2840734
      if (NVL(MSC_ATP_PVT.G_SYNC_ATP_CHECK,'N') = 'Y') AND
                (p_atp_table.Order_Number(p_index) is NULL) AND
                (p_atp_table.attribute_08(p_index) is not NULL) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Calling 24x7 SO Processing');
            END IF;
            MSC_ATP_24x7.Parse_Sales_Order_Number (p_atp_table.attribute_08(p_index),
                                                   x_atp_table.Order_number(l_count + 1)
                                                  );
      end if;
    END IF;

    IF p_atp_table.Old_Source_Organization_Id.Exists(p_index) THEN
      x_atp_table.Old_Source_Organization_Id(l_count + 1) :=
              p_atp_table.Old_Source_Organization_Id(p_index);
    END IF;

    IF p_atp_table.Old_Demand_Class.Exists(p_index) THEN
      x_atp_table.Old_Demand_Class(l_count + 1):=
              p_atp_table.Old_Demand_Class(p_index);
    END IF;

    IF p_atp_table.ato_delete_flag.Exists(p_index) THEN
      x_atp_table.ato_delete_flag(l_count + 1):=
              p_atp_table.ato_delete_flag(p_index);
    END IF;

    IF p_atp_table.attribute_05.Exists(p_index) THEN
      x_atp_table.attribute_05(l_count + 1):=
              p_atp_table.attribute_05(p_index);
    END IF;

    IF p_atp_table.attribute_06.Exists(p_index) THEN
      x_atp_table.attribute_06(l_count + 1):=
              p_atp_table.attribute_06(p_index);
    END IF;

    -- changes for 2392456
    IF p_atp_table.attribute_07.Exists(p_index) THEN
      x_atp_table.attribute_07(l_count + 1):=
              p_atp_table.attribute_07(p_index);
    END IF;
   --plan by request date
    IF p_atp_table.original_request_date.COUNT > 0 THEN
    x_atp_table.original_request_date(l_count + 1):=
    	      p_atp_table.original_request_date(p_index);
    END IF;

    IF p_atp_table.ship_set_name.COUNT > 0 THEN
    x_atp_table.ship_set_name(l_count + 1):=
    	      p_atp_table.ship_set_name(p_index);
    END IF;

    IF p_atp_table.arrival_set_name.COUNT > 0 THEN
    x_atp_table.arrival_set_name(l_count + 1):=
    	      p_atp_table.arrival_set_name(p_index);
    END IF;
    IF p_atp_table.override_flag.COUNT > 0 THEN
    x_atp_table.arrival_set_name(l_count + 1):=
    	      p_atp_table.arrival_set_name(p_index);
    END IF;
    --end of plan by request date change
    --- subst chnages
    IF p_atp_table.substitution_typ_code.Exists(p_index) THEN
      x_atp_table.substitution_typ_code(l_count + 1):=
              p_atp_table.substitution_typ_code(p_index);
    END IF;


    IF p_atp_table.req_item_detail_flag.Exists(p_index) THEN
      x_atp_table.req_item_detail_flag(l_count + 1):=
              p_atp_table.req_item_detail_flag(p_index);
    END IF;

    IF p_atp_table.request_item_id.Exists(p_index) THEN
      x_atp_table.request_item_id(l_count + 1):=
              p_atp_table.request_item_id(p_index);
    END IF;

    IF p_atp_table.req_item_req_date_qty.Exists(p_index) THEN
      x_atp_table.req_item_req_date_qty(l_count + 1):=
              p_atp_table.req_item_req_date_qty(p_index);
    END IF;

    IF p_atp_table.req_item_available_date.Exists(p_index) THEN
      x_atp_table.req_item_available_date(l_count + 1):=
              p_atp_table.req_item_available_date(p_index);
    END IF;

    IF p_atp_table.req_item_available_date_qty.Exists(p_index) THEN
      x_atp_table.req_item_available_date_qty(l_count + 1):=
              p_atp_table.req_item_available_date_qty(p_index);
    END IF;

    IF p_atp_table.request_item_name.Exists(p_index) THEN
      x_atp_table.request_item_name(l_count + 1):=
              p_atp_table.request_item_name(p_index);
    END IF;

    IF p_atp_table.old_inventory_item_id.Exists(p_index) THEN
         x_atp_table.old_inventory_item_id(l_count +1) :=
             p_atp_table.old_inventory_item_id(p_index);
    END IF;

    IF p_atp_table.sales_rep.Exists(p_index) THEN
         x_atp_table.sales_rep(l_count +1) :=
             p_atp_table.sales_rep(p_index);
    END IF;

    IF p_atp_table.customer_contact.Exists(p_index) THEN
         x_atp_table.customer_contact(l_count +1) :=
             p_atp_table.customer_contact(p_index);
    END IF;
    IF p_atp_table.subst_flag.Exists(p_index) THEN
         x_atp_table.subst_flag(l_count +1) :=
             p_atp_table.subst_flag(p_index);
    END IF;

    --diag_atp
    IF p_atp_table.attribute_02.Exists(p_index) THEN
         x_atp_table.attribute_02(l_count +1) :=
             p_atp_table.attribute_02(p_index);
    END IF;

    -- 24x7 Changes
    IF p_atp_table.attribute_04.Exists(p_index) THEN
      x_atp_table.attribute_04(l_count + 1):=
              p_atp_table.attribute_04(p_index);
    END IF;

    IF p_atp_table.attribute_08.Exists(p_index) THEN
      x_atp_table.attribute_08(l_count + 1):=
              p_atp_table.attribute_08(p_index);
    END IF;

    IF p_atp_table.sequence_number.Exists(p_index) THEN
      x_atp_table.sequence_number(l_count + 1):=
              p_atp_table.sequence_number(p_index);
    END IF;

    ----s_cto_rearch
    IF p_atp_table.Top_Model_line_id.Exists(p_index) THEN
       x_atp_table.Top_Model_line_id(l_count + 1):=
                 p_atp_table.Top_Model_line_id(p_index);

    END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Extend_Atp: ' || 'test1 = '||2);
 END IF;
    IF p_atp_table.ATO_Parent_Model_Line_Id.Exists(p_index) THEN
       x_atp_table.ATO_Parent_Model_Line_Id(l_count + 1):=
                 p_atp_table.ATO_Parent_Model_Line_Id(p_index);
    END IF;

    IF p_atp_table.ATO_Model_Line_Id.Exists(p_index) THEN
       x_atp_table.ATO_Model_Line_Id(l_count + 1):=
                 p_atp_table.ATO_Model_Line_Id(p_index);
    END IF;

    IF p_atp_table.Parent_line_id.Exists(p_index) THEN
       x_atp_table.Parent_line_id(l_count + 1):=
                 p_atp_table.Parent_line_id(p_index);
    END IF;

    IF p_atp_table.match_item_id.Exists(p_index) THEN
       x_atp_table.match_item_id(l_count + 1):=
                 p_atp_table.match_item_id(p_index);
    END IF;

    IF p_atp_table.matched_item_name.Exists(p_index) THEN
       x_atp_table.matched_item_name(l_count + 1):=
                 p_atp_table.matched_item_name(p_index);
    END IF;

    IF p_atp_table.Config_item_line_id.Exists(p_index) THEN
       x_atp_table.Config_item_line_id(l_count + 1):=
                 p_atp_table.Config_item_line_id(p_index);
    END IF;

    IF p_atp_table.Validation_Org.Exists(p_index) THEN
       x_atp_table.Validation_Org(l_count + 1):=
                 p_atp_table.Validation_Org(p_index);
    END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Extend_Atp: ' || 'test1 = '||3);
 END IF;
    IF p_atp_table.Component_Sequence_ID.Exists(p_index) THEN
       x_atp_table.Component_Sequence_ID(l_count + 1):=
                 p_atp_table.Component_Sequence_ID(p_index);
    END IF;

    IF p_atp_table.Component_Code.Exists(p_index) THEN
       x_atp_table.Component_Code(l_count + 1):=
                 p_atp_table.Component_Code(p_index);
    END IF;

    IF p_atp_table.line_number.Exists(p_index) THEN
       x_atp_table.line_number(l_count + 1):=
                 p_atp_table.line_number(p_index);
    END IF;

    IF p_atp_table.included_item_flag.Exists(p_index) THEN
       x_atp_table.included_item_flag(l_count + 1):=
                 p_atp_table.included_item_flag(p_index);
    END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Extend_Atp: ' || 'test1 = '||4);
 END IF;

    IF p_atp_table.atp_flag.Exists(p_index) THEN
       x_atp_table.atp_flag(l_count + 1):=
                 p_atp_table.atp_flag(p_index);
    END IF;

    IF p_atp_table.atp_components_flag.Exists(p_index) THEN
       x_atp_table.atp_components_flag(l_count + 1):=
                 p_atp_table.atp_components_flag(p_index);
    END IF;

    IF p_atp_table.wip_supply_type.Exists(p_index) THEN
       x_atp_table.wip_supply_type(l_count + 1):=
                 p_atp_table.wip_supply_type(p_index);
    END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Extend_Atp: ' || 'test1 = '||5);
 END IF;
    IF p_atp_table.bom_item_type.Exists(p_index) THEN
       x_atp_table.bom_item_type(l_count + 1):=
                 p_atp_table.bom_item_type(p_index);
    END IF;

    IF p_atp_table.mandatory_item_flag.Exists(p_index) THEN
       x_atp_table.mandatory_item_flag(l_count + 1):=
                 p_atp_table.mandatory_item_flag(p_index);
    END IF;


    IF p_atp_table.attribute_11.Exists(p_index) THEN
       x_atp_table.attribute_11(l_count + 1):=
                 p_atp_table.attribute_11(p_index);
    END IF;

    IF p_atp_table.attribute_12.Exists(p_index) THEN
       x_atp_table.attribute_12(l_count + 1):=
                 p_atp_table.attribute_12(p_index);
    END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug('Extend_Atp: ' || 'test1 = '||1);
 END IF;

   IF p_atp_table.attribute_13.Exists(p_index) THEN
       x_atp_table.attribute_13(l_count + 1):=
                 p_atp_table.attribute_13(p_index);
    END IF;

    IF p_atp_table.attribute_14.Exists(p_index) THEN
       x_atp_table.attribute_14(l_count + 1):=
                 p_atp_table.attribute_14(p_index);
    END IF;

    IF p_atp_table.attribute_15.Exists(p_index) THEN
       x_atp_table.attribute_15(l_count + 1):=
                 p_atp_table.attribute_15(p_index);
    END IF;

    IF p_atp_table.attribute_16.Exists(p_index) THEN
       x_atp_table.attribute_16(l_count + 1):=
                 p_atp_table.attribute_16(p_index);
    END IF;

    IF p_atp_table.attribute_17.Exists(p_index) THEN
       x_atp_table.attribute_17(l_count + 1):=
                 p_atp_table.attribute_17(p_index);
    END IF;

    IF p_atp_table.attribute_18.Exists(p_index) THEN
       x_atp_table.attribute_18(l_count + 1):=
                 p_atp_table.attribute_18(p_index);
    END IF;

    IF p_atp_table.attribute_19.Exists(p_index) THEN
       x_atp_table.attribute_19(l_count + 1):=
                 p_atp_table.attribute_19(p_index);
    END IF;

    IF p_atp_table.attribute_20.Exists(p_index) THEN
       x_atp_table.attribute_20(l_count + 1):=
                 p_atp_table.attribute_20(p_index);
    END IF;

    IF p_atp_table.Attribute_21.Exists(p_index) THEN
       x_atp_table.Attribute_21(l_count + 1):=
                 p_atp_table.Attribute_21(p_index);
    END IF;

    IF p_atp_table.attribute_22.Exists(p_index) THEN
       x_atp_table.attribute_22(l_count + 1):=
                 p_atp_table.attribute_22(p_index);
    END IF;

    IF p_atp_table.attribute_23.Exists(p_index) THEN
       x_atp_table.attribute_23(l_count + 1):=
                 p_atp_table.attribute_23(p_index);
    END IF;

    IF p_atp_table.attribute_24.Exists(p_index) THEN
       x_atp_table.attribute_24(l_count + 1):=
                 p_atp_table.attribute_24(p_index);
    END IF;

    IF p_atp_table.attribute_25.Exists(p_index) THEN
       x_atp_table.attribute_25(l_count + 1):=
                 p_atp_table.attribute_25(p_index);
    END IF;

    IF p_atp_table.attribute_26.Exists(p_index) THEN
       x_atp_table.attribute_26(l_count + 1):=
                 p_atp_table.attribute_26(p_index);
    END IF;

    IF p_atp_table.attribute_27.Exists(p_index) THEN
       x_atp_table.attribute_27(l_count + 1):=
                 p_atp_table.attribute_27(p_index);
    END IF;

    IF p_atp_table.attribute_28.Exists(p_index) THEN
       x_atp_table.attribute_28(l_count + 1):=
                 p_atp_table.attribute_28(p_index);
    END IF;

    IF p_atp_table.attribute_29.Exists(p_index) THEN
       x_atp_table.attribute_29(l_count + 1):=
                 p_atp_table.attribute_29(p_index);
    END IF;

    IF p_atp_table.attribute_30.Exists(p_index) THEN
       x_atp_table.attribute_30(l_count + 1):=
                 p_atp_table.attribute_30(p_index);
    END IF;

    IF p_atp_table.atf_date.Exists(p_index) THEN
       x_atp_table.atf_date(l_count + 1):=
                 p_atp_table.atf_date(p_index);
    END IF;

    -- Bug 3449812
    IF p_atp_table.internal_org_id.Exists(p_index) THEN
       x_atp_table.internal_org_id(l_count + 1):=
                 p_atp_table.internal_org_id(p_index);
    END IF;

    --2814895
    IF p_atp_table.customer_country.Exists(p_index) THEN
      x_atp_table.customer_country(l_count + 1):=
              p_atp_table.customer_country(p_index);
    END IF;
    IF p_atp_table.customer_city.Exists(p_index) THEN
      x_atp_table.customer_city(l_count + 1):=
              p_atp_table.customer_city(p_index);
    END IF;
    IF p_atp_table.customer_state.Exists(p_index) THEN
      x_atp_table.customer_state(l_count + 1):=
              p_atp_table.customer_state(p_index);
    END IF;
    IF p_atp_table.customer_postal_code.Exists(p_index) THEN
      x_atp_table.customer_postal_code(l_count + 1):=
              p_atp_table.customer_postal_code(p_index);
    END IF;

    IF p_atp_table.party_site_id.Exists(p_index) THEN
      x_atp_table.party_site_id(l_count + 1):=
              p_atp_table.party_site_id(p_index);
    END IF;


    -- Bug 3328421
    IF p_atp_table.first_valid_ship_arrival_date.Exists(p_index) THEN
       x_atp_table.first_valid_ship_arrival_date(l_count + 1):=
                 p_atp_table.first_valid_ship_arrival_date(p_index);
    END IF;
    --Bug 4500382
    IF p_atp_table.part_of_set.Exists(p_index) THEN
       x_atp_table.part_of_set(l_count + 1):=
          p_atp_table.part_of_set(p_index);
    --4500382 ENDS
    END IF;
    ---e_cto_rearch
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** End Assign_Atp_Input_Rec Procedure *****');
    END IF;
END Assign_Atp_Input_Rec;


PROCEDURE Assign_Atp_Output_Rec (
  p_atp_table          	IN       MRP_ATP_PUB.ATP_Rec_Typ,
  x_atp_table           IN OUT   NOCOPY MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status	OUT	 NoCopy VARCHAR2
) IS

l_atp_count    	PLS_INTEGER;
l_count         PLS_INTEGER;
Begin

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Begin Assign_Atp_Output_Rec Procedure *****');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- append the p_atp_table to x_atp_tablecopy

  l_count := x_atp_table.Action.COUNT;

  IF nvl(l_count, 0) > 0 THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Assign_Atp_Output_Rec: ' || 'x_atp_table.Action : ' || x_atp_table.Action(l_count));
     END IF;
  END IF;

  FOR l_atp_count in 1..p_atp_table.Action.COUNT LOOP

    MSC_SATP_FUNC.Extend_Atp(x_atp_table, x_return_status, 1);

    x_atp_table.Row_Id(l_count + l_atp_count):= p_atp_table.Row_Id(l_atp_count);
    x_atp_table.Instance_Id(l_count + l_atp_count):=
              p_atp_table.Instance_Id(l_atp_count);
    x_atp_table.Inventory_Item_Id(l_count + l_atp_count):=
              p_atp_table.Inventory_Item_Id(l_atp_count);
    x_atp_table.Inventory_Item_Name(l_count + l_atp_count):=
              p_atp_table.Inventory_Item_Name(l_atp_count);
    x_atp_table.Source_Organization_Id(l_count + l_atp_count):=
              p_atp_table.Source_Organization_Id(l_atp_count);
    x_atp_table.Organization_Id(l_count + l_atp_count):=
              p_atp_table.Organization_Id(l_atp_count);
    x_atp_table.Source_Organization_Code(l_count + l_atp_count):=
              p_atp_table.Source_Organization_Code(l_atp_count);
    x_atp_table.Identifier(l_count + l_atp_count):=
              p_atp_table.Identifier(l_atp_count);
    x_atp_table.Calling_Module(l_count+l_atp_count) :=
              p_atp_table.Calling_Module(l_atp_count);
    x_atp_table.Scenario_Id(l_count + l_atp_count):=
              p_atp_table.Scenario_Id(l_atp_count);
    x_atp_table.Customer_Id(l_count + l_atp_count):=
              p_atp_table.Customer_Id(l_atp_count);
    x_atp_table.Customer_Site_Id(l_count + l_atp_count):=
              p_atp_table.Customer_Site_Id(l_atp_count);
    x_atp_table.Destination_Time_Zone(l_count + l_atp_count):=
              p_atp_table.Destination_Time_Zone(l_atp_count);
    x_atp_table.Quantity_Ordered(l_count + l_atp_count):=
              p_atp_table.Quantity_Ordered(l_atp_count);
    x_atp_table.Quantity_UOM(l_count + l_atp_count):=
              p_atp_table.Quantity_UOM(l_atp_count);
    x_atp_table.Requested_Ship_Date(l_count + l_atp_count):=
              p_atp_table.Requested_Ship_Date(l_atp_count);
    x_atp_table.Requested_Arrival_Date(l_count + l_atp_count):=
              p_atp_table.Requested_Arrival_Date(l_atp_count);
    x_atp_table.Earliest_Acceptable_Date(l_count + l_atp_count):=
              p_atp_table.Earliest_Acceptable_Date(l_atp_count);
    x_atp_table.Latest_Acceptable_Date(l_count + l_atp_count):=
              p_atp_table.Latest_Acceptable_Date(l_atp_count);
    x_atp_table.Delivery_Lead_Time(l_count + l_atp_count):=
              p_atp_table.Delivery_Lead_Time(l_atp_count);
    x_atp_table.Freight_Carrier(l_count + l_atp_count):=
              p_atp_table.Freight_Carrier(l_atp_count);
    x_atp_table.Ship_Method(l_count + l_atp_count):=
              p_atp_table.Ship_Method(l_atp_count);
    x_atp_table.Demand_Class(l_count + l_atp_count):=
              p_atp_table.Demand_Class(l_atp_count);
    x_atp_table.Ship_Set_Name(l_count + l_atp_count):=
	      p_atp_table.Ship_Set_Name(l_atp_count);
    x_atp_table.Arrival_Set_Name(l_count + l_atp_count):=
              p_atp_table.Arrival_Set_Name(l_atp_count);
    x_atp_table.Override_Flag(l_count + l_atp_count):=
              p_atp_table.Override_Flag(l_atp_count);
    x_atp_table.Action(l_count + l_atp_count):= p_atp_table.Action(l_atp_count);
    x_atp_table.Ship_Date(l_count + l_atp_count):=
              p_atp_table.Ship_Date(l_atp_count);
    x_atp_table.Arrival_Date(l_count + l_atp_count):=
              p_atp_table.Arrival_Date(l_atp_count);
    x_atp_table.Available_Quantity(l_count + l_atp_count):=
              p_atp_table.Available_Quantity(l_atp_count);
    x_atp_table.Requested_Date_Quantity(l_count + l_atp_count):=
              p_atp_table.Requested_Date_Quantity(l_atp_count);
    x_atp_table.Group_Ship_Date(l_count + l_atp_count):=
              p_atp_table.Group_Ship_Date(l_atp_count);
    x_atp_table.Group_Arrival_Date(l_count + l_atp_count):=
              p_atp_table.Group_Arrival_Date(l_atp_count);
    x_atp_table.Vendor_Id(l_count + l_atp_count):=
              p_atp_table.Vendor_Id(l_atp_count);
    x_atp_table.Vendor_Name(l_count + l_atp_count):=
              p_atp_table.Vendor_Name(l_atp_count);
    x_atp_table.Vendor_Site_Id(l_count + l_atp_count):=
              p_atp_table.Vendor_Site_Id(l_atp_count);
    x_atp_table.Vendor_Site_Name(l_count + l_atp_count):=
              p_atp_table.Vendor_Site_Name(l_atp_count);
    x_atp_table.Insert_Flag(l_count + l_atp_count):=
              p_atp_table.Insert_Flag(l_atp_count);
    x_atp_table.Error_Code(l_count + l_atp_count):=
              p_atp_table.Error_Code(l_atp_count);
    x_atp_table.Message(l_count + l_atp_count):=
              p_atp_table.Message(l_atp_count);
    x_atp_table.OE_Flag(l_count + l_atp_count):=
              p_atp_table.OE_Flag(l_atp_count);
    x_atp_table.Atp_Lead_Time(l_count + l_atp_count):=
              p_atp_table.Atp_Lead_Time(l_atp_count);
    x_atp_table.Demand_Source_Header_Id(l_count + l_atp_count):=
              p_atp_table.Demand_Source_Header_Id(l_atp_count);
    x_atp_table.Demand_Source_Delivery(l_count + l_atp_count):=
              p_atp_table.Demand_Source_Delivery(l_atp_count);
    x_atp_table.Demand_Source_Type(l_count + l_atp_count):=
              p_atp_table.Demand_Source_Type(l_atp_count);
    x_atp_table.End_Pegging_Id(l_count + l_atp_count):=
              p_atp_table.End_Pegging_Id(l_atp_count);
    x_atp_table.Order_Number(l_count + l_atp_count):=
              p_atp_table.Order_Number(l_atp_count);
    x_atp_table.Old_Source_Organization_Id(l_count + l_atp_count):=
              p_atp_table.Old_Source_Organization_Id(l_atp_count);
    x_atp_table.Old_Demand_Class(l_count + l_atp_count):=
              p_atp_table.Old_Demand_Class(l_atp_count);

    x_atp_table.ato_delete_flag(l_count + l_atp_count):=
              p_atp_table.ato_delete_flag(l_atp_count);
    x_atp_table.attribute_05(l_count + l_atp_count):=
              p_atp_table.attribute_05(l_atp_count);
    x_atp_table.attribute_06(l_count + l_atp_count):=
              p_atp_table.attribute_06(l_atp_count);

    -- changes for bug 2392456
    x_atp_table.attribute_07(l_count + l_atp_count):=
              p_atp_table.attribute_07(l_atp_count);

    --- product substitution changes

    x_atp_table.substitution_typ_code(l_count + l_atp_count):=
              p_atp_table.substitution_typ_code(l_atp_count);

    x_atp_table.req_item_detail_flag(l_count + l_atp_count):=
              p_atp_table.req_item_detail_flag(l_atp_count);

    x_atp_table.request_item_id(l_count + l_atp_count):=
              p_atp_table.request_item_id(l_atp_count);

    x_atp_table.req_item_req_date_qty(l_count + l_atp_count):=
              p_atp_table.req_item_req_date_qty(l_atp_count);

    x_atp_table.req_item_available_date(l_count + l_atp_count):=
              p_atp_table.req_item_available_date(l_atp_count);

    x_atp_table.req_item_available_date_qty(l_count + l_atp_count):=
              p_atp_table.req_item_available_date_qty(l_atp_count);

    x_atp_table.request_item_name(l_count + l_atp_count):=
              p_atp_table.request_item_name(l_atp_count);

    x_atp_table.old_inventory_item_id(l_count + l_atp_count):=
              p_atp_table.old_inventory_item_id(l_atp_count);

    x_atp_table.sales_rep(l_count + l_atp_count):=
              p_atp_table.sales_rep(l_atp_count);

    x_atp_table.customer_contact(l_count + l_atp_count):=
              p_atp_table.customer_contact(l_atp_count);

    x_atp_table.subst_flag(l_count + l_atp_count):=
              p_atp_table.subst_flag(l_atp_count);

    --diag_atp

    x_atp_table.attribute_02(l_count + l_atp_count):=
              p_atp_table.attribute_02(l_atp_count);

    -- 24x7 ATP
    x_atp_table.attribute_04(l_count + l_atp_count):=
              p_atp_table.attribute_04(l_atp_count);

    x_atp_table.attribute_08(l_count + l_atp_count):=
              p_atp_table.attribute_08(l_atp_count);


     x_atp_table.sequence_number(l_count + l_atp_count):=
              p_atp_table.sequence_number(l_atp_count);
    ----s_cto_rearch
       x_atp_table.Top_Model_line_id(l_count + l_atp_count):=
                 p_atp_table.Top_Model_line_id(l_atp_count);


       x_atp_table.ATO_Parent_Model_Line_Id(l_count + l_atp_count):=
                 p_atp_table.ATO_Parent_Model_Line_Id(l_atp_count);

       x_atp_table.ATO_Model_Line_Id(l_count + l_atp_count):=
                 p_atp_table.ATO_Model_Line_Id(l_atp_count);

       x_atp_table.Parent_line_id(l_count + l_atp_count):=
                 p_atp_table.Parent_line_id(l_atp_count);

       x_atp_table.match_item_id(l_count + l_atp_count):=
                 p_atp_table.match_item_id(l_atp_count);

       x_atp_table.matched_item_name(l_count + l_atp_count):=
                 p_atp_table.matched_item_name(l_atp_count);

       x_atp_table.Config_item_line_id(l_count + l_atp_count):=
                 p_atp_table.Config_item_line_id(l_atp_count);

       x_atp_table.Validation_Org(l_count + l_atp_count):=
                 p_atp_table.Validation_Org(l_atp_count);

       x_atp_table.Component_Sequence_ID(l_count + l_atp_count):=
                 p_atp_table.Component_Sequence_ID(l_atp_count);

       x_atp_table.Component_Code(l_count + l_atp_count):=
                 p_atp_table.Component_Code(l_atp_count);

       x_atp_table.line_number(l_count + l_atp_count):=
                 p_atp_table.line_number(l_atp_count);

       x_atp_table.included_item_flag(l_count + l_atp_count):=
                 p_atp_table.included_item_flag(l_atp_count);

       x_atp_table.included_item_flag(l_count + l_atp_count):=
                 p_atp_table.included_item_flag(l_atp_count);

       x_atp_table.atp_flag(l_count + l_atp_count):=
                 p_atp_table.atp_flag(l_atp_count);

       x_atp_table.atp_components_flag(l_count + l_atp_count):=
                 p_atp_table.atp_components_flag(l_atp_count);

       x_atp_table.wip_supply_type(l_count + l_atp_count):=
                 p_atp_table.wip_supply_type(l_atp_count);

       x_atp_table.bom_item_type(l_count + l_atp_count):=
                 p_atp_table.bom_item_type(l_atp_count);

       x_atp_table.mandatory_item_flag(l_count + l_atp_count):=
                 p_atp_table.mandatory_item_flag(l_atp_count);

       x_atp_table.mandatory_item_flag(l_count + l_atp_count):=
                 p_atp_table.mandatory_item_flag(l_atp_count);

       x_atp_table.attribute_11(l_count + l_atp_count):=
                 p_atp_table.attribute_11(l_atp_count);

       x_atp_table.attribute_12(l_count + l_atp_count):=
                 p_atp_table.attribute_12(l_atp_count);


       x_atp_table.attribute_13(l_count + l_atp_count):=
                 p_atp_table.attribute_13(l_atp_count);

       x_atp_table.attribute_14(l_count + l_atp_count):=
                 p_atp_table.attribute_14(l_atp_count);

       x_atp_table.attribute_15(l_count + l_atp_count):=
                 p_atp_table.attribute_15(l_atp_count);

       x_atp_table.attribute_16(l_count + l_atp_count):=
                 p_atp_table.attribute_16(l_atp_count);

       x_atp_table.attribute_17(l_count + l_atp_count):=
                 p_atp_table.attribute_17(l_atp_count);

       x_atp_table.attribute_18(l_count + l_atp_count):=
                 p_atp_table.attribute_18(l_atp_count);

       x_atp_table.attribute_19(l_count + l_atp_count):=
                 p_atp_table.attribute_19(l_atp_count);

       x_atp_table.attribute_20(l_count + l_atp_count):=
                 p_atp_table.attribute_20(l_atp_count);

       x_atp_table.Attribute_21(l_count + l_atp_count):=
                 p_atp_table.Attribute_21(l_atp_count);

       x_atp_table.attribute_22(l_count + l_atp_count):=
                 p_atp_table.attribute_22(l_atp_count);

       x_atp_table.attribute_23(l_count + l_atp_count):=
                 p_atp_table.attribute_23(l_atp_count);

       x_atp_table.attribute_24(l_count + l_atp_count):=
                 p_atp_table.attribute_24(l_atp_count);

       x_atp_table.attribute_25(l_count + l_atp_count):=
                 p_atp_table.attribute_25(l_atp_count);

       x_atp_table.attribute_26(l_count + l_atp_count):=
                 p_atp_table.attribute_26(l_atp_count);

       x_atp_table.attribute_27(l_count + l_atp_count):=
                 p_atp_table.attribute_27(l_atp_count);

       x_atp_table.attribute_28(l_count + l_atp_count):=
                 p_atp_table.attribute_28(l_atp_count);

       x_atp_table.attribute_29(l_count + l_atp_count):=
                 p_atp_table.attribute_29(l_atp_count);

       x_atp_table.attribute_30(l_count + l_atp_count):=
                 p_atp_table.attribute_30(l_atp_count);

       x_atp_table.atf_date(l_count + l_atp_count):=
                 p_atp_table.atf_date(l_atp_count);

    ---e_cto_rearch

    -- ship_rec_cal changes begin
    x_atp_table.receiving_cal_code(l_count + l_atp_count):=
              p_atp_table.receiving_cal_code(l_atp_count);

    x_atp_table.intransit_cal_code(l_count + l_atp_count):=
              p_atp_table.intransit_cal_code(l_atp_count);

    x_atp_table.shipping_cal_code(l_count + l_atp_count):=
              p_atp_table.shipping_cal_code(l_atp_count);

    x_atp_table.manufacturing_cal_code(l_count + l_atp_count):=
              p_atp_table.manufacturing_cal_code(l_atp_count);

    x_atp_table.plan_id(l_count + l_atp_count):=
              p_atp_table.plan_id(l_atp_count);
    -- ship_rec_cal changes end

    -- Bug 3449812
    x_atp_table.internal_org_id(l_count + l_atp_count):=
              p_atp_table.internal_org_id(l_atp_count);


    -- Bug 3328421
    x_atp_table.first_valid_ship_arrival_date(l_count + l_atp_count):=
              p_atp_table.first_valid_ship_arrival_date(l_atp_count);

     x_atp_table.part_of_set(l_count + l_atp_count):=
              p_atp_table.part_of_set(l_atp_count);
  END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** End Assign_Atp_Output_Rec Procedure *****');
  END IF;

END Assign_Atp_Output_Rec;


PROCEDURE Extend_Atp_Period (
  p_atp_period          IN OUT NOCOPY  	MRP_ATP_PUB.ATP_Period_Typ,
  x_return_status       OUT      	NoCopy VARCHAR2
) IS

Begin

--    msc_sch_wb.atp_debug('***** Begin Extend_Atp_Period Procedure *****');

                    x_return_status := FND_API.G_RET_STS_SUCCESS;

                    p_atp_period.Level.Extend;
                    p_atp_period.Inventory_Item_Id.Extend;
                    p_atp_period.Request_Item_Id.Extend;
                    p_atp_period.Organization_Id.Extend;
                    p_atp_period.Department_Id.Extend;
                    p_atp_period.Resource_Id.Extend;
                    p_atp_period.Supplier_Id.Extend;
                    p_atp_period.Supplier_Site_Id.Extend;
                    p_atp_period.From_Organization_Id.Extend;
                    p_atp_period.From_Location_Id.Extend;
                    p_atp_period.To_Organization_Id.Extend;
                    p_atp_period.To_Location_Id.Extend;
                    p_atp_period.Ship_Method.Extend;
                    p_atp_period.Uom.Extend;
                    p_atp_period.Total_Supply_Quantity.Extend;
                    p_atp_period.Total_Demand_Quantity.Extend;
                    p_atp_period.Period_Start_Date.Extend;
                    p_atp_period.Period_End_Date.Extend;
                    p_atp_period.Period_Quantity.Extend;
                    p_atp_period.Identifier1.Extend;
                    p_atp_period.Identifier2.Extend;
                    p_atp_period.Identifier.Extend;
                    p_atp_period.Scenario_Id.Extend;
                    p_atp_period.Cumulative_Quantity.Extend;
                    p_atp_period.Pegging_Id.Extend;
                    p_atp_period.End_Pegging_Id.Extend;
                    -- ssurendr: additional fields for allocation w/b start
                    p_atp_period.Identifier4.Extend;
                    p_atp_period.Demand_Class.Extend;
                    p_atp_period.Class.Extend;
                    p_atp_period.Customer_Id.Extend;
                    p_atp_period.Customer_Site_Id.Extend;
                    p_atp_period.Allocated_Supply_Quantity.Extend;
                    p_atp_period.Supply_Adjustment_Quantity.Extend;
                    p_atp_period.Backward_Forward_Quantity.Extend;
                    p_atp_period.Backward_Quantity.Extend;
                    p_atp_period.Demand_Adjustment_Quantity.Extend;
                    p_atp_period.Adjusted_Availability_Quantity.Extend;
                    p_atp_period.Adjusted_Cum_Quantity.Extend;
                    p_atp_period.Unallocated_Supply_Quantity.Extend;
                    p_atp_period.Unallocated_Demand_Quantity.Extend;
                    p_atp_period.Unallocated_Net_Quantity.Extend;
                    -- ssurendr: additional fields for allocation w/b end
                    -- time_phased_atp
                    p_atp_period.total_bucketed_demand_quantity.Extend;
--    msc_sch_wb.atp_debug('***** End Extend_Atp_Period Procedure *****');

END Extend_Atp_Period;


PROCEDURE Extend_Atp_Supply_Demand (
  p_atp_supply_demand   IN OUT NOCOPY  MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status       OUT      NoCopy VARCHAR2,
  p_index		IN		NUMBER -- added by rajjain 12/10/2002
) IS
Begin
                    IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('***** Begin Extend_Atp_Supply_Demand Procedure *****');
                      msc_sch_wb.atp_debug('Extend_Atp_Supply_Demand: ' || 'p_index = ' || p_index);
                    END IF;

                    x_return_status := FND_API.G_RET_STS_SUCCESS;

                    -- rajjain added p_index 12/10/2002
                    p_atp_supply_demand.Level.Extend(p_index);
                    p_atp_supply_demand.Inventory_Item_Id.Extend(p_index);
                    p_atp_supply_demand.Request_Item_Id.Extend(p_index);
                    p_atp_supply_demand.Organization_Id.Extend(p_index);
                    p_atp_supply_demand.Department_Id.Extend(p_index);
                    p_atp_supply_demand.Resource_Id.Extend(p_index);
                    p_atp_supply_demand.Supplier_Id.Extend(p_index);
                    p_atp_supply_demand.Supplier_Site_Id.Extend(p_index);
                    p_atp_supply_demand.From_Organization_Id.Extend(p_index);
                    p_atp_supply_demand.From_Location_Id.Extend(p_index);
                    p_atp_supply_demand.To_Organization_Id.Extend(p_index);
                    p_atp_supply_demand.To_Location_Id.Extend(p_index);
                    p_atp_supply_demand.Ship_Method.Extend(p_index);
                    p_atp_supply_demand.Uom.Extend(p_index);
                    p_atp_supply_demand.Identifier1.Extend(p_index);
                    p_atp_supply_demand.Identifier2.Extend(p_index);
                    p_atp_supply_demand.Identifier3.Extend(p_index);
                    p_atp_supply_demand.Identifier4.Extend(p_index);
                    p_atp_supply_demand.Supply_Demand_Type.Extend(p_index);
                    p_atp_supply_demand.Supply_Demand_Source_Type.Extend(p_index);
                    p_atp_supply_demand.Supply_Demand_Source_Type_Name.Extend(p_index);
                    p_atp_supply_demand.Supply_Demand_Date.Extend(p_index);
                    p_atp_supply_demand.Supply_Demand_Quantity.Extend(p_index);
                    p_atp_supply_demand.Identifier.Extend(p_index);
                    p_atp_supply_demand.Scenario_Id.Extend(p_index);
                    p_atp_supply_demand.Disposition_Type.Extend(p_index);
                    p_atp_supply_demand.Disposition_Name.Extend(p_index);
                    p_atp_supply_demand.Pegging_Id.Extend(p_index);
                    p_atp_supply_demand.End_Pegging_Id.Extend(p_index);
                    -- time_phased_atp change begin
                    p_atp_supply_demand.Original_Item_Id.Extend(p_index);
                    p_atp_supply_demand.Original_Supply_Demand_Type.Extend(p_index);
                    p_atp_supply_demand.Original_Demand_Date.Extend(p_index);
                    p_atp_supply_demand.Original_Demand_Quantity.Extend(p_index);
                    p_atp_supply_demand.Allocated_Quantity.Extend(p_index);
                    p_atp_supply_demand.Pf_Display_Flag.Extend(p_index);
                    -- time_phased_atp change end

                    IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('***** End Extend_Atp_Supply_Demand Procedure *****');
                    END IF;

END Extend_Atp_Supply_Demand;

-- rajjain begin 12/10/2002
PROCEDURE Trim_Atp_Supply_Demand (
  p_atp_supply_demand   IN OUT NOCOPY  MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status       OUT      NoCopy VARCHAR2,
  p_index		IN		NUMBER
) IS
Begin
                    IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('***** Begin Trim_Atp_Supply_Demand Procedure *****');
                      msc_sch_wb.atp_debug('Trim_Atp_Supply_Demand: ' || 'p_index = ' || p_index);
                    END IF;
                    x_return_status := FND_API.G_RET_STS_SUCCESS;

                    p_atp_supply_demand.Level.Trim(p_index);
                    p_atp_supply_demand.Inventory_Item_Id.Trim(p_index);
                    p_atp_supply_demand.Request_Item_Id.Trim(p_index);
                    p_atp_supply_demand.Organization_Id.Trim(p_index);
                    p_atp_supply_demand.Department_Id.Trim(p_index);
                    p_atp_supply_demand.Resource_Id.Trim(p_index);
                    p_atp_supply_demand.Supplier_Id.Trim(p_index);
                    p_atp_supply_demand.Supplier_Site_Id.Trim(p_index);
                    p_atp_supply_demand.From_Organization_Id.Trim(p_index);
                    p_atp_supply_demand.From_Location_Id.Trim(p_index);
                    p_atp_supply_demand.To_Organization_Id.Trim(p_index);
                    p_atp_supply_demand.To_Location_Id.Trim(p_index);
                    p_atp_supply_demand.Ship_Method.Trim(p_index);
                    p_atp_supply_demand.Uom.Trim(p_index);
                    p_atp_supply_demand.Identifier1.Trim(p_index);
                    p_atp_supply_demand.Identifier2.Trim(p_index);
                    p_atp_supply_demand.Identifier3.Trim(p_index);
                    p_atp_supply_demand.Identifier4.Trim(p_index);
                    p_atp_supply_demand.Supply_Demand_Type.Trim(p_index);
                    p_atp_supply_demand.Supply_Demand_Source_Type.Trim(p_index);
                    p_atp_supply_demand.Supply_Demand_Source_Type_Name.Trim(p_index);
                    p_atp_supply_demand.Supply_Demand_Date.Trim(p_index);
                    p_atp_supply_demand.Supply_Demand_Quantity.Trim(p_index);
                    p_atp_supply_demand.Identifier.Trim(p_index);
                    p_atp_supply_demand.Scenario_Id.Trim(p_index);
                    p_atp_supply_demand.Disposition_Type.Trim(p_index);
                    p_atp_supply_demand.Disposition_Name.Trim(p_index);
                    p_atp_supply_demand.Pegging_Id.Trim(p_index);
                    p_atp_supply_demand.End_Pegging_Id.Trim(p_index);
                    -- time_phased_atp change begin
                    p_atp_supply_demand.Original_Item_Id.Extend(p_index);
                    p_atp_supply_demand.Original_Supply_Demand_Type.Extend(p_index);
                    p_atp_supply_demand.Original_Demand_Date.Extend(p_index);
                    p_atp_supply_demand.Original_Demand_Quantity.Extend(p_index);
                    p_atp_supply_demand.Allocated_Quantity.Extend(p_index);
                    p_atp_supply_demand.Pf_Display_Flag.Extend(p_index);
                    -- time_phased_atp change end

                    IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('***** End Trim_Atp_Supply_Demand Procedure *****');
                    END IF;

END Trim_Atp_Supply_Demand;
-- rajjain end 12/10/2002

-- ngoel 9/28/2001, added this function for use in View MSC_SCATP_SOURCES_V to support
-- Region Level Sourcing.

FUNCTION Get_Session_id
RETURN NUMBER
IS
BEGIN
    RETURN order_sch_wb.debug_session_id;
END Get_Session_id;

-- savirine, Aug 29, 2001: created the procedure get_regions.  This would be called to get region information
-- and store in MSC_REGIONS_TEMP table.

-- savirine, Sep 5, 2001:  added parameters p_session_id and p_dblink and changed the region info selection
--                         to dynamic sql so that if the ATP request is coming from the source and both ERP and APS
--                         instances are different ( if the p_dblink is not null it means both
--                         ERP and APS Instances are differnt), customer address info will be selected from HZ tables
--			   and the region info will be selected from WSH Tables.

-- Procedure: Get_Regions
--
-- Purpose:   Obtains information of the region by matching all address attributes for the customer site
--

PROCEDURE Get_Regions_Old (
	p_customer_site_id		IN 	NUMBER,
	p_calling_module   		IN	NUMBER,  -- i.e. Source (ERP) or Destination (724)
	p_instance_id			IN	NUMBER,
        p_session_id                    IN      NUMBER,
        p_dblink			IN      VARCHAR2,
        --2814895
        -- Adding address parameters of customer
        p_postal_code               IN      VARCHAR2, --4505374
        p_city                      IN      VARCHAR2,
        p_state                     IN      VARCHAR2,
        p_country                   IN      VARCHAR2,
        p_order_line_id             IN      NUMBER,
        x_return_status			OUT NOCOPY     VARCHAR2 ) IS

  l_postal_code  VARCHAR2(60);
  l_city         VARCHAR2(60);
  l_state        VARCHAR2(150); -- Increase field size for UTF reasons Bug 2890899
  l_country      VARCHAR2(150); -- Increase field size for UTF reasons Bug 2890899

  l_cnt 	 NUMBER;
  l_stmt 	 VARCHAR2(4000);
  l_dynstring    VARCHAR2(128) := NULL;
  l_region_id    NUMBER;

  -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
  l_stmt1        VARCHAR2(4000) := NULL;  -- bug 2882331. forward porting fix
  -- Variables added to avoid repeated calls to NVL(LENGTH(var)) bug 2882331
  l_postal_code_length	NUMBER := 0;
  l_state_length	NUMBER := 0;
  l_country_length	NUMBER := 0;

  -- Partner type values added for supplier intransit LT project
  l_customer_type       NUMBER := 2;
  l_partner_site_id  NUMBER;  --2814895

BEGIN
   -- Bug 2732267 Change the debug message qualifier from Get_Regions to Get_Regions_Old
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Begin Get_Regions_Old');
      msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'p_customer_site_id : ' || p_customer_site_id);
      msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'p_calling_module : ' || p_calling_module);
      msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'p_instance_id : ' || p_instance_id);
      msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'p_session_id : ' || p_session_id);
      msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'p_dblink : ' || p_dblink);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_calling_module <> 724 THEN
     BEGIN
       /********************* BUG 2085071 Fix ************************/
       /*  Old Select statement -- Incorrect and hence commented out.
       SELECT  a.postal_code, a.city, a.state, a.country
       INTO    l_postal_code, l_city, l_state, l_country
       FROM    hz_locations a, hz_party_sites s
       WHERE   a.location_id = s.location_id
       AND     s.party_site_id = p_customer_site_id;
       */

       /* New Select Statement */
       	-- For bug 2732267 select province if state is not specified
	IF ((p_country is not null) --2814895, use address parameter directly when they are passed by calling module
           AND (p_customer_site_id is NULL))  THEN

           l_postal_code := p_postal_code;
           l_city := p_city ;
           l_state := p_state;
           l_country := p_country ;

           l_partner_site_id :=  p_order_line_id;
           l_customer_type := 5; --2814895, 5 for address parameters

       ELSE --2814895

        l_partner_site_id := p_customer_site_id; --2814895

	SELECT LOC.POSTAL_CODE, LOC.CITY, NVL(LOC.STATE, LOC.PROVINCE), LOC.COUNTRY
         INTO l_postal_code, l_city, l_state, l_country
         FROM HZ_CUST_SITE_USES_ALL SITE_USES_ALL,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
        WHERE LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
          AND PARTY_SITE.party_site_id =ACCT_SITE.party_site_id
          AND SITE_USES_ALL.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
          AND SITE_USES_ALL.site_use_id = p_customer_site_id;

       END IF;
       /********************* BUG 2085071 Fix ************************/

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_postal_code : ' || l_postal_code);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_city : ' || l_city);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_state : ' || l_state);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_country : ' || l_country);
       END IF;

	-- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
	-- Length Variables assigned the NVL(LENGTH(var)) to avoid repeated calls bug 2882331.
	-- If length of these variables is <= 3, join with var_code else join with var
	l_postal_code_length	:= NVL(LENGTH(l_postal_code), 0);
	l_state_length		:= NVL(LENGTH(l_state), 0);
	l_country_length	:= NVL(LENGTH(l_country), 0);

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Length(l_postal_code) : ' || l_postal_code_length);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Length(l_state) : ' || l_state_length);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Length(l_country) : ' || l_country_length);
       END IF;


       l_cnt := 0;

       FOR i in REVERSE 0..3 LOOP

         BEGIN
           l_stmt :=    'SELECT region_id
                         FROM   WSH_REGIONS_V';

           -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
           IF l_cnt <= 3 THEN
	     IF l_country_length <= 3 THEN
               l_stmt := l_stmt || ' WHERE  country_code = :l_country';
             ELSE
               -- 2778393 : krajan : case insensitivity
               l_stmt := l_stmt || ' WHERE  UPPER(country) = UPPER(:l_country)';
             END IF;
	        -- bug 2882331. forward porting fix for COUNTRY+ZIP
	       l_stmt1 := l_stmt;
           END IF;

           -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
	   IF l_cnt <= 2 THEN
             -- krajan : 2778393 : Check if State record is nULL
             IF l_state_length = 0 THEN
               l_stmt := l_stmt || ' AND state_code is NULL';
               l_stmt := l_stmt || ' AND state is NULL';
	       -- We dont need DECODE stmt anymore.
             ELSIF l_state_length <= 3 THEN
	       l_stmt := l_stmt || ' AND  nvl(state_code,:l_state2) = :l_state3';
             ELSE
	       -- 2778393 : krajan : case insensitivity
	       l_stmt := l_stmt || ' AND  UPPER(nvl(state,:l_state4)) = UPPER(:l_state5)';
             END IF;
           END IF;

           IF l_cnt <= 1 THEN
             -- 2778393 : krajan : case insensitivity
             l_stmt := l_stmt || ' AND UPPER(city) = UPPER(:l_city)';
           END IF;

           -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
           IF l_cnt = 0 THEN
	     IF l_postal_code_length > 0 THEN
                -- use l_stmt1 instead of l_stmt
		-- Bug 3010834 F/w port 2979572 Use Postal code from when Postal Code to is null
		l_stmt1 := l_stmt1 || ' AND postal_code_from <= :l_postal_code1
                                        AND nvl(postal_code_to, postal_code_from) >= :l_postal_code2
					AND region_type = :counter AND rownum = 1';
             END IF;
           END IF;

	   l_stmt := l_stmt || ' AND region_type = :counter AND rownum = 1';
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Regions_Old: searching region_type: ' || i);
	      IF l_cnt = 0 THEN
		msc_sch_wb.atp_debug('Get_Regions_Old: l_stmt1: '||l_stmt1);
	      ELSE
		msc_sch_wb.atp_debug('Get_Regions_Old: l_stmt: ' || l_stmt);
	      END IF;
           END IF;

           -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
	   IF l_cnt = 0 THEN
	      IF l_postal_code_length > 0 THEN
                 execute immediate l_stmt1 INTO l_region_id
                 -- Bug 3010834 F/w port 2979572 Use Postal code from when Postal Code to is null
		 using l_country, l_postal_code,l_postal_code, i;
              ELSE
		 RAISE NO_DATA_FOUND;
              END IF;
           ELSIF l_cnt = 1 THEN
	       IF (l_state_length = 0) THEN
		execute immediate l_stmt INTO l_region_id
		using l_country, l_city, i;
               ELSE
                execute immediate l_stmt INTO l_region_id
                using l_country, l_state,l_state,l_city, i;
               END IF;
           ELSIF l_cnt = 2 THEN
               IF (l_state_length = 0) THEN
		execute immediate l_stmt INTO l_region_id
		using l_country, i;
               ELSE
		execute immediate l_stmt INTO l_region_id
                using l_country, l_state,l_state,i;
               END IF;
           ELSIF l_cnt = 3 THEN
             execute immediate l_stmt INTO l_region_id
         	using l_country, i;
           END IF;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_cnt: ' || l_cnt);
           END IF;
           exit;  -- to exit the loop.

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_cnt := l_cnt + 1;

         END;

       END LOOP; 	-- FOR i in 3..0 LOOP

       IF l_region_id is NOT NULL THEN

           IF p_dblink IS NOT NULL THEN
              l_dynstring := '@'||p_dblink;
           END IF;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_dynstring: ' || l_dynstring);
           END IF;

           BEGIN
              -- Modified the SQL for bug 2484964. For better performance
              -- avoid the sub-query.
              -- also update Partner_type for supplier intransit LT project
              l_stmt:= 'INSERT into msc_regions_temp' || l_dynstring ||
                      ' (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                      -- SELECT :p_session_id, commented for performance tuning bug 2484964
		      (SELECT DISTINCT :p_session_id,
                               :p_customer_site_id,
                               region_id,
                               region_type,
                               ''N'',
                               :partner_type
                        FROM   WSH_REGIONS
                        START WITH region_id =  :l_region_id
                        CONNECT BY PRIOR parent_region_id = region_id)';

	      IF PG_DEBUG in ('Y', 'C') THEN
	         msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_stmt : ' || l_stmt);
	         msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'p_session_id : ' || p_session_id);
	         msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'p_customer_site_id : ' || p_customer_site_id);
	         msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_region_id : ' || l_region_id);
	      END IF;

              EXECUTE immediate l_stmt
		   using p_session_id, l_partner_site_id, l_customer_type, l_region_id; --2814895

              -- also update Partner_type for supplier intransit LT project
              -- partner_type is also included in the where clause
              --2814895, changed l_customer site_id to l_partner_site_id
              l_stmt:=  'INSERT into msc_regions_temp' || l_dynstring ||
                        ' (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
		        SELECT :p_session_id,
                                 :l_partner_site_id,
                                 a.region_id,
                                 a.zone_level,
                                 ''Y'',
                                 :partner_type
                        FROM     WSH_REGIONS a, WSH_ZONE_REGIONS b
                        WHERE    a.region_id = b.parent_region_id
                        AND      a.region_type = 10
                        AND      a.zone_level IS NOT NULL
                        AND      b.region_id IN (
	                                       SELECT c.region_id
	                                       FROM   msc_regions_temp' || l_dynstring || ' c
	                                       WHERE  c.session_id = :p_session_id1
	                                       AND    c.partner_site_id = :p_partner_site_id1
	                                       AND    c.partner_type = :partner_type1)';

	      IF PG_DEBUG in ('Y', 'C') THEN
	         msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_stmt : ' || l_stmt);
	      END IF;

              EXECUTE immediate l_stmt using p_session_id, l_partner_site_id, l_customer_type,
                p_session_id, l_partner_site_id, l_customer_type;  --2814895
           EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                 --- if we come here then that means that
                 -- region info for this customer has already been inserted
                 -- This would happen from order imports where one order may  contain
                 -- requests from many customer sites. If a same customer is
                 --- seperated by one or more customers then we would come in this
                 -- procedure both time. One second time this exception will be raised.
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Regions for this customer are already there in the temp table');
                 END IF;
           END;
       END IF; 	-- IF l_region_id is NOT NULL THEN

     END;
   ELSE 	-- IF p_calling_module <> 724 THEN

     BEGIN

       SELECT mtps.postal_code, mtps.city, mtps.state, mtps.country
       INTO   l_postal_code, l_city, l_state, l_country
       FROM   msc_trading_partner_sites mtps,
              msc_tp_site_id_lid tpsid
       WHERE  tpsid.sr_tp_site_id = p_customer_site_id
       AND    tpsid.sr_instance_id = p_instance_id
       AND    rownum = 1
       AND    tpsid.partner_type = 2
       AND    tpsid.tp_site_id = mtps.partner_site_id;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_postal_code : ' || l_postal_code);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_city : ' || l_city);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_state : ' || l_state);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_country : ' || l_country);
       END IF;

	-- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
	-- Length Variables assigned the NVL(LENGTH(var)) to avoid repeated calls bug 2882331.
	-- If length of these variables is <= 3, join with var_code else join with var
	l_postal_code_length	:= NVL(LENGTH(l_postal_code), 0);
	l_state_length		:= NVL(LENGTH(l_state), 0);
	l_country_length	:= NVL(LENGTH(l_country), 0);

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Length(l_postal_code) : ' || l_postal_code_length);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Length(l_state) : ' || l_state_length);
          msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Length(l_country) : ' || l_country_length);
       END IF;


       l_cnt := 0;

       FOR i in REVERSE 0..3 LOOP
         BEGIN
           l_stmt :=    'SELECT region_id
                         FROM   MSC_REGIONS
                         WHERE sr_instance_id = :p_instance_id';

           -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
           IF l_cnt <= 3 THEN
	     IF l_country_length <= 3 THEN
               l_stmt := l_stmt || ' AND  country_code = :l_country';
             ELSE
             -- 2778393 : krajan : case insensitivity
               l_stmt := l_stmt || ' AND  UPPER(country) = UPPER(:l_country)';
             END IF;
	     -- bug 2882331. forward porting fix
	     l_stmt1 := l_stmt;
           END IF;

           -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
	   IF l_cnt <= 2 THEN
             -- krajan : 2778393 : Check if State record is nULL
             IF l_state_length = 0 THEN
               l_stmt := l_stmt || ' AND  state_code is NULL';
               l_stmt := l_stmt || ' AND  state is NULL';
               -- l_stmt := l_stmt || ' AND DECODE (:l_state,0,0,0) = 0'; We dont need this now
             ELSIF l_state_length <= 3 THEN
	       l_stmt := l_stmt || ' AND  nvl(state_code,:l_state2) = :l_state3';
             ELSE
	       -- 2778393 : krajan : case insensitivity
               -- l_stmt := l_stmt || ' AND  UPPER(state) = UPPER(:l_state)';
	       l_stmt := l_stmt || ' AND  UPPER(nvl(state,:l_state4)) = UPPER(:l_state5)';
             END IF;
           END IF;

           IF l_cnt <= 1 THEN
             l_stmt := l_stmt || ' AND UPPER(city) = UPPER(:l_city)';
           END IF;

           -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
	   IF l_cnt = 0 THEN
	      IF l_postal_code_length > 0 THEN
	        -- Bug 3010834 F/w port 2979572 Use Postal code from when Postal Code to is null
                l_stmt1 := l_stmt1 || ' AND postal_code_from <= :l_postal_code1
                                        AND nvl(postal_code_to, postal_code_from) >= :l_postal_code2
					AND region_type = :counter AND rownum = 1';
              END IF;
           END IF;

	   l_stmt := l_stmt || ' AND region_type = :counter AND rownum = 1';

           IF PG_DEBUG in ('Y', 'C') THEN
		msc_sch_wb.atp_debug('Get_Regions_Old: searching region_type : ' || i);
		IF l_cnt = 0 THEN
			msc_sch_wb.atp_debug('Get_Regions_Old: l_stmt1: ' ||l_stmt1);
		ELSE
			msc_sch_wb.atp_debug('Get_Regions_Old: l_stmt : ' || l_stmt);
		END IF;
           END IF;

	   -- Bug 3010834: Backport bug 2882331 to 11.5.9 to be included in I.1
	   IF l_cnt = 0 THEN
	     IF l_postal_code_length > 0 THEN
                 execute immediate l_stmt1 INTO l_region_id
		 -- Bug 3010834 F/w port 2979572 Use Postal code from when Postal Code to is null
                 using p_instance_id,l_country, l_postal_code,l_postal_code, i;
             ELSE
               RAISE NO_DATA_FOUND;
             END IF;

           ELSIF l_cnt = 1 THEN
	     IF l_state_length = 0 THEN
		execute immediate l_stmt INTO l_region_id
                -- using p_instance_id, l_country, l_state, l_city, i; We dont need to pass state
		using p_instance_id, l_country, l_city, i;
             ELSE
		execute immediate l_stmt INTO l_region_id
               using p_instance_id, l_country, l_state,l_state, l_city,i;
             END IF;

           ELSIF l_cnt = 2 THEN
	      IF l_state_length = 0 THEN
		execute immediate l_stmt INTO l_region_id
                -- using p_instance_id, l_country, l_state,i; No need to pass state.
		using p_instance_id, l_country, i;
              ELSE
		execute immediate l_stmt INTO l_region_id
                using p_instance_id, l_country, l_state,l_state,i;
              END IF;

           ELSIF l_cnt = 3 THEN
             execute immediate l_stmt INTO l_region_id
		using p_instance_id, l_country, i;
           END IF;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_cnt: ' || l_cnt);
           END IF;
           exit;  -- to exit the loop.

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_cnt := l_cnt + 1;

         END;
       END LOOP;

       IF l_region_id is NOT NULL THEN

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'l_region_id: ' || l_region_id);
           END IF;

           -- Bug 2837366 : krajan : Catch the DUP_VAL_ON_INDEX error
           -- also update Partner_type for supplier intransit LT project
           BEGIN
                INSERT INTO msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                        -- Begin Bug 2498174
                        -- Changed Query to enhance performance
                SELECT  DISTINCT p_session_id,
                        p_customer_site_id,
                        region_id,
                        region_type,
                        'N',
                        l_customer_type -- For supplier intransit LT project
                FROM    MSC_REGIONS
                WHERE   sr_instance_id = p_instance_id
                START   WITH region_id = l_region_id
                CONNECT BY PRIOR parent_region_id = region_id;
                -- Removed Subquery for performance  Bug 2498174
                  -- End Bug 2498174

                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'After Region Fetch for ' || l_region_id);
                END IF;

                -- Begin Bug 2498174
                -- Ensure that regions and zones query has instance_id filter
                -- Changed Query to enhance performance
                INSERT INTO msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                SELECT p_session_id,
                        p_customer_site_id,
                        a.region_id,
                        a.zone_level,
                        'Y',
                        l_customer_type -- For supplier intransit LT project
                FROM   MSC_REGIONS_TEMP c, MSC_ZONE_REGIONS b, MSC_REGIONS a
                WHERE  a.region_id = b.parent_region_id
                AND    c.region_id = b.region_id
                AND    a.sr_instance_id = b.sr_instance_id
                AND    b.sr_instance_id = p_instance_id
                AND    a.region_type = 10
                AND    a.zone_level IS NOT NULL
                AND    c.session_id = p_session_id
                AND    c.partner_site_id = p_customer_site_id
                AND    c.partner_type = l_customer_type; -- For supplier intransit LT project
                  -- End Bug 2498174
           EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Regions for this customer are already there in the temp table');
                    END IF;
           END;

       END IF; 	-- IF l_region_id is NOT NULL THEN
     END;

   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Customer with following customer_site_id does not exist: ' || p_customer_site_id);
	END IF;
        return;
   WHEN OTHERS THEN
        IF (SQLCODE = -942) THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Table/View doesnt exist');
                 msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Continue as normal');
              END IF;
              return;
        ELSE
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'sqlcode : ' || sqlcode || ' : ' || sqlerrm);
              msc_sch_wb.atp_debug('Get_Regions_Old: ' || 'Error for Customer with customer_site_id : ' || p_customer_site_id);
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           return;
        END IF;
END Get_Regions_Old;


-- Get Regions functionality using the Regions to Locations mapping table
-- krajan : refer to design document for bug 2359231

PROCEDURE Get_Regions_Shipping (
        p_customer_site_id              IN      NUMBER,
        p_calling_module                IN      NUMBER,  -- i.e. Source (ERP) or Destination (724)
        p_instance_id                   IN      NUMBER,
        p_session_id                    IN      NUMBER,
        p_dblink                        IN      VARCHAR2,
        x_return_status                 OUT NOCOPY    VARCHAR2,
        p_location_id                   IN      NUMBER ,
        p_location_source               IN      VARCHAR2,
        p_supplier_site_id              IN      NUMBER DEFAULT NULL,-- For supplier intransit LT project
        p_party_site_id                 IN      NUMBER) IS  --2814895


    l_postal_code  VARCHAR2(60);
    l_city         VARCHAR2(60);
    l_state        VARCHAR2(60);
    l_country      VARCHAR2(60);

    l_cnt 	 NUMBER;
    l_stmt 	 VARCHAR2(4000);
    l_dynstring    VARCHAR2(128) := NULL;

    l_region_id    NUMBER;
    l_region_type  NUMBER;

    --bug 2744106: Change hard coded strings to bind variables
    l_YES          VARCHAR2(1) := 'Y';
    l_NO           VARCHAR2(1) := 'N';
    l_HZ           VARCHAR2(2) := 'HZ';

    -- Partner type values added for supplier intransit LT project
    l_vendor_type         NUMBER := 1;
    l_customer_type       NUMBER := 2;
    l_party_type          NUMBER := 4; --2814895
    l_partner_type        NUMBER := 2; --2814895, default as 2

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Begin Get_regions_SHIPPING');
        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'p_customer_site_id : ' || p_customer_site_id);
        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'p_calling_module : ' || p_calling_module);
        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'p_instance_id : ' || p_instance_id);
        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'p_session_id : ' || p_session_id);
        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'p_dblink : ' || p_dblink);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Always use destination table if supplier site is passed
    -- IF p_calling_module <> 724 AND nvl(p_supplier_site_id,-1)=-1 THEN -- For supplier intransit LT project
    -- Bug 3497370 - Handle null calling_module
    IF nvl(p_calling_module,-99) <> 724 AND nvl(p_supplier_site_id,-1)=-1 THEN -- For supplier intransit LT project
        BEGIN

            IF p_dblink IS NOT NULL THEN
                l_dynstring := '@'||p_dblink;
            END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'l_dynstring: ' || l_dynstring);
                msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'New Code starting ');
            END IF;
            if (p_customer_site_id <> -1) THEN
                --process as usual
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Customer_Site_id is populated : ' || p_customer_site_id);
                END IF;
                --bug 2744106: chnage hard coded stings to bind variables
                -- bug 2974334. Change the SQL into static if dbink is null.

                /* bug 3425497: First insert into table locally and then transfer over dblink
                IF p_dblink IS NOT NULL THEN

                    -- also update Partner_type for supplier intransit LT project
                    l_stmt := ' INSERT INTO msc_regions_temp' || l_dynstring ||
                              ' (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                    SELECT  :p_session_id,
                            :p_customer_site_id1,
                            region_id,
                            region_type,
                            :l_NO,
                            :partner_type
                    FROM    WSH_REGION_LOCATIONS
                    WHERE   location_id IN
                           (SELECT  LOC.LOCATION_ID
                            FROM    HZ_CUST_SITE_USES_ALL SITE_USES_ALL,
                                    HZ_PARTY_SITES PARTY_SITE,
                                    HZ_LOCATIONS LOC,
                                    HZ_CUST_ACCT_SITES_ALL ACCT_SITE
                            WHERE   LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
                            AND     PARTY_SITE.party_site_id =ACCT_SITE.party_site_id
                            AND     SITE_USES_ALL.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
                            AND     SITE_USES_ALL.site_use_id = :p_customer_site_id
                           )
                    AND     location_source = :l_HZ
                    AND     region_id is not null'; -- 2837468

                    EXECUTE immediate l_stmt
                    using p_session_id, p_customer_site_id,l_NO, l_customer_type, p_customer_site_id, l_HZ;

                ELSE -- bug 2974334. Change the SQL into static if dbink is null.

                    -- also update Partner_type for supplier intransit LT project
                    INSERT  INTO msc_regions_temp
                            (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                    SELECT  p_session_id, p_customer_site_id, region_id, region_type, l_NO, l_customer_type
                    FROM    WSH_REGION_LOCATIONS
                    WHERE   location_id IN
                           (SELECT  LOC.LOCATION_ID
                            FROM    HZ_CUST_SITE_USES_ALL SITE_USES_ALL,
                                    HZ_PARTY_SITES PARTY_SITE,
                                    HZ_LOCATIONS LOC,
                                    HZ_CUST_ACCT_SITES_ALL ACCT_SITE
                            WHERE   LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
                            AND     PARTY_SITE.party_site_id =ACCT_SITE.party_site_id
                            AND     SITE_USES_ALL.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
                            AND     SITE_USES_ALL.site_use_id = p_customer_site_id
                           )
                    AND     location_source = l_HZ
                    AND     region_id is not null; -- 2837468

                END IF;
                */

                INSERT  INTO msc_regions_temp
                            (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                    SELECT  p_session_id, p_customer_site_id, wrl.region_id, wrl.region_type, l_NO, l_partner_type --2814895
                    FROM    WSH_REGION_LOCATIONS WRL,
                            HZ_CUST_SITE_USES_ALL SITE_USES_ALL,
                            HZ_PARTY_SITES PARTY_SITE,
                            HZ_LOCATIONS LOC,
                            HZ_CUST_ACCT_SITES_ALL ACCT_SITE
                    WHERE   WRL.location_id = LOC.LOCATION_ID
                    AND     LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
                    AND     PARTY_SITE.party_site_id =ACCT_SITE.party_site_id
                    AND     SITE_USES_ALL.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
                    AND     SITE_USES_ALL.site_use_id = p_customer_site_id
                    AND     WRL.location_source = l_HZ
                    AND     WRL.region_id is not null; -- 2837468

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Row Count := ' || SQL%ROWCOUNT);
                END IF;

            ELSIF (NVL(p_party_site_id, -1) <> -1) THEN --2814895, only adding it if nvl(p_calling_module,-99) <> 724

               l_partner_type := l_party_type;

               INSERT  INTO msc_regions_temp
               (session_id,partner_site_id,region_id,region_type,zone_flag, partner_type) --2814895
               SELECT  p_session_id,p_party_site_id,wrl.region_id,wrl.region_type,l_NO,l_partner_type
               FROM    WSH_REGION_LOCATIONS WRL,
                       HZ_PARTY_SITES PARTY_SITE
               WHERE   WRL.location_id = PARTY_SITE.LOCATION_ID
               AND     PARTY_SITE.party_site_id = p_party_site_id
               AND     WRL.location_source = l_HZ
               AND     WRL.region_id is not null;

               IF PG_DEBUG in ('Y', 'C') THEN --2814895
                    msc_sch_wb.atp_debug('Row Count := ' || SQL%ROWCOUNT);
               END IF;
            else
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Going by the location ID');
                    msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Location ID : ' ||p_location_id);
                    msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Location Src: ' || p_location_source);
                END IF;

                -- bug 2974334. Change the SQL into static if dbink is null
                /* 3425497: first insert locally.
                IF p_dblink IS NOT NULL THEN

                    -- also update Partner_type for supplier intransit LT project
                    l_stmt := 'INSERT INTO msc_regions_temp' || l_dynstring ||
                              ' (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                    SELECT  :p_session_id,
                            -1,
                            region_id,
                            region_type,
                            :l_NO,
                            :partner_type
                    FROM    WSH_REGION_LOCATIONS
                    WHERE   location_id = :p_location_id
                    AND     location_source =  :p_location_source
                    AND     region_id is not null'; --2837468

                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug ('Get_Regions_Shipping: ' || 'l_stmt = ' || l_stmt);
                    END IF;

                    EXECUTE immediate l_stmt
                    using p_session_id, l_NO, p_location_id, p_location_source;

                ELSE

                    -- also update Partner_type for supplier intransit LT project
                    INSERT  INTO msc_regions_temp
                            (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                    SELECT  p_session_id, -1, region_id, region_type, l_NO, l_customer_type
                    FROM    WSH_REGION_LOCATIONS
                    WHERE   location_id = p_location_id
                    AND     location_source =  p_location_source
                    AND     region_id is not null; --2837468

                END IF; -- bug 2974334. Change the SQL into static if dbink is null
                */
                -- also update Partner_type for supplier intransit LT project
                INSERT  INTO msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                SELECT  p_session_id, -1, region_id, region_type, l_NO, l_customer_type --2814895
                FROM    WSH_REGION_LOCATIONS
                WHERE   location_id = p_location_id
                AND     location_source =  p_location_source
                AND     region_id is not null; --2837468

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Row Count := ' || SQL%ROWCOUNT);
                END IF;
            END if;

            --- RMEHRA : Sql Performance Tuning
            -- changed SQL
            -- bug 2974334. Change the SQL into static if dbink is null

            /* 3425497: Insert data locally
            IF p_dblink IS NOT NULL THEN

                -- also update Partner_type for supplier intransit LT project
                -- partner_type is also included in the where clause
                l_stmt:=  'INSERT into msc_regions_temp' || l_dynstring ||
                          ' (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                SELECT  DISTINCT :p_session_id,
                        :p_customer_site_id,
                        a.region_id,
                        a.zone_level,
                        :l_YES,
                        :partner_type
                FROM    WSH_REGIONS a, WSH_ZONE_REGIONS b,
                        MSC_REGIONS_TEMP' || l_dynstring || ' c
                WHERE   a.region_id = b.parent_region_id
                AND     a.region_type = 10
                AND     a.zone_level IS NOT NULL
                AND     b.region_id = c.region_id
                AND     c.session_id = :p_session_id1
                AND     c.partner_site_id = :p_customer_site_id1
                AND     c.partner_type    = :partner_type1'; -- For supplier intransit LT project


                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'l_stmt : ' || l_stmt);
                END IF;


                EXECUTE immediate l_stmt using p_session_id, p_customer_site_id, l_YES,
                l_customer_type, p_session_id, p_customer_site_id, l_customer_type;

            ELSE

                -- also update Partner_type for supplier intransit LT project
                -- partner_type is also included in the where clause
                INSERT  into msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                SELECT  DISTINCT p_session_id,
                        p_customer_site_id,
                        a.region_id,
                        a.zone_level,
                        l_YES,
                        l_customer_type
                FROM    WSH_REGIONS a, WSH_ZONE_REGIONS b, MSC_REGIONS_TEMP c
                WHERE   a.region_id = b.parent_region_id
                AND     a.region_type = 10
                AND     a.zone_level IS NOT NULL
                AND     b.region_id = c.region_id
                AND     c.session_id = p_session_id
                AND     c.partner_site_id = p_customer_site_id
                AND     c.partner_type    = l_customer_type; -- For supplier intransit LT project

            END IF; -- bug 2974334. Change the SQL into static if dbink is null

            */

            -- also update Partner_type for supplier intransit LT project
            -- partner_type is also included in the where clause
            INSERT  into msc_regions_temp
                    (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
            SELECT  DISTINCT p_session_id,
                    p_customer_site_id,
                    a.region_id,
                    a.zone_level,
                    l_YES,
                    l_customer_type
            FROM    WSH_REGIONS a, WSH_ZONE_REGIONS b, MSC_REGIONS_TEMP c
            WHERE   a.region_id = b.parent_region_id
            AND     a.region_type = 10
            AND     a.zone_level IS NOT NULL
            AND     b.region_id = c.region_id
            AND     c.session_id = p_session_id
            AND     c.partner_site_id = decode(l_partner_type, l_customer_type, p_customer_site_id, p_party_site_id) --2814895
            AND     c.partner_type    = l_partner_type; -- 2814895  -- For supplier intransit LT project

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Row Count := ' || SQL%ROWCOUNT);
            END IF;
            /*bug3520746 do not push the data across dblink
            --bug 3425497: Now if dblink is not null then transfer the data across dblink
            IF p_dblink IS NOT NULL THEN
                --first insert data across dblink
                l_stmt:=  'INSERT into msc_regions_temp' || l_dynstring ||
                          ' (SESSION_ID, PARTNER_SITE_ID, REGION_ID, REGION_TYPE, ZONE_FLAG, PARTNER_TYPE)
                           select SESSION_ID, PARTNER_SITE_ID, REGION_ID, REGION_TYPE, ZONE_FLAG, PARTNER_TYPE
                           from   msc_regions_temp
                           where  session_id = :p_session_id';
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('l_stmt:= ' || l_stmt);
                END IF;

                execute immediate l_stmt using p_session_id;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Row Count := ' || SQL%ROWCOUNT);
                END IF;

                 --now delete the data locally
                 delete msc_regions_temp where session_id = p_session_id;
            END IF;
            */
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Regions for this customer are already there in the temp table');
                END IF;
        END;
    ELSE    -- IF p_calling_module <> 724 AND nvl(p_supplier_site_id,-1)=-1 THEN

        IF nvl(p_customer_site_id,-1) <> -1 THEN  -- For supplier intransit LT project

            BEGIN
                /* Replace IN clause with = join
                -- also update Partner_type for supplier intransit LT project
                insert  into msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                select  p_session_id,
                        p_customer_site_id,
                        region_id,
                        region_type,
                        'N',
                        l_customer_type
                from    msc_region_locations
                where   location_id in  (
                        select location_id
                        from   msc_tp_site_id_lid tpsid
                        where  tpsid.sr_instance_id = p_instance_id
                        and    tpsid.sr_tp_site_id = p_customer_site_id
                        and    tpsid.partner_type = 2
                )
                and     sr_instance_id = p_instance_id
                and     region_id is not null
                and     location_source = 'HZ';

                */

                insert  into msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                select  p_session_id,
                        p_customer_site_id,
                        mrl.region_id,
                        mrl.region_type,
                        'N',
                        l_customer_type
                from    msc_region_locations mrl,
                        msc_tp_site_id_lid tpsid

                where   mrl.location_id = tpsid.location_id
                and     tpsid.sr_instance_id = p_instance_id
                and    tpsid.sr_tp_site_id = p_customer_site_id
                and    tpsid.partner_type = 2
                and     mrl.sr_instance_id = p_instance_id
                and     mrl.region_id is not null
                and     mrl.location_source = 'HZ';

                /* 3425497: Replace in clause with = joins

                -- Insert Zones data
                -- also update Partner_type for supplier intransit LT project
                -- partner_type is also included in the where clause
                INSERT  INTO msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                SELECT  DISTINCT p_session_id,
                        p_customer_site_id,
                        a.region_id,
                        a.zone_level,
                        'Y',
                        l_customer_type
                FROM    MSC_REGIONS a, MSC_ZONE_REGIONS b
                WHERE   a.region_id = b.parent_region_id
                AND     a.region_type = 10
                AND     a.zone_level IS NOT NULL
                AND     a.sr_instance_id = b.sr_instance_id
                and     b.sr_instance_id = p_instance_id
                AND     b.region_id IN (
                        SELECT  c.region_id
                        FROM    msc_regions_temp c
                        WHERE   c.session_id = p_session_id
                        AND     c.partner_site_id = p_customer_site_id
                        AND     c.partner_type    = l_customer_type -- For supplier intransit LT project
                );
                */

                INSERT  INTO msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                SELECT  DISTINCT p_session_id,
                        p_customer_site_id,
                        a.region_id,
                        a.zone_level,
                        'Y',
                        l_customer_type
                FROM    MSC_REGIONS a, MSC_ZONE_REGIONS b, msc_regions_temp c
                WHERE   a.region_id = b.parent_region_id
                AND     a.region_type = 10
                AND     a.zone_level IS NOT NULL
                AND     a.sr_instance_id = b.sr_instance_id
                and     b.sr_instance_id = p_instance_id
                AND     b.region_id  =  c.region_id
                AND     c.session_id = p_session_id
                AND     c.partner_site_id = p_customer_site_id
                AND     c.partner_type    = l_customer_type -- For supplier intransit LT project
                ;
            EXCEPTION
                -- Bug 2837366 : krajan : Catch exception
                WHEN DUP_VAL_ON_INDEX THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Regions for this customer are already there in the temp table');
                    END IF;
                WHEN NO_DATA_FOUND THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Customer with following customer_site_id does not exist: ');
                    END IF;
            END;

        ELSE -- IF nvl(p_customer_site_id,-1) <> -1 THEN  -- For supplier intransit LT project

            BEGIN
                -- Populating region data for supplier site
                insert into msc_regions_temp
                        (session_id, partner_site_id, region_id, region_type, zone_flag, partner_type)
                select  p_session_id,
                        p_supplier_site_id,
                        region_id,
                        region_type,
                        null,   -- not required anymore because collected data is already translated
                        l_vendor_type
                from    msc_region_sites
                where   vendor_site_id = p_supplier_site_id
                and     sr_instance_id = p_instance_id;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Regions for this supplier are already there in the temp table');
                    END IF;
                WHEN NO_DATA_FOUND THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Region data for the following supplier_site_id does not exist: ' || p_supplier_site_id);
                    END IF;
            END;

        END IF; -- IF nvl(p_customer_site_id,-1) <> -1 THEN  -- For supplier intransit LT project

    END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Customer with following customer_site_id does not exist: ' || p_customer_site_id);
	END IF;
        return;
   WHEN OTHERS THEN
        IF (SQLCODE = -942) THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Table/View doesnt exist');
                 msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Continue as normal');
              END IF;
              return;
        ELSE
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'sqlcode : ' || sqlcode || ' : ' || sqlerrm);
              msc_sch_wb.atp_debug('sqlcode : ' || sqlcode || ' : ' || sqlerrm);
              msc_sch_wb.atp_debug('Get_Regions_Shipping: ' || 'Error for Customer with customer_site_id : ' || p_customer_site_id);
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           --bug 3425497: delete data from local table
           delete msc_regions_temp where session_id = p_session_id;
           return;
        END IF;
END Get_Regions_Shipping;

PROCEDURE get_src_transit_time (
	p_from_org_id		IN NUMBER,
	p_from_loc_id		IN NUMBER,
	p_to_org_id		IN NUMBER,
	p_to_loc_id		IN NUMBER,
	p_session_id		IN NUMBER,
	p_partner_site_id	IN NUMBER,
	x_ship_method		IN OUT NOCOPY VARCHAR2,
	x_intransit_time	OUT NOCOPY NUMBER,
	p_partner_type          IN NUMBER --2814895
	)
IS
	l_level			NUMBER;
	-- Bug 4000425
	--l_ship_method           VARCHAR2(30) := x_ship_method;

CURSOR	c_lead_time
IS
SELECT  intransit_time,
        ((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM    mtl_interorg_ship_methods mism,
        msc_regions_temp mrt
WHERE   mism.from_location_id = p_from_loc_id
AND     mism.ship_method = x_ship_method
AND     mism.to_region_id = mrt.region_id
AND     mrt.session_id = p_session_id
--AND     mrt.partner_type = 2    -- For supplier intransit LT project
AND     mrt.partner_site_id = p_partner_site_id --2814895
AND     mrt.partner_type = NVL(p_partner_type,2)
ORDER BY 2;

CURSOR  c_default_lead_time
IS
SELECT  ship_method, intransit_time,
        ((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM    mtl_interorg_ship_methods mism,
        msc_regions_temp mrt
WHERE   mism.from_location_id = p_from_loc_id
AND     mism.default_flag = 1
AND     mism.to_region_id = mrt.region_id
AND     mrt.session_id = p_session_id
AND     mrt.partner_site_id = p_partner_site_id
--2814895
AND     mrt.partner_type = NVL(p_partner_type,2)
--AND     mrt.partner_type = 2    -- For supplier intransit LT project
ORDER BY 3; -- was earlier ordered wrongly by 2. changed it to 3 along with supplier intransit LT changes

BEGIN

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('********** get_src_transit_time **********');
	   msc_sch_wb.atp_debug('get_src_transit_time: ' || 'org from: ' || p_from_org_id ||
					 ' to: '      || p_to_org_id);
	   msc_sch_wb.atp_debug('get_src_transit_time: ' || 'loc from: ' || p_from_loc_id ||
					 ' to: '      || p_to_loc_id);
	   msc_sch_wb.atp_debug('get_src_transit_time: ' || 'session_id: '    || p_session_id);
	   msc_sch_wb.atp_debug('get_src_transit_time: ' || 'partner_site: '  || p_partner_site_id);
	   msc_sch_wb.atp_debug('get_src_transit_time: ' || 'ship method: '   || x_ship_method);
	END IF;


	-- if the receipt org or the ship method is NULL
	-- then get the default time

	IF p_from_loc_id IS NOT NULL THEN
    	 	BEGIN
			IF x_ship_method IS NOT NULL THEN
         			SELECT  intransit_time
    	    			INTO    x_intransit_time
     	    			FROM    mtl_interorg_ship_methods
    	    			WHERE   from_location_id = p_from_loc_id
	         		AND     to_location_id = p_to_loc_id
    				AND     ship_method = x_ship_method
    				AND     rownum = 1;
			ELSE
         			SELECT  ship_method, intransit_time
    	    			INTO    x_ship_method, x_intransit_time
     	    			FROM    mtl_interorg_ship_methods
    	    			WHERE   from_location_id = p_from_loc_id
	         		AND     to_location_id = p_to_loc_id
				AND     default_flag = 1
    				AND     rownum = 1;
			END IF;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   msc_sch_wb.atp_debug('get_src_transit_time: ' || 'Using region level transit times');
			END IF;
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
	END IF;

	IF (x_intransit_time is NULL AND
	    p_from_org_id IS NOT NULL AND p_to_org_id IS NOT NULL) THEN

		BEGIN
			IF x_ship_method IS NOT NULL THEN
				select  intransit_time
				into	x_intransit_time
				from    mtl_interorg_ship_methods
				where   from_organization_id = p_from_org_id
				and     to_organization_id = p_to_org_id
				and     ship_method = x_ship_method
				and     rownum = 1;
			ELSE
				select  ship_method, intransit_time
				into	x_ship_method, x_intransit_time
				from    mtl_interorg_ship_methods
				where   from_organization_id = p_from_org_id
				and     to_organization_id = p_to_org_id
				and     default_flag = 1
				and     rownum = 1;
			END IF;

		EXCEPTION WHEN NO_DATA_FOUND THEN
			null;
		END;
	END IF;

	IF x_intransit_time IS NULL AND x_ship_method IS NOT NULL THEN
		-- call myself with null ship method to get defaults
		x_ship_method := NULL;
		get_src_transit_time(p_from_org_id,
				 p_from_loc_id,
				 p_to_org_id,
				 p_to_loc_id,
				 p_session_id,
				 p_partner_site_id,
				 x_ship_method,
				 x_intransit_time,
				 p_partner_type --2814895
				 );
        	/* -- Bug 4000425 Return transit time and ship method as null if not found.
        	IF x_intransit_time IS NULL THEN
        	        x_intransit_time := 0;
        	        x_ship_method := l_ship_method;
        	END IF;*/
	END IF;

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('get_src_transit_time: ' || 'transit_time:' || x_intransit_time);
	   msc_sch_wb.atp_debug('get_src_transit_time: ' || 'ship_method:'  || x_ship_method);
	END IF;

END get_src_transit_time;

-- Get Regions Wrapper
-- krajan : bug 2359231
-- Call Get_Regions_old or Get_regions_shipping based on the data in the mapping tables
PROCEDURE Get_Regions (
        p_customer_site_id      IN  NUMBER,
        p_calling_module        IN  NUMBER,  -- i.e. Source (ERP) or Destination (724)
        p_instance_id           IN  NUMBER,
        p_session_id            IN  NUMBER,
        p_dblink                IN  VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        p_location_id           IN  NUMBER ,
        p_location_source       IN  VARCHAR2,
        p_supplier_site_id      IN  NUMBER,-- For supplier intransit LT project
        -- 2814895
        -- Adding new address of customer and party_site
        p_postal_code           IN  VARCHAR2,
        p_city                  IN  VARCHAR2,
        p_state                 IN  VARCHAR2,
        p_country               IN  VARCHAR2,
        p_party_site_id         IN  NUMBER,
        p_order_line_id         IN  NUMBER --2814895, for address parameters
        ) IS   -- For supplier intransit LT project

l_api_to_use    number;

l_temp_var      number;
BEGIN
    if PG_DEBUG in ('Y','C') then
        msc_sch_wb.atp_debug ('---------------Get Regions..................');
        msc_sch_wb.atp_debug (' Customer Site ID    : ' || p_customer_site_id );
        msc_sch_wb.atp_debug (' Calling Module      : ' || p_calling_module);
        msc_sch_wb.atp_debug (' Instance ID         : ' || p_instance_id);
        msc_sch_wb.atp_debug (' Session ID          : ' || p_session_id);
        msc_sch_wb.atp_debug (' DB Link             : ' || p_dblink);
        msc_sch_wb.atp_debug (' Location ID         : ' || p_location_id);
        msc_sch_wb.atp_debug (' Location source     : ' || p_location_source );
    end if;

    l_api_to_use := 1;

    IF ((p_country is not null) --2814895, use the get_regions_old in case only address parameters are given
        AND (p_customer_site_id is NULL)
        AND (p_party_site_id is NULL) ) THEN
        l_api_to_use := 2;
    END IF;

    -- If supplier site is passed then always use the new API
    IF p_supplier_site_id IS NULL THEN -- For supplier intransit LT project
        begin
            -- Bug 3497370 - Handle null calling module
            -- if (p_calling_module = 724) then
            if (nvl(p_calling_module,-99) = 724) then

                select  1
                into    l_temp_var
                from    msc_region_locations
                where   sr_instance_id = p_instance_id
                and     rownum = 1;

            else
                -- bug 2974334. Change the SQL into static
                select  1
                into    l_temp_var
                from    wsh_region_locations
                where   rownum = 1;

            end if;
        exception
            when others then
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug ('Get_Regions: ' || 'Error Code : ' || sqlerrm);
                    msc_sch_wb.atp_debug ('Get_REgions API: Unable to get status of msc(wsh)_region_locations');
                    msc_sch_wb.atp_debug ('Get Regions API: Switching to OLD get_regions');
                END IF;
                l_api_to_use := 2;
        end;
    end if;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug ('Get_Regions API: API to Use : ' || l_api_to_use);
    END IF;
    if (l_api_to_use = 1) then
        MSC_SATP_FUNC.Get_Regions_shipping (
                        p_customer_site_id,
                        p_calling_module,
                        p_instance_id,
                        p_session_id,
                        p_dblink,
                        x_return_status,
                        p_location_id,
                        p_location_source,
                        p_supplier_site_id, -- For supplier intransit LT project
                        p_party_site_id ); --2814895

    else
        MSC_SATP_FUNC.Get_Regions_Old (
                        p_customer_site_id,
                        p_calling_module,
                        p_instance_id,
                        p_session_id,
                        p_dblink,
                        --2814895
                        -- Adding new address of customer
                        p_postal_code,
                        p_city,
                        p_state,
                        p_country,
                        p_order_line_id,
                        x_return_status);
    end if;
end get_regions;


/*   New Extend ATP API
        krajan: 05-Aug-2003

     Inputs:
        MRP_ATP_PUB.atp_rec_typ to extend
        p_tot_size : total size to extend to

     Working:
        p_tot_size is used to calculate the length of the final array:
                value > 0 : extend everything to p_tot_size
                value = 0 : extend everything to inv. item id + 1 (extend by 1)
                value < 0 : extend everything to inv. item id size
*/
procedure new_extend_atp (
        p_atp_tab               IN OUT NOCOPY   MRP_ATP_PUB.atp_rec_typ,
        p_tot_size              IN              number,
        x_return_status         OUT    NOCOPY   varchar2
)
IS
reclength       number;
totlength       number;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** Begin New_Extend_Atp Procedure *****');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if p_tot_size > 0 then
        totlength := p_tot_size;
    elsif p_tot_size = 0 then
        totlength := p_atp_tab.inventory_item_id.count + 1;
    else
        totlength := p_atp_tab.inventory_item_id.count;
    end if;


    reclength := p_atp_tab.Row_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Row_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Instance_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Instance_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Inventory_Item_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Inventory_Item_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Inventory_Item_Name.count;
    if (reclength < totlength) then
        p_atp_tab.Inventory_Item_Name.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Source_Organization_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Source_Organization_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Source_Organization_Code.count;
    if (reclength < totlength) then
        p_atp_tab.Source_Organization_Code.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Organization_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Organization_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Identifier.count;
    if (reclength < totlength) then
        p_atp_tab.Identifier.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Demand_Source_Header_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Demand_Source_Header_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Demand_Source_Delivery.count;
    if (reclength < totlength) then
        p_atp_tab.Demand_Source_Delivery.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Demand_Source_Type.count;
    if (reclength < totlength) then
        p_atp_tab.Demand_Source_Type.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Scenario_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Scenario_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Calling_Module.count;
    if (reclength < totlength) then
        p_atp_tab.Calling_Module.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Customer_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Customer_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Customer_Site_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Customer_Site_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Destination_Time_Zone.count;
    if (reclength < totlength) then
        p_atp_tab.Destination_Time_Zone.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Quantity_Ordered.count;
    if (reclength < totlength) then
        p_atp_tab.Quantity_Ordered.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Quantity_UOM.count;
    if (reclength < totlength) then
        p_atp_tab.Quantity_UOM.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Requested_Ship_Date.count;
    if (reclength < totlength) then
        p_atp_tab.Requested_Ship_Date.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Requested_Arrival_Date.count;
    if (reclength < totlength) then
        p_atp_tab.Requested_Arrival_Date.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Earliest_Acceptable_Date.count;
    if (reclength < totlength) then
        p_atp_tab.Earliest_Acceptable_Date.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Latest_Acceptable_Date.count;
    if (reclength < totlength) then
        p_atp_tab.Latest_Acceptable_Date.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Delivery_Lead_Time.count;
    if (reclength < totlength) then
        p_atp_tab.Delivery_Lead_Time.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Freight_Carrier.count;
    if (reclength < totlength) then
        p_atp_tab.Freight_Carrier.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Ship_Method.count;
    if (reclength < totlength) then
        p_atp_tab.Ship_Method.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Demand_Class.count;
    if (reclength < totlength) then
        p_atp_tab.Demand_Class.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Ship_Set_Name.count;
    if (reclength < totlength) then
        p_atp_tab.Ship_Set_Name.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Arrival_Set_Name.count;
    if (reclength < totlength) then
        p_atp_tab.Arrival_Set_Name.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Override_Flag.count;
    if (reclength < totlength) then
        p_atp_tab.Override_Flag.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Action.count;
    if (reclength < totlength) then
        p_atp_tab.Action.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Ship_Date.count;
    if (reclength < totlength) then
        p_atp_tab.Ship_Date.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Arrival_date.count;
    if (reclength < totlength) then
        p_atp_tab.Arrival_date.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.original_request_date.count;
     if (reclength < totlength) then
         p_atp_tab.original_request_date.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.Available_Quantity.count;
    if (reclength < totlength) then
        p_atp_tab.Available_Quantity.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Requested_Date_Quantity.count;
    if (reclength < totlength) then
        p_atp_tab.Requested_Date_Quantity.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Group_Ship_Date.count;
    if (reclength < totlength) then
        p_atp_tab.Group_Ship_Date.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Group_Arrival_Date.count;
    if (reclength < totlength) then
        p_atp_tab.Group_Arrival_Date.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Vendor_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Vendor_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Vendor_Name.count;
    if (reclength < totlength) then
        p_atp_tab.Vendor_Name.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Vendor_Site_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Vendor_Site_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Vendor_Site_Name.count;
    if (reclength < totlength) then
        p_atp_tab.Vendor_Site_Name.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Insert_Flag.count;
    if (reclength < totlength) then
        p_atp_tab.Insert_Flag.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.OE_Flag.count;
    if (reclength < totlength) then
        p_atp_tab.OE_Flag.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Atp_Lead_Time.count;
    if (reclength < totlength) then
        p_atp_tab.Atp_Lead_Time.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Error_Code.count;
    if (reclength < totlength) then
        p_atp_tab.Error_Code.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Message.count;
    if (reclength < totlength) then
        p_atp_tab.Message.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.End_Pegging_Id.count;
    if (reclength < totlength) then
        p_atp_tab.End_Pegging_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Order_Number.count;
    if (reclength < totlength) then
        p_atp_tab.Order_Number.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Old_Source_Organization_Id.count;
    if (reclength < totlength) then
        p_atp_tab.Old_Source_Organization_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Old_Demand_Class.count;
    if (reclength < totlength) then
        p_atp_tab.Old_Demand_Class.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.ato_delete_flag.count;
    if (reclength < totlength) then
        p_atp_tab.ato_delete_flag.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_01.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_01.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_02.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_02.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_03.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_03.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_04.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_04.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_05.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_05.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_06.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_06.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_07.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_07.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_08.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_08.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_09.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_09.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_10.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_10.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.customer_name.count;
    if (reclength < totlength) then
        p_atp_tab.customer_name.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.customer_class.count;
    if (reclength < totlength) then
        p_atp_tab.customer_class.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.customer_location.count;
    if (reclength < totlength) then
        p_atp_tab.customer_location.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.customer_country.count;
    if (reclength < totlength) then
        p_atp_tab.customer_country.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.customer_state.count;
    if (reclength < totlength) then
        p_atp_tab.customer_state.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.customer_city.count;
    if (reclength < totlength) then
        p_atp_tab.customer_city.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.customer_postal_code.count;
    if (reclength < totlength) then
        p_atp_tab.customer_postal_code.extend (totlength - reclength);
    end if;

    --2814895
    reclength := p_atp_tab.party_site_id.count;
    if (reclength < totlength) then
        p_atp_tab.party_site_id.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.substitution_typ_code.count;
    if (reclength < totlength) then
        p_atp_tab.substitution_typ_code.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.req_item_detail_flag.count;
    if (reclength < totlength) then
        p_atp_tab.req_item_detail_flag.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.request_item_id.count;
    if (reclength < totlength) then
        p_atp_tab.request_item_id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.req_item_req_date_qty.count;
    if (reclength < totlength) then
        p_atp_tab.req_item_req_date_qty.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.req_item_available_date.count;
    if (reclength < totlength) then
        p_atp_tab.req_item_available_date.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.req_item_available_date_qty.count;
    if (reclength < totlength) then
        p_atp_tab.req_item_available_date_qty.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.request_item_name.count;
    if (reclength < totlength) then
        p_atp_tab.request_item_name.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.old_inventory_item_id.count;
    if (reclength < totlength) then
        p_atp_tab.old_inventory_item_id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.sales_rep.count;
    if (reclength < totlength) then
        p_atp_tab.sales_rep.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.customer_contact.count;
    if (reclength < totlength) then
        p_atp_tab.customer_contact.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.subst_flag.count;
    if (reclength < totlength) then
        p_atp_tab.subst_flag.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Top_Model_line_id.count;
    if (reclength < totlength) then
        p_atp_tab.Top_Model_line_id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.ATO_Parent_Model_Line_Id.count;
    if (reclength < totlength) then
        p_atp_tab.ATO_Parent_Model_Line_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.ATO_Model_Line_Id.count;
    if (reclength < totlength) then
        p_atp_tab.ATO_Model_Line_Id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Parent_line_id.count;
    if (reclength < totlength) then
        p_atp_tab.Parent_line_id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.match_item_id.count;
    if (reclength < totlength) then
        p_atp_tab.match_item_id.extend (totlength - reclength);
    end if;

     reclength := p_atp_tab.matched_item_name.count;
    if (reclength < totlength) then
        p_atp_tab.matched_item_name.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Config_item_line_id.count;
    if (reclength < totlength) then
        p_atp_tab.Config_item_line_id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Validation_Org.count;
    if (reclength < totlength) then
        p_atp_tab.Validation_Org.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Component_Sequence_ID.count;
    if (reclength < totlength) then
        p_atp_tab.Component_Sequence_ID.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Component_Code.count;
    if (reclength < totlength) then
        p_atp_tab.Component_Code.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.line_number.count;
    if (reclength < totlength) then
        p_atp_tab.line_number.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.included_item_flag.count;
    if (reclength < totlength) then
        p_atp_tab.included_item_flag.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.atp_flag.count;
    if (reclength < totlength) then
        p_atp_tab.atp_flag.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.atp_components_flag.count;
    if (reclength < totlength) then
        p_atp_tab.atp_components_flag.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.wip_supply_type.count;
    if (reclength < totlength) then
        p_atp_tab.wip_supply_type.extend (totlength - reclength);
    end if;

   reclength := p_atp_tab.bom_item_type.count;
    if (reclength < totlength) then
        p_atp_tab.bom_item_type.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.mandatory_item_flag.count;
    if (reclength < totlength) then
        p_atp_tab.mandatory_item_flag.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.pick_components_flag.count;
    if (reclength < totlength) then
        p_atp_tab.pick_components_flag.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.base_model_id.count;
    if (reclength < totlength) then
        p_atp_tab.base_model_id.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.OSS_ERROR_CODE.count;
    if (reclength < totlength) then
        p_atp_tab.OSS_ERROR_CODE.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.matched_item_name.count;
    if (reclength < totlength) then
        p_atp_tab.matched_item_name.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.cascade_model_info_to_comp.count;
    if (reclength < totlength) then
        p_atp_tab.cascade_model_info_to_comp.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.firm_flag.count;
    if (reclength < totlength) then
        p_atp_tab.firm_flag.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.order_line_number.count;
    if (reclength < totlength) then
        p_atp_tab.order_line_number.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.option_number.count;
    if (reclength < totlength) then
        p_atp_tab.option_number.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.shipment_number.count;
    if (reclength < totlength) then
        p_atp_tab.shipment_number.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.item_desc.count;
    if (reclength < totlength) then
        p_atp_tab.item_desc.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.old_line_schedule_date.count;
    if (reclength < totlength) then
        p_atp_tab.old_line_schedule_date.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.old_source_organization_code.count;
    if (reclength < totlength) then
        p_atp_tab.old_source_organization_code.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.firm_source_org_id.count;
    if (reclength < totlength) then
        p_atp_tab.firm_source_org_id.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.firm_source_org_code.count;
    if (reclength < totlength) then
        p_atp_tab.firm_source_org_code.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.firm_ship_date.count;
    if (reclength < totlength) then
        p_atp_tab.firm_ship_date.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.firm_arrival_date.count;
    if (reclength < totlength) then
        p_atp_tab.firm_arrival_date.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.ship_method_text.count;
    if (reclength < totlength) then
        p_atp_tab.ship_method_text.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.ship_set_id.count;
    if (reclength < totlength) then
        p_atp_tab.ship_set_id.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.arrival_set_id.count;
    if (reclength < totlength) then
        p_atp_tab.arrival_set_id.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.PROJECT_ID.count;
    if (reclength < totlength) then
        p_atp_tab.PROJECT_ID.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.TASK_ID.count;
    if (reclength < totlength) then
        p_atp_tab.TASK_ID.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.PROJECT_NUMBER.count;
    if (reclength < totlength) then
        p_atp_tab.PROJECT_NUMBER.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.TASK_NUMBER.count;
    if (reclength < totlength) then
        p_atp_tab.TASK_NUMBER.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.attribute_11.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_11.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_12.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_12.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_13.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_13.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_14.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_14.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_15.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_15.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_16.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_16.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_17.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_17.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_18.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_18.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_19.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_19.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_20.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_20.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.Attribute_21.count;
    if (reclength < totlength) then
        p_atp_tab.Attribute_21.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_22.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_22.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_23.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_23.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_24.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_24.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_25.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_25.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_26.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_26.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_27.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_27.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_28.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_28.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_29.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_29.extend (totlength - reclength);
    end if;


    reclength := p_atp_tab.attribute_30.count;
    if (reclength < totlength) then
        p_atp_tab.attribute_30.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.atf_date.count;
    if (reclength < totlength) then
        p_atp_tab.atf_date.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.plan_id.count;
    if (reclength < totlength) then
        p_atp_tab.plan_id.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.original_request_date.count;
    if (reclength < totlength) then
        p_atp_tab.original_request_date.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.receiving_cal_code.count;
    if (reclength < totlength) then
        p_atp_tab.receiving_cal_code.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.intransit_cal_code.count;
    if (reclength < totlength) then
        p_atp_tab.intransit_cal_code.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.shipping_cal_code.count;
    if (reclength < totlength) then
        p_atp_tab.shipping_cal_code.extend (totlength - reclength);
    end if;

    reclength := p_atp_tab.manufacturing_cal_code.count;
    if (reclength < totlength) then
        p_atp_tab.manufacturing_cal_code.extend (totlength - reclength);
    end if;

    -- Bug 3449812
    reclength := p_atp_tab.internal_org_id.count;
    if (reclength < totlength) then
        p_atp_tab.internal_org_id.extend (totlength - reclength);
    end if;

     -- Bug 3328421
    reclength := p_atp_tab.first_valid_ship_arrival_date.count;
    if (reclength < totlength) then
        p_atp_tab.first_valid_ship_arrival_date.extend (totlength - reclength);
    end if;
    --4500382 Starts
    reclength := p_atp_tab.part_of_set.count;
    if (reclength < totlength) then
        p_atp_tab.part_of_set.extend (totlength - reclength);
    end if;
    --4500382 ENDS

EXCEPTION
    when others then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        msc_sch_wb.atp_debug ('Exception in New extend');
        msc_sch_wb.atp_debug ('Sqlcode ' || sqlcode);
        msc_sch_wb.atp_debug ('Sqlerr  ' || sqlerrm);
END new_extend_atp;

/*--------------------------------------------------------------------------
|  Begin Functions added for ship_rec_cal project
+-------------------------------------------------------------------------*/

FUNCTION Src_Get_Calendar_Code(
			p_customer_id		IN number,
			p_customer_site_id	IN number,
			p_organization_id	IN number,
			p_ship_method_code      IN varchar2,
			p_calendar_type  	IN integer -- One of OSC, CRC or VIC
			) RETURN VARCHAR2
IS
	l_calendar_code		VARCHAR2(14)    := MSC_CALENDAR.FOC;
	l_ship_method_code      VARCHAR2(50)    := NVL(p_ship_method_code, '@@@');
	l_customer_site_id	NUMBER          := NVL(p_customer_site_id, -1);
	l_calendar_type         VARCHAR2(15);   -- Bug 3449812

BEGIN
        IF PG_DEBUG in ('Y','C') THEN
                msc_sch_wb.atp_debug ('***** Begin Function Src_Get_Calendar_Code *****');
                msc_sch_wb.atp_debug ('________________Input________________');
                msc_sch_wb.atp_debug (' Customer ID         : ' || p_customer_id );
                msc_sch_wb.atp_debug (' Customer Site ID    : ' || p_customer_site_id );
                msc_sch_wb.atp_debug (' Organization ID     : ' || p_organization_id);
                msc_sch_wb.atp_debug (' Ship Method Code    : ' || p_ship_method_code);
                msc_sch_wb.atp_debug (' Calendar Type       : ' || p_calendar_type);
                msc_sch_wb.atp_debug (' G_USE_SHIP_REC_CAL  : ' || MSC_ATP_PVT.G_USE_SHIP_REC_CAL);
                msc_sch_wb.atp_debug (' ');
        END IF;

        -- Bug 3647208 - Move the check inside individual "IF"s
        -- IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
            -- l_calendar_code is already initialized to FOC

        -- case 1. Searching for a valid customer receiving calendar (CRC)
        IF (p_calendar_type = MSC_CALENDAR.CRC) THEN

            -- Bug 3647208 - Move the check inside individual "IF"s
            IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
                -- l_calendar_code is already initialized to FOC

        	-- Using the fact the length of association_types carrier_customer_site (21),
        	-- carrier_customer (16), customer_site (13), customer (8) can be used to order by

        	SELECT	calendar_code
        	INTO	l_calendar_code
        	FROM	(SELECT wca.CALENDAR_CODE
        		FROM	WSH_CARRIERS wc,
                                WSH_CALENDAR_ASSIGNMENTS wca,
                                WSH_CARRIER_SERVICES wcs,
                                WSH_CARRIER_SERVICES wcs1
        		WHERE	wc.FREIGHT_CODE(+) = wca.FREIGHT_CODE
                        AND     wc.CARRIER_ID = wcs.CARRIER_ID(+)
                        AND     wca.CARRIER_ID = wcs1.CARRIER_ID(+)
                        AND     wca.ENABLED_FLAG = 'Y'
                        AND     wca.CUSTOMER_ID = p_customer_id
        		AND	wca.CALENDAR_TYPE in ('RECEIVING', 'CARRIER')
        		AND	NVL(wca.CUSTOMER_SITE_USE_ID, l_customer_site_id)  = l_customer_site_id
        		AND	NVL(decode(wca.ASSOCIATION_TYPE,
        		                        'CARRIER',wcs1.SHIP_METHOD_CODE,
        		                        'CARRIER_SITE',wcs1.SHIP_METHOD_CODE,
        		                        wcs.SHIP_METHOD_CODE),
        		            l_ship_method_code) = l_ship_method_code
        		AND     wca.ASSOCIATION_TYPE in ('VENDOR_SITE','CUSTOMER_SITE','VENDOR','CUSTOMER','ORGANIZATION','CARRIER')
        		ORDER BY LENGTH(decode(wca.association_type,
        		                        'CUSTOMER', decode(wca.CALENDAR_TYPE,'CARRIER','CARRIER_CUSTOMER','CUSTOMER'),
                                                'CUSTOMER_SITE',decode(wca.CALENDAR_TYPE,'CARRIER','CARRIER_CUSTOMER_SITE','CUSTOMER_SITE'))) DESC)
        	WHERE	ROWNUM = 1;

            END IF;

        -- case 2. Org's Shipping Calendar (OSC)
        -- Bug 3449812 - Added support for ORC for ISOs
        ELSIF (p_calendar_type = MSC_CALENDAR.OSC OR p_calendar_type = MSC_CALENDAR.ORC) THEN

            -- Bug 3647208 - Move the check inside individual "IF"s
            IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN

        	-- Using the fact the length of association_types carrier_organization (20),
        	-- organization (12) can be used to order by

        	IF p_calendar_type = MSC_CALENDAR.ORC THEN
        	        l_calendar_type := 'RECEIVING';
        	ELSE
        	        l_calendar_type := 'SHIPPING';
        	END IF;

        	SELECT	calendar_code
        	INTO	l_calendar_code
        	FROM	(SELECT wca.CALENDAR_CODE
        		FROM	WSH_CARRIERS wc,
                                WSH_CALENDAR_ASSIGNMENTS wca,
                                WSH_CARRIER_SERVICES wcs,
                                WSH_CARRIER_SERVICES wcs1
        		WHERE	wc.FREIGHT_CODE(+) = wca.FREIGHT_CODE
                        AND     wc.CARRIER_ID = wcs.CARRIER_ID(+)
                        AND     wca.CARRIER_ID = wcs1.CARRIER_ID(+)
                        AND     wca.ENABLED_FLAG = 'Y'
                        AND     wca.ORGANIZATION_ID = p_organization_id
        		AND	wca.CALENDAR_TYPE in (l_calendar_type, 'CARRIER')       -- Bug 3449812
        		AND	NVL(decode(wca.ASSOCIATION_TYPE,
        		                        'CARRIER',wcs1.SHIP_METHOD_CODE,
        		                        'CARRIER_SITE',wcs1.SHIP_METHOD_CODE,
        		                        wcs.SHIP_METHOD_CODE),
        		            l_ship_method_code) = l_ship_method_code
        		AND     wca.ASSOCIATION_TYPE in ('VENDOR_SITE','CUSTOMER_SITE','VENDOR','CUSTOMER','ORGANIZATION','CARRIER')
        		ORDER BY LENGTH(decode(wca.association_type,
        		                        'ORGANIZATION', decode(wca.CALENDAR_TYPE,'CARRIER','CARRIER_ORGANIZATION','ORGANIZATION'))) DESC)
        	WHERE	ROWNUM = 1;

            ELSE

                -- Bug 3647208 - For b/w compatibility use OMC instead of ORC/OSC
                -- Raise exception so that the OMC query gets executed.
                IF PG_DEBUG in ('Y','C') THEN
                    msc_sch_wb.atp_debug ('Src_Get_Calendar_Code :' || ' Use OMC instead on ORC/OSC');
                END IF;
                RAISE NO_DATA_FOUND;

            END IF;

        -- case 3. Searching for valid Intransit Calendar (VIC)
        ELSIF (p_calendar_type = MSC_CALENDAR.VIC) THEN

            -- Bug 3647208 - Move the check inside individual "IF"s
            IF MSC_ATP_PVT.G_USE_SHIP_REC_CAL='Y' THEN
                -- l_calendar_code is already initialized to FOC

        	SELECT  wca.CALENDAR_CODE
		INTO    l_calendar_code
		FROM	WSH_CALENDAR_ASSIGNMENTS wca,
                        WSH_CARRIER_SERVICES wcs
		WHERE	wca.CARRIER_ID = wcs.CARRIER_ID
		AND     wca.CALENDAR_TYPE = 'CARRIER'
		AND     wca.ASSOCIATION_TYPE = 'CARRIER'
                AND     wca.ENABLED_FLAG = 'Y'
		AND	NVL(wcs.SHIP_METHOD_CODE, l_ship_method_code) = l_ship_method_code;

            END IF;

        END IF;

        IF PG_DEBUG in ('Y','C') THEN
                msc_sch_wb.atp_debug ('________________Output________________');
                msc_sch_wb.atp_debug (' Calendar Code       : ' || l_calendar_code);
                msc_sch_wb.atp_debug (' ');
        END IF;

	RETURN	l_calendar_code;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
        	-- Bug 3449812 - Added support for ORC for ISOs
        	IF (p_calendar_type = MSC_CALENDAR.ORC OR p_calendar_type = MSC_CALENDAR.OSC) THEN
                	-- Return OMC.
                	SELECT	calendar_code
                	INTO	l_calendar_code
                	FROM	MTL_PARAMETERS
                	WHERE	ORGANIZATION_ID			= p_organization_id
                	AND	CALENDAR_EXCEPTION_SET_ID	= -1;
        	END IF;

                IF PG_DEBUG in ('Y','C') THEN
                        msc_sch_wb.atp_debug ('****** No Data Found Exception *******');
                        msc_sch_wb.atp_debug ('________________Output________________');
                        msc_sch_wb.atp_debug (' Calendar Code       : ' || l_calendar_code);
                        msc_sch_wb.atp_debug (' ');
                END IF;

        	RETURN l_calendar_code;

END Src_Get_Calendar_Code;

-- Overloaded Functions driven by calendar_code rather than org_id
FUNCTION Src_NEXT_WORK_DAY(
			p_calendar_code		IN varchar2,
			p_calendar_date		IN date
			) RETURN DATE
IS
	l_next_work_day		DATE;
	l_first_work_day	DATE;
	l_last_work_day		DATE;
BEGIN
	IF (p_calendar_code IS NULL) OR
			(p_calendar_date IS NULL) THEN
		--RETURN NULL; bug3583705
		RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
	END IF;

	IF (p_calendar_code = MSC_CALENDAR.FOC) THEN
		RETURN p_calendar_date;
	END IF;

	BEGIN

		SELECT	NEXT_DATE
		INTO	l_next_work_day
		FROM	BOM_CALENDAR_DATES
		WHERE	CALENDAR_CODE		= p_calendar_code
		AND	EXCEPTION_SET_ID	= -1
		AND	CALENDAR_DATE		= TRUNC(p_calendar_date);

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN --bug3583705
            IF MSC_CALENDAR.G_RETAIN_DATE = 'Y' THEN
                BEGIN
                    SELECT  min(calendar_date), max(calendar_date)
                    INTO    l_first_work_day, l_last_work_day
                    FROM    BOM_CALENDAR_DATES
                    WHERE   CALENDAR_CODE	= p_calendar_code
                    AND     SEQ_NUM is not null;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END;

                IF p_calendar_date >= l_last_work_day THEN
                    l_next_work_day := l_last_work_day;
                ELSIF p_calendar_date <= l_first_work_day THEN
                    l_next_work_day := l_first_work_day;
                ELSE
                    RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
	END;
	RETURN	l_next_work_day;

END Src_NEXT_WORK_DAY;

FUNCTION Src_PREV_WORK_DAY(
			p_calendar_code		IN varchar2,
			p_calendar_date		IN date
			) RETURN DATE
IS
	l_prev_work_day		DATE;
	l_first_work_day	DATE;
	l_last_work_day		DATE;
BEGIN
	IF (p_calendar_code IS NULL) OR
		(p_calendar_date IS NULL) THEN
		--RETURN NULL; bug3583705
		RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
	END IF;

	IF (p_calendar_code = MSC_CALENDAR.FOC) THEN
		RETURN p_calendar_date;
	END IF;

	BEGIN

		SELECT	PRIOR_DATE
		INTO	l_prev_work_day
		FROM	BOM_CALENDAR_DATES
		WHERE	CALENDAR_CODE		= p_calendar_code
		AND	EXCEPTION_SET_ID	= -1
		AND	CALENDAR_DATE		= TRUNC(p_calendar_date);

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN --bug3583705
            IF MSC_CALENDAR.G_RETAIN_DATE = 'Y' THEN
                BEGIN
                    SELECT  min(calendar_date), max(calendar_date)
                    INTO    l_first_work_day, l_last_work_day
                    FROM    BOM_CALENDAR_DATES
                    WHERE   CALENDAR_CODE	= p_calendar_code
                    AND     SEQ_NUM is not null;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END;

                IF p_calendar_date >= l_last_work_day THEN
                    l_prev_work_day := l_last_work_day;
                ELSIF p_calendar_date <= l_first_work_day THEN
                    l_prev_work_day := l_first_work_day;
                ELSE
                    RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                END IF;
            ELSE
                FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
	END;

	RETURN	l_prev_work_day;

END Src_PREV_WORK_DAY;

FUNCTION Src_DATE_OFFSET(
			p_calendar_code		IN varchar2,
			p_calendar_date		IN date,
			p_days_offset		IN number,
			p_offset_type           IN number
			) RETURN DATE
IS
	l_offsetted_day		DATE;
	l_days_offset		NUMBER;
	l_first_work_day	DATE;
	l_last_work_day		DATE;
BEGIN
	IF (p_calendar_code IS NULL) OR
		(p_calendar_date IS NULL) OR
			(p_days_offset IS NULL) THEN
		--RETURN NULL; bug3583705
		RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
	END IF;

	IF (p_days_offset = 0) and (p_calendar_code = MSC_CALENDAR.FOC) THEN
	        RETURN p_calendar_date;
	ELSIF (p_days_offset = 0) and (p_offset_type = -1) THEN
	        l_offsetted_day := MSC_SATP_FUNC.SRC_PREV_WORK_DAY(
	                                                p_calendar_code,
	                                                p_calendar_date);
	ELSIF (p_days_offset = 0) and (p_offset_type = +1) THEN --bug3558412
	        l_offsetted_day := MSC_SATP_FUNC.SRC_NEXT_WORK_DAY(
	                                                p_calendar_code,
	                                                p_calendar_date);
	ELSE
        	IF p_days_offset > 0 THEN
        		l_days_offset := CEIL(p_days_offset);
        	ELSE
        		l_days_offset := FLOOR(p_days_offset);
        	END IF;

        	IF p_calendar_code = MSC_CALENDAR.FOC THEN
        		RETURN p_calendar_date + l_days_offset;
        	END IF;

        	IF p_days_offset > 0 THEN
            	BEGIN
            		SELECT	cal2.calendar_date
            		INTO	l_offsetted_day
            		FROM	BOM_CALENDAR_DATES cal1, BOM_CALENDAR_DATES cal2
            		WHERE	cal1.calendar_code	= p_calendar_code
            		AND	cal1.exception_set_id	= -1
            		AND	cal1.calendar_date	= TRUNC(p_calendar_date)
            		AND	cal2.calendar_code	= cal1.calendar_code
            		AND	cal2.exception_set_id	= cal1.exception_set_id
            		AND     cal2.seq_num		= cal1.prior_seq_num + l_days_offset; --bug3558412
            		--AND	cal2.seq_num		= cal1.next_seq_num + l_days_offset;

            	EXCEPTION
            	   WHEN NO_DATA_FOUND THEN --bug3583705
                     IF MSC_CALENDAR.G_RETAIN_DATE = 'Y' THEN
                        BEGIN
                         SELECT  min(calendar_date), max(calendar_date)
                         INTO    l_first_work_day, l_last_work_day
                         FROM    BOM_CALENDAR_DATES
                         WHERE   CALENDAR_CODE	= p_calendar_code
                         AND     SEQ_NUM is not null;
                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                        END;

                       IF p_calendar_date >= l_last_work_day THEN
                          l_offsetted_day := l_last_work_day;
                       ELSIF p_calendar_date <= l_first_work_day THEN
                          l_offsetted_day := l_first_work_day;
                       ELSE
                          RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                       END IF;
                     ELSE
                        FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                        APP_EXCEPTION.RAISE_EXCEPTION;
                     END IF;
            	END;
        	ELSE
            	BEGIN
            		SELECT	cal2.calendar_date
            		INTO	l_offsetted_day
            		FROM	BOM_CALENDAR_DATES cal1, BOM_CALENDAR_DATES cal2
            		WHERE	cal1.calendar_code	= p_calendar_code
            		AND	cal1.exception_set_id	= -1
            		AND	cal1.calendar_date	= TRUNC(p_calendar_date)
            		AND	cal2.calendar_code	= cal1.calendar_code
            		AND	cal2.exception_set_id	= cal1.exception_set_id
            		AND     cal2.seq_num		= cal1.next_seq_num + l_days_offset; --bug3558412
            		--AND	cal2.seq_num		= cal1.prior_seq_num + l_days_offset;

            	EXCEPTION
            	   WHEN NO_DATA_FOUND THEN --bug3583705
                     IF MSC_CALENDAR.G_RETAIN_DATE = 'Y' THEN
                        BEGIN
                         SELECT  min(calendar_date), max(calendar_date)
                         INTO    l_first_work_day, l_last_work_day
                         FROM    BOM_CALENDAR_DATES
                         WHERE   CALENDAR_CODE	= p_calendar_code
                         AND     SEQ_NUM is not null;
                        EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                        END;

                       IF p_calendar_date >= l_last_work_day THEN
                          l_offsetted_day := l_last_work_day;
                       ELSIF p_calendar_date <= l_first_work_day THEN
                          l_offsetted_day := l_first_work_day;
                       ELSE
                          RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
                       END IF;
                     ELSE
                        FND_MESSAGE.SET_NAME('MRP', 'GEN-DATE OUT OF BOUNDS');
                        APP_EXCEPTION.RAISE_EXCEPTION;
                     END IF;
            	END;
            END IF;
        END IF;

	RETURN	l_offsetted_day;

END Src_DATE_OFFSET;

FUNCTION SRC_THREE_STEP_CAL_OFFSET_DATE(
			p_input_date			IN Date,
			p_first_cal_code		IN VARCHAR2,
			p_first_cal_validation_type	IN NUMBER,
			p_second_cal_code		IN VARCHAR2,
			p_offset_days			IN NUMBER,
			p_second_cal_validation_type	IN NUMBER,
			p_third_cal_code		IN VARCHAR2,
			p_third_cal_validation_type	IN NUMBER
			) RETURN DATE
IS
	l_first_date	DATE := NULL;
	l_second_date	DATE := NULL;
	l_output_date	DATE := NULL;

BEGIN
    IF PG_DEBUG in ('Y','C') THEN
            msc_sch_wb.atp_debug ('***** Begin Function THREE_STEP_CAL_OFFSET_DATE *****');
            msc_sch_wb.atp_debug ('________________Input________________');
            msc_sch_wb.atp_debug (' Input Date          : ' || p_input_date );
            msc_sch_wb.atp_debug (' First Cal Code      : ' || p_first_cal_code );
            msc_sch_wb.atp_debug (' Second Cal Code     : ' || p_second_cal_code );
            msc_sch_wb.atp_debug (' Third Cal Code      : ' || p_third_cal_code );
            msc_sch_wb.atp_debug (' Days Offset         : ' || p_offset_days );
            msc_sch_wb.atp_debug (' ');
    END IF;
	-- First date is computed using p_input_date, first calendar and its validation_type
	IF p_first_cal_code = MSC_CALENDAR.FOC THEN
		l_first_date := p_input_date;
	ELSIF p_first_cal_validation_type = -1 THEN
		l_first_date := MSC_SATP_FUNC.SRC_PREV_WORK_DAY(
				p_first_cal_code,
				p_input_date);
	ELSIF p_first_cal_validation_type = 1 THEN
		l_first_date := MSC_SATP_FUNC.SRC_NEXT_WORK_DAY(
				p_first_cal_code,
				p_input_date);
	ELSE
		l_first_date := p_input_date;
	END IF;

    IF PG_DEBUG in ('Y','C') THEN
            msc_sch_wb.atp_debug (' Date after validation on first cal: ' || l_first_date );
    END IF;

	-- Second date is computed using first date, 2nd calendar and offset days
	IF (p_offset_days = 0) and (p_second_cal_code = MSC_CALENDAR.FOC) THEN
	        l_second_date := l_first_date;
	ELSIF (p_offset_days = 0) and (p_second_cal_validation_type = -1) THEN
		l_second_date := MSC_SATP_FUNC.SRC_PREV_WORK_DAY(
				p_second_cal_code,
				l_first_date);
	ELSIF (p_offset_days = 0) and (p_second_cal_validation_type = 1) THEN
		l_second_date := MSC_SATP_FUNC.SRC_NEXT_WORK_DAY(
				p_second_cal_code,
				l_first_date);
	ELSIF p_second_cal_code = MSC_CALENDAR.FOC THEN
	        l_second_date := l_first_date + p_offset_days;
	ELSIF p_offset_days > 0 THEN
---Bug 6625744 start---
					l_first_date:=MSC_SATP_FUNC.SRC_NEXT_WORK_DAY(
								p_second_cal_code,
								l_first_date);
---Bug 6625744 end---
        	l_second_date := MSC_SATP_FUNC.SRC_DATE_OFFSET(
        				p_second_cal_code,
        				l_first_date,
        				p_offset_days,
        				+1);
	ELSIF p_offset_days < 0 THEN
---Bug 6625744 start---
					l_first_date:=MSC_SATP_FUNC.SRC_PREV_WORK_DAY(
								p_second_cal_code,
								l_first_date);
---Bug 6625744 end---
        	l_second_date := MSC_SATP_FUNC.SRC_DATE_OFFSET(
        				p_second_cal_code,
        				l_first_date,
        				p_offset_days,
        				-1);
	ELSE
		l_second_date := l_first_date;
	END IF;

    IF PG_DEBUG in ('Y','C') THEN
            msc_sch_wb.atp_debug (' Date after offset using second cal: ' || l_second_date );
    END IF;

	-- Third date = Output Date is computed using 2nd date, 3rd calendar and validation_type
	IF p_third_cal_code = MSC_CALENDAR.FOC THEN
		l_output_date := l_second_date;
	ELSIF p_third_cal_validation_type = -1 THEN
		l_output_date := MSC_SATP_FUNC.SRC_PREV_WORK_DAY(
				p_third_cal_code,
				l_second_date);
	ELSIF p_third_cal_validation_type = 1 THEN
		l_output_date := MSC_SATP_FUNC.SRC_NEXT_WORK_DAY(
				p_third_cal_code,
				l_second_date);
	ELSE
		l_output_date := l_second_date;
	END IF;

    IF PG_DEBUG in ('Y','C') THEN
            msc_sch_wb.atp_debug (' Date after validation on third cal: ' || l_output_date );
    END IF;

	RETURN l_output_date;

END SRC_THREE_STEP_CAL_OFFSET_DATE;

/*--------------------------------------------------------------------------
|  End Functions added for ship_rec_cal project
+-------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
|  Begin Functions added for collection enhancement project-3049003
+-------------------------------------------------------------------------*/

PROCEDURE get_dblink_profile(
x_dblink                  OUT NOCOPY VARCHAR2,
x_instance_id	 	  OUT NOCOPY NUMBER,
x_return_status           OUT     NOCOPY VARCHAR2
)
IS

Begin
	 IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Begin get_dblink_profile');
         END IF;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

         --Bug3765793 adding trim functions to remove spaces from db_link
         SELECT instance_id, ltrim(rtrim(a2m_dblink))
         INTO   x_instance_id, x_dblink
         FROM   mrp_ap_apps_instances;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('get_dblink_profile: ' || 'x_instance_id := ' || NVL(x_instance_id, -1));
            msc_sch_wb.atp_debug('get_dblink_profile: ' || 'a2m_dblink := ' || NVL(x_dblink,'NULL'));
         END IF;
EXCEPTION
         WHEN others THEN
                -- something wrong so we want to rollback;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Error in mrp_ap_apps_instances : ' || sqlcode);
                END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

End get_dblink_profile;

/*--------------------------------------------------------------------------
|  End Functions added for collection enhancement project-aksaxena
+-------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
|  Begin Procedure get_src_to_dstn_profiles added for supporting Multiple
|  allocation enh -3940999 Inserts values of profiles at source in table
|  msc_atp_src_profile_temp..
+-------------------------------------------------------------------------*/
PROCEDURE put_src_to_dstn_profiles(
p_session_id                  IN NUMBER,
x_return_status               OUT   NoCopy VARCHAR2
                               ) IS

l_profile_name                MRP_ATP_PUB.char255_arr := MRP_ATP_PUB.char255_arr();
j                             NUMBER := 1;
l_user_id                     number;
l_count                       number;
l_sysdate                     DATE := TRUNC(sysdate);

BEGIN
   -- initialize API returm status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_user_id := FND_GLOBAL.USER_ID;
    l_count   := 10; --optional_fw

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('enter put_src_to_dstn_profiles');
       msc_sch_wb.atp_debug('put_src_to_dstn_profiles: ' || 'p_session_id := ' || p_session_id);
       msc_sch_wb.atp_debug('put_src_to_dstn_profiles: ' || 'l_user_id := ' || l_user_id);
    END IF;

    -- Delete records from msc_atp_src_profile_temp in case there are any records
    -- with similar session id.
    Delete from msc_atp_src_profile_temp where session_id = p_session_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** After Deleting data for old session ****');
       msc_sch_wb.atp_debug('put_src_to_dstn_profiles: ' || 'Number of rows deleted ' || SQL%ROWCOUNT);
    END IF;

    l_profile_name.extend(l_count);
    l_profile_name(1) := 'MSC_ALLOCATION_METHOD';
    l_profile_name(2) := 'MSC_ALLOCATED_ATP';
    l_profile_name(3) := 'MSC_CLASS_HIERARCHY';
    l_profile_name(4) := 'INV_CTP';
    l_profile_name(5) := 'MSC_ALLOCATED_ATP_WORKFLOW';
    l_profile_name(6) := 'MSC_USE_SHIP_REC_CAL';
    l_profile_name(7) := 'MSC_MOVE_PAST_DUE_TO_SYSDATE'; --6316476
    l_profile_name(8) := 'MSC_ZERO_ALLOC_PERC'; --6359986
    l_profile_name(9) := 'MSC_ATP_CHECK_INT_SALES_ORDERS'; --6485306
    l_profile_name(10) := 'MSC_ENHANCED_FORWARD_ATP'; --optional_fw

    FOR j in 1..l_count LOOP
    INSERT INTO msc_atp_src_profile_temp
    (
    session_id,
    profile_name,
    profile_value,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    values
    (p_session_id,
     l_profile_name(j),
     fnd_profile.value(l_profile_name(j)),
     l_sysdate,
     l_user_id,
     l_sysdate,
     l_user_id,
     l_user_id
     );
    END LOOP;

     IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('put_src_to_dstn_profiles: ' || 'Rows inserted ' || SQL%ROWCOUNT );
     END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug(' Error in put_src_to_dstn_profiles '||substr(sqlerrm,1,100));
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
END put_src_to_dstn_profiles;
/*--------------------------------------------------------------------------
|  End Procedure put_src_to_dstn_profiles added for Multiple allocation enh -3940999
+-------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
|  Begin Procedure get_src_to_dstn_profiles added for supporting Multiple
|  allocation enh -3940999 Inserts values of profiles at destination by
|  reading them from table msc_atp_src_profile_temp at source.
+-------------------------------------------------------------------------*/

PROCEDURE get_src_to_dstn_profiles(
p_dblink                      IN VARCHAR2,
p_session_id                  IN NUMBER,
x_return_status               OUT   NoCopy VARCHAR2
                               ) IS

l_profile_name                MRP_ATP_PUB.char255_arr := MRP_ATP_PUB.char255_arr();
j                             NUMBER;
l_dynstring                   VARCHAR2(128) := NULL;
l_user_id                     number;
l_sql_stmt                    varchar2(2000);

BEGIN
   -- initialize API returm status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('enter get_src_to_dstn_profiles');
      msc_sch_wb.atp_debug('get_src_to_dstn_profiles: ' || 'p_session_id := ' || p_session_id);
      msc_sch_wb.atp_debug('get_src_to_dstn_profiles ' || 'p_dblink := ' || NVL(p_dblink,'NULL'));
   END IF;

    l_dynstring := '@'||p_dblink;
    l_user_id := FND_GLOBAL.USER_ID;

     -- Delete records from msc_atp_src_profile_temp in case there are any records
     -- with similar session id.
     Delete from msc_atp_src_profile_temp where session_id = p_session_id;

     IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** After Deleting data for old session ****');
       msc_sch_wb.atp_debug('get_src_to_dstn_profiles: ' || 'Number of rows deleted ' || SQL%ROWCOUNT);
     END IF;

     l_sql_stmt :=
       'Insert into msc_atp_src_profile_temp
         (session_id,
          profile_name,
          profile_value,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login';

     l_sql_stmt := l_sql_stmt ||
         ' )select
          session_id,
          profile_name,
          profile_value,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login';

     l_sql_stmt := l_sql_stmt || '  from msc_atp_src_profile_temp' || l_dynstring ||
                                  ' where session_id = :p_session_id';

     EXECUTE IMMEDIATE l_sql_stmt USING p_session_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('After Inserting the profiles in msc_atp_src_profile_temp');
       msc_sch_wb.atp_debug('l_sql_stmt= ' || l_sql_stmt);
       msc_sch_wb.atp_debug('rows inserted = ' || SQL%ROWCOUNT);
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug(' Error in get_src_to_dstn_profiles '||substr(sqlerrm,1,100));
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
END get_src_to_dstn_profiles;
/*--------------------------------------------------------------------------
|  End Procedure get_src_to_dstn_profiles added for Multiple allocation enh -3940999
+-------------------------------------------------------------------------*/

END MSC_SATP_FUNC;

/
