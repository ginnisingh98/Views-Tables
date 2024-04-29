--------------------------------------------------------
--  DDL for Package Body ARP_ARXCUDCI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ARXCUDCI_PKG" AS
/* $Header: AROSTDB.pls 120.2 2005/08/01 12:18:21 mantani ship $ */
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
--	Sisir 	07-JUL-02	:Bug:2420993,Handled exception for set_of_books.
--
procedure initialize ( 	customer_type 		in out nocopy varchar2,
			tax_printing_option 	in out nocopy varchar2,
			grouping_rule		in out nocopy varchar2,
			create_reciprocal	in out nocopy varchar2,
			auto_cust_numbering 	in out nocopy varchar2,
			auto_site_numbering 	in out nocopy varchar2,
			profile_class 		in out nocopy varchar2,
			change_cust_name 	in out nocopy varchar2,
			use_customer_keys_flag 	in out nocopy varchar2,
			so_organization_id 	in out nocopy number,
			address_validation 	in out nocopy varchar2,
			location_structure_id 	in out nocopy number,
			from_postal_code 	in out nocopy varchar2,
			to_postal_code 		in out nocopy varchar2,
			home_country_code 	in out nocopy varchar2,
			default_country_code 	in out nocopy varchar2,
			default_country_disp 	in out nocopy varchar2,
			address_style		in out nocopy varchar2,
			functional_currency	in out nocopy varchar2
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
	--
	---Bug:2420993,Handled the following exception.
	--
	begin
	  SELECT 	currency_code
	  INTO	functional_currency
	  FROM	gl_sets_of_books
	  WHERE	set_of_books_id = arp_standard.sysparm.set_of_books_id;
	exception
	  when NO_DATA_FOUND then
            arp_standard.fnd_message( 'ARTA_SET_OF_BOOKS_ID_NOT_FOUND' );
        end;

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

        /*4512781 ar_customer_profile_classes to hz_cust_profile_classes*/
        begin
	  select 	cpc.name
  	  into 	profile_class
  	  from 	HZ_CUST_PROFILE_CLASSES cpc
 	  WHERE cpc.status 		      = 'A'
   	  AND 	cpc.profile_class_id = 0;
          exception
            when NO_DATA_FOUND then
            null;
        end;

end initialize;

end arp_arxcudci_pkg;

/
