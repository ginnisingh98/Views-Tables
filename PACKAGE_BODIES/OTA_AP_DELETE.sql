--------------------------------------------------------
--  DDL for Package Body OTA_AP_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_AP_DELETE" as
/* $Header: otdap01t.pkb 115.0 99/07/16 00:51:04 porting ship $ */
--
g_package  varchar2(33)	:= '  ota_ap_delete.';  -- Global package name
--
Procedure check_delete(p_vendor_id number default null
                      ,p_contact_id number default null
                      ,p_vendor_site_id number default null) is
--
  l_proc 	varchar2(72) := g_package||'check_delete';
  l_exists      varchar2(1);
--
  cursor c_events is
  select null
  from  ota_events
  where vendor_id = p_vendor_id;
--
  cursor c_activity_versions is
  select null
  from   ota_activity_versions
  where  vendor_id = p_vendor_id;
--
  cursor c_suppliable_resources is
  select null
  from   ota_suppliable_resources
  where  vendor_id = p_vendor_id;
--
  cursor c_finance_headers1 is
  select null
  from   ota_finance_headers
  where  vendor_id = p_vendor_id;
--
  cursor c_finance_headers2 is
  select null
  from   ota_finance_headers
  where  contact_id = p_contact_id
  and    vendor_id is not null;
--
  cursor c_finance_headers3 is
  select null
  from   ota_finance_headers
  where  address_id = p_vendor_site_id
  and    vendor_id is not null;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_vendor_id is not null then
     --
  hr_utility.set_location('Entering:'||l_proc, 15);
     open c_events;
     fetch c_events into l_exists;
     if c_events%found then
        close c_events;
        fnd_message.set_name('OTA','OTA_13543_VENDOR_DELETE');
        fnd_message.set_token('TABLE','OTA_EVENTS');
        fnd_message.set_token('COLUMN','VENDOR_ID');
        fnd_message.raise_error;
     end if;
     close c_events;
     --
  hr_utility.set_location('Entering:'||l_proc, 20);
     open c_activity_versions;
     fetch c_activity_versions into l_exists;
     if c_activity_versions%found then
        close c_activity_versions;
        fnd_message.set_name('OTA','OTA_13543_VENDOR_DELETE');
        fnd_message.set_token('TABLE','OTA_BOOKING_DEALS');
        fnd_message.set_token('COLUMN','CUSTOMER_ID');
        fnd_message.raise_error;
     end if;
     close c_activity_versions;
     --
  hr_utility.set_location('Entering:'||l_proc, 25);
     open c_suppliable_resources;
     fetch c_suppliable_resources into l_exists;
     if c_suppliable_resources%found then
        close c_suppliable_resources;
        fnd_message.set_name('OTA','OTA_13543_VENDOR_DELETE');
        fnd_message.set_token('TABLE','OTA_DELEGATE_BOOKINGS');
        fnd_message.set_token('COLUMN','THIRD_PARTY_CUSTOMER_ID');
        fnd_message.raise_error;
     end if;
     close c_suppliable_resources;
     --
  hr_utility.set_location('Entering:'||l_proc, 35);
     open c_finance_headers1;
     fetch c_finance_headers1 into l_exists;
     if c_finance_headers1%found then
        close c_finance_headers1;
        fnd_message.set_name('OTA','OTA_13543_VENDOR_DELETE');
        fnd_message.set_token('TABLE','OTA_FINANCE_HEADERS');
        fnd_message.set_token('COLUMN','CUSTOMER_ID');
        fnd_message.raise_error;
     end if;
     close c_finance_headers1;
     --
  elsif p_contact_id is not null then
     --
  hr_utility.set_location('Entering:'||l_proc, 55);
     open c_finance_headers2;
     fetch c_finance_headers2 into l_exists;
     if c_finance_headers2%found then
        close c_finance_headers2;
        fnd_message.set_name('OTA','OTA_13544_VEND_CONTACT_DELETE');
        fnd_message.set_token('TABLE','OTA_FINANCE_HEADERS');
        fnd_message.set_token('COLUMN','CONTACT_ID');
        fnd_message.raise_error;
     end if;
     close c_finance_headers2;
     --
  elsif p_vendor_site_id is not null then
     --
  hr_utility.set_location('Entering:'||l_proc, 70);
     open c_finance_headers3;
     fetch c_finance_headers3 into l_exists;
     if c_finance_headers3%found then
        close c_finance_headers3;
        fnd_message.set_name('OTA','OTA_13545_VEND_SITE_DELETE');
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
end ota_ap_delete;

/
