--------------------------------------------------------
--  DDL for Package ICX_STORE_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_STORE_CUSTOM" AUTHID CURRENT_USER as
/* $Header: ICXCSTMS.pls 115.1 99/07/17 03:16:12 porting ship $ */

 procedure add_user_error(p_cart_id number, error_message varchar2);

 procedure  store_validate_head(p_cart_id IN NUMBER);



 procedure  store_validate_line(p_cart_id in number);



 procedure store_default_lines(p_cart_id in number);



 procedure  store_default_head(p_cart_id in number);

 procedure freight_customcalc(p_cart_id in number,
                              p_amt out number);

end icx_store_custom;

 

/
