--------------------------------------------------------
--  DDL for Package Body WSH_AUTO_MANIFEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_AUTO_MANIFEST" as
/* $Header: WSHAUMNB.pls 120.3.12010000.3 2009/12/03 14:34:30 anvarshn ship $ */

--
-- PROCEDURE:         Submit
-- Purpose:           Submit Automated Carrier Manifesting based on given criteria.
-- Description:       This procedure  is called by Concurrent Program to submit request for Automated
--                    Carrier Manifesting. This works as a wrapper to the main procedure
--                    Process_Auto_Manifest for Automated  Carrier Manifesting.
--
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_AUTO_MANIFEST';
--
PROCEDURE Submit (
        errbuf                  OUT NOCOPY      VARCHAR2,
        retcode                 OUT NOCOPY      VARCHAR2,
        --R12.1.1 STANDALONE PROJECT added dummy parameter
        p_standalone_mode       IN      VARCHAR2,
        -- K proj
        p_doctype               IN      VARCHAR2,
        p_shipment_type         IN      VARCHAR2,
        p_deploy_mode           IN      VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
        p_set_org               IN      NUMBER,
        p_client_id             IN      NUMBER, -- Modified R12.1.1 LSP PROJECT(rminocha)
        p_organization_id       IN      NUMBER,
        -- K proj
        p_src_header_num_from   IN      VARCHAR2,
        p_src_header_num_to     IN      VARCHAR2,
        --R12.1.1 STANDALONE PROJECT
        p_del_name_from         IN      VARCHAR2,
        p_del_name_to           IN      VARCHAR2,
        p_carrier_id            IN      NUMBER,
        p_customer_id           IN      NUMBER,
        p_customer_ship_to_id   IN      NUMBER,
        p_scheduled_from_date   IN      VARCHAR2,
        p_scheduled_to_date     IN      VARCHAR2,
        p_set_auto_pack         IN      NUMBER,
        p_autopack              IN      VARCHAR2,
        p_log_level             IN      NUMBER
    ) IS

 l_return_status     	VARCHAR2(1);
 l_temp              	BOOLEAN;
 l_message_level	NUMBER;
 --K proj
 l_warning_count        NUMBER := 0;
 l_error_count          NUMBER := 0;
 l_otm_installed VARCHAR2(1) ;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SUBMIT';
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
  IF (p_doctype = 'SA') --{ K proj
    OR
     ((p_doctype = 'SR')
       AND ((p_shipment_type IS NULL) OR (p_shipment_type = 'TPW') OR (p_shipment_type = 'BOTH')))  THEN
     Process_Auto_Manifest (
           p_organization_id       => p_organization_id,
           p_carrier_id            => p_carrier_id,
           p_customer_id           => p_customer_id,
           p_customer_ship_to_id   => p_customer_ship_to_id,
           p_scheduled_from_date   => FND_DATE.canonical_to_date(p_scheduled_from_date),
           p_scheduled_to_date     => FND_DATE.canonical_to_date(p_scheduled_to_date),
           p_autopack              => p_autopack,
           p_log_level             => p_log_level,
           x_return_status         => l_return_status,
           p_shipment_type         => p_shipment_type,
           p_doctype               => p_doctype,
           p_src_header_num_from   => p_src_header_num_from,
           p_src_header_num_to     => p_src_header_num_to,
           --R12.1.1 STANDALONE PROJECT
           p_del_name_from         => p_del_name_from,
           p_del_name_to           => p_del_name_to,
           p_client_id             => p_client_id -- Modified R12.1.1 LSP PROJECT(rminocha)
           );

           wsh_util_core.api_post_call
           (
              p_return_status => l_return_status,
              x_num_warnings  => l_warning_count,
              x_num_errors    => l_error_count,
              p_raise_error_flag => FALSE
            );

  END IF; --}
  IF  ((p_doctype = 'SR')
       AND ((p_shipment_type IS NULL) OR (p_shipment_type = 'CMS') OR
            (p_shipment_type = 'BOTH')))  THEN --{
     l_otm_installed := WSH_UTIL_CORE.GC3_Is_Installed;
     IF l_otm_installed = 'N' THEN --{
        Process_Auto_Manifest (
           p_organization_id       => p_organization_id,
           p_carrier_id            => p_carrier_id,
           p_customer_id           => p_customer_id,
           p_customer_ship_to_id   => p_customer_ship_to_id,
           p_scheduled_from_date   =>
                            FND_DATE.canonical_to_date(p_scheduled_from_date),
           p_scheduled_to_date     =>
                            FND_DATE.canonical_to_date(p_scheduled_to_date),
           p_autopack              => p_autopack,
           p_log_level             => p_log_level,
           x_return_status         => l_return_status,
           p_shipment_type         => 'CMS',
           p_doctype               => p_doctype,
           p_src_header_num_from   => p_src_header_num_from,
           p_src_header_num_to     => p_src_header_num_to,

           --R12.1.1 STANDALONE PROJECT
           p_del_name_from         => p_del_name_from,
           p_del_name_to           => p_del_name_to,
           p_client_id           => p_client_id -- Modified R12.1.1 LSP PROJECT(rminocha)
           );

           wsh_util_core.api_post_call
              (
                 p_return_status => l_return_status,
                 x_num_warnings  => l_warning_count,
                 x_num_errors    => l_error_count,
                 p_raise_error_flag => FALSE
               );
        END IF; --}
  END IF; --}

  IF l_error_count > 0
  THEN
      l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF l_warning_count > 0
  THEN
      l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
      l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;


        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', '');
            --errbuf := 'Automated Carrier Manifesting is completed Successfully';
            FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_NORMAL');
            errbuf := FND_MESSAGE.GET;
            retcode := '0';
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS( 'WARNING', '');
            --errbuf :=  'Automated Carrier Manifesting is completed with Warning';
            FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_WARNING');
            errbuf := FND_MESSAGE.GET;
            retcode := '1';
        ELSE
            l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', '');
            --errbuf := 'Automated Carrier Manifesting submission is completed with Error';
            FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_ERROR');
            errbuf := FND_MESSAGE.GET;
            retcode := '2';
        END IF;

EXCEPTION

  WHEN others THEN
    l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', '');
    --errbuf := 'Automated Carrier Manifesting submission is completed with Unexpected Error: '||sqlerrm;
    FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_UNEXP');
    FND_MESSAGE.SET_TOKEN('ERR_MSG', sqlerrm);
    errbuf := FND_MESSAGE.GET;
    retcode := '2';

END Submit;


--
-- PROCEDURE  : Process_Auto_Manifest
-- Description: This is the main procedure for Automated  Carrier Manifesting System,
--              which is called by procedure submit.
--
PROCEDURE Process_Auto_Manifest (
        p_organization_id       IN      NUMBER,
        p_carrier_id            IN      NUMBER,
        p_customer_id           IN      NUMBER,
        p_customer_ship_to_id   IN      NUMBER,
        p_scheduled_from_date   IN      DATE,
        p_scheduled_to_date     IN      DATE,
        p_autopack              IN      VARCHAR2 DEFAULT 'N',
        p_log_level             IN      NUMBER DEFAULT 0,
        x_return_status         OUT NOCOPY      VARCHAR2,
        p_shipment_type         IN      VARCHAR2,
        p_doctype               IN      VARCHAR2,
        p_src_header_num_from   IN      VARCHAR2,
        p_src_header_num_to     IN      VARCHAR2,
        -- R12.1.1 STANDALONE PROJECT
        p_del_name_from         IN      VARCHAR2,
        p_del_name_to           IN      VARCHAR2,
        p_client_id             IN      NUMBER -- Modified R12.1.1 LSP PROJECT(rminocha)
        ) IS

  -- R12.1.1 STANDALONE PROJECT

 CURSOR c_stnd_shipment_advice_del IS
   SELECT distinct wnd.organization_id
                   ,wnd.delivery_id
                   ,wnd.carrier_id
                   ,wnd.customer_id
                   ,wnd.ultimate_dropoff_location_id ship_to_id
   FROM   wsh_new_deliveries wnd
        , wsh_delivery_assignments_v wdav
        , wsh_delivery_details wdd
   WHERE  nvl(wnd.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO')
   AND  wdav.delivery_id = wnd.delivery_id
   AND  wdd.delivery_detail_id = wdav.delivery_detail_id
   AND  wnd.pending_advice_flag = 'Y'
   AND  ((p_src_header_num_from IS NOT NULL
          AND wdd.source_header_number >= p_src_header_num_from)
          OR (p_src_header_num_from IS NULL))
   AND  ((p_src_header_num_to IS NOT NULL
          AND wdd.source_header_number <= p_src_header_num_to)
          OR (p_src_header_num_to IS NULL))
   AND wnd.status_code IN ('CL', 'IT', 'CO')
   AND wnd.DELIVERY_TYPE <> 'CONSOLIDATION'
   AND ((p_organization_id IS NOT NULL AND wnd.organization_id = p_organization_id)
       OR (P_organization_id IS NULL))
   AND (( p_carrier_id IS NULL )
       OR ( p_carrier_id IS NOT NULL AND wnd.carrier_id = p_carrier_id))
   AND ((p_customer_id IS NULL)
       OR ((p_customer_id IS NOT NULL) AND (wnd.customer_id = p_customer_id)))
   AND wnd.ultimate_dropoff_location_id = nvl(p_customer_ship_to_id,ultimate_dropoff_location_id)
   AND ((p_scheduled_from_date IS NULL )
       OR (wnd.confirm_date >=  p_scheduled_from_date))
   AND ((p_scheduled_to_date IS NULL)
       OR (wnd.confirm_date  <= p_scheduled_to_date))
   AND ((p_del_name_from IS NOT NULL
        AND wnd.name >= p_del_name_from)
        OR (p_del_name_from IS NULL))
   AND ((p_del_name_to IS NOT NULL
        AND wnd.name <= p_del_name_to)
        OR (p_del_name_to IS NULL))
   AND  ((p_client_id IS NULL )
        OR ( (p_client_id IS NOT NULL) AND (wnd.client_id = p_client_id  ))) -- Modified R12.1.1 LSP PROJECT
   AND NOT EXISTS (
                   SELECT entity_number
                   FROM wsh_transactions_history wth2
                   WHERE wth2.entity_number = wnd.name
                   AND wth2.document_type = 'SA'
		   AND wth2.entity_type = 'DLVY'
		   AND wth2.document_direction = 'O'
                  ) ;

 --k proj
 CURSOR c_shipment_advice_del IS
   SELECT distinct wnd.organization_id
                  ,wnd.delivery_id
                  ,wnd.carrier_id
                  ,wnd.customer_id
                  ,wnd.ultimate_dropoff_location_id ship_to_id
   FROM  wsh_new_deliveries wnd
        , wsh_transactions_history wth
        , wsh_delivery_assignments_v wdav
        , wsh_delivery_details wdd
   WHERE  nvl(wnd.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO')
   AND  wdav.delivery_id = wnd.delivery_id
   AND  wdd.delivery_detail_id = wdav.delivery_detail_id
   --R12.1.1 STANDALONE PROJECT
   AND  wnd.pending_advice_flag = 'Y'
   AND  ((p_src_header_num_from IS NOT NULL
          AND wdd.source_header_number >= p_src_header_num_from)
         OR (p_src_header_num_from IS NULL))
   AND  ((p_src_header_num_to IS NOT NULL
          AND wdd.source_header_number <= p_src_header_num_to)
         OR (p_src_header_num_to IS NULL))
   AND    wnd.status_code in ('CL', 'IT', 'CO')
   AND    wnd.DELIVERY_TYPE <> 'CONSOLIDATION'
   AND ( ( p_organization_id   is not null
   AND  wnd.organization_id = p_organization_id)
       OR  (P_organization_id is null))
   AND  (( p_carrier_id is null )
       OR ( p_carrier_id is not null AND wnd.carrier_id = p_carrier_id))
   AND   ((p_customer_id IS NULL)
       OR ((p_customer_id IS NOT NULL) AND (wnd.customer_id = p_customer_id)))
   AND    wnd.ultimate_dropoff_location_id =
                   nvl(p_customer_ship_to_id,ultimate_dropoff_location_id)
   AND  ((p_scheduled_from_date IS NULL )
       OR  (wnd.confirm_date >=  p_scheduled_from_date))
   AND ((p_scheduled_to_date IS NULL)
       OR (wnd.confirm_date  <= p_scheduled_to_date))
   AND wth.entity_number =  wnd.name
   AND wth.document_direction = 'I'
   AND wth.document_type = 'SR'
   AND wth.entity_type = 'DLVY'
   --R12.1.1 STANDALONE PROJECT
   AND  ((p_del_name_from IS NOT NULL
          AND wnd.name >= p_del_name_from)
         OR (p_del_name_from IS NULL))
   AND  ((p_del_name_to IS NOT NULL
          AND wnd.name <= p_del_name_to)
         OR (p_del_name_to IS NULL))
   AND  ((p_client_id IS NULL )
        OR ( (p_client_id IS NOT NULL) AND (wnd.client_id = p_client_id  ))) -- Modified R12.1.1 LSP PROJECT
   AND NOT EXISTS (
                   SELECT entity_number
                   from wsh_transactions_history wth2
                   WHERE wth2.entity_number = wnd.name
                   AND wth2.document_type = 'SA'
                  ) ;

 CURSOR c_sr_cms_del IS
   SELECT distinct wnd.organization_id
   ,wnd.delivery_id
   ,wnd.carrier_id
   ,wnd.customer_id
   ,wnd.ultimate_dropoff_location_id ship_to_id
   FROM   wsh_delivery_details wdd,
   wsh_delivery_assignments_v wda,
   wsh_new_deliveries wnd,
   mtl_parameters mtl,
   wsh_carriers  wc
   WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
   AND    wda.delivery_id = wnd.delivery_id
   AND    wda.delivery_detail_id = wdd.delivery_detail_id
   AND  ((p_src_header_num_from IS NOT NULL
          AND wdd.source_header_number >= p_src_header_num_from)
         OR (p_src_header_num_from IS NULL))
   AND  ((p_src_header_num_to IS NOT NULL
          AND wdd.source_header_number <= p_src_header_num_to)
         OR (p_src_header_num_to IS NULL))
   AND    nvl(wnd.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO')
   AND    wdd.container_flag = 'N'
   AND    wnd.organization_id = NVL(p_organization_id , wnd.organization_id)
   AND    wnd.organization_id= mtl.organization_id
   AND    wnd.DELIVERY_TYPE <> 'CONSOLIDATION'
   AND    mtl.CARRIER_MANIFESTING_FLAG = 'Y'
   AND    wdd.released_status in ('X','Y')
   AND    wnd.status_code='OP'
   AND    wc.carrier_id = wnd.carrier_id
   AND    wc.MANIFESTING_ENABLED_FLAG = 'Y'
   AND    NVL(p_carrier_id, wnd.carrier_id ) = wnd.carrier_id
   AND    wnd.customer_id = nvl(p_customer_id,wnd.customer_id)
   AND    wnd.ultimate_dropoff_location_id =
                  nvl(p_customer_ship_to_id,ultimate_dropoff_location_id)
   AND    wda.delivery_id IS NOT NULL
   AND  ((p_scheduled_from_date IS NULL )
      OR  (wnd.initial_pickup_date >=  p_scheduled_from_date))
   AND ((p_scheduled_to_date IS NULL)
      OR ( wnd.initial_pickup_date  <= p_scheduled_to_date))
   AND  ((p_client_id IS NULL )
      OR ( (p_client_id IS NOT NULL) AND (wnd.client_id = p_client_id  ))) -- Modified R12.1.1 LSP PROJECT
      ;

 CURSOR c_sr_tpw_del IS
   SELECT distinct wnd.organization_id,
    wnd.delivery_id
   ,wnd.carrier_id
   ,wnd.customer_id
   ,wnd.ultimate_dropoff_location_id ship_to_id
   FROM   wsh_delivery_details wdd,
   wsh_delivery_assignments_v wda,
   wsh_new_deliveries wnd,
   mtl_parameters mtl
   WHERE  wdd.delivery_detail_id = wda.delivery_detail_id
   AND    wda.delivery_id = wnd.delivery_id
   AND    nvl(wnd.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO')
   AND    wdd.container_flag = 'N'
   AND  ((p_src_header_num_from IS NOT NULL
          AND wdd.source_header_number >= p_src_header_num_from)
         OR (p_src_header_num_from IS NULL))
   AND  ((p_src_header_num_to IS NOT NULL
          AND wdd.source_header_number <= p_src_header_num_to)
         OR (p_src_header_num_to IS NULL))
   AND    wnd.organization_id = NVL(p_organization_id , wnd.organization_id)
   AND    wnd.organization_id= mtl.organization_id
   AND    mtl.DISTRIBUTED_ORGANIZATION_FLAG ='Y'
   AND    wdd.released_status in ('X','R','B')
   AND    wnd.status_code='OP'
   AND    wnd.DELIVERY_TYPE <> 'CONSOLIDATION'
   AND    (  ( p_carrier_id is null)
           OR  (p_carrier_id IS NOT NULL AND wnd.carrier_id = p_carrier_id))
   AND    wnd.customer_id = nvl(p_customer_id,wnd.customer_id)
   AND    wnd.ultimate_dropoff_location_id =
              nvl(p_customer_ship_to_id,ultimate_dropoff_location_id)
   AND    wda.delivery_id IS NOT NULL
   AND  ((p_scheduled_from_date IS NULL )
          OR  (wnd.initial_pickup_date >=  p_scheduled_from_date))
   AND ((p_scheduled_to_date IS NULL)
          OR ( wnd.initial_pickup_date  <= p_scheduled_to_date))
   AND  ((p_client_id IS NULL )
        OR ( (p_client_id IS NOT NULL) AND (wnd.client_id = p_client_id  ))) -- Modified R12.1.1 LSP PROJECT
          ;

 CURSOR get_carrier_name(pc_carrier_id NUMBER) IS
  SELECT party_name
  FROM   wsh_carriers, hz_parties
  WHERE  carrier_id =party_id (+)
  AND    carrier_id= pc_carrier_id;

 CURSOR get_customer_name(pc_customer_id NUMBER) IS
  SELECT HP.PARTY_NAME
  FROM   HZ_CUST_ACCOUNTS HCA, HZ_PARTIES HP
  WHERE  HP.PARTY_ID = HCA.PARTY_ID
  AND    HP.PARTY_ID = pc_customer_id;

/*Patchset I: Locations Project. Use ui_location_code from wsh_customer_locations_v */

 CURSOR get_location(pc_location_id NUMBER) IS
  SELECT wclv.ui_location_code
  FROM
         wsh_customer_locations_v wclv
  WHERE  wclv.wsh_location_id = pc_location_id
  AND    wclv.customer_status = 'A'
  AND    wclv.cust_acct_site_status = 'A'
  AND    wclv.site_use_status = 'A'
  AND    wclv.site_use_code  = 'SHIP_TO';

 l_carrier_name		VARCHAR2(80);
 l_customer_name	VARCHAR2(80);
 l_location		VARCHAR2(200);
 l_autopack		VARCHAR2(5);

 l_entity_ids 		WSH_UTIL_CORE.id_tab_type;
 l_con_ids 		WSH_UTIL_CORE.id_tab_type;
 l_err_entity_ids 	WSH_UTIL_CORE.id_tab_type;
 l_cont_inst_tab        WSH_UTIL_CORE.id_tab_type;
 l_group_id_tab 	WSH_UTIL_CORE.id_tab_type;
 l_success_delivery     WSH_AUTO_MANIFEST.tab_delivery_msg;
 l_success_count        NUMBER := 0;
 l_error_delivery       WSH_AUTO_MANIFEST.tab_delivery_msg;
 l_error_count          NUMBER := 0;
 l_warning_delivery     WSH_AUTO_MANIFEST.tab_delivery_msg;
 l_warning_count	NUMBER := 0;
 l_warning_index	NUMBER;
 l_delivery_count	NUMBER := 0;

 l_calling_api		VARCHAR2(500);

 l_delivery_status	VARCHAR2(10):='SUCCESS';
 l_validate		VARCHAR2(1);
 l_return_status 	VARCHAR2(1);
 l_msg_summary 		VARCHAR2(3000);
 l_msg_details 		VARCHAR2(3000);
 l_msg_data 		VARCHAR2(3000);
 l_msg_count   		NUMBER;
 /*Modified R12.1.1 LSP PROJECT*/
  l_client_id NUMBER;
  l_client_code  VARCHAR2(10);
  l_client_name  VARCHAR2(50);
  /*Modified R12.1.1 LSP PROJECT*/
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_AUTO_MANIFEST';
--
--Bugfix 4070732
l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
l_reset_flags BOOLEAN;
--k proj
 l_cur_rec               WSH_AUTO_MANIFEST.t_shipment_rec;

BEGIN
  --
  -- Bug 4070732
  IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN
     WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
     WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
  END IF;

  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  wsh_debug_sv.start_debug;

  IF l_debug_on THEN
     wsh_debug_sv.push (l_module_name);
     wsh_debug_sv.log(l_module_name,'Parameters');
     wsh_debug_sv.log(l_module_name,'==========');
     wsh_debug_sv.log (l_module_name,'p_organization_id',to_char(p_organization_id));
     wsh_debug_sv.log (l_module_name,'p_carrier_id',to_char(p_carrier_id));
     wsh_debug_sv.log (l_module_name,'p_customer_id',to_char(p_customer_id));
     wsh_debug_sv.log (l_module_name,'p_customer_ship_to_id',to_char(p_customer_ship_to_id));
     wsh_debug_sv.log (l_module_name,'p_scheduled_from_date',p_scheduled_from_date);
     wsh_debug_sv.log (l_module_name,'p_scheduled_to_date',p_scheduled_to_date);
     wsh_debug_sv.log (l_module_name,'p_autopack',p_autopack);
     wsh_debug_sv.log (l_module_name,'p_log_level',p_log_level);
     wsh_debug_sv.log (l_module_name,'p_shipment_type',p_shipment_type);
     wsh_debug_sv.log (l_module_name,'p_doctype',p_doctype);
     wsh_debug_sv.log (l_module_name,'p_src_header_num_from'
                                                   ,p_src_header_num_from);
     wsh_debug_sv.log (l_module_name,'p_src_header_num_to'
                                                   ,p_src_header_num_to);

     wsh_debug_sv.log (l_module_name,'p_del_name_from'
                                                   ,p_del_name_from);
     wsh_debug_sv.log (l_module_name,'p_del_name_to'
                                                   ,p_del_name_to);
     wsh_debug_sv.log (l_module_name,'p_client_id',p_client_id); -- Modified R12.1.1 LSP PROJECT
  END IF;



   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name, 'Begining of FOR LOOP');
   END IF;
   --Open the cursor based on p_shipment_type and p_doctype
   IF p_doctype = 'SA' THEN

      -- R12.1.1 STANDALONE PROJECT
      IF p_shipment_type = 'STND' THEN
         OPEN c_stnd_shipment_advice_del;
      ELSE
         OPEN c_shipment_advice_del;
      END IF;
      --
   ELSIF p_shipment_type = 'TPW' THEN
      OPEN c_sr_tpw_del;
   ELSE
      OPEN c_sr_cms_del;
   END IF;
   LOOP --Begin of the loop {
   --R12.1.1 STANDALONE PROJECT
   IF c_stnd_shipment_advice_del%ISOPEN THEN
      FETCH c_stnd_shipment_advice_del INTO l_cur_rec;
      --
      IF c_stnd_shipment_advice_del%NOTFOUND THEN
         CLOSE c_stnd_shipment_advice_del;
         EXIT;
      END IF;
      --
   ELSIF c_shipment_advice_del%ISOPEN THEN
      FETCH c_shipment_advice_del INTO l_cur_rec;
      --
      IF c_shipment_advice_del%NOTFOUND THEN
         CLOSE c_shipment_advice_del;
         EXIT;
      END IF;
      --
   ELSIF c_sr_tpw_del%ISOPEN THEN
      FETCH c_sr_tpw_del INTO l_cur_rec;
      --
      IF c_sr_tpw_del%NOTFOUND THEN
         CLOSE c_sr_tpw_del;
         EXIT;
      END IF;
      --
   ELSIF c_sr_cms_del%ISOPEN THEN
      FETCH c_sr_cms_del INTO l_cur_rec;
      --
      IF c_sr_cms_del%NOTFOUND THEN
         CLOSE c_sr_cms_del;
         EXIT;
      END IF;
      --
   END IF;
    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,' ');
      wsh_debug_sv.log (l_module_name,'Delivery_id',l_cur_rec.delivery_id);
      wsh_debug_sv.log (l_module_name,'organization_id',l_cur_rec.organization_id);
      wsh_debug_sv.log (l_module_name,'Carrier_Id',l_cur_rec.carrier_id);
      wsh_debug_sv.log (l_module_name,'Customer_Id',l_cur_rec.customer_id);
      wsh_debug_sv.log (l_module_name,'Ship_To',l_cur_rec.ultimate_dropoff_location_id);
    END IF;

      SAVEPOINT start_process_delivery;

      l_delivery_status	:='SUCCESS';
      l_warning_index := 0;
      l_delivery_count := l_delivery_count + 1;
      l_entity_ids(1) := l_cur_rec.delivery_id;


      l_calling_api := 'Calling API wsh_new_deliveries_pvt.Lock_Dlvy_No_Compare';
      BEGIN
         wsh_new_deliveries_pvt.Lock_Dlvy_No_Compare(
                                            p_delivery_id =>l_entity_ids(1));

         -- set the return status to success if no exception raised, as the
         -- API Lock_Dlvy_No_Compare does not have a x_return_status

         l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      EXCEPTION
         WHEN app_exception.application_exception
                               OR app_exception.record_lock_exception THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      END ;

      IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'wsh_new_deliveries_pvt.Lock_Dlvy_No_Compare return status: ',l_return_status);
      END IF;

      IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN  --1.IF {

         IF p_shipment_type = 'CMS' AND p_doctype = 'SR' THEN --{

            l_calling_api := 'Calling WSH_DELIVERY_VALIDATIONS.Check_Pack';

            WSH_DELIVERY_VALIDATIONS.Check_Pack(
                        p_delivery_id   => l_entity_ids(1),
                        x_return_status => l_return_status);

            IF l_debug_on THEN
              wsh_debug_sv.log (l_module_name,'WSH_DELIVERY_VALIDATIONS.Check_Pack Return Status',l_return_status);
            END IF;

            IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR) THEN --3.IF {

               IF ( nvl(p_autopack,'N') = 'Y' ) THEN -- {
                  l_calling_api := 'Calling WSH_CONTAINER_ACTIONS.Auto_Pack_Delivery';

                  WSH_CONTAINER_ACTIONS.Auto_Pack_Delivery(
                        p_delivery_tab          => l_entity_ids,
                        p_pack_cont_flag        => 'N',
                        x_cont_instance_tab     => l_con_ids,
                        x_return_status         => l_return_status);

                  IF l_debug_on THEN
                    wsh_debug_sv.log (l_module_name,'WSH_CONTAINER_ACTIONS.Auto_Pack_Delivery Return Status',
                                                                                                     l_return_status);
                  END IF;

                  IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) )THEN --5.IF
                      l_delivery_status := 'ERROR';
                  ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN --5.IF
                      l_warning_index := l_warning_index +1;
                  END IF; --5.IF

               ELSE -- }{
                  l_delivery_status := 'ERROR';
               END IF; --}

            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN --}{
               l_warning_index := l_warning_index +1;
            ELSIF (l_return_status =  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN --}{
               l_delivery_status := 'ERROR';
            END IF; --}

         END IF; --}


            IF (l_delivery_status = 'SUCCESS' ) THEN --{
               l_calling_api := 'Calling WSH_TRANSACTIONS_UTIL.Send_Document';

               WSH_TRANSACTIONS_UTIL.Send_Document (
                        p_entity_id             => l_entity_ids(1) ,
                        p_entity_type           => 'DLVY',
                        p_action_type           => 'A' ,
                        p_document_type         => p_doctype ,
                        p_organization_id       => l_cur_rec.organization_id,
                        x_return_status         => l_return_status);

               IF l_debug_on THEN
                 wsh_debug_sv.log (l_module_name,'WSH_TRANSACTIONS_UTIL.Send_Document Return Status',l_return_status);
               END IF;

               IF ( l_return_status not in (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING )) THEN --{
                  l_delivery_status := 'ERROR';
               ELSE --}{
                  IF ( l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                     l_warning_index := l_warning_index +1;
                  END IF;
               END IF; --}
            END IF; --}

        ELSE --}{
           l_delivery_status := 'ERROR';
        END IF; --}


      WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, l_msg_count);
      IF (l_msg_count < 2 ) THEN
        l_msg_details := NULL;
      END IF;

      IF l_debug_on THEN
        wsh_debug_sv.log (l_module_name,'l_msg_summary: ',l_msg_summary);
        wsh_debug_sv.log (l_module_name,'l_msg_details: ',l_msg_details);
        wsh_debug_sv.log (l_module_name,'l_msg_count: ',l_msg_count);
      END IF;
      FND_MSG_PUB.initialize;

      IF (l_delivery_status = 'SUCCESS' ) THEN --{

         IF l_debug_on THEN
           wsh_debug_sv.log (l_module_name,'Success l_warning_index: ',l_warning_index);
         END IF;

	 --Start of bug 4070732
         l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	 IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN --{

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => FALSE,
                                                   x_return_status => l_return_status);

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           END IF;
           wsh_util_core.api_post_call
           (
              p_return_status => l_return_status,
              x_num_warnings  => l_warning_count,
              x_num_errors    => l_error_count,
              p_raise_error_flag => FALSE
            );
         END IF; --}
	 -- End of bug 4070732
         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                     WSH_UTIL_CORE.G_RET_STS_WARNING)  THEN --{
            IF ( l_warning_index > 0 ) THEN --{
              IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'Delivery Status: SUCCESS with WARNING');
              END IF;
               l_warning_count := l_warning_count+1;
               l_warning_delivery(l_warning_count).delivery_name := wsh_new_deliveries_pvt.get_name(l_entity_ids(1));
               l_warning_delivery(l_warning_count).msg_summary := l_msg_summary;
               l_warning_delivery(l_warning_count).msg_details := l_msg_details;
            ELSE --}{
              IF l_debug_on THEN
               wsh_debug_sv.log(l_module_name,'Delivery Status: SUCCESS');
              END IF;
               l_success_count := l_success_count+1;
               l_success_delivery(l_success_count).delivery_name := wsh_new_deliveries_pvt.get_name(l_entity_ids(1));
               l_success_delivery(l_success_count).msg_summary := l_msg_summary;
               l_success_delivery(l_success_count).msg_details := l_msg_details;
            END IF; --}
         END IF; --}

         IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,
                     WSH_UTIL_CORE.G_RET_STS_WARNING) THEN --{
            COMMIT;
         ELSE --}{
            IF l_debug_on THEN
             wsh_debug_sv.log(l_module_name,'Delivery Status: ERROR');
            END IF;
            l_error_count := l_error_count+1;
            l_error_delivery(l_error_count).delivery_name := wsh_new_deliveries_pvt.get_name(l_entity_ids(1));
            l_error_delivery(l_error_count).msg_summary := l_msg_summary;
            l_error_delivery(l_error_count).msg_details := l_msg_details;
            ROLLBACK TO SAVEPOINT start_process_delivery;
         END IF; --}
      ELSE --}{
         IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'Delivery Status: ERROR');
         END IF;
         l_error_count := l_error_count+1;
         l_error_delivery(l_error_count).delivery_name := wsh_new_deliveries_pvt.get_name(l_entity_ids(1));
         l_error_delivery(l_error_count).msg_summary := l_msg_summary;
         l_error_delivery(l_error_count).msg_details := l_msg_details;
         ROLLBACK TO SAVEPOINT start_process_delivery;
      END IF; --}

   END LOOP; --}


   IF l_error_count > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      IF l_delivery_count = l_error_count THEN
         IF l_debug_on THEN
          wsh_debug_sv.log(l_module_name,'All Deliveries selected are having error');
         END IF;
      END IF;
   END IF;

   ----** Output to Concurrent Output File **---
   OPEN  get_carrier_name(p_carrier_id);
   FETCH get_carrier_name INTO l_carrier_name;
   CLOSE get_carrier_name;

   OPEN  get_customer_name(p_customer_id);
   FETCH get_customer_name INTO l_customer_name;
   CLOSE get_customer_name;

   OPEN  get_location(p_customer_ship_to_id);
   FETCH get_location INTO l_location;
   CLOSE get_location;

   IF (NVL(p_autopack,'N') ='N') THEN
      l_autopack :='No';
   ELSE
      l_autopack :='Yes';
   END IF;

   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_PARM');
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
   FND_FILE.put_line(FND_FILE.output,'==========');

   FND_MESSAGE.SET_NAME('WSH', 'WSH_DOC_TYPE');
   FND_MESSAGE.SET_TOKEN('DOC_TYPE', wsh_util_core.get_lookup_meaning('WSH_TXN_DOCUMENT_TYPE',p_doctype));
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_SHIP_TYPE');
   FND_MESSAGE.SET_TOKEN('SHIP_TYPE', wsh_util_core.get_lookup_meaning('WSH_SHIPMENT_TYPE',p_shipment_type));
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   /*Modified R12.1.1 LSP PROJECT*/
        IF p_client_id  IS NOT NULL THEN
          l_client_id := p_client_id;
          l_client_code := NULL;
           wms_deploy.get_client_details(
           x_client_id     => l_client_id,
           x_client_name   => l_client_name,
           x_client_code   => l_client_code,
           x_return_status => l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       --{
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Error occured in WMS_DEPLOY.GET_CLIENT_DETAILS');
             END IF;

           END IF;

        ELSE
            l_client_name := '' ;
        END IF;

           FND_MESSAGE.SET_NAME('WSH', 'WSH_CLIENT');
           FND_MESSAGE.SET_TOKEN('CLIENT_NAME', l_client_name);
           FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

        /*Modified R12.1.1 LSP PROJECT*/


   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_ORG');
   FND_MESSAGE.SET_TOKEN('ORG_NAME', WSH_UTIL_CORE.Get_Org_Name(p_organization_id));
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_ORDER_FROM');
   FND_MESSAGE.SET_TOKEN('ORDER',p_src_header_num_from );
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_ORDER_TO');
   FND_MESSAGE.SET_TOKEN('ORDER',p_src_header_num_to );
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
   --R12.1.1 STANDALONE PROJECT
   FND_MESSAGE.SET_NAME('WSH', 'WSH_DELIVERY_FROM');
   FND_MESSAGE.SET_TOKEN('DELIVERY',p_del_name_from );
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_DELIVERY_TO');
   FND_MESSAGE.SET_TOKEN('DELIVERY',p_del_name_to );
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_CARRIER');
   FND_MESSAGE.SET_TOKEN('CARRIER_NAME', l_carrier_name);
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_CUSTOMER');
   FND_MESSAGE.SET_TOKEN('CUSTOMER_NAME', l_customer_name);
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_SHIP_TO');
   FND_MESSAGE.SET_TOKEN('SHIP_TO', l_location);
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_SCH_FROM');
   FND_MESSAGE.SET_TOKEN('SCH_FROM_DATE', p_scheduled_from_date);
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_SCH_TO');
   FND_MESSAGE.SET_TOKEN('SCH_TO_DATE', p_scheduled_to_date);
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_AUTOPACK');
   FND_MESSAGE.SET_TOKEN('AUTOPACK', l_autopack);
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_LOG_LEVEL');
   FND_MESSAGE.SET_TOKEN('LOG_LEVEL', to_char(p_log_level));
   FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

   IF (l_delivery_count < 1 ) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      FND_FILE.put_line(FND_FILE.output,' ');
      FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_DEL_FOR_PARAMETERS');
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);
      IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name,l_msg_summary);
      END IF;

   ELSE
      FND_FILE.put_line(FND_FILE.output,' ');
      FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_SUMMARY');
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

      FND_FILE.put_line(FND_FILE.output,'==============');
      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'All Deliveries: ',l_delivery_count);
      END IF;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_ALL_DLVY');
      FND_MESSAGE.SET_TOKEN('ALL_DLVY', to_char(l_delivery_count));
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'Success Deliveries: ',l_success_count);
      END IF;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_SUC_DLVY');
      FND_MESSAGE.SET_TOKEN('SUC_DLVY', to_char(l_success_count));
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'Warning Deliveries: ',l_warning_count);
      END IF;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_WAR_DLVY');
      FND_MESSAGE.SET_TOKEN('WAR_DLVY', to_char(l_warning_count));
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

      IF l_debug_on THEN
       wsh_debug_sv.log (l_module_name,'Error Deliveries: ',l_error_count);
      END IF;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_ERR_DLVY');
      FND_MESSAGE.SET_TOKEN('ERR_DLVY', to_char(l_error_count));
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

      FND_FILE.put_line(FND_FILE.output,' ');
      FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_HS_DLVY');
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

      IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name,'Success Deliveries');
      END IF;
      FOR s_count IN 1..l_success_count LOOP
            IF (s_count <> 1) THEN
               FND_FILE.put(FND_FILE.output,',');
               IF l_debug_on THEN
                wsh_debug_sv.log(l_module_name,',');
               END IF;
            END IF;
            FND_FILE.put(FND_FILE.output,l_success_delivery(s_count).delivery_name);
            IF l_debug_on THEN
             wsh_debug_sv.log (l_module_name,' ',l_success_delivery(s_count).delivery_name);
            END IF;
      END LOOP;

      IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name,'Warning Deliveries');
      END IF;
      FND_FILE.put_line(FND_FILE.output,' ');
      FND_FILE.put_line(FND_FILE.output,' ');
      FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_HW_DLVY');
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

      FOR w_count IN 1..l_warning_count LOOP
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,l_warning_delivery(w_count).delivery_name||': '||
                                                             l_warning_delivery(w_count).msg_summary);
        END IF;
        FND_FILE.put_line(FND_FILE.output,l_warning_delivery(w_count).delivery_name||': '
                                                 ||l_warning_delivery(w_count).msg_summary);

        IF (l_warning_delivery(w_count).msg_details IS NOT NULL ) THEN
           IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,l_warning_delivery(w_count).msg_details);
           END IF;
           FND_FILE.put_line(FND_FILE.output,'      '||l_warning_delivery(w_count).msg_details);
        END IF;
      END LOOP;

      IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name,'Error Deliveries');
      END IF;
      FND_FILE.put_line(FND_FILE.output,' ');
      FND_FILE.put_line(FND_FILE.output,' ');
      FND_MESSAGE.SET_NAME('WSH', 'WSH_MANIFEST_HE_DLVY');
      FND_FILE.put_line(FND_FILE.output,FND_MESSAGE.GET);

      FOR e_count IN 1..l_error_count LOOP
        IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,l_error_delivery(e_count).delivery_name||': '||
                                 l_error_delivery(e_count).msg_summary);
        END IF;
        FND_FILE.put_line(FND_FILE.output,l_error_delivery(e_count).delivery_name||': '
                                                 ||l_error_delivery(e_count).msg_summary);

        IF (l_error_delivery(e_count).msg_details IS NOT NULL) THEN
           IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name,l_error_delivery(e_count).msg_details);
           END IF;
           FND_FILE.put_line(FND_FILE.output,'      '||l_error_delivery(e_count).msg_details);
        END IF;
      END LOOP;

   END IF;
   ----** Output to Concurrent Output File **---

--Bugfix 4070732 {
  IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name)
THEN --{
    IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       WSH_UTIL_CORE.Process_stops_for_load_tender(
                                     p_reset_flags   => TRUE,
                                     x_return_status => l_return_status);
       IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
       END IF;


       IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
          OR (x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
       THEN --{
          x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       ELSIF x_return_status <> WSH_UTIL_CORE.G_RET_STS_ERROR
       THEN
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
          THEN
             x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
          END IF;
       END IF; --}
    END IF;
  END IF; --}

  --}
 --End of bug 4070732
   IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
   END IF;
   wsh_debug_sv.stop_debug;

EXCEPTION

  WHEN others THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     wsh_util_core.default_handler('WSH_AUTO_MANIFEST.Process_Auto_Manifest',l_module_name);
     WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, l_msg_count);

     --Start of bug 4070732

     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
       IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                   x_return_status => l_return_status);
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;

       END IF;
     END IF;
     --End of bug 4070732

     IF l_debug_on THEN
       wsh_debug_sv.log(l_module_name,l_msg_summary);
       wsh_debug_sv.log(l_module_name,'Calling API :'||l_calling_api);
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                                                             SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Process_Auto_Manifest;


--
-- PROCEDURE  : Lock_Manifest_Delivery
-- Description: This procedure lock the delivery and its assigned lines
--
PROCEDURE Lock_Manifest_Delivery(
  p_delivery_id   	IN	NUMBER,
  x_return_status       OUT NOCOPY 	VARCHAR2) IS

 RECORD_LOCKED          EXCEPTION;
 PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);
 l_delivery_id		NUMBER;
 l_status_code 	VARCHAR2(10);

 CURSOR c_lock_delivery IS
  SELECT       wnd.delivery_id, wnd.status_code
   FROM         wsh_delivery_details wdd,
                wsh_delivery_assignments_v wda,
                wsh_new_deliveries wnd
   WHERE        wdd.delivery_detail_id = wda.delivery_detail_id
   AND          wda.delivery_id = wnd.delivery_id
   AND          wdd.container_flag = 'N'
   AND          wdd.released_status in ('X','Y')
   AND          wnd.status_code='OP'
   AND          wnd.delivery_id=p_delivery_id
   AND		wda.delivery_id IS NOT NULL
   FOR UPDATE NOWAIT;
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_MANIFEST_DELIVERY';
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
    wsh_debug_sv.push (l_module_name);
    wsh_debug_sv.log (l_module_name,'DELIVERY_ID',p_delivery_id);
   END IF;

   OPEN c_lock_delivery;
   FETCH c_lock_delivery INTO l_delivery_id,l_status_code;
   CLOSE c_lock_delivery;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
   END IF;
EXCEPTION
   WHEN RECORD_LOCKED THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
      END IF;

   WHEN others THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_AUTO_MANIFEST.Lock_Manifest_Delivery',l_module_name);

      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Lock_Manifest_Delivery;


--
-- PROCEDURE  : Validate_Scheduled_Ship_Date
-- Description: This procedure check if scheduled _date of lines assign to delivery fall in the range
--              of input scheduled_ship_date
--
PROCEDURE Validate_Scheduled_Ship_Date(
        p_delivery_id           IN      NUMBER,
        p_scheduled_from_date   IN      DATE,
        p_scheduled_to_date     IN      DATE,
        x_validate              OUT NOCOPY      VARCHAR2,
        x_return_status         OUT NOCOPY      VARCHAR2) IS

l_count NUMBER;
CURSOR c1 IS
 SELECT count(*)
      FROM   wsh_delivery_details wdd,
             wsh_delivery_assignments_v wda
      WHERE wdd.delivery_detail_id = wda.delivery_detail_id
      AND   wda.delivery_id = p_delivery_id
      AND   wdd.container_flag = 'N'
      AND   wdd.released_status in ('X','Y')
      AND   wda.delivery_id IS NOT NULL
      AND   trunc(wdd.DATE_SCHEDULED) between trunc(p_scheduled_from_date) AND trunc(p_scheduled_to_date);

CURSOR c2 IS
 SELECT count(*)
      FROM   wsh_delivery_details wdd,
             wsh_delivery_assignments_v wda
      WHERE wdd.delivery_detail_id = wda.delivery_detail_id
      AND   wda.delivery_id = p_delivery_id
      AND   wdd.container_flag = 'N'
      AND   wdd.released_status in ('X','Y')
      AND   wda.delivery_id IS NOT NULL
      AND   trunc(wdd.DATE_SCHEDULED) >= trunc(p_scheduled_from_date);

CURSOR c3 IS
 SELECT count(*)
      FROM   wsh_delivery_details wdd,
             wsh_delivery_assignments_v wda
      WHERE wdd.delivery_detail_id = wda.delivery_detail_id
      AND   wda.delivery_id = p_delivery_id
      AND   wdd.container_flag = 'N'
      AND   wdd.released_status in ('X','Y')
      AND   wda.delivery_id IS NOT NULL
      AND   trunc(wdd.DATE_SCHEDULED) <= trunc(p_scheduled_to_date);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_SCHEDULED_SHIP_DATE';
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
  wsh_debug_sv.push (l_module_name);
  wsh_debug_sv.log (l_module_name,'DELIVERY_ID',p_delivery_id);
  wsh_debug_sv.log (l_module_name,'P_SCHEDULED_FROM_DATE',p_scheduled_from_date);
  wsh_debug_sv.log (l_module_name,'P_SCHEDULED_TO_DATE',p_scheduled_to_date);
 END IF;

  x_validate := 'Y';
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF (p_scheduled_from_date IS NULL AND p_scheduled_to_date IS NULL ) THEN
    IF l_debug_on THEN
     wsh_debug_sv.pop(l_module_name,'RETURN');
    END IF;
    RETURN;
  END IF;

  IF (p_scheduled_from_date IS NOT NULL AND p_scheduled_to_date IS NOT NULL ) THEN
     OPEN c1;
     FETCH c1 INTO l_count;
     CLOSE c1;
  ELSIF (p_scheduled_from_date IS NOT NULL AND p_scheduled_to_date IS NULL ) THEN
     OPEN c2;
     FETCH c2 INTO l_count;
     CLOSE c2;
  ELSIF (p_scheduled_from_date IS NULL AND p_scheduled_to_date IS NOT NULL ) THEN
     OPEN c3;
     FETCH c3 INTO l_count;
     CLOSE c3;
  END IF;

  IF (l_count < 1 ) THEN
     x_validate := 'N';
     FND_MESSAGE.SET_NAME('WSH','WSH_SCH_DATE_NOT_IN_RANGED');
     FND_MESSAGE.SET_TOKEN('DEL_NAME',wsh_new_deliveries_pvt.get_name(p_delivery_id));
     WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
  END IF;

   IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
   END IF;
EXCEPTION
  WHEN others THEN
     x_validate := 'N';
     wsh_util_core.default_handler('WSH_AUTO_MANIFEST.Validate_Scheduled_Ship_Date',l_module_name);
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Validate_Scheduled_Ship_Date;

FUNCTION set_auto_pack (
       p_doc_type    IN VARCHAR2,
       p_shipment_type IN VARCHAR2
      ) RETURN NUMBER
IS
   l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' ||
'SET_AUTO_PACK';
BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
    wsh_debug_sv.push (l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_doc_type', p_doc_type);
    WSH_DEBUG_SV.log(l_module_name,'p_shipment_type', p_shipment_type);
   END IF;

   IF p_doc_type = 'SR' AND p_shipment_type = 'CMS' THEN
      IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'return 1');
       wsh_debug_sv.pop(l_module_name);
      END IF;
      RETURN 1;
   END IF;

   IF l_debug_on THEN
    wsh_debug_sv.pop(l_module_name);
   END IF;

   RETURN NULL;

END set_auto_pack;

END WSH_AUTO_MANIFEST;

/
