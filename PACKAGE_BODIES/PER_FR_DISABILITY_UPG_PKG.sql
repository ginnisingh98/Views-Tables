--------------------------------------------------------
--  DDL for Package Body PER_FR_DISABILITY_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_DISABILITY_UPG_PKG" AS
/* $Header: pefrdiup.pkb 115.1 2002/07/03 06:47:11 pvaish noship $ */

  CURSOR csr_disabled_entries(p_business_group_id number)
  IS
    SELECT pei.PERSON_ID,
           per1.full_name,
           per1.employee_number,
           pei.PEI_INFORMATION1,
           pei.PEI_INFORMATION2,
           pei.PEI_INFORMATION3,
           pei.PEI_INFORMATION4,
           pei.PEI_INFORMATION5,
           pei.PEI_INFORMATION6,
           pei.PEI_INFORMATION7,
           pei.PEI_INFORMATION8,
           pei.PEI_INFORMATION9,
           pei.PERSON_EXTRA_INFO_ID
    FROM   per_people_extra_info pei
    ,      per_all_people_f per1
    WHERE  pei.PEI_INFORMATION_CATEGORY = 'FR_DISABILITY'
    AND    pei.person_id = per1.person_id
    AND    per1.business_group_id = p_business_group_id
    AND    per1.effective_start_date = (select max(per2.effective_start_date)
                                         from per_all_people_f per2
                                        where per2.person_id = per1.person_id
                                          and per2.business_group_id = p_business_group_id)
    AND   pei.PEI_INFORMATION30 IS NULL
    order by per1.full_name;

g_package varchar2(30) := 'per_fr_disability_upg_pkg';

/********************************************************************************
*  Procedure that writes out the whole disability information to the log        *
*  this allows users to mannually enter this information where it could not be  *
*  created by the process                                                       *
********************************************************************************/
procedure write_disability_to_log(p_disability in csr_disabled_entries%ROWTYPE)
IS
BEGIN
/*Added script to print all Disability related information into Log*/
   per_fr_upgrade_data_pkg.write_log(p_disability.employee_number);
   per_fr_upgrade_data_pkg.write_log(p_disability.full_name);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION1);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION2);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION3);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION4);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION5);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION6);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION7);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION8);
   per_fr_upgrade_data_pkg.write_log(p_disability.PEI_INFORMATION9);

END write_disability_to_log;

/***********************************************************************
*  function TRANSFER_DATA                                              *
*  This fucntion must be called from run_upgrade                       *
*  Return = 0 means upgrade completed OK.                              *
*  Return = 1 means warnings                                           *
*  Return = 2 means upgrade failed                                     *
***********************************************************************/
function transfer_data(p_business_group_id IN NUMBER) return number
IS
  l_disabled	                csr_disabled_entries%ROWTYPE;
  l_person_start_date 	        date;
  l_person_end_date             date;
  l_disability_id               number;
  l_object_version_number       number;
  l_reason                      varchar2(30);
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_disabilities_start_date     date;
  l_disabilities_end_date       date;
  l_category                    varchar2(30);
  l_run_status                  number :=0;            /* Status of the whole run */
  l_record_status               number;
  l_proc varchar2(72) := g_package||'.transfer_data';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

  OPEN csr_disabled_entries(p_business_group_id);
  FETCH csr_disabled_entries INTO l_disabled;

  WHILE csr_disabled_entries%FOUND LOOP

     l_record_status :=0;

     SELECT MIN(EFFECTIVE_START_DATE), MAX(effective_end_date)
     INTO l_person_start_date, l_person_end_date
     FROM per_all_people_f
     WHERE person_id = l_disabled.person_id;

     /* Determine Start date for disability record */
     IF l_disabled.PEI_INFORMATION6 IS NULL THEN
        -- Disability Start Date is NULL. Use person start date
        l_disabilities_start_date := l_person_start_date;
     ELSIF FND_date.canonical_to_date(l_disabled.PEI_INFORMATION6) < l_person_start_date THEN
        -- Disability started prior to employment.  Therefore use person start date.
        l_disabilities_start_date := l_person_start_date;
     ELSIF FND_date.canonical_to_date(l_disabled.PEI_INFORMATION6) BETWEEN l_person_start_date AND l_person_end_date THEN
         -- Disability started within employment term. Use disability start date.
        l_disabilities_start_date := FND_date.canonical_to_date(l_disabled.PEI_INFORMATION6);
     ELSE
        -- Disability Started after end date of employee
        per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74992_DIS_BAD_STR_DATE');
        l_record_status := 1;
     END IF;

     /* Determine End date for disability record */
     IF l_disabled.PEI_INFORMATION7 IS NULL THEN
        -- Disability end Date is NULL. Use person end date
        l_disabilities_end_date := l_person_end_date;
     ELSIF FND_date.canonical_to_date(l_disabled.PEI_INFORMATION7) > l_person_end_date THEN
        -- Disability end date exceeds employment term, use end of employment
        l_disabilities_end_date := l_person_end_date;
     ELSIF (FND_date.canonical_to_date(l_disabled.PEI_INFORMATION7) between l_person_start_date AND l_person_end_date) THEN
         -- Disability ended within employment term.  Use Disability end date.
         l_disabilities_end_date := FND_date.canonical_to_date(l_disabled.PEI_INFORMATION7);
     ELSE
         -- Disability end before start date of employeee
        per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74993_DIS_BAD_END_DATE');
        l_record_status := 1;
     END IF;


      If l_record_status = 1 THEN
         -- We could not create the record because the dates were invalid.
         -- Write out disability information to log for mannual user entry.
         write_disability_to_log(l_disabled);
         if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
            l_run_status := 1;  -- Set status of run to warning.
         end if;
         -- Set the record status so that it is not processed in the future.
         update per_people_extra_info
            set PEI_INFORMATION30 = 'INVALID_DATES'
          where person_id = l_disabled.person_id
            and PEI_INFORMATION_CATEGORY = 'FR_DISABILITY'
            and PERSON_EXTRA_INFO_ID = l_disabled.PERSON_EXTRA_INFO_ID;

      ELSE
          /* Map fields to new values and default mandatory fields that are NULL  */
          SELECT decode(l_disabled.PEI_INFORMATION9, 'Y', 'OCC_INC', NULL)
          INTO l_reason
          from DUAL;

          if l_disabled.PEI_INFORMATION4 IS NULL THEN
              l_category := 'UNKNOWN';
              /* Field is defaulted Change status to warning. And write message to log */
              per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74994_DIS_CAT_DFLT',
                                                        p_token1 => 'EMPLOYEE:'|| l_disabled.employee_number);
              if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
                 l_run_status := 1;  -- Set status of run to warning.
              end if;
          else
             l_category := l_disabled.PEI_INFORMATION4;
          end if;



          BEGIN -- Insert new disability section

             SAVEPOINT start_insert;

             PER_DISABILITY_API.create_disability(p_disability_id => l_disability_id,
                                             p_person_id => l_disabled.PERSON_ID,
                                             p_quota_fte => 1.00,
                                             p_category => l_category,
                                             p_status => 'A',
                                             p_description => l_disabled.PEI_INFORMATION2,
                                             p_reason => l_reason,
                                             p_degree => TO_NUMBER(l_disabled.PEI_INFORMATION3),
                                             p_work_restriction => l_disabled.PEI_INFORMATION8,
                                             p_effective_date => l_disabilities_start_date,
                                             p_effective_start_date => l_effective_start_date,
                                             p_effective_end_date => l_effective_end_date,
                                             p_dis_information_category => 'FR',
                                             p_dis_information1 => l_disabled.PEI_INFORMATION1,
                                             p_dis_information2 => l_disabled.PEI_INFORMATION5,
                                             p_object_version_number => l_object_version_number);

             /* End Date the Disability if different to end date of person */
             IF l_disabilities_end_date<>l_person_end_date then
                hr_utility.set_location('about to update',5);
                --
                PER_DISABILITY_API.delete_disability(p_disability_id => l_disability_id,
                                                 p_effective_date => l_disabilities_end_date,
                                                 p_datetrack_mode => 'DELETE',
                                                 p_object_version_number => l_object_version_number,
                                                 p_effective_start_date => l_effective_start_date,
                                                 p_effective_end_date => l_effective_end_date);
             END IF;   -- End of Disability End Date.

             update per_people_extra_info
                set PEI_INFORMATION30 = to_char(l_disability_id)
              where person_id = l_disabled.person_id
                and PEI_INFORMATION_CATEGORY = 'FR_DISABILITY'
                and PERSON_EXTRA_INFO_ID = l_disabled.PERSON_EXTRA_INFO_ID;

          exception when others then
             rollback to start_insert;
             per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74995_DIS_UPG_FATAL'
                                            ,p_token1 => 'STEP:10');
             write_disability_to_log(l_disabled);
             per_fr_upgrade_data_pkg.write_log(sqlcode);
             per_fr_upgrade_data_pkg.write_log(sqlerrm);
             l_run_status := 2;   /* Fatal Error */
          END;  -- end of section inserting new disability

         /* Commit every record to ensure conc log corresponds to records in DB */
         commit;

      END IF;

    FETCH csr_disabled_entries INTO l_disabled;
  END LOOP;
  CLOSE csr_disabled_entries;

  return l_run_status;

exception when others then
   rollback;
   CLOSE csr_disabled_entries;
   per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74995_DIS_UPG_FATAL'
                                            ,p_token1 => 'STEP:50');
   per_fr_upgrade_data_pkg.write_log(sqlcode);
   per_fr_upgrade_data_pkg.write_log(sqlerrm);
   return 2;   /* Fatal Error */
END transfer_data;


/***********************************************************************
*  function RUN_UPGRADE                                                *
*  This fucntion must be called from                                   *
*      per_fr_upgrade_data_pkg.run_upgrade                             *
*  return = 0 for Status Normal                                        *
*  return = 1 for Status Warning                                       *
*  return = 2 for Status Error                                         *
***********************************************************************/
function run_upgrade(p_business_group_id number) return number
IS
   l_status number :=0;
   l_error_status number :=0;
   l_proc varchar2(72) := g_package||'.run_upgrade';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   l_status := per_fr_upgrade_data_pkg.check_lookups(p_fr_lookup_type => 'FR_COTOREP_CODE'
                          ,p_core_lookup_type => 'DISABILITY_CATEGORY');

   l_error_status := l_status;

   /* Lookups checked, Check for DF*/
   l_status := per_fr_upgrade_data_pkg.check_dfs(p_df => 'PER_DISABILITIES');
   if l_status > 0 then
	l_error_status := l_status;
   end if;

   if l_error_status = 0 then
      /* Lookups and DFs checked OK, upgrade data */
      l_status := transfer_data(p_business_group_id => p_business_group_id);
      RETURN l_status;
   else
      /* If check fails then fatal error */
      RETURN 2;
   end if;

/* Allow exceptions to be handled by calling unit do not trap here. */

end run_upgrade;


END PER_FR_DISABILITY_UPG_PKG;

/
