--------------------------------------------------------
--  DDL for Package BEN_ELI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELI_RKD" AUTHID CURRENT_USER as
/* $Header: beelirhi.pkh 120.0 2005/05/28 02:18:37 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handelp user hook. The package body is generated.
--
Procedure after_delete
	(
		p_elp_extra_info_id_o		in	number	,
		p_information_type_o		in	varchar2	,
		p_eligy_prfl_id_o				in	number	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_eli_attribute_category_o	in	varchar2	,
		p_eli_attribute1_o		in	varchar2	,
		p_eli_attribute2_o		in	varchar2	,
		p_eli_attribute3_o		in	varchar2	,
		p_eli_attribute4_o		in	varchar2	,
		p_eli_attribute5_o		in	varchar2	,
		p_eli_attribute6_o		in	varchar2	,
		p_eli_attribute7_o		in	varchar2	,
		p_eli_attribute8_o		in	varchar2	,
		p_eli_attribute9_o		in	varchar2	,
		p_eli_attribute10_o		in	varchar2	,
		p_eli_attribute11_o		in	varchar2	,
		p_eli_attribute12_o		in	varchar2	,
		p_eli_attribute13_o		in	varchar2	,
		p_eli_attribute14_o		in	varchar2	,
		p_eli_attribute15_o		in	varchar2	,
		p_eli_attribute16_o		in	varchar2	,
		p_eli_attribute17_o		in	varchar2	,
		p_eli_attribute18_o		in	varchar2	,
		p_eli_attribute19_o		in	varchar2	,
		p_eli_attribute20_o		in	varchar2	,
		p_eli_information_category_o	in	varchar2	,
		p_eli_information1_o		in	varchar2	,
		p_eli_information2_o		in	varchar2	,
		p_eli_information3_o		in	varchar2	,
		p_eli_information4_o		in	varchar2	,
		p_eli_information5_o		in	varchar2	,
		p_eli_information6_o		in	varchar2	,
		p_eli_information7_o		in	varchar2	,
		p_eli_information8_o		in	varchar2	,
		p_eli_information9_o		in	varchar2	,
		p_eli_information10_o		in	varchar2	,
		p_eli_information11_o		in	varchar2	,
		p_eli_information12_o		in	varchar2	,
		p_eli_information13_o		in	varchar2	,
		p_eli_information14_o		in	varchar2	,
		p_eli_information15_o		in	varchar2	,
		p_eli_information16_o		in	varchar2	,
		p_eli_information17_o		in	varchar2	,
		p_eli_information18_o		in	varchar2	,
		p_eli_information19_o		in	varchar2	,
		p_eli_information20_o		in	varchar2	,
		p_eli_information21_o		in	varchar2	,
		p_eli_information22_o		in	varchar2	,
		p_eli_information23_o		in	varchar2	,
		p_eli_information24_o		in	varchar2	,
		p_eli_information25_o		in	varchar2	,
		p_eli_information26_o		in	varchar2	,
		p_eli_information27_o		in	varchar2	,
		p_eli_information28_o		in	varchar2	,
		p_eli_information29_o		in	varchar2	,
		p_eli_information30_o		in	varchar2
	);

end ben_eli_rkd;

 

/
