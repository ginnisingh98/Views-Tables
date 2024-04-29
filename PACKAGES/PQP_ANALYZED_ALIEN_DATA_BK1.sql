--------------------------------------------------------
--  DDL for Package PQP_ANALYZED_ALIEN_DATA_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ANALYZED_ALIEN_DATA_BK1" AUTHID CURRENT_USER as
/* $Header: pqaadapi.pkh 120.0 2005/05/29 01:39:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_analyzed_alien_data_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_analyzed_alien_data_b
  (
   p_assignment_id                  in  number
  ,p_data_source                    in  varchar2
  ,p_tax_year                       in  number
  ,p_current_residency_status       in  varchar2
  ,p_nra_to_ra_date                 in  date
  ,p_target_departure_date          in  date
  ,p_tax_residence_country_code     in  varchar2
  ,p_treaty_info_update_date        in  date
  ,p_number_of_days_in_usa          in  number
  ,p_withldg_allow_eligible_flag    in  varchar2
  ,p_ra_effective_date              in  date
  ,p_record_source                  in  varchar2
  ,p_visa_type                      in  varchar2
  ,p_j_sub_type                     in  varchar2
  ,p_primary_activity               in  varchar2
  ,p_non_us_country_code            in  varchar2
  ,p_citizenship_country_code       in  varchar2
  ,p_effective_date                 in  date
  ,p_date_8233_signed               in  date
  ,p_date_w4_signed                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_analyzed_alien_data_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_analyzed_alien_data_a
  (
   p_analyzed_data_id               in  number
  ,p_assignment_id                  in  number
  ,p_data_source                    in  varchar2
  ,p_tax_year                       in  number
  ,p_current_residency_status       in  varchar2
  ,p_nra_to_ra_date                 in  date
  ,p_target_departure_date          in  date
  ,p_tax_residence_country_code     in  varchar2
  ,p_treaty_info_update_date        in  date
  ,p_number_of_days_in_usa          in  number
  ,p_withldg_allow_eligible_flag    in  varchar2
  ,p_ra_effective_date              in  date
  ,p_record_source                  in  varchar2
  ,p_visa_type                      in  varchar2
  ,p_j_sub_type                     in  varchar2
  ,p_primary_activity               in  varchar2
  ,p_non_us_country_code            in  varchar2
  ,p_citizenship_country_code       in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_date_8233_signed               in  date
  ,p_date_w4_signed                 in  date
  );
--
end pqp_analyzed_alien_data_bk1;

 

/
