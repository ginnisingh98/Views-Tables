--------------------------------------------------------
--  DDL for Package ICX_CART_LINES_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CART_LINES_VAL" AUTHID CURRENT_USER as
/* $Header: ICXCRLVS.pls 115.0 99/08/09 17:22:55 porting ship $ */

--  procedure line_validation(line_rec IN AK$ICX_SHOPPING_CART_LINES_V.REC);
procedure line_validation(line_rec IN varchar2);
end ICX_CART_LINES_VAL;

 

/
