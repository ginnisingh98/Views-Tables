--------------------------------------------------------
--  DDL for Package CSE_ITEM_MOVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_ITEM_MOVE_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEITMVS.pls 120.0.12010000.1 2008/07/30 05:18:07 appldev ship $ */
SUBTYPE  Item_Move_Attr_Rec_Type IS
         CSE_DATASTRUCTURES_PUB.Item_Move_Attr_Rec_TYPE;
SUBTYPE  Item_Move_Attr_tbl_Type IS
         CSE_DATASTRUCTURES_PUB.Item_Move_Attr_tbl_TYPE;

PROCEDURE Decode_Message(
   P_Msg_Header             IN         XNP_MESSAGE.Msg_Header_Rec_Type,
   P_Msg_Text               IN         VARCHAR2,
   X_Item_Move_Attr_Rec  OUT NOCOPY Item_Move_Attr_Rec_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2);

PROCEDURE Update_Ib_Repository(
   P_Item_Move_Attr_Rec  IN  Item_Move_Attr_Rec_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2);

PROCEDURE Update_eib_instances(
   P_Item_Move_Attr_tbl  IN  Item_Move_Attr_tbl_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2);
end CSE_ITEM_MOVE_PKG ;

/
