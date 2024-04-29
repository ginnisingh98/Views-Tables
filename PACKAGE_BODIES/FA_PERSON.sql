--------------------------------------------------------
--  DDL for Package Body FA_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_PERSON" as
/* $Header: fapkperb.pls 120.2.12010000.3 2009/08/05 14:40:01 bridgway ship $ */


  PROCEDURE fa_predel_validation (p_person_id	number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
  IS
  --
  v_delete_permitted	varchar2(1);
  --
  BEGIN
    --
    hr_utility.set_location('FA_PERSON.FA_PREDEL_VALIDATION', 1);
    --
      begin
	select 'Y'
	into	v_delete_permitted
	from	dual
	where	not exists (
		select	'X'
		from	fa_massadd_distributions md
		where	md.employee_id = P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6248_ALL_FA_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('FA_PERSON.FA_PREDEL_VALIDATION', 2);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	dual
	where	not exists (
		select	'X'
		from	fa_distribution_history	dh
		where	dh.assigned_to = P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6269_ALL_FA2_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('FA_PERSON.FA_PREDEL_VALIDATION', 3);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	dual
	where	not exists (
		select	'X'
		from	fa_mass_transfers	mt
		where	mt.from_employee_id = P_PERSON_ID
		or	mt.to_employee_id = P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6270_ALL_FA3_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
  END fa_predel_validation;
--
END FA_PERSON;

/
