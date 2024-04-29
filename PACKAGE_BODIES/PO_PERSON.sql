--------------------------------------------------------
--  DDL for Package Body PO_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PERSON" AS

/* $Header: popredeb.pls 115.0 99/07/17 02:27:14 porting ship $ */

--
  /*
    NAME
      po_predel_validation
    DESCRIPTION
      Foreign key reference check.
  */
  --
  PROCEDURE po_predel_validation (p_person_id	number)
  IS
  --
  v_delete_permitted	varchar2(1);
  --
  BEGIN
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 1);
      --
      begin
	select	'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_vendors			pov
		where	pov.employee_id			= P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6246_ALL_PO_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 2);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	hr_locations			hr
		where	hr.designated_receiver_id	= P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6250_ALL_PO2_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 3);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_agents	po
		where	po.agent_id	= P_PERSON_ID);
       exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6251_ALL_PO3_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 4);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_acceptances	po
		where	po.employee_id	= P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6252_ALL_PO4_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 5);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_quotation_approvals_all	po
		where	po.approver_id	= P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6253_ALL_PO5_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 6);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_headers_all	po
		where	po.agent_id	= P_PERSON_ID)
	and	not exists (
                select  null
                from    po_headers_archive_all po
                where   po.agent_id     = P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6256_ALL_PO8_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 7);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_distributions_all	po
		where	po.deliver_to_person_id	= P_PERSON_ID)
	and	not exists (
		select	null
		from	po_distributions_archive_all po
		where	po.deliver_to_person_id = P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6257_ALL_PO9_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 8);
      --
      begin
       null;
       /* po_notifications_all is obsolete in R11
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_notifications_all	po
		where	po.employee_id		= P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6261_ALL_PO11_PER_NO_DEL');
		hr_utility.raise_error;
        */
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 9);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_releases_all	po
		where	po.agent_id	= P_PERSON_ID
                or      po.cancelled_by = P_PERSON_ID
		or	po.hold_by	= P_PERSON_ID)
	and	not exists (
                select  null
                from    po_releases_archive_all	po
                where   po.agent_id     = P_PERSON_ID
                or      po.cancelled_by = P_PERSON_ID
                or      po.hold_by      = P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6265_ALL_PO15_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 10);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_requisitions_interface_all	po
		where	po.approver_id			= P_PERSON_ID
		or	po.deliver_to_requestor_id	= P_PERSON_ID
		or	po.suggested_buyer_id		= P_PERSON_ID
		or	po.preparer_id			= P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6266_ALL_PO16_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 11);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_requisition_headers_all	po
		where	po.preparer_id		= P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6267_ALL_PO17_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 12);
      --
      begin
	select 'Y'
	into	v_delete_permitted
	from	sys.dual
	where	not exists (
		select	null
		from	po_requisition_lines_all	po
		where	po.to_person_id		= P_PERSON_ID
		or	po.purchasing_agent_id	= P_PERSON_ID
		or	po.research_agent_id	= P_PERSON_ID);
      exception
 	when NO_DATA_FOUND then
		hr_utility.set_message (801, 'HR_6268_ALL_PO18_PER_NO_DEL');
		hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 13);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    po_action_history	po
		where   po.employee_id		= P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6255_ALL_PO19_PRE_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION',14);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    po_employee_hierarchies po
                where   po.employee_id          = P_PERSON_ID
		or	po.superior_id		= P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6260_ALL_PO20_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 15);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    po_lines_all	po
		where	po.cancelled_by	= P_PERSON_ID
		or	po.closed_by	= P_PERSON_ID)
	and	not exists (
                select  null
                from    po_lines_archive_all  po
                where   po.cancelled_by = P_PERSON_ID
		or	po.closed_by	= P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6264_ALL_PO21_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 16);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    po_line_locations_all	po
		where   po.cancelled_by = P_PERSON_ID
                or      po.closed_by    = P_PERSON_ID)
        and     not exists (
                select  null
                from    po_line_locations_archive_all  po
                where   po.cancelled_by = P_PERSON_ID
                or      po.closed_by    = P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6573_ALL_PO22_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
      hr_utility.set_location('PO_PERSON.PO_PREDEL_VALIDATION', 17);
      --
      begin
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (
                select  null
                from    po_reqexpress_lines_all	po
		where	po.suggested_buyer_id 	= P_PERSON_ID);
      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (801, 'HR_6574_ALL_PO23_PER_NO_DEL');
                hr_utility.raise_error;
      end;
      --
  END po_predel_validation;
--
END po_person;

/
