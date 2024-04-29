--------------------------------------------------------
--  DDL for Package Body HR_DM_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_DELETE" AS
/* $Header: perdmdel.pkb 120.1 2005/06/15 02:09:35 nhunur noship $ */



/*---------------------------- PUBLIC ROUTINES ----------------------------*/

-- ------------------------- set_active ------------------------
-- Description: The next group to be deleted is selected by finding the
-- first unprocessed group on the locking ladder and updating the table
-- hr_dm_migrations with its group id.
--
--
--  Input Parameters
--        p_migration_id - current migration
--
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE set_active(p_migration_id IN NUMBER) IS
--

l_active_group NUMBER;
l_delete_phase_id NUMBER;
l_range_phase_id NUMBER;


CURSOR csr_get_active IS
  SELECT group_id
    FROM hr_dm_application_groups
    WHERE (migration_type = 'D')
      AND (group_order IN (
      SELECT MAX(apg.group_order)
        FROM hr_dm_phase_items pi_dn,
             hr_dm_tables tbl,
             hr_dm_migration_ranges mr,
             hr_dm_phase_items pi_rg,
             hr_dm_table_groupings tgp,
             hr_dm_application_groups apg
        WHERE pi_rg.phase_id = l_range_phase_id
          AND pi_rg.phase_item_id = mr.phase_item_id
          AND pi_rg.table_name = tbl.table_name
          AND pi_dn.phase_id = l_delete_phase_id
          AND pi_dn.group_id = pi_rg.group_id
          AND tbl.table_id = tgp.table_id
          AND tgp.group_id = apg.group_id
          AND apg.migration_type = 'D'
          AND mr.status = 'NS')
       );



--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_delete.set_active', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id || ')',
                      10);


-- get the delete phase_id
l_delete_phase_id := hr_dm_utility.get_phase_id('D', p_migration_id);

-- get the range phase_id
l_range_phase_id := hr_dm_utility.get_phase_id('R', p_migration_id);



-- get group id of next (or first) group to be processed
OPEN csr_get_active;
FETCH csr_get_active INTO l_active_group;
CLOSE csr_get_active;

-- update hr_dm_migrations with active group
UPDATE hr_dm_migrations
  SET active_group = l_active_group
  WHERE migration_id = p_migration_id;

COMMIT;



hr_dm_utility.message('INFO','Currently Active group set', 15);
hr_dm_utility.message('SUMM','Currently Active group set', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_delete.set_active', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_delete.set_active',
                      'Error setting currently active group','D');
  RAISE;

--
END set_active;
--


-- ------------------------- del_fnd_info ------------------------
-- Description: For the business group being deleted, the following
-- items are removed via FND APIs:
--
-- * Local lookups
-- * FND_SECURITY_GROUPS
-- * FND_USER_RESP_GROUPS
--
--  Input Parameters
--        p_business_group_id - business_group_id to delete
--
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE del_fnd_info(p_business_group_id IN NUMBER) IS
--

l_security_group_id NUMBER;
l_lookup_type VARCHAR2(30);
l_lookup_code VARCHAR2(30);
l_view_application_id NUMBER(15);
l_username VARCHAR2(100);
l_resp_app VARCHAR2(50);
l_resp_key VARCHAR2(30);
l_security_group VARCHAR2(30);

CURSOR csr_sec_grp IS
  SELECT security_group_id
  FROM per_business_groups
  WHERE business_group_id = p_business_group_id;

CURSOR csr_lu_type IS
  SELECT lookup_type,
         view_application_id
  FROM fnd_lookup_types
  WHERE security_group_id = l_security_group_id;

CURSOR csr_lu_code IS
  SELECT DISTINCT lookup_code
  FROM FND_LOOKUP_VALUES
  WHERE security_group_id = l_security_group_id
    AND lookup_type = l_lookup_type
    AND view_application_id = l_view_application_id;

CURSOR csr_usrresgrp IS
  SELECT u.user_name                  username,
         a.application_short_name     resp_app,
         r.responsibility_key         resp_key,
         s.security_group_key         security_group
  FROM fnd_user_resp_groups rg,
       fnd_user u,
       fnd_application a,
       fnd_responsibility r,
       fnd_security_groups s
  WHERE rg.user_id = u.user_id
    AND rg.responsibility_application_id = a.application_id
    AND rg.responsibility_id = r.responsibility_id
    AND rg.security_group_id = s.security_group_id
    AND rg.security_group_id = l_security_group_id;

--
BEGIN
--

hr_utility.set_trace_options('TRACE_DEST:DBMS_OUTPUT');
hr_utility.trace_on;

-- find the security group id
OPEN csr_sec_grp;
FETCH csr_sec_grp INTO l_security_group_id;
CLOSE csr_sec_grp;

-- only delete when not using standard security group
IF (l_security_group_id <> 0) THEN

-- delete lookups

-- find the lookup type
  OPEN csr_lu_type;
  LOOP
    FETCH csr_lu_type INTO l_lookup_type,
                           l_view_application_id;
    EXIT WHEN csr_lu_type%NOTFOUND;

    hr_utility.trace('Deleting lookup type ' || l_lookup_type ||
                     ' (' || l_view_application_id ||
                     ') and associated lookup codes');

-- find the codes to delete and delete them
    OPEN csr_lu_code;
    LOOP
      FETCH csr_lu_code INTO l_lookup_code;
      EXIT WHEN csr_lu_code%NOTFOUND;

-- call API to delete lookup code / value
      fnd_lookup_values_pkg.delete_row(
           X_LOOKUP_TYPE => l_lookup_type,
           X_SECURITY_GROUP_ID => l_security_group_id,
           X_VIEW_APPLICATION_ID => l_view_application_id,
           X_LOOKUP_CODE => l_lookup_code);

    END LOOP;
    CLOSE csr_lu_code;

-- now delete the lookup type
    fnd_lookup_types_pkg.delete_row(
         X_LOOKUP_TYPE => l_lookup_type,
         X_SECURITY_GROUP_ID => l_security_group_id,
         X_VIEW_APPLICATION_ID => l_view_application_id);

    COMMIT;

  END LOOP;
  CLOSE csr_lu_type;


-- delete FND_USER_RESP_GROUPS

  OPEN csr_usrresgrp;
  LOOP
    FETCH csr_usrresgrp INTO
      l_username,
      l_resp_app,
      l_resp_key,
      l_security_group;

   EXIT WHEN csr_usrresgrp%NOTFOUND;

   hr_utility.trace('Deleting user/resp (' ||
                    l_username || '/' ||
                    l_resp_app || '/' ||
                    l_resp_key || '/' ||
                    l_security_group || ')');

   fnd_user_pkg.DelResp(username       => l_username,
                        resp_app       => l_resp_app,
                        resp_key       => l_resp_key,
                        security_group => l_security_group);

   COMMIT;

  END LOOP;
  CLOSE csr_usrresgrp;


-- delete FND_SECURITY_GROUPS
  fnd_security_groups_pkg.delete_row(l_security_group_id);


END IF;


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_utility.trace('An error occurred whilst deleting fnd information:');
  hr_utility.trace(SQLERRM || ' in hr_dm_delete.del_fnd_info');
  RAISE;

--
END del_fnd_info;
--


-- ------------------------- main ------------------------
-- Description: This is the delete phase slave. It reads an item from the
-- hr_dm_migration_ranges table that is applicable for the current group.
-- The data is then deleted using the appropriate TDS package.
--
-- When there are no more items left for the currently active group, the
-- process pauses until all the threads that are processing the group have
-- finished and then the next group to be processed is selected.
--
--
--  Input Parameters
--        p_migration_id        - of current migration
--
--        p_concurrent_process  - Y if program called from CM, otherwise
--                                N prevents message logging
--
--        p_last_migration_date - date of last sucessful migration
--
--        p_process_number      - the slave number to allow implicit locking
--
--
--  Output Parameters
--        errbuf  - buffer for output message (for CM manager)
--
--        retcode - program return code (for CM manager)
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_migration_id IN NUMBER,
               p_concurrent_process IN VARCHAR2 DEFAULT 'Y',
               p_last_migration_date IN DATE,
               p_process_number IN NUMBER
               ) IS
--

l_current_phase_status VARCHAR2(30);
l_delete_phase_id NUMBER;
l_range_phase_id NUMBER;
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_table_name VARCHAR2(30);
l_short_name VARCHAR2(30);
l_status VARCHAR2(30);
l_phase_item_id NUMBER;
l_business_group_id NUMBER;
l_migration_type VARCHAR2(30);
l_string VARCHAR2(500);
l_group_id NUMBER;
l_no_of_threads NUMBER;

l_chunk_size NUMBER;
l_dummy NUMBER;
l_active_group NUMBER;
l_group_work NUMBER := -1;
l_range_id NUMBER;
l_starting_process_sequence NUMBER;
l_ending_process_sequence NUMBER;


CURSOR csr_migration_info IS
  SELECT business_group_id, migration_type
    FROM hr_dm_migrations
    WHERE migration_id = p_migration_id;

CURSOR csr_active_group IS
  SELECT active_group
    FROM hr_dm_migrations
    WHERE migration_id = p_migration_id;

CURSOR csr_group_work IS
  SELECT group_id
    FROM hr_dm_application_groups
    WHERE (migration_type = 'D')
      AND (group_order IN (
      SELECT MAX(apg.group_order)
        FROM hr_dm_phase_items pi_dn,
             hr_dm_tables tbl,
             hr_dm_migration_ranges mr,
             hr_dm_phase_items pi_rg,
             hr_dm_table_groupings tgp,
             hr_dm_application_groups apg
        WHERE pi_rg.phase_id = l_range_phase_id
          AND pi_rg.phase_item_id = mr.phase_item_id
          AND pi_rg.table_name = tbl.table_name
          AND pi_dn.phase_id = l_delete_phase_id
          AND pi_dn.group_id = pi_rg.group_id
          AND tbl.table_id = tgp.table_id
          AND tgp.group_id = apg.group_id
          AND apg.migration_type = 'D'
          AND mr.status ='NS')
       );

CURSOR csr_table_range IS
  SELECT mr.range_id,
         tbl.table_name,
         tbl.short_name,
         mr.starting_process_sequence,
         mr.ending_process_sequence,
         pi_del.phase_item_id
    FROM hr_dm_phase_items pi_del,
         hr_dm_tables tbl,
         hr_dm_migration_ranges mr,
         hr_dm_phase_items pi_rg,
         hr_dm_table_groupings tgp
    WHERE pi_rg.phase_id = l_range_phase_id
      AND pi_rg.phase_item_id = mr.phase_item_id
      AND mr.status = 'NS'
      AND pi_rg.table_name = tbl.table_name
      AND pi_del.phase_id = l_delete_phase_id
      AND pi_del.group_id = pi_rg.group_id
      AND tgp.table_id = tbl.table_id
      AND tgp.group_id = l_active_group
      AND ((MOD(mr.range_id, l_no_of_threads) + 1) = p_process_number);


--
BEGIN
--

-- initialize messaging (only for concurrent processing)
IF (p_concurrent_process = 'Y') THEN
  hr_dm_utility.message_init;
END IF;

hr_dm_utility.message('ROUT','entry:hr_dm_delete.main', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             ')(p_last_migration_date - ' ||
                             p_last_migration_date || ')', 10);


-- Set the variable so as to disable the trigger on the table.
hr_general.g_data_migrator_mode := 'Y';

-- set the profile to disable the audit trigger
fnd_profile.put (name => 'AUDITTRAIL:ACTIVATE'
                ,val => 'N'
                );

-- get the delete phase_id
l_delete_phase_id := hr_dm_utility.get_phase_id('D', p_migration_id);

-- get the range phase_id
l_range_phase_id := hr_dm_utility.get_phase_id('R', p_migration_id);


-- get the business_group_id and migration_type
OPEN csr_migration_info;
LOOP
  FETCH csr_migration_info INTO l_business_group_id, l_migration_type;
  EXIT WHEN csr_migration_info%NOTFOUND;
END LOOP;
CLOSE csr_migration_info;

-- get the number of threads to enable modulus locking
l_no_of_threads := hr_dm_utility.number_of_threads(l_business_group_id);

-- find the chunk size
l_chunk_size := hr_dm_utility.chunk_size(l_business_group_id);


-- loop until either delete phase is in error or all delete phase items have
-- been processed
hr_dm_utility.message('INFO','loop start', 15);
LOOP

-- get status of delete phase, is phase completed?
-- if null returned, then assume it is NS.
  l_current_phase_status := NVL(hr_dm_utility.get_phase_status('D',
                                p_migration_id), 'NS');

-- if status is error, then raise an exception
  IF (l_current_phase_status = 'E') THEN
    l_fatal_error_message := 'Current phase in error - slave exiting';
    RAISE e_fatal_error;
  END IF;

-- get currently active group
  OPEN csr_active_group;
  FETCH csr_active_group INTO l_active_group;
  CLOSE csr_active_group;
  hr_dm_utility.message('INFO','active group is ' || l_active_group, 15);

-- fetch a row to process
  l_table_name := NULL;
  OPEN csr_table_range;
  FETCH csr_table_range INTO l_range_id, l_table_name, l_short_name,
                             l_starting_process_sequence,
                             l_ending_process_sequence,
                             l_phase_item_id;
  CLOSE csr_table_range;

  IF l_table_name IS NOT NULL THEN
    hr_dm_utility.message('INFO','deleting - ' || l_table_name, 11);
-- update status to started
    hr_dm_utility.update_migration_ranges(p_new_status => 'S',
                                          p_id => l_range_id);
--
-- call delete function...
--
-- build parameter string
    l_string := 'begin hrdmd_' || l_short_name || '.delete_source( ' ||
                l_business_group_id || ', ''' ||
                l_starting_process_sequence || ''', ' ||
                l_ending_process_sequence || ', ' ||
                l_chunk_size || '); end;';
    hr_dm_utility.message('INFO','using - ' || l_string, 12);
    EXECUTE IMMEDIATE l_string;

-- update status to completed
    hr_dm_utility.update_migration_ranges(p_new_status => 'C',
                                          p_id => l_range_id);
    COMMIT;

  ELSE
-- no rows left to process in this group
-- check if all tables in this group have either been completed or errored
-- ie all slaves have completed work on this group
    LOOP
      hr_dm_utility.message('INFO','seeing if work on this group to do.', 15);

      OPEN csr_group_work;
      FETCH csr_group_work INTO l_group_work;
      IF csr_group_work%NOTFOUND THEN
        l_group_work := NULL;
      END IF;
      CLOSE csr_group_work;

-- set new active group
      hr_dm_utility.message('INFO','l_group_work - ' || l_group_work, 15);
      hr_dm_utility.message('INFO','l_active_group - ' || l_active_group, 15);
      IF l_group_work <> l_active_group THEN
        hr_dm_utility.message('INFO','setting new active group', 15);
        set_active(p_migration_id);
        COMMIT;
      ELSE
        hr_dm_utility.message('INFO','Waiting for other slaves to finish this' ||
                               ' group', 13);
-- sleep for 5 seconds to allow other slaves to finish
-- read from a non-existant pipe, using time out feature to
-- give delay time
        l_dummy := dbms_pipe.receive_message('temporary_unused_hrdm_pipe', 5);
      END IF;

      EXIT WHEN NVL(l_group_work,0) <> l_active_group
        OR NVL(hr_dm_utility.get_phase_status('D',p_migration_id), 'NS') = 'E'
        OR l_group_work IS NULL;

    END LOOP;
  END IF;

  l_status := NVL(hr_dm_utility.get_phase_status('D', p_migration_id), 'NS');

  hr_dm_utility.message('INFO','l_group_work - ' || l_group_work, 15);
  hr_dm_utility.message('INFO','l_status - ' || l_status, 15);
  EXIT WHEN l_status IN ('C','E')
        OR l_group_work IS NULL;

  COMMIT;
END LOOP;


-- set up return values to concurrent manager
retcode := 0;
errbuf := 'No errors - examine logfiles for detailed reports.';


hr_dm_utility.message('INFO','delete - slave process', 15);
hr_dm_utility.message('SUMM','delete - slave process', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_delete.main', 25);
hr_dm_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);

-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  retcode := 0;
  errbuf := 'An error occurred during the migration - examine logfiles for '
            || 'detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_delete.main',l_fatal_error_message,'R');
WHEN OTHERS THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles for '
            || 'detailed reports.';
-- update status to error
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_delete.main','(none)','R');

--
END main;
--



-- ------------------------- pre_delete_process ------------------------
-- Description: This procedure writes out a sql script to delete the entries
-- that the are striped by business_group_id (directly or indirectly) that
-- the DM can not delete itself.
--
--
--  Input Parameters
--        r_migration_data  - migration record
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE pre_delete_process(r_migration_data IN
                                           hr_dm_utility.r_migration_rec) IS
--

l_location VARCHAR2(2000);
l_aol_filename VARCHAR2(30);
l_filehandle UTL_FILE.FILE_TYPE;
l_sysdate VARCHAR2(30);
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_delete.pre_delete_process', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);



-- find logfile directory and open file for delete script
fnd_profile.get('UTL_FILE_LOG', l_location);
l_aol_filename := 'DM' || r_migration_data.migration_id || '.sql';
hr_dm_utility.message('INFO','l_location ' || l_location, 13);
hr_dm_utility.message('INFO','l_aol_filename ' || l_aol_filename, 13);

IF l_location IS NULL THEN
  l_fatal_error_message := 'The profile named Stored Procedure Log ' ||
                           'Directory has not been set. Set to a ' ||
                           'valid location where the database can ' ||
                           'write files to.';
  RAISE e_fatal_error;
END IF;


l_filehandle := utl_file.fopen(l_location, l_aol_filename, 'w');

-- add header info
utl_file.put_line(l_filehandle, 'REM');
utl_file.put_line(l_filehandle, 'WHENEVER SQLERROR EXIT FAILURE ROLLBACK;');
utl_file.put_line(l_filehandle, 'WHENEVER OSERROR EXIT FAILURE ROLLBACK;');
utl_file.put_line(l_filehandle, 'REM');
utl_file.put_line(l_filehandle, 'REM  Data Migrator Delete Script');
utl_file.put_line(l_filehandle, 'REM ');
utl_file.put_line(l_filehandle, 'REM  Migration ID ' || r_migration_data.migration_id);
SELECT to_char(sysdate,'HH:MI  DD-MON-YYYY')
  INTO l_sysdate
  FROM dual;
utl_file.put_line(l_filehandle, 'REM  Date         ' || l_sysdate);
utl_file.put_line(l_filehandle, 'REM ');
utl_file.put_line(l_filehandle, 'REM ');

utl_file.put_line(l_filehandle, '--');
utl_file.put_line(l_filehandle, 'BEGIN');
utl_file.put_line(l_filehandle, '--');

utl_file.put_line(l_filehandle, '-- local lookups, security info');
utl_file.put_line(l_filehandle, 'hr_dm_delete.del_fnd_info(' ||
                  r_migration_data.business_group_id || ');');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, '');
utl_file.put_line(l_filehandle, '-- business group info');

utl_file.put_line(l_filehandle, 'delete from HR_ALL_ORGANIZATION_UNITS_TL');
utl_file.put_line(l_filehandle, 'where ORGANIZATION_ID in (');
utl_file.put_line(l_filehandle, '    select ORGANIZATION_ID');
utl_file.put_line(l_filehandle, '    from HR_ALL_ORGANIZATION_UNITS');
utl_file.put_line(l_filehandle, '    where BUSINESS_GROUP_ID = ' ||
                  r_migration_data.business_group_id || ');');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, 'delete from HR_LOCATIONS_ALL_TL');
utl_file.put_line(l_filehandle, 'where LOCATION_ID in (');
utl_file.put_line(l_filehandle, '    select LOCATION_ID');
utl_file.put_line(l_filehandle, '    from HR_LOCATIONS_ALL');
utl_file.put_line(l_filehandle, '    where BUSINESS_GROUP_ID = ' ||
                  r_migration_data.business_group_id || ');');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, 'delete from HR_ORGANIZATION_INFORMATION ');
utl_file.put_line(l_filehandle, 'where ORGANIZATION_ID in (');
utl_file.put_line(l_filehandle, '    select ORGANIZATION_ID');
utl_file.put_line(l_filehandle, '    from HR_ALL_ORGANIZATION_UNITS');
utl_file.put_line(l_filehandle, '    where BUSINESS_GROUP_ID = ' ||
                  r_migration_data.business_group_id || ');');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, 'delete from HR_ALL_ORGANIZATION_UNITS');
utl_file.put_line(l_filehandle, 'where BUSINESS_GROUP_ID = ' ||
                  r_migration_data.business_group_id || ';');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, 'delete from HR_LOCATIONS_ALL');
utl_file.put_line(l_filehandle, 'where BUSINESS_GROUP_ID = ' ||
                  r_migration_data.business_group_id || ';');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, '-- DM processes info');
utl_file.put_line(l_filehandle, 'delete from BEN_BATCH_PARAMETER');
utl_file.put_line(l_filehandle, 'where BUSINESS_GROUP_ID = ' ||
                  r_migration_data.business_group_id || ';');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, '-- misc tables');
utl_file.put_line(l_filehandle, 'delete from BEN_EXT_CHG_EVT_LOG');
utl_file.put_line(l_filehandle, 'where BUSINESS_GROUP_ID = ' ||
                  r_migration_data.business_group_id || ';');
utl_file.put_line(l_filehandle, '');


utl_file.put_line(l_filehandle, '-- migration info');
utl_file.put_line(l_filehandle, 'delete from hr_dm_migration_requests');
utl_file.put_line(l_filehandle, 'where migration_id in');
utl_file.put_line(l_filehandle, '  (select migration_id');
utl_file.put_line(l_filehandle, '   from hr_dm_migrations');
utl_file.put_line(l_filehandle, '   where business_group_id = ' ||
                  r_migration_data.business_group_id || ');');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, 'delete from hr_dm_migration_ranges');
utl_file.put_line(l_filehandle, 'where phase_item_id in');
utl_file.put_line(l_filehandle, '  (select phase_item_id');
utl_file.put_line(l_filehandle, '   from hr_dm_phase_items');
utl_file.put_line(l_filehandle, '   where phase_id in');
utl_file.put_line(l_filehandle, '     (select phase_id');
utl_file.put_line(l_filehandle, '      from hr_dm_phases');
utl_file.put_line(l_filehandle, '      where migration_id in');
utl_file.put_line(l_filehandle, '        (select migration_id');
utl_file.put_line(l_filehandle, '         from hr_dm_migrations');
utl_file.put_line(l_filehandle, '         where business_group_id = ' ||
                  r_migration_data.business_group_id || ')));');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, 'delete from hr_dm_phase_items');
utl_file.put_line(l_filehandle, 'where phase_item_id in');
utl_file.put_line(l_filehandle, '  (select phase_item_id');
utl_file.put_line(l_filehandle, '   from hr_dm_phase_items');
utl_file.put_line(l_filehandle, '   where phase_id in');
utl_file.put_line(l_filehandle, '     (select phase_id');
utl_file.put_line(l_filehandle, '      from hr_dm_phases');
utl_file.put_line(l_filehandle, '      where migration_id in');
utl_file.put_line(l_filehandle, '        (select migration_id');
utl_file.put_line(l_filehandle, '         from hr_dm_migrations');
utl_file.put_line(l_filehandle, '         where business_group_id = ' ||
                  r_migration_data.business_group_id || ')));');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, 'delete from hr_dm_phases');
utl_file.put_line(l_filehandle, 'where phase_id in');
utl_file.put_line(l_filehandle, '  (select phase_id');
utl_file.put_line(l_filehandle, '   from hr_dm_phases');
utl_file.put_line(l_filehandle, '   where migration_id in');
utl_file.put_line(l_filehandle, '     (select migration_id');
utl_file.put_line(l_filehandle, '      from hr_dm_migrations');
utl_file.put_line(l_filehandle, '      where business_group_id = ' ||
                  r_migration_data.business_group_id || '));');
utl_file.put_line(l_filehandle, '');

utl_file.put_line(l_filehandle, 'delete from hr_dm_migrations');
utl_file.put_line(l_filehandle, 'where migration_id in');
utl_file.put_line(l_filehandle, '  (select migration_id');
utl_file.put_line(l_filehandle, '   from hr_dm_migrations');
utl_file.put_line(l_filehandle, '   where business_group_id = ' ||
                  r_migration_data.business_group_id || ');');
utl_file.put_line(l_filehandle, '');


utl_file.put_line(l_filehandle, '--');
utl_file.put_line(l_filehandle, 'END;');
utl_file.put_line(l_filehandle, '--');
utl_file.put_line(l_filehandle, '/');
utl_file.put_line(l_filehandle, 'COMMIT;');
utl_file.put_line(l_filehandle, 'EXIT;');


-- close file
utl_file.fclose(l_filehandle);



hr_dm_utility.message('INFO','Delete - cleanup script', 15);
hr_dm_utility.message('SUMM','Delete - cleanup script', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_delete.pre_delete_process', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_delete.pre_delete_process',
                      l_fatal_error_message,'R');
  RAISE;

WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_delete.pre_delete_process',
                      '(none)','R');
  RAISE;

--
END pre_delete_process;
--



END hr_dm_delete;

/
