--------------------------------------------------------
--  DDL for Package ICX_REQ_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_ORDER" AUTHID CURRENT_USER as
/* $Header: ICXREQMS.pls 115.1 99/07/17 03:22:04 porting ship $ */


  /*
  procedure my_order(n_org        varchar2,
                     n_emergency  varchar2   default NULL,
		     n_cart_id    number     default NULL,
                     v_po_number  varchar2   default NULL);
  */
  procedure my_order(n_org        varchar2,
                     n_emergency  varchar2   default NULL,
		     n_cart_id    number     default NULL,
                     v_po_number  varchar2   default NULL,
                     n_cart_line_id number   default NULL,
                     n_account_dist varchar2 default NULL);

  procedure my_order1(n_org        varchar2,
                     n_emergency  varchar2   default NULL,
                     n_cart_id    number     default NULL,
                     v_po_number  varchar2   default NULL);

  procedure my_order2(n_org        varchar2,
                     n_emergency  varchar2   default NULL,
                     n_cart_id    number     default NULL,
                     v_po_number  varchar2   default NULL);

  procedure reserve_po_num(reserved_po_num IN OUT varchar2,
		        	n_cart_id IN number,
		           n_org IN  number);

  procedure get_emergency_po_num(n_org varchar2,n_cart_id number);


  function addURL(URL varchar2, display_text varchar2)
           return varchar2;


  procedure giveWarning;

  procedure get_currency(v_org        in  number,
                         v_currency   out varchar2,
                         v_precision  out number,
                         v_fmt_mask   out varchar2);


  procedure addAttachmentScript;

  procedure submit_item(n_org in varchar2,
                        n_emergency in varchar2 default NULL,
                        v_po_number in varchar2 default NULL,
                        cartId in number,
                        cartLineId in number,
                        cartLineAction in varchar2,
		        itemCount in number);

  procedure copy_line(n_org number,cartId number,cartLineId number);
  procedure delete_line(n_org number,cartId number,cartLineId number);

  pk1		varchar2(10);

end ICX_REQ_ORDER;

 

/
