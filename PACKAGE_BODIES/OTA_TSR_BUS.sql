--------------------------------------------------------
--  DDL for Package Body OTA_TSR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TSR_BUS" as
/* $Header: ottsr01t.pkb 120.2 2005/08/08 23:27:40 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tsr_bus.';  -- Global package name
g_legislation_code            varchar2(150)  default null;
-- ici insert tsr.cat
--*******************************************************************************
--                         	TPL: ADDITIONAL API
--
-- Version    Date         Author       Reason
-- 1.01       15/11/94 M.Roychowdhury  Added business rules
-- 10.2     28feb95     lparient.FR     New API generator, new business rules
-- 10.11     01Jun95	lparient.FR	Name and person_id became mutually exclusive
--					Unique key was changed.
--*******************************************************************************
--
--                      ***************************
--                      ADDITIONAL GLOBAL VARIABLES
--                      ***************************
--
g_trainer_type          varchar2(10)    := 'T';
g_venue_type            varchar2(10)    := 'V';
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
--*******************************************************************************
--
--added for bug4310348 by jbharath
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_supplied_resource_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_suppliable_resources tsr
     where tsr.supplied_resource_id = p_supplied_resource_id
       and pbg.business_group_id = tsr.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'supplied_resource_id'
    ,p_argument_value     => p_supplied_resource_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'SUPPLIED_RESOURCE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
-- added for bug#4310348 by jbharath
--
--============================================================================
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
if p_constraint_name = 'startdate_is_mandatory' then
    fnd_message.set_name('OTA','OTA_13457_GEN_MAND_START_DATE');
elsif p_constraint_name = 'end_precedes_start' then
    fnd_message.set_name('OTA','OTA_13312_GEN_DATE_ORDER');
elsif p_constraint_name = 'location_is_not_active' then
    fnd_message.set_name('OTA','OTA_13377_GEN_LOCAT_NOT_ACTIVE');
--
elsif p_constraint_name = 'resource_type_is_mandatory' then
    fnd_message.set_name('OTA','OTA_13222_GEN_MANDATORY_VALUE');
    fnd_message.set_token('FIELD','Supplied resource Type');
    fnd_message.set_token('OPTIONAL_EXTENSION','');
elsif p_constraint_name = 'vendor_is_mandatory' then
    fnd_message.set_name('OTA','OTA_13222_GEN_MANDATORY_VALUE');
    fnd_message.set_token('FIELD','Training Center or Supplier');
    fnd_message.set_token('OPTIONAL_EXTENSION','');
elsif p_constraint_name = 'consumable_flag_is_mandatory' then
    fnd_message.set_name('OTA','OTA_13222_GEN_MANDATORY_VALUE');
    fnd_message.set_token('FIELD','Resource Consumable flag');
    fnd_message.set_token('OPTIONAL_EXTENSION','');
--
elsif (p_constraint_name='cost_without_currency' or p_constraint_name='currency_without_cost') then
    fnd_message.set_name('OTA','OTA_13203_TSR_COST_CURRENCY');
    fnd_message.set_token('FIELD1','CURRENCY');
    fnd_message.set_token('FIELD2','COST');
--
elsif p_constraint_name = 'wrong_consumable_flag' then
    fnd_message.set_name('OTA','OTA_13204_GEN_INVALID_LOOKUP');
    fnd_message.set_token('FIELD','CONSUMABLE_FLAG');
    fnd_message.set_token('LOOKUP_TYPE','YES_NO');
--
elsif p_constraint_name = 'address_must_be_null' then
    fnd_message.set_name('OTA','OTA_13223_GEN_MANDATORY_NULL');
    fnd_message.set_token('FIELD','Address line');
    fnd_message.set_token('OPTIONAL_EXTENSION','No location.');
--
elsif p_constraint_name = 'del_child_trb_exists' then
    fnd_message.set_name('OTA','OTA_13227_TSR_TRB_EXISTS');
elsif p_constraint_name = 'del_child_rud_exists' then
    fnd_message.set_name('OTA','OTA_13229_TSR_RUD_EXISTS');
--
elsif p_constraint_name = 'resource_already_exists' then
    fnd_message.set_name('OTA','OTA_13381_TSR_DUPLICATE');
elsif p_constraint_name = 'cons_flag_other_excl' then
    fnd_message.set_name('OTA','OTA_13382_TSR_CONS_FLAG_EXCL');
elsif p_constraint_name = 'resource_type_is_not_updatable' then
    fnd_message.set_name('OTA','OTA_13378_TSR_TYPE_NOT_UPD');
elsif p_constraint_name = 'new_date_invalids_usage_date' then
    fnd_message.set_name('OTA','OTA_13379_TSR_DATES_RUD');
elsif p_constraint_name = 'new_date_invalids_booking_date' then
    fnd_message.set_name('OTA','OTA_13380_TSR_DATES_TRB');
--
elsif p_constraint_name = 'mutual_exclusive' then
    fnd_message.set_name('OTA','OTA_13222_GEN_MANDATORY_VALUE');
    fnd_message.set_token('FIELD','Either Training Center or Supplier');
    fnd_message.set_token('OPTIONAL_EXTENSION','');

else
    fnd_message.set_name('OTA','OTA_13259_GEN_UNKN_CONSTRAINT');
    fnd_message.set_token('CONSTRAINT',p_constraint_name);
End If;
--
fnd_message.raise_error;
--
hr_utility.set_location(' Leaving:'||l_proc, 10);

End constraint_error2;
--======================================================================
--======================================================================
function from_other_type (p_type in varchar2)
return boolean is
begin
--
if p_type = g_venue_type or p_type = g_trainer_type then
        return false;
else
        return true;
end if;
--
end from_other_type;

--
--***************************************************************************
--		CHECKS OVER TYPE AND KEY (Vendor,person and name)
--***************************************************************************
procedure check_tsr_type (
   p_resource_type       varchar2)
is
-----------------
begin
--
if p_resource_type is null then
        constraint_error2('resource_type_is_mandatory');
end if;
--
ota_general.check_domain_value ('RESOURCE_TYPE',p_resource_type);
--
end check_tsr_type;
--===========================================================================
--===========================================================================
--===========================================================================
-- The following primary keys operate for Suppliable Resources
-- Type   Key
-- ----   ---
-- V      Name,Supplier,Centre,Location
-- T      Name,Supplier (anonymous trainer)
-- T      PERSON_ID (Named Trainer)
-- O      Name,Supplier,Centre
--===========================================================================
--
-- PRIVATE
--
procedure check_unique_key (
  p_biz		  number,
  p_suppres_id    number,
  p_name	  varchar2,
  p_resource_type varchar2
) is
----------------
cursor cur_tsr is
	select 1
	from ota_suppliable_resources_vl
	where business_group_id = p_biz
	and (p_suppres_id is null or p_suppres_id <> supplied_resource_id)
        and name = p_name
	and resource_type = p_resource_type;
--
l_tsr_exists	boolean;
--
l_dummy		integer;
--
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'business_group',p_biz);
end chkp;
-----------------
begin
--
chkp;
--
open cur_tsr;
fetch cur_tsr into l_dummy;
l_tsr_exists := cur_tsr%found;
close cur_tsr;
--
if l_tsr_exists then
	constraint_error2('resource_already_exists');
end if;
--
end check_unique_key;
--===========================================================================
--===========================================================================
procedure check_tsr_key
(
 p_business_group_id		number,
 p_resource_type                varchar2,
 p_vendor_id			number,
 p_supplied_resource_id         number,
 p_name				varchar2,
 p_training_center_id         number
)
is
-------------
begin
--
if p_vendor_id is null  and p_training_center_id  is null then
	constraint_error2('vendor_is_mandatory');
--elsif p_vendor_id is not null  and p_training_center_id is not null then
--    constraint_error2('mutual_exclusive' ); Ench# 2004405
end if;
--
check_tsr_type(p_resource_type);
--
check_unique_key(
  p_biz		  => p_business_group_id,
  p_suppres_id    => p_supplied_resource_id,
  p_name          => p_name,
  p_resource_type => p_resource_type);
--
end check_tsr_key;
--*************************************************************
--			DATES VALIDATION
--***************************************************************
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
        constraint_error2('startdate_is_mandatory');
end if;
--
if p_enddate is not null then
   if p_enddate < p_startdate then
        constraint_error2('end_precedes_start');
   end if;
end if;
--
end check_dates_order;
--
--=================================================================
--=================================================================
procedure check_tsr_dates
(
p_startdate                 date,
p_enddate                   date
)
is
-------------------
begin
--
check_dates_order (
 p_startdate => p_startdate,
 p_enddate => p_enddate);
end check_tsr_dates;
--
--********************************************************************************
--				UPDATE VALIDATION
--********************************************************************************
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_type_update >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_type_update (
   p_tsr_id	in number,
   p_ovn	in number,
   p_resource_type in varchar2) is
---------------
  l_proc        varchar2(72) := g_package||'check_type_update';
--
l_api_updating		boolean;
--
procedure chkp is
begin
if not l_api_updating or  p_tsr_id <> OTA_TSR_SHD.g_old_rec.supplied_resource_id then
	constraint_error2('wrong_old_rec');
end if;
end chkp;
---------------
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := OTA_TSR_SHD.api_updating (
        p_supplied_resource_id => p_tsr_id,
        p_object_version_number => p_ovn );
  --
  chkp;
  --
  if OTA_TSR_SHD.g_old_rec.resource_type <> p_resource_type then
	constraint_error2('resource_type_is_not_updatable');
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End check_type_update;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_usage_dates >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_usage_dates (p_supplied_resource_id in number,
                             p_start_date           in date,
                             p_end_date             in date) is
--
  -- cursor to check that the dates of resource usag are within the bounds
  -- of the resource dates
  --
  Cursor c_invalid_usage is
    select 'X'
    from ota_resource_usages
    where supplied_resource_id = p_supplied_resource_id
      and (start_date < p_start_date or
           nvl(end_date, hr_api.g_eot) > nvl(p_end_date, hr_api.g_eot));
--
  l_proc	varchar2(72) := g_package||'check_usage_dates';
  l_dummy       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_invalid_usage;
  fetch c_invalid_usage into l_dummy;
  if c_invalid_usage%found then
  --
    close c_invalid_usage;
    --
	constraint_error2('new_date_invalids_usage_date');
    --
  end if;
  --
  close c_invalid_usage;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_usage_dates;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_booking_dates >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_booking_dates (p_supplied_resource_id in number,
                               p_start_date           in date,
                               p_end_date             in date) is
--
  Cursor c_invalid_bookings is
    select 'X'
    from ota_resource_bookings
    where supplied_resource_id = p_supplied_resource_id
      and (required_date_from < p_start_date
           or
           nvl(required_date_to,hr_api.g_eot) > nvl(p_end_date,hr_api.g_eot));
--
  l_proc	varchar2(72) := g_package||'check_booking_dates';
  l_dummy       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_invalid_bookings;
  fetch c_invalid_bookings into l_dummy;
  --
  if c_invalid_bookings%found then
    close c_invalid_bookings;
	constraint_error2('new_date_invalids_booking_date');
  end if;
  --
  close c_invalid_bookings;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_booking_dates;
--**************************************************************
--**************************************************************
procedure check_tsr_new_dates
(
p_tsr_id		number,
p_startdate		date,
p_enddate		date
)
is
----------------
-- New dates cannot invalidate children's dates.
---------------
procedure chkp is
begin
check_dates_order(p_startdate,p_enddate);
end chkp;
---------------
begin
--
chkp;
--
check_booking_dates(p_tsr_id,p_startdate,p_enddate);
--
check_usage_dates(p_tsr_id,p_startdate,p_enddate);
--
end check_tsr_new_dates;
--
--*****************************************************************************
--                              COST CHECKS
--*****************************************************************************
--
procedure check_currency (
p_currency      in varchar2
)
is
-------------
begin
--
if p_currency is not null then
   ota_general.check_currency_is_valid(p_currency);
end if;
--
end check_currency;
--=======================================================
--=======================================================
procedure check_cost_and_currency (
	p_cost		number,
	p_currency_code varchar2
)
is
---------------
begin
--
if p_currency_code is not null then
   if p_cost is null then
	constraint_error2('currency_without_cost');
   end if ;
   check_currency (p_currency_code);
--
elsif p_cost is not null then
   constraint_error2('cost_without_currency');
end if;
--
end check_cost_and_currency;
--
--*****************************************************************************
--				STOCK CHECKS
--*****************************************************************************
--
-- PRIVATE ONLY (resource_type must be ok)
--
procedure check_consumable_flag
(
   p_resource_type	in varchar2,
   p_consumable_flag	in varchar2
)
is
-------------
begin
--
if p_consumable_flag is null then
  constraint_error2('consumable_flag_is_mandatory');
elsif NOT (p_consumable_flag in ('N', 'Y')) then
        constraint_error2('wrong_consumable_flag');
elsif p_consumable_flag = 'Y' and not from_other_type(p_resource_type) then
	constraint_error2('cons_flag_other_excl');
end if;
--
end check_consumable_flag;
--*****************************************************************************
--				DELETE VALIDATION
--*****************************************************************************
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_bookings >------------------------------|
-- ----------------------------------------------------------------------------
--
--              Checks that no bookings exist for this resource before deletion
--
Procedure del_check_bookings (p_supplied_resource_id  in number) is
--
  Cursor c_bookings is
    select 'X'
    from ota_resource_bookings
    where supplied_resource_id = p_supplied_resource_id;
--
  l_proc	varchar2(72) := g_package||'check_bookings';
  l_dummy       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_bookings;
  fetch c_bookings into l_dummy;
  --
  if c_bookings%found then
     close c_bookings;
	constraint_error2('del_child_trb_exists');
  end if;
  --
  close c_bookings;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del_check_bookings;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_usages >------------------------------|
-- ----------------------------------------------------------------------------
--
--              Checks that resource is not being used before deletion
--
Procedure del_check_usages (p_supplied_resource_id  in number) is
--
  Cursor c_usages is
    select 'X'
    from ota_resource_usages
    where supplied_resource_id = p_supplied_resource_id;
--
  l_proc	varchar2(72) := g_package||'check_usages';
  l_dummy       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_usages;
  fetch c_usages into l_dummy;
  --
  if c_usages%found then
     close c_usages;
	constraint_error2('del_child_rud_exists');
  end if;
  --
  close c_usages;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del_check_usages;

/** Added for globalization **/
-- ----------------------------------------------------------------------------
-- |-----------------------<  chk_Training_center  >---------------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Insert_validate procedure and
--               Update_validaate procedure. This
--               procedure will check whether Training center exist or not.
--
Procedure chk_Training_center
  (p_supplied_resource_id  in number,
   p_training_center_id      in number)
IS


--
  l_proc  varchar2(72) := g_package||'chk_training_center';
  l_exists	varchar2(1);

  Cursor c_training_center
  IS
  Select null
  From HR_ALL_ORGANIZATION_UNITS
  Where organization_id = p_training_center_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if (((p_supplied_resource_id  is not null) and
      nvl(ota_tsr_shd.g_old_rec.training_center_id,hr_api.g_number) <>
         nvl(p_training_center_id,hr_api.g_number))
   or (p_supplied_resource_id  is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_training_center_id is not null) then
	  hr_utility.set_location('Entering:'||l_proc, 15);
            open c_training_center;
            fetch c_training_center into l_exists;
            if c_training_center%notfound then
               close c_training_center;
               fnd_message.set_name('OTA','OTA_13907_TSR_TRNCTR_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close c_training_center;
            hr_utility.set_location('Entering:'||l_proc, 20);
      end if;
end if;
hr_utility.set_location('Entering:'||l_proc, 30);

end;

-- ----------------------------------------------------------------------------
-- |-----------------------------<  chk_location  >---------------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Insert_validate procedure and
--               Update_validate procedure. This
--               procedure will check whether Location exist or not.

--
Procedure Chk_location
  (p_supplied_resource_id  	in number,
   p_location_id 	      	in number,
   p_training_center_id 	in number)
IS


--
  l_proc  varchar2(72) := g_package||'chk_location';
  l_exists	varchar2(1);
 Cursor c_location
  IS
  Select null
  From HR_LOCATIONS_ALL loc
  Where loc.location_id = p_location_id ;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  if (((p_supplied_resource_id  is not null) and
      nvl(ota_tsr_shd.g_old_rec.location_id,hr_api.g_number) <>
         nvl(p_location_id,hr_api.g_number))
   or (p_supplied_resource_id  is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_location_id is not null) then
	  hr_utility.set_location('Entering:'||l_proc, 15);
            open c_location;
            fetch c_location into l_exists;
            if c_location%notfound then
               close c_location;
               fnd_message.set_name('OTA','OTA_13908_TSR_LOC_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close c_location;
            hr_utility.set_location('Entering:'||l_proc, 20);
      end if;
end if;
hr_utility.set_location('Entering:'||l_proc, 30);

end;

-- ----------------------------------------------------------------------------
-- |-----------------------------<  chk_trainer  >---------------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Insert_validate procedure and
--               Update_validate procedure. This
--               procedure will check whether trainer exist or not.

--
Procedure Chk_trainer
  (p_supplied_resource_id  	in number,
   p_trainer_id 	      	in number,
   p_business_group_id    	in number,
   p_start_date			IN DATE,
   p_end_date			IN DATE
)
IS


--
  l_proc  varchar2(72) := g_package||'chk_trainer';
  l_exists	varchar2(1);
  l_global_business_group_id   number := FND_PROFILE.VALUE('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
--Bug 1991061
-- Enh 2530860  Following 2 cursors modified to support PTU . Included the table
-- PER_PERSON_TYPE_USAGES_F & PER_PERSON_TYPES

  Cursor c_trainer_global
  IS
  Select null
  From PER_ALL_PEOPLE_F per, PER_PERSON_TYPE_USAGES_F ptu, PER_PERSON_TYPES ppt
  Where per.person_id = p_trainer_id
  --AND   trunc(p_start_date) between per.effective_start_date and per.effective_end_date Bug# 2956482
  AND   trunc(p_start_date) >= per.start_date
  AND   NVL(trunc(p_end_date),trunc(sysdate)) <= ptu.effective_end_date  --bug no 3058027
  AND	trunc(p_start_date) between ptu.effective_start_date and ptu.effective_end_date
  AND	ptu.person_id = per.person_id
  AND	ppt.business_group_id = per.business_group_id
 -- AND	ppt.system_person_type in ('EMP','CWK') Bug# 2956482
  AND    ((ppt.system_person_type = 'EMP' and nvl(per.current_employee_flag,'N')='Y')
        or (ppt.system_person_type = 'CWK'  and nvl(per.current_npw_flag,'N')='Y'))
  AND	ptu.person_type_id = ppt.person_type_id ;

  Cursor c_trainer
  IS
  Select null
  From PER_ALL_PEOPLE_F per, PER_PERSON_TYPE_USAGES_F ptu, PER_PERSON_TYPES ppt
  Where per.person_id = p_trainer_id
 -- AND   trunc(p_start_date) between per.effective_start_date and per.effective_end_date Bug# 2956482
  AND   trunc(p_start_date) >= per.start_date
  AND   NVL(trunc(p_end_date),trunc(sysdate)) <= ptu.effective_end_date  --bug no 3058027
  AND	trunc(p_start_date) between ptu.effective_start_date and ptu.effective_end_date
  AND	ptu.person_id = per.person_id
  AND	ppt.business_group_id = per.business_group_id
  AND	per.business_group_id = p_business_group_id
 -- AND	ppt.system_person_type in ('EMP','CWK') Bug# 2956482
  AND    ((ppt.system_person_type = 'EMP' and nvl(per.current_employee_flag,'N')='Y')
         or (ppt.system_person_type = 'CWK' and nvl(per.current_npw_flag,'N')='Y'))
  AND	ptu.person_type_id = ppt.person_type_id  ;



--Bug 1991061

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  if (((p_supplied_resource_id  is not null) and
      nvl(ota_tsr_shd.g_old_rec.trainer_id,hr_api.g_number) <>
         nvl(p_trainer_id,hr_api.g_number))
   or (p_supplied_resource_id  is null)) or
      nvl(ota_tsr_shd.g_old_rec.start_date, hr_api.g_date) <>
      nvl(p_start_date, hr_api.g_date) OR
      nvl(ota_tsr_shd.g_old_rec.end_date, hr_api.g_date) <>
      nvl(p_end_date, hr_api.g_date)
      then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_trainer_id is not null) then
      if l_global_business_group_id is not null then
         hr_utility.set_location('Entering:'||l_proc, 15);
            open c_trainer_global;
            fetch c_trainer_global into l_exists;
            if c_trainer_global%notfound then
               close c_trainer_global;
               fnd_message.set_name('OTA','OTA_13906_TSR_TRAIN_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close c_trainer_global;
            hr_utility.set_location('leaving:'||l_proc, 20);
      else
	  hr_utility.set_location('Entering:'||l_proc, 25);
            open c_trainer;
            fetch c_trainer into l_exists;
            if c_trainer%notfound then
               close c_trainer;
               fnd_message.set_name('OTA','OTA_13906_TSR_TRAIN_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close c_trainer;
            hr_utility.set_location('Leaving:'||l_proc, 30);
       end if;
      end if;
end if;
hr_utility.set_location('Leaving:'||l_proc, 35);

end;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_df
  (p_rec IN ota_tsr_shd.g_rec_type
  ) IS
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  IF ((p_rec.supplied_resource_id IS NOT NULL)  AND (
    NVL(ota_tsr_shd.g_old_rec.tsr_information_category, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information_category, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information1, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information1, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information2, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information2, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information3, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information3, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information4, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information4, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information5, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information5, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information6, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information6, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information7, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information7, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information8, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information8, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information9, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information9, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information10, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information10, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information11, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information11, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information12, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information12, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information13, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information13, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information14, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information14, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information15, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information15, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information16, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information16, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information17, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information17, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information18, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information18, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information19, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information19, hr_api.g_varchar2)  OR
    NVL(ota_tsr_shd.g_old_rec.tsr_information20, hr_api.g_varchar2) <>
    NVL(p_rec.tsr_information20, hr_api.g_varchar2) ) )
    OR (p_rec.supplied_resource_id IS NULL)  THEN
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the tsr_information values have actually changed.
    -- b) During insert.
    --

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_SUPPLIABLE_RESOURCES'
      ,p_attribute_category              => p_rec.tsr_information_category
      ,p_attribute1_name                 => 'TSR_INFORMATION1'
      ,p_attribute1_value                => p_rec.tsr_information1
      ,p_attribute2_name                 => 'TSR_INFORMATION2'
      ,p_attribute2_value                => p_rec.tsr_information2
      ,p_attribute3_name                 => 'TSR_INFORMATION3'
      ,p_attribute3_value                => p_rec.tsr_information3
      ,p_attribute4_name                 => 'TSR_INFORMATION4'
      ,p_attribute4_value                => p_rec.tsr_information4
      ,p_attribute5_name                 => 'TSR_INFORMATION5'
      ,p_attribute5_value                => p_rec.tsr_information5
      ,p_attribute6_name                 => 'TSR_INFORMATION6'
      ,p_attribute6_value                => p_rec.tsr_information6
      ,p_attribute7_name                 => 'TSR_INFORMATION7'
      ,p_attribute7_value                => p_rec.tsr_information7
      ,p_attribute8_name                 => 'TSR_INFORMATION8'
      ,p_attribute8_value                => p_rec.tsr_information8
      ,p_attribute9_name                 => 'TSR_INFORMATION9'
      ,p_attribute9_value                => p_rec.tsr_information9
      ,p_attribute10_name                => 'TSR_INFORMATION10'
      ,p_attribute10_value               => p_rec.tsr_information10
      ,p_attribute11_name                => 'TSR_INFORMATION11'
      ,p_attribute11_value               => p_rec.tsr_information11
      ,p_attribute12_name                => 'TSR_INFORMATION12'
      ,p_attribute12_value               => p_rec.tsr_information12
      ,p_attribute13_name                => 'TSR_INFORMATION13'
      ,p_attribute13_value               => p_rec.tsr_information13
      ,p_attribute14_name                => 'TSR_INFORMATION14'
      ,p_attribute14_value               => p_rec.tsr_information14
      ,p_attribute15_name                => 'TSR_INFORMATION15'
      ,p_attribute15_value               => p_rec.tsr_information15
      ,p_attribute16_name                => 'TSR_INFORMATION16'
      ,p_attribute16_value               => p_rec.tsr_information16
      ,p_attribute17_name                => 'TSR_INFORMATION17'
      ,p_attribute17_value               => p_rec.tsr_information17
      ,p_attribute18_name                => 'TSR_INFORMATION18'
      ,p_attribute18_value               => p_rec.tsr_information18
      ,p_attribute19_name                => 'TSR_INFORMATION19'
      ,p_attribute19_value               => p_rec.tsr_information19
      ,p_attribute20_name                => 'TSR_INFORMATION20'
      ,p_attribute20_value               => p_rec.tsr_information20
      );
  END IF;

  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
END chk_df;


--
--
--*****************************************************************************
--			GENERAL VALIDATION PROCEDURES
--*****************************************************************************
procedure validation1
(
p_rec in ota_tsr_shd.g_rec_type
)
is
---------------------
begin
--
check_tsr_key (
   p_business_group_id	  => p_rec.business_group_id,
   p_resource_type        => p_rec.resource_type,
   p_vendor_id		  => p_rec.vendor_id,
   p_supplied_resource_id => p_rec.supplied_resource_id,
   p_name		  => p_rec.name,
   p_training_center_id   => p_rec.training_center_id
   );
--
check_tsr_dates (
   p_startdate 		  => p_rec.start_date,
   p_enddate		  => p_rec.end_date);

chk_Training_center
  (p_supplied_resource_id  => p_rec.supplied_resource_id,
   p_training_center_id    => p_rec.training_center_id);


Chk_location
  (p_supplied_resource_id  => p_rec.supplied_resource_id,
   p_location_id 	         => p_rec.location_id,
   p_training_center_id    => p_rec.training_center_id);

Chk_trainer
  (p_supplied_resource_id  => p_rec.supplied_resource_id,
   p_trainer_id 	         => p_rec.trainer_id,
   p_business_group_id	   => p_rec.business_group_id,
   p_start_date            => p_rec.start_date,
   p_end_date              => p_rec.end_date);
--
end validation1;
--=============================================================================
--=============================================================================
procedure validation2
(
p_rec in ota_tsr_shd.g_rec_type
)
is
---------------------
begin
--
check_cost_and_currency (
   p_cost		=> p_rec.cost,
   p_currency_code	=> p_rec.currency_code );
--
end validation2;
--=============================================================================
--=============================================================================
procedure insert_validate2
(
p_rec in ota_tsr_shd.g_rec_type
)
is
---------------------
begin
--
validation1(p_rec);
--
validation2(p_rec);
--
end insert_validate2;
--=============================================================================
--=============================================================================
procedure update_validate2
(
p_rec in ota_tsr_shd.g_rec_type
)
is
---------------------
begin
--
check_type_update(
   p_tsr_id		=> p_rec.supplied_resource_id,
   p_ovn		=> p_rec.object_version_number,
   p_resource_type	=> p_rec.resource_type);
--
validation1(p_rec);
--
check_tsr_new_dates (
	p_tsr_id => p_rec.supplied_resource_id,
	p_startdate => p_rec.start_date,
	p_enddate => p_rec.end_date);
--
validation2(p_rec);
--
end update_validate2;
--=============================================================================
--=============================================================================
procedure delete_validate2
(
p_rec in ota_tsr_shd.g_rec_type
)
is
---------------------
begin
--
del_check_bookings(p_rec.supplied_resource_id);
--
del_check_usages(p_rec.supplied_resource_id);
--
end delete_validate2;
--*****************************************************************************
--				END OF MANUALLY WRITTEN SECTION
--*****************************************************************************
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_tsr_shd.g_rec_type) is
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
  ota_tsr_bus.chk_df(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ota_tsr_shd.g_rec_type) is
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
Procedure delete_validate(p_rec in ota_tsr_shd.g_rec_type) is
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

-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This function will be used by the user hooks. This will be  used
--   of by the user hooks of ota_suppliable_resources and
--   ota_resource_booking row handler user hook business process.
--
-- Pre Conditions:
--   This function will be called by the user hook packages.
--
-- In Arguments:
--   SUPPLIED_RESOURCE_ID
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Errors out
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--------------------------------------------------------------------------------
--
Function return_legislation_code
         ( p_supplied_resource_id     in number
          ) return varchar2 is
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups_perf pbg,
                 ota_suppliable_resources tsr
          where  pbg.business_group_id    = tsr.business_group_id
            and  tsr.supplied_resource_id = p_supplied_resource_id;


   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'supplied_resource_id',
                              p_argument_value => p_supplied_resource_id);
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;

end ota_tsr_bus;

/
