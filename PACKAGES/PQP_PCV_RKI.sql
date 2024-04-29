--------------------------------------------------------
--  DDL for Package PQP_PCV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PCV_RKI" AUTHID CURRENT_USER as
/* $Header: pqpcvrhi.pkh 120.0 2005/05/29 01:55:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_configuration_value_id       in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_pcv_attribute_category       in varchar2
  ,p_pcv_attribute1               in varchar2
  ,p_pcv_attribute2               in varchar2
  ,p_pcv_attribute3               in varchar2
  ,p_pcv_attribute4               in varchar2
  ,p_pcv_attribute5               in varchar2
  ,p_pcv_attribute6               in varchar2
  ,p_pcv_attribute7               in varchar2
  ,p_pcv_attribute8               in varchar2
  ,p_pcv_attribute9               in varchar2
  ,p_pcv_attribute10              in varchar2
  ,p_pcv_attribute11              in varchar2
  ,p_pcv_attribute12              in varchar2
  ,p_pcv_attribute13              in varchar2
  ,p_pcv_attribute14              in varchar2
  ,p_pcv_attribute15              in varchar2
  ,p_pcv_attribute16              in varchar2
  ,p_pcv_attribute17              in varchar2
  ,p_pcv_attribute18              in varchar2
  ,p_pcv_attribute19              in varchar2
  ,p_pcv_attribute20              in varchar2
  ,p_pcv_information_category     in varchar2
  ,p_pcv_information1             in varchar2
  ,p_pcv_information2             in varchar2
  ,p_pcv_information3             in varchar2
  ,p_pcv_information4             in varchar2
  ,p_pcv_information5             in varchar2
  ,p_pcv_information6             in varchar2
  ,p_pcv_information7             in varchar2
  ,p_pcv_information8             in varchar2
  ,p_pcv_information9             in varchar2
  ,p_pcv_information10            in varchar2
  ,p_pcv_information11            in varchar2
  ,p_pcv_information12            in varchar2
  ,p_pcv_information13            in varchar2
  ,p_pcv_information14            in varchar2
  ,p_pcv_information15            in varchar2
  ,p_pcv_information16            in varchar2
  ,p_pcv_information17            in varchar2
  ,p_pcv_information18            in varchar2
  ,p_pcv_information19            in varchar2
  ,p_pcv_information20            in varchar2
  ,p_object_version_number        in number
  ,p_configuration_name           in varchar2
  );
end pqp_pcv_rki;

 

/
