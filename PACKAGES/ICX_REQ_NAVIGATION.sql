--------------------------------------------------------
--  DDL for Package ICX_REQ_NAVIGATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_NAVIGATION" AUTHID CURRENT_USER as
/* $Header: ICXREQSS.pls 115.1 99/07/17 03:22:10 porting ship $ */

  procedure shopper_info(v_shopper_id    IN  number,
                         v_shopper_name  OUT VARCHAR2,
                         v_location_id   OUT number,
                         v_location_code OUT VARCHAR2,
                         v_org_id        OUT NUMBER,
                         v_org_code      OUT VARCHAR2);



  procedure reqs_welcome_page;

  procedure chk_vendor_on(v_on out varchar2);

  procedure top_frame( tab_name  varchar2, emergency varchar2 default NULL );

  procedure ic_parent(cart_id in varchar2, emergency in varchar2  default NULL );

  function addURL(URL varchar2, display_text varchar2)
           return varchar2;

  procedure get_currency(v_org        in  number,
                         v_currency   out varchar2,
                         v_precision  out number,
                         v_fmt_mask   out varchar2);

  procedure giveWarning;

  procedure Copy_Req_to_Cart(p_req_header_id varchar2);


end ICX_REQ_NAVIGATION;

 

/
