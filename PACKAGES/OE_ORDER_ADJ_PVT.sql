--------------------------------------------------------
--  DDL for Package OE_ORDER_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_ADJ_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVADJS.pls 120.3.12010000.1 2008/07/25 07:58:09 appldev ship $ */

G_STMT_NO			Varchar2(2000);

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'oe_order_adj_pvt';
G_SEEDED_GSA_HOLD_ID          CONSTANT NUMBER := 2;
G_SEEDED_PROM_ORDER_HOLD_ID    CONSTANT NUMBER := 30;  -- PROMOTIONS SEP/01
G_SEEDED_PROM_LINE_HOLD_ID     CONSTANT NUMBER := 31;  -- PROMOTIONS SEP/01

--  Header_Adjs

--btea begin
--profile option value for rounding flag
G_ROUNDING_FLAG   VARCHAR2(1) :=nvl(Fnd_Profile.value('OE_UNIT_PRICE_ROUNDING'),'N');
--btea end

G_PASS_ALL_LINES	VARCHAR2(30) := NULL;

Type rounding_factor_rec is Record
(List_Header_id 		number
,rounding_factor	number
);

g_rounding_factor_rec 	rounding_factor_rec;

Type Index_Tbl_Type is table of number
	Index by Binary_Integer;

Type Char_Tbl_Type is table of Varchar2(5) Index by Binary_Integer;

G_MISS_INDEX_TBL	Index_Tbl_Type;

Type Sorted_Adjustment_rec_Type is Record
(Adj_index	Number
,Pricing_group_sequence	number
);

Type Sorted_Adjustment_Tbl_Type is table of Sorted_Adjustment_rec_Type
	Index by Binary_Integer;

PROCEDURE Header_Adjs
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Adj_tbl              IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_x_old_Header_Adj_tbl          IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Tbl_Type
);

PROCEDURE HEader_Price_Atts
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_HEader_Price_Att_tbl        IN OUT NOCOPY  OE_Order_PUB.HEader_Price_Att_Tbl_Type
,   p_x_old_HEader_Price_Att_tbl    IN OUT NOCOPY  OE_Order_PUB.HEader_Price_Att_Tbl_Type
);

PROCEDURE Header_Adj_Atts
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_x_old_Header_Adj_Att_tbl      IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Att_Tbl_Type
);

PROCEDURE Header_Adj_Assocs
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_x_old_Header_Adj_Assoc_tbl    IN OUT NOCOPY  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
);

PROCEDURE Line_Adjs
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Adj_tbl                IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_x_old_Line_Adj_tbl            IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Tbl_Type
);

PROCEDURE Line_Price_Atts
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_x_old_Line_Price_Att_tbl      IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Tbl_Type
);

PROCEDURE Line_Adj_Atts
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_x_old_Line_Adj_Att_tbl        IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Att_Tbl_Type
);

PROCEDURE Line_Adj_Assocs
(   p_init_msg_list                 IN VARCHAR2:=FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_x_old_Line_Adj_Assoc_tbl      IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
);

procedure calculate_adjustments(
x_return_status out nocopy varchar2,
p_line_id					number default null,
p_header_id				number Default null,
p_Request_Type_Code			varchar2 ,
p_Control_Rec				QP_PREQ_GRP.CONTROL_RECORD_TYPE,
x_req_line_tbl                out  nocopy QP_PREQ_GRP.LINE_TBL_TYPE,
x_Req_qual_tbl                out  nocopy QP_PREQ_GRP.QUAL_TBL_TYPE,
x_Req_line_attr_tbl           out  nocopy QP_PREQ_GRP.LINE_ATTR_TBL_TYPE,
x_Req_LINE_DETAIL_tbl         out  nocopy QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
x_Req_LINE_DETAIL_qual_tbl    out  nocopy QP_PREQ_GRP.LINE_DETAIL_QUAL_TBL_TYPE,
x_Req_LINE_DETAIL_attr_tbl    out  nocopy QP_PREQ_GRP.LINE_DETAIL_ATTR_TBL_TYPE,
x_Req_related_lines_tbl       out  nocopy QP_PREQ_GRP.RELATED_LINES_TBL_TYPE
,p_use_current_header         in   Boolean      Default FALSE
,p_write_to_db			Boolean 	Default TRUE
,x_any_frozen_line out nocopy Boolean
,x_Header_Rec out nocopy oe_Order_Pub.Header_REc_Type
,x_line_Tbl			   in out nocopy  oe_Order_Pub.Line_Tbl_Type
,p_honor_price_flag			VARCHAR2 Default 'Y'
,p_multiple_events            in VARCHAR2 Default 'N'
,p_action_code                in VARCHAR2 Default 'NONE'
);

procedure process_adjustments
(
p_request_type_code				varchar2,
x_return_status out nocopy Varchar2,
p_Req_Control_Rec			   QP_PREQ_GRP.Control_record_type,
p_req_line_tbl                   QP_PREQ_GRP.line_tbl_type,
p_Req_qual_tbl                   QP_PREQ_GRP.qual_tbl_type,
p_Req_line_attr_tbl              QP_PREQ_GRP.line_attr_tbl_type,
p_Req_Line_Detail_tbl            QP_PREQ_GRP.line_detail_tbl_type,
p_Req_Line_Detail_Qual_tbl       QP_PREQ_GRP.line_detail_qual_tbl_type,
p_Req_Line_Detail_Attr_tbl       QP_PREQ_GRP.line_detail_attr_tbl_type,
p_Req_related_lines_tbl          QP_PREQ_GRP.related_lines_tbl_type
,p_write_to_db					Boolean
,p_any_frozen_line              in Boolean
,x_line_Tbl			in out nocopy    oe_Order_Pub.Line_Tbl_Type
,p_header_rec				   oe_Order_Pub.header_rec_type
,p_multiple_events     in Varchar2 Default 'N'
,p_honor_price_flag    in Varchar2 Default 'Y'  --bug 2503186
);

Procedure Price_line(
X_Return_Status out nocopy Varchar2
		,p_Line_id          	Number	Default Null
		,p_Header_id        	Number	DEfault Null
		,p_Request_Type_code	Varchar2
		,p_Control_Rec			QP_PREQ_GRP.control_record_type
		,p_write_to_db			Boolean DEFAULT TRUE
		,p_request_rec          OE_Order_PUB.request_rec_type default oe_order_pub.G_MISS_REQUEST_REC
		,x_line_Tbl	in 	out nocopy  oe_Order_Pub.Line_Tbl_Type
		,p_honor_price_flag	VARCHAR2	Default 'Y'
		,p_multiple_events      Varchar2 default 'N'
                ,p_action_code          VARCHAR2 Default Null
                );

Procedure Price_Adjustments(
X_Return_Status out nocopy Varchar2
	,p_Header_id             Number    DEfault null
	,p_Line_id               Number    DEfault null
	,p_request_type_code	varchar2
	,p_request_rec          OE_Order_PUB.request_rec_type default oe_order_pub.G_MISS_REQUEST_REC

);

procedure price_action
		(
		 p_selected_records             Oe_Globals.Selected_Record_Tbl
		,P_price_level			varchar2
                ,p_header_id                    Number Default Null
,x_Return_Status out nocopy varchar2
,x_msg_count out nocopy number
,x_msg_data out nocopy varchar2
		);


/* For Backward Compatibility */
procedure price_action
                (p_HEader_count         Number
                ,p_HEader_list                  varchar2
                ,p_line_count                   number
                ,p_line_List                    Varchar2
                ,P_price_level                  varchar2
,x_Return_Status out nocopy varchar2
,x_msg_count out nocopy number
,x_msg_data out nocopy varchar2
                );


Type quote_header_Rec_Type Is Record
(   accounting_rule_id            NUMBER
,   agreement_id                  NUMBER
,   booked_flag                   VARCHAR2(1)
,   cancelled_flag                VARCHAR2(1)
,   context                       VARCHAR2(30)
,   conversion_rate               NUMBER
,   conversion_rate_date          DATE
,   conversion_type_code          VARCHAR2(30)
,   customer_preference_set_code  VARCHAR2(30)
,   cust_po_number                VARCHAR2(50)
,   deliver_to_contact_id         NUMBER
,   deliver_to_org_id             NUMBER
,   demand_class_code             VARCHAR2(30)
,   expiration_date               DATE
,   fob_point_code                VARCHAR2(30)
,   freight_carrier_code          VARCHAR2(30)
,   freight_terms_code            VARCHAR2(30)
,   invoice_to_contact_id         NUMBER
,   invoice_to_org_id             NUMBER
,   invoicing_rule_id             NUMBER
,   order_category_code           VARCHAR2(30)
,   ordered_date                  DATE
,   order_date_type_code	  VARCHAR2(30)
,   order_number                  NUMBER
,   order_source_id               NUMBER
,   order_type_id                 NUMBER
,   org_id                        NUMBER
,   payment_term_id               NUMBER
,   price_list_id                 NUMBER
,   pricing_date                  DATE
,   request_date                  DATE
,   request_id                    NUMBER
,   salesrep_id			  NUMBER
,   sales_channel_code            VARCHAR2(30)
,   shipment_priority_code        VARCHAR2(30)
,   shipping_method_code          VARCHAR2(30)
,   ship_from_org_id              NUMBER
,   ship_to_contact_id            NUMBER
,   ship_to_org_id                NUMBER
,   sold_from_org_id		  NUMBER
,   sold_to_contact_id            NUMBER
,   sold_to_org_id                NUMBER
,   source_document_id            NUMBER
,   source_document_type_id       NUMBER
,   transactional_curr_code       VARCHAR2(15)
,   drop_ship_flag		  VARCHAR2(1)
,   customer_payment_term_id	  NUMBER
,   payment_type_code             VARCHAR2(30)
,   payment_amount                NUMBER
,   credit_card_code              VARCHAR2(80)
,   credit_card_holder_name       VARCHAR2(80)
,   credit_card_number            VARCHAR2(80)
,   marketing_source_code_id      NUMBER
);


TYPE quote_line_Rec IS RECORD
(   actual_arrival_date           DATE
,   actual_shipment_date          DATE
,   agreement_id                  NUMBER
,   cancelled_quantity            NUMBER
,   cust_po_number                VARCHAR2(50)
,   deliver_to_contact_id         NUMBER
,   deliver_to_org_id             NUMBER
,   freight_carrier_code          VARCHAR2(30)
,   freight_terms_code            VARCHAR2(30)
,   intermed_ship_to_org_id       NUMBER
,   intermed_ship_to_contact_id   NUMBER
,   inventory_item_id             NUMBER
,   invoice_interface_status_code VARCHAR2(30)
,   invoice_to_contact_id         NUMBER
,   invoice_to_org_id             NUMBER
,   ordered_item                  VARCHAR2(2000)
,   item_type_code                VARCHAR2(30)
,   line_id                       NUMBER
,   line_type_id                  NUMBER
,   ordered_quantity              NUMBER
,   ordered_quantity2             NUMBER
,   order_quantity_uom            VARCHAR2(3)
,   ordered_quantity_uom2         VARCHAR2(3)
,   org_id                        NUMBER
,   payment_term_id               NUMBER
,   price_list_id                 NUMBER
,   pricing_context               VARCHAR2(240)
,   pricing_date                  DATE
,   pricing_quantity              NUMBER
,   pricing_quantity_uom          VARCHAR2(3)
,   project_id                    NUMBER
,   promise_date                  DATE
,   salesrep_id			  NUMBER
,   schedule_arrival_date         DATE
,   schedule_ship_date            DATE
,   ship_from_org_id              NUMBER
,   ship_to_org_id                NUMBER
,   sold_to_org_id                NUMBER
,   sold_from_org_id              NUMBER
,   source_document_type_id       NUMBER
,   task_id                       NUMBER
,   tax_code                      VARCHAR2(50)
,   unit_list_price               NUMBER
,   unit_selling_price            NUMBER
,   order_source_id               NUMBER
,   customer_payment_term_id	  NUMBER
,   ordered_item_id               NUMBER
,   item_identifier_type          VARCHAR2(25)
,   unit_list_percent             NUMBER
,   unit_selling_percent          NUMBER
,   unit_percent_base_price       NUMBER
,   service_number                NUMBER
,   revenue_amount    		  NUMBER
,   status_code                   VARCHAR2(30)
,   status_text                   VARCHAR2(240)
);

Type quote_line_tbl_type is Table of quote_line_rec index by binary_integer;


Type key_rec_type is record
(db_start NUMBER DEFAULT NULL,
 db_end   NUMBER DEFAULT NULL
);

Type key_tbl_type is table of key_rec_type index by binary_integer;

G_MISS_KEY_TBL key_tbl_type;

PROCEDURE Get_Quote(p_quote_header       in  quote_header_rec_type,
                    p_quote_line_tbl     in  quote_line_tbl_type,
                    p_request_type_code  in  Varchar2,
                    p_event              in  Varchar2 default 'BATCH',
x_quote_line_tbl out nocopy quote_line_tbl_type,
x_return_status out nocopy Varchar2,
x_return_status_text out nocopy Varchar2);
-- sgowtham
Type Manual_Adj_Type is Record
(modifier_number      Varchar2(240)
,list_line_type_code  Varchar2(30)
,operator             Varchar2(30)
,operand              Number
,list_line_id         Number
,list_header_id       Number
,pricing_phase_id     Number
,automatic_flag       Varchar2(1)
,modifier_level_code  Varchar2(30)
,override_flag        Varchar2(1)
,adjusted_amount      Number
,charge_type_code     Varchar2(30)
,charge_subtype_code  Varchar2(30)
,PRICE_BREAK_TYPE_CODE VARCHAR2(30) --bucket man
,PRICING_GROUP_SEQUENCE NUMBER
);

Type Manual_Adj_Tbl_Type Is Table of Manual_Adj_Type index by Binary_Integer;

Procedure Create_Manual_Adjustments(p_line_id In Number);

-- Bug 1713035
-- Introduced a new parameter p_line_level to indicate that
-- this procedure is being called from sales order lines.
-- if p_line_level='Y' show only line/linegroup level manual adjustments
-- else show all other adjustments too

Procedure Get_Manual_Adjustments (
p_header_id        in  number                     Default Null,
p_line_id          in  number                     Default Null,
p_line_rec         in  oe_Order_Pub.Line_Rec_Type Default oe_order_pub.g_miss_line_rec,
p_level            in  Varchar2 default 'LINE',
p_pbh_mode         in  Varchar2 default 'CHILD',
p_cross_order      in  Varchar2 Default 'N',
p_line_level       in  Varchar2 Default 'N',
x_manual_adj_tbl   out Nocopy  Oe_Order_Adj_Pvt.Manual_Adj_Tbl_Type,
x_return_status out nocopy Varchar2,
x_header_id out nocopy Number,
p_freight_flag     in  boolean default false,
p_called_from      in  varchar2 default null
);

Procedure Promotion_Put_Hold(                                    -- PROMOTIONS SEP/01
p_header_id        in                   Number   default null,
p_line_id          in 			Number   default null
);

PROCEDURE Insert_Adj_Assocs
(p_Line_Adj_Assoc_tbl          IN OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
);

PROCEDURE Insert_Adj_Atts
(p_Line_Adj_attribs_tbl          IN OE_Order_PUB.Line_Adj_Att_Tbl_Type
);


Procedure copy_Header_to_request(
 p_header_rec	 			OE_Order_PUB.Header_Rec_Type
,px_req_line_tbl   in out nocopy	QP_PREQ_GRP.LINE_TBL_TYPE
,p_Request_Type_Code			varchar2
,p_calculate_price_flag 		varchar2
);


Procedure copy_Line_to_request(
 p_Line_rec	 		OE_Order_PUB.Line_Rec_Type
,px_req_line_tbl   		in out nocopy 	QP_PREQ_GRP.LINE_TBL_TYPE
,p_pricing_event		varchar2
,p_Request_Type_Code		varchar2
,p_honor_price_flag		VARCHAR2 	Default 'Y'
);

Procedure copy_attribs_to_Req(
p_line_index				number
,p_pricing_contexts_Tbl 		QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
,p_qualifier_contexts_Tbl 	QP_Attr_Mapping_PUB.Contexts_Result_Tbl_Type
,px_Req_line_attr_tbl		in out nocopy  QP_PREQ_GRP.LINE_ATTR_TBL_TYPE
,px_Req_qual_tbl			in out  nocopy  QP_PREQ_GRP.QUAL_TBL_TYPE
);


Procedure Reset_Fields(p_line_rec in Oe_Order_Pub.Line_Rec_Type);
-- bug 6718566
Procedure GET_MANUAL_ADV_STATUS(p_event_code IN VARCHAR2);

end oe_order_adj_pvt;

/
