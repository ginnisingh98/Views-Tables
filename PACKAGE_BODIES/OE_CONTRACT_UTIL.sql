--------------------------------------------------------
--  DDL for Package Body OE_CONTRACT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONTRACT_UTIL" AS
/* $Header: OEXUPCTB.pls 115.0 99/07/15 19:27:47 porting shi $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Contract_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   x_Contract_rec                  OUT OE_Pricing_Cont_PUB.Contract_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_Contract_rec := p_Contract_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.agreement_id,p_old_Contract_rec.agreement_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute1,p_old_Contract_rec.attribute1)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute10,p_old_Contract_rec.attribute10)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute11,p_old_Contract_rec.attribute11)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute12,p_old_Contract_rec.attribute12)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute13,p_old_Contract_rec.attribute13)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute14,p_old_Contract_rec.attribute14)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute15,p_old_Contract_rec.attribute15)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute2,p_old_Contract_rec.attribute2)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute3,p_old_Contract_rec.attribute3)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute4,p_old_Contract_rec.attribute4)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute5,p_old_Contract_rec.attribute5)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute6,p_old_Contract_rec.attribute6)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute7,p_old_Contract_rec.attribute7)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute8,p_old_Contract_rec.attribute8)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute9,p_old_Contract_rec.attribute9)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.context,p_old_Contract_rec.context)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.created_by,p_old_Contract_rec.created_by)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.creation_date,p_old_Contract_rec.creation_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.discount_id,p_old_Contract_rec.discount_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.last_updated_by,p_old_Contract_rec.last_updated_by)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.last_update_date,p_old_Contract_rec.last_update_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.last_update_login,p_old_Contract_rec.last_update_login)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.price_list_id,p_old_Contract_rec.price_list_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Contract_rec.pricing_contract_id,p_old_Contract_rec.pricing_contract_id)
        THEN
            NULL;
        END IF;

    ELSIF p_attr_id = G_AGREEMENT THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        NULL;
    ELSIF p_attr_id = G_CONTEXT THEN
        NULL;
    ELSIF p_attr_id = G_CREATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        NULL;
    ELSIF p_attr_id = G_DISCOUNT THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        NULL;
    ELSIF p_attr_id = G_PRICE_LIST THEN
        NULL;
    ELSIF p_attr_id = G_PRICING_CONTRACT THEN
        NULL;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   x_Contract_rec                  OUT OE_Pricing_Cont_PUB.Contract_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_Contract_rec := p_Contract_rec;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.agreement_id,p_old_Contract_rec.agreement_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute1,p_old_Contract_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute10,p_old_Contract_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute11,p_old_Contract_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute12,p_old_Contract_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute13,p_old_Contract_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute14,p_old_Contract_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute15,p_old_Contract_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute2,p_old_Contract_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute3,p_old_Contract_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute4,p_old_Contract_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute5,p_old_Contract_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute6,p_old_Contract_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute7,p_old_Contract_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute8,p_old_Contract_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.attribute9,p_old_Contract_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.context,p_old_Contract_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.created_by,p_old_Contract_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.creation_date,p_old_Contract_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.discount_id,p_old_Contract_rec.discount_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.last_updated_by,p_old_Contract_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.last_update_date,p_old_Contract_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.last_update_login,p_old_Contract_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.price_list_id,p_old_Contract_rec.price_list_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Contract_rec.pricing_contract_id,p_old_Contract_rec.pricing_contract_id)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type := p_Contract_rec;
BEGIN

    IF l_Contract_rec.agreement_id = FND_API.G_MISS_NUM THEN
        l_Contract_rec.agreement_id := p_old_Contract_rec.agreement_id;
    END IF;

    IF l_Contract_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute1 := p_old_Contract_rec.attribute1;
    END IF;

    IF l_Contract_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute10 := p_old_Contract_rec.attribute10;
    END IF;

    IF l_Contract_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute11 := p_old_Contract_rec.attribute11;
    END IF;

    IF l_Contract_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute12 := p_old_Contract_rec.attribute12;
    END IF;

    IF l_Contract_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute13 := p_old_Contract_rec.attribute13;
    END IF;

    IF l_Contract_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute14 := p_old_Contract_rec.attribute14;
    END IF;

    IF l_Contract_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute15 := p_old_Contract_rec.attribute15;
    END IF;

    IF l_Contract_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute2 := p_old_Contract_rec.attribute2;
    END IF;

    IF l_Contract_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute3 := p_old_Contract_rec.attribute3;
    END IF;

    IF l_Contract_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute4 := p_old_Contract_rec.attribute4;
    END IF;

    IF l_Contract_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute5 := p_old_Contract_rec.attribute5;
    END IF;

    IF l_Contract_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute6 := p_old_Contract_rec.attribute6;
    END IF;

    IF l_Contract_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute7 := p_old_Contract_rec.attribute7;
    END IF;

    IF l_Contract_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute8 := p_old_Contract_rec.attribute8;
    END IF;

    IF l_Contract_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute9 := p_old_Contract_rec.attribute9;
    END IF;

    IF l_Contract_rec.context = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.context := p_old_Contract_rec.context;
    END IF;

    IF l_Contract_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Contract_rec.created_by := p_old_Contract_rec.created_by;
    END IF;

    IF l_Contract_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Contract_rec.creation_date := p_old_Contract_rec.creation_date;
    END IF;

    IF l_Contract_rec.discount_id = FND_API.G_MISS_NUM THEN
        l_Contract_rec.discount_id := p_old_Contract_rec.discount_id;
    END IF;

    IF l_Contract_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Contract_rec.last_updated_by := p_old_Contract_rec.last_updated_by;
    END IF;

    IF l_Contract_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Contract_rec.last_update_date := p_old_Contract_rec.last_update_date;
    END IF;

    IF l_Contract_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Contract_rec.last_update_login := p_old_Contract_rec.last_update_login;
    END IF;

    IF l_Contract_rec.price_list_id = FND_API.G_MISS_NUM THEN
        l_Contract_rec.price_list_id := p_old_Contract_rec.price_list_id;
    END IF;

    IF l_Contract_rec.pricing_contract_id = FND_API.G_MISS_NUM THEN
        l_Contract_rec.pricing_contract_id := p_old_Contract_rec.pricing_contract_id;
    END IF;

    RETURN l_Contract_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type := p_Contract_rec;
BEGIN

    IF l_Contract_rec.agreement_id = FND_API.G_MISS_NUM THEN
        l_Contract_rec.agreement_id := NULL;
    END IF;

    IF l_Contract_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute1 := NULL;
    END IF;

    IF l_Contract_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute10 := NULL;
    END IF;

    IF l_Contract_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute11 := NULL;
    END IF;

    IF l_Contract_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute12 := NULL;
    END IF;

    IF l_Contract_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute13 := NULL;
    END IF;

    IF l_Contract_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute14 := NULL;
    END IF;

    IF l_Contract_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute15 := NULL;
    END IF;

    IF l_Contract_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute2 := NULL;
    END IF;

    IF l_Contract_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute3 := NULL;
    END IF;

    IF l_Contract_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute4 := NULL;
    END IF;

    IF l_Contract_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute5 := NULL;
    END IF;

    IF l_Contract_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute6 := NULL;
    END IF;

    IF l_Contract_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute7 := NULL;
    END IF;

    IF l_Contract_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute8 := NULL;
    END IF;

    IF l_Contract_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.attribute9 := NULL;
    END IF;

    IF l_Contract_rec.context = FND_API.G_MISS_CHAR THEN
        l_Contract_rec.context := NULL;
    END IF;

    IF l_Contract_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Contract_rec.created_by := NULL;
    END IF;

    IF l_Contract_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Contract_rec.creation_date := NULL;
    END IF;

    IF l_Contract_rec.discount_id = FND_API.G_MISS_NUM THEN
        l_Contract_rec.discount_id := NULL;
    END IF;

    IF l_Contract_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Contract_rec.last_updated_by := NULL;
    END IF;

    IF l_Contract_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Contract_rec.last_update_date := NULL;
    END IF;

    IF l_Contract_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Contract_rec.last_update_login := NULL;
    END IF;

    IF l_Contract_rec.price_list_id = FND_API.G_MISS_NUM THEN
        l_Contract_rec.price_list_id := NULL;
    END IF;

    IF l_Contract_rec.pricing_contract_id = FND_API.G_MISS_NUM THEN
        l_Contract_rec.pricing_contract_id := NULL;
    END IF;

    RETURN l_Contract_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
)
IS
BEGIN

    UPDATE  OE_PRICING_CONTRACTS
    SET     AGREEMENT_ID                   = p_Contract_rec.agreement_id
    ,       ATTRIBUTE1                     = p_Contract_rec.attribute1
    ,       ATTRIBUTE10                    = p_Contract_rec.attribute10
    ,       ATTRIBUTE11                    = p_Contract_rec.attribute11
    ,       ATTRIBUTE12                    = p_Contract_rec.attribute12
    ,       ATTRIBUTE13                    = p_Contract_rec.attribute13
    ,       ATTRIBUTE14                    = p_Contract_rec.attribute14
    ,       ATTRIBUTE15                    = p_Contract_rec.attribute15
    ,       ATTRIBUTE2                     = p_Contract_rec.attribute2
    ,       ATTRIBUTE3                     = p_Contract_rec.attribute3
    ,       ATTRIBUTE4                     = p_Contract_rec.attribute4
    ,       ATTRIBUTE5                     = p_Contract_rec.attribute5
    ,       ATTRIBUTE6                     = p_Contract_rec.attribute6
    ,       ATTRIBUTE7                     = p_Contract_rec.attribute7
    ,       ATTRIBUTE8                     = p_Contract_rec.attribute8
    ,       ATTRIBUTE9                     = p_Contract_rec.attribute9
    ,       CONTEXT                        = p_Contract_rec.context
    ,       CREATED_BY                     = p_Contract_rec.created_by
    ,       CREATION_DATE                  = p_Contract_rec.creation_date
    ,       DISCOUNT_ID                    = p_Contract_rec.discount_id
    ,       LAST_UPDATED_BY                = p_Contract_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_Contract_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_Contract_rec.last_update_login
    ,       PRICE_LIST_ID                  = p_Contract_rec.price_list_id
    ,       PRICING_CONTRACT_ID            = p_Contract_rec.pricing_contract_id
    WHERE   PRICING_CONTRACT_ID = p_Contract_rec.pricing_contract_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
)
IS
BEGIN

    oe_debug_pub.add('Entering OE_Contract_Util.Insert_Row');

    INSERT  INTO OE_PRICING_CONTRACTS
    (       AGREEMENT_ID
    ,       ATTRIBUTE1
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
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRICE_LIST_ID
    ,       PRICING_CONTRACT_ID
    )
    VALUES
    (       p_Contract_rec.agreement_id
    ,       p_Contract_rec.attribute1
    ,       p_Contract_rec.attribute10
    ,       p_Contract_rec.attribute11
    ,       p_Contract_rec.attribute12
    ,       p_Contract_rec.attribute13
    ,       p_Contract_rec.attribute14
    ,       p_Contract_rec.attribute15
    ,       p_Contract_rec.attribute2
    ,       p_Contract_rec.attribute3
    ,       p_Contract_rec.attribute4
    ,       p_Contract_rec.attribute5
    ,       p_Contract_rec.attribute6
    ,       p_Contract_rec.attribute7
    ,       p_Contract_rec.attribute8
    ,       p_Contract_rec.attribute9
    ,       p_Contract_rec.context
    ,       p_Contract_rec.created_by
    ,       p_Contract_rec.creation_date
    ,       p_Contract_rec.discount_id
    ,       p_Contract_rec.last_updated_by
    ,       p_Contract_rec.last_update_date
    ,       p_Contract_rec.last_update_login
    ,       p_Contract_rec.price_list_id
    ,       p_Contract_rec.pricing_contract_id
    );

    oe_debug_pub.add('Exiting OE_Contract_Util.Insert_Row');

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_pricing_contract_id           IN  NUMBER
)
IS
BEGIN

    DELETE  FROM OE_PRICING_CONTRACTS
    WHERE   PRICING_CONTRACT_ID = p_pricing_contract_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_pricing_contract_id           IN  NUMBER
) RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
BEGIN

    SELECT  AGREEMENT_ID
    ,       ATTRIBUTE1
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
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRICE_LIST_ID
    ,       PRICING_CONTRACT_ID
    INTO    l_Contract_rec.agreement_id
    ,       l_Contract_rec.attribute1
    ,       l_Contract_rec.attribute10
    ,       l_Contract_rec.attribute11
    ,       l_Contract_rec.attribute12
    ,       l_Contract_rec.attribute13
    ,       l_Contract_rec.attribute14
    ,       l_Contract_rec.attribute15
    ,       l_Contract_rec.attribute2
    ,       l_Contract_rec.attribute3
    ,       l_Contract_rec.attribute4
    ,       l_Contract_rec.attribute5
    ,       l_Contract_rec.attribute6
    ,       l_Contract_rec.attribute7
    ,       l_Contract_rec.attribute8
    ,       l_Contract_rec.attribute9
    ,       l_Contract_rec.context
    ,       l_Contract_rec.created_by
    ,       l_Contract_rec.creation_date
    ,       l_Contract_rec.discount_id
    ,       l_Contract_rec.last_updated_by
    ,       l_Contract_rec.last_update_date
    ,       l_Contract_rec.last_update_login
    ,       l_Contract_rec.price_list_id
    ,       l_Contract_rec.pricing_contract_id
    FROM    OE_PRICING_CONTRACTS
    WHERE   PRICING_CONTRACT_ID = p_pricing_contract_id
    ;

    RETURN l_Contract_rec;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Contract_rec                  OUT OE_Pricing_Cont_PUB.Contract_Rec_Type
)
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
BEGIN

    SELECT  AGREEMENT_ID
    ,       ATTRIBUTE1
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
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PRICE_LIST_ID
    ,       PRICING_CONTRACT_ID
    INTO    l_Contract_rec.agreement_id
    ,       l_Contract_rec.attribute1
    ,       l_Contract_rec.attribute10
    ,       l_Contract_rec.attribute11
    ,       l_Contract_rec.attribute12
    ,       l_Contract_rec.attribute13
    ,       l_Contract_rec.attribute14
    ,       l_Contract_rec.attribute15
    ,       l_Contract_rec.attribute2
    ,       l_Contract_rec.attribute3
    ,       l_Contract_rec.attribute4
    ,       l_Contract_rec.attribute5
    ,       l_Contract_rec.attribute6
    ,       l_Contract_rec.attribute7
    ,       l_Contract_rec.attribute8
    ,       l_Contract_rec.attribute9
    ,       l_Contract_rec.context
    ,       l_Contract_rec.created_by
    ,       l_Contract_rec.creation_date
    ,       l_Contract_rec.discount_id
    ,       l_Contract_rec.last_updated_by
    ,       l_Contract_rec.last_update_date
    ,       l_Contract_rec.last_update_login
    ,       l_Contract_rec.price_list_id
    ,       l_Contract_rec.pricing_contract_id
    FROM    OE_PRICING_CONTRACTS
    WHERE   PRICING_CONTRACT_ID = p_Contract_rec.pricing_contract_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_Contract_rec.agreement_id =
             p_Contract_rec.agreement_id) OR
            ((p_Contract_rec.agreement_id = FND_API.G_MISS_NUM) OR
            (   (l_Contract_rec.agreement_id IS NULL) AND
                (p_Contract_rec.agreement_id IS NULL))))
    AND (   (l_Contract_rec.attribute1 =
             p_Contract_rec.attribute1) OR
            ((p_Contract_rec.attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute1 IS NULL) AND
                (p_Contract_rec.attribute1 IS NULL))))
    AND (   (l_Contract_rec.attribute10 =
             p_Contract_rec.attribute10) OR
            ((p_Contract_rec.attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute10 IS NULL) AND
                (p_Contract_rec.attribute10 IS NULL))))
    AND (   (l_Contract_rec.attribute11 =
             p_Contract_rec.attribute11) OR
            ((p_Contract_rec.attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute11 IS NULL) AND
                (p_Contract_rec.attribute11 IS NULL))))
    AND (   (l_Contract_rec.attribute12 =
             p_Contract_rec.attribute12) OR
            ((p_Contract_rec.attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute12 IS NULL) AND
                (p_Contract_rec.attribute12 IS NULL))))
    AND (   (l_Contract_rec.attribute13 =
             p_Contract_rec.attribute13) OR
            ((p_Contract_rec.attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute13 IS NULL) AND
                (p_Contract_rec.attribute13 IS NULL))))
    AND (   (l_Contract_rec.attribute14 =
             p_Contract_rec.attribute14) OR
            ((p_Contract_rec.attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute14 IS NULL) AND
                (p_Contract_rec.attribute14 IS NULL))))
    AND (   (l_Contract_rec.attribute15 =
             p_Contract_rec.attribute15) OR
            ((p_Contract_rec.attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute15 IS NULL) AND
                (p_Contract_rec.attribute15 IS NULL))))
    AND (   (l_Contract_rec.attribute2 =
             p_Contract_rec.attribute2) OR
            ((p_Contract_rec.attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute2 IS NULL) AND
                (p_Contract_rec.attribute2 IS NULL))))
    AND (   (l_Contract_rec.attribute3 =
             p_Contract_rec.attribute3) OR
            ((p_Contract_rec.attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute3 IS NULL) AND
                (p_Contract_rec.attribute3 IS NULL))))
    AND (   (l_Contract_rec.attribute4 =
             p_Contract_rec.attribute4) OR
            ((p_Contract_rec.attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute4 IS NULL) AND
                (p_Contract_rec.attribute4 IS NULL))))
    AND (   (l_Contract_rec.attribute5 =
             p_Contract_rec.attribute5) OR
            ((p_Contract_rec.attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute5 IS NULL) AND
                (p_Contract_rec.attribute5 IS NULL))))
    AND (   (l_Contract_rec.attribute6 =
             p_Contract_rec.attribute6) OR
            ((p_Contract_rec.attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute6 IS NULL) AND
                (p_Contract_rec.attribute6 IS NULL))))
    AND (   (l_Contract_rec.attribute7 =
             p_Contract_rec.attribute7) OR
            ((p_Contract_rec.attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute7 IS NULL) AND
                (p_Contract_rec.attribute7 IS NULL))))
    AND (   (l_Contract_rec.attribute8 =
             p_Contract_rec.attribute8) OR
            ((p_Contract_rec.attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute8 IS NULL) AND
                (p_Contract_rec.attribute8 IS NULL))))
    AND (   (l_Contract_rec.attribute9 =
             p_Contract_rec.attribute9) OR
            ((p_Contract_rec.attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.attribute9 IS NULL) AND
                (p_Contract_rec.attribute9 IS NULL))))
    AND (   (l_Contract_rec.context =
             p_Contract_rec.context) OR
            ((p_Contract_rec.context = FND_API.G_MISS_CHAR) OR
            (   (l_Contract_rec.context IS NULL) AND
                (p_Contract_rec.context IS NULL))))
    AND (   (l_Contract_rec.created_by =
             p_Contract_rec.created_by) OR
            ((p_Contract_rec.created_by = FND_API.G_MISS_NUM) OR
            (   (l_Contract_rec.created_by IS NULL) AND
                (p_Contract_rec.created_by IS NULL))))
    AND (   (l_Contract_rec.creation_date =
             p_Contract_rec.creation_date) OR
            ((p_Contract_rec.creation_date = FND_API.G_MISS_DATE) OR
            (   (l_Contract_rec.creation_date IS NULL) AND
                (p_Contract_rec.creation_date IS NULL))))
    AND (   (l_Contract_rec.discount_id =
             p_Contract_rec.discount_id) OR
            ((p_Contract_rec.discount_id = FND_API.G_MISS_NUM) OR
            (   (l_Contract_rec.discount_id IS NULL) AND
                (p_Contract_rec.discount_id IS NULL))))
    AND (   (l_Contract_rec.last_updated_by =
             p_Contract_rec.last_updated_by) OR
            ((p_Contract_rec.last_updated_by = FND_API.G_MISS_NUM) OR
            (   (l_Contract_rec.last_updated_by IS NULL) AND
                (p_Contract_rec.last_updated_by IS NULL))))
    AND (   (l_Contract_rec.last_update_date =
             p_Contract_rec.last_update_date) OR
            ((p_Contract_rec.last_update_date = FND_API.G_MISS_DATE) OR
            (   (l_Contract_rec.last_update_date IS NULL) AND
                (p_Contract_rec.last_update_date IS NULL))))
    AND (   (l_Contract_rec.last_update_login =
             p_Contract_rec.last_update_login) OR
            ((p_Contract_rec.last_update_login = FND_API.G_MISS_NUM) OR
            (   (l_Contract_rec.last_update_login IS NULL) AND
                (p_Contract_rec.last_update_login IS NULL))))
    AND (   (l_Contract_rec.price_list_id =
             p_Contract_rec.price_list_id) OR
            ((p_Contract_rec.price_list_id = FND_API.G_MISS_NUM) OR
            (   (l_Contract_rec.price_list_id IS NULL) AND
                (p_Contract_rec.price_list_id IS NULL))))
    AND (   (l_Contract_rec.pricing_contract_id =
             p_Contract_rec.pricing_contract_id) OR
            ((p_Contract_rec.pricing_contract_id = FND_API.G_MISS_NUM) OR
            (   (l_Contract_rec.pricing_contract_id IS NULL) AND
                (p_Contract_rec.pricing_contract_id IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_Contract_rec                 := l_Contract_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Contract_rec.return_status   := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Contract_rec.return_status   := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Contract_rec.return_status   := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Contract_rec.return_status   := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Contract_rec.return_status   := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
) RETURN OE_Pricing_Cont_PUB.Contract_Val_Rec_Type
IS
l_Contract_val_rec            OE_Pricing_Cont_PUB.Contract_Val_Rec_Type;
BEGIN

    IF p_Contract_rec.agreement_id IS NOT NULL AND
        p_Contract_rec.agreement_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Contract_rec.agreement_id,
        p_old_Contract_rec.agreement_id)
    THEN
        l_Contract_val_rec.agreement := OE_Id_To_Value.Agreement
        (   p_agreement_id                => p_Contract_rec.agreement_id
        );
    END IF;

    IF p_Contract_rec.discount_id IS NOT NULL AND
        p_Contract_rec.discount_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Contract_rec.discount_id,
        p_old_Contract_rec.discount_id)
    THEN
        l_Contract_val_rec.discount := OE_Id_To_Value.Discount
        (   p_discount_id                 => p_Contract_rec.discount_id
        );
    END IF;

    IF p_Contract_rec.price_list_id IS NOT NULL AND
        p_Contract_rec.price_list_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Contract_rec.price_list_id,
        p_old_Contract_rec.price_list_id)
    THEN
        l_Contract_val_rec.price_list := OE_Id_To_Value.Price_List
        (   p_price_list_id               => p_Contract_rec.price_list_id
        );
    END IF;

    RETURN l_Contract_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_Contract_val_rec              IN  OE_Pricing_Cont_PUB.Contract_Val_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_Contract_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Contract_rec.

    l_Contract_rec := p_Contract_rec;

    IF  p_Contract_val_rec.agreement <> FND_API.G_MISS_CHAR
    THEN

        IF p_Contract_rec.agreement_id <> FND_API.G_MISS_NUM THEN

            l_Contract_rec.agreement_id := p_Contract_rec.agreement_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Contract_rec.agreement_id := OE_Value_To_Id.agreement
            (   p_agreement                   => p_Contract_val_rec.agreement
            );

            IF l_Contract_rec.agreement_id = FND_API.G_MISS_NUM THEN
                l_Contract_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Contract_val_rec.discount <> FND_API.G_MISS_CHAR
    THEN

        IF p_Contract_rec.discount_id <> FND_API.G_MISS_NUM THEN

            l_Contract_rec.discount_id := p_Contract_rec.discount_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Contract_rec.discount_id := OE_Value_To_Id.discount
            (   p_discount                    => p_Contract_val_rec.discount
            );

            IF l_Contract_rec.discount_id = FND_API.G_MISS_NUM THEN
                l_Contract_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Contract_val_rec.price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_Contract_rec.price_list_id <> FND_API.G_MISS_NUM THEN

            l_Contract_rec.price_list_id := p_Contract_rec.price_list_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Contract_rec.price_list_id := OE_Value_To_Id.price_list
            (   p_price_list                  => p_Contract_val_rec.price_list
            );

            IF l_Contract_rec.price_list_id = FND_API.G_MISS_NUM THEN
                l_Contract_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_Contract_rec;

END Get_Ids;

END OE_Contract_Util;

/
