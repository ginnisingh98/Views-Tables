--------------------------------------------------------
--  DDL for Package Body HXT_TC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TC_UTIL" AS
/* $Header: hxttcutl.pkb 115.1 2002/06/10 00:38:38 pkm ship      $ */

FUNCTION get_tc_hrs_total(p_tim_id IN NUMBER) RETURN NUMBER IS

 CURSOR tot_hrs IS
  select sum(thw.hours)
  from hxt_sum_hours_worked  thw
   where thw.tim_id = p_tim_id
     and thw.element_type_id is null;

CURSOR tot_hrs2 IS
  select sum(thw.hours)
    from hxt_sum_hours_worked thw
        ,pay_element_types_f elt
        ,hxt_pay_element_types_f_ddf_v eltv
   where thw.tim_id = p_tim_id
     and thw.element_type_id is not null
     and thw.element_type_id = elt.element_type_id
     and elt.element_type_id = eltv.element_type_id
     and thw.date_worked between eltv.effective_start_date
                             and eltv.effective_end_date
     and eltv.hxt_earning_category in ('ABS','REG','OVT');

current_number_hours number;
hrs_type_hrs   NUMBER;

BEGIN

  if p_tim_id is null then
    return 0;
  end if;

  OPEN tot_hrs;
  FETCH tot_hrs into current_number_hours;
  IF tot_hrs%NOTFOUND then
     current_number_hours := 0;
  END IF;
  CLOSE tot_hrs;

  IF current_number_hours IS NULL THEN
    current_number_hours := 0;
  END IF;

  OPEN tot_hrs2;
  FETCH tot_hrs2 into hrs_type_hrs;
  IF tot_hrs2%NOTFOUND then
     hrs_type_hrs := 0;
  END IF;
  CLOSE tot_hrs2;

  IF hrs_type_hrs IS NULL THEN
    hrs_type_hrs := 0;
  END IF;

  RETURN (current_number_hours + hrs_type_hrs);
END;  -- get_tc_hrs_total

PROCEDURE update_approver(p_tim_row_id IN VARCHAR2,
p_approv_person_id   NUMBER,
p_approved_timestamp DATE,
p_last_updated_by    NUMBER,
p_last_update_date   DATE,
p_last_update_login  NUMBER
) is

begin

update HXT_TIMECARDS_F
set
approv_person_id = p_approv_person_id,
approved_timestamp = p_approved_timestamp,
last_updated_by = p_last_updated_by,
last_update_date = p_last_update_date,
last_update_login = p_last_update_login
where rowid = p_tim_row_id;

end   update_approver;

END hxt_tc_util;

/
