--------------------------------------------------------
--  DDL for Package PAY_PL_SII_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_SII_BK2" AUTHID CURRENT_USER as
/* $Header: pypsdapi.pkh 120.4 2006/04/24 23:37:08 nprasath noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_pl_sii_details_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pl_sii_details_b
  (p_effective_date                in     date
  ,p_sii_details_id                in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2
  ,p_pension_contribution          in     varchar2
  ,p_sickness_contribution         in     varchar2
  ,p_work_injury_contribution      in     varchar2
  ,p_labor_contribution            in     varchar2
  ,p_health_contribution           in     varchar2
  ,p_unemployment_contribution     in     varchar2
  ,p_old_age_cont_end_reason       in     varchar2
  ,p_pension_cont_end_reason       in     varchar2
  ,p_sickness_cont_end_reason      in     varchar2
  ,p_work_injury_cont_end_reason   in     varchar2
  ,p_labor_fund_cont_end_reason    in     varchar2
  ,p_health_cont_end_reason        in     varchar2
  ,p_unemployment_cont_end_reason  in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_pl_sii_details_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pl_sii_details_a
  (p_effective_date                in     date
  ,p_sii_details_id                in     number
  ,p_datetrack_update_mode         in     varchar2
  ,p_emp_social_security_info      in     varchar2
  ,p_old_age_contribution          in     varchar2
  ,p_pension_contribution          in     varchar2
  ,p_sickness_contribution         in     varchar2
  ,p_work_injury_contribution      in     varchar2
  ,p_labor_contribution            in     varchar2
  ,p_health_contribution           in     varchar2
  ,p_unemployment_contribution     in     varchar2
  ,p_old_age_cont_end_reason       in     varchar2
  ,p_pension_cont_end_reason       in     varchar2
  ,p_sickness_cont_end_reason      in     varchar2
  ,p_work_injury_cont_end_reason   in     varchar2
  ,p_labor_fund_cont_end_reason    in     varchar2
  ,p_health_cont_end_reason        in     varchar2
  ,p_unemployment_cont_end_reason  in     varchar2
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  );
--
end PAY_PL_SII_BK2;

 

/
