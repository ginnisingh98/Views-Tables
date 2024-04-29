--------------------------------------------------------
--  DDL for Package Body HR_NL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_UTILITY" AS
/* $Header: hrnlutil.pkb 120.0.12010000.5 2010/03/17 11:12:33 knadhan ship $ */
--
FUNCTION per_nl_full_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
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
			 )
			  RETURN VARCHAR2 IS
--
l_full_name      varchar2(240);
l_title          varchar2(30);
l_acad_title     varchar2(80);
l_sub_acad_title varchar2(80);
--
/* 6891179 */
CURSOR cur_effective_date is
SELECT se.effective_date effective_date
FROM fnd_sessions se
WHERE se.session_id = USERENV('sessionid');

--
CURSOR cur_contact_person_id(c_effective_date date)
is
SELECT pcr.contact_person_id contact_person_id
FROM per_contact_relationships pcr
WHERE  pcr.person_id=per_per_shd.g_old_rec.person_id
  AND pcr.contact_type='S'
  AND c_effective_date between nvl(pcr.date_start,to_date('01/01/0001','dd/mm/yyyy')) and nvl(pcr.date_end,to_date('31/12/4712','dd/mm/yyyy'))
;

--
CURSOR cur_contact_person_details(c_person_id per_all_people_f.person_id%type,c_effective_date date)
is
SELECT papf.pre_name_adjunct prefix
      ,papf.last_name last_name
FROM per_all_people_f papf
WHERE papf.person_id=c_person_id
  AND c_effective_date between papf.effective_start_date and papf.effective_end_date
  AND papf.person_type_id  IN (
                                  SELECT ppt.person_type_id
				  FROM per_person_types ppt
				  WHERE ppt.business_group_id=papf.business_group_id
                                    AND ppt.seeded_person_type_key='CONTACT') ;

--
l_effective_date date;
l_contact_person_details cur_contact_person_details%ROWTYPE;
l_per_information5 varchar2(150);
l_per_information6 varchar2(150);
l_person_id  per_all_people_f.person_id%type;

--
BEGIN

   /* 6891179 */

   hr_utility.set_location(' entered per_nl_full_name',10);
   hr_utility.set_location(' session id :='||USERENV('sessionid'),10);
   hr_utility.set_location(' hr_util_misc_ss.g_eff_date'||hr_util_misc_ss.g_eff_date,10000);

/* 8680292 */
   --
 --  hr_util_misc_ss.setEffectiveDate(hr_util_misc_ss.g_eff_date);
   --

   hr_utility.set_location(' hr_util_misc_ss.g_eff_date'||hr_util_misc_ss.g_eff_date,10);
   hr_utility.set_location('p_per_information5 '||p_per_information5,10);
   hr_utility.set_location(' p_per_information6 '||p_per_information6,10);
   hr_utility.set_location(' per_per_shd.g_old_rec.person_id'||per_per_shd.g_old_rec.person_id,20);

   hr_utility.set_location('Before cur_effective_date cursor ',30);

/* 8680292 */
/*  Replaces l_effective_date by hr_util_misc_ss.g_eff_date
   --
   OPEN cur_effective_date;
   FETCH cur_effective_date INTO l_effective_date;
   CLOSE cur_effective_date;
   hr_utility.set_location(' l_effective_Date  '||l_effective_date,30);
*/
   --
   open cur_contact_person_id(hr_util_misc_ss.g_eff_date);
   fetch cur_contact_person_id into l_person_id;
   close cur_contact_person_id;

   --
   hr_utility.set_location('l_person_id '||l_person_id,40);
  -- hr_utility.set_location('After cur_effective_date cursor ',40);
  -- hr_utility.set_location('l_effective_date '||l_effective_date,50);
   hr_utility.set_location('Before cur_contact_person_details ',60);

   --
   OPEN cur_contact_person_details(l_person_id,hr_util_misc_ss.g_eff_date);
   FETCH cur_contact_person_details INTO l_contact_person_details;

   hr_utility.set_location(' contact person prename adjunct   '||l_contact_person_details.prefix ,70);
   hr_utility.set_location('contact person last name  '|| l_contact_person_details.last_name,70);


   /* the l_per_information5,l_per_information6 stores either dynamically retrieved last name , prename adjucnt(if spouse exist)
     or the p_per_information5,p_per_information6 tat are passed to procedure */
   IF(cur_contact_person_details%FOUND) THEN
      l_per_information5:=l_contact_person_details.prefix;
      l_per_information6:=l_contact_person_details.last_name;
      hr_utility.set_location(' entered if condtion',80);
   ELSE
      l_per_information5:= p_per_information5;
      l_per_information6:= p_per_information6;
      hr_utility.set_location(' entered else  condtion',90);
   END IF;
   CLOSE cur_contact_person_details;

 --
   l_title:=hr_general.decode_lookup('TITLE', p_title);
   l_acad_title:=hr_general.decode_lookup('HR_NL_ACADEMIC_TITLE',
                        p_per_information10);
   l_sub_acad_title:=hr_general.decode_lookup('HR_NL_SUB_ACADEMIC_TITLE',
                        p_per_information3);
   if p_per_information4 is null then
     select p_last_name || ' '
            || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
            || decode (p_per_information1,'','',p_per_information1 || ' ')
            || decode (l_per_information5,'','',l_per_information5 || ' ')
            || l_per_information6
     into l_full_name
     from dual;
   elsif p_per_information4 = 'FORMAT1' then
     select decode (p_per_information1,'','',p_per_information1 || ' ')
            || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
            || p_last_name
     into l_full_name
     from dual;
   elsif p_per_information4 = 'FORMAT2' then
   	if (p_pre_name_adjunct is not null or p_last_name is not null) then
     	  select decode (p_per_information1,'','',p_per_information1 || ' ')
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	       || decode (l_per_information6,'','',l_per_information6)
     	       || '-'
               || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
     	       || p_last_name
     	  into l_full_name
     	  from dual;
     	else
      	 select decode (p_per_information1,'','',p_per_information1 || ' ')
	        || decode (l_per_information5,'','',l_per_information5 || ' ')
	        || decode (l_per_information6,'','',l_per_information6 || ' ')
	        || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	        || p_last_name
	 into l_full_name
     	 from dual;
     	end if;
    elsif p_per_information4 = 'FORMAT3' then
    	if (l_per_information5 is not null or l_per_information6 is not null) then
     	 select decode (p_per_information1,'','',p_per_information1 || ' ')
     	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
     	       || p_last_name
     	       || '-'
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	       || l_per_information6
    	 into l_full_name
    	 from dual;
    	else
    	 select decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	       || p_last_name || ' '
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	       || l_per_information6
	 into l_full_name
    	 from dual;
    	end if;
    elsif p_per_information4 = 'FORMAT4' then
    	if (p_per_information1 is not null or l_per_information5 is not null or l_per_information6 is not null) then
     	 select p_last_name || ' '
     	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct)
     	       || ', '
     	       || decode (p_per_information1,'','',p_per_information1 || ' ')
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	       || l_per_information6
     	 into l_full_name
     	 from dual;
     	else
     	 select p_last_name || ' '
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	       || l_per_information6
	 into l_full_name
     	 from dual;
     	end if;
    elsif p_per_information4 = 'FORMAT5' then
     select decode (p_per_information1,'','',p_per_information1 || ' ')
            || decode (l_per_information5,'','',l_per_information5 || ' ')
            || l_per_information6
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT6' then
    	if (p_per_information1 is not null or p_pre_name_adjunct is not null or p_last_name is not null) then
      	 select decode (l_per_information6,'','',l_per_information6 || ' ')
      	       || decode (l_per_information5,'','',l_per_information5)
      	       || ', '
      	       || decode (p_per_information1,'','',p_per_information1 || ' ')
      	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
      	       || p_last_name
     	 into l_full_name
      	 from dual;
     	else
      	 select decode (l_per_information6,'','',l_per_information6 || ' ')
      	       || decode (l_per_information5,'','',l_per_information5 || ' ')
               || decode (p_per_information1,'','',p_per_information1 || ' ')
               || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
               || p_last_name
         into l_full_name
      	 from dual;
     	end if;
    elsif p_per_information4 = 'FORMAT7' then
     select p_last_name || ' '
            || decode (p_first_name,'','',p_first_name|| ' ')
            || p_pre_name_adjunct
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT8' then
     select p_last_name || ' '
            || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct|| ' ')
            || p_first_name
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT9' then
     select decode (p_first_name,'','',p_first_name|| ' ')
            || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct|| ' ')
            || p_last_name
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT10' then
    	if (p_pre_name_adjunct is not null or p_last_name is not null) then
     	 select decode (p_first_name,'','',p_first_name|| ' ')
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	       || decode (l_per_information6,'','',l_per_information6)
     	       || '-'
     	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
     	       || p_last_name
     	 into l_full_name
     	 from dual;
     	else
     	 select decode (p_first_name,'','',p_first_name|| ' ')
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	       || decode (l_per_information6,'','',l_per_information6 || ' ')
     	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
     	       || p_last_name
     	 into l_full_name
     	 from dual;
     	end if;
    elsif p_per_information4 = 'FORMAT11' then
     select p_last_name || ' '
            || decode (l_title,'','',l_title|| ' ')
            || p_per_information1
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT12' then
     select p_last_name || ' '
            || decode (l_title,'','',l_title|| ' ')
            || decode (p_per_information1,'','',p_per_information1 || ' ')
            || p_first_name
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT13' then
     select p_last_name || ' '
            || decode (l_title,'','',l_title|| ' ')
            || decode (p_per_information1,'','',p_per_information1 || ' ')
            || p_known_as
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT14' then
     select p_last_name || ' '
            || decode (p_per_information1,'','',p_per_information1 || ' ')
            || p_pre_name_adjunct
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT15' then
     select decode (l_acad_title,'','',l_acad_title|| ' ')
            || decode (p_per_information1,'','',p_per_information1 || ' ')
            || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
            || p_last_name || ' '
            || decode (l_sub_acad_title,'','',l_sub_acad_title|| ' ')
     into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT16' then
    	if (p_pre_name_adjunct is not null or p_last_name is not null or l_sub_acad_title is not null) then
     	 select decode (l_acad_title,'','',l_acad_title|| ' ')
     	       || decode (p_per_information1,'','',p_per_information1 || ' ')
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	       || decode (l_per_information6,'','',l_per_information6)
     	       || '-'
     	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
     	       || p_last_name || ' '
     	       || decode (l_sub_acad_title,'','',l_sub_acad_title|| ' ')
     	 into l_full_name
     	 from dual;
     	else
     	 select decode (l_acad_title,'','',l_acad_title|| ' ')
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	       || decode (l_per_information6,'','',l_per_information6 || ' ')
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	       || p_last_name || ' '
	       || decode (l_sub_acad_title,'','',l_sub_acad_title|| ' ')
	 into l_full_name
     	 from dual;
     	end if;
    elsif p_per_information4 = 'FORMAT17' then
    	if ((p_pre_name_adjunct is not null or p_last_name is not null) and (p_per_information1 is not null or l_per_information5 is not null)) then
     	 select decode (l_per_information6,'','',l_per_information6)
     	       || '-'
     	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
     	       || p_last_name || ', '
     	       || decode (p_per_information1,'','',p_per_information1 || ' ')
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	 into l_full_name
     	 from dual;
     	elsif ((p_pre_name_adjunct is not null or p_last_name is not null) and (p_per_information1 is null and l_per_information5 is null)) then
     	 select decode (l_per_information6,'','',l_per_information6)
     	       || '-'
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	       || p_last_name || ''
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	 into l_full_name
     	 from dual;
     	elsif ((p_pre_name_adjunct is null and p_last_name is null) and (p_per_information1 is not null or l_per_information5 is not null)) then
     	 select decode (l_per_information6,'','',l_per_information6)
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct)
	       || decode (p_last_name, '','',p_last_name)
	       || ', '
	       || decode (p_per_information1,'','', ', ' || p_per_information1 || ' ')
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	 into l_full_name
     	 from dual;
     	elsif (p_pre_name_adjunct is null and p_last_name is null and p_per_information1 is null and l_per_information5 is null) then
     	 select decode (l_per_information6,'','',l_per_information6)
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	       || decode (p_last_name, '','',p_last_name || ', ')
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	 into l_full_name
     	 from dual;
     	end if;
    elsif p_per_information4 = 'FORMAT18' then
    	if ((l_per_information5 is not null or l_per_information6 is not null) and (p_per_information1 is not null or p_pre_name_adjunct is not null)) then
     	 select p_last_name || '-'
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	       || decode (l_per_information6,'','',l_per_information6)
     	       || ', '
     	       || decode (p_per_information1,'','',p_per_information1 || ' ')
     	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
         into l_full_name
     	 from dual;
     	elsif((l_per_information5 is not null or l_per_information6 is not null) and (p_per_information1 is null and p_pre_name_adjunct is null)) then
     	 select p_last_name || '-'
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	       || decode (l_per_information6,'','',l_per_information6 || ' ')
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	 into l_full_name
	 from dual;
	elsif((l_per_information5 is null and l_per_information6 is null) and (p_per_information1 is not null or p_pre_name_adjunct is not null)) then
       	 select p_last_name || ''
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	       || decode (l_per_information6,'','',l_per_information6)
	       || ', '
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	 into l_full_name
	 from dual;
	elsif(l_per_information5 is null and l_per_information6 is null and p_per_information1 is null and p_pre_name_adjunct is null) then
       	 select p_last_name || ''
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	       || decode (l_per_information6,'','',l_per_information6 || ', ')
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	 into l_full_name
	 from dual;
     	end if;
    elsif p_per_information4 = 'FORMAT19' then
    	if (p_per_information1 is not null or l_per_information5 is not null) then
     	 select decode (l_per_information6,'','',l_per_information6)
     	       || ', '
     	       || decode (p_per_information1,'','',p_per_information1 || ' ')
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	 into l_full_name
    	 from dual;
    	else
    	 select decode (l_per_information6,'','',l_per_information6|| ' ')
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	 into l_full_name
    	 from dual;
    	end if;
    elsif p_per_information4 = 'FORMAT20' then
     select decode (l_acad_title,'','',l_acad_title|| ' ')
            || decode (l_title,'','',l_title|| ' ')
            || decode (p_per_information1,'','',p_per_information1 || ' ')
            || decode (l_per_information5,'','',l_per_information5 || ' ')
            || decode (l_per_information6,'','',l_per_information6 || ' ')
            || decode (l_sub_acad_title,'','',l_sub_acad_title || ' ')
         into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT21' then
     select decode (l_acad_title,'','',l_acad_title|| ' ')
            || decode (l_title,'','',l_title|| ' ')
            || decode (p_per_information1,'','',p_per_information1 || ' ')
            || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
            || p_last_name || ' '
            || decode (l_sub_acad_title,'','',l_sub_acad_title || ' ')
         into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT22' then
    	if (p_pre_name_adjunct is not null or p_last_name is not null or l_sub_acad_title is not null) then
     	 select decode (l_acad_title,'','',l_acad_title|| ' ')
     	       || decode (l_title,'','',l_title|| ' ')
     	       || decode (p_per_information1,'','',p_per_information1 || ' ')
     	       || decode (l_per_information5,'','',l_per_information5 || ' ')
     	       || decode (l_per_information6,'','',l_per_information6)
     	       || '-'
     	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
     	       || p_last_name || ' '
     	       || decode (l_sub_acad_title,'','',l_sub_acad_title || ' ')
         into l_full_name
     	 from dual;
     	else
     	 select decode (l_acad_title,'','',l_acad_title|| ' ')
	       || decode (l_title,'','',l_title|| ' ')
	       || decode (p_per_information1,'','',p_per_information1 || ' ')
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	       || decode (l_per_information6,'','',l_per_information6 || ' ')
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	       || p_last_name || ' '
	       || decode (l_sub_acad_title,'','',l_sub_acad_title || ' ')
	 into l_full_name
     	 from dual;
     	end if;
    elsif p_per_information4 = 'FORMAT23' then
     select decode (l_acad_title,'','',l_acad_title|| ' ')
            || decode (l_title,'','',l_title|| ' ')
            || decode (p_first_name,'','',p_first_name|| ' ')
            || decode (l_per_information5,'','',l_per_information5 || ' ')
            || decode (l_per_information6,'','',l_per_information6 || ' ')
            || decode (l_sub_acad_title,'','',l_sub_acad_title || ' ')
         into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT24' then
     select decode (l_acad_title,'','',l_acad_title|| ' ')
            || decode (l_title,'','',l_title|| ' ')
            || decode (p_first_name,'','',p_first_name|| ' ')
            || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
            || p_last_name || ' '
            || decode (l_sub_acad_title,'','',l_sub_acad_title || ' ')
         into l_full_name
     from dual;
    elsif p_per_information4 = 'FORMAT25' then
    	if (p_pre_name_adjunct is not null or p_last_name is not null or l_sub_acad_title is not null) then
    	 select decode (l_acad_title,'','',l_acad_title|| ' ')
    	       || decode (l_title,'','',l_title|| ' ')
    	       || decode (p_first_name,'','',p_first_name|| ' ')
    	       || decode (l_per_information5,'','',l_per_information5 || ' ')
    	       || decode (l_per_information6,'','',l_per_information6)
    	       || '-'
    	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
    	       || p_last_name || ' '
    	       || decode (l_sub_acad_title,'','',l_sub_acad_title || ' ')
         into l_full_name
     	 from dual;
     	else
     	 select decode (l_acad_title,'','',l_acad_title|| ' ')
	       || decode (l_title,'','',l_title|| ' ')
	       || decode (p_first_name,'','',p_first_name|| ' ')
	       || decode (l_per_information5,'','',l_per_information5 || ' ')
	       || decode (l_per_information6,'','',l_per_information6 || ' ')
	       || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
	       || p_last_name || ' '
	       || decode (l_sub_acad_title,'','',l_sub_acad_title || ' ')
	 into l_full_name
     	 from dual;
        end if;
    elsif p_per_information4 = 'FORMAT26' then
     select p_last_name ||','|| ' ' /* 9346754QA */
            || decode (p_per_information1,'','',p_per_information1 || ' ')
            || p_pre_name_adjunct
     into l_full_name
     from dual;
    else
     select p_last_name || ' '
           || decode (p_pre_name_adjunct,'','',p_pre_name_adjunct || ' ')
           || decode (p_per_information1,'','',p_per_information1 || ' ')
           || decode (l_per_information5,'','',l_per_information5 || ' ')
           || l_per_information6
     into l_full_name
     from dual;
   end if;
 return rtrim(l_full_name);
 END;
 --
 END HR_NL_UTILITY;

/
