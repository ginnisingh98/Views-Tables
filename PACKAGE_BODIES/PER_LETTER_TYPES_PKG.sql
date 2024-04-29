--------------------------------------------------------
--  DDL for Package Body PER_LETTER_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_LETTER_TYPES_PKG" as
/* $Header: peltt01t.pkb 115.1 99/07/18 14:02:00 porting ship $ */

procedure LETTER_TYPE_NOT_UNIQUE (
--
-- Returns TRUE if the letter type name is not unique, then the check is for a
-- new record within generic data
--
-- Parameters are:
--
p_letter_type        in varchar2,
p_business_group_id  in number,
p_letter_type_id     in number) is
--
v_not_unique    boolean := FALSE;
g_dummy_number  number;
--
cursor csr_duplicate is
		select  null
                from per_letter_types
		where upper(p_letter_type) = upper(letter_type_name)
	    	and p_business_group_id = business_group_id + 0
		and (p_letter_type_id is null
		    or (p_letter_type_id is not null
		    and letter_type_id <> p_letter_type_id));
begin
--
  open csr_duplicate;
  fetch csr_duplicate into g_dummy_number;
  v_not_unique := csr_duplicate%found;
  close csr_duplicate;
--
if v_not_unique then
    hr_utility.set_message (801,'PER_7856_DEF_LETTER_EXISTS');
    hr_utility.raise_error;
end if;
--
end letter_type_not_unique;

procedure check_delete_letter_type (p_letter_type_id in number) is
--
g_dummy_number    number;
v_no_delete       boolean := FALSE;
--
cursor csr_status is
	   select null
	   from per_letter_gen_statuses
           where p_letter_type_id = letter_type_id;
--
cursor csr_request is
	   select null
	   from per_letter_requests
           where p_letter_type_id = letter_type_id;
--
-- Check there are no dependencies of the letter type record
-- in the per_letter_gen_statuses and per_letter_requests table
--
begin
  open csr_status;
  fetch csr_status into g_dummy_number;
  v_no_delete := csr_status%found;
  close csr_status;
  --
  if  v_no_delete then
      hr_utility.set_message (801,'PER_7857_DEF_LETTER_STATUSES');
      hr_utility.raise_error;
  end if;
  --
  open csr_request;
  fetch csr_request into g_dummy_number;
  v_no_delete := csr_request%found;
  close csr_request;
  --
  if  v_no_delete then
      hr_utility.set_message (801,'PER_7858_DEF_LETTER_REQUESTS');
      hr_utility.raise_error;
  end if;
  --
end check_delete_letter_type;
--
--
procedure get_next_sequence(p_letter_type_id in out number) is
--
cursor c1 is select per_letter_types_s.nextval
	     from sys.dual;
--
begin
  --
  -- Retrieve the next sequence number for letter_type_id
  --
  if (p_letter_type_id is null) then
    open c1;
    fetch c1 into p_letter_type_id;
    if (C1%NOTFOUND) then
	 CLOSE C1;
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','peltt01t.get_next_sequence');
         hr_utility.set_message_token('STEP','1');
	 hr_utility.raise_error;
    end if;
    close c1;
  end if;
end get_next_sequence;
--
procedure get_concurrent_program(p_concurrent_program_id in number,
				 p_concurrent_program_name in out varchar2) is
--
cursor c1 is select concurrent_program_name
             from fnd_concurrent_programs fcp
	     where p_concurrent_program_id = fcp.concurrent_program_id;

begin
   --
   -- Get the concurrent program value for the non-db field
   --
   open c1;
   fetch c1 into p_concurrent_program_name;
     if (C1%NOTFOUND) then
	 CLOSE C1;
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','peltt01t.concurrent_program_name');
         hr_utility.set_message_token('STEP','1');
	 hr_utility.raise_error;
     end if;
   close c1;
   --
end get_concurrent_program;
--
END PER_LETTER_TYPES_PKG;

/
