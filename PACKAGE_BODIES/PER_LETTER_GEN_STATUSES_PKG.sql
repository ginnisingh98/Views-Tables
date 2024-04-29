--------------------------------------------------------
--  DDL for Package Body PER_LETTER_GEN_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_LETTER_GEN_STATUSES_PKG" as
/* $Header: pelts01t.pkb 115.2 99/07/18 14:01:54 porting ship  $ */

procedure ASSIGNMENT_STATUS_NOT_UNIQUE (
--
-- Returns TRUE if the assignment status is not unique, then the check is for
-- new record within generic data
--
-- Parameters are:
--
p_business_group_id         in number,
p_assignment_status_type_id in number,
p_letter_type_id            in number,
p_letter_gen_status_id      in number) is
--
v_not_unique    boolean := FALSE;
g_dummy_number  number;
--
cursor csr_duplicate is
	select  null
	from    per_letter_gen_statuses x
	where   x.business_group_id + 0     = p_business_group_id
	and     x.assignment_status_type_id = p_assignment_status_type_id
	and     x.letter_type_id        = p_letter_type_id
	and     (p_letter_gen_status_id is null
		or (p_letter_gen_status_id is not null
	           and x.letter_gen_status_id <> p_letter_gen_status_id));
--
begin
--
  open csr_duplicate;
  fetch csr_duplicate into g_dummy_number;
  v_not_unique := csr_duplicate%found;
  close csr_duplicate;
--
if v_not_unique then
    hr_utility.set_message (801,'PER_7859_DEF_LETTER_STAT_EXIST');
    hr_utility.raise_error;
end if;
--
end assignment_status_not_unique;
--
--
procedure get_next_sequence(p_letter_gen_status_id in out number) is
--
cursor c1 is select per_letter_gen_statuses_s.nextval
	     from sys.dual;
--
-- Retrieve the nnext sequence number for letter_gen_status_id field
--
begin
  --
  if (p_letter_gen_status_id is null) then
    open c1;
    fetch c1 into p_letter_gen_status_id;
    if (C1%NOTFOUND) then
	CLOSE C1;
	hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
	hr_utility.set_message_token('PROCEDURE','get_next_sequence');
	hr_utility.set_message_token('STEP','1');
        hr_utility.raise_error;
    end if;
    close c1;
  end if;
end get_next_sequence;
--
procedure get_assignment_status(p_assignment_status_type_id in number,
				p_assignment_status in out varchar2) is
--cursor c1 is select assignment_status
     --from assignment_status_lov
     --where p_assignment_status_type_id = assignment_status_type_id;
  cursor c1 is select nvl(atl.user_status, ttl.user_status)
               from   per_assignment_status_types_tl ttl,
                      per_assignment_status_types t,
                      per_ass_status_type_amends_tl atl,
                      per_ass_status_type_amends a
               where  t.assignment_status_type_id     = p_assignment_status_type_id
               and    a.assignment_status_type_id (+) = t.assignment_status_type_id
               and    a.ass_status_type_amend_id      = atl.ass_status_type_amend_id (+)
               and    decode(atl.ass_status_type_amend_id, null, '1', userenv('LANG')) =
                      decode(atl.ass_status_type_amend_id, null, '1', atl.LANGUAGE)
               and    t.assignment_status_type_id     = ttl.assignment_status_type_id
               and    ttl.LANGUAGE = userenv('LANG');

--
-- Get the assignment status value for the non-database field
--
begin
  --
  open c1;
  fetch c1 into p_assignment_status;
  if (C1%NOTFOUND) then
	CLOSE C1;
	hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
	hr_utility.set_message_token('PROCEDURE','get_assignment_status');
	hr_utility.set_message_token('STEP','1');
        hr_utility.raise_error;
  end if;
  close c1;
--
end get_assignment_status;
--
END PER_LETTER_GEN_STATUSES_PKG;

/
