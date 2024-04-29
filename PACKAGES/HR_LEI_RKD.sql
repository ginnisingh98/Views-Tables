--------------------------------------------------------
--  DDL for Package HR_LEI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEI_RKD" AUTHID CURRENT_USER as
/* $Header: hrleirhi.pkh 120.0.12000000.1 2007/01/21 17:09:16 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
	(
		p_location_extra_info_id_o	in	number	,
		p_information_type_o		in	varchar2	,
		p_location_id_o			in	number	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_lei_attribute_category_o	in	varchar2	,
		p_lei_attribute1_o		in	varchar2	,
		p_lei_attribute2_o		in	varchar2	,
		p_lei_attribute3_o		in	varchar2	,
		p_lei_attribute4_o		in	varchar2	,
		p_lei_attribute5_o		in	varchar2	,
		p_lei_attribute6_o		in	varchar2	,
		p_lei_attribute7_o		in	varchar2	,
		p_lei_attribute8_o		in	varchar2	,
		p_lei_attribute9_o		in	varchar2	,
		p_lei_attribute10_o		in	varchar2	,
		p_lei_attribute11_o		in	varchar2	,
		p_lei_attribute12_o		in	varchar2	,
		p_lei_attribute13_o		in	varchar2	,
		p_lei_attribute14_o		in	varchar2	,
		p_lei_attribute15_o		in	varchar2	,
		p_lei_attribute16_o		in	varchar2	,
		p_lei_attribute17_o		in	varchar2	,
		p_lei_attribute18_o		in	varchar2	,
		p_lei_attribute19_o		in	varchar2	,
		p_lei_attribute20_o		in	varchar2	,
		p_lei_information_category_o	in	varchar2	,
		p_lei_information1_o		in	varchar2	,
		p_lei_information2_o		in	varchar2	,
		p_lei_information3_o		in	varchar2	,
		p_lei_information4_o		in	varchar2	,
		p_lei_information5_o		in	varchar2	,
		p_lei_information6_o		in	varchar2	,
		p_lei_information7_o		in	varchar2	,
		p_lei_information8_o		in	varchar2	,
		p_lei_information9_o		in	varchar2	,
		p_lei_information10_o		in	varchar2	,
		p_lei_information11_o		in	varchar2	,
		p_lei_information12_o		in	varchar2	,
		p_lei_information13_o		in	varchar2	,
		p_lei_information14_o		in	varchar2	,
		p_lei_information15_o		in	varchar2	,
		p_lei_information16_o		in	varchar2	,
		p_lei_information17_o		in	varchar2	,
		p_lei_information18_o		in	varchar2	,
		p_lei_information19_o		in	varchar2	,
		p_lei_information20_o		in	varchar2	,
		p_lei_information21_o		in	varchar2	,
		p_lei_information22_o		in	varchar2	,
		p_lei_information23_o		in	varchar2	,
		p_lei_information24_o		in	varchar2	,
		p_lei_information25_o		in	varchar2	,
		p_lei_information26_o		in	varchar2	,
		p_lei_information27_o		in	varchar2	,
		p_lei_information28_o		in	varchar2	,
		p_lei_information29_o		in	varchar2	,
		p_lei_information30_o		in	varchar2
	);

end hr_lei_rkd;

 

/
