--------------------------------------------------------
--  DDL for Package IRC_IRF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IRF_RKI" AUTHID CURRENT_USER as
/* $Header: irirfrhi.pkh 120.1 2008/04/16 07:34:00 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--

procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_referral_info_id             in number
  ,p_object_id                    in number
  ,p_object_type                  in varchar2
  ,p_start_date                   in date
  ,p_end_date            	      in date
  ,p_source_type            	  in varchar2
  ,p_source_name            	  in varchar2
  ,p_source_criteria1             in varchar2
  ,p_source_value1            	  in varchar2
  ,p_source_criteria2             in varchar2
  ,p_source_value2            	  in varchar2
  ,p_source_criteria3             in varchar2
  ,p_source_value3                in varchar2
  ,p_source_criteria4             in varchar2
  ,p_source_value4                in varchar2
  ,p_source_criteria5             in varchar2
  ,p_source_value5                in varchar2
  ,p_source_person_id             in number
  ,p_candidate_comment            in varchar2
  ,p_employee_comment             in varchar2
  ,p_irf_attribute_category       in varchar2
  ,p_irf_attribute1               in varchar2
  ,p_irf_attribute2               in varchar2
  ,p_irf_attribute3               in varchar2
  ,p_irf_attribute4               in varchar2
  ,p_irf_attribute5               in varchar2
  ,p_irf_attribute6               in varchar2
  ,p_irf_attribute7               in varchar2
  ,p_irf_attribute8               in varchar2
  ,p_irf_attribute9               in varchar2
  ,p_irf_attribute10              in varchar2
  ,p_irf_information_category     in varchar2
  ,p_irf_information1             in varchar2
  ,p_irf_information2             in varchar2
  ,p_irf_information3             in varchar2
  ,p_irf_information4             in varchar2
  ,p_irf_information5             in varchar2
  ,p_irf_information6             in varchar2
  ,p_irf_information7             in varchar2
  ,p_irf_information8             in varchar2
  ,p_irf_information9             in varchar2
  ,p_irf_information10            in varchar2
  ,p_object_created_by            in varchar2
  ,p_created_by                   in number
  ,p_object_version_number        in number
  );
end irc_irf_rki;

/
