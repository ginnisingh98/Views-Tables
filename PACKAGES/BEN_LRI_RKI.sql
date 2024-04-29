--------------------------------------------------------
--  DDL for Package BEN_LRI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRI_RKI" AUTHID CURRENT_USER as
/* $Header: belrirhi.pkh 120.0 2005/05/28 03:35:25 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_insert >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
Procedure after_insert
	(
		p_ler_extra_info_id		in	number	,
		p_information_type		in	varchar2	,
		p_ler_id				in	number	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_lri_attribute_category	in	varchar2	,
		p_lri_attribute1			in	varchar2	,
		p_lri_attribute2			in	varchar2	,
		p_lri_attribute3			in	varchar2	,
		p_lri_attribute4			in	varchar2	,
		p_lri_attribute5			in	varchar2	,
		p_lri_attribute6			in	varchar2	,
		p_lri_attribute7			in	varchar2	,
		p_lri_attribute8			in	varchar2	,
		p_lri_attribute9			in	varchar2	,
		p_lri_attribute10			in	varchar2	,
		p_lri_attribute11			in	varchar2	,
		p_lri_attribute12			in	varchar2	,
		p_lri_attribute13			in	varchar2	,
		p_lri_attribute14			in	varchar2	,
		p_lri_attribute15			in	varchar2	,
		p_lri_attribute16			in	varchar2	,
		p_lri_attribute17			in	varchar2	,
		p_lri_attribute18			in	varchar2	,
		p_lri_attribute19			in	varchar2	,
		p_lri_attribute20			in	varchar2	,
		p_lri_information_category	in	varchar2	,
		p_lri_information1		in	varchar2	,
		p_lri_information2		in	varchar2	,
		p_lri_information3		in	varchar2	,
		p_lri_information4		in	varchar2	,
		p_lri_information5		in	varchar2	,
		p_lri_information6		in	varchar2	,
		p_lri_information7		in	varchar2	,
		p_lri_information8		in	varchar2	,
		p_lri_information9		in	varchar2	,
		p_lri_information10		in	varchar2	,
		p_lri_information11		in	varchar2	,
		p_lri_information12		in	varchar2	,
		p_lri_information13		in	varchar2	,
		p_lri_information14		in	varchar2	,
		p_lri_information15		in	varchar2	,
		p_lri_information16		in	varchar2	,
		p_lri_information17		in	varchar2	,
		p_lri_information18		in	varchar2	,
		p_lri_information19		in	varchar2	,
		p_lri_information20		in	varchar2	,
		p_lri_information21		in	varchar2	,
		p_lri_information22		in	varchar2	,
		p_lri_information23		in	varchar2	,
		p_lri_information24		in	varchar2	,
		p_lri_information25		in	varchar2	,
		p_lri_information26		in	varchar2	,
		p_lri_information27		in	varchar2	,
		p_lri_information28		in	varchar2	,
		p_lri_information29		in	varchar2	,
		p_lri_information30		in	varchar2
	);

end ben_lri_rki;

 

/
