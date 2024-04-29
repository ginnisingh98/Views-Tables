--------------------------------------------------------
--  DDL for Package PER_EST_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EST_RKI" AUTHID CURRENT_USER as
/* $Header: peestrhi.pkh 120.0.12010000.1 2008/07/28 04:39:11 appldev ship $ */
--
-- ------------------------------------------------------------------------------
-- |---------------------------------< after_insert >-----------------------------|
-- ------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- This procedure is for the row handler user hook. The package body is generated.
--
--
procedure after_insert
  (p_establishment_id             in number
  ,p_name                         in varchar2
  ,p_location                     in varchar2
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2,
	p_est_information_category            in varchar2,
	p_est_information1                    in varchar2,
	p_est_information2                    in varchar2,
	p_est_information3                    in varchar2,
	p_est_information4                    in varchar2,
	p_est_information5                    in varchar2,
	p_est_information6                    in varchar2,
	p_est_information7                    in varchar2,
	p_est_information8                    in varchar2,
	p_est_information9                    in varchar2,
	p_est_information10                   in varchar2,
	p_est_information11                   in varchar2,
	p_est_information12                   in varchar2,
	p_est_information13                   in varchar2,
	p_est_information14                   in varchar2,
	p_est_information15                   in varchar2,
	p_est_information16                   in varchar2,
	p_est_information17                   in varchar2,
	p_est_information18                   in varchar2,
	p_est_information19                   in varchar2,
	p_est_information20                   in varchar2
  ,p_object_version_number        in number
   );
end per_est_rki;

/
