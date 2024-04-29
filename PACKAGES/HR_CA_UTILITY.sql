--------------------------------------------------------
--  DDL for Package HR_CA_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CA_UTILITY" AUTHID CURRENT_USER AS
/* $Header: hrcautil.pkh 120.0.12000000.2 2007/03/07 06:04:56 amigarg ship $ */
--
FUNCTION per_ca_full_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2 default hr_api.g_varchar2
       ,p_per_information2 in varchar2 default hr_api.g_varchar2
       ,p_per_information3 in varchar2 default hr_api.g_varchar2
       ,p_per_information4 in varchar2 default hr_api.g_varchar2
       ,p_per_information5 in varchar2 default hr_api.g_varchar2
       ,p_per_information6 in varchar2 default hr_api.g_varchar2
       ,p_per_information7 in varchar2 default hr_api.g_varchar2
       ,p_per_information8 in varchar2 default hr_api.g_varchar2
       ,p_per_information9 in varchar2 default hr_api.g_varchar2
       ,p_per_information10 in varchar2 default hr_api.g_varchar2
       ,p_per_information11 in varchar2 default hr_api.g_varchar2
       ,p_per_information12 in varchar2 default hr_api.g_varchar2
       ,p_per_information13 in varchar2 default hr_api.g_varchar2
       ,p_per_information14 in varchar2 default hr_api.g_varchar2
       ,p_per_information15 in varchar2 default hr_api.g_varchar2
       ,p_per_information16 in varchar2 default hr_api.g_varchar2
       ,p_per_information17 in varchar2 default hr_api.g_varchar2
       ,p_per_information18 in varchar2 default hr_api.g_varchar2
       ,p_per_information19 in varchar2 default hr_api.g_varchar2
       ,p_per_information20 in varchar2 default hr_api.g_varchar2
       ,p_per_information21 in varchar2 default hr_api.g_varchar2
       ,p_per_information22 in varchar2 default hr_api.g_varchar2
       ,p_per_information23 in varchar2 default hr_api.g_varchar2
       ,p_per_information24 in varchar2 default hr_api.g_varchar2
       ,p_per_information25 in varchar2 default hr_api.g_varchar2
       ,p_per_information26 in varchar2 default hr_api.g_varchar2
       ,p_per_information27 in varchar2 default hr_api.g_varchar2
       ,p_per_information28 in varchar2 default hr_api.g_varchar2
       ,p_per_information29 in varchar2 default hr_api.g_varchar2
	,p_per_information30 in VARCHAR2 default hr_api.g_varchar2
	)
   RETURN VARCHAR2;
--
FUNCTION per_ca_order_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2 default hr_api.g_varchar2
       ,p_per_information2 in varchar2 default hr_api.g_varchar2
       ,p_per_information3 in varchar2 default hr_api.g_varchar2
       ,p_per_information4 in varchar2 default hr_api.g_varchar2
       ,p_per_information5 in varchar2 default hr_api.g_varchar2
       ,p_per_information6 in varchar2 default hr_api.g_varchar2
       ,p_per_information7 in varchar2 default hr_api.g_varchar2
       ,p_per_information8 in varchar2 default hr_api.g_varchar2
       ,p_per_information9 in varchar2 default hr_api.g_varchar2
       ,p_per_information10 in varchar2 default hr_api.g_varchar2
       ,p_per_information11 in varchar2 default hr_api.g_varchar2
       ,p_per_information12 in varchar2 default hr_api.g_varchar2
       ,p_per_information13 in varchar2 default hr_api.g_varchar2
       ,p_per_information14 in varchar2 default hr_api.g_varchar2
       ,p_per_information15 in varchar2 default hr_api.g_varchar2
       ,p_per_information16 in varchar2 default hr_api.g_varchar2
       ,p_per_information17 in varchar2 default hr_api.g_varchar2
       ,p_per_information18 in varchar2 default hr_api.g_varchar2
       ,p_per_information19 in varchar2 default hr_api.g_varchar2
       ,p_per_information20 in varchar2 default hr_api.g_varchar2
       ,p_per_information21 in varchar2 default hr_api.g_varchar2
       ,p_per_information22 in varchar2 default hr_api.g_varchar2
       ,p_per_information23 in varchar2 default hr_api.g_varchar2
       ,p_per_information24 in varchar2 default hr_api.g_varchar2
       ,p_per_information25 in varchar2 default hr_api.g_varchar2
       ,p_per_information26 in varchar2 default hr_api.g_varchar2
       ,p_per_information27 in varchar2 default hr_api.g_varchar2
       ,p_per_information28 in varchar2 default hr_api.g_varchar2
       ,p_per_information29 in varchar2 default hr_api.g_varchar2
       ,p_per_information30 in VARCHAR2 default hr_api.g_varchar2
      )
  RETURN VARCHAR2;
--
procedure DERIVE_HR_LOC_ADDRESS
                       (p_tax_name                  in varchar2,
                        p_style                     in varchar2,
                        p_address_line_1            in varchar2,
                        p_address_line_2            in varchar2,
                        p_address_line_3            in varchar2,
                        p_town_or_city              in varchar2,
                        p_country                   in varchar2,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_loc_information13         in varchar2,
                        p_loc_information14         in varchar2,
                        p_loc_information15         in varchar2,
                        p_loc_information16         in varchar2,
                        p_loc_information17         in varchar2,
                        p_attribute_category        in varchar2,
                        p_attribute1                in varchar2,
                        p_attribute2                in varchar2,
                        p_attribute3                in varchar2,
                        p_attribute4                in varchar2,
                        p_attribute5                in varchar2,
                        p_attribute6                in varchar2,
                        p_attribute7                in varchar2,
                        p_attribute8                in varchar2,
                        p_attribute9                in varchar2,
                        p_attribute10               in varchar2,
                        p_attribute11               in varchar2,
                        p_attribute12               in varchar2,
                        p_attribute13               in varchar2,
                        p_attribute14               in varchar2,
                        p_attribute15               in varchar2,
                        p_attribute16               in varchar2,
                        p_attribute17               in varchar2,
                        p_attribute18               in varchar2,
                        p_attribute19               in varchar2,
                        p_attribute20               in varchar2,
                        p_global_attribute_category in varchar2,
                        p_global_attribute1         in varchar2,
                        p_global_attribute2         in varchar2,
                        p_global_attribute3         in varchar2,
                        p_global_attribute4         in varchar2,
                        p_global_attribute5         in varchar2,
                        p_global_attribute6         in varchar2,
                        p_global_attribute7         in varchar2,
                        p_global_attribute8         in varchar2,
                        p_global_attribute9         in varchar2,
                        p_global_attribute10        in varchar2,
                        p_global_attribute11        in varchar2,
                        p_global_attribute12        in varchar2,
                        p_global_attribute13        in varchar2,
                        p_global_attribute14        in varchar2,
                        p_global_attribute15        in varchar2,
                        p_global_attribute16        in varchar2,
                        p_global_attribute17        in varchar2,
                        p_global_attribute18        in varchar2,
                        p_global_attribute19        in varchar2,
                        p_global_attribute20        in varchar2,
                        p_loc_information18         in varchar2,
                        p_loc_information19         in varchar2,
                        p_loc_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2
                       );
--
procedure DERIVE_PER_ADD_ADDRESS
                       (p_style                     in varchar2,
                        p_address_line1             in varchar2,
                        p_address_line2             in varchar2,
                        p_address_line3             in varchar2,
                        p_country                   in varchar2,
                        p_date_to                   in date,
                        p_postal_code               in varchar2,
                        p_region_1                  in varchar2,
                        p_region_2                  in varchar2,
                        p_region_3                  in varchar2,
                        p_telephone_number_1        in varchar2,
                        p_telephone_number_2        in varchar2,
                        p_telephone_number_3        in varchar2,
                        p_town_or_city              in varchar2,
                        p_addr_attribute_category   in varchar2,
                        p_addr_attribute1           in varchar2,
                        p_addr_attribute2           in varchar2,
                        p_addr_attribute3           in varchar2,
                        p_addr_attribute4           in varchar2,
                        p_addr_attribute5           in varchar2,
                        p_addr_attribute6           in varchar2,
                        p_addr_attribute7           in varchar2,
                        p_addr_attribute8           in varchar2,
                        p_addr_attribute9           in varchar2,
                        p_addr_attribute10          in varchar2,
                        p_addr_attribute11          in varchar2,
                        p_addr_attribute12          in varchar2,
                        p_addr_attribute13          in varchar2,
                        p_addr_attribute14          in varchar2,
                        p_addr_attribute15          in varchar2,
                        p_addr_attribute16          in varchar2,
                        p_addr_attribute17          in varchar2,
                        p_addr_attribute18          in varchar2,
                        p_addr_attribute19          in varchar2,
                        p_addr_attribute20          in varchar2,
		 	p_add_information13         in varchar2,
			p_add_information14         in varchar2,
			p_add_information15         in varchar2,
			p_add_information16         in varchar2,
                        p_add_information17         in varchar2,
                        p_add_information18         in varchar2,
                        p_add_information19         in varchar2,
                        p_add_information20         in varchar2,
                        p_derived_locale           out nocopy varchar2);
--
END HR_CA_UTILITY;

 

/
