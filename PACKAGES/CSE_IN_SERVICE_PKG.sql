--------------------------------------------------------
--  DDL for Package CSE_IN_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_IN_SERVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEINSVS.pls 120.0.12010000.1 2008/07/30 05:17:57 appldev ship $ */

SUBTYPE  In_Service_Attr_Rec_Type IS  CSE_DATASTRUCTURES_PUB.IN_SERVICE_ATTR_REC_TYPE;
SUBTYPE  In_Service_Attr_tbl_Type IS  CSE_DATASTRUCTURES_PUB.IN_SERVICE_ATTR_tbl_TYPE;

PROCEDURE Decode_Message(
   P_Msg_Header             IN         XNP_MESSAGE.Msg_Header_Rec_Type,
   P_Msg_Text               IN         VARCHAR2,
   X_In_Service_Attr_Rec   OUT NOCOPY In_Service_Attr_Rec_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2);

PROCEDURE Update_Ib_Repository(
   P_In_Service_Attr_Rec   IN  In_Service_Attr_Rec_Type,
   X_Return_Status          OUT NOCOPY VARCHAR2,
   X_Error_Message          OUT NOCOPY VARCHAR2);

PROCEDURE update_eib_instances(
   P_In_Service_Attr_tbl   IN  In_Service_Attr_tbl_Type,
   X_Return_Status         OUT NOCOPY VARCHAR2,
   X_Error_Message         OUT NOCOPY VARCHAR2);
end CSE_IN_SERVICE_PKG ;

/
