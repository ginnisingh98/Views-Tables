--------------------------------------------------------
--  DDL for Package PAY_SID_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SID_RKD" AUTHID CURRENT_USER as
/* $Header: pysidrhi.pkh 120.1 2005/07/05 06:25:39 vikgupta noship $ */
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
  ,p_prsi_details_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_object_version_number_o      in number
  ,p_assignment_id_o              in number
  ,p_contribution_class_o         in varchar2
  ,p_overridden_subclass_o        in varchar2
  ,p_soc_ben_flag_o               in varchar2
  ,p_soc_ben_start_date_o         in date
  ,p_overridden_ins_weeks_o       in number
  ,p_non_standard_ins_weeks_o     in number
  ,p_exemption_start_date_o       in date
  ,p_exemption_end_date_o         in date
  ,p_cert_issued_by_o             in varchar2
  ,p_director_flag_o              in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_community_flag_o             in varchar2
  );
--
end pay_sid_rkd;

 

/
