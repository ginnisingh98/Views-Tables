--------------------------------------------------------
--  DDL for Package Body BEN_DM_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_INIT" AS
/* $Header: benfdmdini.pkb 120.0 2006/06/13 14:56:19 nkkrishn noship $ */

-- ------------------------- populate_pi_table_i ------------------------
-- Description: The phase items for the initialization phase are seeded
-- into the hr_dm_phase_items. (currently none required)
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
-- ------------------------------------------------------------------------
--
PROCEDURE populate_pi_table_i(r_migration_data IN
                                         ben_dm_utility.r_migration_rec) IS
--

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.populate_pi_table_i', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);

--
-- phase specific code to be inserted here
--
-- no code required
--

ben_dm_utility.message('INFO','Populate Phase Items table - I phase', 15);
ben_dm_utility.message('SUMM','Populate Phase Items table - I phase', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_init.populate_pi_table_i', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.populate_pi_table_i','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_i;
--

-- ------------------------- populate_pi_table_g ------------------------
-- Description: The phase items for the generator phase are seeded
-- into the ben_dm_phase_items.
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
-- ------------------------------------------------------------------------

--
PROCEDURE populate_pi_table_g(r_migration_data IN
                                          ben_dm_utility.r_migration_rec) IS
--

l_phase_id NUMBER;
l_loader_name VARCHAR2(30);
l_group_id NUMBER;
l_table_name VARCHAR2(30);
l_generator_version VARCHAR2(2000);
l_status    varchar2(50);
l_industry  varchar2(50);
l_per_owner     varchar2(30);
l_ben_owner     varchar2(30);
l_pay_owner     varchar2(30);
l_ff_owner     varchar2(30);
l_fnd_owner     varchar2(30);
l_apps_owner     varchar2(30);

l_ret1      boolean := FND_INSTALLATION.GET_APP_INFO ('PAY', l_status,
                                                      l_industry, l_pay_owner);
l_ret2      boolean := FND_INSTALLATION.GET_APP_INFO ('BEN', l_status,
                                                      l_industry, l_ben_owner);
l_ret3      boolean := FND_INSTALLATION.GET_APP_INFO ('FF', l_status,
                                                      l_industry, l_ff_owner);
l_ret5      boolean := FND_INSTALLATION.GET_APP_INFO ('PER', l_status,
                                                      l_industry, l_per_owner);
l_ret6      boolean := FND_INSTALLATION.GET_APP_INFO ('APPS', l_status,
                                                      l_industry, l_apps_owner);

-- select tables for generating where
-- 1. generator not yet run (last_generated_date is null)  OR
-- 2. table updated since last run (last_ddl_time >= last_generated_date) OR
-- 3. generator updated (generator_version(table) <>
--                                           generator version(generator))
-- 4. row in hr_dm_tables has been updated since the last generation
--    (last_update_date > last_generated_date)

CURSOR csr_select_pi IS
  SELECT DISTINCT tbl.table_name
    FROM ben_dm_tables tbl, ben_dm_table_order tbo,
         all_objects obj
    WHERE (tbo.table_id = tbl.table_id)
      AND (obj.object_name = tbl.table_name)
      AND (obj.object_type = 'TABLE')
      AND obj.owner in
          (l_apps_owner,
           l_ff_owner,
           l_ben_owner,
           l_pay_owner,
           l_per_owner);
--      AND (
--           (obj.last_ddl_time >= NVL(tbl.last_generated_date,
--                                     obj.last_ddl_time))
--        OR (l_generator_version <> NVL(tbl.generator_version,
--                                       'none'))
--       OR (tbl.last_update_date > NVL(tbl.last_generated_date,
--                                    tbl.last_update_date))
--         );

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.populate_pi_table_g', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);

-- get phase id
l_phase_id := ben_dm_utility.get_phase_id('G',
                                         r_migration_data.migration_id);

-- read generator version (Tilak)
-- hr_dm_library.get_generator_version(p_generator_version =>
--                                     l_generator_version);

OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_table_name;
  EXIT WHEN csr_select_pi%NOTFOUND;

  INSERT INTO ben_dm_phase_items (PHASE_ITEM_ID,
                                 PHASE_ID,
                                 GROUP_ORDER,
                                 TABLE_NAME,
                                 STATUS,
                                 START_TIME,
                                 END_TIME,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
    SELECT ben_dm_phase_items_s.nextval,
           l_phase_id,
           NULL,
           l_table_name,
           'NS',
           NULL,
           NULL,
           1,
           SYSDATE,
           1,
           SYSDATE,
           NULL
      FROM dual
      WHERE NOT EXISTS
        (SELECT NULL FROM ben_dm_phase_items
          WHERE ((phase_id = l_phase_id)
            AND (table_name = l_table_name)));

  COMMIT;

  ben_dm_utility.message('INFO','Seeding ' || l_table_name, 11);

END LOOP;
CLOSE csr_select_pi;

ben_dm_utility.message('INFO','Populate Phase Items table - G phase', 15);
ben_dm_utility.message('SUMM','Populate Phase Items table - G phase', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_init.populate_pi_table_g', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.populate_pi_table_g','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_g;
--
--
-- ------------------------- populate_pi_table_dp ------------------------
-- Description: The phase items for the download phase are seeded
-- into the ben_dm_phase_items. An entry is made for each group that is
-- applicable for the current migration.
--
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
-- ------------------------------------------------------------------------


--
PROCEDURE populate_pi_table_dp(r_migration_data IN
                                        ben_dm_utility.r_migration_rec) IS
--

--

l_phase_id NUMBER;
l_group_order NUMBER;
l_input_file_id NUMBER;

CURSOR csr_select_pi IS
  SELECT input_file_id, group_order
    FROM ben_dm_input_file
    ORDER BY group_order asc;

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.populate_pi_table_dp', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id := ben_dm_utility.get_phase_id('DP',
                                         r_migration_data.migration_id);


OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_input_file_id, l_group_order;
  EXIT WHEN csr_select_pi%NOTFOUND;

  INSERT INTO ben_dm_phase_items (PHASE_ITEM_ID,
                                 PHASE_ID,
                                 GROUP_ORDER,
                                 TABLE_NAME,
                                 INPUT_FILE_ID,
                                 STATUS,
                                 START_TIME,
                                 END_TIME,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
    SELECT ben_dm_phase_items_s.nextval,
           l_phase_id,
           l_group_order,
           NULL,
           l_input_file_id,
           'NS',
           NULL,
           NULL,
           1,
           SYSDATE,
           1,
           SYSDATE,
           NULL
      FROM dual
      WHERE NOT EXISTS
        (SELECT NULL FROM ben_dm_phase_items
          WHERE ((phase_id = l_phase_id)
            AND (input_file_id = l_input_file_id)));

  COMMIT;

  ben_dm_utility.message('INFO','Seeding ' || l_input_file_id, 11);


END LOOP;
CLOSE csr_select_pi;


ben_dm_utility.message('INFO','Populate Phase Items table - DP phase', 15);
ben_dm_utility.message('SUMM','Populate Phase Items table - DP phase', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_init.populate_pi_table_dp', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.populate_pi_table_dp','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_dp;
--

-- ------------------------- populate_pi_table_up ------------------------
-- Description: The phase items for the upload phase are seeded
-- into the ben_dm_phase_items. An entry is made for each group that is
-- applicable for the current migration.
--
--  Input Parameters
--        r_migration_data - record containing migration information
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------



--
PROCEDURE populate_pi_table_up(r_migration_data IN
                                          ben_dm_utility.r_migration_rec) IS
--

l_phase_id NUMBER;
l_group_order NUMBER;

CURSOR csr_select_pi IS
  SELECT distinct group_order
    FROM ben_dm_input_file
--    WHERE migration_id = r_migration_data.migration_id
    ORDER BY group_order asc;

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.populate_pi_table_up', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id := ben_dm_utility.get_phase_id('UP',
                                         r_migration_data.migration_id);

OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_group_order;
  EXIT WHEN csr_select_pi%NOTFOUND;

  INSERT INTO ben_dm_phase_items (PHASE_ITEM_ID,
                                 PHASE_ID,
                                 GROUP_ORDER,
                                 TABLE_NAME,
                                 STATUS,
                                 START_TIME,
                                 END_TIME,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
    SELECT ben_dm_phase_items_s.nextval,
           l_phase_id,
           l_group_order,
           NULL,
           'NS',
           NULL,
           NULL,
           1,
           SYSDATE,
           1,
           SYSDATE,
           NULL
      FROM dual
      WHERE NOT EXISTS
        (SELECT NULL FROM ben_dm_phase_items
          WHERE ((phase_id = l_phase_id)
            AND (group_order = l_group_order)));

      COMMIT;

      ben_dm_utility.message('INFO','Seeding ' || l_group_order, 11);

END LOOP;
CLOSE csr_select_pi;

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.populate_pi_table_up','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_up;
--
-- ------------------------- populate_pi_table ------------------------
-- Description: The code to populate the current phase is called.
--
--
--  Input Parameters
--        r_migration_data - record containing migration information
--
--        p_phase_name     - phase code
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------


--
PROCEDURE populate_pi_table(r_migration_data IN
                                           ben_dm_utility.r_migration_rec,
                            p_phase_name IN VARCHAR2) IS
--

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.populate_pi_table', 5);
ben_dm_utility.message('PARA','(r_migration_data - record' ||
                  ')(p_phase_name - ' || p_phase_name || ')', 10);

IF (p_phase_name = 'I') THEN
  populate_pi_table_i(r_migration_data);
ELSIF (p_phase_name = 'G') THEN
  populate_pi_table_g(r_migration_data);
ELSIF (p_phase_name = 'DP') THEN
  populate_pi_table_dp(r_migration_data);
ELSIF (p_phase_name = 'UP') THEN
  populate_pi_table_up(r_migration_data);
END IF;

ben_dm_utility.message('INFO','Populate Phase Items table -' ||
                      ' calling phase code', 15);
ben_dm_utility.message('SUMM','Populate Phase Items table -' ||
                      ' calling phase code', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_init.populate_pi_table', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.populate_pi_table','(none)','R');
  RAISE;

--
END populate_pi_table;
--


-- ------------------------- populate_phase_items ------------------------
-- Description: The phases applicable to the current migration and the
-- database location (ie source / destination) are populated by calling
-- populate_pi_table.
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
-- ------------------------------------------------------------------------

--
PROCEDURE populate_phase_items(r_migration_data IN
                                           ben_dm_utility.r_migration_rec) IS

--

l_search_phase VARCHAR2(30);
l_phase_name VARCHAR2(30);
l_previous_phase VARCHAR2(30);
l_next_phase VARCHAR2(30);
l_database_location VARCHAR2(30);

CURSOR csr_phase_rule IS
  SELECT phase_name, previous_phase, next_phase, database_location
    FROM hr_dm_phase_rules
    WHERE ((migration_type = 'SP')
      AND (previous_phase = l_search_phase))
      AND database_location =  r_migration_data.database_location;
--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.populate_phase_items', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);

-- seed first phase
l_search_phase := 'START';
l_next_phase := '?';

WHILE (l_next_phase <> 'END') LOOP
  OPEN csr_phase_rule;
  FETCH csr_phase_rule INTO l_phase_name, l_previous_phase,
                            l_next_phase, l_database_location;
-- add check to exit if table is not seed/problem
  EXIT WHEN csr_phase_rule%NOTFOUND;

-- does it apply?
  IF (INSTR(l_database_location, r_migration_data.database_location) >0) THEN
    populate_pi_table(r_migration_data, l_phase_name);
  END IF;
  l_search_phase := l_phase_name;
  CLOSE csr_phase_rule;
END LOOP;
ben_dm_utility.message('INFO','Populate Phase Items table', 15);
ben_dm_utility.message('SUMM','Populate Phase Items table', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_init.populate_phase_items', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.populate_phase_items',
                      '(none)','R');
  RAISE;

--
END populate_phase_items;
--

-- ------------------------- populate_p_table ----------------------
-- Description: The phases applicable to the current migration and the
-- database location (ie source / destination) are seeded into the
-- hr_dm_phases table.
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
-- ------------------------------------------------------------------------

--
PROCEDURE populate_p_table(r_migration_data IN ben_dm_utility.r_migration_rec,
                           p_phase_name IN VARCHAR2) IS
--

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.populate_p_table', 5);
ben_dm_utility.message('PARA','(r_migration_data - record' ||
                      ')(p_phase_name - ' || p_phase_name || ')', 10);

INSERT INTO ben_dm_phases (PHASE_ID,
                          MIGRATION_ID,
                          PHASE_NAME,
                          STATUS,
                          START_TIME,
                          END_TIME,
                          CREATED_BY,
                          CREATION_DATE,
                          LAST_UPDATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATE_LOGIN)
  SELECT ben_dm_phases_s.nextval,
         r_migration_data.migration_id,
         p_phase_name,
         'NS',
         NULL,
         NULL,
         1,
         SYSDATE,
         1,
         SYSDATE,
         NULL
    FROM dual
    WHERE NOT EXISTS
      (SELECT NULL FROM ben_dm_phases
        WHERE ((migration_id = r_migration_data.migration_id)
          AND (phase_name = p_phase_name)));

COMMIT;

ben_dm_utility.message('INFO','Populate Phases table', 15);
ben_dm_utility.message('SUMM','Populate Phases table', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_init.populate_p_table', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.populate_p_table','(none)','R');
  RAISE;

--
END populate_p_table;
--


-- ------------------------- populate_populate_phases ----------------------
-- Description: The phases applicable to the current migration and the
-- database location (ie source / destination) are populated by calling
-- populate_p_table.
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
-- ------------------------------------------------------------------------

--
PROCEDURE populate_phases(r_migration_data IN
                                       ben_dm_utility.r_migration_rec) IS
--

l_phase_name VARCHAR2(30);
l_database_location VARCHAR2(30);

CURSOR csr_phase_rule IS
  SELECT phase_name, database_location
    FROM hr_dm_phase_rules
    WHERE ((migration_type = 'SP')
 AND database_location =  r_migration_data.database_location);
--    AND (INSTR(database_location,
--                 r_migration_data.database_location) >0));

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.populate_phases', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);


OPEN csr_phase_rule;
LOOP
  FETCH csr_phase_rule INTO l_phase_name, l_database_location;
  EXIT WHEN csr_phase_rule%NOTFOUND;
  populate_p_table(r_migration_data, l_phase_name);
END LOOP;
CLOSE csr_phase_rule;

ben_dm_utility.message('INFO','Populate Phase Items table', 15);
ben_dm_utility.message('SUMM','Populate Phase Items table', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_init.populate_phases', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.populate_phases','(none)','R');
  RAISE;

--
END populate_phases;
--




/*-------------------------- PUBLIC ROUTINES ---------------------------*/

-- ------------------------- main ----------------------
-- Description: The phases and associated phase items that are applicable
-- to the current migration and the database location (ie source /
-- destination) are seeded.
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
-- ------------------------------------------------------------------------
--
PROCEDURE main(r_migration_data IN ben_dm_utility.r_migration_rec) IS
--

l_current_phase_status VARCHAR2(30);

--
BEGIN
--

ben_dm_utility.message('ROUT','entry:ben_dm_init.main', 5);
ben_dm_utility.message('PARA','(r_migration_data - record)', 10);


-- get status of initialization phase, is phase completed?
-- if null returned, then assume it is NS.
l_current_phase_status := NVL(ben_dm_utility.get_phase_status('I',
                              r_migration_data.migration_id), 'NS');

-- is phase complete?
-- if so, skip all processing
IF (l_current_phase_status <> 'C') THEN
-- do we need to explicitly rollback using rollback utility?
  IF (l_current_phase_status IN('S', 'E')) THEN
    ben_dm_utility.rollback(p_phase => 'I',
                           p_migration_id => r_migration_data.migration_id);
  END IF;

-- populate phases table
  populate_phases(r_migration_data);


-- update status to started
  ben_dm_utility.update_phases(p_new_status => 'S',
                              p_id => ben_dm_utility.get_phase_id('I',
                              r_migration_data.migration_id));

-- populate phase_items table
  populate_phase_items(r_migration_data);

-- delete the contents of hr_dm_exp_imps table
-- if we are on the source database only
IF (r_migration_data.database_location = 'S') THEN
  DELETE ben_dm_entity_results;
  COMMIT;
END IF;

-- update status to completed
  ben_dm_utility.update_phases(p_new_status => 'C',
                              p_id => ben_dm_utility.get_phase_id('I',
                              r_migration_data.migration_id));

END IF;

ben_dm_utility.message('INFO','Initialization Phase', 15);
ben_dm_utility.message('SUMM','Initialization Phase', 20);
ben_dm_utility.message('ROUT','exit:ben_dm_init.main', 25);
ben_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  ben_dm_utility.error(SQLCODE,'ben_dm_init.main','(none)','R');
  RAISE;

--
END main;
--

END ben_dm_init;

/
