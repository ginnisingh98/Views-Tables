--------------------------------------------------------
--  DDL for Package OKE_DTS_ACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DTS_ACTION_PKG" AUTHID CURRENT_USER As
/* $Header: OKEDACTS.pls 120.1 2006/05/11 14:16:41 ifilimon noship $ */
  Function Get_Org(P_Direction Varchar2
		, P_Ship_From_Org_Id Number
		, P_Ship_To_Org_Id Number) Return Number;

  Function Check_Operation_Allowed(P_Sts_Code Varchar2
			, P_Opn_Code Varchar2) Return Boolean;

  Function Check_Dependencies(P_Deliverable_Id Number) Return Boolean;
  Function Check_Item_Valid(P_Inventory_Org_Id Number
			, P_Item_Id Number) Return Boolean;

  Procedure Initiate_Actions(P_Action Varchar2
			, P_Action_Level Number  -- 1 Header, 2 Line, 3 Deliverable
			, P_Header_Id Number
			, P_Line_Id Number
			, P_Deliverable_Id Number
			, X_Return_Status OUT NOCOPY Varchar2
			, X_Msg_Data OUT NOCOPY Varchar2
			, X_Msg_Count OUT NOCOPY Number);

  PROCEDURE Initiate_Actions_CP( -- Initiate_Actions wrapper for Concurrent programs
        ERRBUF            OUT NOCOPY    VARCHAR2
      , RETCODE           OUT NOCOPY    NUMBER
      , P_Action          VARCHAR2
			, P_Action_Level    NUMBER  -- 1 Header, 2 Line, 3 Deliverable
			, P_Header_Id       NUMBER
			, P_Line_Id         NUMBER
			, P_Deliverable_Id  NUMBER
  );

End;


 

/
