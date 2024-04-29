--------------------------------------------------------
--  DDL for Package INV_EXPRESS_PICK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EXPRESS_PICK_PUB" AUTHID CURRENT_USER AS
/* $Header: INVEXPRS.pls 120.2 2006/09/14 10:12:09 bradha noship $ */
TYPE INV_SPLIT_DELIVERY_DETAILS_TBL IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

TYPE p_pick_release_status_rec IS RECORD
(
        Delivery_detail_id  NUMBER,
        Pick_status         VARCHAR2(1),
        Split_Delivery_Id  NUMBER
);
TYPE p_pick_release_status_tbl is TABLE OF p_pick_release_status_rec
  INDEX BY BINARY_INTEGER;



PROCEDURE         PICK_RELEASE
        (
         p_api_version               IN      NUMBER
	,p_init_msg_list             IN      VARCHAR2
        ,P_commit                    IN      VARCHAR2
        ,x_return_status             OUT NOCOPY    VARCHAR2
        ,x_msg_count                 OUT NOCOPY    NUMBER
 	,x_msg_data                  OUT NOCOPY    VARCHAR2
  	,p_mo_line_tbl               IN      INV_Move_Order_PUB.TROLIN_TBL_TYPE
        ,p_grouping_rule_id          IN      NUMBER
        ,p_allow_partial_pick        IN      VARCHAR2
        ,p_reservations_tbl       IN  inv_reservation_global.mtl_reservation_tbl_type
        , p_pick_release_status_tbl       OUT NOCOPY    INV_EXPRESS_PICK_PUB.p_pick_release_status_tbl
        );
PROCEDURE   STAGE_DD_RSV(P_mo_line_REC  IN INV_Move_Order_PUB.Trolin_Rec_Type
              ,p_Reservation_tbl IN inv_reservation_global.mtl_reservation_tbl_type
             ,p_pick_release_status_tbl IN OUT NOCOPY INV_EXPRESS_PICK_PUB.p_pick_release_status_tbl
              , x_return_status      OUT NOCOPY VARCHAR2
              , x_msg_count          OUT NOCOPY NUMBER
              , x_msg_data           OUT NOCOPY VARCHAR2);
 PROCEDURE   PICK_SERIAL_NUMBERS(
                                  p_inventory_item_id	IN NUMBER
                                , p_organization_id	IN NUMBER
                                , p_revision		IN VARCHAR2
                                , p_lot_number		IN VARCHAR2
                                , p_subinventory_code	IN VARCHAR2
                                , p_locator_id		IN NUMBER
                                , p_required_sl_qty     IN NUMBER
                                , p_unit_number         IN NUMBER
                                , p_reservation_id      IN NUMBER  -- Bug 5517498
                                , x_available_sl_qty        OUT NOCOPY NUMBER
                                , g_transaction_temp_id     OUT NOCOPY NUMBER
                                , x_serial_index            OUT NOCOPY NUMBER
                                , x_return_status           OUT NOCOPY VARCHAR2
                                , x_msg_count               OUT NOCOPY NUMBER
                                , x_msg_data                OUT NOCOPY VARCHAR2
                                , x_serial_number           OUT NOCOPY VARCHAR2 -- Bug 5517498
				);

END INV_EXPRESS_PICK_PUB;

 

/
