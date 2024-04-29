--------------------------------------------------------
--  DDL for Package Body PER_FR_TERMINATION_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_TERMINATION_UPG_PKG" AS
/* $Header: pefrtmup.pkb 115.2 2002/09/27 15:24:44 jrhodes noship $ */

  CURSOR csr_pds(p_business_group_id number)
  IS
    SELECT pds.PERIOD_OF_SERVICE_ID,
           pds.pds_information2,
           l.lookup_code,
           p.employee_number,
           p.full_name,
           pds.date_start
    FROM   per_periods_of_service pds
    ,      per_all_people_f p
    ,      hr_lookups l
    WHERE  pds.business_group_id = p_business_group_id
    AND    pds.pds_information2 is not null
    AND    pds.leaving_reason is null
    and    l.lookup_type(+) = 'LEAV_REAS'
    and    l.lookup_code(+) = pds.pds_information2
    and    pds.person_id = p.person_id
    AND    pds.date_start between
           p.effective_start_date and p.effective_end_date
    order by p.full_name,pds.date_start;

g_package varchar2(30) := 'per_fr_termination_upg_pkg';

/********************************************************************************
*  Procedure that writes out the termination information to the log        *
*  this allows users to mannually enter this information where it could not be  *
*  created by the process                                                       *
********************************************************************************/
procedure write_pds_to_log(p_pds in csr_pds%ROWTYPE)
IS
BEGIN
   per_fr_upgrade_data_pkg.write_log(p_pds.employee_number);
   per_fr_upgrade_data_pkg.write_log(p_pds.full_name);
   per_fr_upgrade_data_pkg.write_log(p_pds.pds_information2);
END write_pds_to_log;

/***********************************************************************
*  function TRANSFER_DATA                                              *
*  This fucntion must be called from run_upgrade                       *
*  Return = 0 means upgrade completed OK.                              *
*  Return = 1 means warnings                                           *
*  Return = 2 means upgrade failed                                     *
***********************************************************************/
function transfer_data(p_business_group_id IN NUMBER) return number
IS
  l_pds     	                csr_pds%ROWTYPE;
  l_run_status                  number :=0;            /* Status of the whole run */
  l_record_status               number;
  l_proc varchar2(72) := g_package||'.transfer_data';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

  OPEN csr_pds(p_business_group_id);
  FETCH csr_pds INTO l_pds;

  WHILE csr_pds%FOUND LOOP

     l_record_status :=0;

     if l_pds.lookup_code is null then
        per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_75010_MISSING_LEAVING_REAS');
        l_record_status := 1;
     end if;

      If l_record_status = 1 THEN
         -- We could not create the record because the dates were invalid.
         -- Write out termination information to log for mannual user entry.
         write_pds_to_log(l_pds);
         if l_run_status = 0 THEN   /* only change status if not 1 or 2 already */
            l_run_status := 1;  -- Set status of run to warning.
         end if;
     else

          BEGIN -- Update termination record
          hr_utility.set_location(l_proc,10);
          hr_utility.trace(l_pds.period_of_service_id);

             SAVEPOINT start_insert;

             update per_periods_of_service
             set leaving_reason = pds_information2
             ,   pds_information2 = null
             where period_of_service_id = l_pds.period_of_service_id;

          exception when others then
             rollback to start_insert;
             per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_75011_TERM_UPG_FATAL'
                                            ,p_token1 => 'STEP:10');
             write_pds_to_log(l_pds);
             per_fr_upgrade_data_pkg.write_log(sqlcode);
             per_fr_upgrade_data_pkg.write_log(sqlerrm);
             l_run_status := 2;   /* Fatal Error */
          END;  -- end of section updating termination

         /* Commit every record to ensure conc log corresponds to records in DB */
         commit;

      END IF;

    FETCH csr_pds INTO l_pds;
  END LOOP;
  CLOSE csr_pds;

  return l_run_status;

exception when others then
   rollback;
   CLOSE csr_pds;
   per_fr_upgrade_data_pkg.write_log_message(p_message_name => 'PER_75011_TERM_UPG_FATAL'
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
   l_status := transfer_data(p_business_group_id => p_business_group_id);
   return l_status;
/* Allow exceptions to be handled by calling unit do not trap here. */
end run_upgrade;


END PER_FR_TERMINATION_UPG_PKG;

/
