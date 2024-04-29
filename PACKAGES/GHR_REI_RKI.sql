--------------------------------------------------------
--  DDL for Package GHR_REI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_REI_RKI" AUTHID CURRENT_USER as
/* $Header: ghreirhi.pkh 120.1.12010000.1 2008/07/28 10:38:38 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_insert >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.
Procedure after_insert
	(
	p_pa_request_extra_info_id 	in   number		,
	p_pa_request_id 			in   number		,
	p_information_type 		in   varchar2	,
	p_rei_attribute_category	in   varchar2	,
	p_rei_attribute1 			in   varchar2	,
	p_rei_attribute2 			in   varchar2	,
	p_rei_attribute3 			in   varchar2	,
	p_rei_attribute4 			in   varchar2	,
	p_rei_attribute5 			in   varchar2	,
	p_rei_attribute6 			in   varchar2	,
	p_rei_attribute7 			in   varchar2	,
	p_rei_attribute8 			in   varchar2	,
	p_rei_attribute9 			in   varchar2	,
	p_rei_attribute10 		in   varchar2	,
	p_rei_attribute11 		in   varchar2	,
	p_rei_attribute12 		in   varchar2	,
	p_rei_attribute13 		in   varchar2	,
	p_rei_attribute14 		in   varchar2	,
	p_rei_attribute15 		in   varchar2	,
	p_rei_attribute16 		in   varchar2	,
	p_rei_attribute17 		in   varchar2	,
	p_rei_attribute18 		in   varchar2	,
	p_rei_attribute19			in   varchar2	,
	p_rei_attribute20			in   varchar2	,
	p_rei_information_category 	in   varchar2	,
	p_rei_information1		in   varchar2	,
	p_rei_information2 		in   varchar2	,
	p_rei_information3 		in   varchar2	,
	p_rei_information4 		in   varchar2	,
	p_rei_information5 		in   varchar2	,
	p_rei_information6 		in   varchar2	,
	p_rei_information7 		in   varchar2	,
	p_rei_information8 		in   varchar2	,
	p_rei_information9 		in   varchar2	,
	p_rei_information10 		in   varchar2	,
	p_rei_information11 		in   varchar2	,
	p_rei_information12 		in   varchar2	,
	p_rei_information13 		in   varchar2	,
	p_rei_information14 		in   varchar2	,
	p_rei_information15		in   varchar2	,
	p_rei_information16 		in   varchar2	,
	p_rei_information17		in   varchar2	,
	p_rei_information18 		in   varchar2	,
	p_rei_information19 		in   varchar2	,
	p_rei_information20 		in   varchar2	,
	p_rei_information21 		in   varchar2	,
	p_rei_information22 		in   varchar2	,
	p_rei_information28 		in   varchar2	,
	p_rei_information29 		in   varchar2	,
	p_rei_information23 		in   varchar2	,
	p_rei_information24 		in   varchar2	,
	p_rei_information25 		in   varchar2	,
	p_rei_information26 		in   varchar2	,
	p_rei_information27 		in   varchar2	,
	p_rei_information30 		in   varchar2	,
	p_request_id 			in   number		,
	p_program_application_id 	in   number		,
	p_program_id 			in   number		,
	p_program_update_date 		in   date
	);

end ghr_rei_rki;

/
