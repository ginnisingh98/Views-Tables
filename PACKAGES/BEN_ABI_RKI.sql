--------------------------------------------------------
--  DDL for Package BEN_ABI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABI_RKI" AUTHID CURRENT_USER as
/* $Header: beabirhi.pkh 120.0 2005/05/28 00:17:40 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_insert >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handabr user hook. The package body is generated.
Procedure after_insert
	(
		p_abr_extra_info_id		in	number	,
		p_information_type		in	varchar2	,
		p_acty_base_rt_id		in	number	,
		p_request_id			in	number	,
		p_program_application_id	in	number	,
		p_program_id			in	number	,
		p_program_update_date		in	date		,
		p_abi_attribute_category	in	varchar2	,
		p_abi_attribute1			in	varchar2	,
		p_abi_attribute2			in	varchar2	,
		p_abi_attribute3			in	varchar2	,
		p_abi_attribute4			in	varchar2	,
		p_abi_attribute5			in	varchar2	,
		p_abi_attribute6			in	varchar2	,
		p_abi_attribute7			in	varchar2	,
		p_abi_attribute8			in	varchar2	,
		p_abi_attribute9			in	varchar2	,
		p_abi_attribute10			in	varchar2	,
		p_abi_attribute11			in	varchar2	,
		p_abi_attribute12			in	varchar2	,
		p_abi_attribute13			in	varchar2	,
		p_abi_attribute14			in	varchar2	,
		p_abi_attribute15			in	varchar2	,
		p_abi_attribute16			in	varchar2	,
		p_abi_attribute17			in	varchar2	,
		p_abi_attribute18			in	varchar2	,
		p_abi_attribute19			in	varchar2	,
		p_abi_attribute20			in	varchar2	,
		p_abi_information_category	in	varchar2	,
		p_abi_information1		in	varchar2	,
		p_abi_information2		in	varchar2	,
		p_abi_information3		in	varchar2	,
		p_abi_information4		in	varchar2	,
		p_abi_information5		in	varchar2	,
		p_abi_information6		in	varchar2	,
		p_abi_information7		in	varchar2	,
		p_abi_information8		in	varchar2	,
		p_abi_information9		in	varchar2	,
		p_abi_information10		in	varchar2	,
		p_abi_information11		in	varchar2	,
		p_abi_information12		in	varchar2	,
		p_abi_information13		in	varchar2	,
		p_abi_information14		in	varchar2	,
		p_abi_information15		in	varchar2	,
		p_abi_information16		in	varchar2	,
		p_abi_information17		in	varchar2	,
		p_abi_information18		in	varchar2	,
		p_abi_information19		in	varchar2	,
		p_abi_information20		in	varchar2	,
		p_abi_information21		in	varchar2	,
		p_abi_information22		in	varchar2	,
		p_abi_information23		in	varchar2	,
		p_abi_information24		in	varchar2	,
		p_abi_information25		in	varchar2	,
		p_abi_information26		in	varchar2	,
		p_abi_information27		in	varchar2	,
		p_abi_information28		in	varchar2	,
		p_abi_information29		in	varchar2	,
		p_abi_information30		in	varchar2
	);

end ben_abi_rki;

 

/
