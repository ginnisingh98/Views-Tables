--------------------------------------------------------
--  DDL for Package ARH_ARXCUDCI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_ARXCUDCI_PKG" AUTHID CURRENT_USER as
/* $Header: ARHSTDS.pls 120.2 2005/06/16 21:16:08 jhuang ship $*/
procedure initialize ( 	customer_type 		in out NOCOPY varchar2,
			tax_printing_option 	in out NOCOPY varchar2,
			grouping_rule 		in out NOCOPY varchar2,
			create_reciprocal 	in out NOCOPY varchar2,
			auto_cust_numbering 	in out NOCOPY varchar2,
			auto_site_numbering 	in out NOCOPY varchar2,
			profile_class 		in out NOCOPY varchar2,
			change_cust_name 	in out NOCOPY varchar2,
			use_customer_keys_flag 	in out NOCOPY varchar2,
			so_organization_id 	in out NOCOPY number,
			address_validation 	in out NOCOPY varchar2,
			location_structure_id 	in out NOCOPY number,
			from_postal_code 	in out NOCOPY varchar2,
			to_postal_code 		in out NOCOPY varchar2,
			home_country_code 	in out NOCOPY varchar2,
			default_country_code 	in out NOCOPY varchar2,
			default_country_disp 	in out NOCOPY varchar2,
			address_style		in out NOCOPY varchar2,
			functional_currency	in out NOCOPY varchar2

	   	     );

end arh_arxcudci_pkg;

 

/
