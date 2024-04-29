--------------------------------------------------------
--  DDL for Package PQH_STS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_STS_RKU" AUTHID CURRENT_USER as
/* $Header: pqstsrhi.pkh 120.0 2005/05/29 02:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_statutory_situation_id       in number
  ,p_business_group_id            in number
  ,p_situation_name               in varchar2
  ,p_type_of_ps                   in varchar2
  ,p_situation_type               in varchar2
  ,p_sub_type                     in varchar2
  ,p_source                       in varchar2
  ,p_location                     in varchar2
  ,p_reason                       in varchar2
  ,p_is_default                   in varchar2
  ,p_date_from                    in date
  ,p_date_to                      in date
  ,p_request_type                 in varchar2
  ,p_employee_agreement_needed    in varchar2
  ,p_manager_agreement_needed     in varchar2
  ,p_print_arrette                in varchar2
  ,p_reserve_position             in varchar2
  ,p_allow_progressions           in varchar2
  ,p_extend_probation_period      in varchar2
  ,p_remuneration_paid            in varchar2
  ,p_pay_share                    in number
  ,p_pay_periods                  in number
  ,p_frequency                    in varchar2
  ,p_first_period_max_duration    in number
  ,p_min_duration_per_request     in number
  ,p_max_duration_per_request     in number
  ,p_max_duration_whole_career    in number
  ,p_renewable_allowed            in varchar2
  ,p_max_no_of_renewals           in number
  ,p_max_duration_per_renewal     in number
  ,p_max_tot_continuous_duration  in number
  ,p_object_version_number        in number
  ,p_remunerate_assign_status_id  in number
  ,p_business_group_id_o          in number
  ,p_situation_name_o             in varchar2
  ,p_type_of_ps_o                 in varchar2
  ,p_situation_type_o             in varchar2
  ,p_sub_type_o                   in varchar2
  ,p_source_o                     in varchar2
  ,p_location_o                   in varchar2
  ,p_reason_o                     in varchar2
  ,p_is_default_o                 in varchar2
  ,p_date_from_o                  in date
  ,p_date_to_o                    in date
  ,p_request_type_o               in varchar2
  ,p_employee_agreement_needed_o  in varchar2
  ,p_manager_agreement_needed_o   in varchar2
  ,p_print_arrette_o              in varchar2
  ,p_reserve_position_o           in varchar2
  ,p_allow_progressions_o         in varchar2
  ,p_extend_probation_period_o    in varchar2
  ,p_remuneration_paid_o          in varchar2
  ,p_pay_share_o                  in number
  ,p_pay_periods_o                in number
  ,p_frequency_o                  in varchar2
  ,p_first_period_max_duration_o  in number
  ,p_min_duration_per_request_o   in number
  ,p_max_duration_per_request_o   in number
  ,p_max_duration_whole_career_o  in number
  ,p_renewable_allowed_o          in varchar2
  ,p_max_no_of_renewals_o         in number
  ,p_max_duration_per_renewal_o   in number
  ,p_max_tot_continuous_duratio_o in number
  ,p_object_version_number_o      in number
  ,p_remunerate_assign_stat_id_o  in number
  );
--
end pqh_sts_rku;

 

/