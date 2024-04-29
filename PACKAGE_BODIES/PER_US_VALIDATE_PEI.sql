--------------------------------------------------------
--  DDL for Package Body PER_US_VALIDATE_PEI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_VALIDATE_PEI" as
/* $Header: peuspeiv.pkb 120.0 2005/05/31 22:43:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
  g_package  varchar2(33)	:= '  per_us_validate_pei.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_us_visa_rows >-------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Record level validation for US Visa PEI types.
--   Detail validation rules is documented in
--     $DOCS_TOP/per/projects/visa/visahld.doc
--
-- Pre Conditions:
--
--
-- In Parameters:
--   person_id, information_type, pei_information5, pei_information7,
--     pei_information8, pei_information10, pei_information11
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
-- ----------------------------------------------------------------------------
Procedure chk_us_visa_rows ( p_person_id    number,
                                   p_information_type varchar2,
                                   p_pei_information5 varchar2,
                                   p_pei_information6 varchar2,
                                   p_pei_information7 varchar2,
                                   p_pei_information8 varchar2,
                                   p_pei_information9 varchar2,
                                   p_pei_information10 varchar2,
                                   p_pei_information11 varchar2) is
  --
  l_proc  varchar2(100) := g_package||'chk_us_visa_rows';
  l_counter number := 0;
  a_end_date     date;

  --
  -- Validation of START_DATE and END_DATE for PER_US_PASSPORT_DETAILS,
  -- PER_US_VISA_DETAILS, and PER_US_VISIT_HISTORY
  -- WWBUG 2097669
  -- Add fnd_date.date_to_canonial to pei_informatin7 and 8
  CURSOR c1 (p_person_id    number,
             p_information_type varchar2) is
  SELECT 1
  FROM  per_people_extra_info
  WHERE person_id    = p_person_id
    AND information_type = p_information_type
    AND fnd_date.canonical_to_date(pei_information7) >
       fnd_date.canonical_to_date(nvl(pei_information8,'4712/12/31 00:00:00'));
  --
  -- Non-duplicate rows on INCOME_CODE of PER_US_PAYROLL_DETAILS
  CURSOR c2 (p_person_id    number,
             p_information_type varchar2,
             p_pei_information5 varchar2) is
  SELECT count(*)
  FROM   per_people_extra_info
  WHERE  person_id    = p_person_id
    AND  information_type = p_information_type
    AND  pei_information5 = p_pei_information5
  HAVING count(*) > 1;
  --
  -- Unique CURRENT Visa row of PER_US_VISA_DETAILS
  CURSOR c3 (p_person_id    number,
             p_information_type varchar2) is
  SELECT count(*)
  FROM   per_people_extra_info
  WHERE  person_id    = p_person_id
    AND  information_type = p_information_type
    AND  pei_information10 = 'Y'
  HAVING count(*) > 1;
  --
  -- Non-duplicate rows on PER_US_PASSPORT_DETAILS,PER_US_VISA_DETAILS
  CURSOR c4 (p_person_id    number,
             p_information_type varchar2,
             p_pei_information5 varchar2,
             p_pei_information6 varchar2) is
  SELECT count(*)
  FROM   per_people_extra_info
  WHERE  person_id    = p_person_id
    AND  information_type = p_information_type
    AND  pei_information5 = p_pei_information5
    AND  pei_information6 = p_pei_information6
  HAVING count(*) > 1;
  --
  -- Non-overlap Validation for START_DATE and END_DATE of PER_US_VISIT_HISTORY
  CURSOR next_visit (p_person_id    number,
             p_information_type varchar2) is
  SELECT fnd_date.canonical_to_date(pei_information7) start_date,
         fnd_date.canonical_to_date(nvl(pei_information8,'4712/12/31 00:00:00'))
               end_date
  FROM  per_people_extra_info
  WHERE person_id    = p_person_id
    AND information_type = p_information_type
  ORDER BY start_date asc;
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if p_information_type IN ('PER_US_PASSPORT_DETAILS',
      'PER_US_VISA_DETAILS', 'PER_US_VISIT_HISTORY')   then
     --
     -- check for end date later than start date
     hr_utility.set_location(l_proc, 15);
     for c1_rec in c1 (p_person_id,
                       p_information_type) loop

        --
        -- raise error if start date later than end date
        hr_utility.set_message(800, 'PER_INCORRECT_START_END_DATES');
        hr_utility.raise_error;
     end loop;
  end if;

  hr_utility.set_location(l_proc, 20);

  if p_information_type IN ('PER_US_PASSPORT_DETAILS',
      'PER_US_VISA_DETAILS')   then
     --
     -- check for duplicate record
     hr_utility.set_location(l_proc, 25);
     for c4_rec in c4 (p_person_id,
                       p_information_type,
                       p_pei_information5,
                       p_pei_information6 ) loop
         --
         -- raise error if a duplicate record exists
         hr_utility.set_message(800, 'PER_PEI_VISA_DUP_RECORD');
         hr_utility.raise_error;
     end loop;
  end if;

  hr_utility.set_location(l_proc, 30);

  if p_information_type = 'PER_US_PAYROLL_DETAILS' then
     --
     -- check for INCOME_CODE duplicate record
     hr_utility.set_location(l_proc, 35);
     for c2_rec in c2 (p_person_id,
                       p_information_type,
                       p_pei_information5 ) loop
         --
         -- raise error if the record exists for the same INCOME_CODE
         hr_utility.set_message(800, 'PER_PEI_VISA_DUP_RECORD');
         hr_utility.raise_error;
     end loop;
  end if;
  --
  hr_utility.set_location(l_proc, 40);

  if p_information_type = 'PER_US_INCOME_FORECAST' then
     --
     -- check for INCOME_CODE duplicate record
     hr_utility.set_location(l_proc, 45);
     for c2_rec in c2 (p_person_id,
                       p_information_type,
                       p_pei_information5 ) loop
         --
         -- raise error if the record exists for the same INCOME_CODE
         hr_utility.set_message(800, 'PER_PEI_VISA_DUP_RECORD');
         hr_utility.raise_error;
     end loop;
  end if;
  --

  hr_utility.set_location(l_proc, 50);

  if p_information_type = 'PER_US_VISA_DETAILS' then
     --
     -- check for J Visa Category
     hr_utility.set_location(l_proc, 55);
     if (p_pei_information5 = 'J-1' or p_pei_information5 = 'J-2') and
        p_pei_information9 is NULL then
        -- raise error if J Visa Category is not entered for J visa
        hr_utility.set_message(800, 'PER_PEI_J_VISA_CATEGORY');
        hr_utility.raise_error;
     end if;
     --
     -- check for more than one CURRENT Visa record
     hr_utility.set_location(l_proc, 60);
     for c3_rec in c3 (p_person_id, p_information_type) loop
         --
         -- raise error if more than one record has CURRENT set to Y
         hr_utility.set_message(800, 'PER_PEI_MULTI_CURRENT_VISA');
         hr_utility.raise_error;
     end loop;
  end if;
  --
  hr_utility.set_location(l_proc, 65);

  if p_information_type = 'PER_US_VISIT_HISTORY' then
     --
     -- check for overlap visit period
     hr_utility.set_location(l_proc, 70);
     for c_rec in next_visit (p_person_id, p_information_type) loop
        l_counter := l_counter + 1;
        --
        hr_utility.set_location('End Date: '||
            to_char(c_rec.end_date,'YYYY/MM/DD')||' : ', 75);
        if l_counter > 1 then
           if c_rec.start_date <= a_end_date then
              --
              -- raise error if there is a visit date overlap
              hr_utility.set_message(800, 'PER_PEI_VISIT_OVERLAP');
              hr_utility.raise_error;
           end if;
        end if;
        -- Save the end date of previous visit
        a_end_date := c_rec.end_date;

     end loop;
  end if;
  --
  hr_utility.set_location(l_proc, 80);

  if p_information_type = 'PER_US_ADDITIONAL_DETAILS' then
     --
     -- check if DEP_CHILDREN_IN_CNTRY < DEP_CHILDREN_TOTAL
     hr_utility.set_location(l_proc, 85);
     if to_number(p_pei_information11) > to_number(p_pei_information10) then
         --
         hr_utility.set_message(800, 'PER_PEI_WRONG_DEP_CHILD_NUM');
         hr_utility.raise_error;
     end if;
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
  --
End chk_us_visa_rows;
--
--
End per_us_validate_pei;

/
