--------------------------------------------------------
--  DDL for Package Body PAY_PAYROLLS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYROLLS_F_PKG" as
/* $Header: pyprl01t.pkb 120.2 2006/11/10 16:49:25 ajeyam noship $ */
--
 c_end_of_time constant date := to_date('31/12/4712','DD/MM/YYYY');
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   maintain_soft_coding_keyflex                                          --
 -- Purpose                                                                 --
 --   Maintains the SCL keyflex. As the SCL keyflex can be set at different --
 --   levels ie. assignment, payroll, organization etc ... the standard FND --
 --   VALID cannot deal with partial flexfields so this function replaces   --
 --   it.                                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 function maintain_soft_coding_keyflex
 (
  p_scl_structure          number,
  p_soft_coding_keyflex_id number,
  p_concatenated_segments  varchar2,
  p_summary_flag           varchar2,
  p_start_date_active      date,
  p_end_date_active        date,
  p_segment1               varchar2,
  p_segment2               varchar2,
  p_segment3               varchar2,
  p_segment4               varchar2,
  p_segment5               varchar2,
  p_segment6               varchar2,
  p_segment7               varchar2,
  p_segment8               varchar2,
  p_segment9               varchar2,
  p_segment10              varchar2,
  p_segment11              varchar2,
  p_segment12              varchar2,
  p_segment13              varchar2,
  p_segment14              varchar2,
  p_segment15              varchar2,
  p_segment16              varchar2,
  p_segment17              varchar2,
  p_segment18              varchar2,
  p_segment19              varchar2,
  p_segment20              varchar2,
  p_segment21              varchar2,
  p_segment22              varchar2,
  p_segment23              varchar2,
  p_segment24              varchar2,
  p_segment25              varchar2,
  p_segment26              varchar2,
  p_segment27              varchar2,
  p_segment28              varchar2,
  p_segment29              varchar2,
  p_segment30              varchar2
 ) return number is
--
   cursor csr_soft_coding_exists is
     select hsc.soft_coding_keyflex_id
     from   hr_soft_coding_keyflex hsc
     where  hsc.soft_coding_keyflex_id = p_soft_coding_keyflex_id;
--
   v_dummy number;
   v_soft_coding_keyflex_id number := p_soft_coding_keyflex_id;
--
 begin
--
   -- A soft_keyflex_id has been specified so confirm it still is valid.
   if (v_soft_coding_keyflex_id is not null and
       v_soft_coding_keyflex_id <> -1) then
--
     open csr_soft_coding_exists;
     fetch csr_soft_coding_exists into v_dummy;
--
     -- Keyflex does not exist so need to rederive a soft_keyflex_id.
     if csr_soft_coding_exists%notfound then
       v_soft_coding_keyflex_id := -1;
     -- Keyflex does exist.
     else
       v_soft_coding_keyflex_id := p_soft_coding_keyflex_id;
     end if;
--
     close csr_soft_coding_exists;
--
   end if;
--
   if (v_soft_coding_keyflex_id = -1) then
--
     -- Need to check for a partial value.
     begin
       select s.soft_coding_keyflex_id
       into   v_soft_coding_keyflex_id
       from   hr_soft_coding_keyflex s
       where  s.id_flex_num   = p_scl_structure
       and    s.enabled_flag  = 'Y'
       and   (s.segment1      = p_segment1
       or    (s.segment1      is null
       and    p_segment1  is null))
       and   (s.segment2      = p_segment2
       or    (s.segment2      is null
       and    p_segment2  is null))
       and   (s.segment3      = p_segment3
       or    (s.segment3      is null
       and    p_segment3  is null))
       and   (s.segment4      = p_segment4
       or    (s.segment4      is null
       and    p_segment4  is null))
       and   (s.segment5      = p_segment5
       or    (s.segment5      is null
       and    p_segment5  is null))
       and   (s.segment6      = p_segment6
       or    (s.segment6      is null
       and    p_segment6  is null))
       and   (s.segment7      = p_segment7
       or    (s.segment7      is null
       and    p_segment7  is null))
       and   (s.segment8      = p_segment8
       or    (s.segment8      is null
       and    p_segment8  is null))
       and   (s.segment9      = p_segment9
       or    (s.segment9      is null
       and    p_segment9  is null))
       and   (s.segment10     = p_segment10
       or    (s.segment10     is null
       and    p_segment10 is null))
       and   (s.segment11     = p_segment11
       or    (s.segment11     is null
       and    p_segment11 is null))
       and   (s.segment12     = p_segment12
       or    (s.segment12     is null
       and    p_segment12 is null))
       and   (s.segment13     = p_segment13
       or    (s.segment13     is null
       and    p_segment13 is null))
       and   (s.segment14     = p_segment14
       or    (s.segment14     is null
       and    p_segment14 is null))
       and   (s.segment15     = p_segment15
       or    (s.segment15     is null
       and    p_segment15 is null))
       and   (s.segment16     = p_segment16
       or    (s.segment16     is null
       and    p_segment16 is null))
       and   (s.segment17     = p_segment17
       or    (s.segment17     is null
       and    p_segment17 is null))
       and   (s.segment18     = p_segment18
       or    (s.segment18     is null
       and    p_segment18 is null))
       and   (s.segment19     = p_segment19
       or    (s.segment19     is null
       and    p_segment19 is null))
       and   (s.segment20     = p_segment20
       or    (s.segment20     is null
       and    p_segment20 is null))
       and   (s.segment21     = p_segment21
       or    (s.segment21     is null
       and    p_segment21 is null))
       and   (s.segment22     = p_segment22
       or    (s.segment22     is null
       and    p_segment22 is null))
       and   (s.segment23     = p_segment23
       or    (s.segment23     is null
       and    p_segment23 is null))
       and   (s.segment24     = p_segment24
       or    (s.segment24     is null
       and    p_segment24 is null))
       and   (s.segment25     = p_segment25
       or    (s.segment25     is null
       and    p_segment25 is null))
       and   (s.segment26     = p_segment26
       or    (s.segment26     is null
       and    p_segment26 is null))
       and   (s.segment27     = p_segment27
       or    (s.segment27     is null
       and    p_segment27 is null))
       and   (s.segment28     = p_segment28
       or    (s.segment28     is null
       and    p_segment28 is null))
       and   (s.segment29     = p_segment29
       or    (s.segment29     is null
       and    p_segment29 is null))
       and   (s.segment30     = p_segment30
       or    (s.segment30     is null
       and    p_segment30 is null));
     exception
       when no_data_found then null;
       when too_many_rows then null;
     end;
--
     -- check to see if the soft coding keyflex combination already
     -- exists. if it doesn't then, insert the required row.
     if (v_soft_coding_keyflex_id = -1) then
--
       -- select the next sequence value for the soft coding keyflex.
       begin
         select hr_soft_coding_keyflex_s.nextval
         into   v_soft_coding_keyflex_id
         from   sys.dual;
       exception
         when NO_DATA_FOUND then
           hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE',
                         'pay_payrolls_f_pkg.maintain_soft_coding_keyflex');
           hr_utility.set_message_token('STEP','1');
           hr_utility.raise_error;
       end;
--
       -- Insert the new row.
       begin
         insert into hr_soft_coding_keyflex
         (soft_coding_keyflex_id
         ,concatenated_segments
         ,id_flex_num
         ,last_update_date
         ,last_updated_by
         ,summary_flag
         ,enabled_flag
         ,start_date_active
         ,end_date_active
         ,segment1
         ,segment2
         ,segment3
         ,segment4
         ,segment5
         ,segment6
         ,segment7
         ,segment8
         ,segment9
         ,segment10
         ,segment11
         ,segment12
         ,segment13
         ,segment14
         ,segment15
         ,segment16
         ,segment17
         ,segment18
         ,segment19
         ,segment20
         ,segment21
         ,segment22
         ,segment23
         ,segment24
         ,segment25
         ,segment26
         ,segment27
         ,segment28
         ,segment29
         ,segment30)
         values
         (v_soft_coding_keyflex_id
         ,p_concatenated_segments
         ,p_scl_structure
         ,null
         ,null
         ,p_summary_flag
         ,'Y'
         ,p_start_date_active
         ,p_end_date_active
         ,p_segment1
         ,p_segment2
         ,p_segment3
         ,p_segment4
         ,p_segment5
         ,p_segment6
         ,p_segment7
         ,p_segment8
         ,p_segment9
         ,p_segment10
         ,p_segment11
         ,p_segment12
         ,p_segment13
         ,p_segment14
         ,p_segment15
         ,p_segment16
         ,p_segment17
         ,p_segment18
         ,p_segment19
         ,p_segment20
         ,p_segment21
         ,p_segment22
         ,p_segment23
         ,p_segment24
         ,p_segment25
         ,p_segment26
         ,p_segment27
         ,p_segment28
         ,p_segment29
         ,p_segment30);
       end;
--
     end if;
--
     return(v_soft_coding_keyflex_id);
--
   end if;
--
   return(v_soft_coding_keyflex_id);
--
 end maintain_soft_coding_keyflex;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   current_values                                                        --
 -- Purpose                                                                 --
 --  Returns the current values for several columns so that a check can be  --
 --  made to see if the value has changed.                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 procedure current_values
 (
  p_rowid                     varchar2,
  p_payroll_name              in out nocopy varchar2,
  p_number_of_years           in out nocopy number,
  p_default_payment_method_id in out nocopy number
 ) is
--
   cursor csr_current_values is
     select prl.payroll_name,
      prl.number_of_years,
      prl.default_payment_method_id
     from   pay_payrolls_f prl
     where  prl.rowid = p_rowid;
--
   v_values_rec csr_current_values%rowtype;
--
 begin
--
   open csr_current_values;
   fetch csr_current_values into v_values_rec;
   if csr_current_values%notfound then
     close csr_current_values;
     hr_utility.set_message(801, 'ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
          'pay_payrolls_f_pkg.current_values');
     hr_utility.set_message_token('STEP', 1);
     hr_utility.raise_error;
   else
     close csr_current_values;
   end if;
--
   p_payroll_name              := v_values_rec.payroll_name;
   p_number_of_years           := v_values_rec.number_of_years;
   p_default_payment_method_id := v_values_rec.default_payment_method_id;
--
 end current_values;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   lock_payroll                                                          --
 -- Purpose                                                                 --
 --   Locks the specified payroll.                                          --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This is used to reduce concurrency problems when changing /  checking --
 --   time periods.                                                         --
 -----------------------------------------------------------------------------
--
 procedure lock_payroll
 (
  p_payroll_id number
 ) is
--
   cursor csr_lock_payroll is
     select prl.payroll_id
     from   pay_payrolls_f prl
     where  prl.payroll_id = p_payroll_id
     for    update;
--
 begin
--
   open csr_lock_payroll;
   close csr_lock_payroll;
--
 end lock_payroll;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_payroll_unique                                                    --
 -- Purpose                                                                 --
 --   Make sure that the payroll name being entered is unique within the    --
 --   business group.                                                       --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 procedure chk_payroll_unique
 (
  p_payroll_id        number,
  p_payroll_name      varchar2,
  p_business_group_id number
 ) is
--
   cursor csr_payroll_exists is
     SELECT prl.payroll_id
     from   pay_all_payrolls_f prl
     where  upper(prl.payroll_name) = upper(p_payroll_name)
       and  (prl.payroll_id <> p_payroll_id or
       p_payroll_id is null)
       and  prl.business_group_id + 0 = p_business_group_id;
--
   v_payroll_id number;
--
 begin
--
   -- Make sure payroll name is unique.
   open csr_payroll_exists;
   fetch csr_payroll_exists into v_payroll_id;
   if csr_payroll_exists%found then
     close csr_payroll_exists;
     hr_utility.set_message(801, 'HR_6667_PAY_PAYROLL_EXISTS');
     hr_utility.raise_error;
   else
     close csr_payroll_exists;
   end if;
--
 end chk_payroll_unique;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   propagate_changes                                                     --
 -- Purpose                                                                 --
 --   Copies values accross all datetrack rows for a payroll.               --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   The NUMBER_OF_YEARS and PAYROLL_NAME columns are not datetracked in   --
 --   that they should be the same for the lifetime of the payroll. As a   --
 --   workaround to datetrack the rows are updated after datetrack has been --
 --   called.                                                               --
 -----------------------------------------------------------------------------
--
 procedure propagate_changes
 (
  p_payroll_id      number,
  p_payroll_name    varchar2,
  p_number_of_years number
 ) is
--
   cursor csr_payroll_rows is
     select prl.payroll_name,
      prl.number_of_years
     from   pay_payrolls_f prl
     where  prl.payroll_id = p_payroll_id
     for update;
--
 begin
--
   for v_prl_rec in csr_payroll_rows loop
--
     update pay_payrolls_f prl
     set    prl.payroll_name    = nvl(p_payroll_name,
              v_prl_rec.payroll_name),
      prl.number_of_years = nvl(p_number_of_years,
              v_prl_rec.number_of_years)
     where  current of csr_payroll_rows;
--
   end loop;
--
 end propagate_changes;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_bg_and_leg_info                                                   --
 -- Purpose                                                                 --
 --   1.Retrieves keyflex structure for the legislations SCL and also for the --
 --   costing keyflex for the business group.                   --
 --   2.Looks for rules in PAY_LEGISLATION_RULES for the disabling of       --
 --   update of time period                   --
 --   dates ie. some legislations require that some dates cannot be changed --
 --   eg. cannot update the regular payment date etc...                     --
 --   3.Looks for rule in PAY_LEGISLATION_RULES which determines whether    --
 --   the pay offset date must be negative or whether it can be negative    --
 --   or positive.
 -- Arguments                                                               --
 --   p_regular_payment_date                                                --
 --   p_default_dd_date       TRUE if update of the particular date is      --
 --   p_pay_advice_date       disallowed.                                   --
 --   p_cut_off_date                                                        --
 --   p_pay_date_offset_rule
 --   p_payslip_view_date   by rajeesha bug 4246280
 -- Notes                                                                   --
 --   The existence of a row in PAY_LEGISLATION_RULES with a RULE_TYPE as   --
 --   shown below means that the date is disabled ie. cannot be updated.    --
 --   RULE_TYPE           DATE                                              --
 --   P                   REGULAR_PAYMENT_DATE                              --
 --   C                   CUT_OFF_DATE                                      --
 --   D                   DEFAULT_DD_DATE                                   --
 --   A                   PAY_ADVICE_DATE                                   --
 --   With a rule type of PDO the value N signifies only negative values    --
 --   are allowed , NP signifies Negative and Positive values are allowed   --
 --   If the rule is missing then the value NP is assumed.        --
 -----------------------------------------------------------------------------
--
 procedure get_bg_and_leg_info
 (
  p_business_group_id    number,
  p_legislation_code     varchar2,
  p_cost_id_flex_num     out nocopy varchar2,
  p_scl_id_flex_num      out nocopy varchar2,
  p_regular_payment_date out nocopy boolean,
  p_default_dd_date      out nocopy boolean,
  p_pay_advice_date      out nocopy boolean,
  p_cut_off_date         out nocopy boolean,
  p_pay_date_offset_rule out nocopy varchar2,
  p_scl_enabled          out nocopy boolean,
  p_payslip_view_date    out nocopy boolean
 ) is
--
   cursor csr_cost_id_flex_num is
     select bg.cost_allocation_structure
     from   per_business_groups bg
     where  bg.business_group_id + 0 = p_business_group_id;
--
   cursor csr_leg_rules is
     select lr.rule_type,
      lr.rule_mode
     from   pay_legislation_rules lr
     where  lr.legislation_code = p_legislation_code;
--
   cursor csr_leg_rules2 is
     select lr.rule_type,
      lr.rule_mode
     from   pay_legislative_field_info lr
     where  lr.legislation_code = p_legislation_code
     and    lr.field_name = 'PAYSLIP_VIEW_DATE'
     and    lr.rule_type  = 'UPDATE';
--
   v_regular_payment_date boolean      := false;
   v_default_dd_date      boolean      := false;
   v_pay_advice_date      boolean      := false;
   v_cut_off_date         boolean      := false;
   v_scl_enabled          boolean      := false;
   v_pay_date_offset_rule varchar2(60) := 'NP' ;
   v_payslip_view_date    boolean      := false;
--
 begin
--
   -- Retrieve the costing structure identifier for the business group.
   open csr_cost_id_flex_num;
   fetch csr_cost_id_flex_num into p_cost_id_flex_num;
   close csr_cost_id_flex_num;
--
   -- Retrieve all legislation rules for the legislation.
   for v_leg_rule in csr_leg_rules loop
--
     --
     -- The dates that can be updated for the legislation.
     --
     if v_leg_rule.rule_type = 'A' then
       v_pay_advice_date := true;
     elsif v_leg_rule.rule_type = 'D' then
       v_default_dd_date := true;
     elsif v_leg_rule.rule_type = 'C' then
       v_cut_off_date    := true;
     elsif v_leg_rule.rule_type = 'P' then
       v_regular_payment_date := true;
--
     --
     -- The SCL structure for the legislation
     --
     elsif v_leg_rule.rule_type = 'S' then
       p_scl_id_flex_num := v_leg_rule.rule_mode;
--
     --
     -- The rule for maintaining the pay date offset.
     --
     elsif v_leg_rule.rule_type = 'PDO' then
       v_pay_date_offset_rule := v_leg_rule.rule_mode;
--
     --
     -- Is the SCL enabled to appear at the payroll level for the legislation.
     --
     elsif v_leg_rule.rule_type = 'SDL' and v_leg_rule.rule_mode = 'P' then
       v_scl_enabled     := true;
     end if;
--
   end loop;
--
   for v_leg_rule in csr_leg_rules2 loop
      if v_leg_rule.rule_mode = 'Y' then
        v_payslip_view_date := true ;
      end if;
   end loop;

   p_regular_payment_date := v_regular_payment_date;
   p_default_dd_date      := v_default_dd_date;
   p_pay_advice_date      := v_pay_advice_date;
   p_cut_off_date         := v_cut_off_date;
   p_pay_date_offset_rule := v_pay_date_offset_rule;
   p_scl_enabled          := v_scl_enabled;
   p_payslip_view_date    := v_payslip_view_date;
--
 end get_bg_and_leg_info;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   validate_dflt_payment_method                                          --
 -- Purpose                                                                 --
 --   Makes sure that the default payment method exists for the life of     --
 --   the payroll record that uses it.                                      --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None                                                                 --
 -----------------------------------------------------------------------------
--
 procedure validate_dflt_payment_method
 (
  p_default_payment_method_id number,
  p_validation_start_date     date,
  p_validation_end_date       date
 ) is
--
   cursor csr_opm_dates is
     select opm.effective_start_date,
      opm.effective_end_date
     from   pay_org_payment_methods_f opm
     where  opm.org_payment_method_id = p_default_payment_method_id
     order by opm.effective_start_date
     for update;
--
   v_opm_rec csr_opm_dates%rowtype;
   v_start_date date;
   v_end_date   date;
--
 begin
--
   open csr_opm_dates;
   fetch csr_opm_dates into v_opm_rec;
   if csr_opm_dates%notfound then
     close csr_opm_dates;
     hr_utility.set_message(801, 'ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
          'validate_dflt_payment_method');
     hr_utility.set_message_token('STEP', 1);
     hr_utility.raise_error;
   else
     v_start_date := v_opm_rec.effective_start_date;
     v_end_date   := v_opm_rec.effective_end_date;
   end if;
--
   loop
     fetch csr_opm_dates into v_opm_rec;
     exit when csr_opm_dates%notfound;
     v_end_date := v_opm_rec.effective_end_date;
   end loop;
   close csr_opm_dates;
--
   if v_start_date > p_validation_start_date or
      v_end_date   < p_validation_end_date then
     hr_utility.set_message(801, 'HR_7096_PAYM_PYRLL_DFLT_INVID');
     hr_utility.raise_error;
   end if;
--
 end validate_dflt_payment_method;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   maintain_dflt_payment_method                                          --
 -- Purpose                                                                 --
 --   Creates OPMU's to represent the default payment method chosen for the --
 --   payroll.                                                              --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 procedure maintain_dflt_payment_method
 (
  p_payroll_id                number,
  p_default_payment_method_id number,
  p_validation_start_date     date,
  p_validation_end_date       date
 ) is
--
   cursor csr_payroll_opmu is
     select opmu.effective_start_date,
      opmu.effective_end_date
     from   pay_org_pay_method_usages_f opmu
     where  opmu.payroll_id = p_payroll_id
       and  opmu.org_payment_method_id = p_default_payment_method_id
       and  opmu.effective_start_date <= p_validation_end_date
       and  opmu.effective_end_date   >= p_validation_start_date
     order by opmu.effective_start_date
     for update;
--
   v_insert_record boolean := TRUE;
--
 begin
--
   -- The new opmu to be created is for the default payment method for the
   -- payroll and should exist for the duration of the default on the payroll
   -- record ie. valiadation_start_date to validation_end_date.
--
   -- Retrieve all opmu's for a payroll for the specified payment type that
   -- overlap with the period of change.
   for v_opmu_rec in csr_payroll_opmu loop
--
     -- An existing opmu already represents the default so do nothing.
     -- current opmu     |------------------------------------|
     -- required opmu       |----------------------------|
     if v_opmu_rec.effective_start_date <= p_validation_start_date and
  v_opmu_rec.effective_end_date   >= p_validation_end_date then
--
       v_insert_record := FALSE;
--
     -- opmu overlaps with start of required opmu so need to shorten it ie.
     -- current opmu     |--------|
     -- required opmu    .   |----------------------------|
     --                  .   .                            .
     -- adjust opmu      |--|.                            .
     -- insert new opmu      |----------------------------| (see below)
     elsif v_opmu_rec.effective_start_date < p_validation_start_date then
--
       update pay_org_pay_method_usages_f opmu
       set    opmu.effective_end_date = p_validation_start_date - 1
       where  current of csr_payroll_opmu;
--
     -- opmu overlaps with end of required opmu so need to shorten it ie.
     -- current opmu                                   |--------|
     -- required opmu        |----------------------------|     .
     --                      .                            .     .
     -- adjust opmu          .                            .|----|
     -- insert new opmu      |----------------------------| (see below)
     elsif v_opmu_rec.effective_end_date > p_validation_end_date then
--
       update pay_org_pay_method_usages_f opmu
       set    opmu.effective_start_date = p_validation_end_date + 1
       where  current of csr_payroll_opmu;
--
     -- opmu overlaps within required opmu so need to remove it ie.
     -- current opmu            |----)
     -- required opmu        |----------------------------|
     --                      .                            .
     -- remove opmu          .                            .
     -- insert new opmu      |----------------------------| (see below)
     else
--
       delete from pay_org_pay_method_usages_f
       where  current of csr_payroll_opmu;
--
     end if;

   end loop;
--
   if v_insert_record then
--
     -- Create opmu to represent the default payment method selected for the
     -- payroll.
     insert into pay_org_pay_method_usages_f
     (org_pay_method_usage_id,
      effective_start_date,
      effective_end_date,
      payroll_id,
      org_payment_method_id,
      last_update_date,
      last_updated_by,
      last_update_login,
      created_by,
      creation_date)
     values
     (pay_org_pay_method_usages_s.nextval,
      p_validation_start_date,
      p_validation_end_date,
      p_payroll_id,
      p_default_payment_method_id,
      trunc(sysdate),
      0,
      0,
      0,
      trunc(sysdate));
--
   end if;
--
 end maintain_dflt_payment_method;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   dflt_scl_from_bg                                                      --
 -- Purpose                                                                 --
 --   Retrieves the current values for the SCL that were set up for the     --
 --   business group. These are then used as defaults when creating a SCL   --
 --   for a payroll.                                                        --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 procedure dflt_scl_from_bg
 (
  p_business_group_id number,
  p_segment1          in out nocopy varchar2,
  p_segment2          in out nocopy varchar2,
  p_segment3          in out nocopy varchar2,
  p_segment4          in out nocopy varchar2,
  p_segment5          in out nocopy varchar2,
  p_segment6          in out nocopy varchar2,
  p_segment7          in out nocopy varchar2,
  p_segment8          in out nocopy varchar2,
  p_segment9          in out nocopy varchar2,
  p_segment10         in out nocopy varchar2,
  p_segment11         in out nocopy varchar2,
  p_segment12         in out nocopy varchar2,
  p_segment13         in out nocopy varchar2,
  p_segment14         in out nocopy varchar2,
  p_segment15         in out nocopy varchar2,
  p_segment16         in out nocopy varchar2,
  p_segment17         in out nocopy varchar2,
  p_segment18         in out nocopy varchar2,
  p_segment19         in out nocopy varchar2,
  p_segment20         in out nocopy varchar2,
  p_segment21         in out nocopy varchar2,
  p_segment22         in out nocopy varchar2,
  p_segment23         in out nocopy varchar2,
  p_segment24         in out nocopy varchar2,
  p_segment25         in out nocopy varchar2,
  p_segment26         in out nocopy varchar2,
  p_segment27         in out nocopy varchar2,
  p_segment28         in out nocopy varchar2,
  p_segment29         in out nocopy varchar2,
  p_segment30         in out nocopy varchar2
 ) is
--
   cursor csr_bg_scl_segs is
     select *
     from   hr_soft_coding_keyflex kf
     where  exists
        (select null
         from   hr_all_organization_units org
               where  org.organization_id = p_business_group_id
                 and  org.soft_coding_keyflex_id = kf.soft_coding_keyflex_id);
--
   v_scl_rec csr_bg_scl_segs%rowtype;
--
 begin
--
   -- Retrieve the SCL values set for the business group. This is then used to
   -- default the SCL when creating an SCL for a payroll.
   open csr_bg_scl_segs;
   fetch csr_bg_scl_segs into v_scl_rec;
   if csr_bg_scl_segs%found then
     p_segment1  := v_scl_rec.segment1;
     p_segment2  := v_scl_rec.segment2;
     p_segment3  := v_scl_rec.segment3;
     p_segment4  := v_scl_rec.segment4;
     p_segment5  := v_scl_rec.segment5;
     p_segment6  := v_scl_rec.segment6;
     p_segment7  := v_scl_rec.segment7;
     p_segment8  := v_scl_rec.segment8;
     p_segment9  := v_scl_rec.segment9;
     p_segment10 := v_scl_rec.segment10;
     p_segment11 := v_scl_rec.segment11;
     p_segment12 := v_scl_rec.segment12;
     p_segment13 := v_scl_rec.segment13;
     p_segment14 := v_scl_rec.segment14;
     p_segment15 := v_scl_rec.segment15;
     p_segment16 := v_scl_rec.segment16;
     p_segment17 := v_scl_rec.segment17;
     p_segment18 := v_scl_rec.segment18;
     p_segment19 := v_scl_rec.segment19;
     p_segment20 := v_scl_rec.segment20;
     p_segment21 := v_scl_rec.segment21;
     p_segment22 := v_scl_rec.segment22;
     p_segment23 := v_scl_rec.segment23;
     p_segment24 := v_scl_rec.segment24;
     p_segment25 := v_scl_rec.segment25;
     p_segment26 := v_scl_rec.segment26;
     p_segment27 := v_scl_rec.segment27;
     p_segment28 := v_scl_rec.segment28;
     p_segment29 := v_scl_rec.segment29;
     p_segment30 := v_scl_rec.segment30;
   end if;
   close csr_bg_scl_segs;
--
 end dflt_scl_from_bg;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   validate_insert_payroll                                               --
 -- Purpose                                                                 --
 --   Validates the creation of a payroll.                                  --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   1. Is the payroll name unique.                                        --
 --   2. If a default payment method is chosen does it exist for the        --
 --      lifetime of the payroll.                                           --
 -----------------------------------------------------------------------------
--
 procedure validate_insert_payroll
 (
  p_business_group_id         number,
  p_payroll_name              varchar2,
  p_default_payment_method_id number,
  p_validation_start_date     date,
  p_validation_end_date       date
 ) is
--
 begin

   -- Make sure payroll name is unique within the business group.
   chk_payroll_unique
     (null,
      p_payroll_name,
      p_business_group_id);

   -- Make sure default payment method is valid for the duration of the payroll.
   if p_default_payment_method_id is not null then
--
     validate_dflt_payment_method
       (p_default_payment_method_id,
        p_validation_start_date,
        p_validation_end_date);
--
   end if;
--
 end validate_insert_payroll;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   insert_payroll                                                        --
 -- Purpose                                                                 --
 --   Mainatins payroll related tables on creation of a payroll.            --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   1. Create time periods for payroll.                                   --
 --   2. Create OPMU for default payment method if it is specified.         --
 -----------------------------------------------------------------------------
--
 procedure insert_payroll
 (
  p_payroll_id                number,
  p_default_payment_method_id number,
  p_validation_start_date     date,
  p_validation_end_date       date
 ) is
--
 begin

   -- Create payroll time periods based on the payroll definition.
   hr_payrolls.create_payroll_proc_periods
     (p_payroll_id,
      null,  -- last_update_date
      null,  -- last_updated_by
      null,  -- last_update_login
      null,  -- created_by
      null); -- creation_date

   -- create opmu for default payment method if it has benn specified.
   if p_default_payment_method_id is not null then
--
     maintain_dflt_payment_method
       (p_payroll_id,
        p_default_payment_method_id,
        p_validation_start_date,
        p_validation_end_date);
--
   end if;
--
 end insert_payroll;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   validate_update_payroll                                               --
 -- Purpose                                                                 --
 --   Validates the updating of a payroll.                                  --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   1. Is the payroll name unique.                                        --
 --   2. If the default payment method has chnaged make sure it exists for  --
 --      the lifetime of the payroll.                                       --
 -----------------------------------------------------------------------------
--
 procedure validate_update_payroll
 (
  p_business_group_id           number,
  p_payroll_id                  number,
  p_payroll_name                varchar2,
  p_s_payroll_name              varchar2,
  p_default_payment_method_id   number,
  p_s_default_payment_method_id number,
  p_validation_start_date       date,
  p_validation_end_date         date
 ) is
--
 begin
--
   -- Make sure payroll name is unique within the business group.
   if p_payroll_name <> p_s_payroll_name then
--
     chk_payroll_unique
       (p_payroll_id,
        p_payroll_name,
        p_business_group_id);
--
   end if;
--
   -- Make sure default payment method is valid for the duration of the payroll.
   if p_default_payment_method_id <> nvl(p_s_default_payment_method_id,
           0) and
      p_default_payment_method_id is not null then
--
     validate_dflt_payment_method
       (p_default_payment_method_id,
        p_validation_start_date,
        p_validation_end_date);
--
   end if;
--
 end validate_update_payroll;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   update_payroll                                                        --
 -- Purpose                                                                 --
 --   Maintains payroll related tables on update of a payroll.              --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   1. If payroll name has changed then copy it to all payroll rows.      --
 --   2. If the number of years has changed then copy it to all payroll     --
 --      rows.                                                              --
 --   3. If the number of years has been increased then create more time    --
 --      periods for the payroll.                                           --
 --   4. If the default payment method has chnaged then create an OPMU.     --
 -----------------------------------------------------------------------------
--
 procedure update_payroll
 (
  p_business_group_id           number,
  p_payroll_id                  number,
  p_payroll_name                varchar2,
  p_s_payroll_name              varchar2,
  p_default_payment_method_id   number,
  p_s_default_payment_method_id number,
  p_number_of_years             number,
  p_s_number_of_years           number,
  p_validation_start_date       date,
  p_validation_end_date         date
 ) is
--
 begin
--
   -- Copy new payroll_name to all rows for the payroll ie,. this should not be
   -- datetracked.
   if p_payroll_name <> p_s_payroll_name then
--
     propagate_changes
       (p_payroll_id,
        p_payroll_name,
        null); -- number of years
--
    end if;
--
   -- Extend the number of payroll time periods if the number of years has been
   -- increased.
   if p_number_of_years > p_s_number_of_years then
--
     -- copy new number_of_years to all rows for the payroll ie,. this should
     -- not be datetracked.
     propagate_changes
       (p_payroll_id,
        null, -- payroll name
        p_number_of_years);
--
     hr_payrolls.create_payroll_proc_periods
       (p_payroll_id,
        null,  -- last_update_date
        null,  -- last_updated_by
        null,  -- last_update_login
        null,  -- created_by
        null); -- creation_date
--
   end if;
--
   -- If default payment method for the payroll has changed then create
   -- opmu to represent it.
   if p_default_payment_method_id <> nvl(p_s_default_payment_method_id,
           0) and
      p_default_payment_method_id is not null then
--
     maintain_dflt_payment_method
       (p_payroll_id,
        p_default_payment_method_id,
        p_validation_start_date,
        p_validation_end_date);
--
   end if;
--
 end update_payroll;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   validate_delete_payroll                                               --
 -- Purpose                                                                 --
 --   Validates the deletion of a payroll.                                  --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   1. Checks per_all_assignments_f, pay_element_links_f,                 --
 --     pay_exchange_rates_f,pay_payroll_actions, hr_assignment_sets,       --
 --     pay_payroll_list, pay_security_payrolls, pay_message_lines.         --
 --   2. If the payroll record is being opened up then make sure that the   --
 --     default payment method on the last row is valid for the new lifetime  --
 --     of the payroll.t method on the last row is valid for the new lifetime --
 -----------------------------------------------------------------------------
--
 procedure validate_delete_payroll
 (
  p_payroll_id                number,
  p_default_payment_method_id number,
  p_dt_delete_mode            varchar2,
  p_validation_start_date     date,
  p_validation_end_date       date
 ) is
--
   cursor csr_chk_assignment is
     select 'found'
     from   per_all_assignments_f asg
     where  asg.payroll_id = p_payroll_id
       and  asg.effective_start_date <= p_validation_end_date
       and  asg.effective_end_date   >= p_validation_start_date;
--
   cursor csr_chk_element_link is
     select 'found'
     from   pay_element_links_f el
     where  el.payroll_id = p_payroll_id
       and  el.effective_start_date <= p_validation_end_date
       and  el.effective_end_date   >= p_validation_start_date;

   cursor csr_chk_position is
     select 'found'
     from   hr_all_positions_f po
     where  po.pay_freq_payroll_id = p_payroll_id
       and  po.effective_start_date <= p_validation_end_date
       and  po.effective_end_date   >= p_validation_start_date;

--
--  commented out as pay_exchange rates is no longer supported
--  it had been replaced by gl daily_rates
--
--   cursor csr_chk_exchange_rate is
--     select  'found'
--     from    pay_exchange_rates_f exr
--     where   exr.payroll_id = p_payroll_id
--       and   exr.effective_start_date <= p_validation_end_date
--       and   exr.effective_end_date   >= p_validation_start_date;
--
   cursor csr_chk_payroll_action is
     select 'found'
     from   pay_payroll_actions ppa
     where  ppa.payroll_id = p_payroll_id;
--
   cursor csr_chk_assignment_set is
     select 'found'
     from   hr_assignment_sets a
     where  a.payroll_id = p_payroll_id;
--
   cursor csr_chk_security_payroll is
     select 'found'
     from   pay_security_payrolls psp
     where  psp.payroll_id = p_payroll_id;
--
   cursor csr_chk_message_line is
     select 'found'
     from   pay_message_lines pml
     where  pml.payroll_id = p_payroll_id;
--
   v_result                 varchar2(5);
   v_text                   varchar2(2000);
   NO_OTL_PACKAGE_FUNCTION  exception;
--
   pragma exception_init(NO_OTL_PACKAGE_FUNCTION,-6550);
--
 begin
--
   -- If default payment method is being extended then make sure that the opm
   -- exists for the duration of the default.
   if p_dt_delete_mode = 'DELETE_NEXT_CHANGE' and
      p_default_payment_method_id is not null then
--
      validate_dflt_payment_method
        (p_default_payment_method_id,
         p_validation_start_date,
         p_validation_end_date);
--
   end if;
--
   -- Do validation checks on date effective children of payroll.
   if p_dt_delete_mode in ('ZAP','DELETE') then
--
     open csr_chk_assignment;
     fetch csr_chk_assignment into v_result;
     if csr_chk_assignment%found then
       close csr_chk_assignment;
       hr_utility.set_message(801, 'HR_6674_PAY_ASSIGN');
       hr_utility.raise_error;
     else
       close csr_chk_assignment;
     end if;
--
     open csr_chk_element_link;
     fetch csr_chk_element_link into v_result;
     if csr_chk_element_link%found then
       close csr_chk_element_link;
       hr_utility.set_message(801, 'HR_6675_PAY_ELE');
       hr_utility.raise_error;
     else
       close csr_chk_element_link;
     end if;

     open csr_chk_position;
     fetch csr_chk_position into v_result;
     if csr_chk_position%found then
       close csr_chk_position;
       hr_utility.set_message(800, 'HR_DEL_PAYROLL_POSITION_EXISTS');
       hr_utility.raise_error;
     else
       close csr_chk_position;
     end if;

   end if;
--
   -- Do validation checks on non date effective children of payroll.
   if p_dt_delete_mode = 'ZAP' then
--
     open csr_chk_payroll_action;
     fetch csr_chk_payroll_action into v_result;
     if csr_chk_payroll_action%found then
       close csr_chk_payroll_action;
       hr_utility.set_message(801, 'HR_6488_PAY_DEL_ACTIONS');
       hr_utility.raise_error;
     else
       close csr_chk_payroll_action;
     end if;
--
     open csr_chk_assignment_set;
     fetch csr_chk_assignment_set into v_result;
     if csr_chk_assignment_set%found then
       close csr_chk_assignment_set;
       hr_utility.set_message(801, 'HR_6489_PAY_DEL_ASS');
       hr_utility.raise_error;
     else
       close csr_chk_assignment_set;
     end if;
--
     open csr_chk_security_payroll;
     fetch csr_chk_security_payroll into v_result;
     if csr_chk_security_payroll%found then
       close csr_chk_security_payroll;
       hr_utility.set_message(801, 'HR_6491_PAY_DEL_SEC_PAY');
       hr_utility.raise_error;
     else
       close csr_chk_security_payroll;
     end if;
--
     open csr_chk_message_line;
     fetch csr_chk_message_line into v_result;
     if csr_chk_message_line%found then
       close csr_chk_message_line;
       hr_utility.set_message(801, 'HR_6731_PAY_DEL_MESS');
       hr_utility.raise_error;
     else
       close csr_chk_message_line;
     end if;
--
     begin
  v_text :=  'declare l_payroll_used boolean;
                    begin
                         l_payroll_used := hxc_resource_rules_utils.chk_criteria_exists
                                             (''PAYROLL'',:p_eligibility_criteria_id);
               if l_payroll_used then
                        hr_utility.set_message(801, ''PAY_33198_PAYROLL_USED_IN_OTL'');
                    hr_utility.raise_error;
                 end if;
        end;' ;

  execute immediate v_text using p_payroll_id ;
     exception
          when NO_OTL_PACKAGE_FUNCTION then
               null;
     end;
--
   end if;
--
 end validate_delete_payroll;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   delete_payroll                                                        --
 -- Purpose                                                                 --
 --   Maintains payroll related tables on deletion of a payroll.            --
 -- Arguments                                                               --
 --   See Below.                                                            --
 -- Notes                                                                   --
 --   None                                                                  --
 -----------------------------------------------------------------------------
--
 procedure delete_payroll
 (
  p_payroll_id                number,
  p_default_payment_method_id number,
  p_dt_delete_mode            varchar2,
  p_validation_start_date     date,
  p_validation_end_date       date
 ) is
--
   cursor csr_comment_rows_zap is
     select com.comment_id
     from   pay_payrolls_f prl,
            hr_comments com
     where  prl.payroll_id = p_payroll_id
       and  com.comment_id = prl.comment_id
     for update of com.comment_id;
--
   cursor csr_comment_rows_delete is
     select com.comment_id
     from   pay_payrolls_f prl,
            hr_comments com
     where  prl.payroll_id = p_payroll_id
       and  prl.effective_start_date >= p_validation_start_date
       and  com.comment_id = prl.comment_id
       and  not exists
              (select null
               from   pay_payrolls_f prl2
               where  prl2.payroll_id = prl.payroll_id
                 and  prl2.effective_start_date < p_validation_start_date
                 and  prl2.comment_id = prl.comment_id)
     for update of com.comment_id;

   cursor csr_period_end_date is
     select max(tpe.end_date), min(tpe.start_date)
     from   per_time_periods tpe
     where  tpe.payroll_id = p_payroll_id;
--
l_last_period_end_date date;
l_first_period_start_date date;
--
 begin
--
   if p_dt_delete_mode = 'ZAP' then
--
     delete from per_time_periods tpe
     where  tpe.payroll_id = p_payroll_id;
--
     delete from pay_org_pay_method_usages_f opu
     where  opu.payroll_id = p_payroll_id;
--
     delete from pay_payroll_gl_flex_maps gfm
     where  gfm.payroll_id = p_payroll_id;
--
     for v_com_rec in csr_comment_rows_zap loop
       delete from hr_comments
       where  current of csr_comment_rows_zap;
     end loop;
     --
     -- Payroll Lists are created by default for all the security profiles
     -- within the business group when a payroll is created. Hence we can
     -- safely purge them.
     --
     hr_security.delete_payroll_from_list(p_payroll_id);
--
   elsif p_dt_delete_mode = 'DELETE_NEXT_CHANGE' then

     -- If default payment method is being extended then make sure that the
     -- opmu is extended to represent the default payment method.
     if p_default_payment_method_id is not null then
--
        maintain_dflt_payment_method
          (p_payroll_id,
           p_default_payment_method_id,
           p_validation_start_date,
           p_validation_end_date);
--
      end if;
--
     -- Record is being opened up so need to recreate any time periods that
     -- were removed when the payroll was shut down.
     if p_validation_end_date = c_end_of_time then
--
       -- Create payroll time periods based on the payroll definition.
       hr_payrolls.create_payroll_proc_periods
         (p_payroll_id,
          null,  -- last_update_date
          null,  -- last_updated_by
          null,  -- last_update_login
          null,  -- created_by
          null); -- creation_date
--
     end if;
--
   elsif p_dt_delete_mode = 'DELETE' then
--
     -- All opmu's for a payroll must exist within the lifetime of the payroll
     -- so any opmus that exist outisde the new dates will be removed /
     -- shortened.
     delete from pay_org_pay_method_usages_f opu
     where  opu.payroll_id = p_payroll_id
       and  opu.effective_start_date >= p_validation_start_date;
--
     update pay_org_pay_method_usages_f opu
     set    opu.effective_end_date = p_validation_start_date - 1
     where  opu.payroll_id = p_payroll_id
       and  opu.effective_end_date >= p_validation_start_date;
--
     -- Only time periods that fit completely within the lifetime of the
     -- payroll are valid.
     delete from per_time_periods tpe
     where  tpe.payroll_id = p_payroll_id
       and  tpe.end_date >= p_validation_start_date;

     Open csr_period_end_date;
     Fetch csr_period_end_date into l_last_period_end_date,
                                    l_first_period_start_date;
     Close csr_period_end_date;
     --
     -- The number of years should be updated to the span of the payroll
     -- period.
     --
     if l_last_period_end_date is not null and
        l_first_period_start_date is not null
     then
       update pay_payrolls_f
       set    number_of_years =
              round(months_between(l_last_period_end_date,l_first_period_start_date))/12
       where  payroll_id = p_payroll_id;
     end if;
--
     -- Remove any comments that only exist after the date on which the payroll
     -- is being closed down.
     for v_com_rec in csr_comment_rows_delete loop
       delete from hr_comments
       where  current of csr_comment_rows_delete;
     end loop;
--
   end if;
--
 end delete_payroll;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Additions                                                               --
 --   Added X_payslip_view_date_offset By Rajeesha Bug 4246280              --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN out nocopy VARCHAR2,
                      X_Payroll_Id                   IN out nocopy NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Default_Payment_Method_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Consolidation_Set_Id                NUMBER,
                      X_Cost_Allocation_Keyflex_Id          NUMBER,
                      X_Suspense_Account_Keyflex_Id         NUMBER,
                      X_Gl_Set_Of_Books_Id                  NUMBER,
                      X_Soft_Coding_Keyflex_Id              NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Organization_Id                     NUMBER,
                      X_Cut_Off_Date_Offset                 NUMBER,
                      X_Direct_Deposit_Date_Offset          NUMBER,
                      X_First_Period_End_Date               DATE,
                      X_Negative_Pay_Allowed_Flag           VARCHAR2,
                      X_Number_Of_Years                     NUMBER,
                      X_Pay_Advice_Date_Offset              NUMBER,
                      X_Pay_Date_Offset                     NUMBER,
                      X_Payroll_Name                        VARCHAR2,
                      X_Workload_Shifting_Level             VARCHAR2,
                      X_Comment_Id                          NUMBER,
                      X_Attribute_Category                  VARCHAR2,
                      X_Attribute1                          VARCHAR2,
                      X_Attribute2                          VARCHAR2,
                      X_Attribute3                          VARCHAR2,
                      X_Attribute4                          VARCHAR2,
                      X_Attribute5                          VARCHAR2,
                      X_Attribute6                          VARCHAR2,
                      X_Attribute7                          VARCHAR2,
                      X_Attribute8                          VARCHAR2,
                      X_Attribute9                          VARCHAR2,
                      X_Attribute10                         VARCHAR2,
                      X_Attribute11                         VARCHAR2,
                      X_Attribute12                         VARCHAR2,
                      X_Attribute13                         VARCHAR2,
                      X_Attribute14                         VARCHAR2,
                      X_Attribute15                         VARCHAR2,
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      -- Payroll Developer DF
                      X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                      X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information30                VARCHAR2 DEFAULT NULL,
          -- Extra Columns
          X_Validation_Start_date            DATE,
          X_Validation_End_date              DATE,
                      X_Arrears_Flag                     VARCHAR2,
                      X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
          X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
          X_payslip_view_date_offset         NUMBER DEFAULT NULL
        ) IS
--
    CURSOR C IS SELECT rowid FROM PAY_ALL_PAYROLLS_F
                WHERE  payroll_id = X_Payroll_Id;
--
    CURSOR C2 IS SELECT pay_payrolls_s.nextval FROM sys.dual;
--
    l_midpoint_offset number := 0 ;
--
 BEGIN
--
   pay_payrolls_f_pkg.validate_insert_payroll
     (x_business_group_id,
      x_payroll_name,
      x_default_payment_method_id,
      x_validation_start_date,
      x_validation_end_date);
--
   if (X_Payroll_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Payroll_Id;
     CLOSE C2;
   end if;
--
   if ( X_period_type = 'Semi-Month' ) then
      l_midpoint_offset := -15 ;
   else
      l_midpoint_offset := 0 ;
   end if ;
--
   INSERT INTO PAY_PAYROLLS_F
   (payroll_id,
    effective_start_date,
    effective_end_date,
    default_payment_method_id,
    business_group_id,
    consolidation_set_id,
    cost_allocation_keyflex_id,
    suspense_account_keyflex_id,
    gl_set_of_books_id,
    soft_coding_keyflex_id,
    period_type,
    organization_id,
    cut_off_date_offset,
    direct_deposit_date_offset,
    first_period_end_date,
    midpoint_offset,
    negative_pay_allowed_flag,
    number_of_years,
    pay_advice_date_offset,
    pay_date_offset,
    payroll_name,
    workload_shifting_level,
    comment_id,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    prl_information_category,
    prl_information1,
    prl_information2,
    prl_information3,
    prl_information4,
    prl_information5,
    prl_information6,
    prl_information7,
    prl_information8,
    prl_information9,
    prl_information10,
    prl_information11,
    prl_information12,
    prl_information13,
    prl_information14,
    prl_information15,
    prl_information16,
    prl_information17,
    prl_information18,
    prl_information19,
    prl_information20,
    prl_information21,
    prl_information22,
    prl_information23,
    prl_information24,
    prl_information25,
    prl_information26,
    prl_information27,
    prl_information28,
    prl_information29,
    prl_information30,
    arrears_flag,
    multi_assignments_flag,
    period_reset_years,
    payslip_view_date_offset)
   VALUES
   (X_Payroll_Id,
    X_Effective_Start_Date,
    X_Effective_End_Date,
    X_Default_Payment_Method_Id,
    X_Business_Group_Id,
    X_Consolidation_Set_Id,
    X_Cost_Allocation_Keyflex_Id,
    X_Suspense_Account_Keyflex_Id,
    X_Gl_Set_Of_Books_Id,
    X_Soft_Coding_Keyflex_Id,
    X_Period_Type,
    X_Organization_Id,
    X_Cut_Off_Date_Offset,
    X_Direct_Deposit_Date_Offset,
    X_First_Period_End_Date,
    l_midpoint_offset,
    X_Negative_Pay_Allowed_Flag,
    X_Number_Of_Years,
    X_Pay_Advice_Date_Offset,
    X_Pay_Date_Offset,
    X_Payroll_Name,
    X_Workload_Shifting_Level,
    X_Comment_Id,
    X_Attribute_Category,
    X_Attribute1,
    X_Attribute2,
    X_Attribute3,
    X_Attribute4,
    X_Attribute5,
    X_Attribute6,
    X_Attribute7,
    X_Attribute8,
    X_Attribute9,
    X_Attribute10,
    X_Attribute11,
    X_Attribute12,
    X_Attribute13,
    X_Attribute14,
    X_Attribute15,
    X_Attribute16,
    X_Attribute17,
    X_Attribute18,
    X_Attribute19,
    X_Attribute20,
    X_Prl_Information_Category,
    X_Prl_Information1,
    X_Prl_Information2,
    X_Prl_Information3,
    X_Prl_Information4,
    X_Prl_Information5,
    X_Prl_Information6,
    X_Prl_Information7,
    X_Prl_Information8,
    X_Prl_Information9,
    X_Prl_Information10,
    X_Prl_Information11,
    X_Prl_Information12,
    X_Prl_Information13,
    X_Prl_Information14,
    X_Prl_Information15,
    X_Prl_Information16,
    X_Prl_Information17,
    X_Prl_Information18,
    X_Prl_Information19,
    X_Prl_Information20,
    X_Prl_Information21,
    X_Prl_Information22,
    X_Prl_Information23,
    X_Prl_Information24,
    X_Prl_Information25,
    X_Prl_Information26,
    X_Prl_Information27,
    X_Prl_Information28,
    X_Prl_Information29,
    X_Prl_Information30,
    X_Arrears_Flag,
    X_Multi_Assignments_Flag,
    X_Period_Reset_Years,
    X_payslip_view_date_offset);
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_payrolls_f_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
-- Code added as part of bug fix 2593982
-- Code to view the payrolls which were initially not visible in secured
-- responsibility

   hr_security_internal.populate_new_payroll
   (X_Business_Group_Id
   ,X_Payroll_Id
   );
--
-- Bug 3596436
-- Add newly created payroll to the cache so that it is available
-- for the rest of session
--
   hr_security.add_payroll(x_payroll_id);
--
   pay_payrolls_f_pkg.insert_payroll
     (x_payroll_id,
      x_default_payment_method_id,
      x_validation_start_date,
      x_validation_end_date);
--
 END Insert_Row;
--
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Additions                                                               --
 --   Added X_payslip_view_date_offset By Rajeesha Bug 4246280              --
 -- Added the Overloaded procedure to call the API 5144323                  --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN out nocopy VARCHAR2,
                      X_Payroll_Id                   IN out nocopy NUMBER,
                      X_Default_Payment_Method_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Consolidation_Set_Id                NUMBER,
                      X_Cost_Allocation_Keyflex_Id          NUMBER,
                      X_Suspense_Account_Keyflex_Id         NUMBER,
                      X_Gl_Set_Of_Books_Id                  NUMBER,
                      X_Soft_Coding_Keyflex_Id              NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Organization_Id                     NUMBER,
                      X_Cut_Off_Date_Offset                 NUMBER,
                      X_Direct_Deposit_Date_Offset          NUMBER,
                      X_First_Period_End_Date               DATE,
                      X_Negative_Pay_Allowed_Flag           VARCHAR2,
                      X_Number_Of_Years                     NUMBER,
                      X_Pay_Advice_Date_Offset              NUMBER,
                      X_Pay_Date_Offset                     NUMBER,
                      X_Payroll_Name                        VARCHAR2,
                      X_Workload_Shifting_Level             VARCHAR2,
                      X_Attribute_Category                  VARCHAR2,
                      X_Attribute1                          VARCHAR2,
                      X_Attribute2                          VARCHAR2,
                      X_Attribute3                          VARCHAR2,
                      X_Attribute4                          VARCHAR2,
                      X_Attribute5                          VARCHAR2,
                      X_Attribute6                          VARCHAR2,
                      X_Attribute7                          VARCHAR2,
                      X_Attribute8                          VARCHAR2,
                      X_Attribute9                          VARCHAR2,
                      X_Attribute10                         VARCHAR2,
                      X_Attribute11                         VARCHAR2,
                      X_Attribute12                         VARCHAR2,
                      X_Attribute13                         VARCHAR2,
                      X_Attribute14                         VARCHAR2,
                      X_Attribute15                         VARCHAR2,
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      -- Payroll Developer DF
                      X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                      X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information30                VARCHAR2 DEFAULT NULL,
          -- Extra Columns
                      X_Validation_Start_date            DATE,
                      X_Validation_End_date              DATE,
                      X_Arrears_Flag                     VARCHAR2,
                      X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
                      X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
                      X_payslip_view_date_offset         NUMBER DEFAULT NULL
--bug 5609830 / 5144323 TEST starts
                     ,X_Effective_Date                   DATE --new
                     ,X_payroll_type                     VARCHAR2 DEFAULT NULL --new
                     ,X_comments                         VARCHAR2 DEFAULT NULL --new
                     ,X_Effective_Start_Date         OUT nocopy DATE --out type added
                     ,X_Effective_End_Date           OUT nocopy DATE --out type added
                     ,X_Comment_Id                   OUT nocopy NUMBER --out type added
--bug 5609830 / 5144323 TEST ends
        ) IS
--
    CURSOR C IS SELECT rowid, comment_id FROM PAY_ALL_PAYROLLS_F
                WHERE  payroll_id = X_Payroll_Id;
--
   l_midpoint_offset number := 0 ;
--
   l_payroll_id                    number;
   l_org_pay_method_usage_id       number;
   l_prl_object_version_number     number;
   l_opm_object_version_number     number;
   l_opm_effective_start_date      date;
   l_opm_effective_end_date        date;

   l_cost_allocation_keyflex_id    PAY_ALL_PAYROLLS_F.COST_ALLOCATION_KEYFLEX_ID%TYPE ;
   l_suspense_account_keyflex_id   PAY_ALL_PAYROLLS_F.SUSPENSE_ACCOUNT_KEYFLEX_ID%TYPE ;
   l_soft_coding_keyflex_id        PAY_ALL_PAYROLLS_F.SOFT_CODING_KEYFLEX_ID%TYPE ;

   l_cost_concat_segments          PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_susp_concat_segments          PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_scl_concat_segments           HR_SOFT_CODING_KEYFLEX.concatenated_segments%TYPE;
--
 BEGIN
--
   pay_payrolls_f_pkg.validate_insert_payroll
     (x_business_group_id,
      x_payroll_name,
      x_default_payment_method_id,
      x_validation_start_date,
      x_validation_end_date);

   if ( X_period_type = 'Semi-Month' ) then
      l_midpoint_offset := -15 ;
   else
      l_midpoint_offset := 0 ;
   end if ;
--

  pay_payroll_api.create_payroll(
    p_validate                   => FALSE
   ,p_effective_date             => X_Effective_Date
   ,p_payroll_name               => X_Payroll_Name
   ,p_consolidation_set_id       => X_Consolidation_Set_Id
   ,p_period_type                => X_Period_Type
   ,p_first_period_end_date      => X_First_Period_End_Date
   ,p_number_of_years            => X_Number_Of_Years
   ,p_payroll_type               => X_payroll_type
   ,p_pay_date_offset            => X_Pay_Date_Offset
   ,p_direct_deposit_date_offset => X_Direct_Deposit_Date_Offset
   ,p_pay_advice_date_offset     => X_Pay_Advice_Date_Offset
   ,p_cut_off_date_offset        => X_Cut_Off_Date_Offset
   ,p_midpoint_offset            => l_midpoint_offset
   ,p_default_payment_method_id  => X_Default_Payment_Method_Id
   ,p_cost_alloc_keyflex_id_in   => X_Cost_Allocation_Keyflex_Id
   ,p_susp_account_keyflex_id_in => X_Suspense_Account_Keyflex_Id
   ,p_negative_pay_allowed_flag  => X_Negative_Pay_Allowed_Flag
   ,p_gl_set_of_books_id         => X_Gl_Set_Of_Books_Id
   ,p_soft_coding_keyflex_id_in  => X_Soft_Coding_Keyflex_Id
   ,p_comments                   => X_comments
   ,p_attribute_category         => X_Attribute_Category
   ,p_attribute1      => X_attribute1
   ,p_attribute2      => X_attribute2
   ,p_attribute3      => X_attribute3
   ,p_attribute4      => X_attribute4
   ,p_attribute5      => X_attribute5
   ,p_attribute6      => X_attribute6
   ,p_attribute7      => X_attribute7
   ,p_attribute8      => X_attribute8
   ,p_attribute9      => X_attribute9
   ,p_attribute10     => X_attribute10
   ,p_attribute11     => X_attribute11
   ,p_attribute12     => X_attribute12
   ,p_attribute13     => X_attribute13
   ,p_attribute14     => X_attribute14
   ,p_attribute15     => X_attribute15
   ,p_attribute16     => X_attribute16
   ,p_attribute17     => X_attribute17
   ,p_attribute18     => X_attribute18
   ,p_attribute19     => X_attribute19
   ,p_attribute20     => X_attribute20
   ,p_arrears_flag    => X_Arrears_Flag
   ,p_period_reset_years     => X_Period_Reset_Years
   ,p_multi_assignments_flag => X_Multi_Assignments_Flag
   ,p_organization_id       => X_Organization_Id
   ,p_prl_information1      => X_prl_information1
   ,p_prl_information2      => X_prl_information2
   ,p_prl_information3      => X_prl_information3
   ,p_prl_information4      => X_prl_information4
   ,p_prl_information5      => X_prl_information5
   ,p_prl_information6      => X_prl_information6
   ,p_prl_information7      => X_prl_information7
   ,p_prl_information8      => X_prl_information8
   ,p_prl_information9      => X_prl_information9
   ,p_prl_information10     => X_prl_information10
   ,p_prl_information11     => X_prl_information11
   ,p_prl_information12     => X_prl_information12
   ,p_prl_information13     => X_prl_information13
   ,p_prl_information14     => X_prl_information14
   ,p_prl_information15     => X_prl_information15
   ,p_prl_information16     => X_prl_information16
   ,p_prl_information17     => X_prl_information17
   ,p_prl_information18     => X_prl_information18
   ,p_prl_information19     => X_prl_information19
   ,p_prl_information20     => X_prl_information20
   ,p_prl_information21     => X_prl_information21
   ,p_prl_information22     => X_prl_information22
   ,p_prl_information23     => X_prl_information23
   ,p_prl_information24     => X_prl_information24
   ,p_prl_information25     => X_prl_information25
   ,p_prl_information26     => X_prl_information26
   ,p_prl_information27     => X_prl_information27
   ,p_prl_information28     => X_prl_information28
   ,p_prl_information29     => X_prl_information29
   ,p_prl_information30     => X_prl_information30
--
   ,p_workload_shifting_level     => X_Workload_Shifting_Level
   ,p_payslip_view_date_offset    => X_payslip_view_date_offset
--
   ,p_payroll_id                  => l_payroll_id
   ,p_org_pay_method_usage_id     => l_org_pay_method_usage_id

   ,p_prl_object_version_number   => l_prl_object_version_number
   ,p_opm_object_version_number   => l_opm_object_version_number

   ,p_prl_effective_start_date    => X_effective_start_date
   ,p_prl_effective_end_date      => X_effective_end_date
   ,p_opm_effective_start_date    => l_opm_effective_start_date
   ,p_opm_effective_end_date      => l_opm_effective_end_date
   ,p_comment_id                  => X_comment_id
--
   ,p_cost_alloc_keyflex_id_out   => l_cost_allocation_keyflex_id
   ,p_susp_account_keyflex_id_out => l_suspense_account_keyflex_id
   ,p_soft_coding_keyflex_id_out  => l_soft_coding_keyflex_id
   ,p_cost_concat_segments_out    => l_cost_concat_segments
   ,p_susp_concat_segments_out    => l_susp_concat_segments
   ,p_scl_concat_segments_out     => l_scl_concat_segments
--
   );

   X_payroll_id := l_payroll_id;
--
-- Comment_id not returned from create_payroll_api
   OPEN C;
   FETCH C INTO X_Rowid, X_comment_id;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_payrolls_f_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
-- Code added as part of bug fix 2593982
-- Code to view the payrolls which were initially not visible in secured
-- responsibility

   hr_security_internal.populate_new_payroll
   (X_Business_Group_Id
   ,X_Payroll_Id
   );
--
-- Bug 3596436
-- Add newly created payroll to the cache so that it is available
-- for the rest of session
--
   hr_security.add_payroll(x_payroll_id);
--
   pay_payrolls_f_pkg.insert_payroll
     (x_payroll_id,
      x_default_payment_method_id,
      x_validation_start_date,
      x_validation_end_date);
--
 END Insert_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a payroll in the Define Payroll    --
 --   form.                                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- Additions                                                               --
 --   Added X_payslip_view_date_offset By Rajeesha Bug 4246280              --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Payroll_Id                            NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Default_Payment_Method_Id             NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Consolidation_Set_Id                  NUMBER,
                    X_Cost_Allocation_Keyflex_Id            NUMBER,
                    X_Suspense_Account_Keyflex_Id           NUMBER,
                    X_Gl_Set_Of_Books_Id                    NUMBER,
                    X_Soft_Coding_Keyflex_Id                NUMBER,
                    X_Period_Type                           VARCHAR2,
                    X_Organization_Id                       NUMBER,
                    X_Cut_Off_Date_Offset                   NUMBER,
                    X_Direct_Deposit_Date_Offset            NUMBER,
                    X_First_Period_End_Date                 DATE,
                    X_Negative_Pay_Allowed_Flag             VARCHAR2,
                    X_Number_Of_Years                       NUMBER,
                    X_Pay_Advice_Date_Offset                NUMBER,
                    X_Pay_Date_Offset                       NUMBER,
                    X_Payroll_Name                          VARCHAR2,
                    X_Workload_Shifting_Level               VARCHAR2,
                    X_Comment_Id                            NUMBER,
                    X_Attribute_Category                    VARCHAR2,
                    X_Attribute1                            VARCHAR2,
                    X_Attribute2                            VARCHAR2,
                    X_Attribute3                            VARCHAR2,
                    X_Attribute4                            VARCHAR2,
                    X_Attribute5                            VARCHAR2,
                    X_Attribute6                            VARCHAR2,
                    X_Attribute7                            VARCHAR2,
                    X_Attribute8                            VARCHAR2,
                    X_Attribute9                            VARCHAR2,
                    X_Attribute10                           VARCHAR2,
                    X_Attribute11                           VARCHAR2,
                    X_Attribute12                           VARCHAR2,
                    X_Attribute13                           VARCHAR2,
                    X_Attribute14                           VARCHAR2,
                    X_Attribute15                           VARCHAR2,
                    X_Attribute16                           VARCHAR2,
                    X_Attribute17                           VARCHAR2,
                    X_Attribute18                           VARCHAR2,
                    X_Attribute19                           VARCHAR2,
                    X_Attribute20                           VARCHAR2,
                    -- Payroll Developer DF
                    X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                    X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                    X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                    X_Prl_Information30                VARCHAR2 DEFAULT NULL,
                    --
                    X_Arrears_Flag                     VARCHAR2,
                    X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
        X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
        X_payslip_view_date_offset         NUMBER DEFAULT NULL
      ) IS

--
   CURSOR C IS SELECT * FROM PAY_PAYROLLS_F
               WHERE  rowid = X_Rowid FOR UPDATE of Payroll_Id NOWAIT;
--
   Recinfo C%ROWTYPE;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_payrolls_f_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Remove trailing spaces.
   Recinfo.period_type := rtrim(Recinfo.period_type);
   Recinfo.negative_pay_allowed_flag :=
     rtrim(Recinfo.negative_pay_allowed_flag);
   Recinfo.payroll_name := rtrim(Recinfo.payroll_name);
   Recinfo.workload_shifting_level := rtrim(Recinfo.workload_shifting_level);
   Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
   Recinfo.attribute1 := rtrim(Recinfo.attribute1);
   Recinfo.attribute2 := rtrim(Recinfo.attribute2);
   Recinfo.attribute3 := rtrim(Recinfo.attribute3);
   Recinfo.attribute4 := rtrim(Recinfo.attribute4);
   Recinfo.attribute5 := rtrim(Recinfo.attribute5);
   Recinfo.attribute6 := rtrim(Recinfo.attribute6);
   Recinfo.attribute7 := rtrim(Recinfo.attribute7);
   Recinfo.attribute8 := rtrim(Recinfo.attribute8);
   Recinfo.attribute9 := rtrim(Recinfo.attribute9);
   Recinfo.attribute10 := rtrim(Recinfo.attribute10);
   Recinfo.attribute11 := rtrim(Recinfo.attribute11);
   Recinfo.attribute12 := rtrim(Recinfo.attribute12);
   Recinfo.attribute13 := rtrim(Recinfo.attribute13);
   Recinfo.attribute14 := rtrim(Recinfo.attribute14);
   Recinfo.attribute15 := rtrim(Recinfo.attribute15);
   Recinfo.attribute16 := rtrim(Recinfo.attribute16);
   Recinfo.attribute17 := rtrim(Recinfo.attribute17);
   Recinfo.attribute18 := rtrim(Recinfo.attribute18);
   Recinfo.attribute19 := rtrim(Recinfo.attribute19);
   Recinfo.attribute20 := rtrim(Recinfo.attribute20);
--
   Recinfo.prl_information_category := rtrim(Recinfo.prl_information_category);
   Recinfo.prl_information1 := rtrim(Recinfo.prl_information1);
   Recinfo.prl_information2 := rtrim(Recinfo.prl_information2);
   Recinfo.prl_information3 := rtrim(Recinfo.prl_information3);
   Recinfo.prl_information4 := rtrim(Recinfo.prl_information4);
   Recinfo.prl_information5 := rtrim(Recinfo.prl_information5);
   Recinfo.prl_information6 := rtrim(Recinfo.prl_information6);
   Recinfo.prl_information7 := rtrim(Recinfo.prl_information7);
   Recinfo.prl_information8 := rtrim(Recinfo.prl_information8);
   Recinfo.prl_information9 := rtrim(Recinfo.prl_information9);
   Recinfo.prl_information10 := rtrim(Recinfo.prl_information10);
   Recinfo.prl_information11 := rtrim(Recinfo.prl_information11);
   Recinfo.prl_information12 := rtrim(Recinfo.prl_information12);
   Recinfo.prl_information13 := rtrim(Recinfo.prl_information13);
   Recinfo.prl_information14 := rtrim(Recinfo.prl_information14);
   Recinfo.prl_information15 := rtrim(Recinfo.prl_information15);
   Recinfo.prl_information16 := rtrim(Recinfo.prl_information16);
   Recinfo.prl_information17 := rtrim(Recinfo.prl_information17);
   Recinfo.prl_information18 := rtrim(Recinfo.prl_information18);
   Recinfo.prl_information19 := rtrim(Recinfo.prl_information19);
   Recinfo.prl_information20 := rtrim(Recinfo.prl_information20);
   Recinfo.prl_information21 := rtrim(Recinfo.prl_information21);
   Recinfo.prl_information22 := rtrim(Recinfo.prl_information22);
   Recinfo.prl_information23 := rtrim(Recinfo.prl_information23);
   Recinfo.prl_information24 := rtrim(Recinfo.prl_information24);
   Recinfo.prl_information25 := rtrim(Recinfo.prl_information25);
   Recinfo.prl_information26 := rtrim(Recinfo.prl_information26);
   Recinfo.prl_information27 := rtrim(Recinfo.prl_information27);
   Recinfo.prl_information28 := rtrim(Recinfo.prl_information28);
   Recinfo.prl_information29 := rtrim(Recinfo.prl_information29);
   Recinfo.prl_information30 := rtrim(Recinfo.prl_information30);
--
   Recinfo.arrears_flag:= rtrim(Recinfo.arrears_flag);
   Recinfo.multi_assignments_flag:= rtrim(Recinfo.multi_assignments_flag);
--
   if (    (   (Recinfo.payroll_id = X_Payroll_Id)
            OR (    (Recinfo.payroll_id IS NULL)
                AND (X_Payroll_Id IS NULL)))
       AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
            OR (    (Recinfo.effective_start_date IS NULL)
                AND (X_Effective_Start_Date IS NULL)))
       AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
            OR (    (Recinfo.effective_end_date IS NULL)
                AND (X_Effective_End_Date IS NULL)))
       AND (   (Recinfo.default_payment_method_id = X_Default_Payment_Method_Id)
            OR (    (Recinfo.default_payment_method_id IS NULL)
                AND (X_Default_Payment_Method_Id IS NULL)))
       AND (   (Recinfo.business_group_id = X_Business_Group_Id)
            OR (    (Recinfo.business_group_id IS NULL)
                AND (X_Business_Group_Id IS NULL)))
       AND (   (Recinfo.consolidation_set_id = X_Consolidation_Set_Id)
            OR (    (Recinfo.consolidation_set_id IS NULL)
                AND (X_Consolidation_Set_Id IS NULL)))
       AND (   (Recinfo.cost_allocation_keyflex_id = X_Cost_Allocation_Keyflex_Id)
            OR (    (Recinfo.cost_allocation_keyflex_id IS NULL)
                AND (X_Cost_Allocation_Keyflex_Id IS NULL)))
       AND (   (Recinfo.suspense_account_keyflex_id = X_Suspense_Account_Keyflex_Id)
            OR (    (Recinfo.suspense_account_keyflex_id IS NULL)
                AND (X_Suspense_Account_Keyflex_Id IS NULL)))
       AND (   (Recinfo.gl_set_of_books_id = X_Gl_Set_Of_Books_Id)
            OR (    (Recinfo.gl_set_of_books_id IS NULL)
                AND (X_Gl_Set_Of_Books_Id IS NULL)))
       AND (   (Recinfo.soft_coding_keyflex_id = X_Soft_Coding_Keyflex_Id)
            OR (    (Recinfo.soft_coding_keyflex_id IS NULL)
                AND (X_Soft_Coding_Keyflex_Id IS NULL)))
       AND (   (Recinfo.period_type = X_Period_Type)
            OR (    (Recinfo.period_type IS NULL)
                AND (X_Period_Type IS NULL)))
       AND (   (Recinfo.organization_id = X_Organization_Id)
            OR (    (Recinfo.organization_id IS NULL)
                AND (X_Organization_Id IS NULL)))
       AND (   (Recinfo.cut_off_date_offset = X_Cut_Off_Date_Offset)
            OR (    (Recinfo.cut_off_date_offset IS NULL)
                AND (X_Cut_Off_Date_Offset IS NULL)))
       AND (   (Recinfo.direct_deposit_date_offset = X_Direct_Deposit_Date_Offset)
            OR (    (Recinfo.direct_deposit_date_offset IS NULL)
                AND (X_Direct_Deposit_Date_Offset IS NULL)))
       AND (   (Recinfo.first_period_end_date = X_First_Period_End_Date)
            OR (    (Recinfo.first_period_end_date IS NULL)
                AND (X_First_Period_End_Date IS NULL)))
       AND (   (Recinfo.negative_pay_allowed_flag = X_Negative_Pay_Allowed_Flag)
            OR (    (Recinfo.negative_pay_allowed_flag IS NULL)
                AND (X_Negative_Pay_Allowed_Flag IS NULL)))
       AND (   (Recinfo.number_of_years = X_Number_Of_Years)
            OR (    (Recinfo.number_of_years IS NULL)
                AND (X_Number_Of_Years IS NULL)))
       AND (   (Recinfo.pay_advice_date_offset = X_Pay_Advice_Date_Offset)
            OR (    (Recinfo.pay_advice_date_offset IS NULL)
                AND (X_Pay_Advice_Date_Offset IS NULL)))
       AND (   (Recinfo.pay_date_offset = X_Pay_Date_Offset)
            OR (    (Recinfo.pay_date_offset IS NULL)
                AND (X_Pay_Date_Offset IS NULL)))
       AND (   (Recinfo.payroll_name = X_Payroll_Name)
            OR (    (Recinfo.payroll_name IS NULL)
                AND (X_Payroll_Name IS NULL)))
       AND (   (Recinfo.workload_shifting_level = X_Workload_Shifting_Level)
            OR (    (Recinfo.workload_shifting_level IS NULL)
                AND (X_Workload_Shifting_Level IS NULL)))
       AND (   (Recinfo.comment_id = X_Comment_Id)
            OR (    (Recinfo.comment_id IS NULL)
                AND (X_Comment_Id IS NULL)))
       AND (   (Recinfo.attribute_category = X_Attribute_Category)
            OR (    (Recinfo.attribute_category IS NULL)
                AND (X_Attribute_Category IS NULL)))
       AND (   (Recinfo.attribute1 = X_Attribute1)
            OR (    (Recinfo.attribute1 IS NULL)
                AND (X_Attribute1 IS NULL)))
       AND (   (Recinfo.attribute2 = X_Attribute2)
            OR (    (Recinfo.attribute2 IS NULL)
                AND (X_Attribute2 IS NULL)))
       AND (   (Recinfo.attribute3 = X_Attribute3)
            OR (    (Recinfo.attribute3 IS NULL)
                AND (X_Attribute3 IS NULL)))
       AND (   (Recinfo.attribute4 = X_Attribute4)
            OR (    (Recinfo.attribute4 IS NULL)
                AND (X_Attribute4 IS NULL)))
       AND (   (Recinfo.attribute5 = X_Attribute5)
            OR (    (Recinfo.attribute5 IS NULL)
                AND (X_Attribute5 IS NULL)))
       AND (   (Recinfo.attribute6 = X_Attribute6)
            OR (    (Recinfo.attribute6 IS NULL)
                AND (X_Attribute6 IS NULL)))
       AND (   (Recinfo.attribute7 = X_Attribute7)
            OR (    (Recinfo.attribute7 IS NULL)
                AND (X_Attribute7 IS NULL)))
       AND (   (Recinfo.attribute8 = X_Attribute8)
            OR (    (Recinfo.attribute8 IS NULL)
                AND (X_Attribute8 IS NULL)))
       AND (   (Recinfo.attribute9 = X_Attribute9)
            OR (    (Recinfo.attribute9 IS NULL)
                AND (X_Attribute9 IS NULL)))
       AND (   (Recinfo.attribute10 = X_Attribute10)
            OR (    (Recinfo.attribute10 IS NULL)
                AND (X_Attribute10 IS NULL)))
       AND (   (Recinfo.attribute11 = X_Attribute11)
            OR (    (Recinfo.attribute11 IS NULL)
                AND (X_Attribute11 IS NULL)))
       AND (   (Recinfo.attribute12 = X_Attribute12)
            OR (    (Recinfo.attribute12 IS NULL)
                AND (X_Attribute12 IS NULL)))
       AND (   (Recinfo.attribute13 = X_Attribute13)
            OR (    (Recinfo.attribute13 IS NULL)
                AND (X_Attribute13 IS NULL)))
       AND (   (Recinfo.attribute14 = X_Attribute14)
            OR (    (Recinfo.attribute14 IS NULL)
                AND (X_Attribute14 IS NULL)))
       AND (   (Recinfo.attribute15 = X_Attribute15)
            OR (    (Recinfo.attribute15 IS NULL)
                AND (X_Attribute15 IS NULL)))
       AND (   (Recinfo.attribute16 = X_Attribute16)
            OR (    (Recinfo.attribute16 IS NULL)
                AND (X_Attribute16 IS NULL)))
       AND (   (Recinfo.attribute17 = X_Attribute17)
            OR (    (Recinfo.attribute17 IS NULL)
                AND (X_Attribute17 IS NULL)))
       AND (   (Recinfo.attribute18 = X_Attribute18)
            OR (    (Recinfo.attribute18 IS NULL)
                AND (X_Attribute18 IS NULL)))
       AND (   (Recinfo.attribute19 = X_Attribute19)
            OR (    (Recinfo.attribute19 IS NULL)
                AND (X_Attribute19 IS NULL)))
       AND (   (Recinfo.attribute20 = X_Attribute20)
            OR (    (Recinfo.attribute20 IS NULL)
                AND (X_Attribute20 IS NULL)))
--
       AND (   (Recinfo.prl_information_category = X_Prl_Information_Category)
            OR (    (Recinfo.prl_information_category IS NULL)
                AND (X_Prl_Information_Category IS NULL)))
       AND (   (Recinfo.prl_information1 = X_Prl_Information1)
            OR (    (Recinfo.prl_information1 IS NULL)
                AND (X_Prl_Information1 IS NULL)))
       AND (   (Recinfo.prl_information2 = X_Prl_Information2)
            OR (    (Recinfo.prl_information2 IS NULL)
                AND (X_Prl_Information2 IS NULL)))
       AND (   (Recinfo.prl_information3 = X_Prl_Information3)
            OR (    (Recinfo.prl_information3 IS NULL)
                AND (X_Prl_Information3 IS NULL)))
       AND (   (Recinfo.prl_information4 = X_Prl_Information4)
            OR (    (Recinfo.prl_information4 IS NULL)
                AND (X_Prl_Information4 IS NULL)))
       AND (   (Recinfo.prl_information5 = X_Prl_Information5)
            OR (    (Recinfo.prl_information5 IS NULL)
                AND (X_Prl_Information5 IS NULL)))
       AND (   (Recinfo.prl_information6 = X_Prl_Information6)
            OR (    (Recinfo.prl_information6 IS NULL)
                AND (X_Prl_Information6 IS NULL)))
       AND (   (Recinfo.prl_information7 = X_Prl_Information7)
            OR (    (Recinfo.prl_information7 IS NULL)
                AND (X_Prl_Information7 IS NULL)))
       AND (   (Recinfo.prl_information8 = X_Prl_Information8)
            OR (    (Recinfo.prl_information8 IS NULL)
                AND (X_Prl_Information8 IS NULL)))
       AND (   (Recinfo.prl_information9 = X_Prl_Information9)
            OR (    (Recinfo.prl_information9 IS NULL)
                AND (X_Prl_Information9 IS NULL)))
       AND (   (Recinfo.prl_information10 = X_Prl_Information10)
            OR (    (Recinfo.prl_information10 IS NULL)
                AND (X_Prl_Information10 IS NULL)))
       AND (   (Recinfo.prl_information11 = X_Prl_Information11)
            OR (    (Recinfo.prl_information11 IS NULL)
                AND (X_Prl_Information11 IS NULL)))
       AND (   (Recinfo.prl_information12 = X_Prl_Information12)
            OR (    (Recinfo.prl_information12 IS NULL)
                AND (X_Prl_Information12 IS NULL)))
       AND (   (Recinfo.prl_information13 = X_Prl_Information13)
            OR (    (Recinfo.prl_information13 IS NULL)
                AND (X_Prl_Information13 IS NULL)))
       AND (   (Recinfo.prl_information14 = X_Prl_Information14)
            OR (    (Recinfo.prl_information14 IS NULL)
                AND (X_Prl_Information14 IS NULL)))
       AND (   (Recinfo.prl_information15 = X_Prl_Information15)
            OR (    (Recinfo.prl_information15 IS NULL)
                AND (X_Prl_Information15 IS NULL)))
       AND (   (Recinfo.prl_information16 = X_Prl_Information16)
            OR (    (Recinfo.prl_information16 IS NULL)
                AND (X_Prl_Information16 IS NULL)))
       AND (   (Recinfo.prl_information17 = X_Prl_Information17)
            OR (    (Recinfo.prl_information17 IS NULL)
                AND (X_Prl_Information17 IS NULL)))
       AND (   (Recinfo.prl_information18 = X_Prl_Information18)
            OR (    (Recinfo.prl_information18 IS NULL)
                AND (X_Prl_Information18 IS NULL)))
       AND (   (Recinfo.prl_information19 = X_Prl_Information19)
            OR (    (Recinfo.prl_information19 IS NULL)
                AND (X_Prl_Information19 IS NULL)))
       AND (   (Recinfo.prl_information20 = X_Prl_Information20)
            OR (    (Recinfo.prl_information20 IS NULL)
                AND (X_Prl_Information20 IS NULL)))
       AND (   (Recinfo.prl_information21 = X_Prl_Information21)
            OR (    (Recinfo.prl_information21 IS NULL)
                AND (X_Prl_Information21 IS NULL)))
       AND (   (Recinfo.prl_information22 = X_Prl_Information22)
            OR (    (Recinfo.prl_information22 IS NULL)
                AND (X_Prl_Information22 IS NULL)))
       AND (   (Recinfo.prl_information23 = X_Prl_Information23)
            OR (    (Recinfo.prl_information23 IS NULL)
                AND (X_Prl_Information23 IS NULL)))
       AND (   (Recinfo.prl_information24 = X_Prl_Information24)
            OR (    (Recinfo.prl_information24 IS NULL)
                AND (X_Prl_Information24 IS NULL)))
       AND (   (Recinfo.prl_information25 = X_Prl_Information25)
            OR (    (Recinfo.prl_information25 IS NULL)
                AND (X_Prl_Information25 IS NULL)))
       AND (   (Recinfo.prl_information26 = X_Prl_Information26)
            OR (    (Recinfo.prl_information26 IS NULL)
                AND (X_Prl_Information26 IS NULL)))
       AND (   (Recinfo.prl_information27 = X_Prl_Information27)
            OR (    (Recinfo.prl_information27 IS NULL)
                AND (X_Prl_Information27 IS NULL)))
       AND (   (Recinfo.prl_information28 = X_Prl_Information28)
            OR (    (Recinfo.prl_information28 IS NULL)
                AND (X_Prl_Information28 IS NULL)))
       AND (   (Recinfo.prl_information29 = X_Prl_Information29)
            OR (    (Recinfo.prl_information29 IS NULL)
                AND (X_Prl_Information29 IS NULL)))
       AND (   (Recinfo.prl_information30 = X_Prl_Information30)
            OR (    (Recinfo.prl_information30 IS NULL)
                AND (X_Prl_Information30 IS NULL)))
--
       AND (   (Recinfo.arrears_flag = X_Arrears_Flag)
            OR (    (Recinfo.arrears_flag IS NULL)
                AND (X_Arrears_Flag IS NULL)))
       AND (   (Recinfo.multi_assignments_flag = X_Multi_Assignments_Flag)
            OR (    (Recinfo.multi_assignments_flag IS NULL)
                AND (X_Multi_Assignments_Flag IS NULL)))
       AND (   (Recinfo.period_reset_years = X_Period_Reset_Years)
            OR (    (Recinfo.period_reset_years IS NULL)
                AND (X_Period_Reset_Years IS NULL)))
       AND (   (Recinfo.payslip_view_date_offset = X_payslip_view_Date_Offset)
            OR (    (Recinfo.payslip_view_date_offset IS NULL)
                AND (X_payslip_view_Date_Offset IS NULL)))

           ) then
     return;
   else
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
--
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- Additions                                                               --
 --   Added X_payslip_view_date_offset By Rajeesha Bug 4246280              --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Payroll_Id                          NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Default_Payment_Method_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Consolidation_Set_Id                NUMBER,
                      X_Cost_Allocation_Keyflex_Id          NUMBER,
                      X_Suspense_Account_Keyflex_Id         NUMBER,
                      X_Gl_Set_Of_Books_Id                  NUMBER,
                      X_Soft_Coding_Keyflex_Id              NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Organization_Id                     NUMBER,
                      X_Cut_Off_Date_Offset                 NUMBER,
                      X_Direct_Deposit_Date_Offset          NUMBER,
                      X_First_Period_End_Date               DATE,
                      X_Negative_Pay_Allowed_Flag           VARCHAR2,
                      X_Number_Of_Years                     NUMBER,
                      X_Pay_Advice_Date_Offset              NUMBER,
                      X_Pay_Date_Offset                     NUMBER,
                      X_Payroll_Name                        VARCHAR2,
                      X_Workload_Shifting_Level             VARCHAR2,
                      X_Comment_Id                          NUMBER,
                      X_Attribute_Category                  VARCHAR2,
                      X_Attribute1                          VARCHAR2,
                      X_Attribute2                          VARCHAR2,
                      X_Attribute3                          VARCHAR2,
                      X_Attribute4                          VARCHAR2,
                      X_Attribute5                          VARCHAR2,
                      X_Attribute6                          VARCHAR2,
                      X_Attribute7                          VARCHAR2,
                      X_Attribute8                          VARCHAR2,
                      X_Attribute9                          VARCHAR2,
                      X_Attribute10                         VARCHAR2,
                      X_Attribute11                         VARCHAR2,
                      X_Attribute12                         VARCHAR2,
                      X_Attribute13                         VARCHAR2,
                      X_Attribute14                         VARCHAR2,
                      X_Attribute15                         VARCHAR2,
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      -- Payroll Developer DF
                      X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                      X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information30                VARCHAR2 DEFAULT NULL,
          -- Extra Columns
          X_Validation_Start_date            DATE,
          X_Validation_End_date              DATE,
                      X_Arrears_Flag                     VARCHAR2,
                      X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
          X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
          X_payslip_view_date_offset         NUMBER DEFAULT NULL
        ) IS

--
   v_payroll_name              varchar2(80);
   v_number_of_years           number;
   v_default_payment_method_id number;
--
 BEGIN
--
   -- Find the current values for payroll name, default payment method and
   -- the number of years.
   current_values
     (X_Rowid,
      v_payroll_name,
      v_number_of_years,
      v_default_payment_method_id);
--
   pay_payrolls_F_pkg.validate_update_payroll
     (X_Business_Group_id,
      X_Payroll_Id,
      X_Payroll_Name,
      v_payroll_name,              -- Current payroll name
      X_Default_Payment_Method_Id,
      v_default_payment_method_id, -- Current default payment method
      X_Validation_Start_Date,
      X_Validation_End_Date);

   UPDATE PAY_PAYROLLS_F
   SET payroll_id                    =    X_Payroll_Id,
       effective_start_date          =    X_Effective_Start_Date,
       effective_end_date            =    X_Effective_End_Date,
       default_payment_method_id     =    X_Default_Payment_Method_Id,
       business_group_id             =    X_Business_Group_Id,
       consolidation_set_id          =    X_Consolidation_Set_Id,
       cost_allocation_keyflex_id    =    X_Cost_Allocation_Keyflex_Id,
       suspense_account_keyflex_id   =    X_Suspense_Account_Keyflex_Id,
       gl_set_of_books_id            =    X_Gl_Set_Of_Books_Id,
       soft_coding_keyflex_id        =    X_Soft_Coding_Keyflex_Id,
       period_type                   =    X_Period_Type,
       organization_id               =    X_Organization_Id,
       cut_off_date_offset           =    X_Cut_Off_Date_Offset,
       direct_deposit_date_offset    =    X_Direct_Deposit_Date_Offset,
       first_period_end_date         =    X_First_Period_End_Date,
       negative_pay_allowed_flag     =    X_Negative_Pay_Allowed_Flag,
       number_of_years               =    X_Number_Of_Years,
       pay_advice_date_offset        =    X_Pay_Advice_Date_Offset,
       pay_date_offset               =    X_Pay_Date_Offset,
       payroll_name                  =    X_Payroll_Name,
       workload_shifting_level       =    X_Workload_Shifting_Level,
       comment_id                    =    X_Comment_Id,
       attribute_category            =    X_Attribute_Category,
       attribute1                    =    X_Attribute1,
       attribute2                    =    X_Attribute2,
       attribute3                    =    X_Attribute3,
       attribute4                    =    X_Attribute4,
       attribute5                    =    X_Attribute5,
       attribute6                    =    X_Attribute6,
       attribute7                    =    X_Attribute7,
       attribute8                    =    X_Attribute8,
       attribute9                    =    X_Attribute9,
       attribute10                   =    X_Attribute10,
       attribute11                   =    X_Attribute11,
       attribute12                   =    X_Attribute12,
       attribute13                   =    X_Attribute13,
       attribute14                   =    X_Attribute14,
       attribute15                   =    X_Attribute15,
       attribute16                   =    X_Attribute16,
       attribute17                   =    X_Attribute17,
       attribute18                   =    X_Attribute18,
       attribute19                   =    X_Attribute19,
       attribute20                   =    X_Attribute20,
       prl_information_category      =    X_Prl_Information_Category,
       prl_information1              =    X_Prl_Information1,
       prl_information2              =    X_Prl_Information2,
       prl_information3              =    X_Prl_Information3,
       prl_information4              =    X_Prl_Information4,
       prl_information5              =    X_Prl_Information5,
       prl_information6              =    X_Prl_Information6,
       prl_information7              =    X_Prl_Information7,
       prl_information8              =    X_Prl_Information8,
       prl_information9              =    X_Prl_Information9,
       prl_information10             =    X_Prl_Information10,
       prl_information11             =    X_Prl_Information11,
       prl_information12             =    X_Prl_Information12,
       prl_information13             =    X_Prl_Information13,
       prl_information14             =    X_Prl_Information14,
       prl_information15             =    X_Prl_Information15,
       prl_information16             =    X_Prl_Information16,
       prl_information17             =    X_Prl_Information17,
       prl_information18             =    X_Prl_Information18,
       prl_information19             =    X_Prl_Information19,
       prl_information20             =    X_Prl_Information20,
       prl_information21             =    X_Prl_Information21,
       prl_information22             =    X_Prl_Information22,
       prl_information23             =    X_Prl_Information23,
       prl_information24             =    X_Prl_Information24,
       prl_information25             =    X_Prl_Information25,
       prl_information26             =    X_Prl_Information26,
       prl_information27             =    X_Prl_Information27,
       prl_information28             =    X_Prl_Information28,
       prl_information29             =    X_Prl_Information29,
       prl_information30             =    X_Prl_Information30,
       arrears_flag                  =    X_Arrears_Flag,
       multi_assignments_flag        =    X_Multi_Assignments_Flag,
       period_reset_years            =    X_Period_Reset_Years,
       payslip_view_date_offset      =    X_payslip_view_date_offset
   WHERE rowid = X_rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_payrolls_f_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
--
   end if;
--
   pay_payrolls_f_pkg.update_payroll
     (x_business_group_id,
      x_payroll_id,
      x_payroll_name,
      v_payroll_name,              -- Current payroll name
      x_default_payment_method_id,
      v_default_payment_method_id, -- Current default payment method
      x_number_of_years,
      v_number_of_years,           -- Current number of years
      x_validation_start_date,
      x_validation_end_date);
--
 END Update_Row;
--
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- Additions                                                               --
 --   Added X_payslip_view_date_offset By Rajeesha Bug 4246280              --
 -- Added the Overloaded procedure to call the API 5144323                  --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Default_Payment_Method_Id           NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Consolidation_Set_Id                NUMBER,
                      X_Cost_Allocation_Keyflex_Id          NUMBER,
                      X_Suspense_Account_Keyflex_Id         NUMBER,
                      X_Gl_Set_Of_Books_Id                  NUMBER,
                      X_Soft_Coding_Keyflex_Id              NUMBER,
                      X_Period_Type                         VARCHAR2,
                      X_Organization_Id                     NUMBER,
                      X_Cut_Off_Date_Offset                 NUMBER,
                      X_Direct_Deposit_Date_Offset          NUMBER,
                      X_First_Period_End_Date               DATE,
                      X_Negative_Pay_Allowed_Flag           VARCHAR2,
                      X_Number_Of_Years                     NUMBER,
                      X_Pay_Advice_Date_Offset              NUMBER,
                      X_Pay_Date_Offset                     NUMBER,
                      X_Payroll_Name                        VARCHAR2,
                      X_Workload_Shifting_Level             VARCHAR2,
                      X_Attribute_Category                  VARCHAR2,
                      X_Attribute1                          VARCHAR2,
                      X_Attribute2                          VARCHAR2,
                      X_Attribute3                          VARCHAR2,
                      X_Attribute4                          VARCHAR2,
                      X_Attribute5                          VARCHAR2,
                      X_Attribute6                          VARCHAR2,
                      X_Attribute7                          VARCHAR2,
                      X_Attribute8                          VARCHAR2,
                      X_Attribute9                          VARCHAR2,
                      X_Attribute10                         VARCHAR2,
                      X_Attribute11                         VARCHAR2,
                      X_Attribute12                         VARCHAR2,
                      X_Attribute13                         VARCHAR2,
                      X_Attribute14                         VARCHAR2,
                      X_Attribute15                         VARCHAR2,
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      -- Payroll Developer DF
                      X_Prl_Information_Category         VARCHAR2 DEFAULT NULL,
                      X_Prl_Information1                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information2                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information3                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information4                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information5                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information6                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information7                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information8                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information9                 VARCHAR2 DEFAULT NULL,
                      X_Prl_Information10                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information11                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information12                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information13                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information14                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information15                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information16                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information17                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information18                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information19                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information20                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information21                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information22                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information23                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information24                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information25                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information26                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information27                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information28                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information29                VARCHAR2 DEFAULT NULL,
                      X_Prl_Information30                VARCHAR2 DEFAULT NULL,
          -- Extra Columns
                      X_Validation_Start_date            DATE,
                      X_Validation_End_date              DATE,
                      X_Arrears_Flag                     VARCHAR2,
                      X_Multi_Assignments_Flag           VARCHAR2 DEFAULT NULL,
                      X_Period_Reset_Years               VARCHAR2 DEFAULT NULL,
                      X_payslip_view_date_offset         NUMBER DEFAULT NULL
--bug 5609830 / 5144323 TEST starts contents
                     ,X_Dt_Update_Mode                   VARCHAR2 --new
                     ,X_effective_date                   DATE --new
                     ,X_Comments                         VARCHAR2 DEFAULT NULL --new
                     ,X_effective_start_date         OUT nocopy DATE --type out added
                     ,X_effective_end_date           OUT nocopy DATE --type out added
                     ,X_Comment_Id                   OUT nocopy NUMBER --type out added
                     ,X_Rowid                     in OUT nocopy VARCHAR2 --type in out added
                     ,X_Payroll_Id                in OUT nocopy NUMBER --type in out added
--bug 5609830 / 5144323 TEST ends contents
        ) IS

--
   v_payroll_name              varchar2(80);
   v_number_of_years           number;
   v_default_payment_method_id number;
--
   l_payroll_id                   number := X_payroll_id;
   l_rowid                        VARCHAR2(150);
   l_prl_object_version_number    NUMBER;

   cursor csr_prl_ovn is
    select object_version_number
    from   pay_all_payrolls_f
    where  rowid = X_Rowid;

   cursor csr_prl_rowid is
    select rowid
    from   pay_all_payrolls_f
    where  payroll_id            = l_Payroll_id
    and    object_version_number = l_prl_object_version_number;
--
   l_cost_allocation_keyflex_id   PAY_ALL_PAYROLLS_F.COST_ALLOCATION_KEYFLEX_ID%TYPE ;
   l_suspense_account_keyflex_id  PAY_ALL_PAYROLLS_F.SUSPENSE_ACCOUNT_KEYFLEX_ID%TYPE ;
   l_soft_coding_keyflex_id       PAY_ALL_PAYROLLS_F.SOFT_CODING_KEYFLEX_ID%TYPE ;
   l_cost_concat_segments         PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_susp_concat_segments         PAY_COST_ALLOCATION_KEYFLEX.concatenated_segments%TYPE ;
   l_scl_concat_segments          HR_SOFT_CODING_KEYFLEX.concatenated_segments%TYPE;
--
 BEGIN
--
   -- Find the current values for payroll name, default payment method and
   -- the number of years.
   current_values
     (X_Rowid,
      v_payroll_name,
      v_number_of_years,
      v_default_payment_method_id);
--
   pay_payrolls_F_pkg.validate_update_payroll
     (X_Business_Group_id,
      X_Payroll_Id,
      X_Payroll_Name,
      v_payroll_name,              -- Current payroll name
      X_Default_Payment_Method_Id,
      v_default_payment_method_id, -- Current default payment method
      X_Validation_Start_Date,
      X_Validation_End_Date);

   open csr_prl_ovn;
   fetch csr_prl_ovn into l_prl_object_version_number;
   close csr_prl_ovn;

   pay_payroll_api.update_payroll(
    p_validate                    => FALSE
   ,p_effective_date              => X_effective_date
   ,p_datetrack_mode              => X_Dt_Update_Mode
   ,p_payroll_name                => X_payroll_name
   ,p_consolidation_set_id        => X_consolidation_set_id
   ,p_number_of_years             => X_number_of_years
   ,p_default_payment_method_id   => X_default_payment_method_id
   ,p_cost_alloc_keyflex_id_in    => X_cost_allocation_keyflex_id
   ,p_susp_account_keyflex_id_in  => X_suspense_account_keyflex_id
   ,p_negative_pay_allowed_flag   => X_negative_pay_allowed_flag
   ,p_soft_coding_keyflex_id_in   => X_soft_coding_keyflex_id
   ,p_comments                    => X_comments
   ,p_attribute_category          => X_attribute_category
   ,p_attribute1      => X_attribute1
   ,p_attribute2      => X_attribute2
   ,p_attribute3      => X_attribute3
   ,p_attribute4      => X_attribute4
   ,p_attribute5      => X_attribute5
   ,p_attribute6      => X_attribute6
   ,p_attribute7      => X_attribute7
   ,p_attribute8      => X_attribute8
   ,p_attribute9      => X_attribute9
   ,p_attribute10     => X_attribute10
   ,p_attribute11     => X_attribute11
   ,p_attribute12     => X_attribute12
   ,p_attribute13     => X_attribute13
   ,p_attribute14     => X_attribute14
   ,p_attribute15     => X_attribute15
   ,p_attribute16     => X_attribute16
   ,p_attribute17     => X_attribute17
   ,p_attribute18     => X_attribute18
   ,p_attribute19     => X_attribute19
   ,p_attribute20     => X_attribute20
   ,p_arrears_flag    => X_arrears_flag
   ,p_multi_assignments_flag    => X_multi_assignments_flag
   ,p_prl_information1      => X_prl_information1
   ,p_prl_information2      => X_prl_information2
   ,p_prl_information3      => X_prl_information3
   ,p_prl_information4      => X_prl_information4
   ,p_prl_information5      => X_prl_information5
   ,p_prl_information6      => X_prl_information6
   ,p_prl_information7      => X_prl_information7
   ,p_prl_information8      => X_prl_information8
   ,p_prl_information9      => X_prl_information9
   ,p_prl_information10     => X_prl_information10
   ,p_prl_information11     => X_prl_information11
   ,p_prl_information12     => X_prl_information12
   ,p_prl_information13     => X_prl_information13
   ,p_prl_information14     => X_prl_information14
   ,p_prl_information15     => X_prl_information15
   ,p_prl_information16     => X_prl_information16
   ,p_prl_information17     => X_prl_information17
   ,p_prl_information18     => X_prl_information18
   ,p_prl_information19     => X_prl_information19
   ,p_prl_information20     => X_prl_information20
   ,p_prl_information21     => X_prl_information21
   ,p_prl_information22     => X_prl_information22
   ,p_prl_information23     => X_prl_information23
   ,p_prl_information24     => X_prl_information24
   ,p_prl_information25     => X_prl_information25
   ,p_prl_information26     => X_prl_information26
   ,p_prl_information27     => X_prl_information27
   ,p_prl_information28     => X_prl_information28
   ,p_prl_information29     => X_prl_information29
   ,p_prl_information30     => X_prl_information30
--
   ,p_workload_shifting_level     => X_Workload_Shifting_Level
   ,p_payslip_view_date_offset    => X_payslip_view_date_offset
--
   ,p_payroll_id                  => l_Payroll_Id
   ,p_object_version_number       => l_prl_object_version_number

   ,p_effective_start_date        => X_effective_start_date
   ,p_effective_end_date          => X_effective_end_date
   ,p_comment_id                  => X_comment_id
--
   ,p_cost_alloc_keyflex_id_out   => l_cost_allocation_keyflex_id
   ,p_susp_account_keyflex_id_out => l_suspense_account_keyflex_id
   ,p_soft_coding_keyflex_id_out  => l_soft_coding_keyflex_id
   ,p_cost_concat_segments_out    => l_cost_concat_segments
   ,p_susp_concat_segments_out    => l_susp_concat_segments
   ,p_scl_concat_segments_out     => l_scl_concat_segments
--
   );

   open csr_prl_rowid;
   fetch csr_prl_rowid into l_rowid;
   close csr_prl_rowid;

   X_Payroll_Id := l_payroll_id;
   X_rowid      := l_rowid;

--
   pay_payrolls_f_pkg.update_payroll
     (x_business_group_id,
      x_payroll_id,
      x_payroll_name,
      v_payroll_name,              -- Current payroll name
      x_default_payment_method_id,
      v_default_payment_method_id, -- Current default payment method
      x_number_of_years,
      v_number_of_years,           -- Current number of years
      x_validation_start_date,
      x_validation_end_date);
--
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
            -- Extra Columns
          X_Payroll_Id                          NUMBER,
          X_Default_Payment_Method_Id           NUMBER,
          X_Dt_Delete_Mode                      VARCHAR2,
          X_Validation_Start_date               DATE,
          X_Validation_End_date                 DATE) IS
 BEGIN
--
   pay_payrolls_f_pkg.validate_delete_payroll
     (x_payroll_id,
      x_default_payment_method_id,
      x_dt_delete_mode,
      x_validation_start_date,
      x_validation_end_date);
--
   DELETE FROM PAY_PAYROLLS_F
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_payrolls_f_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
   pay_payrolls_F_pkg.delete_payroll
     (x_payroll_id,
      x_default_payment_method_id,
      x_dt_delete_mode,
      x_validation_start_date,
      x_validation_end_date);
--
 END Delete_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a payroll via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Added the Overloaded procedure to call the API 5144323                  --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                               VARCHAR2,
            -- Extra Columns
          X_Payroll_Id                          NUMBER,
          X_Default_Payment_Method_Id           NUMBER,
          X_Dt_Delete_Mode                      VARCHAR2,
          X_Validation_Start_date               DATE,
          X_Validation_End_date                 DATE
-- bug 5609830 / 5144323 TEST starts contents
         ,X_effective_date                      DATE
-- bug 5609830 / 5144323 TEST ends contents
          ) IS
--
  l_effective_start_date date;
  l_effective_end_date   date;
  l_prl_object_version_number    NUMBER;

  cursor csr_prl_ovn is
    select object_version_number
    from   pay_all_payrolls_f
    where  rowid = X_Rowid;
--
 BEGIN
--
   pay_payrolls_f_pkg.validate_delete_payroll
     (x_payroll_id,
      x_default_payment_method_id,
      x_dt_delete_mode,
      x_validation_start_date,
      x_validation_end_date);
--
  open csr_prl_ovn;
  fetch csr_prl_ovn into l_prl_object_version_number;
  close csr_prl_ovn;

  pay_payroll_api.delete_payroll
  (p_validate                     => FALSE,
   p_effective_date               => X_effective_date,
   p_datetrack_mode               => X_Dt_Delete_Mode,
   p_payroll_id                   => X_payroll_id,
   p_object_version_number        => l_prl_object_version_number,
   p_effective_start_date         => l_effective_start_date,
   p_effective_end_date           => l_effective_end_date
  );
--
   pay_payrolls_F_pkg.delete_payroll
     (x_payroll_id,
      x_default_payment_method_id,
      x_dt_delete_mode,
      x_validation_start_date,
      x_validation_end_date);
--
 END Delete_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_offset_field_prompts                                              --
 -- Purpose                                                                 --
 --   To retrieve the labels for the form PAYWSDPG taking the legislation   --
 --   code as parameter.                                                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -- Additions                                                               --
 --   Added p_payslip_view_date_prompt By Rajeesha Bug 4246280              --
 -----------------------------------------------------------------------------
--
 PROCEDURE get_offset_field_prompts ( p_legislation_code IN varchar2,
                                      p_pay_date_prompt IN out nocopy varchar2,
                                      p_dd_offset_prompt IN out nocopy varchar2,
                                      p_pay_advice_offset_prompt IN out nocopy varchar2,
                                      p_cut_off_date IN out nocopy varchar2,
                                      p_arrears_flag IN out nocopy varchar2,
              p_payslip_view_date_prompt IN out nocopy varchar2
            )
 IS
   CURSOR c_advance_pay IS
      SELECT 'X'
      FROM   pay_legislation_rules
      WHERE  legislation_code = p_legislation_code
      AND    rule_type = 'ADVANCE';

   l_lookup_type  varchar2(80);
 BEGIN

   l_lookup_type := p_legislation_code || '_PAYWSDPG_PROMPT';

   p_pay_date_prompt := hr_general.decode_lookup(l_lookup_type, 'PAY_DATE_PROMPT');
   p_dd_offset_prompt := hr_general.decode_lookup(l_lookup_type, 'DD_OFFSET_PROMPT');
   p_pay_advice_offset_prompt := hr_general.decode_lookup(l_lookup_type, 'PAY_ADVICE_OFFSET_PROMPT');
   p_cut_off_date := hr_general.decode_lookup(l_lookup_type, 'CUT_OFF_DATE');
   p_payslip_view_date_prompt := hr_general.decode_lookup(l_lookup_type,'PAYSLIP_VIEW_DATE_PROMPT');
--
-- Currently the Arrears flag is only relevant for legislations using Advance
-- Pay.  Although it's part of the core product it may appear confusing to
-- customers in other legislations (US) if this flag was not set but they were
-- running an Arrears Payroll.  This temporary piece of code will ensure that
-- only legislations with the 'ADVANCE' element defined will display the flag.
   OPEN c_advance_pay;
   FETCH c_advance_pay
   INTO  p_arrears_flag;
   CLOSE c_advance_pay;

 END get_offset_field_prompts;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   show_ddf_canvas_yesno                                                 --
 -- Purpose                                                                 --
 --   If at least a segment has been defined for the Payroll DDF, then      --
 --   the PAYROLL_DDF canvas will be shown                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE show_ddf_canvas_yesno ( p_ddf_name IN varchar2,
                                   p_legislation_code IN varchar2,
                                   p_show_ddf_canvas out nocopy boolean)
 IS
   CURSOR c_show_ddf_canvas IS
      SELECT 1
      FROM   fnd_descr_flex_column_usages
      WHERE  application_id = 801
      AND    descriptive_flexfield_name = p_ddf_name
      AND    descriptive_flex_context_code = p_legislation_code;
--
   v_dummy            number;
   v_show_ddf_canvas  boolean  := false;
--
 BEGIN
--
   hr_utility.set_location('pyprl01t.show_ddf_canvas_yesno',100);

-- the flexfield canvas will be shown only if there are segments defined
-- for the Payroll DDF

   OPEN c_show_ddf_canvas;
   FETCH c_show_ddf_canvas into v_dummy;
   if c_show_ddf_canvas%found then
     v_show_ddf_canvas := true;
   end if;
   CLOSE c_show_ddf_canvas;

   p_show_ddf_canvas := v_show_ddf_canvas;
   hr_utility.set_location('pyprl01t.show_ddf_canvas_yesno',200);

 END show_ddf_canvas_yesno;
--
END pay_payrolls_f_pkg;

/
