--------------------------------------------------------
--  DDL for Package ARP_ARXCUDCI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ARXCUDCI_PKG" AUTHID CURRENT_USER as
/* $Header: AROSTDS.pls 115.0 99/07/17 00:02:43 porting ship $ */
procedure initialize ( 	customer_type 		in out varchar2,
			tax_printing_option 	in out varchar2,
			grouping_rule 		in out varchar2,
			create_reciprocal 	in out varchar2,
			auto_cust_numbering 	in out varchar2,
			auto_site_numbering 	in out varchar2,
			profile_class 		in out varchar2,
			change_cust_name 	in out varchar2,
			use_customer_keys_flag 	in out varchar2,
			so_organization_id 	in out number,
			address_validation 	in out varchar2,
			location_structure_id 	in out number,
			from_postal_code 	in out varchar2,
			to_postal_code 		in out varchar2,
			home_country_code 	in out varchar2,
			default_country_code 	in out varchar2,
			default_country_disp 	in out varchar2,
			address_style		in out varchar2,
			functional_currency	in out varchar2

	   	     );

end arp_arxcudci_pkg;

 

/
