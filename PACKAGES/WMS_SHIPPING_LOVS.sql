--------------------------------------------------------
--  DDL for Package WMS_SHIPPING_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SHIPPING_LOVS" AUTHID CURRENT_USER AS
/* $Header: WMSSHPLS.pls 120.0.12010000.2 2009/07/31 12:52:31 pbonthu ship $ */
--
TYPE t_genref IS REF CURSOR;

-- Start of comments
--  API name: Get_LPN_Order_LOV
--  Type    : Private
--  Pre-reqs: None.
--  Function: Returns a list of sales order associated to
--            a given LPN.  The LPN is identified by it's
--            delivery_detail_id in WSH_DELIVERY_DETAILS
--  Parameters:
--  IN: p_organization_id           IN NUMBER   Required
--        Organization ID of the salse order line and LPN
--      p_parent_delivery_detail_id IN NUMBER  Required
--        Delivery detail ID of the LPN which contains
--        the sales orders
--      p_order                     IN VARCHAR2 Required
--        Partial string value to limit search results
-- OUT: x_order_lov OUT NOCOPY T_GENREF
--        Standard LOV out parameter
--  Version : Current version 1.0
-- End of comments

PROCEDURE Get_LPN_Order_LOV(
  x_order_lov                 OUT NOCOPY t_genref
, p_organization_id           IN         NUMBER
, p_parent_delivery_detail_id IN         NUMBER
, p_order                     IN         VARCHAR2);

-- Start of comments
--  API name: Get_LPN_Orderline_LOV
--  Type    : Private
--  Pre-reqs: None.
--  Function: Returns a list of sales order associated to
--            a given LPN.  The LPN is identified by it's
--            delivery_detail_id in WSH_DELIVERY_DETAILS
--  Parameters:
--  IN: p_organization_id           IN NUMBER   Required
--        Organization ID of the salse order line and LPN
--      p_source_header_id          IN NUMBER   Required
--        Header ID of the sales order that the salse order
--      p_parent_delivery_detail_id IN NUMBER   Required
--        Delivery detail ID of the LPN which contains
--        the sales orderline
--      p_order_line                IN VARCHAR2 Required
--        Partial string value to limit search results
-- OUT: x_order_lov OUT NOCOPY T_GENREF
--        Standard LOV out parameter
--  Version : Current version 1.0
-- End of comments

PROCEDURE Get_LPN_Orderline_LOV(
   x_orderline_lov             OUT NOCOPY T_GENREF
,  p_organization_id           IN         NUMBER
,  p_source_header_id          IN         NUMBER
,  p_parent_delivery_detail_id IN         NUMBER
,  p_order_line                IN         VARCHAR2);


--Added for Case Picking Project start

PROCEDURE Get_Manifest_Pickslip_LOV( x_pickslip_lov OUT NOCOPY T_GENREF ,
                                     p_organization_id  IN NUMBER ,
                                     p_pick_slip_number IN VARCHAR2 ,
                                     p_equipment_id     IN NUMBER := NULL,
                                     p_sign_on_emp_id   IN NUMBER,
                                     p_zone             IN VARCHAR2 := NULL );

PROCEDURE Get_Manifest_Order_LOV( x_orderline_lov OUT NOCOPY T_GENREF ,
                                  p_organization_id IN NUMBER ,
                                  p_order_number    IN VARCHAR2,
                                  p_equipment_id     IN NUMBER := NULL,
                                  p_sign_on_emp_id   IN NUMBER,
                                  p_zone             IN VARCHAR2 := NULL );

--Added for Case Picking Project end

END WMS_SHIPPING_LOVS;

/
