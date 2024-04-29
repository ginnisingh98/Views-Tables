--------------------------------------------------------
--  DDL for Package PER_SPP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SPP_RKI" AUTHID CURRENT_USER as
/* $Header: pespprhi.pkh 120.1 2005/12/12 21:15:29 vbanner noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_placement_id                 in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_business_group_id            in number
  ,p_assignment_id                in number
  ,p_step_id                      in number
  ,p_auto_increment_flag          in varchar2
  ,p_parent_spine_id              in number
  ,p_reason                       in varchar2
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_increment_number             in number
  ,p_object_version_number        in number
  ,p_information1                 in varchar2
  ,p_information2                 in varchar2
  ,p_information3                 in varchar2
  ,p_information4                 in varchar2
  ,p_information5                 in varchar2
  ,p_information6                 in varchar2
  ,p_information7                 in varchar2
  ,p_information8                 in varchar2
  ,p_information9                 in varchar2
  ,p_information10                in varchar2
  ,p_information11                in varchar2
  ,p_information12                in varchar2
  ,p_information13                in varchar2
  ,p_information14                in varchar2
  ,p_information15                in varchar2
  ,p_information16                in varchar2
  ,p_information17                in varchar2
  ,p_information18                in varchar2
  ,p_information19                in varchar2
  ,p_information20                in varchar2
  ,p_information21                in varchar2
  ,p_information22                in varchar2
  ,p_information23                in varchar2
  ,p_information24                in varchar2
  ,p_information25                in varchar2
  ,p_information26                in varchar2
  ,p_information27                in varchar2
  ,p_information28                in varchar2
  ,p_information29                in varchar2
  ,p_information30                in varchar2
  ,p_information_category         in varchar2
  );
end per_spp_rki;

 

/
