--------------------------------------------------------
--  DDL for Package Body MRP_DEFAULT_FLOW_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_DEFAULT_FLOW_SCHEDULE" AS
/* $Header: MRPDSCNB.pls 120.1 2005/08/30 15:49:51 yulin noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Default_Flow_Schedule';

--  Package global used within the package.
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/
g_flow_schedule_rec           MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;

--  Get functions.

FUNCTION Get_Alternate_Bom_Designator
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Alternate_Bom_Designator;

FUNCTION Get_Alternate_Routing_Desig
RETURN VARCHAR2
IS

  CURSOR C1(p_item_id	IN	NUMBER,
	p_org_id	IN	NUMBER,
	p_line_id	IN	NUMBER) IS
  SELECT alternate_routing_designator
  FROM bom_operational_routings
  WHERE line_id = p_line_id
  AND assembly_item_id = p_item_id
  AND organization_id = p_org_id
  AND cfm_routing_flag = 1
  ORDER BY alternate_routing_designator desc;

  l_alt_rtg_desig	VARCHAR2(10);

BEGIN

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.line_id IS NOT NULL AND
        g_flow_schedule_rec.line_id <> FND_API.G_MISS_NUM
    THEN

        OPEN C1(g_flow_schedule_rec.primary_item_id,
		g_flow_schedule_rec.organization_id,
		g_flow_schedule_rec.line_id);
        LOOP
            FETCH C1 into l_alt_rtg_desig;
            /* We just want one row so exit */
            EXIT;
        END LOOP;
        CLOSE C1;

        RETURN l_alt_rtg_desig;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        RETURN NULL;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Alternate_Routing_Desig'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Alternate_Routing_Desig;

FUNCTION Get_Bom_Revision
RETURN VARCHAR2
IS
l_bom_revision		VARCHAR(3) := NULL;
l_revision		VARCHAR(3) := NULL;
l_error_number 		NUMBER := 1;
l_revision_date		DATE := NULL;
BEGIN

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.scheduled_completion_date IS NOT NULL AND
        g_flow_schedule_rec.scheduled_completion_date <> FND_API.G_MISS_DATE
    THEN

        IF g_flow_schedule_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
            l_revision_date := NULL;
        ELSE
            l_revision_date := g_flow_schedule_rec.bom_revision_date;
        END IF;

        l_error_number := WIP_FLOW_DERIVE.Bom_Revision(
				l_bom_revision,
				l_revision,
				l_revision_date,
				g_flow_schedule_rec.primary_item_id,
				g_flow_schedule_rec.scheduled_completion_date,
 				g_flow_schedule_rec.organization_id
			  );

        IF l_error_number = 1 THEN

            RETURN l_bom_revision;

        ELSE

            -- If we couldn't retrieve the BOM, we don't care because
            -- it is not a required field so we just return null.
            RETURN NULL;

        END IF;

    ELSE

        RETURN NULL;

    END IF;

END Get_Bom_Revision;

FUNCTION Get_Bom_Revision_Date
RETURN DATE
IS
l_bom_revision		VARCHAR(3) := NULL;
l_revision		VARCHAR(3) := NULL;
l_error_number 		NUMBER := 1;
l_revision_date		DATE := NULL;
BEGIN

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.scheduled_completion_date IS NOT NULL AND
        g_flow_schedule_rec.scheduled_completion_date <> FND_API.G_MISS_DATE
    THEN

        /* Fix for bug 2977987: Initialized l_revision_date instead of
           l_bom_revision so that scheduled_completion_date is returned
           instead of sysdate */

        IF g_flow_schedule_rec.bom_revision_date = FND_API.G_MISS_DATE THEN
            l_revision_date := NULL;
        ELSE
            l_revision_date := g_flow_schedule_rec.bom_revision_date;
        END IF;

        l_error_number := WIP_FLOW_DERIVE.Bom_Revision(
				l_bom_revision,
				l_revision,
				l_revision_date,
				g_flow_schedule_rec.primary_item_id,
				g_flow_schedule_rec.scheduled_completion_date,
 				g_flow_schedule_rec.organization_id
			  );

        -- revision_date should be null if revision is null
        IF (l_error_number = 1 and l_bom_revision is not null) THEN

            RETURN l_revision_date;

        ELSE

            -- If we couldn't retrieve the BOM, we don't care because
            -- it is not a required field so we just return null.
            RETURN NULL;

        END IF;

    ELSE

        RETURN NULL;

    END IF;

END Get_Bom_Revision_Date;

FUNCTION Get_Build_Sequence
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Build_Sequence;

FUNCTION Get_Class
RETURN VARCHAR2
IS
l_class_code        VARCHAR2(10) := NULL;
l_project_id        NUMBER := NULL;
l_project_name      VARCHAR2(30) := NULL;
l_error_number      NUMBER := 1;
l_err_mesg          VARCHAR2(80) := NULL;
l_default_class     VARCHAR2(10) := NULL;
BEGIN

    -- Use wip procedure to get class code.  Class code is dependent
    -- on item, organization, and project.

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        IF g_flow_schedule_rec.project_id = FND_API.G_MISS_NUM THEN
            l_project_id := NULL;
        ELSE
            l_project_id := g_flow_schedule_rec.project_id;
        END IF;

        -- If the project is defined then we need to have a class code
        -- defined at the project level.
        -- If not, raise an expected error to the user.
        IF l_project_id IS NOT NULL THEN
          BEGIN

            SELECT wip_acct_class_code, project_number
            INTO l_class_code, l_project_name
            FROM mrp_project_parameters_v
            WHERE project_id = l_project_id
            AND organization_id = g_flow_schedule_rec.organization_id;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN

              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN

                FND_MESSAGE.SET_NAME('MRP','MRP_NO_PROJ_CLASS_CODE');
                FND_MESSAGE.SET_TOKEN('PROJECT',l_project_name);
                FND_MSG_PUB.Add;

                RAISE FND_API.G_EXC_ERROR;

              END IF;

          END;

        END IF;

        l_error_number := WIP_FLOW_DERIVE.Class_Code(l_class_code,
				l_err_mesg,
				g_flow_schedule_rec.organization_id,
				g_flow_schedule_rec.primary_item_id,
				4,
				l_project_id);

        IF l_error_number = 1 THEN

             RETURN l_class_code;

        ELSE

            -- If the procedure returns with error, then was it
            -- because there is no default defined at the org level.
            -- If so, raise an expected error to the user.
            BEGIN

                SELECT default_discrete_class
                INTO l_default_class
                FROM wip_parameters
                WHERE organization_id = g_flow_schedule_rec.organization_id;

                RETURN l_default_class;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN

                    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN

                        FND_MESSAGE.SET_NAME('MRP','MRP-NO_DEFAULT_CLASS');
                        FND_MSG_PUB.Add;

                    END IF;

                    RAISE FND_API.G_EXC_ERROR;

                WHEN OTHERS THEN

                    -- l_err_mesg is not used because class code procedure
                    -- returns translated message

                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                    THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME,
                            'Get_Class: '||l_err_mesg
                        );
                    END IF;

                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END;

        END IF;

    ELSE

        RETURN NULL;

    END IF;

END Get_Class;

FUNCTION Get_Completion_Locator
RETURN NUMBER
IS
l_alt_routing		VARCHAR(10) := NULL;
l_subinventory		VARCHAR(10) := NULL;
l_locator_id		NUMBER := NULL;
l_error_number		NUMBER := 1;
BEGIN

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        IF g_flow_schedule_rec.alternate_routing_desig = FND_API.G_MISS_CHAR
        THEN
            l_alt_routing := NULL;
        ELSE
            l_alt_routing := g_flow_schedule_rec.alternate_routing_desig;
        END IF;

        l_error_number := WIP_FLOW_DERIVE.Routing_Completion_Sub_Loc(
				l_subinventory,
				l_locator_id,
				g_flow_schedule_rec.primary_item_id,
 				g_flow_schedule_rec.organization_id,
                                l_alt_routing
			  );

        IF l_error_number = 1 THEN

            RETURN l_locator_id;

        ELSE

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    'Get_Completion_Locator'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

    ELSE

        RETURN NULL;

    END IF;

END Get_Completion_Locator;

FUNCTION Get_Completion_Subinventory
RETURN VARCHAR2
IS
l_alt_routing		VARCHAR(10) := NULL;
l_subinventory		VARCHAR(10) := NULL;
l_locator_id		NUMBER := NULL;
l_error_number		NUMBER := 1;
BEGIN

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        IF g_flow_schedule_rec.alternate_routing_desig = FND_API.G_MISS_CHAR
        THEN
            l_alt_routing := NULL;
        ELSE
            l_alt_routing := g_flow_schedule_rec.alternate_routing_desig;
        END IF;

        l_error_number := WIP_FLOW_DERIVE.Routing_Completion_Sub_Loc(
				l_subinventory,
				l_locator_id,
				g_flow_schedule_rec.primary_item_id,
 				g_flow_schedule_rec.organization_id,
                                l_alt_routing
			  );

        IF l_error_number = 1 THEN

            RETURN l_subinventory;

        ELSE

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    'Get_Completion_Subinventory'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

    ELSE

        RETURN NULL;

    END IF;

END Get_Completion_Subinventory;

FUNCTION Get_Date_Closed
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Date_Closed;

FUNCTION Get_Demand_Class
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Demand_Class;

FUNCTION Get_Demand_Source_Delivery
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Demand_Source_Delivery;

FUNCTION Get_Demand_Source_Header
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Demand_Source_Header;

FUNCTION Get_Demand_Source_Line
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Demand_Source_Line;

FUNCTION Get_Demand_Source_Type
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Demand_Source_Type;

FUNCTION Get_Line
RETURN NUMBER
IS
  l_line_id	NUMBER;
BEGIN

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN
      SELECT line_id
      INTO l_line_id
      FROM bom_operational_routings
      WHERE cfm_routing_flag = 1
        AND ((alternate_routing_designator IS NULL) OR
		(alternate_routing_designator IS NOT NULL
		AND priority = (SELECT min(priority)
		FROM bom_operational_routings
		WHERE cfm_routing_flag = 1
                  AND assembly_item_id = g_flow_schedule_rec.primary_item_id
                  AND organization_id = g_flow_schedule_rec.organization_id
                  AND NOT EXISTS (SELECT line_id FROM bom_operational_routings
              		WHERE cfm_routing_flag = 1
			AND alternate_routing_designator IS NULL
                        AND assembly_item_id = g_flow_schedule_rec.primary_item_id
                        AND organization_id = g_flow_schedule_rec.organization_id
			))))
        AND assembly_item_id = g_flow_schedule_rec.primary_item_id
        AND organization_id = g_flow_schedule_rec.organization_id;

      RETURN l_line_id;

    ELSE

       RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        RETURN NULL;

END Get_Line;

FUNCTION Get_Material_Account
RETURN NUMBER
IS
l_material_account	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT MATERIAL_ACCOUNT
        INTO l_material_account
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_material_account;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Material_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Material_Account;

FUNCTION Get_Material_Overhead_Account
RETURN NUMBER
IS
l_material_overhead_account	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT MATERIAL_OVERHEAD_ACCOUNT
        INTO l_material_overhead_account
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_material_overhead_account;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Material_Overhead_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Material_Overhead_Account;

FUNCTION Get_Material_Variance_Account
RETURN NUMBER
IS
l_material_variance_account	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT MATERIAL_VARIANCE_ACCOUNT
        INTO l_material_variance_account
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_material_variance_account;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Material_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Material_Variance_Account;

FUNCTION Get_Mps_Net_Quantity
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Mps_Net_Quantity;

FUNCTION Get_Mps_Scheduled_Comp_Date
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Mps_Scheduled_Comp_Date;

FUNCTION Get_Organization
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Organization;

FUNCTION Get_Outside_Processing_Acct
RETURN NUMBER
IS
l_outside_processing_acct	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT OUTSIDE_PROCESSING_ACCOUNT
        INTO l_outside_processing_acct
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_outside_processing_acct;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Outside_Processing_Acct'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Outside_Processing_Acct;

FUNCTION Get_Outside_Proc_Var_Acct
RETURN NUMBER
IS
l_outside_proc_var_acct		NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT OUTSIDE_PROC_VARIANCE_ACCOUNT
        INTO l_outside_proc_var_acct
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_outside_proc_var_acct;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Outside_Proc_Var_Acct'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Outside_Proc_Var_Acct;

FUNCTION Get_Overhead_Account
RETURN NUMBER
IS
l_overhead_account	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT OVERHEAD_ACCOUNT
        INTO l_overhead_account
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_overhead_account;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Overhead_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Overhead_Account;

FUNCTION Get_Overhead_Variance_Account
RETURN NUMBER
IS
l_overhead_variance_account	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT OVERHEAD_VARIANCE_ACCOUNT
        INTO l_overhead_variance_account
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_overhead_variance_account;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Overhead_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Overhead_Variance_Account;

FUNCTION Get_Planned_Quantity
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Planned_Quantity;

FUNCTION Get_Primary_Item
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Primary_Item;

FUNCTION Get_Project
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Project;

FUNCTION Get_Quantity_Completed
RETURN NUMBER
IS
BEGIN

    RETURN 0;

END Get_Quantity_Completed;

FUNCTION Get_Request_Id
RETURN NUMBER
IS
  l_request_id		NUMBER := 0;
BEGIN

    SELECT USERENV( 'SESSIONID' )
    INTO l_request_id
    FROM DUAL;

    RETURN l_request_id;

END Get_Request_Id;

FUNCTION Get_Resource_Account
RETURN NUMBER
IS
l_resource_account	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT RESOURCE_ACCOUNT
        INTO l_resource_account
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_resource_account;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Resource_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Resource_Account;

FUNCTION Get_Resource_Variance_Account
RETURN NUMBER
IS
l_resource_variance_account	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT RESOURCE_VARIANCE_ACCOUNT
        INTO l_resource_variance_account
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_resource_variance_account;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Resource_Variance_Account'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Resource_Variance_Account;

FUNCTION Get_Routing_Revision
RETURN VARCHAR2
IS
l_routing_revision	VARCHAR(3) := NULL;
l_error_number		NUMBER := 1;
l_revision_date 	DATE := NULL;
BEGIN

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.scheduled_completion_date IS NOT NULL AND
        g_flow_schedule_rec.scheduled_completion_date <> FND_API.G_MISS_DATE
    THEN

        IF g_flow_schedule_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
            l_revision_date := NULL;
        ELSE
            l_revision_date := g_flow_schedule_rec.routing_revision_date;
        END IF;

        l_error_number := WIP_FLOW_DERIVE.Routing_Revision(
				l_routing_revision,
				l_revision_date,
				g_flow_schedule_rec.primary_item_id,
				g_flow_schedule_rec.scheduled_completion_date,
 				g_flow_schedule_rec.organization_id
			  );

        IF l_error_number = 1 THEN

            RETURN l_routing_revision;

        ELSIF l_routing_revision IS NULL THEN

            RETURN NULL;

        END IF;

    ELSE

        RETURN NULL;

    END IF;

END Get_Routing_Revision;


FUNCTION Get_Routing_Revision_Date
RETURN DATE
IS
l_routing_revision	VARCHAR(3) := NULL;
l_error_number		NUMBER := 1;
l_revision_date 	DATE := NULL;
BEGIN

    IF g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.scheduled_completion_date IS NOT NULL AND
        g_flow_schedule_rec.scheduled_completion_date <> FND_API.G_MISS_DATE
    THEN

        IF g_flow_schedule_rec.routing_revision_date = FND_API.G_MISS_DATE THEN
            l_revision_date := NULL;
        ELSE
            l_revision_date := g_flow_schedule_rec.routing_revision_date;
        END IF;

        l_error_number := WIP_FLOW_DERIVE.Routing_Revision(
				l_routing_revision,
				l_revision_date,
				g_flow_schedule_rec.primary_item_id,
				g_flow_schedule_rec.scheduled_completion_date,
 				g_flow_schedule_rec.organization_id
			  );

        -- revision_date should be null, if revision is null
        IF (l_error_number = 1 and l_routing_revision is not null) THEN

            RETURN l_revision_date;

        ELSE
            RETURN NULL;

        END IF;

    ELSE

        RETURN NULL;

    END IF;

END Get_Routing_Revision_Date;


FUNCTION Get_Scheduled_Completion_Date
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Scheduled_Completion_Date;

FUNCTION Get_Scheduled
RETURN NUMBER
IS
BEGIN

    -- Return yes (1)
    RETURN 1;

END Get_Scheduled;

FUNCTION Get_Scheduled_Start_Date
RETURN DATE
IS
l_variable_lead_time		NUMBER := 0;
l_fixed_lead_time		NUMBER := 0;
l_temp_date			DATE;
l_lead_time                     NUMBER := 0;
l_start_time                    NUMBER;
l_end_time                      NUMBER;
l_completion_date_time		DATE;
l_completion_date		DATE;
l_completion_time		NUMBER;
l_new_end_time			NUMBER;

BEGIN

    IF g_flow_schedule_rec.scheduled_completion_date IS NOT NULL AND
        g_flow_schedule_rec.scheduled_completion_date <> FND_API.G_MISS_DATE AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.primary_item_id IS NOT NULL AND
        g_flow_schedule_rec.primary_item_id <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.planned_quantity IS NOT NULL AND
        g_flow_schedule_rec.planned_quantity <> FND_API.G_MISS_NUM AND
        g_flow_schedule_rec.line_id IS NOT NULL AND
        g_flow_schedule_rec.line_id <> FND_API.G_MISS_NUM
    THEN

        SELECT NVL(FIXED_LEAD_TIME,0),
		NVL(VARIABLE_LEAD_TIME,0)
	INTO l_fixed_lead_time, l_variable_lead_time
        FROM MTL_SYSTEM_ITEMS
        WHERE INVENTORY_ITEM_ID = g_flow_schedule_rec.primary_item_id
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        SELECT start_time, stop_time
        INTO   l_start_time, l_end_time
        FROM   wip_lines
        WHERE  line_id = g_flow_schedule_rec.line_id
        AND  organization_id = g_flow_schedule_rec.organization_id;

        --fix bug#3827600
        if (l_end_time < l_start_time) then
          l_new_end_time := 86400+l_end_time;
        else
          l_new_end_time := l_end_time;
        end if;

        l_completion_date := trunc(g_flow_schedule_rec.scheduled_completion_date);
	l_completion_time := to_char(g_flow_schedule_rec.scheduled_completion_date,'SSSSS');

	if (l_completion_time > l_new_end_time) then
   	  l_completion_date_time := l_completion_date + (l_new_end_time/86400);

	elsif (l_completion_time < l_start_time) then
	  l_completion_date := mrp_calendar.prev_work_day(
				g_flow_schedule_rec.organization_id,
				1,
				flm_timezone.server_to_calendar(l_completion_date)-1);

          l_completion_date := flm_timezone.calendar_to_server(l_completion_date,l_completion_time);
          l_completion_date_time := trunc(l_completion_date) + (l_new_end_time/86400);

        else
          l_completion_date_time := l_completion_date + (l_completion_time/86400);

	end if;
        --end of fix bug#3827600

        l_lead_time := l_fixed_lead_time + (l_variable_lead_time *
                       (g_flow_schedule_rec.planned_quantity-1));

        l_temp_date := MRP_LINE_SCHEDULE_ALGORITHM.calculate_begin_time(
                                g_flow_schedule_rec.organization_id,
                                l_completion_date_time,
                                l_lead_time,
                                l_start_time,
                                l_new_end_time);

        RETURN l_temp_date;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Scheduled_Start_Date'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Scheduled_Start_Date;

FUNCTION Get_Schedule_Group
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Schedule_Group;

FUNCTION Get_Schedule_Number
RETURN VARCHAR2
IS
l_schedule_number	VARCHAR2(30) := NULL;
l_error_number		NUMBER := 1;
BEGIN

    l_error_number := WIP_FLOW_DERIVE.Schedule_Number(l_schedule_number);

    IF l_error_number = 1 THEN

        RETURN l_schedule_number;

    ELSE

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Schedule_Number'
             );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        RETURN NULL;

    END IF;

END Get_Schedule_Number;

FUNCTION Get_Status
RETURN NUMBER
IS
BEGIN

    -- Return Open (1)
    RETURN 1;

END Get_Status;

FUNCTION Get_Std_Cost_Adjustment_Acct
RETURN NUMBER
IS
l_std_cost_adjustment_acct	NUMBER := NULL;
BEGIN

    IF g_flow_schedule_rec.class_code IS NOT NULL AND
	g_flow_schedule_rec.class_code <> FND_API.G_MISS_CHAR AND
        g_flow_schedule_rec.organization_id IS NOT NULL AND
        g_flow_schedule_rec.organization_id <> FND_API.G_MISS_NUM
    THEN

        SELECT STD_COST_ADJUSTMENT_ACCOUNT
        INTO l_std_cost_adjustment_acct
        FROM WIP_ACCOUNTING_CLASSES
        WHERE CLASS_CODE = g_flow_schedule_rec.class_code
        AND ORGANIZATION_ID = g_flow_schedule_rec.organization_id;

        RETURN l_std_cost_adjustment_acct;

    ELSE

        RETURN NULL;

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Std_Cost_Adjustment_Acct'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Std_Cost_Adjustment_Acct;

FUNCTION Get_Task
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Task;

FUNCTION Get_Wip_Entity
RETURN NUMBER
IS
l_wip_entity_id		NUMBER := NULL;
BEGIN

    -- Select from sequence
    SELECT WIP_ENTITIES_S.nextval
    INTO l_wip_entity_id
    FROM DUAL;

    RETURN l_wip_entity_id;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
                'Get_Wip_Entity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Wip_Entity;




FUNCTION Get_End_Item_Unit_Number
RETURN NUMBER
IS
BEGIN
RETURN NULL;

END Get_End_Item_Unit_Number;

FUNCTION Get_Quantity_Scrapped
RETURN NUMBER
IS
BEGIN
RETURN 0;

END Get_Quantity_Scrapped;

PROCEDURE Get_Flex_Wip_Flow_Schedule
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_flow_schedule_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute1 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute10 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute11 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute12 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute13 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute14 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute15 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute2 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute3 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute4 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute5 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute6 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute7 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute8 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute9 := NULL;
    END IF;

    IF g_flow_schedule_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_flow_schedule_rec.attribute_category := NULL;
    END IF;

END Get_Flex_Wip_Flow_Schedule;

--  Procedure Attributes

PROCEDURE Attributes
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_iteration                     IN  NUMBER DEFAULT NULL
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
)
IS
	l_old_flow_schedule_rec     MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type;
BEGIN

    --  Check number of iterations.
    -- If p_iteration is null, default to 1
    IF nvl(p_iteration, 1) > MRP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;
    --  Initialize g_flow_schedule_rec

    g_flow_schedule_rec := p_flow_schedule_rec;

    --  Default missing attributes.

    IF g_flow_schedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR or g_flow_schedule_rec.alternate_bom_designator IS NULL THEN

        g_flow_schedule_rec.alternate_bom_designator := Get_Alternate_Bom_Designator;

        IF g_flow_schedule_rec.alternate_bom_designator IS NOT NULL THEN

            IF MRP_Validate.Alternate_Bom_Designator(g_flow_schedule_rec.alternate_bom_designator)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_ALTERNATE_BOM_DESIGNATOR
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.alternate_bom_designator := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.alternate_routing_desig = FND_API.G_MISS_CHAR or g_flow_schedule_rec.alternate_routing_desig IS NULL THEN

        g_flow_schedule_rec.alternate_routing_desig := Get_Alternate_Routing_Desig;

        IF g_flow_schedule_rec.alternate_routing_desig IS NOT NULL THEN

            IF MRP_Validate.Alternate_Routing_Desig(g_flow_schedule_rec.alternate_routing_desig)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_ALTERNATE_ROUTING_DESIG
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.alternate_routing_desig := NULL;
            END IF;

        END IF;

    END IF;

/* Fix for bug 2977987: Moved this code to ensure that bom_revision is calculated after calculating
   bom_revision_date

    IF g_flow_schedule_rec.bom_revision = FND_API.G_MISS_CHAR  OR g_flow_schedule_rec.bom_revision  IS NULL THEN

        g_flow_schedule_rec.bom_revision := Get_Bom_Revision;

        IF g_flow_schedule_rec.bom_revision IS NOT NULL THEN

            IF MRP_Validate.Bom_Revision(g_flow_schedule_rec.bom_revision)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_BOM_REVISION
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.bom_revision := NULL;
            END IF;

        END IF;

    END IF;
*/

    IF g_flow_schedule_rec.bom_revision_date = FND_API.G_MISS_DATE OR g_flow_schedule_rec.bom_revision_date  IS NULL THEN

        g_flow_schedule_rec.bom_revision_date := Get_Bom_Revision_Date;

        IF g_flow_schedule_rec.bom_revision_date IS NOT NULL THEN

            IF MRP_Validate.Bom_Revision_Date(g_flow_schedule_rec.bom_revision_date)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_BOM_REVISION_DATE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.bom_revision_date := NULL;
            END IF;

        END IF;

    END IF;

    /* Fix for bug 2977987: bom_revision is being calculated after calculating bom_revision_date. */

    IF g_flow_schedule_rec.bom_revision = FND_API.G_MISS_CHAR  OR g_flow_schedule_rec.bom_revision  IS NULL THEN

        g_flow_schedule_rec.bom_revision := Get_Bom_Revision;

        IF g_flow_schedule_rec.bom_revision IS NOT NULL THEN

            IF MRP_Validate.Bom_Revision(g_flow_schedule_rec.bom_revision)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_BOM_REVISION
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
                ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.bom_revision := NULL;
            END IF;

        END IF;

    END IF;


    IF g_flow_schedule_rec.build_sequence = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.build_sequence IS NULL THEN

        g_flow_schedule_rec.build_sequence := Get_Build_Sequence;

        IF g_flow_schedule_rec.build_sequence IS NOT NULL THEN

            IF MRP_Validate.Build_Sequence(g_flow_schedule_rec.build_sequence)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_BUILD_SEQUENCE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.build_sequence := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.class_code = FND_API.G_MISS_CHAR OR g_flow_schedule_rec.class_code IS NULL THEN

        g_flow_schedule_rec.class_code := Get_Class;

        IF g_flow_schedule_rec.class_code IS NOT NULL THEN

            IF MRP_Validate.Class(g_flow_schedule_rec.class_code)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_CLASS
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.class_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.completion_locator_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.completion_locator_id IS NULL THEN

        g_flow_schedule_rec.completion_locator_id := Get_Completion_Locator;

        IF g_flow_schedule_rec.completion_locator_id IS NOT NULL THEN

            IF MRP_Validate.Completion_Locator(g_flow_schedule_rec.completion_locator_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_COMPLETION_LOCATOR
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.completion_locator_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.completion_subinventory = FND_API.G_MISS_CHAR  OR g_flow_schedule_rec.completion_subinventory IS NULL THEN

        g_flow_schedule_rec.completion_subinventory := Get_Completion_Subinventory;

        IF g_flow_schedule_rec.completion_subinventory IS NOT NULL THEN

            IF MRP_Validate.Completion_Subinventory(g_flow_schedule_rec.completion_subinventory)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_COMPLETION_SUBINVENTORY
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.completion_subinventory := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.date_closed = FND_API.G_MISS_DATE  OR g_flow_schedule_rec.date_closed IS NULL THEN

        g_flow_schedule_rec.date_closed := Get_Date_Closed;

        IF g_flow_schedule_rec.date_closed IS NOT NULL THEN

            IF MRP_Validate.Date_Closed(g_flow_schedule_rec.date_closed)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_DATE_CLOSED
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.date_closed := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.demand_class = FND_API.G_MISS_CHAR  OR g_flow_schedule_rec.demand_class IS NULL THEN

        g_flow_schedule_rec.demand_class := Get_Demand_Class;

        IF g_flow_schedule_rec.demand_class IS NOT NULL THEN

            IF MRP_Validate.Demand_Class(g_flow_schedule_rec.demand_class)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_DEMAND_CLASS
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.demand_class := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.end_item_unit_number = FND_API.G_MISS_CHAR  OR g_flow_schedule_rec.end_item_unit_number IS NULL THEN

        g_flow_schedule_rec.end_item_unit_number := Get_end_item_unit_number;

        IF g_flow_schedule_rec.end_item_unit_number IS NOT NULL THEN

            IF MRP_Validate.end_item_unit_number(g_flow_schedule_rec.end_item_unit_number)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_END_ITEM_UNIT_NUMBER
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.end_item_unit_number := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.quantity_scrapped = FND_API.G_MISS_NUM or g_flow_schedule_rec.quantity_scrapped IS NULL THEN

        g_flow_schedule_rec.quantity_scrapped := Get_quantity_scrapped;

        IF g_flow_schedule_rec.quantity_scrapped IS NOT NULL THEN

            IF MRP_Validate.quantity_scrapped(g_flow_schedule_rec.quantity_scrapped)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_quantity_scrapped
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.quantity_scrapped := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.demand_source_delivery = FND_API.G_MISS_CHAR OR  g_flow_schedule_rec.demand_source_delivery IS NULL THEN

        g_flow_schedule_rec.demand_source_delivery := Get_Demand_Source_Delivery;

        IF g_flow_schedule_rec.demand_source_delivery IS NOT NULL THEN

            IF MRP_Validate.Demand_Source_Delivery(g_flow_schedule_rec.demand_source_delivery)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_DEMAND_SOURCE_DELIVERY
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.demand_source_delivery := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.demand_source_header_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.demand_source_header_id IS NULL THEN

        g_flow_schedule_rec.demand_source_header_id := Get_Demand_Source_Header;

        IF g_flow_schedule_rec.demand_source_header_id IS NOT NULL THEN

            IF MRP_Validate.Demand_Source_Header(g_flow_schedule_rec.demand_source_header_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_DEMAND_SOURCE_HEADER
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.demand_source_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.demand_source_line = FND_API.G_MISS_CHAR  OR g_flow_schedule_rec.demand_source_line IS NULL THEN

        g_flow_schedule_rec.demand_source_line := Get_Demand_Source_Line;

        IF g_flow_schedule_rec.demand_source_line IS NOT NULL THEN

            IF MRP_Validate.Demand_Source_Line(g_flow_schedule_rec.demand_source_line)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_DEMAND_SOURCE_LINE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.demand_source_line := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.demand_source_type = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.demand_source_type IS NULL THEN

        g_flow_schedule_rec.demand_source_type := Get_Demand_Source_Type;

        IF g_flow_schedule_rec.demand_source_type IS NOT NULL THEN

            IF MRP_Validate.Demand_Source_Type(g_flow_schedule_rec.demand_source_type)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_DEMAND_SOURCE_TYPE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.demand_source_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.line_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.line_id IS NULL THEN

        g_flow_schedule_rec.line_id := Get_Line;

        IF g_flow_schedule_rec.line_id IS NOT NULL THEN

            IF MRP_Validate.Line(g_flow_schedule_rec.line_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_LINE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.material_account = FND_API.G_MISS_NUM OR g_flow_schedule_rec.material_account IS NULL THEN

        g_flow_schedule_rec.material_account := Get_Material_Account;

        IF g_flow_schedule_rec.material_account IS NOT NULL THEN

            IF MRP_Validate.Material_Account(g_flow_schedule_rec.material_account)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_MATERIAL_ACCOUNT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.material_account := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.material_overhead_account = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.material_overhead_account IS NULL THEN

        g_flow_schedule_rec.material_overhead_account := Get_Material_Overhead_Account;

        IF g_flow_schedule_rec.material_overhead_account IS NOT NULL THEN

            IF MRP_Validate.Material_Overhead_Account(g_flow_schedule_rec.material_overhead_account)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_MATERIAL_OVERHEAD_ACCOUNT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.material_overhead_account := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.material_variance_account = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.material_variance_account IS NULL THEN

        g_flow_schedule_rec.material_variance_account := Get_Material_Variance_Account;

        IF g_flow_schedule_rec.material_variance_account IS NOT NULL THEN

            IF MRP_Validate.Material_Variance_Account(g_flow_schedule_rec.material_variance_account)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_MATERIAL_VARIANCE_ACCOUNT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.material_variance_account := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.mps_net_quantity = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.mps_net_quantity IS NULL THEN

        g_flow_schedule_rec.mps_net_quantity := Get_Mps_Net_Quantity;

        IF g_flow_schedule_rec.mps_net_quantity IS NOT NULL THEN

            IF MRP_Validate.Mps_Net_Quantity(g_flow_schedule_rec.mps_net_quantity)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_MPS_NET_QUANTITY
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.mps_net_quantity := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.mps_scheduled_comp_date = FND_API.G_MISS_DATE  OR g_flow_schedule_rec.mps_scheduled_comp_date IS NULL THEN

        g_flow_schedule_rec.mps_scheduled_comp_date := Get_Mps_Scheduled_Comp_Date;

        IF g_flow_schedule_rec.mps_scheduled_comp_date IS NOT NULL THEN

            IF MRP_Validate.Mps_Scheduled_Comp_Date(g_flow_schedule_rec.mps_scheduled_comp_date)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_MPS_SCHEDULED_COMP_DATE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.mps_scheduled_comp_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.organization_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.organization_id IS NULL THEN

        g_flow_schedule_rec.organization_id := Get_Organization;

        IF g_flow_schedule_rec.organization_id IS NOT NULL THEN

            IF MRP_Validate.Organization(g_flow_schedule_rec.organization_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_ORGANIZATION
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.organization_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.outside_processing_acct = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.outside_processing_acct IS NULL THEN

        g_flow_schedule_rec.outside_processing_acct := Get_Outside_Processing_Acct;

        IF g_flow_schedule_rec.outside_processing_acct IS NOT NULL THEN

            IF MRP_Validate.Outside_Processing_Acct(g_flow_schedule_rec.outside_processing_acct)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_OUTSIDE_PROCESSING_ACCT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.outside_processing_acct := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.outside_proc_var_acct = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.outside_proc_var_acct IS NULL THEN

        g_flow_schedule_rec.outside_proc_var_acct := Get_Outside_Proc_Var_Acct;

        IF g_flow_schedule_rec.outside_proc_var_acct IS NOT NULL THEN

            IF MRP_Validate.Outside_Proc_Var_Acct(g_flow_schedule_rec.outside_proc_var_acct)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_OUTSIDE_PROC_VAR_ACCT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.outside_proc_var_acct := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.overhead_account = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.overhead_account IS NULL THEN

        g_flow_schedule_rec.overhead_account := Get_Overhead_Account;

        IF g_flow_schedule_rec.overhead_account IS NOT NULL THEN

            IF MRP_Validate.Overhead_Account(g_flow_schedule_rec.overhead_account)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_OVERHEAD_ACCOUNT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.overhead_account := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.overhead_variance_account = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.overhead_variance_account IS NULL THEN

        g_flow_schedule_rec.overhead_variance_account := Get_Overhead_Variance_Account;

        IF g_flow_schedule_rec.overhead_variance_account IS NOT NULL THEN

            IF MRP_Validate.Overhead_Variance_Account(g_flow_schedule_rec.overhead_variance_account)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_OVERHEAD_VARIANCE_ACCOUNT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.overhead_variance_account := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.planned_quantity = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.planned_quantity IS NULL THEN

        g_flow_schedule_rec.planned_quantity := Get_Planned_Quantity;

        IF g_flow_schedule_rec.planned_quantity IS NOT NULL THEN

            IF MRP_Validate.Planned_Quantity(g_flow_schedule_rec.planned_quantity)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_PLANNED_QUANTITY
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.planned_quantity := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.primary_item_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.primary_item_id IS NULL THEN

        g_flow_schedule_rec.primary_item_id := Get_Primary_Item;

        IF g_flow_schedule_rec.primary_item_id IS NOT NULL THEN

            IF MRP_Validate.Primary_Item(g_flow_schedule_rec.primary_item_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_PRIMARY_ITEM
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.primary_item_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.project_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.project_id IS NULL THEN

        g_flow_schedule_rec.project_id := Get_Project;

        IF g_flow_schedule_rec.project_id IS NOT NULL THEN

            IF MRP_Validate.Project(g_flow_schedule_rec.project_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_PROJECT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.project_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.quantity_completed = FND_API.G_MISS_NUM OR g_flow_schedule_rec.quantity_completed IS NULL THEN

        g_flow_schedule_rec.quantity_completed := Get_Quantity_Completed;

        IF g_flow_schedule_rec.quantity_completed IS NOT NULL THEN

            IF MRP_Validate.Quantity_Completed(g_flow_schedule_rec.quantity_completed)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_QUANTITY_COMPLETED
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.quantity_completed := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.request_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.request_id IS NULL THEN

-- bug 4529167
--        g_flow_schedule_rec.request_id := Get_Request_Id;
        g_flow_schedule_rec.request_id := null;

    END IF;

    IF g_flow_schedule_rec.resource_account = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.resource_account IS NULL THEN

        g_flow_schedule_rec.resource_account := Get_Resource_Account;

        IF g_flow_schedule_rec.resource_account IS NOT NULL THEN

            IF MRP_Validate.Resource_Account(g_flow_schedule_rec.resource_account)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_RESOURCE_ACCOUNT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.resource_account := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.resource_variance_account = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.resource_variance_account IS NULL THEN

        g_flow_schedule_rec.resource_variance_account := Get_Resource_Variance_Account;

        IF g_flow_schedule_rec.resource_variance_account IS NOT NULL THEN

            IF MRP_Validate.Resource_Variance_Account(g_flow_schedule_rec.resource_variance_account)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_RESOURCE_VARIANCE_ACCOUNT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.resource_variance_account := NULL;
            END IF;

        END IF;

    END IF;

/* Fix for bug 2977987: Moved this code to ensure that routing_revision is calculated after calculating
   routing_revision_date

    IF g_flow_schedule_rec.routing_revision = FND_API.G_MISS_CHAR  OR g_flow_schedule_rec.routing_revision IS NULL THEN

        g_flow_schedule_rec.routing_revision := Get_Routing_Revision;

        IF g_flow_schedule_rec.routing_revision IS NOT NULL THEN

            IF MRP_Validate.Routing_Revision(g_flow_schedule_rec.routing_revision)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_ROUTING_REVISION
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.routing_revision := NULL;
            END IF;

        END IF;

    END IF;
*/

    IF g_flow_schedule_rec.routing_revision_date = FND_API.G_MISS_DATE  OR g_flow_schedule_rec.routing_revision_date IS NULL THEN

        g_flow_schedule_rec.routing_revision_date := Get_Routing_Revision_Date;

        IF g_flow_schedule_rec.routing_revision_date IS NOT NULL THEN

            IF MRP_Validate.Routing_Revision_Date(g_flow_schedule_rec.routing_revision_date)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_ROUTING_REVISION_DATE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.routing_revision_date := NULL;
            END IF;

        END IF;

    END IF;

/* Fix for bug 2977987: routing_revision is being calculated after calculating routing_revision_date */

    IF g_flow_schedule_rec.routing_revision = FND_API.G_MISS_CHAR  OR g_flow_schedule_rec.routing_revision IS NULL THEN

        g_flow_schedule_rec.routing_revision := Get_Routing_Revision;

        IF g_flow_schedule_rec.routing_revision IS NOT NULL THEN

            IF MRP_Validate.Routing_Revision(g_flow_schedule_rec.routing_revision)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_ROUTING_REVISION
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
                ,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.routing_revision := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.scheduled_completion_date = FND_API.G_MISS_DATE  OR g_flow_schedule_rec.scheduled_completion_date IS NULL THEN

        g_flow_schedule_rec.scheduled_completion_date := Get_Scheduled_Completion_Date;

        IF g_flow_schedule_rec.scheduled_completion_date IS NOT NULL THEN

            IF MRP_Validate.Scheduled_Completion_Date(g_flow_schedule_rec.scheduled_completion_date)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_SCHEDULED_COMPLETION_DATE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.scheduled_completion_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.scheduled_flag = FND_API.G_MISS_NUM or g_flow_schedule_rec.scheduled_flag IS NULL THEN

        g_flow_schedule_rec.scheduled_flag := Get_Scheduled;

        IF g_flow_schedule_rec.scheduled_flag IS NOT NULL THEN

            IF MRP_Validate.Scheduled(g_flow_schedule_rec.scheduled_flag)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_SCHEDULED
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.scheduled_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.scheduled_start_date = FND_API.G_MISS_DATE OR g_flow_schedule_rec.scheduled_start_date IS NULL THEN

        g_flow_schedule_rec.scheduled_start_date := Get_Scheduled_Start_Date;

        IF g_flow_schedule_rec.scheduled_start_date IS NOT NULL THEN

            IF MRP_Validate.Scheduled_Start_Date(g_flow_schedule_rec.scheduled_start_date)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_SCHEDULED_START_DATE
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.scheduled_start_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.schedule_group_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.schedule_group_id IS NULL THEN

        g_flow_schedule_rec.schedule_group_id := Get_Schedule_Group;

        IF g_flow_schedule_rec.schedule_group_id IS NOT NULL THEN

            IF MRP_Validate.Schedule_Group(g_flow_schedule_rec.schedule_group_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_SCHEDULE_GROUP
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.schedule_group_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.schedule_number = FND_API.G_MISS_CHAR OR g_flow_schedule_rec.schedule_number IS NULL THEN

        g_flow_schedule_rec.schedule_number := Get_Schedule_Number;

        IF g_flow_schedule_rec.schedule_number IS NOT NULL THEN

            IF MRP_Validate.Schedule_Number(g_flow_schedule_rec.schedule_number)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_SCHEDULE_NUMBER
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.schedule_number := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.status = FND_API.G_MISS_NUM OR g_flow_schedule_rec.status IS NULL THEN

        g_flow_schedule_rec.status := Get_Status;

        IF g_flow_schedule_rec.status IS NOT NULL THEN

            IF MRP_Validate.Status(g_flow_schedule_rec.status)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_STATUS
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.status := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.std_cost_adjustment_acct = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.std_cost_adjustment_acct IS NULL THEN

        g_flow_schedule_rec.std_cost_adjustment_acct := Get_Std_Cost_Adjustment_Acct;

        IF g_flow_schedule_rec.std_cost_adjustment_acct IS NOT NULL THEN

            IF MRP_Validate.Std_Cost_Adjustment_Acct(g_flow_schedule_rec.std_cost_adjustment_acct)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_STD_COST_ADJUSTMENT_ACCT
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.std_cost_adjustment_acct := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.task_id = FND_API.G_MISS_NUM  OR g_flow_schedule_rec.task_id IS NULL THEN

        g_flow_schedule_rec.task_id := Get_Task;

        IF g_flow_schedule_rec.task_id IS NOT NULL THEN

            IF MRP_Validate.Task(g_flow_schedule_rec.task_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_TASK
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.task_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.wip_entity_id = FND_API.G_MISS_NUM OR g_flow_schedule_rec.wip_entity_id IS NULL THEN

        g_flow_schedule_rec.wip_entity_id := Get_Wip_Entity;

        IF g_flow_schedule_rec.wip_entity_id IS NOT NULL THEN

            IF MRP_Validate.Wip_Entity(g_flow_schedule_rec.wip_entity_id)
            THEN
                MRP_Flow_Schedule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Flow_Schedule_Util.G_WIP_ENTITY
                ,   p_flow_schedule_rec           => g_flow_schedule_rec
		,   p_old_flow_schedule_rec       => l_old_flow_schedule_rec
                ,   x_flow_schedule_rec           => g_flow_schedule_rec
                );
            ELSE
                g_flow_schedule_rec.wip_entity_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_flow_schedule_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute_category = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Wip_Flow_Schedule;

    END IF;

    IF g_flow_schedule_rec.created_by = FND_API.G_MISS_NUM THEN

        g_flow_schedule_rec.created_by := NULL;

    END IF;

    IF g_flow_schedule_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_flow_schedule_rec.creation_date := NULL;

    END IF;

    IF g_flow_schedule_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_flow_schedule_rec.last_updated_by := NULL;

    END IF;

    IF g_flow_schedule_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_flow_schedule_rec.last_update_date := NULL;

    END IF;

    IF g_flow_schedule_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_flow_schedule_rec.last_update_login := NULL;

    END IF;

    IF g_flow_schedule_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_flow_schedule_rec.program_application_id := NULL;

    END IF;

    IF g_flow_schedule_rec.program_id = FND_API.G_MISS_NUM THEN

        g_flow_schedule_rec.program_id := NULL;

    END IF;

    IF g_flow_schedule_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_flow_schedule_rec.program_update_date := NULL;

    END IF;

    IF g_flow_schedule_rec.request_id = FND_API.G_MISS_NUM THEN

        g_flow_schedule_rec.request_id := NULL;

    END IF;

    IF g_flow_schedule_rec.kanban_card_id = FND_API.G_MISS_NUM THEN

        g_flow_schedule_rec.kanban_card_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_flow_schedule_rec.alternate_bom_designator = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.alternate_routing_desig = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.attribute_category = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.bom_revision = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.bom_revision_date = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.build_sequence = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.class_code = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.completion_locator_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.completion_subinventory = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.created_by = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.date_closed = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.end_item_unit_number = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.quantity_scrapped = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.demand_class = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.demand_source_delivery = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.demand_source_header_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.demand_source_line = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.demand_source_type = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.line_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.material_account = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.material_overhead_account = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.material_variance_account = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.mps_net_quantity = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.mps_scheduled_comp_date = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.organization_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.outside_processing_acct = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.outside_proc_var_acct = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.overhead_account = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.overhead_variance_account = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.planned_quantity = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.primary_item_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.program_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.project_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.quantity_completed = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.request_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.resource_account = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.resource_variance_account = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.routing_revision = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.routing_revision_date = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.scheduled_completion_date = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.scheduled_flag = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.scheduled_start_date = FND_API.G_MISS_DATE
    OR  g_flow_schedule_rec.schedule_group_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.schedule_number = FND_API.G_MISS_CHAR
    OR  g_flow_schedule_rec.status = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.std_cost_adjustment_acct = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.task_id = FND_API.G_MISS_NUM
    OR  g_flow_schedule_rec.wip_entity_id = FND_API.G_MISS_NUM
    THEN

        MRP_Default_Flow_Schedule.Attributes
        (   p_flow_schedule_rec           => g_flow_schedule_rec
        ,   p_iteration                   => nvl(p_iteration, 1) + 1
        ,   x_flow_schedule_rec           => x_flow_schedule_rec
        );

    ELSE

        --  Done defaulting attributes

        x_flow_schedule_rec := g_flow_schedule_rec;

    END IF;

END Attributes;

END MRP_Default_Flow_Schedule;

/
