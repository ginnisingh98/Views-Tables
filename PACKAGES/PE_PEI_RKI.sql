--------------------------------------------------------
--  DDL for Package PE_PEI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_PEI_RKI" AUTHID CURRENT_USER as
/* $Header: pepeirhi.pkh 120.0 2005/05/31 13:21:30 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_insert >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
Procedure after_insert
	(
		p_person_extra_info_id		in	number	,
		p_person_id				in	number	,
		p_information_type		in	varchar2	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_pei_attribute_category	in	varchar2	,
		p_pei_attribute1			in	varchar2	,
		p_pei_attribute2			in	varchar2	,
		p_pei_attribute3			in	varchar2	,
		p_pei_attribute4			in	varchar2	,
		p_pei_attribute5			in	varchar2	,
		p_pei_attribute6			in	varchar2	,
		p_pei_attribute7			in	varchar2	,
		p_pei_attribute8			in	varchar2	,
		p_pei_attribute9			in	varchar2	,
		p_pei_attribute10			in	varchar2	,
		p_pei_attribute11			in	varchar2	,
		p_pei_attribute12			in	varchar2	,
		p_pei_attribute13			in	varchar2	,
		p_pei_attribute14			in	varchar2	,
		p_pei_attribute15			in	varchar2	,
		p_pei_attribute16			in	varchar2	,
		p_pei_attribute17			in	varchar2	,
		p_pei_attribute18			in	varchar2	,
		p_pei_attribute19			in	varchar2	,
		p_pei_attribute20			in	varchar2	,
		p_pei_information_category	in	varchar2	,
		p_pei_information1		in	varchar2	,
		p_pei_information2		in	varchar2	,
		p_pei_information3		in	varchar2	,
		p_pei_information4		in	varchar2	,
		p_pei_information5		in	varchar2	,
		p_pei_information6		in	varchar2	,
		p_pei_information7		in	varchar2	,
		p_pei_information8		in	varchar2	,
		p_pei_information9		in	varchar2	,
		p_pei_information10		in	varchar2	,
		p_pei_information11		in	varchar2	,
		p_pei_information12		in	varchar2	,
		p_pei_information13		in	varchar2	,
		p_pei_information14		in	varchar2	,
		p_pei_information15		in	varchar2	,
		p_pei_information16		in	varchar2	,
		p_pei_information17		in	varchar2	,
		p_pei_information18		in	varchar2	,
		p_pei_information19		in	varchar2	,
		p_pei_information20		in	varchar2	,
		p_pei_information21		in	varchar2	,
		p_pei_information22		in	varchar2	,
		p_pei_information23		in	varchar2	,
		p_pei_information24		in	varchar2	,
		p_pei_information25		in	varchar2	,
		p_pei_information26		in	varchar2	,
		p_pei_information27		in	varchar2	,
		p_pei_information28		in	varchar2	,
		p_pei_information29		in	varchar2	,
		p_pei_information30		in	varchar2
	);

end pe_pei_rki;

 

/
