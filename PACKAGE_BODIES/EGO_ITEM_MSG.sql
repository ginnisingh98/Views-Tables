--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_MSG" AS
/* $Header: EGOMITMB.pls 115.0 2002/12/12 15:39:54 anakas noship $ */

G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOMITMB.pls';
G_PKG_NAME        CONSTANT  VARCHAR2(30)  :=  'EGO_ITEM_MSG';

-- =============================================================================
--                         Package variables and cursors
-- =============================================================================

G_Entity_Code		VARCHAR2(30)    :=  'ITEM';
G_Table_Name		VARCHAR2(30)    :=  'MTL_SYSTEM_ITEMS_B';
G_Transaction_Id	NUMBER		:=  NULL;

-- =============================================================================
--                                  Procedures
-- =============================================================================

-- -----------------------------------------------------------------------------
--  API Name:		Add_Error_Message
-- -----------------------------------------------------------------------------

PROCEDURE Add_Error_Message
(
   p_Entity_Index		IN      NUMBER
,  p_Application_Short_Name	IN	VARCHAR2
,  p_Message_Name		IN      VARCHAR2
,  p_Token_Name1		IN      VARCHAR2	DEFAULT  NULL
,  p_Token_Value1		IN      VARCHAR2	DEFAULT  NULL
,  p_Translate1			IN      BOOLEAN		DEFAULT  FALSE
,  p_Token_Name2		IN      VARCHAR2	DEFAULT  NULL
,  p_Token_Value2		IN      VARCHAR2	DEFAULT  NULL
,  p_Translate2			IN      BOOLEAN		DEFAULT  FALSE
,  p_Token_Name3		IN      VARCHAR2	DEFAULT  NULL
,  p_Token_Value3		IN      VARCHAR2	DEFAULT  NULL
,  p_Translate3			IN      BOOLEAN		DEFAULT  FALSE
)
IS
   l_Token_Tbl			Error_Handler.Token_Tbl_Type;
BEGIN

   IF ( p_Token_Name1 IS NOT NULL ) THEN
      l_Token_Tbl(1).Token_Name   :=  p_Token_Name1;
      l_Token_Tbl(1).Token_Value  :=  p_Token_Value1;
      l_Token_Tbl(1).Translate    :=  p_Translate1;
   END IF;
   IF ( p_Token_Name2 IS NOT NULL ) THEN
      l_Token_Tbl(2).Token_Name   :=  p_Token_Name2;
      l_Token_Tbl(2).Token_Value  :=  p_Token_Value2;
      l_Token_Tbl(2).Translate    :=  p_Translate2;
   END IF;
   IF ( p_Token_Name3 IS NOT NULL ) THEN
      l_Token_Tbl(3).Token_Name   :=  p_Token_Name3;
      l_Token_Tbl(3).Token_Value  :=  p_Token_Value3;
      l_Token_Tbl(3).Translate    :=  p_Translate3;
   END IF;

   Error_Handler.Add_Error_Message
   (
      p_message_name		=>  p_Message_Name
   ,  p_application_id		=>  p_Application_Short_Name
   ,  p_token_tbl		=>  l_Token_Tbl
   ,  p_message_type		=>  'E'
   ,  p_row_identifier		=>  G_Transaction_Id
   ,  p_entity_id		=>  NULL
   ,  p_entity_code		=>  G_Entity_Code
   ,  p_entity_index		=>  p_Entity_Index
   ,  p_table_name		=>  G_Table_Name
   );

END Add_Error_Message;

-- -----------------------------------------------------------------------------
--  API Name:		Add_Error_Text
-- -----------------------------------------------------------------------------

PROCEDURE Add_Error_Text
(
   p_Entity_Index		IN      NUMBER
,  p_Message_Text		IN      VARCHAR2
)
IS
BEGIN

   Error_Handler.Add_Error_Message
   (
      p_message_text		=>  p_Message_Text
   ,  p_message_type		=>  'E'
   ,  p_row_identifier		=>  G_Transaction_Id
   ,  p_entity_id		=>  NULL
   ,  p_entity_code		=>  G_Entity_Code
   ,  p_entity_index		=>  p_Entity_Index
   ,  p_table_name		=>  G_Table_Name
   );

END Add_Error_Text;


END EGO_Item_Msg;

/
