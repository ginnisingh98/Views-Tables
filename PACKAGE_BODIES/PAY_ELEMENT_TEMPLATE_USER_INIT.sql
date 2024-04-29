--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TEMPLATE_USER_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TEMPLATE_USER_INIT" AS
/* $Header: payeletmplusrini.pkb 120.4 2006/11/16 01:23:57 vpandya noship $ */
--

/*
================================================================================
    ******************************************************************
    *                                                                *
    *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
    *                   Chertsey, England.                           *
    *                                                                *
    *  All rights reserved.                                          *
    *                                                                *
    *  This material has been provided pursuant to an agreement      *
    *  containing restrictions on its use.  The material is also     *
    *  protected by copyright law.  No part of this material may     *
    *  be copied or distributed, transmitted or transcribed, in      *
    *  any form or by any means, electronic, mechanical, magnetic,   *
    *  manual, or otherwise, or disclosed to third parties without   *
    *  the express written permission of Oracle Corporation UK Ltd,  *
    *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
    *  England.                                                      *
    *                                                                *
    ******************************************************************

    Description: This package is used to create earning and deduction
                 elements using Element Templates for Oracle
                 International Payroll.

    Change List
    -----------
    Date         Name        Vers   Bug No   Description
    -----------  ----------  -----  -------  -----------------------------------
    12-NOV-2004  vpandya     115.0            Created.
    01-DEC-2004  vpandya     115.1            Made p_rec as IN parameter only,
                                              Also added l_rec.
                                              Calling update_shadow_element.
    12-DEC-2004  vpandya     115.2            Removed legislation rule check.
                                              And calling pre and post process
                                              package without checking leg rule.
    22-DEC-2004  vpandya     115.3            Added SYSTEM to Type Object in
                                              declaration section.
    05-JAN-2005  vpandya     115.4            Calling procedure
                                              ELEMENT_TEMPLATE_UPD_USER_STRU
                                              That is being called after
                                              User Structure generation (Shadow
                                              Schema ) and before creating Core
                                              Schema. Also calling
                                              fnd_request.submit_request to
                                              compile formula.
    27-JAN-2005   vmehta      115.5           Removed reference to SYSTEM schema
                                              from objects.
    18-FEB-2005   ssattini    115.6           Added code to create
                                              Sub-classification
                                              and Frequency Rules records.
    07-MAR-2005   ssattini    115.7           Added code to initialise
                                              Frequency Rule PL/SQL table
                                              used in Summary Page of Element
                                              Template Wizard.
    14-Apr-2005   vpandya     115.8,9 4300619 Setting default processing
                                              priority only when
                                              p_rec.processing_priority
                                              is null or it not in its range.
    28-APR-2005   pganguly    115.10          Added the delete_element
                                              procedure.
    04-MAY-2005   pganguly    115.11          Changed the procedure in
                                              delete_ element.
    01-AUG-2005   rdhingra    115.12  4518218 Removing code from the call of
                                              Cursor Name: get_proc_priority
                                              As decided, if the user is allowed
                                              to give his own priority then
                                              thats what should be carried
                                              forward.
    31-AUG-2005   vpandya     115.13  4585922 Added a cursor get_shd_formula_id
                                              and compiling formulas.
    14-Sep-2005   vpandya     115.14          Changed code for exception so that
                                              it raises error if inlined pkg
                                              returns any error.
    15-Nov-2006   vpandya     115.15  5609242 Added a function
                                              get_base_classification to get
                                              classification name in base (US)
                                              language if it entered in
                                              translated/pseudo language. Also
                                              used for sub classifications.
================================================================================
*/
--

  g_package  varchar2(50);


  FUNCTION get_base_classification ( p_legislation_code    IN VARCHAR2
                                    ,p_business_group_id   IN NUMBER
                                    ,p_classification_name IN VARCHAR2 )
  RETURN VARCHAR2 IS

    CURSOR c_base_class_name ( cp_legislation_code     VARCHAR2
                              ,cp_business_group_id    NUMBER
                              ,cp_classification_name  VARCHAR2 ) IS
      SELECT pec.classification_id
            ,pec.classification_name
            ,pect.language
        FROM pay_element_classifications_tl pect
            ,pay_element_classifications pec
       WHERE pect.classification_name = cp_classification_name
         AND pec.classification_id    = pect.classification_id
         AND ( pec.legislation_code   = cp_legislation_code OR
               pec.business_group_id  = cp_business_group_id )
        ORDER BY pec.classification_id DESC;

    ln_classification_id   NUMBER;
    lv_classification_name VARCHAR2(240);
    lv_language            VARCHAR2(240);

  BEGIN

    OPEN  c_base_class_name( p_legislation_code
                            ,p_business_group_id
                            ,p_classification_name );

    FETCH c_base_class_name INTO ln_classification_id
                                ,lv_classification_name
                                ,lv_language;
    CLOSE c_base_class_name;

    RETURN lv_classification_name;

  END get_base_classification;

  PROCEDURE create_element
    ( p_validate         IN               BOOLEAN
     ,p_save_for_later   IN               VARCHAR2
     ,p_rec              IN               PAY_ELE_TMPLT_OBJ
     ,p_sub_class        IN               PAY_ELE_SUB_CLASS_TABLE
     ,p_freq_rule        IN               PAY_FREQ_RULE_TABLE
     ,p_ele_template_id  OUT NOCOPY       NUMBER
    ) IS

    CURSOR get_template_id ( cp_legislation_code varchar2
                            ,cp_template_name    varchar2) IS
      SELECT template_id
      FROM   pay_element_templates
      WHERE  legislation_code = cp_legislation_code
      AND    template_name    = cp_template_name;

    CURSOR get_busgrp_info ( cp_business_group_name varchar2 ) IS
      SELECT business_group_id
            ,legislation_code
            ,currency_code
      FROM   per_business_groups
      WHERE  name = cp_business_group_name;

   CURSOR get_shd_ele_info ( cp_template_id       NUMBER
                            ,cp_element_name      VARCHAR2 ) IS
     SELECT element_type_id
           ,object_version_number
           ,payroll_formula_id
     FROM   pay_shadow_element_types
     WHERE  template_id  = cp_template_id
     AND    element_name = cp_element_name;

   CURSOR get_proc_priority ( cp_legislation_code     VARCHAR2
                             ,cp_classification_name  VARCHAR2 ) IS
     SELECT default_priority
           ,default_high_priority
           ,default_low_priority
     FROM   pay_element_classifications
     WHERE  legislation_code    = cp_legislation_code
     AND    classification_name = cp_classification_name;

   CURSOR get_rule_mode ( cp_legislation_code     VARCHAR2 ) IS
     SELECT rule_mode
     FROM   pay_legislation_rules
     WHERE  legislation_code    = cp_legislation_code
     AND    rule_type           = 'SEP_CHEQUE_IV';

   CURSOR get_shd_formula_id ( cp_template_id       NUMBER ) IS
     SELECT payroll_formula_id
     FROM   pay_shadow_element_types
     WHERE  template_id  = cp_template_id
     AND    payroll_formula_id IS NOT NULL;

   CURSOR get_formula_info ( cp_formula_id NUMBER ) IS
     SELECT ff.formula_name
           ,ft.formula_type_name
     FROM   pay_shadow_formulas psf
           ,ff_formulas_f ff
           ,ff_formula_types ft
     WHERE psf.formula_id     = cp_formula_id
     AND   psf.formula_name   = ff.formula_name
     AND   ff.formula_type_id = ft.formula_type_id;


    -- Cursor to get the core_schema element_type_id and
    -- shadow_schema element_type_id based on tempalte_id value

    CURSOR get_core_shadow_object_id( cp_template_id number
                                     ,cp_object_type varchar2) IS
    SELECT core_object_id
          ,shadow_object_id
    FROM  pay_template_core_objects
    WHERE template_id = cp_template_id
    AND   core_object_type = cp_object_type;

    -- Cursor to get payroll_id value based on payroll_name

    CURSOR get_payroll_id( cp_bg_id        number
                          ,cp_payroll_name varchar2
                          ,cp_eff_date     date) IS
    SELECT payroll_id
    FROM   pay_payrolls_f
    WHERE  business_group_id + 0 = cp_bg_id
    AND    payroll_name = cp_payroll_name
    AND    cp_eff_date between effective_start_date and effective_end_date;

     ln_business_group_id    NUMBER;
     lv_legislation_code     VARCHAR2(240);
     lv_currency_code        VARCHAR2(240);

     l_source_template_id    NUMBER;
     l_object_version_number NUMBER;

     l_proc                  VARCHAR2(240);

     lv_rule_mode            VARCHAR2(240);
     ln_iv_exists            NUMBER;

     l_ele_obj_ver_number    NUMBER;
     ln_shd_ele_type_id      NUMBER;
     ln_processing_priority  NUMBER;
     ln_proc_high_priority   NUMBER;
     ln_proc_low_priority    NUMBER;
     ln_payroll_formula_id   NUMBER;

     ln_req_id               NUMBER;
     lv_formula_name         VARCHAR2(240);
     lv_formula_type_name    VARCHAR2(240);

     l_rec                   PAY_ELE_TMPLT_OBJ;

     -- added for Sub-classifications
     lr_sub_class            pay_ele_sub_class_obj;
     lt_sub_class            PAY_ELE_SUB_CLASS_TABLE;

     lr_shadow_sub_class_rec pay_ssr_shd.g_rec_type;
     -- end of sub-classifications declare

     -- added for Frequency rules
     lr_freq_rule_rec        pay_freq_rule_obj;
     lt_freq_rule_table      PAY_FREQ_RULE_TABLE;
     ln_core_object_id       NUMBER;
     ln_shadow_object_id     NUMBER;
     ln_payroll_id           NUMBER;
     lv_period_6             VARCHAR2(1);

     -- end of frequency rules declare

  BEGIN  -- create_element

    l_rec := p_rec;

    -- added initialization for sub-classifications
    lr_sub_class := pay_ele_sub_class_obj(null);
    lt_sub_class := p_sub_class;

    lr_shadow_sub_class_rec.sub_classification_rule_id := null;
    lr_shadow_sub_class_rec.element_type_id := null;
    lr_shadow_sub_class_rec.element_classification := null;
    lr_shadow_sub_class_rec.object_version_number := null;
    lr_shadow_sub_class_rec.exclusion_rule_id := null;

    -- end of initialization of sub-classification

    -- added initialization for Frequency rules

    lr_freq_rule_rec   := pay_freq_rule_obj(null,null,null,
                                            null,null,null,null,null);
    lt_freq_rule_table := p_freq_rule;

    -- end of initialization of Frequency rules

    --hr_utility.trace_on(null, 'TMPLT');

    l_proc := g_package || 'create_element';

    hr_utility.set_location('Entering '||l_proc, 10);

    OPEN  get_busgrp_info(l_rec.business_group_name);
    FETCH get_busgrp_info INTO ln_business_group_id
                              ,lv_legislation_code
                              ,lv_currency_code;
    CLOSE get_busgrp_info;

    hr_utility.trace('Entered element_classification '||
                                      l_rec.element_classification);

    l_rec.element_classification :=
                  get_base_classification( lv_legislation_code
                                          ,ln_business_group_id
                                          ,l_rec.element_classification);

    hr_utility.trace('BASE element_classification '||
                                   l_rec.element_classification);

    IF l_rec.legislation_code IS NULL THEN
       l_rec.legislation_code := lv_legislation_code;
    END IF;

    hr_utility.set_location('Entering '||l_proc, 20);

    OPEN  get_template_id ( l_rec.legislation_code, l_rec.calculation_rule );
    FETCH get_template_id INTO l_source_template_id;
    CLOSE get_template_id;

    hr_utility.set_location(l_proc, 40);

    IF l_rec.process_mode IS NOT NULL AND
       l_rec.process_mode <> 'N' THEN

       lv_rule_mode := NULL;

       OPEN  get_rule_mode( l_rec.legislation_code );
       FETCH get_rule_mode INTO lv_rule_mode;
       CLOSE get_rule_mode;

       hr_utility.set_location(l_proc, 50);

       IF lv_rule_mode IS NOT NULL THEN

          SELECT COUNT(*)
          INTO   ln_iv_exists
          FROM   pay_shadow_element_types pset
                ,pay_shadow_input_values psiv
          WHERE  pset.template_id      = l_source_template_id
          AND    psiv.element_type_id  = pset.element_type_id
          AND    psiv.name             = lv_rule_mode;

          IF ln_iv_exists > 0 THEN

             IF l_rec.process_mode = 'S' THEN

                l_rec.configuration_information1 := 'Y';
                l_rec.configuration_information2 := 'Y';
                l_rec.configuration_information3 := 'Y';

             ELSIF l_rec.process_mode = 'P' THEN

                l_rec.configuration_information1 := 'Y';
                l_rec.configuration_information2 := 'N';
                l_rec.configuration_information3 := 'Y';

             END IF;

             hr_utility.set_location(l_proc, 60);

          END IF;

       END IF;

    END IF;

    /**********************************************************************
    ** Cursor Name: get_proc_priority
    ** Purpose    : This gets default priority, default high priority
    **              and default low priority of the element classification.
    **              Using entered priority if it is not null
    **********************************************************************/


    OPEN  get_proc_priority( l_rec.legislation_code
                           , l_rec.element_classification);
    FETCH get_proc_priority INTO ln_processing_priority
                                ,ln_proc_high_priority
                                ,ln_proc_low_priority;
    CLOSE get_proc_priority;


    IF p_rec.processing_priority is not null THEN

          ln_processing_priority := p_rec.processing_priority;

    END IF;

    hr_utility.set_location(l_proc, 70);

    BEGIN

       EXECUTE IMMEDIATE 'BEGIN :a := PAY_'||l_rec.legislation_code||
                         '_RULES.ELEMENT_TEMPLATE_PRE_PROCESS(:b); END;'
               USING OUT l_rec, IN l_rec;

       hr_utility.trace('l_rec.configuration_information1 ' ||
                         l_rec.configuration_information1);
       hr_utility.trace('l_rec.configuration_information4 ' ||
                         l_rec.configuration_information4);
       hr_utility.trace('l_rec.configuration_information5 ' ||
                         l_rec.configuration_information5);
       hr_utility.trace('l_rec.configuration_information6 ' ||
                         l_rec.configuration_information6);
       hr_utility.trace('l_rec.configuration_information7 ' ||
                         l_rec.configuration_information7);

      EXCEPTION
        WHEN Cannot_Find_Prog_Unit THEN
          null;
        WHEN others THEN
          raise;

    END;

    hr_utility.set_location(l_proc, 80);

    pay_element_template_api.create_user_structure
       (p_validate                      => p_validate
       ,p_effective_date                => l_rec.effective_date
       ,p_business_group_id             => ln_business_group_id
       ,p_source_template_id            => l_source_template_id
       ,p_base_name                     => l_rec.element_name
       ,p_base_processing_priority      => ln_processing_priority
       ,p_preference_info_category      => l_rec.preference_info_category
       ,p_preference_information1       => l_rec.preference_information1
       ,p_preference_information2       => l_rec.preference_information2
       ,p_preference_information3       => l_rec.preference_information3
       ,p_preference_information4       => l_rec.preference_information4
       ,p_preference_information5       => l_rec.preference_information5
       ,p_preference_information6       => l_rec.preference_information6
       ,p_preference_information7       => l_rec.preference_information7
       ,p_preference_information8       => l_rec.preference_information8
       ,p_preference_information9       => l_rec.preference_information9
       ,p_preference_information10      => l_rec.preference_information10
       ,p_preference_information11      => l_rec.preference_information11
       ,p_preference_information12      => l_rec.preference_information12
       ,p_preference_information13      => l_rec.preference_information13
       ,p_preference_information14      => l_rec.preference_information14
       ,p_preference_information15      => l_rec.preference_information15
       ,p_preference_information16      => l_rec.preference_information16
       ,p_preference_information17      => l_rec.preference_information17
       ,p_preference_information18      => l_rec.preference_information18
       ,p_preference_information19      => l_rec.preference_information19
       ,p_preference_information20      => l_rec.preference_information20
       ,p_preference_information21      => l_rec.preference_information21
       ,p_preference_information22      => l_rec.preference_information22
       ,p_preference_information23      => l_rec.preference_information23
       ,p_preference_information24      => l_rec.preference_information24
       ,p_preference_information25      => l_rec.preference_information25
       ,p_preference_information26      => l_rec.preference_information26
       ,p_preference_information27      => l_rec.preference_information27
       ,p_preference_information28      => l_rec.preference_information28
       ,p_preference_information29      => l_rec.preference_information29
       ,p_preference_information30      => l_rec.preference_information30
       ,p_configuration_info_category   => l_rec.configuration_info_category
       ,p_configuration_information1    => l_rec.configuration_information1
       ,p_configuration_information2    => l_rec.configuration_information2
       ,p_configuration_information3    => l_rec.configuration_information3
       ,p_configuration_information4    => l_rec.configuration_information4
       ,p_configuration_information5    => l_rec.configuration_information5
       ,p_configuration_information6    => l_rec.configuration_information6
       ,p_configuration_information7    => l_rec.configuration_information7
       ,p_configuration_information8    => l_rec.configuration_information8
       ,p_configuration_information9    => l_rec.configuration_information9
       ,p_configuration_information10   => l_rec.configuration_information10
       ,p_configuration_information11   => l_rec.configuration_information11
       ,p_configuration_information12   => l_rec.configuration_information12
       ,p_configuration_information13   => l_rec.configuration_information13
       ,p_configuration_information14   => l_rec.configuration_information14
       ,p_configuration_information15   => l_rec.configuration_information15
       ,p_configuration_information16   => l_rec.configuration_information16
       ,p_configuration_information17   => l_rec.configuration_information17
       ,p_configuration_information18   => l_rec.configuration_information18
       ,p_configuration_information19   => l_rec.configuration_information19
       ,p_configuration_information20   => l_rec.configuration_information20
       ,p_configuration_information21   => l_rec.configuration_information21
       ,p_configuration_information22   => l_rec.configuration_information22
       ,p_configuration_information23   => l_rec.configuration_information23
       ,p_configuration_information24   => l_rec.configuration_information24
       ,p_configuration_information25   => l_rec.configuration_information25
       ,p_configuration_information26   => l_rec.configuration_information26
       ,p_configuration_information27   => l_rec.configuration_information27
       ,p_configuration_information28   => l_rec.configuration_information28
       ,p_configuration_information29   => l_rec.configuration_information29
       ,p_configuration_information30   => l_rec.configuration_information30
       ,p_template_id                   => p_ele_template_id
       ,p_object_version_number         => l_object_version_number
       );

    hr_utility.set_location(l_proc, 50);

    OPEN  get_shd_ele_info( p_ele_template_id, l_rec.element_name );
    FETCH get_shd_ele_info INTO ln_shd_ele_type_id
                               ,l_ele_obj_ver_number
                               ,ln_payroll_formula_id;
    CLOSE get_shd_ele_info;

    IF ln_shd_ele_type_id IS NOT NULL THEN

       hr_utility.trace('Sub-class reccount='||to_char(lt_sub_class.count));

       IF lt_sub_class.count > 0 THEN

          FOR j IN lt_sub_class.FIRST..lt_sub_class.LAST LOOP

              lr_sub_class := lt_sub_class(j);

              IF lr_sub_class.name IS NOT NULL THEN

                 hr_utility.trace('Sub-class rec-'||to_char(j)||
                                               '='||lr_sub_class.name);

                 hr_utility.trace('Entered SUB element_classification '||
                                                   lr_sub_class.name);

                 lr_sub_class.name :=
                               get_base_classification( lv_legislation_code
                                                       ,ln_business_group_id
                                                       ,lr_sub_class.name);

                 hr_utility.trace('BASE SUB element_classification '||
                                                lr_sub_class.name);

                 lr_shadow_sub_class_rec.sub_classification_rule_id := null;
                 lr_shadow_sub_class_rec.element_type_id := ln_shd_ele_type_id;
                 lr_shadow_sub_class_rec.element_classification :=
                                                           lr_sub_class.name;
                 lr_shadow_sub_class_rec.object_version_number := null;
                 lr_shadow_sub_class_rec.exclusion_rule_id := null;

                 pay_ssr_ins.ins(l_rec.effective_date, lr_shadow_sub_class_rec);

              ELSIf lr_sub_class.name IS NULL THEN

                 hr_utility.trace('Exit from Sub-class loop');
                 exit;

              END IF; -- lr_sub_class.name is not null

          END LOOP;

       END IF;

    END IF; --ln_shd_ele_type_id is not null

    /* End of Sub-classification rules creation */

    hr_utility.set_location(l_proc, 60);

    IF p_validate <> TRUE THEN

       pay_shadow_element_api.update_shadow_element
         (p_validate                     =>   p_validate
         ,p_effective_date               =>   l_rec.effective_date
         ,p_element_type_id              =>   ln_shd_ele_type_id
         ,p_reporting_name               =>   l_rec.reporting_name
         ,p_description                  =>   l_rec.element_description
         ,p_classification_name          =>   l_rec.element_classification
         ,p_post_termination_rule        =>   l_rec.termination_rule
         ,p_standard_link_flag           =>   l_rec.standard_link
         ,p_processing_type              =>   l_rec.processing_type
         ,p_once_each_period_flag        =>   l_rec.proc_once_pay_period
         ,p_process_mode                 =>   l_rec.process_mode
         ,p_input_currency_code          =>   l_rec.input_currency_code
         ,p_output_currency_code         =>   lv_currency_code
         ,p_multiple_entries_allowed_fla =>   l_rec.multiple_entries_allowed
         ,p_object_version_number        =>   l_ele_obj_ver_number);

       hr_utility.set_location(l_proc, 70);

       BEGIN

          EXECUTE IMMEDIATE 'BEGIN PAY_'||l_rec.legislation_code||
                            '_RULES.ELEMENT_TEMPLATE_UPD_USER_STRU(:c); END;'
                  USING p_ele_template_id;

          hr_utility.set_location(l_proc, 100);

          EXCEPTION
            WHEN Cannot_Find_Prog_Unit THEN
              null;
            WHEN others THEN
              raise;

       END;

       IF p_save_for_later <> 'Y' THEN

          pay_element_template_api.generate_part1
            (p_validate           =>  FALSE
            ,p_effective_date     =>  l_rec.effective_date
            ,p_hr_only            =>  FALSE
            ,p_hr_to_payroll      =>  FALSE
            ,p_template_id        =>  p_ele_template_id);

          hr_utility.set_location(l_proc, 80);

          pay_element_template_api.generate_part2
            (p_validate           =>  FALSE
            ,p_effective_date     =>  l_rec.effective_date
            ,p_template_id        =>  p_ele_template_id);

          hr_utility.set_location(l_proc, 90);

          FOR formula in get_shd_formula_id( p_ele_template_id )
          LOOP

             OPEN  get_formula_info(formula.payroll_formula_id);
             FETCH get_formula_info INTO lv_formula_name
                                        ,lv_formula_type_name;
             CLOSE get_formula_info;

             ln_req_id := fnd_request.submit_request(
                                        application    => 'FF',
                                        program        => 'SINGLECOMPILE',
                                        argument1      => lv_formula_type_name,
                                        argument2      => lv_formula_name);


          END LOOP;

       END IF;


       BEGIN

          EXECUTE IMMEDIATE 'BEGIN PAY_'||l_rec.legislation_code||
                            '_RULES.ELEMENT_TEMPLATE_POST_PROCESS(:c); END;'
                  USING p_ele_template_id;

          hr_utility.set_location(l_proc, 100);

          EXCEPTION
            WHEN Cannot_Find_Prog_Unit THEN
              null;
            WHEN others THEN
              raise;

       END;

       /* Added the Frequency Rule creation in core schema */

       hr_utility.trace('Start of Frequency Rule Creation ');

       OPEN get_core_shadow_object_id(p_ele_template_id,'ET');
       FETCH get_core_shadow_object_id INTO ln_core_object_id,
                                            ln_shadow_object_id;
       CLOSE get_core_shadow_object_id;

       lv_period_6 := 'N';
       hr_utility.trace('ln_core_object_id :'||to_char(ln_core_object_id));

       IF ln_core_object_id IS NOT NULL AND
          lt_freq_rule_table.count > 0 THEN

          hr_utility.trace('Freq Rule Rec Count :'||
                                      to_char(lt_freq_rule_table.count));
          hr_utility.trace('Start of Freq Rule Recs Loop');

          FOR k IN lt_freq_rule_table.FIRST..lt_freq_rule_table.LAST
          LOOP

              lr_freq_rule_rec   := pay_freq_rule_obj(null,null,null,
                                                      null,null,null,null,null);
              lr_freq_rule_rec := lt_freq_rule_table(k);

              hr_utility.trace('Freq Rule Rec :'||to_char(k));
              hr_utility.trace('Period 1 : '||lr_freq_rule_rec.period_1);
              hr_utility.trace('Period 2 : '||lr_freq_rule_rec.period_2);
              hr_utility.trace('Period 3 : '||lr_freq_rule_rec.period_3);
              hr_utility.trace('Period 4 : '||lr_freq_rule_rec.period_4);
              hr_utility.trace('Period 5 : '||lr_freq_rule_rec.period_5);
              hr_utility.trace('RuleDateCode : '||lr_freq_rule_rec.date_option);

              IF lr_freq_rule_rec.payroll IS NOT NULL THEN

                 OPEN get_payroll_id(ln_business_group_id
                                    ,lr_freq_rule_rec.payroll
                                    ,l_rec.effective_date);

                 FETCH get_payroll_id INTO ln_payroll_id;
                 CLOSE get_payroll_id;

                 hr_utility.trace('Payroll Id :'||to_char(ln_payroll_id));

                 pay_pyepfreq_pkg.hr_ele_pay_freq_rules
                     (p_context       => 'ON-UPDATE',
                      p_eletype_id    => ln_core_object_id,
                      p_payroll_id    => ln_payroll_id,
                      p_period_type   => lr_freq_rule_rec.period_type,
                      p_bg_id         => ln_business_group_id,
                      p_period_1      => lr_freq_rule_rec.period_1,
                      p_period_2      => lr_freq_rule_rec.period_2,
                      p_period_3      => lr_freq_rule_rec.period_3,
                      p_period_4      => lr_freq_rule_rec.period_4,
                      p_period_5      => lr_freq_rule_rec.period_5,
                      p_period_6      => lv_period_6,
                      p_eff_date      => l_rec.effective_date,
                      p_rule_date_code => lr_freq_rule_rec.date_option,
                      p_leg_code      => null);

              END IF; -- lr_freq_rule_rec.payroll is not null

          END LOOP;

          hr_utility.trace('End of Freq Rule Recs Loop');

          /* Initialize Frequency Rule Plsql table that is used in
             Summary Page of Element Template Wizard. */

          pay_pyepfreq_pkg.initialise_freqrule_table;

       END IF; -- ln_core_object_id is not null

       /* End of Frequency Rule creation in core schema */

    END IF;

    hr_utility.set_location('Leaving '||l_proc, 1000);

  END create_element;


  PROCEDURE delete_element
  ( p_validate             IN       BOOLEAN,
    p_template_id          IN       NUMBER
  ) IS

  l_proc     VARCHAR2(240);
  l_legislation_code varchar2(30);

  cursor cur_leg_code IS
  SELECT
    pbg.legislation_code
  FROM
    per_business_groups pbg,
    pay_element_templates pet
  WHERE
    pet.template_id = p_template_id AND
    pet.business_group_id = pbg.business_group_id;

  BEGIN

     l_proc := 'delete_element';

     hr_utility.set_location(l_proc, 10);

     OPEN  cur_leg_code;
     FETCH cur_leg_code
     INTO  l_legislation_code;
     CLOSE cur_leg_code;

     hr_utility.set_location(l_proc, 20);

     BEGIN
          EXECUTE IMMEDIATE 'BEGIN PAY_'||l_legislation_code||
                            '_RULES.DELETE_PRE_PROCESS(:c); END;'
                  USING p_template_id;

          hr_utility.set_location(l_proc, 30);

       EXCEPTION
         WHEN Cannot_Find_Prog_Unit THEN
           null;
         WHEN others THEN
           raise;

     END;

    pay_element_template_api.delete_user_structure
        (p_validate => p_validate,
         p_drop_formula_packages => TRUE,
         p_template_id => p_template_id);

     BEGIN

          EXECUTE IMMEDIATE 'BEGIN PAY_'||l_legislation_code||
                            '_RULES.DELETE_POST_PROCESS(:c); END;'
                  USING p_template_id;

          hr_utility.set_location(l_proc, 50);

       EXCEPTION
         WHEN Cannot_Find_Prog_Unit THEN
           null;
         WHEN others THEN
           raise;

     END;

  END delete_element;

BEGIN

  g_package  := 'pay_element_template_user_init.';

END pay_element_template_user_init;

/
