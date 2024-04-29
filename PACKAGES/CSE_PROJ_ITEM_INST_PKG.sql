--------------------------------------------------------
--  DDL for Package CSE_PROJ_ITEM_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_PROJ_ITEM_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEITINS.pls 115.10 2003/09/22 16:05:37 stutika ship $ */

SUBTYPE  proj_item_inst_Attr_Rec_Type IS
         CSE_DATASTRUCTURES_PUB.PROJ_ITEM_INST_ATTR_REC_TYPE;
SUBTYPE  proj_item_inst_Attr_tbl_Type IS
         CSE_DATASTRUCTURES_PUB.PROJ_ITEM_INST_ATTR_tbl_TYPE;

PROCEDURE Decode_Message(
   P_Msg_Header           IN         XNP_MESSAGE.Msg_Header_Rec_Type,
   P_Msg_Text             IN         VARCHAR2,
   X_proj_item_inst_Attr_Rec  OUT NOCOPY        proj_item_inst_Attr_Rec_Type,
   X_Return_Status        OUT NOCOPY VARCHAR2,
   X_Error_Message        OUT NOCOPY VARCHAR2);

PROCEDURE Update_Ib_Repository(
   P_proj_item_inst_Attr_Rec  IN  proj_item_inst_Attr_Rec_Type,
   X_Return_Status        OUT NOCOPY VARCHAR2,
   X_Error_Message        OUT NOCOPY VARCHAR2);

PROCEDURE Update_eib_instances(
   P_proj_item_inst_Attr_tbl  IN  proj_item_inst_Attr_tbl_Type,
   X_Return_Status        OUT NOCOPY VARCHAR2,
   X_Error_Message        OUT NOCOPY VARCHAR2);

end CSE_PROJ_ITEM_INST_PKG;

 

/
