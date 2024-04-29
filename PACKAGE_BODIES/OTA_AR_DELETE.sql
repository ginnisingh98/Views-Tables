--------------------------------------------------------
--  DDL for Package Body OTA_AR_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_AR_DELETE" as
/* $Header: otdar01t.pkb 115.0 99/07/16 00:51:11 porting ship $ */
--
g_package  varchar2(33)	:= '  ota_ar_delete.';  -- Global package name
--
Procedure check_delete(p_customer_id number default null
                      ,p_contact_id  number default null
                      ,p_address_id  number default null) is
--
  l_proc 	varchar2(72) := g_package||'check_delete';
  l_exists      varchar2(1);
--
  cursor c_booking_deals is
  select null
  from  ota_booking_deals
  where customer_id = p_customer_id;
--
  cursor c_delegate_bookings1 is
  select null
  from   ota_delegate_bookings
  where  customer_id = p_customer_id;
--
  cursor c_delegate_bookings2 is
  select null
  from   ota_delegate_bookings
  where  third_party_customer_id = p_customer_id;
--
  cursor c_delegate_bookings3 is
  select null
  from   ota_delegate_bookings
  where  contact_id = p_contact_id;
--
  cursor c_delegate_bookings4 is
  select null
  from   ota_delegate_bookings
  where  third_party_contact_id = p_contact_id;
--
  cursor c_delegate_bookings5 is
  select null
  from   ota_delegate_bookings
  where  delegate_contact_id = p_contact_id;
--
  cursor c_delegate_bookings6 is
  select null
  from   ota_delegate_bookings
  where  contact_address_id = p_address_id;
--
  cursor c_delegate_bookings7 is
  select null
  from   ota_delegate_bookings
  where  third_party_address_id = p_address_id;
--
  cursor c_event_associations is
  select null
  from   ota_event_associations
  where  customer_id = p_customer_id;
--
  cursor c_finance_headers1 is
  select null
  from   ota_finance_headers
  where  customer_id = p_customer_id;
--
  cursor c_finance_headers2 is
  select null
  from   ota_finance_headers
  where  contact_id = p_contact_id
  and    customer_id is not null;
--
  cursor c_finance_headers3 is
  select null
  from   ota_finance_headers
  where  address_id = p_address_id
  and    customer_id is not null;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_customer_id is not null then
     --
  hr_utility.set_location('Entering:'||l_proc, 15);
     open c_booking_deals;
     fetch c_booking_deals into l_exists;
     if c_booking_deals%found then
        close c_booking_deals;
        fnd_message.set_name('OTA','OTA_13540_CUSTOMER_DELETE');
        fnd_message.set_token('TABLE','OTA_BOOKING_DEALS');
        fnd_message.set_token('COLUMN','CUSTOMER_ID');
        fnd_message.raise_error;
     end if;
     close c_booking_deals;
     --
  hr_utility.set_location('Entering:'||l_proc, 20);
     open c_delegate_bookings1;
     fetch c_delegate_bookings1 into l_exists;
     if c_delegate_bookings1%found then
        close c_delegate_bookings1;
        fnd_message.set_name('OTA','OTA_13540_CUSTOMER_DELETE');
        fnd_message.set_token('TABLE','OTA_BOOKING_DEALS');
        fnd_message.set_token('COLUMN','CUSTOMER_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings1;
     --
  hr_utility.set_location('Entering:'||l_proc, 25);
     open c_delegate_bookings2;
     fetch c_delegate_bookings2 into l_exists;
     if c_delegate_bookings2%found then
        close c_delegate_bookings2;
        fnd_message.set_name('OTA','OTA_13540_CUSTOMER_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','THIRD_PARTY_CUSTOMER_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings2;
     --
  hr_utility.set_location('Entering:'||l_proc, 30);
     open c_event_associations;
     fetch c_event_associations into l_exists;
     if c_event_associations%found then
        close c_event_associations;
        fnd_message.set_name('OTA','OTA_13540_CUSTOMER_DELETE');
        fnd_message.set_token('TABLE','OTA_EVENT_ASSOCIATIONS');
        fnd_message.set_token('COLUMN','CUSTOMER_ID');
        fnd_message.raise_error;
     end if;
     close c_event_associations;
     --
  hr_utility.set_location('Entering:'||l_proc, 35);
     open c_finance_headers1;
     fetch c_finance_headers1 into l_exists;
     if c_finance_headers1%found then
        close c_finance_headers1;
        fnd_message.set_name('OTA','OTA_13540_CUSTOMER_DELETE');
        fnd_message.set_token('TABLE','OTA_FINANCE_HEADERS');
        fnd_message.set_token('COLUMN','CUSTOMER_ID');
        fnd_message.raise_error;
     end if;
     close c_finance_headers1;
     --
  elsif p_contact_id is not null then
     --
  hr_utility.set_location('Entering:'||l_proc, 40);
     open c_delegate_bookings3;
     fetch c_delegate_bookings3 into l_exists;
     if c_delegate_bookings3%found then
        close c_delegate_bookings3;
        fnd_message.set_name('OTA','OTA_13541_CONTACT_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','CONTACT_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings3;
     --
  hr_utility.set_location('Entering:'||l_proc, 45);
     open c_delegate_bookings4;
     fetch c_delegate_bookings4 into l_exists;
     if c_delegate_bookings4%found then
        close c_delegate_bookings4;
        fnd_message.set_name('OTA','OTA_13541_CONTACT_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','THIRD_PARTY_CONTACT_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings4;
     --
  hr_utility.set_location('Entering:'||l_proc, 50);
     open c_delegate_bookings5;
     fetch c_delegate_bookings5 into l_exists;
     if c_delegate_bookings5%found then
        close c_delegate_bookings5;
        fnd_message.set_name('OTA','OTA_13541_CONTACT_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','DELEGATE_CONTACT_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings5;
     --
  hr_utility.set_location('Entering:'||l_proc, 55);
     open c_finance_headers2;
     fetch c_finance_headers2 into l_exists;
     if c_finance_headers2%found then
        close c_finance_headers2;
        fnd_message.set_name('OTA','OTA_13541_CONTACT_DELETE');
        fnd_message.set_token('TABLE','OTA_FINANCE_HEADERS');
        fnd_message.set_token('COLUMN','CONTACT_ID');
        fnd_message.raise_error;
     end if;
     close c_finance_headers2;
     --
  elsif p_address_id is not null then
     --
  hr_utility.set_location('Entering:'||l_proc, 60);
     open c_delegate_bookings6;
     fetch c_delegate_bookings6 into l_exists;
     if c_delegate_bookings6%found then
        close c_delegate_bookings6;
        fnd_message.set_name('OTA','OTA_13542_ADDRESS_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','CONTACT_ADDRESS_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings6;
     --
  hr_utility.set_location('Entering:'||l_proc, 65);
     open c_delegate_bookings7;
     fetch c_delegate_bookings7 into l_exists;
     if c_delegate_bookings7%found then
        close c_delegate_bookings7;
        fnd_message.set_name('OTA','OTA_13542_ADDRESS_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','THIRD_PARTY_ADDRESS_ID');
        fnd_message.raise_error;
     end if;
     close c_delegate_bookings7;
     --
  hr_utility.set_location('Entering:'||l_proc, 70);
     open c_finance_headers3;
     fetch c_finance_headers3 into l_exists;
     if c_finance_headers3%found then
        close c_finance_headers3;
        fnd_message.set_name('OTA','OTA_13542_ADDRESS_DELETE');
        fnd_message.set_token('TABLE','OTA_FINANCE_HEADERS');
        fnd_message.set_token('COLUMN','ADDRESS_ID');
        fnd_message.raise_error;
     end if;
     close c_finance_headers3;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 75);
end;
--
end ota_ar_delete;

/
