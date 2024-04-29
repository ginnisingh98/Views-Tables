--------------------------------------------------------
--  DDL for Package Body PAY_INS_CUSTOM_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_INS_CUSTOM_TEMPLATE" AS
/* $Header: payinscstmplt.pkb 120.0.12010000.4 2009/08/03 14:04:34 avenkatk noship $  */
 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name      PAY_INS_CUSTOM_TEMPLATE

  File      payinscstmplt.pkb

  Purpose   The purpose of this package is to register the user defined custom
                Templates into Payroll Tables i.e. PAY_REPORT_CATEGORUES,
        PAY_REPORT_CATEGORY_COMPONENTS AND PAY_REPORT_VARIABLES.

  Notes     Currently this procedure supports the following concurrent programs
                for which user defined custom templates can be registered :
        1.  Local Year End Interface Extract
        2.  Employee W-2 PDF
        3.  1099R Information Return - PDF
        4.  Check Writer (XML)
        5.  Deposit Advice (XML)
        6.  RL1 PDF
        7.  RL2 PDF
        8.  Direct Deposit (New Zealand)
        9.  Japan, Roster of Workers
        10. Japan, Employee Ledger
        Whenever any new concurrent programs is required to be added in this
        category i.e if any new conc programs is decided to have the flexibility
        of registering custom template, please edit the function GET_NAME.
        If the Concurrent program's short name differs from the corresponding
        data_source_code in table xdo_templates_b, this function needs one
        'elsif' clause to be added for that new concurrent program.

  Change History

  Date          User Id       Version    Description
  ============================================================================
  01-Sep-08     kagangul       115.0     Initial Version Created
  01-Oct-08     kagangul       115.4     Modified the Cursor csr_report_group_id
                                         to consider those Report Groups which
                                         are seeded by Core Payroll
                                         i.e. Legislation Code is NULL.
   03-Aug-09    avenkatk       115.5     Bug #8716056 - Added support for PER templates
   03-Aug-09    avenkatk       115.6     Resolved GSCC Warnings
  ============================================================================*/

DEBUG_MODE  BOOLEAN := FALSE;

PROCEDURE insert_custom_template(errbuf out nocopy VARCHAR2,
                 retcode out nocopy NUMBER,
                 p_conc_prog  IN VARCHAR2,
                 p_lookup_type_name IN VARCHAR2,
                 p_business_group_id IN NUMBER) IS

CURSOR csr_get_temp_codes(p_lookup_type IN VARCHAR) IS
SELECT lookup_code, meaning
FROM fnd_common_lookups
WHERE lookup_type = p_lookup_type
AND application_id IN (800,801)
AND sysdate between nvl(start_date_active,sysdate) AND nvl(end_date_active,sysdate)
AND enabled_flag = 'Y';

CURSOR csr_temp_code_dtls(p_template_code IN VARCHAR,
                          p_concurrent_prog IN VARCHAR) IS
SELECT xtl.template_code, xtl.template_name, xb.template_type_code
FROM xdo_templates_b xb, xdo_templates_tl xtl
WHERE xb.template_code = xtl.template_code
AND xb.application_short_name = xtl.application_short_name
AND xtl.application_short_name IN ('PAY', 'PER')        /* Bug 8716056 */
AND xb.template_status = 'E'
AND xtl.language = USERENV('LANG')
/*AND xb.data_source_code = decode(p_concurrent_prog,'LOCALW2XML','LOCALW2MAG',
                           'PAYUSW2PDF','PAYUSW2',
                           'EMP_1099R_PDF','PAYUS1099R',p_conc_prog)*/
AND xb.data_source_code = GET_NAME(p_concurrent_prog)
AND xtl.template_code = p_template_code;

CURSOR csr_report_group_id(p_report_group_short_name IN VARCHAR,
               p_legislation_code IN VARCHAR) IS
SELECT report_group_id
FROM pay_report_groups
WHERE short_name = p_report_group_short_name
AND business_group_id IS NULL
/*AND nvl(legislation_code,'US') = nvl(p_legislation_code,'US');*/
AND ((legislation_code = p_legislation_code) OR (legislation_code IS NULL));

CURSOR csr_report_category_id(p_report_group_id IN NUMBER,
                  p_category_short_name IN VARCHAR2,
                              p_business_group_id IN NUMBER
                             ) IS
SELECT report_category_id
FROM pay_report_categories
WHERE report_group_id = p_report_group_id
AND short_name = p_category_short_name
AND business_group_id = p_business_group_id
AND legislation_code IS NULL;

CURSOR csr_report_definition_id(p_report_group_id NUMBER) IS
SELECT report_definition_id
FROM pay_report_definitions
WHERE report_group_id = p_report_group_id;

CURSOR csr_report_cat_comp_id(p_report_category_id IN NUMBER,
                              p_report_definition_id IN NUMBER,
                  p_business_group_id IN NUMBER) IS
SELECT style_sheet_variable_id
FROM pay_report_category_components
WHERE report_category_id = p_report_category_id
AND report_definition_id = p_report_definition_id
AND business_group_id = p_business_group_id
AND legislation_code IS NULL;

CURSOR csr_report_variable_id(p_report_variable_id IN NUMBER,
                  p_business_group_id IN NUMBER) IS
SELECT report_variable_id
FROM pay_report_variables
WHERE report_variable_id = p_report_variable_id
AND business_group_id = p_business_group_id
AND legislation_code IS NULL;

lv_lookup_code          fnd_common_lookups.lookup_code%TYPE;
lv_meaning          fnd_common_lookups.meaning%TYPE;
lv_template_code        xdo_templates_tl.template_code%TYPE;
lv_template_name        xdo_templates_tl.template_name%TYPE;
lv_template_type_code       xdo_templates_b.template_type_code%TYPE;
lv_rg_short_name        fnd_common_lookups.description%TYPE;
lv_legislation_code     hr_organization_information.org_information9%TYPE;
ln_report_group_id      pay_report_groups.report_group_id%TYPE;
ln_report_category_id       pay_report_categories.report_category_id%TYPE;
ln_report_category_id_new   pay_report_categories.report_category_id%TYPE;
ln_report_definition_id     pay_report_definitions.report_definition_id%TYPE;
ln_definition_id        pay_report_definitions.report_definition_id%TYPE;
ln_style_sheet_id       pay_report_category_components.style_sheet_variable_id%TYPE;
ln_report_variable_id       pay_report_variables.report_variable_id%TYPE;
pn_report_variable_id       pay_report_variables.report_variable_id%TYPE;
lv_lookup_type_meaning      fnd_common_lookup_types.lookup_type_meaning%TYPE;
pn_report_category_comp_id  pay_report_category_components.report_category_comp_id%TYPE;

BEGIN

   fnd_file.put_line(fnd_file.log,'Starting ....');
   lv_legislation_code := get_legislation_code(p_business_group_id);
   fnd_file.put_line(fnd_file.log,'Business Group Id : ' || p_business_group_id);
   fnd_file.put_line(fnd_file.log,'Legislation Code : ' || lv_legislation_code);

   BEGIN
      SELECT description INTO lv_rg_short_name
      FROM fnd_common_lookups
      WHERE lookup_type = 'GEN_CUST_TEMP_CONC_PROGS'
      AND lookup_code = p_conc_prog
      AND application_id IN (800, 801)                                                  /* Bug 8716056 */
      AND SYSDATE between nvl(start_date_active,sysdate) AND nvl(end_date_active,sysdate)
      AND enabled_flag = 'Y';
      fnd_file.put_line(fnd_file.log,'Report Group Short Name : ' || lv_rg_short_name);
   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line(fnd_file.log,'Report Group Not Found : Please Contact Your Support Representative');
   END;

   BEGIN
      SELECT lookup_type_meaning INTO lv_lookup_type_meaning
      FROM fnd_common_lookup_types
      WHERE lookup_type = p_lookup_type_name;
      fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');
      fnd_file.put_line(fnd_file.log,'New Category Name : ' || lv_lookup_type_meaning);
   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line(fnd_file.log,'Report Category Not Found : Please Contact Your Support Representative');
   END;

   SELECT pay_report_categories_s.nextval INTO ln_report_category_id_new
   FROM DUAL;
   fnd_file.put_line(fnd_file.log,'New Category Id : ' || ln_report_category_id_new);
   fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');

   OPEN csr_get_temp_codes(p_lookup_type_name);
   LOOP

      FETCH csr_get_temp_codes INTO lv_lookup_code,lv_meaning;
      EXIT WHEN csr_get_temp_codes%NOTFOUND;
      fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');
      fnd_file.put_line(fnd_file.log,'Registering Template : ' || lv_lookup_code);
      OPEN csr_temp_code_dtls(lv_lookup_code,p_conc_prog);
      FETCH csr_temp_code_dtls INTO lv_template_code, lv_template_name, lv_template_type_code;

      IF csr_temp_code_dtls%FOUND THEN
     fnd_file.put_line(fnd_file.log,'Template Name : ' || lv_template_name);
     fnd_file.put_line(fnd_file.log,'Template Type : ' || lv_template_type_code);
         OPEN csr_report_group_id(lv_rg_short_name,lv_legislation_code);
     FETCH csr_report_group_id INTO ln_report_group_id;

     IF csr_report_group_id%FOUND THEN
        fnd_file.put_line(fnd_file.log,'Report Group Id : ' || ln_report_group_id);
        IF DEBUG_MODE THEN
           hr_utility.trace('Before Opening Category Cursor : csr_report_category_id');
           hr_utility.trace('ln_report_group_id='||ln_report_group_id);
           hr_utility.trace('p_lookup_type_name='||p_lookup_type_name);
           hr_utility.trace('p_business_group_id='||p_business_group_id);
        END IF;

            OPEN csr_report_category_id(ln_report_group_id,p_lookup_type_name,p_business_group_id);
        FETCH csr_report_category_id INTO ln_report_category_id;

        IF DEBUG_MODE THEN
           hr_utility.trace('After Opening Category Cursor : csr_report_category_id');
           hr_utility.trace('ln_report_category_id='||ln_report_category_id);
        END IF;

        IF csr_report_category_id%FOUND THEN

           OPEN csr_report_definition_id(ln_report_group_id);
           LOOP
          FETCH csr_report_definition_id INTO ln_report_definition_id;
              EXIT WHEN csr_report_definition_id%NOTFOUND;

              OPEN csr_report_cat_comp_id(ln_report_category_id,ln_report_definition_id,p_business_group_id);
              FETCH csr_report_cat_comp_id INTO ln_style_sheet_id;
          IF csr_report_cat_comp_id%FOUND THEN
             fnd_file.put_line(fnd_file.log,'Removing Template For Definition Id : ' || ln_report_definition_id);
             fnd_file.put_line(fnd_file.log,'Removing Template For Category Id : ' || ln_report_category_id);
             fnd_file.put_line(fnd_file.log,'Removing Style Sheet Id : ' || ln_style_sheet_id);
             OPEN csr_report_variable_id(ln_style_sheet_id,p_business_group_id);
             FETCH csr_report_variable_id INTO ln_report_variable_id;
             IF csr_report_variable_id%FOUND THEN
                fnd_file.put_line(fnd_file.log,'Removing Variable Id : ' || ln_style_sheet_id);
                IF DEBUG_MODE THEN
               hr_utility.trace('DELETE FROM pay_report_variables WHERE report_variable_id = ' || ln_report_variable_id);
            ELSE
               DELETE FROM pay_report_variables
                    WHERE report_variable_id = ln_report_variable_id;
            END IF;
             END IF;
             CLOSE csr_report_variable_id;
             IF DEBUG_MODE THEN
            hr_utility.trace('DELETE FROM pay_report_category_components WHERE style_sheet_variable_id = ' || ln_style_sheet_id);
             ELSE
                DELETE FROM pay_report_category_components
                    WHERE style_sheet_variable_id = ln_style_sheet_id;
             END IF;
              END IF;
          CLOSE csr_report_cat_comp_id;
           END LOOP;
           CLOSE csr_report_definition_id;
        END IF;
        CLOSE csr_report_category_id;

        ln_definition_id := get_definition_id(ln_report_group_id,lv_template_type_code,lv_template_code);

        fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');
        fnd_file.put_line(fnd_file.log,'Inserting Record Into PAY_REPORT_VARIABLES');
        fnd_file.put_line(fnd_file.log,'Definition Id ' || ln_definition_id);
        fnd_file.put_line(fnd_file.log,'Template Name ' || lv_template_name);
        fnd_file.put_line(fnd_file.log,'Template Code ' || lv_template_code);
        fnd_file.put_line(fnd_file.log,'Business Group Id ' || p_business_group_id);

        insert_report_variable(p_report_definition_id => ln_definition_id,
                   p_definition_type => 'SS',
                   p_name => lv_template_name,
                   p_value => lv_template_code,
                   p_business_group_id => p_business_group_id,
                   p_report_variable_id => pn_report_variable_id);

        fnd_file.put_line(fnd_file.log,'Report Variable Id ' || pn_report_variable_id);

        fnd_file.put_line(fnd_file.log,'Inserting Record Into PAY_REPORT_CATEGORY_COMPONENTS');
        fnd_file.put_line(fnd_file.log,'Category Id ' || ln_report_category_id_new);
        fnd_file.put_line(fnd_file.log,'Definition Id ' || ln_definition_id);
        fnd_file.put_line(fnd_file.log,'Style Sheet Id ' || pn_report_variable_id);
        fnd_file.put_line(fnd_file.log,'Business Group Id ' || p_business_group_id);

        insert_report_catg_comp(p_report_category_id => ln_report_category_id_new,
                    p_report_definition_id => ln_definition_id,
                    p_breakout_variable_id => NULL,
                    p_order_by_variable_id => NULL,
                    p_style_sheet_variable_id => pn_report_variable_id,
                    p_business_group_id => p_business_group_id,
                    p_report_category_comp_id => pn_report_category_comp_id);

        fnd_file.put_line(fnd_file.log,'Category Component Id ' || pn_report_category_comp_id);

         END IF;
     CLOSE csr_report_group_id;
      END IF;
      CLOSE csr_temp_code_dtls;
   END LOOP;
   CLOSE csr_get_temp_codes;

   IF DEBUG_MODE THEN
      hr_utility.trace('DELETE FROM pay_report_categories WHERE report_category_id = ' || ln_report_category_id);
   ELSE
      DELETE FROM pay_report_categories
               WHERE report_category_id = ln_report_category_id;
   END IF;

   fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');
   fnd_file.put_line(fnd_file.log,'Inserting Record Into PAY_REPORT_CATEGORIES');
   fnd_file.put_line(fnd_file.log,'Report Group Id ' || ln_report_group_id);
   fnd_file.put_line(fnd_file.log,'Category Name ' || lv_lookup_type_meaning);
   fnd_file.put_line(fnd_file.log,'Category Short Name ' || p_lookup_type_name);
   fnd_file.put_line(fnd_file.log,'Business Group Id ' || p_business_group_id);
   fnd_file.put_line(fnd_file.log,'Category Id ' || ln_report_category_id_new);

   insert_report_category(p_report_group_id => ln_report_group_id,
               p_category_name => lv_lookup_type_meaning,
               p_short_name => p_lookup_type_name,
               p_legislation_code => NULL,
               p_business_group_id => p_business_group_id,
               p_report_category_id => ln_report_category_id_new);

   fnd_file.put_line(fnd_file.log,'Template Registered Successfully');

END insert_custom_template;

FUNCTION get_legislation_code(p_business_group_id NUMBER)
RETURN VARCHAR2 IS

lv_legislation_code hr_organization_information.org_information9%TYPE;

BEGIN

   BEGIN
      SELECT org_information9 INTO lv_legislation_code
      FROM hr_organization_information
      WHERE org_information_context = 'Business Group Information'
      AND organization_id = p_business_group_id;
   EXCEPTION
      WHEN OTHERS THEN
         lv_legislation_code := NULL;
   END;

RETURN lv_legislation_code;

END get_legislation_code;

FUNCTION get_definition_id(pn_report_group_id NUMBER, pv_template_type_code VARCHAR2,
                pv_template_code VARCHAR2)
RETURN NUMBER IS

CURSOR csr_fetch_definition_id_one IS
SELECT report_definition_id
FROM pay_report_definitions
WHERE report_group_id = pn_report_group_id;

CURSOR csr_fetch_definition_id_mul IS
SELECT report_definition_id
FROM pay_report_definitions
WHERE report_group_id = pn_report_group_id
AND upper(report_name) LIKE  '%' || upper(substr(pv_template_code,(instr(pv_template_code,'_',-1) + 1),(length(pv_template_code) - instr(pv_template_code,'_',-1)))) || '%';
--AND report_type = decode(pv_template_type_code,'ETEXT','EFT',pv_template_type_code);

ln_report_definition_id     pay_report_definitions.report_definition_id%TYPE;
ln_tot_report_definitions   NUMBER;

BEGIN

   SELECT count(*) INTO ln_tot_report_definitions
   FROM pay_report_definitions
   WHERE report_group_id = pn_report_group_id;

   IF ln_tot_report_definitions = 1 THEN
      OPEN csr_fetch_definition_id_one;
      FETCH csr_fetch_definition_id_one INTO ln_report_definition_id;

      IF csr_fetch_definition_id_one%FOUND THEN
         RETURN ln_report_definition_id;
      END IF;
      CLOSE csr_fetch_definition_id_one;
   ELSE
      OPEN csr_fetch_definition_id_mul;
      FETCH csr_fetch_definition_id_mul INTO ln_report_definition_id;

      IF csr_fetch_definition_id_mul%FOUND THEN
         RETURN ln_report_definition_id;
      END IF;
      CLOSE csr_fetch_definition_id_mul;
   END IF;

END get_definition_id;


PROCEDURE insert_report_variable(p_report_definition_id NUMBER,
                                 p_definition_type      VARCHAR2,
                                 p_name                 VARCHAR2,
                                 p_value                VARCHAR2,
                     p_business_group_id    NUMBER,
                                 p_report_variable_id   out nocopy NUMBER) IS

l_proc_name       VARCHAR2(50);
BEGIN

   l_proc_name := 'INSERT_REPORT_VARIABLE';
   hr_utility.trace('Entering '||l_proc_name);
   hr_utility.trace('Inserting report variable '|| p_name);

   SELECT pay_report_variables_s.nextval INTO p_report_variable_id FROM DUAL;

   IF DEBUG_MODE THEN
      hr_utility.trace('INSERT INTO pay_report_variables(report_variable_id,report_definition_id,definition_type,name,value,legislation_code,business_group_id) ' ||
                   'VALUES(' ||p_report_variable_id||','||p_report_definition_id||','||p_definition_type||','||p_name||','||p_value||','||NULL||','||p_business_group_id||')');
   ELSE
      INSERT INTO pay_report_variables(report_variable_id,
                                       report_definition_id,
                                       definition_type,
                                       name,
                                       value,
                                       legislation_code,
                                       business_group_id)
      VALUES(p_report_variable_id,
         p_report_definition_id,
         p_definition_type,
         p_name,
         p_value,
         NULL,
         p_business_group_id);
   END IF;

   hr_utility.trace('Leaving '||l_proc_name);

END insert_report_variable;

PROCEDURE insert_report_catg_comp(p_report_category_id      NUMBER,
                  p_report_definition_id    NUMBER,
                  p_breakout_variable_id    NUMBER,
                  p_order_by_variable_id    NUMBER,
                  p_style_sheet_variable_id NUMBER,
                  p_business_group_id           NUMBER,
                  p_report_category_comp_id  out nocopy NUMBER) IS

l_proc_name       VARCHAR2(50);

BEGIN

   l_proc_name := 'INSERT_REPORT_CATEGORY_COMPONENT';
   hr_utility.trace('Entering '||l_proc_name);
   hr_utility.trace('Deleting report category component.');

   SELECT pay_report_category_comp_s.nextval INTO p_report_category_comp_id FROM DUAL;

   hr_utility.trace('Inserting report category component.');

   IF DEBUG_MODE THEN
      hr_utility.trace('INSERT INTO PAY_REPORT_CATEGORY_COMPONENTS(report_category_comp_id,report_category_id,report_definition_id,breakout_variable_id,order_by_variable_id,style_sheet_variable_id,legislation_code,business_group_id) ' ||
                           'VALUES (' ||p_report_category_comp_id||','||p_report_category_id||','||p_report_definition_id||','||p_breakout_variable_id||','||p_order_by_variable_id||','||p_style_sheet_variable_id||','||NULL||','||
               p_business_group_id||');');
   ELSE
      INSERT INTO PAY_REPORT_CATEGORY_COMPONENTS(report_category_comp_id,
                                                 report_category_id,
                                                 report_definition_id,
                                                 breakout_variable_id,
                                                 order_by_variable_id,
                                                 style_sheet_variable_id,
                                                 legislation_code,
                                                 business_group_id)
      VALUES (p_report_category_comp_id,
          p_report_category_id,
          p_report_definition_id,
          p_breakout_variable_id,
          p_order_by_variable_id,
          p_style_sheet_variable_id,
          NULL,
          p_business_group_id);
    END IF;

    hr_utility.trace('Leaving '||l_proc_name);

END insert_report_catg_comp;

PROCEDURE insert_report_category(p_report_group_id IN NUMBER,
                 p_category_name IN VARCHAR2,
                 p_short_name IN VARCHAR2,
                 p_legislation_code IN VARCHAR2,
                 p_business_group_id IN NUMBER,
                 p_report_category_id IN NUMBER) IS

l_proc_name       VARCHAR2(50);

BEGIN

   l_proc_name := 'INSERT_REPORT_CATEGORY';
   hr_utility.trace('Entering '||l_proc_name);
   hr_utility.trace('Inserting report category '|| p_short_name);

   IF DEBUG_MODE THEN
      hr_utility.trace('INSERT INTO pay_report_categories(report_category_id,report_group_id,category_name,short_name,legislation_code,business_group_id) ' ||
                           'VALUES ('||p_report_category_id||','||p_report_group_id||','||p_category_name||','||p_short_name||','||p_legislation_code||','||p_business_group_id||');');
   ELSE
      INSERT INTO pay_report_categories(report_category_id,
                                        report_group_id,
                                        category_name,
                                        short_name,
                                        legislation_code,
                                        business_group_id)
      VALUES (p_report_category_id,
              p_report_group_id,
          p_category_name,
          p_short_name,
          p_legislation_code,
          p_business_group_id);
   END IF;

    hr_utility.trace('Leaving '||l_proc_name);

END insert_report_category;

FUNCTION GET_NAME(p_conc_prog IN VARCHAR2)
-- This function accepts the short_name of a concurrent program
-- and returns the corresponding data_source_code in table
-- xdo_templates_b
RETURN  VARCHAR2
IS

BEGIN

   IF p_conc_prog = 'LOCALW2XML' THEN
      RETURN 'LOCALW2MAG';
   ELSIF p_conc_prog = 'PAYUSW2PDF' THEN
      RETURN 'PAYUSW2';
   ELSIF p_conc_prog = 'EMP_1099R_PDF' THEN
      RETURN 'PAYUS1099R';
   ELSE
      RETURN p_conc_prog;
   END IF;

END GET_NAME;

END pay_ins_custom_template;

/
