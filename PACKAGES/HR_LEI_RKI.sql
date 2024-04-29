--------------------------------------------------------
--  DDL for Package HR_LEI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEI_RKI" AUTHID CURRENT_USER as
/* $Header: hrleirhi.pkh 120.0.12000000.1 2007/01/21 17:09:16 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_insert >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
Procedure after_insert
	(
		p_location_extra_info_id	in	number	,
		p_information_type		in	varchar2	,
		p_location_id			in	number	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_lei_attribute_category	in	varchar2	,
		p_lei_attribute1			in	varchar2	,
		p_lei_attribute2			in	varchar2	,
		p_lei_attribute3			in	varchar2	,
		p_lei_attribute4			in	varchar2	,
		p_lei_attribute5			in	varchar2	,
		p_lei_attribute6			in	varchar2	,
		p_lei_attribute7			in	varchar2	,
		p_lei_attribute8			in	varchar2	,
		p_lei_attribute9			in	varchar2	,
		p_lei_attribute10			in	varchar2	,
		p_lei_attribute11			in	varchar2	,
		p_lei_attribute12			in	varchar2	,
		p_lei_attribute13			in	varchar2	,
		p_lei_attribute14			in	varchar2	,
		p_lei_attribute15			in	varchar2	,
		p_lei_attribute16			in	varchar2	,
		p_lei_attribute17			in	varchar2	,
		p_lei_attribute18			in	varchar2	,
		p_lei_attribute19			in	varchar2	,
		p_lei_attribute20			in	varchar2	,
		p_lei_information_category	in	varchar2	,
		p_lei_information1		in	varchar2	,
		p_lei_information2		in	varchar2	,
		p_lei_information3		in	varchar2	,
		p_lei_information4		in	varchar2	,
		p_lei_information5		in	varchar2	,
		p_lei_information6		in	varchar2	,
		p_lei_information7		in	varchar2	,
		p_lei_information8		in	varchar2	,
		p_lei_information9		in	varchar2	,
		p_lei_information10		in	varchar2	,
		p_lei_information11		in	varchar2	,
		p_lei_information12		in	varchar2	,
		p_lei_information13		in	varchar2	,
		p_lei_information14		in	varchar2	,
		p_lei_information15		in	varchar2	,
		p_lei_information16		in	varchar2	,
		p_lei_information17		in	varchar2	,
		p_lei_information18		in	varchar2	,
		p_lei_information19		in	varchar2	,
		p_lei_information20		in	varchar2	,
		p_lei_information21		in	varchar2	,
		p_lei_information22		in	varchar2	,
		p_lei_information23		in	varchar2	,
		p_lei_information24		in	varchar2	,
		p_lei_information25		in	varchar2	,
		p_lei_information26		in	varchar2	,
		p_lei_information27		in	varchar2	,
		p_lei_information28		in	varchar2	,
		p_lei_information29		in	varchar2	,
		p_lei_information30		in	varchar2
	);

end hr_lei_rki;

 

/
