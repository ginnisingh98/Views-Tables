--------------------------------------------------------
--  DDL for Package PE_JEI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_JEI_RKD" AUTHID CURRENT_USER as
/* $Header: pejeirhi.pkh 120.0 2005/05/31 10:37:01 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
	(
		p_job_extra_info_id_o		in	number	,
		p_information_type_o		in	varchar2	,
		p_job_id_o				in	number	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_jei_attribute_category_o	in	varchar2	,
		p_jei_attribute1_o		in	varchar2	,
		p_jei_attribute2_o		in	varchar2	,
		p_jei_attribute3_o		in	varchar2	,
		p_jei_attribute4_o		in	varchar2	,
		p_jei_attribute5_o		in	varchar2	,
		p_jei_attribute6_o		in	varchar2	,
		p_jei_attribute7_o		in	varchar2	,
		p_jei_attribute8_o		in	varchar2	,
		p_jei_attribute9_o		in	varchar2	,
		p_jei_attribute10_o		in	varchar2	,
		p_jei_attribute11_o		in	varchar2	,
		p_jei_attribute12_o		in	varchar2	,
		p_jei_attribute13_o		in	varchar2	,
		p_jei_attribute14_o		in	varchar2	,
		p_jei_attribute15_o		in	varchar2	,
		p_jei_attribute16_o		in	varchar2	,
		p_jei_attribute17_o		in	varchar2	,
		p_jei_attribute18_o		in	varchar2	,
		p_jei_attribute19_o		in	varchar2	,
		p_jei_attribute20_o		in	varchar2	,
		p_jei_information_category_o	in	varchar2	,
		p_jei_information1_o		in	varchar2	,
		p_jei_information2_o		in	varchar2	,
		p_jei_information3_o		in	varchar2	,
		p_jei_information4_o		in	varchar2	,
		p_jei_information5_o		in	varchar2	,
		p_jei_information6_o		in	varchar2	,
		p_jei_information7_o		in	varchar2	,
		p_jei_information8_o		in	varchar2	,
		p_jei_information9_o		in	varchar2	,
		p_jei_information10_o		in	varchar2	,
		p_jei_information11_o		in	varchar2	,
		p_jei_information12_o		in	varchar2	,
		p_jei_information13_o		in	varchar2	,
		p_jei_information14_o		in	varchar2	,
		p_jei_information15_o		in	varchar2	,
		p_jei_information16_o		in	varchar2	,
		p_jei_information17_o		in	varchar2	,
		p_jei_information18_o		in	varchar2	,
		p_jei_information19_o		in	varchar2	,
		p_jei_information20_o		in	varchar2	,
		p_jei_information21_o		in	varchar2	,
		p_jei_information22_o		in	varchar2	,
		p_jei_information23_o		in	varchar2	,
		p_jei_information24_o		in	varchar2	,
		p_jei_information25_o		in	varchar2	,
		p_jei_information26_o		in	varchar2	,
		p_jei_information27_o		in	varchar2	,
		p_jei_information28_o		in	varchar2	,
		p_jei_information29_o		in	varchar2	,
		p_jei_information30_o		in	varchar2
	);

end pe_jei_rkd;

 

/
