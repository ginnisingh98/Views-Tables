--------------------------------------------------------
--  DDL for Package Body PAY_MX_DRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_DRT" AS
/* $Header: pymxdrt.pkb 120.0.12010000.6 2018/05/11 07:07:00 nvelaga noship $ */
/* ************************************************************************
 +======================================================================+
 |                Copyright (c) 2018, 2018 Oracle Corporation           |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 Package Body Name : pay_mx_drt
 Package File Name : pycadrt.pkb
 Description : US Payroll localization package for Data Removal Tool

 Change List:
 ------------

 Name        Date          Version Bug       Text
 ----------- ------------  ------- --------- ------------------------------
 sjawid     03-Mar-2018     120.0             Created
 sjawid     27-Mar-2018     120.0.12010000.3  Modified proc pay_mx_hr_post
 sjawid     29-Mar-2018     120.0.12010000.4  Added DRC procedure (dummy)
 nvelaga    11-May-2018     120.0.12010000.6  Bug 27980337 - Added overwrite_dis_reg_id
************************************************************************ */

    g_package   VARCHAR2(100) := 'pay_mx_drt.';


	PROCEDURE write_log
      (message IN varchar2
       ,stage   IN varchar2) IS
       BEGIN
       IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
          fnd_log.string (fnd_log.level_procedure
                          ,message
                          ,stage);
       END IF;
    END write_log;
--

--
  PROCEDURE PAY_MX_HR_DRC
      (person_id       IN         number
      ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

      l_proc varchar2(72);
      p_person_id varchar2(20);
      l_legislation_code varchar2(20);
	  l_success BOOLEAN;

  BEGIN

      l_proc := g_package|| 'pay_mx_hr_drc';
      write_log ('Entering:'|| l_proc,10);

      p_person_id := person_id;
      write_log ('p_person_id: '|| p_person_id,20);

      l_legislation_code := per_per_bus.return_legislation_code (p_person_id);
      write_log ('l_legislation_code: '|| l_legislation_code, 20);


    IF (l_legislation_code = 'MX') THEN

                pay_us_drt.pay_final_process_check
                                    (p_person_id         => p_person_id
                                    ,p_legislation_code  => l_legislation_code
                                    ,p_constraint_months => 18
                                    ,result_tbl          => result_tbl );

    END IF;

      write_log ('Leaving:'|| l_proc,999);

  END PAY_MX_HR_DRC;


   PROCEDURE pay_mx_hr_post(p_person_id NUMBER)
    IS

       l_procedure            VARCHAR2(100) := '.pay_mx_hr_post';
       l_business_group_id    per_all_people_f.business_group_id%TYPE;
       l_proc_statement       VARCHAR2(2000);
       l_proc_cursor          INTEGER;
       l_rows                 INTEGER;
      -- l_process_status       VARCHAR2(10);

    BEGIN
       hr_utility.trace('Entering '||g_package||l_procedure);
       hr_utility.trace('Parameters are ');
       hr_utility.trace('Person ID  : '||p_person_id);

       pay_drt.extract_details(p_person_id);
       hr_utility.trace('g_legislation_code  : '||pay_drt.g_legislation_code);

      IF pay_drt.g_legislation_code = 'MX' THEN

       pay_us_drt.purge_archive_data ( p_person_id => p_person_id
                                      ,p_legislation_code => pay_drt.g_legislation_code);
      END IF;

       hr_utility.trace('Leaving '||g_package||l_procedure);

    END pay_mx_hr_post;

    FUNCTION overwrite_dis_reg_id(rid IN ROWID,
                                  table_name IN VARCHAR2,
                                  column_name IN VARCHAR2,
                                  person_id IN NUMBER
                                 )
    RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
        l_dis_info_category PER_DISABILITIES_F.DIS_INFORMATION_CATEGORY%TYPE;
        l_registration_id   PER_DISABILITIES_F.REGISTRATION_ID%TYPE;
        l_overwrite_value   VARCHAR2(100);

        l_sql_stmt VARCHAR2(2000);

    BEGIN

        l_sql_stmt := 'SELECT '
                      || column_name
                      || ' ,dis_information_category '
                      || ' FROM '
                      || table_name
                      || ' WHERE rowid = :1';

        EXECUTE IMMEDIATE
            l_sql_stmt
        INTO l_registration_id,
             l_dis_info_category
        USING rid;

        IF l_dis_info_category = 'MX' THEN
            l_overwrite_value := 'AA111111';
        ELSE
            l_overwrite_value := l_registration_id;
        END IF;

        RETURN l_overwrite_value;

    END overwrite_dis_reg_id;

END pay_mx_drt;

/
