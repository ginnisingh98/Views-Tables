--------------------------------------------------------
--  DDL for Package Body WSH_INV_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INV_INTEGRATION_GRP" AS
/* $Header: WSHINVIB.pls 120.0 2005/05/26 17:06:48 appldev noship $ */

   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INV_INTEGRATION_GRP ';
   --

   PROCEDURE Find_Printer (
      p_subinventory             IN          VARCHAR2 ,
      p_organization_id          IN          NUMBER,
      x_api_status               OUT NOCOPY  VARCHAR2,
      x_error_message            OUT NOCOPY  VARCHAR2
   )  is
   -- local variables
   l_printer_name   VARCHAR2(30);
   l_org_found      number;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FIND_PRINTER';
--
      CURSOR c_orgsub_printer  (v_organization_id  IN NUMBER ,
				v_subinventory     in VARCHAR2 ) IS
        select printer_name
        from wsh_report_printers_v  wrp
        where wrp.level_type_id = '10006'
        and   application_id = 665
        and   concurrent_program_id = (
	      select concurrent_program_id from
	      fnd_concurrent_programs_vl
	      where concurrent_program_name = 'WSHRDPIK'
	      and application_id = 665
	      and rownum = 1 )
        and   organization_id = v_organization_id
        and   wrp.subinventory  = v_subinventory
	and   wrp.enabled_flag = 'Y'
	order by decode ( nvl( wrp.default_printer_flag ,2) ,
				'Y' ,1 , 2 ) ;

      CURSOR c_org_printer  (v_organization_id  IN NUMBER ) IS
         select printer_name
         from wsh_report_printers_v  wrp
         where wrp.level_type_id = '10008'
         and   application_id = 665
         and   concurrent_program_id =  (
	      select concurrent_program_id from
	      fnd_concurrent_programs_vl
	      where concurrent_program_name = 'WSHRDPIK'
	      and application_id = 665
	      and rownum = 1 )
         and   level_value_id  = v_organization_id
	 and   wrp.enabled_flag = 'Y'
	 order by decode ( nvl( wrp.default_printer_flag ,2) ,
				'Y' ,1 , 2 )  ;

   BEGIN
      x_api_status := FND_API.G_RET_STS_SUCCESS;
      x_error_message := NULL ;
      --
      --

     for i in 1..WSH_INV_INTEGRATION_GRP.G_ORGSUBTAB.count loop
	  if WSH_INV_INTEGRATION_GRP.G_ORGSUBTAB(i) = p_organization_id || '~' ||  p_subinventory THEN
              --
	     return  ;
	  end if ;
          --
          --
     end loop ;

     -- Insert the orgsub combination in the global table:

     WSH_INV_INTEGRATION_GRP.G_ORGSUBTAB(WSH_INV_INTEGRATION_GRP.G_ORGSUBTAB.count + 1 ):= p_organization_id ||  '~' || p_subinventory ;

     l_org_found := 0 ;

     for i in 1..WSH_INV_INTEGRATION_GRP.G_ORGTAB.count loop
	  if WSH_INV_INTEGRATION_GRP.G_ORGTAB(i) = p_organization_id THEN
              --
	     l_org_found := 1 ;
	     exit  ; -- we don't return here , because we although this org has been encountered before
		     -- we want to know if a printer has been setup for this OrgSub combo.
	  end if ;
          --
     end loop ;

     -- Initialize the printer_name to -1 and see if a setup exists for this orgsub combo.

     l_printer_name := '-1' ;

     OPEN c_orgsub_printer  ( p_organization_id , p_subinventory ) ;
     FETCH c_orgsub_printer into l_printer_name ;

     if l_printer_name = '-1' and l_org_found = 0 then

         -- printer not set for the ( sub , org )    combination ,there search for just the org
	 -- First insert the org in the global table

         WSH_INV_INTEGRATION_GRP.G_ORGTAB(WSH_INV_INTEGRATION_GRP.G_ORGTAB.count + 1 ):= p_organization_id;

	 -- Next , see if printer setup has been done for this org

         OPEN  c_org_printer  ( p_organization_id ) ;
         FETCH c_org_printer into l_printer_name ;

         --
         --
     end if ;

     for i in 1..WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count loop
	  if WSH_INV_INTEGRATION_GRP.G_PRINTERTAB(i) = l_printer_name  THEN
              --
              --
	     return ;
	  end if ;
     end loop ;
     --
     --
     -- bug 3980388 - Not to add printer '-1' to the table because Find_Printer return '-1' printer when
     --               printing report by user level.
     IF l_printer_name <> '-1' THEN
        WSH_INV_INTEGRATION_GRP.G_PRINTERTAB(WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count + 1 ) := l_printer_name ;
     END IF;
     -- end bug 3980388

     exception
      when others then
         x_error_message := 'Exception occurred in WSH_INV_INTEGRATION_GRP.Find_Printer';
         x_api_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --

   END Find_Printer ;


/*
Procedure :Complete_Inv_Interface
Description: This procedure will be called by Inventory during processing of the data from their interface
             tables.The purpose of this procedure is to update the inventory_interfaced_flag on
             wsh_delivery_details to 'Y' if inventory interface process has completed successfully
             and also to update the pending_interface_flag for the corresponding trip stops to NULL.
*/
PROCEDURE Complete_Inv_Interface(
        p_api_version_number    IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        p_commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_txn_header_id         IN NUMBER,
        p_txn_batch_id          IN NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS

CURSOR detail_rec_csr IS
     SELECT 	st.stop_id, wdd.delivery_detail_id
     FROM	wsh_delivery_details wdd,
		mtl_transactions_interface mtf,
                wsh_delivery_assignments_v da ,
                wsh_delivery_legs dg,
                wsh_new_deliveries dl,
                wsh_trip_stops st
     WHERE	wdd.delivery_detail_id = mtf.picking_line_id
     AND	mtf.error_code IS NULL
     AND	mtf.transaction_header_id = p_txn_header_id
     AND	nvl(mtf.transaction_batch_id,-1) = nvl(nvl(p_txn_batch_id,mtf.transaction_batch_id),-1)
     AND        ((mtf.transaction_action_id IN ( 21,3,2,1)
                    AND mtf.transaction_source_type_id = 8)
              OR ((mtf.transaction_action_id = 1) AND
                        mtf.transaction_source_type_id IN (2,16,13)))
     AND 	wdd.container_flag = 'N'
     AND 	nvl(wdd.inv_interfaced_flag , 'N')  <> 'Y'
     AND 	nvl(wdd.inv_interfaced_flag , 'N')  <> 'X'
     AND		wdd.released_status <> 'D'
     AND        (exists (
                SELECT mmt.picking_line_id
                   FROM  mtl_material_transactions mmt
                   WHERE mmt.picking_line_id  =  wdd.delivery_detail_id
               and transaction_source_type_id in ( 2,8,13,16 )
               and trx_source_line_id = wdd.source_line_id
                   )
               )
     AND       wdd.delivery_detail_id = da.delivery_detail_id
     AND       dl.delivery_id = da.delivery_id
     AND       da.delivery_id  IS NOT NULL
     AND       st.stop_id = dg.pick_up_stop_id
     AND       st.stop_location_id = dl.initial_pickup_location_id
     AND       dg.delivery_id = dl.delivery_id
     AND       wdd.source_code in ('OE','OKE', 'WSH')
     ORDER BY  st.stop_id, wdd.delivery_detail_id
     FOR UPDATE of wdd.delivery_detail_id NOWAIT;

-- Cursor to verify that OM and INV interface is complete for trip stop.
  CURSOR c_lines_not_interfaced(p_stop_id NUMBER) IS
   SELECT wdd.delivery_detail_id
   FROM   wsh_trip_stops wts,
         wsh_delivery_legs wdl,
         wsh_delivery_assignments_v wda,
         wsh_delivery_details wdd
   WHERE  (wdd.inv_interfaced_flag IN ('N', 'P') OR wdd.oe_interfaced_flag <> 'Y')
   AND   wts.stop_id = p_stop_id
   AND   wts.stop_location_id = wdd.ship_from_location_id
   AND   wts.stop_id = wdl.pick_up_stop_id
   AND   wdl.delivery_id = wda.delivery_id
   AND   wda.delivery_id IS NOT NULL
   AND   wda.delivery_detail_id = wdd.delivery_detail_id
   AND   wdd.source_code in ('OE','OKE', 'WSH')
   AND   wdd.released_status <> 'D'
   AND   rownum = 1;

l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Complete_Inv_Interface';

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COMPLETE_INV_INTERFACE';

trip_stop_locked 	exception;
PRAGMA EXCEPTION_INIT(trip_stop_locked, -54);

TYPE tlb_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE Rec_Tab_Type IS RECORD (
   stop_id		tlb_num,
   delivery_detail_id	tlb_num);

l_det_rec   		Rec_Tab_Type;
l_row_count		NUMBER:=0;
l_stop_id		NUMBER;
l_temp			VARCHAR2(1);
l_temp_id		NUMBER;
l_encoded 		VARCHAR2(1) := 'F';
l_index                 NUMBER;
l_stop_cache            wsh_util_core.id_tab_type;

BEGIN
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

   IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
      WSH_DEBUG_SV.log(l_module_name,'p_txn_header_id',p_txn_header_id);
      WSH_DEBUG_SV.log(l_module_name,'p_txn_batch_id',p_txn_batch_id);
   END IF;

   savepoint Complete_Inv_Interface;

   --  Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version_number,p_api_version_number,l_api_name,G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Done Compatible_API_Call');
   END IF;

   --  Initialize message stack if required
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Done FND_API.to_Boolean');
   END IF;

   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --Bulk fetch detail_rec_csr into record of table.
   OPEN  detail_rec_csr;
   FETCH detail_rec_csr BULK COLLECT
         INTO -- l_det_rec; -- replaced due to 8.1.7.4 pl/sql bug 3286811
             l_det_rec.stop_id,
             l_det_rec.delivery_detail_id;
   l_row_count := detail_rec_csr%ROWCOUNT;
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'No of Record fetch l_row_count',l_row_count);
   END IF;
   CLOSE  detail_rec_csr;

   IF (l_row_count < 1 ) THEN
    raise no_data_found;
   END IF;

   SAVEPOINT Complete_Inv_Interface;

   l_stop_id := l_det_rec.stop_id(l_det_rec.stop_id.first);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_stop_id',l_stop_id);
   END IF;

   FORALL i IN 1 ..l_row_count
    UPDATE wsh_delivery_details
    SET    inv_interfaced_flag = 'Y'
    WHERE  delivery_detail_id = l_det_rec.delivery_detail_id(i);

   l_row_count := SQL%ROWCOUNT;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'No of Record Update to Y  l_row_count',l_row_count);
   END IF;

  /* Check if all the delivery details under the trip stop are interfaced to inventory and OM.
     If yes, then update the pending_interface_flag of the trip to NULL.*/

   l_index := l_det_rec.stop_id.FIRST;
   WHILE l_index IS NOT NULL LOOP --{
     IF NOT l_stop_cache.EXISTS(l_det_rec.stop_id(l_index)) THEN --{
       BEGIN
           l_stop_cache(l_det_rec.stop_id(l_index))
                                               := l_det_rec.stop_id(l_index);
           SELECT 'X' INTO   l_temp
           FROM   WSH_TRIP_STOPS
           WHERE  stop_id = l_det_rec.stop_id(l_index)
           FOR UPDATE NOWAIT;

           OPEN  c_lines_not_interfaced(l_det_rec.stop_id(l_index));
           FETCH c_lines_not_interfaced INTO l_temp_id;

           IF (c_lines_not_interfaced%NOTFOUND) THEN
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'All lines are Interface to INV and OM',l_temp_id);
              END IF;

              UPDATE wsh_trip_stops
                 SET    pending_interface_flag = NULL
                 WHERE  stop_id = l_det_rec.stop_id(l_index);

              l_row_count := SQL%ROWCOUNT;

              IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'pending_interface_flag update to NULL for stop',l_det_rec.stop_id(l_index));
              END IF;
           ELSE
              IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'All lines are Not Interface to INV and OM',l_temp_id);
              END IF;
           END IF;
           CLOSE c_lines_not_interfaced;

           --EXIT;
        EXCEPTION
           WHEN trip_stop_locked THEN
             NULL;
        END;

     END IF; --}
     l_index := l_det_rec.stop_id.NEXT(l_index);
   END LOOP; --}

   IF p_commit = FND_API.G_TRUE THEN
      COMMIT;
   END IF;


   FND_MSG_PUB.Count_And_Get
     ( p_encoded => l_encoded
     , p_count => x_msg_count
     , p_data  => x_msg_data);

   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'No Record found to complete interface',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;


   WHEN trip_stop_locked THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Could not locked the records for stop',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
       IF detail_rec_csr%ISOPEN THEN
         CLOSE detail_rec_csr;
       END IF;

       IF c_lines_not_interfaced%ISOPEN THEN
         CLOSE c_lines_not_interfaced;
       END IF;

       rollback to savepoint Complete_Inv_Interface;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --  Get message count and data
      FND_MSG_PUB.Count_And_Get
         ( p_encoded => l_encoded
         , p_count => x_msg_count
         , p_data  => x_msg_data
         );
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
       rollback to savepoint Complete_Inv_Interface;

   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
           ( G_PKG_NAME
           , '_x_'
           );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
         ( p_encoded => l_encoded
         , p_count => x_msg_count
         , p_data  => x_msg_data
         );
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
       rollback to savepoint Complete_Inv_Interface;

END Complete_Inv_Interface;



END WSH_INV_INTEGRATION_GRP ;

/
