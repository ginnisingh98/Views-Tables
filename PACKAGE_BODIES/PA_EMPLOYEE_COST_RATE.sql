--------------------------------------------------------
--  DDL for Package Body PA_EMPLOYEE_COST_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EMPLOYEE_COST_RATE" as
/* $Header: PAXSUECB.pls 120.2 2005/08/10 04:23:25 avajain noship $ */
procedure check_overlapping_date(v_person_id varchar2,
                                v_err_code in out NOCOPY number,
                                v_mesg in out NOCOPY varchar2) is
  v_temp       varchar2(1);
  cursor c is
  select 'X'
  from pa_compensation_details a, pa_compensation_details b
  where a.person_id = v_person_id
  and   b.person_id = v_person_id
  and   a.rowid <> b.rowid
  and ((a.start_date_active
        between b.start_date_active
        and nvl(b.end_date_active,a.start_date_active +1))
  or   (a.end_date_active
        between b.start_date_active
        and nvl(b.end_date_active,b.end_date_active +1))
  or   (b.start_date_active
        between a.start_date_active
        and nvl(a.end_date_active,b.start_date_active +1))
      );
BEGIN
  open c;
  fetch c into v_temp;
  if c%found then
    v_err_code :=1;
  else
    v_err_code :=0;
  end if;
  close c;
EXCEPTION
  when others then
    v_err_code :=2;
    v_mesg := to_char(sqlcode);
END check_overlapping_date;

END;

/
