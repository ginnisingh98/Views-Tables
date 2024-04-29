--------------------------------------------------------
--  DDL for Package CSE_OUT_OF_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_OUT_OF_SERVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEOUTSS.pls 115.9 2003/09/22 15:39:01 stutika ship $ */

SUBTYPE  Out_Of_Service_Attr_Rec_Type IS
         CSE_DATASTRUCTURES_PUB.Out_Of_Service_ATTR_REC_TYPE;
SUBTYPE  Out_Of_Service_Attr_tbl_Type IS
         CSE_DATASTRUCTURES_PUB.Out_Of_Service_ATTR_tbl_TYPE;

PROCEDURE Decode_Message(
   P_Msg_Header             IN         XNP_MESSAGE.Msg_Header_Rec_Type,
   P_Msg_Text               IN         VARCHAR2,
   X_Out_Of_Service_Attr_Rec  OUT NOCOPY Out_Of_Service_Attr_Rec_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2);

PROCEDURE Update_Ib_Repository(
   P_Out_Of_Service_Attr_Rec  IN  Out_Of_Service_Attr_Rec_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2);

PROCEDURE Update_eib_instances(
   P_Out_Of_Service_Attr_tbl  IN  Out_Of_Service_Attr_tbl_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2);
end CSE_OUT_OF_SERVICE_PKG ;

 

/
