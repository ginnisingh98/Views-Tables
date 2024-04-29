--------------------------------------------------------
--  DDL for Package Body PER_FR_WORK_ACC_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_WORK_ACC_UPG_PKG" AS
/* $Header: pefrwaup.pkb 115.1 2002/07/03 06:46:24 pvaish noship $ */

  CURSOR csr_work_accidents(p_business_group_id number)
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
          pei.PEI_INFORMATION9,
          pei.PERSON_EXTRA_INFO_ID
   FROM   per_people_extra_info pei
      ,   per_all_people_f per1
   WHERE  pei.PEI_INFORMATION_CATEGORY = 'FR_WORK_ACCI'
    AND    pei.person_id = per1.person_id
    AND    per1.business_group_id = p_business_group_id
    AND    per1.effective_start_date = (select min(per2.effective_start_date)
                                         from per_all_people_f per2
                                        where per2.person_id = per1.person_id
                                          and per2.business_group_id = p_business_group_id)
    AND   pei.PEI_INFORMATION30 IS NULL
    order by per1.full_name;


g_package varchar2(30) := 'per_fr_work_acc_upg_pkg';


/********************************************************************************
*  Procedure that writes out the whole work incidents information to the   *
*  log this allows users to mannual enter this information where it could not be*
*  created by the process                                                       *
********************************************************************************/
procedure write_work_accident_to_log(p_work_acci in csr_work_accidents%ROWTYPE)
IS
BEGIN
   per_fr_upgrade_data_pkg.write_log(p_work_acci.employee_number);
/* added script to print all work incidents information to log*/
   per_fr_upgrade_data_pkg.write_log(p_work_acci.full_name);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION1);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION2);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION3);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION4);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION5);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION6);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION7);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION8);
   per_fr_upgrade_data_pkg.write_log(p_work_acci.PEI_INFORMATION9);

END write_work_accident_to_log;

/***********************************************************************
*  function TRANSFER_DATA                                              *
*  This fucntion must be called from run_upgrade                       *
*  RETURN = 0 means upgrade completed OK.                              *
*  RETURN = 1 means warnings                                           *
*  RETURN = 2 means upgrade failed                                     *
***********************************************************************/
function transfer_data(p_business_group_id IN NUMBER) RETURN number
IS

  l_work_acci                      csr_work_accidents%ROWTYPE;
  l_incident_id                    number;
  l_incident_date                  date;
  l_incident_type                  varchar2(30);
  l_org_notified_date              date;
  l_body_part                      varchar2(30);
  l_ovn			           number;
  l_activity                       varchar2(30);
  l_absence_exists_flag            varchar2(30);
  l_proc			   varchar2(72) := g_package||'.transfer_data';
  l_run_status                     number :=0;     /* Status of the whole run */

BEGIN

  hr_utility.set_location('Entered '||l_proc,5);

  OPEN csr_work_accidents(p_business_group_id);
  FETCH csr_work_accidents INTO l_work_acci;

  WHILE csr_work_accidents%FOUND LOOP

	if l_work_acci.PEI_INFORMATION1 is NULL then
           per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_75000_WA_ACTIVITY_DFLT',
                                                     p_token1 => 'EMPLOYEE:'|| l_work_acci.full_name);
           l_activity := 'W';
           if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
              l_run_status := 1;  -- Set status of run to warning.
           end if;
        else
           l_activity :=l_work_acci.PEI_INFORMATION1;
        end if;

        if l_work_acci.PEI_INFORMATION3 is NULL then
           l_incident_date :=to_date('01010001','DDMMYYYY');

           per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_75001_WA_INCI_DATE_DFLT',
                                                     p_token1 => 'EMPLOYEE:'|| l_work_acci.full_name);

	   if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
              l_run_status := 1;  -- Set status of run to warning.
           end if;
        else
           l_incident_date :=fnd_date.canonical_to_date(l_work_acci.PEI_INFORMATION3);
        end if;

	if l_work_acci.PEI_INFORMATION4 is NOT NULL then
           l_body_part := l_work_acci.PEI_INFORMATION4||'%';
        else
           l_body_part :=NULL;
        end if;

	if l_work_acci.PEI_INFORMATION7 IS NULL then
           l_incident_type := 'UNKNOWN';
           per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_75002_WA_INCI_TYPE_DFLT',
                                                     p_token1 => 'EMPLOYEE:'|| l_work_acci.full_name);
           if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
              l_run_status := 1;  -- Set status of run to warning.
           end if;
        else
           l_incident_type := l_work_acci.PEI_INFORMATION7;
        end if;

	if l_work_acci.PEI_INFORMATION8 = 'Y' then
           l_org_notified_date := l_incident_date;
        else
           l_org_notified_date := NULL;
        end if;

	if l_work_acci.PEI_INFORMATION9 = 'Y' then
           l_absence_exists_flag := 'Y';
        else
           l_absence_exists_flag := 'N';
        end if;

	BEGIN -- Insert newwork inccidents section

          SAVEPOINT start_insert;

          per_work_incident_api.create_work_incident
             (p_effective_date            => l_work_acci.effective_start_date
	     ,p_person_id                 => l_work_acci.person_id
	     ,p_incident_reference        => 'FR' || TO_CHAR(l_work_acci.PERSON_EXTRA_INFO_ID)
             ,p_at_work_flag		  => l_activity
	     ,p_hazard_type		  => l_work_acci.PEI_INFORMATION2
	     ,p_incident_date		  => l_incident_date
	     ,p_body_part		  => l_body_part
	     ,p_description		  => l_work_acci.PEI_INFORMATION5
	     ,p_disease_type		  => l_work_acci.PEI_INFORMATION6
	     ,p_incident_type		  => l_incident_type
	     ,p_org_notified_date	  => l_org_notified_date
	     ,p_absence_exists_flag	  => l_absence_exists_flag
             ,p_incident_id	          => l_incident_id
             ,p_object_version_number     => l_ovn);

             update per_people_extra_info
                set PEI_INFORMATION30 = to_char(l_incident_id)
              where person_id = l_work_acci.person_id
                and PEI_INFORMATION_CATEGORY = 'FR_WORK_ACCI'
                and PERSON_EXTRA_INFO_ID = l_work_Acci.PERSON_EXTRA_INFO_ID;

          exception when others then
             rollback to start_insert;
             per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_75003_WA_UPG_FATAL'
                                                      ,p_token1 => 'TOKEN1:10');
             write_work_accident_to_log(l_work_acci);
             per_fr_upgrade_data_pkg.write_log(sqlcode);
             per_fr_upgrade_data_pkg.write_log(sqlerrm);
             l_run_status := 2;   /* Fatal Error */
          END;  -- end of section inserting new work inccident

	 /* Commit every record to ensure conc log corresponds to records in DB */
         COMMIT;

    FETCH csr_work_accidents INTO l_work_acci;
  END LOOP;
  CLOSE csr_work_accidents;

  RETURN l_run_status;

exception when others then
   ROLLBACK;
   CLOSE csr_work_accidents;
   per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_75003_WA_UPG_FATAL'
                                            ,p_token1 => 'STEP:50');
   per_fr_upgrade_data_pkg.write_log(sqlcode);
   per_fr_upgrade_data_pkg.write_log(sqlerrm);
   RETURN 2;   /* Fatal Error */
END transfer_data;


/***********************************************************************
*  function RUN_UPGRADE                                                *
*  This fucntion must be called from                                   *
*      per_fr_upgrade_data_pkg.run_upgrade                             *
*  RETURN = 0 for Status Normal                                        *
*  RETURN = 1 for Status Warning                                       *
*  RETURN = 2 for Status Error                                         *
***********************************************************************/
function run_upgrade(p_business_group_id number) RETURN number
IS
   l_status number :=0;
   l_error_status number :=0;
   l_proc   varchar2(72) := g_package||'.run_upgrade';
begin
   hr_utility.set_location('Entered ' || l_proc,5);
   l_status := per_fr_upgrade_data_pkg.check_lookups(p_fr_lookup_type => 'FR_WORK_ACCIDENT_RESULT'
                          ,p_core_lookup_type => 'INCIDENT_TYPE');

   l_error_status := l_status;

   l_status := per_fr_upgrade_data_pkg.check_lookups(p_fr_lookup_type => 'FR_WORK_ACCIDENT_TYPE'
                          ,p_core_lookup_type => 'AT_WORK_FLAG');

   if l_status > 0 then
        l_error_status := l_status;
   end if;

   l_status := per_fr_upgrade_data_pkg.check_lookups(p_fr_lookup_type => 'FR_ILLNESS_TYPE'
                          ,p_core_lookup_type => 'DISEASE_TYPE');

   if l_status > 0 then
        l_error_status := l_status;
   end if;

   l_status := per_fr_upgrade_data_pkg.check_lookups(p_fr_lookup_type => 'FR_WORK_ACCIDENT_CODE'
                          ,p_core_lookup_type => 'HAZARD_TYPE');

   if l_status > 0 then
        l_error_status := l_status;
   end if;

   /* Lookups checked, Check for DF*/
   l_status := per_fr_upgrade_data_pkg.check_dfs(p_df => 'PER_WORK_INCIDENTS');

   if l_status > 0 then
        l_error_status := l_status;
   end if;

   if l_error_status = 0 then
      /* DFs checked OK, upgrade data */
      l_status := transfer_data(p_business_group_id => p_business_group_id);
      RETURN l_status;
   else
      /* If DF check fails then fatal error */
      RETURN 2;
   end if;

/* Allow exceptions to be handled by calling unit do not trap here. */

end run_upgrade;

END PER_FR_WORK_ACC_UPG_PKG;

/
