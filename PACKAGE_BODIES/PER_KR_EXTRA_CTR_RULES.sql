--------------------------------------------------------
--  DDL for Package Body PER_KR_EXTRA_CTR_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_EXTRA_CTR_RULES" as
/* $Header: pekrxctr.pkb 115.5 2003/05/30 06:52:02 nnaresh noship $ */
--
procedure chk_primary_ctr_flag(
            p_contact_relationship_id in number,
            p_person_id               in number,
            p_contact_person_id       in number,
            p_date_start              in date,
            p_date_end                in date,
            p_cont_information1       in varchar2)
is
  l_exists  varchar2(1);
  cursor csr_lck is
    select  null
    from    per_people_f
    where   person_id = p_person_id
    and     effective_start_date = start_date
    for update of person_id nowait;
/* Changed from static to dynamic SQL to remove dependency.
  cursor csr_exists is
    select  'Y'
    from    dual
    where   exists(
              select  null
              from    per_contact_relationships
              where   person_id = p_person_id
              and     contact_person_id = p_contact_person_id
              and     contact_relationship_id <> p_contact_relationship_id
              and     cont_information1 = 'Y'
              and     nvl(date_end, hr_general.end_of_time) >= nvl(p_date_start, hr_general.start_of_time)
              and     nvl(date_start, hr_general.start_of_time) <= nvl(p_date_end, hr_general.end_of_time));
*/
	type csr is ref cursor;
	csr_exists	csr;
begin
  if p_cont_information1 = 'Y' then
    --
    -- Lock first person record to guarantee uniqueness.
    --
    open csr_lck;
    close csr_lck;
    --
    -- Check whether the contact relationship is unique.
    --
/* Changed from static to dynamic SQL to remove dependency.
    open csr_exists;
*/
    begin
      open csr_exists for
'select  ''Y''
from    dual
where   exists(
          select  null
          from    per_contact_relationships
          where   person_id = :p_person_id
          and     contact_person_id = :p_contact_person_id
          and     contact_relationship_id <> :p_contact_relationship_id
          and     cont_information1 = ''Y''
          and     nvl(date_end, hr_general.end_of_time) >= nvl(:p_date_start, hr_general.start_of_time)
          and     nvl(date_start, hr_general.start_of_time) <= nvl(:p_date_end, hr_general.end_of_time))'
      using p_person_id, p_contact_person_id, p_contact_relationship_id, p_date_start, p_date_end;
    exception
      --
      -- Above open statement will raise error if column "CONT_INFORMATION1" does not exist.
      -- No need to close the cursor because the cursor is not opened in case of error.
      --
      when others then
        return;
    end;
    fetch csr_exists into l_exists;
    if csr_exists%FOUND then
      close csr_exists;
      fnd_message.set_name('PAY', 'PER_KR_CTR_PRIMARY_CTR_FLAG');
      fnd_message.raise_error;
    end if;
    close csr_exists;
  end if;
end chk_primary_ctr_flag;
--
end per_kr_extra_ctr_rules;

/
