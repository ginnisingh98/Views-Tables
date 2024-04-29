--------------------------------------------------------
--  DDL for Package Body HR_DM_BUSINESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_BUSINESS" AS
/* $Header: perdmbiz.pkb 120.0 2005/05/31 17:04:52 appldev noship $ */

/*--------------------------- PRIVATE ROUTINES ---------------------------*/

-- ------------------------- rule_1_source ------------------------
-- Description: No migration can proceed if the current database is not
-- the source database.
--
-- Note - this rule is similar to rule_1_dest
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
PROCEDURE rule_1_source(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_1_source', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

-- r_migration_data holds either S or D if in source or destination
-- otherwise NULL
IF (NVL(r_migration_data.database_location,'?') <> 'S') THEN
  p_valid := 'E';
  hr_dm_utility.message('INFO','Business rule 1 broken - ' ||
                        r_migration_data.database_location ||
                        ' - No migration can proceed if the current' ||
                        ' database is not the source database.', 15);

END IF;


hr_dm_utility.message('INFO','Validated rule 1', 215);
hr_dm_utility.message('SUMM','Validated rule 1', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_1_source', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_1_source',
                      '(none)','R');
  RAISE;

--
END rule_1_source;
--

-- ------------------------- rule_2_source ------------------------
-- Description: For any migration, the business group must exist
-- on the source database.
--
-- Note - this rule is similar to rule_2_dest
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
PROCEDURE rule_2_source(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--

l_business_group_id NUMBER;

CURSOR csr_biz_grp IS
  SELECT business_group_id
  FROM per_business_groups
  WHERE business_group_id = r_migration_data.business_group_id;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_2_source', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

-- r_migration_data holds the business_group_ids
OPEN csr_biz_grp;
FETCH csr_biz_grp INTO l_business_group_id;
CLOSE csr_biz_grp;
IF (r_migration_data.business_group_id <>
                                      NVL(l_business_group_id, -1)) THEN
  p_valid := 'E';
  hr_dm_utility.message('INFO','Business rule 2 broken - ' ||
                        r_migration_data.database_location ||
                        ' - For any migration, the business group must' ||
                        ' exist on the source database.', 20);
END IF;

hr_dm_utility.message('INFO','Validated rule 2', 215);
hr_dm_utility.message('SUMM','Validated rule 2', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_2_source', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_2_source',
                      '(none)','R');
  RAISE;

--
END rule_2_source;
--

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
PROCEDURE rule_8_source(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--

l_mig_count NUMBER;

CURSOR csr_mig_count IS
  SELECT count(*)
    FROM hr_dm_migrations
    WHERE status IN ('S', 'NS', 'E');

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_8_source', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

OPEN csr_mig_count;
FETCH csr_mig_count INTO l_mig_count;
CLOSE csr_mig_count;

IF (l_mig_count > 1) THEN
  p_valid := 'E';
  hr_dm_utility.message('INFO','Business rule 8 broken - ' ||
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
END IF;


hr_dm_utility.message('INFO','Validated rule 8', 215);
hr_dm_utility.message('SUMM','Validated rule 8', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_8_source', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_8_source',
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
PROCEDURE rule_9_source(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--

l_status VARCHAR2(30);

CURSOR csr_mig_status IS
  SELECT status
    FROM hr_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id);

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_9_source', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

OPEN csr_mig_status;
FETCH csr_mig_status INTO l_status;
CLOSE csr_mig_status;

IF (l_status NOT IN ('NS', 'E')) THEN
  p_valid := 'E';
  hr_dm_utility.message('INFO','Business rule 9 broken - ' ||
                        r_migration_data.database_location ||
                        ' - A migration can only be rerun if it has a status' ||
                        ' of NS - Not Started or E - Error.', 45);
END IF;


hr_dm_utility.message('INFO','Validated rule 9', 215);
hr_dm_utility.message('SUMM','Validated rule 9', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_9_source', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_9_source',
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
PROCEDURE rule_10_source(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
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
    FROM hr_dm_migration_requests
    WHERE (migration_id = r_migration_data.migration_id)
      AND (master_slave <> 'M');

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_10_source', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
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
      hr_dm_utility.message('INFO','Business rule 10 broken - ' ||
                            r_migration_data.database_location ||
                            ' - A migration can only be rerun if all the' ||
                            ' slaves and sub-slaves launched by the' ||
                            ' previous run have either completed or' ||
                            ' errored.', 50);
  END IF;

END LOOP;
CLOSE csr_requests;


hr_dm_utility.message('INFO','Validated rule 10', 215);
hr_dm_utility.message('SUMM','Validated rule 10', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_10_source', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_10_source',
                      '(none)','R');
  RAISE;

--
END rule_10_source;
--


-- ------------------------- rule_1_dest ------------------------
-- Description: No migration can proceed if the current database is not
-- the destination database.
--
-- Note - this rule is similar to rule_1_dest
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
PROCEDURE rule_1_dest(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_1_dest', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

-- r_migration_data holds either S or D if in dest or destination
-- otherwise NULL
IF (NVL(r_migration_data.database_location,'?') <> 'D') THEN
  p_valid := 'E';
  hr_dm_utility.message('INFO','Business rule 1 broken - ' ||
                        r_migration_data.database_location ||
                        ' - No migration can proceed if the current' ||
                        ' database is not the dest database.', 15);

END IF;


hr_dm_utility.message('INFO','Validated rule 1', 215);
hr_dm_utility.message('SUMM','Validated rule 1', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_1_dest', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_1_dest',
                      '(none)','R');
  RAISE;

--
END rule_1_dest;
--

-- ------------------------- rule_2_dest ------------------------
-- Description: For a non-FW migration the business group must
-- exist in the destination database.
--
-- Note - this rule is similar to rule_2_source
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
PROCEDURE rule_2_dest(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--

l_business_group_id NUMBER;

CURSOR csr_biz_grp IS
  SELECT business_group_id
  FROM per_business_groups
  WHERE business_group_id = r_migration_data.business_group_id;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_2_dest', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

IF (r_migration_data.migration_type <> 'FW') THEN
  OPEN csr_biz_grp;
  FETCH csr_biz_grp INTO l_business_group_id;
  CLOSE csr_biz_grp;
  IF (r_migration_data.business_group_id <>
                                        NVL(l_business_group_id, -1)) THEN
    p_valid := 'E';
    hr_dm_utility.message('INFO','Business rule 2 broken - ' ||
                          r_migration_data.database_location ||
                          ' - For a non-FW migration the business ' ||
                          'group must exist in the destination ' ||
                          'database.', 20);
  END IF;
END IF;


hr_dm_utility.message('INFO','Validated rule 2', 215);
hr_dm_utility.message('SUMM','Validated rule 2', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_2_dest', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_2_dest',
                      '(none)','R');
  RAISE;

--
END rule_2_dest;
--



-- ------------------------- rule_6_dest ------------------------
-- Description: For a FW migration, the business group must not exist
-- on the destination database unless it has been created as part of
-- this upload process.
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
PROCEDURE rule_6_dest(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--

l_business_group_created VARCHAR2(1);
l_business_group_id NUMBER;

CURSOR csr_mig_info IS
  SELECT business_group_created
    FROM hr_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id);

CURSOR csr_biz_grp IS
  SELECT business_group_id
  FROM per_business_groups
  WHERE business_group_id = r_migration_data.business_group_id;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_6_dest', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

-- get the details of the current migration
OPEN csr_mig_info;
LOOP
  FETCH csr_mig_info INTO l_business_group_created;
  EXIT WHEN csr_mig_info%NOTFOUND;
END LOOP;
CLOSE csr_mig_info;

IF (r_migration_data.migration_type = 'FW') THEN
-- see if BG exists
  l_business_group_id := NULL;
  OPEN csr_biz_grp;
  FETCH csr_biz_grp INTO l_business_group_id;
  CLOSE csr_biz_grp;

-- if bg exists and we haven't created it, then raise error
  IF (l_business_group_id IS NOT NULL)
    AND (NVL(l_business_group_created,'N') = 'N') THEN
    p_valid := 'E';
    hr_dm_utility.message('INFO','Business rule 6 broken - ' ||
                          r_migration_data.database_location ||
                          ' - For a FW migration, the business group' ||
                          ' must not exist on the destination' ||
                          ' database.', 105);
    END IF;

-- if bg doesn't exist but we think we have created it then raise error
  IF (l_business_group_id IS NULL)
    AND (NVL(l_business_group_created,'N') = 'Y') THEN
    p_valid := 'E';
    hr_dm_utility.message('INFO','Business rule 6 broken - ' ||
                          r_migration_data.database_location ||
                          ' - Business Group does not exist ' ||
                          'although it should have been ' ||
                          'created already.', 105);
  END IF;

END IF;

hr_dm_utility.message('INFO','Validated rule 6', 215);
hr_dm_utility.message('SUMM','Validated rule 6', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_7_dest', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_6_dest',
                      '(none)','R');
  RAISE;

--
END rule_6_dest;
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
PROCEDURE rule_7_dest(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--

l_mig_count NUMBER;

CURSOR csr_mig_count IS
  SELECT count(*)
    FROM hr_dm_migrations
    WHERE status IN ('S', 'NS', 'E');

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_7_dest', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

OPEN csr_mig_count;
FETCH csr_mig_count INTO l_mig_count;
CLOSE csr_mig_count;

IF (l_mig_count > 1) THEN
  p_valid := 'E';
  hr_dm_utility.message('INFO','Business rule 7 broken - ' ||
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
END IF;



hr_dm_utility.message('INFO','Validated rule 7', 215);
hr_dm_utility.message('SUMM','Validated rule 7', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_7_dest', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_7_dest',
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
PROCEDURE rule_8_dest(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--

l_status VARCHAR2(30);

CURSOR csr_mig_status IS
  SELECT status
    FROM hr_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id);

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_8_dest', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 10);

OPEN csr_mig_status;
FETCH csr_mig_status INTO l_status;
CLOSE csr_mig_status;

IF (l_status NOT IN ('NS', 'E')) THEN
  p_valid := 'E';
  hr_dm_utility.message('INFO','Business rule 8 broken - ' ||
                        r_migration_data.database_location ||
                        ' - A migration can only be rerun if it has a status' ||
                        ' of NS - Not Started or E - Error.', 45);
END IF;

hr_dm_utility.message('INFO','Validated rule 8', 215);
hr_dm_utility.message('SUMM','Validated rule 8', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_8_dest', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_8_dest',
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
PROCEDURE rule_9_dest(r_migration_data IN hr_dm_utility.r_migration_rec,
                       p_valid IN OUT NOCOPY VARCHAR2,
                       p_warning IN OUT NOCOPY VARCHAR2) IS
--

l_status VARCHAR2(30);

CURSOR csr_mig_status IS
  SELECT status
    FROM hr_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id);

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.rule_9_dest', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(p_valid - ' || p_valid ||
                             ')(p_warning - ' || p_warning || ')', 9);

OPEN csr_mig_status;
FETCH csr_mig_status INTO l_status;
CLOSE csr_mig_status;

IF (l_status NOT IN ('NS', 'E')) THEN
  p_valid := 'E';
  hr_dm_utility.message('INFO','Business rule 9 broken - ' ||
                        r_migration_data.database_location ||
                        ' - A migration can only be rerun if it has a status' ||
                        ' of NS - Not Started or E - Error.', 45);
END IF;

hr_dm_utility.message('INFO','Validated rule 9', 215);
hr_dm_utility.message('SUMM','Validated rule 9', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.rule_9_dest', 225);
hr_dm_utility.message('PARA','(p_valid - ' || p_valid ||
                      ')(p_warning - ' || p_warning || ')', 230);


-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.rule_9_dest',
                      '(none)','R');
  RAISE;

--
END rule_9_dest;
--


/*---------------------------- PUBLIC ROUTINES ---------------------------*/

-- ------------------------- last_migration_date ------------------------
-- Description: For an A, P, SL, SF and SD migration, data is migrated
-- starting with the date of the latest previously finished migration
-- of the same type, business group, source and destination and finishing
-- with the start date and time of the current migration. Where a previous
-- migration of the same type, business group, source and destination has
-- not been performed or has not been finished, then the starting date is
-- that of the finished FW migration for the same business group, source
-- and destination.
--
-- For the first P migration, the last migration date is null.
--
-- For an SR migration, the last migration date is always null.
--
-- For a D migration, the last migration date is always null.
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
--        last_migration_date - date of last sucessful migration
--
-- ------------------------------------------------------------------------


--
FUNCTION last_migration_date(
  r_migration_data IN hr_dm_utility.r_migration_rec)
  RETURN DATE IS
--

l_last_migration_date DATE;
l_last_fw_date DATE;
l_migration_type_test VARCHAR2(30);
l_business_group_id NUMBER;
l_last_date DATE;


CURSOR csr_mig_info IS
  SELECT business_group_id
    FROM hr_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id)
      AND (UPPER(source_database_instance) =
                      UPPER(r_migration_data.source_database_instance))
      AND (UPPER(destination_database_instance) =
                      UPPER(r_migration_data.destination_database_instance));

CURSOR csr_mig_date IS
  SELECT MAX(effective_date)
    FROM hr_dm_migrations
    WHERE (status = 'F')
      AND (business_group_id = l_business_group_id)
      AND (migration_type = 'FW')
      AND
      (
        (
          UPPER(source_database_instance) =
                      UPPER(r_migration_data.source_database_instance)
        AND
          UPPER(destination_database_instance) =
                      UPPER(r_migration_data.destination_database_instance)
        )
      OR
        (
          UPPER(source_database_instance) =
                      UPPER(r_migration_data.destination_database_instance)
        AND
          UPPER(destination_database_instance) =
                      UPPER(r_migration_data.source_database_instance)
        )
      );

CURSOR csr_mig_date_othr IS
  SELECT MAX(effective_date)
    FROM hr_dm_migrations
    WHERE (status = 'F')
      AND (business_group_id = l_business_group_id)
      AND (migration_type = l_migration_type_test)
      AND (effective_date > NVL(l_last_fw_date,
                        hr_general.start_of_time))
      AND
      (
        (
          UPPER(source_database_instance) =
                      UPPER(r_migration_data.source_database_instance)
        AND
          UPPER(destination_database_instance) =
                      UPPER(r_migration_data.destination_database_instance)
        )
      OR
        (
          UPPER(source_database_instance) =
                      UPPER(r_migration_data.destination_database_instance)
        AND
          UPPER(destination_database_instance) =
                      UPPER(r_migration_data.source_database_instance)
        )
      );

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.last_migration_date', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

-- if we are doing an FW / SR migration, then we want to migrate all
-- data, so last migration date is null

hr_dm_utility.message('INFO','src - ' ||
                      r_migration_data.source_database_instance, 10);
hr_dm_utility.message('INFO','dest - ' ||
                      r_migration_data.destination_database_instance, 10);

IF r_migration_data.migration_type IN('FW','SR', 'D') THEN
  l_last_migration_date := NULL;
ELSE

-- we have a non-FW/SR migration

-- get the details of the current migration
  OPEN csr_mig_info;
  LOOP
    FETCH csr_mig_info INTO l_business_group_id;
    EXIT WHEN csr_mig_info%NOTFOUND;
  END LOOP;
  CLOSE csr_mig_info;


-- find the date of last finished FW migration
-- assume last FW date of null (ie start of time)
  l_last_fw_date := NULL;
  OPEN csr_mig_date;
  FETCH csr_mig_date INTO l_last_date;
  IF (l_last_date > NVL(l_last_fw_date,
                        hr_general.start_of_time)) THEN
    l_last_fw_date := l_last_date;
  END IF;
  CLOSE csr_mig_date;

hr_dm_utility.message('INFO','l_last_fw_date - ' || l_last_fw_date, 10);
hr_dm_utility.message('INFO','l_last_date - ' || l_last_date, 10);

-- have we finished a migration for the same business group, source and
-- destination databases for the same migration type since the last
-- finished FW migration?
--
-- If we are doing the first P migration then the last_migration_date
-- is null as we haven't yet migrated any participants.
  IF (r_migration_data.migration_type = 'P') THEN
    l_last_migration_date := NULL;
  ELSE
    l_last_migration_date := l_last_fw_date;
  END IF;

hr_dm_utility.message('INFO','l_last_migration_date - ' || l_last_migration_date, 10);

  l_migration_type_test := r_migration_data.migration_type;
  OPEN csr_mig_date_othr;
  FETCH csr_mig_date_othr INTO l_last_date;
  IF (NVL(l_last_date, hr_general.start_of_time) >
      NVL(l_last_migration_date, hr_general.start_of_time)) THEN
    l_last_migration_date := l_last_date;
  END IF;
  CLOSE csr_mig_date_othr;

hr_dm_utility.message('INFO','l_last_migration_date - ' || l_last_migration_date, 10);


END IF;


hr_dm_utility.message('INFO','Found last migration date', 15);
hr_dm_utility.message('SUMM','Found last migration date', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_business.last_migration_date', 25);
hr_dm_utility.message('PARA','(l_last_migration_date - ' ||
                              l_last_migration_date || ')', 30);



RETURN(l_last_migration_date);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.last_migration_date','(none)',
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
                                             hr_dm_utility.r_migration_rec)
  RETURN VARCHAR2 IS
--

l_valid VARCHAR2(1);
l_warning VARCHAR2(1);
l_source_instance VARCHAR2(30);
l_destination_instance VARCHAR2(30);

CURSOR csr_mig_info IS
  SELECT source_database_instance, destination_database_instance
    FROM hr_dm_migrations
    WHERE (migration_id = r_migration_data.migration_id);


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_business.validate_migration', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);


-- assume that migration is valid - then test to see if there are problems
l_valid := 'V';
l_warning := 'N';

-- validate business rules, as per DM LLD
-- get the details of the current migration
OPEN csr_mig_info;
LOOP
  FETCH csr_mig_info INTO l_source_instance,
                          l_destination_instance;
  EXIT WHEN csr_mig_info%NOTFOUND;
END LOOP;
CLOSE csr_mig_info;

-- source business rules
--   implemented in code
--   and applicable to main controller

IF (r_migration_data.database_location = 'S') THEN
  rule_1_source(r_migration_data, l_valid, l_warning);
  rule_2_source(r_migration_data, l_valid, l_warning);
  rule_8_source(r_migration_data, l_valid, l_warning);
  rule_9_source(r_migration_data, l_valid, l_warning);
  rule_10_source(r_migration_data, l_valid, l_warning);
END IF;

IF (r_migration_data.database_location = 'D') THEN
  rule_1_dest(r_migration_data, l_valid, l_warning);
  rule_2_dest(r_migration_data, l_valid, l_warning);
  rule_6_dest(r_migration_data, l_valid, l_warning);
  rule_7_dest(r_migration_data, l_valid, l_warning);
  rule_8_dest(r_migration_data, l_valid, l_warning);
  rule_9_dest(r_migration_data, l_valid, l_warning);
END IF;



-- if valid but a warning has been found, show warning
IF (l_valid = 'Y' AND l_warning = 'V') THEN
  l_valid := 'W';
END IF;

hr_dm_utility.message('INFO','Validated migration', 215);
hr_dm_utility.message('SUMM','Validated migration', 220);
hr_dm_utility.message('ROUT','exit:hr_dm_business.validate_migration', 225);
hr_dm_utility.message('PARA','(l_valid - ' || l_valid || ')', 230);


-- overide
-- uncomment to turn off business rule validation for testing purposes
--l_valid := 'V';


RETURN(l_valid);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_business.validate_migration',
                      '(none)','R');
  RAISE;

--
END validate_migration;
--




END hr_dm_business;

/
