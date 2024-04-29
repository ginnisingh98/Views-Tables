--------------------------------------------------------
--  DDL for Package OZF_LOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_LOCATION_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvlocs.pls 115.1 2004/01/30 03:23:31 mkothari noship $ */


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


   FUNCTION get_location (p_location_id         IN NUMBER,
                          p_cust_site_use_code  IN VARCHAR2 := NULL
                         )return VARCHAR2;

   FUNCTION get_location_id (p_site_use_id      IN NUMBER
                            )return NUMBER;

   FUNCTION get_party_name(p_party_id    IN NUMBER,
                           p_site_use_id IN NUMBER) RETURN VARCHAR2;


END ozf_location_pvt;

 

/
