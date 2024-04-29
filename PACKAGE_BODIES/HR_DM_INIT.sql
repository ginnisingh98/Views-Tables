--------------------------------------------------------
--  DDL for Package Body HR_DM_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_INIT" AS
/* $Header: perdmini.pkb 115.19 2004/03/24 08:29:10 mmudigon ship $ */

-- ------------------------- check_custom_flex ------------------------
-- Description: Check if custom flex code use is enabled. This is determined
-- from the table pay_action_parameters, using a parameter name of
-- HR_DM_CUSTOM_AOL_CODE.
--
--  Input Parameters
--        <none>
--
--
--  Output Parameters
--        parameter value if one exists, otherwise null
--
--
-- ------------------------------------------------------------------------

--
FUNCTION check_custom_flex RETURN VARCHAR2 IS
--
CURSOR csr_value IS
  SELECT UPPER(parameter_value)
    FROM pay_action_parameters
    WHERE parameter_name = 'HR_DM_CUSTOM_AOL_CODE';

l_retval VARCHAR2(80) := NULL;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.check_custom_flex', 5);
hr_dm_utility.message('PARA','(none)', 10);

-- read values from pay_action_parameters

OPEN csr_value;
LOOP
  FETCH csr_value INTO l_retval;
  EXIT WHEN csr_value%NOTFOUND;
END LOOP;
CLOSE csr_value;

-- looking for a Y, otherwise return null
IF l_retval <> 'Y' THEN
  l_retval := NULL;
END IF;


hr_dm_utility.message('INFO','Checked custom flex setting', 15);
hr_dm_utility.message('SUMM','Checked custom flex setting', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.check_custom_flex', 25);
hr_dm_utility.message('PARA','(l_retval - ' || l_retval || ')', 30);


RETURN(l_retval);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.check_custom_flex','(none)','R');
  RAISE;

--
END check_custom_flex;
--



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
                                         hr_dm_utility.r_migration_rec) IS
--

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_i', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

--
-- phase specific code to be inserted here
--
-- no code required
--

hr_dm_utility.message('INFO','Populate Phase Items table - I phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - I phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_i', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_i','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_i;
--

-- ------------------------- populate_pi_table_g ------------------------
-- Description: The phase items for the generator phase are seeded
-- into the hr_dm_phase_items.
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
                                          hr_dm_utility.r_migration_rec) IS
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
l_ret4      boolean := FND_INSTALLATION.GET_APP_INFO ('FND', l_status,
                                                      l_industry, l_fnd_owner);
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
  SELECT DISTINCT tbl.loader_name, tbg.group_id, tbl.table_name
    FROM hr_dm_tables tbl, hr_dm_table_groupings tbg,
         all_objects obj, hr_dm_application_groups app,
         hr_dm_migrations mig
    WHERE (tbl.table_id = tbg.table_id)
      AND (app.group_id = tbg.group_id)
      AND (mig.application_id = app.application_id)
      AND (mig.migration_id = r_migration_data.migration_id)
      AND (obj.object_name = tbl.table_name)
      AND (obj.object_type = 'TABLE')
      AND obj.owner in
          (l_apps_owner,
           l_fnd_owner,
           l_ff_owner,
           l_ben_owner,
           l_pay_owner,
           l_per_owner)
      AND (
           (obj.last_ddl_time >= NVL(tbl.last_generated_date,
                                     obj.last_ddl_time))
        OR (l_generator_version <> NVL(tbl.generator_version,
                                       'none'))
        OR (tbl.last_update_date > NVL(tbl.last_generated_date,
                                    tbl.last_update_date))
          )
  UNION
  SELECT DISTINCT tbl.loader_name, tbg.group_id, tbl.table_name
    FROM hr_dm_tables tbl, hr_dm_table_groupings tbg,
         all_objects obj, hr_dm_application_groups app,
         hr_dm_migrations mig
    WHERE (tbl.table_id = tbg.table_id)
      AND (app.group_id = tbg.group_id)
      AND (mig.application_id = app.application_id)
      AND (mig.migration_id = r_migration_data.migration_id)
      AND (obj.object_name = tbl.upload_table_name)
      AND (obj.object_type = 'TABLE')
      AND obj.owner in
          (l_apps_owner,
           l_fnd_owner,
           l_ff_owner,
           l_ben_owner,
           l_pay_owner,
           l_per_owner)
      AND (
           (obj.last_ddl_time >= NVL(tbl.last_generated_date,
                                     obj.last_ddl_time))
        OR (l_generator_version <> NVL(tbl.generator_version,
                                       'none'))
        OR (tbl.last_update_date > NVL(tbl.last_generated_date,
                                    tbl.last_update_date))
          )
  UNION
  SELECT DISTINCT tbl.loader_name, tbg.group_id, tbl.table_name
    FROM hr_dm_tables tbl, hr_dm_table_groupings tbg,
         hr_dm_application_groups app,
         hr_dm_migrations mig
    WHERE (tbl.table_id = tbg.table_id)
      AND (app.group_id = tbg.group_id)
      AND (mig.application_id = app.application_id)
      AND (mig.migration_id = r_migration_data.migration_id)
      AND (tbl.table_name like 'HR_DMVP%')
      AND (tbl.upload_table_name IS NULL);



--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_g', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

-- get phase id
l_phase_id := hr_dm_utility.get_phase_id('G',
                                         r_migration_data.migration_id);

-- read generator version
hr_dm_library.get_generator_version(p_generator_version =>
                                    l_generator_version);

-- we always want to generate for ff_formulas_f
UPDATE hr_dm_tables
  SET last_generated_date = NULL
  WHERE table_name = 'FF_FORMULAS_F'
    OR table_name LIKE 'HR_DMV%';
COMMIT;


OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_loader_name, l_group_id, l_table_name;
  EXIT WHEN csr_select_pi%NOTFOUND;

  INSERT INTO hr_dm_phase_items (PHASE_ITEM_ID,
                                 PHASE_ID,
                                 LOADER_NAME,
                                 BATCH_ID,
                                 GROUP_ID,
                                 TABLE_NAME,
                                 STATUS,
                                 START_TIME,
                                 END_TIME,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
    SELECT hr_dm_phase_items_s.nextval,
           l_phase_id,
           l_loader_name,
           NULL,
           l_group_id,
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
        (SELECT NULL FROM hr_dm_phase_items
          WHERE ((phase_id = l_phase_id)
            AND (table_name = l_table_name)));

  COMMIT;

  hr_dm_utility.message('INFO','Seeding ' || l_table_name, 11);

END LOOP;
CLOSE csr_select_pi;


hr_dm_utility.message('INFO','Populate Phase Items table - G phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - G phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_g', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_g','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_g;
--


-- ------------------------- populate_pi_table_r ------------------------
-- Description: The phase items for the range phase are seeded
-- into the hr_dm_phase_items. An entry is made for each table within
-- a group that is applicable for the current migration.
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
PROCEDURE populate_pi_table_r(r_migration_data IN
                                       hr_dm_utility.r_migration_rec) IS
--

l_phase_id NUMBER;
l_group_id NUMBER;
l_table_name VARCHAR2(30);

CURSOR csr_select_pi IS
  SELECT tbg.group_id, tbl.table_name
    FROM hr_dm_tables tbl, hr_dm_table_groupings tbg,
         hr_dm_groups grp, hr_dm_application_groups apg
    WHERE ( (tbl.table_id = tbg.table_id)
     AND (tbg.group_id = grp.group_id)
     AND (grp.group_type = 'D')
     AND (grp.group_id = apg.group_id)
     AND (apg.application_id = r_migration_data.application_id)
     AND (apg.migration_type = r_migration_data.migration_type) );

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_r', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id := hr_dm_utility.get_phase_id('R',
                                         r_migration_data.migration_id);

OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_group_id, l_table_name;
  EXIT WHEN csr_select_pi%NOTFOUND;

  INSERT INTO hr_dm_phase_items (PHASE_ITEM_ID,
                                 PHASE_ID,
                                 LOADER_NAME,
                                 BATCH_ID,
                                 GROUP_ID,
                                 TABLE_NAME,
                                 STATUS,
                                 START_TIME,
                                 END_TIME,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
    SELECT hr_dm_phase_items_s.nextval,
           l_phase_id,
           NULL,
           NULL,
           l_group_id,
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
        (SELECT NULL FROM hr_dm_phase_items
          WHERE ((phase_id = l_phase_id)
            AND (table_name = l_table_name)));

    COMMIT;

    hr_dm_utility.message('INFO','Seeding ' || l_table_name, 11);

END LOOP;
CLOSE csr_select_pi;

hr_dm_utility.message('INFO','Populate Phase Items table - R phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - R phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_r', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_r','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_r;
--


-- ----------------------------- get_filename -----------------------------
-- Description: Generates a filename for the AOL loader to download into
-- based on the last 5 digits (0 padded) of the phase_item_id
--
--
--  Input Parameters
--        p_phase_item_id       phase item id from the DA phase
--        p_loader_conc_program to determine file extension
--
--
--  Output Parameters
--        created filename
--
--
-- ------------------------------------------------------------------------

--
FUNCTION get_filename (p_phase_item_id NUMBER,
                       p_loader_conc_program VARCHAR2)
    RETURN VARCHAR2 IS
--

l_filename VARCHAR2(11);
l_length NUMBER;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.get_filename', 5);
hr_dm_utility.message('PARA','(p_phase_item_id - ' || p_phase_item_id ||
                      ')(p_loader_conc_program - ' || p_loader_conc_program ||
                      ')', 10);

l_length := length(to_char(p_phase_item_id));

IF l_length > 5 THEN
  l_filename := substrb(to_char(p_phase_item_id),
                        lengthb(to_char(p_phase_item_id))-4);
ELSE
  l_filename := lpad(to_char(p_phase_item_id),5,'0');
END IF;

IF (p_loader_conc_program = 'FNDSLOAD') THEN
  l_filename := 'DM' || l_filename || '.slt';
ELSE
  l_filename := 'DM' || l_filename || '.ldt';
END IF;

hr_dm_utility.message('INFO','Generated filename', 15);
hr_dm_utility.message('SUMM','Generated filename', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.get_filename', 25);
hr_dm_utility.message('PARA','(l_filename - ' || l_filename || ')', 30);


RETURN(l_filename);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.get_filename','(none)','R');
  RAISE;

--
END get_filename;
--

-- --------------------------- seed_ua_da_data ---------------------------
-- Description: Seeds the passed data into the hr_dm_phase_items and the
-- hr_dm_loader_phase_items tables
--
--
--  Input Parameters
--        p_param_rec               data record
--        p_custom_code_specified   Y if custom code specified
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE seed_ua_da_data (p_param_rec r_loader_param_rec,
                           p_custom_code_specified VARCHAR2,
                           p_phase_id_da NUMBER,
                           p_phase_id_ua NUMBER) IS
--

l_phase_item_id_ua NUMBER;
l_phase_item_id_da NUMBER;
l_filename VARCHAR2(11);

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.seed_ua_da_data', 5);
hr_dm_utility.message('PARA','(p_param_rec - record)', 10);

hr_dm_utility.message('INFO','Seeding ' || p_param_rec.loader_name , 10);

-- get phase_item_ids for ua and da phases
SELECT HR_DM_PHASE_ITEMS_S.nextval
  INTO l_phase_item_id_da
  FROM dual;
SELECT HR_DM_PHASE_ITEMS_S.nextval
  INTO l_phase_item_id_ua
  FROM dual;
   -- hr_dm_phase_items da phase
INSERT INTO hr_dm_phase_items (PHASE_ITEM_ID,
                               PHASE_ID,
                               LOADER_NAME,
                               LOADER_PARAMS_ID,
                               BATCH_ID,
                               GROUP_ID,
                               TABLE_NAME,
                               STATUS,
                               START_TIME,
                               END_TIME)
  SELECT l_phase_item_id_da,
         p_phase_id_da,
         p_param_rec.loader_name,
         p_param_rec.loader_params_id,
         NULL,
         p_param_rec.group_id,
         NULL,
         'NS',
         NULL,
         NULL
    FROM dual;
   -- hr_dm_phase_items da phase
INSERT INTO hr_dm_phase_items (PHASE_ITEM_ID,
                               PHASE_ID,
                               LOADER_NAME,
                               LOADER_PARAMS_ID,
                               BATCH_ID,
                               GROUP_ID,
                               TABLE_NAME,
                               STATUS,
                               START_TIME,
                               END_TIME)
  SELECT l_phase_item_id_ua,
         p_phase_id_ua,
         p_param_rec.loader_name,
         p_param_rec.loader_params_id,
         NULL,
         p_param_rec.group_id,
         NULL,
         'NS',
         NULL,
         NULL
    FROM dual;

-- generate filename
l_filename := get_filename(l_phase_item_id_da,
                           p_param_rec.loader_conc_program);

-- hr_dm_loader_phase_items
INSERT INTO hr_dm_loader_phase_items (
      loader_phase_item_id,
      da_phase_item_id,
      ua_phase_item_id,
      loader_name,
      loader_conc_program,
      loader_config_file,
      loader_application,
      application_id,
      filename,
      parameter_1,
      parameter_2,
      parameter_3,
      parameter_4,
      parameter_5,
      parameter_6,
      parameter_7,
      parameter_8,
      parameter_9,
      parameter_10,
      custom_code_specified)
  SELECT
      hr_dm_loader_phase_items_s.nextval,
      l_phase_item_id_da,
      l_phase_item_id_ua,
      p_param_rec.loader_name,
      p_param_rec.loader_conc_program,
      p_param_rec.loader_config_file,
      p_param_rec.loader_application,
      p_param_rec.application_id,
      l_filename,
      p_param_rec.parameter1,
      p_param_rec.parameter2,
      p_param_rec.parameter3,
      p_param_rec.parameter4,
      p_param_rec.parameter5,
      p_param_rec.parameter6,
      p_param_rec.parameter7,
      p_param_rec.parameter8,
      p_param_rec.parameter9,
      p_param_rec.parameter10,
      p_custom_code_specified
      FROM dual;

COMMIT;

hr_dm_utility.message('INFO','Seeded UA/DA phase item', 15);
hr_dm_utility.message('SUMM','Seeded UA/DA phase item', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.seed_ua_da_data', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.seed_ua_da_data','(none)','R');
  RAISE;

--
END seed_ua_da_data;
--

-- ----------------------------- custom_specified -----------------------------
-- Description: Calls the custom code to determine if a flexfield is
-- to be migrated.
--
--  Input Parameters
--        p_phase_item_id       phase item id from the DA phase
--        p_loader_conc_program to determine file extension
--
--
--  Output Parameters
--        created filename
--
--
-- ------------------------------------------------------------------------

--
FUNCTION custom_specified(p_check_custom_flex_call VARCHAR2,
                          r_migration_data hr_dm_utility.r_migration_rec,
                          r_flexfield_rec r_flexfield_rec)
    RETURN BOOLEAN IS
--

l_retval BOOLEAN := FALSE;
l_message VARCHAR2(200);

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.custom_specified', 5);
hr_dm_utility.message('PARA','(p_check_custom_flex_call - ' ||
                               p_check_custom_flex_call ||
                      ')(r_migration_data - record)' ||
                      '(r_flexfield_rec - record)', 10);

hr_dm_utility.message('INFO','Calling hr_dm_aol_ext.custom_test', 15);


IF r_flexfield_rec.flexfield_type = 'D' THEN
  l_message := '(descriptive_flexfield_name =' ||
               r_flexfield_rec.descriptive_flexfield_name ||
               ')(descriptive_flex_context_code =' ||
               r_flexfield_rec.descriptive_flex_context_code || ')';
ELSE
  l_message := '(id_flex_code =' ||
               r_flexfield_rec.id_flex_code ||
               ')(id_flex_structure_codee =' ||
               r_flexfield_rec.id_flex_structure_code || ')';
END IF;

hr_dm_utility.message('INFO',l_message,12);

-- call test code directly

l_retval := hr_dm_aol_ext.custom_test(r_migration_data,
                                      r_flexfield_rec);

IF l_retval THEN
  hr_dm_utility.message('INFO','Custom code requests download of ' ||
                        l_message, 30);
ELSE
  hr_dm_utility.message('INFO','Custom code does not request download of ' ||
                        l_message, 30);
END IF;


hr_dm_utility.message('INFO','Checked custom flex', 15);
hr_dm_utility.message('SUMM','Checked custom flex', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.custom_specified', 25);
IF l_retval THEN
  hr_dm_utility.message('PARA','(l_retval - TRUE)', 30);
ELSE
  hr_dm_utility.message('PARA','(l_retval - FALSE)', 30);
END IF;

RETURN(l_retval);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.custom_specified','(none)','R');
  RAISE;

--
END custom_specified;
--

-- --------------------------- seed_data ---------------------------
-- Description: Seeds the custom specified flexfield data
--
--
--  Input Parameters
--        p_param_rec               data record
--        p_custom_code_specified   Y if custom code specified
--
--
--  Output Parameters
--        <none>
--
--
-- ------------------------------------------------------------------------

--
PROCEDURE seed_data (r_migration_data IN hr_dm_utility.r_migration_rec,
                     r_flexfield_data IN r_flexfield_rec,
                     p_phase_id_da IN NUMBER,
                     p_phase_id_ua IN NUMBER) IS
--

l_param_rec r_loader_param_rec;
l_app_short_name VARCHAR2(50);

CURSOR csr_loader_info IS
  SELECT tbl.loader_conc_program,
         tbl.loader_config_file,
         tbl.loader_application,
         grp.group_id
    FROM hr_dm_groups grp,
         hr_dm_application_groups apg,
         hr_dm_table_groupings tbg,
         hr_dm_tables tbl
    WHERE tbl.table_id = tbg.table_id
      AND tbg.group_id = grp.group_id
      AND grp.group_type = 'A'
      AND grp.group_id = apg.group_id
      AND apg.application_id = r_migration_data.application_id
      AND apg.migration_type = r_migration_data.migration_type
      AND tbl.loader_name = l_param_rec.loader_name;

CURSOR csr_app_id IS
  SELECT application_short_name
    FROM fnd_application
    WHERE application_id = r_flexfield_data.application_id;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.seed_data', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)' ||
                             '(r_flexfield_data - record)' ||
                             '(p_phase_id_da - ' || p_phase_id_da ||
                             ')(p_phase_id_ua - ' || p_phase_id_ua ||
                             ')', 10);


-- build up r_loader_param_rec record

l_param_rec.loader_params_id := NULL;
l_param_rec.application_id   := r_migration_data.application_id;
l_param_rec.parameter1       := ':mode';
l_param_rec.parameter2       := ':config';
l_param_rec.parameter3       := ':data';

-- Find the flexfield application short name

OPEN csr_app_id;
FETCH csr_app_id INTO l_app_short_name;
CLOSE csr_app_id;

hr_dm_utility.message('INFO','r_flexfield_data.flexfield_type - ' ||
                              r_flexfield_data.flexfield_type,1);

IF r_flexfield_data.flexfield_type = 'K' THEN
  -- key flexfield data
  l_param_rec.parameter4  := 'KEY_FLEX';
  l_param_rec.parameter5  := 'APPLICATION_SHORT_NAME=' ||
                             l_app_short_name;
  l_param_rec.parameter6  := 'ID_FLEX_CODE=' ||
                             r_flexfield_data.id_flex_code;
  l_param_rec.parameter7  := 'P_LEVEL=''COL_ALL:FQL_ALL:SQL_ALL:STR_ONE:' ||
                             'WFP_ALL:SHA_ALL:CVR_ALL:SEG_ALL''';
  l_param_rec.parameter8  := 'P_STRUCTURE_CODE=' ||
                              r_flexfield_data.id_flex_structure_code;
  l_param_rec.parameter9  := NULL;

  l_param_rec.loader_name := 'Key flexfields';

ELSE
  -- descriptive flexfield data
  l_param_rec.parameter4  := 'DESC_FLEX';
  l_param_rec.parameter5  := 'APPLICATION_SHORT_NAME=' ||
                             l_app_short_name;
  l_param_rec.parameter6  := 'DESCRIPTIVE_FLEXFIELD_NAME=' ||
                             r_flexfield_data.descriptive_flexfield_name;
  l_param_rec.parameter7  := 'P_LEVEL=''COL_ALL:REF_ALL:CTX_ONE:SEG_ALL''';
  l_param_rec.parameter8  := 'P_CONTEXT_CODE=' ||
                             r_flexfield_data.descriptive_flex_context_code;
  l_param_rec.parameter9  := NULL;

  IF r_migration_data.migration_type = 'SD' THEN
    l_param_rec.loader_name := 'Desc flexfields (selective)';
    l_param_rec.parameter9 := ':selective';
  ELSIF r_migration_data.migration_type = 'SL' THEN
    l_param_rec.loader_name := 'Desc flexfields (lookups)';
  ELSE
    l_param_rec.loader_name := 'Descriptive flexfields';
  END IF;

END IF;

hr_dm_utility.message('INFO','l_param_rec.loader_name - ' ||
                              l_param_rec.loader_name,1);


-- null out unused entries
l_param_rec.parameter10 := NULL;

-- get loader info from hr_dm_tables
OPEN csr_loader_info;
FETCH csr_loader_info INTO l_param_rec.loader_conc_program,
                           l_param_rec.loader_config_file,
                           l_param_rec.loader_application,
                           l_param_rec.group_id;
CLOSE csr_loader_info;

-- check for FNDSLOAD and seed dummy config file
IF l_param_rec.loader_conc_program = 'FNDSLOAD' THEN
  l_param_rec.loader_config_file := 'n/a';
END IF;

-- insert data
seed_ua_da_data (l_param_rec,
                 'Y',
                 p_phase_id_da,
                 p_phase_id_ua);

hr_dm_utility.message('INFO','Seeded UA/DA phase item', 15);
hr_dm_utility.message('SUMM','Seeded UA/DA phase item', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.seed_ua_da_data', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.seed_data','(none)','R');
  RAISE;

--
END seed_data;
--


-- ------------------------- populate_pi_table_da ------------------------
-- Description: The phase items for the download aol phase are seeded
-- into the hr_dm_phase_items. An entry is made for each aol loader within
-- a group that is applicable for the current migration.
--
-- UA phase items are also seeded in this procedure.
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
PROCEDURE populate_pi_table_da(r_migration_data IN
                                         hr_dm_utility.r_migration_rec) IS
--

l_phase_id_da NUMBER;
l_phase_id_ua NUMBER;
l_check_custom_flex_call VARCHAR2(100);
l_param_rec r_loader_param_rec;
r_flexfield_data r_flexfield_rec;

CURSOR csr_select_pi IS
  SELECT tbl.loader_name,
         tbl.loader_conc_program,
         tbl.loader_config_file,
         tbl.loader_application,
         lp.loader_params_id,
         lp.application_id,
         lp.parameter1,
         lp.parameter2,
         lp.parameter3,
         lp.parameter4,
         lp.parameter5,
         lp.parameter6,
         lp.parameter7,
         lp.parameter8,
         lp.parameter9,
         lp.parameter10,
         grp.group_id
    FROM hr_dm_groups grp,
         hr_dm_application_groups apg,
         hr_dm_table_groupings tbg,
         hr_dm_tables tbl,
         hr_dm_loader_params lp
    WHERE (lp.table_id = tbl.table_id)
      AND (lp.application_id = r_migration_data.application_id)
      AND (tbl.table_id = tbg.table_id)
      AND (tbg.group_id = grp.group_id)
      AND (grp.group_type = 'A')
      AND (grp.group_id = apg.group_id)
      AND (apg.application_id = lp.application_id)
      AND (apg.migration_type = r_migration_data.migration_type);

CURSOR csr_dff IS
  SELECT 'D',
         a.application_id,
         NULL,
         NULL,
         fc.descriptive_flexfield_name,
         fc.descriptive_flex_context_code
    FROM fnd_descr_flex_contexts_vl fc,
         fnd_descriptive_flexs_vl f,
         fnd_application a
    WHERE fc.descriptive_flexfield_name =
                            f.descriptive_flexfield_name
      AND f.application_id = a.application_id
      AND a.application_short_name IN ('PER','PAY','BEN','FND')
      AND fc.descriptive_flexfield_name NOT LIKE '$SRS$%';

CURSOR csr_sdff IS
  SELECT 'D',
         a.application_id,
         NULL,
         NULL,
         fc.descriptive_flexfield_name,
         fc.descriptive_flex_context_code
    FROM fnd_descr_flex_contexts_vl fc,
         fnd_descriptive_flexs_vl f,
         fnd_application a,
         hr_dm_migrations mig
    WHERE fc.descriptive_flexfield_name =
                            f.descriptive_flexfield_name
      AND f.application_id = a.application_id
      AND a.application_short_name IN ('PER','PAY','BEN','FND')
      AND fc.descriptive_flexfield_name NOT LIKE '$SRS$%'
      AND fc.descriptive_flexfield_name = mig.selective_migration_criteria
      AND mig.migration_id = r_migration_data.migration_id;

CURSOR csr_kff IS
  SELECT 'K',
         a.application_id,
         f.id_flex_code,
         f.id_flex_structure_code,
         NULL,
         NULL
    FROM fnd_id_flex_structures_vl f,
         fnd_application a,
         fnd_id_flexs fc
    WHERE f.id_flex_code = fc.id_flex_code
      AND fc.application_id = f.application_id
      AND f.application_id = a.application_id
      AND a.application_short_name IN ('PER','PAY','BEN','FND');


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_da', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id_da := hr_dm_utility.get_phase_id('DA',
                                         r_migration_data.migration_id);
l_phase_id_ua := hr_dm_utility.get_phase_id('UA',
                                         r_migration_data.migration_id);

-- see if we are using the custom_flex_solution
l_check_custom_flex_call := check_custom_flex;

OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_param_rec;

  EXIT WHEN csr_select_pi%NOTFOUND;

  -- seed data for:
  --   1. hr_dm_phase_items da phase
  --   2. hr_dm_phase_items ua phase
  --   3. hr_dm_loader_phase_items

  -- no data is automatically seeded when:
  --   1. l_check_custom_flex_call is not null
  --   2. up/downloading flexfield data

  hr_dm_utility.message('INFO','Checking ' || l_param_rec.loader_name , 10);
  hr_dm_utility.message('INFO','l_check_custom_flex_call ' ||
                        NVL(l_check_custom_flex_call,'-NULL-') , 10);


  IF (
       (l_check_custom_flex_call IS NOT NULL)
     AND
       (l_param_rec.loader_name IN ('Descriptive flexfields',
                          'Desc flexfields (selective)',
                          'Desc flexfields (lookups)',
                          'Key flexfields')
        )
      ) THEN

      -- process this data later
      -- this is for data where confirmation is required
      NULL;

    ELSE

      -- check for FNDSLOAD and seed dummy config file
      IF l_param_rec.loader_conc_program = 'FNDSLOAD' THEN
        l_param_rec.loader_config_file := 'n/a';
      END IF;

      seed_ua_da_data(l_param_rec,
                      'N',
                      l_phase_id_da,
                      l_phase_id_ua);

  END IF;

END LOOP;
CLOSE csr_select_pi;

-- now seed custom flex data
IF (l_check_custom_flex_call IS NOT NULL) THEN

  -- descriptive flexfields

  IF r_migration_data.migration_type = 'SD' THEN

    -- selective dff migration
    hr_dm_utility.message('INFO','Seeding selective dff migration' , 10);
    OPEN csr_sdff;
    LOOP
      FETCH csr_sdff INTO r_flexfield_data;
      EXIT WHEN csr_sdff%NOTFOUND;

      -- see if required
      IF (custom_specified(l_check_custom_flex_call,
                           r_migration_data,
                           r_flexfield_data)) THEN
        seed_data(r_migration_data,
                  r_flexfield_data,
                  l_phase_id_da,
                  l_phase_id_ua);
      END IF;

    END LOOP;
    CLOSE csr_sdff;

  ELSE

    -- non-selective migration
    hr_dm_utility.message('INFO','Seeding dff migration' , 10);
    OPEN csr_dff;
    LOOP
      FETCH csr_dff INTO r_flexfield_data;
      EXIT WHEN csr_dff%NOTFOUND;

      -- see if required
      IF (custom_specified(l_check_custom_flex_call,
                           r_migration_data,
                           r_flexfield_data)) THEN
        seed_data(r_migration_data,
                  r_flexfield_data,
                  l_phase_id_da,
                  l_phase_id_ua);
      END IF;

    END LOOP;
    CLOSE csr_dff;


    -- seed key flex for non-SL migrations
    IF r_migration_data.migration_type <> 'SL' THEN

      -- key flexfields
      hr_dm_utility.message('INFO','Seeding kff migration' , 10);
      OPEN csr_kff;
      LOOP
        FETCH csr_kff INTO r_flexfield_data;
        EXIT WHEN csr_kff%NOTFOUND;

        -- see if required
        IF (custom_specified(l_check_custom_flex_call,
                             r_migration_data,
                             r_flexfield_data)) THEN
          seed_data(r_migration_data,
                    r_flexfield_data,
                    l_phase_id_da,
                    l_phase_id_ua);
        END IF;

      END LOOP;
      CLOSE csr_kff;

    END IF;

  END IF;

END IF;

hr_dm_utility.message('INFO','Populate Phase Items table - DA phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - DA phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_da', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_da','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_da;
--

-- ------------------------- populate_pi_table_dp ------------------------
-- Description: The phase items for the download phase are seeded
-- into the hr_dm_phase_items. An entry is made for each group that is
-- applicable for the current migration.
--
-- It also truncates the datapump tables
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
                                        hr_dm_utility.r_migration_rec) IS
--

l_phase_id NUMBER;
l_group_id NUMBER;
l_batch_id NUMBER;
l_business_group_name hr_dm_migrations.business_group_name%type;
l_batch_name VARCHAR2(80);
l_group_text VARCHAR2(240);

CURSOR csr_select_pi IS
  SELECT grp.group_id, grp.description
    FROM hr_dm_groups grp, hr_dm_application_groups apg
    WHERE ((grp.group_type = 'D')
      AND (grp.group_id = apg.group_id)
      AND (apg.application_id = r_migration_data.application_id)
      AND (apg.migration_type = r_migration_data.migration_type) )
    ORDER BY apg.group_order;

CURSOR csr_select_bg_name IS
  SELECT pbg.name
    FROM per_business_groups pbg, hr_dm_migrations mig
    WHERE ((mig.migration_id = r_migration_data.migration_id)
      AND (mig.business_group_id = pbg.business_group_id));


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_dp', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id := hr_dm_utility.get_phase_id('DP',
                                         r_migration_data.migration_id);

-- truncate datapump tables
hr_dm_copy.delete_datapump_tables;




OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_group_id, l_group_text;
  EXIT WHEN csr_select_pi%NOTFOUND;

-- allocate batch_id for this group
  OPEN csr_select_bg_name;
  LOOP
    FETCH csr_select_bg_name INTO l_business_group_name;
    EXIT WHEN csr_select_bg_name%NOTFOUND;
  END LOOP;
  CLOSE csr_select_bg_name;

  l_batch_name := '(Mig ID ' || r_migration_data.migration_id ||
                  ')(Ph ID ' || l_phase_id ||
                  ')(Grp ID ' || l_group_id || ')' ||
                  '[' || l_group_text || ']';

  l_batch_id := hr_pump_utils.create_batch_header(
                  p_batch_name => l_batch_name,
                  p_business_group_name => l_business_group_name,
                  p_reference => 'HR Data Migrator');

  INSERT INTO hr_dm_phase_items (PHASE_ITEM_ID,
                                 PHASE_ID,
                                 LOADER_NAME,
                                 BATCH_ID,
                                 GROUP_ID,
                                 TABLE_NAME,
                                 STATUS,
                                 START_TIME,
                                 END_TIME,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
    SELECT hr_dm_phase_items_s.nextval,
           l_phase_id,
           NULL,
           l_batch_id,
           l_group_id,
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
        (SELECT NULL FROM hr_dm_phase_items
          WHERE ((phase_id = l_phase_id)
            AND (batch_id = l_batch_id)
            AND (group_id = l_group_id)));

  COMMIT;

  hr_dm_utility.message('INFO','Seeding ' || l_group_text, 11);


END LOOP;
CLOSE csr_select_pi;


hr_dm_utility.message('INFO','Populate Phase Items table - DP phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - DP phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_dp', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_dp','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_dp;
--

-- ------------------------- populate_pi_table_cp ------------------------
-- Description: The phase items for the copy phase are seeded
-- into the hr_dm_phase_items. (none required)
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
PROCEDURE populate_pi_table_cp(r_migration_data IN
                                        hr_dm_utility.r_migration_rec) IS
--

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_cp', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

--
-- phase specific code to be inserted here
--
-- Copy phase is now offline only
--
-- no code required
--

hr_dm_utility.message('INFO','Populate Phase Items table - CP phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - CP phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_cp', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_cp','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_cp;
--


-- ------------------------- populate_pi_table_up ------------------------
-- Description: The phase items for the upload phase are seeded
-- into the hr_dm_phase_items. An entry is made for each group that is
-- applicable for the current migration.
--
-- The table hr_dm_resolve_pks has entries for migrations from the current
-- source database deleted for an FW or SR migration.
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
                                          hr_dm_utility.r_migration_rec) IS
--

l_phase_id NUMBER;
l_group_id NUMBER;
l_batch_id NUMBER;
l_business_group_name hr_dm_migrations.business_group_name%type;
l_batch_name VARCHAR2(80);
l_group_text VARCHAR2(240);
l_batch_start NUMBER;
l_batch_end NUMBER;
l_batch_txt VARCHAR2(80);

CURSOR csr_select_pi IS
  SELECT grp.group_id, grp.description
    FROM hr_dm_groups grp, hr_dm_application_groups apg
    WHERE ((grp.group_type = 'D')
     AND (grp.group_id = apg.group_id)
     AND (apg.application_id = r_migration_data.application_id)
     AND (apg.migration_type = r_migration_data.migration_type) )
    ORDER BY apg.group_order;

CURSOR csr_select_batch_id IS
 SELECT bh.batch_id, bh.batch_name
    FROM hr_pump_batch_headers bh
    WHERE bh.reference = 'HR Data Migrator'
    AND EXISTS (SELECT NULL
                FROM hr_pump_batch_lines bl
                WHERE bh.batch_id = bl.batch_id
                AND ROWNUM < 2);


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_up', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id := hr_dm_utility.get_phase_id('UP',
                                         r_migration_data.migration_id);

OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_group_id, l_group_text;
  EXIT WHEN csr_select_pi%NOTFOUND;


-- find the batch_id for this group


  OPEN csr_select_batch_id;
  LOOP
    FETCH csr_select_batch_id INTO l_batch_id, l_batch_name;
    EXIT WHEN (csr_select_batch_id%NOTFOUND);



    l_batch_start := instr(l_batch_name, '[')+1;
    l_batch_end := instr(l_batch_name, ']');
    l_batch_txt := substr (l_batch_name, l_batch_start,
                           l_batch_end - l_batch_start);
    EXIT WHEN (csr_select_batch_id%NOTFOUND);

    IF (l_group_text = l_batch_txt) THEN
      INSERT INTO hr_dm_phase_items (PHASE_ITEM_ID,
                                     PHASE_ID,
                                     LOADER_NAME,
                                     BATCH_ID,
                                     GROUP_ID,
                                     TABLE_NAME,
                                     STATUS,
                                     START_TIME,
                                     END_TIME,
                                     CREATED_BY,
                                     CREATION_DATE,
                                     LAST_UPDATED_BY,
                                     LAST_UPDATE_DATE,
                                     LAST_UPDATE_LOGIN)
        SELECT hr_dm_phase_items_s.nextval,
               l_phase_id,
               NULL,
               l_batch_id,
               l_group_id,
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
            (SELECT NULL FROM hr_dm_phase_items
              WHERE ((phase_id = l_phase_id)
                AND (batch_id = l_batch_id)
                AND (group_id = l_group_id)));

      COMMIT;

      hr_dm_utility.message('INFO','Seeding ' || l_group_text, 11);

    END IF;

  END LOOP;
  CLOSE csr_select_batch_id;



END LOOP;
CLOSE csr_select_pi;




IF r_migration_data.migration_type in ('FW','SR') THEN
  hr_dm_utility.message('INFO',
                'Deleting hr_dm_resolve_pks table for source database' ||
                ' for FW or SR migration', 15);
  DELETE FROM hr_dm_resolve_pks
    WHERE source_database_instance = r_migration_data.source_database_instance;
END IF;

IF r_migration_data.migration_type = 'A' THEN
  hr_dm_utility.message('INFO',
                'Deleting hr_dm_resolve_pks table for source database' ||
                ' for A migration and NR_NAVIGATION_UNITS data', 15);
  DELETE FROM hr_dm_resolve_pks
    WHERE source_database_instance = r_migration_data.source_database_instance
    AND TABLE_NAME = 'HR_NAVIGATION_UNITS';
END IF;



hr_dm_utility.message('INFO','Populate Phase Items table - UP phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - UP phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_up', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_up','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_up;
--



-- ------------------------- populate_pi_table_ua ------------------------
-- Description: The phase items for the upload aol phase are seeded
-- into the hr_dm_phase_items. An entry is made for each aol loader within
-- a group that is applicable for the current migration.
--
-- This data is now seeded in the populate_pi_table_da procedure.
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
PROCEDURE populate_pi_table_ua(r_migration_data IN
                                         hr_dm_utility.r_migration_rec) IS
--

l_phase_id NUMBER;
l_group_id NUMBER;
l_loader_name VARCHAR2(30);
l_loader_params_id NUMBER;

CURSOR csr_select_pi IS
  SELECT tbl.loader_name,
         lp.loader_params_id,
         grp.group_id
    FROM hr_dm_groups grp,
         hr_dm_application_groups apg,
         hr_dm_table_groupings tbg,
         hr_dm_tables tbl,
         hr_dm_loader_params lp
    WHERE (lp.table_id = tbl.table_id)
      AND (lp.application_id = r_migration_data.application_id)
      AND (tbl.table_id = tbg.table_id)
      AND (tbg.group_id = grp.group_id)
      AND (grp.group_type = 'A')
      AND (grp.group_id = apg.group_id)
      AND (apg.application_id = r_migration_data.application_id)
      AND (apg.migration_type = r_migration_data.migration_type)
    ORDER BY tbl.table_id;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_ua', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id := hr_dm_utility.get_phase_id('UA',
                                         r_migration_data.migration_id);


-- no work is done in this procedure as the UA phase items are
-- seeded as part of the DA phase item seeding


hr_dm_utility.message('INFO','Populate Phase Items table - UA phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - UA phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_ua', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_ua','(none)',
                      'R');
  RAISE;


--
END populate_pi_table_ua;
--

-- ------------------------- populate_pi_table_d ------------------------
-- Description: The phase items for the delete phase are seeded
-- into the hr_dm_phase_items. An entry is made for each group that is
-- applicable for the current migration.
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
PROCEDURE populate_pi_table_d(r_migration_data IN
                                          hr_dm_utility.r_migration_rec) IS
--

l_phase_id NUMBER;
l_group_id NUMBER;
l_group_text VARCHAR2(240);

CURSOR csr_select_pi IS
  SELECT apg.group_id, grp.description
    FROM hr_dm_application_groups apg,
         hr_dm_groups grp
    WHERE ((apg.application_id = r_migration_data.application_id)
      AND (apg.migration_type = r_migration_data.migration_type)
      AND (apg.group_id = grp.group_id))
    ORDER BY apg.group_order DESC;

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_d', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id := hr_dm_utility.get_phase_id('D',
                                         r_migration_data.migration_id);


OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_group_id, l_group_text;
  EXIT WHEN csr_select_pi%NOTFOUND;

  INSERT INTO hr_dm_phase_items (PHASE_ITEM_ID,
                                 PHASE_ID,
                                 LOADER_NAME,
                                 BATCH_ID,
                                 GROUP_ID,
                                 TABLE_NAME,
                                 STATUS,
                                 START_TIME,
                                 END_TIME,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
    SELECT hr_dm_phase_items_s.nextval,
           l_phase_id,
           NULL,
           NULL,
           l_group_id,
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
        (SELECT NULL FROM hr_dm_phase_items
          WHERE ((phase_id = l_phase_id)
            AND (group_id = l_group_id)));

  COMMIT;

  hr_dm_utility.message('INFO','Seeding ' || l_group_text, 11);

END LOOP;
CLOSE csr_select_pi;


hr_dm_utility.message('INFO','Populate Phase Items table - D phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - D phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_d', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_d','(none)',
                      'R');
  RAISE;

--
END populate_pi_table_d;
--

-- ------------------------- populate_pi_table_ua ------------------------
-- Description: The phase items for the clean up phase are seeded
-- into the hr_dm_phase_items. An entry is made for each aol loader within
-- a group that is applicable for the current migration.
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
PROCEDURE populate_pi_table_c(r_migration_data IN
                                        hr_dm_utility.r_migration_rec) IS
--

l_phase_id NUMBER;
l_group_id NUMBER;
l_loader_name VARCHAR2(30);
l_loader_params_id NUMBER;

CURSOR csr_select_pi IS
  SELECT tbl.loader_name,
         lp.loader_params_id,
         grp.group_id
    FROM hr_dm_groups grp,
         hr_dm_application_groups apg,
         hr_dm_table_groupings tbg,
         hr_dm_tables tbl,
         hr_dm_loader_params lp
    WHERE (lp.table_id = tbl.table_id)
      AND (lp.application_id = r_migration_data.application_id)
      AND (tbl.table_id = tbg.table_id)
      AND (tbg.group_id = grp.group_id)
      AND (grp.group_type = 'C')
      AND (grp.group_id = apg.group_id)
      AND (apg.application_id = r_migration_data.application_id)
      AND (apg.migration_type = r_migration_data.migration_type)
    ORDER BY tbl.table_id;


--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table_c', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

l_phase_id := hr_dm_utility.get_phase_id('C',
                                         r_migration_data.migration_id);

OPEN csr_select_pi;
LOOP
  FETCH csr_select_pi INTO l_loader_name, l_loader_params_id, l_group_id;
  EXIT WHEN csr_select_pi%NOTFOUND;

  INSERT INTO hr_dm_phase_items (PHASE_ITEM_ID,
                                 PHASE_ID,
                                 LOADER_NAME,
                                 LOADER_PARAMS_ID,
                                 BATCH_ID,
                                 GROUP_ID,
                                 TABLE_NAME,
                                 STATUS,
                                 START_TIME,
                                 END_TIME,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
    SELECT hr_dm_phase_items_s.nextval,
           l_phase_id,
           l_loader_name,
           l_loader_params_id,
           NULL,
           l_group_id,
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
        (SELECT NULL FROM hr_dm_phase_items
          WHERE ((phase_id = l_phase_id)
            AND (loader_name = l_loader_name)));

  COMMIT;

  hr_dm_utility.message('INFO','Seeding ' || l_loader_name, 11);

END LOOP;
CLOSE csr_select_pi;


hr_dm_utility.message('INFO','Populate Phase Items table - C phase', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table - C phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table_c', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table_c','(none)'
                      ,'R');
  RAISE;

--
END populate_pi_table_c;
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
                                           hr_dm_utility.r_migration_rec,
                            p_phase_name IN VARCHAR2) IS
--

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_pi_table', 5);
hr_dm_utility.message('PARA','(r_migration_data - record' ||
                  ')(p_phase_name - ' || p_phase_name || ')', 10);

IF (p_phase_name = 'I') THEN
  populate_pi_table_i(r_migration_data);
ELSIF (p_phase_name = 'G') THEN
  populate_pi_table_g(r_migration_data);
ELSIF (p_phase_name = 'R') THEN
  populate_pi_table_r(r_migration_data);
ELSIF (p_phase_name = 'DA') THEN
  populate_pi_table_da(r_migration_data);
ELSIF (p_phase_name = 'DP') THEN
  populate_pi_table_dp(r_migration_data);
ELSIF (p_phase_name = 'CP') THEN
  populate_pi_table_cp(r_migration_data);
ELSIF (p_phase_name = 'UP') THEN
  populate_pi_table_up(r_migration_data);
ELSIF (p_phase_name = 'UA') THEN
  populate_pi_table_ua(r_migration_data);
ELSIF (p_phase_name = 'D') THEN
  populate_pi_table_d(r_migration_data);
ELSIF (p_phase_name = 'C') THEN
  populate_pi_table_c(r_migration_data);
END IF;

hr_dm_utility.message('INFO','Populate Phase Items table -' ||
                      ' calling phase code', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table -' ||
                      ' calling phase code', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_pi_table', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_pi_table','(none)','R');
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
                                           hr_dm_utility.r_migration_rec) IS

--

l_search_phase VARCHAR2(30);
l_phase_name VARCHAR2(30);
l_previous_phase VARCHAR2(30);
l_next_phase VARCHAR2(30);
l_database_location VARCHAR2(30);

CURSOR csr_phase_rule IS
  SELECT phase_name, previous_phase, next_phase,
         database_location
    FROM hr_dm_phase_rules
    WHERE ((migration_type = r_migration_data.migration_type)
      AND (previous_phase = l_search_phase));

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_phase_items', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);

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

hr_dm_utility.message('INFO','Populate Phase Items table', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_phase_items', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_phase_items',
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
PROCEDURE populate_p_table(r_migration_data IN hr_dm_utility.r_migration_rec,
                           p_phase_name IN VARCHAR2) IS
--

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_p_table', 5);
hr_dm_utility.message('PARA','(r_migration_data - record' ||
                      ')(p_phase_name - ' || p_phase_name || ')', 10);

INSERT INTO hr_dm_phases (PHASE_ID,
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
  SELECT hr_dm_phases_s.nextval,
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
      (SELECT NULL FROM hr_dm_phases
        WHERE ((migration_id = r_migration_data.migration_id)
          AND (phase_name = p_phase_name)));

COMMIT;

hr_dm_utility.message('INFO','Populate Phases table', 15);
hr_dm_utility.message('SUMM','Populate Phases table', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_p_table', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_p_table','(none)','R');
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
                                       hr_dm_utility.r_migration_rec) IS
--

l_phase_name VARCHAR2(30);
l_database_location VARCHAR2(30);

CURSOR csr_phase_rule IS
  SELECT phase_name, database_location
    FROM hr_dm_phase_rules
    WHERE ((migration_type = r_migration_data.migration_type)
      AND (INSTR(database_location,
                 r_migration_data.database_location) >0));

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.populate_phases', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);


OPEN csr_phase_rule;
LOOP
  FETCH csr_phase_rule INTO l_phase_name, l_database_location;
  EXIT WHEN csr_phase_rule%NOTFOUND;
  populate_p_table(r_migration_data, l_phase_name);
END LOOP;
CLOSE csr_phase_rule;

hr_dm_utility.message('INFO','Populate Phase Items table', 15);
hr_dm_utility.message('SUMM','Populate Phase Items table', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.populate_phases', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.populate_phases','(none)','R');
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
PROCEDURE main(r_migration_data IN hr_dm_utility.r_migration_rec) IS
--

l_current_phase_status VARCHAR2(30);

--
BEGIN
--

hr_dm_utility.message('ROUT','entry:hr_dm_init.main', 5);
hr_dm_utility.message('PARA','(r_migration_data - record)', 10);


-- get status of initialization phase, is phase completed?
-- if null returned, then assume it is NS.
l_current_phase_status := NVL(hr_dm_utility.get_phase_status('I',
                              r_migration_data.migration_id), 'NS');

-- is phase complete?
-- if so, skip all processing
IF (l_current_phase_status <> 'C') THEN
-- do we need to explicitly rollback using rollback utility?
  IF (l_current_phase_status IN('S', 'E')) THEN
    hr_dm_utility.rollback(p_phase => 'I',
                           p_migration_id => r_migration_data.migration_id);
  END IF;


-- populate phases table
  populate_phases(r_migration_data);


-- update status to started
  hr_dm_utility.update_phases(p_new_status => 'S',
                              p_id => hr_dm_utility.get_phase_id('I',
                              r_migration_data.migration_id));

-- populate phase_items table
  populate_phase_items(r_migration_data);

-- delete the contents of hr_dm_exp_imps table
-- if we are on the source database only
IF (r_migration_data.database_location = 'S') THEN
  DELETE hr_dm_exp_imps;
  COMMIT;
END IF;

-- update status to completed
  hr_dm_utility.update_phases(p_new_status => 'C',
                              p_id => hr_dm_utility.get_phase_id('I',
                              r_migration_data.migration_id));

END IF;


hr_dm_utility.message('INFO','Initialization Phase', 15);
hr_dm_utility.message('SUMM','Initialization Phase', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_init.main', 25);
hr_dm_utility.message('PARA','(none)', 30);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  hr_dm_utility.error(SQLCODE,'hr_dm_init.main','(none)','R');
  RAISE;

--
END main;
--



END hr_dm_init;

/
