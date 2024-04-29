--------------------------------------------------------
--  DDL for Package OE_DROP_SHIP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DROP_SHIP_GRP" AUTHID CURRENT_USER As
/* $Header: OEXUDSHS.pls 120.0.12000000.1 2007/01/16 22:02:22 appldev ship $ */

Procedure Update_Req_Info(P_API_Version              In  Number,
P_Return_Status out nocopy Varchar2,

P_Msg_Count out nocopy Number,

P_MSG_Data out nocopy Varchar2,

                          P_Interface_Source_Code    In  Varchar2,
                          P_Interface_Source_Line_ID In  Number,
                          P_Requisition_Header_ID    In  Number,
                          P_Requisition_Line_ID      In  Number);

Procedure Insert_OE_Drop_Ship_Sources
( P_Drop_Ship_Source_ID         In Number
, P_Header_ID                   In Number
, P_Line_ID                     In Number
, P_Org_ID                      In Number
, P_Destination_Organization_ID In Number
, P_Requisition_Header_ID       In Number
, P_Requisition_Line_ID         In Number
, P_PO_Header_ID                In Number
, P_PO_Line_ID                  In Number
, P_Line_Location_ID            In Number
, P_PO_Release_ID               In Number Default Null);

-- Update_All_Reqs_In_Process is an OE procedure that is called by
-- Oracle Purchasing to update requisition information for a drop shipped line.
-- This procedure is called in the Requisition Import (ReqImport) process of
-- Oracle Purchasing.

Procedure Update_All_Reqs_In_Process
( P_API_Version              In  Number
, P_Return_Status out nocopy Varchar2

, P_Msg_Count out nocopy Number

, P_MSG_Data out nocopy Varchar2

, P_Requisition_Header_ID    In Number
, P_Request_Id               In Number
, P_Process_Flag             In Varchar2);

-- Update_PO_Info is an OE procedure that is called by Oracle Purchasing to
-- update purchase order information for a drop shipped line. This procedure
-- is called in the Auto create process of Oracle Purchasing

Procedure Update_PO_Info
( P_API_Version          In  Number
, P_Return_Status out nocopy Varchar2

, P_Msg_Count out nocopy Number

, P_MSG_Data out nocopy Varchar2

, P_Req_Header_ID        In  Number
, P_Req_Line_ID          In  Number
, P_PO_Header_Id         In  Number
, P_PO_Line_Id           In  Number
, P_Line_Location_ID     In  Number
, P_PO_Release_ID        In  Number Default Null);

Function Valid_Drop_Ship_Source_ID
(P_Drop_Ship_Source_ID In Number)
Return Boolean;

Function Req_Line_Is_Drop_Ship
(P_Req_Line_Id              In  Number)
Return Number;

Function PO_Line_Location_Is_Drop_Ship
(P_PO_Line_Location_Id In  Number)
Return Number;

--PO will pass in the data po_header_id or po_requisition_header_id

TYPE PO_ENTITY_ID_TBL_TYPE IS TABLE OF NUMBER;

--Validation outcome for each document that is passed

TYPE VAL_STATUS_TBL_TYPE IS TABLE OF VARCHAR2(1);

Procedure Update_Drop_Ship_Links
( p_api_version	         IN	        NUMBER
 ,p_po_header_id 	 IN	        NUMBER
 ,p_po_line_id        	 IN	        NUMBER
 ,p_po_line_location_id	 IN	        NUMBER
 ,p_po_release_id	 IN	        NUMBER
 ,p_new_req_hdr_id	 IN	        NUMBER
 ,p_new_req_line_id	 IN 	        NUMBER
 ,x_msg_data	         OUT NOCOPY	VARCHAR2
 ,x_msg_count	         OUT NOCOPY	NUMBER
 ,x_return_status	 OUT NOCOPY	VARCHAR2
);

Function Is_Receipt_For_Drop_Ship
( p_rcv_transaction_id     IN             NUMBER
)RETURN BOOLEAN;

Procedure Get_Drop_Ship_Line_ids
( p_po_header_id        IN              NUMBER
, p_po_line_id          IN              NUMBER
, p_po_line_location_id IN              NUMBER
, p_po_release_id       IN              NUMBER
, p_mode           	IN	        NUMBER := null
, p_rcv_transaction_id  IN              NUMBER := null
, x_num_lines           OUT NOCOPY /* file.sql.39 change */             NUMBER
, x_line_id             OUT     NOCOPY  NUMBER
, x_header_id           OUT     NOCOPY  NUMBER
, x_org_id              OUT     NOCOPY  NUMBER
);

Procedure Get_Order_Line_Status
(p_api_version	        IN	        NUMBER
,p_po_header_id	        IN	        NUMBER
,p_po_line_id	        IN	        NUMBER
,p_po_line_location_id	IN	        NUMBER
,p_po_release_id     	IN	        NUMBER
,p_mode           	IN	        NUMBER
,x_updatable_flag	OUT     NOCOPY	VARCHAR2
,x_on_hold	        OUT     NOCOPY	VARCHAR2
,x_order_line_status	OUT     NOCOPY	NUMBER
,x_msg_data       	OUT     NOCOPY	VARCHAR2
,x_msg_count       	OUT     NOCOPY	NUMBER
,x_return_status	OUT     NOCOPY	VARCHAR2
);

Procedure Purge_Drop_Ship_PO_Links
( p_api_version          IN             NUMBER
 ,p_init_msg_list        IN             VARCHAR2
 ,p_commit               IN             VARCHAR2
 ,p_entity               IN             VARCHAR2
 ,p_entity_id_tbl        IN             PO_ENTITY_ID_TBL_TYPE
 ,x_msg_count            OUT    NOCOPY  NUMBER
 ,x_msg_data             OUT    NOCOPY  VARCHAR2
 ,x_return_status        OUT    NOCOPY  VARCHAR2
);

Procedure Purge_Drop_Ship_PO_Validation
( p_api_version          IN             NUMBER
 ,p_init_msg_list        IN             VARCHAR2
 ,p_commit               IN             VARCHAR2
 ,p_entity               IN             VARCHAR2
 ,p_entity_id_tbl        IN             PO_ENTITY_ID_TBL_TYPE
 ,x_purge_allowed_tbl    OUT    NOCOPY  VAL_STATUS_TBL_TYPE
 ,x_msg_count            OUT    NOCOPY  NUMBER
 ,x_msg_data             OUT    NOCOPY  VARCHAR2
 ,x_return_status        OUT    NOCOPY  VARCHAR2
);

TYPE Order_Line_Info_Rec_Type IS RECORD
( ship_to_contact_name           VARCHAR2(400)
 ,ship_to_contact_phone          VARCHAR2(200)
 ,ship_to_contact_fax            VARCHAR2(200)
 ,ship_to_contact_email          VARCHAR2(2000)
 ,deliver_to_customer_name       VARCHAR2(400)
 ,deliver_to_customer_address    VARCHAR2(2000)
 ,deliver_to_customer_Location   VARCHAR2(2000)
 ,deliver_to_contact_name        VARCHAR2(400)
 ,deliver_to_contact_phone       VARCHAR2(200)
 ,deliver_to_contact_fax         VARCHAR2(200)
 ,deliver_to_contact_email       VARCHAR2(2000)
 ,shipping_method                VARCHAR2(240)
 ,shipping_instructions          VARCHAR2(2000)
 ,packing_instructions           VARCHAR2(2000)
 ,customer_product_description   VARCHAR2(1000)
 ,customer_po_number             VARCHAR2(50)
 ,customer_po_line_number        VARCHAR2(50)
 ,customer_po_shipment_number    VARCHAR2(50)
 ,ship_to_customer_name          VARCHAR2(400)
 ,ship_to_customer_location      VARCHAR2(2000)
 ,sales_order_number             VARCHAR2(240)
 ,sales_order_line_number        VARCHAR2(30)
 ,sales_order_line_ordered_qty   NUMBER
 ,sales_order_line_shipped_qty   NUMBER
 ,sales_order_line_ordered_qty2   NUMBER -- INVCONV
 ,sales_order_line_shipped_qty2   NUMBER -- INVCONV
 ,sales_order_line_status        VARCHAR2(240)
 ,deliver_to_customer_address1   VARCHAR2(240)
 ,deliver_to_customer_address2   VARCHAR2(240)
 ,deliver_to_customer_address3   VARCHAR2(240)
 ,deliver_to_customer_address4   VARCHAR2(240)
 ,deliver_to_customer_city       VARCHAR2(60)
 ,deliver_to_customer_state      VARCHAR2(60)
 ,deliver_to_customer_zip        VARCHAR2(60)
 ,deliver_to_customer_country    VARCHAR2(60)
);


PROCEDURE Get_Order_Line_Info
( p_api_version          IN  NUMBER
 ,p_po_header_id         IN  NUMBER
 ,p_po_line_id           IN  NUMBER
 ,p_po_line_location_id  IN  NUMBER
 ,p_po_release_id        IN  NUMBER
 ,p_mode                 IN  NUMBER
 ,x_order_line_info_rec  OUT NOCOPY  Order_Line_Info_Rec_Type
 ,x_msg_data             OUT NOCOPY  VARCHAR2
 ,x_msg_count            OUT NOCOPY  NUMBER
 ,x_return_status        OUT NOCOPY  VARCHAR2);

End OE_DROP_SHIP_GRP;

 

/
