--------------------------------------------------------
--  DDL for Package Body INV_TO_FORM_TROHDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TO_FORM_TROHDR" AS
/* $Header: INVFTRHB.pls 120.1 2005/06/17 14:20:31 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_TO_Form_Trohdr';

--  Global variables holding cached record.

g_trohdr_rec                  INV_Move_Order_PUB.Trohdr_Rec_Type;
g_db_trohdr_rec               INV_Move_Order_PUB.Trohdr_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_trohdr
(   p_trohdr_rec                    IN  INV_Move_Order_PUB.Trohdr_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_trohdr
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_header_id                     IN  NUMBER
)
RETURN INV_Move_Order_PUB.Trohdr_Rec_Type;

PROCEDURE Clear_trohdr;

--  Global variable holding performed operations.

g_opr__tbl                    INV_Move_Order_PUB.Trohdr_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_attribute_category            OUT NOCOPY VARCHAR2
,   x_date_required                 OUT NOCOPY DATE
,   x_description                   OUT NOCOPY VARCHAR2
,   x_from_subinventory_code        OUT NOCOPY VARCHAR2
,   x_header_id                     OUT NOCOPY NUMBER
,   x_header_status                 OUT NOCOPY NUMBER
,   x_organization_id               OUT NOCOPY NUMBER
,   x_request_number                OUT NOCOPY VARCHAR2
,   x_status_date                   OUT NOCOPY DATE
,   x_to_account_id                 OUT NOCOPY NUMBER
,   x_to_subinventory_code          OUT NOCOPY VARCHAR2
,   x_move_order_type	            OUT NOCOPY NUMBER
,   x_from_subinventory             OUT NOCOPY VARCHAR2
,   x_header                        OUT NOCOPY VARCHAR2
,   x_organization                  OUT NOCOPY VARCHAR2
,   x_to_account                    OUT NOCOPY VARCHAR2
,   x_to_subinventory               OUT NOCOPY VARCHAR2
,   x_move_order_type_name          OUT NOCOPY VARCHAR2
,   x_transaction_type_id	    OUT NOCOPY NUMBER
,   x_ship_to_location_id           OUT NOCOPY NUMBER
)
IS
l_trohdr_rec                  INV_Move_Order_PUB.Trohdr_Rec_Type;
l_trohdr_val_rec              INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
BEGIN

    INV_GLOBALS.G_CALL_MODE            := 'FORM';
    INV_GLOBALS.G_MAX_LINE_NUM         := null;
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

    l_trohdr_rec.attribute1                       := NULL;
    l_trohdr_rec.attribute10                      := NULL;
    l_trohdr_rec.attribute11                      := NULL;
    l_trohdr_rec.attribute12                      := NULL;
    l_trohdr_rec.attribute13                      := NULL;
    l_trohdr_rec.attribute14                      := NULL;
    l_trohdr_rec.attribute15                      := NULL;
    l_trohdr_rec.attribute2                       := NULL;
    l_trohdr_rec.attribute3                       := NULL;
    l_trohdr_rec.attribute4                       := NULL;
    l_trohdr_rec.attribute5                       := NULL;
    l_trohdr_rec.attribute6                       := NULL;
    l_trohdr_rec.attribute7                       := NULL;
    l_trohdr_rec.attribute8                       := NULL;
    l_trohdr_rec.attribute9                       := NULL;
    l_trohdr_rec.attribute_category               := NULL;

    --  Set Operation to Create

    l_trohdr_rec.operation := INV_GLOBALS.G_OPR_CREATE;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trohdr_rec                  => l_trohdr_rec
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    x_attribute1                   := l_x_trohdr_rec.attribute1;
    x_attribute10                  := l_x_trohdr_rec.attribute10;
    x_attribute11                  := l_x_trohdr_rec.attribute11;
    x_attribute12                  := l_x_trohdr_rec.attribute12;
    x_attribute13                  := l_x_trohdr_rec.attribute13;
    x_attribute14                  := l_x_trohdr_rec.attribute14;
    x_attribute15                  := l_x_trohdr_rec.attribute15;
    x_attribute2                   := l_x_trohdr_rec.attribute2;
    x_attribute3                   := l_x_trohdr_rec.attribute3;
    x_attribute4                   := l_x_trohdr_rec.attribute4;
    x_attribute5                   := l_x_trohdr_rec.attribute5;
    x_attribute6                   := l_x_trohdr_rec.attribute6;
    x_attribute7                   := l_x_trohdr_rec.attribute7;
    x_attribute8                   := l_x_trohdr_rec.attribute8;
    x_attribute9                   := l_x_trohdr_rec.attribute9;
    x_attribute_category           := l_x_trohdr_rec.attribute_category;
    x_date_required                := l_x_trohdr_rec.date_required;
    x_description                  := l_x_trohdr_rec.description;
    x_from_subinventory_code       := l_x_trohdr_rec.from_subinventory_code;
    x_header_id                    := l_x_trohdr_rec.header_id;
    x_header_status                := l_x_trohdr_rec.header_status;
    x_organization_id              := l_x_trohdr_rec.organization_id;
    x_request_number               := l_x_trohdr_rec.request_number;
    x_status_date                  := l_x_trohdr_rec.status_date;
    x_to_account_id                := l_x_trohdr_rec.to_account_id;
    x_to_subinventory_code         := l_x_trohdr_rec.to_subinventory_code;
    --ssia move order enhancement changes
    x_move_order_type              := l_x_trohdr_rec.move_order_type;
    -- ssia end of changes
    x_transaction_type_id	   := l_x_trohdr_rec.transaction_type_id;
    x_ship_to_location_id          := l_x_trohdr_rec.ship_to_location_id;
    --  Load display out parameters if any

    l_trohdr_val_rec := INV_Trohdr_Util.Get_Values
    (   p_trohdr_rec                  => l_x_trohdr_rec
    );
    x_from_subinventory            := l_trohdr_val_rec.from_subinventory;
    x_header                       := l_trohdr_val_rec.header;
    x_organization                 := l_trohdr_val_rec.organization;
    x_to_account                   := l_trohdr_val_rec.to_account;
    x_to_subinventory              := l_trohdr_val_rec.to_subinventory;
    x_move_order_type_name         := l_trohdr_val_rec.move_order_type;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_trohdr_rec.db_flag := FND_API.G_FALSE;

    Write_trohdr
    (   p_trohdr_rec                  => l_x_trohdr_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attribute
--

PROCEDURE Validate_Record
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
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
,   p_attribute_category            IN  VARCHAR2
,   p_date_required                 IN  DATE
,   p_description                   IN  VARCHAR2
,   p_from_subinventory_code        IN  VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_header_status                 IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_request_number                IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_to_account_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_move_order_type               IN  NUMBER
,   p_transaction_type_id	    IN  NUMBER
,   p_ship_to_location_id           IN  NUMBER
,   p_db_flag                       IN  VARCHAR2
)
IS
l_trohdr_rec                  INV_Move_Order_PUB.Trohdr_Rec_Type;
l_old_trohdr_rec              INV_Move_Order_PUB.Trohdr_Rec_Type;
l_trohdr_val_rec              INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    l_trohdr_rec.db_flag               := p_db_flag;
    --  Read trohdr from cache

    IF FND_API.To_Boolean(l_trohdr_rec.db_flag) THEN
    	l_trohdr_rec := Get_trohdr
    	(   p_db_record                   => FALSE
    	,   p_header_id                   => p_header_id
    	);
    End If;

    l_old_trohdr_rec               := l_trohdr_rec;

    l_trohdr_rec.date_required          := p_date_required;
    l_trohdr_rec.description            := p_description;
    l_trohdr_rec.from_subinventory_code := p_from_subinventory_code;
    l_trohdr_rec.header_id              := p_header_id;
    l_trohdr_rec.header_status          := p_header_status;
    l_trohdr_rec.organization_id        := p_organization_id;
    l_trohdr_rec.request_number         := p_request_number;
    l_trohdr_rec.status_date            := p_status_date;
    l_trohdr_rec.to_account_id          := p_to_account_id;
    l_trohdr_rec.to_subinventory_code   := p_to_subinventory_code;
    -- ssia move order enhancement changes
    l_trohdr_rec.move_order_type        := p_move_order_type;
    -- ssia end of chnages
    l_trohdr_rec.transaction_type_id	:= p_transaction_type_id;
    l_trohdr_rec.ship_to_location_id    := p_ship_to_location_id;
    l_trohdr_rec.attribute1             := p_attribute1;
    l_trohdr_rec.attribute10            := p_attribute10;
    l_trohdr_rec.attribute11            := p_attribute11;
    l_trohdr_rec.attribute12            := p_attribute12;
    l_trohdr_rec.attribute13            := p_attribute13;
    l_trohdr_rec.attribute14            := p_attribute14;
    l_trohdr_rec.attribute15            := p_attribute15;
    l_trohdr_rec.attribute2             := p_attribute2;
    l_trohdr_rec.attribute3             := p_attribute3;
    l_trohdr_rec.attribute4             := p_attribute4;
    l_trohdr_rec.attribute5             := p_attribute5;
    l_trohdr_rec.attribute6             := p_attribute6;
    l_trohdr_rec.attribute7             := p_attribute7;
    l_trohdr_rec.attribute8             := p_attribute8;
    l_trohdr_rec.attribute9             := p_attribute9;
    l_trohdr_rec.attribute_category     := p_attribute_category;

    --  Set Operation.

    IF FND_API.To_Boolean(l_trohdr_rec.db_flag) THEN
        l_trohdr_rec.operation := INV_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_trohdr_rec.operation := INV_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trohdr_rec                  => l_trohdr_rec
    ,   p_old_trohdr_rec              => l_old_trohdr_rec
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


/*
    --  Init OUT NOCOPY parameters to missing.

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
    x_attribute_category           := FND_API.G_MISS_CHAR;
    x_date_required                := FND_API.G_MISS_DATE;
    x_description                  := FND_API.G_MISS_CHAR;
    x_from_subinventory_code       := FND_API.G_MISS_CHAR;
    x_header_id                    := FND_API.G_MISS_NUM;
    x_header_status                := FND_API.G_MISS_NUM;
    x_organization_id              := FND_API.G_MISS_NUM;
    x_request_number               := FND_API.G_MISS_CHAR;
    x_status_date                  := FND_API.G_MISS_DATE;
    x_to_account_id                := FND_API.G_MISS_NUM;
    x_to_subinventory_code         := FND_API.G_MISS_CHAR;
    x_move_order_type	           := FND_API.G_MISS_NUM;
    x_transaction_type_id	   := FND_API.G_MISS_NUM;
    x_from_subinventory            := FND_API.G_MISS_CHAR;
    x_header                       := FND_API.G_MISS_CHAR;
    x_organization                 := FND_API.G_MISS_CHAR;
    x_to_account                   := FND_API.G_MISS_CHAR;
    x_to_subinventory              := FND_API.G_MISS_CHAR;
    --ssia move order enhancement changes
    x_move_order_type_name         := FND_API.G_MISS_CHAR;
    -- ssia end of changes
    x_ship_to_location_id          := FND_API.G_MISS_NUM;
    --  Load display out parameters if any

    l_trohdr_val_rec := INV_Trohdr_Util.Get_Values
    (   p_trohdr_rec                  => l_x_trohdr_rec
    ,   p_old_trohdr_rec              => l_trohdr_rec
    );

    --  Return changed attributes.

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute1,
                            l_trohdr_rec.attribute1)
    THEN
        x_attribute1 := l_x_trohdr_rec.attribute1;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute10,
                            l_trohdr_rec.attribute10)
    THEN
        x_attribute10 := l_x_trohdr_rec.attribute10;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute11,
                            l_trohdr_rec.attribute11)
    THEN
        x_attribute11 := l_x_trohdr_rec.attribute11;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute12,
                            l_trohdr_rec.attribute12)
    THEN
        x_attribute12 := l_x_trohdr_rec.attribute12;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute13,
                            l_trohdr_rec.attribute13)
    THEN
        x_attribute13 := l_x_trohdr_rec.attribute13;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute14,
                            l_trohdr_rec.attribute14)
    THEN
        x_attribute14 := l_x_trohdr_rec.attribute14;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute15,
                            l_trohdr_rec.attribute15)
    THEN
        x_attribute15 := l_x_trohdr_rec.attribute15;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute2,
                            l_trohdr_rec.attribute2)
    THEN
        x_attribute2 := l_x_trohdr_rec.attribute2;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute3,
                            l_trohdr_rec.attribute3)
    THEN
        x_attribute3 := l_x_trohdr_rec.attribute3;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute4,
                            l_trohdr_rec.attribute4)
    THEN
        x_attribute4 := l_x_trohdr_rec.attribute4;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute5,
                            l_trohdr_rec.attribute5)
    THEN
        x_attribute5 := l_x_trohdr_rec.attribute5;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute6,
                            l_trohdr_rec.attribute6)
    THEN
        x_attribute6 := l_x_trohdr_rec.attribute6;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute7,
                            l_trohdr_rec.attribute7)
    THEN
        x_attribute7 := l_x_trohdr_rec.attribute7;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute8,
                            l_trohdr_rec.attribute8)
    THEN
        x_attribute8 := l_x_trohdr_rec.attribute8;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute9,
                            l_trohdr_rec.attribute9)
    THEN
        x_attribute9 := l_x_trohdr_rec.attribute9;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.attribute_category,
                            l_trohdr_rec.attribute_category)
    THEN
        x_attribute_category := l_x_trohdr_rec.attribute_category;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.date_required,
                            l_trohdr_rec.date_required)
    THEN
        x_date_required := l_x_trohdr_rec.date_required;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.description,
                            l_trohdr_rec.description)
    THEN
        x_description := l_x_trohdr_rec.description;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.from_subinventory_code,
                            l_trohdr_rec.from_subinventory_code)
    THEN
        x_from_subinventory_code := l_x_trohdr_rec.from_subinventory_code;
        x_from_subinventory := l_trohdr_val_rec.from_subinventory;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.header_id,
                            l_trohdr_rec.header_id)
    THEN
        x_header_id := l_x_trohdr_rec.header_id;
        x_header := l_trohdr_val_rec.header;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.header_status,
                            l_trohdr_rec.header_status)
    THEN
        x_header_status := l_x_trohdr_rec.header_status;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.organization_id,
                            l_trohdr_rec.organization_id)
    THEN
        x_organization_id := l_x_trohdr_rec.organization_id;
        x_organization := l_trohdr_val_rec.organization;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.request_number,
                            l_trohdr_rec.request_number)
    THEN
        x_request_number := l_x_trohdr_rec.request_number;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.status_date,
                            l_trohdr_rec.status_date)
    THEN
        x_status_date := l_x_trohdr_rec.status_date;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.to_account_id,
                            l_trohdr_rec.to_account_id)
    THEN
        x_to_account_id := l_x_trohdr_rec.to_account_id;
        x_to_account := l_trohdr_val_rec.to_account;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.to_subinventory_code,
                            l_trohdr_rec.to_subinventory_code)
    THEN
        x_to_subinventory_code := l_x_trohdr_rec.to_subinventory_code;
        x_to_subinventory := l_trohdr_val_rec.to_subinventory;
    END IF;

    -- ssia mo enhancement changes
    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.move_order_type,
                            l_trohdr_rec.move_order_type)
    THEN
        x_move_order_type := l_x_trohdr_rec.move_order_type;
        x_move_order_type_name := l_trohdr_val_rec.move_order_type;
    END IF;
    -- ssia end of changes

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.transaction_type_id,
                            l_trohdr_rec.transaction_type_id)
    THEN
        x_transaction_type_id := l_x_trohdr_rec.transaction_type_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trohdr_rec.ship_to_location_id,
                             l_trohdr_rec.ship_to_location_id)
    THEN
       x_ship_to_location_id  := l_x_trohdr_rec.ship_to_location_id;
    END IF;

*/

    --  Write to cache.

    Write_trohdr
    (   p_trohdr_rec                  => l_x_trohdr_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Validate_Record;

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
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
,   p_attribute_category            IN  VARCHAR2
,   p_date_required                 IN  DATE
,   p_description                   IN  VARCHAR2
,   p_from_subinventory_code        IN  VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_header_status                 IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_request_number                IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_to_account_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_move_order_type	            IN  NUMBER
,   p_transaction_type_id	    IN  NUMBER
,   p_ship_to_location_id           IN  NUMBER
,   p_db_flag                       IN  VARCHAR2
,   x_creation_date                 OUT NOCOPY DATE
,   x_created_by                    OUT NOCOPY NUMBER
,   x_last_update_date              OUT NOCOPY DATE
,   x_last_updated_by               OUT NOCOPY NUMBER
,   x_last_update_login             OUT NOCOPY NUMBER
)
IS
l_trohdr_rec                  INV_Move_Order_PUB.Trohdr_Rec_Type;
l_old_trohdr_rec              INV_Move_Order_PUB.Trohdr_Rec_Type;
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
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

    g_trohdr_rec.date_required          := p_date_required;
    g_trohdr_rec.description            := p_description;
    g_trohdr_rec.from_subinventory_code := p_from_subinventory_code;
    g_trohdr_rec.header_id              := p_header_id;
    g_trohdr_rec.header_status          := p_header_status;
    g_trohdr_rec.organization_id        := p_organization_id;
    g_trohdr_rec.request_number         := p_request_number;
    g_trohdr_rec.status_date            := p_status_date;
    g_trohdr_rec.to_account_id          := p_to_account_id;
    g_trohdr_rec.to_subinventory_code   := p_to_subinventory_code;
    g_trohdr_rec.move_order_type        := p_move_order_type; -- ssia mo enhancement changes
    g_trohdr_rec.transaction_type_id    := p_transaction_type_id;
    g_trohdr_rec.ship_to_location_id    := p_ship_to_location_id;
    g_trohdr_rec.attribute1             := p_attribute1;
    g_trohdr_rec.attribute10            := p_attribute10;
    g_trohdr_rec.attribute11            := p_attribute11;
    g_trohdr_rec.attribute12            := p_attribute12;
    g_trohdr_rec.attribute13            := p_attribute13;
    g_trohdr_rec.attribute14            := p_attribute14;
    g_trohdr_rec.attribute15            := p_attribute15;
    g_trohdr_rec.attribute2             := p_attribute2;
    g_trohdr_rec.attribute3             := p_attribute3;
    g_trohdr_rec.attribute4             := p_attribute4;
    g_trohdr_rec.attribute5             := p_attribute5;
    g_trohdr_rec.attribute6             := p_attribute6;
    g_trohdr_rec.attribute7             := p_attribute7;
    g_trohdr_rec.attribute8             := p_attribute8;
    g_trohdr_rec.attribute9             := p_attribute9;
    g_trohdr_rec.attribute_category     := p_attribute_category;
    g_trohdr_rec.db_flag                := p_db_flag;

    --  Read trohdr from cache

    l_old_trohdr_rec := Get_trohdr
    (   p_db_record                   => TRUE
    ,   p_header_id                   => p_header_id
    );

    l_trohdr_rec := Get_trohdr
    (   p_db_record                   => FALSE
    ,   p_header_id                   => p_header_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_trohdr_rec.db_flag) THEN
        l_trohdr_rec.operation := INV_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_trohdr_rec.operation := INV_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trohdr_rec                  => l_trohdr_rec
    ,   p_old_trohdr_rec              => l_old_trohdr_rec
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.


    x_creation_date                := l_x_trohdr_rec.creation_date;
    x_created_by                   := l_x_trohdr_rec.created_by;
    x_last_update_date             := l_x_trohdr_rec.last_update_date;
    x_last_updated_by              := l_x_trohdr_rec.last_updated_by;
    x_last_update_login            := l_x_trohdr_rec.last_update_login;

    --  Clear trohdr record cache

    Clear_trohdr;

    --  Keep track of performed operations.

    l_old_trohdr_rec.operation := l_trohdr_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Validate_And_Write;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
)
IS
l_trohdr_rec                  INV_Move_Order_PUB.Trohdr_Rec_Type;
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
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

    l_trohdr_rec := Get_trohdr
    (   p_db_record                   => TRUE
    ,   p_header_id                   => p_header_id
    );

    --  Set Operation.

    l_trohdr_rec.operation := INV_GLOBALS.G_OPR_DELETE;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trohdr_rec                  => l_trohdr_rec
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear trohdr record cache

    Clear_trohdr;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := INV_GLOBALS.G_ENTITY_TROHDR;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Entity;

--  Procedure       Process_Object
--

PROCEDURE Process_Object
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := INV_GLOBALS.G_ENTITY_ALL;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Object'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Object;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
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
,   p_attribute_category            IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_date_required                 IN  DATE
,   p_description                   IN  VARCHAR2
,   p_from_subinventory_code        IN  VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_header_status                 IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_request_number                IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_to_account_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_move_order_type               IN  NUMBER
,   p_transaction_type_id	    IN  NUMBER
,   p_ship_to_location_id           IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_trohdr_rec                  INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
BEGIN

    --  Load trohdr record

    l_trohdr_rec.attribute1        := p_attribute1;
    l_trohdr_rec.attribute10       := p_attribute10;
    l_trohdr_rec.attribute11       := p_attribute11;
    l_trohdr_rec.attribute12       := p_attribute12;
    l_trohdr_rec.attribute13       := p_attribute13;
    l_trohdr_rec.attribute14       := p_attribute14;
    l_trohdr_rec.attribute15       := p_attribute15;
    l_trohdr_rec.attribute2        := p_attribute2;
    l_trohdr_rec.attribute3        := p_attribute3;
    l_trohdr_rec.attribute4        := p_attribute4;
    l_trohdr_rec.attribute5        := p_attribute5;
    l_trohdr_rec.attribute6        := p_attribute6;
    l_trohdr_rec.attribute7        := p_attribute7;
    l_trohdr_rec.attribute8        := p_attribute8;
    l_trohdr_rec.attribute9        := p_attribute9;
    l_trohdr_rec.attribute_category := p_attribute_category;
    l_trohdr_rec.created_by        := p_created_by;
    l_trohdr_rec.creation_date     := p_creation_date;
    l_trohdr_rec.date_required     := p_date_required;
    l_trohdr_rec.description       := p_description;
    l_trohdr_rec.from_subinventory_code := p_from_subinventory_code;
    l_trohdr_rec.header_id         := p_header_id;
    l_trohdr_rec.header_status     := p_header_status;
    l_trohdr_rec.last_updated_by   := p_last_updated_by;
    l_trohdr_rec.last_update_date  := p_last_update_date;
    l_trohdr_rec.last_update_login := p_last_update_login;
    l_trohdr_rec.organization_id   := p_organization_id;
    l_trohdr_rec.program_application_id := p_program_application_id;
    l_trohdr_rec.program_id        := p_program_id;
    l_trohdr_rec.program_update_date := p_program_update_date;
    l_trohdr_rec.request_id        := p_request_id;
    l_trohdr_rec.request_number    := p_request_number;
    l_trohdr_rec.status_date       := p_status_date;
    l_trohdr_rec.to_account_id     := p_to_account_id;
    l_trohdr_rec.to_subinventory_code := p_to_subinventory_code;
    l_trohdr_rec.move_order_type   := p_move_order_type; -- ssia mo enhancement changes
    l_trohdr_rec.transaction_type_id := p_transaction_type_id;
    l_trohdr_rec.ship_to_location_id := p_ship_to_location_id;

    --  Call INV_Transfer_Order_PVT.Lock_Transfer_Order

    INV_Transfer_Order_PVT.Lock_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_trohdr_rec                  => l_trohdr_rec
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_trohdr_rec.db_flag := FND_API.G_TRUE;

        Write_trohdr
        (   p_trohdr_rec                  => l_x_trohdr_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;

--  Procedures maintaining trohdr record cache.

PROCEDURE Write_trohdr
(   p_trohdr_rec                    IN  INV_Move_Order_PUB.Trohdr_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_trohdr_rec := p_trohdr_rec;

    IF p_db_record THEN

        g_db_trohdr_rec := p_trohdr_rec;

    END IF;

END Write_Trohdr;

FUNCTION Get_trohdr
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_header_id                     IN  NUMBER
)
RETURN INV_Move_Order_PUB.Trohdr_Rec_Type
IS
BEGIN

    IF  p_header_id <> g_trohdr_rec.header_id
    THEN

        --  Query row from DB

        g_trohdr_rec := INV_Trohdr_Util.Query_Row
        (   p_header_id                   => p_header_id
        );

        g_trohdr_rec.db_flag           := FND_API.G_TRUE;

        --  Load DB record

        g_db_trohdr_rec                := g_trohdr_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_trohdr_rec;

    ELSE

        RETURN g_trohdr_rec;

    END IF;

END Get_Trohdr;

PROCEDURE Clear_Trohdr
IS
BEGIN

    g_trohdr_rec                   := INV_Move_Order_PUB.G_MISS_TROHDR_REC;
    g_db_trohdr_rec                := INV_Move_Order_PUB.G_MISS_TROHDR_REC;

END Clear_Trohdr;

END INV_TO_Form_Trohdr;

/
