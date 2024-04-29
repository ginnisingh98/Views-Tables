--------------------------------------------------------
--  DDL for Package OE_SALES_CAN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SALES_CAN_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUCANS.pls 120.0.12010000.2 2008/11/19 10:30:48 vbkapoor ship $ */

--  Start of Comments
--  API name    OE_SALES_CAN_UTIL
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_SALES_CAN_UTIL';
G_LINE_REC         OE_ORDER_PUB.Line_Rec_Type;
G_REQUIRE_REASON  BOOLEAN := FALSE;
G_ORDER_CANCEL    BOOLEAN := FALSE;

/* 7576948: IR ISO Change Management project Start */

-- This global is added to check the header level cancellation
-- in IR ISO change management project. If this global is TRUE
-- then no line level IR ISO OE_GLOBALS.G_UPDATE_REQUISITION
-- delayed request will be logged for Schedule Ship Date change.
-- However, for ordered quantity change, if this global is TRUE,
-- delayed request will be logged but just to track the count of
-- lines cancelled under that header, which will be useful to
-- determine the total count of lines cancellaed for partial
-- order cancellation case.
G_IR_ISO_HDR_CANCEL BOOLEAN := FALSE;

-- Since with IR ISO change management project, it is feasible
-- that if requisition header is cancelled, which is partially
-- shipped/received, corresponding internal sales order will
-- also be triggered for partial cancellation. If that is true
-- then for existing shipped but unfulfilled lines, which are
-- part of fulfillment set and waiting for fulfillment, may get
-- stuck, being existsing open line get cancelled from this
-- partial order cancellation flow. Thus, so as to push those
-- lines for fulfillment, we need to trigger their Fulfill-Line
-- workflow activity, which happens via below procdure. Earlier
-- this procedure was limited with usage in the current package
-- only, but with IR ISO CMS project, it is needed to be called
-- from  OE_Internal_Requisition_Pvt.Process_Line_Entity. So
-- now exposing it publically.
PROCEDURE Call_Process_Fulfillment(p_header_id IN NUMBER);

-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM-GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc

/* IR ISO Change Management project End */

PROCEDURE check_constraints
(   p_x_line_rec                  IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE check_constraints
(   p_header_rec                      IN  OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                  IN  OE_Order_PUB.header_Rec_Type:=
                                        OE_Order_PUB.G_MISS_header_REC
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE update_service
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
, x_return_status OUT NOCOPY VARCHAR2

);


FUNCTION Cal_Cancelled_Qty (
   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
)Return Number;

FUNCTION Cal_Cancelled_Qty2 (     -- INVCONV
   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
)Return Number;


PROCEDURE perform_line_change
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
, x_return_status OUT NOCOPY varchar2

);

PROCEDURE perform_cancel_order
(   p_header_rec                      IN  OE_Order_PUB.header_Rec_Type
,   p_old_header_rec                  IN  OE_Order_PUB.header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_header_REC
, x_return_status OUT NOCOPY varchar2

);

PROCEDURE Cancel_Remaining_Order
(   p_Header_Rec                   IN  OE_Order_PUB.Header_Rec_Type
				:= OE_Order_PUB.G_MISS_header_REC,
    p_header_id                 IN NUMBER := FND_API.G_MISS_NUM
, x_return_status OUT NOCOPY varchar2

);


FUNCTION Query_Rows
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Order_PUB.Line_Tbl_Type;

PROCEDURE Cancel_Wf
(
x_return_status OUT NOCOPY varchar2
, x_request_rec      IN OUT NOCOPY OE_Order_PUB.Request_Rec_Type
);

END OE_SALES_CAN_UTIL;

/
