--------------------------------------------------------
--  DDL for Package Body OTA_EVENT_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVENT_ASSOCIATIONS_PKG" as
/* $Header: ottea02t.pkb 120.0.12010000.2 2008/08/05 11:45:22 ubhat ship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_event_associations_pkg.';  -- Global package name
--
--
-- Check that max places is not exceeded for a booking deal
--
--
procedure check_booking_deal_places (p_event_id        in number,
				     p_customer_id     in number,
				     p_booking_deal_id in number,
				     p_places          in number) is
   --
   l_proc varchar2(80) := g_package||' check_booking_deal_places';
   l_places_used  number(9) := 0;
   l_max_places   number(9);
   --
   cursor c_places_used is
     select nvl(sum(number_of_places),0)
     from   ota_delegate_bookings tdb,
            ota_finance_lines fin,
            ota_booking_status_types bst,
	    ota_events evt
     where  fin.booking_deal_id = p_booking_deal_id
     and    fin.cancelled_flag = 'N'
     and    fin.booking_id = tdb.booking_id
     and    tdb.booking_status_type_id = bst.booking_status_type_id
     and    bst.type in ('P','A','E')
     and    tdb.event_id = evt.event_id
     and    ((evt.price_basis = 'C'
	      and tdb.delegate_contact_id is null
	      and tdb.customer_id <> p_customer_id
	      and tdb.event_id <> p_event_id)
              or evt.price_basis = 'S');
   --
   cursor c_max_places is
     select number_of_places
     from   ota_booking_deals
     where  booking_deal_id = p_booking_deal_id;
   --
begin
  --
   hr_utility.set_location('Entering '||l_proc,10);
   --
   -- Get maximum number of places for booking deal
   --
   open c_max_places;
      --
      fetch c_max_places into l_max_places;
      if c_max_places%notfound then
         --
         l_max_places := -1;
         --
      end if;
      --
   close c_max_places;
   --
   -- If no limit on booking deal then return to calling procedure
   --
   if l_max_places = -1 then
      return;
   end if;
   --
   -- Get number of places used
   --
   open c_places_used;
      --
      fetch c_places_used into l_places_used;
      --
    close c_places_used;
   --
   -- Check if number of places used and number of places requested
   -- exceed limit on places
   --
   if l_max_places < (l_places_used + p_places) then
      --
      fnd_message.set_name('OTA','OTA_13606_BOOKING_DEAL_PLACES');
      fnd_message.raise_error;
      --
   end if;
   --
   hr_utility.set_location('Leaving '||l_proc,10);
   --
end check_booking_deal_places;
--
procedure maintain_delegate_bookings
(
 p_validate			in boolean
,p_price_basis                  in varchar2
,p_business_group_id            in number
,p_event_id                     in number
,p_customer_id                  in number
,p_booking_id			in out nocopy number
,p_tdb_object_version_number 	in out nocopy number
,p_booking_status_type_id	in number
,p_date_status_changed          in date
,p_status_change_comments       in varchar2
,p_booking_contact_id		in number
,p_contact_address_id           in number
,p_delegate_contact_phone       in varchar2
,p_delegate_contact_fax         in varchar2
,p_internal_booking_flag	in varchar2
,p_source_of_booking		in varchar2
,p_number_of_places		in number
,p_date_booking_placed		in date
,p_update_finance_line          in varchar2
,p_tfl_object_version_number    in out nocopy number
,p_finance_header_id		in number
,p_currency_code                in varchar2
,p_standard_amount		in number
,p_unitary_amount		in number
,p_money_amount			in number
,p_booking_deal_id		in number
,p_booking_deal_type		in varchar2
,p_finance_line_id		in out nocopy number
,p_delegate_contact_email     in varchar2
) is
   --
   l_proc  varchar2(72) := g_package||'maintain_delegate_bookings';
   --
   l_create_finance_line varchar2(1);
   l_type varchar2(10);
   cursor c1 is
     select type
     from   ota_booking_status_types
     where  booking_status_type_id = p_booking_status_type_id;
   --
begin
   --
   hr_utility.set_location('Entering:'||l_proc,5);
   --
   if p_price_basis not in('C','O') or p_price_basis is null then
      return;
   end if;
   --
   if p_booking_contact_id is null then
      fnd_message.set_name('OTA','OTA_13554_TEA_CONTACT_NULL');
      fnd_message.raise_error;
   end if;
   --
   if p_number_of_places is null then
      fnd_message.set_name('OTA','OTA_13555_TEA_PLACES_NULL');
      fnd_message.raise_error;
   end if;
   --
   -- Check if booking needs a place
   --
   open c1;
     --
     fetch c1 into l_type;
     --
   close c1;
   --
   if l_type in ('P','A') then
      --
      check_booking_deal_places(p_event_id,
				p_customer_id,
			        p_booking_deal_id,
			        p_number_of_places);
      --
   end if;
   --
   if p_tdb_object_version_number is null then
      --
      if p_finance_header_id is not null then
         l_create_finance_line := 'Y';
      else
         l_create_finance_line := 'N';
      end if;
      --
      ota_tdb_api_ins2.create_enrollment (
	 p_booking_id			=> p_booking_id
	,p_booking_status_type_id	=> p_booking_status_type_id
	,p_contact_id			=> p_booking_contact_id
	,p_contact_address_id		=> p_contact_address_id
	,p_delegate_contact_phone	=> p_delegate_contact_phone
	,p_delegate_contact_fax		=> p_delegate_contact_fax
	,p_business_group_id		=> p_business_group_id
	,p_event_id			=> p_event_id
	,p_customer_id			=> p_customer_id
	,p_date_booking_placed		=> p_date_booking_placed
	,p_corespondent			=> 'C'
	,p_internal_booking_flag	=> p_internal_booking_flag
	,p_number_of_places		=> p_number_of_places
	,p_object_version_number	=> p_tdb_object_version_number
	,p_source_of_booking		=> p_source_of_booking
	,p_create_finance_line		=> l_create_finance_line
	,p_finance_header_id		=> p_finance_header_id
	,p_currency_code		=> p_currency_code
	,p_standard_amount		=> p_standard_amount
	,p_unitary_amount		=> p_unitary_amount
	,p_money_amount			=> p_money_amount
	,p_booking_deal_id		=> p_booking_deal_id
	,p_booking_deal_type		=> p_booking_deal_type
	,p_finance_line_id		=> p_finance_line_id
	,p_enrollment_type              => 'C'
	,p_validate			=> p_validate
      ,p_delegate_contact_email    => p_delegate_contact_email
	);
      --
   else
      --
      ota_tdb_api_upd2.update_enrollment (
         p_booking_id                   => p_booking_id
        ,p_booking_status_type_id       => p_booking_status_type_id
        ,p_date_status_changed          => p_date_status_changed
        ,p_status_change_comments       => p_status_change_comments
        ,p_contact_id                   => p_booking_contact_id
        ,p_contact_address_id           => p_contact_address_id
        ,p_delegate_contact_phone       => p_delegate_contact_phone
        ,p_delegate_contact_fax         => p_delegate_contact_fax
        ,p_business_group_id            => p_business_group_id
        ,p_event_id                     => p_event_id
        ,p_customer_id                  => p_customer_id
        ,p_internal_booking_flag        => p_internal_booking_flag
        ,p_number_of_places             => p_number_of_places
        ,p_object_version_number        => p_tdb_object_version_number
        ,p_source_of_booking            => p_source_of_booking
        ,p_update_finance_line          => p_update_finance_line
        ,p_tfl_object_version_number    => p_tfl_object_version_number
        ,p_finance_header_id            => p_finance_header_id
        ,p_currency_code                => p_currency_code
        ,p_standard_amount              => p_standard_amount
        ,p_unitary_amount               => p_unitary_amount
        ,p_money_amount                 => p_money_amount
        ,p_booking_deal_id              => p_booking_deal_id
        ,p_booking_deal_type            => p_booking_deal_type
        ,p_finance_line_id              => p_finance_line_id
        ,p_enrollment_type              => 'C'
	,p_validate                     => p_validate
      ,p_delegate_contact_email    => p_delegate_contact_email

        );
      --
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc,10);
   --
end maintain_delegate_bookings;

end ota_event_associations_pkg;

/
