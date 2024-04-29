--------------------------------------------------------
--  DDL for Package Body PAY_MIX_ROLLBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MIX_ROLLBACK_PKG" AS
/* $Header: pymixrbk.pkb 120.1 2006/11/29 12:29:29 susivasu noship $ */
--
-- type defs
--

type varchar2_table is table of varchar2(240)
  index by binary_integer;

type varchar2_table2 is table of varchar2(1)
  index by binary_integer;

type number_table is table of number
  index by binary_integer;

--
-- global declarations
--

g_message_tbl           varchar2_table;
g_message_level_tbl     varchar2_table2;
g_message_id_tbl        number_table;
g_message_count         number := 0;
g_message_severity_tbl  varchar2_table2;


--
-- undo_mix
--

procedure undo_mix(
  p_errbuf                           out nocopy varchar2,
  p_retcode                          out nocopy number,
  p_batch_header_id                  in number,
  p_commit_all_or_nothing            in varchar2 default 'Y',
  p_reject_if_run_results_exist      in varchar2 default 'Y',
  p_dml_mode                         in varchar2,
  p_leave_batch                      in varchar2 default 'Y',
  p_assignment_id                    in number default null,
  p_asg_action_id                    in number default null
) is

type batch_line is record
(
  batch_line_id   pay_batch_lines.batch_id%type,
  assignment_id   pay_batch_lines.assignment_id%type,
  assignment_number pay_batch_lines.assignment_number%type,
  element_type_id pay_batch_lines.element_type_id%type,
  effective_date  pay_batch_lines.effective_date%type,
  effective_start_date  pay_batch_lines.effective_start_date%type
);

  l_business_group_id      number;
  l_check_batch_id         varchar2(1) := 'N';
  l_allow_rollback         varchar2(30);
  l_reject_ent_not_removed varchar2(30);
  l_DATE_EFFECTIVE_CHANGES varchar2(30);
  l_element_entry_id       number;
  l_creator_id             number;
  l_creator_type           varchar2(1);
  l_assignments_processed  number      := 0;
  l_max_errors             pay_action_parameters.parameter_value%type;
  l_batch_line             batch_line;
  l_effective_session_date date;
  l_errbuf                 varchar2(2000);
  l_retcode                number;

  cursor csr_check_classification is
  select 'Y'
    from pay_element_types_f pet,
         pay_element_classifications pec
   where pet.element_type_id = l_batch_line.element_type_id
     and pet.CLASSIFICATION_ID = pec.CLASSIFICATION_ID
     and pet.PROCESSING_TYPE = 'R'
     and pec.legislation_code is not null
     and pec.CLASSIFICATION_name like 'EXTERNAL_REPORTING%'
     and pec.legislation_code = 'GB';

  l_ele_class_chk varchar2(1);

  cursor c_batch_lines is
    select pbl.batch_line_id,
           pbl.assignment_id,
           pbl.assignment_number,
           pbl.element_type_id,
           pbl.effective_date,
           pbl.effective_start_date
    from   pay_batch_lines pbl
    where  pbl.batch_id = p_batch_header_id
    and    pbl.batch_line_status = 'T'
    and    (p_assignment_id is null or pbl.assignment_id = p_assignment_id)
    union all
    select to_number(null) batch_line_id,
           to_number(null) assignment_id,
           to_char(null) assignment_number,
           to_number(null) element_type_id,
           to_date(null) effective_date,
           to_date(null) effective_start_date
    from   dual
    where  not exists
               (select null
                from   pay_batch_headers pbh
                where pbh.batch_id = p_batch_header_id);

  cursor c_batch_entries (c_assignment_id number) is
    select pee.element_entry_id, pee.creator_type,
           pee.creator_id, pee.effective_start_date
    from   pay_element_entries_f pee,
           pay_element_links_f pel,
           pay_element_types_f pet
    where  pee.creator_id = p_batch_header_id
    and    pee.creator_type = 'H'
    and    (pee.source_id is null or pee.source_id = p_asg_action_id)
    and    pee.element_link_id = pel.element_link_id
    and    pel.element_type_id = l_batch_line.element_type_id
    and    pet.element_type_id = pel.element_type_id
    and    pee.assignment_id = c_assignment_id
    and ((pet.processing_type = 'R'
          and pee.effective_start_date = l_batch_line.effective_date)
          or (pet.processing_type = 'N'
              and l_batch_line.effective_date between pee.effective_start_date
              and pee.effective_end_date))
    and l_batch_line.effective_date between pel.effective_start_date
                                        and pel.effective_end_date
    and l_batch_line.effective_date between pet.effective_start_date
                                        and pet.effective_end_date
    and l_ele_class_chk is null
    union all
    select pee.element_entry_id, pee.creator_type,
           pee.creator_id, pee.effective_start_date
    from   per_absence_attendances paa,
           pay_element_entries_f pee,
           pay_element_links_f pel,
           pay_element_types_f pet
    where  paa.batch_id = p_batch_header_id
    and    pee.creator_id = paa.absence_attendance_id
    and    pee.creator_type = 'A'
    and    (pee.source_id is null or pee.source_id = p_asg_action_id)
    and    pee.element_link_id = pel.element_link_id
    and    pel.element_type_id = l_batch_line.element_type_id
    and    pet.element_type_id = pel.element_type_id
    and    pee.assignment_id = c_assignment_id
    and l_batch_line.effective_date between pel.effective_start_date
                                        and pel.effective_end_date
    and l_batch_line.effective_date between pet.effective_start_date
                                        and pet.effective_end_date
    and l_ele_class_chk is null
    union all
    select pee.element_entry_id, pee.creator_type,
           pee.creator_id, pee.effective_start_date
    from   pay_element_entries_f pee,
           pay_element_links_f pel,
           pay_element_types_f pet
    where  pee.creator_id = p_batch_header_id
    and    pee.creator_type = 'H'
    and    (pee.source_id is null or pee.source_id = p_asg_action_id)
    and    pee.element_link_id = pel.element_link_id
    and    pel.element_type_id = l_batch_line.element_type_id
    and    pet.element_type_id = pel.element_type_id
    and    pee.assignment_id = c_assignment_id
    and pet.processing_type = 'R'
    and ((l_batch_line.effective_start_date is not null and pee.effective_start_date=l_batch_line.effective_start_date)
        or
         (l_batch_line.effective_start_date is null and pee.effective_start_date=l_batch_line.effective_date))
    and l_batch_line.effective_date between pel.effective_start_date
                                        and pel.effective_end_date
    and l_batch_line.effective_date between pet.effective_start_date
                                        and pet.effective_end_date
    and l_ele_class_chk is not null
    union all
    select pee.element_entry_id, pee.creator_type,
           pee.creator_id, pee.effective_start_date
    from   pay_element_entries_f pee
    where  pee.creator_id = p_batch_header_id
    and    pee.creator_type = 'H'
    and    pee.source_id = p_asg_action_id
    and    pee.assignment_id = c_assignment_id
    and    pee.entry_type = 'E'
    and    l_batch_line.element_type_id is null
    union all
    select pee.element_entry_id, pee.creator_type,
           pee.creator_id, pee.effective_start_date
    from   per_absence_attendances paa,
           pay_element_entries_f pee
    where  paa.batch_id = p_batch_header_id
    and    pee.creator_id = paa.absence_attendance_id
    and    pee.creator_type = 'A'
    and    pee.source_id = p_asg_action_id
    and    pee.assignment_id = c_assignment_id
    and    pee.entry_type = 'E'
    and    l_batch_line.element_type_id is null;

  cursor csr_control_lines (p_batch_id number) is
    select pct.batch_control_id
      from pay_batch_control_totals pct
     where pct.batch_id = p_batch_id;

  l_ctl_rec csr_control_lines%ROWTYPE;

  cursor csr_pay_act_exists (p_batch_id number) is
    select 'Y'
      from pay_payroll_actions pact
     where pact.batch_id = p_batch_id
       and pact.action_type = 'BEE';

  l_pay_act_exists varchar2(1) := 'N';

  cursor csr_payroll_action_exists is
    select pact.payroll_action_id,
           pact.business_group_id
      from pay_payroll_actions pact
     where pact.batch_id = p_batch_header_id
       and pact.action_type = 'BEE'
       and pact.batch_process_mode = 'TRANSFER';

  cursor csr_check_entry_modified (p_ee_id number, p_eff_date date) is
   select 'Y'
   from   pay_element_entries_f pee
   where  pee.element_entry_id = p_ee_id
   and    p_eff_date between pee.effective_start_date
                                 and pee.effective_end_date
   and    pee.creator_type in ('A','H')
   and    pee.creator_id is not null
   and exists (select null
               from   pay_element_entries_f pee1
               where  pee.element_entry_id = pee1.element_entry_id
               and    (pee1.creator_type <> pee.creator_type
                       or pee1.creator_id <> pee.creator_id));

  l_chk_entry_modified varchar2(1);
  l_chk_rollback_upd   varchar2(1);

  l_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;
  l_assignment_id per_assignments_f.assignment_id%TYPE;
  l_request_id number := 0;
  l_entry_exists varchar2(1) := 'N';

begin

  hr_utility.set_location('pay_mix_rollback_pkg.undo_mix',10);

  --
  if p_asg_action_id is null then
     l_payroll_action_id := null;
     open csr_payroll_action_exists;
     fetch csr_payroll_action_exists into l_payroll_action_id,l_business_group_id;
     close csr_payroll_action_exists;
     --
     if l_payroll_action_id is not null then

        l_request_id :=  pay_paywsqee_pkg.paylink_request_id(
                             p_business_group_id     => l_business_group_id,
                             p_mode                  => 'ROLLBACK',
                             p_batch_id              => p_batch_header_id,
                             p_wait                  => 'Y' );

        open csr_payroll_action_exists;
        fetch csr_payroll_action_exists into l_payroll_action_id,l_business_group_id;
        if ( l_request_id = 0 or csr_payroll_action_exists%found) then
           close csr_payroll_action_exists;
           hr_utility.raise_error;
        end if;
        close csr_payroll_action_exists;

        return;
     end if;
  end if;

  --
  SAVEPOINT RB;
  --
  -- No longer needed since this is supported within the
  -- PYUGEN processes.
  -- -- Get max_errors_allowed value
  -- l_max_errors := action_parameter('MAX_ERRORS_ALLOWED');

  begin

    -- Ensure batch is valid for rollback
    hr_utility.set_location('pay_mix_rollback_pkg.undo_mix',20);

    select 'Y'
    into   l_check_batch_id
    from   pay_batch_headers
    where  batch_id = p_batch_header_id
    and    batch_status = 'T';

    -- Get business_group_id
    hr_utility.set_location('pay_mix_rollback_pkg.undo_mix',30);

    select business_group_id,
           nvl(REJECT_ENTRY_NOT_REMOVED,'N'),
           nvl(ROLLBACK_ENTRY_UPDATES,'N'),
           DATE_EFFECTIVE_CHANGES
    into   l_business_group_id,
           l_reject_ent_not_removed,
           l_allow_rollback,
           l_DATE_EFFECTIVE_CHANGES
    from   pay_batch_headers
    where  batch_id = p_batch_header_id;

  exception
    when no_data_found then
      l_check_batch_id := 'N';

  end;

  -- If no action id is passed and if payroll actions exits for this batch then
  -- do not undo mix.
  open csr_pay_act_exists(p_batch_header_id);
  fetch csr_pay_act_exists into l_pay_act_exists;
  if csr_pay_act_exists%found and p_asg_action_id is null then
     --
     close csr_pay_act_exists;
     hr_utility.set_message(800,'HR_289717_BEE_CANNOT_ROLLBACK');
     hr_utility.raise_error;
     --
  end if;
  close csr_pay_act_exists;
  --
  -- Only purge header message if it is has been called by outside of the PYUGEN.
  --
  if p_asg_action_id is null then
     -- First delete any messages relating to this batch from pay_message_lines
     purge_rollback_messages(p_batch_header_id,'H');
  end if;

  if (l_check_batch_id = 'Y') or (l_check_batch_id = 'N' and p_asg_action_id is not null) then
    hr_utility.set_location('pay_mix_rollback_pkg.undo_mix',40);

    open c_batch_lines;
    fetch c_batch_lines into l_batch_line;

    while c_batch_lines%found loop

      purge_rollback_messages(l_batch_line.batch_line_id,'L');

      open csr_check_classification;
      fetch csr_check_classification into l_ele_class_chk;
      close csr_check_classification;

      if (l_batch_line.assignment_id is not null or p_assignment_id is not null) then
         l_assignment_id := nvl(p_assignment_id,l_batch_line.assignment_id);
      else

         select assignment_id
         into l_assignment_id
         from per_assignments_f asg
         where upper(asg.assignment_number) = upper(l_batch_line.assignment_number)
         and   asg.business_group_id = l_business_group_id
         and ((l_batch_line.effective_start_date is not null
               and l_batch_line.effective_start_date between asg.effective_start_date
                                                         and asg.effective_end_date)
             or (l_batch_line.effective_start_date is null
               and l_batch_line.effective_date between asg.effective_start_date
                                                   and asg.effective_end_date));
      end if;

      open c_batch_entries(l_assignment_id);
      fetch c_batch_entries into l_element_entry_id, l_creator_type,
                                 l_creator_id, l_effective_session_date;

      l_entry_exists := 'N';
      while c_batch_entries%found loop
        --
        --
        -- Check the entry is modifed.
        l_chk_rollback_upd := 'N';
        open csr_check_entry_modified(l_element_entry_id,l_effective_session_date);
        fetch csr_check_entry_modified into l_chk_entry_modified;
        if csr_check_entry_modified%found then
           l_chk_entry_modified := 'Y';
           --
           if (l_allow_rollback = 'Y' and l_date_effective_changes = 'U') then
              l_chk_rollback_upd := 'Y';
           end if;
           --
        else
           l_chk_entry_modified := 'N';
        end if;
        close csr_check_entry_modified;
        --
        if (l_chk_entry_modified <> 'Y' or l_chk_rollback_upd='Y') then
          --
          -- If run results exist for the element entry, the user may want us
          -- to error the line.
          if p_reject_if_run_results_exist = 'Y'
             and run_results_exist(l_element_entry_id,
                                   l_effective_session_date,
                                   l_chk_rollback_upd) then

            -- MAx errros checks and commit all or nothing are
            -- done at the payroll_action level.
            --
            -- if p_commit_all_or_nothing = 'Y' then
            --   g_message_count := g_message_count + 1;
            --   insert_rollback_message('L', l_batch_line.batch_line_id, 'F', false);
            --
            -- elsif p_commit_all_or_nothing = 'N'
            --       and g_message_count >= fnd_number.canonical_to_number(l_max_errors) then
            --
            --   g_message_count := g_message_count + 1;
            --   insert_rollback_message('L', l_batch_line.batch_line_id, 'F', false);
            --
            -- else
            --
            --   g_message_count := g_message_count + 1;
            --   insert_rollback_message('L', l_batch_line.batch_line_id, 'I', false);
            --
            -- end if;
            g_message_count := g_message_count + 1;
            hr_utility.set_message(801,'PAY_52014_RUN_RESULTS_EXIST');
            insert_rollback_message('L', l_batch_line.batch_line_id, 'F', false);

          else

            -- in the case of an absence remove the absence record
            if (l_creator_type = 'A') then

               delete from per_absence_attendances
               where absence_attendance_id = l_creator_id;

            end if;

            -- remove entry
            begin
               l_entry_exists := 'Y';
               --
               if l_chk_rollback_upd = 'Y' then
                  hr_entry_api.delete_element_entry('DELETE_NEXT_CHANGE',
                                                    l_effective_session_date-1,
                                                    l_element_entry_id);
               else
                  hr_entry_api.delete_element_entry('ZAP',
                                                    l_effective_session_date,
                                                    l_element_entry_id);
               end if;
            exception
               when others then
                  commit_messages;
                  g_message_count := 0;
                  close c_batch_entries;
                  close c_batch_lines;
                  hr_utility.set_message(800,'PER_289522_CANNOT_RBK_BEE_LINE');
                  hr_utility.raise_error;
            end;

            -- change batch line status to 'unprocessed'
            --
            payplnk.g_payplnk_call := true;
            --
            update pay_batch_lines
            set    batch_line_status = 'U'
            where  batch_line_id = l_batch_line.batch_line_id;
            --
            payplnk.g_payplnk_call := false;

            l_assignments_processed := l_assignments_processed + 1;

          end if;

        end if;

        fetch c_batch_entries into l_element_entry_id, l_creator_type,
                                   l_creator_id, l_effective_session_date;

      end loop;

      -- if no entries were found for batch line, reset status

      if (c_batch_entries%notfound and l_entry_exists <> 'Y') then
         if (l_check_batch_id = 'N' or (l_check_batch_id ='Y'
                                        and l_reject_ent_not_removed <> 'Y')) then
             --
             payplnk.g_payplnk_call := true;
             --
             update pay_batch_lines
             set    batch_line_status = 'U'
             where  batch_line_id = l_batch_line.batch_line_id;
             --
             payplnk.g_payplnk_call := false;
             --
         else
             --
             commit_messages;
             g_message_count := 0;
             close c_batch_entries;
             close c_batch_lines;
             hr_utility.set_message(800,'PER_449031_CANNOT_RBK_BEE_ENR');
             hr_utility.raise_error;
             --
         end if;
      end if;

      close c_batch_entries;
      fetch c_batch_lines into l_batch_line;

    end loop;

    close c_batch_lines;

    if g_message_count = 0 then

      -- Following only applies to previous single threaded BEE
      -- processes.
      --
      if p_asg_action_id is null then
         -- -- Change batch header status to 'unprocessed'
         update pay_batch_headers
         set    batch_status = 'U'
         where  batch_id = p_batch_header_id;
         --
         update pay_batch_control_totals
         set    control_status = 'U'
         where  batch_id = p_batch_header_id;
         --
         for l_ctl_rec in csr_control_lines(p_batch_header_id) loop
           purge_rollback_messages(l_ctl_rec.batch_control_id,'C');
         end loop;
         --
         if p_leave_batch = 'N' then
           --
           -- The user wants the batch to be deleted from the database.
           payplnk.run_process(l_errbuf,
                               l_retcode,
                               l_business_group_id,
                               'PURGE',
                               p_batch_header_id);
           --
         end if;
         --
         hr_utility.set_message(801,'PAY_52013_MIX_ROLLBACK_SUCCESS');
         hr_utility.set_message_token('ASGN_COUNT', l_assignments_processed);
         g_message_count := g_message_count + 1;
         insert_rollback_message('H', p_batch_header_id, 'I', false);
         --
         -- commit;
         --
      end if;
      --
    else
      --
      if (p_asg_action_id is null and p_commit_all_or_nothing='N') then
         --
         update pay_batch_control_totals
         set    control_status = 'U'
         where  batch_id = p_batch_header_id;
         --
         for l_ctl_rec in csr_control_lines(p_batch_header_id) loop
           purge_rollback_messages(l_ctl_rec.batch_control_id,'C');
         end loop;
         --
         hr_utility.set_message(801,'PAY_52013_MIX_ROLLBACK_SUCCESS');
         hr_utility.set_message_token('ASGN_COUNT', l_assignments_processed);
         g_message_count := g_message_count + 1;
         insert_rollback_message('H', p_batch_header_id, 'I', false);
         --
      else
         rollback to RB;
      end if;
      --
    end if;
  else
    -- Following only applies to previous single threaded BEE
    -- processes.
    --
    if p_asg_action_id is null then
       g_message_count := g_message_count + 1;
       hr_utility.set_message(801,'PAY_52015_INVALID_BATCH');
       insert_rollback_message('H', p_batch_header_id, 'F', false);
    end if;
    --
    --
  end if;
  --
  commit_messages;
  --
  if g_message_count > 0  and p_asg_action_id is not null then
     -- Must manually reset global message counter, since concurrent
     -- manager does not start a new session for PL/SQL stored procedures.
     g_message_count := 0;
     --
     hr_utility.set_message(800,'PER_289522_CANNOT_RBK_BEE_LINE');
     hr_utility.raise_error;
     --
  end if;
  --
  -- Following only applies to previous single threaded BEE
  -- processes.
  --
  if p_asg_action_id is null then
     commit;
  end if;
  --
  g_message_count := 0;

end undo_mix;

--
-- undo_mix_asg
--

procedure undo_mix_asg(
  p_asg_action_id                    in number
) is
  --
  cursor csr_asg_act is
    select pbh.batch_id,
           pac.assignment_id,
           nvl(pbh.reject_if_results_exists,'Y') reject_if_results_exists,
           pbh.batch_status
      from pay_assignment_actions pac,
           pay_payroll_actions ppa,
           pay_batch_headers pbh
     where pac.assignment_action_id = p_asg_action_id
       and ppa.payroll_action_id = pac.payroll_action_id
       and pbh.batch_id = ppa.batch_id
       and ppa.action_type = 'BEE'
     union all
    select ppa.batch_id,
           pac.assignment_id,
           'Y' reject_if_results_exists,
           'T' batch_status
      from pay_assignment_actions pac,
           pay_payroll_actions ppa
     where pac.assignment_action_id = p_asg_action_id
       and ppa.payroll_action_id = pac.payroll_action_id
       and ppa.action_type = 'BEE'
       and not exists
           (select null
              from pay_batch_headers pbh1
             where pbh1.batch_id = ppa.batch_id);
  --
  cursor csr_reset_control_total (p_batch_id number) is
    select 'Y'
      from dual
     where exists
            (select null
               from pay_batch_control_totals pct
              where pct.batch_id = p_batch_id
                and pct.control_status <> 'U')
       and exists
            (select null
               from pay_batch_lines pbl
              where pbl.batch_id = p_batch_id
                and pbl.batch_line_status <> 'T')
       and exists
            (select null
               from pay_batch_headers pbh
              where pbh.batch_id = p_batch_id
                and pbh.batch_status = 'T');
  --
  cursor csr_control_lines (p_batch_id number) is
    select pct.batch_control_id
      from pay_batch_control_totals pct
     where pct.batch_id = p_batch_id;
  --
  l_ctl_rec csr_control_lines%ROWTYPE;
  l_rec_exists varchar2(1);
  l_rec csr_asg_act%ROWTYPE;
  --
  l_errbuf varchar2(1000);
  l_retcode number;
  --
  --
begin
  --
  hr_utility.set_location('pay_mix_rollback_pkg.undo_mix_asg',10);
  --
  open csr_asg_act;
  fetch csr_asg_act into l_rec;
  close csr_asg_act;
  --
  hr_utility.set_location('pay_mix_rollback_pkg.undo_mix_asg',20);
  --
  if l_rec.batch_status = 'T' then
     --
     undo_mix(
     p_errbuf                           => l_errbuf,
     p_retcode                          => l_retcode,
     p_batch_header_id                  => l_rec.batch_id,
     p_reject_if_run_results_exist      => l_rec.reject_if_results_exists,
     p_dml_mode                         => null,
     p_assignment_id                    => l_rec.assignment_id,
     p_asg_action_id                    => p_asg_action_id
     );
     --
     hr_utility.set_location('pay_mix_rollback_pkg.undo_mix_asg',30);
     --
     -- Now check o see if the batch lines have been changed. If so
     -- then reset the control totals.
     open csr_reset_control_total(l_rec.batch_id);
     fetch csr_reset_control_total into l_rec_exists;
     --
     if csr_reset_control_total%found then
        --
        hr_utility.set_location('pay_mix_rollback_pkg.undo_mix_asg',40);
        --
        for l_ctl_rec in csr_control_lines(l_rec.batch_id) loop
           purge_rollback_messages(l_ctl_rec.batch_control_id,'C');
        end loop;
        --
        payplnk.g_payplnk_call := true;
        --
        update pay_batch_control_totals
        set    control_status = 'U'
        where  batch_id = l_rec.batch_id;
        --
        payplnk.g_payplnk_call := false;
        --
     end if;
     close csr_reset_control_total;
     --
  end if;
  --
  hr_utility.set_location('pay_mix_rollback_pkg.undo_mix_asg',50);
  --
end;

--
-- set_status
--

procedure set_status(
  p_payroll_action_id               in number,
  p_leave_row                       in boolean
) is
  --
  cursor csr_asg_act is
    select pbh.batch_id,
           pbh.business_group_id,
           ppa.BATCH_PROCESS_MODE,
           nvl(pbh.purge_after_rollback,'N') purge_after_rollback
      from pay_payroll_actions ppa,
           pay_batch_headers pbh
     where ppa.payroll_action_id = p_payroll_action_id
       and pbh.batch_id = ppa.batch_id
       and ppa.action_type = 'BEE'
       and not exists
           (select null
              from pay_batch_lines pbl
             where pbl.batch_id = pbh.batch_id
               and pbl.batch_line_status = 'T');
  --
  l_rec            csr_asg_act%ROWTYPE;
  l_leave_batch    varchar2(30);
  --
  l_errbuf                 varchar2(2000);
  l_retcode                number;
  --
  --
begin
  --
  hr_utility.set_location('pay_mix_rollback_pkg.set_status',10);
  --
  open csr_asg_act;
  fetch csr_asg_act into l_rec;
  -- IF batch doesn't exists thenno need to reset the batch status.
  if csr_asg_act%notfound then
     close csr_asg_act;
     return;
  end if;
  --
  close csr_asg_act;
  --
  hr_utility.set_location('pay_mix_rollback_pkg.set_status',20);
  --
  -- Only purge the batch if the payroll action is purged.
  if (l_rec.purge_after_rollback = 'Y' and l_rec.BATCH_PROCESS_MODE = 'TRANSFER') then
     -- Purge the batch regarless of the status of the leave_row flag.
     -- and p_leave_row = false) then
     --
     hr_utility.set_location('pay_mix_rollback_pkg.set_status',30);
     --
     -- The user wants the batch to be deleted from the database.
     payplnk.run_process(l_errbuf,
                         l_retcode,
                         l_rec.business_group_id,
                         'PURGE',
                         l_rec.batch_id);
     --
     hr_utility.set_location('pay_mix_rollback_pkg.set_status',40);
     --
  else
     --
     hr_utility.set_location('pay_mix_rollback_pkg.set_status',50);
     -- Change batch header status to 'unprocessed'
     --
     purge_rollback_messages(l_rec.batch_id,'H');
     --
     update pay_batch_headers
     set    batch_status = 'U'
     where  batch_id = l_rec.batch_id;
     --
     hr_utility.set_location('pay_mix_rollback_pkg.set_status',60);
     --
  end if;
  --
  hr_utility.set_location('pay_mix_rollback_pkg.set_status',70);
  --
end;


--
-- run_results_exist
--

function run_results_exist(p_element_entry_id in number
                          ,p_effective_session_date in date default null
                          ,p_chk_rollback_upd in varchar default null) return boolean is

  l_results_found varchar2(1) := 'N';

  begin

    begin
      hr_utility.set_location('pay_mix_rollback_pkg.run_results_exist',10);

      if p_chk_rollback_upd = 'Y' then
         select 'Y' into l_results_found
         from pay_run_results prr,
              pay_assignment_actions paa,
              pay_payroll_actions ppa,
              pay_element_entries_f pee
         where prr.source_type = 'E'
         and pee.element_entry_id = p_element_entry_id
         and p_effective_session_date between pee.effective_start_date
                                      and pee.effective_end_date
         and prr.source_id = pee.element_entry_id
         and prr.status = 'P'
         and prr.assignment_action_id = paa.assignment_action_id
         and paa.payroll_action_id = ppa.payroll_action_id
         and ppa.date_earned between pee.effective_start_date
                             and pee.effective_end_date ;
      else
         select 'Y' into l_results_found
         from pay_run_results
         where source_type = 'E'
         and source_id = p_element_entry_id
         and status = 'P';
      end if;

    exception
      when no_data_found then
        null;

    end;

    if l_results_found = 'Y' then
      return true;
    else
      return false;
    end if;

end run_results_exist;


--
-- insert_rollback_message
--

procedure insert_rollback_message(
  p_level    in varchar2,
  p_batch_id in number,
  p_severity in varchar2,
  p_fail     in boolean
) is

l_line_text  pay_message_lines.line_text%type;
l_payroll_id number;

begin
  hr_utility.set_location('pay_mix_rollback_pkg.insert_rollback_message',10);

  if p_level = 'H' then -- error occurred at header level

    l_line_text := substrb(hr_utility.get_message, 1, 240);

  elsif p_level = 'L' then -- error occurred at line level

    l_line_text := substrb(hr_utility.get_message, 1, 240);

  end if;

  -- Store the message information in PL/SQL tables for committing at the end of the process.
  g_message_tbl(g_message_count) := l_line_text;
  g_message_level_tbl(g_message_count) := p_level;
  g_message_id_tbl(g_message_count) := p_batch_id;
  g_message_severity_tbl(g_message_count) := p_severity;

  if p_fail then

    -- Stop the process now.
    hr_utility.raise_error;

  end if;

end insert_rollback_message;


--
-- action_parameter
--

function action_parameter(p_param_name in varchar2)
return varchar2 is

   l_name      pay_action_parameters.parameter_name%type;
   param_value pay_action_parameters.parameter_value%type;

begin
  begin
    hr_utility.set_location('pay_mix_rollback_pkg.action_parameter',10);

    --  attempt to find value of the parameter in the action parameter table.
    select par.parameter_value
    into   param_value
    from   pay_action_parameters par
    where  par.parameter_name = p_param_name;

  exception
    when no_data_found then
      if(p_param_name = 'MAX_ERRORS_ALLOWED') then
        --  If we can't get the max errors allowed, we
        --  default to chunk_size - make recursive call
        --  to get this value.
        param_value := action_parameter('CHUNK_SIZE');
      end if;
  end;
--
   return (param_value);
--
end action_parameter;

--
-- commit_messages
--

procedure commit_messages is

i number;

begin
  hr_utility.set_location('pay_mix_rollback_pkg.commit_messages',10);

  for i in 1..g_message_count loop
    if g_message_tbl(i) is not null and g_message_id_tbl(i) is not null then
      insert into pay_message_lines(
        line_sequence,
        message_level,
        source_id,
        source_type,
        line_text)
        values(
        pay_message_lines_s.nextval,
        g_message_severity_tbl(i),
        g_message_id_tbl(i),
        g_message_level_tbl(i),
        g_message_tbl(i));
    end if;
  end loop;

  -- Empty global PL/SQL message tables
  for i in 1..g_message_count loop
    g_message_severity_tbl(i) := null;
    g_message_id_tbl(i) := null;
    g_message_level_tbl(i) := null;
    g_message_tbl(i) := null;
  end loop;

--
  -- commit;
--

  hr_utility.set_location('pay_mix_rollback_pkg.commit_messages',20);

end commit_messages;

--
-- purge_rollback_messages
--

procedure purge_rollback_messages(p_source_id in number, p_msg_type varchar2) is

begin
  hr_utility.set_location('pay_mix_rollback_pkg.purge_rollback_messages',10);

  delete from pay_message_lines
  where source_id = p_source_id
  and   source_type = p_msg_type;

  -- commit;

end purge_rollback_messages;


end pay_mix_rollback_pkg;

/
