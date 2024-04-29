--------------------------------------------------------
--  DDL for Package Body OTA_TPL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPL_BUS" as
/* $Header: ottpl01t.pkb 115.2 99/07/16 00:55:57 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tpl_bus.';  -- Global package name
--
-- ici insert tpl.cat
--*******************************************************************************
--                         	TPL: ADDITIONAL API
--
-- Version    Date         Author       Reason
-- 10.15     27Apr95     lparient.FR    Reviewed error messages
--
--*******************************************************************************
--
--                      ***************************
--                      ADDITIONAL GLOBAL VARIABLES
--                      ***************************
--
g_dummy         integer(1);
g_end_of_time   date;
g_update 	boolean;
--
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
--      procedure copy_price_list
--      procedure change_price_list_dates
--	procedure check_single_name
--
--*******************************************************************************
--
--============================================================================
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
if p_constraint_name = 'flag_must_be_populated' then
    fnd_message.set_name('OTA','OTA_13567_TPL_DEFAULT_FLAG');
elsif p_constraint_name = 'tpl_name_and_date_is_mandatory' then
    fnd_message.set_name('OTA','OTA_13566_TPL_COPY_PRICE_LIST');
elsif p_constraint_name = 'tpl_name_is_mandatory' then
    fnd_message.set_name('OTA','OTA_13568_TPL_PRICE_LIST_NAME');
elsif p_constraint_name = 'single_unit_price_should_be_populated' then
    fnd_message.set_name('OTA','OTA_13569_TPL_SINGLE_UNIT');
elsif p_constraint_name = 'training_unit_type_should_be_populated' then
    fnd_message.set_name('OTA','OTA_13569_TPL_SINGLE_UNIT');
--
elsif p_constraint_name = 'price_list_doesnt_exist' then
    fnd_message.set_name('OTA','OTA_13570_TPL_PRICE_LIST_NAME');
elsif p_constraint_name = 'price_list_type_must_be_populated' then
    fnd_message.set_name('OTA','OTA_13571_TPL_LIST_TYPE');
elsif p_constraint_name = 'single_unit_price_should_be_null' then
    fnd_message.set_name('OTA','OTA_13572_TPL_SINGLE_UNIT_NULL');
elsif p_constraint_name = 'training_unit_type_should_be_null' then
    fnd_message.set_name('OTA','OTA_13572_TPL_SINGLE_UNIT_NULL');
elsif p_constraint_name = 'undeletable_child_tbd_exists' then
    fnd_message.set_name('OTA','OTA_13228_TPL_TBD_EXISTS');
--
elsif p_constraint_name = 'tpl_name_already_exists' then
    fnd_message.set_name('OTA','OTA_13258_TPL_WRONG_NAME');
elsif (p_constraint_name = 'default_price_list_already_exists') Then
    fnd_message.set_name('OTA','OTA_13221_TPL_WRONG_FLAG');
elsif (p_constraint_name = 'tpl_dates_ple') Then
    fnd_message.set_name('OTA','OTA_13233_TPL_DATES_PLE');
elsif (p_constraint_name = 'tpl_dates_tbd') Then
    fnd_message.set_name('OTA','OTA_13234_TPL_DATES_TBD');
elsif p_constraint_name = 'startdate_must_be_populated' then
    fnd_message.set_name('OTA','OTA_13230_GEN_MAND_START_DATE');
elsif p_constraint_name = 'enddate_must_be_greater_than_startdate' then
    fnd_message.set_name('OTA','OTA_13312_GEN_DATE_ORDER');
elsif p_constraint_name = 'tpl_entries_exist' then
    fnd_message.set_name('OTA','OTA_13639_TPL_ENTRIES_EXIST');
--
else
    fnd_message.set_name('OTA','OTA_13259_GEN_UNKN_CONSTRAINT');
    fnd_message.set_token('CONSTRAINT',p_constraint_name);
End If;
--
fnd_message.raise_error;
--
hr_utility.set_location(' Leaving:'||l_proc, 10);

End constraint_error2;
--==============================================================================
--=============================================================================
--
-- PUBLIC
--
procedure check_single_name
(
p_price_list_id		in number,
p_name			in varchar2,
p_business_group_id	in number
)
is
--
cursor csr_tpl is
	select 1
	from ota_price_lists
	where name = p_name
	   and business_group_id = p_business_group_id
	   and (p_price_list_id is null or price_list_id <> p_price_list_id);
--
l_tpl_exists	boolean;
l_dummy		number;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'business_group_id',p_business_group_id);
end chkp;
-------------------
begin
--
chkp;
--
if p_name is null then
	constraint_error2('tpl_name_is_mandatory');
end if;
--
open csr_tpl;
fetch csr_tpl into l_dummy;
l_tpl_exists := csr_tpl%found;
close csr_tpl;
--
if l_tpl_exists then
	constraint_error2('tpl_name_already_exists');
end if;
--
end check_single_name;
--=============================================================================
--=============================================================================
procedure check_flag
(
p_flag          varchar2
)
is
---------------------
begin
--
if p_flag is null
or (p_flag <> 'Y' and  p_flag <> 'N') then
        constraint_error2('flag_must_be_populated');
end if;
--
end check_flag;
--=============================================================================
--=============================================================================
procedure check_type
(
p_type		varchar2,
p_price		number,
p_tu_type	varchar2
)
is
--
begin
--
if p_type is null
or p_type not in ('M','T') then
	constraint_error2('price_list_type_must_be_populated');
elsif p_type = 'T' then
   if p_price is null then
	constraint_error2('single_unit_price_should_be_populated');
   end if;
   if p_tu_type is null then
	constraint_error2('training_unit_type_should_be_populated');
   end if;
   ota_general.check_domain_value ('TRAINING_UNIT',p_tu_type);
elsif p_type = 'M' then
   if p_price is not null then
	constraint_error2('single_unit_price_should_be_null');
   end if;
   if p_tu_type is not null then
	constraint_error2('training_unit_type_should_be_null');
   end if;
end if;
--
end check_type;
--=============================================================================
--=============================================================================
procedure check_currency
(
p_currency      varchar2
)
is
--
begin
--
if p_currency is null then
        constraint_error2('currency_must_be_populated');
else
   ota_general.check_currency_is_valid(p_currency_code => p_currency);
end if;
--
end check_currency;
--==============================================================================
--==============================================================================
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
end dates_are_in_order;
--==============================================================================
--=============================================================================
procedure check_dates_order
(
p_startdate                 date,
p_enddate                   date
)
is
-------------------
begin
--
if p_startdate is null then
	constraint_error2('startdate_must_be_populated');
end if;
--
if not dates_are_in_order(p_startdate,p_enddate) then
        constraint_error2('enddate_must_be_greater_than_startdate');
end if;
--
end check_dates_order;
--==============================================================================
--==============================================================================
procedure check_table_constraints
(
p_rec		in ota_tpl_shd.g_rec_type
)
is
-------------
begin
--
check_single_name (
	p_price_list_id => p_rec.price_list_id,
	p_name => p_rec.name,
	p_business_group_id => p_rec.business_group_id);
--
check_flag (p_flag => p_rec.default_flag);
--
check_type (
	p_type => p_rec.price_list_type,
	p_price => p_rec.single_unit_price,
	p_tu_type => p_rec.training_unit_type);
--
check_currency (p_currency => p_rec.currency_code);
--
check_dates_order (
	p_startdate => p_rec.start_date,
	p_enddate => p_rec.end_date);
--
end check_table_constraints;

--***********************************************************************-
--			PRICE LIST ENTRIES CHILDREN
--*************************************************************************-
function tpl_has_child_ple
---------------------------
(
p_tpl_id                        number
)
return boolean is
----------------------------
cursor csr_children_ple is
    select 1
    from ota_price_list_entries
    where price_list_id = p_tpl_id;

l_ple_exists                    boolean;

procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_tpl_id',p_tpl_id);
end chkp;
------------------------
begin

chkp;

open csr_children_ple;
fetch csr_children_ple into g_dummy;
l_ple_exists := csr_children_ple%found;
close csr_children_ple;

return l_ple_exists;

end tpl_has_child_ple;

/**************************************************************************/
procedure del_check_no_child_ple
(
p_tpl_id        number
)
is
-------------------
begin
--
  if tpl_has_child_ple (p_tpl_id) then
    constraint_error2('tpl_entries_exist');
  end if;
--
end del_check_no_child_ple;

--***********************************************************************-
--			CHILDREN BOOKING DEALS
--*************************************************************************-
function tpl_has_child_tbd
---------------------------
(
p_tpl_id                        number
)
return boolean is
----------------------------
cursor csr_child is
    select 1
    from ota_booking_deals
    where price_list_id = p_tpl_id;

l_child_exists                    boolean;

procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_tpl_id',p_tpl_id);
end chkp;
------------------------
begin

chkp;

open csr_child;
fetch csr_child into g_dummy;
l_child_exists := csr_child%found;
close csr_child;

return l_child_exists;

end tpl_has_child_tbd;
--========================================================================
--=======================================================================
procedure del_check_no_child_tbd
(
p_tpl_id	number
)
is
-------------------
begin
--
if tpl_has_child_tbd (p_tpl_id) then
	constraint_error2('undeletable_child_tbd_exists');
end if;
--
end del_check_no_child_tbd;
--***************************************************************************************
--		DEFAULT PRICE LIST ENTRY FOR A BUSINESS GROUP (DEFAULT_FLAG)
--***************************************************************************************
procedure check_single_default_tpl
(
	 p_tpl_id			number
	,p_default_flag                  varchar2
	,p_business_group_id             number
	,p_currency_code		varchar2
	,p_start_date			date
	,p_end_date			date
)
is
--
--*** check that there is a single default price list
--*** business rule: there may only be one price list with the default flag set to 'Y'
--*** If p_tpl_id is null, it's an INSERT, otherwise it's an update.
--
cursor csr_default_price_list is
   select 1
   from ota_price_lists
   where business_group_id = p_business_group_id
         and default_flag = 'Y'
	 and currency_code = p_currency_code
	 and p_start_date <= nvl(end_date,p_start_date)
	 and nvl(p_end_date,start_date) >= start_date
         and (p_tpl_id is null or (p_tpl_id is not null
                                 and price_list_id <> p_tpl_id));
--
l_tpl_exists            boolean;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_business_group_id',p_business_group_id);
hr_api.mandatory_arg_error(g_package,'p_default_flag',p_default_flag);
end chkp;
--
begin
--
if p_default_flag = 'N' then
	return;
end if;
--
chkp;
--
open csr_default_price_list;
fetch csr_default_price_list into g_dummy;
l_tpl_exists := csr_default_price_list%found;
close csr_default_price_list;
if l_tpl_exists then
	constraint_error2('default_price_list_already_exists');
end if;
--
end check_single_default_tpl;
--*************************************************************************************
--				TPL: DATES VALIDATION
--*************************************************************************************
function tpl_start_precedes_ple_starts
-----------------------------
(
p_tpl_id                        number,
p_start_date                    date
)
return boolean is

--*** Returns true if Price list'new start date <= Price list entries'min start date
--*** This function must be called before updating ota_price_lists
--*** Start_dates are mandatory in price lists and price list entries
----------------
cursor csr_ple_min_startdate is
   select min(start_date)
   from ota_price_list_entries
   where price_list_id = p_tpl_id;

mindate				date;

procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_tpl_id',p_tpl_id);
hr_api.mandatory_arg_error(g_package,'p_start_date',p_start_date);
end chkp;
-----------------
begin
--
chkp;
--
open csr_ple_min_startdate;
fetch csr_ple_min_startdate into mindate;
close csr_ple_min_startdate;
--
if mindate is null then
    return TRUE;
elsif p_start_date <= mindate then
    	return TRUE;
elsif p_start_date > mindate then
	if g_update then
	   return TRUE;
	else
	   return FALSE;
	end if;
else
     return FALSE;
end if;
end tpl_start_precedes_ple_starts;
--=======================================================================================
--=======================================================================================
function tpl_start_precedes_tbd_starts
(
p_tpl_id                        number,
p_start_date                    date
)
return boolean is

--*** Returns true if Price list'new start date <= booking deals'min start date
--*** This function must be called before updating ota_price_lists
--*** Start_dates are mandatory in price lists and booking deals
----------------
cursor csr_tbd_min_startdate is
   select min(start_date)
   from ota_booking_deals
   where price_list_id = p_tpl_id;

mindate                             date;

procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_tpl_id',p_tpl_id);
hr_api.mandatory_arg_error(g_package,'p_start_date',p_start_date);
end chkp;
-----------------
begin
--
chkp;
--
open csr_tbd_min_startdate;
fetch csr_tbd_min_startdate into mindate;
close csr_tbd_min_startdate;
--
if mindate is null then
    return TRUE;
elsif p_start_date <= mindate then
	   return TRUE;
else
	   return FALSE;
end if;
--
end tpl_start_precedes_tbd_starts;
--=======================================================================================
--=======================================================================================
function tpl_end_succeeds_ple_ends
-----------------------------
(
p_tpl_id                        number,
p_end_date                    date
)
return boolean is
--
--*** Returns true if Price list's new end date >= Price list entries' max end date
--*** This function must be called before updating ota_price_lists
--*** end dates may be null
--
cursor csr_ple_max_enddate is
   select max(nvl(end_date,g_end_of_time))
   from ota_price_list_entries
   where price_list_id = p_tpl_id;
--
maxdate                 date;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_tpl_id',p_tpl_id);
end chkp;
--
begin
--
chkp;
--
if p_end_date is null
then
        return TRUE;
end if;
--
open csr_ple_max_enddate;
fetch csr_ple_max_enddate into maxdate;
close csr_ple_max_enddate;
--
if maxdate is null then
    return TRUE;
elsif p_end_date >= maxdate then
      return TRUE;
elsif p_end_date < maxdate then
	if g_update then
	   return TRUE;
	else
	   return FALSE;
	end if;
else
  return FALSE;
end if;
--
end tpl_end_succeeds_ple_ends;
--=======================================================================================
--=======================================================================================
function tpl_end_succeeds_tbd_ends
-----------------------------
(
p_tpl_id                        number,
p_end_date                    date
)
return boolean is
--
--*** Returns true if Price list's new end date >= booking deals' max end date
--*** This function must be called before updating ota_price_lists
--*** end dates may be null
-------------------
cursor csr_tbd_max_enddate is
   select max(nvl(end_date,g_end_of_time))
   from ota_booking_deals
   where price_list_id = p_tpl_id;
--
maxdate                 date;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'p_tpl_id',p_tpl_id);
end chkp;
-------------------
begin
--
chkp;
--
if p_end_date is null
then
        return TRUE;
end if;
--
open csr_tbd_max_enddate;
fetch csr_tbd_max_enddate into maxdate;
close csr_tbd_max_enddate;
--
if maxdate is null then
    return TRUE;
elsif p_end_date >= maxdate then
        return TRUE;
else
        return FALSE;
end if;
--
end tpl_end_succeeds_tbd_ends;
--=======================================================================================
--=======================================================================================
procedure check_tpl_new_start_date
(
p_tpl_id                number,
p_start_date            date
)
is
--------------
begin
--
if not tpl_start_precedes_ple_starts(p_tpl_id,p_start_date)
then
	constraint_error2('tpl_dates_ple');
end if;
--
if not tpl_start_precedes_tbd_starts(p_tpl_id,p_start_date)
then
	constraint_error2('tpl_dates_tbd');
end if;
--
end check_tpl_new_start_date;
--=======================================================================================
--=======================================================================================
procedure check_tpl_new_end_date
(
p_tpl_id                number,
p_end_date            date
)
is
--------------
begin
--
g_end_of_time := hr_general.end_of_time;

if not tpl_end_succeeds_ple_ends(p_tpl_id,p_end_date)
then
	constraint_error2('tpl_dates_ple');
end if;
--
if not tpl_end_succeeds_tbd_ends(p_tpl_id,p_end_date)
then
	constraint_error2('tpl_dates_tbd');
end if;
--
end check_tpl_new_end_date;
--=======================================================================================
--=======================================================================================
procedure check_tpl_new_dates
(
p_tpl_id                number,
p_start_date            date,
p_end_date              date
)
is
--*** called when updating price list 's start_date and end_date
----------------
begin
--
check_tpl_new_start_date(p_tpl_id,p_start_date);

check_tpl_new_end_date(p_tpl_id,p_end_date);
--
end check_tpl_new_dates;
--**************************************************************************************
--			GENERAL VALIDATION PROCEDURES
--***************************************************************************************
procedure insert_and_update_validate
(
p_rec in ota_tpl_shd.g_rec_type
)
is
---------------------
begin
--
check_table_constraints(p_rec);
--
check_single_default_tpl (
	 p_tpl_id 		=> p_rec.price_list_id
        ,p_default_flag 	=> p_rec.default_flag
        ,p_business_group_id 	=> p_rec.business_group_id
	,p_currency_code	=> p_rec.currency_code
	,p_start_date		=> p_rec.start_date
	,p_end_date		=> p_rec.end_date
   );
--
end insert_and_update_validate;
--=======================================================================================
--=======================================================================================
procedure insert_validate2
(
p_rec in ota_tpl_shd.g_rec_type
)
is
---------------------
begin
--
insert_and_update_validate(p_rec);
--
end insert_validate2;
--=======================================================================================
--=======================================================================================
procedure update_validate2
(
p_rec in ota_tpl_shd.g_rec_type
)
is
---------------------
begin
--
insert_and_update_validate(p_rec);
--
check_tpl_new_dates (
		p_tpl_id => p_rec.price_list_id,
		p_start_date => p_rec.start_date,
		p_end_date => p_rec.end_date);
--
end update_validate2;
--=======================================================================================
--=======================================================================================
procedure delete_validate2
(
p_rec in ota_tpl_shd.g_rec_type
)
is
---------------------
begin
--
--Check no child booking deals exist for price list.
--
  del_check_no_child_tbd (p_tpl_id => p_rec.price_list_id);

--
--Check no child entries exist for price list.
--
  del_check_no_child_ple (p_tpl_id => p_rec.price_list_id);
--
end delete_validate2;
--***************************************************************************************
--				END OF MANUALLY WRITTEN SECTION
--***************************************************************************************
--*********************************************************************
--***********************************************************************
procedure modify_price_list
(
p_proc_use		number,
p_old_tpl_id		number,
p_new_tpl_name		varchar2,
p_new_startdate		date,
p_new_enddate		date,
p_price_increase	number,
p_rounding_direction	varchar2,
p_rounding_factor	number,
p_change_entries	boolean
)
is
-----------------
--*** p_proc_use = 1 => copy_price_list utility:
--*** Create a new price list based on an existing price list
--*** and the associated price list entries,
--*** with new dates and a possible increase in price.
--*** p_price_increase is a percent.
--
--*** p_proc_use = 2 => change_price_list_dates utility;
--*** Update the end_date of a price_list
--*** Close_down_price_list:
--***   If the end_date is < old end_date then price list entries
--***   will be modified: if their start_date is > new end date,
--***   price list entries will be deleted. If their end_date
--***   is > new end_date, their end_date will be updated.
--*** Widen_dates:
--***   If end date > old end date, Entries ending at the same old
--***   end date will be updated after the price list update.
--***   If start date < old start date, Entries starting at the same
--***   old start date will be updated as well.
--
l_tplrec		ota_tpl_shd.g_rec_type;
--
cursor csr_tplrec is
select
   price_list_id,
   business_group_id,
   currency_code,
   default_flag,
   name,
   object_version_number,
   price_list_type,
   start_date,
   comments,
   description,
   end_date,
   single_unit_price,
   training_unit_type,
   tpl_information_category,tpl_information1,tpl_information2,
   tpl_information3,tpl_information4,tpl_information5,tpl_information6,
   tpl_information7,tpl_information8,tpl_information9,tpl_information10,
   tpl_information11,tpl_information12,tpl_information13,tpl_information14,
   tpl_information15,tpl_information16,tpl_information17,tpl_information18,
   tpl_information19,tpl_information20
	from ota_price_lists
	where price_list_id = p_old_tpl_id;
--
l_tpl_found		boolean;
l_dates_difference	number;
l_old_startdate		date;
l_old_enddate		date;
--
procedure chkp is
begin
--
hr_api.mandatory_arg_error(g_package,'old_price_list_id',p_old_tpl_id);
if p_proc_use = 1 then
   if p_new_tpl_name is null or p_new_startdate is null then
	constraint_error2('tpl_name_and_date_is_mandatory');
   end if;
--
elsif p_proc_use = 2 then
   if p_new_startdate is null then
	constraint_error2('startdate_must_be_populated');
   end if;
   if not (p_new_tpl_name is null and p_price_increase is null and
	p_rounding_direction is null and p_rounding_factor is null) then
	constraint_error2('parameters_should_be_null');
   end if;
--
else
	constraint_error2('p_proc_use_is_wrong');
end if;
end chkp;
-------------
begin
--
chkp;
--
open csr_tplrec;
fetch csr_tplrec into l_tplrec;
l_tpl_found := csr_tplrec%found;
close csr_tplrec;
if not l_tpl_found then
	constraint_error2('price_list_doesnt_exist');
end if;
--
----------------------------
-- Copy price list function
----------------------------
if p_proc_use = 1 then
   if p_new_tpl_name = l_tplrec.name then
      constraint_error2('tpl_name_already_exists');
   end if;
   --
   l_old_startdate := l_tplrec.start_date;
   l_old_enddate   := l_tplrec.end_date;
   l_tplrec.price_list_id := null;
   l_tplrec.object_version_number := null;
   l_tplrec.default_flag := 'N';
   l_tplrec.name := p_new_tpl_name;
   l_tplrec.start_date := p_new_startdate;
   l_tplrec.end_date := p_new_enddate;
   --
   ota_tpl_ins.ins(l_tplrec,FALSE);
   --
   if l_tplrec.price_list_id is null then
      constraint_error2('ins_tpl_failure');
   end if;
   OTA_PLE_BUS.copy_price_list (
        p_old_price_list_id     => p_old_tpl_id,
        p_new_price_list_id     => l_tplrec.price_list_id,
        p_increase_rate         => p_price_increase,
        p_round_direction       => p_rounding_direction,
	p_round_factor		=> p_rounding_factor ,
        p_old_startdate       => l_old_startdate,
        p_new_startdate       => p_new_startdate,
        p_old_enddate         => l_old_enddate,
        p_new_enddate         => p_new_enddate
);
--
------------------------------------
-- Change price list dates function
-----------------------------------
elsif p_proc_use = 2 then
   --
   if p_new_startdate = l_tplrec.start_date and
     p_new_enddate = l_tplrec.end_date then
     return;
   end if;
   --
   l_old_startdate := l_tplrec.start_date;
   l_old_enddate := l_tplrec.end_date;
   l_tplrec.end_date := p_new_enddate;
   l_tplrec.start_date := p_new_startdate;
   ota_tpl_upd.upd(l_tplrec,FALSE);
   --
   if p_change_entries then
      OTA_PLE_BUS.widen_entries_dates (
	p_price_list_id		=> p_old_tpl_id
	,p_old_startdate	=> l_old_startdate
	,p_new_startdate	=> p_new_startdate
	,p_old_enddate		=> l_old_enddate
	,p_new_enddate		=> p_new_enddate );
   end if;
----------
end if;
--
end modify_price_list;
--***********************************************************************
--***********************************************************************
--
-- PUBLIC
--
procedure copy_price_list (
	p_tpl_id in number,
	p_new_tpl_name in varchar2,
	p_new_startdate in date,
	p_new_enddate in date,
	p_price_increase in number,
	p_rounding_direction in varchar2,
	p_rounding_factor in number
)
is
-----------------
begin
--
modify_price_list (
	p_proc_use		=> 1
	,p_old_tpl_id		=> p_tpl_id
	,p_new_tpl_name		=> p_new_tpl_name
	,p_new_startdate	=> p_new_startdate
	,p_new_enddate		=> p_new_enddate
	,p_price_increase	=> p_price_increase
	,p_rounding_direction	=> p_rounding_direction
	,p_rounding_factor	=> p_rounding_factor
	,p_change_entries	=> false);
--
end copy_price_list;
--***********************************************************************
--***********************************************************************
--
-- PUBLIC
--
procedure change_price_list_dates
  (
	p_price_list_id		in number
	,p_new_startdate	in date
	,p_new_enddate		in date
	,p_change_entries	in char
  )
is
---------------
begin
--
if p_change_entries not in ('Y','N') then
	constraint_error2('alter_entry_flag_is_wrong');
end if;
if p_change_entries = 'Y' then
   g_update := TRUE;
else
   g_update := FALSE;
end if;
modify_price_list (
        p_proc_use              => 2
        ,p_old_tpl_id           => p_price_list_id
        ,p_new_tpl_name         => null
        ,p_new_startdate        => p_new_startdate
        ,p_new_enddate          => p_new_enddate
        ,p_price_increase       => null
        ,p_rounding_direction   => null
        ,p_rounding_factor      => null
	,p_change_entries	=> (p_change_entries='Y') );
--
g_update := FALSE;
--
end change_price_list_dates;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_tpl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
	insert_validate2(p_rec);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ota_tpl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
	update_validate2(p_rec);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tpl_shd.g_rec_type) is
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
end ota_tpl_bus;

/
