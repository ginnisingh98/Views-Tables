--------------------------------------------------------
--  DDL for Package Body PY_FR_ADDITIONAL_ELEMENT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_FR_ADDITIONAL_ELEMENT_RULES" AS
/* $Header: pyfreliv.pkb 120.1.12000000.2 2007/02/28 10:02:03 spendhar noship $ */
g_package  varchar2(80) := 'py_fr_additional_element_rules.create_extra_elements';

FUNCTION create_input_value
                (p_element_name              IN varchar2
                ,p_input_value_name          IN varchar2
                ,p_uom_code                  IN varchar2
                ,p_bg_name                   IN varchar2
                ,p_element_type_id           IN number
                ,p_primary_classification_id IN number
                ,p_business_group_id         IN number
                ,p_legislation_code          IN varchar2
                ,p_classification_type       IN varchar2
                ,p_sequence                  IN number
                ,p_base_name                 IN varchar2 default null)
RETURN number IS
                --
                l_effective_start_date  date;
                l_effective_end_date    date;
                l_input_value_id        number;
                l_generate_db_item_flag varchar2(5) := 'Y';
                --
Begin
        --
        select least(effective_start_date),greatest(effective_end_date)
        into l_effective_start_date,l_effective_end_date
        from pay_element_types_f
        where element_type_id =p_element_type_id;
        --
        l_input_value_id := pay_db_pay_setup.create_input_value
                 (p_element_name           =>  p_element_name
                 ,p_name                   =>  p_input_value_name
                 ,p_uom                    =>  ''
                 ,p_uom_code               =>  p_uom_code
                 ,p_mandatory_flag         =>  'N'
                 ,p_generate_db_item_flag  =>  'Y'
                 ,p_default_value          =>  ''
                 ,p_min_value              =>  ''
                 ,p_max_value              =>  ''
                 ,p_warning_or_error       =>  ''
                 ,p_lookup_type            =>  ''
                 ,p_formula_id             => NULL
                 ,p_hot_default_flag       =>  'N'
                 ,p_display_sequence       =>  p_sequence
                 ,p_business_group_name    =>  p_bg_name
                 ,p_effective_start_date   => l_effective_start_date
                 ,p_effective_end_date     => l_effective_end_date);
        --
        --
        hr_input_values.chk_input_value
                (p_element_type_id        => p_element_type_id
                ,p_legislation_code       => p_legislation_code
                ,p_val_start_date         => l_effective_start_date
                ,p_val_end_date           => l_effective_end_date
                ,p_insert_update_flag     => 'NULL'
                ,p_input_value_id         => l_input_value_id
                ,p_rowid                  => ''
                ,p_recurring_flag         => 'R'
                ,p_mandatory_flag         => 'N'
                ,p_hot_default_flag       => 'N'
                ,p_standard_link_flag     => 'N'
                ,p_classification_type    => p_classification_type
                ,p_name                   => p_input_value_name
                ,p_uom                    => p_uom_code
                ,p_min_value              => ''
                ,p_max_value              => ''
                ,p_default_value          => ''
                ,p_lookup_type            => ''
                ,p_formula_id             => NULL
                ,p_generate_db_items_flag => 'Y'
                ,p_warning_or_error       => '');
        --
        -- Bug 3794513, need to use US lang base names for context inputs.
        -- Nb. This may not match a value in the tl table, but that is also
        -- true of the Pay Value input.
        if p_base_name <> p_input_value_name then
                update pay_input_values_f
                set name = p_base_name
                where input_value_id = l_input_value_id;
        end if;
    return l_input_value_id;
    --
end create_input_value;

procedure create_extra_elements
        (p_effective_date                IN date
        ,p_accrual_plan_id               IN number
        ,p_accrual_plan_name             IN varchar2
        ,p_accrual_plan_element_type_id  IN number
        ,p_business_group_id             IN number
        ,p_pto_input_value_id            IN number
        ,p_accrual_category              IN varchar2) is

        l_element_id                    number;
        j                               number;
        l_unused_number                 number;
        l_element_name                  varchar2(80);
        l_item_suffix                   varchar2(80);
        l_bg_name                       varchar2(80);
        l_leg_code                      varchar2(80);
        l_post_term_rule                varchar2(80);
        l_input_value_name              varchar2(80);
        l_uom_code                      varchar2(80);
        l_primary_class_id              number;
        l_effective_start_date          date;
        l_effective_end_date            date;
        l_count                         number;
        l_accrual_class_id              number;
        l_accrual_classification_name   varchar2(30) := 'Accrual Information';
        l_new_skip_rule_id              ff_formulas_f.formula_id%TYPE;


        type inp_val_table IS TABLE of pay_input_values.input_value_id%type
        index by binary_integer;

        input_value_table  inp_val_table;

        --
        -- Cursor to retrieve details of absence element link, to be
        -- copied into links for other elements.
        --

        cursor c_absence_element_link_id is
        select *
          from pay_element_links_f
         where element_link_id in ( select pel.element_link_id
          from pay_element_links_f pel,
                   pay_input_values_f piv
         where pel.element_type_id = piv.element_type_id
           and piv.input_value_id = p_pto_input_value_id
           and p_effective_date between pel.effective_start_date
           and pel.effective_end_date
           and p_effective_date between piv.effective_start_date
           and piv.effective_end_date );

        cursor class_id is
        select classification_id
          from pay_element_types_f
         where element_type_id =(select element_type_id from pay_input_values_f
         where input_value_id = p_pto_input_value_id)
           and rownum = 1;

        cursor csr_name_translation(p_code varchar2) is
        select meaning
          from hr_lookups
         where lookup_type = 'NAME_TRANSLATIONS'
           and lookup_code = p_code;

        cursor accrual_class_id is
        select CLASSIFICATION_ID
        from  pay_element_classifications
        where LEGISLATION_CODE       = 'FR'
        and CLASSIFICATION_NAME = 'Accrual Information';

        cursor csr_skip_rule is
        select f1.formula_id
         from  ff_formulas_f f1, ff_formula_types ft
        where  f1.formula_name = 'FR_PROCESS_IN_LAST_PRORATION_PERIOD_PROCESSED'
        and   f1.formula_type_id = ft.formula_type_id
         and   ft.formula_type_name = 'Element Skip'
         and   f1.effective_start_date = (select max(f0.effective_start_date)
                                            from ff_formulas_f f0
                                             where f0.legislation_code = 'FR'
                                             and f0.formula_id = f1.formula_id
                                             and f0.formula_type_id = f1.formula_type_id
                                             and f0.business_Group_id is null);

Procedure Create_Termination_Element is

l_element_group       varchar2(80);
l_fres_rule_id        number;
l_formula_id          number;
l_index               number := 1;
l_process_rule_id     number;
l_rate_input_value_id number;
l_date_input_value_id number;
l_input_value_id number;
l_end_of_time  date := to_date('31/12/4712','DD/MM/YYYY');
l_earnings_class_id number;
l_act_term_date       varchar2(80);
l_proration_group_id  number;
l_seq_no number;

l_element_link_id    number;
l_comment_id         number;
l_ovn                number;
l_effective_start_date date;
l_effective_end_date   date;
TYPE input_value_rec IS RECORD
  ( input_value_id   pay_input_values_f.input_value_id%type,
    result_name      pay_formula_result_rules_f.result_name%type,
    result_rule_type pay_formula_result_rules_f.result_rule_type%type,
    uom              pay_input_values_f.uom%type,
    base_name        pay_input_values_f.name%type,
    meaning_iv_name  pay_input_values_f.name%type);

TYPE t_input_value IS TABLE OF input_value_rec INDEX BY BINARY_INTEGER;
l_input_value t_input_value;

cursor csr_formula_exists IS
  SELECT formula_id
  FROM ff_formulas_f
  WHERE  formula_name = 'FR_HOLIDAY_TERMINATION_PAYMENT'
  AND    legislation_code = 'FR';

cursor Earnings_class_id is
  select CLASSIFICATION_ID
  from  pay_element_classifications
  where LEGISLATION_CODE       = 'FR'
  and CLASSIFICATION_NAME = 'Earnings';

cursor element_group is
  select TAG ||' : '||meaning
         from
         fnd_lookup_values
         where LOOKUP_TYPE = 'FR_ELEMENT_GROUP'
         and  LOOKUP_CODE = 'TERMINATION_HOLIDAY_PAY';

Begin
       /* Create the element */
       hr_utility.set_location('Step '||g_package,810);
       open  csr_name_translation('FR_TERM_PAYMENT');
       fetch csr_name_translation into l_item_suffix;
       close csr_name_translation;

       l_element_name := p_accrual_plan_name||' '||l_item_suffix;

       /* Create element */
-- for testing ... waiting for API availability

       hr_utility.set_location('Step '||g_package,815);
       select hl.meaning
                into l_act_term_date
                from hr_lookups hl
                where hl.lookup_type='TERMINATION_RULE'
                and hl.lookup_code='A';

       hr_utility.set_location('Step '||g_package,816);
       select event_group_id
       into l_proration_group_id
       from pay_event_groups
       where
       event_group_name = 'FR_BASIC';

       l_element_id :=  hr_accrual_plan_api.create_element
                                 (p_element_name           => l_element_name
                                ,p_element_description    => ''
                                ,p_processing_type        => 'N'
                                ,p_bg_name                => l_bg_name
                                ,p_classification_name    => 'Earnings'
                                ,p_legislation_code       => ''
                                ,p_currency_code          => 'EUR'
                                ,p_post_termination_rule  => l_act_term_date
                                ,p_mult_entries_allowed   => 'Y'
                                ,p_indirect_only_flag     => 'N'
                                ,p_formula_id             => NULL
                                ,p_processing_priority    => 9591);


       open element_group;
       fetch element_group into
       l_element_group;

       If element_group%notfound Then
          close element_group;
          fnd_message.set_token('LOOKUP_CODE','TERMINATION_HOLIDAY_PAY');
          fnd_message.set_token('LOOKUP_TYPE','FR_ELEMENT_GROUP');
          hr_utility.set_message(801,'PAY_75051_ELEMENT_GROUP');
          hr_utility.raise_error;
       Else
          update pay_element_types_f
          set element_information1 = 'TERMINATION_HOLIDAY_PAY' --	l_element_group
             ,element_information_category = 'FR_EARNINGS'
             ,proration_group_id = l_proration_group_id
          where element_type_id = l_element_id;
      End if;
      close element_group;

      hr_utility.set_location('Step '||g_package,820);
       open  csr_name_translation('FR_ACCRUAL_PLAN');
       fetch csr_name_translation into l_input_value_name;
       close csr_name_translation;

       l_input_value(1).result_name  := 'ACCRUAL_PLAN_ID';
       l_input_value(1).uom          := 'N';
       l_input_value(1).result_rule_type := 'I';
       l_input_value(1).base_name        := 'Accrual Plan ID';
       l_input_value(1).meaning_iv_name  := l_input_value_name;

       hr_utility.set_location('Step '||g_package,830);

       /* store the details of the 6 input values in a table */
       open  csr_name_translation('START_DATE');
       fetch csr_name_translation into l_input_value_name;
       close csr_name_translation;

       hr_utility.set_location('Step '||g_package,860);
       l_input_value(2).result_name  := 'START_DATE';
       l_input_value(2).uom          := 'D';
       l_input_value(2).result_rule_type := 'D';
       l_input_value(2).base_name        := 'Start Date';
       l_input_value(2).meaning_iv_name  := l_input_value_name;

       open  csr_name_translation('BASE');
       fetch csr_name_translation into l_input_value_name;
       close csr_name_translation;

       l_input_value(3).result_name  := 'DAILY_RATE';
       l_input_value(3).uom          := 'N';
       l_input_value(3).result_rule_type := 'D';
       l_input_value(3).base_name        := 'Base';
       l_input_value(3).meaning_iv_name  := l_input_value_name;

       hr_utility.set_location('Step '||g_package,870);

       open  csr_name_translation('RATE');
       fetch csr_name_translation into l_input_value_name;
       close csr_name_translation;

       l_input_value(4).result_name  := 'DAYS';
       l_input_value(4).uom          := 'N';
       /* 4538139 Changed from D to I */
       l_input_value(4).result_rule_type := 'I';
       l_input_value(4).base_name        := 'Rate';
       l_input_value(4).meaning_iv_name  := l_input_value_name;

       hr_utility.set_location('Step '||g_package,890);

       open  csr_name_translation('FR_PAYMENT_INDEX');
       fetch csr_name_translation into l_input_value_name;
       close csr_name_translation;

       l_input_value(5).result_name  := 'PAYMENT_INDEX';
       l_input_value(5).uom          := 'N';
       l_input_value(5).result_rule_type := 'I';
       l_input_value(5).base_name        := 'Payment Index';
       l_input_value(5).meaning_iv_name  := l_input_value_name;

       hr_utility.set_location('Step '||g_package,910);

       l_input_value(6).result_name  := 'PAY_VALUE';
       l_input_value(6).uom          := 'N';
       l_input_value(6).result_rule_type := 'D';
       l_input_value(6).base_name        := 'Pay Value';

       hr_utility.set_location('Step '||g_package,920);

       /* 4538139 - dummy rate is not used here after */
/*       l_input_value(7).result_name  := 'L_DUMMY_RATE';
       l_input_value(7).uom          := 'N';
       l_input_value(7).result_rule_type := 'I';
       l_input_value(7).base_name        := 'Rate';
       l_input_value(7).meaning_iv_name  := l_input_value(4).meaning_iv_name; */

       /* create the input value and formula results for the new Termination element
        loop round the table created.
        First Check if the formula is present and then create the processing rule */

        OPEN csr_formula_exists;
        FETCH csr_formula_exists INTO l_formula_id;
        close csr_formula_exists;

        hr_utility.set_location('Step '||g_package,920);

        If l_formula_id IS NOT null then
           l_process_rule_id := pay_formula_results.ins_stat_proc_rule (
                p_business_group_id             => p_business_group_id,
                p_legislation_code              => l_leg_code,
             -- p_legislation_subgroup          => g_template_leg_subgroup,
                p_effective_start_date          => p_effective_date,
                p_effective_end_date            => l_end_of_time,
                p_element_type_id               => l_element_id,
                p_assignment_status_type_id     => NULL,
                p_formula_id                    => l_formula_id,
                p_processing_rule               => 'P');
        Else
           hr_utility.set_message(801,'PAY_75050_TERM_MISSG_FORMULA');
           hr_utility.raise_error;
        END IF;

        open  earnings_class_id;
        fetch earnings_class_id into l_earnings_class_id;
        close earnings_class_id;

        hr_utility.set_location('Step '||g_package,930);
        For l_index in 1..5 loop -- only loop 5 times as we don't want to create pay value
            hr_utility.trace ('input value = ' || l_input_value(l_index).base_name);
            l_seq_no :=l_index * 10;
            l_input_value(l_index).input_value_id :=
                create_input_value(l_element_name
                                  ,l_input_value(l_index).meaning_iv_name
                                  ,l_input_value(l_index).uom
                                  ,l_bg_name
                                  ,l_element_id
                                  ,l_earnings_class_id
                                  ,p_business_group_id
                                  ,l_leg_code
                                  ,'N'
                                  ,l_seq_no
                                  ,l_input_value(l_index).base_name);
        End Loop;

        /* Need to select the ip value id for Pay Value  as this is created automatically */
        Select input_value_id
        into l_input_value(6).input_value_id
        from pay_input_values_f
        where element_type_id = l_element_id
        and name = 'Pay Value';

        /* Rate input value is target for 2 results so set the dummy rate input_value_id */
       /* Bug 4538139 - Since l_input_value(7) is not used anymore, code is commented out */
--        l_input_value(7).input_value_id := l_input_value(4).input_value_id;

        hr_utility.set_location('Step '||g_package,940);

        For l_index in 1..6 loop /* Bug 4538139 - Since only 6 records are used, loop is cut short to 6 */
           -- 115.16 Set the element_type_id on direct result rules for
           --        consistency with the form behaviour.
           l_fres_rule_id := pay_formula_results.ins_form_res_rule (
            p_business_group_id         => p_business_group_id,
            p_legislation_code          => NULL,
            p_effective_start_date      => p_effective_date,
            p_effective_end_date        => l_end_of_time,
            p_status_processing_rule_id => l_process_rule_id,
            p_input_value_id            => l_input_value(l_index).input_value_id,
            p_result_name               => l_input_value(l_index).result_name,
            p_result_rule_type          => l_input_value(l_index).result_rule_type,
            p_element_type_id           => l_element_id);
           IF l_index in (2,3,4) then
               /* As direct input value for direct results always gets set to Pay value, we need to
                  update the result rule to have the correct input value id */
               update pay_formula_result_rules_f
               set input_value_id = l_input_value(l_index).input_value_id
               where formula_result_rule_id = l_fres_rule_id;
           END IF;
        End loop;
         /* Now store the input value id's for the rate and date in the Accrual plan DDF */

         hr_utility.set_location('Step '||g_package,950);

         IF p_accrual_category = 'FR_MAIN_HOLIDAY'  Then
                 hr_utility.set_location('Step '||g_package,960);
                update pay_accrual_plans set
                 information28  = l_input_value(3).input_value_id  -- index 3 holds rate
                ,information29  = l_input_value(2).input_value_id  -- index 2 holds date
                where accrual_plan_id = p_accrual_plan_id;

        ELSE
           IF (p_accrual_category = 'FR_RTT_HOLIDAY') OR (p_accrual_category = 'FR_ADDITIONAL_HOLIDAY') Then
            hr_utility.set_location('Step '||g_package,970);
                  update pay_accrual_plans set
                    information28  = l_input_value(3).input_value_id
                   ,information29  = l_input_value(2).input_value_id
                 where accrual_plan_id = p_accrual_plan_id;
           END IF;
        END IF;


        /* create element link for the termination element */

        hr_utility.set_location('Step '||g_package,980);
        PAY_ELEMENT_LINK_API.create_element_link
                (
                 p_effective_date             => p_effective_date
                ,p_element_type_id            => l_element_id
                ,p_business_group_id          => p_business_group_id
                ,p_costable_type              => 'N'
                ,p_link_to_all_payrolls_flag  => 'Y'
                ,p_cost_concat_segments       => null
                ,p_balance_concat_segments    => null
                ,p_element_link_id            => l_element_link_id
                ,p_comment_id                 => l_comment_id
                ,p_object_version_number      => l_ovn
                ,p_effective_start_date       => l_effective_start_date
                ,p_effective_end_date         => l_effective_end_date
                );

        Exception
           when no_data_found then
           hr_utility.trace(g_package||'.Create_Termination_element when no_data_found');
           hr_utility.set_message(801,'HR_NO_F_TERM_RULE');
           hr_utility.raise_error;

           when others then
           hr_utility.trace(g_package||'.Create_Termination_element when others exception');
           hr_utility.trace(SQLCODE);
           hr_utility.trace(SQLERRM);
           Raise;

End Create_Termination_element;


begin

  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
    hr_utility.set_location('Leaving '||g_package , 10);
    return;
  END IF;

  --
  --hr_utility.trace_on(null,'EXTRA');
  hr_utility.set_location('Entering  '||g_package , 10);
IF (p_accrual_category = 'FR_RTT_HOLIDAY') OR (p_accrual_category = 'FR_ADDITIONAL_HOLIDAY')
         OR (p_accrual_category = 'FR_MAIN_HOLIDAY') Then

        --
        --  Get value for variables
        --
        hr_utility.set_location('Step '||g_package,20);

        open  class_id;
        fetch class_id into l_primary_class_id;
        close class_id;

        open  accrual_class_id;
        fetch accrual_class_id into l_accrual_class_id;
        close accrual_class_id;

        hr_utility.set_location('Step '||g_package,30);

        begin
                --
                select hl.meaning
                into l_post_term_rule
                from hr_lookups hl
                where hl.lookup_type='TERMINATION_RULE'
                and hl.lookup_code='F';                           -- Final Close

                select name,legislation_code
                into l_bg_name,l_leg_code
                from per_business_groups
                where business_group_id = p_business_group_id;


                --
        exception
                --
                when no_data_found then
                hr_utility.set_message(801,'HR_NO_F_TERM_RULE');
                hr_utility.raise_error;
                --
                --
        end;
         hr_utility.set_location('Step '||g_package,40);
            for i in 1..3 loop
                 hr_utility.set_location('Step '||g_package,50);
                --
                if i = 1 then

                hr_utility.set_location('Step '||g_package,60);
                open  csr_name_translation('FR_ENTITLEMENT');
                fetch csr_name_translation into l_item_suffix;
                close csr_name_translation;

                        hr_utility.set_location('Step '||g_package,70);
                        l_element_name := p_accrual_plan_name||' '||l_item_suffix;
                        j := 0;

                elsif i = 2  then

                hr_utility.set_location('Step '||g_package,80);
                open  csr_name_translation('FR_OBSOLETE');
                fetch csr_name_translation into l_item_suffix;
                close csr_name_translation;

                        hr_utility.set_location('Step '||g_package,90);
                        l_element_name := p_accrual_plan_name||' '||l_item_suffix;
                        j := 9;

                elsif i = 3  then

                hr_utility.set_location('Step '||g_package,100);
                open  csr_name_translation('FR_ADJUSTMENT');
                fetch csr_name_translation into l_item_suffix;
                close csr_name_translation;

                         hr_utility.set_location('Step '||g_package,110);
                        l_element_name := p_accrual_plan_name||' '||l_item_suffix;
                        j := 18;
                end if;
                --

                hr_utility.set_location('Step '||g_package,120);
                l_element_id :=  hr_accrual_plan_api.create_element
                                 (p_element_name           => l_element_name
                                ,p_element_description    => ''
                                ,p_processing_type        => 'N'
                                ,p_bg_name                => l_bg_name
                                ,p_classification_name    => 'Information'
                                ,p_legislation_code       => ''
                                ,p_currency_code          => 'EUR'
                                ,p_post_termination_rule  => l_post_term_rule
                                ,p_mult_entries_allowed   => 'Y'
                                ,p_indirect_only_flag     => 'N'
                                ,p_formula_id             => NULL
                                ,p_processing_priority    => NULL);

                hr_utility.set_location('Step '||g_package,130);
                open  csr_name_translation('FR_ACCRUAL_PLAN');
                fetch csr_name_translation into l_input_value_name;
                close csr_name_translation;

                hr_utility.set_location('Step '||g_package,140);
                l_uom_code := 'N';

                input_value_table(j+1) := create_input_value
                                          (l_element_name
                                          ,l_input_value_name
                                          ,l_uom_code
                                          ,l_bg_name
                                          ,l_element_id
                                          ,l_primary_class_id
                                          ,p_business_group_id
                                          ,l_leg_code
                                          ,'N'
                                          ,10);

                hr_utility.set_location('Step '||g_package,150);
                open  csr_name_translation('FR_ACCRUAL_DATE');
                fetch csr_name_translation into l_input_value_name;
                close csr_name_translation;

                hr_utility.set_location('Step '||g_package,160);
                l_uom_code := 'D';

                input_value_table(j+2) := create_input_value
                                          (l_element_name
                                          ,l_input_value_name
                                          ,l_uom_code
                                          ,l_bg_name
                                          ,l_element_id
                                          ,l_primary_class_id
                                          ,p_business_group_id
                                          ,l_leg_code
                                          ,'N'
                                          ,20);

                hr_utility.set_location('Step '||g_package,170);
                open  csr_name_translation('FR_MAIN_DAY');
                fetch csr_name_translation into l_input_value_name;
                close csr_name_translation;

                hr_utility.set_location('Step '||g_package,180);
                l_uom_code := 'ND';

                input_value_table(j+3) := create_input_value
                                          (l_element_name
                                          ,l_input_value_name
                                          ,l_uom_code
                                          ,l_bg_name
                                          ,l_element_id
                                          ,l_primary_class_id
                                          ,p_business_group_id
                                          ,l_leg_code
                                          ,'N'
                                          ,30);

                hr_utility.set_location('Step '||g_package,190);
                --
                IF p_accrual_category = 'FR_MAIN_HOLIDAY'  Then

                        hr_utility.set_location('Step '||g_package,200);
                        open  csr_name_translation('FR_PROTECT_DAY');
                        fetch csr_name_translation into l_input_value_name;
                        close csr_name_translation;

                        hr_utility.set_location('Step '||g_package,210);
                        l_uom_code := 'ND';

                        input_value_table(j+4) := create_input_value
                                                (l_element_name
                                                ,l_input_value_name
                                                ,l_uom_code
                                                ,l_bg_name
                                                ,l_element_id
                                                ,l_primary_class_id
                                                ,p_business_group_id
                                                ,l_leg_code
                                                ,'N'
                                                ,40);

                        hr_utility.set_location('Step '||g_package,220);
                        open  csr_name_translation('FR_CONVEN_DAY');
                        fetch csr_name_translation into l_input_value_name;
                        close csr_name_translation;

                        hr_utility.set_location('Step '||g_package,230);
                        l_uom_code := 'ND';

                        input_value_table(j+5) := create_input_value
                                                  (l_element_name
                                                ,l_input_value_name
                                                ,l_uom_code
                                                ,l_bg_name
                                                ,l_element_id
                                                ,l_primary_class_id
                                                ,p_business_group_id
                                                ,l_leg_code
                                                ,'N'
                                                ,50);


                        hr_utility.set_location('Step '||g_package,240);
                        open  csr_name_translation('FR_SENIORITY_DAY');
                        fetch csr_name_translation into l_input_value_name;
                        close csr_name_translation;

                        hr_utility.set_location('Step '||g_package,250);
                        l_uom_code := 'ND';

                        input_value_table(j+6) := create_input_value
                                                  (l_element_name
                                                ,l_input_value_name
                                                ,l_uom_code
                                                ,l_bg_name
                                                ,l_element_id
                                                ,l_primary_class_id
                                                ,p_business_group_id
                                                ,l_leg_code
                                                ,'N'
                                                ,60);


                        hr_utility.set_location('Step '||g_package,260);
                        open  csr_name_translation('FR_YMOTHER_DAY');
                        fetch csr_name_translation into l_input_value_name;
                        close csr_name_translation;

                        hr_utility.set_location('Step '||g_package,270);
                        l_uom_code := 'ND';

                        input_value_table(j+7) := create_input_value
                                                  (l_element_name
                                                ,l_input_value_name
                                                ,l_uom_code
                                                ,l_bg_name
                                                ,l_element_id
                                                ,l_primary_class_id
                                                ,p_business_group_id
                                                ,l_leg_code
                                                ,'N'
                                                ,70);


                        hr_utility.set_location('Step '||g_package,280);
                        --
                        IF  i = 1 THEN
                                hr_utility.set_location('Step '||g_package,290);
                                open  csr_name_translation('FR_REF_SALARY');
                                fetch csr_name_translation into l_input_value_name;
                                close csr_name_translation;

                                hr_utility.set_location('Step '||g_package,300);
                                l_uom_code := 'M';

                                input_value_table(j+8) := create_input_value
                                                         (l_element_name
                                                         ,l_input_value_name
                                                         ,l_uom_code
                                                         ,l_bg_name
                                                         ,l_element_id
                                                         ,l_primary_class_id
                                                         ,p_business_group_id
                                                         ,l_leg_code
                                                         ,'N'
                                                         ,80);


                                hr_utility.set_location('Step '||g_package,310);
                                open  csr_name_translation('FR_REF_DAY');
                                fetch csr_name_translation into l_input_value_name;
                                close csr_name_translation;

                                hr_utility.set_location('Step '||g_package,320);
                                l_uom_code := 'ND';

                                input_value_table(j+9) := create_input_value
                                                          (l_element_name
                                                          ,l_input_value_name
                                                          ,l_uom_code
                                                          ,l_bg_name
                                                          ,l_element_id
                                                          ,l_primary_class_id
                                                          ,p_business_group_id
                                                          ,l_leg_code
                                                          ,'N'
                                                          ,90);
                                hr_utility.set_location('Step '||g_package,330);

                        END IF;
                        --
               hr_utility.set_location('Step '||g_package,340);
            END IF;
            --

                for l_element_link_rec in c_absence_element_link_id
                loop
                --
                        l_count := l_count + 1;
                        --
                        -- Create element links for new accrual plan elements,
                        -- beginning with the plan element itself.
                        --
                        hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                                       ,p_absence_link_rec  => l_element_link_rec
                                                       ,p_legislation_code  => l_leg_code);
                --
                end loop;


    hr_utility.set_location('Step '||g_package,350);
    end loop;
        --
        hr_utility.set_location('Step '||g_package,360);
        open  csr_name_translation('FR_WORK_DAY');
        fetch csr_name_translation into l_input_value_name;
        close csr_name_translation;

        hr_utility.set_location('Step '||g_package,370);
        l_uom_code := 'ND';

        input_value_table(28) := create_input_value
                                (p_accrual_plan_name
                                ,l_input_value_name
                                ,l_uom_code
                                ,l_bg_name
                                ,p_accrual_plan_element_type_id
                                ,l_primary_class_id
                                ,p_business_group_id
                                ,l_leg_code
                                ,'N'
                                ,20);

        hr_utility.set_location('Step '||g_package,380);
        --
        IF p_accrual_category = 'FR_MAIN_HOLIDAY' then
           hr_utility.set_location('Step '||g_package,390);
                 open  csr_name_translation('FR_PROTECT_DAY');
                 fetch csr_name_translation into l_input_value_name;
                 close csr_name_translation;

                 hr_utility.set_location('Step '||g_package,400);
                 l_uom_code := 'ND';

                 input_value_table(29) := create_input_value
                                          (p_accrual_plan_name
                                          ,l_input_value_name
                                          ,l_uom_code
                                          ,l_bg_name
                                          ,p_accrual_plan_element_type_id
                                          ,l_primary_class_id
                                          ,p_business_group_id
                                          ,l_leg_code
                                          ,'N'
                                          ,30);
                 hr_utility.set_location('Step '||g_package,410);
      END IF;
      --
      --
      IF p_accrual_category = 'FR_MAIN_HOLIDAY'  Then
                 hr_utility.set_location('Step '||g_package,420);
                update pay_accrual_plans set
                 information8  = input_value_table(3)
                ,information9  = input_value_table(4)
                ,information10 = input_value_table(5)
                ,information11 = input_value_table(6)
                ,information12 = input_value_table(7)
                ,information13 = input_value_table(12)
                ,information14 = input_value_table(13)
                ,information15 = input_value_table(14)
                ,information16 = input_value_table(15)
                ,information17 = input_value_table(16)
                ,information18 = input_value_table(21)
                ,information19 = input_value_table(22)
                ,information20 = input_value_table(23)
                ,information21 = input_value_table(24)
                ,information22 = input_value_table(25)
                ,information23 = input_value_table(2)
                ,information24 = input_value_table(11)
                ,information25 = input_value_table(20)
                ,information26 = input_value_table(28)
                ,information27 = input_value_table(29)
                where accrual_plan_id = p_accrual_plan_id;

     ELSE
           IF (p_accrual_category = 'FR_RTT_HOLIDAY') OR (p_accrual_category = 'FR_ADDITIONAL_HOLIDAY') Then
            hr_utility.set_location('Step '||g_package,430);
                  update pay_accrual_plans set
                         information8  = input_value_table(3)
                        ,information13 = input_value_table(12)
                        ,information18 = input_value_table(21)
                        ,information23 = input_value_table(2)
                        ,information24 = input_value_table(11)
                        ,information25 = input_value_table(20)
                        ,information26 = input_value_table(28)
                 where accrual_plan_id = p_accrual_plan_id;
           END IF;
            hr_utility.set_location('Step '||g_package,440);
     END IF;
     --
        --
        -- Now create the extra Accounting Accrual elements
        --
           hr_utility.set_location('Step '||g_package,450);
           l_uom_code := 'M';

           open csr_name_translation('PAY VALUE');
           fetch csr_name_translation into l_input_value_name;
           close csr_name_translation;

           hr_utility.set_location('Step '||g_package,460);
        --
        -- AMOUNT, Current Year
        --
           open  csr_name_translation('FR_ACC_Y_AMOUNT');
           fetch csr_name_translation into l_item_suffix;
           close csr_name_translation;

           l_element_name := p_accrual_plan_name||' '||l_item_suffix;

           hr_utility.trace('****l_element_name****'||l_element_name);
           hr_utility.set_location('Step '||g_package,470);

       l_element_id :=  hr_accrual_plan_api.create_element
          (p_element_name           => p_accrual_plan_name||' '||l_item_suffix
          ,p_element_description    => ''
          ,p_processing_type        => 'N'
          ,p_bg_name                => l_bg_name
          ,p_classification_name    => l_accrual_classification_name
          ,p_legislation_code       => ''
          ,p_currency_code          => 'EUR'
          ,p_post_termination_rule  => l_post_term_rule
          ,p_mult_entries_allowed   => 'Y'
          ,p_indirect_only_flag     => 'N'
          ,p_formula_id             => NULL
          ,p_processing_priority    => NULL);

           hr_utility.set_location('Step '||g_package,480);

        l_unused_number := create_input_value
         (l_element_name
         ,l_input_value_name
         ,l_uom_code
         ,l_bg_name
         ,l_element_id
         ,l_accrual_class_id
         ,p_business_group_id
         ,l_leg_code
         ,'N'
         ,10);

           hr_utility.set_location('Step '||g_package,490);
        --
        -- Create the links for this record
           --
           for l_element_link_rec in c_absence_element_link_id loop

              hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                             ,p_absence_link_rec  => l_element_link_rec
                                             ,p_legislation_code  => l_leg_code);

           end loop;
           --
           hr_utility.set_location('Step '||g_package,500);
        --
        -- AMOUNT, Current year minus one
        --
           open  csr_name_translation('FR_ACC_Y1_AMOUNT');
           fetch csr_name_translation into l_item_suffix;
           close csr_name_translation;

           l_element_name := p_accrual_plan_name||' '||l_item_suffix;
           hr_utility.set_location('Step '||g_package,510);

        l_element_id :=  hr_accrual_plan_api.create_element
          (p_element_name           => l_element_name
          ,p_element_description    => ''
          ,p_processing_type        => 'N'
          ,p_bg_name                => l_bg_name
          ,p_classification_name    =>  l_accrual_classification_name
          ,p_legislation_code       => ''
          ,p_currency_code          => 'EUR'
          ,p_post_termination_rule  => l_post_term_rule
          ,p_mult_entries_allowed   => 'Y'
          ,p_indirect_only_flag     => 'N'
          ,p_formula_id             => NULL
          ,p_processing_priority    => NULL);

           hr_utility.set_location('Step '||g_package,520);

        l_unused_number := create_input_value
         (l_element_name
         ,l_input_value_name
         ,l_uom_code
         ,l_bg_name
         ,l_element_id
         ,l_accrual_class_id
         ,p_business_group_id
         ,l_leg_code
         ,'N'
         ,10);

        hr_utility.set_location('Step '||g_package,530);
        --
        -- Create the links for this record
        --
        for l_element_link_rec in c_absence_element_link_id loop
            hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                           ,p_absence_link_rec  => l_element_link_rec
                                           ,p_legislation_code  => l_leg_code);
          --
        end loop;

       hr_utility.set_location('Step '||g_package,540);
        --
        -- AMOUNT, Current Year minus two
        --
           open  csr_name_translation('FR_ACC_Y2_AMOUNT');
           fetch csr_name_translation into l_item_suffix;
           close csr_name_translation;

           l_element_name := p_accrual_plan_name||' '||l_item_suffix;
           hr_utility.set_location('Step '||g_package,550);

        l_element_id :=  hr_accrual_plan_api.create_element
          (p_element_name           => l_element_name
          ,p_element_description    => ''
          ,p_processing_type        => 'N'
          ,p_bg_name                => l_bg_name
          ,p_classification_name    => l_accrual_classification_name
          ,p_legislation_code       => ''
          ,p_currency_code          => 'EUR'
          ,p_post_termination_rule  => l_post_term_rule
          ,p_mult_entries_allowed   => 'Y'
          ,p_indirect_only_flag     => 'N'
          ,p_formula_id             => NULL
          ,p_processing_priority    => NULL);

           hr_utility.set_location('Step '||g_package,560);

        l_unused_number := create_input_value
         (l_element_name
         ,l_input_value_name
         ,l_uom_code
         ,l_bg_name
         ,l_element_id
         ,l_accrual_class_id
         ,p_business_group_id
         ,l_leg_code
         ,'N'
         ,10);

        hr_utility.set_location('Step '||g_package,570);
        --
        -- Create the links for this record
           --
          for l_element_link_rec in c_absence_element_link_id loop
              hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                             ,p_absence_link_rec  => l_element_link_rec
                                             ,p_legislation_code  => l_leg_code);

          end loop;
          --
        hr_utility.set_location('Step '||g_package,580);
        --
        -- AMOUNT, year - 3
        --
           open  csr_name_translation('FR_ACC_Y3_AMOUNT');
           fetch csr_name_translation into l_item_suffix;
           close csr_name_translation;

           l_element_name := p_accrual_plan_name||' '||l_item_suffix;
           hr_utility.set_location('Step '||g_package,590);

        l_element_id :=  hr_accrual_plan_api.create_element
          (p_element_name           => l_element_name
          ,p_element_description    => ''
          ,p_processing_type        => 'N'
          ,p_bg_name                => l_bg_name
          ,p_classification_name    => l_accrual_classification_name
          ,p_legislation_code       => ''
          ,p_currency_code          => 'EUR'
          ,p_post_termination_rule  => l_post_term_rule
          ,p_mult_entries_allowed   => 'Y'
          ,p_indirect_only_flag     => 'N'
          ,p_formula_id             => NULL
          ,p_processing_priority    => NULL);

           hr_utility.set_location('Step '||g_package,600);

        l_unused_number := create_input_value
         (l_element_name
         ,l_input_value_name
         ,l_uom_code
         ,l_bg_name
         ,l_element_id
         ,l_accrual_class_id
         ,p_business_group_id
         ,l_leg_code
         ,'N'
         ,10);

           hr_utility.set_location('Step '||g_package,610);
        --
        -- Create the links for this record
           --
           for l_element_link_rec in c_absence_element_link_id loop
               hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                              ,p_absence_link_rec  => l_element_link_rec
                                              ,p_legislation_code  => l_leg_code);

           end loop;
           --
        hr_utility.set_location('Step '||g_package,620);
        --
        -- CHARGES, Current Year
        --
           open  csr_name_translation('FR_ACC_Y_CHARGES');
           fetch csr_name_translation into l_item_suffix;
           close csr_name_translation;

           l_element_name := p_accrual_plan_name||' '||l_item_suffix;
           hr_utility.set_location('Step '||g_package,630);

        l_element_id :=  hr_accrual_plan_api.create_element
          (p_element_name           =>  l_element_name
          ,p_element_description    => ''
          ,p_processing_type        => 'N'
          ,p_bg_name                => l_bg_name
          ,p_classification_name    => l_accrual_classification_name
          ,p_legislation_code       => ''
          ,p_currency_code          => 'EUR'
          ,p_post_termination_rule  => l_post_term_rule
          ,p_mult_entries_allowed   => 'Y'
          ,p_indirect_only_flag     => 'N'
          ,p_formula_id             => NULL
          ,p_processing_priority    => NULL);

          hr_utility.set_location('Step '||g_package,640);

        l_unused_number := create_input_value
         ( l_element_name
         ,l_input_value_name
         ,l_uom_code
         ,l_bg_name
         ,l_element_id
         ,l_accrual_class_id
         ,p_business_group_id
         ,l_leg_code
         ,'N'
         ,10);

          hr_utility.set_location('Step '||g_package,650);
        --
        -- Create the links for this record
          --
          for l_element_link_rec in c_absence_element_link_id loop
              hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                             ,p_absence_link_rec  => l_element_link_rec
                                             ,p_legislation_code  => l_leg_code);
          end loop;
          --

          hr_utility.set_location('Step '||g_package,660);
        --
        -- CHARGES, Current Year minus one
        --
           open  csr_name_translation('FR_ACC_Y1_CHARGES');
           fetch csr_name_translation into l_item_suffix;
           close csr_name_translation;

           l_element_name := p_accrual_plan_name||' '||l_item_suffix;
           hr_utility.set_location('Step '||g_package,670);

        l_element_id :=  hr_accrual_plan_api.create_element
          (p_element_name           => l_element_name
          ,p_element_description    => ''
          ,p_processing_type        => 'N'
          ,p_bg_name                => l_bg_name
          ,p_classification_name    => l_accrual_classification_name
          ,p_legislation_code       => ''
          ,p_currency_code          => 'EUR'
          ,p_post_termination_rule  => l_post_term_rule
          ,p_mult_entries_allowed   => 'Y'
          ,p_indirect_only_flag     => 'N'
          ,p_formula_id             => NULL
          ,p_processing_priority    => NULL);

           hr_utility.set_location('Step '||g_package,680);

        l_unused_number := create_input_value
         (l_element_name
         ,l_input_value_name
         ,l_uom_code
         ,l_bg_name
         ,l_element_id
         ,l_accrual_class_id
         ,p_business_group_id
         ,l_leg_code
         ,'N'
         ,10);

           hr_utility.set_location('Step '||g_package,690);
        --
        -- Create the links for this record
           --
           for l_element_link_rec in c_absence_element_link_id loop
               hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                              ,p_absence_link_rec  => l_element_link_rec
                                              ,p_legislation_code  => l_leg_code);
           end loop;
           --

          hr_utility.set_location('Step '||g_package,700);
        --
        -- CHARGES, Current Year minus two
        --
           open  csr_name_translation('FR_ACC_Y2_CHARGES');
           fetch csr_name_translation into l_item_suffix;
           close csr_name_translation;

           l_element_name := p_accrual_plan_name||' '||l_item_suffix;
           hr_utility.set_location('Step '||g_package,710);

        l_element_id :=  hr_accrual_plan_api.create_element
          (p_element_name           => l_element_name
          ,p_element_description    => ''
          ,p_processing_type        => 'N'
          ,p_bg_name                => l_bg_name
          ,p_classification_name    => l_accrual_classification_name
          ,p_legislation_code       => ''
          ,p_currency_code          => 'EUR'
          ,p_post_termination_rule  => l_post_term_rule
          ,p_mult_entries_allowed   => 'Y'
          ,p_indirect_only_flag     => 'N'
          ,p_formula_id             => NULL
          ,p_processing_priority    => NULL);

           hr_utility.set_location('Step '||g_package,720);

        l_unused_number := create_input_value
         (l_element_name
         ,l_input_value_name
         ,l_uom_code
         ,l_bg_name
         ,l_element_id
         ,l_accrual_class_id
         ,p_business_group_id
         ,l_leg_code
         ,'N'
         ,10);

           hr_utility.set_location('Step '||g_package,730);
        --
        -- Create the links for this record
           --
           for l_element_link_rec in c_absence_element_link_id loop
               hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                              ,p_absence_link_rec  => l_element_link_rec
                                              ,p_legislation_code  => l_leg_code);
           end loop;
           --

           hr_utility.set_location('Step '||g_package,740);
        --
        -- CHARGES, Current Year minus 3
        --
           open  csr_name_translation('FR_ACC_Y3_CHARGES');
           fetch csr_name_translation into l_item_suffix;
           close csr_name_translation;

           l_element_name := p_accrual_plan_name||' '||l_item_suffix;
           hr_utility.set_location('Step '||g_package,750);

        l_element_id :=  hr_accrual_plan_api.create_element
          (p_element_name           => l_element_name
          ,p_element_description    => ''
          ,p_processing_type        => 'N'
          ,p_bg_name                => l_bg_name
          ,p_classification_name    => l_accrual_classification_name
          ,p_legislation_code       => ''
          ,p_currency_code          => 'EUR'
          ,p_post_termination_rule  => l_post_term_rule
          ,p_mult_entries_allowed   => 'Y'
          ,p_indirect_only_flag     => 'N'
          ,p_formula_id             => NULL
          ,p_processing_priority    => NULL);

           hr_utility.set_location('Step '||g_package,760);

        l_unused_number := create_input_value
         (l_element_name
         ,l_input_value_name
         ,l_uom_code
         ,l_bg_name
         ,l_element_id
         ,l_accrual_class_id
         ,p_business_group_id
         ,l_leg_code
         ,'N'
         ,10);

        hr_utility.set_location('Step '||g_package,780);
        --
        -- Create the links for this record
        --
        for l_element_link_rec in c_absence_element_link_id loop
               hr_accrual_plan_api.create_element_link(p_element_type_id   => l_element_id
                                              ,p_absence_link_rec  => l_element_link_rec
                                              ,p_legislation_code  => l_leg_code);
        end loop;
        hr_utility.set_location('Step '||g_package,785);
        --
        -- get the new skip rule id, if it exists.
        --
        BEGIN
          open csr_skip_rule;
          fetch csr_skip_rule into l_new_skip_rule_id;
          close csr_skip_rule;
        EXCEPTION
          -- if the skip rule does not exist, continue
          when others then null;
        END;
        --
        -- Now update the main acp element to have a processing priority of 9590
        --
        hr_utility.set_location('Step '||g_package,790);
        begin
          update pay_element_types_f
          set processing_priority = 9590
             ,formula_id = nvl(l_new_skip_rule_id, formula_id)
          where element_name = p_accrual_plan_name
          and business_group_id = p_business_group_id;
        end;
        --

        hr_utility.trace('Creating Termination element');
        Create_Termination_Element;

        hr_utility.set_location('Leaving '||g_package,800);
  END IF;

END create_extra_elements;
--
END py_fr_additional_element_rules;

/
