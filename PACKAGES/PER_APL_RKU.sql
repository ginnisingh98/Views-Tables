--------------------------------------------------------
--  DDL for Package PER_APL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APL_RKU" AUTHID CURRENT_USER as
/* $Header: peaplrhi.pkh 120.1 2005/10/25 00:30:44 risgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_application_id                 in number
  ,p_date_received                  in date
  ,p_comments                       in varchar2
  ,p_current_employer               in varchar2
  ,p_projected_hire_date            in date
  ,p_successful_flag                in varchar2
  ,p_termination_reason             in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  ,p_appl_attribute_category        in varchar2
  ,p_appl_attribute1                in varchar2
  ,p_appl_attribute2                in varchar2
  ,p_appl_attribute3                in varchar2
  ,p_appl_attribute4                in varchar2
  ,p_appl_attribute5                in varchar2
  ,p_appl_attribute6                in varchar2
  ,p_appl_attribute7                in varchar2
  ,p_appl_attribute8                in varchar2
  ,p_appl_attribute9                in varchar2
  ,p_appl_attribute10               in varchar2
  ,p_appl_attribute11               in varchar2
  ,p_appl_attribute12               in varchar2
  ,p_appl_attribute13               in varchar2
  ,p_appl_attribute14               in varchar2
  ,p_appl_attribute15               in varchar2
  ,p_appl_attribute16               in varchar2
  ,p_appl_attribute17               in varchar2
  ,p_appl_attribute18               in varchar2
  ,p_appl_attribute19               in varchar2
  ,p_appl_attribute20               in varchar2
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  ,p_business_group_id_o            in number
  ,p_person_id_o                    in number
  ,p_date_received_o                in date
  ,p_comments_o                     in varchar2
  ,p_current_employer_o             in varchar2
  ,p_projected_hire_date_o          in date
  ,p_successful_flag_o              in varchar2
  ,p_termination_reason_o           in varchar2
  ,p_request_id_o                   in number
  ,p_program_application_id_o       in number
  ,p_program_id_o                   in number
  ,p_program_update_date_o          in date
  ,p_appl_attribute_category_o      in varchar2
  ,p_appl_attribute1_o              in varchar2
  ,p_appl_attribute2_o              in varchar2
  ,p_appl_attribute3_o              in varchar2
  ,p_appl_attribute4_o              in varchar2
  ,p_appl_attribute5_o              in varchar2
  ,p_appl_attribute6_o              in varchar2
  ,p_appl_attribute7_o              in varchar2
  ,p_appl_attribute8_o              in varchar2
  ,p_appl_attribute9_o              in varchar2
  ,p_appl_attribute10_o             in varchar2
  ,p_appl_attribute11_o             in varchar2
  ,p_appl_attribute12_o             in varchar2
  ,p_appl_attribute13_o             in varchar2
  ,p_appl_attribute14_o             in varchar2
  ,p_appl_attribute15_o             in varchar2
  ,p_appl_attribute16_o             in varchar2
  ,p_appl_attribute17_o             in varchar2
  ,p_appl_attribute18_o             in varchar2
  ,p_appl_attribute19_o             in varchar2
  ,p_appl_attribute20_o             in varchar2
  ,p_object_version_number_o        in number
  );
end per_apl_rku;

 

/
