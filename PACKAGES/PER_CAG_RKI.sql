--------------------------------------------------------
--  DDL for Package PER_CAG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAG_RKI" AUTHID CURRENT_USER as
/* $Header: pecagrhi.pkh 120.0 2005/05/31 06:22:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  ( p_collective_agreement_id      in number,
    p_business_group_id            in number,
    p_object_version_number        in number,
    p_name                         in varchar2,
	p_pl_id                        in number,
	p_status                       in varchar2,
    p_cag_number                   in number,
    p_description                  in varchar2,
    p_start_date                   in date,
    p_end_date                     in date,
    p_employer_organization_id     in number,
    p_employer_signatory           in varchar2,
    p_bargaining_organization_id   in number,
    p_bargaining_unit_signatory    in varchar2,
    p_jurisdiction                 in varchar2,
    p_authorizing_body             in varchar2,
    p_authorized_date              in date,
    p_cag_information_category     in varchar2,
    p_cag_information1             in varchar2,
    p_cag_information2             in varchar2,
    p_cag_information3             in varchar2,
    p_cag_information4             in varchar2,
    p_cag_information5             in varchar2,
    p_cag_information6             in varchar2,
    p_cag_information7             in varchar2,
    p_cag_information8             in varchar2,
    p_cag_information9             in varchar2,
    p_cag_information10            in varchar2,
    p_cag_information11            in varchar2,
    p_cag_information12            in varchar2,
    p_cag_information13            in varchar2,
    p_cag_information14            in varchar2,
    p_cag_information15            in varchar2,
    p_cag_information16            in varchar2,
    p_cag_information17            in varchar2,
    p_cag_information18            in varchar2,
    p_cag_information19            in varchar2,
    p_cag_information20            in varchar2,
    p_attribute_category           in varchar2,
    p_attribute1                   in varchar2,
    p_attribute2                   in varchar2,
    p_attribute3                   in varchar2,
    p_attribute4                   in varchar2,
    p_attribute5                   in varchar2,
    p_attribute6                   in varchar2,
    p_attribute7                   in varchar2,
    p_attribute8                   in varchar2,
    p_attribute9                   in varchar2,
    p_attribute10                  in varchar2,
    p_attribute11                  in varchar2,
    p_attribute12                  in varchar2,
    p_attribute13                  in varchar2,
    p_attribute14                  in varchar2,
    p_attribute15                  in varchar2,
    p_attribute16                  in varchar2,
    p_attribute17                  in varchar2,
    p_attribute18                  in varchar2,
    p_attribute19                  in varchar2,
    p_attribute20                  in varchar2
  );
end per_cag_rki;

 

/
