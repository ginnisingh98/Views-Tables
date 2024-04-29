--------------------------------------------------------
--  DDL for Package Body PER_PL_PEM_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_PEM_INFO" AS
/* $Header: peplpemp.pkb 120.0.12000000.3 2007/02/28 11:02:25 spendhar noship $ */

PROCEDURE validate_dates(p_start_date           DATE,
                         p_end_date             DATE,
                         p_period_years         NUMBER,
                         p_period_months        NUMBER,
                         p_period_days          NUMBER,
                         p_employment_category  varchar2) IS

BEGIN

if p_employment_category is NULL then   -- Previous Employer is called
  if p_start_date is NULL and p_end_date is NULL then
         if p_period_years is NULL and p_period_months is NULL and p_period_days is NULL then
            hr_utility.set_message(800,'HR_PEM_DATE_NULL_PL');
            hr_utility.raise_error;
          end if;  -- End if of Y/M/D NULL
      end if;  -- End if of Start/End Date NULL

      if (p_start_date is not NULL and p_end_date is NULL) then
          hr_utility.set_message(800,'HR_PEM_END_DATE_NULL_PL');
          hr_utility.raise_error;
      end if;

      if (p_start_date is NULL and p_end_date is not NULL) then
          hr_utility.set_message(800,'HR_PEM_START_DATE_NULL_PL');
          hr_utility.raise_error;
      end if;
end if;  -- End if of Employment Category NULL


if p_employment_category is not NULL then
  if p_start_date is NULL and p_end_date is NULL then
         if p_period_years is NULL and p_period_months is NULL and p_period_days is NULL then
            hr_utility.set_message(800,'HR_PEJ_DATE_NULL_PL');
            hr_utility.set_message_token('SERVICE',hr_general.decode_lookup('PL_TYPE_OF_SERVICE',p_employment_category));
            hr_utility.raise_error;
          end if;  -- End if of Y/M/D NULL
      end if;  -- End if of Start/End Date NULL

      if (p_start_date is not NULL and p_end_date is NULL) then
          hr_utility.set_message(800,'HR_PEJ_END_DATE_NULL_PL');
          hr_utility.set_message_token('CATEGORY',hr_general.decode_lookup('PL_TYPE_OF_SERVICE',p_employment_category));
          hr_utility.raise_error;
      end if;

      if (p_start_date is NULL and p_end_date is not NULL) then
          hr_utility.set_message(800,'HR_PEJ_START_DATE_NULL_PL');
          hr_utility.set_message_token('CATEGORY',hr_general.decode_lookup('PL_TYPE_OF_SERVICE',p_employment_category));
          hr_utility.raise_error;
      end if;


end if;  -- End if of Employment Category Not NULL

END validate_dates;


PROCEDURE VALIDATE_PREV_EMP(p_employer_type       VARCHAR2,
                            p_start_date          DATE,
                            p_end_date            DATE,
                            p_period_years        NUMBER,
                            p_period_months       NUMBER,
                            p_period_days         NUMBER,
                            p_employment_category VARCHAR2) IS

BEGIN

   if p_employer_type not in ('PARALLEL','PREVIOUS') then
       hr_utility.set_message(800,'HR_PEM_TYPE_INVALID_PL');
       hr_utility.raise_error;
   end if;

   if p_employer_type = 'PREVIOUS' then

      validate_dates(p_start_date,
                     p_end_date,
                     p_period_years,
                     p_period_months,
                     p_period_days,
                     p_employment_category);

   end if;   -- End if of Type in Previous

END VALIDATE_PREV_EMP;


PROCEDURE CREATE_PL_PREV_EMPLOYER(p_effective_date           DATE,
                                  p_business_group_id        NUMBER,
                                  p_person_id                NUMBER,
                                  p_start_date               DATE,
                                  p_end_date                 DATE,
                                  p_period_years             NUMBER,
                                  p_period_months            NUMBER,
                                  p_period_days              NUMBER,
                                  p_employer_type            VARCHAR2,
                                  p_employer_name            VARCHAR2,
                                  p_party_id                 NUMBER,
                                  p_employer_subtype         VARCHAR2,
                                  p_pem_information_category VARCHAR2,
                                  p_pem_information1         VARCHAR2,
                                  p_pem_information2         VARCHAR2,
                                  p_pem_information3         VARCHAR2,
                                  p_pem_information4         VARCHAR2,
                                  p_pem_information5         VARCHAR2,
                                  p_pem_information6         VARCHAR2) IS

l_proc VARCHAR2(72);  -- Variable used when data is uploaded directly by api
BEGIN

l_proc := 'PER_PL_PEM_INFO.'||'CREATE_PL_PREV_EMPLOYER';

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;

-- Check when data is uploaded by api's directly
    hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','PEM_NAME'),
              p_argument_value   => p_employer_name
             );


    VALIDATE_PREV_EMP(p_employer_type,
                      p_start_date,
                      p_end_date,
                      p_period_years,
                      p_period_months,
                      p_period_days,
                      NULL);


END CREATE_PL_PREV_EMPLOYER;



PROCEDURE UPDATE_PL_PREV_EMPLOYER(p_effective_date           DATE,
                                  p_previous_employer_id     NUMBER,
                                  p_start_date               DATE,
                                  p_end_date                 DATE,
                                  p_period_years             NUMBER,
                                  p_period_months            NUMBER,
                                  p_period_days              NUMBER,
                                  p_employer_type            VARCHAR2,
                                  p_employer_name            VARCHAR2,
                                  p_employer_subtype         VARCHAR2,
                                  p_pem_information_category VARCHAR2,
                                  p_pem_information1         VARCHAR2,
                                  p_pem_information2         VARCHAR2,
                                  p_pem_information3         VARCHAR2,
                                  p_pem_information4         VARCHAR2,
                                  p_pem_information5         VARCHAR2,
                                  p_pem_information6         VARCHAR2) IS

l_proc varchar2(72);

BEGIN

l_proc := 'PER_PL_PEM_INFO.'||'UPDATE_PL_PREV_EMPLOYER';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
-- The Employer Name check code is called when data is uploaded using api's directly

if p_employer_name <> hr_api.g_varchar2 then
       hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','PEM_NAME'),
              p_argument_value   => p_employer_name
             );
end if;

     VALIDATE_PREV_EMP(p_employer_type,
                       p_start_date,
                       p_end_date,
                       p_period_years,
                       p_period_months,
                       p_period_days,
                       NULL);


END UPDATE_PL_PREV_EMPLOYER;

PROCEDURE CREATE_PL_PREV_JOB(p_effective_date       DATE,
                             p_previous_employer_id NUMBER,
                             p_start_date           DATE,
                             p_end_date             DATE,
                             p_period_years         NUMBER,
                             p_period_months        NUMBER,
                             p_period_days          NUMBER,
                             p_employment_category  VARCHAR2,
                             p_pjo_information1     VARCHAR2) IS

cursor csr_emp_cat is
    select 1 from per_previous_jobs where previous_employer_id = p_previous_employer_id
    and pjo_information1 = p_pjo_information1;


dup_emp_cat number;

BEGIN
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving CREATE_PL_PREV_JOB');
   return;
END IF;

dup_emp_cat := NULL;

open csr_emp_cat;
 fetch csr_emp_cat into dup_emp_cat;
  if csr_emp_cat%found then
    hr_utility.set_message(800,'HR_PL_DUPLICATE_EMP_CATEGORY');
    hr_utility.set_message_token('SERVICE',hr_general.decode_lookup('PL_TYPE_OF_SERVICE',p_pjo_information1));
    hr_utility.raise_error;
 end if;
close csr_emp_cat;

      validate_dates(p_start_date,
                     p_end_date,
                     p_period_years,
                     p_period_months,
                     p_period_days,
                     p_pjo_information1);

END CREATE_PL_PREV_JOB;

PROCEDURE UPDATE_PL_PREV_JOB(p_effective_date       DATE,
                             p_previous_job_id      NUMBER,
                             p_start_date           DATE,
                             p_end_date             DATE,
                             p_period_years         NUMBER,
                             p_period_months        NUMBER,
                             p_period_days          NUMBER,
                             p_employment_category  VARCHAR2,
                             p_pjo_information1     VARCHAR2) IS

cursor csr_emp_catupd is
select ppj.pjo_information1 from per_previous_employers ppe, per_previous_jobs ppj
       where
         ppe.previous_employer_id = ppj.previous_employer_id and
         ppj.previous_job_id <> p_previous_job_id and ppj.previous_employer_id in (
		 select previous_employer_id from per_previous_jobs where previous_job_id = p_previous_job_id);

dup_emp_cat per_previous_jobs.pjo_information1%TYPE;


BEGIN

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving UPDATE_PL_PREV_JOB');
   return;
END IF;

dup_emp_cat := NULL;

   open csr_emp_catupd;
     fetch csr_emp_catupd into dup_emp_cat;
   close csr_emp_catupd;

   if p_pjo_information1 = dup_emp_cat then
     hr_utility.set_message(800,'HR_PL_DUPLICATE_EMP_CATEGORY');
     hr_utility.set_message_token('SERVICE',hr_general.decode_lookup('PL_TYPE_OF_SERVICE',p_pjo_information1));
     hr_utility.raise_error;
   end if;

      validate_dates(p_start_date,
                     p_end_date,
                     p_period_years,
                     p_period_months,
                     p_period_days,
                     p_pjo_information1);

END UPDATE_PL_PREV_JOB;

END PER_PL_PEM_INFO;

/
