--------------------------------------------------------
--  DDL for Package ARP_TEST_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TEST_TAX" AUTHID CURRENT_USER as
/* $Header: ARTSTTXS.pls 115.2 2002/11/15 04:01:16 anukumar ship $ */

 test_description varchar2(80);

 function  update_header( p_customer_trx_id IN number, p_msg out NOCOPY varchar2 ) return BOOLEAN;
 procedure update_all_headers( p_tax_line_count IN NUMBER default null );
 function  check_dist( p_customer_trx_id IN number ) return BOOLEAN;

end;

 

/
