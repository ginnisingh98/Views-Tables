--------------------------------------------------------
--  DDL for Package Body PER_PL_LEI_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_LEI_INFO" as
/* $Header: peplleip.pkb 120.1 2006/09/13 12:23:47 mseshadr noship $ */
--------------------------------------------------------------------------------
-- PROCEDURE CREATE_PL_LEI_INFO
--------------------------------------------------------------------------------

PROCEDURE CHK_STREET_NAME(p_lei_information3	VARCHAR2,
				  p_lei_information4	VARCHAR2
 				 ) IS
--
BEGIN
--
  IF p_lei_information3 is not null and p_lei_information4 is null THEN
     hr_utility.set_message(800,'HR_PL_ST_NAME_NOT_SPEC');
     hr_utility.raise_error;
  END IF;
END CHK_STREET_NAME;



PROCEDURE CREATE_LEI_DETAILS(P_LOCATION_ID    NUMBER,
                             P_FLEX_START_DATE  VARCHAR2,
                             P_FLEX_END_DATE    VARCHAR2,
   		             P_INFORMATION_TYPE VARCHAR2) IS

cursor csr_overlap_rec is
   select 1
          from hr_location_extra_info where
               location_id = p_location_id and
	       INFORMATION_TYPE = P_INFORMATION_TYPE and
               (fnd_date.canonical_to_date(P_FLEX_START_DATE) between fnd_date.canonical_to_date(LEI_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(LEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
	        nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))
                    between fnd_date.canonical_to_date(LEI_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(LEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
                fnd_date.canonical_to_date(LEI_INFORMATION1) between fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                                nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) or
                nvl(fnd_date.canonical_to_date(LEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) between
                                 fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                               nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')));

overlap_found  number;

BEGIN

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving CREATE_LEI_DETAILS');
   return;
END IF;

if (fnd_date.canonical_to_date(P_FLEX_START_DATE) > fnd_date.canonical_to_date(P_FLEX_END_DATE)) then
         hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
         	     -- This message will be 'Please enter a Start date >= End date
         hr_utility.raise_error;
  end if;

open csr_overlap_rec;
  fetch csr_overlap_rec into overlap_found;
   if csr_overlap_rec%found then
      hr_utility.set_message(800,'HR_ORG_OVERLAP_REC_PL');
      hr_utility.set_message_token('ORGFLEX',hr_general.decode_lookup('PL_FORM_LABELS',P_INFORMATION_TYPE));
      hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
      hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
      hr_utility.raise_error;
   end if;
close csr_overlap_rec;


END CREATE_LEI_DETAILS;
--  CREATE_LEI_DETAILS
------------------------------------------------------------------------------------------------------
--  UPDATE_LEI_DETAILS																		        --
------------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_LEI_DETAILS(P_LOCATION_EXTRA_INFO_ID  NUMBER,
                             P_FLEX_START_DATE         VARCHAR2,
                             P_FLEX_END_DATE           VARCHAR2,
                             p_lei_information_category VARCHAR2) IS


cursor csr_overlap_upd_rec is
   select 1
          from hr_location_extra_info where
                      INFORMATION_TYPE = p_lei_information_category
	        and location_extra_info_id <> P_LOCATION_EXTRA_INFO_ID and
                location_id = (select location_id from hr_location_extra_info where LOCATION_EXTRA_INFO_ID = P_LOCATION_EXTRA_INFO_ID)
                and (fnd_date.canonical_to_date(P_FLEX_START_DATE) between fnd_date.canonical_to_date(LEI_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(LEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
	        nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))
                    between fnd_date.canonical_to_date(LEI_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(LEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
                fnd_date.canonical_to_date(LEI_INFORMATION1) between fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                                nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) or
                nvl(fnd_date.canonical_to_date(LEI_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) between
                                 fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                               nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')));


overlap_upd_found  number;
org_start_date date;
org_end_date   date;

BEGIN
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving UPDATE_LEI_DETAILS');
   return;
END IF;

if (fnd_date.canonical_to_date(P_FLEX_START_DATE) > fnd_date.canonical_to_date(P_FLEX_END_DATE)) then
         hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
	     -- This message will be 'Please enter a Start date >= End date
         hr_utility.raise_error;
  end if;

open csr_overlap_upd_rec;
  fetch csr_overlap_upd_rec into overlap_upd_found;
   if csr_overlap_upd_rec%found then
      hr_utility.set_message(800,'HR_ORG_OVERLAP_REC_PL');
      hr_utility.set_message_token('ORGFLEX',hr_general.decode_lookup('PL_FORM_LABELS',p_lei_information_category));
      hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
      hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
      hr_utility.raise_error;
   end if;
close csr_overlap_upd_rec;

END UPDATE_LEI_DETAILS;
--  UPDATE_LEI_DETAILS

PROCEDURE CREATE_PL_LEI_INFO(p_information_type VARCHAR2
                             ,p_location_id       NUMBER
                             ,p_lei_information1  VARCHAR2
                             ,p_lei_information2  VARCHAR2
                             ,p_lei_information3  VARCHAR2
                             ,p_lei_information4  VARCHAR2
                             ,p_lei_information5  VARCHAR2
                             ,p_lei_information6  VARCHAR2
                             ,p_lei_information7  VARCHAR2
                             ,p_lei_information8  VARCHAR2
                             ,p_lei_information9  VARCHAR2
                             ,p_lei_information10 VARCHAR2
                             ,p_lei_information11 VARCHAR2
                             ,p_lei_information12 VARCHAR2
                             ,p_lei_information13 VARCHAR2
                             ,p_lei_information14 VARCHAR2
                             ,p_lei_information15 VARCHAR2
                             ,p_lei_information16 VARCHAR2
                             ,p_lei_information17 VARCHAR2
                             ,p_lei_information18 VARCHAR2
                             ,p_lei_information19 VARCHAR2
                             ,p_lei_information20 VARCHAR2
                             ,p_lei_information21 VARCHAR2
                             ,p_lei_information22 VARCHAR2
                             ,p_lei_information23 VARCHAR2
                             ,p_lei_information24 VARCHAR2
                             ,p_lei_information25 VARCHAR2
                             ,p_lei_information26 VARCHAR2
                             ,p_lei_information27 VARCHAR2
                             ,p_lei_information28 VARCHAR2
                             ,p_lei_information29 VARCHAR2
                             ,p_lei_information30 VARCHAR2
					 ) IS

--
BEGIN
--
 IF p_information_type ='PL_CORRESPONDENCE_ADDRESS' THEN

    CREATE_LEI_DETAILS(P_LOCATION_ID,
                       p_lei_information1,
                       p_lei_information2,
		       P_INFORMATION_TYPE);

    CHK_STREET_NAME(p_lei_information3,p_lei_information4);
 END IF;

--
END CREATE_PL_LEI_INFO;

PROCEDURE UPDATE_PL_LEI_INFO(p_lei_information_category  VARCHAR2
                             ,p_location_extra_info_id NUMBER
                             ,p_lei_information1  VARCHAR2
                             ,p_lei_information2  VARCHAR2
                             ,p_lei_information3  VARCHAR2
                             ,p_lei_information4  VARCHAR2
                             ,p_lei_information5  VARCHAR2
                             ,p_lei_information6  VARCHAR2
                             ,p_lei_information7  VARCHAR2
                             ,p_lei_information8  VARCHAR2
                             ,p_lei_information9  VARCHAR2
                             ,p_lei_information10 VARCHAR2
                             ,p_lei_information11 VARCHAR2
                             ,p_lei_information12 VARCHAR2
                             ,p_lei_information13 VARCHAR2
                             ,p_lei_information14 VARCHAR2
                             ,p_lei_information15 VARCHAR2
                             ,p_lei_information16 VARCHAR2
                             ,p_lei_information17 VARCHAR2
                             ,p_lei_information18 VARCHAR2
                             ,p_lei_information19 VARCHAR2
                             ,p_lei_information20 VARCHAR2
                             ,p_lei_information21 VARCHAR2
                             ,p_lei_information22 VARCHAR2
                             ,p_lei_information23 VARCHAR2
                             ,p_lei_information24 VARCHAR2
                             ,p_lei_information25 VARCHAR2
                             ,p_lei_information26 VARCHAR2
                             ,p_lei_information27 VARCHAR2
                             ,p_lei_information28 VARCHAR2
                             ,p_lei_information29 VARCHAR2
                             ,p_lei_information30 VARCHAR2
					 ) IS

--
BEGIN
--
	IF p_lei_information_category ='PL_CORRESPONDENCE_ADDRESS' THEN
            UPDATE_LEI_DETAILS(P_LOCATION_EXTRA_INFO_ID,
                               p_lei_information1,
	                       p_lei_information2,
                               p_lei_information_category);

 	   CHK_STREET_NAME(p_lei_information3,p_lei_information4);
	END IF;
--
END UPDATE_PL_LEI_INFO;

END PER_PL_LEI_INFO;

/
