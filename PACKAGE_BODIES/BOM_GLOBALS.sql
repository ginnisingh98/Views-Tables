--------------------------------------------------------
--  DDL for Package Body BOM_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_GLOBALS" AS
/* $Header: BOMSGLBB.pls 120.24.12010000.5 2009/07/08 09:06:01 adasa ship $ */
/**********************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSGLBB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Globals
--
--  NOTES
--
--  HISTORY
--
-- 16-JUL-1999  Rahul Chitko  Initial Creation
--
--  09-MAY-2001 Refai Farook    EAM related changes
--
--  22-AUG-01   Refai Farook    One To Many support changes
--
-- 08-Apr-2003  snelloli        Added Functions Get_Alternate Get_Structure_Type
**********************************************************************/

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'BOM_Globals';

--  Global variable holding ECO workflow approval process name

G_PROCESS_NAME                VARCHAR2(30) := NULL;
G_System_Information          System_Information_Rec_Type;
G_Control_Rec                 BOM_BO_PUB.Control_Rec_Type;

PROCEDURE Init_System_Info_Rec
(   x_mesg_token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status     IN OUT NOCOPY VARCHAR2
)
IS
BEGIN
        Bom_Globals.Set_user_id( p_user_id       => FND_GLOBAL.user_id);
        Bom_Globals.Set_login_id( p_login_id     => FND_GLOBAL.login_id);
        Bom_Globals.Set_prog_id( p_prog_id       => FND_GLOBAL.conc_program_id);
        Bom_Globals.Set_prog_appid( p_prog_appid => FND_GLOBAL.prog_appl_id);
        Bom_Globals.Set_request_id( p_request_id => FND_GLOBAL.conc_request_id);

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
* Added 06/21/99 by RC.
*****************************************************************************/

/**************************************************************************
* Function  : Get_System_Information
* Returns : System_Information Record
* Parameters IN : None
* Parameters OUT: None
* Purpose : This procedure will return the value of the system information
*     record.
****************************************************************************/
FUNCTION Get_System_Information RETURN Bom_Globals.System_Information_Rec_Type
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
    ( p_system_information_rec  IN
      Bom_Globals.System_Information_Rec_Type)
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
  l_process_name := BOM_Globals.Get_Process_Name;
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
* Procedure : Set_Bill_Sequence_id
* Returns : None
* Parameters IN : Bill_Sequence_Id
* Parameters OUT: None
* Purpose : This procedure will set the bill_sequence_id value in the
*     system_information record.
*
*****************************************************************************/
PROCEDURE Set_Bill_Sequence_id
    ( p_bill_sequence_id  IN  NUMBER)
IS
BEGIN
  G_System_Information.bill_sequence_id := p_bill_sequence_id;
END;

/***************************************************************************
* Function  : Get_Bill_Sequence_id
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : This function will return the bill_sequence_id value in the
*     system_information record.
******************************************************************************/
FUNCTION Get_Bill_Sequence_id RETURN NUMBER
IS
BEGIN
  RETURN G_System_Information.bill_sequence_id;

END Get_Bill_Sequence_id;

/*****************************************************************************
* Procedure : Set_Entity
* Returns : None
* Parameters IN : Entity Name
* Parameter IN OUT NOCOPY : None
* Purpose : Will set the entity name in the System Information Record.
*
******************************************************************************/
PROCEDURE Set_Entity
    ( p_entity  IN  VARCHAR2)
IS
BEGIN
  G_System_information.entity := p_entity;
END Set_Entity;

/****************************************************************************
* Function  : Get_Entity
* Returns       : VARCHAR2
* Parameters IN : None
* Parameter IN OUT NOCOPY : None
* Purpose       : Will return the entity name in the System Information Record.
*
*****************************************************************************/
FUNCTION Get_Entity RETURN VARCHAR2
IS
BEGIN
  RETURN G_System_Information.entity;
END Get_Entity;

/****************************************************************************
* Procedure : Set_Org_id
* Returns : None
* Parameters IN : Organization_Id
* Parameters OUT: None
* Purpose : Will set the org_id attribute of the sytem_information_record
*
*****************************************************************************/
PROCEDURE Set_Org_id
    ( p_org_id  IN  NUMBER)
IS
BEGIN
  G_System_Information.org_id := p_org_id;

END Set_Org_Id;

/***************************************************************************
* Function  : Get_Org_id
* Returns       : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the org_id attribute of the
*     sytem_information_record
*****************************************************************************/
FUNCTION Get_Org_id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.org_id;

END Get_Org_Id;

/****************************************************************************
* Procedure : Set_Eco_Name
* Returns : None
* Parameters IN : Eco_Name
* Parameters OUT: None
* Purpose : Will set the Eco_Name attribute of the
*     system_information record
******************************************************************************/
PROCEDURE Set_Eco_Name
    ( p_eco_name  IN VARCHAR2)
IS
BEGIN
  G_System_Information.eco_name := p_eco_name;

END Set_Eco_Name;

/****************************************************************************
* Function  : Get_Eco_Name
* Returns       : VARCHAR2
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Will return the Eco_Name attribute of the
*     system_information record
*****************************************************************************/
FUNCTION Get_Eco_Name RETURN VARCHAR2
IS
BEGIN
  RETURN G_System_Information.eco_name;

END Get_Eco_Name;

/*****************************************************************************
* Procedure : Set_User_Id
* Returns : None
* Parameters IN : User ID
* Parameters OUT: None
* Purpose : Will set the user ID attribute of the
*     system_information_record
*****************************************************************************/
PROCEDURE Set_User_Id
    ( p_user_id IN  NUMBER)
IS
BEGIN
  G_System_Information.user_id := p_user_id;

END Set_User_Id;

/***************************************************************************
* Function  : Get_User_Id
* Returns : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose : Will return the user_id attribute from the
*     system_information_record
*****************************************************************************/
FUNCTION Get_User_ID RETURN NUMBER
IS
BEGIN
  RETURN G_System_Information.user_id;

END Get_User_id;

/***************************************************************************
* Procedure     : Set_Routing_Sequence_Id
* Returns       : None
* Parameters IN : p_routing_sequence_id
* Parameters OUT: None
* Purpose       : Procedure will set the Routing Sequence Id attribute
*                 Routing_Sequence_Id of the system information record.
*****************************************************************************/
PROCEDURE Set_Routing_Sequence_Id
          ( p_routing_sequence_id IN  NUMBER)
IS
BEGIN
        G_System_Information.routing_sequence_id :=
        p_routing_sequence_id;

END Set_Routing_Sequence_Id;

/***************************************************************************
* Function      : Get_Routing_Sequence_Id
* Returns       : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of Routing Sequence Id
*                 from the system
*                 information record.
*****************************************************************************/
FUNCTION Get_Routing_Sequence_Id RETURN NUMBER
IS
BEGIN
        RETURN G_System_Information.routing_sequence_id;

END Get_Routing_Sequence_Id;

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


/****************************************************************************
* Procedure : Set_Login_Id
* Returns : None
* Paramaters IN : p_login_id
* Parameters OUT: None
* Purpose : Will set the login ID attribute of the system information
*     record.
*****************************************************************************/
PROCEDURE Set_Login_Id
    ( p_login_id  IN NUMBER )
IS
BEGIN
  G_System_Information.login_id := p_login_id;

END Set_Login_Id;

/****************************************************************************
* Function  : Get_Login_Id
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
* Procedure : Set_Prog_AppId
* Returns : None
* Parameters IN : p_prog_appid
* Parameters OUT: None
* Purpose : Will set the Program Application Id attribute of the
*     System Information Record.
*****************************************************************************/
PROCEDURE Set_Prog_AppId
    ( p_prog_Appid  IN  NUMBER )
IS
BEGIN
  G_System_Information.prog_appid := p_prog_appid;

END Set_Prog_AppId;

/***************************************************************************
* Function  : Get_Prog_AppId
* Returns : Number
* Parameters IN : None
* Parameters OUT: None
* Purpose : Will return the Program Application Id (prog_appid)
*     attribute of the system information record.
*****************************************************************************/
FUNCTION Get_Prog_AppId RETURN NUMBER
IS
BEGIN
  RETURN G_System_Information.prog_AppId;

END Get_Prog_AppId;


/***************************************************************************
* Procedure : Set_Prog_Id
* Returns : None
* Parameters IN : p_prog_id
* Parameters OUT: None
* Purpose : Will set the Program Id attribute of the system information
*     record.
*****************************************************************************/
PROCEDURE Set_Prog_Id
    ( p_prog_id   IN  NUMBER )
IS
BEGIN
  G_System_Information.prog_id := p_prog_id;

END Set_Prog_Id;

/***************************************************************************
* Function  : Get_Prog_Id
* Returns : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will return the Prog_Id attribute of the System
*     information record.
*****************************************************************************/
FUNCTION Get_Prog_Id RETURN NUMBER
IS
BEGIN
  RETURN G_System_Information.prog_id;

END Get_Prog_Id;

/***************************************************************************
* Procedure : Set_Request_Id
* Returns : None
* Parameters IN : p_request_id
* Parameters OUT: None
* Purpose : Procedure will set the request_id attribute of the
*     system information record.
*****************************************************************************/
PROCEDURE Set_Request_Id
    ( p_request_id  IN  NUMBER )
IS
BEGIN
  G_System_Information.request_id := p_request_id;
END;


/***************************************************************************
* Function  : Get_Request_Id
* Returns : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will return the value of the request_id attribute
*     of the system information record.
*****************************************************************************/
FUNCTION Get_Request_id RETURN NUMBER
IS
BEGIN
  RETURN G_System_Information.request_id;

END Get_Request_Id;

/***************************************************************************
* Procedure : Set_Eco_Impl
* Returns : None
* Parameters IN : p_eco_impl
* Parameters OUT: None
* Purpose : Will set the attribute Eco_Impl of system information record
*     to true or false based on the implemented status of the ECO
*****************************************************************************/
PROCEDURE Set_Eco_Impl
    ( p_eco_impl  IN  BOOLEAN )
IS
BEGIN
  G_System_Information.eco_impl := p_eco_impl;

END Set_Eco_Impl;

/***************************************************************************
* Function  : Is_Eco_Impl
* Returns : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will true or false value of the system information
*     record's attribute Eco_Impl. True if ECO is implemented and
*     false otherwise.
*****************************************************************************/
FUNCTION Is_Eco_Impl RETURN BOOLEAN
IS
BEGIN
  RETURN G_System_Information.eco_impl;

END Is_Eco_Impl;

/***************************************************************************
* Procedure : Set_Eco_Cancl
* Returns : None
* Parameters IN : p_eco_cancl
* Parameters OUT: None
* Purpose : Procedure will set the value of the system information
*     record attribute, Eco_Cancl. True if the Eco is canceled
*     and false otherwise.
*****************************************************************************/
PROCEDURE Set_Eco_Cancl
    ( p_eco_cancl IN  BOOLEAN )
IS
BEGIN
  G_System_Information.eco_cancl := p_eco_cancl;

END Set_Eco_Cancl;

/***************************************************************************
* Function  : Is_Eco_Cancl
* Returns : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will return true or false value of the system
*     information record's attribute Eco_Cancl.
*****************************************************************************/
FUNCTION Is_Eco_Cancl RETURN BOOLEAN
IS
BEGIN
  RETURN G_System_Information.eco_cancl;

END Is_Eco_Cancl;


/***************************************************************************
* Procedure : Set_Wkfl_Process
* Returns : None
* Parameters IN : p_wkfl_process
* Parameters OUT: None
* Purpose : Procedure will set a true or false value in the attribute
*     WKFL_Process of the system information record.
*****************************************************************************/
PROCEDURE Set_Wkfl_Process
    ( p_wkfl_process  IN  BOOLEAN )
IS
BEGIN
  G_System_Information.wkfl_process := p_wkfl_process;

END Set_Wkfl_Process;

/***************************************************************************
* Function  : Is_Wkfl_Process
* Returns : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will return the value of the system information
*     record attribute Wkfl_Process. True if a Workflow process
*     exists the ECO and false otherwise.
*****************************************************************************/
FUNCTION Is_Wkfl_Process RETURN BOOLEAN
IS
BEGIN
  RETURN G_System_Information.wkfl_process;

END Is_Wkfl_Process;


/***************************************************************************
* Procedure : Set_Eco_Access
* Returns : None
* Parameters IN : p_eco_access
* Parameters OUT: None
* Purpose : Procedure will set the value of the system information record
*       attribute Eco_Access. True if the user has access to the ECO
*     and false otherwise.
*****************************************************************************/
PROCEDURE Set_Eco_Access
    ( p_eco_access  IN  BOOLEAN )
IS
BEGIN
  G_System_Information.eco_access := p_eco_access;

END Set_Eco_Access;

/***************************************************************************
* Function  : Is_Eco_Access
* Returns : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will return true if the Eco_Access is True and
*     false otherwise.
*****************************************************************************/
FUNCTION Is_Eco_Access RETURN BOOLEAN
IS
BEGIN
  RETURN G_System_Information.eco_access;

END Is_Eco_Access;

/***************************************************************************
* Procedure : Set_RItem_Impl
* Returns : None
* Parameters IN : p_ritem_impl
* Parameters OUT: None
* Purpose : Procedure will set the value of system iformation record
*     attribute RItem_Impl.
*****************************************************************************/
PROCEDURE Set_RItem_Impl
    ( p_ritem_impl  IN  BOOLEAN )
IS
BEGIN
  G_System_Information.ritem_impl := p_ritem_impl;

END Set_RItem_Impl;

/***************************************************************************
* Function  : Is_RItem_Impl
* Returns : BOOLEAN
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will answer true or false to the question
*     Is Revised Item Implemented ?
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
* Procedure : Set_Std_Item_Access
* Returns : None
* Parameters IN : p_std_item_access
* Parameters OUT: None
* Purpose : Will set the value of the attribute STD_Item_Access in the
*     system information record.
*****************************************************************************/
PROCEDURE Set_Std_Item_Access
    ( p_std_item_access IN  NUMBER )
IS
BEGIN
  G_System_Information.std_item_access := p_std_item_access;

END Set_Std_Item_Access;

/**************************************************************************
* Function  : Get_Std_Item_Access
* Returns : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose : Will return the value of the Standard Item Access attribute
*     Std_Item_Access from the system information record.
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
* Function  : Get_Mdl_Item_Access
* Returns : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose : Will return the value of the Model Item Access attribute
*     Mdl_Item_Access from the system information record.
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
* Function  : Get_Pln_Item_Access
* Returns : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose : Will return the value of the Planning Item Access attribute
*     Pln_Item_Access from the system information record.
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
* Function  : Get_OC_Item_Access
* Returns : NUMBER
* Parameters IN : None
* Parameters OUT: None
* Purpose : Will return value of the Option Class Item Access attribute
*     OC_Item_Access from the system information record.
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
* Procedure : Set_Current_Revision
* Returns : None
* Parameters IN : p_current_revision
* Parameters OUT: None
* Purpose : Procedure will set the current revision attribute of the
*     system information record.
*****************************************************************************/
PROCEDURE Set_Current_Revision
    ( p_current_revision  IN  VARCHAR2 )
IS
BEGIN
  G_System_Information.current_revision := p_current_revision;

END Set_Current_Revision;

/***************************************************************************
* Function  : Get_Current_Revision
* Returns : VARCHAR2(3)
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will return the value of current revision attribute
*     of the system information record.
*****************************************************************************/
FUNCTION Get_Current_Revision RETURN VARCHAR2
IS
BEGIN
  RETURN G_System_Information.current_revision;

END Get_Current_Revision;

/***************************************************************************
* Procedure : Set_BO_Identifier
* Returns : None
* Parameters IN : p_bo_identifier
* Parameters OUT: None
* Purpose : Procedure will set the Business object identifier attribute
*     BO_Identifier of the system information record.
*****************************************************************************/
PROCEDURE Set_BO_Identifier
    ( p_bo_identifier IN  VARCHAR2 )
IS
BEGIN
  G_System_Information.bo_identifier := p_bo_identifier;
  Error_Handler.Set_Bo_Identifier(p_bo_identifier);

END Set_BO_Identifier;

/***************************************************************************
* Function  : Get_BO_Identifier
* Returns : VARCHAR2
* Parameters IN : None
* Parameters OUT: None
* Purpose : Function will return the value of the business object
*     identifier attribute BO_Identifier from the system
*     information record.
*****************************************************************************/
FUNCTION Get_BO_Identifier RETURN VARCHAR2
IS
BEGIN
  RETURN G_System_Information.bo_identifier;

END Get_BO_Identifier;

/**************************************************************************
* Procedure : Transaction_Type_Validity
* Parameters IN : Transaction Type
*     Entity Name
*     Entity ID, so that it can be used in a meaningful message
* Parameters OUT: Valid flag
*     Message Token Table
* Purpose : This procedure will check if the transaction type is valid
*     for a particular entity.
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

    /* Introducing a new transaction type 'SYNC' to support BOM creation
       from WIP (EAM) */

    IF p_transaction_type = 'SYNC' THEN
      x_mesg_token_tbl := l_mesg_token_tbl;
      RETURN;
    END IF;

    IF (p_entity IN ('Bom_Header','Bom_Comps','Bom_Ref_Desgs','Bom_Sub_Comps','Bom_Comp_Ops')
   AND
         NVL(p_transaction_type, FND_API.G_MISS_CHAR)
                        NOT IN ('CREATE', 'UPDATE', 'DELETE')
       )
       OR
       ( p_entity ='Bom_Rev' AND
          NVL(p_transaction_type, FND_API.G_MISS_CHAR)
                        NOT IN ('CREATE', 'UPDATE')
       )
    THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            IF p_entity = 'Bom_Header'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_HEADER_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Bom_Rev'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_REV_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Bom_Comps'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_CMP_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Bom_Ref_Desgs'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_RFD_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Bom_Sub_Comps'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_SBC_TRANS_TYPE_INVALID'
                , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );
            ELSIF p_entity = 'Bom_Comp_Ops'
            THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name       => 'BOM_COPS_TRANS_TYPE_INVALID'
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
        Error_Handler.Set_Debug(p_debug_flag => p_debug_flag);
    END Set_Debug;

    FUNCTION Get_Debug RETURN VARCHAR2
    IS
    BEGIN
       RETURN G_System_Information.debug_flag;
       -- RETURN Error_Handler.Get_Debug;
    END;

    PROCEDURE Set_Assembly_Item_Id
    (  p_assembly_item_id     IN  NUMBER )
    IS
    BEGIN
        G_System_Information.assembly_item_id := p_assembly_item_id;
    END Set_Assembly_Item_Id;

    FUNCTION Get_Assembly_Item_Id RETURN NUMBER IS
    BEGIN
        RETURN G_System_Information.assembly_item_id;
    END Get_Assembly_Item_Id;

/***************************************************************************
* Function      : Set_Caller_Type
* Returns       : None
* Parameters IN : p_caller_type
* Parameters OUT: None
* Purpose       : Procedure will set the value of Caller_type in
*                 G_Control_Rec
*****************************************************************************/
Procedure Set_Caller_Type
        ( p_caller_type         IN      VARCHAR2)
IS
BEGIN
        G_Control_Rec.Caller_Type := p_caller_type;

End Set_Caller_Type;

/***************************************************************************
* Function      : Get_Caller_Type
* Returns       : Caller type(VARCHAR2)
* Parameters IN : None
* Parameters OUT: None
* Purpose       : Function will return the value of Caller_type in
*                 G_Control_Rec
*****************************************************************************/
Function Get_Caller_Type RETURN VARCHAR2
IS
BEGIN
        RETURN G_Control_Rec.Caller_Type;
End Get_Caller_Type;

FUNCTION RETRIEVE_MESSAGE(
          p_application_id      IN VARCHAR2
        , p_message_name        IN VARCHAR2
        ) RETURN VARCHAR2
IS
BEGIN
  Fnd_Message.Set_Name (  application  => p_application_id,
                                    name         => p_message_name
                                 );
  return Fnd_Message.Get;
END RETRIEVE_MESSAGE;


/* Bug 5737158
 **************************************************************************
 * Function      : Get_Concat_Segs
 * Returns       : The concatenated item segments
 * Parameters IN : Item_id , Organization_id
 * Parameters OUT: None
 * Purpose       : Can be used in views to get the concatenated item segments.
 *                 Non-displayed segments would not be returned.
 ****************************************************************************/
 FUNCTION Get_Concat_Segs(p_item_id IN NUMBER,
                          p_org_id  IN NUMBER )
 RETURN VARCHAR2
 IS
  l_get_flex BOOLEAN;
  l_no_segments NUMBER ;
  l_value varchar2(2000);
  l_segments fnd_flex_ext.SegmentArray;
  BEGIN
       l_get_flex :=  fnd_flex_ext.get_segments('INV','MSTK',101,p_item_id,l_no_segments,l_segments,p_org_id);
       if (l_get_flex) then
          l_value := fnd_flex_ext.concatenate_segments(l_no_segments,l_segments,fnd_flex_ext.get_delimiter('INV','MSTK',101));
       end if;

  return l_value;
  EXCEPTION
      WHEN OTHERS THEN
        return null;
  END Get_Concat_Segs;

/***************************************************************************
* Function      : Get_Alternate
* Returns       : alternate_bom_designator type(VARCHAR2)
* Parameters IN : p_bill_sequence_id type(NUMBER)
* Parameters OUT: None
* Purpose       : Function will return the Alternate BOM Designatore
*****************************************************************************/

FUNCTION Get_Alternate
(p_bill_sequence_id NUMBER)
RETURN VARCHAR2
IS
  cursor c_alternate IS
  SELECT alternate_bom_designator
    FROM bom_structures_b
   WHERE bill_sequence_id = p_bill_sequence_id;
BEGIN
  for alternate in c_alternate
  loop
    if (alternate.alternate_bom_designator IS NULL)
    then
      return RETRIEVE_MESSAGE('BOM','BOM_PRIMARY');

    else
      return alternate.alternate_bom_designator;
    end if;
  end loop;

  return null;
END;


/***************************************************************************
* Function      : Get_Structure_Type
* Returns       : display_name type(VARCHAR2)
* Parameters IN : p_bill_sequence_id   type(NUMBER)
*                p_organization_id  type(NUMBER)
* Parameters OUT: None
* Purpose       : Function will return the display name For the Structure Type
*****************************************************************************/

FUNCTION Get_Structure_Type
(  p_bill_sequence_id   IN NUMBER
 , p_organization_id  IN NUMBER
)
RETURN VARCHAR2
IS
   CURSOR c_structure_type(l_bill_sequence_id   NUMBER
         ) IS
  SELECT display_name
  FROM bom_structure_types_vl st
       , bom_structures_b bsb
  WHERE bsb.bill_sequence_id = l_bill_sequence_id
        and bsb.structure_type_id = st.structure_type_id;

BEGIN
  for structure_type in c_structure_type( l_bill_sequence_id => p_bill_sequence_id)
  loop
    return structure_type.display_name;
  end loop;

  RETURN null;

END;

/***************************************************************************
* Function      : get_item_type
* Returns       : meaning type(VARCHAR2)
* Parameters IN : p_item_type type(VARCHAR2)
* Parameters OUT: None
* Purpose       : Function will return the Item Type Meaning
*****************************************************************************/

FUNCTION get_item_type
( p_item_type IN VARCHAR2)
RETURN VARCHAR2
IS
  cursor c_item_type is
  select meaning
    from fnd_lookup_values
   where LOOKUP_CODE = p_ITEM_TYPE
    AND LOOKUP_TYPE = 'ITEM_TYPE'
           AND LANGUAGE = USERENV('LANG');
BEGIN
  if p_item_type is null
  then
    return null;
  end if;

  for item_type in c_item_type
  loop
    return item_type.meaning;
  end loop;

  return null;
END;

  FUNCTION get_reference_designators
  ( p_component_sequence_id  IN NUMBER
   ) return VARCHAR2
  IS
        cursor c_ref_desg ( p_component_seq IN NUMBER)
        IS
        SELECT component_reference_designator
          FROM bom_reference_designators rd
	     , bom_components_b comp
         WHERE comp.component_sequence_id = p_component_seq
	   AND rd.component_sequence_id = comp.component_sequence_id
	   AND ( (comp.implementation_date IS NULL AND
		  rd.change_notice = comp.change_notice
	         ) OR
		 (comp.implementation_date is NOT NULL AND
		     (rd.acd_type IS NULL OR rd.acd_type <> 3)
		 )
		)
  order by 1 DESC;

         --l_ref_desg VARCHAR2(32000);
         l_ref_desg VARCHAR2(4000);
         l_length NUMBER;
  BEGIN
        l_ref_desg := null;
        l_length := 0;
        FOR ref_desg IN c_ref_desg(p_component_seq => p_component_sequence_id)
        LOOP
            l_length := l_length + length(ref_desg.component_reference_designator) + 2;
            IF(l_length < 3998) THEN
                l_ref_desg := ref_desg.component_reference_designator || ', ' || l_ref_desg;
            ELSE
                EXIT;
            END IF;
        END LOOP;
        if (l_ref_desg is not null) then
          l_ref_desg := substr(l_ref_desg, 0, length(l_ref_desg) - 2);
        end if;
        IF(l_length >= 3998) THEN
          l_ref_desg := l_ref_desg || ', ...';
        END IF;
        return l_ref_desg;

  END get_reference_designators;


  FUNCTION Get_Item_Name(p_item_id IN NUMBER,p_org_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_item_name MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;
  BEGIN
    SELECT concatenated_segments
    INTO   l_item_name
    FROM   mtl_system_items_kfv
    WHERE  inventory_item_id = p_item_id
    AND    organization_id   = p_org_id;
    RETURN l_item_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return null;
  END Get_Item_Name;

    PROCEDURE Get_Orgs(p_org_hier IN VARCHAR2 , p_organization_id IN NUMBER, x_org_list IN OUT NOCOPY BOM_GLOBALS.OrgID_tbl_type  )
    IS
      t_org_code_list Inv_Orghierarchy_Pvt.OrgID_tbl_type;
      starting_org_counter    NUMBER ;
      I     NUMBER := 1 ;
      N     NUMBER := 0 ;
      err_msg   VARCHAR2(200);
    BEGIN
      Inv_Orghierarchy_Pvt.ORG_HIERARCHY_LIST(p_org_hier,p_organization_id,t_org_code_list) ;
      starting_org_counter := 1;
      FOR I IN starting_org_counter..t_org_code_list.COUNT LOOP
        N:=N+1;
        x_org_list(N) := t_org_code_list(I);
      END LOOP;
    END Get_Orgs;

   PROCEDURE Set_Validate_For_Plm
    (  p_validate_for_plm_flag     IN  VARCHAR2 )
    IS
    BEGIN
        G_System_Information.validate_for_plm := p_validate_for_plm_flag;
    END Set_Validate_For_Plm;

    FUNCTION Get_Validate_For_Plm RETURN VARCHAR2
    IS
    BEGIN
       RETURN G_System_Information.validate_for_plm;
    END;


  --
/* Procedure to default the New Structure Revision Attributes */
  PROCEDURE GET_DEF_REV_ATTRS
  (     p_bill_sequence_id IN NUMBER
    ,   p_comp_item_id IN NUMBER
    ,   p_effectivity_date IN DATE
    ,   x_object_revision_id OUT NOCOPY VARCHAR2
    ,   x_minor_revision_id OUT NOCOPY VARCHAR2
    ,   x_comp_revision_id OUT NOCOPY VARCHAR2
    ,   x_comp_minor_revision_id OUT NOCOPY VARCHAR2
  )
  IS

  stmt1 LONG;
  stmt2 LONG;
  x_install_ego boolean;
  x_status VARCHAR2(1);
  x_industry VARCHAR2(1);
  x_schema VARCHAR2(30);
  object_type VARCHAR2(20);

      CURSOR
       get_ass_current_rev
                (p_bill_sequence_id in Number,
                 p_effectivity_date in Date )
      IS
          SELECT
            revision_id
          FROM
            mtl_item_revisions_B mir,
            bom_bill_of_materials bom
          WHERE
                mir.inventory_item_id = bom.assembly_item_id
            AND mir.organization_id = bom.organization_id
            AND bom.bill_sequence_id = p_bill_sequence_id
           AND effectivity_date =
            (SELECT max(mir1.effectivity_date)
                      FROM mtl_item_revisions_b mir1
                      WHERE mir1.inventory_item_id = mir.inventory_item_id
                      AND mir1.organization_id = mir.organization_id
                      AND mir1.effectivity_date <= p_effectivity_date
                      AND ROWNUM = 1);

     CURSOR
       get_comp_current_rev
                (p_bill_sequence_id Number,
                 p_component_item_id Number,
                 p_effectivity_date Date
                )
      IS
          SELECT
            revision_id
          FROM
            mtl_item_revisions_B mir,
            bom_bill_of_materials bom
          WHERE
                mir.inventory_item_id = p_component_item_id
            AND mir.organization_id = bom.organization_id
            AND bom.bill_sequence_id = p_bill_sequence_id
           AND effectivity_date = (SELECT max(mir1.effectivity_date)
                      FROM mtl_item_revisions_b mir1
                      WHERE mir1.inventory_item_id = mir.inventory_item_id
                      AND mir1.organization_id = mir.organization_id
                      AND mir1.effectivity_date <= p_effectivity_date
                      AND ROWNUM = 1);


  BEGIN
    object_type := 'EGO_ITEM_REVISION';
    x_minor_revision_id := 0;
    x_comp_minor_revision_id :=0;
    x_install_ego :=  Fnd_Installation.Get_App_Info
                       (application_short_name => 'EGO',
                        status                 => x_status,
                        industry               => x_industry,
                        oracle_schema          => x_schema);



    FOR c_obj_rev IN get_ass_current_rev
      ( p_bill_sequence_id => p_bill_sequence_id
       ,p_effectivity_date => p_effectivity_date)
    LOOP
           x_object_revision_id :=  c_obj_rev.revision_id;

           IF (x_status = 'I' ) then
          stmt2 :=  '  SELECT '||
          ' nvl(max(minor_revision_id),0) minor_revision_id '||
          '  FROM '||
          ' ego_minor_revisions emr, '||
          ' bom_bill_of_materials bom '||
          ' WHERE '||
          ' emr.pk1_value = to_char(bom.assembly_item_id) '||
          ' AND emr.pk2_value =  to_char(bom.organization_id)' ||
          ' AND bom.bill_sequence_id = :bill_seq_id' ||
          ' and emr.pk3_value = :object_rev_id' ||
          '  and emr.obj_name = :object_type';

                       execute immediate stmt2 using p_bill_sequence_id, x_object_revision_id, object_type;-- into x_minor_revision_id;
           END IF;

    END LOOP;

    FOR c_comp_rev IN get_comp_current_rev
      ( p_bill_sequence_id => p_bill_sequence_id
        ,p_component_item_id  => p_comp_item_id
        ,p_effectivity_date => p_effectivity_date)
    LOOP
            x_comp_revision_id :=  c_comp_rev.revision_id;

            IF (x_status = 'I') then
          stmt1 :=  ' SELECT '||
           'nvl(max(minor_revision_id),0) minor_revision_id ' ||
           ' FROM '||
           ' ego_minor_revisions emr, '||
           ' bom_bill_of_materials bom '||
           ' WHERE '||
             '   emr.pk1_value = to_char(:comp_item_id) ' ||
           ' AND emr.pk2_value = to_char(bom.organization_id) '||
           ' AND bom.bill_sequence_id = :bill_seq_id ' ||
           ' and emr.pk3_value =  :comp_rev_id' ||
           ' and emr.obj_name = :object_type';


                       execute immediate stmt1 into x_comp_minor_revision_id using p_comp_item_id, p_bill_sequence_id, x_comp_revision_id, object_type;
            END IF;

    END LOOP;

END;

  /***************************************************************************
  * Function : Is_GTIN_Structure_Type_Id
  * Returns : TRUE / FALSE
  * Parameters IN : Structure Type Id
  * Parameters OUT: None
  * Purpose : Function will return TRUE if the given structure type is
  *           'Packaging Hierarchy' otherwise returns false
  *****************************************************************************/
  FUNCTION Is_GTIN_Structure_Type_Id (p_Structure_Type_Id IN NUMBER) RETURN BOOLEAN
  IS
    l_GTIN_Id NUMBER;
  BEGIN
    SELECT Structure_Type_Id
      INTO l_GTIN_Id
        FROM bom_structure_types_vl
    WHERE Structure_Type_Name ='Packaging Hierarchy'
      AND Structure_Type_Id = p_Structure_Type_Id;

    RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Return FALSE;
  END Is_GTIN_Structure_Type_Id;


  /***************************************************************************
  * Function : Get_Change_Policy_Val
  * Returns : Change Policy value
  * Parameters IN : Bill Sequence Id
  *                 Item's revision code
  * Parameters OUT: None
  * Purpose : Function will return the change policy value if there is any policy
  *           otherwise it will return "ALLOWED"
  *****************************************************************************/
  FUNCTION Get_Change_Policy_Val (p_bill_seq_id  IN NUMBER,
                                  p_item_revision_code IN VARCHAR2)
  RETURN VARCHAR2 IS

  l_change_policy_char_val VARCHAR2(80);
  l_item_rev_code VARCHAR2(30);
  l_item_id NUMBER;
  l_org_id NUMBER;

  BEGIN

    l_change_policy_char_val := 'ALLOWED';
    l_item_rev_code := p_item_revision_code;

    --If revision code is not passed then current revision will be queried.
    -- Commenting the revision related code, as structure change policies are not dependent on item's revision
    /*IF p_item_revision_code IS NULL THEN
        SELECT Assembly_Item_id, Organization_Id into  l_item_id, l_org_id
        FROM Bom_Structures_b
        WHERE Bill_Sequence_Id = p_bill_seq_id;
        l_item_rev_code := BOM_REVISIONS.GET_ITEM_REVISION_FN('ALL', 'ALL', l_org_id, l_item_id, SYSDATE);
    END IF;
    */
    -- Getting the change policy value.
    SELECT
        ecp.policy_char_value INTO l_change_policy_char_val
    FROM
         MTL_SYSTEM_ITEMS ITEM_DTLS, ENG_CHANGE_POLICIES_V ECP, Bom_Structures_b bsb
    WHERE
         ecp.policy_object_pk1_value =
              (SELECT TO_CHAR(ic.item_catalog_group_id)
               FROM mtl_item_catalog_groups_b ic
               WHERE EXISTS (SELECT olc.object_classification_code CatalogId
                             FROM EGO_OBJ_TYPE_LIFECYCLES olc
                             WHERE olc.object_id = (SELECT OBJECT_ID
                                                    FROM fnd_objects
                                                    WHERE obj_name = 'EGO_ITEM')
                             AND  olc.lifecycle_id = ITEM_DTLS.lifecycle_id
                             AND olc.object_classification_code = ic.item_catalog_group_id
                             )
                AND ROWNUM = 1
                CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                START WITH item_catalog_group_id = ITEM_DTLS.item_catalog_group_id)
    AND ecp.policy_object_pk2_value = ITEM_DTLS.lifecycle_id
    AND ecp.policy_object_pk3_value = ITEM_DTLS.current_phase_id
    AND ecp.policy_object_name ='CATALOG_LIFECYCLE_PHASE'
    AND ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
    AND ecp.attribute_code = 'STRUCTURE_TYPE'
    AND bsb.Structure_Type_id = ecp.attribute_number_value
    AND bsb.Assembly_item_id = ITEM_DTLS.inventory_item_id
    AND bsb.organization_id = ITEM_DTLS.organization_id
    AND bsb.Bill_Sequence_id = p_bill_seq_id;

    RETURN l_change_policy_char_val;

  EXCEPTION WHEN OTHERS THEN

    RETURN l_change_policy_char_val;

  END Get_Change_Policy_Val;


  /***************************************************************************
  * Function : Get_Change_Policy_Val
  * Returns : Change Policy value
  * Parameters IN : Inventory Item Id
  *                 Organization Id
  *                 Structure Type id
  * Parameters OUT: None
  * Purpose : Function will return the change policy value if there is any policy
  *           otherwise it will return "ALLOWED". This is used to determine whether
  *           structure header creation is allowed for the current item/str type.
  *****************************************************************************/
 FUNCTION Get_Change_Policy_Val (p_item_id  IN NUMBER,
                                 p_org_id IN NUMBER,
 			         p_structure_type_id in NUMBER)
 RETURN VARCHAR2 IS

  l_change_policy_char_val VARCHAR2(80);
  l_item_rev_code VARCHAR2(30);

  BEGIN
    --get the current rev of the item, since structure header is independent of item rev.
    -- Commenting the revision related code, as structure change policies are not dependent on item's revision
    --l_item_rev_code := BOM_REVISIONS.GET_ITEM_REVISION_FN('ALL', 'ALL', p_org_id, p_item_id, SYSDATE);
    l_change_policy_char_val := 'ALLOWED';

    SELECT
        ecp.policy_char_value INTO l_change_policy_char_val
    FROM
         MTL_SYSTEM_ITEMS ITEM_DTLS, ENG_CHANGE_POLICIES_V ECP
    WHERE
         ecp.policy_object_pk1_value =
              (SELECT TO_CHAR(ic.item_catalog_group_id)
               FROM mtl_item_catalog_groups_b ic
               WHERE EXISTS (SELECT olc.object_classification_code CatalogId
                             FROM EGO_OBJ_TYPE_LIFECYCLES olc
                             WHERE olc.object_id = (SELECT OBJECT_ID
                                                    FROM fnd_objects
                                                    WHERE obj_name = 'EGO_ITEM')
                             AND  olc.lifecycle_id = ITEM_DTLS.lifecycle_id
                             AND olc.object_classification_code = ic.item_catalog_group_id
                             )
                AND ROWNUM = 1
                CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                START WITH item_catalog_group_id = ITEM_DTLS.item_catalog_group_id)
    AND ecp.policy_object_pk2_value = ITEM_DTLS.lifecycle_id
    AND ecp.policy_object_pk3_value = ITEM_DTLS.current_phase_id
    AND ecp.policy_object_name ='CATALOG_LIFECYCLE_PHASE'
    AND ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
    AND ecp.attribute_code = 'STRUCTURE_TYPE'
    AND ecp.attribute_number_value = p_structure_type_id
    AND ITEM_DTLS.inventory_item_id = p_item_id
    AND ITEM_DTLS.organization_id = p_org_id;

    RETURN l_change_policy_char_val;

  EXCEPTION WHEN OTHERS THEN

    RETURN l_change_policy_char_val;



  END Get_Change_Policy_Val;

  /****************************************************************************
   * Function                : GET_PRIMARY_UI
   * Returns                 : VARCHAR2
   * Parameters IN           : None
   * Parameter IN OUT NOCOPY : None
   * Purpose                 : Returns Alternate designator string for Primary
   *                           structure.(bug:4162717)
   *****************************************************************************/
  FUNCTION GET_PRIMARY_UI RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_PRIMARY_UI;
  END GET_PRIMARY_UI;

  FUNCTION Is_PLM_Enabled RETURN VARCHAR2
  IS
  	l_plm_profile_value NUMBER;
  	l_returnValue VARCHAR2(1);
  BEGIN
	l_plm_profile_value := fnd_profile.value('EGO_ENABLE_PLM');
	IF (l_plm_profile_value = 1)
	THEN
          l_returnValue := 'Y';
        ELSE
          l_returnValue := 'N';
        END IF;
        RETURN l_returnValue;
  END;

  FUNCTION Is_PIM_Enabled RETURN VARCHAR2
  IS
  	l_pim_profile_value NUMBER;
  	l_returnValue VARCHAR2(1);
  BEGIN
	l_pim_profile_value := fnd_profile.value('EGO_ENABLE_PIMDL');
	IF (l_pim_profile_value = 1)
	THEN
          l_returnValue := 'Y';
        ELSE
          l_returnValue := 'N';
        END IF;
        RETURN l_returnValue;
  END;

  FUNCTION Is_PDS_Enabled RETURN VARCHAR2
  IS
  	l_gdsn_profile_value NUMBER;
  	l_returnValue VARCHAR2(1);
  BEGIN
	l_gdsn_profile_value := fnd_profile.value('EGO_UCCNET_ENABLED');
	IF (l_gdsn_profile_value = 1)
	THEN
          l_returnValue := 'Y';
        ELSE
          l_returnValue := 'N';
        END IF;
        RETURN l_returnValue;
  END;


  FUNCTION Is_PIM_PDS_Enabled RETURN VARCHAR2
  IS
    l_pim_profile_value NUMBER;
    l_gdsn_profile_value NUMBER;
    l_returnValue VARCHAR2(1);
  BEGIN
    	l_pim_profile_value := fnd_profile.value('EGO_ENABLE_PIMDL');
  	l_gdsn_profile_value := fnd_profile.value('EGO_UCCNET_ENABLED') ;

    	--dbms_output.put_line(''||l_pim_profile_value);
  	--dbms_output.put_line(''||l_gdsn_profile_value);

  	IF (l_pim_profile_value = 1 OR l_gdsn_profile_value = 1)
  	THEN
  	  l_returnValue := 'Y';
  	ELSE
  	  l_returnValue := 'N';
  	END IF;
        RETURN 	l_returnValue;
  END;

  /****************************************************************************
   * Function                : Check_ItemAttrGroup_Security
   * Returns                 : VARCHAR2
   * Parameters IN           : viewPrivilegeName
   * 			       editPrivilegeName
   *			       partyId,	inventoryItemId	 ,organizationId
   * Parameter IN OUT NOCOPY : None
   * Purpose                 : Returns T if view privilege is allowed
   *			       Returns E if view and edit privilege are allowed
   *			       Returns F if view privilege is not allowed.
   *****************************************************************************/


  FUNCTION Check_ItemAttrGroup_Security(viewPrivilegeName   IN VARCHAR2,
                                        editPrivilegeName   IN VARCHAR2,
  				        partyId             IN VARCHAR2,
  				        inventoryItemId     IN NUMBER,
  				        organizationId      IN NUMBER) RETURN VARCHAR2
  IS
  l_view_privilege VARCHAR2(1) := NULL;
  l_edit_privilege VARCHAR2(1) := NULL;
  l_attrgroup_security  VARCHAR2(1) := NULL;
  BEGIN

  IF (viewPrivilegeName IS NOT NULL)
  THEN
  	SELECT EGO_DATA_SECURITY.CHECK_FUNCTION(1.0,viewPrivilegeName,'EGO_ITEM',inventoryItemId,
        			   organizationId,null, null, null,partyId) INTO l_view_privilege
        FROM DUAL;
  END IF;

  IF (editPrivilegeName IS NOT NULL)
  THEN
  	SELECT EGO_DATA_SECURITY.CHECK_FUNCTION(1.0,editPrivilegeName,'EGO_ITEM',inventoryItemId,
        			   organizationId,null, null, null,partyId) INTO l_edit_privilege
        FROM DUAL;
  END IF;

  IF (l_view_privilege IS NOT NULL)
  THEN
      l_attrgroup_security := l_view_privilege;
      IF (l_view_privilege = 'T')
      THEN
         IF ((l_edit_privilege IS NOT NULL) AND (l_edit_privilege = 'T'))
         THEN
           l_attrgroup_security := 'E';
         END IF;
      END IF;
  ELSE
      l_attrgroup_security := l_edit_privilege;
      IF (l_edit_privilege = 'T')
      THEN
         l_attrgroup_security := 'E';
       ELSIF  (l_edit_privilege = 'F')
       THEN
         l_attrgroup_security := 'T';
       END IF;
  END IF;

  RETURN l_attrgroup_security;
  END;

  /*#
   * This function will return Y if the revised component is editable.
   * @return Y or N
   * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
   * @rep:compatibility S
   * @rep:scope private
   * @rep:lifecycle active
   */
  FUNCTION Is_Rev_Comp_Editable(p_comp_seq_id IN NUMBER)
           RETURN VARCHAR2
  IS
    l_eng_api_call VARCHAR2(1000);
    l_edit_flag VARCHAR2(1);
  BEGIN
    --Dynamic call to remove dependency on ENG
    l_eng_api_call := 'BEGIN
                       ENG_REVISED_ITEMS_PKG.Check_Rev_Comp_Editable (
                         p_component_sequence_id => :1,
                         x_rev_comp_editable_flag => :2);
                       END;';

    EXECUTE IMMEDIATE l_eng_api_call
    USING IN p_comp_seq_id, OUT l_edit_flag;

    IF l_edit_flag = FND_API.G_TRUE
    THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'Y';

  END;



  /* Return the structure change policy value associated with the revision/item level */

  FUNCTION Get_Change_Policy_Val (p_item_id  IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_rev_id  IN NUMBER,
                                  p_rev_date IN DATE,
                                  p_structure_type_id in NUMBER) RETURN VARCHAR2 IS
    CURSOR changePolicy IS
    SELECT ecp.policy_char_value
    FROM
     (SELECT NVL(mirb.lifecycle_id, msi.lifecycle_id) AS lifecycle_id,
       NVL(mirb.current_phase_id , msi.current_phase_id) AS phase_id,
       msi.item_catalog_group_id item_catalog_group_id,
       msi.inventory_item_id, msi.organization_id , mirb.revision_id
     FROM mtl_item_revisions_b mirb, MTL_SYSTEM_ITEMS_b msi
     WHERE msi.INVENTORY_ITEM_ID = p_item_id
       AND msi.ORGANIZATION_ID = p_org_id
       AND mirb.revision_id = nvl(p_rev_id,BOM_Revisions.Get_Item_Revision_Id_Fn('ALL','ALL',p_org_id, p_item_id, p_rev_date) )
       AND (mirb.current_phase_id IS NOT NULL OR msi.current_phase_id IS NOT NULL)) ITEM_DTLS,
       ENG_CHANGE_POLICIES_V ECP
   WHERE
     ecp.policy_object_pk1_value =
          (SELECT TO_CHAR(ic.item_catalog_group_id)
           FROM mtl_item_catalog_groups_b ic
           WHERE EXISTS (SELECT olc.object_classification_code CatalogId
                         FROM EGO_OBJ_TYPE_LIFECYCLES olc
                         WHERE olc.object_id = (SELECT OBJECT_ID
                                                FROM fnd_objects
                                                WHERE obj_name = 'EGO_ITEM')
                         AND  olc.lifecycle_id = ITEM_DTLS.lifecycle_id
                         AND olc.object_classification_code = ic.item_catalog_group_id
                         )
            AND ROWNUM = 1
            CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
            START WITH item_catalog_group_id = ITEM_DTLS.item_catalog_group_id)
     AND ecp.policy_object_pk2_value = item_dtls.lifecycle_id
     AND ecp.policy_object_pk3_value = item_dtls.phase_id
     AND ecp.policy_object_name ='CATALOG_LIFECYCLE_PHASE'
     AND ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
     AND ecp.attribute_code = 'STRUCTURE_TYPE'
     AND ecp.attribute_number_value = p_structure_type_id;

  BEGIN

    FOR r1 IN changePolicy
    LOOP
      Return r1.policy_char_value;
    END LOOP;

    Return 'ALLOWED';

  END;


  FUNCTION getItemRevCode(p_rev_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_rev_code MTL_ITEM_REVISIONS_B.REVISION%TYPE;
  BEGIN
    SELECT revision
    INTO l_rev_code
    FROM mtl_item_revisions_b
    WHERE revision_id = p_rev_id;

    RETURN l_rev_code;
  END;


  /* Return value: 'Y' --> Component's effectivity range is allowed
                    Revision: Change Ploicy value --> Component's effectivity range is NOT allowed.
                    Check the revision and the change policy value mentioned in the return value
  */

  FUNCTION Check_Change_Policy_Range (p_item_id IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_start_revision IN VARCHAR2,
                                  p_end_revision IN VARCHAR2,
                                  p_start_rev_id IN NUMBER,
                                  p_end_rev_id IN NUMBER,
                                  p_effective_date IN DATE,
                                  p_disable_date IN DATE,
                                  p_current_chg_pol IN VARCHAR2,
                                  p_structure_type_id IN NUMBER,
                                  p_use_eco IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR changePolicy(p_start_rev VARCHAR2, p_end_rev VARCHAR2) IS
    SELECT item_dtls.revision, ecp.policy_char_value
    FROM
     (SELECT NVL(mirb.lifecycle_id, msi.lifecycle_id) AS lifecycle_id,
       NVL(mirb.current_phase_id , msi.current_phase_id) AS phase_id,
       msi.item_catalog_group_id item_catalog_group_id,
       msi.inventory_item_id, msi.organization_id , mirb.revision
     FROM mtl_item_revisions_b mirb, MTL_SYSTEM_ITEMS_b msi
     WHERE msi.INVENTORY_ITEM_ID = p_item_id
       AND msi.ORGANIZATION_ID = p_org_id
       AND mirb.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
       AND mirb.ORGANIZATION_ID = msi.ORGANIZATION_ID
       AND mirb.revision >= nvl(p_start_rev,BOM_Revisions.Get_Item_Revision_Fn('ALL','ALL',p_org_id, p_item_id, p_effective_date) )
       AND mirb.revision <= nvl(p_end_rev,decode(p_disable_date,null,mirb.revision,BOM_Revisions.Get_Item_Revision_Fn('ALL','ALL',p_org_id, p_item_id, p_disable_date)) )
       AND (mirb.current_phase_id IS NOT NULL OR msi.current_phase_id IS NOT NULL)) ITEM_DTLS,
       ENG_CHANGE_POLICIES_V ECP
   WHERE
     ecp.policy_object_pk1_value =
          (SELECT TO_CHAR(ic.item_catalog_group_id)
           FROM mtl_item_catalog_groups_b ic
           WHERE EXISTS (SELECT olc.object_classification_code CatalogId
                         FROM EGO_OBJ_TYPE_LIFECYCLES olc
                         WHERE olc.object_id = (SELECT OBJECT_ID
                                                FROM fnd_objects
                                                WHERE obj_name = 'EGO_ITEM')
                         AND  olc.lifecycle_id = ITEM_DTLS.lifecycle_id
                         AND olc.object_classification_code = ic.item_catalog_group_id
                         )
            AND ROWNUM = 1
            CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
            START WITH item_catalog_group_id = ITEM_DTLS.item_catalog_group_id)
     AND ecp.policy_object_pk2_value = item_dtls.lifecycle_id
     AND ecp.policy_object_pk3_value = item_dtls.phase_id
     AND ecp.policy_object_name ='CATALOG_LIFECYCLE_PHASE'
     AND ecp.attribute_object_name = 'EGO_CATALOG_GROUP'
     AND ecp.attribute_code = 'STRUCTURE_TYPE'
     AND ecp.attribute_number_value = p_structure_type_id
     AND ecp.policy_char_value <> p_current_chg_pol
   ORDER BY item_dtls.revision;

   l_start_rev mtl_item_revisions_b.revision%TYPE;
   l_end_rev mtl_item_revisions_b.revision%TYPE;

  BEGIN
    l_start_rev := p_start_revision;
    l_end_rev := p_end_revision;
    IF p_start_revision IS NULL AND p_start_rev_id IS NOT NULL
    THEN
      l_start_rev := getItemRevCode(p_start_rev_id);
    END IF;
    IF p_end_revision IS NULL AND p_end_rev_id IS NOT NULL
    THEN
      l_end_rev := getItemRevCode(p_end_rev_id);
    END IF;

    FOR r1 IN changePolicy(l_start_rev, l_end_rev)
    LOOP
      IF r1.policy_char_value = 'NOT_ALLOWED'
         OR(r1.policy_char_value = 'CHANGE_ORDER_REQUIRED' AND p_use_eco <> 'Y')
      THEN
        Return r1.revision||': '||r1.policy_char_value;
      END IF;
    END LOOP;

    Return 'Y';
  END;


  FUNCTION getRevDate(p_rev_id IN NUMBER)
  RETURN VARCHAR2
  IS
    l_rev_date MTL_ITEM_REVISIONS_B.EFFECTIVITY_DATE%TYPE;
  BEGIN

    SELECT effectivity_date
    INTO l_rev_date
    FROM mtl_item_revisions_b
    where revision_id = p_rev_id;

    RETURN l_rev_date;
  END;


  FUNCTION Check_Change_Policy_Range (p_item_id IN NUMBER,
                                      p_org_id IN NUMBER,
                                      p_component_sequence_id IN NUMBER,
                                      p_current_chg_pol IN VARCHAR2,
                                      p_structure_type_id IN NUMBER,
                                      p_context_rev_id IN NUMBER,
                                      p_use_eco IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_start_rev_id NUMBER;
    l_end_rev_id NUMBER;
    l_effective_date DATE;
    l_disable_date DATE;
    l_start_date DATE;
    l_eff_ctrl NUMBER;

  BEGIN

    SELECT from_end_item_rev_id, to_end_item_rev_id, effectivity_date, disable_date
    INTO l_start_rev_id, l_end_rev_id, l_effective_date, l_disable_date
    FROM BOM_COMPONENTS_B
    WHERE component_sequence_id = p_component_sequence_id;

    IF p_context_rev_id IS NOT NULL
    THEN
      SELECT effectivity_date
      INTO l_start_date
      FROM mtl_item_revisions_b
      WHERE revision_id = p_context_rev_id;

      SELECT effectivity_control
      INTO l_eff_ctrl
      FROM BOM_STRUCTURES_B
      WHERE bill_sequence_id = (SELECT bill_sequence_id
                                FROM bom_components_b
                                WHERE component_sequence_id = p_component_sequence_id
                                AND ROWNUM = 1);

      IF l_eff_ctrl = 1 AND SYSDATE BETWEEN l_effective_date AND l_start_date
      THEN
        l_effective_date := l_start_date;
      ELSIF l_eff_ctrl = 4 AND getItemRevCode(p_context_rev_id) > getItemRevCode(l_start_rev_id)
            AND getRevDate(l_start_rev_id) < SYSDATE
      THEN
        l_start_rev_id := p_context_rev_id;
      END IF;
    END IF;

    RETURN Check_Change_Policy_Range (p_item_id => p_item_id,
                           p_org_id => p_org_id,
                           p_start_revision => null,
                           p_end_revision => null,
                           p_start_rev_id => l_start_rev_id,
                           p_end_rev_id => l_end_rev_id,
                           p_effective_date => l_effective_date,
                           p_disable_date => l_disable_date,
                           p_current_chg_pol => p_current_chg_pol,
                           p_structure_type_id => p_structure_type_id,
                           p_use_eco => p_use_eco);

  END;

  /*FUNCTION Check_Change_Policy_Range (p_item_id IN NUMBER,
                                      p_org_id IN NUMBER,
                                      p_component_sequence_id IN NUMBER,
                                      p_current_chg_pol IN VARCHAR2,
                                      p_structure_type_id IN NUMBER,
                                      p_use_eco IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_start_rev_id NUMBER;
    l_end_rev_id NUMBER;
    l_effective_date DATE;
    l_disable_date DATE;

  BEGIN

    SELECT from_end_item_rev_id, to_end_item_rev_id, effectivity_date, disable_date
    INTO l_start_rev_id, l_end_rev_id, l_effective_date, l_disable_date
    FROM BOM_COMPONENTS_B
    WHERE component_sequence_id = p_component_sequence_id;

    RETURN Check_Change_Policy_Range (p_item_id => p_item_id,
                           p_org_id => p_org_id,
                           p_start_revision => null,
                           p_end_revision => null,
                           p_start_rev_id => l_start_rev_id,
                           p_end_rev_id => l_end_rev_id,
                           p_effective_date => l_effective_date,
                           p_disable_date => l_disable_date,
                           p_current_chg_pol => p_current_chg_pol,
                           p_structure_type_id => p_structure_type_id,
                           p_use_eco => p_use_eco);

  END;
 */
  Procedure copy_Comp_User_Attrs(p_src_comp_seq_id IN NUMBER,
                                p_dest_comp_seq_id IN NUMBER,
                                x_Return_Status OUT NOCOPY VARCHAR2)
  IS
    l_dest_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_src_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_new_str_type EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_bill_seq_id   NUMBER;
    l_errorcode     NUMBER;
    l_msg_data      VARCHAR2(100);
    l_msg_count     NUMBER      :=  0;
    --l_return_status      VARCHAR2(1);
    l_str_type NUMBER;
    l_data_level_name_comp VARCHAR2(30) := 'COMPONENTS_LEVEL';
    l_data_level_id_comp   NUMBER;
    l_old_dtlevel_col_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_new_dtlevel_col_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;


    Cursor get_bill_seq_id(p_comp_sequence_id Number)
    IS
    SELECT bill_sequence_id
    from BOM_COMPONENTS_B
    where component_sequence_id = p_comp_sequence_id;

    Cursor get_structure_type(p_bill_seq_id NUMBER)
    IS
    Select structure_type_id
    from BOM_STRUCTURES_B
    where bill_sequence_id = p_bill_seq_id;

    CURSOR C_DATA_LEVEL(p_data_level_name VARCHAR2) IS
      SELECT DATA_LEVEL_ID
        FROM EGO_DATA_LEVEL_B
       WHERE DATA_LEVEL_NAME = p_data_level_name;


  BEGIN

    Open get_bill_seq_id(p_comp_sequence_id => p_src_comp_seq_id);
    Fetch get_bill_seq_id INTO l_bill_seq_id;
    Close get_bill_seq_id;

    Open get_structure_type(p_bill_seq_id => l_bill_seq_id);
    Fetch get_structure_type INTO l_str_type;
    Close get_structure_type;

    FOR c_comp_level IN C_DATA_LEVEL(l_data_level_name_comp) LOOP
      l_data_level_id_comp := c_comp_level.DATA_LEVEL_ID;
    END LOOP;

    l_src_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' , to_char(p_src_comp_seq_id))
                                                                ,EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' , to_char(l_bill_seq_id)) );
    l_dest_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' , to_char(p_dest_comp_seq_id)),
                                                                  EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' , to_char(l_bill_seq_id)) );
    l_new_str_type := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'STRUCTURE_TYPE_ID', TO_CHAR(l_str_type)));
    l_old_dtlevel_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID', ''));
    l_new_dtlevel_col_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID', ''));
/*
    EGO_USER_ATTRS_DATA_PUB.Copy_User_Attrs_Data(
                                                  p_api_version                 => 1.0
                                                  ,p_application_id              => 702
                                                  ,p_object_name                 => 'BOM_COMPONENTS'
                                                  ,p_old_pk_col_value_pairs      => l_src_pk_col_name_val_pairs
                                                  ,p_new_pk_col_value_pairs      =>  l_dest_pk_col_name_val_pairs
                                                  ,p_new_cc_col_value_pairs      => l_new_str_type
                                                  ,x_return_status               => x_Return_Status
                                                  ,x_errorcode                   => l_errorcode
                                                  ,x_msg_count                   => l_msg_count
                                                  ,x_msg_data                    => l_msg_data
                                                  );
*/
    EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data(
                                                  p_api_version                 => 1.0
                                                  ,p_application_id              => 702
                                                  ,p_object_name                 => 'BOM_COMPONENTS'
                                                  ,p_old_pk_col_value_pairs      => l_src_pk_col_name_val_pairs
                                                  ,p_new_pk_col_value_pairs      =>  l_dest_pk_col_name_val_pairs
                                                  ,p_new_cc_col_value_pairs      => l_new_str_type
                                                  ,p_old_data_level_id           => l_data_level_id_comp
                                                  ,p_new_data_level_id           => l_data_level_id_comp
                                                  ,p_old_dtlevel_col_value_pairs => l_old_dtlevel_col_value_pairs
                                                  ,p_new_dtlevel_col_value_pairs => l_new_dtlevel_col_value_pairs
                                                  ,x_return_status               => x_Return_Status
                                                  ,x_errorcode                   => l_errorcode
                                                  ,x_msg_count                   => l_msg_count
                                                  ,x_msg_data                    => l_msg_data
                                                  );


  IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
    THEN
      fnd_message.set_name('BOM', 'BOM_SPLIT_FAILED');
      return;
    END IF;
  END copy_Comp_User_Attrs;


  /* Function to split the component and copy the user attributes, RFD and Subcomps */
  FUNCTION split_component(p_comp_seq_id IN NUMBER,
	                         p_rev_id IN NUMBER,
                           p_disable_rev_id IN NUMBER,
                           p_disable_date IN DATE)
	RETURN NUMBER
  IS
    l_component_seqeunce_id NUMBER;
    l_Return_Status   VARCHAR2(1);
    l_effectivity_control NUMBER;
    l_start_effectivity_date DATE;
    l_disable_date DATE;
    l_start_rev_id NUMBER;
    l_end_rev_id NUMBER;
    l_temp_num NUMBER;
  BEGIN
  --Get the new ComponentSequenceId
  SELECT Bom_Inventory_Components_S.NEXTVAL INTO l_component_seqeunce_id FROM dual;

  --Get the parents effectivity control
  SELECT Effectivity_Control INTO l_effectivity_control FROM BOM_STRUCTURES_B
  WHERE Bill_Sequence_Id = (SELECT Bill_Sequence_Id FROM BOM_COMPONENTS_B WHERE COMPONENT_SEQUENCE_ID = p_comp_seq_id);

  -- IF the effectivity is not of date or rev return
  IF l_effectivity_control = 1  THEN
    SELECT Effectivity_Date INTO l_start_effectivity_date FROM MTL_ITEM_REVISIONS_B WHERE REVISION_ID = p_rev_id;
    SELECT Disable_date INTO l_disable_date FROM BOM_COMPONENTS_B WHERE COMPONENT_SEQUENCE_ID = p_comp_seq_id;
    l_start_rev_id := null;
    l_end_rev_id := null;
  ELSIF l_effectivity_control = 4 THEN
    SELECT SYSDATE INTO l_start_effectivity_date FROM dual;
    l_disable_date := null;
    l_start_rev_id := p_rev_id;
    SELECT To_End_Item_Rev_Id INTO l_end_rev_id FROM BOM_COMPONENTS_B WHERE COMPONENT_SEQUENCE_ID = p_comp_seq_id;
  ELSE
    l_component_seqeunce_id := 0;
    RETURN l_component_seqeunce_id;
  END IF;

  --Before creating new component, disable the existing row
  IF l_effectivity_control = 1
  THEN
    UPDATE bom_components_b
    SET disable_date =  p_disable_date
    WHERE component_sequence_id = p_comp_seq_id;
  ELSIF l_effectivity_control = 4
  THEN
    UPDATE bom_components_b
    SET to_end_item_rev_id = p_disable_rev_id
    WHERE component_sequence_id = p_comp_seq_id;
  END IF;


  --Create new Component
    INSERT  INTO BOM_COMPONENTS_B
      (       SUPPLY_SUBINVENTORY
      ,       OPERATION_LEAD_TIME_PERCENT
      ,       REVISED_ITEM_SEQUENCE_ID
      ,       COST_FACTOR
      ,       REQUIRED_FOR_REVENUE
      ,       HIGH_QUANTITY
      ,       COMPONENT_SEQUENCE_ID
      ,       PROGRAM_APPLICATION_ID
      ,       WIP_SUPPLY_TYPE
      ,       SUPPLY_LOCATOR_ID
      ,       BOM_ITEM_TYPE
      ,       OPERATION_SEQ_NUM
      ,       COMPONENT_ITEM_ID
      ,       LAST_UPDATE_DATE
      ,       LAST_UPDATED_BY
      ,       CREATION_DATE
      ,       CREATED_BY
      ,       LAST_UPDATE_LOGIN
      ,       ITEM_NUM
      ,       COMPONENT_QUANTITY
      ,       COMPONENT_YIELD_FACTOR
      ,       COMPONENT_REMARKS
      ,       EFFECTIVITY_DATE
      ,       CHANGE_NOTICE
      ,       IMPLEMENTATION_DATE
      ,       DISABLE_DATE
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
      ,       PLANNING_FACTOR
      ,       QUANTITY_RELATED
      ,       SO_BASIS
      ,       OPTIONAL
      ,       MUTUALLY_EXCLUSIVE_OPTIONS
      ,       INCLUDE_IN_COST_ROLLUP
      ,       CHECK_ATP
      ,       SHIPPING_ALLOWED
      ,       REQUIRED_TO_SHIP
      ,       INCLUDE_ON_SHIP_DOCS
      ,       INCLUDE_ON_BILL_DOCS
      ,       LOW_QUANTITY
      ,       ACD_TYPE
      ,       OLD_COMPONENT_SEQUENCE_ID
      ,       BILL_SEQUENCE_ID
      ,       REQUEST_ID
      ,       PROGRAM_ID
      ,       PROGRAM_UPDATE_DATE
      ,       PICK_COMPONENTS
      ,       Original_System_Reference
      ,       From_End_Item_Unit_Number
      ,       To_End_Item_Unit_Number
      ,       Eco_For_Production -- Added by MK
      ,       Enforce_Int_Requirements
      ,       Auto_Request_Material -- Added in 11.5.9 by ADEY
      ,       Obj_Name -- Added by hgelli.
      ,       pk1_value
      ,       pk2_value
      ,       Suggested_Vendor_Name --- Deepu
      ,       Vendor_Id --- Deepu
      ,       Unit_Price --- Deepu
      ,       from_object_revision_id
      ,       from_minor_revision_id
      ,       from_end_item_rev_id
      ,       to_end_item_rev_id
      ,       component_item_revision_id
      ,       basis_type
      ,       common_component_sequence_id
      )
     SELECT comp_rec.SUPPLY_SUBINVENTORY
      , comp_rec.OPERATION_LEAD_TIME_PERCENT
      , comp_rec.REVISED_ITEM_SEQUENCE_ID
      , comp_rec.COST_FACTOR
      , comp_rec.REQUIRED_FOR_REVENUE
      , comp_rec.HIGH_QUANTITY
      , l_component_seqeunce_id
      , comp_rec.PROGRAM_APPLICATION_ID
      , comp_rec.WIP_SUPPLY_TYPE
      , comp_rec.SUPPLY_LOCATOR_ID
      , comp_rec.BOM_ITEM_TYPE
      , comp_rec.OPERATION_SEQ_NUM
      , comp_rec.COMPONENT_ITEM_ID
      , sysdate
      , comp_rec.LAST_UPDATED_BY
      , sysdate
      , comp_rec.CREATED_BY
      , comp_rec.LAST_UPDATE_LOGIN
      , comp_rec.ITEM_NUM
      , comp_rec.COMPONENT_QUANTITY
      , comp_rec.COMPONENT_YIELD_FACTOR
      , comp_rec.COMPONENT_REMARKS
      , l_start_effectivity_date
      , comp_rec.CHANGE_NOTICE
      , comp_rec.IMPLEMENTATION_DATE
      , l_disable_date
      , comp_rec.ATTRIBUTE_CATEGORY
      , comp_rec.ATTRIBUTE1
      , comp_rec.ATTRIBUTE2
      , comp_rec.ATTRIBUTE3
      , comp_rec.ATTRIBUTE4
      , comp_rec.ATTRIBUTE5
      , comp_rec.ATTRIBUTE6
      , comp_rec.ATTRIBUTE7
      , comp_rec.ATTRIBUTE8
      , comp_rec.ATTRIBUTE9
      , comp_rec.ATTRIBUTE10
      , comp_rec.ATTRIBUTE11
      , comp_rec.ATTRIBUTE12
      , comp_rec.ATTRIBUTE13
      , comp_rec.ATTRIBUTE14
      , comp_rec.ATTRIBUTE15
      , comp_rec.PLANNING_FACTOR
      , comp_rec.QUANTITY_RELATED
      , comp_rec.SO_BASIS
      , comp_rec.OPTIONAL
      , comp_rec.MUTUALLY_EXCLUSIVE_OPTIONS
      , comp_rec.INCLUDE_IN_COST_ROLLUP
      , comp_rec.CHECK_ATP
      , comp_rec.SHIPPING_ALLOWED
      , comp_rec.REQUIRED_TO_SHIP
      , comp_rec.INCLUDE_ON_SHIP_DOCS
      , comp_rec.INCLUDE_ON_BILL_DOCS
      , comp_rec.LOW_QUANTITY
      , comp_rec.ACD_TYPE
      , comp_rec.OLD_COMPONENT_SEQUENCE_ID
      , comp_rec.bill_sequence_id
      , comp_rec.REQUEST_ID
      , comp_rec.PROGRAM_ID
      , comp_rec.PROGRAM_UPDATE_DATE
      , comp_rec.PICK_COMPONENTS
      , comp_rec.Original_System_Reference
      , comp_rec.From_End_Item_Unit_Number
      , comp_rec.To_End_Item_Unit_Number
      , comp_rec.Eco_For_Production -- Added by MK
      , comp_rec.Enforce_Int_Requirements
      , comp_rec.Auto_Request_Material -- Added in 11.5.9 by ADEY
      , comp_rec.Obj_Name -- Added by hgelli.
      , comp_rec.pk1_value
      , comp_rec.pk2_value
      , comp_rec.Suggested_Vendor_Name --- Deepu
      , comp_rec.Vendor_Id --- Deepu
      , comp_rec.Unit_Price --- Deepu
      , comp_rec.from_object_revision_id
      , comp_rec.from_minor_revision_id
      , l_start_rev_id
      , l_end_rev_id
      , comp_rec.component_item_revision_id
      , comp_rec.basis_type
      , comp_rec.common_component_sequence_id
      FROM BOM_COMPONENTS_B comp_rec
      WHERE comp_rec.component_sequence_id = p_comp_seq_id;

    SELECT Count(1) INTO l_temp_num FROM bom_components_b WHERE component_sequence_id = l_component_seqeunce_id;

  --Copy component user attributes to new component
    copy_Comp_User_Attrs(p_src_comp_seq_id  => p_comp_seq_id,
                         p_dest_comp_seq_id => l_component_seqeunce_id,
                         x_Return_Status    => l_Return_Status);

  --EMTAPIA: Start added to support component UDA override values
  --Copy component user attribute override values to new component
    BOM_UDA_OVERRIDES_PVT.Copy_Comp_UDA_Overrides(p_comp_seq_id, l_component_seqeunce_id);
  --EMTAPIA: End added to support component UDA override values

  -- Copy Reference designators to new component
  INSERT  INTO BOM_REFERENCE_DESIGNATORS
  (       COMPONENT_REFERENCE_DESIGNATOR
  ,       LAST_UPDATE_DATE
  ,       LAST_UPDATED_BY
  ,       CREATION_DATE
  ,       CREATED_BY
  ,       LAST_UPDATE_LOGIN
  ,       REF_DESIGNATOR_COMMENT
  ,       CHANGE_NOTICE
  ,       COMPONENT_SEQUENCE_ID
  ,       ACD_TYPE
  ,       REQUEST_ID
  ,       PROGRAM_APPLICATION_ID
  ,       PROGRAM_ID
  ,       PROGRAM_UPDATE_DATE
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
  ,       Original_System_Reference
  ,       common_component_sequence_id
  )
  SELECT
          ref_desg.component_reference_designator
  ,       SYSDATE
  ,       ref_desg.LAST_UPDATED_BY
  ,       SYSDATE
  ,       ref_desg.CREATED_BY
  ,       ref_desg.LAST_UPDATE_LOGIN
  ,       DECODE( ref_desg.ref_designator_comment
                , FND_API.G_MISS_CHAR
                , NULL
                , ref_desg.ref_designator_comment )
  ,       ref_desg.change_notice
  ,       l_component_seqeunce_id
  ,       ref_desg.acd_type
  ,       NULL /* Request Id */
  ,       Bom_Globals.Get_Prog_AppId
  ,       Bom_Globals.Get_Prog_Id
  ,       SYSDATE
  ,       ref_desg.attribute_category
  ,       ref_desg.attribute1
  ,       ref_desg.attribute2
  ,       ref_desg.attribute3
  ,       ref_desg.attribute4
  ,       ref_desg.attribute5
  ,       ref_desg.attribute6
  ,       ref_desg.attribute7
  ,       ref_desg.attribute8
  ,       ref_desg.attribute9
  ,       ref_desg.attribute10
  ,       ref_desg.attribute11
  ,       ref_desg.attribute12
  ,       ref_desg.attribute13
  ,       ref_desg.attribute14
  ,       ref_desg.attribute15
  ,       ref_desg.Original_System_Reference
  ,       ref_desg.common_component_sequence_id
  FROM BOM_REFERENCE_DESIGNATORS ref_desg
  WHERE ref_desg.component_sequence_id = p_comp_seq_id;

    -- Copy Substitute components to new component
  INSERT  INTO BOM_SUBSTITUTE_COMPONENTS
  (       SUBSTITUTE_COMPONENT_ID
  ,       LAST_UPDATE_DATE
  ,       LAST_UPDATED_BY
  ,       CREATION_DATE
  ,       CREATED_BY
  ,       LAST_UPDATE_LOGIN
  ,       SUBSTITUTE_ITEM_QUANTITY
  ,       COMPONENT_SEQUENCE_ID
  ,       ACD_TYPE
  ,       CHANGE_NOTICE
  ,       REQUEST_ID
  ,       PROGRAM_APPLICATION_ID
  ,       PROGRAM_UPDATE_DATE
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
  ,       PROGRAM_ID
  ,       Original_System_Reference
  ,       Enforce_Int_Requirements
  ,       common_component_sequence_id
  )
  SELECT
          sub_comp.substitute_component_id
  ,       SYSDATE
  ,       sub_comp.LAST_UPDATED_BY
  ,       SYSDATE
  ,       sub_comp.CREATED_BY
  ,       sub_comp.LAST_UPDATE_LOGIN
  ,       sub_comp.substitute_item_quantity
  ,       l_component_seqeunce_id
  ,       sub_comp.acd_type
  ,       sub_comp.Change_Notice
  ,     NULL /* Request Id */
  ,       Bom_Globals.Get_Prog_AppId
  ,       SYSDATE
  ,       sub_comp.attribute_category
  ,       sub_comp.attribute1
  ,       sub_comp.attribute2
  ,       sub_comp.attribute3
  ,       sub_comp.attribute4
  ,       sub_comp.attribute5
  ,       sub_comp.attribute6
  ,       sub_comp.attribute7
  ,       sub_comp.attribute8
  ,       sub_comp.attribute9
  ,       sub_comp.attribute10
  ,       sub_comp.attribute11
  ,       sub_comp.attribute12
  ,       sub_comp.attribute13
  ,       sub_comp.attribute14
  ,       sub_comp.attribute15
  ,       Bom_Globals.Get_Prog_Id
  ,       sub_comp.Original_System_Reference
  ,       sub_comp.enforce_int_requirements
  ,       sub_comp.common_component_sequence_id
  FROM BOM_SUBSTITUTE_COMPONENTS sub_comp
  WHERE sub_comp.component_sequence_id = p_comp_seq_id;


    INSERT INTO bom_component_operations
    (
    COMP_OPERATION_SEQ_ID          ,
    OPERATION_SEQ_NUM              ,
    OPERATION_SEQUENCE_ID          ,
    LAST_UPDATE_DATE               ,
    LAST_UPDATED_BY                ,
    CREATION_DATE                  ,
    CREATED_BY                     ,
    LAST_UPDATE_LOGIN              ,
    COMPONENT_SEQUENCE_ID          ,
    BILL_SEQUENCE_ID               ,
    CONSUMING_OPERATION_FLAG       ,
    CONSUMPTION_QUANTITY           ,
    SUPPLY_SUBINVENTORY            ,
    SUPPLY_LOCATOR_ID              ,
    WIP_SUPPLY_TYPE                ,
    ATTRIBUTE_CATEGORY             ,
    ATTRIBUTE1                     ,
    ATTRIBUTE2                     ,
    ATTRIBUTE3                     ,
    ATTRIBUTE4                     ,
    ATTRIBUTE5                     ,
    ATTRIBUTE6                     ,
    ATTRIBUTE7                     ,
    ATTRIBUTE8                     ,
    ATTRIBUTE9                     ,
    ATTRIBUTE10                    ,
    ATTRIBUTE11                    ,
    ATTRIBUTE12                    ,
    ATTRIBUTE13                    ,
    ATTRIBUTE14                    ,
    ATTRIBUTE15                    ,
    COMMON_COMPONENT_SEQUENCE_ID)
  SELECT
    bom_component_operations_s.NEXTVAL      ,
    comp_ops.OPERATION_SEQ_NUM              ,
    comp_ops.OPERATION_SEQUENCE_ID          ,
    comp_ops.LAST_UPDATE_DATE               ,
    comp_ops.LAST_UPDATED_BY                ,
    comp_ops.CREATION_DATE                  ,
    comp_ops.CREATED_BY                     ,
    comp_ops.LAST_UPDATE_LOGIN              ,
    l_component_seqeunce_id                 ,
    comp_ops.BILL_SEQUENCE_ID               ,
    comp_ops.CONSUMING_OPERATION_FLAG       ,
    comp_ops.CONSUMPTION_QUANTITY           ,
    comp_ops.SUPPLY_SUBINVENTORY            ,
    comp_ops.SUPPLY_LOCATOR_ID              ,
    comp_ops.WIP_SUPPLY_TYPE                ,
    comp_ops.ATTRIBUTE_CATEGORY             ,
    comp_ops.ATTRIBUTE1                     ,
    comp_ops.ATTRIBUTE2                     ,
    comp_ops.ATTRIBUTE3                     ,
    comp_ops.ATTRIBUTE4                     ,
    comp_ops.ATTRIBUTE5                     ,
    comp_ops.ATTRIBUTE6                     ,
    comp_ops.ATTRIBUTE7                     ,
    comp_ops.ATTRIBUTE8                     ,
    comp_ops.ATTRIBUTE9                     ,
    comp_ops.ATTRIBUTE10                    ,
    comp_ops.ATTRIBUTE11                    ,
    comp_ops.ATTRIBUTE12                    ,
    comp_ops.ATTRIBUTE13                    ,
    comp_ops.ATTRIBUTE14                    ,
    comp_ops.ATTRIBUTE15                    ,
    comp_ops.COMMON_COMPONENT_SEQUENCE_ID
  FROM BOM_COMPONENT_OPERATIONS comp_ops
  WHERE comp_ops.component_sequence_id = p_comp_seq_id;


  RETURN l_component_seqeunce_id;
  END split_component;

  /* Function to get the effective component with respect to the passed parent item's revision and explosion date*/
  FUNCTION get_effetive_component(p_comp_seq_id IN NUMBER,
	                                p_rev_id IN NUMBER,
                                  p_explosion_date DATE)
	RETURN NUMBER
  IS
    l_component_seqeunce_id NUMBER;
    l_effectivity_control NUMBER;
    l_start_effectivity_date DATE;
    l_rev_code VARCHAR2(30);
  BEGIN
    --Get the parents effectivity control
    SELECT Effectivity_Control INTO l_effectivity_control FROM BOM_STRUCTURES_B
    WHERE Bill_Sequence_Id = (SELECT Bill_Sequence_Id FROM BOM_COMPONENTS_B WHERE COMPONENT_SEQUENCE_ID = p_comp_seq_id);

    -- IF the effectivity is not of date or rev return
    BEGIN
      IF l_effectivity_control = 1  THEN -- DATE
        IF p_explosion_date IS NULL THEN
          SELECT Effectivity_Date INTO l_start_effectivity_date FROM MTL_ITEM_REVISIONS_B WHERE REVISION_ID = p_rev_id;
          IF(l_start_effectivity_date < SYSDATE) THEN
            l_start_effectivity_date := SYSDATE;
          END IF;
        ELSE
          l_start_effectivity_date := p_explosion_date;
        END IF;
        SELECT
          bcb2.component_sequence_id INTO l_component_seqeunce_id
        FROM
          bom_components_b bcb1, bom_components_b bcb2
        WHERE
          bcb1.component_sequence_id = p_comp_seq_id
          AND bcb1.bill_sequence_id = bcb2.bill_sequence_id
          AND nvl(bcb1.obj_name,'EGO_ITEM') = nvl(bcb2.obj_name,'EGO_ITEM')
          AND bcb1.pk1_value = bcb2.pk1_value
          AND bcb1.operation_seq_num = bcb2.operation_seq_num
          AND bcb2.Implementation_Date IS NOT NULL
          AND bcb2.effectivity_date <= l_start_effectivity_date
          AND (bcb2.disable_date IS NULL OR bcb2.disable_date > l_start_effectivity_date);

      ELSIF l_effectivity_control = 4 THEN -- REVISION
        SELECT Revision INTO l_rev_code FROM MTL_ITEM_REVISIONS_B WHERE REVISION_ID = p_rev_id;
        SELECT
          bcb2.component_sequence_id INTO l_component_seqeunce_id
        FROM
          bom_components_b bcb1, bom_components_b bcb2, mtl_item_revisions_b mirb1, mtl_item_revisions_b mirb2
        WHERE
          bcb1.component_sequence_id = p_comp_seq_id
          AND bcb1.bill_sequence_id = bcb2.bill_sequence_id
          AND nvl(bcb1.obj_name,'EGO_ITEM') = nvl(bcb2.obj_name,'EGO_ITEM')
          AND bcb1.pk1_value = bcb2.pk1_value
          AND bcb1.operation_seq_num = bcb2.operation_seq_num
          AND bcb2.Implementation_Date IS NOT NULL
          AND bcb2.disable_date IS NULL
          AND mirb1.revision_id = bcb2.from_end_item_rev_id
          AND mirb2.revision_id = Nvl(bcb2.to_end_item_rev_id, bcb2.from_end_item_rev_id)
          AND mirb1.revision <= l_rev_code
          AND (bcb2.to_end_item_rev_id IS NULL OR mirb2.revision >= l_rev_code);

      ELSE
        l_component_seqeunce_id := p_comp_seq_id;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_component_seqeunce_id := p_comp_seq_id;
    END;

    RETURN l_component_seqeunce_id;
  END get_effetive_component;

  /* Function to get the effective component with respect to the passed parent item's revision */
  FUNCTION get_effetive_component(p_comp_seq_id IN NUMBER,
	                                p_rev_id IN NUMBER)
  RETURN NUMBER
  IS
  BEGIN
    RETURN get_effetive_component(p_comp_seq_id, p_rev_id, NULL);
  END get_effetive_component;

  /* Function to get the catalog category name for the given item_catalog_group_id */
  FUNCTION get_item_catalog_category(p_item_catalog_group_id IN NUMBER)
    RETURN VARCHAR2
  IS
    l_catalog_category_name VARCHAR2(2020);
  BEGIN
--   Bug 7570437 mtl_item_catalog_groups_kfv should not be used.
--	SELECT concatenated_segments
     	  SELECT decode(MICG.item_catalog_group_id, NULL, NULL,
	         FND_FLEX_SERVER.GET_KFV_CONCAT_SEGS_BY_CCID('COMPACT',401,'MICG',101,MICG.item_catalog_group_id,NULL) )
	  INTO l_catalog_category_name
  	  FROM mtl_item_catalog_groups MICG
--	  FROM mtl_item_catalog_groups_kfv
	 WHERE item_catalog_group_id = p_item_catalog_group_id;

    RETURN l_catalog_category_name;

	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    RETURN NULL;
  END;


  FUNCTION Get_Bill_Header_ECN(p_bill_seq_id IN NUMBER)
    RETURN VARCHAR2
  IS
    l_pend_from_ecn BOM_STRUCTURES_B.pending_from_ecn%TYPE;
  BEGIN
    SELECT pending_from_ecn
    INTO l_pend_from_ecn
    FROM bom_structures_b
    WHERE bill_sequence_id = p_bill_Seq_id;

    IF l_pend_from_ecn IS NOT NULL
    THEN
      RETURN l_pend_from_ecn;
    END IF;

    RETURN NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

  END;

PROCEDURE  uda_attribute_defaulting(p_bill_sequence_id IN VARCHAR2
                             ,p_component_sequence_id  IN VARCHAR2 DEFAULT NULL
                             ,p_object_name            IN VARCHAR2
                             ,p_structure_type_id      IN VARCHAR2
                             ,x_return_status       OUT NOCOPY VARCHAR2
                             ,x_msg_data            OUT NOCOPY VARCHAR2)

IS

  l_error_code VARCHAR2(2000);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_failed_row_id_list  VARCHAR2(2000);

  l_pk_column_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_data_level_values EGO_COL_NAME_VALUE_PAIR_ARRAY;

  l_object_name VARCHAR2(50);
  l_application_id NUMBER;
  l_additional_class_Code_list VARCHAR2(32000);
  l_attribute_group_type VARCHAR2(50);
  --Added for bug 8462879
  l_message_list  ERROR_HANDLER.Error_Tbl_Type;
  --EMTAPIA: Start added to support data levels in component udas
  l_data_level VARCHAR2(50):= NULL;
  --EMTAPIA: End added to support data levels in component udas

  l_return_status VARCHAR2(10);

  CURSOR parent_st_type_cursor
  IS
  SELECT STRUCTURE_TYPE_ID,PARENT_STRUCTURE_TYPE_ID
    FROM BOM_STRUCTURE_TYPES_B
  CONNECT BY PRIOR PARENT_STRUCTURE_TYPE_ID = STRUCTURE_TYPE_ID
    START WITH STRUCTURE_TYPE_ID = p_structure_type_id;

BEGIN
  x_return_status := l_return_status;
  l_additional_class_Code_list := NULL;

  IF p_object_name = 'BOM_STRUCTURE' THEN
    l_object_name := 'BOM_STRUCTURE';
    l_attribute_group_type := 'BOM_STRUCTUREMGMT_GROUP';

    l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
      ( EGO_COL_NAME_VALUE_PAIR_OBJ('BILL_SEQUENCE_ID', p_bill_sequence_id));

    l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
      (EGO_COL_NAME_VALUE_PAIR_OBJ('STRUCTURE_TYPE_ID', p_structure_type_id));

  ELSIF p_object_name = 'BOM_COMPONENTS' THEN
    l_object_name := 'BOM_COMPONENTS';
    l_attribute_group_type := 'BOM_COMPONENTMGMT_GROUP';
    l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
      ( EGO_COL_NAME_VALUE_PAIR_OBJ('COMPONENT_SEQUENCE_ID', p_component_sequence_id)
      , EGO_COL_NAME_VALUE_PAIR_OBJ('BILL_SEQUENCE_ID', p_bill_sequence_id));

    l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
      (EGO_COL_NAME_VALUE_PAIR_OBJ('STRUCTURE_TYPE_ID', p_structure_type_id));

    --EMTAPIA: Start support for data levels in component udas
      l_data_level := 'COMPONENTS_LEVEL';
    --EMTAPIA: End support for data levels in component udas

  END IF;

  l_application_id := 702;

  FOR st_type_rec IN parent_st_type_cursor
  LOOP
    IF (st_type_rec.PARENT_STRUCTURE_TYPE_ID IS NOT NULL) THEN
      l_additional_class_Code_list := l_additional_class_Code_list || st_type_rec.PARENT_STRUCTURE_TYPE_ID || ',';
    END IF;
  END LOOP;

  IF l_additional_class_Code_list IS NULL  THEN
    l_additional_class_Code_list := '1';
  ELSE
    l_additional_class_Code_list := l_additional_class_Code_list|| p_structure_type_id ;
  END IF;
  EGO_USER_ATTRS_DATA_PVT.Apply_Default_Vals_For_Entity
        ( p_object_name                  => l_object_name
        ,p_application_id                => l_application_id
        ,p_attr_group_type               => l_attribute_group_type
        ,p_attr_groups_to_exclude        => null
        ,p_pk_column_name_value_pairs    => l_pk_column_name_value_pairs
        ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
        ,p_data_level                    => l_data_level   --EMTAPIA: Added to support component uda data levels
        ,p_data_level_values             => null
        ,p_additional_class_Code_list    => l_additional_class_Code_list
        ,p_init_error_handler            => 'T'
        ,p_init_fnd_msg_list             => 'T'
        ,p_log_errors                    => 'T'
        ,p_add_errors_to_fnd_stack       => 'T'
        ,P_commit                        => 'F'
        ,x_failed_row_id_list            => l_failed_row_id_list
        ,x_return_status                 => l_return_status
        ,x_errorcode                     => l_error_code
        ,x_msg_count                     => l_msg_count
        ,x_msg_data                      => l_msg_data
        );

  x_return_status := l_return_status ;
  --for bug 8462879 return x_msg_data
     if (l_msg_count>0 AND l_return_status<>FND_API.G_RET_STS_SUCCESS) then
           ERROR_HANDLER.Get_Message_List(l_message_list);
       FOR i IN l_message_list.FIRST..l_message_list.LAST
        LOOP
         x_msg_data := x_msg_data || l_message_list(i).message_text;
       END LOOP;
     else
           x_msg_data := l_msg_data;
     end if ;
  --for bug 8462879 return x_msg_data end

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;

END uda_attribute_defaulting;

/*
 * This API is the  Starting point for Logging time statistics
 * for Performance Testing.G_TIME_LOGGED stores the start time and
 * G_METHOD_LOGGED stores the current API for which time is logged
 */
PROCEDURE Init_Logging
IS
BEGIN
   G_TIME_LOGGED := new NUM_VARRAY();
   G_METHOD_LOGGED  := new VARCHAR2_VARRAY();
   G_TOP  := 0 ;
END Init_Logging;

/*
 * API for writing the Performance Statistics in XML format.
 * This will create the data in xml format in the fnd_util_file
 */
PROCEDURE Start_Logging(flow_name VARCHAR2,flow_id NUMBER)
IS
BEGIN
  IF ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) AND  ( G_PROFILE_ENABLED = FND_PROFILE.VALUE('BOM:LOG_EXECUTION_TIME'))) THEN
    G_FLOW_ID := flow_id;
    FND_FILE.put_line(FND_FILE.LOG,'BOM Performance Log: <PerformanceStatistics flowID= "' || flow_id || '"  flowName= "' || flow_name || '" >');
  END IF;
END Start_Logging;

/*
 * API for Logging the beginning of any Procedure whose execution time
 * needs to calculated
 */
PROCEDURE Log_Start_Time(operation_name VARCHAR2)
IS
BEGIN
   G_TIME_LOGGED.extend;
   G_METHOD_LOGGED.extend;
   IF G_TOP < G_STACK_SIZE THEN
      G_TOP := G_TOP + 1;
      SELECT dbms_utility.get_time INTO G_TIME_LOGGED(G_TOP) FROM dual;
      G_METHOD_LOGGED(G_TOP) := operation_name;
   END IF;
END Log_Start_Time;

/*
 * API for calculating the execution time for any API
 */
PROCEDURE Log_Exec_Time
IS
temp1 NUMBER;
temp2 NUMBER;
BEGIN
  IF ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) AND  ( G_PROFILE_ENABLED = FND_PROFILE.VALUE('BOM:LOG_EXECUTION_TIME'))) THEN
    IF G_TOP > 0 THEN
     temp1 := G_TIME_LOGGED(G_TOP);
     SELECT  dbms_utility.get_time INTO temp2 FROM dual;
     FND_FILE.put_line(FND_FILE.LOG,'BOM Performance Log: <Operation flowID= "' || G_FLOW_ID || '" flowName= "' || G_METHOD_LOGGED(G_TOP) || '" ExecTimeinMillis= "'|| (temp2 - temp1) || '" >');
     G_TOP := G_TOP -1 ;
    END IF;
  END IF;
END Log_Exec_Time;

/*
 * API for creating the correct closing tags for the xml format getting
 * created in fnd util file
 */


PROCEDURE Stop_Logging
IS
BEGIN
  IF ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) AND  ( G_PROFILE_ENABLED = FND_PROFILE.VALUE('BOM:LOG_EXECUTION_TIME'))) THEN
    FND_FILE.put_line(FND_FILE.LOG,'BOM Performance Log: </PerformanceStatistics>');
  END IF;
END Stop_Logging;


  PROCEDURE set_show_Impl_comps_only(p_option IN VARCHAR2)
  IS
  BEGIN
  G_SHOW_IMPL_COMPS_ONLY := p_option;
  END;


  FUNCTION get_show_Impl_comps_only RETURN VARCHAR2
  IS
  BEGIN
    RETURN G_SHOW_IMPL_COMPS_ONLY;
  END;


  FUNCTION check_chg_pol_for_delete(p_bill_seq_id IN NUMBER,
                                    p_comp_seq_id IN NUMBER,
                                    p_start_revision IN VARCHAR2,
                                    p_end_revision IN VARCHAR2,
                                    p_start_rev_id IN NUMBER,
                                    p_end_rev_id IN NUMBER,
                                    p_effective_date IN DATE,
                                    p_disable_date IN DATE,
                                    p_current_chg_pol IN VARCHAR2) RETURN VARCHAR2
  IS
    l_item_id NUMBER;
    l_org_id NUMBER;
    l_str_type_id NUMBER;
    l_initial_rev mtl_item_revisions_b.revision%TYPE;
  BEGIN

    SELECT assembly_item_id, organization_id, structure_type_id
    INTO l_item_id, l_org_id, l_str_type_id
    FROM BOM_STRUCTURES_B
    WHERE bill_sequence_id = p_bill_seq_id;

    IF p_comp_seq_id IS NOT NULL --Component delete
    THEN
      RETURN Check_Change_Policy_Range (p_item_id => l_item_id,
                                        p_org_id => l_org_id,
                                        p_component_sequence_id => p_comp_seq_id,
                                        p_current_chg_pol => p_current_chg_pol,
                                        p_structure_type_id => l_str_type_id,
                                        p_context_rev_id => null,
                                        p_use_eco => 'N');
    ELSE --structure delete
      SELECT revision
      INTO l_initial_rev
      FROM (SELECT revision
            FROM mtl_item_revisions_b
            WHERE inventory_item_id = l_item_id
            AND organization_id = l_org_id
            AND implementation_date IS NOT NULL
            ORDER BY effectivity_date)
      WHERE ROWNUM = 1;

      RETURN Check_Change_Policy_Range (p_item_id => l_item_id,
                             p_org_id => l_org_id,
                             p_start_revision => l_initial_rev,
                             p_end_revision => null,
                             p_start_rev_id => null,
                             p_end_rev_id => null,
                             p_effective_date => null,
                             p_disable_date => null,
                             p_current_chg_pol => p_current_chg_pol,
                             p_structure_type_id => l_str_type_id,
                             p_use_eco => 'N');
    END IF;

  END;


FUNCTION get_comp_names(p_comp_seq_ids IN VARCHAR2) RETURN VARCHAR2
IS
  l_item_id NUMBER;
  l_org_id NUMBER;
  l_item_names VARCHAR2(32767) := '';

  CURSOR get_item_details
  IS
  SELECT pk1_value, pk2_value
  FROM bom_components_b
  WHERE INSTR(','||p_comp_seq_ids||',', ','||component_sequence_id||',') > 0;

BEGIN
  FOR item IN get_item_details
  LOOP
    l_item_id := item.pk1_value;
    l_org_id := item.pk2_value;
    l_item_names := l_item_names || Get_Item_Name(l_item_id, l_org_id) || ', ';  END LOOP;
  IF (l_item_names IS NOT NULL) THEN
    l_item_names := substr(l_item_names, 0, length(l_item_names) - 2);
  END IF;
  IF(length(l_item_names) >= 4000) THEN
    l_item_names := substr(l_item_names, 0, 3994) || ', ...';
  END IF;
  RETURN l_item_names;
END;


FUNCTION get_lookup_meaning(p_lookup_type IN VARCHAR2,
                            p_lookup_code IN VARCHAR2) RETURN VARCHAR2
IS
  l_meaning mfg_lookups.meaning%TYPE := NULL;
BEGIN
  SELECT meaning
  INTO l_meaning
  FROM mfg_lookups
  WHERE lookup_type = p_lookup_type
  AND lookup_code = p_lookup_code;

  RETURN l_meaning;
EXCEPTION
  WHEN No_Data_Found THEN
    RETURN l_meaning;
END;

/****************************************************************************
* Procedure : Set_Profile_Org_id
* Returns : None
* Parameters IN : Organization_Id
* Parameters OUT: None
* Purpose : Will set the 'MFG_ORGANIZATION_ID in the profile
* For Bug id
*****************************************************************************/
PROCEDURE Set_Profile_Org_id
    ( p_org_id  IN  NUMBER)
IS
BEGIN

fnd_profile.put('MFG_ORGANIZATION_ID', p_org_id);

END Set_Profile_Org_id;
END BOM_Globals;

/
