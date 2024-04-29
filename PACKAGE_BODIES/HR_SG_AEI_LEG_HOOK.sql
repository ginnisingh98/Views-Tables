--------------------------------------------------------
--  DDL for Package Body HR_SG_AEI_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SG_AEI_LEG_HOOK" as
/* $Header: pesglhae.pkb 120.1.12010000.2 2008/11/17 04:20:06 jalin ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
  g_package  varchar2(33)	:= 'hr_sg_aei_leg_hook.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_ir8s_c_valid>-------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Verify that the segment values are valid for certain conditions
--   Added for SG Payroll specific situations.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   assignment_id, information_type, aei_information1, aei_information2,
--   aei_information3, aei_information4, aei_information5, aei_information6,
--   aei_information7, aei_information8, aei_information9, aei_information10
--   aei_information11
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
Procedure chk_ir8s_c_valid ( p_assignment_id    number,
                             p_information_type varchar2,
                             p_aei_information1 varchar2,
                             p_aei_information2 varchar2,
                             p_aei_information3 varchar2,
                             p_aei_information4 varchar2,
                             p_aei_information5 varchar2,
                             p_aei_information6 varchar2,
                             p_aei_information7 varchar2,
                             p_aei_information8 varchar2,
                             p_aei_information9 varchar2,
                             p_aei_information10 varchar2,
                             p_aei_information11 varchar2) is
  --
  l_proc  varchar2(100) := g_package||'chk_ir8s_c_valid';
  l_invalid_record      varchar(1) NULL;
  --
  CURSOR ir8s_c_invalid_records
            (p_assignment_id    number,
             p_information_type varchar2,
             p_aei_information1 varchar2) is
  SELECT 'X'
  FROM   per_assignment_extra_info
  WHERE  assignment_id    = p_assignment_id
    AND  information_type = p_information_type
    AND  aei_information1 = p_aei_information1
  HAVING count(*) > 3;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if p_information_type = 'HR_CPF_CLAIMED_SG' then

     -- check if it has more than 3 claim details entered per basic year
     open ir8s_c_invalid_records
                (p_assignment_id,
                 p_information_type,
                 p_aei_information1);
     fetch ir8s_c_invalid_records into l_invalid_record;
     if ir8s_c_invalid_records%found then
       fnd_message.set_name('PAY', 'HR_SG_IR8S_C_RECORDS_INVALID');
       fnd_message.raise_error;

        hr_utility.set_location(l_proc, 20);

     end if;
     close ir8s_c_invalid_records;


     -- Check if any the following has been entered, Additional Wages, Payment
     -- for additional wages from date, Payment for additional wages to date
     -- and pay date for additional wages

     if ((nvl(p_aei_information2, 0) <> 0) and  /* Bug 7415444 */
             (p_aei_information3 is null or
              p_aei_information4 is null or
              p_aei_information5 is null)) or
         ((p_aei_information3 is not null) and
             (nvl(p_aei_information2, 0) = 0 or
              p_aei_information4 is null or
              p_aei_information5 is null)) or
         ((p_aei_information4 is not null) and
             (nvl(p_aei_information2, 0) = 0 or
              p_aei_information3 is null or
              p_aei_information5 is null)) or
         ((p_aei_information5 is not null) and
             (nvl(p_aei_information2, 0) = 0 or
              p_aei_information3 is null or
              p_aei_information4 is null)) then

        fnd_message.set_name('PAY', 'HR_SG_IR8S_C_ADD_WAGES_INVALID');
        fnd_message.raise_error;

        hr_utility.set_location(l_proc, 30);

     -- check if Period To Date of Additional Wages is greater then
     -- Period From Date of Additional Wages
     -- Modified the condition for Bug# 3249303

     elsif fnd_date.canonical_to_date(p_aei_information4) <= fnd_date.canonical_to_date(p_aei_information3) then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID2');
           fnd_message.set_token('DATE1', 'Period To Date of Additional Wages');
           fnd_message.set_token('DATE2', 'Period From Date of Additional Wages');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 40);

     -- Check Pay date for additional wages must be greater or equal to
     -- Payment for additional wages to date

     elsif fnd_date.canonical_to_date(p_aei_information5) < fnd_date.canonical_to_date(p_aei_information4) then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID');
           fnd_message.set_token('DATE1', 'Pay Date of Additional Wages');
           fnd_message.set_token('DATE2', 'Period To Date of Additional Wages');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 50);

     -- Check if Date of refund on employer CPF contribution is entered then
     -- ensure Pay date for additional wages must be entered

     elsif p_aei_information8 is not null and
           p_aei_information5 is null then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID1');
           fnd_message.set_token('FIELD1', 'Date of Refund of Employer Amount');
           fnd_message.set_token('FIELD2', 'Pay Date of Additional Wages');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 60);

     -- Check if ER CPF contribution on amount of refund is entered then ensure
     -- Date of refund on ER CPF contribution on amount of refund must be entered
     elsif nvl(p_aei_information6, 0) <> 0 and p_aei_information8 is null then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID1');
           fnd_message.set_token('FIELD1', 'Amount of Refund of Employer Contribution');
           fnd_message.set_token('FIELD2', 'Date of Refund of Employer Amount');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 70);

     -- Check if Interset paid on ER CPF contribution on amount of refund
     -- is entered then ensure Date of refund on ER CPF contribution on amount
     -- of refund must be entered

     elsif nvl(p_aei_information7, 0) <> 0 and p_aei_information8 is null then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID1');
           fnd_message.set_token('FIELD1', 'Interest on Refund of Employer Contribution');
           fnd_message.set_token('FIELD2', 'Date of Refund of Employer Amount');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 80);

     -- Check if Date of refund on ER CPF contribution on amount of refund is
     -- entered, then ensure ER CPF contribution on amount of refund or
     -- Interest paid on ER CPF contribution on amount of refund must be entered

     elsif ((p_aei_information8 is not null) and
                (nvl(p_aei_information6, 0) = 0 and nvl(p_aei_information7, 0) =0)) then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_CPF_INVALID');
           fnd_message.set_token('FIELD1', 'Amount of Refund of Employer Contribution');
           fnd_message.set_token('FIELD2', 'Interest on Refund of Employer Contribution');
           fnd_message.set_token('FIELD3', 'Date of Refund of Employer Amount');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 90);

     -- Check date of refund on ER CPF Contribution on amount of refund must
     -- be greater or equal to Pay date for additional wages

     elsif fnd_date.canonical_to_date(p_aei_information8) < fnd_date.canonical_to_date(p_aei_information5) then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID');
           fnd_message.set_token('DATE1', 'Date of Refund of Employer Amount');
           fnd_message.set_token('DATE2', 'Pay Date of Additional Wages');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 100);

     -- Check if Date of refund on employee CPF contribution is entered then
     -- ensure Pay date for additional wages must be entered

     elsif p_aei_information11 is not null and
             p_aei_information5 is null then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID1');
           fnd_message.set_token('FIELD1', 'Date of Refund of Employee Amount');
           fnd_message.set_token('FIELD2', 'Pay Date of Additional Wages');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 110);

     -- Check if ER CPF contribution on amount of refund is entered then ensure
     -- Date of refund on ER CPF contribution on amount of refund must be entered

     elsif nvl(p_aei_information9, 0) <> 0 and p_aei_information11 is null then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID1');
           fnd_message.set_token('FIELD1', 'Amount of Refund of Employee Contribution');
           fnd_message.set_token('FIELD2', 'Date of Refund of Employee Amount');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 120);

     -- Check if Interset paid on EE CPF contribution on amount of refund
     -- is entered then ensure Date of refund on EE CPF contribution on amount
     -- of refund must be entered

     elsif nvl(p_aei_information10, 0) <> 0 and p_aei_information11 is null then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID1');
           fnd_message.set_token('FIELD1', 'Interest on Refund of Employee Contribution');
           fnd_message.set_token('FIELD2', 'Date of Refund of Employee Amount');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 130);

     -- Check if Date of refund on EE CPF contribution on amount of refund is
     -- entered, then ensure EE CPF contribution on amount of refund or
     -- Interest paid on EE CPF contribution on amount of refund must be entered

     elsif ((p_aei_information11 is not null) and
                (nvl(p_aei_information9, 0) = 0 and nvl(p_aei_information10, 0) = 0)) then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_CPF_INVALID');
           fnd_message.set_token('FIELD1', 'Amount of Refund of Employee Contribution');
           fnd_message.set_token('FIELD2', 'Interest on Refund of Employee Contribution');
           fnd_message.set_token('FIELD3', 'Date of Refund of Employee Amount');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 140);

     -- Check date of refund on EE CPF Contribution on amount of refund must
     -- be greater or equal to Pay date for additional wages

     elsif fnd_date.canonical_to_date(p_aei_information11) < fnd_date.canonical_to_date(p_aei_information5) then
           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_INVALID');
           fnd_message.set_token('DATE1', 'Date of Refund of Employee Amount');
           fnd_message.set_token('DATE2', 'Pay Date of Additional Wages');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 150);

     -- Check all dates are in basis year
     -- Bug 5960714, this validation check should not include Date of refund
     -- p_aei_information8 &p_aei_information11
     elsif nvl(to_char(fnd_date.canonical_to_date(p_aei_information3), 'YYYY'),
                p_aei_information1) <> p_aei_information1 or
            nvl(to_char(fnd_date.canonical_to_date(p_aei_information4), 'YYYY'),
                p_aei_information1) <> p_aei_information1 or
            nvl(to_char(fnd_date.canonical_to_date(p_aei_information5), 'YYYY'),
                p_aei_information1) <> p_aei_information1 then

           fnd_message.set_name('PAY', 'HR_SG_IR8S_C_DATES_SAME_YEAR');
           fnd_message.raise_error;

           hr_utility.set_location(l_proc, 160);

     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
  --
End chk_ir8s_c_valid;
--
--
End hr_sg_aei_leg_hook;

/
