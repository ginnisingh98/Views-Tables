--------------------------------------------------------
--  DDL for Package Body BEN_EXT_PAYROLL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_PAYROLL" as
/* $Header: benxpayr.pkb 120.3.12010000.3 2008/09/05 13:16:27 vkodedal ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract Payroll Process.
Purpose:
    This process handles fields that are related to Element Entries and Input Values.
History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        18 Dec 98        Ty Hayden  115.0      Created.
        21 Dec 98        Ty Hayden  115.1      Added g_chg_input_value_idn to cursor.
        09 Mar 99        G Perry    115.2      IS to AS.
        13 Mar 99        Ty Hayden  115.3      Moved globals to ben_ext_person.
        17 May 99        Isen       115.4      Removed null others exception handler
                                               - bug 2422.
        25 May 99        Isen       115.5      Added procedure to initialize the globals
        01 Jul 99        Asen       115.6      Added code for decode fields.
        1 Jul 00        Sdas       115.7      Added g3_element_entry_value_is.
        2 apr 02        tjesumic   115.9      g_element_eev_eff_strt_date,g_element_eev_eff_end_date
                                              added for 2202990
        3 apr 02        tjesumic   115.10     dbdrv added
        24-Dec-05        tjesumic   115.11      formula added for payroll
        24-Dec-05        tjesumic   115.12      formula added for payroll
        27-Feb-06       anshghos    115.13     modified cursor c_pay, removed last where clause of
                                               "and screen_entry_value is not null;"
                                               This is cause in element repeating level, elements without a
                                               PayValue were not being picked up.
        11-Jun-07       tjesumic   115.14    for performance c_pay cursor splited into differenct cursors
         05-sep-08     vkodedal   115.15    performance fix - allowance extract - penserver - 7371957
*/
-----------------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_payroll.';  -- Global package name
--
-- procedure to initialize the globals - May, 99
-- --------------------------------------------------------------------------------
-- |----------------< initialize_globals >----------------------------------------------|
-- --------------------------------------------------------------------------------
PROCEDURE initialize_globals IS
--
  --
  l_proc             varchar2(72) := g_package||'initialize_globals';
  --
Begin
--
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
    ben_ext_person.g_element_name                        := null;
    ben_ext_person.g_element_id                          := null;
    ben_ext_person.g_element_reporting_name              := null;
    ben_ext_person.g_element_description                 := null;
    ben_ext_person.g_element_classification_name         := null;
    ben_ext_person.g_element_classification_id           := null;
    ben_ext_person.g_element_processing_type             := null;
    ben_ext_person.g_element_input_currency_code         := null;
    ben_ext_person.g_element_output_currency_code        := null;
    ben_ext_person.g_element_skip_rule                   := null;
    ben_ext_person.g_element_skip_rule_id                := null;
    ben_ext_person.g_element_input_value_name            := null;
    ben_ext_person.g_element_input_value_id              := null;
    ben_ext_person.g_element_input_value_units           := null;
    ben_ext_person.g_element_input_value_sequence        := null;
    ben_ext_person.g_element_entry_value                 := null;
    ben_ext_person.g_element_entry_costing               := null;
    ben_ext_person.g_element_entry_costing_id            := null;
    ben_ext_person.g_element_entry_reason                := null;
    ben_ext_person.g_element_entry_id                    := null;
    ben_ext_person.g_element_entry_eff_start_date        := null;
    ben_ext_person.g_element_entry_eff_end_date          := null;
    ben_ext_person.g_element_entry_value_id              := null;
    ben_ext_person.g_element_eev_eff_strt_date           := null;
    ben_ext_person.g_element_eev_eff_end_date            := null;
  --
  hr_utility.set_location('Exiting'||l_proc, 15);
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
   --

--Changes for Penserver: Start
/*   cursor c_pay is
      select
       iv.name,
       iv.uom,
       iv.display_sequence,
       iv.input_value_id,
       iv.element_type_id,
       eev.screen_entry_value,
       eev.element_entry_value_id,
       eev.effective_start_date  eev_effective_start_date,
       eev.effective_end_date    eev_effective_end_date,
       ee.cost_allocation_keyflex_id,
       ee.reason,
       ee.effective_start_date,
       ee.effective_end_date,
       ee.element_entry_id
     from
       pay_element_entry_values_f eev,
       pay_element_entries_f ee,
       per_all_assignments_f asg,
       pay_input_values_f iv
     where
       asg.person_id = p_person_id
       and asg.assignment_id  = ee.assignment_id
       and ee.element_entry_id  = eev.element_entry_id
       and iv.input_value_id  = eev.input_value_id
       and (ben_ext_person.g_chg_input_value_id is null
             or ben_ext_person.g_chg_input_value_id = iv.input_value_id
           )
       and p_effective_date between asg.effective_start_date and asg.effective_end_date
       and p_effective_date between ee.effective_start_date and ee.effective_end_date
       and p_effective_date between eev.effective_start_date and eev.effective_end_date
       and p_effective_date between iv.effective_start_date and iv.effective_end_date
       ;
 */
    CURSOR c_get_evnt_group
    IS
     SELECT val_1
     FROM BEN_EXT_CRIT_VAL val,
          BEN_EXT_CRIT_TYP typ,
	  BEN_EXT_CRIT_PRFL prfl
     WHERE val.ext_crit_typ_id = typ.ext_crit_typ_id
     AND typ.ext_crit_prfl_id = prfl.ext_crit_prfl_id
     AND prfl.name = 'PQP GB PenServer Periodic Changes Criteria - Allowance History'
     AND prfl.legislation_code = 'GB'
     AND typ.crit_typ_cd = 'CPE'
     AND typ.legislation_code = 'GB'
     AND val.legislation_code = 'GB';

    l_allowance_flag      varchar2(2) := 'N';

    TYPE get_pay_ref_csr_typ IS REF CURSOR;
         c_pay      get_pay_ref_csr_typ;


    TYPE get_csr_val IS RECORD
    (
      name			  pay_input_values_f.name%TYPE,
      uom			  pay_input_values_f.uom%TYPE,
      display_sequence		  pay_input_values_f.display_sequence%TYPE,
      input_value_id		  pay_input_values_f.input_value_id%TYPE,
      element_type_id		  pay_input_values_f.element_type_id%TYPE,
      screen_entry_value          pay_element_entry_values_f.screen_entry_value%TYPE,
      element_entry_value_id      pay_element_entry_values_f.element_entry_value_id%TYPE,
      eev_effective_start_date    pay_element_entry_values_f.effective_start_date%TYPE,
      eev_effective_end_date      pay_element_entry_values_f.effective_end_date%TYPE,
      cost_allocation_keyflex_id  pay_element_entries_f.cost_allocation_keyflex_id%TYPE,
      reason                      pay_element_entries_f.reason%TYPE,
      effective_start_date        pay_element_entries_f.effective_start_date%TYPE,
      effective_end_date          pay_element_entries_f.effective_end_date%TYPE,
      element_entry_id            pay_element_entries_f.element_entry_id%TYPE
    );

    pay           get_csr_val;
--Changes for Penserver: Stop


    cursor c_ele_type (p_element_type_id number) is
    select
       et.element_name,
       et.reporting_name,
       et.description,
       et.classification_id,
       et.processing_type,
       et.input_currency_code,
       et.output_currency_code,
       et.formula_id  -- skip rule
    from pay_element_types_f et
    where et.element_type_id = p_element_type_id
      and p_effective_date between et.effective_start_date and et.effective_end_date
    ;


  cursor c_ele_clas (p_classification_id number) is
  select ec.classification_name
  from  pay_element_classifications ec
  where ec.classification_id = p_classification_id
  ;

  cursor c_ff_name (p_formula_id number) is
  select ff.formula_name
  from ff_formulas_f ff
  where ff.formula_id = p_formula_id
  and p_effective_date between ff.effective_start_date and ff.effective_end_date
  ;

  cursor c_ele_conc (p_cost_allocation_keyflex_id number) is
  select ca.concatenated_segments
  from pay_cost_allocation_keyflex ca
  where ca.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
 ;


/*

   cursor c_pay is
   select
       et.element_name,
       et.element_type_id,
       et.reporting_name,
       et.description,
       et.classification_id,
       ec.classification_name,
       et.processing_type,
       et.input_currency_code,
       et.output_currency_code,
       et.formula_id,  -- skip rule
       ff.formula_name,
       iv.name,
       iv.uom,
       iv.display_sequence,
       iv.input_value_id,
       eev.screen_entry_value,
       eev.element_entry_value_id,
       eev.effective_start_date  eev_effective_start_date,
       eev.effective_end_date    eev_effective_end_date,
       ee.cost_allocation_keyflex_id,
       ca.concatenated_segments,
       ee.reason,
       ee.effective_start_date,
       ee.effective_end_date,
       ee.element_entry_id
     from
       pay_element_entry_values_f eev,
       pay_element_entries_f ee,
       per_all_assignments_f asg,
       per_all_people_f per,
       pay_input_values_f iv,
       pay_element_types_f et,
       pay_element_classifications ec,
       ff_formulas_f ff,
       pay_cost_allocation_keyflex ca
     where
       per.person_id = p_person_id
       and iv.input_value_id  = nvl(ben_ext_person.g_chg_input_value_id,iv.input_value_id)
       and ee.element_entry_id  = eev.element_entry_id
       and asg.assignment_id  = ee.assignment_id
       and per.person_id   = asg.person_id
       and iv.input_value_id  = eev.input_value_id
       and iv.element_type_id = et.element_type_id
       and et.classification_id  = ec.classification_id (+)
       and ee.cost_allocation_keyflex_id = ca.cost_allocation_keyflex_id (+)
       and et.formula_id = ff.formula_id (+)
       and p_effective_date between nvl(asg.effective_start_date,p_effective_date)
            and nvl(asg.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(per.effective_start_date,p_effective_date)
            and nvl(per.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(ee.effective_start_date,p_effective_date)
            and nvl(ee.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(eev.effective_start_date,p_effective_date)
            and nvl(eev.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(iv.effective_start_date,p_effective_date)
            and nvl(iv.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(et.effective_start_date,p_effective_date)
            and nvl(et.effective_end_date ,p_effective_date)
       and p_effective_date between nvl(ff.effective_start_date,p_effective_date)
            and nvl(ff.effective_end_date,p_effective_date);
       -- and screen_entry_value is not null;

  */


   BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
--Changes for Penserver: Start
   FOR event IN c_get_evnt_group
   LOOP
        hr_utility.set_location('event.val_1: '||event.val_1, 100);
        IF event.val_1 = p_chg_evt_cd
        THEN
             hr_utility.set_location('Set allowance flag= Y and exit loop', 100);
             l_allowance_flag := 'Y';
             EXIT;
         END IF;
   END LOOP;

   hr_utility.set_location('l_allowance_flag: '||l_allowance_flag, 100);

   IF l_allowance_flag = 'Y'
   THEN
       OPEN c_pay FOR
		       select
		       iv.name,
		       iv.uom,
		       iv.display_sequence,
		       iv.input_value_id,
		       iv.element_type_id,
		       eev.screen_entry_value,
		       eev.element_entry_value_id,
		       eev.effective_start_date  eev_effective_start_date,
		       eev.effective_end_date    eev_effective_end_date,
		       ee.cost_allocation_keyflex_id,
		       ee.reason,
		       ee.effective_start_date,
		       ee.effective_end_date,
		       ee.element_entry_id
		       from
		       pay_element_entry_values_f eev,
		       pay_element_entries_f ee,
		       per_all_assignments_f asg,
		       pay_input_values_f iv
		      where
		       asg.person_id = p_person_id
		       and asg.assignment_id  = ee.assignment_id
		       and ee.element_entry_id  = eev.element_entry_id
		       and iv.input_value_id  = eev.input_value_id
		       and ee.element_type_id in (Select element_type_id
				                 From PAY_ELEMENT_TYPE_RULES rule,
						      PAY_EVENT_GROUP_USAGES usg,
						      pay_event_groups grp
				                 Where rule.element_set_id = usg.element_set_id
						 AND usg.event_group_id = grp.event_group_id
		                                 AND grp.event_group_name = 'PQP_GB_PSI_ALL_ELEMENT_ENTRIES'
		                                 AND grp.legislation_code = 'GB')
		       and (ben_ext_person.g_chg_input_value_id is null
		             or ben_ext_person.g_chg_input_value_id = iv.input_value_id
		           )
		       and p_effective_date between asg.effective_start_date and asg.effective_end_date
		       and p_effective_date between ee.effective_start_date and ee.effective_end_date
		       and p_effective_date between eev.effective_start_date and eev.effective_end_date
		       and p_effective_date between iv.effective_start_date and iv.effective_end_date;

   ELSE
       OPEN c_pay FOR
		       select
		       iv.name,
		       iv.uom,
		       iv.display_sequence,
		       iv.input_value_id,
		       iv.element_type_id,
		       eev.screen_entry_value,
		       eev.element_entry_value_id,
		       eev.effective_start_date  eev_effective_start_date,
		       eev.effective_end_date    eev_effective_end_date,
		       ee.cost_allocation_keyflex_id,
		       ee.reason,
		       ee.effective_start_date,
		       ee.effective_end_date,
		       ee.element_entry_id
		      from
		       pay_element_entry_values_f eev,
		       pay_element_entries_f ee,
		       per_all_assignments_f asg,
		       pay_input_values_f iv
		      where
		       asg.person_id = p_person_id
		       and asg.assignment_id  = ee.assignment_id
		       and ee.element_entry_id  = eev.element_entry_id
		       and iv.input_value_id  = eev.input_value_id
		       and (ben_ext_person.g_chg_input_value_id is null
		             or ben_ext_person.g_chg_input_value_id = iv.input_value_id
		           )
		       and p_effective_date between asg.effective_start_date and asg.effective_end_date
		       and p_effective_date between ee.effective_start_date and ee.effective_end_date
		       and p_effective_date between eev.effective_start_date and eev.effective_end_date
		       and p_effective_date between iv.effective_start_date and iv.effective_end_date;
   END IF;

   LOOP
        FETCH c_pay INTO pay;
	EXIT WHEN c_pay%NOTFOUND;

        -- initialize the globals - May, 99
        initialize_globals;

        ben_ext_person.g_element_input_value_name            := pay.name;
        ben_ext_person.g_element_input_value_units           := pay.uom;
        ben_ext_person.g_element_input_value_sequence        := pay.display_sequence;
        ben_ext_person.g_element_input_value_id              := pay.input_value_id;
        ben_ext_person.g_element_id                          := pay.element_type_id;
        ben_ext_person.g_element_entry_value                 := pay.screen_entry_value;
        ben_ext_person.g_element_entry_value_id              := pay.element_entry_value_id;
        ben_ext_person.g_element_entry_eff_start_date        := pay.effective_start_date;
        ben_ext_person.g_element_entry_eff_end_date          := pay.effective_end_date;
        ben_ext_person.g_element_entry_costing_id            := pay.cost_allocation_keyflex_id;
        ben_ext_person.g_element_entry_reason                := pay.reason;
        ben_ext_person.g_element_eev_eff_strt_date           := pay.eev_effective_start_date;
        ben_ext_person.g_element_eev_eff_end_date            := pay.eev_effective_end_date;
        ben_ext_person.g_element_entry_id                    := pay.element_entry_id;

        open c_ele_type(pay.element_type_id) ;
        fetch c_ele_type into
             ben_ext_person.g_element_name  ,
             ben_ext_person.g_element_reporting_name,
             ben_ext_person.g_element_description ,
             ben_ext_person.g_element_classification_id ,
             ben_ext_person.g_element_processing_type,
             ben_ext_person.g_element_input_currency_code ,
             ben_ext_person.g_element_output_currency_code,
             ben_ext_person.g_element_skip_rule_id;
        close c_ele_type ;
     --

        ben_ext_evaluate_inclusion.Evaluate_Elm_Entry_Incl
                    (p_processing_type     => ben_ext_person.g_element_processing_type ,
                     p_input_value_id      => pay.input_value_id    ,
                     p_business_group_id   => p_business_group_id   ,
                     p_effective_date      => p_effective_date  ,
                     p_person_id           => p_person_id   ,
                     p_element_type_id     => pay.element_type_id ,
                     p_source_id           => null ,
                     p_source_Type         => null ,
                     p_element_entry_id    => pay.element_entry_id ,
                     p_include             => l_include
                     ) ;

       IF l_include = 'Y' THEN
       --
       -- assign enrollment info to global variables
       --


           if  ben_ext_person.g_element_classification_id is not null then
               open c_ele_clas (ben_ext_person.g_element_classification_id) ;
               fetch c_ele_clas into ben_ext_person.g_element_classification_name ;
               close c_ele_clas ;
           end if ;

           if ben_ext_person.g_element_skip_rule_id is not null then
              open c_ff_name (ben_ext_person.g_element_skip_rule_id) ;
              fetch c_ff_name into ben_ext_person.g_element_skip_rule ;
              close c_ff_name ;
           end if ;

           if ben_ext_person.g_element_entry_costing_id is not null then
              open c_ele_conc (ben_ext_person.g_element_entry_costing_id) ;
              fetch c_ele_conc into ben_ext_person.g_element_entry_costing ;
              close c_ele_conc ;
           end if ;

           hr_utility.set_location('eeveffdate '||ben_ext_person.g_element_eev_eff_strt_date||
                                    '-'||ben_ext_person.g_element_eev_eff_end_date  ,99);
       --
        -- format and write
       --
           ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                    p_ext_file_id       => p_ext_file_id,
                                    p_data_typ_cd       => p_data_typ_cd,
                                    p_ext_typ_cd        => p_ext_typ_cd,
                                    p_rcd_typ_cd        => 'D',  --detail
                                    p_low_lvl_cd        => 'Y',  --payroll
                                    p_person_id         => p_person_id,
                                    p_chg_evt_cd        => p_chg_evt_cd,
                                    p_business_group_id => p_business_group_id,
                                    p_effective_date    => p_effective_date
                                    );
       --
       end if;

   END LOOP;
   CLOSE c_pay;

/*   FOR pay IN c_pay LOOP
     -- initialize the globals - May, 99
     initialize_globals;

       ben_ext_person.g_element_input_value_name            := pay.name;
       ben_ext_person.g_element_input_value_units           := pay.uom;
       ben_ext_person.g_element_input_value_sequence        := pay.display_sequence;
       ben_ext_person.g_element_input_value_id              := pay.input_value_id;
       ben_ext_person.g_element_id                          := pay.element_type_id;
       ben_ext_person.g_element_entry_value                 := pay.screen_entry_value;
       ben_ext_person.g_element_entry_value_id              := pay.element_entry_value_id;
       ben_ext_person.g_element_entry_eff_start_date        := pay.effective_start_date;
       ben_ext_person.g_element_entry_eff_end_date          := pay.effective_end_date;
       ben_ext_person.g_element_entry_costing_id            := pay.cost_allocation_keyflex_id;
       ben_ext_person.g_element_entry_reason                := pay.reason;
       ben_ext_person.g_element_eev_eff_strt_date           := pay.eev_effective_start_date;
       ben_ext_person.g_element_eev_eff_end_date            := pay.eev_effective_end_date;
       ben_ext_person.g_element_entry_id                    := pay.element_entry_id;


       open c_ele_type(pay.element_type_id) ;
       fetch c_ele_type into
            ben_ext_person.g_element_name  ,
            ben_ext_person.g_element_reporting_name,
            ben_ext_person.g_element_description ,
            ben_ext_person.g_element_classification_id ,
            ben_ext_person.g_element_processing_type,
            ben_ext_person.g_element_input_currency_code ,
            ben_ext_person.g_element_output_currency_code,
            ben_ext_person.g_element_skip_rule_id
        ;
       close c_ele_type ;


     --

      ben_ext_evaluate_inclusion.Evaluate_Elm_Entry_Incl
                    (p_processing_type     => ben_ext_person.g_element_processing_type ,
                     p_input_value_id      => pay.input_value_id    ,
                     p_business_group_id   => p_business_group_id   ,
                     p_effective_date      => p_effective_date  ,
                     p_person_id           => p_person_id   ,
                     p_element_type_id     => pay.element_type_id ,
                     p_source_id           => null ,
                     p_source_Type         => null ,
                     p_element_entry_id    => pay.element_entry_id ,
                     p_include             => l_include
                ) ;


     IF l_include = 'Y' THEN
       --
       -- assign enrollment info to global variables
       --


       if  ben_ext_person.g_element_classification_id is not null then
           open c_ele_clas (ben_ext_person.g_element_classification_id) ;
           fetch c_ele_clas into ben_ext_person.g_element_classification_name ;
           close c_ele_clas ;
       end if ;

       if ben_ext_person.g_element_skip_rule_id is not null then
          open c_ff_name (ben_ext_person.g_element_skip_rule_id) ;
          fetch c_ff_name into ben_ext_person.g_element_skip_rule ;
          close c_ff_name ;
       end if ;

       if ben_ext_person.g_element_entry_costing_id is not null then
          open c_ele_conc (ben_ext_person.g_element_entry_costing_id) ;
          fetch c_ele_conc into ben_ext_person.g_element_entry_costing ;
          close c_ele_conc ;
       end if ;

       hr_utility.set_location('eeveffdate '||ben_ext_person.g_element_eev_eff_strt_date||
                                    '-'||ben_ext_person.g_element_eev_eff_end_date  ,99);
       --
       -- format and write
       --
       ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                    p_ext_file_id       => p_ext_file_id,
                                    p_data_typ_cd       => p_data_typ_cd,
                                    p_ext_typ_cd        => p_ext_typ_cd,
                                    p_rcd_typ_cd        => 'D',  --detail
                                    p_low_lvl_cd        => 'Y',  --payroll
                                    p_person_id         => p_person_id,
                                    p_chg_evt_cd        => p_chg_evt_cd,
                                    p_business_group_id => p_business_group_id,
                                    p_effective_date    => p_effective_date
                                    );
       --
     end if;
     --
   END LOOP; */
--Changes for Penserver: Stop
   --
   hr_utility.set_location('Exiting'||l_proc, 15);
   --
   END main;

END;

/
