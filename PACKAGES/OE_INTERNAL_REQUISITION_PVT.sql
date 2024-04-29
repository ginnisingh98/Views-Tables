--------------------------------------------------------
--  DDL for Package OE_INTERNAL_REQUISITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INTERNAL_REQUISITION_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVIRQS.pls 120.0.12010000.2 2014/08/18 05:47:04 rahujain noship $ */

TYPE Line_id_Rec_Type IS RECORD
( LINE_ID           OE_Order_Lines_All.LINE_ID%TYPE
, LINE_NUMBER       OE_Order_Lines_All.LINE_NUMBER%TYPE
, SHIPMENT_NUMBER   OE_Order_Lines_All.SHIPMENT_NUMBER%TYPE
, HEADER_ID         OE_Order_Lines_All.HEADER_ID%TYPE
, ORDERED_QUANTITY  OE_Order_Lines_All.ORDERED_QUANTITY%TYPE
, ORDERED_QUANTITY2 OE_Order_Lines_All.ORDERED_QUANTITY2%TYPE
, REQUEST_DATE      OE_Order_Lines_All.REQUEST_DATE%TYPE
, SCH_ARRIVAL_DATE  OE_Order_Lines_All.SCHEDULE_ARRIVAL_DATE%TYPE); --Bug 19273040

G_ORG_ID            OE_Order_Headers_All.ORG_ID%TYPE;
G_Update_ISO_From_Req BOOLEAN := FALSE;
-- Confirming IR initiated change.This global is created to mark that the change on
-- the order line is initiated by the requesting organization. Its value will be read
-- while logging delayed requests in OM system for the changes initiated by the
-- fulfillment organization user. In that case, no delayed request will be logged if
-- this global is set with value TRUE

Procedure Get_Eligible_ISO_Shipment  -- Specification definition
(  P_internal_req_line_id   IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  X_line_ids_rec	       OUT NOCOPY Line_Id_Rec_Type
,  X_return_status	       OUT NOCOPY VARCHAR2
);

Function Update_Allowed -- Specification definition
( P_line_id          IN NUMBER
, P_Attribute        IN VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN;

Function Cancel_Allowed -- Specification definition
( P_line_id IN NUMBER
) RETURN BOOLEAN;

Function Cancel_Header_Allowed -- Specification definition
( P_header_id IN NUMBER
) RETURN BOOLEAN;

PROCEDURE Process_Line_Entity  -- Specification definition
(p_line_tbl       IN OE_Order_PUB.Line_Tbl_Type
,P_mode           IN VARCHAR2
,P_Cancel         IN BOOLEAN
,x_return_status  OUT NOCOPY VARCHAR2
);

Procedure Apply_Hold_for_IReq  -- Specification definition
(  P_API_Version            IN  NUMBER
,  P_internal_req_line_id   IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  X_msg_count              OUT NOCOPY NUMBER
,  X_msg_data               OUT NOCOPY VARCHAR2
,  X_return_status	    OUT NOCOPY VARCHAR2
);

Procedure Release_Hold_for_IReq  -- Specification definition
(  P_API_Version            IN  NUMBER
,  P_internal_req_line_id   IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  X_msg_count              OUT NOCOPY NUMBER
,  X_msg_data               OUT NOCOPY VARCHAR2
,  X_return_status	    OUT NOCOPY VARCHAR2
);

Procedure Is_IReq_Changable -- Specification definition
(  P_API_Version            IN  NUMBER
,  P_internal_req_line_id   IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE DEFAULT NULL
,  P_internal_req_header_id IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE DEFAULT NULL
,  X_Update_Allowed         OUT NOCOPY BOOLEAN
,  X_Cancel_Allowed         OUT NOCOPY BOOLEAN
,  X_msg_count              OUT NOCOPY NUMBER
,  X_msg_data               OUT NOCOPY VARCHAR2
,  X_return_status	    OUT NOCOPY VARCHAR2
);

Procedure Call_Process_Order_for_IReq  -- Specification definition
(  P_API_Version             IN  NUMBER
,  P_internal_req_line_id    IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id  IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  P_Mode                    IN  VARCHAR2
,  P_Cancel_ISO              IN  BOOLEAN DEFAULT FALSE
,  P_Cancel_ISO_lines        IN  BOOLEAN DEFAULT FALSE
,  P_New_Request_Date        IN  DATE DEFAULT NULL
,  P_Delta_Ordered_Qty       IN  NUMBER DEFAULT 0
,  X_msg_count               OUT NOCOPY NUMBER
,  X_msg_data                OUT NOCOPY VARCHAR2
,  X_return_status	     OUT NOCOPY VARCHAR2
);

--Bug 19273040, overloaded procedure
Procedure Call_Process_Order_for_IReq  -- Specification definition
(  P_API_Version             IN  NUMBER
,  P_internal_req_line_id    IN PO_Requisition_Lines_All.Requisition_Line_id%TYPE
,  P_internal_req_header_id  IN PO_Requisition_Headers_All.Requisition_Header_id%TYPE
,  P_Mode                    IN  VARCHAR2
,  P_Cancel_ISO              IN  BOOLEAN DEFAULT FALSE
,  P_Cancel_ISO_lines        IN  BOOLEAN DEFAULT FALSE
,  P_New_Request_Date        IN  DATE DEFAULT NULL
,  P_Delta_Ordered_Qty       IN  NUMBER DEFAULT 0
,  X_msg_count               OUT NOCOPY NUMBER
,  X_msg_data                OUT NOCOPY VARCHAR2
,  X_return_status	         OUT NOCOPY VARCHAR2
,  X_New_Needby_Date         OUT NOCOPY DATE --Bug 19273040
);

END OE_INTERNAL_REQUISITION_PVT;

/
