--------------------------------------------------------
--  DDL for Package Body FTE_TENDER_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TENDER_WF" AS
/* $Header: FTETEWFB.pls 120.11 2006/06/12 23:29:04 nltan noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_TENDER_WF';


PROCEDURE GET_DOCK_CLOSE_DATE (p_loc_id          IN NUMBER,
	                       p_tender_date     IN DATE,
                               x_dock_close_date OUT NOCOPY DATE,
                               x_return_status   OUT NOCOPY VARCHAR2) IS
l_from_time       NUMBER;
l_to_time         NUMBER;
l_dock_close_date DATE;
l_dock_close_dt   VARCHAR2(100);
l_hrs             NUMBER;
l_minutes         NUMBER;
l_seconds         NUMBER;
l_return_status   VARCHAR2(1);
l_date DATE;
l_location_id NUMBER;

BEGIN

	-- Standard Start of API savepoint
	SAVEPOINT   GET_DOCK_CLOSE_DATE_PUB;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_location_id :=  p_loc_id;
	l_date        :=  p_tender_date;

	WSH_CALENDAR_ACTIONS.Get_Shift_Times
	                 (p_location_id   => l_location_id,
                          p_date          => l_date,
                          x_from_time     => l_from_time,
                          x_to_time       => l_to_time,
                          x_return_status => l_return_status);
	x_dock_close_date := null;

	if ( l_to_time is not null and l_from_time is not null) then
		IF l_to_time <= l_from_time THEN
		   l_dock_close_date := p_tender_date + 1;
		ELSE
		   l_dock_close_date := p_tender_date;
		END IF;


		l_hrs     :=  floor(l_to_time/3600);
		l_minutes :=  floor((l_to_time - (l_hrs * 3600))/60);
		l_seconds :=  mod(l_to_time,60);

		l_dock_close_dt   := to_char(l_dock_close_date,'dd-mm-yyyy')||':'||to_char(l_hrs)||':'||to_char(l_minutes)||':'||to_char(l_seconds);
		x_dock_close_date := to_date(l_dock_close_dt,'dd-mm-yyyy:hh24:mi:ss');
	End if ;

  EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO GET_DOCK_CLOSE_DATE_PUB;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END GET_DOCK_CLOSE_DATE;







PROCEDURE   VALIDATE_XML_INFO(
			p_tender_number		IN		NUMBER,
			p_tender_status		IN		VARCHAR2,
			p_wf_item_key		IN		VARCHAR2,
			p_shipment_status_id	IN		NUMBER,
			x_return_status         OUT NOCOPY      VARCHAR2) IS

CURSOR c_tender_check (p_tender_id NUMBER)
IS
SELECT trip_id,wf_item_key
FROM   wsh_trips
WHERE load_tender_number = p_tender_id;

l_trip_id   NUMBER;
l_item_key  VARCHAR2(240);
l_msg_data  VARCHAR2(32000);
l_msg_count NUMBER;
l_return_status VARCHAR2(1);

BEGIN

	-- Standard Start of API savepoint
	SAVEPOINT   VALIDATE_XML_INFO_PUB;


        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_msg_count := 0;
	l_msg_data := '';




---------------------------------------------
-- Check for Load Tender Number and Item Key
---------------------------------------------
	OPEN c_tender_check(P_TENDER_NUMBER);
	FETCH c_tender_check into l_trip_id , l_item_key;

	IF c_tender_check%NOTFOUND THEN

  	      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

	      FTE_FPA_UTIL.LOG_FAILURE_REASON(
					p_init_msg_list  => FND_API.G_FALSE,
					p_parent_name    => 'FTE_SHIPMENT_STATUS_HEADERS',
					p_parent_id	 => P_SHIPMENT_STATUS_ID,
					p_failure_type	 => 'FTE_TENDER_XML_FAILURE',
					p_failure_reason => 'FTE_XML_INVALID_TENDER',
					x_return_status  =>  l_return_status,
					x_msg_count      =>  l_msg_count,
					x_msg_data       =>  l_msg_data);


	 ELSE

	      IF nvl(l_item_key,'-11') <>  nvl(P_WF_ITEM_KEY,'-12') THEN

	          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

		  FTE_FPA_UTIL.LOG_FAILURE_REASON(
					p_init_msg_list  => FND_API.G_FALSE,
					p_parent_name    => 'FTE_SHIPMENT_STATUS_HEADERS',
					p_parent_id	 => P_SHIPMENT_STATUS_ID,
					p_failure_type	 => 'FTE_TENDER_XML_FAILURE',
					p_failure_reason => 'FTE_XML_OLD_MESSAGE',
					x_return_status  =>  l_return_status,
					x_msg_count      =>  l_msg_count,
					x_msg_data       =>  l_msg_data);


		END IF;

	 END IF;

	CLOSE c_tender_check;

	IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	    RETURN;
        END IF;


---------------------------------------------
-- Check for Load Tender Status
---------------------------------------------
	IF P_TENDER_STATUS NOT IN (FTE_TENDER_PVT.S_ACCEPTED,FTE_TENDER_PVT.S_REJECTED) THEN

		  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

		  FTE_FPA_UTIL.LOG_FAILURE_REASON(
					p_init_msg_list  => FND_API.G_FALSE,
					p_parent_name    => 'FTE_SHIPMENT_STATUS_HEADERS',
					p_parent_id	 => P_SHIPMENT_STATUS_ID,
					p_failure_type	 => 'FTE_TENDER_XML_FAILURE',
					p_failure_reason => 'FTE_XML_INVALID_TENDER_STATUS',
					x_return_status  =>  l_return_status,
					x_msg_count      =>  l_msg_count,
					x_msg_data       =>  l_msg_data);

	END IF;

		-- Standard call to get message count and if count is 1,get message info.
	--
	  FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  l_msg_count,
	    p_data  =>  l_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );

--}
EXCEPTION
	--{
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO VALIDATE_XML_INFO_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => l_msg_count,
		     p_data  =>  l_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO VALIDATE_XML_INFO_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => l_msg_count,
		     p_data  =>  l_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN OTHERS THEN
		ROLLBACK TO VALIDATE_XML_INFO_PUB;
		wsh_util_core.default_handler('FTE_TENDER_WF.VALIDATE_XML_INFO_PUB');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => l_msg_count,
		     p_data  =>  l_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	--}


END VALIDATE_XML_INFO;

PROCEDURE   GET_ITEM_INFO(
			P_ITEM_TYPE		IN		VARCHAR2,
			P_ITEM_KEY		IN		VARCHAR2,
			X_SHIPPER_NAME		OUT  NOCOPY	VARCHAR2,
			X_TENDERED_DATE		OUT  NOCOPY	DATE,
			X_RESPOND_BY_DATE	OUT  NOCOPY	DATE,
			X_VEHICLE_TYPE		OUT  NOCOPY 	VARCHAR2,
			X_VEHICLE_CLASS		OUT  NOCOPY 	VARCHAR2 ) IS

BEGIN


      X_SHIPPER_NAME     := wf_engine.GetItemAttrText(P_ITEM_TYPE,P_ITEM_KEY,'SHIPPER_NAME');

      X_TENDERED_DATE    := wf_engine.GetItemAttrDate(P_ITEM_TYPE,P_ITEM_KEY,'TENDERED_DATE');

      X_RESPOND_BY_DATE  := wf_engine.GetItemAttrDate(P_ITEM_TYPE,P_ITEM_KEY,'RESPOND_BY_DATE');

      X_VEHICLE_TYPE     := wf_engine.GetItemAttrText(P_ITEM_TYPE,P_ITEM_KEY,'VEHICLE_TYPE');

      X_VEHICLE_CLASS    := wf_engine.GetItemAttrText(P_ITEM_TYPE,P_ITEM_KEY,'VEHICLE_CLASS');



END GET_ITEM_INFO;



PROCEDURE GET_SERVICE_VEHICLE_INFO(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_tender_id		  IN	 NUMBER,
	        	x_vehicle_type            OUT	NOCOPY VARCHAR2,
	        	x_vehicle_class           OUT   NOCOPY VARCHAR2,
	        	x_service_level           OUT   NOCOPY VARCHAR2) IS

  CURSOR c_vehicle_info(p_tender_id NUMBER) is
        select
               msi.segment1 vehicle_type,
               flvv.meaning vehicle_class
         from  wsh_trips wts,
               mtl_system_items msi,
               fnd_lookup_values_vl flvv,
               fte_vehicle_types fvt
         where
                fvt.inventory_item_id    = wts.vehicle_item_id
            and fvt.organization_id      = wts.vehicle_organization_id
            and wts.vehicle_item_id      = msi.inventory_item_id
            and fvt.vehicle_class_code   = flvv.lookup_code(+)
            and flvv.lookup_type(+)      = 'FTE_VEHICLE_CLASS'
            and wts.vehicle_organization_id = msi.organization_id
            and wts.load_tender_number = p_tender_id;

  CURSOR c_service_info(p_tender_id NUMBER) is
           select
               wl.meaning service_level
  	   from
                 wsh_trips wts,
	         wsh_lookups wl
	   where
		wts.service_level =  wl.lookup_code(+)
            and wl.lookup_type(+) = 'WSH_SERVICE_LEVELS'
            and wts.load_tender_number = p_tender_id;

BEGIN

        OPEN   c_vehicle_info(p_tender_id);
	FETCH  c_vehicle_info into x_vehicle_type,x_vehicle_class;
        CLOSE  c_vehicle_info;

	OPEN   c_service_info(p_tender_id);
        FETCH  c_service_info into x_service_level;
	CLOSE  c_service_info;


END GET_SERVICE_VEHICLE_INFO;

PROCEDURE GET_MBOL_NUMBER(
			p_init_msg_list           IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_tender_id		  IN	NUMBER,
			p_generate_mbol           IN    BOOLEAN,
	        	x_mbol_number             OUT	NOCOPY VARCHAR2) IS

CURSOR c_mode_of_transport(p_tender_id NUMBER) is
       SELECT mode_of_transport,trip_id
       from   wsh_trips
       where  load_tender_number = p_tender_id;

CURSOR c_mbol_info(p_trip_id NUMBER) is
       select sequence_number
       from wsh_document_instances
       where
	    entity_id  = p_trip_id
       and  entity_name = 'WSH_TRIPS'
       and  document_type = 'MBOL';

l_mode_of_transport  VARCHAR2(60);
l_trip_id            NUMBER;
l_mbol_number        VARCHAR2(100);
l_return_status      VARCHAR2(1000);


l_generate_mbol	     BOOLEAN := FALSE;

BEGIN


      OPEN  c_mode_of_transport(p_tender_id);
      FETCH c_mode_of_transport into l_mode_of_transport,l_trip_id;
      CLOSE c_mode_of_transport;

	IF l_mode_of_transport = 'TRUCK' THEN

		IF (p_generate_mbol = TRUE) THEN

		        WSH_MBOLS_PVT.Generate_MBOL(p_trip_id =>  l_trip_id,
       	                                    x_sequence_number =>  l_mbol_number,
			                    x_return_status   =>  l_return_status);

			IF ( (l_return_status = 'E') OR   (l_return_status = 'U') )
			THEN

			   wf_core.TOKEN('ERROR_STRING','Error in MBOL Generation ');
                  	   wf_core.RAISE('FTE_WF_ERROR_MESSAGE');

			END IF;


		ELSE
			OPEN  c_mbol_info(l_trip_id);
			FETCH c_mbol_info into l_mbol_number;
		        CLOSE c_mbol_info;

		END IF;

		x_mbol_number := l_mbol_number;

	END IF;

END GET_MBOL_NUMBER;


-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                INITIALIZE_TENDER_REQUEST                                  --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR					   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure will initialize the attributes to initialize--
--			Load Tendering Process.
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002		11.5.8  HBHAGAVA           Created                                 --
-- 2003		11.5.9  SAMUTHUK           Modified				   --
-- ------------------------------------------------------------------------------- --

PROCEDURE INITIALIZE_TENDER_REQUEST(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS




l_result_code	VARCHAR2(10);
l_tender_id 	NUMBER;
l_trip_id	NUMBER;
l_api_name	VARCHAR2(30) := 'INITIALIZE_TENDER_REQUEST';


l_return_status	VARCHAR2(30000);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_msg_string	VARCHAR2(30000);


-- Local Variables
l_trip_name		VARCHAR2(32767);
l_wait_time_uom		VARCHAR2(32767);
l_carrier_id		NUMBER;
l_mode_of_transport     VARCHAR2(100);

l_shipper_wait_time	VARCHAR2(32767);
l_shipper_cutoff_time	NUMBER;
l_shipper_cutoff_time_days	NUMBER;
l_load_tendered_time	DATE;

l_shipper_name		VARCHAR2(32767);
l_remaining_time	VARCHAR2(32767);

l_temp_value		NUMBER;
l_rem_days		NUMBER;
l_rem_hr		NUMBER;
l_rem_min		NUMBER;

l_ship_org_name	VARCHAR2(100);
l_ship_info	VARCHAR2(32767);

l_notif_type		VARCHAR2(10);
l_auto_accept		VARCHAR2(10);
l_carrier_site_id       NUMBER;

l_carrier_name		    VARCHAR2(360);

cursor get_carrier_name (c_trip_id number) is
select hz.party_name from
hz_parties hz, wsh_trips wt
where wt.carrier_id= hz.party_id AND
wt.trip_id =  c_trip_id;

CURSOR get_trip_cur(c_trip_id NUMBER) is
	SELECT trip_id, name,load_tender_status,load_Tender_number,
		shipper_wait_time,wait_time_uom,carrier_id,
		load_tendered_time,mode_of_transport
	from wsh_trips
	where trip_id = c_trip_id;


/* Bug 5312853: Query does not join contacts to sites
CURSOR get_notif_type_c (l_trip_id NUMBER) IS
	SELECT	car_sites.tender_transmission_method  notif_type,
		car_sites.auto_accept_load_tender auto_accept_flag,car_sites.carrier_site_id
	FROM hz_contact_points cont, hz_relationships rel,
		hz_party_sites sites, wsh_Carrier_sites car_sites, wsh_trips trips
	WHERE owner_table_name = 'HZ_PARTIES'
		and rel.party_id = owner_table_id
		and sites.party_id =rel.subject_id
		and car_sites.carrier_site_id = sites.party_site_id
		and trips.carrier_contact_id = owner_table_id
		and trip_id = l_trip_id;
*/

CURSOR get_notif_type_c (l_trip_id NUMBER) IS
	SELECT  car_sites.tender_transmission_method  notif_type,
	        car_sites.auto_accept_load_tender auto_accept_flag,car_sites.carrier_site_id
	FROM hz_parties party, hz_relationships rel, hz_party_sites sites,
     		hz_org_contacts cont, hz_contact_points points,
     		wsh_carrier_sites car_sites, wsh_trips trips
	WHERE rel.object_id = party.party_id
	AND rel.subject_type = 'ORGANIZATION'
	AND rel.subject_Table_name = 'HZ_PARTIES'
	AND sites.party_id = rel.subject_id
	AND cont.party_site_id = sites.party_site_id
	AND cont.party_relationship_id = rel.relationship_id
	AND points.owner_table_id = rel.party_id
	AND points.owner_table_name = 'HZ_PARTIES'
	AND points.contact_point_type = 'EMAIL'
	AND car_sites.carrier_site_id = sites.party_site_id
	AND trips.carrier_contact_id = points.owner_table_id
	AND trips.trip_id = l_trip_id;
--}


-- Debug paramteres
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || 'FTE_TENDER_WF'|| '.' || 'INITIALIZE_TENDER_REQUEST';

  l_userId              NUMBER;
  l_respId              NUMBER;
  l_respAppId           NUMBER;


BEGIN

   --wsh_debug_sv.push(l_api_name);
   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
	-- These values should be retrived from database

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	-- Initialize all the attributes to send notification to carrier
	-- based on the tender id
	-- Get the tender id first
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Getting Trip id, tender id, shipper name ',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	l_userId    := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey,'USER_ID');
	l_respAppId := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey, 'RESP_APPL_ID');
	l_respId    := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey,'RESPONSIBILITY_ID');


	IF(l_respAppId IS NULL OR l_respId IS NULL) THEN
		RAISE no_data_found;
	ELSE
		FND_GLOBAL.Apps_Initialize(l_userId, l_respId, l_respAppId);
	END IF;


	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Item key' || itemkey,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

 	l_tender_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TENDER_ID');

 	--l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');
 	l_trip_id	:= l_tender_id;


	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'After getting trip id ' || l_trip_id,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

 	l_shipper_name	:= wf_engine.GetItemAttrText(itemtype,itemkey,'SHIPPER_NAME');

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'After Getting Trip id, tender id, shipper name ' ||
				l_tender_id,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	--{
 	-- **************************** Rel 12
 	-- Query up trip information


	FOR get_trip_rec IN get_trip_cur(l_trip_id)
		LOOP
		--{
			l_trip_name		:=      get_trip_rec.name;
			l_shipper_wait_time	:= 	get_trip_rec.shipper_wait_time;
			l_wait_time_uom		:=	get_trip_rec.wait_time_uom;
			l_load_tendered_time	:=	get_trip_rec.load_tendered_time;
			l_carrier_id		:=	get_trip_rec.carrier_id;
			l_mode_of_transport	:=	get_trip_rec.mode_of_transport;
		--}
		END LOOP;
	-- END OF get trip segment info
	--
	--
	IF get_trip_cur%ISOPEN THEN
	  CLOSE get_trip_cur;
	END IF;


	-- Calculate Shipper Cutoff time
	l_shipper_cutoff_time := FTE_MLS_UTIL.FTE_UOM_CONV(l_shipper_wait_time, l_wait_time_uom,'MIN');

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Gettting shipper cuttoff time in MIN ' || l_shipper_cutoff_time,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF (l_shipper_cutoff_time = -9999)
	THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'orig wait time:'||l_shipper_wait_time ||
						l_wait_time_uom,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,'conv wait time:'||l_shipper_cutoff_time ||
						'MIN',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		FND_MESSAGE.SET_NAME('FTE','FTE_INVLD_SHIP_WAITTIME');
		FND_MESSAGE.SET_TOKEN('WAIT_TIME',l_shipper_wait_time);
		FND_MESSAGE.SET_TOKEN('WAIT_TIME_UOM',l_wait_time_uom);
		WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		l_msg_string := FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);


		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');

	END IF;



	l_shipper_cutoff_time_days := FTE_MLS_UTIL.FTE_UOM_CONV(l_shipper_wait_time,
					l_wait_time_uom,'DAY');

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,
			'Gettting shipper cuttoff time in days ' || l_shipper_cutoff_time_days,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


 	-- **************************** Rel 12
	--}
	-- initializing following parameters
	-- Carrier Name, Shipper Name, Tender Id, Respond By Date, Shipping Org Name,
	-- Response Url, Tendered Date, Shippment Information, Handling Information
	-- Carrier Contact Name, Email, Phone, Fax, Pickup Date

	-- Get response by date, tendered date, shipment info, handling info
	-- pickup date from GET_TENDER_INFO

        ------------------------------------------------------------------
	-- Samuthuk [ workflow Notifications std ]
        ------------------------------------------------------------------

	wf_engine.SetItemOwner(itemtype,itemkey,l_shipper_name);


	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Setting tender id',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

        wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDER_TEXT_ID',
				avalue		=>	to_char(l_tender_id));

	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDER_STATUS',
				avalue		=>	FTE_TENDER_PVT.S_TENDERED);


        wf_engine.SetItemAttrNumber(itemtype	=>	itemtype,
		   		itemkey		=>	itemkey,
				aname		=>	'CARRIER_ID',
				avalue		=>	l_carrier_id);

	wf_engine.SetItemAttrDate(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'RESPOND_BY_DATE',
				avalue		=>	(l_load_tendered_time+l_shipper_cutoff_time_days));


	wf_engine.SetItemAttrDate(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDERED_DATE',
				avalue		=>	l_load_tendered_time);

	wf_engine.SetItemAttrNumber(itemtype	=>	itemtype,
				   itemkey	=>	itemkey,
				   aname	=>	'SHIPPER_CUTOFF_TIME',
				   avalue	=>	l_shipper_cutoff_time);

	--Added by sharvisa
	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				   itemkey	=>	itemkey,
				   aname	=>	'MODE_OF_TRANSPORT',
				   avalue	=>	l_mode_of_transport);

	------------------------------------------------------------------
	-- Samuthuk [ workflow Notifications std ]
        ------------------------------------------------------------------
	l_shipper_wait_time := to_char(l_shipper_wait_time)||':'||l_wait_time_uom;

	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'SHIPPER_WAIT_TIME',
				avalue		=>	l_shipper_wait_time);

        ------------------------------------------------------------------


	-- org and shipment info
	FTE_TRIPS_PVT.GET_SHIPMENT_INFORMATION
			(p_init_msg_list           => FND_API.G_FALSE,
			p_tender_number		   => l_tender_id,
			x_return_status            => l_return_status,
			x_msg_count                => l_msg_count,
			x_msg_data                 => l_msg_data,
			x_shipment_info		   => l_ship_info,
			x_shipping_org_name	   => l_ship_org_name);

	IF ( (l_return_status = 'E')
	OR   (l_return_status = 'U') )
	THEN
		l_msg_string := FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;


	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'SHIPPING_ORG_NAME',
				avalue		=>	l_ship_org_name);


	-- Notification and Auto accept info
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Trip id ');
		WSH_DEBUG_SV.logmsg(l_module_name,' Auto Accept ' || l_auto_accept,
					WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	FOR get_notif_type_rec IN get_notif_type_c(l_trip_id)
		LOOP
		--{
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,' Getting notif and auto accept ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			l_notif_type := get_notif_type_rec.notif_type;
			l_auto_accept := get_notif_type_rec.auto_accept_flag;
			l_carrier_site_id := get_notif_type_rec.carrier_site_id;
		--}
		END LOOP;
	-- END OF g
	--
	--
	IF get_notif_type_c%ISOPEN THEN
	  CLOSE get_notif_type_c;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Notif Type ' || l_notif_type,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Auto Accept ' || l_auto_accept,
					WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


 	IF (l_notif_type IS NULL)
 	THEN
		l_notif_type := 'EMAIL';
	END IF;


	IF (l_auto_accept IS NULL)
	THEN
		l_auto_accept := 'N';
	END IF;

	OPEN get_carrier_name(l_trip_id);
	FETCH get_carrier_name into l_carrier_name;
	close get_carrier_name;


	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'CARRIER_NAME',
				avalue		=>	l_carrier_name);

	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'NOTIF_TYPE',
				avalue		=>	l_notif_type);

	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'AUTO_ACCEPT',
				avalue		=>	l_auto_accept);

        -- Rel 12 Coding....
	wf_engine.SetItemAttrNumber(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'CARRIER_SITE_ID',
				avalue		=>	l_carrier_site_id);






	resultout := 'COMPLETE:Y';
	return;


   END IF; --- func mode


   --7
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'INITIALIZE_TENDER_REQUEST',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode);
      RAISE;

END INITIALIZE_TENDER_REQUEST;


-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                UPDATE_CARRIER_RESPONSE                                    --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     p_tender_id	        NUMBER			           --
--                      p_remarks               VARCHAR2			   --
--                      p_initial_pickup_date	DATE				   --
--			p_ultimate_dropoff_date	DATE				   --
--										   --
-- PARAMETERS (OUT):								   --
--                      x_return_status	 VARCHAR2                                  --
--			x_msg_count	 NUMBER					   --
--			x_msg_data 	 VARCHAR2				   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:       This procedure Update the Trip/Stops with Carrier Responses  --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2003        11.5.9   SAMUTHUK           Created                                 --
-- 2005			SHRAVISA	   Updated                                 --
-- ------------------------------------------------------------------------------- --

PROCEDURE UPDATE_CARRIER_RESPONSE(
		p_init_msg_list  IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_tender_id               IN          NUMBER,
		p_tender_status		  IN          VARCHAR2,
	        p_wf_item_key		  IN	      VARCHAR2,
		p_remarks                 IN          VARCHAR2,
	        p_initial_pickup_date     IN          DATE,
	        p_ultimate_dropoff_date   IN          DATE,
		p_vehicle_number	  IN	      VARCHAR2,
		p_operator		  IN	      VARCHAR2,
		p_carrier_ref_number      IN	      VARCHAR2,
		p_call_source		  IN	      VARCHAR2,
	        x_return_status           OUT NOCOPY  VARCHAR2,
		x_msg_count               OUT NOCOPY  NUMBER,
		x_msg_data                OUT NOCOPY  VARCHAR2) IS

l_api_name	 VARCHAR2(30)     := 'UPDATE_CARRIER_RESPONSE';
l_api_version    CONSTANT NUMBER  := 1.0;
l_debug_on       BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name    CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CARRIER_RESPONSE';


l_action_out_rec	FTE_ACTION_OUT_REC;
trip_action_param 	FTE_TRIP_ACTION_PARAM_REC;
l_tender_attr_rec	FTE_TENDER_ATTR_REC;
l_tender_status         VARCHAR2(30);
l_tender_process        VARCHAR2(100);

l_file_name VARCHAR2(300);
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);




BEGIN

        wsh_debug_interface.g_Debug := TRUE;
	WSH_DEBUG_SV.start_debugger
	    (x_file_name     =>  l_file_name,
	     x_return_status =>  l_return_status,
	     x_msg_count     =>  l_msg_count,
	     x_msg_data      =>  l_msg_data);

        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

        SAVEPOINT UPDATE_CARRIER_RESPONSE_PUB;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;
		--
	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;

	--
	--  Initialize API return status to success
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;

       WSH_DEBUG_SV.log(l_module_name,' ************ Parameters ********************* ');
       WSH_DEBUG_SV.log(l_module_name,' p_tender_status ',p_tender_status);

       IF p_tender_status = FTE_TENDER_PVT.S_ACCEPTED THEN
	  l_tender_process := 'TENDER_ACCEPT_PROCESS';
       ELSIF p_tender_status = FTE_TENDER_PVT.S_REJECTED THEN
	  l_tender_process := 'TENDER_REJECT_PROCESS';
       END IF;

       WSH_DEBUG_SV.log(l_module_name,' l_tender_process ',l_tender_process);

       l_tender_attr_rec   :=    FTE_TENDER_ATTR_REC(
					p_tender_id, -- TripId
					null, -- Trip Name
					p_tender_id, --tender id
					p_tender_status, -- status
					null,-- car_contact_id
					null, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					null, -- ship wait time
					null, -- ship time uom
					'FTETERES', -- wf name
 					l_tender_process, -- wf process name
 					p_wf_item_key, --wf item key
 					p_remarks,
 					p_initial_pickup_date,
 					p_ultimate_dropoff_date,
 					p_vehicle_number,
 					p_operator,
 					p_carrier_ref_number,
 					null,
					FTE_TENDER_PVT.S_SOURCE_XML,
 					null);

	trip_action_param := FTE_TRIP_ACTION_PARAM_REC(null,p_tender_status,
					204,null,null,null,null,null,
					null,null,null,null,null,null,
					null,null);


        FTE_MLS_WRAPPER.Trip_Action (p_api_version_number => 1.0,
					    p_init_msg_list      => FND_API.G_TRUE,
					    x_return_status      => x_return_status,
					    x_msg_count          => x_msg_count,
					    x_msg_data           => x_msg_data,
					    x_action_out_rec	 => l_action_out_rec,
					    p_trip_info_rec	 => l_tender_attr_rec,
				 	    p_action_prms	 => trip_action_param);




	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );
	--
	--


	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


	EXCEPTION

		WHEN FND_API.G_EXC_ERROR THEN
			ROLLBACK TO UPDATE_CARRIER_RESPONSE_PUB;
	                x_return_status := FND_API.G_RET_STS_ERROR ;
		        FND_MSG_PUB.Count_And_Get
			  (
	                     p_count  => x_msg_count,
	                     p_data  =>  x_msg_data,
		             p_encoded => FND_API.G_FALSE
		          );
	        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		        ROLLBACK TO UPDATE_CARRIER_RESPONSE_PUB;
	                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		        FND_MSG_PUB.Count_And_Get
			  (
	                     p_count  => x_msg_count,
		             p_data  =>  x_msg_data,
		             p_encoded => FND_API.G_FALSE
	                  );

	         WHEN OTHERS THEN
	                ROLLBACK TO UPDATE_CARRIER_RESPONSE_PUB;
	                wsh_util_core.default_handler('FTE_TENDER_WF.UPDATE_CARRIER_RESPONSE');
	                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	                FND_MSG_PUB.Count_And_Get
	                  (
	                     p_count  => x_msg_count,
	                     p_data  =>  x_msg_data,
		             p_encoded => FND_API.G_FALSE
	                  );


END UPDATE_CARRIER_RESPONSE;




-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                RAISE_TENDER_ACCEPT                                        --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR					   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure will trigger the approve notification       --
--			Load Tendering Process.
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2003        11.5.9   SAMUTHUK           Created                                 --
--                                                                                 --
-- ------------------------------------------------------------------------------- --

PROCEDURE RAISE_TENDER_ACCEPT( itemtype  in  varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2) IS


l_return_status		VARCHAR2(30000);
l_tender_status         VARCHAR2(2000);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(30000);
l_tender_id		NUMBER;
l_shipper_name		VARCHAR2(2000);
l_carrier_name		VARCHAR2(2000);
l_contact_name	        VARCHAR2(10000);
l_contact_perf		VARCHAR2(2000);
l_carrier_response	VARCHAR2(2000);
l_initial_pickup_date   DATE;
l_ultimate_dropoff_date DATE;
l_carrier_reference_number VARCHAR2(30);
l_vehicle_number	VARCHAR2(35);
l_operator		VARCHAR2(150);

l_trip_id	NUMBER;
l_trip_name	VARCHAR2(30000);
l_api_name	VARCHAR2(30) := 'RAISE_TENDER_ACCEPT';
l_msg_string		VARCHAR2(30000);


l_action_out_rec	FTE_ACTION_OUT_REC;
trip_action_param 	FTE_TRIP_ACTION_PARAM_REC;
l_tender_attr_rec	FTE_TENDER_ATTR_REC;
l_responseSource	VARCHAR2(30);

l_api_name	 VARCHAR2(30)     := 'RAISE_TENDER_ACCEPT';
l_api_version    CONSTANT NUMBER  := 1.0;
l_debug_on       CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name    CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'RAISE_TENDER_ACCEPT';


BEGIN

   IF (funcmode = 'RUN') THEN


	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	l_responseSource := wf_engine.GetItemAttrText(itemtype,itemkey,'RESPONSE_SOURCE');

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Response source ' || l_responseSource,
						  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF (l_responseSource = FTE_TENDER_PVT.S_SOURCE_CP OR
		l_responseSource = FTE_TENDER_PVT.S_SOURCE_XML)
	THEN
		RETURN; -- We already have response.
	END IF;

	l_tender_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'TENDER_ID');
	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');

	-- TBD
	l_trip_id := l_tender_id;
	l_carrier_response := wf_engine.GetItemAttrText(itemtype,itemkey,'CARRIER_RESPONSE');

	l_tender_status	   := FTE_TENDER_PVT.S_ACCEPTED;
	l_initial_pickup_date   := wf_engine.GetItemAttrDate(itemtype,itemkey,'INITIAL_PICKUP_DATE');
	l_ultimate_dropoff_date := wf_engine.GetItemAttrDate(itemtype,itemkey,'ULTIMATE_DROPOFF_DATE');
	--l_carrier_reference_number := wf_engine.GetItemAttrText(itemtype,itemkey,'Z_CARRIER_REFERENCE_NUMBER');
	l_vehicle_number	:= wf_engine.GetItemAttrText(itemtype,itemkey,'VEHICLE_NUMBER');
	l_operator		:= wf_engine.GetItemAttrText(itemtype,itemkey,'VEHICLE_OPERATOR');

	l_tender_attr_rec	:= FTE_TENDER_ATTR_REC(
					l_trip_id, -- TripId
					null, -- Trip Name
					l_tender_id, --tender id
					FTE_TENDER_PVT.S_ACCEPTED, -- status
					null,-- car_contact_id
					null, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					null, -- ship wait time
					null, -- ship time uom
					'FTETERES', -- wf name
 					'TENDER_ACCEPT_PROCESS', -- wf process name
 					itemkey, --wf item key
 					l_carrier_response,
 					l_initial_pickup_date,
 					l_ultimate_dropoff_date,
 					l_vehicle_number,
 					l_operator,
 					l_carrier_reference_number,
 					null,
 					FTE_TENDER_PVT.S_SOURCE_WL,
 					null);

	trip_action_param := FTE_TRIP_ACTION_PARAM_REC(null,FTE_TENDER_PVT.S_ACCEPTED,
					null,null,null,null,null,null,
					null,null,null,null,null,null,
					null,null);


	FTE_MLS_WRAPPER.Trip_Action (p_api_version_number     => 1.0,
		p_init_msg_list          => FND_API.G_TRUE,
		x_return_status          => l_return_status,
		x_msg_count              => l_msg_count,
		x_msg_data               => l_msg_data,
		x_action_out_rec	 => l_action_out_rec,
		p_trip_info_rec	     	 => l_tender_attr_rec,
		p_action_prms	     	 => trip_action_param);



	IF ( (l_return_status = 'E') OR   (l_return_status = 'U') ) THEN
		l_msg_string := FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


	-- Now raise the event

	resultout := 'COMPLETE:Y';
        return;


   END IF;


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'RAISE_TENDER_ACCEPT',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END RAISE_TENDER_ACCEPT;



-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                RAISE_TENDER_REJECT                                        --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR					   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure will trigger the reject notification        --
--			Process.
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2003        11.5.9   SAMUTHUK           Created                                 --
--                                                                                 --
-- ------------------------------------------------------------------------------- --

PROCEDURE RAISE_TENDER_REJECT( itemtype  in  varchar2,
			       itemkey   in  varchar2,
	                       actid     in  number,
		               funcmode  in  varchar2,
			       resultout out NOCOPY varchar2) IS


l_return_status		VARCHAR2(30000);
l_tender_status         VARCHAR2(2000);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(30000);
l_tender_id		NUMBER;
l_shipper_name		VARCHAR2(2000);
l_carrier_name		VARCHAR2(2000);
l_contact_name	        VARCHAR2(10000);
l_contact_perf		VARCHAR2(2000);
l_msg_string		VARCHAR2(30000);
l_carrier_response	VARCHAR2(2000);
l_trip_id	NUMBER;
l_trip_name	VARCHAR2(30000);

l_api_name	VARCHAR2(30) := 'RAISE_TENDER_REJECT';

l_action_out_rec	FTE_ACTION_OUT_REC;
trip_action_param 	FTE_TRIP_ACTION_PARAM_REC;
l_tender_attr_rec	FTE_TENDER_ATTR_REC;

l_responseSource	VARCHAR2(30);

BEGIN

   IF (funcmode = 'RUN') THEN

	l_responseSource := wf_engine.GetItemAttrText(itemtype,itemkey,'RESPONSE_SOURCE');

	IF (l_responseSource = FTE_TENDER_PVT.S_SOURCE_CP OR
		l_responseSource = FTE_TENDER_PVT.S_SOURCE_XML)
	THEN
		RETURN; -- We already have response.
	END IF;


	l_tender_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'TENDER_ID');
	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');

	-- TBD
	l_trip_id := l_tender_id;
	l_carrier_response := wf_engine.GetItemAttrText(itemtype,itemkey,'CARRIER_RESPONSE');

	l_tender_attr_rec	:= FTE_TENDER_ATTR_REC(
					l_trip_id, -- TripId
					null, -- Trip Name
					l_tender_id, --tender id
					FTE_TENDER_PVT.S_REJECTED, -- status
					null,-- car_contact_id
					null, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					null, -- ship wait time
					null, -- ship time uom
					'FTETERES', -- wf name
 					'TENDER_REJECT_PROCESS', -- wf process name
 					itemkey, --wf item key
 					l_carrier_response,
 					null,
 					null,
 					null,
 					null,
 					null,
 					null,
 					FTE_TENDER_PVT.S_SOURCE_WL,
 					null);

	trip_action_param := FTE_TRIP_ACTION_PARAM_REC(null,FTE_TENDER_PVT.S_REJECTED,
					204,null,null,null,null,null,
					null,null,null,null,null,null,
					null,null);


	FTE_MLS_WRAPPER.Trip_Action (p_api_version_number     => 1.0,
		p_init_msg_list          => FND_API.G_TRUE,
		x_return_status          => l_return_status,
		x_msg_count              => l_msg_count,
		x_msg_data               => l_msg_data,
		x_action_out_rec	 => l_action_out_rec,
		p_trip_info_rec	     	 => l_tender_attr_rec,
		p_action_prms	     	 => trip_action_param);



	IF ( (l_return_status = 'E') OR   (l_return_status = 'U') ) THEN
		l_msg_string := FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;

	-- Now raise the event

        resultout := 'COMPLETE:Y';

   END IF;

   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:N';
      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'RAISE_TENDER_REJECT',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END RAISE_TENDER_REJECT;


-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                FINALIZE_UPDATE_TENDER                                  --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR					   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure will initialize the attributes for update   --
--			Load Tendering Process.
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002		11.5.8  HBHAGAVA           Created                                 --
-- 2003		11.5.9  SAMUTHUK           Modified				   --
-- ------------------------------------------------------------------------------- --

PROCEDURE FINALIZE_UPDATE_TENDER(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS

l_result_code	VARCHAR2(10);
l_tender_id 	NUMBER;
l_api_name	VARCHAR2(30) := 'FINALIZE_UPDATE_TENDER';


l_return_status	VARCHAR2(30000);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_msg_string	VARCHAR2(30000);

  l_userId              NUMBER;
  l_respId              NUMBER;
  l_respAppId           NUMBER;


BEGIN

   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
	-- These values should be retrived from database

	-- Initialize all the attributes to send notification to carrier
	-- based on the tender id
	-- Get the tender id first


	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDER_STATUS',
				avalue		=>	FTE_TENDER_PVT.S_SHIPPER_UPDATED);

	wf_engine.SetItemOwner(itemtype,itemkey,wf_engine.GetItemAttrText(itemtype,
						itemkey,'SHIPPER_NAME'));


	l_userId    := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey,'USER_ID');
	l_respAppId := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey, 'RESP_APPL_ID');
	l_respId    := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey,'RESPONSIBILITY_ID');


	    IF(l_respAppId IS NULL OR l_respId IS NULL) THEN
	      RAISE no_data_found;
	    ELSE
	      FND_GLOBAL.Apps_Initialize(l_userId, l_respId, l_respAppId);
	    END IF;


	resultout := 'COMPLETE:Y';
	return;


   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'FINALIZE_UPDATE_TENDER',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode);
      RAISE;

END FINALIZE_UPDATE_TENDER;



-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                FINALIZE_TENDER_REQUEST                                  --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR					   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure will finalize the load tender process 	   --
--			This process will check if tender request block is notified--
--			if it is then it will release the block and set's up	   --
--			other paramters to indicate that load tender request is    --
--			completed						   --
--			If process is blocked by reminder then the block and 	   --
--			release and other paramters are set to indicate that load  --
--			tender request is completed				   --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION    BY        BUG      DESCRIPTION                           --
-- ----------  -------    --------  -------  ----------------------------------------
-- 2002		11.5.8    HBHAGAVA           Created                               --
-- 2003		11.5.9    SAMUTHUK	     Modified				   --	                                                                                   --
-- ----------------------------------------------------------------------------------

PROCEDURE FINALIZE_TENDER_REQUEST(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'FINALIZE_TENDER_REQUEST';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;

l_trip_id	NUMBER;
l_tender_id	NUMBER;
l_tender_action	VARCHAR2(30);

l_return_status	VARCHAR2(30000);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_msg_string	VARCHAR2(30000);
l_ship_org_name	VARCHAR2(100);
l_ship_info	VARCHAR2(32767);


  l_userId              NUMBER;
  l_respId              NUMBER;
  l_respAppId           NUMBER;


BEGIN

   --
   -- RUN mode - normal process execution
   --

   IF (funcmode = 'RUN') THEN



	IF l_debug_on THEN
			WSH_DEBUG_SV.push(l_api_name);

   	END IF;


      	l_tender_action := wf_engine.getItemAttrText(itemtype, itemkey, 'TENDER_ACTION');

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_api_name,l_tender_action,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	l_tender_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TENDER_ID');
 	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');
 	l_trip_id	:= l_tender_id;


        wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDER_TEXT_ID',
				avalue		=>	to_char(l_tender_id));


	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDER_STATUS',
				avalue		=>	l_tender_action);

	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'SHIPPER_NAME',
				avalue		=>	wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'SHIPPER_NAME'));

	wf_engine.SetItemOwner(itemtype,itemkey,wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'SHIPPER_NAME'));

	--Addded by sharvisa for R12
	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'MODE_OF_TRANSPORT',
				avalue		=>	wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'MODE_OF_TRANSPORT'));


	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'SHIPPER_WAIT_TIME',
				avalue		=>	wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'SHIPPER_WAIT_TIME'));


	wf_engine.SetItemAttrDate(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDERED_DATE',
				avalue		=>	wf_engine.GetItemAttrDate(
						'FTETEREQ', itemkey, 'TENDERED_DATE'));

         wf_engine.SetItemAttrText(itemtype	=>	itemtype,
		   		  itemkey	=>	itemkey,
				  aname		=>	'MBOL_NUM',
				  avalue	=>	wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'MBOL_NUM'));


         -- Rel12 Coding ....
         wf_engine.SetItemAttrNumber(itemtype	=>	itemtype,
		   		  itemkey	=>	itemkey,
				  aname		=>	'CARRIER_SITE_ID',
				  avalue	=>	wf_engine.GetItemAttrNumber(
						'FTETEREQ', itemkey, 'CARRIER_SITE_ID'));

	 wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				  itemkey	=>	itemkey,
				  aname		=>	'CONTACT_PERFORMER',
				  avalue	=>	wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'CONTACT_PERFORMER'));

	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'SHIPPING_ORG_NAME',
				avalue		=>	wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'SHIPPING_ORG_NAME'));


	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'CARRIER_NAME',
				avalue		=>	wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'CARRIER_NAME'));

	-- Initialize fnd context.

	l_userId    := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey,'USER_ID');
	l_respAppId := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey, 'RESP_APPL_ID');
	l_respId    := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey,'RESPONSIBILITY_ID');

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Initializing responsiblity information ' ||
						l_userId,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF(l_respAppId IS NULL OR l_respId IS NULL) THEN
		RAISE no_data_found;
	ELSE
		FND_GLOBAL.Apps_Initialize(l_userId, l_respId, l_respAppId);
	END IF;


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_api_name);
	END IF;

	resultout := 'COMPLETE:Y';
      	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'FINALIZE_TENDER_REQUEST',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END FINALIZE_TENDER_REQUEST;

--*******************************************************
-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                IS_TENDER_MODIFIED                                  	   --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR2					   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure calculated the remaining block time and     --
--			assigns it to tender block. The calculation is based on    --
--			the numder of loops and reminder time.
--			This is a temp procedure. Should be changed with actual database check
-- -- This is a temp procedure. Should be changed with actual database check
-- and see if the tender status of delivery is modified
--
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --



PROCEDURE IS_TENDER_MODIFIED(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS

l_is_modified	VARCHAR2(10);

BEGIN

   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --
      -- Call API to get the value of the wf status
      --

	l_is_modified	:= wf_engine.GetItemAttrText(itemtype,itemkey,'TENDER_MODIFIED');

	IF (l_is_modified = 'YES') THEN
		resultout	:= 'COMPLETE:Y';
		return;
	ELSE
		resultout	:= 'COMPLETE:N';
		return;
	END IF;

   END IF; --- func mode


EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'IS_TENDER_MODIFIED',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END IS_TENDER_MODIFIED;

--*******************************************************
-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                IS_REMINDER_ENABLED                                  	   --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR2				   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure calculated the remaining block time and     --
--			assigns it to tender block. The calculation is based on    --
--			the numder of loops and reminder time.
--			This is a temp procedure. Should be changed with actual database check
--
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --

--

PROCEDURE IS_REMINDER_ENABLED(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS

BEGIN

   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --
      -- Call API to get the value of the wf status
      --
      	-- hbhagava 09/02/2002
	-- This value will remain 'COMPLETE:N' since we are not going to
	-- implement reminder functionality in Pack I
	resultout	:= 'COMPLETE:N';
	return;

   END IF; --- func mode


EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'IS_REMINDER_ENABLED',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END IS_REMINDER_ENABLED;

--*******************************************************
-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                CALCULATE_WAIT_TIME                                  --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR2					   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure calculated the remaining block time and     --
--			assigns it to tender block. The calculation is based on    --
--			the numder of loops and reminder time.
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --

PROCEDURE CALCULATE_WAIT_TIME(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS

l_loop_count	NUMBER;
l_max_reminder	NUMBER;
l_reminder_time	NUMBER;
l_total_reminder_time	NUMBER;
l_tender_block_time	NUMBER;


BEGIN

   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --
      -- Call API to get the value of the wf status
      --

	-- Calculate the tender block time / wait time based on
	-- number of loops and reminder time. If tender wait time is less than
	-- total reminder time then there is no use of reminder
	-- just proceed to tender block. So return N

      	l_loop_count := FTE_WF_UTIL.GET_ATTRIBUTE_NUMBER(
      						p_item_type  => 	itemtype,
                                                p_item_key   => 	itemkey,
                                                p_aname      => 	'CYCLE_COUNTER'
                                                	);

	l_max_reminder	:= wf_engine.GetItemAttrNumber(
						itemtype 	=> 	itemtype,
						itemkey		=>	itemkey,
						aname		=>	'MAX_NO_REMINDER'
							);

	l_reminder_time	:= wf_engine.GetItemAttrNumber(
						itemtype 	=> 	itemtype,
						itemkey		=>	itemkey,
						aname		=>	'REMINDER_WAIT_TIME'
							);

	-- wait time to expire load tender request.
	l_tender_block_time := wf_engine.GetItemAttrNumber(
						itemtype 	=> 	itemtype,
						itemkey		=>	itemkey,
						aname		=>	'SHIPPER_CUTOFF_TIME'
							);

	-- Left out time for reminders
	--l_total_reminder_time	:=  (l_max_reminder - 1) * l_reminder_time;


	IF (l_tender_block_time <= l_reminder_time) THEN
		resultout := 'COMPLETE:Y';
	ELSE
		resultout := 'COMPLETE:N';
		-- since we going to block the activity for reminder, remove that time from
		-- tender block time
		l_tender_block_time := l_tender_block_time - l_reminder_time;
	END IF;

	wf_engine.SetItemAttrNumber(
				itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'SHIPPER_CUTOFF_TIME',
				avalue		=>	l_tender_block_time
				);

	return;

   END IF; --- func mode


EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'CALCULATE_WAIT_TIME',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END CALCULATE_WAIT_TIME;


--*******************************************************
-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                FINALIZE_NORESPONSE                                        --
-- TYPE:                PROCEDURE                                                  --
-- PARAMETERS (IN):     itemtype	VARCHAR2				   --
--                      itemkey         VARCHAR2 (wf block instance label)         --
--                      actid		NUMBER					   --
--			funcmode	VARCHAR2				   --
--
-- PARAMETERS (OUT):    resultout       VARCHAR2                                   --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              none                                                       --
-- DESCRIPTION:         This procedure will finalize the no response tender request--
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                --
--                                                                                 --
-- ------------------------------------------------------------------------------- --

PROCEDURE FINALIZE_NORESPONSE(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'FINALIZE_NORESPONSE';
l_api_version           CONSTANT NUMBER         := 1.0;

l_tender_id	NUMBER;
l_return_status	VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);

l_msg_string	VARCHAR2(30000);
l_trip_id	NUMBER;
l_trip_name	VARCHAR2(30000);
l_msg_token     VARCHAR2(1000);

l_action_out_rec	FTE_ACTION_OUT_REC;
trip_action_param 	FTE_TRIP_ACTION_PARAM_REC;
l_tender_attr_rec	FTE_TENDER_ATTR_REC;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;

  l_userId              NUMBER;
  l_respId              NUMBER;
  l_respAppId           NUMBER;


BEGIN

   --wsh_debug_sv.push(l_api_name,'>>FTE: Enterning Procedure');

   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --

 	l_tender_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TENDER_ID');
 	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');
 	l_trip_id	:= l_tender_id;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Trip Id ' || l_trip_id,WSH_DEBUG_SV.C_PROC_LEVEL);
		WSH_DEBUG_SV.logmsg(l_module_name,' Tender Id' || l_tender_id,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDER_STATUS',
				avalue		=>	FTE_TENDER_PVT.S_NORESPONSE);

         -- Rel12 Coding ....
         wf_engine.SetItemAttrNumber(itemtype	=>	itemtype,
		   		  itemkey	=>	itemkey,
				  aname		=>	'CARRIER_SITE_ID',
				  avalue	=>	wf_engine.GetItemAttrNumber(
						'FTETEREQ', itemkey, 'CARRIER_SITE_ID'));

	-- INITIALIZE_ APPS CONTEXT

	l_userId    := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey,'USER_ID');
	l_respAppId := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey, 'RESP_APPL_ID');
	l_respId    := wf_engine.GetItemAttrNumber('FTETEREQ',itemKey,'RESPONSIBILITY_ID');

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Initializing responsiblity information ' ||
						l_userId,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF(l_respAppId IS NULL OR l_respId IS NULL) THEN
		RAISE no_data_found;
	ELSE
		FND_GLOBAL.Apps_Initialize(l_userId, l_respId, l_respAppId);
	END IF;



	l_tender_attr_rec	:= FTE_TENDER_ATTR_REC(
					l_trip_id, -- TripId
					null, -- Trip Name
					l_tender_id, --tender id
					FTE_TENDER_PVT.S_NORESPONSE, -- status
					null,-- car_contact_id
					null, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					null, -- ship wait time
					null, -- ship time uom
					'FTETEREQ', -- wf name
 					'TENDER_NORESPONSE_PROCESS', -- wf process name
 					itemkey, --wf item key
 					null,null,null,null,null,null,null,null,null);

	trip_action_param := FTE_TRIP_ACTION_PARAM_REC(null,FTE_TENDER_PVT.S_NORESPONSE,
					null,null,null,null,null,null,
					null,null,null,null,null,null,
					null,null);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Before Calling FTE_MLS_WRAPPER.TRIP_ACTION ' || l_trip_id,
							WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	FTE_MLS_WRAPPER.Trip_Action (p_api_version_number     => 1.0,
		p_init_msg_list          => FND_API.G_TRUE,
		x_return_status          => l_return_status,
		x_msg_count              => l_msg_count,
		x_msg_data               => l_msg_data,
		x_action_out_rec	 => l_action_out_rec,
		p_trip_info_rec	     	 => l_tender_attr_rec,
		p_action_prms	     	 => trip_action_param);



	IF ( (l_return_status = 'E') OR   (l_return_status = 'U') ) THEN
		l_msg_string := FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' l_return_status after
				FTE_MLS_WRAPPER.TRIP_ACTION ' ||
				l_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	resultout := 'COMPLETE:Y';

	IF l_debug_on THEN
		wsh_debug_sv.pop(l_api_name);
	END IF;
	--wsh_debug_sv.pop(l_api_name);

      	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'FINALIZE_NORESPONSE',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END FINALIZE_NORESPONSE;


PROCEDURE FINALIZE_AUTO_ACCEPT(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'FINALIZE_AUTO_ACCEPT';
l_api_version           CONSTANT NUMBER         := 1.0;

l_tender_id	NUMBER;
l_return_status	VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_trip_id	NUMBER;
l_trip_name	VARCHAR2(30000);
l_msg_string	VARCHAR2(30000);


p_trip_info_tab		WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
p_trip_in_rec 		WSH_TRIPS_GRP.TripInRecType;
x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;

l_number_of_warnings	NUMBER;
l_number_of_errors	NUMBER;


l_action_out_rec	FTE_ACTION_OUT_REC;
trip_action_param 	FTE_TRIP_ACTION_PARAM_REC;
l_tender_attr_rec	FTE_TENDER_ATTR_REC;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


BEGIN


   --wsh_debug_sv.push(l_api_name,'>>FTE: Enterning Procedure');

   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --


	 wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'TENDER_STATUS',
				avalue		=>	FTE_TENDER_PVT.S_AUTO_ACCEPTED);

         -- Rel12 Coding ....
         wf_engine.SetItemAttrNumber(itemtype	=>	itemtype,
		   		  itemkey	=>	itemkey,
				  aname		=>	'CARRIER_SITE_ID',
				  avalue	=>	wf_engine.GetItemAttrNumber(
						'FTETEREQ', itemkey, 'CARRIER_SITE_ID'));

	 wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'CARRIER_NAME',
				avalue		=>	wf_engine.GetItemAttrText(
						'FTETEREQ', itemkey, 'CARRIER_NAME'));

	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

 	l_tender_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TENDER_ID');
 	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');
 	l_trip_id	:= l_tender_id;


	l_tender_attr_rec	:= FTE_TENDER_ATTR_REC(
					l_trip_id, -- TripId
					null, -- Trip Name
					l_tender_id, --tender id
					FTE_TENDER_PVT.S_AUTO_ACCEPTED, -- status
					null,-- car_contact_id
					null, -- car contact name
					null, -- auto_accept
					null, -- auto tender
					null, -- ship wait time
					null, -- ship time uom
					'FTETEREQ', -- wf name
 					'AUTO_ACCEPT_PROCESS', -- wf process name
 					itemkey, --wf item key
 					null,null,null,null,null,null,null,null,null);

	trip_action_param := FTE_TRIP_ACTION_PARAM_REC(null,FTE_TENDER_PVT.S_AUTO_ACCEPTED,
					204,null,null,null,null,null,
					null,null,null,null,null,null,
					null,null);


	FTE_MLS_WRAPPER.Trip_Action (p_api_version_number     => 1.0,
		p_init_msg_list          => FND_API.G_TRUE,
		x_return_status          => l_return_status,
		x_msg_count              => l_msg_count,
		x_msg_data               => l_msg_data,
		x_action_out_rec	 => l_action_out_rec,
		p_trip_info_rec	     	 => l_tender_attr_rec,
		p_action_prms	     	 => trip_action_param);



	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' l_return_status after
				FTE_MLS_WRAPPER.TRIP_ACTION ' ||
				l_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);

	IF ( (l_return_status = 'E')
	OR   (l_return_status = 'U') )
	THEN
		l_msg_string := 'FINALIZE_AUTO_ACCEPT :-> Tender Id ='||to_char(l_tender_id)||' :'||FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;

	resultout := 'COMPLETE:Y';
	--wsh_debug_sv.pop(l_api_name);
      	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                     'FINALIZE_AUTO_ACCEPT',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END FINALIZE_AUTO_ACCEPT;



PROCEDURE IS_AUTO_ACCEPT_ENABLED(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'IS_AUTO_ACCEPT_ENABLED';
l_api_version           CONSTANT NUMBER         := 1.0;

l_autoAccept 		VARCHAR2(10);

BEGIN


   --wsh_debug_sv.push(l_api_name,'>>FTE: Enterning Procedure');

   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --

 	l_autoAccept	:= wf_engine.GetItemAttrText(itemtype,itemkey,'AUTO_ACCEPT');

 	IF (l_autoAccept = 'Y')
 	THEN
		resultout := 'COMPLETE:Y';
	ELSE
		resultout := 'COMPLETE:N';
	END IF;

      	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'IS_AUTO_ACCEPT_ENABLED',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END IS_AUTO_ACCEPT_ENABLED;

-- Get response by date, tendered date, handling info pickup date from GET_TENDER_INFO
-- Reminder time

PROCEDURE GET_TENDER_INFO(
			p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
			p_tender_id		  IN	 NUMBER,
	        	x_return_status           OUT	NOCOPY   VARCHAR2,
	        	x_msg_count               OUT   NOCOPY NUMBER,
	        	x_msg_data                OUT   NOCOPY VARCHAR2,
	        	x_response_by		  OUT	NOCOPY DATE,
			x_shipper_wait_time	  OUT   NOCOPY VARCHAR2,
	        	x_remaining_time	  OUT	NOCOPY VARCHAR2,
	        	x_routing_inst		  OUT	NOCOPY VARCHAR2,
	        	x_tendered_date		  OUT	NOCOPY DATE,
	        	x_carrier_remarks	  OUT   NOCOPY VARCHAR2,
			x_mode_of_transport       OUT   NOCOPY VARCHAR2) IS
	--{

        l_api_name              CONSTANT VARCHAR2(30)   := 'GET_TENDER_INFO';
        l_api_version           CONSTANT NUMBER         := 1.0;
        l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'GET_TENDER_INFO';

        l_wait_time	NUMBER;
        l_wait_time_uom	VARCHAR(10);
        l_temp_value		NUMBER;
        l_rem_days		NUMBER;
        l_rem_hr		NUMBER;
        l_rem_min		NUMBER;
        l_wait_time_days	NUMBER;
        l_respond_by_text	DATE;

	--}

	CURSOR get_tender_info_cur (c_tender_id NUMBER)
	IS
	SELECT routing_instructions, load_tendered_time,
		shipper_wait_time,wait_time_uom, carrier_response, mode_of_transport
	FROM wsh_trips	WHERE load_tender_number = c_tender_id;

	--{
	BEGIN
		--
	        -- Standard Start of API savepoint
	        SAVEPOINT   GET_TENDER_INFO_PUB;
		--
		--
	        -- Initialize message list if p_init_msg_list is set to TRUE.
		--
		--
		IF FND_API.to_Boolean( p_init_msg_list )
		THEN
			FND_MSG_PUB.initialize;
		END IF;
		--
		IF l_debug_on THEN
		      wsh_debug_sv.push(l_module_name);
		END IF;

		--
		--  Initialize API return status to success
		x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		x_msg_count		:= 0;
		x_msg_data		:= 0;

		--
		--GET TRIP INFO
		--
		FOR get_tender_info_rec IN get_tender_info_cur(p_tender_id)
		LOOP
			x_tendered_date		:=	get_tender_info_rec.load_tendered_time;
			x_routing_inst		:=	get_tender_info_rec.routing_instructions;
			x_carrier_remarks	:= 	get_tender_info_rec.carrier_response;
			l_wait_time		:=	get_tender_info_rec.shipper_wait_time;
			l_wait_time_uom		:=	get_tender_info_rec.wait_time_uom;
			x_mode_of_transport     :=	get_tender_info_rec.mode_of_transport;
		END LOOP;
		-- END OF GET TRIP INFO


		IF get_tender_info_cur%ISOPEN THEN
		  CLOSE get_tender_info_cur;
		END IF;

		-- Bug 2917554: Use FTE conversion method
		--l_wait_time_days := INV_CONVERT.inv_um_convert(null,
		--					5,l_wait_time,
		--					l_wait_time_uom,
		--					'DAY',NULL,NULL);

	        ------------------------------------------------------------------
		-- Samuthuk [ workflow Notifications std ]
	        ------------------------------------------------------------------
		x_shipper_wait_time := to_char(l_wait_time)||':'||l_wait_time_uom;
	        ------------------------------------------------------------------


		l_wait_time_days := FTE_MLS_UTIL.FTE_UOM_CONV(l_wait_time, l_wait_time_uom,'DAY');

		--l_wait_time_days := FTE_MLS_UTIL.FTE_UOM_CONV(l_wait_time, l_wait_time_uom,'MIN');

		IF (l_wait_time_days = -9999)
		THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_INVLD_SHIP_WAITTIME');
			FND_MESSAGE.SET_TOKEN('WAIT_TIME',l_wait_time_days);
			FND_MESSAGE.SET_TOKEN('WAIT_TIME_UOM','DAY');
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		RAISE FND_API.G_EXC_ERROR;
		END IF;

		x_response_by	:=  (x_tendered_date+l_wait_time_days);
		--l_respond_by_text := x_tendered_date + l_wait_time_days/(60*24);

		IF l_debug_on
		THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Nhi!TenderedDate:'||x_tendered_date,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,'Nhi!WaitTime:'||l_wait_time||l_wait_time_uom,WSH_DEBUG_SV.C_PROC_LEVEL);
			--WSH_DEBUG_SV.logmsg(l_module_name,'Nhi!ResponseByText:'||l_respond_by_text,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		l_temp_value 	:= trunc(to_number(x_response_by-SYSDATE),2);

		-- Bug 2917554: Use FTE conversion method
		--l_temp_value    :=  INV_CONVERT.inv_um_convert(null,2,
		-- 					l_temp_value,
		--					'DAY','MIN',
		--					NULL,NULL);
		l_temp_value := FTE_MLS_UTIL.FTE_UOM_CONV(l_temp_value, 'DAY','MIN');

		IF (l_temp_value = -9999)
		THEN
			FND_MESSAGE.SET_NAME('FTE','FTE_INVLD_SHIP_WAITTIME');
			FND_MESSAGE.SET_TOKEN('WAIT_TIME',l_temp_value);
			FND_MESSAGE.SET_TOKEN('WAIT_TIME_UOM','MIN');
			WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		RAISE FND_API.G_EXC_ERROR;
		END IF;

		l_rem_days	:= trunc(l_temp_value/(60*24),0);
		l_temp_value	:= l_temp_value - (l_rem_days*60*24);
		l_rem_hr	:= trunc(l_temp_value/(60),0);
		l_rem_min	:= trunc(l_temp_value - (l_rem_hr*60),0);
		x_remaining_time	:= l_rem_days || 'd:' || l_rem_hr
					   || 'h:' || l_rem_min || 'm';

		IF l_debug_on
		THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Nhi!Remainingtime:'||x_remaining_time,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.logmsg(l_module_name,'Nhi!SYSDATE:'||SYSDATE,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		--
		--
		--
		-- Standard call to get message count and if count is 1,get message info.
		--
		FND_MSG_PUB.Count_And_Get
		  (
		    p_count =>  x_msg_count,
		    p_data  =>  x_msg_data,
		    p_encoded => FND_API.G_FALSE
		  );
		--
		--
		IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
    		END IF;

	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO GET_TENDER_INFO_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO GET_TENDER_INFO_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
       WHEN OTHERS THEN
                ROLLBACK TO GET_TENDER_INFO_PUB;
                wsh_util_core.default_handler('FTE_TENDER_WF.GET_TENDER_INFO');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count   => x_msg_count,
                     p_data    => x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END GET_TENDER_INFO;


-- Rel 12 HBHAGAVA
PROCEDURE GET_NOTIF_TYPE(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS
--{


l_api_name              CONSTANT VARCHAR2(30)   := 'GET_NOTIF_TYPE';
l_api_version           CONSTANT NUMBER         := 1.0;

l_trip_id		NUMBER;
l_notif_type		VARCHAR2(10);

-- Cursor Definition
--{
--}

BEGIN


   --wsh_debug_sv.push(l_api_name,'>>FTE: Enterning Procedure');

   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --
	IF (itemtype ='FTETEUPD')  THEN
 		l_notif_type	:= wf_engine.GetItemAttrText('FTETEUPD',itemkey,'NOTIF_TYPE');
	ELSE
		l_notif_type	:= wf_engine.GetItemAttrText('FTETEREQ',itemkey,'NOTIF_TYPE');
	END IF ;

 	IF (l_notif_type IS NULL OR l_notif_type = 'EMAIL')
 	THEN
		resultout := 'COMPLETE:EMAIL';
	ELSE
		resultout := 'COMPLETE:XML';
	END IF;

      	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;
--}

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      'GET_NOTIF_TYPE',
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END GET_NOTIF_TYPE;

--{

-- Rel 12 HBHAGAVA
PROCEDURE LOG_HISTORY(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS
--{


l_api_name              CONSTANT VARCHAR2(30)   := 'LOG_HISTORY';
l_api_version           CONSTANT NUMBER         := 1.0;

l_trip_id		NUMBER;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;

l_tender_status		VARCHAR2(30);
l_rank_id		NUMBER;
l_rank_version		NUMBER;
l_shipper_name		VARCHAR2(100);
l_shipper_id		NUMBER;
l_carrier_contact_name	VARCHAR2(100);
l_carrier_contact_id	NUMBER;


l_delivery_leg_activity_rec FTE_DELIVERY_ACTIVITY.delivery_leg_activity_rec;


l_return_status	VARCHAR2(30000);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_msg_string	VARCHAR2(30000);


BEGIN


   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --


 	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');
 	l_tender_status	:= wf_engine.GetItemAttrText(itemtype,itemkey,'TENDER_STATUS');
	l_rank_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'RANK_ID');
	l_rank_version  := wf_engine.GetItemAttrNumber(itemtype,itemkey,'RANK_VERSION');

	IF l_debug_on
	THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' TEnder status ' || l_tender_status,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


 	IF (l_tender_status = FTE_TENDER_PVT.S_TENDERED OR
 	    l_tender_status = FTE_TENDER_PVT.S_SHIPPER_CANCELLED OR
 	    l_tender_status = FTE_TENDER_PVT.S_AUTO_ACCEPTED OR
 	    l_tender_status = FTE_TENDER_PVT.S_NORESPONSE OR
 	    l_tender_status = FTE_TENDER_PVT.S_SHIPPER_UPDATED)
 	THEN
		l_delivery_leg_activity_rec.action_by :=
				wf_engine.GetItemAttrNumber(itemtype,itemkey,'SHIPPER_USER_ID');
		l_delivery_leg_activity_rec.action_by_name :=
				wf_engine.GetItemAttrText(itemtype,itemkey,'SHIPPER_NAME');
	ELSE
		l_delivery_leg_activity_rec.action_by :=
				wf_engine.GetItemAttrNumber(itemtype,itemkey,'CONTACT_USER_ID');
		l_delivery_leg_activity_rec.action_by_name :=
				wf_engine.GetItemAttrText(itemtype,itemkey,'CONTACT_USER_NAME');
		l_delivery_leg_activity_rec.remarks	:=
				wf_engine.GetItemAttrText(itemtype,itemkey,'CARRIER_REMARKS');

 	END IF;

	-- For shipper update item key is different. so we have to get the original
	-- tender wf item key.
	IF (l_tender_status = FTE_TENDER_PVT.S_SHIPPER_UPDATED)
	THEN
		SELECT WF_ITEM_KEY INTO l_delivery_leg_activity_rec.wf_item_key
		FROM WSH_TRIPS
		WHERE TRIP_ID = l_trip_id;
	ELSE
		l_delivery_leg_activity_rec.wf_item_key	:=	itemkey;
	END IF;


	l_delivery_leg_activity_rec.trip_id	:=	l_trip_id;
	l_delivery_leg_activity_rec.activity_type := l_tender_status;
	l_delivery_leg_activity_rec.rank_id	:= l_rank_id;
	l_delivery_leg_activity_rec.rank_version := l_rank_version;


	FTE_DELIVERY_ACTIVITY.ADD_HISTORY(
		p_init_msg_list           => FND_API.G_FALSE,
		p_trip_id		  => l_trip_id,
		p_delivery_leg_activity_rec => l_delivery_leg_activity_rec,
	        x_return_status           => l_return_status,
		x_msg_count               => l_msg_count,
		x_msg_data                => l_msg_data);


	IF ( (l_return_status = 'E')
	OR   (l_return_status = 'U') )
	THEN
		l_msg_string := 'LOG_HISTORY :-> Tender Id ='||to_char(l_trip_id)||' :'||
				FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;



  	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;
--}

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      l_api_name,
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END LOG_HISTORY;

--}

--{

-- Rel 12 HBHAGAVA
PROCEDURE RAISE_XML_OUTBOUND(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS
--{


l_api_name              CONSTANT VARCHAR2(30)   := 'RAISE_XML_OUTBOUND';
l_api_version           CONSTANT NUMBER         := 1.0;

l_trip_id		NUMBER;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


BEGIN


   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --
	resultout := 'COMPLETE:Y';
  	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;
--}

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      l_api_name,
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END RAISE_XML_OUTBOUND;

-- Rel 12 HBHAGAVA
PROCEDURE EXPAND_RANK_LIST(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS
--{


l_api_name              CONSTANT VARCHAR2(30)   := 'EXPAND_RANK_LIST';
l_api_version           CONSTANT NUMBER         := 1.0;

l_trip_id		NUMBER;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;

p_FTE_SS_ATTR_REC	FTE_SS_ATTR_REC;

l_LIST_CREATE_TYPE		VARCHAR2(10);
l_SS_RATE_SORT_TAB		FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_appendFlag		VARCHAR2(1);
l_ruleId		NUMBER;

l_return_status	VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_number_of_warnings	NUMBER;
l_number_of_errors	NUMBER;
l_msg_string	VARCHAR2(30000);

l_RATING_REQUEST_ID	NUMBER;

l_arr_date DATE;
l_dept_date DATE;
l_first_stop_id NUMBER;
l_last_stop_id NUMBER;
l_first_stop_loc_id NUMBER;
l_last_stop_loc_id NUMBER;


BEGIN


   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --

	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


 	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');

	SELECT APPEND_FLAG,ROUTING_RULE_ID INTO l_appendFlag, l_ruleId
	FROM WSH_TRIPS
	WHERE TRIP_ID = l_trip_id;

	-- We have to query first stop, last stop information to populate on to
	-- trip
	FTE_MLS_UTIL.GET_FIRST_LAST_STOP_INFO(x_return_status          => l_return_status,
			    x_arrival_date	     => l_arr_date,
			    x_departure_date	     => l_dept_date,
			    x_first_stop_id	     => l_first_stop_id,
			    x_last_stop_id	     => l_last_stop_id,
			    x_first_stop_loc_id	     => l_first_stop_loc_id,
			    x_last_stop_loc_id	     => l_last_stop_loc_id,
			    p_trip_id		     => l_trip_id);

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);

	IF ( (l_return_status = 'E')
	OR   (l_return_status = 'U') )
	THEN
		l_msg_string := 'FTE_MSL_UTIL.GET_FIRST_LAST_STOP_INFO :-> Tender Id ='||to_char(l_trip_id)||
					' :'||FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;


	p_FTE_SS_ATTR_REC	:= FTE_SS_ATTR_REC(null,
					null,
					l_trip_id,
				   	l_arr_date,l_arr_date,
				   	l_dept_date, -- DEP_DATE_TO
				   	l_dept_date,
				   	l_first_stop_loc_id,
				   	l_last_stop_loc_id,
				   	l_first_stop_id,
				   	l_last_stop_id,
				   	l_first_stop_loc_id, -- PICK_UP_STOP_LOCATION_ID,
				   	l_last_stop_loc_id,
				   	null,null,null,--Carrier
				   	null,null,
				   	null,null,l_ruleId,--rule id
				   	null,l_appendFlag);


	FTE_SS_INTERFACE.SEARCH_SERVICES(
		P_INIT_MSG_LIST			=> FND_API.G_FALSE,
		P_API_VERSION_NUMBER		=> 1.0,
		P_COMMIT			=> FND_API.G_FALSE,
		P_CALLER			=> FTE_SS_INTERFACE.S_CALLER_WF,
		P_FTE_SS_ATTR_REC		=> p_FTE_SS_ATTR_REC,
		X_RATING_REQUEST_ID		=> l_rating_request_id,
		X_LIST_CREATE_TYPE		=> l_LIST_CREATE_TYPE,
		X_SS_RATE_SORT_TAB		=> l_SS_RATE_SORT_TAB,
		x_return_status			=> l_return_status,
		x_msg_count			=> l_msg_count,
		x_msg_data			=> l_msg_data);

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);

	IF ( (l_return_status = 'E')
	OR   (l_return_status = 'U') )
	THEN
		l_msg_string := 'FTE_SS_INTERFACE.SEARCH_SERIVCE :-> Tender Id ='||to_char(l_trip_id)||
					' :'||FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;


--	wf_core.TOKEN('ERROR_STRING','Test Error MEssage ');
--	wf_core.RAISE('FTE_WF_ERROR_MESSAGE');


        wf_engine.SetItemAttrText(itemtype	=>	itemtype,
				itemkey		=>	itemkey,
				aname		=>	'PRICE_REQUEST_ID',
				avalue		=>	l_rating_request_id);

	resultout := 'COMPLETE:Y';
  	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;
--}

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      l_api_name,
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END EXPAND_RANK_LIST;

--}
-- Rel 12 HBHAGAVA
PROCEDURE IS_RANK_LIST_EXHAUSTED(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS
--{


l_api_name              CONSTANT VARCHAR2(30)   := 'IS_RANK_LIST_EXHAUSTED';
l_api_version           CONSTANT NUMBER         := 1.0;

l_trip_id		NUMBER;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;

l_is_exhausted		VARCHAR2(10);

l_return_status	VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_number_of_warnings	NUMBER;
l_number_of_errors	NUMBER;
l_msg_string	VARCHAR2(30000);

BEGIN


   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

 	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');

	IF l_debug_on
	THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Trip Id ' || l_trip_id,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	FTE_CARRIER_RANK_LIST_PVT.IS_RANK_LIST_EXHAUSTED(
		p_init_msg_list	        => FND_API.G_TRUE,
		x_is_exhausted		=> l_is_exhausted,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		p_trip_id		=> l_trip_id);


	IF l_debug_on
	THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' After calling IS_RANK_LIST_EXHAUSTED ' ||
				l_is_exhausted,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	IF ( (l_return_status = 'E')
	OR   (l_return_status = 'U') )
	THEN
		l_msg_string := 'FTE_SS_INTERFACE.IS_RANK_LIST_EXHAUSTED :-> Tender Id ='||to_char(l_trip_id)||
					' :'||FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;

	IF l_debug_on
	THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Returning back value ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF (l_is_exhausted = 'T')
	THEN
		resultout := 'COMPLETE:Y';
	ELSE
		resultout := 'COMPLETE:N';
	END IF;

  	return;

   END IF; --- func mode

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      return;
   END IF;
--}

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      l_api_name,
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END IS_RANK_LIST_EXHAUSTED;

--}
-- Rel 12 HBHAGAVA
PROCEDURE REMOVE_SERVICE_APPLY_NEXT(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS
--{


l_api_name              CONSTANT VARCHAR2(30)   := 'REMOVE_SERVICE_APPLY_NEXT';
l_api_version           CONSTANT NUMBER         := 1.0;

l_trip_id		NUMBER;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;

l_priceRequestId		NUMBER;

l_return_status	VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_number_of_warnings	NUMBER;
l_number_of_errors	NUMBER;
l_msg_string	VARCHAR2(30000);

BEGIN


   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --

	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

 	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');
 	l_priceRequestId := wf_engine.GetItemAttrNumber(itemtype,itemkey,'PRICE_REQUEST_ID');

	FTE_CARRIER_RANK_LIST_PVT.REMOVE_SERVICE_APPLY_NEXT(
		p_init_msg_list	        => FND_API.G_TRUE,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		p_trip_id		=> l_trip_id,
		p_price_request_id	=> l_priceRequestId);

	IF ( (l_return_status = 'E')
	OR   (l_return_status = 'U') )
	THEN
		l_msg_string := 'FTE_CARRIER_RANK_LIST_PVT.REMOVE_SERVICE_APPLY_NEXT :-> Tender Id ='||to_char(l_trip_id)||
					' :'||FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
		wf_core.TOKEN('ERROR_STRING',l_msg_string);
		wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
	END IF;

	resultout := 'COMPLETE:Y';

  	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;
--}

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      l_api_name,
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END REMOVE_SERVICE_APPLY_NEXT;

--}
-- Rel 12 HBHAGAVA
PROCEDURE AUTO_TENDER_SERVICE(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS
--{


l_api_name              CONSTANT VARCHAR2(30)   := 'AUTO_TENDER_SERVICE';
l_api_version           CONSTANT NUMBER         := 1.0;

l_trip_id		NUMBER;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status	VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(30000);
l_number_of_warnings	NUMBER;
l_number_of_errors	NUMBER;
l_msg_string	VARCHAR2(30000);
l_carrier_id	NUMBER;
l_autoTender	VARCHAR2(1);

trip_action_param FTE_TRIP_ACTION_PARAM_REC;
l_action_out_rec	FTE_ACTION_OUT_REC;


BEGIN


   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      --

	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

 	l_trip_id	:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'TRIP_ID');


 	SELECT CARRIER_ID INTO l_carrier_id FROM WSH_TRIPS
 	WHERE TRIP_ID = l_trip_id;

        SELECT decode(ENABLE_AUTO_TENDER,null,'N','N','N','Y') AUTO_TENDER
        INTO l_autoTender
        FROM WSH_CARRIER_SITES
        WHERE CARRIER_ID = l_carrier_id
        AND ROWNUM = 1;

	IF (l_autoTender = 'N') THEN
		resultout := 'COMPLETE:N';
	ELSE

		trip_action_param := FTE_TRIP_ACTION_PARAM_REC(null,'TENDERED',
						null,null,null,null,null,null,
						null,null,null,null,null,null,
						null,null);

		FTE_MLS_WRAPPER.Trip_Action (
			p_api_version_number     => 1.0,
			p_init_msg_list          => FND_API.G_TRUE,
			x_return_status          => l_return_status,
			x_msg_count              => l_msg_count,
			x_msg_data               => l_msg_data,
			x_action_out_rec	 => l_action_out_rec,
			p_tripId	     	 => l_trip_id,
			p_action_prms	     	 => trip_action_param);


		IF ( (l_return_status = 'E')
		OR   (l_return_status = 'U') )
		THEN
			l_msg_string := 'FTE_MLS_WRAPPER.TRIP_ACTION :-> Tender Id ='||to_char(l_trip_id)||
						' :'||FTE_MLS_UTIL.GET_MESSAGE(l_msg_count,l_msg_data);
			wf_core.TOKEN('ERROR_STRING',l_msg_string);
			wf_core.RAISE('FTE_WF_ERROR_MESSAGE');
		END IF;

		resultout := 'COMPLETE:Y';

	END IF;

  	return;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;
--}

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      l_api_name,
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
      RAISE;

END AUTO_TENDER_SERVICE;

--}

-- Rel 12 HBHAGAVA
PROCEDURE FTETENDER_SELECTOR(itemtype  in  varchar2,
                       itemkey   in  varchar2,
                       actid     in  number,
                       funcmode  in  varchar2,
                       resultout out NOCOPY varchar2) IS
--{


l_api_name              CONSTANT VARCHAR2(30)   := 'FTETENDER_SELECTOR';
l_api_version           CONSTANT NUMBER         := 1.0;

l_trip_id		NUMBER;

l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


  l_userId              NUMBER;
  l_respId              NUMBER;
  l_respAppId           NUMBER;


BEGIN


   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
	resultout := 'COMPLETE:Y';
   ELSIF (funcmode = 'SET_CTX') THEN

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

    l_userId    := wf_engine.GetItemAttrNumber(itemtype,itemKey,'USER_ID');
    l_respAppId := wf_engine.GetItemAttrNumber(itemtype,itemKey, 'RESP_APPL_ID');
    l_respId    := wf_engine.GetItemAttrNumber(itemtype,itemKey,'RESPONSIBILITY_ID');

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,' Initializing responsiblity information ' ||
						l_userId,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


    IF(l_respAppId IS NULL OR l_respId IS NULL) THEN
      RAISE no_data_found;
    ELSE
      FND_GLOBAL.Apps_Initialize(l_userId, l_respId, l_respAppId);
    END IF;
    --
    resultout := 'COMPLETE';


	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

   END IF; --- func mode


   --
   -- CANCEL mode
   --
   IF (funcmode = 'CANCEL') THEN
      resultout := 'COMPLETE:';

      return;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
      resultout := 'COMPLETE:';
      --wsh_debug_sv.pop(l_api_name);
      return;
   END IF;
--}

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('FTE_TENDER_WF',
                      l_api_name,
                      itemtype,
                      itemkey,
                      actid,
                      funcmode,
                      itemtype);
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

      RAISE;

END FTETENDER_SELECTOR;

--}


END FTE_TENDER_WF;

/
