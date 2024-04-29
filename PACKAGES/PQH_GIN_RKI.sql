--------------------------------------------------------
--  DDL for Package PQH_GIN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GIN_RKI" AUTHID CURRENT_USER as
/* $Header: pqginrhi.pkh 120.0 2005/05/29 01:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_global_index_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_type_of_record               in varchar2
  ,p_gross_index                  in number
  ,p_increased_index              in number
  ,p_basic_salary_rate            in number
  ,p_housing_indemnity_rate            in number
  ,p_object_version_number        in number
  ,p_currency_code		  in varchar2
  );
end pqh_gin_rki;

 

/
