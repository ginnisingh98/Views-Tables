--------------------------------------------------------
--  DDL for Package HR_IN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_UTILITY" AUTHID CURRENT_USER as
/* $Header: hrinutil.pkh 120.3 2008/01/03 10:09:06 vdabgar ship $ */
FUNCTION per_in_full_name(
        p_first_name        IN VARCHAR2
       ,p_middle_names      IN VARCHAR2
       ,p_last_name         IN VARCHAR2
       ,p_known_as          IN VARCHAR2
       ,p_title             IN VARCHAR2
       ,p_suffix            IN VARCHAR2
       ,p_pre_name_adjunct  IN VARCHAR2
       ,p_per_information1  IN VARCHAR2
       ,p_per_information2  IN VARCHAR2
       ,p_per_information3  IN VARCHAR2
       ,p_per_information4  IN VARCHAR2
       ,p_per_information5  IN VARCHAR2
       ,p_per_information6  IN VARCHAR2
       ,p_per_information7  IN VARCHAR2
       ,p_per_information8  IN VARCHAR2
       ,p_per_information9  IN VARCHAR2
       ,p_per_information10 IN VARCHAR2
       ,p_per_information11 IN VARCHAR2
       ,p_per_information12 IN VARCHAR2
       ,p_per_information13 IN VARCHAR2
       ,p_per_information14 IN VARCHAR2
       ,p_per_information15 IN VARCHAR2
       ,p_per_information16 IN VARCHAR2
       ,p_per_information17 IN VARCHAR2
       ,p_per_information18 IN VARCHAR2
       ,p_per_information19 IN VARCHAR2
       ,p_per_information20 IN VARCHAR2
       ,p_per_information21 IN VARCHAR2
       ,p_per_information22 IN VARCHAR2
       ,p_per_information23 IN VARCHAR2
       ,p_per_information24 IN VARCHAR2
       ,p_per_information25 IN VARCHAR2
       ,p_per_information26 IN VARCHAR2
       ,p_per_information27 IN VARCHAR2
       ,p_per_information28 IN VARCHAR2
       ,p_per_information29 IN VARCHAR2
       ,p_per_information30 IN VARCHAR2
       ) RETURN VARCHAR2 ;

FUNCTION per_in_full_name(
        p_first_name        IN VARCHAR2
       ,p_middle_names      IN VARCHAR2
       ,p_last_name         IN VARCHAR2
       ,p_title             IN VARCHAR2
       ) RETURN VARCHAR2 ;

PROCEDURE derive_hr_loc_address(
                        p_tax_name                  IN VARCHAR2,
                        p_style                     IN VARCHAR2,
                        p_address_line_1            IN VARCHAR2,
                        p_address_line_2            IN VARCHAR2,
                        p_address_line_3            IN VARCHAR2,
                        p_town_or_city              IN VARCHAR2,
                        p_country                   IN VARCHAR2,
                        p_postal_code               IN VARCHAR2,
                        p_region_1                  IN VARCHAR2,
                        p_region_2                  IN VARCHAR2,
                        p_region_3                  IN VARCHAR2,
                        p_telephone_number_1        IN VARCHAR2,
                        p_telephone_number_2        IN VARCHAR2,
                        p_telephone_number_3        IN VARCHAR2,
                        p_loc_information13         IN VARCHAR2,
                        p_loc_information14         IN VARCHAR2,
                        p_loc_information15         IN VARCHAR2,
                        p_loc_information16         IN VARCHAR2,
                        p_loc_information17         IN VARCHAR2,
                        p_attribute_category        IN VARCHAR2,
                        p_attribute1                IN VARCHAR2,
                        p_attribute2                IN VARCHAR2,
                        p_attribute3                IN VARCHAR2,
                        p_attribute4                IN VARCHAR2,
                        p_attribute5                IN VARCHAR2,
                        p_attribute6                IN VARCHAR2,
                        p_attribute7                IN VARCHAR2,
                        p_attribute8                IN VARCHAR2,
                        p_attribute9                IN VARCHAR2,
                        p_attribute10               IN VARCHAR2,
                        p_attribute11               IN VARCHAR2,
                        p_attribute12               IN VARCHAR2,
                        p_attribute13               IN VARCHAR2,
                        p_attribute14               IN VARCHAR2,
                        p_attribute15               IN VARCHAR2,
                        p_attribute16               IN VARCHAR2,
                        p_attribute17               IN VARCHAR2,
                        p_attribute18               IN VARCHAR2,
                        p_attribute19               IN VARCHAR2,
                        p_attribute20               IN VARCHAR2,
                        p_global_attribute_category IN VARCHAR2,
                        p_global_attribute1         IN VARCHAR2,
                        p_global_attribute2         IN VARCHAR2,
                        p_global_attribute3         IN VARCHAR2,
                        p_global_attribute4         IN VARCHAR2,
                        p_global_attribute5         IN VARCHAR2,
                        p_global_attribute6         IN VARCHAR2,
                        p_global_attribute7         IN VARCHAR2,
                        p_global_attribute8         IN VARCHAR2,
                        p_global_attribute9         IN VARCHAR2,
                        p_global_attribute10        IN VARCHAR2,
                        p_global_attribute11        IN VARCHAR2,
                        p_global_attribute12        IN VARCHAR2,
                        p_global_attribute13        IN VARCHAR2,
                        p_global_attribute14        IN VARCHAR2,
                        p_global_attribute15        IN VARCHAR2,
                        p_global_attribute16        IN VARCHAR2,
                        p_global_attribute17        IN VARCHAR2,
                        p_global_attribute18        IN VARCHAR2,
                        p_global_attribute19        IN VARCHAR2,
                        p_global_attribute20        IN VARCHAR2,
                        p_loc_information18         IN VARCHAR2,
                        p_loc_information19         IN VARCHAR2,
                        p_loc_information20         IN VARCHAR2,
                        p_derived_locale            OUT NOCOPY VARCHAR2
                       );
end hr_in_utility;

/
