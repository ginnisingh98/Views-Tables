--------------------------------------------------------
--  DDL for Package GML_MOBILE_MOVE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_MOBILE_MOVE_ORDER" AUTHID CURRENT_USER AS
  /* $Header: GMLMOMBS.pls 120.0 2005/05/25 16:20:53 appldev noship $ */


TYPE t_genref IS REF CURSOR;

PROCEDURE Get_Allocation_Parameters(p_alloc_class IN VARCHAR2,
                                    p_org_id IN NUMBER,
                                    p_cust_id IN NUMBER,
                                    p_ship_to_org_id IN NUMBER,
                                    x_grade OUT NOCOPY VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Save_Allocation(p_transaction_id   IN NUMBER,
                          p_lot_id           IN NUMBER,
                          p_location         IN VARCHAR2,
                          p_allocated_qty    IN NUMBER,
                          p_allocated_qty2   IN NUMBER,
                          p_grade            IN VARCHAR2,
                          p_lot_no           IN VARCHAR2,
                          p_lot_status       IN VARCHAR2,
                          p_transaction_date IN DATE,
                          p_reason_code      IN VARCHAR2,
                          p_item_id          IN NUMBER,
                          p_line_id          IN NUMBER,
                          p_warehouse_code   IN VARCHAR2,
                          p_line_detail_id   IN NUMBER,
                          p_transaction_um   IN VARCHAR2,
                          p_transaction_um2  IN VARCHAR2,
                          p_mo_line_id       IN NUMBER,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_error_msg        OUT NOCOPY VARCHAR2);

PROCEDURE Auto_Allocate(p_allow_delete  IN NUMBER,
                          p_mo_line_id    IN NUMBER,
                          p_transaction_header_id IN NUMBER,
                          p_move_order_type    IN NUMBER,
                          x_number_of_rows     OUT NOCOPY NUMBER,
                          x_qc_grade           OUT NOCOPY VARCHAR2,
                          x_detailed_qty       OUT NOCOPY NUMBER,
                          x_qty_UM             OUT NOCOPY VARCHAR2,
                          x_detailed_qty2      OUT NOCOPY NUMBER,
                          x_qty_UM2            OUT NOCOPY VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_error_msg          OUT NOCOPY VARCHAR2);



PROCEDURE Get_Sales_Order_LoV( x_so_mo_lov OUT NOCOPY t_genref,
                         p_org_id IN NUMBER,
                         p_so_no  IN VARCHAR2);

PROCEDURE Get_Item_LoV( x_mo_item_lov OUT NOCOPY t_genref,
                        p_org_id IN NUMBER,
                        p_item_no IN VARCHAR2);


PROCEDURE Get_Location_Lov( x_location_lov OUT NOCOPY t_genref,
                            p_location IN VARCHAR2,
                            p_item_id IN NUMBER,
                            p_whse_code IN VARCHAR2,
                            p_lot_id IN NUMBER,
                            p_neg_inv_allowed IN INTEGER);

PROCEDURE Get_Lot_LoV( x_lot_lov         OUT NOCOPY t_genref,
                       p_lot_no          IN VARCHAR2,
                       p_item_id         IN NUMBER,
                       p_whse_code       IN VARCHAR2,
                       p_location        IN VARCHAR2,
                       p_pref_grade      IN VARCHAR2,
                       p_neg_inv_allowed IN INTEGER);

PROCEDURE Get_Sub_Lot_Lov( x_sub_lot_lov OUT NOCOPY t_genref,
                           p_item_id IN NUMBER,
                           p_whse_code IN VARCHAR2,
                           p_location IN VARCHAR2,
                           p_lot_no IN VARCHAR2,
                           p_sublot_no IN VARCHAR2,
                           p_neg_inv_allowed IN INTEGER);

  PROCEDURE Get_Move_Order_LoV(x_pwmo_lov OUT NOCOPY t_genref,
                              p_organization_id IN NUMBER,
                              p_mo_req_number IN VARCHAR2);


PROCEDURE Get_Delivery_LoV(x_delivery OUT NOCOPY t_genref,
                             p_organization_id IN NUMBER,
                             p_deliv_num IN VARCHAR2);

PROCEDURE Get_Pickslip_LoV(x_pickslip OUT NOCOPY t_genref,
                            p_organization_id IN NUMBER,
                            p_pickslip_num IN VARCHAR2);


PROCEDURE Get_Stacked_Messages(x_message OUT NOCOPY VARCHAR2);

PROCEDURE Get_Reason_Code_Lov(x_reasonCodeLOV OUT NOCOPY t_genref,
                              p_reason_code   IN VARCHAR2);

END GML_MOBILE_MOVE_ORDER;

 

/
