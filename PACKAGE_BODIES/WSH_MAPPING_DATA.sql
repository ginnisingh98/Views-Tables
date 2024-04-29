--------------------------------------------------------
--  DDL for Package Body WSH_MAPPING_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_MAPPING_DATA" AS
/* $Header: WSHMAPDB.pls 120.1.12010000.4 2010/02/25 16:19:16 sankarun ship $ */

   /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Get_Delivery_Info                                        |
   |                                                                           |
   | DESCRIPTION	    This procedure gets the Delivery Information at the time |
   |                  populating the data into the interface tables, when      |
   |                  processing an inbound XML transaction.                   |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/02      Vijay Nandula   Created                                    |
   |                                                                           |
   ============================================================================*/

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_MAPPING_DATA';
--

PROCEDURE get_name_number(
                     p_ship_to_site_contact_id IN NUMBER,
                     x_per_ph_number        OUT NOCOPY VARCHAR2,
                     x_contact_person_name  OUT NOCOPY VARCHAR2,
                     x_return_status        OUT NOCOPY VARCHAR2
                     );
PROCEDURE Get_Phone_Fax(
		p_loc_id IN NUMBER,
		x_phone	OUT NOCOPY  VARCHAR2,
		x_fax	OUT NOCOPY  VARCHAR2,
		x_url	OUT NOCOPY  VARCHAR2,
		x_return_status OUT NOCOPY  VARCHAR2);

   PROCEDURE Get_Delivery_Info ( p_delivery_id          IN   NUMBER,
                                 p_document_type        IN   VARCHAR2,
                                 x_name                 OUT NOCOPY   VARCHAR2,
                                 x_arrival_date         OUT NOCOPY   DATE,
                                 x_departure_date       OUT NOCOPY   DATE,
                                 x_vehicle_num_prefix   OUT NOCOPY   VARCHAR2,
                                 x_vehicle_number       OUT NOCOPY   VARCHAR2,
                                 x_route_id             OUT NOCOPY   VARCHAR2,
                                 x_routing_instructions OUT NOCOPY   VARCHAR2,
                                 x_departure_seal_code  OUT NOCOPY   VARCHAR2,
                                 x_customer_name	OUT NOCOPY   VARCHAR2,
                                 x_customer_number	OUT NOCOPY   VARCHAR2,
                                 x_warehouse_type	OUT NOCOPY   VARCHAR2,
--Bug 3458160
                                 x_operator             OUT NOCOPY   VARCHAR2,
                                 x_ship_to_loc_code     OUT NOCOPY   VARCHAR2,
                                 x_cnsgn_cont_per_name  OUT  NOCOPY VARCHAR2, --4227777
                                 x_cnsgn_cont_per_ph    OUT  NOCOPY VARCHAR2, --4227777
                                 x_return_status        OUT NOCOPY  VARCHAR2
)
   IS

      CURSOR l_src_hdr_no_cur
      IS
      SELECT wdd.source_header_number
      FROM   wsh_delivery_details      wdd,
             wsh_delivery_assignments_v  wda
      WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
      AND    wda.delivery_id = p_delivery_id
      AND    wdd.container_flag= 'N'
      AND    rownum = 1;

      CURSOR l_del_info_cur
      IS
      SELECT name,
	     customer_id,
	     organization_id,
             ultimate_dropoff_location_id --bug 3920178
      FROM   wsh_new_deliveries
      WHERE  delivery_id = p_delivery_id;

      CURSOR l_get_dates_cur
      IS
      SELECT wts1.Actual_Departure_Date,
             wts2.Actual_Arrival_Date,
             wt.Vehicle_Num_Prefix,
             wt.Vehicle_Number,
             wt.Route_ID,
             wt.Routing_Instructions,
             wts1.Departure_Seal_Code,
--Bug 3458160
             wt.operator
      FROM   wsh_delivery_legs  wdl,
             wsh_trip_stops     wts1,
             wsh_trip_stops     wts2,
             wsh_trips          wt
      WHERE  wts1.trip_id		= wt.trip_id
      AND    wts2.trip_id		= wt.trip_id
      AND    wts1.stop_id		= wdl.pick_up_stop_id
      AND    wts2.stop_id		= wdl.drop_off_stop_id
      AND    wdl.delivery_id		= p_delivery_id;

      CURSOR l_cust_cur( p_customer_id IN NUMBER )
      IS
      SELECT hp.party_name,
	     hca.account_number
      FROM   hz_parties hp,
	     hz_cust_accounts hca
      WHERE  hca.party_id		= hp.party_id
      AND    hca.cust_account_id	= p_customer_id;

      l_org_id NUMBER;
      l_customer_id NUMBER;

      wsh_invalid_delivery_id EXCEPTION;

      --bug 3920178 {
     cursor l_ship_to_site_use_id_csr( p_delivery_id IN NUMBER) is
      SELECT wdd.ship_to_site_use_id ship_to_site_use_id , count(*) cnt
      FROM   wsh_delivery_assignments_v wda,
             wsh_delivery_details wdd
      WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
      AND    wda.delivery_id        =  p_delivery_id
      AND    wdd.container_flag     = 'N'
      GROUP BY ship_to_site_use_id
      ORDER BY cnt DESC;

      cursor l_site_use_loc_csr(p_site_use_id IN NUMBER) is
      SELECT LOCATION, contact_id
      FROM   HZ_CUST_SITE_USES_ALL
      WHERE  site_use_id = p_site_use_id;

      cursor l_cust_ship_to_loc_csr
                (p_customer_id         IN NUMBER,
                 p_ship_to_location_id IN NUMBER,
                 p_org_id              IN NUMBER) is
      SELECT HCSU.LOCATION, HCSU.CONTACT_ID
      FROM   HZ_CUST_SITE_USES_ALL HCSU,
             HZ_CUST_ACCT_SITES_ALL HCAS,
             HZ_CUST_ACCOUNTS HCA,
             HZ_PARTY_SITES HPS
      WHERE  HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
      AND    HCAS.PARTY_SITE_ID     = HPS.PARTY_SITE_ID
      AND    HCAS.CUST_ACCOUNT_ID   = HCA.CUST_ACCOUNT_ID
      AND    HCSU.SITE_USE_CODE     = 'SHIP_TO'
      AND    HCSU.STATUS            = 'A'
      AND    HCAS.STATUS            = 'A'
      AND    HCA.STATUS             = 'A'
      AND    HPS.LOCATION_ID        = p_ship_to_location_id
      AND    HCAS.CUST_ACCOUNT_ID   = p_customer_id
      AND    (HCAS.ORG_ID IS NULL   OR HCAS.ORG_ID = p_org_id)
      AND    HCAS.ORG_ID = HCSU.ORG_ID ;
      -- removed the nvl from org_id k proj

      cursor l_rel_cust_ship_to_loc_csr
                (p_customer_id         IN NUMBER,
                 p_ship_to_location_id IN NUMBER,
                 p_org_id              IN NUMBER) is
      SELECT HCSU.LOCATION, HCSU.CONTACT_ID
      FROM   HZ_CUST_SITE_USES_ALL HCSU,
             HZ_CUST_ACCT_SITES_ALL HCAS,
             HZ_PARTY_SITES HPS,
             HZ_CUST_ACCOUNTS HCA,
             HZ_CUST_ACCT_RELATE_ALL HCAR
      WHERE  HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
      AND    HCAS.PARTY_SITE_ID     = HPS.PARTY_SITE_ID
      AND    HCAS.CUST_ACCOUNT_ID   = HCA.CUST_ACCOUNT_ID
      AND    HCSU.SITE_USE_CODE     = 'SHIP_TO'
      AND    HCSU.STATUS            = 'A'
      AND    HCAS.STATUS            = 'A'
      AND    HCA.STATUS             = 'A'
      AND    HPS.LOCATION_ID        = p_ship_to_location_id
      AND    HCA.CUST_ACCOUNT_ID    = HCAR.CUST_ACCOUNT_ID
      AND    HCAR.RELATED_CUST_ACCOUNT_ID    = p_customer_id
      AND    HCAR.SHIP_TO_FLAG      = 'Y'
      AND    (HCAS.ORG_ID IS NULL   OR HCAS.ORG_ID = p_org_id)
      AND    HCAS.ORG_ID = HCSU.ORG_ID ;
      -- removed the nvl from org_id k proj



      l_operating_unit NUMBER;
      l_ship_to_site_use_id NUMBER;
      l_ship_to_location_id NUMBER;
      l_cnt NUMBER;
      l_ship_to_loc_code VARCHAR2(32767);
      l_ship_to_site_contact_id NUMBER;
      -- bug 3920178}

      l_per_first_name          VARCHAR2(150);
      l_per_middle_name         VARCHAR2(60);
      l_per_last_name           VARCHAR2(150);
      l_contact_person_name     VARCHAR2(400);
      l_owner_table_id          NUMBER;
      l_per_ph_number           VARCHAR2(60);
      l_return_status           VARCHAR2(2);
	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_INFO';
	--
   BEGIN
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      IF l_debug_on THEN
       wsh_debug_sv.push(l_module_name);
       wsh_debug_sv.log (l_module_name, 'delivery id' , p_delivery_id);
       wsh_debug_sv.log (l_module_name, 'document type' , p_document_type);
      END IF;

      x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

      OPEN l_del_info_cur;
      FETCH l_del_info_cur INTO x_name, l_customer_id, l_org_id,l_ship_to_location_id;--bug 3920178
      IF ( l_del_info_cur % NOTFOUND) THEN
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Error at cursor l_del_info_cur');
         END IF;

         CLOSE l_del_info_cur;
         RAISE wsh_invalid_delivery_id;
      END IF;
      CLOSE l_del_info_cur;

      open l_cust_cur(l_customer_id);
      fetch l_cust_cur into x_customer_name, x_customer_number;
      close l_cust_cur;

      --bug 3920178 {
      open l_ship_to_site_use_id_csr(p_delivery_id);
      fetch l_ship_to_site_use_id_csr into l_ship_to_site_use_id, l_cnt;
      IF l_ship_to_site_use_id_csr%NOTFOUND THEN
         l_ship_to_site_use_id := -1;
      END IF;
      close l_ship_to_site_use_id_csr;

     IF l_debug_on THEN
      WSH_DEBUG_SV.log(L_MODULE_NAME, 'l_ship_to_site_use_id' , l_ship_to_site_use_id);
     END IF;
      IF nvl(l_ship_to_site_use_id, -1) <> -1 THEN
      --{
          open  l_site_use_loc_csr(l_ship_to_site_use_id);
          fetch l_site_use_loc_csr into l_ship_to_loc_code, l_ship_to_site_contact_id;
          IF l_site_use_loc_csr%NOTFOUND THEN
            l_ship_to_loc_code := NULL;
          END IF;
          close l_site_use_loc_csr;
      --}
      END IF;

      IF l_ship_to_loc_code IS NULL THEN
      --{
          l_operating_unit := WSH_UTIL_CORE.Get_OperatingUnit_Id(p_delivery_id);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'l_operating_unit' , l_operating_unit);
        END IF;
          open  l_cust_ship_to_loc_csr
                   (l_customer_id,
                    l_ship_to_location_id,
                    l_operating_unit);
          fetch l_cust_ship_to_loc_csr into l_ship_to_loc_code, l_ship_to_site_contact_id;
          IF l_cust_ship_to_loc_csr%NOTFOUND THEN
            l_ship_to_loc_code := NULL;
          END IF;
          close l_cust_ship_to_loc_csr;

          IF l_ship_to_loc_code IS NULL THEN
          --{
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(L_MODULE_NAME, 'Using Customer Relationship Cursor');
            END IF;

              open l_rel_cust_ship_to_loc_csr
                     (l_customer_id,
                      l_ship_to_location_id,
                      l_operating_unit);
              fetch l_rel_cust_ship_to_loc_csr into l_ship_to_loc_code,l_ship_to_site_contact_id;
              close l_rel_cust_ship_to_loc_csr;
          --}
          END IF;
      --}
      END IF;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'l_ship_to_loc_code', l_ship_to_loc_code);
      END IF;

      IF l_ship_to_loc_code IS NULL THEN
         raise fnd_api.g_exc_error;
      END IF;

      IF (l_ship_to_site_contact_id is not null) THEN
      --{
         get_name_number(
                     l_ship_to_site_contact_id,
                     l_per_ph_number,
                     l_contact_person_name,
                     l_return_status
                     );
         IF  l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

          x_cnsgn_cont_per_name := l_contact_person_name;
          x_cnsgn_cont_per_ph   := l_per_ph_number;
      --}
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log (L_MODULE_NAME, 'Contact Person Name ',
                                                 x_cnsgn_cont_per_name);
         WSH_DEBUG_SV.log (L_MODULE_NAME, ' Contact Person Phone Number ',
                                                     x_cnsgn_cont_per_ph);
     END IF;


      x_ship_to_loc_code := l_ship_to_loc_code;
      --bug 3920178 }

      x_warehouse_type := WSH_EXTERNAL_INTERFACE_SV.Get_Warehouse_Type
							(
							 p_organization_id =>l_org_id,
                                                         x_return_status   =>x_return_status
							);
      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name, 'x_warehouse_type,x_return_status',x_warehouse_type||','||x_return_status);
      END IF;

      IF ( p_document_type = 'SA' ) THEN

         OPEN  l_src_hdr_no_cur;
         FETCH l_src_hdr_no_cur INTO x_name;
         IF ( l_src_hdr_no_cur % NOTFOUND) THEN
            IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name, 'Error at cursor l_src_hdr_no_cur');
            END IF;
            CLOSE l_src_hdr_no_cur;
            RAISE wsh_invalid_delivery_id;
         END IF;
         CLOSE l_src_hdr_no_cur;

         OPEN  l_get_dates_cur;
         FETCH l_get_dates_cur
         INTO  x_arrival_date,
               x_departure_date,
               x_vehicle_num_prefix,
               x_vehicle_number,
               x_route_id,
               x_routing_instructions,
               x_departure_seal_code,
--Bug 3458160
               x_operator;
         IF ( l_get_dates_cur % NOTFOUND ) THEN
            IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name, 'Error at cursor l_get_dates_cur');
            END IF;
            CLOSE l_get_dates_cur;
            RAISE wsh_invalid_delivery_id;
         END IF;
         CLOSE l_get_dates_cur;
         IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name, 'Arrival Date', x_arrival_date);
          wsh_debug_sv.log (l_module_name, 'Departure Date', x_departure_date);
         END IF;


      END IF;

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'name' , x_name);
       wsh_debug_sv.pop (l_module_name);
      END IF;
   EXCEPTION
      --bug 3920178
      WHEN fnd_api.g_exc_error THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'fnd_api.g_exc_error has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:fnd_api.g_exc_error');
         END IF;
      WHEN wsh_invalid_delivery_id THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_delivery_id exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_delivery_id');
         END IF;

      WHEN OTHERS THEN
         x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
         END IF;
   END Get_Delivery_Info;


/*
  This procedure Get_Part_Addr_Info, is called by the outbound map(WSHSSNO.xgm),
to populate the elements in the PARTNER segment under SHIPMENT level.

*/
PROCEDURE Get_Part_Addr_Info(
	p_partner_type		IN	VARCHAR2,
	p_delivery_id		IN	NUMBER,
	x_party_name		OUT NOCOPY  	VARCHAR2,
	x_partner_location	OUT NOCOPY 	VARCHAR2,
	x_currency		OUT NOCOPY 	VARCHAR2,
	x_duns_number		OUT NOCOPY 	VARCHAR2,
	x_intmed_ship_to_location OUT NOCOPY  	VARCHAR2,
	x_pooled_ship_to_location OUT NOCOPY  	VARCHAR2,
	x_address1		OUT NOCOPY  	VARCHAR2,
	x_address2		OUT NOCOPY  	VARCHAR2,
	x_address3		OUT NOCOPY  	VARCHAR2,
	x_address4		OUT NOCOPY  	VARCHAR2,
	x_city			OUT NOCOPY  	VARCHAR2,
	x_country		OUT NOCOPY  	VARCHAR2,
	x_county		OUT NOCOPY  	VARCHAR2,
	x_postal_code		OUT NOCOPY  	VARCHAR2,
	x_region		OUT NOCOPY  	VARCHAR2,
	x_state			OUT NOCOPY  	VARCHAR2,
	x_fax_number		OUT NOCOPY  	VARCHAR2,
	x_telephone		OUT NOCOPY  	VARCHAR2,
	x_url			OUT NOCOPY  	VARCHAR2,
	x_return_status 	OUT NOCOPY 	VARCHAR2) IS

CURSOR loc_ids_cur IS
SELECT  organization_id,
	initial_pickup_location_id,
	ultimate_dropoff_location_id,
	intmed_ship_to_location_id,
	pooled_ship_to_location_id,
	currency_code
FROM wsh_new_deliveries
WHERE delivery_id = p_delivery_id;

/* Patchset I: Locations Project. Select address components from
wsh_ship_from_org_locations_v */
CURSOR ship_from_info_cur(p_org_id NUMBER, p_loc_id NUMBER) IS
 SELECT
	WSFL.ORGANIZATION_NAME 		PARTY_NAME,
	HL.LOCATION_CODE		PARTNER_LOCATION,
	0				DUNS_NUMBER,
	NULL				INTMED_SHIP_TO_LOCATION,
	NULL				POOLED_SHIP_TO_LOCATION_ID,
	WSFL.ADDRESS1		        ADDRESS1,
	WSFL.ADDRESS2		        ADDRESS2,
	WSFL.ADDRESS3		        ADDRESS3,
	NULL				ADDRESS4,
	WSFL.CITY			CITY,
	WSFL.COUNTRY			COUNTRY,
	NULL				COUNTY,
	WSFL.POSTAL_CODE		POSTAL_CODE,
	WSFL.PROVINCE			REGION,
	WSFL.STATE			STATE,
	HL.TELEPHONE_NUMBER_2		FAX_NUMBER,
	HL.TELEPHONE_NUMBER_1		TELEPHONE,
	NULL				URL
  FROM
        wsh_ship_from_org_locations_v WSFL,
        HR_LOCATIONS_ALL HL
  WHERE
        WSFL.wsh_location_id = p_loc_id
        AND WSFL.source_location_id =  HL.location_id;

/* Patchset I: Locations Project. Selecting from wsh_customer_locations_v */
CURSOR ship_to_info_cur(p_loc_id NUMBER, p_opUnit_id NUMBER DEFAULT NULL) IS
SELECT
	DISTINCT wclv.CUSTOMER_NAME	PARTY_NAME,
	wclv.LOCATION			PARTNER_LOCATION,
	NULL				CURRENCY,
	wclv.DUNS_NUMBER		DUNS_NUMBER,
	WCLV.ADDRESS1			ADDRESS1,
	WCLV.ADDRESS2			ADDRESS2,
	WCLV.ADDRESS3			ADDRESS3,
	WCLV.ADDRESS4			ADDRESS4,
	WCLV.CITY			CITY,
	WCLV.COUNTRY			COUNTRY,
	WCLV.COUNTY			COUNTY,
	WCLV.POSTAL_CODE		POSTAL_CODE,
	WCLV.PROVINCE			REGION,
	WCLV.STATE			STATE
  FROM
        wsh_customer_locations_v wclv
  WHERE
       wclv.wsh_location_id = p_loc_id
       and wclv.org_id = nvl(p_opUnit_id, wclv.org_id)
       AND wclv.customer_status = 'A'
       AND wclv.cust_acct_site_status = 'A'
       AND wclv.site_use_status = 'A'
       AND wclv.site_use_code = 'SHIP_TO';

l_organization_id NUMBER;
l_init_loc_id	NUMBER;
l_ult_loc_id	NUMBER;
l_intmed_loc_id NUMBER;
l_pooled_loc_id NUMBER;
l_return_status	VARCHAR2(30);
l_dummy	VARCHAR2(360);
--
-- Patchset I: Locations Project. kvenkate.
l_opUnit_id     NUMBER;

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PART_ADDR_INFO';
--
BEGIN
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
  wsh_debug_sv.push(l_module_name);
  wsh_debug_sv.log (l_module_name, 'Partner Type', p_partner_type);
  wsh_debug_sv.log (l_module_name, 'Delivery Id', p_delivery_id);
 END IF;

	OPEN loc_ids_cur;
	FETCH loc_ids_cur INTO 	l_organization_id, l_init_loc_id, l_ult_loc_id, l_intmed_loc_id, l_pooled_loc_id, x_currency;
	CLOSE loc_ids_cur;

       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Calling program unit WSH_UTIL_CORE.GET_OPERATINGUNIT_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

/* Patchset I: Locations Project. Get the OperatingUnit Id */
          l_opUnit_id := wsh_util_core.get_OperatingUnit_id(p_delivery_id);


       IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'Operating Unit Id', l_opUnit_id);
	wsh_debug_sv.log (l_module_name, 'Initial Pickup Location Id', l_init_loc_id);
	wsh_debug_sv.log (l_module_name, 'Ultimate Dropoff location Id', l_ult_loc_id);
	wsh_debug_sv.log (l_module_name, 'Intmed ShipTo Location Id', l_intmed_loc_id);
	wsh_debug_sv.log (l_module_name, 'Pooled ShipTo Location Id', l_pooled_loc_id);
       END IF;

	IF(p_partner_type = 'ShipFrom') THEN
   	  OPEN ship_from_info_cur(l_organization_id, l_init_loc_id);
	  FETCH ship_from_info_cur INTO
			x_party_name,
			x_partner_location,
			x_duns_number,
			x_intmed_ship_to_location,
			x_pooled_ship_to_location,
			x_address1,
			x_address2,
			x_address3,
			x_address4,
			x_city,
			x_country,
			x_county,
			x_postal_code,
			x_region,
			x_state,
			x_fax_number,
			x_telephone,
			x_url;
	   CLOSE ship_from_info_cur;

	ELSIF(p_partner_type = 'ShipTo') THEN
/* Patchset I: Locations Project. Use  OperatingUnit Id for ShipTo*/
	  OPEN ship_to_info_cur(l_ult_loc_id, l_opUnit_id);
	  FETCH ship_to_info_cur INTO x_party_name,
			x_partner_location,
			x_currency,
			x_duns_number,
			x_address1,
			x_address2,
			x_address3,
			x_address4,
			x_city,
			x_country,
			x_county,
			x_postal_code,
			x_region,
			x_state;
	   CLOSE ship_to_info_cur;

       	  OPEN ship_to_info_cur(l_intmed_loc_id);
	  FETCH ship_to_info_cur INTO l_dummy,
			x_intmed_ship_to_location,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy;
	   CLOSE ship_to_info_cur;

	OPEN ship_to_info_cur(l_pooled_loc_id);
	  FETCH ship_to_info_cur INTO l_dummy,
			x_pooled_ship_to_location,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy;
	   CLOSE ship_to_info_cur;

	   Get_Phone_Fax(
		p_loc_id => l_ult_loc_id,
		x_phone	=> x_telephone,
		x_fax	=> x_fax_number,
		x_url   => x_url,
		x_return_status => l_return_status);

           IF l_debug_on THEN
	    wsh_debug_sv.log (l_module_name, 'x_telephone,x_fax_number', x_telephone||','||x_fax_number);
	    wsh_debug_sv.log (l_module_name, 'x_url', x_url);
	    wsh_debug_sv.log (l_module_name, 'l_return_status', l_return_status);
           END IF;

	END IF;

 IF l_debug_on THEN
  wsh_debug_sv.pop(l_module_name);
 END IF;
EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END get_part_addr_info;

PROCEDURE Get_Phone_Fax(
		p_loc_id IN NUMBER,
		x_phone	OUT NOCOPY  VARCHAR2,
		x_fax	OUT NOCOPY  VARCHAR2,
		x_url	OUT NOCOPY  VARCHAR2,
		x_return_status OUT NOCOPY  VARCHAR2) IS

/* Patchset I: Locations Project. Joining with wsh_locations_hz_v */
CURSOR phone_fax_cur(l_line_type VARCHAR2) IS
	SELECT 	hcp.raw_phone_number,
		hcp.url
	  FROM	hz_party_sites hps,
		hz_contact_points hcp,
                wsh_locations_hz_v wlhz
	  WHERE	HCP.CONTACT_POINT_TYPE = 'PHONE'
          AND   HCP.PHONE_LINE_TYPE=l_line_type
  	  AND	HCP.OWNER_TABLE_NAME = 'HZ_PARTY_SITES'
  	  AND	HPS.PARTY_SITE_ID = HCP.OWNER_TABLE_ID
          AND   wlhz.wsh_location_id = p_loc_id
          AND   wlhz.source_location_id = hps.location_id
	  ORDER BY hcp.primary_flag desc;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PHONE_FAX';
--
BEGIN
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
  wsh_debug_sv.push(l_module_name);
  wsh_debug_sv.log (l_module_name, 'Loc Id', p_loc_id);
 END IF;

	OPEN phone_fax_cur('GEN');
	FETCH phone_fax_cur INTO x_phone, x_url;
	CLOSE phone_fax_cur;

	OPEN phone_fax_cur('FAX');
	FETCH phone_fax_cur INTO x_fax, x_url;
	CLOSE phone_fax_cur;

 IF l_debug_on THEN
  wsh_debug_sv.pop(l_module_name);
 END IF;

EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Get_Phone_Fax;

PROCEDURE get_ship_method_code(
        p_carrier_name              IN     VARCHAR2,
        p_service_level             IN     VARCHAR2,
        p_mode_of_transport         IN     VARCHAR2,
        p_doc_type                  IN     VARCHAR2, -- bug 3479643
        p_delivery_name             IN     VARCHAR2, -- bug 3479643
        x_ship_method_code          OUT NOCOPY     VARCHAR2,
        x_return_status             OUT NOCOPY      VARCHAR2)
IS

-- Bug fix 2930693
-- Added nvl to wcs.service_level and wcs.mode_of_transport because they could be NULL in wsh_carrier_services
-- bug 3479643
-- Created  a separate cursor so that for 945 inbound, we can
-- use the delivery's ship method to validate the incoming ship method
cursor c_ship_method_cur is
select wcs.ship_method_code
from   wsh_carrier_services wcs,
       wsh_carriers_v wcar
where  wcar.carrier_name = p_carrier_name
and    nvl(wcs.service_level, '!') = nvl(p_service_level, '!')
and    nvl(wcs.mode_of_transport, '!') = nvl(p_mode_of_transport, '!')
and    wcs.carrier_id = wcar.carrier_id;

l_ship_method_code VARCHAR2(32767);
l_delivery_id  NUMBER;
l_organization_id  NUMBER;
l_org_type         VARCHAR2(32767);
l_return_status    VARCHAR2(1);
-- bug 3479643

wsh_invalid_ship_method EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SHIP_METHOD_CODE';
--

BEGIN
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 IF l_debug_on THEN
  wsh_debug_sv.push(l_module_name);
  wsh_debug_sv.log (l_module_name, 'Carrier Name', p_carrier_name);
  wsh_debug_sv.log (l_module_name, 'Service Level', p_service_level);
  wsh_debug_sv.log (l_module_name, 'Mode of Transport', p_mode_of_transport);
  wsh_debug_sv.log (l_module_name, 'Document Type', p_doc_type);
  wsh_debug_sv.log (l_module_name, 'Delivery Name', p_delivery_name);
 END IF;
 -- bug 3857041
 IF (
     nvl(p_service_level,'!!!!') <> '!!!!'
     OR
     nvl(p_mode_of_transport,'!!!!') <> '!!!!'
    )
 THEN
 --{
     open c_ship_method_cur;
     fetch c_ship_method_cur into x_ship_method_code;
     IF ( c_ship_method_cur%NOTFOUND) THEN
         IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Error -- Ship Method Not Found');
         END IF;
     END IF;
     close c_ship_method_cur;
 --}
 END IF;
 -- bug 3857041

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
 IF l_debug_on THEN
  wsh_debug_sv.pop(l_module_name);
 END IF;

EXCEPTION
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END get_ship_method_code;

    -- ---------------------------------------------------------------------
    -- Procedure:	Get_Locn_Cust_Info
    --
    -- Parameters:
    --
    -- Description:  This procedure gets the location, party_name, party_number
    --               that are required for SHIPITEM and SHIPUNIT during
    --                  940/945 outbound. This procedure to be called from
    --               the outbound mapping.
    -- Created:   Locations Project. Patchset I. KVENKATE
    -- -----------------------------------------------------------------------

PROCEDURE get_locn_cust_info(
        p_location_id      IN   NUMBER,
        p_org_id           IN   NUMBER,
        p_customer_id      IN   NUMBER,
        x_location         OUT NOCOPY VARCHAR2,
        x_party_name       OUT NOCOPY VARCHAR2,
        x_party_number     OUT NOCOPY VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        p_delivery_detail_id IN NUMBER,
        p_wsn_rowid          IN     VARCHAR2,
        p_requested_quantity IN   NUMBER,
        p_fm_serial_number   IN   VARCHAR2,
        p_to_serial_number   IN   VARCHAR2,
        x_requested_quantity OUT  NOCOPY NUMBER,
        x_shipped_quantity   OUT  NOCOPY NUMBER,
        p_site_use_id        IN  NUMBER,
        --bug 4227777
        p_entity_type        IN VARCHAR2,
        x_cnsgn_cont_per_name OUT NOCOPY VARCHAR2,
        x_cnsgn_cont_per_ph OUT NOCOPY VARCHAR2
)

IS

l_org_id    NUMBER;
l_count     NUMBER;
CURSOR loc_cust_cur (p_loc_id NUMBER, p_org_id NUMBER, p_cust_id NUMBER) IS
  SELECT  HCSU.LOCATION --bug 3920178 , HP.PARTY_NAME, HP.PARTY_NUMBER
  FROM
    HZ_CUST_SITE_USES_ALL HCSU,
    HZ_CUST_ACCT_SITES_ALL HCAS,
    HZ_PARTY_SITES HPS,
    HZ_CUST_ACCOUNTS HCA,
    HZ_PARTIES HP,
    WSH_LOCATIONS WL1
  WHERE
     WL1.wsh_location_id = p_loc_id AND
     HCA.CUST_ACCOUNT_ID = p_cust_id AND --bugfix 3842898
     (HCAS.ORG_ID IS NULL OR HCAS.ORG_ID = p_org_id) AND
     WL1.SOURCE_LOCATION_ID = HPS.LOCATION_ID AND
     WL1.LOCATION_SOURCE_CODE = 'HZ' AND
     HCA.PARTY_ID = HP.PARTY_ID AND
     HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID AND
     HCAS.PARTY_SITE_ID = HPS.PARTY_SITE_ID AND
     HCSU.SITE_USE_CODE = 'SHIP_TO' AND
     HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID AND
     HCSU.STATUS = 'A' AND
     HCAS.STATUS = 'A' AND
     HCA.STATUS = 'A' AND
     HCAS.ORG_ID = HCSU.ORG_ID AND
     -- removed the NVL around the org_id k proj
     --bug 3920178
     HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
  ORDER BY
     HCSU.SITE_USE_CODE;

CURSOR org_id_cur(p_del_detail_id NUMBER) IS
  SELECT wdd.org_id org_id, count(*) cnt
  FROM wsh_delivery_details wdd
  WHERE wdd.delivery_detail_id IN
        (SELECT wda.delivery_detail_id
         FROM wsh_delivery_assignments_v wda
         START WITH delivery_detail_id  = p_del_detail_id
         CONNECT BY PRIOR wda.delivery_detail_id = wda.parent_delivery_detail_id         )
  GROUP BY org_id
  HAVING org_id IS NOT NULL
  ORDER BY cnt desc;

CURSOR get_rowid_count(cp_delivery_detail_id NUMBER) IS
 SELECT rowidtochar(min(rowid)),count(*),sum(quantity)
 FROM   wsh_serial_numbers
 WHERE  delivery_detail_id = cp_delivery_detail_id;

CURSOR get_wsn_qty(cp_wsn_rowid VARCHAR2) IS
 SELECT quantity
 FROM   wsh_serial_numbers
 WHERE   rowidtochar(rowid) = cp_wsn_rowid;

--bug 3920178 {
      cursor l_site_use_loc_csr(p_site_use_id IN NUMBER) is
      SELECT LOCATION
      FROM   HZ_CUST_SITE_USES_ALL
      WHERE  site_use_id = p_site_use_id;

      cursor l_rel_cust_ship_to_loc_csr
                (p_customer_id         IN NUMBER,
                 p_ship_to_location_id IN NUMBER,
                 p_org_id              IN NUMBER) is
      SELECT HCSU.LOCATION
      FROM   HZ_CUST_SITE_USES_ALL HCSU,
             HZ_CUST_ACCT_SITES_ALL HCAS,
             HZ_PARTY_SITES HPS,
             HZ_CUST_ACCOUNTS HCA,
             HZ_CUST_ACCT_RELATE_ALL HCAR
      WHERE  HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
      AND    HCAS.PARTY_SITE_ID     = HPS.PARTY_SITE_ID
      AND    HCAS.CUST_ACCOUNT_ID   = HCA.CUST_ACCOUNT_ID
      AND    HCSU.SITE_USE_CODE     = 'SHIP_TO'
      AND    HCSU.STATUS            = 'A'
      AND    HCAS.STATUS            = 'A'
      AND    HCA.STATUS             = 'A'
      AND    HPS.LOCATION_ID        = p_ship_to_location_id
      AND    HCA.CUST_ACCOUNT_ID    = HCAR.CUST_ACCOUNT_ID
      AND    HCAR.RELATED_CUST_ACCOUNT_ID    = p_customer_id
      AND    HCAR.SHIP_TO_FLAG      = 'Y'
      AND    (HCAS.ORG_ID IS NULL   OR HCAS.ORG_ID = p_org_id)
      AND    HCAS.ORG_ID = HCSU.ORG_ID ;
      -- removed the nvl from org_id k proj

    CURSOR c_cust_info_cur(p_customer_id IN NUMBER) IS
    SELECT HP.PARTY_NAME, HP.PARTY_NUMBER
    FROM HZ_PARTIES HP,
    HZ_CUST_ACCOUNTS HCA
    WHERE HP.PARTY_ID = HCA.PARTY_ID
    AND HCA.CUST_ACCOUNT_ID = p_customer_id;

     l_deliver_to_site_use_id NUMBER;
     l_location VARCHAR2(32767);

--bug 3920178 }


l_wsn_rowid		VARCHAR2(100);
l_wsn_count		NUMBER;
l_wsn_qty		NUMBER;
l_wsn_sum_qty		NUMBER;

--bug 4227777

CURSOR l_get_lines_in_container_csr IS
    SELECT wda.delivery_detail_id
    FROM  wsh_delivery_assignments_v wda
    START WITH wda.parent_delivery_detail_id  =  p_delivery_detail_id
    CONNECT BY PRIOR  wda.delivery_detail_id =  wda.parent_delivery_detail_id;

CURSOR l_get_ship_to_contact_csr (p_detail_id NUMBER)
IS
    SELECT  wdd.ship_to_contact_id
    FROM wsh_delivery_details wdd
    WHERE wdd.delivery_detail_id = p_detail_id
    AND   wdd.container_flag = 'N';



l_per_first_name          VARCHAR2(150);
l_per_middle_name         VARCHAR2(60);
l_per_last_name           VARCHAR2(150);
l_contact_person_name     VARCHAR2(360);
l_owner_table_id          NUMBER;

l_per_ph_number           VARCHAR2(40);
l_per_email_addr          VARCHAR2(2000);

l_uniq_ship_to_contact_id NUMBER;
l_curr_ship_to_contact_id NUMBER;
l_delivery_detail_tab     wsh_util_core.id_tab_type;
l_ship_to_contact_id_tab  wsh_util_core.id_tab_type;
l_return_status           VARCHAR2(2);


l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LOCN_CUST_INFO';

BEGIN
 --
 l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
 --
 IF l_debug_on IS NULL
 THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
 END IF;
 --
 x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 IF l_debug_on THEN
  wsh_debug_sv.push(l_module_name);
  wsh_debug_sv.log (l_module_name, 'Location Id', p_location_id);
  wsh_debug_sv.log(l_module_name, 'Org Id', p_org_id);
  wsh_debug_sv.log(l_module_name, 'Customer Id', p_customer_id);
  wsh_debug_sv.log(l_module_name, 'p_wsn_rowid',p_wsn_rowid);
  wsh_debug_sv.log(l_module_name, 'p_requested_quantity',p_requested_quantity);
  wsh_debug_sv.log(l_module_name, 'p_fm_serial_number',p_fm_serial_number);
  wsh_debug_sv.log(l_module_name, 'p_to_serial_number',p_to_serial_number);
  wsh_debug_sv.log(l_module_name, 'p_delivery_detail_id',p_delivery_detail_id);
  wsh_debug_sv.log(l_module_name, 'p_site_use_id',p_site_use_id);
  wsh_debug_sv.log(l_module_name, 'p_entity_type',p_entity_type);
 END IF;



 --bug 3920178{
   IF p_site_use_id IS NOT NULL THEN
      open l_site_use_loc_csr(p_site_use_id);
      fetch l_site_use_loc_csr INTO l_location;
      close l_site_use_loc_csr;
   END IF;
   if l_debug_on then
      wsh_debug_sv.log(l_module_name, 'l_location',l_location);
   end if;

 IF l_location IS NULL AND
 --bug 3920178}
    p_location_id IS NOT NULL THEN
    IF p_org_id IS NULL THEN
       OPEN org_id_cur(p_delivery_detail_id);
       FETCH org_id_cur INTO l_org_id, l_count;
       CLOSE org_id_cur;
    ELSE
       l_org_id := p_org_id;
    END IF;

    IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'l_org_id', l_org_id);
    END IF;

    OPEN loc_cust_cur(p_location_id, l_org_id, p_customer_id);
    FETCH loc_cust_cur INTO l_location; --bug 3920178
    IF loc_cust_cur%NOTFOUND THEN
       --Bug 3920178{
       IF l_debug_on THEN
          wsh_debug_sv.logmsg(l_module_name, 'Using l_rel_cust_ship_to_loc_csr');
       END IF;
       OPEN l_rel_cust_ship_to_loc_csr(p_customer_id, p_location_id, l_org_id);
       FETCH l_rel_cust_ship_to_loc_csr INTO l_location;
       CLOSE l_rel_cust_ship_to_loc_csr;
        --Bug 3920178}
    END IF;

    CLOSE loc_cust_cur;
  END IF;
  IF p_customer_id IS NOT NULL THEN
       OPEN c_cust_info_cur(p_customer_id);
       FETCH c_cust_info_Cur INTO x_party_name, x_party_number;
       CLOSE c_cust_info_cur;
  END IF;

  if l_debug_on then
      wsh_debug_sv.log(l_module_name, 'l_location',l_location);
   end if;

/* bug 4227777
  IF l_location IS NULL THEN
     raise fnd_api.g_exc_error;
  END IF;
*/
  x_location := l_location;

    IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'Location', x_location);
     wsh_debug_sv.log(l_module_name, 'Party Name', x_party_name);
     wsh_debug_sv.log(l_module_name, 'Party Number', x_party_number);
    END IF;

 IF p_wsn_rowid IS NOT NULL THEN
   OPEN  get_wsn_qty(p_wsn_rowid);
   FETCH get_wsn_qty INTO l_wsn_qty;
   CLOSE get_wsn_qty;
   x_shipped_quantity := l_wsn_qty;

   OPEN  get_rowid_count(p_delivery_detail_id);
   FETCH get_rowid_count INTO l_wsn_rowid, l_wsn_count,l_wsn_sum_qty;
   CLOSE get_rowid_count;

   IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_wsn_qty',l_wsn_qty );
     wsh_debug_sv.log(l_module_name, 'l_wsn_rowid',l_wsn_rowid );
     wsh_debug_sv.log(l_module_name, 'l_wsn_count',l_wsn_count );
     wsh_debug_sv.log(l_module_name, 'l_wsn_sum_qty',l_wsn_sum_qty );
   END IF;

   IF l_wsn_sum_qty = p_requested_quantity THEN
      x_requested_quantity :=l_wsn_qty;
   ELSE

      IF p_wsn_rowid = l_wsn_rowid THEN
         x_requested_quantity:=trunc(p_requested_quantity/l_wsn_count)+ mod(p_requested_quantity,l_wsn_count);
      ELSE
         x_requested_quantity:=trunc(p_requested_quantity/l_wsn_count);
      END IF;
   END IF;

   IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'x_shipped_quantity', x_shipped_quantity);
     wsh_debug_sv.log(l_module_name, 'x_requested_quantity', x_requested_quantity);
   END IF;
 END IF;
   --bug 4227777
   l_uniq_ship_to_contact_id := null;

   IF p_entity_type = 'CONTAINER'
   THEN --{
      --cursor to fetch all the lines (item/container) within the given container
      OPEN  l_get_lines_in_container_csr;
      FETCH l_get_lines_in_container_csr BULK COLLECT INTO
                                                      l_delivery_detail_tab;
      CLOSE l_get_lines_in_container_csr;

      IF l_delivery_detail_tab.count > 0 THEN --{
         FOR k in 1..l_delivery_detail_tab.count
         LOOP --{
           l_curr_ship_to_contact_id := null;
           OPEN l_get_ship_to_contact_csr (l_delivery_detail_tab(k));
           FETCH l_get_ship_to_contact_csr INTO l_curr_ship_to_contact_id;

           --for container lines this cursor will not fetch any record
           IF l_get_ship_to_contact_csr%FOUND THEN --{
              l_uniq_ship_to_contact_id := nvl(l_uniq_ship_to_contact_id,l_curr_ship_to_contact_id);

              IF     l_curr_ship_to_contact_id IS NOT NULL
                 AND  l_uniq_ship_to_contact_id <> l_curr_ship_to_contact_id
              THEN
                 --need not check remaining lines, since lines have different not-null contact IDs
                 l_uniq_ship_to_contact_id := null;
                 CLOSE l_get_ship_to_contact_csr;
                 EXIT;
               END IF;
           END IF; --}
           CLOSE l_get_ship_to_contact_csr;
        END LOOP; --}
      END IF; --}
   ELSIF p_entity_type = 'LINE'  THEN --}{
      OPEN  l_get_ship_to_contact_csr (p_delivery_detail_id);
      FETCH l_get_ship_to_contact_csr INTO l_uniq_ship_to_contact_id;
      CLOSE l_get_ship_to_contact_csr;
   END IF; --}

   IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_uniq_ship_to_contact_id',
                                                 l_uniq_ship_to_contact_id);
   END IF;
   IF l_uniq_ship_to_contact_id IS NOT NULL THEN --{
      get_name_number(
                     l_uniq_ship_to_contact_id,
                     l_per_ph_number,
                     l_contact_person_name,
                     l_return_status
                     );
      IF  l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

       x_cnsgn_cont_per_name := l_contact_person_name;
       x_cnsgn_cont_per_ph   := l_per_ph_number;

   END IF; --}


 IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'x_cnsgn_cont_per_name',
                                                     x_cnsgn_cont_per_name);
     wsh_debug_sv.log(l_module_name, 'x_cnsgn_cont_per_ph',
                                                     x_cnsgn_cont_per_ph);
   wsh_debug_sv.pop(l_module_name);
 END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               wsh_util_core.add_message(x_return_status, l_module_name);
                  --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
              END IF;
WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END get_locn_cust_info;

--bug 4227777
PROCEDURE get_name_number(
                     p_ship_to_site_contact_id IN NUMBER,
                     x_per_ph_number        OUT NOCOPY VARCHAR2,
                     x_contact_person_name  OUT NOCOPY VARCHAR2,
                     x_return_status        OUT NOCOPY VARCHAR2
                     )
IS
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                            || 'GET_NAME_NUMBER';
   l_per_first_name                     HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
   l_per_middle_name                    HZ_PARTIES.PERSON_MIDDLE_NAME%TYPE;
   l_per_last_name                      HZ_PARTIES.PERSON_LAST_NAME%TYPE;
   l_owner_table_id                     NUMBER;

      cursor l_ship_to_site_contact_csr(p_contact_id IN NUMBER) is
      SELECT PER_CONTACT.PERSON_FIRST_NAME,
             PER_CONTACT.PERSON_MIDDLE_NAME,
             PER_CONTACT.PERSON_LAST_NAME,
             PHONE_CONTACT.RAW_PHONE_NUMBER,
             HREL.PARTY_ID
      from   HZ_CUST_ACCOUNT_ROLES HCAR,
             HZ_RELATIONSHIPS HREL,
             HZ_ORG_CONTACTS HOC,
             HZ_CONTACT_POINTS   PHONE_CONTACT,
             HZ_PARTIES PER_CONTACT
      WHERE  HCAR.CUST_ACCOUNT_ROLE_ID           = p_contact_id
      AND    HREL.PARTY_ID                       = HCAR.PARTY_ID
      AND    HCAR.ROLE_TYPE                      = 'CONTACT'
      AND    HREL.RELATIONSHIP_ID                = HOC.PARTY_RELATIONSHIP_ID
      AND    HREL.SUBJECT_TABLE_NAME             = 'HZ_PARTIES'
      AND    HREL.OBJECT_TABLE_NAME              = 'HZ_PARTIES'
      AND    HREL.SUBJECT_TYPE                   = 'PERSON'
      AND    HREL.DIRECTIONAL_FLAG               = 'F'
      AND    HREL.SUBJECT_ID                     = PER_CONTACT.PARTY_ID
      AND    PHONE_CONTACT.OWNER_TABLE_NAME(+)   = 'HZ_PARTIES'
      AND    PHONE_CONTACT.OWNER_TABLE_ID(+)     = HREL.PARTY_ID
      AND    PHONE_CONTACT.CONTACT_POINT_TYPE(+) = 'PHONE'
      AND    PHONE_CONTACT.PHONE_LINE_TYPE(+)    = 'GEN'
      AND    PHONE_CONTACT.PRIMARY_FLAG(+)       = 'Y';

      cursor l_ship_to_site_ph_csr(p_owner_tbl_id IN NUMBER) is
      SELECT RAW_PHONE_NUMBER
      FROM   HZ_CONTACT_POINTS
      WHERE  OWNER_TABLE_NAME    = 'HZ_PARTIES'
      AND    OWNER_TABLE_ID     = p_owner_tbl_id
      AND    CONTACT_POINT_TYPE = 'PHONE'
      AND    PHONE_LINE_TYPE    = 'GEN';

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log (l_module_name, 'p_ship_to_site_contact_id', p_ship_to_site_contact_id);
   END IF;

   open  l_ship_to_site_contact_csr(p_ship_to_site_contact_id);
   fetch l_ship_to_site_contact_csr into l_per_first_name,
                                                l_per_middle_name,
                                                l_per_last_name,
                                                x_per_ph_number,
                                                l_owner_table_id;
   close l_ship_to_site_contact_csr;

   IF l_per_first_name IS NOT NULL THEN
   --{
       x_contact_person_name := l_per_first_name || ' ';
   --}
   END IF;

   IF l_per_middle_name IS NOT NULL THEN
   --{
       x_contact_person_name := x_contact_person_name || l_per_middle_name || ' ';
   --}
   END IF;

   IF l_per_last_name IS NOT NULL THEN
          --{
              x_contact_person_name := x_contact_person_name || l_per_last_name;          --}
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.log (L_MODULE_NAME,' Contact Person Phone Number ',
                                                               x_per_ph_number);
       WSH_DEBUG_SV.log (L_MODULE_NAME,' l_owner_table_id ',
                                                        l_owner_table_id);
   END IF;

   IF x_per_ph_number IS NULL
             AND l_owner_table_id IS NOT NULL
   THEN
   --{
      open l_ship_to_site_ph_csr(l_owner_table_id);
      fetch l_ship_to_site_ph_csr into x_per_ph_number;
      close l_ship_to_site_ph_csr;
   --}
   END IF;


   IF l_debug_on THEN
     wsh_debug_sv.log (l_module_name, 'x_per_ph_number', x_per_ph_number);
     wsh_debug_sv.log (l_module_name, 'x_contact_person_name',
                                                    x_contact_person_name);
     wsh_debug_sv.log (l_module_name, 'x_return_status', x_return_status);
     wsh_debug_sv.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END get_name_number;

 -- R12.1.1 STANDALONE PROJECT
 /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Get_Stnd_Delivery_Info                                   |
   |                                                                           |
   | DESCRIPTION     This procedure gets the Delivery Information at the time  |
   |                  populating the data into the interface tables, when      |
   |                  processing an Standalone inbound XML transaction.        |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/09       Leelaraj   Created                                      |
   |                                                                           |
   ============================================================================*/
   PROCEDURE Get_Stnd_Delivery_Info (p_delivery_id          IN           NUMBER  ,
                                     x_name                 OUT NOCOPY   VARCHAR2,
                                     x_org_id               OUT NOCOPY   NUMBER  ,
                                     x_arrival_date         OUT NOCOPY   DATE    ,
                                     x_departure_date       OUT NOCOPY   DATE    ,
                                     x_vehicle_num_prefix   OUT NOCOPY   VARCHAR2,
                                     x_vehicle_number       OUT NOCOPY   VARCHAR2,
                                     x_route_id             OUT NOCOPY   VARCHAR2,
                                     x_routing_instructions OUT NOCOPY   VARCHAR2,
                                     x_departure_seal_code  OUT NOCOPY   VARCHAR2,
                                     x_operator             OUT NOCOPY   VARCHAR2,
                                     x_ship_to_loc_code     OUT NOCOPY   VARCHAR2,
                                     x_pack_slip_num        OUT NOCOPY   VARCHAR2,
                                     x_bill_of_lading_num   OUT NOCOPY   VARCHAR2,
                                     -- Distributed - TPW Changes
                                     x_customer_name        OUT NOCOPY   VARCHAR2,
                                     x_return_status        OUT NOCOPY   VARCHAR2) IS

   CURSOR l_del_info_cur
   IS
   SELECT name,
	  customer_id,
	  organization_id,
          ultimate_dropoff_location_id
   FROM   wsh_new_deliveries
   WHERE  delivery_id = p_delivery_id;

   CURSOR l_get_dates_cur
   IS
   SELECT wts1.Actual_Departure_Date,
          wts2.Actual_Arrival_Date,
          wt.Vehicle_Num_Prefix,
          wt.Vehicle_Number,
          wt.Route_ID,
          wt.Routing_Instructions,
          wts1.Departure_Seal_Code,
          wt.operator
   FROM   wsh_delivery_legs  wdl,
          wsh_trip_stops     wts1,
          wsh_trip_stops     wts2,
          wsh_trips          wt
   WHERE  wts1.trip_id		= wt.trip_id
   AND    wts2.trip_id		= wt.trip_id
   AND    wts1.stop_id		= wdl.pick_up_stop_id
   AND    wts2.stop_id		= wdl.drop_off_stop_id
   AND    wdl.delivery_id	= p_delivery_id;

   l_org_id NUMBER;
   l_customer_id NUMBER;

   wsh_invalid_delivery_id EXCEPTION;

   CURSOR l_ship_to_site_use_id_csr( c_delivery_id IN NUMBER) is
   SELECT wdd.ship_to_site_use_id ship_to_site_use_id , count(*) cnt
   FROM   wsh_delivery_assignments_v wda,
          wsh_delivery_details wdd
   WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
   AND    wda.delivery_id        =  c_delivery_id
   AND    wdd.container_flag     = 'N'
   GROUP BY ship_to_site_use_id
   ORDER BY cnt DESC;

   CURSOR l_site_use_loc_csr(c_site_use_id IN NUMBER) is
   SELECT location
   FROM   hz_cust_site_uses_all
   WHERE  site_use_id = c_site_use_id;

   CURSOR l_cust_ship_to_loc_csr
             (c_customer_id         IN NUMBER,
              c_ship_to_location_id IN NUMBER,
              c_org_id              IN NUMBER) IS
   SELECT hcsu.location
   FROM   hz_cust_site_uses_all hcsu,
          hz_cust_acct_sites_all hcas,
          hz_cust_accounts hca,
          hz_party_sites hps
   WHERE  hcsu.cust_acct_site_id = hcas.cust_acct_site_id
   AND    hcas.party_site_id     = hps.party_site_id
   AND    hcas.cust_account_id   = hca.cust_account_id
   AND    hcsu.site_use_code     = 'SHIP_TO'
   AND    hcsu.status            = 'A'
   AND    hcas.status            = 'A'
   AND    hca.status             = 'A'
   AND    hps.location_id        = c_ship_to_location_id
   AND    hcas.cust_account_id   = c_customer_id
   AND    (hcas.org_id IS NULL OR hcas.org_id = c_org_id)
   AND    hcas.org_id            = hcsu.org_id ;

   CURSOR l_rel_cust_ship_to_loc_csr
             (c_customer_id         IN NUMBER,
              c_ship_to_location_id IN NUMBER,
              c_org_id              IN NUMBER) IS
   SELECT hcsu.location
   FROM   hz_cust_site_uses_all hcsu,
          hz_cust_acct_sites_all hcas,
          hz_party_sites hps,
          hz_cust_accounts hca,
          hz_cust_acct_relate_all hcar
   WHERE  hcsu.cust_acct_site_id       = hcas.cust_acct_site_id
   AND    hcas.party_site_id           = hps.party_site_id
   AND    hcas.cust_account_id         = hca.cust_account_id
   AND    hcsu.site_use_code           = 'SHIP_TO'
   AND    hcsu.status                  = 'A'
   AND    hcas.status                  = 'A'
   AND    hca.status                   = 'A'
   AND    hps.location_id              = c_ship_to_location_id
   AND    hca.cust_account_id          = hcar.cust_account_id
   AND    hcar.related_cust_account_id = c_customer_id
   AND    hcar.ship_to_flag            = 'Y'
   AND    (hcas.org_id IS NULL OR hcas.org_id = c_org_id)
   AND    hcas.org_id                  = hcsu.org_id ;

   -- Distributed - TPW Changes
   CURSOR c_cust_name_cur( c_customer_id IN NUMBER ) IS
   SELECT hp.party_name
   FROM   hz_parties hp,
          hz_cust_accounts hca
   WHERE  hca.party_id               = hp.party_id
   AND    hca.cust_account_id        = c_customer_id;

   l_operating_unit NUMBER;
   l_ship_to_site_use_id NUMBER;
   l_ship_to_location_id NUMBER;
   l_cnt NUMBER;
   l_ship_to_loc_code VARCHAR2(32767);

   l_return_status           VARCHAR2(2);
   --
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_STND_DELIVERY_INFO';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
    wsh_debug_sv.push(l_module_name);
    wsh_debug_sv.log (l_module_name, 'delivery id' , p_delivery_id);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

   OPEN l_del_info_cur;
   FETCH l_del_info_cur INTO x_name, l_customer_id, l_org_id,l_ship_to_location_id;
   --
   IF ( l_del_info_cur % NOTFOUND) THEN
      --
      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Error at cursor l_del_info_cur');
      END IF;
      --
      CLOSE l_del_info_cur;
      RAISE wsh_invalid_delivery_id;
   END IF;
   --
   CLOSE l_del_info_cur;

   l_operating_unit := WSH_UTIL_CORE.Get_OperatingUnit_Id(p_delivery_id);
   x_org_id := l_operating_unit;

   -- Distributed - TPW Changes
   open  c_cust_name_cur (l_customer_id);
   fetch c_cust_name_cur into x_customer_name;
   close c_cust_name_cur;

   OPEN l_ship_to_site_use_id_csr(p_delivery_id);
   FETCH l_ship_to_site_use_id_csr INTO l_ship_to_site_use_id, l_cnt;
   --
   IF l_ship_to_site_use_id_csr%NOTFOUND THEN
      l_ship_to_site_use_id := -1;
   END IF;
   --
   CLOSE l_ship_to_site_use_id_csr;
   --
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(L_MODULE_NAME, 'l_ship_to_site_use_id' , l_ship_to_site_use_id);
   END IF;
   --
   IF nvl(l_ship_to_site_use_id, -1) <> -1 THEN
   --{
       OPEN  l_site_use_loc_csr(l_ship_to_site_use_id);
       FETCH l_site_use_loc_csr INTO l_ship_to_loc_code;
       --
       IF l_site_use_loc_csr%NOTFOUND THEN
          l_ship_to_loc_code := NULL;
       END IF;
       --
       CLOSE l_site_use_loc_csr;
   --}
   END IF;

   IF l_ship_to_loc_code IS NULL THEN
   --{
     --
     IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_operating_unit' , l_operating_unit);
     END IF;
     --
     OPEN  l_cust_ship_to_loc_csr
              (l_customer_id,
               l_ship_to_location_id,
               l_operating_unit);
     FETCH l_cust_ship_to_loc_csr INTO l_ship_to_loc_code;
     --
     IF l_cust_ship_to_loc_csr%NOTFOUND THEN
        l_ship_to_loc_code := NULL;
     END IF;
     --
     CLOSE l_cust_ship_to_loc_csr;
     --
     IF l_ship_to_loc_code IS NULL THEN
     --{
       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(L_MODULE_NAME, 'Using Customer Relationship Cursor');
       END IF;

       OPEN l_rel_cust_ship_to_loc_csr(
                                       l_customer_id,
	                               l_ship_to_location_id,
                                       l_operating_unit);
       FETCH l_rel_cust_ship_to_loc_csr into l_ship_to_loc_code;
       CLOSE l_rel_cust_ship_to_loc_csr;
     --}
     END IF;
   --}
   END IF;
   IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_ship_to_loc_code', l_ship_to_loc_code);
   END IF;

   IF l_ship_to_loc_code IS NULL THEN
      raise fnd_api.g_exc_error;
   END IF;

   x_ship_to_loc_code := l_ship_to_loc_code;

   OPEN  l_get_dates_cur;
   FETCH l_get_dates_cur
   INTO  x_arrival_date,
         x_departure_date,
         x_vehicle_num_prefix,
         x_vehicle_number,
         x_route_id,
         x_routing_instructions,
         x_departure_seal_code,
         x_operator;
   --
   IF ( l_get_dates_cur % NOTFOUND ) THEN
      --
      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'Error at cursor l_get_dates_cur');
      END IF;
      --
      CLOSE l_get_dates_cur;
      RAISE wsh_invalid_delivery_id;
   END IF;
   --
   CLOSE l_get_dates_cur;

   BEGIN --{
      SELECT packing_slip_number
      INTO   x_pack_slip_num
      FROM   wsh_packing_slips_db_v
      WHERE  delivery_id = p_delivery_id;

      SELECT wdi.sequence_number
      INTO   x_bill_of_lading_num
      FROM   wsh_new_deliveries wnd,
             wsh_delivery_legs wdl,
             wsh_trip_stops wts,
             wsh_document_instances wdi
      WHERE  wnd.delivery_id      = p_delivery_id
      AND    wnd.delivery_id      = wdl.delivery_id
      AND    wdl.pick_up_stop_id  = wts.stop_id
      AND    wts.stop_location_id = wnd.initial_pickup_location_id
      AND    wdi.entity_id        = wdl.delivery_leg_id
      AND    wdi.entity_name      = 'WSH_DELIVERY_LEGS'
      AND    wdi.document_type    = 'BOL';

   EXCEPTION
     WHEN OTHERS THEN
        NULL;
   END; --}
   --
   IF l_debug_on THEN
    wsh_debug_sv.log (l_module_name, 'Name' , x_name);
    wsh_debug_sv.log (l_module_name, 'Ship To Loc Code' , x_ship_to_loc_code);
    wsh_debug_sv.log (l_module_name, 'Arrival Date', x_arrival_date);
    wsh_debug_sv.log (l_module_name, 'Departure Date', x_departure_date);
    wsh_debug_sv.log (l_module_name, 'Packing Slip Number' , x_pack_slip_num);
    wsh_debug_sv.log (l_module_name, 'BOL Number' , x_bill_of_lading_num);
    wsh_debug_sv.log (l_module_name, 'Customer Name' , x_customer_name);
    wsh_debug_sv.pop (l_module_name);
   END IF;
   --
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'fnd_api.g_exc_error has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:fnd_api.g_exc_error');
      END IF;
   WHEN wsh_invalid_delivery_id THEN
      x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'wsh_invalid_delivery_id exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_invalid_delivery_id');
      END IF;

   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                       WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Get_Stnd_Delivery_Info;


  -- R12.1.1 STANDALONE PROJECT
 /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Get_Delivery_Detail_Info                                 |
   |                                                                           |
   | DESCRIPTION     This procedure gets the Delivery Detail Information       |
   |                 like open quantity,backorder quantity,locator,order       |
   |                 header ,order line number and Ship to contact information.|
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/09       Leelaraj   Created                                      |
   |                                                                           |
   ============================================================================*/
PROCEDURE get_delivery_detail_info(
                                   p_src_line_id          IN         NUMBER  ,
                                   p_delivery_detail_id   IN         NUMBER  ,
                                   p_detail_seq_number    IN         NUMBER  ,
                                   p_locator_id           IN         NUMBER  ,
				   p_wsn_rowid            IN         VARCHAR2,
				   p_serial_type          IN         VARCHAR2 ,
                                   p_requested_quantity   IN         NUMBER,
                                   x_requested_quantity   OUT  NOCOPY NUMBER,
                                   x_shipped_quantity     OUT  NOCOPY NUMBER,
                                   x_open_quantity        OUT NOCOPY NUMBER  ,
                                   x_bo_quantity          OUT NOCOPY NUMBER  ,
				   x_locator_code         OUT NOCOPY VARCHAR2,
                                   x_shipto_cont_per_name OUT NOCOPY VARCHAR2,
                                   x_shipto_cont_per_ph   OUT NOCOPY VARCHAR2,
                                   x_shipto_cont_per_id   OUT NOCOPY NUMBER  ,
                                   x_document_type        OUT NOCOPY VARCHAR2,
                                   x_document_id          OUT NOCOPY NUMBER  ,
                                   x_line_number          OUT NOCOPY NUMBER  ,
                                   x_return_status        OUT NOCOPY VARCHAR2) IS

  CURSOR l_get_contacts_csr (c_detail_id NUMBER)
  IS
      SELECT wdd.ship_to_contact_id
      FROM   wsh_delivery_details wdd
      WHERE  wdd.delivery_detail_id = c_detail_id
      AND    wdd.container_flag = 'N';

 -- Distributed - TPW Changes
 CURSOR get_rowid_count(cp_delivery_detail_id NUMBER) IS
 SELECT rowidtochar(min(rowid)),count(*),sum(quantity)
 FROM   wsh_serial_numbers
 WHERE  delivery_detail_id = cp_delivery_detail_id;

 CURSOR get_wsn_qty(cp_wsn_rowid VARCHAR2) IS
 SELECT quantity
 FROM   wsh_serial_numbers
 WHERE  rowidtochar(rowid) = cp_wsn_rowid;

CURSOR get_msnt_rowid_count(cp_delivery_detail_id NUMBER) IS
SELECT rowidtochar(min(rowid)),count(*),sum(to_number(SERIAL_PREFIX))
FROM   mtl_serial_numbers_temp
WHERE transaction_temp_id IN
           (SELECT transaction_temp_id
	     FROM WSH_DELIVERY_DETAILS
	     WHERE DELIVERY_DETAIL_ID = cp_delivery_detail_id
	      AND  SOURCE_CODE = 'OE');

 CURSOR get_msnt_qty(cp_wsn_rowid VARCHAR2) IS
 SELECT to_number(SERIAL_PREFIX)
 FROM   mtl_serial_numbers_temp
 WHERE  rowidtochar(rowid) = cp_wsn_rowid;

  l_wsn_rowid		VARCHAR2(100);
  l_wsn_count		NUMBER;
  l_wsn_qty		NUMBER;
  l_wsn_sum_qty		NUMBER;

  l_uniq_ship_to_contact_id NUMBER;
  l_curr_ship_to_contact_id NUMBER;
  l_delivery_detail_tab     wsh_util_core.id_tab_type;
  l_ship_to_contact_id_tab  wsh_util_core.id_tab_type;
  l_return_status           VARCHAR2(2);
  l_temp1 BOOLEAN;
  l_temp2 BOOLEAN;
  -- Distributed - TPW Changes
  l_source_document_type_id NUMBER;
  l_source_document_id      NUMBER;
  l_source_document_line_id NUMBER;

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_DETAIL_INFO';

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
   wsh_debug_sv.push(l_module_name);
   wsh_debug_sv.log(l_module_name, 'p_src_line_id',p_src_line_id);
   wsh_debug_sv.log(l_module_name, 'p_delivery_detail_id',p_delivery_detail_id);
   wsh_debug_sv.log(l_module_name, 'p_detail_seq_number',p_detail_seq_number);
   wsh_debug_sv.log(l_module_name, 'p_locator_id',p_locator_id);
   wsh_debug_sv.log(l_module_name, 'p_serial_type',P_serial_type);
   wsh_debug_sv.log(l_module_name, 'p_wsn_rowid',p_wsn_rowid);
   wsh_debug_sv.log(l_module_name, 'p_requested_quantity',p_requested_quantity);

  END IF;

  IF (p_locator_id is not null) THEN --{

    begin
      select concatenated_segments
      into   x_locator_code
      from   mtl_item_locations_kfv
      where  inventory_location_id = p_locator_id;
    exception
      when others then
        null;
    end;
  END IF; --}

  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'x_locator_code', x_locator_code);
  END IF;

  IF p_detail_seq_number = 1 THEN --{

    select sum(requested_quantity)
    into   x_open_quantity
    from   wsh_delivery_details
    where  source_line_id = p_src_line_id
    and    source_code = 'OE'
    and    released_status in ('N','R','S','Y');

    select sum(requested_quantity)
    into   x_bo_quantity
    from   wsh_delivery_details
    where  source_line_id = p_src_line_id
    and    source_code = 'OE'
    and    released_status = 'B';

    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'x_open_quantity', x_open_quantity);
      wsh_debug_sv.log(l_module_name, 'x_bo_quantity', x_bo_quantity);
    END IF;

  END IF; --}

  -- Distributed - TPW Changes
  IF p_wsn_rowid IS NOT NULL THEN --{

    IF P_SERIAL_TYPE = 'WSN' THEN

      OPEN  get_wsn_qty(p_wsn_rowid);
      FETCH get_wsn_qty INTO l_wsn_qty;
      CLOSE get_wsn_qty;

      x_shipped_quantity := l_wsn_qty;

      OPEN  get_rowid_count(p_delivery_detail_id);
      FETCH get_rowid_count INTO l_wsn_rowid, l_wsn_count,l_wsn_sum_qty;
      CLOSE get_rowid_count;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_wsn_qty',l_wsn_qty );
        wsh_debug_sv.log(l_module_name, 'l_wsn_rowid',l_wsn_rowid );
        wsh_debug_sv.log(l_module_name, 'l_wsn_count',l_wsn_count );
        wsh_debug_sv.log(l_module_name, 'l_wsn_sum_qty',l_wsn_sum_qty );
      END IF;

      IF l_wsn_sum_qty = p_requested_quantity THEN
         x_requested_quantity :=l_wsn_qty;
      ELSE

         IF p_wsn_rowid = l_wsn_rowid THEN
            x_requested_quantity:=trunc(p_requested_quantity/l_wsn_count)+ mod(p_requested_quantity,l_wsn_count);
         ELSE
            x_requested_quantity:=trunc(p_requested_quantity/l_wsn_count);
         END IF;
      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'x_shipped_quantity', x_shipped_quantity);
        wsh_debug_sv.log(l_module_name, 'x_requested_quantity', x_requested_quantity);
      END IF;

    ELSE
      OPEN  get_msnt_qty(p_wsn_rowid);
      FETCH get_msnt_qty INTO l_wsn_qty;
      CLOSE get_msnt_qty;
      x_shipped_quantity := l_wsn_qty;

      OPEN  get_msnt_rowid_count(p_delivery_detail_id);
      FETCH get_msnt_rowid_count INTO l_wsn_rowid, l_wsn_count,l_wsn_sum_qty;
      CLOSE get_msnt_rowid_count;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_msnt_qty',l_wsn_qty );
        wsh_debug_sv.log(l_module_name, 'l_msnt_rowid',l_wsn_rowid );
        wsh_debug_sv.log(l_module_name, 'l_msnt_count',l_wsn_count );
        wsh_debug_sv.log(l_module_name, 'l_msnt_sum_qty',l_wsn_sum_qty );
      END IF;

      IF l_wsn_sum_qty = p_requested_quantity THEN
         x_requested_quantity :=l_wsn_qty;
      ELSE

         IF p_wsn_rowid = l_wsn_rowid THEN
            x_requested_quantity:=trunc(p_requested_quantity/l_wsn_count)+ mod(p_requested_quantity,l_wsn_count);
         ELSE
            x_requested_quantity:=trunc(p_requested_quantity/l_wsn_count);
         END IF;
      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'x_shipped_quantity', x_shipped_quantity);
        wsh_debug_sv.log(l_module_name, 'x_requested_quantity', x_requested_quantity);
      END IF;

    END IF ;
   --
  END IF; --}

  OPEN  l_get_contacts_csr (p_delivery_detail_id);
  FETCH l_get_contacts_csr INTO l_uniq_ship_to_contact_id;
  CLOSE l_get_contacts_csr;

    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name, 'l_uniq_ship_to_contact_id',
                                                  l_uniq_ship_to_contact_id);
    END IF;

    IF l_uniq_ship_to_contact_id IS NOT NULL THEN --{
       get_name_number(
                      l_uniq_ship_to_contact_id,
                      x_shipto_cont_per_ph,
                      x_shipto_cont_per_name,
                      l_return_status
                      );
       IF  l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       x_shipto_cont_per_id := l_uniq_ship_to_contact_id;

    END IF; --}

     begin
      select oh.order_number,
             ol.line_number,
             nvl(wth.document_type,'SalesOrder'),
             -- Distributed - TPW Changes
             ol.source_document_type_id,
             ol.source_document_id,
             ol.source_document_line_id
      into   x_document_id,
             x_line_number,
             x_document_type,
             -- Distributed - TPW Changes
             l_source_document_type_id,
             l_source_document_id,
             l_source_document_line_id
      from   oe_order_lines_all ol,
             oe_order_headers_all oh,
             wsh_transactions_history wth
      where ol.line_id = p_src_line_id
      and   ol.header_id = oh.header_id
      and   oh.header_id = wth.entity_number (+)
      and   wth.entity_type(+) = 'ORDER'
      and   wth.document_type(+) = 'SR'
      and   wth.document_direction(+) = 'I'
      and   wth.transaction_status(+) = 'SC'
      and   rownum < 2;

      -- Distributed - TPW Changes
      IF l_source_document_type_id = 10 THEN

        select ph.segment1,
               pl.line_num,
               'InternalRequisition'
        into   x_document_id,
               x_line_number,
               x_document_type
        from   po_requisition_headers_all ph,
               po_requisition_lines_all pl
        where  ph.requisition_header_id = pl.requisition_header_id
        and    pl.requisition_line_id = l_source_document_line_id
        and    ph.requisition_header_id = l_source_document_id;

      END IF;
    exception
      when others then
        null;
    end;

  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'x_shipto_cont_per_name', x_shipto_cont_per_name);
    wsh_debug_sv.log(l_module_name, 'x_shipto_cont_per_ph', x_shipto_cont_per_ph);
    wsh_debug_sv.log(l_module_name, 'x_shipto_cont_per_id', x_shipto_cont_per_id);
    wsh_debug_sv.log(l_module_name, 'x_document_type', x_document_type);
    wsh_debug_sv.log(l_module_name, 'x_document_id', x_document_id);
    wsh_debug_sv.log(l_module_name, 'x_line_number', x_line_number);
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               wsh_util_core.add_message(x_return_status, l_module_name);
                  --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
              END IF;
  WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Get_Delivery_Detail_Info;

  -- R12.1.1 STANDALONE PROJECT
 /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   get_detail_part_addr_info                                |
   |                                                                           |
   | DESCRIPTION     This procedure gets the Address Information               |
   |                 and contact details of the parties.                       |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/09       Leelaraj   Created                                      |
   |                                                                           |
   ============================================================================*/

PROCEDURE get_detail_part_addr_info(
        p_delivery_detail_id    IN         NUMBER,
        p_entity_type           IN         VARCHAR2,
        p_org_id                IN         NUMBER,
        p_partner_type          IN         VARCHAR2,
	x_partner_id		OUT NOCOPY NUMBER,
	x_partner_name		OUT NOCOPY VARCHAR2,
	x_partner_location	OUT NOCOPY VARCHAR2,
	x_duns_number		OUT NOCOPY VARCHAR2,
	x_address_id		OUT NOCOPY NUMBER,
	x_address1		OUT NOCOPY VARCHAR2,
	x_address2		OUT NOCOPY VARCHAR2,
	x_address3		OUT NOCOPY VARCHAR2,
	x_address4		OUT NOCOPY VARCHAR2,
	x_city			OUT NOCOPY VARCHAR2,
	x_country		OUT NOCOPY VARCHAR2,
	x_county		OUT NOCOPY VARCHAR2,
	x_postal_code		OUT NOCOPY VARCHAR2,
	x_region		OUT NOCOPY VARCHAR2,
	x_state			OUT NOCOPY VARCHAR2,
        x_contact_id            OUT NOCOPY NUMBER,
	x_contact_name		OUT NOCOPY VARCHAR2,
	x_contact_telephone	OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2) IS


  CURSOR c_get_lines_in_container_csr IS
      SELECT wda.delivery_detail_id
      FROM  wsh_delivery_assignments_v wda
      START WITH wda.parent_delivery_detail_id  =  p_delivery_detail_id
      CONNECT BY PRIOR  wda.delivery_detail_id =  wda.parent_delivery_detail_id;

  CURSOR c_get_sites_contacts (c_detail_id NUMBER)
  IS
      SELECT ol.ship_to_org_id,
             ol.ship_to_contact_id,
	     ol.deliver_to_org_id,
	     ol.deliver_to_contact_id
      FROM  wsh_delivery_details wdd,
            oe_order_lines_all ol
      WHERE wdd.delivery_detail_id = c_detail_id
      AND   wdd.source_line_id = ol.line_id
      AND   wdd.source_code = 'OE'
      AND   wdd.container_flag = 'N';


  l_ship_to_site_id         NUMBER;
  l_uniq_ship_to_contact_id NUMBER;
  l_curr_ship_to_contact_id NUMBER;
  l_uniq_deliver_to_site_id NUMBER;
  l_curr_deliver_to_site_id NUMBER;
  l_uniq_deliver_to_contact_id NUMBER;
  l_curr_deliver_to_contact_id NUMBER;
  l_delivery_detail_tab     wsh_util_core.id_tab_type;
  l_return_status           VARCHAR2(2);
  l_temp1 BOOLEAN;
  l_temp2 BOOLEAN;
  l_temp3 BOOLEAN;
  l_site_id NUMBER;
  l_contact_id NUMBER;


  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DETAIL_PART_ADDR_INFO';

BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
   wsh_debug_sv.push(l_module_name);
   wsh_debug_sv.log(l_module_name, 'p_delivery_detail_id',p_delivery_detail_id);
   wsh_debug_sv.log(l_module_name, 'p_entity_type',p_entity_type);
   wsh_debug_sv.log(l_module_name, 'p_org_id',p_org_id);
   wsh_debug_sv.log(l_module_name, 'p_partner_type',p_partner_type);
  END IF;

  IF p_partner_type not in ('ShipTo', 'DeliverTo') THEN
    return;
  END IF;

  l_uniq_ship_to_contact_id := null;
  l_uniq_deliver_to_site_id := null;
  l_uniq_deliver_to_contact_id := null;

  IF p_entity_type = 'CONTAINER' THEN --{
    OPEN  c_get_lines_in_container_csr;
    FETCH c_get_lines_in_container_csr BULK COLLECT INTO l_delivery_detail_tab;
    CLOSE c_get_lines_in_container_csr;

    IF l_delivery_detail_tab.count > 0 THEN --{

       l_temp1 := FALSE;
       l_temp2 := FALSE;
       l_temp3 := FALSE;

       FOR k in 1..l_delivery_detail_tab.count LOOP --{
         l_curr_ship_to_contact_id := null;
         l_curr_deliver_to_site_id := null;
         l_curr_deliver_to_contact_id := null;

         OPEN  c_get_sites_contacts (l_delivery_detail_tab(k));
         FETCH c_get_sites_contacts INTO l_ship_to_site_id, l_curr_ship_to_contact_id,
                                         l_curr_deliver_to_site_id, l_curr_deliver_to_contact_id;
         IF c_get_sites_contacts%FOUND THEN --{
            l_uniq_ship_to_contact_id := nvl(l_uniq_ship_to_contact_id,l_curr_ship_to_contact_id);
            l_uniq_deliver_to_site_id := nvl(l_uniq_deliver_to_site_id,l_curr_deliver_to_site_id);
            l_uniq_deliver_to_contact_id := nvl(l_uniq_deliver_to_contact_id,l_curr_deliver_to_contact_id);

            IF (NOT l_temp1) AND  l_curr_ship_to_contact_id IS NOT NULL
               AND  l_uniq_ship_to_contact_id <> l_curr_ship_to_contact_id
            THEN
               l_uniq_ship_to_contact_id := null;
               l_temp1 := TRUE;
            END IF;

            IF  (NOT l_temp2) AND  l_curr_deliver_to_site_id IS NOT NULL THEN
               IF l_uniq_deliver_to_site_id <> l_curr_deliver_to_site_id THEN
                  l_uniq_deliver_to_site_id := null;
                  l_uniq_deliver_to_contact_id := null;
                  l_temp2 := TRUE;
                  l_temp3 := TRUE;
               ELSE
                  IF (NOT l_temp3) AND  l_curr_deliver_to_contact_id IS NOT NULL
                     AND  l_uniq_deliver_to_contact_id <> l_curr_deliver_to_contact_id
                  THEN
                     l_uniq_deliver_to_contact_id := null;
                     l_temp3 := TRUE;
                  END IF;
               END IF;
            END IF;

            IF l_temp1 and l_temp2 and l_temp3 THEN
               CLOSE c_get_sites_contacts;
               EXIT;
            END IF;
         END IF; --}
         CLOSE c_get_sites_contacts;
      END LOOP; --}
    END IF; --}
  END IF; --}

  IF (p_partner_type = 'ShipTo') THEN
    l_site_id := l_ship_to_site_id;
    l_contact_id := l_uniq_ship_to_contact_id;
  ELSIF (p_partner_type = 'DeliverTo') THEN
    l_site_id := l_uniq_deliver_to_site_id;
    l_contact_id := l_uniq_deliver_to_contact_id;
  END IF;

  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'l_site_id', l_site_id);
    wsh_debug_sv.log(l_module_name, 'l_contact_id', l_contact_id);
  END IF;

  IF (l_site_id is not null) THEN
    Get_Cust_addr_Info (
        p_site_id               => l_site_id,
        p_contact_id            => l_contact_id,
        p_org_id                => p_org_id,
  	x_partner_id		=> x_partner_id,
  	x_partner_name		=> x_partner_name,
  	x_partner_location	=> x_partner_location,
  	x_duns_number		=> x_duns_number,
  	x_address_id		=> x_address_id,
  	x_address1		=> x_address1,
  	x_address2		=> x_address2,
  	x_address3		=> x_address3,
  	x_address4		=> x_address4,
  	x_city			=> x_city,
  	x_country		=> x_country,
  	x_county		=> x_county,
  	x_postal_code		=> x_postal_code,
  	x_region		=> x_region,
  	x_state			=> x_state,
  	x_contact_name		=> x_contact_name,
  	x_contact_telephone	=> x_contact_telephone,
  	x_return_status 	=> x_return_status);
    x_contact_id := l_contact_id;
  END IF;

  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               wsh_util_core.add_message(x_return_status, l_module_name);
                  --
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
              END IF;
  WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Get_Detail_Part_addr_Info;

  -- R12.1.1 STANDALONE PROJECT
 /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   Get_Cust_addr_Info                                       |
   |                                                                           |
   | DESCRIPTION     This procedure gets the Ship To Address Information       |
   |                 of the parties.                                           |
   |                 This is a new API created for Standalone Project.         |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/09       Leelaraj   Created                                      |
   |                                                                           |
   ============================================================================*/

PROCEDURE Get_Cust_addr_Info (
        p_site_id               IN         NUMBER,
        p_contact_id            IN         NUMBER,
        p_org_id                IN         NUMBER,
	x_partner_id		OUT NOCOPY NUMBER,
	x_partner_name		OUT NOCOPY VARCHAR2,
	x_partner_location	OUT NOCOPY VARCHAR2,
	x_duns_number		OUT NOCOPY VARCHAR2,
        x_address_id            OUT NOCOPY NUMBER,
	x_address1		OUT NOCOPY VARCHAR2,
	x_address2		OUT NOCOPY VARCHAR2,
	x_address3		OUT NOCOPY VARCHAR2,
	x_address4		OUT NOCOPY VARCHAR2,
	x_city			OUT NOCOPY VARCHAR2,
	x_country		OUT NOCOPY VARCHAR2,
	x_county		OUT NOCOPY VARCHAR2,
	x_postal_code		OUT NOCOPY VARCHAR2,
	x_region		OUT NOCOPY VARCHAR2,
	x_state			OUT NOCOPY VARCHAR2,
	x_contact_name		OUT NOCOPY VARCHAR2,
	x_contact_telephone	OUT NOCOPY VARCHAR2,
	x_return_status 	OUT NOCOPY VARCHAR2) IS

  CURSOR c_party_info_cur(c_site_id NUMBER, c_opunit_id NUMBER DEFAULT NULL) IS
  SELECT
        distinct wclv.customer_id       party_id,
        wclv.customer_name              party_name,
        wclv.location                   partner_location,
        wclv.duns_number                duns_number,
        wclv.site_use_id                address_id,
        wclv.address1                   address1,
        wclv.address2                   address2,
        wclv.address3                   address3,
        wclv.address4                   address4,
        wclv.city                       city,
        wclv.country                    country,
        wclv.county                     county,
        wclv.postal_code                postal_code,
        wclv.province                   region,
        wclv.state                      state
   FROM wsh_customer_locations_v wclv
  WHERE wclv.site_use_id = c_site_id
    AND wclv.org_id = c_opunit_id
    AND wclv.customer_status = 'A'
    AND wclv.cust_acct_site_status = 'A'
    AND wclv.site_use_status = 'A';

  l_return_status VARCHAR2(2);

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CUST_ADDR_INFO';
  --
BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
   wsh_debug_sv.push(l_module_name);
   wsh_debug_sv.log (l_module_name, 'p_site_id', p_site_id);
   wsh_debug_sv.log (l_module_name, 'p_contact_id', p_contact_id);
   wsh_debug_sv.log (l_module_name, 'p_org_id', p_org_id);
  END IF;

  OPEN  c_party_info_cur(p_site_id, p_org_id);
  FETCH c_party_info_cur INTO
                      x_partner_id,
                      x_partner_name,
                      x_partner_location,
                      x_duns_number,
                      x_address_id,
                      x_address1,
                      x_address2,
                      x_address3,
                      x_address4,
                      x_city,
                      x_country,
                      x_county,
                      x_postal_code,
                      x_region,
                      x_state;
  CLOSE c_party_info_cur;

  IF (p_contact_id is not null) THEN
    get_name_number(
                  p_contact_id,
                  x_contact_telephone,
                  x_contact_name,
                  l_return_status
                  );
    IF  l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'x_partner_id', x_partner_id);
    wsh_debug_sv.log(l_module_name, 'x_partner_name', x_partner_name);
    wsh_debug_sv.log(l_module_name, 'x_partner_location', x_partner_location);
    wsh_debug_sv.log(l_module_name, 'x_duns_number', x_duns_number);
    wsh_debug_sv.log(l_module_name, 'x_address_id', x_address_id);
    wsh_debug_sv.log(l_module_name, 'x_address1', x_address1);
    wsh_debug_sv.log(l_module_name, 'x_address2', x_address2);
    wsh_debug_sv.log(l_module_name, 'x_address3', x_address3);
    wsh_debug_sv.log(l_module_name, 'x_address4', x_address4);
    wsh_debug_sv.log(l_module_name, 'x_city', x_city);
    wsh_debug_sv.log(l_module_name, 'x_country', x_country);
    wsh_debug_sv.log(l_module_name, 'x_county', x_county);
    wsh_debug_sv.log(l_module_name, 'x_postal_code', x_postal_code);
    wsh_debug_sv.log(l_module_name, 'x_region', x_region);
    wsh_debug_sv.log(l_module_name, 'x_state', x_state);
    wsh_debug_sv.log(l_module_name, 'x_contact_name', x_contact_name);
    wsh_debug_sv.log(l_module_name, 'x_contact_telephone', x_contact_telephone);
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END Get_Cust_addr_Info;

-- R12.1.1 STANDALONE PROJECT
 /*===========================================================================
   |                                                                           |
   | PROCEDURE NAME   get_detail_part_addr_info                                |
   |                                                                           |
   | DESCRIPTION     This procedure gets the Ship From, Ship To and            |
   |                 Bill To Information of the parties.                       |
   |                 This is a new API created for Standalone Project.         |
   |                                                                           |
   | MODIFICATION HISTORY                                                      |
   |                                                                           |
   |	02/18/09       Leelaraj   Created                                      |
   |                                                                           |
   ============================================================================*/

PROCEDURE Get_Del_Part_Addr_Info(
	p_partner_type		  IN	     VARCHAR2,
	p_delivery_id		  IN	     NUMBER,
	p_org_id		  IN	     NUMBER,
	x_partner_id		  OUT NOCOPY NUMBER,
	x_partner_name		  OUT NOCOPY VARCHAR2,
	x_partner_location	  OUT NOCOPY VARCHAR2,
	x_duns_number		  OUT NOCOPY VARCHAR2,
	x_intmed_ship_to_location OUT NOCOPY VARCHAR2,
	x_pooled_ship_to_location OUT NOCOPY VARCHAR2,
        x_address_id              OUT NOCOPY NUMBER,
	x_address1		  OUT NOCOPY VARCHAR2,
	x_address2		  OUT NOCOPY VARCHAR2,
	x_address3		  OUT NOCOPY VARCHAR2,
	x_address4		  OUT NOCOPY VARCHAR2,
	x_city			  OUT NOCOPY VARCHAR2,
	x_country		  OUT NOCOPY VARCHAR2,
	x_county		  OUT NOCOPY VARCHAR2,
	x_postal_code		  OUT NOCOPY VARCHAR2,
	x_region		  OUT NOCOPY VARCHAR2,
	x_state			  OUT NOCOPY VARCHAR2,
	x_contact_id		  OUT NOCOPY NUMBER,
	x_contact_name		  OUT NOCOPY VARCHAR2,
	x_telephone		  OUT NOCOPY VARCHAR2,
	x_return_status 	  OUT NOCOPY VARCHAR2) IS

  CURSOR c_del_info IS
  SELECT organization_id,
  	 initial_pickup_location_id,
  	 intmed_ship_to_location_id,
  	 pooled_ship_to_location_id
   FROM  wsh_new_deliveries
  WHERE  delivery_id = p_delivery_id;

   CURSOR ship_from_info_cur(c_org_id NUMBER, c_loc_id NUMBER) IS
   SELECT
  	wsfl.organization_name 		party_name,
  	hl.location_code		partner_location,
  	0				duns_number,
  	NULL				intmed_ship_to_location,
  	NULL				pooled_ship_to_location_id,
  	wsfl.address1		        address1,
  	wsfl.address2		        address2,
  	wsfl.address3		        address3,
  	NULL				address4,
  	wsfl.city			city,
  	wsfl.country			country,
  	NULL				county,
  	wsfl.postal_code		postal_code,
  	wsfl.province			region,
  	wsfl.state			state
   FROM wsh_ship_from_org_locations_v wsfl,
        hr_locations_all hl
  WHERE wsfl.wsh_location_id = c_loc_id
    AND wsfl.source_location_id =  hl.location_id;

  CURSOR ship_to_info_cur(c_loc_id NUMBER, c_opUnit_id NUMBER DEFAULT NULL) IS
  SELECT
  	distinct wclv.customer_name	party_name,
  	wclv.location			partner_location,
  	wclv.duns_number		duns_number,
  	wclv.address1			address1,
  	wclv.address2			address2,
  	wclv.address3			address3,
  	wclv.address4			address4,
  	wclv.city			city,
  	wclv.country			country,
  	wclv.county			county,
  	wclv.postal_code		postal_code,
  	wclv.province			region,
  	wclv.state			state
   FROM wsh_customer_locations_v wclv
  WHERE wclv.wsh_location_id = c_loc_id
    AND wclv.org_id = nvl(c_opUnit_id, wclv.org_id)
    AND wclv.customer_status = 'A'
    AND wclv.cust_acct_site_status = 'A'
    AND wclv.site_use_status = 'A'
    AND wclv.site_use_code = 'SHIP_TO';

   CURSOR c_del_sites IS
   SELECT ol.ship_to_org_id,
          ol.invoice_to_org_id
   FROM   wsh_new_deliveries wnd,
          wsh_delivery_assignments_v wda,
          wsh_delivery_details wdd,
          oe_order_lines_all ol
  WHERE   wnd.delivery_id = p_delivery_id
  AND     wnd.delivery_id = wda.delivery_id
  AND     wda.delivery_detail_id = wdd.delivery_detail_id
  AND     wdd.source_code = 'OE'
  AND     wdd.source_line_id = ol.line_id
  AND     rownum < 2;

  CURSOR c_party_info_cur(c_site_id NUMBER, c_opunit_id NUMBER DEFAULT NULL) IS
  SELECT
         DISTINCT wclv.customer_id       party_id,
          wclv.customer_name              party_name,
          wclv.location                   partner_location,
          wclv.duns_number                duns_number,
          wclv.site_use_id                address_id,
          wclv.address1                   address1,
          wclv.address2                   address2,
          wclv.address3                   address3,
          wclv.address4                   address4,
          wclv.city                       city,
          wclv.country                    country,
          wclv.county                     county,
          wclv.postal_code                postal_code,
          wclv.province                   region,
          wclv.state                      state
     FROM wsh_customer_locations_v wclv
    WHERE wclv.site_use_id = c_site_id
      AND wclv.org_id = c_opunit_id
      AND wclv.customer_status = 'A'
      AND wclv.cust_acct_site_status = 'A'
      AND wclv.site_use_status = 'A';

  l_organization_id NUMBER;
  l_init_loc_id	NUMBER;
  l_ult_loc_id	NUMBER;
  l_intmed_loc_id NUMBER;
  l_pooled_loc_id NUMBER;
  l_ship_to_site_id NUMBER;
  l_ship_to_contact_id NUMBER;
  l_bill_to_site_id NUMBER;
  l_bill_to_contact_id NUMBER;
  l_return_status	VARCHAR2(30);
  l_dummy	VARCHAR2(360);
  --

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DEL_PART_ADDR_INFO';
  --
BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
   wsh_debug_sv.push(l_module_name);
   wsh_debug_sv.log (l_module_name, 'Partner Type', p_partner_type);
   wsh_debug_sv.log (l_module_name, 'Delivery Id', p_delivery_id);
   wsh_debug_sv.log (l_module_name, 'Org Id', p_org_id);
  END IF;

  OPEN  c_del_info;
  FETCH c_del_info INTO	l_organization_id, l_init_loc_id, l_intmed_loc_id, l_pooled_loc_id;
  CLOSE c_del_info;

  IF l_debug_on THEN
    wsh_debug_sv.log (l_module_name, 'Initial Pickup Location Id', l_init_loc_id);
    wsh_debug_sv.log (l_module_name, 'Intmed ShipTo Location Id', l_intmed_loc_id);
    wsh_debug_sv.log (l_module_name, 'Pooled ShipTo Location Id', l_pooled_loc_id);
  END IF;

  IF (p_partner_type = 'ShipFrom') THEN --{
     OPEN ship_from_info_cur(l_organization_id, l_init_loc_id);
     FETCH ship_from_info_cur INTO
			x_partner_name,
			x_partner_location,
			x_duns_number,
			x_intmed_ship_to_location,
			x_pooled_ship_to_location,
			x_address1,
			x_address2,
			x_address3,
			x_address4,
			x_city,
			x_country,
			x_county,
			x_postal_code,
			x_region,
			x_state;
     CLOSE ship_from_info_cur;
     x_partner_id := l_organization_id;

  ELSIF(p_partner_type = 'ShipTo') THEN

    OPEN  c_del_sites;
    FETCH c_del_sites INTO l_ship_to_site_id, l_bill_to_site_id;
    CLOSE c_del_sites;

    OPEN  c_party_info_cur(l_ship_to_site_id, p_org_id);
    FETCH c_party_info_cur INTO
                        x_partner_id,
                        x_partner_name,
			x_partner_location,
			x_duns_number,
                        x_address_id,
			x_address1,
			x_address2,
			x_address3,
			x_address4,
			x_city,
			x_country,
			x_county,
			x_postal_code,
			x_region,
			x_state;
    CLOSE c_party_info_cur;

    OPEN ship_to_info_cur(l_intmed_loc_id);
    FETCH ship_to_info_cur INTO l_dummy,
             		x_intmed_ship_to_location,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy;
     CLOSE ship_to_info_cur;

     OPEN ship_to_info_cur(l_pooled_loc_id);
     FETCH ship_to_info_cur INTO l_dummy,
			x_pooled_ship_to_location,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy,
			l_dummy;
     CLOSE ship_to_info_cur;

     BEGIN
       select distinct ol.ship_to_contact_id
       into   l_ship_to_contact_id
       from   wsh_new_deliveries wnd,
              wsh_delivery_assignments_v wda,
              wsh_delivery_details wdd,
              oe_order_lines_all ol
       where  wnd.delivery_id = p_delivery_id
       and    wnd.delivery_id = wda.delivery_id
       and    wda.delivery_detail_id = wdd.delivery_detail_id
       and    wdd.source_code = 'OE'
       and    wdd.source_line_id = ol.line_id;
     EXCEPTION
       when others then
         l_ship_to_contact_id := null;
     END;

     IF (l_ship_to_contact_id is not null) THEN
       x_contact_id := l_ship_to_contact_id;
       get_name_number(
                     l_ship_to_contact_id,
                     x_telephone,
                     x_contact_name,
                     l_return_status
                     );
       IF  l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name, 'x_telephone,x_contact_name', x_telephone||','||x_contact_name);
       wsh_debug_sv.log (l_module_name, 'l_return_status', l_return_status);
     END IF;

  ELSIF(p_partner_type = 'BillTo') THEN

    OPEN  c_del_sites;
    FETCH c_del_sites INTO l_ship_to_site_id, l_bill_to_site_id;
    CLOSE c_del_sites;

    OPEN  c_party_info_cur(l_bill_to_site_id, p_org_id);
    FETCH c_party_info_cur INTO
                          x_partner_id,
                          x_partner_name,
                          x_partner_location,
                          x_duns_number,
                          x_address_id,
                          x_address1,
                          x_address2,
                          x_address3,
                          x_address4,
                          x_city,
                          x_country,
                          x_county,
                          x_postal_code,
                          x_region,
                          x_state;
    CLOSE c_party_info_cur;

    BEGIN
      select distinct ol.invoice_to_contact_id
      into   l_bill_to_contact_id
      from   wsh_new_deliveries wnd,
             wsh_delivery_assignments_v wda,
             wsh_delivery_details wdd,
             oe_order_lines_all ol
      where  wnd.delivery_id = p_delivery_id
      and    wnd.delivery_id = wda.delivery_id
      and    wda.delivery_detail_id = wdd.delivery_detail_id
      and    wdd.source_code = 'OE'
      and    wdd.source_line_id = ol.line_id;
    EXCEPTION
      when others then
        l_bill_to_contact_id := null;
    END;

    IF (l_bill_to_contact_id is not null) THEN
      x_contact_id := l_bill_to_contact_id;
      get_name_number(
                     l_bill_to_contact_id,
                     x_telephone,
                     x_contact_name,
                     l_return_status
                     );
      IF  l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF; --}

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'x_telephone,x_contact_name', x_telephone||','||x_contact_name);
      wsh_debug_sv.log (l_module_name, 'l_return_status', l_return_status);
    END IF;

  END IF;

  IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END get_del_part_addr_info;

-- TPW - Distributed Organization Changes
PROCEDURE get_name_number(
                     p_contact_id           IN NUMBER,
                     x_per_ph_number        OUT NOCOPY VARCHAR2,
                     x_contact_person_name  OUT NOCOPY VARCHAR2,
                     x_return_status        OUT NOCOPY VARCHAR2
                     )
IS
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                            || 'GET_NAME_NUMBER';
   l_per_first_name                     HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
   l_per_middle_name                    HZ_PARTIES.PERSON_MIDDLE_NAME%TYPE;
   l_per_last_name                      HZ_PARTIES.PERSON_LAST_NAME%TYPE;
   l_owner_table_id                     NUMBER;

      cursor l_ship_to_site_contact_csr(p_contact_id IN NUMBER) is
      SELECT PER_CONTACT.PERSON_FIRST_NAME,
             PER_CONTACT.PERSON_MIDDLE_NAME,
             PER_CONTACT.PERSON_LAST_NAME,
             PHONE_CONTACT.RAW_PHONE_NUMBER,
             HREL.PARTY_ID
      from   HZ_CUST_ACCOUNT_ROLES HCAR,
             HZ_RELATIONSHIPS HREL,
             HZ_ORG_CONTACTS HOC,
             HZ_CONTACT_POINTS   PHONE_CONTACT,
             HZ_PARTIES PER_CONTACT
      WHERE  HCAR.CUST_ACCOUNT_ROLE_ID           = p_contact_id
      AND    HREL.PARTY_ID                       = HCAR.PARTY_ID
      AND    HCAR.ROLE_TYPE                      = 'CONTACT'
      AND    HREL.RELATIONSHIP_ID                = HOC.PARTY_RELATIONSHIP_ID
      AND    HREL.SUBJECT_TABLE_NAME             = 'HZ_PARTIES'
      AND    HREL.OBJECT_TABLE_NAME              = 'HZ_PARTIES'
      AND    HREL.SUBJECT_TYPE                   = 'PERSON'
      AND    HREL.DIRECTIONAL_FLAG               = 'F'
      AND    HREL.SUBJECT_ID                     = PER_CONTACT.PARTY_ID
      AND    PHONE_CONTACT.OWNER_TABLE_NAME(+)   = 'HZ_PARTIES'
      AND    PHONE_CONTACT.OWNER_TABLE_ID(+)     = HREL.PARTY_ID
      AND    PHONE_CONTACT.CONTACT_POINT_TYPE(+) = 'PHONE'
      AND    PHONE_CONTACT.PHONE_LINE_TYPE(+)    = 'GEN'
      AND    PHONE_CONTACT.PRIMARY_FLAG(+)       = 'Y';

      cursor l_ship_to_site_ph_csr(p_owner_tbl_id IN NUMBER) is
      SELECT RAW_PHONE_NUMBER
      FROM   HZ_CONTACT_POINTS
      WHERE  OWNER_TABLE_NAME    = 'HZ_PARTIES'
      AND    OWNER_TABLE_ID     = p_owner_tbl_id
      AND    CONTACT_POINT_TYPE = 'PHONE'
      AND    PHONE_LINE_TYPE    = 'GEN';

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log (l_module_name, 'p_contact_id', p_contact_id);
   END IF;

   open  l_ship_to_site_contact_csr(p_contact_id);
   fetch l_ship_to_site_contact_csr into l_per_first_name,
                                                l_per_middle_name,
                                                l_per_last_name,
                                                x_per_ph_number,
                                                l_owner_table_id;
   close l_ship_to_site_contact_csr;

   IF l_per_first_name IS NOT NULL THEN
   --{
       x_contact_person_name := l_per_first_name || ' ';
   --}
   END IF;

   IF l_per_middle_name IS NOT NULL THEN
   --{
       x_contact_person_name := x_contact_person_name || l_per_middle_name || ' ';
   --}
   END IF;

   IF l_per_last_name IS NOT NULL THEN
          --{
              x_contact_person_name := x_contact_person_name || l_per_last_name;          --}
   END IF;
   IF l_debug_on THEN
       WSH_DEBUG_SV.log (L_MODULE_NAME,' Contact Person Phone Number ',
                                                               x_per_ph_number);
       WSH_DEBUG_SV.log (L_MODULE_NAME,' l_owner_table_id ',
                                                        l_owner_table_id);
   END IF;

   IF x_per_ph_number IS NULL
             AND l_owner_table_id IS NOT NULL
   THEN
   --{
      open l_ship_to_site_ph_csr(l_owner_table_id);
      fetch l_ship_to_site_ph_csr into x_per_ph_number;
      close l_ship_to_site_ph_csr;
   --}
   END IF;


   IF l_debug_on THEN
     wsh_debug_sv.log (l_module_name, 'x_per_ph_number', x_per_ph_number);
     wsh_debug_sv.log (l_module_name, 'x_contact_person_name', x_contact_person_name);
     wsh_debug_sv.log (l_module_name, 'x_return_status', x_return_status);
     wsh_debug_sv.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
END get_name_number;

PROCEDURE get_ship_method_details(
          p_ship_method_code  IN VARCHAR2,
          x_carrier_code      OUT NOCOPY VARCHAR2,
          x_service_level     OUT NOCOPY VARCHAR2,
          x_mode_of_transport OUT NOCOPY VARCHAR2,
          x_return_status     OUT NOCOPY VARCHAR2 )
IS
   --
   l_debug_on               BOOLEAN;
   l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Ship_Method_Details';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_ship_method_code', p_ship_method_code);
   END IF;
   --
   x_return_status     := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   select wc.freight_code, wcs.service_level, wcs.mode_of_transport
   into   x_carrier_code, x_service_level, x_mode_of_transport
   from   wsh_carrier_services wcs,
          wsh_carriers wc
   where  wc.carrier_id = wcs.carrier_id
   and    wcs.ship_method_code = p_ship_method_code;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Get_Ship_Method_Details;

PROCEDURE get_batch_addr_info (
          p_partner_type  IN  VARCHAR2,
          p_batch_id      IN  NUMBER,
          x_partner_id    OUT NOCOPY NUMBER,
          x_partner_name  OUT NOCOPY VARCHAR2,
          x_address_id    OUT NOCOPY NUMBER,
          x_address1      OUT NOCOPY VARCHAR2,
          x_address2      OUT NOCOPY VARCHAR2,
          x_address3      OUT NOCOPY VARCHAR2,
          x_address4      OUT NOCOPY VARCHAR2,
          x_city          OUT NOCOPY VARCHAR2,
          x_country       OUT NOCOPY VARCHAR2,
          x_county        OUT NOCOPY VARCHAR2,
          x_postal_code   OUT NOCOPY VARCHAR2,
          x_region        OUT NOCOPY VARCHAR2,
          x_state         OUT NOCOPY VARCHAR2,
          x_contact_id    OUT NOCOPY NUMBER,
          x_contact_name  OUT NOCOPY VARCHAR2,
          x_telephone     OUT NOCOPY VARCHAR2,
          x_return_status OUT NOCOPY VARCHAR2 )
IS

   CURSOR c_ship_from_location(c_organization_id IN NUMBER, c_loc_id IN NUMBER)
   IS
   select organization_id,
          organization_name,
          wsh_location_id,
          address1,
          address2,
          address3,
          address4,
          city,
          country,
          county,
          postal_code,
          province,
          state
   from   wsh_ship_from_org_locations_v
   where  wsh_location_id = c_loc_id
   and    organization_id = c_organization_id;

   CURSOR c_cust_name(c_customer_id IN NUMBER)
   IS
   SELECT HP.PARTY_NAME
   FROM   HZ_PARTIES HP,
          HZ_CUST_ACCOUNTS HCA
   WHERE  HP.PARTY_ID = HCA.PARTY_ID
   AND    HCA.CUST_ACCOUNT_ID = c_customer_id;

   CURSOR c_cust_site_location(c_site_use_id IN NUMBER)
   IS
   select customer_id,
          customer_name,
          site_use_id,
          address1,
          address2,
          address3,
          address4,
          city,
          country,
          county,
          postal_code,
          province,
          state
   from   wsh_customer_locations_v
   where  site_use_id = c_site_use_id;

   l_organization_id        number;
   l_ship_from_location_id  number;
   l_customer_id            number;
   l_ship_to_site_use_id    number;
   l_ship_to_contact_id     number;
   l_invoice_to_site_use_id number;
   l_invoice_to_contact_id  number;
   l_deliver_to_site_use_id number;
   l_deliver_to_contact_id  number;
   l_return_status          VARCHAR2(1);

   --
   l_debug_on               BOOLEAN;
   l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Batch_Addr_Info';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_partner_type', p_partner_type);
      WSH_DEBUG_SV.log(l_module_name, 'p_batch_id', p_batch_id);
   END IF;
   --
   x_return_status     := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   select organization_id, ship_from_location_id, customer_id,
          ship_to_site_use_id, ship_to_contact_id,
          invoice_to_site_use_id, invoice_to_contact_id,
          deliver_to_site_use_id, deliver_to_contact_id
   into  l_organization_id, l_ship_from_location_id, l_customer_id,
         l_ship_to_site_use_id, l_ship_to_contact_id,
         l_invoice_to_site_use_id, l_invoice_to_contact_id,
         l_deliver_to_site_use_id, l_deliver_to_contact_id
   from  wsh_shipment_batches
   where batch_id = p_batch_id;

   IF p_partner_type = 'ShipFrom' THEN
      OPEN  c_ship_from_location(l_organization_id, l_ship_from_location_id);
      FETCH c_ship_from_location INTO
            x_partner_id,
            x_partner_name,
            x_address_id,
            x_address1,
            x_address2,
            x_address3,
            x_address4,
            x_city,
            x_country,
            x_county,
            x_postal_code,
            x_region,
            x_state;
      CLOSE c_ship_from_location;
   ELSIF p_partner_type = 'SoldTo' THEN
      OPEN  c_cust_name (l_customer_id);
      FETCH c_cust_name INTO x_partner_name;
      CLOSE c_cust_name;
      x_partner_id := l_customer_id;
   ELSIF p_partner_type = 'ShipTo' THEN
      OPEN  c_cust_site_location(l_ship_to_site_use_id);
      FETCH c_cust_site_location INTO
            x_partner_id,
            x_partner_name,
            x_address_id,
            x_address1,
            x_address2,
            x_address3,
            x_address4,
            x_city,
            x_country,
            x_county,
            x_postal_code,
            x_region,
            x_state;
      CLOSE c_cust_site_location;

      IF l_ship_to_contact_id is not null THEN
         x_contact_id := l_ship_to_contact_id;
         get_name_number(
                     p_contact_id              => l_ship_to_contact_id,
                     x_per_ph_number           => x_telephone,
                     x_contact_person_name     => x_contact_name,
                     x_return_status           => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   ELSIF p_partner_type = 'BillTo' THEN
      OPEN  c_cust_site_location(l_invoice_to_site_use_id);
      FETCH c_cust_site_location INTO
            x_partner_id,
            x_partner_name,
            x_address_id,
            x_address1,
            x_address2,
            x_address3,
            x_address4,
            x_city,
            x_country,
            x_county,
            x_postal_code,
            x_region,
            x_state;
      CLOSE c_cust_site_location;

      IF l_invoice_to_contact_id is not null THEN
         x_contact_id := l_invoice_to_contact_id;
         get_name_number(
                     p_contact_id              => l_invoice_to_contact_id,
                     x_per_ph_number           => x_telephone,
                     x_contact_person_name     => x_contact_name,
                     x_return_status           => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   ELSIF p_partner_type = 'DeliverTo' THEN
      OPEN  c_cust_site_location(l_deliver_to_site_use_id);
      FETCH c_cust_site_location INTO
            x_partner_id,
            x_partner_name,
            x_address_id,
            x_address1,
            x_address2,
            x_address3,
            x_address4,
            x_city,
            x_country,
            x_county,
            x_postal_code,
            x_region,
            x_state;
      CLOSE c_cust_site_location;

      IF l_deliver_to_contact_id is not null THEN
         x_contact_id := l_deliver_to_contact_id;
         get_name_number(
                     p_contact_id              => l_deliver_to_contact_id,
                     x_per_ph_number           => x_telephone,
                     x_contact_person_name     => x_contact_name,
                     x_return_status           => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;

   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Get_Batch_Addr_Info;


PROCEDURE get_detail_line_info (
          p_reference_line_id      IN NUMBER,
          x_line_number            OUT NOCOPY NUMBER,
          x_line_quantity          OUT NOCOPY VARCHAR2,
          x_line_quantity_uom      OUT NOCOPY VARCHAR2,
          x_item_number            OUT NOCOPY VARCHAR2,
          x_item_description       OUT NOCOPY VARCHAR2,
          x_unit_selling_price     OUT NOCOPY NUMBER,
          x_packing_instructions   OUT NOCOPY VARCHAR2,
          x_shipping_instructions  OUT NOCOPY VARCHAR2,
          x_request_date           OUT NOCOPY DATE,
          x_schedule_date          OUT NOCOPY DATE,
          x_shipment_priority_code OUT NOCOPY VARCHAR2,
          x_ship_tolerance_above   OUT NOCOPY NUMBER,
          x_ship_tolerance_below   OUT NOCOPY NUMBER,
          x_set_name               OUT NOCOPY VARCHAR2,
          x_customer_item_number   OUT NOCOPY VARCHAR2,
          x_cust_po_number         OUT NOCOPY VARCHAR2,
          x_subinventory           OUT NOCOPY VARCHAR2,
          x_return_status          OUT NOCOPY VARCHAR2) IS

   l_return_status          VARCHAR2(1);
   l_line_set_id            NUMBER;
   -- Bug 9234726: Added variables.
   l_req_qty_uom            VARCHAR2(3);
   l_inv_item_id            NUMBER;

   --
   l_debug_on               BOOLEAN;
   l_module_name CONSTANT   VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Detail_Line_Info';
   --
BEGIN
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_reference_line_id', p_reference_line_id);
   END IF;
   --
   x_return_status     := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   select order_quantity_uom,
          ol.line_number,
          msik.concatenated_segments,
          msik.description,
          ol.unit_selling_price,
          ol.packing_instructions,
          ol.shipping_instructions,
          ol.request_date,
          ol.schedule_ship_date,
          ol.shipment_priority_code,
          ol.ship_tolerance_above,
          ol.ship_tolerance_below,
          set_name,
          customer_item_number,
          ol.cust_po_number,
          ol.subinventory,
          ol.ordered_quantity,
          ol.line_set_id,
          -- Bug 9234726: Querying Item Id and Item's Primary UOM
          msik.primary_uom_code,
          ol.inventory_item_id
   into   x_line_quantity_uom,
          x_line_number,
          x_item_number,
          x_item_description,
          x_unit_selling_price,
          x_packing_instructions,
          x_shipping_instructions,
          x_request_date,
          x_schedule_date,
          x_shipment_priority_code,
          x_ship_tolerance_above,
          x_ship_tolerance_below,
          x_set_name,
          x_customer_item_number,
          x_cust_po_number,
          x_subinventory,
          x_line_quantity,
          l_line_set_id,
          l_req_qty_uom,
          l_inv_item_id
   from   oe_order_lines_all ol,
          mtl_system_items_kfv msik,
          oe_sets,
          mtl_customer_items
   where  ol.line_id = p_reference_line_id
   and    ol.inventory_item_id = msik.inventory_item_id
   and    ol.ship_from_org_id = msik.organization_id
   and    ol.ship_set_id = set_id (+)
   and    decode(ol.item_type_code, 'CUST', ol.ordered_item_id, null) = customer_item_id (+);

   if (l_line_set_id is not null) then
     select sum(ol1.ordered_quantity)
     into   x_line_quantity
     from   oe_order_lines_all ol1
     where  ol1.line_set_id = l_line_set_id;
   end if;

   -- Bug 9234726: If Ordered UOM is different from Item's Primary UOM then
   -- calculate Unit Selling Price based on Item's Primary UOM.
   if ( x_line_quantity_uom <> l_req_qty_uom ) then
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Converting Unit Selling Price based on Primary UOM of Inventory Item');
      END IF;
      --
      x_unit_selling_price := ROUND(x_unit_selling_price * WSH_WV_UTILS.CONVERT_UOM(l_req_qty_uom, x_line_quantity_uom, 1, l_inv_item_id),2);
   end if;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'x_line_quantity '||x_line_quantity||' x_line_quantity_uom '||x_line_quantity_uom);
      WSH_DEBUG_SV.log(l_module_name, 'Return Status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END get_detail_line_info;

END WSH_MAPPING_DATA;

/
