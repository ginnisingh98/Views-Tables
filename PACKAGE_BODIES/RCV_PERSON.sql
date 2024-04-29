--------------------------------------------------------
--  DDL for Package Body RCV_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_PERSON" AS
/* $Header: rvpredeb.pls 115.0 99/07/17 02:31:02 porting ship $ */

--
  /*
    NAME
      rcv_predel_validation
    DESCRIPTION
      Foreign key reference check.
  */
  --
  PROCEDURE rcv_predel_validation (p_person_id	number)
  IS
  --
  v_delete_permitted	varchar2(1);
  --
  BEGIN
      --
      hr_utility.set_location('RCV_PERSON.RCV_PREDEL_VALIDATION', 18);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    rcv_shipment_headers	rcv
		where	rcv.employee_id		= P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6575_ALL_PO24_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('RCV_PERSON.RCV_PREDEL_VALIDATION', 19);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    rcv_shipment_lines	rcv
                where   rcv.employee_id         = P_PERSON_ID
		or	rcv.deliver_to_person_id = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6581_ALL_PO25_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('RCV_PERSON.RCV_PREDEL_VALIDATION', 20);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    rcv_transactions	rcv
		where	rcv.employee_id         = P_PERSON_ID
                or	rcv.deliver_to_person_id = P_PERSON_ID)
	and	not exists (
                select  null
                from    rcv_transactions_interface rcv
                where   rcv.employee_id         = P_PERSON_ID
                or      rcv.deliver_to_person_id = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6582_ALL_PO26_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
  END rcv_predel_validation;
--
END rcv_person;

/
