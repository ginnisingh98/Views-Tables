--------------------------------------------------------
--  DDL for Package Body BEN_EXT_RUNRSLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_RUNRSLT" as
/* $Header: benxrunr.pkb 120.1.12000000.2 2007/02/15 17:13:18 tjesumic noship $
+==============================================================================+
|           Copyright (c) 1997 Oracle Corporation                  |
|              Redwood Shores, California, USA                     |
|                   All rights reserved.                             |
+==============================================================================+
Name:      Extract Run Result Process
Purpose :  This process handles fields that are related to Element Entries and
       Input Values.
History:
        Date          Who           Version    What?
        ----          ---           -------    -----
        26 Apr 99     Anusree Sen   115.0      Created
        14 May 99     Anusree Sen   115.1      Added Header
        14 May 99     Anusree Sen   115.2      Deleted DBMS_OUTPUT
        17 May 99     Isen          115.3      Removed null others exception handler
                                               - bug 2422
        25 May 99     Isen          115.4      Added procedure to initialize globals
        01 Jul 99     Asen          115.5      Added code for decode fields.
        14 jub 91    tilak          115.6      pay_payroll_actions.effective_Date
                                               extracted for payroll end date criteria
        30 nov 01    tjesumic       115.7      for performance cursor changed bug 2129704
        14 dec 01    tjesumic       115.8      for performance cursor changed bug 2129704
        06 feb 02    tjesumic       115.9      comment added ,why the global assignment id is not
                                               used to control the assignment table
        18 nov 02    lakrish        115.10     Bug 2669594,Added assignment for input value name
        24-Dec-05    tjesumic       115.11      formula added for payroll
        15-Feb-07    tjesumic       115.12     Hint added for c_asg cursor
--------------------------------------------------------------------------------
*/
--
g_package  varchar2(33) := '  ben_ext_runrslt.';  -- Global package name
--
-- procedure to initialize the globals - May, 99
-- -----------------------------------------------------------------------------
-- |----------------------< initialize_globals >-------------------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE initialize_globals IS
  --
  l_proc             varchar2(72) := g_package||'initialize_globals';
  --
Begin
--
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
    --
    ben_ext_person.g_runrslt_element_name         := null;
    ben_ext_person.g_runrslt_element_id           := null;
    ben_ext_person.g_runrslt_reporting_name       := null;
    ben_ext_person.g_runrslt_element_description  := null;
    ben_ext_person.g_runrslt_classification       := null;
    ben_ext_person.g_runrslt_classification_id    := null;
    ben_ext_person.g_runrslt_processing_type      := null;
    ben_ext_person.g_runrslt_input_currency       := null;
    ben_ext_person.g_runrslt_output_currency      := null;
    ben_ext_person.g_runrslt_skip_rule            := null;
    ben_ext_person.g_runrslt_skip_rule_id         := null;
    ben_ext_person.g_runrslt_input_value_name     := null;
    ben_ext_person.g_runrslt_input_value_id       := null;
    ben_ext_person.g_runrslt_input_value_units    := null;
    ben_ext_person.g_runrslt_input_value_sequence := null;
    ben_ext_person.g_runrslt_identifier           := null;
    ben_ext_person.g_runrslt_jurisdiction_code    := null;
    ben_ext_person.g_runrslt_status           := null;
    ben_ext_person.g_runrslt_source_type      := null;
    ben_ext_person.g_runrslt_entry_type       := null;
    ben_ext_person.g_runrslt_value        := null;
    ben_ext_person.g_runrslt_last_pay_date        := null;
    --
  --
  hr_utility.set_location('Exiting'||l_proc, 15);
  --
--
End initialize_globals;
--
--
PROCEDURE main
    (                        p_person_id          in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date) is
   --
   l_proc             varchar2(72) := g_package||'main';
   --
   l_include          varchar2(1) := 'Y';
   l_dummy_no         number ;
   --
   ---when the criteris is exclude theen use this cursor
   --- global assignment id is not validated intentionally
   --- if needed this can be added latter
   -- if a person hired in jan , terminated in mar and rehired in
   -- sep .
   -- if the assg_id control allded then it is not possible for the person
   -- to extract the salary of the whole year. inorder have the history
   -- of the person runresult  the global assg id is not controlled here

   cursor c_runrslt_excl is
   select
       et.element_name          element_name,
       et.element_type_id       element_id,
       et.reporting_name        reporting_name,
       et.description           description,
       et.classification_id     class_id,
       ec.classification_name       class_name,
       et.processing_type       process_type,
       et.input_currency_code       input_currency,
       et.output_currency_code      output_currency,
       et.formula_id            skip_rule_id,  -- skip rule
       ff.formula_name          skip_rule_name,
       iv.name              value_name,
       iv.uom               value_unit,
       iv.display_sequence      value_seq,
       iv.input_value_id        value_id,
       rr.run_result_id         result_id,
       rr.jurisdiction_code     juris_code,
       rr.status            status,
       rr.source_type           source_type,
       rr.source_id             source_id,
       rr.entry_type            entry_type,
       rv.result_value          result_value,
       ppa.effective_Date               effective_Date
       from
       per_all_assignments_f asg,
       pay_assignment_actions aac,
       pay_input_values_f iv,
       pay_element_types_f et,
       pay_element_classifications ec,
       ff_formulas_f ff,
       pay_run_results rr,
       pay_run_result_values rv,
       pay_payroll_actions ppa
     where
       asg.person_id = p_person_id
       --and asg.assignment_id = ben_ext_person.g_assignment_id  --1969853
       and asg.assignment_id = aac.assignment_id
       and aac.assignment_action_id = rr.assignment_action_id
       and iv.input_value_id  = nvl(ben_ext_person.g_chg_input_value_id,iv.input_value_id)
       and iv.element_type_id = et.element_type_id
       and aac.payroll_action_id = ppa.payroll_action_id
       and rr.element_type_id = et.element_type_id
       and rr.run_result_id = rv.run_result_id
       and rv.input_value_id = iv.input_value_id
       and et.classification_id  = ec.classification_id (+)
       and et.formula_id = ff.formula_id (+)
       and p_effective_date between nvl(iv.effective_start_date,p_effective_date)
            and nvl(iv.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(et.effective_start_date,p_effective_date)
            and nvl(et.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(asg.effective_start_date,p_effective_date)
            and nvl(asg.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(ff.effective_start_date,p_effective_date)
            and nvl(ff.effective_end_date,p_effective_date)
       and rv.result_value is not null;

    cursor c_asg
           (p_start_date date , p_end_date date) is
    select /*+ ordered */ aac.assignment_action_id       ,
           ppa.effective_Date    effective_Date
      from per_all_assignments_f asg,
           pay_assignment_actions aac,
           pay_payroll_actions ppa
      where asg.person_id = p_person_id
        --and asg.assignment_id = ben_ext_person.g_assignment_id  --1969853
        and asg.assignment_id = aac.assignment_id
        and aac.payroll_action_id = ppa.payroll_action_id
        and p_effective_date between asg.effective_start_date and asg.effective_end_date
        and (p_start_date is null or (ppa.effective_date  between
                                     p_start_date and p_end_date ) )  ;

   cursor c_rslt
          (c_assignment_action_id number)  is
   select iv.name                       value_name,
       iv.uom                           value_unit,
       iv.display_sequence              value_seq,
       iv.input_value_id                value_id,
       rr.run_result_id                 result_id,
       rr.jurisdiction_code             juris_code,
       rr.status                        status,
       rr.source_type                   source_type,
       rr.source_id                    source_id,
       rr.entry_type                    entry_type,
       rv.result_value                  result_value,
       iv.element_type_id
   from pay_run_results rr,
        pay_input_values_f iv,
        pay_run_result_values rv
   where rr.assignment_action_id = c_assignment_action_id
     and rr.element_type_id = iv.element_type_id
     and (ben_ext_person.g_chg_input_value_id is null
          or (iv.input_value_id  = ben_ext_person.g_chg_input_value_id))
     and rr.run_result_id = rv.run_result_id
     and rv.input_value_id = iv.input_value_id
     and rv.result_value is not null
     and p_effective_date between iv.effective_start_date
         and  iv.effective_end_date ;


    cursor c_rslt_p
          (c_assignment_action_id number,
           c_input_value_id   number ,
           c_element_type_id  number)  is
   select iv.name                       value_name,
       iv.uom                           value_unit,
       iv.display_sequence              value_seq,
       iv.input_value_id                value_id,
       rr.run_result_id                 result_id,
       rr.jurisdiction_code             juris_code,
       rr.status                        status,
       rr.source_type                   source_type,
       rr.source_id                    source_id,
       rr.entry_type                    entry_type,
       rv.result_value                  result_value,
       iv.element_type_id
   from pay_run_results rr,
        pay_input_values_f iv,
        pay_run_result_values rv
   where rr.assignment_action_id = c_assignment_action_id
     and rr.element_type_id = iv.element_type_id
     and (ben_ext_person.g_chg_input_value_id is null
          or (iv.input_value_id  = ben_ext_person.g_chg_input_value_id))
     and iv.input_value_id       = c_input_value_id
     and iv.element_type_id      = c_element_type_id
     and rr.run_result_id = rv.run_result_id
     and rv.input_value_id = iv.input_value_id
     and rv.result_value is not null
     and p_effective_date between iv.effective_start_date
         and  iv.effective_end_date ;

   cursor c_ele  ( c_element_type_id number )  is
   select et.element_name               element_name,
       et.element_type_id               element_id,
       et.reporting_name                reporting_name,
       et.description                   description,
       et.classification_id             class_id,
       ec.classification_name           class_name,
       et.processing_type               process_type,
       et.input_currency_code           input_currency,
       et.output_currency_code          output_currency,
       et.formula_id                    skip_rule_id  -- skip rule
    from pay_element_types_f et,
         pay_element_classifications ec
    where  et.element_type_id = c_element_type_id
       and et.classification_id  = ec.classification_id
       and p_effective_date between nvl(et.effective_start_date,p_effective_date)
       and nvl(et.effective_end_date ,p_effective_date);


    cursor c_ff  (c_formula_id number)  is
    select ff.formula_name  skip_rule_name
    from ff_formulas_f ff
    where  ff.formula_id = c_formula_id
      and p_effective_date between ff.effective_start_date
          and ff.effective_end_date ;


   BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   hr_utility.set_location('input_excld_flag ' || ben_ext_evaluate_inclusion.g_ele_input_excld_flag , 199 );
   hr_utility.set_location('lastDate_excldflag'||ben_ext_evaluate_inclusion.g_payroll_last_Date_excld_flag, 199) ;

   -- when the criteris is exclded

   if ben_ext_evaluate_inclusion.g_ele_input_excld_flag = 'Y'
      or ben_ext_evaluate_inclusion.g_payroll_last_Date_excld_flag = 'Y'
      then
      FOR runrslt IN c_runrslt_excl LOOP
      --
        -- initialize the globals - May, 99
        initialize_globals;
        --

        ben_ext_evaluate_inclusion.Evaluate_Elm_Entry_Incl
                    (p_processing_type  => runrslt.process_type ,
                     p_input_value_id   => runrslt.value_id    ,
                     p_business_group_id   => p_business_group_id   ,
                     p_pay_period_date  => runrslt.effective_date ,
                     p_effective_date   => p_effective_date  ,
                     p_person_id        => p_person_id   ,
                     p_element_type_id  => runrslt.element_id ,
                     p_source_id        => runrslt.source_id,
                     p_source_Type      => runrslt.source_type,
                     p_include          => l_include
                ) ;


        IF l_include = 'Y' THEN
          --
          -- assign run result elemts info to global variables
          --
          ben_ext_person.g_runrslt_element_name         := runrslt.element_name;
          ben_ext_person.g_runrslt_element_id           := runrslt.element_id;
          ben_ext_person.g_runrslt_reporting_name       := runrslt.reporting_name;
          ben_ext_person.g_runrslt_element_description  := runrslt.description;
          ben_ext_person.g_runrslt_classification       := runrslt.class_name;
          ben_ext_person.g_runrslt_classification_id    := runrslt.class_id;
          ben_ext_person.g_runrslt_processing_type      := runrslt.process_type;
          ben_ext_person.g_runrslt_input_currency       := runrslt.input_currency;
          ben_ext_person.g_runrslt_output_currency      := runrslt.output_currency;
          ben_ext_person.g_runrslt_skip_rule            := runrslt.skip_rule_name;
          ben_ext_person.g_runrslt_skip_rule_id         := runrslt.skip_rule_id;
          ben_ext_person.g_runrslt_input_value_name     := runrslt.value_name;
          ben_ext_person.g_runrslt_input_value_id       := runrslt.value_id;
          ben_ext_person.g_runrslt_input_value_units    := runrslt.value_unit;
          ben_ext_person.g_runrslt_input_value_sequence := runrslt.value_seq;
          ben_ext_person.g_runrslt_identifier           := runrslt.result_id;
          ben_ext_person.g_runrslt_jurisdiction_code    := runrslt.juris_code;
          ben_ext_person.g_runrslt_status           := runrslt.status;
          ben_ext_person.g_runrslt_source_type          := runrslt.source_type;
          ben_ext_person.g_runrslt_entry_type           := runrslt.entry_type;
          ben_ext_person.g_runrslt_value            := runrslt.result_value;
          ben_ext_person.g_runrslt_last_pay_date        := runrslt.effective_date;

          --
          -- format and write
          --
          ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                    p_ext_file_id       => p_ext_file_id,
                                    p_data_typ_cd       => p_data_typ_cd,
                                    p_ext_typ_cd        => p_ext_typ_cd,
                                    p_rcd_typ_cd        => 'D',  --detail
                                    p_low_lvl_cd        => 'R',  --payroll
                                    p_person_id         => p_person_id,
                                    p_chg_evt_cd        => p_chg_evt_cd,
                                    p_business_group_id => p_business_group_id,
                                    p_effective_date    => p_effective_date
                                    );
        --
        end if;
        --
      END LOOP;
      --
  else
       initialize_globals;
       ---intialise after writing rec
      for r_asg in  c_asg(ben_ext_person.g_pay_last_start_date
                          ,ben_ext_person.g_pay_last_end_date )
          loop

          --- the loop will be bracned in to two
          --- 1 with the input_valu_id from criteria
          --- 2 no criteria for input_value_id
          if  ben_ext_evaluate_inclusion.g_ele_input_list.count >  0 then
              l_dummy_no := ben_ext_evaluate_inclusion.g_ele_input_list.count ;
              for i  in 1 .. l_dummy_no
                  loop
                  for r_rslt  in c_rslt_p (r_asg.assignment_action_id,
                                     ben_ext_evaluate_inclusion.g_ele_input_list(i),
                                     ben_ext_evaluate_inclusion.g_ele_type_list(i))
                      Loop



                       for r_ele in c_ele  ( r_rslt.element_type_id )
                           Loop

                           --  if  rule define call for evaluation
                           l_include :=  'Y' ;
                           if  ben_ext_evaluate_inclusion.g_payroll_rl_incl_rqd = 'Y'  then

                               ben_ext_evaluate_inclusion.Evaluate_Elm_Entry_Incl
                                   (p_processing_type  =>   r_ele.process_type ,
                                    p_input_value_id   =>   r_rslt.value_id    ,
                                    p_business_group_id   => p_business_group_id   ,
                                    p_pay_period_date  =>   r_asg.effective_date ,
                                    p_effective_date   =>   p_effective_date  ,
                                    p_person_id        =>   p_person_id   ,
                                    p_element_type_id  =>   r_ele.element_id ,
                                    p_source_id        =>   r_rslt.source_id,
                                    p_source_Type      =>   r_rslt.source_type,
                                    p_include          => l_include
                                    ) ;
                           end if ;

                           IF l_include = 'Y' THEN

                              ben_ext_person.g_runrslt_last_pay_date        := r_asg.effective_date;
                              ben_ext_person.g_runrslt_input_value_units    := r_rslt.value_unit;
                              ben_ext_person.g_runrslt_input_value_sequence := r_rslt.value_seq;
                              ben_ext_person.g_runrslt_identifier           := r_rslt.result_id;
                              ben_ext_person.g_runrslt_input_value_id       := r_rslt.value_id;
                              ben_ext_person.g_runrslt_input_value_name     := r_rslt.value_name; --Bug 2669594
                              ben_ext_person.g_runrslt_jurisdiction_code    := r_rslt.juris_code;
                              ben_ext_person.g_runrslt_status               := r_rslt.status;
                              ben_ext_person.g_runrslt_source_type          := r_rslt.source_type;
                              ben_ext_person.g_runrslt_entry_type           := r_rslt.entry_type;
                              ben_ext_person.g_runrslt_value                := r_rslt.result_value;
                              ben_ext_person.g_runrslt_element_name         := r_ele.element_name;
                              ben_ext_person.g_runrslt_element_id           := r_ele.element_id;
                              ben_ext_person.g_runrslt_reporting_name       := r_ele.reporting_name;
                              ben_ext_person.g_runrslt_element_description  := r_ele.description;
                              ben_ext_person.g_runrslt_classification       := r_ele.class_name;
                              ben_ext_person.g_runrslt_classification_id    := r_ele.class_id;
                              ben_ext_person.g_runrslt_processing_type      := r_ele.process_type;
                              ben_ext_person.g_runrslt_input_currency       := r_ele.input_currency;
                              ben_ext_person.g_runrslt_output_currency      := r_ele.output_currency;
                              ben_ext_person.g_runrslt_skip_rule_id         := r_ele.skip_rule_id;
                              if r_ele.skip_rule_id is not null then
                                 open c_ff  (r_ele.skip_rule_id ) ;
                                 fetch c_ff into ben_ext_person.g_runrslt_skip_rule ;
                                 if c_ff%notfound then
                                    ben_ext_person.g_runrslt_skip_rule := null ;
                                 end if ;
                                 close c_ff ;
                              end if;
                              -- format and write
                              --
                              ben_ext_fmt.process_ext_recs(p_ext_rslt_id => p_ext_rslt_id,
                                       p_ext_file_id       => p_ext_file_id,
                                       p_data_typ_cd       => p_data_typ_cd,
                                       p_ext_typ_cd        => p_ext_typ_cd,
                                       p_rcd_typ_cd        => 'D',  --detail
                                       p_low_lvl_cd        => 'R',  --payroll
                                       p_person_id         => p_person_id,
                                       p_chg_evt_cd        => p_chg_evt_cd,
                                       p_business_group_id => p_business_group_id,
                                       p_effective_date    => p_effective_date
                                       );
                           end if ;
                           initialize_globals;

                       end loop ;
                  end loop ;

              end loop  ;

          Else  -- nor input value criteria

              for r_rslt  in c_rslt (r_asg.assignment_action_id)
                  Loop
                  for r_ele in c_ele  ( r_rslt.element_type_id )
                      Loop
                      --  if  rule define call for evaluation
                      l_include :=  'Y' ;
                      if  ben_ext_evaluate_inclusion.g_payroll_rl_incl_rqd = 'Y'  then

                               ben_ext_evaluate_inclusion.Evaluate_Elm_Entry_Incl
                                   (p_processing_type  =>   r_ele.process_type ,
                                    p_input_value_id   =>   r_rslt.value_id    ,
                                    p_business_group_id   => p_business_group_id   ,
                                    p_pay_period_date  =>   r_asg.effective_date ,
                                    p_effective_date   =>   p_effective_date  ,
                                    p_person_id        =>   p_person_id   ,
                                    p_element_type_id  =>   r_ele.element_id ,
                                    p_source_id        =>   r_rslt.source_id,
                                    p_source_Type      =>   r_rslt.source_type,
                                    p_include          => l_include
                                    );
                       end if ;

                       IF l_include = 'Y' THEN


                          ben_ext_person.g_runrslt_last_pay_date        := r_asg.effective_date;
                          ben_ext_person.g_runrslt_input_value_units    := r_rslt.value_unit;
                          ben_ext_person.g_runrslt_input_value_sequence := r_rslt.value_seq;
                          ben_ext_person.g_runrslt_identifier           := r_rslt.result_id;
                          ben_ext_person.g_runrslt_input_value_id       := r_rslt.value_id;
                          ben_ext_person.g_runrslt_input_value_name     := r_rslt.value_name; -- Bug 2669594
                          ben_ext_person.g_runrslt_jurisdiction_code    := r_rslt.juris_code;
                          ben_ext_person.g_runrslt_status               := r_rslt.status;
                          ben_ext_person.g_runrslt_source_type          := r_rslt.source_type;
                          ben_ext_person.g_runrslt_entry_type           := r_rslt.entry_type;
                          ben_ext_person.g_runrslt_value                := r_rslt.result_value;
                          ben_ext_person.g_runrslt_element_name         := r_ele.element_name;
                          ben_ext_person.g_runrslt_element_id           := r_ele.element_id;
                          ben_ext_person.g_runrslt_reporting_name       := r_ele.reporting_name;
                          ben_ext_person.g_runrslt_element_description  := r_ele.description;
                          ben_ext_person.g_runrslt_classification       := r_ele.class_name;
                          ben_ext_person.g_runrslt_classification_id    := r_ele.class_id;
                          ben_ext_person.g_runrslt_processing_type      := r_ele.process_type;
                          ben_ext_person.g_runrslt_input_currency       := r_ele.input_currency;
                          ben_ext_person.g_runrslt_output_currency      := r_ele.output_currency;
                          ben_ext_person.g_runrslt_skip_rule_id         := r_ele.skip_rule_id;
                          if r_ele.skip_rule_id is not null then
                              open c_ff  (r_ele.skip_rule_id ) ;
                              fetch c_ff into ben_ext_person.g_runrslt_skip_rule ;
                               if c_ff%notfound then
                                  ben_ext_person.g_runrslt_skip_rule := null ;
                               end if ;
                               close c_ff ;
                          end if;
                           -- format and write
                          ben_ext_fmt.process_ext_recs(p_ext_rslt_id => p_ext_rslt_id,
                                     p_ext_file_id       => p_ext_file_id,
                                     p_data_typ_cd       => p_data_typ_cd,
                                     p_ext_typ_cd        => p_ext_typ_cd,
                                     p_rcd_typ_cd        => 'D',  --detail
                                     p_low_lvl_cd        => 'R',  --payroll
                                     p_person_id         => p_person_id,
                                     p_chg_evt_cd        => p_chg_evt_cd,
                                     p_business_group_id => p_business_group_id,
                                     p_effective_date    => p_effective_date
                                     );
                      end if ;
                      initialize_globals;

                  end loop ;

              end loop ;

          end if;  -- eof input value criteria
      end loop ; ---- asg loop
  end if  ; -- exclide flag
  hr_utility.set_location('Exiting'||l_proc, 15);
   --
  END main;

END;

/
