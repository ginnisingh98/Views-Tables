--------------------------------------------------------
--  DDL for Package Body PAY_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DRT" AS
/* $Header: pydrtut.pkb 120.0.12010000.6 2018/05/17 09:33:17 emunisek noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_drt
 Package File Name : pydrtut.pkb
 Description : Core Payroll package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 emunisek    08-Mar-2018   120.0   27660496  Created
 emunisek    12-Mar-2018   120.1   27660496  Modified parameters of function
                                             additional_filter
 emunisek    03-May-2018   120.2   27943094  Added new procedure pay_hr_post
 emunisek    16-May-2018   120.3   28025987  Modified signature of
                                             mask_value_udf to use ROWID
                                             instead of RAW for rowid
                                             parameter
 emunisek    17-May-2018   120.4   28038251  Modified signature of mask_value_udf
 emunisek    17-May-2018   120.5   28039494  Added pragma autonomous_transaction
                                             in additional_filter and
                                             mask_value_udf
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_drt.';

    -- Procedure to determine Business Group ID and Legislation Code
    PROCEDURE extract_details(p_person_id IN per_all_people_f.person_id%TYPE) IS

       CURSOR get_business_group_id (cp_person_id NUMBER) IS
       SELECT ppf.business_group_id
         FROM per_all_people_f ppf
        WHERE ppf.person_id = cp_person_id
          AND ROWNUM = 1;

       CURSOR get_legislation_code (cp_business_group_id NUMBER) IS
       SELECT pbg.legislation_code
         FROM per_business_groups pbg
        WHERE pbg.business_group_id = cp_business_group_id;

       l_procedure            VARCHAR2(100) := 'extract_details';
       l_business_group_id    per_all_people_f.business_group_id%TYPE;

    BEGIN

       hr_utility.trace('Entering '||g_package||l_procedure);
       hr_utility.trace('Parameters are ');
       hr_utility.trace('Person ID    : '||p_person_id);

       IF NVL(g_person_id,-1) <> p_person_id THEN

           g_person_id := p_person_id;

           hr_utility.trace('Determine Business Group ID');

           OPEN get_business_group_id(p_person_id);
           FETCH get_business_group_id INTO l_business_group_id;
           CLOSE get_business_group_id;

           IF NVL(g_business_group_id,-1) <> l_business_group_id THEN

               hr_utility.trace('Determine Legislation Code');

               g_business_group_id := l_business_group_id;

               OPEN get_legislation_code(l_business_group_id);
               FETCH get_legislation_code INTO g_legislation_code;
               CLOSE get_legislation_code;

           END IF;

       END IF;

       hr_utility.trace('Determined values are ');
       hr_utility.trace('Person ID         : '||g_person_id);
       hr_utility.trace('Business Group ID : '||g_business_group_id);
       hr_utility.trace('Legislation Code : '||g_legislation_code);
       hr_utility.trace('Leaving '||g_package||l_procedure);

    END extract_details;

    -- Function to return if the Row needs to be filtered out.
    -- If Y is returned, row will be considered for further processing.

    FUNCTION additional_filter(p_person_id   IN  per_all_people_f.person_id%TYPE,
                               p_table_name  IN  VARCHAR2,
                               p_row_id      IN  VARCHAR2)
    RETURN VARCHAR2 IS

       PRAGMA AUTONOMOUS_TRANSACTION;

       l_procedure            VARCHAR2(100) := 'additional_filter';
       l_business_group_id    per_all_people_f.business_group_id%TYPE;
       l_proc_statement       VARCHAR2(2000);
       l_proc_cursor          INTEGER;
       l_rows                 INTEGER;
       l_filter_value         VARCHAR2(100) := 'N';
       l_person_id            per_all_assignments_f.person_id%TYPE;

    BEGIN

       hr_utility.trace('Entering '||g_package||l_procedure);
       hr_utility.trace('Parameters are ');
       hr_utility.trace('Person ID    : '||p_person_id);
       hr_utility.trace('Table Name   : '||p_table_name);
       hr_utility.trace('Row ID       : '||p_row_id);

       l_person_id := p_person_id;

       extract_details(l_person_id);

       BEGIN

          hr_utility.trace('Calling Localization Code to determine Filter value');

          l_proc_statement := 'BEGIN pay_'||g_legislation_code||'_drt.additional_filter('
                              || ' p_person_id => :p_person_id,'
                              || ' p_business_group_id => :p_business_group_id, '
                              || ' p_row_id => :p_row_id, '
                              || ' p_table_name => :p_table_name, '
                              || ' p_filter_value => :p_filter_value ); END;';

          l_proc_cursor := dbms_sql.open_cursor;
          dbms_sql.parse(l_proc_cursor, l_proc_statement, dbms_sql.v7);
          dbms_sql.bind_variable(l_proc_cursor, 'p_person_id', g_person_id);
          dbms_sql.bind_variable(l_proc_cursor, 'p_business_group_id', g_business_group_id);
          dbms_sql.bind_variable(l_proc_cursor, 'p_row_id',p_row_id,100);
          dbms_sql.bind_variable(l_proc_cursor, 'p_table_name',p_table_name,100);
          dbms_sql.bind_variable(l_proc_cursor, 'p_filter_value',l_filter_value,100);

          l_rows := dbms_sql.execute(l_proc_cursor);

          dbms_sql.variable_value(l_proc_cursor, 'p_filter_value', l_filter_value);

          dbms_sql.close_cursor(l_proc_cursor);

          hr_utility.trace('Localization value for Filter value : '||l_filter_value);

       EXCEPTION

          WHEN OTHERS THEN

             IF  DBMS_SQL.IS_OPEN(l_proc_cursor) THEN
                dbms_sql.close_cursor(l_proc_cursor);
             END IF;

             IF SQLCODE = -6550 AND
                (INSTR(SQLERRM, 'PLS-00201') > 0 OR INSTR(SQLERRM, 'PLS-00302') > 0) THEN

                 hr_utility.trace('No Localization procedure defined for additional filter.');
                 l_filter_value := 'N';

             ELSE

                 hr_utility.trace('Error encountered. Below are details.');
                 hr_utility.trace('SQL Code    : '||SQLCODE);
                 hr_utility.trace('SQL Message : '||SQLERRM);
                 RAISE;

             END IF;

       END;

       l_filter_value := NVL(l_filter_value,'N');

       hr_utility.trace('Leaving '||g_package||l_procedure);
       hr_utility.trace('Return value '||l_filter_value);

       RETURN l_filter_value;

    END additional_filter;

    -- Function to return the user-defined value for given table column

    FUNCTION mask_value_udf(rowid       ROWID,
                            table_name  VARCHAR2,
                            column_name VARCHAR2,
                            person_id   NUMBER)
    RETURN VARCHAR2 IS

       PRAGMA AUTONOMOUS_TRANSACTION;

       l_procedure            VARCHAR2(100) := 'mask_value_udf';
       l_business_group_id    per_all_people_f.business_group_id%TYPE;
       l_row_id               VARCHAR2(100);
       l_udf_mask_value       VARCHAR2(2000);
       l_proc_statement       VARCHAR2(2000);
       l_proc_cursor          INTEGER;
       l_rows                 INTEGER;
       TYPE l_cursor IS REF CURSOR;
       l_udf_cursor           l_cursor;
       l_udf_statement        VARCHAR2(200);

    BEGIN

       hr_utility.trace('Entering '||g_package||l_procedure);
       hr_utility.trace('Parameters are ');
       --hr_utility.trace('Row ID RAW Format      : '||rowid);
       --l_row_id := UTL_RAW.CAST_TO_VARCHAR2(rowid);
       l_row_id := ROWIDTOCHAR(rowid);
       hr_utility.trace('Row ID Varchar2 Format : '||l_row_id);
       hr_utility.trace('Person ID              : '||person_id);
       hr_utility.trace('Table Name             : '||table_name);
       hr_utility.trace('Column Name            : '||column_name);

       extract_details(person_id);

       BEGIN

          hr_utility.trace('Calling Localization Code to determine User-Defined value');

          l_proc_statement := 'BEGIN pay_'||g_legislation_code||'_drt.mask_value_udf('
                              || ' p_person_id => :p_person_id,'
                              || ' p_business_group_id => :p_business_group_id, '
                              || ' p_row_id => :p_row_id, '
                              || ' p_table_name => :p_table_name, '
                              || ' p_column_name => :p_column_name, '
                              || ' p_udf_mask_value => :p_udf_mask_value ); END;';

          l_proc_cursor := dbms_sql.open_cursor;
          dbms_sql.parse(l_proc_cursor, l_proc_statement, dbms_sql.v7);
          dbms_sql.bind_variable(l_proc_cursor, 'p_person_id', g_person_id);
          dbms_sql.bind_variable(l_proc_cursor, 'p_business_group_id', g_business_group_id);
          dbms_sql.bind_variable(l_proc_cursor, 'p_row_id',l_row_id,100);
          dbms_sql.bind_variable(l_proc_cursor, 'p_table_name',table_name,100);
          dbms_sql.bind_variable(l_proc_cursor, 'p_column_name',column_name,100);
          dbms_sql.bind_variable(l_proc_cursor, 'p_udf_mask_value',l_udf_mask_value,2000);

          l_rows := dbms_sql.execute(l_proc_cursor);

          dbms_sql.variable_value(l_proc_cursor, 'p_udf_mask_value', l_udf_mask_value);

          dbms_sql.close_cursor(l_proc_cursor);

          hr_utility.trace('Localization value for User-Defined Value : '||l_udf_mask_value);

       EXCEPTION

          WHEN OTHERS THEN

             IF  DBMS_SQL.IS_OPEN(l_proc_cursor) THEN
                dbms_sql.close_cursor(l_proc_cursor);
             END IF;

             IF SQLCODE = -6550 AND
                (INSTR(SQLERRM, 'PLS-00201') > 0 OR INSTR(SQLERRM, 'PLS-00302') > 0) THEN

                 hr_utility.trace('No Localization procedure defined to User-Defined Value.');

                 l_udf_statement := 'SELECT '||column_name||' FROM '||table_name||
                                    ' WHERE rowid = :l_row_id';

                 hr_utility.trace('Return existing value itself as User-Defined value');
                 hr_utility.trace('Query Statement is '||l_udf_statement);

                 OPEN l_udf_cursor FOR l_udf_statement USING l_row_id;
                 FETCH l_udf_cursor INTO l_udf_mask_value;
                 CLOSE l_udf_cursor;

             ELSE

                 hr_utility.trace('Error encountered. Below are details.');
                 hr_utility.trace('SQL Code    : '||SQLCODE);
                 hr_utility.trace('SQL Message : '||SQLERRM);
                 RAISE;

             END IF;

       END;

       hr_utility.trace('Leaving '||g_package||l_procedure);
       hr_utility.trace('Return value '||l_udf_mask_value);

       RETURN l_udf_mask_value;

    END mask_value_udf;

    -- Procedure to clear data from PAY_PROCESS_EVENTS in Post Processing.

    PROCEDURE pay_hr_post(p_person_id NUMBER) IS

       l_procedure            VARCHAR2(100) := 'pay_hr_post';

    BEGIN

       hr_utility.trace('Entering '||g_package||l_procedure);
       hr_utility.trace('Parameters are ');
       hr_utility.trace('Person ID              : '||p_person_id);

       DELETE FROM pay_process_events
       WHERE assignment_id
       IN (SELECT assignment_id
             FROM per_all_assignments_f
            WHERE person_id = p_person_id);

       hr_utility.trace('Rows Deleted '||SQL%ROWCOUNT);

       hr_utility.trace('Leaving '||g_package||l_procedure);

    END pay_hr_post;

END pay_drt;

/
