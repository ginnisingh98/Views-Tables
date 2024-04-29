--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_HEADER_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_HEADER_PATTR" AS
/* $Header: OEXLHPAB.pls 120.1.12000000.3 2007/04/27 05:50:56 jisingh ship $ */

--  Global constant holding the package name

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'OE_Validate_Header_Pattr';

--  Procedure Entity

PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Price_Attr_rec        IN  OE_Order_PUB.Header_Price_Att_Rec_Type
,   p_old_Header_Price_Attr_rec    IN  OE_Order_PUB.Header_Price_Att_Rec_Type
                                       := OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_REC
)
IS
l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_VALIDATE_HEADER_PATTR.ENTITY' , 1 ) ;
    END IF;

    --  Check required attributes.

    IF  p_Header_Price_Attr_rec.order_price_attrib_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute1');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --


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


    --  Done validating entity

    x_return_status := l_return_status;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_VALIDATE_HEADER_PATTR.ENTITY' , 1 ) ;
    END IF;
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
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Price_Attr_rec        IN  OE_Order_PUB.Header_Price_Att_Rec_Type
,   p_old_Header_Price_Attr_rec    IN  OE_Order_PUB.Header_Price_Att_Rec_Type := OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_REC
,   p_validation_level  		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL
)
IS
l_column_prefix	varchar2(20);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_VALIDATE_HEADER_PATTR.ATTRIBUTES' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Line_Pricing_PAttr attributes

    IF  p_Header_Price_Attr_rec.created_by IS NOT NULL AND
        (   p_Header_Price_Attr_rec.created_by <>
            p_old_Header_Price_Attr_rec.created_by OR
            p_old_Header_Price_Attr_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Created_By(p_Header_Price_Attr_rec.created_by)        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.creation_date IS NOT NULL AND
        (   p_Header_Price_Attr_rec.creation_date <>
            p_old_Header_Price_Attr_rec.creation_date OR
            p_old_Header_Price_Attr_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Creation_Date
          (p_Header_Price_Attr_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.flex_title IS NOT NULL AND
        (   p_Header_Price_Attr_rec.flex_title <>
            p_old_Header_Price_Attr_rec.flex_title OR
            p_old_Header_Price_Attr_rec.flex_title IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Flex_Title
           (p_Header_Price_Attr_rec.flex_title) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.header_id IS NOT NULL AND
        (   p_Header_Price_Attr_rec.header_id <>
            p_old_Header_Price_Attr_rec.header_id OR
            p_old_Header_Price_Attr_rec.header_id IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Header(p_Header_Price_Attr_rec.header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.last_updated_by IS NOT NULL AND
        (   p_Header_Price_Attr_rec.last_updated_by <>
            p_old_Header_Price_Attr_rec.last_updated_by OR
            p_old_Header_Price_Attr_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Last_Updated_By
           (p_Header_Price_Attr_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.last_update_date IS NOT NULL AND
        (   p_Header_Price_Attr_rec.last_update_date <>
            p_old_Header_Price_Attr_rec.last_update_date OR
            p_old_Header_Price_Attr_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Last_Update_Date
           (p_Header_Price_Attr_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.last_update_login IS NOT NULL AND
        (   p_Header_Price_Attr_rec.last_update_login <>
            p_old_Header_Price_Attr_rec.last_update_login OR
            p_old_Header_Price_Attr_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Last_Update_Login
           (p_Header_Price_Attr_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.override_flag IS NOT NULL AND
        (   p_Header_Price_Attr_rec.override_flag <>
            p_old_Header_Price_Attr_rec.override_flag OR
            p_old_Header_Price_Attr_rec.override_flag IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Override_Flag
          (p_Header_Price_Attr_rec.override_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Header_Price_Attr_rec.line_id IS NOT NULL AND
        (   p_Header_Price_Attr_rec.line_id <>
            p_old_Header_Price_Attr_rec.line_id OR
            p_old_Header_Price_Attr_rec.line_id IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Line(p_Header_Price_Attr_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.order_price_attrib_id IS NOT NULL AND
        (   p_Header_Price_Attr_rec.order_price_attrib_id <>
            p_old_Header_Price_Attr_rec.order_price_attrib_id OR
            p_old_Header_Price_Attr_rec.order_price_attrib_id IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Order_Price_Attrib
           (p_Header_Price_Attr_rec.order_price_attrib_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.program_application_id IS NOT NULL AND
        (   p_Header_Price_Attr_rec.program_application_id <>
            p_old_Header_Price_Attr_rec.program_application_id OR
            p_old_Header_Price_Attr_rec.program_application_id IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Program_Application
           (p_Header_Price_Attr_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.program_id IS NOT NULL AND
        (   p_Header_Price_Attr_rec.program_id <>
            p_old_Header_Price_Attr_rec.program_id OR
            p_old_Header_Price_Attr_rec.program_id IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Program
           (p_Header_Price_Attr_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.program_update_date IS NOT NULL AND
        (   p_Header_Price_Attr_rec.program_update_date <>
            p_old_Header_Price_Attr_rec.program_update_date OR
            p_old_Header_Price_Attr_rec.program_update_date IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Program_Update_Date
           (p_Header_Price_Attr_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Header_Price_Attr_rec.request_id IS NOT NULL AND
        (   p_Header_Price_Attr_rec.request_id <>
            p_old_Header_Price_Attr_rec.request_id OR
            p_old_Header_Price_Attr_rec.request_id IS NULL )
    THEN
        IF NOT OE_Validate_Adj.Request
          (p_Header_Price_Attr_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    if OE_GLOBALS.g_validate_desc_flex ='Y' then --4343612
     oe_debug_pub.add('Validation of desc flex is set to Y in OE_Validate_Header_PAttr.attributes ',1);
    IF  (p_Header_Price_Attr_rec.attribute1 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute1 <>
            p_old_Header_Price_Attr_rec.attribute1 OR
            p_old_Header_Price_Attr_rec.attribute1 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute10 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute10 <>
            p_old_Header_Price_Attr_rec.attribute10 OR
            p_old_Header_Price_Attr_rec.attribute10 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute11 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute11 <>
            p_old_Header_Price_Attr_rec.attribute11 OR
            p_old_Header_Price_Attr_rec.attribute11 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute12 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute12 <>
            p_old_Header_Price_Attr_rec.attribute12 OR
            p_old_Header_Price_Attr_rec.attribute12 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute13 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute13 <>
            p_old_Header_Price_Attr_rec.attribute13 OR
            p_old_Header_Price_Attr_rec.attribute13 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute14 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute14 <>
            p_old_Header_Price_Attr_rec.attribute14 OR
            p_old_Header_Price_Attr_rec.attribute14 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute15 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute15 <>
            p_old_Header_Price_Attr_rec.attribute15 OR
            p_old_Header_Price_Attr_rec.attribute15 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute2 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute2 <>
            p_old_Header_Price_Attr_rec.attribute2 OR
            p_old_Header_Price_Attr_rec.attribute2 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute3 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute3 <>
            p_old_Header_Price_Attr_rec.attribute3 OR
            p_old_Header_Price_Attr_rec.attribute3 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute4 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute4 <>
            p_old_Header_Price_Attr_rec.attribute4 OR
            p_old_Header_Price_Attr_rec.attribute4 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute5 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute5 <>
            p_old_Header_Price_Attr_rec.attribute5 OR
            p_old_Header_Price_Attr_rec.attribute5 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute6 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute6 <>
            p_old_Header_Price_Attr_rec.attribute6 OR
            p_old_Header_Price_Attr_rec.attribute6 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute7 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute7 <>
            p_old_Header_Price_Attr_rec.attribute7 OR
            p_old_Header_Price_Attr_rec.attribute7 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute8 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute8 <>
            p_old_Header_Price_Attr_rec.attribute8 OR
            p_old_Header_Price_Attr_rec.attribute8 IS NULL ))
    OR  (p_Header_Price_Attr_rec.attribute9 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.attribute9 <>
            p_old_Header_Price_Attr_rec.attribute9 OR
            p_old_Header_Price_Attr_rec.attribute9 IS NULL ))
    OR  (p_Header_Price_Attr_rec.context IS NOT NULL AND
        (   p_Header_Price_Attr_rec.context <>
            p_old_Header_Price_Attr_rec.context OR
            p_old_Header_Price_Attr_rec.context IS NULL ))
    THEN



        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE1'
        ,   column_value              => p_Header_Price_Attr_rec.attribute1
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE10'
        ,   column_value              => p_Header_Price_Attr_rec.attribute10
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE11'
        ,   column_value              => p_Header_Price_Attr_rec.attribute11
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE12'
        ,   column_value              => p_Header_Price_Attr_rec.attribute12
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE13'
        ,   column_value              => p_Header_Price_Attr_rec.attribute13
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE14'
        ,   column_value              => p_Header_Price_Attr_rec.attribute14
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE15'
        ,   column_value              => p_Header_Price_Attr_rec.attribute15
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE2'
        ,   column_value              => p_Header_Price_Attr_rec.attribute2
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE3'
        ,   column_value              => p_Header_Price_Attr_rec.attribute3
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE4'
        ,   column_value              => p_Header_Price_Attr_rec.attribute4
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE5'
        ,   column_value              => p_Header_Price_Attr_rec.attribute5
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE6'
        ,   column_value              => p_Header_Price_Attr_rec.attribute6
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE7'
        ,   column_value              => p_Header_Price_Attr_rec.attribute7
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE8'
        ,   column_value              => p_Header_Price_Attr_rec.attribute8
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'ATTRIBUTE9'
        ,   column_value              => p_Header_Price_Attr_rec.attribute9
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name               => 'CONTEXT'
        ,   column_value              => p_Header_Price_Attr_rec.context
        );


    END IF;

    IF  (p_Header_Price_Attr_rec.pricing_attribute1 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute1 <>
            p_old_Header_Price_Attr_rec.pricing_attribute1 OR
            p_old_Header_Price_Attr_rec.pricing_attribute1 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute2 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute2 <>
            p_old_Header_Price_Attr_rec.pricing_attribute2 OR
            p_old_Header_Price_Attr_rec.pricing_attribute2 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute3 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute3 <>
            p_old_Header_Price_Attr_rec.pricing_attribute3 OR
            p_old_Header_Price_Attr_rec.pricing_attribute3 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute4 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute4 <>
            p_old_Header_Price_Attr_rec.pricing_attribute4 OR
            p_old_Header_Price_Attr_rec.pricing_attribute4 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute5 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute5 <>
            p_old_Header_Price_Attr_rec.pricing_attribute5 OR
            p_old_Header_Price_Attr_rec.pricing_attribute5 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute6 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute6 <>
            p_old_Header_Price_Attr_rec.pricing_attribute6 OR
            p_old_Header_Price_Attr_rec.pricing_attribute6 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute7 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute7 <>
            p_old_Header_Price_Attr_rec.pricing_attribute7 OR
            p_old_Header_Price_Attr_rec.pricing_attribute7 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute8 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute8 <>
            p_old_Header_Price_Attr_rec.pricing_attribute8 OR
            p_old_Header_Price_Attr_rec.pricing_attribute8 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute9 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute9 <>
            p_old_Header_Price_Attr_rec.pricing_attribute9 OR
            p_old_Header_Price_Attr_rec.pricing_attribute9 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_context IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_context <>
            p_old_Header_Price_Attr_rec.pricing_context OR
            p_old_Header_Price_Attr_rec.pricing_context IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute10 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute10 <>
            p_old_Header_Price_Attr_rec.pricing_attribute10 OR
            p_old_Header_Price_Attr_rec.pricing_attribute10 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute11 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute11 <>
            p_old_Header_Price_Attr_rec.pricing_attribute11 OR
            p_old_Header_Price_Attr_rec.pricing_attribute11 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute12 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute12 <>
            p_old_Header_Price_Attr_rec.pricing_attribute12 OR
            p_old_Header_Price_Attr_rec.pricing_attribute12 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute13 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute13 <>
            p_old_Header_Price_Attr_rec.pricing_attribute13 OR
            p_old_Header_Price_Attr_rec.pricing_attribute13 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute14 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute14 <>
            p_old_Header_Price_Attr_rec.pricing_attribute14 OR
            p_old_Header_Price_Attr_rec.pricing_attribute14 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute15 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute15 <>
            p_old_Header_Price_Attr_rec.pricing_attribute15 OR
            p_old_Header_Price_Attr_rec.pricing_attribute15 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute16 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute16 <>
            p_old_Header_Price_Attr_rec.pricing_attribute16 OR
            p_old_Header_Price_Attr_rec.pricing_attribute16 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute17 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute17 <>
            p_old_Header_Price_Attr_rec.pricing_attribute17 OR
            p_old_Header_Price_Attr_rec.pricing_attribute17 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute18 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute18 <>
            p_old_Header_Price_Attr_rec.pricing_attribute18 OR
            p_old_Header_Price_Attr_rec.pricing_attribute18 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute19 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute19 <>
            p_old_Header_Price_Attr_rec.pricing_attribute19 OR
            p_old_Header_Price_Attr_rec.pricing_attribute19 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute20 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute20 <>
            p_old_Header_Price_Attr_rec.pricing_attribute20 OR
            p_old_Header_Price_Attr_rec.pricing_attribute20 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute21 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute21 <>
            p_old_Header_Price_Attr_rec.pricing_attribute21 OR
            p_old_Header_Price_Attr_rec.pricing_attribute21 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute22 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute22 <>
            p_old_Header_Price_Attr_rec.pricing_attribute22 OR
            p_old_Header_Price_Attr_rec.pricing_attribute22 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute23 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute23 <>
            p_old_Header_Price_Attr_rec.pricing_attribute23 OR
            p_old_Header_Price_Attr_rec.pricing_attribute23 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute24 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute24 <>
            p_old_Header_Price_Attr_rec.pricing_attribute24 OR
            p_old_Header_Price_Attr_rec.pricing_attribute24 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute25 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute25 <>
            p_old_Header_Price_Attr_rec.pricing_attribute25 OR
            p_old_Header_Price_Attr_rec.pricing_attribute25 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute26 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute26 <>
            p_old_Header_Price_Attr_rec.pricing_attribute26 OR
            p_old_Header_Price_Attr_rec.pricing_attribute26 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute27 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute27 <>
            p_old_Header_Price_Attr_rec.pricing_attribute27 OR
            p_old_Header_Price_Attr_rec.pricing_attribute27 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute28 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute28 <>
            p_old_Header_Price_Attr_rec.pricing_attribute28 OR
            p_old_Header_Price_Attr_rec.pricing_attribute28 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute29 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute29 <>
            p_old_Header_Price_Attr_rec.pricing_attribute29 OR
            p_old_Header_Price_Attr_rec.pricing_attribute29 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute30 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute30 <>
            p_old_Header_Price_Attr_rec.pricing_attribute30 OR
            p_old_Header_Price_Attr_rec.pricing_attribute30 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute31 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute31 <>
            p_old_Header_Price_Attr_rec.pricing_attribute31 OR
            p_old_Header_Price_Attr_rec.pricing_attribute31 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute32 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute32 <>
            p_old_Header_Price_Attr_rec.pricing_attribute32 OR
            p_old_Header_Price_Attr_rec.pricing_attribute32 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute33 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute33 <>
            p_old_Header_Price_Attr_rec.pricing_attribute33 OR
            p_old_Header_Price_Attr_rec.pricing_attribute33 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute34 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute34 <>
            p_old_Header_Price_Attr_rec.pricing_attribute34 OR
            p_old_Header_Price_Attr_rec.pricing_attribute34 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute35 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute35 <>
            p_old_Header_Price_Attr_rec.pricing_attribute35 OR
            p_old_Header_Price_Attr_rec.pricing_attribute35 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute36 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute36 <>
            p_old_Header_Price_Attr_rec.pricing_attribute36 OR
            p_old_Header_Price_Attr_rec.pricing_attribute36 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute37 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute37 <>
            p_old_Header_Price_Attr_rec.pricing_attribute37 OR
            p_old_Header_Price_Attr_rec.pricing_attribute37 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute38 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute38 <>
            p_old_Header_Price_Attr_rec.pricing_attribute38 OR
            p_old_Header_Price_Attr_rec.pricing_attribute38 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute39 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute39 <>
            p_old_Header_Price_Attr_rec.pricing_attribute39 OR
            p_old_Header_Price_Attr_rec.pricing_attribute39 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute40 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute40 <>
            p_old_Header_Price_Attr_rec.pricing_attribute40 OR
            p_old_Header_Price_Attr_rec.pricing_attribute40 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute41 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute41 <>
            p_old_Header_Price_Attr_rec.pricing_attribute41 OR
            p_old_Header_Price_Attr_rec.pricing_attribute41 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute42 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute42 <>
            p_old_Header_Price_Attr_rec.pricing_attribute42 OR
            p_old_Header_Price_Attr_rec.pricing_attribute42 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute43 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute43 <>
            p_old_Header_Price_Attr_rec.pricing_attribute43 OR
            p_old_Header_Price_Attr_rec.pricing_attribute43 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute44 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute44 <>
            p_old_Header_Price_Attr_rec.pricing_attribute44 OR
            p_old_Header_Price_Attr_rec.pricing_attribute44 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute45 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute45 <>
            p_old_Header_Price_Attr_rec.pricing_attribute45 OR
            p_old_Header_Price_Attr_rec.pricing_attribute45 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute46 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute46 <>
            p_old_Header_Price_Attr_rec.pricing_attribute46 OR
            p_old_Header_Price_Attr_rec.pricing_attribute46 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute47 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute47 <>
            p_old_Header_Price_Attr_rec.pricing_attribute47 OR
            p_old_Header_Price_Attr_rec.pricing_attribute47 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute48 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute48 <>
            p_old_Header_Price_Attr_rec.pricing_attribute48 OR
            p_old_Header_Price_Attr_rec.pricing_attribute48 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute49 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute49 <>
            p_old_Header_Price_Attr_rec.pricing_attribute49 OR
            p_old_Header_Price_Attr_rec.pricing_attribute49 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute50 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute50 <>
            p_old_Header_Price_Attr_rec.pricing_attribute50 OR
            p_old_Header_Price_Attr_rec.pricing_attribute50 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute51 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute51 <>
            p_old_Header_Price_Attr_rec.pricing_attribute51 OR
            p_old_Header_Price_Attr_rec.pricing_attribute51 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute52 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute52 <>
            p_old_Header_Price_Attr_rec.pricing_attribute52 OR
            p_old_Header_Price_Attr_rec.pricing_attribute52 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute53 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute53 <>
            p_old_Header_Price_Attr_rec.pricing_attribute53 OR
            p_old_Header_Price_Attr_rec.pricing_attribute53 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute54 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute54 <>
            p_old_Header_Price_Attr_rec.pricing_attribute54 OR
            p_old_Header_Price_Attr_rec.pricing_attribute54 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute55 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute55 <>
            p_old_Header_Price_Attr_rec.pricing_attribute55 OR
            p_old_Header_Price_Attr_rec.pricing_attribute55 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute56 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute56 <>
            p_old_Header_Price_Attr_rec.pricing_attribute56 OR
            p_old_Header_Price_Attr_rec.pricing_attribute56 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute57 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute57 <>
            p_old_Header_Price_Attr_rec.pricing_attribute57 OR
            p_old_Header_Price_Attr_rec.pricing_attribute57 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute58 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute58 <>
            p_old_Header_Price_Attr_rec.pricing_attribute58 OR
            p_old_Header_Price_Attr_rec.pricing_attribute58 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute59 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute59 <>
            p_old_Header_Price_Attr_rec.pricing_attribute59 OR
            p_old_Header_Price_Attr_rec.pricing_attribute59 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute60 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute60 <>
            p_old_Header_Price_Attr_rec.pricing_attribute60 OR
            p_old_Header_Price_Attr_rec.pricing_attribute60 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute61 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute61 <>
            p_old_Header_Price_Attr_rec.pricing_attribute61 OR
            p_old_Header_Price_Attr_rec.pricing_attribute61 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute62 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute62 <>
            p_old_Header_Price_Attr_rec.pricing_attribute62 OR
            p_old_Header_Price_Attr_rec.pricing_attribute62 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute63 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute63 <>
            p_old_Header_Price_Attr_rec.pricing_attribute63 OR
            p_old_Header_Price_Attr_rec.pricing_attribute63 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute64 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute64 <>
            p_old_Header_Price_Attr_rec.pricing_attribute64 OR
            p_old_Header_Price_Attr_rec.pricing_attribute64 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute65 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute65 <>
            p_old_Header_Price_Attr_rec.pricing_attribute65 OR
            p_old_Header_Price_Attr_rec.pricing_attribute65 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute66 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute66 <>
            p_old_Header_Price_Attr_rec.pricing_attribute66 OR
            p_old_Header_Price_Attr_rec.pricing_attribute66 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute67 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute67 <>
            p_old_Header_Price_Attr_rec.pricing_attribute67 OR
            p_old_Header_Price_Attr_rec.pricing_attribute67 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute68 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute68 <>
            p_old_Header_Price_Attr_rec.pricing_attribute68 OR
            p_old_Header_Price_Attr_rec.pricing_attribute68 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute69 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute69 <>
            p_old_Header_Price_Attr_rec.pricing_attribute69 OR
            p_old_Header_Price_Attr_rec.pricing_attribute69 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute70 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute70 <>
            p_old_Header_Price_Attr_rec.pricing_attribute70 OR
            p_old_Header_Price_Attr_rec.pricing_attribute70 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute71 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute71 <>
            p_old_Header_Price_Attr_rec.pricing_attribute71 OR
            p_old_Header_Price_Attr_rec.pricing_attribute71 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute72 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute72 <>
            p_old_Header_Price_Attr_rec.pricing_attribute72 OR
            p_old_Header_Price_Attr_rec.pricing_attribute72 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute73 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute73 <>
            p_old_Header_Price_Attr_rec.pricing_attribute73 OR
            p_old_Header_Price_Attr_rec.pricing_attribute73 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute74 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute74 <>
            p_old_Header_Price_Attr_rec.pricing_attribute74 OR
            p_old_Header_Price_Attr_rec.pricing_attribute74 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute75 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute75 <>
            p_old_Header_Price_Attr_rec.pricing_attribute75 OR
            p_old_Header_Price_Attr_rec.pricing_attribute75 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute76 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute76 <>
            p_old_Header_Price_Attr_rec.pricing_attribute76 OR
            p_old_Header_Price_Attr_rec.pricing_attribute76 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute77 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute77 <>
            p_old_Header_Price_Attr_rec.pricing_attribute77 OR
            p_old_Header_Price_Attr_rec.pricing_attribute77 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute78 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute78 <>
            p_old_Header_Price_Attr_rec.pricing_attribute78 OR
            p_old_Header_Price_Attr_rec.pricing_attribute78 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute79 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute79 <>
            p_old_Header_Price_Attr_rec.pricing_attribute79 OR
            p_old_Header_Price_Attr_rec.pricing_attribute79 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute80 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute80 <>
            p_old_Header_Price_Attr_rec.pricing_attribute80 OR
            p_old_Header_Price_Attr_rec.pricing_attribute80 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute81 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute81 <>
            p_old_Header_Price_Attr_rec.pricing_attribute81 OR
            p_old_Header_Price_Attr_rec.pricing_attribute81 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute82 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute82 <>
            p_old_Header_Price_Attr_rec.pricing_attribute82 OR
            p_old_Header_Price_Attr_rec.pricing_attribute82 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute83 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute83 <>
            p_old_Header_Price_Attr_rec.pricing_attribute83 OR
            p_old_Header_Price_Attr_rec.pricing_attribute83 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute84 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute84 <>
            p_old_Header_Price_Attr_rec.pricing_attribute84 OR
            p_old_Header_Price_Attr_rec.pricing_attribute84 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute85 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute85 <>
            p_old_Header_Price_Attr_rec.pricing_attribute85 OR
            p_old_Header_Price_Attr_rec.pricing_attribute85 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute86 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute86 <>
            p_old_Header_Price_Attr_rec.pricing_attribute86 OR
            p_old_Header_Price_Attr_rec.pricing_attribute86 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute87 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute87 <>
            p_old_Header_Price_Attr_rec.pricing_attribute87 OR
            p_old_Header_Price_Attr_rec.pricing_attribute87 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute88 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute88 <>
            p_old_Header_Price_Attr_rec.pricing_attribute88 OR
            p_old_Header_Price_Attr_rec.pricing_attribute88 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute89 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute89 <>
            p_old_Header_Price_Attr_rec.pricing_attribute89 OR
            p_old_Header_Price_Attr_rec.pricing_attribute89 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute90 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute90 <>
            p_old_Header_Price_Attr_rec.pricing_attribute90 OR
            p_old_Header_Price_Attr_rec.pricing_attribute90 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute91 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute91 <>
            p_old_Header_Price_Attr_rec.pricing_attribute91 OR
            p_old_Header_Price_Attr_rec.pricing_attribute91 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute92 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute92 <>
            p_old_Header_Price_Attr_rec.pricing_attribute92 OR
            p_old_Header_Price_Attr_rec.pricing_attribute92 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute93 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute93 <>
            p_old_Header_Price_Attr_rec.pricing_attribute93 OR
            p_old_Header_Price_Attr_rec.pricing_attribute93 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute94 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute94 <>
            p_old_Header_Price_Attr_rec.pricing_attribute94 OR
            p_old_Header_Price_Attr_rec.pricing_attribute94 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute95 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute95 <>
            p_old_Header_Price_Attr_rec.pricing_attribute95 OR
            p_old_Header_Price_Attr_rec.pricing_attribute95 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute96 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute96 <>
            p_old_Header_Price_Attr_rec.pricing_attribute96 OR
            p_old_Header_Price_Attr_rec.pricing_attribute96 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute97 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute97 <>
            p_old_Header_Price_Attr_rec.pricing_attribute97 OR
            p_old_Header_Price_Attr_rec.pricing_attribute97 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute98 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute98 <>
            p_old_Header_Price_Attr_rec.pricing_attribute98 OR
            p_old_Header_Price_Attr_rec.pricing_attribute98 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute99 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute99 <>
            p_old_Header_Price_Attr_rec.pricing_attribute99 OR
            p_old_Header_Price_Attr_rec.pricing_attribute99 IS NULL ))
    OR  (p_Header_Price_Attr_rec.pricing_attribute100 IS NOT NULL AND
        (   p_Header_Price_Attr_rec.pricing_attribute100 <>
            p_old_Header_Price_Attr_rec.pricing_attribute100 OR
            p_old_Header_Price_Attr_rec.pricing_attribute100 IS NULL ))
    THEN

    --  These calls are temporarily commented out

	if p_Header_Price_Attr_rec.flex_title='QP_ATTR_DEFNS_PRICING' then
		l_column_prefix := 'PRICING';
	else
		l_column_prefix := 'QUALIFIER';
	end if;


        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE1'
        ,   column_value         =>  p_Header_Price_Attr_rec.pricing_attribute1
        );

        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE2'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute2
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE3'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute3
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE4'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute4
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE5'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute5
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE6'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute6
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE7'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute7
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE8'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute8
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE9'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute9
        );

        -- fixed bug 1769612
        /***
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_CONTEXT'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_context
        );
        ***/

        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE10'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute10
        );

        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE11'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute11
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE12'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute12
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE13'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute13
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE14'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute14
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE15'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute15
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE16'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute16
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE17'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute17
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE18'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute18
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE19'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute19
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE20'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute20
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE21'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute21
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE22'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute22
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE23'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute23
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE24'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute24
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE25'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute25
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE26'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute26
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE27'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute27
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE28'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute28
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE29'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute29
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE30'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute30
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE31'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute31
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE32'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute32
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE33'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute33
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE34'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute34
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE35'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute35
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE36'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute36
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE37'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute37
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE38'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute38
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE39'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute39
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE40'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute40
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE41'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute41
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE42'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute42
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE43'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute43
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE44'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute44
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE45'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute45
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE46'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute46
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE47'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute47
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE48'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute48
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE49'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute49
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE50'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute50
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE51'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute51
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE52'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute52
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE53'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute53
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE54'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute54
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE55'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute55
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE56'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute56
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE57'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute57
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE58'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute58
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE59'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute59
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE60'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute60
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE61'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute61
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE62'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute62
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE63'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute63
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE64'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute64
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE65'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute65
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE66'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute66
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE67'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute67
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE68'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute68
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE69'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute69
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE70'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute70
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE71'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute71
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE72'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute72
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE73'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute73
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE74'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute74
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE75'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute75
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE76'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute76
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE77'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute77
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE78'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute78
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE79'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute79
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE80'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute80
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE81'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute81
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE82'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute82
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE83'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute83
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE84'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute84
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE85'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute85
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE86'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute86
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE87'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute87
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE88'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute88
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE89'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute89
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE90'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute90
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE91'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute91
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE92'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute92
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE93'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute93
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE94'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute94
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE95'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute95
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE96'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute96
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE97'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute97
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE98'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute98
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE99'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute99
        );
        FND_FLEX_DESCVAL.Set_Column_Value
        (   column_name          => l_column_prefix||'_ATTRIBUTE100'
        ,   column_value         => p_Header_Price_Attr_rec.pricing_attribute100
        );

       -- bug 1769612
        FND_FLEX_DESCVAL.Set_Context_Value
        (
          context_value         => p_Header_Price_Attr_rec.pricing_context
        );

        --  Validate descriptive flexfield.
      /* commented for bug#5679839
        IF NOT OE_Validate_adj.Desc_Flex( 'QP', p_Header_Price_Attr_rec.Flex_Title )
	   THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      */
    END IF;
   end if; -- bug4343612
    --  Done validating attributes

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_VALIDATE_HEADER_PATTR.ATTRIBUTES' , 1 ) ;
    END IF;
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
( x_return_status OUT NOCOPY VARCHAR2

,   p_Header_Price_Attr_rec        IN  OE_Order_PUB.Header_Price_Att_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
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

END OE_Validate_Header_PAttr;

/
