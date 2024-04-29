--------------------------------------------------------
--  DDL for Package OE_LINEINFO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINEINFO_GRP" AUTHID CURRENT_USER AS
/* $Header: OEXLIFOS.pls 120.0 2005/06/01 00:51:15 appldev noship $ */




Type adj_tbl_type is Table of OE_HEADER_ADJ_UTIL.line_adjustments_rec_type;
Type tax_rec_type is record
(tax_code VARCHAR2(50),
 tax_rate NUMBER,
 tax_amount NUMBER ,
 tax_date DATE,
 tax_exempt_flag VARCHAR2(1),
 tax_exempt_number VARCHAR2(80),
 tax_exempt_reason_code VARCHAR2(30));

Procedure Get_Adjustments( p_header_id  IN NUMBER
			  ,p_line_id    IN NUMBER
			  ,x_adj_detail OUT nocopy OE_Header_Adj_Util.line_adjustments_tab_type
			  ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

Procedure Get_Tax(p_header_id IN NUMBER
		  ,p_line_id  IN NUMBER
		  ,x_tax_rec OUT nocopy oe_lineinfo_grp.tax_rec_type
		  ,x_return_status OUT nocopy VARCHAR2);

/*Procedure Get_All_Taxes(p_header_id IN NUMBER
			,x_tax_tbl OUT nocopy oe_lineinfo_grp.tax_tbl_type);*/

Procedure Get_Total_Tax(p_header_id IN NUMBER
			 ,x_order_tax_total OUT nocopy NUMBER
			 ,x_return_status OUT nocopy VARCHAR2);

End  OE_LINEINFO_GRP;

 

/
