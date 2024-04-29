--------------------------------------------------------
--  DDL for Package Body INV_VALIDATE_TROHDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_VALIDATE_TROHDR" AS
/* $Header: INVLTRHB.pls 120.1 2005/06/17 14:23:04 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Validate_Trohdr';

-- Header validations

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Date_Required ( p_date_required IN DATE )
RETURN NUMBER
IS
BEGIN

     return inv_validate.check_date(p_date_required,'INV_DATE_REQUIRED');

END Date_Required;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Header ( p_header_id IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_header_id IS NULL OR
        p_header_id = FND_API.G_MISS_NUM
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_HEADER_ID'),FALSE);   -- ND
            FND_MSG_PUB.Add;
        END IF;
        RETURN F;
    END IF;
    return T;
END Header;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Header_Status ( p_header_status IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_header_status IS NULL OR
        p_header_status = FND_API.G_MISS_NUM
    THEN
        RETURN T;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    MFG_LOOKUPS
    WHERE   LOOKUP_TYPE = 'MTL_TXN_REQUEST_STATUS'
      AND   p_header_status IN (1,7)
      AND   LOOKUP_CODE = p_header_status;

    RETURN T;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('INV','INV_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_HEADER_STATUS'),FALSE); -- ND
            FND_MSG_PUB.Add;

        END IF;

        RETURN F;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Header_Status;



-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Request ( p_request_id IN NUMBER )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
BEGIN
     RETURN T;
END Request;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Request_Number ( p_request_number IN VARCHAR2, p_org IN ORG )
RETURN NUMBER
IS
l_dummy                       VARCHAR2(10);
l_ret_val 		      boolean;
BEGIN

    IF p_request_number IS NULL OR
        p_request_number = FND_API.G_MISS_CHAR
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('INV','INV_REQUEST_NUMBER'),FALSE); -- ND
            FND_MSG_PUB.Add;
        END IF;
        RETURN F;


    END IF;

    l_ret_val := INV_Transfer_Order_PVT.Unique_Order(p_org.organization_id,p_request_number);

    if l_ret_val then
	RETURN T;
    else
	return F;
    end if;

END Request_Number;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
FUNCTION Status_Date ( p_status_date IN DATE )
RETURN NUMBER
IS
BEGIN

     return inv_validate.check_date(p_status_date,'INV_STATUS_DATE');

END Status_Date;


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------


--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trohdr_rec                    IN  INV_Move_Order_PUB.Trohdr_Rec_Type
,   p_old_trohdr_rec                IN  INV_Move_Order_PUB.Trohdr_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROHDR_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN


   --  Check required attributes.

    -- inv_debug.message('Org:'||to_char(p_trohdr_rec.organization_id));  */
    IF  p_trohdr_rec.organization_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Organization_id ');
            FND_MSG_PUB.Add;
        END IF;
    END IF;

    IF  p_trohdr_rec.header_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Header Id');
            FND_MSG_PUB.Add;
        END IF;
    END IF;

    --
    --  Check rest of required attributes here.
    --
    -- if the transaction type is account transfer, then check
    --   if to_account and required date is not null


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Done validating entity

    x_return_status := l_return_status;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trohdr_rec                    IN OUT NOCOPY  INV_Move_Order_PUB.Trohdr_Rec_Type
,   p_trohdr_val_rec                    IN  INV_Move_Order_PUB.Trohdr_Val_Rec_Type
,   p_old_trohdr_rec                IN  INV_Move_Order_PUB.Trohdr_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROHDR_REC
)
IS
BEGIN


   x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate trohdr attributes
    -- inv_debug.message('Calling validate org 1');

    IF  p_trohdr_rec.organization_id IS NULL
      AND p_trohdr_val_rec.organization IS NOT NULL
    THEN
       p_trohdr_rec.organization_id := INV_Value_To_Id.Organization(p_trohdr_val_rec.organization);
    END IF;

    --inv_debug.message('Calling validate org '||to_char(p_trohdr_rec.organization_id));
    IF  p_trohdr_rec.organization_id IS NOT NULL --AND
/*        (   p_trohdr_rec.organization_id <>
            p_old_trohdr_rec.organization_id OR
            p_old_trohdr_rec.organization_id IS NULL )*/
    THEN
       g_org.organization_id := p_trohdr_rec.organization_id;
       IF INV_Validate.Organization(g_org) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;


    IF  p_trohdr_rec.transaction_type_id IS NOT NULL AND
      (   p_trohdr_rec.transaction_type_id <>
	  p_old_trohdr_rec.transaction_type_id OR
	  p_old_trohdr_rec.transaction_type_id IS NULL )
    THEN
       g_transaction.transaction_type_id := p_trohdr_rec.transaction_type_id;
       IF INV_Validate.Transaction_type(g_transaction) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;


    -- inv_debug.message('Calling validate created_by');
    IF  p_trohdr_rec.created_by IS NOT NULL AND
        (   p_trohdr_rec.created_by <>
            p_old_trohdr_rec.created_by OR
            p_old_trohdr_rec.created_by IS NULL )
    THEN
       IF INV_Validate.Created_By(p_trohdr_rec.created_by) = inv_validate.F
	 THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;




    -- inv_debug.message('Calling validate created_date');
    IF  p_trohdr_rec.creation_date IS NOT NULL AND
        (   p_trohdr_rec.creation_date <>
            p_old_trohdr_rec.creation_date OR
            p_old_trohdr_rec.creation_date IS NULL )
    THEN
        IF INV_Validate.Creation_Date(p_trohdr_rec.creation_date) = inv_validate.F
	  THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    -- inv_debug.message('Calling validate date required');
    IF  p_trohdr_rec.date_required IS NOT NULL AND
        (   p_trohdr_rec.date_required <>
            p_old_trohdr_rec.date_required OR
            p_old_trohdr_rec.date_required IS NULL )
    THEN
        IF Date_Required(p_trohdr_rec.date_required) = F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    -- inv_debug.message('Calling validate description');
    IF  p_trohdr_rec.description IS NOT NULL AND
        (   p_trohdr_rec.description <>
            p_old_trohdr_rec.description OR
            p_old_trohdr_rec.description IS NULL )
    THEN
        IF INV_Validate.Description(p_trohdr_rec.description) =
	  inv_validate.F
	  THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    -- inv_debug.message('Calling validate transaction type');
    IF  p_trohdr_rec.move_order_type IS NOT NULL AND
        (   p_trohdr_rec.move_order_type <>
            p_old_trohdr_rec.move_order_type OR
            p_old_trohdr_rec.move_order_type IS NULL )
    THEN
        --IF NOT INV_Validate.Move_Order_Type(p_trohdr_rec.move_order_type) THEN
        --    x_return_status := FND_API.G_RET_STS_ERROR;
        --END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;


    -- inv_debug.message('Calling validate header id');
    IF  p_trohdr_rec.header_id IS NOT NULL AND
        (   p_trohdr_rec.header_id <>
            p_old_trohdr_rec.header_id OR
            p_old_trohdr_rec.header_id IS NULL )
    THEN
        IF Header(p_trohdr_rec.header_id) = F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    -- inv_debug.message('Calling validate header status');
    IF  p_trohdr_rec.header_status IS NOT NULL AND
        (   p_trohdr_rec.header_status <>
            p_old_trohdr_rec.header_status OR
            p_old_trohdr_rec.header_status IS NULL )
    THEN
        IF Header_Status(p_trohdr_rec.header_status) = F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    -- inv_debug.message('Calling validate last updated by');
    IF  p_trohdr_rec.last_updated_by IS NOT NULL AND
        (   p_trohdr_rec.last_updated_by <>
            p_old_trohdr_rec.last_updated_by OR
            p_old_trohdr_rec.last_updated_by IS NULL )
    THEN
        IF INV_Validate.Last_Updated_By(p_trohdr_rec.last_updated_by) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    -- inv_debug.message('Calling validate last update date');
    IF  p_trohdr_rec.last_update_date IS NOT NULL AND
        (   p_trohdr_rec.last_update_date <>
            p_old_trohdr_rec.last_update_date OR
            p_old_trohdr_rec.last_update_date IS NULL )
    THEN
        IF INV_Validate.Last_Update_Date(p_trohdr_rec.last_update_date) =
	  inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    -- inv_debug.message('Calling validate last update login');
    IF  p_trohdr_rec.last_update_login IS NOT NULL AND
        (   p_trohdr_rec.last_update_login <>
            p_old_trohdr_rec.last_update_login OR
            p_old_trohdr_rec.last_update_login IS NULL )
    THEN
       IF
	 INV_Validate.Last_Update_Login(p_trohdr_rec.last_update_login)=
	 inv_validate.F
       	 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_trohdr_rec.program_application_id IS NOT NULL AND
        (   p_trohdr_rec.program_application_id <>
            p_old_trohdr_rec.program_application_id OR
            p_old_trohdr_rec.program_application_id IS NULL )
    THEN
        IF
	  INV_Validate.Program_Application(p_trohdr_rec.program_application_id)  = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_trohdr_rec.program_id IS NOT NULL AND
        (   p_trohdr_rec.program_id <>
            p_old_trohdr_rec.program_id OR
            p_old_trohdr_rec.program_id IS NULL )
    THEN
        IF INV_Validate.Program(p_trohdr_rec.program_id) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_trohdr_rec.program_update_date IS NOT NULL AND
        (   p_trohdr_rec.program_update_date <>
            p_old_trohdr_rec.program_update_date OR
            p_old_trohdr_rec.program_update_date IS NULL )
    THEN
        IF
	  INV_Validate.Program_Update_Date(p_trohdr_rec.program_update_date)= inv_validate.F THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_trohdr_rec.request_id IS NOT NULL AND
        (   p_trohdr_rec.request_id <>
            p_old_trohdr_rec.request_id OR
            p_old_trohdr_rec.request_id IS NULL )
    THEN
        IF Request(p_trohdr_rec.request_id) = F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    -- inv_debug.message('Calling validate request number');
    IF  p_trohdr_rec.request_number IS NOT NULL AND
        (   p_trohdr_rec.request_number <>
            p_old_trohdr_rec.request_number OR
            p_old_trohdr_rec.request_number IS NULL )
    THEN
        IF Request_Number(p_trohdr_rec.request_number,g_org) = F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_trohdr_rec.status_date IS NOT NULL AND
        (   p_trohdr_rec.status_date <>
            p_old_trohdr_rec.status_date OR
            p_old_trohdr_rec.status_date IS NULL )
    THEN
        IF Status_Date(p_trohdr_rec.status_date) =  F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_trohdr_rec.to_account_id IS NULL
        AND p_trohdr_val_rec.to_account IS NOT NULL
    THEN
       p_trohdr_rec.to_account_id := INV_Value_To_Id.To_Account(p_trohdr_rec.organization_id,
                                                             p_trohdr_val_rec.to_account);
    END IF;

    IF  p_trohdr_rec.to_account_id IS NOT NULL AND
        (   p_trohdr_rec.to_account_id <>
            p_old_trohdr_rec.to_account_id OR
            p_old_trohdr_rec.to_account_id IS NULL )
    THEN
        IF INV_Validate.To_Account(p_trohdr_rec.to_account_id) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF p_trohdr_rec.ship_to_location_id IS NOT NULL AND
        (   p_trohdr_rec.ship_to_location_id <>
            p_old_trohdr_rec.ship_to_location_id OR
            p_old_trohdr_rec.ship_to_location_id IS NULL )
    THEN
        IF INV_Validate.hr_location(p_trohdr_rec.ship_to_location_id) = INV_Validate.F
        THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_trohdr_rec.attribute1 IS NOT NULL AND
        (   p_trohdr_rec.attribute1 <>
            p_old_trohdr_rec.attribute1 OR
            p_old_trohdr_rec.attribute1 IS NULL ))
    OR  (p_trohdr_rec.attribute10 IS NOT NULL AND
        (   p_trohdr_rec.attribute10 <>
            p_old_trohdr_rec.attribute10 OR
            p_old_trohdr_rec.attribute10 IS NULL ))
    OR  (p_trohdr_rec.attribute11 IS NOT NULL AND
        (   p_trohdr_rec.attribute11 <>
            p_old_trohdr_rec.attribute11 OR
            p_old_trohdr_rec.attribute11 IS NULL ))
    OR  (p_trohdr_rec.attribute12 IS NOT NULL AND
        (   p_trohdr_rec.attribute12 <>
            p_old_trohdr_rec.attribute12 OR
            p_old_trohdr_rec.attribute12 IS NULL ))
    OR  (p_trohdr_rec.attribute13 IS NOT NULL AND
        (   p_trohdr_rec.attribute13 <>
            p_old_trohdr_rec.attribute13 OR
            p_old_trohdr_rec.attribute13 IS NULL ))
    OR  (p_trohdr_rec.attribute14 IS NOT NULL AND
        (   p_trohdr_rec.attribute14 <>
            p_old_trohdr_rec.attribute14 OR
            p_old_trohdr_rec.attribute14 IS NULL ))
    OR  (p_trohdr_rec.attribute15 IS NOT NULL AND
        (   p_trohdr_rec.attribute15 <>
            p_old_trohdr_rec.attribute15 OR
            p_old_trohdr_rec.attribute15 IS NULL ))
    OR  (p_trohdr_rec.attribute2 IS NOT NULL AND
        (   p_trohdr_rec.attribute2 <>
            p_old_trohdr_rec.attribute2 OR
            p_old_trohdr_rec.attribute2 IS NULL ))
    OR  (p_trohdr_rec.attribute3 IS NOT NULL AND
        (   p_trohdr_rec.attribute3 <>
            p_old_trohdr_rec.attribute3 OR
            p_old_trohdr_rec.attribute3 IS NULL ))
    OR  (p_trohdr_rec.attribute4 IS NOT NULL AND
        (   p_trohdr_rec.attribute4 <>
            p_old_trohdr_rec.attribute4 OR
            p_old_trohdr_rec.attribute4 IS NULL ))
    OR  (p_trohdr_rec.attribute5 IS NOT NULL AND
        (   p_trohdr_rec.attribute5 <>
            p_old_trohdr_rec.attribute5 OR
            p_old_trohdr_rec.attribute5 IS NULL ))
    OR  (p_trohdr_rec.attribute6 IS NOT NULL AND
        (   p_trohdr_rec.attribute6 <>
            p_old_trohdr_rec.attribute6 OR
            p_old_trohdr_rec.attribute6 IS NULL ))
    OR  (p_trohdr_rec.attribute7 IS NOT NULL AND
        (   p_trohdr_rec.attribute7 <>
            p_old_trohdr_rec.attribute7 OR
            p_old_trohdr_rec.attribute7 IS NULL ))
    OR  (p_trohdr_rec.attribute8 IS NOT NULL AND
        (   p_trohdr_rec.attribute8 <>
            p_old_trohdr_rec.attribute8 OR
            p_old_trohdr_rec.attribute8 IS NULL ))
    OR  (p_trohdr_rec.attribute9 IS NOT NULL AND
        (   p_trohdr_rec.attribute9 <>
            p_old_trohdr_rec.attribute9 OR
            p_old_trohdr_rec.attribute9 IS NULL ))
    OR  (p_trohdr_rec.attribute_category IS NOT NULL AND
        (   p_trohdr_rec.attribute_category <>
            p_old_trohdr_rec.attribute_category OR
            p_old_trohdr_rec.attribute_category IS NULL ))
    THEN

    --  These calls are temporarily commented out

        --  Validate descriptive flexfield.

        IF INV_Validate.Desc_Flex( 'TROHDR' ) = inv_validate.F THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_trohdr_rec                    IN  INV_Move_Order_PUB.Trohdr_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END INV_Validate_Trohdr;

/
