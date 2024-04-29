--------------------------------------------------------
--  DDL for Package PQP_VAI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VAI_RKI" AUTHID CURRENT_USER as
/* $Header: pqvairhi.pkh 120.0.12010000.2 2008/08/08 07:19:40 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_veh_alloc_extra_info_id      in number
  ,p_vehicle_allocation_id        in number
  ,p_information_type             in varchar2
  ,p_vaei_attribute_category      in varchar2
  ,p_vaei_attribute1              in varchar2
  ,p_vaei_attribute2              in varchar2
  ,p_vaei_attribute3              in varchar2
  ,p_vaei_attribute4              in varchar2
  ,p_vaei_attribute5              in varchar2
  ,p_vaei_attribute6              in varchar2
  ,p_vaei_attribute7              in varchar2
  ,p_vaei_attribute8              in varchar2
  ,p_vaei_attribute9              in varchar2
  ,p_vaei_attribute10             in varchar2
  ,p_vaei_attribute11             in varchar2
  ,p_vaei_attribute12             in varchar2
  ,p_vaei_attribute13             in varchar2
  ,p_vaei_attribute14             in varchar2
  ,p_vaei_attribute15             in varchar2
  ,p_vaei_attribute16             in varchar2
  ,p_vaei_attribute17             in varchar2
  ,p_vaei_attribute18             in varchar2
  ,p_vaei_attribute19             in varchar2
  ,p_vaei_attribute20             in varchar2
  ,p_vaei_information_category    in varchar2
  ,p_vaei_information1            in varchar2
  ,p_vaei_information2            in varchar2
  ,p_vaei_information3            in varchar2
  ,p_vaei_information4            in varchar2
  ,p_vaei_information5            in varchar2
  ,p_vaei_information6            in varchar2
  ,p_vaei_information7            in varchar2
  ,p_vaei_information8            in varchar2
  ,p_vaei_information9            in varchar2
  ,p_vaei_information10           in varchar2
  ,p_vaei_information11           in varchar2
  ,p_vaei_information12           in varchar2
  ,p_vaei_information13           in varchar2
  ,p_vaei_information14           in varchar2
  ,p_vaei_information15           in varchar2
  ,p_vaei_information16           in varchar2
  ,p_vaei_information17           in varchar2
  ,p_vaei_information18           in varchar2
  ,p_vaei_information19           in varchar2
  ,p_vaei_information20           in varchar2
  ,p_vaei_information21           in varchar2
  ,p_vaei_information22           in varchar2
  ,p_vaei_information23           in varchar2
  ,p_vaei_information24           in varchar2
  ,p_vaei_information25           in varchar2
  ,p_vaei_information26           in varchar2
  ,p_vaei_information27           in varchar2
  ,p_vaei_information28           in varchar2
  ,p_vaei_information29           in varchar2
  ,p_vaei_information30           in varchar2
  ,p_object_version_number        in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  );
end pqp_vai_rki;

/
