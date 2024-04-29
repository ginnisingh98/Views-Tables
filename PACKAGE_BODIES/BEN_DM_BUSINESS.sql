--------------------------------------------------------
--  DDL for Package Body BEN_DM_BUSINESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_BUSINESS" AS
/* $Header: benfdmdbiz.pkb 120.0 2006/06/13 14:54:55 nkkrishn noship $ */

/*--------------------------- PRIVATE ROUTINES ---------------------------*/


-- ------------------------- rule_8_source ------------------------
-- Description: Only one migration can proceed at any one time. Only
-- one migration at any one time may have a status of S - Started,
-- NS - Not Started or E - Error, indicating that a migration is in
-- progress. Once a migration is C - Completed on the source or
-- destination, then a new migration can proceed. If a migration is
-- to be abandoned, then it will be given a status of A - Abandoned
-- to enable a new migration to be started.
--
--
--  Input Parameters
--        r_migration_data - record containing migration information
--        p_valid          - current validity of migration
--        p_warning        - cuurent warning of migration
--
--
--  Output Parameters
--        validity of migration - E = Error
--                                V = Valid
--                                W = Warning
--
-- ------------------------------------------------------------------------


--
PROCEDURE rule_8_source(r_migration_data IN ben_dm_utility.r_migration_rec,
                       p_valid IN OUT nocopy VARCHAR2,
                       p_warning IN OUT nocopy VARCHAR2) IS
--

l_mig_count NUMBER;

cursor c_req_stat is
select 'x'
  from fnd_concurrent_requests req,
       fnd_concurrent_programs prog
 where prog.concurrent_program_name in ('BENDMSD','BENDMSU')
   and req.concurrent_program_id = prog.concurrent_program_id
   and req.request_id <> fnd_global.conc_request_id
   and req.phase_code <> 'C';

--
l_dummy   varchar2(30);

BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_business.rule_8_source', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

ben_dm_utility.message('INFO','req id '||fnd_global.conc_request_id, 5);

open c_req_stat;
fetch c_req_stat into l_dummy;
if c_req_stat%found then
   p_valid := 'E';
   ben_dm_utility.message('INFO','Business rule 8 broken - ' ||
                        r_migration_data.database_location ||
                        ' - Only one migration can proceed at any one' ||
                        ' time. Only one migration at any one time may' ||
                        ' have a status of  S - Started, NS - Not Started' ||
                        ' or E - Error, indicating that a migration is in' ||
                        ' progress. Once a migration is C - Completed on' ||
                        ' the source or destination, then a new migration' ||
                        ' can proceed. If a migration is to be abandoned,' ||
                        ' then it will be given a statusof A - Abandoned' ||
                        ' to enable a new migration to be started.', 40);

else

  update ben_dm_migrations
     set status =decode(status,'E','A','C')
   where migration_id <>  r_migration_data.migration_id
     and status <> 'C';
  commit;

end if;
close c_req_stat;


ben_dm_utility.message('INFO','Validated rule 8', 215);
ben_dm_utility.message('SUMM','Validated rule 8', 220);
ben_dm_utility.message('ROUT','exit:ben_dm_business.rule_8_source', 225);
ben_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_business.rule_8_source',
                      '(none)','R');
  RAISE;

--
END rule_8_source;
--

-- ------------------------- rule_9_source ------------------------
-- Description: A migration can only be run / rerun if it has a
-- status of NS - Not Started or E - Error.
--
--
--  Input Parameters
--        r_migration_data - record containing migration information
--        p_valid          - current validity of migration
--        p_warning        - cuurent warning of migration
--
--
--  Output Parameters
--        validity of migration - E = Error
--                                V = Valid
--                                W = Warning
--
-- ------------------------------------------------------------------------


--
PROCEDURE rule_9_source(r_migration_data IN ben_dm_utility.r_migration_rec,
                       p_valid IN OUT nocopy VARCHAR2,
                       p_warning IN OUT nocopy VARCHAR2) IS
--

l_status VARCHAR2(30);

CURSOR csr_mig_status IS
  SELECT status
    FROM ben_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id);

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_business.rule_9_source', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

OPEN csr_mig_status;
FETCH csr_mig_status INTO l_status;
CLOSE csr_mig_status;

IF (l_status NOT IN ('NS', 'E')) THEN
  p_valid := 'E';
  ben_dm_utility.message('INFO','Business rule 9 broken - ' ||
                        r_migration_data.database_location ||
                        ' - A migration can only be rerun if it has a status' ||
                        ' of NS - Not Started or E - Error.', 45);
END IF;


ben_dm_utility.message('INFO','Validated rule 9', 215);
ben_dm_utility.message('SUMM','Validated rule 9', 220);
ben_dm_utility.message('ROUT','exit:ben_dm_business.rule_9_source', 225);
ben_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_business.rule_9_source',
                      '(none)','R');
  RAISE;

--
END rule_9_source;
--

-- ------------------------- rule_10_source ------------------------
-- Description: A migration can only be rerun if all the slaves and
-- sub-slaves launched by the previous run have either completed or
-- errored.

--
--
--  Input Parameters
--        r_migration_data - record containing migration information
--        p_valid          - current validity of migration
--        p_warning        - cuurent warning of migration
--
--
--  Output Parameters
--        validity of migration - E = Error
--                                V = Valid
--                                W = Warning
--
-- ------------------------------------------------------------------------


--
PROCEDURE rule_10_source(r_migration_data IN ben_dm_utility.r_migration_rec,
                       p_valid IN OUT nocopy VARCHAR2,
                       p_warning IN OUT nocopy VARCHAR2) IS
--

l_request_id NUMBER;
l_call_status BOOLEAN;
l_phase VARCHAR2(30);
l_status VARCHAR2(30);
l_dev_phase VARCHAR2(30);
l_dev_status VARCHAR2(30);
l_message VARCHAR2(240);

CURSOR csr_requests IS
  SELECT request_id
    FROM ben_dm_migration_requests
    WHERE (migration_id = r_migration_data.migration_id)
      AND (master_slave <> 'M');

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_business.rule_10_source', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

-- check if a slave has errored
OPEN csr_requests;
LOOP
  FETCH csr_requests INTO l_request_id;
  EXIT WHEN csr_requests%NOTFOUND;

  l_call_status := fnd_concurrent.get_request_status(l_request_id, '', '',
                                l_phase, l_status, l_dev_phase,
                                l_dev_status, l_message);
-- make sure that each slave is complete
-- this includes any of normal (ie finished sucessfully), error, warning,
-- cancelled or terminated.
  IF ( NOT(l_dev_phase = 'COMPLETE')) THEN
      p_valid := 'E';
      ben_dm_utility.message('INFO','Business rule 10 broken - ' ||
                            r_migration_data.database_location ||
                            ' - A migration can only be rerun if all the' ||
                            ' slaves and sub-slaves launched by the' ||
                            ' previous run have either completed or' ||
                            ' errored.', 50);
  END IF;

END LOOP;
CLOSE csr_requests;


ben_dm_utility.message('INFO','Validated rule 10', 215);
ben_dm_utility.message('SUMM','Validated rule 10', 220);
ben_dm_utility.message('ROUT','exit:ben_dm_business.rule_10_source', 225);
ben_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_business.rule_10_source',
                      '(none)','R');
  RAISE;

--
END rule_10_source;
--
-- ------------------------- rule_7_dest ------------------------
-- Description: Only one migration can proceed at any one time. Only
-- one migration at any one time may have a status of S - Started,
-- NS - Not Started or E - Error, indicating that a migration is in
-- progress. Once a migration is C - Completed on the source or
-- destination, then a new migration can proceed. If a migration is
-- to be abandoned, then it will be given a status of A - Abandoned
-- to enable a new migration to be started.
--
-- Note - this rule is similar to rule_7_source
--
--
--  Input Parameters
--        r_migration_data - record containing migration information
--        p_valid          - current validity of migration
--        p_warning        - cuurent warning of migration
--
--
--  Output Parameters
--        validity of migration - E = Error
--                                V = Valid
--                                W = Warning
--
-- ------------------------------------------------------------------------


--
PROCEDURE rule_7_dest(r_migration_data IN ben_dm_utility.r_migration_rec,
                       p_valid IN OUT nocopy VARCHAR2,
                       p_warning IN OUT nocopy VARCHAR2) IS
--

l_mig_count NUMBER;

cursor c_req_stat is
select 'x'
  from fnd_concurrent_requests req,
       fnd_concurrent_programs prog
 where prog.concurrent_program_name in ('BENDMSD','BENDMSU')
   and req.concurrent_program_id = prog.concurrent_program_id
   and req.request_id <> fnd_global.conc_request_id
   and req.phase_code <> 'C';

--
l_dummy   varchar2(30);

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_business.rule_7_dest', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

ben_dm_utility.message('INFO','req id '||fnd_global.conc_request_id, 5);

open c_req_stat;
fetch c_req_stat into l_dummy;
if c_req_stat%found then
   p_valid := 'E';
   ben_dm_utility.message('INFO','Business rule 7 broken - ' ||
                        r_migration_data.database_location ||
                        ' - Only one migration can proceed at any one' ||
                        ' time. Only one migration at any one time may' ||
                        ' have a status of  S - Started, NS - Not Started' ||
                        ' or E - Error, indicating that a migration is in' ||
                        ' progress. Once a migration is C - Completed on' ||
                        ' the source or destination, then a new migration' ||
                        ' can proceed. If a migration is to be abandoned,' ||
                        ' then it will be given a statusof A - Abandoned' ||
                        ' to enable a new migration to be started.', 40);

else

  update ben_dm_migrations
     set status =decode(status,'E','A','C')
   where migration_id <>  r_migration_data.migration_id
     and status <> 'C';
  commit;

end if;
close c_req_stat;


ben_dm_utility.message('INFO','Validated rule 7', 215);
ben_dm_utility.message('SUMM','Validated rule 7', 220);
ben_dm_utility.message('ROUT','exit:ben_dm_business.rule_7_dest', 225);
ben_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_business.rule_7_dest',
                      '(none)','R');
  RAISE;

--
END rule_7_dest;
--

-- ------------------------- rule_8_dest ------------------------
-- Description: Only one migration can proceed at any one time. Only
-- one migration at any one time may have a status of S - Started,
-- NS - Not Started or E - Error, indicating that a migration is in
-- progress. Once a migration is C - Completed on the source or
-- destination, then a new migration can proceed. If a migration is
-- to be abandoned, then it will be given a status of A - Abandoned
-- to enable a new migration to be started.
--
-- Note - this rule is similar to rule_9_source
--
--
--  Input Parameters
--        r_migration_data - record containing migration information
--        p_valid          - current validity of migration
--        p_warning        - cuurent warning of migration
--
--
--  Output Parameters
--        validity of migration - E = Error
--                                V = Valid
--                                W = Warning
--
-- ------------------------------------------------------------------------


--
PROCEDURE rule_8_dest(r_migration_data IN ben_dm_utility.r_migration_rec,
                       p_valid IN OUT nocopy VARCHAR2,
                       p_warning IN OUT nocopy VARCHAR2) IS
--

l_status VARCHAR2(30);

CURSOR csr_mig_status IS
  SELECT status
    FROM ben_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id);

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_business.rule_8_dest', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

OPEN csr_mig_status;
FETCH csr_mig_status INTO l_status;
CLOSE csr_mig_status;

IF (l_status NOT IN ('NS', 'E')) THEN
  p_valid := 'E';
  ben_dm_utility.message('INFO','Business rule 8 broken - ' ||
                        r_migration_data.database_location ||
                        ' - A migration can only be rerun if it has a status' ||
                        ' of NS - Not Started or E - Error.', 45);
END IF;

ben_dm_utility.message('INFO','Validated rule 8', 215);
ben_dm_utility.message('SUMM','Validated rule 8', 220);
ben_dm_utility.message('ROUT','exit:ben_dm_business.rule_8_dest', 225);
ben_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_business.rule_8_dest',
                      '(none)','R');
  RAISE;

--
END rule_8_dest;
--

-- ------------------------- rule_9_dest ------------------------
-- Description: A migration can only be run / rerun if it has a
-- status of NS - Not Started or E - Error.

--
-- Note - this rule is similar to rule_10_source
--
--
--  Input Parameters
--        r_migration_data - record containing migration information
--        p_valid          - current validity of migration
--        p_warning        - cuurent warning of migration
--
--
--  Output Parameters
--        validity of migration - E = Error
--                                V = Valid
--                                W = Warning
--
-- ------------------------------------------------------------------------


--
PROCEDURE rule_9_dest(r_migration_data IN ben_dm_utility.r_migration_rec,
                       p_valid IN OUT nocopy VARCHAR2,
                       p_warning IN OUT nocopy VARCHAR2) IS
--

l_status VARCHAR2(30);

CURSOR csr_mig_status IS
  SELECT status
    FROM ben_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id);

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_business.rule_9_dest', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 9);

OPEN csr_mig_status;
FETCH csr_mig_status INTO l_status;
CLOSE csr_mig_status;

IF (l_status NOT IN ('NS', 'E')) THEN
  p_valid := 'E';
  ben_dm_utility.message('INFO','Business rule 9 broken - ' ||
                        r_migration_data.database_location ||
                        ' - A migration can only be rerun if it has a status' ||
                        ' of NS - Not Started or E - Error.', 45);
END IF;

ben_dm_utility.message('INFO','Validated rule 9', 215);
ben_dm_utility.message('SUMM','Validated rule 9', 220);
ben_dm_utility.message('ROUT','exit:ben_dm_business.rule_9_dest', 225);
ben_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_business.rule_9_dest',
                      '(none)','R');
  RAISE;

--
END rule_9_dest;
--


/*---------------------------- PUBLIC ROUTINES ---------------------------*/

-- ------------------------- last_migration_date ------------------------
-- Description: For an a migration, data is migrated
-- starting with the date of the latest previously finished migration and
-- finishing with the start date and time of the current migration. Where a previous
-- migration has
-- not been performed or has not been finished, then the starting date is
-- that of the finished migration.
--
--  Input Parameters
--        r_migration_data - record containing migration information
--
--
--  Output Parameters
--        <none>
--
--
--  Return Value
--        last_migration_date - date of last sucessful migration
--
-- ------------------------------------------------------------------------


--
FUNCTION last_migration_date(
  r_migration_data IN ben_dm_utility.r_migration_rec)
  RETURN DATE IS
--

l_last_migration_date DATE;
l_last_mig_date DATE;
l_migration_type_test VARCHAR2(30);
l_business_group_id NUMBER;
l_last_date DATE;



CURSOR csr_mig_date IS
  SELECT MAX(effective_date)
    FROM ben_dm_migrations
    WHERE (status = 'C');
--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_business.last_migration_date', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_last_migration_date := NULL;

-- find the date of last Completed 'C' migration
-- assume last FW date of null (ie start of time)
  l_last_mig_date := NULL;
  OPEN csr_mig_date;
  FETCH csr_mig_date INTO l_last_date;
  IF (l_last_date > NVL(l_last_mig_date,
                        hr_general.start_of_time)) THEN
    l_last_mig_date := l_last_date;
    l_last_migration_date := l_last_date;
  ELSE
    l_last_migration_date := hr_general.start_of_time;
  END IF;
  CLOSE csr_mig_date;


ben_dm_utility.message('INFO','l_last_mig_date - ' || l_last_mig_date, 10);
ben_dm_utility.message('INFO','l_last_date - ' || l_last_date, 10);
ben_dm_utility.message('INFO','Found last migration date', 15);
ben_dm_utility.message('SUMM','Found last migration date', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_business.last_migration_date', 25);
ben_dm_utility.message('PARA','(l_last_migration_date - ' ||
                              l_last_migration_date || ')', 30);



RETURN(l_last_migration_date);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_business.last_migration_date','(none)',
                      'R');
  RAISE;


--
END last_migration_date;
--


-- ------------------------- validate_migration ------------------------
-- Description: The details of the current migration are compared against
-- the aplicable business rules, detailed in the code.
--
--
--  Input Parameters
--        r_migration_data - record containing migration information
--
--
--  Output Parameters
--        <none>
--
--
--  Return Value
--        validity of migration - E = Error
--                                V = Valid
--                                W = Warning
--
-- ------------------------------------------------------------------------


--
FUNCTION validate_migration(r_migration_data IN
                                             ben_dm_utility.r_migration_rec)
  RETURN VARCHAR2 IS
--

l_valid VARCHAR2(1);
l_warning VARCHAR2(1);
l_source_instance VARCHAR2(30);
l_destination_instance VARCHAR2(30);

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_business.validate_migration', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);


-- assume that migration is valid - then test to see if there are problems
l_valid := 'V';
l_warning := 'N';

-- validate business rules, as per DM LLD
-- source business rules
--   implemented in code
--   and applicable to main controller

IF (r_migration_data.database_location = 'S') THEN
  rule_8_source(r_migration_data, l_valid, l_warning);
  rule_9_source(r_migration_data, l_valid, l_warning);
  rule_10_source(r_migration_data, l_valid, l_warning);
END IF;

IF (r_migration_data.database_location = 'D') THEN
  rule_7_dest(r_migration_data, l_valid, l_warning);
  rule_8_dest(r_migration_data, l_valid, l_warning);
  rule_9_dest(r_migration_data, l_valid, l_warning);
END IF;



-- if valid but a warning has been found, show warning
IF (l_valid = 'Y' AND l_warning = 'V') THEN
  l_valid := 'W';
END IF;

ben_dm_utility.message('INFO','Validated migration', 215);
ben_dm_utility.message('SUMM','Validated migration', 220);
ben_dm_utility.message('ROUT','exit:ben_dm_business.validate_migration', 225);
ben_dm_utility.message('PARA','(l_valid - ' || l_valid || ')', 230);


-- overide
-- uncomment to turn off business rule validation for testing purposes
--l_valid := 'V';


RETURN(l_valid);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_business.validate_migration',
                      '(none)','R');
  RAISE;

--
END validate_migration;
--




END ben_dm_business;

/
