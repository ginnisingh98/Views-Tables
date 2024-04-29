--------------------------------------------------------
--  DDL for Package BEN_PLI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLI_RKD" AUTHID CURRENT_USER as
/* $Header: beplirhi.pkh 120.0.12010000.1 2008/07/29 12:50:44 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handpl user hook. The package body is generated.
--
Procedure after_delete
	(
		p_pl_extra_info_id_o		in	number	,
		p_information_type_o		in	varchar2	,
		p_pl_id_o				in	number	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_pli_attribute_category_o	in	varchar2	,
		p_pli_attribute1_o		in	varchar2	,
		p_pli_attribute2_o		in	varchar2	,
		p_pli_attribute3_o		in	varchar2	,
		p_pli_attribute4_o		in	varchar2	,
		p_pli_attribute5_o		in	varchar2	,
		p_pli_attribute6_o		in	varchar2	,
		p_pli_attribute7_o		in	varchar2	,
		p_pli_attribute8_o		in	varchar2	,
		p_pli_attribute9_o		in	varchar2	,
		p_pli_attribute10_o		in	varchar2	,
		p_pli_attribute11_o		in	varchar2	,
		p_pli_attribute12_o		in	varchar2	,
		p_pli_attribute13_o		in	varchar2	,
		p_pli_attribute14_o		in	varchar2	,
		p_pli_attribute15_o		in	varchar2	,
		p_pli_attribute16_o		in	varchar2	,
		p_pli_attribute17_o		in	varchar2	,
		p_pli_attribute18_o		in	varchar2	,
		p_pli_attribute19_o		in	varchar2	,
		p_pli_attribute20_o		in	varchar2	,
		p_pli_information_category_o	in	varchar2	,
		p_pli_information1_o		in	varchar2	,
		p_pli_information2_o		in	varchar2	,
		p_pli_information3_o		in	varchar2	,
		p_pli_information4_o		in	varchar2	,
		p_pli_information5_o		in	varchar2	,
		p_pli_information6_o		in	varchar2	,
		p_pli_information7_o		in	varchar2	,
		p_pli_information8_o		in	varchar2	,
		p_pli_information9_o		in	varchar2	,
		p_pli_information10_o		in	varchar2	,
		p_pli_information11_o		in	varchar2	,
		p_pli_information12_o		in	varchar2	,
		p_pli_information13_o		in	varchar2	,
		p_pli_information14_o		in	varchar2	,
		p_pli_information15_o		in	varchar2	,
		p_pli_information16_o		in	varchar2	,
		p_pli_information17_o		in	varchar2	,
		p_pli_information18_o		in	varchar2	,
		p_pli_information19_o		in	varchar2	,
		p_pli_information20_o		in	varchar2	,
		p_pli_information21_o		in	varchar2	,
		p_pli_information22_o		in	varchar2	,
		p_pli_information23_o		in	varchar2	,
		p_pli_information24_o		in	varchar2	,
		p_pli_information25_o		in	varchar2	,
		p_pli_information26_o		in	varchar2	,
		p_pli_information27_o		in	varchar2	,
		p_pli_information28_o		in	varchar2	,
		p_pli_information29_o		in	varchar2	,
		p_pli_information30_o		in	varchar2
	);

end ben_pli_rkd;

/
