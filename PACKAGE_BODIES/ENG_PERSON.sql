--------------------------------------------------------
--  DDL for Package Body ENG_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_PERSON" AS
/* $Header: ENGEMPDB.pls 120.0.12000000.2 2007/02/22 09:56:29 prgopala noship $ */
--
  /*
    NAME
      eng_predel_validation
    DESCRIPTION
      Foreign key reference check.
  */
  --
  PROCEDURE eng_predel_validation (p_person_id  number)
  IS
  --
  v_delete_permitted    varchar2(1);
  --
  BEGIN
      --
      hr_utility.set_location('ENG_PERSON.ENG_PREDEL_VALIDATION', 1);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    eng_engineering_changes eng
                where   eng.requestor_id in  (select party_id
                                            from hz_parties
                                            where person_identifier = to_char(p_person_id)));
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6249_ALL_ENG_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('ENG_PERSON.ENG_PREDEL_VALIDATION', 2);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    eng_current_scheduled_dates     eng
                where   eng.employee_id  in (select party_id
					    from hz_parties
		                            where person_identifier = to_char(p_person_id)));
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6271_ALL_ENG2_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('ENG_PERSON.ENG_PREDEL_VALIDATION', 3);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    eng_ecn_approvers       eng
                where   eng.employee_id         = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6272_ALL_ENG3_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('ENG_PERSON.ENG_PREDEL_VALIDATION', 4);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    eng_eng_changes_interface       eng
                where   eng.requestor_id in (select party_id
                                            from hz_parties
                                            where person_identifier = to_char(p_person_id)));
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6273_ALL_ENG4_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
  END eng_predel_validation;
--
END eng_person;

/
