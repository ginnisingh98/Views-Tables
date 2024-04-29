--------------------------------------------------------
--  DDL for Package Body ENG_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VALIDATE" AS
/* $Header: ENGSVATB.pls 120.3 2006/06/06 12:40:09 vkeerthi noship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ENG_Validate';
ret_code                 NUMBER;

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
    FND_API.g_attr_tbl(I).name     := 'request';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_application';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'approval_status_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'approval_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'approval_list';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'change_order_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'responsible_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'approval_request_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'change_notice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'organization';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_updated_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'creation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_login';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'description';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'status_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'initiation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'implementation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cancellation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cancellation_comments';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'priority';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'estimated_eng_cost';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'estimated_mfg_cost';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'requestor';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rev';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'comments';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'using_assembly';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revised_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cancel_comments';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'disposition_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'new_item_revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'early_schedule_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'scheduled_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'bill_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'mrp_active';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'update_wip';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'use_up';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'use_up_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'revised_item_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'use_up_plan_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'descriptive_text';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'auto_implement_date';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'supply_subinventory';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'op_lead_time_percent';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cost_factor';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'required_for_revenue';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'high_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wip_supply_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'supply_locator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'bom_item_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'operation_seq_num';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_num';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component_yield_factor';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component_remarks';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'effectivity_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'disable_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'planning_factor';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity_related';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'so_basis';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'optional';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'mutually_exclusive_opt';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'include_in_cost_rollup';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'check_atp';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_allowed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'required_to_ship';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'include_on_ship_docs';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'include_on_bill_docs';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'low_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'acd_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'old_component_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pick_components';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ref_designator';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ref_designator_comment';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'substitute_component';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'substitute_item_quantity';


--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate
--  comment.


FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )
RETURN BOOLEAN
IS
BEGIN

    RETURN TRUE;

END Desc_Flex;

/***************************************************************************
*
*
*
*
*
*
***************************************************************************/
FUNCTION Approval_Status_Type (  p_approval_status_type IN  NUMBER
                               , x_err_text             OUT NOCOPY VARCHAR2
                               )
RETURN BOOLEAN
IS
l_dummy        VARCHAR2(10);
BEGIN

    IF p_approval_status_type IS NULL OR
        p_approval_status_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT 'VALID'
      INTO l_dummy
      FROM mfg_lookups
     WHERE lookup_type = 'ENG_ECN_APPROVAL_STATUS'
       AND lookup_code = p_approval_status_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        --  Should log error message ENG_APPROVAL_STATUS_INVALID
        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Approval_Status_Type ' || SQLERRM;
        RETURN FALSE;

END Approval_Status_Type;

/***************************************************************************
*
*
*
*
*
*
***************************************************************************/
FUNCTION Approval_Date (  p_approval_date       IN  DATE
                        , x_err_text            OUT NOCOPY VARCHAR2
                        )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_approval_date IS NULL OR
        p_approval_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    IF p_approval_date > SYSDATE
    THEN
     RETURN FALSE;
    END IF;

    RETURN TRUE;

END Approval_Date;

/***************************************************************************
*
*
*
*
*
*
***************************************************************************/
FUNCTION Approval_List (  p_approval_list_id    IN  NUMBER
                        , x_err_text            OUT NOCOPY VARCHAR2
                        )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_approval_list_id IS NULL OR
        p_approval_list_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     eng_ecn_approval_lists
    WHERE    approval_list_id = p_approval_list_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        -- Should log error ENG_APPROVAL_LIST_INVALID
        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Approval_List ' || SQLERRM;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Approval_List;

/***************************************************************************
*
*
*
*
*
*
***************************************************************************/
FUNCTION Change_Order_Type (  p_change_order_type_id IN  NUMBER
                            , x_err_text             OUT NOCOPY VARCHAR2
                           )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_change_order_type_id IS NULL OR
        p_change_order_type_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     eng_change_order_types
    WHERE    change_order_type_id = p_change_order_type_id
             AND NVL(disable_date, SYSDATE + 1) > SYSDATE;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        -- Should log error message ENG_CHANGE_ORDER_TYPE_INVALID
        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Change_Order_Type ' || SQLERRM;
        RETURN FALSE;

END Change_Order_Type;

/***************************************************************************
*
*
*
*
*
*
***************************************************************************/
FUNCTION Responsible_Org (  p_responsible_org_id        IN  NUMBER
                          , p_current_org_id            IN  NUMBER
                          , x_err_text                  OUT NOCOPY VARCHAR2
                          )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_responsible_org_id IS NULL OR
        p_responsible_org_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;
    -- Bug 4947849
    -- The following query has been fixed to fetch valid departments immaterial of the business group in context.
    -- The view hr_organization_units in iteself is restricted based on the profile HR: Cross Business group
    -- Value and per_business_group_id in context if the prior value is N.
    -- Also , it is being assumed here that the user will login to Oracle Appliction for doing an import from
    -- 11.5.10 onwards because Change Import concurrent pogram is used. Otherwise the query should return all
    -- departments
    SELECT  'VALID'
    INTO     l_dummy
    FROM     hr_organization_units hou
	  --   ,org_organization_definitions org_def
    WHERE    hou.organization_id = p_responsible_org_id
   --   AND    org_def.organization_id =   p_current_org_id
   --   AND    org_def.business_group_id = hou.business_group_id
    AND      EXISTS
                (select null
                 from   hr_organization_information hoi
                 where  hoi.organization_id = hou.organization_id
                 and    hoi.org_information_context = 'CLASS'
                 and    hoi.org_information1 = 'BOM_ECOD'
                 and    hoi.org_information2 = 'Y');
    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        -- Should log an error ENG_RESP_ORG_ID_INVALID
        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Responsible_Org ' || SQLERRM;

        RETURN FALSE;

END Responsible_Org;

/***************************************************************************
*
*
*
*
*
*
***************************************************************************/
FUNCTION Approval_Request_Date (  p_approval_request_date IN  DATE
                                , x_err_text              OUT NOCOPY VARCHAR2
                                )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_approval_request_date IS NULL OR
        p_approval_request_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    IF p_approval_request_date > SYSDATE
    THEN
     RETURN FALSE;
    END IF;

    RETURN TRUE;

END Approval_Request_Date;

/*****************************************************************************
*
*
*
*
*
*
*****************************************************************************/
FUNCTION Status_Type (  p_status_type IN  NUMBER
                      , x_err_text    OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_err_text      VARCHAR2(2000) := NULL;
BEGIN

    IF p_status_type IS NULL OR
        p_status_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --SELECT  'VALID'
    --INTO     l_dummy
    --FROM     mfg_lookups
    --WHERE    lookup_type = 'ECG_ECN_STATUS'
    --      and lookup_code = p_status_type;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     eng_change_statuses
    WHERE    status_code = p_status_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Status_Type ' || SQLERRM ;

        RETURN FALSE;

END Status_Type;

/****************************************************************************
* Function      : End_Item_Unit_Number
* Parameters IN : p_From_End_Item_Unit_Number
* Parameters OUT: Error Text which will be pouplated in case of an
*                 unexpected error.
*
* Return        : True if the from end item unit number is valid else False
* Purpose       : Verify that the from end item unit number exists
*                 in the table PJM_MODEL_UNIT_NUMBERS.
****************************************************************************/
FUNCTION End_Item_Unit_Number
( p_from_end_item_unit_number IN  VARCHAR2
, p_revised_item_id           IN  NUMBER
, x_err_text                  OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy         VARCHAR2(10);
l_err_text      VARCHAR2(2000) := NULL;
BEGIN

    IF p_from_end_item_unit_number IS NULL OR
        p_from_end_item_unit_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --Commented out on Oct 3, 1002 by ragreenw to match bom
    -- equivalent package code
    SELECT  'VALID'
    INTO     l_dummy
    FROM     pjm_unit_numbers
    --WHERE    end_item_id = p_revised_item_id
    WHERE    unit_number = p_from_end_item_unit_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure From End Item Unit Number'
                      || SQLERRM ;

        RETURN FALSE;

END End_Item_Unit_Number;

/****************************************************************************
*
*
*
*
*
*
****************************************************************************/
FUNCTION Initiation_Date (  p_initiation_date   IN  DATE
                          , x_err_text          OUT NOCOPY VARCHAR2
                          )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_initiation_date IS NULL OR
        p_initiation_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    IF p_initiation_date > SYSDATE
    THEN
     RETURN FALSE;
    END IF;

    RETURN TRUE;

END Initiation_Date;

/*****************************************************************************
*
*
*
*
*
*
*****************************************************************************/
FUNCTION Implementation_Date (  p_implementation_date   IN  DATE
                              , x_err_text              OUT NOCOPY VARCHAR2
                              )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_err_text      VARCHAR2(2000) := NULL;
BEGIN

    IF p_implementation_date IS NULL OR
        p_implementation_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    IF p_implementation_date IS NOT NULL
    THEN
     RETURN FALSE;
    END IF;

    RETURN TRUE;

END Implementation_Date;

/****************************************************************************
*
*
*
*
*
*
*****************************************************************************/
FUNCTION Cancellation_Date (  p_cancellation_date       IN  DATE
                            , x_err_text                OUT NOCOPY VARCHAR2
                            )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_cancellation_date IS NULL OR
        p_cancellation_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    IF p_cancellation_date > SYSDATE
    THEN
     RETURN FALSE;
    END IF;

    RETURN TRUE;

END Cancellation_Date;

/****************************************************************************
*
*
*
*
*
*
*****************************************************************************/
FUNCTION Priority (  p_priority_code IN VARCHAR2
                   , p_organization_id IN NUMBER
                   , x_disable_date OUT NOCOPY DATE
                   , x_err_text OUT NOCOPY VARCHAR2
                   )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_priority_code IS NULL OR
        p_priority_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID', disable_date
    INTO     l_dummy, x_disable_date
    FROM     eng_change_priorities
    WHERE    eng_change_priority_code = p_priority_code
             AND organization_id = -1;   --p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        -- Should log error message 'ENG_PRIORITY_CODE_INVALID'

        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Priority' || SQLERRM ;

        RETURN FALSE;

END Priority;

FUNCTION Reason (  p_reason_code        IN VARCHAR2
                 , p_organization_id    IN NUMBER
                 , x_disable_date       OUT NOCOPY DATE
                 , x_err_text           OUT NOCOPY VARCHAR2
                 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_reason_code IS NULL OR
        p_reason_code = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID', disable_date
    INTO     l_dummy, x_disable_date
    FROM     eng_change_reasons
    WHERE    eng_change_reason_code = p_reason_code
             AND organization_id = -1;   --p_organization_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Priority' || SQLERRM ;

        RETURN FALSE;


END Reason;

FUNCTION Disposition_Type (  p_disposition_type IN  NUMBER
                           , x_err_text         OUT NOCOPY VARCHAR2
                           )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_err_text                    VARCHAR2(2000) := NULL;
BEGIN

    IF p_disposition_type IS NULL OR
        p_disposition_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     mfg_lookups
    WHERE    lookup_type = 'ECG_MATERIAL_DISPOSITION'
          and lookup_code = p_disposition_type;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Disposition_Type' || SQLERRM ;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Disposition_Type;

/**************************************************************************
*
*
*
*
*
*
**************************************************************************/
FUNCTION Mrp_Active (  p_mrp_active     IN  NUMBER
                     , x_err_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_err_text                    VARCHAR2(2000) := NULL;
BEGIN

    IF p_mrp_active IS NULL OR
        p_mrp_active = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_mrp_active IN (1, 2)
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Mrp_Active;

/****************************************************************************
*
*
*
*
*
****************************************************************************/
FUNCTION Update_Wip (  p_update_wip     IN  NUMBER
                     , x_err_text       OUT NOCOPY VARCHAR2
                    )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_update_wip IS NULL OR
        p_update_wip = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_update_wip IN (1, 2)
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Update_Wip;

/*****************************************************************************
*
*
*
*
*
*****************************************************************************/
FUNCTION Use_Up (  p_use_up     IN  NUMBER
                 , x_err_text   OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_use_up IS NULL OR
        p_use_up = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_use_up IN (1, 2)
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Use_Up;


/*****************************************************************************
* Function      : Use_Up_Plan_Name
* Parameters IN : Plan Name
*                 Organization Id
* Parameters OUT: Error_Text
* Returns       : True if plan is valid, otherwise False.
* Purpose       : Function will validate the plan name against mrp_plans and
*                 verify if it exists. If it does then the function will check
*                 1. If Data_completion date < Explosion_completion_date
*                 2. If Plan completion_date < Data_completion_date
*                 If any of these conditions are violated, then the function
*                 returns with a False and the message name that should be used
*                 to get the message from the dictionary.
******************************************************************************/
FUNCTION Use_Up_Plan_Name (  p_use_up_plan_name IN  VARCHAR2
                           , p_organization_id  IN  NUMBER
                           , x_err_text         OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
        l_explosion_completion_date     DATE;
        l_data_completion_date          DATE;
        l_plan_completion_date          DATE;
BEGIN
    IF p_use_up_plan_name IS NULL OR
        p_use_up_plan_name = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

   Begin
    SELECT explosion_completion_date, data_completion_date,
           plan_completion_date
      INTO l_explosion_completion_date,
           l_data_completion_date,
           l_plan_completion_date
      FROM mrp_plans
     WHERE compile_designator = p_use_up_plan_name
       AND organization_id = p_organization_id;

        IF l_data_completion_date < l_explosion_completion_date
        THEN
                x_err_text := 'ENG_DATA_COMPL_DATE_INVALID';
                RETURN FALSE;

        END IF;
        IF l_data_completion_date > l_plan_completion_date
        THEN
                x_err_text := 'ENG_PLAN_COMPL_DATE_INVALID';
                RETURN FALSE;
        END IF;

/* Aded following for Bug 3240315 */
   Exception
    WHEN NO_DATA_FOUND THEN

      SELECT plan_completion_date
      INTO l_plan_completion_date
      FROM mrp_plan_organizations_v
      WHERE compile_designator = p_use_up_plan_name
       AND planned_organization = p_organization_id;

   End;
    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := 'ENG_USE_UP_PLAN_INVALID';
        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Use_Up_Plan_Name' || SQLERRM ;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Use_Up_Plan_Name;


/****************************************************************************
* Function      : Supply_Subinventory
* Parameters IN : Subinventory Name
*                 Organization Id
* Parameters OUT: Error Text which will be pouplated in case of an
*                 unexpected error.
*
* Return        : True if the subinventory is valid else False
* Purpose       : Verify that the supply subinventory is exist for the given
*                 organization in the table MTL_SECONDARY_SUBINVENTORIES.
****************************************************************************/
FUNCTION Supply_Subinventory (  p_supply_subinventory   IN  VARCHAR2
                              , p_organization_id       IN  NUMBER
                              , x_err_text              OUT NOCOPY VARCHAR2
                              )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_supply_subinventory IS NULL OR
        p_supply_subinventory = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    SELECT 'VALID'
      INTO l_dummy
      FROM mtl_secondary_inventories
     WHERE secondary_inventory_name = p_supply_subinventory
       AND organization_id          = p_organization_id;

    RETURN TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                RETURN FALSE;

        WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and procedure Supply_Subinventory' || SQLERRM ;
                RETURN FALSE;

END Supply_Subinventory;

/****************************************************************************
*
*
*
*
*
*
****************************************************************************/
FUNCTION Required_For_Revenue (  p_required_for_revenue IN  NUMBER
                               , x_err_text             OUT NOCOPY VARCHAR2
                               )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_required_for_revenue IS NULL OR
        p_required_for_revenue = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_required_for_revenue NOT IN(1, 2) THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;

END Required_For_Revenue;

/****************************************************************************
* Function      : Wip_Supply_Type
* Parameters IN : Wip_Supply_Type value
* Parameters OUT: Error Text which will be populated in case of an
*                 unexpected error.
* Returns       : True if the Wip_supply_Type exist in the Lookup else False
* Purpose       : Verify that the value of Wip_Supply_Type is valid, by looking
*                 in the Table MFG_LOOKUPS with a Lookup Type of 'WIP_SUPPLY'
*****************************************************************************/
FUNCTION Wip_Supply_Type (  p_wip_supply_type   IN  NUMBER
                          , x_err_text          OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_wip_supply_type IS NULL OR
        p_wip_supply_type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT 'VALID'
      INTO l_dummy
      FROM mfg_lookups
     WHERE lookup_code = p_wip_supply_type
       AND lookup_type = 'WIP_SUPPLY' ;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

    WHEN OTHERS THEN
        x_err_text := 'An unexpected error occured in ' || G_PKG_NAME ||
                      ' and function Wip_Supply_Type' || SQLERRM ;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wip_Supply_Type;

/*****************************************************************************
*
*
*
*
*
*
*****************************************************************************/
FUNCTION Item_Num ( p_item_num  IN  NUMBER
                   , x_err_text OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Attribute validating Item_num . . . ' ||
    to_char(p_item_num));
END IF;

    IF p_item_num IS NULL OR
        p_item_num = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    ELSIF p_item_num < 0 OR
          p_item_num > 9999 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;

END Item_Num;

FUNCTION Component_Yield_Factor (  p_component_yield_factor     IN  NUMBER
                                 , x_err_text                   OUT NOCOPY VARCHAR2
                                )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_component_yield_factor IS NULL OR
       p_component_yield_factor = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    ELSIF p_component_yield_factor < 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;

END Component_Yield_Factor;

/*****************************************************************************
* Function      : Effectivity_Date
* Parmeters IN  : Effectivity Date of the component
*                 Revised item sequence id
* Parmeters OUT : Error Text which will be populated in case of an unexpected
*                 error.
* Returns       : True if the effectivity date is valid else False.
* Purpose       : Verify that the effectivity date of the component is equal
*                 to the schedule date of the revised item.
******************************************************************************/
FUNCTION Effectivity_Date (  p_effectivity_date         IN  DATE
                           , p_revised_item_sequence_id IN  NUMBER
                           , x_err_text                 OUT NOCOPY VARCHAR2
                           )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
CURSOR c_EffectiveDate IS
        SELECT scheduled_date
          FROM eng_revised_items
         WHERE revised_item_sequence_id = p_revised_item_sequence_id;

BEGIN

    IF p_effectivity_date IS NULL OR
           p_effectivity_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    FOR l_Effective IN c_EffectiveDate LOOP

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Schedule Date : ' ||
                     to_Char(l_effective.scheduled_date) || ' ' ||
                     'Effective Date : ' || to_Char(p_effectivity_date));
END IF;

        IF p_effectivity_date = l_effective.scheduled_date
        THEN
                RETURN TRUE;
        ELSE
                 -- Date's should be = Scheduled date
                RETURN FALSE;

        END IF;
     END LOOP;

END Effectivity_Date;

/****************************************************************************
*
*
*
*
*
*****************************************************************************/
FUNCTION Disable_Date (  p_disable_date         IN  DATE
                       , p_effectivity_date     IN  DATE
                       , x_err_text             OUT NOCOPY VARCHAR2
                       )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_disable_date IS NULL OR
        p_disable_date = FND_API.G_MISS_DATE OR
        (p_disable_date >= SYSDATE AND
         p_disable_date >= p_effectivity_date
        )
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Disable_Date;

FUNCTION Quantity_Related ( p_quantity_related IN NUMBER ,
                            x_err_text         OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_quantity_related IS NULL OR
        p_quantity_related = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_quantity_related in (1, 2) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Quantity_Related;

FUNCTION So_Basis ( p_so_basis  IN  NUMBER
                  , x_err_text  OUT NOCOPY VARCHAR2
                  )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_so_basis IS NULL OR
        p_so_basis = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;
        IF p_so_basis in (1, 2) THEN
                RETURN TRUE;
        ELSE
                RETURN FALSE;
        END IF;

END So_Basis;

/****************************************************************************
*
*
*
*
*****************************************************************************/
FUNCTION Optional ( p_optional IN NUMBER ,
                    x_err_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_optional IS NULL OR
        p_optional = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_optional IN (1, 2) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Optional;

/****************************************************************************
*
*
*
*
*****************************************************************************/
FUNCTION Mutually_Exclusive_Opt ( p_mutually_exclusive_opt IN NUMBER ,
                                  x_err_text               OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_mutually_exclusive_opt IS NULL OR
        p_mutually_exclusive_opt = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_mutually_exclusive_opt IN (1, 2)
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Mutually_Exclusive_Opt;

/****************************************************************************
*
*
*
*
*****************************************************************************/
FUNCTION Include_In_Cost_Rollup ( p_include_in_cost_rollup IN NUMBER ,
                                  x_err_text               OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_include_in_cost_rollup IS NULL OR
        p_include_in_cost_rollup = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_include_in_cost_rollup IN (1, 2)
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Include_In_Cost_Rollup;

/****************************************************************************
*
*
*
*
*****************************************************************************/
FUNCTION Check_Atp ( p_check_atp IN  NUMBER
                   , x_err_text  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

        -- Validate ATP at the Entity level as it
        -- requires lot of additional information.

        IF p_check_atp IS NULL OR
           p_check_atp = FND_API.G_MISS_NUM
        THEN
                RETURN TRUE;
        ELSIF p_check_atp NOT IN (1, 2, 3) THEN
                RETURN FALSE;
        ELSE
                RETURN TRUE;
        END IF;

END Check_Atp;

/****************************************************************************
*
*
*
*
*****************************************************************************/
FUNCTION Shipping_Allowed ( p_shipping_allowed IN NUMBER ,
                            x_err_text         OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_shipping_allowed IS NULL OR
        p_shipping_allowed = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_shipping_Allowed IN (1, 2)
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Shipping_Allowed;

/****************************************************************************
*
*
*
*
*****************************************************************************/
FUNCTION Required_To_Ship ( p_required_to_ship IN NUMBER ,
                            x_err_text         OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_required_to_ship IS NULL OR
        p_required_to_ship = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_required_to_ship IN (1, 2)
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Required_To_Ship;

/****************************************************************************
*
*
*
*
*****************************************************************************/
FUNCTION Include_On_Ship_Docs ( p_include_on_ship_docs IN NUMBER ,
                                x_err_text             OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_include_on_ship_docs IS NULL OR
        p_include_on_ship_docs = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    IF p_include_on_ship_docs IN (1, 2)
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Include_On_Ship_Docs;

/****************************************************************************
*
*
*
*
*****************************************************************************/
FUNCTION Acd_Type ( p_acd_type IN NUMBER ,
                    x_err_text OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_acd_type IS NULL OR
        p_acd_type NOT IN (1,2,3)
    THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END Acd_Type;



/****************************************************************************
* Added by MK on 09/01/2000 for ECO New Effectivities
*
*
* Function      : Check_RevCmp_In_ECO_By_WO
* Parameters IN : Revised Item Sequence Id, Component Item Id and Operation Seq Num
* Parameters OUT: Error Text which will be populated in case of an
*                 unexpected error.
* Returns       : True if All Jobs in ECO by Lot, WO, Cum Qty have the
*                  Rev Component and Op Seq Number else False.
* Purpose       : Check if Component Item, Op Seq Num exists in material requirements
*                 info of jobs and schedules Verify the user can create a revised
*                 component record in ECO by WO
*****************************************************************************/
FUNCTION Check_RevCmp_In_ECO_By_WO
             ( p_revised_item_sequence_id IN  NUMBER
             , p_rev_comp_item_id         IN  NUMBER
             , p_operation_seq_num        IN  NUMBER)

RETURN BOOLEAN
IS
       l_ret_status BOOLEAN := TRUE ;

       CURSOR l_check_rit_effectivity_csr (p_revised_item_sequence_id NUMBER)
       IS
          SELECT   lot_number
                 , from_wip_entity_id
                 , to_wip_entity_id
                 , from_cum_qty
                 , organization_id
          FROM    ENG_REVISED_ITEMS
          WHERE  (lot_number         IS NOT NULL  OR
                  from_wip_entity_id IS NOT NULL)
          AND    revised_item_sequence_id = p_revised_item_sequence_id ;


       CURSOR  l_check_lot_num_csr ( p_lot_number        NUMBER
                                   , p_rev_comp_item_id  NUMBER
                                   , p_operation_seq_num NUMBER
                                   , p_organization_id   NUMBER)
       IS
          SELECT 'Cmp does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                         WHERE  (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS(SELECT NULL
                                             FROM   WIP_REQUIREMENT_OPERATIONS wro
                                             WHERE  wro.operation_seq_num = p_operation_seq_num
                                             AND    wro.inventory_item_id = p_rev_comp_item_id
                                             AND    wro.wip_entity_id     = wdj.wip_entity_id)
                                  )
                         AND      wdj.lot_number = p_lot_number
                         AND      wdj.organization_id = p_organization_id
                        ) ;

       CURSOR  l_check_wo_csr (  p_from_wip_entity_id NUMBER
                               , p_to_wip_entity_id   NUMBER
                               , p_rev_comp_item_id   NUMBER
                               , p_operation_seq_num  NUMBER )
       IS
          SELECT 'Cmp does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                               , WIP_ENTITIES       we
                               , WIP_ENTITIES       we1
                               , WIP_ENTITIES       we2
                         WHERE   (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS (SELECT NULL
                                              FROM   WIP_REQUIREMENT_OPERATIONS wro
                                              WHERE  wro.operation_seq_num = p_operation_seq_num
                                              AND    wro.inventory_item_id = p_rev_comp_item_id
                                              AND    wro.wip_entity_id     = wdj.wip_entity_id)
                                 )
                         AND     wdj.wip_entity_id = we.wip_entity_id
                         AND     we.wip_entity_name >= we1.wip_entity_name
                         AND     we.wip_entity_name <= we2.wip_entity_name
                         AND     we1.wip_entity_id = p_from_wip_entity_id
                         AND     we2.wip_entity_id = p_to_wip_entity_id
                         ) ;

      CURSOR  l_check_cum_csr (  p_from_wip_entity_id NUMBER
                               , p_rev_comp_item_id   NUMBER
                               , p_operation_seq_num  NUMBER)
       IS
          SELECT 'Cmp does not exist'
          FROM   SYS.DUAL
          WHERE  EXISTS (SELECT  NULL
                         FROM    WIP_DISCRETE_JOBS  wdj
                         WHERE   (wdj.status_type <> 1
                                  OR
                                  NOT EXISTS(SELECT NULL
                                             FROM   WIP_REQUIREMENT_OPERATIONS wro
                                             WHERE  wro.operation_seq_num = p_operation_seq_num
                                             AND    wro.inventory_item_id = p_rev_comp_item_id
                                             AND    wro.wip_entity_id     = wdj.wip_entity_id)
                                 )
                         AND     wdj.wip_entity_id = p_from_wip_entity_id
                         ) ;

    BEGIN


       FOR l_eco_effect_rec IN l_check_rit_effectivity_csr
                                           (p_revised_item_sequence_id)
       LOOP


          -- Check if Op Seq Num is exist in ECO by Lot
          IF    l_eco_effect_rec.lot_number         IS NOT NULL
           AND  l_eco_effect_rec.from_wip_entity_id IS NULL
           AND  l_eco_effect_rec.to_wip_entity_id   IS NULL
           AND  l_eco_effect_rec.from_cum_qty       IS NULL
          THEN

             FOR l_lot_num_rec IN l_check_lot_num_csr
                               ( p_lot_number        => l_eco_effect_rec.lot_number
                               , p_rev_comp_item_id  => p_rev_comp_item_id
                               , p_operation_seq_num => p_operation_seq_num
                               , p_organization_id   => l_eco_effect_rec.organization_id)

             LOOP
                 l_ret_status  := FALSE ;
             END LOOP ;

          -- Check if Op Seq Num is exist  in ECO by Cum
          ELSIF   l_eco_effect_rec.lot_number         IS NULL
           AND    l_eco_effect_rec.from_wip_entity_id IS NOT NULL
           AND    l_eco_effect_rec.to_wip_entity_id   IS NULL
           AND    l_eco_effect_rec.from_cum_qty       IS NOT NULL
          THEN

             FOR l_lot_num_rec IN l_check_cum_csr
                               ( p_from_wip_entity_id => l_eco_effect_rec.from_wip_entity_id
                               , p_rev_comp_item_id   => p_rev_comp_item_id
                               , p_operation_seq_num  => p_operation_seq_num )
             LOOP
                 l_ret_status  := FALSE ;
             END LOOP ;

          -- Check if Op Seq Num is exist  in ECO by WO
          ELSIF   l_eco_effect_rec.lot_number         IS NULL
           AND    l_eco_effect_rec.from_wip_entity_id IS NOT NULL
           AND    l_eco_effect_rec.to_wip_entity_id IS NOT NULL
           AND    l_eco_effect_rec.from_cum_qty       IS NULL
          THEN

             FOR l_lot_num_rec IN l_check_wo_csr
                               ( p_from_wip_entity_id => l_eco_effect_rec.from_wip_entity_id
                               , p_to_wip_entity_id   => l_eco_effect_rec.to_wip_entity_id
                               , p_rev_comp_item_id   => p_rev_comp_item_id
                               , p_operation_seq_num  => p_operation_seq_num )
             LOOP
                 l_ret_status  := FALSE ;
             END LOOP ;

          ELSIF   l_eco_effect_rec.lot_number         IS NULL
           AND    l_eco_effect_rec.from_wip_entity_id IS NULL
           AND    l_eco_effect_rec.to_wip_entity_id   IS NULL
           AND    l_eco_effect_rec.from_cum_qty       IS NULL
          THEN
             NULL ;

          --  ELSE
          --     l_ret_status  := FALSE ;
          --

          END IF ;
       END LOOP ;

       RETURN l_ret_status ;

END Check_RevCmp_In_ECO_By_WO ;


-- Function Check_Reference_Common
-- Cannot delete revised item if another bill references it as a common bill

FUNCTION Check_Reference_Common
( p_change_notice       VARCHAR2
, p_bill_sequence_id    NUMBER
)RETURN NUMBER
IS
  l_count1                      NUMBER := 0;
  l_count2                      NUMBER := 0;
  cursor pending_on_eco is
                select 1
                  from BOM_BILL_OF_MATERIALS
                 where bill_sequence_id = p_bill_sequence_id
                   and pending_from_ecn is not null
                   and pending_from_ecn = p_change_notice;
  cursor reference_common is
                select 1
                  from BOM_BILL_OF_MATERIALS
                 where source_bill_sequence_id = p_bill_sequence_id
                   and source_bill_sequence_id <> bill_sequence_id;
BEGIN

  l_count1 := 0;

  for l_pending_on_eco in pending_on_eco loop
    l_count1 := 1;
  end loop;

  if l_count1 = 1
  then
    l_count2 := 0;

    for l_reference_common in reference_common loop
      l_count2 := 1;
    end loop;
  end if;

  return (l_count2);
END Check_Reference_Common;


-- Function Check_Reference_Rtg_Common
-- Cannot delete revised item if another Routing references it as a common routing

FUNCTION Check_Reference_Rtg_Common
( p_change_notice          VARCHAR2
, p_routing_sequence_id    NUMBER
)RETURN NUMBER
IS
  l_count1                      NUMBER := 0;
  l_count2                      NUMBER := 0;
  cursor pending_on_eco is
                select 1
                  from BOM_OPERATIONAL_ROUTINGS
                 where routing_sequence_id = p_routing_sequence_id
                   and pending_from_ecn is not null
                   and pending_from_ecn = p_change_notice;
  cursor reference_common is
                select 1
                  from BOM_OPERATIONAL_ROUTINGS
                 where common_routing_sequence_id = p_routing_sequence_id
                   and common_routing_sequence_id <> routing_sequence_id;
BEGIN

  l_count1 := 0;

  for l_pending_on_eco in pending_on_eco loop
    l_count1 := 1;
  end loop;

  if l_count1 = 1
  then
    l_count2 := 0;

    for l_reference_common in reference_common loop
      l_count2 := 1;
    end loop;
  end if;

  return (l_count2);
END Check_Reference_Rtg_Common;


-- Added by MK on 08/26/2000
/*****************************************************************************
* Procedure     : Entity_Delete
* Parameters IN : Revised item exposed column record
*                 Revised item unexposed column record
* Parameters OUT: Mesg Token Table
*                 Return Status
* Purpose       : Entity Delete procedure will check if the given revised item
*                 can be deleted without violating any business rules or
*                 constraints. Revised item's cannot be deleted if there are
*                 components on the bill or it revised item's bill is being
*                 referenced as common by any other bills in the same org or
*                 any other org.
*                 (Check of revised item being implemented or cancelled is done
*                  in the previous steps of the process flow)
******************************************************************************/
PROCEDURE Check_Entity_Delete
(  x_return_status              OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_revised_item_rec           IN  ENG_Eco_PUB.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec         IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
)
IS
  l_err_text                  VARCHAR2(2000) := NULL;
  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  check_delete          NUMBER := 0;
  l_count1              NUMBER := 0;
  CURSOR rev_comps IS
                SELECT 1
                  FROM BOM_INVENTORY_COMPONENTS
                 WHERE revised_item_sequence_id =
                       p_rev_item_unexp_rec.revised_item_sequence_id;


  /******************************************************************
  -- Added by MK on 08/26/2000
  -- Enhancement for ECO Routing
  ******************************************************************/
  CURSOR rev_op_seq IS
  SELECT 'Rev Op Exist'
  FROM    SYS.DUAL
  WHERE EXISTS  ( SELECT NULL
                  FROM BOM_OPERATION_SEQUENCES
                  WHERE revised_item_sequence_id =
                       p_rev_item_unexp_rec.revised_item_sequence_id) ;
  -- Added by MK on 08/26/2000

        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
BEGIN


        --
        -- Set the revised item token name and value
        --
        l_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        l_Token_Tbl(1).Token_Value := p_revised_item_rec.revised_item_name;

        FOR l_rev_comps IN rev_comps
        LOOP
                --
                -- if loop executes, then component exist on that bill
                -- so it cannot be deleted.
                --
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_DEL_COMP_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END LOOP;



        /******************************************************************
        -- Added by MK on 08/26/2000
        -- Enhancement for ECO Routing
        ******************************************************************/
        FOR l_rev_op_seq IN rev_op_seq
        LOOP
                --
                -- if loop executes, then revised operation exist on that
                -- routing so it cannot be deleted.
                --
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_DEL_OP_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END LOOP;
        -- Added by MK on 08/26/2000



        /*********************************************************************
        --
        -- Check if the revised item's bill is being referenced as common
        --
        **********************************************************************/
        check_delete := Check_Reference_Common
                  ( p_change_notice     => p_revised_item_rec.eco_name
                  , p_bill_sequence_id  => p_rev_item_unexp_rec.bill_sequence_id
                  );

        IF check_delete <> 0
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_DEL_COMMON_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        /*********************************************************************
        -- Added by MK on 08/26/2000
        -- Check if the revised item's routing is being referenced as common
        **********************************************************************/
        check_delete := 0 ;
        check_delete :=  Check_Reference_Rtg_Common
                  ( p_change_notice     => p_revised_item_rec.eco_name
                  , p_routing_sequence_id  => p_rev_item_unexp_rec.routing_sequence_id
                  );

        IF check_delete <> 0
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_CANNOT_DEL_RTG_COMMON_EXIST'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                END IF;
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        -- Added by MK on 08/26/2000

        -- Done with the validations
        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            l_err_text := G_PKG_NAME || ' : (Entity Delete Validation) ' ||
                          substrb(SQLERRM,1,200);
            Error_Handler.Add_Error_Token
            (  p_Message_Name   => NULL
             , p_Message_Text   => l_Err_Text
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             );
        END IF;

END Check_Entity_Delete;

END ENG_Validate;

/
