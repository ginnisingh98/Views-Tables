--------------------------------------------------------
--  DDL for Package BEN_OPI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPI_RKD" AUTHID CURRENT_USER as
/* $Header: beopirhi.pkh 120.0 2005/05/28 09:53:29 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handopt user hook. The package body is generated.
--
Procedure after_delete
	(
		p_opt_extra_info_id_o		in	number	,
		p_information_type_o		in	varchar2	,
		p_opt_id_o				in	number	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_opi_attribute_category_o	in	varchar2	,
		p_opi_attribute1_o		in	varchar2	,
		p_opi_attribute2_o		in	varchar2	,
		p_opi_attribute3_o		in	varchar2	,
		p_opi_attribute4_o		in	varchar2	,
		p_opi_attribute5_o		in	varchar2	,
		p_opi_attribute6_o		in	varchar2	,
		p_opi_attribute7_o		in	varchar2	,
		p_opi_attribute8_o		in	varchar2	,
		p_opi_attribute9_o		in	varchar2	,
		p_opi_attribute10_o		in	varchar2	,
		p_opi_attribute11_o		in	varchar2	,
		p_opi_attribute12_o		in	varchar2	,
		p_opi_attribute13_o		in	varchar2	,
		p_opi_attribute14_o		in	varchar2	,
		p_opi_attribute15_o		in	varchar2	,
		p_opi_attribute16_o		in	varchar2	,
		p_opi_attribute17_o		in	varchar2	,
		p_opi_attribute18_o		in	varchar2	,
		p_opi_attribute19_o		in	varchar2	,
		p_opi_attribute20_o		in	varchar2	,
		p_opi_information_category_o	in	varchar2	,
		p_opi_information1_o		in	varchar2	,
		p_opi_information2_o		in	varchar2	,
		p_opi_information3_o		in	varchar2	,
		p_opi_information4_o		in	varchar2	,
		p_opi_information5_o		in	varchar2	,
		p_opi_information6_o		in	varchar2	,
		p_opi_information7_o		in	varchar2	,
		p_opi_information8_o		in	varchar2	,
		p_opi_information9_o		in	varchar2	,
		p_opi_information10_o		in	varchar2	,
		p_opi_information11_o		in	varchar2	,
		p_opi_information12_o		in	varchar2	,
		p_opi_information13_o		in	varchar2	,
		p_opi_information14_o		in	varchar2	,
		p_opi_information15_o		in	varchar2	,
		p_opi_information16_o		in	varchar2	,
		p_opi_information17_o		in	varchar2	,
		p_opi_information18_o		in	varchar2	,
		p_opi_information19_o		in	varchar2	,
		p_opi_information20_o		in	varchar2	,
		p_opi_information21_o		in	varchar2	,
		p_opi_information22_o		in	varchar2	,
		p_opi_information23_o		in	varchar2	,
		p_opi_information24_o		in	varchar2	,
		p_opi_information25_o		in	varchar2	,
		p_opi_information26_o		in	varchar2	,
		p_opi_information27_o		in	varchar2	,
		p_opi_information28_o		in	varchar2	,
		p_opi_information29_o		in	varchar2	,
		p_opi_information30_o		in	varchar2
	);

end ben_opi_rkd;

 

/
