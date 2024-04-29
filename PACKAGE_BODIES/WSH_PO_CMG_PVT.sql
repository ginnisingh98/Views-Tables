--------------------------------------------------------
--  DDL for Package Body WSH_PO_CMG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PO_CMG_PVT" as
/* $Header: WSHPPCMB.pls 120.0.12000000.2 2007/01/24 18:22:51 bsadri ship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PO_CMG_PVT';
LIMITED_PRECISION NUMBER := 5;

/*========================================================================
-- PROCEDURE : Reapprove_PO
-- HISTORY   : Created the API.
--========================================================================*/
-- Start of comments
-- API name : Reapprove_PO
-- Type     : Public
-- Pre-reqs : None.
-- Function : This is the wrapper API which gets called when PO goes for Re-approval.
--	      1.For every Line_location_id passed by PO, first propagate
--              the attributes other than quantity on the Delivery details,
--              by calling Update_Attributes.
--            2.Next, take care of the quantity increments and decrements,
--              by calling Update_Quantity.
--            3.When ever delivery grouping attributes changes, the line
--              gets unassigned from the delivery.Collect the list of delivery details id's
--              that needs to be unassigned and at the end call the Unassign_Multiple_details
--              API for the same.
--            4.If the inventory_item_id is updated on the delivery_detail or if the qty is
--              updated to any value other than zero, then those delivery_detail_id's are
--              Collected to l_wr_vol_dd_id list .Weight and volume gets recalculated
--              by calling WSH_WV_UTILS.Detail_Weight_Volume which makes use of this
--              l_wt_vol_dd_id list.
--            5.Call WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required API using the
--              l_wt_vol_dd_id list to reprice the delivery_details.
--            This also gets called from Correction by setting action code as
--            RECEIPT'.
--
-- Parameters :
-- IN OUT:
--   p_line_rec IN OUT OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL
--      This record structure contains information about the lines to be updated.
--      The information may include header id,line id ,line location id and other po
--      attributes..
--   p_action_prms    IN  OUT NOCOPY WSH_BULK_TYPES_GRP.action_parameters_rectype
--      The record which specifies the caller, actio to be performed(REAPPROVE)
--IN :
--  p_dd_list       IN dd_list_type
--       This is the record structure which contains the list of delivery details and the
--       associated po shipment line id that needs to be updated.This list gets populated
--       only when called from Cancel_ASN or Revert Matching Transaction.
-- OUT:
--   x_return_status  OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0

PROCEDURE Reapprove_PO(
p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN OUT NOCOPY WSH_BULK_TYPES_GRP.action_parameters_rectype,
p_dd_list    IN dd_list_type,
x_return_status  OUT  NOCOPY VARCHAR2)
IS

l_return_status  VARCHAR2(10);
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_dd_id_unassigned wsh_util_core.id_tab_type;
l_wt_vol_dd_id wsh_util_core.id_tab_type;
l_init_msg_list         VARCHAR2(30) := NULL;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_commit                VARCHAR2(1);
l_validation_level      NUMBER;
l_delivery_id      NUMBER;
l_delivery_name VARCHAR2(150);
l_action_prms wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'REAPPROVE_PO';
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
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;
--
SAVEPOINT Reapprove_PO_PVT;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF p_action_prms.action_code = 'REAPPROVE_PO' OR
   p_action_prms.action_code = 'CANCEL_ASN' THEN

-- If action code is 'CANCEL_ASN', only Update_Attributes API is called.
-- For action code 'REAPPROVE_PO', both Update_Quantity and Update_Attributes
-- are called.

   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Update_Attributes',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;

   Update_Attributes(
     p_line_rec          => p_line_rec,
     p_action_prms       => p_action_prms,
     p_dd_list           => p_dd_list,
     p_dd_id_unassigned  => l_dd_id_unassigned,
     p_wt_vol_dd_id      => l_wt_vol_dd_id,
     x_return_status     => l_return_status);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_util_core.api_post_call(
     p_return_status => l_return_status,
     x_num_warnings  => l_num_warnings,
     x_num_errors    => l_num_errors);

END IF;

IF p_action_prms.action_code = 'REAPPROVE_PO' OR
   p_action_prms.action_code = 'RECEIPT' OR
   p_action_prms.action_code = 'ASN' THEN

-- If action code is 'RECEIPT' or 'ASN', only Update_quantity API is called.
-- For action code 'REAPPROVE_PO', both Update_Quantity and Update_Attributes
-- are called.


  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Update_Quantity',WSH_DEBUG_SV.C_PROC_LEVEL);
    WSH_DEBUG_SV.log(l_module_name,'l_wt_vol_dd_id.COUNT is' ,l_wt_vol_dd_id.COUNT);
  END IF;

     Update_quantity(
	 p_line_rec               => p_line_rec,
	 p_action_prms            => p_action_prms,
         p_dd_id_unassigned       => l_dd_id_unassigned,
	 p_wt_vol_dd_id		  => l_wt_vol_dd_id,
	 x_return_status          => l_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_wt_vol_dd_id.COUNT is' ,l_wt_vol_dd_id.COUNT);
  END IF;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_util_core.api_post_call(
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors);
END IF;

--
-- Debug Statements
--
IF l_dd_id_unassigned.count > 0 then
--Call GRP API to unassign the dd from delivery
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit  WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  l_action_prms.caller := wsh_util_core.C_IB_PO_PREFIX;

  WSH_DELIVERY_DETAILS_ACTIONS.unassign_multiple_details(
                p_rec_of_detail_ids  =>  l_dd_id_unassigned,
                p_from_delivery      => 'Y',
                p_from_container     => 'N',
                x_return_status      =>  l_return_status,
                p_validate_flag      =>  'N',
                p_action_prms        =>  l_action_prms);

  wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

l_dd_id_unassigned.delete;

END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_wt_vol_dd_id.COUNT -3 is' ,l_wt_vol_dd_id.COUNT);
  END IF;
IF l_wt_vol_dd_id.COUNT > 0 THEN
  -- recalculate the wt/volume and reprice the delviery detail.

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Detail_Weight_Volume',WSH_DEBUG_SV.C_PROC_LEVEL);
    WSH_DEBUG_SV.log(l_module_name,'l_wt_vol_dd_id.COUNT is' ,l_wt_vol_dd_id.COUNT);
  END IF;

  WSH_WV_UTILS.Detail_Weight_Volume(
    p_detail_rows        => l_wt_vol_dd_id,
    p_override_flag      => 'Y',
    p_calc_wv_if_frozen  => 'N',
    x_return_status      => l_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
       p_entity_type   => 'DELIVERY_DETAIL',
       p_entity_ids    => l_wt_vol_dd_id,
       x_return_status => l_return_status);

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);
--END IF;

l_wt_vol_dd_id.delete;
--l_dd_id_unassigned.delete;

END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Reapprove_PO_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN OTHERS THEN
    ROLLBACK TO Reapprove_PO_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_CMG_PVT.Reapprove_PO',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Reapprove_PO;


/*========================================================================
-- PROCEDURE : Update_Attributes
-- HISTORY   : Created the API.
--========================================================================*/
-- Start of comments
-- API name : Update_Attributes
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API update all the non-quantity attributes in
--            wsh_delivery_details when PO goes for reapproval.
--            This API internally calls Update_dd_attribues API which does the
--            actual update on wsh_delivery_details.
--            In case of PO Reapproval scenario, the p_dd_list  will
--            be just defined, but will not have any data in it.
--            In case of ASN Cancellation or Reverting the Matching
--            Transactions, the p_dd_list will have the set of
--            delivery_details that are getting cancelled/reverted.
-- Parameters :
-- IN OUT:
--   p_line_rec       IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL
--      This record structure contains information about the lines to be updated.
--      The information may include header id,line id ,line location id and other po
--      attributes..
--   p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type
--      This contains the list of delviery details that needs to be unassigned from
--      the respective delivery.
--   p_wt_vol_dd_id IN OUT NOCOPY wsh_util_core.id_tab_type,
--      This contains the list of delviery details for which weight and volume needs to
--      be re-calculated.
--   p_action_prms    IN  OUT NOCOPY WSH_BULK_TYPES_GRP.action_parameters_rectype
--      The record which specifies the caller, actio to be performed(REAPPROVE,CANCEL_ASN,RECEIPT,ASN)
--IN :
--  p_dd_list       IN dd_list_type
--       This is the record structure which contains the list of delivery details and the
--       associated po shipment line id that needs to be updated.This list gets populated
--       only when called from Cancel_ASN or Revert Matching Transaction.
-- OUT:
--   x_return_status  OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

Procedure Update_Attributes(
p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN WSH_BULK_TYPES_GRP.action_parameters_rectype,
p_dd_list    IN dd_list_type,
p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type,
p_wt_vol_dd_id IN OUT NOCOPY wsh_util_core.id_tab_type,
x_return_status       OUT NOCOPY VARCHAR2) IS

l_api_version    CONSTANT NUMBER          :=    1.0;
l_msg_count    NUMBER := 0;
l_msg_data      VARCHAR2(1000) := NULL;
l_po_release_rec_type PO_FTE_INTEGRATION_GRP.po_release_rec_type;
l_po_shipment_line_id NUMBER;
l_return_status  VARCHAR2(1);
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_rcv_shipment_line_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ATTRIBUTES';
--
BEGIN

--If this routine is being called from the PO Reapproval Case
--the entire p_line_rec is always passed for which all
--the open delivery details are to be updated.

--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;
--
SAVEPOINT Update_Attributes_PVT;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF p_dd_list.delivery_detail_id.count = 0 THEN
-- If this routine is being called from the PO Reapproval Case
-- the p_dd_list is null.Only p_line_rec will be populated.
  IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Update_dd_attributes',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
--{
  FOR i in p_line_rec.po_shipment_line_id.FIRST..p_line_rec.po_shipment_line_id.LAST
    LOOP
-- Update_dd_attributes is called directly to update the non quantity attributes.
      Update_dd_attributes(
	 p_line_rec       => p_line_rec,
	 p_action_prms    => p_action_prms,
	 p_dd_id          => null,
         p_dd_id_unassigned => p_dd_id_unassigned,
         p_wt_vol_dd_id     => p_wt_vol_dd_id,
	 p_line_rec_index => i,
	 x_return_status          => l_return_status);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors);

    END LOOP;
ELSE

--If this routine is being called from the Cancel_asn or the
--revert Matching Transactions, entire list of delivery details
--will be passed which are being cancelled or reverted.
--Need to derive the p_line_rec information by calling get_po_rcv_attributes API.
  l_po_shipment_line_id := 0;

  For  i in p_dd_list.delivery_detail_id.FIRST..p_dd_list.delivery_detail_id.LAST
    LOOP
      IF p_dd_list.po_shipment_line_id(i) <> l_po_shipment_line_id THEN
      --{
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.GET_PO_RCV_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
	-- Deriving the p_line_rec information.
        WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes(
          p_po_line_location_id  => p_dd_list.po_shipment_line_id(i),
          p_rcv_shipment_line_id => l_rcv_shipment_line_id,
          x_line_rec             => p_line_rec,
          x_return_status        => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status => l_return_status,
          x_num_warnings  => l_num_warnings,
          x_num_errors    => l_num_errors);

        l_po_shipment_line_id := p_dd_list.po_shipment_line_id(i);

       --}
       END IF;

      IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Update_dd_attributes',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      -- Once p_line_rec is derived, call update_dd_attributes to update wsh_delivery_details.

      Update_dd_attributes(
        p_line_rec       => p_line_rec,
        p_action_prms    => p_action_prms,
        p_dd_id          => p_dd_list.delivery_detail_id(i),
        p_dd_id_unassigned => p_dd_id_unassigned,
        p_wt_vol_dd_id     => p_wt_vol_dd_id,
        p_line_rec_index => p_line_rec.header_id.COUNT,
        x_return_status          => l_return_status);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors);

  END LOOP;
--}
END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Attributes_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN OTHERS THEN
    ROLLBACK TO Update_Attributes_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_CMG_PVT.Update_Attributes',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Attributes;

/*========================================================================
-- PROCEDURE : Update_dd_Attributes
-- HISTORY   : Created the API.
========================================================================*/
-- Start of comments
-- API name : Update_dd_Attributes
-- Type     : Public
-- Pre-reqs : None.
-- Function : This is the main API which actually synch up the
--            delivery detail attributes with the Purchase Order attribtues
--            in case of PO reapproval/Cancel ASN.
--            1. Checks if any of the delviery grouping attribute is changed
--               on the PO or not.If the delivery grouping attribtue is changed, then
--                  - Collect the delivery_detail_id into p_dd_id_unassigned list
--                    which will be later used to unassign the delivery details from
--                    the delivery.
--            2. Check if the Shipping control is changed on the PO or not.
--                  - If the Shipping control on the PO is changed from 'SUPPLIER' to
--                    'BUYER', then all the open delivery details are updated with the
--                     new value.
--                  - If the shipping Control is changed from 'BUYER' to 'SUPPLIER', then
--                    then this change is updated in Shipping only if routing response
--                    is not send.
--                    If the associated delivery detail is assigned to delviery, then
--                    it gets unassigned from the delivery. Also an exception gets logged
--                    against the delivery.
--             3. Check for the need by date/promise date change
--                If Trip is associated with the delivery detail then
--                   - If the earliest delivery date is greater that planned arrival date
--                     of the trip stop or latest delivery date is less that the
--                     planned arrival date of the tirp stop then an exception gets logged
--                     against the trip stop.
--                If the delivery detail has not trip, but delivery then
--                   - If the earliest delivery date is greater that ultimate drop off date
--                     of the delivery or latest delivery date is less that the
--                     ultimate drop off date of the delivery then an exception gets logged
--                     against the delivery.
--                     The delivery id is collected to l_tp_del_id array which will be later
--                     used to re-calculate the TP dates.
--              4. Check for Freight  (only if delivery is not getting unassigned and the
--                 line is a standard PO line and not a blanket release)
--                   - If all the details in a delivery has the same freight, then the freight on
--                     the delivery will be updated to that value.If the details have different
--                     freight terms, then the delviery freight is updated to NULL.
--
--{
--
-- Parameters :
-- IN OUT:
--   p_line_rec       IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL
--      This record structure contains information about the lines to be updated.
--      The information may include header id,line id ,line location id and other po
--      attributes..
--   p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type
--       This contains the list of delviery details that needs to be unassigned from
--       the respective delivery.
--   p_wt_vol_dd_id IN OUT NOCOPY wsh_util_core.id_tab_type,
--       This contains the list of delviery details for which weight and volume needs to
--        be re-calculated.
--   p_action_prms    IN  OUT NOCOPY
--                               WSH_BULK_TYPES_GRP.action_parameters_rectype
--      The record which specifies the caller, actio to be performed(REAPPROVE,CANCEL_ASN,RECEIPT,ASN)
--IN :
--  p_dd_id       IN NUMBER
--       This parameter will have value only if the p_dd_list in the update_attributes is populated
--       (when called from Cancel_ASN or Revert Matching Transaction).
--       When p_dd_id is passed, only that particular delivery_detail_id is updated.If the p_dd_id
--       is null, then all the open delivery details corresponding to the input po_line_location_id
--       will be updated.
-- OUT:
--   x_return_status  OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

Procedure Update_dd_attributes(
p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN WSH_BULK_TYPES_GRP.action_parameters_rectype,
p_dd_id  IN NUMBER,
p_line_rec_index IN NUMBER,
p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type,
p_wt_vol_dd_id     IN OUT NOCOPY wsh_util_core.id_tab_type,
x_return_status OUT NOCOPY VARCHAR2) IS

-- Cursor to fetch the delivery grouping attributes and other critical attributes
-- like shipping control, freight term,fob,ultimate_drop_off_date of delivery.

Cursor C_dd_attr(p_line_location_id NUMBER, p_delivery_detail_id NUMBER,
                 p_header_id NUMBER,p_line_id NUMBER)
IS
SELECT
WDD.delivery_detail_id,
WDD.ship_to_location_id,
WDD.organization_id,
WDD.ship_from_location_id,
WDD.customer_id,
WDD.date_requested,
WDD.date_scheduled,
WDD.fob_code dd_fob,
WDD.freight_terms_code dd_fgt,
WND.routing_response_id,
WDD.shipping_control,
WND.delivery_id,
WND.freight_terms_code del_fgt,
WND.ultimate_dropoff_date del_date,
WND.ultimate_dropoff_location_id del_location,
/*J-IB-ANJ*/
WDD.earliest_dropoff_date edd,
WDD.latest_dropoff_date ldd,
WDD.last_update_Date
FROM
WSH_DELIVERY_DETAILS WDD,
wsh_delivery_assignments_v WDA,
WSH_NEW_DELIVERIES WND
WHERE
WDD.Delivery_Detail_id = WDA.Delivery_Detail_id AND
WDA.Delivery_id = WND.Delivery_id(+) AND
WDD.released_status = 'X' AND
WDD.PO_SHIPMENT_LINE_ID = p_line_location_id AND
WDD.source_code = 'PO' AND
WDD.source_header_id = nvl(p_header_id,WDD.source_header_id) AND
WDD.source_line_id   = p_line_id AND
WDD.delivery_detail_id = NVL(p_delivery_detail_id, WDD.DELIVERY_DETAIL_ID);

-- Cursor to fetch all the attributes corresponding to the line location id, line id and header id
-- from wsh_delivery_details which is later used to check if any on the non-quantity attributes
-- have changed before doing the update on wdd.

Cursor c_dd_info(p_line_location_id NUMBER, p_delivery_detail_id NUMBER,
                 p_header_id NUMBER,p_line_id NUMBER)
IS
-- Changed for Bug# 3330869
-- select * from wsh_delivery_details
SELECT
  inventory_item_id,
  delivery_detail_id,
  source_header_id,
  source_blanket_reference_id,
  source_line_id,
  ship_from_site_id,
  customer_item_id,
  source_line_type_code,
  sold_to_contact_id,
  vendor_id,
  item_description,
  hazard_class_id,
  country_of_origin,
  ship_to_location_id,
  ship_to_contact_id,
  deliver_to_location_id,
  deliver_to_contact_id,
  intmed_ship_to_location_id,
  intmed_ship_to_contact_id,
  hold_code,
  ship_tolerance_above,
  ship_tolerance_below,
  revision,
  date_requested,
  date_scheduled,
  ship_method_code,
  carrier_id,
  freight_terms_code,
  fob_code,
  supplier_item_number,
  customer_prod_seq,
  customer_dock_code,
  cust_model_serial_number,
  customer_job,
  customer_production_line,
  organization_id,
  ship_model_complete_flag,
  top_model_line_id,
  source_header_number,
  source_header_type_name,
  cust_po_number,
  ato_line_id,
  shipping_instructions,
  packing_instructions,
  org_id,
  source_line_number,
  unit_price,
  currency_code,
  preferred_grade,
  po_shipment_line_number,
  source_blanket_reference_num,
  po_revision_number,
  release_revision_number,
  earliest_dropoff_date,
  latest_dropoff_date
FROM wsh_delivery_details
WHERE source_code = 'PO'
AND po_shipment_line_id = p_line_location_id AND
source_header_id = p_header_id AND
source_line_id = p_line_id AND
delivery_detail_id = NVL(p_delivery_detail_id, DELIVERY_DETAIL_ID);

-- Cursor to get the planned arrival date of the trip stop

Cursor c_check_ts_date(p_dd_id NUMBER)
 IS
SELECT
WTS.STOP_ID,
WTS.planned_arrival_date Stop_date ,
WTS.STOP_LOCATION_ID
FROM wsh_delivery_assignments_v WDA,
WSH_NEW_DELIVERIES WND,
WSH_DELIVERY_LEGS WDG,
WSH_TRIP_STOPS WTS
WHERE wda.delivery_detail_id = p_dd_id AND
WDA.DELIVERY_ID = WND.DELIVERY_ID AND
WDG.DELIVERY_ID = WND.DELIVERY_ID AND
WTS.STOP_ID = WDG.DROP_OFF_STOP_ID AND
WTS.STOP_LOCATION_ID = WND.ULTIMATE_DROPOFF_LOCATION_ID;

l_stop_loaction_id  NUMBER;
l_del_unassigned VARCHAR2(1);
l_return_status  VARCHAR2(1);
l_validate_flag  VARCHAR2(1);
l_stop_id  NUMBER;
l_stop_date  DATE;
l_Earliest_delivery_Date DATE;
l_latest_delivery_Date DATE;

l_init_msg_list         VARCHAR2(30) := NULL;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_commit                VARCHAR2(1);
l_validation_level      NUMBER;
l_delivery_id      NUMBER;
l_tp_del_id     wsh_util_core.id_tab_type;

l_delivery_name VARCHAR2(150);
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_fgt_terms_code   VARCHAR2(30);

l_del_fgt_terms_tbl           wsh_util_core.id_tab_type;
l_del_fgt_terms_tbl_cache     WSH_UTIL_CORE.key_value_tab_type;
l_del_fgt_terms_tbl_ext_cache WSH_UTIL_CORE.key_value_tab_type;
l_ind NUMBER;
l_req_res_id NUMBER;
l_msg   varchar2(2000);
l_check_routing_res varchar2(1);
l_rr_status boolean;
l_old_value varchar2(100);
l_new_value varchar2(100);
--J-IB-ANJ
/*l_del_edd date; -- Earliest Drop Off Date Bug#: 3145863
l_del_ldd date; -- Latest Drop Off Date Bug#: 3145863*/

l_shippingControlTurnedOn BOOLEAN := FALSE;
l_action_prms             WSH_BULK_TYPES_GRP.action_parameters_rectype;

e_wdd_locked EXCEPTION ;
PRAGMA  EXCEPTION_INIT(e_wdd_locked,-54);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DD_ATTRIBUTES';
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
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_DD_ID',P_DD_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_LINE_REC_INDEX',P_LINE_REC_INDEX);
END IF;
--
SAVEPOINT Update_dd_Attributes_PVT;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF (p_action_prms.action_code ='REAPPROVE_PO'
    OR p_action_prms.action_code ='CANCEL_ASN') THEN
--{

  FOR v_dd_attr IN c_dd_attr(p_line_rec.po_shipment_line_id(p_line_rec_index),
        p_dd_id, p_line_rec.header_id(p_line_rec_index),
        p_line_rec.line_id(p_line_rec_index))
  LOOP

/*Variable for avoiding unassignment from delivery for shipping control
check further down. Will be set to 'Y' when first unassignment happens,
and later can be just checked against.*/
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'v_dd_attr wdd id is ',v_dd_attr.delivery_detail_id);
        WSH_DEBUG_SV.log(l_module_name,'v_dd_attr last_update_date is ',v_dd_attr.last_update_date);
      END IF;


    l_del_unassigned := 'N';
    l_check_routing_res:=NULL;

    --Check for Delivery Grouping Attributes - Starts
    IF ((p_line_rec.ship_to_location_id(p_line_rec_index) IS NOT NULL) AND
         p_line_rec.ship_to_location_id(p_line_rec_index) <> v_dd_attr.ship_to_location_id) OR
        ((p_line_rec.organization_id(p_line_rec_index) IS NOT NULL) AND
          p_line_rec.organization_id(p_line_rec_index) <> v_dd_attr.organization_id)
            OR
        ((p_line_rec.sold_to_org_id(p_line_rec_index) IS NOT NULL) AND
          p_line_rec.sold_to_org_id(p_line_rec_index) <> v_dd_attr.customer_id)
    THEN
    --{
      IF v_dd_attr.delivery_id IS NOT NULL THEN

      -- When ever ship to location is changed on the PO, if the delivery details is
      -- assigned to delviery, it gets unassigned from the delivery.This is done by
      -- collecting the list of delviery details that needs to be unassigned to
      -- p_dd_id_unassigned array.
      -- Also an exception gets logged against the delivery.

      --{
        p_dd_id_unassigned(p_dd_id_unassigned.COUNT +1)
                  := v_dd_attr.delivery_detail_id;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	-- Bug 3395410 : Setting the message that needs to be displayed while logging exception.

	FND_MESSAGE.SET_NAME('WSH','WSH_IB_DELIVERY_CHANGE');
        FND_MESSAGE.SET_TOKEN('DELIVERY',v_dd_attr.delivery_id);
        l_msg := FND_MESSAGE.GET;

        Log_Exception(
          p_entity_id      => V_dd_attr.delivery_id,
          p_logging_entity_name    => 'DELIVERY',
          p_exception_name => 'WSH_IB_DELIVERY_CHANGE',
          p_location_id    =>  v_dd_attr.del_location,
	  p_message        => l_msg,
          x_return_status  =>  l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status => l_return_status,
          x_num_warnings  => l_num_warnings,
          x_num_errors    => l_num_errors);


         -- HACMS {
         IF (p_line_rec.ship_to_location_id(p_line_rec_index) IS NOT NULL AND
                p_line_rec.ship_to_location_id(p_line_rec_index) <> v_dd_attr.ship_to_location_id) THEN

            IF (l_check_routing_res IS NULL) THEN
              l_rr_status:=WSH_INBOUND_UTIL_PKG.Is_Routing_Response_Send(V_dd_attr.delivery_detail_id,l_req_res_id);
              l_check_routing_res:='Y';
            END IF;

            IF (l_rr_status) THEN
	    -- If routing response in send and the ship to location is undergoing a change, then
	    -- an exception is logged against the delivery detail.

                FND_MESSAGE.SET_NAME('WSH','WSH_IB_ST_LOC_CHANGE');
                FND_MESSAGE.SET_TOKEN('DETAIL', V_dd_attr.delivery_detail_id);
                FND_MESSAGE.SET_TOKEN('OLD_VALUE', v_dd_attr.ship_to_location_id);
                FND_MESSAGE.SET_TOKEN('NEW_VALUE', p_line_rec.ship_to_location_id(p_line_rec_index));
                l_msg := FND_MESSAGE.GET;

		IF l_debug_on THEN
	            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

                Log_Exception(
                   p_entity_id      => V_dd_attr.delivery_detail_id,
                   p_logging_entity_name    => 'DETAIL',
                   p_exception_name => 'WSH_IB_DETAIL_CHANGE',
                   p_location_id    =>  v_dd_attr.ship_to_location_id,
                   p_message        =>  l_msg,
                   x_return_status  =>  l_return_status);

               IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'After Log_Exception l_return_status',l_return_status);
               END IF;

               wsh_util_core.api_post_call(
                  p_return_status => l_return_status,
                  x_num_warnings  => l_num_warnings,
                  x_num_errors    => l_num_errors);

            END IF;
         END IF;
         -- HACMS }

        l_del_unassigned := 'Y';

      END IF;
      --}
    END IF;
    --}

    --Check for Delivery Grouping Attributes - Ends

    --Check for Shipping Control - Starts

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_line_rec shipping_control is ',p_line_rec.shipping_control(p_line_rec_index));
        WSH_DEBUG_SV.log(l_module_name,'v_dd_attr shipping_control is ',v_dd_attr.shipping_control);
        WSH_DEBUG_SV.log(l_module_name,'v_dd_attr routing response id is ',v_dd_attr.routing_response_id);
      END IF;


    IF  p_line_rec.shipping_control(p_line_rec_index) IS NOT NULL
    AND v_dd_attr.shipping_control                    IS NULL
    THEN
    --{
        l_shippingControlTurnedOn := TRUE;
    --}
    END IF;


    IF ((p_line_rec.shipping_control(p_line_rec_index) IS NOT NULL) AND
         p_line_rec.shipping_control(p_line_rec_index) <> v_dd_attr.shipping_control) THEN
    --{
      IF v_dd_attr.shipping_control  ='BUYER' AND p_line_rec.shipping_control(p_line_rec_index) = 'SUPPLIER' THEN

      -- If shipping control is changed from 'Buyer' to 'Supplier' on the PO, then this change is
      -- updated in Shipping only if routing response is not send.
      -- If the associated delivery detail is assigned to delviery, then it gets unassigned from the
      --delivery. Also an exception gets logged against the delivery.

      --{
        IF v_dd_attr.routing_response_id IS NULL THEN
          IF v_dd_attr.delivery_id is NOT NULL and l_del_unassigned = 'N' THEN
            p_dd_id_unassigned(p_dd_id_unassigned.COUNT +1)
                 := v_dd_attr.delivery_detail_id;
            l_del_unassigned := 'Y';

	    IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;

	    -- Bug 3395410 : Setting the message that needs to be displayed while logging exception.

	    FND_MESSAGE.SET_NAME('WSH','WSH_IB_DELIVERY_CHANGE');
            FND_MESSAGE.SET_TOKEN('DELIVERY',v_dd_attr.delivery_id);
            l_msg := FND_MESSAGE.GET;

            Log_Exception(
	      p_entity_id      => V_dd_attr.delivery_id,
              p_logging_entity_name    => 'DELIVERY',
              p_exception_name => 'WSH_IB_DELIVERY_CHANGE',
              p_location_id    =>  v_dd_attr.del_location,
	      p_message        => l_msg,
              x_return_status  =>  l_return_status);
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors);

          END IF;
          update wsh_delivery_details
	  set shipping_control = p_line_rec.shipping_control(p_line_rec_index),
	  last_update_date = SYSDATE,
          last_updated_by =  FND_GLOBAL.USER_ID,
          last_update_login =  FND_GLOBAL.LOGIN_ID
          WHERE po_shipment_line_id = p_line_rec.po_shipment_line_id(p_line_rec_index)
          AND  source_header_id = p_line_rec.header_id(p_line_rec_index) AND
          source_line_id = p_line_rec.line_id(p_line_rec_index) AND
          source_code = 'PO' AND
         ((p_line_rec.source_blanket_reference_id(p_line_rec_index) IS NULL AND
           source_blanket_reference_id IS NULL) OR
          (p_line_rec.source_blanket_reference_id(p_line_rec_index) IS NOT NULL
          AND source_blanket_reference_id = p_line_rec.source_blanket_reference_id(p_line_rec_index))) AND
	  delivery_detail_id = v_dd_attr.delivery_detail_id AND
          released_status = 'X' AND
          container_flag = 'N' AND
										last_update_date =  v_dd_attr.last_update_date;

									   IF SQL%ROWCOUNT <> 1 THEN
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT',SQL%ROWCOUNT);
              END IF;
              FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_CHANGED');
              wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
              RAISE FND_API.G_EXC_ERROR;
           END IF;

        END IF;
      ELSE
          -- If shipping control is changed from 'Supplier' to 'Buyer' on the PO, then
	  -- it is directly updated to wsh_delivery_details without checking for any contions
	  -- other than line status which should be 'X'(OPEN).

	  update wsh_delivery_details
	  set shipping_control = p_line_rec.shipping_control(p_line_rec_index),
	  last_update_date = SYSDATE,
          last_updated_by =  FND_GLOBAL.USER_ID,
          last_update_login =  FND_GLOBAL.LOGIN_ID
          WHERE po_shipment_line_id = p_line_rec.po_shipment_line_id(p_line_rec_index)
          AND  source_header_id = p_line_rec.header_id(p_line_rec_index) AND
          source_line_id = p_line_rec.line_id(p_line_rec_index) AND
          source_code = 'PO' AND
         ((p_line_rec.source_blanket_reference_id(p_line_rec_index) IS NULL AND
           source_blanket_reference_id IS NULL) OR
          (p_line_rec.source_blanket_reference_id(p_line_rec_index) IS NOT NULL
          AND source_blanket_reference_id = p_line_rec.source_blanket_reference_id(p_line_rec_index))) AND
	  delivery_detail_id = v_dd_attr.delivery_detail_id AND
          released_status = 'X' AND
          container_flag = 'N' AND
										last_update_date =  v_dd_attr.last_update_date;

									   IF SQL%ROWCOUNT <> 1 THEN
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT',SQL%ROWCOUNT);
              END IF;
              FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_CHANGED');
              wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
              RAISE FND_API.G_EXC_ERROR;
           END IF;

      --}
      END IF;
    --}
    END IF;

    --Check for Shipping Control - Ends

    --Check for Need By Date  Promise Date - Starts
    -- J-IB-ANJ
    /*IF (((p_line_rec.request_date(p_line_rec_index) IS NOT NULL) AND
             p_line_rec.request_date(p_line_rec_index) <> v_dd_attr.date_requested)) OR
       (((p_line_rec.schedule_ship_date(p_line_rec_index) IS NOT NULL) AND
          p_line_rec.schedule_ship_date(p_line_rec_index) <> v_dd_attr.date_scheduled))
    THEN
    --{*/
      l_Earliest_delivery_Date := (NVL(p_line_rec.schedule_ship_date(p_line_rec_index),
      p_line_rec.request_date(p_line_rec_index))-
          NVL(p_line_rec.Days_early_receipt_allowed(p_line_rec_index),0));

      l_latest_delivery_date   := (NVL(p_line_rec.schedule_ship_date(p_line_rec_index),
      p_line_rec.request_date(p_line_rec_index)) +
      NVL(p_line_rec.Days_late_receipt_allowed(p_line_rec_index),0));

      --J-IB-ANJ
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Early Receipt allowed',p_line_rec.Days_early_receipt_allowed(p_line_rec_index));
        WSH_DEBUG_SV.log(l_module_name,'Late Receipt Allowed',p_line_rec.Days_late_receipt_allowed(p_line_rec_index));
        WSH_DEBUG_SV.log(l_module_name,'l_Earliest_delivery_Date',l_Earliest_delivery_Date);
        WSH_DEBUG_SV.log(l_module_name,'l_latest_delivery_date',l_latest_delivery_date);
      END IF;
      -- J-IB-ANJ

      IF v_dd_attr.edd <> l_Earliest_delivery_Date OR
         v_dd_attr.ldd <> l_latest_delivery_date THEN
      --{
        OPEN c_check_ts_date(v_dd_attr.delivery_detail_id);
        FETCH c_check_ts_date INTO l_stop_id, l_stop_date,l_stop_loaction_id;

        IF c_check_ts_date%FOUND THEN
        --{

          IF l_Earliest_delivery_Date  > l_stop_date
          OR l_latest_delivery_date < l_stop_date THEN
	  -- if the earliest delivery date is greater that planned arrival date of the trip stop
	  -- or latest delivery date is less that the planned arrival date of the tirp stop then
	  -- an exception gets logged against the trip stop.
          --{
    	    IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
	    END IF;

	    -- Bug 3395410 : Setting the message that needs to be displayed while logging exception.

 	    FND_MESSAGE.SET_NAME('WSH','WSH_IB_TS_DATE_EXCP');
            FND_MESSAGE.SET_TOKEN('STOP',l_stop_id);
            l_msg := FND_MESSAGE.GET;

            Log_Exception(
             p_entity_id      => l_stop_id,
             p_logging_entity_name    => 'STOP',
             p_exception_name => 'WSH_IB_TS_DATE_EXCP',
             p_location_id    =>  l_stop_loaction_id,
	     p_message        =>  l_msg,
             x_return_status  => l_return_status);

             --
             -- Debug Statements
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors);

           END IF;
           --}
         ELSE
           IF l_Earliest_delivery_Date  > v_dd_attr.del_date
           OR l_latest_delivery_date < v_dd_attr.del_date THEN
           -- if the earliest delivery date is greater that ultimate drop off date of the delivery
	   -- or latest delivery date is less that the ultimate drop off date of the delivery then
	   -- an exception gets logged against the delivery.
	   -- The delivery id is collected to l_tp_del_id array which will be later used to re-calculate
	   -- the TP dates.
           --{
	     IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
   	     END IF;

	     -- Bug 3395410 : Setting the message that needs to be displayed while logging exception.

	     FND_MESSAGE.SET_NAME('WSH','WSH_IB_DEL_DATE_EXCP');
             FND_MESSAGE.SET_TOKEN('DELIVERY',v_dd_attr.delivery_id);
             l_msg := FND_MESSAGE.GET;

             Log_Exception(
              p_entity_id      => V_dd_attr.delivery_id,
              p_logging_entity_name    => 'DELIVERY',
              p_exception_name => 'WSH_IB_DEL_DATE_EXCP',
              p_location_id    =>  V_dd_attr.del_location,
	      p_message        => l_msg,
              x_return_status  =>  l_return_status);

             --
             -- Debug Statements
             --
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors);

           END IF;
           --}
           CLOSE c_check_ts_date;


           -- HACMS {
           IF (p_line_rec.request_date(p_line_rec_index) IS NOT NULL AND
                  p_line_rec.request_date(p_line_rec_index) <> v_dd_attr.date_requested) THEN

            IF (l_check_routing_res IS NULL) THEN
              l_rr_status:=WSH_INBOUND_UTIL_PKG.Is_Routing_Response_Send(V_dd_attr.delivery_detail_id,l_req_res_id);
              l_check_routing_res:='Y';
            END IF;

            IF (l_rr_status) THEN
	       -- If request date is changed on the PO and routing response is already send,
	       -- then exception gets logged agains delivery and delivery detail.

               l_old_value :=  to_char(v_dd_attr.date_requested);
               l_new_value :=  to_char(p_line_rec.request_date(p_line_rec_index));

                FND_MESSAGE.SET_NAME('WSH','WSH_IB_NEED_DT_CHANGE');
                FND_MESSAGE.SET_TOKEN('DETAIL', V_dd_attr.delivery_detail_id);
                FND_MESSAGE.SET_TOKEN('OLD_VALUE', to_char(v_dd_attr.date_requested));
                FND_MESSAGE.SET_TOKEN('NEW_VALUE', to_char(p_line_rec.request_date(p_line_rec_index)));
                l_msg := FND_MESSAGE.GET;

               IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
 	       END IF;

               Log_Exception(
                 p_entity_id      => V_dd_attr.delivery_detail_id,
                 p_logging_entity_name    => 'DETAIL',
                 p_exception_name => 'WSH_IB_DETAIL_CHANGE',
                 p_location_id    =>  v_dd_attr.ship_to_location_id,
                 p_message        =>  l_msg,
                 x_return_status  =>  l_return_status);

               IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log_Exception l_return_status',l_return_status);
               END IF;

               wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors);

                 FND_MESSAGE.SET_NAME('WSH','WSH_IB_DEL_ATT_CHANGE');
                 FND_MESSAGE.SET_TOKEN('DELIVERY',  V_dd_attr.delivery_id);
                 l_msg := FND_MESSAGE.GET;

               Log_Exception(
                 p_entity_id      => V_dd_attr.delivery_id,
                 p_logging_entity_name    => 'DELIVERY',
                 p_exception_name => 'WSH_IB_DEL_ATT_CHANGE',
                 p_location_id    =>  v_dd_attr.del_location,
                 p_message        =>  l_msg,
                 x_return_status  =>  l_return_status);

               IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log_Exception l_return_status',l_return_status);
               END IF;

               wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors);


             END IF;
          END IF;
          -- HACMS }

         l_tp_del_id(l_tp_del_id.COUNT +1) := v_dd_attr.delivery_id;
       END IF;
       --}
     END IF;
     --}

     --Check for Need By Date  promised Date - Ends

     --Check for Freight/FOB - Starts (only if delivery is not getting
     --unassigned and the line is a standard PO line and not a blanket release)
     -- If all the details in a delivery has the same freight, then the freight on
     -- the delivery will be updated to that value.If the details have different
     -- freight terms, then the delviery freight is updated to NULL.

     IF l_del_unassigned = 'N' and v_dd_attr.delivery_id is NOT NULL and
        (p_line_rec.source_blanket_reference_id(p_line_rec_index) IS NULL)
        THEN
     --{
       IF nvl(v_dd_attr.del_fgt,'!!!') <> nvl(p_line_rec.freight_terms_code(p_line_rec_index),'!!!') THEN
         wsh_util_core.get_cached_value(
       p_cache_tbl       => l_del_fgt_terms_tbl_cache,
       p_cache_ext_tbl   => l_del_fgt_terms_tbl_ext_cache,
       p_value           => v_dd_attr.delivery_id,
       p_key             => v_dd_attr.delivery_id,
       p_action          => 'PUT',
       x_return_status   => l_return_status);

               wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors);
       END IF;
     ELSIF p_line_rec.source_blanket_reference_id(p_line_rec_index) IS NOT NULL THEN
       p_line_rec.freight_terms_code(p_line_rec_index) := v_dd_attr.del_fgt;
       p_line_rec.fob_point_code(p_line_rec_index) := v_dd_attr.dd_fob;
     --}
     END IF;
     --Check for Freight Terms - Ends

   END LOOP;--For c_dd_attr

FOR l_dd_info in  c_dd_info(p_line_rec.po_shipment_line_id(p_line_rec_index),
                p_dd_id, p_line_rec.header_id(p_line_rec_index),
                p_line_rec.line_id(p_line_rec_index)) LOOP
--J-IB-ANJ
-- Calculating the Earliest and Latest Dropoff dates 3145863
/*l_del_edd := (NVL(p_line_rec.schedule_ship_date(p_line_rec_index),p_line_rec.request_date(p_line_rec_index)) -
  NVL(p_line_rec.Days_early_receipt_allowed(p_line_rec_index),0));
l_del_ldd :=  (NVL(p_line_rec.schedule_ship_date(p_line_rec_index),p_line_rec.request_date(p_line_rec_index)) +
  NVL(p_line_rec.Days_late_receipt_allowed(p_line_rec_index),0));

IF l_debug_on THEN
 WSH_DEBUG_SV.log(l_module_name,'Early Receipt allowed',p_line_rec.Days_early_receipt_allowed(p_line_rec_index));
 WSH_DEBUG_SV.log(l_module_name,'Late Receipt Allowed',p_line_rec.Days_late_receipt_allowed(p_line_rec_index));
 WSH_DEBUG_SV.log(l_module_name,'l_del_edd',l_del_edd);
 WSH_DEBUG_SV.log(l_module_name,'l_del_ldd',l_del_ldd);
END IF;*/

IF ((l_dd_info.inventory_item_id is NULL and p_line_rec.inventory_item_id(p_line_rec_index) is NOT NULL )
   OR (l_dd_info.inventory_item_id <> p_line_rec.inventory_item_id(p_line_rec_index)) ) THEN
   -- Collecting the list of delivery_detail_ids for which inv item id has changed.
   -- This list is later used in Reapprove PO to re-calcualte the weight and volume.
   p_wt_vol_dd_id (p_wt_vol_dd_id.COUNT +1) := l_dd_info.delivery_detail_id;
END IF;

IF nvl(l_dd_info.source_header_id,-99) <>
   nvl(p_line_rec.header_id(p_line_rec_index),-99)OR
   nvl(l_dd_info.source_blanket_reference_id,-99) <>
   nvl(p_line_rec.source_blanket_reference_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.source_line_id,-99) <>
   nvl(p_line_rec.line_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.ship_from_site_id,-99) <>
   nvl(p_line_rec.ship_from_site_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.customer_item_id,-99) <>
   nvl(p_line_rec.customer_item_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.source_line_type_code,'!!!') <>
   nvl(p_line_rec.source_line_type_code(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.sold_to_contact_id,-99) <>
   nvl(p_line_rec.sold_to_contact_id(p_line_rec_index),-99)OR
   nvl(l_dd_info.vendor_id,-99) <>
   nvl(p_line_rec.vendor_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.inventory_item_id,-99) <>
   nvl(p_line_rec.inventory_item_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.item_description,'!!!') <>
   nvl(p_line_rec.item_description(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.hazard_class_id,-99) <>
   nvl(p_line_rec.hazard_class_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.country_of_origin,'!!!') <>
   nvl(p_line_rec.country_of_origin(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.ship_to_location_id,-99) <>
   nvl(p_line_rec.ship_to_location_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.ship_to_contact_id,-99) <>
   nvl(p_line_rec.ship_to_contact_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.deliver_to_location_id,-99) <>
   nvl(p_line_rec.deliver_to_location_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.deliver_to_contact_id,-99) <>
   nvl(p_line_rec.deliver_to_contact_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.intmed_ship_to_location_id,-99) <>
   nvl(p_line_rec.intmed_ship_to_location_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.intmed_ship_to_contact_id,-99) <>
   nvl(p_line_rec.intermed_ship_to_contact_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.hold_code,'!!!') <>
   nvl(p_line_rec.hold_code(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.ship_tolerance_above,-99)  <>
   nvl(p_line_rec.ship_tolerance_above(p_line_rec_index),-99) OR
   nvl(l_dd_info.ship_tolerance_below,-99) <>
   nvl(p_line_rec.ship_tolerance_below(p_line_rec_index),-99) OR
   nvl(l_dd_info.revision,'!!!')  <>
   nvl(p_line_rec.revision(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.date_requested,FND_API.G_MISS_DATE) <>
   nvl(nvl(p_line_rec.request_date(p_line_rec_index),p_line_rec.schedule_ship_date(p_line_rec_index)),FND_API.G_MISS_DATE) OR
   nvl(l_dd_info.date_scheduled,FND_API.G_MISS_DATE) <>
   nvl(p_line_rec.schedule_ship_date(p_line_rec_index),FND_API.G_MISS_DATE) OR
   nvl(l_dd_info.ship_method_code,'!!!')  <>
   nvl(p_line_rec.shipping_method_code(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.carrier_id,-99)  <>
   nvl(p_line_rec.carrier_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.freight_terms_code,'!!!')  <>
   nvl(p_line_rec.freight_terms_code(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.fob_code,'!!!')  <>
   nvl(p_line_rec.fob_point_code(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.supplier_item_number,'!!!') <>
   nvl(p_line_rec.supplier_item_num(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.customer_prod_seq,'!!!') <>
   nvl(p_line_rec.cust_production_seq_num(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.customer_dock_code,'!!!') <>
   nvl(p_line_rec.customer_dock_code(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.cust_model_serial_number,'!!!')  <>
   nvl(p_line_rec.cust_model_serial_number(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.customer_job,'!!!')  <>
   nvl(p_line_rec.customer_job(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.customer_production_line,'!!!') <>
   nvl(p_line_rec.customer_production_line(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.organization_id,-99)  <>
   nvl(p_line_rec.organization_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.ship_model_complete_flag,'!!!')  <>
   nvl(p_line_rec.ship_model_complete_flag(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.top_model_line_id,-99)  <>
   nvl(p_line_rec.top_model_line_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.source_header_number,'!!!')  <>
   nvl(p_line_rec.source_header_number(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.source_header_type_name,'!!!')  <>
   nvl(p_line_rec.source_header_type_name(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.cust_po_number,'!!!') <>
   nvl(p_line_rec.cust_po_number(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.ato_line_id,-99)  <>
   nvl(p_line_rec.ato_line_id(p_line_rec_index),-99) OR
 --nvl(l_dd_info.tracking_number,'!!!')  <>
 --nvl(p_line_rec.tracking_number(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.shipping_instructions,'!!!')  <>
   nvl(p_line_rec.shipping_instructions(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.packing_instructions,'!!!')  <>
   nvl(p_line_rec.packing_instructions(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.org_id,-99)  <>
   nvl(p_line_rec.org_id(p_line_rec_index),-99) OR
   nvl(l_dd_info.source_line_number,'!!!')  <>
   nvl(p_line_rec.source_line_number(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.unit_price,-99)  <>
   nvl(p_line_rec.unit_list_price(p_line_rec_index),-99) OR
   nvl(l_dd_info.currency_code,'!!!')  <>
   nvl(p_line_rec.currency_code(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.preferred_grade,'!!!')  <>
   nvl(p_line_rec.preferred_grade(p_line_rec_index),'!!!') OR
   nvl(l_dd_info.po_shipment_line_number,-99)  <>
   nvl(p_line_rec.po_shipment_line_number(p_line_rec_index),-99) OR
   nvl(l_dd_info.source_blanket_reference_num,-99)  <>
   nvl(p_line_rec.source_blanket_reference_num(p_line_rec_index),-99) OR
   nvl(p_line_rec.po_revision(p_line_rec_index),-99) <>
   nvl(l_dd_info.po_revision_number,-99) OR
   nvl(p_line_rec.release_revision(p_line_rec_index),-99) <>
   nvl(l_dd_info.release_revision_number,-99) OR
   -- Added for Bug#: 3145863
   --J-IB-ANJ
   /*nvl(l_dd_info.earliest_dropoff_date, sysdate) <> nvl(l_del_edd,sysdate) OR
   nvl(l_dd_info.latest_dropoff_date, sysdate) <> nvl(l_del_ldd,sysdate)  THEN*/
   nvl(l_dd_info.earliest_dropoff_date, sysdate) <> nvl(l_Earliest_delivery_Date,sysdate) OR
   nvl(l_dd_info.latest_dropoff_date, sysdate) <> nvl(l_latest_delivery_date,sysdate)  THEN

-- Only if any of the non-quantity attribtues are changed in the PO, the delivery details
-- is updated.
-- If only quantity is changed, then this is taken care in Update_quantity API.

  UPDATE WSH_DELIVERY_DETAILS
  SET
  source_header_id = p_line_rec.header_id(p_line_rec_index),
  source_blanket_reference_id=p_line_rec.source_blanket_reference_id(p_line_rec_index),
  source_line_id=p_line_rec.line_id(p_line_rec_index),
  ship_from_site_id = p_line_rec.ship_from_site_id(p_line_rec_index),
  customer_item_id = p_line_rec.customer_item_id(p_line_rec_index),
  source_line_type_code  = p_line_rec.source_line_type_code(p_line_rec_index),
  sold_to_contact_id=p_line_rec.sold_to_contact_id(p_line_rec_index),
  vendor_id=p_line_rec.vendor_id(p_line_rec_index),
  inventory_item_id=p_line_rec.inventory_item_id(p_line_rec_index),
  item_description=p_line_rec.item_description(p_line_rec_index),
  hazard_class_id=p_line_rec.hazard_class_id(p_line_rec_index),
  country_of_origin=p_line_rec.country_of_origin(p_line_rec_index),
  ship_to_location_id=p_line_rec.ship_to_location_id(p_line_rec_index),
  ship_to_contact_id=p_line_rec.ship_to_contact_id(p_line_rec_index),
  ship_to_site_use_id=p_line_rec.ship_to_org_id(p_line_rec_index),
  deliver_to_location_id=p_line_rec.deliver_to_location_id(p_line_rec_index),
  deliver_to_contact_id=p_line_rec.deliver_to_contact_id(p_line_rec_index),
  deliver_to_site_use_id=p_line_rec.deliver_to_org_id(p_line_rec_index),
  intmed_ship_to_location_id=p_line_rec.intmed_ship_to_location_id(p_line_rec_index),
  intmed_ship_to_contact_id=p_line_rec.intermed_ship_to_contact_id(p_line_rec_index),
  hold_code=p_line_rec.hold_code(p_line_rec_index),
  ship_tolerance_above=p_line_rec.ship_tolerance_above(p_line_rec_index),
  ship_tolerance_below=p_line_rec.ship_tolerance_below(p_line_rec_index),
  revision=p_line_rec.revision(p_line_rec_index),
  date_requested = p_line_rec.request_date(p_line_rec_index),
  date_scheduled= p_line_rec.schedule_ship_date(p_line_rec_index),
/*J-IB-ANJ*/
  -- Start - Changed for Bug#: 3145863
/*  earliest_dropoff_date = l_del_edd,
  latest_dropoff_date = l_del_ldd, */
  -- End - Changed for Bug#: 3145863
  --J-IB-ANJ
  earliest_dropoff_date = l_Earliest_delivery_Date,
  latest_dropoff_date = l_latest_delivery_date,
  ship_method_code=p_line_rec.shipping_method_code(p_line_rec_index),
  carrier_id=p_line_rec.carrier_id(p_line_rec_index),
  freight_terms_code=p_line_rec.freight_terms_code(p_line_rec_index),
  fob_code=p_line_rec.fob_point_code(p_line_rec_index),
  supplier_item_number=p_line_rec.supplier_item_num(p_line_rec_index),
  customer_prod_seq=p_line_rec.cust_production_seq_num(p_line_rec_index),
  customer_dock_code=p_line_rec.customer_dock_code(p_line_rec_index),
  cust_model_serial_number=p_line_rec.cust_model_serial_number(p_line_rec_index),
  customer_job=p_line_rec.customer_job(p_line_rec_index),
  customer_production_line=p_line_rec.customer_production_line(p_line_rec_index),
  /*net_weight=p_line_rec.net_weight(p_line_rec_index),
  weight_uom_code=p_line_rec.weight_uom_code(p_line_rec_index),
  volume=p_line_rec.volume(p_line_rec_index),
  volume_uom_code=p_line_rec.volume_uom_code(p_line_rec_index),*/
  organization_id=p_line_rec.organization_id(p_line_rec_index),
  ship_model_complete_flag=p_line_rec.ship_model_complete_flag(p_line_rec_index),
  top_model_line_id=p_line_rec.top_model_line_id(p_line_rec_index),
  source_header_number=p_line_rec.source_header_number(p_line_rec_index),
  source_header_type_name=p_line_rec.source_header_type_name(p_line_rec_index),
  cust_po_number=p_line_rec.cust_po_number(p_line_rec_index),
  ato_line_id=p_line_rec.ato_line_id(p_line_rec_index),
--  tracking_number=p_line_rec.tracking_number(p_line_rec_index),
  shipping_instructions=p_line_rec.shipping_instructions(p_line_rec_index),
  packing_instructions=p_line_rec.packing_instructions(p_line_rec_index),
  org_id=p_line_rec.org_id(p_line_rec_index),
  source_line_number=p_line_rec.source_line_number(p_line_rec_index),
  unit_price=p_line_rec.unit_list_price(p_line_rec_index),
  currency_code=p_line_rec.currency_code(p_line_rec_index),
  preferred_grade=p_line_rec.preferred_grade(p_line_rec_index),
  po_shipment_line_id=p_line_rec.po_shipment_line_id(p_line_rec_index),
  po_revision_number=p_line_rec.po_revision(p_line_rec_index),
  release_revision_number=p_line_rec.release_revision(p_line_rec_index),
  po_shipment_line_number=p_line_rec.po_shipment_line_number(p_line_rec_index),
  source_blanket_reference_num=p_line_rec.source_blanket_reference_num(p_line_rec_index),
  last_update_date = SYSDATE,
  last_updated_by =  FND_GLOBAL.USER_ID,
  last_update_login =  FND_GLOBAL.LOGIN_ID
  WHERE po_shipment_line_id = p_line_rec.po_shipment_line_id(p_line_rec_index) AND
        delivery_detail_id  = nvl(p_dd_id,delivery_detail_id)
  AND  source_header_id = p_line_rec.header_id(p_line_rec_index) AND
       source_line_id = p_line_rec.line_id(p_line_rec_index) ANd
       source_code = 'PO' AND
       ((p_line_rec.source_blanket_reference_id(p_line_rec_index) IS NULL AND
         source_blanket_reference_id IS NULL) OR
       (p_line_rec.source_blanket_reference_id(p_line_rec_index) IS NOT NULL
       AND source_blanket_reference_id = p_line_rec.source_blanket_reference_id(p_line_rec_index))) AND
       released_status = 'X' AND
       container_flag = 'N';

  END IF;

END LOOP;

IF l_tp_del_id.COUNT > 0 THEN
-- Call TP API for the list of delivery id's in l_tp_del_id.
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TP_RELEASE.calculate_cont_del_tpdates',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;

   WSH_TP_RELEASE.calculate_cont_del_tpdates(
     p_entity => 'DLVY',
     p_entity_ids => l_tp_del_id,
     x_return_status => l_return_status);

   wsh_util_core.api_post_call(
     p_return_status =>l_return_status,
     x_num_warnings  => l_num_warnings,
     x_num_errors    => l_num_errors);

l_tp_del_id.delete;

END IF;

l_ind := l_del_fgt_terms_tbl_cache.FIRST;

WHILE l_ind IS NOT NULL
LOOP
  --copying cached data to l_del_fgt_terms_tbl
  l_del_fgt_terms_tbl(l_del_fgt_terms_tbl.count + 1) := l_del_fgt_terms_tbl_cache(l_ind).value;
  l_ind := l_del_fgt_terms_tbl_cache.NEXT(l_ind);
END LOOP;
l_ind := l_del_fgt_terms_tbl_ext_cache.FIRST;
WHILE l_ind IS NOT NULL
LOOP
  l_del_fgt_terms_tbl(l_del_fgt_terms_tbl.count + 1) := l_del_fgt_terms_tbl_ext_cache(l_ind).value;
  l_ind := l_del_fgt_terms_tbl_ext_cache.NEXT(l_ind);
END LOOP;
--



IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_del_fgt_terms_tbl count is ' || l_del_fgt_terms_tbl.COUNT);
END IF;

IF l_del_fgt_terms_tbl.COUNT > 0 THEN
   --update the freight terms of delivery
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS. update_freight_terms',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;

  FOR i in 1..l_del_fgt_terms_tbl.COUNT LOOP
    WSH_NEW_DELIVERY_ACTIONS. update_freight_terms
    (  p_delivery_id          => l_del_fgt_terms_tbl(i),
       p_action_code          => 'ASSIGN',
       x_freight_terms_Code   => l_fgt_terms_code,
       x_return_status        => l_return_status);

  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);

  END LOOP;
END IF;
l_del_fgt_terms_tbl.delete;
--}
END IF;
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_shippingControlTurnedOn',l_shippingControlTurnedOn);
END IF;
--
IF l_shippingControlTurnedOn THEN
--{
    l_action_prms.caller := 'PO_INTG';
				/*
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_IB_TXN_MATCH_PKG.handlePriorReceipts',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    --
    WSH_IB_TXN_MATCH_PKG.handlePriorReceipts
      (
        p_action_prms      => l_action_prms,
        x_line_rec         => p_line_rec,
        x_return_status    => l_return_status
      );
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call
      (
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors
      );
						*/

--}
END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN e_wdd_locked THEN
    ROLLBACK TO Update_dd_Attributes_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_LOCKED');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'e_Wdd_locked exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_Wdd_locked');
END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_dd_Attributes_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN OTHERS THEN
    ROLLBACK TO Update_dd_Attributes_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_CMG_PVT.Update_dd_Attributes',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_dd_Attributes;


/*========================================================================
-- PROCEDURE : Update_Quantity
-- HISTORY   : Created the API.
========================================================================*/
-- Start of comments
-- API name : Update_quantity
-- Type     : Private
-- Pre-reqs : None.
-- Function : This API gets called from two places:
--            1. PO Reapproval
--            2.ASN/Receipt Integration
--
--            1.When called from PO Reapproval,the execution is as follows:
--              For every Line_location_id passed by PO, check the total
--              source quantity against the passed quantity.
--              - If no records found for the line_location_id, it is a
--                case of new record to be inserted in the
--                WSH_DELIVERY_DETAILS table.
--              - If records are found, then check if it a case of
--                Incrementing the quantity or decrementing the quantity.
--                - If the case is INCREMENT, then the additional qty is updated on to
--                  the open delivery detail.If no open delivery detail is found, then
--                  a new record is inserted into wsh_delivery_details for the
--                  additional quantity.
--                - In case of DECREMENT in the qty, the changes are first applied to
--                  lines with null routing request id.
--                  If no such lines are found, then the changes are applied to line
--                  with routing request id .
--                  The changes are applied to lines in the order of the latest earliest_pickup_date.
--                  Also checks if all the delivery details for the present line location id have
--                  the same ship from or not.If the lines have different ship from location id,
--                  then the ship_from_location_id is updated to -1.
--              - This also takes care of the quantity change happening due to
--                change in the ordered UOM.
--
--            2.When called from ASN/Receipt Integration, the case is set to 'INCREMENT'.
--              - The quantity that needs to be incremeted is specified by
--                p_line_rec.consolidate_quantity.
--
-- Parameters :
-- IN OUT:
--   p_line_rec       IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL
--      This record structure contains information about the lines to be updated.
--      The information may include header id,line id ,line location id and other po
--      attributes..
--   p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type
--       This contains the list of delviery details that needs to be unassigned from
--       the respective delivery.
--   p_wt_vol_dd_id IN OUT NOCOPY wsh_util_core.id_tab_type,
--       This contains the list of delviery details for which weight and volume needs to
--        be re-calculated.
--   p_action_prms    IN  OUT NOCOPY WSH_BULK_TYPES_GRP.action_parameters_rectype
--      The record which specifies the caller, actio to be performed(REAPPROVE,CANCEL_ASN,RECEIPT,ASN)
-- OUT:
--   x_return_status  OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE Update_Quantity(
p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN OUT NOCOPY WSH_BULK_TYPES_GRP.action_parameters_rectype,
p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type,
p_wt_vol_dd_id     IN OUT NOCOPY wsh_util_core.id_tab_type,
x_return_status       OUT NOCOPY VARCHAR2) IS

-- Cursor to get the source requested quantity corresponding to the
-- po_line_location_id.

Cursor c_src_qty(p_line_location_id NUMBER,p_header_id NUMBER,p_line_id NUMBER)
 is
select src_requested_quantity,
src_requested_quantity_uom,
src_requested_quantity2,
--HACMS {
requested_quantity_uom,
inventory_item_id
--HACMS }
from WSH_DELIVERY_DETAILS
where po_shipment_line_id = p_line_location_id and
source_code = 'PO' AND
source_header_id = p_header_id AND
source_line_id   = p_line_id AND
rownum = 1;

--Cursor to get the count of lines with null routing request id in wdd.

Cursor c_dd_count_with_null_rr(p_line_location_id NUMBER,p_header_id NUMBER,p_line_id NUMBER) is
SELECT count(*)
FROM wsh_delivery_details
WHERE released_status = 'X' and
source_code = 'PO' AND
source_header_id = p_header_id AND
source_line_id   = p_line_id AND
po_shipment_line_id = p_line_location_id and
routing_req_id is null;

-- Cursor to find out if there are any open delivery detail with null
-- routing request id which is later used in the 'INCREMENT' quantity case.

Cursor c_inc_qty(p_line_location_id NUMBER,p_header_id NUMBER,p_line_id NUMBER)is
select
delivery_detail_id,
requested_quantity,
--HACMS {
requested_quantity_uom ,
inventory_item_id,
--HACMS }
last_update_date
from WSH_DELIVERY_DETAILS
where released_status = 'X' and
source_code = 'PO' AND
source_header_id = p_header_id AND
source_line_id   = p_line_id AND
po_shipment_line_id = p_line_location_id and
routing_req_id IS NULL
and rownum = 1;


--HACMS {
-- Cursor to fetch the requested_qty ,uom, picked_qty which is later used
-- to take care of the UOM changes for one time items.
cursor c_lines_all(p_line_location_id NUMBER,p_header_id NUMBER,p_line_id NUMBER) is
select
delivery_detail_id,
requested_quantity qty,
picked_quantity pick_qty,
requested_quantity_uom qty_uom,
inventory_item_id,
last_update_date
from
wsh_delivery_details
where released_status = 'X' and
source_code = 'PO' AND
source_header_id = p_header_id AND
source_line_id   = p_line_id AND
po_shipment_line_id = p_line_location_id;
--HACMS }

--Cursor to check if lines with null routing request id exists in wdd.

cursor c_lines_without_rr(p_line_location_id NUMBER,p_header_id NUMBER,p_line_id NUMBER) is
select
delivery_detail_id,
requested_quantity qty,
--HACMS {
inventory_item_id,
requested_quantity_uom qty_uom,
last_update_date
--HACMS }
from
wsh_delivery_details
where released_status = 'X' and
source_code = 'PO' AND
source_header_id = p_header_id AND
source_line_id   = p_line_id AND
po_shipment_line_id = p_line_location_id and
routing_req_id is null
order by qty asc;

--Cursor to check if lines with routing request id exists in wdd
--The lines are fetched in the order of the latest earliest_pickup_date.

cursor c_lines_with_rr(p_line_location_id NUMBER,p_header_id NUMBER,p_line_id NUMBER) is
select
wdd.requested_quantity qty,
wdd.delivery_detail_id,
wnd.delivery_id,
wdd.ship_from_location_id,
wdd.routing_req_id,
wnd.planned_flag,
--wdd.ignore_for_planning,
nvl(wdd.ignore_for_planning, 'N') ignore_for_planning,
--HACMS {
wdd.inventory_item_id,
wdd.picked_quantity pick_qty,
wdd.requested_quantity_uom qty_uom,
wdd.ship_to_location_id,
wnd.ultimate_dropoff_location_id del_location,
--HACMS }
wdd.last_update_date
from
wsh_delivery_details wdd,
wsh_delivery_assignments_v wda,
wsh_new_deliveries wnd
where wdd.released_status = 'X' and
WDD.source_code = 'PO' AND
WDD.source_header_id = p_header_id AND
WDD.source_line_id   = p_line_id AND
wdd.po_shipment_line_id = p_line_location_id and
wda.delivery_detail_id = wdd.delivery_detail_id and
wnd.delivery_id(+) = wda.delivery_id and
wdd.routing_req_id is not null
order by wdd.earliest_pickup_date desc;

-- Cursor to find out if the ship from location id is same or different on the delivery details
-- belonging to the same po line location id.

CURSOR c_ship_from_count(p_line_location_id NUMBER,p_header_id NUMBER,p_line_id NUMBER) is
SELECT count(distinct(ship_from_location_id))
FROM wsh_delivery_details
WHERE released_status = 'X' and
source_code = 'PO' AND
source_header_id = p_header_id AND
source_line_id   = p_line_id AND
po_shipment_line_id = p_line_location_id and
routing_req_id is not null;

l_case         VARCHAR2(20);
l_insert_new_dd      VARCHAR2(1);
l_remaining_qty      NUMBER  ;
l_qty_to_change_ord_uom      NUMBER ;
l_qty_to_change      NUMBER  ;
l_requested_qty      NUMBER  ;
l_cancelled_qty      NUMBER  ;
l_released_status    VARCHAR2(1);
l_ignore_for_planning VARCHAR2(1);
l_sf_count           NUMBER;
l_sf_differs         VARCHAR2(1);
l_ship_from_location_id NUMBER;
l_routing_request_id NUMBER;
l_record_with_null_rr NUMBER;
l_src_qty     NUMBER  ;
l_src_qty2    NUMBER  ;
l_src_qty_uom     VARCHAR2(3)  ;
temp_qty    NUMBER  ;
l_last_update_date DATE;
l_return_status   VARCHAR2(1);
l_delivery_detail_id  NUMBER;
l_validate_flag   VARCHAR2(1);
l_dff_attribute     WSH_FLEXFIELD_UTILS.FlexfieldAttributeTabType ;
l_dff_context       VARCHAR2(150);
l_dff_update_flag   VARCHAR2(1);
l_additional_line_info_rec WSH_BULK_PROCESS_PVT.additional_line_info_rec_type;
l_delivery_details_info wsh_glbl_var_strct_grp.delivery_details_rec_type;
l_new_delivery_detail_id   NUMBER;
detail_rowid VARCHAR2(30);
x_rowid NUMBER;
x_delivery_detail_id NUMBER;
l_tab_count               NUMBER := 0;

l_init_msg_list         VARCHAR2(30) := NULL;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(3000);
l_commit                VARCHAR2(1);
l_validation_level      NUMBER;
l_delivery_id      NUMBER;
l_delivery_name VARCHAR2(150);
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_dd_id          NUMBER;
v_item_info_rec         wsh_util_validate.item_info_rec_type;
l_ratio          NUMBER;
l_ratio_tbl          WSH_UTIL_CORE.id_tab_type;
l_sum_req_qty      NUMBER;
l_requested_qty2 NUMBER;
temp_qty2 NUMBER;
l_diff_qty2 NUMBER;

l_dd_ids_dd_ids_cache      WSH_UTIL_CORE.key_value_tab_type;
l_dd_ids_dd_ids_ext_cache  WSH_UTIL_CORE.key_value_tab_type;

-- Bug 3395410 : Added the following variable.
l_routing_response_send    VARCHAR2(1);

l_action_prms WSH_BULK_TYPES_GRP.action_parameters_rectype;

l_ind NUMBER;
j NUMBER;

--HACMS {
l_requested_quantity_uom        VARCHAR2(3);
l_new_req_qty_uom               VARCHAR2(3);
l_requested_quantity    NUMBER;
l_inventory_item_id             NUMBER;
l_src_qty_to_change             NUMBER;
l_tmp_requested_quantity        NUMBER;

l_conv_pick_qty     NUMBER;
l_qty_to_split      NUMBER;
l_qty_to_split2     NUMBER;
l_pick_qty      NUMBER;
l_split_delivery_detail_id  NUMBER;
l_req_res_id  NUMBER;
l_msg   varchar2(2000);
l_update_flag BOOLEAN := FALSE;
--HACMS }
l_caller         VARCHAR2(20);
--
e_wdd_locked EXCEPTION ;
PRAGMA  EXCEPTION_INIT(e_wdd_locked,-54);

l_detail_tab   WSH_UTIL_CORE.id_tab_type; -- DBI Project
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_QUANTITY';
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
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;
--
SAVEPOINT Update_Quantity_PVT;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



--code to copy to cache tables


l_ind := p_wt_vol_dd_id.FIRST;
WHILE l_ind IS NOT NULL
LOOP
 wsh_util_core.get_cached_value(
      p_cache_tbl       => l_dd_ids_dd_ids_cache,
      p_cache_ext_tbl   => l_dd_ids_dd_ids_ext_cache,
      p_value           => p_wt_vol_dd_id(l_ind),
      p_key             => p_wt_vol_dd_id(l_ind),
      p_action          => 'PUT',
      x_return_status   => l_return_status);

               wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors);

l_ind :=  p_wt_vol_dd_id.next(l_ind);
END LOOP;

-- Assigning the l_action_prms with the p_action_prms so that all the attributes
-- and column values are still retained in l_action_prms.
l_action_prms := p_action_prms;
For i in p_line_rec.po_shipment_line_id.FIRST..p_line_rec.po_shipment_line_id.LAST

  LOOP
    l_remaining_qty         := 0;
    l_qty_to_change_ord_uom := 0;
    l_qty_to_change         := 0;
    l_requested_qty         := 0;
    l_cancelled_qty         := 0;
    temp_qty                := 0;
    l_insert_new_dd         := NULL;
    l_case              := NULL;
    l_new_req_qty_uom       := NULL; --HACMS
    --initlizing c_src_qty cursor's fetch variables to null for each iteration
    l_src_qty               := NULL;
    l_src_qty_uom           := NULL;
    l_src_qty2              := NULL;
    l_requested_quantity_uom := NULL;
    l_inventory_item_id     := NULL;
    --

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'i',i);
      WSH_DEBUG_SV.log(l_module_name,'header_id',p_line_rec.header_id(i));
      WSH_DEBUG_SV.log(l_module_name,'line_id',p_line_rec.line_id(i));
      WSH_DEBUG_SV.log(l_module_name,'po_shipment_line_id',p_line_rec.po_shipment_line_id(i));
      WSH_DEBUG_SV.log(l_module_name,'ordered_quantity',p_line_rec.ordered_quantity(i));
      WSH_DEBUG_SV.log(l_module_name,'order_quantity_uom',p_line_rec.order_quantity_uom(i));
      WSH_DEBUG_SV.log(l_module_name,'ordered_quantity2',p_line_rec.ordered_quantity2(i));
      WSH_DEBUG_SV.log(l_module_name,'ordered_quantity_uom2',p_line_rec.ordered_quantity_uom2(i));
    END IF;
    -- get the source requested quantity for the line location.

    OPEN c_src_qty(p_line_rec.po_shipment_line_id(i),p_line_rec.header_id(i),
                   p_line_rec.line_id(i));
    FETCH c_src_qty INTO l_src_qty,l_src_qty_uom,l_src_qty2,
            l_requested_quantity_uom,l_inventory_item_id; --HACMS
    CLOSE c_src_qty;
    -- The l_ratio is calculated on the basis of the new ordered quantity2.

    l_ratio := p_line_rec.ordered_quantity2(i)/p_line_rec.ordered_quantity(i); --HACMS
    l_ratio_tbl(i) := l_ratio;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_src_qty', l_src_qty);
      WSH_DEBUG_SV.log(l_module_name,'l_src_qty2', l_src_qty2);
      WSH_DEBUG_SV.log(l_module_name,'l_src_qty_uom',l_src_qty_uom);
      --HACMS {
      WSH_DEBUG_SV.log(l_module_name,'l_requested_quantity_uom',l_requested_quantity_uom);
      WSH_DEBUG_SV.log(l_module_name,'l_inventory_item_id',l_inventory_item_id);
      WSH_DEBUG_SV.log(l_module_name,'l_ratio',l_ratio);
      WSH_DEBUG_SV.log(l_module_name,'l_ratio_tbl(i)',l_ratio_tbl(i));
      --HACMS }
      WSH_DEBUG_SV.log(l_module_name,'p_action_prms.action_code', p_action_prms.action_code);
    END IF;


    IF l_src_qty IS NOT NULL AND p_action_prms.action_code = 'REAPPROVE_PO'
    THEN
    --{
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_line_rec.ordered_quantity(i)',p_line_rec.ordered_quantity(i));
         WSH_DEBUG_SV.log(l_module_name,'p_line_rec.order_quantity_uom(i)',p_line_rec.order_quantity_uom(i));
       END IF;
      -- Check if ordered_quantity is different from  source_requested_quantity or
      -- ordered_quantity_uom is different from source_requested_quantity_uom.
      IF (p_line_rec.ordered_quantity(i) <> l_src_qty OR
         p_line_rec.order_quantity_uom(i) <> l_src_qty_uom) THEN
        --HACMS {
        IF (l_inventory_item_id IS NOT NULL) THEN
	   -- If qyt is different from src qty or uom is different from src_uom ,then
	   -- call the WSH_INBOUND_UTIL_PKG.convert_quantity API to find the actual qty
	   -- that needs to be chagned in ordered uom.
	   -- This is done only if inventory item id is not null.
	   IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.convert_quantity',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

	   WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            => p_line_rec.inventory_item_id(i),
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => p_line_rec.order_quantity_uom(i),
              p_quantity               => l_src_qty,
              p_qty_uom_code           => l_src_qty_uom,
              x_conv_qty               => l_src_qty_to_change,
              x_return_status          => l_return_status);

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'convert_quantity l_return_status',l_return_status);
             WSH_DEBUG_SV.log(l_module_name,'l_src_qty_to_change',l_src_qty_to_change);
           END IF;

            wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors);


           l_qty_to_change_ord_uom := abs(p_line_rec.ordered_quantity(i) - l_src_qty_to_change);
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_qty_to_change_ord_uom',l_qty_to_change_ord_uom);
           END IF;
           -- Call WSH_INBOUND_UTIL_PKG.convert_quantity to convert the ordered qty to base uom .

	   IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.convert_quantity',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            =>  p_line_rec.inventory_item_id(i),
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => l_requested_quantity_uom,
              p_quantity               => l_qty_to_change_ord_uom,
              p_qty_uom_code           => p_line_rec.order_quantity_uom(i),
              x_conv_qty               => l_qty_to_change,
              x_return_status          => l_return_status);

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'convert_quantity l_return_status,l_qty_to_change',l_return_status||','||l_qty_to_change);
           END IF;
           wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors);

          -- if ordered_quantity is less that src_qty then the case is 'DECREMENT'
	  -- if ordered_quantity is greater than src_qty then the case is 'INCREMENT'.

          IF (p_line_rec.ordered_quantity(i) < l_src_qty_to_change) THEN
            l_case := 'DECREMENT';
          ELSIF (p_line_rec.ordered_quantity(i) > l_src_qty_to_change) then
            l_case := 'INCREMENT';
          END IF;--Finding Case of Increment/Decrement.

        ELSE
          --One time item i.e if inventory_item_id is null
           IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.convert_quantity',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;

           WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            => p_line_rec.inventory_item_id(i),
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => p_line_rec.order_quantity_uom(i),
              p_quantity               => l_src_qty,
              p_qty_uom_code           => l_src_qty_uom,
              x_conv_qty               => l_src_qty_to_change,
              x_return_status          => l_return_status);

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'convert_quantity l_return_status',l_return_status);
             WSH_DEBUG_SV.log(l_module_name,'l_src_qty_to_change',l_src_qty_to_change);
           END IF;

            wsh_util_core.api_post_call(
              p_return_status => l_return_status,
              x_num_warnings  => l_num_warnings,
              x_num_errors    => l_num_errors);


          l_qty_to_change := abs(p_line_rec.ordered_quantity(i) - l_src_qty_to_change);
          l_new_req_qty_uom:= p_line_rec.order_quantity_uom(i);

          IF (p_line_rec.ordered_quantity(i) < l_src_qty_to_change) THEN
             l_case := 'DECREMENT';
          ELSIF (p_line_rec.ordered_quantity(i) > l_src_qty_to_change) then
             l_case := 'INCREMENT';
          END IF;--Finding Case of Increment/Decrement.

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'l_qty_to_change',l_qty_to_change);
             WSH_DEBUG_SV.log(l_module_name,'l_new_req_qty_uom',l_new_req_qty_uom);
           END IF;
        END IF;
        --HACMS }

      ELSE
        --No qty change, then go to the next record in p_line_rec.

        GOTO next_p_line_rec;
      END IF;--quantity change is there.
      --}
    ELSIF l_src_qty is NOT NULL AND (p_action_prms.action_code = 'ASN' OR
      p_action_prms.action_code = 'RECEIPT') THEN
      -- In case the Reapprove_PO api is called from ASN or RECEIPT, we
      -- set the case as INCREMENT.
      l_qty_to_change := nvl(p_line_rec.consolidate_quantity(i),0);
      l_case := 'INCREMENT';

    ELSE--insert case
      -- No delivery detail is present for the corresponding po shipment line.
      -- This is an insert case.
      l_insert_new_dd := 'Y';

    END IF;
    --}

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_insert_new_dd', l_insert_new_dd);
      WSH_DEBUG_SV.log(l_module_name,'l_case', l_case);
    END IF;

    IF l_case = 'DECREMENT' THEN
    --{
      -- First the decrement of qty is done on delivery details with null routing request id.
      l_remaining_qty := l_qty_to_change;

      FOR v_lines_without_rr IN c_lines_without_rr(p_line_rec.po_shipment_line_id(i),p_line_rec.header_id(i),p_line_rec.line_id(i))
      LOOP
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_qty_to_change',l_qty_to_change);
           WSH_DEBUG_SV.log(l_module_name,' v_lines_without_rr.qty', v_lines_without_rr.qty);
           WSH_DEBUG_SV.log(l_module_name,' v_lines_without_rr.delivery_detail_id', v_lines_without_rr.delivery_detail_id);
           WSH_DEBUG_SV.log(l_module_name,' v_lines_without_rr.last_update_date', v_lines_without_rr.last_update_date);
         END IF;

        --HACMS {
        l_requested_quantity:=v_lines_without_rr.qty;

        IF (v_lines_without_rr.inventory_item_id IS NULL and
             v_lines_without_rr.qty_uom <> p_line_rec.order_quantity_uom(i)) THEN

          l_new_req_qty_uom := p_line_rec.order_quantity_uom(i);

           WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            =>  p_line_rec.inventory_item_id(i),
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => p_line_rec.order_quantity_uom(i),
              p_quantity               => v_lines_without_rr.qty,
              p_qty_uom_code           => l_requested_quantity_uom,
              x_conv_qty               => l_requested_quantity,
              x_return_status          => l_return_status);

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              WSH_DEBUG_SV.log(l_module_name,'l_requested_quantity',l_requested_quantity);
            END IF;
        END IF;
        --HACMS }

        IF l_qty_to_change < l_requested_quantity THEN --HACMS
	-- IF the qty to be changed is less that the requested quantity, then
	-- the open delivery detail is updated with the new qty.
           l_requested_qty := l_requested_quantity - l_qty_to_change; --HACMS
           l_cancelled_qty := l_qty_to_change;
           l_released_status := 'X';
           l_remaining_qty := 0;
        ELSIF l_qty_to_change = l_requested_quantity then --HACMS
	-- If the qty to be changed is equal to the requested quantity, then the
	-- delviery detail gets updatd to 'D'(Cancelled).
           l_requested_qty := 0;
           l_cancelled_qty := l_qty_to_change;
           l_released_status := 'D';
           l_remaining_qty := 0;
        ELSE
	-- If the qty to be changed is greater than the requested quantity, then
	-- the delivery detail is updated to 'D'( Cancelled').
	-- The new qyt that needs to be updated is determined and this is
	-- updated once again on to the next available open delivery detail.
           temp_qty := l_qty_to_change - l_requested_quantity; --HACMS
           l_requested_qty := 0;
           l_cancelled_qty := l_qty_to_change;
           l_released_status := 'D';
           l_qty_to_change := temp_qty;
           l_remaining_qty := temp_qty;
        END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_requested_qty',l_requested_qty);
           WSH_DEBUG_SV.log(l_module_name,'l_requested_qty2',l_requested_qty2);
           WSH_DEBUG_SV.log(l_module_name,'l_cancelled_qty',l_cancelled_qty);
           WSH_DEBUG_SV.log(l_module_name,'l_released_status',l_released_status);
           WSH_DEBUG_SV.log(l_module_name,'l_remaining_qty',l_remaining_qty);
        END IF;

        --Collecting the list of delviery_detail_ids if the req qty is not
        --updated to 0.
        IF l_requested_qty <> 0 THEN
          wsh_util_core.get_cached_value(
            p_cache_tbl       => l_dd_ids_dd_ids_cache,
            p_cache_ext_tbl   => l_dd_ids_dd_ids_ext_cache,
            p_value           => v_lines_without_rr.delivery_detail_id,
            p_key             => v_lines_without_rr.delivery_detail_id,
            p_action          => 'PUT',
            x_return_status   => l_return_status);

               wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors);

        END IF;

        Update wsh_delivery_details
        set
        requested_quantity = l_requested_qty,
        requested_quantity_uom = decode(l_new_req_qty_uom,NULL,requested_quantity_uom,l_new_req_qty_uom), --HACMS
        cancelled_quantity = nvl(cancelled_quantity,0) + nvl(l_cancelled_qty,0), --HACMS
        released_status = l_released_status,
        last_update_date = SYSDATE,
        last_updated_by =  FND_GLOBAL.USER_ID,
        last_update_login =  FND_GLOBAL.LOGIN_ID
        WHERE
        delivery_detail_id = v_lines_without_rr.delivery_detail_id AND
        po_shipment_line_id = p_line_rec.po_shipment_line_id(i) AND
        source_header_id = p_line_rec.header_id(i) AND
        source_line_id = p_line_rec.line_id(i) ANd
        source_code = 'PO' AND
        ((p_line_rec.source_blanket_reference_id(i) IS NULL AND
          source_blanket_reference_id IS NULL) OR
         (p_line_rec.source_blanket_reference_id(i) IS NOT NULL AND
          source_blanket_reference_id = p_line_rec.source_blanket_reference_id(i))) AND
        released_status = 'X' AND
	last_update_date =  v_lines_without_rr.last_update_date;


        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Line Updated in wsh_delivery_details',sql%rowcount);
        END IF;

        IF SQL%ROWCOUNT <> 1 THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_CHANGED');
          wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --
        -- DBI Project
        -- Update of wsh_delivery_details where requested_quantity/released_status
        -- are changed, call DBI API after the update.
        -- This API will also check for DBI Installed or not
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',v_lines_without_rr.delivery_detail_id);
        END IF;
        l_detail_tab(1) := v_lines_without_rr.delivery_detail_id;
        WSH_INTEGRATION.DBI_Update_Detail_Log
          (p_delivery_detail_id_tab => l_detail_tab,
           p_dml_type               => 'UPDATE',
           x_return_status          => l_dbi_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
        END IF;
        IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          -- just pass this return status to caller API
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- End of Code for DBI Project
        --

        EXIT WHEN (l_remaining_qty = 0);

      END LOOP;

      IF l_remaining_qty <> 0 THEN
      -- if lines with null routing request is not available, then
      -- the qty change is applied to lines with routing request.
      --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'For l_remaining_qty <> 0');
        END IF;

        l_qty_to_change := l_remaining_qty;

      --Check if all the delivery details for the present line location id have
      --the same ship from. if not, set the ship_from_location_id to -1.
      --Also collect the list of such delivery details to p_dd_id_unassigned
      --which will be later used to unassgin the delivery details from the
      --delviery.
      --l_sf_differs ='1' => ship_from is different.

        OPEN c_ship_from_count(p_line_rec.po_shipment_line_id(i),
                  p_line_rec.header_id(i),p_line_rec.line_id(i));
        FETCH c_ship_from_count into l_sf_count;
        CLOSE c_ship_from_count;

        IF l_sf_count > 1 THEN
          l_sf_differs := '1';
        END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_sf_differs',l_sf_differs);
        END IF;
        -- The cursor c_lines_with_rr fetches delivery_details in the order of
	-- latest earliest_pickup_date.
        FOR v_lines_with_rr IN c_lines_with_rr(p_line_rec.po_shipment_line_id(i),p_line_rec.header_id(i),p_line_rec.line_id(i))
        LOOP--Start loop for processing lines with Routing Request

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Start loop for processing lines with Routing Request');
           WSH_DEBUG_SV.log(l_module_name,'l_qty_to_change',l_qty_to_change);
           WSH_DEBUG_SV.log(l_module_name,' v_lines_with_rr.qty', v_lines_with_rr.qty);
           WSH_DEBUG_SV.log(l_module_name,' v_lines_with_rr.delivery_detail_id', v_lines_with_rr.delivery_detail_id);
           WSH_DEBUG_SV.log(l_module_name,' v_lines_with_rr.last_update_date', v_lines_with_rr.last_update_date);
        END IF;

        --HACMS {
        l_requested_quantity:=v_lines_with_rr.qty;

        IF (v_lines_with_rr.inventory_item_id IS NULL and
             v_lines_with_rr.qty_uom <> p_line_rec.order_quantity_uom(i)) THEN

          l_new_req_qty_uom := p_line_rec.order_quantity_uom(i);

           WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            =>  p_line_rec.inventory_item_id(i),
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => p_line_rec.order_quantity_uom(i),
              p_quantity               => v_lines_with_rr.qty,
              p_qty_uom_code           => l_requested_quantity_uom,
              x_conv_qty               => l_requested_quantity,
              x_return_status          => l_return_status);

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              WSH_DEBUG_SV.log(l_module_name,'l_requested_quantity',l_requested_quantity);
            END IF;
        END IF;
        --HACMS }

        IF l_qty_to_change < l_requested_quantity then  --HACMS
	-- IF the qty to be changed is less that the requested quantity, then
	-- the open delivery detail is updated with the new qty.
           l_requested_qty := l_requested_quantity - l_qty_to_change; --HACMS
           l_cancelled_qty := l_qty_to_change;
           l_released_status := 'X';
           l_remaining_qty := 0;
        ELSIF l_qty_to_change = l_requested_quantity then
	-- If the qty to be changed is equal to the requested quantity, then the
	-- delviery detail gets updatd to 'D'(Cancelled).
           l_requested_qty := 0;
           l_cancelled_qty := l_qty_to_change;
           l_released_status := 'D';
           l_remaining_qty := 0;
        ELSE
	-- If the qty to be changed is greater than the requested quantity, then
	-- the delivery detail is updated to 'D'( Cancelled').
	-- The new qyt that needs to be updated is determined and this is
	-- updated once again on to the next available open delivery detail.
           temp_qty := l_qty_to_change - l_requested_quantity;
           l_requested_qty := 0;
           l_cancelled_qty := l_qty_to_change;
           l_released_status := 'D';
           l_qty_to_change := temp_qty;
           l_remaining_qty := temp_qty;
        END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_requested_qty',l_requested_qty);
           WSH_DEBUG_SV.log(l_module_name,'l_requested_qty2',l_requested_qty2);
           WSH_DEBUG_SV.log(l_module_name,'l_cancelled_qty',l_cancelled_qty);
           WSH_DEBUG_SV.log(l_module_name,'l_released_status',l_released_status);
           WSH_DEBUG_SV.log(l_module_name,'l_remaining_qty',l_remaining_qty);
           WSH_DEBUG_SV.log(l_module_name,'v_lines_with_rr.delivery_detail_id',v_lines_with_rr.delivery_detail_id);
        END IF;

        IF l_sf_differs = '1'  OR l_released_status = 'D' THEN
        --{
	   l_ship_from_location_id := -1;
           l_ignore_for_planning := 'Y';

   IF v_lines_with_rr.delivery_id IS NOT NULL THEN
   --{
   -- Collecting the delivery detail id for which ship from location ids are different
   -- to p_ddd_id_unassigned list which is used at the end of
   -- Reapproval action to unassign the details from the delivery.
     p_dd_id_unassigned(p_dd_id_unassigned.COUNT +1):= v_lines_with_rr.delivery_detail_id;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     -- Bug 3395410 : Setting the message that needs to be displayed while logging exception.

     FND_MESSAGE.SET_NAME('WSH','WSH_IB_DELIVERY_CHANGE');
     FND_MESSAGE.SET_TOKEN('DELIVERY',  v_lines_with_rr.delivery_id);
     l_msg := FND_MESSAGE.GET;

     Log_Exception(
               p_entity_id      => v_lines_with_rr.delivery_id,
               p_logging_entity_name    => 'DELIVERY',
               p_exception_name => 'WSH_IB_DELIVERY_CHANGE',
               p_location_id    => v_lines_with_rr.del_location,
        x_return_status  => l_return_status);

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
               p_return_status => x_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

    END IF;

           --}
         ELSE
           l_ship_from_location_id := v_lines_with_rr.ship_from_location_id;
           l_ignore_for_planning   := v_lines_with_rr.ignore_for_planning;
           l_routing_request_id := v_lines_with_rr.routing_req_id;
         END IF;
         --}

         --HACMS {
         IF l_sf_differs = '1' THEN
	    -- if delivery details have different ship from location and routing response is send against
	    -- these delivery details, then log exception against the delivery detail.

            IF (WSH_INBOUND_UTIL_PKG.Is_Routing_Response_Send( v_lines_with_rr.delivery_detail_id,l_req_res_id) ) THEN

              FND_MESSAGE.SET_NAME('WSH','WSH_IB_ST_LOC_CHANGE');
              FND_MESSAGE.SET_TOKEN('DETAIL', v_lines_with_rr.delivery_detail_id);
              FND_MESSAGE.SET_TOKEN('OLD_VALUE', v_lines_with_rr.ship_from_location_id);
              FND_MESSAGE.SET_TOKEN('NEW_VALUE', '-1');
              l_msg := FND_MESSAGE.GET;

	      IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
	      END IF;
              -- Anjana : Changed the v_lines_with_rr.ship_to_location_id to v_lines_with_rr.ship_from_location_id
	      -- in the log_exception.
              Log_Exception(
                 p_entity_id           => v_lines_with_rr.delivery_detail_id,
                 p_logging_entity_name => 'DETAIL',
                 p_exception_name      => 'WSH_IB_DETAIL_CHANGE',
                 p_location_id    =>   v_lines_with_rr.ship_from_location_id,
                 p_message        =>  l_msg,
                 x_return_status  =>  l_return_status);

              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Log_Exception l_return_status',l_return_status);
              END IF;

              wsh_util_core.api_post_call(
               p_return_status => x_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);
            END IF;
         END IF;
         --HACMS }



        IF l_requested_qty <> 0 THEN
         wsh_util_core.get_cached_value(
           p_cache_tbl       => l_dd_ids_dd_ids_cache,
           p_cache_ext_tbl   => l_dd_ids_dd_ids_ext_cache,
           p_value           => v_lines_with_rr.delivery_detail_id,
           p_key             => v_lines_with_rr.delivery_detail_id,
           p_action          => 'PUT',
           x_return_status   => l_return_status);

               wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors);

        END IF;

        --HACMS {
        l_pick_qty:=null;
        l_conv_pick_qty:=null;

        IF (v_lines_with_rr.inventory_item_id IS NULL) THEN
	-- for one time items

           WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            => NULL,
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => p_line_rec.requested_quantity_uom(i),
              p_quantity               => v_lines_with_rr.pick_qty,
              p_qty_uom_code           => v_lines_with_rr.qty_uom,
              x_conv_qty               => l_conv_pick_qty,
              x_return_status          => l_return_status);

            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'convert_quantity l_return_status',l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'l_conv_pick_qty',l_conv_pick_qty);
            END IF;
            --
            wsh_util_core.api_post_call(
               p_return_status => x_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

           IF (l_conv_pick_qty < l_requested_qty) then
             l_qty_to_split := l_requested_qty - l_conv_pick_qty;
             l_pick_qty  := l_requested_qty;
           ELSE
             l_pick_qty  := l_conv_pick_qty;
           END IF;

         END IF;
         --HACMS }

         Update wsh_delivery_details
         set
         requested_quantity = l_requested_qty,
         --HACMS {
         requested_quantity_uom = decode(l_new_req_qty_uom,NULL,requested_quantity_uom,l_new_req_qty_uom),
         cancelled_quantity = nvl(cancelled_quantity,0)+nvl(l_cancelled_qty,0),
         picked_quantity = decode(l_pick_qty,NULL,picked_quantity,l_pick_qty),
         --HACMS }
         released_status = l_released_status,
         ignore_for_planning = l_ignore_for_planning,
         ship_from_location_id = l_ship_from_location_id,
         routing_req_id = l_routing_request_id,
         last_update_date = SYSDATE,
         last_updated_by =  FND_GLOBAL.USER_ID,
         last_update_login =  FND_GLOBAL.LOGIN_ID
         WHERE
         delivery_detail_id = v_lines_with_rr.delivery_detail_id AND
         po_shipment_line_id = p_line_rec.po_shipment_line_id(i) AND
         source_header_id = p_line_rec.header_id(i) AND
         source_line_id = p_line_rec.line_id(i) AND
         source_code = 'PO' AND
         ((p_line_rec.source_blanket_reference_id(i) IS NULL AND
           source_blanket_reference_id IS NULL) OR
         (p_line_rec.source_blanket_reference_id(i) IS NOT NULL AND
          source_blanket_reference_id = p_line_rec.source_blanket_reference_id(i))) AND
          released_status = 'X' AND
	  last_update_date =  v_lines_with_rr.last_update_date;

         IF SQL%ROWCOUNT <> 1 THEN
           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT',SQL%ROWCOUNT);
           END IF;
           FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_CHANGED');
           wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         --
         -- DBI Project
         -- Update of wsh_delivery_details where requested_quantity/released_status
         -- are changed, call DBI API after the update.
         -- This API will also check for DBI Installed or not
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',v_lines_with_rr.delivery_detail_id);
         END IF;
          l_detail_tab(1) := v_lines_with_rr.delivery_detail_id;
          WSH_INTEGRATION.DBI_Update_Detail_Log
            (p_delivery_detail_id_tab => l_detail_tab,
             p_dml_type               => 'UPDATE',
             x_return_status          => l_dbi_rs);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
          END IF;
          IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            -- just pass this return status to caller API
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- End of Code for DBI Project
          --

        --HACMS {

	-- Bug 3395410 : Exception needs to be logged if the qty is decreased and the associated delivery is
	-- Contents Firm.Checking for the planned_flag for the same.

        IF (WSH_INBOUND_UTIL_PKG.Is_Routing_Response_Send( v_lines_with_rr.delivery_detail_id,l_req_res_id)) THEN
          l_routing_response_send := 'Y';
        ELSE
          l_routing_response_send := 'N';
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_routing_response_send:',l_routing_response_send);
        END IF;

        IF ((l_routing_response_send = 'Y')
	OR (v_lines_with_rr.planned_flag in ('Y','F'))) THEN
        -- If routing response is send  then log excpetion against the delivery detail and delivery.
        -- If delivery is firm,then log excpetion against the delivery.

      	   FND_MESSAGE.SET_NAME('WSH','WSH_IB_REQ_QTY_CHANGE');
           FND_MESSAGE.SET_TOKEN('DETAIL',  v_lines_with_rr.delivery_detail_id);
           FND_MESSAGE.SET_TOKEN('OLD_VALUE', v_lines_with_rr.qty);
           FND_MESSAGE.SET_TOKEN('NEW_VALUE', l_requested_qty);
           l_msg := FND_MESSAGE.GET;

	   IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;

	   IF (l_routing_response_send = 'Y') THEN
	      -- Routing response is send.

              Log_Exception(
                 p_entity_id           => v_lines_with_rr.delivery_detail_id,
                 p_logging_entity_name => 'DETAIL',
                 p_exception_name      => 'WSH_IB_DETAIL_CHANGE',
                 p_location_id         =>  v_lines_with_rr.ship_to_location_id,
                 p_message             =>  l_msg,
                 x_return_status  =>  l_return_status);

	      IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Log_Exception l_return_status',l_return_status);
              END IF;

	      wsh_util_core.api_post_call(
                p_return_status => x_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors);

           ELSIF v_lines_with_rr.planned_flag in ('Y','F') THEN
	       -- Delivery is Contents Firm.
	       Log_Exception(
                 p_entity_id           => v_lines_with_rr.delivery_id,
                 p_logging_entity_name => 'DELIVERY',
                 p_exception_name      => 'WSH_IB_DELIVERY_CHANGE',
                 p_location_id         =>  v_lines_with_rr.del_location,
                 p_message             =>  l_msg,
                 x_return_status  =>  l_return_status);

	      IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Log_Exception l_return_status',l_return_status);
              END IF;

	      wsh_util_core.api_post_call(
                p_return_status => x_return_status,
                x_num_warnings  => l_num_warnings,
                x_num_errors    => l_num_errors);

	   END IF;



           FND_MESSAGE.SET_NAME('WSH','WSH_IB_DEL_ATT_CHANGE');
           FND_MESSAGE.SET_TOKEN('DELIVERY',v_lines_with_rr.delivery_id);
           l_msg := FND_MESSAGE.GET;

	   IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Log_Exception',WSH_DEBUG_SV.C_PROC_LEVEL);
	   END IF;

	   Log_Exception(
                 p_entity_id           => v_lines_with_rr.delivery_id,
                 p_logging_entity_name => 'DELIVERY',
                 p_exception_name      => 'WSH_IB_DEL_ATT_CHANGE',
                 p_location_id    =>  v_lines_with_rr.del_location,
                 p_message        =>  l_msg,
                 x_return_status  =>  l_return_status);

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Log_Exception l_return_status',l_return_status);
           END IF;
            wsh_util_core.api_post_call(
               p_return_status => x_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

        END IF;

         --HACMS }

  EXIT WHEN (l_remaining_qty = 0);


         END LOOP;--end loop for processing lines with Routing Request

       END IF; -- l_requested_qty
       --}


     ELSE--For increment quantity case.
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'For increment quantity case l_qty_to_change',l_qty_to_change);
        END IF;
        IF l_qty_to_change > 0 THEN

        --{

	OPEN c_dd_count_with_null_rr(p_line_rec.po_shipment_line_id(i),
                            p_line_rec.header_id(i),p_line_rec.line_id(i));
	FETCH c_dd_count_with_null_rr into l_record_with_null_rr;
	CLOSE c_dd_count_with_null_rr;

	IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'l_record_with_null_rr', l_record_with_null_rr);
        END IF;

        IF l_record_with_null_rr >= 1 THEN
	-- Increase in Qty is applied only to open delivery details with null
	-- routing request id.
	-- If no such line is present, then a new record  is inserted into wdd
	-- for the additional qty.
        --{

          OPEN  c_inc_qty(p_line_rec.po_shipment_line_id(i),
                p_line_rec.header_id(i),p_line_rec.line_id(i));
	  FETCH c_inc_qty INTO l_delivery_detail_id, l_requested_qty,
                l_requested_quantity_uom, l_inventory_item_id, l_last_update_date; --HACMS
	  CLOSE c_inc_qty;

   wsh_util_core.get_cached_value(
       p_cache_tbl       => l_dd_ids_dd_ids_cache,
       p_cache_ext_tbl   => l_dd_ids_dd_ids_ext_cache,
       p_value           => l_delivery_detail_id,
       p_key             => l_delivery_detail_id,
       p_action          => 'PUT',
       x_return_status   => l_return_status);

               wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors);


          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_delivery_detail_id',l_delivery_detail_id);
            WSH_DEBUG_SV.log(l_module_name,'l_requested_qty',l_requested_qty);
            WSH_DEBUG_SV.log(l_module_name,'l_requested_qty2',l_requested_qty2);
            WSH_DEBUG_SV.log(l_module_name,'l_last_update_date',l_last_update_date);
          END IF;

          --HACMS {
          IF (l_inventory_item_id IS NULL and
             l_requested_quantity_uom<> p_line_rec.order_quantity_uom(i)) THEN

             l_new_req_qty_uom := p_line_rec.order_quantity_uom(i);

             WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            =>  p_line_rec.inventory_item_id(i),
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => p_line_rec.order_quantity_uom(i),
              p_quantity               => l_requested_qty,
              p_qty_uom_code           => l_requested_quantity_uom,
              x_conv_qty               => l_tmp_requested_quantity,
              x_return_status          => l_return_status);

              l_requested_qty:=l_tmp_requested_quantity;

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                WSH_DEBUG_SV.log(l_module_name,'After conversion l_requested_qty',l_requested_qty);
              END IF;
          END IF;
          --HACMS }

          UPDATE WSH_DELIVERY_DETAILS
          SET
          requested_quantity = l_requested_qty + l_qty_to_change,
          requested_quantity_uom = decode(l_new_req_qty_uom,NULL,requested_quantity_uom,l_new_req_qty_uom), --HACMS
          last_update_date = SYSDATE,
          last_updated_by =  FND_GLOBAL.USER_ID,
          last_update_login =  FND_GLOBAL.LOGIN_ID
          WHERE delivery_detail_id = l_delivery_detail_id AND
          po_shipment_line_id = p_line_rec.po_shipment_line_id(i) AND
          source_header_id = p_line_rec.header_id(i) AND
          source_line_id = p_line_rec.line_id(i) ANd
          source_code = 'PO' AND
          ((p_line_rec.source_blanket_reference_id(i) IS NULL AND
            source_blanket_reference_id IS NULL) OR
          (p_line_rec.source_blanket_reference_id(i) IS NOT NULL AND
           source_blanket_reference_id = p_line_rec.source_blanket_reference_id(i))) AND
          released_status = 'X' AND
	  last_update_date =  l_last_update_date;

	  IF SQL%ROWCOUNT <> 1 THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT',SQL%ROWCOUNT);
            END IF;
            FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_CHANGED');
            wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_update_flag := TRUE;

          --
          -- DBI Project
          -- Update of wsh_delivery_details where requested_quantity/released_status
          -- are changed, call DBI API after the update.
          -- This API will also check for DBI Installed or not
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',l_delivery_detail_id);
          END IF;
          l_detail_tab(1) := l_delivery_detail_id;
          WSH_INTEGRATION.DBI_Update_Detail_Log
            (p_delivery_detail_id_tab => l_detail_tab,
             p_dml_type               => 'UPDATE',
             x_return_status          => l_dbi_rs);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
          END IF;
          IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            -- just pass this return status to caller API
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- End of Code for DBI Project
          --

        ELSIF l_record_with_null_rr  = 0 THEN
	  -- insert a new record for additional qty.
          IF p_action_prms.action_code = 'REAPPROVE_PO' THEN
		l_caller := 'WSH-PO-INT';
	  END IF;
	  p_line_rec.requested_quantity(i) := l_qty_to_change;
          p_line_rec.requested_quantity_uom2(i) := p_line_rec.ordered_quantity_uom2(i);
	  p_line_rec.tracking_number(i) := null; --Bugfix 3711663

	  IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_qty_to_change', l_qty_to_change);
          END IF;

	  IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit populate_additional_line_info',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

	  populate_additional_line_info(
	    p_line_rec                  => p_line_rec,
            p_index                     => i,
	    p_caller           => l_caller,
	    p_additional_line_info_rec  => l_additional_line_info_rec ,
	    x_return_status             => l_return_status);

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_qty_to_change', l_qty_to_change);
          END IF;

          -- This is very important.  We should use a local action prms
          -- otherwise it will overwrite the existing value of action in
          -- in p_action_prms
          --p_action_prms.action_code := 'CREATE';
          l_action_prms.action_code := 'CREATE';
	  l_action_prms.org_id := p_line_rec.org_id(i);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_BULK_PROCESS_PVT.BULK_INSERT_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   WSH_BULK_PROCESS_PVT.bulk_insert_details (
             P_line_rec       => P_line_rec,
             p_index          => i,
             p_action_prms    => l_action_prms,
             p_additional_line_info_rec => l_additional_line_info_rec,
             X_return_status  => l_return_status
             );

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors);

          wsh_util_core.get_cached_value(
            p_cache_tbl       => l_dd_ids_dd_ids_cache,
            p_cache_ext_tbl   => l_dd_ids_dd_ids_ext_cache,
            p_value           => p_line_rec.delivery_detail_id(i),
            p_key             => p_line_rec.delivery_detail_id(i),
            p_action          => 'PUT',
            x_return_status   => l_return_status);

               wsh_util_core.api_post_call(
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors);


         END IF;
         --}
       END IF;
       --}

      END IF;--end if for decrement/increment cases.
      --}

      IF l_insert_new_dd = 'Y' THEN
      --{
        -- No delivery detail is present for the corresponding po shipment line id.
	-- Need to insert a new record for the line location id.

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'p_line_rec.requested_quantity(i)', p_line_rec.requested_quantity(i));
          --WSH_DEBUG_SV.log(l_module_name,'p_line_rec.consolidate_quantity(i)', p_line_rec.consolidate_quantity(i));
        END IF;
	IF p_action_prms.action_code = 'REAPPROVE_PO' THEN
	      l_caller := 'WSH-PO-INT';
        END IF;

	IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit populate_additional_line_info',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
	-- populate p_additional_line_info_rec by calling populate_additional_line_info() API.
	populate_additional_line_info(
	   p_line_rec                  => p_line_rec,
           p_index                     => i,
	   p_caller           => l_caller,
	   p_additional_line_info_rec  => l_additional_line_info_rec ,
	   x_return_status             => l_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status => l_return_status,
          x_num_warnings  => l_num_warnings,
          x_num_errors    => l_num_errors);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_BULK_PROCESS_PVT.BULK_INSERT_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        l_action_prms := p_action_prms;
        l_action_prms.org_id := p_line_rec.org_id(i);
              --
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,' l_action_prms.org_id', l_action_prms.org_id);
        END IF;
              --
	 -- Call WSH_BULK_PROCESS_PVT.bulk_insert_details() to insert the record into wsh_delivery_details.
        WSH_BULK_PROCESS_PVT.bulk_insert_details (
          P_line_rec       => P_line_rec,
          p_index          => i,
          p_action_prms    => l_action_prms,
          p_additional_line_info_rec => l_additional_line_info_rec,
          X_return_status  => l_return_status
                     );

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status => l_return_status,
          x_num_warnings  => l_num_warnings,
          x_num_errors    => l_num_errors);

      END IF;
      --}

   --HACMS {
   --Take care of UOM for unchange UOM lines for one time items
   IF (l_inventory_item_id IS NULL) THEN
      FOR v_lines IN c_lines_all(p_line_rec.po_shipment_line_id(i),p_line_rec.header_id(i),p_line_rec.line_id(i) )
      LOOP

         IF ( v_lines.qty_uom <> p_line_rec.requested_quantity_uom(i)) THEN --{
           WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            => NULL,
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => p_line_rec.requested_quantity_uom(i),
              p_quantity               => v_lines.qty,
              p_qty_uom_code           => v_lines.qty_uom,
              x_conv_qty               => l_qty_to_change,
              x_return_status          => l_return_status);

           IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'convert_quantity Req Qty l_return_status,l_qty_to_change',l_return_status||','||l_qty_to_change);
           END IF;

           wsh_util_core.api_post_call(
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors);


           IF (v_lines.pick_qty IS NOT NULL or v_lines.pick_qty <> 0) THEN
             WSH_INBOUND_UTIL_PKG.convert_quantity(
              p_inv_item_id            => NULL,
              p_organization_id        => p_line_rec.organization_id(i),
              p_primary_uom_code       => p_line_rec.requested_quantity_uom(i),
              p_quantity               => v_lines.pick_qty,
              p_qty_uom_code           => v_lines.qty_uom,
              x_conv_qty               => l_pick_qty,
              x_return_status          => l_return_status);

              IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'convert_quantity Pick Qty l_return_status',l_return_status);
                  WSH_DEBUG_SV.log(l_module_name,'l_pick_qty',l_pick_qty);
              END IF;
              --
              wsh_util_core.api_post_call(
               p_return_status => x_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

            END IF;

            Update wsh_delivery_details
            set requested_quantity = l_qty_to_change,
                requested_quantity_uom = p_line_rec.requested_quantity_uom(i),
                picked_quantity = decode(l_pick_qty,null,picked_quantity,l_pick_qty) ,
                last_update_date = SYSDATE,
                last_updated_by =  FND_GLOBAL.USER_ID,
                last_update_login =  FND_GLOBAL.LOGIN_ID
            WHERE delivery_detail_id = v_lines.delivery_detail_id AND
            po_shipment_line_id = p_line_rec.po_shipment_line_id(i) AND
            source_header_id = p_line_rec.header_id(i) AND
            source_line_id = p_line_rec.line_id(i) ANd
            source_code = 'PO' AND
            ((p_line_rec.source_blanket_reference_id(i) IS NULL AND source_blanket_reference_id IS NULL) OR
            (p_line_rec.source_blanket_reference_id(i) IS NOT NULL AND source_blanket_reference_id = p_line_rec.source_blanket_reference_id(i))) AND
            released_status = 'X' AND
	    last_update_date =  v_lines.last_update_date;

	   IF SQL%ROWCOUNT <> 1 THEN
             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT',SQL%ROWCOUNT);
             END IF;
             FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_CHANGED');
             wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
             RAISE FND_API.G_EXC_ERROR;
           END IF;
         --
         -- DBI Project
         -- Update of wsh_delivery_details where requested_quantity/released_status
         -- are changed, call DBI API after the update.
         -- This API will also check for DBI Installed or not
         IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail id-',v_lines.delivery_detail_id);
         END IF;
          l_detail_tab(1) := v_lines.delivery_detail_id;
          WSH_INTEGRATION.DBI_Update_Detail_Log
            (p_delivery_detail_id_tab => l_detail_tab,
             p_dml_type               => 'UPDATE',
             x_return_status          => l_dbi_rs);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
          END IF;
          IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            -- just pass this return status to caller API
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- End of Code for DBI Project
          --


         END IF; --}

      END LOOP;
   END IF;
   --HACMS }


   <<next_p_line_rec>>
    null;
END LOOP;--For p_line_rec


--Updating src_quantity on all lines whether 'OPEN'/'CLOSED'/'SHIPPED'.
-- in case of increment, we still need to upd. sec. qty.
--
IF p_action_prms.action_code = 'REAPPROVE_PO'
OR l_update_flag --- increment from asn/receipt
THEN
  FORALL i in 1..p_line_rec.po_shipment_line_id.COUNT

    Update wsh_delivery_details
    Set src_requested_quantity = nvl(p_line_rec.ordered_quantity(i),src_requested_quantity),
        src_requested_quantity_uom = nvl(p_line_rec.order_quantity_uom(i),src_requested_quantity_uom),
        --HACMS
-- HW OPMCONV - No need to use OPM precision. Use current INV which is 5
        requested_quantity2 = decode(released_status,'X',ROUND(l_ratio_tbl(i) * requested_quantity ,WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV),requested_quantity2),
        cancelled_quantity2 = decode(released_status,'X',ROUND(l_ratio_tbl(i) * cancelled_quantity ,WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV),cancelled_quantity2),
        picked_quantity2 = decode(released_status,'X',ROUND(l_ratio_tbl(i) * picked_quantity ,WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV),picked_quantity2),
        src_requested_quantity2 = nvl(p_line_rec.ordered_quantity2(i),src_requested_quantity2),
        src_requested_quantity_uom2 = nvl(p_line_rec.ordered_quantity_uom2(i),src_requested_quantity_uom2),
        --HACMS
	source_line_number = p_line_rec.source_line_number(i),
	po_shipment_line_number = p_line_rec.po_shipment_line_number(i),
        last_update_date = SYSDATE,
        last_updated_by =  FND_GLOBAL.USER_ID,
        last_update_login =  FND_GLOBAL.LOGIN_ID
        where source_code = 'PO'
        AND   po_shipment_line_id = p_line_rec.po_shipment_line_id(i)
        AND   source_header_id = p_line_rec.header_id(i)
        AND   source_line_id = p_line_rec.line_id(i)
        AND    source_code = 'PO' AND
        ((p_line_rec.source_blanket_reference_id(i) IS NULL AND source_blanket_reference_id IS NULL) OR
        (p_line_rec.source_blanket_reference_id(i) IS NOT NULL AND source_blanket_reference_id = p_line_rec.source_blanket_reference_id(i))) ;


        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
END IF;

--copying back to the original table after deleting the contents from it
p_wt_vol_dd_id.delete;
l_ind := l_dd_ids_dd_ids_cache.FIRST;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'first-l_ind' ,l_ind);
  END IF;

WHILE l_ind IS NOT NULL
LOOP
  p_wt_vol_dd_id(p_wt_vol_dd_id.COUNT + 1) := l_dd_ids_dd_ids_cache(l_ind).value;
  l_ind := l_dd_ids_dd_ids_cache.NEXT(l_ind);
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'  p_wt_vol_dd_id.count' , p_wt_vol_dd_id.count);
    WSH_DEBUG_SV.log(l_module_name,' p_wt_vol_dd_id( p_wt_vol_dd_id.count)' ,p_wt_vol_dd_id( p_wt_vol_dd_id.count));
    WSH_DEBUG_SV.log(l_module_name,'l_ind' ,l_ind);
  END IF;
END LOOP;
l_ind := l_dd_ids_dd_ids_ext_cache.FIRST;
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'first-ext-l_ind' ,l_ind);
  END IF;
WHILE l_ind IS NOT NULL
LOOP
  p_wt_vol_dd_id(p_wt_vol_dd_id.COUNT + 1) := l_dd_ids_dd_ids_ext_cache(l_ind).value;
  l_ind := l_dd_ids_dd_ids_ext_cache.NEXT(l_ind);
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'  p_wt_vol_dd_id.count' , p_wt_vol_dd_id.count);
    WSH_DEBUG_SV.log(l_module_name,' p_wt_vol_dd_id( p_wt_vol_dd_id.count)' ,p_wt_vol_dd_id( p_wt_vol_dd_id.count));
    WSH_DEBUG_SV.log(l_module_name,'l_ind' ,l_ind);
  END IF;
END LOOP;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN e_wdd_locked THEN
    ROLLBACK TO Update_quantity_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_LOCKED');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'e_Wdd_locked exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_Wdd_locked');
END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_quantity_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  -- Added for DBI Project to handle Unexpected error
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_quantity_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
  -- End of Code Added for DBI Project to handle Unexpected error
  WHEN OTHERS THEN
    ROLLBACK TO Update_quantity_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_CMG_PVT.Update_quantity',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_Quantity;

--Developed by Arun Raj
--======================================================================
-- PROCEDURE : cancel_close_po
-- HISTORY   : Created the API.
--======================================================================
-- Start of comments
-- API name : cancel_close_po
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API updates the status of lines to closed/cancelled depending
--            on the action code and caller passed through the i/p parameter
--	      p_action_prms.
-- Parameters :
-- IN:
--   p_line_rec       IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL
--      This record structure contains information about the lines to be deleted.
--      The information may include header id,line id ,line location id etc.
--   p_action_prms    IN  OUT NOCOPY
--                               WSH_BULK_TYPES_GRP.action_parameters_rectype
--      The record which specifies the caller, actio to be performed(Close/Cancel)
-- IN OUT:
-- OUT:
--   x_return_status  OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE cancel_close_po(
   p_line_rec       IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL,
   p_action_prms    IN  OUT NOCOPY
                               WSH_BULK_TYPES_GRP.action_parameters_rectype,
   x_return_status  OUT NOCOPY VARCHAR2) IS

-- Cursor to fetch the open delivery detail ids that needs to be either cancelled of closed
-- based on the action code that is being passed to the API.

cursor c_dd_ids(p_header_id NUMBER,p_line_id NUMBER,p_line_location_id NUMBER,p_release_id NUMBER) IS
SELECT
wdd.delivery_detail_id,
wdd.requested_quantity,
wdd.requested_quantity2,
wda.delivery_id,
wdd.last_update_date
FROM
wsh_delivery_details     wdd,
wsh_delivery_assignments_v wda
WHERE
wdd.source_header_id    = NVL(p_header_id,wdd.source_header_id)   AND
wdd.delivery_detail_id  = wda.delivery_detail_id   AND
wdd.source_line_id      = p_line_id   AND
wdd.po_shipment_line_id = p_line_location_id  AND
(  (p_release_id IS NULL AND wdd.source_blanket_reference_id IS NULL)
    OR
   (p_release_id IS NOT NULL AND wdd.source_blanket_reference_id = p_release_id )
) AND
wdd.source_code         = 'PO'   AND
wdd.released_status     = 'X'
for update of wdd.released_status NOWAIT;

l_chk_pend        NUMBER := 0;
l_return_status  VARCHAR2(1);
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_index          NUMBER := 0;
dd_ids_tab   WSH_UTIL_CORE.ID_TAB_TYPE;
dd_ids_tab_for_unassign WSH_UTIL_CORE.ID_TAB_TYPE;
req_qty_tab      WSH_UTIL_CORE.ID_TAB_TYPE;
req_qty2_tab      WSH_UTIL_CORE.ID_TAB_TYPE;
last_update_date_tab WSH_UTIL_CORE.date_tab_type;

l_api_version    NUMBER := 1.0;
l_init_msg_list  VARCHAR2(30) := NULL;
l_msg_count    NUMBER;
l_msg_data   VARCHAR2(3000);
l_commit   VARCHAR2(1);
l_validation_level NUMBER;
l_delivery_id NUMBER;
l_action_prms wsh_glbl_var_strct_grp.dd_action_parameters_rec_type;

l_detail_tab    WSH_UTIL_CORE.id_tab_type; -- DBI Project
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API

e_wdd_locked EXCEPTION ;
PRAGMA  EXCEPTION_INIT(e_wdd_locked,-54);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_CLOSE_PO';
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
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;
--
SAVEPOINT cancel_close_PO_PVT;
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;

l_index := p_line_rec.line_id.FIRST;
IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'action code is :',p_action_prms.action_code);
END IF;


WHILE l_index IS NOT NULL
LOOP
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.CHECK_PENDING_TXNS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --

  --Call to check whether the line has any pending transactions
  --against it.
  --If l_chk_pend = 0,there are no pending(unmatched)transactions agaisnt the line.
  --IF l_chk_pend = 1, there are pending(unmatched) transactions against the line.

  l_chk_pend:= WSH_PO_CMG_PVT.check_pending_txns(
  p_line_rec.header_id(l_index),
  p_line_rec.line_id(l_index),
  p_line_rec.po_shipment_line_id(l_index),
  p_line_rec.source_blanket_reference_id(l_index));

  IF l_chk_pend = 0 THEN
  -- No pending transactions
  -- Collect the list of delivery detail ids that needs to be updated into dd_ids_tab array.
  -- Also collect the list of delivery details ids for which delivery id is not null into
  -- dd_ids_tab_for_unassign array which is later used for 'UNASSIGN' action.(by calling
  -- unassign_multiple_details grp API.

    FOR v_dd_ids IN c_dd_ids(p_line_rec.header_id(l_index),
                        p_line_rec.line_id(l_index),
                        p_line_rec.po_shipment_line_id(l_index),
                        p_line_rec.source_blanket_reference_id(l_index))
    LOOP
      dd_ids_tab(dd_ids_tab.COUNT + 1) := v_dd_ids.delivery_detail_id;
      req_qty_tab(req_qty_tab.COUNT+1) := v_dd_ids.requested_quantity;
      req_qty2_tab(req_qty2_tab.COUNT+1) := v_dd_ids.requested_quantity2;
      last_update_date_tab(last_update_date_tab.COUNT+1) := v_dd_ids.last_update_date;

      IF v_dd_ids.delivery_id IS NOT NULL THEN
        dd_ids_tab_for_unassign(dd_ids_tab_for_unassign.COUNT + 1) := v_dd_ids.delivery_detail_id;
      END IF;
    END LOOP;
  END IF;

  l_index := p_line_rec.line_id.NEXT(l_index);
END LOOP;

IF dd_ids_tab_for_unassign.COUNT > 0 THEN
--
-- Debug Statements
--
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit  WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  l_action_prms.caller := wsh_util_core.C_IB_PO_PREFIX;

  WSH_DELIVERY_DETAILS_ACTIONS.unassign_multiple_details(
                p_rec_of_detail_ids  =>  dd_ids_tab_for_unassign,
                p_from_delivery      => 'Y',
                p_from_container     => 'N',
                x_return_status      =>  l_return_status,
                p_validate_flag      =>  'N',
                p_action_prms        =>  l_action_prms);

  wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);
END IF;



IF dd_ids_tab.COUNT > 0 THEN
  -- update the delivery details to the appropriate status based on the
  -- action code.
  IF p_action_prms.action_code = 'CANCEL_PO' THEN
  --update the status of the selected lines to 'D' (Cancel).
    FORALL i IN dd_ids_tab.FIRST..dd_ids_tab.LAST
      UPDATE
      wsh_delivery_details
      SET
      requested_quantity = 0,
      requested_quantity2 = 0,
      cancelled_quantity = req_qty_tab(i),
      cancelled_quantity2 = req_qty2_tab(i),
      released_status  = 'D',
      last_update_date = SYSDATE,
      last_updated_by =  FND_GLOBAL.USER_ID,
      last_update_login =  FND_GLOBAL.LOGIN_ID
      WHERE
      delivery_detail_id = dd_ids_tab(i) AND
      released_status = 'X'
      RETURNING delivery_detail_id BULK COLLECT INTO l_detail_tab; -- Added for DBI Project

  ELSIF p_action_prms.action_code = 'CLOSE_PO' OR
  --update the status of the selected lines to 'L' (Close).
        p_action_prms.action_code = 'FINAL_CLOSE' OR
        p_action_prms.action_code = 'CLOSE_PO_FOR_RECEIVING' THEN
    FORALL i IN dd_ids_tab.FIRST..dd_ids_tab.LAST
      UPDATE wsh_delivery_details
      SET released_status = 'L',
        last_update_date = SYSDATE,
        last_updated_by =  FND_GLOBAL.USER_ID,
        last_update_login =  FND_GLOBAL.LOGIN_ID
      WHERE delivery_detail_id = dd_ids_tab(i) AND
      released_status = 'X'
      RETURNING delivery_detail_id BULK COLLECT INTO l_detail_tab; -- Added for DBI Project

  END IF;
  --
  -- Above 2 update conditions would populate the table of ids for DBI
  -- DBI Project
  -- Update of wsh_delivery_details where requested_quantity/released_status
  -- are changed, call DBI API after the update.
  -- DBI API will check if DBI is installed
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_detail_tab.count);
  END IF;
  WSH_INTEGRATION.DBI_Update_Detail_Log
    (p_delivery_detail_id_tab => l_detail_tab,
     p_dml_type               => 'UPDATE',
     x_return_status          => l_dbi_rs);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
  END IF;
  -- Only Handle Unexpected error
  IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    x_return_status := l_dbi_rs;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;
  -- End of Code for DBI Project
  --

END IF;

-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN e_wdd_locked THEN
    ROLLBACK TO cancel_close_PO_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_LOCKED');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'e_Wdd_locked exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:e_Wdd_locked');
END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO cancel_close_PO_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN OTHERS THEN
    ROLLBACK TO cancel_close_PO_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_PO_CMG_PVT.CANCEL_CLOSE_PO',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END cancel_close_po;

--========================================================================
-- PROCEDURE : reopen_po
-- HISTORY   : Created the API.
--========================================================================

-- Start of comments
-- API name : REOPEN_PO
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API, changes the status of all the shipment line IDs
--		it receives, from Closed status (L) to Open status 'X'.
-- Parameters :
-- IN:
--	p_line_rec   IN  OE_WSH_BULK_GRP.line_rec_type
--        contains the information of the lines to be updated.
-- IN OUT:
--
-- OUT:
--	x_return_status  OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE reopen_po(
p_line_rec   IN  OE_WSH_BULK_GRP.line_rec_type,
x_return_status  OUT NOCOPY VARCHAR2) IS


l_num_warnings  NUMBER;
l_num_errors    NUMBER;

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                      VARCHAR2(1); -- Return Status from DBI API
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'REOPEN_PO';
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
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  SAVEPOINT REOPEN_PO_PVT;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FORALL i IN p_line_rec.header_id.FIRST..p_line_rec.header_id.LAST
   UPDATE wsh_delivery_details
      SET released_status = 'X'
  WHERE
  released_status = 'L' AND
  received_quantity IS  NULL AND
  source_code       = 'PO' AND
  source_header_id  = NVL(p_line_rec.header_id(i),source_header_id) AND
  source_line_id    = p_line_rec.line_id(i) AND
  po_shipment_line_id = p_line_rec.po_shipment_line_id(i)  AND
  ((p_line_rec.source_blanket_reference_id(i) IS NULL AND source_blanket_reference_id IS NULL)
    OR
   (p_line_rec.source_blanket_reference_id(i) IS NOT NULL AND source_blanket_reference_id = p_line_rec.source_blanket_reference_id(i) )
  )
  RETURNING delivery_detail_id BULK COLLECT INTO l_detail_tab; -- Added for DBI Project

  --
  -- DBI Project
  -- Update of wsh_delivery_details where requested_quantity/released_status
  -- are changed, call DBI API after the update.
  -- DBI API will check if DBI is installed
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_detail_tab.count);
  END IF;
  WSH_INTEGRATION.DBI_Update_Detail_Log
    (p_delivery_detail_id_tab => l_detail_tab,
     p_dml_type               => 'UPDATE',
     x_return_status          => l_dbi_rs);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
  END IF;
  -- Only Handle Unexpected error
  IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
    x_return_status := l_dbi_rs;
    --
    ROLLBACK TO REOPEN_PO_PVT;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN; -- just pass this return status back to caller API
  END IF;
  -- End of Code for DBI Project
  --
  IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO REOPEN_PO_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_PO_CMG_PVT.Reopen_po',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Reopen_po;

--========================================================================
-- PROCEDURE : Log_Exception
-- HISTORY   : Created the API.
--========================================================================

-- Start of comments
-- API name : Log_Exception
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API is used to log exception against delivery or
--		trip stop.It will check if already any exception is logged
--		against the delivery or the trip and if not, then it will
--		log the exception.
-- Parameters :
-- IN:
--		p_entity_id           IN NUMBER
--		p_logging_entity_name IN VARCHAR2
--		p_exception_name      IN VARCHAR2
--		p_location_id         IN NUMBER   DEFAULT NULL
--		p_message             IN VARCHAR2 DEFAULT NULL
-- IN OUT:
--
-- OUT:
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE Log_Exception(
p_entity_id           IN NUMBER,
p_logging_entity_name IN VARCHAR2,
p_exception_name      IN VARCHAR2,
p_location_id         IN NUMBER   DEFAULT NULL,
p_message             IN VARCHAR2 DEFAULT NULL,
x_return_status       OUT NOCOPY VARCHAR2) IS

l_exception_exists         VARCHAR2(1) := 'N';
l_return_status            VARCHAR2(30);
l_exception_msg_count      NUMBER;
l_dummy_exception_id       NUMBER;
l_exception_msg_data       VARCHAR2(2000);
l_init_msg_list            VARCHAR2(100):= FND_API.G_FALSE;
l_exceptions_tab           WSH_EXCEPTIONS_PUB.XC_TAB_TYPE;
l_msg                      VARCHAR2(2000):= NULL;
l_exception_error_message  VARCHAR2(2000) := NULL;
l_logged_at_location_id    NUMBER := FND_API.G_MISS_NUM;
l_exception_location_id    NUMBER := FND_API.G_MISS_NUM;
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_EXCEPTION';
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
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY_NAME',P_LOGGING_ENTITY_NAME);
    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME',P_EXCEPTION_NAME);
    WSH_DEBUG_SV.log(l_module_name,'p_location_id',p_location_id);
    WSH_DEBUG_SV.log(l_module_name,'p_message',p_message);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF p_logging_entity_name = 'DELIVERY' THEN
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_EXCEPTIONS_GRP.GET_EXCEPTIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  -- anviswan
  -- making use of WSH_EXCEPTIONS_GRP.Get_exceptions() instead of WSH_EXCEPTIONS_PUB.Get_exceptions()
  WSH_EXCEPTIONS_GRP.Get_exceptions(
    p_api_version => 1.0,
    p_init_msg_list => l_init_msg_list,
    x_return_status => l_return_status,
    x_msg_count => l_exception_msg_count,
    x_msg_data => l_exception_msg_data,
    p_logging_entity_id => p_entity_id,
    p_logging_entity_name => p_logging_entity_name,
    x_exceptions_tab => l_exceptions_tab
    );

   wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);

ELSIF p_logging_entity_name = 'STOP' THEN
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_EXCEPTIONS_GRP.GET_EXCEPTIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  -- anviswan
  -- making use of WSH_EXCEPTIONS_GRP.Get_exceptions() instead of WSH_EXCEPTIONS_PUB.Get_exceptions()
  WSH_EXCEPTIONS_GRP.Get_exceptions(
    p_api_version => 1.0,
    x_return_status => l_return_status,
    x_msg_count => l_exception_msg_count,
    x_msg_data => l_exception_msg_data,
    p_logging_entity_id => p_entity_id,
    p_logging_entity_name => p_logging_entity_name,
    x_exceptions_tab => l_exceptions_tab
    );

   wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);
END IF;


IF p_logging_entity_name <> 'DETAIL' THEN
  FOR i IN 1..l_exceptions_tab.COUNT
    LOOP
      --HACMS {
      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'exception_name',l_exceptions_tab(i).exception_name);
          WSH_DEBUG_SV.log(l_module_name,'status',l_exceptions_tab(i).status);
      END IF;
      --HACMS }

      IF (l_exceptions_tab(i).exception_name = p_exception_name
          AND l_exceptions_tab(i).status='OPEN' ) THEN --HACMS
        l_exception_exists := 'Y';
        EXIT;
      END IF;
    END LOOP;
END IF;


IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'l_exception_exists',l_exception_exists);
END IF;


IF (l_exception_exists = 'N') THEN
--{
  IF p_logging_entity_name = 'DELIVERY' THEN

  -- Bug 3395410 : Commented the following code as p_message is getting populated with the
  -- message to be displayed.

 /*  IF (p_exception_name= 'WSH_IB_DEL_ATT_CHANGE') THEN
       l_msg := p_message;
    ELSE
       FND_MESSAGE.SET_NAME('WSH',p_exception_name);
       FND_MESSAGE.SET_TOKEN('DELIVERY', p_entity_id);
       l_msg := FND_MESSAGE.GET;
    END IF;
*/
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_xc_util.log_exception(
        p_api_version             => 1.0,
        x_return_status           => l_return_status,
        x_msg_count               => l_exception_msg_count,
        x_msg_data                => l_exception_msg_data,
        x_exception_id            => l_dummy_exception_id ,
        p_logging_entity          => 'SHIPPER',
        p_logging_entity_id       => FND_GLOBAL.USER_ID,
        p_exception_name          => p_exception_name,
        p_logged_at_location_id   => p_location_id,
        p_exception_location_id   => p_location_id,
        p_message                 => p_message,
        p_delivery_id             => p_entity_id,
        p_error_message           => l_exception_error_message);

      wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings  => l_num_warnings,
         x_num_errors    => l_num_errors);
   ELSIF p_logging_entity_name = 'STOP' THEN
   -- Bug 3395410 : Commented the following code as p_message is getting populated with the
   -- message to be displayed.
   /*
    FND_MESSAGE.SET_NAME('WSH',p_exception_name);
    FND_MESSAGE.SET_TOKEN('STOP', p_entity_id);
    l_msg := FND_MESSAGE.GET;
   */
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_xc_util.log_exception(
        p_api_version             => 1.0,
        x_return_status           => l_return_status,
        x_msg_count               => l_exception_msg_count,
        x_msg_data                => l_exception_msg_data,
        x_exception_id            => l_dummy_exception_id ,
        p_logging_entity          => 'SHIPPER',
        p_logging_entity_id       => FND_GLOBAL.USER_ID,
        p_exception_name          => p_exception_name,
        p_logged_at_location_id   => p_location_id,
        p_exception_location_id   => p_location_id,
        p_message                 => p_message,
        p_trip_stop_id            => p_entity_id,
        p_error_message           => l_exception_error_message);

      wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings  => l_num_warnings,
         x_num_errors    => l_num_errors);

      END IF;--For logging entity name.

    END IF;--For exception exists.
   --}


   --HACMS {
   IF p_logging_entity_name = 'DETAIL' THEN
      wsh_xc_util.log_exception(
        p_api_version             => 1.0,
        x_return_status           => l_return_status,
        x_msg_count               => l_exception_msg_count,
        x_msg_data                => l_exception_msg_data,
        x_exception_id            => l_dummy_exception_id ,
        p_logging_entity          => 'SHIPPER',
        p_logging_entity_id       => FND_GLOBAL.USER_ID,
        p_exception_name          => p_exception_name,
        p_logged_at_location_id   => p_location_id,
        p_exception_location_id   => p_location_id,
        p_message                 => p_message,
        p_delivery_detail_id      => p_entity_id,
        p_error_message           => l_exception_error_message);

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'wsh_xc_util.log_exception l_return_status',l_return_status);
      END IF;
      wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings  => l_num_warnings,
         x_num_errors    => l_num_errors);
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'after wsh_util_core.api_post_call');
      END IF;
   END IF;
   --HACMS }

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_PO_CMG_PVT.LOG_EXCEPTION',l_module_name);

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --
END Log_Exception;

--========================================================================
-- PROCEDURE : check_pending_txns
-- HISTORY   : Created the API.
--========================================================================

-- Start of comments
-- API name : CHECK_PENDING_TXNS
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API is a utility API to check if there are pending
--	       transactions against the delivery detail line(s).Pending transactions
--             imply
--              1. An ASN which conatins this delivery detail line is pending to be
--		   matched.
--                                       (or)
--              2. A Receipt which conatins this delivery detail line is pending to be
--		   matched.
-- Parameters :
-- IN:
--	        p_header_id		IN NUMBER
--                The header Id of the delivery detail line to be checked for pending transactions.
--	        p_line_id		IN NUMBER
--                The line Id of the delivery detail line to be checked for pending transactions.
--	        p_line_location_id      IN NUMBER
--                The line location Id of the delivery detail line to be checked for pending transactions.
--	        p_release_id            IN NUMBER
--                The release Id of the delivery detail line to be checked for pending transactions.
-- IN OUT:
--
-- OUT:
-- Version : 1.0
-- Previous version  1.0
-- Initial  version  1.0
-- End of comments


Function check_pending_txns(
    p_header_id		IN NUMBER,
    p_line_id		IN NUMBER,
    p_line_location_id  IN NUMBER,
    p_release_id        IN NUMBER
    ) RETURN NUMBER IS

-- Cursor to find out if there are any unmatched transactions
-- present in WSH_INBOUND_TXN_HISTORY table.

cursor c_pending_txns(p_header_id NUMBER,p_line_id NUMBER,
p_line_location_id NUMBER,p_release_id NUMBER) IS
    SELECT '1'
    FROM
    RCV_FTE_LINES_V RFLV,
    WSH_INBOUND_TXN_HISTORY WTH
    WHERE RFLV.PO_HEADER_ID = p_header_id AND
    RFLV.SHIPMENT_HEADER_ID = WTH.SHIPMENT_HEADER_ID AND
    RFLV.PO_LINE_ID         = NVL(p_line_id,RFLV.PO_LINE_ID)    AND
    RFLV.PO_LINE_LOCATION_ID= NVL(p_line_location_id,RFLV.PO_LINE_LOCATION_ID)  AND
    (
      p_release_id IS NULL AND RFLV.po_release_id IS NULL
      OR
      RFLV.PO_RELEASE_ID     = p_release_id
    )
    AND WTH.STATUS NOT IN ('MATCHED','CANCELLED')
    AND WTH.TRANSACTION_TYPE NOT IN ('ROUTING_REQUEST','ROUTING_RESPONSE');

l_pending_txns    NUMBER := 0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_PENDING_TXNS';
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
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_HEADER_ID',P_HEADER_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_ID',P_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LINE_LOCATION_ID',P_LINE_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_RELEASE_ID',P_RELEASE_ID);
  END IF;
  --
  OPEN  c_pending_txns(p_header_id,p_line_id ,p_line_location_id ,p_release_id);
  FETCH c_pending_txns INTO l_pending_txns;

  IF c_pending_txns%NOTFOUND THEN

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN 0;--No Pending Transactions.

  ELSE

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN 1;--Transactions are Pending to be Matched.

  END IF;
  CLOSE c_pending_txns;


  EXCEPTION
   WHEN OTHERS THEN
     WSH_UTIL_CORE.Default_Handler('WSH_PO_CMG_PVT.check_pending_txns',l_module_name);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END check_pending_txns;

/*========================================================================
-- PROCEDURE : populate_additional_line_info
-- HISTORY   : Created the API.
--========================================================================*/

-- Start of comments
-- API name : populate_additional_line_info
-- Type     : Private
-- Pre-reqs : None.
-- Function : This API is used to populate the p_additional_line_info record
--                     structure.Once this record structure is populated, during insert
--                    into wsh_delivery_details, the Bulk_insert API can me made use
--                    of .
-- Parameters :
-- IN OUT:
--   p_line_rec       IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL
--      This record structure contains information about the lines to be updated.
--      The information may include header id,line id ,line location id and other po
--      attributes..
--IN:
--  p_index IN  NUMBER
--     This stores the index of the p_line_rec  that is being passed.
--  p_caller IN VARCHAR2
--     This variable specified if the call to populate_additional_line_info is being made from PO reapproval or ASN/Receipt.
--     If the caller value is 'WSH-PO-INT', then the call is being made from PO Re-approval.
-- OUT:
--  p_additional_line_info_rec  OUT NOCOPY WSH_BULK_PROCESS_PVT.additional_line_info_rec_type
--      This record structure contains all the attributes which are derived in this API.
--   x_return_status  OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

Procedure populate_additional_line_info(
p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_index  IN  NUMBER,
p_caller IN VARCHAR2,
p_additional_line_info_rec  OUT NOCOPY WSH_BULK_PROCESS_PVT.additional_line_info_rec_type ,
x_return_status  OUT NOCOPY VARCHAR2) IS

l_dff_attribute     WSH_FLEXFIELD_UTILS.FlexfieldAttributeTabType ;
l_dff_context       VARCHAR2(150);
l_dff_update_flag   VARCHAR2(1);
l_return_status VARCHAR2(1);
i number := p_index;
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
v_item_info_rec         wsh_util_validate.item_info_rec_type;
l_vendor_party_exists  VARCHAR2(1);
l_index NUMBER;
l_cache_tbl         wsh_util_core.char500_tab_type;
l_cache_ext_tbl     wsh_util_core.char500_tab_type;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POPULATE_ADDITIONAL_LINE_INFO';
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
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_FLEXFIELD_UTILS.GET_DFF_DEFAULTS',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
WSH_FLEXFIELD_UTILS.Get_DFF_Defaults
  (p_flexfield_name    => 'WSH_DELIVERY_DETAILS',
   p_default_values    => l_dff_attribute,
   p_default_context   => l_dff_context,
   p_update_flag       => l_dff_update_flag,
   x_return_status     => l_return_status);


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
Wsh_util_core.api_post_call(
     p_return_status => x_return_status,
     x_num_warnings  => l_num_warnings,
     x_num_errors    => l_num_errors);

   l_index := p_index;

   p_additional_line_info_rec.service_level.EXTEND(p_index);
   p_additional_line_info_rec.mode_of_transport.EXTEND(p_index);
   p_additional_line_info_rec.earliest_pickup_date.EXTEND(p_index);
   p_additional_line_info_rec.latest_pickup_date.EXTEND(p_index);
   p_additional_line_info_rec.earliest_dropoff_date.EXTEND(p_index);
   p_additional_line_info_rec.latest_dropoff_date.EXTEND(p_index);
   p_additional_line_info_rec.ignore_for_planning.EXTEND(p_index);
   p_additional_line_info_rec.cancelled_quantity2.EXTEND(p_index);
   p_additional_line_info_rec.released_status.EXTEND(p_index);
   p_additional_line_info_rec.inv_interfaced_flag.EXTEND(p_index);
   p_additional_line_info_rec.cancelled_quantity.EXTEND(p_index);
   p_additional_line_info_rec.master_container_item_id.EXTEND(p_index);
   p_additional_line_info_rec.detail_container_item_id.EXTEND(p_index);
   p_additional_line_info_rec.attribute_category.EXTEND(p_index);
   p_additional_line_info_rec.attribute1.EXTEND(p_index);
   p_additional_line_info_rec.attribute2.EXTEND(p_index);
   p_additional_line_info_rec.attribute3.EXTEND(p_index);
   p_additional_line_info_rec.attribute4.EXTEND(p_index);
   p_additional_line_info_rec.attribute5.EXTEND(p_index);
   p_additional_line_info_rec.attribute6.EXTEND(p_index);
   p_additional_line_info_rec.attribute7.EXTEND(p_index);
   p_additional_line_info_rec.attribute8.EXTEND(p_index);
   p_additional_line_info_rec.attribute9.EXTEND(p_index);
   p_additional_line_info_rec.attribute10.EXTEND(p_index);
   p_additional_line_info_rec.attribute11.EXTEND(p_index);
   p_additional_line_info_rec.attribute12.EXTEND(p_index);
   p_additional_line_info_rec.attribute13.EXTEND(p_index);
   p_additional_line_info_rec.attribute14.EXTEND(p_index);
   p_additional_line_info_rec.attribute15.EXTEND(p_index);
   p_line_rec.vendor_party_id.EXTEND(p_index);

   p_additional_line_info_rec.source_code := 'PO';
   p_additional_line_info_rec.service_level(p_index):= NULL;
   p_additional_line_info_rec.mode_of_transport(p_index):= NULL;
   p_additional_line_info_rec.earliest_pickup_date(p_index):= NULL;
   p_additional_line_info_rec.latest_pickup_date(p_index):= NULL;
   p_additional_line_info_rec.earliest_dropoff_date(i):=
 (NVL(p_line_rec.schedule_ship_date(p_index),p_line_rec.request_date(p_index)) -
  NVL(p_line_rec.Days_early_receipt_allowed(p_index),0));
   p_additional_line_info_rec.latest_dropoff_date(p_index) :=
 (NVL(p_line_rec.schedule_ship_date(p_index),p_line_rec.request_date(p_index)) +
  NVL(p_line_rec.Days_late_receipt_allowed(p_index),0));
   p_additional_line_info_rec.ignore_for_planning(p_index):= 'Y';
   p_additional_line_info_rec.cancelled_quantity2(p_index):= NULL;
   p_additional_line_info_rec.released_status(p_index):= 'X';
   p_additional_line_info_rec.inv_interfaced_flag(p_index):= 'X';
   p_additional_line_info_rec.cancelled_quantity(p_index):= NULL;
   p_additional_line_info_rec.master_container_item_id(p_index):= NULL;
   p_additional_line_info_rec.detail_container_item_id(p_index):= NULL;
   p_line_rec.shipping_eligible_flag(p_index) := 'Y';
   p_line_rec.shipping_interfaced_flag(p_index) := 'Y';

   p_line_rec.shipped_quantity(p_index) := NULL;
   p_line_rec.received_quantity(p_index) := NULL;

   p_line_rec.shipped_quantity2(p_index) := NULL;
   p_line_rec.received_quantity2(p_index) := NULL;

   IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'p_caller is :',p_caller);
   END IF;

   IF nvl(p_caller,'!!!') <> 'WSH-PO-INT' THEN
      -- Need to calculate the wt and volume before inserting record into wdd.
      -- This is done only if the call is being made from ASN/Receipt.

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.Calculate_Wt_Vol',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      Calculate_Wt_Vol(p_line_rec   => p_line_rec,
                   p_index          => l_index,
                   x_return_status  => l_return_status);

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      wsh_util_core.api_post_call(
          p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

   END IF;

   -- Will Check it out with Nikhil once again and if not needed,can remove it.
   /*IF p_line_rec.request_date(p_index) IS NULL THEN
        P_line_rec.request_date(p_index) := p_line_rec.schedule_ship_date(p_index);
   END IF;*/

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SUPPLIER_PARTY.WSH_SUPPLIER_PARTY',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
   l_vendor_party_exists := WSH_SUPPLIER_PARTY.VENDOR_PARTY_EXISTS(
     p_vendor_id => p_line_rec.vendor_id(p_line_rec.vendor_id.FIRST),
     x_party_id  => p_line_rec.vendor_party_id(p_index));

   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'After calling VENDOR_PARTY_EXISTS');
     WSH_DEBUG_SV.log(l_module_name,'l_vendor_party_exists', l_vendor_party_exists);
   END IF;

IF l_vendor_party_exists = 'N' THEN
    -- { IB-Phase-2
    --If party not exists, throw an error message and return.
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Party does not Exist for the Vendor ');
    END IF;
    raise fnd_api.g_exc_error;
    -- } IB-Phase-2
END IF;

IF p_line_rec.drop_ship_flag(p_index) = 'Y' AND p_line_rec.shipping_method_code(p_index) is  NOT NULL THEN
--{
    -- Need to derive the carrier,service and mode from the ship method code for drop ship order.
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_BULK_PROCESS_PVT.calc_service_mode',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    WSH_BULK_PROCESS_PVT.calc_service_mode(
         p_line_rec         => p_line_rec,
         p_cache_tbl        => l_cache_tbl,
         p_cache_ext_tbl    => l_cache_ext_tbl,
         p_index            => i,
         p_additional_line_info_rec   => p_additional_line_info_rec,
         x_return_status   => l_return_status);

    wsh_util_core.api_post_call(
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors);
--}
END IF;

IF (l_dff_update_flag = 'Y')  THEN
  --{
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ACTIONS_LEVELS.G_VALIDATION_LEVEL_TAB',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    --IF WSH_ACTIONS_LEVELS.g_validation_level_tab(WSH_ACTIONS_LEVELS.C_PO_DEFAULT_FLEX_LVL ) = 1
    --THEN
    --{
      p_additional_line_info_rec.attribute_category(p_index) := l_dff_context ;
      p_additional_line_info_rec.attribute1(p_index) :=l_dff_attribute(1);
      p_additional_line_info_rec.attribute2(p_index) :=l_dff_attribute(2);
      p_additional_line_info_rec.attribute3(p_index) :=l_dff_attribute(3);
      p_additional_line_info_rec.attribute4(p_index) :=l_dff_attribute(4);
      p_additional_line_info_rec.attribute5(p_index) :=l_dff_attribute(5);
      p_additional_line_info_rec.attribute6(p_index) :=l_dff_attribute(6);
      p_additional_line_info_rec.attribute7(p_index) :=l_dff_attribute(7);
      p_additional_line_info_rec.attribute8(p_index) :=l_dff_attribute(8);
      p_additional_line_info_rec.attribute9(p_index) :=l_dff_attribute(9);
      p_additional_line_info_rec.attribute10(p_index) :=l_dff_attribute(10);
      p_additional_line_info_rec.attribute11(p_index) := l_dff_attribute(11);
      p_additional_line_info_rec.attribute12(p_index) :=l_dff_attribute( 12);
      p_additional_line_info_rec.attribute13(p_index) :=l_dff_attribute(13);
      p_additional_line_info_rec.attribute14(p_index) :=l_dff_attribute(14);
      p_additional_line_info_rec.attribute15(p_index) :=l_dff_attribute(15);

    ELSE --}{
      p_additional_line_info_rec.attribute_category(p_index) :=
                       nvl(p_line_rec.context(i),l_dff_context ) ;
      p_additional_line_info_rec.attribute1(p_index) :=
                             nvl(p_line_rec.attribute1(i),l_dff_attribute(1));
      p_additional_line_info_rec.attribute2(p_index) :=
                            nvl(p_line_rec.attribute2(i),l_dff_attribute(2) );
      p_additional_line_info_rec.attribute3(p_index) :=
                          nvl(p_line_rec.attribute3(i), l_dff_attribute( 3) );
      p_additional_line_info_rec.attribute4(p_index) :=
                          nvl(p_line_rec.attribute4(i), l_dff_attribute( 4) );
      p_additional_line_info_rec.attribute5(p_index) :=
                           nvl(p_line_rec.attribute5(i), l_dff_attribute( 5) );
      p_additional_line_info_rec.attribute6(p_index) :=
                           nvl(p_line_rec.attribute6(i), l_dff_attribute( 6) );
      p_additional_line_info_rec.attribute7(p_index) :=
                           nvl(p_line_rec.attribute7(i), l_dff_attribute( 7) );
      p_additional_line_info_rec.attribute8(p_index) :=
                           nvl(p_line_rec.attribute8(i), l_dff_attribute( 8) );
      p_additional_line_info_rec.attribute9(p_index) :=
                           nvl(p_line_rec.attribute9(i), l_dff_attribute( 9) );
      p_additional_line_info_rec.attribute10(p_index) :=
                          nvl(p_line_rec.attribute10(i), l_dff_attribute( 10));
      p_additional_line_info_rec.attribute11(p_index) :=
                          nvl(p_line_rec.attribute11(i), l_dff_attribute( 11));
      p_additional_line_info_rec.attribute12(p_index) :=
                          nvl(p_line_rec.attribute12(i), l_dff_attribute( 12));
      p_additional_line_info_rec.attribute13(p_index) :=
                          nvl(p_line_rec.attribute13(i), l_dff_attribute( 13));
      p_additional_line_info_rec.attribute14(p_index) :=
                          nvl(p_line_rec.attribute14(i), l_dff_attribute( 14));
      p_additional_line_info_rec.attribute15(p_index) :=
                          nvl(p_line_rec.attribute15(i), l_dff_attribute( 15));

    --END IF; --}
  END IF; --}

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_CMG_PVT.populate_additional_line_info',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END populate_additional_line_info;

--==============================================================================
-- PROCEDURE : Calculate_Wt_Vol
-- HISTORY   : Created the API.
--==============================================================================
-- Start of comments
-- API name : Calculate_Wt_Vol
-- Type     : Private
-- Pre-reqs : None.
-- Function : This API is used to dervie the wt/volume attributes of p_line_Rec
--            while processing an ASN or RECEIPT
-- Parameters :
-- IN OUT:
--   p_line_rec       IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL
--      This record structure contains information about the lines to be updated.
--      The information may include header id,line id ,line location id and other po
--      attributes..
--  p_index IN OUT NOCOPY  NUMBER
--     This stores the index of the p_line_rec  that is being passed.
-- OUT:
--   x_return_status  OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

Procedure Calculate_Wt_Vol(p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
                           p_index    IN OUT NOCOPY NUMBER,
       x_return_status OUT NOCOPY VARCHAR2) IS


l_item_info_rec         wsh_util_validate.item_info_rec_type;
l_return_status   VARCHAR2(1);
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Calculate_Wt_Vo';
--

BEGIN

x_return_status := wsh_util_core.g_ret_sts_success;
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;
--

IF (p_line_rec.inventory_item_id(p_index) is NOT NULL) THEN
--{
    -- Need to calculate wt/volume only if inventroy item id is not null.
    IF p_line_rec.weight_uom_code(p_index) IS NULL OR
         p_line_rec.volume_uom_code(p_index) IS NULL
  THEN --{
     IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit wsh_util_validate.get_item_info',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

     wsh_util_validate.get_item_info(
        p_organization_id   => p_line_rec.organization_id(p_index),
        p_inventory_item_id => p_line_rec.inventory_item_id(p_index),
        x_Item_info_rec     => l_item_info_rec,
        x_return_status     => l_return_status);

     wsh_util_core.api_post_call(
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors);

     p_line_rec.weight_uom_code(p_index) := NVL(p_line_rec.weight_uom_code(p_index), l_item_info_rec.weight_uom_code);
     p_line_rec.volume_uom_code(p_index) := NVL(p_line_rec.volume_uom_code(p_index), l_item_info_rec.volume_uom_code);
     p_line_rec.mtl_unit_weight(p_index) := NVL(p_line_rec.mtl_unit_weight(p_index), l_item_info_rec.unit_weight);
     p_line_rec.mtl_unit_volume(p_index) := NVL(p_line_rec.mtl_unit_volume(p_index), l_item_info_rec.unit_volume);

     p_line_rec.net_weight(p_index) := p_line_rec.mtl_unit_weight(p_index)* p_line_rec.requested_quantity(p_index);
     p_line_rec.volume(p_index) := p_line_rec.mtl_unit_volume(p_index) * p_line_rec.requested_quantity(p_index);
     p_line_rec.gross_weight(p_index) := p_line_rec.net_weight(p_index);

   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'p_line_rec wt uom code is :',p_line_rec.weight_uom_code(p_index));
       WSH_DEBUG_SV.log(l_module_name,'p_line_rec vol uom code is :',p_line_rec.volume_uom_code(p_index));
       WSH_DEBUG_SV.log(l_module_name,'p_line_rec unit wt is :',p_line_rec.mtl_unit_weight(p_index));
       WSH_DEBUG_SV.log(l_module_name,'p_line_rec unit vol is :',p_line_rec.mtl_unit_volume(p_index));
       WSH_DEBUG_SV.log(l_module_name,'p_line_rec net wt is : ',p_line_rec.net_weight(p_index));
       WSH_DEBUG_SV.log(l_module_name,'p_line_rec volume is :',p_line_rec.volume(p_index));
       WSH_DEBUG_SV.log(l_module_name,'p_line_rec gross wt is :',p_line_rec.gross_weight(p_index));
  END If;
   END IF;--}
END IF;--}

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     WSH_UTIL_CORE.Default_Handler('WSH_PO_CMG_PVT.Calculate_Wt_Vol');

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END Calculate_Wt_Vol;

END WSH_PO_CMG_PVT;

/
