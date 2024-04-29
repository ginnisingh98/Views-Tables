--------------------------------------------------------
--  DDL for Package OTA_TDB_BUS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TDB_BUS2" AUTHID CURRENT_USER as
/* $Header: ottdb01t.pkh 120.5.12010000.2 2009/08/13 09:15:22 smahanka ship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< check_person_address >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Person Address
--
--              Checks that the given person is registered at the given address
--
Procedure check_person_address (p_person_id           in number,
                                p_address_id          in number,
                                p_delegate_or_contact in varchar2);
-- ----------------------------------------------------------------------------
-- |-------------------------< other_bookings_clash >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Other Bookings Clash
--
--              Checks if the booking being made clashes with any other
--              bookings for the delegate
--              Note - bookings only clash if they are confirmed
--
Function other_bookings_clash (p_delegate_person_id     in varchar2,
                               p_delegate_contact_id    in varchar2,
                p_event_id               in number,
                               p_booking_status_type_id in varchar2)
Return boolean;
-- ----------------------------------------------------------------------------
-- |-------------------------< overdraft_exceeded >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Overdraft Exceeded
--
--              Checks if the booking being made is greater than the
--              overdraft limit if there is one. It takes into account
--              all other bookings as well for the pre-purchase agreement.
--
Function overdraft_exceeded (p_booking_deal_id in number,
                             p_money_amount    in number)
Return boolean;
-- ----------------------------------------------------------------------------
-- |--------------------------< check_person_visible >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Person Visible
--
--              Checks that the specified person is visible on the given date
--
Procedure check_person_visible (p_person_id            in number,
                                p_date_booking_placed  in date,
                                p_person_type          in varchar2,
                                p_person_address_type in varchar2);

--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_enrollment_type >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Enrollment Type
--
--              Checks whether a customer based enrollment follows the rules
--
Procedure check_enrollment_type(p_event_id             in number,
            p_person_id            in number,
                                p_enrollment_type      in varchar2,
            p_booking_id           in number);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_organization_details >------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Organization Id related information
--
--              Checks whether organization id is not null and whether :
--              if sponsor_person_id is not null then
--       sponsor_assignment_id must be not null
--    if delegate_person_id is not null then
--       delegate_assignment_id must be not null
--
Procedure check_organization_details(p_organization_id        in number,
                 p_delegate_person_id     in number,
                 p_delegate_assignment_id in number,
                                     p_sponsor_person_id      in number,
                 p_sponsor_assignment_id  in number);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_customer_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Customer Id related information
--
--              Checks whether customer id is not null and whether :
--              if contact_id is not null then
--       contact must exist for the customer id
--    if delegate_contact_id is not null then
--       delegate_contact_id must exist for the customer
--
Procedure check_customer_details(p_customer_id         in number,
             p_delegate_contact_id in number,
             p_sponsor_contact_id  in number);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_contact_address >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Contact Address Id related information
--
--              Checks whether contact address id is not null and that :
--              The address_id is valid for the customer
--
Procedure check_contact_address (p_contact_address_id  in number,
             p_customer_id         in number);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_org_business_group >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Checks Organization business group information
--
--              Checks whether business group id for an internal enrollment is :
--                the same as the organization_id
--       the same as the delegate_person_id
--                      the same as the sponsor_person_id
--                      the same as the delegate_assignment_id
--                      the same as the sponsor_assignment_id
--
Procedure check_org_business_group (p_event_id               in number,
                p_business_group_id      in number,
                                    p_organization_id        in number,
                p_delegate_person_id     in number,
                p_sponsor_person_id      in number,
                                    p_delegate_assignment_id in number,
                                    p_sponsor_assignment_id  in number,
                p_date_booking_placed    in date);
--
--
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_spon_del_validity >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check whether delegate and sponsor are valid at the time
--              of the enrollment and at the time when the event started.
--              They must exist as employees around the time periods above.
--
--              Checks whether organization id is not null and whether :
--              if sponsor_person_id is not null then
--       sponsor_person_id must exist from before the
--                      event start date and on the day of the enrollment
--    if delegate_person_id is not null then
--       delegate_person_id must exist from before the
--                      event start date and on the day of the enrollment
--
Procedure check_spon_del_validity(p_event_id               in number,
                                  p_organization_id        in number,
                   p_delegate_person_id     in number,
                   p_sponsor_person_id      in number,
              p_date_booking_placed    in date);
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_old_event_changed  >------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will check whether the event id is changed.
Procedure chk_old_event_changed
  (p_booking_id         in number
   ,p_event_id    in number
  ) ;

--
-- ----------------------------------------------------------------------------
-- |---------------------------<  check_commitment_date  >------------------------|
-- ----------------------------------------------------------------------------
-- This procedure will check whether Event End Date is on or before
-- commitment_end_date. If it is, then raise an error.
--
Procedure check_commitment_date(p_line_id IN NUMBER,
            p_event_id  IN NUMBER);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Check Location  >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check the event location when Inserting or updating. If country
-- of the event is the not the same as that of Operating Unit, then raise an  error.
-- This check is performed only when the profile 'OTA:Restrict Enrollment by Country'
-- is set to yes.
--
--
procedure Check_Location(p_event_id IN NUMBER,
                         p_om_org_id IN VARCHAR2) ;
--
--
end ota_tdb_bus2;

/
