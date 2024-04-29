--------------------------------------------------------
--  DDL for Package ARP_ADDR_LABEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ADDR_LABEL_PKG" AUTHID CURRENT_USER as
/* $Header: AROADDLS.pls 115.1 99/10/11 16:15:15 porting sh $ */


FUNCTION format_address_label( address_style IN VARCHAR2,
                               address1 IN VARCHAR2,
                               address2 IN VARCHAR2,
                               address3 IN VARCHAR2,
                               address4 IN VARCHAR2,
                               city IN VARCHAR2,
                               county IN VARCHAR2,
                               state IN VARCHAR2,
                               province IN VARCHAR2,
                               postal_code IN VARCHAR2,
                               territory_short_name IN VARCHAR2,
                               country_code IN VARCHAR2,
                               customer_name IN VARCHAR2,
                               bill_to_location IN VARCHAR2,
                               first_name IN VARCHAR2,
                               last_name IN VARCHAR2,
                               mail_stop IN VARCHAR2,
                               default_country_code IN VARCHAR2,
                               default_country_desc IN VARCHAR2,
                               print_home_country_flag IN VARCHAR2,
                               width IN NUMBER,
                               height_min IN NUMBER,
                               height_max IN NUMBER
                              )return VARCHAR2;


FUNCTION format_address( address_style IN VARCHAR2,
			 address1 IN VARCHAR2,
			 address2 IN VARCHAR2,
			 address3 IN VARCHAR2,
			 address4 IN VARCHAR2,
			 city IN VARCHAR2,
			 county IN VARCHAR2,
			 state IN VARCHAR2,
			 province IN VARCHAR2,
			 postal_code IN VARCHAR2,
			 territory_short_name IN VARCHAR2,
			 country_code IN VARCHAR2,
			 customer_name IN VARCHAR2,
			 bill_to_location IN VARCHAR2,
			 first_name IN VARCHAR2,
			 last_name IN VARCHAR2,
			 mail_stop IN VARCHAR2,
			 default_country_code IN VARCHAR2,
                         default_country_desc IN VARCHAR2,
                         print_home_country_flag IN VARCHAR2,
                         print_default_attn_flag IN VARCHAR2,
			 width IN NUMBER,
			 height_min IN NUMBER,
			 height_max IN NUMBER
		        )return VARCHAR2;


FUNCTION format_address( address_style IN VARCHAR2,
			 address1 IN VARCHAR2,
			 address2 IN VARCHAR2,
			 address3 IN VARCHAR2,
			 address4 IN VARCHAR2,
			 city IN VARCHAR2,
			 county IN VARCHAR2,
			 state IN VARCHAR2,
			 province IN VARCHAR2,
			 postal_code IN VARCHAR2,
			 territory_short_name IN VARCHAR2,
			 country_code IN VARCHAR2 default NULL,
			 customer_name IN VARCHAR2 default NULL,
			 first_name IN VARCHAR2 default NULL,
			 last_name IN VARCHAR2 default NULL,
			 mail_stop IN VARCHAR2 default NULL,
			 default_country_code IN VARCHAR2 default NULL,
                         default_country_desc IN VARCHAR2 default NULL,
                         print_home_country_flag IN VARCHAR2 default 'Y',
                         print_default_attn_flag IN VARCHAR2 default 'N',
			 width IN NUMBER default 1000,
			 height_min IN NUMBER default 1,
			 height_max IN NUMBER default 1
		        )return VARCHAR2;



END arp_addr_label_pkg;

 

/
