--------------------------------------------------------
--  DDL for Package BEN_PGI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGI_RKD" AUTHID CURRENT_USER as
/* $Header: bepgirhi.pkh 120.0 2005/05/28 10:46:19 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handpgm user hook. The package body is generated.
--
Procedure after_delete
	(
		p_pgm_extra_info_id_o		in	number	,
		p_information_type_o		in	varchar2	,
		p_pgm_id_o				in	number	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_pgi_attribute_category_o	in	varchar2	,
		p_pgi_attribute1_o		in	varchar2	,
		p_pgi_attribute2_o		in	varchar2	,
		p_pgi_attribute3_o		in	varchar2	,
		p_pgi_attribute4_o		in	varchar2	,
		p_pgi_attribute5_o		in	varchar2	,
		p_pgi_attribute6_o		in	varchar2	,
		p_pgi_attribute7_o		in	varchar2	,
		p_pgi_attribute8_o		in	varchar2	,
		p_pgi_attribute9_o		in	varchar2	,
		p_pgi_attribute10_o		in	varchar2	,
		p_pgi_attribute11_o		in	varchar2	,
		p_pgi_attribute12_o		in	varchar2	,
		p_pgi_attribute13_o		in	varchar2	,
		p_pgi_attribute14_o		in	varchar2	,
		p_pgi_attribute15_o		in	varchar2	,
		p_pgi_attribute16_o		in	varchar2	,
		p_pgi_attribute17_o		in	varchar2	,
		p_pgi_attribute18_o		in	varchar2	,
		p_pgi_attribute19_o		in	varchar2	,
		p_pgi_attribute20_o		in	varchar2	,
		p_pgi_information_category_o	in	varchar2	,
		p_pgi_information1_o		in	varchar2	,
		p_pgi_information2_o		in	varchar2	,
		p_pgi_information3_o		in	varchar2	,
		p_pgi_information4_o		in	varchar2	,
		p_pgi_information5_o		in	varchar2	,
		p_pgi_information6_o		in	varchar2	,
		p_pgi_information7_o		in	varchar2	,
		p_pgi_information8_o		in	varchar2	,
		p_pgi_information9_o		in	varchar2	,
		p_pgi_information10_o		in	varchar2	,
		p_pgi_information11_o		in	varchar2	,
		p_pgi_information12_o		in	varchar2	,
		p_pgi_information13_o		in	varchar2	,
		p_pgi_information14_o		in	varchar2	,
		p_pgi_information15_o		in	varchar2	,
		p_pgi_information16_o		in	varchar2	,
		p_pgi_information17_o		in	varchar2	,
		p_pgi_information18_o		in	varchar2	,
		p_pgi_information19_o		in	varchar2	,
		p_pgi_information20_o		in	varchar2	,
		p_pgi_information21_o		in	varchar2	,
		p_pgi_information22_o		in	varchar2	,
		p_pgi_information23_o		in	varchar2	,
		p_pgi_information24_o		in	varchar2	,
		p_pgi_information25_o		in	varchar2	,
		p_pgi_information26_o		in	varchar2	,
		p_pgi_information27_o		in	varchar2	,
		p_pgi_information28_o		in	varchar2	,
		p_pgi_information29_o		in	varchar2	,
		p_pgi_information30_o		in	varchar2
	);

end ben_pgi_rkd;

 

/
