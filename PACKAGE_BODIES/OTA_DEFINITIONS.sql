--------------------------------------------------------
--  DDL for Package Body OTA_DEFINITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_DEFINITIONS" as
/* $Header: otobk01t.pkb 115.0 99/07/16 00:52:40 porting ship $ */
--
-- |--------------------------------------------------------------------------|
-- |-----------------------< status_usage >-----------------------------------|
-- |--------------------------------------------------------------------------|
--
/*
   Contains code to determine the meaning of booking status types defined
   by the user

   PLACE_USED -  determines the list of Booking_Status_Type_IDs
                 that constitute the use of a place on a course
*/
--
function status_usage(p_usage_type in varchar2
                     ,p_booking_status_type_id in number)
    return number is
--
  l_proc 	varchar2(72) := 'status_usage';
--
begin
--
  --
  if p_usage_type = 'PLACE_USED' then
     if p_booking_status_type_id in
  --
  /* --------------------------------------------------------------------
     Modify this list to include the Booking Status Type IDs that you want
     to be taken into account when calculating whether a an enrolment
     uses places on an event
     --------------------------------------------------------------------*/
  --
        (59,32,31)
  --
        then return(1);
     else
        return(0);
     end if;
  else
     return(0);
  end if;
--
end;
--
end ota_definitions;

/
