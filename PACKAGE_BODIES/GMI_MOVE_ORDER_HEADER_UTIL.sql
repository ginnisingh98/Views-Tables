--------------------------------------------------------
--  DDL for Package Body GMI_MOVE_ORDER_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_MOVE_ORDER_HEADER_UTIL" AS
/*   $Header: GMIUMOHB.pls 120.0 2005/05/26 00:14:59 appldev noship $ */
/* +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIUMOHB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Move Order Header Utilities                                         |
 |                                                                         |
 | - Process_Move_Order_Header                                             |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     27-Apr-2000  odaboval        Created                                |
 |   	14-Sep-2000  odaboval        removed dummy calls.                   |
 |   	                                                                    |
 |   	                                                                    |
 +=========================================================================+
  API Name  : GMI_Move_Order_Header_Util
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/


/*   Global constant holding the package name  */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'GMI_Move_Order_Header_Util';

/*  (odab) Deleted procedures :
   Procedure Clear_Dependent_Attr
   Procedure Apply_Attribute_Changes
   Function Get_Values
   Function Get_Ids
*/

/*   Function Complete_Record  */

FUNCTION Complete_Record
(   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
,   p_old_mo_hdr_rec                IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
) RETURN GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
IS
l_mo_hdr_rec                  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC := p_mo_hdr_rec;
BEGIN

    IF l_mo_hdr_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute1 := p_old_mo_hdr_rec.attribute1;
    END IF;

    IF l_mo_hdr_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute10 := p_old_mo_hdr_rec.attribute10;
    END IF;

    IF l_mo_hdr_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute11 := p_old_mo_hdr_rec.attribute11;
    END IF;

    IF l_mo_hdr_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute12 := p_old_mo_hdr_rec.attribute12;
    END IF;

    IF l_mo_hdr_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute13 := p_old_mo_hdr_rec.attribute13;
    END IF;

    IF l_mo_hdr_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute14 := p_old_mo_hdr_rec.attribute14;
    END IF;

    IF l_mo_hdr_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute15 := p_old_mo_hdr_rec.attribute15;
    END IF;

    IF l_mo_hdr_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute2 := p_old_mo_hdr_rec.attribute2;
    END IF;

    IF l_mo_hdr_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute3 := p_old_mo_hdr_rec.attribute3;
    END IF;

    IF l_mo_hdr_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute4 := p_old_mo_hdr_rec.attribute4;
    END IF;

    IF l_mo_hdr_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute5 := p_old_mo_hdr_rec.attribute5;
    END IF;

    IF l_mo_hdr_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute6 := p_old_mo_hdr_rec.attribute6;
    END IF;

    IF l_mo_hdr_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute7 := p_old_mo_hdr_rec.attribute7;
    END IF;

    IF l_mo_hdr_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute8 := p_old_mo_hdr_rec.attribute8;
    END IF;

    IF l_mo_hdr_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute9 := p_old_mo_hdr_rec.attribute9;
    END IF;

    IF l_mo_hdr_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute_category := p_old_mo_hdr_rec.attribute_category;
    END IF;

    IF l_mo_hdr_rec.created_by = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.created_by := p_old_mo_hdr_rec.created_by;
    END IF;

    IF l_mo_hdr_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.creation_date := p_old_mo_hdr_rec.creation_date;
    END IF;

    IF l_mo_hdr_rec.date_required = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.date_required := p_old_mo_hdr_rec.date_required;
    END IF;

    IF l_mo_hdr_rec.description = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.description := p_old_mo_hdr_rec.description;
    END IF;

    IF l_mo_hdr_rec.from_subinventory_code = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.from_subinventory_code := p_old_mo_hdr_rec.from_subinventory_code;
    END IF;

    IF l_mo_hdr_rec.header_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.header_id := p_old_mo_hdr_rec.header_id;
    END IF;

    IF l_mo_hdr_rec.header_status = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.header_status := p_old_mo_hdr_rec.header_status;
    END IF;

    IF l_mo_hdr_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.last_updated_by := p_old_mo_hdr_rec.last_updated_by;
    END IF;

    IF l_mo_hdr_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.last_update_date := p_old_mo_hdr_rec.last_update_date;
    END IF;

    IF l_mo_hdr_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.last_update_login := p_old_mo_hdr_rec.last_update_login;
    END IF;

    IF l_mo_hdr_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.organization_id := p_old_mo_hdr_rec.organization_id;
    END IF;

    IF l_mo_hdr_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.program_application_id := p_old_mo_hdr_rec.program_application_id;
    END IF;

    IF l_mo_hdr_rec.program_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.program_id := p_old_mo_hdr_rec.program_id;
    END IF;

    IF l_mo_hdr_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.program_update_date := p_old_mo_hdr_rec.program_update_date;
    END IF;

    IF l_mo_hdr_rec.request_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.request_id := p_old_mo_hdr_rec.request_id;
    END IF;

    IF l_mo_hdr_rec.request_number = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.request_number := p_old_mo_hdr_rec.request_number;
    END IF;

    IF l_mo_hdr_rec.status_date = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.status_date := p_old_mo_hdr_rec.status_date;
    END IF;

    IF l_mo_hdr_rec.to_account_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.to_account_id := p_old_mo_hdr_rec.to_account_id;
    END IF;

    IF l_mo_hdr_rec.to_subinventory_code = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.to_subinventory_code := p_old_mo_hdr_rec.to_subinventory_code;
    END IF;

    IF l_mo_hdr_rec.move_order_type = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.move_order_type := p_old_mo_hdr_rec.move_order_type;
    END IF;

    IF l_mo_hdr_rec.transaction_type_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.transaction_type_id := p_old_mo_hdr_rec.transaction_type_id;
    END IF;

    IF l_mo_hdr_rec.ship_to_location_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.ship_to_location_id := p_old_mo_hdr_rec.ship_to_location_id;
    END IF;

    RETURN l_mo_hdr_rec;

END Complete_Record;

/*   Function Convert_Miss_To_Null  */

FUNCTION Convert_Miss_To_Null
(   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
) RETURN GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
IS
l_mo_hdr_rec                  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC := p_mo_hdr_rec;
BEGIN

    IF l_mo_hdr_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute1 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute10 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute11 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute12 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute13 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute14 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute15 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute2 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute3 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute4 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute5 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute6 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute7 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute8 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute9 := NULL;
    END IF;

    IF l_mo_hdr_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.attribute_category := NULL;
    END IF;

    IF l_mo_hdr_rec.created_by = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.created_by := NULL;
    END IF;

    IF l_mo_hdr_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.creation_date := NULL;
    END IF;

    IF l_mo_hdr_rec.date_required = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.date_required := NULL;
    END IF;

    IF l_mo_hdr_rec.description = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.description := NULL;
    END IF;

    IF l_mo_hdr_rec.from_subinventory_code = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.from_subinventory_code := NULL;
    END IF;

    IF l_mo_hdr_rec.header_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.header_id := NULL;
    END IF;

    IF l_mo_hdr_rec.header_status = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.header_status := NULL;
    END IF;

    IF l_mo_hdr_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.last_updated_by := NULL;
    END IF;

    IF l_mo_hdr_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.last_update_date := NULL;
    END IF;

    IF l_mo_hdr_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.last_update_login := NULL;
    END IF;

    IF l_mo_hdr_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.organization_id := NULL;
    END IF;

    IF l_mo_hdr_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.program_application_id := NULL;
    END IF;

    IF l_mo_hdr_rec.program_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.program_id := NULL;
    END IF;

    IF l_mo_hdr_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.program_update_date := NULL;
    END IF;

    IF l_mo_hdr_rec.request_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.request_id := NULL;
    END IF;

    IF l_mo_hdr_rec.request_number = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.request_number := NULL;
    END IF;

    IF l_mo_hdr_rec.status_date = FND_API.G_MISS_DATE THEN
        l_mo_hdr_rec.status_date := NULL;
    END IF;

    IF l_mo_hdr_rec.to_account_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.to_account_id := NULL;
    END IF;

    IF l_mo_hdr_rec.to_subinventory_code = FND_API.G_MISS_CHAR THEN
        l_mo_hdr_rec.to_subinventory_code := NULL;
    END IF;

    IF l_mo_hdr_rec.move_order_type = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.move_order_type := NULL;
    END IF;

    IF l_mo_hdr_rec.transaction_type_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.transaction_type_id := NULL;
    END IF;

    IF l_mo_hdr_rec.ship_to_location_id = FND_API.G_MISS_NUM THEN
        l_mo_hdr_rec.ship_to_location_id := NULL;
    END IF;

    RETURN l_mo_hdr_rec;

END Convert_Miss_To_Null;

/*   Procedure Update_Row  */

PROCEDURE Update_Row
(   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
)
IS
BEGIN

    UPDATE  IC_TXN_REQUEST_HEADERS
    SET     ATTRIBUTE1                     = p_mo_hdr_rec.attribute1
    ,       ATTRIBUTE10                    = p_mo_hdr_rec.attribute10
    ,       ATTRIBUTE11                    = p_mo_hdr_rec.attribute11
    ,       ATTRIBUTE12                    = p_mo_hdr_rec.attribute12
    ,       ATTRIBUTE13                    = p_mo_hdr_rec.attribute13
    ,       ATTRIBUTE14                    = p_mo_hdr_rec.attribute14
    ,       ATTRIBUTE15                    = p_mo_hdr_rec.attribute15
    ,       ATTRIBUTE2                     = p_mo_hdr_rec.attribute2
    ,       ATTRIBUTE3                     = p_mo_hdr_rec.attribute3
    ,       ATTRIBUTE4                     = p_mo_hdr_rec.attribute4
    ,       ATTRIBUTE5                     = p_mo_hdr_rec.attribute5
    ,       ATTRIBUTE6                     = p_mo_hdr_rec.attribute6
    ,       ATTRIBUTE7                     = p_mo_hdr_rec.attribute7
    ,       ATTRIBUTE8                     = p_mo_hdr_rec.attribute8
    ,       ATTRIBUTE9                     = p_mo_hdr_rec.attribute9
    ,       ATTRIBUTE_CATEGORY             = p_mo_hdr_rec.attribute_category
    ,       CREATED_BY                     = p_mo_hdr_rec.created_by
    ,       CREATION_DATE                  = p_mo_hdr_rec.creation_date
    ,       DATE_REQUIRED                  = p_mo_hdr_rec.date_required
    ,       DESCRIPTION                    = p_mo_hdr_rec.description
    ,       FROM_SUBINVENTORY_CODE         = p_mo_hdr_rec.from_subinventory_code
    ,       HEADER_ID                      = p_mo_hdr_rec.header_id
    ,       HEADER_STATUS                  = p_mo_hdr_rec.header_status
    ,       LAST_UPDATED_BY                = p_mo_hdr_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_mo_hdr_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_mo_hdr_rec.last_update_login
    ,       ORGANIZATION_ID                = p_mo_hdr_rec.organization_id
    ,       PROGRAM_APPLICATION_ID         = p_mo_hdr_rec.program_application_id
    ,       PROGRAM_ID                     = p_mo_hdr_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_mo_hdr_rec.program_update_date
    ,       REQUEST_ID                     = p_mo_hdr_rec.request_id
    ,       REQUEST_NUMBER                 = p_mo_hdr_rec.request_number
    ,       STATUS_DATE                    = p_mo_hdr_rec.status_date
    ,       TO_ACCOUNT_ID                  = p_mo_hdr_rec.to_account_id
    ,       TO_SUBINVENTORY_CODE           = p_mo_hdr_rec.to_subinventory_code
    ,       MOVE_ORDER_TYPE                = p_mo_hdr_rec.move_order_type
    ,	    TRANSACTION_TYPE_ID		   = p_mo_hdr_rec.transaction_type_id
    ,       SHIP_TO_LOCATION_ID            = p_mo_hdr_rec.ship_to_location_id
    WHERE   HEADER_ID = p_mo_hdr_rec.header_id
    ;

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


/*   Procedure Insert_Row  */

PROCEDURE Insert_Row
(   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
)
IS
BEGIN

gmi_reservation_util.println('In insert_row in GMIUMOHB.pls');
gmi_reservation_util.println('value of l_mo_hdr_rec.organization_id: '||p_mo_hdr_rec.organization_id);
gmi_reservation_util.println('Value of l_mo_hdr_rec.operation is '||p_mo_hdr_rec.request_number);

    INSERT  INTO IC_TXN_REQUEST_HEADERS
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
    ,       DESCRIPTION
    ,       FROM_SUBINVENTORY_CODE
    ,       HEADER_ID
    ,       HEADER_STATUS
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       REQUEST_NUMBER
    ,       STATUS_DATE
    ,       TO_ACCOUNT_ID
    ,       TO_SUBINVENTORY_CODE
    ,       MOVE_ORDER_TYPE
    , 	    TRANSACTION_TYPE_ID
    , 	    GROUPING_RULE_ID
    ,       SHIP_TO_LOCATION_ID
    )
    VALUES
    (       p_mo_hdr_rec.attribute1
    ,       p_mo_hdr_rec.attribute10
    ,       p_mo_hdr_rec.attribute11
    ,       p_mo_hdr_rec.attribute12
    ,       p_mo_hdr_rec.attribute13
    ,       p_mo_hdr_rec.attribute14
    ,       p_mo_hdr_rec.attribute15
    ,       p_mo_hdr_rec.attribute2
    ,       p_mo_hdr_rec.attribute3
    ,       p_mo_hdr_rec.attribute4
    ,       p_mo_hdr_rec.attribute5
    ,       p_mo_hdr_rec.attribute6
    ,       p_mo_hdr_rec.attribute7
    ,       p_mo_hdr_rec.attribute8
    ,       p_mo_hdr_rec.attribute9
    ,       p_mo_hdr_rec.attribute_category
    ,       p_mo_hdr_rec.created_by
    ,       p_mo_hdr_rec.creation_date
    ,       p_mo_hdr_rec.date_required
    ,       p_mo_hdr_rec.description
    ,       p_mo_hdr_rec.from_subinventory_code
    ,       p_mo_hdr_rec.header_id
    ,       p_mo_hdr_rec.header_status
    ,       p_mo_hdr_rec.last_updated_by
    ,       p_mo_hdr_rec.last_update_date
    ,       p_mo_hdr_rec.last_update_login
    ,       p_mo_hdr_rec.organization_id
    ,       p_mo_hdr_rec.program_application_id
    ,       p_mo_hdr_rec.program_id
    ,       p_mo_hdr_rec.program_update_date
    ,       p_mo_hdr_rec.request_id
    ,       p_mo_hdr_rec.request_number
    ,       p_mo_hdr_rec.status_date
    ,       p_mo_hdr_rec.to_account_id
    ,       p_mo_hdr_rec.to_subinventory_code
    ,       p_mo_hdr_rec.move_order_type
    ,	    p_mo_hdr_rec.transaction_type_id
    ,	    p_mo_hdr_rec.grouping_rule_id
    ,       p_mo_hdr_rec.ship_to_location_id
    );

gmi_reservation_util.println('End of isnert row');

EXCEPTION

    WHEN OTHERS THEN
    WSH_Util_Core.PrintLn('Error In Insert');
    gmi_reservation_util.println('ERROR in INSERT');
    gmi_reservation_util.println('     ERR NUM => ' || SQLERRM);
    gmi_reservation_util.println('     ERR MSG => ' || SQLCODE);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

/*   Procedure Delete_Row   */

PROCEDURE Delete_Row
(   p_header_id                     IN  NUMBER
)
IS
BEGIN

    DELETE  FROM IC_TXN_REQUEST_HEADERS
    WHERE   HEADER_ID = p_header_id
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


/*   Procedure Update_Row_Status  */

PROCEDURE Update_Row_Status
(   p_header_id              IN  Number,
    p_status                 IN  Number
)
IS
l_mo_hdr_rec        GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC;
BEGIN

       /*    l_mo_hdr_rec := INV_Trohdr_util.Query_Row( p_header_id );  */
                l_mo_hdr_rec.header_Status := p_status;
                l_mo_hdr_rec.last_update_date := SYSDATE;
                l_mo_hdr_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_mo_hdr_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

        /*         INV_Trohdr_Util.Update_Row(l_mo_hdr_rec);   */

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row_Status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row_Status;

/*    Function Query_Row   */

FUNCTION Query_Row
(   p_header_id                     IN  NUMBER
) RETURN GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
IS
l_mo_hdr_rec                  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC;
BEGIN

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
    ,       DESCRIPTION
    ,       FROM_SUBINVENTORY_CODE
    ,       HEADER_ID
    ,       HEADER_STATUS
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       REQUEST_NUMBER
    ,       STATUS_DATE
    ,       TO_ACCOUNT_ID
    ,       TO_SUBINVENTORY_CODE
    ,       MOVE_ORDER_TYPE
    ,       TRANSACTION_TYPE_ID
    , 	    GROUPING_RULE_ID
    ,       SHIP_TO_LOCATION_ID
    INTO    l_mo_hdr_rec.attribute1
    ,       l_mo_hdr_rec.attribute10
    ,       l_mo_hdr_rec.attribute11
    ,       l_mo_hdr_rec.attribute12
    ,       l_mo_hdr_rec.attribute13
    ,       l_mo_hdr_rec.attribute14
    ,       l_mo_hdr_rec.attribute15
    ,       l_mo_hdr_rec.attribute2
    ,       l_mo_hdr_rec.attribute3
    ,       l_mo_hdr_rec.attribute4
    ,       l_mo_hdr_rec.attribute5
    ,       l_mo_hdr_rec.attribute6
    ,       l_mo_hdr_rec.attribute7
    ,       l_mo_hdr_rec.attribute8
    ,       l_mo_hdr_rec.attribute9
    ,       l_mo_hdr_rec.attribute_category
    ,       l_mo_hdr_rec.created_by
    ,       l_mo_hdr_rec.creation_date
    ,       l_mo_hdr_rec.date_required
    ,       l_mo_hdr_rec.description
    ,       l_mo_hdr_rec.from_subinventory_code
    ,       l_mo_hdr_rec.header_id
    ,       l_mo_hdr_rec.header_status
    ,       l_mo_hdr_rec.last_updated_by
    ,       l_mo_hdr_rec.last_update_date
    ,       l_mo_hdr_rec.last_update_login
    ,       l_mo_hdr_rec.organization_id
    ,       l_mo_hdr_rec.program_application_id
    ,       l_mo_hdr_rec.program_id
    ,       l_mo_hdr_rec.program_update_date
    ,       l_mo_hdr_rec.request_id
    ,       l_mo_hdr_rec.request_number
    ,       l_mo_hdr_rec.status_date
    ,       l_mo_hdr_rec.to_account_id
    ,       l_mo_hdr_rec.to_subinventory_code
    ,       l_mo_hdr_rec.move_order_type
    ,       l_mo_hdr_rec.transaction_type_id
    ,	    l_mo_hdr_rec.grouping_rule_id
    ,       l_mo_hdr_rec.ship_to_location_id
    FROM    IC_TXN_REQUEST_HEADERS
    WHERE   HEADER_ID = p_header_id
    ;
    RETURN l_mo_hdr_rec;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

/*   Procedure       lock_Row   */

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_mo_hdr_rec                    IN  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
,   x_mo_hdr_rec                    OUT NOCOPY GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC
)
IS
l_mo_hdr_rec                  GMI_MOVE_ORDER_GLOBAL.MO_HDR_REC;
BEGIN

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
    ,       DESCRIPTION
    ,       FROM_SUBINVENTORY_CODE
    ,       HEADER_ID
    ,       HEADER_STATUS
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       REQUEST_NUMBER
    ,       STATUS_DATE
    ,       TO_ACCOUNT_ID
    ,       TO_SUBINVENTORY_CODE
    ,       MOVE_ORDER_TYPE
    ,       TRANSACTION_TYPE_ID
    , 	    grouping_rule_id
    ,       SHIP_TO_LOCATION_ID
    INTO    l_mo_hdr_rec.attribute1
    ,       l_mo_hdr_rec.attribute10
    ,       l_mo_hdr_rec.attribute11
    ,       l_mo_hdr_rec.attribute12
    ,       l_mo_hdr_rec.attribute13
    ,       l_mo_hdr_rec.attribute14
    ,       l_mo_hdr_rec.attribute15
    ,       l_mo_hdr_rec.attribute2
    ,       l_mo_hdr_rec.attribute3
    ,       l_mo_hdr_rec.attribute4
    ,       l_mo_hdr_rec.attribute5
    ,       l_mo_hdr_rec.attribute6
    ,       l_mo_hdr_rec.attribute7
    ,       l_mo_hdr_rec.attribute8
    ,       l_mo_hdr_rec.attribute9
    ,       l_mo_hdr_rec.attribute_category
    ,       l_mo_hdr_rec.created_by
    ,       l_mo_hdr_rec.creation_date
    ,       l_mo_hdr_rec.date_required
    ,       l_mo_hdr_rec.description
    ,       l_mo_hdr_rec.from_subinventory_code
    ,       l_mo_hdr_rec.header_id
    ,       l_mo_hdr_rec.header_status
    ,       l_mo_hdr_rec.last_updated_by
    ,       l_mo_hdr_rec.last_update_date
    ,       l_mo_hdr_rec.last_update_login
    ,       l_mo_hdr_rec.organization_id
    ,       l_mo_hdr_rec.program_application_id
    ,       l_mo_hdr_rec.program_id
    ,       l_mo_hdr_rec.program_update_date
    ,       l_mo_hdr_rec.request_id
    ,       l_mo_hdr_rec.request_number
    ,       l_mo_hdr_rec.status_date
    ,       l_mo_hdr_rec.to_account_id
    ,       l_mo_hdr_rec.to_subinventory_code
    ,       l_mo_hdr_rec.move_order_type
    ,       l_mo_hdr_rec.transaction_type_id
    ,	    l_mo_hdr_rec.grouping_rule_id
    ,       l_mo_hdr_rec.ship_to_location_id
    FROM    IC_TXN_REQUEST_HEADERS
    WHERE   HEADER_ID = p_mo_hdr_rec.header_id
        FOR UPDATE NOWAIT;

    /*   Row locked. Compare IN attributes to DB attributes.   */

    IF  INV_GLOBALS.Equal(p_mo_hdr_rec.attribute1,
                         l_mo_hdr_rec.attribute1)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute10,
                         l_mo_hdr_rec.attribute10)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute11,
                         l_mo_hdr_rec.attribute11)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute12,
                         l_mo_hdr_rec.attribute12)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute13,
                         l_mo_hdr_rec.attribute13)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute14,
                         l_mo_hdr_rec.attribute14)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute15,
                         l_mo_hdr_rec.attribute15)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute2,
                         l_mo_hdr_rec.attribute2)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute3,
                         l_mo_hdr_rec.attribute3)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute4,
                         l_mo_hdr_rec.attribute4)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute5,
                         l_mo_hdr_rec.attribute5)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute6,
                         l_mo_hdr_rec.attribute6)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute7,
                         l_mo_hdr_rec.attribute7)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute8,
                         l_mo_hdr_rec.attribute8)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute9,
                         l_mo_hdr_rec.attribute9)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.attribute_category,
                         l_mo_hdr_rec.attribute_category)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.created_by,
                         l_mo_hdr_rec.created_by)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.creation_date,
                         l_mo_hdr_rec.creation_date)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.date_required,
                         l_mo_hdr_rec.date_required)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.description,
                         l_mo_hdr_rec.description)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.from_subinventory_code,
                         l_mo_hdr_rec.from_subinventory_code)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.header_id,
                         l_mo_hdr_rec.header_id)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.header_status,
                         l_mo_hdr_rec.header_status)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.last_updated_by,
                         l_mo_hdr_rec.last_updated_by)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.last_update_date,
                         l_mo_hdr_rec.last_update_date)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.last_update_login,
                         l_mo_hdr_rec.last_update_login)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.organization_id,
                         l_mo_hdr_rec.organization_id)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.program_application_id,
                         l_mo_hdr_rec.program_application_id)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.program_id,
                         l_mo_hdr_rec.program_id)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.program_update_date,
                         l_mo_hdr_rec.program_update_date)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.request_id,
                         l_mo_hdr_rec.request_id)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.request_number,
                         l_mo_hdr_rec.request_number)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.status_date,
                         l_mo_hdr_rec.status_date)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.to_account_id,
                         l_mo_hdr_rec.to_account_id)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.to_subinventory_code,
                         l_mo_hdr_rec.to_subinventory_code)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.move_order_type,
                         l_mo_hdr_rec.move_order_type)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.transaction_type_id,
                         l_mo_hdr_rec.transaction_type_id)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.grouping_rule_id,
                         l_mo_hdr_rec.grouping_rule_id)
    AND INV_GLOBALS.Equal(p_mo_hdr_rec.ship_to_location_id,
                         l_mo_hdr_rec.ship_to_location_id)
    THEN

        /*   Row has not changed. Set out parameter.   */

        x_mo_hdr_rec                   := l_mo_hdr_rec;

        /*   Set return status   */

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_mo_hdr_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

    ELSE

        /*   Row has changed by another user.   */

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_mo_hdr_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','OE_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_mo_hdr_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_mo_hdr_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_mo_hdr_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

END GMI_Move_Order_Header_Util;

/
