--------------------------------------------------------
--  DDL for Package EGO_ITEM_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_MSG" AUTHID CURRENT_USER AS
/* $Header: EGOMITMS.pls 115.0 2002/12/12 15:45:20 anakas noship $ */

G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOMITMS.pls';

-- =============================================================================
--                          Global variables and cursors
-- =============================================================================

G_RET_STS_SUCCESS	CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR		CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR	CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'

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
);

-- -----------------------------------------------------------------------------
--  API Name:		Add_Error_Text
-- -----------------------------------------------------------------------------

PROCEDURE Add_Error_Text
(
   p_Entity_Index		IN      NUMBER
,  p_Message_Text		IN      VARCHAR2
);


END EGO_Item_Msg;

 

/
