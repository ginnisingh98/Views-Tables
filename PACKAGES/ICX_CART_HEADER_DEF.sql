--------------------------------------------------------
--  DDL for Package ICX_CART_HEADER_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CART_HEADER_DEF" AUTHID CURRENT_USER as
/* $Header: ICXCRHDS.pls 115.0 99/08/09 17:22:44 porting ship $ */


--  procedure HEADER_DEFAULT(header_rec IN OUT AK$ICX_SHOPPING_CARTS_V.REC);
 procedure HEADER_DEFAULT(header_rec IN OUT varchar2);
end ICX_CART_HEADER_DEF;

 

/
