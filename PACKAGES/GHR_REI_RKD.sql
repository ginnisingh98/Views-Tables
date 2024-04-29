--------------------------------------------------------
--  DDL for Package GHR_REI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_REI_RKD" AUTHID CURRENT_USER as
/* $Header: ghreirhi.pkh 120.1.12010000.1 2008/07/28 10:38:38 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
--
Procedure after_delete
	(
	p_pa_request_extra_info_id_o 	in   number		,
	p_pa_request_id_o 		in   number		,
	p_information_type_o 		in   varchar2	,
	p_rei_attribute_category_o	in   varchar2	,
	p_rei_attribute1_o 		in   varchar2	,
	p_rei_attribute2_o 		in   varchar2	,
	p_rei_attribute3_o 		in   varchar2	,
	p_rei_attribute4_o 		in   varchar2	,
	p_rei_attribute5_o 		in   varchar2	,
	p_rei_attribute6_o 		in   varchar2	,
	p_rei_attribute7_o 		in   varchar2	,
	p_rei_attribute8_o 		in   varchar2	,
	p_rei_attribute9_o 		in   varchar2	,
	p_rei_attribute10_o 		in   varchar2	,
	p_rei_attribute11_o 		in   varchar2	,
	p_rei_attribute12_o 		in   varchar2	,
	p_rei_attribute13_o 		in   varchar2	,
	p_rei_attribute14_o 		in   varchar2	,
	p_rei_attribute15_o 		in   varchar2	,
	p_rei_attribute16_o 		in   varchar2	,
	p_rei_attribute17_o 		in   varchar2	,
	p_rei_attribute18_o 		in   varchar2	,
	p_rei_attribute19_o		in   varchar2	,
	p_rei_attribute20_o		in   varchar2	,
	p_rei_information_category_o 	in   varchar2	,
	p_rei_information1_o		in   varchar2	,
	p_rei_information2_o 		in   varchar2	,
	p_rei_information3_o 		in   varchar2	,
	p_rei_information4_o 		in   varchar2	,
	p_rei_information5_o 		in   varchar2	,
	p_rei_information6_o 		in   varchar2	,
	p_rei_information7_o 		in   varchar2	,
	p_rei_information8_o 		in   varchar2	,
	p_rei_information9_o 		in   varchar2	,
	p_rei_information10_o 		in   varchar2	,
	p_rei_information11_o 		in   varchar2	,
	p_rei_information12_o 		in   varchar2	,
	p_rei_information13_o 		in   varchar2	,
	p_rei_information14_o 		in   varchar2	,
	p_rei_information15_o		in   varchar2	,
	p_rei_information16_o 		in   varchar2	,
	p_rei_information17_o		in   varchar2	,
	p_rei_information18_o 		in   varchar2	,
	p_rei_information19_o 		in   varchar2	,
	p_rei_information20_o 		in   varchar2	,
	p_rei_information21_o 		in   varchar2	,
	p_rei_information22_o 		in   varchar2	,
	p_rei_information28_o 		in   varchar2	,
	p_rei_information29_o 		in   varchar2	,
	p_rei_information23_o 		in   varchar2	,
	p_rei_information24_o 		in   varchar2	,
	p_rei_information25_o 		in   varchar2	,
	p_rei_information26_o 		in   varchar2	,
	p_rei_information27_o 		in   varchar2	,
	p_rei_information30_o 		in   varchar2	,
	p_request_id_o 			in   number		,
	p_program_application_id_o 	in   number		,
	p_program_id_o 			in   number		,
	p_program_update_date_o 	in   date
	);

end ghr_rei_rkd;

/
