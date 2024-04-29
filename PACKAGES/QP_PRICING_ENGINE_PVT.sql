--------------------------------------------------------
--  DDL for Package QP_PRICING_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICING_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVDLNS.pls 115.1 99/10/15 16:21:34 porting ship $ */

	TYPE l_discount_line_rec IS RECORD (
		p_discount_id			QP_LIST_LINES.LIST_HEADER_ID%TYPE,
		p_discount_line_id 		QP_LIST_LINES.LIST_LINE_ID%TYPE,
		p_discount_name		QP_LIST_HEADERS.NAME%TYPE,
		p_discount_percent		NUMBER);

	TYPE l_discount_lines_tbl IS TABLE OF l_discount_line_rec
	  INDEX BY BINARY_INTEGER;

	PROCEDURE Get_Discount_Lines
					(p_price_list_id 		NUMBER,
					 p_list_price    		NUMBER,
					 p_quantity			NUMBER,
					 p_unit_code			VARCHAR2,
				  	 p_attribute_id	 	NUMBER,
					 p_attribute_value 		VARCHAR2,
					 p_pricing_date		DATE,
					 p_customer_class_code	VARCHAR2,
					 p_sold_to_org_id		VARCHAR2,
					 p_ship_to_id			VARCHAR2,
					 p_invoice_to_id		VARCHAR2,
					 p_best_adj_percent		NUMBER,
					 p_gsa				VARCHAR2,
					 p_asc_desc_flag		VARCHAR2,
					 x_discount_line_rec	OUT l_discount_line_rec);
					 --x_discount_lines_tbl 	OUT l_discount_lines_tbl);
END QP_Pricing_Engine_PVT;


 

/
