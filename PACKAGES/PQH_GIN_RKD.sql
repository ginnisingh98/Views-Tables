--------------------------------------------------------
--  DDL for Package PQH_GIN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GIN_RKD" AUTHID CURRENT_USER as
/* $Header: pqginrhi.pkh 120.0 2005/05/29 01:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_global_index_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_type_of_record_o             in varchar2
  ,p_gross_index_o                in number
  ,p_increased_index_o            in number
  ,p_basic_salary_rate_o          in number
  ,p_housing_indemnity_rate_o          in number
  ,p_object_version_number_o      in number
  ,p_currency_code_o		  in varchar2
  );
--
end pqh_gin_rkd;

 

/
