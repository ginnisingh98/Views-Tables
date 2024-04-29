--------------------------------------------------------
--  DDL for Package Body PER_JP_DEPENDENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_DEPENDENT_PKG" AS
/* $Header: pejpdepf.pkb 115.3 2003/12/09 22:12:09 ttagawa noship $ */
 --
 FUNCTION address_count(
  p_person_id		IN	NUMBER,
  p_effective_date	IN 	DATE)	RETURN NUMBER IS
  --
  CURSOR cel_address_exist IS
   SELECT COUNT(person_id) FROM per_addresses
   WHERE person_id = p_person_id
   AND p_effective_date BETWEEN date_from AND NVL(date_to,p_effective_date);
  --
  l_address_count	NUMBER;
 BEGIN
  --
  OPEN cel_address_exist;
  FETCH cel_address_exist INTO l_address_count;
  CLOSE cel_address_exist;
  --
  RETURN(l_address_count);
  --
 END address_count;
 --
 FUNCTION address_style(
  p_style		IN	VARCHAR2) RETURN VARCHAR2 IS
  --
  CURSOR cel_address_style IS
   SELECT descriptive_flex_context_name
   FROM fnd_descr_flex_contexts_vl
   WHERE application_id = 800
   AND descriptive_flexfield_name = 'Address Structure'
   AND descriptive_flex_context_code = p_style
   AND enabled_flag = 'Y'
   AND descriptive_flex_context_code NOT IN ('Global Data Elements','GENERIC')
   AND (hr_general.chk_geocodes_installed = 'Y'
    OR descriptive_flex_context_code NOT IN ('CA','US'));
  --
  l_style_meaning	VARCHAR2(80);
  --
 BEGIN
  --
  OPEN cel_address_style;
  FETCH cel_address_style INTO l_style_meaning;
  CLOSE cel_address_style;
  --
  RETURN l_style_meaning;
  --
 END address_style;
 --
 PROCEDURE address_detail(
  p_person_id			IN	NUMBER,
  p_effective_date		IN	DATE,
  p_address_type_meaning OUT NOCOPY VARCHAR2,
  p_style		 OUT NOCOPY VARCHAR2,
  p_primary_flag	 OUT NOCOPY VARCHAR2,
  p_address_line1	 OUT NOCOPY VARCHAR2,
  p_address_line2	 OUT NOCOPY VARCHAR2,
  p_address_line3	 OUT NOCOPY VARCHAR2,
  p_country		 OUT NOCOPY VARCHAR2,
  p_postal_code		 OUT NOCOPY VARCHAR2,
  p_region_1		 OUT NOCOPY VARCHAR2,
  p_region_2		 OUT NOCOPY VARCHAR2,
  p_region_3		 OUT NOCOPY VARCHAR2,
  p_telephone_number_1	 OUT NOCOPY VARCHAR2,
  p_telephone_number_2	 OUT NOCOPY VARCHAR2,
  p_telephone_number_3	 OUT NOCOPY VARCHAR2,
  p_town_or_city	 OUT NOCOPY VARCHAR2,
  p_add_information13	 OUT NOCOPY VARCHAR2,
  p_add_information14	 OUT NOCOPY VARCHAR2,
  p_add_information15	 OUT NOCOPY VARCHAR2,
  p_add_information16	 OUT NOCOPY VARCHAR2,
  p_add_information17	 OUT NOCOPY VARCHAR2,
  p_add_information18	 OUT NOCOPY VARCHAR2,
  p_add_information19	 OUT NOCOPY VARCHAR2,
  p_add_information20	 OUT NOCOPY VARCHAR2,
  p_date_from		 OUT NOCOPY DATE,
  p_date_to		 OUT NOCOPY DATE) IS
  --
  CURSOR cel_address_detail IS
   SELECT
    SUBSTRB(hr_general.decode_lookup('ADDRESS_TYPE',address_type),1,80) address_type_meaning,
    style,
    primary_flag,
    address_line1,
    address_line2,
    address_line3,
    country,
    postal_code,
    region_1,
    region_2,
    region_3,
    telephone_number_1,
    telephone_number_2,
    telephone_number_3,
    town_or_city,
    add_information13,
    add_information14,
    add_information15,
    add_information16,
    add_information17,
    add_information18,
    add_information19,
    add_information20,
    date_from,
    date_to
   FROM per_addresses
   WHERE person_id = p_person_id
   AND p_effective_date BETWEEN date_from AND NVL(date_to,p_effective_date);
  --
  celrec_address_detail		cel_address_detail%ROWTYPE;
  --
 BEGIN
  --
  OPEN cel_address_detail;
  FETCH cel_address_detail INTO celrec_address_detail;
  --
  p_address_type_meaning := celrec_address_detail.address_type_meaning;
  p_style := celrec_address_detail.style;
  p_primary_flag := celrec_address_detail.primary_flag;
  p_date_from := celrec_address_detail.date_from;
  p_date_to := celrec_address_detail.date_to;
  p_address_line1 := celrec_address_detail.address_line1;
  p_address_line2 := celrec_address_detail.address_line2;
  p_address_line3 := celrec_address_detail.address_line3;
  p_country := celrec_address_detail.country;
  p_postal_code := celrec_address_detail.postal_code;
  p_region_1 := celrec_address_detail.region_1;
  p_region_2 := celrec_address_detail.region_2;
  p_region_3 := celrec_address_detail.region_3;
  p_telephone_number_1 := celrec_address_detail.telephone_number_1;
  p_telephone_number_2 := celrec_address_detail.telephone_number_2;
  p_telephone_number_3 := celrec_address_detail.telephone_number_3;
  p_town_or_city := celrec_address_detail.town_or_city;
  p_add_information13 := celrec_address_detail.add_information13;
  p_add_information14 := celrec_address_detail.add_information14;
  p_add_information15 := celrec_address_detail.add_information15;
  p_add_information16 := celrec_address_detail.add_information16;
  p_add_information17 := celrec_address_detail.add_information17;
  p_add_information18 := celrec_address_detail.add_information18;
  p_add_information19 := celrec_address_detail.add_information19;
  p_add_information20 := celrec_address_detail.add_information20;
  --
  CLOSE cel_address_detail;
  --
 END address_detail;
 --
 PROCEDURE populate_address_fields(
  p_person_id		  IN	NUMBER,
  p_effective_date	  IN	DATE,
  p_count		  OUT NOCOPY NUMBER,
  p_d_address_type	  OUT NOCOPY VARCHAR2,
  p_style		  OUT NOCOPY VARCHAR2,
  p_d_style		  OUT NOCOPY VARCHAR2,
  p_primary_flag	  OUT NOCOPY VARCHAR2,
  p_address_line1         OUT NOCOPY VARCHAR2,
  p_address_line2         OUT NOCOPY   VARCHAR2,
  p_address_line3         OUT NOCOPY   VARCHAR2,
  p_country               OUT NOCOPY   VARCHAR2,
  p_postal_code           OUT NOCOPY   VARCHAR2,
  p_region_1              OUT NOCOPY   VARCHAR2,
  p_region_2              OUT NOCOPY   VARCHAR2,
  p_region_3              OUT NOCOPY   VARCHAR2,
  p_telephone_number_1    OUT NOCOPY   VARCHAR2,
  p_telephone_number_2    OUT NOCOPY   VARCHAR2,
  p_telephone_number_3    OUT NOCOPY   VARCHAR2,
  p_town_or_city          OUT NOCOPY   VARCHAR2,
  p_add_information13     OUT NOCOPY   VARCHAR2,
  p_add_information14     OUT NOCOPY   VARCHAR2,
  p_add_information15     OUT NOCOPY   VARCHAR2,
  p_add_information16     OUT NOCOPY   VARCHAR2,
  p_add_information17     OUT NOCOPY   VARCHAR2,
  p_add_information18     OUT NOCOPY   VARCHAR2,
  p_add_information19     OUT NOCOPY   VARCHAR2,
  p_add_information20     OUT NOCOPY   VARCHAR2,
  p_date_from		  OUT NOCOPY DATE,
  p_date_to	  	  OUT NOCOPY DATE) IS
  --
  l_address_count	NUMBER := address_count(p_person_id, p_effective_date);
  --
 BEGIN
  --
  p_count := l_address_count;
  --
  IF l_address_count = 0 THEN
   --
   p_d_address_type := NULL;
   p_style := NULL;
   p_d_style := NULL;
   p_primary_flag := NULL;
   p_address_line1 := NULL;
   p_address_line2 := NULL;
   p_address_line3 := NULL;
   p_country := NULL;
   p_postal_code := NULL;
   p_region_1 := NULL;
   p_region_2 := NULL;
   p_region_3 := NULL;
   p_telephone_number_1 := NULL;
   p_telephone_number_2 := NULL;
   p_telephone_number_3 := NULL;
   p_town_or_city := NULL;
   p_add_information13 := NULL;
   p_add_information14 := NULL;
   p_add_information15 := NULL;
   p_add_information16 := NULL;
   p_add_information17 := NULL;
   p_add_information18 := NULL;
   p_add_information19 := NULL;
   p_add_information20 := NULL;
   p_date_from := NULL;
   p_date_to := NULL;
   --
  ELSIF l_address_count = 1 THEN
   --
   address_detail(
    p_person_id			=> p_person_id,
    p_effective_date 		=> p_effective_date,
    p_address_type_meaning 	=> p_d_address_type,
    p_style          		=> p_style,
    p_primary_flag   		=> p_primary_flag,
    p_address_line1		=> p_address_line1,
    p_address_line2		=> p_address_line2,
    p_address_line3		=> p_address_line3,
    p_country			=> p_country,
    p_postal_code		=> p_postal_code,
    p_region_1			=> p_region_1,
    p_region_2			=> p_region_2,
    p_region_3 			=> p_region_3,
    p_telephone_number_1	=> p_telephone_number_1,
    p_telephone_number_2	=> p_telephone_number_2,
    p_telephone_number_3	=> p_telephone_number_3,
    p_town_or_city		=> p_town_or_city,
    p_add_information13		=> p_add_information13,
    p_add_information14		=> p_add_information14,
    p_add_information15   	=> p_add_information15,
    p_add_information16   	=> p_add_information16,
    p_add_information17   	=> p_add_information17,
    p_add_information18   	=> p_add_information18,
    p_add_information19   	=> p_add_information19,
    p_add_information20   	=> p_add_information20,
    p_date_from      		=> p_date_from,
    p_date_to        		=> p_date_to);
   --
   p_d_style := address_style(p_style);
   --
  ELSE
   --
   hr_utility.set_message(
    applid         => 800,
    l_message_name => 'PER_JP_ALL_COUNT_ADDRESSES');
   --
   p_d_address_type := '** ' || l_address_count || ' ' || hr_utility.get_message;
   p_style := NULL;
   p_d_style := NULL;
   p_primary_flag := NULL;
   p_address_line1 := NULL;
   p_address_line2 := NULL;
   p_address_line3 := NULL;
   p_country := NULL;
   p_postal_code := NULL;
   p_region_1 := NULL;
   p_region_2 := NULL;
   p_region_3 := NULL;
   p_telephone_number_1 := NULL;
   p_telephone_number_2 := NULL;
   p_telephone_number_3 := NULL;
   p_town_or_city := NULL;
   p_add_information13 := NULL;
   p_add_information14 := NULL;
   p_add_information15 := NULL;
   p_add_information16 := NULL;
   p_add_information17 := NULL;
   p_add_information18 := NULL;
   p_add_information19 := NULL;
   p_add_information20 := NULL;
   p_date_from := NULL;
   p_date_to := NULL;
   --
  END IF;
  --
 END populate_address_fields;
 --
 FUNCTION phone_count(
  p_person_id           IN      NUMBER,
  p_effective_date      IN      DATE)   RETURN NUMBER IS
  --
  CURSOR cel_phone_exist IS
   SELECT COUNT(parent_id) FROM per_phones
   WHERE parent_id = p_person_id
   AND parent_table = 'PER_ALL_PEOPLE_F'
   AND p_effective_date BETWEEN date_from AND NVL(date_to,p_effective_date);
  --
  l_phone_count       NUMBER;
  --
 BEGIN
  --
  OPEN cel_phone_exist;
  FETCH cel_phone_exist INTO l_phone_count;
  CLOSE cel_phone_exist;
  --
  RETURN(l_phone_count);
  --
 END phone_count;
 --
 PROCEDURE phone_detail(
  p_person_id		  IN	NUMBER,
  p_effective_date	  IN	DATE,
  p_phone_type_meaning	  OUT NOCOPY VARCHAR2,
  p_phone_number	  OUT NOCOPY VARCHAR2,
  p_date_from		  OUT NOCOPY DATE,
  p_date_to		  OUT NOCOPY DATE) IS
  --
  CURSOR cel_phone_detail IS
   SELECT
    SUBSTRB(hr_general.decode_lookup('PHONE_TYPE',phone_type),1,80) phone_type_meaning,
    phone_number,
    date_from,
    date_to
   FROM per_phones
   WHERE parent_id = p_person_id
   AND parent_table = 'PER_ALL_PEOPLE_F'
   AND p_effective_date BETWEEN date_from AND NVL(date_to,p_effective_date);
  --
  celrec_phone_detail		cel_phone_detail%ROWTYPE;
  --
 BEGIN
  --
  OPEN cel_phone_detail;
  FETCH cel_phone_detail INTO celrec_phone_detail;
  --
  p_phone_type_meaning := celrec_phone_detail.phone_type_meaning;
  p_phone_number := celrec_phone_detail.phone_number;
  p_date_from := celrec_phone_detail.date_from;
  p_date_to := celrec_phone_detail.date_to;
  --
  CLOSE cel_phone_detail;
  --
 END phone_detail;
 --
 PROCEDURE populate_phone_fields(
  p_person_id		  IN	NUMBER,
  p_effective_date	  IN	DATE,
  p_count		  OUT NOCOPY NUMBER,
  p_d_phone_type	  OUT NOCOPY VARCHAR2,
  p_phone_number	  OUT NOCOPY VARCHAR2,
  p_date_from		  OUT NOCOPY DATE,
  p_date_to		  OUT NOCOPY DATE) IS
  --
  l_phone_count		NUMBER := phone_count(p_person_id,p_effective_date);
  --
 BEGIN
  --
  p_count := l_phone_count;
  --
  IF l_phone_count = 0 THEN
   --
   p_d_phone_type := NULL;
   p_phone_number := NULL;
   p_date_from := NULL;
   p_date_to := NULL;
   --
  ELSIF l_phone_count = 1 THEN
   --
   phone_detail(
    p_person_id		    => p_person_id,
    p_effective_date	    => p_effective_date,
    p_phone_type_meaning    => p_d_phone_type,
    p_phone_number	    => p_phone_number,
    p_date_from		    => p_date_from,
    p_date_to		    => p_date_to);
   --
  ELSE
   --
   hr_utility.set_message(
    applid         => 800,
    l_message_name => 'PER_JP_ALL_COUNT_PHONES');
   --
   p_d_phone_type := '** ' || l_phone_count || ' ' || hr_utility.get_message;
   p_phone_number := NULL;
   p_date_from := NULL;
   p_date_to := NULL;
   --
  END IF;
  --
 END populate_phone_fields;
 --
 FUNCTION extra_info_count(
  p_contact_relationship_id	IN	NUMBER,
  p_effective_date 		IN      DATE,
  p_information_type_group	IN	VARCHAR2)   RETURN NUMBER IS
  --
  CURSOR cel_extra_info_exist IS
   SELECT COUNT(contact_relationship_id) FROM per_contact_extra_info_f
   WHERE contact_relationship_id = p_contact_relationship_id
   AND information_type LIKE p_information_type_group || '%'
   AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
  l_extra_info_count		NUMBER;
 BEGIN
  --
  OPEN cel_extra_info_exist;
  FETCH cel_extra_info_exist INTO l_extra_info_count;
  CLOSE cel_extra_info_exist;
  --
  RETURN(l_extra_info_count);
  --
 END extra_info_count;
 --
 PROCEDURE extra_info_detail(
  p_contact_relationship_id	IN	NUMBER,
  p_effective_date		IN	DATE,
  p_information_type_group	IN	VARCHAR2,
  p_contact_extra_info_id OUT NOCOPY NUMBER,
  p_information_type	 OUT NOCOPY VARCHAR2,
  p_d_information_type	 OUT NOCOPY VARCHAR2,
  p_cei_information_category OUT NOCOPY VARCHAR2,
  p_cei_information1	 OUT NOCOPY VARCHAR2,
  p_cei_information2	 OUT NOCOPY VARCHAR2,
  p_cei_information3	 OUT NOCOPY VARCHAR2,
  p_cei_information4	 OUT NOCOPY VARCHAR2,
  p_cei_information5	 OUT NOCOPY VARCHAR2,
  p_cei_information6	 OUT NOCOPY VARCHAR2,
  p_cei_information7	 OUT NOCOPY VARCHAR2,
  p_cei_information8	 OUT NOCOPY VARCHAR2,
  p_cei_information9	 OUT NOCOPY VARCHAR2,
  p_cei_information10	 OUT NOCOPY VARCHAR2,
  p_cei_information11	 OUT NOCOPY VARCHAR2,
  p_cei_information12	 OUT NOCOPY VARCHAR2,
  p_cei_information13	 OUT NOCOPY VARCHAR2,
  p_cei_information14	 OUT NOCOPY VARCHAR2,
  p_cei_information15	 OUT NOCOPY VARCHAR2,
  p_cei_information16	 OUT NOCOPY VARCHAR2,
  p_cei_information17	 OUT NOCOPY VARCHAR2,
  p_cei_information18	 OUT NOCOPY VARCHAR2,
  p_cei_information19	 OUT NOCOPY VARCHAR2,
  p_cei_information20	 OUT NOCOPY VARCHAR2,
  p_cei_information21	 OUT NOCOPY VARCHAR2,
  p_cei_information22	 OUT NOCOPY VARCHAR2,
  p_cei_information23	 OUT NOCOPY VARCHAR2,
  p_cei_information24	 OUT NOCOPY VARCHAR2,
  p_cei_information25	 OUT NOCOPY VARCHAR2,
  p_cei_information26	 OUT NOCOPY VARCHAR2,
  p_cei_information27	 OUT NOCOPY VARCHAR2,
  p_cei_information28	 OUT NOCOPY VARCHAR2,
  p_cei_information29	 OUT NOCOPY VARCHAR2,
  p_cei_information30	 OUT NOCOPY VARCHAR2,
  p_effective_start_date OUT NOCOPY DATE,
  p_effective_end_date	 OUT NOCOPY DATE,
  p_cei_attribute_category OUT NOCOPY VARCHAR2,
  p_cei_attribute1	 OUT NOCOPY VARCHAR2,
  p_cei_attribute2	 OUT NOCOPY VARCHAR2,
  p_cei_attribute3	 OUT NOCOPY VARCHAR2,
  p_cei_attribute4	 OUT NOCOPY VARCHAR2,
  p_cei_attribute5	 OUT NOCOPY VARCHAR2,
  p_cei_attribute6	 OUT NOCOPY VARCHAR2,
  p_cei_attribute7	 OUT NOCOPY VARCHAR2,
  p_cei_attribute8	 OUT NOCOPY VARCHAR2,
  p_cei_attribute9	 OUT NOCOPY VARCHAR2,
  p_cei_attribute10	 OUT NOCOPY VARCHAR2,
  p_cei_attribute11	 OUT NOCOPY VARCHAR2,
  p_cei_attribute12	 OUT NOCOPY VARCHAR2,
  p_cei_attribute13	 OUT NOCOPY VARCHAR2,
  p_cei_attribute14	 OUT NOCOPY VARCHAR2,
  p_cei_attribute15	 OUT NOCOPY VARCHAR2,
  p_cei_attribute16	 OUT NOCOPY VARCHAR2,
  p_cei_attribute17	 OUT NOCOPY VARCHAR2,
  p_cei_attribute18	 OUT NOCOPY VARCHAR2,
  p_cei_attribute19	 OUT NOCOPY VARCHAR2,
  p_cei_attribute20	 OUT NOCOPY VARCHAR2,
  p_object_version_number OUT NOCOPY NUMBER,
  p_last_update_date	 OUT NOCOPY DATE,
  p_last_updated_by	 OUT NOCOPY NUMBER,
  p_last_update_login	 OUT NOCOPY NUMBER,
  p_created_by		 OUT NOCOPY NUMBER,
  p_creation_date	 OUT NOCOPY DATE,
  p_request_id		 OUT NOCOPY NUMBER,
  p_program_application_id OUT NOCOPY NUMBER,
  p_program_id		 OUT NOCOPY NUMBER,
  p_program_update_date	 OUT NOCOPY DATE) IS
  --
  CURSOR cel_extra_info_detail IS
   SELECT
    pceif.contact_extra_info_id,
    pceif.information_type,
    pcitv.description,
    pceif.cei_information_category,
    pceif.cei_information1,
    pceif.cei_information2,
    pceif.cei_information3,
    pceif.cei_information4,
    pceif.cei_information5,
    pceif.cei_information6,
    pceif.cei_information7,
    pceif.cei_information8,
    pceif.cei_information9,
    pceif.cei_information10,
    pceif.cei_information11,
    pceif.cei_information12,
    pceif.cei_information13,
    pceif.cei_information14,
    pceif.cei_information15,
    pceif.cei_information16,
    pceif.cei_information17,
    pceif.cei_information18,
    pceif.cei_information19,
    pceif.cei_information20,
    pceif.cei_information21,
    pceif.cei_information22,
    pceif.cei_information23,
    pceif.cei_information24,
    pceif.cei_information25,
    pceif.cei_information26,
    pceif.cei_information27,
    pceif.cei_information28,
    pceif.cei_information29,
    pceif.cei_information30,
    pceif.effective_start_date,
    pceif.effective_end_date,
    pceif.cei_attribute_category,
    pceif.cei_attribute1,
    pceif.cei_attribute2,
    pceif.cei_attribute3,
    pceif.cei_attribute4,
    pceif.cei_attribute5,
    pceif.cei_attribute6,
    pceif.cei_attribute7,
    pceif.cei_attribute8,
    pceif.cei_attribute9,
    pceif.cei_attribute10,
    pceif.cei_attribute11,
    pceif.cei_attribute12,
    pceif.cei_attribute13,
    pceif.cei_attribute14,
    pceif.cei_attribute15,
    pceif.cei_attribute16,
    pceif.cei_attribute17,
    pceif.cei_attribute18,
    pceif.cei_attribute19,
    pceif.cei_attribute20,
    pceif.object_version_number,
    pceif.last_update_date,
    pceif.last_updated_by,
    pceif.last_update_login,
    pceif.created_by,
    pceif.creation_date,
    pceif.request_id,
    pceif.program_application_id,
    pceif.program_id,
    pceif.program_update_date
   FROM
    per_contact_extra_info_f pceif,
    per_contact_info_types_vl pcitv
   WHERE pceif.contact_relationship_id = p_contact_relationship_id
   AND pceif.information_type LIKE p_information_type_group || '%'
   AND p_effective_date BETWEEN pceif.effective_start_date AND pceif.effective_end_date
   AND pceif.information_type = pcitv.information_type
   -- /* Added by keyazawa at 2003/10/02 for bugfix 3047148. */
   and  exists(
          select  null
          from    per_contact_relationships     pcr,
                  per_business_groups_perf      pbg,
                  per_info_type_security_cit_v  pitsc
          -- /* This relation is to fetch legislation code, ideally this should be parameter. */
          where   pcr.contact_relationship_id = pceif.contact_relationship_id
          and     pbg.business_group_id = pcr.business_group_id
          -- /* This sql should be called by EBS, ideally these should be parameter.
          --    fnd_global is better than fnd_profile.value. */
          and     pitsc.application_id = fnd_global.resp_appl_id
          and     pitsc.responsibility_id = fnd_global.resp_id
          and     pitsc.information_type  = pceif.information_type
          and     pitsc.legislation_code = nvl(pbg.legislation_code,pitsc.legislation_code));
  --
  celrec_extra_info_detail	cel_extra_info_detail%ROWTYPE;
  --
 BEGIN
  --
  OPEN cel_extra_info_detail;
  FETCH cel_extra_info_detail INTO celrec_extra_info_detail;
  --
  p_contact_extra_info_id := celrec_extra_info_detail.contact_extra_info_id;
  p_information_type := celrec_extra_info_detail.information_type;
  p_d_information_type := celrec_extra_info_detail.description;
  p_cei_information_category := celrec_extra_info_detail.cei_information_category;
  p_cei_information1 := celrec_extra_info_detail.cei_information1;
  p_cei_information2 := celrec_extra_info_detail.cei_information2;
  p_cei_information3 := celrec_extra_info_detail.cei_information3;
  p_cei_information4 := celrec_extra_info_detail.cei_information4;
  p_cei_information5 := celrec_extra_info_detail.cei_information5;
  p_cei_information6 := celrec_extra_info_detail.cei_information6;
  p_cei_information7 := celrec_extra_info_detail.cei_information7;
  p_cei_information8 := celrec_extra_info_detail.cei_information8;
  p_cei_information9 := celrec_extra_info_detail.cei_information9;
  p_cei_information10 := celrec_extra_info_detail.cei_information10;
  p_cei_information11 := celrec_extra_info_detail.cei_information11;
  p_cei_information12 := celrec_extra_info_detail.cei_information12;
  p_cei_information13 := celrec_extra_info_detail.cei_information13;
  p_cei_information14 := celrec_extra_info_detail.cei_information14;
  p_cei_information15 := celrec_extra_info_detail.cei_information15;
  p_cei_information16 := celrec_extra_info_detail.cei_information16;
  p_cei_information17 := celrec_extra_info_detail.cei_information17;
  p_cei_information18 := celrec_extra_info_detail.cei_information18;
  p_cei_information19 := celrec_extra_info_detail.cei_information19;
  p_cei_information20 := celrec_extra_info_detail.cei_information20;
  p_cei_information21 := celrec_extra_info_detail.cei_information21;
  p_cei_information22 := celrec_extra_info_detail.cei_information22;
  p_cei_information23 := celrec_extra_info_detail.cei_information23;
  p_cei_information24 := celrec_extra_info_detail.cei_information24;
  p_cei_information25 := celrec_extra_info_detail.cei_information25;
  p_cei_information26 := celrec_extra_info_detail.cei_information26;
  p_cei_information27 := celrec_extra_info_detail.cei_information27;
  p_cei_information28 := celrec_extra_info_detail.cei_information28;
  p_cei_information29 := celrec_extra_info_detail.cei_information29;
  p_cei_information30 := celrec_extra_info_detail.cei_information30;
  p_effective_start_date := celrec_extra_info_detail.effective_start_date;
  p_effective_end_date := celrec_extra_info_detail.effective_end_date;
  p_cei_attribute_category := celrec_extra_info_detail.cei_attribute_category;
  p_cei_attribute1 := celrec_extra_info_detail.cei_attribute1;
  p_cei_attribute2 := celrec_extra_info_detail.cei_attribute2;
  p_cei_attribute3 := celrec_extra_info_detail.cei_attribute3;
  p_cei_attribute4 := celrec_extra_info_detail.cei_attribute4;
  p_cei_attribute5 := celrec_extra_info_detail.cei_attribute5;
  p_cei_attribute6 := celrec_extra_info_detail.cei_attribute6;
  p_cei_attribute7 := celrec_extra_info_detail.cei_attribute7;
  p_cei_attribute8 := celrec_extra_info_detail.cei_attribute8;
  p_cei_attribute9 := celrec_extra_info_detail.cei_attribute9;
  p_cei_attribute10 := celrec_extra_info_detail.cei_attribute10;
  p_cei_attribute11 := celrec_extra_info_detail.cei_attribute11;
  p_cei_attribute12 := celrec_extra_info_detail.cei_attribute12;
  p_cei_attribute13 := celrec_extra_info_detail.cei_attribute13;
  p_cei_attribute14 := celrec_extra_info_detail.cei_attribute14;
  p_cei_attribute15 := celrec_extra_info_detail.cei_attribute15;
  p_cei_attribute16 := celrec_extra_info_detail.cei_attribute16;
  p_cei_attribute17 := celrec_extra_info_detail.cei_attribute17;
  p_cei_attribute18 := celrec_extra_info_detail.cei_attribute18;
  p_cei_attribute19 := celrec_extra_info_detail.cei_attribute19;
  p_cei_attribute20 := celrec_extra_info_detail.cei_attribute20;
  p_object_version_number := celrec_extra_info_detail.object_version_number;
  p_last_update_date := celrec_extra_info_detail.last_update_date;
  p_last_updated_by := celrec_extra_info_detail.last_updated_by;
  p_last_update_login := celrec_extra_info_detail.last_update_login;
  p_created_by := celrec_extra_info_detail.created_by;
  p_creation_date := celrec_extra_info_detail.creation_date;
  p_request_id := celrec_extra_info_detail.request_id;
  p_program_application_id := celrec_extra_info_detail.program_application_id;
  p_program_id := celrec_extra_info_detail.program_id;
  p_program_update_date := celrec_extra_info_detail.program_update_date;
  --
  CLOSE cel_extra_info_detail;
  --
 END extra_info_detail;
 --
 PROCEDURE populate_extra_info_field(
  p_contact_relationship_id	IN	NUMBER,
  p_effective_date		IN	DATE,
  p_information_type_group	IN	VARCHAR2,
  p_contact_extra_info_id OUT NOCOPY NUMBER,
  p_information_type	 OUT NOCOPY VARCHAR2,
  p_d_information_type	 OUT NOCOPY VARCHAR2,
  p_cei_information_category OUT NOCOPY VARCHAR2,
  p_cei_information1	 OUT NOCOPY VARCHAR2,
  p_cei_information2	 OUT NOCOPY VARCHAR2,
  p_cei_information3	 OUT NOCOPY VARCHAR2,
  p_cei_information4	 OUT NOCOPY VARCHAR2,
  p_cei_information5	 OUT NOCOPY VARCHAR2,
  p_cei_information6	 OUT NOCOPY VARCHAR2,
  p_cei_information7	 OUT NOCOPY VARCHAR2,
  p_cei_information8	 OUT NOCOPY VARCHAR2,
  p_cei_information9	 OUT NOCOPY VARCHAR2,
  p_cei_information10	 OUT NOCOPY VARCHAR2,
  p_cei_information11	 OUT NOCOPY VARCHAR2,
  p_cei_information12	 OUT NOCOPY VARCHAR2,
  p_cei_information13	 OUT NOCOPY VARCHAR2,
  p_cei_information14	 OUT NOCOPY VARCHAR2,
  p_cei_information15	 OUT NOCOPY VARCHAR2,
  p_cei_information16	 OUT NOCOPY VARCHAR2,
  p_cei_information17	 OUT NOCOPY VARCHAR2,
  p_cei_information18	 OUT NOCOPY VARCHAR2,
  p_cei_information19	 OUT NOCOPY VARCHAR2,
  p_cei_information20	 OUT NOCOPY VARCHAR2,
  p_cei_information21	 OUT NOCOPY VARCHAR2,
  p_cei_information22	 OUT NOCOPY VARCHAR2,
  p_cei_information23	 OUT NOCOPY VARCHAR2,
  p_cei_information24	 OUT NOCOPY VARCHAR2,
  p_cei_information25	 OUT NOCOPY VARCHAR2,
  p_cei_information26	 OUT NOCOPY VARCHAR2,
  p_cei_information27	 OUT NOCOPY VARCHAR2,
  p_cei_information28	 OUT NOCOPY VARCHAR2,
  p_cei_information29	 OUT NOCOPY VARCHAR2,
  p_cei_information30	 OUT NOCOPY VARCHAR2,
  p_effective_start_date OUT NOCOPY DATE,
  p_effective_end_date	 OUT NOCOPY DATE,
  p_cei_attribute_category OUT NOCOPY VARCHAR2,
  p_cei_attribute1	 OUT NOCOPY VARCHAR2,
  p_cei_attribute2	 OUT NOCOPY VARCHAR2,
  p_cei_attribute3	 OUT NOCOPY VARCHAR2,
  p_cei_attribute4	 OUT NOCOPY VARCHAR2,
  p_cei_attribute5	 OUT NOCOPY VARCHAR2,
  p_cei_attribute6	 OUT NOCOPY VARCHAR2,
  p_cei_attribute7	 OUT NOCOPY VARCHAR2,
  p_cei_attribute8	 OUT NOCOPY VARCHAR2,
  p_cei_attribute9	 OUT NOCOPY VARCHAR2,
  p_cei_attribute10	 OUT NOCOPY VARCHAR2,
  p_cei_attribute11	 OUT NOCOPY VARCHAR2,
  p_cei_attribute12	 OUT NOCOPY VARCHAR2,
  p_cei_attribute13	 OUT NOCOPY VARCHAR2,
  p_cei_attribute14	 OUT NOCOPY VARCHAR2,
  p_cei_attribute15	 OUT NOCOPY VARCHAR2,
  p_cei_attribute16	 OUT NOCOPY VARCHAR2,
  p_cei_attribute17	 OUT NOCOPY VARCHAR2,
  p_cei_attribute18	 OUT NOCOPY VARCHAR2,
  p_cei_attribute19	 OUT NOCOPY VARCHAR2,
  p_cei_attribute20	 OUT NOCOPY VARCHAR2,
  p_object_version_number OUT NOCOPY NUMBER,
  p_last_update_date	 OUT NOCOPY DATE,
  p_last_updated_by	 OUT NOCOPY NUMBER,
  p_last_update_login	 OUT NOCOPY NUMBER,
  p_created_by		 OUT NOCOPY NUMBER,
  p_creation_date	 OUT NOCOPY DATE,
  p_request_id		 OUT NOCOPY NUMBER,
  p_program_application_id OUT NOCOPY NUMBER,
  p_program_id		 OUT NOCOPY NUMBER,
  p_program_update_date	 OUT NOCOPY DATE,
  p_extra_info_count	 OUT NOCOPY NUMBER) IS
 --
  l_extra_info_count	NUMBER := extra_info_count(p_contact_relationship_id, p_effective_date, p_information_type_group);
  --
 BEGIN
  --
  p_extra_info_count := l_extra_info_count;
  --
  IF l_extra_info_count = 0 THEN
   --
   p_contact_extra_info_id := NULL;
   p_information_type := NULL;
   p_d_information_type	:= NULL;
   p_cei_information_category := NULL;
   p_cei_information1 := NULL;
   p_cei_information2 := NULL;
   p_cei_information3 := NULL;
   p_cei_information4 := NULL;
   p_cei_information5 := NULL;
   p_cei_information6 := NULL;
   p_cei_information7 := NULL;
   p_cei_information8 := NULL;
   p_cei_information9 := NULL;
   p_cei_information10 := NULL;
   p_cei_information11 := NULL;
   p_cei_information12 := NULL;
   p_cei_information13 := NULL;
   p_cei_information14 := NULL;
   p_cei_information15 := NULL;
   p_cei_information16 := NULL;
   p_cei_information17 := NULL;
   p_cei_information18 := NULL;
   p_cei_information19 := NULL;
   p_cei_information20 := NULL;
   p_cei_information21 := NULL;
   p_cei_information22 := NULL;
   p_cei_information23 := NULL;
   p_cei_information24 := NULL;
   p_cei_information25 := NULL;
   p_cei_information26 := NULL;
   p_cei_information27 := NULL;
   p_cei_information28 := NULL;
   p_cei_information29 := NULL;
   p_cei_information30 := NULL;
   p_effective_start_date := NULL;
   p_effective_end_date	:= NULL;
   p_cei_attribute_category := NULL;
   p_cei_attribute1 := NULL;
   p_cei_attribute2 := NULL;
   p_cei_attribute3 := NULL;
   p_cei_attribute4 := NULL;
   p_cei_attribute5 := NULL;
   p_cei_attribute6 := NULL;
   p_cei_attribute7 := NULL;
   p_cei_attribute8 := NULL;
   p_cei_attribute9 := NULL;
   p_cei_attribute10 := NULL;
   p_cei_attribute11 := NULL;
   p_cei_attribute12 := NULL;
   p_cei_attribute13 := NULL;
   p_cei_attribute14 := NULL;
   p_cei_attribute15 := NULL;
   p_cei_attribute16 := NULL;
   p_cei_attribute17 := NULL;
   p_cei_attribute18 := NULL;
   p_cei_attribute19 := NULL;
   p_cei_attribute20 := NULL;
   p_object_version_number := NULL;
   p_last_update_date := NULL;
   p_last_updated_by := NULL;
   p_last_update_login := NULL;
   p_created_by	:= NULL;
   p_creation_date := NULL;
   p_request_id := NULL;
   p_program_application_id := NULL;
   p_program_id := NULL;
   p_program_update_date := NULL;
   --
  ELSE
   --
   extra_info_detail(
    p_contact_relationship_id	=> p_contact_relationship_id,
    p_effective_date		=> p_effective_date,
    p_information_type_group	=> p_information_type_group,
    p_contact_extra_info_id	=> p_contact_extra_info_id,
    p_information_type		=> p_information_type,
    p_d_information_type	=> p_d_information_type,
    p_cei_information_category	=> p_cei_information_category,
    p_cei_information1		=> p_cei_information1,
    p_cei_information2 		=> p_cei_information2,
    p_cei_information3		=> p_cei_information3,
    p_cei_information4		=> p_cei_information4,
    p_cei_information5		=> p_cei_information5,
    p_cei_information6		=> p_cei_information6,
    p_cei_information7		=> p_cei_information7,
    p_cei_information8		=> p_cei_information8,
    p_cei_information9		=> p_cei_information9,
    p_cei_information10		=> p_cei_information10,
    p_cei_information11         => p_cei_information11,
    p_cei_information12         => p_cei_information12,
    p_cei_information13         => p_cei_information13,
    p_cei_information14         => p_cei_information14,
    p_cei_information15         => p_cei_information15,
    p_cei_information16         => p_cei_information16,
    p_cei_information17         => p_cei_information17,
    p_cei_information18         => p_cei_information18,
    p_cei_information19         => p_cei_information19,
    p_cei_information20         => p_cei_information20,
    p_cei_information21         => p_cei_information21,
    p_cei_information22         => p_cei_information22,
    p_cei_information23		=> p_cei_information23,
    p_cei_information24		=> p_cei_information24,
    p_cei_information25		=> p_cei_information25,
    p_cei_information26		=> p_cei_information26,
    p_cei_information27		=> p_cei_information27,
    p_cei_information28		=> p_cei_information28,
    p_cei_information29		=> p_cei_information29,
    p_cei_information30		=> p_cei_information30,
    p_effective_start_date	=> p_effective_start_date,
    p_effective_end_date	=> p_effective_end_date,
    p_cei_attribute_category	=> p_cei_attribute_category,
    p_cei_attribute1		=> p_cei_attribute1,
    p_cei_attribute2		=> p_cei_attribute2,
    p_cei_attribute3		=> p_cei_attribute3,
    p_cei_attribute4		=> p_cei_attribute4,
    p_cei_attribute5		=> p_cei_attribute5,
    p_cei_attribute6		=> p_cei_attribute6,
    p_cei_attribute7		=> p_cei_attribute7,
    p_cei_attribute8		=> p_cei_attribute8,
    p_cei_attribute9		=> p_cei_attribute9,
    p_cei_attribute10		=> p_cei_attribute10,
    p_cei_attribute11		=> p_cei_attribute11,
    p_cei_attribute12		=> p_cei_attribute12,
    p_cei_attribute13		=> p_cei_attribute13,
    p_cei_attribute14		=> p_cei_attribute14,
    p_cei_attribute15		=> p_cei_attribute15,
    p_cei_attribute16		=> p_cei_attribute16,
    p_cei_attribute17 		=> p_cei_attribute17,
    p_cei_attribute18		=> p_cei_attribute18,
    p_cei_attribute19		=> p_cei_attribute19,
    p_cei_attribute20		=> p_cei_attribute20,
    p_object_version_number	=> p_object_version_number,
    p_last_update_date		=> p_last_update_date,
    p_last_updated_by		=> p_last_updated_by,
    p_last_update_login		=> p_last_update_login,
    p_created_by 		=> p_created_by,
    p_creation_date		=> p_creation_date,
    p_request_id 		=> p_request_id,
    p_program_application_id	=> p_program_application_id,
    p_program_id		=> p_program_id,
    p_program_update_date	=> p_program_update_date);
   --
  END IF;
  --
 END populate_extra_info_field;
 --
 PROCEDURE populate_itax_result_field(
  p_person_id			IN	NUMBER,
  p_effective_date		IN	DATE,
  p_itax_type_iv_id		IN	NUMBER,
  p_deductible_spouse_status OUT NOCOPY VARCHAR2,
  p_disabled_spouse_status OUT NOCOPY VARCHAR2,
  p_dependents		 OUT NOCOPY NUMBER,
  p_aged_dependents	 OUT NOCOPY NUMBER,
  p_aged_parents	 OUT NOCOPY NUMBER,
  p_specified_dependents OUT NOCOPY NUMBER,
  p_ordinary_disabled	 OUT NOCOPY NUMBER,
  p_severely_disabled	 OUT NOCOPY NUMBER,
  p_severely_disabled_live_with OUT NOCOPY NUMBER) IS
  --
  l_assignment_id		per_all_assignments_f.assignment_id%TYPE;
  l_itax_type			hr_lookups.lookup_code%TYPE;
  l_deductible_spouse_status    VARCHAR2(30);
  l_disabled_spouse_status      VARCHAR2(30);
  l_minor_dpnts			NUMBER;
  l_multiple_spouses_warning	BOOLEAN;
  --
  CURSOR cel_assignment_exists IS
   SELECT assignment_id FROM per_all_assignments_f
   WHERE person_id = p_person_id
   AND primary_flag = 'Y'
   AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
  --
 BEGIN
  --
  OPEN cel_assignment_exists;
  FETCH cel_assignment_exists INTO l_assignment_id;
  --
  IF cel_assignment_exists%FOUND THEN
   --
   l_itax_type := pay_jp_balance_pkg.get_entry_value_char(
                   p_input_value_id	=> p_itax_type_iv_id,
                   p_assignment_id	=> l_assignment_id,
                   p_effective_date	=> p_effective_date);
   --
   IF l_itax_type IN ('M_KOU', 'D_KOU', 'M_OTSU', 'D_OTSU') THEN
    --
    per_jp_ctr_utility_pkg.get_itax_dpnt_info(
     p_assignment_id		=> l_assignment_id,
     p_itax_type 		=> l_itax_type,
     p_effective_date		=> p_effective_date,
     p_dpnt_spouse_type		=> l_deductible_spouse_status,
     p_dpnt_spouse_dsbl_type    => l_disabled_spouse_status,
     p_dpnts			=> p_dependents,
     p_aged_dpnts		=> p_aged_dependents,
     p_cohab_aged_asc_dpnts	=> p_aged_parents,
     p_major_dpnts		=> p_specified_dependents,
     p_minor_dpnts              => l_minor_dpnts,
     p_dsbl_dpnts 		=> p_ordinary_disabled,
     p_svr_dsbl_dpnts		=> p_severely_disabled,
     p_cohab_svr_dsbl_dpnts	=> p_severely_disabled_live_with,
     p_multiple_spouses_warning => l_multiple_spouses_warning,
     p_use_cache		=> FALSE);
    --
    p_deductible_spouse_status := hr_general.decode_lookup('JP_SPOUSE_STATUS', l_deductible_spouse_status);
    p_disabled_spouse_status := hr_general.decode_lookup('JP_DISABLED_SPOUSE_STATUS', l_disabled_spouse_status);
    --
   ELSE
    --
    p_deductible_spouse_status := NULL;
    p_disabled_spouse_status := NULL;
    p_dependents := NULL;
    p_aged_dependents := NULL;
    p_aged_parents := NULL;
    p_specified_dependents := NULL;
    p_ordinary_disabled := NULL;
    p_severely_disabled := NULL;
    p_severely_disabled_live_with := NULL;
    --
   END IF;
   --
  ELSE
   --
   p_deductible_spouse_status := NULL;
   p_disabled_spouse_status := NULL;
   p_dependents := NULL;
   p_aged_dependents := NULL;
   p_aged_parents := NULL;
   p_specified_dependents := NULL;
   p_ordinary_disabled := NULL;
   p_severely_disabled := NULL;
   p_severely_disabled_live_with := NULL;
   --
  END IF;
  --
  CLOSE cel_assignment_exists;
  --
 END populate_itax_result_field;
 --
END per_jp_dependent_pkg;

/
