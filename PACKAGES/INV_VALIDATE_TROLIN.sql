--------------------------------------------------------
--  DDL for Package INV_VALIDATE_TROLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_VALIDATE_TROLIN" AUTHID CURRENT_USER AS
/* $Header: INVLTRLS.pls 120.1 2005/12/13 05:00:47 jrayarot noship $ */


SUBTYPE item IS mtl_system_items%ROWTYPE;
SUBTYPE sub  IS mtl_secondary_inventories%ROWTYPE;
SUBTYPE locator IS mtl_item_locations%ROWTYPE;
SUBTYPE lot IS mtl_lot_numbers%ROWTYPE;
SUBTYPE serial IS mtl_serial_numbers%ROWTYPE;
SUBTYPE transaction IS mtl_transaction_types%ROWTYPE;

T CONSTANT NUMBER := 1;
F CONSTANT NUMBER := 0;

g_item ITEM;
g_from_sub  SUB;
g_from_locator LOCATOR;
g_to_sub SUB;
g_to_locator LOCATOR;
g_lot LOT;
g_serial SERIAL;
g_transaction_l transaction;


--Line level validations

FUNCTION Line(p_line_id IN NUMBER)RETURN NUMBER;

FUNCTION Line_Number(p_line_number IN NUMBER,
		     p_header_id IN NUMBER,
		     p_org IN inv_validate_trohdr.ORG)RETURN NUMBER;

FUNCTION Line_Status(p_line_status IN NUMBER)RETURN NUMBER;

FUNCTION Quantity_Delivered(p_quantity_delivered IN NUMBER)RETURN NUMBER;

FUNCTION Quantity_Detailed(p_quantity_detailed IN NUMBER)RETURN NUMBER;

--INVCONV
FUNCTION Secondary_Quantity_Delivered(p_secondary_quantity_delivered IN NUMBER)RETURN NUMBER;

FUNCTION Secondary_Quantity_Detailed(p_secondary_quantity_detailed IN NUMBER)RETURN NUMBER;

--INVCONV

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trolin_rec                    IN  INV_Move_Order_PUB.Trolin_Rec_Type
,   p_old_trolin_rec                IN  INV_Move_Order_PUB.Trolin_Rec_Type := INV_Move_Order_PUB.G_MISS_TROLIN_REC
,   p_move_order_type		    IN  NUMBER DEFAULT INV_GLOBALS.G_MOVE_ORDER_REQUISITION
);


--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trolin_rec                    IN OUT NOCOPY INV_Move_Order_PUB.Trolin_Rec_Type
,   p_trolin_val_rec                IN  INV_Move_Order_PUB.Trolin_Val_Rec_Type
,   p_old_trolin_rec                IN  INV_Move_Order_PUB.Trolin_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROLIN_REC
);


--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trolin_rec                    IN  INV_Move_Order_PUB.Trolin_Rec_Type
);

-- Bug # 1911054
-- Procedure Init : used to initialized the global variable created in this package
PROCEDURE Init;

END INV_Validate_Trolin;

 

/
