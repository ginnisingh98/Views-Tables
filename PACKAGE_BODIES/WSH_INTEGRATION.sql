--------------------------------------------------------
--  DDL for Package Body WSH_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INTEGRATION" as
/* $Header: WSHINTGB.pls 120.5.12010000.8 2010/08/06 16:10:41 anvarshn ship $ */

--  Global constant holding the package name
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'WSH_INTEGRATION';

-- Global variable holding transaction_id
--Bug#5104847:Assigning default value FND_API.G_MISS_NUM to trx_id and trx_temp_id as
--            WMS is not calling the API WSH_INTEGRATION.Set_Inv_PC_Attributes to set trx ids.
TYPE InvPCRecType IS RECORD
                ( transaction_id           NUMBER    DEFAULT FND_API.G_MISS_NUM,
                  transaction_temp_id      NUMBER    DEFAULT FND_API.G_MISS_NUM);


G_InvPCRec InvPCRecType;

-- DBI Project,11.5.10+
-- Global Variable indicating if DBI is installed or not
G_DBI_IS_INSTALLED VARCHAR2(1) := NULL;


PROCEDURE Get_Min_Max_Tolerance_Quantity
                ( p_in_attributes           IN     MinMaxInRecType,
                  p_out_attributes          OUT NOCOPY     MinMaxOutRecType,
                  p_inout_attributes        IN OUT NOCOPY  MinMaxInOutRecType,
                  x_return_status           OUT NOCOPY     VARCHAR2,
                  x_msg_count               OUT NOCOPY     NUMBER,
                  x_msg_data                OUT NOCOPY     VARCHAR2
                )
IS
  l_minmaxinrectype          WSH_DETAILS_VALIDATIONS.MinMaxInRecType;
  l_minmaxinoutrectype       WSH_DETAILS_VALIDATIONS.MinMaxInOutRecType;
  l_minmaxoutrectype         WSH_DETAILS_VALIDATIONS.MinMaxOutRecType;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MIN_MAX_TOLERANCE_QUANTITY';
--
BEGIN
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'api_version_number',p_in_attributes.api_version_number);
    WSH_DEBUG_SV.log(l_module_name,'source_code',p_in_attributes.source_code);
    WSH_DEBUG_SV.log(l_module_name,'line_id',p_in_attributes.line_id);
    WSH_DEBUG_SV.log(l_module_name,'dummy_quantity',p_inout_attributes.dummy_quantity);
  END IF;

  IF ( p_in_attributes.source_code IS NULL )
  THEN
      x_msg_count := 1;
      x_msg_data := 'INVALID SOURCE_CODE';
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF l_debug_on THEN
   WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_DETAILS_VALIDATIONS.Get_Min_Max_Tolerance_Quantity');
  END IF;

  l_minmaxinrectype.api_version_number := NVL(p_in_attributes.api_version_number, 1.0);
  l_minmaxinrectype.source_code := p_in_attributes.source_code;
  l_minmaxinrectype.line_id :=  p_in_attributes.line_id;
  l_minmaxinrectype.action_flag := 'C';
  l_minmaxinoutrectype.dummy_quantity := p_inout_attributes.dummy_quantity;

  WSH_DETAILS_VALIDATIONS.get_min_max_tolerance_quantity
		(p_in_attributes  => l_minmaxinrectype,
		 x_out_attributes  => l_minmaxoutrectype,
		 p_inout_attributes  => l_minmaxinoutrectype,
		 x_return_status  => x_return_status,
		 x_msg_count  =>  x_msg_count,
		 x_msg_data => x_msg_data
		 );

  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Return status from WSH_DETAILS_VALIDATIONS.get_min_max_tolerance_quantity',x_return_status);
  END IF;

  IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     return;
  END IF;

  p_inout_attributes.dummy_quantity        := l_minmaxinoutrectype.dummy_quantity;
  p_out_attributes.quantity_uom            := l_minmaxoutrectype.quantity_uom;
  p_out_attributes.min_remaining_quantity  := l_minmaxoutrectype.min_remaining_quantity;
  p_out_attributes.max_remaining_quantity  := l_minmaxoutrectype.max_remaining_quantity;
  p_out_attributes.quantity2_uom           := l_minmaxoutrectype.quantity2_uom;
  p_out_attributes.min_remaining_quantity2 := l_minmaxoutrectype.min_remaining_quantity2;
  p_out_attributes.max_remaining_quantity2 := l_minmaxoutrectype.max_remaining_quantity2;

  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'p_inout_attributes.dummy_quantity', p_inout_attributes.dummy_quantity);
   WSH_DEBUG_SV.log(l_module_name,'p_out_attributes.quantity_uom',p_out_attributes.quantity_uom);
   WSH_DEBUG_SV.log(l_module_name,'p_out_attributes.min_remaining_quantity',p_out_attributes.min_remaining_quantity);
   WSH_DEBUG_SV.log(l_module_name,'p_out_attributes.max_remaining_quantity',p_out_attributes.max_remaining_quantity);
   WSH_DEBUG_SV.log(l_module_name,'p_out_attributes.quantity2_uom',p_out_attributes.quantity2_uom);
   WSH_DEBUG_SV.log(l_module_name,'p_out_attributes.min_remaining_quantity2',p_out_attributes.min_remaining_quantity2);
   WSH_DEBUG_SV.log(l_module_name,'p_out_attributes.max_remaining_quantity2',p_out_attributes.max_remaining_quantity2);
   WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
   WSH_DEBUG_SV.log(l_module_name,'x_msg_count',x_msg_count);
   WSH_DEBUG_SV.log(l_module_name,'x_msg_data',x_msg_data);
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Get_Min_Max_Tolerance_Quantity;


-- PROCEDURE GET_UNTRXD_SHPG_LINES_COUNT
--
-- Purpose : To Get the total Number of Untransacted Shipping Lines remaining ( which
--           are Shipped, and Delivery is in CLOSED or IN-TRANSIT status) for a
--           given set of dates (From Dt. and To Dt.).
--           Untransacted implies all delivery details in Shpg. which are in Shipped Status,
--            but are either not Inventory Interfaced or are pending Inv. Interface.
--           This is intended for a given Organization_id
--
-- Input   : p_in_attributes.closing_fm_date -> (usuall INV) PERIOD Closing From date;
--           p_in_attributes.closing_to_date -> (usuall INV) PERIOD Closing To   date;
--           p_in_attributes.organization_id -> Inventory Warehouse/Organization id;
--
-- Output  : p_out_attributes.untrxd_rec_count -> Total Number of Untransacted (Shipped) Delivery Dtls.
--           p_out_attributes.receiving_rec_count -> Total Number of Untransacted (Shipped) Delivery Dtls
--                   that are Receiving (incoming) - Direct Shipment or Intransit to Expense destinations.


PROCEDURE Get_Untrxd_Shpg_Lines_Count
                ( p_in_attributes           IN     ShpgUnTrxdInRecType,
                  p_out_attributes          OUT NOCOPY     ShpgUnTrxdOutRecType,
                  p_inout_attributes        IN OUT NOCOPY  ShpgUnTrxdInOutRecType,
                  x_return_status           OUT NOCOPY     VARCHAR2,
                  x_msg_count               OUT NOCOPY     NUMBER,
                  x_msg_data                OUT NOCOPY     VARCHAR2
                )
IS
  l_untrxd_rec_count                   NUMBER;
  l_rec_exp_count                      NUMBER;
  l_rec_direct_count                   NUMBER;
  l_closing_fm_date                    DATE;
  l_closing_to_date                    DATE;
  l_organization_id                    NUMBER;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_UNTRXD_SHPG_LINES_COUNT';
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
    WSH_DEBUG_SV.log(l_module_name,'api_version_number',p_in_attributes.api_version_number);
    WSH_DEBUG_SV.log(l_module_name,'source_code',p_in_attributes.source_code);
    WSH_DEBUG_SV.log(l_module_name,'closing_fm_date',p_in_attributes.closing_fm_date);
    WSH_DEBUG_SV.log(l_module_name,'closing_to_date',p_in_attributes.closing_to_date);
    WSH_DEBUG_SV.log(l_module_name,'organization_id',p_in_attributes.organization_id);
    WSH_DEBUG_SV.log(l_module_name,'dummy_count',p_inout_attributes.dummy_count);
  END IF;

     IF ( p_in_attributes.source_code IS NULL )
     THEN
         x_msg_count := 1;
         x_msg_data := 'INVALID SOURCE_CODE';
         x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

     l_closing_fm_date := p_in_attributes.closing_fm_date;
     l_closing_to_date := p_in_attributes.closing_to_date;
     l_organization_id := p_in_attributes.organization_id;

     BEGIN
        select count(*)
          into l_untrxd_rec_count
          from wsh_delivery_details wdd, wsh_delivery_assignments_v wda,
               wsh_new_deliveries wnd, wsh_delivery_legs wdl, wsh_trip_stops wts
         where
               wdd.source_code = 'OE'
           and wdd.released_status = 'C'
           and wdd.inv_interfaced_flag in ('N' ,'P')
           and wdd.organization_id = l_organization_id
           and wda.delivery_detail_id = wdd.delivery_detail_id
           and wnd.delivery_id = wda.delivery_id
           and wnd.status_code in ('CL','IT')
           and wdl.delivery_id = wnd.delivery_id
           and wts.pending_interface_flag in ('Y', 'P')
           and trunc(wts.actual_departure_date) between l_closing_fm_date and l_closing_to_date
           and wdl.pick_up_stop_id = wts.stop_id;

         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_untrxd_rec_count',l_untrxd_rec_count);
         END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_untrxd_rec_count := 0;

       WHEN OTHERS THEN
         l_untrxd_rec_count := null;
         x_msg_count := 1;
	 FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     END;
       BEGIN
        -- Check for Expense Destination Type Code Receiving Transactions
        select count(*)
          into l_rec_exp_count
          from wsh_delivery_details wdd, wsh_delivery_assignments wda,
               wsh_new_deliveries wnd, wsh_delivery_legs wdl, wsh_trip_stops wts,
               oe_order_lines_all oel, po_requisition_lines_all pl
         where
               wdd.source_code = 'OE'
           and wdd.released_status = 'C'
           and wdd.inv_interfaced_flag in ('N' ,'P')
           and wda.delivery_detail_id = wdd.delivery_detail_id
           and wnd.delivery_id = wda.delivery_id
           and wnd.status_code in ('CL','IT')
           and wdl.delivery_id = wnd.delivery_id
           and wts.pending_interface_flag in ('Y', 'P')
           and trunc(wts.actual_departure_date) between l_closing_fm_date and l_closing_to_date
           and wdd.source_line_id = oel.line_id
           and wdd.source_document_type_id = 10
           and oel.source_document_line_id = pl.requisition_line_id
           and pl.destination_organization_id = l_organization_id
           and pl.destination_organization_id <> pl.source_organization_id
           and pl.destination_type_code = 'EXPENSE'
           and wdl.pick_up_stop_id = wts.stop_id
           and wts.stop_location_id = wnd.initial_pickup_location_id;

         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_rec_exp_count',l_rec_exp_count);
         END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_rec_exp_count := 0;
       WHEN OTHERS THEN
         l_rec_exp_count := null;
         x_msg_count := 1;
	 FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     END;

     BEGIN
        -- Check for Direct Shipment which are not Expense Destination Type Code Related
        select count(*)
          into l_rec_direct_count
          from wsh_delivery_details wdd, wsh_delivery_assignments wda,
               wsh_new_deliveries wnd, wsh_delivery_legs wdl, wsh_trip_stops wts,
               oe_order_lines_all oel, po_requisition_lines_all pl,
               mtl_interorg_parameters mip
         where
               wdd.source_code = 'OE'
           and wdd.released_status = 'C'
           and wdd.inv_interfaced_flag in ('N' ,'P')
           and wda.delivery_detail_id = wdd.delivery_detail_id
           and wnd.delivery_id = wda.delivery_id
           and wnd.status_code in ('CL','IT')
           and wdl.delivery_id = wnd.delivery_id
           and wts.pending_interface_flag in ('Y', 'P')
           and trunc(wts.actual_departure_date) between l_closing_fm_date and l_closing_to_date
           and wdd.source_line_id = oel.line_id
           and wdd.source_document_type_id = 10
           and oel.source_document_line_id = pl.requisition_line_id
           and pl.destination_organization_id = l_organization_id
           and pl.destination_organization_id <> pl.source_organization_id
           and pl.destination_organization_id = mip.to_organization_id
           and pl.source_organization_id = mip.from_organization_id
           and mip.intransit_type = 1
           and pl.destination_type_code <> 'EXPENSE'
           and wdl.pick_up_stop_id = wts.stop_id
           and wts.stop_location_id = wnd.initial_pickup_location_id;

         IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_rec_direct_count',l_rec_direct_count);
         END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_rec_direct_count := 0;
       WHEN OTHERS THEN
         l_rec_direct_count := null;
         x_msg_count := 1;
	 FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     END;

     p_out_attributes.untrxd_rec_count := l_untrxd_rec_count;
     p_out_attributes.receiving_rec_count := NVL(l_rec_exp_count,0) + NVL(l_rec_direct_count,0);

   IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );

      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Get_Untrxd_Shpg_Lines_Count;

--2465199
-- PROCEDURE GET_NONINTF_SHPG_LINE_QTY
--
-- Purpose : To Get the total order line quantity that is not yet interfaced to Inventory
--
-- Input   : p_in_attributes.line_id         -> Order line id
--         : p_in_attributes.source_code     -> 'OE'
--
-- Output  : p_out_attributes.nonintf_line_qty : Total Order line Qty. not yet Interfaced to INV

PROCEDURE Get_NonIntf_Shpg_Line_Qty
                ( p_in_attributes           IN     LineIntfInRecType,
                  p_out_attributes          OUT NOCOPY     LineIntfOutRecType,
                  p_inout_attributes        IN OUT NOCOPY  LineIntfInOutRecType,
                  x_return_status           OUT NOCOPY     VARCHAR2,
                  x_msg_count               OUT NOCOPY     NUMBER,
                  x_msg_data                OUT NOCOPY     VARCHAR2
                )
IS
  l_nonintf_line_qty                   NUMBER;
  l_line_id                            NUMBER;
BEGIN

     --
     --
     IF ( p_in_attributes.source_code IS NULL )
     THEN
         x_msg_count := 1;
         x_msg_data := 'INVALID SOURCE_CODE';
         x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

     l_line_id := p_in_attributes.line_id;

     BEGIN
        select sum( nvl(shipped_quantity, nvl(picked_quantity, requested_quantity)) )
          into l_nonintf_line_qty
          from wsh_delivery_details wdd
         where
               wdd.source_code = 'OE'
           and wdd.inv_interfaced_flag in ('N' ,'P')
           and wdd.source_line_id = l_line_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_nonintf_line_qty := 0;

       WHEN OTHERS THEN
         l_nonintf_line_qty := null;
         x_msg_count := 1;
	 FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

     END;

     p_out_attributes.nonintf_line_qty := l_nonintf_line_qty;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count
        , p_data  => x_msg_data
        ,p_encoded => FND_API.G_FALSE
        );

END Get_Nonintf_Shpg_Line_Qty;

-- PROCEDURE Ins_Backorder_SS_SMC_Rec
--
-- Purpose : To insert the Ship Set or Ship Model line which has insufficient available quantity
--           and causes the backorder of the line. This will lead to other lines in Ship Set / SMC
--           to also become backordered, if the Enforce Ship Set / SMC is set in Shipping Parameters
--           Inventory will call this in such a scenario and will have 1 record for each Ship Set / SMC
--
-- Input   : p_api_version_number    -> Standard Version Number 1.0
--           p_source_code           -> Source code = 'INV'
--           p_init_msg_list         -> Should be initialized to TRUE by the caller
--           p_backorder_rec         -> Record containing Line information for Backordering
--
-- Output  : x_return_status         -> Return Status
--           x_msg_count             -> Error / Warning Message Count
--           x_msg_data              -> Error / Warning Message

PROCEDURE Ins_Backorder_SS_SMC_Rec (
                                         p_api_version_number  IN     NUMBER,
                                         p_source_code         IN     VARCHAR2,
                                         p_init_msg_list       IN     VARCHAR2,
                                         p_backorder_rec       IN     BackorderRecType,
                                         x_return_status       OUT NOCOPY     VARCHAR2,
                                         x_msg_count           OUT NOCOPY     NUMBER,
                                         x_msg_data            OUT NOCOPY     VARCHAR2
                                     )

IS

  l_cnt                    NUMBER;
  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30):= 'Ins_Backorder_SS_SMC_Rec';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INS_BACKORDER_SS_SMC_REC';
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
    WSH_DEBUG_SV.log(l_module_name,'p_api_version_number',p_api_version_number);
    WSH_DEBUG_SV.log(l_module_name,'p_source_code',p_source_code);
    WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',p_init_msg_list);
    WSH_DEBUG_SV.log(l_module_name,'move_order_line_id',p_backorder_rec.move_order_line_id);
    WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id',p_backorder_rec.delivery_detail_id);
    WSH_DEBUG_SV.log(l_module_name,'ship_set_id',p_backorder_rec.ship_set_id);
    WSH_DEBUG_SV.log(l_module_name,'ship_model_id',p_backorder_rec.ship_model_id);
  END IF;


     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    --  Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


     IF ( p_source_code IS NULL ) OR (p_source_code <> 'INV' ) THEN

         x_msg_count := 1;
         x_msg_data  := 'INVALID SOURCE CODE';
         x_return_status := FND_API.G_RET_STS_ERROR;

     ELSIF ( p_backorder_rec.move_order_line_id IS NULL AND p_backorder_rec.delivery_detail_id IS NULL )
     OR    ( p_backorder_rec.ship_set_id IS NULL AND p_backorder_rec.ship_model_id IS NULL ) THEN

         x_msg_count := 1;
         x_msg_data  := 'INVALID RECORD';
         x_return_status := FND_API.G_RET_STS_ERROR;

     ELSE

        l_cnt := G_BackorderRec_Tbl.LAST;

        IF l_cnt IS NULL THEN
           l_cnt := 1;
        ELSE
           l_cnt := l_cnt + 1;
        END IF;

        G_BackorderRec_Tbl(l_cnt).move_order_line_id := p_backorder_rec.move_order_line_id;
        G_BackorderRec_Tbl(l_cnt).delivery_detail_id := p_backorder_rec.delivery_detail_id;
        G_BackorderRec_Tbl(l_cnt).ship_set_id        := p_backorder_rec.ship_set_id;
        G_BackorderRec_Tbl(l_cnt).ship_model_id      := p_backorder_rec.ship_model_id;

      END IF;

   IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
   END IF;
EXCEPTION

   WHEN OTHERS THEN

         FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

       IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

END Ins_Backorder_SS_SMC_Rec;

/*
** -- The below API has been copied from WMS.
*/
--  NOTES
--
--  HISTORY
--
--  05-June-2002 Created By Johnson Abraham (joabraha@us)

-- This is the final version.
--

PROCEDURE trace(p_message IN VARCHAR2) iS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRACE';
--
BEGIN
	-- Please replace this call to the one used by shipping.
	--INV_LOG_UTIL.trace(p_message, 'WSH_PRINTER_ASSG', 1);

        -- replaced as required
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'p_message');
        END IF;
END trace;

PROCEDURE update_printer_assignment(
		x_msg_count		OUT NOCOPY  NUMBER
	,	x_msg_data		OUT NOCOPY  VARCHAR2
	,	x_return_status		OUT NOCOPY  VARCHAR2
	, 	p_application_id	IN NUMBER
	,	p_conc_program_id	IN NUMBER
	,	p_level_type_id		IN NUMBER
	,	p_level_value_id	IN NUMBER
	,	p_organization_id	IN NUMBER
	,	p_printer_name		IN VARCHAR2
	,	p_enabled_flag		IN VARCHAR2
) IS

l_api_name CONSTANT VARCHAR2(100) := 'update_printer_assignment';

l_enabled_flag	WSH_REPORT_PRINTERS.enabled_flag%TYPE := null;
l_default_printer_flag	WSH_REPORT_PRINTERS.default_printer_flag%TYPE := null;

l_min_label_type_id 	NUMBER := 1;
l_max_label_type_id 	NUMBER := 0;
loop_counter 		NUMBER := 0;

l_label_type_id 	NUMBER := 0;
l_application_id	NUMBER := null;

l_printer_signed_on NUMBER := 0;

CURSOR c_printer_enabled(v_application_id NUMBER, v_label_type_id NUMBER) IS
SELECT enabled_flag, default_printer_flag
FROM   WSH_REPORT_PRINTERS
WHERE  application_id = v_application_id
AND    concurrent_program_id = v_label_type_id
AND    level_type_id = p_level_type_id
AND    level_value_id = p_level_value_id
AND    printer_name = p_printer_name;

CURSOR c_get_max_label_type_id IS
SELECT max(lookup_code)
FROM   mfg_lookups
WHERE  lookup_type = 'WMS_LABEL_TYPE';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_PRINTER_ASSIGNMENT';
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
        WSH_DEBUG_SV.start_debug();
        IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
         WSH_DEBUG_SV.log(l_module_name,'p_application_id',p_application_id);
         WSH_DEBUG_SV.log(l_module_name,'p_conc_program_id',p_conc_program_id);
         WSH_DEBUG_SV.log(l_module_name,'p_level_type_id',p_level_type_id);
         WSH_DEBUG_SV.log(l_module_name,'p_level_value_id',p_level_value_id);
         WSH_DEBUG_SV.log(l_module_name,'p_organization_id',p_organization_id);
         WSH_DEBUG_SV.log(l_module_name,'p_printer_name',p_printer_name);
         WSH_DEBUG_SV.log(l_module_name,'p_enabled_flag',p_enabled_flag);
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_application_id := p_application_id;

	trace('******** Mobile Printer Sign On **********');

	trace('p_application_id passed in = ' || p_application_id);
	trace('p_conc_program_id passed in = ' || p_conc_program_id);
	trace('p_level_type_id passed in = ' || p_level_type_id);
	trace('p_level_value_id passed in = ' || p_level_value_id);
	trace('p_organization_id passed in = ' || p_organization_id);
	trace('p_printer_name passed in = ' || p_printer_name);
	trace('p_enabled_flag passed in = ' || p_enabled_flag);

	IF (p_enabled_flag = 'Y') AND (p_printer_name IS NULL) THEN
		trace('Printer name is required for enabling');
		FND_MESSAGE.SET_NAME('WSH', 'WSH_PRINTER_NAME_REQUIRED');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get( p_count =>  x_msg_count
		                 	 , p_data  =>  x_msg_data );
		x_return_status := fnd_api.g_ret_sts_error;
                IF l_debug_on THEN
                 wsh_debug_sv.pop(l_module_name,'RETURN');
                END IF;

		RETURN;
	END IF;

	-- When signing off a printer, check to see whether this printer has been signed on
	-- If this printer is not signed on for any type, given error message and return.
	-- This SELECT checks to see if there is atleast a single label type enabled for this printer.
	-- In case the user is signing off this printer for all label types, the "p_conc_program_id"
	-- is null and so the "concurrent_program_id = nvl(p_conc_program_id, concurrent_program_id)"
	-- results in a true.
	-- The advantage of having this check outside of the loop is that the message pops up only for
	-- cases where a printer name is specified.
	-- A good test case for this would be to enable a printer for multiple label types and test.
	-- In cases of signing off all printers for all label types, this part of the code is not executed
	-- and so the messages don't pop up.
	IF  (p_printer_name IS NOT NULL) AND
		(nvl(p_enabled_flag,'N') = 'N') THEN
		trace('When signing off a specific printer, check whether this printer has been signed on');

		BEGIN
			SELECT 1 INTO l_printer_signed_on FROM dual
			WHERE EXISTS
	    		(SELECT 1
 				 FROM wsh_report_printers
 				 WHERE enabled_flag ='Y'
 				 AND nvl(default_printer_flag,'N') ='Y'
 				 AND concurrent_program_id = nvl(p_conc_program_id, concurrent_program_id)
 				 AND level_type_id = p_level_type_id
 				 AND level_value_id = p_level_value_id
 				 AND printer_name = p_printer_name);
 		EXCEPTION
 			WHEN NO_DATA_FOUND THEN
 				trace('Printer is not signed on');
                                wsh_debug_sv.pop(l_module_name);
				FND_MESSAGE.SET_NAME('WSH', 'WSH_PRINTER_NOT_SIGNON');
				FND_MSG_PUB.ADD;
				FND_MSG_PUB.Count_And_Get( p_count =>  x_msg_count
							 , p_data  =>  x_msg_data );
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                                IF l_debug_on THEN
                                 wsh_debug_sv.pop(l_module_name,'RETURN');
                                END IF;
				RETURN;
		END;
		trace('printer has been signed on, continue signing off');
 	END IF;


	IF p_conc_program_id IS NULL THEN
	-- Check to see if the concurrent program ID(Label Type ID) is null.
	-- This means for all label types.
	        trace('Enabling/Disabling printer(s) for all label types');
		l_min_label_type_id := 1;

		OPEN  c_get_max_label_type_id;
		FETCH c_get_max_label_type_id
		INTO  l_max_label_type_id;

		CLOSE c_get_max_label_type_id;
	ELSE
		l_min_label_type_id := p_conc_program_id;
		l_max_label_type_id := p_conc_program_id;
	END IF;

	trace('Got min_label_type_id = '|| l_min_label_type_id);
	trace('Got max_label_type_id = '|| l_max_label_type_id);
	loop_counter := 1;
	FOR l_label_type_id IN l_min_label_type_id..l_max_label_type_id LOOP
	-- Looping for every label type id retrieved
		trace('p_conc_program_id = ' || l_label_type_id);
		trace('In Loop ' || loop_counter);

		trace('Deriving Application ID');
		IF l_label_type_id in (3,4,5,9) THEN
			l_application_id := 385;
			trace('label_type_id = '|| l_label_type_id || '  Application ID Derived = ' || l_application_id);
		ELSE
			l_application_id := 401;
			trace('label_type_id = '|| l_label_type_id || '  Application ID Derived = ' || l_application_id);
		END IF;

		trace('p_application_id = ' || l_application_id);
		trace('p_conc_program_id = ' || l_label_type_id);

		IF (p_enabled_flag = 'Y') THEN
		-- Trying to enable a printer/user/doc relationship
		-- Check for existing records that match the App_id, conc_prog_id, level_type_id, level_value_id,
		-- printer name in the WSH_REPORT_PRINTERS.

			trace('Inside p_enabled_flag = Y  Enabling Printer ');

			OPEN  c_printer_enabled(l_application_id, l_label_type_id);
			FETCH c_printer_enabled INTO l_enabled_flag, l_default_printer_flag;

			trace(' l_enabled_flag is ' || l_enabled_flag);
			trace(' l_default_printer_flag ' || l_default_printer_flag);

			IF c_printer_enabled%NOTFOUND THEN
			--IF (l_enabled_flag <> 'Y') OR (nvl(l_default_printer_flag, 'N') <> 'Y') THEN
			-- Check to see if the printer is already enabled.

				trace('No Records exist for this combination');
				trace('Inserting new record for the combination');

				-- Insert the new relation into the table.
				INSERT INTO WSH_REPORT_PRINTERS
				( 	application_id
				,	concurrent_program_id
				,	level_type_id
				,	level_value_id
				,	printer_name
				,	description
				,	enabled_flag
				,	attribute_category
				,	attribute1
				,	attribute2
				,	attribute3
				,	attribute4
				,	attribute5
				,	attribute6
				,	attribute7
				,	attribute8
				,	attribute9
				,	attribute10
				,	attribute11
				,	attribute12
				,	attribute13
				,	attribute14
				,	attribute15
				,	creation_date
				,	created_by
				,	last_update_date
				,	last_updated_by
				,	last_update_login
				,	request_id
				,	program_application_id
				,	program_id
				,	program_update_date
				,	label_id
				,	format_type
				,	equipment_instance
				,	organization_id
				,	subinventory
				,	default_printer_flag)
				VALUES(
					l_application_id
				,	l_label_type_id
				,	p_level_type_id
				,	p_level_value_id
				,	p_printer_name
				,	null
				,	p_enabled_flag
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	sysdate
				,	FND_GLOBAL.user_id
				,	sysdate
				,	FND_GLOBAL.user_id
				,	FND_GLOBAL.user_id
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	null
				,	'Y');
				trace('Record inserted');
			ELSE
				trace('Record already exists');
				IF (l_enabled_flag <> 'Y') OR (nvl(l_default_printer_flag, 'N') <> 'Y') THEN
				-- Check to see if the printer is already enabled.

					trace('Updating existing record for the combination');
					-- Relationship exists already.
					-- Now the printer is also marked as the default printer for the user.

					UPDATE 	WSH_REPORT_PRINTERS
					SET 	enabled_flag = 'Y',
						default_printer_flag = 'Y'
					WHERE  	application_id = l_application_id
					AND	concurrent_program_id = l_label_type_id
					AND	level_type_id = p_level_type_id
					AND	level_value_id = p_level_value_id
					AND	printer_name = p_printer_name;
					trace('Record updated');
				ELSE
					trace('Printer ' ||p_printer_name||' is already enabled');
				END IF;
			END IF;

			trace('Update printers other than the current one to be not default');
			-- Reset the current default_printer for this user since the newly enabled printer
			-- will also be the default printer for this user.

			-- In this update, set the default_printer_flag to 'N' so that any printer
			-- with the enabled_flag earlier is left untouched. The currently enabled printer
			-- is a combination of the "enabled_flag" and the "default_printer_flag" set to 'Y'.
			UPDATE 	WSH_REPORT_PRINTERS
			SET 	enabled_flag = 'N',
				default_printer_flag = null
			WHERE  	application_id = l_application_id
			AND	concurrent_program_id = l_label_type_id
			AND	level_type_id = p_level_type_id
			AND	level_value_id = p_level_value_id
			AND     printer_name <> p_printer_name;
			CLOSE c_printer_enabled;
			trace('Record updated');

		ELSIF (p_enabled_flag = 'N')   THEN
		-- Trying to disable all printer/user/doc relationship for that user
		-- Trying to disable a specific printer/user/doc relationship
		-- This is for the case where printers are being disabled for multiple label types,
		-- (label type id null passed in), application id.

			trace('Disabling all printers or the specific printer');

			-- Check to see if a printer name is passed in.
			-- If yes, then check to see if a record exists for the printer for the user
			-- and enable only if the printer has already been disabled.

			trace('Inside p_enabled_flag = N');
			UPDATE WSH_REPORT_PRINTERS
			SET  enabled_flag = 'N',
			     default_printer_flag = null
			WHERE application_id = l_application_id
			AND concurrent_program_id = l_label_type_id
			AND level_type_id = p_level_type_id
			AND level_value_id = p_level_value_id
			AND printer_name = nvl(p_printer_name, printer_name);
			trace('Record updated');

		END IF;
		loop_counter := loop_counter + 1;

	END LOOP;
	COMMIT;
        IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name);
         wsh_debug_sv.stop_debug;
        END IF;
EXCEPTION
      WHEN fnd_api.g_exc_error THEN
      	trace(' Expected Error In '|| G_PKG_NAME||'.' || l_api_name);
	trace('ERROR CODE = ' || SQLCODE);
	trace('ERROR MESSAGE = ' || SQLERRM);
        IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name);
         wsh_debug_sv.stop_debug;
        END IF;
	ROLLBACK;

      WHEN fnd_api.g_exc_unexpected_error THEN
      	trace(' Unexpected Error In '|| G_PKG_NAME||'.' || l_api_name);
	trace('ERROR CODE = ' || SQLCODE);
	trace('ERROR MESSAGE = ' || SQLERRM);
        IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name);
         wsh_debug_sv.stop_debug;
        END IF;
	ROLLBACK;

      WHEN others THEN
      	trace(' Other Error In '|| G_PKG_NAME||'.' || l_api_name);
      	trace('ERROR CODE = ' || SQLCODE);
	trace('ERROR MESSAGE = ' || SQLERRM);
        IF l_debug_on THEN
         wsh_debug_sv.pop(l_module_name);
         wsh_debug_sv.stop_debug;
        END IF;
	ROLLBACK;

END update_printer_assignment;

-- For the issue in bug 2678601 porting to Pack I

PROCEDURE Set_Inv_PC_Attributes
                ( p_in_attributes           IN         InvPCInRecType,
                  x_return_status           OUT NOCOPY VARCHAR2,
                  x_msg_count               OUT NOCOPY NUMBER,
                  x_msg_data                OUT NOCOPY VARCHAR2
                )
IS

  l_api_version_number     CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30):= 'Set_Inv_PC_Attributes';

BEGIN
     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    --  Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_in_attributes.api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF ( p_in_attributes.source_code IS NULL ) OR (p_in_attributes.source_code
    <> 'INV' ) THEN
         x_msg_count := 1;
         x_msg_data  := 'INVALID SOURCE CODE';
         x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
       G_InvPCRec.transaction_id      := p_in_attributes.transaction_id;
       G_InvPCRec.transaction_temp_id := p_in_attributes.transaction_temp_id;
     END IF;

EXCEPTION

   WHEN OTHERS THEN

         FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Set_Inv_PC_Attributes;

PROCEDURE Get_Inv_PC_Attributes
                ( p_out_attributes          OUT NOCOPY InvPCOutRecType,
                  x_return_status           OUT NOCOPY VARCHAR2,
                  x_msg_count               OUT NOCOPY NUMBER,
                  x_msg_data                OUT NOCOPY VARCHAR2
                ) IS
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  p_out_attributes.transaction_id      := G_InvPCRec.transaction_id;
  p_out_attributes.transaction_temp_id := G_InvPCRec.transaction_temp_id;

EXCEPTION

   WHEN OTHERS THEN

         FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Inv_PC_Attributes;

-- DBI Project, Added in 11.5.10+
--
--===============================================
-- Name   :   DBI_Installed
-- Purpose:   To check if DBI is installed,
-- History:   Added in 11i10+
--
-- Input Arguments: None
-- Output Arguments: Varchar2(1) indicating Y or N
--
--===============================================
Function DBI_Installed return VARCHAR2 is
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DBI_INSTALLED';
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
        --
  IF G_DBI_IS_INSTALLED IS NULL THEN
    G_DBI_IS_INSTALLED  := (NVL(FND_PROFILE.VALUE('ISC_WSH_FTE_DBI_INSTALLED'), 'N'));
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'G_DBI_IS_INSTALLED',G_DBI_IS_INSTALLED);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  RETURN G_DBI_IS_INSTALLED ;

EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
     wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,l_module_name);
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END DBI_Installed;

--========================================================
-- DataType Conversion APIs , DBI Project
-- 1. Convert WSH table of ids to DBI Table of ids
--=========================================================

-- 1.Convert WSH Table of ids to DBI Table of ids
PROCEDURE WSH_ID_TAB_TO_DBI_ID_TAB
  (p_wsh_id_tab IN WSH_UTIL_CORE.id_tab_type,
   x_dbi_id_tab OUT NOCOPY ISC_DBI_CHANGE_LOG_PKG.log_tab_type,
   x_return_status OUT NOCOPY VARCHAR2
  ) IS

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'WSH_ID_TAB_TO_DBI_ID_TAB';
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Count Input records',p_wsh_id_tab.count);
  END IF;

  -- Conversion is required from WSH datatype to DBI datatype
  -- Use the same counter while adding records in x_dbi_tab
  FOR i in p_wsh_id_tab.FIRST..p_wsh_id_tab.LAST
  LOOP
    x_dbi_id_tab(i) := p_wsh_id_tab(i);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Id being converted-',p_wsh_id_tab(i));
    END IF;
  END LOOP;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Count Output records',x_dbi_id_tab.count);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.add_message(x_return_status,l_module_name);
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END WSH_ID_TAB_TO_DBI_ID_TAB;

--===============================================
-- Name   :   DBI_Update_Detail_Log
-- Purpose:   Call DBI for update in wsh_delivery_details table
-- History:   Added in 11i10+. Actions covered are
--              1. Update of Requested Quantity
--              2. Update of Requested Quantity UOM
--              3. Update of Released Status
--
-- Input Arguments:
--              p_delivery_detail_tab - Table of Delivery Detail ids
--              p_dml_type            - DML type (INSERT/UPDATE/DELETE)
-- Output Arguments:
--              x_return_status       - Return Status
--
--===============================================
PROCEDURE DBI_Update_Detail_Log
  (p_delivery_detail_id_tab IN WSH_UTIL_CORE.id_tab_type,
   p_dml_type               IN VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2) IS

  l_dbi_detail_list ISC_DBI_CHANGE_LOG_PKG.log_tab_type;
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DBI_UPDATE_DETAIL_LOG';BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Before Calling DBI API-',x_return_status);
    WSH_DEBUG_SV.log(l_module_name,'Count Detail records-',p_delivery_detail_id_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'DML Type-',p_dml_type);
  END IF;
  --
  -- Check if DBI is installed, possible values are Y or N only
  -- If not installed, then do not proceed , return Success
  -- Also, atleast 1 record should be populated in the Input table
  IF (WSH_INTEGRATION.DBI_Installed = 'N' OR
      p_delivery_detail_id_tab.count < 1)
  THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'DBI Installed flag-',WSH_INTEGRATION.DBI_Installed);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;
  --
  -- Conversion is required from WSH datatype to DBI datatype
  WSH_ID_TAB_TO_DBI_ID_TAB
    (p_wsh_id_tab    => p_delivery_detail_id_tab,
     x_dbi_id_tab    => l_dbi_detail_list,
     x_return_status => x_return_status);

  IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Count Detail records-',l_dbi_detail_list.count);
      WSH_DEBUG_SV.log(l_module_name,'Before Calling DBI API-',x_return_status);
    END IF;
    --
    ISC_DBI_CHANGE_LOG_PKG.Update_Del_Detail_Log
      (p_detail_list          =>  l_dbi_detail_list,
       p_dml_type             =>  p_dml_type,
       x_return_status        =>  x_return_status
      );
    --
    -- Only Unexpected error can be raised from DBI API,
    -- all others have to be treated as success and code flow
    -- will continue and not rollback
    IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_INCOMPLETE_TRANSACTION');
      WSH_UTIL_CORE.Add_Message(x_return_status);
    ELSE -- all other Statuses are equivalent to Success
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.add_message(x_return_status,l_module_name);

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END DBI_Update_Detail_Log;


--===============================================
-- Name   :   DBI_Update_Trip_Stop_Log
-- Purpose:   Call DBI for creation/deletion/update of Stop,Delivery Leg
-- History:   Added in 11i10+. Actions covered are
--              1. Create Trip Stop
--              2. Delete Trip Stop
--              3. Update of Stop Actual Departure Date
--              4. Update of Stop Actual Arrival Date
--              5. Update of Stop Status
--              6. Update of Planned Arrival Date
--              7. Assign Delivery to Trip(create delivery leg)
--              8. Unassign Delivery from Trip(delete delivery leg)
--              9. Update of Freight Cost of delivery leg
--             10. Change in Trip Status (corresponds to change in Stop status)
--
-- Input Arguments:
--              p_delivery_detail_tab - Table of Delivery Detail ids
--              p_dml_type            - DML type (INSERT/UPDATE/DELETE)
-- Output Arguments:
--              x_return_status       - Return Status
--
--===============================================
PROCEDURE DBI_Update_Trip_Stop_Log
  (p_stop_id_tab         IN WSH_UTIL_CORE.id_tab_type,
   p_dml_type            IN VARCHAR2,
   x_return_status       OUT NOCOPY VARCHAR2) IS

  l_dbi_stop_list ISC_DBI_CHANGE_LOG_PKG.log_tab_type;
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.'||G_PKG_NAME||'.'||'DBI_UPDATE_TRIP_STOP_LOG';
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Count Stop records-',p_stop_id_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'DML Type-',p_dml_type);
  END IF;
  --
  -- Check if DBI is installed, possible values are Y or N only
  -- If not installed, then do not proceed , return Success
  -- Also, atleast 1 record should be populated in the Input table
  IF (WSH_INTEGRATION.DBI_Installed = 'N' OR
      p_stop_id_tab.count < 1)
  THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'DBI Installed flag-',WSH_INTEGRATION.DBI_Installed);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;
  --
  -- Conversion is required from WSH datatype to DBI datatype
  WSH_ID_TAB_TO_DBI_ID_TAB
    (p_wsh_id_tab    => p_stop_id_tab,
     x_dbi_id_tab    => l_dbi_stop_list,
     x_return_status => x_return_status);

  IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Count Stop records-',l_dbi_stop_list.count);
      WSH_DEBUG_SV.log(l_module_name,'Before Calling DBI API-',x_return_status);
    END IF;
    --
    ISC_DBI_CHANGE_LOG_PKG.Update_Trip_Stop_Log
      (p_stop_list          =>  l_dbi_stop_list,
       p_dml_type           =>  p_dml_type,
       x_return_status      =>  x_return_status
      );
    --
    -- Only Unexpected error can be raised from DBI API,
    -- all others have to be treated as success and code flow
    -- will continue and not rollback
    IF x_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('WSH','WSH_INCOMPLETE_TRANSACTION');
      WSH_UTIL_CORE.Add_Message(x_return_status);
    ELSE -- all other Statuses are equivalent to Success
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     wsh_util_core.add_message(x_return_status,l_module_name);

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END DBI_Update_Trip_Stop_Log;

-- X-dock
-- Procedure Name    : Find_Matching_Groups
-- Description       : This API will find entities (deliveries/containers) that
--                     match the grouping criteria of the input table of entities.
-- p_attr_tab        : Table of entities or record of grouping criteria that need to be matched.
-- p_action_rec      : Record of specific actions and their corresponding parameters.
--                     check_single_grp_only:  ('Y', 'N') will  check only of the records can be
--                     grouped together.
-- output_entity_type: ('DLVY', 'CONT') the entity type that the input records
--                     need to be matched with.
-- output_format_type: Format of the output.
--                     'ID_TAB': table of id's of the matched entities
--                     'TEMP_TAB': The output will be inserted into wsh_temp (wsh_temp
--                                 needs to be cleared after this API has been used).
--                     'SQL_STRING': Will return a SQL query to find the matching entities
--                                   as a string and values of the variables that will
--                                   need to be bound to the string.
-- p_target_rec      : Entity or grouping attributes that need to be matched with (if necessary)
-- x_matched_entities: table of ids of the matched entities
-- x_out_rec         : Record of output values based on the actions and output format.
--                     query_string: String to query for matching entities.
-- x_return_status   : 'S', 'E', 'U'.

procedure Find_Matching_Groups
          (p_attr_tab         IN OUT NOCOPY GRP_ATTR_TAB_TYPE,
           p_action_rec       IN ACTION_REC_TYPE,
           p_target_rec       IN GRP_ATTR_REC_TYPE,
           p_group_tab        IN OUT NOCOPY GRP_ATTR_TAB_TYPE,
           x_matched_entities OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
           x_out_rec          OUT NOCOPY OUT_REC_TYPE,
           x_return_status    OUT NOCOPY VARCHAR2) IS

-- Local variables to move information from or to the variables
l_attr_tab   WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
l_action_rec WSH_DELIVERY_AUTOCREATE.action_rec_type;
l_target_rec WSH_DELIVERY_AUTOCREATE.grp_attr_rec_type;
l_group_tab WSH_DELIVERY_AUTOCREATE.grp_attr_tab_type;
l_out_rec WSH_DELIVERY_AUTOCREATE.out_rec_type;
l_del_det_id WSH_DELIVERY_DETAILS.delivery_detail_id%type;
l_org_id WSH_DELIVERY_DETAILS.organization_id%type;
l_param_info  WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Find_Matching_Groups';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'p_action_rec.action', p_action_rec.action);
      WSH_DEBUG_SV.log(l_module_name, 'p_action_rec.output_format_type', p_action_rec.output_format_type);
      WSH_DEBUG_SV.log(l_module_name, 'p_attr_tab count' , p_attr_tab.count);
      WSH_DEBUG_SV.log(l_module_name, 'p_group_tab count', p_group_tab.count);
      WSH_DEBUG_SV.log(l_module_name, 'p_target_rec.entity_type', p_target_rec.entity_type);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --
  -- Wrapper on top of WSHDEAUB.find_matching_groups
  --
  l_attr_tab.delete;
  l_group_tab.delete;

  -- Move information from p_attr_tab to l_attr_tab
  l_attr_tab := p_attr_tab;

  -- Move information from p_action_rec to l_p_action_rec
  l_action_rec := p_action_rec;

  -- Move information from p_target_rec to l_p_target_rec
  l_target_rec := p_target_rec;

  -- Move information from p_group_tab to l_group_tab
  IF p_group_tab.COUNT > 0 THEN
    l_group_tab := p_group_tab;
  END IF;

  --Bug : 6911078 : Check for Appending_limit to get the matching deliveries : Start
  IF l_action_rec.action = 'MATCH_GROUPS' AND l_target_rec.entity_type = 'DELIVERY' THEN
  --{
      IF l_debug_on THEN
      --{
          WSH_DEBUG_SV.log(l_module_name, 'p_attr_tab.count for ''MATCH_GROUPS'' is ', l_attr_tab.COUNT);
      --}
      END IF;

      IF l_attr_tab.COUNT > 1 THEN
      --{
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_on THEN
          --{
              WSH_DEBUG_SV.log(l_module_name, 'p_attr_tab.count for ''MATCH_GROUPS'' > 1 and hence exiting..');
              WSH_DEBUG_SV.pop(l_module_name);
          --}
          END IF;
          RETURN;
      --}
      END IF;

      l_del_det_id := l_attr_tab(l_attr_tab.FIRST).entity_id ;

      -- Check for delivery_detail_id > 0
      IF NVL(l_del_det_id,0) > 0  THEN
      --{
          -- Delivery appending limit 'N' check goes in this block.
          BEGIN

              SELECT organization_id INTO l_org_id FROM wsh_delivery_details WHERE delivery_detail_id = l_del_det_id;
              -- Call wsh_shipping_parameters.Get for appending_limit
              IF l_debug_on THEN
              --{
                  WSH_DEBUG_SV.log(l_module_name, 'l_org_id', l_org_id);
                  WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.GET',WSH_DEBUG_SV.C_PROC_LEVEL);
              --}
              END IF;

              WSH_SHIPPING_PARAMS_PVT.GET(p_organization_id => l_org_id,
                                          x_param_info => l_param_info,
                                          x_return_status => x_return_status);

              IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
              --{
                  IF l_debug_on THEN
                  --{
                      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
                      WSH_DEBUG_SV.pop(l_module_name);
                  --}
                  END IF;
                  RETURN;
              --}
              END IF;

              IF l_debug_on THEN
              --{
                  WSH_DEBUG_SV.log(l_module_name, 'Appending Limit', l_param_info.APPENDING_LIMIT );
              --}
              END IF;

              IF l_param_info.APPENDING_LIMIT = 'N' THEN
              --{
                  IF l_debug_on THEN
                  --{
                      WSH_DEBUG_SV.log(l_module_name, 'Append Limit is ''Do not append'' and hence exiting..');
                      WSH_DEBUG_SV.pop(l_module_name);
                  --}
                  END IF;
                  RETURN;
              --}
              END IF;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_on THEN
                  --{
                      WSH_DEBUG_SV.log(l_module_name, 'Delivery Detail doesnt exists in WDD',  l_del_det_id);
                      WSH_DEBUG_SV.pop(l_module_name);
                  --}
                  END IF;
                  RETURN;

              WHEN OTHERS THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_on THEN
                  --{
                      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                  --}
                  END IF;
                  RETURN;
          END;

      ELSE    -- Delivery Detail is Invalid
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_on THEN
          --{
              WSH_DEBUG_SV.logmsg(l_module_name,'Invalid Delivery_detail_id',l_del_det_id);
              WSH_DEBUG_SV.pop(l_module_name);
          --}
          END IF;
          RETURN;
      --}
      END IF;
      -- Check for delivery_detail_id > 0
  END IF;
  --Bug : 6911078 : Check for Appending_limit to get the matching deliveries : End

  WSH_DELIVERY_AUTOCREATE.FIND_MATCHING_GROUPS
    (p_attr_tab         => l_attr_tab,
     p_action_rec       => l_action_rec,
     p_target_rec       => l_target_rec,
     p_group_tab        => l_group_tab,
     x_matched_entities => x_matched_entities,
     x_out_rec          => l_out_rec,
     x_return_status    => x_return_status);

  IF x_return_status in (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ) THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;

  -- Move information from l_attr_tab back to p_attr_tab, IN OUT variable
  p_attr_tab := l_attr_tab;
  -- Move informaiton from l_group_tab back to p_group_tab, IN OUT variable
  p_group_tab := l_group_tab;

  -- Move information from l_out_rec to x_out_rec
  x_out_rec := l_out_rec;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
    wsh_debug_sv.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := wsh_util_core.g_ret_sts_unexp_error;
     wsh_util_core.default_handler('WSH_INTEGRATION.FIND_MATCHING_GROUPS',l_module_name);
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END find_matching_groups;

-- end of X-dock changes

 -- 5870774
 -- Procedure Get_Cancel_Qty_Allowed is to get the Unshipped Qty. on any Source Line id that
 --  is allowed to be Cancelled. The Unshipped Qty. is from all the underlying Delivery Details
 --  that do not belong to Any Delivery that is either in 'CO'nfirmed, 'CL'osed or 'InTransit' status
 -- Input :
 --          p_source_code      --  Source Code of the Application Calling this Procedure
 --        		     	   e.g. 'OKE'
 --          p_source_line_id   --  Source Line id of Source Line for which the Qty. cancellable is to be
 -- 			           determined
 --
 -- Output :
 --          x_cancel_qty_allowed  -- Qty. that is allowed to be Cancelled in Source Ordered Qty. UOM
 --                                   If there is No Qty. that can be cancelled, then this parameter will return 0 (Zero)
 --
 --          x_return_status     --   Return Status [ Fnd api- Return Status: Sucess, Error , UnExpected Error ]
 --          x_msg_count,data    --   Number of Messages, Message Data Stored
 PROCEDURE Get_Cancel_Qty_Allowed
                ( p_source_code             IN  VARCHAR2,
                  p_source_line_id          IN  NUMBER,
                  x_cancel_qty_allowed      OUT NOCOPY NUMBER,
                  x_return_status           OUT NOCOPY VARCHAR2,
                  x_msg_count               OUT NOCOPY NUMBER,
                  x_msg_data                OUT NOCOPY VARCHAR2
                 )
 IS
 --
 l_cancel_qty_allowed             number;
 l_src_cancel_qty_allowed         number;
 l_requested_quantity_uom         wsh_delivery_details.src_requested_quantity_uom%type;
 l_src_requested_quantity_uom     wsh_delivery_details.src_requested_quantity_uom%type;
 l_cancel_allowed_quantity        number;
 l_inventory_item_id              number;
   --
 l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CANCEL_QTY_ALLOWED';
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
     WSH_DEBUG_SV.log(l_module_name,'source_code ',p_source_code);
     WSH_DEBUG_SV.log(l_module_name,'src line id ',p_source_line_id);
   END IF;

   IF ( p_source_code IS NULL )
   THEN
      x_msg_count := 1;
      x_msg_data := 'INVALID SOURCE_CODE';
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'Invalid source code: ', p_source_code);
             WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      return;
   END IF;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   BEGIN
          -- select stmt.

          select sum(wdd.requested_quantity) , requested_quantity_uom, src_requested_quantity_uom, inventory_item_id
          into  l_cancel_qty_allowed , l_requested_quantity_uom, l_src_requested_quantity_uom, l_inventory_item_id
          from wsh_delivery_details wdd
          where
                wdd.source_line_id = p_source_line_id
            and wdd.source_code   =  p_source_code
            and not exists (select 'x' from
                wsh_delivery_assignments wda,
                wsh_new_deliveries wnd
                where
                       wda.delivery_detail_id = wdd.delivery_detail_id
                  and  wda.delivery_id  = wnd.delivery_id
                  and  wnd.status_code in ('CL','CO', 'IT') )
          group by requested_quantity_uom, src_requested_quantity_uom, inventory_item_id;
          --
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          x_cancel_qty_allowed  := 0;
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name, 'No Data Found. Req. Qty. allowed to be cancelled'||to_char(x_cancel_qty_allowed) );
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       FND_MESSAGE.SET_NAME('WSH', 'WSH_LINE_CANCEL_NOT_ALLOWED');
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get( p_count =>  x_msg_count
 	                 	, p_data  =>  x_msg_data );
       x_return_status := fnd_api.g_ret_sts_error;
       return;
     END;
     --
     x_cancel_qty_allowed  := l_cancel_qty_allowed;
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'l_cancel_qty_allowed: '||to_char(l_cancel_qty_allowed) );
     end if;
     --
     -- Need to do UOM conversion of the Quantity if SRc and REq. differ.
     -- and if there are any Cancellable Qtys.
     --
     IF ( (nvl(l_cancel_qty_allowed,0) > 0) and (l_src_requested_quantity_uom <> l_requested_quantity_uom) ) then
     --{
        l_src_cancel_qty_allowed := WSH_WV_UTILS.convert_uom(from_uom => l_requested_quantity_uom,
                                                            to_uom => l_src_requested_quantity_uom,
                                                          quantity => l_cancel_qty_allowed ,
                                                           item_id => l_inventory_item_id       );
        --
        x_cancel_qty_allowed  := l_src_cancel_qty_allowed;
        --
        IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'SRC Req. Qty. UOM: '||l_src_requested_quantity_uom );
              WSH_DEBUG_SV.log(l_module_name, 'Req. Qty. UOM: '||l_requested_quantity_uom );
              WSH_DEBUG_SV.log(l_module_name, 'SRC Req. Qty. allowed to be cancelled: '||l_src_cancel_qty_allowed);
        end if;
    END IF;  --}
    --

    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'Req. Qty. allowed to be cancelled'||to_char(x_cancel_qty_allowed) );
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status '||x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
    END IF;

 EXCEPTION

   WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count
         , p_data  => x_msg_data
         ,p_encoded => FND_API.G_FALSE
         );

       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                               SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;

END Get_Cancel_Qty_Allowed;
--
--bug #8590113 :
--===================================================================================================
   -- Start of comments
   --
   -- API Name          : Get_Delivery_Detail_attributes
   -- Type              : Public
   -- Purpose           : To fetch all the delivery details attributes along with parent_delivery_Detail_id(container)
   -- Pre-reqs          : None
   -- Function          : This API can be used to get all the attributes of delivery details along with container details
   --
   --
   -- PARAMETERS        : p_header_id             header_id of the Sales Order
   --                     p_line_id               line_id of the Sales Order
   --                     x_rec_tab               Return all the delivery details attributes in following format
   --                                             x_rec_tab.detail_rec_type  - dellivery details attributes record
   --                                             x_rec_tab.parent_delivery_detail_id - container delivery_detail_id
   --
   --                     x_return_status         return status
   -- VERSION          :  current version         1.0
   --                     initial version         1.0
   -- End of comments
--===================================================================================================


PROCEDURE  Get_Delivery_Detail_attributes ( p_header_id  IN NUMBER,
                            p_line_id       IN NUMBER,
                            x_rec_tab       OUT NOCOPY WSH_INTEGRATION.detail_lpn_rec_type_tab_type,
                            x_return_status OUT NOCOPY VARCHAR2)IS

  l_debug_on              BOOLEAN;
  l_module_name CONSTANT  VARCHAR2(100) := 'wsh.plsql.'|| G_PKG_NAME || '.'|| ' Get_Delivery_Detail_attributes';
  l_return_status         VARCHAR2(1);
  l_wdd_lpn_tab           detail_lpn_rec_type_tab_type;
  ind                     NUMBER := 0;
  l_actual_departure_date DATE;
  l_ship_method_meaning   VARCHAR2(240);
  l_carrier_name          VARCHAR2(360);
  l_temp_line_id          NUMBER :=0 ;

  --Get the delivery details and associated container delivery details records for the order line id passed
  CURSOR c_wdd_lpn_for_line (l_line_id NUMBER ) IS
  SELECT wdd.*
  FROM wsh_delivery_assignments wda,wsh_delivery_details wdd
  WHERE wdd.delivery_detail_id = wda.delivery_detail_id
  START WITH wda.delivery_detail_id in
   (  SELECT delivery_detail_id
      FROM wsh_delivery_details
      WHERE source_line_id = l_line_id
      AND source_code = 'OE')
  CONNECT BY PRIOR wda.parent_delivery_detail_id = wda.DELIVERY_DETAIL_ID ;

  l_line_ids wsh_util_core.id_tab_type; --for storing line_ids if only header_id is passed in package.

  --Get the  line_id assoicated to the header_id
  CURSOR c_line_id(l_header_id NUMBER ) IS
  SELECT DISTINCT source_line_id
  FROM wsh_delivery_details
  WHERE source_header_id = l_header_id
  AND source_code = 'OE';

  --Get the  parent_delivery_detail_id for delivery detail
  CURSOR c_assignment(l_delivery_detail_id NUMBER ) IS
  SELECT parent_delivery_detail_id
  FROM wsh_delivery_assignments
  WHERE  delivery_detail_id =l_delivery_detail_id ;

 ----Get the actual departure date
 CURSOR c_actual_ship_date(l_line_id NUMBER ) IS
 SELECT wts.actual_departure_date,wcs.ship_method_meaning,hp.party_name
  FROM wsh_delivery_details wdd ,
       wsh_delivery_assignments wda ,
       wsh_new_deliveries wnd ,
       wsh_delivery_legs wdl ,
       wsh_trip_stops wts,
       wsh_trips wt,
       wsh_carrier_services wcs,
       hz_parties hp
  WHERE wdd.source_line_id = l_line_id
  AND wdd.delivery_detail_id = wda.delivery_detail_id
  AND wda.delivery_id = wnd.delivery_id
  AND wda.delivery_id = wdl.delivery_id
  AND wdl.pick_up_stop_id = wts.stop_id
  AND wnd.initial_pickup_location_id = wts.stop_location_id
  AND  wts.trip_id = wt.trip_id
  AND wt.carrier_id = hp.party_id (+)
  AND wt.ship_method_code = wcs.ship_method_code (+)
  AND ROWNUM = 1;

  NO_VALUE_PASSED exception;

BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'header_id ',p_header_id);
        WSH_DEBUG_SV.log(l_module_name,'line_id ',p_line_id);
    END IF;

    --If line_id is passed as i/p
    IF p_line_id IS NOT NULL  THEN
    --{
        l_line_ids(1) :=   p_line_id ;
    --}
    --If only header_id is passed as i/p
    ELSIF p_header_id IS NOT NULL  THEN
    --{
        OPEN c_line_id(p_header_id);
	FETCH c_line_id BULK COLLECT INTO l_line_ids;
        CLOSE c_line_id;
    --}
    ELSE
    --{
        RAISE NO_VALUE_PASSED;
    --}
    END IF;

    FOR i in 1..l_line_ids.COUNT  LOOP
    --{
        --Get the actual departure date
        --bugfix 9883511 - assigned null value to variables
        l_actual_departure_date := NULL;
        l_ship_method_meaning   := NULL ;
        l_carrier_name := NULL;

	OPEN c_actual_ship_date(l_line_ids(i)) ;
        FETCH c_actual_ship_date INTO l_actual_departure_date,l_ship_method_meaning,l_carrier_name;
        CLOSE c_actual_ship_date;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'********** Line_id loop for line_id ',l_line_ids(i));
	    WSH_DEBUG_SV.log(l_module_name,'actual ship date',l_actual_departure_date);
            WSH_DEBUG_SV.log(l_module_name,'Ship Method',l_ship_method_meaning);
            WSH_DEBUG_SV.log(l_module_name,'Carrier Name',l_carrier_name);
        END IF;

	--Get the delivery detail and associated container records
        FOR wdd_lpn_rec IN c_wdd_lpn_for_line(l_line_ids(i)) loop
        --{
            x_rec_tab(ind).detail_rec_type:= wdd_lpn_rec;

	    --Assign the actual departure date, ship method and carrier name
	    x_rec_tab(ind).actual_ship_date := l_actual_departure_date;
            x_rec_tab(ind).Ship_method  := l_ship_method_meaning;
            x_rec_tab(ind).carrier_name := l_carrier_name;

            --Get the parent_delivery_details_id for the delivery detail
            OPEN c_assignment(x_rec_tab(ind).detail_rec_type.delivery_detail_id) ;
            FETCH c_assignment INTO x_rec_tab(ind).parent_delivery_detail_id ;
            CLOSE c_assignment;


            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'wdd_lpn_rec loop count ',ind + 1);
                WSH_DEBUG_SV.log(l_module_name,'delivery_detail_id ',x_rec_tab(ind).detail_rec_type.delivery_detail_id);
                WSH_DEBUG_SV.log(l_module_name,'parent_delivery_detail_id ',x_rec_tab(ind).parent_delivery_detail_id);
            END IF;
            ind := ind+1;
        --}
        END LOOP;
    --}
    END LOOP ;


    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Total records count ',x_rec_tab.count);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;

EXCEPTION
   WHEN NO_VALUE_PASSED THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.printMsg('line_id and header_id both are not passed');

       IF c_line_id%ISOPEN THEN
           close c_line_id;
       END IF;

       IF c_wdd_lpn_for_line%ISOPEN THEN
           close c_wdd_lpn_for_line;
       END IF;

       IF c_assignment%ISOPEN THEN
           close c_assignment;
       END IF;

       IF c_actual_ship_date%ISOPEN THEN
           close c_actual_ship_date;
       END IF;

       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN  Get_Delivery_Detail_attributes :line_id and header_id both are not passed' );
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_VALUE_PASSED');
       END IF;


   WHEN OTHERS THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       wsh_util_core.printMsg('API  Get_Delivery_Detail_attributes failed with an unexpected error');
       WSH_UTIL_CORE.PrintMsg('The unexpected error is '|| sqlerrm);

       IF c_line_id%ISOPEN THEN
           close c_line_id;
       END IF;

       IF c_wdd_lpn_for_line%ISOPEN THEN
           close c_wdd_lpn_for_line;
       END IF;

       IF c_assignment%ISOPEN THEN
           close c_assignment;
       END IF;

       IF c_actual_ship_date%ISOPEN THEN
           close c_actual_ship_date;
       END IF;

       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'UNEXPECTED ERROR IN  Get_Delivery_Detail_attributes' );
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;

END  Get_Delivery_Detail_attributes;
--
--
-- LSP project : new API
--
--===================================================================================================
   -- Start of comments
   --
   -- API Name          : Validate_Oe_Attributes
   -- Type              : Private
   -- Purpose           : To determine whether the validation of Sales order/order line
   --                     attribute is required or not.
   -- Pre-reqs          : None
   -- Function          : This API returns 'N' when the
   --                      a) Deployment mode is Distributed
   --                      b) Deployment Mode is LSP and Order Source is equal to any of the valid client code
   --                     For all other cases this API returns 'Y'
   --
   --
   -- PARAMETERS        : p_order_source_id      Order number of the Sales Order
   --                     x_return_status         'Y' : OM should validate attributes, 'N': OM can ignore the validation.
   -- VERSION          :  current version         1.0
   --                     initial version         1.0
   -- End of comments
--===================================================================================================
FUNCTION  Validate_Oe_Attributes (p_order_source_id IN NUMBER) RETURN VARCHAR2 IS
CURSOR c_check_client IS
  SELECT
    'N'
  FROM
    oe_order_sources oos,
    mtl_client_parameters mcp
  WHERE  oos.order_source_id = p_order_source_id
    AND  mcp.client_code     = oos.name;

l_return_status VARCHAR2(1) := 'Y';
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_Oe_Attributes';
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_order_source_id',p_order_source_id);
  END IF;
  IF WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'D' THEN
  --{
    l_return_status := 'N';
  ELSIF ( WMS_DEPLOY.WMS_DEPLOYMENT_MODE = 'L' AND p_order_source_id is NOT NULL ) THEN
    OPEN  c_check_client;
    FETCH c_check_client INTO l_return_status;
    CLOSE c_check_client;
    l_return_status := nvl(l_return_status,'Y');
  --}
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  RETURN l_return_status;
EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
     wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,l_module_name);
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
                              SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
END Validate_Oe_Attributes;
--
-- LSP project : end
--
--RTV changes
--
--  Procedure:   Update_Delivery_Line
--  Parameters:  list of  Delivery Lines that need to be updated
--  Description: This procedure will update inv_interface_flag of
--               a delivery line to 'Y'
--

PROCEDURE Update_Delivery_Details(
  p_detail_rows    IN  wsh_util_core.id_tab_type,
  x_return_status  OUT NOCOPY   VARCHAR2) IS

 others     EXCEPTION;
 l_debug_on BOOLEAN;
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DELIVERY_DETAILS';
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
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF (p_detail_rows.count = 0) THEN
     raise others;
  END IF;

  FOR i IN 1..p_detail_rows.count LOOP

    IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'delivery_detail_id', p_detail_rows(i));
    END IF;

    update wsh_delivery_details dd
    set    inv_interfaced_flag    = 'Y',
           last_update_date       = sysdate,
           last_updated_by        = fnd_global.user_id,
           last_update_login      = fnd_global.login_id
    where  delivery_detail_id     = p_detail_rows(i)
    and    source_code NOT IN ('OE','OKE', 'WSH');

  END LOOP;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION

    WHEN others THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       wsh_util_core.default_handler('WSH_INTERFACE.UPDATE_DELIVERY_DETAILS',l_module_name);
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
		 	 --
END Update_Delivery_Details;
--RTV changes

END WSH_INTEGRATION;

/
