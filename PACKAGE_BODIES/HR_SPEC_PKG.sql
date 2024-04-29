--------------------------------------------------------
--  DDL for Package Body HR_SPEC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SPEC_PKG" as
/* $Header: hrspec.pkb 115.4 99/07/17 05:37:04 porting sh $ */
------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
	HR Libraries server-side agent
Purpose
	Agent handles all server-side traffic to and from forms libraries. This
	is particularly necessary because we wish to avoid the situation where
	a form and its libraries both refer to the same server-side package.
	Forms/libraries appears to be unable to cope with this situation in
	circumstances which we cannot yet define.
History
	21 Apr 95	N Simpson	Created
	17 May 95	N Simpson	Added delete_ownerships,
					insert_ownerships and
					startup_insert_allowed to
					remove all sql from client side and
					thus allow library to be made global
        06 Sep 95       S Desai         Added test_path_to_perbecvd
					      test_path_to_perbeben
        08 Sep 95	D Kerr		Changed datatype of parameter
					chk_asg_on_payroll from %TYPE to
					number. Workaround for forms bug.
	11 Mar 96       D Kerr		Added checkformat and changeformat
	19 Aug 97	Sxshah	Banner now on eack line.
	21 Aug 97       V Treiger       Added procedures per_date_range and
	                                asg_date_range.
        21 May 98       D Kerr          Added overload for chk_asg_payroll
                                        620733.
        06 Apr 99       S Doshi         Flexible Dates Conversion
115.4   21 Apr 99       cborrett.uk     Multiradix conversion.
*/
g_dummy	number;
--
procedure test_path_to_perwsspp (p_ass_id    NUMBER) is
--
begin
per_spinal_pt_plcmt_pkg.test_path_to_perwsspp (p_ass_id);
--
end test_path_to_perwsspp;
--
procedure test_path_to_perbecvd ( p_element_entry_id NUMBER )is
--
begin
    ben_covered_dependents_pkg.test_path_to_perbecvd (p_element_entry_id);
end test_path_to_perbecvd;
--
procedure test_path_to_perbeben (p_element_entry_id NUMBER ) is
--
begin
    ben_beneficiaries_pkg.test_path_to_perbeben (p_element_entry_id);
end test_path_to_perbeben;
--
procedure chk_asg_on_payroll
  (p_assignment_id  in NUMBER
    ) is
begin
--
pay_qpq_api.chk_asg_on_payroll (p_assignment_id);
--
end chk_asg_on_payroll;
--620733. For some reason the payment methods package takes a varchar
--rather than a date as a parameter. Making the current routine take
--a date for simplicity.
--
procedure chk_asg_on_payroll
  (p_assignment_id  in NUMBER,
   p_effective_date in DATE
    ) is
begin
--
  pay_payment_methods_pkg.check_asg_on_payroll (p_assignment_id,
                                                fnd_date.date_to_canonical(p_effective_date));
--
end;
-----------------------------------------------------------------
function startup_insert_allowed (p_session_id	number) return boolean is
--
-- Returns TRUE if there is a row in hr_owner_definitions for the users
-- session (ie the first session they open with forms), which indicates
-- that startup data may be inserted by the user.
--
cursor csr_ownership is
	select	1
	from	hr_owner_definitions
	where	session_id = p_session_id;
	--
l_insert_allowed	boolean := FALSE;
--
begin
--
open csr_ownership;
fetch csr_ownership into g_dummy;
l_insert_allowed := csr_ownership%found;
close csr_ownership;
--
return l_insert_allowed;
--
end startup_insert_allowed;
-------------------------------------------------------------------------
procedure insert_ownerships (
--
-- Inserts ownerships for startup data
--
	--
	p_session_id	number,
	p_key_name	varchar2,
	p_key_value	number) is
	--
cursor csr_definition is
	select	product_short_name
	from	hr_owner_definitions
	where	session_id = p_session_id;
	--
begin
--
for product in csr_definition LOOP
  --
  insert into hr_application_ownerships (
	--
	key_name,
	key_value,
	product_name)
	--
  values (
	p_key_name,
	fnd_number.number_to_canonical(p_key_value),
	product.product_short_name);
	--
end loop;
--
end insert_ownerships;
-------------------------------------------------------------------------
procedure delete_ownerships (
--
-- Deletes ownerships for startup data
--
	--
	p_key_name	varchar2,
	p_key_value	number) is
	--
begin
--
delete from hr_application_ownerships
where key_name = p_key_name
and key_value = fnd_number.number_to_canonical(p_key_value);
--
end delete_ownerships;
-------------------------------------------------------------------------

procedure checkformat
( value   in out varchar2,
  format  in     varchar2,
  output  in out varchar2,
  minimum in     varchar2,
  maximum in     varchar2,
  nullok  in     varchar2,
  rgeflg  in out varchar2,
  curcode in     varchar2
) is
begin
--
   hr_chkfmt.checkformat( value,
			  format,
			  output,
			  minimum,
			  maximum,
			  nullok,
			  rgeflg,
			  curcode ) ;
--
end checkformat ;
-------------------------------------------------------------------------
procedure changeformat
( input   in     varchar2,
  output  out    varchar2,
  format  in     varchar2,
  curcode in     varchar2
) is
begin
--
  hr_chkfmt.changeformat ( input,
			   output,
			   format,
			   curcode ) ;
--
end changeformat ;
-------------------------------------------------------------------------
-------------------------------------------------------------------------
procedure per_date_range
( p_person_id  in      number,
  p_date_from  in out  date,
  p_date_to    in out  date
) is
begin
--
  per_people3_pkg.get_date_range ( p_person_id,
			           p_date_from,
			           p_date_to ) ;
--
end per_date_range ;
-------------------------------------------------------------------------
procedure asg_date_range
( p_assignment_id  in      number,
  p_date_from      in out  date,
  p_date_to        in out  date
) is
begin
--
  per_people3_pkg.get_asg_date_range ( p_assignment_id,
			               p_date_from,
			               p_date_to ) ;
--
end asg_date_range ;
-------------------------------------------------------------------------
end	hr_spec_pkg;

/
