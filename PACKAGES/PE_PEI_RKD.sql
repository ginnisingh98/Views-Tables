--------------------------------------------------------
--  DDL for Package PE_PEI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_PEI_RKD" AUTHID CURRENT_USER as
/* $Header: pepeirhi.pkh 120.0 2005/05/31 13:21:30 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
	(
		p_person_extra_info_id_o	in	number	,
		p_person_id_o			in	number	,
		p_information_type_o		in	varchar2	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_pei_attribute_category_o	in	varchar2	,
		p_pei_attribute1_o		in	varchar2	,
		p_pei_attribute2_o		in	varchar2	,
		p_pei_attribute3_o		in	varchar2	,
		p_pei_attribute4_o		in	varchar2	,
		p_pei_attribute5_o		in	varchar2	,
		p_pei_attribute6_o		in	varchar2	,
		p_pei_attribute7_o		in	varchar2	,
		p_pei_attribute8_o		in	varchar2	,
		p_pei_attribute9_o		in	varchar2	,
		p_pei_attribute10_o		in	varchar2	,
		p_pei_attribute11_o		in	varchar2	,
		p_pei_attribute12_o		in	varchar2	,
		p_pei_attribute13_o		in	varchar2	,
		p_pei_attribute14_o		in	varchar2	,
		p_pei_attribute15_o		in	varchar2	,
		p_pei_attribute16_o		in	varchar2	,
		p_pei_attribute17_o		in	varchar2	,
		p_pei_attribute18_o		in	varchar2	,
		p_pei_attribute19_o		in	varchar2	,
		p_pei_attribute20_o		in	varchar2	,
		p_pei_information_category_o	in	varchar2	,
		p_pei_information1_o		in	varchar2	,
		p_pei_information2_o		in	varchar2	,
		p_pei_information3_o		in	varchar2	,
		p_pei_information4_o		in	varchar2	,
		p_pei_information5_o		in	varchar2	,
		p_pei_information6_o		in	varchar2	,
		p_pei_information7_o		in	varchar2	,
		p_pei_information8_o		in	varchar2	,
		p_pei_information9_o		in	varchar2	,
		p_pei_information10_o		in	varchar2	,
		p_pei_information11_o		in	varchar2	,
		p_pei_information12_o		in	varchar2	,
		p_pei_information13_o		in	varchar2	,
		p_pei_information14_o		in	varchar2	,
		p_pei_information15_o		in	varchar2	,
		p_pei_information16_o		in	varchar2	,
		p_pei_information17_o		in	varchar2	,
		p_pei_information18_o		in	varchar2	,
		p_pei_information19_o		in	varchar2	,
		p_pei_information20_o		in	varchar2	,
		p_pei_information21_o		in	varchar2	,
		p_pei_information22_o		in	varchar2	,
		p_pei_information23_o		in	varchar2	,
		p_pei_information24_o		in	varchar2	,
		p_pei_information25_o		in	varchar2	,
		p_pei_information26_o		in	varchar2	,
		p_pei_information27_o		in	varchar2	,
		p_pei_information28_o		in	varchar2	,
		p_pei_information29_o		in	varchar2	,
		p_pei_information30_o		in	varchar2
	);

end pe_pei_rkd;

 

/
