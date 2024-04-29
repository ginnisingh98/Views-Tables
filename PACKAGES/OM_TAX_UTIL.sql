--------------------------------------------------------
--  DDL for Package OM_TAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OM_TAX_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUTAXS.pls 120.1.12010000.1 2008/07/25 07:57:55 appldev ship $ */

TYPE om_tax_out_rec_type IS RECORD
( trx_id    	           NUMBER,
  trx_line_id              NUMBER,
  tax_amount               NUMBER,
  taxable_amount           NUMBER,
  tax_rate_id              NUMBER,
  tax_rate_code            VARCHAR2(50),
  tax_rate                 NUMBER,
  amount_includes_tax_flag VARCHAR2(1));


TYPE om_tax_out_tab_type IS TABLE of om_tax_out_rec_type index by
  binary_integer;

om_tax_info_rec_tbl om_tax_out_tab_type;


TYPE tax_rec_tbl_type is TABLE of RA_CUSTOMER_TRX_LINES%ROWTYPE index by
  binary_integer;

tax_rec_tbl         tax_rec_tbl_type;


PROCEDURE TAX_LINE(             p_line_rec          in OE_Order_PUB.Line_Rec_Type,
                                p_header_rec        in OE_Order_PUB.Header_Rec_Type,
                                x_tax_value         out NOCOPY /* file.sql.39 change */ number,
				x_tax_out_tbl OUT NOCOPY OM_TAX_UTIL.OM_TAX_OUT_TAB_TYPE,
                                x_return_status out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE CALCULATE_TAX ( p_header_id 		in number
                         ,x_return_status	out NOCOPY /* file.sql.39 change */ varchar2);

FUNCTION Get_Content_Owner_Id(
p_header_id IN NUMBER)  RETURN NUMBER;

END OM_TAX_UTIL;

/
