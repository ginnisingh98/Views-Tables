--------------------------------------------------------
--  DDL for Package PE_AEI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_AEI_RKD" AUTHID CURRENT_USER as
/* $Header: peaeirhi.pkh 120.0 2005/05/31 05:08:28 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
	(
		p_assignment_extra_info_id_o	in	number	,
		p_assignment_id_o			in	number	,
		p_information_type_o		in	varchar2	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_aei_attribute_category_o	in	varchar2	,
		p_aei_attribute1_o		in	varchar2	,
		p_aei_attribute2_o		in	varchar2	,
		p_aei_attribute3_o		in	varchar2	,
		p_aei_attribute4_o		in	varchar2	,
		p_aei_attribute5_o		in	varchar2	,
		p_aei_attribute6_o		in	varchar2	,
		p_aei_attribute7_o		in	varchar2	,
		p_aei_attribute8_o		in	varchar2	,
		p_aei_attribute9_o		in	varchar2	,
		p_aei_attribute10_o		in	varchar2	,
		p_aei_attribute11_o		in	varchar2	,
		p_aei_attribute12_o		in	varchar2	,
		p_aei_attribute13_o		in	varchar2	,
		p_aei_attribute14_o		in	varchar2	,
		p_aei_attribute15_o		in	varchar2	,
		p_aei_attribute16_o		in	varchar2	,
		p_aei_attribute17_o		in	varchar2	,
		p_aei_attribute18_o		in	varchar2	,
		p_aei_attribute19_o		in	varchar2	,
		p_aei_attribute20_o		in	varchar2	,
		p_aei_information_category_o	in	varchar2	,
		p_aei_information1_o		in	varchar2	,
		p_aei_information2_o		in	varchar2	,
		p_aei_information3_o		in	varchar2	,
		p_aei_information4_o		in	varchar2	,
		p_aei_information5_o		in	varchar2	,
		p_aei_information6_o		in	varchar2	,
		p_aei_information7_o		in	varchar2	,
		p_aei_information8_o		in	varchar2	,
		p_aei_information9_o		in	varchar2	,
		p_aei_information10_o		in	varchar2	,
		p_aei_information11_o		in	varchar2	,
		p_aei_information12_o		in	varchar2	,
		p_aei_information13_o		in	varchar2	,
		p_aei_information14_o		in	varchar2	,
		p_aei_information15_o		in	varchar2	,
		p_aei_information16_o		in	varchar2	,
		p_aei_information17_o		in	varchar2	,
		p_aei_information18_o		in	varchar2	,
		p_aei_information19_o		in	varchar2	,
		p_aei_information20_o		in	varchar2	,
		p_aei_information21_o		in	varchar2	,
		p_aei_information22_o		in	varchar2	,
		p_aei_information23_o		in	varchar2	,
		p_aei_information24_o		in	varchar2	,
		p_aei_information25_o		in	varchar2	,
		p_aei_information26_o		in	varchar2	,
		p_aei_information27_o		in	varchar2	,
		p_aei_information28_o		in	varchar2	,
		p_aei_information29_o		in	varchar2	,
		p_aei_information30_o		in	varchar2
	);

end pe_aei_rkd;

 

/
