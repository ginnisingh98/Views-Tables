--------------------------------------------------------
--  DDL for Package WSH_PO_CMG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PO_CMG_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHPPCMS.pls 115.3 2003/10/08 09:33:08 anviswan noship $ */

TYPE T_NUM   is TABLE OF NUMBER;

TYPE dd_list_type IS RECORD
(po_shipment_line_id T_NUM := T_NUM(),
 delivery_detail_id        T_NUM := T_NUM());

/*=============================================================================
--      API name        : Reapprove_PO
--      Type            : Private
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--			  p_action_prms IN WSH_BULK_TYPES_GRP.action_parameters_rectype
--			  p_dd_list    IN dd_list_type
--
--      OUT             : x_return_status            OUT     VARCHAR2(1)
--
==============================================================================*/

PROCEDURE Reapprove_PO(
p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN OUT NOCOPY WSH_BULK_TYPES_GRP.action_parameters_rectype,
p_dd_list    IN dd_list_type,
x_return_status  OUT  NOCOPY VARCHAR2);

/*=============================================================================
--      API name        : Update_Attributes
--      Type            : Private
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--
--      OUT             : x_return_status            OUT     VARCHAR2(1)
--
==============================================================================*/

Procedure Update_Attributes(
p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN WSH_BULK_TYPES_GRP.action_parameters_rectype,
p_dd_list   IN dd_list_type,
p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type,
p_wt_vol_dd_id IN OUT NOCOPY wsh_util_core.id_tab_type,
x_return_status       OUT NOCOPY VARCHAR2);


/*=============================================================================
--      API name        : Update_dd_Attribute
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
-- 	                  p_action_prms IN WSH_BULK_TYPES_GRP.action_parameters_rectype
--			  p_dd_id  IN NUMBER
--			  p_line_rec_index IN NUMBER
--			  x_return_status OUT NOCOPY VARCHAR2)
--
--      OUT             : x_return_status            OUT     VARCHAR2(1)
--
==============================================================================*/

Procedure Update_dd_Attributes(
p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN WSH_BULK_TYPES_GRP.action_parameters_rectype,
p_dd_id  IN NUMBER,
p_line_rec_index IN NUMBER,
p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type,
p_wt_vol_dd_id IN OUT NOCOPY wsh_util_core.id_tab_type,
x_return_status OUT NOCOPY VARCHAR2);

/*=============================================================================
--      API name        : Update_Quantity
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type
--                        p_action_prms IN WSH_BULK_TYPES_GRP.action_parameters_rectype
--
--      OUT             : x_return_status            OUT     VARCHAR2(1)
--
==============================================================================*/

Procedure  Update_Quantity(
p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN OUT NOCOPY WSH_BULK_TYPES_GRP.action_parameters_rectype,
p_dd_id_unassigned IN OUT NOCOPY wsh_util_core.id_tab_type,
p_wt_vol_dd_id IN OUT NOCOPY wsh_util_core.id_tab_type,
x_return_status      OUT   NOCOPY VARCHAR2);

--=============================================================================
--      API name        : cancel_close_po
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--                      p_line_rec    IN OE_WSH_BULK_GRP.line_rec_type
--			p_action_prms IN OUT
--                               WSH_BULK_TYPES_GRP.action_parameters_rectype
--                      x_return_status OUT VARCHAR2
--=============================================================================
 PROCEDURE Cancel_Close_PO(
   p_line_rec	    IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL,
   p_action_prms    IN  OUT NOCOPY
                               WSH_BULK_TYPES_GRP.action_parameters_rectype,

   x_return_status  OUT NOCOPY VARCHAR2
            );
--=============================================================================
--      API name        : purge_po
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--                       p_line_rec	IN     OE_WSH_BULK_GRP.line_rec_type
--                       p_header_ids   IN OUT WSH_UTIL_CORE.id_tab_type
--                       x_return_status   OUT VARCHAR2
--=============================================================================
/*Procedure purge_po(
   p_line_rec 	  IN  OE_WSH_BULK_GRP.line_rec_type DEFAULT NULL,
   p_header_ids   IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type ,
   x_return_status  OUT NOCOPY VARCHAR2);
*/

/*=============================================================================
 --      API name        : reopen_po
 --      Type            : Private.
 --      Function        :
 --      Pre-reqs        : None.
 --      Parameters      :
 --      IN              :
 --                         p_line_rec IN     OE_WSH_BULK_GRP.line_rec_type
 --      OUT             :
 --                         x_return_status       OUT     VARCHAR2
==============================================================================*/
PROCEDURE reopen_po(
       p_line_rec       IN  OE_WSH_BULK_GRP.line_rec_type,
       x_return_status  OUT NOCOPY VARCHAR2) ;

/*=============================================================================
 --      API name        : Log_Exception
 --      Type            : Private.
 --      Function        :
 --      Pre-reqs        : None.
 --      Parameters      :
 --      IN              :
 --                         p_line_rec  IN     OE_WSH_BULK_GRP.line_rec_type
 --      OUT             :
 --                         x_return_status       OUT     VARCHAR2
==============================================================================*/
PROCEDURE Log_Exception(
        p_entity_id           IN NUMBER,
        p_logging_entity_name IN VARCHAR2,
        p_exception_name      IN VARCHAR2,
        p_location_id         IN NUMBER DEFAULT NULL,
        p_message             IN  VARCHAR2 DEFAULT NULL,
        x_return_status       OUT NOCOPY VARCHAR2);

--=============================================================================
--      API name        : None
--      Type            :
--      Function        : check_pending_txns
--      Pre-reqs        : None.
--      Parameters      :
--			 p_header_id IN NUMBER
--			 p_line_id   IN NUMBER
--			 p_line_location_id IN NUMBER
--			 p_release_id  IN  NUMBER
--=============================================================================
Function check_pending_txns(
p_header_id IN NUMBER,
p_line_id   IN NUMBER,
p_line_location_id IN NUMBER,
p_release_id  IN  NUMBER
) RETURN NUMBER ;

/*=============================================================================
 --      API name        : populate_additional_line_info
 --      Type            :
 --      Function        :
 --      Pre-reqs        : None.
 --      Parameters      :
 --      IN              :
 --
 --      OUT             :
 --                         p_additional_line_info_rec
 --			    WSH_BULK_PROCESS_PVT.additional_line_info_rec_type ,
 --			    x_return_status   VARCHAR2
==============================================================================*/
Procedure populate_additional_line_info(
p_line_rec        IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_index IN NUMBER,
p_caller IN  VARCHAR2 DEFAULT NULL,
p_additional_line_info_rec  OUT NOCOPY    WSH_BULK_PROCESS_PVT.additional_line_info_rec_type ,
x_return_status  OUT NOCOPY VARCHAR2);

Procedure Calculate_Wt_Vol(
p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_index    IN OUT NOCOPY NUMBER,
x_return_status OUT NOCOPY VARCHAR2);

END WSH_PO_CMG_PVT;

 

/
