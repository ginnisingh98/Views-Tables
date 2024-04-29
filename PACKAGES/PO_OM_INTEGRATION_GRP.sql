--------------------------------------------------------
--  DDL for Package PO_OM_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_OM_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGOMIS.pls 120.1 2005/08/26 13:51:28 dreddy noship $*/

-- Detailed comments maintained in the Package Body PO_OM_INTEGRATION_GRP.update_req_po
PROCEDURE update_req_po
(
    p_api_version           IN NUMBER,
    p_req_header_id         IN PO_TBL_NUMBER,
    p_req_line_id           IN PO_TBL_NUMBER,
    p_po_header_id          IN PO_TBL_NUMBER := NULL,
    p_po_release_id         IN PO_TBL_NUMBER := NULL,
    p_po_line_id            IN PO_TBL_NUMBER := NULL,
    p_po_line_location_id   IN PO_TBL_NUMBER := NULL,
    p_quantity              IN PO_TBL_NUMBER := NULL,
    p_secondary_quantity    IN PO_TBL_NUMBER := NULL,
    p_need_by_date          IN PO_TBL_DATE := NULL,
    p_ship_to_location_id   IN PO_TBL_NUMBER := NULL,
    p_sales_order_update_date IN PO_TBL_DATE := NULL,
    p_preferred_grade       IN  PO_TBL_VARCHAR240 := NULL, /* INVCONV SSCHINCH 09/07/04*/
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
)
;


-- Detailed comments maintained in the Package Body PO_OM_INTEGRATION_GRP.cancel_req_po
PROCEDURE cancel_req_po
(
    p_api_version           IN NUMBER,
    p_req_header_id         IN PO_TBL_NUMBER,
    p_req_line_id           IN PO_TBL_NUMBER,
    p_po_header_id          IN PO_TBL_NUMBER := NULL,
    p_po_release_id         IN PO_TBL_NUMBER := NULL,
    p_po_line_id            IN PO_TBL_NUMBER := NULL,
    p_po_line_location_id   IN PO_TBL_NUMBER := NULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
)
;

-- <VM_DP FPJ START>

PROCEDURE Purge
( p_api_version          IN            NUMBER
 ,p_init_msg_list        IN            VARCHAR2
 ,p_commit               IN            VARCHAR2
 ,x_return_status        OUT NOCOPY    VARCHAR2
 ,x_msg_count            OUT NOCOPY    NUMBER
 ,x_msg_data             OUT NOCOPY    VARCHAR2
 ,p_entity               IN            VARCHAR2
 ,p_entity_id_tbl        IN            PO_TBL_NUMBER
);

PROCEDURE Validate_Purge
( p_api_version          IN            NUMBER
 ,p_init_msg_list        IN            VARCHAR2
 ,p_commit               IN            VARCHAR2
 ,x_return_status        OUT NOCOPY    VARCHAR2
 ,x_msg_count            OUT NOCOPY    NUMBER
 ,x_msg_data             OUT NOCOPY    VARCHAR2
 ,p_entity               IN            VARCHAR2
 ,p_entity_id_tbl        IN            PO_TBL_NUMBER
 ,x_purge_allowed_tbl    OUT NOCOPY    PO_TBL_VARCHAR1
);

-- <VM_DP FPJ END>
PROCEDURE get_drop_ship_details(p_api_version   IN NUMBER,
                         p_line_location_id     IN NUMBER,
                         x_customer_name        OUT NOCOPY VARCHAR2,
                         x_customer_contact OUT NOCOPY VARCHAR2,
                         x_shipping_method OUT NOCOPY VARCHAR2,
                         x_shipping_instructions OUT NOCOPY VARCHAR2,
                         x_packing_instructions OUT NOCOPY VARCHAR2,
                         x_so_num OUT NOCOPY VARCHAR2,
                         x_so_line_num OUT NOCOPY VARCHAR2,
                         x_so_status OUT NOCOPY VARCHAR2,
                         x_ordered_qty OUT NOCOPY NUMBER,
                         x_shipped_qty OUT NOCOPY NUMBER,
                         x_customer_po_number OUT NOCOPY VARCHAR2,
                         x_customer_po_line_num OUT NOCOPY VARCHAR2,
                         x_customer_po_shipment_num OUT NOCOPY VARCHAR2,
                         x_customer_item_desc   OUT NOCOPY VARCHAR2,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_return_status        OUT NOCOPY VARCHAR2 );


END PO_OM_INTEGRATION_GRP;

 

/
