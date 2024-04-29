--------------------------------------------------------
--  DDL for Package PER_REI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REI_RKI" AUTHID CURRENT_USER as
/* $Header: pereirhi.pkh 120.0 2005/05/31 17:34:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_contact_extra_info_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_contact_relationship_id      in number
  ,p_information_type             in varchar2
  ,p_cei_information_category     in varchar2
  ,p_cei_information1             in varchar2
  ,p_cei_information2             in varchar2
  ,p_cei_information3             in varchar2
  ,p_cei_information4             in varchar2
  ,p_cei_information5             in varchar2
  ,p_cei_information6             in varchar2
  ,p_cei_information7             in varchar2
  ,p_cei_information8             in varchar2
  ,p_cei_information9             in varchar2
  ,p_cei_information10            in varchar2
  ,p_cei_information11            in varchar2
  ,p_cei_information12            in varchar2
  ,p_cei_information13            in varchar2
  ,p_cei_information14            in varchar2
  ,p_cei_information15            in varchar2
  ,p_cei_information16            in varchar2
  ,p_cei_information17            in varchar2
  ,p_cei_information18            in varchar2
  ,p_cei_information19            in varchar2
  ,p_cei_information20            in varchar2
  ,p_cei_information21            in varchar2
  ,p_cei_information22            in varchar2
  ,p_cei_information23            in varchar2
  ,p_cei_information24            in varchar2
  ,p_cei_information25            in varchar2
  ,p_cei_information26            in varchar2
  ,p_cei_information27            in varchar2
  ,p_cei_information28            in varchar2
  ,p_cei_information29            in varchar2
  ,p_cei_information30            in varchar2
  ,p_cei_attribute_category       in varchar2
  ,p_cei_attribute1               in varchar2
  ,p_cei_attribute2               in varchar2
  ,p_cei_attribute3               in varchar2
  ,p_cei_attribute4               in varchar2
  ,p_cei_attribute5               in varchar2
  ,p_cei_attribute6               in varchar2
  ,p_cei_attribute7               in varchar2
  ,p_cei_attribute8               in varchar2
  ,p_cei_attribute9               in varchar2
  ,p_cei_attribute10              in varchar2
  ,p_cei_attribute11              in varchar2
  ,p_cei_attribute12              in varchar2
  ,p_cei_attribute13              in varchar2
  ,p_cei_attribute14              in varchar2
  ,p_cei_attribute15              in varchar2
  ,p_cei_attribute16              in varchar2
  ,p_cei_attribute17              in varchar2
  ,p_cei_attribute18              in varchar2
  ,p_cei_attribute19              in varchar2
  ,p_cei_attribute20              in varchar2
  ,p_object_version_number        in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  );
end per_rei_rki;

 

/
