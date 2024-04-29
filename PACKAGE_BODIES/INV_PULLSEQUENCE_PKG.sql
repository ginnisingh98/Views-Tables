--------------------------------------------------------
--  DDL for Package Body INV_PULLSEQUENCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PULLSEQUENCE_PKG" as
/* $Header: INVKPSQB.pls 120.0 2005/05/25 07:00:22 appldev noship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_PullSequence_PKG';


FUNCTION  Check_Unique( p_Pull_Sequence_Id IN OUT NOCOPY  NUMBER,
                        p_Organization_Id          NUMBER,
                        p_Kanban_Plan_Id           NUMBER,
                        p_Inventory_item_id        NUMBER,
                        p_Subinventory_Name        VARCHAR2,
                        p_Locator_Id               NUMBER)
RETURN BOOLEAN IS
    l_Dummy Varchar2(1);
BEGIN
    Select 'x'
    Into l_Dummy
    From MTL_KANBAN_PULL_SEQUENCES
    Where organization_id = p_Organization_Id
    And   kanban_plan_id = p_kanban_plan_id
    And   inventory_item_id = p_inventory_item_id
    And   subinventory_name = p_Subinventory_Name
    And   nvl(locator_id,-1)= nvl(p_locator_id,-1)
    And ((p_Pull_Sequence_Id is NULL ) Or
         (Pull_Sequence_Id <> p_Pull_Sequence_Id));
	Raise too_Many_Rows;

Exception
When No_Data_found
Then
	return True;
When Too_Many_Rows
Then
       FND_MESSAGE.SET_NAME('INV', 'INV_PULLSEQ_EXISTS');
       Return FALSE;
When Others
Then
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Unique'
            );
        END IF;
       Return FALSE;

END Check_Unique;

Procedure commit_row is
BEGIN
   commit;
end commit_row;

Procedure rollback_row is
BEGIN
  rollback;
end rollback_row;

FUNCTION Query_Row
(   p_pull_sequence_id              IN  NUMBER
) RETURN INV_Kanban_PVT.Pull_Sequence_Rec_Type
IS
l_pull_sequence_rec           INV_Kanban_PVT.Pull_Sequence_Rec_Type;
BEGIN

    SELECT  PULL_SEQUENCE_ID
    ,       INVENTORY_ITEM_ID
    ,       ORGANIZATION_ID
    ,       SUBINVENTORY_NAME
    ,       KANBAN_PLAN_ID
    ,       SOURCE_TYPE
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LOCATOR_ID
    ,       SUPPLIER_ID
    ,       SUPPLIER_SITE_ID
    ,       SOURCE_ORGANIZATION_ID
    ,       SOURCE_SUBINVENTORY
    ,       SOURCE_LOCATOR_ID
    ,       WIP_LINE_ID
    ,       REPLENISHMENT_LEAD_TIME
    ,       RELEASE_KANBAN_FLAG
    ,       CALCULATE_KANBAN_FLAG
    ,       KANBAN_SIZE
    ,       FIXED_LOT_MULTIPLIER
    ,       SAFETY_STOCK_DAYS
    ,       NUMBER_OF_CARDS
    ,       MINIMUM_ORDER_QUANTITY
    ,       AGGREGATION_TYPE
    ,       ALLOCATION_PERCENT
    ,       LAST_UPDATE_LOGIN
    ,       UPDATED_FLAG
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       REQUEST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,	    POINT_OF_USE_X
    ,	    POINT_OF_USE_Y
    ,	    POINT_OF_SUPPLY_X
    ,       POINT_OF_SUPPLY_Y
    ,	    PLANNING_UPDATE_STATUS
    ,       AUTO_REQUEST
    ,       AUTO_ALLOCATE_FLAG  --Added for 3905884
    INTO    l_pull_sequence_rec.pull_sequence_id
    ,       l_pull_sequence_rec.inventory_item_id
    ,       l_pull_sequence_rec.organization_id
    ,       l_pull_sequence_rec.subinventory_name
    ,       l_pull_sequence_rec.Kanban_plan_id
    ,       l_pull_sequence_rec.source_type
    ,       l_pull_sequence_rec.last_update_date
    ,       l_pull_sequence_rec.last_updated_by
    ,       l_pull_sequence_rec.creation_date
    ,       l_pull_sequence_rec.created_by
    ,       l_pull_sequence_rec.locator_id
    ,       l_pull_sequence_rec.supplier_id
    ,       l_pull_sequence_rec.supplier_site_id
    ,       l_pull_sequence_rec.source_organization_id
    ,       l_pull_sequence_rec.source_subinventory
    ,       l_pull_sequence_rec.source_locator_id
    ,       l_pull_sequence_rec.Wip_line_id
    ,       l_pull_sequence_rec.replenishment_lead_time
    ,       l_pull_sequence_rec.Release_Kanban_Flag
    ,       l_pull_sequence_rec.Calculate_Kanban_Flag
    ,       l_pull_sequence_rec.kanban_size
    ,       l_pull_sequence_rec.fixed_lot_multiplier
    ,       l_pull_sequence_rec.safety_stock_days
    ,       l_pull_sequence_rec.number_of_cards
    ,       l_pull_sequence_rec.minimum_order_quantity
    ,       l_pull_sequence_rec.aggregation_Type
    ,       l_pull_sequence_rec.Allocation_Percent
    ,       l_pull_sequence_rec.last_update_login
    ,       l_pull_sequence_rec.updated_flag
    ,       l_pull_sequence_rec.attribute_category
    ,       l_pull_sequence_rec.attribute1
    ,       l_pull_sequence_rec.attribute2
    ,       l_pull_sequence_rec.attribute3
    ,       l_pull_sequence_rec.attribute4
    ,       l_pull_sequence_rec.attribute5
    ,       l_pull_sequence_rec.attribute6
    ,       l_pull_sequence_rec.attribute7
    ,       l_pull_sequence_rec.attribute8
    ,       l_pull_sequence_rec.attribute9
    ,       l_pull_sequence_rec.attribute10
    ,       l_pull_sequence_rec.attribute11
    ,       l_pull_sequence_rec.attribute12
    ,       l_pull_sequence_rec.attribute13
    ,       l_pull_sequence_rec.attribute14
    ,       l_pull_sequence_rec.attribute15
    ,       l_pull_sequence_rec.request_id
    ,       l_pull_sequence_rec.program_application_id
    ,       l_pull_sequence_rec.program_id
    ,       l_pull_sequence_rec.program_update_date
    ,	    l_pull_sequence_rec.point_of_use_x
    ,	    l_pull_sequence_rec.point_of_use_y
    ,	    l_pull_sequence_rec.point_of_supply_x
    ,       l_pull_sequence_rec.point_of_supply_y
    ,       l_pull_sequence_rec.planning_update_status
    ,       l_pull_sequence_rec.auto_request
    ,       l_pull_sequence_rec.auto_allocate_flag  --Added for3905884
    FROM    MTL_KANBAN_PULL_SEQUENCES
    WHERE   PULL_SEQUENCE_ID = p_pull_sequence_id
    ;

    RETURN l_pull_sequence_rec;

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

FUNCTION Convert_Miss_To_Null
(   p_pull_sequence_rec             IN  INV_Kanban_PVT.Pull_Sequence_Rec_Type
) RETURN INV_Kanban_PVT.Pull_Sequence_Rec_Type
IS
l_pull_sequence_rec INV_Kanban_PVT.Pull_Sequence_Rec_Type := p_pull_sequence_rec;
BEGIN

    IF l_pull_sequence_rec.pull_sequence_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.pull_sequence_id := NULL;
    END IF;

    IF l_pull_sequence_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.inventory_item_id := NULL;
    END IF;

    IF l_pull_sequence_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.organization_id := NULL;
    END IF;

    IF l_pull_sequence_rec.subinventory_name = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.subinventory_name := NULL;
    END IF;

    IF l_pull_sequence_rec.kanban_plan_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.kanban_plan_id := NULL;
    END IF;

    IF l_pull_sequence_rec.source_type = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.source_type := NULL;
    END IF;

    IF l_pull_sequence_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_pull_sequence_rec.last_update_date := NULL;
    END IF;

    IF l_pull_sequence_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.last_updated_by := NULL;
    END IF;

    IF l_pull_sequence_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_pull_sequence_rec.creation_date := NULL;
    END IF;

    IF l_pull_sequence_rec.created_by = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.created_by := NULL;
    END IF;

    IF l_pull_sequence_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.last_update_login := NULL;
    END IF;

    IF l_pull_sequence_rec.locator_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.locator_id := NULL;
    END IF;

    IF l_pull_sequence_rec.supplier_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.supplier_id := NULL;
    END IF;

    IF l_pull_sequence_rec.source_organization_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.source_organization_id := NULL;
    END IF;

    IF l_pull_sequence_rec.source_subinventory = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.source_subinventory := NULL;
    END IF;

    IF l_pull_sequence_rec.source_locator_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.source_locator_id := NULL;
    END IF;

    IF l_pull_sequence_rec.wip_line_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.wip_line_id := NULL;
    END IF;

    IF l_pull_sequence_rec.release_kanban_flag = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.release_kanban_flag := NULL;
    END IF;

    IF l_pull_sequence_rec.calculate_kanban_flag = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.calculate_kanban_flag := NULL;
    END IF;

    IF l_pull_sequence_rec.kanban_size = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.kanban_size := NULL;
    END IF;

    IF l_pull_sequence_rec.replenishment_lead_time = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.replenishment_lead_time := NULL;
    END IF;

    IF l_pull_sequence_rec.fixed_lot_multiplier = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.fixed_lot_multiplier := NULL;
    END IF;

    IF l_pull_sequence_rec.safety_stock_days = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.safety_stock_days := NULL;
    END IF;

    IF l_pull_sequence_rec.number_of_cards = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.number_of_cards := NULL;
    END IF;

    IF l_pull_sequence_rec.minimum_order_quantity = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.minimum_order_quantity := NULL;
    END IF;

    IF l_pull_sequence_rec.aggregation_type = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.aggregation_type := NULL;
    END IF;

    IF l_pull_sequence_rec.allocation_percent = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.allocation_percent := NULL;
    END IF;

    IF l_pull_sequence_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.last_update_login := NULL;
    END IF;

    IF l_pull_sequence_rec.updated_flag = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.updated_flag := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute_category := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute1 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute2 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute3 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute4 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute5 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute6 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute7 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute8 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute9 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute10 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute11 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute12 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute13 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute14 := NULL;
    END IF;

    IF l_pull_sequence_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute15 := NULL;
    END IF;

    IF l_pull_sequence_rec.request_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.request_id := NULL;
    END IF;

    IF l_pull_sequence_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.program_application_id := NULL;
    END IF;

    IF l_pull_sequence_rec.program_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.program_id := NULL;
    END IF;

    IF l_pull_sequence_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_pull_sequence_rec.program_update_date := NULL;
    END IF;

    IF l_pull_sequence_rec.point_of_use_x= FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.point_of_use_x := NULL;
    END IF;

    IF l_pull_sequence_rec.point_of_use_y = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.point_of_use_y := NULL;
    END IF;

    IF l_pull_sequence_rec.point_of_supply_x = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.point_of_supply_x := NULL;
    END IF;

    IF l_pull_sequence_rec.point_of_supply_y = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.point_of_supply_y := NULL;
    END IF;

    IF l_pull_sequence_rec.planning_update_status = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.planning_update_status := NULL;
    END IF;

    IF l_pull_sequence_rec.auto_request = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.auto_request := NULL;
    END IF;

    /*Added the following IF statement for 3905884.*/
    IF l_pull_sequence_rec.auto_allocate_flag = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.auto_allocate_flag := NULL;
    END IF;

    RETURN l_pull_sequence_rec;

END Convert_Miss_To_Null;

FUNCTION Complete_Record
(   p_pull_sequence_rec             IN  INV_Kanban_PVT.Pull_Sequence_Rec_Type
,   p_old_pull_sequence_rec         IN  INV_Kanban_PVT.Pull_Sequence_Rec_Type
) RETURN INV_Kanban_PVT.Pull_Sequence_Rec_Type
IS
l_pull_sequence_rec INV_Kanban_PVT.Pull_Sequence_Rec_Type := p_pull_sequence_rec;
BEGIN

    IF l_pull_sequence_rec.pull_sequence_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.pull_sequence_id := p_old_pull_sequence_rec.pull_sequence_id;
    END IF;

    IF l_pull_sequence_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.inventory_item_id := p_old_pull_sequence_rec.inventory_item_id;
    END IF;

    IF l_pull_sequence_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.organization_id := p_old_pull_sequence_rec.organization_id;
    END IF;

    IF l_pull_sequence_rec.subinventory_name = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.subinventory_name := p_old_pull_sequence_rec.subinventory_name;
    END IF;

    IF l_pull_sequence_rec.Kanban_plan_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.Kanban_plan_id := p_old_pull_sequence_rec.Kanban_plan_id;
    END IF;

    IF l_pull_sequence_rec.source_type = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.source_type := p_old_pull_sequence_rec.source_type;
    END IF;

    IF l_pull_sequence_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_pull_sequence_rec.last_update_date := p_old_pull_sequence_rec.last_update_date;
    END IF;

    IF l_pull_sequence_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.last_updated_by := p_old_pull_sequence_rec.last_updated_by;
    END IF;

    IF l_pull_sequence_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_pull_sequence_rec.creation_date := p_old_pull_sequence_rec.creation_date;
    END IF;

    IF l_pull_sequence_rec.created_by = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.created_by := p_old_pull_sequence_rec.created_by;
    END IF;

    IF l_pull_sequence_rec.locator_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.locator_id := p_old_pull_sequence_rec.locator_id;
    END IF;

    IF l_pull_sequence_rec.supplier_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.supplier_id := p_old_pull_sequence_rec.supplier_id;
    END IF;

    IF l_pull_sequence_rec.supplier_site_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.supplier_site_id := p_old_pull_sequence_rec.supplier_site_id;
    END IF;

    IF l_pull_sequence_rec.source_organization_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.source_organization_id := p_old_pull_sequence_rec.source_organization_id;
    END IF;

    IF l_pull_sequence_rec.source_subinventory = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.source_subinventory := p_old_pull_sequence_rec.source_subinventory;
    END IF;

    IF l_pull_sequence_rec.source_locator_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.source_locator_id := p_old_pull_sequence_rec.source_locator_id;
    END IF;

    IF l_pull_sequence_rec.wip_line_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.wip_line_id := p_old_pull_sequence_rec.wip_line_id;
    END IF;

    IF l_pull_sequence_rec.replenishment_lead_time = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.replenishment_lead_time := p_old_pull_sequence_rec.replenishment_lead_time;
    END IF;

    IF l_pull_sequence_rec.Release_Kanban_Flag = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.Release_Kanban_Flag := p_old_pull_sequence_rec.Release_Kanban_Flag;

    END IF;
    IF l_pull_sequence_rec.Calculate_Kanban_Flag = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.Calculate_Kanban_Flag := p_old_pull_sequence_rec.Calculate_Kanban_Flag;
    END IF;

    IF l_pull_sequence_rec.kanban_size = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.kanban_size := p_old_pull_sequence_rec.kanban_size;
    END IF;

    IF l_pull_sequence_rec.fixed_lot_multiplier = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.fixed_lot_multiplier := p_old_pull_sequence_rec.fixed_lot_multiplier;
    END IF;

    IF l_pull_sequence_rec.safety_stock_days = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.safety_stock_days := p_old_pull_sequence_rec.safety_stock_days;
    END IF;

    IF l_pull_sequence_rec.number_of_cards = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.number_of_cards := p_old_pull_sequence_rec.number_of_cards;
    END IF;

    IF l_pull_sequence_rec.minimum_order_quantity = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.minimum_order_quantity := p_old_pull_sequence_rec.minimum_order_quantity;
    END IF;

    IF l_pull_sequence_rec.aggregation_type = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.aggregation_type := p_old_pull_sequence_rec.aggregation_type;
    END IF;

    IF l_pull_sequence_rec.Allocation_Percent = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.Allocation_Percent := p_old_pull_sequence_rec.Allocation_Percent;
    END IF;

    IF l_pull_sequence_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.last_update_login := p_old_pull_sequence_rec.last_update_login;
    END IF;

    IF l_pull_sequence_rec.updated_flag = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.updated_flag := p_old_pull_sequence_rec.updated_flag;
    END IF;

    IF l_pull_sequence_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute_category := p_old_pull_sequence_rec.attribute_category;
    END IF;

    IF l_pull_sequence_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute1 := p_old_pull_sequence_rec.attribute1;
    END IF;

    IF l_pull_sequence_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute2 := p_old_pull_sequence_rec.attribute2;
    END IF;

    IF l_pull_sequence_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute3 := p_old_pull_sequence_rec.attribute3;
    END IF;

    IF l_pull_sequence_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute4 := p_old_pull_sequence_rec.attribute4;
    END IF;

    IF l_pull_sequence_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute5 := p_old_pull_sequence_rec.attribute5;
    END IF;

    IF l_pull_sequence_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute6 := p_old_pull_sequence_rec.attribute6;
    END IF;

    IF l_pull_sequence_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute7 := p_old_pull_sequence_rec.attribute7;
    END IF;

    IF l_pull_sequence_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute8 := p_old_pull_sequence_rec.attribute8;
    END IF;

    IF l_pull_sequence_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute9 := p_old_pull_sequence_rec.attribute9;
    END IF;

    IF l_pull_sequence_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute10 := p_old_pull_sequence_rec.attribute10;
    END IF;

    IF l_pull_sequence_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute11 := p_old_pull_sequence_rec.attribute11;
    END IF;

    IF l_pull_sequence_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute12 := p_old_pull_sequence_rec.attribute12;
    END IF;

    IF l_pull_sequence_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute13 := p_old_pull_sequence_rec.attribute13;
    END IF;

    IF l_pull_sequence_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute14 := p_old_pull_sequence_rec.attribute14;
    END IF;

    IF l_pull_sequence_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.attribute15 := p_old_pull_sequence_rec.attribute15;
    END IF;

    IF l_pull_sequence_rec.request_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.request_id := p_old_pull_sequence_rec.request_id;
    END IF;

    IF l_pull_sequence_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.program_application_id := p_old_pull_sequence_rec.program_application_id;
    END IF;

    IF l_pull_sequence_rec.program_id = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.program_id := p_old_pull_sequence_rec.program_id;
    END IF;

    IF l_pull_sequence_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_pull_sequence_rec.program_update_date := p_old_pull_sequence_rec.program_update_date;
    END IF;

    IF l_pull_sequence_rec.point_of_use_x = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.point_of_use_x := p_old_pull_sequence_rec.point_of_use_x;
    END IF;

    IF l_pull_sequence_rec.point_of_use_y = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.point_of_use_y := p_old_pull_sequence_rec.point_of_use_y;
    END IF;

    IF l_pull_sequence_rec.point_of_supply_x = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.point_of_supply_x := p_old_pull_sequence_rec.point_of_supply_x;
    END IF;

    IF l_pull_sequence_rec.point_of_supply_y = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.point_of_supply_y := p_old_pull_sequence_rec.point_of_supply_y;
    END IF;

    IF l_pull_sequence_rec.planning_update_status = FND_API.G_MISS_NUM THEN
        l_pull_sequence_rec.planning_update_status := p_old_pull_sequence_rec.planning_update_status;
    END IF;

    IF l_pull_sequence_rec.auto_request = FND_API.G_MISS_CHAR THEN
        l_pull_sequence_rec.auto_request := p_old_pull_sequence_rec.auto_request;
    END IF;

    /*Added the following IF statement for 3905884.*/
    IF l_pull_sequence_rec.auto_allocate_flag = FND_API.G_MISS_NUM THEN
       l_pull_sequence_rec.auto_allocate_flag := p_old_pull_sequence_rec.auto_allocate_flag;
    END IF;

    RETURN l_pull_sequence_rec;

END Complete_Record;

PROCEDURE   Insert_Row(x_return_status        OUT NOCOPY    Varchar2,
                       p_pull_sequence_id     IN Out NOCOPY NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id       		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Last_Updated_By                NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory            VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_Kanban_Flag 		NUMBER,
                       p_Calculate_Kanban_Flag 		NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_type		NUMBER,
                       p_Allocation_Percent		NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag          		NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
                       p_Request_Id        		NUMBER,
                       p_Program_application_Id		NUMBER,
                       p_Program_Id        		NUMBER,
                       p_Program_Update_date        	DATE,
		       p_point_of_use_x			NUMBER DEFAULT NULL,
	               p_point_of_use_y			NUMBER DEFAULT NULL,
		       p_point_of_supply_x		NUMBER DEFAULT NULL,
	               p_point_of_supply_y		NUMBER DEFAULT NULL,
		       p_planning_update_status		NUMBER DEFAULT NULL,
		       p_auto_request                   VARCHAR2 DEFAULT NULL,
                       p_Auto_Allocate_Flag             NUMBER ) --Bug3905884
   is
   l_pull_sequence_Id     MTL_Kanban_Pull_Sequences.Pull_Sequence_Id%Type;
   l_return_status        Varchar2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
       FND_MSG_PUB.Initialize;
       If nvl(p_Pull_sequence_Id,0) <= 0
       Then
       	Select MTL_KANBAN_PULL_SEQUENCES_S.NEXTVAL
       	into l_pull_sequence_Id
       	from dual;
       Else
        l_pull_sequence_Id := p_Pull_sequence_Id;
       End If;

       INSERT INTO MTL_KANBAN_PULL_SEQUENCES
             (
              Pull_sequence_id,
              Inventory_item_id,
              Organization_id,
              Subinventory_name,
              Kanban_Plan_id,
              Source_type,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_By,
              Last_Update_Login,
              Locator_id,
              Supplier_id,
              Supplier_site_id,
              Source_Organization_id,
              Source_Subinventory,
              Source_Locator_id,
              Wip_Line_id,
              Release_Kanban_flag,
              Calculate_Kanban_flag,
              Kanban_size,
              Number_of_cards,
              Minimum_order_quantity,
              Aggregation_type,
              Allocation_Percent,
              Replenishment_lead_time,
              Fixed_Lot_multiplier,
              Safety_Stock_Days,
              Updated_Flag,
              Attribute_Category,
              Attribute1,
              Attribute2,
              Attribute3,
              Attribute4,
              Attribute5,
              Attribute6,
              Attribute7,
              Attribute8,
              Attribute9,
              Attribute10,
              Attribute11,
              Attribute12,
              Attribute13,
              Attribute14,
              Attribute15,
              Request_Id,
              Program_application_Id,
              Program_Id,
              Program_Update_date,
              point_of_use_x,
              point_of_use_y,
	      point_of_supply_x,
              point_of_supply_y,
	      planning_update_status,
	      auto_request,
              Auto_Allocate_Flag) --Bug3905884
        Values
              (
              l_Pull_sequence_id,
              p_Inventory_item_id,
              p_Organization_id,
              p_Subinventory_name,
              p_Kanban_Plan_id,
              p_Source_type,
              p_Last_Update_Date,
              p_Last_Updated_By,
              p_Creation_Date,
              p_Created_By,
              p_Last_Update_Login,
              p_Locator_id,
              p_Supplier_id,
              p_Supplier_site_id,
              p_Source_Organization_id,
              p_Source_Subinventory,
              p_Source_Locator_id,
              p_Wip_Line_id,
              p_Release_Kanban_flag,
              p_Calculate_Kanban_flag,
              p_Kanban_size,
              p_Number_of_cards,
              p_Minimum_order_quantity,
              p_Aggregation_type,
              p_Allocation_Percent,
              p_Replenishment_lead_time,
              p_Fixed_Lot_multiplier,
              p_Safety_Stock_Days,
              p_Updated_Flag,
              p_Attribute_Category,
              p_Attribute1,
              p_Attribute2,
              p_Attribute3,
              p_Attribute4,
              p_Attribute5,
              p_Attribute6,
              p_Attribute7,
              p_Attribute8,
              p_Attribute9,
              p_Attribute10,
              p_Attribute11,
              p_Attribute12,
              p_Attribute13,
              p_Attribute14,
              p_Attribute15,
              p_Request_Id,
              p_Program_application_Id,
              p_Program_Id,
              p_Program_Update_Date,
	      p_point_of_use_x,
	      p_point_of_use_y,
	      p_point_of_supply_x,
              p_point_of_supply_y,
	      p_planning_update_status,
	      p_auto_request,
              p_Auto_Allocate_Flag --Bug3905884
              );

              p_pull_sequence_id := l_Pull_Sequence_id;

              x_return_status := l_return_status;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Insert_Row;

Procedure Insert_Row(p_pull_sequence_rec INV_Kanban_PVT.Pull_Sequence_Rec_Type)
Is
l_Pull_sequence_rec    INV_Kanban_PVT.Pull_Sequence_Rec_Type :=
			p_pull_sequence_rec;
l_return_status Varchar2(1);

Begin
        FND_MSG_PUB.Initialize;
	INV_PullSequence_PKG.Insert_Row(
	x_return_status 	=>l_return_status,
	p_pull_sequence_id 	=>l_Pull_sequence_Rec.pull_sequence_id,
        p_Inventory_item_id	=>l_Pull_sequence_Rec.Inventory_item_id,
        p_Organization_id	=>l_Pull_sequence_Rec.Organization_id,
        p_Subinventory_name	=>l_Pull_sequence_Rec.Subinventory_name,
        p_Kanban_Plan_id	=>l_Pull_sequence_Rec.Kanban_Plan_id,
        p_Source_type		=>l_Pull_sequence_Rec.Source_type,
        p_Last_Update_Date	=>l_Pull_sequence_Rec.Last_Update_Date,
        p_Last_Updated_By	=>l_Pull_sequence_Rec.Last_Updated_By,
        p_Creation_Date		=>l_Pull_sequence_Rec.Creation_Date,
        p_Created_By		=>l_Pull_sequence_Rec.Created_By,
        p_Last_Update_Login	=>l_Pull_sequence_Rec.Last_Update_Login,
        p_Locator_id		=>l_Pull_sequence_Rec.Locator_id,
        p_Supplier_id		=>l_Pull_sequence_Rec.Supplier_id,
        p_Supplier_site_id	=>l_Pull_sequence_Rec.Supplier_site_id,
        p_Source_Organization_id=>l_Pull_sequence_Rec.Source_Organization_id,
        p_Source_Subinventory	=>l_Pull_sequence_Rec.Source_Subinventory,
        p_Source_Locator_id	=>l_Pull_sequence_Rec.Source_Locator_id,
        p_Wip_Line_id		=>l_Pull_Sequence_Rec.Wip_Line_id,
        p_Release_Kanban_Flag	=>l_Pull_sequence_Rec.Release_Kanban_Flag,
        p_Calculate_Kanban_Flag	=>l_Pull_sequence_Rec.Calculate_Kanban_Flag,
        p_Kanban_size		=>l_Pull_sequence_Rec.Kanban_size,
        p_Number_of_cards	=>l_Pull_sequence_Rec.Number_of_cards,
        p_Minimum_order_quantity=>l_Pull_sequence_Rec.Minimum_order_quantity,
        p_Aggregation_type	=>l_Pull_sequence_Rec.Aggregation_type,
        p_Allocation_Percent	=>l_Pull_sequence_Rec.Allocation_Percent,
        p_Replenishment_lead_time=>l_Pull_sequence_Rec.Replenishment_lead_time,
        p_Fixed_Lot_multiplier	=>l_Pull_sequence_Rec.Fixed_Lot_multiplier,
        p_Safety_Stock_Days	=>l_Pull_sequence_Rec.Safety_Stock_Days,
        p_Updated_Flag		=>l_Pull_sequence_Rec.Updated_Flag,
        p_Attribute_Category	=>l_Pull_sequence_Rec.Attribute_Category,
        p_Attribute1		=>l_Pull_sequence_Rec.Attribute1,
        p_Attribute2		=>l_Pull_sequence_Rec.Attribute2,
        p_Attribute3		=>l_Pull_sequence_Rec.Attribute3,
        p_Attribute4		=>l_Pull_sequence_Rec.Attribute4,
        p_Attribute5		=>l_Pull_sequence_Rec.Attribute5,
        p_Attribute6		=>l_Pull_sequence_Rec.Attribute6,
        p_Attribute7		=>l_Pull_sequence_Rec.Attribute7,
        p_Attribute8		=>l_Pull_sequence_Rec.Attribute8,
        p_Attribute9		=>l_Pull_sequence_Rec.Attribute9,
        p_Attribute10		=>l_Pull_sequence_Rec.Attribute10,
        p_Attribute11		=>l_Pull_sequence_Rec.Attribute11,
        p_Attribute12		=>l_Pull_sequence_Rec.Attribute12,
        p_Attribute13		=>l_Pull_sequence_Rec.Attribute13,
        p_Attribute14		=>l_Pull_sequence_Rec.Attribute14,
        p_Attribute15		=>l_Pull_sequence_Rec.Attribute15,
        p_Request_Id		=>l_Pull_sequence_Rec.Request_Id,
        p_Program_application_Id=>l_Pull_sequence_Rec.Program_application_Id,
        p_Program_Id		=>l_Pull_sequence_Rec.Program_Id,
        p_Program_Update_date	=>l_Pull_sequence_Rec.Program_Update_date,
        p_point_of_use_x	=>l_Pull_sequence_Rec.point_of_use_x,
	p_point_of_use_y	=>l_Pull_sequence_Rec.point_of_use_y,
	p_point_of_supply_x	=>l_Pull_sequence_Rec.point_of_supply_x,
        p_point_of_supply_y	=>l_Pull_sequence_Rec.point_of_supply_y,
	p_planning_update_status=>l_Pull_sequence_Rec.planning_update_status,
	p_auto_request          =>l_Pull_sequence_Rec.auto_request,
      	p_Auto_Allocate_Flag    =>l_Pull_sequence_Rec.Auto_Allocate_Flag); --Added for 3905884.
	if l_return_status = FND_API.G_RET_STS_ERROR
	Then
		Raise FND_API.G_EXC_ERROR;
	End if;

	if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	Then
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

	Raise FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	Raise FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

	Raise FND_API.G_EXC_UNEXPECTED_ERROR;

End Insert_Row;

PROCEDURE   Lock_Row  (p_Pull_Sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id        		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory            VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_Kanban_flag            NUMBER,
                       p_Calculate_Kanban_flag          NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_type		NUMBER,
                       p_Allocation_Percent             NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag           	NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
		       p_point_of_use_x			NUMBER DEFAULT NULL,
	               p_point_of_use_y			NUMBER DEFAULT NULL,
		       p_point_of_supply_x		NUMBER DEFAULT NULL,
	               p_point_of_supply_y		NUMBER DEFAULT NULL,
		       p_planning_update_status		NUMBER DEFAULT NULL,
		       p_auto_request                   VARCHAR2 DEFAULT NULL,
		       p_Auto_Allocate_Flag             NUMBER)--Added for 3905884.
IS
    CURSOR Get_Current_Row IS
        SELECT *
        FROM   MTL_KANBAN_PULL_SEQUENCES
        WHERE  pull_sequence_id = p_pull_sequence_id
        FOR UPDATE of Organization_Id NOWAIT;

    Recinfo MTL_KANBAN_PULL_SEQUENCES%ROWTYPE;
    RECORD_CHANGED EXCEPTION;
BEGIN
    OPEN Get_Current_Row;
    FETCH Get_Current_Row INTO Recinfo;
    if (Get_Current_Row%NOTFOUND) then
      CLOSE Get_Current_Row;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE Get_Current_Row;
    if not (
	Recinfo.Inventory_item_id 	=	p_Inventory_item_id and
      	Recinfo.Organization_Id 	=	p_Organization_Id and
 	Recinfo.Subinventory_name       =	p_Subinventory_name and
 	Recinfo.Kanban_Plan_id               	=	p_Kanban_Plan_id and
	Recinfo.Source_type             =	p_Source_type and
      ((Recinfo.Locator_id            =	p_Locator_id)
     or (Recinfo.Locator_id is null  and p_Locator_id is null)) and
      ((Recinfo.Supplier_id           =	p_Supplier_id)
     or (Recinfo.Supplier_id is null and p_Supplier_id is null)) and
      ((Recinfo.Supplier_site_id      =	p_Supplier_site_id)
     or (Recinfo.Supplier_site_id is null and p_Supplier_site_id is null)) and
      ((Recinfo.Source_Organization_id=	p_Source_Organization_id)
     or (Recinfo.Source_Organization_id is null and p_Source_Organization_id is null)) and
      ((Recinfo.Source_Subinventory      =	p_Source_Subinventory)
     or (Recinfo.Source_Subinventory is null and p_Source_Subinventory is null)) and
      ((Recinfo.Source_Locator_id      =	p_Source_Locator_id)
     or (Recinfo.Source_Locator_id is null and p_Source_Locator_id is null)) and
      ((Recinfo.Wip_Line_id      =	p_Wip_Line_id)
     or (Recinfo.Wip_Line_id is null and p_Wip_Line_id is null)) and
      ((Recinfo.Release_Kanban_Flag      =	p_Release_Kanban_flag)
     or (Recinfo.Release_Kanban_flag is null and p_Release_Kanban_flag is null)) and
      ((Recinfo.Calculate_Kanban_Flag      =	p_Calculate_Kanban_flag)
     or (Recinfo.Calculate_Kanban_flag is null and p_Calculate_Kanban_flag is null)) and
      ((Recinfo.Kanban_size      =	p_Kanban_size)
     or (Recinfo.Kanban_size is null and p_Kanban_size is null)) and
      ((Recinfo.Number_of_cards      =	p_Number_of_cards)
     or (Recinfo.Number_of_cards is null and p_Number_of_cards is null)) and
      ((Recinfo.Minimum_order_quantity      =	p_Minimum_order_quantity)
     or (Recinfo.Minimum_order_quantity is null and p_Minimum_order_quantity is null)) and
      ((Recinfo.Aggregation_Type      =	p_Aggregation_Type)
     or (Recinfo.Aggregation_Type is null and p_Aggregation_Type is null)) and
      ((Recinfo.Allocation_Percent      =	p_Allocation_Percent)
     or (Recinfo.Allocation_Percent is null and p_Allocation_Percent is null)) and
      ((Recinfo.Replenishment_lead_time      =	p_Replenishment_lead_time)
     or (Recinfo.Replenishment_lead_time is null and p_Replenishment_lead_time is null)) and
      ((Recinfo.fixed_lot_multiplier      =	p_fixed_lot_multiplier)
     or (Recinfo.fixed_lot_multiplier is null and p_fixed_lot_multiplier is null)) and
      ((Recinfo.Safety_Stock_Days      =	p_Safety_Stock_Days)
     or (Recinfo.Safety_Stock_Days is null and p_Safety_Stock_Days is null)) and
      ((Recinfo.Updated_Flag      =	p_Updated_Flag)
     or (Recinfo.Updated_Flag is null and p_Updated_Flag is null))  and
      ((Recinfo.Attribute_Category      =	p_Attribute_Category)
     or (Recinfo.Attribute_Category is null and p_Attribute_Category is null))
     /*Fix for 3905884.*/
     and ((Recinfo.Auto_Allocate_Flag      =	p_Auto_Allocate_Flag)
       or (Recinfo.Auto_Allocate_Flag is null and p_Auto_Allocate_Flag is null))    /*End of fix for 3905884*/
	) then
            RAISE RECORD_CHANGED;
	end if;
      if not (
      (   (Recinfo.attribute1 =  p_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (p_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 =  p_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (p_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 =  p_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (p_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 =  p_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (p_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 =  p_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (p_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 =  p_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (p_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 =  p_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (p_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 =  p_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (p_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 =  p_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (p_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 =  p_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (p_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 =  p_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (p_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 =  p_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (p_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 =  p_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (p_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 =  p_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (p_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 =  p_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (p_Attribute15 IS NULL)))
     ) then
         RAISE RECORD_CHANGED;
      end if;

     IF NOT (
      (   (Recinfo.point_of_use_x =  p_point_of_use_x)
           OR (    (Recinfo.point_of_use_x IS NULL)
               AND (p_point_of_use_x IS NULL)))
      AND (   (Recinfo.point_of_use_y =  p_point_of_use_y)
           OR (    (Recinfo.point_of_use_y IS NULL)
               AND (p_point_of_use_y IS NULL)))
      AND (   (Recinfo.point_of_supply_x =  p_point_of_supply_x)
           OR (    (Recinfo.point_of_supply_x IS NULL)
               AND (p_point_of_supply_x IS NULL)))
      AND (   (Recinfo.point_of_supply_x =  p_point_of_supply_x)
           OR (    (Recinfo.point_of_supply_x IS NULL)
               AND (p_point_of_supply_x IS NULL)))
      AND (   (Recinfo.point_of_supply_y =  p_point_of_supply_y)
           OR (    (Recinfo.point_of_supply_y IS NULL)
               AND (p_point_of_supply_y IS NULL)))
      AND (   (Recinfo.planning_update_status=  p_planning_update_status)
           OR (    (Recinfo.planning_update_status IS NULL)
               AND (p_planning_update_status IS NULL)))
      AND (   (Recinfo.auto_request =  p_auto_request)
           OR (    (Recinfo.auto_request IS NULL)
               AND (p_auto_request IS NULL)))
     ) THEN
         RAISE RECORD_CHANGED;
      END IF;
exception
       WHEN RECORD_CHANGED THEN
	FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    when others then
    raise;
END Lock_Row;

PROCEDURE   Update_Row(x_return_status        OUT NOCOPY     	VARCHAR2,
                       p_Pull_Sequence_Id               NUMBER,
                       p_Inventory_item_id              NUMBER,
                       p_Organization_id       		NUMBER,
                       p_Subinventory_name              VARCHAR2,
                       p_Kanban_Plan_id        		NUMBER,
                       p_Source_type           		NUMBER,
                       p_Last_Update_Date               DATE,
                       p_Last_Updated_By                NUMBER,
                       p_Creation_Date                  DATE,
                       p_Created_By                     NUMBER,
                       p_Last_Update_Login              NUMBER,
                       p_Locator_id              	NUMBER,
                       p_Supplier_id           		NUMBER,
                       p_Supplier_site_id      		NUMBER,
                       p_Source_Organization_id		NUMBER,
                       p_Source_Subinventory            VARCHAR2,
                       p_Source_Locator_id		NUMBER,
                       p_Wip_Line_id		        NUMBER,
                       p_Release_Kanban_flag 		NUMBER,
                       p_Calculate_Kanban_flag 		NUMBER,
                       p_Kanban_size        		NUMBER,
                       p_Number_of_cards       		NUMBER,
                       p_Minimum_order_quantity		NUMBER,
                       p_Aggregation_Type		NUMBER,
                       p_Allocation_Percent		NUMBER,
                       p_Replenishment_lead_time        NUMBER,
                       p_Fixed_Lot_multiplier           NUMBER,
                       p_Safety_Stock_Days              NUMBER,
                       p_Updated_Flag           	NUMBER,
                       p_Attribute_Category             VARCHAR2,
                       p_Attribute1                     VARCHAR2,
                       p_Attribute2                     VARCHAR2,
                       p_Attribute3                     VARCHAR2,
                       p_Attribute4                     VARCHAR2,
                       p_Attribute5                     VARCHAR2,
                       p_Attribute6                     VARCHAR2,
                       p_Attribute7                     VARCHAR2,
                       p_Attribute8                     VARCHAR2,
                       p_Attribute9                     VARCHAR2,
                       p_Attribute10                    VARCHAR2,
                       p_Attribute11                    VARCHAR2,
                       p_Attribute12                    VARCHAR2,
                       p_Attribute13                    VARCHAR2,
                       p_Attribute14                    VARCHAR2,
                       p_Attribute15                    VARCHAR2,
		       p_point_of_use_x			NUMBER DEFAULT NULL,
	               p_point_of_use_y			NUMBER DEFAULT NULL,
		       p_point_of_supply_x		NUMBER DEFAULT NULL,
	               p_point_of_supply_y		NUMBER DEFAULT NULL,
		       p_planning_update_status		NUMBER DEFAULT NULL,
		       p_auto_request                   VARCHAR2 DEFAULT NULL,
                       p_Auto_Allocate_Flag             NUMBER )  --Added for 3905884
IS

l_return_status 	varchar2(1)     := FND_API.G_RET_STS_SUCCESS;

BEGIN
        FND_MSG_PUB.Initialize;
	UPDATE MTL_KANBAN_PULL_SEQUENCES
	SET
      		Inventory_item_id 	=	p_Inventory_item_id,
      		Organization_Id 	=	p_Organization_Id,
 		Subinventory_name       =	p_Subinventory_name,
	 	Kanban_Plan_id         	=	p_Kanban_Plan_id,
 		Source_type             =	p_Source_type,
 		Last_Update_Date        =	p_Last_Update_Date,
 		Last_Updated_By         =	p_Last_Updated_By,
 		Creation_Date           =	p_Creation_Date,
 		Created_By              =	p_Created_By,
 		Last_Update_Login       =	p_Last_Update_Login,
 		Locator_id              =	p_Locator_id,
 		Supplier_id             =	p_Supplier_id,
 		Supplier_site_id        =	p_Supplier_site_id,
 		Source_Organization_id  =	p_Source_Organization_id,
 		Source_Subinventory     =	p_Source_Subinventory,
 		Source_Locator_id       =	p_Source_Locator_id,
 		Wip_Line_id             =	p_Wip_Line_id,
 		Release_Kanban_Flag     =	p_Release_Kanban_flag,
 		Calculate_Kanban_Flag   =	p_Calculate_Kanban_flag,
 		Kanban_size             =	p_Kanban_size,
 		Number_of_cards         =	p_Number_of_cards,
 		Minimum_order_quantity  =	p_Minimum_order_quantity,
 		Aggregation_Type        =	p_Aggregation_Type,
 		Allocation_Percent      =	p_Allocation_Percent,
 		Replenishment_lead_time =	p_Replenishment_lead_time,
 		Fixed_Lot_multiplier    =	p_Fixed_Lot_multiplier,
 		Safety_Stock_Days       =	p_Safety_Stock_Days,
 		Updated_Flag            =	p_Updated_Flag,
 		Attribute_Category      =	p_Attribute_Category,
 		Attribute1              =	p_Attribute1,
 		Attribute2              =	p_Attribute2,
 		Attribute3              =	p_Attribute3,
 		Attribute4              =	p_Attribute4,
 		Attribute5              =	p_Attribute5,
 		Attribute6              =	p_Attribute6,
 		Attribute7              =	p_Attribute7,
 		Attribute8              =	p_Attribute8,
 		Attribute9              =	p_Attribute9,
 		Attribute10             =	p_Attribute10,
 		Attribute11             =	p_Attribute11,
 		Attribute12             =	p_Attribute12,
 		Attribute13             =	p_Attribute13,
 		Attribute14             =	p_Attribute14,
 		Attribute15             =	p_Attribute15,
		point_of_use_x		=	p_point_of_use_x,
		point_of_use_y		=	p_point_of_use_y,
	        point_of_supply_x	=	p_point_of_supply_x,
                point_of_supply_y	=	p_point_of_supply_y,
	        planning_update_status	=	p_planning_update_status,
		auto_request            =       p_auto_request,
		Auto_Allocate_Flag      =       p_Auto_Allocate_Flag --Added for 3905884
    WHERE pull_sequence_id = p_pull_sequence_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;

PROCEDURE Update_Row(
p_pull_sequence_rec INV_Kanban_PVT.Pull_sequence_Rec_Type)
Is

l_return_status Varchar2(1);

Begin
        FND_MSG_PUB.Initialize;
	Update_Row(
	x_return_status 	=>l_return_status,
	p_pull_sequence_id 	=>p_Pull_sequence_Rec.pull_sequence_id,
        p_Inventory_item_id	=>p_Pull_sequence_Rec.Inventory_item_id,
        p_Organization_id	=>p_Pull_sequence_Rec.Organization_id,
        p_Subinventory_name	=>p_Pull_sequence_Rec.Subinventory_name,
        p_Kanban_Plan_id	=>p_Pull_sequence_Rec.Kanban_Plan_id,
        p_Source_type		=>p_Pull_sequence_Rec.Source_type	,
        p_Last_Update_Date	=>p_Pull_sequence_Rec.Last_Update_Date,
        p_Last_Updated_By	=>p_Pull_sequence_Rec.Last_Updated_By,
        p_Creation_Date		=>p_Pull_sequence_Rec.Creation_Date,
        p_Created_By		=>p_Pull_sequence_Rec.Created_By,
        p_Last_Update_Login	=>p_Pull_sequence_Rec.Last_Update_Login	,
        p_Locator_id		=>p_Pull_sequence_Rec.Locator_id,
        p_Supplier_id		=>p_Pull_sequence_Rec.Supplier_id,
        p_Supplier_site_id	=>p_Pull_sequence_Rec.Supplier_site_id	,
        p_Source_Organization_id=>p_Pull_sequence_Rec.Source_Organization_id,
        p_Source_Subinventory	=>p_Pull_sequence_Rec.Source_Subinventory,
        p_Source_Locator_id	=>p_Pull_sequence_Rec.Source_Locator_id	,
        p_Wip_Line_id		=>p_Pull_Sequence_Rec.Wip_Line_id	,
        p_Release_Kanban_Flag	=>p_Pull_sequence_Rec.Release_Kanban_Flag,
        p_Calculate_Kanban_Flag	=>p_Pull_sequence_Rec.Calculate_Kanban_Flag,
        p_Kanban_size		=>p_Pull_sequence_Rec.Kanban_size	,
        p_Number_of_cards	=>p_Pull_sequence_Rec.Number_of_cards	,
        p_Minimum_order_quantity=>p_Pull_sequence_Rec.Minimum_order_quantity,
        p_Aggregation_type	=>p_Pull_sequence_Rec.Aggregation_type	,
        p_Allocation_Percent	=>p_Pull_sequence_Rec.Allocation_Percent,
        p_Replenishment_lead_time=>p_Pull_sequence_Rec.Replenishment_lead_time,
        p_Fixed_Lot_multiplier	=>p_Pull_sequence_Rec.Fixed_Lot_multiplier,
        p_Safety_Stock_Days	=>p_Pull_sequence_Rec.Safety_Stock_Days	,
        p_Updated_Flag		=>p_Pull_sequence_Rec.Updated_Flag	,
        p_Attribute_Category	=>p_Pull_sequence_Rec.Attribute_Category,
        p_Attribute1		=>p_Pull_sequence_Rec.Attribute1	,
        p_Attribute2		=>p_Pull_sequence_Rec.Attribute2	,
        p_Attribute3		=>p_Pull_sequence_Rec.Attribute3	,
        p_Attribute4		=>p_Pull_sequence_Rec.Attribute4	,
        p_Attribute5		=>p_Pull_sequence_Rec.Attribute5	,
        p_Attribute6		=>p_Pull_sequence_Rec.Attribute6	,
        p_Attribute7		=>p_Pull_sequence_Rec.Attribute7	,
        p_Attribute8		=>p_Pull_sequence_Rec.Attribute8	,
        p_Attribute9		=>p_Pull_sequence_Rec.Attribute9	,
        p_Attribute10		=>p_Pull_sequence_Rec.Attribute10	,
        p_Attribute11		=>p_Pull_sequence_Rec.Attribute11	,
        p_Attribute12		=>p_Pull_sequence_Rec.Attribute12	,
        p_Attribute13		=>p_Pull_sequence_Rec.Attribute13	,
        p_Attribute14		=>p_Pull_sequence_Rec.Attribute14	,
        p_Attribute15		=>p_Pull_sequence_Rec.Attribute15	,
	p_point_of_use_x	=>p_Pull_sequence_Rec.point_of_use_x	,
	p_point_of_use_y	=>p_Pull_sequence_Rec.point_of_use_y	,
	p_point_of_supply_x	=>p_Pull_sequence_Rec.point_of_supply_x	,
        p_point_of_supply_y	=>p_Pull_sequence_Rec.point_of_supply_y ,
	p_planning_update_status =>p_Pull_sequence_Rec.planning_update_status,
	p_auto_request          =>p_Pull_sequence_Rec.auto_request,
	p_Auto_Allocate_Flag    =>p_Pull_sequence_Rec.Auto_Allocate_Flag ); --Added for 3905884.

	if l_return_status = FND_API.G_RET_STS_ERROR
	Then
		Raise FND_API.G_EXC_ERROR;
	End if;

	if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	Then
		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End If;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        Raise FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       Raise FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;
        Raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

PROCEDURE Delete_Row(x_return_status    OUT NOCOPY VARCHAR2,
                     p_Pull_Sequence_Id     Number)
IS
l_return_status         varchar2(1) :=  FND_API.G_RET_STS_ERROR;

BEGIN
    FND_MSG_PUB.Initialize;
    if INV_Kanban_PVT.Ok_To_Delete_Pull_Sequence(p_pull_sequence_Id)
    then

      DELETE FROM MTL_KANBAN_PULL_SEQUENCES
      WHERE pull_sequence_id = p_pull_sequence_id;

      if (SQL%NOTFOUND) then
        Raise FND_API.G_EXC_UNEXPECTED_ERROR;
      else
        l_return_status := FND_API.G_RET_STS_SUCCESS;
      end if;
    else
	Raise FND_API.G_EXC_ERROR;
    end if;

    x_return_status := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

       	x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

       	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

END Delete_Row;

END INV_PullSequence_PKG;

/
