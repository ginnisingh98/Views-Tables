--------------------------------------------------------
--  DDL for Package PE_POI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PE_POI_RKD" AUTHID CURRENT_USER as
/* $Header: pepoirhi.pkh 120.0 2005/05/31 14:50:52 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
	(
		p_position_extra_info_id_o	in	number	,
		p_position_id_o			in	number	,
		p_information_type_o		in	varchar2	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_poei_attribute_category_o	in	varchar2	,
		p_poei_attribute1_o		in	varchar2	,
		p_poei_attribute2_o		in	varchar2	,
		p_poei_attribute3_o		in	varchar2	,
		p_poei_attribute4_o		in	varchar2	,
		p_poei_attribute5_o		in	varchar2	,
		p_poei_attribute6_o		in	varchar2	,
		p_poei_attribute7_o		in	varchar2	,
		p_poei_attribute8_o		in	varchar2	,
		p_poei_attribute9_o		in	varchar2	,
		p_poei_attribute10_o		in	varchar2	,
		p_poei_attribute11_o		in	varchar2	,
		p_poei_attribute12_o		in	varchar2	,
		p_poei_attribute13_o		in	varchar2	,
		p_poei_attribute14_o		in	varchar2	,
		p_poei_attribute15_o		in	varchar2	,
		p_poei_attribute16_o		in	varchar2	,
		p_poei_attribute17_o		in	varchar2	,
		p_poei_attribute18_o		in	varchar2	,
		p_poei_attribute19_o		in	varchar2	,
		p_poei_attribute20_o		in	varchar2	,
		p_poei_information_category_o	in	varchar2	,
		p_poei_information1_o		in	varchar2	,
		p_poei_information2_o		in	varchar2	,
		p_poei_information3_o		in	varchar2	,
		p_poei_information4_o		in	varchar2	,
		p_poei_information5_o		in	varchar2	,
		p_poei_information6_o		in	varchar2	,
		p_poei_information7_o		in	varchar2	,
		p_poei_information8_o		in	varchar2	,
		p_poei_information9_o		in	varchar2	,
		p_poei_information10_o		in	varchar2	,
		p_poei_information11_o		in	varchar2	,
		p_poei_information12_o		in	varchar2	,
		p_poei_information13_o		in	varchar2	,
		p_poei_information14_o		in	varchar2	,
		p_poei_information15_o		in	varchar2	,
		p_poei_information16_o		in	varchar2	,
		p_poei_information17_o		in	varchar2	,
		p_poei_information18_o		in	varchar2	,
		p_poei_information19_o		in	varchar2	,
		p_poei_information20_o		in	varchar2	,
		p_poei_information21_o		in	varchar2	,
		p_poei_information22_o		in	varchar2	,
		p_poei_information23_o		in	varchar2	,
		p_poei_information24_o		in	varchar2	,
		p_poei_information25_o		in	varchar2	,
		p_poei_information26_o		in	varchar2	,
		p_poei_information27_o		in	varchar2	,
		p_poei_information28_o		in	varchar2	,
		p_poei_information29_o		in	varchar2	,
		p_poei_information30_o		in	varchar2
	);

end pe_poi_rkd;

 

/
