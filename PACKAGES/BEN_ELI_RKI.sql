--------------------------------------------------------
--  DDL for Package BEN_ELI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELI_RKI" AUTHID CURRENT_USER as
/* $Header: beelirhi.pkh 120.0 2005/05/28 02:18:37 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_insert >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handelp user hook. The package body is generated.
Procedure after_insert
	(
		p_elp_extra_info_id		in	number	,
		p_information_type		in	varchar2	,
		p_eligy_prfl_id				in	number	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_eli_attribute_category	in	varchar2	,
		p_eli_attribute1			in	varchar2	,
		p_eli_attribute2			in	varchar2	,
		p_eli_attribute3			in	varchar2	,
		p_eli_attribute4			in	varchar2	,
		p_eli_attribute5			in	varchar2	,
		p_eli_attribute6			in	varchar2	,
		p_eli_attribute7			in	varchar2	,
		p_eli_attribute8			in	varchar2	,
		p_eli_attribute9			in	varchar2	,
		p_eli_attribute10			in	varchar2	,
		p_eli_attribute11			in	varchar2	,
		p_eli_attribute12			in	varchar2	,
		p_eli_attribute13			in	varchar2	,
		p_eli_attribute14			in	varchar2	,
		p_eli_attribute15			in	varchar2	,
		p_eli_attribute16			in	varchar2	,
		p_eli_attribute17			in	varchar2	,
		p_eli_attribute18			in	varchar2	,
		p_eli_attribute19			in	varchar2	,
		p_eli_attribute20			in	varchar2	,
		p_eli_information_category	in	varchar2	,
		p_eli_information1		in	varchar2	,
		p_eli_information2		in	varchar2	,
		p_eli_information3		in	varchar2	,
		p_eli_information4		in	varchar2	,
		p_eli_information5		in	varchar2	,
		p_eli_information6		in	varchar2	,
		p_eli_information7		in	varchar2	,
		p_eli_information8		in	varchar2	,
		p_eli_information9		in	varchar2	,
		p_eli_information10		in	varchar2	,
		p_eli_information11		in	varchar2	,
		p_eli_information12		in	varchar2	,
		p_eli_information13		in	varchar2	,
		p_eli_information14		in	varchar2	,
		p_eli_information15		in	varchar2	,
		p_eli_information16		in	varchar2	,
		p_eli_information17		in	varchar2	,
		p_eli_information18		in	varchar2	,
		p_eli_information19		in	varchar2	,
		p_eli_information20		in	varchar2	,
		p_eli_information21		in	varchar2	,
		p_eli_information22		in	varchar2	,
		p_eli_information23		in	varchar2	,
		p_eli_information24		in	varchar2	,
		p_eli_information25		in	varchar2	,
		p_eli_information26		in	varchar2	,
		p_eli_information27		in	varchar2	,
		p_eli_information28		in	varchar2	,
		p_eli_information29		in	varchar2	,
		p_eli_information30		in	varchar2
	);

end ben_eli_rki;

 

/
