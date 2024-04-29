--------------------------------------------------------
--  DDL for Package BEN_PGI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGI_RKI" AUTHID CURRENT_USER as
/* $Header: bepgirhi.pkh 120.0 2005/05/28 10:46:19 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_insert >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handpgm user hook. The package body is generated.
Procedure after_insert
	(
		p_pgm_extra_info_id		in	number	,
		p_information_type		in	varchar2	,
		p_pgm_id				in	number	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_pgi_attribute_category	in	varchar2	,
		p_pgi_attribute1			in	varchar2	,
		p_pgi_attribute2			in	varchar2	,
		p_pgi_attribute3			in	varchar2	,
		p_pgi_attribute4			in	varchar2	,
		p_pgi_attribute5			in	varchar2	,
		p_pgi_attribute6			in	varchar2	,
		p_pgi_attribute7			in	varchar2	,
		p_pgi_attribute8			in	varchar2	,
		p_pgi_attribute9			in	varchar2	,
		p_pgi_attribute10			in	varchar2	,
		p_pgi_attribute11			in	varchar2	,
		p_pgi_attribute12			in	varchar2	,
		p_pgi_attribute13			in	varchar2	,
		p_pgi_attribute14			in	varchar2	,
		p_pgi_attribute15			in	varchar2	,
		p_pgi_attribute16			in	varchar2	,
		p_pgi_attribute17			in	varchar2	,
		p_pgi_attribute18			in	varchar2	,
		p_pgi_attribute19			in	varchar2	,
		p_pgi_attribute20			in	varchar2	,
		p_pgi_information_category	in	varchar2	,
		p_pgi_information1		in	varchar2	,
		p_pgi_information2		in	varchar2	,
		p_pgi_information3		in	varchar2	,
		p_pgi_information4		in	varchar2	,
		p_pgi_information5		in	varchar2	,
		p_pgi_information6		in	varchar2	,
		p_pgi_information7		in	varchar2	,
		p_pgi_information8		in	varchar2	,
		p_pgi_information9		in	varchar2	,
		p_pgi_information10		in	varchar2	,
		p_pgi_information11		in	varchar2	,
		p_pgi_information12		in	varchar2	,
		p_pgi_information13		in	varchar2	,
		p_pgi_information14		in	varchar2	,
		p_pgi_information15		in	varchar2	,
		p_pgi_information16		in	varchar2	,
		p_pgi_information17		in	varchar2	,
		p_pgi_information18		in	varchar2	,
		p_pgi_information19		in	varchar2	,
		p_pgi_information20		in	varchar2	,
		p_pgi_information21		in	varchar2	,
		p_pgi_information22		in	varchar2	,
		p_pgi_information23		in	varchar2	,
		p_pgi_information24		in	varchar2	,
		p_pgi_information25		in	varchar2	,
		p_pgi_information26		in	varchar2	,
		p_pgi_information27		in	varchar2	,
		p_pgi_information28		in	varchar2	,
		p_pgi_information29		in	varchar2	,
		p_pgi_information30		in	varchar2
	);

end ben_pgi_rki;

 

/
