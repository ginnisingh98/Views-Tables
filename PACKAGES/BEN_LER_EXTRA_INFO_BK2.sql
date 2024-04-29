--------------------------------------------------------
--  DDL for Package BEN_LER_EXTRA_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_EXTRA_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: belriapi.pkh 120.0 2005/05/28 03:35:01 appldev noship $ */
--

-- |----------------------< update_ler_extra_info_b >----------------------|

Procedure update_ler_extra_info_b	(
		p_ler_extra_info_id		in	number	,
		p_lri_attribute_category	in	varchar2	,
		p_lri_attribute1			in	varchar2	,
		p_lri_attribute2			in	varchar2	,
		p_lri_attribute3			in	varchar2	,
		p_lri_attribute4			in	varchar2	,
		p_lri_attribute5			in	varchar2	,
		p_lri_attribute6			in	varchar2	,
		p_lri_attribute7			in	varchar2	,
		p_lri_attribute8			in	varchar2	,
		p_lri_attribute9			in	varchar2	,
		p_lri_attribute10			in	varchar2	,
		p_lri_attribute11			in	varchar2	,
		p_lri_attribute12			in	varchar2	,
		p_lri_attribute13			in	varchar2	,
		p_lri_attribute14			in	varchar2	,
		p_lri_attribute15			in	varchar2	,
		p_lri_attribute16			in	varchar2	,
		p_lri_attribute17			in	varchar2	,
		p_lri_attribute18			in	varchar2	,
		p_lri_attribute19			in	varchar2	,
		p_lri_attribute20			in	varchar2	,
		p_lri_information_category	in	varchar2	,
		p_lri_information1		in	varchar2	,
		p_lri_information2		in	varchar2	,
		p_lri_information3		in	varchar2	,
		p_lri_information4		in	varchar2	,
		p_lri_information5		in	varchar2	,
		p_lri_information6		in	varchar2	,
		p_lri_information7		in	varchar2	,
		p_lri_information8		in	varchar2	,
		p_lri_information9		in	varchar2	,
		p_lri_information10		in	varchar2	,
		p_lri_information11		in	varchar2	,
		p_lri_information12		in	varchar2	,
		p_lri_information13		in	varchar2	,
		p_lri_information14		in	varchar2	,
		p_lri_information15		in	varchar2	,
		p_lri_information16		in	varchar2	,
		p_lri_information17		in	varchar2	,
		p_lri_information18		in	varchar2	,
		p_lri_information19		in	varchar2	,
		p_lri_information20		in	varchar2	,
		p_lri_information21		in	varchar2	,
		p_lri_information22		in	varchar2	,
		p_lri_information23		in	varchar2	,
		p_lri_information24		in	varchar2	,
		p_lri_information25		in	varchar2	,
		p_lri_information26		in	varchar2	,
		p_lri_information27		in	varchar2	,
		p_lri_information28		in	varchar2	,
		p_lri_information29		in	varchar2	,
		p_lri_information30		in	varchar2	,
		p_object_version_number		in	number
	);

-- |----------------------< update_ler_extra_info_a >----------------------|

Procedure update_ler_extra_info_a
	(
		p_ler_extra_info_id		in	number	,
		p_lri_attribute_category	in	varchar2	,
		p_lri_attribute1			in	varchar2	,
		p_lri_attribute2			in	varchar2	,
		p_lri_attribute3			in	varchar2	,
		p_lri_attribute4			in	varchar2	,
		p_lri_attribute5			in	varchar2	,
		p_lri_attribute6			in	varchar2	,
		p_lri_attribute7			in	varchar2	,
		p_lri_attribute8			in	varchar2	,
		p_lri_attribute9			in	varchar2	,
		p_lri_attribute10			in	varchar2	,
		p_lri_attribute11			in	varchar2	,
		p_lri_attribute12			in	varchar2	,
		p_lri_attribute13			in	varchar2	,
		p_lri_attribute14			in	varchar2	,
		p_lri_attribute15			in	varchar2	,
		p_lri_attribute16			in	varchar2	,
		p_lri_attribute17			in	varchar2	,
		p_lri_attribute18			in	varchar2	,
		p_lri_attribute19			in	varchar2	,
		p_lri_attribute20			in	varchar2	,
		p_lri_information_category	in	varchar2	,
		p_lri_information1		in	varchar2	,
		p_lri_information2		in	varchar2	,
		p_lri_information3		in	varchar2	,
		p_lri_information4		in	varchar2	,
		p_lri_information5		in	varchar2	,
		p_lri_information6		in	varchar2	,
		p_lri_information7		in	varchar2	,
		p_lri_information8		in	varchar2	,
		p_lri_information9		in	varchar2	,
		p_lri_information10		in	varchar2	,
		p_lri_information11		in	varchar2	,
		p_lri_information12		in	varchar2	,
		p_lri_information13		in	varchar2	,
		p_lri_information14		in	varchar2	,
		p_lri_information15		in	varchar2	,
		p_lri_information16		in	varchar2	,
		p_lri_information17		in	varchar2	,
		p_lri_information18		in	varchar2	,
		p_lri_information19		in	varchar2	,
		p_lri_information20		in	varchar2	,
		p_lri_information21		in	varchar2	,
		p_lri_information22		in	varchar2	,
		p_lri_information23		in	varchar2	,
		p_lri_information24		in	varchar2	,
		p_lri_information25		in	varchar2	,
		p_lri_information26		in	varchar2	,
		p_lri_information27		in	varchar2	,
		p_lri_information28		in	varchar2	,
		p_lri_information29		in	varchar2	,
		p_lri_information30		in	varchar2	,
		p_object_version_number		in	number
	);

end ben_ler_extra_info_bk2;

 

/