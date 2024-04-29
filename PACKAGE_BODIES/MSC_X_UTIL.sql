--------------------------------------------------------
--  DDL for Package Body MSC_X_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_UTIL" AS
/* $Header: MSCXUTLB.pls 115.45 2004/07/07 22:39:55 pshah ship $  */

STATUS_ERROR CONSTANT NUMBER := 1;
STATUS_SUCCESS CONSTANT NUMBER := 0;

-- function get_party_name takes in party_id and returns the party
-- name from HZ_PARTIES
FUNCTION GET_PARTY_NAME (p_party_id IN NUMBER) RETURN VARCHAR2
IS
l_party_name  VARCHAR2(30);

BEGIN

    SELECT party_name
    INTO   l_party_name
    FROM   hz_parties
    WHERE  party_id = p_party_id;

    RETURN l_party_name;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

END GET_PARTY_NAME;

-- function get_category_code takes in inventory_item_id of an item,
-- customer and supplier info and returns the category name of the
-- item defined in the OEM's org.
FUNCTION GET_CATEGORY_CODE(p_inventory_item_id IN NUMBER,
                        p_publisher_id IN NUMBER,
                        p_publisher_site_id IN NUMBER,
                        p_customer_id IN NUMBER,
                        p_customer_site_id IN NUMBER,
                        p_supplier_id IN NUMBER,
                        p_supplier_site_id IN NUMBER)
RETURN VARCHAR2
IS
l_category_code varchar2(250);
l_org_id NUMBER;
BEGIN

   -- get the OEM's org
   if(p_publisher_id = 1) then
     l_org_id := p_publisher_site_id;
   elsif(p_customer_id = 1) then
     l_org_id := p_customer_site_id;
   elsif (p_supplier_id = 1) then
     l_org_id := p_supplier_site_id;
   else
     l_org_id := null;
   end if;

   l_category_code := null;

   SELECT category_name
   INTO l_category_code
   FROM   msc_item_categories mic,
          msc_trading_partners tp,
          msc_trading_partner_maps map
   WHERE  map.company_key = l_org_id
          and map.map_type = 2
          and map.tp_key = tp.partner_id
          and tp.sr_tp_id = mic.organization_id
          and mic.sr_instance_id = tp.sr_instance_id
          and mic.inventory_item_id = p_inventory_item_id
          and mic.category_set_id = FND_PROFILE.VALUE('MSCX_CP_HZ_CATEGORY_SET');

   return l_category_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   BEGIN
		 return NULL;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN

          RETURN NULL;
   END;
END GET_CATEGORY_CODE;

-- function get_buyer_code takes in inventory_item_id, customer and supplier information
-- from CP to return the buyer_code from msc_system_items.
FUNCTION GET_BUYER_CODE (p_inventory_item_id IN NUMBER,
			 p_publisher_id IN NUMBER,
			 p_publisher_site_id IN NUMBER,
                         p_customer_id IN NUMBER,
                         p_customer_site_id IN NUMBER,
                         p_supplier_id IN NUMBER,
                         p_supplier_site_id IN NUMBER) RETURN VARCHAR2
IS
l_buyer_code VARCHAR2(240);
l_org_id     NUMBER;
BEGIN

   -- get the OEM's org
   if(p_publisher_id = 1) then
     l_org_id := p_publisher_site_id;
   elsif(p_customer_id = 1) then
     l_org_id := p_customer_site_id;
   elsif (p_supplier_id = 1) then
     l_org_id := p_supplier_site_id;
   else
     l_org_id := null;
   end if;

   SELECT buyer_name into l_buyer_code
   FROM   msc_system_items msi,
          msc_trading_partners tp,
          msc_trading_partner_maps map
   WHERE  map.company_key = l_org_id
          and map.map_type = 2
          and map.tp_key = tp.partner_id
          and tp.sr_tp_id = msi.organization_id
          and msi.sr_instance_id = tp.sr_instance_id
          and msi.inventory_item_id = p_inventory_item_id
	  and msi.plan_id = -1;

   RETURN l_buyer_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

END GET_BUYER_CODE;

-- function get_xref_party_name takes in party_id s of a trading partner
-- and a cross referenced trading partner and returns the xref name of the
-- cross referenced trading partner
FUNCTION GET_XREF_PARTY_NAME (p_party_id IN NUMBER, p_xref_party_id IN NUMBER)
RETURN VARCHAR2 IS

l_xref_party_name  VARCHAR2(80);

BEGIN

/*   select max(tpx.xref_ext_value)
  into l_xref_party_name
  from ect_xref_dtl tpx
  where tpx.xref_int_value = p_xref_party_id
  and tpx.party_id = p_party_id
  and tpx.direction = 'IN'
  and tpx.xref_category_id = 9 ;

  RETURN l_xref_party_name;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL; */

return NULL;

END GET_XREF_PARTY_NAME;

---FUNCTION CREATE_EXCH_PARTITIONS creates partitions in MSC_ITEM_EXCEPTION
-- and MSC_EXCEPTION_DETAILS in exchange 6.2

PROCEDURE CREATE_EXCH_PARTITIONS(p_status OUT NOCOPY NUMBER) IS

share_partition VARCHAR2(10) := 'X';
partition1_exists VARCHAR2(1) := 'N';
partition2_exists VARCHAR2(1) := 'N';
errbuf VARCHAR2(1000);
retcode NUMBER;

BEGIN

   /* This function was used in Supply Chain Exchange and no
   ** longer required in Oracle Collaborative Planning
   */


   null;

END CREATE_EXCH_PARTITIONS;

/*----------------------------------------------------+
| This procedure takes into 2 uom codes in the same     |
| uom class or across classes and returns a conv     |
| rate between them.                        |
| If a conversion is not found then it sets       |
| the output variable conv found to FALSE         |
| and returns a conv factor of 1.                 |
| Do not use this procedure to validate UOM's. Use      |
| validate uom code.                        |
+-----------------------------------------------------*/

PROCEDURE GET_UOM_CONVERSION_RATES(p_uom_code IN VARCHAR2,
                                   p_dest_uom_code IN VARCHAR2,
                                   p_inventory_item_id IN NUMBER DEFAULT 0,
                           p_conv_found OUT NOCOPY BOOLEAN,
                                   p_conv_rate  OUT NOCOPY NUMBER) IS
l_uom_class VARCHAR2(10);
l_dest_uom_class VARCHAR2(10);
BEGIN


   /*-------------------------------------------------------------+
   | Rownum = 1 is used to account for the corner case APS bug    |
   | when the same uom code points to different unit of measures  |
   | in multiple instances. This can be removed when APS makes    |
   | the fix to allow only 1 uom code in addition to unit of      |
   | measure in MSC_UNITS_OF_MEASURE.                       |
   +--------------------------------------------------------------*/

   /*-----------------------------------------------------+
   | Inventory Item Id = non zero is required only if       |
   | we are doing conversions across uom classes         |
   +------------------------------------------------------*/

   BEGIN
   select uom_class
   into l_uom_class
   from msc_units_of_measure
   where uom_code = p_uom_code
   and rownum = 1;
   EXCEPTION WHEN no_data_found then
   p_conv_found := FALSE;
   p_conv_rate := 1.0;
   return;
   END;

   BEGIN
    select uom_class
    into l_dest_uom_class
    from msc_units_of_measure
    where uom_code = p_dest_uom_code
   and rownum = 1;
    EXCEPTION WHEN no_data_found then
    p_conv_found := FALSE;
    p_conv_rate := 1.0;
    return;
    END;


    if(l_uom_class = l_dest_uom_class) then
      BEGIN
      select muc1.conversion_rate/muc2.conversion_rate
      INTO
      p_conv_rate
      FROM
      msc_uom_conversions muc1,
       msc_uom_conversions muc2
      where muc1.inventory_item_id = 0
      and muc2.inventory_item_id = 0
      and muc1.uom_class = muc2.uom_class
      and muc1.uom_class = l_uom_class
      and muc1.uom_code = p_uom_code
      and muc2.uom_code = p_dest_uom_code
      and rownum = 1;
      EXCEPTION when NO_DATA_FOUND then
      p_conv_found := FALSE;
      p_conv_rate := 1.0;
      return;
      END;

   else

   BEGIN
        select  muc.conversion_rate
        INTO
        p_conv_rate
        FROM
        msc_uom_conversions_view muc
        where muc.inventory_item_id = p_inventory_item_id
        and muc.primary_uom_code = p_uom_code
        and muc.uom_code = p_dest_uom_code
      and rownum = 1;
        EXCEPTION when NO_DATA_FOUND then

         BEGIN
         select  muc.conversion_rate
         INTO
         p_conv_rate
         FROM
         msc_uom_conversions_view muc
         where muc.inventory_item_id = p_inventory_item_id
         and muc.primary_uom_code = p_dest_uom_code
         and muc.uom_code = p_uom_code
         and rownum = 1;
         EXCEPTION when NO_DATA_FOUND then
         p_conv_found := FALSE;
         p_conv_rate := 1.0;
         return;
         END;
        END;

   end if;

p_conv_found := TRUE;
return;

END;

FUNCTION GET_DEFAULT_RES_DATE(p_type IN NUMBER,
                              p_ship_date IN DATE,
                              p_rcpt_date IN DATE,
                              p_supplier_id IN NUMBER,
                              p_customer_id IN NUMBER,
                       p_order_type IN NUMBER) return DATE
IS

l_result_date DATE;
BEGIN

/*------------------------------------------------------+
| The behaviour of sales forecast is different from   |
| other order types. Hence it is handled first.       |
+-------------------------------------------------------*/

if(p_order_type = 1) then /* Sales Forecast */
   if(p_ship_date is null) then
                l_result_date := p_rcpt_date;
    elsif (p_rcpt_date is null) then
               l_result_date := p_ship_date;
    end if;

   return l_result_date;


end if;


if(p_type = 2) then

       if(p_order_type in (13, 15, 16, 17, 2, 20)) then
               /* Outbound docs to Supp's */
                l_result_date := p_rcpt_date;
         elsif (p_order_type in (14,15, 21, 3, 6)) then
       /* Inbound docs from Supp's */
            if(p_ship_date is null) then
                l_result_date := p_rcpt_date;
            elsif (p_rcpt_date is null) then
                l_result_date := p_ship_date;
            end if;

       end if;

elsif(p_type = 1) then

      if(p_order_type in (13, 15, 16, 17, 2, 20)) then
            /* Inbound docs from  customers */
            l_result_date := p_rcpt_date;
      elsif (p_order_type in (14,15, 21, 3, 6)) then
         /* Outbound docs to customers */
            if(p_ship_date is null) then
                l_result_date := p_rcpt_date;
            elsif (p_rcpt_date is null) then
                l_result_date := p_ship_date;
            end if;

      end if;

end if;

return l_result_date;

END;

FUNCTION UPDATE_SHIP_RCPT_DATES (
                                  p_customer_id IN NUMBER,
                                  p_customer_site_id IN NUMBER,
                                  p_supplier_id IN NUMBER,
                                  p_supplier_site_id IN NUMBER,
                                  p_order_type IN NUMBER,
                          p_item_id IN NUMBER,
                                  p_ship_date IN  DATE,
                                  p_rcpt_date  IN DATE) RETURN DATE IS

l_org_id NUMBER NULL;
l_supplier_id NUMBER NULL;
l_supplier_site_id NUMBER NULL;
l_customer_id NUMBER NULL;
l_customer_site_id NUMBER NULL;
l_tp_org_partner_id NUMBER NULL;
l_sr_tp_id NUMBER NULL;
l_sr_instance_id NUMBER NULL;
l_company_id NUMBER NULL;
l_tp_customer_id NUMBER NULL;
l_tp_customer_site_id NUMBER NULL;
l_tp_supplier_id NUMBER NULL;
l_tp_supplier_site_id NUMBER NULL;
l_location_id NUMBER NULL;
l_lead_time NUMBER NULL;
l_result_date DATE NULL;
l_session_id NUMBER NULL;
l_org_location_id NUMBER NULL;
l_regions_return_status VARCHAR2(1);

l_return_status         VARCHAR2(1);
l_ship_method           varchar2(30);

BEGIN


   if((p_customer_id <> 1) and (p_supplier_id <> 1)) then

      if(p_ship_date is null) then
            l_result_date := p_rcpt_date;
      elsif (p_rcpt_date is null) then
            l_result_date := p_ship_date;
       end if;

       return l_result_date;

   end if;




   /*----------------------------------------------------------+
   | Before the ATP routines are called to return intransit    |
   | times, the correct variables need to be passed            |
   +-----------------------------------------------------------*/


   if(p_customer_id = 1) then /* Buyer is the OEM */

      if (p_supplier_id is not null) then

            l_org_id := p_customer_site_id;
            l_supplier_id := p_supplier_id;
            l_supplier_site_id := p_supplier_site_id;
            l_customer_id := null;
            l_customer_site_id := null;
            l_company_id := p_customer_id; /* Just used for mapping to
                                       tp schema */

      end if;

   end if;

   if(p_supplier_id = 1) /* Seller is the OEM */ then

      if ((p_customer_id is not null) and
         (p_order_type in (14, 15, 21, 3, 6, 1))) then

         l_org_id :=  p_supplier_site_id;
         l_customer_id := p_customer_id;
         l_customer_site_id := p_customer_site_id;
         l_supplier_id := NULL;
         l_supplier_site_id := NULL;
         l_company_id := p_supplier_id; /* Just used for mapping to
                                 * TP schema */


      elsif((p_customer_id is not null) AND
         (p_order_type in (13, 15, 16, 17, 2, 20, 1))) then

          l_org_id := p_supplier_site_id;
          l_customer_id := p_customer_id;
          l_customer_site_id := p_customer_site_id;
          l_supplier_id := NULL;
          l_supplier_site_id := NULL;
          l_company_id := p_customer_id; /* Just used for mapping to
                                    TP schema */

      end if;

   end if;



   /*--------------------------------------------------------+
   | For material bound to customers, the lead time is based |
   | on the location to location lead time. For              |
    | material from suppliers, the lead time is based on      |
   | lead time on the asl for the item/supplier         |
   +---------------------------------------------------------*/

   if(l_customer_id is not null)
      then


      /*-----------------------------------------------------------+
      | Map the id's to the TP schema, these will be passed to the |
      | ATP functions                                     |
      +------------------------------------------------------------*/

      /*-----------------------------------------------------------+
      | First get the partner id corresponding to the org       |
      +------------------------------------------------------------*/

      BEGIN
      SELECT tp_key
      INTO l_tp_org_partner_id
      FROM msc_trading_partner_maps map
      WHERE map.map_type = 2
      and map.company_key = l_org_id;
      EXCEPTION WHEN OTHERS THEN
      l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
      return l_result_date;
      END;


      /*--------------------------------------------------------------+
      | Get the sr_tp_id and sr_instance_id corresponding to the orgs |
      +---------------------------------------------------------------*/

      BEGIN
      SELECT sr_tp_id,
         sr_instance_id
      INTO l_sr_tp_id,
       l_sr_instance_id
      FROM msc_trading_partners
      WHERE partner_id = l_tp_org_partner_id;
      EXCEPTION WHEN OTHERS THEN
      l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
        return l_result_date;
      END;

      /*-----------------------------------------------+
      | Get the sr_tp_id for the customer from the     |
      | corresponding instance in the lid table.       |
      +------------------------------------------------*/


      BEGIN
      SELECT tpl.sr_tp_id INTO
      l_tp_customer_id
      FROM
      msc_tp_id_lid tpl,
      msc_trading_partner_maps map,
      msc_company_relationships rels
      WHERE tpl.tp_id = map.tp_key
      and tpl.partner_type = 2
      and tpl.sr_company_id = -1
      and tpl.sr_instance_id = l_sr_instance_id
       and map.map_type = 1
        and map.company_key = rels.relationship_id
      and rels.object_id = l_customer_id
        and rels.subject_id = l_company_id
        and rels.relationship_type = 1;
      EXCEPTION WHEN OTHERS THEN
      l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
        return l_result_date;
      END;



      /*-------------------------------------------------------+
      | Map the customer site and get its source id from the    |
      | lid table for the corresponding instance.            |
      | If multiple sites are found use the SHIP_TO site.    |
      +--------------------------------------------------------*/

       BEGIN
      SELECT tps.sr_tp_site_id into
      l_tp_customer_site_id
      FROM
      msc_tp_site_id_lid tps,
      msc_trading_partner_maps map
      WHERE tps.sr_company_id = -1
      and tps.tp_site_id = map.tp_key
      and tps.sr_instance_id = l_sr_instance_id
      and tps.partner_type = 2
      and map.map_type = 3
        and map.company_key = l_customer_site_id;
      EXCEPTION WHEN TOO_MANY_ROWS THEN
         BEGIN
         SELECT tps.sr_tp_site_id into
         l_tp_customer_site_id
         FROM
         msc_tp_site_id_lid tps,
         msc_trading_partner_sites tp_sites,
         msc_trading_partner_maps map
         WHERE tps.sr_company_id = -1
         and tps.tp_site_id = tp_sites.partner_site_id
         and tps.sr_instance_id = l_sr_instance_id
         and tps.partner_type = 2
         and tp_sites.partner_site_id = map.tp_key
         and tp_sites.tp_site_code = 'SHIP_TO'
         and map.map_type = 3
         and map.company_key = l_customer_site_id;
            EXCEPTION WHEN OTHERS THEN
            l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
            return l_result_date;
         END;
      WHEN OTHERS THEN
         l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
         return l_result_date;
      END;


      /*-----------------------------------------------------+
      | The ATP API's to get lead time will use region level |
      | leadtime if location level lead time is not found      |
      +------------------------------------------------------*/


      --===============
        -- Get session id
        --===============
       select mrp_atp_schedule_temp_s.nextval
       into   l_session_id
       from dual;

       BEGIN

             MSC_SATP_FUNC.GET_REGIONS(l_tp_customer_site_id,
                                  724, -- Calling Module is 'MSC'
                                  l_sr_instance_id,
                                  l_session_id,
                                  null,
                                  l_regions_return_status);
              EXCEPTION WHEN OTHERS THEN
                  l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
            return l_result_date;

       END;


      /*-----------------------------------------------+
      | Get the default ship to/deliver from location  |
      | for the org.                          |
      +------------------------------------------------*/

      BEGIN
      l_org_location_id :=

            msc_atp_func.get_location_id(
                         l_sr_instance_id,
                         l_sr_tp_id,
                         null,
                         null,
                         null,
                         null);
      EXCEPTION  WHEN OTHERS  then
        l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
        return l_result_date;
        END;


      /*-----------------------------------------------+
      | Get the default ship to/deliver from location  |
      | for the customer/supplier                |
      +------------------------------------------------*/

      BEGIN
      l_location_id := msc_atp_func.get_location_id(
                   l_sr_instance_id,
                         null,
                         l_tp_customer_id,
                         l_tp_customer_site_id,
                         l_tp_supplier_id,
                         l_tp_supplier_site_id);

      EXCEPTION  WHEN OTHERS  then
        l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
        return l_result_date;
      END;


      BEGIN
         l_lead_time := MSC_SCATP_PUB.get_default_intransit_time (
                    l_org_location_id,
                    l_sr_instance_id,
                    l_location_id,
                    l_sr_instance_id,
               l_session_id,
               l_tp_customer_site_id);
      EXCEPTION WHEN OTHERS then
        l_result_date := get_default_res_date(1,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
        return l_result_date;
      END;


      if(p_ship_date is null) then
         l_result_date := p_rcpt_date - nvl(l_lead_time, 0);
      elsif (p_rcpt_date is null) then
         l_result_date := p_ship_date + nvl(l_lead_time, 0);
      end if;

      return l_result_date;

   elsif (l_supplier_id is not null) then
		/*-----------------------------------------------------------+
		| Map the id's to the TP schema, these will be passed to the |
		| ATP functions                                     |
		+------------------------------------------------------------*/

		/*-----------------------------------------------------------+
		| First get the partner id corresponding to the org       |
		+------------------------------------------------------------*/

		BEGIN
		SELECT tp_key
		INTO l_tp_org_partner_id
		FROM msc_trading_partner_maps map
		WHERE map.map_type = 2
		and map.company_key = l_org_id;
		EXCEPTION WHEN OTHERS THEN
		l_result_date := get_default_res_date(1,
					   p_ship_date,
					   p_rcpt_date,
					   p_supplier_id,
					   p_customer_id,
				           p_order_type);
		return l_result_date;
		END;


		/*--------------------------------------------------------------+
		| Get the sr_tp_id and sr_instance_id corresponding to the orgs |
		+---------------------------------------------------------------*/

		BEGIN
		SELECT sr_tp_id,
		   sr_instance_id
		INTO l_sr_tp_id,
		 l_sr_instance_id
		FROM msc_trading_partners
		WHERE partner_id = l_tp_org_partner_id;
		EXCEPTION WHEN OTHERS THEN
		l_result_date := get_default_res_date(1,
					   p_ship_date,
					   p_rcpt_date,
					   p_supplier_id,
					   p_customer_id,
				           p_order_type);
		  return l_result_date;
		END;

      /*------------------------------------------------+
      | Get the id of the supplier and supplier site in |
      | the TP schema.                         |
      +-------------------------------------------------*/

         BEGIN
        SELECT map.tp_key INTO
        l_tp_supplier_id
        FROM
        msc_trading_partner_maps map,
        msc_company_relationships rels
        WHERE map.map_type = 1
        and map.company_key = rels.relationship_id
        and rels.object_id = l_supplier_id
        and rels.subject_id = l_company_id
        and rels.relationship_type = 2;
        EXCEPTION WHEN OTHERS THEN
       l_result_date := get_default_res_date(2,
                         p_ship_date,
                         p_rcpt_date,
                         p_supplier_id,
                         p_customer_id,
                         p_order_type);
        return l_result_date;
        END;


      BEGIN
        SELECT map.tp_key INTO
        l_tp_supplier_site_id
        FROM
        msc_trading_partner_maps map
        WHERE map.map_type = 3
        and map.company_key = l_supplier_site_id;
        EXCEPTION WHEN OTHERS THEN
          l_result_date := get_default_res_date(2,
                                 p_ship_date,
                                 p_rcpt_date,
                                 p_supplier_id,
                                 p_customer_id,
                         p_order_type);
           return l_result_date;
        END;

      /*-----------------------------------------------------+
      | The ATP API's to get lead time will use region level |
      | leadtime if location level lead time is not found      |
      +------------------------------------------------------*/

      --===============
        -- Get session id
        --===============
     BEGIN
       select mrp_atp_schedule_temp_s.nextval
       into   l_session_id
       from dual;

       MSC_ATP_PROC.ATP_Intransit_LT(
                 2  ,                     --- Destination
                 l_session_id,            -- session_id
                 null,                    -- from_org_id
                 null,                    -- from_loc_id
                 l_tp_supplier_site_id,   -- from_vendor_site_id
                 l_sr_instance_id,        -- p_to_instance_id
                 --null,                    -- p_from_instance_id
                 l_sr_tp_id,              -- p_to_org_id
                 null,                    -- p_to_loc_id
                 null,                    -- p_to_customer_site_id
                 l_sr_instance_id,        -- p_to_instance_id
                 l_ship_method,           -- p_ship_method
                 l_lead_time,             -- x_intransit_lead_time
                 l_return_status          -- x_return_status
		 );


       IF (l_return_status = FND_API.G_RET_STS_ERROR) then
	       l_result_date := get_default_res_date(2,
				 p_ship_date,
				 p_rcpt_date,
				 p_supplier_id,
				 p_customer_id,
				 p_order_type);
	      return l_result_date;
       END IF;

     EXCEPTION
         WHEN OTHERS THEN
	       l_result_date := get_default_res_date(2,
				 p_ship_date,
				 p_rcpt_date,
				 p_supplier_id,
				 p_customer_id,
				 p_order_type);
	      return l_result_date;
     END;

      if(p_order_type in (1, 3, 6, 21, 14, 15))
      then
         if(p_ship_date is null) then
               l_result_date := p_rcpt_date - nvl(l_lead_time, 0);
         elsif (p_rcpt_date is null) then
               l_result_date := p_ship_date + nvl(l_lead_time, 0);
         end if;
      else
         l_result_date := p_rcpt_date -  nvl(l_lead_time,0);
      end if;
      return l_result_date;

   end if;


END UPDATE_SHIP_RCPT_DATES;

FUNCTION GET_CUSTOMER_TRANSIT_TIME(p_publisher_id IN NUMBER,
                                   p_publisher_site_id IN NUMBER,
                                   p_customer_id IN NUMBER,
                                p_customer_site_id IN NUMBER) RETURN NUMBER IS
rcpt_date DATE;
ship_date DATE := sysdate;
jul_rcpt_date NUMBER;
jul_ship_date NUMBER;
lead_time NUMBER := 0;

BEGIN


   select to_number(to_char(sysdate,  'j'))
   INTO jul_ship_date
   FROM dual;


   /* This function returns the lead time between an OEM org and a
   ** customer/customer site.
   ** It is built on top of update_ship_rcpt_dates fn. It passes
   ** in a ship date and gets back a recipt date. The difference
   ** between the 2 is returned as lead time.
   */


   BEGIN
    rcpt_date := UPDATE_SHIP_RCPT_DATES (
                                  p_customer_id,
                                  p_customer_site_id,
                          p_publisher_id,
                          p_publisher_site_id,
                                  14, /* Hard Coded to Sales Order */
                                  NULL,
                                  ship_date,
                                  NULL);
   EXCEPTION WHEN OTHERS THEN
   return lead_time;
   END;


   select to_number(to_char(rcpt_date, 'j'))
   INTO jul_rcpt_date FROM dual;

   lead_time := GREATEST(jul_rcpt_date - jul_ship_date, 0);

   return lead_time;

END;

--------------------------------------------------------------------------
-- Function GET_LOOKUP_MEANING
----------------------------------------------------------------------
FUNCTION GET_LOOKUP_MEANING(p_lookup_type in varchar2,
			    p_order_type_code in Number) RETURN Varchar2 IS
    l_order_type_desc   varchar2(240);
BEGIN
  --Get the order type desc. Takes care of order type renaming.
  BEGIN
    select meaning
    into   l_order_type_desc
    from   mfg_lookups
    where  lookup_type = p_lookup_type
    and    lookup_code = p_order_type_code;

    return l_order_type_desc;
  EXCEPTION
    WHEN OTHERS THEN
      l_order_type_desc := null;
      return l_order_type_desc;
  END;

END GET_LOOKUP_MEANING;

PROCEDURE SCE_TO_APS(
                        p_map_type            IN  NUMBER,
                        p_sce_company_id      IN  NUMBER,
                        p_sce_company_site_id IN  NUMBER,
                        p_relationship_type   IN  NUMBER,
			aps_partner_id        OUT NOCOPY NUMBER,
			aps_partner_site_id   OUT NOCOPY NUMBER,
			aps_sr_instance_id    OUT NOCOPY NUMBER
			)
IS

BEGIN

	--dbms_output.put_line(' p_map_type '|| p_map_type );
	--dbms_output.put_line(' p_sce_company_id '|| p_sce_company_id );
	--dbms_output.put_line(' p_sce_company_site_id '|| p_sce_company_site_id );
  if (p_map_type = G_ORGANIZATION_MAPPING) then

	  SELECT tp.sr_tp_id,tp.sr_instance_id
	    INTO aps_partner_id, aps_sr_instance_id
	    FROM msc_trading_partner_maps map,
		 msc_trading_partners tp
	   WHERE map.map_type = G_ORGANIZATION_MAPPING
	     AND map.company_key = p_sce_company_site_id
	     AND map.tp_key = tp.partner_id;

  elsif (p_map_type = G_COMPANY_MAPPING) then

	--dbms_output.put_line(' Inside SCE TO APS ' );
	      SELECT map.tp_key
		INTO aps_partner_id
	        FROM msc_trading_partner_maps map,
		     msc_company_relationships cr
	       WHERE map.map_type = G_COMPANY_MAPPING
	         AND cr.object_id = p_sce_company_id
	         AND map.company_key = cr.relationship_id
	         AND cr.relationship_type = p_relationship_type
	         AND cr.subject_id = OEM_COMPANY_ID;

	--dbms_output.put_line(' aps_partner_id : ' || aps_partner_id);
         if (p_sce_company_site_id is not null) then

            begin
              SELECT map.tp_key
		INTO aps_partner_site_id
	        FROM msc_trading_partner_maps map
	       WHERE map.map_type = G_COMPANY_SITE_MAPPING
	         AND map.company_key = p_sce_company_site_id;
	    exception
	       when too_many_rows then
		   BEGIN
		     SELECT tp_sites.partner_site_id
		       INTO aps_partner_site_id
		       FROM msc_trading_partner_sites tp_sites,
			    msc_trading_partner_maps map
		      WHERE tp_sites.partner_site_id = map.tp_key
		        and tp_sites.tp_site_code = 'SHIP_TO'
		        and tp_sites.partner_type = 2
		        and map.map_type = G_COMPANY_SITE_MAPPING
		        and map.company_key = p_sce_company_site_id;

	           EXCEPTION
		       WHEN OTHERS THEN
			    RAISE;
		   END;

		when others then
		      raise;
	    end;
	 end if;

  end if;

    --dbms_output.put_line(' aps_partner_id = ' || aps_partner_id);
	--dbms_output.put_line(' aps_partner_site_id : ' || aps_partner_site_id);
    --dbms_output.put_line('  aps_sr_instance_id = '||aps_sr_instance_id);
EXCEPTION

     WHEN OTHERS THEN
	RAISE;


END SCE_TO_APS;

PROCEDURE GET_CALENDAR_CODE(
			    p_supplier_id      in number,
			    p_supplier_site_id in number,
			    p_customer_id      in number,
			    p_customer_site_id in number,
			    p_calendar_code    out nocopy varchar2,
		            p_sr_instance_id   out nocopy number,
			    p_tp_ids           in number default 1, --1 means CP,2 means APS
			    p_tp_instance_id   in  number default 99999,
			    p_oem_ident        in  number default 3)
IS

lv_calendar_code   varchar2(30);

aps_org_partner_id        number;
aps_org_site_partner_id   number;
aps_sr_instance_id        number;

aps_cust_partner_id       number;
aps_cust_partner_site_id  number;

aps_supp_partner_id       number;
aps_supp_partner_site_id  number;

BEGIN

if (p_tp_ids = 1) then  /* TP ids are in CP schema */
	  if (p_supplier_id <> 1) then
		     /* Get the APS Ids for the Supplier company id */
		 SCE_TO_APS(G_COMPANY_MAPPING ,
				p_supplier_id,
				p_supplier_site_id,
				2,       --- supplier relationship
				aps_supp_partner_id,
				aps_supp_partner_site_id,
				aps_sr_instance_id
				);
	  end if;

	  if (p_customer_id <> 1) then
		     /* Get the APS Ids for the Customer company id */
		 SCE_TO_APS(G_COMPANY_MAPPING,
				p_customer_id,
				p_customer_site_id,
				1,       --- customer relationship
				aps_cust_partner_id,
				aps_cust_partner_site_id,
				aps_sr_instance_id
				);
	  end if;
else
	    /* This code added for VMI to use the Calendar hierarchy */
	    /* TP ids are in APS schema */
		aps_supp_partner_id := p_supplier_id;
		aps_supp_partner_site_id := p_supplier_site_id;
		aps_cust_partner_id := p_customer_id;
		aps_cust_partner_site_id := p_customer_site_id;
		aps_sr_instance_id := p_tp_instance_id;

    ---1-Supplier is OEM , 2 means Customer is OEM,3 means IDs are in terms of CP
	if (p_oem_ident = 1) then
		aps_org_partner_id := p_supplier_site_id;
	elsif (p_oem_ident = 2) then
		aps_org_partner_id := p_customer_site_id;
	end if;

end if;

  if (p_supplier_id = 1 and p_tp_ids=1) OR
     (p_oem_ident=1 and p_tp_ids = 2) then     --- OEM is the supplier
      if (p_tp_ids = 1) then  /* TP ids are in CP schema */
		     /* Get the APS sr_instance_id and partner_id for the OEM */
		 SCE_TO_APS(G_ORGANIZATION_MAPPING ,
				p_supplier_id,
				p_supplier_site_id,
				null,       --- relationship
				aps_org_partner_id,
				aps_org_site_partner_id,
				aps_sr_instance_id
				);
      end if;

        begin
		   /* Get the Customer Receiving calendar  */
	     select nvl(ca1.CALENDAR_CODE, ca.CALENDAR_CODE)
	       into lv_calendar_code
	       from msc_calendar_assignments  ca,
		    msc_calendar_assignments  ca1
	      where ca.sr_instance_id = aps_sr_instance_id
		and ca.CALENDAR_TYPE = 'RECEIVING'
		and ca.partner_type = 2
		and ca.partner_id = aps_cust_partner_id
		and ca.ORGANIZATION_ID is null
		and ca.ASSOCIATION_TYPE = G_CUSTOMER
		and ca1.sr_instance_id(+) = ca.sr_instance_id
		and ca1.CALENDAR_TYPE(+) = ca.CALENDAR_TYPE
		and ca1.partner_type(+) = ca.partner_type
		and ca1.ORGANIZATION_ID is null
		and ca1.ASSOCIATION_TYPE(+) = G_CUSTOMER_SITE
		and ca1.partner_id(+) = ca.partner_id
		and ca1.partner_site_id(+) = aps_cust_partner_site_id;

	exception
		when no_data_found then

                   begin
                        /* If there is no customer calendar, get the OEM Org Shipping or Mfg calendar   */
			select nvl(ca.CALENDAR_CODE, tp.calendar_code)
	                  into lv_calendar_code
			  from msc_trading_partners tp,
			       msc_calendar_assignments    ca
			 where tp.sr_instance_id = aps_sr_instance_id
			   and tp.sr_tp_id = aps_org_partner_id
			   and tp.partner_type = 3
			   and ca.sr_instance_id(+) = tp.sr_instance_id
			   and ca.ORGANIZATION_ID(+) = tp.sr_tp_id
			   and ca.partner_type(+) = tp.partner_type
			   and ca.CALENDAR_TYPE(+) = 'SHIPPING'
			   and ca.ASSOCIATION_TYPE(+) = G_ORGANIZATION;

		   exception
			   when others then
                           raise;
		   end;

		when others then
			   raise;
	end;

  elsif (p_customer_id = 1 and p_tp_ids=1) OR
        (p_oem_ident=2 and p_tp_ids = 2) then     --- OEM is the customer

      if (p_tp_ids = 1) then  /* TP ids are in CP schema */
		     /* Get the APS sr_instance_id and partner_id for the OEM */
		 SCE_TO_APS(G_ORGANIZATION_MAPPING ,
				p_customer_id,
				p_customer_site_id,
				null,    --- relationship type
				aps_org_partner_id,
				aps_org_site_partner_id,
				aps_sr_instance_id
				);
			--dbms_output.put_line(' sr_tp _id = ' || aps_org_partner_id);
			--dbms_output.put_line(' Org sr_instance_id = ' || aps_sr_instance_id);
      end if;


           /* Get the Org Receiving Calendar, if not available then get the OEM Orgs' Mfg calendar */
        select nvl(ca.CALENDAR_CODE, tp.calendar_code)
	  into lv_calendar_code
	  from msc_calendar_assignments  ca,
	       msc_trading_partners tp
         where tp.sr_instance_id = aps_sr_instance_id
	   and tp.sr_tp_id = aps_org_partner_id
	   and tp.partner_type = 3
	   and ca.sr_instance_id(+) = tp.sr_instance_id
	   and ca.ORGANIZATION_ID(+) = tp.sr_tp_id
	   and ca.partner_type(+) = tp.partner_type
	   and ca.CALENDAR_TYPE(+) = 'RECEIVING'
	   and ca.ASSOCIATION_TYPE(+) = G_ORGANIZATION;

  elsif (p_supplier_id is null and nvl(p_customer_id,-1) <> 1) then
	 /* This is added as per UI reqmnt in the case where
	    they dont call with supplier(OEM) info
	    This will be called by UI for OEM to Customer */

        begin
		   /* Get the Customer Receiving calendar  */
	     select nvl(ca1.CALENDAR_CODE, ca.CALENDAR_CODE),
		    nvl(ca1.sr_instance_id,ca.sr_instance_id)
	       into lv_calendar_code,
		    aps_sr_instance_id
	       from msc_calendar_assignments  ca,
		    msc_calendar_assignments  ca1
	      where ca.CALENDAR_TYPE = 'RECEIVING'
		and ca.partner_type = 2
		and ca.partner_id = aps_cust_partner_id
		and ca.ORGANIZATION_ID is null
		and ca.ASSOCIATION_TYPE = G_CUSTOMER
		and ca1.sr_instance_id(+) = ca.sr_instance_id
		and ca1.CALENDAR_TYPE(+) = ca.CALENDAR_TYPE
		and ca1.partner_type(+) = ca.partner_type
		and ca1.ORGANIZATION_ID is null
		and ca1.ASSOCIATION_TYPE(+) = G_CUSTOMER_SITE
		and ca1.partner_id(+) = ca.partner_id
		and ca1.partner_site_id(+) = aps_cust_partner_site_id;

	exception
	   when others then
	        raise;
	end;

  else                           -- OEM is neither supplier/customer

        begin
		   /* Get the Customer or Customer Site Receiving calendar  */
	     select nvl(ca1.CALENDAR_CODE, ca.CALENDAR_CODE)
	       into lv_calendar_code
	       from msc_calendar_assignments  ca,
		    msc_calendar_assignments  ca1
	      where ca.sr_instance_id = aps_sr_instance_id
		and ca.CALENDAR_TYPE = 'RECEIVING'
		and ca.partner_type = 2
		and ca.partner_id = aps_cust_partner_id
		and ca.ORGANIZATION_ID is null
		and ca.ASSOCIATION_TYPE = G_CUSTOMER
		and ca1.sr_instance_id(+) = ca.sr_instance_id
		and ca1.CALENDAR_TYPE(+) = ca.CALENDAR_TYPE
		and ca1.partner_type(+) = ca.partner_type
		and ca1.ORGANIZATION_ID is null
		and ca1.ASSOCIATION_TYPE(+) = G_CUSTOMER_SITE
		and ca1.partner_id(+) = ca.partner_id
		and ca1.partner_site_id(+) = aps_cust_partner_site_id;

	exception
		when no_data_found then

                        /* If there is no customer calendar, get the OEM Org Shipping or Mfg calendar   */
			select nvl(ca.CALENDAR_CODE, tp.calendar_code)
	                  into lv_calendar_code
			  from msc_trading_partners tp,
			       msc_calendar_assignments    ca
			 where tp.sr_instance_id = aps_sr_instance_id
			   and tp.sr_tp_id = aps_org_partner_id
			   and tp.partner_type = 3
			   and ca.sr_instance_id(+) = tp.sr_instance_id
			   and ca.ORGANIZATION_ID(+) = tp.sr_tp_id
			   and ca.partner_type(+) = tp.partner_type
			   and ca.CALENDAR_TYPE(+) = 'SHIPPING'
			   and ca.ASSOCIATION_TYPE(+) = G_ORGANIZATION;

		when others then
			   raise;

	end;

  end if;

  p_calendar_code := lv_calendar_code;
  p_sr_instance_id :=  aps_sr_instance_id;

EXCEPTION
   WHEN OTHERS THEN
     p_calendar_code :=  nvl(fnd_profile.value('MSC_X_DEFAULT_CALENDAR'),'-1');
     begin
	     select sr_instance_id
	       into p_sr_instance_id
	       from msc_calendar_dates
	      where calendar_code  = p_calendar_code
	        and rownum = 1;
     exception
         when others then
	   p_sr_instance_id := -1;
     end;
END GET_CALENDAR_CODE;

FUNCTION GET_SHIPPING_CONTROL_ID(l_customer_id      IN NUMBER,
                                 l_customer_site_id IN NUMBER,
                                 l_supplier_id      IN NUMBER,
                                 l_supplier_site_id IN NUMBER)
RETURN NUMBER IS

CURSOR C_SHIPPING_CONTROL(a_site_id NUMBER,
                          a_partner_type NUMBER) IS
SELECT decode(upper(mtps.shipping_control), 'BUYER', 2,1)
from msc_trading_partner_maps mtpm,
     msc_trading_partner_sites mtps
where mtpm.company_key = a_site_id
and  mtpm.map_type = G_COMPANY_SITE
and  mtpm.tp_key = mtps.partner_site_id
and  mtps.partner_type = a_partner_type;

CURSOR C_SHIPPING_CONTROL_SHIP_TO(a_site_id NUMBER,
                          a_partner_type NUMBER) IS
SELECT decode(upper(mtps.shipping_control), 'BUYER', 2,1)
from msc_trading_partner_maps mtpm,
     msc_trading_partner_sites mtps
where mtpm.company_key = a_site_id
and  mtpm.map_type = G_COMPANY_SITE
and  mtpm.tp_key = mtps.partner_site_id
and  mtps.partner_type = a_partner_type
AND mtps.tp_site_code = 'SHIP_TO'
;

l_oem_type NUMBER;
a_site_id NUMBER;
a_partner_type NUMBER;
l_shipping_control NUMBER;

BEGIN

/* -------------------------------------------------------+
 | Check if OEM is involved in transaction. If OEM is     |
 | involved then determine if OEM is Customer or Supplier |
 +--------------------------------------------------------*/

    IF (l_customer_id = OEM_COMPANY_ID) THEN
       l_oem_type := G_CUSTOMER;
       RETURN 1;
    ELSIF (l_supplier_id = OEM_COMPANY_ID) THEN
       l_oem_type := G_SUPPLIER;
    ELSE
        RETURN 1;
    END IF;

        /*----------------------------------------------------------------+
         | If OEM is Customer the get shipping control from Supplier Sites|
         | or get shipping control from Customer sites.                   |
         +----------------------------------------------------------------*/

        IF (l_oem_type = G_CUSTOMER) THEN
            a_site_id := l_supplier_site_id;
            a_partner_type := G_SUPPLIER;
        ELSE
            a_site_id := l_customer_site_id;
            a_partner_type := G_CUSTOMER;
        END IF;

        BEGIN
            OPEN C_SHIPPING_CONTROL(a_site_id, a_partner_type);

            IF (C_SHIPPING_CONTROL%ROWCOUNT = 1) THEN
              FETCH C_SHIPPING_CONTROL INTO l_shipping_control;
            ELSE
              OPEN C_SHIPPING_CONTROL_SHIP_TO(a_site_id, a_partner_type);
              FETCH C_SHIPPING_CONTROL_SHIP_TO INTO l_shipping_control;
              CLOSE C_SHIPPING_CONTROL_SHIP_TO;
            END IF;
            CLOSE C_SHIPPING_CONTROL;

            RETURN l_shipping_control;

        EXCEPTION WHEN OTHERS THEN

            RETURN 1;

        END;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 1;
END GET_SHIPPING_CONTROL_ID;

FUNCTION GET_SHIPPING_CONTROL(p_customer_name      IN VARCHAR2,
                              p_customer_site_name IN VARCHAR2,
                              p_supplier_name      IN VARCHAR2,
                              p_supplier_site_name IN VARCHAR2)
RETURN NUMBER IS

l_shipping_control NUMBER;
l_customer_id      NUMBER;
l_customer_site_id NUMBER;
l_supplier_id      NUMBER;
l_supplier_site_id NUMBER;

BEGIN

/*--------------------------------------------------------+
 | Get the Ids for Customer and Supplier and their sites  |
 +--------------------------------------------------------*/

     select mcs.company_id, mcs.company_site_id
      INTO l_customer_id, l_customer_site_id
      from msc_companies mc,
           msc_company_sites mcs
     where mc.company_id = mcs.company_id
     and   upper(mc.company_name) = upper(p_customer_name)
     and   upper(mcs.company_site_name) = upper(p_customer_site_name);

     select mcs.company_id, mcs.company_site_id
      INTO l_supplier_id, l_supplier_site_id
      from msc_companies mc,
           msc_company_sites mcs
     where mc.company_id = mcs.company_id
     and   upper(mc.company_name) = upper(p_supplier_name)
     and   upper(mcs.company_site_name) = upper(p_supplier_site_name);

     l_shipping_control := GET_SHIPPING_CONTROL_ID(
                             l_customer_id,
			     l_customer_site_id,
			     l_supplier_id,
			     l_supplier_site_id);

     return l_shipping_control;

EXCEPTION
  WHEN OTHERS THEN
     RETURN 1;
END GET_SHIPPING_CONTROL;


-- function to return the buyer code for VMI

FUNCTION GET_BUYER_CODE (p_inventory_item_id IN NUMBER,
            p_organization_id IN NUMBER,
            p_sr_instance_id IN NUMBER
            ) RETURN VARCHAR2
IS
l_buyer_code VARCHAR2(240);
BEGIN

     SELECT distinct buyer_name into l_buyer_code
   FROM   msc_system_items msi
   WHERE
	  msi.organization_id=p_organization_id
          and msi.sr_instance_id = p_sr_instance_id
          and msi.inventory_item_id = p_inventory_item_id
	  and   msi.plan_id = -1;

   RETURN l_buyer_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

END GET_BUYER_CODE;


END MSC_X_UTIL;

/
