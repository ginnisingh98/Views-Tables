--------------------------------------------------------
--  DDL for Package Body PAY_STANDARD_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_STANDARD_CHECK" AS
/* $Header: pystdchk.pkb 120.2 2006/01/30 07:08:56 alogue noship $ */

cursor csr_relevant_total_chk(l_batch_id in number,
                              l_meaning in varchar2) is
       select 'X'
       from pay_input_values_f piv,
       hr_lookups hrl,
       pay_batch_lines pbl

       where l_meaning = piv.name             -- restrict to input value parameter
       and piv.name = hrl.meaning             -- join piv-hrl on name of input value

       and hrl.lookup_type = 'CONTROL_TYPE'   -- restrict to relevant lookup
       and hrl.lookup_code like '_TOTAL_COLUMN_%'    -- must be a standard total

       and pbl.element_type_id = piv.element_type_id -- join piv-pbl on element_type_id
       and pbl.batch_id = l_batch_id ;                -- restrict to batch_id parameter
--  and effective_date_condition. depends on wether its the effective date or sysdate thats inportant for processing
-- probably the effective date - just use pay_input_values


-- function to wrap up csr_relevant_total_chk. This is called by check_control but
-- also by the BEE form.

function relevant_total_chk(p_batch_id in number,p_meaning in varchar2) return boolean
is
--     success or failure of cursor
l_csr_result varchar2(1);

begin
  open csr_relevant_total_chk(p_batch_id,p_meaning);
  fetch csr_relevant_total_chk into l_csr_result;

  if csr_relevant_total_chk%NOTFOUND then --  dont even attempt summation.
       close csr_relevant_total_chk;
       return false;
  else
       close csr_relevant_total_chk;
       return true;
  end  if;

end relevant_total_chk;

 -- NAME
 -- pay_user_check.check_control
 --
 -- DESCRIPTION
 -- Given a batch id it will carry out any standard totals
 -- and insert any necessary messages into the message table and
 -- update statuses that are required. The p_standard_status is updated
 -- to true to signify that the control total has been dealt with
 -- at this point. If the control total is not
 -- recognised as standard then no action is taken.

--



procedure check_control
(
p_batch_id        in     	number,
p_control_type    in     	varchar2,
p_control_total   in     	varchar2,
p_std_status      out  nocopy 	varchar2,
p_std_message     out  nocopy 	varchar2
) is

-- cursor to return all the distinct elements in a given batch
cursor csr_distinct_elements(l_batch_id in number) is
       select distinct element_type_id, element_name
       from pay_batch_lines
       where batch_id=l_batch_id;

-- cursor to return an ordered list of input value names according to
-- the criteria used by the BEE form for associating input values with
-- pay_batch_lines columns

cursor csr_ordered_input_values(l_element_type_id in number) is
       select piv.name
       from pay_input_values_f piv
       where piv.element_type_id = l_element_type_id
       and sysdate between piv.effective_start_date and piv.effective_end_date
       order by piv.display_sequence, piv.name;


--     for totals
l_running_total number := 0;
l_element_total number;
--     for the dynamic sql statements used in totalling
l_sql_stat varchar2(1000);
--     for a single batch line
l_batch_line pay_batch_lines%rowtype;
--     for the (translated) meanings from hr_lookups
l_meaning hr_lookups.meaning%TYPE := null;
--     for the number of lines in a batch
l_n_lines number := 0;
--     for the column of pay_batch_lines holding the values to be summed
l_value_number number;
--     batches bus grp id
l_business_group_id number;
--     status of BEE_IV_UPG upgrade
l_bee_iv_upgrade pay_upgrade_status.status%type;

--
--
begin

hr_utility.set_location('pay_std_check::check_control',1);


p_std_status := 'C';
--
-- Control code exists (as checked in calling routine) so we can select the meaning
--
select hlk.meaning into l_meaning
from hr_lookups hlk
where   hlk.lookup_type = 'CONTROL_TYPE'
and     hlk.lookup_code = p_control_type;

-- Deal with special values of p_control_type

if(p_control_type='_COUNT_LINES_') then

    p_std_status := 'V';  -- set to valid to signify the total will be interpreted
                         -- as a standard control

-- get number of lines in batch

    select count(*) into l_n_lines
    from   pay_batch_lines bal
    where  bal.batch_id = p_batch_id;

    if(l_n_lines <> nvl(p_control_total,0)) then

    -- Set status to signify an error and load up message text
        p_std_status:='E';
        hr_utility.set_message(801,'HR_34850_WRONG_NUM_BATCH_LINES');
        hr_utility.set_message_token('N_LINES_IN_BATCH',l_n_lines);
        hr_utility.set_message_token('N_LINES_CONTROL_TOTAL',p_control_total);
        p_std_message:=hr_utility.get_message;

    end if;

end if;

-- Deal with a standard total
if (instr (p_control_type,'_TOTAL_COLUMN_') = 1) then
   -- only check if control is recognisable as an arithmetic sum.
   -- _TOTAL_COLUMN_ must be the first characters in the string

   p_std_status := 'V';             -- set to valid

-- precheck that the total is relevant to this batch

  if (relevant_total_chk(p_batch_id,l_meaning)=false) then
     -- dont even attempt summation.
     -- No element in batch has this input value.
     -- Set status to error and insert relevant error in message table
     p_std_status:='E';
     hr_utility.set_message(801,'HR_34851_IRRELEVANT_CONTROL_TOTAL');
     hr_utility.set_message_token('NAME_OF_ENTRY_TO_SUM',l_meaning);
     p_std_message:=hr_utility.get_message;

  else

     -- Do the summation. We need to build a sql statement for each
     -- element individually as the column number (in pay) for the
     -- same named input value may differ between elements

     -- First of all find out if BEE_IV_UPG upgrade has been executed

     select business_group_id
     into   l_business_group_id
     from   pay_batch_headers
     where  batch_id = p_batch_id;

     l_bee_iv_upgrade := pay_core_utils.get_upgrade_status(l_business_group_id,'BEE_IV_UPG');

     for l_element in csr_distinct_elements(p_batch_id) loop

--     get the column number in pay_batch_lines that we need to sum.
--     We do this by finding the first column in pay_batch_lines that matches
--     the control total name.

       l_value_number:=0;
       for l_input_value in csr_ordered_input_values(l_element.element_type_id) loop
         l_value_number := l_value_number +1;
         if(l_input_value.name = l_meaning) then

--             found the number of the value column that contains the values for l_meaning
--             Build and excute dynamic sql statment to do the summation
--
                   if (l_bee_iv_upgrade = 'N') then
                     l_sql_stat:='select sum(value_'||l_value_number||') from pay_batch_lines where element_type_id='||l_element.element_type_id||' and batch_id='||p_batch_id;
                   else
                     l_sql_stat:='select sum(fnd_number.canonical_to_number(value_'||l_value_number||')) from pay_batch_lines where element_type_id='||l_element.element_type_id||' and batch_id='||p_batch_id;
                   end if;
--
                   begin
                        execute immediate l_sql_stat into l_element_total;
                   exception  -- could not perform summation for some reason
                    when others then
                      p_std_status:='E';
                      hr_utility.set_message(801,'HR_34853_CANT_SUM_COLUMN');
                      hr_utility.set_message_token('NAME_OF_ENTRY_TO_SUM',l_meaning);
                      p_std_message:=hr_utility.get_message;
--
                   end;
--
                   l_running_total := l_running_total + nvl(l_element_total,0);
--
           exit;
         end if;
       end loop;

    end loop;

--  compare calculated total with control total

    if(l_running_total <> nvl(p_control_total,0)) then
       p_std_status:='E';
       hr_utility.set_message(801,'HR_34852_SUMMATION_NE_TOTAL');
       hr_utility.set_message_token('NAME_OF_ENTRY_TO_SUM',l_meaning);
       hr_utility.set_message_token('BATCH_TOTAL',l_running_total);
       hr_utility.set_message_token('CONTROL_TOTAL',p_control_total);
       p_std_message:=hr_utility.get_message;
    end if;

   end if;
end if;

end check_control;


end pay_standard_check;

/
