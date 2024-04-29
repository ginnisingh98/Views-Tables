--------------------------------------------------------
--  DDL for Package Body HR_CN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CN_UTILITY" as
/* $Header: hrcnutil.pkb 120.1 2008/01/04 06:37:42 mdubasi ship $ */
FUNCTION per_cn_full_name(
        p_first_name        in varchar2
       ,p_middle_names      in varchar2
       ,p_last_name         in varchar2
       ,p_known_as          in varchar2
       ,p_title             in varchar2
       ,p_suffix            in varchar2
       ,p_pre_name_adjunct  in varchar2
       ,p_per_information1  in varchar2
       ,p_per_information2  in varchar2
       ,p_per_information3  in varchar2
       ,p_per_information4  in varchar2
       ,p_per_information5  in varchar2
       ,p_per_information6  in varchar2
       ,p_per_information7  in varchar2
       ,p_per_information8  in varchar2
       ,p_per_information9  in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in varchar2
       ) return varchar2 as
  l_full_name       VARCHAR2(240);
BEGIN
    IF p_per_information8 = 'N'
    THEN
	l_full_name := p_last_name||p_first_name;
    ELSE
	l_full_name := HR_US_UTILITY.per_us_full_name
		       (
		         p_first_name       => p_first_name
			,p_middle_names     => p_middle_names
			,p_last_name        => p_last_name
			,p_known_as         => p_known_as
			,p_title            => p_title
			,p_suffix           => p_suffix
			,p_pre_name_adjunct => p_pre_name_adjunct
                       );
    END IF;
    RETURN (l_full_name);

END per_cn_full_name;

FUNCTION per_cn_order_name(
        p_first_name        in varchar2
       ,p_middle_names      in varchar2
       ,p_last_name         in varchar2
       ,p_known_as          in varchar2
       ,p_title             in varchar2
       ,p_suffix            in varchar2
       ,p_pre_name_adjunct  in varchar2
       ,p_per_information1  in varchar2
       ,p_per_information2  in varchar2
       ,p_per_information3  in varchar2
       ,p_per_information4  in varchar2
       ,p_per_information5  in varchar2
       ,p_per_information6  in varchar2
       ,p_per_information7  in varchar2
       ,p_per_information8  in varchar2
       ,p_per_information9  in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in varchar2
       ) return varchar2 as
  l_order_name       VARCHAR2(240);
BEGIN
    IF p_per_information8 = 'N'
    THEN
    /*Changed the order_name construction w.r.t bug 3075230*/
	l_order_name := p_last_name||p_first_name;
    ELSE
	l_order_name := HR_US_UTILITY.per_us_full_name
		       (
		         p_first_name       => p_first_name
			,p_middle_names     => p_middle_names
			,p_last_name        => p_last_name
			,p_known_as         => p_known_as
			,p_title            => p_title
			,p_suffix           => p_suffix
			,p_pre_name_adjunct => p_pre_name_adjunct
                       );
    /*Bug 3075230 changes end here*/
    END IF;
    RETURN (l_order_name);
END per_cn_order_name;
/*Added this procedure w.r.t Bug 6713884*/
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
                        p_derived_locale           OUT NOCOPY VARCHAR2
                       ) is
BEGIN
   if (ltrim(p_town_or_city) is not null) then
    p_derived_locale := hr_general.decode_lookup('CN_PROVINCE',p_town_or_city) || ', ';
  end if;
  if (ltrim(p_region_2) is not null) then
    p_derived_locale := p_derived_locale || p_region_2 || ', ';
  end if;
  if (ltrim(p_country) is null) then
    p_derived_locale := rtrim(p_derived_locale, ',');
  else
    p_derived_locale := p_derived_locale || p_country;
  end if;
END;
/*Bug 6713884 ends*/
END hr_cn_utility;

/
