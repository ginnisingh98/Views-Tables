--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_LIMIT_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_LIMIT_BALANCES" AS
/* $Header: QPXFLMBB.pls 120.1 2005/06/13 03:35:48 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Limit_Balances';

--  Global variables holding cached record.

g_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
g_db_LIMIT_BALANCES_rec       QP_Limits_PUB.Limit_Balances_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_LIMIT_BALANCES
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_LIMIT_BALANCES
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_limit_balance_id              IN  NUMBER
)
RETURN QP_Limits_PUB.Limit_Balances_Rec_Type;

PROCEDURE Clear_LIMIT_BALANCES;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Limits_PUB.Limit_Balances_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_available_amount              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_consumed_amount               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_limit_balance_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_limit_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_multival_attr1_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attribute1           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_datatype       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attribute2           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_datatype       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attr_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attribute        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attr_value       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reserved_amount               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_limit_balance                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_limit                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
l_LIMIT_BALANCES_val_rec      QP_Limits_PUB.Limit_Balances_Val_Rec_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_LIMITS_rec                QP_Limits_PUB.Limits_Rec_Type;
l_x_LIMIT_ATTRS_rec           QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_x_LIMIT_ATTRS_tbl           QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_x_LIMIT_BALANCES_rec        QP_Limits_PUB.Limit_Balances_Rec_Type;
l_x_LIMIT_BALANCES_tbl        QP_Limits_PUB.Limit_Balances_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.default_attributes   := TRUE;

    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_LIMIT_BALANCES_rec.attribute1               := NULL;
    l_LIMIT_BALANCES_rec.attribute10              := NULL;
    l_LIMIT_BALANCES_rec.attribute11              := NULL;
    l_LIMIT_BALANCES_rec.attribute12              := NULL;
    l_LIMIT_BALANCES_rec.attribute13              := NULL;
    l_LIMIT_BALANCES_rec.attribute14              := NULL;
    l_LIMIT_BALANCES_rec.attribute15              := NULL;
    l_LIMIT_BALANCES_rec.attribute2               := NULL;
    l_LIMIT_BALANCES_rec.attribute3               := NULL;
    l_LIMIT_BALANCES_rec.attribute4               := NULL;
    l_LIMIT_BALANCES_rec.attribute5               := NULL;
    l_LIMIT_BALANCES_rec.attribute6               := NULL;
    l_LIMIT_BALANCES_rec.attribute7               := NULL;
    l_LIMIT_BALANCES_rec.attribute8               := NULL;
    l_LIMIT_BALANCES_rec.attribute9               := NULL;
    l_LIMIT_BALANCES_rec.context                  := NULL;

    --  Set Operation to Create

    l_LIMIT_BALANCES_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Populate LIMIT_BALANCES table

    l_LIMIT_BALANCES_tbl(1) := l_LIMIT_BALANCES_rec;

    --  Call QP_Limits_PVT.Process_Limits

    QP_Limits_PVT.Process_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    ,   x_LIMITS_rec                  => l_x_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_x_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_x_LIMIT_BALANCES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_LIMIT_BALANCES_rec := l_x_LIMIT_BALANCES_tbl(1);

    --  Load OUT parameters.

    x_attribute1                   := l_x_LIMIT_BALANCES_rec.attribute1;
    x_attribute10                  := l_x_LIMIT_BALANCES_rec.attribute10;
    x_attribute11                  := l_x_LIMIT_BALANCES_rec.attribute11;
    x_attribute12                  := l_x_LIMIT_BALANCES_rec.attribute12;
    x_attribute13                  := l_x_LIMIT_BALANCES_rec.attribute13;
    x_attribute14                  := l_x_LIMIT_BALANCES_rec.attribute14;
    x_attribute15                  := l_x_LIMIT_BALANCES_rec.attribute15;
    x_attribute2                   := l_x_LIMIT_BALANCES_rec.attribute2;
    x_attribute3                   := l_x_LIMIT_BALANCES_rec.attribute3;
    x_attribute4                   := l_x_LIMIT_BALANCES_rec.attribute4;
    x_attribute5                   := l_x_LIMIT_BALANCES_rec.attribute5;
    x_attribute6                   := l_x_LIMIT_BALANCES_rec.attribute6;
    x_attribute7                   := l_x_LIMIT_BALANCES_rec.attribute7;
    x_attribute8                   := l_x_LIMIT_BALANCES_rec.attribute8;
    x_attribute9                   := l_x_LIMIT_BALANCES_rec.attribute9;
    x_available_amount             := l_x_LIMIT_BALANCES_rec.available_amount;
    x_consumed_amount              := l_x_LIMIT_BALANCES_rec.consumed_amount;
    x_context                      := l_x_LIMIT_BALANCES_rec.context;
    x_limit_balance_id             := l_x_LIMIT_BALANCES_rec.limit_balance_id;
    x_limit_id                     := l_x_LIMIT_BALANCES_rec.limit_id;
    x_multival_attr1_type          := l_x_LIMIT_BALANCES_rec.multival_attr1_type;
    x_multival_attr1_context       := l_x_LIMIT_BALANCES_rec.multival_attr1_context;
    x_multival_attribute1          := l_x_LIMIT_BALANCES_rec.multival_attribute1;
    x_multival_attr1_value         := l_x_LIMIT_BALANCES_rec.multival_attr1_value;
    x_multival_attr1_datatype      := l_x_LIMIT_BALANCES_rec.multival_attr1_datatype;
    x_multival_attr2_type          := l_x_LIMIT_BALANCES_rec.multival_attr2_type;
    x_multival_attr2_context       := l_x_LIMIT_BALANCES_rec.multival_attr2_context;
    x_multival_attribute2          := l_x_LIMIT_BALANCES_rec.multival_attribute2;
    x_multival_attr2_value         := l_x_LIMIT_BALANCES_rec.multival_attr2_value;
    x_multival_attr2_datatype      := l_x_LIMIT_BALANCES_rec.multival_attr2_datatype;
    x_organization_attr_context    := l_x_LIMIT_BALANCES_rec.organization_attr_context;
    x_organization_attribute       := l_x_LIMIT_BALANCES_rec.organization_attribute;
    x_organization_attr_value      := l_x_LIMIT_BALANCES_rec.organization_attr_value;
    x_reserved_amount              := l_x_LIMIT_BALANCES_rec.reserved_amount;

    --  Load display out parameters if any

    l_LIMIT_BALANCES_val_rec := QP_Limit_Balances_Util.Get_Values
    (   p_LIMIT_BALANCES_rec          => l_x_LIMIT_BALANCES_rec
    );
    x_limit_balance                := l_LIMIT_BALANCES_val_rec.limit_balance;
    x_limit                        := l_LIMIT_BALANCES_val_rec.limit;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_LIMIT_BALANCES_rec.db_flag := FND_API.G_FALSE;

    Write_LIMIT_BALANCES
    (   p_LIMIT_BALANCES_rec          => l_x_LIMIT_BALANCES_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_balance_id              IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_available_amount              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_consumed_amount               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_limit_balance_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_limit_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_multival_attr1_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attribute1           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr1_datatype       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attribute2           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_multival_attr2_datatype       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attr_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attribute        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization_attr_value       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reserved_amount               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_limit_balance                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_limit                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
l_old_LIMIT_BALANCES_rec      QP_Limits_PUB.Limit_Balances_Rec_Type;
l_LIMIT_BALANCES_val_rec      QP_Limits_PUB.Limit_Balances_Val_Rec_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_old_LIMIT_BALANCES_tbl      QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_LIMITS_rec                QP_Limits_PUB.Limits_Rec_Type;
l_x_LIMIT_ATTRS_rec           QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_x_LIMIT_ATTRS_tbl           QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_x_LIMIT_BALANCES_rec        QP_Limits_PUB.Limit_Balances_Rec_Type;
l_x_LIMIT_BALANCES_tbl        QP_Limits_PUB.Limit_Balances_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read LIMIT_BALANCES from cache

    l_LIMIT_BALANCES_rec := Get_LIMIT_BALANCES
    (   p_db_record                   => FALSE
    ,   p_limit_balance_id            => p_limit_balance_id
    );

    l_old_LIMIT_BALANCES_rec       := l_LIMIT_BALANCES_rec;

    IF p_attr_id = QP_Limit_Balances_Util.G_AVAILABLE_AMOUNT THEN
        l_LIMIT_BALANCES_rec.available_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_CONSUMED_AMOUNT THEN
        l_LIMIT_BALANCES_rec.consumed_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_LIMIT_BALANCE THEN
        l_LIMIT_BALANCES_rec.limit_balance_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_LIMIT THEN
        l_LIMIT_BALANCES_rec.limit_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTR1_TYPE THEN
        l_LIMIT_BALANCES_rec.multival_attr1_type := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTR1_CONTEXT THEN
        l_LIMIT_BALANCES_rec.multival_attr1_context := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTRIBUTE1 THEN
        l_LIMIT_BALANCES_rec.multival_attribute1 := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTR1_VALUE THEN
        l_LIMIT_BALANCES_rec.multival_attr1_value := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTR1_DATATYPE THEN
        l_LIMIT_BALANCES_rec.multival_attr1_datatype := p_attr_value;
     ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTR2_TYPE THEN
        l_LIMIT_BALANCES_rec.multival_attr2_type := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTR2_CONTEXT THEN
        l_LIMIT_BALANCES_rec.multival_attr2_context := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTRIBUTE2 THEN
        l_LIMIT_BALANCES_rec.multival_attribute2 := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTR2_VALUE THEN
        l_LIMIT_BALANCES_rec.multival_attr2_value := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_MULTIVAL_ATTR2_DATATYPE THEN
        l_LIMIT_BALANCES_rec.multival_attr2_datatype := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_ORGANIZATION_ATTR_CONTEXT THEN
        l_LIMIT_BALANCES_rec.organization_attr_context := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_ORGANIZATION_ATTRIBUTE THEN
        l_LIMIT_BALANCES_rec.organization_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_ORGANIZATION_ATTR_VALUE THEN
        l_LIMIT_BALANCES_rec.organization_attr_value := p_attr_value;
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_RESERVED_AMOUNT THEN
        l_LIMIT_BALANCES_rec.reserved_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Limit_Balances_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Limit_Balances_Util.G_CONTEXT
    THEN

        l_LIMIT_BALANCES_rec.attribute1 := p_attribute1;
        l_LIMIT_BALANCES_rec.attribute10 := p_attribute10;
        l_LIMIT_BALANCES_rec.attribute11 := p_attribute11;
        l_LIMIT_BALANCES_rec.attribute12 := p_attribute12;
        l_LIMIT_BALANCES_rec.attribute13 := p_attribute13;
        l_LIMIT_BALANCES_rec.attribute14 := p_attribute14;
        l_LIMIT_BALANCES_rec.attribute15 := p_attribute15;
        l_LIMIT_BALANCES_rec.attribute2 := p_attribute2;
        l_LIMIT_BALANCES_rec.attribute3 := p_attribute3;
        l_LIMIT_BALANCES_rec.attribute4 := p_attribute4;
        l_LIMIT_BALANCES_rec.attribute5 := p_attribute5;
        l_LIMIT_BALANCES_rec.attribute6 := p_attribute6;
        l_LIMIT_BALANCES_rec.attribute7 := p_attribute7;
        l_LIMIT_BALANCES_rec.attribute8 := p_attribute8;
        l_LIMIT_BALANCES_rec.attribute9 := p_attribute9;
        l_LIMIT_BALANCES_rec.context   := p_context;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --  Set Operation.

    IF FND_API.To_Boolean(l_LIMIT_BALANCES_rec.db_flag) THEN
        l_LIMIT_BALANCES_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_LIMIT_BALANCES_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate LIMIT_BALANCES table

    l_LIMIT_BALANCES_tbl(1) := l_LIMIT_BALANCES_rec;
    l_old_LIMIT_BALANCES_tbl(1) := l_old_LIMIT_BALANCES_rec;

    --  Call QP_Limits_PVT.Process_Limits

    QP_Limits_PVT.Process_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    ,   p_old_LIMIT_BALANCES_tbl      => l_old_LIMIT_BALANCES_tbl
    ,   x_LIMITS_rec                  => l_x_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_x_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_x_LIMIT_BALANCES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_LIMIT_BALANCES_rec := l_x_LIMIT_BALANCES_tbl(1);

    --  Init OUT parameters to missing.

    x_attribute1                   := FND_API.G_MISS_CHAR;
    x_attribute10                  := FND_API.G_MISS_CHAR;
    x_attribute11                  := FND_API.G_MISS_CHAR;
    x_attribute12                  := FND_API.G_MISS_CHAR;
    x_attribute13                  := FND_API.G_MISS_CHAR;
    x_attribute14                  := FND_API.G_MISS_CHAR;
    x_attribute15                  := FND_API.G_MISS_CHAR;
    x_attribute2                   := FND_API.G_MISS_CHAR;
    x_attribute3                   := FND_API.G_MISS_CHAR;
    x_attribute4                   := FND_API.G_MISS_CHAR;
    x_attribute5                   := FND_API.G_MISS_CHAR;
    x_attribute6                   := FND_API.G_MISS_CHAR;
    x_attribute7                   := FND_API.G_MISS_CHAR;
    x_attribute8                   := FND_API.G_MISS_CHAR;
    x_attribute9                   := FND_API.G_MISS_CHAR;
    x_available_amount             := FND_API.G_MISS_NUM;
    x_consumed_amount              := FND_API.G_MISS_NUM;
    x_context                      := FND_API.G_MISS_CHAR;
    x_limit_balance_id             := FND_API.G_MISS_NUM;
    x_limit_id                     := FND_API.G_MISS_NUM;
    x_multival_attr1_type          := FND_API.G_MISS_CHAR;
    x_multival_attr1_context       := FND_API.G_MISS_CHAR;
    x_multival_attribute1          := FND_API.G_MISS_CHAR;
    x_multival_attr1_value         := FND_API.G_MISS_CHAR;
    x_multival_attr1_datatype      := FND_API.G_MISS_CHAR;
    x_multival_attr2_type          := FND_API.G_MISS_CHAR;
    x_multival_attr2_context       := FND_API.G_MISS_CHAR;
    x_multival_attribute2          := FND_API.G_MISS_CHAR;
    x_multival_attr2_value         := FND_API.G_MISS_CHAR;
    x_multival_attr2_datatype      := FND_API.G_MISS_CHAR;
    x_organization_attr_context    := FND_API.G_MISS_CHAR;
    x_organization_attribute       := FND_API.G_MISS_CHAR;
    x_organization_attr_value      := FND_API.G_MISS_CHAR;
    x_reserved_amount              := FND_API.G_MISS_NUM;
    x_limit_balance                := FND_API.G_MISS_CHAR;
    x_limit                        := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_LIMIT_BALANCES_val_rec := QP_Limit_Balances_Util.Get_Values
    (   p_LIMIT_BALANCES_rec          => l_x_LIMIT_BALANCES_rec
    ,   p_old_LIMIT_BALANCES_rec      => l_LIMIT_BALANCES_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute1,
                            l_LIMIT_BALANCES_rec.attribute1)
    THEN
        x_attribute1 := l_x_LIMIT_BALANCES_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute10,
                            l_LIMIT_BALANCES_rec.attribute10)
    THEN
        x_attribute10 := l_x_LIMIT_BALANCES_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute11,
                            l_LIMIT_BALANCES_rec.attribute11)
    THEN
        x_attribute11 := l_x_LIMIT_BALANCES_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute12,
                            l_LIMIT_BALANCES_rec.attribute12)
    THEN
        x_attribute12 := l_x_LIMIT_BALANCES_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute13,
                            l_LIMIT_BALANCES_rec.attribute13)
    THEN
        x_attribute13 := l_x_LIMIT_BALANCES_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute14,
                            l_LIMIT_BALANCES_rec.attribute14)
    THEN
        x_attribute14 := l_x_LIMIT_BALANCES_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute15,
                            l_LIMIT_BALANCES_rec.attribute15)
    THEN
        x_attribute15 := l_x_LIMIT_BALANCES_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute2,
                            l_LIMIT_BALANCES_rec.attribute2)
    THEN
        x_attribute2 := l_x_LIMIT_BALANCES_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute3,
                            l_LIMIT_BALANCES_rec.attribute3)
    THEN
        x_attribute3 := l_x_LIMIT_BALANCES_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute4,
                            l_LIMIT_BALANCES_rec.attribute4)
    THEN
        x_attribute4 := l_x_LIMIT_BALANCES_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute5,
                            l_LIMIT_BALANCES_rec.attribute5)
    THEN
        x_attribute5 := l_x_LIMIT_BALANCES_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute6,
                            l_LIMIT_BALANCES_rec.attribute6)
    THEN
        x_attribute6 := l_x_LIMIT_BALANCES_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute7,
                            l_LIMIT_BALANCES_rec.attribute7)
    THEN
        x_attribute7 := l_x_LIMIT_BALANCES_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute8,
                            l_LIMIT_BALANCES_rec.attribute8)
    THEN
        x_attribute8 := l_x_LIMIT_BALANCES_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.attribute9,
                            l_LIMIT_BALANCES_rec.attribute9)
    THEN
        x_attribute9 := l_x_LIMIT_BALANCES_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.available_amount,
                            l_LIMIT_BALANCES_rec.available_amount)
    THEN
        x_available_amount := l_x_LIMIT_BALANCES_rec.available_amount;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.consumed_amount,
                            l_LIMIT_BALANCES_rec.consumed_amount)
    THEN
        x_consumed_amount := l_x_LIMIT_BALANCES_rec.consumed_amount;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.context,
                            l_LIMIT_BALANCES_rec.context)
    THEN
        x_context := l_x_LIMIT_BALANCES_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.limit_balance_id,
                            l_LIMIT_BALANCES_rec.limit_balance_id)
    THEN
        x_limit_balance_id := l_x_LIMIT_BALANCES_rec.limit_balance_id;
        x_limit_balance := l_LIMIT_BALANCES_val_rec.limit_balance;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.limit_id,
                            l_LIMIT_BALANCES_rec.limit_id)
    THEN
        x_limit_id := l_x_LIMIT_BALANCES_rec.limit_id;
        x_limit := l_LIMIT_BALANCES_val_rec.limit;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attr1_type,
                            l_LIMIT_BALANCES_rec.multival_attr1_type)
    THEN
        x_multival_attr1_type := l_x_LIMIT_BALANCES_rec.multival_attr1_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attr1_context,
                            l_LIMIT_BALANCES_rec.multival_attr1_context)
    THEN
        x_multival_attr1_context := l_x_LIMIT_BALANCES_rec.multival_attr1_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attribute1,
                            l_LIMIT_BALANCES_rec.multival_attribute1)
    THEN
        x_multival_attribute1 := l_x_LIMIT_BALANCES_rec.multival_attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attr1_value,
                            l_LIMIT_BALANCES_rec.multival_attr1_value)
    THEN
        x_multival_attr1_value := l_x_LIMIT_BALANCES_rec.multival_attr1_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attr1_datatype,
                            l_LIMIT_BALANCES_rec.multival_attr1_datatype)
    THEN
        x_multival_attr1_datatype := l_x_LIMIT_BALANCES_rec.multival_attr1_datatype;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attr2_type,
                            l_LIMIT_BALANCES_rec.multival_attr2_type)
    THEN
        x_multival_attr2_type := l_x_LIMIT_BALANCES_rec.multival_attr2_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attr2_context,
                            l_LIMIT_BALANCES_rec.multival_attr2_context)
    THEN
        x_multival_attr2_context := l_x_LIMIT_BALANCES_rec.multival_attr2_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attribute2,
                            l_LIMIT_BALANCES_rec.multival_attribute2)
    THEN
        x_multival_attribute2 := l_x_LIMIT_BALANCES_rec.multival_attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attr2_value,
                            l_LIMIT_BALANCES_rec.multival_attr2_value)
    THEN
        x_multival_attr2_value := l_x_LIMIT_BALANCES_rec.multival_attr2_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.multival_attr2_datatype,
                            l_LIMIT_BALANCES_rec.multival_attr2_datatype)
    THEN
        x_multival_attr2_datatype := l_x_LIMIT_BALANCES_rec.multival_attr2_datatype;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.organization_attr_context,
                            l_LIMIT_BALANCES_rec.organization_attr_context)
    THEN
        x_organization_attr_context := l_x_LIMIT_BALANCES_rec.organization_attr_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.organization_attribute,
                            l_LIMIT_BALANCES_rec.organization_attribute)
    THEN
        x_organization_attribute := l_x_LIMIT_BALANCES_rec.organization_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.organization_attr_value,
                            l_LIMIT_BALANCES_rec.organization_attr_value)
    THEN
        x_organization_attr_value := l_x_LIMIT_BALANCES_rec.organization_attr_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_LIMIT_BALANCES_rec.reserved_amount,
                            l_LIMIT_BALANCES_rec.reserved_amount)
    THEN
        x_reserved_amount := l_x_LIMIT_BALANCES_rec.reserved_amount;
    END IF;


    --  Write to cache.

    Write_LIMIT_BALANCES
    (   p_LIMIT_BALANCES_rec          => l_x_LIMIT_BALANCES_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_balance_id              IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
l_old_LIMIT_BALANCES_rec      QP_Limits_PUB.Limit_Balances_Rec_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_old_LIMIT_BALANCES_tbl      QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_LIMITS_rec                QP_Limits_PUB.Limits_Rec_Type;
l_x_LIMIT_ATTRS_rec           QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_x_LIMIT_ATTRS_tbl           QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_x_LIMIT_BALANCES_rec        QP_Limits_PUB.Limit_Balances_Rec_Type;
l_x_LIMIT_BALANCES_tbl        QP_Limits_PUB.Limit_Balances_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read LIMIT_BALANCES from cache

    l_old_LIMIT_BALANCES_rec := Get_LIMIT_BALANCES
    (   p_db_record                   => TRUE
    ,   p_limit_balance_id            => p_limit_balance_id
    );

    l_LIMIT_BALANCES_rec := Get_LIMIT_BALANCES
    (   p_db_record                   => FALSE
    ,   p_limit_balance_id            => p_limit_balance_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_LIMIT_BALANCES_rec.db_flag) THEN
        l_LIMIT_BALANCES_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_LIMIT_BALANCES_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate LIMIT_BALANCES table

    l_LIMIT_BALANCES_tbl(1) := l_LIMIT_BALANCES_rec;
    l_old_LIMIT_BALANCES_tbl(1) := l_old_LIMIT_BALANCES_rec;

    --  Call QP_Limits_PVT.Process_Limits

    QP_Limits_PVT.Process_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    ,   p_old_LIMIT_BALANCES_tbl      => l_old_LIMIT_BALANCES_tbl
    ,   x_LIMITS_rec                  => l_x_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_x_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_x_LIMIT_BALANCES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_LIMIT_BALANCES_rec := l_x_LIMIT_BALANCES_tbl(1);

    x_creation_date                := l_x_LIMIT_BALANCES_rec.creation_date;
    x_created_by                   := l_x_LIMIT_BALANCES_rec.created_by;
    x_last_update_date             := l_x_LIMIT_BALANCES_rec.last_update_date;
    x_last_updated_by              := l_x_LIMIT_BALANCES_rec.last_updated_by;
    x_last_update_login            := l_x_LIMIT_BALANCES_rec.last_update_login;

    --  Clear LIMIT_BALANCES record cache

    Clear_LIMIT_BALANCES;

    --  Keep track of performed operations.

    l_old_LIMIT_BALANCES_rec.operation := l_LIMIT_BALANCES_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Validate_And_Write;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_balance_id              IN  NUMBER
)
IS
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_LIMITS_rec                QP_Limits_PUB.Limits_Rec_Type;
l_x_LIMIT_ATTRS_rec           QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_x_LIMIT_ATTRS_tbl           QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_x_LIMIT_BALANCES_rec        QP_Limits_PUB.Limit_Balances_Rec_Type;
l_x_LIMIT_BALANCES_tbl        QP_Limits_PUB.Limit_Balances_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    l_LIMIT_BALANCES_rec := Get_LIMIT_BALANCES
    (   p_db_record                   => TRUE
    ,   p_limit_balance_id            => p_limit_balance_id
    );

    --  Set Operation.

    l_LIMIT_BALANCES_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Populate LIMIT_BALANCES table

    l_LIMIT_BALANCES_tbl(1) := l_LIMIT_BALANCES_rec;

    --  Call QP_Limits_PVT.Process_Limits

    QP_Limits_PVT.Process_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    ,   x_LIMITS_rec                  => l_x_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_x_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_x_LIMIT_BALANCES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear LIMIT_BALANCES record cache

    Clear_LIMIT_BALANCES;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_LIMITS_rec                QP_Limits_PUB.Limits_Rec_Type;
l_x_LIMIT_ATTRS_rec           QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_x_LIMIT_ATTRS_tbl           QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_x_LIMIT_BALANCES_rec        QP_Limits_PUB.Limit_Balances_Rec_Type;
l_x_LIMIT_BALANCES_tbl        QP_Limits_PUB.Limit_Balances_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_LIMIT_BALANCES;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_Limits_PVT.Process_Limits

    QP_Limits_PVT.Process_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_LIMITS_rec                  => l_x_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_x_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_x_LIMIT_BALANCES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Entity;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_available_amount              IN  NUMBER
,   p_consumed_amount               IN  NUMBER
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_limit_balance_id              IN  NUMBER
,   p_limit_id                      IN  NUMBER
,   p_multival_attr1_type           IN  VARCHAR2
,   p_multival_attr1_context        IN  VARCHAR2
,   p_multival_attribute1           IN  VARCHAR2
,   p_multival_attr1_value          IN  VARCHAR2
,   p_multival_attr1_datatype       IN  VARCHAR2
,   p_multival_attr2_type           IN  VARCHAR2
,   p_multival_attr2_context        IN  VARCHAR2
,   p_multival_attribute2           IN  VARCHAR2
,   p_multival_attr2_value          IN  VARCHAR2
,   p_multival_attr2_datatype       IN  VARCHAR2
,   p_organization_attr_context     IN  VARCHAR2
,   p_organization_attribute        IN  VARCHAR2
,   p_organization_attr_value       IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_reserved_amount               IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_x_LIMITS_rec                QP_Limits_PUB.Limits_Rec_Type;
l_x_LIMIT_ATTRS_rec           QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_x_LIMIT_ATTRS_tbl           QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_x_LIMIT_BALANCES_rec        QP_Limits_PUB.Limit_Balances_Rec_Type;
l_x_LIMIT_BALANCES_tbl        QP_Limits_PUB.Limit_Balances_Tbl_Type;
BEGIN

    --  Load LIMIT_BALANCES record

    l_LIMIT_BALANCES_rec.attribute1 := p_attribute1;
    l_LIMIT_BALANCES_rec.attribute10 := p_attribute10;
    l_LIMIT_BALANCES_rec.attribute11 := p_attribute11;
    l_LIMIT_BALANCES_rec.attribute12 := p_attribute12;
    l_LIMIT_BALANCES_rec.attribute13 := p_attribute13;
    l_LIMIT_BALANCES_rec.attribute14 := p_attribute14;
    l_LIMIT_BALANCES_rec.attribute15 := p_attribute15;
    l_LIMIT_BALANCES_rec.attribute2 := p_attribute2;
    l_LIMIT_BALANCES_rec.attribute3 := p_attribute3;
    l_LIMIT_BALANCES_rec.attribute4 := p_attribute4;
    l_LIMIT_BALANCES_rec.attribute5 := p_attribute5;
    l_LIMIT_BALANCES_rec.attribute6 := p_attribute6;
    l_LIMIT_BALANCES_rec.attribute7 := p_attribute7;
    l_LIMIT_BALANCES_rec.attribute8 := p_attribute8;
    l_LIMIT_BALANCES_rec.attribute9 := p_attribute9;
    l_LIMIT_BALANCES_rec.available_amount := p_available_amount;
    l_LIMIT_BALANCES_rec.consumed_amount := p_consumed_amount;
    l_LIMIT_BALANCES_rec.context   := p_context;
    l_LIMIT_BALANCES_rec.created_by := p_created_by;
    l_LIMIT_BALANCES_rec.creation_date := p_creation_date;
    l_LIMIT_BALANCES_rec.last_updated_by := p_last_updated_by;
    l_LIMIT_BALANCES_rec.last_update_date := p_last_update_date;
    l_LIMIT_BALANCES_rec.last_update_login := p_last_update_login;
    l_LIMIT_BALANCES_rec.limit_balance_id := p_limit_balance_id;
    l_LIMIT_BALANCES_rec.limit_id  := p_limit_id;
    l_LIMIT_BALANCES_rec.multival_attr1_type := p_multival_attr1_type;
    l_LIMIT_BALANCES_rec.multival_attr1_context := p_multival_attr1_context;
    l_LIMIT_BALANCES_rec.multival_attribute1 := p_multival_attribute1;
    l_LIMIT_BALANCES_rec.multival_attr1_value := p_multival_attr1_value;
    l_LIMIT_BALANCES_rec.multival_attr1_datatype := p_multival_attr1_datatype;
    l_LIMIT_BALANCES_rec.multival_attr2_type := p_multival_attr2_type;
    l_LIMIT_BALANCES_rec.multival_attr2_context := p_multival_attr2_context;
    l_LIMIT_BALANCES_rec.multival_attribute2 := p_multival_attribute2;
    l_LIMIT_BALANCES_rec.multival_attr2_value := p_multival_attr2_value;
    l_LIMIT_BALANCES_rec.multival_attr2_datatype := p_multival_attr2_datatype;
    l_LIMIT_BALANCES_rec.organization_attr_context := p_organization_attr_context;
    l_LIMIT_BALANCES_rec.organization_attribute := p_organization_attribute;
    l_LIMIT_BALANCES_rec.organization_attr_value := p_organization_attr_value;
    l_LIMIT_BALANCES_rec.program_application_id := p_program_application_id;
    l_LIMIT_BALANCES_rec.program_id := p_program_id;
    l_LIMIT_BALANCES_rec.program_update_date := p_program_update_date;
    l_LIMIT_BALANCES_rec.request_id := p_request_id;
    l_LIMIT_BALANCES_rec.reserved_amount := p_reserved_amount;

    --  Populate LIMIT_BALANCES table

    l_LIMIT_BALANCES_tbl(1) := l_LIMIT_BALANCES_rec;

    --  Call QP_Limits_PVT.Lock_Limits

    QP_Limits_PVT.Lock_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    ,   x_LIMITS_rec                  => l_x_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_x_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_x_LIMIT_BALANCES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_LIMIT_BALANCES_rec.db_flag := FND_API.G_TRUE;

        Write_LIMIT_BALANCES
        (   p_LIMIT_BALANCES_rec          => l_x_LIMIT_BALANCES_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;

--  Procedures maintaining LIMIT_BALANCES record cache.

PROCEDURE Write_LIMIT_BALANCES
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_LIMIT_BALANCES_rec := p_LIMIT_BALANCES_rec;

    IF p_db_record THEN

        g_db_LIMIT_BALANCES_rec := p_LIMIT_BALANCES_rec;

    END IF;

END Write_Limit_Balances;

FUNCTION Get_LIMIT_BALANCES
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_limit_balance_id              IN  NUMBER
)
RETURN QP_Limits_PUB.Limit_Balances_Rec_Type
IS
BEGIN

    IF  p_limit_balance_id <> g_LIMIT_BALANCES_rec.limit_balance_id
    THEN

        --  Query row from DB

        g_LIMIT_BALANCES_rec := QP_Limit_Balances_Util.Query_Row
        (   p_limit_balance_id            => p_limit_balance_id
        );

        g_LIMIT_BALANCES_rec.db_flag   := FND_API.G_TRUE;

        --  Load DB record

        g_db_LIMIT_BALANCES_rec        := g_LIMIT_BALANCES_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_LIMIT_BALANCES_rec;

    ELSE

        RETURN g_LIMIT_BALANCES_rec;

    END IF;

END Get_Limit_Balances;

PROCEDURE Clear_Limit_Balances
IS
BEGIN

    g_LIMIT_BALANCES_rec           := QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC;
    g_db_LIMIT_BALANCES_rec        := QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC;

END Clear_Limit_Balances;

END QP_QP_Form_Limit_Balances;

/
