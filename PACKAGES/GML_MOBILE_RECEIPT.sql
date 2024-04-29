--------------------------------------------------------
--  DDL for Package GML_MOBILE_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_MOBILE_RECEIPT" AUTHID CURRENT_USER AS
  /* $Header: GMLMRCVS.pls 120.0 2005/05/25 16:28:27 appldev noship $ */

TYPE t_genref IS REF CURSOR;


--yannamal 4189249 Added NOCOPY for x_return_status and x_error_msg
PROCEDURE Check_Lot_Status(p_lot_id        IN NUMBER,
                           p_lot_num       IN VARCHAR2,
                           p_sublot_num    IN VARCHAR2,
                           p_item_id       IN NUMBER,
                           p_org_id        IN NUMBER,
                           p_locator_id    IN NUMBER,
                           p_reason_code   IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_error_msg     OUT NOCOPY VARCHAR2);

PROCEDURE Get_Lot_LoV( x_lot_lov OUT NOCOPY t_genref,
                       p_item_id IN NUMBER,
                       p_lot_no IN VARCHAR2);


PROCEDURE Get_SubLot_LoV( x_sublot_lov OUT NOCOPY t_genref,
                       p_item_id IN NUMBER,
                       p_lot_no IN VARCHAR2,
                       p_sublot_no IN VARCHAR2);

PROCEDURE Get_Reason_Code_LoV( x_reason_code_lov OUT NOCOPY t_genref,
                               p_reason_code     IN VARCHAR2);

PROCEDURE Get_Location_Lov( x_location_lov OUT NOCOPY t_genref,
                            p_location IN VARCHAR2,
                            p_item_id IN NUMBER,
                            p_whse_code IN VARCHAR2,
                            p_lot_id IN NUMBER);

  PROCEDURE insert_lot(
    p_transaction_interface_id   IN OUT NOCOPY NUMBER
  , p_product_transaction_id     IN OUT NOCOPY NUMBER
  , p_created_by                 IN            NUMBER
  , p_transaction_qty            IN            NUMBER
  , p_secondary_qty              IN            NUMBER
  , p_primary_qty                IN            NUMBER
  , p_lot_number                 IN            VARCHAR2
  , p_sublot_number              IN            VARCHAR2
  , p_expiration_date            IN            DATE
  , p_secondary_unit_of_measure  IN            VARCHAR2
  , p_reason_code                IN            VARCHAR2
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  );

PROCEDURE GET_PO_LINE_ITEM_NUM_LOV(x_po_line_num_lov OUT NOCOPY t_genref,
                              p_organization_id IN NUMBER,
                              p_po_header_id IN NUMBER,
                              p_mobile_form IN VARCHAR2,
                              p_po_line_num IN VARCHAR2,
                              p_inventory_item_id IN VARCHAR2);

PROCEDURE Get_UoM_LoV_RcV(x_uoms            OUT NOCOPY t_genref,
                          p_organization_id IN NUMBER,
                          p_item_id         IN NUMBER,
                          p_uom_type        IN NUMBER,
                          p_uom_code        IN VARCHAR2);

  PROCEDURE rcv_clear_global;

  PROCEDURE get_uom_code(
                          x_return_status      OUT NOCOPY    VARCHAR2
                        , x_uom_code           OUT NOCOPY    VARCHAR2
                        , p_po_header_id       IN            NUMBER
                        , p_item_id            IN            NUMBER
                        , p_organization_id    IN            NUMBER
                        );

  PROCEDURE Create_Lot(p_item_id IN NUMBER,
                       p_item_no IN VARCHAR2,
                       p_lot_no  IN VARCHAR2,
                       p_sublot_no IN VARCHAR2,
                       p_vendor_id IN NUMBER,
                       x_lot_id    OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_error_msg     OUT NOCOPY VARCHAR2);

--yannamal 4189249 Added NOCOPY for x_message
PROCEDURE get_stacked_messages(x_message OUT NOCOPY VARCHAR2);

PROCEDURE GET_DOC_LOV(x_doc_num_lov        OUT NOCOPY t_genref,
                      p_organization_id    IN  NUMBER,
                      p_doc_number         IN  VARCHAR2,
                      p_mobile_form        IN  VARCHAR2,
                      p_manual_po_num_type IN  VARCHAR2,
                      p_shipment_header_id IN  VARCHAR2,
                      p_inventory_item_id  IN  VARCHAR2,
                      p_item_description   IN  VARCHAR2,
                      p_doc_type           IN  VARCHAR2,
                      p_vendor_prod_num    IN  VARCHAR2);


PROCEDURE GET_ITEM_LOV_RECEIVING (
x_Items                               OUT NOCOPY t_genref,
p_Organization_Id                     IN NUMBER,
p_Concatenated_Segments               IN VARCHAR2,
p_poHeaderID                          IN VARCHAR2,
p_poReleaseID                         IN VARCHAR2,
p_poLineID                            IN VARCHAR2,
p_shipmentHeaderID                    IN VARCHAR2,
p_oeOrderHeaderID                     IN VARCHAR2,
p_reqHeaderID                         IN VARCHAR2,
p_projectId                           IN VARCHAR2,
p_taskId                              IN VARCHAR2,
p_pjmorg                              IN VARCHAR2,
p_crossreftype                        IN VARCHAR2
);


PROCEDURE GET_COUNTRY_LOV
  (x_country_lov OUT NOCOPY t_genref,
   p_country IN VARCHAR2 );

  PROCEDURE Get_Sub_Lov_RcV(x_sub OUT NOCOPY t_genref,
                            p_organization_id IN NUMBER,
                            p_item_id IN NUMBER,
                            p_sub IN VARCHAR2,
                            p_restrict_subinventories_code IN NUMBER,
                            p_transaction_type_id IN NUMBER,
                            p_wms_installed IN VARCHAR2);

PROCEDURE clear_lot_rec;

PROCEDURE Calculate_Secondary_Qty(
  p_item_no                     IN  VARCHAR2
, p_unit_of_measure             IN  VARCHAR2
, p_quantity                    IN  NUMBER
, p_lot_no                      IN  VARCHAR2
, p_sublot_no                   IN  VARCHAR2
, p_secondary_unit_of_measure   IN  VARCHAR2
, x_secondary_quantity          OUT NOCOPY      NUMBER
);

  PROCEDURE get_dynamic_locator(x_location_id OUT NOCOPY NUMBER,
                                x_description OUT NOCOPY VARCHAR2,
                                x_result OUT NOCOPY VARCHAR2,
                                x_exist_or_create OUT NOCOPY VARCHAR2,
                                p_org_id IN NUMBER,
                                p_sub_code IN VARCHAR2,
                                p_concat_segs IN VARCHAR2);

PROCEDURE get_prj_loc_lov(
    x_locators               OUT    NOCOPY t_genref
  , p_organization_id        IN     NUMBER
  , p_subinventory_code      IN     VARCHAR2
  , p_restrict_locators_code IN     NUMBER
  , p_inventory_item_id      IN     NUMBER
  , p_concatenated_segments  IN     VARCHAR2
  , p_transaction_type_id    IN     NUMBER
  , p_wms_installed          IN     VARCHAR2
  , p_project_id             IN     NUMBER
  , p_task_id                IN     NUMBER
  );

END GML_MOBILE_RECEIPT;

 

/
