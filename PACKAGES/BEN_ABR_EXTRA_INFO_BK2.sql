--------------------------------------------------------
--  DDL for Package BEN_ABR_EXTRA_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ABR_EXTRA_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: beabiapi.pkh 120.0 2005/05/28 00:17:20 appldev noship $ */
--
--  ------------------------------------------------------------------------
-- |----------------------< update_abr_extra_info_b >----------------------|
--  ------------------------------------------------------------------------

Procedure update_abr_extra_info_b	(
		p_abr_extra_info_id		in	number	,
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
		p_abi_information30		in	varchar2	,
		p_object_version_number		in	number
	);



-- |----------------------< update_abr_extra_info_a >----------------------|

Procedure update_abr_extra_info_a
	(
		p_abr_extra_info_id		in	number	,
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
		p_abi_information30		in	varchar2	,
		p_object_version_number		in	number
	);

end ben_abr_extra_info_bk2;

 

/
