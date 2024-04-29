--------------------------------------------------------
--  DDL for Package BEN_OPI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPI_RKI" AUTHID CURRENT_USER as
/* $Header: beopirhi.pkh 120.0 2005/05/28 09:53:29 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_insert >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handopt user hook. The package body is generated.
Procedure after_insert
	(
		p_opt_extra_info_id		in	number	,
		p_information_type		in	varchar2	,
		p_opt_id				in	number	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_opi_attribute_category	in	varchar2	,
		p_opi_attribute1			in	varchar2	,
		p_opi_attribute2			in	varchar2	,
		p_opi_attribute3			in	varchar2	,
		p_opi_attribute4			in	varchar2	,
		p_opi_attribute5			in	varchar2	,
		p_opi_attribute6			in	varchar2	,
		p_opi_attribute7			in	varchar2	,
		p_opi_attribute8			in	varchar2	,
		p_opi_attribute9			in	varchar2	,
		p_opi_attribute10			in	varchar2	,
		p_opi_attribute11			in	varchar2	,
		p_opi_attribute12			in	varchar2	,
		p_opi_attribute13			in	varchar2	,
		p_opi_attribute14			in	varchar2	,
		p_opi_attribute15			in	varchar2	,
		p_opi_attribute16			in	varchar2	,
		p_opi_attribute17			in	varchar2	,
		p_opi_attribute18			in	varchar2	,
		p_opi_attribute19			in	varchar2	,
		p_opi_attribute20			in	varchar2	,
		p_opi_information_category	in	varchar2	,
		p_opi_information1		in	varchar2	,
		p_opi_information2		in	varchar2	,
		p_opi_information3		in	varchar2	,
		p_opi_information4		in	varchar2	,
		p_opi_information5		in	varchar2	,
		p_opi_information6		in	varchar2	,
		p_opi_information7		in	varchar2	,
		p_opi_information8		in	varchar2	,
		p_opi_information9		in	varchar2	,
		p_opi_information10		in	varchar2	,
		p_opi_information11		in	varchar2	,
		p_opi_information12		in	varchar2	,
		p_opi_information13		in	varchar2	,
		p_opi_information14		in	varchar2	,
		p_opi_information15		in	varchar2	,
		p_opi_information16		in	varchar2	,
		p_opi_information17		in	varchar2	,
		p_opi_information18		in	varchar2	,
		p_opi_information19		in	varchar2	,
		p_opi_information20		in	varchar2	,
		p_opi_information21		in	varchar2	,
		p_opi_information22		in	varchar2	,
		p_opi_information23		in	varchar2	,
		p_opi_information24		in	varchar2	,
		p_opi_information25		in	varchar2	,
		p_opi_information26		in	varchar2	,
		p_opi_information27		in	varchar2	,
		p_opi_information28		in	varchar2	,
		p_opi_information29		in	varchar2	,
		p_opi_information30		in	varchar2
	);

end ben_opi_rki;

 

/