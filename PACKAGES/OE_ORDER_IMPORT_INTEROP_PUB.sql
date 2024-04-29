--------------------------------------------------------
--  DDL for Package OE_ORDER_IMPORT_INTEROP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_IMPORT_INTEROP_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPIMIS.pls 120.0.12010000.1 2008/07/25 07:53:04 appldev ship $ */

--  Start of Comments
--  API name    OE_ORDER_IMPORT_INTEROP_PUB
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME         VARCHAR2(30) := 'OE_ORDER_IMPORT_INTEROP_PUB';

--  Line_Id record type
TYPE LineId_Rec_Type IS RECORD
(   line_id            NUMBER
);

TYPE LineId_Tbl_Type IS TABLE OF LineId_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Header_Id record type
TYPE HeaderId_Rec_Type IS RECORD
(   header_id            NUMBER
);

TYPE HeaderId_Tbl_Type IS TABLE OF HeaderId_Rec_Type
    INDEX BY BINARY_INTEGER;

/* ------------------------------------------------------------------
   Function: Get_Open_Qty
   ------------------------------------------------------------------
   This accepts order source id, original system document reference and
   original system line reference and returns the total open quantity.
   ------------------------------------------------------------------
*/
FUNCTION Get_Open_Qty (
   p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref    	IN  VARCHAR2
  ,p_orig_sys_line_ref    	IN  VARCHAR2
)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(Get_Open_Qty, WNDS,WNPS);


/* ------------------------------------------------------------------
   Function: Get_Shipped_Qty
   ------------------------------------------------------------------
   This accepts order source id, original system document reference and
   original system line reference and returns the total shipped quantity.
   ------------------------------------------------------------------
*/
FUNCTION Get_Shipped_Qty (
   p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref    	IN  VARCHAR2
  ,p_orig_sys_line_ref    	IN  VARCHAR2
)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(Get_Shipped_Qty, WNDS,WNPS);


/* ------------------------------------------------------------------
   Function: Get_Cancelled_Qty
   ------------------------------------------------------------------
   This accepts order source id, original system document reference and
   original system line reference and returns the total cancelled quantity.
   ------------------------------------------------------------------
*/
FUNCTION Get_Cancelled_Qty (
   p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref    	IN  VARCHAR2
  ,p_orig_sys_line_ref    	IN  VARCHAR2
)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(Get_Cancelled_Qty, WNDS,WNPS);


/* ------------------------------------------------------------------
   Function: Get_Order_Number
   ------------------------------------------------------------------
   This accepts Order Source Id, Original System Reference and
   Original System Line Reference and returns the corresponding
   Order Number.
   ------------------------------------------------------------------
*/
FUNCTION Get_Order_Number (
   p_order_source_id   		IN  NUMBER
  ,p_orig_sys_document_ref   	IN  VARCHAR2
  ,p_orig_sys_line_ref   	IN  VARCHAR2
)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(Get_Order_Number, WNDS,WNPS);


/* ------------------------------------------------------------------
   Function: Get_Header_Id
   ------------------------------------------------------------------
   This accepts a Requisition Header Id and returns the corresponding
   Order Header Id.

   p_type='S' will get it from so_headers/oe_order_headers table and
         ='D' will get it from so_drop_ship_sources/oe_drop_ship_sources
   ------------------------------------------------------------------
*/
FUNCTION Get_Header_Id (
   p_order_source_id   		IN  NUMBER
  ,p_orig_sys_document_ref   	IN  VARCHAR2
  ,p_requisition_header_id      IN  NUMBER
  ,p_type			IN  VARCHAR2
  ,p_requisition_line_id        IN  NUMBER DEFAULT NULL
)
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(Get_Header_Id, WNDS,WNPS);


/* ------------------------------------------------------------------
   Function: Get_Req_Header_Id
   ------------------------------------------------------------------
   This accepts a Order Header Id and returns the corresponding
   Requisition Header Id.

   p_type='S' will get it from so_headers/oe_order_headers table and
         ='D' will get it from so_drop_ship_sources/oe_drop_ship_sources
   ------------------------------------------------------------------
*/
FUNCTION Get_Req_Header_Id (
   p_header_id   		IN  NUMBER
  ,p_type			IN  VARCHAR2
)
RETURN NUMBER;

--PRAGMA RESTRICT_REFERENCES(Get_Req_Header_Id, WNDS,WNPS);

PROCEDURE Get_Line_Id (
   p_order_source_id            IN  NUMBER  := 10
  ,p_orig_sys_document_ref      IN  VARCHAR2
  ,p_requisition_header_id      IN  NUMBER
  ,p_line_num                   IN  VARCHAR2 := NULL
  ,p_requisition_line_id        IN  NUMBER
  ,x_line_id_tbl               OUT NOCOPY /* file.sql.39 change */  LineId_Tbl_Type
  ,x_return_status             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


/*Bug2770121*/
/* ------------------------------------------------------------------
   Procedure: Get_Requisition_Header_Ids
   ------------------------------------------------------------------
   This accepts a Order Header Id and returns the corresponding
   Requisition Header Ids associated with the drop ship header_id
   ------------------------------------------------------------------
*/

Procedure Get_Requisition_Header_Ids (
   p_header_id                  IN  NUMBER
  ,x_req_header_id_tbl          OUT NOCOPY /* file.sql.39 change */  HeaderId_Tbl_Type
);

END OE_ORDER_IMPORT_INTEROP_PUB;

/
