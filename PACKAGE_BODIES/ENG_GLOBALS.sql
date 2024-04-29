--------------------------------------------------------
--  DDL for Package Body ENG_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_GLOBALS" AS
/* $Header: ENGSGLBB.pls 120.0.12010000.2 2009/11/12 23:12:56 umajumde ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Globals';

--  Global variable holding ECO workflow approval process name

G_PROCESS_NAME		      VARCHAR2(30) := NULL;
G_System_Information	      System_Information_Rec_Type;


-- Initialize system information record

PROCEDURE Init_System_Info_Rec
(   x_mesg_token_tbl    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status 	OUT NOCOPY VARCHAR2
)
IS
BEGIN
	Eng_Globals.Set_user_id( p_user_id	 => FND_GLOBAL.user_id);
	Eng_Globals.Set_login_id( p_login_id	 => FND_GLOBAL.login_id);
	Eng_Globals.Set_prog_id( p_prog_id 	 => FND_GLOBAL.conc_program_id);
	Eng_Globals.Set_prog_appid( p_prog_appid => FND_GLOBAL.prog_appl_id);
	Eng_Globals.Set_request_id( p_request_id => FND_GLOBAL.conc_request_id);
END Init_System_Info_Rec;


--  Check transaction_type validity

PROCEDURE Transaction_Type_Validity
(   p_transaction_type              IN  VARCHAR2
,   p_entity			    IN  VARCHAR2
,   p_entity_id			    IN  VARCHAR2
,   x_valid			    OUT NOCOPY BOOLEAN
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl		Error_Handler.Token_Tbl_Type;
BEGIN
    l_token_tbl(1).token_name := 'entity_id';
    l_token_tbl(1).token_value := p_entity_id;

    x_valid := TRUE;


    IF ((p_entity IN ('ECO_Header', 'ECO_Rev', 'Rev_Items', 'Ref_Desgs',
                      'Sub_Comps','Sub_Res', 'Op_Res',
                      'Change_Lines', 'People') AND
         NVL(p_transaction_type, FND_API.G_MISS_CHAR)
			NOT IN ('CREATE', 'UPDATE', 'DELETE')))
       OR
       ((p_entity IN ('Rev_Comps','Op_Seq') AND                     -- L1
         NVL(p_transaction_type, FND_API.G_MISS_CHAR)
			NOT IN ('CREATE', 'UPDATE', 'DELETE', 'CANCEL')))
    THEN
    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            IF p_entity = 'ECO_Header'
	    THEN
	 	Error_Handler.Add_Error_Token
              	( p_Message_Name       => 'ENG_ECO_TRANS_TYPE_INVALID'
              	, p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              	, x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              	);
	    ELSIF p_entity = 'ECO_Rev'
	    THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'ENG_REV_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Rev_Items'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'ENG_RIT_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Rev_Comps'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_CMP_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Ref_Desgs'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_RFD_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Sub_Comps'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_SBC_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Op_Seq'                                 --L1
            THEN                                                      --L1
                Error_Handler.Add_Error_Token                         --L1
                ( p_Message_Name       => 'BOM_OP_TRANS_TYPE_INVALID' --L1
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl            --L1
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl            --L1
                );                                                    --L1
            ELSIF p_entity = 'Op_Res'                                 --L1
            THEN                                                      --L1
                Error_Handler.Add_Error_Token                         --L1
                ( p_Message_Name       => 'BOM_RES_TRANS_TYPE_INVALID'--L1
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl            --L1
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl            --L1
                );                                                    --L1
            ELSIF p_entity = 'Sub_Res'                                --L1
            THEN                                                      --L1
                Error_Handler.Add_Error_Token                         --L1
                ( p_Message_Name       => 'BOM_SRC_TRANS_TYPE_INVALID'--L1
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl            --L1
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl            --L1
                );                                                    --L1
            ELSIF p_entity = 'Change_Lines'                           -- Eng Change
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'ENG_CL_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'People'                                -- Eng Change
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'ENG_PEOPLE_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
	    END IF;



        END IF;

        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    	x_valid := FALSE;
    END IF;

END Transaction_Type_Validity;

--  Initialize control record.

FUNCTION Init_Control_Rec
(   p_operation                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
,   x_err_text			    OUT NOCOPY VARCHAR2
)RETURN Control_Rec_Type
IS
l_control_rec                 Control_Rec_Type;
BEGIN

    IF p_control_rec.controlled_operation THEN

        RETURN p_control_rec;

    ELSIF p_operation = G_OPR_NONE THEN

        l_control_rec.default_attributes:=  FALSE;
        l_control_rec.change_attributes :=  FALSE;
        l_control_rec.validate_entity	:=  FALSE;
        l_control_rec.write_to_DB	:=  FALSE;
        l_control_rec.process		:=  p_control_rec.process;
        -- l_control_rec.process_entity	:=  p_control_rec.process_entity;
        l_control_rec.request_category	:=  p_control_rec.request_category;
        l_control_rec.request_name	:=  p_control_rec.request_name;
        l_control_rec.clear_api_cache	:=  p_control_rec.clear_api_cache;
        l_control_rec.clear_api_requests:=  p_control_rec.clear_api_requests;
	-- if the transaction type is null or missing then Process Entity is set to XXXX
	l_control_rec.process_entity	:= 'XXXX';
    ELSIF p_operation = G_OPR_CREATE THEN

        l_control_rec.default_attributes:=   TRUE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity  :=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_operation = G_OPR_UPDATE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   TRUE;
        l_control_rec.validate_entity	:=   TRUE;
        l_control_rec.write_to_DB	:=   TRUE;
        l_control_rec.process		:=   TRUE;
        l_control_rec.process_entity	:=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	:=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_operation = G_OPR_DELETE THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity	  :=   TRUE;
        l_control_rec.write_to_DB	  :=   TRUE;
        l_control_rec.process		  :=   TRUE;
        l_control_rec.process_entity	  :=   G_ENTITY_ALL;
        l_control_rec.clear_api_cache	  :=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSIF p_operation = G_OPR_CANCEL THEN

        l_control_rec.default_attributes:=   FALSE;
        l_control_rec.change_attributes :=   FALSE;
        l_control_rec.validate_entity     :=   TRUE;
        l_control_rec.write_to_DB         :=   TRUE;
        l_control_rec.process             :=   TRUE;
        l_control_rec.process_entity      :=   G_ENTITY_REV_COMPONENT;
        l_control_rec.clear_api_cache     :=   TRUE;
        l_control_rec.clear_api_requests:=   TRUE;

    ELSE

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            x_err_text := G_PKG_NAME || '(Init_Control_Rec) - Invalid Operation' || substrb(SQLERRM,1,60);
            l_control_rec.process_entity  :=   'XXXX';
        END IF;
    END IF;

    RETURN l_control_rec;

END Init_Control_Rec;

PROCEDURE Init_Process_Name
(   p_change_order_type_id                 IN  NUMBER
,   p_priority_code			   IN  VARCHAR2
,   p_organization_id		 	   IN  NUMBER
)
IS
l_process_name 		VARCHAR2(30) := NULL;
BEGIN

	IF p_change_order_type_id IS NULL THEN
		G_PROCESS_NAME := NULL;
	END IF;

        SELECT process_name
        INTO l_process_name
	FROM eng_change_type_processes
 	WHERE change_order_type_id = p_change_order_type_id
	   AND organization_id = p_organization_id          -- 2230130
	   AND (( p_priority_code is NOT NULL
		  AND eng_change_priority_code = p_priority_code)
                OR
	        (p_priority_code is NULL
		  AND eng_change_priority_code is NULL));

	G_PROCESS_NAME := l_process_name;
	G_system_information.wkfl_process := TRUE;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN

		G_PROCESS_NAME := NULL;

END Init_Process_Name;

FUNCTION Get_Process_Name
RETURN VARCHAR2
IS
BEGIN

	RETURN G_PROCESS_NAME;
END Get_Process_Name;


PROCEDURE Add_Request
(   p_entity 			    IN  VARCHAR2
,   p_step			    IN 	VARCHAR2 := NULL
,   p_name			    IN 	VARCHAR2
,   p_category			    IN 	VARCHAR2 := NULL
,   p_processed		  	    IN 	BOOLEAN := FALSE
,   p_attribute1		    IN 	VARCHAR2 := NULL
,   p_attribute2		    IN 	VARCHAR2 := NULL
,   p_attribute3		    IN 	VARCHAR2 := NULL
,   p_attribute4		    IN 	VARCHAR2 := NULL
,   p_attribute5		    IN 	VARCHAR2 := NULL
)
IS
l_next_index		INTEGER := 0;
BEGIN
	l_next_index := NVL(G_REQUEST_TBL.LAST,0) + 1;

	G_REQUEST_TBL(l_next_index).entity := p_entity;
	G_REQUEST_TBL(l_next_index).step := p_step;
	G_REQUEST_TBL(l_next_index).name := p_name;
	G_REQUEST_TBL(l_next_index).category := p_category;
	G_REQUEST_TBL(l_next_index).processed := p_processed;
	G_REQUEST_TBL(l_next_index).attribute1 := p_attribute1;
	G_REQUEST_TBL(l_next_index).attribute2 := p_attribute2;
	G_REQUEST_TBL(l_next_index).attribute3 := p_attribute3;
	G_REQUEST_TBL(l_next_index).attribute4 := p_attribute4;
	G_REQUEST_TBL(l_next_index).attribute5 := p_attribute5;

END Add_Request;

FUNCTION Get_Request_Status
(   p_entity 			    IN  VARCHAR2
,   p_step			    IN 	VARCHAR2 := NULL
,   p_name			    IN 	VARCHAR2
,   p_category			    IN 	VARCHAR2 := NULL
,   p_attribute1		    IN 	VARCHAR2 := NULL
,   p_attribute2		    IN 	VARCHAR2 := NULL
,   p_attribute3		    IN 	VARCHAR2 := NULL
,   p_attribute4		    IN 	VARCHAR2 := NULL
,   p_attribute5		    IN 	VARCHAR2 := NULL
)RETURN BOOLEAN
IS
l_processed 		BOOLEAN := TRUE;
l_index1		NUMBER;
BEGIN
	l_index1 := G_REQUEST_TBL.COUNT;

	FOR l_index IN 1 .. l_index1
	LOOP
		IF G_REQUEST_TBL(l_index).entity = p_entity AND
		   NVL(G_REQUEST_TBL(l_index).step,'NONE') = NVL(p_step,'NONE') AND
		   G_REQUEST_TBL(l_index).name = p_name AND
		   NVL(G_REQUEST_TBL(l_index).category,'NONE') = NVL(p_category,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute1,'NONE') = NVL(p_attribute1,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute2,'NONE') = NVL(p_attribute2,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute3,'NONE') = NVL(p_attribute3,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute4,'NONE') = NVL(p_attribute4,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute5,'NONE') = NVL(p_attribute5,'NONE')
		THEN
			l_processed := G_REQUEST_TBL(l_index).processed;
		END IF;
	END LOOP;

	RETURN l_processed;

END Get_Request_Status;

-- Checks if there is an unprocessed request that matches the parameters

FUNCTION Get_Unprocessed_Request
(   p_entity 			    IN  VARCHAR2
,   p_step			    IN 	VARCHAR2 := NULL
,   p_name			    IN 	VARCHAR2
,   p_category			    IN 	VARCHAR2 := NULL
,   p_attribute1		    IN 	VARCHAR2 := NULL
,   p_attribute2		    IN 	VARCHAR2 := NULL
,   p_attribute3		    IN 	VARCHAR2 := NULL
,   p_attribute4		    IN 	VARCHAR2 := NULL
,   p_attribute5		    IN 	VARCHAR2 := NULL
)RETURN BOOLEAN
IS
l_found 		BOOLEAN := FALSE;
l_index1		NUMBER;
BEGIN
	l_index1 := G_REQUEST_TBL.COUNT;

	FOR l_index IN 1 .. l_index1
	LOOP
		IF G_REQUEST_TBL(l_index).entity = p_entity AND
		   NVL(G_REQUEST_TBL(l_index).step,'NONE') = NVL(p_step,'NONE') AND
		   G_REQUEST_TBL(l_index).name = p_name AND
		   NVL(G_REQUEST_TBL(l_index).category,'NONE') = NVL(p_category,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute1,'NONE') = NVL(p_attribute1,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute2,'NONE') = NVL(p_attribute2,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute3,'NONE') = NVL(p_attribute3,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute4,'NONE') = NVL(p_attribute4,'NONE') AND
		   NVL(G_REQUEST_TBL(l_index).attribute5,'NONE') = NVL(p_attribute5,'NONE') AND
		   NOT G_REQUEST_TBL(l_index).processed
		THEN
			l_found := TRUE;
		END IF;
	END LOOP;

	RETURN l_found;

END Get_Unprocessed_Request;

PROCEDURE Get_Unprocessed_Request_Keys
(   p_entity 			    IN  VARCHAR2
,   p_step			    IN 	VARCHAR2 := NULL
,   p_name			    IN 	VARCHAR2
,   p_category			    IN 	VARCHAR2 := NULL
,   x_attribute			    OUT NOCOPY Request_Key_Tbl_Type
,   x_max_count			    OUT NOCOPY NUMBER
)
IS
l_index1		NUMBER;
l_index2		NUMBER;
BEGIN
	l_index1 := G_REQUEST_TBL.COUNT;
	l_index2 := 0;

	FOR l_index IN 1 .. l_index1
	LOOP
		IF G_REQUEST_TBL(l_index).entity = p_entity AND
		   NVL(G_REQUEST_TBL(l_index).step,'NONE') = NVL(p_step,'NONE') AND
		   G_REQUEST_TBL(l_index).name = p_name AND
		   NVL(G_REQUEST_TBL(l_index).category,'NONE') = NVL(p_category,'NONE') AND
		   G_REQUEST_TBL(l_index).processed = FALSE
		THEN
		   l_index2 := l_index2 + 1;
		   x_attribute(l_index2).attribute1 := G_REQUEST_TBL(l_index).attribute1;
		   x_attribute(l_index2).attribute2 := G_REQUEST_TBL(l_index).attribute2;
		   x_attribute(l_index2).attribute3 := G_REQUEST_TBL(l_index).attribute3;
		   x_attribute(l_index2).attribute4 := G_REQUEST_TBL(l_index).attribute4;
		   x_attribute(l_index2).attribute5 := G_REQUEST_TBL(l_index).attribute5;
		END IF;
	END LOOP;

	x_max_count := l_index2;

END Get_Unprocessed_Request_Keys;

PROCEDURE Clear_Request_Table
IS
BEGIN

	G_REQUEST_TBL.DELETE;

END Clear_Request_Table;

PROCEDURE Init_WHO_Rec
( p_org_id IN NUMBER
, p_user_id IN NUMBER
, p_login_id IN NUMBER
, p_prog_appid IN NUMBER
, p_prog_id IN NUMBER
, p_req_id IN NUMBER
)
IS
BEGIN
        G_WHO_REC.org_id := p_org_id;
	G_WHO_REC.user_id := p_user_id;
	G_WHO_REC.login_id := p_login_id;
	G_WHO_REC.prog_appid := p_prog_appid;
	G_WHO_REC.prog_id:= p_prog_id;
	G_WHO_REC.req_id := p_req_id;
END Init_WHO_Rec;

PROCEDURE Init_WHO_Rec_Entity_Details
( p_entity IN VARCHAR2
, p_transaction_id IN NUMBER
)
IS
BEGIN
        G_WHO_REC.entity := p_entity;
	G_WHO_REC.transaction_id := p_transaction_id;
END Init_WHO_Rec_Entity_Details;

-- If an approved ECO has a process and any part of the ECO is being modified,
-- set ECO Approval Status to 'Not Submitted for Approval' and
-- set Status Type of any scheduled revised items to 'Open'.
-- Also issue warning.

PROCEDURE Check_Approved_For_Process
(   p_change_notice                 IN  VARCHAR2
,   p_organization_id		    IN  NUMBER
,   x_processed			    OUT NOCOPY BOOLEAN
,   x_err_text			    OUT NOCOPY VARCHAR2
)
IS
l_process_name		VARCHAR2(30) := NULL;
l_approval_status_type	NUMBER;
BEGIN

  x_processed := FALSE;

  -- Get Workflow Process name

  l_process_name := ENG_Globals.Get_Process_Name;

  SELECT approval_status_type
  INTO 	 l_approval_status_type
  FROM	 eng_engineering_changes
  WHERE  change_notice = p_change_notice
    AND  organization_id = p_organization_id;

  -- ECO w/ Process is Approved

  IF l_approval_status_type = 5 AND
     l_process_name is NOT NULL
  THEN
        x_processed := TRUE;
  END IF;

  EXCEPTION
    	WHEN NO_DATA_FOUND THEN
        	x_processed := FALSE;

	WHEN OTHERS THEN
	        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        	THEN
            		x_err_text := G_PKG_NAME || '(Check_Approved_For_Process) - ECO Header' || substrb(SQLERRM,1,60);
        	END IF;

        	RAISE FND_API.G_EXC_ERROR;

END Check_Approved_For_Process;

-- Sets ECO to 'Not Submitted For Approval' and any
-- "Scheduled" revised items to "Open"

PROCEDURE Set_Request_For_Approval
(   p_change_notice                 IN  VARCHAR2
,   p_organization_id		    IN  NUMBER
,   x_err_text			    OUT NOCOPY VARCHAR2
)
IS
BEGIN
        -- Set ECO to 'Not Submitted For Approval'

        UPDATE eng_engineering_changes
           SET approval_status_type = 1,
               approval_request_date = null,
               approval_date = null,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID,
	       last_update_login = FND_GLOBAL.LOGIN_ID
         WHERE organization_id = p_organization_id
           AND change_notice = p_change_notice;

        -- Set all "Scheduled" revised items to "Open"

        UPDATE eng_revised_items
           SET status_type = 1,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID,
	       last_update_login = FND_GLOBAL.LOGIN_ID
         WHERE organization_id = p_organization_id
           AND change_notice = p_change_notice
           AND status_type = 4;

        -- Issue warning

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
        	NULL;
	     /* Commented out since a message should not be logged
	        from here anymore

		Eng_Eco_Pub.Log_Error ( p_who_rec       => ENG_GLOBALS.G_WHO_REC
                                   , p_msg_name      => 'ENG_APPROVE_WARNING'
                                   , x_err_text      => x_err_text );
	      */
        END IF;

     EXCEPTION
	WHEN OTHERS THEN
	        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        	THEN
            		x_err_text := G_PKG_NAME || '(Set_Request_For_Approval) -
            				ECO Header and Revised Items' || substrb(SQLERRM,1,60);
        	END IF;

        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Set_Request_For_Approval;

-- Function Get_ECO_Assembly_Type
-- Returns ECO assembly type

FUNCTION Get_ECO_Assembly_Type
( p_change_notice IN VARCHAR2
, p_organization_id IN NUMBER
) RETURN NUMBER
IS
l_assembly_type 	NUMBER := NULL;
l_change_order_type_id 	NUMBER := NULL;
BEGIN
   select assembly_type
   into   l_assembly_type
   from   eng_change_order_types
   where  change_order_type_id =
   	  (select change_order_type_id
   	   from   eng_engineering_changes
   	   where  change_notice = p_change_notice
   	   	  and organization_id = p_organization_id);

   RETURN l_assembly_type;

   EXCEPTION
   	WHEN OTHERS THEN
   		RETURN 0;
END Get_ECO_Assembly_Type;

-- Function ECO_Cannot_Update
-- Checks if the ECO should not be updated

FUNCTION ECO_Cannot_Update
( p_change_notice IN VARCHAR2
, p_organization_id IN NUMBER
)RETURN BOOLEAN
IS
  l_ret				BOOLEAN := FALSE;
  l_process_name		VARCHAR2(30) := NULL;
  l_status_type			NUMBER := NULL;

  cursor get_pri_chgtype_stat is select priority_code, change_order_type_id, status_type
  				  from ENG_ENGINEERING_CHANGES
  				 where change_notice = p_change_notice
  				   and organization_id = p_organization_id;

  cursor check_ECO is		select 1
  				  from ENG_ENGINEERING_CHANGES
  				 where change_notice = p_change_notice
  				   and organization_id = p_organization_id
  				   and approval_status_type = 3;
BEGIN
  for l_open IN check_ECO loop
    l_ret := TRUE;
  end loop;

  for l_details in get_pri_chgtype_stat loop
  	ENG_Globals.Init_Process_Name	( p_change_order_type_id => l_details.change_order_type_id
					, p_priority_code => l_details.priority_code
					, p_organization_id => p_organization_id
					) ;
	l_process_name := ENG_Globals.Get_Process_Name;
	l_status_type := l_details.status_type;
  end loop;

  if (l_ret and l_process_name is not null) or l_status_type in (5,6)
  then
  	RETURN TRUE;
  else
  	RETURN FALSE;
  end if;
END ECO_Cannot_Update;

-- Function Get_PLM_Or_ERP_Change
-- Checks if the ECO is 'PLM' or 'ERP'
-- Added for 3618676

FUNCTION Get_PLM_Or_ERP_Change
( p_change_notice IN VARCHAR2
, p_organization_id IN NUMBER
) RETURN VARCHAR2
IS
CURSOR c_plm_or_erp IS
SELECT nvl(plm_or_erp_change, 'PLM') plm_or_erp
FROM eng_engineering_changes
WHERE change_notice = p_change_notice
AND organization_id = p_organization_id;

l_plm_or_erp_change VARCHAR2(3);

BEGIN
	l_plm_or_erp_change := 'ERP';
	FOR cp IN  c_plm_or_erp
	LOOP
		l_plm_or_erp_change := cp.plm_or_erp;
	END LOOP;
	RETURN l_plm_or_erp_change;
EXCEPTION
WHEN OTHERS THEN
	RETURN l_plm_or_erp_change;
END Get_PLM_Or_ERP_Change;

-- Function Validate_Change_Order_Access
-- The user must have access to the change order assembly type

/* Commented out since this procedure will require changes to
   accomodate new design
*/

/*
PROCEDURE Validate_Change_Order_Access
( p_change_order_type_id 	IN  NUMBER
, p_change_notice		IN  VARCHAR2
, p_organization_id 		IN  NUMBER
, x_change_order_access 	OUT NOCOPY BOOLEAN
, x_err_text 			OUT NOCOPY VARCHAR2
)
IS
l_assembly_type 	NUMBER := 0;
l_profile_value 	NUMBER;
l_err_text		VARCHAR2(2000) := NULL;
BEGIN

  select assembly_type
  into   l_assembly_type
  from   eng_change_order_types
  where  change_order_type_id =
  	  	p_change_order_type_id;

  IF fnd_profile.defined('ENG:ENG_ITEM_ECN_ACCESS')
  THEN
    	l_profile_value := fnd_profile.value('ENG:ENG_ITEM_ECN_ACCESS');
  END IF;

  IF ((l_assembly_type = 2 AND l_profile_value = 1) OR (l_assembly_type = 1))
  THEN
  	x_change_order_access := TRUE;
  ELSE
  	x_change_order_access := FALSE;
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		NULL;
		Eng_Eco_Pub.Log_Error ( p_who_rec       => ENG_GLOBALS.G_WHO_REC
                                  , p_msg_name      => 'ENG_CHGORD_TYPE_DELETED'
                                  , x_err_text      => x_err_text );

		END IF;

	RAISE FND_API.G_EXC_ERROR;

    WHEN OTHER THEN
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            l_err_text := G_PKG_NAME || ' : (Validate_Change_Order_Access) -
            				Change_Notice ' || substrb(SQLERRM,1,200);
		Eng_Eco_Pub.Log_Error ( p_who_rec       => ENG_GLOBALS.G_WHO_REC
                                  , p_msg_name      => NULL
                                  , p_err_text	    => l_err_text
                                  , x_err_text      => x_err_text );
	END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Change_Order_Access;
*/

/****************************************************************************
* The following procedures and functions are the get and set routines for the
* system_information_record.
* Numeric attributes of the record have Get functions with a naming convention
* of Get_<Attribute_Name> ex. Get_Bill_Sequence_Id
* For attributes of type Boolean the convention is IS_<Boolean_Attribute_Name>
* Ex. Is_Eco_Impl will return value of the boolean attribute Eco_Impl.
* Similarly the set procedures will have the convention of Set_<Attribute_Name>
* with the respective attribute Type variable as an input.
* There are also two routines which get and set the entire record as a whole.
* Added 06/21/99 by RC.
*****************************************************************************/

/**************************************************************************
* Function 	: Get_System_Information
* Returns	: System_Information Record
* Parameters IN : None
* Parameters OUT: None
* Purpose	: This procedure will return the value of the system information
*		  record.
****************************************************************************/
FUNCTION Get_System_Information RETURN Eng_Globals.System_Information_Rec_Type
IS
BEGIN
	RETURN G_System_Information;

END Get_System_Information;


/***************************************************************************
* Procedure     : Set_System_Information
* Returns       : None
* Parameters IN : System_Information_Record
* Parameters OUT: None
* Purpose       : This procedure will set the value of the system information
*                 record.
****************************************************************************/
PROCEDURE Set_System_Information
	  ( p_system_information_rec	IN
			Eng_Globals.System_Information_Rec_Type)
IS
BEGIN
	G_System_Information := p_system_information_rec;

END Set_System_Information;

/*****************************************************************************
* Procedure	: Set_Bill_Sequence_id
* Returns	: None
* Parameters IN	: Bill_Sequence_Id
* Parameters OUT: None
* Purpose	: This procedure will set the bill_sequence_id value in the
*		  system_information record.
*
*****************************************************************************/
PROCEDURE Set_Bill_Sequence_id
	  ( p_bill_sequence_id	IN  NUMBER)
IS
BEGIN
	G_System_Information.bill_sequence_id := p_bill_sequence_id;
END;

/***************************************************************************
* Function	: Get_Bill_Sequence_id
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : This function will return the bill_sequence_id value in the
*		  system_information record.
******************************************************************************/
FUNCTION Get_Bill_Sequence_id RETURN NUMBER
IS
BEGIN
	RETURN G_System_Information.bill_sequence_id;

END Get_Bill_Sequence_id;

/*****************************************************************************
* Procedure	: Set_Entity
* Returns	: None
* Parameters IN	: Entity Name
* Parameter OUT : None
* Purpose	: Will set the entity name in the System Information Record.
*
******************************************************************************/
PROCEDURE Set_Entity
	  ( p_entity	IN  VARCHAR2)
IS
BEGIN
	G_System_information.entity := p_entity;
END Set_Entity;

/****************************************************************************
* Function	: Get_Entity
* Returns       : VARCHAR2
* Parameters IN : None
* Parameter OUT : None
* Purpose       : Will return the entity name in the System Information Record.
*
*****************************************************************************/
FUNCTION Get_Entity RETURN VARCHAR2
IS
BEGIN
	RETURN G_System_Information.entity;
END Get_Entity;

/****************************************************************************
* Procedure	: Set_Org_id
* Returns	: None
* Parameters IN	: Organization_Id
* Parameters OUT: None
* Purpose	: Will set the org_id attribute of the sytem_information_record
*
*****************************************************************************/
PROCEDURE Set_Org_id
	  ( p_org_id	IN  NUMBER)
IS
BEGIN
	G_System_Information.org_id := p_org_id;

END Set_Org_Id;

/***************************************************************************
* Function	: Get_Org_id
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the org_id attribute of the
*		  sytem_information_record
*****************************************************************************/
FUNCTION Get_Org_id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.org_id;

END Get_Org_Id;

/****************************************************************************
* Procedure	: Set_Eco_Name
* Returns	: None
* Parameters IN : Eco_Name
* Parameters OUT: None
* Purpose	: Will set the Eco_Name attribute of the
*		  system_information record
******************************************************************************/
PROCEDURE Set_Eco_Name
	  ( p_eco_name	IN VARCHAR2)
IS
BEGIN
	G_System_Information.eco_name := p_eco_name;

END Set_Eco_Name;

/****************************************************************************
* Function	: Get_Eco_Name
* Returns       : VARCHAR2
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the Eco_Name attribute of the
*		  system_information record
*****************************************************************************/
FUNCTION Get_Eco_Name RETURN VARCHAR2
IS
BEGIN
	RETURN G_System_Information.eco_name;

END Get_Eco_Name;

/*****************************************************************************
* Procedure	: Set_User_Id
* Returns	: None
* Parameters IN : User ID
* Parameters OUT: None
* Purpose	: Will set the user ID attribute of the
*		  system_information_record
*****************************************************************************/
PROCEDURE Set_User_Id
	  ( p_user_id	IN  NUMBER)
IS
BEGIN
	-- Now sharing System Information with BOM
	--G_System_Information.user_id := p_user_id;

	Bom_Globals.Set_User_Id(p_user_id);

	-- Also sharing System Information with RTG
        -- added by MK on 11/15/00
	Bom_Rtg_Globals.Set_User_Id(p_user_id);

END Set_User_Id;

/***************************************************************************
* Function	: Get_User_Id
* Returns	: Number
* Parameters IN : None
* Parameters OUT: None
* Purpose	: Will return the user_id attribute from the
*		  system_information_record
*****************************************************************************/
FUNCTION Get_User_ID RETURN NUMBER
IS
BEGIN
	-- Now sharing system information with BOM
	-- RETURN G_System_Information.user_id;

	RETURN Bom_Globals.Get_User_Id;


END Get_User_id;


/****************************************************************************
* Procedure	: Set_Login_Id
* Returns	: None
* Paramaters IN	: p_login_id
* Parameters OUT: None
* Purpose	: Will set the login ID attribute of the system information
*		  record.
*****************************************************************************/
PROCEDURE Set_Login_Id
	  ( p_login_id	IN NUMBER )
IS
BEGIN
	-- Now sharing system information with BOM
	-- G_System_Information.login_id := p_login_id;

	Bom_Globals.Set_Login_Id(p_login_id);

        -- Also sharing System Information with RTG
        -- added by MK on 11/15/00
        Bom_Rtg_Globals.Set_Login_Id(p_login_id) ;

END Set_Login_Id;

/****************************************************************************
* Function	: Get_Login_Id
* Returns       : Number
* Paramaters IN : None
* Parameters OUT: None
* Purpose       : Will retun the login ID attribute of the system information
*                 record.
*****************************************************************************/
FUNCTION Get_Login_Id RETURN NUMBER
IS
BEGIN
	-- Now sharing system information with BOM
	-- RETURN G_System_Information.Login_Id;

	RETURN Bom_Globals.Get_Login_Id;
END;

/***************************************************************************
* Procedure	: Set_Prog_AppId
* Returns	: None
* Parameters IN	: p_prog_appid
* Parameters OUT: None
* Purpose	: Will set the Program Application Id attribute of the
*		  System Information Record.
*****************************************************************************/
PROCEDURE Set_Prog_AppId
	  ( p_prog_Appid	IN  NUMBER )
IS
BEGIN
	-- Now sharing system information with BOM
	-- G_System_Information.prog_appid := p_prog_appid;

	Bom_Globals.Set_Prog_AppId(p_prog_appid);

        -- Also sharing System Information with RTG
        -- added by MK on 11/15/00
        Bom_Rtg_Globals.Set_Prog_AppId(p_prog_appid);

END Set_Prog_AppId;

/***************************************************************************
* Function	: Get_Prog_AppId
* Returns	: Number
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Will return the Program Application Id (prog_appid)
*		  attribute of the system information record.
*****************************************************************************/
FUNCTION Get_Prog_AppId RETURN NUMBER
IS
BEGIN
	-- Now sharing system information with BOM
	-- RETURN G_System_Information.prog_AppId;

	RETURN Bom_Globals.Get_Prog_AppId;

END Get_Prog_AppId;


/***************************************************************************
* Procedure	: Set_Prog_Id
* Returns	: None
* Parameters IN	: p_prog_id
* Parameters OUT: None
* Purpose	: Will set the Program Id attribute of the system information
*		  record.
*****************************************************************************/
PROCEDURE Set_Prog_Id
	  ( p_prog_id 	IN  NUMBER )
IS
BEGIN
	-- Now sharing system information with BOM
	-- G_System_Information.prog_id := p_prog_id;

	Bom_Globals.Set_Prog_Id(p_prog_id);

        -- Also sharing System Information with RTG
        -- added by MK on 11/15/00
        Bom_Rtg_Globals.Set_Prog_Id(p_prog_id);

END Set_Prog_Id;

/***************************************************************************
* Function	: Get_Prog_Id
* Returns	: NUMBER
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will return the Prog_Id attribute of the System
*		  information record.
*****************************************************************************/
FUNCTION Get_Prog_Id RETURN NUMBER
IS
BEGIN
	-- Now sharing system information with BOM
	-- RETURN G_System_Information.prog_id;

	RETURN Bom_Globals.Get_Prog_Id;

END Get_Prog_Id;

/***************************************************************************
* Procedure	: Set_Request_Id
* Returns	: None
* Parameters IN	: p_request_id
* Parameters OUT: None
* Purpose	: Procedure will set the request_id attribute of the
*		  system information record.
*****************************************************************************/
PROCEDURE Set_Request_Id
	  ( p_request_id	IN  NUMBER )
IS
BEGIN
	-- Now sharing system information with BOM
	-- G_System_Information.request_id := p_request_id;

	Bom_Globals.Set_Request_Id(p_request_id);

        -- Also sharing System Information with RTG
        -- added by MK on 11/15/00
        Bom_Rtg_Globals.Set_Request_Id(p_request_id);

END;


/***************************************************************************
* Function	: Get_Request_Id
* Returns	: NUMBER
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will return the value of the request_id attribute
*		  of the system information record.
*****************************************************************************/
FUNCTION Get_Request_id RETURN NUMBER
IS
BEGIN
	-- Now sharing system information with BOM
	-- RETURN G_System_Information.request_id;

	RETURN Bom_Globals.Get_Request_id;

END Get_Request_Id;

/***************************************************************************
* Procedure	: Set_Eco_Impl
* Returns	: None
* Parameters IN	: p_eco_impl
* Parameters OUT: None
* Purpose	: Will set the attribute Eco_Impl of system information record
*		  to true or false based on the implemented status of the ECO
*****************************************************************************/
PROCEDURE Set_Eco_Impl
	  ( p_eco_impl	IN  BOOLEAN )
IS
BEGIN
	G_System_Information.eco_impl := p_eco_impl;

END Set_Eco_Impl;

/***************************************************************************
* Function	: Is_Eco_Impl
* Returns	: BOOLEAN
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will true or false value of the system information
*		  record's attribute Eco_Impl. True if ECO is implemented and
*		  false otherwise.
*****************************************************************************/
FUNCTION Is_Eco_Impl RETURN BOOLEAN
IS
BEGIN
	RETURN G_System_Information.eco_impl;

END Is_Eco_Impl;

/***************************************************************************
* Procedure	: Set_Eco_Cancl
* Returns	: None
* Parameters IN	: p_eco_cancl
* Parameters OUT: None
* Purpose	: Procedure will set the value of the system information
*		  record attribute, Eco_Cancl. True if the Eco is canceled
*		  and false otherwise.
*****************************************************************************/
PROCEDURE Set_Eco_Cancl
	  ( p_eco_cancl	IN  BOOLEAN )
IS
BEGIN
	G_System_Information.eco_cancl := p_eco_cancl;

END Set_Eco_Cancl;

/***************************************************************************
* Function	: Is_Eco_Cancl
* Returns	: BOOLEAN
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will return true or false value of the system
*		  information record's attribute Eco_Cancl.
*****************************************************************************/
FUNCTION Is_Eco_Cancl RETURN BOOLEAN
IS
BEGIN
	RETURN G_System_Information.eco_cancl;

END Is_Eco_Cancl;


/***************************************************************************
* Procedure	: Set_Wkfl_Process
* Returns	: None
* Parameters IN	: p_wkfl_process
* Parameters OUT: None
* Purpose	: Procedure will set a true or false value in the attribute
*		  WKFL_Process of the system information record.
*****************************************************************************/
PROCEDURE Set_Wkfl_Process
	  ( p_wkfl_process	IN  BOOLEAN )
IS
BEGIN
	G_System_Information.wkfl_process := p_wkfl_process;

END Set_Wkfl_Process;

/***************************************************************************
* Function	: Is_Wkfl_Process
* Returns	: BOOLEAN
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will return the value of the system information
*		  record attribute Wkfl_Process. True if a Workflow process
*		  exists the ECO and false otherwise.
*****************************************************************************/
FUNCTION Is_Wkfl_Process RETURN BOOLEAN
IS
BEGIN
	RETURN G_System_Information.wkfl_process;

END Is_Wkfl_Process;


/***************************************************************************
* Procedure	: Set_Eco_Access
* Returns	: None
* Parameters IN	: p_eco_access
* Parameters OUT: None
* Purpose	: Procedure will set the value of the system information record
* 		  attribute Eco_Access. True if the user has access to the ECO
*		  and false otherwise.
*****************************************************************************/
PROCEDURE Set_Eco_Access
	  ( p_eco_access	IN  BOOLEAN )
IS
BEGIN
	G_System_Information.eco_access := p_eco_access;

END Set_Eco_Access;

/***************************************************************************
* Function	: Is_Eco_Access
* Returns	: BOOLEAN
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will return true if the Eco_Access is True and
*		  false otherwise.
*****************************************************************************/
FUNCTION Is_Eco_Access RETURN BOOLEAN
IS
BEGIN
	RETURN G_System_Information.eco_access;

END Is_Eco_Access;

/***************************************************************************
* Procedure	: Set_RItem_Impl
* Returns	: None
* Parameters IN	: p_ritem_impl
* Parameters OUT: None
* Purpose	: Procedure will set the value of system iformation record
*		  attribute RItem_Impl.
*****************************************************************************/
PROCEDURE Set_RItem_Impl
	  ( p_ritem_impl	IN  BOOLEAN )
IS
BEGIN
	G_System_Information.ritem_impl := p_ritem_impl;

END Set_RItem_Impl;

/***************************************************************************
* Function	: Is_RItem_Impl
* Returns	: BOOLEAN
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will answer true or false to the question
*		  Is Revised Item Implemented ?
*****************************************************************************/
FUNCTION Is_RItem_Impl RETURN BOOLEAN
IS
BEGIN
	RETURN G_System_Information.RItem_Impl;

END Is_RItem_Impl;

/***************************************************************************
* Procedure     : Set_RItem_Cancl
* Returns       : None
* Parameters IN : p_ritem_cancl
* Parameters OUT: None
* Purpose       : Procedure will set the value of system information record
*                 attribute RItem_cancl.
*****************************************************************************/
PROCEDURE Set_RItem_Cancl
          ( p_ritem_cancl        IN  BOOLEAN )
IS
BEGIN
        G_System_Information.ritem_cancl := p_ritem_cancl;

END Set_RItem_Cancl;

/***************************************************************************
* Function      : Is_RItem_Cancl
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will answer true or false to the question
*                 Is Revised Item Canceled?
*****************************************************************************/
FUNCTION Is_RItem_Cancl RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.ritem_cancl;

END Is_RItem_Cancl;

/***************************************************************************
* Procedure     : Set_RComp_Cancl
* Returns       : None
* Parameters IN : p_Comp_Cancl
* Parameters OUT: None
* Purpose       : Procedure will set the value of system iformation record
*                 attribute RComp_Cancl.
*****************************************************************************/
PROCEDURE Set_RComp_Cancl
          ( p_rcomp_cancl        IN  BOOLEAN )
IS
BEGIN
        G_System_Information.rcomp_cancl := p_rcomp_cancl;

END Set_RComp_Cancl;

/***************************************************************************
* Function      : Is_RComp_Cancl
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will answer true or false to the question
*                 Is Revised Revised Component canceled ?
*****************************************************************************/
FUNCTION Is_RComp_Cancl RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.rcomp_cancl;

END Is_rcomp_cancl;


/***************************************************************************
* Added by MK on 09/01/2000
* Procedure     : Set_ROp_Cancl
* Returns       : None
* Parameters IN : p_rop_cancl
* Parameters OUT: None
* Purpose       : Procedure will set the value of system iformation record
*                 attribute ROp_Cancl.
*****************************************************************************/
PROCEDURE Set_ROp_Cancl
          ( p_rcomp_cancl        IN  BOOLEAN )
IS
BEGIN
        G_System_Information.rcomp_cancl := p_rcomp_cancl;

END Set_ROp_Cancl;

/***************************************************************************
* Added by MK on 09/01/2000
* Function      : Is_ROp_Cancl
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will answer true or false to the question
*                 Is Revised Operation canceled ?
*****************************************************************************/
FUNCTION Is_ROp_Cancl RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.ROp_cancl;

END Is_ROp_cancl;


/***************************************************************************
* Procedure	: Set_Std_Item_Access
* Returns	: None
* Parameters IN	: p_std_item_access
* Parameters OUT: None
* Purpose	: Will set the value of the attribute STD_Item_Access in the
*		  system information record.
*****************************************************************************/
PROCEDURE Set_Std_Item_Access
	  ( p_std_item_access	IN  NUMBER )
IS
BEGIN
	G_System_Information.std_item_access := p_std_item_access;

END Set_Std_Item_Access;

/**************************************************************************
* Function	: Get_Std_Item_Access
* Returns	: NUMBER
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Will return the value of the Standard Item Access attribute
*		  Std_Item_Access from the system information record.
***************************************************************************/
FUNCTION Get_Std_Item_Access RETURN NUMBER
IS
BEGIN
	RETURN G_System_Information.std_item_access;

END Get_Std_Item_Access;

/***************************************************************************
* Procedure     : Set_Mdl_Item_Access
* Returns       : None
* Parameters IN : p_Mdl_item_access
* Parameters OUT: None
* Purpose       : Will set the value of the attribute Mdl_Item_Access in the
*                 system information record.
*****************************************************************************/
PROCEDURE Set_Mdl_Item_Access
          ( p_mdl_item_access   IN  NUMBER )
IS
BEGIN
        G_System_Information.mdl_item_access := p_mdl_item_access;

END Set_Mdl_Item_Access;

/**************************************************************************
* Function	: Get_Mdl_Item_Access
* Returns	: NUMBER
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Will return the value of the Model Item Access attribute
*		  Mdl_Item_Access from the system information record.
***************************************************************************/
FUNCTION Get_Mdl_Item_Access RETURN NUMBER
IS
BEGIN
	RETURN G_System_Information.mdl_item_access;

END Get_Mdl_Item_Access;


/***************************************************************************
* Procedure     : Set_Pln_Item_Access
* Returns       : None
* Parameters IN : p_Pln_item_access
* Parameters OUT: None
* Purpose       : Will set the value of the attribute Pln_Item_Access in the
*                 system information record.
*****************************************************************************/
PROCEDURE Set_Pln_Item_Access
          ( p_Pln_item_access   IN  NUMBER )
IS
BEGIN
        G_System_Information.Pln_item_access := p_Pln_item_access;

END Set_Pln_Item_Access;

/**************************************************************************
* Function	: Get_Pln_Item_Access
* Returns	: NUMBER
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Will return the value of the Planning Item Access attribute
*		  Pln_Item_Access from the system information record.
***************************************************************************/
FUNCTION Get_Pln_Item_Access RETURN NUMBER
IS
BEGIN
	RETURN G_System_Information.Pln_item_access;

END Get_Pln_Item_Access;

/***************************************************************************
* Procedure     : Set_OC_Item_Access
* Returns       : None
* Parameters IN : p_OC_item_access
* Parameters OUT: None
* Purpose       : Will set the value of the attribute OC_Item_Access in the
*                 system information record.
*****************************************************************************/
PROCEDURE Set_OC_Item_Access
          ( p_oc_item_access   IN  NUMBER )
IS
BEGIN
        G_System_Information.oc_item_access := p_oc_item_access;

END Set_OC_Item_Access;

/**************************************************************************
* Function	: Get_OC_Item_Access
* Returns	: NUMBER
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Will return value of the Option Class Item Access attribute
*		  OC_Item_Access from the system information record.
***************************************************************************/
FUNCTION Get_OC_Item_Access RETURN NUMBER
IS
BEGIN
	RETURN G_System_Information.oc_item_access;

END Get_OC_Item_Access;

/***************************************************************************
* Procedure     : Set_Unit_Effectivity
* Returns       : None
* Parameters IN : p_Unit_Effectivity
* Parameters OUT: None
* Purpose       : Will set the value of the attribute Unit_Effectivity in the
*                 system information record.
*****************************************************************************/
PROCEDURE Set_Unit_Effectivity
          ( p_Unit_Effectivity IN  BOOLEAN )
IS
BEGIN
        G_System_Information.unit_effectivity := p_unit_effectivity;

END Set_Unit_Effectivity;

/**************************************************************************
* Function      : Get_Unit_Effectivity
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return value of the unit effective item attribute
*                 Unit_Effectivity from the system information record.
***************************************************************************/
FUNCTION Get_Unit_Effectivity RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.Unit_Effectivity;

END Get_Unit_Effectivity;

/***************************************************************************
* Procedure     : Set_Unit_Controlled_Item
* Returns       : None
* Parameters IN : p_Unit_Controlled_Item
* Parameters OUT: None
* Purpose       : Will set the value of the attribute Unit_Controlled_Item in
*                 system information record.
*****************************************************************************/
PROCEDURE Set_Unit_Controlled_Item
          ( p_Unit_Controlled_Item IN BOOLEAN)
IS
BEGIN
        G_System_Information.unit_controlled_item := p_unit_controlled_item;

END Set_Unit_Controlled_Item;

/**************************************************************************
* Function      : Get_Unit_Controlled_Item
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return value of the unit effective item attribute
*                 Unit_Controlled_Item from the system information record.
***************************************************************************/
FUNCTION Get_Unit_Controlled_Item RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.Unit_Controlled_Item;

END Get_Unit_Controlled_Item;

/***************************************************************************
* Procedure     : Set_Unit_Controlled_Component
* Returns       : None
* Parameters IN : p_Unit_Controlled_Component
* Parameters OUT: None
* Purpose       : Will set the value of the attribute Unit_Controlled_Component
*                 in the system information record.
*****************************************************************************/
PROCEDURE Set_Unit_Controlled_Component
          ( p_Unit_Controlled_Component IN BOOLEAN)
IS
BEGIN
        G_System_Information.unit_controlled_component
			:= p_unit_controlled_component;

END Set_Unit_Controlled_Component;

/**************************************************************************
* Function      : Get_Unit_Controlled_Component
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return value of the unit effective component attribute
*                 Unit_Controlled_Component from the system information record.
***************************************************************************/
FUNCTION Get_Unit_Controlled_Component RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.Unit_Controlled_Component;

END Get_Unit_Controlled_Component;

/***************************************************************************
* Procedure	: Set_Current_Revision
* Returns	: None
* Parameters IN	: p_current_revision
* Parameters OUT: None
* Purpose	: Procedure will set the current revision attribute of the
*		  system information record.
*****************************************************************************/
PROCEDURE Set_Current_Revision
	  ( p_current_revision 	IN  VARCHAR2 )
IS
BEGIN
	G_System_Information.current_revision := p_current_revision;

END Set_Current_Revision;

/***************************************************************************
* Function	: Get_Current_Revision
* Returns	: VARCHAR2(3)
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will return the value of current revision attribute
*		  of the system information record.
*****************************************************************************/
FUNCTION Get_Current_Revision RETURN VARCHAR2
IS
BEGIN
	RETURN G_System_Information.current_revision;

END Get_Current_Revision;

/***************************************************************************
* Procedure	: Set_BO_Identifier
* Returns	: None
* Parameters IN	: p_bo_identifier
* Parameters OUT: None
* Purpose	: Procedure will set the Business object identifier attribute
*		  BO_Identifier of the system information record.
*****************************************************************************/
PROCEDURE Set_BO_Identifier
	  ( p_bo_identifier	IN  VARCHAR2 )
IS
BEGIN
	G_System_Information.bo_identifier := p_bo_identifier;
	Error_Handler.Set_Bo_Identifier(p_bo_identifier);

END Set_BO_Identifier;

/***************************************************************************
* Function	: Get_BO_Identifier
* Returns	: VARCHAR2
* Parameters IN	: None
* Parameters OUT: None
* Purpose	: Function will return the value of the business object
*		  identifier attribute BO_Identifier from the system
*		  information record.
*****************************************************************************/
FUNCTION Get_BO_Identifier RETURN VARCHAR2
IS
BEGIN
	RETURN G_System_Information.bo_identifier;

END Get_BO_Identifier;


/******************************************************************************
* Procedure : Create_New_Routing
* Parameters IN : Assembly_Item_Id
*                 Organization_Id
*                 Alternate_Routing_Code
*                 Pending from ECN
*                 Common_Routing_Sequence_Id
*                 Routing_Type
*                 WHO columns
*                 Revised_Item_Sequence_Id
* Purpose   : This procedure will be called when a revised operation is
*             the first operation being added on a revised item. This
*             procedure will create a Routing and update the revised item
*             information indicating that routing for this revised item now
*             exists.
******************************************************************************/
PROCEDURE Create_New_Routing
            ( p_assembly_item_id            IN NUMBER
            , p_organization_id             IN NUMBER
            , p_alternate_routing_code      IN VARCHAR2 := NULL
            , p_pending_from_ecn            IN VARCHAR2
            , p_routing_sequence_id         IN NUMBER
            , p_common_routing_sequence_id  IN NUMBER
            , p_routing_type                IN NUMBER
            , p_last_update_date            IN DATE
            , p_last_updated_by             IN NUMBER
            , p_creation_date               IN DATE
            , p_created_by                  IN NUMBER
            , p_login_id                    IN NUMBER
            , p_revised_item_sequence_id    IN NUMBER
            , p_original_system_reference   IN VARCHAR2
            , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
            , x_return_status               OUT NOCOPY VARCHAR2
            )
IS
    -- Error Handlig Variables
    l_return_status VARCHAR2(1);
    l_err_text  VARCHAR2(2000) ;
    l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type ;

BEGIN
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Create New Routing for ECO . . .') ;
   END IF ;

   --
   -- Create New Routing using Routing Information in Revised Item table
   --
   INSERT INTO BOM_OPERATIONAL_ROUTINGS
                    (  assembly_item_id
                     , organization_id
                     , alternate_routing_designator
                     , pending_from_ecn
                     , routing_sequence_id
                     , common_routing_sequence_id
                     , routing_type
                     , last_update_date
                     , last_updated_by
                     , creation_date
                     , created_by
                     , last_update_login
                     , original_system_reference
                     , cfm_routing_flag
                     , completion_subinventory
                     , completion_locator_id
                     , mixed_model_map_flag
                     , priority
                     , ctp_flag
                     , routing_comment
                     )
              SELECT   p_assembly_item_id
                     , p_organization_id
                     , p_alternate_routing_code
                     , p_pending_from_ecn
                     , p_routing_sequence_id
                     , p_common_routing_sequence_id
                     , p_routing_type
                     , p_last_update_date
                     , p_last_updated_by
                     , p_creation_date
                     , p_created_by
                     , p_login_id
                     , p_original_system_reference
-- Bug 2232521
-- Some time NULL value was defaulted to the cfm_routing_flag.
-- So, the form ENGFDECN.fmb is not displaying the Operations.
--                   , cfm_routing_flag
                     , NVL(cfm_routing_flag,2)
                     , completion_subinventory
                     , completion_locator_id
                     , mixed_model_map_flag
                     , priority
                     , ctp_flag
                     , routing_comment
              FROM ENG_REVISED_ITEMS
              WHERE revised_item_sequence_id = p_revised_item_sequence_id ;

   --
   -- Set Routing Sequence Id to Revised Item table
   --
   UPDATE ENG_REVISED_ITEMS
   SET    routing_sequence_id = p_routing_sequence_id
     ,    last_update_date  = p_last_update_date       --  Last Update Date
     ,    last_updated_by   = p_last_updated_by        --  Last Updated By
     ,    last_update_login = p_login_id               --  Last Update Login
   WHERE revised_item_sequence_id = p_revised_item_sequence_id ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Set created routing sequence id : ' || to_char(p_routing_sequence_id)
          || '  to the parenet revised item . . .') ;
   END IF ;


EXCEPTION
   WHEN OTHERS THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Some unknown error in Creating New Routing . . .' || SQLERRM );
      END IF ;

      l_err_text := G_PKG_NAME || 'Utilities  (Create New Routing) '
                                || substrb(SQLERRM,1,200);

      -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

       -- Return the status and message table.
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;
END Create_New_Routing ;


/********************************************************************
* Procedure     : Cancel_Operaiton
* Parameters IN : Common Operation exposed column record
*                 Common Operation unexposed column record
* Parameters OUT: Return Status
*                 Message Token Table
* Purpose       : This procedure will move revised operation to Eng Revised
*                 Operation table and set cansel information.
*                 Also it will delte any child operation resources and sub
*                 operation resources.
*********************************************************************/
PROCEDURE Cancel_Operation
( p_operation_sequence_id  IN  NUMBER
, p_cancel_comments        IN  VARCHAR2
, p_op_seq_num             IN  NUMBER
, p_user_id                IN  NUMBER
, p_login_id               IN  NUMBER
, p_prog_id                IN  NUMBER
, p_prog_appid             IN  NUMBER
, x_mesg_token_tbl         OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status          OUT NOCOPY VARCHAR2
)


IS

    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_Token_Tbl       Error_Handler.Token_Tbl_Type;


BEGIN
   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug('Performing cancel revised operation : '
                                 || to_char(p_operation_sequence_id) || '  . . .') ;
   END IF ;

   --
   -- Insert the cancelled revised operation into
   -- ENG_REVISED_OPERATIONS
   --
   INSERT INTO ENG_REVISED_OPERATIONS (
                   operation_sequence_id
                 , routing_sequence_id
                 , operation_seq_num
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , standard_operation_id
                 , department_id
                 , operation_lead_time_percent
                 , minimum_transfer_quantity
                 , count_point_type
                 , operation_description
                 , effectivity_date
                 , disable_date
                 , backflush_flag
                 , option_dependent_flag
                 , attribute_category
                 , attribute1
                 , attribute2
                 , attribute3
                 , attribute4
                 , attribute5
                 , attribute6
                 , attribute7
                 , attribute8
                 , attribute9
                 , attribute10
                 , attribute11
                 , attribute12
                 , attribute13
                 , attribute14
                 , attribute15
                 , request_id
                 , program_application_id
                 , program_id
                 , program_update_date
                 , operation_type
                 , reference_flag
                 , process_op_seq_id
                 , line_op_seq_id
                 , yield
                 , cumulative_yield
                 , reverse_cumulative_yield
                 , labor_time_calc
                 , machine_time_calc
                 , total_time_calc
                 , labor_time_user
                 , machine_time_user
                 , total_time_user
                 , net_planning_percent
                 , x_coordinate
                 , y_coordinate
                 , include_in_rollup
                 , operation_yield_enabled
                 , change_notice
                 , implementation_date
                 , old_operation_sequence_id
                 , acd_type
                 , revised_item_sequence_id
                 , cancellation_date
                 , cancel_comments
                 , original_system_reference )
          SELECT
                   OPERATION_SEQUENCE_ID
                 , ROUTING_SEQUENCE_ID
                 , OPERATION_SEQ_NUM
                 , SYSDATE                  /* Last Update Date */
                 , p_user_id                /* Last Updated By */
                 , SYSDATE                  /* Creation Date */
                 , p_user_id                /* Created By */
                 , p_login_id               /* Last Update Login */
                 , STANDARD_OPERATION_ID
                 , DEPARTMENT_ID
                 , OPERATION_LEAD_TIME_PERCENT
                 , MINIMUM_TRANSFER_QUANTITY
                 , COUNT_POINT_TYPE
                 , OPERATION_DESCRIPTION
                 , EFFECTIVITY_DATE
                 , DISABLE_DATE
                 , BACKFLUSH_FLAG
                 , OPTION_DEPENDENT_FLAG
                 , ATTRIBUTE_CATEGORY
                 , ATTRIBUTE1
                 , ATTRIBUTE2
                 , ATTRIBUTE3
                 , ATTRIBUTE4
                 , ATTRIBUTE5
                 , ATTRIBUTE6
                 , ATTRIBUTE7
                 , ATTRIBUTE8
                 , ATTRIBUTE9
                 , ATTRIBUTE10
                 , ATTRIBUTE11
                 , ATTRIBUTE12
                 , ATTRIBUTE13
                 , ATTRIBUTE14
                 , ATTRIBUTE15
                 , NULL                       /* Request Id */
                 , p_prog_appid               /* Application Id */
                 , p_prog_id                  /* Program Id */
                 , SYSDATE                    /* program_update_date */
                 , OPERATION_TYPE
                 , REFERENCE_FLAG
                 , PROCESS_OP_SEQ_ID
                 , LINE_OP_SEQ_ID
                 , YIELD
                 , CUMULATIVE_YIELD
                 , REVERSE_CUMULATIVE_YIELD
                 , LABOR_TIME_CALC
                 , MACHINE_TIME_CALC
                 , TOTAL_TIME_CALC
                 , LABOR_TIME_USER
                 , MACHINE_TIME_USER
                 , TOTAL_TIME_USER
                 , NET_PLANNING_PERCENT
                 , X_COORDINATE
                 , Y_COORDINATE
                 , INCLUDE_IN_ROLLUP
                 , OPERATION_YIELD_ENABLED
                 , CHANGE_NOTICE
                 , IMPLEMENTATION_DATE
                 , OLD_OPERATION_SEQUENCE_ID
                 , ACD_TYPE
                 , REVISED_ITEM_SEQUENCE_ID
                 , SYSDATE                    /* Cancellation Date */
                 , p_cancel_comments          /* Cancel Comments */
                 , ORIGINAL_SYSTEM_REFERENCE
         FROM    BOM_OPERATION_SEQUENCES
         WHERE   operation_sequence_id = p_operation_sequence_id ;


   --
   -- Delete Cancel Revisd Operation from operation table
   --
    DELETE FROM BOM_OPERATION_SEQUENCES
    WHERE  operation_sequence_id = p_operation_sequence_id ;

   --
   -- Delete child Operation Resources
   --
    DELETE FROM BOM_OPERATION_RESOURCES
    WHERE  operation_sequence_id = p_operation_sequence_id ;


    IF SQL%FOUND THEN

         --
         -- Log a warning indicating operation resources and
         -- substitute operation resources also get deleted.
         --
         -- l_Token_Tbl(1).token_name  := 'OP_SEQ_NUMBER';
         -- l_Token_Tbl(1).token_value := p_op_seq_num ;

         Error_Handler.Add_Error_Token
          (   p_Message_Name       => 'BOM_OP_CANCEL_DEL_CHILDREN'
            , p_Message_Text       => NULL
            , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            , p_Token_Tbl          => l_Token_Tbl
            , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
            , p_message_type       => 'W'
          ) ;

    END IF ;


    --
    -- Delete child Sub Operation Resources
    --
    DELETE FROM BOM_SUB_OPERATION_RESOURCES
    WHERE  operation_sequence_id = p_operation_sequence_id ;

   -- Return Token
    x_mesg_token_tbl := l_mesg_token_tbl ;

EXCEPTION
    WHEN OTHERS THEN
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Cancel . . .' || SQLERRM);
       END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Operation Cancel) ' ||
                                        SUBSTR(SQLERRM, 1, 200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return the status and message table.
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Cancel_Operation ;


/*********************************************************************
* Procedure : Perform_Writes_For_Primary_RTG
* Parameters IN : Revised Operation exposed column record
*                 Revised Operation unexposed column record
* Parameters OUT: Return Status
*                 Message Token Table
* Purpose   : This procedure has been moved here from BOM_Op_Seq_UTIL
*             packages to make the RTG object independant of the ENG object.
*             Also modified Common Op record to Rev Op Record.
*             Check if Primary routing for current revised operation exists.
*             Then if not, Create New Primary Routing and
*              New Routing Revision
*********************************************************************/
PROCEDURE Perform_Writes_For_Primary_RTG
        (  p_rev_operation_rec         IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
         , p_rev_op_unexp_rec          IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , p_control_rec               IN  Bom_Rtg_Pub.Control_Rec_Type
                                         := Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
         , x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status             OUT NOCOPY VARCHAR2
        )
IS

    l_rev_operation_rec      Bom_Rtg_Pub.Rev_Operation_Rec_Type ;
    l_rev_op_unexp_rec       Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type ;
    l_routing_sequence_id    NUMBER ; -- Routing Sequence Id
    l_routing_type           NUMBER ; -- Routing Type
-- Bug 2233631
    l_routing_type1           NUMBER ; -- Assembly_type from ENG_CHANGE_ORDER_TYUPES, table.
    -- Error Handlig Variables
    l_return_status          VARCHAR2(1);
    l_temp_return_status     VARCHAR2(1);
    l_err_text               VARCHAR2(2000) ;
    l_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
    l_temp_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
    l_Token_Tbl              Error_Handler.Token_Tbl_Type;

    -- Check if Routing exists
    CURSOR l_rtg_exists_csr ( p_revised_item_id NUMBER
                            , p_organization_id NUMBER
                            , p_alternate_rtg_code VARCHAR2
                            )
    IS
        SELECT 'Routing Exists'
        FROM   DUAL
        WHERE NOT EXISTS ( SELECT  routing_sequence_id
                           FROM    BOM_OPERATIONAL_ROUTINGS
                           WHERE assembly_item_id = p_revised_item_id
                           AND   organization_id  = p_organization_id
                           AND NVL(alternate_routing_designator, FND_API.G_MISS_CHAR)  =
                               NVL(p_alternate_rtg_code,FND_API.G_MISS_CHAR)
             );

    -- Get Eng_Item_Flag for Routing Type value
    CURSOR l_routing_type_csr ( p_revised_item_id NUMBER
                               , p_organization_id NUMBER )
    IS
       SELECT decode(eng_item_flag, 'N', 1, 2) eng_item_flag
       FROM   MTL_SYSTEM_ITEMS
       WHERE  inventory_item_id = p_revised_item_id
       AND    organization_id   = p_organization_id ;

    -- Get Routing_Sequence_id
    CURSOR l_get_rtg_seq_csr
    IS
           SELECT BOM_OPERATIONAL_ROUTINGS_S.NEXTVAL routing_sequence_id
           FROM DUAL ;


BEGIN

   --
   -- Initialize Rev Op Record and Status
   --
   l_rev_operation_rec  := p_rev_operation_rec ;
   l_rev_op_unexp_rec   := p_rev_op_unexp_rec ;
   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;


   IF l_rev_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE THEN

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Check if primary rtg exists and if not, new primary rtg is created. . . ') ;
      END IF;

      --
      -- Revised Operation
      --
         FOR  l_rtg_exists_rec IN l_rtg_exists_csr
                    ( p_revised_item_id => l_rev_op_unexp_rec.revised_item_id
                    , p_organization_id => l_rev_op_unexp_rec.organization_id
                    , p_alternate_rtg_code => l_rev_operation_rec.alternate_routing_code
                    )
         LOOP
            --
            -- Loop executes then the Routing does not exist.
            --
            FOR l_routing_type_rec IN l_routing_type_csr
                    ( p_revised_item_id => p_rev_op_unexp_rec.revised_item_id
                    , p_organization_id => p_rev_op_unexp_rec.organization_id)
            LOOP
               l_routing_type   :=  l_routing_type_rec.eng_item_flag ;
            END LOOP ;

-- Bug 2233631
-- Say assembly item a#1 is a Manufacturing Item, and routing was created
-- through ECO (Engineering type).  Then this routing should be created in
-- Engineering routing.  So, this routing should be displayed only in the
-- Engineering (prototype) responsibility.  But becasue of the above condition
-- It was created as a Manufaturing routing. Now I am adding one more condition
-- to check wether the routing is created for Engineering or Manufacturing res
-- ponsibility.

             l_routing_type1 :=  Get_ECO_Assembly_Type(l_rev_operation_rec.ECO_name,p_rev_op_unexp_rec.organization_id);
             if (l_routing_type1 <> 0) then
                l_routing_type := l_routing_type1;
             end if;

--Bug 2233631 End

            -- If Caller Type is FORM, Generate new routing_sequence_id
            --
            IF p_control_rec.caller_type = 'FORM'
            THEN
               FOR l_get_rtg_seq_rec IN l_get_rtg_seq_csr
               LOOP
               l_rev_op_unexp_rec.routing_sequence_id :=
                        l_get_rtg_seq_rec.routing_sequence_id;
               END LOOP;

               l_Token_Tbl(1).token_name  := 'REVISED_ITEM_NAME';
--Bug 3614603
               l_Token_Tbl(1).token_value := p_rev_operation_rec.revised_item_name ;
               l_Token_Tbl(2).token_name  := 'OP_SEQ_NUMBER';
               l_Token_Tbl(2).token_value := p_rev_operation_rec.operation_sequence_number ;

               Error_Handler.Add_Error_Token
               (  p_Message_Name       => 'BOM_NEW_PRIMARY_RTG_CREATED'
                , p_Message_Text       => NULL
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , p_message_type       => 'W'

               ) ;
            ELSE

               --
               -- Log a warning indicating that a new bill has been created
               -- as a result of the operation being added.
               --
               l_Token_Tbl(1).token_name  := 'REVISED_ITEM_NAME';
--Bug 3614603
               l_Token_Tbl(1).token_value := p_rev_operation_rec.revised_item_name;
               l_Token_Tbl(2).token_name  := 'OP_SEQ_NUMBER';
               l_Token_Tbl(2).token_value := p_rev_operation_rec.operation_sequence_number ;

               Error_Handler.Add_Error_Token
                    (  p_Message_Name       => 'BOM_NEW_PRIMARY_RTG_CREATED'
                     , p_Message_Text       => NULL
                     , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                     , p_Token_Tbl          => l_Token_Tbl
                     , p_message_type       => 'W'
                    ) ;
            END IF ;

            --
            -- Create New Routing using Routing Attributes in Revised Items table
            --
            Eng_Globals.Create_New_Routing
            ( p_assembly_item_id            => l_rev_op_unexp_rec.revised_item_id
            , p_organization_id             => l_rev_op_unexp_rec.organization_id
            , p_pending_from_ecn            => l_rev_operation_rec.eco_name
            , p_routing_sequence_id         => l_rev_op_unexp_rec.routing_sequence_id
            , p_common_routing_sequence_id  => l_rev_op_unexp_rec.routing_sequence_id
            , p_routing_type                => l_routing_type
            , p_last_update_date            => SYSDATE
            , p_last_updated_by             => BOM_Rtg_Globals.Get_User_Id
            , p_creation_date               => SYSDATE
            , p_created_by                  => BOM_Rtg_Globals.Get_User_Id
            , p_login_id                    => BOM_Rtg_Globals.Get_Login_Id
            , p_revised_item_sequence_id    => l_rev_op_unexp_rec.revised_item_sequence_id
            , p_original_system_reference   => l_rev_operation_rec.original_system_reference
            , x_Mesg_Token_Tbl              => l_temp_mesg_token_Tbl
            , x_return_status               => l_temp_return_status
            ) ;


            IF l_temp_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
                l_return_status  := l_temp_return_status ;
                l_mesg_token_Tbl := l_temp_Mesg_Token_Tbl ;

            ELSE
                -- Create a new routing revision for the created primary routing
                INSERT INTO MTL_RTG_ITEM_REVISIONS
                       (  inventory_item_id
                        , organization_id
                        , process_revision
                        , implementation_date
                        , last_update_date
                        , last_updated_by
                        , creation_date
                        , created_by
                        , last_update_login
                        , change_notice
                        , ecn_initiation_date
                        , effectivity_date
                        , revised_item_sequence_id
                        )
                        SELECT
                          l_rev_op_unexp_rec.revised_item_id
                        , l_rev_op_unexp_rec.organization_id
                        , mp.starting_revision
                        , SYSDATE
                        , SYSDATE
                        , BOM_Rtg_Globals.Get_User_Id
                        , SYSDATE
                        , BOM_Rtg_Globals.Get_User_Id
                        , BOM_Rtg_Globals.Get_Login_Id
                        , l_rev_operation_rec.eco_name
                        , SYSDATE
                        , SYSDATE
                        , l_rev_op_unexp_rec.revised_item_sequence_id
                        FROM MTL_PARAMETERS mp
                        WHERE mp.organization_id = l_rev_op_unexp_rec.organization_id
                        AND   NOT EXISTS( SELECT NULL
                                          FROM MTL_RTG_ITEM_REVISIONS
                                          WHERE implementation_date IS NOT NULL
                                          AND   organization_id   = l_rev_op_unexp_rec.organization_id
                                          AND   inventory_item_id = l_rev_op_unexp_rec.revised_item_id
                        ) ;

      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Creating new routing revision for the created primary routing for the revised item . . . ') ;
      END IF;


            END IF ;

         END LOOP ;

    END IF ; -- End of Create
    --
    -- Return Status
    --
    x_return_status  := l_return_status ;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl ;

EXCEPTION
   WHEN OTHERS THEN
      IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Some unknown error in Perform Writes . . .' || SQLERRM );
      END IF ;

      l_err_text := G_PKG_NAME || ' Utility (Perform Writes for Primary Rtg) '
                                || substrb(SQLERRM,1,200);

      -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

       -- Return the status and message table.
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;


END Perform_Writes_for_Primary_RTG ;


FUNCTION Compatible_Primary_Rtg_Exists
 	   (  p_revised_item_id    IN NUMBER
 	     , p_change_notice      IN VARCHAR2
 	   , p_organization_id    IN NUMBER
 	  ) RETURN BOOLEAN
 	   IS
 	    l_routing_type       NUMBER := 0;

 	    cursor c_CheckRtgType IS
 	                SELECT 1
 	                   FROM BOM_OPERATIONAL_ROUTINGS
 	                   WHERE assembly_item_id = p_revised_item_id
 	                     AND organization_id  = p_organization_id
 	                     AND alternate_routing_designator is null
 	                    AND ((routing_type = 1 and l_routing_type = 1)
 	                          or l_routing_type = 2);
 	    BEGIN

 	          l_routing_type := ENG_Globals.Get_ECO_Assembly_Type
 	                             (  p_change_notice   => p_change_notice
 	                              , p_organization_id => p_organization_id
 	                             );

 	          FOR l_Count IN c_CheckRtgType LOOP
 	                  RETURN TRUE;
 	           END LOOP;

 	           RETURN FALSE;

 	    END Compatible_Primary_Rtg_Exists;










 	 --the following procedure has been added for bug 8970186
 	 /*********************************************************************
 	 * Procedure : Perform_Writes_For_Alt_RTG
 	 * Parameters IN : Revised Operation exposed column record
 	 *                 Revised Operation unexposed column record
 	 * Parameters OUT: Return Status
 	 *                 Message Token Table
 	 * Purpose   : This procedure has been created for Bug 9088260
 	 *             Check if Alternate routing for current revised operation exists.
 	 *             Then if not, Create New Alternate Routing and
 	 *              New Routing Revision  after checking that compatible primary
 	 *              routing exists.
 	 *********************************************************************/
 	 PROCEDURE Perform_Writes_For_Alt_RTG
 	         (  p_rev_operation_rec         IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
 	          , p_rev_op_unexp_rec          IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
 	          , p_control_rec               IN  Bom_Rtg_Pub.Control_Rec_Type
 	                                          := Bom_Rtg_Pub.G_DEFAULT_CONTROL_REC
 	          , x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 	          , x_return_status             OUT NOCOPY VARCHAR2
 	         )
 	 IS

 	     l_rev_operation_rec      Bom_Rtg_Pub.Rev_Operation_Rec_Type ;
 	     l_rev_op_unexp_rec       Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type ;
 	     l_routing_sequence_id    NUMBER ; -- Routing Sequence Id
 	     l_routing_type           NUMBER ; -- Routing Type
 	     l_routing_type1           NUMBER ; -- Assembly_type from ENG_CHANGE_ORDER_TYUPES, table.
 	     -- Error Handlig Variables
 	     l_return_status          VARCHAR2(1);
 	     l_temp_return_status     VARCHAR2(1);
 	     l_err_text               VARCHAR2(2000) ;
 	     l_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
 	     l_temp_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
 	     l_Token_Tbl              Error_Handler.Token_Tbl_Type;

 	     -- Check if Routing exists
 	     CURSOR l_rtg_exists_csr ( p_revised_item_id NUMBER
 	                             , p_organization_id NUMBER
 	                             , p_alternate_rtg_code VARCHAR2
 	                             )
 	     IS
 	         SELECT 'Routing Exists'
 	         FROM   DUAL
 	         WHERE NOT EXISTS ( SELECT  routing_sequence_id
 	                            FROM    BOM_OPERATIONAL_ROUTINGS
 	                            WHERE assembly_item_id = p_revised_item_id
 	                            AND   organization_id  = p_organization_id
 	                            AND alternate_routing_designator  = p_alternate_rtg_code
 	              );

 	     -- Get Eng_Item_Flag for Routing Type value
 	     CURSOR l_routing_type_csr ( p_revised_item_id NUMBER
 	                                , p_organization_id NUMBER )
 	     IS
 	        SELECT decode(eng_item_flag, 'N', 1, 2) eng_item_flag
 	        FROM   MTL_SYSTEM_ITEMS
 	        WHERE  inventory_item_id = p_revised_item_id
 	        AND    organization_id   = p_organization_id ;

 	     -- Get Routing_Sequence_id
 	     CURSOR l_get_rtg_seq_csr
 	     IS
 	            SELECT BOM_OPERATIONAL_ROUTINGS_S.NEXTVAL routing_sequence_id
 	            FROM DUAL ;


 	 BEGIN

 	    --
 	    -- Initialize Rev Op Record and Status
 	    --
 	    l_rev_operation_rec  := p_rev_operation_rec ;
 	    l_rev_op_unexp_rec   := p_rev_op_unexp_rec ;
 	    l_return_status      := FND_API.G_RET_STS_SUCCESS ;
 	    x_return_status      := FND_API.G_RET_STS_SUCCESS ;


 	    IF l_rev_operation_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE THEN

 	       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
 	       ('Check if alternate rtg exists and if not, new alternate rtg is created after checking
 	          compatible primary routing exists  . . . ') ;
 	       END IF;

 	       --
 	       -- Revised Operation
 	       --
 	          FOR  l_rtg_exists_rec IN l_rtg_exists_csr
 	                     ( p_revised_item_id => l_rev_op_unexp_rec.revised_item_id
 	                     , p_organization_id => l_rev_op_unexp_rec.organization_id
 	                     , p_alternate_rtg_code => l_rev_operation_rec.alternate_routing_code
 	                     )
 	          LOOP
 	             --
 	             -- Loop executes then the Routing does not exist.
 	             --

 	              IF  Compatible_Primary_Rtg_Exists
 	              (  p_revised_item_id  => l_rev_op_unexp_rec.revised_item_id
 	               , p_change_notice    => l_rev_operation_rec.ECO_name
 	               , p_organization_id  => l_rev_op_unexp_rec.organization_id
 	               )

 	          THEN

 	             FOR l_routing_type_rec IN l_routing_type_csr
 	                     ( p_revised_item_id => p_rev_op_unexp_rec.revised_item_id
 	                     , p_organization_id => p_rev_op_unexp_rec.organization_id)
 	             LOOP
 	                l_routing_type   :=  l_routing_type_rec.eng_item_flag ;
 	             END LOOP ;


 	              l_routing_type1 :=  Get_ECO_Assembly_Type(l_rev_operation_rec.ECO_name,p_rev_op_unexp_rec.organization_id);
 	              if (l_routing_type1 <> 0) then
 	                 l_routing_type := l_routing_type1;
 	              end if;



 	             -- If Caller Type is FORM, Generate new routing_sequence_id
 	             --
 	             IF p_control_rec.caller_type = 'FORM'
 	             THEN
 	                FOR l_get_rtg_seq_rec IN l_get_rtg_seq_csr
 	                LOOP
 	                l_rev_op_unexp_rec.routing_sequence_id :=
 	                         l_get_rtg_seq_rec.routing_sequence_id;
 	                END LOOP;

 	                l_Token_Tbl(1).token_name  := 'REVISED_ITEM_NAME';
 	                l_Token_Tbl(1).token_value := p_rev_operation_rec.revised_item_name ;
 	                l_Token_Tbl(2).token_name  := 'OP_SEQ_NUMBER';
 	                l_Token_Tbl(2).token_value := p_rev_operation_rec.operation_sequence_number ;

 	                Error_Handler.Add_Error_Token
 	                (  p_Message_Name       => 'BOM_NEW_ALTERNATE_RTG_CREATED'
 	                 , p_Message_Text       => NULL
 	                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
 	                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
 	                 , p_message_type       => 'W'

 	                ) ;
 	             ELSE

 	                --
 	                -- Log a warning indicating that a new bill has been created
 	                -- as a result of the operation being added.
 	                --
 	                l_Token_Tbl(1).token_name  := 'REVISED_ITEM_NAME';
 	                l_Token_Tbl(1).token_value := p_rev_operation_rec.revised_item_name;
 	                l_Token_Tbl(2).token_name  := 'OP_SEQ_NUMBER';
 	                l_Token_Tbl(2).token_value := p_rev_operation_rec.operation_sequence_number ;

 	                Error_Handler.Add_Error_Token
 	                     (  p_Message_Name       => 'BOM_NEW_ALTERNATE_RTG_CREATED'
 	                      , p_Message_Text       => NULL
 	                      , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
 	                      , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
 	                      , p_Token_Tbl          => l_Token_Tbl
 	                      , p_message_type       => 'W'
 	                     ) ;
 	             END IF ;

 	             --
 	             -- Create New Routing using Routing Attributes in Revised Items table
 	             --
 	             Eng_Globals.Create_New_Routing
 	             ( p_assembly_item_id            => l_rev_op_unexp_rec.revised_item_id
 	             , p_organization_id             => l_rev_op_unexp_rec.organization_id
 	             , p_alternate_routing_code      => l_rev_operation_rec.alternate_routing_code
 	             , p_pending_from_ecn            => l_rev_operation_rec.eco_name
 	             , p_routing_sequence_id         => l_rev_op_unexp_rec.routing_sequence_id
 	             , p_common_routing_sequence_id  => l_rev_op_unexp_rec.routing_sequence_id
 	             , p_routing_type                => l_routing_type
 	             , p_last_update_date            => SYSDATE
 	             , p_last_updated_by             => BOM_Rtg_Globals.Get_User_Id
 	             , p_creation_date               => SYSDATE
 	             , p_created_by                  => BOM_Rtg_Globals.Get_User_Id
 	             , p_login_id                    => BOM_Rtg_Globals.Get_Login_Id
 	             , p_revised_item_sequence_id    => l_rev_op_unexp_rec.revised_item_sequence_id
 	             , p_original_system_reference   => l_rev_operation_rec.original_system_reference
 	             , x_Mesg_Token_Tbl              => l_temp_mesg_token_Tbl
 	             , x_return_status               => l_temp_return_status
 	             ) ;



 	             IF l_temp_return_status <> FND_API.G_RET_STS_SUCCESS
 	             THEN
 	                 l_return_status  := l_temp_return_status ;
 	                 l_mesg_token_Tbl := l_temp_Mesg_Token_Tbl ;

 	             ELSE
 	                 -- Create a new routing revision for the created alternate routing

 	                 INSERT INTO MTL_RTG_ITEM_REVISIONS
 	                        (  inventory_item_id
 	                         , organization_id
 	                         , process_revision
 	                         , implementation_date
 	                         , last_update_date
 	                         , last_updated_by
 	                         , creation_date
 	                         , created_by
 	                         , last_update_login
 	                         , change_notice
 	                         , ecn_initiation_date
 	                         , effectivity_date
 	                         , revised_item_sequence_id
 	                         )
 	                         SELECT
 	                           l_rev_op_unexp_rec.revised_item_id
 	                         , l_rev_op_unexp_rec.organization_id
 	                         , mp.starting_revision
 	                         , SYSDATE
 	                         , SYSDATE
 	                         , BOM_Rtg_Globals.Get_User_Id
 	                         , SYSDATE
 	                         , BOM_Rtg_Globals.Get_User_Id
 	                         , BOM_Rtg_Globals.Get_Login_Id
 	                         , l_rev_operation_rec.eco_name
 	                         , SYSDATE
 	                         , SYSDATE
 	                         , l_rev_op_unexp_rec.revised_item_sequence_id
 	                         FROM MTL_PARAMETERS mp
 	                         WHERE mp.organization_id = l_rev_op_unexp_rec.organization_id
 	                         AND   NOT EXISTS( SELECT NULL
 	                                           FROM MTL_RTG_ITEM_REVISIONS
 	                                           WHERE implementation_date IS NOT NULL
 	                                           AND   organization_id   = l_rev_op_unexp_rec.organization_id
 	                                           AND   inventory_item_id = l_rev_op_unexp_rec.revised_item_id
 	                         ) ;

 	       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
 	       ('Creating new routing revision for the created alternate routing for the revised item . . . ') ;
 	       END IF;


 	             END IF ;
 	         END IF;
 	          END LOOP ;

 	     END IF ; -- End of Create
 	     --
 	     -- Return Status
 	     --
 	     x_return_status  := l_return_status ;
 	     x_Mesg_Token_Tbl := l_Mesg_Token_Tbl ;

 	 EXCEPTION
 	    WHEN OTHERS THEN
 	       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
 	       ('Some unknown error in Perform Writes . . .' || SQLERRM );
 	       END IF ;

 	       l_err_text := G_PKG_NAME || ' Utility (Perform Writes for Alternate Rtg) '
 	                                 || substrb(SQLERRM,1,200);

 	       -- dbms_output.put_line('Unexpected Error: '||l_err_text);

 	           Error_Handler.Add_Error_Token
 	           (  p_message_name   => NULL
 	            , p_message_text   => l_err_text
 	            , p_mesg_token_tbl => l_mesg_token_tbl
 	            , x_mesg_token_tbl => l_mesg_token_tbl
 	           ) ;

 	        -- Return the status and message table.
 	        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
 	        x_mesg_token_tbl := l_mesg_token_tbl ;


 	 END Perform_Writes_for_Alt_RTG ;



END ENG_Globals;

/
