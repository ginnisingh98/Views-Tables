--------------------------------------------------------
--  DDL for Package ARP_CUST_ALT_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CUST_ALT_MATCH_PKG" AUTHID CURRENT_USER as
/* $Header: ARCUANMS.pls 115.2 2002/11/15 02:27:13 anukumar ship $ */

--
--
PROCEDURE delete_match( p_customer_id in NUMBER,
	                p_site_use_id in NUMBER,
                        p_alt_name in VARCHAR2
                       );
--
--
PROCEDURE insert_match( p_alt_name in VARCHAR2,
                        p_customer_id in NUMBER,
                        p_site_use_id in NUMBER,
                        p_term_id in NUMBER
                       );
--
--
PROCEDURE update_pay_term_id( p_customer_id in NUMBER,
			      p_site_use_id in NUMBER,
                              p_term_id in NUMBER
		   	     );
--
--
PROCEDURE lock_match( p_customer_id in NUMBER,
		      p_site_use_id in NUMBER,
                      p_status out NOCOPY NUMBER
		     );
--
--

END arp_cust_alt_match_pkg;

 

/
