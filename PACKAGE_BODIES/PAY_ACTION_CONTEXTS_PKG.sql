--------------------------------------------------------
--  DDL for Package Body PAY_ACTION_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ACTION_CONTEXTS_PKG" as
/* $Header: pyactx.pkb 120.0 2005/05/29 01:51:32 appldev noship $ */
--
-- private global variables
--
type g_context_ids_type is record (
    original_entry_id   ff_contexts.context_id%type,
    jurisdiction_code   ff_contexts.context_id%type,
    tax_group           ff_contexts.context_id%type);

g_context_ids       g_context_ids_type;
g_legislation_code  pay_legislation_rules.legislation_code%type;



procedure archinit(p_pay_act_id in number)
is
begin
    hr_utility.trace('> archinit()');

    --
    -- lookup up context id values for contexts to be populated
    --
    begin
        SELECT c1.context_id original_entry_id,
               c2.context_id jurisdiction_code,
               c3.context_id tax_group
        INTO   g_context_ids
        FROM   FF_CONTEXTS c3,
               FF_CONTEXTS c2,
               FF_CONTEXTS c1
        WHERE  c1.context_name = 'ORIGINAL_ENTRY_ID'
        and    c2.context_name = 'JURISDICTION_CODE'
        and    c3.context_name = 'TAX_GROUP';
    exception
        when NO_DATA_FOUND then
            ff_utils.assert(false, 'pay_action_contexts_pkg:archinit:10');
    end;

    --
    -- lookup up legislation code for business group
    --
    begin
        SELECT ou.org_information9
        INTO   g_legislation_code
        FROM   HR_ORGANIZATION_INFORMATION ou,
               HR_ORGANIZATION_UNITS       o,
               PAY_PAYROLL_ACTIONS         pa
        WHERE  pa.payroll_action_id = p_pay_act_id
        and    o.business_group_id = pa.business_group_id
        and    ou.organization_id = o.organization_id
        and    ou.org_information_context = 'Business Group Information';
    exception
        when NO_DATA_FOUND then
            ff_utils.assert(false, 'pay_action_contexts_pkg:archinit:20');
    end;

    hr_utility.trace('< archinit()');
end archinit;



procedure range_cursor(p_pay_act_id in            number
                      ,p_sqlstr        out nocopy varchar2)
is
begin
    hr_utility.trace('> range_cursor()');

    p_sqlstr :=
    'SELECT DISTINCT
            asg.person_id
     FROM   PER_ASSIGNMENTS_F   asg,
            PAY_PAYROLL_ACTIONS pa
     WHERE  pa.payroll_action_id = :payroll_action_id
     and    asg.business_group_id = pa.business_group_id
     ORDER BY
            asg.person_id';

    hr_utility.trace('< range_cursor()');
end range_cursor;



procedure action_creation(p_pay_act_id in number,
                          p_stperson   in number,
                          p_endperson  in number,
                          p_chunk      in number)
is
    cursor csr_asg_acts(b_pay_act_id number, b_stperson number,
                                                    b_endperson number) is
        SELECT DISTINCT
               asg.assignment_id
        FROM   PAY_PAYROLL_ACTIONS    pa,
               PER_ALL_ASSIGNMENTS_F  asg,
               PER_PERIODS_OF_SERVICE pos
        WHERE  pa.payroll_action_id = b_pay_act_id
        and    asg.business_group_id = pa.business_group_id
        and    pa.effective_date between
                    asg.effective_start_date and asg.effective_end_date
        and    pos.period_of_service_id = asg.period_of_service_id
        and    pos.person_id between b_stperson and b_endperson;

    l_locking_asg_act_id number;
begin
    hr_utility.trace('> action_creation()');

    for rec_asg_act in csr_asg_acts(p_pay_act_id, p_stperson, p_endperson) loop
        SELECT pay_assignment_actions_s.nextval
        INTO   l_locking_asg_act_id
        FROM   DUAL;

        --
        -- insert assignment action record
        --
        hr_nonrun_asact.insact(l_locking_asg_act_id, rec_asg_act.assignment_id,
                                p_pay_act_id, p_chunk, null);
    end loop;

    hr_utility.trace('< action_creation()');
end action_creation;



procedure ins_action_context(p_asg_act_id    in number,
                             p_asg_id        in number,
                             p_context_id    in number,
                             p_context_value in varchar2)
is
    cursor csr_chk_dup(b_asg_act_id    number,
                       b_asg_id        number,
                       b_context_id    number,
                       b_context_value varchar2) is
        SELECT 1
        FROM   PAY_ACTION_CONTEXTS ac
        WHERE  ac.assignment_action_id = b_asg_act_id
        and    ac.assignment_id = b_asg_id
        and    ac.context_id = b_context_id
        and    ac.context_value = b_context_value;

    rec_dummy csr_chk_dup%rowtype;
begin
    hr_utility.trace('> ins_action_context()');

    --
    -- before doing insert,
    -- check if context value already exists,
    -- if it does then don't bother inserting again,
    -- nb. need to use this approach as csr_context_values may select out
    --     duplicate values
    --
    open csr_chk_dup(p_asg_act_id, p_asg_id, p_context_id, p_context_value);
    fetch csr_chk_dup into rec_dummy;

    if csr_chk_dup%notfound then
        hr_utility.trace('AA_ID>'         || p_asg_act_id    || '< ' ||
                         'ASG_ID>'        || p_asg_id        || '< ' ||
                         'CONTEXT_ID>'    || p_context_id    || '< ' ||
                         'CONTEXT_VALUE>' || p_context_value || '<');
        INSERT INTO pay_action_contexts (
            assignment_action_id,
            assignment_id,
            context_id,
            context_value)
        VALUES (
            p_asg_act_id,
            p_asg_id,
            p_context_id,
            p_context_value);
    end if;

    close csr_chk_dup;

    hr_utility.trace('< ins_action_context()');
exception
    when others then
        close csr_chk_dup;
        raise;
end ins_action_context;



procedure process_asg_act(p_asg_id         in number,
                          p_asg_act_id     in number,
                          p_tax_unit_id    in number,
                          p_effective_date in date,
                          p_action_type    in varchar2)
is
    --
    -- may select out duplicate context values
    -- eg.      sor_    jur_  sor_  entry_
    --          id      code  type  type
    --     RR1  299035  null  E     E
    --     RR2  299035  null  I     E
    --
    -- nb. selecting out distinct values is not possible because the
    --     source type and entry type are required
    --
    cursor csr_context_values(b_asg_act_id number) is
        SELECT distinct
               et.element_type_id,
               et.processing_type,
               rr.source_id,
               rr.jurisdiction_code
        FROM   PAY_RUN_RESULTS rr,
               PAY_ELEMENT_TYPES_F et
        WHERE  rr.assignment_action_id = b_asg_act_id
        AND    et.element_type_id      = rr.element_type_id
        AND    p_effective_date between
               et.effective_start_date and et.effective_end_date;

    --
    -- Cursor to check if the specified source entry of an adjustment
    -- run result is an original entry (a normal entry).
    --
    cursor csr_is_adj_orig_entry(p_entry_id in number)
    is
    select 1
      from   pay_element_entries_f pee
      where  pee.element_entry_id = p_entry_id
      and    pee.entry_type       = 'E';
    --
    l_dummy     number;

    l_tax_group pay_action_contexts.context_value%type;
begin
    hr_utility.trace('> process_asg_act()');

    --
    -- if in US legislation then also look up tax group
    --
    if g_legislation_code = 'US' then
        begin
            SELECT oi.org_information5
            INTO   l_tax_group
            FROM   HR_ORGANIZATION_INFORMATION oi
            WHERE  upper(oi.org_information_context) = 'FEDERAL TAX RULES'
            and    oi.organization_id = p_tax_unit_id;
        exception
            when NO_DATA_FOUND then
                null;
        end;

        --
        -- if tax group does not exist set or is null then
        -- set context value to 'No Tax Group'
        --
        if l_tax_group is null then
            l_tax_group  := 'No Tax Group';
        end if;

        ins_action_context(p_asg_act_id, p_asg_id,
                            g_context_ids.tax_group, l_tax_group);
    end if;

    --
    -- get distinct context values for current assignment action
    --
    for rec_context_value in csr_context_values(p_asg_act_id) loop

      --
      -- Check for ORIGINAL_ENTRY_ID context.
      --
      if p_action_type in ('B', 'I') then
        --
        -- For the adjustment actions, check to see if the originated
        -- entry is a normal entry (entry_type='E').
        --
        open csr_is_adj_orig_entry(rec_context_value.source_id);
        fetch csr_is_adj_orig_entry into l_dummy;
        if csr_is_adj_orig_entry%found then

          ins_action_context(p_asg_act_id, p_asg_id,
                             g_context_ids.original_entry_id,
                             to_char(rec_context_value.source_id));
        end if;
        close csr_is_adj_orig_entry;

      else
        if rec_context_value.processing_type = 'R' then

            -- Insert an action context for all RECURRING entries
            -- that have a formula associated with them that
            -- uses ORIGINAL_ENTRY_ID.
            -- This does not match exactly with the Payroll processes
            -- but it's difficult to do that after the fact.
            declare
               is_oeid number;
            begin
            select 1
            into   is_oeid
            from   pay_status_processing_rules_f spr,
                   ff_fdi_usages_f               fdi
            where  spr.element_type_id = rec_context_value.element_type_id
            and    p_effective_date between
                   spr.effective_start_date and spr.effective_end_date
            and    fdi.formula_id      = spr.formula_id
            and    p_effective_date between
                   fdi.effective_start_date and fdi.effective_end_date
            and    fdi.item_name       = 'ORIGINAL_ENTRY_ID'
            and    fdi.usage           = 'U'
            and    rownum = 1;

            ins_action_context(p_asg_act_id, p_asg_id,
                               g_context_ids.original_entry_id,
                               to_char(rec_context_value.source_id));

            exception when no_data_found then
               null;
            end;

        end if;
      end if;

        --
        -- insert jurisdiction code into action contexts
        --
        if rec_context_value.jurisdiction_code is not null then
            ins_action_context(p_asg_act_id, p_asg_id,
                               g_context_ids.jurisdiction_code,
                               rec_context_value.jurisdiction_code);
        end if;
    end loop;

    hr_utility.trace('< process_asg_act()');
end process_asg_act;



procedure archive_data(p_asg_act_id in number, p_effective_date in date)
is
    --
    -- all assigment actions associated with marker assignment action,
    -- only process assignment actions associated with runs of type:
    -- - 'R' (payroll run)
    -- - 'Q' (quick pay)
    -- - 'B' (balance adjustment)
    -- - 'V' (reversal)
    -- - 'I' (balance initialisation)
    --
    -- also excludes assignment actions associated with a run of
    -- type 'X' (archiver)
    --
    cursor csr_asg_acts(b_asg_act_id number) is
        SELECT pa.effective_date,
               pa.action_type,
               aat.assignment_id,
               aat.assignment_action_id,
               aat.tax_unit_id
        FROM   PAY_PAYROLL_ACTIONS    pa,
               PAY_ASSIGNMENT_ACTIONS aat,
               PAY_ASSIGNMENT_ACTIONS aam
        WHERE  aam.assignment_action_id = b_asg_act_id
        and    aat.assignment_id = aam.assignment_id
        and    pa.payroll_action_id = aat.payroll_action_id
        and    pa.action_type in ('R', 'Q', 'B', 'V', 'I')
        and    pa.effective_date <= p_effective_date
        and    NOT EXISTS
                (SELECT 1
                 FROM   PAY_ACTION_CONTEXTS ac
                 WHERE  ac.assignment_action_id = aat.assignment_action_id)
        ORDER BY
               aat.assignment_action_id;
begin
    hr_utility.trace('> ***** archive_data() *****');
    hr_utility.trace('  p_asg_act_id>' || p_asg_act_id || '<');
    hr_utility.trace('  p_effective_date>' || p_effective_date || '<');

    --
    -- loop through all assignment actions associated with an assignment,
    -- do context processing for each assignment action individually
    --
    for rec_asg_act in csr_asg_acts(p_asg_act_id) loop
        process_asg_act(rec_asg_act.assignment_id,
                            rec_asg_act.assignment_action_id,
                            rec_asg_act.tax_unit_id,
                            rec_asg_act.effective_date,
                            rec_asg_act.action_type);
    end loop;

    hr_utility.trace('< ***** archive_data() *****');
exception
    when others then
        hr_utility.trace('***** others');
        hr_utility.trace('***** sqlcode>' || sqlcode || '<');
        hr_utility.trace('***** sqlerrm>' || sqlerrm || '<');
        raise;
end archive_data;



procedure deinitialise(p_pay_act_id in number)
is
begin
    hr_utility.trace('> deinitialise()');
    hr_utility.trace('< deinitialise()');
end deinitialise;

end pay_action_contexts_pkg;

/
