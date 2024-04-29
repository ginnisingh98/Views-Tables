--------------------------------------------------------
--  DDL for Package Body INV_TO_FORM_TROLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TO_FORM_TROLIN" AS
/* $Header: INVFTRLB.pls 120.0 2005/05/25 06:25:41 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_TO_Form_Trolin';

--  Global variables holding cached record.

g_trolin_rec                  INV_Move_Order_PUB.Trolin_Rec_Type;
g_db_trolin_rec               INV_Move_Order_PUB.Trolin_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_trolin
(   p_trolin_rec                    IN  INV_Move_Order_PUB.Trolin_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_trolin
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_line_id                       IN  NUMBER
)
RETURN INV_Move_Order_PUB.Trolin_Rec_Type;

PROCEDURE Clear_trolin;

--  Global variable holding performed operations.

g_opr__tbl                    INV_Move_Order_PUB.Trolin_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_id              	    IN  NUMBER
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
,   x_from_locator_id               OUT NOCOPY NUMBER
,   x_from_subinventory_code        OUT NOCOPY VARCHAR2
,   x_from_subinventory_id          OUT NOCOPY NUMBER
,   x_header_id                     OUT NOCOPY NUMBER
,   x_inventory_item_id             OUT NOCOPY NUMBER
,   x_line_id                       OUT NOCOPY NUMBER
,   x_line_number                   OUT NOCOPY NUMBER
,   x_line_status                   OUT NOCOPY NUMBER
,   x_lot_number                    OUT NOCOPY VARCHAR2
,   x_organization_id               OUT NOCOPY NUMBER
,   x_project_id                    OUT NOCOPY NUMBER
,   x_quantity                      OUT NOCOPY NUMBER
,   x_quantity_delivered            OUT NOCOPY NUMBER
,   x_quantity_detailed             OUT NOCOPY NUMBER
,   x_reason_id                     OUT NOCOPY NUMBER
,   x_reference                     OUT NOCOPY VARCHAR2
,   x_reference_id                  OUT NOCOPY NUMBER
,   x_reference_type_code           OUT NOCOPY NUMBER
,   x_revision                      OUT NOCOPY VARCHAR2
,   x_serial_number_end             OUT NOCOPY VARCHAR2
,   x_serial_number_start           OUT NOCOPY VARCHAR2
,   x_status_date                   OUT NOCOPY DATE
,   x_task_id                       OUT NOCOPY NUMBER
,   x_to_account_id                 OUT NOCOPY NUMBER
,   x_to_locator_id                 OUT NOCOPY NUMBER
,   x_to_subinventory_code          OUT NOCOPY VARCHAR2
,   x_to_subinventory_id            OUT NOCOPY NUMBER
,   x_transaction_header_id         OUT NOCOPY NUMBER
,   x_uom_code                      OUT NOCOPY VARCHAR2
,   x_from_locator                  OUT NOCOPY VARCHAR2
,   x_inventory_item                OUT NOCOPY VARCHAR2
,   x_project                       OUT NOCOPY VARCHAR2
,   x_reason                        OUT NOCOPY VARCHAR2
,   x_reference_type                OUT NOCOPY VARCHAR2
,   x_task                          OUT NOCOPY VARCHAR2
,   x_to_account                    OUT NOCOPY VARCHAR2
,   x_to_locator                    OUT NOCOPY VARCHAR2
,   x_transaction_type_id           OUT NOCOPY NUMBER
,   x_transaction_source_type_id    OUT NOCOPY NUMBER
,   x_txn_source_id                 OUT NOCOPY NUMBER
,   x_txn_source_line_id            OUT NOCOPY NUMBER
,   x_txn_source_line_detail_id     OUT NOCOPY NUMBER
,   x_primary_quantity              OUT NOCOPY NUMBER
,   x_to_organization_id            OUT NOCOPY NUMBER
,   x_pick_strategy_id              OUT NOCOPY NUMBER
,   x_put_away_strategy_id          OUT NOCOPY NUMBER
,   x_unit_number          	    OUT NOCOPY VARCHAR2
-- ,   x_ship_to_location_id           OUT NOCOPY NUMBER -- NL MERGE
,   x_transaction_type		    OUT NOCOPY VARCHAR2
,   x_secondary_quantity                      OUT NOCOPY NUMBER   --INVCONV change
,   x_secondary_quantity_delivered            OUT NOCOPY NUMBER   --INVCONV change
,   x_secondary_quantity_detailed             OUT NOCOPY NUMBER   --INVCONV change
,   x_secondary_uom_code                      OUT NOCOPY VARCHAR2 --INVCONV change
,   x_grade_code                              OUT NOCOPY VARCHAR2 --INVCONV change
)
IS
l_trolin_rec                  INV_Move_Order_PUB.Trolin_Rec_Type;
l_trolin_val_rec              INV_Move_Order_PUB.Trolin_Val_Rec_Type;
l_trolin_tbl                  INV_Move_Order_PUB.Trolin_Tbl_Type;
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    /* inv_debug.message('In default for lines'); */
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
    l_trolin_rec.header_id 	       := p_header_id;


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_trolin_rec.attribute1                       := NULL;
    l_trolin_rec.attribute10                      := NULL;
    l_trolin_rec.attribute11                      := NULL;
    l_trolin_rec.attribute12                      := NULL;
    l_trolin_rec.attribute13                      := NULL;
    l_trolin_rec.attribute14                      := NULL;
    l_trolin_rec.attribute15                      := NULL;
    l_trolin_rec.attribute2                       := NULL;
    l_trolin_rec.attribute3                       := NULL;
    l_trolin_rec.attribute4                       := NULL;
    l_trolin_rec.attribute5                       := NULL;
    l_trolin_rec.attribute6                       := NULL;
    l_trolin_rec.attribute7                       := NULL;
    l_trolin_rec.attribute8                       := NULL;
    l_trolin_rec.attribute9                       := NULL;
    l_trolin_rec.attribute_category               := NULL;

    --  Set Operation to Create

    l_trolin_rec.operation := INV_GLOBALS.G_OPR_CREATE;

    --  Populate trolin table

    l_trolin_tbl(1) := l_trolin_rec;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order
    /* Inv_debug.message('Before Process Order in default lines'); */

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trolin_tbl                  => l_trolin_tbl
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    /* Inv_debug.message('After Process Order'||l_return_status); */
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_trolin_rec := l_x_trolin_tbl(1);

    --  Load OUT NOCOPY parameters.

    x_attribute1                   := l_x_trolin_rec.attribute1;
    x_attribute10                  := l_x_trolin_rec.attribute10;
    x_attribute11                  := l_x_trolin_rec.attribute11;
    x_attribute12                  := l_x_trolin_rec.attribute12;
    x_attribute13                  := l_x_trolin_rec.attribute13;
    x_attribute14                  := l_x_trolin_rec.attribute14;
    x_attribute15                  := l_x_trolin_rec.attribute15;
    x_attribute2                   := l_x_trolin_rec.attribute2;
    x_attribute3                   := l_x_trolin_rec.attribute3;
    x_attribute4                   := l_x_trolin_rec.attribute4;
    x_attribute5                   := l_x_trolin_rec.attribute5;
    x_attribute6                   := l_x_trolin_rec.attribute6;
    x_attribute7                   := l_x_trolin_rec.attribute7;
    x_attribute8                   := l_x_trolin_rec.attribute8;
    x_attribute9                   := l_x_trolin_rec.attribute9;
    x_attribute_category           := l_x_trolin_rec.attribute_category;
    x_date_required                := l_x_trolin_rec.date_required;
    x_from_locator_id              := l_x_trolin_rec.from_locator_id;
    x_from_subinventory_code       := l_x_trolin_rec.from_subinventory_code;
    x_from_subinventory_id         := l_x_trolin_rec.from_subinventory_id;
    x_header_id                    := l_x_trolin_rec.header_id;
    x_inventory_item_id            := l_x_trolin_rec.inventory_item_id;
    x_line_id                      := l_x_trolin_rec.line_id;
    x_line_number                  := l_x_trolin_rec.line_number;
    x_line_status                  := l_x_trolin_rec.line_status;
    x_lot_number                   := l_x_trolin_rec.lot_number;
    x_organization_id              := l_x_trolin_rec.organization_id;
    x_project_id                   := l_x_trolin_rec.project_id;
    x_quantity                     := l_x_trolin_rec.quantity;
    x_quantity_delivered           := l_x_trolin_rec.quantity_delivered;
    x_quantity_detailed            := l_x_trolin_rec.quantity_detailed;
    x_reason_id                    := l_x_trolin_rec.reason_id;
    x_reference                    := l_x_trolin_rec.reference;
    x_reference_id                 := l_x_trolin_rec.reference_id;
    x_reference_type_code          := l_x_trolin_rec.reference_type_code;
    x_revision                     := l_x_trolin_rec.revision;
    x_serial_number_end            := l_x_trolin_rec.serial_number_end;
    x_serial_number_start          := l_x_trolin_rec.serial_number_start;
    x_status_date                  := l_x_trolin_rec.status_date;
    x_task_id                      := l_x_trolin_rec.task_id;
    x_to_account_id                := l_x_trolin_rec.to_account_id;
    x_to_locator_id                := l_x_trolin_rec.to_locator_id;
    x_to_subinventory_code         := l_x_trolin_rec.to_subinventory_code;
    x_to_subinventory_id           := l_x_trolin_rec.to_subinventory_id;
    x_transaction_header_id        := l_x_trolin_rec.transaction_header_id;
    x_uom_code                     := l_x_trolin_rec.uom_code;
/* ssia added for move order enhancement */
    x_transaction_type_id          := l_x_trolin_rec.transaction_type_id;
    x_transaction_source_type_id   := l_x_trolin_rec.transaction_source_type_id;
    x_txn_source_id                := l_x_trolin_rec.txn_source_id;
    x_txn_source_line_id           := l_x_trolin_rec.txn_source_line_id;
    x_txn_source_line_detail_id    := l_x_trolin_rec.txn_source_line_detail_id;
    x_primary_quantity             := l_x_trolin_rec.primary_quantity;
    x_to_organization_id           := l_x_trolin_rec.to_organization_id;
    x_pick_strategy_id             := l_x_trolin_rec.pick_strategy_id;
    x_put_away_strategy_id         := l_x_trolin_rec.put_away_strategy_id;
    x_unit_number                  := l_x_trolin_rec.unit_number;
    --INVCONV BEGIN
    x_secondary_quantity           := l_x_trolin_rec.secondary_quantity;
    x_secondary_quantity_delivered := l_x_trolin_rec.secondary_quantity_delivered;
    x_secondary_quantity_detailed  := l_x_trolin_rec.secondary_quantity_detailed;
    x_secondary_uom_code           := l_x_trolin_rec.secondary_uom;
    x_grade_code                   := l_x_trolin_rec.grade_code;
--INVCONV END

 --   x_ship_to_location_id          := l_x_trolin_rec.ship_to_location_id; -- NL MERGE
/* ssia end of move order enhancement changes */
    --  Load display out parameters if any

    l_trolin_val_rec := INV_Trolin_Util.Get_Values
    (   p_trolin_rec                  => l_x_trolin_rec
    );
    x_from_locator                 := l_trolin_val_rec.from_locator;
    x_inventory_item               := l_trolin_val_rec.inventory_item;
    x_project                      := l_trolin_val_rec.project;
    x_reason                       := l_trolin_val_rec.reason;
    x_reference_type               := l_trolin_val_rec.reference_type;
    x_task                         := l_trolin_val_rec.task;
    x_to_account                   := l_trolin_val_rec.to_account;
    x_to_locator                   := l_trolin_val_rec.to_locator;
    x_transaction_type		   := l_trolin_val_rec.transaction_type;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_trolin_rec.db_flag := FND_API.G_FALSE;

    Write_trolin
    (   p_trolin_rec                  => l_x_trolin_rec
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

--  Procedure   :   Validate_Record
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
,   p_from_locator_id               IN  NUMBER
,   p_from_subinventory_code        IN  VARCHAR2
,   p_from_subinventory_id          IN  NUMBER
,   p_header_id                     IN  NUMBER
,   p_inventory_item_id             IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_line_number                   IN  NUMBER
,   p_line_status                   IN  NUMBER
,   p_lot_number                    IN  VARCHAR2
,   p_organization_id               IN  NUMBER
,   p_project_id                    IN  NUMBER
,   p_quantity                      IN  NUMBER
,   p_quantity_delivered            IN  NUMBER
,   p_quantity_detailed             IN  NUMBER
,   p_reason_id                     IN  NUMBER
,   p_reference                     IN  VARCHAR2
,   p_reference_id                  IN  NUMBER
,   p_reference_type_code           IN  NUMBER
,   p_revision                      IN  VARCHAR2
,   p_serial_number_end             IN  VARCHAR2
,   p_serial_number_start           IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_task_id                       IN  NUMBER
,   p_to_account_id                 IN  NUMBER
,   p_to_locator_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_to_subinventory_id            IN  NUMBER
,   p_transaction_header_id         IN  NUMBER
,   p_uom_code                      IN  VARCHAR2
,   p_transaction_type_id           IN  NUMBER
,   p_transaction_source_type_id    IN  NUMBER
,   p_txn_source_id                 IN  NUMBER
,   p_txn_source_line_id            IN  NUMBER
,   p_txn_source_line_detail_id     IN  NUMBER
,   p_primary_quantity              IN  NUMBER
,   p_to_organization_id            IN  NUMBER
,   p_pick_strategy_id              IN  NUMBER
,   p_put_away_strategy_id          IN  NUMBER
,   p_unit_number                   IN  VARCHAR2
,   p_ship_to_location_id           IN  NUMBER
,   p_from_cost_group_id	    IN  NUMBER DEFAULT NULL
,   p_to_cost_Group_id		    IN  NUMBER DEFAULT NULL
,   p_lpn_id			    IN  NUMBER DEFAULT NULL
,   p_to_lpn_id		    IN  NUMBER DEFAULT NULL
,   p_db_flag                       IN  VARCHAR2
,   p_secondary_quantity            IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_quantity_delivered  IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_quantity_detailed   IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_uom_code            IN VARCHAR2 DEFAULT NULL --INVCONV change
,   p_grade_code                    IN VARCHAR2 DEFAULT NULL --INVCONV change
)
IS
l_trolin_rec                  INV_Move_Order_PUB.Trolin_Rec_Type;
l_old_trolin_rec              INV_Move_Order_PUB.Trolin_Rec_Type;
l_trolin_val_rec              INV_Move_Order_PUB.Trolin_Val_Rec_Type;
l_trolin_tbl                  INV_Move_Order_PUB.Trolin_Tbl_Type;
l_old_trolin_tbl              INV_Move_Order_PUB.Trolin_Tbl_Type;
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
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

    l_trolin_rec.db_flag               := p_db_flag;

    --  Read trolin from cache

    IF FND_API.To_Boolean(l_trolin_rec.db_flag) THEN

    l_trolin_rec := Get_trolin
    (   p_db_record                   => FALSE
    ,   p_line_id                     => p_line_id
    );
    End If;

    l_old_trolin_rec               := l_trolin_rec;

        l_trolin_rec.date_required      := p_date_required;
        l_trolin_rec.from_locator_id    := p_from_locator_id;
        l_trolin_rec.from_subinventory_code     := p_from_subinventory_code;
        l_trolin_rec.from_subinventory_id       := p_from_subinventory_id;
        l_trolin_rec.header_id                  := p_header_id;
        l_trolin_rec.inventory_item_id          := p_inventory_item_id;
        l_trolin_rec.line_id                    := p_line_id;
        l_trolin_rec.line_number                := p_line_number;
        l_trolin_rec.line_status                := p_line_status;
        l_trolin_rec.lot_number                 := p_lot_number;
        l_trolin_rec.organization_id            := p_organization_id;
        l_trolin_rec.project_id                 := p_project_id;
        l_trolin_rec.quantity                   := p_quantity;
        l_trolin_rec.quantity_delivered         := p_quantity_delivered;
        l_trolin_rec.quantity_detailed          := p_quantity_detailed;
        l_trolin_rec.reason_id                  := p_reason_id;
        l_trolin_rec.reference                  := p_reference;
        l_trolin_rec.reference_id               := p_reference_id;
        l_trolin_rec.reference_type_code        := p_reference_type_code;
        l_trolin_rec.revision                   := p_revision;
        l_trolin_rec.serial_number_end          := p_serial_number_end;
        l_trolin_rec.serial_number_start        := p_serial_number_start;
        l_trolin_rec.status_date                := p_status_date;
        l_trolin_rec.task_id                    := p_task_id;
        l_trolin_rec.to_account_id              := p_to_account_id;
        l_trolin_rec.to_locator_id              := p_to_locator_id;
        l_trolin_rec.to_subinventory_code       := p_to_subinventory_code;
        l_trolin_rec.to_subinventory_id         := p_to_subinventory_id;
        l_trolin_rec.transaction_header_id      := p_transaction_header_id;
        l_trolin_rec.uom_code                   := p_uom_code;
        l_trolin_rec.attribute1                 := p_attribute1;
        l_trolin_rec.attribute10                := p_attribute10;
        l_trolin_rec.attribute11                := p_attribute11;
        l_trolin_rec.attribute12                := p_attribute12;
        l_trolin_rec.attribute13                := p_attribute13;
        l_trolin_rec.attribute14                := p_attribute14;
        l_trolin_rec.attribute15                := p_attribute15;
        l_trolin_rec.attribute2                 := p_attribute2;
        l_trolin_rec.attribute3                 := p_attribute3;
        l_trolin_rec.attribute4                 := p_attribute4;
        l_trolin_rec.attribute5                 := p_attribute5;
        l_trolin_rec.attribute6                 := p_attribute6;
        l_trolin_rec.attribute7                 := p_attribute7;
        l_trolin_rec.attribute8                 := p_attribute8;
        l_trolin_rec.attribute9                 := p_attribute9;
        l_trolin_rec.attribute_category         := p_attribute_category;
/* ssia added for move order enhancement */
	l_trolin_rec.transaction_type_id 	:= p_transaction_type_id;
	l_trolin_rec.transaction_source_type_id := p_transaction_source_type_id;
	l_trolin_rec.txn_source_id		:= p_txn_source_id;
	l_trolin_rec.txn_source_line_id		:= p_txn_source_line_id;
	l_trolin_rec.txn_source_line_detail_id  := p_txn_source_line_detail_id;
	l_trolin_rec.primary_quantity		:= p_primary_quantity;
	l_trolin_rec.to_organization_id		:= p_to_organization_id;
	l_trolin_rec.pick_strategy_id		:= p_pick_strategy_id;
	l_trolin_rec.put_away_strategy_id	:= p_put_away_strategy_id;
	l_trolin_rec.unit_number		:= p_unit_number;
        l_trolin_rec.ship_to_location_id        := p_ship_to_location_id;
 	l_trolin_rec.from_cost_group_id		:= p_from_cost_group_id;
	l_trolin_rec.to_cost_group_id		:= p_to_cost_group_id;
	l_trolin_rec.lpn_id			:= p_lpn_id;
	l_trolin_rec.to_lpn_id		:= p_to_lpn_id;
/* ssia end of move order enhancement changes */

--INVCONV BEGIN
        l_trolin_rec.secondary_quantity                   := p_secondary_quantity;
        l_trolin_rec.secondary_quantity_delivered         := p_secondary_quantity_delivered;
        l_trolin_rec.secondary_quantity_detailed          := p_secondary_quantity_detailed;
        l_trolin_rec.secondary_uom                        := p_secondary_uom_code;
        l_trolin_rec.grade_code                           := p_grade_code;
--INVCONV END

    --  Set Operation.

    IF FND_API.To_Boolean(l_trolin_rec.db_flag) THEN
        l_trolin_rec.operation := INV_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_trolin_rec.operation := INV_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate trolin table

    l_trolin_tbl(1) := l_trolin_rec;
    l_old_trolin_tbl(1) := l_old_trolin_rec;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trolin_tbl                  => l_trolin_tbl
    ,   p_old_trolin_tbl              => l_old_trolin_tbl
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
/*    inv_debug.message('After Process Transfer Order'); */


    --  Unload out tbl

    l_x_trolin_rec := l_x_trolin_tbl(1);

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
    x_from_locator_id              := FND_API.G_MISS_NUM;
    x_from_subinventory_code       := FND_API.G_MISS_CHAR;
    x_from_subinventory_id         := FND_API.G_MISS_NUM;
    x_header_id                    := FND_API.G_MISS_NUM;
    x_inventory_item_id            := FND_API.G_MISS_NUM;
    x_line_id                      := FND_API.G_MISS_NUM;
    x_line_number                  := FND_API.G_MISS_NUM;
    x_line_status                  := FND_API.G_MISS_NUM;
    x_lot_number                   := FND_API.G_MISS_CHAR;
    x_organization_id              := FND_API.G_MISS_NUM;
    x_project_id                   := FND_API.G_MISS_NUM;
    x_quantity                     := FND_API.G_MISS_NUM;
    x_quantity_delivered           := FND_API.G_MISS_NUM;
    x_quantity_detailed            := FND_API.G_MISS_NUM;
    x_reason_id                    := FND_API.G_MISS_NUM;
    x_reference                    := FND_API.G_MISS_CHAR;
    x_reference_id                 := FND_API.G_MISS_NUM;
    x_reference_type_code          := FND_API.G_MISS_NUM;
    x_revision                     := FND_API.G_MISS_CHAR;
    x_serial_number_end            := FND_API.G_MISS_CHAR;
    x_serial_number_start          := FND_API.G_MISS_CHAR;
    x_status_date                  := FND_API.G_MISS_DATE;
    x_task_id                      := FND_API.G_MISS_NUM;
    x_to_account_id                := FND_API.G_MISS_NUM;
    x_to_locator_id                := FND_API.G_MISS_NUM;
    x_to_subinventory_code         := FND_API.G_MISS_CHAR;
    x_to_subinventory_id           := FND_API.G_MISS_NUM;
    x_transaction_header_id        := FND_API.G_MISS_NUM;
    x_uom_code                     := FND_API.G_MISS_CHAR;
    x_from_locator                 := FND_API.G_MISS_CHAR;
    x_inventory_item               := FND_API.G_MISS_CHAR;
    x_project                      := FND_API.G_MISS_CHAR;
    x_reason                       := FND_API.G_MISS_CHAR;
    x_reference_type               := FND_API.G_MISS_CHAR;
    x_task                         := FND_API.G_MISS_CHAR;
    x_to_account                   := FND_API.G_MISS_CHAR;
    x_to_locator                   := FND_API.G_MISS_CHAR;
    x_transaction_type_id	   := FND_API.G_MISS_NUM;
    x_transaction_source_type_id   := FND_API.G_MISS_NUM;
    x_txn_source_id		   := FND_API.G_MISS_NUM;
    x_txn_source_line_id	   := FND_API.G_MISS_NUM;
    x_txn_source_line_detail_id	   := FND_API.G_MISS_NUM;
    x_to_organization_id	   := FND_API.G_MISS_NUM;
    x_primary_quantity             := FND_API.G_MISS_NUM;
    x_pick_strategy_id		   := FND_API.G_MISS_NUM;
    x_put_away_strategy_id	   := FND_API.G_MISS_NUM;
    x_unit_number	   	   := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_trolin_val_rec := INV_Trolin_Util.Get_Values
    (   p_trolin_rec                  => l_x_trolin_rec
    ,   p_old_trolin_rec              => l_trolin_rec
    );

    --  Return changed attributes.

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute1,
                            l_trolin_rec.attribute1)
    THEN
        x_attribute1 := l_x_trolin_rec.attribute1;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute10,
                            l_trolin_rec.attribute10)
    THEN
        x_attribute10 := l_x_trolin_rec.attribute10;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute11,
                            l_trolin_rec.attribute11)
    THEN
        x_attribute11 := l_x_trolin_rec.attribute11;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute12,
                            l_trolin_rec.attribute12)
    THEN
        x_attribute12 := l_x_trolin_rec.attribute12;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute13,
                            l_trolin_rec.attribute13)
    THEN
        x_attribute13 := l_x_trolin_rec.attribute13;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute14,
                            l_trolin_rec.attribute14)
    THEN
        x_attribute14 := l_x_trolin_rec.attribute14;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute15,
                            l_trolin_rec.attribute15)
    THEN
        x_attribute15 := l_x_trolin_rec.attribute15;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute2,
                            l_trolin_rec.attribute2)
    THEN
        x_attribute2 := l_x_trolin_rec.attribute2;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute3,
                            l_trolin_rec.attribute3)
    THEN
        x_attribute3 := l_x_trolin_rec.attribute3;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute4,
                            l_trolin_rec.attribute4)
    THEN
        x_attribute4 := l_x_trolin_rec.attribute4;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute5,
                            l_trolin_rec.attribute5)
    THEN
        x_attribute5 := l_x_trolin_rec.attribute5;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute6,
                            l_trolin_rec.attribute6)
    THEN
        x_attribute6 := l_x_trolin_rec.attribute6;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute7,
                            l_trolin_rec.attribute7)
    THEN
        x_attribute7 := l_x_trolin_rec.attribute7;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute8,
                            l_trolin_rec.attribute8)
    THEN
        x_attribute8 := l_x_trolin_rec.attribute8;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute9,
                            l_trolin_rec.attribute9)
    THEN
        x_attribute9 := l_x_trolin_rec.attribute9;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.attribute_category,
                            l_trolin_rec.attribute_category)
    THEN
        x_attribute_category := l_x_trolin_rec.attribute_category;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.date_required,
                            l_trolin_rec.date_required)
    THEN
        x_date_required := l_x_trolin_rec.date_required;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.from_locator_id,
                            l_trolin_rec.from_locator_id)
    THEN
        x_from_locator_id := l_x_trolin_rec.from_locator_id;
        x_from_locator := l_trolin_val_rec.from_locator;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.from_subinventory_code,
                            l_trolin_rec.from_subinventory_code)
    THEN
        x_from_subinventory_code := l_x_trolin_rec.from_subinventory_code;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.from_subinventory_id,
                            l_trolin_rec.from_subinventory_id)
    THEN
        x_from_subinventory_id := l_x_trolin_rec.from_subinventory_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.header_id,
                            l_trolin_rec.header_id)
    THEN
        x_header_id := l_x_trolin_rec.header_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.inventory_item_id,
                            l_trolin_rec.inventory_item_id)
    THEN
        x_inventory_item_id := l_x_trolin_rec.inventory_item_id;
        x_inventory_item := l_trolin_val_rec.inventory_item;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.line_id,
                            l_trolin_rec.line_id)
    THEN
        x_line_id := l_x_trolin_rec.line_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.line_number,
                            l_trolin_rec.line_number)
    THEN
        x_line_number := l_x_trolin_rec.line_number;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.line_status,
                            l_trolin_rec.line_status)
    THEN
        x_line_status := l_x_trolin_rec.line_status;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.lot_number,
                            l_trolin_rec.lot_number)
    THEN
        x_lot_number := l_x_trolin_rec.lot_number;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.organization_id,
                            l_trolin_rec.organization_id)
    THEN
        x_organization_id := l_x_trolin_rec.organization_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.project_id,
                            l_trolin_rec.project_id)
    THEN
        x_project_id := l_x_trolin_rec.project_id;
        x_project := l_trolin_val_rec.project;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.quantity,
                            l_trolin_rec.quantity)
    THEN
        x_quantity := l_x_trolin_rec.quantity;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.quantity_delivered,
                            l_trolin_rec.quantity_delivered)
    THEN
        x_quantity_delivered := l_x_trolin_rec.quantity_delivered;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.quantity_detailed,
                            l_trolin_rec.quantity_detailed)
    THEN
        x_quantity_detailed := l_x_trolin_rec.quantity_detailed;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.reason_id,
                            l_trolin_rec.reason_id)
    THEN
        x_reason_id := l_x_trolin_rec.reason_id;
        x_reason := l_trolin_val_rec.reason;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.reference,
                            l_trolin_rec.reference)
    THEN
        x_reference := l_x_trolin_rec.reference;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.reference_id,
                            l_trolin_rec.reference_id)
    THEN
        x_reference_id := l_x_trolin_rec.reference_id;
        x_reference := l_trolin_val_rec.reference;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.reference_type_code,
                            l_trolin_rec.reference_type_code)
    THEN
        x_reference_type_code := l_x_trolin_rec.reference_type_code;
        x_reference_type := l_trolin_val_rec.reference_type;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.revision,
                            l_trolin_rec.revision)
    THEN
        x_revision := l_x_trolin_rec.revision;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.serial_number_end,
                            l_trolin_rec.serial_number_end)
    THEN
        x_serial_number_end := l_x_trolin_rec.serial_number_end;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.serial_number_start,
                            l_trolin_rec.serial_number_start)
    THEN
        x_serial_number_start := l_x_trolin_rec.serial_number_start;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.status_date,
                            l_trolin_rec.status_date)
    THEN
        x_status_date := l_x_trolin_rec.status_date;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.task_id,
                            l_trolin_rec.task_id)
    THEN
        x_task_id := l_x_trolin_rec.task_id;
        x_task := l_trolin_val_rec.task;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.to_account_id,
                            l_trolin_rec.to_account_id)
    THEN
        x_to_account_id := l_x_trolin_rec.to_account_id;
        x_to_account := l_trolin_val_rec.to_account;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.to_locator_id,
                            l_trolin_rec.to_locator_id)
    THEN
        x_to_locator_id := l_x_trolin_rec.to_locator_id;
        x_to_locator := l_trolin_val_rec.to_locator;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.to_subinventory_code,
                            l_trolin_rec.to_subinventory_code)
    THEN
        x_to_subinventory_code := l_x_trolin_rec.to_subinventory_code;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.to_subinventory_id,
                            l_trolin_rec.to_subinventory_id)
    THEN
        x_to_subinventory_id := l_x_trolin_rec.to_subinventory_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.transaction_header_id,
                            l_trolin_rec.transaction_header_id)
    THEN
        x_transaction_header_id := l_x_trolin_rec.transaction_header_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.uom_code,
                            l_trolin_rec.uom_code)
    THEN
        x_uom_code := l_x_trolin_rec.uom_code;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.transaction_type_id,
                            l_trolin_rec.transaction_type_id)
    THEN
        x_transaction_type_id := l_x_trolin_rec.transaction_type_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.transaction_Source_type_id,
                            l_trolin_rec.transaction_Source_type_id)
    THEN
        x_transaction_Source_type_id := l_x_trolin_rec.transaction_Source_type_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.txn_source_id,
                            l_trolin_rec.txn_source_id)
    THEN
        x_txn_source_id := l_x_trolin_rec.txn_source_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.txn_source_line_id,
                            l_trolin_rec.txn_source_line_id)
    THEN
        x_txn_source_line_id := l_x_trolin_rec.txn_source_line_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.txn_source_line_detail_id,
                            l_trolin_rec.txn_source_line_detail_id)
    THEN
        x_txn_source_line_detail_id := l_x_trolin_rec.txn_source_line_detail_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.primary_quantity,
                            l_trolin_rec.primary_quantity)
    THEN
        x_primary_quantity := l_x_trolin_rec.primary_quantity;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.to_organization_id,
                            l_trolin_rec.to_organization_id)
    THEN
        x_to_organization_id := l_x_trolin_rec.to_organization_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.pick_strategy_id,
                            l_trolin_rec.pick_strategy_id)
    THEN
        x_pick_strategy_id := l_x_trolin_rec.pick_strategy_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.put_away_strategy_id,
                            l_trolin_rec.put_away_strategy_id)
    THEN
        x_put_away_strategy_id := l_x_trolin_rec.put_away_strategy_id;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.unit_number,
                            l_trolin_rec.unit_number)
    THEN
        x_unit_number := l_x_trolin_rec.unit_number;
    END IF;

    IF NOT INV_GLOBALS.Equal(l_x_trolin_rec.ship_to_location_id,
                             l_trolin_rec.ship_to_location_id)
    THEN
        x_ship_to_location_id := l_x_trolin_rec.ship_to_location_id;
    END IF;

*/


    --  Write to cache.

/*    inv_debug.message('Bef Write_trolin'); */
    Write_trolin
    (   p_trolin_rec                  => l_x_trolin_rec
    );

/*    inv_debug.message('AFt Write_trolin'); */
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
,   p_from_locator_id               IN  NUMBER
,   p_from_subinventory_code        IN  VARCHAR2
,   p_from_subinventory_id          IN  NUMBER
,   p_header_id                     IN  NUMBER
,   p_inventory_item_id             IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_line_number                   IN  NUMBER
,   p_line_status                   IN  NUMBER
,   p_lot_number                    IN  VARCHAR2
,   p_organization_id               IN  NUMBER
,   p_project_id                    IN  NUMBER
,   p_quantity                      IN  NUMBER
,   p_quantity_delivered            IN  NUMBER
,   p_quantity_detailed             IN  NUMBER
,   p_reason_id                     IN  NUMBER
,   p_reference                     IN  VARCHAR2
,   p_reference_id                  IN  NUMBER
,   p_reference_type_code           IN  NUMBER
,   p_revision                      IN  VARCHAR2
,   p_serial_number_end             IN  VARCHAR2
,   p_serial_number_start           IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_task_id                       IN  NUMBER
,   p_to_account_id                 IN  NUMBER
,   p_to_locator_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_to_subinventory_id            IN  NUMBER
,   p_transaction_header_id         IN  NUMBER
,   p_uom_code                      IN  VARCHAR2
,   p_transaction_type_id           IN  NUMBER
,   p_transaction_source_type_id    IN  NUMBER
,   p_txn_source_id                 IN  NUMBER
,   p_txn_source_line_id            IN  NUMBER
,   p_txn_source_line_detail_id     IN  NUMBER
,   p_primary_quantity              IN  NUMBER
,   p_to_organization_id            IN  NUMBER
,   p_pick_strategy_id              IN  NUMBER
,   p_put_away_strategy_id          IN  NUMBER
,   p_unit_number          	    IN  VARCHAR2
,   p_ship_to_location_id           IN  NUMBER
,   p_from_cost_group_id	    IN  NUMBER DEFAULT NULL
,   p_to_cost_group_id		    IN  NUMBER DEFAULT NULL
,   p_lpn_id			    IN  NUMBER DEFAULT NULL
,   p_to_lpn_id		    IN  NUMBER DEFAULT NULL
,   p_db_flag                       IN  VARCHAR2
,   p_secondary_quantity            IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_quantity_delivered  IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_quantity_detailed   IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_uom_code            IN VARCHAR2 DEFAULT NULL --INVCONV change
,   p_grade_code                    IN VARCHAR2 DEFAULT NULL --INVCONV change
,   x_creation_date                 OUT NOCOPY DATE
,   x_created_by                    OUT NOCOPY NUMBER
,   x_last_update_date              OUT NOCOPY DATE
,   x_last_updated_by               OUT NOCOPY NUMBER
,   x_last_update_login             OUT NOCOPY NUMBER
)
IS
l_trolin_rec                  INV_Move_Order_PUB.Trolin_Rec_Type;
l_g_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_old_trolin_rec              INV_Move_Order_PUB.Trolin_Rec_Type;
l_trolin_tbl                  INV_Move_Order_PUB.Trolin_Tbl_Type;
l_old_trolin_tbl              INV_Move_Order_PUB.Trolin_Tbl_Type;
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
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

    g_trolin_rec.date_required  := p_date_required;
    g_trolin_rec.from_locator_id        := p_from_locator_id;
    g_trolin_rec.from_subinventory_code:= p_from_subinventory_code;
    g_trolin_rec.from_subinventory_id := p_from_subinventory_id;
    g_trolin_rec.header_id              := p_header_id;
    g_trolin_rec.inventory_item_id      := p_inventory_item_id;
    g_trolin_rec.line_id                := p_line_id;
    g_trolin_rec.line_number            := p_line_number;
    g_trolin_rec.line_status            := p_line_status;
    g_trolin_rec.lot_number             := p_lot_number;
    g_trolin_rec.organization_id        := p_organization_id;
    g_trolin_rec.project_id             := p_project_id;
    g_trolin_rec.quantity               := p_quantity;
    g_trolin_rec.quantity_delivered     := p_quantity_delivered;
    g_trolin_rec.quantity_detailed      := p_quantity_detailed;
    g_trolin_rec.reason_id              := p_reason_id;
    g_trolin_rec.reference              := p_reference;
    g_trolin_rec.reference_id   := p_reference_id;
    g_trolin_rec.reference_type_code    := p_reference_type_code;
    g_trolin_rec.revision               := p_revision;
    g_trolin_rec.serial_number_end      := p_serial_number_end;
    g_trolin_rec.serial_number_start    := p_serial_number_start;
    g_trolin_rec.status_date            := p_status_date;
    g_trolin_rec.task_id                := p_task_id;
    g_trolin_rec.to_account_id  := p_to_account_id;
    g_trolin_rec.to_locator_id  := p_to_locator_id;
    g_trolin_rec.to_subinventory_code := p_to_subinventory_code;
    g_trolin_rec.to_subinventory_id     := p_to_subinventory_id;
    g_trolin_rec.transaction_header_id:= p_transaction_header_id;
    g_trolin_rec.uom_code               := p_uom_code;
    g_trolin_rec.attribute1             := p_attribute1;
    g_trolin_rec.attribute10            := p_attribute10;
    g_trolin_rec.attribute11            := p_attribute11;
    g_trolin_rec.attribute12            := p_attribute12;
    g_trolin_rec.attribute13            := p_attribute13;
    g_trolin_rec.attribute14            := p_attribute14;
    g_trolin_rec.attribute15            := p_attribute15;
    g_trolin_rec.attribute2             := p_attribute2;
    g_trolin_rec.attribute3             := p_attribute3;
    g_trolin_rec.attribute4             := p_attribute4;
    g_trolin_rec.attribute5             := p_attribute5;
    g_trolin_rec.attribute6             := p_attribute6;
    g_trolin_rec.attribute7             := p_attribute7;
    g_trolin_rec.attribute8             := p_attribute8;
    g_trolin_rec.attribute9             := p_attribute9;
    g_trolin_rec.attribute_category     := p_attribute_category;
/* ssia added for move order enhancement changes */
    g_trolin_rec.transaction_type_id	:= p_transaction_type_id;
    g_trolin_rec.transaction_source_type_id	:= p_transaction_source_type_id;
    g_trolin_rec.txn_source_id	:= p_txn_source_id;
    g_trolin_rec.txn_source_line_id	:= p_txn_source_line_id;
    g_trolin_rec.txn_source_line_detail_id	:= p_txn_source_line_detail_id;
    g_trolin_rec.primary_quantity	:= p_primary_quantity;
    g_trolin_rec.to_organization_id	:= p_to_organization_id;
    g_trolin_rec.pick_strategy_id	:= p_pick_strategy_id;
    g_trolin_rec.put_away_strategy_id	:= p_put_away_strategy_id;
    g_trolin_rec.unit_number		:= p_unit_number;
    g_trolin_rec.ship_to_location_id    := p_ship_to_location_id;
    g_trolin_Rec.from_cost_Group_id     := p_from_cost_Group_id;
    g_trolin_rec.to_cost_group_id       := p_to_cost_group_id;
    g_trolin_rec.lpn_id                 := p_lpn_id;
    g_trolin_rec.to_lpn_id        := p_to_lpn_id;
    g_trolin_rec.db_flag                := p_db_flag;

/* ssia end of move order enhancement changes */
--INVCONV BEGIN
    g_trolin_rec.secondary_quantity               := p_secondary_quantity;
    g_trolin_rec.secondary_quantity_delivered     := p_secondary_quantity_delivered;
    g_trolin_rec.secondary_quantity_detailed      := p_secondary_quantity_detailed;
    g_trolin_rec.secondary_uom                    := p_secondary_uom_code;
    g_trolin_rec.grade_code                       := p_grade_code;
--INVCONV END

    --  Read trolin from cache

    l_old_trolin_rec := Get_trolin
    (   p_db_record                   => TRUE
    ,   p_line_id                     => p_line_id
    );

    l_trolin_rec := Get_trolin
    (   p_db_record                   => FALSE
    ,   p_line_id                     => p_line_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_trolin_rec.db_flag) THEN
        l_trolin_rec.operation := INV_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_trolin_rec.operation := INV_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate trolin table

    l_trolin_tbl(1) := l_trolin_rec;
    l_old_trolin_tbl(1) := l_old_trolin_rec;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trolin_tbl                  => l_trolin_tbl
    ,   p_old_trolin_tbl              => l_old_trolin_tbl
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_trolin_rec := l_x_trolin_tbl(1);

    x_creation_date                := l_x_trolin_rec.creation_date;
    x_created_by                   := l_x_trolin_rec.created_by;
    x_last_update_date             := l_x_trolin_rec.last_update_date;
    x_last_updated_by              := l_x_trolin_rec.last_updated_by;
    x_last_update_login            := l_x_trolin_rec.last_update_login;

    --  Clear trolin record cache

    Clear_trolin;

    --  Keep track of performed operations.

    l_old_trolin_rec.operation := l_trolin_rec.operation;


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
,   p_line_id                       IN  NUMBER
)
IS
l_trolin_rec                  INV_Move_Order_PUB.Trolin_Rec_Type;
l_trolin_tbl                  INV_Move_Order_PUB.Trolin_Tbl_Type;
l_control_rec                 INV_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
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

    l_trolin_rec := Get_trolin
    (   p_db_record                   => TRUE
    ,   p_line_id                     => p_line_id
    );

    --  Set Operation.

    l_trolin_rec.operation := INV_GLOBALS.G_OPR_DELETE;

    --  Populate trolin table

    l_trolin_tbl(1) := l_trolin_rec;

    --  Call INV_Transfer_Order_PVT.Process_Transfer_Order

    INV_Transfer_Order_PVT.Process_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_trolin_tbl                  => l_trolin_tbl
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear trolin record cache

    Clear_trolin;

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
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := INV_GLOBALS.G_ENTITY_TROLIN;

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
,   p_from_locator_id               IN  NUMBER
,   p_from_subinventory_code        IN  VARCHAR2
,   p_from_subinventory_id          IN  NUMBER
,   p_header_id                     IN  NUMBER
,   p_inventory_item_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_line_number                   IN  NUMBER
,   p_line_status                   IN  NUMBER
,   p_lot_number                    IN  VARCHAR2
,   p_organization_id               IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_project_id                    IN  NUMBER
,   p_quantity                      IN  NUMBER
,   p_quantity_delivered            IN  NUMBER
,   p_quantity_detailed             IN  NUMBER
,   p_reason_id                     IN  NUMBER
,   p_reference                     IN  VARCHAR2
,   p_reference_id                  IN  NUMBER
,   p_reference_type_code           IN  NUMBER
,   p_request_id                    IN  NUMBER
,   p_revision                      IN  VARCHAR2
,   p_serial_number_end             IN  VARCHAR2
,   p_serial_number_start           IN  VARCHAR2
,   p_status_date                   IN  DATE
,   p_task_id                       IN  NUMBER
,   p_to_account_id                 IN  NUMBER
,   p_to_locator_id                 IN  NUMBER
,   p_to_subinventory_code          IN  VARCHAR2
,   p_to_subinventory_id            IN  NUMBER
,   p_transaction_header_id         IN  NUMBER
,   p_transaction_type_id           IN  NUMBER
,   p_transaction_source_type_id    IN  NUMBER
,   p_txn_source_id                 IN  NUMBER
,   p_txn_source_line_id            IN  NUMBER
,   p_txn_source_line_detail_id     IN  NUMBER
,   p_primary_quantity              IN  NUMBER
,   p_to_organization_id            IN  NUMBER
,   p_pick_strategy_id              IN  NUMBER
,   p_put_away_strategy_id          IN  NUMBER
,   p_unit_number          	    IN  VARCHAR2
,   p_uom_code                      IN  VARCHAR2
,   p_ship_to_location_id           IN  NUMBER
,   p_from_cost_group_id	    IN  NUMBER DEFAULT NULL
,   p_to_cost_group_id		    IN  NUMBER DEFAULT NULL
,   p_lpn_id			    IN  NUMBER DEFAULT NULL
,   p_to_lpn_id               IN  NUMBER DEFAULT NULL
,   p_secondary_quantity            IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_quantity_delivered  IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_quantity_detailed   IN NUMBER DEFAULT NULL   --INVCONV change
,   p_secondary_uom_code            IN VARCHAR2 DEFAULT NULL --INVCONV change
,   p_grade_code                    IN VARCHAR2 DEFAULT NULL --INVCONV change
)
IS
l_return_status               VARCHAR2(1);
l_trolin_rec                  INV_Move_Order_PUB.Trolin_Rec_Type;
l_trolin_tbl                  INV_Move_Order_PUB.Trolin_Tbl_Type;
l_x_trohdr_rec                INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_rec                INV_Move_Order_PUB.Trolin_Rec_Type;
l_x_trolin_tbl                INV_Move_Order_PUB.Trolin_Tbl_Type;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    --  Load trolin record

    l_trolin_rec.attribute1        := p_attribute1;
    l_trolin_rec.attribute10       := p_attribute10;
    l_trolin_rec.attribute11       := p_attribute11;
    l_trolin_rec.attribute12       := p_attribute12;
    l_trolin_rec.attribute13       := p_attribute13;
    l_trolin_rec.attribute14       := p_attribute14;
    l_trolin_rec.attribute15       := p_attribute15;
    l_trolin_rec.attribute2        := p_attribute2;
    l_trolin_rec.attribute3        := p_attribute3;
    l_trolin_rec.attribute4        := p_attribute4;
    l_trolin_rec.attribute5        := p_attribute5;
    l_trolin_rec.attribute6        := p_attribute6;
    l_trolin_rec.attribute7        := p_attribute7;
    l_trolin_rec.attribute8        := p_attribute8;
    l_trolin_rec.attribute9        := p_attribute9;
    l_trolin_rec.attribute_category := p_attribute_category;
    l_trolin_rec.created_by        := p_created_by;
    l_trolin_rec.creation_date     := p_creation_date;
    l_trolin_rec.date_required     := p_date_required;
    l_trolin_rec.from_locator_id   := p_from_locator_id;
    l_trolin_rec.from_subinventory_code := p_from_subinventory_code;
    l_trolin_rec.from_subinventory_id := p_from_subinventory_id;
    l_trolin_rec.header_id         := p_header_id;
    l_trolin_rec.inventory_item_id := p_inventory_item_id;
    l_trolin_rec.last_updated_by   := p_last_updated_by;
    l_trolin_rec.last_update_date  := p_last_update_date;
    l_trolin_rec.last_update_login := p_last_update_login;
    l_trolin_rec.line_id           := p_line_id;
    l_trolin_rec.line_number       := p_line_number;
    l_trolin_rec.line_status       := p_line_status;
    l_trolin_rec.lot_number        := p_lot_number;
    l_trolin_rec.organization_id   := p_organization_id;
    l_trolin_rec.program_application_id := p_program_application_id;
    l_trolin_rec.program_id        := p_program_id;
    l_trolin_rec.program_update_date := p_program_update_date;
    l_trolin_rec.project_id        := p_project_id;
    l_trolin_rec.quantity          := p_quantity;
    l_trolin_rec.quantity_delivered := p_quantity_delivered;
    l_trolin_rec.quantity_detailed := p_quantity_detailed;
    l_trolin_rec.reason_id         := p_reason_id;
    l_trolin_rec.reference         := p_reference;
    l_trolin_rec.reference_id      := p_reference_id;
    l_trolin_rec.reference_type_code := p_reference_type_code;
    l_trolin_rec.request_id        := p_request_id;
    l_trolin_rec.revision          := p_revision;
    l_trolin_rec.serial_number_end := p_serial_number_end;
    l_trolin_rec.serial_number_start := p_serial_number_start;
    l_trolin_rec.status_date       := p_status_date;
    l_trolin_rec.task_id           := p_task_id;
    l_trolin_rec.to_account_id     := p_to_account_id;
    l_trolin_rec.to_locator_id     := p_to_locator_id;
    l_trolin_rec.to_subinventory_code := p_to_subinventory_code;
    l_trolin_rec.to_subinventory_id := p_to_subinventory_id;
    l_trolin_rec.transaction_header_id := p_transaction_header_id;
/* ssia added for move order enhancement */
    l_trolin_rec.transaction_type_id          := p_transaction_type_id;
    l_trolin_rec.transaction_source_type_id          := p_transaction_source_type_id;
    l_trolin_rec.txn_source_id          := p_txn_source_id;
    l_trolin_rec.txn_source_line_id          := p_txn_source_line_id;
    l_trolin_rec.txn_source_line_detail_id          := p_txn_source_line_detail_id;
    l_trolin_rec.primary_quantity          := p_primary_quantity;
    l_trolin_rec.to_organization_id          := p_to_organization_id;
    l_trolin_rec.pick_strategy_id          := p_pick_strategy_id;
    l_trolin_rec.put_away_strategy_id          := p_put_away_strategy_id;
    l_trolin_rec.unit_number          := p_unit_number;
    l_trolin_rec.uom_code          := p_uom_code;
    l_trolin_rec.ship_to_location_id := p_ship_to_location_id;
    l_trolin_Rec.from_cost_group_id := p_from_cost_group_id;
    l_trolin_rec.to_cost_group_id := p_to_cost_group_id;
    l_trolin_rec.lpn_id := p_lpn_id;
    l_trolin_rec.to_lpn_id := p_to_lpn_id;

/* ssia end of move order enhancement changes */

--INVCONV BEGIN
    l_trolin_rec.secondary_quantity          := p_secondary_quantity;
    l_trolin_rec.secondary_quantity_delivered := p_secondary_quantity_delivered;
    l_trolin_rec.secondary_quantity_detailed := p_secondary_quantity_detailed;
    l_trolin_rec.secondary_uom               := p_secondary_uom_code;
    l_trolin_rec.grade_code                  := p_grade_code;
--INVCONV END

    --  Populate trolin table

    l_trolin_tbl(1) := l_trolin_rec;

    --  Call INV_Transfer_Order_PVT.Lock_Transfer_Order

    INV_Transfer_Order_PVT.Lock_Transfer_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_trolin_tbl                  => l_trolin_tbl
    ,   x_trohdr_rec                  => l_x_trohdr_rec
    ,   x_trolin_tbl                  => l_x_trolin_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_trolin_rec.db_flag := FND_API.G_TRUE;

        Write_trolin
        (   p_trolin_rec                  => l_x_trolin_rec
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

--  Procedures maintaining trolin record cache.

PROCEDURE Write_trolin
(   p_trolin_rec                    IN  INV_Move_Order_PUB.Trolin_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    g_trolin_rec := p_trolin_rec;

    IF p_db_record THEN

        g_db_trolin_rec := p_trolin_rec;

    END IF;

END Write_Trolin;

FUNCTION Get_trolin
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_line_id                       IN  NUMBER
)
RETURN INV_Move_Order_PUB.Trolin_Rec_Type
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF  p_line_id <> g_trolin_rec.line_id
    THEN

        --  Query row from DB

        g_trolin_rec := INV_Trolin_Util.Query_Row
        (   p_line_id                     => p_line_id
        );

        g_trolin_rec.db_flag           := FND_API.G_TRUE;

        --  Load DB record

        g_db_trolin_rec                := g_trolin_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_trolin_rec;

    ELSE

        RETURN g_trolin_rec;

    END IF;

END Get_Trolin;

PROCEDURE Clear_Trolin
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    g_trolin_rec                   := INV_Move_Order_PUB.G_MISS_TROLIN_REC;
    g_db_trolin_rec                := INV_Move_Order_PUB.G_MISS_TROLIN_REC;

END Clear_Trolin;

END INV_TO_Form_Trolin;

/
