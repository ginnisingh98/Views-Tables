--------------------------------------------------------
--  DDL for Package Body ENG_DEFAULT_ECO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_DEFAULT_ECO" AS
/* $Header: ENGDECOB.pls 120.3.12010000.1 2008/07/28 06:23:29 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Default_Eco';

--  Package global used within the package.

g_ECO_rec                     ENG_Eco_PUB.Eco_Rec_Type;
g_Unexp_ECO_Rec		      ENG_Eco_PUB.Eco_unexposed_Rec_Type;

--  Get functions.

FUNCTION Get_Responsible_Org
RETURN NUMBER
IS
l_profile_value NUMBER := NULL;
BEGIN

    IF fnd_profile.defined('ENG:ECO_DEPARTMENT')
    THEN
    	l_profile_value := fnd_profile.value('ENG:ECO_DEPARTMENT');
    END IF;

    RETURN l_profile_value;

END Get_Responsible_Org;

FUNCTION Get_Change_Id
RETURN NUMBER
IS
l_change_id NUMBER := NULL;
BEGIN

    SELECT ENG_ENGINEERING_CHANGES_S.NEXTVAL
    INTO l_change_id
    FROM DUAL;

    RETURN l_change_id;

    EXCEPTION

        WHEN OTHERS THEN
                RETURN NULL;

END Get_Change_Id;


PROCEDURE Get_Flex_Eco
( p_ECO_rec		IN  ENG_ECO_PUB.ECO_Rec_Type
, x_ECO_rec 		OUT NOCOPY ENG_ECO_PUB.ECO_Rec_Type
)
IS
l_ECO_rec		ENG_Eco_PUB.Eco_Rec_Type := p_ECO_rec;
BEGIN

    --  In the future call Flex APIs for defaults

    IF l_ECO_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute7           := NULL;
    END IF;

    IF l_ECO_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute8           := NULL;
    END IF;

    IF l_ECO_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute9           := NULL;
    END IF;

    IF l_ECO_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute10          := NULL;
    END IF;

    IF l_ECO_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute11          := NULL;
    END IF;

    IF l_ECO_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute12          := NULL;
    END IF;

    IF l_ECO_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute13          := NULL;
    END IF;

    IF l_ECO_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute14          := NULL;
    END IF;

    IF l_ECO_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute15          := NULL;
    END IF;

    IF l_ECO_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute_category   := NULL;
    END IF;

    IF l_ECO_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute1           := NULL;
    END IF;

    IF l_ECO_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute2           := NULL;
    END IF;

    IF l_ECO_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute3           := NULL;
    END IF;

    IF l_ECO_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute4           := NULL;
    END IF;

    IF l_ECO_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute5           := NULL;
    END IF;

    IF l_ECO_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_ECO_rec.attribute6           := NULL;
    END IF;

    x_ECO_rec := l_ECO_rec;

END Get_Flex_Eco;

--  Procedure Attribute_Defaulting

PROCEDURE Attribute_Defaulting
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_Unexp_ECO_rec		    IN OUT NOCOPY ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
l_process_name		VARCHAR2(30) := NULL;
l_err_text		VARCHAR2(240) := NULL;
l_Token_Tbl		Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

cursor status (p_change_order_type_id NUMBER
		    ) is
       SELECT status_code ,status_type
       from  eng_change_statuses_vl
       where status_code in
       (select status_code from  eng_lifecycle_statuses
                        where entity_name='ENG_CHANGE_TYPE'
                        and entity_id1 = p_change_order_type_id
                        and sequence_number =
                           (select min(sequence_number) from eng_lifecycle_statuses
                            where entity_name='ENG_CHANGE_TYPE'
                            and entity_id1 = p_change_order_type_id)
       );


l_status status%ROWTYPE;

BEGIN

    --  Initialize g_ECO_rec
    g_ECO_rec := p_ECO_rec;
    g_Unexp_ECO_rec := p_Unexp_ECO_rec;

    --  Default missing attributes.

    IF g_Unexp_ECO_rec.responsible_org_id IS NULL THEN

        g_Unexp_ECO_rec.responsible_org_id := Get_Responsible_Org;

    END IF;

/*    IF g_Unexp_ECO_rec.status_type IS NULL THEN

    	-- Default to 'Open'

        g_Unexp_ECO_rec.status_type := 1;

    END IF; */

    --11.5.10
    IF g_ECO_rec.plm_or_erp_change='PLM' and g_Unexp_ECO_rec.status_code IS NULL THEN

       OPEN status(g_Unexp_ECO_rec.Change_Order_Type_Id);
	FETCH status INTO l_status;
	IF status%FOUND THEN
  	   g_Unexp_ECO_rec.status_type := l_status.status_type;
	   g_Unexp_ECO_rec.status_code := l_status.status_code;
	ELSE
  	   g_Unexp_ECO_rec.status_type := 1;
	   g_Unexp_ECO_rec.status_code := 1;
	END IF;
	CLOSE status;
   ELSIF g_Unexp_ECO_rec.status_type IS NULL THEN
        g_Unexp_ECO_rec.status_type := 1;
        g_Unexp_ECO_rec.status_code := 1;
    ELSIF g_Unexp_ECO_rec.status_code IS NULL -- Added for bug 3539102
    THEN
    	g_Unexp_ECO_rec.status_code := g_Unexp_ECO_rec.status_type;
    END IF;

    --changed from g_Unexp_ECO_rec.initiation_date := SYSDATE to the follwing bug no:2738054

     g_Unexp_ECO_rec.initiation_date := nvl(g_Unexp_ECO_rec.initiation_date,SYSDATE);

/*    IF g_Unexp_ECO_rec.cancellation_date IS NULL  AND
       g_ECO_rec.status_type = 5
    THEN
    	g_Unexp_ECO_rec.cancellation_date := SYSDATE;
    END IF;
*/

/*    IF g_unexp_eco_rec.project_id = FND_API.G_MISS_NUM
    THEN
	g_unexp_eco_rec.project_id := NULL;
    END IF;

    IF g_unexp_eco_rec.task_id = FND_API.G_MISS_NUM
    THEN
        g_unexp_eco_rec.task_id := NULL;
    END IF;
*/
    /* Added by MK on 11/29/00 Bug #1508078
    -- Defaulting hierarchy_flag and organization_hierarchy
    --
    IF g_ECO_rec.hierarchy_flag IS NULL OR
       g_ECO_rec.hierarchy_flag = FND_API.G_MISS_NUM
    THEN
       g_ECO_rec.hierarchy_flag := 2 ; -- 2 : No
    END IF;
    */

    IF g_ECO_rec.organization_hierarchy = FND_API.G_MISS_CHAR THEN
       g_ECO_rec.organization_hierarchy :=  NULL ;
    END IF;


    -- Eng Change
    IF  g_unexp_eco_rec.change_mgmt_type_code = FND_API.G_MISS_CHAR
    OR  g_unexp_eco_rec.change_mgmt_type_code IS NULL
    THEN
        g_unexp_eco_rec.change_mgmt_type_code := Eng_Globals.G_CHANGE_ORDER ;
    END IF;

    IF g_unexp_eco_rec.assignee_id = FND_API.G_MISS_NUM
    THEN
        g_unexp_eco_rec.assignee_id := NULL;
    END IF;

    IF  g_unexp_eco_rec.source_type_code = FND_API.G_MISS_CHAR
    OR  g_unexp_eco_rec.source_type_code IS NULL
    THEN
        g_unexp_eco_rec.source_type_code := NULL ;
    END IF;

    IF g_unexp_eco_rec.source_id = FND_API.G_MISS_NUM
    THEN
        g_unexp_eco_rec.source_id := NULL;
    END IF;

    IF g_ECO_rec.internal_use_only IS NULL OR
       g_ECO_rec.internal_use_only = FND_API.G_MISS_NUM
    THEN
       g_ECO_rec.internal_use_only := 1 ; -- 1 : Yes
    END IF;

    IF g_ECO_rec.need_by_date = FND_API.G_MISS_DATE THEN
       g_ECO_rec.need_by_date :=  NULL ;
    END IF;

    IF  g_ECO_rec.effort = FND_API.G_MISS_NUM
    THEN
       g_ECO_rec.effort := NULL ;
    END IF;

    g_unexp_eco_rec.change_id := Get_Change_Id;

    --  Done defaulting attributes

    x_ECO_rec := g_ECO_rec;
    x_Unexp_ECO_rec := g_Unexp_ECO_Rec;
    x_return_status := 'S';

END Attribute_Defaulting;

--  Procedure Entity_Defaulting

PROCEDURE Entity_Defaulting
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   p_Old_ECO_rec	 	    IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Old_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   p_control_rec                   IN  BOM_BO_PUB.Control_Rec_Type :=
                                        BOM_BO_PUB.G_DEFAULT_CONTROL_REC
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_Unexp_ECO_rec		    IN OUT NOCOPY ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
l_process_name		VARCHAR2(30) := NULL;
l_ECO_rec		ENG_Eco_PUB.Eco_Rec_Type := p_ECO_rec;
l_Unexp_ECO_rec		ENG_Eco_PUB.Eco_unexposed_Rec_Type := p_Unexp_ECO_rec;
l_processed		BOOLEAN := FALSE;
l_Token_Tbl		Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_err_text		VARCHAR2(2000) := NULL;


-- Added for bug 3591945
l_sql_stmt		VARCHAR2(2000);
l_default_hierarchy_flag NUMBER;

/* Cursor to fetch the default hierarchy set for the change header type */
CURSOR c_change_default_hierarchy (
		cp_change_type_id IN NUMBER,
		cp_organization_id IN NUMBER
		) IS
SELECT pos.organization_structure_id, pos.NAME
FROM per_organization_structures pos
WHERE pos.organization_structure_id in (SELECT hierarchy_id
		FROM ENG_TYPE_ORG_HIERARCHIES
		WHERE change_type_id = cp_change_type_id
		AND organization_id = cp_organization_id
		AND default_hierarchy_flag = 'Y');
BEGIN

    l_token_tbl(1).token_name := 'ECO_NAME';
    l_token_tbl(1).token_value := p_ECO_Rec.ECO_Name;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_ECO_rec.priority_code = FND_API.G_MISS_CHAR
    THEN
    	l_ECO_rec.priority_code := NULL;
    END IF;

    IF l_ECO_rec.approval_list_name = FND_API.G_MISS_CHAR
    THEN
    	l_ECO_rec.approval_list_name := NULL;
    END IF;

    IF l_ECO_rec.ECO_department_name = FND_API.G_MISS_CHAR
    THEN
    	l_ECO_rec.ECO_Department_name := NULL;
    END IF;

    IF l_Unexp_ECO_rec.status_type = FND_API.G_MISS_NUM
    THEN
    	l_Unexp_ECO_rec.status_type := NULL;
    END IF;

    IF l_Unexp_ECO_rec.approval_status_type = FND_API.G_MISS_NUM
    THEN
    	l_Unexp_ECO_rec.approval_status_type := NULL;
    END IF;

    IF l_ECO_rec.reason_code = FND_API.G_MISS_CHAR
    THEN
    	l_ECO_rec.reason_code := NULL;
    END IF;

    IF l_ECO_rec.eng_implementation_cost = FND_API.G_MISS_NUM
    THEN
    	l_ECO_rec.eng_implementation_cost := NULL;
    END IF;

    IF l_ECO_rec.mfg_implementation_cost = FND_API.G_MISS_NUM
    THEN
    	l_ECO_rec.mfg_implementation_cost := NULL;
    END IF;

    IF l_ECO_rec.cancellation_comments = FND_API.G_MISS_CHAR
    THEN
    	l_ECO_rec.cancellation_comments := NULL;
    END IF;

    IF l_ECO_rec.requestor = FND_API.G_MISS_CHAR
    THEN
    	l_ECO_rec.requestor := NULL;
    END IF;

    IF l_ECO_rec.description = FND_API.G_MISS_CHAR
    THEN
    	l_ECO_rec.description := NULL;
    END IF;

    /* Added by MK on 11/29/00 Bug #1508078
    -- Entity Defaulting
    -- Set null to unexposed data columns
    --
    */
    IF l_Unexp_ECO_rec.initiation_date = FND_API.G_MISS_DATE
    THEN
        l_Unexp_ECO_rec.initiation_date     := NULL ;
    END IF ;

    IF l_Unexp_ECO_rec.implementation_date = FND_API.G_MISS_DATE
    THEN
        l_Unexp_ECO_rec.implementation_date := NULL ;
    END IF ;

    IF  l_Unexp_ECO_rec.cancellation_date = FND_API.G_MISS_DATE
    THEN
        l_Unexp_ECO_rec.cancellation_date   := NULL ;
    END IF ;

    IF  l_ECO_rec.approval_date = FND_API.G_MISS_DATE
    THEN
        l_ECO_rec.approval_date       := NULL ;
    END IF ;

    IF  l_ECO_rec.approval_request_date = FND_API.G_MISS_DATE
    THEN
        l_ECO_rec.approval_request_date := NULL ;
    END IF ;

    -- Eng Change
    IF l_ECO_rec.change_management_type = FND_API.G_MISS_CHAR
    THEN
        l_ECO_rec.change_management_type := NULL;
    END IF;

    -- Eng Change
    IF l_Unexp_ECO_rec.change_mgmt_type_code = FND_API.G_MISS_CHAR
    THEN
        l_Unexp_ECO_rec.change_mgmt_type_code := NULL;
    END IF;

    -- Eng Change
    IF l_ECO_rec.assignee = FND_API.G_MISS_CHAR
    THEN
        l_ECO_rec.assignee := NULL;
    END IF;

/*    -- Eng Change
    IF l_ECO_rec.assignee_company_name = FND_API.G_MISS_CHAR
    THEN
        l_ECO_rec.assignee := NULL;
    END IF;
*/
    -- Eng Change
    IF l_Unexp_ECO_rec.assignee_id = FND_API.G_MISS_NUM
    THEN
        l_Unexp_ECO_rec.assignee_id := NULL;
    END IF;

    IF l_ECO_rec.source_type = FND_API.G_MISS_CHAR
    THEN
        l_ECO_rec.source_type := NULL;
    END IF;

    IF  l_Unexp_ECO_rec.source_type_code = FND_API.G_MISS_CHAR
    THEN
        l_Unexp_ECO_rec.source_type_code := NULL ;
    END IF;

    IF l_ECO_rec.source_name = FND_API.G_MISS_CHAR
    THEN
        l_ECO_rec.source_name := NULL;
    END IF;

    IF g_unexp_eco_rec.source_id = FND_API.G_MISS_NUM
    THEN
        g_unexp_eco_rec.source_id := NULL;
    END IF;

    IF  g_ECO_rec.effort = FND_API.G_MISS_NUM
    THEN
       g_ECO_rec.effort := NULL ;
    END IF;

    IF l_ECO_rec.internal_use_only IS NULL OR
       l_ECO_rec.internal_use_only = FND_API.G_MISS_NUM
    THEN
       l_ECO_rec.internal_use_only := 1 ; -- 1 : Yes
    END IF;

    IF l_ECO_rec.need_by_date = FND_API.G_MISS_DATE THEN
       l_ECO_rec.need_by_date :=  NULL ;
    END IF;


    g_ECO_rec := l_ECO_rec;
    Get_Flex_Eco
    	 ( p_ECO_rec => g_ECO_rec
    	 , x_ECO_rec => l_ECO_rec
    	 );

        -- Initialize Workflow Process

    ENG_Globals.Init_Process_Name
        ( g_Unexp_ECO_rec.change_order_type_id
        , g_ECO_rec.priority_code
        , g_Unexp_ECO_rec.organization_id);

    /*********************************************************************
      -- If caller is the form, then perform this defaulting upon request.
      -- If caller is the open interface, perform it for UPDATEs
      -- Added by AS on 10/07/99 to facilitate ECO form re-architecture.
    **********************************************************************/

    IF (p_control_rec.caller_type = 'FORM' AND
	NVL(p_control_rec.validation_controller, FND_API.G_MISS_CHAR) =
			'PROCESS')
       OR
       l_ECO_rec.transaction_type = ENG_Globals.G_OPR_UPDATE
    THEN
	l_processed := FALSE;

	IF p_control_rec.caller_type = 'OI'
	THEN
		ENG_Globals.Check_Approved_For_Process
		( p_change_notice => l_ECO_rec.ECO_name
		, p_organization_id => l_Unexp_ECO_rec.organization_id
		, x_processed => l_processed
		, x_err_text => l_err_text
		);
	ELSIF (p_control_rec.caller_type = 'FORM' AND
               NVL(p_control_rec.validation_controller, FND_API.G_MISS_CHAR) =
                        'PROCESS' AND
               l_Unexp_ECO_rec.approval_status_type not in (1,3))
	THEN
		l_processed := TRUE;
	END IF;

	IF l_processed
    	THEN
        	-- Issue warning if calling thru open interface. If calling
		-- thru form, user will have been asked for confirmation already

		IF p_control_rec.caller_type = 'OI' AND
		   FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        	THEN
        		Error_Handler.Add_Error_Token
	   			( p_Message_Name => 'ENG_APPROVE_WARNING'
	   			, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
	   			, x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
	   			, p_Token_Tbl => l_Token_Tbl
			        , p_message_type       => 'W'
	   			);
        	END IF;

        	l_Unexp_ECO_rec.approval_status_type := 1;	-- Not Submitted For Approval
        	l_ECO_rec.approval_request_date := NULL;
        	l_ECO_rec.approval_date := NULL;

        	-- Set all "Scheduled" revised items to "Open"

	        BEGIN
		        UPDATE eng_revised_items
        		   SET 	status_type = 1,
        			last_update_date = SYSDATE,
	        		last_updated_by = 'XXX',
		                last_update_login = 'XXX'
		         WHERE organization_id = p_Unexp_ECO_rec.organization_id
        		   AND change_notice = p_ECO_rec.ECO_name
		           AND status_type = 4;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
			WHEN OTHERS THEN
				l_err_text := G_PKG_NAME || ' : (Entity Defaulting) '
						|| substrb(SQLERRM,1,200);
            			Error_Handler.Add_Error_Token
	   				( p_Message_Text => l_err_text
	   				, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
	   				, x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
	   				);
		END;
    	END IF;
    END IF;

    IF l_Unexp_ECO_rec.cancellation_date IS NULL  AND
       l_Unexp_ECO_rec.status_type = 5
    THEN
        l_Unexp_ECO_rec.cancellation_date := SYSDATE;
    END IF;

    l_processed := FALSE;

    IF l_ECO_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
    (l_ECO_rec.priority_code <>
    p_old_ECO_rec.priority_code OR
    (l_ECO_rec.priority_code IS NULL AND
    p_old_ECO_rec.priority_code IS NOT NULL) OR
    (p_old_ECO_rec.priority_code IS NULL AND
    l_ECO_rec.priority_code IS NOT NULL))
    THEN

        -- If process found, null out Approval List and set other approval details accordingly.
        -- Also issue warning.

        ENG_Globals.Init_Process_Name
        	( p_change_order_type_id => l_Unexp_ECO_rec.change_order_type_id
		, p_priority_code	=> l_ECO_rec.priority_code
		, p_organization_id => l_Unexp_ECO_rec.organization_id
		);

    	--  Get new Workflow Process name

    	l_process_name := ENG_Globals.Get_Process_Name;

	IF l_process_name IS NOT NULL
	THEN
	    l_Unexp_ECO_rec.approval_list_id := NULL;
	    l_ECO_rec.approval_request_date := NULL;
	    l_ECO_rec.approval_date := NULL;
	    l_Unexp_ECO_rec.approval_status_type := 1;	-- Not Submitted for Approval

	    IF p_control_rec.caller_type = 'OI' AND
	       FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
        	Error_Handler.Add_Error_Token
	   			( p_Message_Name => 'ENG_APPROV_DETAILS_CHANGED'
	   			, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
	   			, x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
	   			, p_Token_Tbl => l_Token_Tbl
				, p_message_type       => 'W'
	   			);
	    END IF;
        END IF;
        l_processed := TRUE;
    END IF;

    IF l_ECO_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
    (l_Unexp_ECO_rec.change_order_type_id <>
    p_old_Unexp_ECO_rec.change_order_type_id OR
    (l_Unexp_ECO_rec.change_order_type_id IS NULL AND
    p_old_Unexp_ECO_rec.change_order_type_id IS NOT NULL))
    THEN
	IF l_processed
	THEN
	    NULL;
	ELSE

    	    --  Get new Workflow Process name

            ENG_Globals.Init_Process_Name
            	( p_change_order_type_id => l_Unexp_ECO_rec.change_order_type_id
	  	, p_priority_code	=> l_ECO_rec.priority_code
		, p_organization_id => l_Unexp_ECO_rec.organization_id
		);

    	    l_process_name := ENG_Globals.Get_Process_Name;

            -- If process found, null out Approval List and set other approval details accordingly.
            -- Also issue warning.

	    IF l_process_name IS NOT NULL
	    THEN
	    	l_Unexp_ECO_rec.approval_list_id := NULL;
	    	l_ECO_rec.approval_request_date := NULL;
	    	l_ECO_rec.approval_date := NULL;
	    	l_Unexp_ECO_rec.approval_status_type := 1;	-- Not Submitted for Approval

	    	IF p_control_rec.caller_type = 'OI' AND
		   FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            	THEN
        	Error_Handler.Add_Error_Token
	   			( p_Message_Name => 'ENG_APPROV_DETAILS_CHANGED'
	   			, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
	   			, x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
	   			, p_Token_Tbl => l_Token_Tbl
				, p_message_type       => 'W'
	   			);
	    	END IF;
	    END IF;
        END IF;
    END IF;

  IF l_ECO_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
    (l_Unexp_ECO_rec.approval_list_id <>
    p_old_Unexp_ECO_rec.approval_list_id OR
    (l_Unexp_ECO_rec.approval_list_id IS NULL AND
    p_old_Unexp_ECO_rec.approval_list_id IS NOT NULL) OR
    (p_old_Unexp_ECO_rec.approval_list_id IS NULL AND
    l_Unexp_ECO_rec.approval_list_id IS NOT NULL))
    THEN

 	-- No approval list or workflow process

	IF l_Unexp_ECO_rec.approval_status_type IS NULL AND
	   l_process_name IS NULL AND
	   l_Unexp_ECO_rec.approval_list_id IS NULL
	THEN
 	  -- Changed to Not Submitted For Approval ,as a part of Approval Status Changes
	  /* Fix for bug 6413814 - Approval Status should be
                           - 'Not Submitted For Approval' for PLM COs
                           - 'Approved' for ERP ECOs
             Added an If-Else condition to check for plm_or_erp_change column.
          */
          If nvl(l_ECO_rec.plm_or_erp_change,'PLM') = 'PLM' Then
             l_Unexp_ECO_rec.approval_status_type := 1;
             l_ECO_rec.approval_date := NULL;
          Else  /* for ERP Ecos*/
	     l_Unexp_ECO_rec.approval_status_type := 5;  --Bug 5904664
	      l_ECO_rec.approval_date := SYSDATE;    	   --Bug 5904664
	  END IF;
     END IF;


 	-- Approval list or (workflow process and not(Approval Requested))

	IF l_Unexp_ECO_rec.approval_status_type IS NULL AND
	   ((l_process_name IS NOT NULL AND
	     NVL(p_old_Unexp_ECO_rec.approval_status_type, 0) <> 3)
	    OR
	    l_Unexp_ECO_rec.approval_list_id IS NOT NULL)
	THEN
		l_Unexp_ECO_rec.approval_status_type := 1;
		l_ECO_rec.approval_date := NULL;
		l_ECO_rec.approval_request_date := NULL;
        END IF;

    END IF;

    IF l_ECO_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
    (l_Unexp_ECO_rec.approval_status_type <>
    p_old_Unexp_ECO_rec.approval_status_type OR
    (l_Unexp_ECO_rec.approval_status_type IS NULL AND
    p_old_Unexp_ECO_rec.approval_status_type IS NOT NULL) OR
    (p_old_Unexp_ECO_rec.approval_status_type IS NULL AND
    l_Unexp_ECO_rec.approval_status_type IS NOT NULL))
    THEN

    	-- No Workflow Process or approval list id

    	IF l_process_name IS NULL AND
    	   l_Unexp_ECO_rec.approval_list_id IS NULL AND
    	   l_Unexp_ECO_rec.approval_status_type IS NULL
    	THEN
	-- Changed to Not Submitted For Approval ,as a part of Approval Status Changes
	/* Fix for bug 6413814 - Approval Status should be
                           - 'Not Submitted For Approval' for PLM COs
                           - 'Approved' for ERP ECOs
            Added an If-Else condition to check for plm_or_erp_change column.
        */

            If nvl(l_ECO_rec.plm_or_erp_change,'PLM') = 'PLM' Then
              l_Unexp_ECO_rec.approval_status_type := 1;
              l_ECO_rec.approval_date := NULL;
            Else  /* for ERP Ecos*/
	      l_Unexp_ECO_rec.approval_status_type := 5;    	  --Bug 5904664
    	      l_ECO_rec.approval_date := SYSDATE;			  --Bug 5904664
            END IF;
    	END IF;

    	-- Approval requested

    	IF l_Unexp_ECO_rec.approval_status_type = 3
    	THEN
    		l_ECO_rec.approval_request_date := SYSDATE;
    		l_ECO_rec.approval_date := NULL;
    	END IF;

    	-- Approved

    	IF l_Unexp_ECO_rec.approval_status_type = 5
    	THEN
    		l_ECO_rec.approval_date := SYSDATE;
    	ELSE
    		l_ECO_rec.approval_date := NULL;
    	END IF;

    	-- Not Submitted for Approval or Ready to Approve

    	IF l_Unexp_ECO_rec.approval_status_type IN (1,2)
    	THEN
    		l_ECO_rec.approval_request_date := NULL;
    	END IF;

    END IF;


    /* Added by MK on 11/29/00 Bug #1508078
    -- Entity Defaulting hierarchy_flag and organization_hierarchy
    --
    IF l_ECO_rec.hierarchy_flag IS NULL OR
       l_ECO_rec.hierarchy_flag = FND_API.G_MISS_NUM
    THEN
           l_ECO_rec.hierarchy_flag := 2 ; -- 2 : No
    END IF ;

    IF l_ECO_rec.hierarchy_flag <> 1
    THEN
           l_ECO_rec.organization_hierarchy := NULL ;
    END IF ;
    */

    IF l_ECO_rec.organization_hierarchy = FND_API.G_MISS_CHAR
    THEN
           l_ECO_rec.organization_hierarchy := NULL ;
    END IF ;

    -- Changes for bug 3591945
    -- Set the default hierarchy defined at the change type, if any.

    IF l_ECO_rec.organization_hierarchy IS NULL
       AND l_ECO_rec.plm_or_erp_change = 'PLM'
       AND l_ECO_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE
    THEN
    	l_sql_stmt := 'SELECT 1
			FROM AK_CUSTOM_REGION_ITEMS AK_ITEMS, ENG_ATTRIBUTES_SECTIONS_TL ENG_ATTRIBUTES,
			     ENG_ATTRIBUTES_SECTIONS_B ENG_ATTRIBUTES_B, EGO_CUSTOMIZATION_EXT  ATTRIBUTE_EXT
			WHERE
			     AK_ITEMS.ATTRIBUTE_CODE = ENG_ATTRIBUTES.ATTRIBUTE_SECTION_CODE
			     AND  ENG_ATTRIBUTES_B.ATTRIBUTE_SECTION_CODE = ENG_ATTRIBUTES.ATTRIBUTE_SECTION_CODE
			     AND ENG_ATTRIBUTES_B.ATTRIBUTE_SECTION_FLAG= ''A''
			     AND AK_ITEMS.PROPERTY_NAME= ''DISPLAY_SEQUENCE''
			     AND AK_ITEMS.CUSTOMIZATION_CODE=ATTRIBUTE_EXT.CUSTOMIZATION_CODE
			     AND ATTRIBUTE_EXT.CLASSIFICATION1 =:1
			     AND ATTRIBUTE_EXT.CLASSIFICATION2 =  :2
			     AND ATTRIBUTE_EXT.REGION_CODE = ''ENG_ADMIN_CONFIGURATIONS''
			     AND ATTRIBUTE_EXT.REGION_APPLICATION_ID = ''703''	 AND ENG_ATTRIBUTES.language = USERENV(''lang'')
			     AND AK_ITEMS.ATTRIBUTE_CODE =  ''ORGANIZATION_HIERARCHY''	';
	BEGIN
		l_default_hierarchy_flag := 2;
		EXECUTE IMMEDIATE l_sql_stmt INTO l_default_hierarchy_flag USING l_Unexp_ECO_rec.Change_Mgmt_Type_Code, l_Unexp_ECO_rec.Change_Order_Type_Id;
	EXCEPTION
	WHEN OTHERS THEN
		l_default_hierarchy_flag := 2;
	END;
	IF (l_default_hierarchy_flag = 1)
	THEN
		OPEN c_change_default_hierarchy(l_Unexp_ECO_rec.Change_Order_Type_Id, l_Unexp_ECO_rec.Organization_Id);
		FETCH c_change_default_hierarchy INTO l_Unexp_ECO_rec.Hierarchy_Id, l_ECO_rec.organization_hierarchy;
		CLOSE c_change_default_hierarchy;
	END IF;
    END IF;
    -- End changes for bug 3591945
   -- Load out record

   x_ECO_rec := l_ECO_rec;
   x_Unexp_ECO_rec := l_Unexp_ECO_rec;
   x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
END Entity_Defaulting;

--  Procedure Populate_NULL_Columns

PROCEDURE Populate_NULL_Columns
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   p_Old_ECO_rec	 	    IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Old_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_unexposed_Rec_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_Unexp_ECO_rec		    IN OUT NOCOPY ENG_Eco_PUB.Eco_unexposed_Rec_Type
)
IS
l_ECO_rec               ENG_Eco_PUB.Eco_Rec_Type := p_ECO_rec;
l_Unexp_ECO_rec		ENG_Eco_PUB.Eco_unexposed_Rec_Type := p_Unexp_ECO_rec;
BEGIN

    l_Unexp_ECO_rec.initiation_date := p_old_Unexp_ECO_rec.initiation_date;
    l_Unexp_ECO_rec.implementation_date := p_old_Unexp_ECO_rec.implementation_date;
    l_Unexp_ECO_rec.cancellation_date := p_old_Unexp_ECO_rec.cancellation_date;
    l_ECO_rec.approval_date := p_old_ECO_rec.approval_date;
    l_ECO_rec.approval_request_date := p_old_ECO_rec.approval_request_date;

    IF l_Unexp_ECO_rec.requestor_id IS NULL
    THEN
   	l_Unexp_ECO_rec.requestor_id := p_Old_Unexp_ECO_rec.requestor_id;
    END IF;

    IF l_Unexp_ECO_rec.responsible_org_id IS NULL
    THEN
   	l_Unexp_ECO_rec.responsible_org_id := p_Old_Unexp_ECO_rec.responsible_org_id;
    END IF;

    IF l_Unexp_ECO_rec.approval_list_id IS NULL
    THEN
   	l_Unexp_ECO_rec.approval_list_id := p_Old_Unexp_ECO_rec.approval_list_id;
    END IF;

   IF l_Unexp_ECO_rec.change_order_type_id IS NULL
    THEN
   	l_Unexp_ECO_rec.change_order_type_id := p_Old_Unexp_ECO_rec.change_order_type_id;
    END IF;

    IF l_ECO_rec.attribute7 IS NULL THEN
        l_ECO_rec.attribute7 := p_old_ECO_rec.attribute7;
    END IF;

    IF l_ECO_rec.attribute8 IS NULL THEN
        l_ECO_rec.attribute8 := p_old_ECO_rec.attribute8;
    END IF;

    IF l_ECO_rec.attribute9 IS NULL THEN
        l_ECO_rec.attribute9 := p_old_ECO_rec.attribute9;
    END IF;

    IF l_ECO_rec.attribute10 IS NULL THEN
        l_ECO_rec.attribute10 := p_old_ECO_rec.attribute10;
    END IF;

    IF l_ECO_rec.attribute11 IS NULL THEN
        l_ECO_rec.attribute11 := p_old_ECO_rec.attribute11;
    END IF;

    IF l_ECO_rec.attribute12 IS NULL THEN
        l_ECO_rec.attribute12 := p_old_ECO_rec.attribute12;
    END IF;

    IF l_ECO_rec.attribute13 IS NULL THEN
        l_ECO_rec.attribute13 := p_old_ECO_rec.attribute13;
    END IF;

    IF l_ECO_rec.attribute14 IS NULL THEN
        l_ECO_rec.attribute14 := p_old_ECO_rec.attribute14;
    END IF;

    IF l_ECO_rec.attribute15 IS NULL THEN
        l_ECO_rec.attribute15 := p_old_ECO_rec.attribute15;
    END IF;

    IF l_Unexp_ECO_rec.approval_status_type IS NULL THEN
        l_Unexp_ECO_rec.approval_status_type := p_old_Unexp_ECO_rec.approval_status_type;
    END IF;

    IF l_ECO_rec.description IS NULL THEN
        l_ECO_rec.description := p_old_ECO_rec.description;
    END IF;

    --Bug 6378121, Add status_code in the entity defaulting
    IF l_Unexp_ECO_rec.status_code IS NULL THEN
        l_Unexp_ECO_rec.status_code := p_old_Unexp_ECO_rec.status_code;
    END IF;

    IF l_Unexp_ECO_rec.status_type IS NULL THEN
        l_Unexp_ECO_rec.status_type := p_old_Unexp_ECO_rec.status_type;
    END IF;

    IF l_ECO_rec.ECO_Department_Name IS NULL THEN
        l_ECO_rec.ECO_Department_Name := p_old_ECO_rec.ECO_Department_Name;
    END IF;

    IF l_ECO_rec.Approval_List_Name IS NULL THEN
        l_ECO_rec.Approval_List_Name := p_old_ECO_rec.Approval_List_Name;
    END IF;

    IF l_ECO_rec.Requestor IS NULL THEN
        l_ECO_rec.Requestor := p_old_ECO_rec.Requestor;
    END IF;

    IF l_ECO_rec.cancellation_comments IS NULL THEN
        l_ECO_rec.cancellation_comments := p_old_ECO_rec.cancellation_comments;
    END IF;

    IF l_ECO_rec.priority_code IS NULL THEN
        l_ECO_rec.priority_code := p_old_ECO_rec.priority_code;
    END IF;

    IF l_ECO_rec.reason_code IS NULL THEN
        l_ECO_rec.reason_code := p_old_ECO_rec.reason_code;
    END IF;

    IF l_ECO_rec.ENG_implementation_cost IS NULL THEN
        l_ECO_rec.ENG_implementation_cost := p_old_ECO_rec.ENG_implementation_cost;
    END IF;

    IF l_ECO_rec.MFG_implementation_cost IS NULL THEN
        l_ECO_rec.MFG_implementation_cost := p_old_ECO_rec.MFG_implementation_cost;
    END IF;

    IF l_ECO_rec.attribute_category IS NULL THEN
        l_ECO_rec.attribute_category := p_old_ECO_rec.attribute_category;
    END IF;

    IF l_ECO_rec.attribute1 IS NULL THEN
        l_ECO_rec.attribute1 := p_old_ECO_rec.attribute1;
    END IF;

    IF l_ECO_rec.attribute2 IS NULL THEN
        l_ECO_rec.attribute2 := p_old_ECO_rec.attribute2;
    END IF;

    IF l_ECO_rec.attribute3 IS NULL THEN
        l_ECO_rec.attribute3 := p_old_ECO_rec.attribute3;
    END IF;

    IF l_ECO_rec.attribute4 IS NULL THEN
        l_ECO_rec.attribute4 := p_old_ECO_rec.attribute4;
    END IF;

    IF l_ECO_rec.attribute5 IS NULL THEN
        l_ECO_rec.attribute5 := p_old_ECO_rec.attribute5;
    END IF;

    IF l_ECO_rec.attribute6 IS NULL THEN
        l_ECO_rec.attribute6 := p_old_ECO_rec.attribute6;
    END IF;


    /* Added by MK on 11/29/00 Bug #1508078
    -- Modified populating hierarchy_flag and organization_hierarchy
    -- when these are miss values

    IF l_ECO_rec.hierarchy_flag IS NULL
    OR l_ECO_rec.hierarchy_flag = FND_API.G_MISS_NUM
    THEN
        l_ECO_rec.hierarchy_flag := p_old_ECO_rec.hierarchy_flag;
    END IF;
    */

    IF l_ECO_rec.organization_hierarchy IS NULL
    OR l_ECO_rec.organization_hierarchy = FND_API.G_MISS_CHAR
    THEN
        l_ECO_rec.organization_hierarchy := p_old_ECO_rec.organization_hierarchy;
    END IF;


    -- Eng Change
    IF l_Unexp_ECO_rec.change_mgmt_type_code IS NULL
    OR l_Unexp_ECO_rec.change_mgmt_type_code = FND_API.G_MISS_CHAR
    THEN
       l_Unexp_ECO_rec.change_mgmt_type_code := p_Old_Unexp_ECO_rec.change_mgmt_type_code ;
    END IF;

    -- Eng Change
    -- User should be able to null out assignee
    IF l_Unexp_ECO_rec.assignee_id IS NULL
    OR ( l_Unexp_ECO_rec.assignee_id = FND_API.G_MISS_NUM
         AND p_Old_Unexp_ECO_rec.assignee_id IS NULL )
    THEN
       l_Unexp_ECO_rec.assignee_id := p_Old_Unexp_ECO_rec.assignee_id ;
    END IF;


   x_ECO_rec := l_ECO_rec;
   x_Unexp_ECO_rec := l_Unexp_ECO_rec;

END Populate_NULL_Columns;

END ENG_Default_Eco;

/
