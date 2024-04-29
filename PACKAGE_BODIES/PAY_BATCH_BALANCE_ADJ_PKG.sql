--------------------------------------------------------
--  DDL for Package Body PAY_BATCH_BALANCE_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BATCH_BALANCE_ADJ_PKG" AS
/* $Header: pybbautl.pkb 120.9 2006/05/26 11:17:28 jabubaka noship $ */

g_package  constant varchar2(33) := '  PAY_BATCH_BALANCE_ADJ_PKG.';

type varchar240_table is table of varchar2(240)
index by binary_integer;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< submit_conc_request >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This function is called from the BBA webadi interface to submit the
-- concurrent request for batch balance adjustment.
-- Returns the request id of the submitted request.
--
-- ----------------------------------------------------------------------------
function submit_conc_request
(
  p_business_group_id      in  number,
  p_mode                   in  varchar2,
  p_batch_id               in  number,
  p_wait                   in  varchar2 default 'N',
  p_act_parameter_group_id in  number   default null
) return number is
--
l_request_id    number := 0;
l_pac_id        pay_payroll_actions.payroll_action_id%TYPE;
l_batch_status  pay_balance_batch_headers.batch_status%TYPE := null;
l_proc          varchar2(72) := 'PAY_BATCH_BALANCE_ADJ_PKG.SUBMIT_CONC_REQUEST';
--
begin
--
  hr_utility.set_location('Entering ' || l_proc, 5);

  l_batch_status := batch_overall_status(p_batch_id);

  if not check_operation_allowed (p_batch_status => l_batch_status, p_process_mode => p_mode) then

    fnd_message.set_name('PAY', 'PAY_34292_BBABP_INV_OPERATION');
    fnd_message.set_token('BATCHOP', p_mode);
    fnd_message.set_token('STATUS',l_batch_status);
    fnd_message.raise_error;

  end if;

  --
  if p_mode in ('PURGE', 'TRANSFER', 'ROLLBACK', 'VALIDATE') then

      l_request_id :=  fnd_request.submit_request
                        ('PAY',
                         'PAYBBABP',
                          null,
                          null,
                          null,
                          p_mode,
                          p_batch_id,
                          null
                        );


  end if;

  if l_request_id = 0 then
     fnd_message.raise_error;
  else
    commit;
  end if;
  --

  hr_utility.set_location('Leaving ' || l_proc, 5);
  return (l_request_id);
--
End submit_conc_request;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< batch_overall_status >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This function derives the overall stauts of the batch. The overall status
-- is not just the batch status but also considers the status of the
-- batch groups.
--
-- ----------------------------------------------------------------------------
function batch_overall_status (p_batch_id in number)
return varchar2 is
--
valid_groups_exist       boolean := FALSE;
error_groups_exist       boolean := FALSE;
unprocessed_groups_exist boolean := FALSE;
transferred_groups_exist boolean := FALSE;
header_transferred       boolean := FALSE;
header_processing        boolean := FALSE;
l_proc   varchar2(72) := 'PAY_BATCH_BALANCE_ADJ_PKG.BATCH_OVERALL_STATUS';
--
cursor csr_status is
        select  pay_batch_balance_adj_pkg.batch_group_overall_status
                    (pabg.batch_id, pabg.batch_group_id) status
        from    pay_adjust_batch_groups pabg
        where   pabg.batch_id = p_batch_id
        union
        select  batch_status status
        from    pay_balance_batch_headers
        where   batch_id = p_batch_id
        union
        select  'Y' status
        from    pay_balance_batch_headers bth
        where   bth.batch_id = p_batch_id
        and     bth.batch_status = 'T'
        order by 1 desc;
        --
begin
--
hr_utility.set_location('Entering ' || l_proc, 5);

hr_utility.trace('Batch status for batch ' || p_batch_id);

for distinct_status in csr_status LOOP
  --
  if distinct_status.status = 'E' then
    hr_utility.trace('Errored batch groups exist');
    error_groups_exist := TRUE;
    exit; -- we do not need to know the rest
    --
  elsif distinct_status.status = 'U' then
    hr_utility.trace('Unprocessed batch groups exist');
    unprocessed_groups_exist := TRUE;
    --
  elsif distinct_status.status = 'T' then
    hr_utility.trace('Transferred batch groups exist');
    transferred_groups_exist := TRUE;
    --
  elsif distinct_status.status = 'V' then
    hr_utility.trace('Valid batch groups exist');
    valid_groups_exist := TRUE;
    --
  elsif distinct_status.status = 'Y' then
    hr_utility.trace('Batch header is transferred');
    header_transferred := TRUE;
    --
  elsif distinct_status.status in ('L','P') then
    hr_utility.trace('Batch in Processing state');
    header_processing := TRUE;
    --
  end if;
  --
  -- we do not need to know the rest if it is the following case.

  if (header_transferred and
      (unprocessed_groups_exist or valid_groups_exist or error_groups_exist))
     or (not header_transferred and error_groups_exist) then
     --
     exit;
     --
  end if;
--
end loop;
--
if header_processing then
  return 'P'; -- batch is currently under process.
elsif header_transferred
        and NOT unprocessed_groups_exist
        and NOT valid_groups_exist
        and NOT error_groups_exist then
  return 'T'; -- all groups (if exists) has been transferred.
elsif header_transferred then
  return 'ST'; -- some lines might not have transferred.
elsif error_groups_exist then
  return 'E'; -- there is at least one error group
elsif unprocessed_groups_exist
        and NOT transferred_groups_exist then
  return 'U'; -- there is at least one unprocessed line
elsif valid_groups_exist
        and NOT transferred_groups_exist
        and NOT unprocessed_groups_exist then
  return 'V'; -- all lines are valid
else
  return 'SM'; -- mismatch of statuses
end if;

hr_utility.set_location('Leaving ' || l_proc, 5);
--
end batch_overall_status;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< batch_group_overall_status >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This function derives the overall status of the batch group. The overall
-- status is not just the batch group status but also considers the status of
-- the batch lines.
--
-- ----------------------------------------------------------------------------
function batch_group_overall_status
  ( p_batch_id       in  number,
    p_batch_group_id in  number )
return varchar2 is
--
l_proc   varchar2(72) := 'PAY_BATCH_BALANCE_ADJ_PKG.BATCH_GROUP_OVERALL_STATUS';
--
valid_lines_exist       boolean := FALSE;
error_lines_exist       boolean := FALSE;
unprocessed_lines_exist boolean := FALSE;
transferred_lines_exist boolean := FALSE;
group_transferred       boolean := FALSE;
group_processing        boolean := FALSE;
--
cursor csr_status is
        select  pabl.batch_line_status status
        from    pay_adjust_batch_lines pabl
        where   pabl.batch_id = p_batch_id
        and     pabl.batch_group_id = p_batch_group_id
        union
        select  batch_group_status status
        from    pay_adjust_batch_groups
        where   batch_id = p_batch_id
        and     batch_group_id = p_batch_group_id
        union
        select  'Y' status
        from    pay_adjust_batch_groups
        where   batch_group_id = p_batch_group_id
        and     batch_id = p_batch_id
        and     batch_group_status = 'T'
        order by 1 desc;
        --
begin
--
hr_utility.set_location('Entering ' || l_proc, 5);
hr_utility.trace('Status for batch group ' || p_batch_group_id);

for distinct_status in csr_status LOOP
  --
  if distinct_status.status = 'E' then
    hr_utility.trace('Error lines exist');
    error_lines_exist := TRUE;
    exit; -- we do not need to know the rest
    --
  elsif distinct_status.status = 'U' then
    hr_utility.trace('Unprocessed lines exist');
    unprocessed_lines_exist := TRUE;
    --
  elsif distinct_status.status = 'T' then
    hr_utility.trace('Transferred lines exist');
    transferred_lines_exist := TRUE;
    --
  elsif distinct_status.status = 'V' then
      hr_utility.trace('Valid lines exist');
    valid_lines_exist := TRUE;
    --
  elsif distinct_status.status = 'Y' then
    hr_utility.trace('Batch group is transferred');
    group_transferred := TRUE;
    --
  elsif distinct_status.status in ('L','P') then
    hr_utility.trace('Batch group is currently loaded');
    group_processing := TRUE;
    --
  end if;
  --
  -- we do not need to know the rest if it is the following case.
  if (group_transferred and
      (unprocessed_lines_exist or valid_lines_exist or error_lines_exist))
     or (not group_transferred and error_lines_exist) then
     --
     exit;
     --
  end if;
--
end loop;
--
if group_processing then
  return 'P'; -- batch group is currently under process.
elsif group_transferred
        and NOT unprocessed_lines_exist
        and NOT valid_lines_exist
        and NOT error_lines_exist then
  return 'T'; -- all lines (if exists) has been transferred.
elsif group_transferred then
  return 'ST'; -- some lines might not have transferred.
elsif error_lines_exist then
  return 'E'; -- there is at least one error group
elsif unprocessed_lines_exist
        and NOT transferred_lines_exist then
  return 'U'; -- there is at least one unprocessed line
elsif valid_lines_exist
        and NOT transferred_lines_exist
        and NOT unprocessed_lines_exist then
  return 'V'; -- all lines are valid
else
  return 'SM'; -- mismatch of statuses
end if;
--
hr_utility.set_location('Leaving ' || l_proc, 100);
--
end batch_group_overall_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< purge >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedures deletes all records associated with the batch balance
-- adjustment tables and the pay_message_lines table.
--
-- ----------------------------------------------------------------------------
--
procedure purge
  ( p_batch_id       in  number,
    p_batch_group_id in number)
is
--
l_proc   varchar2(72) := 'PAY_BATCH_BALANCE_ADJ_PKG.PURGE';
--
cursor csr_batch_lines is
   select pabl.batch_line_id
     from pay_adjust_batch_lines  pabl
    where pabl.batch_id = p_batch_id
    and   pabl.batch_group_id = nvl(p_batch_group_id, pabl.batch_group_id) ;
--
cursor csr_batch_groups is
   select pabg.batch_group_id
     from pay_adjust_batch_groups pabg
    where pabg.batch_id = p_batch_id
    and   pabg.batch_group_id = nvl(p_batch_group_id, pabg.batch_group_id) ;

--
begin
--
  hr_utility.set_location('Entering: '||l_proc, 5);

  hr_utility.trace('Purging batch '||p_batch_id);

  hr_utility.trace('Purging batch lines of the batch');


  for cssr in csr_batch_lines loop

    --
    -- Delete all messages of the batch line
    --
    delete
      from pay_message_lines
     where source_type = 'I'
       and source_id = cssr.batch_line_id;
    --

    --
    -- Delete the batch line
    --

    delete
      from pay_adjust_batch_lines
     where batch_line_id = cssr.batch_line_id;

  end loop;

  hr_utility.trace('Purging batch groups of the batch');

  for cssr in csr_batch_groups loop

    --
    -- Delete all messages of the batch group
    --
    delete
      from pay_message_lines
     where source_type = 'G'
       and source_id = cssr.batch_group_id;
    --

    --
    -- Delete the batch group
    --

    delete
      from pay_adjust_batch_groups
     where batch_group_id = cssr.batch_group_id;

  end loop;


  hr_utility.trace('Purging the batch header');

  if p_batch_group_id is null then

    --
    -- Deletes all messages of the batch header
    --
    delete
      from pay_message_lines
     where source_type = 'H'
       and source_id = p_batch_id;
    --

    --
    -- Delete the batch header
    --

    delete
      from pay_balance_batch_headers
     where batch_id = p_batch_id;

  end if;

  hr_utility.set_location('Leaving: '||l_proc, 5);
  commit;
--
end purge;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_operation_allowed >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- Given the current batch status and the required processing mode this
-- function determines if its a valid operation or not.
--
-- ----------------------------------------------------------------------------
--
function check_operation_allowed
   ( p_batch_status in varchar2 ,
     p_process_mode in varchar2 )
return boolean is
--
l_proc   varchar2(72) := 'PAY_BATCH_BALANCE_ADJ_PKG.CHECK_OPERATION_ALLOWED';
--
begin
--
  hr_utility.set_location('Entering: '||l_proc, 5);

  -- 'L' stands for Loading (Processing)
  if (p_batch_status = 'T' and p_process_mode in ('TRANSFER')) or
     (p_batch_status = 'P') or
     (p_batch_status = 'L') then
     return false;
  else
     return true;
  end if;

  hr_utility.set_location('Leaving: '||l_proc, 5);
--
end check_operation_allowed;
-- ----------------------------------------------------------------------------
-- |--------------------------------< rollback_batch >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedures rollbacks all the actions of the given batch id.
--
-- ----------------------------------------------------------------------------
--
procedure rollback_batch
  ( p_batch_id       in  number,
    p_batch_group_id in  number )
is
--
l_payroll_action_id  pay_payroll_actions.payroll_action_id%type;
l_proc   varchar2(72) := 'PAY_BATCH_BALANCE_ADJ_PKG.ROLLBACK_BATCH';

l_message_source_id_tbl     hr_entry.number_table;
l_message_source_type_tbl   hr_entry.varchar2_table;
l_message_level_tbl         hr_entry.varchar2_table;
l_message_text_tbl          varchar240_table;
l_count                     binary_integer := 0;
l_error_text                pay_message_lines.line_text%type;

--
cursor csr_batch_groups is
select batch_group_id
from   pay_adjust_batch_groups
where  batch_id = p_batch_id
and    batch_group_id = nvl(p_batch_group_id, batch_group_id)
and    batch_group_status = 'T';
--
cursor csr_payroll_action (p_batch_group_id number) is
    select pact.payroll_action_id
      from pay_payroll_actions pact
     where pact.batch_id = p_batch_group_id
       and pact.action_type = 'B';
       --and pact.batch_process_mode = 'TRANSFER';
--
begin
--
  hr_utility.set_location('Entering: '||l_proc, 10);

  l_count := 0;

  for lcsr in csr_batch_groups loop

    open csr_payroll_action (p_batch_group_id => lcsr.batch_group_id);
    fetch csr_payroll_action into l_payroll_action_id;
    close csr_payroll_action;

    if l_payroll_action_id is not null then

        begin
          hr_utility.trace('Rollback batch group ' || lcsr.batch_group_id);
          hr_utility.trace('Rollback payroll action ' || l_payroll_action_id);

          savepoint RG;
          py_rollback_pkg.rollback_payroll_action(l_payroll_action_id,'ROLLBACK',FALSE);
          commit;

          update pay_adjust_batch_groups
          set    batch_group_status = 'U'
          where  batch_group_id = lcsr.batch_group_id;

          update pay_adjust_batch_lines
          set    batch_line_status = 'U'
          where  batch_group_id = lcsr.batch_group_id;

          commit;

          l_count := l_count + 1;
          l_message_level_tbl(l_count) := 'I';
          l_message_source_type_tbl(l_count) := 'G';
          l_message_source_id_tbl(l_count) := lcsr.batch_group_id;

          hr_utility.set_message(801,'PAY_34293_BBABP_BTCHGRP_RB');
          l_error_text := substrb(hr_utility.get_message, 1, 240);

          l_message_text_tbl(l_count) := l_error_text;


        exception

          when others then

            rollback to RG;

            l_count := l_count + 1;
            l_message_level_tbl(l_count) := 'W';
            l_message_source_type_tbl(l_count) := 'G';
            l_message_source_id_tbl(l_count) := lcsr.batch_group_id;

            hr_utility.set_message(801,'PAY_34294_BBABP_ERR_IN_PROC');
            hr_utility.set_message_token('PROC', l_proc);
            l_error_text := substrb(hr_utility.get_message || ' ' || sqlerrm, 1, 240);
            l_message_text_tbl(l_count) := l_error_text;

        end;

    end if;

  end loop;

  hr_utility.set_location(l_proc, 30);

  begin

    for i in 1..l_count loop

       if l_message_text_tbl(i) is not null then
       --
          insert into pay_message_lines
           (line_sequence,
            payroll_id,
            message_level,
            source_id,
            source_type,
            line_text )
          values
           (pay_message_lines_s.nextval,
            null,
            l_message_level_tbl(i),
            l_message_source_id_tbl(i),
            l_message_source_type_tbl(i),
            l_message_text_tbl(i)
           );
       --
       end if;

    end loop;

  hr_utility.set_location(l_proc, 40);

  --
   exception
     when no_data_found then
     null;
  end;

  commit;

  hr_utility.set_location('Leaving : ' || l_proc, 100);
--
end rollback_batch;
--

--
------------------------------------------------------------------------------
--|--------------------------------< validate_and_transfer >-----------------|
------------------------------------------------------------------------------
--
-- Description:
-- This procedure does validate or transfer based on the batch_process_mode
--   specified. This is internally called by validate_batch and transfer_batch
--------------------------------------------------------------------------------
--
procedure validate_and_transfer
            (p_batch_id in number,
             p_batch_group_id in number,
             p_batch_process_mode in varchar2)
             is




  l_line_error                  boolean := FALSE;
  invalid_batch_group_details   EXCEPTION;
  process_batch_failed          EXCEPTION;
  l_proc varchar2(100);
  status_T number := 0;
  status_E number := 0;
  l_element_link_id number := 0;

  dummy_consolidation_id   pay_consolidation_sets.consolidation_set_id%type;
  dummy_payroll_id         pay_all_payrolls_f.payroll_id%type;
  dummy_msg_source_id      pay_message_lines.source_id%type;

-- Temperorary table for storing error messages and used for later putting into
--    pay_message_lines
  l_message_source_id_tbl       hr_entry.number_table;
  l_message_source_type_tbl     hr_entry.varchar2_table;
  l_message_level_tbl           hr_entry.varchar2_table;
  l_message_text_tbl            varchar240_table;
  l_count                       binary_integer := 0;
  l_error_text                  pay_message_lines.line_text%type;
  l_payroll_action_id           pay_payroll_actions.payroll_action_id%type;
  p_batch_name                  pay_balance_batch_headers.batch_name%type;

--

--

--cursors needed
  cursor csr_batch_groups is
   select batch_group_id, consolidation_set_id,
          payroll_id, effective_date, prepay_flag
     from pay_adjust_batch_groups
    where batch_id = p_batch_id
      and batch_group_id = nvl(p_batch_group_id, batch_group_id)
      and batch_group_status not in ('L','P','T');
--

--
  cursor csr_batch_lines(p_arg_batch_group_id  pay_adjust_batch_groups.batch_group_id%type) is
   select *
     from pay_adjust_batch_lines
    where batch_id = p_batch_id
      and batch_group_id = p_arg_batch_group_id;
--

 cursor batch_grp_stts(batch_status_arg  pay_adjust_batch_groups.batch_group_status%type) is
     select 1 from pay_adjust_batch_groups
                where batch_group_status = batch_status_arg
                  and batch_id = p_batch_id;
--
 begin

   update pay_balance_batch_headers
     set batch_status = 'P'
   where batch_id = p_batch_id;

  select batch_name into p_batch_name
    from pay_balance_batch_headers
   where batch_id = p_batch_id;

  commit;

 for group_csr in csr_batch_groups loop
  begin

   update pay_adjust_batch_lines
      set batch_line_status = 'U'
    where batch_group_id = group_csr.batch_group_id;

   update pay_adjust_batch_groups
            set batch_group_status = 'P'
    where batch_group_id = group_csr.batch_group_id;

--  deleting all the message lines for this group
   delete from pay_message_lines
         where source_type = 'G'
           and source_id = group_csr.batch_group_id;
--deleting all the message lines for the batch lines in this group
   for line_csr in csr_batch_lines(group_csr.batch_group_id) loop
       delete from pay_message_lines
             where source_type = 'I'
               and source_id = line_csr.batch_line_id;
   end loop;

-- committing at this stage so the monitor request region
--       can pick it up to show the status
   commit;

   savepoint main_SP;

   l_payroll_action_id := 0;


-- Checking the payroll id and consolidation set id
--  are valid or not.  If not valid then raise exception here
  --
    begin
    select pcs.consolidation_set_id into dummy_consolidation_id
      from pay_consolidation_sets pcs
     where group_csr.consolidation_set_id = pcs.consolidation_set_id;
    exception
       when no_data_found then
                 raise invalid_batch_group_details;
    end;

    --   invalid consolidation_set_id,....  raising Exception

    begin
      select papf.payroll_id into dummy_payroll_id
        from pay_all_payrolls_f papf
       where group_csr.payroll_id = papf.payroll_id
		  AND  group_csr.effective_date between
                 papf.effective_start_date and papf.effective_end_date;
    exception
       when no_data_found then
                  raise invalid_batch_group_details;
    end;
    --   invlaid payroll_id,...... raising Exception
  --
   begin
    l_payroll_action_id := PAY_BAL_ADJUST.init_batch(
                                                    p_batch_name,
                                                    group_csr.effective_date,
                                                    group_csr.consolidation_set_id,
                                                    group_csr.payroll_id,
                                                    'B', -- B for balance adjustment
                                                    'NO_COMMIT', --to avoid process_batch commiting
                                                    group_csr.prepay_flag
                                                    );
   exception
     when others then
        hr_utility.set_message(801,'HR_6614_PAY_NO_TIME_PERIOD');
        l_error_text := substrb(hr_utility.get_message, 1, 240);
        insert into pay_message_lines
               (line_sequence,
                payroll_id,
                message_level,
                source_id,
                source_type,
                line_text)
             values
               (pay_message_lines_s.nextval,
                null,
                'F',
                group_csr.batch_group_id,
                'G',
                l_error_text);
        raise process_batch_failed;
   end;

   -- Updating the payroll action table
   update pay_payroll_actions
      set batch_id = group_csr.batch_group_id
    where payroll_action_id=l_payroll_action_id
      and action_type ='B';

-- Reset the temperorary PL/SQL message table
  l_count := 0;

  l_line_error := FALSE;


  for line_csr in csr_batch_lines(group_csr.batch_group_id) loop
   savepoint SP2;
      --calling adjust_balance from pybaladj.pkb
   begin

    /*
    Here caching of the element_link_id for a combination can improve performance
    */
    l_element_link_id := hr_entry_api.get_link(
                                        p_assignment_id => line_csr.ASSIGNMENT_ID,
                                        p_element_type_id => line_csr.ELEMENT_TYPE_ID,
                                        p_session_date => group_csr.effective_date);


    PAY_BAL_ADJUST.adjust_balance
                   (
                    p_batch_id			    =>  l_payroll_action_id,
                    p_assignment_id		    =>  line_csr.ASSIGNMENT_ID,
                  --p_element_link_id		=>  line_csr.ELEMENT_LINK_ID,
                    p_element_link_id		=>  l_element_link_id,
                    p_input_value_id1		=>  line_csr.INPUT_VALUE_ID1,
                    p_input_value_id2		=>  line_csr.INPUT_VALUE_ID2,
                    p_input_value_id3		=>  line_csr.INPUT_VALUE_ID3,
                    p_input_value_id4		=>  line_csr.INPUT_VALUE_ID4,
                    p_input_value_id5		=>  line_csr.INPUT_VALUE_ID5,
                    p_input_value_id6		=>  line_csr.INPUT_VALUE_ID6,
                    p_input_value_id7		=>  line_csr.INPUT_VALUE_ID7,
                    p_input_value_id8		=>  line_csr.INPUT_VALUE_ID8,
                    p_input_value_id9		=>  line_csr.INPUT_VALUE_ID9,
                    p_input_value_id10		=>  line_csr.INPUT_VALUE_ID10,
                    p_input_value_id11		=>  line_csr.INPUT_VALUE_ID11,
                    p_input_value_id12		=>  line_csr.INPUT_VALUE_ID12,
                    p_input_value_id13		=>  line_csr.INPUT_VALUE_ID13,
                    p_input_value_id14		=>  line_csr.INPUT_VALUE_ID14,
                    p_input_value_id15		=>  line_csr.INPUT_VALUE_ID15,
                    p_entry_value1		=>  line_csr.ENTRY_VALUE1,
                    p_entry_value2		=>  line_csr.ENTRY_VALUE2,
                    p_entry_value3		=>  line_csr.ENTRY_VALUE3,
                    p_entry_value4		=>  line_csr.ENTRY_VALUE4,
                    p_entry_value5		=>  line_csr.ENTRY_VALUE5,
                    p_entry_value6		=>  line_csr.ENTRY_VALUE6,
                    p_entry_value7		=>  line_csr.ENTRY_VALUE7,
                    p_entry_value8		=>  line_csr.ENTRY_VALUE8,
                    p_entry_value9		=>  line_csr.ENTRY_VALUE9,
                    p_entry_value10		=>  line_csr.ENTRY_VALUE10,
                    p_entry_value11		=>  line_csr.ENTRY_VALUE11,
                    p_entry_value12		=>  line_csr.ENTRY_VALUE12,
                    p_entry_value13		=>  line_csr.ENTRY_VALUE13,
                    p_entry_value14		=>  line_csr.ENTRY_VALUE14,
                    p_entry_value15		=>  line_csr.ENTRY_VALUE15,

                    --Costing Information
                    p_balance_adj_cost_flag	=>  line_csr.BALANCE_ADJ_COST_FLAG,
                    p_cost_allocation_keyflex_id=>  line_csr.COST_ALLOCATION_KEYFLEX_ID,
                    p_attribute_category	=>  line_csr.ATTRIBUTE_CATEGORY,
                    p_attribute1		=> line_csr.ATTRIBUTE1,
                    p_attribute2		=> line_csr.ATTRIBUTE2,
                    p_attribute3		=> line_csr.ATTRIBUTE3,
                    p_attribute4		=> line_csr.ATTRIBUTE4,
                    p_attribute5		=> line_csr.ATTRIBUTE5,
                    p_attribute6		=> line_csr.ATTRIBUTE6,
                    p_attribute7		=> line_csr.ATTRIBUTE7,
                    p_attribute8		=> line_csr.ATTRIBUTE8,
                    p_attribute9		=> line_csr.ATTRIBUTE9,
                    p_attribute10		=> line_csr.ATTRIBUTE10,
                    p_attribute11		=> line_csr.ATTRIBUTE11,
                    p_attribute12		=> line_csr.ATTRIBUTE12,
                    p_attribute13		=> line_csr.ATTRIBUTE13,
                    p_attribute14		=> line_csr.ATTRIBUTE14,
                    p_attribute15		=> line_csr.ATTRIBUTE15,
                    p_attribute16		=> line_csr.ATTRIBUTE16,
                    p_attribute17		=> line_csr.ATTRIBUTE17,
                    p_attribute18		=> line_csr.ATTRIBUTE18,
                    p_attribute19		=> line_csr.ATTRIBUTE19,
                    p_attribute20		=> line_csr.ATTRIBUTE20,
                    p_run_type_id		=> line_csr.RUN_TYPE_ID,
                    p_original_entry_id	=>  line_csr.ORIGINAL_ENTRY_ID,
                    p_tax_unit_id		=>  line_csr.TAX_UNIT_ID
                   );

   exception
     when others then

      --  enter error msg in to PL/SQL msg table at line level
       l_count := l_count + 1;
       l_message_level_tbl(l_count) := 'F';
       l_message_source_type_tbl(l_count) := 'I';
       l_message_source_id_tbl(l_count) := line_csr.batch_line_id;
       --hr_utility.set_message(801, 'PAY_34294_BBABP_ERR_IN_PROC');
       -- message is "Error in test"
       --l_proc := 'PAY_BAL_ADJUST.adjust_balance';
       --hr_utility.set_message_token('PROC', l_proc);
       l_error_text := substrb(hr_utility.get_message || ' ' ||
                   sqlerrm, 1, 240);
       l_message_text_tbl(l_count) := l_error_text;
      --
       l_line_error := TRUE;
      rollback to SP2;
  end;
  end loop;

  begin
    PAY_BAL_ADJUST.process_batch(l_payroll_action_id);
    -- put a message in PL/SQL msg tbl at group level

  exception
     when others
       then
          l_count := l_count + 1;
          l_message_level_tbl(l_count) := 'F';
          l_message_source_type_tbl(l_count) := 'G';
          l_message_source_id_tbl(l_count) := group_csr.batch_group_id;

          --hr_utility.set_message(801, 'PAY_34294_BBABP_ERR_IN_PROC');
          -- message is "Error in test"
          --l_proc := 'PAY_BAL_ADJUST.process_batch';
          --hr_utility.set_message_token('PROC', l_proc);
          l_error_text := substrb(hr_utility.get_message || ' ' ||
                   sqlerrm, 1, 240);

          l_message_text_tbl(l_count) := l_error_text;
          raise process_batch_failed;

  end;

  if (l_line_error = TRUE) then
    rollback to main_SP;
  end if;

  -- the batch operation was a validate so we rollback
  if (p_batch_process_mode = 'V' AND l_line_error = FALSE) then
    rollback to main_SP;
  end if;

  for i in 1..l_count loop
    -- for each error message
    update pay_adjust_batch_lines
       set batch_line_status = 'E'
     where batch_line_id = l_message_source_id_tbl(i)
       and batch_group_id = group_csr.batch_group_id;
  end loop;


  /*
  	Any remainging unprocessed lines we set the status as `V` or `T` if line_error is FALSE otherwise as `V`.
  	Update the batch_group status as `V` or `T` if line_error is FALSE otherwise as `E`.
  */

  if (l_line_error = FALSE) then
 ---
   update pay_adjust_batch_lines
      set batch_line_status = p_batch_process_mode
    where batch_line_status = 'U'
      and batch_group_id  =  group_csr.batch_group_id;
 --
   update pay_adjust_batch_groups
      set batch_group_status  =  p_batch_process_mode
    where batch_group_id  =  group_csr.batch_group_id;
 ---
  elsif (l_line_error = TRUE) then
 ---
   update pay_adjust_batch_lines
      set batch_line_status = 'V'
    where batch_line_status = 'U'
      and batch_group_id  =  group_csr.batch_group_id;
 --
   update pay_adjust_batch_groups
      set batch_group_status = 'E'
    where batch_group_id  =  group_csr.batch_group_id;
 ---
  end if;

  /*
    For each error message in PL/SQL table create an entry in pay_message_line
  */
  for j in 1..l_count loop
   --
   if l_message_text_tbl(j) is not null then
    insert into pay_message_lines
      (line_sequence,
       payroll_id,
       message_level,
       source_id,
       source_type,
       line_text)
     values
      (pay_message_lines_s.nextval,
       null,
       l_message_level_tbl(j),
       l_message_source_id_tbl(j),
       l_message_source_type_tbl(j),
       l_message_text_tbl(j)
       );
   end if;
   --
  end loop; -- for inserting into pay_message_lines

  commit;

  -- the main exception block handling errors in initial checking like if payroll_id, consolidation_id
   --   are valid.
  exception
   when invalid_batch_group_details
     then
       rollback to main_SP;
       --
   when process_batch_failed
     then
       update pay_adjust_batch_groups
          set batch_group_status = 'E'
        where batch_group_id  =  group_csr.batch_group_id;
      --put a message against batch_group in pay_message_lines at group_level
      begin
       select pml.source_id id into dummy_msg_source_id
         from pay_message_lines pml
        where pml.source_id = group_csr.batch_group_id
          and source_type = 'G';
      exception
        when no_data_found  then
	    hr_utility.set_message(801, 'PAY_34294_BBABP_ERR_IN_PROC');
        l_proc := 'validating the batch group';
        hr_utility.set_message_token('PROC', l_proc);
        l_error_text := substrb(hr_utility.get_message || ' ' ||
                   sqlerrm, 1, 240);
         insert into pay_message_lines
               (line_sequence,
                payroll_id,
                message_level,
                source_id,
                source_type,
                line_text)
             values
               (pay_message_lines_s.nextval,
                null,
                'F',
                group_csr.batch_group_id,
                'G',
                l_error_text);


        end;
      --

       commit;
       --
 end; -- batch groups end
  end loop; -- batch groups end loop



  open batch_grp_stts('T');
  -- check if there are any transferred group
  fetch batch_grp_stts into status_T;
  close batch_grp_stts;
  open batch_grp_stts('E');
  -- check if there are any errored group
  fetch batch_grp_stts into status_E;
  close batch_grp_stts;

  if (status_T = 1) then
      update pay_balance_batch_headers
         set batch_status = 'T'
       where batch_id = p_batch_id;
  elsif ((status_T = 0) and (status_E = 1)) then
     update pay_balance_batch_headers
        set batch_status = 'E'
      where batch_id = p_batch_id;
  elsif ((status_T = 0) and (status_E = 0)) then
     update pay_balance_batch_headers
        set batch_status = 'V'
      where batch_id = p_batch_id;
  end if;
 end validate_and_transfer;  -- end of procedure
--
--
--

------------------------------------------------------------------------------
--|--------------------------------< validate_batch >-----------------|
------------------------------------------------------------------------------
--
-- Description:
-- This procedure validates the batch specified
--------------------------------------------------------------------------------
procedure validate_batch
(p_batch_id in number,
 p_batch_group_id in number
 )is
 begin

    validate_and_transfer(p_batch_id,
                          p_batch_group_id,
			  'V');

end validate_batch;
--

------------------------------------------------------------------------------
--|--------------------------------< transfer_batch >-----------------|
------------------------------------------------------------------------------
--
-- Description:
-- This procedure transfers the batch specified
--------------------------------------------------------------------------------
procedure transfer_batch(p_batch_id in number,
                   p_batch_group_id in number)
             is
begin
       validate_and_transfer (p_batch_id,
                           p_batch_group_id,
			   'T'
                            );
end transfer_batch;
--



-- ----------------------------------------------------------------------------
-- |-----------------------------< run_process >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- This procedure is used in the executable of the bba process.
--
-- ----------------------------------------------------------------------------
--
procedure run_process
(errbuf                  out     nocopy varchar2,
 retcode                 out     nocopy number,
 p_batch_operation       in      varchar2,
 p_batch_id              in      number,
 p_batch_group_id        in      number
) is
--
l_proc  varchar2(72) := 'pay_batch_balance_adj_pkg.run_process';
l_batch_status  pay_balance_batch_headers.batch_status%type;
--
begin
--
 hr_utility.set_location('Entering ' || l_proc, 10);

 savepoint rprc;

 l_batch_status := batch_overall_status(p_batch_id => p_batch_id);

 if not check_operation_allowed (p_batch_status => l_batch_status, p_process_mode => p_batch_operation) then

      hr_utility.set_location('Leaving: '||l_proc, 10);
      fnd_message.set_name('PAY','PAY_34292_BBABP_INV_OPERATION');
      fnd_message.set_token('BATCHOP', p_batch_operation);
      fnd_message.set_token('STATUS', l_batch_status);
      fnd_message.raise_error;

  end if;

 hr_utility.set_location(l_proc,20);

 if p_batch_operation = 'ROLLBACK' then

   hr_utility.set_location(l_proc,30);

   pay_batch_balance_adj_pkg.rollback_batch
           ( p_batch_id => p_batch_id,
             p_batch_group_id => p_batch_group_id );
   hr_utility.set_location(l_proc,40);

 elsif p_batch_operation = 'PURGE' then

   hr_utility.set_location(l_proc,50);

   pay_batch_balance_adj_pkg.purge
           ( p_batch_id => p_batch_id,
             p_batch_group_id => p_batch_group_id );

   hr_utility.set_location(l_proc,60);

 elsif p_batch_operation = 'VALIDATE' then

   hr_utility.set_location(l_proc,70);

   pay_batch_balance_adj_pkg.validate_batch
           ( p_batch_id => p_batch_id,
             p_batch_group_id => p_batch_group_id );
    hr_utility.set_location(l_proc,80);

 elsif p_batch_operation = 'TRANSFER' then

   hr_utility.set_location(l_proc,90);

   pay_batch_balance_adj_pkg.transfer_batch
           ( p_batch_id => p_batch_id,
             p_batch_group_id => p_batch_group_id );
    hr_utility.set_location(l_proc,100);
 end if;

 hr_utility.set_location(l_proc,110);

 errbuf  := null;
 retcode := 0;

 hr_utility.set_location('Leaving ' || l_proc, 120);
--
exception
   when others then
      rollback to rprc;
      errbuf  := sqlerrm;
      retcode := 2;
      hr_utility.set_location(l_proc,130);
      raise;
 --
end run_process;
--
END PAY_BATCH_BALANCE_ADJ_PKG;

/
