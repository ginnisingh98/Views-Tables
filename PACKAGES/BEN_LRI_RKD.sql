--------------------------------------------------------
--  DDL for Package BEN_LRI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRI_RKD" AUTHID CURRENT_USER as
/* $Header: belrirhi.pkh 120.0 2005/05/28 03:35:25 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
	(
		p_ler_extra_info_id_o		in	number	,
		p_information_type_o		in	varchar2	,
		p_ler_id_o				in	number	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_lri_attribute_category_o	in	varchar2	,
		p_lri_attribute1_o		in	varchar2	,
		p_lri_attribute2_o		in	varchar2	,
		p_lri_attribute3_o		in	varchar2	,
		p_lri_attribute4_o		in	varchar2	,
		p_lri_attribute5_o		in	varchar2	,
		p_lri_attribute6_o		in	varchar2	,
		p_lri_attribute7_o		in	varchar2	,
		p_lri_attribute8_o		in	varchar2	,
		p_lri_attribute9_o		in	varchar2	,
		p_lri_attribute10_o		in	varchar2	,
		p_lri_attribute11_o		in	varchar2	,
		p_lri_attribute12_o		in	varchar2	,
		p_lri_attribute13_o		in	varchar2	,
		p_lri_attribute14_o		in	varchar2	,
		p_lri_attribute15_o		in	varchar2	,
		p_lri_attribute16_o		in	varchar2	,
		p_lri_attribute17_o		in	varchar2	,
		p_lri_attribute18_o		in	varchar2	,
		p_lri_attribute19_o		in	varchar2	,
		p_lri_attribute20_o		in	varchar2	,
		p_lri_information_category_o	in	varchar2	,
		p_lri_information1_o		in	varchar2	,
		p_lri_information2_o		in	varchar2	,
		p_lri_information3_o		in	varchar2	,
		p_lri_information4_o		in	varchar2	,
		p_lri_information5_o		in	varchar2	,
		p_lri_information6_o		in	varchar2	,
		p_lri_information7_o		in	varchar2	,
		p_lri_information8_o		in	varchar2	,
		p_lri_information9_o		in	varchar2	,
		p_lri_information10_o		in	varchar2	,
		p_lri_information11_o		in	varchar2	,
		p_lri_information12_o		in	varchar2	,
		p_lri_information13_o		in	varchar2	,
		p_lri_information14_o		in	varchar2	,
		p_lri_information15_o		in	varchar2	,
		p_lri_information16_o		in	varchar2	,
		p_lri_information17_o		in	varchar2	,
		p_lri_information18_o		in	varchar2	,
		p_lri_information19_o		in	varchar2	,
		p_lri_information20_o		in	varchar2	,
		p_lri_information21_o		in	varchar2	,
		p_lri_information22_o		in	varchar2	,
		p_lri_information23_o		in	varchar2	,
		p_lri_information24_o		in	varchar2	,
		p_lri_information25_o		in	varchar2	,
		p_lri_information26_o		in	varchar2	,
		p_lri_information27_o		in	varchar2	,
		p_lri_information28_o		in	varchar2	,
		p_lri_information29_o		in	varchar2	,
		p_lri_information30_o		in	varchar2
	);

end ben_lri_rkd;

 

/
