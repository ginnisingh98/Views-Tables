--------------------------------------------------------
--  DDL for Package HR_POSITION_EXTRA_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POSITION_EXTRA_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: pepoiapi.pkh 120.1 2005/10/02 02:21:45 aroussel $ */
--
--
-- update_position_extra_info_b
--
Procedure update_position_extra_info_b	(
		p_position_extra_info_id	in	number	,
		p_poei_attribute_category	in	varchar2	,
		p_poei_attribute1			in	varchar2	,
		p_poei_attribute2			in	varchar2	,
		p_poei_attribute3			in	varchar2	,
		p_poei_attribute4			in	varchar2	,
		p_poei_attribute5			in	varchar2	,
		p_poei_attribute6			in	varchar2	,
		p_poei_attribute7			in	varchar2	,
		p_poei_attribute8			in	varchar2	,
		p_poei_attribute9			in	varchar2	,
		p_poei_attribute10		in	varchar2	,
		p_poei_attribute11		in	varchar2	,
		p_poei_attribute12		in	varchar2	,
		p_poei_attribute13		in	varchar2	,
		p_poei_attribute14		in	varchar2	,
		p_poei_attribute15		in	varchar2	,
		p_poei_attribute16		in	varchar2	,
		p_poei_attribute17		in	varchar2	,
		p_poei_attribute18		in	varchar2	,
		p_poei_attribute19		in	varchar2	,
		p_poei_attribute20		in	varchar2	,
		p_poei_information_category	in	varchar2	,
		p_poei_information1		in	varchar2	,
		p_poei_information2		in	varchar2	,
		p_poei_information3		in	varchar2	,
		p_poei_information4		in	varchar2	,
		p_poei_information5		in	varchar2	,
		p_poei_information6		in	varchar2	,
		p_poei_information7		in	varchar2	,
		p_poei_information8		in	varchar2	,
		p_poei_information9		in	varchar2	,
		p_poei_information10		in	varchar2	,
		p_poei_information11		in	varchar2	,
		p_poei_information12		in	varchar2	,
		p_poei_information13		in	varchar2	,
		p_poei_information14		in	varchar2	,
		p_poei_information15		in	varchar2	,
		p_poei_information16		in	varchar2	,
		p_poei_information17		in	varchar2	,
		p_poei_information18		in	varchar2	,
		p_poei_information19		in	varchar2	,
		p_poei_information20		in	varchar2	,
		p_poei_information21		in	varchar2	,
		p_poei_information22		in	varchar2	,
		p_poei_information23		in	varchar2	,
		p_poei_information24		in	varchar2	,
		p_poei_information25		in	varchar2	,
		p_poei_information26		in	varchar2	,
		p_poei_information27		in	varchar2	,
		p_poei_information28		in	varchar2	,
		p_poei_information29		in	varchar2	,
		p_poei_information30		in	varchar2	,
		p_object_version_number		in	number
	);
--
--  update_position_extra_info_a
--
Procedure update_position_extra_info_a
	(
		p_position_extra_info_id	in	number	,
		p_poei_attribute_category	in	varchar2	,
		p_poei_attribute1			in	varchar2	,
		p_poei_attribute2			in	varchar2	,
		p_poei_attribute3			in	varchar2	,
		p_poei_attribute4			in	varchar2	,
		p_poei_attribute5			in	varchar2	,
		p_poei_attribute6			in	varchar2	,
		p_poei_attribute7			in	varchar2	,
		p_poei_attribute8			in	varchar2	,
		p_poei_attribute9			in	varchar2	,
		p_poei_attribute10		in	varchar2	,
		p_poei_attribute11		in	varchar2	,
		p_poei_attribute12		in	varchar2	,
		p_poei_attribute13		in	varchar2	,
		p_poei_attribute14		in	varchar2	,
		p_poei_attribute15		in	varchar2	,
		p_poei_attribute16		in	varchar2	,
		p_poei_attribute17		in	varchar2	,
		p_poei_attribute18		in	varchar2	,
		p_poei_attribute19		in	varchar2	,
		p_poei_attribute20		in	varchar2	,
		p_poei_information_category	in	varchar2	,
		p_poei_information1		in	varchar2	,
		p_poei_information2		in	varchar2	,
		p_poei_information3		in	varchar2	,
		p_poei_information4		in	varchar2	,
		p_poei_information5		in	varchar2	,
		p_poei_information6		in	varchar2	,
		p_poei_information7		in	varchar2	,
		p_poei_information8		in	varchar2	,
		p_poei_information9		in	varchar2	,
		p_poei_information10		in	varchar2	,
		p_poei_information11		in	varchar2	,
		p_poei_information12		in	varchar2	,
		p_poei_information13		in	varchar2	,
		p_poei_information14		in	varchar2	,
		p_poei_information15		in	varchar2	,
		p_poei_information16		in	varchar2	,
		p_poei_information17		in	varchar2	,
		p_poei_information18		in	varchar2	,
		p_poei_information19		in	varchar2	,
		p_poei_information20		in	varchar2	,
		p_poei_information21		in	varchar2	,
		p_poei_information22		in	varchar2	,
		p_poei_information23		in	varchar2	,
		p_poei_information24		in	varchar2	,
		p_poei_information25		in	varchar2	,
		p_poei_information26		in	varchar2	,
		p_poei_information27		in	varchar2	,
		p_poei_information28		in	varchar2	,
		p_poei_information29		in	varchar2	,
		p_poei_information30		in	varchar2	,
		p_object_version_number		in	number
	);

end hr_position_extra_info_bk2;

 

/
