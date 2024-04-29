--------------------------------------------------------
--  DDL for Package Body HR_DU_DO_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DU_DO_ENTITIES" AS
/* $Header: perduent.pkb 120.0 2005/05/31 17:20:24 appldev noship $ */



-- --------------------------- CREATE_DEFAULT_EMPLOYEE --------------------------
-- Description: It has been separated for the Employee API creates a
-- USER_KEY for assignment it adds 'ASG' to the end of the user key. Apart
-- from that its practically identical to DEFALULT_API
--
--  Input Parameters
--      p_upload_id        - HR_DU_UPLOAD_ID to be used
--
--   p_batch_id        - PUMP_BATCH_HEADER_ID
--
--   p_api_module_id    - API_MODULE_ID
--
--   p_process_order    - Number to tell data pump the order in which
--                           to process the record
--
--   p_upload_line_id   - ID of the line in the HR_DU_UPLOAD_LINES
--                           table that holds all the data to be
--                           pushed into the HR_PUMP_BATCH_LINES
--
--  p_pump_batch_line_id   - Identifies the Pump batch line to be used
-- ------------------------------------------------------------------------
PROCEDURE CREATE_DEFAULT_EMPLOYEE(
             p_values_table IN hr_du_do_datapump.R_INSERT_STATEMENT_TYPE
            ,p_upload_id IN NUMBER
            ,p_batch_id IN NUMBER
            ,p_api_module_id IN NUMBER
            ,p_process_order IN NUMBER
            ,p_upload_line_id IN NUMBER
         ,p_api_name IN VARCHAR2
            ,p_pump_batch_line_id IN NUMBER)
IS

  e_fatal_error               EXCEPTION;
  l_fatal_error_message            VARCHAR2(2000);
  l_parent_user_key           VARCHAR2(2000);
  l_foreign_user_key               VARCHAR2(50);
  l_parent_user_key_2              VARCHAR2(2000);
  l_foreign_user_key_2             VARCHAR2(50);
  l_row_id                    NUMBER;
  l_number_refs                    NUMBER;
  l_pval_parent_line_id            VARCHAR2(2000);
  l_parent_api_module_number       VARCHAR2(2000);
  l_pval_api_module_number         VARCHAR2(2000);
  l_temp_id                   VARCHAR2(2000);
  l_temp_api_module           VARCHAR2(2000);
  l_insert_statement               VARCHAR2(32767);
  l_cursor_handle             INT;
  l_rows_processed            INT;

  CURSOR csr_line_id IS
   SELECT PVAl001
   FROM hr_du_upload_lines
   WHERE UPLOAD_LINE_ID = p_upload_line_id;


BEGIN
--
  hr_du_utility.message('ROUT','entry:hr_du_do_entities.create_default_employee',
                                5);
  hr_du_utility.message('PARA', '(p_values_table - ** Record Structure** ' ||
                    ')(p_upload_id  - ' || p_upload_id  ||
                    ')(p_batch_id - ' || p_batch_id ||
                    ')(p_api_module_id - ' || p_api_module_id ||
                    ')(p_process_order - ' || p_process_order ||
                    ')(p_upload_line_id - ' || p_upload_line_id || ')'
                                , 10);
--
  --Statement extracts the ID number for the particular upload_line_id
  --that was passed in.

  hr_du_utility.message('INFO','p_upload_line_id  : ' || p_upload_line_id, 15);

  OPEN csr_line_id;
  --
    FETCH csr_line_id INTO l_row_id;
    IF csr_line_id%NOTFOUND THEN
      l_fatal_error_message := ' Unable to retrieve the ID';
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_line_id;

  l_parent_user_key := hr_du_do_datapump.RETURN_CREATED_USER_KEY_2(l_row_id,
                           p_values_table.r_api_id, p_upload_line_id,
                           l_foreign_user_key);

  hr_du_utility.message('INFO','l_row_id  : ' || l_row_id  , 25);
  hr_du_utility.message('INFO','l_parent_user_key : ' || l_parent_user_key , 30);
  hr_du_utility.message('INFO','l_foreign_user_key  : '||l_foreign_user_key  , 35);

  hr_du_di_insert.g_current_delimiter   := ',';

  hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_parent_line_id);

-- *********************************************************************************************************************
/*
  l_number_refs := hr_du_di_insert.WORDS_ON_LINE(
                                 p_values_table.r_pval_parent_line_id);

  hr_du_utility.message('INFO','r_pval_parent_line_id  : ' ||
                                 p_values_table.r_pval_parent_line_id , 40);
  hr_du_utility.message('INFO','l_number_refs : ' || l_number_refs , 45);

  --check to see if this api_module has any columns that may contain data to
  --indicate that it has been called by another api_module

  IF l_number_refs > 0 THEN
    FOR j IN 1..l_number_refs LOOP
      --values must be set to null here or else floating API's with no
      --references will take the last values in the loop
      l_parent_user_key_2 := null;
      l_foreign_user_key_2 := null;

      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                               p_values_table.r_pval_parent_line_id );

      l_pval_parent_line_id :=  hr_du_di_insert.Return_Word(
                              p_values_table.r_pval_parent_line_id , j);


      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                               p_values_table.r_parent_api_module_number);

      l_parent_api_module_number :=  hr_du_di_insert.Return_Word(
                             p_values_table.r_parent_api_module_number , j);

      hr_du_utility.message('INFO','l_pval_parent_line_id  : ' ||
                                 l_pval_parent_line_id  , 50);
      hr_du_utility.message('INFO','l_parent_api_module_number  : ' ||
                               l_parent_api_module_number  , 55);


      --check to see if referencing column is a generic reference. If null
      --then it is
      IF l_parent_api_module_number IS NOT NULL THEN
        --want to extract the value in the id column
        l_temp_id :=  hr_du_dp_pc_conversion.return_field_value
                             ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                              'UPLOAD_LINE_ID', l_pval_parent_line_id);

        hr_du_utility.message('INFO','l_temp_id 1  : ' || l_temp_id  , 65);

        --Check to see if there's a value with in the reference column of
        --the api_module
        IF l_temp_id IS NOT NULL THEN
       l_parent_user_key_2 := hr_du_do_datapump.RETURN_CREATED_USER_KEY(
                                 l_parent_api_module_number, l_temp_id,
                                 p_upload_id, l_foreign_user_key_2);

          hr_du_utility.message('INFO', 'l_temp_id  : ' || l_temp_id , 70);
          hr_du_utility.message('INFO', 'l_parent_api_module_number  : ' ||
                                    l_parent_api_module_number  , 75);
          hr_du_utility.message('INFO', 'l_parent_user_key_2  : ' ||
                                    l_parent_user_key_2 , 80);
          hr_du_utility.message('INFO', 'l_foreign_user_key_2  : ' ||
                                    l_foreign_user_key_2  , 85);
          EXIT;
        END IF;
        --generic column
      ELSE
        --want to extract both the table and id values
        l_temp_id :=  hr_du_dp_pc_conversion.return_field_value
                             ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                              'UPLOAD_LINE_ID', l_pval_parent_line_id);

        hr_du_utility.message('INFO','l_temp_id 2  : ' || l_temp_id  , 90);

        -- Check to see if there's a value with in the reference column
        --of that api_module
        IF l_temp_id IS NOT NULL THEN
          l_temp_api_module :=  hr_du_dp_pc_conversion.return_field_value
                            ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                             'UPLOAD_LINE_ID', l_pval_api_module_number);

          hr_du_utility.message('INFO', 'l_temp_api_module  : ' || l_temp_api_module , 95);

       l_parent_user_key_2 := hr_du_do_datapump.RETURN_CREATED_USER_KEY(
                                   l_temp_api_module, l_temp_id,
                                   p_upload_id, l_foreign_user_key_2);

          hr_du_utility.message('INFO','l_temp_api_module  : ' ||l_temp_api_module  , 100);
          hr_du_utility.message('INFO','l_parent_user_key_2  : ' ||
                                   l_parent_user_key_2 , 105);
          hr_du_utility.message('INFO','l_foreign_user_key_2  : ' ||
                                   l_foreign_user_key_2  , 110);

        END IF;
      END IF;
    END LOOP;
  END IF;
*/
--********************************************************************************************************************


  --its here that I have to write the insert statement that will be general
  --enough to take in API's that have no references and ones that do
  l_insert_statement := 'insert into HRDPV_' || p_api_name || '(' ||
                   'BATCH_ID,           BATCH_LINE_ID, '||
                        'API_MODULE_ID, LINE_STATUS,   '||
                        'USER_SEQUENCE,      LINK_VALUE,    '||
                             l_foreign_user_key || ',';

  l_insert_statement := l_insert_statement || 'p_assignment_user_key, ' ;

  l_insert_statement := l_insert_statement || p_values_table.r_insert_string;

  --add the closing bracket to the insert statement
  l_insert_statement := l_insert_statement  || ')';

  --begin creating the values string which will be pushed into the stated
  -- places
  l_insert_statement := l_insert_statement || 'select  ' ||
                   p_batch_id || ',' || p_pump_batch_line_id ||','||
                   p_api_module_id || ', ''U'',' ||
                   p_process_order || ',' || '1' || ',' ||
                            '''' ||l_parent_user_key || ''',' ||
                            '''' ||l_parent_user_key || ':ASG' || ''',';

  l_insert_statement := l_insert_statement || p_values_table.r_PVAL_string;
  l_insert_statement := l_insert_statement || ' FROM HR_DU_UPLOAD_LINES ' ||
                            'WHERE UPLOAD_LINE_ID = ' || p_upload_line_id;

  hr_du_utility.message('INFO','l_foreign_user_key  : ' || l_foreign_user_key , 115);

  hr_du_utility.message('INFO', 'l_insert_statement - ' || l_insert_statement,35);

  hr_du_utility.dynamic_sql(l_insert_statement);

--
  hr_du_utility.message('ROUT','exit:hr_du_do_entities.create_default_employee', 115);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_entities.create_default_employee'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_do_entities.create_default_employee'
                                  ,'(none)', 'R');
    RAISE;

--
END CREATE_DEFAULT_EMPLOYEE;

-- --------------------------- DEFAULT_API ------------------------------
-- Description: This is the default procedure that handles those APIs
-- that fall in to the general catogory of been referenced and referencing
-- others.
--
--  Input Parameters
--      p_upload_id        - HR_DU_UPLOAD_ID to be used
--
--   p_batch_id        - PUMP_BATCH_HEADER_ID
--
--   p_api_module_id    - API_MODULE_ID
--
--   p_process_order    - Number to tell data pump the order in which
--                           to process the record
--
--   p_upload_line_id   - ID of the line in the HR_DU_UPLOAD_LINES
--                           table that holds all the data to be
--                           pushed into the HR_PUMP_BATCH_LINES
--
--  p_pump_batch_line_id   - Identifies the Pump batch line to be used
-- ------------------------------------------------------------------------
PROCEDURE DEFAULT_API(
             p_values_table IN hr_du_do_datapump.R_INSERT_STATEMENT_TYPE
            ,p_upload_id IN NUMBER
            ,p_batch_id IN NUMBER
            ,p_api_module_id IN NUMBER
            ,p_process_order IN NUMBER
            ,p_upload_line_id IN NUMBER
         ,p_api_name IN VARCHAR2
            ,p_pump_batch_line_id IN NUMBER)
IS

  e_fatal_error               EXCEPTION;
  l_fatal_error_message            VARCHAR2(2000);
  l_parent_user_key           VARCHAR2(2000);
  l_foreign_user_key               VARCHAR2(50);
  l_parent_user_key_2              VARCHAR2(2000);
  l_foreign_user_key_2             VARCHAR2(50);
  l_row_id                    NUMBER;
  l_number_refs                    NUMBER;
  l_pval_parent_line_id            VARCHAR2(2000);
  l_parent_api_module_number       VARCHAR2(2000);
  l_pval_api_module_number         VARCHAR2(2000);
  l_temp_id                   VARCHAR2(2000);
  l_temp_api_module           VARCHAR2(2000);
  l_insert_statement               VARCHAR2(32767);
  l_cursor_handle             INT;
  l_rows_processed            INT;

  CURSOR csr_line_id IS
   SELECT PVAl001
   FROM hr_du_upload_lines
   WHERE UPLOAD_LINE_ID = p_upload_line_id;

BEGIN

--
  hr_du_utility.message('ROUT','entry:hr_du_do_entities.default_api', 5);
  hr_du_utility.message('PARA', '(p_values_table - ** Record Structure** ' ||
                    ')(p_upload_id  - ' || p_upload_id  ||
                    ')(p_batch_id - ' || p_batch_id ||
                    ')(p_api_module_id - ' || p_api_module_id ||
                    ')(p_process_order - ' || p_process_order ||
                    ')(p_upload_line_id - ' || p_upload_line_id || ')'
                                , 10);
--

  --Statement extracts the ID number for the particular upload_line_id
  --that was passed in.

  OPEN csr_line_id;
  --
    FETCH csr_line_id INTO l_row_id;
    IF csr_line_id%NOTFOUND THEN
      l_fatal_error_message := ' Unable to retrieve the ID';
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_line_id;

  l_parent_user_key := hr_du_do_datapump.RETURN_CREATED_USER_KEY_2(l_row_id,
                       p_values_table.r_api_id, p_upload_line_id,
                       l_foreign_user_key);


  hr_du_utility.message('INFO', 'l_row_id  : ' || l_row_id  , 15);
  hr_du_utility.message('INFO', 'l_parent_user_key : ' ||
                                 l_parent_user_key , 20);
  hr_du_utility.message('INFO', 'l_foreign_user_key  : ' ||
                                 l_foreign_user_key  , 25);

  hr_du_di_insert.g_current_delimiter   := ',';

  hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_parent_line_id);

  l_number_refs := hr_du_di_insert.WORDS_ON_LINE(
                                   p_values_table.r_pval_parent_line_id);

  hr_du_utility.message('INFO', 'r_pval_parent_line_id  : ' ||
                                   p_values_table.r_pval_parent_line_id , 30);
  hr_du_utility.message('INFO', 'l_number_refs : ' || l_number_refs , 35);


  --check to see if this api_module has any columns that may contain data to
  --indicate that it has been called by another api_module
  IF l_number_refs > 0 THEN
    FOR j IN 1..l_number_refs LOOP
      --values must be set to null here or else floating API's with no
      --references will take the last values in the loop
      l_parent_user_key_2 := null;
      l_foreign_user_key_2 := null;

       hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_parent_line_id);

      l_pval_parent_line_id :=  hr_du_di_insert.Return_Word(
                               p_values_table.r_pval_parent_line_id , j);


      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_parent_api_module_number);

      l_parent_api_module_number :=  hr_du_di_insert.Return_Word(
                                 p_values_table.r_parent_api_module_number, j);


      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_api_module_number);

      l_pval_api_module_number :=  hr_du_di_insert.Return_Word(
                       p_values_table.r_pval_api_module_number , j);

      hr_du_utility.message('INFO','l_pval_parent_line_id  : ' ||
                                       l_pval_parent_line_id  , 40);
      hr_du_utility.message('INFO','l_parent_api_module_number  : ' ||
                                     l_parent_api_module_number  , 45);

      --check to see if referencing column is a generic reference. If null
      --then it is

      IF l_parent_api_module_number IS NOT NULL THEN
        --want to extract the value in the id column
        l_temp_id :=  hr_du_dp_pc_conversion.return_field_value
                          ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                           'UPLOAD_LINE_ID', l_pval_parent_line_id);

        --Check to see if there's a value with in the reference column of
        --the api_module
        IF l_temp_id IS NOT NULL THEN
       l_parent_user_key_2 := hr_du_do_datapump.RETURN_CREATED_USER_KEY(
                                 l_parent_api_module_number, l_temp_id,
                                 p_upload_id, l_foreign_user_key_2);

          hr_du_utility.message('INFO','l_temp_id  : ' || l_temp_id , 60);
          hr_du_utility.message('INFO','l_parent_api_module_number  : ' ||
                                         l_parent_api_module_number  , 65);
          hr_du_utility.message('INFO','l_parent_user_key_2  : ' ||
                                         l_parent_user_key_2 , 70);
          hr_du_utility.message('INFO','l_foreign_user_key_2  : ' ||
                                         l_foreign_user_key_2  , 75);

          EXIT;
        END IF;

      --generic column
      ELSE
      --want to extract both the table and id values
        l_temp_id :=  hr_du_dp_pc_conversion.return_field_value
                          ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                           'UPLOAD_LINE_ID', l_pval_parent_line_id);

        -- Check to see if there's a value with in the reference column
        --of that api_module
        IF l_temp_id IS NOT NULL THEN
          l_temp_api_module :=  hr_du_dp_pc_conversion.return_field_value
                             ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                              'UPLOAD_LINE_ID', l_pval_api_module_number);


       l_parent_user_key_2 := hr_du_do_datapump.RETURN_CREATED_USER_KEY(
                                  l_temp_api_module, l_temp_id,
                                  p_upload_id, l_foreign_user_key_2);

          hr_du_utility.message('INFO', 'l_temp_id  : ' || l_temp_id, 85);
          hr_du_utility.message('INFO', 'l_temp_api_module  : ' || l_temp_api_module, 90);
          hr_du_utility.message('INFO', 'l_parent_user_key_2  : ' ||
                                         l_parent_user_key_2, 95);
          hr_du_utility.message('INFO', 'l_foreign_user_key_2  : ' ||
                                         l_foreign_user_key_2, 100);
        END IF;
      END IF;
    END LOOP;
  END IF;

  --its here that I have to write the insert statement that will be general
  --enough to take in API's that have no references and ones that do
  l_insert_statement := 'insert into HRDPV_' || p_api_name || '(' ||
                   'BATCH_ID,           BATCH_LINE_ID, '||
                        'API_MODULE_ID, LINE_STATUS,   '||
                        'USER_SEQUENCE,      LINK_VALUE,    '||
                             l_foreign_user_key || ',';

  --Glues on to the string the extra information if the api_module has a reference
  --to another api_module
  IF l_foreign_user_key_2 IS NOT NULL THEN
    l_insert_statement := l_insert_statement || l_foreign_user_key_2 || ',';
  END IF;

  l_insert_statement := l_insert_statement || p_values_table.r_insert_string;

  --add the closing bracket to the insert statement
  l_insert_statement := l_insert_statement  || ')';

  --begin creating the values string which will be pushed into the stated
  --places
  l_insert_statement := l_insert_statement || 'select  ' ||
                   p_batch_id || ',' || p_pump_batch_line_id ||','||
                   p_api_module_id || ', ''U'',' ||
                   p_process_order || ',' || '1' || ',' ||
                            '''' ||l_parent_user_key || ''',';

  IF l_foreign_user_key_2 IS NOT NULL THEN
    l_insert_statement := l_insert_statement || '''' || l_parent_user_key_2 || ''',';
  END IF;

  l_insert_statement := l_insert_statement || p_values_table.r_PVAL_string;

  l_insert_statement := l_insert_statement || ' FROM HR_DU_UPLOAD_LINES ' ||
                        'WHERE UPLOAD_LINE_ID = ' || p_upload_line_id;

  hr_du_utility.message('INFO','l_foreign_user_key  : ' || l_foreign_user_key , 115);

  hr_du_utility.message('INFO', 'l_insert_statement - ' || l_insert_statement,35);

  hr_du_utility.dynamic_sql(l_insert_statement);

--
  hr_du_utility.message('ROUT','exit:hr_du_do_entities.default_api', 105);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_entities.default_api'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
   hr_du_utility.error(SQLCODE, 'hr_du_do_entities.default_api','(none)', 'R');
   RAISE;
--
END DEFAULT_API;


-- ------------------------ UPDATE_EMP_ASG_CRITERIA ------------------------
-- Description: Deals specifically with the Assignment api_module, the reason
-- it has it's own procedure isn't  like the others for they have a
-- specified USER_KEY. ASSIGNMENT_USER_KEY has already been created with
-- the person api_module so I need retrieve the USER_KEY from the person.
-- This Procedure is only supported currently to be run with the person api_module
--
--  Input Parameters
--      p_upload_id        - HR_DU_UPLOAD_ID to be used
--
--   p_batch_id        - PUMP_BATCH_HEADER_ID
--
--   p_api_module_id    - API_MODULE_ID
--
--   p_process_order    - Number to tell data pump the order in which
--                           to process the record
--
--   p_upload_line_id   - ID of the line in the HR_DU_UPLOAD_LINES
--                           table that holds all the data to be
--                           pushed into the HR_PUMP_BATCH_LINES
--
--  p_pump_batch_line_id   - Identifies the Pump batch line to be used
--
-- ** This Procedure is currently supported with only the person api_module **
-- ------------------------------------------------------------------------
PROCEDURE UPDATE_EMP_ASG_CRITERIA(
             p_values_table IN hr_du_do_datapump.R_INSERT_STATEMENT_TYPE
            ,p_upload_id IN NUMBER
            ,p_batch_id IN NUMBER
            ,p_api_module_id IN NUMBER
            ,p_process_order IN NUMBER
            ,p_upload_line_id IN NUMBER
         ,p_api_name IN VARCHAR2
            ,p_pump_batch_line_id IN NUMBER)
IS

  e_fatal_error               EXCEPTION;
  l_fatal_error_message            VARCHAR2(2000);
  l_parent_user_key           VARCHAR2(2000);
  l_foreign_user_key               VARCHAR2(50);
  l_parent_user_key_2              VARCHAR2(2000);
  l_foreign_user_key_2             VARCHAR2(50);
  l_row_id                    NUMBER;
  l_number_refs                    NUMBER;
  l_pval_parent_line_id            VARCHAR2(2000);
  l_parent_api_module_number       VARCHAR2(2000);
  l_pval_api_module_number         VARCHAR2(2000);
  l_temp_id                   VARCHAR2(2000);
  l_temp_api_module           VARCHAR2(2000);
  l_insert_statement               VARCHAR2(32767);
  l_cursor_handle             INT;
  l_rows_processed            INT;

  CURSOR csr_line_id IS
   SELECT PVAl001
   FROM hr_du_upload_lines
   WHERE UPLOAD_LINE_ID = p_upload_line_id;

BEGIN

--
  hr_du_utility.message('ROUT',
                        'entry:hr_du_do_entities.update_emp_asg_criteria', 5);
  hr_du_utility.message('PARA', '(p_values_table - ** Record Structure** ' ||
                    ')(p_upload_id  - ' || p_upload_id  ||
                    ')(p_batch_id - ' || p_batch_id ||
                    ')(p_api_module_id - ' || p_api_module_id ||
                    ')(p_process_order - ' || p_process_order ||
                    ')(p_upload_line_id - ' || p_upload_line_id || ')'
                                , 10);
--
  --Statement extracts the ID number for the particular upload_line_id
  --that was passed in.

  OPEN csr_line_id;
  --
    FETCH csr_line_id INTO l_row_id;
    IF csr_line_id%NOTFOUND THEN
      l_fatal_error_message := ' Unable to retrieve the ID';
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_line_id;

  l_parent_user_key := hr_du_do_datapump.RETURN_CREATED_USER_KEY_2(l_row_id,
                           p_values_table.r_api_id, p_upload_line_id,
                           l_foreign_user_key);

  hr_du_utility.message('INFO','l_row_id  : ' || l_row_id  , 15);
  hr_du_utility.message('INFO', 'l_parent_user_key : ' || l_parent_user_key , 20);
  hr_du_utility.message('INFO', 'l_foreign_user_key  : ' || l_foreign_user_key, 25);

  hr_du_di_insert.g_current_delimiter   := ',';

  hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_parent_line_id);

  l_number_refs := hr_du_di_insert.WORDS_ON_LINE(
                                    p_values_table.r_pval_parent_line_id);

  hr_du_utility.message('INFO','r_pval_parent_line_id  : ' ||
                           p_values_table.r_pval_parent_line_id , 30);
  hr_du_utility.message('INFO', 'l_number_refs : ' || l_number_refs , 35);

  --check to see if this api_module has any columns that may contain
  --data to indicate that it has been called by another api_module

  IF l_number_refs > 0 THEN
    FOR j IN 1..l_number_refs LOOP
      --values must be set to null here or else floating API's with no
      --references will take the last values in the loop
      l_parent_user_key_2 := null;
      l_foreign_user_key_2 := null;

      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_parent_line_id);

      l_pval_parent_line_id :=hr_du_di_insert.Return_Word(
                              p_values_table.r_pval_parent_line_id , j);


      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_parent_api_module_number);

      l_parent_api_module_number := hr_du_di_insert.Return_Word(
                             p_values_table.r_parent_api_module_number, j);


      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_api_module_number);

      l_pval_api_module_number :=  hr_du_di_insert.Return_Word(
                       p_values_table.r_pval_api_module_number , j);

      hr_du_utility.message('INFO','l_pval_parent_line_id  : ' ||
                               l_pval_parent_line_id  , 40);
      hr_du_utility.message('INFO','l_parent_api_module_number  : ' ||
                               l_parent_api_module_number  , 45);
      hr_du_utility.message('INFO','l_pval_api_module_number  : ' ||
                               l_pval_api_module_number  , 50);

      --check to see if referencing column is a generic reference. If null
      --then it is
      IF l_parent_api_module_number IS NOT NULL THEN
        --want to extract the value in the id column
        l_temp_id :=  hr_du_dp_pc_conversion.return_field_value
                             ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                              'UPLOAD_LINE_ID', l_pval_parent_line_id);

        --Check to see if there's a value with in the reference column of
        --the api_module
        IF l_temp_id IS NOT NULL THEN
       l_parent_user_key_2 := hr_du_do_datapump.RETURN_CREATED_USER_KEY(
                                 l_parent_api_module_number, l_temp_id,
                                 p_upload_id, l_foreign_user_key_2);

          hr_du_utility.message('INFO', 'l_temp_id  : ' || l_temp_id , 55);
          hr_du_utility.message('INFO', 'l_parent_api_module_number  : ' ||
                                    l_parent_api_module_number  , 60);
          hr_du_utility.message('INFO', 'l_parent_user_key_2  : ' ||
                                    l_parent_user_key_2 , 65);
          hr_du_utility.message('INFO', 'l_foreign_user_key_2  : ' ||
                                    l_foreign_user_key_2  , 70);
          EXIT;
        END IF;
        --generic column
      ELSE
        --want to extract both the table and id values
        l_temp_id :=  hr_du_dp_pc_conversion.return_field_value
                             ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                              'UPLOAD_LINE_ID', l_pval_parent_line_id);

        --Check to see if there's a value with in the reference column
        --of that api_module
        IF l_temp_id IS NOT NULL THEN
          l_temp_api_module :=  hr_du_dp_pc_conversion.return_field_value
                            ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                             'UPLOAD_LINE_ID', l_pval_api_module_number);

          hr_du_utility.message('INFO', 'l_temp_api_module  : ' || l_temp_api_module , 75);

       l_parent_user_key_2 := hr_du_do_datapump.RETURN_CREATED_USER_KEY(
                                   l_temp_api_module, l_temp_id,
                                   p_upload_id, l_foreign_user_key_2);

          hr_du_utility.message('INFO','l_temp_id  : ' || l_temp_id , 80);
          hr_du_utility.message('INFO','l_temp_api_module  : ' || l_temp_api_module  , 85);
          hr_du_utility.message('INFO','l_parent_user_key_2  : ' ||
                                   l_parent_user_key_2 , 90);
          hr_du_utility.message('INFO','l_foreign_user_key_2  : ' ||
                                   l_foreign_user_key_2  , 95);
        END IF;
      END IF;
    END LOOP;
  END IF;

  -- to get it working...
  l_foreign_user_key := 'P_ASSIGNMENT_USER_KEY';


  --its here that I have to write the insert statement that will be general
  --enough to take in API's that have no references and ones that do
  l_insert_statement := 'insert into HRDPV_' || p_api_name || '(' ||
                   'BATCH_ID,           BATCH_LINE_ID, '||
                        'API_MODULE_ID, LINE_STATUS,   '||
                        'USER_SEQUENCE,      LINK_VALUE,    '||
                             l_foreign_user_key || ',';

  l_insert_statement := l_insert_statement || p_values_table.r_insert_string;

  --add the closing bracket to the insert statement
  l_insert_statement := l_insert_statement  || ')';

  --begin creating the values string which will be pushed into the
  --stated places
  l_insert_statement := l_insert_statement || 'select  ' ||
                   p_batch_id || ',' || p_pump_batch_line_id || ',' ||
                   p_api_module_id || ', ''U'',' ||
                   p_process_order || ',' || '1' || ',' ||
                            '''' ||l_parent_user_key_2 || ':ASG' || ''',';

  l_insert_statement := l_insert_statement || p_values_table.r_PVAL_string;
  l_insert_statement := l_insert_statement || ' FROM HR_DU_UPLOAD_LINES ' ||
                            'WHERE UPLOAD_LINE_ID = ' || p_upload_line_id;

  hr_du_utility.message('INFO','l_foreign_user_key  : ' || l_foreign_user_key , 115);
  hr_du_utility.message('INFO', 'l_insert_statement - ' || l_insert_statement,35);

  hr_du_utility.dynamic_sql(l_insert_statement);

--
  hr_du_utility.message('ROUT','exit:hr_du_do_entities.update_emp_asg_criteria', 100);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_entities.update_emp_asg_criteria'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
    hr_du_utility.error(SQLCODE, 'hr_du_do_entities.update_emp_asg_criteria',
    '(none)', 'R');
    RAISE;

--
END UPDATE_EMP_ASG_CRITERIA;


-- --------------------------- DEFAULT_API_NULL ------------------------------
-- Description: This is the default procedure that handles those APIs
-- that don't specify a user key in their flat file
--
--  Input Parameters
--      p_upload_id        - HR_DU_UPLOAD_ID to be used
--
--   p_batch_id        - PUMP_BATCH_HEADER_ID
--
--   p_api_module_id    - API_MODULE_ID
--
--   p_process_order    - Number to tell data pump the order in which
--                           to process the record
--
--   p_upload_line_id   - ID of the line in the HR_DU_UPLOAD_LINES
--                           table that holds all the data to be
--                           pushed into the HR_PUMP_BATCH_LINES
--
--  p_pump_batch_line_id   - Identifies the Pump batch line to be used
-- ------------------------------------------------------------------------
PROCEDURE DEFAULT_API_NULL(
             p_values_table IN hr_du_do_datapump.R_INSERT_STATEMENT_TYPE
            ,p_upload_id IN NUMBER
            ,p_batch_id IN NUMBER
            ,p_api_module_id IN NUMBER
            ,p_process_order IN NUMBER
            ,p_upload_line_id IN NUMBER
         ,p_api_name IN VARCHAR2
            ,p_pump_batch_line_id IN NUMBER)
IS

  e_fatal_error               EXCEPTION;
  l_fatal_error_message            VARCHAR2(2000);
  l_parent_user_key           VARCHAR2(2000);
  l_foreign_user_key               VARCHAR2(50);
  l_parent_user_key_2              VARCHAR2(2000);
  l_foreign_user_key_2             VARCHAR2(50);
  l_row_id                    NUMBER;
  l_number_refs                    NUMBER;
  l_pval_parent_line_id            VARCHAR2(2000);
  l_parent_api_module_number       VARCHAR2(2000);
  l_pval_api_module_number         VARCHAR2(2000);
  l_temp_id                   VARCHAR2(2000);
  l_temp_api_module           VARCHAR2(2000);
  l_insert_statement               VARCHAR2(32767);
  l_cursor_handle             INT;
  l_rows_processed            INT;

  CURSOR csr_line_id IS
   SELECT PVAl001
   FROM hr_du_upload_lines
   WHERE UPLOAD_LINE_ID = p_upload_line_id;


BEGIN

--
  hr_du_utility.message('ROUT','entry:hr_du_do_entities.default_api_null', 5);
  hr_du_utility.message('PARA', '(p_values_table - ** Record Structure** ' ||
                    ')(p_upload_id  - ' || p_upload_id  ||
                    ')(p_batch_id - ' || p_batch_id ||
                    ')(p_api_module_id - ' || p_api_module_id ||
                    ')(p_process_order - ' || p_process_order ||
                    ')(p_upload_line_id - ' || p_upload_line_id || ')'
                                , 10);
--

  --Statement extracts the ID number for the particular upload_line_id
  --that was passed in.

  OPEN csr_line_id;
  --
    FETCH csr_line_id INTO l_row_id;
    IF csr_line_id%NOTFOUND THEN
      l_fatal_error_message := ' Unable to retrieve the ID';
      RAISE e_fatal_error;
    END IF;
  --
  CLOSE csr_line_id;

  hr_du_utility.message('INFO', 'l_row_id  : ' || l_row_id  , 15);

  hr_du_di_insert.g_current_delimiter   := ',';

-- no delimeters as we have 'none' as the user key
  hr_du_di_insert.g_delimiter_count := 0;

--
  l_number_refs := hr_du_di_insert.WORDS_ON_LINE(
                                   p_values_table.r_pval_parent_line_id);

  hr_du_utility.message('INFO', 'r_pval_parent_line_id  : ' ||
                                   p_values_table.r_pval_parent_line_id , 30);
  hr_du_utility.message('INFO', 'l_number_refs : ' || l_number_refs , 35);

  --check to see if this api_module has any columns that may contain data to
  --indicate that it has been called by another api_module

  IF l_number_refs > 0 THEN
    FOR j IN 1..l_number_refs LOOP
      --values must be set to null here or else floating API's with no
      --references will take the last values in the loop
      l_parent_user_key_2 := null;
      l_foreign_user_key_2 := null;

      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_parent_line_id);

      l_pval_parent_line_id :=  hr_du_di_insert.Return_Word(
                               p_values_table.r_pval_parent_line_id , j);

      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_parent_api_module_number);
      l_parent_api_module_number :=  hr_du_di_insert.Return_Word(
                                 p_values_table.r_parent_api_module_number, j);

      hr_du_di_insert.g_delimiter_count := hr_du_di_insert.Num_Delimiters(
                           p_values_table.r_pval_api_module_number);

      l_pval_api_module_number :=  hr_du_di_insert.Return_Word(
                       p_values_table.r_pval_api_module_number , j);

      hr_du_utility.message('INFO','l_pval_parent_line_id  : ' ||
                                       l_pval_parent_line_id  , 40);
      hr_du_utility.message('INFO','l_parent_api_module_number  : ' ||
                                     l_parent_api_module_number  , 45);
      hr_du_utility.message('INFO','l_pval_api_module_number  : ' ||
                                     l_pval_api_module_number  , 50);

      --check to see if referencing column is a generic reference. If null
      --then it is
      IF l_parent_api_module_number IS NOT NULL THEN
        --want to extract the value in the id column
        l_temp_id :=  hr_du_dp_pc_conversion.return_field_value
                          ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                           'UPLOAD_LINE_ID', l_pval_parent_line_id);

        hr_du_utility.message('INFO','l_temp_id 1  : ' || l_temp_id  , 55);

        --Check to see if there's a value with in the reference column of
        --the api_module
        IF l_temp_id IS NOT NULL THEN
       l_parent_user_key_2 := hr_du_do_datapump.RETURN_CREATED_USER_KEY(
                                 l_parent_api_module_number, l_temp_id,
                                 p_upload_id, l_foreign_user_key_2);

          hr_du_utility.message('INFO','l_temp_id  : ' || l_temp_id , 60);
          hr_du_utility.message('INFO','l_parent_api_module_number  : ' ||
                                         l_parent_api_module_number  , 65);
          hr_du_utility.message('INFO','l_parent_user_key_2  : ' ||
                                         l_parent_user_key_2 , 70);
          hr_du_utility.message('INFO','l_foreign_user_key_2  : ' ||
                                         l_foreign_user_key_2  , 75);

          EXIT;
        END IF;
        --generic column
      ELSE

      --want to extract both the table and id values
        l_temp_id :=  hr_du_dp_pc_conversion.return_field_value
                          ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                           'UPLOAD_LINE_ID', l_pval_parent_line_id);

        -- Check to see if there's a value with in the reference column
        --of that api_module
        IF l_temp_id IS NOT NULL THEN
          l_temp_api_module :=  hr_du_dp_pc_conversion.return_field_value
                             ('HR_DU_UPLOAD_LINES', p_upload_line_id,
                              'UPLOAD_LINE_ID', l_pval_api_module_number);

          hr_du_utility.message('INFO', 'l_temp_api_module  : ' || l_temp_api_module,
                                 80);

       l_parent_user_key_2 := hr_du_do_datapump.RETURN_CREATED_USER_KEY(
                                  l_temp_api_module, l_temp_id,
                                  p_upload_id, l_foreign_user_key_2);

          hr_du_utility.message('INFO', 'l_temp_id  : ' || l_temp_id , 85);
          hr_du_utility.message('INFO', 'l_temp_api_module  : ' || l_temp_api_module  , 90);
          hr_du_utility.message('INFO', 'l_parent_user_key_2  : ' ||
                                         l_parent_user_key_2 , 95);
          hr_du_utility.message('INFO', 'l_foreign_user_key_2  : ' ||
                                         l_foreign_user_key_2  , 100);

        END IF;
      END IF;
    END LOOP;
  END IF;

  --its here that I have to write the insert statement that will be general
  --enough to take in API's that have no references and ones that do
  l_insert_statement := 'insert into HRDPV_' || p_api_name || '(' ||
                   'BATCH_ID,           BATCH_LINE_ID, '||
                        'API_MODULE_ID, LINE_STATUS,   '||
                        'USER_SEQUENCE,      LINK_VALUE,    ';

  --Glues on to the string the extra information if the api_module has a reference
  --to another api_module
  IF l_foreign_user_key_2 IS NOT NULL THEN
    l_insert_statement := l_insert_statement || l_foreign_user_key_2 || ',';
  END IF;

  l_insert_statement := l_insert_statement || p_values_table.r_insert_string;

  --add the closing bracket to the insert statement
  l_insert_statement := l_insert_statement  || ')';

  --begin creating the values string which will be pushed into the stated
  --places
  l_insert_statement := l_insert_statement || 'select  ' ||
                   p_batch_id || ',' || p_pump_batch_line_id ||','||
                   p_api_module_id || ', ''U'',' ||
                   p_process_order || ',' || '1' || ',';

  IF l_foreign_user_key_2 IS NOT NULL THEN
    l_insert_statement := l_insert_statement || '''' || l_parent_user_key_2 || ''',';
  END IF;

  l_insert_statement := l_insert_statement || p_values_table.r_PVAL_string;

  l_insert_statement := l_insert_statement || ' FROM HR_DU_UPLOAD_LINES ' ||
                        'WHERE UPLOAD_LINE_ID = ' || p_upload_line_id;

  hr_du_utility.message('INFO', 'l_insert_statement - ' || l_insert_statement,35);

  hr_du_utility.message('INFO','l_foreign_user_key  : ' || l_foreign_user_key , 115);

  hr_du_utility.dynamic_sql(l_insert_statement);

--
  hr_du_utility.message('ROUT','exit:hr_du_do_entities.default_api_null', 105);
--

EXCEPTION
  WHEN e_fatal_error THEN
    hr_du_utility.error(SQLCODE,'hr_du_do_entities.default_api_null'
                        ,l_fatal_error_message, 'R');
    RAISE;
  WHEN OTHERS THEN
   hr_du_utility.error(SQLCODE, 'hr_du_do_entities.default_api_null','(none)', 'R');
   RAISE;
--
END DEFAULT_API_NULL;

END HR_DU_DO_ENTITIES;

/
