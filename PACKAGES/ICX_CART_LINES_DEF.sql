--------------------------------------------------------
--  DDL for Package ICX_CART_LINES_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CART_LINES_DEF" AUTHID CURRENT_USER as
/* $Header: ICXCRLDS.pls 115.0 99/08/09 17:22:52 porting ship $ */

--  procedure line_default (line_rec IN OUT AK$ICX_SHOPPING_CART_LINES_V.REC);
procedure line_default(line_rec IN OUT varchar2);
end ICX_CART_LINES_DEF;

 

/
