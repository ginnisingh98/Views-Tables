--------------------------------------------------------
--  DDL for Package PER_US_EXTRA_ADDRESS_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_EXTRA_ADDRESS_RULES" AUTHID CURRENT_USER AS
/* $Header: peaddhcc.pkh 120.0 2005/05/31 04:55:15 appldev noship $ */
procedure insert_tax_record
  (p_effective_date    in date
  ,p_address_id        in number
  );
--
procedure update_tax_record
  (p_effective_date    in date
  ,p_address_id        in number
  );
--
END per_us_extra_address_rules;

 

/
