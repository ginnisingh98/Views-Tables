--------------------------------------------------------
--  DDL for Package GMI_MOVE_ORDER_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MOVE_ORDER_LINE_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMIUMOLS.pls 120.0 2005/05/25 16:17:20 appldev noship $
 ===========================================================================
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMIUMOLS.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Spec of package GMI_Move_order_line_Util                           |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |  21-Apr-00 Created                                                      |
 |  May-2000 odab added :                                                  |
 |             - Line_Auto_Detail                                          |
 |             - Line_Pick_Confirm                                         |
 |                                                                         |
 |  26-SEP-01 Hverddin Added Concurrent Request API                        |
 |             - AUTO_ALLOC_CONFIRM_SRS                                    |
 ===========================================================================


   Attributes global constants
*/

G_ATTRIBUTE1                  CONSTANT NUMBER := 2;
G_ATTRIBUTE10                 CONSTANT NUMBER := 3;
G_ATTRIBUTE11                 CONSTANT NUMBER := 4;
G_ATTRIBUTE12                 CONSTANT NUMBER := 5;
G_ATTRIBUTE13                 CONSTANT NUMBER := 6;
G_ATTRIBUTE14                 CONSTANT NUMBER := 7;
G_ATTRIBUTE15                 CONSTANT NUMBER := 8;
G_ATTRIBUTE2                  CONSTANT NUMBER := 9;
G_ATTRIBUTE3                  CONSTANT NUMBER := 10;
G_ATTRIBUTE4                  CONSTANT NUMBER := 11;
G_ATTRIBUTE5                  CONSTANT NUMBER := 12;
G_ATTRIBUTE6                  CONSTANT NUMBER := 13;
G_ATTRIBUTE7                  CONSTANT NUMBER := 14;
G_ATTRIBUTE8                  CONSTANT NUMBER := 15;
G_ATTRIBUTE9                  CONSTANT NUMBER := 16;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATION_DATE               CONSTANT NUMBER := 19;
G_DATE_REQUIRED               CONSTANT NUMBER := 20;
G_FROM_LOCATOR                CONSTANT NUMBER := 21;
G_FROM_SUBINVENTORY           CONSTANT NUMBER := 22;
/*  G_FROM_SUBINVENTORY           CONSTANT NUMBER := 23; */
G_HEADER                      CONSTANT NUMBER := 24;
G_INVENTORY_ITEM              CONSTANT NUMBER := 25;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 26;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 27;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 28;
G_LINE                        CONSTANT NUMBER := 29;
G_LINE_NUMBER                 CONSTANT NUMBER := 30;
G_LINE_STATUS                 CONSTANT NUMBER := 31;
G_LOT_NUMBER                  CONSTANT NUMBER := 32;
G_ORGANIZATION                CONSTANT NUMBER := 33;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 34;
G_PROGRAM                     CONSTANT NUMBER := 35;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 36;
G_PROJECT                     CONSTANT NUMBER := 37;
G_QUANTITY                    CONSTANT NUMBER := 38;
G_QUANTITY_DELIVERED          CONSTANT NUMBER := 39;
G_QUANTITY_DETAILED           CONSTANT NUMBER := 40;
G_REASON                      CONSTANT NUMBER := 41;
G_REFERENCE                   CONSTANT NUMBER := 42;
/*  G_REFERENCE                   CONSTANT NUMBER := 43;  */
G_REFERENCE               CONSTANT NUMBER := 44;
G_REQUEST                     CONSTANT NUMBER := 45;
G_REVISION                    CONSTANT NUMBER := 46;
G_SERIAL_NUMBER_END           CONSTANT NUMBER := 47;
G_SERIAL_NUMBER_START         CONSTANT NUMBER := 48;
G_STATUS_DATE                 CONSTANT NUMBER := 49;
G_TASK                        CONSTANT NUMBER := 50;
G_TO_ACCOUNT                  CONSTANT NUMBER := 51;
G_TO_LOCATOR                  CONSTANT NUMBER := 52;
G_TO_SUBINVENTORY             CONSTANT NUMBER := 53;
/* G_TO_SUBINVENTORY             CONSTANT NUMBER := 54;  */
G_TRANSACTION_HEADER          CONSTANT NUMBER := 55;
G_UOM                         CONSTANT NUMBER := 56;
/* G_UOM                         CONSTANT NUMBER := 57; */
G_MAX_ATTR_ID                 CONSTANT NUMBER := 58;
G_TRANSACTION_ID		CONSTANT NUMBER := 59;
G_TRANSACTION_SOURCE_ID	CONSTANT NUMBER := 60;
G_TXN_SOURCE_ID			CONSTANT NUMBER := 61;
G_TXN_SOURCE_LINE_ID		CONSTANT NUMBER := 62;
G_TXN_SOURCE_LINE_DETAIL_ID	CONSTANT NUMBER := 63;
G_PRIMARY_QUANTITY		CONSTANT NUMBER := 64;
G_TO_ORGANIZATION_ID		CONSTANT NUMBER := 65;
G_PICK_STRATEGY_ID		CONSTANT NUMBER := 66;
G_PUT_AWAY_STRATEGY_ID		CONSTANT NUMBER := 67;

/*   Procedure Clear_Dependent_Attr */
/*
PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
,   p_old_mo_line_rec                IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
,   x_mo_line_rec                    OUT GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
);
*/
/*   Procedure Apply_Attribute_Changes   */
/*
PROCEDURE Apply_Attribute_Changes
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
,   p_old_mo_line_rec                IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
,   x_mo_line_rec                    OUT GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
);
*/
/*  Function Complete_Record  */
/*
FUNCTION Complete_Record
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
,   p_old_mo_line_rec                IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_Rec ;
*/

/*   Function Convert_Miss_To_Null */

FUNCTION Convert_Miss_To_Null
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_Rec ;
/*   Procedure Update_Row  */

PROCEDURE Update_Row
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
);

/*   Procedure Update_Row_Status  */

PROCEDURE Update_Row_Status
(   p_line_id                         IN        Number,
    p_status                          IN        Number
);

/*   Procedure Insert_Row   */

PROCEDURE Insert_Row
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
);

/*   Procedure Delete_Row  */

PROCEDURE Delete_Row
(   p_line_id                       IN  NUMBER
);

/*   Function Query_Row  */

FUNCTION Query_Row
(   p_line_id                       IN  NUMBER
) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_Rec ;

/*   Function Query_Rows  */

-- HW BUG#:2643440, removed intitalization of G_MISS_XXX
-- to p_line_id and p_header_id
FUNCTION Query_Rows
(   p_line_id                       IN  NUMBER default NULL
,   p_header_id                     IN  NUMBER default NULL
) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_Tbl ;


/*   Function Get_Lines */

FUNCTION Get_Lines
(
   p_header_id                     IN  NUMBER

) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_Tbl ;

/*   Procedure       lock_Row */

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
,   x_mo_line_rec                    OUT NOCOPY GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
);

/*   Function Get_Values   */
/*

FUNCTION Get_Values
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
,   p_old_mo_line_rec                IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec  :=
                                        GMI_MOVE_ORDER_GLOBAL.G_MISS_mo_line_REC
) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_Val_Rec ;

   Function Get_Ids

FUNCTION Get_Ids
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Rec
,   p_mo_line_val_rec                IN  GMI_MOVE_ORDER_GLOBAL.mo_line_Val_Rec
) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_Rec ;
*/

PROCEDURE Line_Auto_Detail
  (  p_mo_line_id                    IN    NUMBER
  ,  p_init_msg_list                 IN    NUMBER
  ,  p_transaction_header_id         IN    NUMBER
  ,  p_transaction_mode	             IN    NUMBER
  ,  p_move_order_type               IN    NUMBER
  ,  p_allow_delete	             IN    VARCHAR2 DEFAULT NULL
  ,  x_number_of_rows                OUT NOCOPY   NUMBER
  ,  x_qc_grade                      OUT NOCOPY   VARCHAR2
  ,  x_detailed_qty                  OUT NOCOPY   NUMBER
  ,  x_qty_UM                        OUT NOCOPY   VARCHAR2
  ,  x_detailed_qty2                 OUT NOCOPY   NUMBER
  ,  x_qty_UM2                       OUT NOCOPY   VARCHAR2
  ,  x_return_status                 OUT NOCOPY   VARCHAR2
  ,  x_msg_count                     OUT NOCOPY   NUMBER
  ,  x_msg_data                      OUT NOCOPY   VARCHAR2
  );

PROCEDURE Line_Pick_Confirm
  (  p_mo_line_id                    IN    NUMBER
  ,  p_init_msg_list                 IN    NUMBER
  ,  p_move_order_type               IN    NUMBER
  ,  x_delivered_qty                 OUT NOCOPY   NUMBER
  ,  x_qty_UM                        OUT NOCOPY   VARCHAR2
  ,  x_delivered_qty2                OUT NOCOPY   NUMBER
  ,  x_qty_UM2                       OUT NOCOPY   VARCHAR2
  ,  x_return_status                 OUT NOCOPY   VARCHAR2
  ,  x_msg_count                     OUT NOCOPY   NUMBER
  ,  x_msg_data                      OUT NOCOPY   VARCHAR2
  );

PROCEDURE AUTO_ALLOC_CONFIRM_SRS
  ( errbuf                           OUT NOCOPY     VARCHAR2
  , retcode                          OUT NOCOPY     VARCHAR2
  , p_pick_confirm                   IN      VARCHAR2
  , p_whse_code                      IN      VARCHAR2
  , p_from_order_num                 IN      NUMBER
  , p_to_order_num                   IN      NUMBER
  , p_item_num                       IN      VARCHAR2
  , p_cust_num                       IN      VARCHAR2
  , p_from_ship_date                 IN      VARCHAR2
  , p_to_ship_date                   IN      VARCHAR2
  , p_log_level                      IN      NUMBER
 );

PROCEDURE Cancel_Move_Order_Line(
         x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
        ,p_line_id                 IN NUMBER
        ,p_delivery_detail_id      IN NUMBER
        ,p_delete_reservations     IN VARCHAR2
        ,p_txn_source_line_id      IN NUMBER DEFAULT NULL
        );

PROCEDURE Reduce_Move_Order_Quantity(
   x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,p_line_id               IN NUMBER
  ,p_delivery_detail_id    IN NUMBER
  ,p_reduction_quantity    IN NUMBER
  ,p_reduction_quantity2   IN NUMBER
  ,p_txn_source_line_id    IN NUMBER DEFAULT NULL
  );

PROCEDURE update_txn_source_line
         ( p_line_id IN NUMBER
         , p_new_source_line_id IN NUMBER
         ) ;

END GMI_MOVE_ORDER_LINE_UTIL;

 

/
