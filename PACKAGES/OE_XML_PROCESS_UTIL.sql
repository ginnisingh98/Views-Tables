--------------------------------------------------------
--  DDL for Package OE_XML_PROCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_XML_PROCESS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUPOXS.pls 120.1 2005/07/19 11:07:01 jjmcfarl noship $ */

G_PKG_NAME           VARCHAR2(30)           := 'OE_XML_PROCESS_UTIL';

-- This function will concatenate two given strings
Procedure Concat_Strings(
          String1       IN      VARCHAR2,
          String2       IN      VARCHAR2,
OUT_String OUT NOCOPY VARCHAR2

          );

-- This function will get the site id(SHIP_TO)
Procedure Get_Ship_To_Org_Id(
          p_address_id       IN      NUMBER,
x_ship_to_org_id OUT NOCOPY NUMBER

          );

-- This function will get the site id(BILL_TO)
Procedure Get_Bill_To_Org_Id(
          p_address_id       IN      NUMBER,
x_bill_to_org_id OUT NOCOPY NUMBER

          );

-- This function will get the Customer Id
Procedure Get_Sold_To_Org_Id(
          p_address_id       IN      NUMBER,
x_sold_to_org_id OUT NOCOPY NUMBER

          );

Procedure Get_Sold_To_Edi_Loc(
          p_sold_to_org_id      IN      Number,
x_edi_location_code OUT NOCOPY Varchar2,

x_sold_to_name OUT NOCOPY Varchar2

          );

Procedure Get_Ship_From_Edi_Loc(
          p_ship_from_org_id    IN      Number,
x_edi_location_code OUT NOCOPY Varchar2

          );

-- This function will get the Total of the Order or specific Line
Procedure Get_Order_Total(
          p_header_id        IN      NUMBER,
          p_line_id          IN      NUMBER,
          p_total_type       IN      VARCHAR2 DEFAULT 'ALL',
x_order_line_total OUT NOCOPY NUMBER

          );

PROCEDURE Get_Processing_Msgs
( p_request_id             in     varchar2,
  p_order_source_id        in     number      := 20,
  p_orig_sys_document_ref  in     varchar2    := NULL,
  p_orig_sys_line_ref      in     varchar2    := NULL,
  p_ack_code               in     varchar2    := '0',
  p_org_id                 in     number      := null,
x_error_text out nocopy varchar2,

x_result out nocopy varchar2

);

Procedure Get_Sales_Person
(
 p_salesrep_id        IN    Number,
x_salesrep OUT NOCOPY Varchar2

);

Procedure Get_Line_Ordered_Quantity
(
	 p_orig_sys_document_ref	IN	VARCHAR2,
	 p_orig_sys_line_ref		IN	VARCHAR2,
	 p_orig_sys_shipment_ref	IN	VARCHAR2,
	 p_order_source_id		IN 	NUMBER,
         p_sold_to_org_id               IN      NUMBER  := NULL,
x_ordered_quantity OUT NOCOPY NUMBER

	 );

Procedure Get_Line_Ordered_Quantity_UOM
(
	 p_orig_sys_document_ref	IN	VARCHAR2,
	 p_orig_sys_line_ref		IN	VARCHAR2,
	 p_orig_sys_shipment_ref	IN	VARCHAR2,
	 p_order_source_id		IN 	NUMBER,
         p_sold_to_org_id               IN      NUMBER  := NULL,
x_ordered_quantity_uom OUT NOCOPY VARCHAR2

	 );

PROCEDURE Set_Cancelled_Flag
(
 p_orig_sys_document_ref 	in varchar2,
 p_transaction_type             in varchar2,
 p_order_source_id              in number,
 p_sold_to_org_id               in number  := null,
 p_change_sequence              in varchar2 := null,
 p_org_id                       in number,
 p_xml_message_id               in number
);

PROCEDURE Clear_Oe_Header_And_Line_Acks
(p_orig_sys_document_ref        in varchar2,
 p_ack_type                     in varchar2,
 p_sold_to_org_id               in number    := NULL,
 p_change_sequence              in varchar2  := NULL,
 p_request_id                   in number    := NULL
);

Procedure Derive_Line_Operation_Code
( p_orig_sys_document_ref in varchar2,
  p_orig_sys_line_ref     in varchar2,
  p_orig_sys_shipment_ref in varchar2,
  p_order_source_id       in number,
  p_sold_to_org_id        in number   := NULL,
  p_org_id                in number,
  x_operation_code        OUT NOCOPY varchar2
);

Procedure get_address_details
 (p_site_use_id        In          Number,
  p_site_use_code      In          Varchar2,
  x_location           Out NOCOPY  Varchar2,
  x_address1           Out NOCOPY  Varchar2,
  x_address2           Out NOCOPY  Varchar2,
  x_address3           Out NOCOPY  Varchar2,
  x_address4           Out NOCOPY  Varchar2,
  x_city               Out NOCOPY  Varchar2,
  x_state              Out NOCOPY  Varchar2,
  x_country            Out NOCOPY  Varchar2,
  x_postal_code        Out NOCOPY  Varchar2,
  x_edi_location_code  Out NOCOPY  varchar2,
  x_customer_name      Out NOCOPY  Varchar2,
  x_return_status      Out NOCOPY  Varchar2
 );

Procedure Get_Contact_Details
 (p_contact_id            In         Number,
  p_cust_acct_id          In         Number,
  x_first_name            Out NOCOPY Varchar2,
  x_last_name             Out NOCOPY Varchar2,
  x_return_status         Out NOCOPY Varchar2
 );

Procedure Check_Rejected_Level
 (p_header_ack_code       In         Varchar2,
  p_line_ack_code         In         Varchar2,
  p_shipment_ack_code     In         Varchar2,
  p_response_profile      In         Varchar2,
  p_ordered_quantity      In         Number,
  p_response_flag         In         Varchar2,
  p_level_code            In         Varchar2,
  x_insert_flag           Out Nocopy Varchar2);

Procedure Process_Response_Reject
  (p_header_ack_code         In           Varchar2,
   p_line_ack_code           In           Varchar2,
   p_shipment_ack_code       In           Varchar2,
   p_ordered_quantity        In           Number,
   p_response_flag           In           Varchar2,
   p_event_raised_flag       In           Varchar2,
   p_level_code              In           Varchar2,
   p_orig_sys_document_ref   In           Varchar2,
   p_change_sequence         In           Varchar2,
   p_org_id                  In           Varchar2,
   p_sold_to_org_id          In           Number,
   p_xml_message_id          In           Number,
   p_confirmation_flag       In           Varchar2 DEFAULT NULL,
   p_confirmation_message    In           Varchar2 DEFAULT NULL,
   x_insert_level            Out Nocopy   Varchar2,
   x_raised_event            Out Nocopy   Varchar2);


END OE_XML_PROCESS_UTIL;

 

/
