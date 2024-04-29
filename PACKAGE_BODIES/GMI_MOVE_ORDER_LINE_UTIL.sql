--------------------------------------------------------
--  DDL for Package Body GMI_MOVE_ORDER_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_MOVE_ORDER_LINE_UTIL" AS
/*  $Header: GMIUMOLB.pls 120.0 2005/05/25 16:13:10 appldev noship $    */
/* ===========================================================================
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMIUMOLB.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Body of package GMI_Move_order_line_Util                           |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |  21-Apr-00 Created                                                      |
 |  May-2000 odab added :                                                  |
 |             - Line_Auto_Detail                                          |
 |             - Line_Pick_Confirm                                         |
 |             - Lock_Mo_Line                                              |
 | B1513119 odaboval 22-Nov-2000 : added the grouping rule queries.        |
 |                                                                         |
 | 26-SEP-01 Hverddin Added Conc Request API                               |
 |           - AUTO_ALLOC_CONFIRM_SRS                                      |
 |                                                                         |
 |                                                                         |
 |  HW BUG#:2296620 Added code to support ship sets functionality          |                                                                       |
 |
 ===========================================================================
*/

/*   Global constant holding the package name   */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'GMI_MOVE_ORDER_LINE_UTIL';


/*   Function Convert_Miss_To_Null   */

PROCEDURE debug(p_message IN VARCHAR2,
		p_module  IN VARCHAR2) IS
BEGIN
   inv_pick_wave_pick_confirm_pub.tracelog(p_message, p_module);
END;
FUNCTION Convert_Miss_To_Null
(
   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec
)
   RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_rec
IS
   l_mo_line_rec            GMI_MOVE_ORDER_GLOBAL.mo_line_rec := p_mo_line_rec;
BEGIN
/* =======================================================================
  Raise a temporary error, for Dummy calls
 =======================================================================  */
/*     FND_MESSAGE.SET_NAME('GMI','GMI_RSV_UNAVAILABLE');
     OE_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
*/

    IF l_mo_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute1 := NULL;
    END IF;

    IF l_mo_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute10 := NULL;
    END IF;

    IF l_mo_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute11 := NULL;
    END IF;

    IF l_mo_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute12 := NULL;
    END IF;

    IF l_mo_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute13 := NULL;
    END IF;

    IF l_mo_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute14 := NULL;
    END IF;

    IF l_mo_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute15 := NULL;
    END IF;

    IF l_mo_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute2 := NULL;
    END IF;

    IF l_mo_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute3 := NULL;
    END IF;

    IF l_mo_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute4 := NULL;
    END IF;

    IF l_mo_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute5 := NULL;
    END IF;

    IF l_mo_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute6 := NULL;
    END IF;

    IF l_mo_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute7 := NULL;
    END IF;

    IF l_mo_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute8 := NULL;
    END IF;

    IF l_mo_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute9 := NULL;
    END IF;

    IF l_mo_line_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.attribute_category := NULL;
    END IF;

    IF l_mo_line_rec.created_by = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.created_by := NULL;
    END IF;

    IF l_mo_line_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_mo_line_rec.creation_date := NULL;
    END IF;

    IF l_mo_line_rec.date_required = FND_API.G_MISS_DATE THEN
        l_mo_line_rec.date_required := NULL;
    END IF;

    IF l_mo_line_rec.from_locator_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.from_locator_id := NULL;
    END IF;

    IF l_mo_line_rec.from_subinventory_code = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.from_subinventory_code := NULL;
    END IF;

    IF l_mo_line_rec.from_subinventory_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.from_subinventory_id := NULL;
    END IF;

    IF l_mo_line_rec.header_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.header_id := NULL;
    END IF;

    IF l_mo_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.inventory_item_id := NULL;
    END IF;

    IF l_mo_line_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.last_updated_by := NULL;
    END IF;

    IF l_mo_line_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_mo_line_rec.last_update_date := NULL;
    END IF;

    IF l_mo_line_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.last_update_login := NULL;
    END IF;

    IF l_mo_line_rec.line_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.line_id := NULL;
    END IF;

    IF l_mo_line_rec.line_number = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.line_number := NULL;
    END IF;

    IF l_mo_line_rec.line_status = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.line_status := NULL;
    END IF;


    IF l_mo_line_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.organization_id := NULL;
    END IF;

    IF l_mo_line_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.program_application_id := NULL;
    END IF;

    IF l_mo_line_rec.program_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.program_id := NULL;
    END IF;

    IF l_mo_line_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_mo_line_rec.program_update_date := NULL;
    END IF;

    /* IF l_mo_line_rec.project_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.project_id := NULL;
     END IF;
    */

    IF l_mo_line_rec.quantity = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.quantity := NULL;
    END IF;

    IF l_mo_line_rec.quantity_delivered = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.quantity_delivered := NULL;
    END IF;

    IF l_mo_line_rec.quantity_detailed = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.quantity_detailed := NULL;
    END IF;

    IF l_mo_line_rec.reason_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.reason_id := NULL;
    END IF;

    IF l_mo_line_rec.reference = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.reference := NULL;
    END IF;

    IF l_mo_line_rec.reference_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.reference_id := NULL;
    END IF;

    IF l_mo_line_rec.reference_type_code = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.reference_type_code := NULL;
    END IF;

    IF l_mo_line_rec.request_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.request_id := NULL;
    END IF;

/*
    IF l_mo_line_rec.revision = FND_API.G_MISS_CHAR THEN
      l_mo_line_rec.revision := NULL;
    END IF;

    IF l_mo_line_rec.serial_number_end = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.serial_number_end := NULL;
    END IF;

    IF l_mo_line_rec.serial_number_start = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.serial_number_start := NULL;
    END IF;

    IF l_mo_line_rec.task_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.task_id := NULL;
    END IF;

    IF l_mo_line_rec.lot_number = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.lot_number := NULL;
    END IF;
*/

    IF l_mo_line_rec.status_date = FND_API.G_MISS_DATE THEN
        l_mo_line_rec.status_date := NULL;
    END IF;

    IF l_mo_line_rec.to_account_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.to_account_id := NULL;
    END IF;

    IF l_mo_line_rec.to_locator_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.to_locator_id := NULL;
    END IF;

    IF l_mo_line_rec.to_subinventory_code = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.to_subinventory_code := NULL;
    END IF;

    IF l_mo_line_rec.to_subinventory_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.to_subinventory_id := NULL;
    END IF;

    IF l_mo_line_rec.transaction_header_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.transaction_header_id := NULL;
    END IF;

    IF l_mo_line_rec.uom_code = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.uom_code := NULL;
    END IF;

    IF l_mo_line_rec.transaction_type_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.transaction_type_id := NULL;
    END IF;

    IF l_mo_line_rec.transaction_source_type_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.transaction_source_type_id := NULL;
    END IF;

    IF l_mo_line_rec.txn_source_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.txn_source_id := NULL;
    END IF;

    IF l_mo_line_rec.txn_source_line_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.txn_source_line_id := NULL;
    END IF;

    IF l_mo_line_rec.txn_source_line_detail_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.txn_source_line_detail_id := NULL;
    END IF;

    IF l_mo_line_rec.to_organization_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.to_organization_id := NULL;
    END IF;

    IF l_mo_line_rec.primary_quantity = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.primary_quantity := NULL;
    END IF;

    IF l_mo_line_rec.pick_strategy_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.pick_strategy_id := NULL;
    END IF;

    IF l_mo_line_rec.put_away_strategy_id = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.put_away_strategy_id := NULL;
    END IF;

    IF l_mo_line_rec.lot_no = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.lot_no := NULL;
    END IF;

    IF l_mo_line_rec.sublot_no = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.sublot_no := NULL;
    END IF;

    IF l_mo_line_rec.qc_grade = FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.qc_grade := NULL;
    END IF;

    IF l_mo_line_rec.secondary_quantity = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.secondary_quantity:= NULL;
    END IF;

    IF l_mo_line_rec.secondary_uom_code= FND_API.G_MISS_CHAR THEN
        l_mo_line_rec.secondary_uom_code:= NULL;
    END IF;

    IF l_mo_line_rec.secondary_quantity_delivered = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.secondary_quantity_delivered:= NULL;
    END IF;

    IF l_mo_line_rec.secondary_quantity_detailed = FND_API.G_MISS_NUM THEN
        l_mo_line_rec.secondary_quantity_detailed:= NULL;
    END IF;

-- HW BUG#:2296620
    IF l_mo_line_rec.ship_set_id = FND_API.G_MISS_NUM THEN
       l_mo_line_rec.ship_set_id:= NULL;
    END IF;

    RETURN l_mo_line_rec;


END Convert_Miss_To_Null;

/*   Procedure Update_Row   */

PROCEDURE Update_Row
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec
)
IS
BEGIN

    UPDATE  IC_TXN_REQUEST_LINES
    SET     ATTRIBUTE1                     = p_mo_line_rec.attribute1
    ,       ATTRIBUTE10                    = p_mo_line_rec.attribute10
    ,       ATTRIBUTE11                    = p_mo_line_rec.attribute11
    ,       ATTRIBUTE12                    = p_mo_line_rec.attribute12
    ,       ATTRIBUTE13                    = p_mo_line_rec.attribute13
    ,       ATTRIBUTE14                    = p_mo_line_rec.attribute14
    ,       ATTRIBUTE15                    = p_mo_line_rec.attribute15
    ,       ATTRIBUTE2                     = p_mo_line_rec.attribute2
    ,       ATTRIBUTE3                     = p_mo_line_rec.attribute3
    ,       ATTRIBUTE4                     = p_mo_line_rec.attribute4
    ,       ATTRIBUTE5                     = p_mo_line_rec.attribute5
    ,       ATTRIBUTE6                     = p_mo_line_rec.attribute6
    ,       ATTRIBUTE7                     = p_mo_line_rec.attribute7
    ,       ATTRIBUTE8                     = p_mo_line_rec.attribute8
    ,       ATTRIBUTE9                     = p_mo_line_rec.attribute9
    ,       ATTRIBUTE_CATEGORY             = p_mo_line_rec.attribute_category
    ,       CREATED_BY                     = p_mo_line_rec.created_by
    ,       CREATION_DATE                  = p_mo_line_rec.creation_date
    ,       DATE_REQUIRED                  = p_mo_line_rec.date_required
    ,       FROM_LOCATOR_ID                = p_mo_line_rec.from_locator_id
    ,       FROM_SUBINVENTORY_CODE         = p_mo_line_rec.from_subinventory_code
    ,       FROM_SUBINVENTORY_ID           = p_mo_line_rec.from_subinventory_id
    ,       HEADER_ID                      = p_mo_line_rec.header_id
    ,       INVENTORY_ITEM_ID              = p_mo_line_rec.inventory_item_id
    ,       LAST_UPDATED_BY                = p_mo_line_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_mo_line_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_mo_line_rec.last_update_login
    ,       LINE_ID                        = p_mo_line_rec.line_id
    ,       LINE_NUMBER                    = p_mo_line_rec.line_number
    ,       LINE_STATUS                    = p_mo_line_rec.line_status
/*     ,       LOT_NUMBER                     = p_mo_line_rec.lot_number  */
    ,       ORGANIZATION_ID                = p_mo_line_rec.organization_id
    ,       PROGRAM_APPLICATION_ID         = p_mo_line_rec.program_application_id
    ,       PROGRAM_ID                     = p_mo_line_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_mo_line_rec.program_update_date
/*     ,       PROJECT_ID                     = p_mo_line_rec.project_id */
    ,       QUANTITY                       = p_mo_line_rec.quantity
    ,       QUANTITY_DELIVERED             = p_mo_line_rec.quantity_delivered
    ,       QUANTITY_DETAILED              = p_mo_line_rec.quantity_detailed
    ,       REASON_ID                      = p_mo_line_rec.reason_id
    ,       REFERENCE                      = p_mo_line_rec.reference
    ,       REFERENCE_ID                   = p_mo_line_rec.reference_id
    ,       REFERENCE_TYPE_CODE            = p_mo_line_rec.reference_type_code
    ,       REQUEST_ID                     = p_mo_line_rec.request_id
/*     ,       REVISION                       = p_mo_line_rec.revision   */
/*     ,       SERIAL_NUMBER_END              = p_mo_line_rec.serial_number_end */
/*     ,       SERIAL_NUMBER_START            = p_mo_line_rec.serial_number_start  */
    ,       STATUS_DATE                    = p_mo_line_rec.status_date
/*     ,       TASK_ID                        = p_mo_line_rec.task_id  */
    ,       TO_ACCOUNT_ID                  = p_mo_line_rec.to_account_id
    ,       TO_LOCATOR_ID                  = p_mo_line_rec.to_locator_id
    ,       TO_SUBINVENTORY_CODE           = p_mo_line_rec.to_subinventory_code
    ,       TO_SUBINVENTORY_ID             = p_mo_line_rec.to_subinventory_id
    ,       TRANSACTION_HEADER_ID          = p_mo_line_rec.transaction_header_id
    ,       UOM_CODE                       = p_mo_line_rec.uom_code
    ,	    TRANSACTION_TYPE_ID		   = p_mo_line_rec.transaction_type_id
    ,	    TRANSACTION_SOURCE_TYPE_ID     = p_mo_line_rec.transaction_source_type_id
    ,	    TXN_SOURCE_ID		   = p_mo_line_rec.txn_source_id
    ,       TXN_SOURCE_LINE_ID		   = p_mo_line_rec.txn_source_line_id
    , 	    TXN_SOURCE_LINE_DETAIL_ID	   = p_mo_line_rec.txn_source_line_detail_id
    ,	    TO_ORGANIZATION_ID		   = p_mo_line_rec.to_organization_id
    , 	    PRIMARY_QUANTITY		   = p_mo_line_rec.primary_quantity
    ,	    PICK_STRATEGY_ID		   = p_mo_line_rec.pick_strategy_id
    ,       PUT_AWAY_STRATEGY_ID	   = p_mo_line_rec.put_away_strategy_id
    ,       LOT_NO                    = p_mo_line_rec.lot_no
    ,       SUBLOT_NO                 = p_mo_line_rec.sublot_no
    ,       QC_GRADE                  = p_mo_line_rec.qc_grade
    ,       SECONDARY_QUANTITY        = p_mo_line_rec.secondary_quantity
    ,       SECONDARY_UOM_CODE        = p_mo_line_rec.secondary_uom_code
    ,  SECONDARY_QUANTITY_DELIVERED =p_mo_line_rec.secondary_quantity_delivered
    ,  SECONDARY_QUANTITY_DETAILED = p_mo_line_rec.secondary_quantity_detailed
-- HW BUG#:2296620 added ship_set_id
    ,  SHIP_SET_ID               = p_mo_line_rec.ship_set_id
       WHERE   LINE_ID = p_mo_line_rec.line_id
    ;
gmi_reservation_util.println('Done updating ic_txn_requ_lines');

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

 /*   Procedure Update_Row_Status  */

PROCEDURE Update_Row_Status
(   p_line_id              IN  Number,
    p_status               IN  Number
)
IS
l_mo_line_rec    GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
BEGIN
          l_mo_line_rec := GMI_MOVE_ORDER_LINE_util.Query_Row( p_line_id );
                l_mo_line_rec.Line_Status := p_status;
                l_mo_line_rec.last_update_date := SYSDATE;
                l_mo_line_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_mo_line_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                GMI_MOVE_ORDER_LINE_UTIL.Update_Row(l_mo_line_rec);

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row_Status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row_Status;

/*   Procedure Insert_Row  */

PROCEDURE Insert_Row
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec
)
IS
err_num NUMBER;
err_msg VARCHAR2(100);
BEGIN

gmi_reservation_util.println('In insert row in move order line');

WSH_UTIL_CORE.Println(' Line Insert DML');
WSH_UTIL_CORE.Println(' Line   id         =>' || p_mo_line_rec.line_id );
gmi_reservation_util.Println(' Line   id         =>' || p_mo_line_rec.line_id );
WSH_UTIL_CORE.Println(' Line   number     =>' || p_mo_line_rec.line_number );
WSH_UTIL_CORE.Println(' Header id         =>' || p_mo_line_rec.header_id );
WSH_UTIL_CORE.Println(' Inventory Item Id =>' || p_mo_line_rec.inventory_item_id );
WSH_UTIL_CORE.Println(' date required     =>' || p_mo_line_rec.date_required );
WSH_UTIL_CORE.Println(' Line Status       =>' || p_mo_line_rec.line_status );
WSH_UTIL_CORE.Println(' Requested qty     =>' || p_mo_line_rec.quantity );
WSH_UTIL_CORE.Println(' Detailed  qty     =>' || p_mo_line_rec.quantity_detailed );

    INSERT  INTO IC_TXN_REQUEST_LINES
    (       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_REQUIRED
    ,       FROM_LOCATOR_ID
    ,       FROM_SUBINVENTORY_CODE
    ,       FROM_SUBINVENTORY_ID
    ,       HEADER_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       LINE_NUMBER
    ,       LINE_STATUS
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUANTITY
    ,       QUANTITY_DELIVERED
    ,       QUANTITY_DETAILED
    ,       REASON_ID
    ,       REFERENCE
    ,       REFERENCE_ID
    ,       REFERENCE_TYPE_CODE
    ,       REQUEST_ID
    ,       STATUS_DATE
    ,       TO_ACCOUNT_ID
    ,       TO_LOCATOR_ID
    ,       TO_SUBINVENTORY_CODE
    ,       TO_SUBINVENTORY_ID
    ,       TRANSACTION_HEADER_ID
    ,       UOM_CODE
    ,	    TRANSACTION_TYPE_ID
    ,	    TRANSACTION_SOURCE_TYPE_ID
    , 	    TXN_SOURCE_ID
    ,       TXN_SOURCE_LINE_ID
    ,       TXN_SOURCE_LINE_DETAIL_ID
    ,       TO_ORGANIZATION_ID
    ,       PRIMARY_QUANTITY
    ,       PICK_STRATEGY_ID
    ,       PUT_AWAY_STRATEGY_ID
    ,       LOT_NO
    ,       SUBLOT_NO
    ,       QC_GRADE
    ,       SECONDARY_QUANTITY
    ,       SECONDARY_UOM_CODE
    ,       SECONDARY_QUANTITY_DELIVERED
    ,       SECONDARY_QUANTITY_DETAILED
--HW BUG#:2296620 added ship_set_id
    ,       SHIP_SET_ID
    )
    VALUES
    (       p_mo_line_rec.attribute1
    ,       p_mo_line_rec.attribute10
    ,       p_mo_line_rec.attribute11
    ,       p_mo_line_rec.attribute12
    ,       p_mo_line_rec.attribute13
    ,       p_mo_line_rec.attribute14
    ,       p_mo_line_rec.attribute15
    ,       p_mo_line_rec.attribute2
    ,       p_mo_line_rec.attribute3
    ,       p_mo_line_rec.attribute4
    ,       p_mo_line_rec.attribute5
    ,       p_mo_line_rec.attribute6
    ,       p_mo_line_rec.attribute7
    ,       p_mo_line_rec.attribute8
    ,       p_mo_line_rec.attribute9
    ,       p_mo_line_rec.attribute_category
    ,       p_mo_line_rec.created_by
    ,       p_mo_line_rec.creation_date
    ,       p_mo_line_rec.date_required
    ,       p_mo_line_rec.from_locator_id
    ,       p_mo_line_rec.from_subinventory_code
    ,       p_mo_line_rec.from_subinventory_id
    ,       p_mo_line_rec.header_id
    ,       p_mo_line_rec.inventory_item_id
    ,       p_mo_line_rec.last_updated_by
    ,       p_mo_line_rec.last_update_date
    ,       p_mo_line_rec.last_update_login
    ,       p_mo_line_rec.line_id
    ,       p_mo_line_rec.line_number
    ,       p_mo_line_rec.line_status
    ,       p_mo_line_rec.organization_id
    ,       p_mo_line_rec.program_application_id
    ,       p_mo_line_rec.program_id
    ,       p_mo_line_rec.program_update_date
    ,       p_mo_line_rec.quantity
    ,       p_mo_line_rec.quantity_delivered
    ,       p_mo_line_rec.quantity_detailed
    ,       p_mo_line_rec.reason_id
    ,       p_mo_line_rec.reference
    ,       p_mo_line_rec.reference_id
    ,       p_mo_line_rec.reference_type_code
    ,       p_mo_line_rec.request_id
    ,       p_mo_line_rec.status_date
    ,       p_mo_line_rec.to_account_id
    ,       p_mo_line_rec.to_locator_id
    ,       p_mo_line_rec.to_subinventory_code
    ,       p_mo_line_rec.to_subinventory_id
    ,       p_mo_line_rec.transaction_header_id
    ,       p_mo_line_rec.uom_code
    , 	    p_mo_line_rec.transaction_type_id
    ,	    p_mo_line_rec.transaction_source_type_id
    ,	    p_mo_line_rec.txn_source_id
    ,	    p_mo_line_rec.txn_source_line_id
    ,	    p_mo_line_rec.txn_source_line_detail_id
    ,	    p_mo_line_rec.to_organization_id
    ,	    p_mo_line_rec.primary_quantity
    ,	    p_mo_line_rec.pick_strategy_id
    ,	    p_mo_line_rec.put_away_strategy_id
    ,	  p_mo_line_rec.lot_no
    ,	  p_mo_line_rec.sublot_no
    ,       p_mo_line_rec.qc_grade
    ,       p_mo_line_rec.secondary_quantity
    ,       p_mo_line_rec.secondary_uom_code
    ,       p_mo_line_rec.secondary_quantity_delivered
    ,       p_mo_line_rec.secondary_quantity_detailed
-- HW BUG#:2296620 added ship_set_id
    ,       p_mo_line_rec.ship_set_id
    );

gmi_reservation_util.println('End of insert row in move order lines');

EXCEPTION

    WHEN OTHERS THEN

    err_num :=SQLCODE;
    err_msg :=SUBSTR(SQLERRM,1 ,100);

    WSH_UTIL_CORE.Println(' Line Insert Error => ' || err_num || err_msg);
        gmi_reservation_util.Println(' Line Insert Error => ' || err_num || err_msg);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

/*   Procedure Delete_Row  */

PROCEDURE Delete_Row
(   p_line_id                       IN  NUMBER
)
IS
BEGIN

    DELETE  FROM IC_TXN_REQUEST_LINES
    WHERE   LINE_ID = p_line_id
    ;


EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

/*   Function Get_Lines  */

FUNCTION Get_Lines
(   p_header_id                       IN  NUMBER
) RETURN GMI_Move_Order_GLOBAL.mo_line_tbl
IS
BEGIN

    RETURN Query_Rows
        (   p_header_id                     => p_header_id
        );


END Get_Lines;

/*   Function Query_Row  */

FUNCTION Query_Row
(   p_line_id                       IN  NUMBER
) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_rec
IS
BEGIN

    RETURN Query_Rows
        (   p_line_id                     => p_line_id
        )(1);


END Query_Row;

/*   Function Query_Rows */
-- HW BUG#:2643440, removed intitalization of G_MISS_XXX
-- to p_line_id and p_header_id

FUNCTION Query_Rows
(   p_line_id                       IN  NUMBER default NULL
,   p_header_id                     IN  NUMBER default NULL

) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_tbl
IS
l_mo_line_rec                  GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
l_mo_line_tbl                  GMI_MOVE_ORDER_GLOBAL.mo_line_tbl;


CURSOR l_mo_line_csr IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_REQUIRED
    ,       FROM_LOCATOR_ID
    ,       FROM_SUBINVENTORY_CODE
    ,       FROM_SUBINVENTORY_ID
    ,       HEADER_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       LINE_NUMBER
    ,       LINE_STATUS
/*     ,       LOT_NUMBER  */
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
/*     ,       PROJECT_ID  */
    ,       QUANTITY
    ,       QUANTITY_DELIVERED
    ,       QUANTITY_DETAILED
    ,       REASON_ID
    ,       REFERENCE
    ,       REFERENCE_ID
    ,       REFERENCE_TYPE_CODE
    ,       REQUEST_ID
/*     ,       REVISION  */
/*     ,       SERIAL_NUMBER_END  */
/*      ,       SERIAL_NUMBER_START */
    ,       STATUS_DATE
/*     ,       TASK_ID */
    ,       TO_ACCOUNT_ID
    ,       TO_LOCATOR_ID
    ,       TO_SUBINVENTORY_CODE
    ,       TO_SUBINVENTORY_ID
    ,       TRANSACTION_HEADER_ID
    ,       UOM_CODE
    , 	    TRANSACTION_TYPE_ID
    ,	    TRANSACTION_SOURCE_TYPE_ID
    ,	    TXN_SOURCE_ID
    ,	    TXN_SOURCE_LINE_ID
    ,	    TXN_SOURCE_LINE_DETAIL_ID
    ,	    TO_ORGANIZATION_ID
    ,	    PRIMARY_QUANTITY
    ,	    PICK_STRATEGY_ID
    ,	    PUT_AWAY_STRATEGY_ID
    ,       LOT_NO
    ,       SUBLOT_NO
    ,       QC_GRADE
    ,       SECONDARY_QUANTITY
    ,       SECONDARY_UOM_CODE
    ,  SECONDARY_QUANTITY_DELIVERED
    ,  SECONDARY_QUANTITY_DETAILED
-- HW BUG#:2296620 added ship_set_id
    ,       SHIP_SET_ID
    FROM    IC_TXN_REQUEST_LINES
    WHERE ( LINE_ID = p_line_id
    )
    OR (    HEADER_ID = p_header_id
    );


BEGIN

-- HW BUG#:2643440. Removed the AND condition to check for FND_API.G_MISS_NUM
-- for both p_line_id and p_header_id
    IF
    (p_line_id IS NOT NULL)
     AND
    (p_header_id IS NOT NULL)
     THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: line_id = '|| p_line_id || ', header_id = '|| p_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    /*   Loop over fetched records  */

    FOR l_implicit_rec IN l_mo_line_csr LOOP

        l_mo_line_rec.attribute1        := l_implicit_rec.ATTRIBUTE1;
        l_mo_line_rec.attribute10       := l_implicit_rec.ATTRIBUTE10;
        l_mo_line_rec.attribute11       := l_implicit_rec.ATTRIBUTE11;
        l_mo_line_rec.attribute12       := l_implicit_rec.ATTRIBUTE12;
        l_mo_line_rec.attribute13       := l_implicit_rec.ATTRIBUTE13;
        l_mo_line_rec.attribute14       := l_implicit_rec.ATTRIBUTE14;
        l_mo_line_rec.attribute15       := l_implicit_rec.ATTRIBUTE15;
        l_mo_line_rec.attribute2        := l_implicit_rec.ATTRIBUTE2;
        l_mo_line_rec.attribute3        := l_implicit_rec.ATTRIBUTE3;
        l_mo_line_rec.attribute4        := l_implicit_rec.ATTRIBUTE4;
        l_mo_line_rec.attribute5        := l_implicit_rec.ATTRIBUTE5;
        l_mo_line_rec.attribute6        := l_implicit_rec.ATTRIBUTE6;
        l_mo_line_rec.attribute7        := l_implicit_rec.ATTRIBUTE7;
        l_mo_line_rec.attribute8        := l_implicit_rec.ATTRIBUTE8;
        l_mo_line_rec.attribute9        := l_implicit_rec.ATTRIBUTE9;
        l_mo_line_rec.attribute_category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_mo_line_rec.created_by        := l_implicit_rec.CREATED_BY;
        l_mo_line_rec.creation_date     := l_implicit_rec.CREATION_DATE;
        l_mo_line_rec.date_required     := l_implicit_rec.DATE_REQUIRED;
        l_mo_line_rec.from_locator_id   := l_implicit_rec.FROM_LOCATOR_ID;
        l_mo_line_rec.from_subinventory_code := l_implicit_rec.FROM_SUBINVENTORY_CODE;
        l_mo_line_rec.from_subinventory_id := l_implicit_rec.FROM_SUBINVENTORY_ID;
        l_mo_line_rec.header_id         := l_implicit_rec.HEADER_ID;
        l_mo_line_rec.inventory_item_id := l_implicit_rec.INVENTORY_ITEM_ID;
        l_mo_line_rec.last_updated_by   := l_implicit_rec.LAST_UPDATED_BY;
        l_mo_line_rec.last_update_date  := l_implicit_rec.LAST_UPDATE_DATE;
        l_mo_line_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_mo_line_rec.line_id           := l_implicit_rec.LINE_ID;
        l_mo_line_rec.line_number       := l_implicit_rec.LINE_NUMBER;
        l_mo_line_rec.line_status       := l_implicit_rec.LINE_STATUS;
   /*      l_mo_line_rec.lot_number        := l_implicit_rec.LOT_NUMBER;  */
        l_mo_line_rec.organization_id   := l_implicit_rec.ORGANIZATION_ID;
        l_mo_line_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_mo_line_rec.program_id        := l_implicit_rec.PROGRAM_ID;
        l_mo_line_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
/*         l_mo_line_rec.project_id        := l_implicit_rec.PROJECT_ID;  */
        l_mo_line_rec.quantity          := l_implicit_rec.QUANTITY;
        l_mo_line_rec.quantity_delivered := l_implicit_rec.QUANTITY_DELIVERED;
        l_mo_line_rec.quantity_detailed := l_implicit_rec.QUANTITY_DETAILED;
        l_mo_line_rec.reason_id         := l_implicit_rec.REASON_ID;
        l_mo_line_rec.reference         := l_implicit_rec.REFERENCE;
        l_mo_line_rec.reference_id      := l_implicit_rec.REFERENCE_ID;
        l_mo_line_rec.reference_type_code := l_implicit_rec.REFERENCE_TYPE_CODE;
        l_mo_line_rec.request_id        := l_implicit_rec.REQUEST_ID;
 /*       l_mo_line_rec.revision          := l_implicit_rec.REVISION;  */
 /*        l_mo_line_rec.serial_number_end := l_implicit_rec.SERIAL_NUMBER_END; */
 /*         l_mo_line_rec.serial_number_start := l_implicit_rec.SERIAL_NUMBER_START; */
        l_mo_line_rec.status_date       := l_implicit_rec.STATUS_DATE;
/*        l_mo_line_rec.task_id           := l_implicit_rec.TASK_ID;  */
        l_mo_line_rec.to_account_id     := l_implicit_rec.TO_ACCOUNT_ID;
        l_mo_line_rec.to_locator_id     := l_implicit_rec.TO_LOCATOR_ID;
        l_mo_line_rec.to_subinventory_code := l_implicit_rec.TO_SUBINVENTORY_CODE;
        l_mo_line_rec.to_subinventory_id := l_implicit_rec.TO_SUBINVENTORY_ID;
        l_mo_line_rec.transaction_header_id := l_implicit_rec.TRANSACTION_HEADER_ID;
        l_mo_line_rec.uom_code          := l_implicit_rec.UOM_CODE;
	l_mo_line_rec.transaction_type_id := l_implicit_rec.TRANSACTION_TYPE_ID;
	l_mo_line_rec.transaction_source_type_id := l_implicit_rec.TRANSACTION_SOURCE_TYPE_ID;
	l_mo_line_rec.txn_source_id := l_implicit_rec.TXN_SOURCE_ID;
	l_mo_line_rec.txn_source_line_id := l_implicit_rec.TXN_SOURCE_LINE_ID;
	l_mo_line_rec.txn_source_line_detail_id := l_implicit_rec.TXN_SOURCE_LINE_DETAIL_ID;
	l_mo_line_rec.to_organization_id	:= l_implicit_rec.TO_ORGANIZATION_ID;
	l_mo_line_rec.primary_quantity := l_implicit_rec.PRIMARY_QUANTITY;
	l_mo_line_rec.pick_strategy_id := l_implicit_rec.PICK_STRATEGY_ID;
	l_mo_line_rec.put_away_strategy_id := l_implicit_rec.PUT_AWAY_STRATEGY_ID;
     l_mo_line_rec.lot_no := l_implicit_rec.lot_no;
     l_mo_line_rec.sublot_no := l_implicit_rec.sublot_no;
     l_mo_line_rec.qc_grade := l_implicit_rec.qc_grade;
     l_mo_line_rec.secondary_quantity := l_implicit_rec.secondary_quantity;
     l_mo_line_rec.secondary_uom_code := l_implicit_rec.secondary_uom_code;
     l_mo_line_rec.secondary_quantity_delivered := l_implicit_rec.secondary_quantity_delivered;
     l_mo_line_rec.secondary_quantity_detailed :=l_implicit_rec.secondary_quantity_detailed;
-- HW BUG#:2296620 added ship_set_id
     l_mo_line_rec.ship_set_id :=  l_implicit_rec.ship_set_id ;
     l_mo_line_tbl(l_mo_line_tbl.COUNT + 1) := l_mo_line_rec;

    END LOOP;


    /*    PK sent and no rows found  */

-- HW BUG#:2643440. Removed the AND condition to check for FND_API.G_MISS_NUM
-- for p_line_id
    IF
    (p_line_id IS NOT NULL)
     AND
    (l_mo_line_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    /*   Return fetched table  */

    RETURN l_mo_line_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

/*   Procedure       lock_Row  */

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_mo_line_rec                   IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec
,   x_mo_line_rec                   OUT NOCOPY GMI_MOVE_ORDER_GLOBAL.mo_line_rec
)
IS
l_mo_line_rec                  GMI_MOVE_ORDER_GLOBAL.mo_line_rec;

CURSOR c_lock_mol( mo_line_id IN NUMBER) IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DATE_REQUIRED
    ,       FROM_LOCATOR_ID
    ,       FROM_SUBINVENTORY_CODE
    ,       FROM_SUBINVENTORY_ID
    ,       HEADER_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       LINE_NUMBER
    ,       LINE_STATUS
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QUANTITY
    ,       QUANTITY_DELIVERED
    ,       QUANTITY_DETAILED
    ,       REASON_ID
    ,       REFERENCE
    ,       REFERENCE_ID
    ,       REFERENCE_TYPE_CODE
    ,       REQUEST_ID
    ,       STATUS_DATE
    ,       TO_ACCOUNT_ID
    ,       TO_LOCATOR_ID
    ,       TO_SUBINVENTORY_CODE
    ,       TO_SUBINVENTORY_ID
    ,       TRANSACTION_HEADER_ID
    ,       UOM_CODE
    ,	    TRANSACTION_TYPE_ID
    ,	    TRANSACTION_SOURCE_TYPE_ID
    ,	    TXN_SOURCE_ID
    ,	    TXN_SOURCE_LINE_ID
    ,	    TXN_SOURCE_LINE_DETAIL_ID
    ,       TO_ORGANIZATION_ID
    ,       PRIMARY_QUANTITY
    ,       PICK_STRATEGY_ID
    ,       PUT_AWAY_STRATEGY_ID
    ,       LOT_NO
    ,       SUBLOT_NO
    ,       QC_GRADE
    ,       SECONDARY_QUANTITY
    ,       SECONDARY_UOM_CODE
    ,  SECONDARY_QUANTITY_DELIVERED
    ,  SECONDARY_QUANTITY_DETAILED
-- HW BUG#:2296620 added ship_set_id
,       SHIP_SET_ID
    FROM    IC_TXN_REQUEST_LINES
    WHERE   LINE_ID = mo_line_id
        FOR UPDATE NOWAIT;

BEGIN

x_return_status                := FND_API.G_RET_STS_SUCCESS;
GMI_Reservation_Util.PrintLn('(opm_dbg) Entering Lock_Row : line_id='||p_mo_line_rec.line_id);

OPEN c_lock_mol(p_mo_line_rec.line_id);
GMI_Reservation_Util.PrintLn('(opm_dbg) Entering Lock_Row :');
FETCH c_lock_mol
    INTO    l_mo_line_rec.attribute1
    ,       l_mo_line_rec.attribute10
    ,       l_mo_line_rec.attribute11
    ,       l_mo_line_rec.attribute12
    ,       l_mo_line_rec.attribute13
    ,       l_mo_line_rec.attribute14
    ,       l_mo_line_rec.attribute15
    ,       l_mo_line_rec.attribute2
    ,       l_mo_line_rec.attribute3
    ,       l_mo_line_rec.attribute4
    ,       l_mo_line_rec.attribute5
    ,       l_mo_line_rec.attribute6
    ,       l_mo_line_rec.attribute7
    ,       l_mo_line_rec.attribute8
    ,       l_mo_line_rec.attribute9
    ,       l_mo_line_rec.attribute_category
    ,       l_mo_line_rec.created_by
    ,       l_mo_line_rec.creation_date
    ,       l_mo_line_rec.date_required
    ,       l_mo_line_rec.from_locator_id
    ,       l_mo_line_rec.from_subinventory_code
    ,       l_mo_line_rec.from_subinventory_id
    ,       l_mo_line_rec.header_id
    ,       l_mo_line_rec.inventory_item_id
    ,       l_mo_line_rec.last_updated_by
    ,       l_mo_line_rec.last_update_date
    ,       l_mo_line_rec.last_update_login
    ,       l_mo_line_rec.line_id
    ,       l_mo_line_rec.line_number
    ,       l_mo_line_rec.line_status
/*     ,       l_mo_line_rec.lot_number  */
    ,       l_mo_line_rec.organization_id
    ,       l_mo_line_rec.program_application_id
    ,       l_mo_line_rec.program_id
    ,       l_mo_line_rec.program_update_date
/*     ,       l_mo_line_rec.project_id   */
    ,       l_mo_line_rec.quantity
    ,       l_mo_line_rec.quantity_delivered
    ,       l_mo_line_rec.quantity_detailed
    ,       l_mo_line_rec.reason_id
    ,       l_mo_line_rec.reference
    ,       l_mo_line_rec.reference_id
    ,       l_mo_line_rec.reference_type_code
    ,       l_mo_line_rec.request_id
/*     ,       l_mo_line_rec.revision  */
/*     ,       l_mo_line_rec.serial_number_end  */
/*     ,       l_mo_line_rec.serial_number_start  */
    ,       l_mo_line_rec.status_date
/*     ,       l_mo_line_rec.task_id  */
    ,       l_mo_line_rec.to_account_id
    ,       l_mo_line_rec.to_locator_id
    ,       l_mo_line_rec.to_subinventory_code
    ,       l_mo_line_rec.to_subinventory_id
    ,       l_mo_line_rec.transaction_header_id
    ,       l_mo_line_rec.uom_code
    ,	    l_mo_line_rec.transaction_type_id
    ,	    l_mo_line_rec.transaction_source_type_id
    ,	    l_mo_line_rec.txn_source_id
    ,	    l_mo_line_rec.txn_source_line_id
    ,	    l_mo_line_rec.txn_source_line_detail_id
    ,	    l_mo_line_rec.to_organization_id
    ,	    l_mo_line_rec.primary_quantity
    ,	    l_mo_line_rec.pick_strategy_id
    ,	    l_mo_line_rec.put_away_strategy_id
    ,       l_mo_line_rec.lot_no
    ,       l_mo_line_rec.sublot_no
    ,       l_mo_line_rec.qc_grade
    ,       l_mo_line_rec.secondary_quantity
    ,       l_mo_line_rec.secondary_uom_code
    ,       l_mo_line_rec.secondary_quantity_delivered
    ,      l_mo_line_rec.secondary_quantity_detailed
-- HW BUG#:2296620 added ship_set_id
    ,      l_mo_line_rec.ship_set_id;

       GMI_Reservation_Util.PrintLn('(opm_dbg) in Lock_Row : after select.');
    /*   Row locked. Compare IN attributes to DB attributes.   */
    IF ( c_lock_mol%NOTFOUND
      OR SQLCODE = -54 )
    THEN
       CLOSE c_lock_mol;
       GMI_Reservation_Util.PrintLn('(opm_dbg) Lock_Row : the MO_line is locked for line_id='||p_mo_line_rec.line_id||', SQL_CODE='||SQLCODE);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE c_lock_mol;

    x_mo_line_rec                   := l_mo_line_rec;

    /*   Set return status  */

    x_return_status                := FND_API.G_RET_STS_SUCCESS;
    x_mo_line_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
       GMI_Reservation_Util.PrintLn('(opm_dbg) excp Lock_Row : the MO_line is NOTFOUND   line_id='||p_mo_line_rec.line_id||', SQL_CODE='||SQLCODE);

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_mo_line_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

       GMI_Reservation_Util.PrintLn('(opm_dbg) excp Lock_Row : the MO_line is locked for line_id='||p_mo_line_rec.line_id||', SQL_CODE='||SQLCODE);
        x_return_status                := '54';
        x_mo_line_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN
       GMI_Reservation_Util.PrintLn('(opm_dbg) excp Lock_Row : the MO_line is OTHERS   line_id='||p_mo_line_rec.line_id||', SQL_CODE='||SQLCODE);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        x_mo_line_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

/*   Function Get_Values  */
/*

FUNCTION Get_Values
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec
,   p_old_mo_line_rec                IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec :=
                                        INV_Move_Order_PUB.G_MISS_mo_line_rec
) RETURN INV_Move_Order_PUB.Trolin_Val_Rec_Type
IS
l_trolin_val_rec              INV_Move_Order_PUB.Trolin_Val_Rec_Type;
BEGIN

    IF p_mo_line_rec.from_locator_id IS NOT NULL AND
        p_mo_line_rec.from_locator_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.from_locator_id,
        p_old_mo_line_rec.from_locator_id)
    THEN
        l_trolin_val_rec.from_locator := INV_Id_To_Value.From_Locator
        (   p_from_locator_id             => p_mo_line_rec.from_locator_id
        );
    END IF;

--     IF p_mo_line_rec.from_subinventory_code IS NOT NULL AND
--         p_mo_line_rec.from_subinventory_code <> FND_API.G_MISS_CHAR AND
--         NOT INV_GLOBALS.Equal(p_mo_line_rec.from_subinventory_code,
--         p_old_mo_line_rec.from_subinventory_code)
--     THEN
--         l_trolin_val_rec.from_subinventory := INV_Id_To_Value.From_Subinventory
--         (   p_from_subinventory_code      => p_mo_line_rec.from_subinventory_code
--         );
--     END IF;  -- Generated
--  Line 2167
    IF p_mo_line_rec.from_subinventory_id IS NOT NULL AND
        p_mo_line_rec.from_subinventory_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.from_subinventory_id,
        p_old_mo_line_rec.from_subinventory_id)
    THEN
        l_trolin_val_rec.from_subinventory := INV_Id_To_Value.From_Subinventory
        (   p_from_subinventory_id        => p_mo_line_rec.from_subinventory_id
        );
--         (   p_from_subinventory_id        => p_mo_line_rec.from_subinventory_id
--         );
    END IF;

    IF p_mo_line_rec.header_id IS NOT NULL AND
        p_mo_line_rec.header_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.header_id,
        p_old_mo_line_rec.header_id)
    THEN
        l_trolin_val_rec.header := INV_Id_To_Value.Header
        (   p_header_id                   => p_mo_line_rec.header_id
        );
    END IF;

    IF p_mo_line_rec.inventory_item_id IS NOT NULL AND
        p_mo_line_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.inventory_item_id,
        p_old_mo_line_rec.inventory_item_id)
    THEN
        l_trolin_val_rec.inventory_item := INV_Id_To_Value.Inventory_Item
        (   p_inventory_item_id           => p_mo_line_rec.inventory_item_id
        );
    END IF;

    IF p_mo_line_rec.line_id IS NOT NULL AND
        p_mo_line_rec.line_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.line_id,
        p_old_mo_line_rec.line_id)
    THEN
        l_trolin_val_rec.line := INV_Id_To_Value.Line
        (   p_line_id                     => p_mo_line_rec.line_id
        );
    END IF;

    IF p_mo_line_rec.organization_id IS NOT NULL AND
        p_mo_line_rec.organization_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.organization_id,
        p_old_mo_line_rec.organization_id)
    THEN
        l_trolin_val_rec.organization := INV_Id_To_Value.Organization
        (   p_organization_id             => p_mo_line_rec.organization_id
        );
    END IF;

    IF p_mo_line_rec.to_organization_id IS NOT NULL AND
        p_mo_line_rec.to_organization_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.to_organization_id,
        p_old_mo_line_rec.to_organization_id)
    THEN
        l_trolin_val_rec.to_organization := INV_Id_To_Value.To_Organization
        (   p_to_organization_id             => p_mo_line_rec.to_organization_id
        );
    END IF;

    IF p_mo_line_rec.project_id IS NOT NULL AND
        p_mo_line_rec.project_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.project_id,
        p_old_mo_line_rec.project_id)
    THEN
        l_trolin_val_rec.project := INV_Id_To_Value.Project
        (   p_project_id                  => p_mo_line_rec.project_id
        );
    END IF;

    IF p_mo_line_rec.reason_id IS NOT NULL AND
        p_mo_line_rec.reason_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.reason_id,
        p_old_mo_line_rec.reason_id)
    THEN
        l_trolin_val_rec.reason := INV_Id_To_Value.Reason
        (   p_reason_id                   => p_mo_line_rec.reason_id
        );
    END IF;

    IF p_mo_line_rec.reference_id IS NOT NULL AND
        p_mo_line_rec.reference_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.reference_id,
        p_old_mo_line_rec.reference_id)
    THEN
        l_trolin_val_rec.reference := INV_Id_To_Value.Reference
        (   p_reference_id                => p_mo_line_rec.reference_id
        );
    END IF;

    IF p_mo_line_rec.reference_type_code IS NOT NULL AND
        p_mo_line_rec.reference_type_code <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.reference_type_code,
        p_old_mo_line_rec.reference_type_code)
    THEN
        l_trolin_val_rec.reference_type := INV_Id_To_Value.Reference_Type
        (   p_reference_type_code         => p_mo_line_rec.reference_type_code
        );
    END IF;

    IF p_mo_line_rec.task_id IS NOT NULL AND
        p_mo_line_rec.task_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.task_id,
        p_old_mo_line_rec.task_id)
    THEN
        l_trolin_val_rec.task := INV_Id_To_Value.Task
        (   p_task_id                     => p_mo_line_rec.task_id
        );
    END IF;

    IF p_mo_line_rec.to_account_id IS NOT NULL AND
        p_mo_line_rec.to_account_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.to_account_id,
        p_old_mo_line_rec.to_account_id)
    THEN
        l_trolin_val_rec.to_account := INV_Id_To_Value.To_Account
        (  p_to_account_id               => p_mo_line_rec.to_account_id
        );
    END IF;

    IF p_mo_line_rec.to_locator_id IS NOT NULL AND
        p_mo_line_rec.to_locator_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.to_locator_id,
        p_old_mo_line_rec.to_locator_id)
    THEN
        l_trolin_val_rec.to_locator := INV_Id_To_Value.To_Locator
        (   p_to_locator_id               => p_mo_line_rec.to_locator_id
        );
    END IF;

--     IF p_mo_line_rec.to_subinventory_code IS NOT NULL AND
--         p_mo_line_rec.to_subinventory_code <> FND_API.G_MISS_CHAR AND
--         NOT INV_GLOBALS.Equal(p_mo_line_rec.to_subinventory_code,
--         p_old_mo_line_rec.to_subinventory_code)
--     THEN
--         l_trolin_val_rec.to_subinventory := INV_Id_To_Value.To_Subinventory
--         (   p_to_subinventory_code        => p_mo_line_rec.to_subinventory_code
--         );
--     END IF; -- Generated

    IF p_mo_line_rec.to_subinventory_id IS NOT NULL AND
        p_mo_line_rec.to_subinventory_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.to_subinventory_id,
        p_old_mo_line_rec.to_subinventory_id)
    THEN
        l_trolin_val_rec.to_subinventory := INV_Id_To_Value.To_Subinventory
        (   p_to_subinventory_id          => p_mo_line_rec.to_subinventory_id
        );
    END IF;

    IF p_mo_line_rec.transaction_header_id IS NOT NULL AND
        p_mo_line_rec.transaction_header_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.transaction_header_id,
        p_old_mo_line_rec.transaction_header_id)
    THEN
        l_trolin_val_rec.transaction_header := INV_Id_To_Value.Transaction_Header
        (   p_transaction_header_id       => p_mo_line_rec.transaction_header_id
        );
    END IF;

    IF p_mo_line_rec.transaction_type_id IS NOT NULL AND
        p_mo_line_rec.transaction_type_id <> FND_API.G_MISS_NUM AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.transaction_type_id,
        p_old_mo_line_rec.transaction_type_id)
    THEN
        l_trolin_val_rec.transaction_type := INV_Id_To_Value.Transaction_type
        (   p_transaction_type_id       => p_mo_line_rec.transaction_type_id
        );
    END IF;

    IF p_mo_line_rec.uom_code IS NOT NULL AND
        p_mo_line_rec.uom_code <> FND_API.G_MISS_CHAR AND
        NOT INV_GLOBALS.Equal(p_mo_line_rec.uom_code,
        p_old_mo_line_rec.uom_code)
    THEN
        l_trolin_val_rec.uom := INV_Id_To_Value.Uom
        (   p_uom_code                    => p_mo_line_rec.uom_code
        );
    END IF;

    RETURN l_trolin_val_rec;

END Get_Values;

--   Function Get_Ids

FUNCTION Get_Ids
(   p_mo_line_rec                    IN  GMI_MOVE_ORDER_GLOBAL.mo_line_rec
,   p_trolin_val_rec                IN  INV_Move_Order_PUB.Trolin_Val_Rec_Type
) RETURN GMI_MOVE_ORDER_GLOBAL.mo_line_rec
IS
l_mo_line_rec                  GMI_MOVE_ORDER_GLOBAL.mo_line_rec;
BEGIN

    --   initialize  return_status.

    l_mo_line_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --   initialize l_mo_line_rec.

    l_mo_line_rec := p_mo_line_rec;

    IF  p_trolin_val_rec.from_locator <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.from_locator_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.from_locator_id := p_mo_line_rec.from_locator_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','from_locator');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.from_locator_id := INV_Value_To_Id.from_locator
            (   p_organizatoin_id             => p_mo_line_rec.organization_id,
                p_from_locator                => p_trolin_val_rec.from_locator
            );

            IF l_mo_line_rec.from_locator_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.from_subinventory <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.from_subinventory_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.from_subinventory_id := p_mo_line_rec.from_subinventory_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','from_subinventory');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.from_subinventory_id := INV_Value_To_Id.from_subinventory
            (   p_organization_id             => p_mo_line_rec.organization_id,
                p_from_subinventory           => p_trolin_val_rec.from_subinventory
            );

            IF l_mo_line_rec.from_subinventory_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.header <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.header_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.header_id := p_mo_line_rec.header_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.header_id := INV_Value_To_Id.header
            (   p_header                      => p_trolin_val_rec.header
            );

            IF l_mo_line_rec.header_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.inventory_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.inventory_item_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.inventory_item_id := p_mo_line_rec.inventory_item_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.inventory_item_id := INV_Value_To_Id.inventory_item
            (   p_organization_id             => p_mo_line_rec.organization_id,
                p_inventory_item              => p_trolin_val_rec.inventory_item
            );

            IF l_mo_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.line <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.line_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.line_id := p_mo_line_rec.line_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.line_id := INV_Value_To_Id.line
            (   p_line                        => p_trolin_val_rec.line
            );

            IF l_mo_line_rec.line_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.organization <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.organization_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.organization_id := p_mo_line_rec.organization_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.organization_id := INV_Value_To_Id.organization
            (   p_organization                => p_trolin_val_rec.organization
            );

            IF l_mo_line_rec.organization_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.to_organization <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.to_organization_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.to_organization_id := p_mo_line_rec.to_organization_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_organization');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.to_organization_id := INV_Value_To_Id.to_organization
            (   p_to_organization                => p_trolin_val_rec.to_organization
            );

            IF l_mo_line_rec.to_organization_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
    IF  p_trolin_val_rec.project <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.project_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.project_id := p_mo_line_rec.project_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.project_id := INV_Value_To_Id.project
            (   p_project                     => p_trolin_val_rec.project
            );

            IF l_mo_line_rec.project_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.reason_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.reason_id := p_mo_line_rec.reason_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reason');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.reason_id := INV_Value_To_Id.reason
            (   p_reason                      => p_trolin_val_rec.reason
            );

            IF l_mo_line_rec.reason_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.reference <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.reference_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.reference_id := p_mo_line_rec.reference_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reference');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.reference_id := INV_Value_To_Id.reference
            (   p_reference                   => p_trolin_val_rec.reference
            );

            IF l_mo_line_rec.reference_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.reference_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.reference_type_code <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.reference_type_code := p_mo_line_rec.reference_type_code;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reference_type');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.reference_type_code := INV_Value_To_Id.reference_type
            (   p_reference_type              => p_trolin_val_rec.reference_type
            );

            IF l_mo_line_rec.reference_type_code = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.task <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.task_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.task_id := p_mo_line_rec.task_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.task_id := INV_Value_To_Id.task
            (   p_task                        => p_trolin_val_rec.task
            );

            IF l_mo_line_rec.task_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.to_account <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.to_account_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.to_account_id := p_mo_line_rec.to_account_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_account');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.to_account_id := INV_Value_To_Id.to_account
            (  p_organization_id             => p_mo_line_rec.organization_id,
               p_to_account                  => p_trolin_val_rec.to_account
            );

            IF l_mo_line_rec.to_account_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.to_locator <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.to_locator_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.to_locator_id := p_mo_line_rec.to_locator_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_locator');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.to_locator_id := INV_Value_To_Id.to_locator
            (   p_to_locator                  => p_trolin_val_rec.to_locator
            );

            IF l_mo_line_rec.to_locator_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.to_subinventory <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.to_subinventory_code <> FND_API.G_MISS_CHAR THEN

            l_mo_line_rec.to_subinventory_code := p_mo_line_rec.to_subinventory_code;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_subinventory');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.to_subinventory_code := INV_Value_To_Id.to_subinventory
            (   p_organization_id             => p_mo_line_rec.organization_id,
                p_to_subinventory             => p_trolin_val_rec.to_subinventory
            );

            IF l_mo_line_rec.to_subinventory_code = FND_API.G_MISS_CHAR THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
--  Line2839
    IF  p_trolin_val_rec.to_subinventory <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.to_subinventory_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.to_subinventory_id := p_mo_line_rec.to_subinventory_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_subinventory');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.to_subinventory_id := INV_Value_To_Id.to_subinventory
            (   p_organization_id             => p_mo_line_rec.organization_id,
                p_to_subinventory             => p_trolin_val_rec.to_subinventory
            );

            IF l_mo_line_rec.to_subinventory_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_trolin_val_rec.transaction_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.transaction_header_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.transaction_header_id := p_mo_line_rec.transaction_header_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_header');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.transaction_header_id := INV_Value_To_Id.transaction_header
            (   p_transaction_header          => p_trolin_val_rec.transaction_header
            );

            IF l_mo_line_rec.transaction_header_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
    IF  p_trolin_val_rec.transaction_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.transaction_type_id <> FND_API.G_MISS_NUM THEN

            l_mo_line_rec.transaction_type_id := p_mo_line_rec.transaction_type_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_type');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_mo_line_rec.transaction_type_id := INV_Value_To_Id.transaction_type
            (   p_transaction_type          => p_trolin_val_rec.transaction_type
            );

            IF l_mo_line_rec.transaction_type_id = FND_API.G_MISS_NUM THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
--  Line2899
    IF  p_trolin_val_rec.uom <> FND_API.G_MISS_CHAR
    THEN

        IF p_mo_line_rec.uom_code <> FND_API.G_MISS_CHAR THEN

            l_mo_line_rec.uom_code := p_mo_line_rec.uom_code;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('INV','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','uom');
                FND_MSG_PUB.Add;

            END IF;

        ELSE
--  Line2917
            l_mo_line_rec.uom_code := INV_Value_To_Id.uom
            (   p_uom                         => p_trolin_val_rec.uom
            );

            IF l_mo_line_rec.uom_code = FND_API.G_MISS_CHAR THEN
                l_mo_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    RETURN l_mo_line_rec;

END Get_Ids;

*/

PROCEDURE Line_Auto_Detail
  (  p_mo_line_id                    IN    NUMBER
  ,  p_init_msg_list                 IN    NUMBER
  ,  p_transaction_header_id         IN    NUMBER
  ,  p_transaction_mode	             IN    NUMBER
  ,  p_move_order_type               IN    NUMBER
  ,  p_allow_delete	  	     IN    VARCHAR2 DEFAULT NULL
  ,  x_number_of_rows                OUT NOCOPY   NUMBER
  ,  x_qc_grade                      OUT NOCOPY   VARCHAR2
  ,  x_detailed_qty                  OUT NOCOPY   NUMBER
  ,  x_qty_UM                        OUT NOCOPY   VARCHAR2
  ,  x_detailed_qty2                 OUT NOCOPY   NUMBER
  ,  x_qty_UM2                       OUT NOCOPY   VARCHAR2
  ,  x_return_status                 OUT NOCOPY   VARCHAR2
  ,  x_msg_count                     OUT NOCOPY   NUMBER
  ,  x_msg_data                      OUT NOCOPY   VARCHAR2
)
IS
l_api_version_number          CONSTANT NUMBER      := 1.0;
l_init_msg_list               VARCHAR2(255) := FND_API.G_TRUE;
l_api_name                    CONSTANT VARCHAR2(30) := 'Line_Auto_Detail';
l_detailed_qty                NUMBER               := 0;
l_ser_index                   NUMBER;
l_expiration_date             DATE;
x_success                     NUMBER;
l_transfer_to_location	      NUMBER;
l_lot_number		      NUMBER;
l_locator_id		      NUMBER;
l_transaction_temp_id	      NUMBER;
l_transaction_header_id       NUMBER;
l_subinventory_code	      VARCHAR2(30);
l_transaction_quantity 	      NUMBER;
l_primary_quantity	      NUMBER;
l_inventory_item_id	      NUMBER;
l_temp_id		      NUMBER;
l_serial_number		      VARCHAR2(30);

l_mtl_reservation	      INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE;
l_mo_hdr_rec	              GMI_Move_Order_Global.mo_hdr_rec;
l_mo_line_tbl                 GMI_Move_Order_Global.mo_line_tbl;
l_mo_line_rec                 GMI_Move_Order_Global.mo_line_rec;
ll_mo_line_rec                GMI_Move_Order_Global.mo_line_rec;
l_default_lot_index           NUMBER;

l_pick_release_status 	      INV_PICK_RELEASE_PUB.INV_RELEASE_STATUS_Tbl_Type;
l_return_status		      VARCHAR2(1);
l_mold_tbl		      INV_MO_LINE_DETAIL_UTIL.g_mmtt_tbl_type;
l_mold_tbl_temp		      INV_MO_LINE_DETAIL_UTIL.g_mmtt_tbl_type;
l_message                     VARCHAR2(2000);
l_count				NUMBER;
l_from_serial_number	      VARCHAR2(30);
l_to_serial_number	      VARCHAR2(30);
l_detail_rec_count	      NUMBER;
l_success		      NUMBER;
l_auto_pick_flag	      VARCHAR2(1);
l_request_number	      VARCHAR2(80);
l_commit		      VARCHAR2(1);
l_p_allow_delete	      VARCHAR2(3);

/* Default Rules : */
l_ps_mode                 VARCHAR2(1);
l_default_autodetail      VARCHAR2(1);
l_default_autocreate_del  VARCHAR2(1);
l_use_header_flag         VARCHAR2(1);
l_default_to_sub      	VARCHAR2(10);
l_default_to_loc      	NUMBER;
l_pick_seq_rule_id        NUMBER;
l_pick_grouping_rule_id   NUMBER;
l_default_pickconfirm     VARCHAR2(1);

CURSOR get_default_params(v_org_id IN NUMBER) IS
SELECT NVL(PRINT_PICK_SLIP_MODE, 'E'),
       AUTODETAIL_PR_FLAG,
       NVL(AUTOCREATE_DELIVERIES_FLAG, 'N'),
       NVL(AUTOCREATE_DEL_ORDERS_FLAG, 'Y'),
       DEFAULT_STAGE_SUBINVENTORY,
       DEFAULT_STAGE_LOCATOR_ID,
       PICK_SEQUENCE_RULE_ID,
       PICK_GROUPING_RULE_ID
FROM   WSH_SHIPPING_PARAMETERS
WHERE  ORGANIZATION_ID = v_org_id;

CURSOR get_default_confirm(v_org_id IN NUMBER) IS
SELECT DECODE(MO_PICK_CONFIRM_REQUIRED, 2, 'Y', 'N')
FROM   MTL_PARAMETERS
WHERE  ORGANIZATION_ID = v_org_id;


BEGIN

GMI_Reservation_Util.PrintLn('(opm_dbg) Entering Line_Auto_Detail.');

    /*  Init status :  */
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IF (p_init_msg_list = 1)
    THEN
       FND_MSG_PUB.Initialize;
    END IF;

GMI_Reservation_Util.PrintLn('(opm_dbg) Line_Auto_Detail after init Mesg. mo_type='||p_move_order_type||', mo_line_id='||p_mo_line_id);
    /*  check what is the move order type. If it's a non pick wave mo, */
    /*  call the pick engine, otherwise, call the pick release api   */
    /*  call directed pick and put away api  */
    IF ( p_move_order_type = 3 )
    THEN
/*  Get The Move Order line (1 line)  */
        l_mo_line_tbl(1) := GMI_Move_Order_Line_Util.Query_Row( p_mo_line_id);

        l_mo_line_rec.line_id := p_mo_line_id;

        GMI_Move_Order_Line_Util.Lock_Row(
               p_mo_line_rec   => l_mo_line_rec
             , x_mo_line_rec   => ll_mo_line_rec
             , x_return_status => x_return_status);

        IF ( x_return_status = '54' )
        THEN
           GMI_Reservation_Util.PrintLn('(opm_dbg) Line_Auto_Detail : the MO is locked for line_id='||p_mo_line_id);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

GMI_Reservation_Util.PrintLn('(opm_dbg) mo_header_id ='||l_mo_line_tbl(1).header_id||', schedule_ship_date(date_required)='||l_mo_line_tbl(1).date_required);
	/*  Get The Move Order header  */
        l_mo_hdr_rec := GMI_Move_Order_Header_Util.Query_Row( l_mo_line_tbl(1).header_id);

        /* B1513119 23-Nov-2000 odaboval : Added the grouping rules */
        /* Get defaults for organization */
        OPEN get_default_params(l_mo_line_tbl(1).organization_id);
        FETCH get_default_params
        INTO  l_ps_mode,
              l_default_autodetail,
              l_default_autocreate_del,
              l_use_header_flag,
              l_default_to_sub,
              l_default_to_loc,
              l_pick_seq_rule_id,
              l_pick_grouping_rule_id;
        CLOSE get_default_params;

        OPEN get_default_confirm(l_mo_line_tbl(1).organization_id);
        FETCH get_default_confirm
        INTO  l_default_pickconfirm;
        CLOSE get_default_confirm;

        l_mo_hdr_rec.grouping_rule_id := l_pick_grouping_rule_id;

/*
	BEGIN
	   select auto_pick_confirm_flag
	   into l_auto_pick_flag
	   from wsh_picking_batches
	   where name = l_request_number;

	   IF ( l_auto_pick_flag is null ) THEN
		l_auto_pick_flag := 'Y';
	   END IF;
	   GMI_Reservation_Util.PrintLn('(opm_dbg) l_auto_pick_flag is ' || l_auto_pick_flag);
        EXCEPTION
	   WHEN no_data_found THEN
		fnd_message.set_name('INV', 'INV_AUTO_PICK_CONFIRM_PARAM');
		fnd_msg_pub.add;
		raise fnd_api.g_exc_unexpected_error;
	END;
*/
	SAVEPOINT GMI_Before_Pick_Release;
/* 	IF ( l_auto_pick_flag = 'Y') THEN
 	    l_commit := FND_API.G_TRUE;
 	ELSE
*/
l_commit := FND_API.G_FALSE;
/* 	END IF;   */



	l_p_allow_delete := p_allow_delete;
GMI_Reservation_Util.PrintLn('(opm_dbg) l_p_allow_delete = ' || l_p_allow_delete) ;
GMI_Reservation_Util.PrintLn('(opm_dbg) Before calling Auto_detail ='||l_mo_line_tbl(1).header_id);
        GMI_Pick_Release_PUB.Auto_Detail(
	    p_api_version            => 1.0,
	    p_init_msg_lst           => FND_API.G_FALSE,
	    p_commit                 => l_commit,
	    p_mo_hdr_rec             => l_mo_hdr_rec,
	    p_mo_line_tbl            => l_mo_line_tbl,
	    p_grouping_rule_id       => l_mo_hdr_rec.grouping_rule_id,
	    p_allow_delete           => l_p_allow_delete,
	    x_pick_release_status    => l_pick_release_status,
	    x_return_status          => l_return_status,
	    x_msg_data               => x_msg_data,
	    x_msg_count              => x_msg_count);

        GMI_Reservation_Util.PrintLn('(opm_dbg) l_return_status from GMI_pick_release_pub.Auto_detail is ' || l_return_status);
        /* Message('l_return_status from GMI_pick_release_pub.Auto_detail is ' || l_return_status);  */

  	if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	    GMI_Reservation_Util.PrintLn('return error');
/*      fnd_msg_pub.count_and_get(p_count => l_count,
				      p_data => l_message,
				      p_encoded => 'F');
	    if( l_count = 0) then
		GMI_Reservation_Util.PrintLn('(opm_dbg) no message return');
	    else
		for I in 1..l_count LOOP
		l_message := fnd_msg_pub.get(I, 'F');
		GMI_Reservation_Util.PrintLn(l_message);
		end LOOP;
	    end if;
*/

	    raise FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;

	GMI_Reservation_Util.PrintLn('(opm_dbg) l_prick_release_status.count='||l_pick_release_status.count);

        x_number_of_rows := 0;
  	IF ( l_pick_release_status.count > 0 ) THEN
            FOR l_index IN 1..l_pick_release_status.count LOOP
                GMI_Reservation_Util.PrintLn('(opm_dbg) detail record loop pick_return_status=' || l_pick_release_status(l_index).return_status);
                x_number_of_rows := x_number_of_rows + l_pick_release_status(l_index).detail_rec_count;
                IF (l_pick_release_status(l_index).return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                   l_return_status := l_pick_release_status(l_index).return_status;
                END IF;
            END LOOP;
	    GMI_Reservation_Util.PrintLn('(opm_dbg) Transaction row count=' || x_number_of_rows);
	END IF;
        GMI_Reservation_Util.PrintLn('(opm_dbg) after Checking the Pick_Release_rectype NO Error');


	if( l_detail_rec_count > 0 and l_auto_pick_flag = 'Y') then
            /*  comment this out since it will take a long time to do
                  pick release if we wait this print pick slip
             */
	    commit;
	    GMI_Reservation_Util.PrintLn('(opm_dbg) auto pick confirm');

/* odab  Keep this for the Pick Slip
	    for l_index in 1..l_trolin_tbl.count LOOP
	        GMI_Reservation_Util.PrintLn('get mold');
		l_mold_tbl := INV_MO_LINE_DETAIL_UTIL.query_rows(
				p_line_id => l_trolin_tbl(l_index).line_id);
		l_mold_tbl_temp := l_mold_tbl;
		if( l_mold_tbl.count = 0 ) then
		    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		    fnd_message.set_name('INV', 'INV_PICK_RELEASE_ERROR');
		    fnd_msg_pub.add;
	            raise FND_API.G_EXC_UNEXPECTED_ERROR;
		else
	            GMI_Reservation_Util.PrintLn('number of mold record is ' || l_mold_tbl.count);
		    GMI_Reservation_Util.PrintLn('calling pick confirm');
	            INV_PICK_WAVE_PICK_CONFIRM_PUB.Pick_Confirm(
	               p_api_version_number    => 1.0,
	               p_init_msg_list         => FND_API.G_FALSE,
	               p_commit                => FND_API.G_TRUE,
	               x_return_status         => l_return_status,
	               x_msg_count             => x_msg_count,
	               x_msg_data	       => x_msg_data,
	               p_move_order_type       => p_move_order_type,
		       p_transaction_mode      => 1,
	               p_trolin_tbl            => l_trolin_tbl,
	               p_mold_tbl              => l_mold_tbl,
	               x_mmtt_tbl              => l_mold_tbl,
	               x_trolin_tbl            => l_trolin_tbl);
		    GMI_Reservation_Util.PrintLn('after pick confirm with return status = ' || l_return_status);
	            GMI_Reservation_Util.PrintLn('l_return_status = ' || l_return_status);
		    if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
			l_success := 0;
		       GMI_Reservation_Util.PrintLn('rollback changes');
		       GMI_Reservation_Util.PrintLn('l_mold_tbl_temp.count = ' || l_mold_tbl_temp.count);
		       for l_index in 1..l_mold_tbl_temp.count LOOP
			  GMI_Reservation_Util.PrintLn('calling delete details');
		          INV_Replenish_Detail_PUB.Delete_Details(
			     p_transaction_temp_id => l_mold_tbl_temp(l_index).transaction_temp_id,
			     p_move_order_line_id  => l_mold_tbl_temp(l_index).move_order_line_id,
			     p_reservation_id	   => l_mold_tbl_temp(l_index).reservation_id,
			     p_transaction_quantity => l_mold_tbl_temp(l_index).transaction_quantity,
			     p_primary_trx_qty	   => l_mold_tbl_temp(l_index).primary_quantity,
			     x_return_status 	   => l_return_status,
			     x_msg_data	  	   => x_msg_data,
			     x_msg_count	   => x_msg_count);
			  GMI_Reservation_Util.PrintLn('after detele details with return status ' || l_return_status);
	                  if( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                             RAISE FND_API.G_EXC_ERROR;
                          END IF;
			  update mtl_txn_request_lines
			  set quantity_detailed = quantity_detailed - l_mold_tbl_temp(l_index).transaction_quantity,
			      quantity_delivered = quantity_delivered - l_mold_tbl_temp(l_index).transaction_quantity
			  where line_id = l_mold_tbl_temp(l_index).move_order_line_id;
		       end loop;
		       update mtl_txn_request_lines
		       set line_status = 7
		       where line_id = p_mo_line_id;
		       commit;
		    else
			l_success := 1;
		    end if;
	            x_return_status := l_return_status;
		    GMI_Reservation_Util.PrintLn('return status is ' || l_return_status);
		end if;
	        x_return_status := l_return_status;
	     end loop;
odab  Keep this for the Pick Slip */

	 END IF;
   END IF;

/* =============================================================================
  Prepare to retrieve the return value :
  Need the default lot index,
    and if the item is loct_ctl or lot_ctl
============================================================================ */
GMI_Reservation_Util.Get_DefaultLot_from_ItemCtl
         ( p_organization_id          => l_mo_line_tbl(1).organization_id
         , p_inventory_item_id        => l_mo_line_tbl(1).inventory_item_id
         , x_default_lot_index        => l_default_lot_index
         , x_return_status            => x_return_status
         , x_msg_count                => x_msg_count
         , x_msg_data                 => x_msg_data);



/*  ==================================================================
  Set the Returned values from the GMI_Reservation_Util.ic_tran_rec_tbl
 ================================================================== */
x_detailed_qty  := 0;
x_detailed_qty2 := 0;
FOR l_count IN 1..GMI_Reservation_Util.ic_tran_rec_tbl.COUNT
LOOP
   IF (l_count <> l_default_lot_index)
   THEN
      x_detailed_qty  := x_detailed_qty - GMI_Reservation_Util.ic_tran_rec_tbl(l_count).trans_qty;
      x_qty_UM        := GMI_Reservation_Util.ic_tran_rec_tbl(l_count).trans_UM;
      x_detailed_qty2 := x_detailed_qty2 - GMI_Reservation_Util.ic_tran_rec_tbl(l_count).trans_qty2;
      x_qty_UM2       := GMI_Reservation_Util.ic_tran_rec_tbl(l_count).trans_UM2;
      x_qc_grade      := GMI_Reservation_Util.ic_tran_rec_tbl(l_count).qc_grade;
   END IF;
END LOOP;

/* ==================================================================
  Set the Returned values from the GMI_Reservation_Util.ic_tran_rec_tbl
 ==================================================================  */
GMI_Reservation_Util.PrintLn('In Reallocate : default_lot_index='||l_default_lot_index||', detail_qty='||x_detailed_qty||', mo_line_id='||l_mo_line_tbl(1).line_id);

update ic_txn_request_lines
set quantity_detailed = x_detailed_qty
  , secondary_quantity_detailed = x_detailed_qty2
where line_id = l_mo_line_tbl(1).line_id;

l_success := 1;
	if( l_success = 1 ) then
	    x_return_status := FND_API.G_RET_STS_SUCCESS;
	else
	    raise FND_API.G_EXC_ERROR;
	end if;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_return_status = '54')
        THEN
           x_return_status := '54' ;
        ELSE
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        END IF;

        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Details_PUB'
            );
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

END Line_Auto_Detail;

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
  )
IS
l_api_version_number          CONSTANT NUMBER      := 1.0;
l_init_msg_list               VARCHAR2(255) := FND_API.G_TRUE;
l_api_name                    CONSTANT VARCHAR2(30) := 'Line_Pick_Confirm';
x_success                     NUMBER;

l_mo_hdr_rec	              GMI_Move_Order_Global.mo_hdr_rec;
l_mo_line_tbl                 GMI_Move_Order_Global.mo_line_tbl;
-- HW OPM changes for NOCOPY
ll_mo_line_tbl                 GMI_Move_Order_Global.mo_line_tbl;
l_mo_line_rec                 GMI_Move_Order_Global.mo_line_rec;
ll_mo_line_rec                GMI_Move_Order_Global.mo_line_rec;

l_return_status		      VARCHAR2(1);
l_grouping_rule_id	      NUMBER;
l_count				NUMBER;
l_detail_rec_count	      NUMBER;
l_success		      NUMBER;
l_request_number	      VARCHAR2(80);
l_commit		      VARCHAR2(1);


BEGIN

    gmi_reservation_util.println('In line_pick_confirm and line_id is '||p_mo_line_id);
    /*  Init status :  */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_init_msg_list = 1)
    THEN
       FND_MSG_PUB.Initialize;
    END IF;

    /*  check what is the move order type. If it's a non pick wave mo,
      call the pick engine, otherwise, call the pick release api
      call directed pick and put away api
    */
    IF ( p_move_order_type = 3 )
    THEN
     gmi_reservation_util.println('Move Order type is 3');
	/*  Get The Move Order line (1 line)  */
	gmi_reservation_util.println('Going to query the row with id = '||p_mo_line_id);
        l_mo_line_tbl(1) := GMI_Move_Order_Line_Util.Query_Row( p_mo_line_id);


        l_mo_line_rec.line_id := p_mo_line_id;
        gmi_reservation_util.println('Value of l_mo_line_rec.line_id using to lock row is '||l_mo_line_rec.line_id);
        GMI_Move_Order_Line_Util.Lock_Row(
               p_mo_line_rec   => l_mo_line_rec
             , x_mo_line_rec   => ll_mo_line_rec
             , x_return_status => x_return_status);

        IF ( x_return_status = '54' )
        THEN
           GMI_Reservation_Util.PrintLn('(opm_dbg) Line_Pick_Confirm : the MO is locked for line_id='||p_mo_line_id);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


GMI_Reservation_Util.PrintLn('(opm_dbg) mo_header_id ='||l_mo_line_tbl(1).header_id);
GMI_Reservation_Util.PrintLn('(opm_dbg) mo_line_tbl.COUNT ='||l_mo_line_tbl.COUNT);

	SAVEPOINT GMI_Before_Pick_Confirm;
        l_commit := FND_API.G_FALSE;

        GMI_Reservation_Util.PrintLn('(opm_dbg) Before calling Pick_Confirm ='||l_mo_line_tbl(1).header_id);
/* NC 11/14/02  changed the call from GMI_Pick_Wave_Confirm_PUB
   to GMI_Pick_Wave_Confirm_PVT.  enhancement # 2557029 */

        GMI_Pick_Wave_Confirm_PVT.Pick_Confirm(
            p_api_version_number     => 1.0,
            p_init_msg_lst           => FND_API.G_FALSE,
            p_validation_flag        => FND_API.G_VALID_LEVEL_FULL,
            p_commit                 => l_commit,
            p_mo_line_tbl            => l_mo_line_tbl,
            x_mo_line_tbl            => ll_mo_line_tbl,
            x_return_status          => l_return_status,
            x_msg_data               => x_msg_data,
            x_msg_count              => x_msg_count);


        GMI_Reservation_Util.PrintLn('(opm_dbg) l_return_status from GMI_pick_wave_Confirm_pub.Pick_Confirm is ' || l_return_status);
        GMI_Reservation_Util.PrintLn('(opm_dbg) mo_line.count=' || l_mo_line_tbl.count);
        /* Message('l_return_status from GMI_pick_release_pub.Auto_detail is ' || l_return_status); */

  	IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
        THEN
	    GMI_Reservation_Util.PrintLn('return error');
            FND_MESSAGE.Set_Name('GMI','PICK_CONFIRM_ERROR');
            FND_MESSAGE.Set_Token('WHERE', 'AFTER_CALL_PICK_CONFIRM');
            FND_MESSAGE.Set_Token('WHAT', 'UnexpectedError');
            FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

  	IF ( l_mo_line_tbl.count = 0 )
        THEN
	    GMI_Reservation_Util.PrintLn('return error');
            FND_MESSAGE.Set_Name('GMI','PICK_CONFIRM_ERROR');
            FND_MESSAGE.Set_Token('WHERE', 'MO_LINE_COUNT_0');
            FND_MESSAGE.Set_Token('WHAT', 'UnexpectedError');
            FND_MSG_PUB.Add;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

    END IF;


GMI_Reservation_Util.PrintLn('(opm_dbg) Before setting the return value');
/* ==================================================================
  Set the Returned values from the GMI_Reservation_Util.ic_tran_rec_tbl
 ================================================================== */
x_delivered_qty  := l_mo_line_tbl(1).quantity_delivered;
GMI_Reservation_Util.PrintLn('(opm_dbg) Before setting the return value 1');
x_qty_UM         := l_mo_line_tbl(1).uom_code;
GMI_Reservation_Util.PrintLn('(opm_dbg) Before setting the return value 2');
x_delivered_qty2 := l_mo_line_tbl(1).secondary_quantity_delivered;
GMI_Reservation_Util.PrintLn('(opm_dbg) Before setting the return value 3');
x_qty_UM2        := l_mo_line_tbl(1).secondary_uom_code;

GMI_Reservation_Util.PrintLn('(opm_dbg) End of GMI_pick_wave_Confirm_pub.Pick_Confirm, l_return_status is ' || l_return_status);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
/*          ROLLBACK TO SAVEPOINT GMI_Before_Pick_Confirm;  */

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
/*          ROLLBACK TO SAVEPOINT GMI_Before_Pick_Confirm;  */

        IF (x_return_status = '54')
        THEN
           x_return_status := '54' ;
        ELSE
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Pick_Confirm');
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

END Line_Pick_Confirm;


PROCEDURE AUTO_ALLOC_CONFIRM_SRS
(
 errbuf               OUT NOCOPY     VARCHAR2,
 retcode              OUT NOCOPY     VARCHAR2,
 p_pick_confirm       IN      VARCHAR2,
 p_whse_code          IN      VARCHAR2,
 p_from_order_num     IN      NUMBER,
 p_to_order_num       IN      NUMBER,
 p_item_num           IN      VARCHAR2,
 p_cust_num           IN      VARCHAR2,
 p_from_ship_date     IN      VARCHAR2,
 p_to_ship_date       IN      VARCHAR2,
 p_log_level          IN      NUMBER
)
IS

c_order_separator      CONSTANT VARCHAR2(100) :=
  '========================================================================';

c_event_separator CONSTANT VARCHAR2(100) :=
  '------------------------------------------------------------------------';

l_init_msg_list               VARCHAR2(255) := FND_API.G_TRUE;
l_detailed_qty                NUMBER               := 0;
l_mo_line_id                  NUMBER;
l_inv_item_id                  NUMBER;
l_txn_source_line_id          NUMBER;
l_number_rows                NUMBER;
l_detailed_qty2              NUMBER;
l_qty_um                     VARCHAR2(30);
l_order_number               VARCHAR2(30);
l_line_number                NUMBER;
l_ship_date                  VARCHAR2(30);
l_qty_um2                    VARCHAR2(30);
l_qc_grade                   VARCHAR2(30);
l_return_status              VARCHAR2(1);
l_whse_code                  VARCHAR2(4);
l_msg_count                  NUMBER;
l_item_id                    NUMBER;
l_required_lines             NUMBER;
l_total_lines                NUMBER;
l_sucess_pick                NUMBER;
l_pick_fail                  NUMBER;
l_sucess_alloc               NUMBER;
l_manual_lines               NUMBER;
l_nostock                    NUMBER;
l_nostock_ind                NUMBER;
l_no_class                   NUMBER;
l_alloc_class                VARCHAR(8);
l_qty_onhand                 NUMBER;
l_qty_req                    NUMBER;
l_qty_det                    NUMBER;
l_qty_delivered              NUMBER;
l_date_required              DATE;
l_msg_data                   VARCHAR2(2000);
l_message                    VARCHAR2(2000);
l_response                   VARCHAR2(300);
l_item_no                    VARCHAR2(30);
l_completion_status          NUMBER;
l_temp                       BOOLEAN;
l_org_id                     NUMBER;
NO_LINES_FOUND               EXCEPTION;

G_PICK_CONFIRM               VARCHAR2(1);
G_ORG_ID                     NUMBER;
G_INV_ITEM_ID                NUMBER;
G_FROM_ORDER_NUM             NUMBER;
G_TO_ORDER_NUM               NUMBER;
G_SHIP_TO_ID                 NUMBER;
G_FROM_SHIP_DATE             VARCHAR2(11);
G_TO_SHIP_DATE               VARCHAR2(11);
G_NORMAL                     NUMBER :=0;
G_WARNING                    NUMBER :=1;
G_COMP_STATUS                NUMBER;

Cursor get_order_info( p_source_line_id IN NUMBER)
IS
Select h.order_number, d.line_number, d.schedule_ship_date,h.name
 From oe_order_headers_all h
    , oe_order_lines_all d
    , hr_operating_units h
 Where h.header_id  = d.header_id
 and   h.organization_id  = d.org_id
 and   d.line_id = p_source_line_id;

cursor c_inv_info IS
SELECT NVL(SUM(LOCT_ONHAND),0) - NVL(SUM(ABS(COMMIT_QTY)),0)
FROM   IC_ITEM_INV_V
WHERE  item_id = l_item_id
AND    whse_code = l_whse_code;

cursor c_item_info IS
SELECT i.item_id, i.item_no,i.alloc_class
FROM   IC_ITEM_MST i, MTL_SYSTEM_ITEMS m
WHERE  m.organization_id = l_org_id
And    m.inventory_item_id  = l_inv_item_id
AND    i.item_no = m.segment1;


-- Cusror Fetches to retrieve Internal Id's

CURSOR c_get_org_id ( l_whse_code in VARCHAR)
IS
SELECT MTL_ORGANIZATION_ID
FROM   IC_WHSE_MST
WHERE  WHSE_CODE = l_whse_code;

CURSOR c_get_inv_item_id ( l_org_id in NUMBER,l_item_no In VARCHAR)
IS
SELECT m.inventory_item_id
FROM   IC_ITEM_MST i, MTL_SYSTEM_ITEMS m
WHERE  m.organization_id = l_org_id
AND    m.segment1 = l_item_no;

CURSOR c_get_ship_to_id ( l_cust_num IN VARCHAR, l_whse_code IN VARCHAR)
IS
SELECT C.OF_SHIP_TO_SITE_USE_ID
FROM   OP_CUST_MST C, IC_WHSE_MST I, SY_ORGN_MST S
WHERE  S.ORGN_CODE = i.ORGN_CODE
AND    S.CO_CODE   = C.CO_CODE
AND    I.WHSE_CODE = l_whse_code
AND    CUST_NO     = l_cust_num;

-- Line Selection Criteria
-- Cursors

CURSOR C_get_lines_count
IS
SELECT COUNT(1)
FROM ic_txn_request_lines mo,
     oe_order_lines_all l,
     oe_order_headers_all h,
     oe_transaction_types_all ta,
     oe_transaction_types_tl tt
WHERE l.header_id = h.header_id
AND l.line_id = mo.txn_source_line_id
AND tt.transaction_type_id = ta.transaction_type_id
AND ta.transaction_type_id = h.order_type_id
AND ta.org_id = h.org_id
AND mo.line_status <> 5
AND NVL(mo.quantity_delivered,0) < mo.quantity
AND tt.language = userenv('LANG')
AND nvl(l.cancelled_flag,'N') = 'N'
AND l.ship_from_org_id = G_ORG_ID
AND h.order_number between 					--B2593897
NVL(G_FROM_ORDER_NUM,h.order_number) AND NVL(G_TO_ORDER_NUM,h.order_number)
AND NVL(G_SHIP_TO_ID,l.ship_to_org_id) = l.ship_to_org_id
AND TRUNC(l.schedule_ship_date)
between NVL(G_FROM_SHIP_DATE,TRUNC(l.schedule_ship_date))
AND NVL(G_TO_SHIP_DATE,TRUNC(l.schedule_ship_date))
AND l.inventory_item_id =  NVL(G_INV_ITEM_ID, l.inventory_item_id) --B2594191
;


CURSOR C_get_lines
IS
SELECT
       h.order_number,
       mo.line_id,
       mo.organization_id,
       mo.txn_source_line_id,
       mo.date_required,
       mo.quantity,
       mo.quantity_detailed,
       mo.quantity_delivered,
       mo.inventory_item_id
FROM ic_txn_request_lines mo,
     oe_order_lines_all l,
     oe_order_headers_all h,
     oe_transaction_types_all ta,
     oe_transaction_types_tl tt
WHERE l.header_id = h.header_id
AND l.line_id = mo.txn_source_line_id
AND tt.transaction_type_id = ta.transaction_type_id
AND ta.transaction_type_id = h.order_type_id
AND ta.org_id = h.org_id
AND mo.line_status <> 5
AND NVL(mo.quantity_delivered,0) < mo.quantity
AND tt.language = userenv('LANG')
AND nvl(l.cancelled_flag,'N') = 'N'
AND l.ship_from_org_id = G_ORG_ID
AND h.order_number between					--B2593897
NVL(G_FROM_ORDER_NUM,h.order_number) AND NVL(G_TO_ORDER_NUM,h.order_number)
AND NVL(G_SHIP_TO_ID,l.ship_to_org_id) = l.ship_to_org_id
AND TRUNC(l.schedule_ship_date)
    between NVL(G_FROM_SHIP_DATE,TRUNC(l.schedule_ship_date))
AND NVL(G_TO_SHIP_DATE,TRUNC(l.schedule_ship_date))
AND l.inventory_item_id =  NVL(G_INV_ITEM_ID, l.inventory_item_id) --B2594191

ORDER BY 1,2;

BEGIN

  IF p_log_level <> FND_API.G_MISS_NUM THEN      -- log level fix
       WSH_UTIL_CORE.Set_Log_Level(p_log_level);
       OE_DEBUG_PUB.DEBUG_ON;
       OE_DEBUG_PUB.SETDEBUGLEVEL(p_log_level);
       WSH_UTIL_CORE.Set_Log_Level(p_log_level);
  END IF;

  G_COMP_STATUS := G_NORMAL;


  WSH_UTIL_CORE.Enable_Concurrent_Log_Print;

  WSH_UTIL_CORE.PRINTMSG;
  WSH_UTIL_CORE.PRINTMSG(c_event_separator);
  WSH_UTIL_CORE.PRINTMSG('     Pick Confirm       => ' || p_pick_confirm );
  WSH_UTIL_CORE.PRINTMSG('     Inventory Org      => ' || p_whse_code);
  WSH_UTIL_CORE.PRINTMSG('     From  Order Number => ' || p_from_order_num );
  WSH_UTIL_CORE.PRINTMSG('     To    Order Number => ' || p_to_order_num );
  WSH_UTIL_CORE.PRINTMSG('     Item        Number => ' || p_item_num );
  WSH_UTIL_CORE.PRINTMSG('     Customer    Number => ' || p_cust_num );
  WSH_UTIL_CORE.PRINTMSG('     From  Ship Date    => ' || p_from_ship_date );
  WSH_UTIL_CORE.PRINTMSG('     To  Ship Date      => ' || p_to_ship_date );
  WSH_UTIL_CORE.PRINTMSG('     Debug Level        => ' || p_log_level);


  -- Lets Generate the Internal Id's For Parameters
  -- If the value is NULL we do nothing.
  -- We will always default p_pick_confirm to be N
  -- P_whse_code must be passed, all the other parameters
  -- are optional.

  OPEN c_get_org_id(p_whse_code);
  FETCH c_get_org_id INTO G_ORG_ID;
  CLOSE c_get_org_id;


  -- Set Pick Confirm Option

  G_PICK_CONFIRM := p_pick_confirm;

  IF p_from_order_num IS NULL THEN
     G_FROM_ORDER_NUM := NULL;
  ELSE
     G_FROM_ORDER_NUM := p_from_order_num;
  END IF;

  IF p_to_order_num IS NULL THEN
     G_TO_ORDER_NUM := NULL;
  ELSE
     G_TO_ORDER_NUM := p_to_order_num;
  END IF;

  IF p_from_ship_date IS NULL THEN
     G_FROM_SHIP_DATE := NULL;
  ELSE
     G_FROM_SHIP_DATE := p_from_ship_date;
  END IF;

  IF p_to_ship_date IS NULL THEN
     G_TO_SHIP_DATE := NULL;
  ELSE
     G_TO_SHIP_DATE := p_to_ship_date;
  END IF;


  IF p_cust_num IS NULL THEN
     G_SHIP_TO_ID := NULL;
  ELSE
     OPEN c_get_ship_to_id ( p_cust_num, p_whse_code);
     FETCH c_get_ship_to_id into G_SHIP_TO_ID;
     CLOSE c_get_ship_to_id;
  END IF;


  IF p_item_num is NULL THEN
     G_INV_ITEM_ID := NULL;
  ELSE
     OPEN  c_get_inv_item_id ( G_ORG_ID, p_item_num);
     FETCH c_get_inv_item_id INTO G_INV_ITEM_ID;
     CLOSE c_get_inv_item_id;
  END IF;


     WSH_UTIL_CORE.PRINTLN( '     G_ORG_ID          => ' || G_ORG_ID);
     WSH_UTIL_CORE.PRINTLN( '     G_INV_ITEM_ID     => ' || G_INV_ITEM_ID);
     WSH_UTIL_CORE.PRINTLN( '     G_FROM_ORDER_NUM  => ' || G_FROM_ORDER_NUM);
     WSH_UTIL_CORE.PRINTLN( '     G_TO_ORDER_NUM    => ' || G_TO_ORDER_NUM);
     WSH_UTIL_CORE.PRINTLN( '     G_SHIP_TO_ID      => ' || G_SHIP_TO_ID);


   FND_MSG_PUB.INITIALIZE;
   l_required_lines :=0;
   l_total_lines    :=0;
   l_sucess_pick    :=0;
   l_pick_fail      :=0;
   l_sucess_alloc   :=0;
   l_nostock        :=0;
   l_no_class       :=0;
   l_manual_lines   :=0;


   -- Determine How Many Lines We are Likely to Process
   -- Given Input Parameters

   OPEN c_get_lines_count;
       FETCH c_get_lines_count INTO l_total_lines;
   CLOSE c_get_lines_count;

   IF l_total_lines = 0 THEN
      RAISE NO_LINES_FOUND;
   ELSE
     WSH_UTIL_CORE.PRINTMSG( '     Lines Needed To Process => ' || l_total_lines);
     WSH_UTIL_CORE.PRINTMSG;
     WSH_UTIL_CORE.PRINTMSG(c_event_separator);
   END IF;

   OPEN C_get_lines;
      LOOP
       FETCH c_get_lines INTO
         l_order_number, l_mo_line_id ,l_org_id, l_txn_source_line_id,
         l_date_required,l_qty_req,l_qty_det,l_qty_delivered,l_inv_item_id;

         EXIT WHEN c_get_lines%NOTFOUND;

         l_required_lines := l_required_lines + 1;
         WSH_UTIL_CORE.PRINTMSG;
         WSH_UTIL_CORE.PRINTMSG(c_order_separator);
         WSH_UTIL_CORE.PRINTMSG('     PROCESSING LINE => '|| l_required_lines);

         WSH_UTIL_CORE.PRINTLN('     HAM DEBUGGGGGGG');

          Open get_order_info(l_txn_source_line_id);
          Fetch get_order_info
             into l_order_number,l_line_number,l_ship_date, l_response;
          Close get_order_info;

     WSH_UTIL_CORE.PRINTMSG;
     WSH_UTIL_CORE.PRINTMSG( '     Order Number  => ' || l_order_number);
     WSH_UTIL_CORE.PRINTMSG( '     Responsibility=> ' ||  l_response);
     WSH_UTIL_CORE.PRINTMSG( '     Line  Number  => ' ||  l_line_number);
     WSH_UTIL_CORE.PRINTMSG( '     Order Line Id => ' || l_txn_source_line_id);
     WSH_UTIL_CORE.PRINTMSG( '     Sch Ship Date => ' || l_ship_date);
     WSH_UTIL_CORE.PRINTMSG( '     Date Required => ' || l_date_required);
     WSH_UTIL_CORE.PRINTMSG( '     Whse Code     => ' || p_whse_code);
     WSH_UTIL_CORE.PRINTMSG( '     Move Line Id  => ' || l_mo_line_id);
     WSH_UTIL_CORE.PRINTMSG( '     Qty Required  => ' || l_qty_req);
     WSH_UTIL_CORE.PRINTMSG( '     Qty Detailed  => ' || l_qty_det);
     WSH_UTIL_CORE.PRINTMSG( '     Qty Delivered => ' || l_qty_delivered);

    -- Check if Item Has Allocation Class Associated
    -- If no class then item can not be auto allocated


    -- Use Cursor For alloc Class
    OPEN c_item_info;
    FETCH c_item_info into l_item_id, l_item_no, l_alloc_class;
    CLOSE c_item_info;

    IF l_alloc_class = NULL THEN

       l_no_class := l_no_class +1;

       WSH_UTIL_CORE.PRINTMSG( '     Item No  => ' || l_item_no || ' Has No Allocvation Class');

    ELSE


     WSH_UTIL_CORE.PRINTMSG;
     WSH_UTIL_CORE.PRINTMSG(c_event_separator);
     WSH_UTIL_CORE.PRINTMSG( '     START ALLOCATION ');

     l_nostock_ind :=0;


    -- B2497472 EMC
    -- As per enhanced auto allocation, allow call to Line_Auto_Detail
    -- regardless of whether lines are fully allocated.
/*
    IF l_qty_req = l_qty_det THEN
       WSH_UTIL_CORE.PRINTMSG( '     Move Order Is Fully Alocated');
       l_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
          l_return_status := FND_API.G_RET_STS_SUCCESS;
*/


GMI_Reservation_Util.PrintLn('(opm_dbg) in alloc engine b4 call to LINE_AUTO_DETAIL');

          GMI_Move_Order_Line_Util.Line_Auto_Detail
          (  p_mo_line_id                   => l_mo_line_id
          ,  p_init_msg_list                => 1
          ,  p_transaction_header_id        => 0
          ,  p_transaction_mode             => 1
          ,  p_move_order_type              => 3
          ,  p_allow_delete                 => NULL
          ,  x_number_of_rows               => l_number_rows
          ,  x_qc_grade                     => l_qc_grade
          ,  x_detailed_qty                 => l_detailed_qty
          ,  x_qty_UM                       => l_qty_um
          ,  x_detailed_qty2                => l_detailed_qty2
          ,  x_qty_UM2                      => l_qty_um2
          ,  x_return_status                => l_return_status
          ,  x_msg_count                    => l_msg_count
          ,  x_msg_data                     => l_msg_data
          );

GMI_Reservation_Util.PrintLn('(opm_dbg) in alloc engine after call to LINE_AUTO_DETAIL');

          WSH_UTIL_CORE.PRINTMSG('     Quantity Detailed => ' || NVL(l_detailed_qty,0));

         IF nvl(l_detailed_qty,0) = 0 OR ( l_detailed_qty = l_qty_det ) THEN

           WSH_UTIL_CORE.PRINTMSG;
           WSH_UTIL_CORE.PRINTMSG('     CHECK STOCK INFORMATION');
           WSH_UTIL_CORE.PRINTMSG('     ITEM     => '|| l_item_no);
           WSH_UTIL_CORE.PRINTMSG('     ITEM ID  => '|| l_item_id);
           WSH_UTIL_CORE.PRINTMSG('     WHSE     => '|| p_whse_code);

           OPEN c_inv_info;
           FETCH c_inv_info into l_qty_onhand;
           CLOSE c_inv_info;

           WSH_UTIL_CORE.PRINTMSG('     ONHAND BALANCE => ' || l_qty_onhand);

           IF l_qty_onhand <= 0 THEN

              l_nostock := l_nostock + 1;
              l_nostock_ind :=1;

            END IF;

          END IF; /* End Of No Stock Check */

--      END IF; /* End Of Detail qty Check */ end B2497472

     IF l_return_status <> 'S' THEN

        WSH_UTIL_CORE.PRINTMSG;
        WSH_UTIL_CORE.PRINTMSG(c_event_separator);
        WSH_UTIL_CORE.PRINTMSG( '     ALLOCATION ERROR  ');
        WSH_UTIL_CORE.PRINTMSG;

        WSH_UTIL_CORE.PRINTMSG( '     Return Status => ' || l_return_status);
        WSH_UTIL_CORE.PRINTMSG( '     MSG count     => ' || l_msg_count);
        -- FOR i in 1..l_msg_count LOOP
            l_message := fnd_msg_pub.get(1,'F');
            l_message := replace(l_message,fnd_global.local_chr(0),' ');


            WSH_UTIL_CORE.PRINTMSG( '    Error   => ' || l_message);
        -- END LOOP;

        WSH_UTIL_CORE.PRINTMSG;
        WSH_UTIL_CORE.PRINTMSG(c_event_separator);
        WSH_UTIL_CORE.PRINTMSG;
        FND_MSG_PUB.INITIALIZE;
        l_completion_status := G_WARNING;

    ELSE

     IF l_nostock_ind  = 0 THEN

      WSH_UTIL_CORE.PRINTMSG;
      WSH_UTIL_CORE.PRINTMSG(c_event_separator);
      WSH_UTIL_CORE.PRINTMSG( '  ALLOCATION SUCCESSFUL');

      -- added commit
      commit;

      WSH_UTIL_CORE.PRINTMSG('     ALLOC COMMIT ');
      l_completion_status := G_NORMAL;
      l_sucess_alloc  := l_sucess_alloc +1;

      IF  G_PICK_CONFIRM = 'Y' THEN

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         l_return_status := FND_API.G_RET_STS_SUCCESS;

         WSH_UTIL_CORE.PRINTMSG( '  START PICK CONFIRMATION');
         WSH_UTIL_CORE.PRINTMSG;

         GMI_Move_Order_Line_Util. Line_Pick_Confirm
         (  p_mo_line_id                    =>    l_mo_line_id
         ,  p_init_msg_list                 =>    1
         ,  p_move_order_type               =>    3
         ,  x_delivered_qty                 =>   l_detailed_qty
         ,  x_qty_UM                        =>   l_qty_um
         ,  x_delivered_qty2                =>   l_detailed_qty2
         ,  x_qty_UM2                       =>   l_qty_um2
         ,  x_return_status                 =>   l_return_status
         ,  x_msg_count                     =>   l_msg_count
         ,  x_msg_data                      =>   l_msg_data
         );


         IF l_return_status <> 'S' THEN
            WSH_UTIL_CORE.PRINTMSG;
            WSH_UTIL_CORE.PRINTMSG(c_event_separator);
            WSH_UTIL_CORE.PRINTMSG('     PICK CONFIRM ERROR');
            WSH_UTIL_CORE.PRINTMSG('     Return Status => ' || l_return_status);
            WSH_UTIL_CORE.PRINTMSG('     MSG count     => ' || l_msg_count);
            l_message := fnd_msg_pub.get(1,'F');
            l_message := replace(l_message,fnd_global.local_chr(0),' ');
            WSH_UTIL_CORE.PRINTMSG('     Error         => ' || l_message);
            FND_MSG_PUB.INITIALIZE;
            WSH_UTIL_CORE.PRINTMSG;
            WSH_UTIL_CORE.PRINTMSG(c_event_separator);
            l_completion_status := G_WARNING;
          ELSE

            IF nvl(l_detailed_qty,0) = nvl(l_qty_delivered,0) THEN

              WSH_UTIL_CORE.PRINTMSG;
              WSH_UTIL_CORE.PRINTMSG(c_event_separator);
              WSH_UTIL_CORE.PRINTMSG('     PICK CONFIRM FAILURE ');

              l_pick_fail := l_pick_fail +1;
              l_completion_status := G_WARNING;
            ELSE

              WSH_UTIL_CORE.PRINTMSG;
              WSH_UTIL_CORE.PRINTMSG(c_event_separator);
              WSH_UTIL_CORE.PRINTMSG('     PICK CONFIRM SUCCESSFUL ');
              l_completion_status := G_NORMAL;

              l_sucess_pick := l_sucess_pick + 1 ;

              -- added commit
              commit;
            END IF; /* End Check Detailed Qty */

           END IF ; /* PICK CONFIRM  TEST */
       ELSE
           WSH_UTIL_CORE.PRINTMSG;
           WSH_UTIL_CORE.PRINTMSG(c_event_separator);
           WSH_UTIL_CORE.PRINTMSG('     PICK CONFIRM NOT SELECTED ');
       END IF; /* PICK CONFIRM SELECTION */

    END IF ; /* For Sucessful Allocation */

   END IF ; /* For Auto Detail */

  END IF ; /* For Alloc Class */


  -- Add logic to determine the completion status
  -- Only update if value is greater than current

  IF l_completion_status > G_COMP_STATUS THEN
     G_COMP_STATUS := l_completion_status;
  END IF;

  END LOOP;
  CLOSE c_get_lines;


  l_manual_lines := l_total_lines - ( l_nostock + l_sucess_alloc + l_no_class);

  WSH_UTIL_CORE.PRINTMSG;
  WSH_UTIL_CORE.PRINTMSG( '     ************* SUMMARY ************ ');
  WSH_UTIL_CORE.PRINTMSG( '     Total Lines Need          => ' ||  l_total_lines);
  WSH_UTIL_CORE.PRINTMSG( '     Total Lines Processed     => ' ||  l_required_lines);
  WSH_UTIL_CORE.PRINTMSG( '     No Stock lines            => ' ||  l_nostock);
  WSH_UTIL_CORE.PRINTMSG( '     No Alloc Rules Lines      => ' ||  l_no_class);
  WSH_UTIL_CORE.PRINTMSG( '     Require Manual Allocation => ' ||  l_manual_lines);
  WSH_UTIL_CORE.PRINTMSG( '     Pick Confirm Failure      => ' ||  l_pick_fail);
  WSH_UTIL_CORE.PRINTMSG;
  WSH_UTIL_CORE.PRINTMSG(c_event_separator);
  WSH_UTIL_CORE.PRINTMSG( '     Sucessful Allocations     => ' || l_sucess_alloc);
  WSH_UTIL_CORE.PRINTMSG( '     Sucessful Pick Confirms   => ' || l_sucess_pick);
  WSH_UTIL_CORE.PRINTMSG;


  IF G_COMP_STATUS = G_NORMAL THEN
     l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL','');
  ELSE
     l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','');
  END IF;

EXCEPTION

  WHEN NO_LINES_FOUND THEN
    WSH_UTIL_CORE.PRINTMSG;
    WSH_UTIL_CORE.PRINTMSG(c_event_separator);
    WSH_UTIL_CORE.PRINTMSG('     NO LINES FOUND FOR  ' );
    WSH_UTIL_CORE.PRINTMSG('     WHSE CODE   => ' || p_whse_code);
    WSH_UTIL_CORE.PRINTMSG('     ORDER NUM   => ' || p_from_order_num);
    WSH_UTIL_CORE.PRINTMSG('     ITEM  NUM   => ' || p_item_num);
    WSH_UTIL_CORE.PRINTMSG('     CUSTOMER    => ' || p_cust_num);
    WSH_UTIL_CORE.PRINTMSG('     FROM DATE   => ' || p_from_ship_date);
    WSH_UTIL_CORE.PRINTMSG('     TO   DATE   => ' || p_to_ship_date);
    l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING','');

  WHEN OTHERS THEN
    WSH_UTIL_CORE.PRINTMSG;
    WSH_UTIL_CORE.PRINTMSG(c_event_separator);
    WSH_UTIL_CORE.PRINTMSG('     ERR NUM => ' || SQLERRM);
    WSH_UTIL_CORE.PRINTMSG('     ERR MSG => ' || SQLCODE);
    l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');

END AUTO_ALLOC_CONFIRM_SRS;

--Procedure
--   Cancel_Move_Order_Line
--Description
--   This procedure is called from Shipping when a delivery line that
-- is released to warehouse is cancelled.  This procedure will
-- cancel the move order line.  Cancelling a move order line is not
-- the same as closing a move order line.  The user does not have
-- access to a closed move order line - it's as if the line has been
-- deleted.  A cancelled move order line can still be transacted from
-- the move order forms.  However, a cancelled move order line no
-- longer has a corresponding record in Wsh_delivery_details, or a
-- reservation tied to that move order.  A cancelled move order line
-- is simply an inventory transaction, moving material from one subinventory
-- to another. The allocations still exist for the move order line.
--    This procedure updates the status on the move order line to 8 and
-- the required quantity to 0.
-- The detailed_quantity column on the reservation is decremented as
-- necessary. The reservation id on the allocation is deleted.
--    If WMS is installed, this procedure will delete any tasks
-- that are not yet dispatched.
-- Parametrs
--   p_line_id: The move order line id to be cancelled
--   p_delete_reservations:  'Y' or 'N'
--      If passed as 'Y', this procedure deletes/reduces quantity on
--      reservations.  Shipping will pass with 'Y' when the quantity
--      on the sales order line is reduced, and a delivery detail is
--      deleted as a result.
--   p_txn_source_line_Id:  The sales order line id.  If this
--      parameter is not passed in, we get it from the delivery detail.
--
/* for OPM, there is no concept of required_quantity, the quantity in the
  sense is the required qty and would be passed to shipping.
  OPM inventory might be different where a cancelled move order line can not
  be transacted in move order form. User can NOT move material from one lot
  to another by accessing the move order line.
  IF p_delete_reservations:  'Y' The inv transaction is simply
       deleted and qtys are returned to the default lot
  IF p_delete_reservations:  'N' The inv transaction is kept for the delivery line
    as if user has allocated them in order pad

  since the move order line is calceled, user has to pick release the line again
   in order to transact

  OPM does not support WMS yet. So this case is not considered
*/

PROCEDURE Cancel_Move_Order_Line(
         x_return_status           OUT NOCOPY VARCHAR2
        ,x_msg_count               OUT NOCOPY NUMBER
        ,x_msg_data                OUT NOCOPY VARCHAR2
        ,p_line_id                 IN NUMBER
        ,p_delivery_detail_id      IN NUMBER
        ,p_delete_reservations     IN VARCHAR2
        ,p_txn_source_line_id      IN NUMBER DEFAULT NULL)

IS

  l_quantity              NUMBER;
  l_quantity2             NUMBER;
  l_quantity_detailed     NUMBER;
  l_quantity2_detailed    NUMBER;
  l_deleted_quantity      NUMBER;
  l_deleted_quantity2     NUMBER;
  l_quantity_to_delete    NUMBER;
  l_quantity2_to_delete   NUMBER;
  l_line_status           NUMBER;
  l_organization_id       NUMBER;
  l_ship_from_org_id      NUMBER;
  l_return_status         VARCHAR2(1);
  l_delete_reservations   VARCHAR2(1);
  l_reservation_id        NUMBER;
  l_primary_quantity      NUMBER;
  l_txn_source_line_id    NUMBER;
  l_error_code            NUMBER;
  l_trans_rec             GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_trans_row             ic_tran_pnd%ROWTYPE;

  cursor c_line_info IS
    SELECT    quantity
            , secondary_quantity
            , NVL(quantity_detailed, 0)
            , NVL(secondary_quantity_detailed, 0)
            , organization_id
      FROM ic_txn_request_lines
     WHERE line_id = p_line_id
     FOR UPDATE;

  cursor c_txn_source_line IS
    SELECT source_line_id
         , organization_id
      FROM wsh_delivery_details
     WHERE move_order_line_id IS NOT NULL
       AND delivery_detail_id = p_delivery_detail_id
       AND move_order_line_id = p_line_id
       AND released_status = 'S';

  cursor c_reservations IS
    SELECT trans_id
      FROM ic_tran_pnd
     WHERE line_id = l_txn_source_line_id
       AND line_detail_id = p_delivery_detail_id /* should have this filed populated since mo line*/
       AND staged_ind = 0
       AND delete_mark = 0
       AND doc_type = 'OMSO'
       AND trans_qty <> 0
       AND (lot_id > 0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT)
            -- Bug 3962760 - exclude the default transaction.
     ORDER BY trans_qty desc; /* the smaller qty is at the top, keep in mind it is neg */
                              /* or should consider the alloc rules */
BEGIN
  GMI_Reservation_Util.PrintLn('Entering Cancel_Move_order_line and line_id is '||p_line_id);
  --SAVEPOINT CANCELMO_SP;

  l_deleted_quantity := 0;

  /*IF p_delete_reservations IS NULL OR
     p_delete_reservations <> 'Y' THEN
     l_delete_reservations := 'N';
     gmi_reservation_util.println('L_delete is set to N');
  ELSE
     l_delete_reservations := 'Y';
     gmi_reservation_util.println('L_delete is set to Y');
  END IF;*/
  /* for OPM delete is always Y*/
  --l_delete_reservations := 'Y';
  l_delete_reservations := p_delete_reservations;
  GMI_Reservation_Util.PrintLn('Delete_rsvs = ' || l_delete_reservations);

  gmi_reservation_util.println('Going to call open_C_line info in cancel_move_order ');
  --query mo line info
  OPEN c_line_info;
  FETCH c_line_info
  INTO   l_quantity
        ,l_quantity2
        ,l_quantity_detailed
        ,l_quantity2_detailed
        ,l_organization_id;
  IF c_line_info%NOTFOUND THEN
     GMI_Reservation_Util.PrintLn('Error: Could not find mo line');
     RAISE fnd_api.g_exc_error;
  END IF;
  CLOSE c_line_info;

  /* if the delivery_detail is deleted in shipping, all the rsv with it should be deleted */
  IF l_delete_reservations = 'Y'
     --AND l_quantity >= l_quantity_detailed
  THEN
    l_quantity_to_delete := l_quantity_detailed;
    l_quantity2_to_delete := l_quantity2_detailed;
    GMI_Reservation_Util.PrintLn('Qty to delete = ' || l_quantity_to_delete);

    -- we query by the sales order line id.  If that value is not
    -- passed in, we need to get it from shipping table
    If p_txn_source_line_id IS NOT NULL Then
       l_txn_source_line_id := p_txn_source_line_id;
    Else
       OPEN c_txn_source_line;
       FETCH c_txn_source_line
       INTO l_txn_source_line_id
          , l_organization_id;
       if c_txn_source_line%NOTFOUND then
          CLOSE c_txn_source_line;
          RAISE no_data_found;
       end if;
       CLOSE c_txn_source_line;
    End If;
    GMI_Reservation_Util.PrintLn('Src line id = ' || l_txn_source_line_id);

    OPEN c_reservations;
    LOOP
      EXIT WHEN l_quantity_to_delete <= 0;

      FETCH c_reservations INTO l_reservation_id;
      EXIT WHEN c_reservations%NOTFOUND;

      l_trans_rec.trans_id := l_reservation_id;
      GMI_Reservation_Util.PrintLn('Rsv id = ' || l_reservation_id);

      IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
        (l_trans_rec, l_trans_rec )
      THEN
         GMI_Reservation_Util.PrintLn('trans_qty = ' || l_trans_rec.trans_qty);
         IF abs(l_trans_rec.trans_qty) <= l_quantity_to_delete THEN
           -- if so, simply delete the rsv , will balance default later
           GMI_Reservation_Util.PrintLn('set delete trans' );
           GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION
           ( 1
           , FND_API.G_FALSE
           , FND_API.G_FALSE
           , FND_API.G_VALID_LEVEL_FULL
           , l_trans_rec
           , l_trans_row
           , x_return_status
           , x_msg_count
           , x_msg_data
           );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
             GMI_RESERVATION_UTIL.PrintLn('Error returned by Delete_Pending_Transaction');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
           l_deleted_quantity := l_deleted_quantity + abs(l_trans_rec.trans_qty);
           l_deleted_quantity2 := l_deleted_quantity2 + abs(l_trans_rec.trans_qty2);
         ELSE
           GMI_Reservation_Util.PrintLn('update ic_tran_pnd ' );
           l_trans_rec.trans_qty := -1 * (abs(l_trans_rec.trans_qty) - l_quantity_to_delete);
           l_trans_rec.trans_qty2 := -1 * (abs(l_trans_rec.trans_qty2) - l_quantity2_to_delete);
           GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
           ( 1
           , FND_API.G_FALSE
           , FND_API.G_FALSE
           , FND_API.G_VALID_LEVEL_FULL
           , l_trans_rec
           , l_trans_row
           , x_return_status
           , x_msg_count
           , x_msg_data
           );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
              THEN
                GMI_RESERVATION_UTIL.println('Error returned by Update_Pending_Transaction');
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           l_deleted_quantity := l_deleted_quantity + l_quantity_to_delete;
           l_deleted_quantity2 := l_deleted_quantity2 + l_quantity2_to_delete;
         END IF;
      END IF;
      l_quantity_to_delete := l_quantity_to_delete - abs(l_trans_rec.trans_qty);
      l_quantity2_to_delete := l_quantity2_to_delete - abs(l_trans_rec.trans_qty2);
    END LOOP;
    CLOSE c_reservations;
    GMI_RESERVATION_UTIL.find_default_lot
            (  x_return_status     => x_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data,
               x_reservation_id    => l_reservation_id,
               p_line_id           => l_txn_source_line_id
            );

    IF nvl(l_reservation_id,0) > 0 THEN -- no balancing if no default exist
      l_trans_rec.trans_id := l_reservation_id;
      IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
          (l_trans_rec, l_trans_rec )
      THEN
         Select ship_from_org_id
         Into l_ship_from_org_id
         From oe_order_lines_all
         Where line_id = l_txn_source_line_id;

         Select mtl_organization_id
         Into l_organization_id
         From ic_whse_mst
         Where whse_code = l_trans_rec.whse_code;

         GMI_Reservation_Util.PrintLn('om line ship_from_org_id '||l_ship_from_org_id );
         GMI_Reservation_Util.PrintLn('trans organization_id'||l_organization_id);
         IF l_ship_from_org_id = l_organization_id THEN
           GMI_RESERVATION_UTIL.balance_default_lot
              ( p_ic_default_rec            => l_trans_rec
              , p_opm_item_id               => l_trans_rec.item_id
              , x_return_status             => x_return_status
              , x_msg_count                 => x_msg_count
              , x_msg_data                  => x_msg_data
              );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
              GMI_RESERVATION_UTIL.PrintLn('cancle move order Error returned by balancing default lot');
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         ELSE
           /* delete this default lot, and created a new one */
           GMI_Reservation_Util.PrintLn('delete trans trans_id'||l_trans_rec.trans_id);
           GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION
           ( 1
           , FND_API.G_FALSE
           , FND_API.G_FALSE
           , FND_API.G_VALID_LEVEL_FULL
           , l_trans_rec
           , l_trans_row
           , x_return_status
           , x_msg_count
           , x_msg_data
           );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
             GMI_RESERVATION_UTIL.PrintLn('Error returned by Delete_Pending_Transaction');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           Select whse_code
           Into l_trans_rec.whse_code
           From ic_whse_mst
           Where mtl_organization_id = l_ship_from_org_id
              and rownum = 1;   -- just in case, should only have 1 row

           GMI_TRANS_ENGINE_PUB.CREATE_PENDING_TRANSACTION
           ( 1
           , FND_API.G_FALSE
           , FND_API.G_FALSE
           , FND_API.G_VALID_LEVEL_FULL
           , l_trans_rec
           , l_trans_row
           , x_return_status
           , x_msg_count
           , x_msg_data
           );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS
           THEN
             GMI_RESERVATION_UTIL.println('Error returned by Create_Pending_Transaction');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
           l_trans_rec.trans_id := l_trans_row.trans_id;
           GMI_Reservation_Util.PrintLn('created trans trans_id'||l_trans_rec.trans_id);
           IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
               (l_trans_rec, l_trans_rec )
           THEN
              GMI_RESERVATION_UTIL.balance_default_lot
                 ( p_ic_default_rec            => l_trans_rec
                 , p_opm_item_id               => l_trans_rec.item_id
                 , x_return_status             => x_return_status
                 , x_msg_count                 => x_msg_count
                 , x_msg_data                  => x_msg_data
                 );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS
              THEN
                 GMI_RESERVATION_UTIL.PrintLn('cancle move order Error returned by balancing default lot');
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;
         END IF;
      END IF;
    END IF;
  ELSE
    --l_deleted_quantity := requested_qty;
    null;
  END IF;

  -- Reduce move order quantity to only include existing allocations
  IF l_quantity > l_quantity_detailed THEN
     l_quantity := l_quantity_detailed;
  END IF;

  -- If no allocations exist, close move order line
  IF l_quantity <= 0 OR
     l_quantity_detailed <= 0 THEN
     l_quantity := 0;
     l_quantity2 := 0;
     l_line_status := 5;
     GMI_Reservation_Util.PrintLn('No allocations. Closing MO line');
  ELSE
     --  If all of the quantity for the move order line was deleted,
     --  close the move order line
     If l_deleted_quantity >= l_quantity Then
          l_quantity := 0;
          l_quantity2 := 0;
          l_line_status := 5;
          GMI_Reservation_Util.PrintLn('Closing MO Line');
     Else
          l_quantity := l_quantity - l_deleted_quantity;
          l_quantity2 := l_quantity2 - l_deleted_quantity2;
          l_line_status := 9;
          GMI_Reservation_Util.PrintLn('Canceling MO Line New qty = ' || l_quantity);
          GMI_Reservation_Util.PrintLn('Canceling MO Line New qty2 = ' || l_quantity2);
     End If;
  END IF;
  --  Update line status, quantity, and required_quantity
  UPDATE ic_txn_request_lines
     SET quantity = l_quantity
        ,secondary_quantity = l_quantity2
        ,line_status = l_line_status
   WHERE line_id = p_line_id;

  x_return_status := fnd_api.g_ret_sts_success;
  GMI_Reservation_Util.PrintLn('Return status = ' || x_return_status);



EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO CANCELMO_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      GMI_Reservation_Util.PrintLn('Return status = ' || x_return_status);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO CANCELMO_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      GMI_Reservation_Util.PrintLn('Return status = ' || x_return_status);
    WHEN OTHERS THEN
      ROLLBACK TO CANCELMO_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      GMI_Reservation_Util.PrintLn('Other error in Cancel_Move_Order_line');
      GMI_Reservation_Util.PrintLn('Error Code = ' || SQLCODE);
      GMI_Reservation_Util.PrintLn('Error Msg:' || SQLERRM);
      GMI_Reservation_Util.PrintLn('Return status = ' || x_return_status);
END Cancel_Move_Order_Line;

--Procedure
--   Reduce_Move_Order_Quantity
--Description
--   This procedure is called from Shipping when the quantity on a
-- sales order line is reduced, leading to the quantity on a delivery
-- detail being reduced.  This procedure reduces the quantity
-- column on the move order line by p_reduction_quantity. The required
-- quantity is the quantity needed by shipping to fulfill the sales order.
-- Any quantity transacted for this move order line in excess of the
-- required_quantity will be moved to staging, but will not be
-- reserved or shipped to the customer. Since the
-- sales order line quantity has been reduced, the reservation quantity
-- for the sales order should also be reduced. Some reservations are
-- reduced here, and some are reduced in Finalize_Pick_Confirm
-- (INVVTROB.pls).
--    If WMS is installed, undispatched tasks may be deleted, since these
-- tasks are no longer necessary.
-- Parameters
--   p_line_id: The move order line id to be cancelled
--   p_reduction_quantity:  How much to reduce the required
--       quantity by
--   p_txn_source_line_Id:  The sales order line id.  If this
--      parameter is not passed in, we get it from the delivery detail.
--
/* for OPM, there is no concept of required_quantity, the quantity in the
  sense is the required qty and would be passed to shipping. So when user cancels
  qty in OM, the delivery detail(s) would be reduced by the p_reduction_quantity
  as well as the move order column quantity.
  if the p_reduction_quantity <= (quantity-quantity_detailed), no need to remove
  any inv transactions
  else
   need to remove inv trans qtys by the amount of p_reduction_quantity -
   quantity-quantity_detailed
  OPM does not support WMS yet. So this case is not considered
*/
PROCEDURE Reduce_Move_Order_Quantity(
   x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
  ,p_line_id               IN NUMBER
  ,p_delivery_detail_id    IN NUMBER
  ,p_reduction_quantity    IN NUMBER
  ,p_reduction_quantity2   IN NUMBER
  ,p_txn_source_line_id    IN NUMBER DEFAULT NULL)
IS
  l_quantity 	NUMBER;
  l_quantity2 	NUMBER;
  l_quantity_detailed NUMBER;
  l_quantity2_detailed NUMBER;
  l_organization_id NUMBER;
  l_transaction_temp_id NUMBER;
  l_task_qty NUMBER;
  l_return_status VARCHAR2(1);
  l_deleted_quantity NUMBER;
  l_deleted_quantity2 NUMBER;
  l_reservation_id NUMBER;
  l_primary_quantity NUMBER;
  l_rsv_count NUMBER;
  l_quantity_to_delete NUMBER;
  l_quantity2_to_delete NUMBER;
  l_txn_source_line_id NUMBER;
  l_reduction_quantity NUMBER;
  l_error_code NUMBER;
  l_mo_uom_code VARCHAR2(3);
  l_primary_uom_code VARCHAR2(3);
  l_inventory_Item_id NUMBER;
  l_prim_quantity_to_delete NUMBER;
  l_remaining_quantity NUMBER;
  l_trans_rec    GMI_TRANS_ENGINE_PUB.ictran_rec;
  l_trans_row             ic_tran_pnd%ROWTYPE;

  cursor c_line_info IS
    SELECT quantity
         , secondary_quantity
         , NVL(quantity_detailed, 0)
         , NVL(secondary_quantity_detailed, 0)
         , organization_id
         , inventory_item_Id
         , uom_code
      FROM ic_txn_request_lines
     WHERE line_id = p_line_id
     FOR UPDATE;

  cursor c_primary_uom IS
     SELECT primary_uom_code
       FROM mtl_system_items

      WHERE organization_Id = l_organization_id
	AND inventory_Item_Id = l_inventory_Item_Id;

  cursor c_txn_source_line IS
    SELECT source_line_id
      FROM wsh_delivery_details
     WHERE move_order_line_id IS NOT NULL
       AND move_order_line_id = p_line_id
       AND released_status = 'S';

  cursor c_reservations IS
    SELECT trans_id
      FROM ic_tran_pnd
     WHERE line_id = l_txn_source_line_id
       AND (line_detail_id = p_delivery_detail_id
           or nvl(line_detail_id, -1 ) = -1 )
       AND staged_ind = 0
       AND delete_mark = 0
       AND doc_type = 'OMSO'
       AND trans_qty <> 0
       AND (lot_id > 0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT)
            -- Bug 3962760 - exclude the default transaction.
     ORDER BY line_detail_id desc,
              trans_qty desc; /* the smaller qty is at the top, keep in mind it is neg */
                              /* should we do it by the alloc rules? auto-fifo, fefo? */

  cursor find_default_lot IS
    SELECT trans_id
      FROM ic_tran_pnd
     WHERE line_id = l_txn_source_line_id
       AND doc_type = 'OMSO'
       AND delete_mark = 0
       AND (lot_id = 0 OR location <> GMI_RESERVATION_UTIL.G_DEFAULT_LOCT);

BEGIN
   GMI_Reservation_Util.PrintLn('entering reduce move order ');
   gmi_reservation_util.println('Value of p_line_id is '||p_line_id);
   gmi_reservation_util.println('Value of p_txn_source_line_id is '||p_txn_source_line_id);
   gmi_reservation_util.println('Value of p_delivery_detail_id is is '||p_delivery_detail_id);
   gmi_reservation_util.println('Value of p_reduction_quantity is '||p_reduction_quantity);

   --SAVEPOINT REDUCEMO_SP;

   IF p_reduction_quantity <= 0 THEN
      RETURN;
   END IF;

   l_deleted_quantity := 0;
   l_deleted_quantity2 := 0;

   --query mo line info
   OPEN c_line_info;
   FETCH c_line_info
   INTO l_quantity
     , l_quantity2
     ,l_quantity_detailed
     ,l_quantity2_detailed
     ,l_organization_id
     ,l_inventory_Item_id
     ,l_mo_uom_code;
   IF c_line_info%NOTFOUND THEN
      GMI_Reservation_Util.PrintLn('Move order line not found');

      RAISE fnd_api.g_exc_error;
   END IF;

   CLOSE c_line_info;


   l_reduction_quantity := p_reduction_quantity;
   l_remaining_quantity := l_quantity - l_quantity_detailed;
   l_quantity_to_delete := -l_reduction_quantity + l_remaining_quantity;
   l_quantity2_to_delete := -p_reduction_quantity2 + (l_quantity2 - l_quantity2_detailed);

   gmi_reservation_util.println('Value of l_reduction_quantity is '||l_reduction_quantity);
   gmi_reservation_util.println('Value of l_remaining_quantity is '||l_remaining_quantity);
   gmi_reservation_util.println('Value of l_quantity_to_delete is '||l_quantity_to_delete);

  -- Call Cancel MO Line when reduction qu	antity is greater than
  -- required quantity or quantity
  IF l_reduction_quantity >= l_quantity THEN
  gmi_reservation_util.println('Going to call cancel_move_order_line in reduce');
     cancel_move_order_line(
         x_return_status        => l_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
        ,p_line_id              => p_line_id
        ,p_delivery_detail_id   => p_delivery_detail_id
        ,p_delete_reservations  => 'Y'
        ,p_txn_source_line_id   => p_txn_source_line_id);

      IF l_return_status = fnd_api.g_ret_sts_error Then
      gmi_reservation_util.println('Error coming back from cancel_move order in reduce_move_qty');
            RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error Then
      gmi_reservation_util.println('Error coming back from cancel_move but this is different');
            RAISE fnd_api.g_exc_unexpected_error;
      END IF;
  END IF;

  /* need to delete or reduce some of the inv transactions*/
  IF l_quantity_to_delete > 0 THEN
     /* move order uom should be always primary uom */
     /*If l_primary_uom_code <> l_mo_uom_code Then
       null;
       l_prim_quantity_to_delete :=
         GMI_Reservation_Util.get_opm_converted_qty(
            p_apps_item_id    => l_inventory_item_id,
            p_organization_id => l_organization_id,
            p_apps_from_uom   => l_uom_code
            p_apps_to_uom     => c.requested_quantity_uom,
            p_original_qty    => p_changed_attributes(l_counter).ordered_quantity);

     Else
      l_prim_quantity_to_delete := l_quantity_to_delete;
     End If;*/

     -- HW No need to close this cursor. It was never opened
     -- CLOSE c_txn_source_line;
     -- we query by the sales order line id.  If that value is not
     -- passed in, we need to get it from shipping table
     If p_txn_source_line_id IS NOT NULL Then
     gmi_reservation_util.println('Assigning value for l_txn_source_line_id');
        l_txn_source_line_id := p_txn_source_line_id;
      Else
      gmi_reservation_util.println('Going to fetch c_txn_source_line');
        OPEN c_txn_source_line;
        FETCH c_txn_source_line INTO l_txn_source_line_id;
        if c_txn_source_line%NOTFOUND then
           CLOSE c_txn_source_line;
           GMI_Reservation_Util.PrintLn('Did not find any sales order line');
           RAISE no_data_found;
        end if;
        CLOSE c_txn_source_line;
     End If;

     OPEN c_reservations;
     LOOP
        EXIT WHEN l_quantity_to_delete <= 0;

        FETCH c_reservations INTO l_reservation_id;
        EXIT WHEN c_reservations%NOTFOUND;

        l_trans_rec.trans_id := l_reservation_id;
        gmi_reservation_util.println('Going to fetch record from ic in reduce_move');
        IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
          (l_trans_rec, l_trans_rec )
        THEN
            GMI_Reservation_Util.PrintLn('trans_qty = ' || l_trans_rec.trans_qty);
            /* may have to consider indivisible */
            IF abs(l_trans_rec.trans_qty) <= l_quantity_to_delete THEN
              -- if so, simply delete the rsv , will balance default later
              gmi_reservation_util.println('Going to delete tran in reduceMove');
              GMI_TRANS_ENGINE_PUB.DELETE_PENDING_TRANSACTION
              ( 1
              , FND_API.G_FALSE
              , FND_API.G_FALSE
              , FND_API.G_VALID_LEVEL_FULL
              , l_trans_rec
              , l_trans_row
              , x_return_status
              , x_msg_count
              , x_msg_data
              );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS
              THEN
                GMI_RESERVATION_UTIL.PrintLn('Error returned by Delete_Pending_Transaction');
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              l_deleted_quantity := l_deleted_quantity + abs(l_trans_rec.trans_qty);
              l_deleted_quantity2:= l_deleted_quantity2 + abs(l_trans_rec.trans_qty2);
            ELSE
              gmi_reservation_util.println('In ELSE and will be updateing ic_tran');
              l_trans_rec.trans_qty := -1 * (abs(l_trans_rec.trans_qty) - l_quantity_to_delete);
              l_trans_rec.trans_qty2:= -1 * (abs(l_trans_rec.trans_qty2) - l_quantity2_to_delete);
              GMI_TRANS_ENGINE_PUB.UPDATE_PENDING_TRANSACTION
              ( 1
              , FND_API.G_FALSE
              , FND_API.G_FALSE
              , FND_API.G_VALID_LEVEL_FULL
              , l_trans_rec
              , l_trans_row
              , x_return_status
              , x_msg_count
              , x_msg_data
              );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS
                 THEN
                   GMI_RESERVATION_UTIL.println('Error returned by Update_Pending_Transaction');
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              l_deleted_quantity := l_deleted_quantity + l_quantity_to_delete;
              l_deleted_quantity2 := l_deleted_quantity2 + l_quantity2_to_delete;
            END IF;
        END IF;
        l_quantity_to_delete := l_quantity_to_delete - l_deleted_quantity;
        l_quantity2_to_delete := l_quantity2_to_delete - l_deleted_quantity2;
     END LOOP;
     CLOSE c_reservations;

     GMI_RESERVATION_UTIL.find_default_lot
             (  x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                x_reservation_id    => l_reservation_id,
                p_line_id           => l_txn_source_line_id
             );

     IF nvl(l_reservation_id,0) > 0 THEN -- no balancing if no default exist
       l_trans_rec.trans_id := l_reservation_id;
       IF GMI_TRAN_PND_DB_PVT.FETCH_IC_TRAN_PND
           (l_trans_rec, l_trans_rec )
       THEN
         GMI_RESERVATION_UTIL.balance_default_lot
               ( p_ic_default_rec            => l_trans_rec
               , p_opm_item_id               => l_trans_rec.item_id
               , x_return_status             => x_return_status
               , x_msg_count                 => x_msg_count
               , x_msg_data                  => x_msg_data
               );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS
         THEN
            GMI_RESERVATION_UTIL.PrintLn('cancle move order Error returned by balancing default lot');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;
     END IF;
  END IF;

  gmi_reservation_util.println('Value of p_line_id before update is '||p_line_id);
  l_quantity := l_quantity - l_reduction_quantity;
  l_quantity2 := l_quantity2 - p_reduction_quantity2;

  GMI_Reservation_Util.PrintLn('updating move order line with qty  '||l_quantity);
  gmi_reservation_util.println('For line id '||p_line_id);
  --  Update line status, quantity, and required_quantity
  UPDATE ic_txn_request_lines
    SET quantity = l_quantity
      , primary_quantity = l_quantity
      , secondary_quantity = l_quantity2
      , quantity_detailed = quantity_detailed - l_deleted_quantity
      , secondary_quantity_detailed = secondary_quantity_detailed - l_deleted_quantity2
    WHERE line_id = p_line_id;

  x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      --ROLLBACK TO REDUCEMO_SP;
      x_return_status := fnd_api.g_ret_sts_error;
   WHEN OTHERS THEN
      --ROLLBACK TO REDUCEMO_SP;
      GMI_Reservation_Util.PrintLn('Others error' || Sqlerrm);
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END Reduce_Move_Order_Quantity;

  --Update_Txn_Source_Line
  --
  -- This procedure updates the move order line indicated by p_line_id
  -- with a new transaction source line id (p_new_source_line_id).
  -- It also updates all of the allocation lines with the new source line id.
  -- This procedure is called from Shipping when the delivery detail is split
  -- after pick release has occurred, but before pick confirm.
  -- logic is the same as inv file INVVTROB.pls

PROCEDURE update_txn_source_line
         ( p_line_id IN NUMBER
         , p_new_source_line_id IN NUMBER
         ) IS
  BEGIN
    UPDATE ic_txn_request_lines
       SET txn_source_line_id = p_new_source_line_id
     WHERE line_id = p_line_id;

    /*UPDATE mtl_material_transactions_temp
       SET trx_source_line_id = p_new_source_line_id
     WHERE move_order_line_id = p_line_id;*/
  END update_txn_source_line;


END GMI_MOVE_ORDER_LINE_UTIL;

/
