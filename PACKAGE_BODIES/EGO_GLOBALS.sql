--------------------------------------------------------
--  DDL for Package Body EGO_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_GLOBALS" AS
/* $Header: EGOSGLBB.pls 120.1 2005/06/02 05:40:41 lkapoor noship $ */
/**********************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGOSGLBB.pls
--
--  DESCRIPTION
--
--      Body of package EGO_Globals
--
--  NOTES
--
--  HISTORY
--
-- 19-SEPT-2002	Rahul Chitko	Initial Creation
--
**********************************************************************/

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'EGO_Globals';


PROCEDURE Set_Language_Code(p_language_code VARCHAR2)
IS
BEGIN
	G_System_Information.Language_Code := p_Language_Code;
END;

FUNCTION Get_Language_Code RETURN VARCHAR2
IS
BEGIN
	return G_System_Information.Language_Code;
END;

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
	G_System_Information.user_id := p_user_id;

END Set_User_Id;

/***************************************************************************
* Function	: Get_user_Id
* Returns	: Number
* Parameters IN : None
* Parameters OUT: None
* Purpose	: Will return the user_id attribute from the
*		  system_information_record
*****************************************************************************/
FUNCTION Get_User_ID RETURN NUMBER
IS
BEGIN
	RETURN G_System_Information.User_id;

END Get_User_id;

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

/**************************************************************************
* Procedure	: Transaction_Type_Validity
* Parameters IN	: Transaction Type
*		  Entity Name
*		  Entity ID, so that it can be used in a meaningful message
* Parameters OUT: Valid flag
*		  Message Token Table
* Purpose	: This procedure will check if the transaction type is valid
*		  for a particular entity.
**************************************************************************/
PROCEDURE Transaction_Type_Validity
(   p_transaction_type              IN  VARCHAR2
,   p_entity                        IN  VARCHAR2
,   p_entity_id                     IN  VARCHAR2
,   x_valid                         OUT NOCOPY BOOLEAN
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
BEGIN
    l_token_tbl(1).token_name := 'ENTITY_ID';
    l_token_tbl(1).token_value := p_entity_id;

    IF (p_Entity_ID = EGO_Globals.G_ITEM_CATALOG_GROUP AND
	p_transaction_type NOT IN (EGO_Globals.G_OPR_CREATE, EGO_GLOBALS.G_OPR_UPDATE,
				   EGO_GLOBALS.G_OPR_DELETE, 'SYNC')
        )
    THEN
	Error_Handler.Add_Error_Token( p_Message_Name 	=> 'EGO_INVALID_TRANS_TYPE'
				     , p_token_tbl	=> l_token_tbl
				     , x_Mesg_Token_Tbl => x_mesg_token_tbl
				      );

	x_valid := false;
    END IF;

    x_valid := TRUE;

END Transaction_Type_Validity;

END EGO_Globals;

/
