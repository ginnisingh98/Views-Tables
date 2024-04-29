--------------------------------------------------------
--  DDL for Package Body PER_FR_MEDICAL_EXAMS_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_MEDICAL_EXAMS_UPG_PKG" AS
/* $Header: pefrmeup.pkb 115.1 2002/07/03 06:47:56 pvaish noship $ */

  CURSOR csr_medic_exam(p_business_group_id number)
  IS
   SELECT pei.PERSON_ID,
          per1.full_name,
          per1.employee_number,
          per1.effective_start_date,
          pei.PEI_INFORMATION1,
          pei.PEI_INFORMATION2,
          pei.PEI_INFORMATION3,
          pei.PEI_INFORMATION4,
          pei.PEI_INFORMATION5,
          pei.PEI_INFORMATION6,
          pei.PEI_INFORMATION7,
          pei.PEI_INFORMATION8,
          pei.PERSON_EXTRA_INFO_ID
   FROM   per_people_extra_info pei
      ,   per_all_people_f per1
   WHERE  pei.PEI_INFORMATION_CATEGORY = 'FR_MEDIC_EXAM'
    AND    pei.person_id = per1.person_id
    AND    per1.business_group_id = p_business_group_id
    AND    per1.effective_start_date = (select min(per2.effective_start_date)
                                         from per_all_people_f per2
                                        where per2.person_id = per1.person_id
                                          and per2.business_group_id = p_business_group_id)
    AND   pei.PEI_INFORMATION30 IS NULL
    order by per1.full_name;


g_package varchar2(30) := 'per_fr_medical_exams_upg_pkg';


/********************************************************************************
*  Procedure that writes out the whole medical examination information to the   *
*  log this allows users to mannual enter this information where it could not be*
*  created by the process                                                       *
********************************************************************************/
procedure write_medical_exam_to_log(p_medical_exam in csr_medic_exam%ROWTYPE)
IS
BEGIN
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.employee_number);
/* added script to print all medical assessment information to log*/
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.full_name);
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.PEI_INFORMATION1);
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.PEI_INFORMATION2);
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.PEI_INFORMATION3);
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.PEI_INFORMATION4);
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.PEI_INFORMATION5);
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.PEI_INFORMATION6);
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.PEI_INFORMATION7);
   per_fr_upgrade_data_pkg.write_log(p_medical_exam.PEI_INFORMATION8);

END write_medical_exam_to_log;

/***********************************************************************
*  function TRANSFER_DATA                                              *
*  This fucntion must be called from run_upgrade                       *
*  Return = 0 means upgrade completed OK.                              *
*  Return = 1 means warnings                                           *
*  Return = 2 means upgrade failed                                     *
***********************************************************************/
function transfer_data(p_business_group_id IN NUMBER) return number
IS

  l_medical_exam                   csr_medic_exam%ROWTYPE;
  l_consultation_date              date;
  l_next_consultation_date         date;
  l_consultation_type              varchar2(30);
  l_medical_assessment_id          number;
  l_ovn                            number;
  l_proc varchar2(72) := g_package||'.transfer_data';
  l_run_status                  number :=0;            /* Status of the whole run */

BEGIN

  hr_utility.set_location('Entered '||l_proc,5);

  OPEN csr_medic_exam(p_business_group_id);
  FETCH csr_medic_exam INTO l_medical_exam;

  WHILE csr_medic_exam%FOUND LOOP

        if l_medical_exam.PEI_INFORMATION1 is NULL then
           per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74996_MED_DATE_DFLT',
                                                     p_token1 => 'EMPLOYEE:'|| l_medical_exam.employee_number);
           l_consultation_date :=to_date('01010001','DDMMYYYY');
           if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
              l_run_status := 1;  -- Set status of run to warning.
           end if;
        else
           l_consultation_date :=fnd_date.canonical_to_date(l_medical_exam.PEI_INFORMATION1);
        end if;


        l_next_consultation_date := fnd_date.canonical_to_date(l_medical_exam.PEI_INFORMATION8);

        if l_next_consultation_date <= l_consultation_date then
           -- Next consultation date must be after consultation date.  Other set to NULL.
           per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74997_MED_NDATE_DFLT',
                                                     p_token1 => 'EMPLOYEE:'|| l_medical_exam.employee_number);
           l_next_consultation_date := NULL;
           if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
              l_run_status := 1;  -- Set status of run to warning.
           end if;
        END IF;

        if l_medical_exam.PEI_INFORMATION2 IS NULL then
           l_consultation_type := 'UNKNOWN';
           per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74998_MED_TYPE_DFLT',
                                                     p_token1 => 'EMPLOYEE:'|| l_medical_exam.employee_number);
           if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
              l_run_status := 1;  -- Set status of run to warning.
           end if;
        else
           l_consultation_type := l_medical_exam.PEI_INFORMATION2;
        end if;

        BEGIN -- Insert new medical examinations section

          SAVEPOINT start_insert;

          per_medical_assessment_api.create_medical_assessment
             (p_effective_date            => l_medical_exam.effective_start_date
             ,p_person_id                 => l_medical_exam.person_id
             ,p_consultation_date         => l_consultation_date
             ,p_consultation_type         => l_consultation_type
             ,p_examiner_name             => l_medical_exam.PEI_INFORMATION7
             ,p_consultation_result       => l_medical_exam.PEI_INFORMATION5
             ,p_next_consultation_date    => l_next_consultation_date
             ,p_description               => l_medical_exam.PEI_INFORMATION6
             ,p_mea_information_category  => 'FR'
             ,p_mea_information1          => l_medical_exam.PEI_INFORMATION3
             ,p_mea_information2          => l_medical_exam.PEI_INFORMATION4
             ,p_medical_assessment_id     => l_medical_assessment_id
             ,p_object_version_number     => l_ovn);

          update per_people_extra_info
                set PEI_INFORMATION30 = to_char(l_medical_assessment_id)
              where person_id = l_medical_exam.person_id
                and PEI_INFORMATION_CATEGORY = 'FR_MEDIC_EXAM'
                and PERSON_EXTRA_INFO_ID = l_medical_exam.PERSON_EXTRA_INFO_ID;

          exception when others then
             rollback to start_insert;
             per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74999_MED_UPG_FATAL'
                                                      ,p_token1 => 'TOKEN1:10');
             write_medical_exam_to_log(l_medical_exam);
             per_fr_upgrade_data_pkg.write_log(sqlcode);
             per_fr_upgrade_data_pkg.write_log(sqlerrm);
             l_run_status := 2;   /* Fatal Error */
          END;  -- end of section inserting new medical exam


         /* Commit every record to ensure conc log corresponds to records in DB */
         commit;

    FETCH csr_medic_exam INTO l_medical_exam;
  END LOOP;
  CLOSE csr_medic_exam;

  return l_run_status;

exception when others then
   rollback;
   CLOSE csr_medic_exam;
   per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_74999_MED_UPG_FATAL'
                                            ,p_token1 => 'TOKEN1:50');
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
begin
   l_status := per_fr_upgrade_data_pkg.check_lookups(p_fr_lookup_type => 'FR_MEDICAL_EXAMINATION_TYPE'
                          ,p_core_lookup_type => 'CONSULTATION_TYPE');

   l_error_status := l_status;

   l_status := per_fr_upgrade_data_pkg.check_lookups(p_fr_lookup_type => 'FR_MEDICAL_RESULT'
                          ,p_core_lookup_type => 'CONSULTATION_RESULT');

   if l_status > 0 then
        l_error_status := l_status;
   end if;

  /* Lookups checked, Check for DF*/
  l_status := per_fr_upgrade_data_pkg.check_dfs(p_df => 'PER_MEDICAL_ASSESSMENTS');

   if l_status > 0 then
        l_error_status := l_status;
   end if;

  if l_error_status = 0 then
     /* Lookups and DFs checked OK, upgrade data */
     l_status := transfer_data(p_business_group_id => p_business_group_id);
     RETURN l_status;
  else
     /* If DF check fails then fatal error */
     RETURN 2;
  end if;

/* Allow exceptions to be handled by calling unit do not trap here. */

end run_upgrade;


END PER_FR_MEDICAL_EXAMS_UPG_PKG;

/
