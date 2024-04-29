--------------------------------------------------------
--  DDL for Package PAY_SID_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SID_RKI" AUTHID CURRENT_USER as
/* $Header: pysidrhi.pkh 120.1 2005/07/05 06:25:39 vikgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_prsi_details_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_object_version_number        in number
  ,p_assignment_id                in number
  ,p_contribution_class           in varchar2
  ,p_overridden_subclass          in varchar2
  ,p_soc_ben_flag                 in varchar2
  ,p_soc_ben_start_date           in date
  ,p_overridden_ins_weeks         in number
  ,p_non_standard_ins_weeks       in number
  ,p_exemption_start_date         in date
  ,p_exemption_end_date           in date
  ,p_cert_issued_by               in varchar2
  ,p_director_flag                in varchar2
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_community_flag               in varchar2
  );
end pay_sid_rki;

 

/
