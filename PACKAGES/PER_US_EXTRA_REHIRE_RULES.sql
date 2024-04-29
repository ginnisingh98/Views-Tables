--------------------------------------------------------
--  DDL for Package PER_US_EXTRA_REHIRE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_EXTRA_REHIRE_RULES" AUTHID CURRENT_USER AS
/* $Header: peexehcc.pkh 120.0 2005/05/31 08:41:55 appldev noship $ */
PROCEDURE delete_tax_record
  (p_final_process_date    in date
  ,p_period_of_service_id  in number
  );
--
END per_us_extra_rehire_rules;

 

/
