--------------------------------------------------------
--  DDL for Package Body PER_PL_PERSON_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_PERSON_EXTRA_INFO" AS
/* $Header: peplpeip.pkb 120.1 2006/09/13 12:43:30 mseshadr noship $ */



PROCEDURE CHK_PERSON_TYPE(P_PERSON_ID        NUMBER,
                          P_FLEX_START_DATE  VARCHAR2,
                          P_FLEX_END_DATE    VARCHAR2,
                          P_INFORMATION_TYPE VARCHAR2) IS


cursor csr_chk_contact is
   select 1 from
      per_people_f pap,per_person_types ppf,per_person_type_usages_f ptu
   where pap.person_id = P_PERSON_ID and
         pap.person_id = ptu.person_id and
         ppf.person_type_id = ptu.person_type_id and
         ppf.SEEDED_PERSON_TYPE_KEY = 'CONTACT' and
         pap.effective_start_date <= fnd_date.canonical_to_date(P_FLEX_START_DATE) and
         pap.effective_end_date >= nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) and
         ptu.effective_start_date <= fnd_date.canonical_to_date(P_FLEX_START_DATE) and
         ptu.effective_end_date >= nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'));

person_type number;

BEGIN

  open csr_chk_contact;
    fetch csr_chk_contact into person_type;
     if csr_chk_contact%NOTFOUND then
        hr_utility.set_message(800,'HR_CON_INVALID_DETAILS_PL');
        hr_utility.set_message_token('CONTACTFLEX',hr_general.decode_lookup('PL_FORM_LABELS',P_INFORMATION_TYPE||'_FLEX'));
        hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
        hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
        -- This message will be 'These details can be entered only for a Contact. Person type is not a Contact for the date range'
        hr_utility.raise_error;
     end if;
  close csr_chk_contact;

END CHK_PERSON_TYPE;



PROCEDURE CREATE_CON_DATE_CHK(P_PERSON_ID        NUMBER,
                              P_FLEX_START_DATE  VARCHAR2,
                              P_FLEX_END_DATE    VARCHAR2,
                              P_INFORMATION_TYPE VARCHAR2) IS

cursor csr_overlap_rec is
  select 1 from per_people_extra_info where
      person_id = P_PERSON_ID and
      information_type = P_INFORMATION_TYPE and
      (fnd_date.canonical_to_date(P_FLEX_START_DATE) between fnd_date.canonical_to_date(PEI_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(PEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
	        nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))
                    between fnd_date.canonical_to_date(PEI_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(PEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
                fnd_date.canonical_to_date(PEI_INFORMATION1) between fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                                nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) or
                nvl(fnd_date.canonical_to_date(PEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) between
                                 fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                               nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')));

cursor cur_inherit is select per_information2 from per_all_people_f where person_id =P_PERSON_ID
and effective_start_date <= fnd_date.canonical_to_date(P_FLEX_START_DATE)
and effective_end_date >= nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))
and per_information2 ='Y';

overlap_found  number;
vInherit per_all_people_f.per_information2%type;
BEGIN

   if (fnd_date.canonical_to_date(P_FLEX_START_DATE) >
           nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))) then
         hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
         -- This message will be 'Please enter a Start date >= End date
         hr_utility.raise_error;
  end if;

open cur_inherit;
 fetch cur_inherit into vInherit;

  if cur_inherit%notfound then
      hr_utility.set_message(800,'HR_CONTACT_INSURED_FLEX_PL');
      hr_utility.set_message_token('CONTACTFLEX',hr_general.decode_lookup('PL_FORM_LABELS',P_INFORMATION_TYPE||'_FLEX'));
      hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
      hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
      hr_utility.raise_error;
  end if;

 close cur_inherit;

open csr_overlap_rec;
  fetch csr_overlap_rec into overlap_found;
   if csr_overlap_rec%found then
      hr_utility.set_message(800,'HR_CONTACT_OVERLAP_REC_PL');
      hr_utility.set_message_token('CONTACTFLEX',hr_general.decode_lookup('PL_FORM_LABELS',P_INFORMATION_TYPE||'_FLEX'));
      hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
      hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
      hr_utility.raise_error;
   end if;
close csr_overlap_rec;


END CREATE_CON_DATE_CHK;

PROCEDURE UPDATE_CON_DATE_CHK(P_PERSON_EXTRA_INFO_ID     NUMBER
                             ,P_PEI_INFORMATION_CATEGORY VARCHAR2
                             ,P_FLEX_START_DATE          VARCHAR2
                             ,P_FLEX_END_DATE            VARCHAR2) IS


-- This cursor checks if the Start/End Dates are not overlapping with other records

cursor csr_overlap_upd_rec is
  select 1 from per_people_extra_info where
      pei_information_category = P_PEI_INFORMATION_CATEGORY and
      (fnd_date.canonical_to_date(P_FLEX_START_DATE) between fnd_date.canonical_to_date(PEI_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(PEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
	        nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))
                    between fnd_date.canonical_to_date(PEI_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(PEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
                fnd_date.canonical_to_date(PEI_INFORMATION1) between fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                                nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) or
                nvl(fnd_date.canonical_to_date(PEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) between
                                 fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                               nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))) and
               person_id in (select person_id from per_people_extra_info where person_extra_info_id = P_PERSON_EXTRA_INFO_ID) and
               person_extra_info_id <> P_PERSON_EXTRA_INFO_ID;



-- This cursor checks if the Updated Dates are within the Start/End Dates of the 'Contact'

cursor csr_chk_contact_date is
   select 1 from
      per_people_f pap,per_person_types ppf,per_person_type_usages_f ptu
   where pap.person_id in (select person_id from per_people_extra_info where person_extra_info_id = P_PERSON_EXTRA_INFO_ID) and
         pap.person_id = ptu.person_id and
         ppf.person_type_id = ptu.person_type_id and
         ppf.SEEDED_PERSON_TYPE_KEY = 'CONTACT' and
         pap.effective_start_date <= fnd_date.canonical_to_date(P_FLEX_START_DATE) and
         pap.effective_end_date >= nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) and
         ptu.effective_start_date <= fnd_date.canonical_to_date(P_FLEX_START_DATE) and
         ptu.effective_end_date >= nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'));

cursor cur_inherit is select per_information2 from per_all_people_f where
 person_id in (select person_id from per_people_extra_info where person_extra_info_id = P_PERSON_EXTRA_INFO_ID)
and effective_start_date <= fnd_date.canonical_to_date(P_FLEX_START_DATE)
and effective_end_date >= nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))
and per_information2 ='Y';

vInherit per_all_people_f.per_information2%type;

overlap_upd_found   number;
valid_contact_dates number;


BEGIN

   if (fnd_date.canonical_to_date(P_FLEX_START_DATE) >
           nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))) then
         hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
         -- This message will be 'Please enter a Start date >= End date
         hr_utility.raise_error;
  end if;

  open cur_inherit;
 fetch cur_inherit into vInherit;

  if cur_inherit%notfound then
      hr_utility.set_message(800,'HR_CONTACT_INSURED_FLEX_PL');
      hr_utility.set_message_token('CONTACTFLEX',hr_general.decode_lookup('PL_FORM_LABELS',P_PEI_INFORMATION_CATEGORY||'_FLEX'));
      hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
      hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
      hr_utility.raise_error;
  end if;

 close cur_inherit;

open csr_chk_contact_date;
  fetch csr_chk_contact_date into valid_contact_dates;
   if csr_chk_contact_date%NOTFOUND then
        hr_utility.set_message(800,'HR_CON_INVALID_DETAILS_PL');
        hr_utility.set_message_token('CONTACTFLEX',hr_general.decode_lookup('PL_FORM_LABELS',P_PEI_INFORMATION_CATEGORY||'_FLEX'));
        hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
        hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
        -- This message will be 'These details can be entered only for a Contact. Person type is not a Contact for the date range'
        hr_utility.raise_error;
     end if;
close csr_chk_contact_date;


open csr_overlap_upd_rec;
  fetch csr_overlap_upd_rec into overlap_upd_found;
   if csr_overlap_upd_rec%found then
      hr_utility.set_message(800,'HR_CONTACT_OVERLAP_REC_PL');
      hr_utility.set_message_token('CONTACTFLEX',hr_general.decode_lookup('PL_FORM_LABELS',P_PEI_INFORMATION_CATEGORY||'_FLEX'));
      hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
      hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
      hr_utility.raise_error;
   end if;
close csr_overlap_upd_rec;



END UPDATE_CON_DATE_CHK;


PROCEDURE CREATE_PL_PERSON_EXTRA_INFO
    (P_PERSON_ID                in NUMBER
    ,P_INFORMATION_TYPE         in VARCHAR2
    ,P_PEI_INFORMATION_CATEGORY in VARCHAR2
    ,P_PEI_INFORMATION1         in VARCHAR2
    ,P_PEI_INFORMATION2         in VARCHAR2
    ,P_PEI_INFORMATION3         in VARCHAR2
    ,P_PEI_INFORMATION4         in VARCHAR2
    ,P_PEI_INFORMATION5         in VARCHAR2
    ,P_PEI_INFORMATION6         in VARCHAR2
    ,P_PEI_INFORMATION7         in VARCHAR2
    ,P_PEI_INFORMATION8         in VARCHAR2
    ,P_PEI_INFORMATION9         in VARCHAR2
    ,P_PEI_INFORMATION10        in VARCHAR2
    ,P_PEI_INFORMATION11        in VARCHAR2
    ,P_PEI_INFORMATION12        in VARCHAR2
    ,P_PEI_INFORMATION13        in VARCHAR2
    ,P_PEI_INFORMATION14        in VARCHAR2
    ,P_PEI_INFORMATION15        in VARCHAR2
    ,P_PEI_INFORMATION16        in VARCHAR2
    ,P_PEI_INFORMATION17        in VARCHAR2
    ,P_PEI_INFORMATION18        in VARCHAR2
    ,P_PEI_INFORMATION19        in VARCHAR2
    ,P_PEI_INFORMATION20        in VARCHAR2
    ,P_PEI_INFORMATION21        in VARCHAR2
    ,P_PEI_INFORMATION22        in VARCHAR2
    ,P_PEI_INFORMATION23        in VARCHAR2
    ,P_PEI_INFORMATION24        in VARCHAR2
    ,P_PEI_INFORMATION25        in VARCHAR2
    ,P_PEI_INFORMATION26        in VARCHAR2
    ,P_PEI_INFORMATION27        in VARCHAR2
    ,P_PEI_INFORMATION28        in VARCHAR2
    ,P_PEI_INFORMATION29        in VARCHAR2
    ,P_PEI_INFORMATION30        in VARCHAR2) IS

BEGIN
    /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving CREATE_PL_PERSON_EXTRA_INFO');
   return;
END IF;

 if P_INFORMATION_TYPE = 'PL_CON_HEALTH_INS' then

        CHK_PERSON_TYPE(P_PERSON_ID,
                        P_PEI_INFORMATION1,
                        P_PEI_INFORMATION2,
                        P_INFORMATION_TYPE);

        CREATE_CON_DATE_CHK(P_PERSON_ID,
                            P_PEI_INFORMATION1,
                            P_PEI_INFORMATION2,
                            P_INFORMATION_TYPE);

 elsif P_INFORMATION_TYPE = 'PL_CON_HOUSEKEEPING' then

        CHK_PERSON_TYPE(P_PERSON_ID,
                        P_PEI_INFORMATION1,
                        P_PEI_INFORMATION2,
                        P_INFORMATION_TYPE);

        CREATE_CON_DATE_CHK(P_PERSON_ID,
                            P_PEI_INFORMATION1,
                            P_PEI_INFORMATION2,
                            P_INFORMATION_TYPE);



 end if;


END CREATE_PL_PERSON_EXTRA_INFO;


PROCEDURE UPDATE_PL_PERSON_EXTRA_INFO
   (P_PERSON_EXTRA_INFO_ID     in NUMBER
   ,P_PEI_INFORMATION_CATEGORY in VARCHAR2
   ,P_PEI_INFORMATION1         in VARCHAR2
   ,P_PEI_INFORMATION2         in VARCHAR2
   ,P_PEI_INFORMATION3         in VARCHAR2
   ,P_PEI_INFORMATION4         in VARCHAR2
   ,P_PEI_INFORMATION5         in VARCHAR2
   ,P_PEI_INFORMATION6         in VARCHAR2
   ,P_PEI_INFORMATION7         in VARCHAR2
   ,P_PEI_INFORMATION8         in VARCHAR2
   ,P_PEI_INFORMATION9         in VARCHAR2
   ,P_PEI_INFORMATION10        in VARCHAR2
   ,P_PEI_INFORMATION11        in VARCHAR2
   ,P_PEI_INFORMATION12        in VARCHAR2
   ,P_PEI_INFORMATION13        in VARCHAR2
   ,P_PEI_INFORMATION14        in VARCHAR2
   ,P_PEI_INFORMATION15        in VARCHAR2
   ,P_PEI_INFORMATION16        in VARCHAR2
   ,P_PEI_INFORMATION17        in VARCHAR2
   ,P_PEI_INFORMATION18        in VARCHAR2
   ,P_PEI_INFORMATION19        in VARCHAR2
   ,P_PEI_INFORMATION20        in VARCHAR2
   ,P_PEI_INFORMATION21        in VARCHAR2
   ,P_PEI_INFORMATION22        in VARCHAR2
   ,P_PEI_INFORMATION23        in VARCHAR2
   ,P_PEI_INFORMATION24        in VARCHAR2
   ,P_PEI_INFORMATION25        in VARCHAR2
   ,P_PEI_INFORMATION26        in VARCHAR2
   ,P_PEI_INFORMATION27        in VARCHAR2
   ,P_PEI_INFORMATION28        in VARCHAR2
   ,P_PEI_INFORMATION29        in VARCHAR2
   ,P_PEI_INFORMATION30        in VARCHAR2) IS

BEGIN
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving UPDATE_PL_PERSON_EXTRA_INFO');
   return;
END IF;

 if P_PEI_INFORMATION_CATEGORY = 'PL_CON_HEALTH_INS' then

     UPDATE_CON_DATE_CHK(P_PERSON_EXTRA_INFO_ID
                        ,P_PEI_INFORMATION_CATEGORY
                        ,P_PEI_INFORMATION1
                        ,P_PEI_INFORMATION2);


 elsif P_PEI_INFORMATION_CATEGORY = 'PL_CON_HOUSEKEEPING' then

     UPDATE_CON_DATE_CHK(P_PERSON_EXTRA_INFO_ID
                        ,P_PEI_INFORMATION_CATEGORY
                        ,P_PEI_INFORMATION1
                        ,P_PEI_INFORMATION2);

 end if;

END UPDATE_PL_PERSON_EXTRA_INFO;

  --
END PER_PL_PERSON_EXTRA_INFO;

/
