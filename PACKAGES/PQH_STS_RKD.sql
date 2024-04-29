--------------------------------------------------------
--  DDL for Package PQH_STS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_STS_RKD" AUTHID CURRENT_USER as
/* $Header: pqstsrhi.pkh 120.0 2005/05/29 02:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_statutory_situation_id       in number
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
end pqh_sts_rkd;

 

/
