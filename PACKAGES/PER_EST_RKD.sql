--------------------------------------------------------
--  DDL for Package PER_EST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EST_RKD" AUTHID CURRENT_USER as
/* $Header: peestrhi.pkh 120.0.12010000.1 2008/07/28 04:39:11 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
  (p_establishment_id             in number
  ,p_name_o                       in varchar2
  ,p_location_o                   in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2,
	p_est_information_category_o            in varchar2,
	p_est_information1_o                    in varchar2,
	p_est_information2_o                    in varchar2,
	p_est_information3_o                    in varchar2,
	p_est_information4_o                    in varchar2,
	p_est_information5_o                    in varchar2,
	p_est_information6_o                    in varchar2,
	p_est_information7_o                    in varchar2,
	p_est_information8_o                    in varchar2,
	p_est_information9_o                    in varchar2,
	p_est_information10_o                   in varchar2,
	p_est_information11_o                   in varchar2,
	p_est_information12_o                   in varchar2,
	p_est_information13_o                   in varchar2,
	p_est_information14_o                   in varchar2,
	p_est_information15_o                   in varchar2,
	p_est_information16_o                   in varchar2,
	p_est_information17_o                   in varchar2,
	p_est_information18_o                   in varchar2,
	p_est_information19_o                   in varchar2,
	p_est_information20_o                   in varchar2
  ,p_object_version_number_o      in number
   );
end per_est_rkd;

/
