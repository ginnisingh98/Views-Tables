--------------------------------------------------------
--  DDL for Package BEN_ABI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABI_RKD" AUTHID CURRENT_USER as
/* $Header: beabirhi.pkh 120.0 2005/05/28 00:17:40 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handabr user hook. The package body is generated.
--
Procedure after_delete
	(
		p_abr_extra_info_id_o		in	number	,
		p_information_type_o		in	varchar2	,
		p_acty_base_rt_id_o		in	number	,
		p_request_id_o			in	number	,
		p_program_application_id_o	in	number	,
		p_program_id_o			in	number	,
		p_program_update_date_o		in	date		,
		p_abi_attribute_category_o	in	varchar2	,
		p_abi_attribute1_o		in	varchar2	,
		p_abi_attribute2_o		in	varchar2	,
		p_abi_attribute3_o		in	varchar2	,
		p_abi_attribute4_o		in	varchar2	,
		p_abi_attribute5_o		in	varchar2	,
		p_abi_attribute6_o		in	varchar2	,
		p_abi_attribute7_o		in	varchar2	,
		p_abi_attribute8_o		in	varchar2	,
		p_abi_attribute9_o		in	varchar2	,
		p_abi_attribute10_o		in	varchar2	,
		p_abi_attribute11_o		in	varchar2	,
		p_abi_attribute12_o		in	varchar2	,
		p_abi_attribute13_o		in	varchar2	,
		p_abi_attribute14_o		in	varchar2	,
		p_abi_attribute15_o		in	varchar2	,
		p_abi_attribute16_o		in	varchar2	,
		p_abi_attribute17_o		in	varchar2	,
		p_abi_attribute18_o		in	varchar2	,
		p_abi_attribute19_o		in	varchar2	,
		p_abi_attribute20_o		in	varchar2	,
		p_abi_information_category_o	in	varchar2	,
		p_abi_information1_o		in	varchar2	,
		p_abi_information2_o		in	varchar2	,
		p_abi_information3_o		in	varchar2	,
		p_abi_information4_o		in	varchar2	,
		p_abi_information5_o		in	varchar2	,
		p_abi_information6_o		in	varchar2	,
		p_abi_information7_o		in	varchar2	,
		p_abi_information8_o		in	varchar2	,
		p_abi_information9_o		in	varchar2	,
		p_abi_information10_o		in	varchar2	,
		p_abi_information11_o		in	varchar2	,
		p_abi_information12_o		in	varchar2	,
		p_abi_information13_o		in	varchar2	,
		p_abi_information14_o		in	varchar2	,
		p_abi_information15_o		in	varchar2	,
		p_abi_information16_o		in	varchar2	,
		p_abi_information17_o		in	varchar2	,
		p_abi_information18_o		in	varchar2	,
		p_abi_information19_o		in	varchar2	,
		p_abi_information20_o		in	varchar2	,
		p_abi_information21_o		in	varchar2	,
		p_abi_information22_o		in	varchar2	,
		p_abi_information23_o		in	varchar2	,
		p_abi_information24_o		in	varchar2	,
		p_abi_information25_o		in	varchar2	,
		p_abi_information26_o		in	varchar2	,
		p_abi_information27_o		in	varchar2	,
		p_abi_information28_o		in	varchar2	,
		p_abi_information29_o		in	varchar2	,
		p_abi_information30_o		in	varchar2
	);

end ben_abi_rkd;

 

/
