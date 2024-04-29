--------------------------------------------------------
--  DDL for Package Body PAY_CA_DIRECT_DEPOSIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_DIRECT_DEPOSIT_PKG" AS
/* $Header: pycatapd.pkb 120.2 2005/10/06 11:43:49 mmukherj noship $ */

FUNCTION get_file_creation_number(p_originator_id    varchar2
                                 ,p_fin_institution  varchar2
                                 ,p_override_fcn     varchar2)
RETURN varchar2 IS
--
l_new_fcn 	varchar2(4);
l_error         varchar2(10);
l_var 		number := 1;
l_fcn_exists 	number := 0;
l_max_seq 	number;
l_next_seq 	number;
l_orig_id 	varchar2(15) := 0;
l_fcn_rows      number;
l_ct_fcn_rows   number;
l_min_seq	number;
l_override_fcn  number := 0;
l_test_fcn      varchar2(4);
--
-- Cursor to see if Originator ID already exists in FCN table
--
CURSOR originator_exists(p_originator_id varchar2) IS
  select 1
  from   pay_ca_file_creation_numbers
  where  originator_id = p_originator_id;
--
-- Cursor to find the max number of rows allowed in FCN table for a particular
-- Financial Institution.
--
CURSOR get_num_fcns_allowed(p_fin_institution varchar2) IS
  select information_value
  from   pay_ca_legislation_info
  where  information_type = 'CA_DD_FCN_ROWS'
  and    lookup_code = p_fin_institution;
--
-- Cursor to count number of rows currently in FCN table for a given Originator
-- ID
--
CURSOR count_fcn_rows(p_originator_id varchar2) IS
  select count(*)
  from   pay_ca_file_creation_numbers
  where  originator_id = p_originator_id;
--
-- Cursor to find the maximum sequence_number for a particular Originator ID
--
CURSOR get_max_sequence(l_orig_id varchar2) is
  select max(sequence_number)
  from   pay_ca_file_creation_numbers
  where  originator_id = l_orig_id;
--
-- Cursor to find the maximum sequence_number for a particular Originator ID
-- where the file_creation_number is composed of digits only
--
CURSOR digits_only_max_sequence(l_orig_id varchar2) is
select max(sequence_number)
from   pay_ca_file_creation_numbers
where originator_id        = l_orig_id
and file_creation_number =
    translate(file_creation_number,
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz?><~!@#$%^*()_-+=/\|}{][":;.,`''',
      ' ');
--
-- Cursor to find the test FCN for a given Financial Institution
--
CURSOR get_test_fcn(p_fin_institution varchar2) IS
  select information_value
  from   pay_ca_legislation_info
  where  information_type = 'CA_DD_TEST'
  and    lookup_code = p_fin_institution;
--
-- Cursor to find the next FCN for a given Originator ID and seqence number
--
CURSOR get_new_fcn(l_var number, l_orig_id varchar2, l_seq_num number) is
  select fnd_number.canonical_to_number(file_creation_number) + l_var
  from   pay_ca_file_creation_numbers
  where  originator_id = l_orig_id
  and    sequence_number = l_seq_num;

-- Cursor to find the existing FCNs for a given Originator ID
--
CURSOR current_fcns(l_orig_id varchar2, l_fcn varchar2) is
  select 1
  from   pay_ca_file_creation_numbers
  where  originator_id = l_orig_id
  and    file_creation_number = l_fcn;
--
-- Cursor to get the next sequence number
--
CURSOR get_nextval is
  select pay_ca_file_creation_numbers_s.nextval
  from dual;
--
-- Cursor to get the min sequence_number for a given Originator ID
--
CURSOR get_min_sequence(p_originator_id varchar2) IS
  select min(sequence_number)
  from   pay_ca_file_creation_numbers
  where  originator_id = p_originator_id;
--
-- Cursor to find if Override FCN already exists in FCN table
--
CURSOR override_fcn_exists(p_originator_id varchar2
                          ,p_override_fcn  varchar2) is
  select 1
  from   pay_ca_file_creation_numbers
  where  originator_id = p_originator_id
  and    file_creation_number = p_override_fcn;
--
-- Procedure to insert and commit a new row in pay_ca_file_creation_numbers
--
PROCEDURE insert_new_fcn(p_originator_id varchar2
                        ,p_sequence_number number
                        ,p_new_fcn varchar2) is
BEGIN
--
insert into
pay_ca_file_creation_numbers
       (originator_id ,
        sequence_number,
        file_creation_number)
values (p_originator_id,
        p_sequence_number,
        lpad(p_new_fcn,4,'0'));
--
--commit;
end;
--
-- Procedure to delete and commit oldest FCN in the FCN table for a given
-- Originator ID
--
PROCEDURE delete_oldest_fcn(p_originator_id varchar2
                           ,p_sequence_number number) IS
BEGIN
--
delete from pay_ca_file_creation_numbers
where  sequence_number = p_sequence_number
and    originator_id   = p_originator_id;
--
--commit;
end;
--
-- Function that actually gets the next available fcn
--
FUNCTION get_actual_fcn(p_originator_id varchar2) return varchar2 IS
--
BEGIN
    -- Get the max sequence number for a given Originator ID
    -- where the file creation number is made up from digits
    -- only
    open  digits_only_max_sequence(p_originator_id);
    fetch digits_only_max_sequence into l_max_seq;

    if digits_only_max_sequence%FOUND and
       l_max_seq is not NULL then
         --
         -- Get the potential new FCN
         --
         open get_new_fcn(l_var, p_originator_id, l_max_seq);
         fetch get_new_fcn into l_new_fcn;
         close get_new_fcn;
         -- dbms_output.put_line('1st new fcn is '||l_new_fcn);
         --
         -- Check if the potential FCN already exists
         --
         open current_fcns(p_originator_id, l_new_fcn);
         fetch current_fcns into l_fcn_exists;
         close current_fcns;
         -- dbms_output.put_line('l_exists is '||l_fcn_exists);
         --
         -- If the potential FCN does already exist then keep adding 1 to the number
         -- until it does not exist. This will be the new FCN.
         --
         if l_fcn_exists = 1 then
         --
           loop
              l_var := l_var + 1;
              l_fcn_exists := 0;
              open get_new_fcn(l_var, p_originator_id, l_max_seq);
              fetch get_new_fcn into l_new_fcn;
              close get_new_fcn;
              --
              -- dbms_output.put_line('lnewfcn is '||l_new_fcn);
              --
              open current_fcns(p_originator_id, l_new_fcn);
              fetch current_fcns into l_fcn_exists;
              --
              -- dbms_output.put_line('l_fcn_exists is '||l_fcn_exists);
              --
              exit when current_fcns%NOTFOUND;
              --
              close current_fcns;
           end loop;
         else
         -- dbms_output.put_line('else new fcn is '||l_new_fcn);
              null;
         end if;
    else
         l_new_fcn := '0001';
    end if;

    close digits_only_max_sequence;

    -- dbms_output.put_line('l_new_fcn is '||l_new_fcn);
    --
    -- Insert new row into pay_ca_file_creation_numbers, get the
    -- sequence.nextval first.
    --

    open get_nextval;
    fetch get_nextval into l_next_seq;
    close get_nextval;
    --
    insert_new_fcn(p_originator_id
                  ,l_next_seq
                  ,lpad(l_new_fcn,4,'0'));
    --
    open get_max_sequence(p_originator_id);
    fetch get_max_sequence into l_max_seq;
    close get_max_sequence;
    --
    select file_creation_number
    into   l_new_fcn
    from   pay_ca_file_creation_numbers
    where  sequence_number = l_max_seq
    and    originator_id = p_originator_id;
    --
    RETURN l_new_fcn;
END;
--
BEGIN  -- Main function get_file_creation_number
--
-- Does the Originator ID passed in already exist in fcn table? 1 = Exists
-- 0 = Not exists
--
open  originator_exists(p_originator_id);
fetch originator_exists into l_orig_id;
close originator_exists;
--
IF l_orig_id = 1 then
--
-- Has an Override FCN been entered?
--
  IF p_override_fcn is null THEN
  --
  -- Check if number of rows in the FCN table is at the max for a particular
  -- Financial Institution.
  -- l_fcn_rows = number allowed, l_ct_fcn_rows = actual number of rows
  --
    open  get_num_fcns_allowed(p_fin_institution);
    fetch get_num_fcns_allowed into l_fcn_rows;
    close get_num_fcns_allowed;
    --
    open  count_fcn_rows(p_originator_id);
    fetch count_fcn_rows into l_ct_fcn_rows;
    close count_fcn_rows;
    --
    IF l_ct_fcn_rows < l_fcn_rows THEN
    --
    -- Insert the next row as normal
    --
      l_new_fcn := get_actual_fcn(p_originator_id);
      --
      RETURN l_new_fcn;
    --
    ELSE  -- number of rows in FCN table is => than rows allowed, delete
          -- the row with the min sequence_number for the given Originator ID
          -- then insert the new row.
          --
      open  get_min_sequence(p_originator_id);
      fetch get_min_sequence into l_min_seq;
      close get_min_sequence;
      --
      delete_oldest_fcn(p_originator_id, l_min_seq);
      --
      -- NEED TO INSERT ROW HERE
      --
        l_new_fcn := get_actual_fcn(p_originator_id);
        --
        RETURN l_new_fcn;
    --
    END IF;
    --
  ELSE  -- Override FCN is not null
  --
  -- Is the Override FCN the test FCN for a given fin institution?
  --
    open get_test_fcn(p_fin_institution);
    fetch get_test_fcn into l_test_fcn;
    close get_test_fcn;
    --
    IF p_override_fcn = l_test_fcn THEN
    --
      l_new_fcn := p_override_fcn;
      --
      RETURN l_new_fcn;
      --
--    ELSIF
    --
    -- If the Override FCN is not equal to the TEST FCN, and it is not
    -- between 0001 and 9999 then an invalid valud has been passed in
    -- for the Override FCN, so terminate the process and return a
    -- message.
    --
--      (p_override_fcn <> l_test_fcn
--       and (p_override_fcn < '0001'
--           or p_override_fcn > '9999')) THEN
       --
       -- NEED TO RAISE AN ERROR THAT CAN BE RAISED IN FAST FORMULA
       --
--       l_new_fcn := '1.2';
       --
--       RETURN l_new_fcn;
       --
    ELSE
    --
    -- Is the Override FCN already in the FCN table?
    --
      -- dbms_output.put_line('1st l_override_fcn is '||l_override_fcn);
--
    open  override_fcn_exists(p_originator_id, p_override_fcn);
    fetch override_fcn_exists into l_override_fcn;
    close override_fcn_exists;
  --  select 1
  --  into l_override_fcn
  --  from pay_ca_file_creation_numbers
  --  where originator_id = p_originator_id
  --  and   file_creation_number = p_override_fcn;
    --
    -- dbms_output.put_line('l_override_fcn is '||l_override_fcn);
    --
    IF l_override_fcn = 1 THEN  -- i.e does exist
    --
     -- NEED TO RAISE AN ERROR THAT CAN BE RAISED IN FAST FORMULA
      hr_utility.trace('magtape must be terminated as FCN already exists');
      -- dbms_output.put_line('magtape must be terminated as FCN already exists');
      l_new_fcn := 1.1;
      RETURN l_new_fcn;
    ELSE -- Override does not exist on FCN table
    --
    -- Check if number of rows in the FCN table is at the max for a particular
    -- Financial Institution.
    -- l_fcn_rows = number allowed, l_ct_fcn_rows = actual number of rows
    --
      open  get_num_fcns_allowed(p_fin_institution);
      fetch get_num_fcns_allowed into l_fcn_rows;
      close get_num_fcns_allowed;
      --
      open  count_fcn_rows(p_originator_id);
      fetch count_fcn_rows into l_ct_fcn_rows;
      close count_fcn_rows;
      --
      IF l_ct_fcn_rows < l_fcn_rows THEN
      --
      -- Insert the next row as normal
      --
         --l_new_fcn := get_actual_fcn(p_originator_id);
        open get_nextval;
        fetch get_nextval into l_next_seq;
        close get_nextval;
        --
        insert_new_fcn(p_originator_id
                       ,l_next_seq
                       ,p_override_fcn);
         --
         open get_max_sequence(p_originator_id);
         fetch get_max_sequence into l_max_seq;
         close get_max_sequence;
         --
         select file_creation_number
         into   l_new_fcn
         from   pay_ca_file_creation_numbers
         where  sequence_number = l_max_seq
         and    originator_id = p_originator_id;
         --
         --
         RETURN l_new_fcn;
         --
      ELSE -- Number of rows in FCN table is => than rows allowed, delete
           -- the row with the min sequence_number for the given Originator ID
           -- then insert the new row.
           --
        open  get_min_sequence(p_originator_id);
        fetch get_min_sequence into l_min_seq;
        close get_min_sequence;
        --
        delete_oldest_fcn(p_originator_id, l_min_seq);
        --
        --l_new_fcn := get_actual_fcn(p_originator_id);
        open get_nextval;
        fetch get_nextval into l_next_seq;
        close get_nextval;
        --
        insert_new_fcn(p_originator_id
                       ,l_next_seq
                       ,p_override_fcn);
         --
         open get_max_sequence(p_originator_id);
         fetch get_max_sequence into l_max_seq;
         close get_max_sequence;
         --
         select file_creation_number
         into   l_new_fcn
         from   pay_ca_file_creation_numbers
         where  sequence_number = l_max_seq
         and    originator_id = p_originator_id;
         --
         RETURN l_new_fcn;
        --
      END IF; -- Num of rows in FCN table < or => row allowed
      --
      END IF; -- Override FCN is in the table already??
      --
   END IF;  -- Is override FCN the test fcn?
   --
  END IF; -- Overrid is/not null
--
ELSE  -- originator id not in FCN table
--
  -- Has an Override FCN been entered?
  --
  IF p_override_fcn is null THEN
  --
    open  get_nextval;
    fetch get_nextval into l_next_seq;
    close get_nextval;
    --
    insert_new_fcn(p_originator_id
                  ,l_next_seq
                  ,'0001');
    --
    open get_max_sequence(p_originator_id);
    fetch get_max_sequence into l_max_seq;
    close get_max_sequence;
    --
    select file_creation_number
    into   l_new_fcn
    from   pay_ca_file_creation_numbers
    where  sequence_number = l_max_seq
    and    originator_id = p_originator_id;
    --
    RETURN l_new_fcn;
    --
  ELSE   -- Override FCN is not null NB. as it is a new Originator Id in the
         -- FCN table then don't need to check if the override FCN is already
         -- in the FCN, just insert first row with the override FCN value.
         --
  -- Is the Override FCN the test FCN for a given fin institution?
  --
    open get_test_fcn(p_fin_institution);
    fetch get_test_fcn into l_test_fcn;
    close get_test_fcn;
    --
    IF p_override_fcn = l_test_fcn THEN
    --
      l_new_fcn := p_override_fcn;
      --
      RETURN l_new_fcn;
      --
--    ELSIF
    --
    -- If the Override FCN is not equal to the TEST FCN, and it is not
    -- between 0001 and 9999 then an invalid valud has been passed in
    -- for the Override FCN, so terminate the process and return a
    -- message.
    --
--      (p_override_fcn <> l_test_fcn
--       and (p_override_fcn < '0001'
--           or p_override_fcn > '9999')) THEN
       --
       -- NEED TO RAISE AN ERROR THAT CAN BE RAISED IN FAST FORMULA
       --
--       l_new_fcn := '1.2';
       --
--       RETURN l_new_fcn;
       --
    ELSE
    --
    open  get_nextval;
    fetch get_nextval into l_next_seq;
    close get_nextval;
    --
    insert_new_fcn(p_originator_id
                  ,l_next_seq
                  ,p_override_fcn);
    --
    open get_max_sequence(p_originator_id);
    fetch get_max_sequence into l_max_seq;
    close get_max_sequence;
    --
    select file_creation_number
    into   l_new_fcn
    from   pay_ca_file_creation_numbers
    where  sequence_number = l_max_seq
    and    originator_id = p_originator_id;
    --
    RETURN l_new_fcn;
    --
    END IF; -- Is override FCN the test fcn?
    --
  END IF;  -- Is Override FCN null/not null?
END IF;
--
END get_file_creation_number;


/* New Function to generate the FCN value, fix for bug#2790271 */
FUNCTION get_dd_file_creation_number(p_org_payment_method_id number,
                                     p_fin_institution varchar2,
                                     p_override_fcn varchar2,
                                     p_pact_id number,
                                     p_business_group_id number)
RETURN varchar2 IS
l_new_fcn       varchar2(4);
l_error         varchar2(10);
l_var           number := 1;
l_fcn_exists    number := 0;
l_orig_id       varchar2(15) := 0;
l_override_fcn  number := 0;
l_test_fcn      varchar2(4);
l_max_pact_id   number;
l_fcn_rows      number;

--
-- Cursor to find the max number of rows allowed in FCN table
-- for a particular Financial Institution.
--
CURSOR get_num_fcns_allowed(cp_fin_institution varchar2) IS
  select TO_NUMBER(information_value)
  from   pay_ca_legislation_info
  where  information_type = 'CA_DD_FCN_ROWS'
  and    lookup_code = cp_fin_institution;


-- Cursor to find the maximum payroll_action_id for a particular
-- Payment method (Originator ID is unique within each payment method)
-- where the file_creation_number is composed of digits only
--
CURSOR digits_only_max_sequence(cp_org_pmt_method_id number,cp_bg_id number) is
select max(payroll_action_id)
from   pay_payroll_actions
where business_group_id = cp_bg_id
and action_type = 'M'
and org_payment_method_id = cp_org_pmt_method_id
and attribute1 is not null;


-- Cursor to find the next FCN for a given Payment Method ID ,
-- max payroll_action_id and business_group_id
--
CURSOR get_new_fcn(l_var number, cp_org_pmt_method_id number,
                   cp_max_pact_id number, cp_bg_id number) is
  select translate(attribute1,
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz?><~!@#$%^*()_-+=/\|}{][":;.,`''',' ') + l_var
  from   pay_payroll_actions
  where  business_group_id = cp_bg_id
  and action_type = 'M'
 and org_payment_method_id = cp_org_pmt_method_id
  and    payroll_action_id = cp_max_pact_id;


-- Cursor to find whether the newly generated FCN exists
-- in the last N records for a given Payment Method ID
--
CURSOR current_fcns(cp_org_pmt_method_id number, l_fcn varchar2,
                    cp_bg_id number, cp_no_fcn_rows number) is
  select 1
  from   pay_payroll_actions
  where  business_group_id = cp_bg_id
  and action_type = 'M'
  and org_payment_method_id = cp_org_pmt_method_id
  and attribute1 = l_fcn
  and rownum <= cp_no_fcn_rows
  order by payroll_action_id desc;


-- Cursor to find if Override FCN already exists in last N records
--
CURSOR override_fcn_exists(cp_org_pmt_method_id number
                          ,p_override_fcn  varchar2
                          ,cp_bg_id number
                          ,cp_no_fcn_rows number) is
  select 1
  from   pay_payroll_actions
  where  business_group_id = cp_bg_id
  and    action_type = 'M'
  and    org_payment_method_id = cp_org_pmt_method_id
  and    attribute1 = p_override_fcn
  and    rownum <= cp_no_fcn_rows
  order by payroll_action_id desc;


-- Cursor to check whether the Override FCN is a test FCN or not
CURSOR get_test_fcn(p_fin_institution varchar2) IS
  select information_value
  from   pay_ca_legislation_info
  where  information_type = 'CA_DD_TEST'
  and    lookup_code = p_fin_institution;

-- Procedure to stamp the FCN number in pay_payroll_actions table
--
PROCEDURE insert_new_fcn(p_org_pmt_method_id number
                        ,p_new_fcn varchar2
                        ,p_pact_id number) is
BEGIN
--

update pay_payroll_actions
set attribute1 = lpad(p_new_fcn,4,'0')
where payroll_action_id = p_pact_id
and org_payment_method_id = p_org_pmt_method_id;
--
--commit;
end;


-- Function that actually gets the next available fcn
--
FUNCTION get_actual_dd_fcn(p_org_pmt_method_id number,
                           p_bg_id number,
                           p_no_fcn_rows number) return varchar2 IS

BEGIN
       -- Get the max payroll_action_id for a given Payment_Method_ID and
       -- Business_group_id where the file creation number is made up from
       -- digits only

       open  digits_only_max_sequence(p_org_pmt_method_id, p_bg_id);
       fetch digits_only_max_sequence into l_max_pact_id;
       hr_utility.trace('l_max_pact_id: '||to_char(l_max_pact_id));

        if digits_only_max_sequence%FOUND and
           l_max_pact_id is not NULL then

           -- Get the potential new FCN

           hr_utility.trace('Digits_only_max_sequence found ');
           open get_new_fcn(l_var, p_org_pmt_method_id, l_max_pact_id,
                            p_bg_id);
           fetch get_new_fcn into l_new_fcn;
           close get_new_fcn;
           l_new_fcn := lpad(l_new_fcn,4,'0');
           hr_utility.trace('1st new fcn l_new_fcn: '||l_new_fcn);
           -- dbms_output.put_line('1st new fcn is '||l_new_fcn);

           -- Check if the potential FCN already exists in last N records

           open current_fcns(p_org_pmt_method_id, l_new_fcn,
                             p_bg_id,p_no_fcn_rows);
           fetch current_fcns into l_fcn_exists;
           close current_fcns;
           hr_utility.trace('l_fcn_exists: '||to_char(l_fcn_exists));
           -- dbms_output.put_line('l_exists is '||l_fcn_exists);
           --
           -- If the potential FCN does already exist in last N records
           -- then keep adding 1 to the number
           -- until it does not exist. This will be the new FCN.
           --
               if l_fcn_exists = 1 then

                 hr_utility.trace('l_fcn_exists is satisfied');
                 loop
                   l_var := l_var + 1;
                   l_fcn_exists := 0;
                   open get_new_fcn(l_var, p_org_pmt_method_id,
                                    l_max_pact_id, p_bg_id);
                   fetch get_new_fcn into l_new_fcn;
                   close get_new_fcn;
                     l_new_fcn := lpad(l_new_fcn,4,'0');

                   hr_utility.trace('In the loop l_new_fcn: '||l_new_fcn);
                   -- dbms_output.put_line('lnewfcn is
                   -- '||l_new_fcn);

                   open current_fcns(p_org_pmt_method_id, l_new_fcn,
                                     p_bg_id,p_no_fcn_rows);
                   fetch current_fcns into l_fcn_exists;

                   -- dbms_output.put_line('l_fcn_exists is
                   -- '||l_fcn_exists);

                   hr_utility.trace('In the loop l_fcn_exists: '||l_fcn_exists);
                   exit when current_fcns%NOTFOUND;

                   close current_fcns;
                 end loop;

              else
                 -- dbms_output.put_line('else new fcn is
                 -- '||l_new_fcn);
                 null;
              end if;
        else

            l_new_fcn := '0001';

        end if;

       close digits_only_max_sequence;

          -- dbms_output.put_line('l_new_fcn is '||l_new_fcn);
          --
          -- Stamp New FCN record in pay_payroll_actions table

          l_new_fcn := lpad(l_new_fcn,4,'0');
           hr_utility.trace('Final FCN Generated, before Update the l_new_fcn:'||l_new_fcn);
          insert_new_fcn(p_org_pmt_method_id,l_new_fcn,p_pact_id);

          RETURN l_new_fcn;
END; --get_actual_dd_fcn


BEGIN  -- Main function get_dd_file_creation_number
/*          hr_utility.trace_on('Y','TESTFCN');  */
         hr_utility.trace('Start of Get_dd_file_Creation_Number function');
       --
       -- Does any DD exist for the given Payment Method in
       -- pay_payroll_actions table?
       -- l_max_pact_id is not null then Exists
       -- l_max_pact_id is null then Not exists

           hr_utility.trace('p_business_group_id :'||to_char(p_business_group_id));
           hr_utility.trace('p_org_payment_method_id :'||to_char(p_org_payment_method_id));
           hr_utility.trace('p_fin_institution :'||p_fin_institution);
           hr_utility.trace('p_override_fcn : '||p_override_fcn);
           hr_utility.trace('p_pact_id :'||to_char(p_pact_id));

       open  digits_only_max_sequence(p_org_payment_method_id,
                                      p_business_group_id);
       fetch digits_only_max_sequence into l_max_pact_id;
       close digits_only_max_sequence;

           hr_utility.trace('l_max_pact_id :'||to_char(l_max_pact_id));
       -- Check how many max FCN rows allowed for a particular
       -- Financial Institution.
       --
       open  get_num_fcns_allowed(p_fin_institution);
       fetch get_num_fcns_allowed into l_fcn_rows;

       if get_num_fcns_allowed%NOTFOUND then
         l_fcn_rows := 50;
       end if;
       close get_num_fcns_allowed;
           hr_utility.trace('l_fcn_rows :'||to_char(l_fcn_rows));
       --

           hr_utility.trace('p_override_fcn : '||p_override_fcn);
       /* check if there exists atleast one DD for the given
          payment method, Similar to Originator Id exists or not */

       IF l_max_pact_id is not null then

           -- Has an Override FCN been entered?
          IF p_override_fcn is null THEN

             l_new_fcn := get_actual_dd_fcn(p_org_payment_method_id,
                                                p_business_group_id,
                                                l_fcn_rows);

             hr_utility.trace('p_override_fcn is null');
             RETURN l_new_fcn;


          ELSE  -- Override FCN is not null

             -- Is the Override FCN the test FCN for a given fin
             -- institution?

             open get_test_fcn(p_fin_institution);
             fetch get_test_fcn into l_test_fcn;
             close get_test_fcn;

             IF p_override_fcn = l_test_fcn THEN

                l_new_fcn := p_override_fcn;

                /* Update Pay_Payroll_actions table with FCN value */

                 hr_utility.trace('l_new_fcn final:'||l_new_fcn);
                insert_new_fcn(p_org_payment_method_id,l_new_fcn,p_pact_id);
                RETURN l_new_fcn;

             ELSE

                -- Is the Override FCN already in the FCN table?
                -- dbms_output.put_line('1st l_override_fcn is
                -- '||l_override_fcn);

                open override_fcn_exists(p_org_payment_method_id,
                                         p_override_fcn,
                                         p_business_group_id, l_fcn_rows);
                fetch override_fcn_exists into l_override_fcn;
                close override_fcn_exists;

                 hr_utility.trace('l_override_fcn :'||l_override_fcn);
                -- dbms_output.put_line('l_override_fcn is
                -- '||l_override_fcn);

                IF l_override_fcn = 1 THEN  -- i.e does exist

                   -- NEED TO RAISE AN ERROR THAT CAN BE RAISED IN FAST
                   -- FORMULA and XML Magtape formats
                   hr_utility.trace('magtape must be terminated as FCN already exists');
                   -- dbms_output.put_line('magtape must be terminated as
                   -- FCN already exists');
                   l_new_fcn := '1.1';
                   RETURN l_new_fcn;

                ELSE -- Override does not exist on FCN table

                   -- Insert the next row as normal
                   insert_new_fcn(p_org_payment_method_id,p_override_fcn,
                                  p_pact_id);

                   RETURN p_override_fcn;

                END IF; -- Override FCN is in the table already??

              END IF;  -- Is override FCN the test fcn?

           END IF; -- Override FCN is/not null

        ELSE  -- originator id not in Payroll Actions table

              -- Has an Override FCN been entered?

              IF p_override_fcn is null THEN

                  l_new_fcn := '0001';
                  insert_new_fcn(p_org_payment_method_id ,l_new_fcn,p_pact_id);
                 hr_utility.trace('l_new_fcn final:'||l_new_fcn);

                  RETURN l_new_fcn;

              ELSE -- Override FCN is not null NB. as it is a new
                   -- Originator Id in the FCN table then don't
                   -- need to check if the override FCN is already
                   -- in the FCN, just insert first row with the override
                   -- FCN value.

                   -- Is the Override FCN the test FCN for a given fin
                   -- institution?

                    open get_test_fcn(p_fin_institution);
                    fetch get_test_fcn into l_test_fcn;
                    close get_test_fcn;

                    IF p_override_fcn = l_test_fcn THEN

                       l_new_fcn := p_override_fcn;

                       /* Update Pay_Payroll_actions table with
                          FCN value */
                       insert_new_fcn(p_org_payment_method_id,l_new_fcn,
                                      p_pact_id);

                       hr_utility.trace('l_new_fcn final:'||l_new_fcn);
                       RETURN l_new_fcn;

                    ELSE

                       insert_new_fcn(p_org_payment_method_id,p_override_fcn,
                                      p_pact_id);
                       hr_utility.trace('l_new_fcn final:'||l_new_fcn);
                       RETURN p_override_fcn;

                    END IF; -- Is override FCN the test fcn?

               END IF;  -- Is Override FCN null/not null?
        END IF;

         /* hr_utility.trace_off; */
END get_dd_file_creation_number;

FUNCTION convert_uppercase(p_input_string varchar2)
RETURN varchar2 IS
--
l_output_string varchar2(2000);

-- converts the french accented characters to American English
-- in uppercase, used for direct deposit mag tape data
cursor c_uppercase(cp_input_string varchar2) is
select
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
 replace(
 replace(
replace(convert(upper(cp_input_string),'UTF8'),
           utl_raw.cast_to_varchar2(hextoraw('C380')),'A'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38A')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C387')),'C'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C389')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C39C')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C399')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C39B')),'U'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C394')),'O'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38F')),'I'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38E')),'I'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C388')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C38B')),'E'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C382')),'A'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C592')),'OE'
          ),
          utl_raw.cast_to_varchar2(hextoraw('C386')),'AE'
          )
from dual;


begin

  open c_uppercase(p_input_string);
  fetch c_uppercase into l_output_string;
  if c_uppercase%NOTFOUND then
     l_output_string := p_input_string;
  end if;
  close c_uppercase;

  return l_output_string;

end convert_uppercase;


END pay_ca_direct_deposit_pkg;

/
