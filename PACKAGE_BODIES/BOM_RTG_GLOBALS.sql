--------------------------------------------------------
--  DDL for Package Body BOM_RTG_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_GLOBALS" AS
/* $Header: BOMRGLBB.pls 120.1 2006/06/14 06:10:00 abbhardw noship $ */
/**********************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      RTGSGLBB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_RTG_Globals
--
--  NOTES
--
--  HISTORY
--
--  04-AUG-2000 Biao Zhang      Initial Creation
--
**********************************************************************/

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'BOM_Rtg_Globals';

--  Global variable holding ECO workflow approval process name

G_PROCESS_NAME                VARCHAR2(30) := NULL;
G_System_Information          System_Information_Rec_Type;
G_Temp_Op_Rec_Tbl		Temp_Op_Rec_Tbl_Type;

PROCEDURE Init_System_Info_Rec
(   x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status     IN OUT NOCOPY VARCHAR2
)
IS
BEGIN
        BOM_Rtg_Globals.Set_user_id( p_user_id       => FND_GLOBAL.user_id);
        BOM_Rtg_Globals.Set_login_id( p_login_id     => FND_GLOBAL.login_id);
        BOM_Rtg_Globals.Set_prog_id( p_prog_id       => FND_GLOBAL.conc_program_id);
        BOM_Rtg_Globals.Set_prog_appid( p_prog_appid => FND_GLOBAL.prog_appl_id);
        BOM_Rtg_Globals.Set_request_id( p_request_id => FND_GLOBAL.conc_request_id);

END Init_System_Info_Rec;

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
*****************************************************************************/

/**************************************************************************
* Function      : Get_System_Information
* Returns       : System_Information Record
* Parameters IN : None
* Parameters OUT: None
* Purpose       : This procedure will return the value of the system information
*                 record.
****************************************************************************/
FUNCTION Get_System_Information RETURN BOM_Rtg_Globals.System_Information_Rec_Type
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
          ( p_system_information_rec    IN
                        BOM_Rtg_Globals.System_Information_Rec_Type)
IS
BEGIN
        G_System_Information := p_system_information_rec;

END Set_System_Information;


PROCEDURE Check_Approved_For_Process
(   p_change_notice                 IN  VARCHAR2
,   p_organization_id               IN  NUMBER
,   x_processed                     IN OUT NOCOPY BOOLEAN
,   x_err_text                      IN OUT NOCOPY VARCHAR2
)
IS
l_process_name          VARCHAR2(30) := NULL;
l_approval_status_type  NUMBER;
BEGIN
  x_processed := FALSE;
  -- Get Workflow Process name
  l_process_name := BOM_Rtg_Globals.Get_Process_Name;
  SELECT approval_status_type
  INTO   l_approval_status_type
  FROM   eng_engineering_changes
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
                 x_err_text := G_PKG_NAME || '(Check_Approved_For_Process) - '
                                || 'ECO Header' || substrb(SQLERRM,1,60);
                END IF;
                RAISE FND_API.G_EXC_ERROR;

END Check_Approved_For_Process;

PROCEDURE Set_Request_For_Approval
(   p_change_notice                 IN  VARCHAR2
,   p_organization_id               IN  NUMBER
,   x_err_text                      IN OUT NOCOPY VARCHAR2
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

PROCEDURE Init_Process_Name
(   p_change_order_type_id                 IN  NUMBER
,   p_priority_code                        IN  VARCHAR2
,   p_organization_id                      IN  NUMBER
)
IS
l_process_name          VARCHAR2(30) := NULL;
BEGIN

        IF p_change_order_type_id IS NULL THEN
                G_PROCESS_NAME := NULL;
        END IF;

        SELECT process_name
        INTO l_process_name
        FROM eng_change_type_processes
        WHERE change_order_type_id = p_change_order_type_id
           AND ( p_priority_code is NOT NULL
                  AND eng_change_priority_code = p_priority_code
                  AND organization_id = p_organization_id)
                OR
                (p_priority_code is NULL
                  AND eng_change_priority_code is NULL);

        G_PROCESS_NAME := l_process_name;

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

/*****************************************************************************
* Procedure     : Set_Routing_Sequence_Id
* Returns       : None
* Parameters IN : Routing_Sequence_Id
* Parameters OUT: None
* Purpose       : This procedure will set the routing_sequence_id value in the
*                 system_information record.
*
*****************************************************************************/
PROCEDURE Set_Routing_Sequence_id
          ( p_routing_sequence_id       IN  NUMBER)
IS
BEGIN
        G_System_Information.routing_sequence_id := p_routing_sequence_id;
END Set_Routing_Sequence_id ;

/*****************************************************************************
* Procedure     : Set_Common_Rtg_Seq_Id
* Returns       : None
* Parameters IN : Routing_Sequence_Id
* Parameters OUT: None
* Purpose       : This procedure will set common_routing_sequence_id  in the
*                 system_information record.
*
*****************************************************************************/
PROCEDURE Set_Common_Rtg_Seq_Id
          ( p_common_rtg_seq_id IN  NUMBER)
IS
BEGIN
        G_System_Information.common_rtg_seq_id := p_common_rtg_seq_id;
END Set_Common_Rtg_Seq_Id ;


/***************************************************************************
* Function      : Get_Routing_Sequence_Id
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : This function will return the routing_sequence_id value in the
*                 system_information record.
******************************************************************************/
FUNCTION Get_Routing_Sequence_Id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.routing_sequence_id;

END Get_Routing_Sequence_Id;

/***************************************************************************
* Function      : Get_Common_Rtg_Seq_Id
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : This function will return the common_routing_sequence_id value in the
*                 system_information record.
******************************************************************************/
FUNCTION Get_Common_Rtg_Seq_id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.common_rtg_seq_id;

END Get_Common_Rtg_Seq_id ;

/*****************************************************************************
* Procedure     : Set_Entity
* Returns       : None
* Parameters IN : Entity Name
* Parameter OUT : None
* Purpose       : Will set the entity name in the System Information Record.
*
******************************************************************************/
PROCEDURE Set_Entity
          ( p_entity    IN  VARCHAR2)
IS
BEGIN
        G_System_information.entity := p_entity;
END Set_Entity;

/****************************************************************************
* Function      : Get_Entity
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
* Procedure     : Set_Org_Id
* Returns       : None
* Parameters IN : Organization_Id
* Parameters OUT: None
* Purpose       : Will set the org_id attribute of the sytem_information_record
*
*****************************************************************************/
PROCEDURE Set_Org_Id
          ( p_org_id    IN  NUMBER)
IS
BEGIN
        G_System_Information.org_id := p_org_id;

END Set_Org_Id;

/***************************************************************************
* Function      : Get_Org_id
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the org_id attribute of the
*                 sytem_information_record
*****************************************************************************/
FUNCTION Get_Org_id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.org_id;

END Get_Org_Id;

/****************************************************************************
* Procedure     : Set_Eco_Name
* Returns       : None
* Parameters IN : Eco_Name
* Parameters OUT: None
* Purpose       : Will set the Eco_Name attribute of the
*                 system_information record
******************************************************************************/
PROCEDURE Set_Eco_Name
          ( p_eco_name  IN VARCHAR2)
IS
BEGIN
        G_System_Information.eco_name := p_eco_name;

END Set_Eco_Name;

/****************************************************************************
* Function      : Get_Eco_Name
* Returns       : VARCHAR2
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the Eco_Name attribute of the
*                 system_information record
*****************************************************************************/
FUNCTION Get_Eco_Name RETURN VARCHAR2
IS
BEGIN
        RETURN G_System_Information.eco_name;

END Get_Eco_Name;

/*****************************************************************************
* Procedure     : Set_User_Id
* Returns       : None
* Parameters IN : User ID
* Parameters OUT: None
* Purpose       : Will set the user ID attribute of the
*                 system_information_record
*****************************************************************************/
PROCEDURE Set_User_Id
          ( p_user_id   IN  NUMBER)
IS
BEGIN
        G_System_Information.user_id := p_user_id;

END Set_User_Id;

/***************************************************************************
* Function      : Get_User_Id
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the user_id attribute from the
*                 system_information_record
*****************************************************************************/
FUNCTION Get_User_ID RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.user_id;

END Get_User_id;


/****************************************************************************
* Procedure     : Set_Login_Id
* Returns       : None
* Paramaters IN : p_login_id
* Parameters OUT: None
* Purpose       : Will set the login ID attribute of the system information
*                 record.
*****************************************************************************/
PROCEDURE Set_Login_Id
          ( p_login_id  IN NUMBER )
IS
BEGIN
        G_System_Information.login_id := p_login_id;

END Set_Login_Id;

/****************************************************************************
* Function      : Get_Login_Id
* Returns       : Number
* Paramaters IN : None
* Parameters OUT: None
* Purpose       : Will retun the login ID attribute of the system information
*                 record.
*****************************************************************************/
FUNCTION Get_Login_Id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.Login_Id;
END;

/***************************************************************************
* Procedure     : Set_Prog_AppId
* Returns       : None
* Parameters IN : p_prog_appid
* Parameters OUT: None
* Purpose       : Will set the Program Application Id attribute of the
*                 System Information Record.
*****************************************************************************/
PROCEDURE Set_Prog_AppId
          ( p_prog_Appid        IN  NUMBER )
IS
BEGIN
        G_System_Information.prog_appid := p_prog_appid;

END Set_Prog_AppId;

/***************************************************************************
* Function      : Get_Prog_AppId
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the Program Application Id (prog_appid)
*                 attribute of the system information record.
*****************************************************************************/
FUNCTION Get_Prog_AppId RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.prog_AppId;

END Get_Prog_AppId;


/***************************************************************************
* Procedure     : Set_Prog_Id
* Returns       : None
* Parameters IN : p_prog_id
* Parameters OUT: None
* Purpose       : Will set the Program Id attribute of the system information
*                 record.
*****************************************************************************/
PROCEDURE Set_Prog_Id
          ( p_prog_id   IN  NUMBER )
IS
BEGIN
        G_System_Information.prog_id := p_prog_id;

END Set_Prog_Id;

/***************************************************************************
* Function      : Get_Prog_Id
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the Prog_Id attribute of the System
*                 information record.
*****************************************************************************/
FUNCTION Get_Prog_Id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.prog_id;

END Get_Prog_Id;

/***************************************************************************
* Procedure     : Set_Request_Id
* Returns       : None
* Parameters IN : p_request_id
* Parameters OUT: None
* Purpose       : Procedure will set the request_id attribute of the
*                 system information record.
*****************************************************************************/
PROCEDURE Set_Request_Id
          ( p_request_id        IN  NUMBER )
IS
BEGIN
        G_System_Information.request_id := p_request_id;
END;


/***************************************************************************
* Function      : Get_Request_Id
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of the request_id attribute
*                 of the system information record.
*****************************************************************************/
FUNCTION Get_Request_id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.request_id;

END Get_Request_Id;

/***************************************************************************
* Procedure     : Set_Eco_Impl
* Returns       : None
* Parameters IN : p_eco_impl
* Parameters OUT: None
* Purpose       : Will set the attribute Eco_Impl of system information record
*                 to true or false based on the implemented status of the ECO
*****************************************************************************/
PROCEDURE Set_Eco_Impl
          ( p_eco_impl  IN  BOOLEAN )
IS
BEGIN
        G_System_Information.eco_impl := p_eco_impl;

END Set_Eco_Impl;

/***************************************************************************
* Function      : Is_Eco_Impl
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will true or false value of the system information
*                 record's attribute Eco_Impl. True if ECO is implemented and
*                 false otherwise.
*****************************************************************************/
FUNCTION Is_Eco_Impl RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.eco_impl;

END Is_Eco_Impl;

/***************************************************************************
* Procedure     : Set_Eco_Cancl
* Returns       : None
* Parameters IN : p_eco_cancl
* Parameters OUT: None
* Purpose       : Procedure will set the value of the system information
*                 record attribute, Eco_Cancl. True if the Eco is canceled
*                 and false otherwise.
*****************************************************************************/
PROCEDURE Set_Eco_Cancl
          ( p_eco_cancl IN  BOOLEAN )
IS
BEGIN
        G_System_Information.eco_cancl := p_eco_cancl;

END Set_Eco_Cancl;

/***************************************************************************
* Function      : Is_Eco_Cancl
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return true or false value of the system
*                 information record's attribute Eco_Cancl.
*****************************************************************************/
FUNCTION Is_Eco_Cancl RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.eco_cancl;

END Is_Eco_Cancl;


/***************************************************************************
* Procedure     : Set_Wkfl_Process
* Returns       : None
* Parameters IN : p_wkfl_process
* Parameters OUT: None
* Purpose       : Procedure will set a true or false value in the attribute
*                 WKFL_Process of the system information record.
*****************************************************************************/
PROCEDURE Set_Wkfl_Process
          ( p_wkfl_process      IN  BOOLEAN )
IS
BEGIN
        G_System_Information.wkfl_process := p_wkfl_process;

END Set_Wkfl_Process;

/***************************************************************************
* Function      : Is_Wkfl_Process
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of the system information
*                 record attribute Wkfl_Process. True if a Workflow process
*                 exists the ECO and false otherwise.
*****************************************************************************/
FUNCTION Is_Wkfl_Process RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.wkfl_process;

END Is_Wkfl_Process;


/***************************************************************************
* Procedure     : Set_Eco_Access
* Returns       : None
* Parameters IN : p_eco_access
* Parameters OUT: None
* Purpose       : Procedure will set the value of the system information record
*                 attribute Eco_Access. True if the user has access to the ECO
*                 and false otherwise.
*****************************************************************************/
PROCEDURE Set_Eco_Access
          ( p_eco_access        IN  BOOLEAN )
IS
BEGIN
        G_System_Information.eco_access := p_eco_access;

END Set_Eco_Access;

/***************************************************************************
* Function      : Is_Eco_Access
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return true if the Eco_Access is True and
*                 false otherwise.
*****************************************************************************/
FUNCTION Is_Eco_Access RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.eco_access;

END Is_Eco_Access;

/***************************************************************************
* Procedure     : Set_RItem_Impl
* Returns       : None
* Parameters IN : p_ritem_impl
* Parameters OUT: None
* Purpose       : Procedure will set the value of system iformation record
*                 attribute RItem_Impl.
*****************************************************************************/
PROCEDURE Set_RItem_Impl
          ( p_ritem_impl        IN  BOOLEAN )
IS
BEGIN
        G_System_Information.ritem_impl := p_ritem_impl;

END Set_RItem_Impl;

/***************************************************************************
* Function      : Is_RItem_Impl
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will answer true or false to the question
*                 Is Revised Item Implemented ?
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
* Procedure     : Set_Std_Item_Access
* Returns       : None
* Parameters IN : p_std_item_access
* Parameters OUT: None
* Purpose       : Will set the value of the attribute STD_Item_Access in the
*                 system information record.
*****************************************************************************/
PROCEDURE Set_Std_Item_Access
          ( p_std_item_access   IN  NUMBER )
IS
BEGIN
        G_System_Information.std_item_access := p_std_item_access;

END Set_Std_Item_Access;

/**************************************************************************
* Function      : Get_Std_Item_Access
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the value of the Standard Item Access attribute
*                 Std_Item_Access from the system information record.
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
* Function      : Get_Mdl_Item_Access
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the value of the Model Item Access attribute
*                 Mdl_Item_Access from the system information record.
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
        G_System_Information.pln_item_access := p_pln_item_access;

END Set_Pln_Item_Access;

/**************************************************************************
* Function      : Get_Pln_Item_Access
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the value of the Planning Item Access attribute
*                 Pln_Item_Access from the system information record.
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
* Function      : Get_OC_Item_Access
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return value of the Option Class Item Access attribute
*                 OC_Item_Access from the system information record.
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

PROCEDURE Set_Unit_Controlled_Item
( p_inventory_item_id  IN NUMBER
, p_organization_id    IN NUMBER
)
IS
  Cursor Unit_Controlled_Item IS
  SELECT effectivity_control
  FROM mtl_system_items
  WHERE inventory_item_id = p_inventory_item_id
  AND organization_id   = p_organization_id;
BEGIN
        FOR Unit_Cont_Item IN Unit_Controlled_Item
        LOOP
           IF Unit_Cont_Item.Effectivity_Control = 2
           THEN
                G_System_Information.unit_controlled_item := TRUE;
           ELSIF Unit_Cont_Item.Effectivity_Control = 1
           THEN
                G_System_Information.unit_controlled_item := FALSE;
           END IF;
        END LOOP;
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

PROCEDURE Set_Unit_Controlled_Component
( p_inventory_item_id  IN NUMBER
, p_organization_id    IN NUMBER
)
IS
  Cursor Unit_Controlled_Item IS
  SELECT effectivity_control
  FROM mtl_system_items
  WHERE inventory_item_id = p_inventory_item_id
  AND organization_id   = p_organization_id;
BEGIN
        FOR Unit_Cont_Item IN Unit_Controlled_Item
        LOOP
           IF Unit_Cont_Item.Effectivity_Control = 2
           THEN
                G_System_Information.unit_controlled_component := TRUE;
           ELSIF Unit_Cont_Item.Effectivity_Control = 1
           THEN
                G_System_Information.unit_controlled_component := FALSE;
           END IF;
        END LOOP;
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
* Procedure     : Set_Require_Item_Rev
* Returns       : None
* Parameters IN : p_Require_Rev
* Parameters OUT: None
* Purpose       : Will set the value of the attribute Require_Item_Rev
*                 in the system information record.
*****************************************************************************/
PROCEDURE Set_Require_Item_Rev
          ( p_Require_Rev      IN NUMBER )
IS
BEGIN
        G_System_Information.Require_Item_Rev
                        := p_Require_Rev;
END Set_Require_Item_Rev;

/**************************************************************************
* Function      : Is_Item_Rev_Required
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return value of the Require_Item_Rev attribute
*                 from the system information record.
***************************************************************************/
FUNCTION Is_Item_Rev_Required RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.Require_Item_Rev;

END Is_Item_Rev_Required;

/***************************************************************************
* Procedure     : Set_Current_Revision
* Returns       : None
* Parameters IN : p_current_revision
* Parameters OUT: None
* Purpose       : Procedure will set the current revision attribute of the
*                 system information record.
*****************************************************************************/
PROCEDURE Set_Current_Revision
          ( p_current_revision  IN  VARCHAR2 )
IS
BEGIN
        G_System_Information.current_revision := p_current_revision;

END Set_Current_Revision;

/***************************************************************************
* Function      : Get_Current_Revision
* Returns       : VARCHAR2(3)
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of current revision attribute
*                 of the system information record.
*****************************************************************************/
FUNCTION Get_Current_Revision RETURN VARCHAR2
IS
BEGIN
        RETURN G_System_Information.current_revision;

END Get_Current_Revision;

/***************************************************************************
* Procedure     : Set_BO_Identifier
* Returns       : None
* Parameters IN : p_bo_identifier
* Parameters OUT: None
* Purpose       : Procedure will set the Business object identifier attribute
*                 BO_Identifier of the system information record.
*****************************************************************************/
PROCEDURE Set_BO_Identifier
          ( p_bo_identifier     IN  VARCHAR2 )
IS
BEGIN
        G_System_Information.bo_identifier := p_bo_identifier;
        Error_Handler.Set_Bo_Identifier(p_bo_identifier);

END Set_BO_Identifier;

/***************************************************************************
* Function      : Get_BO_Identifier
* Returns       : VARCHAR2
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of the business object
*                 identifier attribute BO_Identifier from the system
*                 information record.
*****************************************************************************/
FUNCTION Get_BO_Identifier RETURN VARCHAR2
IS
BEGIN
        RETURN G_System_Information.bo_identifier;

END Get_BO_Identifier;

/***************************************************************************
* Procedure     : Set_CFM_Rtg_Flag
* Returns       : None
* Parameters IN : CFM_Rtng_Type
* Parameters OUT: None
* Purpose       : Procedure will set the Business object identifier
*                 CFM_Routing_Type as follows:
*                 CFM_Routing_flag = 1: flowing routing type
*                                    2: Standard routing type
*                                    3: Lot Based routing type
*                 BO_Identifier of the system information record.
*****************************************************************************/
PROCEDURE Set_CFM_Rtg_Flag
 (  p_cfm_rtg_type    IN NUMBER
 )
IS
BEGIN
   G_System_Information.cfm_rtg_flag := p_cfm_rtg_type;
END Set_CFM_Rtg_Flag;

/***************************************************************************
* Fuction       : Get_CFM_Rtg_Flag
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will gset the Business object identifier
*                 CFM_Routing_Type as follows
*                 CFM_Routing_flag = 1: flowing routing type
*                                    2: Standard routing type
*                                    3: Lot Based routing type
*                 BO_Identifier of the system information record.
*****************************************************************************/
FUNCTION Get_CFM_Rtg_Flag
 RETURN NUMBER
IS
BEGIN
   RETURN G_System_Information.cfm_rtg_flag;
END Get_CFM_Rtg_flag;

/***************************************************************************
* Procedure     : Set_Lot_Number
* Returns       : None
* Parameters IN : p_lot_number
* Parameters OUT: None
* Purpose       : Procedure will set the Lot Number attribute
*                 of the system information record.
*****************************************************************************/
PROCEDURE Set_Lot_Number
          ( p_lot_number IN  VARCHAR2 )
IS
BEGIN
        G_System_Information.lot_number := p_lot_number;

END Set_Lot_Number;

/***************************************************************************
* Function      : Get_Lot_Number
* Returns       : VARCHAR2
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of Lot Number
*                 from the system information record.
*****************************************************************************/
FUNCTION Get_Lot_Number RETURN VARCHAR2
IS
BEGIN
        RETURN G_System_Information.lot_number;

END Get_Lot_Number;

/***************************************************************************
* Procedure     : Set_From_Wip_Entity_Id
* Returns       : None
* Parameters IN : p_from_wip_entity_id
* Parameters OUT: None
* Purpose       : Procedure will set the from wip entity id attribute
*                 of the system information record.
*****************************************************************************/
PROCEDURE Set_From_Wip_Entity_Id
          ( p_from_wip_entity_id IN  NUMBER)
IS
BEGIN
        G_System_Information.from_wip_entity_id := p_from_wip_entity_id;

END Set_From_Wip_Entity_Id;


/***************************************************************************
* Function      : Get_From_Wip_Entity_Id
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of from wip entity id
*                 from the system information record.
*****************************************************************************/
FUNCTION Get_From_Wip_Entity_Id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.from_wip_entity_id;

END Get_From_Wip_Entity_Id;

/***************************************************************************
* Procedure     : Set_To_Wip_Entity_Id
* Returns       : None
* Parameters IN : p_to_wip_entity_id
* Parameters OUT: None
* Purpose       : Procedure will set the to wip entity id attribute
*                 of the system information record.
*****************************************************************************/

PROCEDURE Set_To_Wip_Entity_Id
          ( p_to_wip_entity_id IN  NUMBER)
IS
BEGIN
        G_System_Information.to_wip_entity_id := p_to_wip_entity_id;

END Set_To_Wip_Entity_Id;

/***************************************************************************
* Function      : Get_To_Wip_Entity_Id
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of to wip entity id
*                 from the system information record.
*****************************************************************************/
FUNCTION Get_To_Wip_Entity_Id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.to_wip_entity_id;

END Get_To_Wip_Entity_Id;

/***************************************************************************
* Procedure     : Set_From_Cum_Qty
* Returns       : None
* Parameters IN : p_from_cum_qty
* Parameters OUT: None
* Purpose       : Procedure will set the From Cum Qty attribute
*                 of the system information record.
*****************************************************************************/
PROCEDURE Set_From_Cum_Qty
          ( p_from_cum_qty IN  NUMBER)
IS
BEGIN
        G_System_Information.from_cum_qty := p_from_cum_qty;

END Set_From_Cum_Qty;

/***************************************************************************
* Function      : Get_From_Cum_Qty
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of From Cum Qty
*                 from the system information record.
*****************************************************************************/
FUNCTION Get_From_Cum_Qty RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.from_cum_qty;

END Get_From_Cum_Qty;

/***************************************************************************
* Procedure     : Set_Eco_For_Production
* Returns       : None
* Parameters IN : p_eco_for_production
* Parameters OUT: None
* Purpose       : Procedure will set the Eco For Production attribute
*                 of the system information record.
*****************************************************************************/
PROCEDURE Set_Eco_For_Production
          ( p_eco_for_production IN  NUMBER)
IS
BEGIN
        G_System_Information.eco_for_production := p_eco_for_production;

END Set_Eco_For_Production;

/***************************************************************************
* Function      : Get_Eco_For_Production
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of Eco For Production
*                 from the system information record.
*****************************************************************************/
FUNCTION Get_Eco_For_Production RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.eco_for_production;

END Get_Eco_For_Production;

/***************************************************************************
* Procedure     : Set_New_Routing_Revision
* Returns       : None
* Parameters IN : p_new_routing_revision
* Parameters OUT: None
* Purpose       : Procedure will set the routing revision attribute
*                 of the system information record.
*****************************************************************************/
PROCEDURE Set_New_Routing_Revision
          ( p_new_routing_revision IN  VARCHAR2 )
IS
BEGIN
        G_System_Information.new_routing_revision := p_new_routing_revision;

END Set_New_Routing_Revision;

/***************************************************************************
* Function      : Get_New_Routing_Revision
* Returns       : VARCHAR2
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of routing revision
*                 from the system information record.
*****************************************************************************/
FUNCTION Get_New_Routing_Revision RETURN VARCHAR2
IS
BEGIN
        RETURN G_System_Information.new_routing_revision;

END Get_New_Routing_Revision;


-- Added for eAM enhancement
/***************************************************************************
* Procedure     : Set_Eam_Item_Type
* Returns       : None
* Parameters IN : p_eam_item_type
* Parameters OUT: None
* Purpose       : Procedure will set the eam item type attribute
*                 of the system information record.
*****************************************************************************/
PROCEDURE Set_Eam_Item_Type
          ( p_eam_item_type IN  NUMBER )
IS
BEGIN
        G_System_Information.eam_item_type := p_eam_item_type ;

END Set_Eam_Item_Type ;

/***************************************************************************
* Function      : Get_Eam_Item_TYpe
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of eam item type
*                 from the system information record.
*****************************************************************************/
FUNCTION Get_Eam_Item_Type RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.eam_item_type ;

END  Get_Eam_Item_TYpe ;


/**************************************************************************
* Procedure     : Transaction_Type_Validity
* Parameters IN : Transaction Type
*                 Entity Name
*                 Entity ID, so that it can be used in a meaningful message
* Parameters OUT: Valid flag
*                 Message Token Table
* Purpose       : This procedure will check if the transaction type is valid
*                 for a particular entity.
**************************************************************************/
PROCEDURE Transaction_Type_Validity
(   p_transaction_type              IN  VARCHAR2
,   p_entity                        IN  VARCHAR2
,   p_entity_id                     IN  VARCHAR2
,   x_valid                         IN OUT NOCOPY BOOLEAN
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
BEGIN
    l_token_tbl(1).token_name := 'ENTITY_ID';
    l_token_tbl(1).token_value := p_entity_id;

    x_valid := TRUE;

    IF (p_entity IN ('Routing_Header','Routing_Revision','Op_Seq',
                      'Op_Res', 'Sub_Op_Res', 'Op_Network')
         AND
         NVL(p_transaction_type, FND_API.G_MISS_CHAR)
                        NOT IN ('CREATE', 'UPDATE', 'DELETE')
       )
   --    OR
   --    ( p_entity ='Bom_Rev' AND
   --       NVL(p_transaction_type, FND_API.G_MISS_CHAR)
   --                     NOT IN ('CREATE', 'UPDATE')
   --    )
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            IF p_entity = 'Routing_Header'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_RTG_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Routing_Revision'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_RTG_REV_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Op_Seq'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_OP_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Op_Res'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_RES_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Sub_Op_Res'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_SUB_RES_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Op_Network'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_OP_NWK_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            END IF;
        END IF;

        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_valid := FALSE;
    END IF;

END Transaction_Type_Validity;

 PROCEDURE Set_Debug
    (  p_debug_flag     IN  VARCHAR2 )
    IS
    BEGIN
        G_System_Information.debug_flag := p_debug_flag;
        Error_Handler.Set_Debug(p_debug_flag => p_debug_flag); -- added for bug 3478148
    END Set_Debug;

    FUNCTION Get_Debug RETURN VARCHAR2
    IS
    BEGIN
        RETURN G_System_Information.debug_flag;
    END;

/***************************************************************************
* Procedure     : Set_Osfm_NW_Calc_Flag
* Returns       : None
* Parameters IN : p_nw_calc_flag
* Parameters OUT: None
* Purpose       : For OSFM, we have to get some data at the start for the
*                 entire Routing. But because of technical difficulties
*                 we had to put the data inside the loop for network records
*                 So we have this flag to have the code run only once
*****************************************************************************/
PROCEDURE Set_Osfm_NW_Calc_Flag
          ( p_nw_calc_flag IN  BOOLEAN )
IS
BEGIN
        G_System_Information.Osfm_NW_Calc_Flag := p_nw_calc_flag;

END Set_Osfm_NW_Calc_Flag;

/***************************************************************************
* Function      : Is_Osfm_NW_Calc_Flag
* Returns       : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose       : returns the value for OSFM Network
*****************************************************************************/
FUNCTION Is_Osfm_NW_Calc_Flag RETURN BOOLEAN
IS
BEGIN
        RETURN G_System_Information.Osfm_NW_Calc_Flag;

END Is_Osfm_NW_Calc_Flag;

/*****************************************************************************
* Procedure     : Set_Osfm_NW_Count
* Returns       : None
* Parameters IN : p_nw_count
* Parameters OUT: None
* Purpose       : For OSFM, At the end of the netowrk Records LOOP,
*                 we need to compare the results before and after the network
*                 insert/update. But we need to differ this comparision
*                 till we process last network link. So we increment this
*                 counter as we process the records and then compare it
*                 with Netowkr table count
*****************************************************************************/
PROCEDURE Set_Osfm_NW_Count
          ( p_nw_count IN  NUMBER)
IS
BEGIN
        G_System_Information.Osfm_NW_Count := p_nw_count;
END Set_Osfm_NW_Count;

/*****************************************************************************
* Procedure     : Add_Osfm_NW_Count
* Returns       : None
* Parameters IN : p_nw_number
* Parameters OUT: None
* Purpose       : Increments the counter
*
*****************************************************************************/
PROCEDURE Add_Osfm_NW_Count
          ( p_nw_number IN  NUMBER)
IS
BEGIN
        G_System_Information.Osfm_NW_Count :=
        G_System_Information.Osfm_NW_Count + p_nw_number;
END Add_Osfm_NW_Count;


/***************************************************************************
* Function      : Get_Osfm_NW_Count
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : returns count
******************************************************************************/
FUNCTION Get_Osfm_NW_Count RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.Osfm_NW_Count;

END Get_Osfm_NW_Count;


/***BEGIN 1838261***/
/***************************************************************************
* Function      : Get_Temp_Op_Rec
* Returns       : Boolean
* Parameters IN : p_op_seq_num
* Parameters OUT: p_temp_op_rec
* Purpose       : returns the required record from the temporary pl/sql table which
		  stores the changed operation sequence numbers and effectivity date
******************************************************************************/
FUNCTION Get_Temp_Op_Rec
          ( p_op_seq_num	IN   NUMBER
	  , p_temp_op_rec	IN OUT NOCOPY Temp_Op_Rec_Type)
RETURN BOOLEAN
IS
l_cnt	NUMBER;
BEGIN
	FOR l_cnt IN 1..G_Temp_Op_Rec_Tbl.COUNT LOOP
	   IF G_Temp_Op_Rec_Tbl(l_cnt).old_op_seq_num = p_op_seq_num THEN
	      p_temp_op_rec := G_Temp_Op_Rec_Tbl(l_cnt);
	      RETURN TRUE;
	   END IF;
	END LOOP;
	RETURN FALSE;
END Get_Temp_Op_Rec;

FUNCTION Get_Temp_Op_Rec1
          ( p_op_seq_num	IN   NUMBER
	  , p_eff_date		IN   DATE
	  , p_temp_op_rec	IN OUT NOCOPY Temp_Op_Rec_Type)
RETURN BOOLEAN
IS
l_cnt	NUMBER;
BEGIN

	FOR l_cnt IN 1..G_Temp_Op_Rec_Tbl.COUNT LOOP
	   IF G_Temp_Op_Rec_Tbl(l_cnt).old_op_seq_num = p_op_seq_num
	   AND trunc(G_Temp_Op_Rec_Tbl(l_cnt).new_start_eff_date) <= trunc(p_eff_date) THEN --truncated date to adjust for sysdate issues with osfm routings
	      p_temp_op_rec := G_Temp_Op_Rec_Tbl(l_cnt);
	      RETURN TRUE;
	   END IF;
	END LOOP;
	RETURN FALSE;
END Get_Temp_Op_Rec1;


/***************************************************************************
* Procedure     : Set_Temp_Op_Tbl
* Returns       : None
* Parameters IN : p_temp_op_rec_tbl
* Parameters OUT: None
* Purpose       : Sets the temporary pl/sql table which stores the changed
		  operation sequence numbers and the effectivity date
******************************************************************************/
PROCEDURE Set_Temp_Op_Tbl
          ( p_temp_op_rec_tbl IN  Temp_Op_Rec_Tbl_Type)
IS
BEGIN
	G_Temp_Op_Rec_Tbl.DELETE;
	G_Temp_Op_Rec_Tbl := p_temp_op_rec_tbl;
END Set_Temp_Op_Tbl;
/***END 1838261***/


/***BUG 5330942***/
/***************************************************************************
* Function      : Get_Routing_Header_ECN
* Returns       : Varchar2
* Parameters IN : p_routing_seq_id
* Parameters OUT: Pending From ECN
* Purpose       : returns the value of Pending From ECN for the Routing header
****************************************************************************/
FUNCTION Get_Routing_Header_ECN
	( p_routing_seq_id IN NUMBER ) RETURN VARCHAR2
IS
	l_pend_from_ecn BOM_OPERATIONAL_ROUTINGS.pending_from_ecn%TYPE;
BEGIN
	SELECT pending_from_ecn
	INTO l_pend_from_ecn
	FROM bom_operational_routings
	WHERE routing_sequence_id = p_routing_seq_id;
	IF l_pend_from_ecn IS NOT NULL THEN
		RETURN l_pend_from_ecn;
	ELSE
		RETURN NULL;
	END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END Get_Routing_Header_ECN;


END BOM_RTG_Globals;

/
