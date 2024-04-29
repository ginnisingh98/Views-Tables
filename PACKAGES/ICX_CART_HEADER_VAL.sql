--------------------------------------------------------
--  DDL for Package ICX_CART_HEADER_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CART_HEADER_VAL" AUTHID CURRENT_USER as
/* $Header: ICXCRHVS.pls 115.0 99/08/09 17:22:48 porting ship $ */


--  procedure HEADER_VALIDATION (header_rec IN AK$ICX_SHOPPING_CARTS_V.REC);
 procedure HEADER_VALIDATION(header_rec IN varchar2);
end ICX_CART_HEADER_VAL;

 

/
