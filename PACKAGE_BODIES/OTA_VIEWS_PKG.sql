--------------------------------------------------------
--  DDL for Package Body OTA_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_VIEWS_PKG" as
/* $Header: otaonvew.pkb 120.0 2005/05/29 06:57:47 appldev noship $ */

--
-- Function to find the number of available places in a Training Course
--
function OTA_GET_PLACES_AVAILABLE(p_event_id    number)
     return number
as
  l_places_booked   	number;
  l_max_places       	number;
  l_max_internal_places number;
  l_internal_places_booked number;
  l_no_of_int_places_remaining number;
  l_no_of_places_remaining number;
  l_place_wait          number;
  l_event_status   varchar2(1);
BEGIN
   select nvl(sum(db.number_of_places),0)
   into   l_places_booked
   from   ota_delegate_bookings db
   ,      ota_booking_status_types bst
   where  bst.booking_status_type_id = db.booking_status_type_id
   and    ota_tdb_bus.event_place_needed(bst.booking_status_type_id) = 1
   and    db.event_id = p_event_id ;

   select nvl(sum(db.number_of_places),0)
   into   l_place_wait
   from   ota_delegate_bookings db
   ,      ota_booking_status_types bst
   where  bst.booking_status_type_id = db.booking_status_type_id
   and    bst.type = 'W'
   and    db.event_id = p_event_id ;


   select nvl(sum(db.number_of_places),0)
   into   l_internal_places_booked
   from   ota_delegate_bookings db
   ,      ota_booking_status_types bst
   where  bst.booking_status_type_id = db.booking_status_type_id
   and    ota_tdb_bus.event_place_needed(bst.booking_status_type_id) = 1
   and    db.internal_booking_flag='Y'
   and    db.event_id = p_event_id ;

   select nvl(maximum_attendees,0)
   into   l_max_places
   from   ota_events
   where  event_id = p_event_id ;

   select nvl(maximum_internal_attendees, -1)
   into l_max_internal_places
   from ota_events
   where event_id = p_event_id;

   select event_status
   into l_event_status
   from ota_events
   where event_id = p_event_id;


   l_no_of_places_remaining :=
        l_max_places - l_places_booked;

   if l_max_internal_places <> -1 THEN
     -- There is an internal  limitation

     l_no_of_int_places_remaining :=
       l_max_internal_places - l_internal_places_booked;

     if l_no_of_int_places_remaining < l_no_of_places_remaining then
       -- There are less internal places available then the amount
       -- of places which could have been filled so use the lower of
       -- the two figures
       l_no_of_places_remaining := l_no_of_int_places_remaining;
     end if;
     if l_no_of_places_remaining < 0 then
       l_no_of_places_remaining := 0 ;
     end if;
   else
      l_no_of_places_remaining :=
      l_max_places - l_places_booked - l_place_wait;
      if l_no_of_places_remaining < 0 then
       l_no_of_places_remaining := 0 ;
     end if;
   end if;

 if l_event_status = 'F' then
      l_no_of_places_remaining := 0 ;
 end if;
   return (l_no_of_places_remaining) ;
END OTA_GET_PLACES_AVAILABLE;
--
END OTA_VIEWS_PKG ;

/
