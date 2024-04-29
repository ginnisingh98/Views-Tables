--------------------------------------------------------
--  DDL for Package QP_UPG_OE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UPG_OE_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXIUOES.pls 120.1 2005/06/14 05:04:58 appldev  $ */

PROCEDURE Upg_Pricing_Attribs;

PROCEDURE Upg_Pricing_Attribs( p_line_rec IN  OE_Order_PUB.Line_Rec_Type);

PROCEDURE Upg_Pricing_Attribs (p_upg_line_rec IN OE_UPG_SO_NEW.LINE_REC_TYPE);

TYPE Price_Adj_Rec_Type IS RECORD
(       list_header_id				OE_PRICE_ADJUSTMENTS.list_header_id%TYPE
,       list_line_id				OE_PRICE_ADJUSTMENTS.list_line_id%TYPE
,       list_line_type_code			OE_PRICE_ADJUSTMENTS.list_line_type_code%TYPE
,       modified_from				OE_PRICE_ADJUSTMENTS.modified_from%TYPE
,       modified_to					OE_PRICE_ADJUSTMENTS.modified_to%TYPE
,       update_allowed				OE_PRICE_ADJUSTMENTS.update_allowed%TYPE
,       operand					OE_PRICE_ADJUSTMENTS.operand%TYPE
,       updated_flag				OE_PRICE_ADJUSTMENTS.updated_flag%TYPE
,       applied_flag				OE_PRICE_ADJUSTMENTS.applied_flag%TYPE
,       arithmetic_operator			OE_PRICE_ADJUSTMENTS.arithmetic_operator%TYPE
,       price_break_type_code			OE_PRICE_ADJUSTMENTS.price_break_type_code%TYPE
,       adjusted_amount				OE_PRICE_ADJUSTMENTS.adjusted_amount%TYPE
,       source_system_code			OE_PRICE_ADJUSTMENTS.source_system_code%TYPE
,       pricing_phase_id				OE_PRICE_ADJUSTMENTS.pricing_phase_id%TYPE
,       charge_type_code				OE_PRICE_ADJUSTMENTS.charge_type_code%TYPE
,       charge_subtype_code			OE_PRICE_ADJUSTMENTS.charge_subtype_code%TYPE
,       list_line_no				OE_PRICE_ADJUSTMENTS.list_line_no%TYPE
,       benefit_qty					OE_PRICE_ADJUSTMENTS.benefit_qty%TYPE
,       benefit_uom_code				OE_PRICE_ADJUSTMENTS.benefit_uom_code%TYPE
,       print_on_invoice_flag			OE_PRICE_ADJUSTMENTS.print_on_invoice_flag%TYPE
,       modifier_level_code			OE_PRICE_ADJUSTMENTS.modifier_level_code%TYPE
,       pricing_group_sequence		OE_PRICE_ADJUSTMENTS.pricing_group_sequence%TYPE
,       expiration_date				OE_PRICE_ADJUSTMENTS.expiration_date%TYPE
);


PROCEDURE Upg_Price_Adj_OE_to_QP(	p_discount_id		IN NUMBER,
					p_discount_line_id	IN NUMBER,
					p_percent		IN NUMBER,
					p_unit_list_price	IN NUMBER,
					p_pricing_context	IN VARCHAR2,
					p_line_id		IN NUMBER,
					x_output		OUT NOCOPY /* file.sql.39 change */ PRICE_ADJ_REC_TYPE);

G_Price_Adj_Rec	Price_Adj_Rec_Type;


END QP_Upg_OE_PVT;

 

/
