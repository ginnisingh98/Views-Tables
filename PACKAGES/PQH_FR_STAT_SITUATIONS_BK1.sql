--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SITUATIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SITUATIONS_BK1" AUTHID CURRENT_USER as
/* $Header: pqstsapi.pkh 120.2 2005/10/28 17:50:11 deenath noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_statutory_situation_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_statutory_situation_b
(
   p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_situation_name                 in     varchar2
  ,p_type_of_ps                     in     varchar2
  ,p_situation_type                 in     varchar2
  ,p_sub_type                       in     varchar2
  ,p_source                         in     varchar2
  ,p_location                       in     varchar2
  ,p_reason                         in     varchar2
  ,p_is_default                     in     varchar2
  ,p_date_from                      in     date
  ,p_date_to                        in     date
  ,p_request_type                   in     varchar2
  ,p_employee_agreement_needed      in     varchar2
  ,p_manager_agreement_needed       in     varchar2
  ,p_print_arrette                  in     varchar2
  ,p_reserve_position               in     varchar2
  ,p_allow_progressions             in     varchar2
  ,p_extend_probation_period        in     varchar2
  ,p_remuneration_paid              in     varchar2
  ,p_pay_share                      in     number
  ,p_pay_periods                    in     number
  ,p_frequency                      in     varchar2
  ,p_first_period_max_duration      in     number
  ,p_min_duration_per_request       in     number
  ,p_max_duration_per_request       in     number
  ,p_max_duration_whole_career      in     number
  ,p_renewable_allowed              in     varchar2
  ,p_max_no_of_renewals             in     number
  ,p_max_duration_per_renewal       in     number
  ,p_max_tot_continuous_duration    in     number
  ,p_remunerate_assign_status_id    in     number

);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_statutory_situation_a>-------------------------|
-- ----------------------------------------------------------------------------
--
  procedure create_statutory_situation_a
  (
     p_effective_date                 in     date
    ,p_business_group_id              in     number
    ,p_situation_name                 in     varchar2
    ,p_type_of_ps                     in     varchar2
    ,p_situation_type                 in     varchar2
    ,p_sub_type                       in     varchar2
    ,p_source                         in     varchar2
    ,p_location                       in     varchar2
    ,p_reason                         in     varchar2
    ,p_is_default                     in     varchar2
    ,p_date_from                      in     date
    ,p_date_to                        in     date
    ,p_request_type                   in     varchar2
    ,p_employee_agreement_needed      in     varchar2
    ,p_manager_agreement_needed       in     varchar2
    ,p_print_arrette                  in     varchar2
    ,p_reserve_position               in     varchar2
    ,p_allow_progressions             in     varchar2
    ,p_extend_probation_period        in     varchar2
    ,p_remuneration_paid              in     varchar2
    ,p_pay_share                      in     number
    ,p_pay_periods                    in     number
    ,p_frequency                      in     varchar2
    ,p_first_period_max_duration      in     number
    ,p_min_duration_per_request       in     number
    ,p_max_duration_per_request       in     number
    ,p_max_duration_whole_career      in     number
    ,p_renewable_allowed              in     varchar2
    ,p_max_no_of_renewals             in     number
    ,p_max_duration_per_renewal       in     number
    ,p_max_tot_continuous_duration    in     number
    ,p_statutory_situation_id         in     number
    ,p_object_version_number          in     number
    ,p_remunerate_assign_status_id    in     number
   );
--
end pqh_fr_stat_situations_bk1;

 

/
