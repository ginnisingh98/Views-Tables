--------------------------------------------------------
--  DDL for Package Body OTA_PLE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_PLE_BUS" as
/* $Header: otple01t.pkb 115.3 99/07/16 00:52:56 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_ple_bus.';  -- Global package name
-- ici insert ple.cat
--*******************************************************************************
--                              PLE: ADDITIONAL API
--
-- Version    Date         Author       Reason
-- 10.15     31May95     lparient.FR    Price increase percentage can be negative
--*******************************************************************************
--
--                      ***************************
-- 			ADDITIONAL GLOBAL VARIABLES
--                      ***************************
--
g_dummy		integer(1);
g_end_of_time	date;
--
--
--            **************************************************
--            MANUALLY WRITTEN SECTION AND GENERATED API SECTION
--            **************************************************
--
-- procedure insert_validate2 must be called from generated procedure insert_validate.
-- procedure update_validate2 must be called from generated procedure update_validate.
-- procedure delete_validate2 must be called from generated procedure delete_validate.
--
-- Utilities (public procedures):
-- 	copy_entries
--	copy_price_list_entries
--
--*******************************************************************************
--
--==============================================================================
--			GENERAL PROCEDURES
--==============================================================================
Procedure constraint_error2
            (p_constraint_name varchar2) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error2';
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
if p_constraint_name = 'startdate_must_be_populated' then
	fnd_message.set_name('OTA','OTA_13457_GEN_MAND_START_DATE');
elsif p_constraint_name = 'enddate_must_be_greater_than_startdate' then
	fnd_message.set_name('OTA','OTA_13312_GEN_DATE_ORDER');
elsif p_constraint_name = 'minimum_attendees_should_be_positive' then
	fnd_message.set_name('OTA','OTA_13296_GEN_MINMAX_POS');
elsif p_constraint_name = 'maximum_should_be_greater_than_minimum' then
	fnd_message.set_name('OTA','OTA_13298_GEN_MINMAX_ORDER');
elsif p_constraint_name = 'price_list_must_be_polulated' then
        fnd_message.set_name('OTA','OTA_13573_PLE_PRICE_LIST_MAND');
elsif p_constraint_name = 'activityversion_or_vendorsupply_should_be_null' then
        fnd_message.set_name('OTA','OTA_13201_PLE_TAV_VSP_EXCL');
elsif p_constraint_name = 'price_list_doesnt_exist' Then
        fnd_message.set_name('OTA','OTA_13574_PLE_NO_PRICE_LIST');
elsif p_constraint_name = 'activity_version_doesnt_exist' Then
	fnd_message.set_name('OTA','OTA_13575_PLE_NO_ACTIVITY');
elsif p_constraint_name = 'minimum_attendees_should_be_null' then
        fnd_message.set_name('OTA','OTA_13576_PLE_MIN_MAX_ATTS');
elsif p_constraint_name = 'maximum_attendees_should_be_null' then
        fnd_message.set_name('OTA','OTA_13576_PLE_MIN_MAX_ATTS');
elsif p_constraint_name = 'minimum_attendees_should_be_populated' then
        fnd_message.set_name('OTA','OTA_13576_PLE_MIN_MAX_ATTS');
elsif p_constraint_name = 'maximum_attendees_should_be_populated' then
        fnd_message.set_name('OTA','OTA_13576_PLE_MIN_MAX_ATTS');
elsif p_constraint_name = 'wrong_copy_entries_dates' then
        fnd_message.set_name('OTA','OTA_13577_PLE_COPY_ENTRY_DATES');
elsif p_constraint_name = 'activity_and_vendor_cant_be_both_null' then
        fnd_message.set_name('OTA','OTA_13238_PLE_TAV_OR_VSP_NOTNU');
elsif p_constraint_name = 'price_basis_must_be_C_or_S' then
        fnd_message.set_name('OTA','OTA_13240_PLE_PRICE_BAS_DOMAIN');
elsif p_constraint_name = 'cple_overlapping' Then
        fnd_message.set_name('OTA','OTA_13208_PLE_C_OVERLAP');
elsif p_constraint_name = 'dple_overlapping' Then
        fnd_message.set_name('OTA','OTA_13210_PLE_D_OVERLAP');
elsif p_constraint_name = 'startdate_must_succeed_tpl_startdate' Then
        fnd_message.set_name('OTA','OTA_13374_PLE_DATES_TPL');
elsif p_constraint_name = 'enddate_must_precede_tpl_enddate' Then
        fnd_message.set_name('OTA','OTA_13374_PLE_DATES_TPL');
elsif p_constraint_name = 'startdate_must_succeed_tav_startdate' Then
        fnd_message.set_name('OTA','OTA_13375_PLE_DATES_TAV');
elsif p_constraint_name = 'enddate_must_precede_tav_enddate' Then
        fnd_message.set_name('OTA','OTA_13375_PLE_DATES_TAV');
elsif p_constraint_name = 'increase_is_a_percent' then
    fnd_message.set_name('OTA','OTA_13399_PLE_INCREASE_RANGE');
elsif p_constraint_name = 'wrong_rounding_factor' then
    fnd_message.set_name('OTA','OTA_13427_PLE_ROUNDING_FACTOR');
else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP',p_constraint_name);
    hr_utility.raise_error;
End If;
--
fnd_message.raise_error;
--
hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End constraint_error2;
--=============================================================================
--===============================================================================
procedure check_tpl
(
p_tpl_id		number
)
is
-------------
cursor csr_tpl is
	select 1 from ota_price_lists
	where price_list_id = p_tpl_id;
--
l_parent_exists		boolean;
-------------
begin
--
hr_utility.set_location('Entering: check_tpl', 5);
if p_tpl_id is null then
	constraint_error2('price_list_must_be_polulated');
else
hr_utility.trace('Check_tpl '||to_char(p_tpl_id));
	open csr_tpl;
	fetch csr_tpl into g_dummy;
	l_parent_exists := csr_tpl%found;
	if not l_parent_exists then
		constraint_error2('price_list_doesnt_exist');
	end if;
end if;
hr_utility.set_location('Leaving: check_tpl', 5);
--
end check_tpl;
--=============================================================================
--=============================================================================
procedure check_tav_vsp_exclusivity
(p_tav_id	number,
p_vsp_id	number
)
is
-----------
begin
hr_utility.set_location('Entering: check_tav_vsp_exclusively', 5);
if p_tav_id is not null and p_vsp_id is not null then
        constraint_error2('activityversion_or_vendorsupply_should_be_null');
elsif p_tav_id is null and p_vsp_id is null then
	constraint_error2('activity_and_vendor_cant_be_both_null');
end if;
hr_utility.set_location('Leaving: check_tav_vsp_exclusivity', 5);

--
end check_tav_vsp_exclusivity;
--=============================================================================
--=============================================================================
/* N.B. Vendor Supply Id is no longer used, however it is left here in
        order to maintain compatibility
*/
procedure check_tav_and_vsp
(
p_tav_id		number,
p_vsp_id		number
)
is
---------------------
cursor csr_tav is
	select 1 from ota_activity_versions
	where activity_version_id = p_tav_id;
--
l_parent_exists		boolean;
-------------

begin
hr_utility.set_location('Entering: check_tav_and_vsp', 5);
--
check_tav_vsp_exclusivity(p_tav_id,p_vsp_id);
--
if p_tav_id is not null then
	open csr_tav;
	fetch csr_tav into g_dummy;
	l_parent_exists := csr_tav%found;
	close csr_tav;
	if not l_parent_exists then
		constraint_error2('activity_version_doesnt_exist');
	end if;
end if;
hr_utility.set_location('Leaving: check_tav_and_vsp', 5);
--
end check_tav_and_vsp;
--=============================================================================
--=============================================================================
procedure check_pricebasis_attendees
(
p_price_basis		varchar2,
p_minattendees		number,
p_maxattendees		number
)
is
---------------
begin
hr_utility.set_location('Entering: check_pricebasis_attendees', 5);
--
if p_price_basis is null
or p_price_basis not in ('C','S') then
	constraint_error2('price_basis_must_be_C_or_S');
end if;
--
if p_price_basis = 'S' then
   if p_minattendees is not null then
	constraint_error2('minimum_attendees_should_be_null');
   end if;
   if p_maxattendees is not null then
	constraint_error2('maximum_attendees_should_be_null');
   end if;
elsif p_price_basis = 'C' then
   if p_minattendees is null then
	constraint_error2('minimum_attendees_should_be_populated');
   elsif p_minattendees < 1 then
	constraint_error2('minimum_attendees_should_be_positive');
   end if;
   if p_maxattendees is null then
	constraint_error2('maximum_attendees_should_be_populated');
   elsif p_maxattendees < p_minattendees then
	constraint_error2('maximum_should_be_greater_than_minimum');
   end if;
end if;
hr_utility.set_location('Leaving: check_pricebasis_attendees', 5);
--
end check_pricebasis_attendees;
--=============================================================================
--=============================================================================
function dates_are_in_order
(
p_startdate                 date,
p_enddate                   date
)
return boolean is
-------------------
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_startdate',p_startdate);
end chkp;
-------------------
begin
hr_utility.set_location('Entering: dates_are_in_order', 5);
--
chkp;
--
if p_enddate is null then
        return TRUE;
elsif p_enddate >= p_startdate then
        return TRUE;
else
        return FALSE;
end if;
--
hr_utility.set_location('Leaving: dates_are_in_order', 5);
end dates_are_in_order;
--==============================================================================
procedure check_dates_order
(
p_startdate                 date,
p_enddate                   date
)
is
-------------------
begin
hr_utility.set_location('Entering: check_dates_order', 5);
--
if p_startdate is null then
	constraint_error2('startdate_must_be_populated');
end if;
--
if not dates_are_in_order(p_startdate,p_enddate) then
        constraint_error2('enddate_must_be_greater_than_startdate');
end if;
hr_utility.set_location('Leaving: check_dates_order', 5);
--
end check_dates_order;
--============================================================================
--============================================================================
procedure check_table_constraints
(
p_rec		in OTA_PLE_SHD.g_rec_type
)
is
-------------
begin
hr_utility.set_location('Entering: check_table_constraints', 5);
--
check_tpl (
	p_tpl_id => p_rec.price_list_id);
--
check_tav_and_vsp (
	p_tav_id => p_rec.activity_version_id,
	p_vsp_id => p_rec.vendor_supply_id);
--
check_pricebasis_attendees (
	p_price_basis => p_rec.price_basis,
	p_minattendees => p_rec.minimum_attendees,
	p_maxattendees => p_rec.maximum_attendees);
--
check_dates_order (
	p_startdate => p_rec.start_date,
	p_enddate => p_rec.end_date);
--
hr_utility.set_location('Leaving: check_table_constraints', 5);
end check_table_constraints;
--===============================================================================
--===============================================================================
function return_tav_id
(
p_tav_id        number,
p_vsp_id        number
)
return number is
-------------
cursor csr_vsp is
  select activity_version_id from ota_vendor_supplies
  where vendor_supply_id = p_vsp_id;
--
l_activity_id           ota_activity_versions.activity_version_id%type;
--
procedure chkp is
-------------
begin
check_tav_vsp_exclusivity(p_tav_id,p_vsp_id);
end chkp;
---------
begin
hr_utility.set_location('Entering: return_tav_id', 5);
--
chkp;
--
if p_tav_id is null then
        open csr_vsp;
	fetch csr_vsp into l_activity_id;
	close csr_vsp;
else
        l_activity_id := p_tav_id;
end if;
--
return l_activity_id;
--
hr_utility.set_location('Leaving: return_tav_id', 5);
end return_tav_id;
--*****************************************************************************
--			DATES VALIDATION
-- See also overlapping
--*******************************************************************************
function start_succeeds_tpl_start
(
p_ple_startdate         date,
p_tpl_id                number
)
return boolean is
--
--*** Price list entry's start date must be >= Price list's start date
---------------------
cursor csr_tpl_date is
   select start_date
   from ota_price_lists
   where price_list_id = p_tpl_id;
--
l_tpl_startdate                 date;
--
l_parent_exists                 boolean;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_ple_startdate',p_ple_startdate);
hr_api.mandatory_arg_error(g_package,'start_succeeds_tpl_start:p_tpl_id',p_tpl_id);
end chkp;
------------------
begin
hr_utility.set_location('Entering: start_succeeds_tpl_start', 5);
--
chkp;
--
open csr_tpl_date;
fetch csr_tpl_date into l_tpl_startdate;
l_parent_exists := csr_tpl_date%found;
close csr_tpl_date;
--
if not l_parent_exists then
hr_utility.trace('start_succeeds_tpl_start ');
        constraint_error2('price_list_doesnt_exist');
end if;
--
if p_ple_startdate >= l_tpl_startdate then
        return TRUE;
else
        return FALSE;
end if;
--
hr_utility.set_location('Leaving: start_succeeds_tpl_start', 5);
end start_succeeds_tpl_start;
--==============================================================================
--==============================================================================
function start_succeeds_tav_start
(
p_ple_startdate         date,
p_tav_id                number
)
return boolean is
--
--*** Price list entry's start date must be >= Activity version start date
--*** Activity version id  may be null in ota_price_list_entries
---------------------
cursor csr_tav_date is
   select start_date
   from ota_activity_versions
   where activity_version_id = p_tav_id;
--
l_tav_startdate                 date;
--
l_parent_exists			boolean;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_ple_startdate',p_ple_startdate);
hr_api.mandatory_arg_error(g_package,'start_succeeds_tav_start:p_tav_id',p_tav_id);
end chkp;
------------------
begin
hr_utility.set_location('Entering: start_succeeds_tav_start', 5);
--
chkp;
--
open csr_tav_date;
fetch csr_tav_date into l_tav_startdate;
l_parent_exists := csr_tav_date%found;
close csr_tav_date;
--
if not l_parent_exists then
	constraint_error2('activity_version_doesnt_exist');
end if;
--
hr_utility.set_location('ple_startdate = '||to_char(p_ple_startdate
                                                   ,'DD-MON-YYYY'), 5);
hr_utility.set_location('l_tav_startdate = '||to_char(l_tav_startdate
                                                   ,'DD-MON-YYYY'), 5);
if l_tav_startdate is null then
	return TRUE;
elsif p_ple_startdate >= l_tav_startdate then
	return TRUE;
else
	return FALSE;
end if;
--
hr_utility.set_location('Leaving: start_succeeds_tav_start', 5);
end start_succeeds_tav_start;
--==============================================================================
--==============================================================================
function end_precedes_tpl_end
(
p_ple_enddate         date,
p_tpl_id                number
)
return boolean is
--
--*** Price list entry's end date must be <= Price list's end date
---------------------
cursor csr_tpl_date is
   select end_date
   from ota_price_lists
   where price_list_id = p_tpl_id;
--
l_tpl_enddate                 date;
--
l_parent_exists                 boolean;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'end_precedes_tpl_end:p_tpl_id',p_tpl_id);
end chkp;
------------------
begin
hr_utility.set_location('Entering: end_precedes_tpl_end', 5);
--
chkp;
--
open csr_tpl_date;
fetch csr_tpl_date into l_tpl_enddate;
l_parent_exists := csr_tpl_date%found;
close csr_tpl_date;
--
if not l_parent_exists then
	hr_utility.trace('end_precedes_tpl_end');
        constraint_error2('price_list_doesnt_exist');
end if;
--
hr_utility.trace('TPL End Date = '||to_char(l_tpl_enddate));
hr_utility.trace('PLE End Date = '||to_char(p_ple_enddate));
--
if l_tpl_enddate is null then
	return TRUE;
elsif nvl(p_ple_enddate,hr_general.end_of_time) <= l_tpl_enddate then
	return TRUE;
else
	return FALSE;
end if;
--
hr_utility.set_location('Leaving: end_precedes_tpl_end', 5);
end end_precedes_tpl_end;
--==============================================================================
--==============================================================================
function end_precedes_tav_end
(
p_ple_enddate			date,
p_tav_id                number
)
return boolean is
--
--*** Price list entry's must be <= Activity version's end date
--*** Activity version id  may be null in ota_price_list_entries
---------------------
cursor csr_tav_date is
   select end_date
   from ota_activity_versions
   where activity_version_id = p_tav_id;
--
l_tav_enddate			date;
--
l_parent_exists			boolean;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'end_precedes_tav_end:p_tav_id',p_tav_id);
end chkp;
--------------
begin
--
open csr_tav_date;
fetch csr_tav_date into l_tav_enddate;
l_parent_exists := csr_tav_date%found;
close csr_tav_date;
--
if not l_parent_exists then
        constraint_error2('activity_version_doesnt_exist');
end if;
--
if l_tav_enddate is null then
        return TRUE;
elsif nvl(p_ple_enddate,hr_general.end_of_time) <= l_tav_enddate then
        return TRUE;
else
        return FALSE;
end if;
--
end end_precedes_tav_end;
--==============================================================================
--==============================================================================
procedure check_ple_startdate
(
p_ple_startdate			date,
p_tpl_parent			number,
p_tav_parent			number
)
is
-----------------
begin
--
if not start_succeeds_tpl_start(p_ple_startdate,p_tpl_parent) then
	constraint_error2('startdate_must_succeed_tpl_startdate');
end if;
--
if not start_succeeds_tav_start(p_ple_startdate,p_tav_parent) then
        constraint_error2('startdate_must_succeed_tav_startdate');
end if;
--
end check_ple_startdate;
--==============================================================================
--==============================================================================
procedure check_ple_enddate
(
p_ple_enddate                 date,
p_tpl_parent                    number,
p_tav_parent                    number
)
is
-----------------
begin
--
if not end_precedes_tpl_end(p_ple_enddate,p_tpl_parent) then
        constraint_error2('enddate_must_precede_tpl_enddate');
end if;
--
if not end_precedes_tav_end(p_ple_enddate,p_tav_parent) then
        constraint_error2('enddate_must_precede_tav_enddate');
end if;
--
end check_ple_enddate;
--==============================================================================
--==============================================================================
procedure check_ple_dates
(
p_ple_startdate			date,
p_ple_enddate			date,
p_tpl_parent			number,
p_tav_parent			number
)
is
------------
begin
--
check_ple_startdate(p_ple_startdate,p_tpl_parent,p_tav_parent);
check_ple_enddate(p_ple_enddate,p_tpl_parent,p_tav_parent);
--
end check_ple_dates;
--*****************************************************************************
--			OVERLAPPING CHECKS
--*******************************************************************************
procedure check_ple_overlapping
(
p_ple_id		number,
p_tpl_id		number,
p_tav_id		number,
p_vsp_id                number,
p_price_basis           varchar2,
p_start_date            date,
p_end_date              date,
p_minattendees          number,
p_maxattendees          number
)
is
--
--*** For PLE based on Customer (price_basis = 'C'),the dates of 2 PLE
--*** may overlap only when their attendance ranges do not overlap.
--*** For other PLEs, dates may never overlap.
--*** NB: p_ple_id must be null if it's an INSERT.
--
----------------
cursor csr_dple is
   select 1
   from ota_price_list_entries
   where price_list_id = p_tpl_id
     and nvl(activity_version_id,0) = nvl(p_tav_id,0)
     and nvl(vendor_supply_id,0) = nvl(p_vsp_id,0)
     and price_basis = p_price_basis
     and p_start_date <= nvl(end_date,g_end_of_time)
     and nvl(p_end_date,g_end_of_time) >= start_date
     and (p_ple_id is null or price_list_entry_id <> p_ple_id);
--
cursor csr_cple is
   select 1
   from ota_price_list_entries
   where price_list_id = p_tpl_id
     and nvl(activity_version_id,0) = nvl(p_tav_id,0)
     and nvl(vendor_supply_id,0) = nvl(p_vsp_id,0)
     and price_basis = p_price_basis
     and p_start_date <= nvl(end_date,g_end_of_time)
     and nvl(p_end_date,g_end_of_time) >= start_date
     and p_minattendees <= maximum_attendees
     and p_maxattendees >= minimum_attendees
     and (p_ple_id is null or price_list_entry_id <> p_ple_id);
--
l_found		boolean;
l_dummy		integer;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'check_ple_overlapping:p_tpl_id',p_tpl_id);
check_tav_and_vsp(p_tav_id,p_vsp_id);
check_pricebasis_attendees(p_price_basis,p_minattendees,p_maxattendees);
hr_api.mandatory_arg_error(g_package,'p_start_date',p_start_date);
end chkp;
-------------------------
begin
--
chkp;
--
g_end_of_time := hr_general.end_of_time;
--
if p_price_basis = 'C' then
	open csr_cple;
	fetch csr_cple into l_dummy;
	l_found := csr_cple%found;
	close csr_cple;
	if l_found then
	  constraint_error2('cple_overlapping');
	end if;
else
	open csr_dple;
	fetch csr_dple into l_dummy;
	l_found := csr_dple%found;
	close csr_dple;
        if l_found then
          constraint_error2('dple_overlapping');
        end if;
end if;
--
end check_ple_overlapping;
--******************************************************************************
--			GENERAL VALIDATION PROCEDURES
--********************************************************************************
procedure insert_and_update_validate
(
p_rec in OTA_PLE_SHD.g_rec_type
)
is
---------------------
l_tav_id	ota_activity_versions.activity_version_id%type;
--
begin
--
check_table_constraints (p_rec);
--
l_tav_id := return_tav_id(p_rec.activity_version_id,p_rec.vendor_supply_id);
check_ple_dates (
		p_ple_startdate => p_rec.start_date,
		p_ple_enddate => p_rec.end_date,
		p_tpl_parent => p_rec.price_list_id,
		p_tav_parent => l_tav_id);
--
check_ple_overlapping (
		p_ple_id => p_rec.price_list_entry_id,
                p_tpl_id => p_rec.price_list_id,
                p_tav_id => p_rec.activity_version_id,
                p_vsp_id => p_rec.vendor_supply_id,
                p_price_basis => p_rec.price_basis,
                p_start_date => p_rec.start_date,
                p_end_date => p_rec.end_date,
                p_minattendees => p_rec.minimum_attendees,
                p_maxattendees => p_rec.maximum_attendees);

--
end insert_and_update_validate;
--==============================================================================
--==============================================================================
procedure insert_validate2
(
p_rec in OTA_PLE_SHD.g_rec_type
)
is
---------------------
begin
--
insert_and_update_validate(p_rec);
--
end insert_validate2;
--==============================================================================
--==============================================================================
procedure update_validate2
(
p_rec in OTA_PLE_SHD.g_rec_type
)
is
---------------------
begin
--
insert_and_update_validate(p_rec);
--
end update_validate2;
--==============================================================================
procedure delete_validate2
(
p_rec in OTA_PLE_SHD.g_rec_type
)
is
---------------------
begin
--
return;
--
end delete_validate2;
--*********************************************************************
--***********************************************************************
function return_new_price (
	p_old_price		number,
	p_price_increase	number,
	p_rounding_direction	varchar2,
	p_rounding_factor	number
)
return number is
---------------------
l_new_price		OTA_PRICE_LIST_ENTRIES.price%TYPE;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'old_price_list_price',p_old_price);
if p_price_increase is null then
        constraint_error2('increase_is_a_percent');
elsif p_price_increase < -100  or p_price_increase > 100 then
        constraint_error2('increase_is_a_percent');
end if;
if p_rounding_direction not in ('N','U','D','R') then
   constraint_error2('rounding_direction_wrong_value');
end if;
if p_rounding_direction <> 'N' and (p_rounding_factor is null or p_rounding_factor=0) then
   constraint_error2('wrong_rounding_factor');
end if;
end chkp;
--------------------
begin
hr_utility.set_location('Entering: return_new_price', 5);
--
chkp;
--
l_new_price := (p_old_price * p_price_increase /100) + p_old_price;
--
if p_rounding_direction = 'D' then
   l_new_price := p_rounding_factor*(floor(l_new_price/p_rounding_factor));
--
elsif p_rounding_direction = 'U' then
   l_new_price := p_rounding_factor*(ceil(l_new_price/p_rounding_factor));
--
elsif p_rounding_direction = 'R' then
   l_new_price := p_rounding_factor*(round(l_new_price/p_rounding_factor));
--
end if;
--
hr_utility.set_location('Leaving: return_new_price', 5);
return l_new_price;
--
end return_new_price;
--***********************************************************************
--***********************************************************************
procedure modify_entries
(
p_proc_use		number,
p_old_tpl_id		number,
p_price_increase	number,
p_rounding_direction	varchar2,
p_rounding_factor	number,
p_new_tpl_id		number,
p_dates_difference	number,
p_increase_date		date,
p_enddate		date,
p_starting_from		date,
p_old_startdate           date default null,
p_new_startdate           date default null,
p_old_enddate           date default null,
p_new_enddate           date default null
)
is
-----------------
--*** Create new entries based on existing Entries
--*** with new dates and a price increase.
--
l_plerec		ota_ple_shd.g_rec_type;
l_plerec2	ota_ple_shd.g_rec_type;
l_activity_version_id number;
l_activity_start_date date;
l_activity_end_date date;
l_start_date date;
l_end_date date;
--
cursor csr_plerec is
select
  ple.price_list_entry_id,
  ple.vendor_supply_id,
  ple.activity_version_id,
  ple.price_list_id,
  ple.object_version_number,
  ple.price,
  ple.price_basis,
  ple.start_date,
  ple.comments,
  ple.end_date,
  ple.maximum_attendees,
  ple.minimum_attendees,
  ple.ple_information_category,
  ple.ple_information1,
  ple.ple_information2,
  ple.ple_information3,
  ple.ple_information4,
  ple.ple_information5,
  ple.ple_information6,
  ple.ple_information7,
  ple.ple_information8,
  ple.ple_information9,
  ple.ple_information10,
  ple.ple_information11,
  ple.ple_information12,
  ple.ple_information13,
  ple.ple_information14,
  ple.ple_information15,
  ple.ple_information16,
  ple.ple_information17,
  ple.ple_information18,
  ple.ple_information19,
  ple.ple_information20
	from ota_price_list_entries ple
	where ple.price_list_id = p_old_tpl_id
	and ((p_proc_use = 2
             and ple.start_date >= nvl(p_starting_from,hr_api.g_sot)
             and not (ple.start_date > nvl(p_enddate,hr_api.g_eot)
                   or nvl(ple.end_date,hr_api.g_eot)
                    < nvl(p_increase_date,hr_api.g_sot)
                     )
            )
	or p_proc_use <>2);
--
cursor get_activity is
select start_date,end_date
from ota_activity_versions
where activity_version_id = l_activity_version_id;
--
l_copy	           boolean;
l_dates_difference number;
--
procedure chkp is
begin
if p_proc_use = 1 then
-- Copy price list and entries with price increase function.
   hr_api.mandatory_arg_error(g_package,'new_price_list_id',p_new_tpl_id);
   if not (p_increase_date is null and p_starting_from is null)  then
	constraint_error2('arguments_should_be_null_1');
   end if;
elsif p_proc_use = 2 then
-- Copy entries with price increase function.
hr_api.mandatory_arg_error(g_package,'old_price_list_id',p_old_tpl_id);
   if p_increase_date is null then
	constraint_error2('startdate_must_be_populated');
   end if;
   if not(p_new_tpl_id is null and p_dates_difference is null) then
	constraint_error2('arguments_should_be_null_2');
   end if;
-- Close down price list function.
elsif p_proc_use = 3 then
hr_api.mandatory_arg_error(g_package,'old_price_list_id',p_old_tpl_id);
   if not(p_new_tpl_id is null and p_dates_difference is null and p_increase_date is null
	and p_starting_from is null and p_price_increase is null
	and p_rounding_direction is null and p_rounding_factor is null) then
        constraint_error2('arguments_should_be_null_3');
   end if;
else
   constraint_error2('p_proc_use is wrong');
end if;
end chkp;
---------------------
begin
hr_utility.set_location('Entering: modify_entries', 5);
--
chkp;
-------------
open csr_plerec;
--
LOOP
--
hr_utility.trace('Price List ID '||to_char(p_old_tpl_id));
   l_copy := true;
   fetch csr_plerec into l_plerec;
   l_activity_version_id := l_plerec.activity_version_id;
   exit when csr_plerec%notfound;
--
---------------------------
-- Copy price list function
---------------------------
   if p_proc_use = 1 then
hr_utility.trace('Price List Entry ID '||to_char(l_plerec.price_list_entry_id));
      --
      open get_activity;
      fetch get_activity into l_activity_start_date,l_activity_end_date;
      close get_activity;
      --
      l_plerec.price_list_id := p_new_tpl_id;
--
      if p_new_startdate < p_old_startdate then
hr_utility.trace('New Start Date < Old Start Date');
         if p_old_startdate = l_plerec.start_date then
            l_plerec.start_date := greatest(p_new_startdate
                                           ,l_activity_start_date);
         end if;
      --
      elsif p_new_startdate > p_old_startdate then
hr_utility.trace('New Start Date > Old Start Date');
            l_plerec.start_date := greatest(l_plerec.start_date
                                           ,p_new_startdate);
      end if;
--
      if nvl(p_new_enddate,hr_api.g_eot) < nvl(p_old_enddate,hr_api.g_eot) then
hr_utility.trace('New End Date < Old End Date');
         if l_plerec.end_date is null and p_new_enddate is null then
            l_plerec.end_date := null;
         else
            l_plerec.end_date := least(nvl(p_new_enddate,hr_api.g_eot)
                                      ,nvl(l_plerec.end_date,hr_api.g_eot));
         end if;
      --
      elsif
         nvl(p_new_enddate,hr_api.g_eot) > nvl(p_old_enddate,hr_api.g_eot) then
hr_utility.trace('New End Date > Old End Date');
         if nvl(p_old_enddate,hr_api.g_eot) =
                            nvl(l_plerec.end_date,hr_api.g_eot) then
            if p_new_enddate is null and l_activity_end_date is null then
               l_plerec.end_date := null;
            else
               l_plerec.end_date := least(nvl(p_new_enddate,hr_api.g_eot)
                                        ,nvl(l_activity_end_date,hr_api.g_eot));
            end if;
         end if;
      --
      end if;
      --
hr_utility.trace('Start Date '||to_char(l_plerec.start_date));
hr_utility.trace('  End Date '||to_char(nvl(l_plerec.end_date,hr_api.g_eot)));
      if  l_plerec.start_date > nvl(l_plerec.end_date,hr_api.g_eot) then
          null;
      else
hr_utility.trace('Inserting Entry');
	  l_plerec.price_list_entry_id := null;
	  l_plerec.object_version_number := null;
	  l_plerec.price := return_new_price(l_plerec.price
                                            ,p_price_increase
                                            ,p_rounding_direction
                                            ,p_rounding_factor);
	  ota_ple_ins.ins(l_plerec,FALSE);
       end if;
--
-------------------------
-- Copy entries function
-------------------------
   elsif p_proc_use = 2 then
--
hr_utility.trace('Proc Use = 2');
hr_utility.trace('PLE Start Date '||to_char(l_plerec.start_date));
hr_utility.trace('PLE End Date '||to_char(l_plerec.end_date));
--
      if p_increase_date <= l_plerec.start_date then
         if    nvl(p_enddate,hr_api.g_eot)
            >= nvl(l_plerec.end_date,hr_api.g_eot) then
         --
hr_utility.trace('Updating the whole entry');
           l_plerec2 := l_plerec;
	   l_plerec2.price := return_new_price(l_plerec2.price
                                              ,p_price_increase
                                              ,p_rounding_direction
                                              ,p_rounding_factor);
	   ota_ple_upd.upd(l_plerec2,FALSE);
         --
         else --    nvl(p_enddate,hr_api.g_eot)
              --  < nvl(l_plerec.end_date,hr_api.g_eot)
         --
hr_utility.trace('Updating the entry up until the New End Date');
           l_plerec2 := l_plerec;
           l_plerec2.end_date := p_enddate;
           l_plerec2.price := return_new_price(l_plerec2.price
                                              ,p_price_increase
                                              ,p_rounding_direction
                                              ,p_rounding_factor);
           ota_ple_upd.upd(l_plerec2,FALSE);
           --
hr_utility.trace('Inserting the remainder of the entry with old price');
           l_plerec2 := l_plerec;
	   l_plerec2.price_list_entry_id := null;
	   l_plerec2.object_version_number := null;
           l_plerec2.start_date := p_enddate + 1;
           ota_ple_ins.ins(l_plerec2,FALSE);
         --
         end if;
      --
      else -- p_increase_date > l_plerec.start_date
      --
         if    nvl(p_enddate,hr_api.g_eot)
            >= nvl(l_plerec.end_date,hr_api.g_eot) then
         --
hr_utility.trace('Setting New End Date on old entry');
            l_plerec2 := l_plerec;
            l_plerec2.end_date := p_increase_date - 1;
            ota_ple_upd.upd(l_plerec2,FALSE);
         --
hr_utility.trace('Inserting new entry with updated price');
            l_plerec2 := l_plerec;
	    l_plerec2.price_list_entry_id := null;
	    l_plerec2.object_version_number := null;
            l_plerec2.start_date := p_increase_date;
            l_plerec2.price := return_new_price(l_plerec2.price
                                               ,p_price_increase
                                               ,p_rounding_direction
                                               ,p_rounding_factor);
            ota_ple_ins.ins(l_plerec2,FALSE);
         --
         else --   nvl(p_enddate,hr_api.g_eot)
              -- < nvl(l_plerec.end_date,hr_api.g_eot)
         --
hr_utility.trace('Setting New End Date on old entry');
            l_plerec2 := l_plerec;
            l_plerec2.end_date := p_increase_date - 1;
            ota_ple_upd.upd(l_plerec2,FALSE);
         --
hr_utility.trace('Inserting entry with new price');
            l_plerec2 := l_plerec;
	    l_plerec2.price_list_entry_id := null;
	    l_plerec2.object_version_number := null;
            l_plerec2.start_date := p_increase_date;
            l_plerec2.end_date   := p_enddate;
            l_plerec2.price := return_new_price(l_plerec2.price
                                               ,p_price_increase
                                               ,p_rounding_direction
                                               ,p_rounding_factor);
            ota_ple_ins.ins(l_plerec2,FALSE);
         --
hr_utility.trace('Inserting the remainder of the entry with old price');
            l_plerec2 := l_plerec;
	    l_plerec2.price_list_entry_id := null;
	    l_plerec2.object_version_number := null;
            l_plerec2.start_date := p_enddate + 1;
            ota_ple_ins.ins(l_plerec2,FALSE);
         --
         end if;
      --
      end if;
--
------------------------
-- Change Price List Entry Dates (called when Chnage Dates used)
------------------------
   elsif p_proc_use = 3 then
	l_copy := false;
        --
        open get_activity;
        fetch get_activity into l_activity_start_date,l_activity_end_date;
        close get_activity;
--
-- if the entry is outside of the new dates delete the entry
--
        if l_plerec.start_date >= nvl(p_new_enddate,hr_api.g_eot) or
           nvl(l_plerec.end_date,hr_api.g_eot) <= p_new_startdate then
                OTA_PLE_DEL.del(l_plerec,FALSE);
        else
--
-- if the start date is before the entry then open up the entry
--
          if l_plerec.start_date = p_old_startdate
         and l_plerec.start_date > p_new_startdate then
             --
             l_start_date := greatest(p_new_startdate
                                     ,l_activity_start_date);
             --
--
-- if the start date is after the entry start then close down the entry
--
          elsif l_plerec.start_date < p_new_startdate then
             --
             l_start_date := p_new_startdate;
          else
             l_start_date := l_plerec.start_date;
          end if;
          --
--
-- if the end date is after the entry start then open up the entry
--
          if nvl(l_plerec.end_date,hr_api.g_eot) =
             nvl(p_old_enddate,hr_api.g_eot)
         and nvl(l_plerec.end_date,hr_api.g_eot) <
             nvl(p_new_enddate,hr_api.g_eot) then
             --
             l_end_date := least(nvl(l_activity_end_date,hr_api.g_eot)
                                ,nvl(p_new_enddate,hr_api.g_eot));
             --
--
-- if the start date is after the entry start then close down the entry
--
          elsif  nvl(l_plerec.end_date,hr_api.g_eot) >
             nvl(p_new_enddate,hr_api.g_eot) then
             --
             l_end_date := p_new_enddate;
          else
             l_end_date := nvl(l_plerec.end_date,hr_api.g_eot);
          end if;
          --
          if l_end_date = hr_api.g_eot then
             l_plerec.end_date := null;
          end if;
          --
--
-- Only do the update if the Entry Start or End Dates have changed
--
          if l_plerec.start_date <> l_start_date
          or nvl(l_plerec.end_date,hr_api.g_eot) <> l_end_date then
             if l_end_date = hr_api.g_eot then
                l_plerec.end_date := null;
             else
                l_plerec.end_date := l_end_date;
             end if;
             l_plerec.start_date := l_start_date;
          --
             hr_utility.trace('Start Date = '||to_char(l_plerec.start_date));
             hr_utility.trace('  End Date = '||to_char(l_plerec.end_date));
             OTA_PLE_UPD.upd(l_plerec,FALSE);
          --
          end if;
       end if;
-----------------------
   end if;
-----------------------
END LOOP;
--
close csr_plerec;
--
hr_utility.set_location('Leaving: modify_entries', 5);
end modify_entries;
--***********************************************************************
--***********************************************************************
--
-- PUBLIC
--	Description: Create new entries based on existing Entries
--	with new dates and a price increase.
--
procedure copy_price_list_entries (
	p_price_list_id 	number,
	p_increase_date		date,
	p_enddate		date,
	p_increase_rate		number,
	p_round_direction	varchar2,
	p_round_factor		number,
	p_select_entries	char,
	p_starting_from		date
)
is
---------------
l_enddate	date;
l_dummy         varchar2(50);
--
--
procedure chkp is
begin
if not ( (p_select_entries='S' and p_starting_from is not null)
        or (p_select_entries='A' and p_starting_from is null) ) then
            constraint_error2('Copy_entries_wrong_parameters');
end if;
end chkp;
---------------
begin
hr_utility.set_location('Entering: copy_price_list_entries', 5);
--
chkp;
--
modify_entries (
  p_proc_use		=> 2,
  p_old_tpl_id		=> p_price_list_id,
  p_price_increase	=> p_increase_rate,
  p_rounding_direction	=> p_round_direction,
  p_rounding_factor	=> p_round_factor,
  p_new_tpl_id		=> null,
  p_dates_difference    => null,
  p_increase_date	=> p_increase_date,
  p_enddate		=> p_enddate,
  p_starting_from	=> p_starting_from );
--
hr_utility.set_location('Leaving: copy_price_list_entries', 5);
end copy_price_list_entries;
--=============================================================
--============================================================
--
-- PUBLIC: called from OTA_TPL_BUS
-- No client side procedure.
--
procedure copy_price_list (
	p_old_price_list_id	in number,
	p_new_price_list_id	in number,
        p_increase_rate         number,
        p_round_direction       varchar2,
        p_round_factor          number,
        p_old_startdate         date,
        p_new_startdate         date,
        p_old_enddate           date,
        p_new_enddate           date
)
is
---------------
begin
hr_utility.set_location('Entering: copy_price_list', 5);
--
modify_entries (
  p_proc_use            => 1,
  p_old_tpl_id          => p_old_price_list_id,
  p_price_increase      => p_increase_rate,
  p_rounding_direction  => p_round_direction,
  p_rounding_factor     => p_round_factor,
  p_new_tpl_id          => p_new_price_list_id,
  p_old_startdate       => p_old_startdate,
  p_new_startdate       => p_new_startdate,
  p_old_enddate         => p_old_enddate,
  p_new_enddate         => p_new_enddate,
  p_dates_difference    => null,
  p_increase_date       => null,
  p_enddate             => null,
  p_starting_from	=> null );
--
hr_utility.set_location('Leaving: copy_price_list', 5);
end copy_price_list;
--=============================================================
--=============================================================
--
-- PUBLIC: Called from OTA_TPL_BUS
--      Not a client-side procedure
--
procedure widen_entries_dates (
	p_price_list_id		in number
	,p_old_startdate	in date
	,p_new_startdate	in date
	,p_old_enddate		in date
	,p_new_enddate 		in date
    )
is
---------------
begin
hr_utility.set_location('Entering: widen_entries_dates', 5);
--
modify_entries (
   p_proc_use		=> 3
  ,p_old_tpl_id 	=> p_price_list_id
  ,p_price_increase 	=> null
  ,p_rounding_direction	=> null
  ,p_rounding_factor	=> null
  ,p_new_tpl_id		=> null
  ,p_dates_difference	=> null
  ,p_increase_date	=> null
  ,p_enddate		=> p_new_enddate
  ,p_starting_from	=> null
  ,p_old_startdate      => p_old_startdate
  ,p_new_startdate      => p_new_startdate
  ,p_old_enddate      => p_old_enddate
  ,p_new_enddate      => p_new_enddate
);
--
hr_utility.set_location('Leaving: widen_entries_dates', 5);
end widen_entries_dates;


-- ----------------------------------------------------------------------------
-- |-----------------------------< copy_price >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Copies all pricelistentry information from a given activity version to
--   another activity version.
--
Procedure copy_price
  (
   p_activity_version_from in  number
  ,p_activity_version_to   in  number
  ) is
  --
  l_rec		          ota_price_list_entries%rowtype;
  v_proc                  varchar2(72) := g_package||'copy_price';
  --
  cursor sel_price is
    select *
      from ota_price_list_entries      ple
     where ple.activity_version_id     =  p_activity_version_from;
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_price;
  fetch sel_price into l_rec;
  --
  Loop
    --
    Exit When sel_price%notfound;
    --
    OTA_PLE_INS.ins( l_rec.price_list_entry_id
       , l_rec.vendor_supply_id
       , p_activity_version_to
       , l_rec.price_list_id
       , l_rec.object_version_number
       , l_rec.price
       , l_rec.price_basis
       , l_rec.start_date
       , l_rec.comments
       , l_rec.end_date
       , l_rec.maximum_attendees
       , l_rec.minimum_attendees
       , l_rec.ple_information_category
       , l_rec.ple_information1
       , l_rec.ple_information2
       , l_rec.ple_information3
       , l_rec.ple_information4
       , l_rec.ple_information5
       , l_rec.ple_information6
       , l_rec.ple_information7
       , l_rec.ple_information8
       , l_rec.ple_information9
       , l_rec.ple_information10
       , l_rec.ple_information11
       , l_rec.ple_information12
       , l_rec.ple_information13
       , l_rec.ple_information14
       , l_rec.ple_information15
       , l_rec.ple_information16
       , l_rec.ple_information17
       , l_rec.ple_information18
       , l_rec.ple_information19
       , l_rec.ple_information20
       , false );
    --
    fetch sel_price into l_rec;
    --
  End Loop;
  --
  close sel_price;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End copy_price;
--
--******************************************************************************
--                              END OF MANUALLY WRITTEN SECTION
--******************************************************************************
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_ple_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
	insert_validate2(p_rec);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< handle_leap_years >---------------------------
-- ----------------------------------------------------------------------------
Procedure handle_leap_years(p_start_date in out date,
                            p_dates_difference  number,
                            p_difference        number) is
--
  l_proc  varchar2(72) := g_package||'handle_leap_years';
  l_old_start_date date;
  l_days           number;
  l_new_days       number := 0;
  l_old_start_year number;
  l_old_leap_days  number;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_dates_difference is not null then
     l_old_start_date := p_start_date;
     l_days := p_dates_difference;
     l_old_leap_days := p_difference;
     --
     -- we have to consider what to do for dates that have included a leap year.
     --
     l_old_start_year := to_number(to_char(l_old_start_date,'YYYY'));
     for counter in 1..l_days loop
       --
       -- Check if leap year
       --
       l_old_start_date := l_old_start_date + 1;
       l_old_start_year := to_number(to_char(l_old_start_date,'YYYY'));
       if mod(l_old_start_year,4) = 0 then
          --
	  -- Check if day is 29th February. if so add a day to p_start_date
	  --
	  if to_char(l_old_start_date,'DD/MM') = '29/02' then
            if l_old_leap_days = 0 then
               p_start_date := p_start_date + 1;
	       l_days := l_days + 1;
            else
               l_old_leap_days := l_old_leap_days - 1;
            end if;
	  end if;
       end if;
     end loop;
  end if;
  if l_old_leap_days > 0 then
    p_start_date := p_start_date - l_old_leap_days;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End handle_leap_years;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< consider_leap_years >-------------------------
-- ----------------------------------------------------------------------------
Procedure consider_leap_years(p_old_tpl_id              number,
                              p_dates_difference in out number) is
--
  l_proc  varchar2(72) := g_package||'consider_leap_years';
  cursor c1 is
    select start_date
    from ota_price_lists
    where price_list_id = p_old_tpl_id;
  l_old_start_date date;
  l_days           number := 0;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
     fetch c1 into l_old_start_date;
     if c1%found then
        for counter in 1..p_dates_difference loop
           l_old_start_date := l_old_start_date + 1;
           --
           -- Check if day is 29th February. if so add a day to p_start_date
           --
           if to_char(l_old_start_date,'DD/MM') = '29/02' then
              l_days := l_days + 1;
           end if;
        end loop;
     end if;
  close c1;
  if l_days > 0 then
     p_dates_difference := l_days;
  else
     p_dates_difference := 0;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End consider_leap_years;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ota_ple_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
	update_validate2(p_rec);
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_ple_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
	delete_validate2(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_ple_bus;

/
