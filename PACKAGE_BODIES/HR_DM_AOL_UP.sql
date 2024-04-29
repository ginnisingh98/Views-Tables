--------------------------------------------------------
--  DDL for Package Body HR_DM_AOL_UP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_AOL_UP" AS
/* $Header: perdmaul.pkb 120.0 2005/05/31 17:03:39 appldev noship $ */


/*--------------------------- PRIVATE ROUTINES ---------------------------*/



-- ------------------------- add_details ------------------------
-- Description: The parameters for the requested loader are
-- written to the upload file.
--
--
--  Input Parameters
--        p_migration_id - migration id
--
--        p_phase_id     - of phase
--
--        p_phase_item   - of phase item
--
--        p_loader_name  - loader to be added
--
--        p_file_handle  - file handle to write commands to
--
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE add_details(p_migration_id IN NUMBER,
                      p_phase_id IN NUMBER,
                      p_phase_item_id IN NUMBER,
                      p_file_handle IN UTL_FILE.FILE_TYPE
                      ) IS
--

l_loader_name VARCHAR2(30);
l_loader_conc_program VARCHAR2(30);
l_loader_config_file VARCHAR2(30);
l_config VARCHAR2(100);
l_parameter1 VARCHAR2(100);
l_parameter2 VARCHAR2(100);
l_parameter3 VARCHAR2(100);
l_parameter4 VARCHAR2(100);
l_parameter5 VARCHAR2(100);
l_parameter6 VARCHAR2(100);
l_parameter7 VARCHAR2(100);
l_parameter8 VARCHAR2(100);
l_parameter9 VARCHAR2(100);
l_parameter10 VARCHAR2(100);
l_loader_application VARCHAR2(50);
l_application_id NUMBER;
l_program VARCHAR2(30);
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_filename VARCHAR2(50);
l_request_id NUMBER;
l_string VARCHAR2(2000);
l_destination_database VARCHAR2(30);
l_upload VARCHAR2(30);
l_security_group VARCHAR2(30);

CURSOR csr_data IS
  SELECT lp.loader_name,
         lp.loader_conc_program,
         lp.loader_config_file,
         lp.loader_application,
         lp.parameter_1, lp.parameter_2,
         lp.parameter_3, lp.parameter_4,
         lp.parameter_5, lp.parameter_6,
         lp.parameter_7, lp.parameter_8,
         lp.parameter_9, lp.parameter_10,
         lp.application_id,
         lp.filename
  FROM hr_dm_loader_phase_items lp,
       hr_dm_phase_items pi
  WHERE pi.phase_item_id = p_phase_item_id
    AND pi.phase_item_id = lp.ua_phase_item_id;

CURSOR csr_migration_info IS
  SELECT sg.security_group_key
  FROM hr_dm_migrations dm,
       fnd_security_groups sg,
       per_business_groups pbg
  WHERE dm.migration_id = p_migration_id
    AND dm.business_group_id = pbg.business_group_id
    AND pbg.security_group_id = sg.security_group_id;


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_aol_up.add_details', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             '(p_phase_id - ' || p_phase_id ||
                             '(p_phase_item_id - ' || p_phase_item_id ||
                             ')', 10);

-- get data for current phase_item_id
OPEN csr_data;
FETCH csr_data INTO l_loader_name,
         l_loader_conc_program,
         l_loader_config_file,
         l_loader_application,
         l_parameter1, l_parameter2,
         l_parameter3, l_parameter4,
         l_parameter5, l_parameter6,
         l_parameter7, l_parameter8,
         l_parameter9, l_parameter10,
         l_application_id,
         l_filename;
IF (csr_data%NOTFOUND) THEN
  l_fatal_error_message := 'Unable to find loader configuration data.';
  RAISE e_fatal_error;
END IF;
CLOSE csr_data;

-- set up local data
l_program := 'HRDMSLVA';
IF (l_loader_conc_program = 'FNDLOAD') THEN
  l_program := l_program || 'G';
ELSIF (l_loader_conc_program = 'FNDSLOAD') THEN
  l_program := l_program || 'S';
END IF;

-- remove loader arguements from parameters
-- except for :mode, :data and :config
-- where the loader is FNDLOAD
IF (l_loader_conc_program = 'FNDLOAD') AND
   (l_loader_name <> 'Lookups') THEN
  l_parameter4 := NULL;
  l_parameter5 := NULL;
  l_parameter6 := NULL;
  l_parameter7 := NULL;
  l_parameter8 := NULL;
  l_parameter9 := NULL;
  l_parameter10 := NULL;
END IF;

-- remove loader arguements from parameters
-- where the loader is FNDSLOAD
IF (l_loader_conc_program = 'FNDSLOAD') THEN
  l_parameter4 := NULL;
  l_parameter5 := NULL;
  l_parameter6 := NULL;
  l_parameter7 := NULL;
  l_parameter8 := NULL;
  l_parameter9 := NULL;
  l_parameter10 := NULL;
END IF;


-- use UPLOAD
-- unless we are uploading lookups, then use upload_partial

IF (l_loader_name = 'Lookups') THEN

  -- also need the security group key
  OPEN csr_migration_info;
  FETCH csr_migration_info INTO l_security_group;
  CLOSE csr_migration_info;

  l_upload := 'UPLOAD_PARTIAL';

  IF l_parameter5 = ':secgrp' THEN
    l_parameter5 := 'SECURITY_GROUP=' || l_security_group;
  END IF;

ELSE
  l_upload := 'UPLOAD';
END IF;

-- find the parameter with the :mode and replace with l_upload
IF (l_parameter1 = ':mode') THEN l_parameter1 := l_upload;
ELSIF (l_parameter2 = ':mode') THEN l_parameter2 := l_upload;
ELSIF (l_parameter3 = ':mode') THEN l_parameter3 := l_upload;
ELSIF (l_parameter4 = ':mode') THEN l_parameter4 := l_upload;
ELSIF (l_parameter5 = ':mode') THEN l_parameter5 := l_upload;
ELSIF (l_parameter6 = ':mode') THEN l_parameter6 := l_upload;
ELSIF (l_parameter7 = ':mode') THEN l_parameter7 := l_upload;
ELSIF (l_parameter8 = ':mode') THEN l_parameter8 := l_upload;
ELSIF (l_parameter9 = ':mode') THEN l_parameter9 := l_upload;
ELSIF (l_parameter10 = ':mode') THEN l_parameter10 := l_upload;
END IF;

-- find the parameter with the :config and replace with the path
-- and config file filename
l_config := '@fnd:patch/115/import/' || l_loader_config_file;

IF (l_parameter1 = ':config') THEN l_parameter1 := l_config;
ELSIF (l_parameter2 = ':config') THEN l_parameter2 := l_config;
ELSIF (l_parameter3 = ':config') THEN l_parameter3 := l_config;
ELSIF (l_parameter4 = ':config') THEN l_parameter4 := l_config;
ELSIF (l_parameter5 = ':config') THEN l_parameter5 := l_config;
ELSIF (l_parameter6 = ':config') THEN l_parameter6 := l_config;
ELSIF (l_parameter7 = ':config') THEN l_parameter7 := l_config;
ELSIF (l_parameter8 = ':config') THEN l_parameter8 := l_config;
ELSIF (l_parameter9 = ':config') THEN l_parameter9 := l_config;
ELSIF (l_parameter10 = ':config') THEN l_parameter10 := l_config;
END IF;


-- find the data file and replace with the path and filename
IF (l_parameter1 = ':data') THEN l_parameter1 := l_filename;
ELSIF (l_parameter2 = ':data') THEN l_parameter2 := l_filename;
ELSIF (l_parameter3 = ':data') THEN l_parameter3 := l_filename;
ELSIF (l_parameter4 = ':data') THEN l_parameter4 := l_filename;
ELSIF (l_parameter5 = ':data') THEN l_parameter5 := l_filename;
ELSIF (l_parameter6 = ':data') THEN l_parameter6 := l_filename;
ELSIF (l_parameter7 = ':data') THEN l_parameter7 := l_filename;
ELSIF (l_parameter8 = ':data') THEN l_parameter8 := l_filename;
ELSIF (l_parameter9 = ':data') THEN l_parameter9 := l_filename;
ELSIF (l_parameter10 = ':data') THEN l_parameter10 := l_filename;
END IF;


-- remove any :selective tags from the parameter list

IF (l_parameter1 = ':selective') THEN l_parameter1 := null;
ELSIF (l_parameter2 = ':selective') THEN l_parameter2 := null;
ELSIF (l_parameter3 = ':selective') THEN l_parameter3 := null;
ELSIF (l_parameter4 = ':selective') THEN l_parameter4 := null;
ELSIF (l_parameter5 = ':selective') THEN l_parameter5 := null;
ELSIF (l_parameter6 = ':selective') THEN l_parameter6 := null;
ELSIF (l_parameter7 = ':selective') THEN l_parameter7 := null;
ELSIF (l_parameter8 = ':selective') THEN l_parameter8 := null;
ELSIF (l_parameter9 = ':selective') THEN l_parameter9 := null;
ELSIF (l_parameter10 = ':selective') THEN l_parameter10 := null;
END IF;

-- remove any :secgrp tags from the parameter list

IF (l_parameter1 = ':secgrp') THEN l_parameter1 := null;
ELSIF (l_parameter2 = ':secgrp') THEN l_parameter2 := null;
ELSIF (l_parameter3 = ':secgrp') THEN l_parameter3 := null;
ELSIF (l_parameter4 = ':secgrp') THEN l_parameter4 := null;
ELSIF (l_parameter5 = ':secgrp') THEN l_parameter5 := null;
ELSIF (l_parameter6 = ':secgrp') THEN l_parameter6 := null;
ELSIF (l_parameter7 = ':secgrp') THEN l_parameter7 := null;
ELSIF (l_parameter8 = ':secgrp') THEN l_parameter8 := null;
ELSIF (l_parameter9 = ':secgrp') THEN l_parameter9 := null;
ELSIF (l_parameter10 = ':secgrp') THEN l_parameter10 := null;
END IF;

hr_dm_utility.message('INFO','application ' || l_loader_application, 115);
hr_dm_utility.message('INFO','program ' || l_program, 115);
hr_dm_utility.message('INFO','sub_request TRUE', 115);
hr_dm_utility.message('INFO','argument1 ' || l_parameter1, 115);
hr_dm_utility.message('INFO','argument2 ' || l_parameter2, 115);
hr_dm_utility.message('INFO','argument3 ' || l_parameter3, 115);
hr_dm_utility.message('INFO','argument4 ' || l_parameter4, 115);
hr_dm_utility.message('INFO','argument5 ' || l_parameter5, 115);
hr_dm_utility.message('INFO','argument6 ' || l_parameter6, 115);
hr_dm_utility.message('INFO','argument7 ' || l_parameter7, 115);
hr_dm_utility.message('INFO','argument8 ' || l_parameter8, 115);
hr_dm_utility.message('INFO','argument9 ' || l_parameter9, 115);
hr_dm_utility.message('INFO','argument10 ' || l_parameter10, 115);

-- get the destination database name
SELECT DESTINATION_DATABASE_INSTANCE
  INTO l_destination_database
  FROM HR_DM_MIGRATIONS
  WHERE migration_id = p_migration_id;


-- write data to UA file

l_string:= l_loader_conc_program || ' apps/apps@' ||
           l_destination_database || ' 0 Y ' ||
           l_parameter1 || ' ' ||
           l_parameter2 || ' ' ||
           l_parameter3 || ' ' ||
           l_parameter4 || ' ' ||
           l_parameter5 || ' ' ||
           l_parameter6 || ' ' ||
           l_parameter7 || ' ' ||
           l_parameter8 || ' ' ||
           l_parameter9 || ' ' ||
           l_parameter10;


utl_file.put_line(p_file_handle, l_string);

hr_dm_utility.message('INFO','Added UA entry', 115);
hr_dm_utility.message('SUMM','Added UA entry', 120);
hr_dm_utility.message('ROUT','exit:hr_dm_aol_up.add_details', 125);
hr_dm_utility.message('PARA','(none)', 130);


-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_up.add_details',
                      l_fatal_error_message, 'R');
  hr_dm_master.report_error('UA', p_migration_id,
                            'Error in hr_dm_aol_up.add_details', 'P');
  RAISE;
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_up.add_details','(none)','R');
  hr_dm_master.report_error('UA', p_migration_id,
                            'Untrapped error in hr_dm_aol_up.add_details',
                            'P');
  RAISE;

--
END add_details;
--



/*--------------------------- PUBLIC ROUTINES ----------------------------*/

-- ------------------------- post_aol_process ------------------------
-- Description: This is the post processing code for the UA phase.
--
-- It copies across the ID_FLEX_STRUCTURE_NAMEs for the current business
-- group from the source database.
--
--
--  Input Parameters
--        p_migration_id        - of current migration
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE post_aol_process(p_migration_id IN NUMBER) IS
--

l_org_information4 VARCHAR2(30);
l_org_information5 VARCHAR2(30);
l_org_information6 VARCHAR2(30);
l_org_information7 VARCHAR2(30);
l_org_information8 VARCHAR2(30);
l_org_information14 VARCHAR2(30);
l_org_information4_id NUMBER;
l_org_information5_id NUMBER;
l_org_information6_id NUMBER;
l_org_information7_id NUMBER;
l_org_information8_id NUMBER;
l_org_information14_id NUMBER;
l_business_group_id NUMBER;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_aol_up.post_aol_process', 5);
hr_dm_utility.message('PARA','(p_migration_id  - ' || p_migration_id  ||
                               ')', 10);

SELECT business_group_id
  INTO l_business_group_id
  FROM hr_dm_migrations
  WHERE migration_id = p_migration_id;


SELECT ORG_INFORMATION4,
       ORG_INFORMATION5,
       ORG_INFORMATION6,
       ORG_INFORMATION7,
       ORG_INFORMATION8,
       ORG_INFORMATION14
  INTO l_org_information4,
       l_org_information5,
       l_org_information6,
       l_org_information7,
       l_org_information8,
       l_org_information14
  FROM hr_dm_exp_hr_org_inf_flx_v;

SELECT ID_FLEX_NUM
  INTO l_org_information4_id
  FROM fnd_id_flex_structures_vl
  WHERE ID_FLEX_STRUCTURE_NAME = l_org_information4
    AND ID_FLEX_CODE = 'GRD';
SELECT ID_FLEX_NUM
  INTO l_org_information5_id
  FROM fnd_id_flex_structures_vl
  WHERE ID_FLEX_STRUCTURE_NAME = l_org_information5
    AND ID_FLEX_CODE = 'GRP';
SELECT ID_FLEX_NUM
  INTO l_org_information6_id
  FROM fnd_id_flex_structures_vl
  WHERE ID_FLEX_STRUCTURE_NAME = l_org_information6
    AND ID_FLEX_CODE = 'JOB';
SELECT ID_FLEX_NUM
  INTO l_org_information7_id
  FROM fnd_id_flex_structures_vl
  WHERE ID_FLEX_STRUCTURE_NAME = l_org_information7
    AND ID_FLEX_CODE = 'COST';
SELECT ID_FLEX_NUM
  INTO l_org_information8_id
  FROM fnd_id_flex_structures_vl
  WHERE ID_FLEX_STRUCTURE_NAME = l_org_information8
    AND ID_FLEX_CODE = 'POS';
SELECT security_group_id
  INTO l_org_information14_id
  FROM fnd_security_groups_vl
  WHERE security_group_key = l_org_information14;

UPDATE hr_organization_information
  SET ORG_INFORMATION4 = l_org_information4_id,
      ORG_INFORMATION5 = l_org_information5_id,
      ORG_INFORMATION6 = l_org_information6_id,
      ORG_INFORMATION7 = l_org_information7_id,
      ORG_INFORMATION8 = l_org_information8_id,
      ORG_INFORMATION14 = l_org_information14_id
  WHERE ORG_INFORMATION_CONTEXT = 'Business Group Information'
    AND ORGANIZATION_ID = l_business_group_id;

COMMIT;


hr_dm_utility.message('ROUT','exit:hr_dm_aol_up.post_aol_process', 25);
hr_dm_utility.message('PARA','(none)', 10);
EXCEPTION
  WHEN OTHERS THEN
    hr_dm_utility.error(SQLCODE,'hr_dm_aol_up.post_aol_process',
                         '(none)','R');
    RAISE;

--
END post_aol_process;
--





-- ------------------------- main ------------------------
-- Description: This is the aol upload phase slave. It reads an item from
-- the hr_dm_phase_items table for the aol upload phase and calls the
-- appropriate aol loader.
--
--
-- On a non-first run (l_request_data <> null), the status of the slave
-- is checked to ensure that it has completed. If not then the phase item
-- status is set to error and the slave exits. Otherwise the phase item is
-- marked as being completed.
--
--
-- The status of the phase is then checked to see if it has errored.
-- If so, the slave exits.
--
-- A row is fetched from the phase_items table that has the status of NS.
-- If no rows are returned then the slave exits as there are no more rows
-- for it to process.
--
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

l_current_phase_status             VARCHAR2(30);
l_phase_id                         NUMBER;
e_fatal_error                      EXCEPTION;
e_fatal_error2                     EXCEPTION;
l_fatal_error_message              VARCHAR2(200);
l_loader_name                      VARCHAR2(30);
l_status                           VARCHAR2(30);
l_phase_item_id                    NUMBER;
l_phase                            VARCHAR2(30);
l_location                         VARCHAR2(2000);
l_aol_filename                     VARCHAR2(30);
l_filehandle                       UTL_FILE.FILE_TYPE;
l_sysdate                          VARCHAR2(30);
l_destination_database             VARCHAR2(30);
l_loader_group                     VARCHAR2(30);
l_source_db                        VARCHAR2(30);
l_destination_db                   VARCHAR2(30);
l_migration_type                   VARCHAR2(30);
l_migration_type_meaning           VARCHAR2(80);
l_business_group_id                NUMBER;
l_business_group_name              hr_dm_migrations.business_group_name%type;
l_selective_mc                     VARCHAR2(2000);


CURSOR csr_get_pi IS
  SELECT pi.phase_item_id,
         pi.status
    FROM hr_dm_phase_items pi
    WHERE (pi.status = 'NS')
      AND (pi.phase_id = l_phase_id)
      AND (pi.loader_name = l_loader_group)
    ORDER BY pi.phase_item_id;

CURSOR csr_loader IS
  SELECT tbl.loader_name
    FROM hr_dm_groups grp,
         hr_dm_application_groups apg,
         hr_dm_table_groupings tbg,
         hr_dm_tables tbl,
         hr_dm_migrations mig
    WHERE tbl.table_id = tbg.table_id
      AND tbg.group_id = grp.group_id
      AND grp.group_type = 'A'
      AND grp.group_id = apg.group_id
      AND apg.application_id = mig.application_id
      AND apg.migration_type = mig.migration_type
      AND mig.migration_id = p_migration_id;

CURSOR csr_mig_info IS
  SELECT source_database_instance,
         destination_database_instance,
         migration_type,
         hr_general.decode_lookup('HR_DM_MIGRATION_TYPE',
                                  migration_type),
         business_group_id,
         business_group_name,
         selective_migration_criteria
  FROM hr_dm_migrations
  WHERE migration_id = p_migration_id;


--
BEGIN
--

-- initialize messaging (only for concurrent processing)
IF (p_concurrent_process = 'Y') THEN
  hr_dm_utility.message_init;
END IF;

hr_dm_utility.message('ROUT','entry:hr_dm_aol_up.main', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             ')(p_last_migration_date - ' ||
                             p_last_migration_date || ')', 10);

-- get the current phase_id
l_phase_id := hr_dm_utility.get_phase_id('UA', p_migration_id);


-- get status of UA phase, is phase completed?
-- if null returned, then assume it is NS.
l_current_phase_status := NVL(hr_dm_utility.get_phase_status('UA',
                                                     p_migration_id), 'NS');


-- if status is error, then raise an exception
IF (l_current_phase_status = 'E') THEN
  l_fatal_error_message := 'Current phase in error - slave exiting';
  RAISE e_fatal_error2;
END IF;



-- find logfile directory and open file for AOL Loader commands
fnd_profile.get('UTL_FILE_LOG', l_location);
l_aol_filename := 'DM' || p_migration_id || '.txt';
hr_dm_utility.message('INFO','l_location ' || l_location, 13);
hr_dm_utility.message('INFO','l_aol_filename ' || l_aol_filename, 13);

IF l_location IS NULL THEN
  l_fatal_error_message := 'The profile named Stored Procedure Log ' ||
                           'Directory has not been set. Set to a ' ||
                           'valid location where the database can ' ||
                           'write files to.';
  RAISE e_fatal_error2;
END IF;

hr_dm_utility.message('INFO','Opening file', 13);
l_filehandle := utl_file.fopen(l_location, l_aol_filename, 'w');
hr_dm_utility.message('INFO','File opened ', 13);

-- get migration info
OPEN csr_mig_info;
FETCH csr_mig_info INTO
  l_source_db,
  l_destination_db,
  l_migration_type,
  l_migration_type_meaning,
  l_business_group_id,
  l_business_group_name,
  l_selective_mc;
CLOSE csr_mig_info;


-- add header info
utl_file.put_line(l_filehandle, '#  Data Migrator AOL Upload');
utl_file.put_line(l_filehandle, '# ');
utl_file.put_line(l_filehandle, '# ');
utl_file.put_line(l_filehandle, '# Migration Information:');
utl_file.put_line(l_filehandle, '# ');
utl_file.put_line(l_filehandle, '#  Migration ID          ' || p_migration_id);
SELECT to_char(sysdate,'HH:MI  DD-MON-YYYY')
  INTO l_sysdate
  FROM dual;
utl_file.put_line(l_filehandle, '#  Date                  ' || l_sysdate);

utl_file.put_line(l_filehandle, '#  Source Database       ' || l_source_db);
utl_file.put_line(l_filehandle, '#  Destination Database  ' || l_destination_db);
utl_file.put_line(l_filehandle, '#  Migration Type (code) ' || l_migration_type);
utl_file.put_line(l_filehandle, '#  Migration Type        ' || l_migration_type_meaning);
utl_file.put_line(l_filehandle, '#  Business Group ID     ' || l_business_group_id);
utl_file.put_line(l_filehandle, '#  Business Group Name   ' || l_business_group_name);
utl_file.put_line(l_filehandle, '#  Selective Migration Criteria');
utl_file.put_line(l_filehandle, '#    ' ||
                                    NVL(SUBSTR(l_selective_mc,1,240),'(Not Applicable)'));

utl_file.put_line(l_filehandle, '# ');
utl_file.put_line(l_filehandle, '# ');
utl_file.put_line(l_filehandle, '#  AOL Loader commands:');
utl_file.put_line(l_filehandle, '#  Replace apps/apps with the appropriate values.');
utl_file.put_line(l_filehandle, '# ');


-- loop around all groups
OPEN csr_loader;
LOOP
  FETCH csr_loader INTO l_loader_group;
  EXIT WHEN csr_loader%NOTFOUND;

  -- send info on current table to logfile
  hr_dm_utility.message('INFO','Processing - ' || l_loader_group, 13);

  -- show start of group
  utl_file.put_line(l_filehandle, '# ');
  utl_file.put_line(l_filehandle, '# <' || l_loader_group || '>');
  utl_file.put_line(l_filehandle, '# ');


  -- process each group
  OPEN csr_get_pi;
  LOOP
    FETCH csr_get_pi INTO l_phase_item_id,
                          l_status;
    EXIT WHEN csr_get_pi%NOTFOUND;

    -- add entry for this phase item

    -- update status to started
    hr_dm_utility.update_phase_items(p_new_status => 'S',
                                     p_id => l_phase_item_id);

    -- call code for AOL loader
    add_details(p_migration_id => p_migration_id,
                p_phase_id => l_phase_id,
                p_phase_item_id => l_phase_item_id,
                p_file_handle => l_filehandle);

    -- update status to completed
    hr_dm_utility.update_phase_items(p_new_status => 'C',
                                     p_id => l_phase_item_id);

  END LOOP;

  CLOSE csr_get_pi;


  -- show end of group
  utl_file.put_line(l_filehandle, '# ');
  utl_file.put_line(l_filehandle, '# </' || l_loader_group || '>');
  utl_file.put_line(l_filehandle, '# ');

END LOOP;
CLOSE csr_loader;



utl_file.put_line(l_filehandle, '# ');
utl_file.put_line(l_filehandle, '#  End of AOL Uploader commands.');
utl_file.put_line(l_filehandle, '# ');


-- get the destination database name
SELECT DESTINATION_DATABASE_INSTANCE
  INTO l_destination_database
  FROM HR_DM_MIGRATIONS
  WHERE migration_id = p_migration_id;


utl_file.put_line(l_filehandle, '# Taskflow upload commands');
utl_file.put_line(l_filehandle, '# ');
utl_file.put_line(l_filehandle, 'sqlplus apps/apps@' || l_destination_database ||
                  ' @hrwkflow.sql');
utl_file.put_line(l_filehandle, 'sqlplus apps/apps@' || l_destination_database ||
                  ' @usrwkflw.sql');
utl_file.put_line(l_filehandle, '# ');
utl_file.put_line(l_filehandle, '# End of Taskflow upload commands');
utl_file.put_line(l_filehandle, '# ');

-- close file
utl_file.fclose(l_filehandle);





-- set up return values to concurrent manager
retcode := 0;
errbuf := 'No errors - examine logfiles for detailed reports.';


hr_dm_utility.message('INFO','UA - main controller', 15);
hr_dm_utility.message('SUMM','UA - main controller', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_aol_up.main', 25);
hr_dm_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);

-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - ' ||
            'examine logfiles for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_up.main',
                      l_fatal_error_message,'UA');
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_up.main','(none)','R');
WHEN e_fatal_error2 THEN
  retcode := 0;
  errbuf := 'An error occurred during the migration - ' ||
            'examine logfiles for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_up.main',
                      l_fatal_error_message,'UA');
  hr_dm_utility.update_phases(p_new_status => 'E',
                              p_id => l_phase_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_up.main','(none)','R');
WHEN OTHERS THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - ' ||
            'examine logfiles for detailed reports.';
-- update status to error
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_aol_up.main','(none)','R');


--
END main;
--


END hr_dm_aol_up;

/
