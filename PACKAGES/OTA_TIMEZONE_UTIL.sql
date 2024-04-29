--------------------------------------------------------
--  DDL for Package OTA_TIMEZONE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TIMEZONE_UTIL" AUTHID CURRENT_USER as
/* $Header: ottznutl.pkh 120.0.12000000.1 2007/01/18 05:29:11 appldev noship $ */

CURSOR get_class_info(p_class_id NUMBER) IS
 SELECT ctu.online_flag, evt.timezone
 FROM ota_events evt
     ,ota_offerings ofn
     ,ota_category_usages ctu
 WHERE evt.parent_offering_id = ofn.offering_id
   AND ctu.category_usage_id = ofn.delivery_mode_id
   AND ctu.type = 'DM'
   AND evt.event_id = p_class_id;

CURSOR get_resource_booking_info(p_resource_booking_id NUMBER) IS
  SELECT ctu.online_flag
        ,trb.timezone_code
        ,ftl.name timezone
  FROM   ota_resource_bookings trb
       , ota_events evt
       , ota_category_usages ctu
       , ota_offerings ofn
       , fnd_timezones_tl ftl
  WHERE evt.parent_offering_id = ofn.offering_id
       AND evt.event_id = trb.event_id
       AND ctu.category_usage_id = ofn.delivery_mode_id
       AND ctu.type = 'DM'
       AND trb.resource_booking_id = p_resource_booking_id
       AND ftl.timezone_code = trb.timezone_code
       AND ftl.LANGUAGE = USERENV('LANG');

-- Returns the HZ Time zone Id corresponding to the Time zone code
-- It is used for 11i code.
FUNCTION Get_Timezone_ID(p_timezone_code       in	varchar2)
RETURN NUMBER;

-- Returns the server time zone code set by the profile "Server Timezone"
FUNCTION get_server_timezone_code
RETURN VARCHAR2;

-- Returns the Client Time Zone code and its name
PROCEDURE get_client_timezone_vals(
        p_timezone_code OUT NOCOPY varchar2
       ,p_timezone_name OUT NOCOPY varchar2);

PROCEDURE get_event_timezone_vals(
        p_event_id IN NUMBER
       ,p_timezone_code OUT NOCOPY VARCHAR2
       ,p_timezone_name OUT NOCOPY VARCHAR2);

-- Returns the time zone name corresponding to the time zone code
FUNCTION get_timezone_name(p_timezone_code in varchar2)
RETURN varchar2;

-- Converts date from one time zone to another.
FUNCTION convert_date(p_datevalue in DATE
                     ,p_timevalue IN VARCHAR2
                     ,p_src_timezone_code IN VARCHAR2
                     ,p_dest_timezone_code IN VARCHAR2)
RETURN DATE;

-- Returns the date and time converted from one time zone to another
FUNCTION convert_dateDT_time(p_datevalue in DATE
                            ,p_timevalue IN VARCHAR2
                            ,p_src_timezone_code IN VARCHAR2
                            ,p_dest_timezone_code IN VARCHAR2)
RETURN VARCHAR2;

/*
FUNCTION convert_date_fnd(p_date in DATE
                        ,p_src_timezone_code IN VARCHAR2
                        ,p_dest_timezone_code IN VARCHAR2)
RETURN DATE;

FUNCTION convert_date_hz(p_date in DATE
                        ,p_src_timezone_code IN VARCHAR2
                        ,p_dest_timezone_code IN VARCHAR2)
RETURN DATE;
*/

-- Returns the converted DATE
FUNCTION get_DateDT(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_online_flag IN VARCHAR2
               ,p_src_timezone IN VARCHAR2)
RETURN DATE;


FUNCTION  get_Class_DateDT(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_event_id IN NUMBER)
RETURN DATE;


FUNCTION get_resource_bookingDT(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_resource_booking_id IN NUMBER)
RETURN DATE;

-- Returns the converted Time
FUNCTION get_dateDT_Time(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_online_flag IN VARCHAR2
               ,p_src_timezone IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_date_time(
                p_datevalue IN DATE
               ,p_timevalue IN VARCHAR2
               ,p_online_flag IN VARCHAR2
               ,p_src_timezone IN VARCHAR2
	       ,p_time_format IN VARCHAR2 default 'HH24:MI')
RETURN VARCHAR2;

end ota_timezone_util;


 

/
