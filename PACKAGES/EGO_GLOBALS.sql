--------------------------------------------------------
--  DDL for Package EGO_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: EGOSGLBS.pls 120.1 2005/06/29 00:13:03 lkapoor noship $ */
/**************************************************************************
--
--  FILENAME
--
--      EGOSGLBS.pls
--
--  DESCRIPTION
--
--      Spec of package EGO_Globals
--
--  NOTES
--
--  HISTORY
--
-- 19-SEP-2002	Rahul Chitko	Initial Creation
--
****************************************************************************/
	G_OPR_CREATE        CONSTANT    VARCHAR2(30) := 'CREATE';
	G_OPR_UPDATE        CONSTANT    VARCHAR2(30) := 'UPDATE';
	G_OPR_DELETE        CONSTANT    VARCHAR2(30) := 'DELETE';
	G_OPR_LOCK          CONSTANT    VARCHAR2(30) := 'LOCK';
	G_OPR_NONE          CONSTANT    VARCHAR2(30) := NULL;
	G_OPR_CANCEL        CONSTANT    VARCHAR2(30) := 'CANCEL';
	G_RECORD_FOUND      CONSTANT    VARCHAR2(1)  := 'F';
	G_RECORD_NOT_FOUND  CONSTANT    VARCHAR2(1)  := 'N';
	G_ITEM_BO	    CONSTANT	VARCHAR2(3)  := 'ITM';
	G_ITEM_CATALOG_BO   CONSTANT	VARCHAR2(3)  := 'CAT';

	--
	-- Entity Id
	--

	G_ITEM_CATALOG_GROUP		CONSTANT VARCHAR2(30) := 'ITEM_CATALOG_GROUP';
	G_ITEM_CATALOG_GROUP_LEVEL	CONSTANT NUMBER := 1;

	--
	-- central objects which will hold the data at all for the other procedures
	-- that need the business object.
	--
	G_CATALOG_GROUP_TBL  EGO_ITEM_CATALOG_PUB.Catalog_Group_Tbl_Type;
	G_CATALOG_GROUP_REC  EGO_ITEM_CATALOG_PUB.Catalog_Group_Rec_Type;
	G_OLD_CATALOG_GROUP_REC  EGO_ITEM_CATALOG_PUB.Catalog_Group_Rec_Type;

	--
	-- Global definition of the exceptions used by the business object processes
	--
	G_EXC_SEV_QUIT_OBJECT     EXCEPTION;
	G_EXC_UNEXP_SKIP_OBJECT   EXCEPTION;
	G_EXC_QUIT_IMPORT         EXCEPTION;
	G_EXC_SEV_QUIT_RECORD     EXCEPTION;
	G_EXC_SEV_QUIT_BRANCH     EXCEPTION;
	G_EXC_SEV_SKIP_BRANCH     EXCEPTION;
	G_EXC_FAT_QUIT_OBJECT     EXCEPTION;
	G_EXC_SEV_QUIT_SIBLINGS   EXCEPTION;
	G_EXC_FAT_QUIT_SIBLINGS   EXCEPTION;
	G_EXC_FAT_QUIT_BRANCH     EXCEPTION;


	TYPE SYSTEM_INFORMATION_REC_TYPE IS RECORD
	(  Entity               VARCHAR2(30)    := NULL
	 , org_id               NUMBER          := NULL
	 , User_Id              NUMBER          := NULL
	 , BO_Identifier        VARCHAR2(3)     := 'CAT'
	 , debug_flag		VARCHAR2(1)	:= 'N'
	 , language_code	VARCHAR2(4)	:= 'US'
	 , calling_mode		VARCHAR2(240)   := 'JSP'
	);

	G_System_Information SYSTEM_INFORMATION_REC_TYPE;

	PROCEDURE Set_Language_Code(p_language_code VARCHAR2);
	FUNCTION Get_Language_Code RETURN VARCHAR2;

	PROCEDURE Set_User_Id
          ( p_user_id   IN  NUMBER);
	FUNCTION Get_User_ID RETURN NUMBER;
	PRAGMA RESTRICT_REFERENCES(Get_User_Id, WNDS);
	FUNCTION Get_BO_Identifier RETURN VARCHAR2;

	PROCEDURE Transaction_Type_Validity
	(   p_transaction_type          IN  VARCHAR2
	,   p_entity                    IN  VARCHAR2
	,   p_entity_id                 IN  VARCHAR2
	,   x_valid                     OUT NOCOPY BOOLEAN
	,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	);

END EGO_Globals;

 

/
