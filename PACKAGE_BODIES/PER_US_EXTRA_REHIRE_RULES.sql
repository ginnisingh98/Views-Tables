--------------------------------------------------------
--  DDL for Package Body PER_US_EXTRA_REHIRE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_EXTRA_REHIRE_RULES" AS
/* $Header: peexehcc.pkb 115.3 2002/03/15 07:20:50 pkm ship    $ */
PROCEDURE delete_tax_record
  (p_final_process_date    in date
  ,p_period_of_service_id  in number) IS
--
  CURSOR csr_get_address_id (p_pds_id NUMBER) IS
    SELECT adr.address_id
    FROM   per_addresses          adr,
           per_periods_of_service pds
    WHERE  pds.period_of_service_id = p_pds_id
    AND    adr.primary_flag         = 'Y'
    AND    adr.person_id            = pds.person_id;

  l_address_id NUMBER;

  BEGIN

    OPEN csr_get_address_id(p_period_of_service_id);
    FETCH csr_get_address_id INTO l_address_id;

    IF csr_get_address_id%FOUND THEN
      pay_us_tax_internal.maintain_us_employee_taxes
        (p_effective_date => p_final_process_date
        ,p_datetrack_mode => 'DELETE'
        ,p_address_id     => l_address_id
        ,p_delete_routine => 'ASSIGNMENT'
        );
    END IF;

    CLOSE csr_get_address_id;

  END;
END per_us_extra_rehire_rules;

/
