--------------------------------------------------------
--  DDL for Package Body MRP_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_VALIDATE" AS
/* $Header: MRPSVATB.pls 115.10 99/07/26 17:07:28 porting ship  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Validate';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Desc_Flex';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'alternate_bom_designator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'alternate_routing_desig';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'bom_revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'bom_revision_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'build_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'completion_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'completion_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'creation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'date_closed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_source_delivery';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'end_item_unit_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity_scrapped ';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_source_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_source_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_source_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_updated_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_login';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'material_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'material_overhead_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'material_variance_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'mps_net_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'mps_scheduled_comp_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'outside_processing_acct';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'outside_proc_var_acct';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overhead_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'overhead_variance_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'planned_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'primary_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_application';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity_completed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'resource_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'resource_variance_account';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'routing_revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'routing_revision_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'scheduled_completion_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'scheduled';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'scheduled_start_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'schedule_group';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'schedule_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'status';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'std_cost_adjustment_acct';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wip_entity';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Assignment_Set';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Assignment';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Sourcing_Rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Receiving_Org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Shipping_Org';
--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.


FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )
RETURN BOOLEAN
IS
BEGIN

    --  Call FND validate API.


    --  This call is temporarily commented out

/*
    IF	FND_FLEX_DESCVAL.Validate_Desccols
        (   appl_short_name               => 'MRP'
        ,   desc_flex_name                => p_flex_name
        )
    THEN
        RETURN TRUE;
    ELSE

        --  Prepare the encoded message by setting it on the message
        --  dictionary stack. Then, add it to the API message list.

        FND_MESSAGE.Set_Encoded(FND_FLEX_DESCVAL.Encoded_Error_Message);

        FND_MSG_PUB.Add;

        --  Derive return status.

        IF FND_FLEX_DESCVAL.value_error OR
            FND_FLEX_DESCVAL.unsupported_error
        THEN

            --  In case of an expected error return FALSE

            RETURN FALSE;

        ELSE

            --  In case of an unexpected error raise an exception.

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

    END IF;
*/

    RETURN TRUE;

END Desc_Flex;

FUNCTION Alternate_Bom_Designator ( p_alternate_bom_designator IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_alternate_bom_designator IS NULL OR
        p_alternate_bom_designator = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_alternate_bom_designator;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ALT_BOM_DESIG');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_alternate_bom_designator);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Alternate_Bom_Designator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Alternate_Bom_Designator;

FUNCTION Alternate_Routing_Desig ( p_alternate_routing_desig IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_alternate_routing_desig IS NULL OR
        p_alternate_routing_desig = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_alternate_routing_desig;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ALT_RTG_DESIG');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_alternate_routing_desig);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Alternate_Routing_Desig'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Alternate_Routing_Desig;

FUNCTION Bom_Revision ( p_bom_revision IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_bom_revision IS NULL OR
        p_bom_revision = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_bom_revision;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_BOM_REV');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_bom_revision);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Bom_Revision'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Bom_Revision;

FUNCTION Bom_Revision_Date ( p_bom_revision_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_bom_revision_date IS NULL OR
        p_bom_revision_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_bom_revision_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','bom_revision_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Bom_Revision_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Bom_Revision_Date;

FUNCTION Build_Sequence ( p_build_sequence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_build_sequence IS NULL OR
        p_build_sequence = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     DUAL
    WHERE    p_build_sequence > 0;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_SEQUENCE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_build_sequence);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Build_Sequence'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Build_Sequence;

FUNCTION Class ( p_class_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_class_code IS NULL OR
        p_class_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_class_code;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_CLASS_CODE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_class_code);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Class;

FUNCTION Completion_Locator ( p_completion_locator_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_completion_locator_id IS NULL OR
        p_completion_locator_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_completion_locator_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_COMP_LOC_ID');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_completion_locator_id);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Completion_Locator'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Completion_Locator;

FUNCTION Completion_Subinventory ( p_completion_subinventory IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_completion_subinventory IS NULL OR
        p_completion_subinventory = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_completion_subinventory;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_COMP_SUBINV');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_completion_subinventory);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Completion_Subinventory'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Completion_Subinventory;

FUNCTION Created_By ( p_created_by IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_created_by IS NULL OR
        p_created_by = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_created_by;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_by');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Created_By'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Created_By;

FUNCTION Creation_Date ( p_creation_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_creation_date IS NULL OR
        p_creation_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_creation_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','creation_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Creation_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Creation_Date;

FUNCTION Date_Closed ( p_date_closed IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_date_closed IS NULL OR
        p_date_closed = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_date_closed;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','date_closed');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Date_Closed'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Date_Closed;

FUNCTION Demand_Class ( p_demand_class IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_class IS NULL OR
        p_demand_class = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     FND_COMMON_LOOKUPS
    WHERE    LOOKUP_CODE = p_demand_class
    AND      LOOKUP_TYPE = 'DEMAND_CLASS'
    AND      ENABLED_FLAG = 'Y'
    AND      SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE) AND
                             NVL(END_DATE_ACTIVE,SYSDATE);

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_DEMAND_CLASS');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_demand_class);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Class'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Class;

FUNCTION Demand_Source_Delivery ( p_demand_source_delivery IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_source_delivery IS NULL OR
        p_demand_source_delivery = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_demand_source_delivery;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_source_delivery');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Source_Delivery'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Source_Delivery;

FUNCTION Demand_Source_Header ( p_demand_source_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_source_header_id IS NULL OR
        p_demand_source_header_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_demand_source_header_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_source_header');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Source_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Source_Header;

FUNCTION Demand_Source_Line ( p_demand_source_line IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_source_line IS NULL OR
        p_demand_source_line = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_demand_source_line;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_source_line');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Source_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Source_Line;

FUNCTION Demand_Source_Type ( p_demand_source_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_demand_source_type IS NULL OR
        p_demand_source_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

--    SELECT  'VALID'
--    INTO     l_dummy
--    FROM     MFG_LOOKUPS
--    WHERE    LOOKUP_CODE = p_demand_source_type
--    AND      LOOKUP_TYPE = 'MTL_SUPPLY_DEMAND_SOURCE_TYPE'
--    AND      ENABLED_FLAG = 'Y'
--    AND      SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
--                     AND NVL(END_DATE_ACTIVE, SYSDATE);

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_source_type');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Source_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Source_Type;

FUNCTION Last_Updated_By ( p_last_updated_by IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_last_updated_by IS NULL OR
        p_last_updated_by = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_updated_by;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_updated_by');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Updated_By'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Updated_By;

FUNCTION Last_Update_Date ( p_last_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_last_update_date IS NULL OR
        p_last_update_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_update_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_update_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Date;

FUNCTION Last_Update_Login ( p_last_update_login IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_last_update_login IS NULL OR
        p_last_update_login = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_update_login;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_update_login');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Login'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Login;

FUNCTION Line ( p_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_line_id IS NULL OR
        p_line_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;

FUNCTION Material_Account ( p_material_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_material_account IS NULL OR
        p_material_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_material_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','material_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Material_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Material_Account;

FUNCTION Material_Overhead_Account ( p_material_overhead_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_material_overhead_account IS NULL OR
        p_material_overhead_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_material_overhead_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','material_overhead_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Material_Overhead_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Material_Overhead_Account;

FUNCTION Material_Variance_Account ( p_material_variance_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_material_variance_account IS NULL OR
        p_material_variance_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_material_variance_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','material_variance_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Material_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Material_Variance_Account;

FUNCTION Mps_Net_Quantity ( p_mps_net_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_mps_net_quantity IS NULL OR
        p_mps_net_quantity = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     DUAL
    WHERE    p_mps_net_quantity >= 0;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_MPS_NET_QTY');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_mps_net_quantity);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Mps_Net_Quantity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Mps_Net_Quantity;

FUNCTION Mps_Scheduled_Comp_Date ( p_mps_scheduled_comp_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_mps_scheduled_comp_date IS NULL OR
        p_mps_scheduled_comp_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_mps_scheduled_comp_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','mps_scheduled_comp_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Mps_Scheduled_Comp_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Mps_Scheduled_Comp_Date;

FUNCTION Organization ( p_organization_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_organization_id IS NULL OR
        p_organization_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mtl_parameters
    WHERE    ORGANIZATION_ID = p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ORG');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_organization_id);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Organization'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Organization;

FUNCTION Outside_Processing_Acct ( p_outside_processing_acct IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_outside_processing_acct IS NULL OR
        p_outside_processing_acct = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_outside_processing_acct;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','outside_processing_acct');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Outside_Processing_Acct'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Outside_Processing_Acct;

FUNCTION Outside_Proc_Var_Acct ( p_outside_proc_var_acct IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_outside_proc_var_acct IS NULL OR
        p_outside_proc_var_acct = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_outside_proc_var_acct;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','outside_proc_var_acct');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Outside_Proc_Var_Acct'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Outside_Proc_Var_Acct;

FUNCTION Overhead_Account ( p_overhead_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overhead_account IS NULL OR
        p_overhead_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_overhead_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','overhead_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overhead_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overhead_Account;

FUNCTION Overhead_Variance_Account ( p_overhead_variance_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_overhead_variance_account IS NULL OR
        p_overhead_variance_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_overhead_variance_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','overhead_variance_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Overhead_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Overhead_Variance_Account;

FUNCTION Planned_Quantity ( p_planned_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_planned_quantity IS NULL OR
        p_planned_quantity = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     DUAL
    WHERE    p_planned_quantity >= 0;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_PLANNED_QTY');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_planned_quantity);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Planned_Quantity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Planned_Quantity;

FUNCTION Primary_Item ( p_primary_item_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_primary_item_id IS NULL OR
        p_primary_item_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_primary_item_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_item');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Primary_Item'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Primary_Item;

FUNCTION Program_Application ( p_program_application_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_program_application_id IS NULL OR
        p_program_application_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_application_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','program_application');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program_Application'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program_Application;

FUNCTION Program ( p_program_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_program_id IS NULL OR
        p_program_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','program');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program;

FUNCTION Program_Update_Date ( p_program_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_program_update_date IS NULL OR
        p_program_update_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_update_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','program_update_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program_Update_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program_Update_Date;

FUNCTION Project ( p_project_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_project_id IS NULL OR
        p_project_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     MTL_PROJECT_V
    WHERE    PROJECT_ID = p_project_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_PROJECT');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_project_id);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Project'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project;

FUNCTION Quantity_Completed ( p_quantity_completed IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_quantity_completed IS NULL OR
        p_quantity_completed = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     DUAL
    WHERE    p_quantity_completed >= 0;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_QTY_COMPLETED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_quantity_completed);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Quantity_Completed'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Quantity_Completed;

FUNCTION Request ( p_request_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_request_id IS NULL OR
        p_request_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','request');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request;

FUNCTION Resource_Account ( p_resource_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_resource_account IS NULL OR
        p_resource_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_resource_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','resource_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Resource_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Resource_Account;

FUNCTION Resource_Variance_Account ( p_resource_variance_account IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_resource_variance_account IS NULL OR
        p_resource_variance_account = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_resource_variance_account;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','resource_variance_account');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Resource_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Resource_Variance_Account;

FUNCTION Routing_Revision ( p_routing_revision IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_routing_revision IS NULL OR
        p_routing_revision = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_routing_revision;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','routing_revision');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Routing_Revision'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Routing_Revision;

FUNCTION Routing_Revision_Date ( p_routing_revision_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_routing_revision_date IS NULL OR
        p_routing_revision_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_routing_revision_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','routing_revision_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Routing_Revision_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Routing_Revision_Date;

FUNCTION Scheduled_Completion_Date ( p_scheduled_completion_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_scheduled_completion_date IS NULL OR
        p_scheduled_completion_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_scheduled_completion_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','scheduled_completion_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Scheduled_Completion_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Scheduled_Completion_Date;

FUNCTION Scheduled ( p_scheduled_flag IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_scheduled_flag IS NULL OR
        p_scheduled_flag = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     DUAL
    WHERE    p_scheduled_flag in (1,2,3);

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_SCH_FLAG');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_scheduled_flag);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Scheduled'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Scheduled;

FUNCTION Scheduled_Start_Date ( p_scheduled_start_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_scheduled_start_date IS NULL OR
        p_scheduled_start_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_scheduled_start_date;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','scheduled_start_date');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Scheduled_Start_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Scheduled_Start_Date;

FUNCTION Schedule_Group ( p_schedule_group_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_schedule_group_id IS NULL OR
        p_schedule_group_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_schedule_group_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','schedule_group');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Group'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_Group;

FUNCTION Schedule_Number ( p_schedule_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_schedule_number IS NULL OR
        p_schedule_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_schedule_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','schedule_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_Number;

FUNCTION Status ( p_status IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_status IS NULL OR
        p_status = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_status;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_STATUS');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_status);
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Status'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Status;

FUNCTION Std_Cost_Adjustment_Acct ( p_std_cost_adjustment_acct IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_std_cost_adjustment_acct IS NULL OR
        p_std_cost_adjustment_acct = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_std_cost_adjustment_acct;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','std_cost_adjustment_acct');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Std_Cost_Adjustment_Acct'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Std_Cost_Adjustment_Acct;

FUNCTION Task ( p_task_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_task_id IS NULL OR
        p_task_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_task_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task;

FUNCTION Wip_Entity ( p_wip_entity_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_wip_entity_id IS NULL OR
        p_wip_entity_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    -- SELECT  'VALID'
    -- INTO     l_dummy
    -- FROM     WIP_ENTITIES
    -- WHERE    WIP_ENTITY_ID = p_wip_entity_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Wip_Entity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wip_Entity;




FUNCTION End_Item_Unit_Number ( p_end_item_unit_number in VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_end_item_unit_number IS NULL OR
        p_end_item_unit_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM    DUAL
    WHERE    EXISTS (
    SELECT UNIT_NUMBER FROM pjm_unit_numbers_lov_v
    WHERE UNIT_NUMBER = p_end_item_unit_number);

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_UNIT_NUMBER');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_item_unit_number');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_Item_Unit_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END End_Item_Unit_Number;


FUNCTION Quantity_Scrapped  ( p_quantity_scrapped  in NUMBER)
RETURN BOOLEAN
IS
BEGIN

    IF p_quantity_scrapped IS NULL OR
        p_quantity_scrapped = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','quantity_scrapped');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'quantity_scrapped'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Quantity_Scrapped;

FUNCTION Assignment_Set
(   p_Assignment_Set_Id             IN  NUMBER
)   RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF  (p_Assignment_Set_Id IS NULL OR
        p_Assignment_Set_Id = FND_API.G_MISS_NUM)
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_KEY');
            FND_MESSAGE.SET_TOKEN('KEY','Assignment_Set');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Assignment_Set'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Assignment_Set;

FUNCTION Assignment
(   p_Assignment_Id                 IN  NUMBER
)   RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF  (p_Assignment_Id IS NULL OR
        p_Assignment_Id = FND_API.G_MISS_NUM)
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_KEY');
            FND_MESSAGE.SET_TOKEN('KEY','Assignment');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Assignment'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Assignment;

FUNCTION Sourcing_Rule
(   p_Sourcing_Rule_Id              IN  NUMBER
)   RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF  (p_Sourcing_Rule_Id IS NULL OR
        p_Sourcing_Rule_Id = FND_API.G_MISS_NUM)
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_KEY');
            FND_MESSAGE.SET_TOKEN('KEY','Sourcing_Rule');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sourcing_Rule'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sourcing_Rule;

FUNCTION Receiving_Org
(   p_Sr_Receipt_Id                 IN  NUMBER
)   RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF  (p_Sr_Receipt_Id IS NULL OR
        p_Sr_Receipt_Id = FND_API.G_MISS_NUM)
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_KEY');
            FND_MESSAGE.SET_TOKEN('KEY','Receiving_Org');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Receiving_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Receiving_Org;

FUNCTION Shipping_Org
(   p_Sr_Source_Id                  IN  NUMBER
)   RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF  (p_Sr_Source_Id IS NULL OR
        p_Sr_Source_Id = FND_API.G_MISS_NUM)
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_KEY');
            FND_MESSAGE.SET_TOKEN('KEY','Shipping_Org');
            FND_MSG_PUB.Add;

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Org;
--  END GEN validate

END MRP_Validate;

/
