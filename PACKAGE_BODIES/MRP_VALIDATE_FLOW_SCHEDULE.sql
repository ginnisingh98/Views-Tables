--------------------------------------------------------
--  DDL for Package Body MRP_VALIDATE_FLOW_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_VALIDATE_FLOW_SCHEDULE" AS
/* $Header: MRPLSCNB.pls 120.0 2005/05/27 11:12:39 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Validate_Flow_Schedule';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy			      VARCHAR2(10) := NULL;
l_see_eng_items		      NUMBER := 0;
l_schedule_group_id	      NUMBER := NULL;
--bug 3906891: use l_flow_schedule_rec instead of p_flow_schedule_rec
l_flow_schedule_rec MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type := MRP_Flow_Schedule_Util.Convert_Miss_To_Null (p_flow_schedule_rec);

BEGIN

    --  Check required (primary key) attributes.

    IF  l_flow_schedule_rec.organization_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ORG_ID_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.wip_entity_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_WIP_ENTITY_ID_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    IF l_flow_schedule_rec.scheduled_flag IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_SCH_FLAG_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.primary_item_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ITEM_ID_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.class_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_CLASS_CODE_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.scheduled_completion_date IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_SCH_COMP_DATE_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.planned_quantity IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_PLANNED_QTY_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.quantity_completed IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_QTY_COMP_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.scheduled_start_date IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_SCH_START_DATE_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.status IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_STATUS_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF l_flow_schedule_rec.schedule_number IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_SCH_NUMBER_REQUIRED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

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

    -- Validate Alternate_Bom_Designator
    IF l_flow_schedule_rec.alternate_bom_designator <>
        p_old_flow_schedule_rec.alternate_bom_designator
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM bom_bill_alternates_v
            WHERE assembly_item_id = l_flow_schedule_rec.primary_item_id
            AND organization_id = l_flow_schedule_rec.organization_id
            AND alternate_bom_designator =
			l_flow_schedule_rec.alternate_bom_designator;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ALT_BOM_DESIG');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.alternate_bom_designator);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Alternate Bom Designator'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Alternate_Routing_Designator
    IF l_flow_schedule_rec.alternate_routing_desig <>
        p_old_flow_schedule_rec.alternate_routing_desig
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM bom_routing_alternates_v
            WHERE assembly_item_id = l_flow_schedule_rec.primary_item_id
            AND organization_id = l_flow_schedule_rec.organization_id
            AND NVL(cfm_routing_flag,2) = 2
            AND alternate_routing_designator =
			l_flow_schedule_rec.alternate_routing_desig;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ALT_RTG_DESIG');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.alternate_routing_desig);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Alternate Routing Designator'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Bom_Revision and Bom_Revision_Date
    IF l_flow_schedule_rec.bom_revision <> p_old_flow_schedule_rec.bom_revision
       OR l_flow_schedule_rec.bom_revision_date <>
		p_old_flow_schedule_rec.bom_revision_date
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM bom_bill_no_hold_revisions_v
            WHERE inventory_item_id = l_flow_schedule_rec.primary_item_id
            AND organization_id = l_flow_schedule_rec.organization_id
            AND revision = l_flow_schedule_rec.bom_revision
            AND l_flow_schedule_rec.bom_revision_date >=  --fix bug#3170105
                effectivity_date;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_BOM_REV');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.bom_revision);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Bom Revison'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Build Sequence and Schedule Group uniqueness
    IF l_flow_schedule_rec.build_sequence <>
		p_old_flow_schedule_rec.build_sequence
        OR p_old_flow_schedule_rec.build_sequence IS NULL
	OR l_flow_schedule_rec.schedule_group_id <>
		p_old_flow_schedule_rec.schedule_group_id
	OR l_flow_schedule_rec.line_id <>
		p_old_flow_schedule_rec.line_id
	OR l_flow_schedule_rec.primary_item_id <>
		p_old_flow_schedule_rec.primary_item_id
    THEN

        BEGIN

            IF l_flow_schedule_rec.schedule_group_id = FND_API.G_MISS_NUM
            THEN
                l_schedule_group_id := NULL;
            ELSE
                l_schedule_group_id := l_flow_schedule_rec.schedule_group_id;
            END IF;

            SELECT 'VALID'
            INTO l_dummy
            FROM dual
            WHERE l_flow_schedule_rec.build_sequence NOT IN
		(SELECT build_sequence
		FROM wip_flow_schedules
		WHERE NVL(schedule_group_id,-1) = NVL(l_schedule_group_id,-1)
                AND line_id = l_flow_schedule_rec.line_id
                AND scheduled_completion_date  --fix bug#3170105
                BETWEEN l_flow_schedule_rec.scheduled_completion_date
                AND l_flow_schedule_rec.scheduled_completion_date+1-1/(24*60*60)
                AND organization_id = l_flow_schedule_rec.organization_id
                AND build_sequence = l_flow_schedule_rec.build_sequence);

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_BUILD_SEQ');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.build_sequence);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Build Sequence'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Class_Code
    IF l_flow_schedule_rec.class_code <> p_old_flow_schedule_rec.class_code
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM mtl_parameters param,
		 cst_cg_wip_acct_classes_v ccwac
            WHERE ccwac.organization_id = l_flow_schedule_rec.organization_id
            AND ccwac.organization_id = param.organization_id
            AND ( l_flow_schedule_rec.project_id is null OR
                  param.primary_cost_method = 1 OR
		( param.primary_cost_method = 2 AND
		l_flow_schedule_rec.project_id is not null
		AND ccwac.cost_group_id =
		( SELECT costing_group_id
		  FROM mrp_project_parameters
                  WHERE organization_id = l_flow_schedule_rec.organization_id
                  AND project_id = l_flow_schedule_rec.project_id)))
            AND ccwac.class_code = l_flow_schedule_rec.class_code;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_CLASS_CODE');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.class_code);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Class Code'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Completion_Locator_Id
    IF l_flow_schedule_rec.completion_locator_id <>
        p_old_flow_schedule_rec.completion_locator_id
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM mtl_item_locations
            WHERE organization_id = l_flow_schedule_rec.organization_id
            AND subinventory_code = l_flow_schedule_rec.completion_subinventory
            AND (disable_date > sysdate or disable_date is null)
            AND inventory_location_id =
			l_flow_schedule_rec.completion_locator_id;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_COMP_LOC_ID');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.completion_locator_id);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Completion Locator Id'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Completion_Subinventory
    IF l_flow_schedule_rec.completion_subinventory <>
        p_old_flow_schedule_rec.completion_subinventory
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM mtl_subinventories_val_v msvv, mtl_sub_ast_trk_val_v msatvv
            WHERE msvv.organization_id = l_flow_schedule_rec.organization_id
            AND msvv.organization_id = msatvv.organization_id
            AND msvv.secondary_inventory_name = msatvv.secondary_inventory_name
            AND msvv.secondary_inventory_name =
			l_flow_schedule_rec.completion_subinventory;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_COMP_SUBINV');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.completion_subinventory);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Completion Subinventory'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Demand_Source_Line, Demand_Source_Delivery,
    -- and Demand_Source_Header_Id
    IF (l_flow_schedule_rec.demand_source_line <>
        p_old_flow_schedule_rec.demand_source_line OR
        l_flow_schedule_rec.demand_source_delivery <>
        p_old_flow_schedule_rec.demand_source_delivery) AND     /* Bug 3539807 - Added the AND-ed condn. */
       (nvl(l_flow_schedule_rec.demand_source_line,FND_API.G_MISS_CHAR)<>
        FND_API.G_MISS_CHAR OR
        nvl(l_flow_schedule_rec.demand_source_delivery,FND_API.G_MISS_CHAR)<>
        FND_API.G_MISS_CHAR)
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM wip_sales_order_lines_v
            WHERE organization_id = l_flow_schedule_rec.organization_id
            AND inventory_item_id = NVL(l_flow_schedule_rec.primary_item_id,
					inventory_item_id)
            AND NVL(demand_class,'@@@') =
			NVL(l_flow_schedule_rec.demand_class,'@@@')
            AND demand_source_header_id =
			l_flow_schedule_rec.demand_source_header_id
            AND demand_source_line = l_flow_schedule_rec.demand_source_line
            AND demand_source_delivery =
			l_flow_schedule_rec.demand_source_delivery;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_DEMAND_SOURCE');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.demand_source_header_id);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Demand Sources'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Line_Id
    IF l_flow_schedule_rec.line_id <> p_old_flow_schedule_rec.line_id
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM wip_lines
            WHERE organization_id = l_flow_schedule_rec.organization_id
            AND line_id = l_flow_schedule_rec.line_id;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_LINE_ID');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.line_id);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Line Id'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Primary_Item_Id
    IF l_flow_schedule_rec.primary_item_id <>
		p_old_flow_schedule_rec.primary_item_id
    THEN
        BEGIN

            l_see_eng_items := FND_PROFILE.Value('WIP_SEE_ENG_ITEMS');

            SELECT 'VALID'
            INTO l_dummy
            FROM mtl_system_items
            WHERE organization_id = l_flow_schedule_rec.organization_id
            AND inventory_item_id = l_flow_schedule_rec.primary_item_id
            AND build_in_wip_flag = 'Y'
            AND pick_components_flag = 'N'
            AND (l_see_eng_items = 1
               OR (l_see_eng_items = 2 AND eng_item_flag = 'N') );

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ITEM');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.primary_item_id);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Primary Item Id'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Routing_Revision and Routing_Revision_Date
    IF l_flow_schedule_rec.routing_revision <>
	p_old_flow_schedule_rec.routing_revision OR
        l_flow_schedule_rec.routing_revision_date <>
        p_old_flow_schedule_rec.routing_revision_date
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM mtl_routing_rev_highdate_v
            WHERE organization_id = l_flow_schedule_rec.organization_id
            AND inventory_item_id = l_flow_schedule_rec.primary_item_id
            AND process_revision = l_flow_schedule_rec.routing_revision
            AND l_flow_schedule_rec.routing_revision_date >=  --fix bug#3170105
                effectivity_date;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_RTG_REV');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.routing_revision);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Routing Revision'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Schedule_Group_Id
    IF l_flow_schedule_rec.schedule_group_id <>
	p_old_flow_schedule_rec.schedule_group_id
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM wip_schedule_groups
            WHERE organization_id = l_flow_schedule_rec.organization_id
            AND schedule_group_id = l_flow_schedule_rec.schedule_group_id;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_SCH_GRP');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.schedule_group_id);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Schedule Group Id'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

    END IF;

    -- Validate Task_Id
    IF l_flow_schedule_rec.task_id <>
	p_old_flow_schedule_rec.task_id
    THEN
        BEGIN

            SELECT 'VALID'
            INTO l_dummy
            FROM mtl_task_v
            WHERE project_id = l_flow_schedule_rec.project_id
            AND task_id = l_flow_schedule_rec.task_id;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN

                l_return_status := FND_API.G_RET_STS_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_TASK');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					l_flow_schedule_rec.task_id);
                    FND_MSG_PUB.Add;

                END IF;

            WHEN OTHERS THEN

                l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN

                    FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME
                    ,   'Record Validation - Task Id'
                    );
                END IF;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

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
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
--bug 3906891: use l_flow_schedule_rec instead of p_flow_schedule_rec
l_flow_schedule_rec MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type := MRP_Flow_Schedule_Util.Convert_Miss_To_Null (p_flow_schedule_rec);
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate flow_schedule attributes

    IF  l_flow_schedule_rec.alternate_bom_designator IS NOT NULL AND
        (   l_flow_schedule_rec.alternate_bom_designator <>
            p_old_flow_schedule_rec.alternate_bom_designator OR
            p_old_flow_schedule_rec.alternate_bom_designator IS NULL )
    THEN
        IF NOT MRP_Validate.Alternate_Bom_Designator(l_flow_schedule_rec.alternate_bom_designator) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.alternate_routing_desig IS NOT NULL AND
        (   l_flow_schedule_rec.alternate_routing_desig <>
            p_old_flow_schedule_rec.alternate_routing_desig OR
            p_old_flow_schedule_rec.alternate_routing_desig IS NULL )
    THEN
        IF NOT MRP_Validate.Alternate_Routing_Desig(l_flow_schedule_rec.alternate_routing_desig) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.bom_revision IS NOT NULL AND
        (   l_flow_schedule_rec.bom_revision <>
            p_old_flow_schedule_rec.bom_revision OR
            p_old_flow_schedule_rec.bom_revision IS NULL )
    THEN
        IF NOT MRP_Validate.Bom_Revision(l_flow_schedule_rec.bom_revision) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.bom_revision_date IS NOT NULL AND
        (   l_flow_schedule_rec.bom_revision_date <>
            p_old_flow_schedule_rec.bom_revision_date OR
            p_old_flow_schedule_rec.bom_revision_date IS NULL )
    THEN
        IF NOT MRP_Validate.Bom_Revision_Date(l_flow_schedule_rec.bom_revision_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.build_sequence IS NOT NULL AND
        (   l_flow_schedule_rec.build_sequence <>
            p_old_flow_schedule_rec.build_sequence OR
            p_old_flow_schedule_rec.build_sequence IS NULL )
    THEN
        IF NOT MRP_Validate.Build_Sequence(l_flow_schedule_rec.build_sequence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.class_code IS NOT NULL AND
        (   l_flow_schedule_rec.class_code <>
            p_old_flow_schedule_rec.class_code OR
            p_old_flow_schedule_rec.class_code IS NULL )
    THEN
        IF NOT MRP_Validate.Class(l_flow_schedule_rec.class_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.completion_locator_id IS NOT NULL AND
        (   l_flow_schedule_rec.completion_locator_id <>
            p_old_flow_schedule_rec.completion_locator_id OR
            p_old_flow_schedule_rec.completion_locator_id IS NULL )
    THEN
        IF NOT MRP_Validate.Completion_Locator(l_flow_schedule_rec.completion_locator_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.completion_subinventory IS NOT NULL AND
        (   l_flow_schedule_rec.completion_subinventory <>
            p_old_flow_schedule_rec.completion_subinventory OR
            p_old_flow_schedule_rec.completion_subinventory IS NULL )
    THEN
        IF NOT MRP_Validate.Completion_Subinventory(l_flow_schedule_rec.completion_subinventory) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.created_by IS NOT NULL AND
        (   l_flow_schedule_rec.created_by <>
            p_old_flow_schedule_rec.created_by OR
            p_old_flow_schedule_rec.created_by IS NULL )
    THEN
        IF NOT MRP_Validate.Created_By(l_flow_schedule_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.creation_date IS NOT NULL AND
        (   l_flow_schedule_rec.creation_date <>
            p_old_flow_schedule_rec.creation_date OR
            p_old_flow_schedule_rec.creation_date IS NULL )
    THEN
        IF NOT MRP_Validate.Creation_Date(l_flow_schedule_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.date_closed IS NOT NULL AND
        (   l_flow_schedule_rec.date_closed <>
            p_old_flow_schedule_rec.date_closed OR
            p_old_flow_schedule_rec.date_closed IS NULL )
    THEN
        IF NOT MRP_Validate.Date_Closed(l_flow_schedule_rec.date_closed) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.demand_class IS NOT NULL AND
        (   l_flow_schedule_rec.demand_class <>
            p_old_flow_schedule_rec.demand_class OR
            p_old_flow_schedule_rec.demand_class IS NULL )
    THEN
        IF NOT MRP_Validate.Demand_Class(l_flow_schedule_rec.demand_class) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.demand_source_delivery IS NOT NULL AND
        (   l_flow_schedule_rec.demand_source_delivery <>
            p_old_flow_schedule_rec.demand_source_delivery OR
            p_old_flow_schedule_rec.demand_source_delivery IS NULL )
    THEN
        IF NOT MRP_Validate.Demand_Source_Delivery(l_flow_schedule_rec.demand_source_delivery) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.demand_source_header_id IS NOT NULL AND
        (   l_flow_schedule_rec.demand_source_header_id <>
            p_old_flow_schedule_rec.demand_source_header_id OR
            p_old_flow_schedule_rec.demand_source_header_id IS NULL )
    THEN
        IF NOT MRP_Validate.Demand_Source_Header(l_flow_schedule_rec.demand_source_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.demand_source_line IS NOT NULL AND
        (   l_flow_schedule_rec.demand_source_line <>
            p_old_flow_schedule_rec.demand_source_line OR
            p_old_flow_schedule_rec.demand_source_line IS NULL )
    THEN
        IF NOT MRP_Validate.Demand_Source_Line(l_flow_schedule_rec.demand_source_line) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.demand_source_type IS NOT NULL AND
        (   l_flow_schedule_rec.demand_source_type <>
            p_old_flow_schedule_rec.demand_source_type OR
            p_old_flow_schedule_rec.demand_source_type IS NULL )
    THEN
        IF NOT MRP_Validate.Demand_Source_Type(l_flow_schedule_rec.demand_source_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.last_updated_by IS NOT NULL AND
        (   l_flow_schedule_rec.last_updated_by <>
            p_old_flow_schedule_rec.last_updated_by OR
            p_old_flow_schedule_rec.last_updated_by IS NULL )
    THEN
        IF NOT MRP_Validate.Last_Updated_By(l_flow_schedule_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.last_update_date IS NOT NULL AND
        (   l_flow_schedule_rec.last_update_date <>
            p_old_flow_schedule_rec.last_update_date OR
            p_old_flow_schedule_rec.last_update_date IS NULL )
    THEN
        IF NOT MRP_Validate.Last_Update_Date(l_flow_schedule_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.last_update_login IS NOT NULL AND
        (   l_flow_schedule_rec.last_update_login <>
            p_old_flow_schedule_rec.last_update_login OR
            p_old_flow_schedule_rec.last_update_login IS NULL )
    THEN
        IF NOT MRP_Validate.Last_Update_Login(l_flow_schedule_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.line_id IS NOT NULL AND
        (   l_flow_schedule_rec.line_id <>
            p_old_flow_schedule_rec.line_id OR
            p_old_flow_schedule_rec.line_id IS NULL )
    THEN
        IF NOT MRP_Validate.Line(l_flow_schedule_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.material_account IS NOT NULL AND
        (   l_flow_schedule_rec.material_account <>
            p_old_flow_schedule_rec.material_account OR
            p_old_flow_schedule_rec.material_account IS NULL )
    THEN
        IF NOT MRP_Validate.Material_Account(l_flow_schedule_rec.material_account) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.material_overhead_account IS NOT NULL AND
        (   l_flow_schedule_rec.material_overhead_account <>
            p_old_flow_schedule_rec.material_overhead_account OR
            p_old_flow_schedule_rec.material_overhead_account IS NULL )
    THEN
        IF NOT MRP_Validate.Material_Overhead_Account(l_flow_schedule_rec.material_overhead_account) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.material_variance_account IS NOT NULL AND
        (   l_flow_schedule_rec.material_variance_account <>
            p_old_flow_schedule_rec.material_variance_account OR
            p_old_flow_schedule_rec.material_variance_account IS NULL )
    THEN
        IF NOT MRP_Validate.Material_Variance_Account(l_flow_schedule_rec.material_variance_account) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.mps_net_quantity IS NOT NULL AND
        (   l_flow_schedule_rec.mps_net_quantity <>
            p_old_flow_schedule_rec.mps_net_quantity OR
            p_old_flow_schedule_rec.mps_net_quantity IS NULL )
    THEN
        IF NOT MRP_Validate.Mps_Net_Quantity(l_flow_schedule_rec.mps_net_quantity) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.mps_scheduled_comp_date IS NOT NULL AND
        (   l_flow_schedule_rec.mps_scheduled_comp_date <>
            p_old_flow_schedule_rec.mps_scheduled_comp_date OR
            p_old_flow_schedule_rec.mps_scheduled_comp_date IS NULL )
    THEN
        IF NOT MRP_Validate.Mps_Scheduled_Comp_Date(l_flow_schedule_rec.mps_scheduled_comp_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.organization_id IS NOT NULL AND
        (   l_flow_schedule_rec.organization_id <>
            p_old_flow_schedule_rec.organization_id OR
            p_old_flow_schedule_rec.organization_id IS NULL )
    THEN
        IF NOT MRP_Validate.Organization(l_flow_schedule_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.outside_processing_acct IS NOT NULL AND
        (   l_flow_schedule_rec.outside_processing_acct <>
            p_old_flow_schedule_rec.outside_processing_acct OR
            p_old_flow_schedule_rec.outside_processing_acct IS NULL )
    THEN
        IF NOT MRP_Validate.Outside_Processing_Acct(l_flow_schedule_rec.outside_processing_acct) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.outside_proc_var_acct IS NOT NULL AND
        (   l_flow_schedule_rec.outside_proc_var_acct <>
            p_old_flow_schedule_rec.outside_proc_var_acct OR
            p_old_flow_schedule_rec.outside_proc_var_acct IS NULL )
    THEN
        IF NOT MRP_Validate.Outside_Proc_Var_Acct(l_flow_schedule_rec.outside_proc_var_acct) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.overhead_account IS NOT NULL AND
        (   l_flow_schedule_rec.overhead_account <>
            p_old_flow_schedule_rec.overhead_account OR
            p_old_flow_schedule_rec.overhead_account IS NULL )
    THEN
        IF NOT MRP_Validate.Overhead_Account(l_flow_schedule_rec.overhead_account) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.overhead_variance_account IS NOT NULL AND
        (   l_flow_schedule_rec.overhead_variance_account <>
            p_old_flow_schedule_rec.overhead_variance_account OR
            p_old_flow_schedule_rec.overhead_variance_account IS NULL )
    THEN
        IF NOT MRP_Validate.Overhead_Variance_Account(l_flow_schedule_rec.overhead_variance_account) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.planned_quantity IS NOT NULL AND
        (   l_flow_schedule_rec.planned_quantity <>
            p_old_flow_schedule_rec.planned_quantity OR
            p_old_flow_schedule_rec.planned_quantity IS NULL )
    THEN
        IF NOT MRP_Validate.Planned_Quantity(l_flow_schedule_rec.planned_quantity) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.primary_item_id IS NOT NULL AND
        (   l_flow_schedule_rec.primary_item_id <>
            p_old_flow_schedule_rec.primary_item_id OR
            p_old_flow_schedule_rec.primary_item_id IS NULL )
    THEN
        IF NOT MRP_Validate.Primary_Item(l_flow_schedule_rec.primary_item_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.program_application_id IS NOT NULL AND
        (   l_flow_schedule_rec.program_application_id <>
            p_old_flow_schedule_rec.program_application_id OR
            p_old_flow_schedule_rec.program_application_id IS NULL )
    THEN
        IF NOT MRP_Validate.Program_Application(l_flow_schedule_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.program_id IS NOT NULL AND
        (   l_flow_schedule_rec.program_id <>
            p_old_flow_schedule_rec.program_id OR
            p_old_flow_schedule_rec.program_id IS NULL )
    THEN
        IF NOT MRP_Validate.Program(l_flow_schedule_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.program_update_date IS NOT NULL AND
        (   l_flow_schedule_rec.program_update_date <>
            p_old_flow_schedule_rec.program_update_date OR
            p_old_flow_schedule_rec.program_update_date IS NULL )
    THEN
        IF NOT MRP_Validate.Program_Update_Date(l_flow_schedule_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.project_id IS NOT NULL AND
        (   l_flow_schedule_rec.project_id <>
            p_old_flow_schedule_rec.project_id OR
            p_old_flow_schedule_rec.project_id IS NULL )
    THEN
        IF NOT MRP_Validate.Project(l_flow_schedule_rec.project_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.quantity_completed IS NOT NULL AND
        (   l_flow_schedule_rec.quantity_completed <>
            p_old_flow_schedule_rec.quantity_completed OR
            p_old_flow_schedule_rec.quantity_completed IS NULL )
    THEN
        IF NOT MRP_Validate.Quantity_Completed(l_flow_schedule_rec.quantity_completed) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.request_id IS NOT NULL AND
        (   l_flow_schedule_rec.request_id <>
            p_old_flow_schedule_rec.request_id OR
            p_old_flow_schedule_rec.request_id IS NULL )
    THEN
        IF NOT MRP_Validate.Request(l_flow_schedule_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.resource_account IS NOT NULL AND
        (   l_flow_schedule_rec.resource_account <>
            p_old_flow_schedule_rec.resource_account OR
            p_old_flow_schedule_rec.resource_account IS NULL )
    THEN
        IF NOT MRP_Validate.Resource_Account(l_flow_schedule_rec.resource_account) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.resource_variance_account IS NOT NULL AND
        (   l_flow_schedule_rec.resource_variance_account <>
            p_old_flow_schedule_rec.resource_variance_account OR
            p_old_flow_schedule_rec.resource_variance_account IS NULL )
    THEN
        IF NOT MRP_Validate.Resource_Variance_Account(l_flow_schedule_rec.resource_variance_account) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.routing_revision IS NOT NULL AND
        (   l_flow_schedule_rec.routing_revision <>
            p_old_flow_schedule_rec.routing_revision OR
            p_old_flow_schedule_rec.routing_revision IS NULL )
    THEN
        IF NOT MRP_Validate.Routing_Revision(l_flow_schedule_rec.routing_revision) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.routing_revision_date IS NOT NULL AND
        (   l_flow_schedule_rec.routing_revision_date <>
            p_old_flow_schedule_rec.routing_revision_date OR
            p_old_flow_schedule_rec.routing_revision_date IS NULL )
    THEN
        IF NOT MRP_Validate.Routing_Revision_Date(l_flow_schedule_rec.routing_revision_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.scheduled_completion_date IS NOT NULL AND
        (   l_flow_schedule_rec.scheduled_completion_date <>
            p_old_flow_schedule_rec.scheduled_completion_date OR
            p_old_flow_schedule_rec.scheduled_completion_date IS NULL )
    THEN
        IF NOT MRP_Validate.Scheduled_Completion_Date(l_flow_schedule_rec.scheduled_completion_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.scheduled_flag IS NOT NULL AND
        (   l_flow_schedule_rec.scheduled_flag <>
            p_old_flow_schedule_rec.scheduled_flag OR
            p_old_flow_schedule_rec.scheduled_flag IS NULL )
    THEN
        IF NOT MRP_Validate.Scheduled(l_flow_schedule_rec.scheduled_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.scheduled_start_date IS NOT NULL AND
        (   l_flow_schedule_rec.scheduled_start_date <>
            p_old_flow_schedule_rec.scheduled_start_date OR
            p_old_flow_schedule_rec.scheduled_start_date IS NULL )
    THEN
        IF NOT MRP_Validate.Scheduled_Start_Date(l_flow_schedule_rec.scheduled_start_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.schedule_group_id IS NOT NULL AND
        (   l_flow_schedule_rec.schedule_group_id <>
            p_old_flow_schedule_rec.schedule_group_id OR
            p_old_flow_schedule_rec.schedule_group_id IS NULL )
    THEN
        IF NOT MRP_Validate.Schedule_Group(l_flow_schedule_rec.schedule_group_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.schedule_number IS NOT NULL AND
        (   l_flow_schedule_rec.schedule_number <>
            p_old_flow_schedule_rec.schedule_number OR
            p_old_flow_schedule_rec.schedule_number IS NULL )
    THEN
        IF NOT MRP_Validate.Schedule_Number(l_flow_schedule_rec.schedule_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.status IS NOT NULL AND
        (   l_flow_schedule_rec.status <>
            p_old_flow_schedule_rec.status OR
            p_old_flow_schedule_rec.status IS NULL )
    THEN
        IF NOT MRP_Validate.Status(l_flow_schedule_rec.status) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.std_cost_adjustment_acct IS NOT NULL AND
        (   l_flow_schedule_rec.std_cost_adjustment_acct <>
            p_old_flow_schedule_rec.std_cost_adjustment_acct OR
            p_old_flow_schedule_rec.std_cost_adjustment_acct IS NULL )
    THEN
        IF NOT MRP_Validate.Std_Cost_Adjustment_Acct(l_flow_schedule_rec.std_cost_adjustment_acct) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.task_id IS NOT NULL AND
        (   l_flow_schedule_rec.task_id <>
            p_old_flow_schedule_rec.task_id OR
            p_old_flow_schedule_rec.task_id IS NULL )
    THEN
        IF NOT MRP_Validate.Task(l_flow_schedule_rec.task_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.wip_entity_id IS NOT NULL AND
        (   l_flow_schedule_rec.wip_entity_id <>
            p_old_flow_schedule_rec.wip_entity_id OR
            p_old_flow_schedule_rec.wip_entity_id IS NULL )
    THEN
        IF NOT MRP_Validate.Wip_Entity(l_flow_schedule_rec.wip_entity_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.end_item_unit_number IS NOT NULL AND
        (   l_flow_schedule_rec.end_item_unit_number <>
            p_old_flow_schedule_rec.end_item_unit_number OR
            p_old_flow_schedule_rec.end_item_unit_number IS NULL )
    THEN
        IF NOT MRP_Validate.End_Item_Unit_Number(l_flow_schedule_rec.end_item_unit_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  l_flow_schedule_rec.quantity_scrapped IS NOT NULL AND
        (   l_flow_schedule_rec.quantity_scrapped <>
            p_old_flow_schedule_rec.quantity_scrapped OR
            p_old_flow_schedule_rec.quantity_scrapped IS NULL )
    THEN
        IF NOT MRP_Validate.Quantity_Scrapped(l_flow_schedule_rec.quantity_scrapped) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (l_flow_schedule_rec.attribute1 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute1 <>
            p_old_flow_schedule_rec.attribute1 OR
            p_old_flow_schedule_rec.attribute1 IS NULL ))
    OR  (l_flow_schedule_rec.attribute10 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute10 <>
            p_old_flow_schedule_rec.attribute10 OR
            p_old_flow_schedule_rec.attribute10 IS NULL ))
    OR  (l_flow_schedule_rec.attribute11 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute11 <>
            p_old_flow_schedule_rec.attribute11 OR
            p_old_flow_schedule_rec.attribute11 IS NULL ))
    OR  (l_flow_schedule_rec.attribute12 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute12 <>
            p_old_flow_schedule_rec.attribute12 OR
            p_old_flow_schedule_rec.attribute12 IS NULL ))
    OR  (l_flow_schedule_rec.attribute13 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute13 <>
            p_old_flow_schedule_rec.attribute13 OR
            p_old_flow_schedule_rec.attribute13 IS NULL ))
    OR  (l_flow_schedule_rec.attribute14 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute14 <>
            p_old_flow_schedule_rec.attribute14 OR
            p_old_flow_schedule_rec.attribute14 IS NULL ))
    OR  (l_flow_schedule_rec.attribute15 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute15 <>
            p_old_flow_schedule_rec.attribute15 OR
            p_old_flow_schedule_rec.attribute15 IS NULL ))
    OR  (l_flow_schedule_rec.attribute2 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute2 <>
            p_old_flow_schedule_rec.attribute2 OR
            p_old_flow_schedule_rec.attribute2 IS NULL ))
    OR  (l_flow_schedule_rec.attribute3 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute3 <>
            p_old_flow_schedule_rec.attribute3 OR
            p_old_flow_schedule_rec.attribute3 IS NULL ))
    OR  (l_flow_schedule_rec.attribute4 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute4 <>
            p_old_flow_schedule_rec.attribute4 OR
            p_old_flow_schedule_rec.attribute4 IS NULL ))
    OR  (l_flow_schedule_rec.attribute5 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute5 <>
            p_old_flow_schedule_rec.attribute5 OR
            p_old_flow_schedule_rec.attribute5 IS NULL ))
    OR  (l_flow_schedule_rec.attribute6 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute6 <>
            p_old_flow_schedule_rec.attribute6 OR
            p_old_flow_schedule_rec.attribute6 IS NULL ))
    OR  (l_flow_schedule_rec.attribute7 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute7 <>
            p_old_flow_schedule_rec.attribute7 OR
            p_old_flow_schedule_rec.attribute7 IS NULL ))
    OR  (l_flow_schedule_rec.attribute8 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute8 <>
            p_old_flow_schedule_rec.attribute8 OR
            p_old_flow_schedule_rec.attribute8 IS NULL ))
    OR  (l_flow_schedule_rec.attribute9 IS NOT NULL AND
        (   l_flow_schedule_rec.attribute9 <>
            p_old_flow_schedule_rec.attribute9 OR
            p_old_flow_schedule_rec.attribute9 IS NULL ))
    OR  (l_flow_schedule_rec.attribute_category IS NOT NULL AND
        (   l_flow_schedule_rec.attribute_category <>
            p_old_flow_schedule_rec.attribute_category OR
            p_old_flow_schedule_rec.attribute_category IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => l_flow_schedule_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => l_flow_schedule_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => l_flow_schedule_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => l_flow_schedule_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => l_flow_schedule_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => l_flow_schedule_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => l_flow_schedule_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => l_flow_schedule_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => l_flow_schedule_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => l_flow_schedule_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => l_flow_schedule_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => l_flow_schedule_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => l_flow_schedule_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => l_flow_schedule_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => l_flow_schedule_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE_CATEGORY'
        ,   column_value                  => l_flow_schedule_rec.attribute_category
        );
*/

        --  Validate descriptive flexfield.

        IF NOT MRP_Validate.Desc_Flex( 'WIP_FLOW_SCHEDULE' ) THEN
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
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
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

END MRP_Validate_Flow_Schedule;

/
