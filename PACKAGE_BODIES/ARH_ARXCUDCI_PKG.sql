--------------------------------------------------------
--  DDL for Package Body ARH_ARXCUDCI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_ARXCUDCI_PKG" AS
/* $Header: ARHSTDB.pls 120.2 2005/06/16 21:16:05 jhuang ship $*/
--
-- PROCEDURE
--     initialize
--
-- DESCRIPTION
--		This procedure returns all the defaults ans system options the form
--		requires.
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--
--              OUT:
--                    None
--
-- RETURNS    : NONE
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
procedure initialize ( 	customer_type 		in out NOCOPY varchar2,
			tax_printing_option 	in out NOCOPY varchar2,
			grouping_rule		in out NOCOPY varchar2,
			create_reciprocal	in out NOCOPY varchar2,
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
	   	     ) is

begin
	customer_type := arp_standard.ar_lookup('CUSTOMER_TYPE','R');

	tax_printing_option := arp_standard.sysparm.tax_invoice_print;

        begin
	  select gr.name
	  into    grouping_rule
	  from    ra_grouping_rules gr
	  where   gr.grouping_rule_id = arp_standard.sysparm.default_grouping_rule_id
	  and     trunc(sysdate) BETWEEN gr.start_date AND nvl(gr.end_date, trunc(sysdate));
          exception
            when NO_DATA_FOUND then
            null;
        end;

	--l_sob_id	  := arp_standard.sysparm.set_of_books_id;
	--
       BEGIN
	SELECT 	currency_code
	INTO	functional_currency
	FROM	gl_sets_of_books
	WHERE	set_of_books_id = arp_standard.sysparm.set_of_books_id;
       EXCEPTION
            when NO_DATA_FOUND then
            arp_standard.fnd_message( 'ARTA_SET_OF_BOOKS_ID_NOT_FOUND' );
       END;
	--
	create_reciprocal := arp_standard.sysparm.create_reciprocal_flag;
	auto_cust_numbering := arp_standard.sysparm.generate_customer_number;
	auto_site_numbering := arp_standard.sysparm.auto_site_numbering;
	address_validation :=  arp_standard.sysparm.address_validation;
	location_structure_id := arp_standard.sysparm.location_structure_id;
	from_postal_code := arp_standard.sysparm.from_postal_code;
	to_postal_code := arp_standard.sysparm.to_postal_code;
	home_country_code := arp_standard.sysparm.default_country;
	fnd_profile.get('DEFAULT_COUNTRY',default_country_code);
	--
	if  ( default_country_code is null ) then
		default_country_code := home_country_code;
	end if;
	--
	-- To avoid exception NO_DATA_FOUND "if" clause is used
        --
        if default_country_code is not null then
	  select territory_short_name,address_style
	  into 	 default_country_disp,address_style
	  from 	 fnd_territories_vl
	  where  territory_code = default_country_code;
        end if;
	--
	--
	fnd_profile.get('AR_CHANGE_CUST_NAME',change_cust_name);
	fnd_profile.get('AS_USE_CUSTOMER_KEYS_FLAG',use_customer_keys_flag);

        -- OE/OM Change
        --
	-- fnd_profile.get('SO_ORGANIZATION_ID',so_organization_id);
        --
	oe_profile.get('SO_ORGANIZATION_ID',so_organization_id);

        begin
	  select 	cpc.name
  	  into 	profile_class
  	  from 	hz_cust_profile_classes cpc
 	  WHERE cpc.status 		      = 'A'
   	  AND 	cpc.profile_class_id = 0;
          exception
            when NO_DATA_FOUND then
            null;
        end;

end initialize;

end arh_arxcudci_pkg;

/
