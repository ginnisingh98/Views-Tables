--------------------------------------------------------
--  DDL for Package OE_PROCESS_REQUISITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PROCESS_REQUISITION_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVPIRS.pls 120.0.12010000.3 2012/09/14 08:06:06 rahujain noship $ */

TYPE Line_id_tbl is TABLE OF NUMBER;

PROCEDURE SET_ORG_CONTEXT -- Specification details
( p_org_id   IN   NUMBER
);

Procedure Update_Internal_Requisition -- Specification definition
(  P_Header_id              IN  NUMBER
,  P_Line_id                IN  NUMBER
,  P_Line_ids               IN  VARCHAR2
,  p_num_records            IN  NUMBER
,  P_Req_Header_id          IN  NUMBER
,  P_Req_Line_id            IN  NUMBER DEFAULT NULL
,  P_Quantity_Change        IN  NUMBER DEFAULT NULL
,  P_Quantity2_Change       IN  NUMBER DEFAULT NULL --Bug 14211120
,  P_New_Schedule_Ship_Date IN  DATE DEFAULT NULL
,  P_Cancel_Order           IN  BOOLEAN
,  P_Cancel_Line            IN  BOOLEAN
,  X_msg_count              OUT NOCOPY NUMBER
,  X_msg_data               OUT NOCOPY VARCHAR2
,  X_return_status	    OUT NOCOPY VARCHAR2
);

Procedure Prepare_Notification -- Specification
( p_header_id     IN NUMBER
, p_Line_Id_tbl   IN Line_id_tbl DEFAULT NULL
, p_performer     IN VARCHAR2
, p_cancel_order  IN BOOLEAN
, p_notify_for    IN VARCHAR2
, p_req_header_id IN NUMBER
, p_req_line_id   IN NUMBER DEFAULT NULL
, x_return_status OUT NOCOPY VARCHAR2
);

END OE_PROCESS_REQUISITION_PVT;

/
