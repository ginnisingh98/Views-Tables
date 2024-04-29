--------------------------------------------------------
--  DDL for Package Body OTA_TEA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TEA_BUS" as
/* $Header: ottea01t.pkb 120.1 2005/06/09 01:16:02 jbharath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tea_bus.';  -- Global package name
--
--------------------------------------------------------------------
function tea_has_tdb (
  p_event_id	in number
 ,p_customer_id in number
)
return boolean is
---------------
cursor csr_tdb is
 	select 1
	from ota_delegate_bookings tdb
	where tdb.event_id = p_event_id
	  and tdb.customer_id = p_customer_id;
--
l_tdb_exist	boolean;
l_dummy 	integer;
--
procedure chkp is
begin
  hr_api.mandatory_arg_error(g_package,'Event_id',p_event_id);
  hr_api.mandatory_arg_error(g_package,'Customer_id',p_customer_id);
end chkp;
-------------
begin
--
  chkp;
--
  open csr_tdb;
  fetch csr_tdb into l_dummy;
  l_tdb_exist := csr_tdb%found;
  close csr_tdb;
--
  return l_tdb_exist;
--
end tea_has_tdb;
--==============================================================
--==============================================================
procedure check_event
(
 p_evt_id  number
)
is
--
cursor csr_evt_type is
        select event_type
        from ota_events
        where event_id = p_evt_id;
--
l_evt_type		OTA_EVENTS.event_type%TYPE;
l_parent_exists         boolean;
--
-------------
begin
--
if p_evt_id is null then
	fnd_message.set_name('OTA','OTA_13222_GEN_MANDATORY_VALUE');
	fnd_message.set_token('FIELD','Event');
	fnd_message.set_token('OPTIONAL_EXTENSION','');
        fnd_message.raise_error;
end if;
--
open csr_evt_type;
fetch csr_evt_type into l_evt_type;
l_parent_exists := csr_evt_type%found;
close csr_evt_type;
--
if not l_parent_exists then
        fnd_message.set_name('OTA','OTA_13202_GEN_INVALID_KEY');
        fnd_message.set_token('COLUMN_NAME','Event_id');
        fnd_message.set_token('TABLE_NAME','OTA_EVENTS');
        fnd_message.raise_error;
end if;
--
if not l_evt_type in ('AD-HOC','SCHEDULED','PROGRAMME') then
        fnd_message.set_name('OTA','OTA_13288_TEA_WRONG_EVENT_TYPE');
        fnd_message.raise_error;
end if;
--
end check_event;
--==============================================================
--==============================================================
procedure check_customer (p_customer_id	number) is
--
cursor csr_customer is
	select 1
	from  hz_parties party, hz_cust_accounts cust_acct
	where  cust_acct.party_id = party.party_id
	and cust_acct.cust_account_id = p_customer_id;
--
l_customer_exists	boolean;
l_dummy			integer;
---------------
begin
--
if p_customer_id is null then
        fnd_message.set_name('OTA','OTA_13222_GEN_MANDATORY_VALUE');
        fnd_message.set_token('FIELD','Customer');
        fnd_message.set_token('OPTIONAL_EXTENSION','');
        fnd_message.raise_error;
end if;
--
open csr_customer;
fetch csr_customer into l_dummy;
l_customer_exists := csr_customer%found;
close csr_customer;
--
if not l_customer_exists then
        fnd_message.set_name('OTA','OTA_13202_GEN_INVALID_KEY');
        fnd_message.set_token('COLUMN_NAME','CUST_ACCOUNT_ID');
        fnd_message.set_token('TABLE_NAME','HZ_CUST_ACCOUNTS');
        fnd_message.raise_error;
end if;
--
end check_customer;
--==============================================================
--==============================================================
procedure check_event_and_customer
(
 p_tea_id number
,p_evt_id number
,p_cus_id number
)
is
--
cursor c_get_internal_association is
--
select 'X'
from ota_event_associations
where event_id = p_evt_id
and   (organization_id is not null
      or position_id is not null
      or job_id is not null);
--
cursor csr_tea is
	select 1
	from ota_event_associations
	where event_id = p_evt_id
	  and customer_id = p_cus_id
	  and (p_tea_id is null or event_association_id <> p_tea_id);
--
l_dummy		number;
l_tea_exists	boolean;
l_exists        varchar2(30);
------------
begin
--
check_event(p_evt_id);
--
check_customer(p_cus_id);
--
   open c_get_internal_association;
   fetch c_get_internal_association into l_exists;
   if c_get_internal_association%found then
      close c_get_internal_association;
      fnd_message.set_name('OTA','OTA_13594_EVT_INT_ASSOCIATION');
      fnd_message.raise_error;
   end if;
   close c_get_internal_association;
--
open csr_tea;
fetch csr_tea into l_dummy;
l_tea_exists := csr_tea%found;
close csr_tea;
--
if l_tea_exists then
        fnd_message.set_name('OTA','OTA_13289_TEA_DUPLICATE_ROW');
        fnd_message.raise_error;
end if;
--
end check_event_and_customer;
--==============================================================
--==============================================================
procedure check_event_and_assignment
(
 p_event_association_id number
,p_event_id            number
,p_organization_id     number
,p_job_id              number
,p_position_id         number
) is
--
l_exists varchar2(1);
--l_cross_business_group varchar2(1):= fnd_profile.value('HR_CROSS_BUSINESS_GROUP') ;
l_business_group_id    ota_events.business_group_id%type := fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
--
cursor c_get_customer_association is
select 'X'
from ota_event_associations
where event_id = p_event_id
and   customer_id is not null;
--
cursor get_duplicate_tea is
select null
from   ota_event_associations
where  event_id = p_event_id
and    customer_id is null
and  ((p_organization_id is null and
       organization_id   is null)
   or (p_organization_id = organization_id))
and  ((p_job_id is null and
       job_id   is null)
   or (p_job_id = job_id))
and  ((p_position_id is null and
       position_id   is null)
   or (p_position_id = position_id))
and (p_event_association_id is null
  or event_association_id <> p_event_association_id);
--
cursor check_org_job_pos is
select null
from   ota_events evt
where  event_id = p_event_id
and   (p_organization_id is null or exists
      (select null
       from   hr_organization_units
       where  organization_id = p_organization_id
       and    business_group_id = evt.business_group_id))
and   (p_job_id is null or exists
      (select null
       from per_jobs
       where job_id = p_job_id
       and    business_group_id = evt.business_group_id))
and   (p_position_id is null or exists
      (select null
       from per_positions
       where position_id = p_position_id
       and    business_group_id = evt.business_group_id));

/* For Globalization */
cursor check_org_job_pos_cross is
select null
from   ota_events evt
where  event_id = p_event_id
and   (p_organization_id is null or exists
      (select null
       from   hr_all_organization_units
       where  organization_id = p_organization_id
      ))
and   (p_job_id is null or exists
      (select null
       from per_jobs
       where job_id = p_job_id
       ))
and   (p_position_id is null or exists
      (select null
       from per_all_positions
       where position_id = p_position_id
       ));

begin
--
   open c_get_customer_association;
   fetch c_get_customer_association into l_exists;
   if c_get_customer_association%found then
      close c_get_customer_association;
      fnd_message.set_name('OTA','OTA_13595_EVT_CUST_ASSOCIATION');
      fnd_message.raise_error;
   end if;
   close c_get_customer_association;
--

If l_business_group_id is not null then
       open check_org_job_pos_cross;
       fetch check_org_job_pos_cross into l_exists;
      if check_org_job_pos_cross%notfound then
       close check_org_job_pos_cross;
       fnd_message.set_name('OTA','OTA_13529_TEA_ORG_JOB_POS');
       fnd_message.raise_error;
      end if;
      close check_org_job_pos_cross;
else
   open check_org_job_pos;
   fetch check_org_job_pos into l_exists;
   if check_org_job_pos%notfound then
      close check_org_job_pos;
      fnd_message.set_name('OTA','OTA_13529_TEA_ORG_JOB_POS');
      fnd_message.raise_error;
   end if;
   close check_org_job_pos;
end if;
--
   open get_duplicate_tea;
   fetch get_duplicate_tea into l_exists;
   if get_duplicate_tea%found then
      close get_duplicate_tea;
      fnd_message.set_name('OTA','OTA_13530_TEA_DUPLICATE_CRIT');
      fnd_message.raise_error;
   end if;
   close get_duplicate_tea;
--
end;
--==============================================================
--==============================================================
--
-- PUBLIC
--  Description: Client side check for the creation of an event association
--
procedure client_check_event_customer (
p_event_association_id in number,
p_event_id 	in number,
p_customer_id	in number)
is
----------------
begin
--
if p_event_association_id is not null then
	-- No creation
	return;
end if;
--
check_event_and_customer (
	p_tea_id	  => null,
	p_evt_id	  => p_event_id,
	p_cus_id	  => p_customer_id);
--
--insert_check_no_bookings (p_event_id, p_customer_id);
--
end client_check_event_customer;
--=======================================================
--
--  PUBLIC
--  Description: Check pre-purchase agreement does not exceed
--               limit + overdraft.
--
function check_pre_purchase_agreement (p_booking_deal_id   in number,
				       p_event_id          in number,
	  			       p_money_amount      in number,
				       p_finance_header_id in number)
				       return boolean is
  --
  l_proc varchar2(80) := g_package||' check_pre_purchase_agreement';
  --
  l_overdraft_limit    number := 0;
  l_amount_so_far      number := 0;
  l_pre_purchase_limit number := 0;
  l_warn               boolean := false;
  --
  cursor c_overdraft_limit is
    select nvl(overdraft_limit,0)
    from   ota_booking_deals
    where  booking_deal_id = p_booking_deal_id;
  --
  cursor c_amount_so_far is
    select sum(nvl(money_amount,0))
    from   ota_finance_lines
    where  finance_header_id = p_finance_header_id
    and    booking_id is not null
    and    cancelled_flag <> 'Y'
    and    booking_deal_id <> p_booking_deal_id;
  --
  cursor c_pre_purchase_limit is
    select sum(nvl(money_amount,0))
    from   ota_finance_lines
    where  booking_deal_id = p_booking_deal_id
    and    booking_id is null
    and    cancelled_flag <> 'Y';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Display values of all variables passed in
  --
  hr_utility.trace('p_booking_deal_id '||p_booking_deal_id);
  hr_utility.trace('p_event_id '||p_event_id);
  hr_utility.trace('p_money_amount '||p_money_amount);
  hr_utility.trace('p_finance_header_id'||p_finance_header_id);
  --
  -- get pre_purchase_agreement_details
  --
  open c_pre_purchase_limit;
    --
    fetch c_pre_purchase_limit into l_pre_purchase_limit;
    --
  close c_pre_purchase_limit;
  --
  -- check if pre-purchase agreement has a limit
  --
  if l_pre_purchase_limit = 0 then
    --
    l_warn := true;
    --
  else
    --
    -- get overdraft limit
    --
    open c_overdraft_limit;
      --
      fetch c_overdraft_limit into l_overdraft_limit;
      --
    close c_overdraft_limit;
    --
    -- Get amount used so far for booking deal
    --
    open c_amount_so_far;
      --
      fetch c_amount_so_far into l_amount_so_far;
      --
      if c_amount_so_far%notfound or
	l_amount_so_far is null then
	--
	l_amount_so_far := 0;
	--
      end if;
      --
    close c_amount_so_far;
    --
    -- Check if limit exceeded
    --
    hr_utility.trace(p_money_amount||' '||l_amount_so_far);
    hr_utility.trace(l_overdraft_limit||' '||l_pre_purchase_limit);
    if (p_money_amount + l_amount_so_far) >
      (l_overdraft_limit + l_pre_purchase_limit) then
      --
      hr_utility.trace('Set Warning Flag');
      l_warn := true;
      --
    end if;
    --
  end if;
  --
  -- Check if warning message needed
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
  if l_warn then
    --
    return true;
    --
  else
    --
    return false;
    --
  end if;
  --
end check_pre_purchase_agreement;
--=======================================================
procedure check_public_event_flag(p_event_id in number) is
--
l_public_event_flag varchar2(30);
--
cursor get_event is
select public_event_flag
from ota_events
where event_id = p_event_id;
--
begin
  open get_event;
  fetch get_event into l_public_event_flag;
  close get_event;
  --
  if l_public_event_flag = 'N' then
     null;
  else
     fnd_message.set_name('OTA','OTA_13531_TEA_UNRESTRICTED_EVT');
     fnd_message.raise_error;
  end if;
end check_public_event_flag;
--=======================================================
--=======================================================
procedure check_enrollments(p_event_id        in number
                           ,p_event_association_id in number
                           ,p_organization_id in number default null
                           ,p_job_id          in number default null
                           ,p_position_id     in number default null
                           ,p_customer_id     in number default null) is
--
l_exists varchar2(1);
l_proc varchar2(30) := 'check_enrollments';
--
cursor get_external_enrollments is
select null
from   ota_delegate_bookings tdb
where  tdb.event_id = p_event_id
and exists
   (select null
    from   ota_event_associations tea
    where  tea.event_id = p_event_id
    and    decode(tea.event_association_id,p_event_association_id
                 ,p_customer_id,tea.customer_id) = tdb.customer_id);
--
cursor get_internal_enrollments is
select asg.organization_id,asg.job_id,asg.position_id
from   ota_delegate_bookings tdb
,      per_assignments_f asg
,      ota_events evt
where  evt.event_id = p_event_id
and    evt.event_id = tdb.event_id
and    tdb.delegate_assignment_id = asg.assignment_id
and    tdb.date_booking_placed between
        asg.effective_start_date and asg.effective_end_date;
--
cursor get_associations(l_organization_id number
                       ,l_job_id number
                       ,l_position_id number) is
select null
from ota_event_associations tea
where event_id = p_event_id
and   event_association_id <> p_event_association_id
and   nvl(organization_id,-1) = decode(organization_id,null,-1
                                      ,nvl(l_organization_id,-1))
and   nvl(job_id,-1) = decode(job_id,null,-1
                                      ,nvl(l_job_id,-1))
and   nvl(position_id,-1) = decode(position_id,null,-1
                                      ,nvl(l_position_id,-1));
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   if p_customer_id is not null then
      open get_external_enrollments;
      fetch get_external_enrollments into l_exists;
      if get_external_enrollments%notfound then
         close get_external_enrollments;
         fnd_message.set_name('OTA','OTA_13532_TEA_CRITERIA_UNMATCH');
         fnd_message.raise_error;
      end if;
      close get_external_enrollments;
   --
   elsif p_customer_id is null then
hr_utility.trace('step 1');
      for internal_enrollments in get_internal_enrollments loop
        -- Test whether the Enrollment matches the new criteria
hr_utility.trace('step 2');
        if  ((p_organization_id is not null
        and p_organization_id = internal_enrollments.organization_id)
            or p_organization_id is null)
        and ((p_job_id is not null
        and p_job_id = internal_enrollments.job_id)
            or p_job_id is null)
        and ((p_position_id is not null
        and p_position_id = internal_enrollments.position_id)
            or p_position_id is null)
              then null;
        else
        --
hr_utility.trace('step 3');
        -- If it doesnt match then look for another set of criteria
           open get_associations(internal_enrollments.organization_id
                                ,internal_enrollments.job_id
                                ,internal_enrollments.position_id);
hr_utility.trace('step 4');
           fetch get_associations into l_exists;
hr_utility.trace('step 5');

             if get_associations%notfound then
                close get_associations;
                fnd_message.set_name('OTA','OTA_13532_TEA_CRITERIA_UNMATCH');
                fnd_message.raise_error;
             end if;
hr_utility.trace('step 6');
           close get_associations;
        end if;
      end loop;
   end if;
  hr_utility.set_location('Leaving:'||l_proc, 5);
end check_enrollments;
--=======================================================
--=======================================================
procedure delete_check_tdb (
   p_event_association_id	in number
)
is
---------------
cursor csr_combination is
        select event_id, customer_id
        from ota_event_associations
        where event_association_id = p_event_association_id;
--
l_event_id      number;
l_customer_id   number;
--
begin
--
open csr_combination;
fetch csr_combination into l_event_id,
                           l_customer_id;
if csr_combination%notfound then
        fnd_message.set_name('OTA','OTA_13202_GEN_INVALID_KEY');
        fnd_message.set_token('COLUMN_NAME','EVENT_ASSOCIATION_ID');
        fnd_message.set_token('TABLE_NAME','OTA_EVENT_ASSOCIATIONS');
        fnd_message.raise_error;
end if;
close csr_combination;
--
if l_customer_id is not null then
   if tea_has_tdb(l_event_id,l_customer_id) then
      fnd_message.set_name('OTA','OTA_13368_TEA_DEL_TDB_EXIST');
      fnd_message.raise_error;
   end if;
else
   check_enrollments(l_event_id,
                     p_event_association_id,
                     -1,
                     -1,
                     -1,
                     null);
end if;
--
end delete_check_tdb;
-- ==========================================================================
-- =========================================================================
--
-- PUBLIC
--
function derive_standard_price (
	 p_event_id		in number
	,p_business_group_id	in number
	,p_currency_code	in varchar2
	,p_booking_deal_type	in varchar2
	,p_customer_total_delegates in number
	,p_session_date		in date
	)
return number is
-----------
cursor csr_price is
    select ple.price
    from ota_price_lists tpl,
	ota_price_list_entries ple,
	ota_events evt,
	ota_vendor_supplies vsp
where
	evt.event_id = p_event_id
  and	tpl.business_group_id = p_business_group_id
  and   tpl.currency_code = p_currency_code
  and	(
	(p_booking_deal_type = 'P' and tpl.price_list_type = 'T')
				or
	(p_booking_deal_type <> 'P' and tpl.price_list_type = 'M')
				or
	(p_booking_deal_type is null and tpl.price_list_type = 'M')
	)
  and	ple.price_list_id = tpl.price_list_id
  and   vsp.vendor_supply_id(+) = ple.vendor_supply_id
  and   (    evt.activity_version_id = ple.activity_version_id
	  or evt.activity_version_id = vsp.vendor_supply_id )
   and	ple.price_basis = 'C'
   and  p_customer_total_delegates between ple.minimum_attendees and ple.maximum_attendees
   and	(
	(evt.course_start_date between ple.start_date and nvl(ple.end_date,hr_api.g_eot))
				or
	(evt.course_start_date is null and
	p_session_date between ple.start_date and nvl(ple.end_date,hr_api.g_eot))
	);
--
l_price		number;
-----------
procedure chkp is
begin
hr_api.mandatory_arg_error(g_package,'Event_id',p_event_id);
hr_api.mandatory_arg_error(g_package,'Business group',p_business_group_id);
hr_api.mandatory_arg_error(g_package,'Currency code',p_currency_code);
hr_api.mandatory_arg_error(g_package,'Number of delegates',p_customer_total_delegates);
hr_api.mandatory_arg_error(g_package,'Session date',p_session_date);
end chkp;
-----------
begin
--
chkp;
--
open csr_price;
fetch csr_price into l_price;
if csr_price%notfound then
        fnd_message.set_name('OTA','OTA_13413_TEA_PRICE_LIST_ENTRY');
        fnd_message.raise_error;
end if;
close csr_price;
return l_price;
-----------
end derive_standard_price;
-- ==========================================================================
-- =========================================================================
--
-- PUBLIC
--
function number_of_delegates
	(p_event IN number
	,p_customer IN number
)
return number
IS
--
--The following cursor sums the number of places for
--delegate bookings for an event for one customer.
--
   Cursor delegate_count
   IS
      select sum(a.number_of_places)
      from   ota_delegate_bookings a
      ,      ota_booking_status_types b
      where  a.booking_status_type_id = b.booking_status_type_id
      and    a.customer_id = p_customer
      and    a.event_id = p_event
      and    a.delegate_contact_id is null;
--
   v_counter number := 0; --variable used to collect the result from the cursor
--
BEGIN
   --
   -- take the number of places from the event association
   -- created customer bookings block.
   --
   open delegate_count;
     --
     fetch delegate_count into v_counter;
     --
   close delegate_count;
   --
   return v_counter;
   --
END number_of_delegates;
-- ==========================================================================
-- =========================================================================
--
-- PUBLIC
--
function new_price_list_hit
	(p_event_id                     IN number
	,p_business_group_id            IN number
	,p_customer_total_delegates     IN number
	,p_customer_total_delegates_old IN number
	,p_session_date                 IN date
	,p_booking_deal_type            IN varchar2
	,p_booking_deal_id              IN number
)
return boolean
IS
  l_warn boolean := false;
  l_dummy varchar2(30);
  --
  cursor c1 is
    select null
    from   ota_price_list_entries ple,
           ota_events evt,
 	   ota_price_lists_v tpl
    where  evt.event_id = p_event_id
    and    tpl.business_group_id = p_business_group_id
    and    tpl.currency_code = evt.currency_code
    and    tpl.price_list_id = ple.price_list_id
    and    ple.price_basis = 'C'
    and    ple.activity_version_id = evt.activity_version_id
    and    p_customer_total_delegates
           between ple.minimum_attendees
           and     ple.maximum_attendees
    and    p_customer_total_delegates_old
           not between ple.minimum_attendees
           and         ple.maximum_attendees
    and (
          (evt.course_start_date
           between ple.start_date
           and     nvl(ple.end_date,evt.course_start_date)
          )
          or
          (evt.course_start_date is null
           and p_session_date
           between ple.start_date
           and     nvl(ple.end_date,p_session_date)
          )
	)
    and (
         (p_booking_deal_type is null
          and tpl.price_list_type = 'M')
	 or
         (p_booking_deal_type is not null
          and exists (select null
	              from   ota_booking_deals tbd
                      where  tbd.booking_deal_id = p_booking_deal_id
                      and    (tbd.price_list_id is null
	                      or (tbd.price_list_id is not null
	                          and tbd.price_list_id = tpl.price_list_id
                                 )
                             )
                     )
         )
        )
   order by tpl.name;
   --
begin
  --
  open c1;
    --
    fetch c1 into l_dummy;
    --
    if c1%found then
      --
      l_warn := true;
      --
    end if;
    --
  close c1;
  --
  return l_warn;
  --
end new_price_list_hit;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ota_tea_shd.g_rec_type
                         ,p_association_type in varchar2) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_price_basis ota_events.price_basis%type;   /*     bug no 3476078 */
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
   if p_association_type = 'C' then
     check_event_and_customer(p_tea_id 		=> p_rec.event_association_id
                             ,p_evt_id 		=> p_rec.event_id
                             ,p_cus_id 		=> p_rec.customer_id);
  --
   else
     /*     bug no 3476078 */
     select price_basis into l_price_basis from ota_events where event_id = p_rec.event_id;
     if p_rec.customer_id is null and l_price_basis = 'C' then
       fnd_message.set_name('OTA','OTA_443659_ASG_LRNR_CUST_ERR');
       fnd_message.raise_error;
     end if;
     /*     bug no 3476078 */
     check_event_and_assignment(
                 p_event_association_id => p_rec.event_association_id
                ,p_event_id             => p_rec.event_id
                ,p_organization_id      => p_rec.organization_id
                ,p_job_id               => p_rec.job_id
                ,p_position_id          => p_rec.position_id
                );
   end if;
  --
   check_public_event_flag(p_rec.event_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ota_tea_shd.g_rec_type
                         ,p_association_type in varchar2) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_price_basis ota_events.price_basis%type;  /*     bug no 3476078 */
--
l_customer_changed boolean :=
   ota_general.value_changed( ota_tea_shd.g_old_rec.customer_id
                            , p_rec.customer_id );
l_organization_changed boolean :=
   ota_general.value_changed( ota_tea_shd.g_old_rec.organization_id
                            , p_rec.organization_id );
l_job_changed boolean :=
   ota_general.value_changed( ota_tea_shd.g_old_rec.job_id
                            , p_rec.job_id );
l_position_changed boolean :=
   ota_general.value_changed( ota_tea_shd.g_old_rec.position_id
                            , p_rec.position_id );
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
   if p_association_type = 'C' then
     if l_customer_changed then
        check_event_and_customer(p_tea_id 		=> p_rec.event_association_id
                                ,p_evt_id 		=> p_rec.event_id
                                ,p_cus_id 		=> p_rec.customer_id);
        --
        check_enrollments(p_event_id    => p_rec.event_id
                         ,p_event_association_id => p_rec.event_association_id
                         ,p_customer_id => p_rec.customer_id);
     end if;
   else
     /*     bug no 3476078 */
     select price_basis into l_price_basis from ota_events where event_id = p_rec.event_id;
     if p_rec.customer_id is null and l_price_basis = 'C' then
       fnd_message.set_name('OTA','OTA_443659_ASG_LRNR_CUST_ERR');
       fnd_message.raise_error;
     end if;
     /*     bug no 3476078 */

     if l_organization_changed
     or l_job_changed
     or l_position_changed then
        check_event_and_assignment(
                    p_event_association_id => p_rec.event_association_id
                   ,p_event_id             => p_rec.event_id
                   ,p_organization_id      => p_rec.organization_id
                   ,p_job_id               => p_rec.job_id
                   ,p_position_id          => p_rec.position_id
                   );
        --
        check_enrollments(p_event_id        => p_rec.event_id
                         ,p_event_association_id => p_rec.event_association_id
                         ,p_organization_id => p_rec.organization_id
                         ,p_job_id          => p_rec.job_id
                         ,p_position_id     => p_rec.position_id);
     end if;
   end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tea_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
     delete_check_tdb(p_event_association_id => p_rec.event_association_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_tea_bus;

/
