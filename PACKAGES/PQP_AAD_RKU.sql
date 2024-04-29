--------------------------------------------------------
--  DDL for Package PQP_AAD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_AAD_RKU" AUTHID CURRENT_USER as
/* $Header: pqaadrhi.pkh 120.0 2005/05/29 01:39:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_analyzed_data_id               in number
 ,p_assignment_id                  in number
 ,p_data_source                    in varchar2
 ,p_tax_year                       in number
 ,p_current_residency_status       in varchar2
 ,p_nra_to_ra_date                 in date
 ,p_target_departure_date          in date
 ,p_tax_residence_country_code     in varchar2
 ,p_treaty_info_update_date        in date
 ,p_number_of_days_in_usa          in number
 ,p_withldg_allow_eligible_flag    in varchar2
 ,p_ra_effective_date              in date
 ,p_record_source                  in varchar2
 ,p_visa_type                      in varchar2
 ,p_j_sub_type                     in varchar2
 ,p_primary_activity               in varchar2
 ,p_non_us_country_code            in varchar2
 ,p_citizenship_country_code       in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_date_8233_signed               in date
 ,p_date_w4_signed                 in date
 ,p_assignment_id_o                in number
 ,p_data_source_o                  in varchar2
 ,p_tax_year_o                     in number
 ,p_current_residency_status_o     in varchar2
 ,p_nra_to_ra_date_o               in date
 ,p_target_departure_date_o        in date
 ,p_tax_residence_country_code_o   in varchar2
 ,p_treaty_info_update_date_o      in date
 ,p_number_of_days_in_usa_o        in number
 ,p_withldg_allow_eligible_fla_o  in varchar2
 ,p_ra_effective_date_o            in date
 ,p_record_source_o                in varchar2
 ,p_visa_type_o                    in varchar2
 ,p_j_sub_type_o                   in varchar2
 ,p_primary_activity_o             in varchar2
 ,p_non_us_country_code_o          in varchar2
 ,p_citizenship_country_code_o     in varchar2
 ,p_object_version_number_o        in number
 ,p_date_8233_signed_o             in date
 ,p_date_w4_signed_o               in date
  );
--
end pqp_aad_rku;

 

/
