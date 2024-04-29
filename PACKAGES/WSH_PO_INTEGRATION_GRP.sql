--------------------------------------------------------
--  DDL for Package WSH_PO_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PO_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHPOGPS.pls 120.1 2005/07/12 04:58:47 amony noship $ */

-- { IB-Phase-2
TYPE validateSF_in_rec_type
IS
RECORD
(  po_line_id_tbl wsh_util_core.id_tab_type,
   po_shipment_line_id_tbl wsh_util_core.id_tab_type,
   ship_from_location_id NUMBER
);

TYPE validateSF_out_rec_type
IS
RECORD
(
    is_valid BOOLEAN
);
-- } IB-Phase-2

--=============================================================================
--      API name        : check_purge
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			p_api_version_number   IN NUMBER
--			p_init_msg_list	       IN VARCHAR2
--			p_commit	IN VARCHAR2
--			p_in_rec	IN WSH_PO_INTG_TYPES_GRP.purge_in_rectype
--			x_out_rec	OUT  WSH_PO_INTG_TYPES_GRP.purge_out_rectype
--			x_return_status OUT  VARCHAR2
--			x_msg_count	OUT  NUMBER
--			x_msg_data	OUT  VARCHAR2
--==============================================================================
PROCEDURE check_purge(
   p_api_version_number   IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit	     IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count	OUT NOCOPY NUMBER,
   x_msg_data	OUT NOCOPY VARCHAR2,
   p_in_rec	IN  WSH_PO_INTG_TYPES_GRP.purge_in_rectype,
   x_out_rec	OUT NOCOPY WSH_PO_INTG_TYPES_GRP.purge_out_rectype);


--=============================================================================
--      API name        : purge
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			p_api_version_number   IN NUMBER
--			p_init_msg_list	       IN VARCHAR2
--			p_commit	       IN VARCHAR2
--			x_return_status OUT  VARCHAR2
--			x_msg_count	OUT  NUMBER
--			x_msg_data	OUT  VARCHAR2
--                      p_in_rec      IN  WSH_PO_INTG_TYPES_GRP.purge_in_rectype
--=============================================================================
PROCEDURE purge(
	p_api_version_number   IN NUMBER,
	p_init_msg_list	       IN VARCHAR2,
	p_commit	       IN VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2,
        p_in_rec               IN  WSH_PO_INTG_TYPES_GRP.purge_in_rectype
        );


--=============================================================================
--      API name        :  vendor_merge
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			 p_api_version_number   IN NUMBER
--			 p_init_msg_list IN VARCHAR2
--			 p_commit IN VARCHAR2
--			 p_in_rec IN WSH_PO_INTG_TYPES_GRP.merge_in_rectype
--			 x_out_rec OUT NOCOPY WSH_PO_INTG_TYPES_GRP.merge_out_rectype
--			 x_return_status OUT NOCOPY VARCHAR2
--			 x_msg_count OUT NOCOPY NUMBER
--			 x_msg_data OUT NOCOPY VARCHAR2
--
--=============================================================================

PROCEDURE vendor_merge(
  P_api_version_number   IN NUMBER,
  P_init_msg_list IN VARCHAR2,
  P_commit IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  P_in_rec IN WSH_PO_INTG_TYPES_GRP.merge_in_rectype,
  x_out_rec OUT NOCOPY WSH_PO_INTG_TYPES_GRP.merge_out_rectype);



--=============================================================================
--      API name        :  HasDeliveryInfoChanged
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			 p_api_version_number   IN NUMBER
--			 p_init_msg_list IN NUMBER
--			 p_commit IN VARCHAR2
--			 p_in_rec IN WSH_PO_INTG_TYPES_GRP.delInfo_in_rectype
--			 x_out_rec OUT NOCOPY WSH_PO_INTG_TYPES_GRP.delInfo_out_rectype
--			 x_return_status OUT NOCOPY VARCHAR2
--			 x_msg_count OUT NOCOPY NUMBER
--			 x_msg_data OUT NOCOPY VARCHAR2
--=============================================================================

PROCEDURE HasDeliveryInfoChanged(
  P_api_version_number   IN NUMBER,
  P_init_msg_list 	 IN VARCHAR2,
  P_commit 		 IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2,
  P_in_rec IN WSH_PO_INTG_TYPES_GRP.delInfo_in_rectype,
  x_out_rec OUT NOCOPY WSH_PO_INTG_TYPES_GRP.delInfo_out_rectype);



-- { IB-Phase-2
--=============================================================================
--      API name        : validateASNReceiptShipFrom
--      Type            : public.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			 p_api_version_number   IN NUMBER
--			 p_init_msg_list IN VARCHAR2
--                       p_in_rec  IN WSH_PO_INTEGRATION_GRP.validateSF_in_rec_type
--			 p_commit IN VARCHAR2
--			 x_return_status OUT NOCOPY VARCHAR2
--                       x_out_rec OUT WSH_PO_INTEGRATION_GRP.validateSF_out_rec_type
--			 x_msg_count OUT NOCOPY NUMBER
--			 x_msg_data OUT NOCOPY VARCHAR2
--      Comment         :This API will be called whenever a ASN is created with a
--                       ShipFromLocation on the IssupplierPortal Page. This API
--                       determines whether the ASN can be created for the given
--                       ShipFromLocation based on the following points. It returns
--                       TRUE or FALSE to indicate this
--                               TRUE - ASN can be created.
--                               FALSE - ASN cannot be created.
--                        a) IS the ShipFromLocationId passed through input parameter
--                            p_in_rec a valid WSH Location.
--                                    AND
--                        b) There is a open Delivery Line (for the input PO line and PO
--                           Shipment Line) with the ShipFromLocation
--                           as the one specified as the input parameter or has a
--                           value of -1 as its ShipFromLocation. Return TRUE.
--                        c) IF (b) above is false (no Delivery lines satisfy (b) ), then
--                           check if there are open Delivery Lines for the input PO line
--                           and PO Shipment Line). If so return FALSE, other wise return
--                           TRUE.
--=============================================================================
procedure validateASNReceiptShipFrom
         (
                        p_api_version_number   IN NUMBER,
                        p_init_msg_list        IN VARCHAR2,
                        p_in_rec  IN WSH_PO_INTEGRATION_GRP.validateSF_in_rec_type,
			p_commit               IN VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_out_rec  OUT NOCOPY WSH_PO_INTEGRATION_GRP.validateSF_out_rec_type,
			x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2
           );


-- } IB-Phase-2

END WSH_PO_INTEGRATION_GRP;


 

/
