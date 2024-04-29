--------------------------------------------------------
--  DDL for Package Body HRI_APL_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_APL_DIAGNOSTICS" AS
/* $Header: hriadiag.pkb 120.2 2005/10/17 22:32:00 anmajumd noship $ */
--
e_data_error Exception;
--

PROCEDURE output(p_text IN VARCHAR2)
IS
--
l_stmnt VARCHAR2(100);
--
BEGIN
  --
  l_stmnt := 'BEGIN dbms_output.put_line(:v); END;';
  --
  EXECUTE IMMEDIATE l_stmnt USING p_text;
  --
END output;
--
PROCEDURE check_object_existence
(p_object_name IN VARCHAR2,
 p_object_type IN VARCHAR2,
 p_subscr_or_diag IN VARCHAR2 DEFAULT 'D')
IS
--
l_obj_exists NUMBER:= 0;
--
CURSOR cur_chk_object
IS
SELECT 1
FROM hri_adm_dgnstc_setup
WHERE object_name = p_object_name
AND   object_type = p_object_type;
--
BEGIN
  --
  OPEN cur_chk_object;
  FETCH cur_chk_object INTO l_obj_exists;
  CLOSE cur_chk_object;
  --
  IF (l_obj_exists <> 1) AND (p_subscr_or_diag = 'S') THEN
    --
    output('Entry for object ' || p_object_name || ' does not exist in diagnostics metadata table.');
    --
    RAISE e_data_error;
    --
  END IF;

  IF (l_obj_exists = 1) AND (p_subscr_or_diag = 'D') THEN
    --
    output('Object ' || p_object_name || ' already exists.');
    --
    RAISE e_data_error;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN e_data_error THEN
    --
    RAISE;
    --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END check_object_existence;
--
-- This procedure is used to check a message has been cerated
--
PROCEDURE check_message(p_msg_name IN VARCHAR2)
IS
--
l_exist_msg NUMBER;
--
BEGIN
  --
  IF (p_msg_name IS NULL) THEN
    --
    RETURN;
    --
  END IF;
  --
  l_exist_msg := FND_MESSAGE.GET_NUMBER('HRI',p_msg_name);
  --
  IF l_exist_msg IS NULL THEN
    --
    -- If the message does not exist  then show output and raise error
    --
    output('The message ' || p_msg_name || ' does not exist.');
    --
    RAISE e_data_error;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN e_data_error THEN
    --
    RAISE;
    --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END check_message;
--
-- This procedure is used to check the existence of functional area
--
PROCEDURE check_functional_area(p_functional_area_cd IN VARCHAR2)
IS
--
l_chk_func_area NUMBER:=0;
--
CURSOR cur_chk_func_area
IS
SELECT 1
FROM hr_lookups
WHERE lookup_type = 'HRI_FUNCTIONAL_AREA'
AND lookup_code = p_functional_area_cd;
--
BEGIN
  --
  OPEN cur_chk_func_area;
  FETCH cur_chk_func_area INTO l_chk_func_area;
  CLOSE cur_chk_func_area;
  --
  IF (l_chk_func_area <> 1) THEN
    --
    output('Functional area ' || p_functional_area_cd || ' does not exists.');
    --
    RAISE e_data_error;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN e_data_error THEN
    --
    RAISE;
    --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END check_functional_area;
--
-- This procedure is used to check if the profile exists
--
PROCEDURE check_profile_existence(p_object_name IN VARCHAR2)
IS
--
l_chk_profile NUMBER:= 0;
--
CURSOR cur_chk_profile
IS
SELECT 1
FROM fnd_profile_options
WHERE profile_option_name = p_object_name;
--
BEGIN
  --
  OPEN cur_chk_profile;
  FETCH cur_chk_profile INTO l_chk_profile;
  CLOSE cur_chk_profile;
  --
  IF (l_chk_profile <> 1) THEN
    --
    output('Profile ' || p_object_name || ' does not exist.');
    --
    RAISE e_data_error;
    --
  END IF;
    --
EXCEPTION
  --
  WHEN e_data_error THEN
    --
    RAISE;
    --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END check_profile_existence;
--
-- This procedure is used to check if the bucket has been defined
--
PROCEDURE check_bucket_existence(p_object_name IN VARCHAR2)
IS
--
l_chk_bucket NUMBER:=0;
--
CURSOR cur_chk_bucket
IS
SELECT 1
FROM bis_bucket
WHERE short_name = p_object_name;
--
BEGIN
  --
  OPEN cur_chk_bucket;
  FETCH cur_chk_bucket INTO l_chk_bucket;
  CLOSE cur_chk_bucket;
  --
  IF (l_chk_bucket <> 1) THEN
    --
    output('Bucket ' || p_object_name || ' does not exist.');
    --
    RAISE e_data_error;
    --
  END IF;
  --
END check_bucket_existence;
--
-- This procedure is used to check the existsnce of triggers
--
PROCEDURE check_trigger_existence(p_object_name IN VARCHAR2)
IS
--
l_chk_trigger NUMBER:= 0;
--
CURSOR cur_chk_trigger
IS
SELECT 1
FROM pay_trigger_events
WHERE short_name = p_object_name;
BEGIN
  --
  OPEN cur_chk_trigger;
  FETCH cur_chk_trigger INTO l_chk_trigger;
  CLOSE cur_chk_trigger;
  --
  IF (l_chk_trigger <> 1) THEN
    --
    output('Trigger ' || p_object_name || ' does not exist.');
    --
    RAISE e_data_error;
    --
  END IF;
  --
END check_trigger_existence;
--
--This procedure is used to check the existence of tables
--
PROCEDURE check_table_existence(p_object_name IN VARCHAR2, p_object_owner IN VARCHAR2)
IS
--
l_chk_table NUMBER:=0;
--
CURSOR cur_chk_table
IS
SELECT 1
FROM all_tables
WHERE table_name = p_object_name
AND owner = p_object_owner;
--
BEGIN
  --
  OPEN cur_chk_table;
  FETCH cur_chk_table INTO l_chk_table;
  CLOSE cur_chk_table;
  --
  IF (l_chk_table <> 1 ) THEN
    --
    output('Table ' || p_object_name || ' does not exist.');
    --
    RAISE e_data_error;
    --
  END IF;
  --
END check_table_existence;
--
-- This procedure is used to check the existence of seeded fast formulas
--
PROCEDURE check_seeded_ff_existence(p_object_name IN VARCHAR2)
IS
--
l_chk_ff NUMBER:= 0;
--
CURSOR cur_chk_seeded_ff
IS
SELECT 1
FROM ff_formulas_f
WHERE formula_name = p_object_name;
--
BEGIN
  --
  OPEN cur_chk_seeded_ff;
  FETCH cur_chk_seeded_ff INTO l_chk_ff;
  CLOSE cur_chk_seeded_ff;
  --
  IF (l_chk_ff <> 1) THEN
    --
    output('Fast Formula ' || p_object_name || ' does not exist.');
    --
    RAISE e_data_error;
    --
  END IF;
  --
EXCEPTION
  --
  WHEN e_data_error THEN
    --
    RAISE;
    --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END check_seeded_ff_existence;

--
-- This procedure is used to create the subscritpion for objects
-- Every diagnostic should have a subscription
--
PROCEDURE create_subscription(
  p_object_name IN VARCHAR2,
  p_object_type IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2)
IS
--
l_chk_cursors NUMBER:=0;
--
CURSOR cur_chk_duplication
IS
SELECT 1
FROM hri_adm_dgnstc_sbscrb
WHERE object_name = p_object_name
AND  object_type = p_object_type
AND functional_area_cd = p_functional_area_cd;
--
BEGIN
  --
  check_functional_area(p_functional_area_cd);
  --
  check_object_existence(p_object_name, p_object_type,'S');
  --
  l_chk_cursors := 0;
  --
  OPEN cur_chk_duplication;
  FETCH cur_chk_duplication INTO l_chk_cursors;
  CLOSE cur_chk_duplication;
  --
  IF (l_chk_cursors = 1) THEN
    --
    -- If the subscription already exists, then show the output and raise error
    --
    output('Subscription already exists for this functional area for object ' || p_object_name || ' and object type ' || p_object_type );
    --
    RAISE e_data_error;
    --
  END IF;
  --
  -- Insert into the subscription table
  --
  INSERT INTO hri_adm_dgnstc_sbscrb
    (object_name,
    object_type,
    functional_area_cd)
  VALUES
    (p_object_name,
    p_object_type,
    p_functional_area_cd);
    --
    COMMIT;
    --
EXCEPTION
    WHEN e_data_error THEN
      RAISE;
    WHEN OTHERS THEN
      RAISE;
END create_subscription;
--
PROCEDURE delete_subscription
  (p_object_name IN VARCHAR2,
  p_object_type IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2)
IS
BEGIN
  --
  DELETE FROM hri_adm_dgnstc_sbscrb
  WHERE object_name = p_object_name
  AND object_type = p_object_type
  AND functional_area_cd = p_functional_area_cd;
  --
  output(SQL%ROWCOUNT || ' row deleted.');
  --
  COMMIT;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END delete_subscription;
--
-- This procedure is used to create diagnostics associated with profiles
--
PROCEDURE create_profile_sys_setup(
  p_object_name IN VARCHAR2,
  p_dynamic_sql IN VARCHAR2,
  p_dynamic_sql_type IN VARCHAR2,
  p_exception_value IN VARCHAR2,
  p_impact_msg_name IN VARCHAR2,
  p_add_info_URL IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_HR_FLAG IN VARCHAR2,
  p_null_impact_msg_name IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2) IS
--
BEGIN
  --
  -- Check for duplication
  --
  check_object_existence(p_object_name,'PROFILE');
  --
  -- Check if the profile exists
  --
  check_profile_existence(p_object_name);
  --
  -- Check if the functional area is valid
  --
  check_functional_area(p_functional_area_cd);
  --
  --
  -- Check the messages have been created
  --
  check_message(p_impact_msg_name);
  check_message(p_null_impact_msg_name);
  --
  -- Insert into the diagnostic meta data table
  --
  INSERT INTO hri_adm_dgnstc_setup
    (object_name,
    object_type,
    dynamic_sql,
    dynamic_sql_type,
    exception_value,
    impact_msg_name,
    add_info_URL,
    enabled_flag,
    foundation_HR_FLAG,
    null_impact_msg_name,
    report_type,
    functional_area_cd
    )
  VALUES
    (p_object_name,
    'PROFILE',
    p_dynamic_sql,
    p_dynamic_sql_type,
    p_exception_value,
    p_impact_msg_name,
    p_add_info_URL,
    p_enabled_flag,
    p_foundation_HR_FLAG,
    p_null_impact_msg_name,
    'SYSTEM',
    p_functional_area_cd);
    --
  COMMIT;
  --
  EXCEPTION
    --
    WHEN e_data_error THEN
    RAISE;
    WHEN OTHERS THEN
    RAISE;
  END create_profile_sys_setup;
  --
PROCEDURE create_trigger_sys_setup(
  p_object_name IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2) IS

BEGIN
  --
  -- Check for duplication
  --
  check_object_existence(p_object_name,'TRIGGER');
  --
  -- Check if the trigger exists
  --
  check_trigger_existence(p_object_name);
  --
  -- Check if the functional area is valid
  --
  check_functional_area(p_functional_area_cd);
  --
  --
  -- Check that the message are created
  --
  check_message(p_exception_status_msg_cd);
  check_message(p_valid_status_msg_cd);
  --
  -- Insert into the diagnostic metadata table
  --
  INSERT INTO hri_adm_dgnstc_setup
    (object_name,
    object_type,
    exception_status_msg_cd,
    valid_status_msg_cd,
    enabled_flag,
    foundation_hr_flag,
    report_type,
    functional_area_cd)
  VALUES
    (p_object_name,
    'TRIGGER',
    p_exception_status_msg_cd,
    p_valid_status_msg_cd,
    p_enabled_flag,
    p_foundation_hr_flag,
    'SYSTEM',
    p_functional_area_cd);
    --
   COMMIT;
   --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END create_trigger_sys_setup;


PROCEDURE create_table_sys_setup
  (p_object_name IN VARCHAR2,
  p_object_owner IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2) IS

BEGIN
  --
  -- Check for duplication
  --
  check_object_existence(p_object_name,'TABLE');
  --
  -- Check if the table exists
  --
  check_table_existence(p_object_name, p_object_owner);
  --
  -- Check if the functional area is valid
  --
  check_functional_area(p_functional_area_cd);
  --
  --
  -- Check that the messages have been created
  --
  check_message(p_exception_status_msg_cd);
  check_message(p_valid_status_msg_cd);
  --
  --
  -- Insert into the diagnostic metacata table
  --
  INSERT INTO hri_adm_dgnstc_setup
    (object_name,
    object_type,
    exception_status_msg_cd,
    valid_status_msg_cd,
    enabled_flag,
    foundation_hr_flag,
    report_type,
    functional_area_cd)
  VALUES
    (p_object_name,
    'TABLE',
    p_exception_status_msg_cd,
    p_valid_status_msg_cd,
    p_enabled_flag,
    p_foundation_hr_flag,
    'SYSTEM',
    p_functional_area_cd);
  --
  COMMIT;
--
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END create_table_sys_setup;


PROCEDURE create_seeded_ff_sys_setup
  (p_object_name IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_add_info_url IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2) IS
--
BEGIN
  --
  -- Check for duplication
  --
  check_object_existence(p_object_name,'SEEDED_FAST_FORMULA');
  --
  -- Check if the seeded fast formulas exists
  --
  check_seeded_ff_existence(p_object_name);
  --
  -- Check if the functional area is valid
  --
  check_functional_area(p_functional_area_cd);
  --
  -- Check messaged have been created
  --
  check_message(p_exception_status_msg_cd);
  check_message(p_valid_status_msg_cd);
  --
  -- Insert into the diagnostic metadata table
  --
  INSERT INTO hri_adm_dgnstc_setup
    (object_name,
    object_type,
    exception_status_msg_cd,
    valid_status_msg_cd,
    add_info_url,
    enabled_flag,
    foundation_hr_flag,
    report_type,
    functional_area_cd)
  VALUES
    (p_object_name,
    'SEEDED_FAST_FORMULA',
     p_exception_status_msg_cd,
     p_valid_status_msg_cd,
     p_add_info_url,
     p_enabled_flag,
     p_foundation_hr_flag,
     'SYSTEM',
     p_functional_area_cd);
     --
   COMMIT;
   --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END create_seeded_ff_sys_setup;

PROCEDURE create_usr_def_ff_sys_setup
  (p_object_name IN VARCHAR2,
  p_dynamic_sql IN VARCHAR2,
  p_dynamic_sql_type IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_impact_msg_name IN VARCHAR2,
  p_add_info_url IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2) IS

BEGIN
  --
  -- Check for duplication
  --
  check_object_existence(p_object_name,'USER_DEFN_FAST_FORMULA');
  --
  -- Check if the functional area is valid
  --
  check_functional_area(p_functional_area_cd);
  --
  -- Check that the messages have been cerated
  --
  check_message(p_exception_status_msg_cd);
  check_message(p_valid_status_msg_cd);
  check_message(p_impact_msg_name);
  --
  -- Insert the data into the diagnostic metadata table
  --
  INSERT INTO hri_adm_dgnstc_setup
    (object_name,
    object_type,
    dynamic_sql,
    dynamic_sql_type,
    exception_status_msg_cd,
    valid_status_msg_cd,
    impact_msg_name,
    add_info_url,
    enabled_flag,
    foundation_hr_flag,
    report_type,
    functional_area_cd)
  VALUES
    (p_object_name,
    'USER_DEFN_FAST_FORMULA',
    p_dynamic_sql,
    p_dynamic_sql_type,
    p_exception_status_msg_cd,
    p_valid_status_msg_cd,
    p_impact_msg_name,
    p_add_info_url,
    p_enabled_flag,
    p_foundation_hr_flag,
    'SYSTEM',
    p_functional_area_cd);
    --
    COMMIT;
    --
EXCEPTION
  --
  WHEN OTHERS THEN
  --
  RAISE;
  --
END create_usr_def_ff_sys_setup;
--
-- This procedure is used to create diagnostics associated with buckets
--
PROCEDURE create_bucket_sys_setup
  (p_object_name IN VARCHAR2,
  p_dynamic_sql IN VARCHAR2,
  p_dynamic_sql_type IN VARCHAR2,
  p_exception_status_msg_cd IN VARCHAR2,
  p_valid_status_msg_cd IN VARCHAR2,
  p_impact_msg_name IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2
  )
IS
BEGIN
  --
  --
  -- Check for duplication
  --
  check_object_existence(p_object_name,'BUCKET');
  --
  -- Check for existence of the bucket
  --
  check_bucket_existence(p_object_name);
  --
  -- Check if the functional area is valid
  --
  check_functional_area(p_functional_area_cd);
  --
  -- Check that the messages have been cerated
  --
  check_message(p_exception_status_msg_cd);
  check_message(p_valid_status_msg_cd);
  check_message(p_impact_msg_name);
  --
  -- Insert the data into the diagnostic metadata table
  --
  INSERT INTO hri_adm_dgnstc_setup
    (object_name,
    object_type,
    dynamic_sql,
    dynamic_sql_type,
    exception_status_msg_cd,
    valid_status_msg_cd,
    impact_msg_name,
    enabled_flag,
    foundation_hr_flag,
    report_type,
    functional_area_cd)
  VALUES
    (p_object_name,
    'BUCKET',
    p_dynamic_sql,
    p_dynamic_sql_type,
    p_exception_status_msg_cd,
    p_valid_status_msg_cd,
    p_impact_msg_name,
    p_enabled_flag,
    p_foundation_hr_flag,
    'SYSTEM',
    p_functional_area_cd);
    --
    COMMIT;
    --
EXCEPTION
  --
  WHEN OTHERS THEN
  --
  RAISE;
  --
END create_bucket_sys_setup;

--
-- This procedure is used to create data diagnostics
--
PROCEDURE create_data_diagnostics
  (p_object_name IN VARCHAR2,
  p_object_type IN VARCHAR2,
  p_dynamic_sql IN VARCHAR2,
  p_dynamic_sql_type IN VARCHAR2,
  p_impact_msg_name IN VARCHAR2,
  p_enabled_flag IN VARCHAR2,
  p_foundation_hr_flag IN VARCHAR2,
  --
  -- object_type_msg_name
  -- Section heading
  --
  p_section_heading IN VARCHAR2,
  --
  -- object_type_desc
  -- Description for COUNT section
  --
  p_section_count_desc IN VARCHAR2,
  --
  -- object_type_dtl_desc_msg_name
  -- Description for DETAIL section
  --
  p_section_detail_desc IN VARCHAR2,
  --
  -- object_name_msg_name
  -- Subsection heading
  --
  p_sub_section_heading IN VARCHAR2,
  --
  -- object_name_desc
  -- Description for COUNT sub-section
  --
  p_sub_section_count_desc  IN VARCHAR2,
  --
  -- object_name_dtl_desc_msg_name
  -- Description for DETAIL sub section
  --
  p_sub_section_detail_desc IN VARCHAR2,
  --
  -- Heading of count column
  --
  p_heading_for_count IN VARCHAR2,
  --
  -- Heading of columns in detail mode as ordered in the dynamic SQL
  --
  p_heading_for_column1 IN VARCHAR2,
  p_heading_for_column2 IN VARCHAR2,
  p_heading_for_column3 IN VARCHAR2,
  p_heading_for_column4 IN VARCHAR2,
  p_heading_for_column5 IN VARCHAR2,
  --
  p_default_sql_mode IN VARCHAR2,
  --
  p_seq_num IN NUMBER,
  p_functional_area_cd IN VARCHAR2
  )
IS
--
l_prev_heading VARCHAR2(100);
--
CURSOR cur_prev_heading
IS
SELECT object_type_msg_name
FROM hri_adm_dgnstc_setup
WHERE seq_num = (
SELECT max(seq_num)
FROM hri_adm_dgnstc_setup
WHERE report_type = 'DATA'
AND seq_num < p_seq_num);



BEGIN
  --
  -- Check the nessages have been created
  --
  check_message(p_impact_msg_name);
  check_message(p_section_heading);
  check_message(p_section_count_desc);
  check_message(p_section_detail_desc);
  check_message(p_sub_section_heading);
  check_message(p_sub_section_count_desc);
  check_message(p_sub_section_detail_desc);
  check_message(p_heading_for_count);
  check_message(p_heading_for_column1);
  check_message(p_heading_for_column2);
  check_message(p_heading_for_column3);
  check_message(p_heading_for_column4);
  check_message(p_heading_for_column5);
  --
  -- Check if the functional area is valid
  --
  check_functional_area(p_functional_area_cd);
  --
  IF (p_sub_section_heading IS NOT NULL) THEN
     --
     OPEN cur_prev_heading;
     FETCH cur_prev_heading INTO l_prev_heading;
     CLOSE cur_prev_heading;
     --
     IF l_prev_heading <> p_section_heading THEN
       --
       output('Warning: The previous diagnostics does not have the same section heading');
       output('This must be the first sub-section of many diagnostics belonging to this section');
       --
     END IF;
     --
  END IF;
  --
  INSERT INTO hri_adm_dgnstc_setup
    (object_name,
    object_type,
    dynamic_sql,
    dynamic_sql_type,
    impact_msg_name,
    enabled_flag,
    foundation_hr_flag,
    --
    -- Section heading
    --
    object_type_msg_name,
    --
    -- Description for COUNT section
    --
    object_type_desc,
    --
    -- Description for DETAIL section
    --
    object_type_dtl_desc_msg_name,
    --
    -- Sub section heading
    --
    object_name_msg_name,
    --
    -- Description for COUNT sub section
    --
    object_name_desc,
    --
    -- Description for DETAIL sub section
    --
    object_name_dtl_desc_msg_name,
    --
    -- Heading for count column
    --
    count_heading,
    --
    -- Heading of columns in detail mode as ordered in the dynamic SQL
    --
    col_heading1,
    col_heading2,
    col_heading3,
    col_heading4,
    col_heading5,
    --
    default_mode,
    seq_num,
    report_type,
    functional_area_cd
    )
  VALUES
    (p_object_name,
    p_object_type,
    p_dynamic_sql,
    p_dynamic_sql_type,
    p_impact_msg_name,
    p_enabled_flag,
    p_foundation_hr_flag,
    p_section_heading,
    p_section_count_desc,
    p_section_detail_desc,
    p_sub_section_heading,
    p_sub_section_count_desc,
    p_sub_section_detail_desc,
    p_heading_for_count,
    p_heading_for_column1,
    p_heading_for_column2,
    p_heading_for_column3,
    p_heading_for_column4,
    p_heading_for_column5,
    p_default_sql_mode,
    p_seq_num,
    'DATA',
    p_functional_area_cd
    );
    --
    COMMIT;
    --
EXCEPTION
  WHEN e_data_error THEN
    --
    RAISE;
    --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END create_data_diagnostics;
--
-- This procedure is used to delete an object from  the diagnostics metadata table
--
PROCEDURE delete_object
  (p_object_name IN VARCHAR2,
  p_object_type IN VARCHAR2,
  p_report_type IN VARCHAR2,
  p_functional_area_cd IN VARCHAR2)
IS
--
BEGIN
  --
  DELETE FROM hri_adm_dgnstc_setup
  WHERE object_name = p_object_name
  AND object_type = p_object_type
  AND report_type = p_report_type
  AND functional_area_cd = p_functional_area_cd;
  --
  output(SQL%ROWCOUNT || ' row deleted.');
  --
  COMMIT;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    RAISE;
    --
END delete_object;
--
END hri_apl_diagnostics;

/
