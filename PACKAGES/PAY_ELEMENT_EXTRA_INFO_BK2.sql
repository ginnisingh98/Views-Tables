--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_EXTRA_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_EXTRA_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: pyeeiapi.pkh 120.1 2005/10/02 02:30 aroussel $ */
--
--
-- update_element_extra_info_b
--
Procedure update_element_extra_info_b	(
		p_element_type_extra_info_id	in	number	,
		p_eei_attribute_category        in      varchar2,
                p_eei_attribute1                in      varchar2,
                p_eei_attribute2                in      varchar2,
                p_eei_attribute3                in      varchar2,
                p_eei_attribute4                in      varchar2,
                p_eei_attribute5                in      varchar2,
                p_eei_attribute6                in      varchar2,
                p_eei_attribute7                in      varchar2,
                p_eei_attribute8                in      varchar2,
                p_eei_attribute9                in      varchar2,
                p_eei_attribute10               in      varchar2,
                p_eei_attribute11               in      varchar2,
                p_eei_attribute12               in      varchar2,
                p_eei_attribute13               in      varchar2,
                p_eei_attribute14               in      varchar2,
                p_eei_attribute15               in      varchar2,
                p_eei_attribute16               in      varchar2,
                p_eei_attribute17               in      varchar2,
                p_eei_attribute18               in      varchar2,
                p_eei_attribute19               in      varchar2,
                p_eei_attribute20               in      varchar2,
                p_eei_information_category	in      varchar2,
		p_eei_information1		in	varchar2,
                p_eei_information2              in      varchar2,
                p_eei_information3              in      varchar2,
                p_eei_information4              in      varchar2,
                p_eei_information5              in      varchar2,
                p_eei_information6              in      varchar2,
                p_eei_information7              in      varchar2,
                p_eei_information8              in      varchar2,
                p_eei_information9              in      varchar2,
                p_eei_information10             in      varchar2,
                p_eei_information11             in      varchar2,
                p_eei_information12             in      varchar2,
                p_eei_information13             in      varchar2,
                p_eei_information14             in      varchar2,
                p_eei_information15             in      varchar2,
                p_eei_information16             in      varchar2,
                p_eei_information17             in      varchar2,
                p_eei_information18             in      varchar2,
                p_eei_information19             in      varchar2,
                p_eei_information20             in      varchar2,
                p_eei_information21             in      varchar2,
                p_eei_information22             in      varchar2,
                p_eei_information23             in      varchar2,
                p_eei_information24             in      varchar2,
                p_eei_information25             in      varchar2,
                p_eei_information26             in      varchar2,
                p_eei_information27             in      varchar2,
                p_eei_information28             in      varchar2,
                p_eei_information29             in      varchar2,
                p_eei_information30             in      varchar2,
                p_object_version_number	        in      number
	);
--
--  update_element_extra_info_a
--
Procedure update_element_extra_info_a
	(
		p_element_type_extra_info_id	in	number,
		p_eei_attribute_category        in      varchar2,
                p_eei_attribute1                in      varchar2,
                p_eei_attribute2                in      varchar2,
                p_eei_attribute3                in      varchar2,
                p_eei_attribute4                in      varchar2,
                p_eei_attribute5                in      varchar2,
                p_eei_attribute6                in      varchar2,
                p_eei_attribute7                in      varchar2,
                p_eei_attribute8                in      varchar2,
                p_eei_attribute9                in      varchar2,
                p_eei_attribute10               in      varchar2,
                p_eei_attribute11               in      varchar2,
                p_eei_attribute12               in      varchar2,
                p_eei_attribute13               in      varchar2,
                p_eei_attribute14               in      varchar2,
                p_eei_attribute15               in      varchar2,
                p_eei_attribute16               in      varchar2,
                p_eei_attribute17               in      varchar2,
                p_eei_attribute18               in      varchar2,
                p_eei_attribute19               in      varchar2,
                p_eei_attribute20               in      varchar2,
                p_eei_information_category	in      varchar2,
		p_eei_information1		in	varchar2,
                p_eei_information2              in      varchar2,
                p_eei_information3              in      varchar2,
                p_eei_information4              in      varchar2,
                p_eei_information5              in      varchar2,
                p_eei_information6              in      varchar2,
                p_eei_information7              in      varchar2,
                p_eei_information8              in      varchar2,
                p_eei_information9              in      varchar2,
                p_eei_information10             in      varchar2,
                p_eei_information11             in      varchar2,
                p_eei_information12             in      varchar2,
                p_eei_information13             in      varchar2,
                p_eei_information14             in      varchar2,
                p_eei_information15             in      varchar2,
                p_eei_information16             in      varchar2,
                p_eei_information17             in      varchar2,
                p_eei_information18             in      varchar2,
                p_eei_information19             in      varchar2,
                p_eei_information20             in      varchar2,
                p_eei_information21             in      varchar2,
                p_eei_information22             in      varchar2,
                p_eei_information23             in      varchar2,
                p_eei_information24             in      varchar2,
                p_eei_information25             in      varchar2,
                p_eei_information26             in      varchar2,
                p_eei_information27             in      varchar2,
                p_eei_information28             in      varchar2,
                p_eei_information29             in      varchar2,
                p_eei_information30             in      varchar2,
                p_object_version_number		in	number
	);

end pay_element_extra_info_bk2;

 

/
