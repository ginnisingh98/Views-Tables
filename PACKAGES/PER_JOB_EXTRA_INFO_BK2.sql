--------------------------------------------------------
--  DDL for Package PER_JOB_EXTRA_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_EXTRA_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: pejeiapi.pkh 120.1 2005/10/02 02:17:57 aroussel $ */
--
--
-- update_job_extra_info_b
--
Procedure update_job_extra_info_b	(
		p_job_extra_info_id		in	number	,
		p_jei_attribute_category	in	varchar2	,
		p_jei_attribute1			in	varchar2	,
		p_jei_attribute2			in	varchar2	,
		p_jei_attribute3			in	varchar2	,
		p_jei_attribute4			in	varchar2	,
		p_jei_attribute5			in	varchar2	,
		p_jei_attribute6			in	varchar2	,
		p_jei_attribute7			in	varchar2	,
		p_jei_attribute8			in	varchar2	,
		p_jei_attribute9			in	varchar2	,
		p_jei_attribute10			in	varchar2	,
		p_jei_attribute11			in	varchar2	,
		p_jei_attribute12			in	varchar2	,
		p_jei_attribute13			in	varchar2	,
		p_jei_attribute14			in	varchar2	,
		p_jei_attribute15			in	varchar2	,
		p_jei_attribute16			in	varchar2	,
		p_jei_attribute17			in	varchar2	,
		p_jei_attribute18			in	varchar2	,
		p_jei_attribute19			in	varchar2	,
		p_jei_attribute20			in	varchar2	,
		p_jei_information_category	in	varchar2	,
		p_jei_information1		in	varchar2	,
		p_jei_information2		in	varchar2	,
		p_jei_information3		in	varchar2	,
		p_jei_information4		in	varchar2	,
		p_jei_information5		in	varchar2	,
		p_jei_information6		in	varchar2	,
		p_jei_information7		in	varchar2	,
		p_jei_information8		in	varchar2	,
		p_jei_information9		in	varchar2	,
		p_jei_information10		in	varchar2	,
		p_jei_information11		in	varchar2	,
		p_jei_information12		in	varchar2	,
		p_jei_information13		in	varchar2	,
		p_jei_information14		in	varchar2	,
		p_jei_information15		in	varchar2	,
		p_jei_information16		in	varchar2	,
		p_jei_information17		in	varchar2	,
		p_jei_information18		in	varchar2	,
		p_jei_information19		in	varchar2	,
		p_jei_information20		in	varchar2	,
		p_jei_information21		in	varchar2	,
		p_jei_information22		in	varchar2	,
		p_jei_information23		in	varchar2	,
		p_jei_information24		in	varchar2	,
		p_jei_information25		in	varchar2	,
		p_jei_information26		in	varchar2	,
		p_jei_information27		in	varchar2	,
		p_jei_information28		in	varchar2	,
		p_jei_information29		in	varchar2	,
		p_jei_information30		in	varchar2	,
		p_object_version_number		in	number
	);
--
--  update_job_extra_info_a
--
Procedure update_job_extra_info_a
	(
		p_job_extra_info_id		in	number	,
		p_jei_attribute_category	in	varchar2	,
		p_jei_attribute1			in	varchar2	,
		p_jei_attribute2			in	varchar2	,
		p_jei_attribute3			in	varchar2	,
		p_jei_attribute4			in	varchar2	,
		p_jei_attribute5			in	varchar2	,
		p_jei_attribute6			in	varchar2	,
		p_jei_attribute7			in	varchar2	,
		p_jei_attribute8			in	varchar2	,
		p_jei_attribute9			in	varchar2	,
		p_jei_attribute10			in	varchar2	,
		p_jei_attribute11			in	varchar2	,
		p_jei_attribute12			in	varchar2	,
		p_jei_attribute13			in	varchar2	,
		p_jei_attribute14			in	varchar2	,
		p_jei_attribute15			in	varchar2	,
		p_jei_attribute16			in	varchar2	,
		p_jei_attribute17			in	varchar2	,
		p_jei_attribute18			in	varchar2	,
		p_jei_attribute19			in	varchar2	,
		p_jei_attribute20			in	varchar2	,
		p_jei_information_category	in	varchar2	,
		p_jei_information1		in	varchar2	,
		p_jei_information2		in	varchar2	,
		p_jei_information3		in	varchar2	,
		p_jei_information4		in	varchar2	,
		p_jei_information5		in	varchar2	,
		p_jei_information6		in	varchar2	,
		p_jei_information7		in	varchar2	,
		p_jei_information8		in	varchar2	,
		p_jei_information9		in	varchar2	,
		p_jei_information10		in	varchar2	,
		p_jei_information11		in	varchar2	,
		p_jei_information12		in	varchar2	,
		p_jei_information13		in	varchar2	,
		p_jei_information14		in	varchar2	,
		p_jei_information15		in	varchar2	,
		p_jei_information16		in	varchar2	,
		p_jei_information17		in	varchar2	,
		p_jei_information18		in	varchar2	,
		p_jei_information19		in	varchar2	,
		p_jei_information20		in	varchar2	,
		p_jei_information21		in	varchar2	,
		p_jei_information22		in	varchar2	,
		p_jei_information23		in	varchar2	,
		p_jei_information24		in	varchar2	,
		p_jei_information25		in	varchar2	,
		p_jei_information26		in	varchar2	,
		p_jei_information27		in	varchar2	,
		p_jei_information28		in	varchar2	,
		p_jei_information29		in	varchar2	,
		p_jei_information30		in	varchar2	,
		p_object_version_number		in	number
	);

end per_job_extra_info_bk2;

 

/