--------------------------------------------------------
--  DDL for Package Body PER_US_EXTRA_ADDRESS_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_EXTRA_ADDRESS_RULES" AS
/* $Header: peaddhcc.pkb 115.2 2004/05/18 06:32:41 kvsankar ship $ */
  PROCEDURE insert_tax_record
    (p_effective_date    in date
    ,p_address_id        in number) IS
  --
  BEGIN

    pay_us_tax_internal.maintain_us_employee_taxes
      (p_effective_date => p_effective_date,
       p_address_id     => p_address_id);

  END;

  PROCEDURE update_tax_record
    (p_effective_date    in date
    ,p_address_id        in number) IS
  --
  BEGIN

    pay_us_tax_internal.maintain_us_employee_taxes
      (p_effective_date => p_effective_date,
       p_address_id     => p_address_id);
  END;

END per_us_extra_address_rules;

/
