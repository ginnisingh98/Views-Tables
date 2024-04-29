--------------------------------------------------------
--  DDL for Package Body PER_US_VALIDATE_AEI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_VALIDATE_AEI" as
/* $Header: peusaeiv.pkb 115.3 2003/05/17 03:59:17 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
  g_package  varchar2(33)	:= '  per_us_validate_aei.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_for_duplicate_rows >-------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Verify that the segment values are not duplicated for an information
--   type in a multi record situation
--   Added for US Payroll specific situations.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   assignment_id, information_type, aei_information1, aei_information2
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
Procedure chk_for_duplicate_rows ( p_assignment_id    number,
                                   p_information_type varchar2,
                                   p_aei_information1 varchar2,
                                   p_aei_information2 varchar2,
                                   p_aei_information3 varchar2) is
  --
  l_proc  varchar2(100) := g_package||'chk_for_duplicate_rows';
  l_count number        := 0;
  --
  CURSOR c1 (p_assignment_id    number,
             p_information_type varchar2,
             p_aei_information1 varchar2,
             p_aei_information3 varchar2) is
  SELECT count(*)
  FROM   per_assignment_extra_info
  WHERE  assignment_id    = p_assignment_id
    AND  information_type = p_information_type
    AND  aei_information1 = p_aei_information1
    AND  aei_information3 = p_aei_information3
  HAVING count(*) > 1;


  CURSOR c2 (p_assignment_id    number,
             p_aei_information1 varchar2,
             p_aei_information3 varchar2) is
SELECT count(*) ct
  FROM hr_organization_information orgi,
       per_assignments_f paf,
       hr_soft_coding_keyflex sft
 WHERE orgi.organization_id          = to_number(sft.segment1)
   AND sft.soft_coding_keyflex_id    = paf.soft_coding_keyflex_id
   AND paf.assignment_id             = p_assignment_id
   AND orgi.org_information1         = p_aei_information1
   AND orgi.org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO'
   AND orgi.org_information3         = p_aei_information3;


  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if p_information_type = 'PAY_US_ASG_STATE_WAGE_PLAN_CD' then
     --
     -- check for wage plan code and duplicate record for california
     --
     if p_aei_information1 = 'CA' then
        if p_aei_information3 is null then
           hr_utility.set_message(801, 'HR_6001_ALL_MANDATORY_FIELD');
           hr_utility.set_message_token('MISSING_FIELD', 'Tax Type for California');
           hr_utility.raise_error;
        end if;
        --
        hr_utility.set_location(l_proc, 20);
         --
        for c1_rec in c1 (p_assignment_id,
                          p_information_type,
                          p_aei_information1,
                          p_aei_information3 ) loop
           --
           -- raise error if the record exists for the assignment id
           --
           hr_utility.set_message(800, 'PER_AEI_REC_EXIST_FOR_INFO_TYP');
           hr_utility.raise_error;
        end loop;

        for c2_rec in c2 (p_assignment_id,
                          p_aei_information1,
                          p_aei_information3 ) loop

          l_count := c2_rec.ct;

        end loop;

        IF l_count = 0 THEN

           --
           -- raise error if the wage plan is not defined at the GRE level
           --

           hr_utility.set_message(801, 'PAY_7024_USERTAB_BAD_ROW_VALUE');
           hr_utility.set_message_token('FORMAT','with Tax Type defined at GRE');

           hr_utility.raise_error;

        END IF;


     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
End chk_for_duplicate_rows;
--
--
End per_us_validate_aei;

/
