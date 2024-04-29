--------------------------------------------------------
--  DDL for Package PQP_SHP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SHP_RKI" AUTHID CURRENT_USER as
/* $Header: pqshprhi.pkh 120.0.12010000.1 2008/07/28 11:23:18 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_service_history_period_id    in number
  ,p_business_group_id            in number
  ,p_assignment_id                in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_employer_name                in varchar2
  ,p_employer_address             in varchar2
  ,p_employer_type                in varchar2
  ,p_employer_subtype             in varchar2
  ,p_period_years                 in number
  ,p_period_days                  in number
  ,p_description                  in varchar2
  ,p_continuous_service           in varchar2
  ,p_all_assignments              in varchar2
  ,p_object_version_number        in number
  ,p_shp_attribute_category       in varchar2
  ,p_shp_attribute1               in varchar2
  ,p_shp_attribute2               in varchar2
  ,p_shp_attribute3               in varchar2
  ,p_shp_attribute4               in varchar2
  ,p_shp_attribute5               in varchar2
  ,p_shp_attribute6               in varchar2
  ,p_shp_attribute7               in varchar2
  ,p_shp_attribute8               in varchar2
  ,p_shp_attribute9               in varchar2
  ,p_shp_attribute10              in varchar2
  ,p_shp_attribute11              in varchar2
  ,p_shp_attribute12              in varchar2
  ,p_shp_attribute13              in varchar2
  ,p_shp_attribute14              in varchar2
  ,p_shp_attribute15              in varchar2
  ,p_shp_attribute16              in varchar2
  ,p_shp_attribute17              in varchar2
  ,p_shp_attribute18              in varchar2
  ,p_shp_attribute19              in varchar2
  ,p_shp_attribute20              in varchar2
  ,p_shp_information_category     in varchar2
  ,p_shp_information1             in varchar2
  ,p_shp_information2             in varchar2
  ,p_shp_information3             in varchar2
  ,p_shp_information4             in varchar2
  ,p_shp_information5             in varchar2
  ,p_shp_information6             in varchar2
  ,p_shp_information7             in varchar2
  ,p_shp_information8             in varchar2
  ,p_shp_information9             in varchar2
  ,p_shp_information10            in varchar2
  ,p_shp_information11            in varchar2
  ,p_shp_information12            in varchar2
  ,p_shp_information13            in varchar2
  ,p_shp_information14            in varchar2
  ,p_shp_information15            in varchar2
  ,p_shp_information16            in varchar2
  ,p_shp_information17            in varchar2
  ,p_shp_information18            in varchar2
  ,p_shp_information19            in varchar2
  ,p_shp_information20            in varchar2
  );
end pqp_shp_rki;

/
