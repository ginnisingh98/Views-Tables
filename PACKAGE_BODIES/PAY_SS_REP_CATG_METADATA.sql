--------------------------------------------------------
--  DDL for Package Body PAY_SS_REP_CATG_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SS_REP_CATG_METADATA" AS
/* $Header: pyssrcmd.pkb 120.0.12000000.1 2007/07/09 12:28:34 vbattu noship $ */
--
  --------------------------------------------------------------------------------
  -- CREATE_PAYSLIP_RECORDS
  --------------------------------------------------------------------------------
  PROCEDURE create_payslip_records(p_business_group_id NUMBER )  IS
      --
      CURSOR  get_template_code IS
      SELECT  DISTINCT org_information4 template_code
      FROM    hr_organization_information
      WHERE   org_information_context = 'HR_SELF_SERVICE_BG_PREFERENCE'
      AND     organization_id         = p_business_group_id
      AND     org_information1        = 'PAYSLIP'
      AND     org_information3        = 'Y';
      --
      CURSOR  get_legislation_code IS
      SELECT  legislation_code
      FROM    per_business_groups
      WHERE   business_group_id = p_business_group_id;
      --
      CURSOR  get_report_group_id IS
      SELECT  report_group_id
      FROM    pay_report_groups
      WHERE   short_name                = 'PAYSLIP_REPORT'
      AND     report_group_name         = 'Generic Payslip Report';
      --
      CURSOR  get_report_category_id(c_leg_code VARCHAR2) IS
      SELECT  report_category_id
      FROM    pay_report_categories
      WHERE   category_name       = c_leg_code||' Payslip Report'
      AND     short_name 		  = c_leg_code||'_PAYSLIP_REPORT'
      AND     business_group_id   = p_business_group_id;
      --
      CURSOR  get_report_variables IS
      SELECT  report_variable_id
             ,report_definition_id
      FROM    pay_report_variables
      WHERE   business_group_id = p_business_group_id;
      --
      l_legislation_code      per_business_groups.legislation_code%TYPE;
      l_report_category_id    pay_report_categories.report_category_id%TYPE;
      l_report_group_id       pay_report_groups.report_group_id%TYPE;
      --
  BEGIN
      --
      OPEN  get_legislation_code;
      FETCH get_legislation_code INTO l_legislation_code;
      CLOSE get_legislation_code;
      --
      OPEN  get_report_category_id(l_legislation_code);
      FETCH get_report_category_id INTO l_report_category_id;
      CLOSE get_report_category_id;
      --
      IF l_report_category_id IS NULL THEN
          --
          INSERT INTO pay_report_categories
            ( REPORT_CATEGORY_ID,
              REPORT_GROUP_ID,
              CATEGORY_NAME,
              --LEGISLATION_CODE,
              SHORT_NAME,
              BUSINESS_GROUP_ID)
          SELECT
              PAY_REPORT_CATEGORIES_S.nextval,
              report_group_id,
              l_legislation_code||' Payslip Report',
              --'DK',
              l_legislation_code||'_PAYSLIP_REPORT',
              p_business_group_id
          FROM  pay_report_groups prg
          WHERE short_name        = 'PAYSLIP_REPORT'
          AND   report_group_name = 'Generic Payslip Report'
          AND	  NOT EXISTS
              (SELECT NULL
               FROM  pay_report_categories
               WHERE report_group_id    = prg.report_group_id
               AND   short_name         = l_legislation_code||'_PAYSLIP_REPORT'
               AND   category_name      = l_legislation_code||' Payslip Report');
          --
          --l_report_category_id := PAY_REPORT_CATEGORIES_S.currval;
          --
      END IF;
      --
      DELETE  FROM pay_report_variables
      WHERE   business_group_id =  p_business_group_id
      AND     report_definition_id IN ( SELECT report_definition_id
                                        from  pay_report_definitions
                                        where report_name = 'Generic Payslip Report (pdf)' );
      --
      DELETE  FROM pay_report_category_components
      WHERE   business_group_id =  p_business_group_id
      AND     report_category_id IN (   SELECT 	report_category_id
                                        FROM    pay_report_categories
                                        WHERE   short_name = l_legislation_code||'_PAYSLIP_REPORT');
      --
      OPEN  get_report_group_id;
      FETCH get_report_group_id INTO l_report_group_id;
      CLOSE get_report_group_id;
      --
      FOR csr_template_code IN get_template_code LOOP
          --
          INSERT INTO pay_report_variables
             ( REPORT_VARIABLE_ID,
               REPORT_DEFINITION_ID,
               DEFINITION_TYPE,
               NAME,
               VALUE,
               --LEGISLATION_CODE,
               BUSINESS_GROUP_ID)
          SELECT
              PAY_REPORT_VARIABLES_S.nextval,
              report_definition_id,
              'SS',
              l_legislation_code||' Payslip Template',
              csr_template_code.template_code,
              --'DK',
              p_business_group_id
          FROM  pay_report_definitions prd
          WHERE report_name         = 'Generic Payslip Report (pdf)'
          AND   report_group_id     = l_report_group_id
          AND	  NOT EXISTS
              (SELECT NULL
               FROM  pay_report_variables
               WHERE value                = csr_template_code.template_code
               AND   name                 = l_legislation_code||' Payslip Template'
               AND   report_definition_id = prd.report_definition_id);
          --
      END LOOP;
      --
      FOR csr_report_varables IN get_report_variables LOOP
          --
          INSERT INTO pay_report_category_components
              (REPORT_CATEGORY_COMP_ID,
               REPORT_CATEGORY_ID,
               REPORT_DEFINITION_ID,
               STYLE_SHEET_VARIABLE_ID,
               --LEGISLATION_CODE,
               BUSINESS_GROUP_ID)
          SELECT
              PAY_REPORT_CATEGORY_COMP_S.nextval,
              report_category_id,
              csr_report_varables.report_definition_id,
              csr_report_varables.report_variable_id,
              --'DK',
              p_business_group_id
          FROM  pay_report_categories prc
          WHERE short_name		 = l_legislation_code||'_PAYSLIP_REPORT'
          AND   category_name	     = l_legislation_code||' Payslip Report'
          AND   report_group_id    = l_report_group_id
          AND	  NOT EXISTS
              (SELECT NULL
               FROM  pay_report_category_components
               WHERE  report_category_id      = prc.report_category_id
               AND    report_definition_id    = csr_report_varables.report_definition_id
               AND    style_sheet_variable_id = csr_report_varables.report_variable_id);
          --
      END LOOP;
      --
  END create_payslip_records;
  --------------------------------------------------------------------------------
  -- create_rep_catg_metadata
  --------------------------------------------------------------------------------
  PROCEDURE create_rep_catg_metadata(errbuf  OUT NOCOPY  VARCHAR2
                                    ,retcode OUT NOCOPY  VARCHAR2
                                    ,p_business_group_id NUMBER
                                    ,p_document_type     VARCHAR2 )  IS
  BEGIN
      --
      IF p_document_type = 'PAYSLIP' THEN
        create_payslip_records(p_business_group_id);
      END IF;
      --
  END create_rep_catg_metadata;
--
END pay_ss_rep_catg_metadata;

/
