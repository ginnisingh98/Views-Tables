--------------------------------------------------------
--  DDL for Package Body SSPWSENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSPWSENT_PKG" as
/* $Header: sspwsent.pkb 120.1 2005/06/15 03:20:58 tukumar noship $ */

procedure fetch_maternity_details (
	--
	p_maternity_ID	in number,
	p_SMP_due_date	out NOCOPY date,
	p_person_ID	out NOCOPY number,
	p_matching_date out NOCOPY date
	) is
	--
cursor c1 is
	--
	select	due_date,
		person_ID,
		matching_date
	from	ssp_maternities MAT
	where	mat.maternity_ID = p_maternity_ID;
	--
begin
--
open c1;
fetch c1 into	p_SMP_due_date,
		p_person_ID,
		p_matching_date;
close c1;
--
end fetch_maternity_details;
--------------------------------------------------------------------------------

  PROCEDURE fetch_absence_details (p_absence_id in number,
				   p_ABSENCE_CATEGORY out NOCOPY varchar2,
				   P_PERSON_ID out NOCOPY number,
				   p_SICKNESS_START_DATE out NOCOPY date,
				   p_SICKNESS_END_DATE out NOCOPY  date,
				   P_MATERNITY_ID out NOCOPY number,
				   P_SMP_DUE_DATE out NOCOPY date,
				   P_LINKED_ABSENCE_ID out NOCOPY number) is
    cursor c1 is
      select ABSENCE_CATEGORY,
	     PERSON_ID,
	     SICKNESS_START_DATE,
	     SICKNESS_END_DATE,
	     MATERNITY_ID,
	     SMP_DUE_DATE,
	     LINKED_ABSENCE_ID
      from per_absence_attendances_v
      where ABSENCE_ATTENDANCE_ID = p_absence_id;
  BEGIN
    open c1;
    fetch c1 into p_ABSENCE_CATEGORY,
		  P_PERSON_ID,
		  p_SICKNESS_START_DATE,
		  p_SICKNESS_END_DATE,
		  P_MATERNITY_ID,
		  P_SMP_DUE_DATE,
		  P_LINKED_ABSENCE_ID;
    close c1;
  END fetch_absence_details;
--------------------------------------------------------------------------------
function fetch_element_type (p_effective_date in date,
			     p_absence_category varchar2)  return number is
lv_element_type_id pay_element_types_f.element_type_id%type;
lv_element_name       pay_element_types_f.element_name%TYPE ;

cursor csr_element_details (p_element_name varchar2 ) is
select element_type_id
from  pay_element_types_f
where   element_name = p_element_name
and     p_effective_date between effective_start_date
and     effective_end_date;
begin
if p_absence_category = 'S' then
   lv_element_name := SSP_SSP_PKG.c_SSP_element_name;
elsif p_absence_category = 'M' then
   lv_element_name := SSP_SMP_PKG.c_SMP_element_name;
elsif p_absence_category = 'GB_ADO' then
   lv_element_name := SSP_SAP_PKG.c_SAP_element_name;
elsif p_absence_category = 'GB_PAT_BIRTH' then
   lv_element_name := SSP_PAB_PKG.c_PAB_element_name;
elsif p_absence_category = 'GB_PAT_ADO' then
   lv_element_name := SSP_PAD_PKG.c_PAD_element_name;
end if;

open csr_element_details (lv_element_name);
fetch csr_element_details into lv_element_type_id;
return lv_element_type_id;
end fetch_element_type;
--------------------------------------------------------------------------------

END SSPWSENT_PKG;

/
