--------------------------------------------------------
--  DDL for Package PAY_IE_SB_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_SB_API_BK1" AUTHID CURRENT_USER as
/* $Header: pyisbapi.pkh 120.0 2005/05/29 06:01:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ie_sb_details_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ie_sb_details_b
  (p_effective_date                 in      date
  ,p_business_group_id              in      number
  ,p_assignment_id                  in      number
  ,p_absence_start_date             in      date
  ,p_absence_end_date               in      date
  ,p_benefit_amount                 in      number
  ,p_benefit_type                   in      varchar2
  ,p_calculation_option             in      varchar2
  ,p_reduced_tax_credit             in      number
  ,p_reduced_standard_cutoff        in      number
  ,p_incident_id                    in      number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ie_sb_details_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ie_sb_details_a
  (p_effective_date                 in      date
  ,p_business_group_id              in      number
  ,p_assignment_id                  in      number
  ,p_absence_start_date             in      date
  ,p_absence_end_date               in      date
  ,p_benefit_amount                 in      number
  ,p_benefit_type                   in      varchar2
  ,p_calculation_option             in      varchar2
  ,p_reduced_tax_credit             in      number
  ,p_reduced_standard_cutoff        in      number
  ,p_incident_id                    in      number
  ,p_social_benefit_id              in      number
  ,p_object_version_number          in      number
  ,p_effective_start_date           in      date
  ,p_effective_end_date             in      date
  );
--
end pay_ie_sb_api_bk1;

 

/
