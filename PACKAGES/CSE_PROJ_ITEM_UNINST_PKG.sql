--------------------------------------------------------
--  DDL for Package CSE_PROJ_ITEM_UNINST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_PROJ_ITEM_UNINST_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEITUIS.pls 115.9 2003/09/22 16:06:45 stutika ship $ */

SUBTYPE  Proj_Item_Uninst_Attr_Rec_Type IS
         CSE_DATASTRUCTURES_PUB.Proj_Item_UNINST_ATTR_REC_TYPE;

SUBTYPE  Proj_Item_Uninst_Attr_tbl_Type IS
         CSE_DATASTRUCTURES_PUB.Proj_Item_UNINST_ATTR_tbl_TYPE;
PROCEDURE Decode_Message(
   P_Msg_Header            IN         XNP_MESSAGE.Msg_Header_Rec_Type,
   P_Msg_Text              IN         VARCHAR2,
   X_Proj_Item_Uninst_Attr_Rec OUT NOCOPY Proj_Item_Uninst_Attr_Rec_Type,
   X_Return_Status         OUT NOCOPY VARCHAR2,
   X_Error_Message         OUT NOCOPY VARCHAR2);

PROCEDURE Update_Ib_Repository(
   P_Proj_Item_Uninst_Attr_Rec IN         Proj_Item_Uninst_Attr_Rec_Type,
   X_Return_Status         OUT NOCOPY VARCHAR2,
   X_Error_Message         OUT NOCOPY VARCHAR2);

PROCEDURE Update_eib_instances(
   P_Proj_Item_Uninst_Attr_tbl IN  Proj_Item_Uninst_Attr_tbl_Type,
   X_Return_Status         OUT NOCOPY VARCHAR2,
   X_Error_Message         OUT NOCOPY VARCHAR2);
end CSE_PROJ_ITEM_UNINST_PKG ;

 

/
