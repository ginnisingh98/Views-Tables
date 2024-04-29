--------------------------------------------------------
--  DDL for Package Body HR_APPLICANT_DATAUPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICANT_DATAUPD" as
/* $Header: hraplupd.pkb 120.1 2006/01/11 11:43 irgonzal noship $ */
-- Package variables
--
   g_RunUpdateMode_profile constant varchar2(30)  := 'HR_APL_UPD_RUN_MODE';
   g_ADPatchRunMode        constant varchar2(100) := 'P';
   g_CMRunMode             constant varchar2(100) := 'D';

   g_concProgramName       constant varchar2(30)  := 'HRAPLUPD1';
   g_updateName            constant varchar2(30)  := 'HRAPLUPD1';
   g_concPgrNameWrk        constant varchar2(30)  := 'HRAPLUPD1W';

   e_LockFailure           EXCEPTION;
   e_NoDataFound           EXCEPTION;
--
-- --------------------------------------------------------------------------+
-- --------------------< ConvertToApplicant >--------------------------------|
-- --------------------------------------------------------------------------+
-- Description:
-- This procedure converts person into applicant whenever if finds active
-- applicant assignments opened and the application has a termination date.
--
-- The following tables are updated:
--     + per_all_people_f
--     + per_person_type_usages_f
--     + per_applications
--
-- Scenario:
--
--  Application Records:
--                                            .
--  |--- APPL 1 ----|       |---- APPL 2 -----|
--                                            .
--  Assignment Records:                       .
--                                |----- ASG 1 -------> *** corrupted
--                                            .
--                                            ^application is already end dated
--
--  After running script person will become an Applicant
--
--  Application Records:
--
--  |--- APPL 1 ----|         |---- APPL 2 -------------> is opened
--
--  Assignment Records:
--                                  |----- ASG 1 ------->
--
--
PROCEDURE ConvertToApplicant(p_start_rowid     IN rowid
                            ,p_end_rowid       IN rowid
                            ,p_rows_processed OUT nocopy number
                            )
 IS
--
   l_datetrack_mode         varchar2(30);

   e_ResourceBusy      EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_ResourceBusy, -54);
--
   CURSOR csr_get_application_details(p_start_rowid rowid, p_end_rowid rowid) IS
    SELECT application_id, date_end, person_id, object_version_number
          ,date_received, business_group_id
      FROM per_applications appl
     WHERE appl.rowid between p_start_rowid and p_end_rowid
       AND date_end IS NOT NULL
       AND EXISTS
           (SELECT 'Y'
             FROM per_all_assignments_f paf
            WHERE paf.application_id = appl.application_id
              AND paf.assignment_type = 'A'
              AND paf.effective_end_date > appl.date_end)
     ORDER BY date_end DESC;
   --
   CURSOR csr_lock_person(cp_person_id number, cp_termination_date date) IS
     SELECT person_id, full_name, applicant_number,object_version_number
       FROM per_all_people_f
      WHERE person_id = cp_person_id
        AND (effective_start_date > cp_termination_date
             OR
             cp_termination_date between effective_start_date
                                     and effective_end_date)
      for update nowait;
   --
   CURSOR csr_lock_ptu(cp_person_id number, cp_termination_date date) IS
     SELECT null
       FROM per_person_type_usages_f ptu
           ,per_person_types         ppt
      WHERE person_id = cp_person_id
        AND (effective_start_date > cp_termination_date
             OR
             cp_termination_date between effective_start_date
                                     and effective_end_date)
        AND ptu.person_type_id = ppt.person_type_id
        AND ppt.system_person_type in ('APL','EX_APL')
      for update of ptu.person_type_id nowait; -- #4919613
   --
   CURSOR csr_get_ended_asg(p_application_id number, p_termination_date date) IS
     SELECT count(assignment_id)
      FROM per_all_assignments_f paf
     WHERE paf.application_id = p_application_id
       AND paf.assignment_type = 'A'
       AND paf.effective_end_date > p_termination_date
       AND paf.effective_end_date <> hr_general.end_of_time
       AND paf.effective_start_date =
           (select max(effective_start_date)  -- do not consider DT updates
              from per_all_assignments_f paf2
              where paf2.assignment_id = paf.assignment_id
                and paf2.effective_end_date > p_termination_date);
   --
   CURSOR csr_get_affected_asg(p_application_id number, p_termination_date date) IS
     SELECT count(assignment_id)
      FROM per_all_assignments_f paf
     WHERE paf.application_id = p_application_id
       AND paf.assignment_type = 'A'
       AND paf.effective_end_date > p_termination_date
       AND paf.effective_start_date =
           (select max(effective_start_date) -- do not consider DT updates
              from per_all_assignments_f paf2
              where paf2.assignment_id = paf.assignment_id
                and paf2.effective_end_date > p_termination_date);
   --
   --
   l_count              number;
   l_appl_rec           csr_get_application_details%ROWTYPE;
   l_failed_apl         per_applications.application_id%TYPE;
   l_person_rec         csr_lock_person%ROWTYPE;
   l_failed_person_id   per_all_people_f.person_id%TYPE;
   l_failed_full_name   per_all_people_f.full_name%TYPE;
   l_rowcount           number;
   l_rowcount_ended     number;
   l_continue_process   boolean;
   l_validation_start_date date;
   l_validation_end_date   date;
   l_per_object_version_number per_all_people_f.object_version_number%TYPE;
   l_proc                  constant varchar2(100) := 'ConvertToApplicant';
   --
   l_rows_processed        number;
--
BEGIN

   hr_utility.trace('Entering: '||l_proc);
   l_rowcount := 0;
   l_rows_processed := 0;
   l_failed_apl := null;
   l_failed_person_id := null;
   l_failed_full_name := null;
   l_continue_process := true;
   l_count := 1;
   --
   While l_continue_process LOOP
   --
     l_continue_process := false;
     for l_appl_rec in csr_get_application_details(p_start_rowid, p_end_rowid) loop
         --
       BEGIN
         --
         l_rows_processed := l_rows_processed + 1;
         l_failed_apl := l_appl_rec.application_id;
         l_failed_person_id := l_appl_rec.person_id;
         --
         -- ---------------------------------------------------------- +
         --                 Lock application record
         -- ---------------------------------------------------------- +
         hr_utility.trace('  10: locking application '||l_appl_rec.application_id);
         --
         begin
           per_apl_shd.lck
          (p_application_id           => l_appl_rec.application_id
           ,p_object_version_number    => l_appl_rec.object_version_number
           );
         exception
            when others then
               raise e_ResourceBusy;

         end;
         -- ------------------------------------------------------------ +
         --                   Lock person records
         -- ------------------------------------------------------------ +
         hr_utility.trace('  20: locking PER and PTU records');
         --
         open csr_lock_person(l_appl_rec.person_id, l_appl_rec.date_end);
         fetch csr_lock_person into l_person_rec;
         close csr_lock_person;
         -- ------------------------------------------------------------ +
         --                     lock the PTU records
         -- ------------------------------------------------------------ +
         open csr_lock_ptu(l_appl_rec.person_id, l_appl_rec.date_end);
         close csr_lock_ptu;
         -- ------------------------------------------------------------ +
         --            update Person and PTU records
         -- ------------------------------------------------------------ +
         hr_utility.trace('  30: update person and ptu records');
         --
         -- Fix for bug 4095315 starts here.
         --
         l_per_object_version_number := l_person_rec.object_version_number;
         --
         hr_applicant_internal.Update_PER_PTU_Records
            (p_business_group_id        => l_appl_rec.business_group_id
            ,p_person_id                => l_appl_rec.person_id
            ,p_effective_date           => l_appl_rec.date_received
            ,p_applicant_number         => l_person_rec.applicant_number
            ,p_APL_person_type_id       => null
            ,p_per_effective_start_date => l_validation_start_date
            ,p_per_effective_end_date   => l_validation_end_date
            ,p_per_object_version_number => l_per_object_version_number --bug 4095315
            );
         -- ---------------------------------------------------------- +
         --                 update the application
         -- ---------------------------------------------------------- +
         hr_utility.trace('  40: update application');
         --
         per_apl_upd.upd
             (p_application_id               => l_appl_rec.application_id
             ,p_object_version_number        => l_appl_rec.object_version_number
             ,p_effective_date               => l_appl_rec.date_received
             ,p_date_end                     => NULL
             ,p_termination_reason           => NULL
             );
          --
         exception
          --
          when TIMEOUT_ON_RESOURCE OR e_ResourceBusy then
            if RunUpdateMode = g_ADPatchRunMode then
              --
              IF l_count = 4 then
                l_continue_process := FALSE;
                raise e_LockFailure;
                l_count := 1;
              else
                l_continue_process := TRUE;
                l_count := l_count+1;
                --
              end if;
              --
            else
              --
              l_continue_process := FALSE;
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed to process application '||l_failed_apl||
                                            ' (person id = '||l_failed_person_id||')');
              raise e_LockFailure;
              --
            end if;
          --
          when others then
            raise;
        end;
   --
   end loop; -- applications found
   --
   -- l_count := 1;
   --
   end loop;  -- infinite while loop.
   --
   -- Settting OUT parameters
   --
   p_rows_processed := l_rows_processed;
   --
   -- Commit the changes.
   --
   commit;
   --
   hr_utility.trace(' Leaving: '||l_proc);
   --
EXCEPTION
   when TIMEOUT_ON_RESOURCE OR e_ResourceBusy then
      -- The required resources are used by some other process.
      if RunUpdateMode = g_ADPatchRunMode then
        --
        -- Fix for bug 4205784.comment out the following code.
        --
           --raise;
        hr_utility.trace('Failed to process application '||l_failed_apl||
                                            ' (person id = '||l_failed_person_id||')');

      else
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed to process application '||l_failed_apl||
                                            ' (person id = '||l_failed_person_id||')');
         raise e_LockFailure;

      end if;
    when OTHERS then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while processing application '||l_failed_apl||
                                            ' (person id = '||l_failed_person_id||')');
         raise;

END ConvertToApplicant;
--
-- --------------------------------------------------------------------------+
-- -----------------< Update_APL_using_LTU >---------------------------------|
-- --------------------------------------------------------------------------+
--
PROCEDURE Update_APL_using_LTU
   (errbuf              OUT nocopy varchar2
   ,retcode             OUT nocopy number
   ,p_this_worker       IN number
   ,p_total_workers     IN number
   ,p_table_owner       IN varchar2
   ,p_table_name        IN varchar2
   ,p_update_name       IN varchar2
   ,p_batchsize         IN number)
IS

  l_any_rows_to_process boolean;
  l_start_rowid     rowid;
  l_end_rowid       rowid;
  l_rows_processed  number;
  --
BEGIN
   --
   ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           p_table_owner,
           p_table_name,
           p_update_name,
           p_this_worker,
           p_total_workers,
           p_batchsize, 0);

   ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batchsize,
           TRUE);
   --
   while (l_any_rows_to_process = TRUE)
   loop
      hr_applicant_dataupd.ConvertToApplicant(l_start_rowid, l_end_rowid, l_rows_processed);

      ad_parallel_updates_pkg.processed_rowid_range(
          l_rows_processed,
          l_end_rowid);
      --
      -- commit transaction here
      --
      commit;
      --
      -- get new range of rowids
      --
      ad_parallel_updates_pkg.get_rowid_range(
         l_start_rowid,
         l_end_rowid,
         l_any_rows_to_process,
         p_batchsize,
         FALSE);

   end loop;
   --
END Update_APL_using_LTU;
--
-- --------------------------------------------------------------------------+
--                        Update_APL_inCM_Manager
-- --------------------------------------------------------------------------+
-- This is run as a concurrent program
--
PROCEDURE Update_APL_inCM_Manager
   (p_errbuf        out nocopy varchar2
   ,p_retcode       out nocopy varchar2
   ,X_batch_size    in  number
   ,X_Num_Workers   in  number
   ,p_process_All   in  varchar2
   ,p_caller        in  varchar2 -- MB:  Move parameter up so it occurs before
                                 -- optional parameters.
   ,p_apl_id        in  number default 0
   --,p_caller        in  varchar2
   ) IS
--
   cursor csr_get_apl_rowid(cp_apl_id number) is
      select rowid
        from per_applications
       where application_id = cp_apl_id;

   l_apl_rowid   rowid;
--
   l_product     varchar2(30);
   l_table_name  varchar2(30);
   l_status      varchar2(30);
   l_industry    varchar2(30);
   l_retstatus   boolean;
   l_table_owner varchar2(30);
   l_update_name varchar2(30);
   l_any_rows_to_process  boolean;
   l_start_rowid          rowid;
   l_rows_processed       number;
   req_data               varchar2(240);
BEGIN
   --
   l_product     := 'PER';
   l_table_name  := 'PER_APPLICATIONS';
   l_update_name := g_updateName;    -- this matches name used in ADPATCH script
   --
   -- get schema name of the table for ROWID range processing
   --
   l_retstatus := fnd_installation.get_app_info(
                          l_product, l_status, l_industry, l_table_owner);
   IF ((l_retstatus = FALSE)
   OR (l_table_owner is null)) THEN
      raise_application_error(-20001, 'Cannot get schema name for product : '||l_product);
   END IF;
   fnd_file.put_line(FND_FILE.LOG, 'X_Num_Workers : '||X_Num_Workers);
   fnd_file.put_line(FND_FILE.LOG, '   UpdateName : '||l_update_name);
   fnd_file.put_line(FND_FILE.LOG, '     p_caller : '||p_caller);
   --
   IF p_process_ALL = 'Y' THEN
   --
      --
      -- Manager processing
      --
         req_data := fnd_conc_global.request_data; --
         if req_data is not null then
            --
            -- indicate that the named update process has started processing
            --
            hr_update_utility.setUpdateProcessing(p_update_name => l_update_name);
            --
            -- set status of complete in the PAY_UPGRADE_STATUS table
            --
            hr_update_utility.setUpdateComplete(p_update_name => l_update_name);
            --
         else
            /* We are not on a restart therefore if we are running from
            ** a manual submission delete the PAY_UPGRADE_STATUS record.
            */
            if p_caller = 'F' then
               delete from pay_upgrade_status
                     where upgrade_definition_id =
                            (select upgrade_definition_id
                               from pay_upgrade_definitions
                              where short_name = l_update_name);
               fnd_file.put_line(FND_FILE.LOG,' ** Upgrade Status row deleted successfully **');

               -- If we are called from a manual submission then we need to run the
               -- data update even if it has run before.  Therefore the LTU update
               -- name needs to be a new previously unused value so concat the
               --  current date and time.
               --
               l_update_name := l_update_name||'_'||to_char(sysdate,'DDMMRRHH24MISS');
            end if;
         end if;
         AD_CONC_UTILS_PKG.submit_subrequests(
                       X_errbuf                     => p_errbuf,
                       X_retcode                    => p_retcode,
                       X_WorkerConc_app_shortname   => l_product,
                       X_WorkerConc_progname        => g_concPgrNameWrk, -- worker SRS
                       X_batch_size                 => X_batch_size,
                       X_Num_Workers                => X_Num_Workers,
                       X_Argument4                  => p_process_ALL,
                       X_Argument5                  => p_caller,
                       X_Argument6                  => l_update_name,
                       X_Argument7                  => p_apl_id
                       );

   ELSE
   --
   -- process ONE application: no need to invoke the LTU mechanism
   --
      BEGIN
         open csr_get_apl_rowid(p_apl_id);
         fetch csr_get_apl_rowid into l_apl_rowid;
         if csr_get_apl_rowid%NOTFOUND then
            close csr_get_apl_rowid;
            fnd_file.put_line(FND_FILE.LOG, '**************');
            fnd_file.put_line(FND_FILE.LOG, 'Application ID: '||p_apl_id||' not found.');
            raise e_NoDataFound;
         else
            close csr_get_apl_rowid;
            hr_applicant_dataupd.ConvertToApplicant(l_apl_rowid, l_apl_rowid, l_rows_processed);
         end if;
         --
         p_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
      EXCEPTION
         WHEN e_LockFailure THEN
          p_retcode := AD_CONC_UTILS_PKG.CONC_WARNING;
         WHEN OTHERS THEN
          p_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
          raise;
      END;

   END IF;
   --
END Update_APL_inCM_Manager;

--
-- --------------------------------------------------------------------------+
--                        Update_APL_inCM_Worker
-- --------------------------------------------------------------------------+
-- This is run as a concurrent program
--
PROCEDURE Update_APL_inCM_Worker
   (p_errbuf        out nocopy varchar2
   ,p_retcode       out nocopy varchar2
   ,X_batch_size    in  number
   ,X_Worker_Id     in  number
   ,X_Num_Workers   in  number
   ,p_process_All   in  varchar2
   ,p_caller        in  varchar2 -- Move parameter up so it occurs before
                                 -- optional parameters.
   ,p_updateName    in varchar2
   ,p_apl_id        in  number default 0
   --,p_caller        in  varchar2
   ) IS
--
   cursor csr_get_apl_rowid(cp_apl_id number) is
      select rowid
        from per_applications
       where application_id = cp_apl_id;

   l_apl_rowid   rowid;
--
   l_product     varchar2(30);
   l_table_name  varchar2(30);
   l_status      varchar2(30);
   l_industry    varchar2(30);
   l_retstatus   boolean;
   l_table_owner varchar2(30);
   l_any_rows_to_process  boolean;
   l_start_rowid          rowid;
   l_rows_processed       number;
   req_data               varchar2(240);
BEGIN
   --
   l_product     := 'PER';
   l_table_name  := 'PER_APPLICATIONS';
   --
   -- get schema name of the table for ROWID range processing
   --
   l_retstatus := fnd_installation.get_app_info(
                          l_product, l_status, l_industry, l_table_owner);
   IF ((l_retstatus = FALSE)
   OR (l_table_owner is null)) THEN
      raise_application_error(-20001, 'Cannot get schema name for product : '||l_product);
   END IF;
   fnd_file.put_line(FND_FILE.LOG, '  X_Worker_Id : '||X_Worker_Id);
   fnd_file.put_line(FND_FILE.LOG, 'X_Num_Workers : '||X_Num_Workers);
   fnd_file.put_line(FND_FILE.LOG, '   updateName : '||p_updateName);
      --
      -- Worker processing
      --
         BEGIN
            hr_applicant_dataupd.Update_APL_using_LTU
               (errbuf              => p_errbuf
               ,retcode             => p_retcode
               ,p_this_worker       => X_worker_id
               ,p_total_workers     => X_num_workers
               ,p_table_owner       => l_table_owner
               ,p_table_name        => l_table_name
               ,p_update_name       => p_updateName
               ,p_batchsize         => X_batch_size);
            --
            p_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
         EXCEPTION
            WHEN e_LockFailure THEN
             p_retcode := AD_CONC_UTILS_PKG.CONC_WARNING;
            WHEN OTHERS THEN
             p_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
             raise;
         END;
   --
END Update_APL_inCM_Worker;
--
-- --------------------------------------------------------------------------+
--                           ValidateRun
-- --------------------------------------------------------------------------+
--
PROCEDURE ValidateRun(p_result OUT nocopy varchar2) IS
  l_result varchar2(10);
BEGIN
   l_result := hr_update_utility.isUpdateComplete
      (p_app_shortname      => g_concProgramName
      ,p_function_name      => null
      ,p_business_group_id  => null
      ,p_update_name        => g_updateName);
   --
   if l_result = 'FALSE' then
      p_result := 'TRUE';
   else
     p_result := 'FALSE';
   end if;
   --
END ValidateRun;
--
-- --------------------------------------------------------------------------+
--                      RunUpdateMode
-- --------------------------------------------------------------------------+
-- Returns the value of the profile option:
--    + P: run within adpatch
--    + D: run when concurrent program is re-started (deferred process)
--
-- If profile value is not set, then returns 'ADPATCH'
--
FUNCTION RunUpdateMode RETURN varchar2 IS
--
   l_value varchar2(100);
   l_defined boolean;

BEGIN
   --
   l_value := FND_PROFILE.value(g_RunUpdateMode_profile);
   if l_value is NULL then
      return(g_ADPatchRunMode);
   else
      return(l_value);
   end if;
   --
END RunUpdateMode;
--
-- --------------------------------------------------------------------------+
--                     isADPATCHMode
-- --------------------------------------------------------------------------+
FUNCTION isADPATCHMode return boolean IS
BEGIN
   return(RunUpdateMode = g_ADPatchRunMode);
END isADPATCHMode;
--
-- --------------------------------------------------------------------------+
--                     isDEFERMode
-- --------------------------------------------------------------------------+
FUNCTION isDEFERMode return boolean IS
BEGIN
    return(RunUpdateMode = g_CMRunMode);
END isDEFERMode;
--
end hr_applicant_dataupd;

/
