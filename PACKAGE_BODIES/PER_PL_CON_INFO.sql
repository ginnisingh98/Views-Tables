--------------------------------------------------------
--  DDL for Package Body PER_PL_CON_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_CON_INFO" AS
/* $Header: peplcrlp.pkb 120.1 2006/09/13 10:58:39 mseshadr noship $ */

---------------------------------------------------------------------------------------------------
--      CREATE_PL_CON_REL                                                                        --
---------------------------------------------------------------------------------------------------
PROCEDURE CREATE_PL_CON_REL(P_DATE_START        DATE,
                            P_DATE_END          DATE,
                            P_CONTACT_PERSON_ID NUMBER,
                            P_PERSON_ID         NUMBER,
                            P_CONTACT_TYPE      VARCHAR2,
					P_DATE_OF_BIRTH     DATE) IS
 cursor cur_crl is select 1 from per_contact_relationships
	where contact_person_id  = p_contact_person_id
	and  person_id = p_person_id
	and contact_type in ('01','11','21','30','31','32','33','40','41','50','60')
        and P_CONTACT_TYPE in ('01','11','21','30','31','32','33','40','41','50','60')
	and (date_start >= p_date_start
	OR nvl(date_end,hr_general.end_of_time) <= nvl(p_date_end,hr_general.end_of_time));

cursor csr_dob_contact is
    select date_of_birth from per_all_people_f where person_id = P_CONTACT_PERSON_ID;

 nDummy_val number;
 l_dob_contact per_all_people_f.date_of_birth%TYPE;
 l_proc    varchar2(17);
BEGIN
l_proc:='CREATE_PL_CON_REL';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
  open cur_crl;
  fetch cur_crl into nDummy_val;
  IF cur_crl%found then
   Close cur_crl;
      hr_utility.set_message(800,'HR_CON_REL_OVERLAP_PL');
      hr_utility.raise_error;
  End If;
  Close cur_crl;

/* This contact is not already a part of the system */

  if p_contact_person_id is null then
     if P_DATE_OF_BIRTH is null and P_CONTACT_TYPE = '11' then
	hr_utility.set_message(800,'HR_CON_DOB_REQD_PL');
        hr_utility.raise_error;
     end if;

  else

/* This contact is already a part of the system. So person_type_id is not null */

  if P_CONTACT_TYPE = '11'  then
     if P_DATE_OF_BIRTH is null then
        hr_utility.set_message(800,'HR_CON_DOB_REQD_PL');
        hr_utility.raise_error;
     end if;

     if P_DATE_OF_BIRTH = hr_api.g_date then
        open csr_dob_contact;
          fetch csr_dob_contact into l_dob_contact;
        close csr_dob_contact;

        if l_dob_contact is null then
           hr_utility.set_message(800,'HR_CON_DOB_REQD_PL');
           hr_utility.raise_error;
        end if;

     end if;
   end if;
  end if; -- End if of p_contact_person_id is null



END CREATE_PL_CON_REL;
---------------------------------------------------------------------------------------------------
--                          UPDATE_PL_CON_REL                                                    --
---------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_PL_CON_REL(P_CONTACT_RELATIONSHIP_ID  NUMBER,
                            P_DATE_START               DATE,
                            P_DATE_END                 DATE,
                            P_CONTACT_TYPE             VARCHAR2) IS

  cursor cur_crl is select 1 from per_contact_relationships
	where contact_person_id in
       (select contact_person_id from per_contact_relationships where contact_relationship_id = p_contact_relationship_id)
	and  person_id in (select person_id from per_contact_relationships where contact_relationship_id = p_contact_relationship_id)
	and  contact_relationship_id <> p_contact_relationship_id
	and contact_type in ('01','11','21','30','31','32','33','40','41','50','60')
        and P_CONTACT_TYPE in ('01','11','21','30','31','32','33','40','41','50','60')
	and (date_start >= p_date_start
	OR nvl(date_end,hr_general.end_of_time) <= nvl(p_date_end,hr_general.end_of_time));

 cursor csr_dob_contact is
select date_of_birth from per_all_people_f where person_id in (select contact_person_id from
per_contact_relationships where contact_relationship_id = P_CONTACT_RELATIONSHIP_ID);

l_contact_dob per_all_people_f.date_of_birth%TYPE;
nDummy_val number;
l_proc     varchar2(17);
BEGIN
l_proc:='UPDATE_PL_CON_REL';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;

 open cur_crl;
  fetch cur_crl into nDummy_val;
  IF cur_crl%found then
   Close cur_crl;
      hr_utility.set_message(800,'HR_CON_REL_OVERLAP_PL');
      hr_utility.raise_error;
  End If;
  Close cur_crl;

 if P_CONTACT_TYPE = '11' then
    open csr_dob_contact;
      fetch csr_dob_contact into l_contact_dob;
    close csr_dob_contact;

    if l_contact_dob is null then
       hr_utility.set_message(800,'HR_CON_DOB_REQD_PL');
       hr_utility.raise_error;
    end if;

 end if;

END UPDATE_PL_CON_REL;

END PER_PL_CON_INFO;

/
