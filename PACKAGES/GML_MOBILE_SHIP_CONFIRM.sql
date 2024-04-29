--------------------------------------------------------
--  DDL for Package GML_MOBILE_SHIP_CONFIRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_MOBILE_SHIP_CONFIRM" AUTHID CURRENT_USER AS
  /* $Header: GMLMOSCS.pls 120.0 2005/05/25 16:29:21 appldev noship $ */

TYPE t_genref IS REF CURSOR;
G_PKG_NAME VARCHAR2(30) := 'GMI_MOBILE_SHIP_CONFIRM';

PROCEDURE INV_DELIVERY_LINE_INFO(x_deliveryLineInfo OUT NOCOPY t_genref,
                                 p_delivery_id IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 x_return_Status OUT NOCOPY VARCHAR2);

PROCEDURE INV_LINE_RETURN_TO_STOCK(p_delivery_id IN NUMBER,
				   p_delivery_line_id IN NUMBER,
				   p_shipped_quantity IN NUMBER,
				   p_shipped_quantity2 IN NUMBER,
				   x_return_status OUT NOCOPY VARCHAR2,
				   x_msg_data OUT NOCOPY VARCHAR2,
				   x_msg_count OUT NOCOPY NUMBER,
				   p_commit_flag IN VARCHAR2 DEFAULT FND_API.g_false,
				   p_relieve_rsv  IN VARCHAR2 DEFAULT 'Y');


PROCEDURE INV_REPORT_MISSING_QTY(
				 p_delivery_line_id IN NUMBER,
				 p_missing_quantity IN NUMBER,
				 p_missing_quantity2 IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_data OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER);

PROCEDURE SUBMIT_DELIVERY_LINE(p_delivery_line_id IN NUMBER,
			       p_quantity IN NUMBER,
			       p_quantity2 IN NUMBER,
			       p_trackingNumber IN VARCHAR2,
			       x_return_status OUT NOCOPY VARCHAR2,
			       x_msg_data OUT NOCOPY VARCHAR2,
			       x_msg_count OUT NOCOPY NUMBER );

FUNCTION GET_SHIPMETHOD_MEANING(p_ship_method_code  IN  VARCHAR2)
     RETURN  VARCHAR2;

PROCEDURE GET_DELIVERY_INFO(x_delivery_info OUT NOCOPY t_genref,
                            p_delivery_id IN NUMBER);



PROCEDURE CONFIRM_DELIVERY (
                             p_ship_delivery     IN  VARCHAR2  DEFAULT NULL,
                             p_delivery_id       IN  NUMBER,
                             p_organization_id   IN  NUMBER,
                             p_delivery_name     IN  VARCHAR2,
                             p_carrier_id        IN  NUMBER,
                             p_ship_method_code  IN  VARCHAR2,
                             p_gross_weight      IN  NUMBER,
                             p_gross_weight_uom  IN  VARCHAR2,
                             p_bol               IN  VARCHAR2,
                             p_waybill           IN  VARCHAR2,
                             p_action_flag       IN  VARCHAR2,
                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_ret_code          OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER);


PROCEDURE UNASSIGN_LINES_AND_CONFIRM (
                            p_delivery_id       IN  NUMBER,
                            p_organization_id   IN  NUMBER,
                            p_delivery_name     IN  VARCHAR2,
                            p_carrier_id        IN  NUMBER,
                            p_ship_method_code  IN  VARCHAR2,
                            p_gross_weight      IN  NUMBER,
                            p_gross_weight_uom  IN  VARCHAR2,
                            p_bol               IN  VARCHAR2,
                            p_waybill           IN  VARCHAR2,
                            p_action_flag       IN  VARCHAR2,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_msg_data          OUT NOCOPY VARCHAR2,
                            x_msg_count         OUT NOCOPY NUMBER);



PROCEDURE CHECK_SHIP_SET(
                             p_delivery_id IN NUMBER,
                             x_ship_set      OUT NOCOPY VARCHAR2,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2);

PROCEDURE CHECK_COMPLETE_DELVIERY(
                             p_delivery_id IN NUMBER,
                             x_return_Status OUT NOCOPY VARCHAR2,
                             x_error_msg     OUT NOCOPY VARCHAR2);


PROCEDURE Get_Ship_Conf_Delivery_Lov(x_deliveryLOV OUT NOCOPY t_genref,
                                     p_delivery_name IN VARCHAR2,
                                     p_organization_id IN NUMBER);


PROCEDURE Get_Ship_Items_Lov(x_items OUT NOCOPY t_genref,
                               p_organization_id IN NUMBER,
                               p_delivery_id IN NUMBER,
                               p_concatenated_segments IN VARCHAR2);

PROCEDURE Get_Ship_Method_LoV(x_shipMethodLOV OUT NOCOPY t_genref,
                              p_organization_id  IN NUMBER,
                              p_ship_method_name IN VARCHAR2);


END GML_MOBILE_SHIP_CONFIRM;

 

/
